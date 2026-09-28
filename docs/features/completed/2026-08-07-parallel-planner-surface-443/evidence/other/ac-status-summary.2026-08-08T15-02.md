# Acceptance-Criteria Status Summary — parallel-planner-surface (#443) ([P10-T11])

Timestamp: 2026-08-08T15-02

Work Mode: `full-feature`. Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, the
authoritative acceptance-criteria sources are
`docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md` and
`docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md`.

Item numbering below is document order within each file's `## Acceptance Criteria` section. Spec
items 20 through 22 were appended by [P9-T1] under the authority of spec R5's own contingency
text; items 1 through 19 are byte-identical to their pre-amendment text. Per-item evidence
reasoning is recorded in `evidence/other/ac-checkoff.2026-08-08T14-45.md`; evidence paths below
are relative to `docs/features/active/2026-08-07-parallel-planner-surface-443/`.

## `spec.md` — 22 criteria

| # | Criterion (abbreviated) | Status | Evidence path |
| --- | --- | --- | --- |
| 1 | Persona frontmatter, tool allowlist, `docs/features/parallel/**` scoping, no epic/active write scope | checked | `evidence/other/agent-persona-verification.2026-08-08T14-30.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| 2 | Exactly five preloaded skills; no `parallel-orchestrate` preload | checked | `evidence/other/agent-persona-verification.2026-08-08T14-30.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| 3 | `## Invocation Origin` documents the F7 `$script:GatedSubagentTypes` extension, documented-but-unenforced | checked | `evidence/other/agent-persona-verification.2026-08-08T14-30.md` |
| 4 | Skill frontmatter `context: fork`, `agent: parallel-planner`, argument hint | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| 5 | Kickoff-line verbatim markers; no `Epic mode: true` / `Parallel mode: true` inside the line | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 6 | `origin/main` branching; no change to `orchestrate/SKILL.md` or `config/orchestration-routing.json` | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/non-modification-orchestrate-route.2026-08-08T14-41.md` |
| 7 | R1 artifact-home decision with the three residual risks | checked | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 8 | F1 radius derivation and V1-V3 validation invoked via `Bash(poetry run *)`; no reimplementation | checked (clause "pending F1" superseded) | `evidence/other/skill-verification.2026-08-08T14-34.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; supersession authority `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` |
| 9 | V1/V2 Blocking and V3 Advisory semantics | checked | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 10 | One cohort-seeding invocation; the four recorded seed fields; `max_concurrency` recorded not enforced; recoloring out of scope | checked (clause "pending F2" superseded) | `evidence/other/skill-verification.2026-08-08T14-34.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; supersession authority `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` |
| 11 | Kickoff artifact per R5: heading, invocation prompt, six-column `## Item Summary`, optional `## Integrity`, both paths | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 12 | F3 boundary stated in the skill; kickoff-module disposition; single-item-run floor | checked (recommendation-and-contingency and flagged-for-F3 clauses superseded) | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `spec.md` section "Boundary Deviation Record — Kickoff Contract (R5 contingency fired)"; supersession authority `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` |
| 13 | Checkpoint contract per R6, `PARALLEL_EXECUTION_READY`, deliberate absences; manifest no `depends_on`, fully resolved | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 14 | Item intake per R8 | checked | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 15 | No worthiness gate, no dependency-graph authoring, no integration-branch creation | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 16 | Contract test exists, follows the precedent, carries the listed assertions, passes | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` (23 passed across the two modules) |
| 17 | No change to `atomic-plan-contract/SKILL.md`, `epic-planner.md`, `epic-plan/SKILL.md` | checked | `evidence/other/non-modification-atomic-plan-contract.2026-08-08T14-41.md`; `evidence/other/non-modification-epic-surfaces.2026-08-08T14-41.md` |
| 18 | Both Markdown deliverables under 500 lines | checked | `evidence/other/agent-persona-verification.2026-08-08T14-30.md` (149 lines); `evidence/other/skill-verification.2026-08-08T14-34.md` (420 lines) |
| 19 | F1/F2/F3 landing status re-verified and reconciled before execution | checked | `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` |
| 20 | `parallel_kickoff_contract.py` exists, validates the R5 shape, under 500 lines, tests pass | checked | `evidence/other/kickoff-module-size.2026-08-08T14-17.md`; `evidence/regression-testing/kickoff-contract-test-run.2026-08-08T14-20.md` |
| 21 | Five-surface additive wiring and the dispatched TypeScript parity core module | checked | `evidence/regression-testing/kickoff-wiring-test-run.2026-08-08T14-26.md`; `evidence/other/non-modification-f3-surfaces.2026-08-08T14-41.md` |
| 22 | Skill documents the cohort recomputation-parity obligation (F3 P5) and the F4-owned per-branch git-integrity verification | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |

## `user-story.md` — 8 criteria

| # | Criterion (abbreviated) | Status | Evidence path |
| --- | --- | --- | --- |
| 1 | Mixed issue-number / potential-entry intake in one command; unpromoted items promoted by their own child | checked | `evidence/other/skill-verification.2026-08-08T14-34.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| 2 | Procedure never asks for `depends_on`, waves, or a worthiness verdict | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 3 | Same preparation-mode child contract; prepared artifacts locatable on the item's own pushed branch | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 4 | V1/V2 failure visibly iterated, not dropped; V3 surfaced as Advisory | checked | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 5 | Completion report contents plus the execution-not-started statement | checked | `evidence/other/skill-verification.2026-08-08T14-34.md`; `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| 6 | Fresh-session start by discovering the kickoff on `parallel/<slug>-plan` without checkout | checked | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 7 | Only per-item branches plus one run branch; no integration branch; nothing pushed to `main` by the planner | checked | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md`; `evidence/other/skill-verification.2026-08-08T14-34.md` |
| 8 | Existing epic workflows unaffected | checked | `evidence/other/non-modification-epic-surfaces.2026-08-08T14-41.md`; `evidence/other/non-modification-orchestrate-route.2026-08-08T14-41.md`; `evidence/other/non-modification-atomic-plan-contract.2026-08-08T14-41.md` |

## Overall counts

| Source | Total | Checked | Unchecked |
| --- | --- | --- | --- |
| `spec.md` | 22 | 22 | 0 |
| `user-story.md` | 8 | 8 | 0 |
| **Combined** | **30** | **30** | **0** |

The recorded counts sum to 30 status lines, one per criterion. No criterion remains unchecked, so
no unchecked-item reason is recorded. Three spec criteria (8, 10, 12) carry supersession notes
rather than text edits; the notes and their authority are recorded in
`evidence/other/ac-checkoff.2026-08-08T14-45.md` and in the `spec.md` section "Boundary Deviation
Record — Kickoff Contract (R5 contingency fired)", subsection "Superseded assumption-labelled
clauses".
