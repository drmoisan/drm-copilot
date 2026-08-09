# Feature Audit: parallel-orchestrator-surface (#441)

**Audit Date:** 2026-08-08
**Feature Folder:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`
**Base Branch:** `epic/parallel-orchestration-integration`
**Head Branch:** `feature/parallel-orchestrator-surface-441` @ `41633ad5e867070853e3e4501c3457b6641d1efc`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review (full branch-vs-base)

---

## Scope and Baseline

- **Base branch:** `epic/parallel-orchestration-integration` (resolved to
  `origin/epic/parallel-orchestration-integration` @ `79091e65f987703bd55431e7c225c034cd862612`)
- **Head branch/commit:** `feature/parallel-orchestrator-surface-441` @
  `41633ad5e867070853e3e4501c3457b6641d1efc`
- **Merge base:** `ee0626e838109fe8d3fe3904fb4631c71879baa3`
- **Diff range audited:** `ee0626e838109fe8d3fe3904fb4631c71879baa3..41633ad5e867070853e3e4501c3457b6641d1efc`
  (33 files changed, 3976 insertions, 92 deletions, 1 commit)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (361 lines)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (503 lines)
  - Feature evidence: `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/**`
    (19 artifacts: 7 baseline, 5 other, 5 qa-gates, 2 regression-testing)
  - Additional evidence: direct inspection of all four delivered runtime/template files, all three
    bundled mirrors, all three added Python modules, and the two frozen epic files; plus the
    independently re-run toolchain and git verification commands recorded in Appendix B of
    `policy-audit.2026-08-08T18-12.md`
- **Feature folder used:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`.
  Selected because it is the only active feature folder whose numeric suffix matches the issue number
  in the branch name, and the only active folder with scoping-doc changes in the branch diff.
- **Requirements source:** `spec.md` (22 criteria) **and** `user-story.md` (11 criteria) — 33 total.
- **Work mode resolution note:** The marker is explicit and well-formed:
  `issue.md:10` reads `- Work Mode: full-feature`. Per the work-mode contract, `full-feature` resolves
  the AC sources to `spec.md` **and** `user-story.md`. `issue.md` carries its own
  `## Acceptance Criteria (early draft)` section with 6 unchecked items and a
  `## Test Conditions to Consider` section with 7 unchecked items; under `full-feature` neither is an
  authoritative AC source, so both were excluded from this evaluation and both were intentionally left
  unchecked. The `issue.md` draft items are a strict subset in substance of the `spec.md` criteria,
  which supersede them.
- **Scope note:** The PR context artifacts were **absent** at audit start and were regenerated against
  the supplied base branch before evaluation, per the PR-context refresh rule:
  `poetry run python -m scripts.dev_tools.pr_context.collector --base epic/parallel-orchestration-integration --head HEAD --repo-root .`
  Scope is the full branch diff. No caller narrowing was accepted; see
  `## Rejected Scope Narrowing` in `policy-audit.2026-08-08T18-12.md`. Every acceptance criterion below
  was verified against the checkout at head, not transcribed from the executor's evidence.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md` — primary source
  (22 checkbox criteria, `## Acceptance Criteria`, lines 516-589)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/user-story.md` — co-authoritative
  source (11 checkbox criteria, `## Acceptance Criteria`, lines 101-141)

Both sources use standard markdown checkbox format, so both support direct check-off.

### From `spec.md`

- S1. `.claude/agents/parallel-orchestrator.md` exists and its YAML frontmatter declares
  `name: parallel-orchestrator` (exact string), a `model`, a `tools` allowlist, a `skills` list
  containing `parallel-orchestrate`, and a `SubagentStop` hook invoking
  `validate-orchestrator-output.ps1` with
  `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json` and
  `-ArtifactType parallel-orchestrator-state`.
- S2. The agent frontmatter `tools` allowlist does not contain `Agent(pr-author)`.
- S3. The agent body contains the headings `## Skill`, `## Startup Protocol`, `## Invocation Origin`,
  `## Prepared-Run Execution`, `## Delegation Model`, `## Cohort Scheduling`,
  `## Checkpoint Persistence`, `## Documentation Maintenance`, and `## Completion Requirements`.
- S4. The agent's `## Invocation Origin` section names `/parallel-orchestrate` and `/parallel-run` as
  entry points and contains a prohibition on invoking `Agent(parallel-orchestrator)` from within an
  `orchestrator` run.
- S5. `.claude/skills/parallel-orchestrate/SKILL.md` exists and its frontmatter declares
  `context: fork` and `agent: parallel-orchestrator`.
- S6. The skill contains the F5-authored elements of R2.1 (the `# Parallel Orchestrate Skill` intro
  heading and the thirteen named `##` sections, items 2–15) in the exact order listed, verifiable by
  an ordered-heading assertion.
- S7. The skill's final three top-level headings are exactly `## Mutation Protocol (F6)`,
  `## Enforcement Hooks (F7)`, and `## Radius Drift Detection (F8)`, in that order, each appearing
  exactly once, each followed by a one-line reserved body stating that content is appended by that
  feature and must not be relocated.
- S8. The `## Parallel-Mode Kickoff Parameter` section contains the literal string
  `Parallel mode: true` and the literal string `PR base branch MUST be main`, states that the kickoff
  prompt never carries `Preparation mode: true` or `Epic mode: true`, and contains no instruction for
  the child to merge its own PR (no occurrence of `gh pr merge` within that section).
- S9. The `## Cohort Barrier and Max-Concurrency Slot Filling` section states that cohort `N+1`
  launches only after every cohort-`N` item is `merged` or `worktree_removed`, and contains the token
  `max_concurrency` and the phrase `ascending item-key order`.
- S10. The `## Per-Item Merge to Main (Merge-on-Green)` section states that the
  `parallel-orchestrator` executes `gh pr merge --merge` against `main` after durably confirming CI
  green, and states that `.claude/skills/orchestrate/SKILL.md` is not modified by this feature.
- S11. The `## Per-Item Merge-Conflict Handling` section maps the exhausted remediation loop to
  `blocked_ci_loop_limit`, states the shared remediation cap of 3, and contains a hand-off sentence
  naming F8 for drift recording, quiesce, recompute, and requeue.
- S12. The `## Documentation Maintenance Boundaries` section states that `parallel-status.md` is
  generated and never hand-authored, states it is never the source of the cohort table, and lists
  regeneration boundaries including item transitions, cohort transitions, `recolor_generation`
  increments, `mutations[]` appends, and `drift_events[]` appends.
- S13. The `## Parallel-Level Checkpoint` section enumerates all eight §12 `merge_status` values
  (`not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`, `worktree_removed`,
  `blocked_drift`, `blocked_ci_loop_limit`) and states that F5 never writes `blocked_drift`,
  `conflict_edges[]`, `mutations[]`, or `drift_events[]`.
- S14. The `## Completion Requirements` section defines mode-dependent completion: `closed` fires when
  every non-withdrawn item is `merged` or `worktree_removed`; `open` terminates only via
  `/parallel-close`.
- S15. The delivered skill text names both `EPIC_MERGE_GATE_BLOCKED` and
  `EPIC_WORKTREE_REMOVAL_BLOCKED` as F7-dependency block conditions that prevent end-to-end execution
  until F7 lands.
- S16. `.claude/skills/parallel-run/SKILL.md` exists, its frontmatter declares `context: fork` and
  `agent: parallel-orchestrator`, its discovery step STOPs with an instruction naming `/parallel-plan`
  when no kickoff artifact is found, and it states that items resume at atomic execution from their
  committed `plan-path`.
- S17. `docs/features/templates/parallel/parallel-status.md` exists and begins with an HTML-comment
  generated-file banner stating the file is generated and must not be hand-authored.
- S18. `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` exists and passes,
  asserting the structural conditions above including content-hash pinning of
  `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`.
- S19. None of the three delivered runtime files (`parallel-orchestrator.md`,
  `parallel-orchestrate/SKILL.md`, `parallel-run/SKILL.md`) contains any of the prescriptive literals
  `Epic mode: true`, `--base epic/`, or `integration-to-main`.
- S20. `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` are
  byte-identical to their pre-feature state (empty `git diff` for both paths over the feature branch).
- S21. `.claude/skills/orchestrate/SKILL.md` is byte-identical to its pre-feature state (empty
  `git diff` for that path over the feature branch).
- S22. The feature branch diff contains no changes under `.claude/hooks/` and no change to
  `.claude/settings.json`.

### From `user-story.md`

- U1. Invoking `/parallel-run` reaches the parallel execution agent:
  `.claude/skills/parallel-run/SKILL.md` exists and its frontmatter declares `context: fork` and
  `agent: parallel-orchestrator`.
- U2. An unprepared run stops with actionable guidance: the `parallel-run` procedure contains a STOP
  path, taken when no kickoff artifact is found at the parallel home, whose text names
  `/parallel-plan`.
- U3. Direct invocation without the entry point is available:
  `.claude/skills/parallel-orchestrate/SKILL.md` exists and its frontmatter declares an argument hint
  accepting the parallel manifest path or slug.
- U4. Launched items resume rather than re-plan: the delivered `parallel-run` and
  `parallel-orchestrate` skill text both state that items resume at atomic execution from their
  committed `plan-path` rather than re-running promotion, research, or planning.
- U5. Every child launch is identifiable as a parallel child: the
  `## Parallel-Mode Kickoff Parameter` section of `parallel-orchestrate/SKILL.md` contains the literal
  marker `Parallel mode: true` and requires the item's `docs/features/active/<basename>` folder path
  and canonical issue number in the kickoff prompt.
- U6. Concurrency never exceeds the configured cap: the skill text states that `max_concurrency`
  bounds simultaneous in-flight items independently of cohort size and that slots fill in
  `ascending item-key order`.
- U7. The operator can read run progress from one document: the skill's
  `## Documentation Maintenance Boundaries` section requires the `parallel-status.md` header fields
  `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`, `recolor_generation`, and
  `last_updated`, an item table with a cohort column, and a cohort table carrying `generation`.
- U8. Each item ships independently: the three delivered runtime files contain no instruction to
  create an integration branch or a final integration PR — none contains the literals
  `Epic mode: true`, `--base epic/`, or `integration-to-main`.
- U9. An interrupted run resumes: the agent's `## Startup Protocol` section requires reading
  `artifacts/orchestration/parallel-orchestrator-state.json` and re-deriving state via
  `git worktree list --porcelain`, `git branch`, and `gh pr view`.
- U10. Open-mode runs never complete silently: the skill's `## Completion Requirements` section states
  that `open` mode has no automatic completion and terminates only via `/parallel-close`, while
  `closed` mode completes when every non-withdrawn item is `merged` or `worktree_removed`.
- U11. The pre-F7 limitation is discoverable by the operator: the delivered skill text names
  `EPIC_MERGE_GATE_BLOCKED` and `EPIC_WORKTREE_REMOVAL_BLOCKED` as the block conditions a live run
  encounters until F7 lands.

---

## Acceptance Criteria Evaluation

### From `spec.md`

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| S1 | Agent frontmatter identity + `SubagentStop` hook | **PASS** | `.claude/agents/parallel-orchestrator.md:2` `name: parallel-orchestrator`; `:3` `model: opus`; `:5-17` 12-entry `tools` allowlist; `:18-24` `skills` includes `parallel-orchestrate` at line 20; `:26-31` `SubagentStop` matcher `parallel-orchestrator` with command carrying `.claude/hooks/validate-orchestrator-output.ps1`, `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json`, and `-ArtifactType parallel-orchestrator-state`. | `poetry run pytest ...test_parallel_orchestrator_surface_contracts.py -q` (tests `test_agent_frontmatter_declares_parallel_orchestrator_identity`, `test_agent_subagent_stop_hook_targets_parallel_checkpoint`) | Also confirmed by direct file read. All five required frontmatter elements present. |
| S2 | `tools` allowlist excludes `Agent(pr-author)` | **PASS** | Allowlist (lines 5-17) contains `Agent(orchestrator)` and no `pr-author` entry of any form. | test `test_agent_tools_allowlist_excludes_pr_author_channel` (asserts no entry contains the substring `pr-author`, which is stricter than the literal) | Rationale recorded in the file at lines 143-145: per-item PRs are authored inside each child run. |
| S3 | Agent body carries the nine required headings | **PASS** | Headings at lines 56, 67, 86, 103, 126, 149, 171, 191, 204 — exactly the nine required, in the listed order, with no extra `##` heading. | test `test_agent_body_contains_exactly_the_nine_required_headings` (asserts set equality against `AGENT_HEADINGS`, so an extra heading fails) | Exact-set assertion is stronger than the criterion's "contains". |
| S4 | `## Invocation Origin` names both entry points and prohibits nesting | **PASS** | Lines 88-90 name `/parallel-orchestrate <parallel-manifest-path>` and `/parallel-run <parallel-slug>`; lines 92-94 state "Do not invoke `Agent(parallel-orchestrator)` from within an `orchestrator` run" with the reason (it would nest `orchestrator` inside its own delegation chain); lines 96-101 record that mechanical enforcement is F7 scope and the prohibition is therefore documented but unenforced. | Direct file read of `.claude/agents/parallel-orchestrator.md:86-101` | Not asserted by a dedicated test; verified by inspection. The honest disclosure that the prohibition is currently unenforced exceeds the criterion. |
| S5 | Procedure skill frontmatter `context: fork`, `agent: parallel-orchestrator` | **PASS** | `.claude/skills/parallel-orchestrate/SKILL.md:5` `context: fork`; `:6` `agent: parallel-orchestrator`. | test `test_skill_frontmatter_forks_the_parallel_orchestrator_agent[relative_path0]` | — |
| S6 | Intro heading + thirteen `##` sections in exact R2.1 order | **PASS** | `# Parallel Orchestrate Skill` at line 9, preceding `## Prerequisites` at line 37. The thirteen sections follow at lines 37, 46, 79, 103, 143, 168, 209, 236, 271, 304, 322, 359, 401 in exactly the R2.1 order: Prerequisites, Parallel Manifest Consumption, Cohort Consumption and Ordering, Cohort Barrier and Max-Concurrency Slot Filling, Per-Item Branch and Worktree Lifecycle, Parallel-Mode Kickoff Parameter, Model Selection, Per-Item Merge to Main (Merge-on-Green), Per-Item Merge-Conflict Handling, Worktree Cleanup, Documentation Maintenance Boundaries, Parallel-Level Checkpoint, Completion Requirements. | tests `test_orchestrate_skill_intro_heading_precedes_prerequisites`, `test_orchestrate_skill_first_thirteen_headings_match_required_layout` (asserts `headings[:13] == SKILL_HEADINGS` and total `== 16`) | Ordered-heading assertion is exactly the verification vehicle the criterion names. |
| S7 | Final three headings are the reserved wave-4 sections, once each, with one-line bodies | **PASS** | Lines 426, 430, 434: `## Mutation Protocol (F6)`, `## Enforcement Hooks (F7)`, `## Radius Drift Detection (F8)`. Bodies at 428, 432, 436 are exactly `Reserved for F6/F7/F8; content is appended by that feature and must not be relocated.` | tests `test_orchestrate_skill_reserved_wave_four_sections_close_the_file` (position + `count == 1` each), `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` (exact whitespace-collapsed body equality) | Body equality is asserted exactly, not by substring, so no wave-4 content can have been added early. |
| S8 | Kickoff section: two literals present; states never carries `Preparation mode: true` / `Epic mode: true`; no `gh pr merge` in section | **PASS** (with a documented spec self-inconsistency) | `Parallel mode: true` at line 175 and again at 177; `PR base branch MUST be main` at 175 and 178. Line 196: "It never carries `Preparation mode: true`." Lines 198-202: "It never carries the epic-mode marker line that `.claude/skills/epic-orchestrate/SKILL.md` emits — the marker whose text is `Epic mode` followed by the value `true`". `grep -c "gh pr merge"` over the file returns 3, all three outside this section (lines 253, 258, 277). | tests `...[kickoff-marker-and-main-base]`, `...[kickoff-never-carries-foreign-markers]`, `test_kickoff_section_carries_no_child_merge_instruction` (section-scoped, extracted by heading boundary) | The `Epic mode: true` obligation is stated by an exact paraphrase rather than by the literal string, because criterion S19 forbids that literal from appearing in any delivered runtime file. Read literally, S8 and S19 are mutually exclusive. The implementation resolved the conflict in favour of S19, the stricter negative obligation, and made the resolution explicit: the paraphrase is pinned in a named test constant carrying a comment that states why (`parallel_orchestrator_surface_expectations.py:108-114`), and the forbidden literals are held as test data so no delivered file must carry them (`..._test_support.py:53-59`). Graded PASS because S8's semantic obligation — that the section state the negative — is fully satisfied. Recommendation to reword spec S8 is recorded as an Info finding in `code-review.2026-08-08T18-12.md`. |
| S9 | Cohort barrier + `max_concurrency` + ascending item-key order | **PASS** | Lines 109-114: "Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`", with durable confirmation from the three git/gh commands and the note that a blocked item holds the barrier. Lines 116-124 carry `max_concurrency` and "Fill slots in ascending item-key order, keyed on `issue_num`". | test `...[cohort-barrier-and-slot-filling-order]` | Section also names the F7 Layer 1 / Layer 2 enforcement deliverables without shipping them. |
| S10 | Merge-on-green: parent executes `gh pr merge --merge` against `main` after durable CI confirmation; states `orchestrate/SKILL.md` unmodified | **PASS** | Line 253: "Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`." Line 250: durable confirmation with `gh pr view --json state,mergedAt,headRefOid` (and `gh pr checks`), "never from an in-memory completion notification", then `merge_status: ci_green`. Line 239: "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**." | test `...[merge-on-green-parent-executes-merge]` | The section additionally records that no `parallel_merge` object and no extra PR Creation Gate condition exist in the child contract. |
| S11 | Conflict handling maps loop exhaustion to `blocked_ci_loop_limit`; cap of 3; F8 hand-off sentence | **PASS** | Line 288: "with the cap of 3, unmodified." Line 294: "the parent records the terminal `merge_status: blocked_ci_loop_limit`". Lines 299-302: the boundary sentence naming F8 for "drift recording in `drift_events[]`, quiesce of admission, conflict recomputation against the observed radius, and requeue of the later-started item". | test `...[merge-conflict-exhaustion-and-f8-handoff]` | All four F8 hand-off elements named, matching spec R2.9 item 5. |
| S12 | Documentation boundaries: generated/never hand-authored; never source of cohort table; regeneration boundary list | **PASS** | Lines 324-327: "is regenerated in full, is never hand-authored, and is never treated as an input. It is never the source of the cohort table and never the source of the schedule". Lines 346-354 list all seven boundaries: run kickoff; every item `state` or `merge_status` transition; every cohort transition (`current_cohort` increment); every `recolor_generation` increment; every append to `mutations[]`; every append to `drift_events[]`; run completion (`closed`) or close (`open`). | tests `...[boundaries-generated-projection-rules]`, `...[boundaries-regeneration-list]` (7 pinned fragments) | Lines 356-357 record why the `mutations[]`/`drift_events[]` boundaries are defined now: so F6/F8 need no amendment. |
| S13 | Checkpoint section enumerates all eight `merge_status` values and the four never-written arrays | **PASS** | Lines 375-377 enumerate all eight members and state the enum "has exactly eight members", plus "An absent `merge_status` is treated as `not_started`." Lines 385-388: "Never written by this feature: `blocked_drift` … `conflict_edges[]` … `mutations[]` … `drift_events[]`". | tests `...[checkpoint-eight-merge-status-values]`, `test_checkpoint_section_states_the_four_arrays_never_written` (splits on the literal "Never written by this feature:" before matching, so a fragment elsewhere in the section does not satisfy it) | The scoped-split assertion is stronger than a section-wide substring match. |
| S14 | Mode-dependent completion | **PASS** | Lines 406-416: `closed` mode requires every non-withdrawn item at `merged` or `worktree_removed` (durably confirmed), final `parallel-status.md` regeneration, `require_complete` validation, and per-item AC check-off. Lines 418-420: "In `open` mode there is no automatic completion … terminates only via `/parallel-close`". Lines 422-424: "No completion condition involves a run-level pull request." | test `...[completion-both-run-modes]` | — |
| S15 | Skill names both F7 block reasons | **PASS** | `EPIC_MERGE_GATE_BLOCKED` at line 260 with the mechanism (project-wide `PreToolUse` Bash-matcher hook denying `gh pr merge --merge` absent an epic-shaped checkpoint). `EPIC_WORKTREE_REMOVAL_BLOCKED` at line 316 with its mechanism and the conjunctive-denial note. | test `test_skill_names_both_f7_dependency_block_reasons` | Lines 262-264 state the consequence plainly: "the parallel surface is not executable end-to-end before F7 lands. That limitation is documented, not worked around." |
| S16 | `parallel-run` skill: frontmatter, STOP naming `/parallel-plan`, plan-path resume | **PASS** | `.claude/skills/parallel-run/SKILL.md:5-6` `context: fork` / `agent: parallel-orchestrator`. Lines 28-31: "STOP without delegating anything when that path does not exist … the user must run `/parallel-plan` first", plus explicit prohibitions on synthesizing a kickoff prompt, falling back to the planner's working copy, or launching a partial run. Lines 32-38: items "resume at atomic execution from that item's committed `plan-path` rather than re-running promotion, research, or planning". | tests `test_skill_frontmatter_forks_the_parallel_orchestrator_agent[relative_path1]`, `test_run_skill_argument_hint_is_the_parallel_slug`, `test_run_skill_stop_path_names_parallel_plan_and_plan_path_resume` (section-scoped to `## Procedure`) | — |
| S17 | Status template exists and opens with a generated-file banner | **PASS** | `docs/features/templates/parallel/parallel-status.md:1-18` is an HTML comment opening with `GENERATED FILE — DO NOT HAND-AUTHOR.` and naming the regeneration boundaries, the authoritative sources, and the overwrite consequence. File begins with `<!--` at byte 0. | test `test_status_template_begins_with_generated_file_banner` (asserts `startswith("<!--")` and both banner fragments) | Template also realises all six header fields, the item table with `cohort_index`, the cohort table with `generation`, and the three projection sections. |
| S18 | Contract test file exists and passes, including content-hash pinning of the two frozen epic files | **PASS** | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` exists (457 lines, 36 tests). `test_frozen_epic_surface_matches_pinned_baseline_digest` is parametrized over both frozen paths with pinned digests `f4e3589a…` (epic-orchestrator.md) and `3c2e38bd…` (epic-orchestrate/SKILL.md); both match. | `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q` → `36 passed in 0.07s`; full suite `poetry run pytest --cov --cov-branch --cov-report=term-missing` → `3004 passed in 10.61s` | Test count reconciles exactly: 2968 baseline + 36 = 3004. |
| S19 | No prescriptive epic literal in any of the three delivered runtime files | **PASS** | `grep -n "Epic mode: true\|--base epic/\|integration-to-main"` across all three files returns no match. | `grep -n "Epic mode: true\|--base epic/\|integration-to-main" .claude/agents/parallel-orchestrator.md .claude/skills/parallel-orchestrate/SKILL.md .claude/skills/parallel-run/SKILL.md`; test `test_delivered_runtime_files_carry_no_prescriptive_epic_literal[×3]` | Verified twice: independently by grep and by the parametrized test, which asserts each literal separately so a failure names the one that leaked. |
| S20 | Both frozen epic files byte-identical to pre-feature state | **PASS** | `git diff --stat` over both paths across the full branch range produces empty output. Additionally, the two in-process SHA-256 pins match. | `git diff --stat ee0626e838109fe8d3fe3904fb4631c71879baa3..41633ad5 -- .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md` → empty | Two independent mechanisms (git diff and content hash) agree. |
| S21 | `.claude/skills/orchestrate/SKILL.md` byte-identical to pre-feature state | **PASS** | `git diff --stat` over that path across the full branch range produces empty output. | `git diff --stat ee0626e838109fe8d3fe3904fb4631c71879baa3..41633ad5 -- .claude/skills/orchestrate/SKILL.md` → empty | The child contract is provably unchanged, which is the premise the merge-on-green section relies on. |
| S22 | No change under `.claude/hooks/` and no change to `.claude/settings.json` | **PASS** | `git diff --stat` over both paths across the full branch range produces empty output. | `git diff --stat ee0626e838109fe8d3fe3904fb4631c71879baa3..41633ad5 -- .claude/hooks/ .claude/settings.json` → empty | Corroborated by `evidence/other/no-hook-or-settings-change.2026-08-08T17-47.md` and by the branch-wide `git diff --name-status` (33 paths, none under `.claude/hooks/`). |

### From `user-story.md`

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| U1 | `/parallel-run` reaches the parallel execution agent | **PASS** | `.claude/skills/parallel-run/SKILL.md` exists; `:5` `context: fork`; `:6` `agent: parallel-orchestrator`. | test `test_skill_frontmatter_forks_the_parallel_orchestrator_agent[relative_path1]` | Same evidence basis as S16. |
| U2 | Unprepared run STOPs with guidance naming `/parallel-plan` | **PASS** | `parallel-run/SKILL.md:28-31`: STOP taken when `docs/features/parallel/<parallel-slug>/parallel-kickoff.md` does not exist, with "the user must run `/parallel-plan` first (or, for a run whose manifest was authored manually, invoke `/parallel-orchestrate <manifest-path>` directly)". | test `test_run_skill_stop_path_names_parallel_plan_and_plan_path_resume` | The STOP branch additionally forbids three specific workarounds, exceeding the criterion. |
| U3 | Procedure skill argument hint accepts manifest path or slug | **PASS** | `parallel-orchestrate/SKILL.md:4` `argument-hint: "[parallel-manifest-path \| parallel-slug]"`. | test `test_orchestrate_skill_argument_hint_accepts_manifest_path_or_slug` (asserts both `parallel-manifest-path` and `parallel-slug` appear in the hint) | — |
| U4 | Both skills state items resume at atomic execution from the committed `plan-path` | **PASS** | `parallel-orchestrate/SKILL.md:184-187` (kickoff element 4): "resume at atomic execution from that plan rather than re-running promotion, research, or planning", plus the note that the prepared folder and approved plan are already committed and preflight-clear. `parallel-run/SKILL.md:32-38`: "resumes at atomic execution from that item's committed `plan-path` rather than re-running promotion, research, or planning", plus "Feature-document authoring and preflight clearance are likewise not repeated". Also `.claude/agents/parallel-orchestrator.md:115-121`. | tests `...[kickoff-resume-at-plan-path]`, `test_run_skill_stop_path_names_parallel_plan_and_plan_path_resume` | Stated in all three runtime files, one more than the criterion requires. |
| U5 | Kickoff carries the literal marker plus the folder path and canonical issue number | **PASS** | `parallel-orchestrate/SKILL.md:175` carries the full marker line including `Parallel mode: true`; `:180-182` requires "The item's active feature folder path, written literally as `docs/features/active/<basename>`" and explains that F7's Layer 1 hook resolves the target item by scanning for exactly that path shape; `:183` "The canonical issue number line, which is the item key." | tests `...[kickoff-marker-and-main-base]`, `...[kickoff-feature-folder-and-issue-number]` | Line 177 states the token "must appear exactly", which is the F7 matching contract. |
| U6 | `max_concurrency` bounds in-flight items independently of cohort size; ascending item-key slot order | **PASS** | `parallel-orchestrate/SKILL.md:116-124`: "`max_concurrency` caps the number of simultaneously in-flight items independently of cohort size: a cohort of twelve items executes at most `max_concurrency` items at a time. Fill slots in ascending item-key order, keyed on `issue_num`, and refill each freed slot with the next unstarted item of the current cohort in that same ascending item-key order." | test `...[cohort-barrier-and-slot-filling-order]` | Lines 121-124 additionally bind the batching to the pure function `compute_concurrency_batches`, which exists at `scripts/dev_tools/parallel_cohort_computation.py:419` (verified) and sorts keys itself so determinism does not depend on caller ordering. |
| U7 | Status document requirements: six header fields, item table with cohort column, cohort table with `generation` | **PASS** | `parallel-orchestrate/SKILL.md:330-331` prescribes exactly the six header fields; `:333-335` the item table with "cohort index" and the note that "The cohort column takes the place of the epic status document's wave column"; `:337-338` the cohort table as a projection of `cohorts[] { index, generation, item_keys[] }`. The shipped template realises all of it. | tests `test_seam_status_template_realises_header_fields_prescribed_by_skill` (asserts exactly 6 parsed fields, each present in the template), `test_seam_status_template_realises_cohort_columns_prescribed_by_skill`, `test_seam_status_template_realises_projections_prescribed_by_skill` (asserts exactly 3), `...[boundaries-generated-projection-rules]` | The three seam tests parse the prescribed names out of the producer at run time rather than restating them, so a one-sided rename between skill and template fails. This is stronger verification than the criterion requires. |
| U8 | Three delivered runtime files carry no integration-branch or final-PR instruction | **PASS** | No match for any of the three forbidden literals in any of the three files. Positive corroboration that the absence is structural rather than accidental: `parallel-orchestrate/SKILL.md:163-166` ("No integration branch is created, fetched, pushed, or referenced at any point in this lifecycle … its absence is structural rather than an omission"); `.claude/agents/parallel-orchestrator.md:42-47`; `parallel-run/SKILL.md:54-56`. | `grep -n "Epic mode: true\|--base epic/\|integration-to-main" <3 files>` → no match; test `test_delivered_runtime_files_carry_no_prescriptive_epic_literal[×3]` | Same evidence basis as S19. |
| U9 | `## Startup Protocol` requires reading the checkpoint and re-deriving via the three commands | **PASS** | `.claude/agents/parallel-orchestrator.md:74-82`: step 3 reads `artifacts/orchestration/parallel-orchestrator-state.json`; step 4 requires re-deriving durable ground truth from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`, states "The checkpoint is a cache of durable state, not the source of truth; where it disagrees with those three commands, the commands win and the checkpoint is rewritten from them", and adds "Never resume from in-memory notifications." | Direct file read of `.claude/agents/parallel-orchestrator.md:67-84` | Not covered by a dedicated test; verified by inspection. Matches the Cache Doctrine in `.claude/rules/parallel-orchestration.md`. `parallel-run/SKILL.md:39-43` repeats the resume obligation. |
| U10 | Open mode has no automatic completion and terminates only via `/parallel-close`; closed mode completes on per-item terminals | **PASS** | `parallel-orchestrate/SKILL.md:406-420`, as evidenced for S14. Also `.claude/agents/parallel-orchestrator.md:204-225`, including "Do not synthesize a completion condition for an `open`-mode run." | test `...[completion-both-run-modes]` | Stated in both the skill and the agent persona. |
| U11 | Skill text names both F7 block conditions as the pre-F7 limitation | **PASS** | `parallel-orchestrate/SKILL.md:258-264` and `:312-320`, as evidenced for S15. | test `test_skill_names_both_f7_dependency_block_reasons` | Each block reason is stated at the step it affects, with its mechanism, rather than once in a footnote — the operator encounters it where it matters. |

---

## Summary

**Overall Feature Readiness:** PASS

All 33 acceptance criteria across both authoritative source files evaluate to PASS on evidence
verified directly against the checkout at head. No criterion is PARTIAL, FAIL, or UNVERIFIED.

**Criteria summary:**
- **PASS:** 33 criteria (22 from `spec.md`, 11 from `user-story.md`)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Verification breadth.** 30 of the 33 criteria are asserted by at least one of the 36 automated
contract tests. The three that are not — S4 and U9 (agent-body prose obligations) and the git-diff
emptiness portions of S20–S22 — were verified by direct file read and by `git diff --stat` commands
recorded above; S20 additionally carries two in-process SHA-256 content pins, so the frozen-surface
claim rests on two independent mechanisms.

**Top gaps preventing PASS:**

1. **None.** No acceptance criterion is unmet.

**Findings that do not affect any acceptance criterion.** Two Major findings are recorded in
`code-review.2026-08-08T18-12.md` (CR-01, CR-02) and routed through
`remediation-inputs.2026-08-08T18-12.md`. Both concern consistency between the delivered persona's
`tools` allowlist and two procedures the delivered skill text prescribes: the parent-side write of an
item's `remediation-inputs.<timestamp>.md` under `docs/features/active/`, and the manifest-validation
library call. Neither is covered by any acceptance criterion — no criterion addresses
allowlist/procedure executability — so neither changes an AC verdict. They are nonetheless internal
contradictions among this feature's own deliverables and are recommended for correction before merge.
This audit's PASS verdict is scoped to the acceptance criteria, as its role requires; the merge
recommendation belongs to the code review, which records **Conditional Go**.

**One spec-level self-inconsistency worth recording.** Criteria S8 and S19 are mutually exclusive if
read literally: S8 asks the kickoff section to state that the prompt never carries the literal
`Epic mode: true`, while S19 forbids that literal from appearing anywhere in the delivered runtime
files. The implementation resolved this correctly in favour of S19, the stricter negative obligation,
and made the resolution explicit rather than implicit — the skill states the obligation as an exact
paraphrase and the test pins that paraphrase in a named constant carrying a comment explaining why.
S8 is graded PASS because its semantic obligation is satisfied. A wording correction to spec S8 is
recommended so a future reader does not mistake the paraphrase for a shortfall.

**Recommended follow-up verification steps:**

1. Resolve CR-01 and CR-02, then re-run the contract suite plus the full Python toolchain. Consider
   adding a contract test asserting that every write target the skill prescribes is covered by a
   persona `Write` grant, which would close this class of gap structurally rather than by review.
2. Re-verify the F7 block-condition names once F7 lands, since `EPIC_MERGE_GATE_BLOCKED` and
   `EPIC_WORKTREE_REMOVAL_BLOCKED` are expected to be superseded by parallel-specific reasons; S15 and
   U11 will need re-evaluation at that point.
3. Reword spec criterion S8 to state its obligation semantically, and record the intended lifetime of
   the two frozen-surface SHA-256 pins (code-review finding CR-03) before this feature's folder is
   archived.
4. Track the pre-existing Pester test-isolation defect (`enforce-pr-author-skill.Tests.ps1` reading
   the real gitignored checkpoint) as a separate potential-bug entry. It is out of this branch's diff
   and affects no criterion here.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are
  represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

**No source-file checkbox change was made by this audit, and none was required.** All 22 `spec.md`
criteria and all 11 `user-story.md` criteria were already marked `- [x]` at head, having been checked
off by the executor as each corresponding plan task passed verification. This audit independently
re-verified every one of the 33 and found each check-off justified by evidence; no criterion was found
checked without support, so no check-off needed to be reverted.

`issue.md` was deliberately left untouched. Its `## Acceptance Criteria (early draft)` section
(6 unchecked items) and `## Test Conditions to Consider` section (7 unchecked items) are not
authoritative AC sources under `full-feature` work mode, and the no-phantom-criteria rule forbids a
reviewer from adding, rewriting, or repurposing source-file criteria. The draft items are superseded
in substance by the `spec.md` criteria.

### AC Status Summary

- Source: `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md` and
  `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/user-story.md`
- Total AC items: 33
- Checked off (delivered): 33
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---|---|---|---|
| `spec.md` | 22 | 22 | 0 | Checkbox-backed; authoritative under `full-feature`. All items already `[x]` at head; all independently re-verified as PASS by this audit. |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed; co-authoritative under `full-feature`. All items already `[x]` at head; all independently re-verified as PASS by this audit. |
| `issue.md` | 13 (6 draft AC + 7 test conditions) | 0 | 13 | **Not authoritative** under `full-feature`. Intentionally left unchecked; superseded in substance by `spec.md`. |
