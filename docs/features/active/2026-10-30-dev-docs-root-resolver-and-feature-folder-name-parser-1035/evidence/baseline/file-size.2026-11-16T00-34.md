# P0-T1 File-Size Baseline

Timestamp: 2026-11-16T00-34
Command: poetry run python SCRATCH/issue-1035-filesize.py <plan> (backticked file tokens of the plan resolved against `git ls-files`, physical lines = newline count plus one for an unterminated last line); sh SCRATCH/issue-1035-npe-diff.sh (git diff --no-index of the two new-potential-entry.ps1 copies)
EXIT_CODE: 0
Output Summary: 368 plan-named tracked files resolved; 38 at or above 500 physical lines; none above 800; four at or above 700 (EpicCrossDependency.psm1 and its two copies at 769, test_atomic_executor_cli.py at 790). The two new-potential-entry.ps1 copies differ in exactly the three D-P3 regions; no further region.

## Files at or above 500 lines

| File | Lines | Tier |
| --- | --- | --- |
| .claude/hooks/enforce-completion-consistency.ps1 | 505 | >=500 guidance |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 699 | >=500 guidance |
| .claude/hooks/hook-docs-only-diff.ps1 | 508 | >=500 guidance |
| .claude/lib/epic-wave/EpicCrossDependency.psm1 | 769 | >=700 advisory |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 687 | >=500 guidance |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 507 | >=500 guidance |
| .codex/hooks/enforce-completion-consistency.ps1 | 500 | >=500 guidance |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 699 | >=500 guidance |
| .codex/hooks/hook-docs-only-diff.ps1 | 508 | >=500 guidance |
| extensions/drm-copilot/jest.config.cjs | 596 | >=500 guidance |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | 505 | >=500 guidance |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-review.ps1 | 699 | >=500 guidance |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 | 508 | >=500 guidance |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1 | 769 | >=700 advisory |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 687 | >=500 guidance |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 507 | >=500 guidance |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | 500 | >=500 guidance |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-review.ps1 | 699 | >=500 guidance |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 | 508 | >=500 guidance |
| extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1 | 769 | >=700 advisory |
| extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts | 520 | >=500 guidance |
| extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts | 500 | >=500 guidance |
| extensions/drm-copilot/test/repo-automation-dispatch.test.ts | 500 | >=500 guidance |
| scripts/dev-tools/ProcessReductionChain.psm1 | 596 | >=500 guidance |
| scripts/dev_tools/_epic_orchestrator_state_resolution.py | 562 | >=500 guidance |
| scripts/dev_tools/resolve_execute_plan_prompt.py | 586 | >=500 guidance |
| scripts/dev_tools/resolve_file_prompt.py | 619 | >=500 guidance |
| tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 536 | >=500 guidance |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 695 | >=500 guidance |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 593 | >=500 guidance |
| tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 | 544 | >=500 guidance |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 | 527 | >=500 guidance |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 517 | >=500 guidance |
| tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 507 | >=500 guidance |
| tests/scripts/dev_tools/test_atomic_executor_cli.py | 790 | >=700 advisory |
| tests/scripts/dev_tools/test_execution_environment_brief_contracts.py | 678 | >=500 guidance |
| tests/scripts/dev_tools/test_new_active_feature_folder.py | 533 | >=500 guidance |
| tests/scripts/dev_tools/test_resolve_file_prompt.py | 553 | >=500 guidance |

## new-potential-entry.ps1 copy regions (D-P3)

Copies: `scripts/dev-tools/new-potential-entry.ps1` (196 lines) and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` (187 lines); SHA-256 differ.

1. `Get-AuthorName`: only the `scripts/dev-tools` copy declares the `-GetCommand` parameter and guards the `git config` lookup behind it.
2. `$workspace` assignment: `Split-Path -Parent (Split-Path -Parent $PSScriptRoot)` in the `scripts/dev-tools` copy, `(Get-Location).Path` in the bundle copy.
3. Trailing blank line: the `scripts/dev-tools` copy ends with one extra blank line.

No further region. P5-T11 unifies these three.
