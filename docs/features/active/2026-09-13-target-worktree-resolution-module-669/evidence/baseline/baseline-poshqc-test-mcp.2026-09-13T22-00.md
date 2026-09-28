# Baseline — PoshQC MCP Test Stage (repository-wide)

Timestamp: 2026-09-17T07:56:43-04:00
Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c (scan_folders omitted; resolves from config/poshqc-scan.json) ; copy artifacts/pester/powershell-coverage.xml -> evidence/other/baseline-powershell-coverage.mcp.2026-09-13T22-00.xml ; copy artifacts/pester/pester-junit.xml -> evidence/other/baseline-pester-junit.2026-09-13T22-00.xml
EXIT_CODE: 2
Output Summary: MCP result ok=false ("Command exited with code 2."), verbatim object below. JUnit counts (from `testsuites` root attributes): tests=4547, failures=2, errors=0, disabled=9; testcase nodes with a `skipped` child: 9. Two pre-existing failures, both outside this feature's scope (listed under Baseline failure set). Repository-wide baseline LINE coverage: covered=8914, missed=422, percentage=95.48.

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

`ok` is `false`, so the fixed template summary (`Ran bundled PoshQC test against ...`) was not produced;
`mcp-tools.ts:139` substituted the error message `Command exited with code 2.` and `mcp-tools.ts:140`
added the `stderr_excerpt` above. The excerpt is stderr text written by release-verification tests under
test, not a runner fault.

## Counts (observed in evidence/other/baseline-pester-junit.2026-09-13T22-00.xml)

Root element `testsuites`, attributes as observed:
`name=Pester tests=4547 errors=0 failures=2 disabled=9 time=203.663`

- total (`tests`): 4547 (independently: 4547 `testcase` elements)
- failures (`failures`): 2 (independently: 2 `testcase` elements with a `failure` child)
- errors (`errors`): 0 (constant in Pester's JUnit writer; not used as a gate)
- skipped: 9 (`disabled=9`; independently: 9 `testcase` elements with a `skipped` child)
- `testsuite` elements: 192

## Repository-wide baseline line coverage (evidence/other/baseline-powershell-coverage.mcp.2026-09-13T22-00.xml)

Report-level counter (verbatim): `<counter type="LINE" missed="422" covered="8914" />`

- covered lines: 8914
- missed lines: 422
- percentage: 95.48

## Baseline failure set

Identifying names observed: a failing test is a `testcase` element (attributes `name`, `status="Failed"`,
`classname` = absolute test-file path, `assertions`, `time`) carrying a `failure` child element
(attribute `message`). Each line below is `<classname file, repo-relative> | <name>`.

One complete failing element (verbatim):

```xml
<testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists" status="Failed" classname="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1" assertions="0" time="0.096"><failure message="Expected strings to be the same, but they were different.&#xD;&#xA;Expected length: 5&#xD;&#xA;Actual length:   4&#xD;&#xA;Strings differ at index 0.&#xD;&#xA;Expected: 'allow'&#xD;&#xA;But was:  'deny'&#xD;&#xA;           ^">at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:145
at &lt;ScriptBlock&gt;, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:145</failure></testcase>
```

Failing tests:

- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
- tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits

Neither file is one of the ten Scope Boundary paths. Both failures exist before this feature changes any file.

Note: the two XML copies were made with a byte-for-byte `cp -f` from the Bash tool rather than
`Copy-Item -Force`; the effect (an overwriting byte copy made before any later run) is the same.
