# Remediation Baseline — Pester with Coverage (Fresh Single Process)

Timestamp: 2026-11-03T19-56
Command: sh SCRATCH/issue-1026-fullrun.sh baseline (fresh single-process PowerShell 7 on the Linux Codespace: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <item worktree> -ScanFolders tests/scripts), run against the unmodified CYCLE_BASE tree
EXIT_CODE: 255

## Counts

- `artifacts/pester/pester-junit.xml` `testsuites` element: tests=13901, failures=409, errors=6, disabled=10.
- Pester console: Tests Passed: 13482, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0; Tests completed in 1038.07s; Covered 91.97% of 35,537 analyzed commands in 265 files.
- Exit code 255: after the run, Pester's JUnit export threw (`Export-XmlReport`: `WriteAttributeString` rejected a failure message that carries a character XML cannot hold), so `pester-junit.xml` is truncated after the `activate.Tests.ps1` suite. The header counts above were written before the exception. Per-suite failure attribution below is therefore taken from the console stack traces (`SCRATCH/issue-1026-consolefail.ps1`), each failure attributed to the `.Tests.ps1` path in its own trace.

## Failing suites

Inside `HOST_FAILURE_SUITES` (89 failure lines): activate 13, Enter-DrmCopilotShell 4, HostBootstrap.Invoke 16, HostBootstrap 1, HostBootstrapWorkspace 8, HostTooling 1, new-potential-entry.TemplateRoot 2, post-codex-worktree-session 1, publish-sideloaded-extension 16, SideloadedExtensionPublish.Invoke 12, SideloadedExtensionPublish 4, sync-agents-from-instructions 3, Test-DiscoveryHostCapability.Entry 4, Test-DiscoveryHostCapability 1, PoshQC.ScanConfig 1, PoshQC.ScanFolders 1, PoshQC.TestingCommands 1.

Outside `HOST_FAILURE_SUITES` (8 suites; six are container failures that fail every test in the container, which accounts for the difference between 97 failure lines and 409 failed tests):

- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` (container: `pwsh` not recognized)
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (container: `pwsh` not recognized)
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (container: `pwsh` not recognized)
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (container: `pwsh` not recognized)
- `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` (container: `pwsh` not recognized)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (container failure)
- `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` (1: child hook exit 2)
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` (1: no Python interpreter resolved)

Cause (pre-existing, not part of this diff): `tests/scripts/dev-tools/run-actionlint.Tests.ps1`, test `Add-DirectoryToPath handles paths with trailing separator`, assigns `$env:PATH = '/existing'` outside the `Add-DirectoryToPath` context whose `AfterEach` restores PATH, so the process PATH stays at `/existing/new/` after that suite. Every later suite that starts `pwsh` or resolves Python in the same process fails. The earlier single-process runs on this branch (baseline 2026-11-03T13-17, final 2026-11-03T14-32) ran on a different host and recorded 0 failures; the 89-failure set of `isolation-parallel.2026-11-03T18-55.md` came from per-shard processes on this host, where the leaker and these victims do not share a process.

Victim confirmation: `sh SCRATCH/issue-1026-suites.sh victims issue-1026-victims.txt` ran the 8 suites above together in one fresh PowerShell 7 process (Invoke-Pester, without `run-actionlint.Tests.ps1`) on the same tree: 356 tests, 356 passed, 0 failed, 0 failed containers, exit 0.

## Line coverage (artifacts/pester/powershell-coverage.xml)

- Total: 92.57% (21514 covered, 1727 missed).

| File | Line coverage |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.27% (155/161) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 95.32% (163/171) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 97.89% (139/142) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 90.14% (128/142) |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 98.08% (51/52) |

Output Summary: 13901 tests; 13482 passed, 409 failed, 10 skipped; total line coverage 92.57%; the five changed files are at 96.27%, 95.32%, 97.89%, 90.14%, and 98.08%. Acceptance NOT MET: every count and percentage is numeric, but 8 failing suites are outside HOST_FAILURE_SUITES. All 8 are victims of the pre-existing PATH leak in run-actionlint.Tests.ps1 on this Linux host. The task stays unchecked and the deviation is escalated at completion.
