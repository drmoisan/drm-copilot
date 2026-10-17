# R1 CR-N3 Fail-Before Run (P3-T2, expect-fail)

Timestamp: 2026-10-16T05-56
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks"]), with the P3-T1 rows applied and `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` unchanged since commit `e2aca1a95`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Call disposition: raised. Error text: `Command exited with code 3.`
- Expected failures: row (a) `CR-N3 does not report the separate-token value of <Parameter>` (both cases) and row (b) `CR-N3 binds Join-Path positionals after the separate-token value of -Credential`. Row (c) is a guard row and is expected to pass.
- Supplementary file observation (not an MCP result string): the JUnit file `artifacts/pester/pester-junit.xml` written by this run (last write 2026-10-16 01:56 -0400) records `tests="4646" failures="3" errors="0"`, with these CR-N3 testcases:
  - `CR-N3 does not report the separate-token value of Import-Module -Prefix`: Failed
  - `CR-N3 does not report the separate-token value of process-start -WorkingDirectory`: Failed
  - `CR-N3 binds Join-Path positionals after the separate-token value of -Credential`: Failed
  - `CR-N3 still reports a positional load after the switch Import-Module -Force`: Passed
  - `CR-N3 still reports a positional load after the switch process-start -NoNewWindow`: Passed
  The three failures are the only failures in the run.

## Code path

The only change since the green P2-T5 run (`r1-p2-ps-test.2026-10-16T05-46.md`, committed in `e2aca1a95`) is the P3-T1 edit to `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` (`git diff --name-only HEAD` lists only that test file and the remediation plan).

Helper line numbers derived at task time on `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`:

- `grep -n -F -e '$loads.Add($element); continue'` printed one line: `352:            if ($element -isnot [System.Management.Automation.Language.CommandParameterAst]) { $loads.Add($element); continue }` (inside `Get-EpicStateIsolationHookReference`, declared at line 329).
- `grep -n -F -e '$pathParameter -notcontains $element.ParameterName'` printed one line: `353:            if ($pathParameter -notcontains $element.ParameterName) { continue }` (inside `Get-EpicStateIsolationHookReference`).
- `grep -n -F -e "AdditionalChildPath') -notcontains"` printed one line: `139:        if (@('Path', 'ChildPath', 'AdditionalChildPath') -notcontains $element.ParameterName) { continue }` (inside `Get-EpicStateIsolationJoinPathPart`, declared at line 128; next function at line 151).

Row (a): in `Get-EpicStateIsolationHookReference`, line 353 skips `-Prefix` (Import-Module) or `-WorkingDirectory` (process start) alone because neither is a recognised load parameter; the next loop pass reaches line 352, which adds the separate-token value (`$Prefix`, bound to `Join-Path $HookRoot 'gate.ps1'`, or `(Join-Path $HookRoot 'gate.ps1')`) as a load, so one RootVariable record is reported where the row expects zero.

Row (b): in `Get-EpicStateIsolationJoinPathPart`, line 139 skips `-Credential` alone; the next loop pass adds `$FixtureCredential` to the positionals, so it binds as `Path`, `$HookRoot` as `ChildPath` and `'gate.ps1'` as `AdditionalChildPath`. With a non-empty `AdditionalChildPath` and no `hooks` segment, no record is produced where the row expects one.
