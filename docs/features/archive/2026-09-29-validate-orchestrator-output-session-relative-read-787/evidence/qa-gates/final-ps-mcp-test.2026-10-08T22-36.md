# Final PoshQC MCP Test Call (P6-T5), pass 1

Timestamp: 2026-10-08T22-36
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root)
EXIT_CODE: 2
Output Summary: the call raised on both attempts: `"ok": false`, `"summary": "Command exited with code 2."`. The `stderr_excerpt` held only publish-verification messages printed by tests that exercise the MCP publish verifier, not a diagnostic of this change.

Acceptance (call returned): NOT MET. P6-T5 is left unchecked.

## Attribution (read-only diagnosis, not a count gate)

The MCP runner wrote `artifacts/pester/pester-junit.xml` (23:53 on the run date). A scratch reader (`SCRATCH/junit-failures.ps1`) printed:

```text
JUNIT tests=7659 failures=2 errors=0 disabled=10
SUITE-FAILED name=<worktree>/tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 failures=1 errors=0
SUITE-FAILED name=<worktree>/tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 failures=1 errors=0
CASE-FAILED enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
CASE-FAILED Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

The exit code (2) equals the failure count. Both failed cases are the two KL-HERMETIC lines recorded in the P0-T24 SET-FULL baseline (`evidence/baseline/pester-set-full.2026-10-08T22-36.md`). Both depend on the local orchestration checkpoint (route_id large, issue 787) and are tracked by #737. Neither file is a PLAN-TEST-FILES member, and neither references a path this plan changes (checked by the P6-T6 SET-FULL classification). No test added or edited by this plan failed.

Disposition: the failing condition is pre-existing and outside this item's scope (run constraint 9; KL-HERMETIC definition), so this executor cannot fix its cause within the plan. Under the post-preflight no-block rule, execution continues. P6-T5 remains unchecked, and P6-T17 and P6-T21 inherit the unmet acceptance. The gap is escalated in the completion report.
