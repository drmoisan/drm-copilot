# Policy Compliance Audit — Issue #505

- **Feature:** `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505`
- **Branch:** `bug/fix-all-json-cancel-thread-race-505` at `c06cb8fc`
- **Base:** `main` at `0c7469f8` (merged into the branch; `git diff main...HEAD` is the review diff)
- **Work Mode:** `full-bug` (marker at `issue.md` line 13) — AC source is `spec.md` only
- **Timestamp:** 2026-08-25T10-40
- **Reviewer:** feature-review

## Scope Statement

The audited scope is the full branch diff against `main`: 39 files, 3571 insertions, 43 deletions.
Of these, 4 are Python test files, 1 is a Python production file, and 34 are Markdown feature and
evidence documents.

No caller instruction attempted to narrow the audit to a plan, task, phase, or file subset. The
`## Rejected Scope Narrowing` section below is therefore empty. The caller did designate three
items as out-of-scope observations; that designation concerns *remediation* of pre-existing
conditions, not audit coverage, and each is nonetheless inspected and recorded below.

### Rejected Scope Narrowing

None. No narrowing was attempted.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were **absent** at review
time. `artifacts/` is gitignored in this repository (`.gitignore` line 6), so their absence is
expected rather than a defect. Scope and evidence were derived directly from `git diff main...HEAD`,
which is the authoritative source the artifacts would otherwise summarise, and from the feature
folder documents. No scope determination in this audit depends on a regenerated context artifact.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`

Only Python files changed, so no PowerShell, TypeScript, C#, or GitHub Actions rule is in scope.

## Verdict Summary

| Policy area | Verdict | Basis |
|---|---|---|
| Tone policy (`.claude/rules/tonality.md`) | PASS | Independent read of all authored prose |
| Mandatory toolchain loop | PASS | All four stages re-executed by the reviewer |
| File size limit (500 lines) | PASS | `wc -l` on every file in the diff |
| Error handling and logging | PASS | Read of `fix_all_runtime.py` lines 141-160 |
| Design principles (simplicity, reusability) | PASS | Read of the stub module and production diff |
| Unit-test core principles | PASS | Read plus a 30-iteration determinism stress |
| Determinism infrastructure (banned APIs) | PASS | Repository-wide grep across the four test files |
| Test file location | PASS | Paths mirror `scripts/dev_tools/` |
| Coverage thresholds and exclusion policy | PASS | Independent parse of `artifacts/python/coverage.json` |
| Evidence location invariant | PASS | `validate_evidence_locations.py --root .` exit 0 |
| Declared scope boundaries | PASS | `git diff --name-only` against the forbidden path set |

**Blocking findings: 0. Non-blocking findings: 8** (detailed in
`code-review.2026-08-25T10-40.md`).

## Language Coverage Verdicts

Coverage verdicts are mandatory and explicit for every language with changed files on the branch.

| Language | Changed files on branch | Coverage artifact | Verdict |
|---|---|---|---|
| Python | 5 (`.py`) | `artifacts/python/coverage.json`, `artifacts/python/lcov.info` — both present | **PASS** |
| TypeScript | 0 | n/a | N/A (zero changed files) |
| PowerShell | 0 | n/a | N/A (zero changed files) |
| C# | 0 | n/a | N/A (zero changed files) |

The `N/A` verdicts are permissible because each of those languages has zero changed files in the
branch diff, which is the sole condition under which `N/A` is acceptable.

### Python coverage detail (independently verified)

Repository-wide figures were parsed by the reviewer directly from
`artifacts/python/coverage.json` rather than read from an evidence document:

| Metric | JSON key | Value | Threshold | Verdict |
|---|---|---|---|---|
| Line | `totals.percent_statements_covered` | 92.6302414231258 | >= 85 | PASS |
| Branch | `totals.percent_branches_covered` | 85.21485797523671 | >= 75 | PASS |

Statement denominator: 14953.

The combined `totals.percent_covered` value is 90.63829787234043. It is recorded here only to note
that it is a different statistic (statements plus branches) and was correctly **not** used as the
line-coverage figure by the executor's evidence. That methodological distinction is stated at
`evidence/qa-gates/coverage-delta.2026-08-25T10-21.md` line 18 and is correct.

#### Changed-line coverage

The production diff adds four executable lines to `scripts/dev_tools/fix_all_runtime.py`: 142
(`try:`), 143 (`result = func()`), 144 (`except Exception as exc:`), and 152 (the
`api.BranchResult(` call spanning 152-157). Lines 145-151 are comments and carry no statement.

Reviewer-parsed result from `coverage.json`:

```
added lines executed?  {142: True, 143: True, 144: True, 152: True}
scripts\dev_tools\fix_all_runtime.py  missing_lines = [77]  missing_branches = [[75, 77]]
```

Line 77 is the injected-runner-factory short-circuit. It is pre-existing, is not among the added
lines, and is not touched by this diff. **No changed line is uncovered.** No modified file regresses
against baseline: repository line coverage moved from 92.6086956521739 to 92.6302414231258 and
branch coverage from 85.19664967225054 to 85.21485797523671, both positive deltas.

`scripts/dev_tools/fix_all_branches.py` reports 100.0 percent line coverage with an empty
`missing_lines` list and an empty `missing_branches` list under the full suite. That file is
read-only for this fix; the figure represents new coverage of pre-existing lines contributed by the
added tests.

## Coverage Exclusion Policy

`pyproject.toml` `[tool.coverage.run]` (lines 118-125) declares `source = ["src", "scripts/dev_tools"]`
and omits only `tests/*`, `*/tests/*`, `*/__pycache__/*`, and `*/site-packages/*`.

No `omit` entry matches a production source path. The new test-support module
`tests/scripts/dev_tools/fix_all_thread_stubs.py` falls outside the denominator through the
permitted `tests/*` entry, which the Coverage Exclusion Policy lists explicitly as permissible test
infrastructure. **PASS.**

`[tool.coverage.run]` does not set `branch = true`, so branch data exists only when `--cov-branch` is
passed on the command line. The spec anticipated this at line 194 and Risk 7 (line 312). The
executor's commands passed the flag, and the reviewer's own verification run passed it. `pyproject.toml`
is unchanged by the diff. **PASS.**

## Mandatory Toolchain Loop

The reviewer re-executed all four stages in order rather than accepting the recorded evidence.

| Stage | Command | Result | Verdict |
|---|---|---|---|
| 1. Format | `poetry run black --check .` | `445 files would be left unchanged` | PASS |
| 2. Lint | `poetry run ruff check .` | `All checks passed!` | PASS |
| 3. Type check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | PASS |
| 4. Unit tests | `poetry run pytest --cov --cov-branch -q` | `4121 passed, 5 skipped in 18.65s` | PASS |

No stage modified a file, so the loop closed in a single consecutive pass. The reviewer's pass count
(4121 passed, 0 failed, 5 skipped) reproduces the executor's reported figure exactly.

Stages 4 through 7 of the seven-stage loop (architecture-boundary tests, contract/schema checks,
integration tests) have no configured Python surface in this repository and no such surface is
introduced by this diff. Not applicable.

### Note on a reviewer-induced artifact mutation, since reversed

While verifying the candidate B mechanism, the reviewer ran a narrow coverage command that
regenerated `artifacts/python/lcov.info` from a two-test scope, truncating it from 423,754 bytes to
1,818 bytes. This was detected immediately and reversed by re-running the full suite with
`--cov --cov-branch`, which restored the file to exactly 423,754 bytes. `artifacts/python/coverage.json`
— the source of every figure in this audit — was never written by any reviewer command and retains
its original 10:14 modification time and 1,593,299-byte size. `artifacts/` is gitignored, so no
tracked file was affected at any point. The incident is recorded here for completeness rather than
because it changed any verdict.

## File Size Limit

`.claude/rules/general-code-change.md` sets a 500-line ceiling on production code, test code, and
reusable script files.

| File | Lines | Verdict |
|---|---|---|
| `scripts/dev_tools/fix_all_runtime.py` | 198 | PASS |
| `tests/scripts/dev_tools/fix_all_thread_stubs.py` | 176 | PASS |
| `tests/scripts/dev_tools/test_fix_all.py` | 447 | PASS |
| `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | 472 | PASS |
| `tests/scripts/dev_tools/test_fix_all_json_cancel.py` | 396 | PASS |

Every file written by this change is at or below the limit. The split into
`test_fix_all_json_cancel.py` was necessary: the host module stood at 492 lines at baseline, leaving
8 lines of headroom against roughly 90 lines of planned additions. The deviation from the spec's
"conditional write" framing is documented at `issue.md` lines 99-101 and is justified by the
measured line counts.

## Determinism Infrastructure (Banned APIs)

`.claude/rules/general-unit-test.md` prohibits real wall-clock waits and elapsed-time dependencies in
test code. A repository-wide grep across all four `fix_all` test files for `time.sleep`,
`Thread.Sleep`, `Task.Delay`, `Date.now`, `time.monotonic`, `time.perf_counter`, `time.time(`,
`datetime.now`, `import time`, and `.wait(` returned exactly one hit:

```
tests\scripts\dev_tools\test_fix_all_json_cancel.py:20:    No test in this module creates a thread, calls ``time.sleep``, waits on a
```

That occurrence is inside the module docstring, forms part of a **negated** prose claim, and is not
executable. There is no `import time` in any of the four files and no `.wait(` call site in test
code. **PASS.**

`GraceWaitCancelEvent.wait` (`test_fix_all_json_cancel.py` lines 143-147) is a *definition*, not a
call. It records its timeout argument, sets its flag, and returns `True` with zero elapsed time. It
therefore removes a wall-clock wait from the path under test rather than introducing one. The
companion assertion at line 301, `cancel_event.wait_timeouts == [fix_all.CANCEL_CHECK_DELAY_S]`,
asserts an argument *value* and not an elapsed duration. **PASS.**

Empirical confirmation: the reviewer executed the four new tests plus the two repaired tests plus the
two must-not-regress tests for 30 iterations. All 30 iterations reported `8 passed` (240 node
executions, zero failures).

The module docstring's claim that "No test in this module creates a thread" is nonetheless factually
inaccurate and is recorded as non-blocking finding N1 in the code review.

## Test File Location

`.claude/rules/general-unit-test.md` requires tests to mirror the production tree under `tests/`.

- `scripts/dev_tools/fix_all_runtime.py` -> `tests/scripts/dev_tools/test_fix_all*.py`. Correct.
- `tests/scripts/dev_tools/fix_all_thread_stubs.py` is test infrastructure, not a test module, and sits
  in the mirrored directory alongside its consumers. Permitted.

No test file was placed in the production source tree. **PASS.**

## Temporary Files in Tests

The rule prohibits creation or use of temporary files in tests. The added tests use `io.StringIO`
for all log capture (`build_logger` at `test_fix_all_json_cancel.py` lines 150-152) and in-memory
fakes for all command execution. No filesystem write occurs. **PASS.**

## Declared Scope Boundaries

The spec declares several files off-limits. Verified with
`git diff --name-only main...HEAD` against the forbidden set:

| Constraint | Result |
|---|---|
| `scripts/dev_tools/fix_all.py` unchanged | Confirmed |
| `scripts/dev_tools/fix_all_branches.py` unchanged | Confirmed |
| `scripts/dev_tools/fix_all_branches_extra.py` unchanged | Confirmed |
| `pyproject.toml` unchanged | Confirmed |
| No file under `.claude/rules/` | Confirmed |
| No file under `.github/instructions/` | Confirmed |
| No file under `.github/workflows/` | Confirmed |

Combined count of forbidden-scope files in the diff: **0**. **PASS.**

## Evidence Location Compliance

`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` requires evidence at
`<FEATURE>/evidence/<kind>/`.

The diff writes 24 evidence files, all under
`docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/` in the kinds
`baseline`, `regression-testing`, `qa-gates`, and `issue-updates`. Every filename carries a
`yyyy-MM-ddTHH-mm` timestamp.

A scan of the branch diff for files under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/` returned **0** matches.

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** with no
output.

**PASS.** No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

## Tone Policy

All authored prose in the diff — the production comment block at `fix_all_runtime.py` lines 145-151,
the docstrings in `fix_all_thread_stubs.py` and `test_fix_all_json_cancel.py`, and the 24 evidence
documents — uses neutral, factual, literal language. No humor, hyperbole, decorative metaphor, or
celebratory phrasing was found.

Evidence-first wording is observed with unusual rigor. Two instances are worth naming as positive
findings:

1. `evidence/regression-testing/pre-fix-repeated-run.2026-08-25T09-30.md` reports `FailureCount: 0`
   plainly, does not claim reproduction it did not achieve, and separates the measurement from the
   inference drawn about it (lines 83-113).
2. `evidence/regression-testing/runner-exception-fail-before.2026-08-25T10-03.md` lines 59-61
   voluntarily disclose that case 2 of the regression test was never evaluated in the fail-before
   run. That disclosure is against interest and is the correct handling.

**PASS.**

## Correction Section Review

`evidence/baseline/pytest-coverage.2026-08-25T09-17.md` carries a correction retracting an earlier
claim that a pre-existing failure existed in `main`. The reviewer's own full-suite run at review
time returned `4121 passed, 0 failed, 5 skipped`, which corroborates the retraction: no such
repository defect is observable. The correction is a good-faith accuracy amendment consistent with
the Evidence-First Wording rule and is **not** evidence tampering.

## Observations — Recorded, Correctly Not Actioned

These three items are pre-existing or deferred conditions. Each is confirmed present, each is
correctly outside the scope of this fix, and none is a finding against this change.

1. **`scripts/dev_tools/fix_all.py` is 628 lines**, exceeding the 500-line limit in
   `.claude/rules/general-code-change.md`. Verified by `wc -l`. The file is unchanged by this diff.
   Splitting it here would have widened the blast radius of a targeted bug fix. Should be filed
   separately.
2. **`quality-tiers.yml` does not exist at the repository root**, although
   `.claude/rules/quality-tiers.md` names it as the tier map and states that an unclassified project
   fails CI. Verified absent by direct `ls`. This does not change the obligations of this fix,
   because the line and branch coverage thresholds are uniform across T1 through T4 (Authoritative
   Decision #2) and so do not depend on a tier assignment. Should be filed separately.
3. **Research candidate E** — removing the 10 ms grace period at `fix_all_branches.py` lines 111-112
   and retiring `CANCEL_CHECK_DELAY_S` — is deferred. It is a production behavior change that the
   flake does not require, and the spec records it at line 321 as the preferred follow-up. Deferring
   it is the correct call for a bug fix of this scope.

## Conclusion

The change complies with every applicable policy in the repository policy set. There are **zero
Blocking findings**. Eight Non-blocking findings, all quality or documentation-accuracy matters, are
detailed in `code-review.2026-08-25T10-40.md`. No remediation is required, so no
`remediation-inputs` artifact is produced.
