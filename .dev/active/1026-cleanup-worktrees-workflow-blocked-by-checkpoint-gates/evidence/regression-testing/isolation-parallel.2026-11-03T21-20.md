# Isolation — Concurrent-Shard Pester and pytest -n auto (Remediation Cycle 1)

Timestamp: 2026-11-03T21-20
Command: sh SCRATCH/issue-1026-parallel.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>; per-shard counts read from artifacts/pester/parallel/shard-<n>/pester-junit.xml; then poetry run pytest -q --no-cov -n auto over the ten P0-T6 contract modules)
EXIT_CODE: 0

## Concurrent-shard Pester (8 shards, 13910 tests)

| Shard | Tests | Failures | Errors | Failing suites (failures) |
|---|---|---|---|---|
| shard-1 | 439 | 0 | 0 | none |
| shard-2 | 1478 | 8 | 0 | new-potential-entry.TemplateRoot (2), Test-DiscoveryHostCapability.Entry (4), PoshQC.ScanConfig (1), PoshQC.TestingCommands (1) |
| shard-3 | 2440 | 18 | 0 | Enter-DrmCopilotShell (4), HostBootstrap (1), SideloadedExtensionPublish.Invoke (12), Test-DiscoveryHostCapability (1) |
| shard-4 | 1612 | 1 | 0 | PoshQC.ScanFolders (1) |
| shard-5 | 2062 | 13 | 0 | activate (13) |
| shard-6 | 2120 | 16 | 0 | publish-sideloaded-extension (16) |
| shard-7 | 2124 | 18 | 0 | HostBootstrap.Invoke (16), HostTooling (1), post-codex-worktree-session (1) |
| shard-8 | 1635 | 15 | 0 | HostBootstrapWorkspace (8), SideloadedExtensionPublish (4), sync-agents-from-instructions (3) |

- Total failures: 89, all in the 17 `HOST_FAILURE_SUITES` (every one under `tests/scripts/dev-tools/` or `tests/scripts/powershell/PoshQC/`); 89 is at most 89.
- Failures under `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`, and `tests/scripts/claude-lib`: 0.
- The 8 PATH-leak victim suites of the single-process run pass here, because in this shard layout `run-actionlint.Tests.ps1` does not share a process with them.

## pytest -n auto

- 220 passed, 0 failed (exit 0).

Output Summary: concurrent-shard Pester ran 13910 tests with 89 failures, all inside HOST_FAILURE_SUITES and none in the hook, runtime, or lib suites; pytest -n auto had 220 passed and 0 failed. Acceptance met.
