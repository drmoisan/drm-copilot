# P0-T11 Scoped Coverage Baseline (R-COV over HRS)

Timestamp: 2026-09-27T03-28
Command: sh <SCRATCHPAD>/x713-cov-p0.sh (R-COV over the 18 HRS files; coverage paths are the two canonical helpers copies)
EXIT_CODE: 0
Output Summary: 727 passed, 0 failed, 0 failed blocks, 0 failed containers. Line coverage of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` is 97.08% (166 covered, 5 missed); `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` is 97.08% (166 covered, 5 missed). B_SCOPED is empty.

PassedCount: 727
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0

FAILED lines: none

LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=166 missed=5 percent=97.08
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=166 missed=5 percent=97.08
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481

No `CHANGED_LINE:` line was printed, because the five section-3 changed-line literals do not exist before the edit.

## HRS file list used (18 files; the ChainEscape suite is included because SIBLING_710_PRESENT is True and the file exists)

1. tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
2. tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
3. tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
4. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
5. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
6. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
7. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
8. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
9. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
10. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
11. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
12. tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
13. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
14. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
15. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
16. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
17. tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
18. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1

## B_SCOPED

none
