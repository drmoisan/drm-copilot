# Research: Cross-epic dependencies (Issue #1162)

- Issue: #1162
- Branch: feature/cross-epic-dependencies-1162
- Work mode: full-feature (preparation-mode research input for spec.md, user-story.md, and the atomic plan)
- Requirements source: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/issue.md` (six acceptance criteria)
- Timestamp note: the researcher has no clock tool. The filename stamp was taken from the session context (the issue mirror records `gh issue view` at 2026-11-09T21:33Z and the plan stub is stamped 16-32 America/New_York, which is 21:32 UTC). The orchestrator may rename the file to a clock-read stamp; no content depends on it.

All findings below were verified by reading the named files in this worktree unless they are listed under `## Facts for the Orchestrator to Confirm`. Execution-environment facts (tool routes, CI shape, contract tests, batch budget) are cited from `.claude/skills/execution-environment/SKILL.md` and are not restated.

---

## 1. Current State

### 1.1 Where the epic manifest is defined

- Schema authority: `.claude/skills/epic-orchestrate/SKILL.md`, section `## Epic Dependency Manifest`. The manifest is the YAML frontmatter of `docs/features/epics/<epic-slug>/epic.md`: `epic`, `integration_branch`, `created_at`, optional `intent`, and `features[]` entries of `issue_num`, `feature_folder`, `depends_on` (array of `issue_num`, legacy folder basenames tolerated). An unresolved `depends_on` entry or a duplicate `feature_folder` is "rejected before epic kickoff as a synthetic Blocking finding". The optional per-feature `early_start_on` field (issue #1097) is documented under `## Early Dependent Starts (early_start)`; it moves no wave because the wave computation reads only `depends_on`.
- `.claude/skills/epic-plan/SKILL.md` (`## Decomposition and Wave Design`) consumes that schema and does not redefine it.
- Codex variant: `.agents/skills/epic-orchestrate/SKILL.md` (`## Manifest Contract`) restates the schema in its own wording; it is not a byte mirror of the Claude skill.
- Templates: `docs/features/templates/epic/epic.md` and the bundled copy `extensions/drm-copilot/resources/feature-templates/epic/epic.md` (verified identical frontmatter). A second bundled template, `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md`, is pinned by `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` through the test-only parser `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1`.

### 1.2 Where the manifest is parsed

There is no production manifest parser. Three consumers read manifest-derived data:

1. **Wave computation.** `.claude/lib/epic-wave/EpicWave.psm1` (`Get-EpicWaveNumber`, `Invoke-EpicWaveCommand`, `ConvertTo-EpicWaveManifest`) and the CLI `.claude/lib/epic-wave/Invoke-EpicWave.ps1` take a JSON object of `feature` to an array of dependency strings, which the agent transcribes from the manifest. `ConvertTo-EpicWaveManifest` returns `$null` (usage error, exit 2) for any value that is not an array of strings. Errors: `EPIC_WAVE_SELF_LOOP:`, `EPIC_WAVE_UNRESOLVED_REFERENCE:`, `EPIC_WAVE_CYCLE:`. Python parity reference: `scripts/dev_tools/epic_wave_computation.py`; TypeScript: `extensions/drm-copilot/src/lib/validate/epic-wave-computation.ts`; shared corpus `tests/fixtures/epic_wave/wave-computation-cases.json`; tests `tests/scripts/claude-lib/epic-wave/EpicWave.Tests.ps1`, `tests/scripts/claude-lib/epic-wave/EpicWave.Parity.Tests.ps1`, `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py`.
2. **Checkpoint validators** validate the manifest as projected into checkpoint `features[]`:
   - `scripts/dev_tools/validate_epic_orchestrator_state.py` (`validate_epic_orchestrator_state_text`, `_validate_feature_folder_uniqueness_and_dependencies`, `_validate_completion`) with helpers `scripts/dev_tools/_epic_orchestrator_state_resolution.py` (`build_feature_reference_index`, `resolve_feature_reference`, `detect_dependency_cycle`, `validate_intent_block`), `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, and `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`. A `depends_on` entry that resolves to no `features[]` entry yields `Epic checkpoint feature '<f>' depends_on unresolved ...`.
   - `scripts/dev_tools/validate_epic_planner_state.py` (`REQUIRED_FEATURE_KEYS` includes `depends_on` and `wave`; `_validate_dependency_waves` recomputes waves through `compute_wave_numbers`).
   - TypeScript ports: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`, `epic-orchestrator-state-resolution.ts`, `epic-orchestrator-state-wave-barrier.ts`, `epic-planner-state-core.ts`.
   - PowerShell Layer 2 port: `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (`Get-OrchestratorStateEpicWaveBarrierError`), called by `Get-OrchestratorOutputWaveBarrierDecision` in `.claude/hooks/validate-orchestrator-output-resolution.ps1`, which `.claude/hooks/validate-orchestrator-output.ps1` runs for `epic-orchestrator-state`. Parity corpus `tests/fixtures/epic_wave_barrier/`.
   - None of these validators rejects unknown keys on a `features[]` entry, so a new key is tolerated by default.
3. **Progress report manifest reader.** `Read-EpicProgressManifestFeature` in `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` is a line parser over the frontmatter `features:` block. It accepts `- key: value` and indented `key: value` lines; a `depends_on` value must be an inline flow list. **Any other line that begins with `-` inside `features:` makes the function return no rows at all** (the branch commented "A block-style list item: this reader parses inline lists only"). A non-`depends_on` key is stored as a raw string, so a single-line inline value for a new key is harmless.

### 1.3 Consequences for a cross-epic edge

- A cross-epic reference placed inside `depends_on` would break every consumer: `EPIC_WAVE_UNRESOLVED_REFERENCE` in the wave CLI, the unresolved-dependency error in both Python validators and the TypeScript ports, the Layer 1 hook deny (missing dependency record), and `Get-EpicProgressDependencyGraph` (unresolved reference, whole graph falls back to waves).
- A separate per-feature key is excluded from wave and cycle computation by construction, because every wave and cycle routine reads only `depends_on`. No change to `EpicWave.psm1`, `epic_wave_computation.py`, or `epic-wave-computation.ts` is needed for exclusion.
- A block-style YAML list under a new key would silently disable the progress report's manifest fallback for the whole epic (section 1.2 item 3). The manifest form must be single-line inline, or the reader must change.

### 1.4 Epic-orchestrate flow (launch, readiness, integration PR)

- Launch: `.claude/skills/epic-orchestrate/SKILL.md` `## Epic Integration Branch Lifecycle` steps 2 to 4 and `## Merge-on-Green Kickoff Parameter`; agent `.claude/agents/epic-orchestrator.md` `## Wave Scheduling` ("Within a wave, launch all features concurrently").
- Readiness today: per-dependency `merge_status` in `merged` or `worktree_removed`, enforced by Layer 1 `.claude/hooks/enforce-epic-wave-barrier.ps1` (deny `EPIC_WAVE_BARRIER_BLOCKED`) and Layer 2 (section 1.2). Early start is the only exception path.
- Main sync precedent: step 3 of `## Epic Integration Branch Lifecycle` merges `origin/main` into the integration branch with `git merge --no-ff origin/main`, resolving conflicts, no rebase, no force push, then pushes. No hook gates `git merge` (verified: no `git merge` handling in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; the only hook matches are `enforce-epic-merge-gate-review.ps1` and a prose mention in `enforce-docs-complete-gate.ps1`). A cross-epic integration merge can follow the same procedure.
- Integration-to-main PR: step 6 of the same section (open via `Agent(pr-author)`, S9 CI gate with `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, record under `epic_merge_pr`, `gh pr merge --merge`, confirm with `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`). Completion requirement 2 of `## Completion Requirements`.
- Checkpoint shape: `## Epic-Level Checkpoint` (`features[]` with `merge_status` enum `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`; `epic_merge_pr`; receipts).
- Agent tool grants (`.claude/agents/epic-orchestrator.md` frontmatter): `Bash(git *)`, `Bash(gh *)`, and three exact `pwsh -NoProfile -File` grants (CI gate parser, merge confirmation parser, wave CLI) plus the Poetry validator CLI. There is no `sleep` grant. `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` (`test_every_prescribed_pwsh_invocation_has_an_epic_persona_bash_grant`) requires a grant for every `pwsh` invocation the epic skills prescribe.
- Frozen-surface pins: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES` pins SHA-256 digests of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, asserted by `test_frozen_epic_surface_matches_pinned_baseline_digest` in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`. Each prior change re-baselined by replacing the digest and appending a `# RE-BASELINED by issue #<n>.` comment paragraph above the tuple naming which digest moved and which merges were combined.

### 1.5 Epic progress report (after #1153)

- Pure scheduling: `Get-EpicProgressReport.Schedule.ps1` (`Get-EpicProgressDependencyGraph`, `Find-EpicProgressDependencyCycle`, `Get-EpicProgressBlockedClosure`, `Get-EpicProgressLongestPath`, `Invoke-EpicProgressListSchedule`, `Resolve-EpicProgressParallelCap`).
- Pure composition: `Get-EpicProgressReport.CriticalPath.ps1` (`Get-EpicProgressCriticalPathReport`, `Get-EpicProgressCriticalChain`, `Get-EpicProgressEpicTail`, `Get-EpicProgressScheduleRange`, `Get-EpicProgressFeatureRemainingSecond`).
- Reads: `Get-EpicProgressReport.Gather.ps1` (`Read-EpicProgressManifestFeature`, `Read-EpicProgressText` through `Invoke-GitExe` `show`, `Get-EpicProgressStepReport` which returns `DependencyRow` from the epic checkpoint `features[]`).
- Wiring: `Get-EpicProgressReport.ps1` (`Invoke-EpicProgressReport`), with I/O wrappers `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Get-EpicProgressUtcNow`. Hub `Get-EpicProgressReport.Logic.ps1` dot-sources the ten part files in a fixed list. The skill imports nothing outside its folder (stated in the Schedule file header).
- Scheduling semantics relevant to external nodes: in `Invoke-EpicProgressListSchedule`, a dependency that is not a node is treated as satisfied, `running` nodes start at 0 and occupy cap slots, and `pending` nodes start only while fewer than `Cap` run. An external prerequisite therefore cannot be modeled as a plain node without consuming this epic's cap.
- Contract test: `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` pins skill wording; per-file tests exist for every part file under `tests/scripts/claude-skills/epic-progress-report/`.
- Repository wrapper `scripts/dev-tools/Get-EpicProgressReport.ps1` forwards arguments; unchanged by this feature.

### 1.6 Merge gate hooks

- `.claude/hooks/enforce-epic-merge-gate.ps1` branch 2 (`Test-EpicCheckpointAllowsMerge`) allows the integration-to-main merge when `epic_merge_pr.ci_gate.conclusion == "success"` and the PR number matches. It trusts the on-disk checkpoint and calls no `gh` (documented design decision in the file header). Codex twin `.codex/hooks/enforce-epic-merge-gate.ps1`. Helpers `enforce-epic-merge-gate-review.ps1` and `enforce-epic-merge-gate-child-ci.ps1` are byte-identical across `.claude/hooks/` and `.codex/hooks/`.
- No hook today knows about other epics. The PR-author epic base-branch check (`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`) only requires the integration PR base to be `main`.

---

## 2. Candidate Approaches and Decisions

Each decision gives one recommendation. Every new behavior applies only when a manifest feature carries the new key; a manifest without it behaves exactly as today.

### D1. Manifest syntax for a cross-epic edge

- Option A: put cross-epic references inside `depends_on` with a qualified string. Rejected: breaks the wave CLI, three validators, the Layer 1 hook, and the progress-report graph (section 1.3).
- Option B: a new per-feature key with block-style YAML objects. Rejected: disables the progress report's manifest fallback for the whole epic (section 1.2 item 3).
- **Recommendation (Option C):** a new optional per-feature key `cross_epic_depends_on`, written on one line as an inline flow sequence of flow mappings with exactly three keys:

  ```yaml
  features:
    - issue_num: 1201
      feature_folder: 2026-11-10-consumer-feature-1201
      depends_on: []
      cross_epic_depends_on: [{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]
  ```

  Rules: `epic` is the other epic's slug (one plain segment of `A-Za-z0-9._-`); `integration_branch` must equal `epic/<epic>-integration`; `issue_num` is a positive integer naming a `features[]` entry of the other epic's manifest. `epic` must differ from this manifest's `epic`. Duplicate `(epic, issue_num)` pairs on one feature are rejected. `early_start_on` may not name a cross-epic issue (it must already be one of `depends_on`). An absent key or `[]` means no cross-epic edge. Cross-epic edges move no wave.

### D2. Location and language of the pure readiness logic

- Option A: a new directory under `.claude/lib/`. Requires a new Codex virtual resource mapping in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` (`VIRTUAL_RESOURCE_DIRECTORIES`), a new Jest case, and a new bundled resource directory.
- **Recommendation (Option B):** PowerShell, inside the existing `.claude/lib/epic-wave/` directory, which already has the Codex mapping `[".codex/lib/epic-wave", "lib/epic-wave"]` and the byte-identity check in `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py`:
  - `.claude/lib/epic-wave/EpicCrossDependency.psm1`: pure functions plus the two thin adapter wrappers (section 3).
  - `.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1`: thin CLI entry, same shape as `Invoke-EpicWave.ps1` (an `Invoke-EpicCrossReadinessCommand` function in the module returns `ExitCode`, `Stdout`, `Stderr`; the script prints and exits).
  - No new Python file; TypeScript only where existing validator ports are extended (D6).

### D3. Source of truth for prerequisite merge state (feature hold)

- Option A: parse the other epic's `epic-status.md`. Rejected: it is an agent-generated projection whose table and prose vary between epics (verified in `docs/features/epics/claude-runtime-portability/epic-status.md`), and it may lag the merge.
- Option B: match a merged PR by head-branch suffix or body issue token. Rejected as the sole rule: epic-child PR bodies may omit the `- Closes #<n>` line (`.claude/hooks/enforce-model-routing-receipt.ps1` allows the omission for an epic child), and branch naming is a convention, not a contract.
- **Recommendation (Option C):** identify the prerequisite by its feature folder, which every child PR modifies (plan checkboxes and evidence). Steps:
  1. Read the other epic's manifest with `git show origin/<integration_branch>:docs/features/epics/<epic>/epic.md`; when the branch no longer exists, read it from `origin/main`. Resolve the `issue_num` to its `feature_folder` basename.
  2. `gh pr list --base <integration_branch> --state merged --limit 200 --json number,headRefName,mergeCommit,files`.
  3. Pure match: the PRs whose `files` include a path under `docs/features/active/<basename>/` or `docs/features/completed/<basename>/`. Exactly one match is required; zero holds with `PREREQ_PR_NOT_FOUND`, more than one holds with `PREREQ_PR_AMBIGUOUS` (fail closed).
  4. Ancestry: `git merge-base --is-ancestor <mergeCommit.oid> origin/<integration_branch>`; exit 0 is ancestor, exit 1 is not, any other exit is an adapter error.

### D4. Integration merge on release

**Recommendation:** reuse the main-sync procedure of step 3 of `## Epic Integration Branch Lifecycle`. Before launching the released feature, `epic-orchestrator` runs `git fetch origin <other integration_branch>`, checks `git merge-base --is-ancestor <prerequisite merge commit> origin/<own integration_branch>` (already integrated: no merge), otherwise `git merge --no-ff origin/<other integration_branch>` in the integration worktree, resolves conflicts as step 3 does, pushes, re-fetches its own integration branch (step 2), records the merge, and only then launches the feature branched from the updated `origin/<own integration_branch>`. When the other integration branch no longer exists and the prerequisite merge commit is an ancestor of `origin/main`, the decision is `release` with reason `PREREQ_IN_MAIN`, and the existing main sync (step 3) brings the change in; no extra merge is made. The merge is a direct merge commit, never a rebase or fast-forward.

### D5. Integration-to-main hold mechanism

- Option A: extend merge-gate branch 2 in `.claude/hooks/enforce-epic-merge-gate.ps1` and its Codex twin with a checkpoint-only check. Rejected for this item: the file is at 500 lines, the twin must change in step, and the sibling items #1156 and #1159 are likely to touch the merge gates and hook registration; a hook change would also make this item's acceptance depend on a branch hook that isolated subagents do not exercise (execution-environment brief, `## Hook Execution Context`).
- **Recommendation (Option B):** a skill-level gate driven by the same pure module, plus a key-gated retrospective validator invariant:
  - Hold point: before step 6 of `## Epic Integration Branch Lifecycle` opens the integration-to-main PR, `epic-orchestrator` runs `Invoke-EpicCrossReadiness.ps1 -Mode main`. For each distinct prerequisite epic named by any feature: `gh pr list --head <other integration_branch> --base main --state merged --json number,mergeCommit`, exactly one result, and `git merge-base --is-ancestor <mergeCommit.oid> origin/main`. Release only when every prerequisite epic releases. On release, run step 3 main sync (so the PR diff no longer carries the other epic's commits), then open the PR. Re-run the check immediately before `gh pr merge` (cheap, and it covers a resumed run).
  - Record: top-level `cross_epic_main_gate` in the epic checkpoint (D7).
  - Backstop: under `require_complete`, a checkpoint whose features carry `cross_epic_depends_on` must record `cross_epic_main_gate.status == "released"` with one verified entry per prerequisite epic (D6).
  - Honest disclosure for the skill text: the merge gate hook does not read `cross_epic_main_gate`; the hold is a skill-level policy control with a retrospective validator backstop, consistent with the checkpoint-cache doctrine.

### D6. Validation surfaces for the new keys

**Recommendation:**
- Manifest validation (authoritative at kickoff): `Get-EpicCrossDependencyManifestError` in `EpicCrossDependency.psm1`, run by the CLI `-Mode validate` against the committed `epic.md`. `epic-orchestrator` runs it at kickoff with the wave CLI; any error is the same synthetic Blocking finding as an unresolved `depends_on`. `epic-planner` relies on the checkpoint validator (next bullet) so no new planner tool grant and no change to the Codex planning-only allowlist in `.codex/hooks/enforce-epic-planning-only.ps1` is needed.
- Checkpoint validation, key-gated (absent key: byte-identical results), extending existing files in place:
  - Shape of `features[].cross_epic_depends_on`: Python in `scripts/dev_tools/_epic_orchestrator_state_resolution.py` (one function used by both `validate_epic_orchestrator_state.py` and `validate_epic_planner_state.py`); TypeScript in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts`, called from `epic-orchestrator-state-core.ts` and `epic-planner-state-core.ts`.
  - Started-while-held invariant (Layer 2 analogue): a feature treated as started by the existing start guard (string `worktree_created_at`, or `merge_status` other than `not_started`) whose every `cross_epic_depends_on` entry does not record `status` `integrated` or `in_main` yields `EPIC_CROSS_DEPENDENCY_VIOLATION: <f> is treated as started while cross-epic dependency <epic>#<n> is not integrated`. Python in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, TypeScript in `epic-orchestrator-state-wave-barrier.ts`, PowerShell in a new `.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1` imported (guarded, fail closed) and appended by `Get-OrchestratorStateEpicWaveBarrierError` in `OrchestratorStateEpicWaveBarrier.psm1`, so the existing stop hook surfaces it with no hook-file change.
  - Completion invariant (D5 backstop): Python in `_validate_completion` of `validate_epic_orchestrator_state.py`; TypeScript in `epic-orchestrator-state-core.ts`.
  - Byte-identical error strings across the three runtimes, pinned by a new shared corpus `tests/fixtures/epic_cross_dependency/` read by a Python test, a Jest test, and a Pester parity test (the `tests/fixtures/epic_wave_barrier/` precedent).
  - Validator route: installed MCP lags the new rules until a release; the skill states the D9 route already used by early start (repository CLI `scripts.dev_tools.validate_orchestration_artifacts` with the `epic-orchestrator-state` subcommand through Poetry in module form, which the agent's existing grant permits).

### D7. Checkpoint records

**Recommendation:** no new `merge_status` member (a held feature stays `not_started`; the enum, its three-runtime parity, and the progress report's state mapping are untouched). New tolerated, key-gated records:
- Per feature in the epic checkpoint: `cross_epic_depends_on[]` copied from the manifest, each entry extended with `status` (`held`, `released`, `integrated`, `in_main`), `reason` (last reason code), `prerequisite_pr_number`, `prerequisite_merge_commit_sha`, `verified_at`, and after D4 `integration_merge_commit_sha` and `integrated_at`.
- Top level: `cross_epic_main_gate` `{ status: held|released, prerequisites: [{ epic, integration_branch, pr_number, merge_commit_sha, verified_at }] }`, written only when some feature carries the key.
- Planner checkpoint: `features[].cross_epic_depends_on` copied from the manifest (shape-validated only).
- `epic-status.md` gains a "Cross-epic" column or table only when the key is present.

### D8. Hold waiting policy

The agent has no `sleep` grant, and a Bash call is bounded by the tool timeout.
**Recommendation:**
- Holds are re-evaluated at every scheduling event (each child return, each wave boundary, resume).
- When every runnable feature is held and nothing is in flight, `epic-orchestrator` calls the CLI with `-WaitSeconds 540`; the CLI polls internally every 60 seconds through an injected sleep seam and returns at the first release or at the bound. The agent repeats the call at most 40 times (about six hours), then records `blocked_reason: "external_dependency"` and the hold records, regenerates `epic-status.md`, and stops; `/epic-run <epic-slug>` resumes. These two constants are stated in the skill as orchestrator defaults (the early-start precedent states 30 seconds and 90 minutes the same way); they are not configuration knobs.

### D9. Critical-path modeling in the progress report

- Option A: ignore unmerged cross-epic prerequisites (treat as satisfied, as the scheduler does for a non-node dependency). Rejected: fails AC4.
- Option B: model the main hold as an extra tail term. Not required by AC4 and depends on another epic's tail, which the report cannot read reliably; recorded as a Full-report status line only.
- **Recommendation (Option C):** external nodes.
  - Source of edges: the epic checkpoint row's `cross_epic_depends_on` when present (with `status`), else the manifest value parsed from the raw string that `Read-EpicProgressManifestFeature` already stores for an unknown key. No change to the reader's abort rule is needed because D1 keeps the value on one line.
  - Node identity: `<epic>#<issue_num>` (non-numeric, so `Compare-EpicProgressIssue` orders it by ordinal text after numeric issues).
  - State: `done` when the checkpoint entry records `integrated` or `in_main`; otherwise `pending`.
  - Duration: the other epic's prepared plan is read once per prerequisite through the existing `Read-EpicProgressText` seam (`git show origin/<other integration_branch>:<plan path>` with the plan path from the other epic's kickoff table, read with `git show` of `docs/features/epics/<epic>/epic-kickoff.md`). Remaining execution tasks are priced at the pooled rate and the other step types at their medians, as for a kickoff feature without a checkpoint. When the other epic has no kickoff (a manually authored epic) or the plan is unreadable, the node is priced at the per-type defaults with zero execution tasks and labeled `external (default)`.
  - Cap: external nodes do not occupy this epic's cap. `Invoke-EpicProgressListSchedule` gains a node property `External` and excludes such nodes from the cap count; with no external node the schedule is byte-identical.
  - Steps and percentage: external nodes add no steps (the predicted main-sync precedent, which "enters the time figures only").
  - Rendering: the chain prints an external node as `<epic>#<issue>` without the leading `#` used for local issues (`Get-EpicProgressCriticalChain`); the Full report adds one `**Cross-epic:**` line listing each edge and its state, present only when an edge exists. The five TL;DR lines keep their shapes.
  - Blocked closure and range: external nodes are never blocked; `Get-EpicProgressScheduleRange` re-prices them with the side rate like any other node.
  - New logic goes in a new part file `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1` (pure edge parsing, external node construction, and its reads through existing seams), dot-sourced by `Get-EpicProgressReport.Logic.ps1`.

### D10. Context handoff for a released feature

**Recommendation:** after D4, the child delegation carries one citation line per cross-epic dependency, appended after the epic-mode kickoff line, parallel to `## Context Handoff to Dependent Features`:
`Upstream context for <issue_num>: cross-epic depends on <epic>#<dep_issue_num> (spec: <dep_folder>/spec.md; plan: <dep_folder>/plan.<ts>.md; merged as PR #<pr>, commit <sha>, into <other integration_branch>; integrated into <own integration_branch> as <sha>).`
In preparation mode (`epic-plan`), the preparation prompt carries the same line with `not merged` in place of the merge facts, so the dependent spec and plan cite the upstream contract.

---

## 3. Pure Readiness Module Design (`.claude/lib/epic-wave/EpicCrossDependency.psm1`)

### 3.1 Pure functions (no I/O, no clock, no process)

| Function | Inputs | Output |
|---|---|---|
| `ConvertFrom-EpicCrossDependencyManifest` | manifest text | `Epic`, `IntegrationBranch`, `Feature[]` (`IssueNum`, `FeatureFolder`, `DependsOn`, `CrossEpic[]`), `Error[]` |
| `Get-EpicCrossDependencyManifestError` | parsed manifest; optional map of other-epic slug to parsed manifest (`$null` when unreadable) | ordered error strings |
| `Get-EpicCrossDependencyPrerequisitePr` | PR list snapshot JSON; prerequisite folder basename | `Match` (number, merge commit) or reason `PREREQ_PR_NOT_FOUND`, `PREREQ_PR_AMBIGUOUS`, `PREREQ_SNAPSHOT_INVALID` |
| `Get-EpicCrossDependencyFeatureDecision` | edge; PR match result; ancestry results (`ancestor`, `not_ancestor`, `branch_absent`, `error`) against the other integration branch, the own integration branch, and `origin/main` | `Decision` (`hold`, `merge_required`, `release`), `Reason`, evidence fields |
| `Get-EpicCrossDependencyMainGateDecision` | per prerequisite epic: main PR snapshot and ancestry against `origin/main` | `Decision` (`not_applicable`, `hold`, `release`), per-epic `Reason` |

Manifest error codes (prefix `EPIC_CROSS_DEPENDENCY_`): `MALFORMED` (value not an inline flow sequence of flow mappings, missing or extra key, wrong type), `UNSUPPORTED_FORM` (block-style value under the key), `BRANCH_MISMATCH`, `SAME_EPIC`, `DUPLICATE`, `UNRESOLVED` (issue not in the other manifest), `MANIFEST_UNREADABLE` (other manifest absent on both its integration branch and `origin/main`), `CYCLE` (a feature-level cycle in the union of this manifest and the directly referenced manifests, one hop).

Feature decision table (evaluated in order; first match wins):

| Condition | Decision | Reason |
|---|---|---|
| any adapter error or invalid snapshot | hold | `PREREQ_UNVERIFIABLE` |
| other integration branch absent and prerequisite merge commit is an ancestor of `origin/main` | release | `PREREQ_IN_MAIN` |
| no matching merged PR | hold | `PREREQ_PR_NOT_FOUND` |
| more than one matching PR | hold | `PREREQ_PR_AMBIGUOUS` |
| merge commit not an ancestor of the other integration branch | hold | `PREREQ_NOT_ANCESTOR` |
| merge commit already an ancestor of the own integration branch | release | `PREREQ_ALREADY_INTEGRATED` |
| otherwise | merge_required | `PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED` |

A feature with several cross-epic edges is released only when every edge is `release`; any `hold` holds it; otherwise `merge_required` lists the distinct integration branches to merge.

Main-gate table per prerequisite epic: no merged PR from the other integration branch to `main` holds with `MAIN_PREREQ_PR_NOT_MERGED`; more than one holds with `MAIN_PREREQ_PR_AMBIGUOUS`; a merge commit not an ancestor of `origin/main` holds with `MAIN_PREREQ_NOT_ANCESTOR`; adapter error holds with `MAIN_PREREQ_UNVERIFIABLE`; otherwise `MAIN_PREREQ_RELEASED`. No cross-epic edge in the manifest gives `not_applicable`.

### 3.2 Thin adapters (the only I/O)

- `Invoke-EpicCrossGhExe -GhArgs <string[]>` and `Invoke-EpicCrossGitExe -GitArgs <string[]>`: wrapper seams per `.claude/rules/powershell.md` `## Design Seams (Minimal DI)`, each returning output lines and the exit code (read through a `Get-EpicCrossLastExitCode` seam, the `Get-EpicProgressLastExitCode` precedent). Tests mock the wrappers, never `gh` or `git`.
- Gather functions call only the wrappers: `Read-EpicCrossManifestText` (`git show`), `Get-EpicCrossPrSnapshot` (`gh pr list` as in D3 and D5), `Test-EpicCrossAncestor` (`git merge-base --is-ancestor`, exit 0, 1, other).
- Wait seam for D8: `Wait-EpicCrossInterval -Seconds` (wraps `Start-Sleep`) and `Get-EpicCrossUtcNow`; tests inject both, so no test sleeps or reads the wall clock.
- No temporary files: manifest and snapshot text pass as strings; the CLI reads `epic.md` from `-ManifestPath` through an injectable reader (the `Invoke-EpicWaveCommand` `-ReadManifestText` precedent).

### 3.3 CLI contract (`Invoke-EpicCrossReadiness.ps1`)

`pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 -Mode validate|feature|main -ManifestPath <path> [-Issue <n>] [-WaitSeconds <0..540>]`. Output is compressed JSON on stdout. Exit 0 when a decision or a clean validation was produced (a `hold` is a valid decision), 1 for manifest validation errors (message on stderr with the `EPIC_CROSS_DEPENDENCY_` codes), 2 for a usage error. Adapter failures never fail open: they produce `hold` with an `UNVERIFIABLE` reason. With no cross-epic key in the manifest, `validate` prints an empty result, `feature` prints `release` with reason `NO_CROSS_EPIC_EDGE`, and `main` prints `not_applicable`.

---

## 4. Behavior Semantics and Edge Cases

- Ordering per feature: manifest validation at kickoff, then hold evaluation at launch time, then integration merge, then push and re-fetch, then delegation. A held feature never receives a worktree.
- Intra-epic dependents of a held feature wait through the existing wave barrier; independent features proceed. Wave numbers are unchanged.
- Early start: `early_start_on` cannot name a cross-epic issue; a feature that has both an early-start edge and cross-epic edges still requires the cross-epic release before launch.
- The prerequisite epic completes and deletes its integration branch: `PREREQ_IN_MAIN` path (D4), manifest read from `origin/main`.
- The other integration branch is force-moved or rewritten: `PREREQ_NOT_ANCESTOR` holds.
- Several features name the same other epic: one integration merge serves all of them; the second evaluation returns `PREREQ_ALREADY_INTEGRATED`.
- Conflict on the integration merge: step 3 conflict handling; no rebase, no force push.
- Main hold after own features merged: no integration PR is opened until release; after release, main sync then PR.
- Resume: hold records are a cache; on resume the decision is re-derived from `gh` and `git` (cache doctrine).
- Mutual waiting across epics (deeper than one hop) is not detected; the hold bound converts it into a halt with `external_dependency` rather than an unbounded wait.

---

## 5. Requirements Mapping

| AC | Design | Files |
|---|---|---|
| AC1 schema accepts, validated, documented, absent key unchanged | D1, D6, D7 | `.claude/skills/epic-orchestrate/SKILL.md` (`## Epic Dependency Manifest`, new section `## Cross-Epic Dependencies (cross_epic_depends_on)`), `.agents/skills/epic-orchestrate/SKILL.md`, `docs/features/templates/epic/epic.md`, `extensions/drm-copilot/resources/feature-templates/epic/epic.md`, `.claude/lib/epic-wave/EpicCrossDependency.psm1`, `scripts/dev_tools/_epic_orchestrator_state_resolution.py`, `scripts/dev_tools/validate_epic_orchestrator_state.py`, `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` |
| AC2 pure readiness with unit tests; gh and ancestry as thin adapters | section 3 | `.claude/lib/epic-wave/EpicCrossDependency.psm1`, `.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1`, `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1`, `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1`, `tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1` |
| AC3 merge other integration branch before starting | D4, D7, D10, Layer 2 invariant of D6 | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` (`## Wave Scheduling` paragraph and the new `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1*)` grant), `.codex/agents/epic-orchestrator.toml`, `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts`, `.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, `tests/fixtures/epic_cross_dependency/` |
| AC4 critical path includes cross-epic edges | D9 | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1` (new), `Get-EpicProgressReport.Logic.ps1`, `Get-EpicProgressReport.Schedule.ps1` (`Invoke-EpicProgressListSchedule` cap exclusion), `Get-EpicProgressReport.CriticalPath.ps1` (chain label, external nodes into the schedule and range), `Get-EpicProgressReport.Render.ps1` (`**Cross-epic:**` line), `Get-EpicProgressReport.ps1` (wiring), `.claude/skills/epic-progress-report/SKILL.md` (calculation rule and decision record) |
| AC5 integration-to-main PR held | D5, D7 | `.claude/skills/epic-orchestrate/SKILL.md` (step 6 and `## Completion Requirements`), `.claude/agents/epic-orchestrator.md` (`## Completion Requirements`), `validate_epic_orchestrator_state.py` `_validate_completion`, `epic-orchestrator-state-core.ts` |
| AC6 skills and agents updated | all | `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-progress-report/SKILL.md`, `.claude/skills/epic-run/SKILL.md` (one scope sentence, the early-start precedent), `.claude/agents/epic-orchestrator.md`, `.claude/agents/epic-planner.md` (`## Checkpoint Persistence` field list), `.agents/skills/epic-plan/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, `.codex/agents/epic-planner.toml`, plus bundle copies (section 6) |

Rejected requirement shortcuts: no new hook, no new `merge_status` member, no new progress-report step type, no change to the wave CLI JSON contract.

---

## 6. Mirror and Push-Down Obligations

Copies that must change together (verified to exist):

- Claude bundle copies under `extensions/drm-copilot/resources/claude-customizations/`: `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/epic-run/SKILL.md`, `.claude/skills/epic-progress-report/SKILL.md` and every changed or new file under its `scripts/`, `.claude/agents/epic-orchestrator.md`, `.claude/agents/epic-planner.md`, `.claude/lib/epic-wave/EpicCrossDependency.psm1`, `.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`.
- Codex stored copies: `extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1` and `extensions/drm-copilot/resources/lib/epic-wave/Invoke-EpicCrossReadiness.ps1` (byte-identical to `.claude/lib/epic-wave/`), published at `.codex/lib/epic-wave/`.
- Codex and agents bundle under `extensions/drm-copilot/resources/codex-and-agents-customizations/`: `.agents/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-plan/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, `.codex/agents/epic-planner.toml` (generated bundle copies; base files are hand-edited).
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` gains the new Claude files (the new progress-report part file, the two epic-wave files, the new orchestrator-state module); `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` gains `.codex/lib/epic-wave/EpicCrossDependency.psm1` and `.codex/lib/epic-wave/Invoke-EpicCrossReadiness.ps1` (generated by the Codex generator).
- Templates: `docs/features/templates/epic/epic.md` and `extensions/drm-copilot/resources/feature-templates/epic/epic.md` stay identical.
- No `.github/` copy exists for any epic skill or the two epic agents (verified: `.github` holds only `epic-review.agent.md` and three epic prompts), so no `.github/` change is needed.

Contract tests to run (from the brief's `## Contract Tests That Pin Mirrored Files`, plus the epic-specific ones verified here):

- `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the new orchestrator-state module is a `$PSScriptRoot`-relative dependency of `OrchestratorStateEpicWaveBarrier.psm1`, which a hook imports, so it must be in core).
- `test_push_down_codex_and_agents_virtual_paths.py` (epic-wave stored mirror byte identity and publication).
- The Codex generator `--check` (`scripts/dev_tools/generate_codex_agent_variants.py` in module form).
- `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`.
- `parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES` through `test_frozen_epic_surface_matches_pinned_baseline_digest`: both digests move. Update procedure: after the final edit of each pinned file (and after any merge of `main` that touches it), recompute SHA-256 of the file bytes, replace the digest in the tuple, and append a `# RE-BASELINED by issue #1162.` paragraph naming that both digests moved and which merges were combined. Because siblings may also re-baseline, the digest is recomputed last, after the final merge of `main`, never carried from an earlier commit.
- `test_epic_orchestrator_permission_contracts.py` (the new `pwsh` invocation needs the grant), `test_epic_skill_script_citations_shipped.py` (every cited `.claude/lib/...` script must be shipped), `test_epic_orchestrate_main_sync_contract.py`, `test_epic_bounded_child_return_contract.py`, `test_epic_run_kickoff_discovery_contract.py`, `test_parallel_planner_surface_contracts.py`, `test_single_pass_preflight_contracts.py`, `merge_queue_documentation_expectations.py`, `test_orchestrator_state_remediation_docs.py` (all read the epic skills or agents).
- `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1`, `owner-directives-skill-contract.Tests.ps1`, `checkpoint-hygiene-skill-contract.Tests.ps1`, `parallel-gate-wording.Tests.ps1`.
- `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` and every existing progress-report part test.
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- `test_claude_rules_frontmatter.py` (agent preloaded skills unchanged, still run).

---

## 7. Execution-Environment Brief Impact

The recommended design changes no fact stated in `.claude/skills/execution-environment/SKILL.md`: no CI job, required context, tool route of a listed agent (`atomic-executor`, `atomic-planner`, `task-researcher`, `orchestrator`), batch-budget rule, hook execution context, or contract-test list entry changes. `epic-orchestrator` is not listed in `## Tool Routes by Agent`, so its new grant is not a brief fact. If the plan departs from D5 and changes a merge gate hook, the brief's `## Hook Execution Context` merge-guard text and all six copies would need an update in the same change.

---

## 8. Automation Feasibility

- Every step runs unattended with `git` and `gh` only: manifest reads (`git show`), PR snapshots (`gh pr list`), ancestry (`git merge-base --is-ancestor`), the integration merge (`git fetch`, `git merge --no-ff`, `git push`), and the existing integration PR flow. No new credential, no new service, and no human approval is introduced.
- The one wait is bounded (D8). When a prerequisite epic stays unmerged beyond the bound, the run halts with `blocked_reason: "external_dependency"` and resumes on the next `/epic-run <epic-slug>` invocation. That re-invocation is the only interaction point; a coordinator can schedule it with a recurring job in its main session (the `epic-progress-report` CronCreate precedent), so no human decision is required.
- Integration-merge conflicts follow the existing main-sync handling; this adds no new human-decision class.

---

## 9. File-Size Proximity (logical lines counted by non-empty-line grep; physical counts may be slightly higher)

| File | Approx. lines | Guidance |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate-review.ps1` | about 699 | not edited (D5) |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | about 530 | wiring only; keep additions to a few lines |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | about 495 | add one call only; logic lives in `epic-orchestrator-state-resolution.ts` |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1` | about 494 | only the `External` cap exclusion; new logic in `Get-EpicProgressReport.CrossEpic.ps1` |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | about 500 | not edited (D5) |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` | about 472 | not edited if D1 single-line form is kept |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | about 470 | not edited |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | about 447 | one line builder added |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | about 431 | completion call only |
| `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` | about 421 | guarded import plus one append; logic in the new module |
| `scripts/dev_tools/validate_epic_planner_state.py` | about 410 | one call |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | about 395 | completion and call sites |
| `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` | about 339 | started-while-held invariant |
| `scripts/dev_tools/_epic_orchestrator_state_resolution.py` | about 288 | shape validation |
| `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/skills/epic-progress-report/SKILL.md` | about 480 and 499 | Markdown, exempt |

No edited code file is expected to reach 700 lines.

---

## 10. Overlap With Concurrent Sibling Items

The sibling feature folders are not present in this worktree, so overlap is inferred from issue titles and must be re-checked at execution start by re-reading each shared file after fetching `origin/main` and the sibling branches.

- #1156 lighter integration-merge path: most likely overlap. Probable shared files: `.claude/skills/epic-orchestrate/SKILL.md` (`## Epic Integration Branch Lifecycle`, `## Merge-Conflict Handling (Fan-In)`), `.claude/agents/epic-orchestrator.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, their bundle copies, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (pinned digests), and possibly `.claude/skills/orchestrate/SKILL.md` S9 step 6 and the merge gate files. This item avoids the merge gates (D5) and adds a separate section rather than rewriting step 3 or step 6 text, so either merge order resolves by keeping both edits and recomputing both digests last.
- #1157 owner directives reach agents: likely edits epic agents and skills (the epic skill already carries an owner-directive relay sentence) and therefore the pinned digests.
- #1158 test-execution policy: likely edits the execution-environment brief and rules; this item does not.
- #1159 single hook dispatcher: likely edits `.claude/settings.json`, `.codex/config.toml`, and hook entry points; this item adds no hook and no registration. `OrchestratorStateEpicWaveBarrier.psm1` is loaded by the stop hook; if #1159 changes how `validate-orchestrator-output.ps1` loads modules, re-check the guarded import path.
- #1160 preimplementation gate false positives: edits the preimplementation gate; this item relies on it only for the integration merge, which already works for main sync.
- #1161 planner worktree removal: likely edits `.claude/skills/epic-plan/SKILL.md` (`## Fan-In to the Integration Branch` step 4) and `.claude/agents/epic-planner.md`; this item edits other sections of both.
- #1163 isolated worktrees and session-root resolution in hooks: likely edits `validate-orchestrator-output-resolution.ps1` and resolution libraries; this item does not edit them.

---

## 11. Testing Implications

- Pester (one `Invoke-PoshQCParallelTest` gate): pure-function tables for every manifest error code and every row of both decision tables; adapter tests that mock `Invoke-EpicCrossGhExe` and `Invoke-EpicCrossGitExe` with matching parameter names (`GhArgs`, `GitArgs`) and assert the exact argument arrays; CLI tests through `Invoke-EpicCrossReadinessCommand` with an injected manifest reader, injected sleep and clock seams (a bounded wait test asserts the number of injected sleeps, no real sleep); parity test reading `tests/fixtures/epic_cross_dependency/`; progress-report tests for external node construction, cap exclusion (a cap-1 schedule with one external node still starts the local node at 0), chain label, the `**Cross-epic:**` line, and a byte-identical result for inputs without the key; Layer 2 module tests.
- pytest (one `pytest -n auto` gate): key-gated shape, started-while-held, and completion invariants; corpus parity; absent-key byte identity against existing fixtures.
- Jest (normal workers): the same invariants and corpus parity in the TypeScript ports. No new TypeScript production file is proposed. Verified in `extensions/drm-copilot/jest.config.cjs`: only `./src/lib/validate/epic-orchestrator-state-wave-barrier.ts` has a per-file `coverageThreshold` entry among the four extended files; `epic-orchestrator-state-resolution.ts`, `epic-orchestrator-state-core.ts`, and `epic-planner-state-core.ts` have none, and the map has no `global` key. The plan either adds entries for those three files (after confirming each already meets 85% line and 75% branch, so the new gate does not fail on pre-existing gaps) or records their per-file figures from the coverage report as evidence; the choice is a planner decision, and the recommendation is to add the entries.
- Isolation: no test writes a file; manifest text, PR JSON, and checkpoint text are in-memory strings; no test depends on order; module imports in Pester use `-Force` within `BeforeAll` and remove imported modules in `AfterAll` so `Invoke-PoshQCLeakScan` stays clean.
- Coverage: each new or changed PowerShell file at or above 85% line coverage from `artifacts/pester/powershell-coverage.xml`; Python and TypeScript changed files at or above 85% line and 75% branch.

---

## Numeric Derivation Evidence

Not applicable: this research proposes no numeric count, enumeration size, or population for any `spec.md` acceptance criterion. The approximate line counts in section 9 are size guidance, not acceptance values. The polling constants in D8 are stated defaults, not derived counts.

---

## Pre-Mortem

- Review checklists: a reviewer can find the cross-epic text inconsistent between `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, and `.codex/agents/epic-orchestrator.toml`, or find the honest-disclosure sentence for the skill-level main hold missing. Mitigation: the plan writes one new section in the Claude skill first, derives the Codex wording from it in the same task, and includes the disclosure text of D5 verbatim.
- Coverage: the adapter and wait paths of `EpicCrossDependency.psm1` and the new progress-report part file can fall below 85% line coverage if only pure functions are tested, and three extended TypeScript files have no `coverageThreshold` entry, so a coverage drop there is not caught by Jest. Mitigation: add the three entries (section 11); the plan names adapter tests with mocked wrappers and CLI tests with injected seams, and compares per-file figures with the `Phase 0 baseline` run of the same gate.
- Mirror parity: missing a bundle copy, the Codex stored copy under `extensions/drm-copilot/resources/lib/epic-wave/`, a pack-manifest entry, or the frozen digests fails the contract tests in section 6. Mitigation: one task per mirror group, the Codex generator `--check`, and a final task that recomputes both `PINNED_FROZEN_SURFACE_HASHES` digests after the last merge of `main`; no brief-update task is needed because no brief fact changes (section 7).
- File size: `Get-EpicProgressReport.ps1`, `Get-EpicProgressReport.Schedule.ps1`, and `epic-planner-state-core.ts` sit near the 500-line guidance tier. Mitigation: new logic goes into `Get-EpicProgressReport.CrossEpic.ps1`, `EpicCrossDependency.psm1`, and `OrchestratorStateEpicCrossDependency.psm1`; edits to the near-limit files are call sites only.
- Test isolation: Pester tests that import `EpicCrossDependency.psm1` or dot-source the progress-report hub can leak functions or mocks across files in one shard, and a test that reads gitignored `artifacts/` would fail in CI. Mitigation: in-memory fixtures only, imports scoped to `BeforeAll` with removal in `AfterAll`, the leak scan in the QA gate, and one parallel run per gate.
- CI-only behavior: the Linux hook-suite job and case-sensitive paths can fail fixture paths, and the `eol=lf` rule changes CRLF fixtures. Mitigation: fixture paths built with `Join-Path` and forward slashes, manifest text fixtures written with LF, no drive letters; the new Layer 2 module is exercised by the existing `tests/scripts/claude-hooks` stop-hook suites, which also run on Linux.
- Evidence: an acceptance condition that depends on the branch's Layer 2 or merge behavior being exercised by an isolated subagent cannot be met, and installed MCP lags the new validator rules. Mitigation: prove hook-side behavior through Pester suites, validate checkpoints through the repository CLI route (D6), and write evidence append-only under `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/` with clock-read stamps.

---

## Facts for the Orchestrator to Confirm

The researcher cannot run `gh` or `git`; these facts were not verified:

1. `gh pr list` in GitHub CLI 2.103.3 accepts `files` in `--json` and returns file paths for merged PRs (D3). If it does not, the fallback is one `gh pr view <n> --json files` per candidate PR from a `number,headRefName,mergeCommit` list.
2. The current Claude Code Bash tool timeout ceiling is 600 seconds, which bounds `-WaitSeconds 540` (D8).
3. Every epic-child PR into an integration branch modifies at least one file under its own feature folder (plan checkboxes or evidence), which D3 relies on. A sample of merged child PRs (for example those listed in `docs/features/epics/claude-runtime-portability/epic-status.md`) can be checked with `gh pr view <n> --json files`.
4. Whether `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` is fully generated by the Codex generator or partly hand-maintained for `.codex/lib/epic-wave/` entries.
5. The scope of sibling items #1156 to #1161 and #1163 (section 10), by reading their issue bodies or branches.

---

## Rejected Alternatives (summary)

- Cross-epic references inside `depends_on`: breaks four consumers (section 1.3).
- Block-style manifest value: silently disables the progress report's manifest fallback.
- A new `.claude/lib/` directory: needs a new Codex virtual mapping and TypeScript push-down change with no functional benefit.
- `epic-status.md` parsing or branch-name matching as the prerequisite identity: unstable formats and conventions.
- A merge gate hook change for the main hold: file size, twin parity, sibling contention, and branch-hook evidence limits.
- A new `merge_status` member such as `held_cross_epic`: three-runtime enum change and progress-report state mapping change for no added safety over the started-while-held invariant.
- Ignoring unmerged prerequisites in the critical path, or modeling the other epic's tail: the first fails AC4, the second depends on data the report cannot read reliably.
