# r3 Guard-Suite Baseline (P0-T19)

Timestamp: 2026-10-16T20-56
Command: TARGETED_RUN(baseline-guard, GUARD_SET) through the Tool route (SCRATCH/issue-953-r3-p0-t19.sh), the same text as P0-T18 with ISSUE953_PATHS = 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1;tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1;tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1;tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1;tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1', JUnit SCRATCH/issue-953-r3-baseline-guard-junit.xml, log SCRATCH/issue-953-r3-baseline-guard.log, followed by the validity check and JRP.
EXIT_CODE: 0
Output Summary:
- EXIT_CODE=0 START_UTC=2026-10-16T20:53:59.5193711Z; VALID=True
- JRP tests=402 failures=0 errors=0
- TOKEN_CHECK issue #850 changed-file constraints.baseline mock interception probe hits=1 PASS
- TOKEN_CHECK session-root-reads-850.Constraints.Tests.ps1 complies with the baseline isolation form hits=1 PASS
- TOKEN_CHECK session-root-reads-850.Constraints.Tests.ps1 calls the interception probe hits=1 PASS
- TOKEN_CHECK AC-6 helper imports without Force hits=1 PASS
- Result: PASS (TARGET_SUITE passes when it runs first in a clean process).

R3_GUARD_BASELINE_TESTS: 402
