# Research: resume prepared items in `/parallel-add` and `/parallel-plan` (Issue #1047)

- Issue: #1047
- Branch: `feature/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Feature folder: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Binding source: `docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md` (owner decisions Q1-Q13)
- Timestamp note: the filename stamp was not read from a host clock. The researcher has no shell tool, so the orchestrator should confirm or rename the stamp.

All findings below come from reading the files in the item worktree. Citations name files, headings, and symbols only. The researcher could not run `git log`, so the statement that PRs #1052, #1044, and #1045 shaped this text is not verified here. The text described is the text present in this worktree.

## 1. Current State: skills and rule

### `.claude/skills/parallel-add/SKILL.md`

- `## Prerequisites` covers four checks. A pending or not-started run is rejected first, with `PARALLEL_MUTATION_REJECTED: run_not_started`. The section then states "closed runs are not eligible" and "A closed run and an argument naming more than one item are rejected only after the run-existence check ... each of these rejections emits no rejection signal". **The closed-run check is prose only.** No step invokes code for it.
- `## Procedure` step 2 (`2. **Prepare the item.**`) is the only step that delegates the preparation child. It always runs the full `route_id: preparation` contract (promotion, research, spec, user-story, plan, preflight) and then the `parallel-plan` `## Complexity Assessment`. For an issue-number item it carries the issue-adoption line.
- Steps 3 to 7 need only a declared radius and a complexity band:
  - Step 3: `Get-BlastRadiusConflictEdge` and `Get-BlastRadiusCombination`.
  - Step 4: `mutate-parallel-run.sh admit`.
  - Step 5: `recolor` and its write rules.
  - Step 6: `add-entry`.
  - Step 7: MCP validation with `parallel-orchestrator-state`.
- `## Constraints` states "No field and no enum member is added to `mutations[]`, `items[]` ...". This sentence blocks new per-item fields unless the text is amended. No test pins it (a search of `tests/` found no match).
- No step records a plan hash, a base commit, a precedence input, or a durable edge record.

### `.claude/skills/parallel-plan/SKILL.md`

- `## Item Intake`: "The operator is never asked for ordering edges". The intro also says "no operator-supplied ordering".
- `## Preparation Fan-Out`: one child per item, always, in waves from `compute-concurrency-batches.sh`. It contains the blockquoted preparation kickoff line, the `model_budget.fable_policy` line, and the issue-adoption line.
- `### Planner procedure` and `### Seeding procedure`: radius, edges, `compute-cohorts.sh`, and the lane assertion. Edges go to `conflict_edges[]` in the gitignored planner checkpoint only.
- `### Recomputation parity (planner-owned check)`: re-invoke `compute_cohorts` over the recorded keys and edges.
- `## Checkpoint Persistence`: the per-item `preparation_status` already exists. The readiness contract requires `preparation_status: prepared` (P7).
- `## Kickoff Artifact`: an optional `## Integrity` section carries a `plan-path | plan-hash` table (40 to 64 hex). This is the only plan-hash surface, and nothing verifies it against a branch.

### `.claude/skills/parallel-orchestrate/SKILL.md`

- `## Parallel-Mode Kickoff Parameter`: five elements. Element 4 carries the committed `plan-path` and the resume instruction. **No plan hash is passed and nothing is verified before the child starts.** `**Band and receipt source.**` gives an admitted item's band source.
- `## Cohort Barrier and Max-Concurrency Slot Filling`: the per-edge barrier reads `conflict_edges[]` only.
- `## Per-Item Merge to Main (Merge-on-Green)` step 2: when the child reported pending CI-dependent criteria, "the item waits until its child pushes the check-off and re-runs S9". **No step re-delegates the child.** See question 7.
- `## Parallel-Level Checkpoint`: "add no field to it that `.claude/rules/parallel-orchestration.md` does not declare". `mergeable_conflicts_resolved` is "the one declared optional item field".
- `## Mutation Protocol (F6)` delegates add to the `parallel-add` skill.

### `.claude/rules/parallel-orchestration.md`

- Orchestrator invariants 1-21 have no closed item-key set, so extra item fields are tolerated by the validators.
- P3 requires a `preparation_status` key with no value constraint. P7 (ready gate) requires `preparation_status == 'prepared'`. The constant is `READY_PREPARATION_STATUS` in `scripts/dev_tools/validate_parallel_planner_state.py`.
- Manifest invariants M1-M8 likewise have no closed top-level key set. M7 rejects `depends_on` at any level. Orchestrator invariant 10 and P3 reject `depends_on` in the checkpoints.
- `## Enum Ownership` fixes the four `conflict_edges[].reason` members. Precedent for tolerated fields: `tolerated_overlaps`, `hard/cost/benefit`, `combined_issue_nums`, and `mergeable_conflicts_resolved`.
- `## Mutation Rejection Signal (issue #1012)` defines a closed four-code set with no closed-run code.

## 2. Current State: helpers, schema, and libraries

### Bash entry points (`.claude/lib/bash/`)

- `mutate-parallel-run.sh` exposes `admit`, `recolor`, `add-entry`, `close`, `close-entry`, and `requeue-entry`. It sources `parallel-mutation-ops.sh` (`pm_decide_admission`, `pm_build_add_entry`, `pm_decide_close`, ...), which sources `parallel-mutation.sh` (`pm_recolor_unstarted`, ...). `parallel-mutation-cli.sh` holds option parsing.
- `admit` takes `--candidate`, `--edges`, `--in-flight`, and `--current-cohort-members`. It prints `{candidate, outcome, triggers_recompute}` and has no rejection branch ("Declared divergence 4").
- `compute-cohorts.sh` and `parallel-cohorts.sh` (`pcoh_compute_cohorts`) perform Welsh-Powell coloring over undirected `a:b` edges.
- The manifest validation path is `validate-parallel-manifest.sh` → `parallel-manifest-validate.sh` → `parallel-items-validate.sh` → `parallel-yaml-emit.sh`/`parallel-yaml-scan.sh` (a block-YAML subset; flow collections, floats, and unquoted timestamps are refused). `parallel-common.sh` is shared.
- Every entry point is a byte-parity port of a Python authority: `parallel_mutation_protocol.py`, `_parallel_mutation_entries.py`, `parallel_cohort_computation.py`, and `parallel_manifest_contract.py`. Parity is pinned by `tests/shell/*_parity.bats` and `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py`.
- **Consequence:** a closed-run branch in `admit`, a precedence input in `compute-cohorts.sh`, or an edge store in the bash path would break parity unless the Python authority also changed. That conflicts with Q6, so none of the new logic belongs in the bash helpers.

### Schema locations

- Run `mode`: manifest frontmatter (`--print-mode`), copied to checkpoint `mode`. The open-mode close record is `mutations[].op == close`.
- Edges: `conflict_edges[]` and `tolerated_overlaps` in `artifacts/orchestration/parallel-planner-state.json` and `artifacts/orchestration/parallel-orchestrator-state.json`. Both files are gitignored.
- Items: `items[]` in both checkpoints. Cohorts: `cohorts[]`, `recolor_generation`, and `current_cohort`.

### Python validators (to be called, not edited, under Q6)

- `scripts/dev_tools/validate_parallel_orchestrator_state.py` (with `_parallel_state_common.py`, `_parallel_state_structures.py`, `_parallel_state_records.py`, `_parallel_orchestrator_state_mutations.py`, `_parallel_orchestrator_state_mode_completion.py`, and `_parallel_orchestrator_state_cohort_barrier.py`).
- `scripts/dev_tools/validate_parallel_planner_state.py` with `_parallel_planner_state_routing.py`.
- `scripts/dev_tools/parallel_manifest_contract.py`.
- `scripts/dev_tools/parallel_kickoff_contract.py`.
- TypeScript ports: `extensions/drm-copilot/src/lib/validate/parallel-*.ts`.

### PowerShell hosts (`.claude/lib/`)

- `parallel-drift/` is the template to follow:
  - `ParallelDrift.psm1`, `ParallelDriftHalt.psm1`, and the entry script `Invoke-ParallelDriftDetection.ps1`.
  - The entry script reads JSON with System.Text.Json and keeps I/O in seam functions (`Read-ParallelDriftJsonText`, `Get-ParallelDriftUtcNow`).
  - It loads functions for tests when dot-sourced and exits 0/1/2.
  - Its tests are under `tests/scripts/claude-lib/parallel-drift/`, including a `*.Manifest.Tests.ps1` that checks core.json membership and bundle byte-identity.
- Reusable modules:
  - `blast-radius/BlastRadius.psm1` exports `Get-PlanPaths`, `Get-BlastRadius`, `Get-NormalizedDeclaredRadius`, and `Get-BlastRadiusConflictEdge`.
  - `blast-radius/BlastRadiusGlob.psm1` provides `Test-GlobMatch` and `Test-EntryOverlap`.
  - `model-routing/ModelRouting.psm1` provides `Get-ComplexityFloor` and `Resolve-DelegationModel`.
- Conventions are enforced for every `.psm1` by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`:
  - `Set-StrictMode -Version Latest` followed directly by `$ErrorActionPreference = 'Stop'`.
  - Every column-0 `Import-Module` carries `-ErrorAction Stop`.
  - The help block contains "imports its siblings with -ErrorAction Stop".
  - The file stays within the 800-line limit.
- `.claude/lib` is a coverage root in `config/poshqc-coverage.json`.

## 3. Mirrors and pins

- **Twins:** the target files have no `.agents/`, `.github/`, or `.codex/` twins (see `## Numeric Derivation Evidence`). The parallel surface is Claude-only. `.codex/hooks/enforce-orchestration-preimplementation-gate*.ps1` mention parallel markers but are not twins of any target file.
- **Bundled copies** under `extensions/drm-copilot/resources/claude-customizations/`:
  - `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`
  - `.claude/rules/parallel-orchestration.md`
  - `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`
  - `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`
  - `.claude/settings.json`
  - every `.claude/lib/bash/*` file
- **Pack manifest:** `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the skills, the agents, the rule, the hooks, and the lib files. New files must be added here.
- **Hash pins:** `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. **No target file is hash-pinned.**
- **Fragment and structure pins** that the edits must preserve:
  - `test_parallel_orchestrator_surface_contracts.py`:
    - `parallel-orchestrate/SKILL.md` keeps exactly sixteen `##` headings, and the first thirteen match `SKILL_HEADINGS`.
    - The agent body keeps exactly the nine `AGENT_HEADINGS`.
    - `Agent(pr-author)` is the only pr-author grant.
    - The section fragments include the kickoff fragments `committed \`plan-path\`` and "resume at atomic execution ...".
  - `test_parallel_orchestrator_permission_contracts.py`: every command invocation prescribed in `parallel-orchestrate/SKILL.md` must be covered by a `Bash(...)` grant in `.claude/agents/parallel-orchestrator.md`.
  - `test_parallel_issue_adoption_skill_contracts.py`:
    - The preparation kickoff blockquote (`KICKOFF_LINE`) must stay byte-identical.
    - Step boundaries `2. **Prepare the item.**` and `3. **Compute conflict edges` must remain.
    - The kickoff keeps five elements, bounded by element 4 and element 5.
    - Added text must not match the hook issue-number pattern `issue(...)\s*[:=]\s*#?\d+`.
  - `test_parallel_complexity_routing_contracts.py`: step 2 keeps `## Complexity Assessment`, `complexity_band`, `parallel-orchestrate`, `## Model Selection`, and `model_routing_receipt`. Constraints keep `complexity_band` and "existing scheduling field". The admitted-item band-source tokens stay.
  - `test_parallel_planner_surface_contracts.py`:
    - "The operator is never asked for ordering edges" and "carries no `depends_on` field at any level" stay.
    - The forbidden strings include `depends_on:`.
    - The required planner grants stay.
    - `pending or not-started` and `execution has started` stay in parallel-add.
  - `test_parallel_mutation_rejection_signal_contracts.py`: the four-code table is unchanged. parallel-add `## Prerequisites` emits only `run_not_started` and keeps "run-existence check is evaluated first" and "emits no rejection signal".
- **Push-down contracts** (`.claude/skills/execution-environment/SKILL.md` `## Contract Tests That Pin Mirrored Files`): resource contracts (bundle text equal), pack-manifest completeness, and dependency closure (`$PSScriptRoot` imports of a manifested `.ps1` must be in core). The Codex generator check is not affected, because no Codex agent is touched.
- **What a change requires:** edit the primary and its bundle copy in the same change with byte-equal text, add new lib files to `core.json`, and add a `*.Manifest.Tests.ps1` for the new lib folder.

## 4. Tests and CI shape

- **bats:** `tests/shell/parallel_*.bats` (behavior and parity, plus `parallel_payload_only.bats` for runs without Python). They run under `shell-coverage / Shell Coverage (Bats + kcov)`. No bats change is needed, because the bash helpers stay unchanged.
- **Pester:**
  - New tests go in `tests/scripts/claude-lib/parallel-admission/`.
  - Hook tests are `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier*.Tests.ps1`. They also run in `poshqc / PowerShell hook suites (Linux)` on a case-sensitive filesystem.
  - `config/poshqc-scan.json` scans `tests/scripts`, so new files are sharded automatically.
- **pytest:**
  - The `tests/scripts/dev_tools/test_parallel_*` contract tests run in `quality-checks7` with `poetry run pytest -n auto`.
  - `pyproject.toml` `addopts` sets `--strict-markers --strict-config`.
- **Order independence:** the isolation checks in `.claude/skills/execution-environment/SKILL.md` `## Test Isolation Checks` apply:
  - seeded shuffled Pester file order (at least three seeds)
  - a reversed-order run of changed pytest modules
  - concurrent shards plus `-n auto`
  - no temporary files; git and file reads go through mocked seams

## 5. Helper invocation by the agents

- `.claude/agents/parallel-planner.md` `tools:` has no `pwsh` grant, but its skill already prescribes `pwsh` `Import-Module` of `BlastRadius.psm1`. `.claude/agents/parallel-orchestrator.md` grants specific `pwsh -NoProfile -File .claude/lib/...` entries. Per the execution-environment brief, a `(pattern)` suffix admits the bare tool, so a grant is not a runtime restriction. It is a contract requirement for the orchestrator (permission-seam test).
- Both agents run as `context: fork` forks in the session checkout, not in agent-isolated worktrees, so the worktree isolation guard does not apply to their `pwsh -File` text. The isolated preparation and execution children do not need to call the helper. The execution child's hash check is `git rev-parse HEAD:<plan-path>`, which the guard accepts as worktree-scoped `git`.
- **Required changes:**
  - Add `"Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)"` to both agents.
  - Add the same allow entry to `.claude/settings.json`.
  - Mirror all three in the bundle.
- **Tests that pin frontmatter:** `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_orchestrator_permission_contracts.py`, `test_parallel_planner_surface_contracts.py`, and `test_claude_rules_frontmatter.py` (preloaded skills exist).

## 6. Precedence and durable edges today

- **How edges are computed:** `Get-BlastRadiusConflictEdge` applies the detection relation and the integration-cost rule (hard classes, cost vs. benefit times tolerance, aggregate cap). It returns `edges` and `tolerated_overlaps`.
- **Why direction is lost:** edges are undirected. The coloring visits nodes by `(-degree, item_key)`, so which item of a pair lands earlier is arbitrary. A prerequisite can therefore be colored after its dependent, which is what the 2026-10-30 dry run at tolerance 1600 showed.
- **Why edges are lost on re-seed:** they are stored only in the two gitignored checkpoints. The committed run artifacts do not carry them:
  - The manifest `parallel.md` has no edges.
  - `parallel-kickoff.md` has cohorts in `## Item Summary` but no edges.
  - `parallel-status.md` projects `## Conflict Edges` but is committed only at `### Run Closing`.
- **Durable candidates:**
  - Manifest frontmatter: authored by the planner, but read-only to `parallel-orchestrator`, so `/parallel-add` edges could not be recorded there. It is also subject to YAML-subset limits.
  - `parallel-status.md`: generated and never an input.
  - A new committed JSON record in the run folder on `parallel/<slug>-plan`. This is the recommended option.

## 7. Orchestrator turn gap

- The child's S9 (`.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate` step 4) ends the turn on a poll timeout with `blocked_reason: "awaiting_ci"`, `next_step: "S9_ci_green"`, and `step9_status: pending`. "DONE is not written while `step9_status` is anything other than `passed`."
- The parent (`## Per-Item Merge to Main (Merge-on-Green)` steps 1-2) assumes the child finished at DONE. Step 2 refuses `ci_green` while CI-dependent criteria are pending, but only says the item "waits". It names no re-delegation trigger. The `## Parallel-Level Checkpoint` transition chain moves `worktree_created` → `pr_open` "when the child reports its pull request open".
- So the state "PR open, step 9 pending" has no defined exit except an operator-initiated second turn. That matches the record: every item has needed a second turn.

## 8. Execution-environment brief

- The planned changes do not alter any fact the brief states:
  - The agents it names (`atomic-executor`, `atomic-planner`, `task-researcher`, `orchestrator`) keep their tool routes.
  - No CI job, required context, or batch-budget rule changes.
  - The edited hook (`enforce-parallel-cohort-barrier-helpers.ps1`) is not described in the brief.
- **No brief-update obligation.** The obligation appears only if the plan adds a CI job or changes a named agent's route. Preflight should re-check this against the final task list.

## Candidate Approaches

1. **Recommended: a new PowerShell admission module plus skill and rule edits.**
   - All new logic goes in `.claude/lib/parallel-admission/`: closed-run guard, stage inference, staleness, plan hash, band resolution, precedence check and lift, and the durable record.
   - The skills call it through one `pwsh -File` entry point. The bash and Python authorities are unchanged.
   - Alignment: Q4 (one helper for both commands), Q6 (no new Python, existing Python only called), and the `parallel-drift` precedent.
2. **Rejected alternatives.**
   - Extend `mutate-parallel-run.sh` and `compute-cohorts.sh`: this breaks byte parity with the Python authorities unless the Python also changes, which conflicts with Q6.
   - A TypeScript MCP command: Q6 reserves TypeScript for MCP and extension commands only, and the planner runs the checks locally.
   - Prose-only stage judgment: fails Q9 and the AC "from code".

## Recommended Design

### File inventory

| File | Action | Purpose |
| --- | --- | --- |
| `.claude/lib/parallel-admission/ParallelAdmission.psm1` | create | Pure functions for the closed-run guard, stage inference, the staleness verdict, band precedence, and the admission decision |
| `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` | create | Pure functions for precedence validation (unknown keys, cycles), the cohort check, and the precedence lift |
| `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | create | CLI, the git seam (`Invoke-ParallelAdmissionGit`), JSON I/O, and exit codes 0/1/2 |
| bundle copies of the three files | create | push-down |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit | list the three files |
| `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1`, `ParallelAdmissionPrecedence.Tests.ps1`, `Invoke-ParallelAdmission.Tests.ps1`, `ParallelAdmission.Manifest.Tests.ps1` | create | unit, CLI, and manifest membership tests |
| `.claude/skills/parallel-add/SKILL.md` (+bundle) | edit | code guard in Prerequisites; assess-then-resume in step 2; precedence in steps 3-5; durable record write |
| `.claude/skills/parallel-plan/SKILL.md` (+bundle) | edit | assess at intake; fan out only incomplete items; precedence input; durable record; `## Integrity` hashes; P5 parity including the precedence lift |
| `.claude/skills/parallel-orchestrate/SKILL.md` (+bundle) | edit | element 4 hash verification; barrier honors precedence; turn-gap rule in Merge-on-Green; declared optional fields. **No new `##` heading.** |
| `.claude/rules/parallel-orchestration.md` (+bundle) | edit | declare tolerated fields and the scheduling record; precedence doctrine (not `depends_on`); P7 per open decision D1 |
| `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md` (+bundle) | edit | helper grant; checkpoint field lists |
| `.claude/settings.json` (+bundle) | edit | allow entry for the helper |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` (+bundle) | edit | `Test-ParallelCohortBarrierClear` also requires every `precedence[]` predecessor of the target to be `merged`/`worktree_removed` |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` | edit | precedence cases |
| contract tests listed in question 3 | review/edit | keep the pins; add fragments for the new text where a pin is wanted |

### Helper command surface

`pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 <subcommand> ...`. Every subcommand prints one JSON object and exits 0 on success, 1 on a rule rejection (one stderr line `PARALLEL_ADMISSION_REJECTED: <code>: <detail>`), and 2 on a usage error.

- `guard-run -CheckpointPath <p> -ManifestMode <closed|open>`: rejects with `run_closed` when the manifest mode is `closed`, the checkpoint `mode` is `closed`, any `mutations[].op == close` exists, or the two mode values disagree. The check fails closed.
- `assess -Branch <ref> -FeatureFolder <docs/features/active/x> [-Receipt <path>] [-Band <C1..C4>] [-PlannerCheckpointPath <p>] [-Main origin/main]`: runs stage inference, the staleness check, hash recording, and band resolution. Prints `{preparation_status, resume_stage, research_path, spec_path, plan_path, plan_hash, base_commit, staleness:{verdict, changed_cited_paths, removed_cited_paths}, band:{value, source}, next_action}`. `next_action` is one of `admit_prepared`, `resume_preparation`, or `full_preparation`.
- `order-cohorts -Cohorts <json> -Edges "<a>:<b> ..." -Precedence "<before>:<after> ..." [-Pinned ...] [-Floor <c>]`: applies the precedence lift to a `compute-cohorts.sh` or `recolor` result. Rejects with `precedence_cycle` or `precedence_unknown_item`.
- `test-cohorts -CheckpointPath <p>`: rejects with `precedence_violated` when a current-generation cohort table violates any precedence entry.
- `record -RunFolder docs/features/parallel/<slug> -Entry <json>`: builds the durable scheduling-record content. The caller writes and commits it, so the helper performs no git write.

### Schema additions

All additions are tolerated-not-validated, declared in the rule, and need no validator change.

- **Orchestrator checkpoint items:**
  - `preparation_status` (`none|research|spec|plan|cleared`), `plan_hash`, `base_commit`, and `band_source` (`caller|planner_checkpoint|assessment`).
  - Top level: `precedence[]` with `{before, after, source, recorded_at}`, where `source` is `operator` or `phase0`.
- **Planner checkpoint items:** `plan_hash`, `base_commit`, and the same `precedence[]`. `preparation_status` is subject to D1.
- **Preparation receipt:** `docs/features/active/<folder>/evidence/other/preparation-receipt.<yyyy-MM-ddTHH-mm>.json` with `{schema_version, stage, research_path, spec_path, plan_path, plan_hash, base_commit, preflight_status, recorded_at}`. The preparation child writes it before its commit. It is added to the preparation prompt as a separate line, because the kickoff line is pinned. A newer receipt supersedes an older one, and nothing is deleted (Q13). The consumer picks the lexicographically greatest file.
- **Durable scheduling record:** `docs/features/parallel/<slug>/parallel-scheduling.json` on `parallel/<slug>-plan` with `{schema_version, parallel_slug, edges[], tolerated_overlaps[], precedence[], items[{issue_num, branch_name, plan_path, plan_hash, base_commit, preparation_status, complexity_band}]}`.
  - The planner writes it at seeding.
  - `/parallel-add` rewrites it after each admission and commits it with a pathspec under `docs/features/parallel/`. That tree is an exempt bookkeeping tree, and `.json` there is docs-only for CI.
  - The manifest stays read-only to the orchestrator.

### Stage inference

This applies when no receipt exists. It is read by ref only (`git ls-tree -r --name-only <branch> -- <folder>` and `git show <branch>:<path>`), and the highest satisfied stage wins:

- `research`: a non-empty `.md` file exists under `<folder>/research/`.
- `spec`: `<folder>/spec.md` exists, contains none of the whole-line placeholder lines of `docs/features/templates/feature/spec.md` (for example "Brief summary of the behavior and scope."), and research is satisfied.
- `plan`: a `<folder>/plan.*.md` file exists. The greatest name is selected. It has at least one task line matching `^- \[[ x]\] \[P\d+-T\d+\]` whose text is not the template placeholder, and spec is satisfied.
- `cleared`: plan is satisfied, and a committed file under `<folder>/evidence/` whose name contains `preflight` and whose text contains the literal `PREFLIGHT: ALL CLEAR` was last committed at or after the plan file's last commit (`git log -1 --format=%ct <branch> -- <path>`). Otherwise the cap is `plan` (see D4).
- A receipt, when present, takes precedence. If its `plan_hash` differs from the current blob hash, the stage is downgraded to `plan`.

### Staleness check

The check is mechanical and needs no agent.

1. `C` = the receipt's `base_commit`. Otherwise `C` = `git merge-base <main> <branch>`. `M` = `origin/main` after `git fetch origin main`. If `C` is not an ancestor of `M`, the verdict is `stale` (fail closed).
2. `cited` = `Get-PlanPaths` over the plan text, plus the normalized declared radius `paths` (`Get-BlastRadius`/`Get-NormalizedDeclaredRadius`), minus the item's own feature-folder glob.
3. `changed` = `git diff --name-only --no-renames C M`.
4. `hits` = every `(changed, cited)` pair where `Test-EntryOverlap` or an exact match holds.
5. `removed` = every concrete cited path present at `C` and absent at `M` (`git cat-file -e`). Paths the plan creates are excluded naturally, because they are absent at `C`.
6. Verdict:
   - `fresh` when `hits` is empty.
   - `premise_falsified` when `removed` is non-empty.
   - `stale` otherwise.

The verdict drives the next action:

| Stage and verdict | Action |
| --- | --- |
| `cleared` + `fresh` | Admit with no child, preflight, or replan (AC 2). |
| `cleared`/`plan` + `stale` | Resume at preflight with `hits` as findings. The single-pass rule applies: trivial defects are fixed in place, substantive defects get one planner revision, and a second failure halts (unchanged rule from `.claude/skills/orchestrate/SKILL.md` `## Delegation Model`). |
| `premise_falsified` | Resume at `plan`. The new plan is a new timestamped file; the old one is kept. |
| `plan` never cleared | Always preflight (Q12 interpretation, see D3). |
| `spec` | Resume at `plan`. |
| `research` | Resume at `spec`. |
| `none` | Full preparation. |

The resume prompt line is added after the unchanged kickoff line, for example `Preparation resume: stage <stage>. Existing artifacts: <paths>. Do not repeat a completed stage; supersede with new timestamped files.`. It must avoid mode markers and the hook issue-number pattern. The child runs on the item's pushed branch (the combination re-plan precedent), not a new branch off `origin/main`.

### Plan hash

- **Record:** after the stage reaches `cleared`, `assess` runs `git fetch origin <branch>` and then `git rev-parse origin/<branch>:<plan_path>`. The value goes to the checkpoint item, the scheduling record, and the kickoff `## Integrity` table.
- **Verify:** kickoff element 4 adds the sentence `plan-hash: <hex>; before any other step run git rev-parse HEAD:<plan-path> and stop with blocked_reason premise_falsified if it differs`. This keeps five elements. The check runs before the child reconciles with `origin/main`. The child contract in `.claude/skills/orchestrate/SKILL.md` is unchanged.

### Closed-run guard placement

- In parallel-add `## Prerequisites`, keep the run-existence check first. Then run `guard-run` with `-ManifestMode` from `validate-parallel-manifest.sh --print-mode`.
- On exit 1, stop with the helper's stderr line. Emit no `PARALLEL_MUTATION_REJECTED` signal, because the checkpoint exists. The rejection-signal pins therefore stay unchanged.

### Complexity band (Q7)

`-Band` first, then the planner checkpoint item's `complexity_band`, then `assessment_required`. With `assessment_required`, the skill runs `## Complexity Assessment` over the plan and records the rationale and floor through `Get-ComplexityFloor`. `band_source` records which source applied.

### Precedence input and rejection rule

- **Input:**
  - `/parallel-plan <slug> <item>... [--after <later>:<earlier> ...]`
  - `/parallel-add <item> [--after <earlier> ...] [--band <Cn>]`
  - Recorded as `precedence[]` with `{before: <earlier>, after: <later>}`. The key is never `depends_on`. The operator is still never asked for it, so the pinned sentence stays true; the intro phrase "no operator-supplied ordering" must be amended.
- **Validation:** both keys must resolve to items, the precedence graph must be acyclic, and `before != after`.
- **Scheduling:**
  1. Pass precedence pairs as extra `a:b` edges to `compute-cohorts.sh` or `recolor`, so the pair is always separated.
  2. `order-cohorts` then visits items in topological order (ties by ascending key). It moves any `after` item whose index is not above every `before` index to the smallest index above all of them that no conflict neighbor, including a pinned neighbor, holds. Unstarted items only move upward, and pinned items never move.
  3. In `/parallel-add`, a candidate with an unmerged predecessor is forced to `defer_and_recolor` even when `admit` returns `admit_current_cohort`.
- **Rejection:** a current-generation cohort table is rejected (`test-cohorts`, exit 1) when, for any entry whose `before` is not `merged`/`worktree_removed`/`withdrawn`, `cohort(after) <= cohort(before)`.
- **Where the check runs:** in place of the P5 parity step (recompute through `compute-cohorts.sh` plus `order-cohorts`, then assert equality), after each parallel-add recolor, and in Layer 1 of the barrier hook.
- **Residual:** the Python Layer 2 validator does not see precedence.

### Durable edge location

`docs/features/parallel/<slug>/parallel-scheduling.json` on `parallel/<slug>-plan`, as described under Schema additions. A re-seed reads it by ref (`git show origin/parallel/<slug>-plan:<path>`). It reuses an item's recorded edges only when that item's recorded `plan_hash` equals the current blob hash; otherwise it recomputes them.

### Turn gap

In `## Per-Item Merge to Main (Merge-on-Green)`, on child completion the parent:

1. Reads the child checkpoint at `<worktree>/artifacts/orchestration/orchestrator-state.json`. The worktree path comes from `git worktree list --porcelain`.
2. If `step9_status != "passed"` or `blocked_reason == "awaiting_ci"`, keeps `merge_status: pr_open` and treats the item as not done.
3. Polls `gh pr checks` with `Invoke-CiGateParser.ps1` until the conclusion is terminal.
4. Re-delegates the child once with a resume-at-S9 prompt, the same re-delegation mechanism as `## Per-Item Merge-Conflict Handling`. The CI-failure cycle counts toward `remediation_loop`.

`ci_green` is recorded only after that.

## Behavior Semantics and Edge Cases

- **One item per invocation:** the flags `--after` and `--band` are not items, and the multi-item rejection still applies to positional items.
- **Receipt and blob disagree:** the stage is downgraded to `plan` and preflight runs.
- **Predecessor state:** a `withdrawn` predecessor releases the constraint, and a `blocked` predecessor holds the dependent (D6).
- **Combination interaction:** a combined item inherits the union of its members' precedence entries. A pair inside one combination is dropped.
- **Ready gate:** a seed from prepared items with no child still needs P10 (band, assessment, routing receipt computed by the planner). `topology_receipt` is recorded as not applicable, because no preparation child ran.

## Testing Implications

- **Pester:**
  - Pure-function suites for each stage-inference row, each staleness verdict (including a non-ancestor base and a removed path), the guard matrix (mode closed, close mutation, mismatch, open), band precedence, cycle and unknown-key rejection, lift correctness (independence preserved, pinned unchanged, monotone), and the `test-cohorts` rejection.
  - CLI suites mock `Invoke-ParallelAdmissionGit` and `Read-...JsonText`.
  - A manifest suite modeled on `ParallelDrift.Manifest.Tests.ps1`.
  - Hook suite cases for precedence allow and deny.
- **pytest:** existing contract tests are kept green. Add fragment pins only where new text must be protected.
- **bats:** no change.
- **Integration (local evidence):**
  - Seed a run from prepared items and confirm the precedence order holds.
  - Add a half-prepared item and confirm it resumes at the first missing stage.
  - Add to a closed run and confirm the error.

## Pre-Mortem

- Review checklists: a reviewer can flag new per-item fields as violating "No field ... is added to `items[]`" (parallel-add `## Constraints`) and "add no field ... the rule does not declare". Mitigation: the plan amends both sentences and declares every field in `.claude/rules/parallel-orchestration.md` in the same change.
- Coverage: the new PowerShell files sit under the `.claude/lib` coverage root and need 85% line coverage. The git and file I/O lines fail this unless isolated. Mitigation: keep all git and file calls in one seam function in `Invoke-ParallelAdmission.ps1`, mocked in Pester, and read per-file coverage from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: every edited `.claude` file has a bundle copy, and the three new lib files need `core.json` entries. A missed copy fails `test_push_down_claude_resource_contracts.py` or pack-manifest completeness. Mitigation: one task per primary/bundle pair, plus the new Manifest suite. No brief-update task is needed (question 8), and the plan's Mirror parity bullet must state that.
- File size: `ParallelAdmission.psm1` could grow past 500 lines if stage inference, staleness, guard, and band all go in one module. Mitigation: split precedence into its own module now, and split again at the 500-line guidance. The 800-line hard limit is checked by `ClaudeLibModuleConvention.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1`.
- Test isolation: suites that import `BlastRadius.psm1` and the new modules can leak module scope across shards. Mitigation: `-Force` imports in `BeforeAll`, `Remove-Module` in `AfterAll`, seeded shuffled file-order runs with three seeds, and a concurrent-shard run.
- CI-only behavior: the hook suites run on Linux with a case-sensitive filesystem, and fixtures with drive letters or CRLF fail there. Mitigation: forward-slash relative fixture paths, `Join-Path`, and in-memory LF text. No test diffs against `origin/main`, because shell-coverage checks out at depth one.
- Evidence: the integration scenarios need real `git` and `gh` runs that CI does not perform. Mitigation: record them under `<FEATURE>/evidence/regression-testing/` with the `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` fields and a UTC stamp read from the clock. Each run is marked as local evidence.

## Risks

- **Scope:** about 15 primary files plus bundles, a hook change, and six behaviors. This is larger than a typical single feature. Consider splitting into child items (admission core and guard; precedence and durable edges; turn gap). Owner decision D7.
- **Route:** the work needs the `large` route. Six new PowerShell production files (three primaries and three bundle copies) plus the hook pair exceed the direct-mode cap of three per kind.
- **Hook visibility:** the hook change is exercised by isolated subagents only after merge. Proof is by Pester, per `## Hook Execution Context`.
- **Fork assumption:** the forks may run in an agent-isolated worktree in some sessions, where `pwsh` text is refused. The fallback is a `sh` launcher; this needs confirmation in a live run.
- **Inference accuracy:** placeholder detection may fail on a spec that quotes template text. This errs toward redoing a stage, which is the safe direction.
- **Layer 2 gap:** the Layer 2 Python validator does not check precedence.

## Open Decisions

- D1: `preparation_status` collides with the planner checkpoint's existing ready value `prepared` (P7). Options: amend P7 to accept `cleared`, which requires a one-constant edit to existing Python and the TS port; or keep `prepared` as the ready value on the planner checkpoint and use the five values only on the orchestrator checkpoint. Recommended: amend P7 and accept `prepared` as a legacy synonym. Q6 may forbid this edit, so the owner must confirm.
- D2: precedence pairs cannot go into `conflict_edges[]` without a fifth `reason` member, which would need a Python validator change. Recommended: a tolerated `precedence[]` plus a Layer 1 hook extension, with the Layer 2 gap accepted.
- D3: whether "checked the same way" (Q3) lets a never-cleared but fresh plan skip preflight. Recommended: no, because Q12 says "fully prepared" includes a cleared preflight.
- D4: the evidence rule for inferring `cleared` on pre-feature branches (committed preflight evidence newer than the plan), or always capping inference at `plan`.
- D5: precedence source. Recommended: operator flags only. Q-text alternative: parse Phase 0 gates, which are prose and not mechanically reliable.
- D6: the precedence semantics of a `withdrawn` or `blocked` predecessor.
- D7: whether to split the work into child items or an epic.
- D8: the receipt location and format (`evidence/other/*.json` vs. the feature-folder root).
- Q14: the promoted record cites "Q1 to Q14" but enumerates only Q1-Q13. A search of the worktree for `Q14` found no matching decision. The only other `Q14` hit is `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/requirements-traceability.md` (an unrelated feature) and its evidence files. Q14 is not recorded in the worktree and must come from the owner.

## Automation Feasibility

The work is fully automatable. Every step is file edits, Pester, pytest, and contract-test runs, plus local `git` and `gh` integration runs that need no human interaction. Two items depend on owner input rather than on interaction during execution:

- The open decisions D1-D8 and Q14 must be resolved at spec review.
- Recording the live integration scenarios needs a prepared test run, which the orchestrator can set up.

## Numeric Derivation Evidence

This section supports the one count stated in this research: the number of Codex, Agents, or GitHub twins of the target parallel surface files. It is not a spec.md acceptance criterion.

- Complete Family: .agents, .codex, .github
- Exhaustive Search Scope: all of the item worktree tree under the three customization roots .agents, .codex, and .github
- Inclusion Rules: a file whose path or content names parallel-add, parallel-plan, parallel-orchestrate, parallel-planner, parallel-orchestrator, parallel-run, parallel-close, or parallel-remove as its own skill or agent identity
- Exclusion Rules: hook files that only reference parallel mode markers (the two .codex preimplementation-gate hooks), which are not twins
- Primary Search Strategy or Query Expression: Glob of the path patterns `**/parallel-*/**` under .agents and `**/*parallel*` under .codex and .github
- Primary Member Set: .agents-none, .codex-none, .github-none
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: content Grep of the regex `parallel-(add|plan|orchestrat|planner|run|close|remove)` across .agents, .codex, and .github, excluding marker-only hooks
- Cross-check Member Set: .agents-none, .codex-none, .github-none
- Cross-check Count: 3
- Member-set Comparison: both strategies yield an identical member set of three roots, each with no twin file. The twin count is therefore zero in every root.
