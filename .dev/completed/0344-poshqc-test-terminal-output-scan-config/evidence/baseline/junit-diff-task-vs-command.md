# Baseline — Task-Path vs Command-Path JUnit Discovered-Set Diff (AC7)

- Timestamp: 2026-07-10T17-52
- Run A Command (task path): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root (Get-Location).Path }"` from repo root
- Run A EXIT_CODE: 0
- Run B Command (command path, in-repo bundled snapshot): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-10T16-55`
- Run B EXIT_CODE: 0

## Method

Both runs executed against the same worktree (branch HEAD). Each produced `artifacts/pester/pester-junit.xml`, copied to `junit-task.xml` (Run A) and `junit-command.xml` (Run B) in this folder. The `<testcase name="...">` sets were extracted and compared.

## Output Summary — Measured Delta

- Run A (task path): 1087 discovered test cases (1078 passed, 9 skipped, 0 failed).
- Run B (command path, bundled): 1087 discovered test cases (1078 passed, 9 skipped, 0 failed).
- Test cases only in task: 0
- Test cases only in command: 0
- **Discovered set delta: IDENTICAL** (1087 = 1087, zero-difference).

At the current worktree commit the bundled and workspace `Run.Path` lines are textually identical, and the bundled `CodeCoverage.ExcludedPath` key does not alter test discovery (only coverage scope; command-path coverage analyzed 16 files / 1565 commands vs task-path 26 files / 2563 commands — a coverage-scope difference, not a discovered-test-set difference). This confirms that at the same commit the two invocations discover the same Pester test set; the residual drift risk addressed by Phase 3 is the coverage `Path` list and the undocumented `ExcludedPath`/`RequiredModules` blocks, plus installed-extension snapshot lag (FR2.5).
