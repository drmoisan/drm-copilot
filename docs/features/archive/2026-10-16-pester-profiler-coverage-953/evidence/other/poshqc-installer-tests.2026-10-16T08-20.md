# PoshQC Installer and Seam Tests (issue #953, P3-T9)

Timestamp: 2026-10-16T08-20
Command: TARGETED_RUN(poshqc-installer, tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1;tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1;tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1) through SCRATCH/issue-953-p3-t9.sh (TARGETED_RUN text verbatim with JUnit SCRATCH/issue-953-poshqc-installer-junit.xml and log SCRATCH/issue-953-poshqc-installer.log), followed by the JUnit freshness check and JRP steps 1-3 in the same script
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:20:34.1731694Z). JRP: tests 43, failures 0, errors 0. The Install-PoshQCTool cases pass with the repaired 5.9.5 fixtures, and the default $EnsureModule seam cases pass with the added -MaximumVersion argument.

JUNIT_TESTS: 43
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
