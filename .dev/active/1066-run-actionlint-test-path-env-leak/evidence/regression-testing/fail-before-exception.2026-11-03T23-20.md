# Fail-Before Exception (P0-T6)

Timestamp: 2026-11-03T23-20
Command: pwsh -NoProfile -File SCRATCH/issue-1066-junit-sets.ps1 -First RAW/baseline-forward.xml -Second RAW/baseline-excluded.xml -Root <worktree root>
EXIT_CODE: 0
Output Summary:
- V (A minus B minus A_T over DEVLIST) is empty: A and B both hold the same 94 failing keys and A_T is empty.

WhyFailingRunImpossible: The plan derives the PATH-induced victim set from single-process runs of the 37 suites directly under tests/scripts/dev-tools. None of the suites that follow run-actionlint.Tests.ps1 in that list fails differently when PATH is left as '/new/:/existing', so the plan's reproduction scope contains no victim and the victim-set comparison cannot show a failing run.

## Alternative Proof

- The leak is present in the source: the Edge cases test "Add-DirectoryToPath handles paths with trailing separator" in tests/scripts/dev-tools/run-actionlint.Tests.ps1 assigns $env:PATH = '/existing' and no BeforeEach/AfterEach in its Context restores it.
- A diagnostic single-process run of TARGET followed by eight suites outside dev-tools produced 105 failing keys that do not fail when the same eight suites run without TARGET (claude-hooks/enforce-parallel-drift-gate-helpers, codex-hooks/codex-bundle-hook-probe, codex-detached-head-transport, codex-pretooluse-integration, codex-pretooluse-transport, epic-execution-gates, legacy-codex-hook-contracts, codex-scripts/Resolve-CodexRouting.Parity). Details: evidence/baseline/victim-set.2026-11-03T23-20.md.
- The guard-level fail-before (P1-T2) and the global-state fail-before (P0-T10) do not depend on V and remain available after a plan revision.
