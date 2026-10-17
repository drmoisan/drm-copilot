# PoshQC MCP test stage (P2-T5)

Timestamp: 2026-10-17T01-38
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/workflows"]
EXIT_CODE: 0
MCP_CALL: returned
Output Summary: The MCP call returned ok=true with summary "Ran bundled PoshQC test against '<WORKSPACE_ROOT>' with 1 selected scan folder(s)." The porcelain listings before and after are identical. Per reference rule 5, no count, percentage, or finding is read from the MCP result; the asserted test counts are those of P2-T4 (rem1-pester-workflows.2026-10-17T01-37.md).

## MCP result (host path redacted)

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"<WORKSPACE_ROOT>","summary":"Ran bundled PoshQC test against '<WORKSPACE_ROOT>' with 1 selected scan folder(s)."}
```

## git status --porcelain before (EXIT: 0)

```text
 M .github/workflows/README.md
 M .github/workflows/_security-scan.yml
 M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-plan.2026-10-17T01-20.md
 M tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes-rem1.2026-10-17T01-28.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-actionlint.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-format.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-pester-workflows.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-pssa.2026-10-17T01-37.md
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
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-actionlint.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-format.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-pester-workflows.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/rem1-pssa.2026-10-17T01-37.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-readme-tokens.2026-10-17T01-36.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/rem1-w18-pass.2026-10-17T01-34.md
?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/remediation-baseline/
```
