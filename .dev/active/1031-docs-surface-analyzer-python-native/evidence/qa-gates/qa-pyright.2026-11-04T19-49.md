# [P6-T3] Pyright (fresh run on the post-merge head)

Timestamp: 2026-11-04T19-49

## Run 1

Command: poetry run pyright
EXIT_CODE: 0
Output Summary: "0 errors, 0 warnings, 0 informations".

## Run 2 (full, no path argument)

Command: poetry run pyright --outputjson
EXIT_CODE: 0
Output Summary: summary.filesAnalyzed 1019, summary.errorCount 0, warningCount 0.

## Run 3 (path-scoped helper check)

Command: poetry run pyright --outputjson .claude/lib/docs/python
EXIT_CODE: 0
Output Summary: summary.filesAnalyzed 12, summary.errorCount 0.

## Baseline after the integration merge ([P0-T5] re-run condition)

The branch was merged with the integration branch (e34dbba74) after [P0-T5], so the no-path baseline count was re-measured at the new MERGE_BASE (`git merge-base origin/epic/documentation-estate-tooling-integration HEAD` = 729ff55ef6b8fcfcf632d9d2220a674bb437bf7e).

Command: sh SCRATCH/issue-1031-base-pyright.sh (`git archive MERGE_BASE` extracted under SCRATCH/base, then `poetry run pyright --outputjson -p SCRATCH/base`)
EXIT_CODE: 1
Output Summary: summary.filesAnalyzed 992. The 27 errors are all `reportArgumentType` module-identity mismatches of the discovery-runtime package between the extracted tree and the worktree virtual environment; they do not affect the analyzed file set. The merge changed no `.py`, `.pyi` or `pyproject.toml` path (`git diff --name-status c83bdf64c e34dbba74` over those patterns is empty), consistent with the unchanged count.

PYRIGHT_FILES_BASELINE: 992 (baseline-pyright.2026-11-04T14-57.md, confirmed at the new MERGE_BASE)
Expected sum: 992 + 27 = 1019
Observed: 1019. Acceptance met.

git status --porcelain identical before and after the runs.
