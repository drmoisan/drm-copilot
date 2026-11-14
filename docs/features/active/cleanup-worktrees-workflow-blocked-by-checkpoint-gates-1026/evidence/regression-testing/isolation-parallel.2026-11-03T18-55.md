# Concurrent-Shard Pester and pytest -n auto Isolation Runs (Issue #1026, P9-T7)

Timestamp: 2026-11-03T18-55
Command: sh SCRATCH/issue-1026-parallel.sh (fresh PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>, scan set from config/poshqc-scan.json)
EXIT_CODE: 1
Output Summary: concurrent-shard Pester run, 8 workers, wall-clock 386.7s: shard 1 exit 0, shards 2 to 8 non-zero; 89 failures in total, every one in 17 suites under tests/scripts/dev-tools and tests/scripts/powershell/PoshQC that this branch does not change. The same 17 suites run single-process give identical results at MERGE_BASE (the main checkout) and on the branch: 308 tests, 219 passed, 89 failed, with the same per-suite distribution. The causes depend on the host: Windows `C:` drive fixtures, backslash path expectations, writes to `/repo`, and Windows prompt strings on this Linux Codespace host. All 415 suites under tests/scripts/claude-hooks, codex-hooks, claude-runtime, and claude-lib are reported across the shards with zero failures. The pytest -n auto run of the eight P8-T9 contract modules: 16/16 workers, 176 passed, 0 failed. The acceptance condition "zero failures in both runs" is NOT met by the Pester run, so P9-T7 stays unchecked.

Host: GitHub Codespace, Linux, 16 cores, PowerShell 7.6, Pester 5.9.1. This differs from the plan-time host. CI runs the PowerShell shards on `windows-latest` (`poshqc / PowerShell QC shard 1` to `3`), and only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on `ubuntu-latest` (`poshqc / PowerShell hook suites (Linux)`).

## Run 1: concurrent-shard Pester (Invoke-PoshQCParallelTest)

Command: sh SCRATCH/issue-1026-parallel.sh
EXIT_CODE: 1 (merge refused: "Shards 2, 3, 4, 5, 6, 7, 8 exited non-zero; see their logs. No merged artifact was written.")

| Shard | Exit | Tests | Failures | Failing suites |
|---|---|---|---|---|
| 1 | 0 | 439 | 0 | none |
| 2 | 8 | 1478 | 8 | new-potential-entry.TemplateRoot (2), Test-DiscoveryHostCapability.Entry (4), PoshQC.ScanConfig (1), PoshQC.TestingCommands (1) |
| 3 | 18 | 2438 | 18 | Enter-DrmCopilotShell (4), HostBootstrap (1), SideloadedExtensionPublish.Invoke (12), Test-DiscoveryHostCapability (1) |
| 4 | 1 | 1612 | 1 | PoshQC.ScanFolders (1) |
| 5 | 255 | 2058 | 13 | activate (13); Pester's JUnit export then failed partway, so shard 5's JUnit file is truncated and counts come from its console summary (Tests Passed: 2045, Failed: 13) |
| 6 | 16 | 2120 | 16 | publish-sideloaded-extension (16) |
| 7 | 18 | 2124 | 18 | HostBootstrap.Invoke (16), HostTooling (1), post-codex-worktree-session (1) |
| 8 | 15 | 1632 | 15 | HostBootstrapWorkspace (8), SideloadedExtensionPublish (4), sync-agents-from-instructions (3) |

Total failures: 89. Representative messages: `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.`; `Expected: 'C:\fixture\ws'`; `UnauthorizedAccessException: Access to the path '/repo' is denied.`; `A parameter cannot be found that matches parameter name 'Raw'.`

Touched-area check: across the eight shard JUnit files, 415 testsuite elements under tests/scripts/claude-hooks, codex-hooks, claude-runtime, and claude-lib are reported, including shard 5's truncated file (1 + 53 + 60 + 56 + 64 + 63 + 58 + 60). Each reports `errors="0" failures="0"`. No failure occurred in any suite that this branch adds or changes.

## Run 2: pre-existing check of the failing suites (single process, both trees)

Command: sh SCRATCH/issue-1026-hostfail.sh (Invoke-Pester over the 17 failing suites, coverage disabled, run once in the main checkout at MERGE_BASE and once in the item worktree)
EXIT_CODE: 0 (both processes completed; the result counts follow)

| Tree | Files | Tests | Passed | Failed |
|---|---|---|---|---|
| main checkout at MERGE_BASE | 17 | 308 | 219 | 89 |
| item worktree (branch) | 17 | 308 | 219 | 89 |

The per-suite failure counts are identical in both trees and equal the shard totals above. The main checkout's `git status --porcelain` was empty before and after the run.

## Run 3: pytest -n auto of the P8-T9 contract tests

Command: SKIP_GEN=1 sh SCRATCH/issue-1026-contract.sh -n auto -v (poetry run pytest -p no:cacheprovider -q --no-cov -n auto -v over the eight P8-T9 contract modules; addopts carry --strict-markers and --strict-config)
EXIT_CODE: 0
Result: `created: 16/16 workers`; 176 passed, 0 failed. The serial run under the same strict options is recorded in qa-gates/contract-tests.2026-11-03T18-39.md (176 passed).

## Disposition

The Pester leg fails the task acceptance on this host only because of pre-existing Windows-host fixtures outside the branch diff. Fixing them is an outcome independent of this plan and is not performed here. P9-T7 is left unchecked and is reported to the orchestrator as a deviation. A clean concurrent-shard result needs a Windows host, or a CI run of `poshqc / PowerShell QC`, whose shard jobs run on `windows-latest`.
