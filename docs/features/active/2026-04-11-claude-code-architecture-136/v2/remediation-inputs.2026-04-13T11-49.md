# Remediation Inputs: Claude Code architecture v2 post-review loop (#136)

Timestamp: 2026-04-13T11:49-04:00
Feature Folder: `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
Base Branch: `origin/development`
Head Branch: `feature/claude-code-architecture-136`
Primary Requirements Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-49.md`

## Scope Summary

This remediation loop is limited to one concrete repo-controlled defect class:

1. The multi-folder `scan_folders` transport contract is still broken across the bundled PoshQC MCP wrappers.

The following earlier findings remain closed and must stay closed:

- `.claude/settings.json` schema validation now passes.
- The PowerShell coverage artifact path now produces numeric output.
- The stale MCP token finding remains closed in settings, docs, and runtime tests.

The following live Claude-session criteria remain environment-only `UNVERIFIED` gaps and are not part of this remediation scope:

- `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` live invocation
- Live subagent allowlist enforcement
- Live checkpoint resume verification
- Live `SubagentStop` verification

## Enumerated Fix List

1. Repair the end-to-end multi-folder `scan_folders` transport contract for the bundled PoshQC MCP wrappers.
   - Files in scope:
     - `extensions/drm-copilot/src/repo-automation-service.ts`
     - `extensions/drm-copilot/resources/templates/run-poshqc-format.ps1`
     - `extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1`
     - `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`
   - Current defect:
     - `mcp__drmCopilotExtension__run_poshqc_format(..., scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])` exits 1 with duplicate `ScanFolders` binding.
     - `mcp__drmCopilotExtension__run_poshqc_analyze(..., scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])` exits 1 with duplicate `ScanFolders` binding.
     - `mcp__drmCopilotExtension__run_poshqc_test(..., scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])` exits 1 because both scan roots are treated as one comma-delimited path.
   - Expected behavior:
     - All three live MCP wrapper commands accept multiple scan roots and reach the underlying PoshQC command without wrapper-level transport failure.
   - Verification commands:
     - `mcp__drmCopilotExtension__run_poshqc_format(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])`
     - `mcp__drmCopilotExtension__run_poshqc_analyze(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])`
     - `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`

2. Add regression coverage for the live service-to-wrapper boundary.
   - Files in scope:
     - `extensions/drm-copilot/test/repo-automation-service.test.ts`
     - `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`
     - `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`
     - Any additional repo-controlled test needed to cover the bundled wrapper boundary directly
   - Current defect:
     - Existing TypeScript and direct Pester regression suites all pass while the live bundled wrappers still fail.
   - Expected behavior:
     - Regression coverage fails before the fix and passes after the fix for the exact live multi-folder wrapper contract used by the MCP commands.
   - Verification commands:
     - `npx jest extensions/drm-copilot/test/repo-automation-service.test.ts --runInBand`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path 'tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1' -Output Detailed"`

## Verified Open Blockers

- `extensions/drm-copilot/src/repo-automation-service.ts:416-421`
- `extensions/drm-copilot/resources/templates/run-poshqc-format.ps1:1-16`
- `extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1:1-16`
- `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1:1-22`
- Current live MCP wrapper errors recorded by this review

## Do Not Do

- Do not reopen the resolved settings/schema finding.
- Do not reopen the resolved coverage-output-path finding.
- Do not broaden scope beyond the multi-folder PoshQC MCP wrapper transport contract and its regression coverage.
- Do not mark any live Claude-session criterion PASS without transcript-level runtime evidence.
- Do not replace the approved live MCP verification commands with undocumented fallback commands in the final QA phase.

## Required Context Package For Planning

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T11-49.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T11-49.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T11-49.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T11-06.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
