# Feature Audit — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T16-21
- Cycle: remediation cycle 1 exit reaudit
- Branch: `feature/parallel-planner-surface-443` @ `15656e4c`
- Base: `b086cf6958ee4b628f60309cda80aac772304bc8`
- Work Mode: `full-feature` (marker at `issue.md:10`)
- AC sources: `spec.md` `## Acceptance Criteria` (22 criteria) and `user-story.md`
  `## Acceptance Criteria` (8 criteria) — 30 total

## Method

Every criterion was evaluated against the branch head directly. Criteria that were satisfied at
cycle entry were re-evaluated rather than carried forward. Where a criterion asserts a runtime
behavior, the evidence is an executed command or a discriminating test, not the presence of a
heading.

## Result Summary

| Verdict | Count |
|---|---|
| PASS | 30 |
| PARTIAL | 0 |
| FAIL | 0 |
| UNVERIFIED | 0 |

No criterion checkbox was modified by this reviewer: all 30 were already `[x]` and all 30 evaluate
PASS.

## Preserve-Text Verification

`git diff cd57985d..HEAD -- spec.md user-story.md`, filtered to checkbox lines (`^[-+]- \[`),
returns zero lines. No acceptance-criterion text and no checkbox state was altered by the
remediation commit. The Phase 0 revert and the Phase 7 re-check netted out inside the single
remediation commit, which is the expected shape.

The only changed line in either AC source file is `user-story.md:135`, inside `## Non-Goals` prose
(the N3 `conflicts(a, b, config)` correction). It is not an acceptance criterion, so the
preserve-text rule does not apply to it.

## Superseded Criterion Clauses

Three criterion clauses are superseded by upstream contracts that landed after the criteria were
authored. The handling is correct: criterion text is left byte-identical and the supersession is
recorded in prose at `spec.md:582-603` rather than by editing the criteria. The clauses are:

1. Spec criterion 8's "labelled as an upstream contract (§5.1-§5.4) pending F1" — F1 has landed.
2. Spec criterion 10's "labelled as an upstream contract (§6) pending F2" — F2 has landed.
3. Spec criterion 12's "the `parallel_kickoff_contract.py` / `artifact_type: "parallel-kickoff"`
   recommendation and its contingency are recorded" and "the single-item-run floor question is
   flagged for F3, not decided" — superseded by the Boundary Deviation Record (`spec.md:556-579`)
   and by F3's landed ready-gate invariant P6.

Each affected criterion is evaluated below against its superseding contract, with the substitution
named.

## spec.md — Technical and Contract Criteria (22)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Agent frontmatter: `name`, `model: opus`, `memory: project`, no `hooks`, exact tool allowlist, `docs/features/parallel/**` scoping, no epics/active write scope | PASS | `.claude/agents/parallel-planner.md:1-25` read directly; no `hooks:` key; allowlist is exactly the 12 declared entries including `"Bash(poetry run *)"`; `Write`/`Edit` scoped to `docs/features/parallel/**` only. Asserted by `test_agent_frontmatter_declares_required_tool_allowlist` and `test_agent_frontmatter_declares_no_epic_docs_scope` |
| 2 | Preloads exactly `policy-compliance-order`, `parallel-plan`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`; not `parallel-orchestrate` | PASS | `.claude/agents/parallel-planner.md:18-23` — exactly those five, no sixth |
| 3 | `## Invocation Origin` documents the F7-owned hook extension and states documented-but-unenforced | PASS | `.claude/agents/parallel-planner.md:58-70` names `.claude/hooks/enforce-epic-invocation-origin.ps1`, `$script:GatedSubagentTypes`, both agent names, and the `EPIC_INVOCATION_ORIGIN_BLOCKED` reason; line 68-70 states the constraint is documented-but-unenforced until F7 |
| 4 | Skill frontmatter `context: fork`, `agent: parallel-planner`, argument hint accepting issue numbers and/or potential-entry paths | PASS | `.claude/skills/parallel-plan/SKILL.md:1-7`; `argument-hint: "[items: issue numbers and/or potential-entry paths]"` |
| 5 | Kickoff line carries `Preparation mode: true.`, `route_id: preparation.`, `parallel_slug: <slug>`, push instruction, `parallel-orchestrator` attribution, `model_budget.fable_policy` line; no `Epic mode: true`, no `Parallel mode: true` | PASS | `SKILL.md:72-74` carries all six required elements verbatim; `SKILL.md:90-94` states both omissions are intentional. Asserted by `test_preparation_kickoff_line_carries_neither_mode_marker` and `test_skill_omission_of_mode_markers_is_stated_deliberately` |
| 6 | Preparation worktree branch from `origin/main`; no change to `orchestrate/SKILL.md` or `config/orchestration-routing.json` | PASS | `SKILL.md:67` "Create each preparation worktree's branch from `origin/main`."; `SKILL.md:96-100` states the no-edit guarantee. Diff filtered against both paths returns `NONE TOUCHED` |
| 7 | R1 artifact-home decision plus the three residual risks | PASS | `SKILL.md:108-125` states per-item branches from `origin/main`, pushed before worktree removal, reused at execution; run-level artifacts on the never-merged-into `parallel/<slug>-plan`; `git fetch` + `git show <ref>:<path>` per the `epic-run` precedent. `SKILL.md:127-141` records all three residual risks |
| 8 | Documents F1 radius derivation and V1-V3 validation via `Bash(poetry run *)`; no reimplementation | PASS (clause 2 superseded) | `SKILL.md:145-180` documents the landed import-only calling convention with the exact signatures. The "pending F1" clause is superseded per `spec.md:585-587`. `SKILL.md:199-200` states the skill calls and defines none of them; verified no derivation, V1-V3, or contention logic appears in any delivered module |
| 9 | V1/V2 Blocking semantics and V3 Advisory semantics | PASS | `SKILL.md:189-195` — item does not transition to `prepared`, findings recorded, follow-up preparation delegation carrying findings, item re-planned not rejected; `SKILL.md:194` V3 Advisory recorded and surfaced with no state effect |
| 10 | One cohort-seeding invocation over the full graph; records `cohorts[]` gen 0, `conflict_edges[]`, `recolor_generation: 0`, `current_cohort: 0`; `max_concurrency` recorded not enforced; recoloring F6/F8 | PASS (clause 2 superseded) | `SKILL.md:229-240` states all four recorded fields and "exactly once per plan run, over the full conflict graph"; `SKILL.md:236-240` states `max_concurrency` default 4 recorded without enforcement, enforcement is F5's `compute_concurrency_batches`, recoloring is F6/F8. "Pending F2" clause superseded per `spec.md:588-590` |
| 11 | Kickoff artifact per R5: heading, `## Invocation Prompt` naming `/parallel-run <slug>` + manifest path + per-item-branch resume sentence, `## Item Summary` exact ordered headers, optional `## Integrity`, both paths | **PASS** (was FAIL at cycle entry) | `SKILL.md:356-386` template plus `:388-405` structural requirements. **Behaviorally verified, not heading-verified:** the live template rendered and validated to an empty error list in both runtimes, and independently through the CLI (`validate_orchestration_artifacts parallel-kickoff`, EXIT_CODE 0) with and without `## Integrity`. Bound by `test_parallel_kickoff_template_seam.py` (9 tests) and `parallel-kickoff-template-seam.test.ts` (8 tests), both confirmed to fail if the template or matcher regresses |
| 12 | F3 boundary stated in the delivered skill | PASS (two clauses superseded) | `SKILL.md:326-338` enumerates the F3-owned surfaces; `:339-344` states F4 ownership and delivery of the kickoff module and artifact type, citing both adjudication sources; `:346-348` records the single-item-run floor as resolved by F3's landed P6. Both superseded clauses documented at `spec.md:591-603` |
| 13 | Checkpoint instance contract per R6, `PARALLEL_EXECUTION_READY` sentinel, absence of `epic_worthiness`/`depends_on`/`wave`; manifest carries no `depends_on` and is committed fully resolved | PASS | `SKILL.md:286-321`; sentinel at `:307-308`; deliberate absences at `:300-302`; manifest no-`depends_on` and fully-resolved-before-kickoff at `:274-277` |
| 14 | Item intake per R8: mixed intake, negative placeholders back-filled, `kind` default-to-`feature` | PASS | `SKILL.md:35-57` — invocation shape, promotion by the child not the planner, negative placeholders `-1, -2, ...` back-filled from promotion receipts with the ordering-safety argument, `kind` default-to-`feature` with the recommendation label |
| 15 | No epic-worthiness gate analogue, no dependency-graph authoring instruction, no integration-branch creation instruction | PASS | Verified by grep: `depends_on`, `integration_branch`, `epic_worthiness`, `wave`, `NON_EPIC_RECOMMENDED` appear only in negative-constraint statements (`SKILL.md:274`, `:300`). Asserted by three dedicated tests (`test_skill_contains_no_worthiness_gate`, `..._no_dependency_authoring_instruction`, `..._no_integration_branch_creation_instruction`) |
| 16 | Surface-contracts test module exists, follows the precedent, contains the listed assertions, passes | PASS | `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` (410 lines); positive and negative assertions present; passes within the 97-test feature-scoped run |
| 17 | No change to `atomic-plan-contract/SKILL.md`, `epic-planner.md`, `epic-plan/SKILL.md` | PASS | Diff filtered against all three returns `NONE TOUCHED` |
| 18 | Agent and skill each under 500 lines | PASS | 149 and 420 lines respectively |
| 19 | Atomic plan re-verifies F1/F2/F3 landing status and reconciles landed upstream against `[ASSUMPTION]` entries | PASS | `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` (525 lines) records the verdict with file-existence evidence against both the worktree and `origin/epic/parallel-orchestration-integration`; supersessions recorded at `spec.md:580-603`; `plan.2026-08-07T11-11.md` updated accordingly |
| 20 | `parallel_kickoff_contract.py` exists, validates the R5 kickoff shape, under 500 lines, passes its tests | **PASS** (was PARTIAL at cycle entry) | Module is 386 lines. `RESUME_RE` now admits the spec's own "each item" wording (`:78-83`), so the matcher is no longer narrower than R5. Cross-runtime pattern parity confirmed byte-identical. `test_parallel_kickoff_contract.py` and `..._tables.py` pass; heading, invocation, six-column table, and optional integrity paths all covered at 100% line and 100% branch |
| 21 | `artifact_type: "parallel-kickoff"` registered additively on the Python CLI, `VALID_ARTIFACT_TYPES`, both MCP tool-definition enums, and the TypeScript dispatcher, with no reflow; TS parity core exists and is dispatched | PASS | Diff shows exactly one added line per surface: `validate_orchestration_artifacts.py:183` and `:360-361`, `mcp-tool-inputs.ts:438`, `mcp-tool-definitions.ts:414`, `mcp-repo-automation-tool-definitions.ts:347`, `orchestration-artifacts.ts:279-280`. No neighbouring entry reordered or reformatted. `parallel-kickoff-artifact.ts` exists (374 lines) and is dispatched |
| 22 | Skill documents the F4-owned cohort recomputation-parity obligation (P5) and the F4-owned per-branch git-integrity verification | PASS | `SKILL.md:242-258` states the P5 obligation, the re-invocation procedure, and that a mismatch is Blocking with no auto-correction and no kickoff emission; `SKILL.md:311-316` states the per-branch git-integrity obligation with the `git cat-file -e` / `git show` technique |

## user-story.md — Outcome and Behavioral Criteria (8)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Operator invokes the skill with a slug plus any mix of issue numbers and potential-entry paths | PASS | `SKILL.md:35-38` defines `/parallel-plan <slug> <item> [<item> ...]` with both item forms and notes the intake domain matches `/parallel-add`; frontmatter `argument-hint` matches |
| 2 | The documented procedure never asks the operator for `depends_on`, ordering, or a worthiness verdict | PASS | `SKILL.md:59-60` "The operator is never asked for ordering edges, cohort assignments, or a worthiness verdict." Asserted by test; no prompt-for-ordering instruction exists anywhere in the skill or agent |
| 3 | Every item prepared through the same preparation-mode child contract an epic child uses | PASS | `SKILL.md:62-106` reuses the `Preparation mode: true.` / `route_id: preparation.` markers verbatim; `SKILL.md:96-100` confirms no edit to the shared child contract, and the diff confirms `orchestrate/SKILL.md` and `config/orchestration-routing.json` are untouched |
| 4 | An item failing V1 or V2 is visibly iterated: findings recorded, plan revised via follow-up delegation, not silently dropped | PASS | `SKILL.md:191-193` and `.claude/agents/parallel-planner.md:97-99` both state the item is re-planned, never dropped, and never withdrawn on the planner's own initiative |
| 5 | Completion report gives per item: plan-path, branch name, preflight status, radius-validation result | PASS | `SKILL.md:407-420` requires exactly those four per item plus V3 Advisory findings; `parallel-planner.md:130-132` restates it as a completion requirement |
| 6 | After planning, the operator can start execution from a fresh session using the kickoff artifact | **PASS** (dependent on the B1/B2 fix) | The kickoff the skill instructs the planner to emit now validates clean end-to-end. Independently reproduced: `validate_orchestration_artifacts parallel-kickoff` EXIT_CODE 0 on the rendered live template, both with and without `## Integrity`. Before remediation this criterion was not genuinely satisfied because the emitted document was rejected on two counts |
| 7 | After a run the repository contains only per-item feature branches and the plan branch; no integration branch | PASS | `SKILL.md:116-121` states `parallel/<slug>-plan` is explicitly not an integration branch, never merged in either direction, and holds only `docs/features/parallel/<slug>/**`; `SKILL.md:104` states there is no fan-in merge step. Both asserted by test |
| 8 | Existing epic workflows unaffected: `/epic-plan` and `/epic-run` behave exactly as before | PASS | All epic surfaces confirmed untouched by the diff (`epic-planner.md`, `epic-plan/SKILL.md`, `epic_kickoff_contract.py`, `epic-kickoff-artifact.ts`, `orchestrate/SKILL.md`, `config/orchestration-routing.json`). Full suites green: 2968 Python tests, 2451 TypeScript tests across 183 suites. All wiring is additive with no reflow |

## Cycle-Entry Finding Dispositions

| ID | Finding | Disposition |
|---|---|---|
| B1 / R-1 | Resume-boundary sentence rejected by `RESUME_RE` | **RESOLVED** — regex widened in both runtimes, byte-identical patterns confirmed programmatically, widening confirmed non-vacuous |
| B2 / R-2 | `## Integrity` commit field name rejected | **RESOLVED** — template now emits `planning_commit: <hex>`; `INTEGRITY_COMMIT_RE` unchanged; mirror re-synced byte-identically |
| B3 / R-4 | Acceptance criteria checked without evidence | **RESOLVED** — criteria 11 and 20 now evidence-supported by seam tests and an executed CLI run; preserve-text rule honored (zero criterion-line changes) |
| B4 / R-3 | No test binds the template to the contract | **RESOLVED** — seam modules added in both runtimes, empirically confirmed to fail if B1 or B2 regresses; no process spawn, no temporary file |
| N1 / R-5 | Evidence artifact missing command-step fields | **RESOLVED** — `Command:`, `EXIT_CODE: 0`, `Output Summary:` added with a correction note |
| N2 / R-6 | Evidence filename lacked ISO timestamp | **RESOLVED** — renamed to `phase0-instructions-read.2026-08-08T13-49.md` |
| N3 / R-7 | Stale two-argument `conflicts(a, b)` reference | **RESOLVED** — `user-story.md:135` now `conflicts(a, b, config)`, matching `_blast_radius_conflicts.py:137-139` |
| A1 | Record verified parity scope for the kickoff module | **DEFERRED** (remains open Advisory) — remedy targets `.claude/rules/parallel-orchestration.md`, a protected surface |
| A2 | Port decision-logic comments into the TypeScript module | **RESOLVED** (comment-only) — header note at `parallel-kickoff-artifact.ts:12-19` directs readers to the Python reference |
| A3 | Establish the Integrity-template precedent | **DEFERRED** (remains open Advisory) — remedy targets `.claude/skills/epic-plan/SKILL.md`, a protected surface |

No cycle-entry finding is newly reintroduced. No new Blocking or Non-blocking finding was
identified in this reaudit.

## Exit-Criteria Check (from `remediation-inputs.2026-08-08T14-59.md`)

| # | Exit criterion | Met |
|---|---|---|
| 1 | Rendered template validates to an empty error list in both runtimes, with and without `## Integrity` | YES — reproduced independently, EXIT_CODE 0 both ways |
| 2 | Seam test exists in both runtimes and passes | YES — 9 Python tests, 8 TypeScript tests, all passing and confirmed discriminating |
| 3 | `cmp` confirms byte identity for both mirrored files | YES |
| 4 | Criteria 11 and 20 genuinely satisfied and re-checked with seam-test evidence | YES |
| 5 | Full toolchain passes in a single pass for both languages | YES — Black, Ruff, Pyright, pytest; Prettier, ESLint, tsc, Jest |
| 6 | Coverage does not regress below recorded values; changed production files >= 85% line / >= 75% branch | YES — Python 91.8236% / 83.8000%; TypeScript 97.1663% / 89.5560%; every changed production file above both floors |
| 7 | No protected surface in the diff | YES — all eleven checked paths return `NONE TOUCHED` |

All seven exit criteria are met.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md
          docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md
- Total AC items: 30 (22 spec + 8 user-story)
- Checked off (delivered): 30
- Remaining (unchecked): 0
- Items remaining: none
```

## Verdict

**PASS.** All 30 acceptance criteria are satisfied and evidence-supported. All four cycle-entry
Blocking findings and all three Non-blocking findings are resolved, verified by independent
reproduction rather than by accepting the executor's report. Two Advisory findings remain
correctly deferred on protected-surface grounds and three new Advisory findings are recorded. There
are zero Blocking and zero blocking-PARTIAL findings, so remediation cycle 1 may close.
