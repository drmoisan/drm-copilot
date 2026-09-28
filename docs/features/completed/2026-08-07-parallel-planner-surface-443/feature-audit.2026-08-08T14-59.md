# Feature Audit — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T14-59
- Branch: `feature/parallel-planner-surface-443`
- Base: `epic/parallel-orchestration-integration` (merge base `b086cf6958ee4b628f60309cda80aac772304bc8`)
- Work Mode: `full-feature` (marker at `issue.md:10`)
- AC sources: `spec.md` (22 criteria) **and** `user-story.md` (8 criteria)

## Method

Each criterion was evaluated against the delivered artifacts in the working tree, not against the
execution report. Where a criterion asserts a negative (absence of a surface, absence of a
marker), absence was confirmed by an explicit search rather than inferred. Where a criterion
asserts that a documented procedure conforms to a landed upstream contract, the upstream
signature was read from the landed module.

## Spec Acceptance Criteria (22)

| # | Line | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|---|
| 1 | 611 | Agent frontmatter: `name`, `model: opus`, `memory: project`, no `hooks`, exact tool allowlist incl. `Bash(poetry run *)` and `docs/features/parallel/**` scoping; no epics/active write scope | PASS | `parallel-planner.md:1-25` matches `spec.md:279-293` item-for-item. No `hooks` key. No `docs/features/epics/**` and no `docs/features/active/**` entry present. |
| 2 | 616 | Preloads exactly the five named skills; does not preload `parallel-orchestrate` | PASS | `parallel-planner.md:18-23` lists exactly `policy-compliance-order`, `parallel-plan`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`. `parallel-orchestrate` absent. |
| 3 | 619 | `## Invocation Origin` documents the F7 hook extension and states documented-but-unenforced | PASS | `parallel-planner.md:58-70` names `.claude/hooks/enforce-epic-invocation-origin.ps1`, `$script:GatedSubagentTypes`, both agent names, the `EPIC_INVOCATION_ORIGIN_BLOCKED` reason, and "Until F7 lands, the constraint is documented-but-unenforced". |
| 4 | 624 | Skill frontmatter `context: fork`, `agent: parallel-planner`, argument hint | PASS | `SKILL.md:1-7`; `argument-hint: "[items: issue numbers and/or potential-entry paths]"`. |
| 5 | 627 | Preparation kickoff line: verbatim markers, `parallel_slug`, push instruction, downstream attribution, `model_budget` line; no `Epic mode: true`, no `Parallel mode: true` | PASS | `SKILL.md:72` contains `Preparation mode: true.`, `route_id: preparation.`, `parallel_slug: <slug>.`, "push the current branch to origin", "executed later by parallel-orchestrator"; `:74` carries the `model_budget.fable_policy` line. Both mode markers appear only at `:91-92` inside the deliberate-omission statement, not in the line itself. |
| 6 | 632 | Worktree branch from `origin/main`; no change to `orchestrate/SKILL.md` or `orchestration-routing.json` | PASS | `SKILL.md:67` "Create each preparation worktree's branch from `origin/main`". Neither protected file appears in `git diff --name-only`. |
| 7 | 635 | R1 artifact-home decision plus the three residual risks | PASS | `SKILL.md:108-141`: per-item artifacts on the item's own branch off `origin/main` pushed before worktree removal; run-level artifacts on `parallel/<slug>-plan`; `git fetch` + `git show <ref>:<path>` per the `epic-run` precedent; the three risks enumerated at `:129-141`. |
| 8 | 642 | Documents F1 derivation and V1-V3 validation via `Bash(poetry run *)`; no reimplementation of derivation, V1-V3, or `conflicts` | PASS (clause superseded per `spec.md:592-594`) | `SKILL.md:143-200`. Cited signatures verified against `compute_blast_radius.py:216-224`, `_blast_radius_validation.py:322-328`, `_blast_radius_conflicts.py:137-139`. `SKILL.md:199-200` states "This skill calls them; it defines none of them." No reimplementation present. |
| 9 | 646 | V1/V2 Blocking semantics and V3 Advisory semantics | PASS | `SKILL.md:188-193` (item does NOT transition to `prepared`; findings recorded in `radius_validation`; re-planned via follow-up preparation delegation, not rejected; withdrawal is a caller decision) and `:194-195` (V3 recorded and surfaced, "no state effect"). |
| 10 | 649 | One cohort-seeding invocation over the full graph; `generation: 0`, `conflict_edges[]`, `recolor_generation: 0`, `current_cohort: 0`; `max_concurrency` recorded not enforced; recoloring is F6/F8 | PASS (clause superseded per `spec.md:595-597`) | `SKILL.md:230-240`. `compute_cohorts(item_keys, conflict_edges)` verified at `parallel_cohort_computation.py:350-353`; `compute_concurrency_batches` at `:419-422`. |
| 11 | 655 | Kickoff artifact per R5: heading; `## Invocation Prompt` naming `/parallel-run <slug>`, manifest path, resume-boundary sentence; `## Item Summary` exact headers; optional `## Integrity`; both paths | **FAIL** | Heading, `## Item Summary` headers, and both paths are correct (`SKILL.md:357`, `:375`, `:352-354`). The **resume-boundary sentence** at `:369-371` ("Each item resumes...") is rejected by `RESUME_RE`, and the **`## Integrity`** commit field at `:381` ("`parallel/<slug>-plan head commit:`") is rejected by `INTEGRITY_COMMIT_RE`, which requires `planning_commit:`. Validated end-to-end: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff <rendered template>` → EXIT_CODE 1 with both errors. See code-review B1, B2. |
| 12 | 661 | F3 boundary stated in the skill; kickoff-module disposition; single-item-run floor | PASS (clauses superseded per `spec.md:598-603`) | `SKILL.md:326-348` enumerates the F3-owned surfaces and states "it never extends or redefines them"; `:339-344` records F4 ownership and delivery of the kickoff module and artifact type; `:346-348` resolves the single-item-run floor via P6's two-item requirement. |
| 13 | 669 | Checkpoint contract per R6 incl. `PARALLEL_EXECUTION_READY` and the deliberate absences; manifest carries no `depends_on` and is committed fully resolved | PASS | `SKILL.md:284-324` (top-level and per-item fields; `:300-302` "Deliberately absent: any `epic_worthiness` analogue, any `depends_on` field, and any `wave` field"; `:308` ready sentinel). Manifest: `:274-277` no `depends_on`, no `integration_branch`, "fully resolved form — every negative placeholder `issue_num` replaced" before kickoff. |
| 14 | 674 | Item intake per R8: mixed intake, negative placeholders back-filled, `kind` default-to-`feature` | PASS | `SKILL.md:33-57`: mixed issue-number / potential-entry intake at `:35-38`; negative placeholders `-1, -2, ...` back-filled from promotion receipts at `:43-48`; `kind` default-to-`feature` at `:55-57`. |
| 15 | 677 | No epic-worthiness gate analogue, no dependency-graph authoring instruction, no integration-branch creation instruction | PASS | Search over `SKILL.md`: every `worthiness` match (`:18`, `:59`, `:300-301`) is a denial; every `depends_on` match (`:274`, `:300`) is a prohibition; every integration-branch match (`:119`, `:274`) is a denial or prohibited-key statement. No authoring or creation instruction exists. |
| 16 | 679 | `test_parallel_planner_surface_contracts.py` exists, follows the precedent, contains the listed positive and negative assertions, passes | PASS | File exists (410 lines), follows the read-the-surface-and-assert-fragments precedent. All assertions listed at `spec.md:494-513` are present. `poetry run pytest <5 feature modules> -q` → EXIT_CODE 0, `88 passed`. The producer/consumer gap identified as code-review B4 is outside this criterion's enumerated list. |
| 17 | 682 | No change to `atomic-plan-contract/SKILL.md`, `epic-planner.md`, `epic-plan/SKILL.md` | PASS | `git diff --name-only <base>...HEAD` contains none of the three. The single grep match is an evidence filename, not a protected surface. |
| 18 | 684 | Agent and skill each under 500 lines | PASS | `wc -l`: `parallel-planner.md` 149, `SKILL.md` 420. |
| 19 | 686 | Atomic plan re-verifies F1/F2/F3 landing status and reconciles landed specs against the `[ASSUMPTION]` entries | PASS | `evidence/other/upstream-reconciliation.2026-08-08T13-56.md` records the verdict with file-existence evidence against both the worktree and `origin/epic/parallel-orchestration-integration`; the reconciliation outcome is carried into `spec.md:556-603`. |
| 20 | 689 | `parallel_kickoff_contract.py` exists, validates the R5 kickoff shape, under 500 lines, passes its tests | **PARTIAL** | Exists (380 lines, plus 261-line helper); tests pass (EXIT_CODE 0, 100% line and branch coverage). However it does not validate the R5 shape **as R5 states it**: `spec.md:451` specifies "a resume-boundary sentence stating that **each item** resumes at atomic execution...", while `RESUME_RE` (`parallel_kickoff_contract.py:72-77`) admits only `Every item` or `items`. The module is under-permissive relative to its own governing specification. |
| 21 | 693 | Five-surface additive wiring with no reflow; TS parity core exists and is dispatched | PASS | One named addition per surface, verified in the diff: `validate_orchestration_artifacts.py:183` + dispatch `:360-361`; `mcp-tool-inputs.ts:438`; `mcp-tool-definitions.ts:414`; `mcp-repo-automation-tool-definitions.ts:347`; `orchestration-artifacts.ts:17,279-280`. No existing entry reordered or reformatted. |
| 22 | 698 | Skill documents the F4-owned cohort recomputation-parity obligation (P5) and the F4-owned per-branch git-integrity verification | PASS | `SKILL.md:242-258` discharges P5 as documented procedure with a Blocking mismatch condition and no new module; `:311-316` assigns git integrity to F4 with the concrete `git cat-file -e <ref>:<path>` / `git show <ref>:<path>` technique against each per-item ref plus `parallel/<slug>-plan`. |

**Spec totals: 20 PASS, 1 PARTIAL, 1 FAIL.**

## User-Story Acceptance Criteria (8)

| # | Line | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|---|
| 1 | 98 | One-command invocation with mixed issue numbers and potential-entry paths; unpromoted items promoted by their own preparation child | PASS | `SKILL.md:35-42`: invocation shape `/parallel-plan <slug> <item> [<item> ...]`; "Unpromoted items are promoted by their own preparation-mode child, not by the planner", with the `preparation` route's existing promotion MCP tools named. No separate manual promotion step. |
| 2 | 101 | Procedure never asks for `depends_on`, wave assignments, or a worthiness verdict | PASS | `SKILL.md:59-60` "The operator is never asked for ordering edges, cohort assignments, or a worthiness verdict. Intake proceeds directly to preparation fan-out." Corroborated by criterion 15 above. |
| 3 | 104 | Same preparation-mode child contract; prepared folder and plan locatable on the item's own pushed branch | PASS | `SKILL.md:62-106` reuses `route_id: preparation` unchanged and enumerates the full child scope; `:110-114` fixes the per-item branch as the location, with `branch_name` and `worktree_path` recorded per item. |
| 4 | 108 | V1/V2 failure visibly iterated rather than dropped; V3 Advisory appears in the completion report on an item that still completes | PASS | `SKILL.md:188-193` (findings recorded, follow-up preparation delegation carrying the findings, "The item is re-planned, not rejected", withdrawal never a planner default); `:194-195` and `:414` (V3 recorded and surfaced in the completion report, no state effect). |
| 5 | 112 | Completion report per item plus generation-0 cohort table, manifest path, both kickoff paths, and the execution-NOT-started statement | PASS | `SKILL.md:407-420` lists all required elements and closes with "execution has NOT started and begins only when the operator runs `/parallel-run <slug>`". |
| 6 | 116 | Fresh-session start by discovering the kickoff via the `parallel/<slug>-plan` branch (fetch plus `git show`, no checkout) | PASS | `SKILL.md:123-125` documents `git fetch origin <branch>` followed by `git show <ref>:<path>` "without checking the ref out", citing the `epic-run` precedent; `:352-354` places the durable kickoff copy on that branch. The discovery mechanism is fully specified. (The document so discovered is affected by spec criterion 11; the discovery mechanism itself is not.) |
| 7 | 120 | Only per-item feature branches and the single `parallel/<slug>-plan` run branch as new refs; no integration branch; nothing pushed to `main` by the planner | PASS | `SKILL.md:116-121`: the run branch "is explicitly not an integration branch: no item branch ever merges into it, it never merges into any item branch, and it holds only `docs/features/parallel/<slug>/**`"; "Each item opens its own pull request against `main`." No push-to-`main` instruction exists anywhere in the skill. |
| 8 | 123 | Existing epic workflows unaffected; `/epic-plan` and `/epic-run` behave exactly as before | PASS | Diff-level guarantee: `epic-planner.md`, `epic-plan/SKILL.md`, `epic-run/SKILL.md`, `epic_kickoff_contract.py`, and `epic-kickoff-artifact.ts` are all absent from `git diff --name-only <base>...HEAD`. All MCP wiring is additive with no reflow (criterion 21). |

**User-story totals: 8 PASS.**

## Baseline-Relative Assessment

Relative to the merge base `b086cf69`, the feature adds the planning half of the `parallel`
surface without altering any pre-existing behavior:

- **Behavioral additions:** one new MCP `artifact_type` (`parallel-kickoff`) reachable through
  the Python CLI and the TypeScript dispatcher; two new Markdown runtime surfaces registered in
  the core pack manifest.
- **Behavioral changes to existing surfaces:** none. Every registration edit is a single appended
  member; the previously-unsupported `parallel-kickoff` value now routes to a validator instead of
  falling through to the unsupported-type branch, which is the adjudicated intent.
- **Regression risk:** low. Repo-wide coverage improved on the Python side (91.72% → 91.82% line,
  83.58% → 83.80% branch) and the TypeScript side remains at 97.16% / 89.54%. The five landed F3
  tests whose expectations changed each retained unsupported-type fallback coverage through a
  newly added test using the genuinely unregistered probe `parallel-status-doc`.

## Supersession Records — adequacy assessment

`spec.md:582-603` records three criterion clauses as superseded rather than editing the criterion
text, per the `acceptance-criteria-tracking` preserve-text rule. The records were assessed for
adequacy and honesty:

| Superseded clause | Assessment |
|---|---|
| Criterion 8's "pending F1" | **Adequate.** The record states F1 landed and that the skill documents the landed import-only calling convention. Verified: `SKILL.md:145-151` documents the import-only form, and all three cited F1 signatures match the landed modules exactly. |
| Criterion 10's "pending F2" | **Adequate.** The record names the landed `compute_cohorts(item_keys, conflict_edges)` signature. Verified against `parallel_cohort_computation.py:350-353`. The record does not overstate: it names the exact signature rather than asserting general conformance. |
| Criterion 12's "recommendation and its contingency" and "single-item-run floor flagged for F3, not decided" | **Adequate.** The record states the recommendation became a delivery and the floor question was resolved by F3's landed P6, and points to the deviation record for the first and to P6 for the second. Verified: `SKILL.md:339-344` states F4 ownership and delivery, and `:346-348` records the two-item ready-gate resolution. The record correctly declines to claim the original clause was satisfied. |

All three records identify what changed, why, and where the replacing evidence lives, and none
asserts more than the evidence supports. The mechanism was used correctly and no criterion text
was modified — confirmed by the `user-story.md` diff, which contains only `- [ ]` → `- [x]`
transitions with byte-identical criterion text, and by the absence of any criterion-text change in
the `spec.md` diff.

## Acceptance Criteria Status

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md` and
  `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md`
- Total AC items: 30 (22 spec + 8 user-story)
- Currently marked checked in the source files: 30
- Evaluated PASS by this audit: 28
- Evaluated PARTIAL: 1 — spec criterion 20 (`parallel_kickoff_contract.py` ... validates the R5
  kickoff shape)
- Evaluated FAIL: 1 — spec criterion 11 (kickoff artifact per R5)
- Items remaining (not genuinely satisfied):
  - `spec.md:655-660` — "The skill specifies the kickoff artifact per R5: heading
    `# Parallel Kickoff: <slug>`; `## Invocation Prompt` naming `/parallel-run <slug>`, the
    manifest path, and the per-item-branch resume-boundary sentence; `## Item Summary` with exact
    ordered headers ...; optional `## Integrity`; working copy at ... and durable copy at ..."
  - `spec.md:689-692` — "`scripts/dev_tools/parallel_kickoff_contract.py` exists, validates the R5
    kickoff shape ..., is under 500 lines, and passes
    `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`" (PARTIAL: validates a shape
    narrower than R5's stated resume-boundary wording)

### Check-off actions not taken

No AC checkbox was modified by this audit. Two items are currently marked `[x]` in `spec.md` but
are evaluated FAIL and PARTIAL respectively. Per the reviewer protocol in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, such items must not carry a check. This
audit records the discrepancy rather than editing the source file, because the required correction
is a code change (B1/B2) whose completion should drive the check-off, and because this agent's
output is audit artifacts rather than repository mutations. Reverting both to `- [ ]` is listed as
a required remediation action in `remediation-inputs.2026-08-08T14-59.md`.

## Verdict

**NOT ACCEPTED.** 28 of 30 acceptance criteria are genuinely satisfied with verifiable evidence.
Two are not: the kickoff-artifact specification criterion fails on two independent counts, and the
kickoff-contract-module criterion is partial because the module's resume-boundary matcher is
narrower than the R5 wording it is meant to enforce. Both trace to a single root cause — the
producer and the consumer of the kickoff contract were verified separately and never against each
other — and both are corrected by the small, contained remediation set recorded in the remediation
inputs.
