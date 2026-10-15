# P0-T9 Observation run of the remaining CRs

Timestamp: 2026-10-09T02-28
Command: Route C: CR-LINES, CR-HERMETIC, CR-MIRROR, CR-PHRASE, CR-CHANGED bodies via pwsh -NoProfile -File (scratchpad .ps1)
EXIT_CODE: 0
Output Summary:
--- CR-LINES ---
LINES: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 500
LINES: tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1 | 500
LINES: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | 498
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | 493
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | 492
LINES: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | 332
LINES: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | 490
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | 467
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 466
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 457
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | 450
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | 405
LINES: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | 396
LINES: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 374
LINES: tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 198
LINES: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 210
LINES-OVER-500: 0
EXIT_CODE_COMPUTED: 0
--- CR-HERMETIC ---
HERMETIC: tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | addedLines=0 | matches=0
HERMETIC-MATCH-COUNT: 0
EXIT_CODE_COMPUTED: 0
--- CR-MIRROR ---
MIRROR: tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | matches=0
MIRROR: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | matches=0
EXIT_CODE_COMPUTED: 0
--- CR-PHRASE ---
PHRASE: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | phrase=three library modules | matches=1
PHRASE: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | phrase=three library modules | matches=1
PHRASE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | phrase=two scan roots | matches=3
PHRASE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | phrase=two guarded roots | matches=1
PHRASE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | phrase=decision D9 | matches=1
PHRASE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | phrase=Non-vacuity floor | matches=1
EXIT_CODE_COMPUTED: 0
--- CR-CHANGED ---
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/epic-state-presence.2026-10-09T02-27.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/git-base.2026-10-09T02-23.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/pester-mock-semantics-probe.2026-10-09T02-27.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/phase0-instructions-read.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/phase0-requirements-read.2026-10-09T02-26.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/population-enumeration.2026-10-09T02-27.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/toolchain-versions.2026-10-09T02-27.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/upstream-verification.2026-10-09T02-26.md
CHANGED: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md
CHANGED-TOTAL: 9
UNTRACKED-TOTAL: 8
UNTRACKED-TESTS: 0
EXIT_CODE_COMPUTED: 0
