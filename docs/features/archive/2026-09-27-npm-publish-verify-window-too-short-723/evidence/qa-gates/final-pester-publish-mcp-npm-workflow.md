# Final Pester publish-mcp-npm workflow

Timestamp: 2026-10-01T17-22
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"
EXIT_CODE: 0
Output Summary: Plan Deviation D4 applies: same CI run and job as D3. Run https://github.com/drmoisan/drm-copilot/actions/runs/36927150048, job 110587188174, on head 9a6e0aa7. Job conclusion success; EXIT_CODE 0 records the job success. Pester summary: "Tests Passed: 6088, Failed: 0, Skipped: 10". All ten tests of the file (six pre-existing, four new) are included in the 6088 passed with zero failed and no [-] lines. Limitation: CI logs print only failing tests, so the ten test names are not shown on [+] lines. The orchestrator will append the PR-head CI run later.
