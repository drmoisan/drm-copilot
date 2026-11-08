---
name: epic-orchestrate
description: Execute a manually authored multi-feature epic through deterministic waves, isolated worktrees, integration-branch fan-in, and a final integration PR.
---

# Epic Orchestrate Skill

Use this manual-manifest compatibility entry only from the root session. The root session must
delegate the supplied manifest or slug to the project custom agent `epic-orchestrator`; an
ordinary `orchestrator` is prohibited from doing so. A committed planner kickoff is optional for
this entry path.

Use the epic manifest path or slug supplied in the invoking user request.

## Prerequisites

Read `AGENTS.md`, applicable language policies, `config/orchestration-routing.json`, and any
existing `artifacts/orchestration/epic-orchestrator-state.json` checkpoint before acting.

## Manifest Contract

The source of truth is `docs/features/epics/<epic-slug>/epic.md`. Its YAML frontmatter is:

```yaml
---
epic: <epic-slug>
integration_branch: epic/<epic-slug>-integration
created_at: <iso8601>
intent: # optional as a whole
  epic_type: <business | enabler>
  business_outcome_hypothesis: <non-empty measurable outcome>
  leading_indicators: [<string>, ...]
  nfrs: [<string>, ...]
features:
  - issue_num: <int>
    feature_folder: <resolvable-hint-basename>
    depends_on: [<upstream-issue_num>, ...]
---
```

`issue_num` is the stable primary key. `feature_folder` is a resolvable hint under `active/` or
`completed/`. Every dependency must resolve against the union of issue numbers and legacy folder
basenames. Reject duplicate folders, unresolved dependencies, malformed optional intent, and
cycles before kickoff.

## Wave Computation

Use longest-path layering:

```text
wave(f) = 0                                      when depends_on(f) is empty
wave(f) = 1 + max(wave(d) for d in depends_on(f)) otherwise
```

Run `pwsh -NoProfile -File .codex/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath <manifest>` as the tested implementation
(the Python module `epic_wave_computation` is this repository's parity reference). Serialize features
within each wave lexicographically by folder, without changing wave membership.

## Entry Paths

- Prepared path (`epic-run`): require and validate `epic-kickoff.md`, reuse the recorded
  integration branch, and resume each child at atomic execution.
- Manual path (`epic-orchestrate`): validate the manifest and create the integration branch when
  absent. A kickoff artifact is not required.

## Integration Branch and Child Worktrees

Create a missing integration branch from current `origin/main` and push it. Before each wave,
fetch the current remote integration tip. Create every child worktree from that tip, never from
`main`, and set each feature PR base explicitly to the integration branch.

Before each wave launches, run `git fetch origin main` and then
`git rev-list --count <integration>..origin/main`. A zero count proceeds directly to the wave.
A non-zero count means `origin/main` has commits the integration branch lacks. Before the wave
launches, `epic-orchestrator` merges `origin/main` into the integration branch
(`git merge --no-ff origin/main`, resolving any conflicts; no rebase, no force-push), pushes the
integration branch, re-fetches the integration tip, and launches the wave. Commits that reach
`origin/main` afterwards are picked up by the next wave's check or by the final integration PR.

Launch all ready children in one bounded parallel wave. Before each launch, persist the
epic-child topology receipt, reviewed complexity assessment, delegation receipt, and Codex
model-routing receipt with the same `delegation_id`, then select the generated deployment agent.
C3 epic children use the elevated Astra/High profile. The child prompt contains:

> `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create.`

For prepared epics, also provide the committed `plan-path` and state that the child resumes at
atomic execution. For each dependency, include its concrete spec, plan, PR, merge SHA, and target
branch as upstream context.

Do not use native `spawn_agent` for worktree children. For each wave, write an immutable launch
specification under `artifacts/orchestration/epic-child-launches/<wave-id>/` and invoke
`.codex/scripts/launch-epic-child-wave.ps1` with `checkpoint_kind: "epic-orchestrator"`, the
current wave number, checkpoint path, integration branch, `max_parallel_features`, and exact
generated profile values for every child. Monitor the durable wave status and record each child
launch receipt/status path. A missing session id, nonzero exit, receipt mismatch, or incomplete
wave status blocks the wave barrier.

The JSON specification requires `schema_version: 1`, `wave_id`, `checkpoint_kind`,
`checkpoint_path`, `integration_branch`, `wave_number`, `max_parallel_features`, and `launches`.
Each launch requires `launch_id`, `delegation_id`, `feature_folder`, positive `issue_num`,
`deployment_agent`, `model`, `model_reasoning_effort`, `permissions`,
`execution_context: "epic_execution_child"`, canonical absolute `worktree_path`, `branch_name`,
and the exact prompt. Invoke it as:

```powershell
pwsh -NoProfile -File .codex/scripts/launch-epic-child-wave.ps1 -LaunchSpecPath <spec-path> -MaxParallel <max_parallel_features>
```

Parse the returned JSON `status_path`. The status file is shared by the wave; every child has its
own immutable receipt but references the same `wave.<wave_id>.status.json`.

## Wave Barrier

Do not start wave N+1 until every dependency edge is durably `merged` or `worktree_removed`.
Reconcile this state using Git worktrees, branches, and live PR state on resume. The Codex
mutation hook is a per-child deterrent; the epic-state validator is the retrospective,
authoritative backstop.

## Early Dependent Starts (early_start)

This section applies only to a feature whose manifest entry carries `early_start_on`. Without
that field this section does not apply, and every other section of this skill governs unchanged.

**Opt-in.** A feature opts in through the manifest field `early_start_on: <upstream issue_num>`,
which must be one of its `depends_on` values. The manifest is human-authored and the wave
computation reads only `depends_on`, so the field moves no wave. The dependent may then start
before its upstream merges, once the upstream has settled its interface, and it may reach
`pr_open` only after the upstream merged and the dependent merged that result into its branch.

**Key and writers.**

- `features[].early_start` on the dependent holds `dependency`, `upstream_branch`,
  `interface_settled_at`, `interface_evidence`, and later `synced_at`. `epic-orchestrator`, the
  only writer of `features[]`, writes it from the manifest field and the evidence file.
- `<upstream FEATURE>/evidence/other/interface-settled.<timestamp>.md` carries `Timestamp:`,
  `Upstream-Head:`, and `Interface-Paths:` (repository-relative paths). The upstream child writes
  it (a plan task, otherwise its `orchestrator` after S5) and pushes it to the upstream branch;
  the upstream's kickoff prompt asks for it only when a dependent names that upstream.
- `early_start_synced_at` is a tolerated top-level key of the dependent child's checkpoint,
  written by the child from the clock in step 8.
- `early_start.synced_at` on the epic feature is written by `epic-orchestrator` in the write that
  moves the feature to `pr_open` or later, after the ancestry check of step 9.

The bounded child return keeps its eight fields; the parent reads the child key from the child
checkpoint under `worktree_path`.

**Procedure.**

1. Parent: while an armed dependent waits, look for the evidence file on
   `origin/<upstream_branch>` every 30 seconds for at most 90 minutes. When none appears, keep the
   wave barrier.
2. Parent: write `early_start`, `merge_status: "worktree_created"`, and `worktree_created_at`,
   then validate the epic checkpoint through the installed MCP validator, which `## Completion`
   requires with no fallback. Installed MCP lags this rule (D9), so it reports an
   `EPIC_WAVE_BARRIER_VIOLATION` that names the feature until the extension release that carries
   the rule is installed: remove the three values and keep the barrier. The early start is
   therefore unavailable on Codex until that release is installed. The same fallback applies when
   an integration branch older than this reduction lacks the rule, when the sibling
   `epic-wave-barrier-early-start.ps1` is absent, or when the mutation hook denies the child.
3. Parent: launch with the literal `Epic mode: true` kickoff line plus
   `Early start: true. dependency: <dep_issue_num>. upstream_branch: <branch>. interface_evidence: <path>. Run the child procedure of ## Early Dependent Starts (early_start) before S7 and S8.`
   and, for the dependency, the line
   `Upstream context for <issue_num>: early start on <dep_issue_num> (spec: <path>; plan: <path>; upstream_branch: <branch>; not merged).`
4. Child: branch from `origin/<integration_branch>`, then run `git fetch origin <upstream_branch>`
   and `git merge --no-ff origin/<upstream_branch>` before the first plan task.
5. Child: after S6, wait for the upstream merge. Run
   `gh pr list --head <upstream_branch> --base <integration_branch> --state merged --json number,mergeCommit`
   every 30 seconds for at most 90 minutes, then
   `git merge-base --is-ancestor <merge commit> origin/<integration_branch>`. When the wait ends
   without a merge, stop with `blocked_reason: "policy_hold"`.
6. Child: run `git diff --name-only <Upstream-Head> <merge commit> -- <Interface-Paths>`. Any listed
   path stops the child with `blocked_reason: "premise_falsified"`, unsynced and with no PR.
7. Child: run `git merge --no-ff origin/<integration_branch>`. The sync is a merge, not a rebase.
   A conflict enters `## Fan-In and Conflict Handling`.
8. Child: re-run the local gate, commit, push, record `early_start_synced_at`, and only then
   start S7 or S8.
9. Parent: before the `pr_open` write, check
   `git merge-base --is-ancestor <upstream merge_commit_sha> origin/<child branch>`. Write
   `synced_at` only when the check passes and the child key exists; otherwise Layer 2 reports the
   unsynced message below.
10. Parent: after a stop in step 5 or step 6, read the diff against the child's plan. When no task
    cites a changed symbol, or the stop was the wait bound, record fresh `interface_settled_at` and
    `interface_evidence` and delegate once more on a branch `<child branch>-r<n>` from the pushed
    child branch, resuming at step 5; otherwise the edge stops with `premise_falsified`.
    `early_start` stays recorded, because removing it from a started feature would turn a truthful
    record into a barrier violation.

The sync of steps 5 to 8 finishes before S7 and S8, so the reviewed head is always a post-sync
head; conflict cycles of an early child are never light.

**Messages.** Layer 2 judges the one edge that a valid record names by its own table: a dependent
at `not_started` or `worktree_created` reports nothing; at any later or unknown status an unmerged
upstream reports
`EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later while early_start dependency <d> is not merged`,
and a merged upstream without a non-empty string `synced_at` reports
`EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later without a string synced_at for early_start dependency <d>`.
The validators compare no timestamps on this edge; the ancestry check of step 9 proves the sync.
Layer 1 skips only the named edge while the upstream is at `worktree_created`, `pr_open`,
`ci_green`, or `merge_conflict`, and its deny text is unchanged. Every other edge keeps the
checks of `## Wave Barrier`.

**Codex differences.**

- `## Completion` requires the installed MCP validator with no fallback, so the early start is
  unavailable until a release carrying this rule is installed; step 2 detects that state.
- `Test-CodexChildLaunchSpec` in `.codex/scripts/epic-child-launch-contract.ps1` requires a launch
  specification to cover every non-terminal feature of its wave, so an early start launches only
  when each member of the wave has merged dependencies or a valid `early_start` record.
- Worktrees are created before launch, so step 4 runs inside the launched child worktree.
- A lifecycle-prefixed `dependency` finds no record in the Codex mutation hook, which keys by
  basename or issue number, so the hook fails closed for it; record the dependency's
  `issue_num`.

## Fan-In and Conflict Handling

Each child owns its implementation, review, PR, CI-green gate, and merge into the integration
branch. A merge conflict enters that child's existing remediation loop with a blocking
`remediation-inputs.<timestamp>.md`. Conflict cycles share the child's attempt count,
`remediation_loop.completed_attempts`. The active cycle number is `completed_attempts + 1`, and a
cycle without an applied candidate consumes no number. After three completed attempts without a
`PASS` review, record `blocked_conflict_loop_limit` and stop that edge. The epic agent must not
resolve child conflicts locally.

Epic-child CI verification (issue #1130): a child merge into the integration branch is never
accepted without a green `CI` run on the child head SHA. When no check whose `workflow` is `CI`
exists on the child head, the child runs the dispatch fallback of the `orchestrate` skill's CI Green
Gate and records `ci_gate.dispatch_run_id`; when a child reports that it is blocked because no `CI`
run exists, `epic-orchestrator` dispatches `CI` once on the child branch
(`gh workflow run CI --ref <child branch>`) and resumes the child to record the run.
`enforce-epic-merge-gate-child-ci.ps1` denies an unverified child merge with
`EPIC_CHILD_CI_NOT_VERIFIED`, and a resolved conflict needs a green `CI` run on its new head.

## Worktree Cleanup

After the child merge SHA is recorded and the epic checkpoint mirrors `merge_status: "merged"`,
remove its worktree. The worktree-removal hook denies removal before the matching feature is
`merged` or `worktree_removed`. Record `worktree_removed_at` after success.

## Model and Deployment Policy

Route selection and model selection are independent. The deterministic file-count or marker
route selects topology; the C1-C4 assessment selects a checked-in Codex deployment profile.

- C1: `gpt-6-luna`, low.
- C2: `gpt-6.1-sol`, medium.
- standalone C3 with ceiling C3: `gpt-6.1-sol`, high.
- epic C3 or C3 with a C4 sibling: `gpt-6-astra`, high.
- C4: `gpt-6-astra`, max.
- `epic-orchestrator`: `gpt-6-astra`, ultra.

Persist the topology and model-routing receipts before every child or `pr-author` delegation. The
deployed agent type and actual model must match its receipts and start attestation. If the
required profile is unavailable, record `model_unavailable` and stop; do not fall back silently.

## Status Projection and Checkpoint

Regenerate `docs/features/epics/<epic-slug>/epic-status.md` from the checkpoint at kickoff, each
merge-status transition, each wave transition, and each final-PR transition. Never treat the
status document as the DAG source.

Post-fan-in allowance (issue #1136): once every feature records `merged` or `worktree_removed`,
the preimplementation gate admits, on the integration branch only and only for the
`merge-in-progress` readiness failure, a Write of `artifacts/pr_body_<N>.md` or
`artifacts/pr_body_<N>.receipt.json` and a `git add` or `git commit` (options `-m`, `--message`,
`-F`, `--file`, `--trailer` only) of `docs/features/epics/<epic-slug>/epic-status.md`; a commit
without `-- <status doc>` needs a staged index that is exactly the status document. Use a
forward-slash `-F` path, and commit separately from a chained `git add`. It is a policy-level
control, not a security control.

Persist `artifacts/orchestration/epic-orchestrator-state.json` with `objective`, `route_id:
"epic"`, epic folder/manifest/status paths, integration branch, completed and next steps,
timestamps, bounded `max_parallel_features`, current wave, waves, features and lifecycle
timestamps, final PR, complexity/model receipts, and required agent/skill/MCP receipts. Each
launched feature records issue/folder, unique branch/worktree, delegation receipt/id,
delegation-bound model receipt, and launch receipt/status paths.

On resume, reconcile the checkpoint against `git worktree list --porcelain`, branch state, and
`gh pr view --json state,mergedAt,headRefOid` before continuing.

## Final Integration PR

After every child is merged or its worktree removed, delegate final PR authoring to the routed
`pr-author` profile, refresh PR context through the MCP surface, run the CI-green procedure,
record the current head SHA and successful conclusion, and merge the integration branch to
`main` only through the merge gate. A zero exit from `gh pr merge` does not prove a merge when
`main` uses a merge queue: read the pull-request state (`state`, `mergeCommit`, `mergedAt`,
`isInMergeQueue`, and `autoMergeRequest`) every 30 seconds for at most 90 minutes until it is
`MERGED`, then run `git fetch origin main` and
`git merge-base --is-ancestor <merge-commit-oid> origin/main`. The final merge SHA is recorded
only after the merge is confirmed by polling and ancestry check. When the 90 minutes are
exhausted, report `awaiting_merge_queue` and do not record a merge; never re-issue the merge in
a loop (issue #952).

## Completion

Do not report completion until every feature is `merged` or `worktree_removed`, the final PR is
merged with its merge SHA recorded, `epic-status.md` reflects that state, acceptance criteria are
checked, and the MCP validator passes `epic-orchestrator-state` with `require_complete: true`.
Require both `require_codex_topology: true` and `require_codex_model_routing: true` on that final
validation call.
