# Expect-fail new Pester assertions

Timestamp: 2026-10-01T17-22
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Output Summary: Plan Deviation D2 applies: evidence taken from CI. Run https://github.com/drmoisan/drm-copilot/actions/runs/36926301667, job 110584370865, on head e3f95fbf (new tests committed, workflow not yet changed). The poshqc job conclusion was failure; EXIT_CODE 1 records the job failure. Pester summary: "Tests Passed: 6085, Failed: 3, Skipped: 10". Failing lines:
- [-] publish-mcp-npm.yml workflow invariants.polls with a bounded backoff schedule whose cumulative sleep budget is at least 600 seconds
- [-] publish-mcp-npm.yml workflow invariants.caps the poll interval at 60 seconds and skips the sleep after the final attempt
- [-] publish-mcp-npm.yml workflow invariants.reports a timeout message that does not claim the tag push failed to publish
The fourth new test ("keeps the exit-code reset, explicit exits, and exact-version operand in the poll step") is not in the failure list and therefore passes: 6085 passed = 6084 baseline + 1. Limitation: CI logs print only failing tests, so [+] lines are not printed; the passing status of the fourth test and of the six pre-existing tests is inferred from the failure list and the passed-count arithmetic, not from [+] lines.
