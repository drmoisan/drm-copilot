# Acceptance-criteria check-off record (issue #737)

Timestamp: 2026-10-09T06-34

## AC-1

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/census-fail-before.2026-10-09T02-47.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/discovery-guard-fail-before.2026-10-09T03-18.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/upstream-verification.2026-10-09T02-26.md
failed AC-4 complies rows in the fail-before artifact: 104
PI-5: the suite population is computed by CR-ENUM at run time; no task lists the in-scope suites and research-record line numbers are never used as anchors.

## AC-2

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/discovery-guard-pass-after.2026-10-09T05-30.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/legacy-guard-list-removed.2026-10-09T03-19.md

## AC-3

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/discovery-guard-pass-after.2026-10-09T05-30.md

## AC-4

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/guard-final.2026-10-09T06-08.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/local-state-differential-after.2026-10-09T06-17.md
AC-4 Total=190, POPULATION-TOTAL=182

## AC-5

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/discovery-guard-pass-after.2026-10-09T05-30.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/other/process-spawning-report.2026-10-09T05-29.md

## AC-6

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/guard-final.2026-10-09T06-08.md

## AC-7

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/guard-final.2026-10-09T06-08.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/hermeticity-scan.2026-10-09T06-10.md

## AC-8

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
fail-before line: NAMED: AC-8 non-compliant* | Passed=0 | Failed=1 | Total=1

## AC-9

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
fail-before line: NAMED: AC-9 non-compliant* | Passed=0 | Failed=1 | Total=1

## AC-10

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
fail-before line: NAMED: AC-10 non-compliant* | Passed=0 | Failed=1 | Total=1

## AC-11

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
fail-before line: NAMED: AC-11 non-compliant* | Passed=0 | Failed=1 | Total=1

## AC-12

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
fail-before line: NAMED: AC-12 non-compliant* | Passed=0 | Failed=1 | Total=1

## AC-13

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/fail-before-exception.2026-10-09T05-46.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
PI-3: a branch that the unmodified predicate already handles cannot fail before the fix; each such row has a fail-before exception dossier with an absence-of-test proof under evidence/regression-testing/. Seven branches: see the P2-T9 disposition artifacts listed above.

## AC-14

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/stale-comment-search.2026-10-09T06-09.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/cr7-pr-author.2026-10-09T05-29.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/cr7-model-routing.2026-10-09T05-29.md

## AC-15

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/no-python-codex-fail-before.2026-10-09T05-33.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-aux-final.2026-10-09T06-17.md

## AC-16

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/no-python-comment-update.2026-10-09T05-34.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/no-python-codex-pass-after.2026-10-09T05-35.md
- tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1

## AC-17

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/gate-parity-pass.2026-10-09T05-42.md

## AC-18

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md

## AC-19

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/fail-before-exception.2026-10-09T05-46.md

## AC-20

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/pretooluse-registration-fail-before.2026-10-09T05-48.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md

## AC-21

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-targeted.2026-10-09T06-22.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/pretooluse-context-removed.2026-10-09T05-49.md

## AC-22

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/mirror-check.2026-10-09T06-10.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/bundle-parity.2026-10-09T06-18.md
No changed file has a mirror under extensions/drm-copilot/resources/.

## AC-23

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/suite-counts-before-after.2026-10-09T06-17.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-population-final.2026-10-09T06-12.md
PI-1 applies; the by-design suites are tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 and tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1.

## AC-24

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/local-state-differential-after.2026-10-09T06-17.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/hostile-checkpoint-created.2026-10-09T06-17.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/hostile-checkpoint-deleted.2026-10-09T06-17.md

## AC-25

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/line-counts.2026-10-09T06-10.md

## AC-26

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/hooks-unchanged.2026-10-09T06-10.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/hermeticity-scan.2026-10-09T06-10.md

## AC-27

Timestamp: 2026-10-09T06-35
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/format-check.2026-10-09T06-10.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pssa.2026-10-09T06-11.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/pester-full.2026-10-09T06-33.md
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/coverage-total.2026-10-09T06-33.md

## AC-28

Timestamp: 2026-10-09T06-36
Artifacts:
- docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/evidence-location.2026-10-09T06-35.md

