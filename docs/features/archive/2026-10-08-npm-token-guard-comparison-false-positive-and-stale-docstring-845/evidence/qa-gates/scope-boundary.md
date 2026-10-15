# Scope Boundary

Timestamp: 2026-10-09T20-58
Command: git status --porcelain --untracked-files=all ; git fetch origin main ; git diff --name-only origin/main...HEAD
EXIT_CODE: 0
Output Summary: Worktree status is empty (all prior phases committed). Every path in the three-dot diff is the test file, a path under the feature folder, or the promoted record; none begins with .github/, src/, scripts/, or extensions/.

`git status --porcelain --untracked-files=all` output: (empty)

`git diff --name-only origin/main...HEAD` output, verbatim:

```text
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-black-check.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-branch.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-coverage-scope.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-docstring-probe.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-line-count.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-pattern-probe.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-pyright.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-pytest-module.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-ruff.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/baseline-worktree-status.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/regression-testing/docstring-probe-after-fix.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/regression-testing/fail-first-assignment-rows.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/regression-testing/pass-after-assignment-rows.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/regression-testing/pattern-probe-after-fix.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/issue.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/plan.2026-10-08T23-42.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/research/research.2026-10-08T23-50.md
docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/spec.md
docs/features/potential/promoted/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring.md
tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

The status command ran before the Phase 3 artifacts in `evidence/qa-gates/` were written, hence the empty status; those files are inside the feature folder and are committed in the final commit.
