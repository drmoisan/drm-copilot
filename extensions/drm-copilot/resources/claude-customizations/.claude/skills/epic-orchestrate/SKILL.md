---
name: epic-orchestrate
description: Route a multi-feature epic through the deterministic wave-scheduling, integration-branch, and fan-in workflow for the epic-orchestrator agent.
argument-hint: "[epic-manifest-path]"
context: fork
agent: epic-orchestrator
---

# Epic Orchestrate Skill

A user invocation (`/epic-orchestrate <epic-manifest-path>`) forks the `epic-orchestrator`
agent with this procedure in context. The epic manifest path (or epic slug) for this run is:

$ARGUMENTS

This skill frames work for the `epic-orchestrator` agent, parallel to how
`.claude/skills/orchestrate/SKILL.md` frames work for `orchestrator`. It documents the epic
checkpoint handling, wave computation, integration-branch lifecycle, wave barrier,
merge-conflict handling, worktree cleanup, and documentation-maintenance procedures so the
procedure is not re-derived ad hoc on each epic run.

## Epic Dependency Manifest

The epic manifest is the YAML frontmatter of the single epic home
`docs/features/epics/<epic-slug>/epic.md`. `epic.md` is the merged source of truth: its
frontmatter carries the fields that must be parsed deterministically, and the Markdown body
below the frontmatter carries the single free-text epic narrative (goal, scope, non-goals,
shared design, decomposition) that is not machine-parsed. `epic.md` is also the source from
which the epic GitHub issue body is generated.

Frontmatter schema:

```yaml
---
epic: <epic-slug>
integration_branch: epic/<epic-slug>-integration
created_at: <iso8601>
# Optional additive SAFe-style intent block. Omit the whole block when unused; when
# present, epic_type and business_outcome_hypothesis are required and
# leading_indicators / nfrs are optional lists of strings.
intent:
  epic_type: <business | enabler>
  business_outcome_hypothesis: <measurable outcome the epic is expected to move>
  leading_indicators: [<early validation signal>, ...]
  nfrs: [<non-functional requirement>, ...]
features:
  - issue_num: <int>
    feature_folder: <resolvable-hint-basename>
    depends_on: [<upstream-issue_num>, ...]
---
```

- `issue_num` is the primary key: the stable GitHub issue number for the child feature. The
  DAG is keyed by `issue_num`, so it does not drift when a child is promoted from `active/` to
  `completed/`.
- `feature_folder` is a resolvable hint, not a stable identifier. It may resolve to a concrete
  path under `docs/features/active/<basename>` or `docs/features/completed/<basename>`; a
  lifecycle prefix is stripped to the basename during resolution.
- `depends_on` is an array of `issue_num` values (legacy manifests may still use
  `feature_folder` basenames). Each entry must resolve — via the union index of the
  `issue_num` set plus the `feature_folder` set — to another entry in `features[]`. A
  `depends_on` entry that does not resolve, or a duplicate `feature_folder` value, is a
  malformed manifest and is rejected before epic kickoff as a synthetic Blocking finding —
  `epic-orchestrator` does not guess.
- The optional `intent` block is additive and presence-gated: when present it is validated
  (`epic_type` in {business, enabler}, non-empty `business_outcome_hypothesis`, string-list
  `leading_indicators` / `nfrs`); when absent, validation is byte-identical to a manifest
  without it.

## Wave Assignment

Wave assignment is computed deterministically by longest-path layering over the dependency DAG,
not by an arbitrary valid topological order:

```
wave(f) = 0                                   if depends_on(f) is empty
wave(f) = 1 + max(wave(d) for d in depends_on(f))   otherwise
```

`pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath <manifest>` is the shipped, tested
implementation of this formula (exit 0 with the JSON wave map, 1 for a cycle, self-loop, or
unresolved reference, 2 for a usage error); the Python module `epic_wave_computation` is this
repository's parity reference.

Compute this via memoized recursion with cycle detection: a `feature_folder` encountered while
still being resolved (i.e., it appears in its own dependency chain) indicates a cycle in the
manifest, which is rejected as a malformed manifest before kickoff. Within a wave, feature
ordering for emission into checkpoint arrays is lexicographic by `feature_folder`, purely for
deterministic serialization; wave *membership* itself has no ties to break since it is a pure
function of the DAG.

## Epic Integration Branch Lifecycle

1. Before wave 0's launch, `epic-orchestrator` creates the integration branch off the tip of
   `main`: `git fetch origin main`, `git checkout -b epic/<epic-slug>-integration origin/main`,
   `git push -u origin epic/<epic-slug>-integration`.
2. Before starting each wave, `epic-orchestrator` runs
   `git fetch origin epic/<epic-slug>-integration` so the wave's child worktrees branch off the
   current remote tip, not a stale local ref.
3. Before each wave launches (wave 0 included), `epic-orchestrator` runs
   `git fetch origin main` and then
   `git rev-list --count origin/epic/<epic-slug>-integration..origin/main`. A zero count
   proceeds directly to the wave. A non-zero count means `origin/main` has commits the
   integration branch lacks. Before the wave launches, `epic-orchestrator` merges `origin/main`
   into the integration branch (`git merge --no-ff origin/main`, resolving any conflicts; no
   rebase, no force-push), pushes the integration branch, re-runs step 2, and launches the wave.
   Commits that reach `origin/main` afterwards are picked up by the next wave's check or by the
   final integration PR in step 6.
4. Each child feature's worktree/branch (created via
   `Agent(orchestrator, isolation: "worktree", run_in_background: true)`) is branched from
   `origin/<integration_branch>`, not `origin/main`. The child's own `orchestrator` instance
   honors this via the epic-mode kickoff line below.
5. Each child feature's PR base branch is the integration branch, not `main` — an explicit
   epic-mode override recorded in the checkpoint, not a reliance on `pr-base-branch-merge-base`'s
   ancestry heuristic. Non-epic (standalone) orchestration is unchanged.
6. At epic completion (every feature in the final wave has `merge_status: "merged"`),
   `epic-orchestrator` drives a final PR merging `epic/<epic-slug>-integration` into `main`,
   delegating PR authoring to `Agent(pr-author)` and refreshing context via
   `mcp__drm-copilot__collect_pr_context`. `epic-orchestrator` runs the same S9 CI-green
   procedure (`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`) directly against this PR, records
   the result under the epic checkpoint's `epic_merge_pr` object, then executes
   `gh pr merge --merge` once green, gated by `enforce-epic-merge-gate.ps1`. Under a merge queue
   on `main`, `gh pr merge` can return before the merge happens, so
   `epic_merge_pr.merge_commit_sha` is recorded only after the merge is confirmed by polling and
   ancestry check, using the confirmation procedure of step 3 of
   `## Per-Item Merge to Main (Merge-on-Green)` in `.claude/skills/parallel-orchestrate/SKILL.md`
   with `main` as the base branch; each pull-request snapshot is classified with
   `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson`
   (issue #952).

## Merge-on-Green Kickoff Parameter

When `epic-orchestrator` delegates a child feature to `Agent(orchestrator)`, the prompt includes
the literal epic-mode kickoff line:

> `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create. Your final report MUST be exactly the bounded return shape (issue_num, feature_folder, merge_status, pr_number, merge_commit_sha, blocked_reason, branch_name, worktree_path) and nothing else; any additional narrative is discarded because the parent re-derives authoritative state regardless.`

The child's own `orchestrator`, on reading this line, records `epic_mode: true` and
`epic_context: { epic_feature_folder, integration_branch, epic_checkpoint_path }` at its first
checkpoint write, and on CI-green (S9 step 6) merges its own PR into the integration branch,
recording `epic_merge: { merge_commit_sha, target_branch, merged_at }`. The child records
`epic_merge` only after the merge is confirmed by polling and ancestry check against
`origin/<integration_branch>` (S9 step 6). Standalone (non-epic)
orchestration is unchanged: `epic_mode` absent or `false` makes S9 step 6 a no-op.

Epic-child CI verification (issue #1130): the child verifies CI on its own head before S9 step 6
merges. When no check whose `workflow` is `CI` exists on the child head, for example because the
repository's `CI` workflow does not list `epic/**` in its `pull_request` branches, the child runs
the S9 dispatch fallback of `.claude/skills/orchestrate/SKILL.md` and records
`ci_gate.dispatch_run_id`. When a child reports that it is blocked at S9 because no `CI` run exists
on its head, `epic-orchestrator` dispatches `CI` once on the child branch
(`gh workflow run CI --ref <child branch>`) as the fallback and resumes the child at S9 to record
the run. A child merge into the integration branch is never accepted without a green `CI` run on
the child head SHA: `enforce-epic-merge-gate-child-ci.ps1` denies it with
`EPIC_CHILD_CI_NOT_VERIFIED`.

The run gates `enforce-orchestration-preimplementation-gate.ps1` and `enforce-epic-wave-barrier.ps1` locate the epic checkpoint by the `integration_branch:` value of this line. They select the live worktree whose `artifacts/orchestration/epic-orchestrator-state.json` records `route_id` `epic` and that integration branch, prefer the worktree that has the branch checked out when more than one records it, and deny the delegation with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` when none or more than one remains. A stale copy of the epic checkpoint is moved to `artifacts/orchestration/handoff/` rather than left at a worktree root. The child run's own delegations to implementation agents carry the canonical issue-number line and `branch:` label defined in `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency`.

## Bounded Child Return Contract

A child `orchestrator`'s final report is consumed as a fixed eight-field shape and nothing else:

- `issue_num` — the child's GitHub issue number.
- `feature_folder` — the child's feature-folder path.
- `merge_status` — the child's terminal merge-status enum value.
- `pr_number` — the child's pull-request number, or null when none was opened.
- `merge_commit_sha` — the merge commit, or null when the child did not merge.
- `blocked_reason` — a short reason string when the child is blocked, otherwise null.
- `branch_name` — the child's feature branch.
- `worktree_path` — the child's isolated worktree path.

Content beyond these eight fields is **discarded**. A child that returns a longer narrative is not
in error; the excess is simply not read into the parent's context, which is what keeps the parent's
footprint flat as the child count grows.

Discarding is safe because the parent re-derives authoritative state regardless, from
`git worktree list --porcelain`, `git branch`, and
`gh pr view --json state,mergedAt,headRefOid`. `branch_name` and `worktree_path` are carried in the
shape only to spare the parent a re-parse of porcelain output per child before
`git worktree remove`; they are not authoritative and are re-derived like every other field. The
governing argument is the cache doctrine already recorded in
`.claude/rules/parallel-orchestration.md`, which is cited here rather than restated.

## Model Selection

When `epic-orchestrator` delegates a child feature to `Agent(orchestrator)`, the prompt appends the
session model-budget kickoff marker line, following the existing kickoff-marker pattern:

> `model_budget.fable_policy: <disabled|available|preferred>.`

The child's own `orchestrator` reads this line and applies the two-axis model-selection mechanism
documented in `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`): it assesses a
judgment-based `complexity_band`, records `complexity_assessments[]` and `model_routing_receipts[]`,
and resolves each delegation's model tier under the given `fable_policy`. The two canonical, tested
reference implementations are `.claude/lib/model-routing/ModelRouting.psm1`
(`Get-ComplexityFloor`) and `.claude/lib/model-routing/ModelRouting.psm1`
(`Resolve-DelegationModel`). Default `fable_policy` is `disabled` when the marker is absent.

When `epic-orchestrator` itself spawns `Agent(orchestrator)` or `Agent(pr-author)`, it applies
the same per-delegation resolution and passes `model` equal to the routing receipt's `model` on
the spawn call. It MUST NOT omit `model` (an omitted `model` falls back to the delegate's
frontmatter default — `opus` for these workers — which suppresses a `fable` resolution) and
MUST NOT hard-code `model=opus` in a way that overrides the resolved routing model, mirroring
step 5 of `## Model Selection` in `.claude/skills/orchestrate/SKILL.md`.

Every such spawn of `Agent(pr-author)` also carries the canonical issue number line and a
`branch: <name>` label naming the branch checked out in the worktree the pull request is opened
from, per `## Issue Number Consistency` in `.claude/skills/orchestrate/SKILL.md`.
`enforce-model-routing-receipt.ps1` identifies the item from those two lines and denies a gated
delegation it cannot identify, so a spawn that omits both is refused rather than validated against
whichever checkpoint occupies the calling session's root.

`route` is never an input to model selection; `route` remains file-count driven and governs only
agents, skills, and MCP tools. A skill whose frontmatter `context` field holds the value `fork`
inherits the parent model and ignores a model override, so model selection applies to agent
delegations, not to fork-routed skill invocations.

## Context Handoff to Dependent Features

When `epic-orchestrator` kicks off a feature with a non-empty `depends_on`, the delegation prompt
includes one literal citation line per dependency, appended after the epic-mode kickoff line
above:

> `Upstream context for <issue_num>: depends on <dep_issue_num> (spec: <dep_resolved_folder>/spec.md; plan: <dep_resolved_folder>/plan.<ts>.md; merged as PR #<dep_pr_number>, commit <dep_merge_commit_sha>, into <integration_branch>).`

`epic-orchestrator` resolves each dependency by its stable `issue_num` against its own
checkpoint's `features[]` records, and resolves `<dep_resolved_folder>` to the dependency's
concrete `feature_folder` path — under `docs/features/active/` or `docs/features/completed/`
depending on the dependency's current lifecycle state at emit time — before emitting the line.
Because the DAG is keyed by `issue_num`, no active→completed path-drift workaround is needed: the
concrete path is resolved from the checkpoint's current state, so the dependent feature's own
`orchestrator`/`atomic-planner` is told exactly which upstream artifacts are relevant rather than
being expected to rediscover prior design decisions from the diff alone.

A recorded `Owner directives:` block is passed verbatim to each child whose scope matches an
entry, as defined in the `owner-directives` skill; `epic-orchestrator` never authors or edits
entries.

## Merge-Conflict Handling (Fan-In)

The merge-conflict remediation loop runs inside the child feature's own `orchestrator` instance
(the same one that executes S9 step 6), reusing the existing R1–R5 loop
(`.claude/skills/orchestrate/SKILL.md` "Remediation Loop (R1–R5)") unmodified — no new loop is
owned by `epic-orchestrator`.

Procedure, triggered by S9 step 6's merge failure:

1. The child's `atomic-executor` runs `git fetch origin <integration_branch>`,
   `git merge --no-commit origin/<integration_branch>`, and on non-zero exit captures
   `git diff --name-only --diff-filter=U` (the conflicted file list) plus the raw conflict-marker
   (`<<<<<<<`/`=======`/`>>>>>>>`) content of each conflicted file.
2. This is written as `remediation-inputs.<timestamp>.md` in the **child feature's own active
   folder** (not the epic folder), severity `Blocking`, naming the conflicting branches, carrying
   the conflicted-file list and marker excerpts — the same shape the existing CI-failure handling
   already uses, substituting the conflict-detection output for `gh run view --log-failed`.
3. The existing R1–R5 loop processes this finding exactly as a local blocking finding:
   `atomic-planner` (R1) plans the resolution, `atomic-executor` performs preflight (R2) then
   resolves the conflict markers, stages, and commits (R3), `feature-review` re-audits (R4).
4. Conflict cycles share the child's own `remediation_loop.completed_attempts` count with
   local-finding and CI-failure cycles. The active cycle number is `completed_attempts + 1`, and a
   cycle without an applied candidate consumes no number.
5. After three completed attempts without resolution, the child's `orchestrator` records
   `step9_status: "blocked_conflict_loop_limit"` (parallel to `blocked_ci_loop_limit`), does not
   write DONE, and halts. It reports this status to `epic-orchestrator`, which mirrors it into
   the epic checkpoint's per-feature `merge_status: "blocked_conflict_loop_limit"` field.
6. A resolved conflict produces a new child head, so S9 runs again against it, and the fan-in
   merge is accepted only with a green `CI` run on that new head (issue #1130).

## Wave Barrier (Two-Layer Design)

Wave-barrier enforcement is a two-layer design: no single hook mechanism can validate a whole
batch of concurrent `Agent` calls, since `PreToolUse` hooks fire per call with no
cross-call/conversation-state visibility.

- **Layer 1 — per-call deterrent:** `.claude/hooks/enforce-epic-wave-barrier.ps1`, a `PreToolUse`
  hook on the `Agent` matcher. It fires when `subagent_type == "orchestrator"` and the serialized
  prompt contains the marker `Epic mode: true`, resolves the target `feature_folder` from the
  prompt text, reads `artifacts/orchestration/epic-orchestrator-state.json`, looks up that
  feature's `depends_on`, and denies with reason `EPIC_WAVE_BARRIER_BLOCKED` unless every
  dependency's `merge_status` is `merged` or `worktree_removed`.
- **Layer 2 — retrospective backstop:** the wave-barrier ordering invariant of
  `validate_epic_orchestrator_state_text`, enforced at `epic-orchestrator` `SubagentStop` time by a
  PowerShell port, `Get-OrchestratorStateEpicWaveBarrierError` in
  `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, which the parameterized
  `validate-orchestrator-output.ps1` hook invokes for `epic-orchestrator-state` after resolving the
  epic checkpoint through `WorktreeRunResolution.psm1`. The hook starts no Python process. Parity
  with `validate_epic_orchestrator_state_text` is pinned by the shared fixtures under
  `tests/fixtures/epic_wave_barrier/`, and the Python validator remains the authority used through
  the `mcp__drm-copilot__validate_orchestration_artifacts` call. It checks only a dependent feature
  that is treated as started: one with a string `worktree_created_at`, or with a `merge_status`
  other than `not_started` (a missing or non-string `merge_status` counts as started). It appends
  exactly one error per violated dependency edge. When the dependency's `merge_status` is not
  `merged` or `worktree_removed`, the error is
  `EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while dependency <d> is not merged`.
  Otherwise, when the dependency's `merge_confirmed_at` is later than the dependent's
  `worktree_created_at`, the error is
  `EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes dependency <d> merge_confirmed_at`.
  A violation blocks with an instruction to report it to the operator and halt. The `SubagentStop`
  transport and exit-code defect that this check previously depended on was resolved by epic #904
  and issue #928: a violation blocks the stop with exit 2 and a stderr reason.

Both layers are required; neither alone closes the gap. `epic-orchestrator` does not launch wave
N+1 until every wave-N feature's dependency edges are durably confirmed merged, verified against
`git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`
on resume, not from in-memory completion notifications alone.

## Worktree Cleanup

After a child feature's `epic_merge.merge_commit_sha` is recorded (S9 step 6 succeeds) and
`epic-orchestrator` mirrors that into its own checkpoint's `merge_status: "merged"` and
`merge_confirmed_at`, recording the child's `pr_number` and `merge_commit_sha` in the matching
`features[]` entry, `epic-orchestrator` (running from the main repository checkout, not any
child worktree) issues `git worktree remove <worktree_path>`, gated by
`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, which denies with reason
`EPIC_WORKTREE_REMOVAL_BLOCKED` unless the epic checkpoint's matching `features[]` record has
`merge_status` in `{merged, worktree_removed}`. On success, `epic-orchestrator` sets
`merge_status: "worktree_removed"` and `worktree_removed_at`.

## Documentation Maintenance Boundaries

`epic.md` (the merged manifest + narrative source of truth) and `epic-status.md` (a separate,
epic-orchestrator-maintained status document) are kept distinct. `epic.md`'s frontmatter is the
human-authored, largely static input; automatic epic decomposition is out of scope, so this
file is not repeatedly rewritten. `epic-status.md` is a generated projection only: it is
regenerated (never hand-authored) from the epic checkpoint and is never the source of the DAG.
`epic-orchestrator` maintains `docs/features/epics/<epic-slug>/epic-status.md`, regenerated from
the epic checkpoint at each of the following boundaries, not only at final completion:

- Epic kickoff — initial status table seeded from the manifest (one row per feature: wave,
  status `not_started`).
- Each time a feature's `merge_status` changes (`worktree_created`, `pr_open`, `ci_green`,
  `merge_conflict`, `merged`, `worktree_removed`) — the corresponding row is updated in place.
- Each wave transition (`current_wave` increments).
- Final integration PR opened, green, and merged.

Each row records: `feature_folder`, `issue_num`, `wave_number`, `merge_status`, PR link
(`pr_url`), `merge_commit_sha`, and the four lifecycle timestamps from the epic checkpoint.
`epic-status.md` is a human-readable projection of the epic checkpoint's `features[]` array; the
checkpoint JSON remains the durable, machine-authoritative source.

## Epic-Level Checkpoint

`artifacts/orchestration/epic-orchestrator-state.json` carries `objective`, `route_id: "epic"`,
`epic_feature_folder`, `epic_manifest_path` (which points at
`docs/features/epics/<epic-slug>/epic.md`), `epic_status_doc_path`, `integration_branch`,
`completed_steps`, `next_step`, `last_updated`, `current_wave`, `waves[]`, `features[]`,
`epic_merge_pr`, `epic_issue_num` (the epic-level issue `epic-planner` promoted),
`model_routing_receipts[]` (the routing receipt for each delegation `epic-orchestrator` itself
spawns), and the three receipt arrays (`delegation_receipts[]`, `skill_receipts[]`,
`mcp_call_receipts[]`). The
`merge_status` enum is: `not_started`, `worktree_created`, `pr_open`, `ci_green`,
`merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`. The optional
`intent` object (projection of the `epic.md` intent block) is validated presence-gated.

Every field needed to re-derive state durably on resume (`worktree_path`, `branch_name`,
`pr_number`, `merge_status`) is re-derivable from `git worktree list --porcelain`, `git branch`,
and `gh pr view --json state,mergedAt,headRefOid` — the checkpoint is a cache of that durable
state, not the source of truth.

Validate the checkpoint through the
`mcp__drm-copilot__validate_orchestration_artifacts` call with
`artifact_type: "epic-orchestrator-state"`, supplying the `require_complete` argument on
that same call at the completion gate. The validation is implemented in
`scripts/dev_tools/validate_epic_orchestrator_state.py`.

**Checkpoint hygiene (issue #673).** The coordinating session never holds a per-feature checkpoint at its own root. Before the first child delegation of a run it moves any `artifacts/orchestration/orchestrator-state.json` at its root to `artifacts/orchestration/handoff/orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json`, and writes none there for the rest of the run, because each item's checkpoint lives in that item's worktree. A gated call the coordinator issues on an item's behalf is resolved by the item's issue number and branch, never by the coordinator root.

**Integration-PR checkpoint shape (issue #663).** The integration-to-`main` pull request and its `Agent(pr-author)` delegation are gated against `artifacts/orchestration/epic-orchestrator-state.json`, and no per-feature checkpoint is written for them. Before `epic-orchestrator` opens that pull request, the epic checkpoint carries `route_id: "epic"`, `integration_branch`, `epic_issue_num`, and a `features[]` array in which every entry's `merge_status` is `merged` or `worktree_removed`. Before the `Agent(pr-author)` delegation, `epic-orchestrator` records the `pr-author` routing receipt in that file's `model_routing_receipts[]`. The pr-author gate, the epic base-branch check, the model-routing gate, and the preimplementation gate treat a call as epic scope when its branch signal (or, for a staging command or file edit, the worktree HEAD) equals `integration_branch`; the pull request base must then be `main`.

**Post-fan-in allowance (issue #1136).** Once fan-in is complete, meaning every `features[]` entry records `merge_status` `merged` or `worktree_removed`, the preimplementation gate admits a narrow set of writes on the integration branch that its epic-scope readiness predicate would otherwise deny with `'merge-in-progress'`. The allowance applies only when the worktree HEAD equals `integration_branch` and only for that exact readiness failure. It admits a Write or Edit of `artifacts/pr_body_<N>.md` or `artifacts/pr_body_<N>.receipt.json`, and a `git add` or `git commit` of the status document `docs/features/epics/<epic_feature_folder>/epic-status.md`, where the slug is one plain path segment and agrees with `epic_status_doc_path` when that field is set. A commit may carry only `-m`, `--message`, `-F`, `--file`, and `--trailer`, followed by no pathspec or by `-- <status doc>`; a commit without a pathspec is admitted only when the staged index of the integration worktree is exactly the status document. Two limits apply: a `-F` value or any other token containing a backslash makes the command unresolvable, so use a forward-slash path or `-m`; and in a chained `git add ... && git commit ...` without a pathspec the index is read before the add runs, so issue the commit separately or name `-- <status doc>`. Every other path and command keeps its deny. The allowance (`hook-epic-fan-in.ps1`) is a policy-level control, not a security control.

**Merged-feature follow-up allowance (issue #1141).** Before fan-in is complete, a follow-up on a child feature that has already merged into the integration branch, such as an evidence or documentation correction, is made in the integration worktree on the integration branch. The preimplementation gate admits it for the same exact `'merge-in-progress'` readiness failure, on the integration branch only, when the matching `features[]` entry of the epic checkpoint qualifies: `merge_status` is `merged` or `worktree_removed`, the `feature_folder` basename (after an optional `docs/features/active/` or `docs/features/completed/` prefix) is one plain path segment, `merge_commit_sha` is 40 or 64 lowercase hex characters, and `pr_number` is an integer greater than 0. The allowed roots are `docs/features/active/<basename>/` and `docs/features/completed/<basename>/` of each qualifying feature, plus the epic status document. The gate admits a Write or Edit whose path lies under an allowed root, a `git add [--] <paths>` whose every operand does, and a `git commit` carrying only `-m`, `--message`, `-F`, `--file`, or `--trailer`, followed by `-- <paths>` under the allowed roots or by no pathspec when the staged index is non-empty and every entry lies under an allowed root. `-a`, `--all`, `--amend`, `-A`, any other flag, globs, `..` segments, backslashes, chained non-git commands, and sibling folders such as `<basename>-x/` keep their unchanged deny. The epic checkpoint entry is the only evidence: the allowance reads no per-item checkpoint. Code corrections are not follow-ups; they go through a new orchestrated child. Agents never hand-author a readiness checkpoint to pass the gate. The allowance (`Get-EpicMergedFeatureFollowUpAllowance` in `hook-epic-fan-in.ps1`) is a policy-level control, not a security control.

## Completion Requirements

`epic-orchestrator` must not report completion until:

1. Every feature in the manifest has `merge_status` in `{merged, worktree_removed}`.
2. The final integration-to-`main` PR has merged and `epic_merge_pr.merge_commit_sha` is
   recorded, and it is recorded only after the merge is confirmed by polling and ancestry check.
3. `docs/features/epics/<epic-slug>/epic-status.md` reflects the completed state.
4. The epic checkpoint passes `validate_epic_orchestrator_state_text` with
   `require_complete=True`.

## Nesting Depth

This chain runs three levels of subagents below the main session: the coordinator at depth 1, each per-feature `orchestrator` at depth 2, and the specialists that orchestrator delegates to at depth 3. Only the depth-2 orchestrator needs the `Agent` tool below the coordinator; specialists do not delegate.

Requirement: Claude Code 2.1.219 or later, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` unset or at least 3, and the skill invoked from the main session. A run started inside a subagent or fork adds one layer, and a lower limit withholds the `Agent` tool from the per-feature orchestrators.

Outcome when the depth is insufficient: an agent that starts without the `Agent` tool records `blocked_reason: "spawn_agent_unavailable"`, does no specialist work, and returns a line beginning `AGENT_TOOL_UNAVAILABLE`; a coordinator that receives that line from a child halts with the same reason instead of doing the child's work. The `enforce-epic-invocation-origin.ps1` hook also denies a chain delegation with `NESTING_DEPTH_INSUFFICIENT:` when the configured limit is below 3.

Fallback: when the depth cannot be raised, the main session itself launches each per-feature `Agent(orchestrator)` with the same delegation prompt the coordinator would have sent, including `Preparation mode: true` on the preparation path, so each orchestrator runs at depth 1 and its specialists at depth 2.
