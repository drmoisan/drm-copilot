# Baseline PoshQC Format ([P0-T16])

Timestamp: 2026-10-07T21-58
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root . -ScanFolders tests/scripts/workflows"
Route: mcp
Deviation: DEV-PWSH-ROUTE, DEV-CI-BASELINE
ExecutedCommand: mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root, scan_folders ["tests/scripts/workflows"])
EXIT_CODE: 0
PreStatus: (empty) - `git status --porcelain -- tests/scripts/workflows` printed nothing before the run
PostStatus: (empty) - `git status --porcelain -- tests/scripts/workflows` printed nothing after the run
Output Summary:
- MCP result: `ok: true`. The MCP result carries no per-file output; the EXIT_CODE above is derived from the ok flag. No count is claimed from it.
- PreStatus equals PostStatus (both empty): the formatter did not rewrite any tracked file under tests/scripts/workflows.
- Per-file lines cited from CI run 37645267440 (workflow CI, event push, head 08ee030d9584bf15882fbb3654c8e38f34c7c359, conclusion success), job 112874273719 "poshqc / PowerShell QC", https://github.com/drmoisan/drm-copilot/actions/runs/37645267440/job/112874273719 , log lines 822-824:
  - `Already formatted: <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1`
  - `Already formatted: <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1`
  - `Already formatted: <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1`
- No `Formatted:` line for any tests/scripts/workflows file. (The only `Formatted:` line in the job log, line 1244 `Formatted: /repo/test.ps1`, is output from a Pester unit test of the formatter, not a repository file.)
- PreExistingFormatDrift: none
- Item branch differs from 08ee030d only in documentation files under docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/ (see base-ref.2026-10-07T21-58.md).
- DEV-MERGE-ADAPT: tests/scripts/workflows now contains three files (PoshQcWorkflow.Tests.ps1 added on main by #743).
