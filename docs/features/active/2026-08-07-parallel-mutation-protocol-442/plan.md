# parallel-mutation-protocol — Plan

- **Issue:** #442
- **Parent (optional):** Epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, child feature F6, wave 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07
- **Status:** Ready for Preflight
- **Version:** 1.0
- **Work Mode:** full-feature
- **Plan Path (continuity):** `docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md` (update in place across revision loops; do not create sibling plan files)

## Required References

- Spec (normative): `docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md`
- User story: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/user-story.md`
- Research: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/research/2026-08-07-parallel-mutation-protocol-research.md`
- Issue: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/issue.md`
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (§8, §9; consumed structures §5.4, §6, §11, §12)
- Epic manifest: `docs/features/epics/parallel-orchestration/epic.md`
- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`

All work must comply with these policies; this plan does not duplicate their content.

## Conventions Used in This Plan

- `<FEATURE>` = `docs/features/active/2026-08-07-parallel-mutation-protocol-442`. Evidence artifacts go only to `<FEATURE>/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/`-rooted evidence path is permitted anywhere in this plan.
- Every evidence artifact records `Timestamp:` (ISO-8601 `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Python toolchain: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Restart the loop from formatting if any step fails or changes files.
- PowerShell toolchain: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test` (Pester v5 with repo settings). Restart from format if any step fails or changes files.
- Determinism: no temporary files in any test; injected clock (`clock: Callable[[], datetime]`) for every `mutations[].at` timestamp; seeded RNG (`random.Random(seed)`, seed printed on failure) for any randomized graph generation; hook tests mock the read seam with literal JSON and never touch the filesystem or live git/gh.
- AC labels: `S1`–`S15` are the `## Acceptance Criteria` items of `spec.md` in file order; `U1`–`U9` are the `## Acceptance Criteria` items of `user-story.md` in file order. Both files are AC sources (work mode `full-feature`).
- Abandon confirmation marker (fixed at plan time per spec FR8): the literal token `--confirm-abandon` present in the same Bash command as `--disposition abandon`.
- Engine module inventory (fixed at plan time, subject to Phase 1 divergence stops): `scripts/dev_tools/_parallel_mutation_models.py` (frozen dataclasses and exception types), `scripts/dev_tools/parallel_mutation_protocol.py` (pure decision functions), `scripts/dev_tools/parallel_mutation_abandon_cli.py` (thin CLI for the abandon path with an injectable runner seam). This split keeps every file under the 500-line cap.

## Execution Context

This plan is authored in preparation mode. Waves 0–3 (F1 issue 447, F2 issue 445, F3 issue 444, F4 issue 443, F5 issue 441) have NOT landed at planning time. Execution occurs later, in an execution-phase worktree based on `epic/parallel-orchestration-integration` with waves 0–3 landed. Phase 1 re-verifies every consumed upstream contract against the landed integration branch head before any edit. Every upstream name used in Phases 2–7 is an expectation carried from the spec; a Phase 1 divergence stops execution with a revisions-required report rather than an improvised adaptation.

## Wave-4 Contention Constraint (Mandatory)

F6 executes concurrently with F7 (`parallel-enforcement-hooks`, issue 440) and F8 (`parallel-drift-detection`, issue 446). All three extend `.claude/skills/parallel-orchestrate/SKILL.md` and `scripts/dev_tools/validate_parallel_orchestrator_state.py`. This plan confines F6's edits to shared files as follows, and no task may reflow or reorder any existing section of any shared file:

| Shared file | Owner | F6's confinement in this plan |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | F5 (issue 441) | Exactly one appended section named `## Mutation Protocol` (or F5's landed reserved name per P1-T2). Append-only; no edits inside existing sections. Task: P4-T4. |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | F3 (issue 444) | Exactly one additive import plus one call line delegating to `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`. Task: P3-T2. |
| `.claude/settings.json` | shared | Exactly one additive entry appended at the end of the existing `PreToolUse` → `Bash` matcher `hooks` array, immediately after the `enforce-epic-worktree-removal-gate.ps1` entry. Task: P5-T2. |

F3 owns the complete checkpoint schema including `mutations[]`, `drift_events[]`, and `conflict_edges[]`. No task in this plan adds a schema field or enum value. No task modifies or refactors any existing epic implementation (`enforce-epic-*` hooks, epic validators, epic skills, epic agents).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read policy files in the required order and record the read evidence.
  - Order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md` (if present), `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md` (if landed by F3)
  - Artifact: `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read
  - Acceptance: artifact exists with all required fields; list matches the order above
- [ ] [P0-T2] Capture Python lint baseline.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-py-lint.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: artifact exists with exit code recorded
- [ ] [P0-T3] Capture Python type-check baseline.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-py-typecheck.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: artifact exists with exit code recorded
- [ ] [P0-T4] Capture Python test + coverage baseline with numeric coverage values.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-py-test-coverage.md`; `Output Summary:` MUST include numeric baseline line and branch coverage percentages and the pass/fail test counts (no placeholders)
  - Acceptance: artifact exists; numeric line and branch coverage recorded
- [ ] [P0-T5] Capture PowerShell analyzer baseline.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ps-analyze.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with finding count)
  - Acceptance: artifact exists with exit code and finding count recorded
- [ ] [P0-T6] Capture PowerShell Pester test + coverage baseline with numeric coverage values.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md`; `Output Summary:` MUST include pass/fail counts and the numeric line coverage percentage from the Pester coverage report (no placeholders)
  - Acceptance: artifact exists; numeric coverage recorded

### Phase 1 — Upstream Contract Re-Verification (Blocking Precondition)

Stop rule for this phase: if any task in this phase records a divergence between the landed contract and the assumption stated in the task, the executor MUST make no file edit, stop plan execution, and report revisions-required with the recorded divergence so this plan can be updated in place. Improvised adaptation to a diverged contract is prohibited.

- [ ] [P1-T1] Fetch the integration branch and confirm the execution worktree is based on its head with waves 0–3 landed.
  - Commands: `git fetch origin epic/parallel-orchestration-integration`; `git merge-base --is-ancestor origin/epic/parallel-orchestration-integration HEAD`; confirm by listing that `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/parallel_cohort_computation.py`, `scripts/dev_tools/validate_parallel_orchestrator_state.py`, `.claude/agents/parallel-orchestrator.md`, and `.claude/skills/parallel-orchestrate/SKILL.md` all exist
  - Artifact: `<FEATURE>/evidence/other/upstream-branch-verification.md` (`Timestamp:`, `Command:` for each check, `EXIT_CODE:` for each check, `Output Summary:` listing each expected file as present/absent)
  - Acceptance: all five files exist and HEAD contains the integration branch head; otherwise apply the phase stop rule
  - AC: S12
- [ ] [P1-T2] Verify F5's reserved section names in `.claude/skills/parallel-orchestrate/SKILL.md`.
  - Read the landed SKILL in full; record its exact `##` section inventory; determine whether a placeholder section is reserved for F6 and, if so, its exact name; confirm the assumption that F6 appends a section named `## Mutation Protocol`
  - Artifact: `<FEATURE>/evidence/other/upstream-f5-skill-sections.md` (`Timestamp:`, section inventory, reserved-name finding, divergence verdict)
  - Acceptance: artifact records either "no divergence — append `## Mutation Protocol`" or the landed reserved name with the phase stop rule applied
  - AC: S11, S12
- [ ] [P1-T3] Verify F3's `mutations[]` schema shape against the landed checkpoint schema and validator.
  - Read `scripts/dev_tools/validate_parallel_orchestrator_state.py` and the landed schema documentation (`.claude/rules/parallel-orchestration.md` if present); confirm: the seven-field entry shape `{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`; the `op` vocabulary `add | remove | close | requeue`; nullability of `item_key`, `prior_state`, `new_state`, `disposition` per the spec per-op table; the item-state enum `proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked`; the `merge_status` enum including `worktree_removed` and `blocked_drift`; the validator's helper-module import/call structure
  - Artifact: `<FEATURE>/evidence/other/upstream-f3-mutations-schema.md` (`Timestamp:`, verified shape, divergence verdict per field)
  - Acceptance: artifact records field-by-field verification; any divergence applies the phase stop rule
  - AC: S12
- [ ] [P1-T4] Verify F1's `conflicts(a, b)` entry point in `scripts/dev_tools/compute_blast_radius.py`.
  - Confirm the exported function name and signature for the contention relation (`path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`, fail-closed)
  - Artifact: `<FEATURE>/evidence/other/upstream-f1-conflicts-signature.md` (`Timestamp:`, exact signature, divergence verdict)
  - Acceptance: artifact records the exact landed signature; any divergence from a callable pairwise conflict relation applies the phase stop rule
  - AC: S12
- [ ] [P1-T5] Verify F2's Welsh-Powell coloring entry point in `scripts/dev_tools/parallel_cohort_computation.py`.
  - Confirm the exported function name, signature, and determinism contract (descending degree, ascending-item-key tie-break) that `recolor_unstarted` will delegate to without reimplementation
  - Artifact: `<FEATURE>/evidence/other/upstream-f2-coloring-signature.md` (`Timestamp:`, exact signature, divergence verdict)
  - Acceptance: artifact records the exact landed signature; any divergence applies the phase stop rule
  - AC: S12, S5
- [ ] [P1-T6] Record the property-test tooling decision from the landed `pyproject.toml`.
  - Check whether `hypothesis` is present in `[tool.poetry.group.dev.dependencies]`; if present, property tests in P2-T9 use `hypothesis`; if absent, they use seeded `random.Random(seed)` generation with the seed printed on failure and the deviation is recorded in this artifact (no dependency is added by this plan)
  - Artifact: `<FEATURE>/evidence/other/property-test-tooling-decision.md` (`Timestamp:`, finding, chosen mechanism)
  - Acceptance: artifact records the finding and the chosen mechanism unambiguously
  - AC: S5
- [ ] [P1-T7] Verify the `.claude/settings.json` insertion point for the abandon-gate registration.
  - Read the landed `PreToolUse` → `Bash` matcher `hooks` array; record its current final entry (assumed `enforce-epic-worktree-removal-gate.ps1`) and confirm the P5-T2 insertion point (append at end of that array); record whether F7 entries are already present
  - Artifact: `<FEATURE>/evidence/other/settings-insertion-point.md` (`Timestamp:`, current array tail, confirmed insertion point)
  - Acceptance: artifact names the exact insertion point; a structurally different hooks surface applies the phase stop rule
  - AC: S10, S11, S12
- [ ] [P1-T8] Reconciliation gate: confirm zero unresolved divergences before implementation.
  - Review the P1-T1..P1-T7 artifacts; confirm every divergence verdict is "no divergence"
  - Artifact: `<FEATURE>/evidence/other/upstream-reconciliation-gate.md` (`Timestamp:`, per-task verdict table, overall verdict)
  - Acceptance: overall verdict is "clear to implement"; otherwise the phase stop rule has already halted execution and this task records the halt
  - AC: S12

### Phase 2 — Pure Mutation Engine (Python)

- [ ] [P2-T1] Create `scripts/dev_tools/_parallel_mutation_models.py` with frozen dataclass value objects and dedicated exception types.
  - Content: `ItemRecord`, `AdmissionDecision` (outcome enum `ADMIT_CURRENT_COHORT | DEFER_AND_RECOLOR`), `RecolorResult` (cohort assignments for unstarted items only, plus resulting generation), `MutationEntry` (exactly the seven F3 fields `op, item_key, at, prior_state, new_state, disposition, recolor_generation`); exception types carrying the offending key per the `epic_wave_computation.py` pattern: rejected in-flight removal without disposition, rejected `merged` removal, rejected close while in flight, unknown item/state errors
  - Constraints: all dataclasses `frozen=True`; full type hints; no file I/O; file <= 500 lines
  - Acceptance: module imports cleanly; Pyright-clean; behaviors verified by P2-T8/P2-T9 tests
  - AC: S1
- [ ] [P2-T2] Implement `decide_admission` in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Signature: `decide_admission(candidate: str, conflict_edges: Sequence[tuple[str, str]], in_flight: frozenset[str]) -> AdmissionDecision`; conflict edges are computed by the caller over ALL items including in-flight ones (F1 relation per P1-T4); returns `ADMIT_CURRENT_COHORT` if and only if the candidate shares no edge with any in-flight item, else `DEFER_AND_RECOLOR`
  - Constraints: pure (no I/O, no clock, inputs unmutated)
  - Acceptance: function implemented with docstring stating the purity contract; verified by P2-T8 scenario 4 and P2-T9
  - AC: S1, S2, U1
- [ ] [P2-T3] Implement `recolor_unstarted` in `scripts/dev_tools/parallel_mutation_protocol.py`, delegating coloring to F2's landed entry point.
  - Signature: `recolor_unstarted(unstarted_items: Sequence[str], conflict_edges: Sequence[tuple[str, str]], pinned: frozenset[str], current_generation: int) -> RecolorResult`; takes the induced subgraph of unstarted items internally; delegates the coloring to the F2 entry point verified in P1-T5 (no reimplementation); returns cohort assignments for unstarted items only, never assigning or moving a pinned item; result generation equals `current_generation + 1`
  - Constraints: pure function of `(remaining subgraph, pinned set)`; identical inputs yield identical outputs; inputs unmutated
  - Acceptance: function implemented; delegation to the F2 function is visible in the source (import and call); verified by P2-T8 and P2-T9
  - AC: S1, S5, U5
- [ ] [P2-T4] Implement the removal decision function in `scripts/dev_tools/parallel_mutation_protocol.py` implementing the spec FR2 behavior table exactly.
  - Behavior: `proposed | admitted | prepared | scheduled` → mark `withdrawn`, drop the vertex, recompute (recolor via P2-T3); `in_flight` without disposition → raise the dedicated rejection exception (no default disposition is ever inferred); `in_flight` + `detach` → new state `withdrawn`, `disposition: "detach"`, no recompute; `in_flight` + `abandon` → new state `withdrawn`, `disposition: "abandon"`, no recompute (side effects are executed only by the P2-T7 CLI); `merged` → raise the dedicated rejection exception; rejected removals make no state change and produce no mutation entry
  - Constraints: pure; full type hints
  - Acceptance: one code path per table row; verified by P2-T8 scenario 5 (one test per row)
  - AC: S1, S3, U2, U3
- [ ] [P2-T5] Implement close gating and the completion predicate in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Behavior: close is rejected (dedicated exception) while any item is `in_flight`; a successful close terminates an `open`-mode run with one run-scoped mutation entry and no recompute; `is_closed_mode_complete(items: Mapping[str, ItemRecord]) -> bool` returns true if and only if every non-withdrawn item has `merge_status` in `{merged, worktree_removed}` (field semantics per P1-T3); `open` mode never auto-completes
  - Constraints: pure; full type hints
  - Acceptance: verified by P2-T8 scenarios 6 and 7
  - AC: S1, S4, S8, U4, U7
- [ ] [P2-T6] Implement mutation-entry construction and generation accounting in `scripts/dev_tools/parallel_mutation_protocol.py` per the spec per-op entry-contents table.
  - Behavior: a constructor producing exactly one `MutationEntry` per successful op, with `op`, `item_key`, `prior_state`, `new_state`, `disposition`, and `recolor_generation` values matching the spec table for all seven op cases (no-conflict add `g`; deferred add `g+1`; unstarted remove `g+1`; `detach` `g`; `abandon` `g`; close `g` run-scoped with null `item_key`/`prior_state`/`new_state`; drift-induced requeue `g+1` with `prior_state: in_flight`, `new_state: blocked` — the requeue constructor is the append/recolor contract F8 invokes); `at` is supplied via the injected `clock: Callable[[], datetime]` seam; the engine never reads the wall clock; rejected ops construct nothing
  - Constraints: pure aside from the injected clock callable; file `parallel_mutation_protocol.py` stays <= 500 lines after P2-T2..P2-T6 (split additional logic into `_parallel_mutation_models.py` if approaching the cap)
  - Acceptance: verified by P2-T8 scenarios 3 and 8; both engine files <= 500 lines
  - AC: S1, S6, S7, U6
- [ ] [P2-T7] Create `scripts/dev_tools/parallel_mutation_abandon_cli.py` — the single deterministic CLI entry point for the abandon path.
  - Content: argparse surface accepting the item key, `--disposition abandon`, the confirmation marker `--confirm-abandon`, the PR number, and the worktree path; executes `gh pr close` and `git worktree remove` through an injectable runner seam (callable parameter with a subprocess default) so tests never invoke live `gh`/`git`; refuses to run without `--confirm-abandon`; exits non-zero with a specific error on any failed side effect
  - Constraints: thinnest possible wiring; all decision logic remains in the engine; file <= 500 lines; full type hints
  - Acceptance: module exists; the documented invocation shape (`poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item <key> --disposition abandon --confirm-abandon ...`) contains the literal substrings `--disposition abandon` and `--confirm-abandon` that the FR8 gate matches; verified by P2-T10
  - AC: S1, S3, U3
- [ ] [P2-T8] Create `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` covering the spec Test Strategy unit scenarios.
  - Scenarios (each as one or more individual tests): (1) pinned items never move — `RecolorResult` contains no assignment for any pinned item and applying it leaves pinned items' states and current-cohort membership unchanged; (3) generation accounting — each recompute op yields `g+1`, each non-recompute op stamps `g` unchanged, and a sequence of N ops from `g` ends at exactly `g + (number of recompute ops)`; (4) admission over ALL items — conflict only with in-flight → deferred; conflict only with unstarted → placed by coloring, not rejected; no conflicts → admitted with no generation change; (5) removal behavior table — one test per FR2 row including both rejection rows, asserting the dedicated exception and that no entry is appended; (6) close gating — rejected while any item is `in_flight`, terminates `open` mode otherwise; (7) completion predicate — parametrized over the `merge_status` enum, `closed` fires only when every non-withdrawn item is `merged` or `worktree_removed`, `open` never auto-completes; (8) mutation-log shape — every successful op appends exactly one entry with the seven fields, `at` from the injected clock, rejected ops append nothing
  - Constraints: literal-dict fixtures; injected fixed clock; no temp files; file <= 500 lines (split a second unit-test file `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` if approaching the cap)
  - Acceptance: every listed scenario present as individual tests; `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_protocol.py -v` exits 0
  - AC: S5, S6, S7, S8, S15, U2, U5, U6, U7
- [ ] [P2-T9] Create `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` with the determinism and property-based tests (primary test obligation).
  - Content: purity/determinism unit test (two calls with equal inputs return equal outputs; inputs unmutated); property P1 (determinism) — for arbitrary conflict graphs and arbitrary pinned/unstarted partitions, `recolor_unstarted(x) == recolor_unstarted(x)`, every unstarted vertex assigned to exactly one cohort, no pinned vertex assigned to any cohort; property P2 (independent-set validity) — no two items in the same recolored cohort share a conflict edge; property P3 (pin stability under mutation sequences) — for an arbitrary sequence of add/remove ops, items in flight at op time never change cohort or state as a result of the op; at least one property test per pure engine function (`decide_admission`, `recolor_unstarted`, removal decision, close gating, `is_closed_mode_complete`, entry construction)
  - Mechanism: `hypothesis` if P1-T6 recorded it present; otherwise seeded `random.Random(seed)` generation with the seed printed on failure (deviation recorded in the P1-T6 artifact)
  - Constraints: deterministic; no temp files; file <= 500 lines
  - Acceptance: P1, P2, P3 and the per-function property tests all pass via `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py -v`
  - AC: S5, S15, U5
- [ ] [P2-T10] Create `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` covering the CLI through the injectable runner seam.
  - Scenarios: refuses (non-zero exit, specific error) without `--confirm-abandon`; with the marker, invokes the runner with the `gh pr close` and `git worktree remove` argument vectors exactly once each; propagates a failed side effect as a non-zero exit with a specific error; no live `gh`/`git` invocation anywhere (runner injected in every test)
  - Constraints: no temp files; no subprocess execution; file <= 500 lines
  - Acceptance: all scenarios pass via `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py -v`
  - AC: S3, S15, U3
- [ ] [P2-T11] Run the full Python toolchain loop until a single clean pass.
  - Commands in order: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: S13

### Phase 3 — Validator Helper and Single Additive Call Site

- [ ] [P3-T1] Create `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` implementing the three key-gated FR9 invariants.
  - Content: one entry function returning a list of literal error strings in the existing validator message style, never mutating its input; invariant 1 — each `mutations[]` entry carries exactly the seven §8.6 fields with the P1-T3-verified nullability; invariant 2 — `recolor_generation` is monotonically non-decreasing across `mutations[]` in append order; invariant 3 — the mode-dependent completion invariant (an `open`-mode checkpoint must not record auto-completion; a `closed`-mode checkpoint recording completion must satisfy the completion predicate); all checks key-gated so a checkpoint without the relevant keys produces no new errors
  - Constraints: follows the `_orchestrator_state_*.py` helper convention; no schema file import; file <= 500 lines; full type hints
  - Acceptance: module implemented; verified by P3-T3
  - AC: S9, U9
- [ ] [P3-T2] Wire the helper into `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned) with exactly one additive import and one call line.
  - Confined edit: one `import`/`from` line added to the existing helper-import block and one call line appended where the validator aggregates helper errors, matching the structure verified in P1-T3; no other line of the file changes; no existing section reflowed or reordered
  - Acceptance: `git diff scripts/dev_tools/validate_parallel_orchestrator_state.py` shows exactly two added lines and zero removed lines; verified again in P7-T10
  - AC: S9, S11
- [ ] [P3-T3] Create `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`.
  - Scenarios: mutation-entry shape errors (missing field, wrong nullability) each produce one literal error; a decreasing `recolor_generation` sequence produces the monotonicity error; `open`-mode checkpoint recording auto-completion produces an error; `closed`-mode checkpoint recording completion while a non-withdrawn item is not `merged`/`worktree_removed` produces an error; backward compatibility — a checkpoint without `mutations[]`/mode-completion keys produces no new errors; the input checkpoint object is unmutated after validation
  - Constraints: literal-dict fixtures; no temp files; file <= 500 lines
  - Acceptance: all scenarios pass via `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py -v`
  - AC: S9, S15, U9
- [ ] [P3-T4] Run the full Python toolchain loop until a single clean pass.
  - Commands in order: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: S13

### Phase 4 — Slash-Command Skills and the Mutation Protocol Section

- [ ] [P4-T1] Create `.claude/skills/parallel-add/SKILL.md`.
  - Frontmatter: `name: parallel-add`, `description`, `argument-hint: "[issue|potential-entry]"`, `context: fork`, `agent: parallel-orchestrator` (slash-command convention per the research Landed table)
  - Body: the FR1 procedure — item enters `proposed`; preparation via a preparation-mode child `Agent(orchestrator)` run reusing the `route_id: preparation` contract unchanged; conflict edges computed against ALL items including in-flight ones via F1's relation; admission decision via `decide_admission` (admit into current cohort only when no in-flight conflict, else defer and recolor via `recolor_unstarted`); exactly one `mutations[]` entry appended at admission-decision time with the per-op generation stamping; re-derive durable state (`git worktree list --porcelain`, `git branch`, `gh pr view`) before applying the mutation
  - Acceptance: file exists with the exact frontmatter fields and every listed procedure element; no other file edited
  - AC: S2, U1
- [ ] [P4-T2] Create `.claude/skills/parallel-remove/SKILL.md`.
  - Frontmatter: `name: parallel-remove`, `description`, `argument-hint: "[item] [--disposition detach|abandon]"`, `context: fork`, `agent: parallel-orchestrator`
  - Body: the FR2 state-dependent behavior table reproduced exactly (all five rows); the no-default-disposition rule stated explicitly; `detach` records `withdrawn` with `disposition: "detach"` and no recompute; the abandon procedure mandates the single deterministic CLI invocation `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item <key> --disposition abandon --confirm-abandon ...` and prohibits ad hoc `gh`/`git` commands for the abandon disposition; the `--confirm-abandon` confirmation-marker contract and the `PARALLEL_ABANDON_BLOCKED` deny behavior documented; rejected removals append no entry and change no state; re-derive durable state before applying
  - Acceptance: file exists with the exact frontmatter fields, the full behavior table, the CLI-only abandon rule, and the marker contract; no other file edited
  - AC: S3, S10, U2, U3
- [ ] [P4-T3] Create `.claude/skills/parallel-close/SKILL.md`.
  - Frontmatter: `name: parallel-close`, `description`, `argument-hint: "[parallel-slug]"`, `context: fork`, `agent: parallel-orchestrator`
  - Body: the FR3 procedure — terminates an `open`-mode run; rejected while any item is `in_flight` (no entry, no state change); a successful close appends one run-scoped `mutations[]` entry and does not recompute; re-derive durable state before applying
  - Acceptance: file exists with the exact frontmatter fields and every listed procedure element; no other file edited
  - AC: S4, U4
- [ ] [P4-T4] Append the `## Mutation Protocol` section to `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned; confined append-only edit).
  - Section name: `## Mutation Protocol`, or the F5 landed reserved name recorded by P1-T2 (a differing landed name has already triggered the Phase 1 stop rule and a plan revision naming it here)
  - Section content: the add/remove/close procedures with pointers to the three P4-T1..P4-T3 skills; the pinning invariant statement; the full recompute boundary (recompute ops: deferred add, unstarted remove, drift-induced requeue; non-recompute ops: no-conflict admit, detach, abandon, close, each stamping the current generation); the per-op mutation-log entry contents; mode-dependent completion semantics; the abandon confirmation-marker contract (`--confirm-abandon`, reason code `PARALLEL_ABANDON_BLOCKED`); the drift-requeue append contract F8 invokes
  - Confinement: append exactly one section at the end of the file; no edit, reflow, or reorder of any existing section
  - Acceptance: `git diff .claude/skills/parallel-orchestrate/SKILL.md` shows only appended lines forming one new section; verified again in P7-T10
  - AC: S11, S6, S7, S8

### Phase 5 — Abandon Gate Hook and Registration (PowerShell)

- [ ] [P5-T1] Create `.claude/hooks/enforce-parallel-abandon-gate.ps1` on the Bash matcher, patterned near-verbatim on `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`.
  - Behavior: parse `CLAUDE_TOOL_INPUT` JSON; deny any command containing `--disposition abandon` without the literal `--confirm-abandon` token in the same command, emitting `hookSpecificOutput.permissionDecision` deny with reason message prefixed `PARALLEL_ABANDON_BLOCKED`; allow when the marker is present; allow commands out of scope (no `--disposition abandon`); throw on malformed `CLAUDE_TOOL_INPUT` JSON
  - Structure: injectable read seam for the tool-input retrieval; allow/block decision builders; dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) so the body is coverable by Pester; advanced functions with `CmdletBinding()`; file <= 500 lines; no modification of any existing `enforce-epic-*` hook
  - Acceptance: hook exists implementing all four behaviors; verified by P5-T3
  - AC: S10, U8
- [ ] [P5-T2] Register the hook in `.claude/settings.json` (shared surface; confined append-only edit).
  - Edit: append exactly one entry `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1" }` at the end of the existing `PreToolUse` → `Bash` matcher `hooks` array, immediately after the `enforce-epic-worktree-removal-gate.ps1` entry (insertion point confirmed by P1-T7; if F7 has already appended entries, append after the current final entry of the same array and record the observed tail in the commit message)
  - Confinement: no other key, entry, or line of `.claude/settings.json` changes; no reordering of existing entries
  - Acceptance: `git diff .claude/settings.json` shows exactly one added hook entry in the Bash matcher array and nothing else; verified again in P7-T10
  - AC: S10, S11
- [ ] [P5-T3] Create `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`, patterned on `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`.
  - Scenarios: deny with reason code matching `PARALLEL_ABANDON_BLOCKED` when the command carries `--disposition abandon` without `--confirm-abandon`; allow when both tokens are present in the same command; allow an out-of-scope command (no `--disposition abandon`); throw on malformed `CLAUDE_TOOL_INPUT` JSON
  - Mechanism: dot-source the hook; mock the read seam with literal JSON strings; no temp files; no live git/gh; assert on `permissionDecision` and `-Match` on the reason code
  - Acceptance: all four scenarios pass via `mcp__drm-copilot__run_poshqc_test`
  - AC: S10, S14, S15, U8
- [ ] [P5-T4] Run the full PowerShell toolchain loop until a single clean pass.
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`; restart from format if any step fails or changes files
  - Acceptance: all three stages pass consecutively with exit code 0
  - AC: S14

### Phase 6 — Acceptance-Criteria Check-Off

Check-off protocol per `.claude/skills/acceptance-criteria-tracking/SKILL.md`: evidence before check-off; one item at a time; change only `- [ ]` to `- [x]`; leave unmet items unchecked and document the gap.

- [ ] [P6-T1] Check off delivered acceptance criteria in `<FEATURE>/spec.md` (`## Acceptance Criteria`, items S1–S15), one at a time, each only after the mapped tasks and their verification evidence are complete.
  - Mapping: S1 ← P2-T1..P2-T7; S2 ← P4-T1; S3 ← P2-T4, P2-T7, P4-T2; S4 ← P2-T5, P4-T3; S5 ← P2-T3, P2-T8, P2-T9; S6 ← P2-T6, P2-T8; S7 ← P2-T6, P2-T8; S8 ← P2-T5, P2-T8; S9 ← P3-T1..P3-T3; S10 ← P5-T1..P5-T3; S11 ← P3-T2, P4-T4, P5-T2, P7-T10; S12 ← P1-T1..P1-T8; S13 ← P7-T1..P7-T4, P7-T8, P7-T9; S14 ← P5-T4, P7-T5..P7-T7; S15 ← P2-T8..P2-T10, P3-T3, P5-T3
  - Acceptance: every S-item is either `[x]` with completed mapped tasks or left `[ ]` with the gap documented in the P7-T11 summary
- [ ] [P6-T2] Check off delivered acceptance criteria in `<FEATURE>/user-story.md` (`## Acceptance Criteria`, items U1–U9), one at a time, each only after the mapped tasks and their verification evidence are complete.
  - Mapping: U1 ← P2-T2, P4-T1; U2 ← P2-T4, P4-T2; U3 ← P2-T4, P2-T7, P2-T10, P4-T2; U4 ← P2-T5, P4-T3; U5 ← P2-T3, P2-T8, P2-T9; U6 ← P2-T6, P2-T8; U7 ← P2-T5, P2-T8; U8 ← P5-T1, P5-T3; U9 ← P3-T1, P3-T3, P4-T4
  - Acceptance: every U-item is either `[x]` with completed mapped tasks or left `[ ]` with the gap documented in the P7-T11 summary

### Phase 7 — Final QA Loop, Coverage Evidence, and Confinement Verification

Loop rule for this phase: if any command in P7-T1..P7-T7 fails or changes files, fix, restart that language's loop from its formatting step, and re-record the affected artifacts. No `SKIPPED` outcomes are authorized for any task in this phase.

- [ ] [P7-T1] Run Python formatting and record evidence.
  - Command: `poetry run black .`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-format.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0; no file changes on the final pass
- [ ] [P7-T2] Run Python linting and record evidence.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-lint.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0, zero findings
- [ ] [P7-T3] Run Python type-checking and record evidence.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-typecheck.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0, zero errors
- [ ] [P7-T4] Run Python tests in coverage mode and record numeric post-change coverage.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-test-coverage.md`; `Output Summary:` MUST include numeric post-change line and branch coverage percentages and the per-module coverage for `scripts/dev_tools/parallel_mutation_protocol.py`, `scripts/dev_tools/_parallel_mutation_models.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, and `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (no placeholders)
  - Acceptance: all tests pass; numeric values recorded
- [ ] [P7-T5] Run PowerShell formatting and record evidence.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_format`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-format.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0; no file changes on the final pass
- [ ] [P7-T6] Run the PowerShell analyzer and record evidence.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-analyze.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0, zero findings
- [ ] [P7-T7] Run PowerShell Pester tests in coverage mode and record numeric post-change coverage.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`; `Output Summary:` MUST include pass/fail counts and the numeric line coverage percentage, including coverage of `.claude/hooks/enforce-parallel-abandon-gate.ps1` (no placeholders)
  - Acceptance: all tests pass; numeric coverage recorded
- [ ] [P7-T8] Verify the coverage delta and thresholds against the Phase 0 baselines.
  - Compare `<FEATURE>/evidence/baseline/baseline-py-test-coverage.md` and `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md` against `<FEATURE>/evidence/qa-gates/final-py-test-coverage.md` and `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`; report baseline coverage, post-change coverage, and new/changed-code coverage per language; confirm line >= 85% and branch >= 75% for the Python modules named in P7-T4 and no coverage regression on changed lines
  - Artifact: `<FEATURE>/evidence/qa-gates/coverage-delta-verification.md` (`Timestamp:`, the three numeric coverage figures per language, threshold verdicts)
  - Acceptance: all thresholds met with numeric evidence; if any required value is unavailable or below threshold, the outcome is remediation-required and MUST NOT be reported as PASS
  - AC: S13, S14
- [ ] [P7-T9] Verify the 500-line cap on every new production and test file.
  - Files: `scripts/dev_tools/parallel_mutation_protocol.py`, `scripts/dev_tools/_parallel_mutation_models.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`, `.claude/hooks/enforce-parallel-abandon-gate.ps1`, `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`, `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`, `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`, `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`, `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` (plus `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` if created by the P2-T8 split branch)
  - Artifact: `<FEATURE>/evidence/qa-gates/file-size-cap-verification.md` (`Timestamp:`, `Command:` = the line-count command used, `EXIT_CODE:`, `Output Summary:` = per-file line counts)
  - Acceptance: every listed file <= 500 lines
  - AC: S13
- [ ] [P7-T10] Verify shared-file confinement and the additive-only constraint from the branch diff.
  - Checks: `git diff --stat` against the integration branch base shows no modified file under `.claude/hooks/enforce-epic-*`, no modified epic skill/agent/validator, and no change to any F3 schema definition; `git diff .claude/skills/parallel-orchestrate/SKILL.md` contains only one appended section (P4-T4); `git diff scripts/dev_tools/validate_parallel_orchestrator_state.py` contains exactly one added import line and one added call line; `git diff .claude/settings.json` contains exactly one added Bash-matcher hook entry; no `mutations[]` field or state/merge-status enum value added anywhere
  - Artifact: `<FEATURE>/evidence/qa-gates/wave4-confinement-verification.md` (`Timestamp:`, `Command:` for each diff, `EXIT_CODE:`, `Output Summary:` = per-check verdicts)
  - Acceptance: every check passes; any violation is remediation-required
  - AC: S11
- [ ] [P7-T11] Record the acceptance-criteria status summary.
  - Content: the `### Acceptance Criteria Status` block per `.claude/skills/acceptance-criteria-tracking/SKILL.md` for both `<FEATURE>/spec.md` (15 items) and `<FEATURE>/user-story.md` (9 items): source, total, checked off, remaining, and the list of any unchecked criterion texts with documented gaps
  - Artifact: `<FEATURE>/evidence/qa-gates/ac-status-summary.md` (`Timestamp:`, both status blocks)
  - Acceptance: artifact exists; every unchecked item has a documented gap; a fully delivered feature shows 15/15 and 9/9 checked
