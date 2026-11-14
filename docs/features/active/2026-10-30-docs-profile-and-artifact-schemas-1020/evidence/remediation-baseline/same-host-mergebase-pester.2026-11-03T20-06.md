# Same-Host Merge-Base Pester Reference (supports [P6-T6])

Timestamp: 2026-11-03T20-06
Command: git clone --shared --no-checkout <item worktree> SCRATCH/issue-1020-mergebase; git -C SCRATCH/issue-1020-mergebase checkout MERGE_BASE; sh SCRATCH/issue-1020-ps.sh issue-1020-subset.ps1 -Root SCRATCH/issue-1020-mergebase -ListFile SCRATCH/issue-1020-dirlist.txt (Run.Path tests/scripts, one process, PassThru, no coverage); then the same script with Run.Path tests/scripts/dev-tools followed by tests/scripts/codex-scripts (SCRATCH/issue-1020-order-probe.txt)
EXIT_CODE: 0
Output Summary: MERGE_BASE (01706c697f3ad4a53b4a771d99d851afc7417ea9, this branch's merge base with origin/main) on the current host (Linux Codespace, PowerShell 7, Pester 5.9.1): tests=13723 passed=13464 failed=249 skipped=10 (186 unique failing test names). The order probe (dev-tools before codex-scripts) gives failed=246 of 887, including all 160 cases of `Codex routing PowerShell wrappers match the Python CLI corpus (issue #697)`. The current host is not the host that recorded the [P0-T6] baseline, which reported 0 failures for the same 13723 tests.

## Why a same-host reference was needed

The [P0-T6] baseline (`evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md`) was captured before the item moved to the current Codespace host (commit `Merge origin/main before resuming orchestration in the Codespace`). On the current host, the unchanged merge-base tree already fails 249 tests in one process. The failures are host-dependent: `DriveNotFoundException` for `C:` roots, `UnauthorizedAccessException` for `/repo`, and `CommandNotFoundException` for `pwsh` in suites that run after `tests/scripts/dev-tools`.

## Order dependence (pre-existing, not introduced by this branch)

- Pester enumerates `tests/scripts` in file-system directory order. In the item worktree, `dev-tools` is enumerated before `codex-scripts` and `codex-hooks`. In the fresh merge-base clone, `codex-scripts` is enumerated before `dev-tools`.
- With `dev-tools` first, `Get-Command pwsh -CommandType Application` in the `BeforeAll` of `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` fails, and all 160 parity cases fail. The merge-base tree reproduces these 160 failures when the run order is the item worktree's order (order probe above).
- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` passes alone (160 of 160) and after all twelve `tests/scripts/claude-lib/docs/` suites (543 of 543). In the item worktree's order the docs suites run after `codex-scripts`, so they cannot affect it.
- Every file this branch adds or edits is outside `tests/scripts/dev-tools`, `tests/scripts/codex-scripts`, and `tests/scripts/codex-hooks`.

This order dependence and the Linux-only failures are pre-existing defects outside this feature's file set and are reported to the orchestrator for a separate issue.
