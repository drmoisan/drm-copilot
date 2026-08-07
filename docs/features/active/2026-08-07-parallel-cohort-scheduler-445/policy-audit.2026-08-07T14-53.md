# Policy Audit — 2026-08-07-parallel-cohort-scheduler-445

- **Timestamp:** 2026-08-07T14-53
- **Branch under review:** `feature/parallel-cohort-scheduler-445`
- **Base branch:** `epic/parallel-orchestration-integration` (epic child; base is not `main`)
- **Merge base:** `8703d7774c693298618df8231f8961018867b92f`
- **Scope command:** `git diff epic/parallel-orchestration-integration...HEAD`
- **Work mode:** `full-feature` (marker at `issue.md:12` — `- Work Mode: full-feature`)
- **Reviewer:** feature-review agent
- **Overall verdict:** **PASS** — 0 Blocking, 4 Advisory, 4 Informational

## Scope Resolution

The PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`
are absent from this worktree. Scope was therefore resolved directly from the authoritative source
pair: the resolved base branch and the full branch diff. The audit covers the complete branch diff
against the base, not any plan, task, or phase subset.

Changed-file inventory (`git diff --name-status epic/parallel-orchestration-integration...HEAD`),
20 files, 1840 insertions / 55 deletions:

| Status | Path |
|---|---|
| A | `scripts/dev_tools/parallel_cohort_computation.py` |
| A | `tests/scripts/dev_tools/test_parallel_cohort_computation.py` |
| A | `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` |
| A | 14 feature-folder evidence artifacts under `evidence/{baseline,regression-testing,qa-gates,other}/` |
| M | `docs/features/active/.../plan.2026-08-07T11-11.md` |
| M | `docs/features/active/.../spec.md` |
| M | `docs/features/active/.../user-story.md` |

## Rejected Scope Narrowing

**None detected.** The caller directive named `epic/parallel-orchestration-integration` as the base
branch. That is a legitimate base-branch resolution for an epic child, not a scope narrowing: it
identifies the correct comparison point rather than restricting the audit to a file subset, a plan,
or a phase. No caller instruction attempted to mark a language as out of scope, skip a toolchain
stage, or limit the audit to a task subset. The full branch-vs-base diff was audited.

## Evidence Location Compliance

All 14 evidence artifacts resolve under
`docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/<kind>/` using the canonical
kinds `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`.

Scan of the branch diff for the prohibited roots `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, and `artifacts/coverage/`:

```
$ git diff --name-only epic/parallel-orchestration-integration...HEAD | grep -E "^artifacts/"
(no matches)
```

Validator:

```
$ poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EVIDENCE_VALIDATOR_EXIT=0
```

**Verdict: PASS.** Zero evidence-location violations. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED`
condition arose during this review.

## Coverage Verification

Languages with changed files in the branch diff: **Python only.** TypeScript, PowerShell, and C#
each have zero changed files on this branch, so no coverage verdict is owed for them.

| Language | Changed files | Coverage artifact | Present | Verdict |
|---|---|---|---|---|
| Python | 3 (`.py`) | `artifacts/python/lcov.info` | Yes | **PASS** |
| TypeScript | 0 | `coverage/lcov.info` | — | N/A (zero changed files) |
| PowerShell | 0 | `artifacts/pester/powershell-coverage.xml` | — | N/A (zero changed files) |
| C# | 0 | `artifacts/csharp/coverage.xml` | — | N/A (zero changed files) |

### Python coverage, independently re-measured

Command run by this reviewer:

```
$ poetry run pytest --cov --cov-branch --cov-report=term-missing -q
...
TOTAL   12353   1104   4484    553    89%
Coverage LCOV written to file artifacts/python/lcov.info
2187 passed in 9.08s
```

Percentages derived from the coverage JSON (not from the combined `Cover` column):

| Metric | Measured by reviewer | Executor-reported | Match |
|---|---|---|---|
| `totals.percent_statements_covered` (repo line) | 91.06289970047762 | 91.06% | Yes |
| `totals.percent_branches_covered` (repo branch) | 82.00267618198038 | 82.00% | Yes |
| Module line coverage | 100.0 (59/59 statements) | 100% | Yes |
| Module branch coverage | 100.0 (22/22 branches) | 100% | Yes |
| Tests passed | 2187 | 2187 | Yes |

New file `scripts/dev_tools/parallel_cohort_computation.py`: line 100% (>= 85% required), branch
100% (>= 75% required). **PASS.** No modified pre-existing production file exists on this branch, so
the modified-file regression tier is vacuous.

Repo-wide: 91.06% line and 82.00% branch, both above the 85% / 75% uniform thresholds of
`.claude/rules/quality-tiers.md`. **PASS.**

### Baseline non-regression, arithmetically corroborated

The executor reported a Phase 0 baseline of 91.02% line / 81.91% branch. That baseline predates this
worktree state and could not be re-executed directly, but it is corroborated arithmetically from the
recorded raw counters, which are internally consistent with the post-change measurement:

| Counter | Baseline (recorded) | Post-change (reviewer-measured) | Delta |
|---|---|---|---|
| `num_statements` | 12294 | 12353 | +59 |
| `missing_lines` | 1104 | 1104 | 0 |
| `num_branches` | 4462 | 4484 | +22 |
| `missing_branches` | 807 | 807 | 0 |

- (12294 − 1104) / 12294 = 91.02000976% — matches the recorded baseline line figure exactly.
- (4462 − 807) / 4462 = 81.91393994% — matches the recorded baseline branch figure exactly.
- The +59 statement and +22 branch deltas equal precisely the new module's 59 statements and 22
  branches, all covered, with zero new missing lines or branches.

The baseline is therefore genuine and the "no regression" claim holds. **PASS.**

### Combined `Cover` column discipline

The plan forbids recording the term-missing `Cover` column as line coverage. The reviewer confirmed
the term-missing `TOTAL` row reports `89%`, which is `totals.percent_covered` (combined
line+branch), and that this value appears nowhere as a line-coverage figure in the evidence.
`evidence/baseline/baseline-pytest.2026-08-07T14-24.md` and
`evidence/qa-gates/coverage-delta.2026-08-07T14-39.md` each carry an explicit
"Explicit exclusion of the combined `Cover` column" section naming the 89% figure and stating it is
not recorded as line coverage. **PASS — the plan constraint was honored.**

### Coverage-exclusion policy

`pyproject.toml` (unchanged on this branch) configures:

```toml
[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
omit = ["tests/*", "*/tests/*", "*/__pycache__/*", "*/site-packages/*"]
```

No `omit` or `exclude_lines` entry matches a production source path. `exclude_lines` contains only
standard non-executable patterns (`if TYPE_CHECKING:`, `@abstractmethod`, `...`, etc.). The new
module is inside the coverage denominator with no configuration change. **PASS.**

## Toolchain Gates (independently re-run)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Format | `poetry run black --check .` | `All done! 337 files would be left unchanged.` exit 0 | **PASS** |
| Lint | `poetry run ruff check .` | `All checks passed!` exit 0 | **PASS** |
| Type check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | **PASS** |
| Unit tests | `poetry run pytest --cov --cov-branch` | `2187 passed in 9.08s` | **PASS** |
| Architecture boundary | n/a for a standard-library-only pure module | — | N/A |
| Contract/schema | n/a — serialization is F3 scope | — | N/A |
| Integration | n/a — no consumers until F3/F4/F5 land | — | N/A |

All four applicable stages pass in a single clean pass with no file modification by the format
stage. `.claude/rules/python.md` toolchain-loop requirement: **PASS**.

## Epic-Level Constraint Verification

Each constraint below is Blocking if violated. All are satisfied.

### 1. Greedy Welsh-Powell only; no optimal/randomized substitution; no cohort-merging post-pass

**PASS.** `_welsh_powell_order` (`parallel_cohort_computation.py:266-296`) is a single static sort;
`_assign_cohort_indices` (`:299-347`) is plain lowest-free-index greedy over that fixed order. There
is no saturation-degree recomputation (DSatur), no solver, and no randomization. `compute_cohorts`
(`:350-416`) terminates at the membership-fill loop (`:413-414`) and returns immediately (`:416`);
there is no post-pass that merges, reduces, or re-packs cohorts. Cohort counts at or above the
chromatic number are accepted as correct, consistent with the epic non-goal
("**Optimal graph coloring.** §13.3 accepts greedy Welsh-Powell in exchange for determinism").

### 2. Additive only

**PASS.** The full name-status diff shows only `A` entries for code files. Targeted check:

```
$ git diff --name-only epic/parallel-orchestration-integration...HEAD \
    | grep -Ei "pyproject|epic_wave|quality-tiers|SKILL.md|\.psm1|\.ps1"
NONE - clean
```

- `scripts/dev_tools/epic_wave_computation.py` — not in the diff. Unmodified.
- `pyproject.toml` — not in the diff. Unchanged; no dependency added.
- `hypothesis` — `grep -i hypothesis pyproject.toml` returns nothing. Not added. **PASS.**
- `quality-tiers.yml` — `ls quality-tiers.yml` → does not exist. Neither created nor modified.
- No pre-existing production or test file is modified anywhere in the diff.

### 3. Module must not compute blast radii and must never evaluate `conflicts(a, b)`

**PASS.** The module's only inputs are `item_keys` and a normalized edge list. There is no
`conflicts` symbol, no path/module analysis, and no radius derivation anywhere in the file. The
contention-relation boundary is stated explicitly in the module docstring (`:27-31`) and the F1
ownership is named. Verified by full read of all 468 lines.

### 4. No PowerShell counterpart module

**PASS.** No `.ps1` or `.psm1` file appears in the branch diff (see the grep in constraint 2).

### 5. No change to `.claude/skills/atomic-plan-contract/SKILL.md`

**PASS.** No `SKILL.md` appears in the branch diff.

### 6. Purity — no file I/O, network, clock, RNG, or input mutation

**PASS.** The module's complete import set is:

```
57: from __future__ import annotations
59: from typing import TYPE_CHECKING
```

No `os`, `io`, `open(`, `pathlib`, `random`, `time`, `datetime`, `urllib`, `requests`, or `print(`
appears in the file. Input mutation is structurally impossible: `_validate_item_keys` builds a new
`list(item_keys)`, `_build_adjacency` builds a new dict, and `compute_concurrency_batches` uses
`sorted(cohort_item_keys)` (a copy) rather than `.sort()`. Both non-mutation behaviors are also
asserted by dedicated tests
(`test_compute_cohorts_does_not_mutate_its_input_arguments`,
`test_compute_concurrency_batches_does_not_mutate_its_input_sequence`).

### 7. 500-line limit per file

**PASS.**

```
$ wc -l scripts/dev_tools/parallel_cohort_computation.py \
        tests/scripts/dev_tools/test_parallel_cohort_computation.py \
        tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py
  468 scripts/dev_tools/parallel_cohort_computation.py
  310 tests/scripts/dev_tools/test_parallel_cohort_computation.py
  187 tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py
```

All three files under 500. The test-file split is the plan's pre-approved
`[P1-T17]` fallback, applied at exactly the permitted path
`tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py`, with no improvised layout.
The `[P1-T17]` trigger ("if and only if the test file meets or exceeds 450 lines") is corroborated:
the executor recorded 474 lines pre-split, and the post-split totals (310 + 187 = 497, less roughly
20 lines of duplicated module docstring and import preamble in the split file) reconstruct to
approximately 477 lines, consistent with the recorded 474 and above the 450 trigger. The split was
therefore mandatory, not discretionary. **PASS.**

### 8. Evidence under `<FEATURE>/evidence/<kind>/`

**PASS.** See "Evidence Location Compliance" above.

## Determinism Audit (verified by reading the code, not by trusting the tests)

Each of the five enumerated hazards from `spec.md` "Determinism Requirement and Enumerated Hazards"
and the plan's Binding Constraints was checked against the source.

### (a) Vertex order sorted by `(-degree, item_key)` ascending, never input iteration order, never relying on sort stability

**PASS.** `parallel_cohort_computation.py:293-296`:

```python
return sorted(
    adjacency,
    key=lambda item_key: (-len(adjacency[item_key]), item_key),
)
```

The composite key carries `item_key` as its second component, so ties are resolved by the key
itself and the result never depends on Python's sort stability or on the dict's insertion order.
Because item keys are unique (enforced by `_validate_item_keys`), the key is a strict total order.
The sort is applied to `adjacency` (the mapping's key view) rather than to the caller's
`item_keys` list, which removes the last path by which arrival order could leak in.

### (b) Every set/dict feeding ordered output passes through `sorted(...)`, including the final per-cohort key lists

**PASS.** Two ordered outputs exist and both are explicitly sorted:

- Cohort membership — `:413`: `for item_key in sorted(cohort_index_by_key):`. The final per-cohort
  key lists are built by walking the **sorted** key view of the assignment mapping, so each inner
  list is ascending by construction.
- Batch contents — `:461`: `ordered_keys = sorted(cohort_item_keys)` before chunking.

The one place a set is iterated is `:332-336`, the `neighbor_indices` set comprehension. Its result
is a `set`, consumed only by the membership test `while candidate_index in neighbor_indices`
(`:342`). Set iteration order cannot influence a membership test, so this is order-insensitive and
never feeds ordered output. The code carries an accurate intent comment saying exactly that
(`:330-331`).

### (c) Ordered results never built by iterating insertion-ordered structures

**PASS.** `cohort_index_by_key` is a dict and therefore insertion-ordered, but it is never iterated
directly into output — every consumption site is either `max(...values())` (`:407`,
order-insensitive) or `sorted(...)` (`:413`). `adjacency` is likewise only ever consumed through
`sorted(...)` (`:293`) or by keyed lookup.

### (d) Item keys `int`-only, duplicates rejected

**PASS (typing) / by-design (runtime).** The signature types keys as `Iterable[int]` and Pyright
runs in strict mode over `scripts`, giving 0 errors. Duplicates are rejected at runtime by
`_validate_item_keys` (`:154-167`) before any coloring work, with the duplicated key named in the
message and stored on `offending_value`. There is no runtime `isinstance` check for `int`; that is
correct rather than a gap, because `spec.md` "Error Handling" enumerates exactly four failure modes
and a non-`int` key is not among them. Recorded as Informational I-1 below.

### (e) Tie-break direction ASCENDING

**PASS.** The second component of the sort key is `item_key`, not `-item_key`, under an ascending
`sorted(...)`. Confirmed both by reading `:295` and by the empirical discrimination test below,
which shows the delivered behavior differs from a descending tie-break on a real fixture.

### Anchor scenario

Required: `compute_cohorts([443, 444, 445, 446], [(443, 445), (443, 446)]) == [[443, 444], [445, 446]]`.

Hand-trace: degrees 443→2, 445→1, 446→1, 444→0. Order `443, 445, 446, 444`. Assignment
443→0; 445→1 (neighbor 443 holds 0); 446→1; 444→0 (isolated). Cohorts `[[443, 444], [445, 446]]`.

Executed: `test_compute_cohorts_user_story_scenario_splits_the_conflicting_items`
(`test_parallel_cohort_computation.py:29-38`) asserts this literal and passes. **Anchor confirmed.**

### Additional verified structural property

Greedy lowest-free-index assignment cannot leave a hole in the cohort index range: if a vertex
receives index `k`, indices `0..k-1` were each occupied by one of its neighbors, so every index up
to `max` is populated. `cohorts` is therefore never returned containing an empty inner list. This
supports the `cohort_count = max(...) + 1` allocation at `:407-408`.

## Policy-by-Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| `CLAUDE.md` tone policy | **PASS** | All new docstrings, comments, and evidence artifacts use neutral, literal, factual language. No humor, hyperbole, emoji, or decorative metaphor found in the 965 delivered lines. |
| `.claude/rules/general-code-change.md` — simplicity first | **PASS** | Four small helpers plus two public functions; no indirection, no inheritance beyond the single `ValueError` subclass, straight-line control flow. |
| `.claude/rules/general-code-change.md` — 500-line limit | **PASS** | 468 / 310 / 187. |
| `.claude/rules/general-code-change.md` — fail fast, explicit errors | **PASS** | All four malformed-input modes raise `ParallelCohortInputError` with a literal, value-naming message before any coloring work. No broad handlers; the module contains no `except` at all. |
| `.claude/rules/general-code-change.md` — I/O boundaries | **PASS** | Pure computation; zero I/O. |
| `.claude/rules/general-code-change.md` — dependencies | **PASS** | Standard library only; `pyproject.toml` untouched. |
| `.claude/rules/general-unit-test.md` — five core properties | **PASS** | Tests are independent (module-level literal constants, no shared mutable state), isolated (one behavior per test with two Advisory exceptions), fast (38 tests in 0.06s), deterministic (no RNG, no clock, no I/O), and readable (descriptive names + docstrings on all 16 test functions). |
| `.claude/rules/general-unit-test.md` — no temp files | **PASS** | `grep -nE "tmp_path\|tempfile\|NamedTemporary\|open\(\|Path\("` over both test files returns no matches. |
| `.claude/rules/general-unit-test.md` — no sleeps / banned timing APIs | **PASS** | No `sleep`, no wall-clock access in either test file. |
| `.claude/rules/general-unit-test.md` — test file location mirrors source | **PASS** | `scripts/dev_tools/X.py` → `tests/scripts/dev_tools/test_X.py`. No colocation in the production tree. |
| `.claude/rules/general-unit-test.md` — coverage exclusion policy | **PASS** | No production path excluded; see Coverage Verification. |
| `.claude/rules/general-unit-test.md` — scenario completeness | **PASS with Advisory** | Positive, negative, boundary, and error-handling flows all covered. One positional gap in the unknown-endpoint negative flow — Advisory A-1. |
| `.claude/rules/python.md` — toolchain order and single clean pass | **PASS** | black → ruff → pyright → pytest all clean in one reviewer-executed pass. |
| `.claude/rules/python.md` — PEP 8 naming | **PASS** | `snake_case` functions and locals, `PascalCase` exception, `CONSTANT_CASE` test fixtures (`CANONICAL_ITEM_KEYS`, `INVARIANT_CONFLICT_EDGES`, `SLOT_FILLING_CASES`). |
| `.claude/rules/python.md` — strong typing, no `Any` | **PASS** | Every parameter and return annotated; `Any` appears nowhere; Pyright strict clean. |
| `.claude/rules/python.md` — private helpers `_prefixed` | **PASS** | `_validate_item_keys`, `_validate_edge`, `_build_adjacency`, `_welsh_powell_order`, `_assign_cohort_indices`. Public surface is exactly the two functions plus one exception, as the spec requires. |
| `.claude/rules/python.md` — `parametrize` for boundary matrices | **PASS** | `SLOT_FILLING_CASES` (6 cases), `MALFORMED_GRAPH_CASES` (3 cases), `max_concurrency` in `[0, -1, -7]`. |
| `.claude/rules/python-suppressions.md` | **PASS** | `grep -nE "noqa\|type: ?ignore\|pragma: ?no cover"` over all three new files returns no matches. Zero suppressions introduced, so no authorization is required. |
| `.claude/rules/self-explanatory-code-commenting.md` — mandatory docstrings | **PASS** | Module, exception class (with `Attributes:`), `__init__`, all five private helpers, and both public functions each carry a Google-style docstring with `Args:` / `Returns:` / `Raises:` / `Side Effects:`. |
| `.claude/rules/self-explanatory-code-commenting.md` — loop/comprehension intent comments | **PASS** | Every loop and non-trivial comprehension has an intent comment immediately above: `:157-158`, `:204-206`, `:250-252`, `:254-257`, `:291-293`, `:326-329`, `:330-332`, `:338-341`, `:410-413`, `:463-465`. |
| `.claude/rules/self-explanatory-code-commenting.md` — branching decision comments | **PASS** | `:191-195` explains why the self-loop check is ordered before the endpoint check; `:402-404` explains the empty-graph short-circuit; `:452-455` explains the `max_concurrency < 1` rejection. |
| `.claude/rules/self-explanatory-code-commenting.md` — no numbered notes | **PASS** | No `NOTE 1:` / `NOTE 2:` style tags anywhere in the delivered files. |
| `.claude/rules/quality-tiers.md` — T4 classification | **PASS** | `scripts/dev_tools/**` is T4 ("dev tooling"). T4 requires no property-based tests and no mutation score, so the absence of `hypothesis` is correct rather than a gap. Uniform gates (format/lint/type/coverage) all met. |

## Findings

### Blocking (0)

None.

### Advisory (4)

**A-1 — Unknown-endpoint tests exercise only the second edge position; a positional mutant survives the suite.**

- **Location:** `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py:108-113`
  (`unknown-edge-endpoint` case, `(443, 999)`) and `:170-180`
  (`test_parallel_cohort_input_error_message_names_the_unknown_key_and_edge`, `(444, 999)`).
- **Rule:** `.claude/rules/general-unit-test.md` — "Scenario Completeness: negative flows for
  invalid or missing inputs ... edge cases and boundary conditions."
- **Detail:** Both unknown-endpoint fixtures place the unknown key in the **second** tuple position.
  No test supplies an unknown key in the **first** position. The production code is correct — it
  iterates `for endpoint in (first, second):` at `:206` and handles both — but the suite does not
  pin that behavior.
- **Verification (empirical, mutant survived):** The reviewer temporarily replaced
  `for endpoint in (first, second):` with `for endpoint in (second,):` and re-ran both new test
  files:

  ```
  $ poetry run pytest tests/scripts/dev_tools/test_parallel_cohort_computation.py \
                      tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py -q
  38 passed in 0.07s
  ```

  The mutant passes the entire suite. Under the mutant, `compute_cohorts([443, 444], [(999, 443)])`
  raises `KeyError: 999` instead of `ParallelCohortInputError` — a real contract break that the
  tests do not catch. The unmutated module was restored via `git checkout --` and re-verified:
  the real implementation raises
  `ParallelCohortInputError - Conflict edge (999, 443) names item key 999, which is not a member of
  item_keys; ...`, and `git status --porcelain` is clean.
- **Why Advisory, not Blocking:** the shipped behavior is correct; this is a durability gap in the
  test net, not a defect. `spec.md` "Required test scenarios" item 9 asks for "unknown edge
  endpoint" without fixing a position, and T4 carries no mutation-score obligation
  (`.claude/rules/quality-tiers.md`).
- **Suggested remediation:** add one `pytest.param([443, 444, 445], [(999, 443)], (999, 443), "999",
  id="unknown-edge-endpoint-first-position")` entry to `MALFORMED_GRAPH_CASES`.

**A-2 — One test asserts two behaviors and duplicates a sibling assertion.**

- **Location:** `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py:91-104`,
  `test_compute_concurrency_batches_concatenate_to_the_sorted_cohort`.
- **Rule:** `.claude/rules/python.md` — "One behavior per test."
- **Detail:** The test asserts `concatenated == sorted(cohort)` (its stated behavior) and then also
  `batches == expected`, which is verbatim the assertion of the sibling parametrized test
  `test_compute_concurrency_batches_matches_the_expected_batch_layout` at `:80-88` over the same
  `SLOT_FILLING_CASES` matrix. A layout regression would fail both tests, which slightly blurs
  which unit is at fault.
- **Impact:** cosmetic; no loss of coverage or protection.
- **Suggested remediation:** drop the redundant `batches == expected` line at `:104`.

**A-3 — Acceptance criterion 12 text says "both new files" but three new files were delivered.**

- **Location:** `spec.md:386` and `user-story.md:165` — "...both new files are each under 500 lines."
- **Rule:** `acceptance-criteria-tracking` skill — "Preserve text ... No phantom criteria."
- **Detail:** The criterion was authored before the `[P1-T17]` split was known to trigger. Three new
  code files were delivered, all verified under 500 lines (468 / 310 / 187), so the criterion's
  substance is satisfied and the check-off is earned. Only the count word is stale. The executor
  correctly did **not** edit the criterion text, since the tracking skill forbids executors and
  reviewers from modifying criterion wording.
- **Suggested remediation:** a planning agent, not the executor, should reword to "all new files"
  in a future revision. No action required to merge.

**A-4 — `spec.md` "Definition of Done" is a stale parallel tracking surface.**

- **Location:** `spec.md:388-396`.
- **Detail:** See the dedicated adjudication section below. Leaving the section unchecked is
  correct. The Advisory is that DoD item 5 ("No file outside the **two** named new files is created
  or modified") is itself inconsistent with the spec's own pre-approved three-file split fallback at
  `spec.md:302-306`, and `user-story.md` has no DoD section at all. The section duplicates the AC
  list without being an AC source, which invites exactly this ambiguity.
- **Suggested remediation:** a planning agent should either remove the DoD section from the template
  or mark it explicitly non-tracking. No action required to merge.

### Informational (4)

**I-1 — No runtime `int` validation of item keys.** `compute_cohorts` types keys as `Iterable[int]`
and relies on Pyright strict plus the total-order sort key, but performs no runtime `isinstance`
check. This is by design: `spec.md` "Error Handling" enumerates exactly four failure modes and a
non-`int` key is not one of them; the spec closes the mixed-type hazard through the typing contract
("Typing keys as `int` also closes two determinism hazards"). Not a gap.

**I-2 — Greedy result equals the chromatic number on the delivered fixtures.** The `[P1-T11]`
five-cycle yields 3 cohorts (χ = 3) and the `[P1-T10]` crown-plus-pendant yields 2 (χ = 2). No
fixture currently demonstrates the accepted supra-chromatic case. This is not a defect — the epic
explicitly accepts counts at or above χ — and no test asserts minimality anywhere, so nothing
constrains a future graph from exceeding χ.

**I-3 — PR context artifacts absent.** `artifacts/pr_context.summary.txt` and
`artifacts/pr_context.appendix.txt` do not exist in this worktree. Scope was resolved from the
authoritative base branch and full branch diff instead, which is equivalent for audit purposes.

**I-4 — Evidence artifacts are unusually rigorous.** Both the baseline and coverage-delta artifacts
proactively quote the term-missing `TOTAL` row, identify the trailing percentage as
`totals.percent_covered`, and state explicitly that it is not recorded as line coverage. Every
numeric figure the reviewer re-derived matched to full floating-point precision. Recorded as a
positive observation about evidence quality, not a finding.

## Verdict

**PASS.** Zero Blocking findings. The change is additive, pure, deterministic by construction,
fully covered, toolchain-clean, and compliant with every epic-level constraint including the
greedy-only non-goal, the F1 boundary, and the evidence-location invariant. The four Advisory items
are non-merge-blocking; A-1 is the only one with technical substance and is a test-durability
improvement rather than a behavior defect.
