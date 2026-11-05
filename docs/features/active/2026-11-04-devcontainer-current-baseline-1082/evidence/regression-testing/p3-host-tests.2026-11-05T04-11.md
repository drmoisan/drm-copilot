Timestamp: 2026-11-05T04-11
Started: 2026-11-05T04:11:22.1153669Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp\codex-container-baseline\issue-1082\issue-1082-current-powershell.sh host
EXIT_CODE: 0
Output Summary:

```text
   [+] AC11-NPM-NONZERO-NO-THROW does not throw and emits nothing when npm exits nonzero 8ms
 Context Invoke-HostBootstrapWsl
   [+] AC11-WSL-STREAMS passes -StreamToHost and emits no captured output when wsl exits 0 11ms
   [+] throws when wsl exits nonzero 7ms
 Context Invoke-HostBootstrapVerifyScript
   [+] invokes the given command path and returns its output 13ms
 Context Invoke-HostBootstrapPoetry
   [+] AC11-POETRY-STREAMS passes -StreamToHost and emits no captured output when poetry exits 0 27ms
   [+] throws when poetry exits nonzero 16ms
   [+] AC11-PYTHON-POETRY-STREAMS passes -StreamToHost and emits no captured output when python -m poetry exits 0 29ms
   [+] throws when python -m poetry exits nonzero 29ms
   [+] throws when neither poetry nor python is available 20ms

Describing Get-ProjectRepositoriesFromManifest
  [+] returns the projectRepositories entries when present 7ms
  [+] returns an empty list when projectRepositories is absent 4ms

Describing Resolve-WorkspaceRoot
  [+] returns the current location when the path is blank 14ms
  [+] returns the full form of an explicit path 4ms
  [+] resolves a relative path against the PowerShell location, not the process directory 9ms

Describing Initialize-WorkspaceRoot
  [+] reports an existing workspace root without creating it 14ms
  [+] reports the planned creation in dry run 12ms
  [+] creates the workspace root in apply mode 21ms

Describing Sync-ProjectsFromManifest
  [+] throws when a project has no url 10ms
  [+] derives the target path from the url in dry run 28ms
  [+] skips a project that is already present 16ms
  [+] reports the planned clone with an explicit target path in dry run 13ms
  [+] clones the project through the git wrapper in apply mode 18ms

Describing Resolve-ProjectRepoRoot
  [+] AC08-RESOLVE-EMPTY-PROJECTS returns the default repo root for an empty project list 13ms
  [+] returns the full form of an explicit repo root 3ms
  [+] resolves a relative explicit repo root against the PowerShell location, not the process directory 6ms
  [+] returns the default repo root when it contains pyproject.toml 12ms
  [+] returns the drm-copilot project target path under the workspace 16ms
  [+] falls back to the drm-copilot folder name when the project target path is empty 10ms
  [+] returns an empty string when no root can be resolved 11ms
Tests completed in 7.71s
Tests Passed: 104, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
RESULT=Passed passed=104 failed=0 skipped=0
```

Raw output: SCRATCH/issue-1082-p3-host-tests.log
