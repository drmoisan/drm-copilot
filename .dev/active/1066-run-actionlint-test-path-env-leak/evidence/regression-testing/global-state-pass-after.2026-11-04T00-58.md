# Global-State Pass-After over TARGET and GUARD (P2-T4)

Timestamp: 2026-11-04T00-58
Command: pwsh -NoProfile -File SCRATCH/issue-1066-global-state.ps1 -TestFile tests/scripts/dev-tools/run-actionlint.Tests.ps1; pwsh -NoProfile -File SCRATCH/issue-1066-global-state.ps1 -TestFile tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
EXIT_CODE: 1
Output Summary:
- Acceptance result: NOT MET. Both runs exit 1, and both printed differences are non-empty; the task is left unchecked and execution stops here.
- TARGET run: nested Total=35 Failed=0. Difference (3): `FUNCTION added Compress-Archive`, `FUNCTION added Expand-Archive`, `FUNCTION added Import-ScriptFunction`. No environment, location, alias, global-variable, or LASTEXITCODE entry remains; the pre-fix `ENV changed PATH` entry (P0-T10) is gone.
- GUARD run: nested Total=3 Failed=0. Difference (3): the same three function entries, which come from the nested TARGET run inside GUARD.
- Origin of the remaining entries (verified):
  - `Import-ScriptFunction` is defined with `function global:` by tests/scripts/powershell/Support/TestHelpers.ps1, which TARGET dot-sources at file scope (4 test files dot-source TestHelpers; 5 reference Import-ScriptFunction).
  - `Compress-Archive` and `Expand-Archive` are exported by the Microsoft.PowerShell.Archive module, which is auto-loaded when a test mocks `Expand-Archive`. A probe (pwsh -NoProfile -Command: nested Invoke-Pester over an in-memory container whose only test runs `Mock Expand-Archive {}`, then lists the functions added) printed `Compress-Archive,Expand-Archive` and `Microsoft.PowerShell.Archive`.
- `$global:LASTEXITCODE`: the control delta and the target delta both end at 0 because Pester itself leaves 0 after a nested run, so this tool cannot distinguish the DD1 LASTEXITCODE restore on this host.
- Neither remaining entry is an environment variable; DD1 restores only `$env:PATH` and `$global:LASTEXITCODE`, and the plan does not authorize a TARGET change for module or helper-function state. Closing the gap needs a plan decision: either a TARGET change that removes the global helper and the auto-loaded module after the file runs (outside DD1), or a revised P2-T4 acceptance and AC3 interpretation that treats module auto-load and the shared global helper as out of scope.

## TARGET run output

```text
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
GLOBAL-STATE: TargetTotal=35 TargetFailed=0 ControlTotal=0
CONTROL-DELTA: 1
  C LASTEXITCODE after exists=True value=0
TARGET-DELTA: 4
  T FUNCTION added Compress-Archive
  T FUNCTION added Expand-Archive
  T FUNCTION added Import-ScriptFunction
  T LASTEXITCODE after exists=True value=0
DIFFERENCE: 3
  D FUNCTION added Compress-Archive
  D FUNCTION added Expand-Archive
  D FUNCTION added Import-ScriptFunction
EXIT_CODE=1
```

## GUARD run output

```text
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
GLOBAL-STATE: TargetTotal=3 TargetFailed=0 ControlTotal=0
CONTROL-DELTA: 1
  C LASTEXITCODE after exists=True value=0
TARGET-DELTA: 4
  T FUNCTION added Compress-Archive
  T FUNCTION added Expand-Archive
  T FUNCTION added Import-ScriptFunction
  T LASTEXITCODE after exists=True value=0
DIFFERENCE: 3
  D FUNCTION added Compress-Archive
  D FUNCTION added Expand-Archive
  D FUNCTION added Import-ScriptFunction
EXIT_CODE=1
```
