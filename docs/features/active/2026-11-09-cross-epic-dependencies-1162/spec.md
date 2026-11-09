# 2026-11-09-cross-epic-dependencies — Spec

- Issue: #1162
- Parent (optional): none
- Owner: drmoisan
- Last Updated: 2026-11-09T21-50
- Status: Draft
- Version: 0.2
- Work Mode: full-feature
- Requirements source: docs/features/active/2026-11-09-cross-epic-dependencies-1162/issue.md
- Research: docs/features/active/2026-11-09-cross-epic-dependencies-1162/research/research.2026-11-09T21-50.md

## Overview

An epic manifest today lists only dependency edges inside the epic and assumes that every earlier epic has already merged. Starting a dependent epic early, so that epics overlap, would launch features whose prerequisites in the earlier epic have not merged.

This feature adds an optional cross-epic dependency edge to the epic manifest. A feature that carries such an edge is held by `epic-orchestrator` until the named prerequisite feature has merged into the other epic's integration branch (verified with `gh` and `git` ancestry). On release, the orchestrator merges the other epic's integration branch into its own integration branch with a direct merge commit before it starts the feature. The epic's integration-to-main pull request is held until the prerequisite epic's integration-to-main pull request has merged. The epic progress report's critical path includes the cross-epic edges.

- Target users and primary use cases: the repository owner and coordinating sessions that run several epics concurrently through `/epic-run` and `/epic-orchestrate`; `epic-planner` and `epic-orchestrator` agents that read the manifest; operators who read `/epic-progress-report` output.
- Expected impact: dependent epics can start while their prerequisite epics are still in flight, without any feature starting before its cross-epic prerequisite is integrated, and without the dependent epic reaching `main` before its prerequisite epic.
- Backward compatibility: a manifest, planner checkpoint, or epic checkpoint without `cross_epic_depends_on` behaves and validates byte-identically to today. Every new parameter defaults to today's behavior.

## Decisions

| ID | Decision | Rationale | Source |
|---|---|---|---|
| D1 | Cross-epic edges use a new optional per-feature key `cross_epic_depends_on`, written on one line as an inline flow sequence of flow mappings with exactly the keys `epic`, `integration_branch`, and `issue_num`; edges inside `depends_on` and block-style values are rejected. | `depends_on` is read by the wave CLI, both Python validators, the TypeScript ports, the Layer 1 hook, and the progress-report graph, all of which would reject a foreign reference; a block-style value disables the progress report's manifest fallback for the whole epic. | adopted from research |
| D2 | The pure readiness logic and its thin adapters are PowerShell in the existing `.claude/lib/epic-wave/` directory: `EpicCrossDependency.psm1` plus the CLI `Invoke-EpicCrossReadiness.ps1`. | That directory already has a Codex virtual resource mapping and a byte-identity contract test, so no new push-down mapping is needed; no new Python file is created. | adopted from research |
| D3 | The prerequisite is identified through the other epic's manifest (issue number to feature folder), a `gh pr list` snapshot of merged PRs into the other integration branch, a pure match on the prerequisite's feature folder, and a `git merge-base --is-ancestor` check of the PR merge commit. | `epic-status.md` is a projection that varies between epics and may lag; PR bodies of epic children may omit the closing line. The feature folder is touched by every child PR. | adopted from research |
| D4 | On release, `epic-orchestrator` merges the other integration branch into its own integration branch with `git merge --no-ff` using the existing main-sync procedure (step 3 of `## Epic Integration Branch Lifecycle`), pushes, re-fetches, records the merge, and only then launches the feature; when the other integration branch no longer exists and the prerequisite merge commit is an ancestor of `origin/main`, the decision is release with `PREREQ_IN_MAIN` and no extra merge is made. | Reuses a tested, conflict-handling procedure with no rebase and no force push; a deleted integration branch means the prerequisite reached `main`, which the existing main sync already brings in. | adopted from research |
| D5 | The integration-to-main hold is a skill-level gate run through the same CLI in `-Mode main`, recorded in the checkpoint as `cross_epic_main_gate`, with a key-gated completion invariant in the validators as a retrospective backstop; the merge-gate hooks are not changed. | The merge-gate hook is at the size guidance limit, has a Codex twin, and is contended by sibling items; isolated subagents do not exercise branch hooks, so a hook-based gate could not be evidenced in this item. | adopted from research |
| D6 | Validation surfaces: manifest validation through `Get-EpicCrossDependencyManifestError` (CLI `-Mode validate`) at kickoff; key-gated checkpoint shape, started-while-held, and completion invariants extended in place in the Python validators, the TypeScript ports, and a new PowerShell Layer 2 module appended by `Get-OrchestratorStateEpicWaveBarrierError`; byte-identical error strings pinned by a shared corpus in tests/fixtures/epic_cross_dependency/. | Matches the existing wave-barrier precedent; the existing stop hook surfaces the Layer 2 error with no hook-file change; absent keys leave every validator result unchanged. | adopted from research |
| D7 | No new `merge_status` member; a held feature stays `not_started`. New key-gated records: per-feature `cross_epic_depends_on[]` hold records in the epic checkpoint, a top-level `cross_epic_main_gate`, a shape-validated copy in the planner checkpoint, and a cross-epic table in `epic-status.md` only when the key is present. | Avoids a parity change to the enum in the Python, TypeScript, and PowerShell implementations and to the progress report's state mapping, with no loss of safety given the started-while-held invariant. | adopted from research |
| D8 | Holds are re-evaluated at every scheduling event. When every runnable feature is held and nothing is in flight, the agent calls the CLI with `-WaitSeconds 540`; the CLI polls every 60 seconds through an injected sleep seam and returns at the first release or at the bound. The agent repeats the call at most 40 times, then records `blocked_reason: "external_dependency"`, regenerates `epic-status.md`, and stops; `/epic-run` on the same epic slug resumes. | The agent has no `sleep` grant and a Bash call is bounded by the 600-second tool timeout; a bound converts an unbounded cross-epic wait into a resumable halt. The constants are orchestrator defaults, stated in the skill as the early-start precedent states its own, not configuration knobs. | adopted from research |
| D9 | The progress report models each cross-epic prerequisite as an external node identified by the epic slug, `#`, and the issue number; it is `done` when the checkpoint hold record shows `integrated` or `in_main`, otherwise `pending`; it is priced from the other epic's prepared plan or per-type defaults; it does not occupy this epic's parallel cap and adds no steps; the Full report gains one cross-epic line only when an edge exists. | Ignoring unmerged prerequisites fails AC4; a plain node would consume this epic's cap; modeling the other epic's tail needs data the report cannot read reliably. | adopted from research |
| D10 | After the D4 merge, the child delegation carries one upstream-context citation line per cross-epic dependency, appended after the epic-mode kickoff line; in preparation mode (`epic-plan`) the same line carries `not merged` in place of the merge facts. | Parallels `## Context Handoff to Dependent Features`, so the dependent spec and plan cite the upstream contract. | adopted from research |
| D11 | Amends D3. `gh pr list --json files` returns at most 100 files per PR (verified on PR 1116: 659 changed files, 100 listed). The prerequisite PR match therefore accepts a merged PR into the other epic's integration branch whose listed files include a path under the prerequisite's feature folder in `docs/features/active/` or `docs/features/completed/`, or whose `headRefName` carries the prerequisite issue number as a hyphen-delimited token. Exactly one distinct PR must match; zero holds with `PREREQ_PR_NOT_FOUND`, more than one holds with `PREREQ_PR_AMBIGUOUS`. Main-sync chore PRs never match. | A file list truncated at 100 entries can omit the feature folder of a large child PR; the head-branch token is a second, independent identity signal; failing closed on ambiguity keeps a wrong release impossible. | orchestrator confirmation |

## Behavior

### Main flow (happy path)

1. Kickoff. When the manifest of the epic being orchestrated contains a non-empty `cross_epic_depends_on` value on any feature, `epic-orchestrator` runs `Invoke-EpicCrossReadiness.ps1 -Mode validate` alongside the existing wave CLI. Any manifest error is reported as the same synthetic Blocking finding used for an unresolved `depends_on` entry, and no feature is launched.
2. Waves are computed exactly as today from `depends_on` only. Cross-epic edges move no wave.
3. Launch-time hold. Before a feature with cross-epic edges receives a worktree, `epic-orchestrator` runs the CLI with `-Mode feature -Issue` set to that feature's issue number. The decision is one of `hold`, `merge_required`, or `release`, with a reason code (decision table below). A held feature never receives a worktree and stays `not_started`.
4. Integration merge (D4). On `merge_required`, for each distinct other integration branch listed by the decision: `git fetch origin` of that branch; when the prerequisite merge commit is already an ancestor of the own integration branch, no merge is made; otherwise `git merge --no-ff` of the fetched other integration branch in the integration worktree, conflict handling as in the main-sync step, push, re-fetch of the own integration branch, and recording of the merge commit in the hold record. The feature is then launched from the updated own integration branch.
5. Context handoff (D10). The child delegation carries one upstream-context line per cross-epic dependency.
6. Main hold (D5). Before step 6 of `## Epic Integration Branch Lifecycle` opens the integration-to-main PR, `epic-orchestrator` runs the CLI with `-Mode main`. The PR is opened only when the decision is `release` or `not_applicable`. On `release`, the existing main sync (step 3) runs first so the PR diff no longer carries the other epic's commits. The check is re-run immediately before `gh pr merge`.
7. Progress report (D9). `/epic-progress-report` includes cross-epic prerequisites as external nodes in the critical-path calculation.

### Alternate and edge flows

- Intra-epic dependents of a held feature wait through the existing wave barrier; independent features proceed.
- Early start: `early_start_on` may not name a cross-epic issue (manifest error). A feature with both an early-start edge and cross-epic edges still requires cross-epic release before launch.
- The prerequisite epic completed and its integration branch was deleted: the other manifest is read from `origin/main`, and the decision is `release` with `PREREQ_IN_MAIN` when the prerequisite merge commit is an ancestor of `origin/main`.
- The other integration branch was force-moved or rewritten: the merge commit is no longer an ancestor, so the feature holds with `PREREQ_NOT_ANCESTOR`.
- Several features name the same other epic: one integration merge serves all of them; later evaluations return `PREREQ_ALREADY_INTEGRATED`.
- A feature with several cross-epic edges is released only when every edge is `release`; any `hold` holds it; otherwise `merge_required` lists the distinct integration branches to merge.
- Own features merged while the main hold is in force: no integration-to-main PR is opened until release; the D8 bounded wait applies to the main hold in the same way as to feature holds.
- Resume: hold records are a cache. On resume every decision is re-derived from `gh` and `git`.
- Mutual waiting across epics deeper than one hop is not detected; the D8 bound converts it into a halt with `blocked_reason: "external_dependency"`.

### Error handling and recovery

- Adapter failures never fail open. A `gh` or `git` failure, an invalid snapshot, or an ancestry exit code other than 0 or 1 produces `hold` with `PREREQ_UNVERIFIABLE` (feature mode) or `MAIN_PREREQ_UNVERIFIABLE` (main mode).
- An integration-merge conflict follows the existing main-sync conflict handling: resolve, no rebase, no force push.
- After the D8 bound, the run halts with `blocked_reason: "external_dependency"`, the hold records stay in the checkpoint, `epic-status.md` is regenerated, and `/epic-run` on the same epic slug resumes.

## Manifest Syntax (D1)

```yaml
features:
  - issue_num: 1201
    feature_folder: 2026-11-10-consumer-feature-1201
    depends_on: []
    cross_epic_depends_on: [{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]
```

Rules:

- The value is one line: an inline flow sequence of flow mappings. Each mapping has exactly the keys `epic`, `integration_branch`, and `issue_num`.
- `epic` is the other epic's slug: one plain segment of the characters `A-Z`, `a-z`, `0-9`, `.`, `_`, `-`. It must differ from this manifest's `epic`.
- `integration_branch` must equal the string `epic/` followed by the `epic` value followed by `-integration`.
- `issue_num` is a positive integer that names a `features[]` entry of the other epic's manifest.
- Duplicate (`epic`, `issue_num`) pairs on one feature are rejected.
- `early_start_on` may not name a cross-epic issue.
- An absent key or `[]` means no cross-epic edge. Cross-epic edges move no wave and never enter `depends_on`.
- The other epic's manifest is the `epic.md` file in that epic's folder under `docs/features/epics/`, read with `git show` from `origin` of the given integration branch, or from `origin/main` when that branch no longer exists.

### Manifest validation error codes

Every manifest error message begins with its code followed by a colon. The CLI writes them to stderr and exits 1.

| Code | Condition |
|---|---|
| `EPIC_CROSS_DEPENDENCY_MALFORMED` | Value is not an inline flow sequence of flow mappings; a key is missing or extra; a value has the wrong type; `epic` is not one plain segment; `issue_num` is not a positive integer. |
| `EPIC_CROSS_DEPENDENCY_UNSUPPORTED_FORM` | A block-style value is given under the key. |
| `EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH` | `integration_branch` is not `epic/` plus the `epic` value plus `-integration`. |
| `EPIC_CROSS_DEPENDENCY_SAME_EPIC` | `epic` equals this manifest's `epic`. |
| `EPIC_CROSS_DEPENDENCY_DUPLICATE` | The same (`epic`, `issue_num`) pair appears twice on one feature. |
| `EPIC_CROSS_DEPENDENCY_UNRESOLVED` | `issue_num` is not a `features[]` entry of the other manifest. |
| `EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE` | The other manifest is absent on both its integration branch and `origin/main`. |
| `EPIC_CROSS_DEPENDENCY_CYCLE` | A feature-level cycle exists in the union of this manifest and the directly referenced manifests (one hop). |
| `EPIC_CROSS_DEPENDENCY_EARLY_START_CROSS` | `early_start_on` names an issue that appears only in `cross_epic_depends_on`. |

## Readiness Decision Tables

### Prerequisite PR match (D3 as amended by D11)

Input: the merged-PR snapshot from `gh pr list --base` (other integration branch) `--state merged --limit 200 --json number,headRefName,mergeCommit,files`, the prerequisite issue number, and the prerequisite feature folder basename.

1. Exclude every PR whose `headRefName` begins with `chore/epic-` and contains `-main-sync-` (main-sync chore PRs). Excluded PRs are never matched by either rule.
2. File rule: a PR matches when any listed file path begins with `docs/features/active/` or `docs/features/completed/` immediately followed by the prerequisite feature folder basename and a `/`.
3. Token rule: split the last `/`-separated segment of `headRefName` on `-`; a PR matches when one token equals the decimal prerequisite issue number. The comparison uses the prerequisite issue number only (never the epic slug and never any other number). This covers the observed child branch shapes with a trailing issue number, a trailing issue number followed by a retry token such as `r2`, and an issue number preceded by an `exec` token.
4. A PR that matches both rules counts once. Exactly one distinct PR is a match; zero is `PREREQ_PR_NOT_FOUND`; more than one is `PREREQ_PR_AMBIGUOUS`. A snapshot that is not valid JSON or lacks a required field is `PREREQ_SNAPSHOT_INVALID`.

### Feature hold (`-Mode feature`)

Evaluated per edge in order; the first matching row wins.

| Order | Condition | Decision | Reason |
|---|---|---|---|
| 1 | Any adapter error, an ancestry exit other than 0 or 1, or `PREREQ_SNAPSHOT_INVALID` | hold | `PREREQ_UNVERIFIABLE` |
| 2 | Exactly one matching PR, the other integration branch is absent, and its merge commit is an ancestor of `origin/main` | release | `PREREQ_IN_MAIN` |
| 3 | No matching merged PR | hold | `PREREQ_PR_NOT_FOUND` |
| 4 | More than one matching PR | hold | `PREREQ_PR_AMBIGUOUS` |
| 5 | Merge commit not an ancestor of the other integration branch (including an absent branch whose merge commit is not in `origin/main`) | hold | `PREREQ_NOT_ANCESTOR` |
| 6 | Merge commit already an ancestor of the own integration branch | release | `PREREQ_ALREADY_INTEGRATED` |
| 7 | Otherwise | merge_required | `PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED` |

Feature aggregation: every edge `release` gives `release`; any `hold` gives `hold`; otherwise `merge_required` with the distinct integration branches to merge. A feature without cross-epic edges gives `release` with `NO_CROSS_EPIC_EDGE`.

### Integration-to-main hold (`-Mode main`)

Evaluated per distinct prerequisite epic named by any feature, in order; the first matching row wins. Input per epic: `gh pr list --head` (other integration branch) `--base main --state merged --json number,mergeCommit`, and `git merge-base --is-ancestor` of the merge commit against `origin/main`.

| Order | Condition | Per-epic reason |
|---|---|---|
| 1 | Adapter error, ancestry exit other than 0 or 1, or invalid snapshot | `MAIN_PREREQ_UNVERIFIABLE` (hold) |
| 2 | No merged PR from the other integration branch into `main` | `MAIN_PREREQ_PR_NOT_MERGED` (hold) |
| 3 | More than one such PR | `MAIN_PREREQ_PR_AMBIGUOUS` (hold) |
| 4 | Merge commit not an ancestor of `origin/main` | `MAIN_PREREQ_NOT_ANCESTOR` (hold) |
| 5 | Otherwise | `MAIN_PREREQ_RELEASED` (release) |

Aggregation: no cross-epic edge in the manifest gives `not_applicable`; every prerequisite epic released gives `release`; otherwise `hold`.

## API / CLI Surface

`pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 -Mode validate|feature|main -ManifestPath (path of epic.md) [-Issue (issue number)] [-WaitSeconds (0 to 540)]`

- `-Mode feature` without `-Issue` evaluates every feature that carries cross-epic edges and returns one decision per feature.
- `-WaitSeconds` defaults to 0 (single evaluation, no wait). With a positive value the CLI re-evaluates every 60 seconds through the injected sleep seam and returns at the first `release` or `merge_required` result or when the bound is reached. A value outside 0 to 540 is a usage error.
- Output: compressed JSON on stdout with `Mode`, `Decision`, `Reason`, and per-edge (feature mode) or per-epic (main mode) evidence fields: prerequisite PR number, merge commit SHA, and evaluation time from the injected clock.
- Exit codes: 0 when a decision or a clean validation was produced (`hold` is a valid decision); 1 for manifest validation errors with `EPIC_CROSS_DEPENDENCY_` codes on stderr; 2 for a usage error.
- With no cross-epic key in the manifest: `validate` prints an empty result, `feature` prints `release` with `NO_CROSS_EPIC_EDGE`, and `main` prints `not_applicable`.
- `Invoke-EpicCrossReadinessCommand` in `EpicCrossDependency.psm1` returns `ExitCode`, `Stdout`, and `Stderr`; the script prints and exits (the `Invoke-EpicWave.ps1` shape), with an injectable manifest reader (the `Invoke-EpicWaveCommand` `-ReadManifestText` precedent).

### Module functions (`.claude/lib/epic-wave/EpicCrossDependency.psm1`)

Pure (no I/O, no clock, no process): `ConvertFrom-EpicCrossDependencyManifest`, `Get-EpicCrossDependencyManifestError`, `Get-EpicCrossDependencyPrerequisitePr`, `Get-EpicCrossDependencyFeatureDecision`, `Get-EpicCrossDependencyMainGateDecision`.

Thin adapters (the only I/O): `Invoke-EpicCrossGhExe -GhArgs`, `Invoke-EpicCrossGitExe -GitArgs`, `Get-EpicCrossLastExitCode`, and the gather functions `Read-EpicCrossManifestText` (`git show`), `Get-EpicCrossPrSnapshot` (`gh pr list`), and `Test-EpicCrossAncestor` (`git merge-base --is-ancestor`; exit 0 is ancestor, 1 is not ancestor, any other exit is an adapter error). Wait seams: `Wait-EpicCrossInterval -Seconds` (wraps `Start-Sleep`) and `Get-EpicCrossUtcNow`.

### Agent grant

`.claude/agents/epic-orchestrator.md` gains a Bash grant for the invocation prefix `pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1`, in the same trailing-wildcard form as the existing `Invoke-EpicWave.ps1` grant. No `sleep` grant is added. `epic-planner` gains no grant; it relies on the checkpoint validator.

## Data & State (D7)

### Epic checkpoint (`epic-orchestrator-state`)

- Per feature, only when the manifest feature carries the key: `cross_epic_depends_on[]` copied from the manifest, each entry extended with `status` (`held`, `released`, `integrated`, `in_main`), `reason` (last reason code), `prerequisite_pr_number`, `prerequisite_merge_commit_sha`, `verified_at`, and after the D4 merge `integration_merge_commit_sha` and `integrated_at`.
- Top level, written only when some feature carries the key: `cross_epic_main_gate` with `status` (`held` or `released`) and `prerequisites[]` entries of `epic`, `integration_branch`, `pr_number`, `merge_commit_sha`, `verified_at`.
- No new `merge_status` member. A held feature stays `not_started`.
- A halt after the D8 bound records `blocked_reason: "external_dependency"`.

### Planner checkpoint (`epic-planner-state`)

- `features[].cross_epic_depends_on` copied from the manifest; shape-validated only.

### `epic-status.md`

- Gains a cross-epic table (edge, status, reason) only when the key is present; unchanged otherwise.

### Validator invariants (key-gated)

- Shape: `features[].cross_epic_depends_on` entries carry `epic`, `integration_branch`, and `issue_num` under the D1 rules, and the optional hold-record fields carry the D7 types and `status` enum. Implemented once in `scripts/dev_tools/_epic_orchestrator_state_resolution.py` (used by both Python validators) and once in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts` (called from `epic-orchestrator-state-core.ts` and `epic-planner-state-core.ts`). Errors begin with `EPIC_CROSS_DEPENDENCY_MALFORMED:`.
- Started-while-held (Layer 2 analogue): a feature treated as started by the existing start guard (string `worktree_created_at`, or `merge_status` other than `not_started`) with any `cross_epic_depends_on` entry whose `status` is not `integrated` or `in_main` yields `EPIC_CROSS_DEPENDENCY_VIOLATION: {feature} is treated as started while cross-epic dependency {epic}#{issue_num} is not integrated`, with `{feature}`, `{epic}`, and `{issue_num}` substituted. Implemented in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts`, and `.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1`, the last imported (guarded, fail closed) and appended by `Get-OrchestratorStateEpicWaveBarrierError` in `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`.
- Completion (D5 backstop): under `require_complete`, a checkpoint whose features carry `cross_epic_depends_on` must record `cross_epic_main_gate.status == "released"` with one entry per distinct prerequisite epic, each carrying `pr_number`, `merge_commit_sha`, and `verified_at`; otherwise `EPIC_CROSS_DEPENDENCY_MAIN_GATE_INCOMPLETE:` followed by the missing epic slugs. Implemented in `_validate_completion` of `scripts/dev_tools/validate_epic_orchestrator_state.py` and in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`.
- Error strings are byte-identical across the Python, TypeScript, and PowerShell implementations, pinned by the corpus in tests/fixtures/epic_cross_dependency/.
- Validator route: the installed MCP validator lags these rules until a release, so the skill names the repository CLI `scripts.dev_tools.validate_orchestration_artifacts` with the `epic-orchestrator-state` subcommand through Poetry in module form, the route already used by early start.

### Persistence and migration

- Hold records are a cache and are re-derived on resume.
- No migration or backfill: existing manifests and checkpoints carry no new key and validate unchanged.

## Progress Report External Nodes (D9)

- Source of edges: the epic checkpoint row's `cross_epic_depends_on` (with `status`) when present; otherwise the raw single-line manifest value that `Read-EpicProgressManifestFeature` already stores for an unknown key. The reader's abort rule is not changed.
- Node identity: the epic slug, `#`, and the issue number. `Compare-EpicProgressIssue` orders such a node by ordinal text after numeric issues.
- State: `done` when the checkpoint entry records `integrated` or `in_main`; otherwise `pending`.
- Duration: the other epic's prepared plan is read once per prerequisite through the existing `Read-EpicProgressText` seam, with the plan path taken from the other epic's `epic-kickoff.md`. Remaining execution tasks are priced at the pooled rate and other step types at their medians. When the other epic has no kickoff or the plan is unreadable, the node is priced at per-type defaults with zero execution tasks and labeled `external (default)`.
- Cap: `Invoke-EpicProgressListSchedule` gains a node property `External`; external nodes do not occupy this epic's cap. With no external node the schedule is byte-identical.
- Steps and percentage: external nodes add no steps; they enter the time figures only.
- Rendering: `Get-EpicProgressCriticalChain` prints an external node as the epic slug, `#`, and the issue number, without the leading `#` used for local issues. The Full report adds one line labeled `Cross-epic:` in the existing bold-label form, listing each edge and its state, present only when an edge exists. The five TL;DR lines keep their shapes.
- Blocked closure and range: external nodes are never blocked; `Get-EpicProgressScheduleRange` re-prices them with the side rate like any other node.
- New logic lives in the new part file `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1`, dot-sourced by `Get-EpicProgressReport.Logic.ps1`; edits to `Get-EpicProgressReport.Schedule.ps1`, `Get-EpicProgressReport.CriticalPath.ps1`, `Get-EpicProgressReport.Render.ps1`, and `Get-EpicProgressReport.ps1` are call sites and small builders only.

## Context Handoff (D10)

After the D4 merge, the child delegation carries one line per cross-epic dependency, appended after the epic-mode kickoff line:

`Upstream context for {issue_num}: cross-epic depends on {epic}#{dep_issue_num} (spec: {dep_spec_path}; plan: {dep_plan_path}; merged as PR #{pr}, commit {sha}, into {other_integration_branch}; integrated into {own_integration_branch} as {integration_sha}).`

`{dep_spec_path}` and `{dep_plan_path}` are the repository-relative paths of the prerequisite feature's `spec.md` and prepared plan. In preparation mode (`epic-plan`), the preparation prompt carries the same line with `not merged` in place of the merge facts.

## Main Hold Disclosure (D5)

The skill text states, verbatim in substance: the merge-gate hook (`enforce-epic-merge-gate.ps1`) does not read `cross_epic_main_gate`; the integration-to-main hold is a skill-level policy control enforced by `epic-orchestrator`, with a retrospective validator backstop (the completion invariant), consistent with the checkpoint-cache doctrine.

## Constraints & Risks

- Language: pushed-down code (skills, hooks, libraries, helpers) is PowerShell or bash. TypeScript is changed only where existing validator ports are extended. No new Python file is created; existing Python validators are extended in place.
- Design: pure logic in host-neutral functions with unit tests; I/O only in thin `gh` and `git` adapters; injected clock, sleep, filesystem-read, and process seams.
- Tests create no temporary files and perform no wall-clock waits. Manifest text, PR JSON, and checkpoint text are in-memory strings. Tests run parallel-only; order dependence is a defect. Pester imports use `-Force` in `BeforeAll` and remove imported modules in `AfterAll`.
- Coverage: each new or changed PowerShell file at or above 85% line coverage; changed Python and TypeScript files at or above 85% line and 75% branch. `extensions/drm-copilot/jest.config.cjs` gains per-file `coverageThreshold` entries for `epic-orchestrator-state-resolution.ts`, `epic-orchestrator-state-core.ts`, and `epic-planner-state-core.ts` after their current figures are confirmed at or above the thresholds.
- File size: no edited code file reaches 700 lines; new logic goes to the new files named above.
- Bash tool timeout ceiling is 600 seconds, which bounds `-WaitSeconds 540`.
- `gh pr list --limit 200` can truncate a very large PR history; a truncated snapshot can only produce `PREREQ_PR_NOT_FOUND` (hold), never a wrong release from a missing match.
- No new hook and no hook registration are added. Merge-gate hooks are not edited.
- Isolated subagents do not exercise branch hooks; hook-side behavior is proven through Pester suites of the Layer 2 module and the existing stop-hook suites.
- Evidence is written append-only under docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/ with clock-read stamps.

## Implementation Strategy

- Add `EpicCrossDependency.psm1` and `Invoke-EpicCrossReadiness.ps1` in `.claude/lib/epic-wave/`, with Codex stored copies and Claude bundle copies.
- Add `OrchestratorStateEpicCrossDependency.psm1` and append its result in `OrchestratorStateEpicWaveBarrier.psm1`.
- Extend the Python validators and TypeScript ports in place for the key-gated invariants; add the shared corpus.
- Add `Get-EpicProgressReport.CrossEpic.ps1` and wire it through the existing part files.
- Update the epic skills and agents (Claude and Codex variants), templates, bundle copies, and pack manifests.
- Recompute the frozen-surface digests last, after the final merge of `origin/main`.
- Dependency changes: none.
- Rollout: opt-in by manifest key; a manifest without the key is unaffected.

## Files in Scope

Production and documentation (new files marked new):

- .claude/lib/epic-wave/EpicCrossDependency.psm1 (new)
- .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 (new)
- .claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1 (new)
- .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1 (new)
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CriticalPath.ps1
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1
- .claude/skills/epic-progress-report/SKILL.md
- .claude/skills/epic-orchestrate/SKILL.md
- .claude/skills/epic-plan/SKILL.md
- .claude/skills/epic-run/SKILL.md
- .claude/agents/epic-orchestrator.md
- .claude/agents/epic-planner.md
- .agents/skills/epic-orchestrate/SKILL.md
- .agents/skills/epic-plan/SKILL.md
- .agents/skills/epic-run/SKILL.md
- .codex/agents/epic-orchestrator.toml
- .codex/agents/epic-planner.toml
- scripts/dev_tools/_epic_orchestrator_state_resolution.py
- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py
- scripts/dev_tools/validate_epic_orchestrator_state.py
- scripts/dev_tools/validate_epic_planner_state.py
- extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts
- extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts
- extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts
- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
- extensions/drm-copilot/jest.config.cjs
- docs/features/templates/epic/epic.md
- extensions/drm-copilot/resources/feature-templates/epic/epic.md

Claude bundle copies:

- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1 (new)
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CriticalPath.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1 (new)
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 (new)
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1 (new)
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1

Codex stored copies (published by push-down at `.codex/lib/epic-wave/`, byte-identical to `.claude/lib/epic-wave/`):

- extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1 (new)
- extensions/drm-copilot/resources/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 (new)

Codex and agents bundle copies (generated by `scripts/dev_tools/generate_codex_agent_variants.py`; base files are hand-edited):

- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-planner.toml

Pack manifests:

- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (gains the new progress-report part file, the two new epic-wave files, and the new orchestrator-state module)
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json (gains the two new `.codex/lib/epic-wave/` entries; written by `scripts/dev_tools/generate_codex_agent_variants.py`)

Tests and fixtures (new files marked new; names fixed by this spec):

- tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1 (new)
- tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1 (new)
- tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1 (new)
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Tests.ps1 (new)
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Parity.Tests.ps1 (new)
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1 (new)
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Schedule.Tests.ps1
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CriticalPath.Tests.ps1
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.CriticalPath.Tests.ps1
- tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1
- tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1 (new)
- tests/scripts/dev_tools/test_epic_cross_dependency_validation.py (new)
- tests/scripts/dev_tools/test_epic_cross_dependency_parity_corpus.py (new)
- extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts (new)
- tests/fixtures/epic_cross_dependency/ (new corpus directory)
- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py (frozen-surface digests)

Feature folder:

- docs/features/active/2026-11-09-cross-epic-dependencies-1162/ (plan, acceptance-criteria check-offs, and append-only evidence under its evidence/ directory)

Existing contract tests that are run unchanged against the edited surfaces: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_virtual_paths.py`, the Codex generator `--check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `codex-epic-runtime-contracts.Tests.ps1`, `test_parallel_orchestrator_surface_contracts.py`, `test_epic_orchestrator_permission_contracts.py`, `test_epic_skill_script_citations_shipped.py`, `test_epic_orchestrate_main_sync_contract.py`, `test_epic_bounded_child_return_contract.py`, `test_epic_run_kickoff_discovery_contract.py`, `test_parallel_planner_surface_contracts.py`, `test_single_pass_preflight_contracts.py`, `merge_queue_documentation_expectations.py`, `test_orchestrator_state_remediation_docs.py`, `early-start-skill-contract.Tests.ps1`, `owner-directives-skill-contract.Tests.ps1`, `checkpoint-hygiene-skill-contract.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `claude-pack-manifest-completeness.test.ts`, `test_claude_rules_frontmatter.py`, every existing progress-report part test, and the existing epic validator, wave, and wave-barrier test suites (the absent-key regression baseline).

## Sibling Items

Prepared concurrently; their feature folders and branches are not present in this worktree, so the overlap below is stated from the issue scopes and must be re-checked at execution start.

| Sibling | Scope | Probable shared surfaces with this item |
|---|---|---|
| #1156 | Lighter integration-merge path | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, merge gates, remediation documents, checkpoint schema, the frozen-surface digests |
| #1157 | Owner directives reach agents | owner-directives skill, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, executor documents, a new PreToolUse hook, the frozen-surface digests |
| #1158 | Test-execution policy | test-execution policy surfaces; no planned file overlap |
| #1159 | Single hook dispatcher | hook registration; the stop hook that loads `OrchestratorStateEpicWaveBarrier.psm1` (re-check the guarded import path) |
| #1160 | Preimplementation gate false positives | the preimplementation gate, which this item relies on only for the integration merge already used by main sync |
| #1161 | Planner worktree removal | `.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md`, the epic planner checkpoint validators, the worktree-removal gate |
| #1163 | Isolated worktrees and session-root resolution in hooks | hook resolution libraries; no planned file overlap |

Rules for this item:

- The implementation works in either merge order relative to every sibling.
- At execution start, after fetching `origin/main` and the sibling branches, every shared file is re-read before it is edited.
- Skill and agent changes are added as separate sections or appended sentences; text owned by a sibling (for example step 3 and step 6 of `## Epic Integration Branch Lifecycle`, or `## Fan-In to the Integration Branch` in `epic-plan`) is referenced, not rewritten.
- This item adds no hook and no hook registration.
- The frozen-surface digests in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` are recomputed from the file bytes after the final merge of `origin/main`, never carried from an earlier commit, with a `# RE-BASELINED by issue #1162.` paragraph naming which digests moved and which merges were combined.

## Non-Goals

- Detection of mutual cross-epic waiting deeper than one hop; the D8 bound converts it into a resumable halt.
- Hook-level enforcement of the integration-to-main hold in the merge-gate hooks; AC5 is met by the skill-level gate with the validator backstop.
- Modeling the prerequisite epic's own integration-to-main tail as an extra term in this epic's time figures; the report shows the cross-epic line only.
- Automatic scheduling of the `/epic-run` resume after an `external_dependency` halt.
- A block-style YAML form of `cross_epic_depends_on`, or cross-epic references inside `depends_on`.
- A new `merge_status` member, a new progress-report step type, or a change to the wave CLI JSON contract.
- A Codex variant of the epic progress report (none exists today).

## Acceptance Criteria

Issue AC1: manifest schema accepts cross-epic edges; validated and documented; manifests without them behave as today.

- [ ] `.claude/skills/epic-orchestrate/SKILL.md` has a new section `## Cross-Epic Dependencies (cross_epic_depends_on)` documenting the D1 syntax and rules, the manifest error codes, both decision tables, the D4 merge procedure, the D7 records, the D8 wait, the D10 handoff line, and the D5 disclosure; `## Epic Dependency Manifest` references it; `.agents/skills/epic-orchestrate/SKILL.md` `## Manifest Contract` states the same rules; verified by `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1`.
- [ ] `docs/features/templates/epic/epic.md` and `extensions/drm-copilot/resources/feature-templates/epic/epic.md` document `cross_epic_depends_on` in frontmatter comments and remain byte-identical to each other; `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` passes unchanged.
- [ ] `Get-EpicCrossDependencyManifestError` returns each code in the Manifest validation error codes table for its condition and no error for a valid manifest, and `Invoke-EpicCrossReadiness.ps1 -Mode validate` exits 1 with the codes on stderr for an invalid manifest; verified by `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1` and `tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1`.
- [ ] The Python and TypeScript checkpoint validators reject a malformed `features[].cross_epic_depends_on` entry with an `EPIC_CROSS_DEPENDENCY_MALFORMED:` error in both the epic orchestrator and epic planner checkpoints, with byte-identical strings across runtimes; verified by `tests/scripts/dev_tools/test_epic_cross_dependency_validation.py`, `tests/scripts/dev_tools/test_epic_cross_dependency_parity_corpus.py`, and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts` reading tests/fixtures/epic_cross_dependency/.
- [ ] A manifest, planner checkpoint, or epic checkpoint without `cross_epic_depends_on` produces results identical to the pre-change behavior: the existing epic validator, wave, wave-barrier, and progress-report test suites pass unchanged, the wave CLI output is unchanged, and the CLI prints an empty result (`validate`), `release` with `NO_CROSS_EPIC_EDGE` (`feature`), and `not_applicable` (`main`) for such a manifest.

Issue AC2: pure readiness logic decides hold or release from prerequisite merge state, with unit tests; gh and ancestry checks are thin adapters.

- [ ] `Get-EpicCrossDependencyPrerequisitePr` implements the D11 match: file rule, token rule, a PR matching both rules counted once, `PREREQ_PR_NOT_FOUND` for zero matches, `PREREQ_PR_AMBIGUOUS` for more than one, `PREREQ_SNAPSHOT_INVALID` for an invalid snapshot; a token rule test proves a branch whose name contains the issue number only as part of a longer token does not match; verified by `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1`.
- [ ] A test in `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1` proves a main-sync PR is not matched: a snapshot holding only a PR with head branch `chore/epic-1188-main-sync-2`, whose listed files include a path under the prerequisite feature folder, with prerequisite issue 1188, yields `PREREQ_PR_NOT_FOUND`; the same snapshot plus one real child PR yields that child PR as the single match.
- [ ] `Get-EpicCrossDependencyFeatureDecision` and `Get-EpicCrossDependencyMainGateDecision` return the decision and reason of every row of the Feature hold and Integration-to-main hold tables, including first-match-wins ordering and the multi-edge and multi-epic aggregation rules; verified by table-driven tests in `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1`.
- [ ] The pure functions perform no I/O: all `gh` and `git` calls go through `Invoke-EpicCrossGhExe -GhArgs` and `Invoke-EpicCrossGitExe -GitArgs`; adapter tests mock only these wrappers with matching parameter names, assert the exact argument arrays (including `--json number,headRefName,mergeCommit,files` for the feature snapshot), and prove that an adapter failure or an ancestry exit other than 0 or 1 yields `hold` with the `UNVERIFIABLE` reason; verified by `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1`.
- [ ] `Invoke-EpicCrossReadinessCommand` honors the CLI contract (exit codes 0, 1, 2; `-WaitSeconds` default 0 and range 0 to 540; compressed JSON output) and the bounded wait polls through the injected `Wait-EpicCrossInterval` and `Get-EpicCrossUtcNow` seams, returning at the first release or at the bound; tests assert the number of injected sleeps and perform no real sleep; verified by `tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1`.
- [ ] `EpicCrossDependency.psm1` and `Invoke-EpicCrossReadiness.ps1` each reach at least 85% line coverage in the Pester coverage report, and the PoshQC format, analyzer, and parallel test gates pass with a clean leak scan.

Issue AC3: on release the orchestrator merges the other epic's integration branch into its own (direct merge commit) before starting the feature.

- [ ] `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` (`## Wave Scheduling`) prescribe, for a feature with cross-epic edges, the launch-time CLI call, no worktree while held, and on `merge_required` the D4 sequence (fetch, ancestry check, `git merge --no-ff` of the other integration branch, conflict handling as in main sync, push, re-fetch, record) before launch, and state that the merge is never a rebase or fast-forward; `PREREQ_IN_MAIN` makes no extra merge; verified by `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1`.
- [ ] `.claude/agents/epic-orchestrator.md` carries the Bash grant for the `Invoke-EpicCrossReadiness.ps1` invocation, `.codex/agents/epic-orchestrator.toml` states the same procedure, and `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` and `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` pass.
- [ ] The started-while-held invariant yields the exact `EPIC_CROSS_DEPENDENCY_VIOLATION:` string for a started feature whose cross-epic entry is not `integrated` or `in_main`, and no error when every entry is `integrated` or `in_main`, in the Python, TypeScript, and PowerShell implementations; `Get-OrchestratorStateEpicWaveBarrierError` appends the PowerShell result and fails closed when the module cannot be imported; verified by `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Parity.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1`, `tests/scripts/dev_tools/test_epic_cross_dependency_parity_corpus.py`, and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts`.
- [ ] The epic checkpoint hold records (D7) are documented in `## Epic-Level Checkpoint` and accepted by the validators with the documented field types and `status` enum, and the D10 upstream-context line is documented in the epic-orchestrate skill and, with `not merged`, in `.claude/skills/epic-plan/SKILL.md`; verified by `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1` and `tests/scripts/dev_tools/test_epic_cross_dependency_validation.py`.

Issue AC4: the epic-progress-report critical path includes cross-epic edges.

- [ ] `Get-EpicProgressReport.CrossEpic.ps1` builds external nodes from checkpoint rows and from the raw manifest value, with the D9 identity, state, and duration rules including the `external (default)` label for an unreadable plan or missing kickoff; verified by `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1`.
- [ ] `Invoke-EpicProgressListSchedule` excludes nodes with `External` from the cap: a cap-1 schedule with one pending external node and one local node starts the local node at time 0, and a schedule without external nodes is byte-identical to the pre-change result; a pending external prerequisite lengthens the critical chain of its dependent; verified by `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Schedule.Tests.ps1` and `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CriticalPath.Tests.ps1`.
- [ ] The critical chain prints an external node as the epic slug, `#`, and the issue number without a leading `#`; the Full report shows the `Cross-epic:` line only when an edge exists; the TL;DR lines keep their shapes; a report for an epic without edges is byte-identical to the pre-change output; verified by `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.CriticalPath.Tests.ps1` and `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1`.
- [ ] `.claude/skills/epic-progress-report/SKILL.md` documents the cross-epic calculation rule, and `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` pins it; the new part file reaches at least 85% line coverage.

Issue AC5: the integration-to-main PR is held until the prerequisite epic's integration-to-main PR has merged.

- [ ] `.claude/skills/epic-orchestrate/SKILL.md` (before step 6 of `## Epic Integration Branch Lifecycle`, and `## Completion Requirements`) and `.claude/agents/epic-orchestrator.md` (`## Completion Requirements`) prescribe the `-Mode main` check before opening the integration-to-main PR, the main sync on release before opening it, the re-check immediately before `gh pr merge`, the `cross_epic_main_gate` record, the D8 bounded wait for the main hold, and the D5 disclosure that the merge-gate hook does not read `cross_epic_main_gate`; verified by `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1`.
- [ ] Under `require_complete`, the Python and TypeScript epic orchestrator validators return `EPIC_CROSS_DEPENDENCY_MAIN_GATE_INCOMPLETE:` for a checkpoint whose features carry `cross_epic_depends_on` but whose `cross_epic_main_gate` is absent, `held`, or missing a verified entry for a prerequisite epic, and no error when it is `released` with complete entries; a checkpoint without the key is unaffected; verified by `tests/scripts/dev_tools/test_epic_cross_dependency_validation.py` and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts`.

Issue AC6: epic-plan, epic-orchestrate, epic-progress-report skills and agents updated.

- [ ] `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/epic-run/SKILL.md`, `.claude/agents/epic-planner.md` (`## Checkpoint Persistence` field list), `.agents/skills/epic-plan/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, and `.codex/agents/epic-planner.toml` describe the cross-epic key, its planner-checkpoint copy, and the preparation-mode handoff line, in sections added alongside existing text; verified by `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1`.
- [ ] Every Claude bundle copy, Codex stored copy, codex-and-agents bundle copy, and pack-manifest entry listed in Files in Scope matches its source; the push-down resource, pack-manifest completeness, dependency-closure, and virtual-path contract tests, the Codex generator `--check`, and `claude-pack-manifest-completeness.test.ts` pass.
- [ ] After the final merge of `origin/main`, the digest entries for `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` equal the SHA-256 of the final file bytes, carry a `# RE-BASELINED by issue #1162.` paragraph, and `test_frozen_epic_surface_matches_pinned_baseline_digest` passes.
- [ ] Every existing contract test named in Files in Scope passes, and no hook file and no hook registration is added or changed by this item.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria
- [ ] Tests added and updated (Pester, pytest, Jest), all run parallel-only
- [ ] Edge cases and error handling covered by tests
- [ ] Skills, agents, templates, and mirrors updated
- [ ] Toolchain pass completed for PowerShell, Python, and TypeScript
