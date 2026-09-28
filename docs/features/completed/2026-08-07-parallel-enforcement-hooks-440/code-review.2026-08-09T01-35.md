# Code Review — F7 Parallel Enforcement Hooks (Issue #440)

- Feature folder: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440`
- Branch: `feature/parallel-enforcement-hooks-440` @ `59796e82`
- Base: `epic/parallel-orchestration-integration`, merge base `c939b5b8`
- Audit type: REAUDIT, remediation cycle 1 exit
- Supersedes: `code-review.2026-08-08T23-10.md`
- Timestamp: 2026-08-09T01-35

## Summary

The remediation delivered a 411-line TypeScript port of the Python cohort-barrier invariant, a
30-file language-neutral parity corpus consumed by both runtimes, and a two-line seam edit. Code
quality is high: zero suppressions, complete docstrings, small pure functions, no I/O in the
invariant modules, and machine-enforced per-file coverage. The design decision that carries the
most value is the shared corpus, which converts a previously unobservable class of defect into a
test failure.

Findings: **0 Blocking, 0 PARTIAL, 5 Advisory, 2 Informational.** All are carried from the policy
audit; this document adds the craft-level rationale.

## Design Assessment

### The shared corpus is the right mechanism, and it is correctly built

The epic has shipped the producer/consumer divergence defect three times, each time with both
language surfaces at full per-side coverage. That history is the correct diagnosis of why per-side
coverage fails: two suites can each be complete and internally consistent while the surfaces
disagree, because nothing compares them. Binding both runtimes to one committed expectation file
is the minimum mechanism that makes disagreement observable, and it follows an in-repo precedent
(`test_blast_radius_parity.py` / `BlastRadius.Parity.Tests.ps1` against
`tests/fixtures/blast_radius`).

Three implementation choices deserve specific credit:

1. **The filter token is restated, not imported.** Both suites hard-code
   `VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION"` rather than importing the
   implementation's `VIOLATION_PREFIX`. A rename of the production constant therefore breaks the
   suites instead of silently moving both sides together. This is the difference between pinning
   to the specification and pinning to the implementation.

2. **The TypeScript side routes through `validateArtifact`, not the helper.** Importing
   `validateCohortBarrierOrdering` directly would have tested the port while leaving the seam
   itself unexercised — which is precisely the shape of B-1. Driving every case through
   `validateArtifact({ artifactType: "parallel-orchestrator-state", text })` means the 33-case
   suite fails if the seam is ever emptied again. The module-level doc comment states that the
   helper is imported "nowhere -- not even by name, so the negative search that proves the
   discipline stays clean," which is a thoughtful detail: it keeps a grep-based audit reliable.

3. **Vacuity is guarded three ways.** A floor of 30, an equality assertion against an
   independently enumerated on-disk count, and a requirement that the corpus contain at least one
   violating and one clean document. The second guard is the one that matters most: a discovery
   filter that silently skipped files would otherwise be reproduced rather than caught, and it is
   what prevents the two suites from iterating different subsets of the same directory. The
   `name`-equals-file-stem assertion closes the remaining rename hole.

### The port is a faithful, readable mirror rather than a re-derivation

The port preserves function boundaries one-for-one (`_normalize_folder_hint` /
`normalizeFolderHint`, `_build_reference_index` / `buildReferenceIndex`, `_resolve_reference` /
`resolveReference`, `_cohort_index_by_item` / `cohortIndexByItem`, `_has_started` / `hasStarted`,
`_satisfies_barrier` / `satisfiesBarrier`, `_merge_confirmed_after_start` /
`mergeConfirmedAfterStart`, `_violation_endpoints` / `violationEndpoints`), and keeps the same
guard ordering inside each. This is the correct choice for a parity port: a cleverer or more
idiomatic TypeScript structure would make future divergence review harder, which is the opposite
of what this module needs. Reviewing the two files side by side took minutes rather than hours
because of it.

The one structural improvement the port makes over a literal transcription is the `ReferenceIndex`
interface, which bundles the two maps the Python version returns as a tuple. That is a genuine
readability gain at the call sites and does not change behavior.

The port also correctly delegates shared guards to `./parallel-state-shared`
(`isObject`, `isPositiveInteger`, `isNonNegativeInteger`, `isEnumMember`,
`MERGED_MERGE_STATUSES`) rather than reimplementing them, which is what keeps the
barrier-satisfying set from drifting independently of the rest of the validator family.

### The seam edit is minimal and well-placed

Two added lines, zero changed existing lines, and the invocation sits inside the delimiter the F3
seam contract reserves. `errors.push(...)` versus Python's `errors.extend(...)` is the idiomatic
equivalent. The wave-4 contention constraint is satisfied by construction: F3, F6, and F7 cannot
collide on these lines.

### The Absorption A fixture repair is correct and well-documented

`stateWithEdges` in `parallel-orchestrator-state-structures.test.ts` previously coloured 444 and
445 into one cohort, which was a coherent graph colouring only while the edge list was empty. Once
the barrier invariant existed, injecting an edge between two same-cohort items earned a barrier
violation on top of whatever edge-shape condition the test was actually exercising. Splitting them
into cohorts 0 and 1 restores the property that each test observes only its own condition.

The 16-line comment explaining this is exemplary: it states why the old builder was latently wrong,
what the fix does, and — importantly — that invariants 13 and 14 still hold under the new shape
(indices unique within the generation, every non-withdrawn item in exactly one current-generation
cohort, `current_cohort` of 0 not exceeding the maximum index of 1). A future reader will not undo
this by accident. The 83 tests in that suite pass unchanged in count.

## Best-Practice Compliance

| Area | Verdict | Notes |
|---|---|---|
| Simplicity first | PASS | small pure functions, no indirection, no abstraction added for its own sake |
| Reusability | PASS | shared guards imported from `parallel-state-shared`; corpus shared across runtimes |
| Separation of concerns | PASS | invariant modules are pure; all I/O confined to hook read seams and read-only corpus loads |
| Error handling / fail-fast | PASS | hooks fail closed; corpus loaders throw naming the offending record and field |
| Naming | PASS | `snake_case` Python, `camelCase` TS locals, `PascalCase` TS interface, `Verb-Noun` PowerShell |
| File naming | PASS | kebab-case TS, `_`-prefixed private Python helper module |
| Docstrings / doc comments | PASS | module-level Purpose/Flow/Responsibilities/Invariants/Side-Effects on both modules; every function documented |
| Loop and branch intent comments | PASS | every loop and every non-trivial branch carries an intent comment |
| No numbered notes | PASS | no `NOTE 1:`-style tags |
| File size <= 500 | PASS | max 499; see Advisory A-5 |
| Type strictness | PASS | `pyright` 0 errors; `tsc` exit 0; no `any`, `unknown` narrowed via guards |
| Suppressions | PASS | zero introduced |
| ES modules | PASS | import syntax throughout |
| Test location | PASS | `tests/scripts/claude-hooks/`, `tests/scripts/dev_tools/`, `extensions/drm-copilot/test/lib/validate/` all mirror their production trees; no colocation |
| Arrange–Act–Assert | PASS | explicitly labelled in the parity suites and the TS unit suite |
| Determinism | PASS | no `Date.now`, `setTimeout`, `Math.random`, `Start-Sleep`, or wall-clock read in any new file |
| No temp files in tests | PASS | only read-only committed-fixture loads |
| Architecture boundaries | PASS | new module imports one sibling in the same `src/lib/validate/` layer; no host-bound or adapter import |

## Findings

### A-1 (Advisory) — First-occurrence resolution is correct but unpinned by the corpus

Both sides resolve duplicates by first occurrence:

- Python: `records.setdefault(key, record)` (:139), `by_folder_hint.setdefault(...)` (:142),
  `assignments.setdefault(key, ...)` (:217)
- TypeScript: `if (!records.has(issueNum))` (:158), `if (!byFolderHint.has(hint))` (:164),
  `key !== null && !assignments.has(key)` (:241)

The comments on both sides justify the choice well ("a duplicate key is invariant 5's error to
report", "a second appearance is invariant 13's error to report, not this one's") — the module
correctly declines to double-report what another invariant owns.

The gap is in the corpus, not the code: no document has a duplicate `issue_num` or places one
member in two current-generation cohort rows. Replacing the TypeScript `!assignments.has(key)`
guard with an unconditional `set` — a plausible "simplification" in a future edit — would flip the
semantics to last-occurrence and leave all 66 parity assertions green.

Recommended follow-up: two corpus cases, one per duplicate path, with the two duplicate records
carrying different `merge_status` so the choice is observable in the output.

### A-2 (Advisory) — Malformed-item skip branches unexercised

No corpus document contains a non-object `items[]` entry, an item with a non-positive-integer
`issue_num`, or an item with an absent, blank, or non-string `feature_folder`. All three are
guard-continues that agree across runtimes by inspection. The `issue_num` guard is the more
interesting one because it is where the integral-float class of I-1 would surface.

### A-3 (Advisory) — `FOLDER_HINT_PREFIXES` ordering rationale overstates its effect

Both files carry the comment "longest first so the repository-rooted form is stripped before the
bare lifecycle form." No input can distinguish the orderings: none of
`docs/features/active/`, `docs/features/completed/`, `active/`, `completed/` is a prefix of
another, so `"docs/features/active/x".startsWith("active/")` is false and the first-match loop
returns the same result under any permutation. The constant order is identical on both sides, so
there is no divergence risk; the comment simply describes a safeguard that the current constant set
does not need. Harmless, but a reader may spend time looking for the interaction it implies.

Only `docs/features/active/` and the bare basename are exercised by the corpus.

### A-4 (Advisory) — Mirrored unreachable defensive guard accounts for the only uncovered lines

`parallel-orchestrator-state-cohort-barrier.ts:344-346` and the Python
`if earlier is None or later is None: return None` cannot execute. Every key in `assignments`
originates from `resolveReference`, which admits a number only when `records.has(reference)` and a
string only through `byFolderHint`, whose values are all `records` keys. `records.get(earlierKey)`
is therefore always defined.

Lines 345-346 are the only uncovered lines in the new module (409/411 line, 88/89 branch). Keeping
the guard is the right call — deleting it would introduce a structural difference from the reference
for no behavioral gain, and the reference must stay authoritative. Recorded so the two-line
shortfall is not re-investigated later.

### A-5 (Advisory) — Three files within four lines of the 500-line cap

`.claude/hooks/enforce-parallel-cohort-barrier.ps1` at 499,
`tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` at 498, and
`tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py` at 496. All
compliant. The spec anticipated this ("PowerShell batch at cap ... with zero headroom"), so it is a
known and accepted condition, but the next change to any of these files will need a split.

### I-1 (Informational) — Documented divergence classes remain, and two are reachable here

`.claude/rules/parallel-orchestration.md` records three known divergence classes for the parallel
TypeScript port. Two are reachable through this module's guards:

- **Integral floats.** Python's `is_positive_integer` / `is_non_negative_integer` require
  `isinstance(value, int)`, rejecting `444.0`; TypeScript's `isIntegral` uses `Number.isInteger`,
  and `JSON.parse` has already erased the distinction. An `issue_num` or `generation` written as
  an integral float diverges.
- **Boolean/integer equality.** Python's `row.get("generation") != recolor_generation` treats
  `True == 1` as equal; TypeScript's `!==` does not.

Both parity suites state in their docstrings that corpus documents are restricted to values that
round-trip through both runtimes' native types, so these classes are "avoided rather than fixed."
That is an honest and correctly located disclosure — it appears in the rule file and in both
suites — and it is inherited from the F3 port rather than introduced by F7. It does mean the parity
guarantee is scoped, and a reader should not read "30-file corpus parity" as unconditional
equivalence.

### I-2 (Informational) — Python repo-wide branch figure

`artifacts/python/lcov.info` yields 83.96% branch (4245/5056) repo-wide, against 88.98% reported.
Line matches exactly at 91.88%. Most consistent with coverage.py's terminal branch column being a
combined line-plus-branch ratio. Both clear >= 75%; no gate outcome changes.

## Test Quality

### Parity suites (33 cases each side)

Structurally guarded loading is the standout quality feature. Both sides validate the full required
key set before reading any field, validate every expectation entry as it is read, and require each
expectation to begin with the violation token so an unrelated string cannot be smuggled into the
barrier comparison. Failures name the offending file, field, and index rather than surfacing inside
an assertion body. The `name`-equals-stem check prevents a case from being renamed away from the
file the other suite reads.

The corpus documents themselves are well-authored: each carries a `notes` field naming the single
behavior class it pins, and the naming is consistently kebab-case and descriptive
(`earlier-ci-green-does-not-satisfy-barrier`, `superseded-generation-cohorts-ignored`,
`merged-at-present-start-absent`). The `three-conflicting-items-one-cohort` case is a good
inclusion: it pins both multiplicity (exactly three messages) and document ordering, which a
single-edge case cannot.

Filtering validator output to the violation token before comparing is the correct isolation
choice, since several corpus documents are deliberately malformed and also produce F3 shape errors.

### PowerShell suites (123 tests, all passing)

Seam injection is done properly: both hooks read the checkpoint only through a named function, and
the tests mock that function. The negative cases prove the mock drives the decision —
`-MockWith { $null }` and `-MockWith { '{ broken json' }` both produce `deny` with the correct
reason prefix. Fail-closed behavior is covered for every unresolvable condition the spec
enumerates.

The epic byte-compatibility assertions at lines 222 and 234 use full exact-string comparison rather
than `-Match`, which is what the spec required and what actually protects the reason string. The
surrounding `-Match` assertions on other tests are appropriate for prefix checks.

### Coverage enforcement

The per-file `coverageThreshold` entry in `jest.config.cjs` for the new module means the 99.51% /
98.88% figures are enforced on every run rather than merely observed once. This is the correct
pattern for a module whose whole purpose is to stay in lockstep with another runtime.

## Verdict

Code quality is high and the remediation addressed B-1 at the right level of abstraction: it did
not merely fill the seam, it built the mechanism that makes an empty seam a test failure. The
Advisory findings are refinements to divergence-detection breadth (A-1, A-2), a comment accuracy
nit (A-3), an accounted-for coverage shortfall (A-4), and a maintenance headroom warning (A-5).
None blocks merge.
