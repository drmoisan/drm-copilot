# Formatting stage — W18-FILE (P2-T1)

Timestamp: 2026-10-17T01-37
Command: sh SCRATCH/tools/run-cr.sh cr-format -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -Write
EXIT_CODE: 0
Output Summary: FORMAT-CLEAN for the file; FORMAT-DRIFT-COUNT: 0; no FORMAT-WRITTEN line; EXIT_CODE_COMPUTED: 0. The porcelain listings before and after the run are identical. The formatter did not rewrite the file.

## Output

```text
RUN-CR: cr-format
FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
```

## git status --porcelain before (EXIT: 0)

```text
 M .github/workflows/README.md
 M .github/workflows/_security-scan.yml
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-plan.2026-10-17T01-20.md
 M tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes-rem1.2026-10-17T01-28.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-readme-tokens.2026-10-17T01-36.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-pass.2026-10-17T01-34.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/remediation-baseline/
```

## git status --porcelain after (EXIT: 0)

```text
 M .github/workflows/README.md
 M .github/workflows/_security-scan.yml
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-plan.2026-10-17T01-20.md
 M tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes-rem1.2026-10-17T01-28.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-readme-tokens.2026-10-17T01-36.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-pass.2026-10-17T01-34.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/remediation-baseline/
```
