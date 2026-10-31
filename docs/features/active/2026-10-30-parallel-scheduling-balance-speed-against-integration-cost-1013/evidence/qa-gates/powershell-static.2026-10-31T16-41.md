# QA Gate — PowerShell Static (rerun after the P9-T6 fix)

Timestamp: 2026-10-31T16-41
Command: sh SCRATCH/issue-1013-p9t5.sh (PowerShell 7: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 and an Invoke-Formatter comparison over the four modules and eight touched Pester files, under a 500-second timeout)
EXIT_CODE: 0
Output Summary: ANALYZE_TOTAL=0 and unchanged=True for all twelve files.

Loop history: the first P9-T6 run reported one failure in `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (`reports no Python invocation beyond the allowlist across the guarded tree`): `.claude/lib/blast-radius/BlastRadiusCombination.psm1` invoked a union-find closure through `& $findRoot`, which that scan treats as an unverifiable dynamic invocation. The closure was replaced with the named function `Get-UnionFindRoot`, and the loop restarted from P9-T5. One intermediate analyzer pass raised a null-reference inside Invoke-ScriptAnalyzer and did not exit; an isolated rerun on the same file reported zero findings, and this full rerun is clean.
