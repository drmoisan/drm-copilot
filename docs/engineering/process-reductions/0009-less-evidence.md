# 0009: Less evidence and the CI cross-check

## Summary

reduction: 0009
Date: 2026-11-08
Issue: #1097
Merge commit: pending (PR #1131)

Reduces review evidence in three places. The format, lint, and type-check results of one language are recorded in one final-QC static artifact per language instead of one artifact per step, and reviewers read that artifact instead of re-running those checks; each test gate keeps its own artifact. The reviewer records the CI result of `Enforce Python coverage thresholds` for the Python repo-wide total instead of computing it; the PowerShell and TypeScript repo-wide review rows stay. The policy-audit `Code Under Test` list and the section 9 commit and file lists are replaced by the merge base and the reviewed head, whose branch log and diff carry the same information; the heading `## 9. Summary of Changes` stays. In exchange the reviewer writes `## CI Cross-check` into the policy audit, and under `review_mode: "concurrent"` the orchestrator compares each row with CI at the join and turns a mismatch into a synthetic `autonomous` finding that the merge guard denies with `REVIEW_GATE_NOT_PASSED`. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation. After a session crash, the reduction's edits first landed in the crash checkpoint commit `c58c16243`. That partial landing was withdrawn by reversing this entry's stored patch, and the whole reduction then landed with this entry in the one commit whose subject carries `reduction: 0009`; the stored patch is generated from the reduction's pre-image, so it is the same either way.

## Reason and Evidence

Research section 4 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` listed evidence that CI already proves on the pull-request head. Clarification K9 of the feature specification re-derives those dispositions against the tree after stages C to R. The final-QC test-gate artifacts are kept, because under decisions D12 and D13 they are the post-change side of the `Phase 0 baseline` comparison. The format, lint, and type-check artifacts are kept as one artifact per language, because the QA-gate skills compare static results with the static baseline. Only the Python repo-wide total is read from CI, because `_quality-checks.yml` enforces only that total (`Enforce Python coverage thresholds`), while `pester.runsettings.psd1` sets `CoveragePercentTarget = 0` and `jest.config.cjs` holds per-file thresholds only. Decision D5 and clarification K7 fix the CI cross-check as the control that replaces the re-run checks.

Decision D13 forbids reducing any baseline task, baseline evidence, or baseline comparison. `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/baseline/stage-g-baseline-text.*.md` records, before the edits, every line of the changed surfaces that matches `baseline|regression|pre-change|Phase 0`, and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/other/stage-g-baseline-text-check.*.md` records that each such line is unchanged after them. `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` pins the kept baseline, comparison, and check-off text (`LEC-BASELINE-HELD-*`, `LEC-KEPT-*`).

Installed assets (decision D9): installed MCP keeps serving the old policy-audit template through `resolve_policy_audit_template_asset`, without `## CI Cross-check` and with the old section 9 lists, until an extension release that carries the new bundle is installed. Until then the reviewer adds the section and writes the reduced section 9 because `feature-review-workflow` says so. The time saved per item is unknown until stage timing has data.

## Files Changed

- `.claude/skills/atomic-plan-contract/SKILL.md`: source
- `.agents/skills/atomic-plan-contract/SKILL.md`: source
- `.github/skills/atomic-plan-contract/SKILL.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`: byte-identical mirror of `.claude/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`: byte-identical mirror of `.agents/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`: byte-identical mirror of `.github/skills/atomic-plan-contract/SKILL.md`
- `.claude/skills/feature-review-workflow/SKILL.md`: source
- `.agents/skills/feature-review-workflow/SKILL.md`: source
- `.github/skills/feature-review-workflow/SKILL.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`: byte-identical mirror of `.claude/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`: byte-identical mirror of `.agents/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`: byte-identical mirror of `.github/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`: source
- `.agents/skills/orchestrate/SKILL.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`: byte-identical mirror of `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`: byte-identical mirror of `.agents/skills/orchestrate/SKILL.md`
- `.claude/agents/atomic-planner.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`: byte-identical mirror of `.claude/agents/atomic-planner.md`
- `.codex/agents/atomic-planner.toml`: source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`: byte-identical mirror of `.codex/agents/atomic-planner.toml`
- `.claude/agents/atomic-executor.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`: byte-identical mirror of `.claude/agents/atomic-executor.md`
- `.codex/agents/atomic-executor.toml`: source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`: byte-identical mirror of `.codex/agents/atomic-executor.toml`
- `.claude/agents/feature-review.md`: source
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`: byte-identical mirror of `.claude/agents/feature-review.md`
- `.codex/agents/feature-review.toml`: source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`: byte-identical mirror of `.codex/agents/feature-review.toml`
- `.codex/agents/atomic-planner-c1.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml`: generated Codex variant
- `.codex/agents/atomic-planner-c2.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml`: generated Codex variant
- `.codex/agents/atomic-planner-c3.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml`: generated Codex variant
- `.codex/agents/atomic-planner-c3-elevated.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml`: generated Codex variant
- `.codex/agents/atomic-planner-c4.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml`: generated Codex variant
- `.codex/agents/atomic-executor-c1.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml`: generated Codex variant
- `.codex/agents/atomic-executor-c2.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml`: generated Codex variant
- `.codex/agents/atomic-executor-c3.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml`: generated Codex variant
- `.codex/agents/atomic-executor-c3-elevated.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml`: generated Codex variant
- `.codex/agents/atomic-executor-c4.toml`: generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml`: generated Codex variant
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: source
- `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: byte-identical mirror of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
- `docs/features/templates/policy_audit/AGENTS.md`: source
- `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`: byte-identical mirror of `docs/features/templates/policy_audit/AGENTS.md`
- `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`: created contract test
- `docs/engineering/process-reductions/patches/0009-less-evidence.patch`: stored patch
- `docs/engineering/process-reductions/0009-less-evidence.md`: this entry
- `docs/engineering/process-reductions/README.md`: index row

## Stored Patch

`patches/0009-less-evidence.patch` holds the reduction as one diff. It is generated as `git diff --cached --binary --no-renames HEAD` over the paths of `## Files Changed` other than the ledger folder, in the run that makes the commit whose subject carries `reduction: 0009`, after the ledger check and the chain replays with this entry report no error. Its create hunk holds `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`, so the chain compares the live file with it. The byte-identical bundle copies and the generated Codex variants are in the patch, and the chain skips them as derived paths.

The check of README `## Revert Order`: `0009` is the highest number, so it is reverted first, against the live tree, and its `git apply -R --check` runs there. Its edits sit beside or inside recorded regions of older entries: hunks of `patches/0001-parallel-only-test-gates.patch` and `patches/0006-test-suite-baseline-restored.patch` on the `atomic-plan-contract` copies, the planner and executor agents, the feature-review surfaces, and the policy-audit template; the hunks of `patches/0008-g13-guideline-cutoff.patch` on the contract copies and the Claude planner; the `0002` block of the concurrent-review section of the two orchestrate skills; and the regions of `0003`, `0004`, and `0005` on the same files. Those older hunks and blocks are not regenerated: reverting `0009` first restores each edited region byte-for-byte before the older turns, so their context matches again, while regenerating them to carry `0009` text would make them fail once `0009` is reverted. The README rule on an edit inside a recorded region applies to an edit with no entry of its own, not to a newer entry that records the edit.

## Revert Steps

1. Apply the blocks: run `git apply -R` of `patches/0009-less-evidence.patch`, which restores every changed path and deletes `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`; then remove the `0009` row from `README.md` and delete this entry. Revert this entry before `0008`, `0006`, `0005`, `0004`, `0003`, `0002`, and `0001`: their hunks and blocks on the changed files hold context that this entry edits, and reverting `0009` first restores that context byte-for-byte, so they apply again unchanged. The control cases `ci-cross-check-synthetic-after-pass` in `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1` and `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-VALID` and `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-BLOCKS-COMPLETION` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1` are not in the patch and stay, because they test the merge guard and the checkpoint validators, which this entry does not change.
2. Re-copy mirrors and bundles: copy the three `atomic-plan-contract` sources, the three `feature-review-workflow` sources, the two `orchestrate` sources, `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, and `docs/features/templates/policy_audit/AGENTS.md` to their bundle paths under `extensions/drm-copilot/resources/`, as listed in `## Files Changed`.
3. Regenerate Codex variants: run `scripts/dev_tools/generate_codex_agent_variants.py` in module form, which regenerates the five variants of `.codex/agents/atomic-planner.toml` and of `.codex/agents/atomic-executor.toml`, the two base bundles, and the variant bundles; then run it with `--check`.
4. Restore pinned hashes: not applicable, because no `PINNED_FROZEN_SURFACE_HASHES` entry covers these files.
5. Restore contract-test literals: the patch deletes `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`, the only suite that pins this entry's text; no other contract test changes.
6. Run the contract tests: run `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `concurrent-review-skill-contract.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1`, `enforce-epic-merge-gate.ReviewGuard.Tests.ps1`, `OrchestratorStateConcurrentReview.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, the Codex suite `enforce-epic-merge-gate-review.Tests.ps1`, `test_validate_policy_audit_artifact.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_agent_wrapper_contracts.py`, inside the one `Invoke-PoshQCParallelTest` run and the one `pytest -n auto` run; the deleted suite `less-evidence-contract.Tests.ps1` no longer runs.

## Revert Signals

- CI cross-check mismatches appear per item, showing that local evidence and CI disagree more often than the reduction assumed.
- Review findings cite missing or wrong static evidence, so a reviewer had to re-run a format, lint, or type check.
- Python repo-wide total failures are first seen in CI rather than in the review.
