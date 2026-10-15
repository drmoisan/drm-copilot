# P2-T16 reduced-audit handoff (evidence index)

Timestamp: 2026-10-10T09-59
Command: ls FEATURE/evidence/baseline FEATURE/evidence/regression-testing FEATURE/evidence/qa-gates FEATURE/evidence/other
EXIT_CODE: 0
Output Summary: every artifact path named below appeared in the listing. AC-1 through AC-6 are checked in issue.md; AC-7 is pending CI until P2-T17 and P2-T18 run. Paths are relative to FEATURE (docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842).

## AC-1 (M-3) - checked
- evidence/regression-testing/expect-fail-scan-root-derivation.2026-10-10T09-53.md
- evidence/regression-testing/pass-after-scan-root-derivation.2026-10-10T10-01.md
- evidence/qa-gates/bats-targeted.2026-10-10T09-57.md
- evidence/qa-gates/structural-checks.2026-10-10T09-55.md
- evidence/other/p1-t8.2026-10-10T09-55.md
- evidence/other/ac-checkoff-ac-1.2026-10-10T09-57.md

## AC-2 (N-1) - checked
- evidence/regression-testing/pass-after-scan-root-derivation.2026-10-10T10-01.md
- evidence/qa-gates/bats-targeted.2026-10-10T09-57.md
- evidence/qa-gates/structural-checks.2026-10-10T09-55.md
- evidence/other/p1-t3.2026-10-10T09-47.md
- evidence/other/p1-t6.2026-10-10T09-52.md
- evidence/other/ac-checkoff-ac-2.2026-10-10T09-58.md

## AC-3 - checked
- evidence/regression-testing/expect-fail-scan-root-derivation.2026-10-10T09-53.md
- evidence/regression-testing/pass-after-scan-root-derivation.2026-10-10T10-01.md
- evidence/qa-gates/bats-targeted.2026-10-10T09-57.md
- evidence/other/p1-t2.2026-10-10T09-47.md
- evidence/other/p1-t5.2026-10-10T09-51.md
- evidence/other/ac-checkoff-ac-3.2026-10-10T09-58.md

## AC-4 (M-2) - checked
- evidence/other/p1-t9.2026-10-10T09-57.md
- evidence/qa-gates/shellcheck.2026-10-10T09-52.md
- evidence/qa-gates/shfmt.2026-10-10T09-52.md
- evidence/qa-gates/structural-checks.2026-10-10T09-55.md
- evidence/other/ac-checkoff-ac-4.2026-10-10T09-58.md

## AC-5 (M-1) - checked
- evidence/other/p1-t10.2026-10-10T09-58.md
- evidence/qa-gates/structural-checks.2026-10-10T09-55.md
- evidence/other/ac-checkoff-ac-5.2026-10-10T09-58.md

## AC-6 - checked
- evidence/other/p1-t11.2026-10-10T10-00.md
- evidence/other/p1-t12.2026-10-10T10-00.md
- evidence/other/p1-t13.2026-10-10T10-00.md
- evidence/qa-gates/mirror-identity.2026-10-10T09-55.md
- evidence/qa-gates/bundle-parity-pytest.2026-10-10T09-55.md
- evidence/other/ac-checkoff-ac-6.2026-10-10T09-59.md

## AC-7 - pending CI (unchecked)
- evidence/qa-gates/shfmt.2026-10-10T09-52.md
- evidence/qa-gates/shellcheck.2026-10-10T09-52.md
- evidence/qa-gates/bats-targeted.2026-10-10T09-57.md
- evidence/baseline/shell-coverage-main.2026-10-10T09-35.md (BASELINE_AGGREGATE 94.2, BASELINE_ENUM_RATE 0.953)
- evidence/qa-gates/shell-coverage-pr-run.TS.md: not yet produced; created by P2-T17 after the pull request CI run exists. AC-7 is checked by P2-T18 only after P2-T17 passes.

## Supporting evidence
- Phase 0: evidence/baseline/ (all eleven artifacts listed by the ls command).
- Scope and limits: evidence/qa-gates/scope.2026-10-10T09-56.md; evidence/qa-gates/line-counts.2026-10-10T09-55.md.
- Plan state: evidence/other/plan-checklist-state.2026-10-10T09-58.md.
