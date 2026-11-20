# P16-T8 Mirror, pack and publication contract suites

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: poetry run pytest tests/scripts/dev_tools tests/schemas -q -p no:cacheprovider --no-cov; sh SCRATCH/issue-980-pester.sh tests/scripts/claude-lib/codex-routing tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 tests/scripts/claude-runtime/claude-settings.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1
EXIT_CODE: 0 (pytest), 0 (Pester)
Output Summary: The complete `tests/scripts/dev_tools` and `tests/schemas` contract population passes: `9581 passed, 6 skipped in 39.13s` (P14-T13: 9547 passed, 6 skipped), including the push-down resource, pack-manifest, dependency-closure, publication (with the three new shared helpers, P15-T22), brief and documentation contracts (P15-T23). The routing and runtime-contract Pester suites plus the bundle hook probe and the file-size repository gate pass: `RESULT total=1053 passed=1053 failed=0 skipped=0`. The six execution-environment brief copies share one SHA-256 (`372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072`, the P15-T21 wording; one distinct value over six files).
Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
