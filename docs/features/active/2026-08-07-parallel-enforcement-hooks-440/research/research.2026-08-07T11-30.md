# Research: parallel-enforcement-hooks (F7, Issue #440)

- Date: 2026-08-07T11-30
- Epic: `parallel-orchestration`, child F7
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited below as §N)
- Epic narrative: `docs/features/epics/parallel-orchestration/epic.md`
- Promoted issue: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/issue.md`
- Spec: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md`

## Current State Analysis

### Upstream constraint — verified

The following upstream artifacts do not exist on disk in this worktree (verified by glob against
the workspace root):

- `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3) — absent. A glob of
  `scripts/dev_tools/*parallel*` returns no files.
- `.claude/agents/parallel-orchestrator.md` (F5) — absent. A glob of `.claude/agents/parallel*`
  returns no files.
- `.claude/skills/parallel-orchestrate/SKILL.md` (F5) — absent. A glob of
  `.claude/skills/parallel*/SKILL.md` returns no files.
- No `docs/features/active/*parallel-schema-validators*` or `*parallel-orchestrator-surface*`
  folder exists; the only `parallel*` folder under `docs/features/active/` is this feature's own
  `2026-08-07-parallel-enforcement-hooks-440/`.

The stated integration-branch commit (`5a0becb0`) could not be independently verified: this
research session has no shell tool, and the environment git snapshot (taken at session start)
reports branch `main` at `060747bd`. The on-disk state is, however, fully consistent with the
stated constraint: the epic scaffold (`epic.md`, design doc, F7 feature folder) is present and no
wave-0-through-3 deliverable exists. All upstream contracts below are therefore cited from the
design document, not from upstream files. The atomic plan must include a Phase 0
upstream-verification task (see `## Upstream Contract Assumptions`).

### Structural precedents (read in full)

**`.claude/hooks/enforce-epic-wave-barrier.ps1`** (305 lines) — the Layer 1 precedent. Structure:

- Script-scoped constants: `$script:EpicCheckpointPath =
  'artifacts/orchestration/epic-orchestrator-state.json'`, `$script:AllowedMergeStatuses =
  @('merged', 'worktree_removed')`, `$script:EpicModeMarker = 'Epic mode: true'` (lines 36-38).
- Read seam: `Get-EpicWaveBarrierCheckpointContent` returns raw checkpoint text or `$null`; tests
  mock this function so no temp files are needed (lines 40-56).
- Target resolution: `Find-EpicWaveBarrierFeatureFolderFromPrompt` regex-scans the prompt for
  `docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+` tokens, normalizes separators, takes the
  longest unique match, strips a `.md` suffix to its parent directory, and returns the basename
  (lines 58-105).
- Record lookup: `Find-EpicWaveBarrierFeatureRecord` scans `features[]` for
  `feature_folder == basename` (lines 107-146).
- Decision: `Test-EpicWaveBarrierDependenciesMerged` returns `$true` only when every
  `depends_on` entry resolves to a record whose `merge_status` is in `$script:AllowedMergeStatuses`;
  a missing record or missing `merge_status` returns `$false` (lines 148-200). Absent/empty
  `depends_on` returns `$true`.
- Decision shape: `[ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse';
  permissionDecision = 'allow' } }` for allow; deny adds `permissionDecision = 'deny'` and
  `permissionDecisionReason = $Reason` (lines 202-230).
- Entry: `Invoke-EpicWaveBarrierDecision -ToolInputRaw <json>` — empty payload allows; malformed
  JSON throws (entrypoint exits 1); non-`orchestrator` `subagent_type` allows; prompt without the
  marker allows; unresolvable feature folder denies; then reads/parses the checkpoint (parse
  failure yields `$null` checkpoint, which the decision function treats as deny) (lines 232-288).
- Dot-source test guard: `if ($MyInvocation.InvocationName -eq '.') { return }` (line 291).
- Entrypoint: reads `$env:CLAUDE_TOOL_INPUT`, `Write-Error` + `exit 1` on throw, else emits the
  decision as `ConvertTo-Json -Compress -Depth 5` and `exit 0` (lines 295-304).

**`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`** (238 lines) — the removal-gate
precedent. Registered on the `Bash` matcher. Intercepts commands matching
`(?i)\bgit\s+worktree\s+remove\b`; extracts the path via
`(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)` with quote trimming; normalizes separators for
Windows/POSIX equality; finds the `features[]` record by `worktree_path`; allows only when
`merge_status` is in `@('merged', 'worktree_removed')`; denies with
`EPIC_WORKTREE_REMOVAL_BLOCKED: ...` otherwise (unreadable checkpoint, no matching record, or
non-terminal status — fail-closed). Same read seam, decision shape, dot-source guard, and
entrypoint pattern as the wave barrier.

**`.claude/hooks/enforce-epic-invocation-origin.ps1`** (247 lines) — the ONE file this feature
extends. Registered on the `Agent` matcher. Key structures:

- `$script:GatedSubagentTypes = @('epic-planner', 'epic-orchestrator')` (line 36) and
  `$script:ProhibitedCallerAgentType = 'orchestrator'` (line 37).
- Caller identity: `CLAUDE_HOOK_INPUT` carries top-level `agent_type` only inside a subagent
  context; absent/blank `agent_type` marks a main-thread call, which allows.
- Target resolution: `subagent_type` from `CLAUDE_TOOL_INPUT`, with a lazy fallback to the hook
  payload's `tool_input` object; the hook payload is not parsed at all for non-gated targets
  (asserted by an existing test that passes malformed `CLAUDE_HOOK_INPUT` with a non-epic target).
- Reason string (line 228), currently epic-specific prose: `"EPIC_INVOCATION_ORIGIN_BLOCKED:
  Agent($target) must not be invoked from an orchestrator agent. Both epic-planner and
  epic-orchestrator delegate to Agent(orchestrator), so an orchestrator-originated invocation
  would nest orchestrator inside its own delegation chain. Invoke $target from the main session
  instead."`

**Pester tests** — locations and pattern:

- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1`

Pattern: `#Requires -Version 7.0`, Pester 5; `BeforeAll` resolves the hook path relative to
`$PSScriptRoot` and dot-sources it (the dot-source guard prevents entrypoint execution); tests
call the `Invoke-*Decision` function directly with `-ToolInputRaw` / `-HookInputRaw` string
parameters (no environment variables needed); checkpoint content is injected with
`Mock -CommandName Get-*CheckpointContent -MockWith { '<json literal>' }`; assertions inspect
`$decision.hookSpecificOutput.permissionDecision` and `-Match` the reason token. Malformed
tool-input JSON is asserted to throw.

**Layer 2 precedent — `scripts/dev_tools/validate_epic_orchestrator_state.py`** (493 lines).
`validate_epic_orchestrator_state_text(text, *, require_complete=False, ...)` parses JSON,
returns a list of error strings, never mutates input. Invariants are small private
`_validate_*` functions each returning `list[str]`; the entry function `errors.extend(...)`s them
in order. Key-gated backward compatibility: optional blocks (for example
`codex_model_routing_receipts`, `intent`) are validated only when their key is present. Helper
modules split out per concern: `scripts/dev_tools/_epic_orchestrator_state_resolution.py`,
`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, and the shared
`scripts/dev_tools/_orchestrator_state_*.py` family. The existing wave-barrier ordering
invariant `_validate_wave_barrier_ordering` (lines 243-307) is the direct model for F7's Layer 2:
for every feature with `depends_on`, each resolved dependency must have `merge_status` in
`{"merged", "worktree_removed"}`; additionally, when both `dep.merge_confirmed_at` and
`feature.worktree_created_at` are strings, `dep_confirmed_at > worktree_created_at` is a timing
violation. Each violated edge appends exactly one literal-prefixed message:
`f"EPIC_WAVE_BARRIER_VIOLATION: {folder} started before dependency {dependency} merged"`.

**SubagentStop consumption** — `.claude/hooks/validate-orchestrator-output.ps1` is a
parameterized hook (`-CheckpointPath`, `-ArtifactType`). Its `Invoke-RoutingContractValidation`
invokes `python -m scripts.dev_tools.validate_orchestration_artifacts <ArtifactType>
<CheckpointPath> --require-complete --require-model-routing 2>&1` through an injectable
`Invoker` scriptblock seam; a non-zero exit code is the sole failure discriminator, and the
captured error text is surfaced as the block reason (`ROUTING_CONTRACT_BLOCKED:` /
`MODEL_ROUTING_BLOCKED:`). The epic surface reuses this hook rather than a new file: in
`.claude/settings.json` the `SubagentStop` matcher `epic-orchestrator` runs
`validate-orchestrator-output.ps1 -CheckpointPath
artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state`.
The CLI dispatch lives in `scripts/dev_tools/validate_orchestration_artifacts.py` (subparser
`epic-orchestrator-state` at line 223, dispatch at line 300); F3 owns adding a
`parallel-orchestrator-state` subparser.

**`.claude/settings.json` registrations** (verified):

- `PreToolUse` / matcher `Bash` (lines 90-118): six `pwsh -NoProfile -File` hook entries,
  including `enforce-epic-worktree-removal-gate.ps1`. The parallel removal gate registers here.
- `PreToolUse` / matcher `Agent` (lines 165-189): five entries, including
  `enforce-epic-wave-barrier.ps1` and `enforce-epic-invocation-origin.ps1`. The parallel cohort
  barrier registers here. The invocation-origin hook is already registered, so its extension
  needs no settings change.
- `SubagentStop` (lines 191-249): a broad artifact-presence matcher plus per-agent matchers;
  the `epic-orchestrator` matcher shows the exact parameterized registration form the
  `parallel-orchestrator` matcher must copy.

## Q1. Layer 1 hook design (`enforce-parallel-cohort-barrier.ps1`)

Decision procedure, adapted from the wave barrier with the dependency lookup replaced by a
conflict-edge lookup:

1. **Activation gate.** Parse `CLAUDE_TOOL_INPUT`. Empty payload → allow. Malformed JSON →
   throw (entrypoint exits 1). `subagent_type != 'orchestrator'` → allow. Prompt not containing
   the literal marker `Parallel mode: true` (script constant, matched with
   `-like "*$script:ParallelModeMarker*"`, mirroring the epic marker check) → allow. §9 states
   the hook "fires when `subagent_type == "orchestrator"` and the prompt carries the marker
   `Parallel mode: true`". The design does not fix a position in the prompt; the epic precedent
   matches the marker anywhere in the prompt text, and F5 owns emitting it (see Upstream
   Contract Assumptions).
2. **Target item resolution.** Reuse the prompt-scanning technique verbatim: regex
   `docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+`, longest unique match, `.md` resolves to
   parent, return the basename. §12 gives `items[]` a `feature_folder` field, so the basename
   matches an `items[]` record the same way the epic hook matches `features[]`. Unresolvable →
   deny with `PARALLEL_COHORT_BARRIER_BLOCKED` (mirrors the epic behavior of denying before the
   checkpoint read).
3. **Checkpoint read.** Read `artifacts/orchestration/parallel-orchestrator-state.json` through
   a mockable `Get-ParallelCohortBarrierCheckpointContent` read seam. Missing file or
   unparseable JSON → `$null` checkpoint → deny (fail-closed).
4. **Cohort membership.** Resolve the target item's key (its `issue_num`; the record also
   carries `feature_folder`, so a folder-hint key form in `cohorts[].item_keys` /
   `conflict_edges[]` should also be tolerated, following the epic union-index precedent in
   `_epic_orchestrator_state_resolution.build_feature_reference_index`). Find the target's
   cohort index: the `cohorts[]` entry whose `item_keys[]` contains the target key. Because
   `cohorts[]` entries carry `generation` (§12) and recoloring appends traceable generations
   (§8.6), consider only cohort rows whose `generation == recolor_generation` (the current
   coloring); an item absent from every current-generation cohort row → deny (fail-closed).
5. **Conflicting prior-cohort enumeration.** For every `conflict_edges[]` entry `{a, b, reason}`
   incident to the target key, take the neighbor key. Look up the neighbor's cohort index in the
   current generation. If the neighbor's cohort index is strictly less than the target's, the
   neighbor is a "conflicting item in a prior cohort" and must have `merge_status` in
   `@('merged', 'worktree_removed')` (§9 names exactly these two values). A neighbor with no
   `items[]` record, no cohort assignment, or any other `merge_status` (`not_started`,
   `worktree_created`, `pr_open`, `ci_green`, `blocked_drift`, `blocked_ci_loop_limit`) → deny.
   `ci_green` does not satisfy the barrier: §6 requires cohort `N+1` to branch from `main` only
   after every cohort-`N` item **has merged**, and §9 lists only `merged` and `worktree_removed`.
6. **Decision emission.** Same ordered-dictionary shape, dot-source guard, `CLAUDE_TOOL_INPUT`
   entrypoint, `ConvertTo-Json -Compress -Depth 5`, `exit 0` / `exit 1` as the epic hook.

Same-cohort neighbors and later-cohort neighbors do not block Layer 1: items within a cohort are
non-conflicting by construction (§6), so a same-cohort conflict edge is a scheduling defect that
Layer 2 reports retrospectively; Layer 1's job is only the prior-cohort barrier.

## Q2. Layer 1 fail-closed semantics

Epic wave-barrier behavior (verified in code and tests): out-of-scope calls (empty payload,
non-orchestrator target, no marker) **allow**; once in scope, everything unresolvable **denies** —
unresolvable feature folder, absent checkpoint file, malformed checkpoint JSON, missing
dependency record, missing `merge_status`. Malformed `CLAUDE_TOOL_INPUT` itself throws → exit 1.

Recommendation: adopt these semantics unchanged for the parallel hook.

- Missing checkpoint → deny. Rationale: a `Parallel mode: true` delegation can only legitimately
  originate from a `parallel-orchestrator` that has already written its checkpoint; an absent
  checkpoint means the concurrency guarantee cannot be verified. Epic.md Shared Design item 7
  ("Fail closed. The contention relation must never assume safety it has not proven") extends
  naturally: the barrier must never assume safety it cannot verify.
- Malformed checkpoint → deny (parse failure produces a `$null` checkpoint object, same as the
  epic hook's swallow-and-null pattern at its checkpoint-parse site).
- Unresolvable target item (no path token in prompt, or no matching `items[]` record, or no
  current-generation cohort assignment) → deny with a reason that instructs the caller to include
  the feature folder path in the prompt (mirroring the epic reason text).
- Out-of-scope calls must still allow: the hook runs on every `Agent` call in the session,
  including non-parallel work; failing closed on out-of-scope traffic would break the rest of the
  runtime. This is the same scope/deny split the epic hook implements.

## Q3. Layer 2 invariant (cohort-ordering, retrospective)

Mandated message (§9, byte-exact): `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with
conflicting <b>`.

Available fields (§12): `cohorts[]` = `{index, generation, item_keys[]}`; `conflict_edges[]` =
`{a, b, reason}`; `items[]` carry `merge_status` and "lifecycle timestamps" (field names not
fixed by the design). `current_cohort` and `recolor_generation` are top-level.

"Ran concurrently" — three candidate mechanical readings:

1. **Cohort-index equality only.** A conflict edge whose endpoints share a cohort index in the
   current generation. Detects scheduling defects (a non-independent set was colored as a
   cohort) but misses execution-order violations across cohorts, which are the failure mode the
   barrier exists for.
2. **Lifecycle-timestamp overlap only.** For an edge `{a, b}` where `a` is in an earlier cohort:
   `b` started before `a` durably merged. Detects execution violations but silently accepts a
   structurally invalid coloring when timestamps are missing.
3. **Both (recommended).** An edge `{a, b}` violates the invariant when either:
   - **Structural:** both endpoints appear in the same current-generation cohort (`index`
     equality). Conflicting items scheduled into one cohort ran (or would run) concurrently by
     construction; or
   - **Temporal:** with `a` in a strictly earlier current-generation cohort than `b`, `b` has
     started (its start timestamp is non-null, or its `merge_status` has left `not_started`)
     while `a.merge_status` is not in `{merged, worktree_removed}`, or — when both timestamps
     are present as strings — `a`'s merge-confirmation timestamp is chronologically greater than
     `b`'s start timestamp (ISO-8601 string comparison, exactly as
     `_validate_wave_barrier_ordering` compares `merge_confirmed_at > worktree_created_at`).

Reading 3 is the most defensible: it is the union of what the checkpoint can prove, it degrades
gracefully when timestamps are absent (the status check still fires, matching the epic
precedent's `status_violation OR timing_violation` structure), and each violated edge appends
exactly one mandated message with `<a>` the earlier/first endpoint and `<b>` the other.

**What F3's schema must supply** for the temporal check: per-item start and merge-confirmation
timestamps with stable names. The epic precedent uses `worktree_created_at` and
`merge_confirmed_at`; §12 says only "lifecycle timestamps". This is the single most important
field-name assumption to verify in Phase 0 (see Upstream Contract Assumptions). If F3 lands
different names, only the two field-name constants in F7's helper change.

Backward-compatibility pattern: the invariant must be key-gated in the established style — it
runs only when `conflict_edges` (and `cohorts`) are present, appends one error per violated
edge, and returns `list[str]` without mutating input.

## Q4. Why both layers are required (non-negotiable)

A `PreToolUse` hook is invoked once per tool call with only that call's payload
(`CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT`). It has no visibility into sibling calls issued in
the same assistant turn, no conversation state, and no memory across invocations. A
`parallel-orchestrator` fanning out a cohort issues a batch of concurrent `Agent(orchestrator)`
calls; no single per-call hook can observe the batch as a set, so Layer 1 can only verify each
call independently against the durable checkpoint (§9: "no single `PreToolUse` hook can validate
a batch of concurrent `Agent` calls, because hooks fire per call with no cross-call state
visibility"). Conversely, the `SubagentStop` validator sees the whole recorded history in the
checkpoint but only after execution. Layer 1 deters per call in real time; Layer 2 proves the
batch retrospectively and blocks completion. Neither subsumes the other; downstream agents must
not collapse them.

## Q5. Wave-4 contention (F6/F8 concurrency)

F6 (`parallel-mutation-protocol`) and F8 (`parallel-drift-detection`) run concurrently with F7
and all three extend `.claude/skills/parallel-orchestrate/SKILL.md` and
`validate_parallel_orchestrator_state.py` (epic.md, "Wave-4 Contention Note").

Recommended distinct section/claim names for F7:

- In `.claude/skills/parallel-orchestrate/SKILL.md`: one new appended section titled
  `## Cohort Barrier Enforcement (F7)`. F5 is expected to reserve named placeholder sections;
  since F5 has not landed, the exact placeholder names are unverifiable — Phase 0 must check
  whether F5 reserved a section for F7 and use the reserved name if one exists, otherwise append
  the section above.
- In `validate_parallel_orchestrator_state.py`: do not add invariant logic inline. Add a new
  helper module `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (mirroring
  the `_epic_orchestrator_state_*.py` / `_orchestrator_state_*.py` split pattern) and confine
  the shared-file edit to two lines: one import and one
  `errors.extend(validate_cohort_barrier_ordering(state_map))` call, placed at the end of the
  existing `errors.extend(...)` sequence. This minimizes merge surface against F6 and F8, which
  will each add their own import + extend call.

No-reflow / no-reorder rule (decomposition constraint, epic.md): F7's edits to both shared files
are append-only within its named section/insertion point; F7 must not reflow, reorder, reformat,
or touch any existing section or any section added by F6/F8.

Schema confirmation: F3 owns the complete checkpoint schema including `conflict_edges[]`
(epic.md Wave-4 Contention Note names `mutations[]`, `drift_events[]`, and `conflict_edges[]` as
F3-owned). F7's Layer 2 invariant validates over existing fields only — `cohorts[]`,
`conflict_edges[]`, `items[].merge_status`, and the F3-defined lifecycle timestamps — and adds
**no** schema fields.

## Q6. Scope boundary

Confirmed from epic.md:

- Decomposition Rationale: "§10's F7 is split into enforcement hooks (F7) and radius-drift
  detection (F8)... F7 is cohort-ordering and lifecycle gating, F8 is diff-versus-declared-radius
  comparison and requeue logic." F8's per-feature scope explicitly "[i]ncludes the drift gate
  that blocks a child's transition to review while an unresolved drift event exists."
- "The abandon gate from §9 is assigned to F6 rather than F7, because it enforces the
  `--disposition abandon` contract that F6 defines."

F7 must not implement the drift gate (F8) or the abandon gate (F6). The spec's Constraints
section repeats this. Any drift- or abandon-related logic appearing in an F7 plan is a scope
violation.

## Q7. Toolchain and testing

PowerShell (per `.claude/rules/powershell.md`):

- Format: `mcp__drm-copilot__run_poshqc_format`
- Analyze: `mcp__drm-copilot__run_poshqc_analyze` (autofix available)
- Test: `mcp__drm-copilot__run_poshqc_test` (Pester 5.x, repo config
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)
- Order: format → analyze → test; restart on any failure or file change. PowerShell 7+.

Python (per `.claude/rules/python.md`):

- `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` →
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`; restart on failure/change.

Mirrored test file paths (per `.claude/rules/general-unit-test.md`, tests mirror production
structure under `tests/`; existing hook tests live in `tests/scripts/claude-hooks/`):

| Production file | Test file |
| --- | --- |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (new) | `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` (new) |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (new) | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` (new) |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` (extended) | `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (extended; existing tests must pass unmodified) |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (new) + two-line edit to `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py` (new; exercises the invariant through `validate_parallel_orchestrator_state_text`, avoiding contention with F3's/F6's/F8's test files) |

Test technique for the PowerShell hooks (established pattern, verified in
`tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1` and
`enforce-epic-invocation-origin.Tests.ps1`): `BeforeAll` dot-sources the hook (the
`$MyInvocation.InvocationName -eq '.'` guard suppresses the entrypoint); tests call the
`Invoke-*Decision` function directly with raw-JSON string parameters (`-ToolInputRaw`,
`-HookInputRaw`) — no `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT` environment setup is required;
checkpoint content is injected via `Mock -CommandName Get-*CheckpointContent`; no temp files.

Coverage thresholds: line >= 85%, branch >= 75%, uniform across tiers; coverage regression on
changed lines is blocking.

## Q8. Change budget

`.claude/rules/powershell.md` caps a batch at 3 production PowerShell files and 3 test files
(enforced by `.claude/hooks/enforce-powershell-batch-budget.ps1`). F7's PowerShell surface is
exactly 3 production files (2 new hooks + 1 extended hook) and 3 test files (2 new + 1 extended)
— it fits a single batch at the cap, with zero headroom. The Python change (1 new helper module,
1 two-line edit, 1 new test file) is outside the PowerShell cap; `.claude/settings.json` and
`SKILL.md` edits are JSON/Markdown and uncounted.

Recommended phase split for the plan (isolation preferred over one at-cap batch):

- **Phase 0 — upstream verification.** Assert existence and shape of every item in
  `## Upstream Contract Assumptions` (F3 validator + checkpoint field names; F5 skill/agent +
  marker + reserved sections; `parallel-orchestrator-state` CLI subparser).
- **Phase 1 — new hooks batch (2 prod PS + 2 test files).** `enforce-parallel-cohort-barrier.ps1`
  and `enforce-parallel-worktree-removal-gate.ps1` with their Tests.ps1 files; full PS toolchain.
- **Phase 2 — invocation-origin extension (1 prod PS + 1 test file).** Additive change with the
  byte-compatibility constraint isolated in its own batch so its regression surface is clean.
- **Phase 3 — Layer 2 Python.** Helper module + two-line validator edit + pytest file; full
  Python toolchain.
- **Phase 4 — wiring.** `.claude/settings.json` registrations and the `SKILL.md` section.

Phases 1 and 2 could merge into one 3/3 batch if the plan prefers fewer phases; both options are
policy-compliant.

## Invocation-origin extension — minimal additive design

Two changes only:

1. `$script:GatedSubagentTypes = @('epic-planner', 'epic-orchestrator', 'parallel-planner',
   'parallel-orchestrator')`.
2. Reason-string selection. The current reason hardcodes "Both epic-planner and
   epic-orchestrator delegate to Agent(orchestrator)". To preserve epic behavior
   byte-compatibly (the spec's stated requirement), keep the existing epic reason string
   literally unchanged for epic targets and add a parallel-family variant selected by target
   prefix, for example: `"EPIC_INVOCATION_ORIGIN_BLOCKED: Agent($target) must not be invoked
   from an orchestrator agent. Both parallel-planner and parallel-orchestrator delegate to
   Agent(orchestrator), so an orchestrator-originated invocation would nest orchestrator inside
   its own delegation chain. Invoke $target from the main session instead."` The reason-code
   prefix for parallel targets is not fixed by the design; retaining
   `EPIC_INVOCATION_ORIGIN_BLOCKED` versus introducing `PARALLEL_INVOCATION_ORIGIN_BLOCKED` is a
   plan decision — recommendation: introduce `PARALLEL_INVOCATION_ORIGIN_BLOCKED` for parallel
   targets so log triage distinguishes the surfaces, while the epic branch stays byte-identical.
   (§9 mandates no reason literal for this gate, unlike the two barrier literals.)

All existing tests in `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` must
pass unmodified; new `Context` blocks cover: parallel targets denied from `orchestrator`,
allowed from main thread and from non-orchestrator agents, and the non-gated-target
malformed-hook-payload no-parse behavior still holding.

## Recommended Implementation Shape

Files to create:

- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` — Layer 1; near-verbatim adaptation of
  `enforce-epic-wave-barrier.ps1` with `depends_on` lookup replaced by conflict-edge +
  cohort-index logic (Q1); constants `$script:ParallelCheckpointPath =
  'artifacts/orchestration/parallel-orchestrator-state.json'`, `$script:AllowedMergeStatuses =
  @('merged', 'worktree_removed')`, `$script:ParallelModeMarker = 'Parallel mode: true'`; deny
  reason prefixed `PARALLEL_COHORT_BARRIER_BLOCKED`.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` — near-verbatim adaptation of
  `enforce-epic-worktree-removal-gate.ps1`: same `git worktree remove` regexes, checkpoint path
  swapped to the parallel checkpoint, records matched by `items[].worktree_path`, terminal
  states `@('merged', 'worktree_removed')`, deny reason prefixed
  `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.
- `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` — `validate_cohort_barrier_ordering(state) -> list[str]`
  implementing the Q3 invariant, key-gated, emitting the mandated
  `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` message.
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`
- `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`

Files to modify:

- `.claude/hooks/enforce-epic-invocation-origin.ps1` — additive extension (two changes above).
- `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` — new contexts only.
- `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned, lands in wave 1) —
  one import + one `errors.extend(...)` call, appended, no reflow.
- `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned, lands in wave 3) — one appended
  section `## Cohort Barrier Enforcement (F7)` (or F5's reserved placeholder name if present).
- `.claude/settings.json` — three registrations:
  1. `PreToolUse` / matcher `Agent`: append
     `pwsh -NoProfile -File .claude/hooks/enforce-parallel-cohort-barrier.ps1`.
  2. `PreToolUse` / matcher `Bash`: append
     `pwsh -NoProfile -File .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
  3. `SubagentStop` / matcher `parallel-orchestrator`:
     `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath
     artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType
     parallel-orchestrator-state` — contingent on F3's CLI subparser and on F5 not having
     already registered it (Phase 0 check; if F5 registered it, F7 makes no SubagentStop change).

Files explicitly NOT modified: `enforce-epic-wave-barrier.ps1`,
`enforce-epic-worktree-removal-gate.ps1`, `enforce-epic-merge-gate.ps1` (additive-only
constraint; the merge gate has no parallel counterpart per §4).

### Rejected alternatives

- **Refactoring the epic hooks into a shared parameterized module** consumed by both surfaces —
  rejected by the epic itself (Non-Goals: "Reuse is by near-verbatim adaptation into new files,
  not by refactoring the epic implementations into a shared abstraction") and by the
  additive-only constraint in the issue.
- **A new dedicated `parallel-invocation-origin.ps1` hook** instead of extending the epic one —
  rejected: §9 explicitly says "Extend `.claude/hooks/enforce-epic-invocation-origin.ps1`", and a
  second hook would duplicate the caller-identity resolution while doubling the Agent-matcher
  hook count for no isolation benefit.
- **Inline Layer 2 logic in `validate_parallel_orchestrator_state.py`** — rejected in favor of a
  helper module to keep the wave-4 shared-file merge surface at two lines (see Q5) and to follow
  the established `_orchestrator_state_*` helper split.

## Behavior Semantics

- Layer 1 success: allow decision emitted for (a) all out-of-scope calls and (b) in-scope calls
  whose every conflicting prior-cohort neighbor is `merged`/`worktree_removed`.
- Layer 1 failure: deny with `PARALLEL_COHORT_BARRIER_BLOCKED: ...` for an in-scope call with an
  unmerged conflicting prior-cohort neighbor, an unresolvable target, or an
  absent/malformed checkpoint. Malformed `CLAUDE_TOOL_INPUT` → exit 1.
- Layer 2: zero errors when no conflict edge violates the Q3 invariant; one
  `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` per violated
  edge; checkpoints without `conflict_edges`/`cohorts` produce no new errors (key-gated).
- Removal gate: allow only for `merged`/`worktree_removed`; deny (fail-closed) otherwise,
  including unreadable checkpoint and no-match; non-`git worktree remove` commands always allow.
- Invocation origin: parallel personas denied only from `agent_type == 'orchestrator'`;
  main-thread and non-orchestrator-agent invocations allow; epic decisions and epic deny reason
  text unchanged.

## Testing Implications

- Pester, per hook: allow paths (empty payload, out-of-scope target, missing marker /
  non-matching command), deny paths (each fail-closed branch and the substantive block), and
  malformed-JSON throw; checkpoint injected through the mocked read seam; assertions on
  `permissionDecision` and reason-prefix `-Match`. For the invocation-origin extension, assert
  the epic deny reason remains byte-identical (exact `-Be` on the reason string for an epic
  target is the strongest available regression guard) alongside the existing regex tests.
- Pytest: table of checkpoint fixtures as inline JSON strings passed to
  `validate_parallel_orchestrator_state_text` — no key (backward compat, zero errors);
  same-cohort conflicting pair; cross-cohort started-early pair (status violation); timestamp
  violation; clean multi-cohort run; missing-timestamp degradation to status-only; one message
  per violated edge with exact literal.
- No temp files, no network, no live executables; determinism per `general-unit-test.md`.

## Upstream Contract Assumptions

Every field name, enum value, and literal this feature depends on, with owner and citation.
Phase 0 of the atomic plan must verify each against the landed upstream artifacts before
implementation.

| # | Assumption | Owner | Citation |
| --- | --- | --- | --- |
| U1 | Checkpoint path `artifacts/orchestration/parallel-orchestrator-state.json` | F3 | design §3, §12 |
| U2 | `cohorts[]` entries shaped `{index, generation, item_keys[]}` | F3 | design §12 |
| U3 | `conflict_edges[]` entries shaped `{a, b, reason}`; `a`/`b` are item keys | F3 | design §12 |
| U4 | `items[]` entries carry `issue_num`, `feature_folder`, `worktree_path`, `merge_status`, and lifecycle timestamps | F3 | design §12 |
| U5 | `merge_status` enum: `not_started, worktree_created, pr_open, ci_green, merged, worktree_removed, blocked_drift, blocked_ci_loop_limit` | F3 | design §12 |
| U6 | Barrier-satisfying statuses are exactly `merged` and `worktree_removed` | F3 (schema) / design | design §9, §8.7 |
| U7 | `issue_num` is the item primary key; `feature_folder` is a resolvable hint | F3 | design §11 |
| U8 | Top-level `recolor_generation` identifies the current coloring; `cohorts[].generation` ties rows to it | F3 | design §12, §8.6 |
| U9 | Lifecycle timestamp field names for item start and merge confirmation (epic precedent: `worktree_created_at`, `merge_confirmed_at`; §12 says only "lifecycle timestamps") — **names unverifiable until F3 lands** | F3 | design §12; epic precedent `validate_epic_orchestrator_state.py` lines 281-301 |
| U10 | `validate_parallel_orchestrator_state.py` exposes `validate_parallel_orchestrator_state_text(text, *, ...) -> list[str]` in the established validator style | F3 | design §10 F3; epic precedent |
| U11 | `validate_orchestration_artifacts` CLI gains a `parallel-orchestrator-state` artifact type | F3 | design §10 F3 (MCP `artifact_type` wiring); epic precedent `validate_orchestration_artifacts.py` lines 223, 300 |
| U12 | Kickoff marker literal `Parallel mode: true` present in the serialized child delegation prompt | F5 | design §9 |
| U13 | The child delegation prompt references the target item's `docs/features/active/<folder>` path (required for prompt-based item resolution) | F5 | epic precedent (wave-barrier prompt resolution); design §9 "resolves the target item" |
| U14 | `.claude/skills/parallel-orchestrate/SKILL.md` exists with reserved named placeholder sections for wave-4 children | F5 | epic.md Wave-4 Contention Note |
| U15 | Agent names `parallel-orchestrator` and `parallel-planner` (exact `subagent_type` strings) | F5/F4 | design §3 |
| U16 | Whether F5 already registered the `parallel-orchestrator` `SubagentStop` matcher in `.claude/settings.json` | F5 | epic precedent registration (settings.json `epic-orchestrator` matcher) |

No upstream contract beyond the design document has been invented; U9, U13, U14, and U16 are the
assumptions the design leaves under-specified and are flagged accordingly.

## Autonomous-Execution Assessment

A full `## Automation Feasibility` section is **not applicable**: this feature touches only
repository-local PowerShell hooks, a Python validator helper, Markdown, and JSON settings. No
third-party UI, external service, credential issuance, or manual environment step is involved.
All verification (toolchain, Pester, Pytest, coverage) runs locally via MCP/poetry commands. No
step requiring a human was identified. The only conditional dependency — upstream F3/F5
artifacts — is resolved mechanically by epic wave ordering (F7 executes in wave 4, after waves
0-3 merge) plus the Phase 0 verification task.

## Risks and Open Questions

1. **U9 timestamp field names.** The temporal half of the Layer 2 invariant and the strongest
   reading of "ran concurrently" depend on F3's lifecycle-timestamp names. Mitigation: isolate
   the names as module constants in the helper; Phase 0 verifies; if F3 supplies no per-item
   start/confirm timestamps at all, the invariant degrades to structural + status checks and the
   plan must record the reduced strength.
2. **Cohort-generation ambiguity.** §12 permits multiple `cohorts[]` generations. The
   recommendation (filter to `generation == recolor_generation`) is the deterministic reading
   consistent with §8.6 auditability, but F3's validator may define a different authoritative
   projection. Phase 0 must confirm.
3. **F5 placeholder section names unknown** (U14). If F5 reserves a differently named section
   for F7, use it verbatim; the appended-section fallback exists only if no placeholder landed.
4. **SubagentStop registration ownership** (U16). If F5 lands the `parallel-orchestrator`
   matcher itself, F7 drops that settings change; if not, F7 adds it, since §9 places
   `SubagentStop`-time enforcement in F7's scope. The plan should branch on the Phase 0 finding.
5. **Reason-code prefix for parallel invocation-origin denials.** The design fixes no literal;
   this research recommends `PARALLEL_INVOCATION_ORIGIN_BLOCKED` for the parallel branch with
   the epic branch byte-identical. The planner should confirm and freeze the literal.
6. **PowerShell batch at cap.** 3 production + 3 test files is exactly the per-batch limit; any
   scope growth (for example a shared helper script) forces a batch split. The recommended
   phase split (Q8) pre-empts this.
7. **Commit-hash verification gap.** The `5a0becb0` integration-branch position was confirmed
   only indirectly (on-disk artifact presence/absence); the executor should re-verify with
   `git log` at execution time as part of Phase 0.
