
type
  # TODO:
  # - rename to `Cmd` to `Cfg`, as only the CLI/cmd has version, help,
  #   fullhelp, advanced and perhaps others
  # - separate flags/switches and commands
  CmdSwitchKind* = enum
    cmdSwitchFromcmd
    cmdSwitchPath
    cmdSwitchNimblepath
    cmdSwitchNonimblepath
    cmdSwitchClearnimblepath
    cmdSwitchExcludepath
    cmdSwitchNimcache
    cmdSwitchOut
    cmdSwitchOutdir
    cmdSwitchDepfile
    cmdSwitchUsenimcache
    cmdSwitchDocseesrcurl
    cmdSwitchDocroot
    cmdSwitchBackend
    cmdSwitchDoccmd
    cmdSwitchDefine
    cmdSwitchUndef
    cmdSwitchCompile
    cmdSwitchLink
    cmdSwitchDebuginfo
    cmdSwitchEmbedsrc
    cmdSwitchCompileonly
    cmdSwitchNolinking
    cmdSwitchNomain
    cmdSwitchForcebuild
    cmdSwitchProject
    cmdSwitchGc
    cmdSwitchWarnings
    cmdSwitchWarning
    cmdSwitchHint
    cmdSwitchWarningaserror
    cmdSwitchHintaserror
    cmdSwitchHints
    cmdSwitchThreadanalysis
    cmdSwitchStacktrace
    cmdSwitchStacktracemsgs
    cmdSwitchExcessivestacktrace
    cmdSwitchLinetrace
    cmdSwitchDebugger
    cmdSwitchProfiler
    cmdSwitchMemtracker
    cmdSwitchChecks
    cmdSwitchFloatchecks
    cmdSwitchInfchecks
    cmdSwitchNanchecks
    cmdSwitchObjchecks
    cmdSwitchFieldchecks
    cmdSwitchRangechecks
    cmdSwitchBoundchecks
    cmdSwitchOverflowchecks
    cmdSwitchStaticboundchecks
    cmdSwitchStylechecks
    cmdSwitchLinedir
    cmdSwitchAssertions
    cmdSwitchThreads
    cmdSwitchTlsemulation
    cmdSwitchImplicitstatic
    cmdSwitchTrmacros
    cmdSwitchOpt
    cmdSwitchApp
    cmdSwitchPassc
    cmdSwitchPassl
    cmdSwitchCincludes
    cmdSwitchClibdir
    cmdSwitchClib
    cmdSwitchHeader
    cmdSwitchIndex
    cmdSwitchImport
    cmdSwitchInclude
    cmdSwitchListcmd
    cmdSwitchAsm
    cmdSwitchGenmapping
    cmdSwitchOs
    cmdSwitchCpu
    cmdSwitchRun
    cmdSwitchMaxloopiterationsvm
    cmdSwitchErrormax
    cmdSwitchVerbosity
    cmdSwitchParallelbuild
    cmdSwitchVersion      # CLI only, forces a quit
    cmdSwitchAdvanced     # CLI only, forces a quit
    cmdSwitchFullhelp     # CLI only, forces a quit
    cmdSwitchHelp         # CLI only, forces a quit
    cmdSwitchIncremental
    cmdSwitchSkipcfg
    cmdSwitchSkipprojcfg
    cmdSwitchSkipusercfg
    cmdSwitchSkipparentcfg
    cmdSwitchGenscript
    cmdSwitchColors
    cmdSwitchLib
    cmdSwitchPutenv
    cmdSwitchCc
    cmdSwitchStdout
    cmdSwitchFilenames
    cmdSwitchMsgformat    # CLI only
    cmdSwitchProcessing
    cmdSwitchUnitsep
    cmdSwitchListfullpaths
    cmdSwitchSpellsuggest
    cmdSwitchDeclaredlocs
    cmdSwitchDynliboverride
    cmdSwitchDynliboverrideall
    cmdSwitchExperimental
    cmdSwitchExceptions
    cmdSwitchCppdefine
    cmdSwitchSeqsv2
    cmdSwitchStylecheck
    cmdSwitchShowallmismatches
    cmdSwitchDocinternal
    cmdSwitchMultimethods
    cmdSwitchExpandmacro
    cmdSwitchExpandarc
    cmdSwitchBenchmarkvm
    cmdSwitchProfilevm
    cmdSwitchSinkinference
    cmdSwitchCursorinference
    cmdSwitchPanics
    cmdSwitchSourcemap
    cmdSwitchDeepcopy
    cmdSwitchProjStdin
    cmdSwitchCmdexitgcstats
    cmdSwitchConfigVar

  # Full list of all the command line options.
  CmdSwitchTextKind* = enum
    fullSwitchTxtFromcmd             = "fromcmd"
    fullSwitchTxtPath                = "path",        smolSwitchTxtPath        = "p",
    fullSwitchTxtNimblepath          = "nimblepath"
    fullSwitchTxtNonimblepath        = "nonimblepath"
    fullSwitchTxtClearnimblepath     = "clearnimblepath"
    fullSwitchTxtExcludepath         = "excludepath"
    fullSwitchTxtNimcache            = "nimcache"
    fullSwitchTxtOut                 = "out",         smolSwitchTxtOut         = "o",
    fullSwitchTxtOutdir              = "outdir"
    fullSwitchTxtDepfile             = "depfile"
    fullSwitchTxtUsenimcache         = "usenimcache"
    fullSwitchTxtDocseesrcurl        = "docseesrcurl"
    fullSwitchTxtDocroot             = "docroot"
    fullSwitchTxtBackend             = "backend",     smolSwitchTxtBackend     = "b",
    fullSwitchTxtDoccmd              = "doccmd"
    fullSwitchTxtDefine              = "define",      smolSwitchTxtDefine      = "d",
    fullSwitchTxtUndef               = "undef",       smolSwitchTxtUndef       = "u",
    fullSwitchTxtCompile             = "compile"
    fullSwitchTxtLink                = "link"
    fullSwitchTxtDebuginfo           = "debuginfo"
    fullSwitchTxtEmbedsrc            = "embedsrc"
    fullSwitchTxtCompileonly         = "compileonly", smolSwitchTxtCompileonly = "c",
    fullSwitchTxtNolinking           = "nolinking"
    fullSwitchTxtNomain              = "nomain"
    fullSwitchTxtForcebuild          = "forcebuild",  smolSwitchTxtForcebuild  = "f",
    fullSwitchTxtGc                  = "gc",
    fullSwitchTxtProject             = "project"
    fullSwitchTxtWarnings            = "warnings",    smolSwitchTxtWarnings    = "w",
    fullSwitchTxtWarning             = "warning"
    fullSwitchTxtHint                = "hint"
    fullSwitchTxtWarningaserror      = "warningaserror"
    fullSwitchTxtHintaserror         = "hintaserror"
    fullSwitchTxtHints               = "hints"
    fullSwitchTxtThreadanalysis      = "threadanalysis"
    fullSwitchTxtStacktrace          = "stacktrace"
    fullSwitchTxtStacktracemsgs      = "stacktracemsgs"
    fullSwitchTxtExcessivestacktrace = "excessivestacktrace"
    fullSwitchTxtLinetrace           = "linetrace"
    fullSwitchTxtDebugger            = "debugger",
    fullSwitchTxtProfiler            = "profiler"
    fullSwitchTxtMemtracker          = "memtracker"
    fullSwitchTxtChecks              = "checks"
    fullSwitchTxtFloatchecks         = "floatchecks"
    fullSwitchTxtInfchecks           = "infchecks"
    fullSwitchTxtNanchecks           = "nanchecks"
    fullSwitchTxtObjchecks           = "objchecks"
    fullSwitchTxtFieldchecks         = "fieldchecks"
    fullSwitchTxtRangechecks         = "rangechecks"
    fullSwitchTxtBoundchecks         = "boundchecks"
    fullSwitchTxtOverflowchecks      = "overflowchecks"
    fullSwitchTxtStaticboundchecks   = "staticboundchecks"
    fullSwitchTxtStylechecks         = "stylechecks"
    fullSwitchTxtLinedir             = "linedir"
    fullSwitchTxtAssertions          = "assertions"
    fullSwitchTxtThreads             = "threads"
    fullSwitchTxtTlsemulation        = "tlsemulation"
    fullSwitchTxtImplicitstatic      = "implicitstatic"
    fullSwitchTxtTrmacros            = "trmacros"
    fullSwitchTxtOpt                 = "opt"
    fullSwitchTxtApp                 = "app"
    fullSwitchTxtPassc               = "passc"
    fullSwitchTxtPassl               = "passl"
    fullSwitchTxtCincludes           = "cincludes"
    fullSwitchTxtClibdir             = "clibdir"
    fullSwitchTxtClib                = "clib"
    fullSwitchTxtHeader              = "header"
    fullSwitchTxtIndex               = "index"
    fullSwitchTxtImport              = "import"
    fullSwitchTxtInclude             = "include"
    fullSwitchTxtListcmd             = "listcmd"
    fullSwitchTxtAsm                 = "asm"
    fullSwitchTxtGenmapping          = "genmapping"
    fullSwitchTxtOs                  = "os"
    fullSwitchTxtCpu                 = "cpu"
    fullSwitchTxtRun                 = "run"
    fullSwitchTxtMaxloopiterationsvm = "maxloopiterationsvm"
    fullSwitchTxtErrormax            = "errormax"
    fullSwitchTxtVerbosity           = "verbosity"
    fullSwitchTxtParallelbuild       = "parallelbuild"
    fullSwitchTxtVersion             = "version"
    smolSwitchTxtVersion             = "v"
    fullSwitchTxtAdvanced            = "advanced"
    fullSwitchTxtFullhelp            = "fullhelp"
    fullSwitchTxtHelp                = "help"
    smolSwitchTxtHelp                = "h"
    fullSwitchTxtIncremental         = "incremental"
    aliasSwitchTxtIncremental        = "ic'"
    fullSwitchTxtSkipcfg             = "skipcfg"
    fullSwitchTxtSkipprojcfg         = "skipprojcfg"
    fullSwitchTxtSkipusercfg         = "skipusercfg"
    fullSwitchTxtSkipparentcfg       = "skipparentcfg"
    fullSwitchTxtGenscript           = "genscript"
    fullSwitchTxtColors              = "colors"
    fullSwitchTxtLib                 = "lib"
    fullSwitchTxtPutenv              = "putenv"
    fullSwitchTxtCc                  = "cc"
    fullSwitchTxtStdout              = "stdout"
    fullSwitchTxtFilenames           = "filenames"
    fullSwitchTxtMsgformat           = "msgformat"
    fullSwitchTxtProcessing          = "processing"
    fullSwitchTxtUnitsep             = "unitsep"
    fullSwitchTxtListfullpaths       = "listfullpaths"
    fullSwitchTxtSpellsuggest        = "spellsuggest"
    fullSwitchTxtDeclaredlocs        = "declaredlocs"
    fullSwitchTxtDynliboverride      = "dynliboverride"
    fullSwitchTxtDynliboverrideall   = "dynliboverrideall"
    fullSwitchTxtExperimental        = "experimental"
    fullSwitchTxtExceptions          = "exceptions"
    fullSwitchTxtCppdefine           = "cppdefine"
    fullSwitchTxtSeqsv2              = "seqsv2"
    fullSwitchTxtStylecheck          = "stylecheck"
    fullSwitchTxtShowallmismatches   = "showallmismatches"
    fullSwitchTxtDocinternal         = "docinternal"
    fullSwitchTxtMultimethods        = "multimethods"
    fullSwitchTxtExpandmacro         = "expandmacro"
    fullSwitchTxtExpandarc           = "expandarc"
    fullSwitchTxtBenchmarkvm         = "benchmarkvm"
    fullSwitchTxtProfilevm           = "profilevm"
    fullSwitchTxtSinkinference       = "sinkinference"
    fullSwitchTxtCursorinference     = "cursorinference"
    fullSwitchTxtPanics              = "panics"
    fullSwitchTxtSourcemap           = "sourcemap"
    fullSwitchTxtDeepcopy            = "deepcopy"
    fullSwitchTxtCmdexitgcstats      = "cmdexitgcstats"
    smolSwitchTxtProjStdin           = ""               # `nim c -r -`, the `-` gets stripped
    fullSwitchTxtConfigVar           = "*.*"            # cfg var dummy entry
    fullSwitchTxtInvalid             = "!ERROR!"

const
    cmdSwitchToTxt = [
      cmdSwitchFromcmd            : {fullSwitchTxtFromcmd},
      cmdSwitchPath               : {fullSwitchTxtPath, smolSwitchTxtPath},
      cmdSwitchNimblepath         : {fullSwitchTxtNimblepath},
      cmdSwitchNonimblepath       : {fullSwitchTxtNonimblepath},
      cmdSwitchClearnimblepath    : {fullSwitchTxtClearnimblepath},
      cmdSwitchExcludepath        : {fullSwitchTxtExcludepath},
      cmdSwitchNimcache           : {fullSwitchTxtNimcache},
      cmdSwitchOut                : {fullSwitchTxtOut, smolSwitchTxtOut},
      cmdSwitchOutdir             : {fullSwitchTxtOutdir},
      cmdSwitchDepfile            : {fullSwitchTxtDepfile},
      cmdSwitchUsenimcache        : {fullSwitchTxtUsenimcache},
      cmdSwitchDocseesrcurl       : {fullSwitchTxtDocseesrcurl},
      cmdSwitchDocroot            : {fullSwitchTxtDocroot},
      cmdSwitchBackend            : {fullSwitchTxtBackend, smolSwitchTxtBackend},
      cmdSwitchDoccmd             : {fullSwitchTxtDoccmd},
      cmdSwitchDefine             : {fullSwitchTxtDefine, smolSwitchTxtDefine},
      cmdSwitchUndef              : {fullSwitchTxtUndef, smolSwitchTxtUndef},
      cmdSwitchCompile            : {fullSwitchTxtCompile},
      cmdSwitchLink               : {fullSwitchTxtLink},
      cmdSwitchDebuginfo          : {fullSwitchTxtDebuginfo},
      cmdSwitchEmbedsrc           : {fullSwitchTxtEmbedsrc},
      cmdSwitchCompileonly        : {fullSwitchTxtCompileonly, smolSwitchTxtCompileonly},
      cmdSwitchNolinking          : {fullSwitchTxtNolinking},
      cmdSwitchNomain             : {fullSwitchTxtNomain},
      cmdSwitchForcebuild         : {fullSwitchTxtForcebuild, smolSwitchTxtForcebuild},
      cmdSwitchProject            : {fullSwitchTxtProject},
      cmdSwitchGc                 : {fullSwitchTxtGc},
      cmdSwitchWarnings           : {fullSwitchTxtWarnings, smolSwitchTxtWarnings},
      cmdSwitchWarning            : {fullSwitchTxtWarning},
      cmdSwitchHint               : {fullSwitchTxtHint},
      cmdSwitchWarningaserror     : {fullSwitchTxtWarningaserror},
      cmdSwitchHintaserror        : {fullSwitchTxtHintaserror},
      cmdSwitchHints              : {fullSwitchTxtHints},
      cmdSwitchThreadanalysis     : {fullSwitchTxtThreadanalysis},
      cmdSwitchStacktrace         : {fullSwitchTxtStacktrace},
      cmdSwitchStacktracemsgs     : {fullSwitchTxtStacktracemsgs},
      cmdSwitchExcessivestacktrace: {fullSwitchTxtExcessivestacktrace},
      cmdSwitchLinetrace          : {fullSwitchTxtLinetrace},
      cmdSwitchDebugger           : {fullSwitchTxtDebugger},
      cmdSwitchProfiler           : {fullSwitchTxtProfiler},
      cmdSwitchMemtracker         : {fullSwitchTxtMemtracker},
      cmdSwitchChecks             : {fullSwitchTxtChecks},
      cmdSwitchFloatchecks        : {fullSwitchTxtFloatchecks},
      cmdSwitchInfchecks          : {fullSwitchTxtInfchecks},
      cmdSwitchNanchecks          : {fullSwitchTxtNanchecks},
      cmdSwitchObjchecks          : {fullSwitchTxtObjchecks},
      cmdSwitchFieldchecks        : {fullSwitchTxtFieldchecks},
      cmdSwitchRangechecks        : {fullSwitchTxtRangechecks},
      cmdSwitchBoundchecks        : {fullSwitchTxtBoundchecks},
      cmdSwitchOverflowchecks     : {fullSwitchTxtOverflowchecks},
      cmdSwitchStaticboundchecks  : {fullSwitchTxtStaticboundchecks},
      cmdSwitchStylechecks        : {fullSwitchTxtStylechecks},
      cmdSwitchLinedir            : {fullSwitchTxtLinedir},
      cmdSwitchAssertions         : {fullSwitchTxtAssertions},
      cmdSwitchThreads            : {fullSwitchTxtThreads},
      cmdSwitchTlsemulation       : {fullSwitchTxtTlsemulation},
      cmdSwitchImplicitstatic     : {fullSwitchTxtImplicitstatic},
      cmdSwitchTrmacros           : {fullSwitchTxtTrmacros},
      cmdSwitchOpt                : {fullSwitchTxtOpt},
      cmdSwitchApp                : {fullSwitchTxtApp},
      cmdSwitchPassc              : {fullSwitchTxtPassc},
      cmdSwitchPassl              : {fullSwitchTxtPassl},
      cmdSwitchCincludes          : {fullSwitchTxtCincludes},
      cmdSwitchClibdir            : {fullSwitchTxtClibdir},
      cmdSwitchClib               : {fullSwitchTxtClib},
      cmdSwitchHeader             : {fullSwitchTxtHeader},
      cmdSwitchIndex              : {fullSwitchTxtIndex},
      cmdSwitchImport             : {fullSwitchTxtImport},
      cmdSwitchInclude            : {fullSwitchTxtInclude},
      cmdSwitchListcmd            : {fullSwitchTxtListcmd},
      cmdSwitchAsm                : {fullSwitchTxtAsm},
      cmdSwitchGenmapping         : {fullSwitchTxtGenmapping},
      cmdSwitchOs                 : {fullSwitchTxtOs},
      cmdSwitchCpu                : {fullSwitchTxtCpu},
      cmdSwitchRun                : {fullSwitchTxtRun},
      cmdSwitchMaxloopiterationsvm: {fullSwitchTxtMaxloopiterationsvm},
      cmdSwitchErrormax           : {fullSwitchTxtErrormax},
      cmdSwitchVerbosity          : {fullSwitchTxtVerbosity},
      cmdSwitchParallelbuild      : {fullSwitchTxtParallelbuild},
      cmdSwitchVersion            : {fullSwitchTxtVersion, smolSwitchTxtVersion},
      cmdSwitchAdvanced           : {fullSwitchTxtAdvanced},
      cmdSwitchFullhelp           : {fullSwitchTxtFullhelp},
      cmdSwitchHelp               : {fullSwitchTxtHelp, smolSwitchTxtHelp},
      cmdSwitchIncremental        : {fullSwitchTxtIncremental, aliasSwitchTxtIncremental},
      cmdSwitchSkipcfg            : {fullSwitchTxtSkipcfg},
      cmdSwitchSkipprojcfg        : {fullSwitchTxtSkipprojcfg},
      cmdSwitchSkipusercfg        : {fullSwitchTxtSkipusercfg},
      cmdSwitchSkipparentcfg      : {fullSwitchTxtSkipparentcfg},
      cmdSwitchGenscript          : {fullSwitchTxtGenscript},
      cmdSwitchColors             : {fullSwitchTxtColors},
      cmdSwitchLib                : {fullSwitchTxtLib},
      cmdSwitchPutenv             : {fullSwitchTxtPutenv},
      cmdSwitchCc                 : {fullSwitchTxtCc},
      cmdSwitchStdout             : {fullSwitchTxtStdout},
      cmdSwitchFilenames          : {fullSwitchTxtFilenames},
      cmdSwitchMsgformat          : {fullSwitchTxtMsgformat},
      cmdSwitchProcessing         : {fullSwitchTxtProcessing},
      cmdSwitchUnitsep            : {fullSwitchTxtUnitsep},
      cmdSwitchListfullpaths      : {fullSwitchTxtListfullpaths},
      cmdSwitchSpellsuggest       : {fullSwitchTxtSpellsuggest},
      cmdSwitchDeclaredlocs       : {fullSwitchTxtDeclaredlocs},
      cmdSwitchDynliboverride     : {fullSwitchTxtDynliboverride},
      cmdSwitchDynliboverrideall  : {fullSwitchTxtDynliboverrideall},
      cmdSwitchExperimental       : {fullSwitchTxtExperimental},
      cmdSwitchExceptions         : {fullSwitchTxtExceptions},
      cmdSwitchCppdefine          : {fullSwitchTxtCppdefine},
      cmdSwitchSeqsv2             : {fullSwitchTxtSeqsv2},
      cmdSwitchStylecheck         : {fullSwitchTxtStylecheck},
      cmdSwitchShowallmismatches  : {fullSwitchTxtShowallmismatches},
      cmdSwitchDocinternal        : {fullSwitchTxtDocinternal},
      cmdSwitchMultimethods       : {fullSwitchTxtMultimethods},
      cmdSwitchExpandmacro        : {fullSwitchTxtExpandmacro},
      cmdSwitchExpandarc          : {fullSwitchTxtExpandarc},
      cmdSwitchBenchmarkvm        : {fullSwitchTxtBenchmarkvm},
      cmdSwitchProfilevm          : {fullSwitchTxtProfilevm},
      cmdSwitchSinkinference      : {fullSwitchTxtSinkinference},
      cmdSwitchCursorinference    : {fullSwitchTxtCursorinference},
      cmdSwitchPanics             : {fullSwitchTxtPanics},
      cmdSwitchSourcemap          : {fullSwitchTxtSourcemap},
      cmdSwitchDeepcopy           : {fullSwitchTxtDeepcopy},
      cmdSwitchProjStdin          : {smolSwitchTxtProjStdin},
      cmdSwitchCmdexitgcstats     : {fullSwitchTxtCmdexitgcstats},
      cmdSwitchConfigVar          : {fullSwitchTxtConfigVar},
    ]

type
  CliOptDef* = object
    name*: string
    ## if empty, then it doesn't have short version
    short*: string
    ## if empty, then it doesn't have long version
    long*: string

import std/strformat

proc print_switch(switch: CliOptDef) =
  echo &"CliOptDef(name: {switch.name.repr},"
  if switch.short.len != 0:
    doAssert switch.short.len == 1
    echo &"  short: some {switch.short[0].repr},"
  if switch.long.len != 0:
    echo &"  long: some {switch.long.repr},"
  echo &"  kind: CliOptKind.set, ),"

echo """
# DO NOT EDIT. generated with 'nim r tools/gencommands2.nim > compiler/front/commands2.nim'

import std/options

type
  CliOptKind* {.pure.} = enum
    set # set or unset
    boolean # --foo:on and --foo:off

  CliOptDef* = object
    name*: string
    ## if empty, then it doesn't have short version
    short*: Option[char]
    ## if empty, then it doesn't have long version
    long*: Option[string]
    ## what kind of switch it is
    kind*: CliOptKind

const allCliOptions* = [
"""

for cmd, txts in cmdSwitchToTxt.pairs:
  const prefix = "cmdSwitch"
  let name = $cmd
  doAssert name[0..<prefix.len] == prefix
  let name_stripped = name[prefix.len..^1]
  
  var switch = CliOptDef(name: name_stripped)
  
  for txt in txts:
    let switchtext = $txt
    if switchtext.len == 0:
      discard
    elif switchtext.len == 1:
      switch.short = switchtext
    else:
      switch.long = switchtext
  
  print_switch(switch)

echo "]"
