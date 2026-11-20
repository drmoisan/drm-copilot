# Policy Compliance Audit — Issue #205 (fix-all TypeScript branch)

- Timestamp: 2026-06-19T17-55
- Feature folder: docs/features/active/2026-06-19-fix-all-typescript-branch-205
- Work Mode: minor-audit (from issue.md)
- Reviewer: feature-review agent
- Scope: full branch diff, feature/fix-all-typescript-branch-205 vs base main

## Scope and Baseline

- Resolved base branch: main
- Merge-base SHA: 18121fbd80ef338ab100559d50207061f9cb031f
- Branch head SHA: d85c09bfdb4b70d988810a1f553e1b10d3223b19
- PR context artifacts: artifacts/pr_context.summary.txt, artifacts/pr_context.appendix.txt (regenerated during this review; previously absent)

### Changed files (git diff --name-status base...HEAD)

Production / test code:
- M scripts/dev_tools/fix_all_runtime.py
- M tests/scripts/dev_tools/test_fix_all.py
- A tests/scripts/dev_tools/test_fix_all_branches.py

Documentation / evidence (non-code):
- A docs/features/active/2026-06-19-fix-all-typescript-branch-205/issue.md
- A docs/features/active/2026-06-19-fix-all-typescript-branch-205/plan.2026-06-19T17-31.md
- A docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/{black,pyright,pytest,ruff}-baseline.md, phase0-instructions-read.md
- A docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/{black-final,coverage-delta,pyright-final,pytest-final,ruff-final}.md, test-file-split-2026-06-19T21-51.md

Languages with changed code files on the branch: Python only. No TypeScript, PowerShell, or C# source files are changed in the branch diff (the feature adds a Python orchestration branch that *invokes* npm scripts; no .ts/.cs/.ps1 files are modified).

## Rejected Scope Narrowing

None. The caller prompt explicitly instructed: "Determine scope yourself from the branch diff; do not narrow scope." No scope-narrowing instruction was supplied. The audit covers the full branch diff against main.

## Language Determination and Coverage Verdicts

| Language | Changed code files on branch | Coverage artifact | Coverage verdict |
|---|---|---|---|
| Python | Yes (3) | artifacts/python/lcov.info (present) | See Python section below |
| TypeScript | No | n/a | N/A (zero changed .ts files) |
| PowerShell | No | n/a | N/A (zero changed .ps1 files) |
| C# | No | n/a | N/A (zero changed .cs files) |

N/A is acceptable for TypeScript, PowerShell, and C# because none of those languages have changed files in the branch diff. Despite the feature being named "fix-all-typescript-branch," the change is implemented entirely in Python; the only TypeScript involvement is the Python branch shelling out to `npm run` scripts.

## Toolchain Results (Python)

Commands run are recorded in Appendix B. All commands are check-only.

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting (Black) | `poetry run black --check <changed files>` | 3 files would be left unchanged | PASS |
| Linting (Ruff) | `poetry run ruff check <changed files>` | All checks passed | PASS |
| Type checking (Pyright) | `poetry run pyright <changed files>` | 0 errors, 0 warnings, 0 informations | PASS |
| Unit tests (Pytest) | `poetry run pytest <both fix_all test files>` | 34 passed | PASS |

## Coverage (Python)

Coverage artifact inspected: artifacts/python/lcov.info (regenerated during this review by running the full module test set: test_fix_all.py + test_fix_all_branches.py).

### Per-file (modified file)

| File | Line coverage | Branch coverage | Changed-code uncovered lines |
|---|---|---|---|
| scripts/dev_tools/fix_all_runtime.py | 84.55% (186/220) | 79.41% (54/68) | none |

- Branch coverage 79.41% >= 75% threshold: PASS.
- No regression on changed lines: PASS. Baseline (merge-base) was 82.20% line / 75.00% branch; post-change is 84.55% line / 79.41% branch. The change increases both metrics. All added TypeScript-branch statements (production lines 453-571, status-board line 40 and lines 51-59, registration line 578) are covered.
- Line coverage 84.55% < 85% modified-file threshold: **FAIL against the >= 85% threshold**. The shortfall is in pre-existing uncovered FAIL/cancel/aggregation paths in the json, shell, python, and powershell branches (uncovered lines: 75, 104-106, 111-113, 143-145, 176-178, 200-202, 230-237, 272, 382-384, 411-413, 440-442, 601, 607, 614-615). None of these lines are within the changed-code range. This is a pre-existing gap, not a regression, but the module remains below the absolute 85% line threshold.

### Repo-wide (Python)

The lcov.info denominator includes all `scripts/dev_tools` modules (8235 statements) but the coverage run exercised only the fix_all test set, so the repo-wide aggregate (4.27%) reflects a module-scoped run, not a full-suite run. This figure is not a valid repo-wide measurement and is recorded only for transparency. A full-suite coverage run was not part of the executor evidence and is not re-run here per the inspect-existing-artifacts model. Repo-wide line/branch verdict is therefore UNVERIFIED for the full suite; the authoritative, in-scope measurement is the per-file modified-file result above.

### Evidence discrepancy (recorded)

The executor coverage evidence (evidence/qa-gates/coverage-delta.md, pytest-final.md) documents the command `poetry run pytest ... tests/scripts/dev_tools/test_fix_all.py` only. The five new TypeScript-branch tests reside in `tests/scripts/dev_tools/test_fix_all_branches.py`, which the documented command does not include. Re-running with both files (the complete module test set) reproduces the same per-file numbers (84.55% line / 79.41% branch), so the conclusion stands, but the documented evidence command was incomplete and should reference both test files.

## File Size Limit (500 lines)

| File | Lines | Verdict |
|---|---|---|
| scripts/dev_tools/fix_all_runtime.py | 626 | FAIL (> 500) |
| tests/scripts/dev_tools/test_fix_all.py | 434 | PASS |
| tests/scripts/dev_tools/test_fix_all_branches.py | 391 | PASS |

`scripts/dev_tools/fix_all_runtime.py` is 626 lines, exceeding the 500-line production-code limit. This violation is introduced by this feature: at the merge-base (18121fbd) the file was 498 lines (under the limit); the feature added the `run_typescript_branch` function (production lines 453-571) plus status-board and registration changes, totaling ~128 added lines and pushing the file to 626 lines. This is a FAIL against the file-size policy directly attributable to the change. The test files were correctly split into two to respect the limit, but the production file was not refactored. Remediation: extract the per-language branch functions (json/shell/python/powershell/typescript) into separate modules or a helper module so `fix_all_runtime.py` returns under 500 lines.

## Suppressions, Banned APIs, Test Hygiene

- `# noqa` / `# type: ignore` in changed files: none found. PASS.
- Banned test APIs (setTimeout, Thread.Sleep, time.sleep, Date.now outside clock): none found. PASS.
- Temporary files in tests (prohibited): none found. PASS.
- External dependencies in unit tests: none; tests use FakeRunner/FakeRunnerFactory injected via runner_factory seam and StringIO loggers. PASS.

## Evidence Location Compliance

- `git diff --name-only base...HEAD | grep '^artifacts/(baselines|qa|evidence|coverage)/'`: no matches. No evidence written to non-canonical artifacts paths.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations.
- All feature evidence is under the canonical `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/<kind>/` path.
- Verdict: PASS.

## modified-workflow-needs-green-run

- `git diff --name-only base...HEAD | grep '^(.github/workflows/|scripts/benchmarks/|.github/actions/)'`: no matches.
- The rule does not fire. Verdict: PASS (not applicable; no CI-gate-modifying paths changed).

## Verdict Summary

| Policy area | Verdict |
|---|---|
| Formatting (Black) | PASS |
| Linting (Ruff) | PASS |
| Type checking (Pyright) | PASS |
| Unit tests | PASS (34 passed) |
| Coverage — changed-code | PASS (100%, no uncovered changed lines) |
| Coverage — branch (modified file) | PASS (79.41% >= 75%) |
| Coverage — line (modified file) | FAIL (84.55% < 85%) |
| Coverage — no regression | PASS |
| Coverage — repo-wide (full suite) | UNVERIFIED (module-scoped run only) |
| File size limit | FAIL (fix_all_runtime.py 626 lines > 500) |
| Suppressions / banned APIs / test hygiene | PASS |
| Evidence location compliance | PASS |
| modified-workflow-needs-green-run | PASS (rule not triggered) |

Overall policy verdict: PARTIAL. Two FAIL findings (modified-file line coverage below 85%; production file above 500-line limit). Both are remediation-required findings. Neither is a regression introduced by the feature's changed code, but both are absolute-threshold policy violations present on the branch.

## Appendix B — Command Reference

```
git diff --name-status 18121fbd80ef338ab100559d50207061f9cb031f...HEAD
poetry run black --check scripts/dev_tools/fix_all_runtime.py tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py
poetry run ruff check scripts/dev_tools/fix_all_runtime.py tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py
poetry run pyright scripts/dev_tools/fix_all_runtime.py tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py
poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base main
```
