# Code Review — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T16-21
- Cycle: remediation cycle 1 exit reaudit (full branch review)
- Branch: `feature/parallel-planner-surface-443` @ `15656e4c`
- Base: `b086cf6958ee4b628f60309cda80aac772304bc8`
- Scope: full branch diff — 106 files, 11267 insertions, 143 deletions

## Summary

The feature delivers a planner agent, a planner skill, a two-module Python kickoff-contract
library, a TypeScript parity port, additive registration on five wiring surfaces, and seven test
modules. Remediation cycle 1 closed the producer/consumer seam that was the root cause of the
cycle-entry Blocking set: the skill's kickoff template is now bound to its validator by a test in
each runtime, and both previously disagreeing points now agree.

**Blocking: 0. Non-blocking: 0. Advisory: 5.**

The central quality question this cycle was whether the new seam tests are real or ceremonial.
They are real: both simulated regressions produce a failing assertion (see Verification of
Discrimination below).

## Design Assessment

### Separation of concerns — good

`parallel_kickoff_contract.py` holds document-level concerns (section splitting, invocation
grammar, item-table typing, structure assembly) and `_parallel_kickoff_tables.py` holds the
Markdown table and integrity primitives. The split is motivated in both module docstrings by the
500-line limit and is enforced one-way: the private helper imports nothing from the contract
module, so there is no cycle. Both modules are pure — no I/O, no Git, no network, no mutation of
inputs — which is what makes the contract testable without fixtures on disk.

The `_`-prefixed helper-module naming follows the established
`_parallel_state_common` / `_parallel_state_structures` convention rather than inventing a new one.

### Value objects — good

`KickoffItem` and `ParsedParallelKickoff` are `@dataclass(frozen=True)` value objects with
complete type hints and docstrings that state the invariants rather than restating the fields.
`ParsedParallelKickoff` deliberately captures `slug` and `invocation_slug` separately so a caller
can detect a kickoff whose heading and invocation disagree — a good example of encoding a
downstream check into the type rather than leaving it implicit.

The deliberate absences are documented in-place: no dependency-edge member on `KickoffItem`, no
integration-branch member on `ParsedParallelKickoff`, each with a one-line reason. That is the
right way to record a negative design constraint.

### Error handling — good

Both entry points return `list[str]` and never raise. Unparseable input yields an error string,
not an exception. `parse_parallel_kickoff` returns `(None, errors)` on any violation, so a caller
cannot accidentally consume a half-parsed structure. The repeated match guards at
`parallel_kickoff_contract.py:341-347` are explained in a comment as type-checker narrowing, which
prevents a future reader from removing them as redundant.

One deliberate design choice worth naming approvingly: `_parse_items` skips a row whose numeric
cells do not parse but records a row whose complexity band is wrong, with the reasoning stated at
`:253-256`. That asymmetry is intentional and explained, not accidental.

### API surface — good

`__all__` at `parallel_kickoff_contract.py:39-52` is explicit and re-exports the two constants
callers legitimately need (`HASH_HEADERS`, `INTEGRITY_COMMIT_RE`) so consumers do not reach into
the private helper module. The thin `validate_parallel_kickoff_text` wrapper is documented as thin
and its reason for existing is stated, which the commenting rule specifically asks for.

### Reuse boundary — correct

The module imports nothing from `scripts/dev_tools/epic_kickoff_contract.py`. The docstring at
`:17-24` explains why: the parallel surface has no integration branch and no wave numbering, so
the two contracts share a shape but not a schema. Forcing shared code across a schema boundary
would have been worse than the duplication. This is the right call and it is justified in place.

## Verification of Discrimination (the cycle's central claim)

The seam tests were tested rather than trusted. Both cycle-entry defects were simulated in memory
with no source file modified.

| Simulated state | Result against the rendered live template |
|---|---|
| Current code, with `## Integrity` | `[]` |
| Current code, without `## Integrity` | `[]` |
| `RESUME_RE` narrowed back to `(?:Every item)` | one structural-invocation error |
| Template emitting `commit:` instead of `planning_commit:` | one integrity-line-invalid error |

Both regressions break `test_rendered_template_with_integrity_validates_clean`
(`test_parallel_kickoff_template_seam.py:265-276`) and its TypeScript twin
(`parallel-kickoff-template-seam.test.ts:209-221`). The B2 regression additionally breaks
`test_rendered_template_captures_planning_commit` (`:295-308`), which asserts the captured value
rather than merely asserting no error — a stronger assertion than the finding required.

### Quality of the seam test design

Several choices are better than the minimum the remediation input asked for.

- **`KickoffTemplateError`** (`:70-87`) is raised when extraction or rendering fails, so a producer
  shape change surfaces as a test error rather than as a vacuous pass against an empty string.
  This closes the obvious way a seam test could silently stop testing anything.
- **The residual-token guard** (`:219-223`) rejects a rendering that still contains `<slug>`,
  `<iso8601>`, `<hex>`, or `...`, so a placeholder the renderer does not know about cannot pass
  through and produce a confusing downstream validator error.
- **`_substitute_placeholder_rows`** (`:127-174`) selects the replacement row by cell count rather
  than by line position, so the helper survives the template gaining or losing surrounding prose,
  and raises on an unrecognized width rather than passing it through.
- **The resume anchor** is `"Each item\nresumes"` (`:60`), deliberately spanning the template's
  line break so the later lowercase `each item opens its own pull request` clause is not rewritten
  by the alternant-substitution tests. The reason is stated in the comment. Without this the
  negative test would have been unsound.
- **The negative-case choice is justified in a comment** (`:339-345`) explaining that
  `RESUME_RE` is applied with `search` and has no word boundary, so a valid negative must contain
  none of the three alternants as a substring, and that `Some items` would therefore be an invalid
  negative. This is precisely the analysis the widening required, written down where the next
  maintainer will find it.
- **`test_committed_fixture_and_template_agree_on_the_resume_clause`** (`:358-378`) asserts the
  independently-maintained fixture and the runtime template agree, taking the remediation input's
  recommended follow-on rather than only its minimum.

### Cross-runtime parity of the seam

The five substitution constants are byte-identical across the two modules, verified by substring
search rather than by inspection. Both modules read the canonical repository-root
`.claude/skills/parallel-plan/SKILL.md`, not the bundled mirror — the TypeScript module documents
the five-level path derivation and states the intent explicitly at `:38-44`. Reading the mirror
instead would have let the canonical file drift undetected.

## Cross-Runtime Parity of the Contract

`RESUME_RE` was compared programmatically, not visually: the compiled Python pattern string equals
the TypeScript literal exactly. `INTEGRITY_COMMIT_RE` matches after the language-inherent
`(?P<commit>` / `(?<commit>` normalization. Error-string literals match across the two runtimes for
every construct both represent identically, which the dispatch and table test modules exercise.

Two intentional structural differences are correct rather than divergent:

- Python `parse_parallel_kickoff` guards on `if not lines` while TypeScript guards on
  `text.length === 0`. These agree on both `""` and `"\n"`; the difference is an artifact of
  `"".splitlines()` returning `[]` in Python.
- TypeScript `splitSections` uses `LINE_SPLIT_RE = /\r\n|\r|\n/u` where Python relies on
  `str.splitlines()`. Both accept LF, CRLF, and CR.

## Comment and Docstring Quality

The Python modules meet `.claude/rules/self-explanatory-code-commenting.md` in full: mandatory
class and function docstrings including private helpers, Google-style sections, loop-intent
comments above every iteration, and decision-logic comments on every non-trivial branch. No
numbered notes appear.

The comments explain intent rather than narrating lines. Representative examples:

- `parallel_kickoff_contract.py:208-209` — why a repeated heading is rejected rather than merged
  ("merging would let a spoofed second table satisfy the contract"). This is a security rationale
  that is not derivable from the code.
- `parallel_kickoff_contract.py:68-77` — the B1 decision-logic comment, which states the governing
  spec wording, names all three admitted spellings, and explains that the alternation is
  deliberately wider than any single producer's phrasing so a spec-conformant document is not
  rejected. A future maintainer tempted to narrow it has the reason in front of them.
- `_parallel_kickoff_tables.py:118-119` — why header order is contractual (the row parser reads
  positionally).
- `_parallel_kickoff_tables.py:190-192` — why a duplicate plan path is flagged (the recorded hash
  would be ambiguous).

The TypeScript port carries one-line doc comments on exports and a header note (`:12-19`)
directing readers to the Python modules as the documented reference, with the rationale that
duplicating the rationale would let the ports drift into inconsistent explanations. That is the
A-2 disposition and it is a defensible choice.

## Delivered Runtime Surfaces

`.claude/agents/parallel-planner.md` (149 lines) and `.claude/skills/parallel-plan/SKILL.md`
(420 lines) are well-structured. Notable strengths:

- The agent's `## Upstream Library Invocation` section (`:134-149`) justifies the
  `"Bash(poetry run *)"` allowlist entry explicitly rather than leaving a broad permission
  unexplained. Broad tool grants should carry their reason, and this one does.
- The skill records negative constraints as first-class content — the "Deliberate omissions"
  paragraph (`:90-94`) states that the kickoff line carries neither mode marker and that both
  omissions must be preserved verbatim, and a test asserts that statement is still present.
- Three residual risks are recorded rather than silently accepted (`:127-141`), each with its
  owning downstream feature.
- The F1a corrections paragraph (`:174-180`) instructs that neither correction be worked around
  and that a radius must not be narrowed to suppress a resulting conflict edge. Encoding a
  fail-closed invariant as an explicit prohibition is the right treatment.

## Test Suite Assessment

Seven test modules, 97 feature-scoped Python tests plus the TypeScript suites, all passing.

| Module | Lines | Role |
|---|---|---|
| `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` | 449 | contract behavior |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py` | 312 | table and integrity primitives |
| `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py` | 378 | producer/consumer seam |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` | 410 | delivered-surface contracts |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py` | 260 | landed-upstream reconciliation |
| `extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts` | 299 | TypeScript seam |
| `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact*.test.ts` | 350 + 253 | TypeScript contract |

Positive, negative, boundary, and error-handling flows are all present. Every module is under the
500-line limit. Test placement mirrors the source tree in both languages; nothing is colocated
into a production tree.

The surface-contract modules assert string presence over Markdown, which is inherent to testing a
Markdown runtime surface and follows the `test_epic_run_kickoff_discovery_contract.py` precedent
the spec names. The cycle-entry defect was not that these assertions exist — it was that a
*behavioral* criterion was evidenced by them. That is now fixed: the behavioral claim is carried
by the seam tests and by the CLI run.

## Findings

### Advisory A-1 (carried forward) — cross-runtime divergences outside verified parity scope

**Location:** `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:179`, `:186`,
`:215`, `:251`.

`Number()` accepts inputs `int()` rejects: `Number("")` is `0`, `Number("0x10")` is `16`,
`Number("1e3")` is `1000`, and all three satisfy `Number.isInteger`. An empty or hex-formatted
`issue_num` or `cohort` cell is therefore accepted by the TypeScript runtime and rejected by
Python. Separately, `planHashes[planPath] !== undefined` at `:251` reads through the prototype
chain of a plain object literal, so a plan path spelled `constructor` or `toString` reports a
spurious duplicate.

**Verified not a regression.** Both are byte-for-byte the design of the landed
`epic-kickoff-artifact.ts` (`Number(row[0])` at `:149`, `Number(row[2])` at `:156`,
`Record<string, string> = {}` at `:186`, prototype lookup at `:240`).

**Correction, when authorized:** replace the object literal with `new Map<string, string>()` or
`Object.create(null)`, and gate numeric cells on `/^-?\d+$/` before `Number()`. The accompanying
verified-parity-scope paragraph belongs in `.claude/rules/parallel-orchestration.md`, a protected
surface, so this must be a separately authorized change and should probably move the epic module
in the same pass to avoid divergence between the two ports.

**Rule:** `.claude/rules/typescript.md`. **Classification: Advisory.**

### Advisory A-3 (carried forward) — Integrity-template precedent

**Location:** `.claude/skills/epic-plan/SKILL.md` (protected surface; no `## Integrity` template).

`.claude/skills/parallel-plan/SKILL.md:379-385` is now the repository's only `## Integrity`
template bound to its validator by a test. Propagating the pattern to the epic surface would
prevent the same defect class there. Requires separate authorization. **Classification: Advisory.**

### Advisory A-4 (new) — defensive-fallback branches uncovered in the TypeScript port

**Location:** `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`, uncovered
arcs at lines 136, 137, 193, 201, 204, 205, 217, 222, 232, 245, 250, 256, 307.

All 13 are `?? ""` / `?? []` fallbacks made unreachable by preceding length guards but required by
TypeScript's unchecked-index strictness. Branch coverage 88.79% (threshold 75%), line coverage
100%. No action required; recorded so the gap is not later mistaken for untested logic.
**Classification: Advisory.**

### Advisory A-5 (new) — flaky coverage arc in an unchanged module

**Location:** `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py:362-403`, arc `[395, 362]`.

The `while True:` subprocess output-streaming loop uses a reader thread, `queue.get(timeout=0.1)`,
and `time.monotonic()`, so whether the loop-continuation edge from the line-395 guard back to the
loop header executes depends on real scheduling. This makes repo-wide Python branch coverage vary
by one arc in 5000 between identical runs and generates spurious ±0.02 pp deltas for every feature
that measures repo-wide coverage.

**Correction:** inject a clock seam into the loop per the determinism-infrastructure requirement in
`.claude/rules/general-unit-test.md`. Outside this feature's change set. **Classification: Advisory.**

### Advisory A-6 (new) — minor line-wrap inconsistency

**Location:** `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md:135`.

The N3 correction produced a 104-character line where the surrounding section wraps near 98. No
enforced Markdown line-length rule exists and the file already contains longer lines. Tidiness
only. **Classification: Advisory.**

## Verdict

**PASS.** No Blocking and no Non-blocking findings. The code is well-factored, fully documented to
the repository's Python commenting standard, correctly bounded against protected and upstream-owned
surfaces, and — the point of this cycle — now covered by tests that were empirically confirmed to
fail if either cycle-entry defect returned.
