# Acceptance-Criteria Check-Off (P14-T1 through P14-T29)

Timestamp: 2026-09-29T21-15
Command: Line edits in FEATURE/spec.md and FEATURE/issue.md changing `- [ ] AC-n:` to `- [x] AC-n:` for n = 1..29 (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 29 of 29 acceptance criteria checked off in both spec.md and issue.md; every cited artifact exists with passing acceptance.

| AC | Plan task | Cited evidence (artifact under FEATURE/evidence/) |
| --- | --- | --- |
| AC-1 | P14-T1 | regression-testing/claude-python-routing-before-fix.2026-09-29T19-35 (32 failed), regression-testing/claude-python-routing-after-fix.2026-09-29T19-44 (32 passed) |
| AC-2 | P14-T2 | regression-testing/codex-python-routing-before-fix.2026-09-29T20-10 (34 failed), regression-testing/codex-python-routing-after-fix.2026-09-29T20-18 (34 passed) |
| AC-3 | P14-T3 | claude-python-routing-after-fix, codex-python-routing-after-fix (case D3 in each) |
| AC-4 | P14-T4 | claude-python-routing-after-fix, codex-python-routing-after-fix (L1-L3), regression-testing/xtest-after-python-fix.2026-09-29T20-18 |
| AC-5 | P14-T5 | claude-python-routing-after-fix, codex-python-routing-after-fix (fallback rows 4-5, L3), regression-testing/route-parity-after.2026-09-29T20-01 |
| AC-6 | P14-T6 | claude-python-routing-after-fix, codex-python-routing-after-fix (fallback rows 1-9, S3), route-parity-after |
| AC-7 | P14-T7 | claude-python-routing-after-fix, codex-python-routing-after-fix (P1-P3), regression-testing/claude-python-existing-after-fix.2026-09-29T19-44 |
| AC-8 | P14-T8 | routing-after-fix suites (override cases), baseline/ac22-ac8-nonvacuity.2026-09-29T19-14, qa-gates/ac8-no-env-override.2026-09-29T20-54 |
| AC-9 | P14-T9 | claude-python-routing-after-fix, claude-python-existing-after-fix, regression-testing/pretooluse-schema.2026-09-29T19-44, codex-python-routing-after-fix, regression-testing/codex-contracts-p6.2026-09-29T20-20 |
| AC-10 | P14-T10 | P6-T1 acceptance counts, codex-python-routing-after-fix (E1-E3), codex-contracts-p6 |
| AC-11 | P14-T11 | qa-gates/ac11-no-temp-files.2026-09-29T20-54, seam cases in both routing-after-fix suites |
| AC-12 | P14-T12 | regression-testing/route-helper-created.2026-09-29T19-17, P4-T3 pair hash, qa-gates/ac12-helper.2026-09-29T20-52 |
| AC-13 | P14-T13 | baseline/ac13-helper-names.2026-09-29T19-14 (non-vacuity), qa-gates/ac13-helper-names.2026-09-29T20-52 |
| AC-14 | P14-T14 | regression-testing/route-parity-before-codex-helper.2026-09-29T19-50, route-parity-after, qa-gates/route-helper-coverage.2026-09-29T21-02 |
| AC-15 | P14-T15 | other/old-route-helper-removed.2026-09-29T19-26, qa-gates/ac15-registration.2026-09-29T20-52, regression-testing/codex-contracts-p4.2026-09-29T20-03 |
| AC-16 | P14-T16 | cpsrtest-after-switch, cpstest-after-switch, xpsrtest-after-rewire, xtest-after-rewire, xtest-after-python-fix, qa-gates/ac16-routing-suite-diff.2026-09-29T20-52, qa-gates/live-state-final.2026-09-29T21-07 |
| AC-17 | P14-T17 | claude-python-routing-after-fix, claude-python-existing-after-fix, codex-python-routing-after-fix, xtest-after-python-fix, codex-contracts-p6 |
| AC-18 | P14-T18 | baseline/ac18-sweep.2026-09-29T19-13 (non-vacuity), qa-gates/ac18-sweep.2026-09-29T20-50 |
| AC-19 | P14-T19 | qa-gates/ac19-routing-text.2026-09-29T20-50 |
| AC-20 | P14-T20 | baseline/ac20-test-clause.2026-09-29T19-14 (non-vacuity), qa-gates/ac20-test-clause.2026-09-29T20-50 |
| AC-21 | P14-T21 | qa-gates/ac21-routing-target.2026-09-29T20-50 |
| AC-22 | P14-T22 | baseline/ac22-ac8-nonvacuity (non-vacuity), qa-gates/ac22-budget-input.2026-09-29T20-50 |
| AC-23 | P14-T23 | other/codex-variants-regenerated.2026-09-29T20-40, qa-gates/codex-variants-check.2026-09-29T20-41, regression-testing/codex-surface-contracts.2026-09-29T20-42 |
| AC-24 | P14-T24 | qa-gates/python-parity.2026-09-29T21-09 (KL-510 STATE-ONLY only), qa-gates/ts-manifest-completeness.2026-09-29T21-09, codex-contracts-p6, qa-gates/mirror-hashes-final.2026-09-29T21-11 |
| AC-25 | P14-T25 | qa-gates/ac25-scope-unchanged.2026-09-29T20-54 |
| AC-26 | P14-T26 | qa-gates/line-counts-final.2026-09-29T21-07, qa-gates/pester-codex-hooks.2026-09-29T21-06, codex-contracts-p6 |
| AC-27 | P14-T27 | qa-gates/powershell-format.2026-09-29T20-57, qa-gates/powershell-analyze.2026-09-29T20-58, P11-T4 through P11-T9 coverage artifacts, qa-gates/coverage-comparison.2026-09-29T21-11 (Disposition: PASS) |
| AC-28 | P14-T28 | qa-gates/ac28-docstrings.2026-09-29T20-54 |
| AC-29 | P14-T29 | other/follow-up-entries.2026-09-29T20-48 |
