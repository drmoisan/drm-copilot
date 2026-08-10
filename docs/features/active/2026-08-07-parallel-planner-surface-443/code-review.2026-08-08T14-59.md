# Code Review — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T14-59
- Branch: `feature/parallel-planner-surface-443`
- Base: `epic/parallel-orchestration-integration` (merge base `b086cf69`)
- Reviewed surfaces: 2 new Markdown runtime surfaces, 3 new production modules, 5 additive
  registration edits, 7 new test modules, 5 updated test modules, 1 new fixture, 1 pack-manifest
  registration, 2 bundled mirrors, 29 evidence artifacts

## Summary

The implementation is well-factored and idiomatic. Module boundaries are chosen for cohesion
rather than to satisfy the line limit mechanically, typing is complete, error reporting is
literal and non-mutating, and the additive MCP wiring is genuinely minimal. Test coverage of the
contract module in isolation is total (100% line and branch on both new Python modules).

The review's substantive finding is a producer/consumer contract break: the kickoff document
template published in `.claude/skills/parallel-plan/SKILL.md` is rejected by
`scripts/dev_tools/parallel_kickoff_contract.py`, which the same feature delivers, on two
independent counts. No test exercises that seam, which is why the break survived execution.

## Blocking Findings

### B1 — Kickoff template's resume sentence does not satisfy `RESUME_RE`

- **Location:** `.claude/skills/parallel-plan/SKILL.md:369-371` (and the byte-identical mirror
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`)
- **Rule violated:** `.claude/rules/general-code-change.md` — "Fail fast and explicitly";
  spec acceptance criterion at `spec.md:655-660`; `.claude/rules/general-unit-test.md` scenario
  completeness at the contract seam.

The skill's canonical kickoff template instructs the planner to emit:

```
docs/features/parallel/<slug>/parallel.md on the plan-home branch parallel/<slug>-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.
```

The contract module's resume-boundary matcher is:

```python
RESUME_RE = re.compile(
    r"(?:Every item|items)\s+resumes?\s+at atomic execution\s+"
    r"from\s+(?:its|their)\s+committed plan-path\s+"
    r"on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch",
    flags=re.IGNORECASE,
)
```
(`scripts/dev_tools/parallel_kickoff_contract.py:72-77`; identical regex at
`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:19-20`.)

The alternation admits only the literals `Every item` and `items`. The template's `Each item`
matches neither: after `item` the next character is a newline, not `s`. The template therefore
fails the mandatory `## Invocation Prompt` structural check in both runtimes.

- **Verification command:** `poetry run python -c "...; from scripts.dev_tools.parallel_kickoff_contract import RESUME_RE; ... print(bool(RESUME_RE.search(s)), bool(RESUME_RE.search(f)))"`
- **EXIT_CODE:** 0
- **Output Summary:** `SKILL: False | FIXTURE: True` — the skill template does not match while
  `tests/fixtures/parallel_kickoff/valid-kickoff.md` (which uses `items resume`) does. The fixture
  passing is precisely what masked the defect.

- **Required correction:** Change the template's `Each item` to `Every item` (or restructure to
  `items resume`), or widen `RESUME_RE` to include `Each item`. If the regex is widened, apply
  the identical change to `parallel-kickoff-artifact.ts:19-20` and add a matching parity test so
  the two runtimes do not drift.

### B2 — Kickoff template's `## Integrity` commit field name is rejected

- **Location:** `.claude/skills/parallel-plan/SKILL.md:381` (and mirror)
- **Rule violated:** same as B1; additionally contradicts this feature's own `spec.md:459`.

The template emits:

```
parallel/<slug>-plan head commit: <hex>
```

The contract module accepts only:

```python
INTEGRITY_COMMIT_RE = re.compile(
    r"^(?:-\s*)?planning_commit:\s*`?(?P<commit>[0-9a-fA-F]{7,64})`?\s*$"
)
```
(`scripts/dev_tools/_parallel_kickoff_tables.py:28-30`.)

`parse_integrity` (`_parallel_kickoff_tables.py:242-255`) routes any non-blank line that is
neither a commit-field match nor a pipe-table row to an error. The consequence is twofold: an
error is emitted, and the run-level provenance commit is silently not captured — `planning_commit`
remains `None`.

The spec itself specifies the correct field name at `spec.md:458-460`: "the epic's single
`planning_commit` field generalizes to the head commit of `parallel/<slug>-plan`". The field name
was intended to remain `planning_commit`; only its semantics generalize. The template deviated
from the spec.

- **Verification command:** `poetry run python -c "...; from scripts.dev_tools._parallel_kickoff_tables import parse_integrity; print(parse_integrity([...]))"`
- **EXIT_CODE:** 0
- **Output Summary:**
  `(None, {'docs/f/plan.md': 'aabb...'}, ['Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: aabb...'])`
  — commit is `None` and an error is present.

- **Required correction:** Change `SKILL.md:381` to `planning_commit: <hex>` and state the
  plan-home-branch provenance in the surrounding prose (which `SKILL.md:399-401` already does
  correctly). Mirror the change into the bundled payload.

### B1 + B2 confirmed end-to-end through the delivered CLI

A kickoff document rendered verbatim from the skill's template, with `<slug>` substituted, was
validated through the artifact type this feature registers:

- **Verification command:**
  `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff <template>`
- **EXIT_CODE:** 1
- **Output Summary:**
  ```
  Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.
  Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: aabbccddeeff00112233445566778899aabbccdd
  ```

**Impact.** `.claude/agents/parallel-planner.md:128-129` makes completion conditional on the
kickoff validating through `artifact_type: "parallel-kickoff"`. A planner that follows the skill's
own template cannot satisfy its own completion gate. B1 fires unconditionally; B2 fires whenever
the optional `## Integrity` section is emitted, so remediation must address both — fixing only B2
would leave the surface still broken.

### B3 — Spec acceptance criterion 11 is checked off without supporting evidence

- **Location:** `docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md:655-660`
  (marked `[x]`); supporting record at `evidence/other/ac-checkoff.2026-08-08T14-45.md:55`
- **Rule violated:** `.claude/skills/acceptance-criteria-tracking/SKILL.md`, "Evidence before
  check-off" — an AC item may be marked `[x]` only after the work satisfying it has been
  implemented **and verified**.

The criterion requires that the skill "specifies the kickoff artifact per R5: heading ...
`## Invocation Prompt` naming ... the per-item-branch resume-boundary sentence; `## Item Summary`
with exact ordered headers ...; optional `## Integrity`". The check-off record supports it with:

> contract-test (`test_skill_names_both_kickoff_artifact_paths`); skill-verification
> (`## Kickoff Artifact` section with the fenced template headings)

Both supports are heading-presence assertions. Neither validates the template's content against
the contract module. B1 and B2 establish that the specified template is invalid, so the criterion
is not in fact satisfied.

- **Required correction:** Revert the criterion to `[ ]` until B1 and B2 are corrected and the
  template validates with an empty error list; then re-check with the new test from B4 as the
  supporting evidence.

### B4 — No test binds the skill's kickoff template to the contract module

- **Location:** `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` and
  `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`
- **Rule violated:** `.claude/rules/general-unit-test.md` — Scenario Completeness; "Untested
  critical behavior is not acceptable even if the overall percentage looks good."

- **Verification command:** `grep -n "Integrity\|head commit\|planning_commit" tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`
- **EXIT_CODE:** 1
- **Output Summary:** no matches.

This feature ships both a contract (`parallel_kickoff_contract.py`) and the authoritative producer
of documents conforming to that contract (the fenced template in `SKILL.md`), and no test relates
them. The contract module reaches 100% branch coverage against synthetic fixtures while its real
producer emits an invalid document — a textbook case of coverage percentage concealing untested
critical behavior. The existing surface-contract tests assert fragment presence in the skill; the
kickoff fixture `tests/fixtures/parallel_kickoff/valid-kickoff.md` is hand-authored and diverges
from the skill template in exactly the two respects that matter.

- **Required correction:** Add a test that extracts the fenced ```markdown block from
  `.claude/skills/parallel-plan/SKILL.md` `## Kickoff Artifact`, substitutes a concrete slug and
  placeholder row values, and asserts `validate_parallel_kickoff_text(rendered) == []`. Add the
  TypeScript analogue asserting `validateParallelKickoffText(rendered)` is empty, so the seam is
  covered in both runtimes. Consider deriving `tests/fixtures/parallel_kickoff/valid-kickoff.md`
  from the skill template rather than maintaining it independently.

## Non-Blocking Findings

### N1 — Measurement evidence artifact omits the command-step fields

- **Location:** `evidence/other/kickoff-module-size.2026-08-08T14-17.md`
- **Rule:** `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

The artifact reports measured line counts — the output of a command — but records only
`Timestamp:`. It carries no `Command:`, `EXIT_CODE:`, or `Output Summary:`. The reported counts
are nonetheless correct: independent `wc -l` confirms 380 / 261 / 449 / 312, matching the
artifact's tables exactly. The split rationale it records is substantive and, unusually for such
records, explains the extraction boundary and cites the naming-convention precedent
(`_parallel_state_common.py`) and the Pyright `reportPrivateUsage` constraint that drove the
unprefixed helper names. Correction: add the three missing fields.

### N2 — One evidence filename lacks the ISO timestamp

- **Location:** `evidence/baseline/phase0-instructions-read.md`
- **Rule:** `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — `yyyy-MM-ddTHH-mm`

The file carries an internal `Timestamp:` field, and it is the only one of 29 evidence artifacts
without a timestamped filename. Correction: rename to
`phase0-instructions-read.<timestamp>.md`.

### N3 — `user-story.md` Non-Goals cites the superseded two-argument `conflicts(a, b)`

- **Location:** `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md:135`

The line reads "Implementing radius derivation, V1-V3 validation, `conflicts(a, b)`,
Welsh-Powell coloring, or any schema/validator". The landed signature is `conflicts(a, b, config)`
(`_blast_radius_conflicts.py:137-139`), which `SKILL.md:168` correctly cites. This text predates
the F1 landing and was not refreshed when the checkbox states were updated in this diff.

Severity is Non-blocking: the text is Non-Goals prose, not an acceptance criterion, so the
`acceptance-criteria-tracking` preserve-text rule does not apply to it; the delivered runtime
surface cites the correct signature; and the sentence's meaning — that F4 does not implement the
function — is unaffected by the arity. Correction: update to `conflicts(a, b, config)`, or add a
supersession note alongside the three already recorded at `spec.md:582-603`.

## Advisory Findings

### A1 — Python/TypeScript parity divergences outside the verified scope

The two runtimes agree on all 21 error-string literals and on every construct exercised by the
92 TypeScript and 88 Python tests. The following behavioral divergences exist outside that scope.
Each mirrors the landed `epic-kickoff-artifact.ts` precedent, so none is a regression introduced
here; they are recorded so a future reader does not mistake them for verified parity.

1. **Backtick stripping.** Python `cell.strip().strip("`")`
   (`_parallel_kickoff_tables.py:59`) removes every leading and trailing backtick; TypeScript
   `.replace(/^`|`$/g, "")` (`parallel-kickoff-artifact.ts:108`) removes at most one at each end.
   A cell written ` ``value`` ` parses as `value` in Python and `` `value` `` in TypeScript.

2. **Numeric cell parsing.** Python `int(text)`
   (`parallel_kickoff_contract.py:254,261`) versus TypeScript `Number(...)` guarded by
   `Number.isInteger` (`parallel-kickoff-artifact.ts:171,178`). TypeScript accepts `"1e3"` (1000),
   `"1.0"` (1), `"0x10"` (16), and `""` (0), all of which Python rejects; Python accepts
   `"1_000"`, which TypeScript rejects as `NaN`. Divergence direction differs per input, so error
   counts can differ in both directions.

3. **Duplicate plan-path detection via prototype lookup.**
   `parallel-kickoff-artifact.ts:243` tests `planHashes[planPath] !== undefined` against a plain
   object literal, so a plan path equal to `constructor`, `toString`, `valueOf`, or another
   `Object.prototype` member yields a spurious "repeats plan path" error, and assignment to
   `__proto__` does not create an own property. Python's `cells[0] in plan_hashes` has no such
   behavior. Realistic plan paths do not collide with prototype members, so the practical risk is
   low; `Object.create(null)` or a `Map` would remove the class entirely.

4. **`repr` quote selection.** Python `f"...{cells[0]!r}."`
   (`_parallel_kickoff_tables.py:206`) switches to double quotes when the value contains a single
   quote; TypeScript hardcodes single quotes (`parallel-kickoff-artifact.ts:245`). This is
   divergence class (1) already recorded repo-wide at
   `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`.

5. **Line-boundary set.** Python `str.splitlines()` also splits on `\v`, `\f`, `\x1c`, `\x1d`,
   `\x1e`, `\x85`, ` `, and ` `; `LINE_SPLIT_RE` handles `\r\n`, `\r`, and `\n` only.

Recommendation: record a verified-scope statement for this module in
`.claude/rules/parallel-orchestration.md`, in the same form F3 used for the state validators
("Verified scope: N of N error strings matched across M constructed documents", followed by the
known divergence classes). This makes the boundary explicit for the F5 consumer.

Noted as an improvement rather than a defect: `LINE_SPLIT_RE = /\r\n|\r|\n/u`
(`parallel-kickoff-artifact.ts:23`) is strictly closer to Python than the epic port's
`split("\n")` (`epic-kickoff-artifact.ts:58,258`), and is consistent with the CRLF/CR handling
established in commit `b845c505`.

### A2 — TypeScript port carries no explanatory comments where the Python original is fully documented

`.claude/rules/self-explanatory-code-commenting.md` scopes its mandatory docstring and
intent-comment requirements to Python, so this is not a policy violation. It is a maintainability
observation. The Python modules carry module docstrings, Google-style docstrings on every
function including private helpers, intent comments above all six loops, and decision-logic
comments on the non-trivial branches — for example the explanation at
`parallel_kickoff_contract.py:202-203` of why a duplicate heading is rejected rather than merged
("merging would let a spoofed second table satisfy the contract"), and at `:247-250` of why a row
with an unparseable numeric cell is skipped while a bad complexity band is recorded.

The TypeScript port reproduces the logic exactly but carries only one-line doc comments on the
three exported symbols and none on the seven private helpers. The rationale a maintainer needs in
order to change either runtime safely exists in only one of them. Recommendation: port the
decision-logic comments, or add a header note directing readers to the Python module as the
documented reference for the shared algorithm.

### A3 — The epic precedent supplies no `## Integrity` template, which explains the B2 root cause

- **Verification command:** `grep -n "Integrity" -A 10 .claude/skills/epic-plan/SKILL.md`
- **EXIT_CODE:** 1
- **Output Summary:** no matches.

`epic-plan/SKILL.md` documents no kickoff Integrity template, so the F4 author had no template to
mirror and composed the section from `spec.md`'s prose description ("the head commit of
`parallel/<slug>-plan`"), which describes the field's *meaning* rather than its *name*. Worth
noting when the correction lands: adding the corrected template to the parallel skill establishes
the precedent the epic surface still lacks.

## Positive Observations

These are recorded because they represent deliberate choices a future maintainer should preserve.

1. **The module split is a real cohesion boundary.** `_parallel_kickoff_tables.py` contains only
   Markdown table primitives and, as its docstring states, "knows nothing about kickoff sections,
   headings, or the invocation grammar". The import direction is one-way and cycle-free. The
   contract module re-exports `HASH_HEADERS` and `INTEGRITY_COMMIT_RE` through `__all__`
   (`parallel_kickoff_contract.py:39-52`) so the split does not change the public surface.

2. **No import from the epic analogue.** `parallel_kickoff_contract.py:17-24` records that the
   parallel surface "shares a shape but not a schema with the epic kickoff contract" and that the
   module "imports nothing from `scripts/dev_tools/epic_kickoff_contract.py`". Given that the two
   contracts differ in the resume clause, the cohort-versus-wave column, and the absence of an
   integration branch, avoiding inheritance here is the correct call.

3. **Duplicate-section rejection rather than merge.** `_split_sections`
   (`parallel_kickoff_contract.py:204-209`) rejects a repeated `## ` heading instead of merging
   its lines, with the security rationale stated inline. This closes a spoofing path in which a
   second `## Item Summary` table could satisfy the contract.

4. **Parse result withheld on any error.** `parse_parallel_kickoff` returns `None` alongside the
   error list whenever any error is present (`:335-342`), so no caller can act on a partially
   validated structure. The repeated match guards at `:336-341` exist to narrow the optional
   matches for the type checker and are annotated as such.

5. **The updated F3 tests strengthened rather than weakened coverage.** Each of the five renamed
   the original assertion to cover positive routing **and** added a separate test covering the
   unsupported-type fallback with the genuinely unregistered probe `parallel-status-doc`. Net
   assertion count increased, and each carries a comment citing the adjudicating documents.

6. **Additive wiring with no reflow.** Each of the five registration surfaces received exactly
   one named addition appended after the two F3 values, satisfying the wave-4 confinement
   discipline that keeps concurrently prepared features from colliding in the same files.

7. **The skill's upstream-contract section is precise.** Every one of the six cited upstream
   signatures matches the landed module exactly, including the affirmative statement at
   `SKILL.md:214-216` that `compute_cohorts` takes "exactly two parameters ... There is no third
   parameter" — a directly useful guard against reintroducing a pinned-set argument.

8. **The F1a corrections are recorded with the correct fail-closed framing** at `SKILL.md:174-180`,
   including the explicit instruction not to narrow a radius to suppress a conflict edge.

## Verdict

**Changes requested.** Four Blocking findings, all confined to the kickoff-template seam and its
missing test. The correction is small — two line edits in `SKILL.md` plus its mirror, one
AC checkbox revert, and one new test per runtime — and does not touch the contract modules, the
MCP wiring, or any upstream integration.
