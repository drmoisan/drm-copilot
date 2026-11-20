# Remediation Inputs — Issue #205 (fix-all TypeScript branch)

- Timestamp: 2026-06-19T17-55
- Base branch: main (merge-base 18121fbd80ef338ab100559d50207061f9cb031f)
- Branch head: d85c09bfdb4b70d988810a1f553e1b10d3223b19
- Work Mode: minor-audit

## Source Artifacts

- policy-audit: docs/features/active/2026-06-19-fix-all-typescript-branch-205/policy-audit.2026-06-19T17-55.md
- code-review: docs/features/active/2026-06-19-fix-all-typescript-branch-205/code-review.2026-06-19T17-55.md
- feature-audit: docs/features/active/2026-06-19-fix-all-typescript-branch-205/feature-audit.2026-06-19T17-55.md

## Remediation-Required Findings

### R1 (Blocking) — Production file exceeds 500-line limit

- File: scripts/dev_tools/fix_all_runtime.py
- Current size: 626 lines. Limit: 500 lines (.claude/rules/general-code-change.md File Size Limit).
- Introduced by this change: file was 498 lines at merge-base; the feature added ~128 lines (run_typescript_branch lines 453-571 plus status-board and registration changes).
- Required action: extract the per-language branch functions into a helper module (for example, move json/shell/python/powershell/typescript branch bodies into a `fix_all_branches` module, or one module per branch) so `fix_all_runtime.py` returns under 500 lines without changing behavior.
- Acceptance: `awk 'END{print NR}' scripts/dev_tools/fix_all_runtime.py` < 500; Black/Ruff/Pyright clean; all 34 existing tests still pass.

### R2 (Blocking) — Modified-file line coverage below 85%

- File: scripts/dev_tools/fix_all_runtime.py
- Current: 84.55% line coverage (186/220); branch 79.41% (54/68). Threshold: line >= 85%, branch >= 75% (branch already passes).
- No regression: baseline was 82.20% line / 75.00% branch; the change improves both. The shortfall is in pre-existing uncovered FAIL/cancel/aggregation paths in the json, shell, python, and powershell branches.
- Uncovered lines: 75, 104-106, 111-113, 143-145, 176-178, 200-202, 230-237, 272, 382-384, 411-413, 440-442, 601, 607, 614-615.
- Required action: add unit tests covering the uncovered FAIL/cancel/aggregation paths (the FakeRunner/FakeRunnerFactory seams already support this; see existing failure-path tests in test_fix_all_branches.py for the pattern). If R1's extraction is performed, allocate the new tests to the appropriate per-branch test files to keep each test file under 500 lines.
- Acceptance: scripts/dev_tools/fix_all_runtime.py (and any modules extracted from it) report line coverage >= 85% and branch coverage >= 75% in artifacts/python/lcov.info, measured with both fix_all test files (and any new per-branch test files) included.

## Evidence Discrepancy to Correct (non-blocking, recommended)

- The executor coverage evidence (evidence/qa-gates/coverage-delta.md, pytest-final.md) documents a pytest command that runs only `tests/scripts/dev_tools/test_fix_all.py`, omitting `tests/scripts/dev_tools/test_fix_all_branches.py` where the five new TypeScript tests reside. Re-running with both files reproduces the same numbers, but the documented command should be corrected to include both test files.

## Verification Commands

```
awk 'END{print NR}' scripts/dev_tools/fix_all_runtime.py
poetry run black --check scripts/dev_tools/ tests/scripts/dev_tools/
poetry run ruff check scripts/dev_tools/ tests/scripts/dev_tools/
poetry run pyright scripts/dev_tools/
poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py
```

## Acceptance Criteria Status

All five acceptance criteria in issue.md are PASS. Remediation is required for policy gates (file size, line coverage), not for unmet acceptance criteria.
