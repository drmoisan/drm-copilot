# Module-Coverage Tests (issue #953, P5-T8)

Timestamp: 2026-10-16T08-26
Command: TARGETED_RUN(module-coverage, tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1) through SCRATCH/issue-953-p5-t8.sh (TARGETED_RUN text verbatim with JUnit SCRATCH/issue-953-module-coverage-junit.xml and log SCRATCH/issue-953-module-coverage.log), followed by the JUnit freshness check and JRP steps 1-4 in the same script
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:25:59.3136930Z). JRP: tests 5, failures 0, errors 0. All five MC tokens PASS (one hit each).

JUNIT_TESTS: 5
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
TOKEN MC01-LOGGER-DEFAULT-WARNING: PASS
TOKEN MC02-LOGGER-DEFAULT-VERBOSE: PASS
TOKEN MC03-LOGGER-DEFAULT-INFORMATION: PASS
TOKEN MC04-INSTALL-POSTCHECK-THROWS: PASS
TOKEN MC05-SUBMODULE-CACHE-MISS-IMPORT: PASS
