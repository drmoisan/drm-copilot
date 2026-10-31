# Preflight Fixes (Stage B, Round 3, final permitted round)

Timestamp: 2026-10-31T16-12
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md

Scope: single-pass review of the whole plan (69 tasks before and after; no task added, removed or reordered). Trivial defects are fixed in place in task text only.

## Round 2 Defect Verification

1. [P2-T4] moves-then-rewrites second apply call: resolved. [P2-T4] is now the owner decision H2 gate. It detects `BRANCH-OQ-12` = `moves-then-rewrites` after the move commit of [P2-T3], issues no second `TOOL` call, writes `commit-split-halt.<timestamp>.md` with the handoff values, emits the fixed re-approval message and stops with `BLOCKED: owner-answer-commit-split-halt`. [P1-T1], the Terms (`APPLY_COMMIT`), the Commit and Check-off Protocol item 3, the Pre-Mortem Evidence bullet, the Size Justification and Open Questions are consistent with it. No stale reference to a removed task ([P2-T6], [P2-T7]) or to `SCRATCH/apply-2/` as a write target remains. This matches spec `## Owner Decisions (preparation)` H2.
2. [P1-T3] and [P1-T4] excluded-file mirror class: resolved. Class `X` is defined in [P1-T3] with `exclude` under both OQ-3 branches, a mixed-module rule and a stop condition for a compared production result that resolves the configured root. `FOLDER_GLOB` (`tests/scripts/dev_tools/test_blast_radius_write_intent.py`, against the frozen `tests/fixtures/blast_radius/write-intent/*.json` read by `load_fixture`) and `PROMOTED_RECORD_FRAGMENT` (`tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, `test_rule_doc_states_origin_conditional_potential_record`, against `.claude/rules/orchestrator-state.md`) are named explicitly, and [P1-T4] includes every class `X` row. Both anchors were re-checked in the tree. Observation, not a defect: `FEATURE_FOLDER_ROOT` in `scripts/dev_tools/compute_blast_radius.py` hard-codes `docs/features/active` today, and child 2's plan task [P9-T3] routes it through the resolver. Either state is caught by [P1-T3] (class `H`, or the class `X` configured-root stop), and Open Questions records the possible stop.
3. [P7-T1] mapping records: resolved. The derived exclusion list adds `NEW_FEATURE/evidence/other/checkpoint-path-handoff.*.md` and `NEW_FEATURE/evidence/other/checkpoint-path-update.*.md` under every `BRANCH-OQ-2` value, and the acceptance requires both globs to be recorded. [P2-T5], [P3-T1] and the Evidence Path Schedule state the same.

## Fixes

1. [P8-T15] | stale diff anchor (validator-blind; meaning kept) | The self-review walked `git diff BASE HEAD`. Run 2 contains no commit task, so the Phase 4 to 7 edits are uncommitted when [P8-T15] runs and `git diff BASE HEAD` would omit them. The task now walks `git diff BASE` (merge base against the working tree) together with the untracked files listed by `git status --porcelain`. The asserted outcome (one PASS, FAIL or N/A row per checklist item, no FAIL row) is unchanged.

## Language Classification Check

Every planned artifact in the plan's Language Classification table was compared against the owner language rule. No new Python, PowerShell hook or bash script is planned; the Python edits (`init_models.py`, `build_discovery_runtime.py`, `build_identity.py`, `json_config.py`) are in-place edits of existing files; the PowerShell edits are existing modules and hooks; TypeScript edits are limited to child 2's existing resolver constant. No artifact is misclassified.

## Validation

- MCP validator (`validate_orchestration_artifacts`, `artifact_type: plan`): passed before and after the fix.
- Branch-current validator (`poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`): passed before and after the fix.

Final signal: PREFLIGHT: ALL CLEAR
