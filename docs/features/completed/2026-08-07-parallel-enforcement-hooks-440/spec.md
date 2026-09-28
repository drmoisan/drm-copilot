# 2026-08-07-parallel-enforcement-hooks — Spec

- **Issue:** #440
- **Parent (optional):** Epic `parallel-orchestration`, child F7
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07
- **Status:** Draft
- **Version:** 1.0

Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited as
§N). Research artifact:
`docs/features/active/2026-08-07-parallel-enforcement-hooks-440/research/research.2026-08-07T11-30.md`.
Epic narrative: `docs/features/epics/parallel-orchestration/epic.md`.

## Overview

The `parallel` orchestration surface schedules unrelated items into cohorts derived from a
computed blast-radius conflict relation (§5.4, §6). Cohort `N+1` may branch from `main` only
after every conflicting cohort-`N` item has merged. Without mechanical enforcement, that
ordering rule is advisory only: a `parallel-orchestrator` could fan out a conflicting item early
and silently invalidate the concurrency guarantee the whole design rests on.

The same gap exists for two lifecycle transitions. A worktree removed before its item reached a
terminal merge state destroys in-flight work. An `Agent(parallel-orchestrator)` or
`Agent(parallel-planner)` call originating from `orchestrator` would nest `orchestrator` inside
its own delegation chain, because both parallel agents delegate to `Agent(orchestrator)`.

The epic surface already solved the structurally identical problems with proven hooks
(`enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
`enforce-epic-invocation-origin.ps1`). This feature adapts that precedent to the `parallel`
surface per §9, excluding the drift gate (F8) and the abandon gate (F6).

## Behavior

Deliver the two-layer cohort barrier plus two lifecycle gates.

### Layer 1 — per-call deterrent (`enforce-parallel-cohort-barrier.ps1`)

A new `PreToolUse` hook `.claude/hooks/enforce-parallel-cohort-barrier.ps1` on the `Agent`
matcher, adapted near-verbatim from `.claude/hooks/enforce-epic-wave-barrier.ps1` with the
`depends_on` lookup replaced by conflict-edge plus cohort-index logic. Decision procedure:

1. **Activation gate.** Parse `CLAUDE_TOOL_INPUT`. Empty payload allows. Malformed JSON throws
   (entrypoint exits 1). `subagent_type != 'orchestrator'` allows. A prompt not containing the
   literal marker `Parallel mode: true` (script constant, matched anywhere in the prompt text,
   mirroring the epic marker check) allows.
2. **Target item resolution.** Reuse the epic prompt-scanning technique: regex-scan the prompt
   for `docs/features/active/<folder>` path tokens, take the longest unique match, resolve a
   `.md` suffix to its parent directory, and return the basename. The basename matches an
   `items[]` record by `feature_folder`. An unresolvable target denies with
   `PARALLEL_COHORT_BARRIER_BLOCKED` and a reason instructing the caller to include the feature
   folder path in the prompt.
3. **Checkpoint read.** Read `artifacts/orchestration/parallel-orchestrator-state.json` through
   a mockable `Get-ParallelCohortBarrierCheckpointContent` read seam. A missing file or
   unparseable JSON yields a null checkpoint, which denies (fail-closed).
4. **Cohort membership.** Resolve the target item's key (`issue_num` primary key; tolerate a
   `feature_folder` hint form in `cohorts[].item_keys` / `conflict_edges[]`, following the epic
   union-index precedent). Consider only `cohorts[]` rows whose `generation ==
   recolor_generation` (the current coloring). A target absent from every current-generation
   cohort row denies (fail-closed).
5. **Conflicting prior-cohort enumeration.** For every `conflict_edges[]` entry `{a, b, reason}`
   incident to the target key, resolve the neighbor's current-generation cohort index. If the
   neighbor's cohort index is strictly less than the target's, the neighbor must have
   `merge_status` in `('merged', 'worktree_removed')`. A neighbor with no `items[]` record, no
   cohort assignment, or any other `merge_status` — including `ci_green` — denies with
   `PARALLEL_COHORT_BARRIER_BLOCKED`. `ci_green` does not satisfy the barrier: §6 requires
   cohort `N+1` to branch only after every cohort-`N` item has merged, and §9 lists only
   `merged` and `worktree_removed`.
6. **Decision emission.** Same ordered-dictionary `hookSpecificOutput` shape, dot-source test
   guard, `CLAUDE_TOOL_INPUT` entrypoint, compressed-JSON emission, and exit-code convention as
   the epic hook.

Same-cohort and later-cohort neighbors do not block Layer 1: items within a cohort are
non-conflicting by construction (§6), so a same-cohort conflict edge is a scheduling defect that
Layer 2 reports retrospectively.

### Layer 2 — retrospective backstop (cohort-ordering invariant)

A cohort-ordering invariant inside `validate_parallel_orchestrator_state_text`, enforced at
`parallel-orchestrator` `SubagentStop` time. The invariant logic lives in a new helper module
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` exposing
`validate_cohort_barrier_ordering(state) -> list[str]`; the edit to F3-owned
`scripts/dev_tools/validate_parallel_orchestrator_state.py` is confined to one import and one
`errors.extend(...)` call appended to the existing extend sequence.

A conflict edge `{a, b}` violates the invariant when either:

- **Structural:** both endpoints appear in the same current-generation cohort (`index`
  equality). Conflicting items scheduled into one cohort run concurrently by construction; or
- **Temporal:** with `a` in a strictly earlier current-generation cohort than `b`, `b` has
  started (its start timestamp is non-null, or its `merge_status` has left `not_started`) while
  `a.merge_status` is not in `{merged, worktree_removed}`, or — when both timestamps are
  present as strings — `a`'s merge-confirmation timestamp is chronologically greater than `b`'s
  start timestamp (ISO-8601 string comparison, matching the epic
  `_validate_wave_barrier_ordering` precedent).

Each violated edge appends exactly one message using the §9 byte-exact literal form
`PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`, with `<a>` the
earlier/first endpoint. The invariant is key-gated: it runs only when `conflict_edges` (and
`cohorts`) are present, degrades to structural-plus-status checks when timestamps are absent,
returns `list[str]`, and never mutates its input. Timestamp field names are isolated as module
constants pending Phase 0 verification of F3's landed schema (assumption U9 below).

### Worktree removal gate (`enforce-parallel-worktree-removal-gate.ps1`)

A new `PreToolUse` hook `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` on the `Bash`
matcher, adapted near-verbatim from `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: same
`git worktree remove` interception regexes and path normalization; checkpoint path swapped to
`artifacts/orchestration/parallel-orchestrator-state.json`; record matched by
`items[].worktree_path`; allow only when `merge_status` is in `('merged', 'worktree_removed')`;
deny with reason prefixed `PARALLEL_WORKTREE_REMOVAL_BLOCKED` otherwise, including an unreadable
checkpoint or no matching record (fail-closed). Commands that are not `git worktree remove`
always allow.

### Invocation origin (extension of `enforce-epic-invocation-origin.ps1`)

Extend the existing `.claude/hooks/enforce-epic-invocation-origin.ps1` additively — two changes
only:

1. Add `parallel-planner` and `parallel-orchestrator` to `$script:GatedSubagentTypes`.
2. Add a parallel-family deny reason variant selected by target. The recommended reason-code
   prefix for parallel targets is `PARALLEL_INVOCATION_ORIGIN_BLOCKED` (the design fixes no
   literal for this gate; the planner freezes the literal). The existing epic deny reason
   string, including the `EPIC_INVOCATION_ORIGIN_BLOCKED` prefix and its prose, remains
   byte-identical for epic targets.

Main-thread invocations (absent/blank caller `agent_type`) and non-orchestrator-agent callers
continue to allow. The existing behavior of not parsing the hook payload for non-gated targets
is preserved.

## Design Constraints (non-negotiable)

1. **Both layers are required; neither alone closes the gap.** A `PreToolUse` hook is invoked
   once per tool call with only that call's payload. It has no visibility into sibling calls
   issued in the same assistant turn, no conversation state, and no memory across invocations,
   so no single `PreToolUse` hook can validate a batch of concurrent `Agent` calls (§9). Layer 1
   deters per call in real time against the durable checkpoint; Layer 2 proves the batch
   retrospectively and blocks completion. Neither subsumes the other. Downstream agents must not
   propose collapsing the two layers into one mechanism.
2. **The barrier is over the conflict relation, not a dependency graph.** An item is blocked by
   conflicting items in prior cohorts, derived from `conflict_edges[]` and cohort indices — not
   by declared upstream features. There is no `depends_on` field anywhere in the parallel
   surface (§11; epic.md Shared Design item 2).
3. **The surface is named `parallel` throughout** — skills, agents, hook filenames, validator
   module names, checkpoint filenames, and reason strings (epic.md Shared Design item 1).
4. **`.claude/hooks/enforce-epic-invocation-origin.ps1` is the one existing file this feature
   extends rather than duplicates** (§9). The epic behavior must remain byte-compatible: the
   existing `EPIC_INVOCATION_ORIGIN_BLOCKED` deny reason string is unchanged for epic targets,
   and all pre-existing tests in
   `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` pass unmodified. The
   parallel personas are added additively.
5. **Additive only otherwise.** Do not modify or refactor
   `.claude/hooks/enforce-epic-wave-barrier.ps1` or
   `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`. Reuse is by near-verbatim adaptation
   into new files, not by generalizing the epic implementations (epic.md Non-Goals).
6. **Fail closed.** Per epic.md Shared Design item 7, the enforcement must never assume safety
   it has not proven. Once a call is in scope, every unresolvable condition — missing
   checkpoint, malformed checkpoint JSON, unresolvable target item, missing record, missing
   `merge_status` — denies. Out-of-scope calls (empty payload, non-`orchestrator` target,
   missing marker, non-matching command) allow, because these hooks run on all session traffic.

## Non-Goals

- **The drift gate** — blocking a child's transition to review while an unresolved
  `drift_events[]` entry exists — belongs to F8 `parallel-drift-detection` (epic.md
  Decomposition Rationale). Any drift-related logic in this feature is a scope violation.
- **The abandon gate** — denying `--disposition abandon` without an explicit confirmation
  marker — belongs to F6 `parallel-mutation-protocol` (epic.md Decomposition Rationale).
- **No parallel merge gate.** `enforce-epic-merge-gate.ps1` has no parallel counterpart; each
  parallel item PRs to `main` independently (§4; epic.md Non-Goals).
- **No refactoring of epic hooks into a shared abstraction** (epic.md Non-Goals).

## Wave-4 Contention Constraint

F7 executes in wave 4 concurrently with F6 (`parallel-mutation-protocol`) and F8
(`parallel-drift-detection`). All three extend `.claude/skills/parallel-orchestrate/SKILL.md`
and, to a lesser degree, `scripts/dev_tools/validate_parallel_orchestrator_state.py` (epic.md
Wave-4 Contention Note). The following rules are mandatory:

- F7's edit to `.claude/skills/parallel-orchestrate/SKILL.md` is confined to one distinct,
  explicitly named appended section titled `## Cohort Barrier Enforcement (F7)`. F5 is expected
  to have reserved named placeholder sections for wave-4 children; if F5 reserved a section for
  F7, use that reserved name verbatim instead (Phase 0 verification, assumption U14).
- F7's edit to `scripts/dev_tools/validate_parallel_orchestrator_state.py` is confined to two
  lines: one import of `_parallel_orchestrator_state_cohort_barrier` and one
  `errors.extend(validate_cohort_barrier_ordering(state_map))` call appended at the end of the
  existing extend sequence. All invariant logic lives in the new helper module.
- F7 must NOT reflow, reorder, reformat, or otherwise touch existing sections of either
  contended file, nor any section added by F6 or F8.
- F3 owns the complete checkpoint schema, including `conflict_edges[]`. F7's Layer 2 invariant
  adds validation logic over existing fields only — `cohorts[]`, `conflict_edges[]`,
  `items[].merge_status`, and the F3-defined lifecycle timestamps — and adds NO schema fields.
- F7's Python test file is `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`,
  a file F3/F6/F8 do not own, avoiding test-file contention.

## Upstream Contract Assumptions

Waves 0–3 had not landed at authoring time; the integration branch was at the scaffold commit.
Every upstream field name, enum value, and literal this feature depends on is listed below,
tagged by owner with design-document citations. The atomic plan must include a Phase 0
upstream-verification task that asserts each assumption against the landed upstream artifacts
before implementation. U9, U13, U14, and U16 are the assumptions the design leaves
under-specified.

| # | Assumption | Owner | Citation |
| --- | --- | --- | --- |
| U1 | Checkpoint path `artifacts/orchestration/parallel-orchestrator-state.json` | F3 | §3, §12 |
| U2 | `cohorts[]` entries shaped `{index, generation, item_keys[]}` | F3 | §12 |
| U3 | `conflict_edges[]` entries shaped `{a, b, reason}`; `a`/`b` are item keys | F3 | §12 |
| U4 | `items[]` entries carry `issue_num`, `feature_folder`, `worktree_path`, `merge_status`, and lifecycle timestamps | F3 | §12 |
| U5 | `merge_status` enum: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`, `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit` | F3 | §12 |
| U6 | Barrier-satisfying statuses are exactly `merged` and `worktree_removed` | F3 (schema) / design | §9, §8.7 |
| U7 | `issue_num` is the item primary key; `feature_folder` is a resolvable hint | F3 | §11 |
| U8 | Top-level `recolor_generation` identifies the current coloring; `cohorts[].generation` ties rows to it | F3 | §12, §8.6 |
| U9 | Lifecycle timestamp field names for item start and merge confirmation (epic precedent: `worktree_created_at`, `merge_confirmed_at`; §12 says only "lifecycle timestamps") — names unverifiable until F3 lands | F3 | §12; epic precedent `validate_epic_orchestrator_state.py` |
| U10 | `validate_parallel_orchestrator_state.py` exposes `validate_parallel_orchestrator_state_text(text, *, ...) -> list[str]` in the established validator style | F3 | §10 F3; epic precedent |
| U11 | `validate_orchestration_artifacts` CLI gains a `parallel-orchestrator-state` artifact type | F3 | §10 F3; epic precedent `validate_orchestration_artifacts.py` |
| U12 | Kickoff marker literal `Parallel mode: true` present in the serialized child delegation prompt | F5 | §9 |
| U13 | The child delegation prompt references the target item's `docs/features/active/<folder>` path (required for prompt-based item resolution) | F5 | §9; epic wave-barrier precedent |
| U14 | `.claude/skills/parallel-orchestrate/SKILL.md` exists with reserved named placeholder sections for wave-4 children | F5 | epic.md Wave-4 Contention Note |
| U15 | Agent names `parallel-orchestrator` and `parallel-planner` (exact `subagent_type` strings) | F5/F4 | §3 |
| U16 | Whether F5 already registered the `parallel-orchestrator` `SubagentStop` matcher in `.claude/settings.json` | F5 | epic precedent (`epic-orchestrator` matcher registration) |

## Inputs / Outputs

- Inputs:
  - `CLAUDE_TOOL_INPUT` environment variable (serialized tool-call payload) for all three
    `PreToolUse` hooks; `CLAUDE_HOOK_INPUT` for caller-identity resolution in the
    invocation-origin hook.
  - `artifacts/orchestration/parallel-orchestrator-state.json` (F3-owned checkpoint), read by
    the cohort barrier and the removal gate through mockable read seams.
- Outputs:
  - Per-call hook decisions: compressed-JSON `hookSpecificOutput` objects with
    `permissionDecision` `allow` or `deny` and, on deny, `permissionDecisionReason` prefixed
    `PARALLEL_COHORT_BARRIER_BLOCKED`, `PARALLEL_WORKTREE_REMOVAL_BLOCKED`,
    `PARALLEL_INVOCATION_ORIGIN_BLOCKED`, or (epic targets, unchanged)
    `EPIC_INVOCATION_ORIGIN_BLOCKED`.
  - Layer 2 validator error strings, one per violated conflict edge, in the form
    `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`, surfaced at
    `SubagentStop` by `.claude/hooks/validate-orchestrator-output.ps1`.
- Config keys and defaults: none introduced. Hook registrations in `.claude/settings.json` (see
  Implementation Strategy).
- Versioning / backward compatibility: the Layer 2 invariant is key-gated — a checkpoint
  lacking `conflict_edges`/`cohorts` validates exactly as before with zero new errors. The
  invocation-origin extension preserves epic decisions and the epic deny reason string
  byte-identically.

## API / CLI Surface

- No new CLI commands. New public PowerShell functions follow the established hook pattern:
  `Invoke-ParallelCohortBarrierDecision -ToolInputRaw <json>` and
  `Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw <json>` (exact names per epic
  precedent naming), each callable directly by tests without environment variables.
- New Python function: `validate_cohort_barrier_ordering(state) -> list[str]` in
  `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`, consumed by
  `validate_parallel_orchestrator_state_text`.
- Contract and validation rules: reason-string literals as specified in Behavior; the §9
  Layer 2 message literal is byte-exact.

## Data & State

- No schema changes. The feature reads F3's checkpoint fields (`cohorts[]`, `conflict_edges[]`,
  `items[]`, `recolor_generation`, `current_cohort`) and writes nothing to the checkpoint.
- Invariant over the data: for every conflict edge, endpoints must not share a
  current-generation cohort, and a later-cohort endpoint must not start before every
  earlier-cohort conflicting endpoint is `merged` or `worktree_removed`.
- No caching, persistence, migration, or backfill.

## Constraints & Risks

- **Wave-4 contention.** See `## Wave-4 Contention Constraint`. This is a decomposition
  constraint, not a suggestion.
- **Upstream ownership.** F3 owns the complete checkpoint schema; Layer 2 adds validation logic
  over existing fields and adds no schema fields. F5 owns the `Parallel mode: true` kickoff
  marker Layer 1 matches on and the child prompt content Layer 1 resolves.
- **U9 timestamp field names.** The temporal half of the Layer 2 invariant depends on F3's
  lifecycle-timestamp names. Mitigation: isolate the names as module constants; Phase 0
  verifies; if F3 supplies no per-item start/confirm timestamps, the invariant degrades to
  structural-plus-status checks and the plan records the reduced strength.
- **Cohort-generation projection.** The recommended reading filters `cohorts[]` to
  `generation == recolor_generation`; Phase 0 must confirm F3's authoritative projection.
- **PowerShell batch at cap.** The PowerShell surface is exactly 3 production files and 3 test
  files — the per-batch limit in `.claude/rules/powershell.md` with zero headroom. The
  recommended phase split (Implementation Strategy) pre-empts this; any scope growth forces a
  batch split.
- **SubagentStop registration ownership (U16).** If F5 already landed the
  `parallel-orchestrator` matcher, F7 makes no `SubagentStop` settings change; otherwise F7
  adds it. The plan branches on the Phase 0 finding.
- **Additive only.** The epic barrier and removal-gate hooks must not be modified or refactored.
- **Out of scope.** The drift gate belongs to F8; the abandon gate belongs to F6.

## Implementation Strategy

- Files to create:
  - `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (Layer 1; constants
    `$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'`,
    `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')`,
    `$script:ParallelModeMarker = 'Parallel mode: true'`).
  - `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
  - `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`.
  - `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`.
  - `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`.
  - `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`.
- Files to modify:
  - `.claude/hooks/enforce-epic-invocation-origin.ps1` (additive extension, two changes).
  - `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (new contexts only;
    existing tests unmodified).
  - `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned; one import plus one
    `errors.extend(...)` call, appended, no reflow).
  - `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned; one appended section
    `## Cohort Barrier Enforcement (F7)` or F5's reserved placeholder name if present).
  - `.claude/settings.json`: append the cohort barrier under `PreToolUse`/`Agent`; append the
    removal gate under `PreToolUse`/`Bash`; add a `SubagentStop` matcher `parallel-orchestrator`
    running `validate-orchestrator-output.ps1 -CheckpointPath
    artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType
    parallel-orchestrator-state`, contingent on F3's CLI subparser and on F5 not having already
    registered it (Phase 0 check). The invocation-origin hook is already registered under
    `PreToolUse`/`Agent`; its extension needs no settings change.
- Files explicitly NOT modified: `.claude/hooks/enforce-epic-wave-barrier.ps1`,
  `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`,
  `.claude/hooks/enforce-epic-merge-gate.ps1`.
- Dependency changes: none.
- Logging/telemetry: hook deny reasons are the observable output; no new logging framework.
- Recommended phase split (research Q8): Phase 0 upstream verification of all assumptions U1–U16;
  Phase 1 new hooks batch (2 production PS + 2 test files); Phase 2 invocation-origin extension
  (1 production PS + 1 test file, isolating the byte-compatibility regression surface); Phase 3
  Layer 2 Python (helper module + two-line validator edit + pytest file); Phase 4 wiring
  (`.claude/settings.json`, `SKILL.md` section).
- Toolchain: PowerShell format → analyze → test via the PoshQC MCP tools; Python
  `poetry run black .` → `ruff check .` → `pyright` →
  `pytest --cov --cov-branch --cov-report=term-missing`; restart on any failure or file change.

## Acceptance Criteria

- [x] Layer 1 hook `.claude/hooks/enforce-parallel-cohort-barrier.ps1` denies an in-scope `Agent(orchestrator)` delegation whose target item has a conflicting item in a strictly prior current-generation cohort with a non-terminal `merge_status`, with a deny reason carrying the exact literal `PARALLEL_COHORT_BARRIER_BLOCKED` (Pester evidence).
- [x] Layer 1 hook allows an in-scope delegation whose every conflicting prior-cohort item has `merge_status` `merged` or `worktree_removed`, and allows an item with no conflicting prior-cohort neighbors (Pester evidence).
- [x] Layer 1 hook allows a delegation whose serialized prompt lacks the literal marker `Parallel mode: true` (Pester evidence).
- [x] Layer 1 hook allows a delegation whose `subagent_type` is not `orchestrator` (Pester evidence).
- [x] Layer 1 hook fails closed — denies with `PARALLEL_COHORT_BARRIER_BLOCKED` — when the parallel checkpoint file is missing or its JSON is malformed (Pester evidence).
- [x] Layer 1 hook fails closed — denies — when the target item is unresolvable: no feature-folder path token in the prompt, no matching `items[]` record, or no current-generation cohort assignment (Pester evidence).
- [x] A conflicting prior-cohort item in `ci_green` does not satisfy the barrier: Layer 1 denies; only `merged` and `worktree_removed` satisfy it (Pester evidence).
- [x] Layer 2 invariant, exercised through `validate_parallel_orchestrator_state_text`, appends exactly one message per violated conflict edge in the exact form `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`, covering both the structural (same-cohort) and temporal (started-before-merged) violation readings (pytest evidence).
- [x] Layer 2 invariant is key-gated: a checkpoint lacking the `conflict_edges` / `cohorts` keys validates exactly as before with zero new errors, and a clean multi-cohort checkpoint produces zero barrier errors (pytest evidence).
- [x] Worktree removal gate `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denies a `git worktree remove` command for an item whose `merge_status` is non-terminal, and fails closed for an unreadable checkpoint or an unmatched worktree path, with the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason prefix (Pester evidence).
- [x] Worktree removal gate allows `git worktree remove` for an item whose `merge_status` is `merged` or `worktree_removed`, and allows commands that are not `git worktree remove` unconditionally (Pester evidence).
- [x] Extended `.claude/hooks/enforce-epic-invocation-origin.ps1` denies both `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` calls originating from caller `agent_type` `orchestrator`, and allows the same targets from the main thread and from non-orchestrator agents (Pester evidence).
- [x] Epic invocation-origin behavior is preserved unchanged: the existing `EPIC_INVOCATION_ORIGIN_BLOCKED` deny reason string is byte-identical for epic targets (exact-string assertion) and all pre-existing tests in `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` pass unmodified (Pester evidence).
- [x] `.claude/settings.json` registers `enforce-parallel-cohort-barrier.ps1` under `PreToolUse` matcher `Agent`, `enforce-parallel-worktree-removal-gate.ps1` under `PreToolUse` matcher `Bash`, and — unless the Phase 0 check finds F5 already registered it — a `SubagentStop` matcher `parallel-orchestrator` invoking `validate-orchestrator-output.ps1` with the parallel checkpoint path and artifact type.
- [x] Line coverage >= 85% and branch coverage >= 75% for all new and changed code, with no coverage regression on changed lines.
- [x] All test files are mirrored under `tests/` per `.claude/rules/general-unit-test.md` (`tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/dev_tools/test_*.py`), use mocked read seams instead of temp files, and are deterministic.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage for allow/deny decision paths in each hook (Pester)
- [ ] Unit coverage for the Layer 2 cohort-ordering invariant (Pytest)
- [ ] Malformed and absent payload handling for each hook
- [ ] Backward compatibility of the extended invocation-origin hook for epic targets
