# Acceptance Criteria Verification (P9-T27)

Timestamp: 2026-10-16T05-19

Source: `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`, section `## Acceptance Criteria` (work mode `full-bug`).

AC-01 | CHECKED | evidence/regression-testing/r3-prd-feature.2026-10-16T01-13.md
AC-02 | CHECKED | evidence/regression-testing/r3-task-researcher.2026-10-16T01-13.md
AC-03 | CHECKED | evidence/regression-testing/r3-prd-feature.2026-10-16T01-13.md, r3-task-researcher.2026-10-16T01-13.md
AC-04 | CHECKED | evidence/other/spec-decision-records.2026-10-16T04-07.md, evidence/qa-gates/ac20-statements.2026-10-16T05-14.md, evidence/qa-gates/scope-diff.2026-10-16T05-15.md
AC-05 | CHECKED | evidence/regression-testing/r4-discovery.2026-10-16T01-16.md, nb4-suites.2026-10-16T04-20.md
AC-06 | CHECKED | evidence/regression-testing/r4-discovery.2026-10-16T01-16.md, nb4-suites.2026-10-16T04-20.md
AC-07 | CHECKED | evidence/regression-testing/nb4-helper.2026-10-16T04-13.md, nb4-envelope-identity.2026-10-16T04-21.md
AC-08 | CHECKED | evidence/regression-testing/nb4-convert-*.md, nb4-census.2026-10-16T04-19.md, nb4-suites.2026-10-16T04-20.md
AC-09 | UNCHECKED | MAIN-MOVED-AFTER-NB4: evidence/qa-gates/ac09-main-containment.2026-10-16T05-16.md records merge-base de4f91294 against origin/main 5bc97774b, so BRANCH-CONTAINS-MAIN is not yes; the plan defines no merge after P8-T17. Both census greps are empty with EXIT_CODE 1 (ac09-census-builder.2026-10-16T05-16.md, ac09-census-comment.2026-10-16T05-16.md), and P7-T2 did not record MERGE-ABORTED.
AC-10 | CHECKED | evidence/qa-gates/commit-order.2026-10-16T05-17.md, evidence/other/issue-928-sequencing.2026-10-16T04-08.md
AC-11 | CHECKED | evidence/regression-testing/nb5-alias-removal.2026-10-16T04-01.md, evidence/other/post-merge-verification.2026-10-16T04-10.md
AC-12 | CHECKED | evidence/qa-gates/final-python-contracts.2026-10-16T05-14.md (ZERO-FAILURES, EXIT_CODE 0)
AC-13 | CHECKED | evidence/qa-gates/scope-diff.2026-10-16T05-15.md
AC-14 | CHECKED | evidence/regression-testing/e3-clarifications.2026-10-16T04-06.md, evidence/qa-gates/final-e3-clarifications.2026-10-16T05-16.md
AC-15 | CHECKED | evidence/regression-testing/e3-clarifications.2026-10-16T04-06.md, evidence/qa-gates/final-e3-clarifications.2026-10-16T05-16.md, evidence/other/spec-decision-records.2026-10-16T04-07.md
AC-16 | CHECKED | evidence/regression-testing/nb9-dispatch.2026-10-16T01-19.md, nb9-checks.2026-10-16T01-19.md, nb4-suites.2026-10-16T04-20.md
AC-17 | CHECKED | evidence/regression-testing/nb9-dispatch.2026-10-16T01-19.md, nb4-suites.2026-10-16T04-20.md
AC-18 | CHECKED | evidence/qa-gates/coverage-comparison.2026-10-16T05-13.md
AC-19 | CHECKED | evidence/regression-testing/nb11-dependency-decision.2026-10-16T01-22.md
AC-20 | CHECKED | evidence/qa-gates/ac20-statements.2026-10-16T05-14.md, final-registration-suites.2026-10-16T05-13.md
AC-21 | CHECKED | evidence/qa-gates/final-format.2026-10-16T04-26.md, final-analyze.2026-10-16T04-31.md (QA loop clean on pass 1; no QA-LOOP-BOUND-REACHED)
AC-22 | CHECKED | evidence/qa-gates/final-pester-selfhosted.2026-10-16T05-12.md (EXIT_CODE 0), final-pester-junit.2026-10-16T05-12.md (FAILURES=0 ERRORS=0, comparison exit 0), final-registration-suites.2026-10-16T05-13.md (EXIT_CODE 0, FAILED=0), final-poshqc-test-mcp.2026-10-16T04-52.md (EXIT_CODE 0)
AC-23 | CHECKED | evidence/qa-gates/coverage-comparison.2026-10-16T05-13.md (missed 2 to 2)
AC-24 | CHECKED | evidence/qa-gates/final-line-counts.2026-10-16T05-15.md
AC-25 | CHECKED | evidence/qa-gates/plan-expect-fail-check.2026-10-16T05-18.md
AC-26 | PENDING-CI | CI job poshqc / PowerShell QC (windows-latest, every suite with coverage) on the PR head SHA; checked off by the item's orchestrator run at S9
AC-27 | PENDING-CI | CI job poshqc / PowerShell hook suites (Linux) (ubuntu-latest, tests/scripts/claude-hooks and tests/scripts/codex-hooks, no coverage) on the PR head SHA; checked off by the item's orchestrator run at S9

### Acceptance Criteria Status
- Source: docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md
- Total AC items: 27
- Checked off (delivered): 24
- Remaining (unchecked): 3
- Items remaining: AC-09 (MAIN-MOVED-AFTER-NB4; branch does not contain the current origin/main), AC-26 (PENDING-CI), AC-27 (PENDING-CI)
