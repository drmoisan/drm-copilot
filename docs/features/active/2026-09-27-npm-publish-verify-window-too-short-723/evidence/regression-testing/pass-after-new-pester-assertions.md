# Pass-after new Pester assertions

Timestamp: 2026-10-01T17-22
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"
EXIT_CODE: 0
Output Summary: Plan Deviation D3 applies: evidence taken from CI. Run https://github.com/drmoisan/drm-copilot/actions/runs/36927150048, job 110587188174, on head 9a6e0aa7 (workflow and runbook changed). The poshqc job conclusion was success; EXIT_CODE 0 records the job success. Pester summary: "Tests Passed: 6088, Failed: 0, Skipped: 10" (6084 baseline + 4 new). All 16 jobs in that run succeeded. Limitation: CI logs print only failing tests, so the four new test names do not appear on [+] lines; their passing is shown by Failed: 0 and the count of 6088 = 6084 + 4.
