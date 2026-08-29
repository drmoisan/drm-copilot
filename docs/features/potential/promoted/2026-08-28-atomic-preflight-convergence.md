# atomic-preflight-convergence (Issue #586)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/atomic-preflight-convergence/ (Issue #586)

- Issue: #586
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/586
- Last Updated: 2026-08-29
## Problem / Why

The atomic-planner / atomic-executor-preflight remediation loop is converging in far more rounds than it should: 9 rounds observed on one plan, 5 on another, in production orchestration sessions. Root cause: each preflight pass finds defects incrementally rather than exhaustively. A round fixes only the reported defect, and a new defect then surfaces in the same code region on the next round because a single thorough pass would have caught it the first time. Two recurring failure classes are observed:

1. A fix to one line invalidates an assumption on a sibling line or test that the preflight pass did not re-check in the same pass; it validated only the reported defect, not the neighborhood the fix touched.
2. A sanitization/policy-compliance fix's own descriptive text violates the same policy it is enforcing (a self-referential rule violation, for example a tonality-compliance fix whose delta prose itself breaks `.claude/rules/tonality.md`), and the plan's "comprehensive sweep" task class does not cover the plan/review documents produced during the same remediation cycle, only production/test code.

## Proposed Behavior

Revise two skill files that govern this loop, `.claude/skills/atomic-plan-contract/SKILL.md` and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, to close both failure classes and bound the round count:

1. Add a mandatory planner-side adversarial self-review section to `atomic-plan-contract/SKILL.md`, before its `## Preflight Validation (Planner ↔ Executor)` section: before any plan handoff (initial or a revision round), `atomic-planner` must re-derive, directly against current repository state, every fact/assumption/line-citation touched by its own edit in that pass, including sibling lines and tests in the same file/region, rather than trusting an earlier round's citation. The handoff must carry an explicit, checkable declaration that this pass occurred.
2. Extend `## Preflight Validation (Planner ↔ Executor)` in `atomic-plan-contract/SKILL.md`, and the corresponding `## Preflight Sub-Loop` in `remediation-handoff-atomic-planner/SKILL.md`, so `atomic-executor` in `DIRECTIVE: PREFLIGHT VALIDATION ONLY` mode reviews the entire plan in one pass rather than stopping at the first defect, enumerates every defect found in `PREFLIGHT: REVISIONS REQUIRED` output, and checks its own proposed fix/delta text against every rule the plan enforces, including the same violation class it is remediating.
3. Extend the remediation-cycle document set in `remediation-handoff-atomic-planner/SKILL.md` so the comprehensive/final sweep explicitly covers the plan and audit documents produced during the same remediation cycle (`remediation-plan.md`, `code-review.md`, `feature-audit.md`, `policy-audit.md`), not only production/test code.
4. State an explicit quality bar of <=2 preflight rounds per plan in `atomic-plan-contract/SKILL.md`, define orchestrator behavior in `remediation-handoff-atomic-planner/SKILL.md` for when `iterations` exceeds that bar, and require `atomic-executor` to state, on every preflight return, an explicit forward-looking assessment of whether further rounds are likely.

## Acceptance Criteria (early draft)

- [ ] `.claude/skills/atomic-plan-contract/SKILL.md` contains a new mandatory section, placed before `## Preflight Validation (Planner ↔ Executor)`, requiring `atomic-planner` to perform an adversarial self-review pass before every plan handoff: re-derive (not reuse from a prior round) any fact/assumption/line-citation touched by the planner's own edit in the current pass, explicitly re-check sibling lines/tests in the same file/region, and carry an explicit, checkable declaration in the handoff that the pass occurred.
- [ ] `.claude/skills/atomic-plan-contract/SKILL.md`'s `## Preflight Validation (Planner ↔ Executor)` section is extended so `atomic-executor` in `DIRECTIVE: PREFLIGHT VALIDATION ONLY` mode: reviews the entire plan in one pass and does not stop at the first defect; enumerates every defect found in `PREFLIGHT: REVISIONS REQUIRED` output; checks its own proposed fix/delta text against every rule the plan enforces, including the delta's own prose against the same violation class it is remediating; states a target of <=2 preflight rounds per plan; and returns an explicit, required line on every preflight signal stating whether further rounds are likely.
- [ ] `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`'s `## Preflight Sub-Loop` section reflects the extended preflight contract and defines orchestrator behavior when a cycle's `iterations` exceeds 2.
- [ ] `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`'s document-set section (`## Required Artifacts` or `## Plan Shape`) is extended so the comprehensive/final sweep explicitly covers the remediation cycle's own plan and audit documents (`remediation-plan.md`, `code-review.md`, `feature-audit.md`, `policy-audit.md`), not only production/test code.
- [ ] Both files remain internally consistent with their existing sections (no contradictions, correct cross-references) and comply with `.claude/rules/tonality.md`.

## Constraints & Risks

- Risk: Low. This is a documentation-only change to two Markdown skill-contract files; no application code, build, or runtime behavior is touched.
- Production file: .claude/skills/atomic-plan-contract/SKILL.md
- Production file: .claude/skills/remediation-handoff-atomic-planner/SKILL.md
- Additive only: no existing rule in either file may be weakened while these sections are added.
- New sections must follow the existing directive-line/signal conventions already used in both files (`DIRECTIVE: ...`, `PREFLIGHT: ALL CLEAR`, `PREFLIGHT: REVISIONS REQUIRED`) rather than introducing an unrelated format.
- `.claude/agents/atomic-executor.md` currently describes preflight as "format and structure validation only," which is in tension with the deeper adversarial/content review this change requires of the skill contract; a follow-up may be needed but is out of scope for this change unless required for internal consistency.

## Test Conditions to Consider

- [ ] Manual review: read both revised files end to end and confirm no contradiction with unchanged sections.
- [ ] Manual review: confirm all new/changed prose complies with `.claude/rules/tonality.md` (no hyperbole, no humor, evidence-first wording).
- [ ] Manual review: confirm cross-references between `atomic-plan-contract/SKILL.md` and `remediation-handoff-atomic-planner/SKILL.md` resolve correctly (heading names match what is referenced).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/atomic-preflight-convergence/` folder from the template

