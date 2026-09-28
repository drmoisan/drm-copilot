# Constraint Verification — Changed-File List (Phase 7, [P7-T2])

Timestamp: 2026-08-25T10-19

Command: three commands, each run separately from the worktree root so that no exit code is masked by a pipe —

1. `git diff --name-only main...HEAD` — EXIT_CODE 0, 33 paths
2. `git diff --name-only main --` — EXIT_CODE 0, 33 paths
3. `git status --porcelain --untracked-files=all` — EXIT_CODE 0, 1 path

EXIT_CODE: 0

The union of the three result sets was computed by concatenation followed by `sort -u`, after stripping the two-character status prefix from the porcelain output.

## Merge-base note (why the anticipated #534 paths are absent)

The plan anticipated that this branch would carry the merge of pull request #534 and that the union would therefore include roughly 2500 pre-existing paths under `docs/features/completed/`. That is not the case at final measurement, and the reason is verified rather than assumed:

```
git merge-base main HEAD  -> 0c7469f8c6e2a8e9915789875b436085e704b114
git rev-parse main        -> 0c7469f8c6e2a8e9915789875b436085e704b114
git rev-parse origin/main -> 0c7469f8c6e2a8e9915789875b436085e704b114
```

Local `main`, `origin/main`, and the merge base are the same commit (`0c7469f8`, "Merge pull request #548"). Pull request #534 has since merged into `main`, so its paths are shared with `main` and are correctly excluded from a diff against it. Both the three-dot and the two-dot form therefore return the identical 33-path set, which is exactly this item's own work. This is a cleaner union than the plan projected, not a missing one.

## (a) Numeric total path count of the union

**34 paths.** (33 committed paths, identical in the three-dot and two-dot forms, plus 1 untracked path.)

## (b) Complete enumeration of every union path ending in `.py`

Exactly five, and these are exactly the five write-set source paths named in [P7-T1]:

1. `scripts/dev_tools/fix_all_runtime.py`
2. `tests/scripts/dev_tools/fix_all_thread_stubs.py`
3. `tests/scripts/dev_tools/test_fix_all.py`
4. `tests/scripts/dev_tools/test_fix_all_failure_paths.py`
5. `tests/scripts/dev_tools/test_fix_all_json_cancel.py`

No other path in the union ends in `.py`. The count was verified with `grep -c '\.py$'`, which returned `5`.

**Read-only production files confirmed absent.** Verified with exact whole-line matching (`grep -cx`), because a suffix pattern such as `fix_all\.py$` produces a false positive against `tests/scripts/dev_tools/test_fix_all.py`:

- `grep -cx 'scripts/dev_tools/fix_all.py'` -> **0**
- `grep -cx 'scripts/dev_tools/fix_all_branches.py'` -> **0**

Independently corroborated: `grep '^scripts/'` over the union returns a single line, `scripts/dev_tools/fix_all_runtime.py`. Neither `scripts/dev_tools/fix_all.py` nor `scripts/dev_tools/fix_all_branches.py` is changed by this diff.

## (c) Complete enumeration of every union path under the feature folder

29 paths, all under `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/` (listed feature-folder-relative):

1. `evidence/baseline/black-check.2026-08-25T09-17.md`
2. `evidence/baseline/phase0-instructions-read.2026-08-25T09-17.md`
3. `evidence/baseline/pyright.2026-08-25T09-17.md`
4. `evidence/baseline/pytest-coverage.2026-08-25T09-17.md`
5. `evidence/baseline/repo-state.2026-08-25T09-17.md`
6. `evidence/baseline/ruff-check.2026-08-25T09-17.md`
7. `evidence/baseline/targeted-module-coverage.2026-08-25T09-17.md`
8. `evidence/qa-gates/banned-api-inspection.2026-08-25T09-43.md`
9. `evidence/qa-gates/file-size-limit.2026-08-25T10-16.md`
10. `evidence/qa-gates/final-black.2026-08-25T10-12.md`
11. `evidence/qa-gates/final-loop-closure.2026-08-25T10-15.md`
12. `evidence/qa-gates/final-pyright.2026-08-25T10-13.md`
13. `evidence/qa-gates/final-pytest-coverage.2026-08-25T10-14.md`
14. `evidence/qa-gates/final-ruff.2026-08-25T10-13.md`
15. `evidence/qa-gates/json-cancel-branch-coverage.2026-08-25T09-58.md`
16. `evidence/qa-gates/runner-hardening-coverage.2026-08-25T10-06.md`
17. `evidence/regression-testing/complete-all-unmodified.2026-08-25T09-43.md`
18. `evidence/regression-testing/fail-before-exception.2026-08-25T09-30.md`
19. `evidence/regression-testing/missing-result-path-preserved.2026-08-25T10-07.md`
20. `evidence/regression-testing/post-fix-repeated-run.2026-08-25T09-43.md`
21. `evidence/regression-testing/post-fix-warnings.2026-08-25T09-43.md`
22. `evidence/regression-testing/pre-fix-repeated-run.2026-08-25T09-30.md`
23. `evidence/regression-testing/pre-fix-warnings.2026-08-25T09-30.md`
24. `evidence/regression-testing/runner-exception-fail-before.2026-08-25T10-03.md`
25. `evidence/regression-testing/skip-branch-relocation.2026-08-25T09-37.md`
26. `issue.md`
27. `plan.2026-08-23T23-23.md`
28. `research/2026-08-23T23-25-fix-all-cancel-propagation-race.md`
29. `spec.md`

All 29 resolve to canonical locations: the four feature documents and the evidence tree in the canonical kinds `baseline`, `qa-gates`, and `regression-testing`. No evidence path under an `artifacts` directory appears in the union.

29 feature-folder paths plus 5 `.py` paths accounts for all 34 union paths.

## (d) Numeric count of union paths under `docs/features/completed/`

**0.** Counted, not enumerated, per the task. The figure is zero for the merge-base reason recorded above, not because the count was omitted.

## Negative assertions required by the acceptance condition

Each verified by a counting command over the union:

| Assertion | Command | Result |
| --- | --- | --- |
| No path under the Claude rules directory | `grep -c '^\.claude/rules/'` | 0 |
| No path under the Copilot instructions directory | `grep -c '^\.github/instructions/'` | 0 |
| No CI workflow path | `grep -c '^\.github/workflows/'` | 0 |
| No Poetry project file | `grep -c 'pyproject.toml'` | 0 |

Output Summary: The union is non-empty at 34 paths. Enumeration (b) consists of exactly the five write-set source paths and contains no other path; in particular it contains neither `scripts/dev_tools/fix_all.py` nor `scripts/dev_tools/fix_all_branches.py`, both confirmed at zero by exact whole-line match. Enumeration (c) lists 29 paths, all inside this feature's own folder. Count (d) is 0. The full union contains no path under `.claude/rules/`, no path under `.github/instructions/`, no CI workflow path, and no `pyproject.toml`. Every clause of the [P7-T2] acceptance condition is satisfied.
