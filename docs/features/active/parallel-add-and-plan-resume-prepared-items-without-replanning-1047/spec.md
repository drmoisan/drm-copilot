# parallel-add-and-plan-resume-prepared-items-without-replanning — Spec

- **Issue:** #1047
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/1047
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03
- **Status:** Draft
- **Version:** 0.2
- **Binding source:** `docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md` (owner decisions Q1 to Q13)
- **Design baseline:** `research/research.2026-11-03T12-30.md`, section `## Recommended Design`

## Overview

`/parallel-add` and `/parallel-plan` currently send every item through a full preparation-mode child (promotion, research, spec, plan, preflight), even when that work already exists on the item's pushed branch. This feature adds a PowerShell admission helper and the matching skill, rule, agent, hook, and settings edits so that both commands:

- determine how far each item is already prepared and resume at the first incomplete stage, never repeating a completed stage;
- skip preflight and plan revision when a mechanical file-diff check shows that nothing the plan cites or writes changed on `main`;
- record and verify a plan hash between admission and execution;
- refuse an add to a closed run from code, with a clear error;
- accept a directed precedence input and reject cohort tables that violate it;
- store conflict edges in a committed record that a re-seed from another checkout can read;
- close the orchestrator turn gap by treating "PR open, step 9 pending" as not done.

- Target users/personas and primary use cases: the repository owner and the parallel orchestration agents (`parallel-planner`, `parallel-orchestrator`) when re-seeding a run from prepared items or adding a prepared or half-prepared item to an open run.
- Success metrics or expected impact: a prepared item whose cited files are unchanged is admitted with no preparation child, no preflight, and no plan revision; prerequisite ordering is honored by the scheduler; no item needs an operator-initiated second turn to reach the CI green gate.

## Behavior

- Main user flow (happy path):
  1. The operator runs `/parallel-plan <slug> <item>... [--after <later>:<earlier> ...]` or `/parallel-add <item> [--after <earlier> ...] [--band <Cn>]`.
  2. For `/parallel-add`, the run-existence check runs first (unchanged), then `guard-run` rejects a closed run.
  3. For each item, `assess` reads the item branch by ref, selects the newest preparation receipt or infers the stage from branch files, runs the staleness check against `origin/main`, records the plan hash, resolves the complexity band, and returns `next_action`.
  4. An item with `preparation_status: cleared` and verdict `fresh` is admitted directly (`admit_prepared`). Other items are delegated to the existing preparation-mode child with a resume line naming the stage and the existing artifact paths.
  5. Edges are computed as today; precedence pairs are added as separating edges, `order-cohorts` applies the precedence lift, and `test-cohorts` confirms the table honors every active precedence entry.
  6. The durable scheduling record is built by `record` and committed under `docs/features/parallel/<slug>/`.
  7. Execution children receive the plan hash in kickoff element 4 and verify it before any other step.
  8. On child completion, the parent reads the child checkpoint; if step 9 is not `passed`, the item stays `pr_open` and the child is re-delegated once to resume at S9.
- Alternate/edge flows:
  - Receipt present but its `plan_hash` differs from the current blob hash: stage downgraded to `plan`; preflight runs.
  - A plan that never cleared preflight always runs preflight, even when fresh (D3).
  - Pre-feature branch with no receipt: stage inferred from branch files; `cleared` only under the D4 evidence rule.
  - Recorded base commit not an ancestor of `origin/main`: verdict `stale` (fail closed).
  - Cited path removed on `main`: verdict `premise_falsified`; resume at `plan`; the new plan is a new timestamped file and the old plan is kept.
  - `withdrawn` predecessor releases a precedence constraint; `blocked` predecessor holds the dependent (D6).
  - A combined item inherits the union of its members' precedence entries; a pair inside one combination is dropped.
- Error handling and recovery behavior:
  - Helper exit codes: 0 success (one JSON object on stdout), 1 rule rejection (one stderr line `PARALLEL_ADMISSION_REJECTED: <code>: <detail>`), 2 usage error.
  - Rejection codes: `run_closed`, `precedence_cycle`, `precedence_unknown_item`, `precedence_violated`.
  - A `run_closed` rejection emits no `PARALLEL_MUTATION_REJECTED` signal; the closed mutation rejection code set defined in `.claude/rules/parallel-orchestration.md` is unchanged.
  - Plan-hash mismatch in the execution child stops the child with `blocked_reason: premise_falsified` before it reconciles with `origin/main`.
  - Preflight on a stale item follows the existing single-pass contract: trivial defects fixed in place, substantive defects get one planner revision, a second failed round halts with the defect list.

## Inputs / Outputs

- Inputs (CLI flags, files, env vars):
  - Skill flags: `--after` (precedence) and `--band` (complexity band). Flags are not items; the multi-item rejection still applies to positional items of `/parallel-add`.
  - Item branch contents read by ref: `<folder>/research/*.md`, `<folder>/spec.md`, `<folder>/plan.*.md`, `<folder>/evidence/**`, `<folder>/evidence/other/preparation-receipt.*.json`.
  - Run checkpoints `artifacts/orchestration/parallel-orchestrator-state.json` and `artifacts/orchestration/parallel-planner-state.json`.
  - Manifest mode from `validate-parallel-manifest.sh --print-mode`.
- Outputs (artifacts, logs, telemetry):
  - Per-item checkpoint fields and top-level `precedence[]` (see Data & State).
  - Preparation receipt `<feature folder>/evidence/other/preparation-receipt.<yyyy-MM-ddTHH-mm>.json`, written by the preparation child.
  - Durable scheduling record `docs/features/parallel/<slug>/parallel-scheduling.json` on `parallel/<slug>-plan`.
  - Kickoff `## Integrity` `plan-path | plan-hash` rows.
- Config keys and defaults: none added.
- Versioning or backward-compatibility constraints:
  - Existing runs and pre-feature branches remain valid; stage inference covers branches with no receipt.
  - The planner checkpoint ready value stays `prepared` (D1).
  - Bash entry points and their Python authorities are unchanged, so byte parity is preserved.

## API / CLI Surface

Entry point: `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 <subcommand> ...`

| Subcommand | Arguments | Output / rejection |
| --- | --- | --- |
| `guard-run` | `-CheckpointPath <p> -ManifestMode <closed\|open>` | Rejects `run_closed` when the manifest mode is `closed`, the checkpoint `mode` is `closed`, any `mutations[].op == close` exists, or the two mode values disagree. Fails closed. |
| `assess` | `-Branch <ref> -FeatureFolder <docs/features/active/x> [-Receipt <path>] [-Band <C1..C4>] [-PlannerCheckpointPath <p>] [-Main origin/main]` | `{preparation_status, resume_stage, research_path, spec_path, plan_path, plan_hash, base_commit, staleness:{verdict, changed_cited_paths, removed_cited_paths}, band:{value, source}, next_action}`; `next_action` is `admit_prepared`, `resume_preparation`, or `full_preparation`. |
| `order-cohorts` | `-Cohorts <json> -Edges "<a>:<b> ..." -Precedence "<before>:<after> ..." [-Pinned ...] [-Floor <c>]` | Lifted cohort table; rejects `precedence_cycle` or `precedence_unknown_item`. |
| `test-cohorts` | `-CheckpointPath <p>` | Rejects `precedence_violated` when the current-generation cohort table violates an active precedence entry. |
| `record` | `-RunFolder docs/features/parallel/<slug> -Entry <json>` | Durable scheduling-record content; the caller writes and commits it; the helper performs no git write. |
| `reuse-edges` | `-Slug <slug> -IssueNum <n> -PlanHash <hex> [-Ref origin/parallel/<slug>-plan]` | `{action, edges, reason}` with `action` `reuse` (reason `plan_hash_matches`, `edges` the item's recorded edges) or `recompute` (reason `record_missing`, `unknown_item`, or `plan_hash_changed`); reads the committed record by ref, runs no fetch, and performs no git write. |

- Example: `... Invoke-ParallelAdmission.ps1 guard-run -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ManifestMode closed` exits 1 with `PARALLEL_ADMISSION_REJECTED: run_closed: <detail>`.
- Contracts and validation rules:
  - Precedence keys must resolve to items, `before != after`, and the precedence graph must be acyclic.
  - The precedence key name is never `depends_on`.
  - Resume prompt line, added after the unchanged preparation kickoff line: `Preparation resume: stage <stage>. Existing artifacts: <paths>. Do not repeat a completed stage; supersede with new timestamped files.` It carries no mode marker and does not match the hook issue-number pattern.

## Data & State

- Orchestrator checkpoint item fields (tolerated, declared in `.claude/rules/parallel-orchestration.md`): `preparation_status` (`none|research|spec|plan|cleared`), `plan_hash`, `base_commit`, `band_source` (`caller|planner_checkpoint|assessment`).
- Checkpoint top level (both checkpoints): `precedence[]` of `{before, after, source, recorded_at}`; `source` is `operator` (D5).
- Planner checkpoint items: `plan_hash`, `base_commit`; `preparation_status` keeps the ready value `prepared`, which corresponds to `cleared` (D1).
- Preparation receipt: `{schema_version, stage, research_path, spec_path, plan_path, plan_hash, base_commit, preflight_status, recorded_at}`. A newer receipt supersedes an older one; the lexicographically greatest name wins; nothing is deleted (D8, Q13).
- Durable scheduling record: `{schema_version, parallel_slug, edges[], tolerated_overlaps[], precedence[], items[{issue_num, branch_name, plan_path, plan_hash, base_commit, preparation_status, complexity_band}]}`. Written by the planner at seeding; rewritten by `/parallel-add` after each admission and committed with a pathspec under `docs/features/parallel/`. The manifest stays read-only to the orchestrator.
- Stage inference (no receipt; read by ref; highest satisfied stage wins):
  - `research`: a non-empty `.md` under `<folder>/research/`.
  - `spec`: `<folder>/spec.md` exists, contains none of the whole-line placeholder lines of `docs/features/templates/feature/spec.md`, and research is satisfied.
  - `plan`: the greatest `<folder>/plan.*.md` has at least one non-placeholder task line matching `^- \[[ x]\] \[P\d+-T\d+\]`, and spec is satisfied.
  - `cleared`: plan is satisfied and a committed file under `<folder>/evidence/` whose name contains `preflight` and whose text contains `PREFLIGHT: ALL CLEAR` was last committed at or after the plan file's last commit (D4); otherwise capped at `plan`.
- Staleness check: base `C` = receipt `base_commit`, else `git merge-base <main> <branch>`; `M` = `origin/main` after fetch; cited = `Get-PlanPaths` over the plan plus the normalized declared radius, minus the item's own feature-folder glob; changed = `git diff --name-only --no-renames C M`; hits by `Test-EntryOverlap` or exact match; removed = concrete cited paths present at `C` and absent at `M`. Verdict `fresh` (no hits), `premise_falsified` (removed non-empty), else `stale`; non-ancestor `C` gives `stale`.
- Verdict to action: `cleared`+`fresh` admit with no child; `cleared`/`plan`+`stale` resume at preflight with hits as findings; `premise_falsified` resume at `plan`; `plan` never cleared always preflights; `spec` resumes at `plan`; `research` resumes at `spec`; `none` gets full preparation. A contract change found by that preflight is treated as a falsified premise and resumes at `plan`.
- Caching or persistence details: run checkpoints remain gitignored; the receipt and the scheduling record are committed.
- Migration or backfill requirements: none; pre-feature branches are covered by stage inference.

## Constraints & Risks

- Language (Q6): PowerShell helper (bash allowed). No new Python file, no edit to existing Python, no edit to the TypeScript validator port; existing Python is only called. No TypeScript is added.
- Gate intent unchanged: closed runs stay closed, preflight strictness is unchanged, and the at-most-one-return rule is unchanged.
- The bash helpers (`mutate-parallel-run.sh`, `compute-cohorts.sh`, and their libraries) are not edited, because they are byte-parity ports of Python authorities.
- Layer 2 gap (D2): the Python orchestrator-state validator does not see `precedence[]`; precedence is enforced by the helper and by Layer 1 of the cohort barrier hook. This is documented in the rule as a known gap.
- Hook visibility: the barrier hook change is exercised by isolated subagents only after merge; proof on the branch is by Pester.
- Invocation route: the `parallel-planner` and `parallel-orchestrator` forks call the helper with `pwsh -NoProfile -NonInteractive -File`; isolated preparation and execution children do not call it (the execution child uses `git rev-parse HEAD:<plan-path>`).
- Inference accuracy: placeholder detection can fail on a spec that quotes template text; this errs toward redoing a stage, which is the safe direction.
- Tolerated overlaps still require the later merger to rebase and re-run CI; this feature does not remove that cost.
- Coverage: git and file I/O stay in seam functions in `Invoke-ParallelAdmission.ps1` so that the production files reach the line-coverage threshold under mocks.

## Decisions

The owner did not decide these; they were resolved by the orchestrator from the research open decisions.

- **D1:** No Python or TypeScript edit. The planner checkpoint keeps its ready value `prepared` (P7). The `preparation_status` values `none`, `research`, `spec`, `plan`, `cleared` are tolerated item fields declared in `.claude/rules/parallel-orchestration.md`; `prepared` corresponds to `cleared`.
- **D2:** Precedence is a tolerated `precedence[]` field plus a Layer 1 check in the cohort barrier hook and the helper's cohort-table rejection. The Layer 2 Python validator does not see precedence; this is documented as a known gap.
- **D3:** A plan that never cleared preflight always runs preflight.
- **D4:** On pre-feature branches, `cleared` is inferred only from a committed preflight evidence file containing `PREFLIGHT: ALL CLEAR` committed at or after the plan's last commit; otherwise the stage is capped at `plan`.
- **D5:** Precedence comes from operator flags only; Phase 0 prose is not parsed.
- **D6:** A `withdrawn` predecessor releases the constraint; a `blocked` predecessor holds the dependent.
- **D7:** The work is delivered as one item, with no split.
- **D8:** The receipt is at `<feature folder>/evidence/other/preparation-receipt.<yyyy-MM-ddTHH-mm>.json`; the lexicographically greatest name wins.
- **D9:** The Language criterion was corrected to permit fragment-pin edits to an existing `.py` test-support module under `tests/`, because the plan-hash and turn-gap criteria require pins in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; Q6 binds new Python and production Python only.

## Open Questions

- **Q14 (non-blocking):** The promoted record states that its decisions are "Q1 to Q14" but enumerates only Q1 to Q13, and no Q14 decision is recorded in the repository. The owner should state whether a Q14 decision exists. Delivery does not depend on the answer.

## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Create `.claude/lib/parallel-admission/ParallelAdmission.psm1` (closed-run guard, stage inference, staleness verdict, band precedence, admission decision), `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` (precedence validation, lift, cohort check), `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` (JSON parse and serialize helpers), and `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` (CLI, `Invoke-ParallelAdmissionGit` seam, JSON read seam, exit codes), following the `.claude/lib/parallel-drift/` pattern.
  - Edit `.claude/skills/parallel-add/SKILL.md`: code guard in `## Prerequisites` after the run-existence check; assess-then-resume in step 2; precedence in steps 3 to 5; durable record write; amend the `## Constraints` sentence that forbids new `items[]` fields.
  - Edit `.claude/skills/parallel-plan/SKILL.md`: assess at `## Item Intake`; fan out only incomplete items in `## Preparation Fan-Out`; precedence input (amend the intro phrase "no operator-supplied ordering" while keeping "The operator is never asked for ordering edges"); durable record at seeding; `## Integrity` hashes; recomputation parity including the precedence lift.
  - Edit `.claude/skills/parallel-orchestrate/SKILL.md`: plan-hash sentence in kickoff element 4; barrier honors precedence; turn-gap rule in `## Per-Item Merge to Main (Merge-on-Green)`; declared optional fields in `## Parallel-Level Checkpoint`. No new `##` heading.
  - Edit `.claude/rules/parallel-orchestration.md`: declare the tolerated fields, `precedence[]`, the receipt, and the scheduling record; precedence doctrine distinct from `depends_on`; the D1 correspondence; the D2 Layer 2 gap.
  - Edit `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, and `.claude/settings.json`: add `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)`; update checkpoint field lists.
  - Edit `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`: `Test-ParallelCohortBarrierClear` also requires every active `precedence[]` predecessor of the target to be `merged` or `worktree_removed` (`withdrawn` releases).
  - Bundle copies of every created or edited `.claude` file under `extensions/drm-copilot/resources/claude-customizations/`, and `pack-manifests/core.json` entries for the new lib files.
- New classes/functions/commands to add or update: the helper subcommands in `## API / CLI Surface`; `Test-ParallelCohortBarrierClear`.
- Tests: `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1`, `ParallelAdmissionPrecedence.Tests.ps1`, `Invoke-ParallelAdmission.Tests.ps1`, `ParallelAdmission.Manifest.Tests.ps1`; precedence cases in `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`; fragment pins in the existing `tests/scripts/dev_tools/test_parallel_*` contract tests only where new text must be protected. No bats change.
- Dependency changes: none.
- Logging/telemetry additions and locations: the helper's stderr rejection line only.
- Rollout plan: the skill and rule changes take effect after merge and push-down; the barrier hook change takes effect for isolated subagents after merge. No feature flag. The execution-environment brief needs no update, because no CI job, required context, tool route of a named agent, or batch-budget rule changes; preflight re-checks this against the final task list.

## Acceptance Criteria

- [x] Language: the helper is implemented as `.claude/lib/parallel-admission/ParallelAdmission.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, and `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` (bash is allowed for any additional helper); the change adds no `.py` file, edits no Python production file (no `.py` path outside `tests/`), and adds or edits no `.ts` file; an existing `.py` test-support module under `tests/` may gain the fragment pins that the plan-hash and turn-gap criteria require. Verified by a `git diff --name-only --no-renames` and a `git diff --name-status --no-renames`, both from the merge base of `origin/main` and `HEAD` and both recorded under `evidence/qa-gates/`, showing no `.ts` path, no added (`A`) `.py` path, and no `.py` path outside `tests/`.
- [x] Stage record: `assess` returns `preparation_status` with a value from the set `none`, `research`, `spec`, `plan`, `cleared`; the orchestrator checkpoint item records it; `.claude/rules/parallel-orchestration.md` declares the values as tolerated item fields and states that the planner ready value `prepared` corresponds to `cleared`, per the recorded stage-record decision. Verified by Pester cases in `ParallelAdmission.Tests.ps1` for each value and by a branch-current run of `scripts/dev_tools/validate_parallel_orchestrator_state.py` and `scripts/dev_tools/validate_parallel_planner_state.py` accepting a checkpoint that carries the new fields.
- [x] Preparation receipt: the preparation prompt instructs the child to write `<feature folder>/evidence/other/preparation-receipt.<yyyy-MM-ddTHH-mm>.json` carrying `plan_hash` and `base_commit` (with the other receipt fields) before its commit; `assess` selects the lexicographically greatest receipt name; a receipt whose `plan_hash` differs from the current blob hash downgrades the stage to `plan`. Verified by Pester cases for receipt selection and downgrade, and by the skill text carrying the receipt instruction as a line separate from the unchanged kickoff line (`test_parallel_issue_adoption_skill_contracts.py` passes).
- [x] Stage inference: for a branch with no receipt, `assess` infers `research`, `spec`, `plan`, or `cleared` by the rules in `## Data & State`, inferring `cleared` only from a committed preflight evidence file containing `PREFLIGHT: ALL CLEAR` committed at or after the plan's last commit and otherwise capping at `plan`. Verified by a Pester case for each inference row, including a template-placeholder spec, a placeholder-only plan, and preflight evidence older than the plan, with `Invoke-ParallelAdmissionGit` mocked.
- [x] Resume at first incomplete stage: for an item that is not `cleared`+`fresh`, the skills delegate the existing preparation-mode child with the unchanged kickoff line followed by the resume line naming the stage and existing artifact paths, on the item's pushed branch; no separate preparation mechanism exists. Verified by Pester `next_action` cases, by `test_parallel_issue_adoption_skill_contracts.py` (kickoff line byte-identical, no hook issue-number pattern), and by the local integration scenario "add a half-prepared item" recorded under `evidence/regression-testing/`.
- [x] Fresh skip: when the stage is `cleared` and no changed path on `main` since the base commit overlaps a cited or written path, `assess` returns verdict `fresh` and `next_action: admit_prepared`, and the skills run no preparation child, no preflight, and no plan revision. Verified by Pester staleness cases with and without overlap and by the local integration seed scenario.
- [x] Stale path and fully-prepared definition: a stale `cleared` or `plan` item resumes at preflight with the overlapping paths as findings under the unchanged single-pass contract (trivial fixes in place, and the existing planner-revision limit and halt rule of that contract); a plan that never cleared preflight always runs preflight; only `cleared` yields `admit_prepared`. Verified by Pester verdict-to-action cases and by the skill text referencing the unchanged `## Delegation Model` rule in `.claude/skills/orchestrate/SKILL.md`.
- [x] Premise falsified and supersession: a cited path present at the base and absent on `main` yields `premise_falsified` and resume at `plan`; a non-ancestor base yields `stale`; a contract change found by preflight resumes at `plan`; superseded artifacts are written as new timestamped files and no artifact is deleted. Verified by Pester cases for a removed path and a non-ancestor base, and by skill text stating the supersession rule.
- [x] Plan hash: `assess` records the git blob hash of the plan at the item branch head on the checkpoint item, in the scheduling record, and in the kickoff `## Integrity` table; the kickoff element that carries the committed `plan-path` also carries `plan-hash: <hex>` and instructs the child to run `git rev-parse HEAD:<plan-path>` before any other step and stop with `blocked_reason premise_falsified` on mismatch; the kickoff element count is unchanged. Verified by Pester hash-recording cases and by `test_parallel_orchestrator_surface_contracts.py` passing with a fragment pin for the plan-hash sentence.
- [x] Closed-run guard: `guard-run` exits with the helper's rule-rejection status and `PARALLEL_ADMISSION_REJECTED: run_closed: <detail>` when the manifest mode is `closed`, the checkpoint `mode` is `closed`, a `mutations[].op == close` exists, or the manifest and checkpoint modes disagree, and exits with the success status for an open run; `/parallel-add` `## Prerequisites` runs it after the run-existence check and emits no `PARALLEL_MUTATION_REJECTED` signal for it. Verified by the Pester guard matrix, by `test_parallel_mutation_rejection_signal_contracts.py` passing with the existing rejection-code table unchanged, and by the local integration scenario "add to a closed run".
- [x] Shared intake and seeding: `/parallel-add` and `/parallel-plan` intake both call the same `assess` subcommand; `/parallel-plan` seeds a new run from `cleared`+`fresh` items without preparation children, records `topology_receipt` as not applicable for them, and the result is accepted by `validate-parallel-manifest.sh`, `scripts/dev_tools/validate_parallel_planner_state.py`, and `scripts/dev_tools/validate_parallel_orchestrator_state.py`. Verified by the local integration seed scenario with the validator exit codes recorded under `evidence/regression-testing/`.
- [x] Complexity band precedence: the band is taken from `--band`, else from the planner checkpoint item's `complexity_band`, else from a fresh `## Complexity Assessment` with a written rationale and the floor from `Get-ComplexityFloor`; `band_source` records `caller`, `planner_checkpoint`, or `assessment`. Verified by Pester cases for each source and by `test_parallel_complexity_routing_contracts.py` passing.
- [x] Precedence input: `--after` flags on both commands are recorded as `precedence[]` entries `{before, after, source, recorded_at}`, never as `depends_on`; unknown keys, self-pairs, and cycles are rejected with `precedence_unknown_item` or `precedence_cycle`; `order-cohorts` places every `after` item in a later cohort than each `before` item, moves only unstarted items upward, and never moves pinned items; `/parallel-add` forces `defer_and_recolor` for a candidate with an active unmerged predecessor. Verified by Pester cases in `ParallelAdmissionPrecedence.Tests.ps1` and by `test_parallel_planner_surface_contracts.py` passing with "The operator is never asked for ordering edges" and the `depends_on` prohibitions intact.
- [x] Precedence rejection and barrier: `test-cohorts` rejects with `precedence_violated` when a current-generation cohort places an `after` item at or before an active `before` item; the recomputation parity step and each `/parallel-add` recolor run it; `Test-ParallelCohortBarrierClear` denies a target whose active predecessor is not `merged` or `worktree_removed`; a `withdrawn` predecessor releases and a `blocked` predecessor holds; the rule documents that the Python orchestrator-state validator does not check precedence. Verified by Pester cases in `ParallelAdmissionPrecedence.Tests.ps1` and in `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`, passing on the Linux hook-suite job.
- [x] Durable edges: `record` builds `docs/features/parallel/<slug>/parallel-scheduling.json` content with edges, tolerated overlaps, precedence, and per-item plan hashes; the planner commits it at seeding and `/parallel-add` rewrites and commits it after each admission; a re-seed reads it by ref from `parallel/<slug>-plan` and reuses an item's edges only when its recorded `plan_hash` equals the current blob hash. Verified by Pester cases for record content and the reuse rule, and by the local integration seed scenario reading the record from another checkout.
- [x] Turn gap: `## Per-Item Merge to Main (Merge-on-Green)` in `.claude/skills/parallel-orchestrate/SKILL.md` directs the parent to read the child checkpoint, keep `merge_status: pr_open` when the child's CI green gate status is not `passed` or `blocked_reason` is `awaiting_ci`, poll CI to a terminal conclusion, and re-delegate the child to resume at the CI green gate before recording `ci_green`; no `##` heading is added. Verified by `test_parallel_orchestrator_surface_contracts.py` passing with the heading pins unchanged and a fragment pin for the re-delegation rule.
- [x] Declared fields and permissions: the parallel-add `## Constraints` sentence and the parallel-orchestrate "add no field ... the rule does not declare" sentence are amended consistently with the new fields; `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, and `.claude/settings.json` grant `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)`. Verified by `test_parallel_orchestrator_permission_contracts.py`, `test_parallel_planner_surface_contracts.py`, and `test_claude_rules_frontmatter.py` passing.
- [x] Mirrors: every created or edited `.claude` file has a byte-equal copy under `extensions/drm-copilot/resources/claude-customizations/`, and the new lib files are listed in `pack-manifests/core.json`. Verified by `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the parallel contract tests named in the research section on mirrors and pins, and `ParallelAdmission.Manifest.Tests.ps1` all passing.
- [x] Unit and CLI tests with coverage: Pester unit suites for each new module and a CLI suite for `Invoke-ParallelAdmission.ps1` mock `Invoke-ParallelAdmissionGit` and the JSON read seam, create no temporary files, and give each new PowerShell production file line coverage at or above the line threshold in `.claude/rules/general-unit-test.md` `## Coverage Requirements`; `ClaudeLibModuleConvention.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1` pass. Verified by `artifacts/pester/pester-junit.xml` and per-file figures from `artifacts/pester/powershell-coverage.xml`, recorded under `evidence/qa-gates/`.
- [x] Test-order independence: a seeded shuffled file-order run of the touched Pester suites in a single process, with the seed count required by `## Test Isolation Checks` in `.claude/skills/execution-environment/SKILL.md` and each seed recorded, a concurrent-shard Pester run, and `poetry run pytest -n auto` over the touched contract tests with `--strict-markers` all report no failures. Verified by artifacts under `evidence/regression-testing/` carrying each seed and file order.
- [x] Gate intent unchanged: closed runs still refuse additions, preflight strictness is unchanged, and the single-pass preflight return limit is unchanged; the bash entry points and their Python authorities are not edited. Verified by the existing `tests/shell/*_parity.bats` and `test_parallel_mutation_run_bash_parity.py` passing unchanged and by a review of the skill diffs against the unchanged `## Delegation Model` rule.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
