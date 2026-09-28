# Code Review — 2026-08-07-parallel-mutation-protocol-442

- **Timestamp:** 2026-08-09T00-19
- **Feature:** `docs/features/active/2026-08-07-parallel-mutation-protocol-442`
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Diff base (pinned):** `c939b5b8`
- **Companion artifacts:** `policy-audit.2026-08-09T00-19.md`, `feature-audit.2026-08-09T00-19.md`

## Change Inventory

**New production Python (7 modules, 2,284 lines total):**

| Module | Lines | Role |
|---|---|---|
| `scripts/dev_tools/parallel_mutation_protocol.py` | 393 | public engine: 4 decision functions + 4 re-exported constructors |
| `scripts/dev_tools/_parallel_mutation_models.py` | 450 | frozen value objects, F3 nullability enforcement at construction |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 229 | dedicated rejection/lookup exceptions |
| `scripts/dev_tools/_parallel_mutation_entries.py` | 249 | 4 entry constructors + centralized generation stamping |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 361 | thin deterministic CLI for the abandon side effects |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 313 | FR9 validator helper (invariants 1-2, delegates 3) |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 289 | FR9 invariant 3 (mode-dependent completion) |

**New production PowerShell:** `.claude/hooks/enforce-parallel-abandon-gate.ps1` (259).

**New skills:** `.claude/skills/parallel-{add,remove,close}/SKILL.md`.

**New tests (8 suites, 3,193 lines).** **Confined shared-file edits:** `+2/-0` validator,
`+4/-0` settings, `+144/-1` orchestrate SKILL (one hunk, inside the reserved F6 section).

## Design and Architecture

### Separation of concerns — strong

The decide/apply split is stated as a contract and held throughout.
`parallel_mutation_protocol.py:20-23` declares "This module DECIDES; it never applies", and
that is true in the code: no engine function writes a checkpoint, runs a subprocess, or
performs I/O. Destructive effects are isolated in a single 361-line CLI whose only process
boundary is one named function (`run_with_subprocess`, lines 125-157). Skills are thin
procedure documents that call named engine functions. This is textbook compliance with
`.claude/rules/general-code-change.md` § Separation of Concerns and § I/O Boundaries.

### Delegation, not reimplementation — verified

`recolor_unstarted` (lines 164-235) delegates coloring in full to F2's landed
`compute_cohorts` (line 226) and derives the mapping view in one comprehension (line 230).
No vertex ordering, no `(-degree, item_key)` tie-break, and no slot-filling logic is
duplicated; the sibling `compute_concurrency_batches` is correctly not called. F1's
`conflicts` relation is never invoked — edges are an input, documented at lines 33-37. The
non-reimplementation claim in AC S5 is genuine.

The induced-subgraph construction (lines 220-224) is the mechanism that excludes pinned
vertices, and the redundant `overlap` guard at lines 212-215 fails fast if a caller passes a
key as both unstarted and pinned. Defence in depth on the feature's core invariant, at
negligible cost.

### Module split rationale — honest

Four of the seven modules exist "only to keep each file inside the 500-line limit"
(`parallel_mutation_protocol.py:14-17`). This is stated plainly rather than dressed up as a
design decision, and each split follows a cited in-repo precedent
(`_blast_radius_conflicts.py` for F1, `_parallel_state_records.py` for F3). The public surface
stays one module via `__all__` re-export (lines 101-111), so callers are unaffected by the
private split. Good judgment.

### Validation at the type boundary — notable strength

`MutationEntry.__post_init__` (`_parallel_mutation_models.py:363-450`) makes an F3-invalid
mutation record **unconstructible**: a non-null `prior_state` on an `add`, a non-null
`item_key` on a `close`, or a stray `disposition` all raise at construction. This is stronger
than validating on serialization and directly implements
`.claude/rules/python.md` § Dataclasses ("Enforce invariants in `__post_init__`") and
`general-code-change.md` § Error Handling ("Enforce invariants at construction time"). The
checks run in field order so the first reported violation names the earliest field at fault
(documented at lines 366-370).

`RecolorResult.__post_init__` (lines 305-323) copies **before** wrapping in
`MappingProxyType`, with the reason stated: wrapping the caller's own dict would leave the
value object mutable through the caller's reference. That is the correct subtlety, correctly
reasoned, and it is test-pinned (`test_parallel_mutation_protocol.py:197-207,487`).

### Clock seam — required, not defaulted

`clock: Callable[[], datetime]` is a **required** keyword-only parameter on all four entry
constructors (`_parallel_mutation_entries.py:85,136,180,230`). Making it required rather than
defaulting to `datetime.now` is the stronger choice: it makes reading the wall clock
impossible rather than merely discouraged. Confirmed by scan — no `datetime.now`,
`datetime.utcnow`, `time.time`, or `Get-Date` appears in any of the seven production modules
or the hook.

### Error handling

Dedicated exception types per rejection reason
(`InFlightRemovalRequiresDispositionError`, `MergedItemRemovalRejectedError`,
`CloseWhileInFlightRejectedError`, `UnknownItemError`, `UnknownEnumMemberError`,
`MutationEntryContractError`), each carrying the offending key. No broad `except Exception`.
The one catch in the CLI (`parallel_mutation_abandon_cli.py:353-355`) is narrowed to
`AbandonSideEffectError` at a CLI boundary and converts it to a specific exit code and stderr
message. `decide_close` (lines 355-357) collects **every** in-flight key before raising rather
than stopping at the first, so a rejected close names all blocking work at once — a small
usability decision with a stated rationale.

### Documentation and commenting

`.claude/rules/self-explanatory-code-commenting.md` compliance is unusually thorough. Every
module carries a Purpose / Responsibilities / Invariants / Raises-and-side-effects header;
every function and property has a Google-style docstring with `Args`/`Returns`/`Raises`; every
loop and non-trivial comprehension has an intent comment above it
(e.g. `parallel_mutation_protocol.py:153-154, 217-219, 228-229`); branch chains carry
decision-logic comments (`decide_removal`'s routing table at lines 249-268,
`MutationEntry._validate_disposition` at lines 440-442). No numbered `NOTE n:` tags. Modules
legitimately omit per-function `Side Effects` sections under an explicit module-wide statement
that nothing has side effects, with the convention's precedent cited — a reasonable
application of the rule rather than an evasion.

### Naming

Consistent `parallel_` / `parallel-` prefixing across modules, hook filename, skills, error
prefixes (`PARALLEL_ABANDON_BLOCKED`, `PARALLEL_ABANDON_ERROR:`), satisfying `spec.md`
constraint 4. PEP 8 naming throughout; `CONSTANT_CASE` module constants; `_`-prefixed private
modules.

## The Producer/Consumer Token Seam — Detailed Assessment

This was the highest-risk area, given two prior children in this epic shipped diverged
producer/consumer pairs at 100% per-side coverage. **The seam test genuinely binds the three
artifacts.** Detail:

**No token value is hardcoded as an expected value.** The only literals in
`test_parallel_abandon_token_seam.py` are path anchors (lines 44-45), a filename anchor
(line 49), the two `$script:` **constant names** in the hook regexes (lines 53-58), and the
argparse option prefix `--` (line 61). Every compared value is extracted at run time.

**Three independent extractions:**

1. **CLI (producer):** `cli_token_pair()` (lines 81-93) reads `cli.ABANDON_DISPOSITION_TOKEN`
   and `cli.CONFIRM_ABANDON_TOKEN` from the imported module. Because those constants are
   f-string compositions (`parallel_mutation_abandon_cli.py:72-73`,
   `f"{DISPOSITION_OPTION} {ABANDON_DISPOSITION}"`), importing resolves the composed value —
   so the S105-avoidance composition does not defeat the parse, which was the specific concern.
2. **Live argparse surface:** `parser_option_strings()` (lines 96-115) unions every action's
   `option_strings` from the parser `build_parser()` actually returns;
   `disposition_action_composition()` (lines 118-148) locates the disposition action and
   asserts `choices` is non-empty and contains `abandon`. This proves the constants are
   **honoured by the parser**, not merely declared beside it — a real risk the author
   anticipated (`parallel_mutation_abandon_cli.py:204-207`).
3. **Hook (consumer):** `hook_token_pair()` (lines 151-172) regex-extracts the right-hand side
   of the hook's two named `$script:` assignments
   (`enforce-parallel-abandon-gate.ps1:38-39`).
4. **SKILL (documented invocation):** `skill_invocation_line()` (lines 175-201) selects lines
   carrying the CLI filename **and** an option token, and asserts **exactly one** candidate.
   `skill_option_tokens()` (lines 204-234) emits both the bare flag and the `<option> <value>`
   pair so a valued option and a bare flag can both be matched without the test knowing which
   shape each token takes.

**Non-empty guards are present throughout**, so a failed parse fails loudly rather than
satisfying a subset assertion vacuously: `assert disposition is not None` /
`assert confirm is not None` (lines 166-171), `assert extracted` (lines 231-233),
`assert len(candidates) == 1` (lines 195-200), `assert choices` (line 141),
`assert option_strings` (line 251), and `.strip()` non-emptiness checks (lines 242-243,
272-273).

**Would it fail on a single-sided rename?** Yes, in all three directions:

- Hook token renamed → `test_hook_token_pair_equals_the_cli_pair` (line 276) fails.
- CLI `DISPOSITION_OPTION`/`CONFIRM_ABANDON_OPTION` renamed → the same test fails, and
  `test_skill_documents_the_cli_token_pair` (line 297) fails.
- SKILL invocation line changed → `test_skill_documents_the_cli_token_pair` fails; a removed or
  duplicated invocation line fails `skill_invocation_line`'s cardinality assertion.

`test_hook_states_each_token_exactly_once` (lines 285-294) additionally asserts each token
literal appears exactly once in the hook, so the extracted value is provably the only value
the hook can match on. Verified independently: the hook states `'--disposition abandon'` only
at line 38 and `'--confirm-abandon'` only at line 39; every other reference reads the variable
(lines 106, 131, 192-193).

**No hardcoding on both sides. Not vacuously passing. This is a correct fix for the failure
mode that burned the two earlier children.** The evidence file
`evidence/regression-testing/abandon-token-seam-binding.md` further records that a
single-sided rename was applied and reverted to demonstrate the binding.

**One weakness (Advisory).** `test_parser_composes_the_disposition_token`
(lines 258-264) asserts `cli_token_pair()[0] == disposition_action_composition()`, but both
sides derive from the same two module constants, so the equality is tautological. The
genuine content is the two `assert` statements inside the helper. Not a defect — the check is
real — but the test name overstates what the comparison proves.

## Correctness Concerns

### Blocking

**Admission into the current cohort does not check independence against not-yet-launched
members of that cohort.** Full detail in `policy-audit.2026-08-09T00-19.md` finding **B1**.
Code-review summary:

`decide_admission` (`parallel_mutation_protocol.py:114-161`) receives only `in_flight` and
returns `ADMIT_CURRENT_COHORT` whenever the candidate shares no edge with a pinned item. That
branch performs no recolor (`parallel-add/SKILL.md:70-72`). Because
`max_concurrency` caps in-flight items independently of cohort size
(`.claude/skills/parallel-orchestrate/SKILL.md:120-124`, "a cohort of twelve items executes
at most `max_concurrency`"), a cohort can durably hold `scheduled` members. Admitting a
candidate that conflicts with such a member places two contending items in the same cohort,
which the next batch then launches concurrently.

The signature cannot express the correct rule: it has no view of the current cohort's
membership. The engine's docstring at lines 127-130 asserts the mitigation ("resolved by
`recolor_unstarted`") that only exists on the `DEFER_AND_RECOLOR` branch, so the code's own
comment is inaccurate for the admit branch. **The implementation is faithful to spec FR1
step 4 and AC S2/U1**, so remediation requires a spec amendment, not a code-only fix.

### Partial

**F3 op-classification tuples copied without a binding assertion.**
`_parallel_mutation_models.py:109-113` and `_parallel_orchestrator_state_mutations.py:92-99`
each re-declare F3's `OPS_REQUIRING_ITEM_KEY`, `OPS_REQUIRING_NULL_PRIOR_STATE`, and
`OPS_REQUIRING_NULL_NEW_STATE` (`_parallel_state_records.py:49-56`) as local copies. F3's
constants are importable. No test binds the copies to F3's values — contrast the item-state
subset binding that *is* present at `test_parallel_mutation_protocol.py:86-101`. This is a
second instance of the same divergence class the token seam was built to prevent: two sides,
both at 100% coverage, agreeing only by coincidence. See policy-audit **P1**.

Note the nine *enum member sets* are correctly imported, not restated
(`_parallel_mutation_models.py:65-71`), so this is a derived-constant gap, not an
enum-ownership violation.

**FR9 invariant 3 is narrower than its spec sentence.** See policy-audit **P2** for the full
independent assessment. Code-review view: the two-signal conjunction in
`_parallel_orchestrator_state_mode_completion.py:279-289` is well-reasoned and the module
docstring (lines 16-43) is an unusually good piece of design documentation — it states each
signal, why the conjunction is required, and why no rule fires on a healthy in-progress
checkpoint. The open-mode arm is a genuine additive invariant. The closed-mode arm is close to
inert on spec-conformant data because a conformant `closed`-mode run records no `close` entry
at all. The code is sound; the **spec text** overstates what it enforces.

### Advisory

- **Abandon-gate literal match is evadable by `--disposition=abandon`.** The hook matches the
  normalized literal `'--disposition abandon'`
  (`enforce-parallel-abandon-gate.ps1:38,105-107`), which argparse's `=` form would not
  produce. **Mitigated by design, and worth crediting:** the CLI independently refuses without
  the marker (`parallel_mutation_abandon_cli.py:342-349` returns `EXIT_REFUSED` before any side
  effect), so no destructive action can occur through an evaded gate. The gate is a
  deterrent; the CLI is the enforcement. Consider also matching the `=` form for completeness.
- **`# noqa: S603` rationale sits on an inert line.**
  `parallel_mutation_abandon_cli.py:152-153`. Line 152 carries the required text but Ruff only
  honours a `noqa` on the violating line, so the effective suppression at 153 is bare and line
  152 reads as a suppression while suppressing nothing. One-line fix. See policy-audit **P5**.
- **Unauthorized `# noqa: S311`** at
  `test_parallel_mutation_protocol_properties.py:125,308`. See policy-audit **P4**.
- **`# pragma: no cover` at `parallel_mutation_abandon_cli.py:360` is redundant** —
  `pyproject.toml:126-131` already excludes `if __name__ == .__main__.:`. Harmless.
- **Three test files at 498-500 lines** leave no headroom under the cap.

## Test Quality

### What is genuinely strong

**The property tests establish the real properties, not weaker proxies.** Assessed against the
directive's specific question:

- **Determinism (P1)** is established four ways, not one: repeated-call equality
  (line 207), **input-order independence** via reversed vertex and edge lists (lines 212-225),
  exact key-set equality against the unstarted set (line 227), and generation `= g + 1`
  (line 243). Input-order independence is the stronger property and the one that would catch a
  set-iteration-order leak; asserting it is a deliberately higher bar than
  `f(x) == f(x)`.
- **Independent-set validity (P2)** is genuinely tested: lines 263-276 iterate **every** edge
  whose endpoints were both colored and assert differing cohort indices. Not a spot check.
  Line 278-296 additionally proves the subgraph is truly *induced* by showing that recoloring
  with the full edge list equals recoloring with pinned-touching edges pre-dropped.
- **Pinning (P1/P3)** is asserted as key-set disjointness from `pinned` (lines 236-241) — the
  correct formulation, since the guarantee is *absence* of an assignment rather than an
  unchanged one. P3 (lines 302-358) then applies a 6-step generated add/remove sequence,
  reapplying the recolor after each op as the orchestrator would, and asserts every pinned
  item's state and cohort are byte-identical to their pre-sequence values.
- Twelve Fibonacci seeds over graphs of 2-12 vertices with seed-varying edge density, so runs
  range from edgeless to near-clique and from zero pinned to almost fully pinned
  (lines 127-146). Keys are offset to 100+ so a test cannot pass by assuming 0-based keys
  (line 128-129) — a thoughtful anti-cheat.
- Seed reproducibility is real: `GeneratedRun.__str__` (lines 174-185) emits the seed and full
  graph shape, interpolated into **every** assertion message, and pytest case ids are
  `seed{N}` (line 188).

**Unit coverage matches the spec's Test Strategy scenario-for-scenario.** All eight numbered
scenarios are present and labelled: pinning (`TestPinnedItemsNeverMove`), generation
accounting including the N-op sum (`test_sequence_of_ops_ends_at_start_plus_recompute_count`),
admission over all items, the full FR2 removal table one test per row including both rejection
rows and the non-live `withdrawn`/`blocked` rows, close gating, the completion predicate
parametrized over `merge_status`, and per-op mutation-log shape with explicit
`prior_state is None` assertions for both `add` cases.

**Purity is tested, not assumed:** `test_no_engine_call_mutates_the_generated_run`
(lines 483-499) exercises every container-taking function and asserts keys, edges, and items
survive unchanged; `test_recolor_does_not_mutate_its_inputs` and
`test_decide_removal_does_not_mutate_the_item_mapping` do the same at unit level.

**Hook tests** (22 cases) cover deny/allow/out-of-scope/malformed-JSON plus whitespace
normalization, token-order independence, the absence of a deny reason on allow, and the mocked
read seam with `Should -Invoke -Times 1 -Exactly`. Dot-source guard
(`enforce-parallel-abandon-gate.ps1:246-248`) makes the body coverable without executing the
entry point. No temp files, no live git/gh, no environment reads.

**Validator-helper tests** include backward compatibility (a checkpoint with no `mutations`
key produces no new errors), exact-string error assertions rather than substring matches, and
the deliberate non-firing case for an idle `open` run
(`test_validate_parallel_orchestrator_state_mutation_modes.py:51-56`).

### Gaps

- **P3 omits in-flight removals.** `test_parallel_mutation_protocol_properties.py:319-343`
  draws removal targets only from `unstarted`, so no `detach`/`abandon` op ever enters the
  "arbitrary sequence of add/remove ops". The complementary property — that removing one
  in-flight item leaves *other* in-flight items' state and cohort untouched — is unproven.
  Adding it would be a small extension to the existing loop.
- **P3's cohort assertion is indirect.** Pinned keys are seeded into `cohort_by_key` via
  `setdefault(key, 0)` (line 315) and can only change if `refreshed.cohort_assignments`
  contains a pinned key. So the assertion at lines 356-358 is functionally the same
  disjointness check as P1 rather than an independent observation. Valid, but it proves less
  than its name suggests.
- **No dedicated integration-scenario suite** for the spec's fixture-driven scenarios. The
  engine is pure with no external boundary, so the unit scenarios cover the same ground; a
  single multi-op walk over one checkpoint-shaped fixture exists only inside P3.
- **No test covers the B1 hazard.**
  `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected` (lines 344-351) calls
  `recolor_unstarted` directly and never exercises the admit-without-recolor path that creates
  the problem. Its docstring — "The contending unstarted pair lands in different cohorts" —
  is true of the function it calls but not of the admission flow it appears to be validating.

## Skills Review

All three skills carry the required frontmatter (`name`, `description`, `argument-hint`,
`context: fork`, `agent: parallel-orchestrator`) per `spec.md` FR10, and F6 correctly did not
edit the F5-owned `parallel-orchestrator` agent frontmatter.

Content quality is high and operationally specific rather than aspirational:

- Each skill opens with a mandatory **re-derive durable state** section naming the three exact
  commands and explaining the consequence of skipping it — `parallel-remove/SKILL.md:39-41`
  ("An item the checkpoint calls `scheduled` but which is really `in_flight` would be silently
  withdrawn and recolored, moving work that is already running"). That is the right level of
  concreteness for an agent-facing procedure.
- Each names the exact engine function to call, so a skill cannot drift into reimplementing
  decision logic.
- `parallel-remove/SKILL.md:103-106` explains *why* ad hoc `gh`/`git` is prohibited (not
  matchable by the gate) rather than merely asserting the prohibition — the kind of rationale
  that survives paraphrase by a future agent.
- `parallel-remove/SKILL.md:137-144` documents the seam contract and explicitly warns "do not
  add a second one", protecting the seam test's cardinality assertion from a future edit.
- `parallel-close/SKILL.md:25-27` correctly instructs *not* to close a `closed`-mode run to
  force completion — consistent with FR7 and directly relevant to the P2 scope assessment.

**One inaccuracy:** `parallel-add/SKILL.md:77-79` states "A conflict with an UNSTARTED item is
not a deferral. The coloring places contending unstarted items in different cohorts, so such a
conflict is resolved by the recolor" — but step 5 immediately below is conditional ("Apply the
recolor result, **if any**"), and on the `ADMIT_CURRENT_COHORT` branch there is no recolor.
This is the documentation face of finding B1.

## Confined Shared-File Edits — Review

The `+2/-0` validator edit is the minimum expressible form: one aliased import and one
`errors.extend(...)` line placed between `_validate_collections` and the `# BEGIN F7 EXTENSION
SEAM` comment. F7's 8-line seam block is byte-identical to base. The `+4/-0` settings edit
appends one object after the observed final entry, preserving order. Both are exemplary for a
concurrent-wave context.

The F5 surface-contract-test adjustment is the right shape: `RESERVED_HEADINGS` untouched (so
the 16-heading count, final-three-headings, uniqueness, and ordering assertions still bind the
populated F6 section), a new `POPULATED_RESERVED_HEADINGS` tuple, and a two-line `continue`
guard. Only the placeholder-*body* assertion is scoped down, and F7/F8 each need a single
tuple-member append. It weakens the F5 contract by the minimum necessary amount and forces no
restructure.

## Verdict

**Overall code-quality verdict: APPROVE WITH CHANGES.**

This is high-quality work. The pure-engine architecture, construction-time invariant
enforcement, required clock seam, full delegation to F2's coloring, exemplary shared-file
confinement, and a token seam that actually binds three artifacts at run time all reflect
careful engineering. Documentation and commenting compliance is among the better examples in
this repository, and the property tests establish the strong forms of the pinning,
determinism, and independent-set properties rather than weaker proxies. All seven new modules
reach 100% line and 100% branch coverage without a single coverage exclusion, and the reported
gate figures were accurate in every value I re-verified.

Two items need action before merge:

1. **B1 (Blocking)** — the admission rule permits a conflicting candidate into the current
   cohort alongside a not-yet-launched member. Root cause is spec FR1 step 4 / AC S2 / U1, so
   this requires a spec amendment plus an engine signature change and a test, or an explicit
   documented acceptance as a tracked limitation.
2. **P1 (Partial)** — bind or import F3's three op-classification tuples. A few lines, and it
   closes the same divergence class the token seam was built to prevent.

P2 through P5 are documentation, policy-authorization, and comment-placement corrections that
require no behavioral change.
