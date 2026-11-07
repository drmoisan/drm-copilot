# 0008: G13 guideline cutoff

## Summary

reduction: 0008
Date: 2026-11-07
Issue: #1097
Merge commit: pending (PR #1097)

Lowers the G13 size guideline from 40 canonical tasks and 400 physical lines to 20 tasks and 250 lines in both plan validators, the rule file, the planning contract, and the planner agents. A plan file stamped before `PLAN_GUIDELINE_CUTOFF` keeps 40 and 400, and a plan validated without a path uses the new pair. The finding message states the pair that applied. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation.

Cutoff: `PLAN_GUIDELINE_CUTOFF` (America/New_York `2026-11-07T18-31`, UTC `2026-11-07T23-31`), one instant written in both zones; a `plan.<stamp>.md` stamp is compared with the America/New_York entry, and a `plan.remediation-cycle-<N>.<stamp>.md`, `remediation-plan.<stamp>.md`, or `remediation/<stamp>/remediation-plan.md` stamp with the UTC entry.

## Reason and Evidence

Research section 2 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` measured the 31 plans in `docs/features/active/` written after G13 shipped: tasks had a minimum of 15, a median of 41, and a maximum of 171; 16 plans were above 40 tasks, all with `## Size Justification`; 30 of 31 were above 20 tasks; physical lines had a median of 148 and a maximum of 1150, and 1, 3, and 6 plans were above 400, 250, and 200 lines. At 400 the line guideline bound on 1 of 31 plans and allowed 20 lines per task over 20 tasks. 250 leaves room for 20 tasks at the observed rate of up to about 6 lines per task plus a fixed preamble and Pre-Mortem. The research recommended lowering the line guideline to 250 with the task guideline at 20, and a cutoff by plan-file stamp so that older plans need no edit, which matters because parallel runs verify `plan-hash`.

Decision D2 of the feature specification, as corrected in this stage, fixes the cutoff as one instant: the UTC clock reading taken once in the run that makes this reduction commit, whose author and committer dates equal it. `PLAN_GUIDELINE_CUTOFF` stores that reading as an America/New_York stamp and a UTC stamp, because `plan.<stamp>.md` is stamped in America/New_York by the feature-folder tooling and remediation plans carry UTC review stamps. A day-boundary cutoff, or one New York stamp compared with UTC review stamps, would change the result of plans written before the rule existed. Clarification K4 fixes the four stamp shapes and the folder form; K5 passes the plan path to G13 by its own parameter, so a plan with absent repository wiring keeps its stamp result. Under D9 the installed MCP validator applies 40 and 400 until a release carrying this change is installed, so the planner holds a new plan to 20 and 250 itself and preflight applies the new pair through the Python CLI.

Result check: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/other/stage-f-g13-result-check.*.md` records, for every plan file under `docs/features/active/` and every Epic #1019 plan and remediation plan on every remote ref, that its G13 outcome under the new rule equals its outcome under the legacy pair. The time saved per item is unknown until stage timing has data.

## Files Changed

- `scripts/dev_tools/plan_gate_document.py`: canonical
- `scripts/dev_tools/plan_gate_discrimination.py`: canonical
- `scripts/dev_tools/validate_orchestration_artifacts.py`: canonical
- `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`: canonical
- `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`: canonical
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`: canonical
- `tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py`: created contract test
- `tests/scripts/dev_tools/test_plan_gate_document_parity.py`: contract test
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`: contract test
- `tests/scripts/dev_tools/test_plan_gate_document_docs.py`: contract test
- `extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts`: created contract test
- `extensions/drm-copilot/test/lib/validate/plan-gate-document-parity.test.ts`: contract test
- `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`: contract test
- `.claude/rules/plan-acceptance-gates.md`: canonical
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`: byte-identical bundle copy
- `.claude/skills/atomic-plan-contract/SKILL.md`: canonical
- `.agents/skills/atomic-plan-contract/SKILL.md`: canonical
- `.github/skills/atomic-plan-contract/SKILL.md`: canonical
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`: byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`: byte-identical bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`: byte-identical bundle copy
- `.claude/agents/atomic-planner.md`: canonical
- `.github/agents/atomic_planning.agent.md`: canonical
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`: byte-identical bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`: byte-identical bundle copy
- `docs/engineering/process-reductions/0008-g13-guideline-cutoff.md`: this entry
- `docs/engineering/process-reductions/README.md`: index row

## Stored Patch

`patches/0008-g13-guideline-cutoff.patch` holds the reduction as one diff. It was generated as `git diff --cached --binary --no-renames HEAD` over the paths of `## Files Changed` other than the ledger folder, after the final cutoff pair was written, in the run that made the commit whose subject carries `reduction: 0008`. Its hunks therefore hold the final pair, and its two create hunks hold the two new test files. A later fix commit with `reduction: 0008` in its subject regenerated the patch to add the removal of the unreachable blocking arm of the G5 channel choice in `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`; the regeneration diffed the same path set from the parent of the reduction commit against the fixed tree, so the patch still reverts the whole reduction in one apply.

The check of README `## Revert Order`: `0008` is the highest number, so it is reverted first, against the live tree, and its `git apply -R --check` runs there. It changes text in recorded regions of two older entries: the `**Size guideline.**` bullet of the six contract copies is a context line of hunks in `patches/0001-parallel-only-test-gates.patch`, and the planner clause of `.claude/agents/atomic-planner.md` and its bundle is a context line of hunks in both `patches/0001-parallel-only-test-gates.patch` and `patches/0006-test-suite-baseline-restored.patch`. No `Current` fence of `0001` to `0007` holds either line. Those hunks need no regeneration, because reverting `0008` first restores both lines byte-for-byte before the `0006` and `0001` turns.

## Revert Steps

1. Apply the blocks: run `git apply -R` of `patches/0008-g13-guideline-cutoff.patch`, which restores every changed path and deletes `tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py` and `extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts`; then remove the `0008` row from `README.md` and delete this entry. Revert this entry before `0006` and `0001`: the `**Size guideline.**` bullet is a context line of the `0001` hunks on the six contract copies, and the planner clause is a context line of the `0001` and `0006` hunks on `.claude/agents/atomic-planner.md` and its bundle. Reverting `0008` first restores both lines byte-for-byte, so those hunks apply again unchanged; regenerating them to carry `0008` text would make them fail once `0008` is reverted.
2. Re-copy mirrors and bundles: copy `.claude/rules/plan-acceptance-gates.md`, the three `atomic-plan-contract` sources, `.claude/agents/atomic-planner.md`, and `.github/agents/atomic_planning.agent.md` to their six bundle paths under `extensions/drm-copilot/resources/`.
3. Regenerate Codex variants: not applicable, because no Codex base or variant states the guideline; still run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check`.
4. Restore pinned hashes: not applicable, because no `PINNED_FROZEN_SURFACE_HASHES` entry covers these files.
5. Restore contract-test literals: the patch restores `_RULE_TOKENS` and removes `test_cutoff_value_is_identical_in_rule_file_and_both_validators` in `test_plan_gate_document_docs.py`, restores the `g13` rows of `test_plan_gate_document_parity.py` and `plan-gate-document-parity.test.ts`, restores `test_plan_branch_builds_context_and_calls_two_channel_entry_point`, and removes the `PCW-SIZE-GUIDELINE-<Copy>` and `PCW-SIZE-AGENT-<Id>` row groups from `planning-contract-wording.Tests.ps1`.
6. Run the contract tests: run `test_plan_gate_document.py`, `test_plan_gate_document_parity.py`, `test_plan_gate_document_docs.py`, `test_validate_orchestration_artifacts_plan_gates.py`, `plan-gate-document.test.ts`, `plan-gate-document-parity.test.ts`, `planning-contract-wording.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_resource_contracts.py`, inside the one `Invoke-PoshQCParallelTest` run, the one `pytest -n auto` run, and the Jest run; the deleted suites `test_plan_gate_guideline_cutoff.py` and `plan-gate-guideline-cutoff.test.ts` no longer run.

## Revert Signals

- The share of new plans carrying `## Size Justification` stays high, so the section becomes routine rather than an exception.
- Plans merge steps into long tasks to stay within 20 tasks.
- Preflight finds more defects per plan after the change.
- After the release is installed, plans that pass the MCP self-check fail G13 at preflight.
