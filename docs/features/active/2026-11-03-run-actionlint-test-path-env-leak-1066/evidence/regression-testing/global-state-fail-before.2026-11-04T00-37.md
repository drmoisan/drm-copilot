# Global-State Fail-Before over TARGET (P0-T10)

Timestamp: 2026-11-04T00-37
Command: pwsh -NoProfile -File SCRATCH/issue-1066-global-state.ps1 -TestFile tests/scripts/dev-tools/run-actionlint.Tests.ps1
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Nested TARGET run: Total=35 Failed=0. Control (empty in-memory container): Total=0.
- Control delta (1): `LASTEXITCODE after exists=True value=0` (sentinel 41 before the nested run; the nested harness itself leaves 0).
- Target delta (5): `ENV changed PATH`, `FUNCTION added Compress-Archive`, `FUNCTION added Expand-Archive`, `FUNCTION added Import-ScriptFunction`, `LASTEXITCODE after exists=True value=0`.
- Printed difference (target delta minus control delta, 4): `ENV changed PATH`, `FUNCTION added Compress-Archive`, `FUNCTION added Expand-Archive`, `FUNCTION added Import-ScriptFunction`. The difference contains the environment key `PATH`; exit 1 as expected.

Observation recorded for later tasks: the three function entries are not produced by an `$env:` assignment. `Import-ScriptFunction` is defined with `function global:` by `tests/scripts/powershell/Support/TestHelpers.ps1`, which TARGET dot-sources at file scope, and `Compress-Archive` and `Expand-Archive` are exported by the `Microsoft.PowerShell.Archive` module, which is auto-loaded when TARGET mocks `Expand-Archive`. DD1 does not address either. Because the nested harness sets `$global:LASTEXITCODE` to 0 in the control as well, the `$global:LASTEXITCODE` change of TARGET is not visible in the difference on this host.

Tooling corrections (mechanical, recorded before this run): under `pwsh -File` the script's own variables are global, so variables assigned after a snapshot are now declared before it (otherwise the restore removed them); an empty delta is wrapped with `@()` so `.Count` is defined under strict mode.

## Script output

```text
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
GLOBAL-STATE: TargetTotal=35 TargetFailed=0 ControlTotal=0
CONTROL-DELTA: 1
  C LASTEXITCODE after exists=True value=0
TARGET-DELTA: 5
  T ENV changed PATH
  T FUNCTION added Compress-Archive
  T FUNCTION added Expand-Archive
  T FUNCTION added Import-ScriptFunction
  T LASTEXITCODE after exists=True value=0
DIFFERENCE: 4
  D ENV changed PATH
  D FUNCTION added Compress-Archive
  D FUNCTION added Expand-Archive
  D FUNCTION added Import-ScriptFunction
EXIT_CODE=1
```
