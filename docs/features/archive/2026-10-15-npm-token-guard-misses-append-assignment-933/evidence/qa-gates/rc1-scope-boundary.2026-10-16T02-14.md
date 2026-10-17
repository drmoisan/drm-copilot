# rc1 Scope Boundary (P2-T17)

Timestamp: 2026-10-16T02-14
Command: git status --porcelain --untracked-files=all; git fetch origin main; git diff --name-only origin/main...HEAD
EXIT_CODE: 0
Output Summary: every path in both listings is on the P2-T17 allowlist (the two test-tree files, the named feature-folder documents, or a path under the feature evidence/ folder); no path begins with .github/, src/, scripts/, extensions/, .codex/, .claude/, or tests/fixtures/.

Abbreviation used below: FEATURE = docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933

## git status --porcelain --untracked-files=all (exit 0)

```text
 M FEATURE/remediation-plan.2026-10-16T00-56.md
?? FEATURE/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T02-11.md
?? FEATURE/evidence/qa-gates/rc1-docstring-f1.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-docstring-f3.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-issue-unchanged.2026-10-16T02-14.md
?? FEATURE/evidence/qa-gates/rc1-line-count.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-line-width.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-node-listing.2026-10-16T02-11.md
?? FEATURE/evidence/qa-gates/rc1-regex-unchanged.2026-10-16T02-13.md
```

## git fetch origin main (exit 0)

```text
 * branch                main       -> FETCH_HEAD
```

## git diff --name-only origin/main...HEAD (exit 0)

```text
FEATURE/code-review.2026-10-16T00-50.md
FEATURE/evidence/baseline/baseline-black-check.2026-10-16T00-13.md
FEATURE/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md
FEATURE/evidence/baseline/baseline-coverage-thresholds.2026-10-16T00-18.md
FEATURE/evidence/baseline/baseline-docstring-pin.2026-10-16T00-20.md
FEATURE/evidence/baseline/baseline-docstring-support.2026-10-16T00-20.md
FEATURE/evidence/baseline/baseline-environment.2026-10-16T00-12.md
FEATURE/evidence/baseline/baseline-line-count.2026-10-16T00-20.md
FEATURE/evidence/baseline/baseline-mode-check.2026-10-16T00-11.md
FEATURE/evidence/baseline/baseline-production-scope.2026-10-16T00-21.md
FEATURE/evidence/baseline/baseline-pyright.2026-10-16T00-14.md
FEATURE/evidence/baseline/baseline-pytest-coverage.2026-10-16T00-18.md
FEATURE/evidence/baseline/baseline-pytest-guard.2026-10-16T00-14.md
FEATURE/evidence/baseline/baseline-ruff-check.2026-10-16T00-13.md
FEATURE/evidence/baseline/phase0-instructions-read.2026-10-16T00-08.md
FEATURE/evidence/other/phase1-handoff.2026-10-16T00-22.md
FEATURE/evidence/other/rc1-phase1-handoff.2026-10-16T01-39.md
FEATURE/evidence/qa-gates/ac-node-listing.2026-10-16T00-37.md
FEATURE/evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md
FEATURE/evidence/qa-gates/ac5-docstring-pin.2026-10-16T00-37.md
FEATURE/evidence/qa-gates/ac5-docstring-support.2026-10-16T00-37.md
FEATURE/evidence/qa-gates/ac8-line-count.2026-10-16T00-38.md
FEATURE/evidence/qa-gates/ac9-ci-pending.2026-10-16T00-39.md
FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md
FEATURE/evidence/qa-gates/final-black.2026-10-16T00-29.md
FEATURE/evidence/qa-gates/final-black.2026-10-16T00-30.md
FEATURE/evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md
FEATURE/evidence/qa-gates/final-coverage-thresholds.2026-10-16T00-34.md
FEATURE/evidence/qa-gates/final-loop-single-pass.2026-10-16T00-35.md
FEATURE/evidence/qa-gates/final-pyright.2026-10-16T00-30.md
FEATURE/evidence/qa-gates/final-pytest-coverage.2026-10-16T00-34.md
FEATURE/evidence/qa-gates/final-pytest-guard.2026-10-16T00-31.md
FEATURE/evidence/qa-gates/final-ruff.2026-10-16T00-30.md
FEATURE/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T01-52.md
FEATURE/evidence/qa-gates/rc1-final-black.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-coverage-thresholds.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-loop-single-pass.2026-10-16T01-48.md
FEATURE/evidence/qa-gates/rc1-final-pyright.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-pytest-guard.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-ruff.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/scope-boundary.2026-10-16T00-39.md
FEATURE/evidence/regression-testing/expect-fail-p1-t2.2026-10-16T00-23.md
FEATURE/evidence/regression-testing/expect-fail-p1-t3.2026-10-16T00-23.md
FEATURE/evidence/regression-testing/expect-fail-p1-t4.2026-10-16T00-24.md
FEATURE/evidence/regression-testing/fail-before.2026-10-16T00-25.md
FEATURE/evidence/regression-testing/pass-after.2026-10-16T00-27.md
FEATURE/evidence/regression-testing/rc1-pass-after.2026-10-16T01-42.md
FEATURE/evidence/regression-testing/rc1-regex-after-edit.2026-10-16T01-42.md
FEATURE/evidence/regression-testing/rc1-rows-f1.2026-10-16T01-40.md
FEATURE/evidence/regression-testing/rc1-rows-f2-detect.2026-10-16T01-40.md
FEATURE/evidence/regression-testing/rc1-rows-f2-ignore.2026-10-16T01-41.md
FEATURE/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T01-29.md
FEATURE/evidence/remediation-baseline/rc1-baseline-black-check.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-characterization.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-coverage-thresholds.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-docstring-f1.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-docstring-f3.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-environment.2026-10-16T01-31.md
FEATURE/evidence/remediation-baseline/rc1-baseline-id-absence.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-line-count.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-line-width.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-mode-check.2026-10-16T01-30.md
FEATURE/evidence/remediation-baseline/rc1-baseline-production-scope.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pyright.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pytest-coverage.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pytest-guard.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-regex.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-ruff-check.2026-10-16T01-32.md
FEATURE/feature-audit.2026-10-16T00-50.md
FEATURE/issue.md
FEATURE/plan.2026-10-15T17-44.md
FEATURE/policy-audit.2026-10-16T00-50.md
FEATURE/remediation-inputs.2026-10-16T00-56.md
FEATURE/remediation-plan.2026-10-16T00-56.md
FEATURE/research/research.2026-10-15T17-50.md
tests/scripts/dev_tools/npm_token_guard_test_support.py
tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

Allowlist check: every listed path is one of the two tests/scripts/dev_tools files, one of FEATURE/issue.md, plan.2026-10-15T17-44.md, research/research.2026-10-15T17-50.md, policy-audit.2026-10-16T00-50.md, code-review.2026-10-16T00-50.md, feature-audit.2026-10-16T00-50.md, remediation-inputs.2026-10-16T00-56.md, remediation-plan.2026-10-16T00-56.md, or a path under FEATURE/evidence/. Paths outside the allowlist: none.
