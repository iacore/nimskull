import os, uri, strformat, strutils
import std/private/gitutils

proc exec*(args: openArray[string]) =
  let cmd = quoteShellCommand(args)
  echo "deps.cmd: " & cmd
  let status = execShellCmd(cmd)
  doAssert status == 0, cmd

proc execRetry*(args: openArray[string]) =
  let cmd = quoteShellCommand(args)
  let ok = retryCall(call = block:
    let status = execShellCmd(cmd)
    let result = status == 0
    if not result:
      echo fmt"failed command: '{cmd}', status: {status}"
    result)
  doAssert ok, cmd

proc cloneDependency*(destDirBase: string, url: string, commit = commitHead,
                      appendRepoName = true, allowBundled = false) =
  let destDirBase = destDirBase.absolutePath
  let p = url.parseUri.path
  let name = p.splitFile.name
  var destDir = destDirBase
  if appendRepoName: destDir = destDir / name
  if not dirExists(destDir):
    # note: old code used `destDir / .git` but that wouldn't prevent git clone
    # from failing
    execRetry ["git", "clone", "-q", "url", destDir]
  if isGitRepo(destDir):
    let oldDir = getCurrentDir()
    setCurrentDir(destDir)
    try:
      execRetry ["git", "fetch", "-q"]
      exec ["git", "checkout", "-q", "commit"]
    finally:
      setCurrentDir(oldDir)
  elif allowBundled:
    discard "this dependency was bundled with Nim, don't do anything"
  else:
    quit "FAILURE: " & destdir & " already exists but is not a git repo"
