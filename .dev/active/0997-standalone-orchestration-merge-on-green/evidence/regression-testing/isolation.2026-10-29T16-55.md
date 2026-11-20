# Isolation Runs (issue #997)

Timestamp: 2026-10-29T16-55
Command: sh SCRATCH/issue-997-isolation.sh (for each seed, one PowerShell 7 process shuffles the seven touched Pester suites with System.Random(seed) and runs Invoke-Pester over them in that order); poetry run python SCRATCH/issue_997_reverse.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py (one process, collected order reversed)
EXIT_CODE: 0
Output Summary: three seeded shuffled Pester runs, 172 passed and 0 failed each; reversed Python run, 36 passed and 0 failed. No order dependence observed.

Seed 11 (passed=172 failed=0):
1. enforce-epic-merge-gate.GreenCiDecision.Tests.ps1
2. enforce-epic-merge-gate.MergeQueue.Tests.ps1
3. enforce-epic-merge-gate.Authorization.Tests.ps1
4. enforce-epic-merge-gate.GreenCiRegression.Tests.ps1
5. enforce-epic-merge-gate.GreenCi.Tests.ps1
6. enforce-epic-merge-gate.DocsOnly.Tests.ps1
7. hook-dependency-failure.SpecialCases.Tests.ps1

Seed 23 (passed=172 failed=0):
1. enforce-epic-merge-gate.DocsOnly.Tests.ps1
2. hook-dependency-failure.SpecialCases.Tests.ps1
3. enforce-epic-merge-gate.GreenCiDecision.Tests.ps1
4. enforce-epic-merge-gate.Authorization.Tests.ps1
5. enforce-epic-merge-gate.MergeQueue.Tests.ps1
6. enforce-epic-merge-gate.GreenCi.Tests.ps1
7. enforce-epic-merge-gate.GreenCiRegression.Tests.ps1

Seed 47 (passed=172 failed=0):
1. enforce-epic-merge-gate.GreenCi.Tests.ps1
2. enforce-epic-merge-gate.Authorization.Tests.ps1
3. hook-dependency-failure.SpecialCases.Tests.ps1
4. enforce-epic-merge-gate.GreenCiDecision.Tests.ps1
5. enforce-epic-merge-gate.GreenCiRegression.Tests.ps1
6. enforce-epic-merge-gate.MergeQueue.Tests.ps1
7. enforce-epic-merge-gate.DocsOnly.Tests.ps1

All suites are under `tests/scripts/claude-hooks/`.

Reversed Python run: 36 passed, 0 failed; first collected node after reversal `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-...]`, last `test_agent_frontmatter_declares_parallel_orchestrator_identity`.

The fresh single-process run over `tests/scripts` is recorded in `qa-gates/pester-full.2026-10-29T16-54.md` (12198 tests, 0 failures).
