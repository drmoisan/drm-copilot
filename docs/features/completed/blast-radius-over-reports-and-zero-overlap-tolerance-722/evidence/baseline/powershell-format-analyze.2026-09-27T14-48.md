# PowerShell Format and Lint Baseline (P0-T19)

Timestamp: 2026-09-27T14-48
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/lib/blast-radius/BlastRadius.psm1 .claude/lib/blast-radius/BlastRadiusValidation.psm1 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 ; mcp__drm-copilot__run_poshqc_analyze (workspace_root = repository root, scan_folders = the same three paths)
EXIT_CODE: 0
Output Summary: The read-only format check exited 0 and printed FORMAT-SUMMARY ChangedCount=0 (Changed=False for all three files). The analyze MCP call returned (ok true) and did not raise; it carries no finding output. git status --porcelain after both steps is identical to the P0-T11 record, so no tracked file was modified.

## A6 format check output

```text
FORMAT file=.claude/lib/blast-radius/BlastRadius.psm1 Changed=False
FORMAT file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 Changed=False
FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```

## MCP analyze call

- Returned: yes (did not raise).
- Result payload: ok true; tool run_poshqc_analyze; summary "Ran bundled PoshQC analyze against the
  repository root with 3 selected scan folder(s)." (the workspace root host path in the payload is
  replaced here by the words "the repository root").
- Error text: none.

## Tracked-file check

git status --porcelain after the two steps:

```text
 M docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/plan.2026-09-27T12-16.md
?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/
```

This equals the P0-T11 porcelain record. No tracked file was modified by this task.
