# P14-T13 Mirror, pack and publication contract suites

Timestamp: 2026-10-29T12-49
Task: [P14-T13] Re-run repository and publication contracts under the tiered file-size policy, discharging [P13-T6].
Command: poetry run pytest tests/scripts/dev_tools tests/schemas -q -p no:cacheprovider --no-cov; sh SCRATCH/issue-980-pester.sh tests/scripts/claude-lib/codex-routing tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 tests/scripts/claude-runtime/claude-settings.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1
EXIT_CODE: 0 (pytest), 0 (Pester)
Output Summary: The complete `tests/scripts/dev_tools` and `tests/schemas` contract population passes: `9547 passed, 6 skipped in 62.54s` (P13-T6: 9541 passed, 6 skipped), including the push-down resource, pack-manifest, dependency-closure, issue-824 consuming-name, brief and documentation contracts. The routing and runtime-contract Pester suites plus the bundle hook probe and the file-size repository gate pass: `RESULT total=1053 passed=1053 failed=0 skipped=0`. The six execution-environment brief copies share one SHA-256 (`82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76`; one distinct value over six files).
Run window 2026-10-29T12-46 to 12-49 UTC on the final tree (`git status --porcelain` empty at start and end).
Result: PASS
