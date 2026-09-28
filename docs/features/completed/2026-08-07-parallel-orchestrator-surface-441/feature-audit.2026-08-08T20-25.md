# Feature Audit: Parallel Orchestrator Surface (#441)

- **Timestamp:** 2026-08-08T20-25
- **Feature folder:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`
- **Issue:** #441
- **Review type:** re-audit after remediation cycle 1 (prior feature audit `feature-audit.2026-08-08T18-12.md`)

## Scope and Baseline

- **Base branch (resolved):** `epic/parallel-orchestration-integration`
- **Merge base:** `ee0626e838109fe8d3fe3904fb4631c71879baa3`, independently re-derived with `git merge-base HEAD epic/parallel-orchestration-integration`
- **Feature branch head:** `feature/parallel-orchestrator-surface-441` @ `aa987c1202da3c88807f6bfefc6ba4279468b06c`
- **Commits in range:** 2 — `41633ad5` (feature) and `aa987c12` (remediation cycle 1)
- **Diff versus base:** 74 files changed, 8596 insertions, 97 deletions
- **Audit scope:** the full branch diff versus the resolved base branch. No caller narrowing was attempted or accepted.

**Work mode and acceptance-criteria sources.** The persisted marker at `issue.md:10` reads `- Work Mode: full-feature`. Per the work-mode contract, the authoritative acceptance-criteria sources are therefore both `spec.md` (`## Acceptance Criteria` at line 525, 22 criteria) and `user-story.md` (`## Acceptance Criteria` at line 101, 11 criteria) — 33 criteria in total. `issue.md` carries a section headed `## Acceptance Criteria (early draft)`, which is explicitly a draft and is **not** an authoritative source under `full-feature`; its items were not evaluated as criteria.

**Baseline-relative framing.** Every criterion below was evaluated against the delivered state at `aa987c12`, not against the executor's evidence artifacts. Where a criterion asserts that a pre-existing file is unchanged, the evaluation is an empty `git diff` against the merge base. Where a criterion asserts document structure, the evaluation is a direct `grep`, `sed`, or hash of the delivered file.

**Stale-input note.** `artifacts/pr_context.summary.txt` records the head as `41633ad5`, the first of the two branch commits; the remediation commit `aa987c12` is not reflected in its head field. Evaluation was therefore performed against live `git` state at `aa987c12`. The summary and appendix were used as narrative context only.

## Acceptance Criteria Inventory

### Source: `spec.md` (22 criteria)

| ID | Criterion (abbreviated) |
| --- | --- |
| SP-01 | `parallel-orchestrator.md` exists; frontmatter declares `name: parallel-orchestrator`, a `model`, a `tools` allowlist, `skills` containing `parallel-orchestrate`, and a `SubagentStop` hook invoking `validate-orchestrator-output.ps1` with the parallel checkpoint path and `-ArtifactType parallel-orchestrator-state`. |
| SP-02 | The agent frontmatter `tools` allowlist does not contain `Agent(pr-author)`. |
| SP-03 | The agent body contains the 9 headings `## Skill` through `## Completion Requirements`. |
| SP-04 | `## Invocation Origin` names `/parallel-orchestrate` and `/parallel-run` and prohibits invoking `Agent(parallel-orchestrator)` from within an `orchestrator` run. |
| SP-05 | `parallel-orchestrate/SKILL.md` exists; frontmatter declares `context: fork` and `agent: parallel-orchestrator`. |
| SP-06 | The skill contains the `# Parallel Orchestrate Skill` intro heading and the thirteen named `##` sections in exact R2.1 order. |
| SP-07 | The skill's final three top-level headings are exactly the F6/F7/F8 reserved headings, in that order, each once, each with a one-line reserved body. |
| SP-08 | `## Parallel-Mode Kickoff Parameter` contains `Parallel mode: true` and `PR base branch MUST be main`, states the prompt never carries `Preparation mode: true` or `Epic mode: true`, and contains no `gh pr merge` within that section. |
| SP-09 | `## Cohort Barrier and Max-Concurrency Slot Filling` states cohort `N+1` launches only after every cohort-`N` item is `merged` or `worktree_removed`, and contains `max_concurrency` and `ascending item-key order`. |
| SP-10 | `## Per-Item Merge to Main (Merge-on-Green)` states the orchestrator executes `gh pr merge --merge` against `main` after durably confirming CI green, and that `orchestrate/SKILL.md` is unmodified. |
| SP-11 | `## Per-Item Merge-Conflict Handling` maps the exhausted remediation loop to `blocked_ci_loop_limit`, states the shared cap of 3, and hands off to F8 for drift recording, quiesce, recompute, requeue. |
| SP-12 | `## Documentation Maintenance Boundaries` states `parallel-status.md` is generated and never hand-authored, never the source of the cohort table, and lists the regeneration boundaries. |
| SP-13 | `## Parallel-Level Checkpoint` enumerates all eight `merge_status` values and states F5 never writes `blocked_drift`, `conflict_edges[]`, `mutations[]`, or `drift_events[]`. |
| SP-14 | `## Completion Requirements` defines mode-dependent completion: `closed` on all non-withdrawn items terminal; `open` only via `/parallel-close`. |
| SP-15 | The skill text names both `EPIC_MERGE_GATE_BLOCKED` and `EPIC_WORKTREE_REMOVAL_BLOCKED` as F7-dependency block conditions. |
| SP-16 | `parallel-run/SKILL.md` exists with `context: fork`, `agent: parallel-orchestrator`, a STOP naming `/parallel-plan`, and states items resume at atomic execution from their committed `plan-path`. |
| SP-17 | `docs/features/templates/parallel/parallel-status.md` exists and begins with an HTML-comment generated-file banner. |
| SP-18 | `test_parallel_orchestrator_surface_contracts.py` exists and passes, including content-hash pinning of the two frozen epic files. |
| SP-19 | None of the three delivered runtime files contains `Epic mode: true`, `--base epic/`, or `integration-to-main`. |
| SP-20 | `epic-orchestrator.md` and `epic-orchestrate/SKILL.md` are byte-identical to their pre-feature state. |
| SP-21 | `orchestrate/SKILL.md` is byte-identical to its pre-feature state. |
| SP-22 | The branch diff contains no changes under `.claude/hooks/` and no change to `.claude/settings.json`. |

### Source: `user-story.md` (11 criteria)

| ID | Criterion (abbreviated) |
| --- | --- |
| US-01 | Invoking `/parallel-run` reaches the parallel execution agent: the skill exists with `context: fork` and `agent: parallel-orchestrator`. |
| US-02 | An unprepared run stops with actionable guidance: a STOP path taken when no kickoff artifact is found, whose text names `/parallel-plan`. |
| US-03 | Direct invocation is available: `parallel-orchestrate/SKILL.md` declares an argument hint accepting the manifest path or slug. |
| US-04 | Launched items resume rather than re-plan: both delivered skills state items resume at atomic execution from their committed `plan-path`. |
| US-05 | Every child launch is identifiable: the kickoff section contains `Parallel mode: true` and requires the item's `docs/features/active/<basename>` folder path and canonical issue number. |
| US-06 | Concurrency never exceeds the cap: `max_concurrency` bounds in-flight items independently of cohort size, and slots fill in `ascending item-key order`. |
| US-07 | One document shows run progress: the required `parallel-status.md` header fields, an item table with a cohort column, and a cohort table carrying `generation`. |
| US-08 | Each item ships independently: none of the three runtime files contains `Epic mode: true`, `--base epic/`, or `integration-to-main`. |
| US-09 | An interrupted run resumes: `## Startup Protocol` requires reading the parallel checkpoint and re-deriving state via `git worktree list --porcelain`, `git branch`, and `gh pr view`. |
| US-10 | Open-mode runs never complete silently: `open` has no automatic completion and terminates only via `/parallel-close`; `closed` completes on all non-withdrawn items terminal. |
| US-11 | The pre-F7 limitation is discoverable: the skill text names `EPIC_MERGE_GATE_BLOCKED` and `EPIC_WORKTREE_REMOVAL_BLOCKED`. |

## Acceptance Criteria Evaluation

### `spec.md`

| ID | Verdict | Evidence (reviewer-verified at `aa987c12`) |
| --- | --- | --- |
| SP-01 | PASS | `sed -n '1,40p' .claude/agents/parallel-orchestrator.md` shows `name: parallel-orchestrator`, `model: opus`, a 14-entry `tools` allowlist, `skills` including `parallel-orchestrate`, and a `SubagentStop` hook whose command is `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state`. |
| SP-02 | PASS | The `tools` allowlist contains `Agent(orchestrator)` and no `Agent(pr-author)` entry. Read directly from frontmatter. |
| SP-03 | PASS | `grep -n '^## '` returns exactly the 9 required headings in order at lines 58, 80, 99, 116, 139, 162, 184, 204, 217. |
| SP-04 | PASS | Asserted by the contract suite; `## Invocation Origin` at line 99 names both entry points and carries the prohibition. |
| SP-05 | PASS | `sed -n '1,10p' .claude/skills/parallel-orchestrate/SKILL.md` shows `context: fork` and `agent: parallel-orchestrator`. |
| SP-06 | PASS | `grep -n '^## '` returns 16 headings; the first 13 are `Prerequisites`, `Parallel Manifest Consumption`, `Cohort Consumption and Ordering`, `Cohort Barrier and Max-Concurrency Slot Filling`, `Per-Item Branch and Worktree Lifecycle`, `Parallel-Mode Kickoff Parameter`, `Model Selection`, `Per-Item Merge to Main (Merge-on-Green)`, `Per-Item Merge-Conflict Handling`, `Worktree Cleanup`, `Documentation Maintenance Boundaries`, `Parallel-Level Checkpoint`, `Completion Requirements`, in R2.1 order. Ordered-heading assertion in the contract suite passes. |
| SP-07 | PASS | The final three headings are `## Mutation Protocol (F6)` (435), `## Enforcement Hooks (F7)` (439), `## Radius Drift Detection (F8)` (443), in that order, each once, each followed by a one-line reserved body. |
| SP-08 | PASS | `Parallel mode: true` at line 179 and 181; `PR base branch MUST be main` at 179 and 182. Contract suite asserts the absence of `gh pr merge` within the section and the `Preparation mode`/`Epic mode` statement. |
| SP-09 | PASS | `ascending item-key order` at line 122 within the barrier section; `max_concurrency` present; barrier condition asserted by the contract suite. |
| SP-10 | PASS | Section at line 240; the merge-gate text and the `orchestrate/SKILL.md`-unmodified statement are asserted by the contract suite. Independently corroborated: `git diff` for `orchestrate/SKILL.md` is empty. |
| SP-11 | PASS | Section at line 275; read directly — the remediation cap of 3 is stated ("with the cap of 3, unmodified"), the exhausted loop maps to `blocked_ci_loop_limit`, and the F8 hand-off sentence is present. |
| SP-12 | PASS | Section at line 331, read directly: "is regenerated in full, is never hand-authored, and is never treated as an input. It is never the source of the cohort table", followed by seven enumerated regeneration boundaries including `mutations[]` and `drift_events[]` appends. |
| SP-13 | PASS | Section at line 368; all eight `merge_status` values and the F5 never-writes statement asserted by the contract suite. |
| SP-14 | PASS | Section at line 410; `/parallel-close` referenced at line 428 as the only `open`-mode termination, with `closed`-mode completion defined on terminal per-item states. |
| SP-15 | PASS | `EPIC_MERGE_GATE_BLOCKED` at line 264 and `EPIC_WORKTREE_REMOVAL_BLOCKED` at line 325, both framed as block reasons a live run encounters. |
| SP-16 | PASS | `sed -n '1,12p' .claude/skills/parallel-run/SKILL.md` shows `context: fork` and `agent: parallel-orchestrator`; the STOP path at lines 27-31 names `/parallel-plan` and forbids launching a partial run; line 35 states items resume at atomic execution from the committed `plan-path`. |
| SP-17 | PASS | `sed -n '1,4p' docs/features/templates/parallel/parallel-status.md` begins `<!--` / `GENERATED FILE — DO NOT HAND-AUTHOR.` |
| SP-18 | PASS | `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -q` returns 39 passed in 0.11s. The suite includes SHA-256 content-hash pinning of the two frozen epic files. |
| SP-19 | PASS | `grep -n -e 'Epic mode: true' -e 'integration-to-main' -e '--base epic/'` over the three files returns no matches (exit 1). |
| SP-20 | PASS | `git diff --stat ee0626e8 -- .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md` is empty. |
| SP-21 | PASS | `git diff --stat ee0626e8 -- .claude/skills/orchestrate/SKILL.md` is empty. |
| SP-22 | PASS | `git diff --stat ee0626e8 -- .claude/hooks .claude/settings.json` is empty. Corroborated by the committed-diff census, which shows zero `.ps1`/`.psm1`/`.psd1` and zero settings changes. |

### `user-story.md`

| ID | Verdict | Evidence (reviewer-verified at `aa987c12`) |
| --- | --- | --- |
| US-01 | PASS | Same evidence as SP-16: frontmatter declares `context: fork` and `agent: parallel-orchestrator`. |
| US-02 | PASS | `parallel-run/SKILL.md:27-31`: "STOP without delegating anything when that path does not exist... the user must run `/parallel-plan` first", plus "do not launch a partial run in place of the STOP". |
| US-03 | PASS | `parallel-orchestrate/SKILL.md` frontmatter declares `argument-hint: "[parallel-manifest-path | parallel-slug]"`, accepting either the manifest path or the slug. |
| US-04 | PASS | `parallel-run/SKILL.md:35` states each item "resumes at atomic execution from that item's committed `plan-path` rather than re-running" promotion/research/planning; the equivalent statement in `parallel-orchestrate/SKILL.md` is asserted by the contract suite. |
| US-05 | PASS | The kickoff prompt template at `parallel-orchestrate/SKILL.md:179` carries the literal `Parallel mode: true`, and line 181 states the token "must appear exactly: it is the marker F7's Layer 1 barrier hook matches on". The folder-path and issue-number requirements are asserted by the contract suite. |
| US-06 | PASS | `parallel-orchestrate/SKILL.md:122`: "Fill slots in ascending item-key order, keyed on `issue_num`", within the `## Cohort Barrier and Max-Concurrency Slot Filling` section that bounds in-flight items by `max_concurrency` independently of cohort size. |
| US-07 | PASS | `parallel-orchestrate/SKILL.md:339-340` lists exactly the six required header fields `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`, `recolor_generation`, `last_updated`. The item table specification carries "cohort index" and states "The cohort column takes the place of the epic status document's wave column"; the cohort table is "a projection of `cohorts[] { index, generation, item_keys[] }`". |
| US-08 | PASS | Same evidence as SP-19: zero matches for the three prohibited literals across all three runtime files. |
| US-09 | PASS | `## Startup Protocol` at `parallel-orchestrator.md:80`; the checkpoint read and the three durable re-derivation commands are asserted by the contract suite and independently corroborated by the permission-seam probe, which parses `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` as prescribed invocations from the delivered text. |
| US-10 | PASS | Same evidence as SP-14: `## Completion Requirements` at line 410 with `/parallel-close` at line 428 as the sole `open`-mode termination. |
| US-11 | PASS | Same evidence as SP-15: both block-condition tokens present at lines 264 and 325. |

## Summary

- **Total acceptance criteria:** 33 (22 from `spec.md`, 11 from `user-story.md`)
- **PASS:** 33
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0

Every criterion is structurally verifiable and was verified directly against the delivered files at `aa987c12`, not inferred from the executor's evidence artifacts. The 39 passing contract tests provide the standing regression lock; this reviewer additionally re-checked the frontmatter, heading sets and ordering, required literal markers, negative literal absence, template banner, frozen-surface empty diffs, hooks/settings empty diff, and bundled mirror parity by independent command.

**Remediation-cycle outcome.** Both cycle-1 Major findings are resolved. CR-01 was resolved by reassigning the conflict capture and the finding write to the child's `atomic-executor` rather than by widening the persona's write grants, which also fixes the latent operational problem that the parent has no worktree holding the item's branch. CR-02 was resolved by granting two interpreter invocation prefixes and naming the exact granted invocation inline in the gate section, with the gate's strictness unchanged. The recommended structural test is delivered and was confirmed non-vacuous by direct probe of its parsers.

**Coverage and toolchain.** Python is the only language with changed files. Repo-wide line coverage 91.82% (floor 85%) and branch coverage 83.80% (floor 75%), zero regression, verified by re-aggregating `artifacts/python/lcov.info`. Black, Ruff, Pyright, and Pytest all pass in a single pass (3007 passed, 0 failed, 0 skipped).

**Scope observations that do not affect any criterion.** Plan tasks P4-T7 and P4-T8 remain unchecked; they name JSON tools that fail identically at HEAD and at the merge base on a path those tools do not govern, so they are unsatisfiable as written and no acceptance criterion depends on them. One Pester test fails for a pre-existing reason on a hook and test that are byte-identical to the merge base. Both are recorded as Minor findings in `policy-audit.2026-08-08T20-25.md`.

**Recommendation: GO.** All 33 acceptance criteria are satisfied, zero blocking findings exist, and remediation is not required.

## Acceptance Criteria Check-off

No check-off action was required by this reviewer. All 33 criteria were already marked `[x]` in their authoritative source files before this re-audit, and every one of them evaluates to PASS, so the recorded state is correct and no criterion was checked off prematurely.

Verified counts at `aa987c12`:

```
grep -c '^- \[x\]' spec.md        -> 22
grep -c '^- \[ \]' spec.md        -> 0
grep -c '^- \[x\]' user-story.md  -> 11
grep -c '^- \[ \]' user-story.md  -> 0
```

Per the acceptance-criteria tracking protocol, a reviewer checks off any criterion that evaluates PASS and leaves PARTIAL, FAIL, or UNVERIFIED items unchecked. Since no criterion evaluates to anything other than PASS and none remains unchecked, no source-file edit was performed. This reviewer independently confirmed that each `[x]` is evidence-backed rather than accepting the mark itself as evidence; the per-criterion evidence is recorded in the evaluation tables above.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md, docs/features/active/2026-08-07-parallel-orchestrator-surface-441/user-story.md
- Total AC items: 33
- Checked off (delivered): 33
- Remaining (unchecked): 0
- Items remaining: none
```
