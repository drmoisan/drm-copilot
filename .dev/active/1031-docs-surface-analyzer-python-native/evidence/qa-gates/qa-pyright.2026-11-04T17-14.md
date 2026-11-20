# [P6-T3] Pyright

Timestamp: 2026-11-04T17-14

## Run 1

Command: poetry run pyright
EXIT_CODE: 0
Output Summary: "0 errors, 0 warnings, 0 informations" (the only other output is the pyright-python new-version notice).

## Run 2 (full, no path argument)

Command: poetry run pyright --outputjson
EXIT_CODE: 0
Output Summary: summary.filesAnalyzed 1019, summary.errorCount 0, warningCount 0. Baseline PYRIGHT_FILES_BASELINE = 992 (evidence/baseline/baseline-pyright.2026-11-04T14-57.md); expected sum 992 + 27 = 1019 (12 PYLIB files, 14 test modules, conftest.py); observed 1019, so the [P1-T1] include edit places the twelve PYLIB files in the configured analyzed set.

## Run 3 (path-scoped helper check)

Command: poetry run pyright --outputjson .claude/lib/docs/python
EXIT_CODE: 0
Output Summary: summary.filesAnalyzed 12, summary.errorCount 0.

## Loop re-run 2026-11-04T17-58

The loop restarted from [P6-T1] after the [P6-T8] PSScriptAnalyzer remediation of four new Pester files (no LIB or PYLIB file changed, so [P5-T1] was not repeated). The same commands were re-run through SCRATCH/issue-1031-loop-py.sh with EXIT_CODE 0 and identical results to those recorded above.
