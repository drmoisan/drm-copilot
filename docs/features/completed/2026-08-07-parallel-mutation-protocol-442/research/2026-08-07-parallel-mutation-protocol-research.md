# parallel-mutation-protocol (Issue #442) — Research

- Date: 2026-08-07
- Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/`
- Epic: `parallel-orchestration` (child feature F6, wave 4)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (§8, §9 abandon gate; upstream structures §5, §6, §11, §12)
- Epic manifest: `docs/features/epics/parallel-orchestration/epic.md`
- Status: Research complete

## Summary

F6 delivers dynamic membership for a live parallel run: `/parallel-add`, `/parallel-remove`,
`/parallel-close`, admission control, the pinning invariant, the item lifecycle, the mutation
log, mode-dependent completion semantics, and the abandon gate. Verified findings:

1. **None of the upstream features (F1–F5) have landed in this worktree.** No
   `scripts/dev_tools/*parallel*` file, no `.claude/skills/parallel-*` skill, no
   `.claude/agents/parallel-orchestrator.md`, no `docs/features/parallel/` home, and no sibling
   F5/F7/F8 feature folder exists (verified by glob over `scripts/dev_tools/`, `.claude/skills/`,
   `.claude/agents/`, and `docs/features/`). Every upstream contract cataloged below is therefore
   marked **expected, not yet landed** and derived from the design document and epic manifest.
   The spec/plan phase must re-verify each against the integration branch once waves 0–3 merge.
2. **The epic surfaces provide near-verbatim prior art for every F6 mechanism**: deterministic
   pure-function scheduling with a tested reference implementation
   (`scripts/dev_tools/epic_wave_computation.py`), deny-with-reason PreToolUse hooks with
   injectable read seams and dot-source guards (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`,
   `.claude/hooks/enforce-epic-invocation-origin.ps1`), append-only literal-error validators
   decomposed into `_orchestrator_state_*.py` helper modules
   (`scripts/dev_tools/validate_epic_orchestrator_state.py`), cross-language config-truth-table
   parity tests (`tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`), and the
   slash-command skill convention (`.claude/skills/epic-run/SKILL.md` frontmatter).
3. **Recommended approach**: implement the mutation protocol as a pure-Python engine
   (`scripts/dev_tools/parallel_mutation_protocol.py`) whose recolor, admission, removal, close,
   and completion decisions are pure functions over checkpoint data; expose the three slash
   commands as three fork-routed skill folders targeting the `parallel-orchestrator` agent;
   implement the abandon gate as a textual PreToolUse Bash hook; and add the mode-dependent
   completion and mutation-log invariants to the F3-owned validator via one new
   `_parallel_orchestrator_state_mutations.py` helper module with a single additive call site.
4. **Two policy-relevant gaps found**: `hypothesis` is not currently a dev dependency
   (`pyproject.toml` `[tool.poetry.group.dev.dependencies]` contains only `pytest` and
   `pytest-cov`), although the repository test policy names it for property tests on T1/T2 pure
   functions; and `quality-tiers.yml` does not exist at the repo root (already recorded as F1's
   known constraint in the epic). Both are recorded under Risks and Open Questions.

## Upstream Contracts

### Landed (verified in this worktree)

| Contract | Location | Evidence |
| --- | --- | --- |
| `route_id: preparation` child-run contract, reused unchanged by `/parallel-add` step 2 | `config/orchestration-routing.json` (route defined at line 79: `requires_ci_gate: false`; required agents `task-researcher`, `prd-feature`, `atomic-planner`, `atomic-executor`) and `.claude/skills/epic-plan/SKILL.md` lines 97–122 | Verified by read. The literal preparation-mode kickoff line and the terminal state contract (`completed_steps` containing `S3_promotion` and `S4_atomic_planning`, `next_step: "S5_atomic_execution"`, out-of-scope statuses `not-applicable`) are specified at `.claude/skills/epic-plan/SKILL.md:99` and lines 119–122. `/parallel-add` reuses this contract verbatim for preparing a proposed item. |
| Slash-command skill convention | `.claude/skills/epic-run/SKILL.md` lines 1–7, `.claude/skills/epic-orchestrate/SKILL.md` lines 1–7 | Frontmatter fields `name`, `description`, `argument-hint`, `context: fork`, `agent: <agent-name>`; `$ARGUMENTS` placeholder in the body. |
| PreToolUse hook registration surface | `.claude/settings.json` (`PreToolUse` → `Bash` matcher registers `enforce-epic-merge-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` at lines 112–117; `Agent` matcher registers `enforce-epic-wave-barrier.ps1` and `enforce-epic-invocation-origin.ps1` at lines 178–187) | The abandon gate registers here as an additive Bash-matcher entry. |
| Validator convention (literal error strings, helper-module decomposition, no input mutation, 500-line cap) | `scripts/dev_tools/validate_epic_orchestrator_state.py` lines 10–13 (convention statement), 21–33 (helper-module imports), 85–89 (error-string style) | The F6 validator contribution follows this convention. |
| Evidence and timestamp conventions | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Timestamp format `yyyy-MM-ddTHH-mm`; evidence under `<FEATURE>/evidence/<kind>/` only. |

### Expected, not yet landed (derive from design; re-verify at planning time)

All of the following were searched for and are absent from this worktree. Source for each
expected shape: design document section cited.

| Feature | Expected contract F6 consumes | Source |
| --- | --- | --- |
| F1 | `conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`, fail-closed, in `scripts/dev_tools/compute_blast_radius.py` with PowerShell mirror `.claude/lib/blast-radius/BlastRadius.psm1` and a config truth table. F6's admission step 3 computes conflict edges "against all items, including in-flight ones" using this relation. | §5.4, §8.3 |
| F2 | Deterministic greedy Welsh-Powell coloring in `scripts/dev_tools/parallel_cohort_computation.py`: vertices sorted by descending degree, ties broken by ascending item key; `max_concurrency` slot-filling in ascending item key; parity test. F6's recolor of the unstarted subgraph must delegate to this function, not reimplement it. | §6 |
| F3 | Checkpoint schema at `artifacts/orchestration/parallel-orchestrator-state.json` incl. `route_id: "parallel"`, `mode`, `max_concurrency`, `current_cohort`, `recolor_generation`, `cohorts[]` (`{ index, generation, item_keys[] }`), `items[]` (state enum `proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked`, per-item `merge_status` enum incl. `worktree_removed`), `conflict_edges[]` (`{ a, b, reason }`), `mutations[]` (`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`), `drift_events[]`; validator `scripts/dev_tools/validate_parallel_orchestrator_state.py`; manifest `docs/features/parallel/<slug>/parallel.md` with `issue_num` primary key and no `depends_on`. **F3 owns all schema fields; F6 populates `mutations[]`, `recolor_generation`, `cohorts[].generation`, and item `state` transitions but adds no fields.** | §8.6, §11, §12; epic wave-4 contention note |
| F5 | `parallel-orchestrator` agent (`.claude/agents/parallel-orchestrator.md`), `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, cohort scheduling and fan-out, per-item merge to `main`, `parallel-status.md` projection. The epic states F5 is expected to reserve named placeholder sections for wave-4 extenders; **no reserved section names can be cited because F5's spec has not landed** — the proposed section name below must be re-verified verbatim once F5 merges. | §10 F5; epic wave-4 contention note |

Every row in the second table is a derived expectation. If any landed shape differs (function
names, field names, section headings), the F6 spec and atomic plan must follow the landed shape,
not this table.

## Recommended Approach

Two candidate implementation shapes were compared:

**A (recommended) — pure-Python mutation engine plus thin skill/hook surfaces.** All decision
logic (admission, per-state removal behavior, close gating, recolor of the unstarted subgraph,
generation accounting, mutation-log entry construction, mode-dependent completion predicate)
lives in a new pure module `scripts/dev_tools/parallel_mutation_protocol.py`, patterned on
`epic_wave_computation.py` (pure function over caller-supplied mappings, no file I/O, dedicated
exception types). The `parallel-orchestrate` SKILL gains one new named section documenting the
procedure; the three slash commands are procedure-framing skills; the validator gains one helper
module. Rationale: the epic's NFR requires deterministic, testable scheduling with a reference
implementation "in the manner of `epic_wave_computation.py`"; the pinning invariant is exactly
the kind of correctness property this repository proves with pure functions and pytest, and the
85%/75% coverage floors are only reachable when logic is host-neutral.

**Rejected alternatives (brief).** (B) Prose-only protocol in the SKILL with the orchestrator
applying it ad hoc: fails the epic NFR that identical inputs must produce identical cohort
assignments, and leaves the pinning invariant unprovable by tests. (C) Implementing the mutation
engine in PowerShell: the scheduling reference implementations are Python
(`epic_wave_computation.py`, F2's `parallel_cohort_computation.py`); the recolor function must
call F2's Python function directly, so a PowerShell engine would force a cross-language call or a
reimplementation, which §6 prohibits in spirit (one tested reference implementation).

### Proposed file inventory (F6-owned, all new unless noted)

- `scripts/dev_tools/parallel_mutation_protocol.py` — pure engine (split into a second module if
  the 500-line cap is approached).
- `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` — validator helper: mutation-log
  shape, `recolor_generation` monotonicity, mode-dependent completion invariant. Wired into
  `validate_parallel_orchestrator_state.py` (F3-owned file) by a single additive import and one
  call line, following the `_orchestrator_state_*.py` convention.
- `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`,
  `.claude/skills/parallel-close/SKILL.md` — slash-command skills (see next section).
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` — abandon gate.
- `.claude/settings.json` — additive Bash-matcher hook registration entry (shared surface; see
  Wave-4 Contention Plan).
- `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned file) — one new appended section only.
- Tests: `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`,
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`,
  `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`.

## Prior Art Catalog

| File | Mechanism it demonstrates for F6 |
| --- | --- |
| `scripts/dev_tools/epic_wave_computation.py` | The deterministic-scheduling reference-implementation pattern: a pure function over a caller-supplied mapping (docstring lines 95–98: "This function is pure: it does not read or write any file, and it does not mutate the input"), a dedicated exception type carrying the offending key (`EpicWaveCycleError`, lines 33–69), and module docstring citing the SKILL sections that document the formula (lines 4–9). F6's recolor/admission/completion functions follow this shape. |
| `tests/scripts/dev_tools/test_epic_wave_computation.py` | Test structure for scheduling logic: one behavior per test, literal-dict fixtures, edge cases (empty manifest, self-cycle, three-node cycle, disconnected vertices), exception-message assertion (lines 102–111). |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | The deny-with-reason PreToolUse Bash hook pattern: parse `CLAUDE_TOOL_INPUT` JSON, regex-match the command (line 199), extract arguments (lines 61–64), fail-closed decision (`Test-EpicWorktreeRemovalAllowed`), allow/block decision builders emitting `hookSpecificOutput.permissionDecision` (lines 139–167), reason-code prefix in the deny message (line 220: `EPIC_WORKTREE_REMOVAL_BLOCKED: ...`), injectable read seam so tests never touch the filesystem (`Get-EpicWorktreeGateCheckpointContent`, lines 27–43), and the dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }` (lines 224–226) enabling Pester import without executing the entrypoint. The abandon gate adapts this near-verbatim. |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | Agent-matcher variant: resolving the delegation target `subagent_type` and the caller `agent_type` from `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT` (lines 102–172), gated-target list as a script-scope constant (line 36). Relevant if the abandon gate must also inspect Agent-call prompts; otherwise the Bash-matcher pattern suffices. |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | Hook test pattern: dot-source the hook (lines 9–12), `Mock -CommandName <read seam>` returning literal JSON strings (lines 37–39) — no temp files, no live git — and assertions on `permissionDecision` plus `-Match` on the reason code. |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` + `scripts/dev_tools/_orchestrator_state_*.py` helpers | Validator conventions: returns a list of literal error strings, never mutates input (lines 10–13), stays under 500 lines by delegating key-gated checks to `_`-prefixed helper modules imported at top (lines 21–33), message style `"<Context> checkpoint <field> must ..., found: <value!r>"` (lines 108–113). `.claude/rules/orchestrator-state.md` documents that each additive invariant family lives in its own helper module with one call from the top-level validator — the exact pattern F6, F7, and F8 each use to avoid colliding inside F3's validator file. |
| `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` (lines 1–26) and `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` | Cross-language parity pattern: both language implementations pin their embedded constants to `config/orchestration-routing.json` as the single truth table, file-read-only, no external process. F6 itself has no PowerShell mirror of the recolor function (F2 owns the scheduler and its parity), but the disposition/state-behavior table could be parity-pinned this way if F7/F8 need it from PowerShell. |
| `.claude/skills/epic-orchestrate/SKILL.md` | The orchestrator-skill document structure F5 will mirror: named `##` sections per concern (Wave Assignment, Wave Barrier, Worktree Cleanup, Completion Requirements), canonical reference-implementation citation (line 88), two-layer enforcement description, and a Completion Requirements section — the analogue F6's mode-dependent completion prose extends on the parallel side. |
| `.claude/agents/epic-orchestrator.md` (frontmatter lines 1–33) | Agent frontmatter shape F5 will mirror: `tools` allowlist including `"Bash(git *)"` and `"Bash(gh *)"`, preloaded `skills`, `SubagentStop` hook invoking `validate-orchestrator-output.ps1` with `-ArtifactType`. F6 should not need to edit the parallel counterpart (see Slash-Command Surface Conventions). |
| `.claude/skills/epic-plan/SKILL.md` lines 87–122 | The preparation-mode child delegation contract `/parallel-add` reuses unchanged: literal kickoff line (line 99), worktree isolation, terminal checkpoint state, `PREFLIGHT: ALL CLEAR` gate. |

## Slash-Command Surface Conventions

Verified convention: a slash command is a skill folder `.claude/skills/<name>/SKILL.md`. The
user invocation `/name args` routes the SKILL body plus `$ARGUMENTS` into context. Frontmatter
observed on comparable commands (`.claude/skills/epic-run/SKILL.md` lines 1–7):

```yaml
---
name: <kebab-name>
description: <one-line routing description>
argument-hint: "[<arg>]"
context: fork
agent: <agent-name>
---
```

Recommendation for F6:

- Three separate skill folders, one per command: `parallel-add` (`argument-hint:
  "[issue|potential-entry]"`), `parallel-remove` (`argument-hint: "[item] [--disposition
  detach|abandon]"`), `parallel-close` (`argument-hint: "[parallel-slug]"`). One folder per
  command matches the existing surface (`epic-plan`, `epic-run`, `epic-orchestrate` are separate
  folders) and keeps each SKILL body a single procedure.
- Each uses `context: fork` with `agent: parallel-orchestrator`, mirroring `epic-run`. The fork
  resumes against the durable checkpoint (`artifacts/orchestration/parallel-orchestrator-state.json`),
  consistent with the design's statement (§12) that the checkpoint is a cache of durable state
  re-derivable from `git worktree list --porcelain`, `git branch`, and `gh pr view`.
- Because fork-routed skills are injected into the agent's context at invocation, F6 does not
  need to append its skills to the `parallel-orchestrator` agent's frontmatter `skills:` preload
  list — avoiding an edit to the F5-owned agent file. (Precedent: `epic-run` is not in
  `epic-orchestrator`'s preload list; `epic-orchestrate` is.)

## Pinning Invariant and Test Strategy

### The invariant restated as testable contracts

From §8.1: in-flight items are pinned; scheduling is recomputed only over the not-yet-started
subgraph; recoloring is a pure function of `(remaining subgraph, pinned set)`. Proposed engine
signatures (expected shapes; final names set at spec time):

```python
def recolor_unstarted(
    unstarted_items: Sequence[str],            # item keys, state in {proposed..scheduled}
    conflict_edges: Sequence[tuple[str, str]], # full graph; induced subgraph taken internally
    pinned: frozenset[str],                    # item keys with state in_flight
    current_generation: int,
) -> RecolorResult:                            # new cohorts for unstarted items only,
    ...                                        # generation == current_generation + 1

def decide_admission(
    candidate: str,
    conflict_edges: Sequence[tuple[str, str]], # computed over ALL items incl. in-flight
    in_flight: frozenset[str],
) -> AdmissionDecision:                        # ADMIT_CURRENT_COHORT | DEFER_AND_RECOLOR
    ...

def is_closed_mode_complete(items: Mapping[str, ItemRecord]) -> bool: ...
```

Coloring inside `recolor_unstarted` delegates to F2's `parallel_cohort_computation.py`
(Welsh-Powell, descending degree, ascending-item-key tie-break) over the induced unstarted
subgraph; F6 must not reimplement the coloring.

### Test approach (patterned on `test_epic_wave_computation.py` and the parity tests)

Unit tests (pytest, `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`):

1. **Pinned items never move.** Fixture with in-flight items A, B and unstarted C, D, E; assert
   the `RecolorResult` contains no cohort assignment for A or B, and that the checkpoint-level
   apply step leaves `items[A].state`, `items[B].state`, and the current cohort's pinned
   membership byte-identical.
2. **Purity/determinism.** Call `recolor_unstarted` twice with equal inputs; assert equal
   outputs; assert the input sequences/mappings are unmutated (the `epic_wave_computation.py`
   purity contract, lines 95–98, is the precedent for asserting this in the docstring and test).
3. **Generation increments exactly once per recompute.** Each mutation op that triggers a
   recompute (deferred add, remove of an unstarted vertex, drift-induced requeue) yields
   `generation == current + 1`; an op that does not recolor (admission into the current cohort
   with no conflict, in-flight `detach`) leaves the generation unchanged and stamps the current
   generation into its `mutations[]` entry. A sequence of N mutating ops from generation g ends
   at exactly g + (number of recompute-triggering ops).
4. **Admission computed over ALL items including in-flight.** Candidate X conflicting only with
   in-flight item A is deferred (even though A is not in the recolor subgraph); candidate Y
   conflicting only with unstarted item C is admitted or cohort-assigned by the coloring, not
   rejected; candidate Z with no conflicts is admitted into the current cohort with no
   generation change.
5. **Removal behavior table (§8.4), one test per row**, including rejection without disposition
   for `in_flight` and rejection for `merged`; disposition never defaulted.
6. **Close gating (§8.5)**: rejected while any item is `in_flight`; terminates `open` mode
   otherwise; `closed`-mode completion predicate fires only when every non-withdrawn item is
   `merged` or `worktree_removed` (parametrized over the `merge_status` enum).
7. **Mutation-log shape**: every op appends exactly one `mutations[]` entry with the seven §8.6
   fields; `at` supplied via an injectable clock parameter (`clock: Callable[[], datetime]`
   seam per `.claude/rules/python.md`), never wall-clock inside the engine.

Property-based tests (T1/T2 obligation: >= 1 property test per pure function):

- **Property P1 (determinism):** for arbitrary conflict graphs and arbitrary partitions into
  pinned/unstarted sets, `recolor_unstarted(x) == recolor_unstarted(x)` and the result assigns
  every unstarted vertex to exactly one cohort and no pinned vertex to any cohort.
- **Property P2 (independent-set validity):** no two items in the same recolored cohort share a
  conflict edge.
- **Property P3 (pin stability under mutation sequences):** for an arbitrary sequence of
  add/remove ops, items that were in-flight at op time never change cohort or state as a result
  of the op.
- **Tooling caveat (verified):** `hypothesis` is not in `pyproject.toml`
  (`[tool.poetry.group.dev.dependencies]` lists only `pytest >= 7.0` and `pytest-cov >= 7.0`;
  a repo-wide grep for `hypothesis` in `*.py` matches only the unrelated field name
  `business_outcome_hypothesis`). The test policy (`.claude/rules/general-unit-test.md`,
  Test Categories) names `hypothesis` for Python property tests "where applicable", while
  `.claude/rules/python.md` prohibits adding dependencies without explicit instruction. See
  Risks and Open Questions; the fallback is seeded-RNG randomized graph generation via
  `random.Random(seed)` with the seed printed on failure, which the determinism-infrastructure
  rules permit.

Hook tests (Pester, `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`):
adapt `enforce-epic-worktree-removal-gate.Tests.ps1` — dot-source, literal-JSON payloads,
assert deny with reason code (proposed `PARALLEL_ABANDON_BLOCKED`) when the command text carries
`--disposition abandon` without the confirmation marker, allow when the marker is present, allow
for out-of-scope commands, throw on malformed JSON.

## Wave-4 Contention Plan

F6 executes concurrently with F7 (`parallel-enforcement-hooks`) and F8
(`parallel-drift-detection`). The epic's wave-4 contention note is a decomposition constraint:
edits to shared files must be confined to a distinct, explicitly named new section, with no
reflow or reorder of existing sections, and no schema-field additions (F3 owns the complete
checkpoint schema including `mutations[]`, `drift_events[]`, `conflict_edges[]`).

F5's spec has not landed, so no reserved placeholder section names can be cited verbatim.
Proposed reservations for F6 — to be re-verified against F5's landed SKILL before planning:

| Shared file | F6's confinement | Expected F7/F8 sections (for non-collision awareness) |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned) | Append one new section, proposed name `## Mutation Protocol`, containing the add/remove/close procedures, pinning invariant, mutation-log and completion semantics, and pointers to the three slash-command skills. Append-only; no edits inside existing sections. | F7: cohort-barrier/enforcement section; F8: drift-detection section. |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned) | One additive import plus one call line delegating to the new F6-owned module `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`. All F6 invariant logic lives in the helper module, mirroring how `validate_orchestrator_state.py` delegates to `_orchestrator_state_complexity.py` etc. (documented in `.claude/rules/orchestrator-state.md`, Enforcement). | F7 Layer-2 cohort-ordering invariant and F8 drift invariants each add their own helper module and call line. |
| `.claude/settings.json` | One additive entry in the existing `PreToolUse` → `Bash` matcher `hooks` array registering `enforce-parallel-abandon-gate.ps1` (pattern: lines 112–117 register the epic Bash-matcher gates). | F7 registers `enforce-parallel-cohort-barrier.ps1` (Agent matcher) and `enforce-parallel-worktree-removal-gate.ps1` (Bash matcher) in the same arrays — a same-array append collision is likely; merges are textually mechanical but should be anticipated. |

Restated rules F6 must honor: no reflow or reorder of existing sections in any shared file; no
schema-field additions anywhere (F6 populates `mutations[]`, item `state`, `recolor_generation`,
and `cohorts[].generation` — all defined by F3); additive only with respect to epic
implementations (no modification of `enforce-epic-*` hooks or epic validators); the surface is
named `parallel` throughout; in-flight removal never infers a default disposition.

## Quality Gates and Toolchain

Languages in scope: Python (engine + validator helper), PowerShell (abandon-gate hook),
Markdown (three skills + one SKILL section).

- **Python** (`.claude/rules/python.md`): Black → Ruff → Pyright → Pytest
  (`poetry run pytest --cov --cov-branch --cov-report=term-missing`), restart on any failure.
  Full type hints; dataclasses (`frozen=True`) for `RecolorResult`/`AdmissionDecision`-style
  value objects; injectable clock seam; docstring policy per
  `.claude/rules/self-explanatory-code-commenting.md` (class/function docstrings, intent
  comments on loops and branches).
- **PowerShell** (`.claude/rules/powershell.md`): PoshQC format → analyze → Pester via the MCP
  commands; PowerShell 7+; advanced functions with `CmdletBinding()`; wrapper-function read
  seams for any filesystem access; hook stays under the 2-production-file direct-mode budget.
- **Coverage**: line >= 85%, branch >= 75%, uniform across tiers; no coverage exclusions for
  production files; hooks are production PowerShell and must be covered by their Pester tests
  (the dot-source-guard pattern exists precisely to make the hook body coverable).
- **File size**: 500-line cap on every production and test file. The epic worktree-removal hook
  is 238 lines and its test ~90+ lines, so the abandon gate fits comfortably; the Python engine
  should be split before approaching the cap.
- **Test locations** (`tests/` mirror, `.claude/rules/general-unit-test.md`): Python engine
  tests at `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`; validator-helper tests
  at `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py` (naming
  precedent: `test_validate_epic_orchestrator_state*.py`); hook tests at
  `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` (precedent: the five
  existing `enforce-epic-*.Tests.ps1` files in that directory).
- **Determinism**: no temp files in tests (mock the hook's read seam with literal JSON); no
  wall-clock reads (clock injection for `mutations[].at`); seeded RNG with printed seed for any
  randomized generation.
- **Property-test obligation**: the mutation engine is scheduling/correctness-critical logic;
  treat it as T1/T2 for property-test density (>= 1 property test per pure function). Tier
  classification interacts with the missing `quality-tiers.yml` (see Risks).

## Automation Feasibility

Assessment: **no step of building or testing F6 requires human interaction.** Evidence:

- All F6 deliverables are repo-local files: Python modules, a PowerShell hook, Markdown skills,
  a settings.json entry, and tests. No external service, credential, or environment beyond the
  existing local toolchain (Poetry/pytest, PoshQC/Pester via MCP) is needed.
- The hook is testable without a live Claude Code session: the epic hook tests drive the
  decision function directly with literal `CLAUDE_TOOL_INPUT` JSON and a mocked read seam
  (verified in `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`).
- The `/parallel-add` preparation-mode child run and `gh pr close` / `git worktree remove`
  side effects of `abandon` are runtime behaviors of a live parallel run, not build/test-time
  requirements; F6 tests them as pure decision functions over checkpoint fixtures, the same way
  the epic validators test merge/wave semantics without invoking `git` or `gh`.
- The only externally-gated event in the feature lifecycle is PR CI on GitHub Actions, which is
  the standard automated S9 path, not human interaction.

## Risks and Open Questions

1. **All upstream contracts are unverified expectations.** Waves 0–3 have not landed in this
   worktree. Highest-impact unknowns: F5's reserved section names in
   `.claude/skills/parallel-orchestrate/SKILL.md`, F2's exact coloring function signature, and
   F3's exact validator module structure and item-state field names. The spec/plan must
   re-verify every "expected, not yet landed" row against the integration branch head.
2. **`hypothesis` is not a dev dependency**, but the test policy names it for T1/T2 property
   tests and the pinning invariant is exactly a property-test target. Options: (a) add
   `hypothesis` to `[tool.poetry.group.dev.dependencies]` — a well-maintained, policy-named
   package, but `pyproject.toml`/`poetry.lock` are lockfile-class shared surfaces (§5.1 level 3)
   and F2 (wave 0) faces the identical obligation first, so the addition should ideally land
   upstream of wave 4; (b) seeded-RNG randomized generation with printed seeds, permitted by the
   determinism rules, requiring no dependency change. Recommendation: check at plan time whether
   F2 already added `hypothesis`; if yes, use it; if no, use (b) and record the deviation.
3. **`.claude/settings.json` append collision with F7.** Both features append entries to the
   same `PreToolUse` hook arrays. Textually mechanical, but the atomic plans should name the
   exact insertion points to keep the wave-4 fan-in merges clean.
4. **`recolor_generation` increment semantics need one spec-level clarification.** §8.6 says the
   generation "increments on each recompute"; §8.3 admission into the current cohort performs no
   recompute. The spec must state explicitly which ops recompute (deferred add, unstarted
   remove, drift requeue) and which do not (no-conflict admit, in-flight detach, close), and
   that non-recomputing ops stamp the current generation into their `mutations[]` entry. The
   acceptance criterion "increments exactly once per recompute" is only testable once this
   boundary is written down.
5. **Live-mutation concurrency.** The issue names the risk that the pinning invariant must hold
   against a concurrently mutating in-flight set. The engine being pure moves the race to the
   checkpoint read-modify-write in the forked slash-command runs. Mitigation to specify: each
   mutation command re-derives durable state (worktree list, branch, `gh pr view`) before
   applying, per §12's cache-not-source-of-truth rule, and the validator's mutation-log
   invariants (monotonic non-decreasing `recolor_generation` across `mutations[]`) make a lost
   update detectable retrospectively. Whether a stronger exclusion (e.g., rejecting mutation
   commands while the parallel-orchestrator is mid-cohort-launch) is needed is an open design
   question for the spec.
6. **Abandon-gate matching surface.** A purely textual Bash-matcher gate (deny
   `--disposition abandon` without a confirmation marker in the same command) is simple and
   fail-closed, but only fires if `abandon` is executed via a Bash command carrying that flag.
   The spec must therefore require that the remove procedure route the abandon disposition
   through a single CLI invocation (proposed: the mutation engine's CLI entry point) so the gate
   has a deterministic match target, mirroring how the worktree-removal gate relies on the
   literal `git worktree remove` command shape.
7. **Tier classification.** `quality-tiers.yml` does not exist at the repo root (verified;
   already F1's known constraint). F6 cannot formally classify its modules until F1 resolves
   this; the plan should treat the engine as T1/T2-rigor regardless, since the uniform coverage
   floors apply either way and the property-test obligation is the only tier-dependent gate at
   stake.
