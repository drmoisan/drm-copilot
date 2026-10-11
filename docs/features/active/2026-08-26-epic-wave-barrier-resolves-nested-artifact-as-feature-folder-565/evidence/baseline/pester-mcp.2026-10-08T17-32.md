# Baseline MCP Pester Test

Timestamp: 2026-10-08T17-32
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <worktree-root>)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: Call completed with ok=false, "Command exited with code 2." The stderr excerpt is console text from pre-existing tests (publish-verification messages). Nothing numeric is asserted from this result; the self-hosted run (P0-T19) is the numeric baseline.

Result text:

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "<worktree-root>",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```
