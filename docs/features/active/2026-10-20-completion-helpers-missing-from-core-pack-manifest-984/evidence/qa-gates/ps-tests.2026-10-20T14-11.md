# QA Gate: Coverage-Enabled Pester Run, Loop Pass 1 (Issue #984)

Timestamp: 2026-10-20T14-11
Command: sh SCRATCH/issue-984-run-hooks-cov.sh issue-984-p6t12 (Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks,tests/scripts/claude-runtime with coverage; parse of artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 1
Output Summary: loop pass 1 FAILED: 7693 test cases, 7692 passed, 1 failed. The failure is not in the [P0-T7] set, so the loop restarted at [P6-T1] after the fix below. This artifact records the failed pass; the pass-2 artifact supersedes it.

Failing test (full name): `discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1 complies with the baseline isolation form for every closure seam` in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`. Message: `seam Get-CheckpointFileContent: no dot-source loads the hook`.

Cause: the new CH suite dot-sourced the hook through a variable bound to a data key with a different name (`HookRelative`), so the epic-state isolation guard could not bind the dot-source to the hook literal, and the suite did not null-mock the hook's read seam `Get-CheckpointFileContent` in its outermost BeforeAll.

Fix: in `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1` the data key is renamed to `HookPath` (matching the dot-sourced variable) and `Mock Get-CheckpointFileContent { $null }` follows the dot-source in BeforeAll. The CH suite and the seven `enforce-gate-suites.EpicStateIsolation*` suites were re-run in one process (462 passed, 0 failed) before the loop restart.

Pass-1 per-hook line coverage (informational; superseded by pass 2): completion-consistency 95.33%, discovery gate 100%, Claude Python batch 93.53%, Claude PowerShell batch 93.53%, Codex Python batch 95.28%, Codex PowerShell batch 95.28%.
