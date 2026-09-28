# 2026-08-07-parallel-drift-detection - Plan

- **Issue:** #446
- **Parent (optional):** Epic `parallel-orchestration` (child F8, wave 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T11-11
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Spec:** `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md`
- **User Story:** `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`
- **Research:** `docs/features/active/2026-08-07-parallel-drift-detection-446/research/2026-08-07T12-15-parallel-drift-detection-research.md`
- **Design source:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited as §N)

## Required References

- General Coding Standards: `.claude/rules/general-code-change.md`
- General Unit Test Policy: `.claude/rules/general-unit-test.md`
- Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- PowerShell: `.claude/rules/powershell.md`

All work must comply with these policies; do not duplicate their content here.

## Acceptance-Criteria Sources (full-feature)

Per the `acceptance-criteria-tracking` skill, the acceptance-criteria sources for this
full-feature plan are the `## Acceptance Criteria` sections of `spec.md` and `user-story.md`
in the feature folder. The final-QC phase contains an explicit check-off task against both.

## Evidence Location (non-overridable)

All evidence artifacts produced by this plan resolve under
`docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/<kind>/` with kinds
`baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`,
`remediation-baseline/`. Paths under `artifacts/` are forbidden for evidence.
`<timestamp>` in artifact names means an ISO-8601 `yyyy-MM-ddTHH-mm` value captured at
execution time.

## Non-Negotiable Constraints (encoded into tasks below)

1. **Halt the later-started item, never the drifting item** (§7). No task in this plan halts
   the drifting item, and no task offers a configuration to invert the rule.
2. **Reuse the R1-R5 remediation loop unmodified.** No task authors a new remediation loop and
   no task modifies `.claude/skills/orchestrate/SKILL.md`. The synthetic Blocking finding is
   written into the child's own `remediation-inputs.<yyyy-MM-ddTHH-mm>.md` (flat form, feature
   folder root) containing the literal line `- Severity: Blocking`, matching the shape research
   §3.2 verified against the CI-failure and epic merge-conflict precedents.
3. **Wave-4 contention (mandatory).** F6 (`parallel-mutation-protocol`) and F7
   (`parallel-enforcement-hooks`) execute concurrently with F8 and also extend
   `.claude/skills/parallel-orchestrate/SKILL.md` and
   `scripts/dev_tools/validate_parallel_orchestrator_state.py`. Every F8 edit to those two
   files is confined to F8's distinct named surface: the single H2 section
   `## Radius Drift Detection and Drift Gate` in the SKILL.md (filling F5's reserved
   placeholder of that name if present, otherwise appended at the end), and F8's own helper
   module `scripts/dev_tools/_parallel_orchestrator_state_drift.py` reached by exactly one
   import line plus one key-gated dispatch call in the validator. No F8 task may reflow,
   reorder, or rewrite any existing section or line of either file. The
   `.claude/settings.json` registration is append-only: exactly one entry appended to the
   `Agent` matcher hook list, no reordering.
4. **F3 owns the checkpoint schema.** Tasks populate `drift_events[]`, `mutations[]`,
   `recolor_generation`, `conflict_edges[]`, and the `blocked_drift` `merge_status` value; no
   task adds schema fields to any of them.
5. **Single recolor seam shared with F6 (IC-6b).** The step-5 requeue routes through one
   narrow seam function that delegates to F6's recolor entry point (assumed
   `requeue_via_recolor(...)`), incrementing `recolor_generation` by one and appending exactly
   one `mutations[]` entry. No task implements a second recolor.
6. **Additive only.** No task modifies or refactors existing epic implementations. Epic prior
   art (`.claude/hooks/enforce-epic-wave-barrier.ps1`, the `_orchestrator_state_*.py` helper
   split, `epic_wave_computation.py`) is adapted near-verbatim into new `parallel`-named files.
7. **Upstream contracts are Assumed.** Research §2 verified (by worktree enumeration) that F1,
   F3, F5, and F6 artifacts do not exist on the integration branch at planning time (tip is the
   epic scaffold commit `5a0becb0`). Phase 1 reconciles all eight integration contracts
   (IC-1a, IC-1b, IC-3a, IC-3b, IC-5a, IC-5b, IC-6a, IC-6b) against the landed upstream
   artifacts before any production code is written, adopting real upstream names and recording
   deviations, with the fallbacks from research §8 encoded per task.
8. **Drift-gate interpretation (confirmed).** This plan adopts the research §5 drift-gate
   reading, resolving research §10 point 3: the Layer-1 hook denies a `feature-review`
   delegation only while the item's latest drift event is unresolved AND its synthetic finding
   has not yet been written (so R4 review is never deadlocked); the Layer-2 validator
   invariant forbids `merge_status` in `{pr_open, ci_green, merged, worktree_removed}` while
   unresolved. A drift event for item K is unresolved until a `resolved` entry for K with a
   later `at` is appended, which happens exactly when the consuming remediation cycle exits
   with `blocking_count == 0`.
9. **Determinism.** Timestamps entering the halt decision are function inputs; no pure
   function in `parallel_drift_detection.py` reads the wall clock or performs I/O.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Baseline Capture

- [x] [P0-T1] Read the policy files in this exact order — `CLAUDE.md`,
  `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
  `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`,
  `.claude/rules/powershell.md` — and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/phase0-instructions-read.md`
  containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: The artifact exists at the stated path with all three required fields and
    lists all six files in the stated order.
- [x] [P0-T2] Run `poetry run black --check .` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-format-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` states pass/fail
    and any files that would be reformatted.
- [x] [P0-T3] Run `poetry run ruff check .` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-lint-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and an error-count summary.
- [x] [P0-T4] Run `poetry run pyright` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-typecheck-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and an error-count summary.
- [x] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the
  repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-test-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` records the
    pass/fail counts and the numeric baseline line-coverage and branch-coverage percentages.
- [x] [P0-T6] Run `mcp__drm-copilot__run_poshqc_format` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-format-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; any pre-existing format drift is
    named in `Output Summary:`.
- [x] [P0-T7] Run `mcp__drm-copilot__run_poshqc_analyze` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-analyze-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and a finding-count summary.
- [x] [P0-T8] Run `mcp__drm-copilot__run_poshqc_test` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-test-baseline.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields, Pester pass/fail counts, and the
    numeric baseline line-coverage and branch-coverage percentages reported by the run.

### Phase 1 — Upstream Contract Reconciliation (IC-1a through IC-6b)

- [x] [P1-T1] Read F1's landed `spec.md` (under `docs/features/active/` or
  `docs/features/completed/`) and `scripts/dev_tools/compute_blast_radius.py`, and record in
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/other/upstream-contract-reconciliation.<timestamp>.md`
  the reconciled IC-1a contract (the real name and signature of F1's path-subsumption
  predicate) and the reconciled IC-1b contract (the real name and signature of F1's
  `conflicts(a, b)` relation), including its glob semantics. Fallbacks: if F1 exposes no
  reusable subsumption predicate, adopt `fnmatch.fnmatchcase` over forward-slash-normalized
  repo-relative paths (the `scripts/dev_tools/discovery/analyzer/inventory.py` precedent) and
  record the deviation; if the `conflicts(a, b)` relation is absent, do NOT reimplement it —
  record `Status: BLOCKED` in the reconciliation artifact with the reason (F1 is wave 0;
  absence indicates a broken branch state), continue executing the remaining tasks in plan
  order, leave unchecked and mark as unmet every downstream task whose acceptance condition
  depends on the missing contract (citing the BLOCKED entry), and escalate the BLOCKED state
  to `epic-orchestrator` in the completion report. Phase 7 final-QC command tasks remain
  unconditional and must still be executed and recorded.
  - Acceptance: The artifact exists and contains an IC-1a entry and an IC-1b entry, each with
    the adopted symbol name, source file path, and either `Deviation: none` or the recorded
    deviation/BLOCKED state.
- [x] [P1-T2] Read F3's landed `spec.md` and `scripts/dev_tools/validate_parallel_orchestrator_state.py`,
  and append to the same reconciliation artifact the reconciled IC-3a contract (the exact
  checkpoint field names for `drift_events[]`, the `items[]` start-of-execution timestamp
  field — `in_flight_at` if F3 defines one, otherwise `worktree_created_at` — `blocked_drift`
  in the `merge_status` enum, `recolor_generation`, `mutations[]`, and F3's `action` enum
  names for drift events if F3 enumerates one, adopting F3's names over the recommended
  `blocking_finding_raised` / `halted_later_started` / `resolved`) and the reconciled IC-3b
  contract (the validator's helper-import and dispatch pattern F8 must follow). Fallback: if
  either F3 artifact is absent, record `Status: BLOCKED` in the reconciliation artifact,
  continue executing the remaining tasks in plan order, leave unchecked and mark as unmet
  every downstream task whose acceptance condition depends on the missing schema, and
  escalate the BLOCKED state to `epic-orchestrator` in the completion report; F8 populates
  the schema and never defines it. Phase 7 final-QC command tasks remain unconditional and
  must still be executed and recorded.
  - Acceptance: The artifact contains an IC-3a entry and an IC-3b entry with adopted field
    names (including the start-timestamp field and the `action` enum) and either
    `Deviation: none` or the recorded deviation/BLOCKED state.
- [x] [P1-T3] Read F5's landed `.claude/skills/parallel-orchestrate/SKILL.md` and
  `.claude/agents/parallel-orchestrator.md`, and append to the same reconciliation artifact
  the reconciled IC-5a contract (the byte-exact `Parallel mode: true` kickoff marker line
  including the `parallel_checkpoint_path` element, which the Phase 5 hook constant must match
  byte-for-byte) and the reconciled IC-5b contract (whether a reserved placeholder section
  named `## Radius Drift Detection and Drift Gate` exists, and the `items[].worktree_path`
  field the parent uses to write the child's remediation-inputs file). Fallback: if no
  placeholder section exists, Phase 6 appends the named section at the end of the file without
  reflowing; record the choice.
  - Acceptance: The artifact contains an IC-5a entry quoting the marker line verbatim and an
    IC-5b entry recording placeholder presence/absence and the worktree-path field name.
- [x] [P1-T4] Determine whether F6's recolor entry point (assumed `requeue_via_recolor(...)`)
  and admission-control surface are callable on the branch at execution time, and append to
  the same reconciliation artifact the reconciled IC-6a contract (F8 exports
  `has_unresolved_drift(events) -> bool` regardless; the consultation edge is F6's to wire —
  record it as a cross-feature acceptance dependency, not an F8 blocker) and the reconciled
  IC-6b contract (the real entry-point name and `mutations[].op` value if F6 has landed;
  otherwise record that Phase 2 stubs the call behind the single named seam function that
  F6's landing replaces or delegates to). Never plan a second recolor implementation.
  - Acceptance: The artifact contains an IC-6a entry and an IC-6b entry stating the adopted
    entry-point name and `op` value or the stub-seam decision, with the §8.6 citation.

### Phase 2 — Pure Detection Module

- [x] [P2-T1] Create `scripts/dev_tools/parallel_drift_detection.py` containing
  `detect_escaped_paths(changed, declared)` returning the observed paths not subsumed by the
  declared `blast_radius.paths` patterns, using F1's path-subsumption predicate as reconciled
  in P1-T1 (imported, not reimplemented; or the documented `fnmatch.fnmatchcase` fallback with
  the deviation recorded). The module performs no I/O, reads no wall clock, and carries full
  type hints and docstrings.
  - Acceptance: The file exists; `detect_escaped_paths` imports the P1-T1 predicate (or the
    documented fallback) and contains no filesystem, subprocess, or `datetime.now` calls.
- [x] [P2-T2] Implement `select_halted_item(a, b)` in
  `scripts/dev_tools/parallel_drift_detection.py`: later-started selection as `argmax` over
  the tuple `(start_ts, item_key)` with lexicographic comparison and `item_key` compared as
  integer `issue_num`; equal timestamps deem the larger `issue_num` later-started (smaller key
  survives); a missing start timestamp on exactly one item makes the timestamped item
  earlier-started; both missing falls through to the item-key tie-break. Timestamps are
  function inputs (the start-timestamp field name is the one reconciled in P1-T2).
  - Acceptance: The function exists, is pure, and encodes all three tie-break branches; no
    code path selects the drifting item by virtue of drifting.
- [x] [P2-T3] Implement `build_drift_event(...)` in
  `scripts/dev_tools/parallel_drift_detection.py`, constructing the §12-shaped record
  `{ item_key, declared, observed, escaped_paths[], at, action }` with `item_key` as
  `issue_num`, `declared`/`observed` provenance per §5.2, `at` as an injected ISO-8601 input,
  and `action` restricted to the enum reconciled in P1-T2. No schema fields beyond the §12
  shape are produced.
  - Acceptance: The function exists, is pure, validates `action` against the reconciled enum,
    and raises a specific exception on an out-of-enum value.
- [x] [P2-T4] Implement `has_unresolved_drift(events) -> bool` in
  `scripts/dev_tools/parallel_drift_detection.py`: returns `True` exactly while the latest
  entry (by `at`, then append order) for any `item_key` has `action != "resolved"` (using the
  reconciled enum name for resolution). This is the single exported quiesce predicate F6's
  admission control consults (IC-6a); no quiesce field is written anywhere.
  - Acceptance: The function exists, is pure, and implements latest-entry-per-item semantics.
- [x] [P2-T5] Implement the single recolor seam function in
  `scripts/dev_tools/parallel_drift_detection.py` (one function, e.g.
  `request_requeue_via_recolor(...)`) that delegates to F6's recolor entry point as
  reconciled in P1-T4 (or the documented stub the F6 landing replaces): the delegated
  operation sets the halted item's `merge_status` to `blocked_drift`, appends exactly one
  `mutations[]` entry
  `{ op, item_key, at, prior_state: "in_flight", new_state: "blocked_drift", disposition: null, recolor_generation: <new> }`,
  and increments `recolor_generation` by one. The seam contains no coloring, cohort, or graph
  logic of its own.
  - Acceptance: Exactly one seam function exists; grep of the module shows no Welsh-Powell,
    cohort-assignment, or graph-coloring logic; the stub (if used) is documented with the
    IC-6b citation.
- [x] [P2-T6] Create `tests/scripts/dev_tools/test_parallel_drift_detection.py` with the
  escape-matrix tests for `detect_escaped_paths`: no escape, single escape, multiple escapes,
  and glob boundary cases (pattern-edge paths, separator handling, and rename handling where
  both old and new paths must be covered — fail closed). Tests are deterministic, use no
  temporary files, and follow Arrange-Act-Assert.
  - Acceptance: The file exists and contains parametrized cases covering all four matrix
    categories; `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_detection.py`
    exits 0.
- [x] [P2-T7] Add later-started selection tests for `select_halted_item` to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`: distinct timestamps (later
  halted), equal timestamps (larger `issue_num` halted, smaller survives), exactly one
  missing timestamp (timestamped item is earlier-started), both missing (item-key tie-break),
  all with injected timestamp inputs.
  - Acceptance: All four tie-break scenarios have at least one test each and pass.
- [x] [P2-T8] Add record-shape tests for `build_drift_event` to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`: the produced record contains
  exactly the §12 keys, `action` accepts each reconciled enum value, and an out-of-enum
  `action` raises the specific exception.
  - Acceptance: Shape, enum-accept, and enum-reject tests exist and pass.
- [x] [P2-T9] Add `has_unresolved_drift` tests to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`: empty event list is resolved;
  an unresolved latest entry for any item yields `True`; a later `resolved` entry for the
  same `item_key` clears it; an unresolved entry for one item is not masked by another
  item's resolution.
  - Acceptance: All four scenarios have tests and pass.
- [x] [P2-T10] Add recolor-seam tests to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`, mocking the delegated entry
  point at the import location used by the seam: exactly one `mutations[]` entry with the
  P2-T5 shape is requested, `recolor_generation` increments by exactly one, the halted item's
  `merge_status` becomes `blocked_drift`, and the seam performs no recoloring itself.
  - Acceptance: The mock-based tests exist and pass without temporary files.
- [x] [P2-T11] Add a determinism test to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`: invoking the full detection and
  halt-selection path twice with identical inputs produces identical escaped-path sets and
  identical halt/requeue decisions.
  - Acceptance: The test exists and passes.
- [x] [P2-T12] Implement conflict recomputation in
  `scripts/dev_tools/parallel_drift_detection.py` (for example
  `recompute_conflicts_with_observed(items, drifting_item_key, observed_paths, conflict_edges)`):
  substitute the observed radius for the drifting item's declared `blast_radius.paths`, evaluate
  F1's `conflicts(a, b)` relation as reconciled in P1-T1 (imported, never reimplemented) against
  each concurrently in-flight item, and return the set of pairs that conflict under the observed
  radius but not under the declared radius recorded in the checkpoint's `conflict_edges[]`. The
  function is pure: `items[]`, `conflict_edges[]`, and the observed path set are inputs; it
  performs no I/O, reads no wall clock, reads `conflict_edges[]` only, and adds no schema field to
  it. The returned newly-conflicting pairs are the input to `select_halted_item` (P2-T2). Fails
  closed: an item whose radius cannot be evaluated is treated as conflicting.
  - Acceptance: The function exists, is pure, imports F1's `conflicts(a, b)` relation (or records
    the P1-T1 BLOCKED state), returns only newly-introduced conflicts, and contains no
    reimplementation of the contention relation.
- [x] [P2-T13] Add conflict-recomputation tests to
  `tests/scripts/dev_tools/test_parallel_drift_detection.py`, mocking F1's `conflicts(a, b)` at
  the import location used by the unit under test: an escape that introduces no new conflict
  returns an empty pair set; an escape that newly conflicts with exactly one in-flight item
  returns that one pair; a pair already present in `conflict_edges[]` is not reported as new; an
  item whose radius cannot be evaluated is reported as conflicting (fail closed); the recomputed
  result feeds `select_halted_item` and yields the later-started item.
  - Acceptance: All five scenarios have at least one test each and pass; `conflict_edges[]` is
    read-only in the tested path.

### Phase 3 — CLI Wrapper

- [x] [P3-T1] Create `scripts/dev_tools/parallel_drift_detection_cli.py`: a thin argparse
  wrapper that accepts the changed-path list (as produced by
  `git diff --name-only <merge-base(origin/main, HEAD)> HEAD` at the child's pre-review
  commit) and the parallel checkpoint path, invokes the pure functions from
  `scripts/dev_tools/parallel_drift_detection.py` — escape detection, conflict recomputation
  (P2-T12), and halt selection when recomputation reports a new conflict — and emits the
  detection result including the escaped paths, the newly-conflicting pairs, and the selected
  halted item (or an explicit "no new conflict" result). All I/O
  (argument parsing, file reads, stdout) is confined to this file; the CLI executes no git
  commands itself and adds no dependency.
  - Acceptance: The file exists, imports only the pure module plus stdlib, and
    `scripts/dev_tools/parallel_drift_detection.py` remains free of I/O.
- [x] [P3-T2] Create `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` covering
  argument parsing (valid invocation, missing required argument, unknown argument) and
  dispatch into the pure functions with the I/O seams mocked; no temporary files and no
  subprocess execution.
  - Acceptance: The file exists;
    `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` exits 0.

### Phase 4 — Layer-2 Validator Invariant

- [x] [P4-T1] Create `scripts/dev_tools/_parallel_orchestrator_state_drift.py`: a key-gated
  helper following the `_orchestrator_state_*.py` split convention, exposing one
  `_validate_drift_events(state) -> list[str]`-style entry that (a) returns an empty list
  when the checkpoint has no `drift_events[]` key, (b) performs `drift_events[]` entry shape
  checks against the reconciled §12 shape, and (c) emits exactly one
  `PARALLEL_DRIFT_GATE_VIOLATION:`-prefixed error per item whose latest drift event is
  unresolved while its `merge_status` is in `{pr_open, ci_green, merged, worktree_removed}`.
  The helper never mutates its input and imports resolution semantics from
  `scripts/dev_tools/parallel_drift_detection.py` rather than duplicating them.
  - Acceptance: The file exists, is under 500 lines, and the absent-key path returns `[]`.
- [x] [P4-T2] Edit `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned) to
  add exactly one import line for `_parallel_orchestrator_state_drift` and exactly one
  key-gated dispatch call (`errors.extend(...)` style, matching the pattern reconciled in
  P1-T2). This edit must not reflow, reorder, or modify any existing line of the file
  (wave-4 contention constraint; F6 and F7 edit the same file concurrently).
  - Acceptance: `git diff scripts/dev_tools/validate_parallel_orchestrator_state.py` shows
    only two added lines (one import, one dispatch call) and zero removed or reflowed lines.
- [x] [P4-T3] Create `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py`
  covering: a checkpoint with no `drift_events[]` key produces zero drift errors (key-gated
  invariant); an unresolved latest event with each of the four progressed `merge_status`
  values produces exactly one `PARALLEL_DRIFT_GATE_VIOLATION:` error per item; a `resolved`
  latest event with a progressed status produces no error; an unresolved event with a
  non-progressed status produces no error; malformed entry shapes produce shape errors. All
  checkpoints are in-memory JSON structures; no temporary files.
  - Acceptance: The file exists;
    `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py`
    exits 0.

### Phase 5 — Layer-1 Hook and Registration

- [x] [P5-T1] Create `.claude/hooks/enforce-parallel-drift-gate.ps1`, adapted near-verbatim
  from `.claude/hooks/enforce-epic-wave-barrier.ps1` (which is not modified): script-scoped
  constants including the `Parallel mode: true` marker line matched byte-for-byte per the
  P1-T3 reconciliation, two injectable read seams so tests mock both boundaries without
  temporary files — a checkpoint-read seam and a finding-presence seam (for example
  `Test-ParallelDriftFindingPresent`) that reports whether a
  `remediation-inputs.<yyyy-MM-ddTHH-mm>.md` file exists in the resolved item's child feature
  folder, located via the `items[].worktree_path` field reconciled in P1-T3,
  prompt-scanning resolution of the target feature folder, and a dot-source guard. The hook
  fires on the `PreToolUse` `Agent` matcher when `subagent_type == "feature-review"` and the
  prompt carries the marker; it performs presence gating only (checkpoint-state reads plus a
  single finding-file existence check through the finding-presence seam — no path-glob
  matching, no diff computation, and no git execution), denying with
  `PARALLEL_DRIFT_GATE_BLOCKED` when the
  resolved item's latest drift event is unresolved and its synthetic finding file has not
  been written; it allows non-feature-review targets, prompts without the marker, resolved
  events, and unresolved events whose finding file exists; it fails closed (deny) on an
  unreadable checkpoint or an unresolvable target item.
  - Acceptance: The file exists, is under 500 lines, contains no `git` invocation and no
    path-glob matching, and emits allow/deny decisions as `hookSpecificOutput` JSON.
- [x] [P5-T2] Edit `.claude/settings.json` to append exactly one hook entry for
  `.claude/hooks/enforce-parallel-drift-gate.ps1` at the end of the existing `PreToolUse`
  `Agent` matcher hook list. The edit must not reorder, reflow, or modify any existing entry
  (append-only; F7 appends to the same list concurrently).
  - Acceptance: `git diff .claude/settings.json` shows only the one appended entry (plus any
    required trailing-comma line adjustment on the immediately preceding entry) and no
    reordering of existing entries.
- [x] [P5-T3] Create `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`
  (Pester v5), mocking both the checkpoint-read seam and the finding-presence seam and
  creating no temporary files, covering:
  allow on non-feature-review `subagent_type`; allow on a prompt without the
  `Parallel mode: true` marker; allow when the item's latest drift event is `resolved`; allow
  when the unresolved item's synthetic finding file is recorded as written; deny with
  `PARALLEL_DRIFT_GATE_BLOCKED` when the latest drift event is unresolved and no finding has
  been written; deny (fail closed) on an unreadable checkpoint; deny (fail closed) when the
  target item cannot be resolved from the prompt.
  - Acceptance: The file exists and all seven scenarios have at least one test each;
    `mcp__drm-copilot__run_poshqc_test` reports them passing.
- [x] [P5-T4] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` to append exactly
  one entry, `'.claude/hooks/enforce-parallel-drift-gate.ps1'`, to the end of the existing
  `CodeCoverage.Path` list with a one-line comment citing issue #446, so the new production hook
  is not excluded from coverage measurement per `.claude/rules/general-unit-test.md` Coverage
  Exclusion Policy. The edit is append-only: it must not reorder, reflow, remove, or modify any
  existing entry (F7 appends its own hooks to the same list concurrently).
  - Acceptance: `git diff scripts/powershell/PoshQC/settings/pester.runsettings.psd1` shows only
    the appended path entry and its comment, with zero removed or reflowed lines.

### Phase 6 — Procedure Documentation and Edit-Confinement Verification

- [x] [P6-T1] Edit `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned) to add the
  single new H2 section `## Radius Drift Detection and Drift Gate` — filling F5's reserved
  placeholder of that name if P1-T3 found one, otherwise appending the section at the end of
  the file. The section documents: the six §7 steps; the child-side evaluation point (the
  child orchestrator's Pre-Feature-Review Commit step, between the successful commit and the
  `feature-review` delegation, active only under the `Parallel mode: true` marker); the CLI
  invocation with the merge-base three-dot diff; the synthetic-finding path
  `docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md` (flat form)
  with the literal `- Severity: Blocking` line, written by the parallel-orchestrator via
  `items[].worktree_path`; the halt-the-later-started rule with tie-breaks; quiesce as
  derived state via `has_unresolved_drift`; the requeue through the single recolor seam; the
  two-layer drift gate with the P1 constraint-8 interpretation; and resolution semantics
  (`resolved` event appended when the consuming remediation cycle exits with
  `blocking_count == 0`, reusing R1-R5 unmodified). The edit must not reflow, reorder, or
  modify any other section, and this feature must not modify
  `.claude/skills/orchestrate/SKILL.md`.
  - Acceptance: The SKILL.md contains exactly one `## Radius Drift Detection and Drift Gate`
    section covering all listed elements;
    `git diff .claude/skills/orchestrate/SKILL.md` is empty.
- [x] [P6-T2] Verify edit confinement on the three shared files and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/other/shared-file-edit-confinement.<timestamp>.md`
  recording, with the diff hunks quoted: `.claude/skills/parallel-orchestrate/SKILL.md` shows
  only the single added H2 section; `scripts/dev_tools/validate_parallel_orchestrator_state.py`
  shows only one added import line and one added dispatch call;
  `.claude/settings.json` shows only one appended `Agent` matcher entry; and no diff exists
  for `.claude/skills/orchestrate/SKILL.md` or any `.claude/hooks/enforce-epic-*.ps1` file.
  - Acceptance: The artifact exists with `Timestamp:`, `Command:` (the git diff commands
    used), `EXIT_CODE:`, and `Output Summary:` confirming all four confinement checks.

### Phase 7 — Final QC Loop and Acceptance Check-Off

Run the two language loops in order (format → lint → type-check → test for Python;
format → analyze → test for PowerShell). If any step fails or changes files, restart that
language's loop from its first step until a single clean pass completes; the artifacts below
record the final clean pass. Every task in this phase is unconditional: each stated command
must be executed and recorded, and `EXIT_CODE: SKIPPED` is not a permitted outcome.

- [x] [P7-T1] Run `poetry run black .` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-format-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` states whether
    any file was reformatted (a reformat restarts the Python loop).
- [x] [P7-T2] Run `poetry run ruff check .` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-lint-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and `EXIT_CODE: 0` on the recorded
    clean pass.
- [x] [P7-T3] Run `poetry run pyright` from the repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-typecheck-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and `EXIT_CODE: 0` (zero errors) on
    the recorded clean pass.
- [x] [P7-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the
  repo root and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-test-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` records the
    pass/fail counts, the numeric post-change overall line and branch coverage, and the
    numeric per-file line and branch coverage for
    `scripts/dev_tools/parallel_drift_detection.py`,
    `scripts/dev_tools/parallel_drift_detection_cli.py`, and
    `scripts/dev_tools/_parallel_orchestrator_state_drift.py`.
- [x] [P7-T5] Run `mcp__drm-copilot__run_poshqc_format` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-format-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; any reformat restarts the
    PowerShell loop and the artifact records the final clean pass.
- [x] [P7-T6] Run `mcp__drm-copilot__run_poshqc_analyze` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-analyze-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields and zero findings on the recorded
    clean pass.
- [x] [P7-T7] Run `mcp__drm-copilot__run_poshqc_test` and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-test-final.<timestamp>.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields, Pester pass counts including
    `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, and the numeric
    post-change line and branch coverage for
    `.claude/hooks/enforce-parallel-drift-gate.ps1`.
- [x] [P7-T8] Verify coverage thresholds and delta, and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/coverage-delta.<timestamp>.md`
  reporting: the numeric baseline coverage from the P0-T5 artifact, the numeric post-change
  coverage from the P7-T4 artifact, the per-file coverage of the three new Python modules and
  of `.claude/hooks/enforce-parallel-drift-gate.ps1` (from the P0-T8 and P7-T7 artifacts),
  confirmation that each of the four new modules meets line >= 85% and branch >= 75%, and
  confirmation of no coverage regression on changed lines. If any value is unavailable or any
  threshold is unmet, record the outcome as remediation-required; do not record PASS.
  - Acceptance: The artifact exists with `Timestamp:`, both numeric coverage sets for both
    languages, the
    per-module threshold verdicts, and an explicit PASS or remediation-required conclusion.
- [x] [P7-T9] Check off the acceptance criteria per the `acceptance-criteria-tracking` skill:
  for every item in the `## Acceptance Criteria` sections of
  `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` and
  `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`, mark the
  checkbox only when supporting evidence exists, and write
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/acceptance-criteria-checkoff.<timestamp>.md`
  mapping each criterion to its evidence (test name, artifact path, or diff hunk), including
  the cross-feature IC-6a consultation edge recorded as F6's acceptance dependency per
  P1-T4.
  - Acceptance: Every criterion in both files is either checked with a named evidence
    reference or listed as unmet with a remediation note; no criterion is checked without
    evidence.

## Test Plan

- Unit (Python): `tests/scripts/dev_tools/test_parallel_drift_detection.py`,
  `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py`,
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py` — escape
  matrix, tie-breaks, record shapes, quiesce predicate, recolor-seam effects, determinism,
  key-gated validator invariant.
- Unit (PowerShell): `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` —
  allow/deny/fail-closed paths with the checkpoint-read seam mocked.
- Determinism: timestamps entering halt decisions are injected inputs; no wall-clock reads in
  pure functions; no temporary files anywhere in tests.
- Coverage evidence: baseline `evidence/baseline/python-test-baseline.<timestamp>.md` and
  `evidence/baseline/powershell-test-baseline.<timestamp>.md`; post-change
  `evidence/qa-gates/python-test-final.<timestamp>.md` and
  `evidence/qa-gates/powershell-test-final.<timestamp>.md`; comparison
  `evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- The `action` enum names and the start-timestamp field name are adopted from F3's landed
  schema in P1-T2; the values named in this plan are the research-recommended defaults used
  only if F3 does not enumerate them.
- IC-6a's consultation edge (F6 calling `has_unresolved_drift`) is F6's to wire; F8 records
  it as a cross-feature acceptance dependency in P1-T4 and P7-T9, not as an F8 deliverable.
- If `scripts/dev_tools/parallel_drift_detection.py` trends past ~400 lines during Phase 2,
  split halt/tie-break/requeue-decision logic into
  `scripts/dev_tools/parallel_drift_halt.py` with a mirrored test file; the split is a
  contingency, not a planned task.
