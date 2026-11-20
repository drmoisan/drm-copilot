# P13-T6 Mirror, pack-manifest, routing, documentation and publication contract suites

Timestamp: 2026-10-29T02-34
Task: [P13-T6] Repeat repository and publication contracts on the final tree.
Command: `poetry run pytest tests/scripts/dev_tools tests/schemas -q -p no:cacheprovider --no-cov`; `sh SCRATCH/issue-980-pester.sh tests/scripts/claude-lib/codex-routing tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 tests/scripts/claude-runtime/claude-settings.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`
EXIT_CODE: 0 (Python), 0 (Pester)
Output Summary: Python: "9541 passed, 6 skipped" (the six pre-existing skips; P11-T8 recorded 9523 passed). This population carries every execution-environment contract suite:
- the two resource-contract suites, the two pack-manifest completeness suites and the pack-manifest dependency closure;
- the Codex wrapper and handoff parity suites, the rules frontmatter suite and the frozen surface hashes;
- the workflow contracts, the issue #824 neutrality suite and the TypeScript toolchain instruction contracts;
- the Set L routing suites, `test_discovery_publication_contracts.py`, and `test_discovery_documentation_contracts.py` (every documentation page and relative link resolves, and the CLI reference covers every console script, MCP tool and command, including the P12-T13 host options);
- the schema catalog suites under `tests/schemas`, including the P12-T5 `start-attestation` schema.

Pester: "RESULT total=1024 passed=1024 failed=0 skipped=0" over:
- the codex-routing parity suites and `Resolve-CodexRouting.Parity.Tests.ps1`;
- the architecture-document and hook-dependency-guard completeness suites;
- the no-Python-invocation hook contract and the role registration suites;
- the Codex bundle hook probe.
Result: PASS
