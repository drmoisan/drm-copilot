# Remediation 1 Format Gate (pass 1)

Timestamp: 2026-10-08T22-22

## [P2-T1] Before-listing

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: five lines, all under FEATURE/:

```text
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/git-baseline.2026-10-08T21-57.md
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/remediation-1-merge-check.2026-10-08T22-17.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/remediation-1-merge-commit.2026-10-08T22-20.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/remediation-1-merge.2026-10-08T22-14.md
```

## [P2-T1] Formatter

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = <WORKSPACE_ROOT>, scan_folders = tests/scripts/codex-hooks)
EXIT_CODE: 0
Output Summary: MCP_CALL: returned (ok=true). No count or finding is read from the MCP result.

## [P2-T1] After-listing

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: identical to the before-listing (same five FEATURE/ lines); no path added by the formatter.

FORMAT_OUTSIDE_SCOPE_RESTORED: none

## [P2-T1] Final listing

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: identical to the before-listing (same five FEATURE/ lines). After removing FEATURE/ lines, both the before-listing and the final listing are empty and therefore identical; LEGACY_TEST does not appear. Pass.

## [P2-T2] Legacy test format check

Command: sh <SCRATCHPAD>/s-fmt-legacy.sh
EXIT_CODE: 0
Output Summary:

```text
FORMAT_CLEAN tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
FORMAT_DRIFT_COUNT: 0
```
