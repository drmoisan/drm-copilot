# PoshQC.Tests.ps1 Post-Split Test Count (issue #953, P5-T12)

Timestamp: 2026-10-16T09-35
Command: TARGETED_RUN(split-after, tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1;tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1) through SCRATCH/issue-953-p5-t12.sh (TARGETED_RUN text verbatim with JUnit SCRATCH/issue-953-split-after-junit.xml and log SCRATCH/issue-953-split-after.log), followed in the same script by the JUnit freshness check, JRP steps 1-3, and `(Get-Content -LiteralPath <path>).Count` for both files; then, from the Bash tool, `git status --porcelain -- tests/scripts/powershell/PoshQC` and `git diff --numstat 5bc97774b8322e57abb94dfac3cd0a000a136c5b -- tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T09:35:33.0882238Z). JRP: tests 34, failures 0, errors 0. Porcelain output: ` M tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` and `?? tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1`. Numstat row (BASE_SHA 5bc97774b8322e57abb94dfac3cd0a000a136c5b against the working tree): `2	292	tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`. Post-split test count equals the pre-split count; both files are at most 500 lines.

JUNIT_TESTS: 34
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
SPLIT_PRE_TESTS: 34
SPLIT_POST_TESTS: 34
SPLIT_LINE_COUNTS: PoshQC.Tests.ps1=289 PoshQC.TestingCommands.Tests.ps1=295
