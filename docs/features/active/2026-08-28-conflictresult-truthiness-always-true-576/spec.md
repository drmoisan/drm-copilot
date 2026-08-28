# 2026-08-28-conflictresult-truthiness-always-true (Spec)

- **Issue:** #576
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T10-10
- **Status:** Draft
- **Version:** 0.1

> Work Mode is `full-bug` (persisted in `issue.md`). This document is the sole acceptance-criteria
> source for the feature. `user-story.md` is deliberately absent: the change is a defect fix on an
> internal library contract and on agent-facing skill prose, with no end-user-facing story.

## Context

The blast-radius conflict relation's result object evaluates truthy unconditionally: `bool(ConflictResult)` is `True` whether or not a conflict was found. A caller writing the natural `if conflicts(a, b, config):` therefore treats every item pair as conflicting. This happened in production during the critical-bug-fixes parallel run: item #559 appeared to conflict with every other item until the caller was corrected to test the result's explicit field.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry toolchain
- Command/flags used: `conflicts(a, b, config)` from the facade module compute_blast_radius.py under scripts/dev_tools (relation defined in `scripts/dev_tools/_blast_radius_conflicts.py`) used in a boolean context
- Data source or fixture: item #559 admission during the critical-bug-fixes parallel run (2026-08-26)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Miscomputed conflict edges do not corrupt state — the recolor is a pure function and the checkpoint validator accepts any well-formed edge set — but they silently destroy concurrency (every admission defers) and misrepresent the contention graph the operator reads.

## Repro & Evidence

Steps to Reproduce:
1. Call `conflicts(a, b, config)` for two items with provably disjoint blast radii.
2. Evaluate the returned object in a boolean context: `if conflicts(a, b, config): ...`.
3. The branch is taken: the result object has no `__bool__`/`__len__`, so Python's default object truthiness makes every result truthy.

Expected:
`bool(result)` equals the verdict the result carries. The PowerShell mirror cannot express that behavior (see Root Cause Analysis), so parity is achieved by recording and pinning the divergence rather than by removing it.

Actual:
Default object truthiness: every result is truthy. During #559's admission the orchestrator's edge computation used the boolean form and derived a conflict edge to every other item, which would have serialized the entire run behind #559. The error was caught by re-deriving edges from the result's explicit field; the incident is recorded in the run checkpoint receipts.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: recorded in `artifacts/orchestration/parallel-orchestrator-state.json` receipts (the #559 conflict-edge correction).

Confirmed defect facts (established in research; not to be re-derived):
- `ConflictResult` is declared at `scripts/dev_tools/_blast_radius_conflicts.py:94-134`. Its only method is `__post_init__` at line 114. `@dataclass(frozen=True)` generates `__init__`, `__repr__`, `__eq__`, `__hash__`, and the frozen attribute blockers, and generates neither `__bool__` nor `__len__`.
- The relation itself is correct. Line 177 returns `ConflictResult(conflict=bool(reasons), reasons=tuple(reasons))`, and lines 124-125 already validate at construction that `conflict` equals `bool(reasons)`. Only the boolean projection is wrong.
- The caller inventory contains no defective call site. The single production caller, the drift-detection module parallel_drift_detection.py under scripts/dev_tools at line 499, already reads `.conflict`. Every test call site reads `.conflict` or `.reasons`. Bash and hook code consumes the pre-computed `conflict_edges[]` array and never invokes the relation. The fix is therefore behavior-preserving for every existing in-repo caller.
- The facade module compute_blast_radius.py under scripts/dev_tools re-exports the same class object at lines 35-39, so a `__bool__` added in the private module propagates without any edit to the facade.

## Scope & Non-Goals

### In scope

1. Define `__bool__` on `ConflictResult` in `scripts/dev_tools/_blast_radius_conflicts.py`, returning `self.conflict`.
2. Record the PowerShell truthiness divergence in the comment-based help of `Test-BlastRadiusConflict`, and pin it with a Pester assertion.
3. Correct the skill prose that instructs an agent how to read the contention verdict, in `.claude/skills/parallel-add/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md`.
4. Mirror every `.claude/` edit into the bundled push-down copy under `extensions/drm-copilot/resources/claude-customizations/`.
5. Add Python and Pester tests covering the new behavior and the pinned divergence.

### Out of scope / non-goals

1. **`ConflictReason` does not receive `__bool__`.** The record carries no verdict — its own docstring at `scripts/dev_tools/_blast_radius_conflicts.py:66-68` states that `ConflictResult` carries the verdict — and both of its fields are non-empty by construction (`kind` must be a member of `CONFLICT_KINDS`, `detail` passes `require_text`). There is no state a boolean could distinguish, so any `__bool__` would either be a constant `True` carrying no information or would invent semantics the type does not have. Line 124 evaluates `bool(self.reasons)`, the truthiness of the tuple, not of any `ConflictReason`; leaving `ConflictReason` untouched keeps that reasoning local.
2. **`BlastRadius` is out of scope.** `BlastRadius`, declared at lines 101-218 of the facade module compute_blast_radius.py under scripts/dev_tools, is also a `@dataclass(frozen=True)` with neither `__bool__` nor `__len__`, so `bool(radius)` is likewise unconditionally `True`. Unlike `ConflictReason`, an empty radius does have a meaning the relation acts on: two empty radii do not conflict (`scripts/dev_tools/_blast_radius_conflicts.py:151-152`). This is a genuine latent instance of the same API-design class, but it is a separate change that would widen the write set to the facade module. It is recorded as a follow-up to be filed as its own potential entry (see Rollout & Follow-up) and is deliberately not folded in here.
3. **A raising `__bool__` is rejected.** See Root Cause Analysis for the four reasons.
4. **The TypeScript parity obligation asserted in `issue.md` is struck as factually incorrect.** See Root Cause Analysis for the evidence.
5. **The behavioral truthiness divergence between Python and PowerShell is not removed.** It is recorded and pinned. Neither remedy is expressible in PowerShell without breaking the frozen result contract.
6. No change to the shared JSON fixture corpus under `tests/fixtures/blast_radius/`, and no change to either cross-language parity suite. Truthiness is a property on which the two runtimes provably cannot agree, so a parity assertion on it would assert a falsehood.
7. No change to the blast-radius truth table config/blast-radius.json or its bundled copy. No truth-table content changes.
8. No change to any policy file under `.claude/rules/` or `.github/instructions/`.

### Explicitly excluded systems, integrations, or datasets

| Path | Reason for exclusion |
| --- | --- |
| The facade module compute_blast_radius.py under scripts/dev_tools | The re-export at lines 35-39 binds the same class object; `__bool__` propagates with no facade edit. |
| The drift-detection module parallel_drift_detection.py under scripts/dev_tools | Line 499 already reads `.conflict`; behavior is unchanged by this fix. |
| The PoshQC Pester run-settings file pester.runsettings.psd1 under scripts/powershell/PoshQC/settings | `BlastRadius.psm1` is already registered at line 167, so no run-settings edit is required. The file is additionally a declared shared surface (blast-radius truth table config/blast-radius.json, line 13); writing it would create a `shared_surface_overlap` edge against every concurrent item that touches it. |
| Anything under the extension TypeScript source tree extensions/drm-copilot/src | No TypeScript port of the conflict relation exists. |
| The blast-radius truth table config/blast-radius.json and its bundled copy | Declared shared surfaces; this fix changes no truth-table content. |
| `.claude/rules/parallel-orchestration.md` | A configured mandate-read path (blast-radius truth table config/blast-radius.json, line 21). Writing it would oblige the planner to append the exact concrete path to the declared radius after normalization. The divergence is a property of the library's API, not of the parallel schema the rule file governs; the module comment-based help is the closer home. |

### Why the excluded-path citations in this document are unformatted

Every path this document cites in order to *exclude* it is written in plain prose rather than in
inline code. That is deliberate and must not be "corrected" by re-adding backticks.

Blast-radius derivation harvests path tokens from both the atomic plan and this specification. The
extractor cannot distinguish an exclusion rationale from a write claim, so a backticked out-of-scope
path is admitted into this item's declared radius. Measured extractor behavior, verified in this
worktree on 2026-08-28:

| Form | Harvested into the declared radius |
| --- | --- |
| Single-backtick inline code | Yes |
| Fenced code block (triple backticks) | No |
| Plain prose with no backticks | No |

Before this document was reformatted, the backticked exclusion citations produced a declared radius
carrying the shared surfaces config/blast-radius.json and the PoshQC Pester run-settings file, and
the modules config and poshqc. Both are declared shared surfaces and both modules match broad globs,
so the item acquired a shared-surface and module overlap against essentially every other item in its
parallel run and would have forced the run serial. This item writes none of those files. The failure
class is recorded under the Blast-Radius Contention Doctrine in the parallel-orchestration rule file
under .claude/rules.

The rule for editors of this document: a path this item **writes** keeps its inline-code formatting,
because the declared radius must claim it. A path this item merely **names in order to exclude,
cite, or explain** is written in plain prose. Removing the backticks is sufficient on its own; the
literal path text is retained wherever it aids the reader, because plain prose is not harvested.

## Root Cause Analysis

`ConflictResult` carries the conflict verdict as a field and was never given boolean semantics. With neither `__bool__` nor `__len__` defined, `bool(instance)` falls through to `object.__bool__`, which returns `True` for every non-`None` instance. The API therefore invites a natural-but-wrong call form. This is an API-design defect, not a caller-only error.

### Remedy selected: an agreeing `__bool__`

Define `__bool__(self) -> bool: return self.conflict` inside the `ConflictResult` body, after `__post_init__` (which ends at line 134). Do not also define `__len__`: `__bool__` takes precedence over `__len__`, so defining both is redundant, and a `__len__` would make `ConflictResult` look sized, which it is not.

### Remedy rejected: a raising `__bool__`

The alternative — define `__bool__` to raise, forcing every caller to read `result.conflict` — is rejected for four reasons.

1. **Cross-runtime parity.** PowerShell can express neither remedy as coercion behavior. Under an agreeing `__bool__` the residual divergence is one of *strictness*: Python is correct and PowerShell is permissive. Under a raising `__bool__` the divergence is one of *kind*: identical caller code raises in Python and silently returns the wrong answer in PowerShell. The runtime that would silently return the wrong answer is the one the planner actually runs — `.claude/agents/parallel-planner.md:142-156` routes radius derivation, validation, and the contention relation through `.claude/lib/blast-radius/BlastRadius.psm1` specifically so the planner needs no Python interpreter and no repository checkout. A raising `__bool__` would hard-fail the runtime that is not on the incident path while leaving the runtime that is on the incident path unchanged.
2. **A raising `__bool__` has a broad blast radius of its own.** It does not only break `if result:`. It also breaks `assert result`, `result or default`, `x if result else y`, `any(...)` and `all(...)` over results, `filter(None, ...)`, and truthiness inside comprehensions — including in third-party code, debuggers, and REPL display paths that this repository does not control.
3. **The "fail fast" rule does not direct it.** `.claude/rules/general-code-change.md` states the rule as raising or returning clear, specific errors *when invariants are violated*. Asking a `ConflictResult` whether it represents a conflict violates no invariant: the object holds a total, already-validated answer in `self.conflict` (validated at lines 124-125). Converting a well-defined query into an error over-extends the rule.
4. **Zero migration cost either way, so the caller inventory does not decide it.** No in-repo caller relies on unconditional truthiness, established by three repository-wide content searches across Python, PowerShell, TypeScript, bash, hooks, Markdown, and JSON. The aggregate caller-edit count is zero under both remedies, which is why reasons 1 through 3 are the deciding ones.

Under the selected remedy the module's own fail-closed doctrine (`scripts/dev_tools/_blast_radius_conflicts.py:17-23`) is satisfied at the call site rather than deferred to a crash: `if conflicts(a, b, config):` yields exactly the fail-closed verdict, including `True` for the undecidable glob pairs the doctrine exists to protect.

### Why the PowerShell mirror can express neither remedy

`Test-BlastRadiusConflict` is defined at `.claude/lib/blast-radius/BlastRadius.psm1:404-474`. It returns a two-key `[hashtable]`:

```powershell
return @{
    conflict = ($reason.Count -gt 0)
    reasons  = @($reason.ToArray())
}
```

`System.Collections.Hashtable` implements `IDictionary` and `ICollection` but not `IList`. PowerShell's count-based truthiness rules apply only to `IList` implementations, so a hashtable falls under the "any other non-collection type" rule and is unconditionally `$true`. Single-element array unrolling does not rescue the case: the single-element rule evaluates the truthiness of the one element, which is the hashtable.

*Refusal is unrepresentable.* PowerShell's boolean conversion is total and exposes no user hook — no overridable method, operator, or attribute — by which a type can decline the conversion or raise from it.

*Agreement is representable only at an unacceptable price.* The only lever the rules expose is the `IList` branch, which would require returning a collection whose length encodes the verdict. That would break, simultaneously:

- the declared `[OutputType([hashtable])]` at `.claude/lib/blast-radius/BlastRadius.psm1:433`;
- the `.OUTPUTS` contract at `.claude/lib/blast-radius/BlastRadius.psm1:428-430`;
- the frozen public result shape recorded at line 135 of spec.md in the originating feature folder docs/features/active/2026-08-07-parallel-blast-radius-447;
- the key-set assertion at `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:65`;
- every `['conflict']` and `['reasons']` indexing caller; and
- the `reasons` payload the cohort audit requires, since invariant 15 of `.claude/rules/parallel-orchestration.md` demands a reason on every conflict edge.

The divergence is therefore **recorded and pinned, not removed**. This follows the repository's own precedent: `.claude/rules/parallel-orchestration.md` names three TypeScript divergence classes in prose under an explicit verified-scope heading rather than pretending they do not exist.

### Why the TypeScript parity obligation is struck

`issue.md:33` asserts that the chosen remedy "must be mirrored in the PowerShell port ... and the TypeScript parity surface so all three runtimes agree." **No TypeScript port of the conflict relation exists.** Recorded here explicitly so a reviewer does not read the omission as a gap.

- A search for `ConflictResult`, `conflicts(`, `function conflicts`, and conflict-named exports across the extension TypeScript source tree extensions/drm-copilot/src returns exactly one match: `export function validateConflictEdges(` at line 416 of parallel-state-structures.ts under extensions/drm-copilot/src/lib/validate. That function validates already-computed checkpoint edge records against invariant 15. It takes no `BlastRadius`, computes no relation, and returns error strings rather than a verdict.
- A case-insensitive search for `conflict` across the extension TypeScript source tree extensions/drm-copilot/src returns seven files, every one a checkpoint validator consuming `conflict_edges[]` as data. None derives an edge.
- `.claude/rules/parallel-orchestration.md` enumerates the TypeScript parity port file by file and scopes it to the checkpoint validators. The blast-radius library is not in that list.
- The module claude-blast-radius-derive-core.ts under extensions/drm-copilot/src/lib/push-down is blast-radius-named but computes a destination module map from the destination's own layout. It is not the conflict relation.
- The originating feature spec, at line 137 of spec.md in docs/features/active/2026-08-07-parallel-blast-radius-447, records the two-language intent: the PowerShell mirror exists because the Layer 1 enforcement hooks and the cohort-barrier hook are PowerShell. No TypeScript consumer is named.

The contention relation is a two-runtime surface: Python (authoritative) and PowerShell (mirror).

### The proximate cause of the #559 incident is skill prose, not the Python dunder

The incident occurred on the PowerShell/agent path, where no Python `__bool__` is ever evaluated. A Python-only fix would touch nothing on the incident surface.

- `.claude/skills/parallel-add/SKILL.md`, step 3, instructs the agent to invoke `Test-BlastRadiusConflict` over item pairs and then to map "each conflicting pair" onto a normalized `(int, int)` conflict edge. It specifies the two radius arguments and the config argument in detail but never states how to read the verdict off the returned hashtable. An agent must infer it, and the natural PowerShell inference is unconditionally true.
- `.claude/skills/parallel-plan/SKILL.md` has the same gap in two places: the seeding procedure, which says to derive the conflict edge set by applying `Test-BlastRadiusConflict` to every unordered pair of declared radii without stating how the verdict is read; and the contention contract, which documents the Python signature and the reason vocabulary without stating that the verdict is the `conflict` field.
- The same skill already carries the analogous warning for the *sibling* function `Test-BlastRadius`, which must be wrapped in `@(...)` because a zero-element pipeline result writes nothing. That warning exists precisely because `Test-BlastRadius` returns an `IList`-shaped result where emptiness is falsy. The skill warns about the first function and is silent about the second.

Correcting this prose is therefore in scope and is the part of the change that closes the recurrence path.

## Proposed Fix

### Design summary (what changes where)

| Layer | Change |
| --- | --- |
| Python library | `ConflictResult` gains `__bool__` returning `self.conflict`. |
| PowerShell library | `Test-BlastRadiusConflict` comment-based help gains a warning that the returned hashtable is unconditionally truthy and that callers must read the `conflict` key. No behavioral change. |
| Skill prose | Both parallel skills gain an explicit instruction to read the verdict from the `conflict` key (PowerShell) or the `conflict` field (Python), with a one-line statement of why the boolean form is wrong. |
| Push-down mirrors | Each edited `.claude/` file receives the identical edit in its bundled copy. |
| Tests | Python unit assertions on the boolean projection, a parametrized agreement matrix, a Pester assertion pinning the PowerShell divergence, and a Pester assertion on the help text. |

### Boundaries and invariants to preserve

- The relation's verdict logic is unchanged. Line 177 and the construction validation at lines 124-125 are not touched.
- The PowerShell result shape stays exactly `@{ conflict; reasons }`. The key-set assertion at `BlastRadius.Conflict.Tests.ps1:65` must continue to pass unmodified.
- `[OutputType([hashtable])]` at `BlastRadius.psm1:433` is unchanged.
- Every existing `.conflict` / `.reasons` and `['conflict']` / `['reasons']` caller keeps its current behavior. No caller edit is required anywhere in the repository.
- The shared JSON fixture corpus and both cross-language parity suites are unchanged.
- `__len__` is not defined on `ConflictResult`.

### Dependencies or blocked work

- None. The change has no upstream dependency and blocks nothing.
- `hypothesis` is **not** an approved dependency and appears nowhere in `pyproject.toml`. Adding it is prohibited by `.claude/rules/python.md` ("Adding new dependencies without explicit user instruction"). Any property-style test must use a `pytest.mark.parametrize` matrix over the existing `RADIUS_PAIRS` fixture in `tests/scripts/dev_tools/test_blast_radius_invariants.py`, or seeded `random` following the existing `*_properties.py` precedent whose Ruff `S311` suppressions are declared at `pyproject.toml:109-111`.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

Production:

| Path | Change |
| --- | --- |
| `scripts/dev_tools/_blast_radius_conflicts.py` | Add `__bool__` to `ConflictResult` after `__post_init__`. Optionally extend the class docstring. |
| `.claude/lib/blast-radius/BlastRadius.psm1` | Comment-based help only. Extend the `.OUTPUTS` and/or `.DESCRIPTION` of `Test-BlastRadiusConflict` with the truthiness warning. The return statement is unchanged. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` | Identical mirror of the preceding row. |
| `.claude/skills/parallel-add/SKILL.md` | Step 3: state explicitly that the verdict is read from the `conflict` key of the returned hashtable, and that the hashtable itself is always truthy. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` | Identical mirror. |
| `.claude/skills/parallel-plan/SKILL.md` | Seeding procedure and contention contract: the same explicit verdict-access instruction on both the PowerShell and Python sides, alongside the existing `@(...)` warning for `Test-BlastRadius`. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | Identical mirror. |

Tests:

| Path | Change |
| --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | Boolean-projection unit assertions, placed beside the existing `ConflictResult` construction-invariant block so the record-type guarantees stay together. |
| `tests/scripts/dev_tools/test_blast_radius_invariants.py` | A `pytest.mark.parametrize` agreement case over the existing ten-entry `RADIUS_PAIRS` matrix, which already spans disjoint, single-level, multi-level, glob-decided, and both empty-radius cases. No new fixture data. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | Two new `It` blocks inside `Describe 'Test-BlastRadiusConflict result shape'`: one pinning the truthiness divergence, one asserting the help text carries the warning. |

All three source/bundled pairs are byte-identical today; SHA-256 prefixes were compared on 2026-08-28 for `BlastRadius.psm1`, `parallel-add/SKILL.md`, and `parallel-plan/SKILL.md`, and each pair matched. Every `.claude/` edit must therefore land in the same commit as its mirror.

#### Functions/classes/CLI commands impacted

- `ConflictResult` (`scripts/dev_tools/_blast_radius_conflicts.py`): gains `__bool__`.
- `Test-BlastRadiusConflict` (`.claude/lib/blast-radius/BlastRadius.psm1`): comment-based help only.
- No CLI command, MCP tool, hook, or checkpoint schema is affected.

#### Data flow and validation changes

None. No persisted artifact changes shape. Conflict edges written to the parallel-orchestrator checkpoint keep exactly the form invariant 15 of `.claude/rules/parallel-orchestration.md` requires.

#### Error handling and logging updates

None. `__bool__` raises nothing and logs nothing. The rejected alternative was the only variant that would have introduced an error path.

#### Rollback/feature-flag considerations

Not applicable. The change is additive and behavior-preserving for every existing caller, so rollback is a plain revert with no data or state migration.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- `ConflictResult.__bool__(self) -> bool` returns `self.conflict`. It takes no argument beyond `self`, performs no I/O, and has no branches.
- `Test-BlastRadiusConflict` output is unchanged: a `[hashtable]` with exactly the keys `conflict` (a `[bool]`) and `reasons` (an array of hashtables with keys `kind` and `detail`).

#### Required configuration keys and defaults

None. The relation reads no truth-table key, and no configuration key is added or read.

#### Backward-compatibility expectations

- Adding `__bool__` is additive. No existing caller relies on unconditional truthiness, so no observable behavior changes for any in-repo caller.
- Construction of `ConflictResult` literals as test doubles is unaffected.
- The PowerShell result contract is frozen and is not touched.

#### Performance constraints (latency/throughput/memory)

None beyond the existing budget. `__bool__` is a single attribute read. The change removes no work and adds no allocation.

## Assumptions, Constraints, Dependencies

Assumptions:
- The repository Poetry environment can run `black`, `ruff`, `pyright`, and `pytest`.
- The PoshQC MCP tools are available for format, analyze, and Pester test.
- The bundle-parity test can fail locally on gitignored `.claude` state while passing in CI (repository issue #510). A failure naming a path unrelated to this fix must be checked against that pre-existing condition before being treated as a regression introduced here.

Constraints:
- `hypothesis` must not be added.
- No policy file under `.claude/rules/` or `.github/instructions/` may be modified.
- The PowerShell change budget in `.claude/rules/powershell.md` permits at most three production and three test PowerShell files per batch. This change touches two production `.psm1` files and one `.Tests.ps1` file, which is within budget.
- No production file may exceed 500 lines. The comment-based-help addition must be checked against that limit for both `BlastRadius.psm1` copies before commit.

Dependencies:
- None external.

### Tier classification and its consequences

`quality-tiers.yml` does not exist at the repository root. This is a known, pre-existing repository condition, not something introduced by this branch. No tier is therefore assigned to `scripts/dev_tools/_blast_radius_conflicts.py` or to `.claude/lib/blast-radius/BlastRadius.psm1`, and the tier-dependent obligations are exempt. The exemptions are recorded explicitly rather than left implied:

| Obligation | Applies | Value |
| --- | --- | --- |
| Format check | Yes (uniform) | 100 percent pass |
| Lint errors | Yes (uniform) | 0 |
| Type errors | Yes (uniform) | 0 for Python; not applicable to PowerShell |
| Architecture violations | Yes (uniform) | 0 |
| Line coverage | Yes (uniform, both languages) | at least 85 percent |
| Branch coverage | Yes for Python only | at least 75 percent. PowerShell is exempt because Pester does not measure branch coverage. |
| No regression on changed lines | Yes (uniform) | required |
| Property-test density | **No** — T1/T2 only, and no tier is assigned | Exempt. The parametrize matrix is added on its merits, not to satisfy this obligation. |
| Mutation score | **No** — T1 only | Exempt |
| Golden/snapshot tests | **No** — T1 classifier-output only | Exempt |
| Untyped escape hatches | **No** — tier-dependent budget | Unconstrained by tier. `.claude/rules/python.md` independently requires avoiding `Any`; `__bool__` introduces none. |
| Contract breaking changes | Not applicable | The change is additive and breaks no caller. |

The exemption is a consequence of an absent classification file, not a reduction of any threshold. The uniform coverage thresholds are unaffected and must be met.

## Data / API / Config Impact

- User-facing or API changes: none. `ConflictResult` gains one dunder; its fields, constructor, equality, hash, and repr are unchanged.
- Data or migration considerations: none. No persisted artifact changes shape.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flag, config schema, MCP input schema, or checkpoint version changes.

## Test Strategy

### Regression tests to add or update

**Python — `tests/scripts/dev_tools/test_blast_radius_conflicts.py`.** This module already owns the relation's behavior and the two record types' construction invariants, and it imports through the facade `scripts.dev_tools.compute_blast_radius`, so a fix in the private module is exercised through the public surface. Add the boolean-projection assertions immediately after the existing construction-invariant block:

- the projection is `False` for a provably disjoint pair;
- the projection is `True` for an overlapping pair;
- the negation form is `True` for a disjoint pair;
- directly constructed `ConflictResult` literals project correctly in both directions;
- `ConflictReason` defines no `__bool__`, pinning the non-goal.

**Python — `tests/scripts/dev_tools/test_blast_radius_invariants.py`.** This module owns the parametrized invariant matrices (symmetry, monotonicity, self-conflict, determinism, V1 self-consistency). Add a `pytest.mark.parametrize` case over the existing `RADIUS_PAIRS` asserting that the boolean projection equals the `conflict` field for every pair. This satisfies the issue's "property test over generated radii" item within the repository's approved dependency set.

**PowerShell — `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`.** Add two `It` blocks inside the existing `Describe 'Test-BlastRadiusConflict result shape'`:

- one asserting both halves of the divergence simultaneously for a provably disjoint pair — the `conflict` key is false while boolean coercion of the whole result is true — with a comment naming the divergence and citing the PowerShell boolean rules. Asserting both halves in one `It` is deliberate: a test that asserted only one half would pass while the other half drifted.
- one asserting that the comment-based help of `Test-BlastRadiusConflict` carries the truthiness warning, so the documentation obligation is enforced by a test rather than by prose review.

### Unit tests for the fixed behavior and boundaries

Covered above. The new `__bool__` is a single branchless `return`, so both the true and the false case are exercised, giving full line and branch coverage of the added code.

### Edge cases and negative scenarios

- Empty-versus-empty radii: no conflict, so the projection is `False`. Covered by the `RADIUS_PAIRS` matrix.
- Empty-versus-populated radii: covered by the same matrix.
- Undecidable glob-versus-glob pair: fails closed to a conflict, so the projection is `True`, matching the module's fail-closed doctrine.
- Multi-reason results: the projection is `True` and reason ordering is unaffected.
- `ConflictReason` truthiness: asserted to remain the default, pinning the non-goal.

### Error handling and logging verification

Not applicable. The change introduces no error path and no logging.

### Coverage impact and targets for changed lines/modules

Scoped Python coverage command, in the dotted-module form the acceptance gates require:

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_invariants.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing
```

Three notes on that command:

1. The `--cov` value is an importable dotted module, supplied with the `=` form. Both `scripts/__init__.py` and `scripts/dev_tools/__init__.py` exist, so `scripts.dev_tools._blast_radius_conflicts` resolves. A filesystem-path form ending in `.py` is a Blocking gate violation under `.claude/rules/plan-acceptance-gates.md`.
2. `--cov-report=term-missing` must be passed explicitly. The project `addopts` at `pyproject.toml:115` supplies an LCOV reporter only, so a bare `--cov` writes `artifacts/python/lcov.info` and prints no readable table.
3. The run must be inspected, not merely exit zero. A table reporting `No data was collected` means the dotted name did not resolve and is a gate failure, not a formatting quirk. This runtime confirmation was not performed during research because no shell was available, and it is carried forward as an explicit acceptance criterion.

PowerShell coverage for `.claude/lib/blast-radius/BlastRadius.psm1` is measured by the existing Pester run settings, which already register the module at line 167 of the PoshQC Pester run-settings file pester.runsettings.psd1 under scripts/powershell/PoshQC/settings. Because no new coverage path entry is added, the known limitation in which the MCP PoshQC runner reads the installed extension's settings and ignores newly added entries does not apply to this feature.

### Toolchain commands to run

Python, in order, restarting from step 1 if any step fails or modifies a file:

```bash
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

PowerShell, in order (type checking is not applicable):

1. `mcp__drm-copilot__run_poshqc_format`
2. `mcp__drm-copilot__run_poshqc_analyze`
3. `mcp__drm-copilot__run_poshqc_test`, using the PoshQC Pester run-settings file pester.runsettings.psd1 under scripts/powershell/PoshQC/settings

### Manual validation steps

Compute and record SHA-256 digests for each of the three source/bundled pairs after the edits, and store the comparison as an evidence artifact under `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/other/`. The Python bundle-parity test compares text after universal-newline translation rather than raw bytes, so a hash comparison is the artifact that substantiates a byte-identity claim.

## Acceptance Criteria

- [x] A named test `tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_is_false_for_a_disjoint_pair` exists and passes, asserting that the boolean projection of the relation's result for two provably disjoint radii is `False`.
- [x] A named test `tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_is_true_for_an_overlapping_pair` exists and passes, asserting that the boolean projection for two overlapping radii is `True`.
- [x] A named test `tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_matches_the_conflict_field_on_constructed_results` exists and passes, asserting that a directly constructed result projects to its own `conflict` field in both the true and the false direction.
- [x] A named parametrized test `tests/scripts/dev_tools/test_blast_radius_invariants.py::test_boolean_projection_agrees_with_the_conflict_field` exists and passes for every entry of the existing `RADIUS_PAIRS` matrix, asserting that the boolean projection equals the `conflict` field.
- [x] A named test `tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_conflict_reason_defines_no_boolean_projection` exists and passes, pinning the non-goal that `ConflictReason` receives no boolean projection.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` contains, inside `Describe 'Test-BlastRadiusConflict result shape'`, a single `It` that asserts both halves of the PowerShell divergence in one test for a provably disjoint pair: the returned hashtable's `conflict` key is false, and boolean coercion of the whole returned hashtable is true. The `It` passes under `mcp__drm-copilot__run_poshqc_test`.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` contains an `It` that reads the comment-based help of `Test-BlastRadiusConflict` and asserts the help text contains the literal `the conflict key of the returned hashtable`. The `It` passes under `mcp__drm-copilot__run_poshqc_test`.
- [ ] The existing key-set assertion at `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:65` is unmodified and still passes, confirming the frozen two-key result shape was preserved.
- [ ] Both `.claude/skills/parallel-add/SKILL.md` and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` contain the literal `the conflict key of the returned hashtable` on a single line, within the step that instructs the agent to derive conflict edges.
- [ ] Both `.claude/skills/parallel-plan/SKILL.md` and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` contain the literal `the conflict key of the returned hashtable` on a single line in the edge-seeding procedure, and the literal `the conflict field of the returned ConflictResult` on a single line in the contention-contract section.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes after the change, confirming every edited file under `.claude` matches its bundled counterpart.
- [ ] An evidence artifact under `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/other/` records matching SHA-256 digests for each of the three source and bundled pairs: `BlastRadius.psm1`, `parallel-add/SKILL.md`, and `parallel-plan/SKILL.md`.
- [x] The scoped coverage command `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_invariants.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing` was run once, its output is captured in the feature evidence folder, and the term-missing table names the module with a non-zero statement count. An output containing `No data was collected` fails this criterion.
- [x] Line coverage of `scripts.dev_tools._blast_radius_conflicts` is at least 85 percent and branch coverage is at least 75 percent in the captured coverage output.
- [x] Line coverage of `.claude/lib/blast-radius/BlastRadius.psm1` is at least 85 percent in the Pester coverage output, with no branch-coverage assertion because Pester does not measure branch coverage.
- [ ] The four-stage Python toolchain completes without error in a single pass: `poetry run black .`, then `poetry run ruff check .`, then `poetry run pyright`, then `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- [ ] The three-stage PowerShell toolchain completes without error in a single pass using `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`.
- [ ] `git diff --name-only main...HEAD` lists only paths from the declared file scope in this specification, and lists no path under the extension TypeScript source tree extensions/drm-copilot/src, no path under the policy-rule directory .claude/rules, and none of the facade module compute_blast_radius.py under scripts/dev_tools, the drift-detection module parallel_drift_detection.py under scripts/dev_tools, the blast-radius truth table config/blast-radius.json, or the PoshQC Pester run-settings file pester.runsettings.psd1 under scripts/powershell/PoshQC/settings.
- [x] `scripts/dev_tools/_blast_radius_conflicts.py` defines no `__len__` on `ConflictResult`, and the class docstring and construction validation are otherwise behaviorally unchanged.
- [ ] Neither the Python parity suite test_blast_radius_parity.py under tests/scripts/dev_tools nor the PowerShell parity suite BlastRadius.Parity.Tests.ps1 under tests/scripts/claude-lib/blast-radius is modified, and both pass unchanged, confirming the shared fixture corpus was not extended with a truthiness assertion the two runtimes cannot both satisfy.
- [x] Neither `.claude/lib/blast-radius/BlastRadius.psm1` nor its bundled copy exceeds 500 lines after the comment-based-help addition.

## Risks & Mitigations

Technical or operational risks:

1. **The Python fix does not touch the incident surface.** Defining `__bool__` closes the defect class for future Python callers, but the #559 incident occurred on the PowerShell/agent path where no Python dunder is evaluated. Mitigation: the skill-prose correction and the comment-based-help warning are in scope and are covered by their own acceptance criteria, so the change cannot ship as a Python-only fix.
2. **The bundle-parity test can fail locally for an unrelated pre-existing reason** (repository issue #510: gitignored `.claude` state fails locally while passing in CI). Mitigation: when the test fails, read the path named in the failure message before treating it as a regression from this change.
3. **A repository-side edit to `extensions/drm-copilot/resources/...` does not change what an installed extension pushes down** until the extension is rebuilt and reinstalled. Mitigation: this affects downstream propagation timing only, not the correctness of the change; no acceptance criterion depends on installed-extension behavior.
4. **The PowerShell divergence remains live.** An agent that ignores the corrected prose can still write `if ($result)` and get an unconditional true. Mitigation: the divergence is documented in the module help, pinned by a test that fails if the language behavior ever changes, and stated in both skills at the point of use. Removing the divergence is impossible without breaking the frozen result contract, which is documented in Root Cause Analysis.
5. **Test-name drift between this specification and the delivered code.** The acceptance criteria name test node IDs that do not yet exist. Mitigation: the executor must create the tests under exactly these names, or update this specification and re-review before checking the criterion off.

Mitigations and rollbacks:
- Rollback is a plain revert. The change is additive, alters no persisted artifact, and requires no data migration.

## Rollout & Follow-up

Release/rollout steps:
- Standard branch, pull request, and merge. No release coordination, no feature flag, no migration.

Post-fix follow-up tasks:
1. **File `BlastRadius` unconditional truthiness as its own potential entry.** `BlastRadius`, at lines 101-218 of the facade module compute_blast_radius.py under scripts/dev_tools, carries the identical latent defect and, unlike `ConflictReason`, has a meaningful empty state that the relation acts on. It is deliberately excluded here because it would widen the write set to the facade module. Filing it separately keeps this fix's blast radius path-level only.
2. **Consider adding a SHA-256 comparison to `Context 'Bundled payload parity'` in the manifest suite BlastRadius.Manifest.Tests.ps1 under tests/scripts/claude-lib/blast-radius.** That block currently asserts only that a bundled counterpart file exists, whereas the three sibling libraries (`OrchestratorState`, `CodexRouting`, `DiscoveryValidation`) hash-compare their copies. The Python bundle-parity test already covers the exposure, so this is symmetry work rather than a gap fix. It is deliberately out of scope for this change and is recorded as an optional follow-up.

Links:
- Issue: https://github.com/drmoisan/drm-copilot/issues/576
- Research: `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/research/2026-08-28T10-05-conflictresult-truthiness-always-true-research.md`
- Related rules: `.claude/rules/parallel-orchestration.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/quality-tiers.md`
