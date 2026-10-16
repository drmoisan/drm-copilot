# Host-Tools Tests After Manifest Edit (issue #953, P4-T6)

Timestamp: 2026-10-16T08-23
Command: TARGETED_RUN(after-hosttools, tests/scripts/host-tools.manifest.Tests.ps1;tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1) through SCRATCH/issue-953-p4-t6.sh (TARGETED_RUN text verbatim with JUnit SCRATCH/issue-953-after-hosttools-junit.xml and log SCRATCH/issue-953-after-hosttools.log), followed by the JUnit freshness check and JRP steps 1-4 in the same script
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:23:07.7616366Z). JRP: tests 27 (equal to the P0-T23 total of 27), failures 0, errors 0. All three HT tokens PASS.

JUNIT_TESTS: 27
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
BASELINE_JUNIT_TESTS (P0-T23): 27
TOKEN AC03-POWERSHELL-MODULES-PINNED: PASS
TOKEN AC06-POWERSHELL-MODULE-ZERO-FAILURES: PASS
TOKEN AC07-DRYRUN-COMMITTED-MANIFEST: PASS
