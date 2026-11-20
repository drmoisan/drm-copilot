# Post-Change — Task-Path vs Command-Path JUnit Discovered-Set Comparison (AC2 closure)

- Timestamp: 2026-07-10T19-35
- Run A Command (task path): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path }"` from repo root
- Run A EXIT_CODE: 0
- Run B Command (command path, in-repo bundled snapshot): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-10T16-55`
- Run B EXIT_CODE: 31

## Method

Both runs executed against the same worktree (post-change branch HEAD, after the Capability 2
resync and the Capability 3 scan-config precedence change). Each produced
`artifacts/pester/pester-junit.xml`, copied to `junit-task-post.xml` (Run A) and
`junit-command-post.xml` (Run B) in this folder. The `<testcase>` `classname :: name` sets were
extracted from both files and compared with `Compare-Object`.

## Output Summary — Discovered-Set Comparison

- Run A (task path): 1103 discovered test cases; 0 failed.
- Run B (command path, bundled): 1103 discovered test cases; 31 failed.
- Test cases only in task: 0
- Test cases only in command: 0
- **Discovered set delta: IDENTICAL** (1103 = 1103, zero-difference).

AC2 acceptance is discovered-test-set parity between the command's "Scan entire workspace" path
and the local task `PoshQC: 4 test (Pester)`. That parity holds exactly: both invocations
discover the identical 1103 Pester test cases at the same commit. The discovered-set count rose
from the 1087 recorded in the baseline (`evidence/baseline/junit-diff-task-vs-command.md`) because
Capability 3 added the new `PoshQC.ScanConfig.Tests.ps1` suite and extended the scan-folder
precedence suite. The bundled `PoshQC.psd1` and `settings/*.psd1` are byte-identical to the
workspace copies (no `RequiredModules`, no `CodeCoverage.ExcludedPath`, current coverage `Path`
list), verified by the extended parity gate (`evidence/qa-gates/final-py-parity.md`).

## Command-Path Pass/Fail Delta (behavioral note, outside AC2 discovery-parity scope)

Run B reports 31 failures with the message `RuntimeException: Mock data are not setup for this
scope, what happened?`. All 31 belong exclusively to PoshQC's own self-mocking test files
(`PoshQC.Comprehensive.Tests.ps1` (26), `PoshQC.EntryPoints.Tests.ps1` (1),
`PoshQC.ScanFolders.Tests.ps1` (4)). The task path (Run A) passes all of these.

Cause: the bundled command wrapper (`run-poshqc-test.ps1`) `Import-Module`s the bundled `PoshQC`
module by name to invoke `Invoke-PoshQCTest`, leaving a resident module named `PoshQC` in the
session. Pester then discovers PoshQC's own test files, which `Import-Module` the workspace
`PoshQC` and register `Mock -ModuleName PoshQC`; the two same-named module instances collide and
Pester's per-scope mock bookkeeping fails. The task path never pre-imports the module, so no
resident instance exists to collide.

This pass/fail delta is a direct and expected consequence of FR2.2: the bundled `RequiredModules`
block was removed to make the bundled manifest byte-identical to the workspace manifest, whose
empty-`RequiredModules` bootstrap contract is asserted by
`tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:31-36`. Diagnostic verification:
restoring `RequiredModules = @(PSScriptAnalyzer, Pester)` to the bundled manifest changes the
module-import ordering enough to mask the collision (Run B then reports 0 failures), but doing so
violates FR2.2/AC2's byte-identical parity requirement and was reverted.

Scope of impact:
- The authoritative PowerShell test gate is the local task / workspace module path (FR2.4), which
  passes 0 failures.
- Production consumer repositories that install the extension do not contain PoshQC's own test
  files, so the self-collision cannot occur there.
- The collision is exclusive to running the bundled command wrapper against this PoshQC
  development repository, which contains both the module and its self-mocking tests.

This behavioral note is recorded for transparency; it does not alter the AC2 discovery-parity
result above.
