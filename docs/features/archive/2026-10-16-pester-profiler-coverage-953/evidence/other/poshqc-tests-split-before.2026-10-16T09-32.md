# PoshQC.Tests.ps1 Pre-Split Test Count (issue #953, P5-T9)

Timestamp: 2026-10-16T09-32
Command: TARGETED_RUN(split-before, tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1) through SCRATCH/issue-953-p5-t9.sh (TARGETED_RUN text verbatim with JUnit SCRATCH/issue-953-split-before-junit.xml and log SCRATCH/issue-953-split-before.log), followed in the same script by the JUnit freshness check, JRP steps 1-3, and `$o = @(Get-Content -LiteralPath tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1); $b = @(git show c73fdd7b2:tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1); "LINES=$($o.Count) UNCHANGED_SINCE_STOP=$((($o) -join [char]10) -ceq (($b) -join [char]10)) IT_LINES=$(@($o | Select-String -Pattern '^\s+It\s').Count)"`
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T09:32:10.6004276Z). JRP: tests 34, failures 0, errors 0. Printed line: `LINES=579 UNCHANGED_SINCE_STOP=True IT_LINES=34`.

JUNIT_TESTS: 34
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
SPLIT_PRE_TESTS: 34
