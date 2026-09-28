# Final QC — PoshQC MCP Test Stage (repository-wide)

Timestamp: 2026-09-17T08:40:15-04:00
Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c (scan_folders omitted) ; Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml -Force ; Copy-Item -LiteralPath artifacts/pester/pester-junit.xml -Destination evidence/other/final-pester-junit.2026-09-13T22-00.xml -Force
EXIT_CODE: 2
Output Summary: MCP ok=false ("Command exited with code 2."), the same result and stderr excerpt as the [P0-T6] baseline. JUnit (testsuites root): tests=4653 (baseline 4547; +106, the three new suites), failures=2 (baseline 2; not greater), errors=0, disabled=9. Both failing tests are the two recorded in the [P0-T6] Baseline failure set, and neither file is a Scope Boundary path. Repository-wide post-change LINE coverage (report counter): covered=8914, missed=422, percentage=95.48.

## MCP result object (verbatim)

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c",
  "summary": "Command exited with code 2.",
  "stderr_excerpt": "Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with \"gh workflow run publish-mcp-npm.yml --ref\" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.\nPublish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish."
}
```

## Counts (evidence/other/final-pester-junit.2026-09-13T22-00.xml)

Root `testsuites` attributes as observed: `name=Pester tests=4653 errors=0 failures=2 disabled=9 time=160.023`

| Count | Final | Baseline ([P0-T6]) |
| --- | --- | --- |
| tests | 4653 | 4547 |
| failures | 2 | 2 |
| skipped (disabled; `testcase` with `skipped` child) | 9 | 9 |
| `testsuite` elements | 195 | 192 |

Failed count 2 is less than or equal to the baseline failed count 2.

## Failing tests (composed from the [P0-T6] names: `testcase` with a `failure` child; `classname` | `name`)

| Test file (classname, repo-relative) | Test name | Scope Boundary path? | In [P0-T6] Baseline failure set? |
| --- | --- | --- | --- |
| tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists | no | yes |
| tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits | no | yes |

No failing test is outside the baseline failure set.

## Repository-wide post-change line coverage (evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml)

Read using the [P0-T8] names (`report/counter[@type='LINE']`, attributes `covered` and `missed`).
Report-level counter (verbatim): `<counter type="LINE" missed="422" covered="8914" />`

- covered lines: 8914
- missed lines: 422
- percentage: 95.48

This run contains no `package` whose `name` ends with `worktree-resolution`; see [P4-T6].
