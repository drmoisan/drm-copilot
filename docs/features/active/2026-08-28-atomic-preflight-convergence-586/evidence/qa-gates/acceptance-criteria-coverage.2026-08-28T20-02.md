# QA Gate — Acceptance-Criteria Coverage Mapping (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T8]
AC source (work mode `minor-audit`): the `## Acceptance Criteria` section of `docs/features/active/2026-08-28-atomic-preflight-convergence-586/issue.md` only
Criteria count: 5

## Mapping Table

Five rows, one per acceptance criterion, in issue-file order.

### Row 1

- **Criterion text:** `.claude/skills/atomic-plan-contract/SKILL.md` contains a new mandatory section, placed before `## Preflight Validation (Planner ↔ Executor)`, requiring `atomic-planner` to perform an adversarial self-review pass before every plan handoff: re-derive (not reuse from a prior round) any fact/assumption/line-citation touched by the planner's own edit in the current pass, explicitly re-check sibling lines/tests in the same file/region, and carry an explicit, checkable declaration in the handoff that the pass occurred.
- **Implementing tasks:** [P1-T1], [P1-T2], [P1-T3], [P1-T4]
- **Evidence artifacts:**
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-atomic-plan-contract.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/heading-inventory-end-state.2026-08-28T20-02.md`
- **Verification:** The [P2-T3] artifact records the post-change heading list showing `## Expect-Fail Test Tasks` (138), `## Planner Adversarial Self-Review (Mandatory)` (142), and `## Preflight Validation (Planner ↔ Executor)` (156) consecutively in that order, so the new section is placed before the named section. The same artifact records the mechanical derivation placing `**Re-derive every citation in this pass.**` (148), `**Re-check the sibling region.**` (149), and `SELF-REVIEW: RE-DERIVED THIS PASS` (153) under that new section. The [P2-T7] artifact records the heading count rising from 17 to 18, which is the one added section.
- **Status:** Verified. Checkbox changed to `- [x]`.

### Row 2

- **Criterion text:** `.claude/skills/atomic-plan-contract/SKILL.md`'s `## Preflight Validation (Planner ↔ Executor)` section is extended so `atomic-executor` in `DIRECTIVE: PREFLIGHT VALIDATION ONLY` mode: reviews the entire plan in one pass and does not stop at the first defect; enumerates every defect found in `PREFLIGHT: REVISIONS REQUIRED` output; checks its own proposed fix/delta text against every rule the plan enforces, including the delta's own prose against the same violation class it is remediating; states a target of <=2 preflight rounds per plan; and returns an explicit, required line on every preflight signal stating whether further rounds are likely.
- **Implementing tasks:** [P1-T5], [P1-T6], [P1-T7], [P1-T8], [P1-T9]
- **Evidence artifacts:**
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-atomic-plan-contract.2026-08-28T20-02.md`
- **Verification:** The [P2-T3] artifact records the mechanical derivation placing all five literals under `## Preflight Validation (Planner ↔ Executor)` (156): `**Review the entire plan in one pass.**` (168), `**Enumerate every defect found.**` (169), `**Check the delta against its own rule.**` (170), `**Two-round target.**` (171), and `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` (175). The same artifact's verdict for heading 13 records that the added convergence paragraph is reconciled with the pre-existing exact-signal bullet.
- **Status:** Verified. Checkbox changed to `- [x]`.

### Row 3

- **Criterion text:** `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`'s `## Preflight Sub-Loop` section reflects the extended preflight contract and defines orchestrator behavior when a cycle's `iterations` exceeds 2.
- **Implementing tasks:** [P1-T10], [P1-T11], [P1-T12]
- **Evidence artifacts:**
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-remediation-handoff.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/cross-reference-resolution.2026-08-28T20-02.md`
- **Verification:** The [P2-T4] artifact records all three literals resolving to `## Preflight Sub-Loop` (100): the cross-file reference at 109, `CONVERGENCE:` at 111, and `blocked_preflight_iteration_limit` at 113. The [P2-T6] artifact records that the cross-file reference to the extended preflight contract resolves in both directions. The iteration-ceiling paragraph at line 113 names `iterations` exceeding 2 as the trigger and states the record, halt, and escalate behavior.
- **Status:** Verified. Checkbox changed to `- [x]`.

### Row 4

- **Criterion text:** `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`'s document-set section (`## Required Artifacts` or `## Plan Shape`) is extended so the comprehensive/final sweep explicitly covers the remediation cycle's own plan and audit documents (`remediation-plan.md`, `code-review.md`, `feature-audit.md`, `policy-audit.md`), not only production/test code.
- **Implementing tasks:** [P1-T13]
- **Evidence artifacts:**
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-remediation-handoff.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/heading-inventory-end-state.2026-08-28T20-02.md`
- **Verification:** The [P1-T13] acceptance was verified mechanically at execution time: `### Cycle-Document Sweep Scope` sits at line 84, `## Required Artifacts` at line 65, and the next `## ` entry is `## Plan Shape` at line 88, so the subsection lies inside the document-set section. The subsection names all four documents. The [P2-T4] artifact's verdict for heading 5 records that the subsection does not conflict with the "exactly five artifacts" rule. The [P2-T7] artifact records the `^## ` count unchanged at 10, confirming the addition is a `### ` subsection.
- **Status:** Verified. Checkbox changed to `- [x]`.

### Row 5

- **Criterion text:** Both files remain internally consistent with their existing sections (no contradictions, correct cross-references) and comply with `.claude/rules/tonality.md`.
- **Implementing tasks:** [P1-T1] through [P1-T13], verified by [P2-T3], [P2-T4], [P2-T5], [P2-T6]
- **Evidence artifacts:**
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-atomic-plan-contract.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/consistency-review-remediation-handoff.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/tonality-review.2026-08-28T20-02.md`
  - `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/qa-gates/cross-reference-resolution.2026-08-28T20-02.md`
- **Verification:** The [P2-T3] artifact records `Contradictions Found: 0` over 18 per-heading verdicts. The [P2-T4] artifact records `Contradictions Found: 0` over 10 per-heading verdicts. The [P2-T5] artifact records `Tonality Violations: 0` over all 38 added lines with a per-category verdict for each of the four tone categories. The [P2-T6] artifact records both sides of the one cross-file reference pair resolving, with the falsifiable side confirmed to exit 1 at baseline.
- **Status:** Verified. Checkbox changed to `- [x]`.

## Checkboxes Changed in `issue.md`

All five checkboxes in the `## Acceptance Criteria` section of `docs/features/active/2026-08-28-atomic-preflight-convergence-586/issue.md` were changed from `- [ ]` to `- [x]`. Criterion text was not modified in any of the five; only the leading marker changed.

| # | issue.md line | Marker before | Marker after |
| --- | --- | --- | --- |
| 1 | 30 | `- [ ]` | `- [x]` |
| 2 | 31 | `- [ ]` | `- [x]` |
| 3 | 32 | `- [ ]` | `- [x]` |
| 4 | 33 | `- [ ]` | `- [x]` |
| 5 | 34 | `- [ ]` | `- [x]` |

Outstanding criteria: none. No criterion's evidence was absent, so no criterion was left unchecked.

The three `## Test Conditions to Consider` checkboxes at lines 49 through 51 of the same file were not modified. Under the `minor-audit` mode rule in `acceptance-criteria-tracking`, only the explicit `## Acceptance Criteria` section is the AC source, and other checkbox sections are not treated as acceptance criteria.

## Verdict

Five rows recorded, each naming criterion text, at least one plan task ID, and at least one evidence artifact path under the feature evidence tree. Five checkboxes changed. Gate passes.
