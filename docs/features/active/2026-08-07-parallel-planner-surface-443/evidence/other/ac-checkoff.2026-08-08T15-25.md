# Acceptance-Criteria Check-Off Record — Remediation Cycle 1

Timestamp: 2026-08-08T15-25

Task: [P7-T3]

Supersedes: `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/ac-checkoff.2026-08-08T14-45.md`

AC sources (Work Mode `full-feature`, marker at `issue.md:10`):
- `docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md` — 22 criteria
- `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md` — 8 criteria
- Combined total: 30

## What This Record Changes

Feature review raised Blocking finding B3: two `spec.md` criteria carried a `[x]` whose supporting evidence did not establish the criterion. Criteria 11 and 20 were checked off against **heading-presence** and **module-existence** evidence only. Neither established that a document produced from the delivered template is accepted by the delivered validator — and in fact it was not, as the [P0-T10] fail-before reproduction demonstrated with exit code 1 and two error lines.

Both criteria were reverted to `[ ]` immediately in Phase 0 ([P0-T11] and [P0-T12]) and are re-checked here only after B1, B2, and B4 landed. Their supporting evidence is now **validation** evidence: seam tests that render the real template and assert an empty error list, plus end-to-end CLI runs through the delivered artifact type.

The prior record's support for criterion 11 read `skill-verification (## Kickoff Artifact section with the fenced template headings)`. That is heading-presence evidence only. It is replaced by the evidence named in the criterion-11 row below. The prior record's support for criterion 20 named module existence, line count, and the contract module's own unit tests, none of which exercised the template; it is replaced likewise.

Criterion text was not modified anywhere in this cycle. Only `- [ ]` <-> `- [x]` state changes were made, per `.claude/skills/acceptance-criteria-tracking/SKILL.md`.

## `spec.md` — 22 Criteria

| # | Line | Criterion (abbreviated) | Status | Supporting evidence |
|---|---|---|---|---|
| 1 | 611 | Persona frontmatter, tool allowlist, `docs/features/parallel/**` scoping, no epic/active write scope | `[x]` | Carried forward: agent-persona verification (149 lines; checks 1-2 PASS); contract tests `test_agent_frontmatter_declares_required_tool_allowlist`, `test_agent_frontmatter_declares_no_epic_docs_scope`. Re-run green at [P2-T6] (23 passed, EXIT_CODE 0) |
| 2 | 616 | Exactly five preloaded skills, no `parallel-orchestrate` | `[x]` | Carried forward: contract test `test_agent_frontmatter_declares_name_and_preloaded_skills`. Re-run green at [P2-T6] |
| 3 | 619 | `## Invocation Origin` documents the F7 `$script:GatedSubagentTypes` extension point | `[x]` | Carried forward: agent-persona verification (`GatedSubagentTypes` present). Re-run green at [P2-T6] |
| 4 | 624 | Skill frontmatter `context: fork`, `agent: parallel-planner`, argument hint | `[x]` | Carried forward: contract test `test_skill_frontmatter_routes_to_the_parallel_planner_agent`. Re-run green at [P2-T6] |
| 5 | 627 | Preparation kickoff-line markers; neither mode marker in the line | `[x]` | Carried forward: contract tests `test_skill_carries_the_preparation_mode_kickoff_markers`, `test_preparation_kickoff_line_carries_neither_mode_marker`. Re-run green at [P2-T6] |
| 6 | 632 | `origin/main` branching; no change to `orchestrate/SKILL.md` or `config/orchestration-routing.json` | `[x]` | Carried forward: contract test `test_skill_branches_preparation_worktrees_from_origin_main`; re-verified this cycle by [P8-T11] protected-surface check |
| 7 | 635 | R1 artifact home with the three residual risks | `[x]` | Carried forward: skill-verification (`## Artifact Home` present). Re-run green at [P2-T6] |
| 8 | 642 | F1 radius derivation and V1-V3 validation invoked via `Bash(poetry run *)`; no reimplementation | `[x]` | Carried forward: contract tests `test_skill_uses_import_only_upstream_invocation`, `test_skill_cites_three_argument_contention_signature`, `test_skill_cites_derivation_over_document_text`. The stale `conflicts(a, b)` token inside this criterion's own text is deliberately not edited; see `evidence/other/evidence-filename-normalization.2026-08-08T15-25.md` |
| 9 | 646 | V1/V2 Blocking and V3 Advisory semantics | `[x]` | Carried forward: skill-verification (`## Radius Computation and Validation` present). Re-run green at [P2-T6] |
| 10 | 649 | One cohort-seeding invocation with the recorded fields; recoloring F6/F8 | `[x]` | Carried forward: contract test `test_skill_cites_two_parameter_cohort_seeding_signature`. Re-run green at [P2-T6] |
| **11** | **655** | **Kickoff artifact per R5: heading, `## Invocation Prompt` with the resume-boundary sentence, six-column `## Item Summary`, optional `## Integrity`, both paths** | **`[x]` (re-checked)** | **Seam tests binding the delivered template to the delivered contract, all asserting an empty error list: `test_rendered_template_with_integrity_validates_clean` ([P3-T4]) and `test_rendered_template_without_integrity_validates_clean` ([P3-T5]); TypeScript `validates the rendered template with the ## Integrity section` ([P4-T5]) and `validates the rendered template without the ## Integrity section` ([P4-T6]). End-to-end CLI runs through the delivered `parallel-kickoff` artifact type: `evidence/regression-testing/kickoff-cli-e2e-with-integrity.2026-08-08T15-25.md` (EXIT_CODE 0, zero error lines) and `evidence/regression-testing/kickoff-cli-e2e-no-integrity.2026-08-08T15-25.md` (EXIT_CODE 0, zero error lines). Both-paths clause carried forward from contract test `test_skill_names_both_kickoff_artifact_paths`** |
| 12 | 661 | F3 boundary stated in the skill; kickoff-module disposition; single-item-run floor | `[x]` | Carried forward: contract tests `test_skill_claims_the_kickoff_contract_as_delivered_by_this_feature`, `test_skill_attributes_git_integrity_verification_to_f4`, `test_skill_cites_planner_invariant_p5_as_the_parity_basis`. Re-run green at [P2-T6] |
| 13 | 669 | Checkpoint contract per R6, `PARALLEL_EXECUTION_READY`, deliberate absences | `[x]` | Carried forward: contract test `test_skill_names_the_planner_checkpoint_and_manifest_paths`. Re-run green at [P2-T6] |
| 14 | 674 | Item intake per R8 | `[x]` | Carried forward: skill-verification (`## Item Intake` present). Re-run green at [P2-T6] |
| 15 | 677 | No worthiness gate, no dependency-graph authoring, no integration-branch creation | `[x]` | Carried forward: contract tests `test_skill_contains_no_worthiness_gate`, `test_skill_contains_no_dependency_authoring_instruction`, `test_skill_contains_no_integration_branch_creation_instruction`. Re-run green at [P2-T6] |
| 16 | 679 | Contract test exists, follows the precedent, carries the assertions, passes | `[x]` | Re-verified this cycle: `evidence/regression-testing/surface-contracts-post-b2.2026-08-08T15-25.md`, `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py -q`, EXIT_CODE 0, 23 passed |
| 17 | 682 | No change to `atomic-plan-contract/SKILL.md`, `epic-planner.md`, `epic-plan/SKILL.md` | `[x]` | Re-verified this cycle: `evidence/qa-gates/protected-surface-check.2026-08-08T15-25.md` ([P8-T11]) |
| 18 | 684 | Both Markdown deliverables under 500 lines | `[x]` | Re-measured this cycle: `evidence/other/mirror-byte-identity.2026-08-08T15-25.md` `## Line Counts` section ([P2-T5]) — skill 420 lines, agent 149 lines, both mirrors identical |
| 19 | 686 | F1/F2/F3 landing status re-verified and reconciled before execution | `[x]` | Carried forward: `evidence/other/upstream-reconciliation` record from the base plan cycle. Not disturbed by this cycle |
| **20** | **689** | **`parallel_kickoff_contract.py` exists, validates the R5 kickoff shape (heading, `## Invocation Prompt`, six-column `## Item Summary`, optional `## Integrity`), under 500 lines, tests pass** | **`[x]` (re-checked)** | **The widened `RESUME_RE` from [P1-T1] now admits the `each item` wording that `spec.md:451` states as the governing requirement, so the module validates the R5 shape as the spec defines it rather than a narrower variant. Three-alternant tests: `test_resume_boundary_accepts_each_documented_alternant` over `Every item`, `Each item`, `items` ([P3-T7]) and TypeScript `accepts the documented resume-boundary alternant ...` ([P4-T8]), each asserting an empty error list, plus the `Each entry` negative case in each runtime asserting the widening did not make the matcher vacuous. Optional-`## Integrity` path validated by [P3-T5]/[P4-T6] and by `evidence/regression-testing/kickoff-cli-e2e-no-integrity.2026-08-08T15-25.md`. Line count 386, under 500: `evidence/other/kickoff-module-size.2026-08-08T14-17.md` `## Command-Step Fields` section. Tests pass: `evidence/regression-testing/kickoff-contract-post-b1.2026-08-08T15-25.md`, EXIT_CODE 0, 49 passed** |
| 21 | 693 | Five-surface additive wiring and the dispatched TypeScript parity core module | `[x]` | Carried forward: kickoff-wiring test evidence from the base plan cycle; re-exercised this cycle end-to-end by the [P5-T1]/[P5-T2]/[P5-T3] CLI runs, which reach the module only through the registered `parallel-kickoff` artifact type |
| 22 | 698 | Skill documents the cohort recomputation-parity obligation (F3 P5) and F4-owned per-branch git-integrity verification | `[x]` | Carried forward: contract tests `test_skill_documents_the_cohort_recomputation_parity_obligation`, `test_skill_attributes_git_integrity_verification_to_f4`, `test_skill_cites_planner_invariant_p5_as_the_parity_basis`. Re-run green at [P2-T6] |

## `user-story.md` — 8 Criteria

| # | Line | Criterion (abbreviated) | Status | Supporting evidence |
|---|---|---|---|---|
| 1 | 98 | Mixed issue-number / potential-entry intake in one command | `[x]` | Carried forward: skill-verification (`## Item Intake`); contract tests. Re-run green at [P2-T6] |
| 2 | 101 | Procedure never asks for `depends_on`, waves, or a worthiness verdict | `[x]` | Carried forward: contract tests `test_skill_contains_no_dependency_authoring_instruction`, `test_skill_contains_no_worthiness_gate`. Re-run green at [P2-T6] |
| 3 | 104 | Same preparation-mode child contract; prepared artifacts on the item's own pushed branch | `[x]` | Carried forward: contract tests `test_skill_carries_the_preparation_mode_kickoff_markers`, `test_skill_branches_preparation_worktrees_from_origin_main`. Re-run green at [P2-T6] |
| 4 | 108 | V1/V2 failure visibly iterated; V3 surfaced as Advisory | `[x]` | Carried forward: skill-verification (`## Radius Computation and Validation`, `## Completion Report`). Re-run green at [P2-T6] |
| 5 | 112 | Completion report content per item plus cohort table, manifest path, both kickoff paths | `[x]` | Carried forward: skill-verification; contract test `test_skill_names_both_kickoff_artifact_paths`. Re-run green at [P2-T6] |
| 6 | 116 | Fresh-session start by discovering the kickoff on `parallel/<slug>-plan` | `[x]` | Carried forward: skill-verification (`## Artifact Home`, `## Kickoff Artifact`). Strengthened this cycle: the kickoff a fresh session would discover is now provably valid against the delivered validator ([P5-T1], EXIT_CODE 0) |
| 7 | 120 | Only per-item branches plus the single run branch; no integration branch | `[x]` | Carried forward: contract test `test_skill_contains_no_integration_branch_creation_instruction`. Re-run green at [P2-T6] |
| 8 | 123 | Existing epic workflows unaffected | `[x]` | Re-verified this cycle: `evidence/qa-gates/protected-surface-check.2026-08-08T15-25.md` ([P8-T11]) confirms `epic-planner.md`, `epic-plan/SKILL.md`, `epic_kickoff_contract.py`, and `epic-kickoff-artifact.ts` are all absent from this cycle's change set; contract test `test_protected_surfaces_retain_their_identifying_content` re-run green at [P2-T6] |

## Counts

- `spec.md`: 22 total, 22 checked, 0 unchecked.
- `user-story.md`: 8 total, 8 checked, 0 unchecked.
- Combined: 30 total, 30 checked, 0 unchecked.

## Text-Preservation Statement

No acceptance-criterion text was modified in this remediation cycle. The `spec.md` diff for the cycle nets to zero: [P0-T11] and [P0-T12] changed two criteria from `[x]` to `[ ]`, and [P7-T1] and [P7-T2] changed the same two back to `[x]` after the supporting work landed. The only `user-story.md` change is the [P6-T4] Non-Goals prose correction at line 135, which is not an acceptance criterion. This is verified independently by [P7-T4].
