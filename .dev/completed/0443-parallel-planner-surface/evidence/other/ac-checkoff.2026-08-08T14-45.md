# Acceptance-Criteria Check-Off Traceability — Phase 9 ([P9-T2] through [P9-T5])

Timestamp: 2026-08-08T14-45

Protocol: `.claude/skills/acceptance-criteria-tracking/SKILL.md`. Work Mode is
`full-feature`, so the authoritative acceptance-criteria sources are
`docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md` (22 items after the
[P9-T1] amendment) and
`docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md` (8 items).

Check-off is evidence-gated and per item. A prior delegation checked 13 spec items and 7
user-story items during Phases 4 and 5; this record reconciles those check-offs against the
evidence now on disk and completes the remainder. Every previously-checked item was re-verified
against its named artifact; none required correction.

Evidence paths below are relative to
`docs/features/active/2026-08-07-parallel-planner-surface-443/`.

## Evidence artifacts referenced

| Short name | Path |
| --- | --- |
| agent-persona | `evidence/other/agent-persona-verification.2026-08-08T14-30.md` |
| skill-verification | `evidence/other/skill-verification.2026-08-08T14-34.md` |
| contract-test | `evidence/regression-testing/contract-test-run.2026-08-08T14-39.md` |
| kickoff-module-size | `evidence/other/kickoff-module-size.2026-08-08T14-17.md` |
| kickoff-contract-test | `evidence/regression-testing/kickoff-contract-test-run.2026-08-08T14-20.md` |
| kickoff-wiring-test | `evidence/regression-testing/kickoff-wiring-test-run.2026-08-08T14-26.md` |
| mirror-gate | `evidence/regression-testing/mirror-gate-run.2026-08-08T14-40.md` |
| upstream-reconciliation | `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` |
| non-mod-apc | `evidence/other/non-modification-atomic-plan-contract.2026-08-08T14-41.md` |
| non-mod-epic | `evidence/other/non-modification-epic-surfaces.2026-08-08T14-41.md` |
| non-mod-route | `evidence/other/non-modification-orchestrate-route.2026-08-08T14-41.md` |
| non-mod-f3 | `evidence/other/non-modification-f3-surfaces.2026-08-08T14-41.md` |

## `spec.md` — items 1 through 3 ([P9-T2], agent persona)

| # | Criterion (abbreviated) | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Persona frontmatter, tool allowlist, `docs/features/parallel/**` scoping, no epic/active write scope | checked | agent-persona (149 lines; checks 1-2 PASS; `Bash(poetry run *)` present); contract-test (`test_agent_frontmatter_declares_required_tool_allowlist`, `test_agent_frontmatter_declares_no_epic_docs_scope`) |
| 2 | Exactly five preloaded skills, no `parallel-orchestrate` | checked | agent-persona (`parallel-orchestrate` 0 matches); contract-test (`test_agent_frontmatter_declares_name_and_preloaded_skills`) |
| 3 | `## Invocation Origin` documents the F7 `$script:GatedSubagentTypes` extension, documented-but-unenforced | checked | agent-persona (`GatedSubagentTypes` 1 match, PASS) |

## `spec.md` — items 4 through 15 ([P9-T3], skill)

| # | Criterion (abbreviated) | Status | Evidence |
| --- | --- | --- | --- |
| 4 | Skill frontmatter `context: fork`, `agent: parallel-planner`, argument hint | checked | contract-test (`test_skill_frontmatter_routes_to_the_parallel_planner_agent`) |
| 5 | Kickoff-line markers; no `Epic mode: true` / `Parallel mode: true` in the line | checked | contract-test (`test_skill_carries_the_preparation_mode_kickoff_markers`, `test_preparation_kickoff_line_carries_neither_mode_marker`); skill-verification checks 8-9 (kickoff line is line 72; markers appear only at lines 91-92 in the omission statement) |
| 6 | `origin/main` branching; no change to `orchestrate/SKILL.md` or `config/orchestration-routing.json` | checked | contract-test (`test_skill_branches_preparation_worktrees_from_origin_main`); non-mod-route (VERDICT PASS — constraint 7) |
| 7 | R1 artifact home with the three residual risks | checked | skill-verification (`## Artifact Home` present; integration-branch check 4 PASS with both negations audited) |
| 8 | F1 radius derivation and V1-V3 validation invoked via `Bash(poetry run *)`; no reimplementation | checked (clause superseded) | skill-verification (checks 5 and 7 PASS: no `conflicts(a, b)`, no `python -m`; `conflicts(a, b, config)` 2 matches); contract-test landed module (`test_skill_uses_import_only_upstream_invocation`, `test_skill_cites_three_argument_contention_signature`, `test_skill_cites_derivation_over_document_text`) |
| 9 | V1/V2 Blocking and V3 Advisory semantics | checked | skill-verification (`## Radius Computation and Validation` present) |
| 10 | One cohort-seeding invocation; `generation: 0`, `conflict_edges[]`, `recolor_generation: 0`, `current_cohort: 0`; `max_concurrency` recorded not enforced; recoloring F6/F8 | checked (clause superseded) | skill-verification (check 6 PASS: no pinned-set reference; `compute_cohorts(item_keys, conflict_edges)` 1 match); contract-test landed module (`test_skill_cites_two_parameter_cohort_seeding_signature`) |
| 11 | Kickoff artifact per R5: heading, invocation prompt, six-column `## Item Summary`, optional `## Integrity`, both paths | checked | contract-test (`test_skill_names_both_kickoff_artifact_paths`); skill-verification (`## Kickoff Artifact` section with the fenced template headings) |
| 12 | F3 boundary stated in the skill; kickoff-module disposition; single-item-run floor | checked (clauses superseded) | contract-test landed module (`test_skill_claims_the_kickoff_contract_as_delivered_by_this_feature`, `test_skill_attributes_git_integrity_verification_to_f4`, `test_skill_cites_planner_invariant_p5_as_the_parity_basis`); `spec.md` section "Boundary Deviation Record — Kickoff Contract (R5 contingency fired)" |
| 13 | Checkpoint contract per R6, `PARALLEL_EXECUTION_READY`, deliberate absences; manifest no `depends_on`, fully resolved | checked | contract-test (`test_skill_names_the_planner_checkpoint_and_manifest_paths`); skill-verification (check 2 PASS with both `depends_on` matches audited as prohibitions) |
| 14 | Item intake per R8 | checked | skill-verification (`## Item Intake` section present among the fourteen `##` headings) |
| 15 | No worthiness gate, no dependency-graph authoring, no integration-branch creation | checked | contract-test (`test_skill_contains_no_worthiness_gate`, `test_skill_contains_no_dependency_authoring_instruction`, `test_skill_contains_no_integration_branch_creation_instruction`); skill-verification checks 1-4 PASS |

### Supersession notes ([P9-T3] acceptance)

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md` rule 3, criterion text was NOT edited.
The supersessions are recorded here and in the `spec.md` section "Boundary Deviation Record —
Kickoff Contract (R5 contingency fired)", subsection "Superseded assumption-labelled clauses".
The authority for each supersession is upstream-reconciliation, which found F1 (with the F1a
correction), F2, and F3 all implementation-landed.

- **Item 8** — the clause "labelled as an upstream contract (§5.1-§5.4) pending F1" is superseded.
  F1 has landed as an import-only library with no CLI entry point, so the skill documents the
  landed calling convention instead of a pending-assumption label. The criterion's substantive
  requirements (invocation through `Bash(poetry run *)`, no reimplementation of derivation, V1-V3,
  or the contention relation) are delivered and asserted by the Phase 6 tests named above.
- **Item 10** — the clause "labelled as an upstream contract (§6) pending F2" is superseded. F2 has
  landed with the two-parameter signature `compute_cohorts(item_keys, conflict_edges)` and no
  pinned-set argument. Every substantive recording requirement of the criterion is delivered.
- **Item 12** — the clauses "the `parallel_kickoff_contract.py` / `artifact_type:
  "parallel-kickoff"` recommendation and its contingency are recorded" and "the single-item-run
  floor question is flagged for F3, not decided" are superseded. The R5 contingency fired and F4
  delivers the module and the artifact type, so the skill records F4 ownership and delivery rather
  than a pending recommendation; the single-item-run question is resolved by F3's landed ready-gate
  invariant P6 (at least two items), so the skill records the resolution rather than an open flag.

## `spec.md` — items 16 through 22 ([P9-T4])

| # | Criterion (abbreviated) | Status | Evidence |
| --- | --- | --- | --- |
| 16 | Contract test exists, follows the precedent, carries the positive and negative assertions, passes | checked | contract-test (EXIT_CODE 0; 15 passed plus 8 passed in the split companion module; 23 total) |
| 17 | No change to `atomic-plan-contract/SKILL.md`, `epic-planner.md`, `epic-plan/SKILL.md` | checked | non-mod-apc (VERDICT PASS — constraint 5); non-mod-epic (VERDICT PASS — constraint 6) |
| 18 | Both Markdown deliverables under 500 lines | checked | agent-persona (149 lines); skill-verification (420 lines) |
| 19 | F1/F2/F3 landing status re-verified and reconciled before execution | checked | upstream-reconciliation (per-feature verdicts against both the worktree and `origin/epic/parallel-orchestration-integration`; per-`[ASSUMPTION]` dispositions; R5 contingency verdict `fired`) |
| 20 | `parallel_kickoff_contract.py` exists, validates the R5 shape, under 500 lines, tests pass | checked | kickoff-module-size (380 lines production plus a 261-line helper module, both under 500); kickoff-contract-test (EXIT_CODE 0 with module coverage recorded) |
| 21 | Five-surface additive wiring and the dispatched TypeScript parity core module | checked | kickoff-wiring-test (EXIT_CODE 0 for both the pytest and the `node run-jest.cjs` invocations); non-mod-f3 (both adjudicated F4 additions present; every remaining F3-owned surface absent) |
| 22 | Skill documents the cohort recomputation-parity obligation (F3 P5) and the F4-owned per-branch git-integrity verification | checked | contract-test landed module (`test_skill_documents_the_cohort_recomputation_parity_obligation`, `test_skill_attributes_git_integrity_verification_to_f4`, `test_skill_cites_planner_invariant_p5_as_the_parity_basis`) |

## `user-story.md` — items 1 through 8 ([P9-T5])

The user-story preamble conditions its criteria on the `[ASSUMPTION]` regime defined in
`spec.md`. That regime is superseded: upstream-reconciliation records F1, F1a, F2, and F3 as
implementation-landed, so criteria touching live upstream tooling are verified against the landed
contracts rather than against a pending assumption. The `spec.md` deviation record carries the
same statement.

| # | Criterion (abbreviated) | Status | Skill section | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Mixed issue-number / potential-entry intake in one command; unpromoted items promoted by their own child | checked | `## Item Intake` | skill-verification (section present); contract-test |
| 2 | Procedure never asks for `depends_on`, waves, or a worthiness verdict | checked | `## Item Intake`, `## Preparation Fan-Out` | contract-test (`test_skill_contains_no_dependency_authoring_instruction`, `test_skill_contains_no_worthiness_gate`); skill-verification checks 1-3 |
| 3 | Same preparation-mode child contract; prepared folder and plan locatable on the item's own pushed branch | checked | `## Preparation Fan-Out`, `## Artifact Home` | contract-test (`test_skill_carries_the_preparation_mode_kickoff_markers`, `test_skill_branches_preparation_worktrees_from_origin_main`) |
| 4 | V1/V2 failure visibly iterated, not dropped; V3 surfaced as Advisory on a completing item | checked | `## Radius Computation and Validation`, `## Completion Report` | skill-verification |
| 5 | Completion report gives per-item plan-path, branch, preflight status, radius validation, plus cohort table, manifest path, both kickoff paths, and the execution-not-started statement | checked | `## Completion Report` | skill-verification; contract-test (`test_skill_names_both_kickoff_artifact_paths`) |
| 6 | Fresh-session start by discovering the kickoff on `parallel/<slug>-plan` via fetch plus `git show` without checkout | checked | `## Artifact Home`, `## Kickoff Artifact` | skill-verification |
| 7 | Only per-item branches plus the single run branch as new refs; no integration branch; nothing pushed to `main` by the planner | checked | `## Artifact Home` | contract-test (`test_skill_contains_no_integration_branch_creation_instruction`); skill-verification check 4 (both matches audited as negations) |
| 8 | Existing epic workflows unaffected; `/epic-plan` and `/epic-run` behave exactly as before | checked | n/a (diff-level guarantee) | non-mod-epic (VERDICT PASS — `epic-planner.md`, `epic-plan/SKILL.md`, `epic_kickoff_contract.py`, and `epic-kickoff-artifact.ts` all absent from the change set); non-mod-route (VERDICT PASS); non-mod-apc (VERDICT PASS); contract-test (`test_protected_surfaces_retain_their_identifying_content`) |

## Counts

- `spec.md`: 22 items total, 22 checked, 0 unchecked.
- `user-story.md`: 8 items total, 8 checked, 0 unchecked.
- Combined: 30 items total, 30 checked, 0 unchecked.

No acceptance-criterion text was modified by any Phase 9 task. Items 20 through 22 were appended
by [P9-T1] under the authority of spec R5's own contingency text; items 1 through 19 remain
byte-identical to their pre-amendment text.
