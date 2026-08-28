Timestamp: 2026-08-28T20-55
Command: Invoke-Pester -Path './tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1' -PassThru | Select-Object TotalCount, PassedCount, FailedCount | Format-List
EXIT_CODE: 0
Output Summary: TotalCount 3, PassedCount 3, FailedCount 0. All three `It` blocks pass in isolation: check (a) budget forwarding to `Wait-ForWorkflowRun`, check (b) budget forwarding to `Test-PublishStepConclusion`, and check (c) polling (41 `Invoke-NpmExe` calls, 39 `Invoke-Sleep` calls at 15 seconds).

Full captured output:

```
Starting discovery in 1 files.
Discovery found 3 tests in 215ms.
Running tests.
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 1.15s (642ms|339ms)
Tests completed in 1.17s
Tests Passed: 3, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0

TotalCount  : 3
PassedCount : 3
FailedCount : 0
```
