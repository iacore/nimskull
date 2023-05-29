#
#
#           The Nim Compiler
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module handles the parsing of command line arguments.

# Switches specified when the compiler is built (-d:xxx)
# 
# Don't use the constant for anything other than printing.
const bootSwitchEnabled: seq[string] = block:
  var result: seq[string]
  
  template testSwitch(expr, userString) =
    ## Helper to build boot constants
    if expr:
      result.add(userString)

  # TODO: show all the -d:xxx used. Currently it's a limited selection
  testSwitch(defined(release), "-d:release")
  testSwitch(defined(danger), "-d:danger")
  testSwitch(defined(useLinenoise), "-d:useLinenoise")
  testSwitch(defined(tinyc), "-d:tinyc")

  result

import
  std/[
    os,
    strutils,
    parseopt,
    sequtils,
  ],
  compiler/modules/[
    nimblecmd,
  ],
  compiler/ast/[
    lineinfos,
  ],
  compiler/front/[
    options,
    optionsprocessor,
    msgs,
  ],
  experimental/[
    colortext,    # required for pretty output; TODO: factor out
  ],
  compiler/utils/[
    nversion,
    idioms,
  ]

# xxx: legacy reports cruft
from compiler/ast/report_enums import ReportKind,
  ReportKinds,
  repHintKinds,
  repHintGroups,
  repWarningKinds,
  repWarningGroups

# TODO: temporary, move into `msgs` or `commands`
type
  CmdOutputKind* = enum
    cmdOutUser        ## a command's primary output, e.g. dump's data dump
    cmdOutStatus      ## command's status, e.g. build success message
    cmdOutUserProf    ## user requested profiling output
    cmdOutInternalDbg ## explicitly secondary output for compiler tracing

proc write*(conf: ConfigRef, dest: static[CmdOutputKind], msg: string) =
  let flags =
    case dest
    of cmdOutUser:
      {msgNoUnitSep, msgStdout}
    of cmdOutInternalDbg:
      {msgNoUnitSep, msgStdout}
    of cmdOutUserProf, cmdOutStatus:
      {msgNoUnitSep} # xxx: force stderr?
  conf.msgWrite(msg, flags)

proc writeln*(conf: ConfigRef, dest: static[CmdOutputKind], msg: string) =
  write(conf, dest, msg & "\n")

# temporary home for formatting output during early cli/config phase; this
# should move to a better suited module.

const
  pathFmtStr = "$#($#, $#)" ## filename(line, column)

func stylize*(str: string, color: ForegroundColor, styles: set[Style] = {}): string =
  if str.len == 0:
    result = str
  else:
    result = "\e[$#m" % $color.int
    for s in styles:
      result.addf "\e[$#m", s.int
    result.add str
    result.add "\e[0m"

func stylize*(str: string, color: ForegroundColor,
              style: Style): string {.inline.} =
  stylize(str, color, {style})

func cliFmtLineInfo*(filename: string, line, col: int, useColor: bool): string =
  const pathFmtStr = "$#($#, $#)" ## filename(line, column)
  let pathStr = pathFmtStr % [filename, $line, $col]
  if useColor:
    stylize(pathStr, fgDefault, {styleBright})
  else:
    pathStr

func cliFmtSrcCodeOrigin*(origin: InstantiationInfo, useColor: bool): string =
  cliFmtLineInfo(origin.filename, origin.line, origin.column, useColor)

func cliFmt*(conf: ConfigRef, info: TLineInfo, useColor: bool): string =
  cliFmtLineInfo(conf.toFullPath(info), info.line.int, info.col + 1, useColor)

func cliFmtMsgOrigin*(origin: InstantiationInfo, showSuffix, useColor: bool): string =
  const suffixText = "[MsgOrigin]"
  let suffix =
        if showSuffix:
          if useColor:
            stylize(suffixText, fgCyan)
          else:
            suffixText
        else:
          ""
  result.addf "\n$# msg instantiated here$#$#",
                [cliFmtSrcCodeOrigin(origin, useColor),
                 if showSuffix: " " else: "",           # spacing
                 suffix]

proc writeLog(conf: ConfigRef, msg: string, srcLoc: InstantiationInfo) =
  var result = msg
  if conf.hasHint(rintMsgOrigin):
    result.addf cliFmtMsgOrigin(srcLoc, showSuffix = conf.hasHint(rintErrKind),
                                useColor = conf.useColor())
  conf.msgWrite(result & "\n")

proc logGcStats*(conf: ConfigRef, stats: string, srcLoc = instLoc()) =
  ## log a 'debug' level message with the GC `stats`
  # TODO: document log levels, eventual introduction of `channels`,
  #       suppression, formatting, etc
  if optCmdExitGcStats in conf.globalOptions:
    conf.writeLog(stats, srcLoc)

proc logExecStart*(conf: ConfigRef, cmd: string, srcLoc = instLoc()) =
  ## use when a command invocation begins a shell exec as part of its
  ## operations; not currently meant for shell execs initiated by input source
  ## code or scripts.
  # xxx: maybe allow configurable command action logging
  if conf.verbosity > compVerbosityDefault:
    conf.writeLog(cmd, srcLoc)

proc logError*(conf: ConfigRef, msg: string, srcLoc = instLoc()) =
  ## logs and error message, typically this means writing to console, and bumps
  ## the error counter in `ConfigRef` to ensure a non-zero exit code.
  inc conf.errorCounter
  writeLog(conf, msg, srcLoc)

proc processArgument*(pass: TCmdLinePass; p: OptParser;
                      argsCount: var int; config: ConfigRef): bool =
  if argsCount == 0:
    # nim filename.nims  is the same as "nim e filename.nims":
    if p.key.endsWith(".nims"):
      config.setCmd cmdNimscript
      incl(config, optWasNimscript)
      config.projectName = unixToNativePath(p.key)
      config.arguments = remainingArgs(p)
      result = true
    elif pass != passCmd2: setCommandEarly(config, p.key)
  else:
    if pass == passCmd1: config.commandArgs.add p.key
    if argsCount == 1:
      # support UNIX style filenames everywhere for portable build scripts:
      if config.projectName.len == 0 and config.inputMode == pimFile:
        config.projectName = unixToNativePath(p.key)
      config.arguments = remainingArgs(p)
      result = true
  inc argsCount

type
  CliFlagKind* = enum
    ## list of cli only flags
    cliFlagVersion
    cliFlagHelp
    cliFlagHelpFull
    cliFlagHelpAdvanced
    cliFlagMsgFormat

type
  CliEventKind* = enum
    # errors - cli command
    cliEvtErrInvalidCommand # main.nim
    cliEvtErrCmdMissing # cmdlinehelper.nim
    cliEvtErrCmdExpectedNoAdditionalArgs # nim.nim
      ## flag disallows additional args
    cliEvtErrFlagArgExpectedFromList # commands.nim
      ## flag expected arg from an allow/valid list, but got none
    cliEvtErrFlagArgNotFromValidList # commands.nim
      ## flag expects arg from an allow/valid list
    cliEvtErrRunCmdFailed  # commands.nim and nim.nim
    cliEvtErrGenDependFailed # main.nim
    # errors - general flag/option/switches (TODO: standardize on "flag")
    cliEvtErrUnexpectedRunOpt # commands.nim and nim.nim
    cliEvtErrFlagArgForbidden # help/version/fullhelp/etc disallow args
    cliEvtErrFlagProcessing # commands.nim
    # errors - specific flag/option/switch
    cliEvtErrNoCliParamsProvided # commands.nim and nim.nim
    # warnings - general flags/options/switches
    cliEvtWarnSwitchValDeprecatedNoop
    # hints - general flag/options/switches and/or processing
    cliEvtHintPathAdded
      ## currently only triggered if nimble adds a path
      # xxx: this doesn't feel like a hint, more like "info" or "trace"

  CliEvent* = object
    # these are not kept as 'flat' log events in order to keep clear the
    # subset-of relationships between switch processing and CLI errors, while
    # also allowing for reuse of `ProcSwitchResult` rendering facilities.
    srcCodeOrigin*: InstantiationInfo
    pass*: TCmdLinePass
    case kind*: CliEventKind
      of cliEvtErrInvalidCommand,
          cliEvtErrCmdExpectedNoAdditionalArgs,
          cliEvtErrUnexpectedRunOpt:
        cmd*: string
        unexpectedArgs*: string
      of cliEvtErrFlagArgForbidden,
          cliEvtErrFlagArgExpectedFromList,
          cliEvtErrFlagArgNotFromValidList:
        flag*: CliFlagKind  # TODO: create a restricted range this type
        givenFlg*: string
        givenArg*: string
      of cliEvtErrRunCmdFailed,
          cliEvtErrGenDependFailed:
        shellCmd*: string
        exitCode*: int
      of cliEvtErrFlagProcessing,
          cliEvtWarnSwitchValDeprecatedNoop:
        origParseOptKey*, origParseOptVal*: string
        procResult*: ProcSwitchResult
      of cliEvtHintPathAdded:
        pathAdded*: string
      of cliEvtErrNoCliParamsProvided,
          cliEvtErrCmdMissing:
        discard

const
  cliLogAllKinds = {low(CliEventKind) .. high(CliEventKind)}
  cliEvtErrors   = {cliEvtErrInvalidCommand .. cliEvtErrNoCliParamsProvided}
  cliEvtWarnings = {cliEvtWarnSwitchValDeprecatedNoop}
  cliEvtHints    = {cliEvtHintPathAdded}

static:
  const unaccountedForEvtKinds =
    cliLogAllKinds - cliEvtErrors - cliEvtWarnings - cliEvtHints
  doAssert unaccountedForEvtKinds == {}, "Uncategorized event kinds: " &
                                            $unaccountedForEvtKinds

iterator procSwitchResultToEvents*(conf: ConfigRef, pass: TCmdLinePass,
                               origParseOptKey, origParseOptVal: string,
                               r: ProcSwitchResult): CliEvent =
  # Note: the order in which this generates events is the order in which
  #       they're output, rearrange code carefully.
  case r.kind
  of procSwitchSuccess: discard
  else:
    yield CliEvent(kind: cliEvtErrFlagProcessing,
                   pass: pass,
                   origParseOptKey: origParseOptKey,
                   origParseOptVal: origParseOptVal,
                   procResult: r,
                   srcCodeOrigin: instLoc())
  case r.switch
  of cmdSwitchNimblepath:
    if conf.hasHint(rextPath) and r.processedNimblePath.didProcess:
      for res in r.processedNimblePath.nimblePathResult.addedPaths:
        yield CliEvent(kind: cliEvtHintPathAdded, pathAdded: res.string)
  else:
    discard

proc writeLog(conf: ConfigRef, msg: string, evt: CliEvent) {.inline.} =
  conf.writeLog(msg, evt.srcCodeOrigin)

proc logError*(conf: ConfigRef, evt: CliEvent) =
  # TODO: consolidate log event rendering, between this and "reports", but with
  #       less of the reports baggage
  func allowedCliOptionsArgs(flg: range[cliFlagMsgFormat..cliFlagMsgFormat]
        ): seq[string] =
    case flg
    of cliFlagMsgFormat: @["text", "sexp"]

  let msg =
    case evt.kind
    of cliEvtErrInvalidCommand:
      "Invalid command - $1" % evt.cmd
    of cliEvtErrCmdMissing:
      "Command missing"
    of cliEvtErrUnexpectedRunOpt:
      "'$1' cannot handle --run" % evt.cmd
    of cliEvtErrCmdExpectedNoAdditionalArgs:
      "$1 command does not support additional arguments: '$2'" %
        [evt.cmd, evt.unexpectedArgs]
    of cliEvtErrRunCmdFailed,
        cliEvtErrGenDependFailed: # make a better message for gen depend
      "execution of an external program '$1' failed with exit code '$2'" %
        [evt.shellCmd, $evt.exitCode]
    of cliEvtErrNoCliParamsProvided:
      "no command-line parameters provided"
    of cliEvtErrFlagArgForbidden:
      "$1 expects no arguments, but '$2' found" %
        [evt.givenFlg, evt.givenArg]
    of cliEvtErrFlagArgExpectedFromList:
      "expected value for switch '$1'. Expected one of $2, but got nothing" %
        [evt.givenFlg, allowedCliOptionsArgs(evt.flag).join(", ")]
    of cliEvtErrFlagArgNotFromValidList:
      "expected value for switch '$1'. Expected one of $2, but got nothing" %
        [evt.givenFlg, allowedCliOptionsArgs(evt.flag).join(", ")]
    of cliEvtErrFlagProcessing:
      procResultToHumanStr(evt.procResult)
    of cliEvtWarnings, cliEvtHints:
      unreachable(evt.kind)
  inc conf.errorCounter
  conf.writeLog(msg, evt)

proc logWarn(conf: ConfigRef, evt: CliEvent) =
  # TODO: see items under `logError`
  let msg =
    case evt.kind
    of cliEvtWarnSwitchValDeprecatedNoop:
      "'$#' is deprecated for flag '$#', now a noop" %
        [evt.procResult.givenArg, evt.procResult.givenSwitch]
    of cliEvtErrors, cliEvtHints:
      unreachable($evt.kind)

  inc conf.warnCounter
  conf.writeLog(msg, evt)

proc logHint(conf: ConfigRef, evt: CliEvent) =
  # TODO: see items under `logError`
  let msg =
    case evt.kind
    of cliEvtHintPathAdded:
      "added path: '$1'" % evt.pathAdded
    of cliEvtErrors, cliEvtWarnings:
      unreachable($evt.kind)

  inc conf.hintCounter
  if conf.verbosity > compVerbosityDefault:
    conf.writeLog(msg, evt)

proc cliEventLogger*(conf: ConfigRef, evt: CliEvent) =
  ## a basic event logger that will write to standard err/out as appropriate
  ## and follow `conf` settings.
  case evt.kind
  of cliEvtErrors:   conf.logError(evt)
  of cliEvtWarnings: conf.logWarn(evt)
  of cliEvtHints:    conf.logHint(evt)

const
  sourceHash {.strdefine.} = "" # defined by koch
  sourceDate {.strdefine.} = "" # defined by koch
  Banner = "Nimskull Compiler Version $1 [$2: $3]\n" % [
    VersionAsString,
    system.hostOS,
    system.hostCPU,
  ]
  CommitMessageTemplate = "Source hash: $1\n" &
                  "Source date: $2\n"
  Usage = slurp"../doc/basicopt.txt".replace(" //", "   ")
  AdvancedUsage = slurp"../doc/advopt.txt".replace(" //", "   ") %
    typeof(Feature).toSeq.mapIt($it).join("|") # '|' separated features

proc showMsg*(conf: ConfigRef, msg: string) =
  ## show a message to the user, meant for informational/status cirucmstances.
  ## Depending upon settings the message might not necessarily be output.
  ## 
  ## For command output, eg: `dump`'s conditionals and search paths use a
  ## different routine (not implemented at time or writing).
  # TODO: implement procs for actual command output
  conf.msgWrite(msg, {msgNoUnitSep})

proc writeUsage*(conf: ConfigRef) =
  conf.showMsg:
    Banner & Usage

proc writeAdvancedUsage(conf: ConfigRef) =
  conf.showMsg:
    Banner & AdvancedUsage

proc writeFullhelp(conf: ConfigRef) =
  conf.showMsg:
    Banner & Usage & AdvancedUsage

proc writeVersionInfo(conf: ConfigRef) =
  let
    commitMsg =
      if sourceHash != "":
        "\n" & CommitMessageTemplate % [sourceHash, sourceDate]
      else:
        ""
  
  var bootSwitchesMsg = ""
  for switchEnabled in bootSwitchEnabled:
    bootSwitchesMsg &= " "
    bootSwitchesMsg &= switchEnabled
  
  conf.showMsg:
    Banner &
    commitMsg &
    "\nactive boot switches:" & bootSwitchesMsg

proc processCmdLine*(pass: TCmdLinePass, cmd: openArray[string]; config: ConfigRef) =
  ## Process input command-line parameters into `config` settings. Input is
  ## a joined list of command-line arguments with multiple options and/or
  ## configurations.
  var
    p = parseopt.initOptParser(cmd) # xxx: `cmd` is always empty, this relies
                                    #      on `parseOpt` using `os` to get the
                                    #      cli params
    argsCount = 0

  config.commandLine.setLen 0
    # bugfix: otherwise, config.commandLine ends up duplicated

  template expectNoArg(f: CliFlagKind, flg, arg: string) =
    if arg != "":
      config.cliEventLogger:
        CliEvent(kind: cliEvtErrFlagArgForbidden,
                flag: f,
                givenFlg: flg,
                givenArg: arg,
                pass: pass,
                srcCodeOrigin: instLoc())

  while true:
    parseopt.next(p)
    case p.kind
    of cmdEnd: break
    of cmdLongOption, cmdShortOption:
      config.commandLine.add:
        case p.kind
        of cmdShortOption: " -"
        of cmdLongOption:  " --"
        else: unreachable()
      config.commandLine.add p.key.quoteShell # quoteShell to be future proof
      if p.val.len > 0:
        config.commandLine.add ':'
        config.commandLine.add p.val.quoteShell

      # this only happens in passCmd1 as each of these triggers a quit
      case p.key.normalize
      of "version", "v":
        # only kept because of user expectations
        expectNoArg(cliFlagVersion, p.key, p.val)
        writeVersionInfo(config)
        msgQuit(0)
      of "help", "h":
        # only kept because of user expectations
        expectNoArg(cliFlagHelp, p.key, p.val)
        writeUsage(config)
        msgQuit(0)
      of "advanced":
        # deprecate/make it a switch for the help sub-command
        expectNoArg(cliFlagHelpAdvanced, p.key, p.val)
        writeAdvancedUsage(config)
        msgQuit(0)
      of "fullhelp":
        # deprecate/make it a switch for the help sub-command
        expectNoArg(cliFlagHelpFull, p.key, p.val)
        writeFullhelp(config)
        msgQuit(0)
      of "msgformat":
        case p.val.normalize
        of "text": config.setMsgFormat(config, msgFormatText)
        of "sexp": config.setMsgFormat(config, msgFormatSexp)
        of "":
          config.cliEventLogger:
            CliEvent(kind: cliEvtErrFlagArgExpectedFromList,
                    flag: cliFlagMsgFormat, givenFlg: p.key,
                    givenArg: p.val, pass: pass,
                    srcCodeOrigin: instLoc())
        else:
          config.cliEventLogger:
            CliEvent(kind: cliEvtErrFlagArgNotFromValidList,
                    flag: cliFlagMsgFormat, givenFlg: p.key,
                    givenArg: p.val, pass: pass,
                    srcCodeOrigin: instLoc())
      else:
        if p.key == "": # `-` was passed to indicate main project is stdin
          p.key = "-"
          if processArgument(pass, p, argsCount, config):
            break
        else:
          # Main part of the configuration processing -
          # `commands.processSwitch` processes input switches a second time
          # and puts them in necessary configuration fields.
          let res = processSwitch(pass, p, config)
          for e in procSwitchResultToEvents(config, pass, p.key, p.val, res):
            config.cliEventLogger(e)
    of cmdArgument:
      config.commandLine.add " "
      config.commandLine.add p.key.quoteShell
      if processArgument(pass, p, argsCount, config):
        break

  if pass == passCmd2:
    if {optRun, optWasNimscript} * config.globalOptions == {} and
        config.arguments.len > 0 and config.cmd notin {
          cmdTcc, cmdNimscript, cmdCrun}:
      config.cliEventLogger:
        CliEvent(kind: cliEvtErrUnexpectedRunOpt,
                  cmd: config.command,
                  pass: pass,
                  srcCodeOrigin: instLoc())
