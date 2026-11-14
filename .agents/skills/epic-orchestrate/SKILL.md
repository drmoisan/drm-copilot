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

A feature may also carry the optional key `cross_epic_depends_on` (issue #1162, D1): one line,
an inline flow sequence of flow mappings with exactly the keys `epic`, `integration_branch`, and
`issue_num`. `epic` is one plain segment that differs from this manifest's `epic`;
`integration_branch` is `epic/` plus the `epic` value plus `-integration`; `issue_num` names a
`features[]` entry of the other epic's manifest. Block-style values and cross-epic edges inside
`depends_on` are rejected. Cross-epic edges move no wave; see
`## Cross-Epic Dependencies (cross_epic_depends_on)`.

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

A recorded `Owner directives:` block is passed verbatim to each child whose scope matches an
entry, as defined in the `owner-directives` skill; `epic-orchestrator` never authors or edits
entries.

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

## Cross-Epic Dependencies (cross_epic_depends_on)

This section applies only when a feature of the manifest carries `cross_epic_depends_on` (issue
#1162). Without the key every other section of this skill governs unchanged.

**CLI.** `pwsh -NoProfile -File .codex/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 -Mode validate|feature|main -ManifestPath <manifest> [-Issue <issue_num>] [-WaitSeconds <0 to 540>]`
exits 0 with compressed JSON (`Mode`, `Decision`, `Reason`, and per-edge or per-epic PR number,
merge commit SHA, and evaluation time), 1 for a manifest error, and 2 for a usage error. The other
epic's manifest is read with `git show` from `origin` of its integration branch, or from
`origin/main` when that branch no longer exists.

**Kickoff validation.** At kickoff, alongside `Invoke-EpicWave.ps1`, run `Invoke-EpicCrossReadiness.ps1`
with `-Mode validate`. Each manifest error begins with its code and blocks kickoff like an
unresolved `depends_on` entry. The nine codes are `EPIC_CROSS_DEPENDENCY_MALFORMED`,
`EPIC_CROSS_DEPENDENCY_UNSUPPORTED_FORM`, `EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH`,
`EPIC_CROSS_DEPENDENCY_SAME_EPIC`, `EPIC_CROSS_DEPENDENCY_DUPLICATE`,
`EPIC_CROSS_DEPENDENCY_UNRESOLVED`, `EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE`,
`EPIC_CROSS_DEPENDENCY_CYCLE` (a feature-level cycle across this manifest and the directly
referenced manifests, one hop), and `EPIC_CROSS_DEPENDENCY_EARLY_START_CROSS` (`early_start_on`
may not name a cross-epic issue).

**Launch hold.** Before a feature with cross-epic edges receives a worktree, run the CLI with
`-Mode feature -Issue <issue_num>`. A held feature never receives a worktree and stays
`not_started`; its intra-epic dependents wait through the wave barrier, and independent features
proceed. The prerequisite PR is the one merged PR into the other integration branch whose listed
files include the prerequisite feature folder under `docs/features/active/` or
`docs/features/completed/`, or whose head branch carries the prerequisite issue number as a
hyphen-delimited token; main-sync chore PRs never match. Each edge takes the first matching row:

| Order | Condition | Decision | Reason |
|---|---|---|---|
| 1 | Adapter error, ancestry exit other than 0 or 1, or `PREREQ_SNAPSHOT_INVALID` | hold | `PREREQ_UNVERIFIABLE` |
| 2 | One matching PR, the other integration branch is absent, and its merge commit is an ancestor of `origin/main` | release | `PREREQ_IN_MAIN` |
| 3 | No matching merged PR | hold | `PREREQ_PR_NOT_FOUND` |
| 4 | More than one matching PR | hold | `PREREQ_PR_AMBIGUOUS` |
| 5 | Merge commit not an ancestor of the other integration branch | hold | `PREREQ_NOT_ANCESTOR` |
| 6 | Merge commit already an ancestor of the own integration branch | release | `PREREQ_ALREADY_INTEGRATED` |
| 7 | Otherwise | merge_required | `PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED` |

Every edge `release` gives `release`; any `hold` gives `hold`; otherwise `merge_required` lists
the distinct integration branches to merge. A feature without cross-epic edges gives `release` with
`NO_CROSS_EPIC_EDGE`. Adapter failures never fail open.

**Integration merge (D4).** On `merge_required`, for each listed integration branch: fetch it from
`origin`; when the prerequisite merge commit is already an ancestor of the own integration branch,
make no merge; otherwise run `git merge --no-ff` of the fetched branch in the integration
worktree, never a rebase or fast-forward, with conflicts handled as in the main sync, then push,
re-fetch the own integration branch, record `integration_merge_commit_sha` and `integrated_at` in
the hold record, and launch the feature. `PREREQ_IN_MAIN` makes no merge.

**Context handoff (D10).** After the merge, the child launch context carries one line per
cross-epic dependency, appended after the epic-mode context line:
`Upstream context for {issue_num}: cross-epic depends on {epic}#{dep_issue_num} (spec: {dep_spec_path}; plan: {dep_plan_path}; merged as PR #{pr}, commit {sha}, into {other_integration_branch}; integrated into {own_integration_branch} as {integration_sha}).`
In preparation mode (`epic-plan`) the same line carries `not merged` in place of the merge facts.

**Main hold (D5).** Before `## Final Integration PR` opens the integration-to-main PR, run the CLI
with `-Mode main`. Each distinct prerequisite epic takes the first matching row:
`MAIN_PREREQ_UNVERIFIABLE` (adapter error, hold), `MAIN_PREREQ_PR_NOT_MERGED` (no merged PR from
the other integration branch into `main`, hold), `MAIN_PREREQ_PR_AMBIGUOUS` (more than one, hold),
`MAIN_PREREQ_NOT_ANCESTOR` (merge commit not an ancestor of `origin/main`, hold), otherwise
`MAIN_PREREQ_RELEASED`. No edge gives `not_applicable`; every epic released gives `release`;
otherwise `hold`. Open the PR only on `release` or `not_applicable`. On release the main sync runs
first, so the PR diff no longer carries the other epic's commits. The check is re-run immediately
before `gh pr merge`. Record the result as `cross_epic_main_gate`.

**Bounded wait (D8).** Re-evaluate holds at every scheduling event. When every runnable feature is
held and nothing is in flight, or the main hold is in force, call the CLI with `-WaitSeconds 540`;
it polls every 60 seconds and returns at the first release or at the bound. Repeat the call at
most 40 times, then record `blocked_reason: "external_dependency"`, regenerate `epic-status.md`,
and stop; running `epic-run` again on the same epic slug resumes. Hold records are a cache,
re-derived from `gh` and `git` on resume.

**Records (D7).** Each feature carrying the key copies `cross_epic_depends_on[]` into the epic
checkpoint with `status` (`held`, `released`, `integrated`, `in_main`), `reason`,
`prerequisite_pr_number`, `prerequisite_merge_commit_sha`, and `verified_at`; a held feature stays
`not_started`. The top-level `cross_epic_main_gate` carries `status` (`held` or `released`) and
`prerequisites[]` (`epic`, `integration_branch`, `pr_number`, `merge_commit_sha`, `verified_at`).
`epic-status.md` gains a cross-epic table (edge, status, reason) only when the key is present. The
repository CLI `scripts.dev_tools.validate_orchestration_artifacts` with its
`epic-orchestrator-state` subcommand applies these rules; the installed MCP validator applies them
only after the extension release that carries them is installed.

**Status mapping (D7).** A `hold` decision records `held`. `PREREQ_IN_MAIN` records `in_main`.
`PREREQ_ALREADY_INTEGRATED`, or a completed D4 merge, records `integrated` before the feature is
launched. `released` is recorded only between a `merge_required` decision and its completed D4
merge, so a feature is launched only when every entry is `integrated` or `in_main`, the two
statuses the started-while-held invariant accepts. A main-gate `release` records
`cross_epic_main_gate` status `released`, and a main-gate `hold` records `held`.

**Disclosure (D5).** The merge-gate hook `enforce-epic-merge-gate.ps1` does not read
`cross_epic_main_gate`. The integration-to-main hold is a skill-level policy control enforced by
`epic-orchestrator`, with the completion invariant of the validators as a retrospective backstop,
consistent with the checkpoint-cache doctrine.

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
with the child's `pr_number` and `merge_commit_sha` recorded in the matching `features[]` entry,
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

Merged-feature follow-up allowance (issue #1141): before fan-in, a follow-up on a child that has
already merged is made in the integration worktree on the integration branch. For the same
`merge-in-progress` failure, the gate admits it when the matching `features[]` entry records
`merged` or `worktree_removed`, a plain `feature_folder` basename (an optional
`docs/features/active/` or `docs/features/completed/` prefix is stripped), a `merge_commit_sha`
of 40 or 64 lowercase hex characters, and an integer `pr_number` above 0. Allowed roots are
`docs/features/active/<basename>/`, `docs/features/completed/<basename>/`, and the status
document; Write or Edit, `git add [--] <paths>`, and `git commit` (options `-m`, `--message`,
`-F`, `--file`, `--trailer` only) with `-- <paths>` or a staged index that lies entirely under
those roots are admitted. `-a`, `--all`, `--amend`, `-A`, other flags, globs, `..`, backslashes,
chained non-git commands, and sibling folders keep their deny. Only the epic checkpoint entry is
evidence; no per-item checkpoint is read. Code corrections go through a new orchestrated child,
and agents never hand-author a readiness checkpoint. It is a policy-level control, not a
security control.

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
