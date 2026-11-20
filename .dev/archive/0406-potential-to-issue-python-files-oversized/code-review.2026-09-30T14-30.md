# Code Review: potential_to_issue file-size decomposition (#406)

**Review Date:** 2026-09-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406`
**Feature Folder Selection Rule:** The folder suffix `-406` matches the issue number in the branch name `bug/potential-to-issue-python-files-oversized-406`.
**Base Branch:** `main` (merge base `2b0121abf74f5862a3d12929d833504668941156`)
**Head Branch:** `bug/potential-to-issue-python-files-oversized-406` (`c9b3cb67da0d673f850d125b031c2552e92a7ca2`)
**Review Type:** Initial review (replaces the structurally invalid pass dated 2026-09-30T14-10; conclusions re-verified)

---

## Executive Summary

The branch splits two oversized Python files into cohesive modules. `scripts/dev_tools/potential_to_issue.py` shrinks from 559 to 438 lines by moving the gh subprocess adapter seam into the new `scripts/dev_tools/potential_to_issue_adapters.py` (154 lines). `tests/scripts/dev_tools/test_potential_to_issue.py` shrinks from 1076 to 282 lines, with tests redistributed to three new files, a shared support module, and the existing content test file. The non-documentation diff is eight paths, all under `scripts/dev_tools/` or `tests/scripts/dev_tools/`. The implementation is a verbatim move: public names are re-exported through `__all__`, the CLI entry stays in `potential_to_issue.py`, and the collected test count is 59 before and after with identical sorted names.

Evidence reviewed: the branch diff against the merge base, the adapters module in full, the import and `__all__` block of the host module, line counts, `artifacts/python/lcov.info`, and the executor artifacts under `evidence/`. This review re-ran Black, Ruff, Pyright, and Pytest (59 passed) and re-collected the tests. No Blocker or Major finding was identified.

**What changed:**
The gh transport dataclass (`GhResult`), the `GhClient` Protocol, `RealGhClient`, and the two label constants moved to `potential_to_issue_adapters.py`. `potential_to_issue.py` now imports them and lists them in `__all__` with the previously public names, alongside the #623 filesystem seam imports. Test monkeypatch targets were repointed from the host module to `adapters.shutil` and `adapters.subprocess`.

**Top 3 risks:**
1. Evidence timestamps inside the executor artifacts do not match commit or wall-clock time (finding M1); the values themselves were corroborated independently.
2. The Python coverage artifact is scoped to four modules, so a repo-wide Python percentage cannot be derived from it (finding I2).
3. Adapters branch coverage sits exactly at the 75% threshold because of `GhClient` Protocol stub branches (finding I1); adding branches to that file without tests would breach the threshold.

**PR readiness recommendation:** **Go** — the change is a behavior-neutral, policy-compliant decomposition with no regression in tests or coverage and all four acceptance criteria satisfied.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/evidence/qa-gates/pytest-coverage.md` | header `Timestamp:` lines across `evidence/baseline/` and `evidence/qa-gates/` (M1) | Recorded timestamps such as 2026-09-30T10-22 to 10-27 are later than the commit containing them (`c9b3cb67` at 09:59:26 -0400) and later than the wall-clock time of this review (about 10:03). Baseline stamps (09:56 to 10:00) also follow the baseline commit `c9488f46` (09:54:50). | No action is needed for merge. In future runs, populate the timestamp from the system clock at command time. | Inaccurate timestamps weaken audit provenance even though the recorded values are correct. | `git log --format='%h %cd' 2b0121ab..HEAD`; `date`; values corroborated by re-run: 59 tests, `wc -l`, `artifacts/python/lcov.info` totals. |
| Info | `scripts/dev_tools/potential_to_issue_adapters.py` | lines 43-50 (I1) | Four `GhClient` Protocol member stubs produce unhit `->exit` branches (`44`, `46`, `48`, `50`); adapters branch coverage is 12/16 = 75.0%, exactly at the threshold. Line coverage is 48/48. | Leave as is. Do not add a coverage exclusion; policy prohibits excluding production paths. Add tests if further branches are added to this module. | Threshold is satisfied but has no margin. The stubs carry no behavior and were the same partial branches at baseline (`82->exit` to `88->exit`). | `artifacts/python/lcov.info` (BRF 16, BRH 12); `evidence/qa-gates/pytest-coverage.md`. |
| Info | `artifacts/python/lcov.info` | whole file (I2) | The artifact holds only the four `potential_to_issue*` modules, so a repo-wide Python percentage is not derivable. | Regenerate with the full Python coverage command in the pre-merge pipeline to obtain the repo-wide figure. | Repo-wide thresholds are evaluated in CI; every changed module individually meets line >= 85% and branch >= 75%. | Parsed LF/LH/BRF/BRH per file: 306/310 lines, 86/96 branches across the four modules. |
| Nit | `scripts/dev_tools/potential_to_issue_adapters.py` | lines 44-50, 120, 146 (N1) | `GhClient` Protocol members and the public methods `issue_create` and `issue_view` have no docstrings. | Optional: add one-line docstrings in a later change. | Public API documentation consistency. The code moved verbatim; the omission exists at baseline, so it is not introduced by this branch. | Inspected adapters module; the diff shows a verbatim move. |
| Info | `tests/scripts/dev_tools/potential_to_issue_test_support.py` | whole file (I3) | The helper module has no `test_` prefix and is imported by the split test files; pytest does not collect it. | None. | Correct placement under `tests/` mirrors the source tree and avoids duplicated fakes across split files. | 116 lines; `pytest --collect-only` shows 59 tests, none from this file. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The adapters module has no import from `potential_to_issue.py`, so the split introduces no circular dependency.
- The move is verbatim: the diff shows no signature, message, or constant change, and the fifteen public names remain importable from `potential_to_issue` through `__all__`.
- The #623 filesystem seam is reused rather than duplicated (plan deviation D1).
- The `# noqa: S603` annotations moved with the subprocess calls they annotate. The only other `noqa` in the touched test files (`E501` in `test_potential_to_issue_content.py`) exists at the merge base.
- The CLI entry (`main` and the `__main__` guard) remains in `potential_to_issue.py`; `evidence/qa-gates/cli-help-smoke.md` records `usage: potential_to_issue.py` output.

#### Typing and API notes

- Annotations are complete and Pyright reports 0 errors, 0 warnings, 0 informations in this review.
- `GhClient` is a `Protocol` and `RealGhClient` is a `@dataclass` implementing it, as at baseline. No `Any` was introduced. No new public API surface was added.

#### Error handling and logging

- `RealGhClient.__post_init__` raises `FileNotFoundError` with an explicit message when `gh` cannot be resolved, and `_run` raises `RuntimeError` when the path is unresolved. Both are moved unchanged and covered by tests.
- No broad exception handlers and no `print` calls were added.

---

## Test Quality Audit

The 59-test family passes in this review (0.41 s). The collected count equals the baseline of 59, and the executor's name-level diff of the sorted test function names was empty. Line counts of all changed test files are at most 295, and the largest file in the family is 430 lines (pre-existing). Coverage did not regress: uncovered lines 4 to 4, partial branches 10 to 10, computed line coverage 98.68% to 98.71%.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_potential_to_issue.py` — core promotion flow tests (8); positive, negative, and error paths.
- `tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py`, `test_potential_to_issue_work_modes.py`, `test_potential_to_issue_cli_and_adapters.py` — the three new split files (6, 7, and 5 tests).
- `tests/scripts/dev_tools/potential_to_issue_test_support.py` — shared fakes; no temporary files, clock, or randomness.
- `evidence/qa-gates/coverage-delta.md` — baseline versus post-change comparison; confirmed against `artifacts/python/lcov.info`.
- `evidence/qa-gates/collected-count.md` and `evidence/baseline/collected-count.md` — name-level parity.
- `evidence/qa-gates/jest-parity.md` — 9 suites, 131 tests, equal to baseline; confirms the TypeScript side was not disturbed (recorded, not rerun).

### Quality assessment prompts

- **Determinism:** No clock, sleep, or randomness introduced; subprocess and `shutil` are monkeypatched.
- **Isolation:** Each test targets one behavior; names are unchanged from baseline.
- **Speed:** 0.41 s for 59 tests in this review.
- **Diagnostics:** Direct equality assertions produce specific pytest comparison output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection found no credentials; `test_promote_potential_body_omits_token_like_secret_strings` remains and passes. |
| No unsafe subprocess or command construction | PASS | Subprocess argument lists are built as lists, with `shell` unset and `check=False`; `# noqa: S603` moved unchanged with the existing justification. |
| Input validation at boundaries | PASS | `gh_path` is validated at construction; promotion type and work mode validation tests pass. |
| Error handling remains explicit | PASS | Specific exceptions with messages; no broad catches. |
| Configuration / path handling is safe | PASS | No new path handling; the filesystem seam from #623 is reused. |

---

## Research Log

No external research was required. The review used the repository policy files, the feature folder documents, the PR context artifacts, and local check-only commands.

---

## Verdict

The change is ready for normal PR flow. Every finding is Minor or lower, and none affects behavior, tests, or policy compliance. The file-size, coverage, typing, and test-parity requirements are satisfied, and the eight-path scope matches the plan. The Minor timestamp-provenance observation (M1) does not require remediation because the recorded values match independently recomputed figures.
