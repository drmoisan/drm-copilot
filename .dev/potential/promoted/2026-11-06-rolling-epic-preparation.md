# rolling-epic-preparation (Issue #1088)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/rolling-epic-preparation/ (Issue #1088)

- Issue: #1088
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1088
- Last Updated: 2026-11-06
## Problem / Why

Rolling (wave-lagged) preparation for epic orchestration.

Let an epic run with only its first waves prepared up front. The epic orchestrator then prepares later waves itself while earlier waves execute: when every feature in wave N is confirmed merged into the integration branch, it starts preparation-mode runs for the features in wave N + `preparation_lead_waves` (default 2), concurrently with execution of wave N+1.

Motivating case: a 35-feature, 15-wave epic in iar-migration. Preparing every feature up front is expensive, and plans for later waves would cite functions and files that earlier waves have not created yet, so preflight cannot check them against the code and they go stale. Planning each feature at launch avoids staleness but serializes preparation and execution. Rolling preparation gets most of the freshness and keeps them overlapped.

### Current state (verified in the pushed-down copy in iar-migration; confirm against canonical sources)

- `epic-orchestrator` may already delegate `Agent(orchestrator)`. A preparation run is an `Agent(orchestrator)` call carrying the preparation-mode kickoff line defined in `.claude/skills/epic-plan/SKILL.md` (`## Preparation-Mode Child Delegation`).
- The preparation kickoff line deliberately omits `Epic mode: true`, so `.claude/hooks/enforce-epic-wave-barrier.ps1` (Layer 1) does not gate it.
- `.claude/hooks/enforce-epic-invocation-origin.ps1` blocks only `orchestrator` → {epic-planner, epic-orchestrator, parallel-planner, parallel-orchestrator}. It does not block epic-orchestrator → orchestrator.
- The steps for merging prepared outputs into the integration branch (merge the child branch, back-fill `issue_num`/`feature_folder`, update `preparation_status`/`plan_path`/`preflight_status`, remove the worktree) are defined only in `epic-plan/SKILL.md` (`## Fan-In to the Integration Branch`).
- Child orchestrators can adopt pre-existing issues through `issue_adoption` with `origin: epic_decomposition`.
- **The blocker:** the Layer-2 wave-barrier backstop (`validate_epic_orchestrator_state_text`, the PowerShell port `Get-OrchestratorStateEpicWaveBarrierError` in `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, the TS port, and the fixtures under `tests/fixtures/epic_wave_barrier/`) treats any `features[]` entry with a string `worktree_created_at`, or a `merge_status` other than `not_started`, as started. A preparation worktree recorded in `features[]` for a wave-N+2 feature would therefore raise `EPIC_WAVE_BARRIER_VIOLATION` while wave N+1 is unmerged.
- The `epic-plan` kickoff artifact template states "All child features are prepared". `epic-orchestrator.md` `## Prepared-Epic Execution` assumes every child folder carries a plan and a preflight clearance.

## Proposed Behavior

### 1. epic-plan skill and the epic-planner agent

- Accept a preparation scope: a list or range of waves to prepare now. The rest are issue-only.
- Open issues for every feature, including issue-only ones: write a potential entry, then call `potential_to_issue`. Back-fill `issue_num` into the manifest.
- Kickoff artifact: give each feature's preparation status (`prepared` | `issue_only`) instead of the blanket "All child features are prepared". Record `preparation_lead_waves` and `max_parallel_preparations`.

### 2. epic-orchestrate skill and the epic-orchestrator agent

- New section `## Rolling Preparation`. Once wave N's merges are durably confirmed (same evidence the wave barrier uses), launch preparation-mode `Agent(orchestrator)` runs (`isolation: "worktree"`, `run_in_background: true`, branched from `origin/<integration_branch>`) for every `issue_only` feature in wave N + `preparation_lead_waves`. Include upstream context lines citing merged upstream specs and plans.
- Move the fan-in steps out of `epic-plan` into a shared location (shared skill section or library doc) used by both `epic-plan` and `epic-orchestrate`. Do not duplicate them.
- The epic orchestrator is the only writer to the integration branch. It serializes preparation fan-in merges with execution PR merges.
- Concurrency: preparation runs are capped by `max_parallel_preparations`, separately from `max_parallel_features`, unless you find a reason they must share one cap. Document the choice.
- Bootstrap: at kickoff, also prepare any `issue_only` features in waves ≤ `preparation_lead_waves` - 1 that `epic-plan` did not prepare.
- Update `## Prepared-Epic Execution` for a mixed manifest of prepared and issue-only features.

### 3. Epic checkpoint shape (`artifacts/orchestration/epic-orchestrator-state.json`)

- Track preparation outside the fields the wave barrier reads. Preferred: a top-level `preparations[]` array keyed by `issue_num` with `{ issue_num, feature_folder, wave, preparation_status (not_started|in_progress|prepared|failed), plan_path, preflight_status, worktree_path, branch_name, started_at, fanned_in_at, prepared_against_sha }`. `prepared_against_sha` is the integration-branch SHA the preparation ran against.
- Validator changes, in Python (authority), TypeScript and PowerShell with byte-identical error strings and a shared fixture corpus:
  - Shape and enum checks for `preparations[]`, presence-gated so existing checkpoints validate unchanged.
  - Invariant: a `features[]` entry treated as started requires a `preparations[]` entry for the same `issue_num` with `preparation_status: prepared` and a non-empty `plan_path`, or evidence that the feature was prepared by `epic-plan` (from the kickoff artifact or the planner checkpoint). Choose the evidence source and document it.
  - Invariant: a preparation for a feature in wave W must not start before every feature in wave W - `preparation_lead_waves` is merged (the lagged barrier for preparation).
- The Layer-2 wave-barrier backstop must keep ignoring `preparations[]`.

### 4. Execution launch gate

- Extend `enforce-epic-wave-barrier.ps1`, or add a sibling hook, to deny an `Epic mode: true` execution delegation for a feature that is not prepared. Use a new deny reason, e.g. `EPIC_FEATURE_NOT_PREPARED`.

### 5. Re-preflight at execution launch

- A feature prepared against an older integration-branch SHA must re-run atomic-executor preflight against the current tip before execution. Add this to the epic-mode kickoff line, or as an extra kickoff line, citing `prepared_against_sha`.
- On a substantive preflight failure, use the existing plan-revision path (plan back to atomic-planner once, then halt per the single-pass preflight rule) before executing.

### 6. Docs and push-down

- Update `epic-run`, any epic-planner state validator affected by the new kickoff fields, and the routing docs if `route_id: preparation` needs to accept issue adoption from an epic-orchestrator caller.
- Push down to consumer repos with the existing push-down tooling.

## Acceptance Criteria (early draft)

- [ ] An epic planned with waves 0–1 prepared and waves 2+ issue-only runs to completion. Preparation of wave N+2 starts only after wave N is confirmed merged, and runs concurrently with wave N+1 execution.
- [ ] No `EPIC_WAVE_BARRIER_VIOLATION` is raised by preparation activity. Starting execution of an unprepared feature is denied by a hook and by the Layer-2 validator.
- [ ] A feature whose plan has gone stale against the current integration tip is re-preflighted and, when needed, revised before execution. Covered by a test.
- [ ] Existing fully prepared epics validate and run with byte-identical behavior: no new errors on existing fixtures.
- [ ] Python, TypeScript and PowerShell validator parity is pinned by a shared fixture corpus that includes the new invariants.
- [ ] No duplicated fan-in instructions across skills, so the canonical-location audit passes.

## Constraints & Risks

Out of scope:

- Changes to parallel-plan/parallel-orchestrate, except where shared fan-in text is factored out.
- Automatic re-planning of already-prepared features when upstream specs change, beyond the re-preflight in item 5.

The current-state notes above were verified in the pushed-down copy in iar-migration and must be confirmed against the canonical sources in this repository.

## Test Conditions to Consider

- [ ] Shared fixture corpus covering `preparations[]` shape and enum checks and both new invariants, run by the Python, TypeScript and PowerShell validators
- [ ] Existing epic checkpoints and `tests/fixtures/epic_wave_barrier/` fixtures validate with no new errors
- [ ] Layer-2 wave-barrier backstop ignores `preparations[]`
- [ ] Hook denies an `Epic mode: true` delegation for an unprepared feature with `EPIC_FEATURE_NOT_PREPARED`
- [ ] Stale-plan scenario: re-preflight against the current integration tip, with plan revision when needed

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/rolling-epic-preparation/` folder from the template
