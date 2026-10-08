# Baseline Pester publish-mcp-npm workflow

Timestamp: 2026-10-01T17-22
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"
EXIT_CODE: 0
Output Summary: Plan Deviation D1 applies: plain pwsh is not permitted for the executor, so this baseline was taken from CI. CI workflow_dispatch run https://github.com/drmoisan/drm-copilot/actions/runs/36925501558, job "poshqc / PowerShell QC" (job id 110581712968, https://github.com/drmoisan/drm-copilot/actions/runs/36925501558/job/110581712968) on head bad51ae6 (pre-edit test and workflow). Job conclusion: success. EXIT_CODE 0 records the job success, not a local process exit code. Pester summary: "Tests Passed: 6084, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0" (repository-wide Pester run; the plan's expected per-file count of 6 is not separately observable). Limitation: detailed per-test output is not available from CI logs or the MCP tool.
