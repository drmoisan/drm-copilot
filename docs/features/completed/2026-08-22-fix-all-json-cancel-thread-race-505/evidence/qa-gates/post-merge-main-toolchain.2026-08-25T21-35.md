# Post-Merge Toolchain Verification — Issue #505

Timestamp: 2026-08-25T21-35

## Why this artifact exists

`origin/main` advanced from `0c7469f8` (this branch's merge base) to `52992bef` while the
implementation work was in progress. `52992bef` was merged into
`bug/fix-all-json-cancel-thread-race-505-r2` at merge commit `1a67d2c2`, which is the tree CI will
actually build. The Phase 6 final-QC artifacts under this same folder were recorded against the
pre-merge tree, so they do not, on their own, evidence the merged state. This artifact re-runs the
full mandatory four-stage Python toolchain loop against the merged tree.

## Merge scope

Command: `git diff --name-only 8d11c86b 1a67d2c2 -- "*.py" "*.ts" "*.ps1" "pyproject.toml"`
EXIT_CODE: 0
Output Summary: Empty result. The merge of `origin/main` introduced **zero** Python, TypeScript,
PowerShell, or Poetry-project files. The 91 files it did change are documentation, feature-folder
records, Claude settings, and skill frontmatter. No file in this change's write set was touched by
the merge, and no file this change depends on was touched by the merge.

## Stage 1 — Formatting

Command: `poetry run black --check .`
EXIT_CODE: 0
Output Summary: `445 files would be left unchanged.` Zero files would be reformatted.

## Stage 2 — Linting

Command: `poetry run ruff check .`
EXIT_CODE: 0
Output Summary: `All checks passed!` Finding count: 0.

## Stage 3 — Type checking

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Error count: 0.

## Stage 4 — Tests with coverage

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -q`
EXIT_CODE: 0
Output Summary: `4121 passed, 5 skipped in 35.37s`. Passed: 4121. Failed: 0. Skipped: 5.

Coverage read from `artifacts/python/coverage.json`, never from the terminal `TOTAL` row:

| Metric | JSON key | Value | Threshold | Verdict |
| --- | --- | --- | --- | --- |
| Repository line coverage | `totals.percent_statements_covered` | 92.6302414231258 | >= 85 | PASS |
| Repository branch coverage | `totals.percent_branches_covered` | 85.23306627822286 | >= 75 | PASS |

Targeted modules, read from the `files` entries under their `summary` keys:

| Module | `percent_statements_covered` | `percent_branches_covered` | `missing_lines` |
| --- | --- | --- | --- |
| `scripts/dev_tools/fix_all_runtime.py` | 98.78048780487805 | 95.45454545454545 | `[77]` |
| `scripts/dev_tools/fix_all_branches.py` | 100.0 | 100.0 | `[]` |

Line 77 of `scripts/dev_tools/fix_all_runtime.py` is pre-existing and is not a line added or
modified by this change; every line added by the `_runner` hardening in Phase 5 is covered. This
matches the Phase 5 and Phase 7 findings recorded in `runner-hardening-coverage.2026-08-25T10-06.md`
and `coverage-delta.2026-08-25T10-21.md`.

## Loop closure

Command: the four stages above, in the order `black` -> `ruff` -> `pyright` -> `pytest`
EXIT_CODE: 0
Output Summary: One loop iteration was performed. All four stages completed consecutively, every
stage exited 0, and no stage modified a file (`black --check` is non-mutating and reported zero
files needing reformatting; the working tree was clean before and after the loop). The mandatory
toolchain loop in `.claude/rules/general-code-change.md` is therefore satisfied against the merged
tree at `1a67d2c2`.

## Effect on the audit verdicts

The three feature-review artifacts dated `2026-08-25T10-40` recorded zero Blocking findings against
the pre-merge tree. Because the merge introduced no code file, no evidence supporting those verdicts
is invalidated by it, and the toolchain result above is numerically consistent with the pre-merge
final-QC artifacts (identical pass count of 4121, identical skip count of 5).
