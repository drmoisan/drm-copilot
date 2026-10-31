# QA Gate — PowerShell Tests and Coverage

Timestamp: 2026-10-31T16-59
Command: sh SCRATCH/issue-1013-pester-run.sh p9t6b (fresh single-process branch-current PowerShell 7 Invoke-Pester over tests/scripts, JUnit and JaCoCo coverage under SCRATCH, coverage paths the four blast-radius modules)
EXIT_CODE: 0
Output Summary: JUnit tests=13688 failures=0 errors=0 skipped=10. Line coverage: `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` 100.00% (138/138); `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` 100.00% (37/37); `.claude/lib/blast-radius/BlastRadiusCombination.psm1` 100.00% (72/72); `.claude/lib/blast-radius/BlastRadius.psm1` 100.00% (109/109). Each is at or above 85% line.

Loop history: the first P9-T6 run (tests=13688, failures=1) failed `enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree` on the `& $findRoot` closure in BlastRadiusCombination.psm1. After the fix (named function `Get-UnionFindRoot`), P9-T5 was rerun clean, the bundle copy refreshed, and this run passed with zero failures.
