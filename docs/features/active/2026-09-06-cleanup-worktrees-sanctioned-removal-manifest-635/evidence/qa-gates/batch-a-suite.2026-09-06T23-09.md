# Batch A Full PowerShell Suite Gate

Timestamp: 2026-09-08T02-40

Task: [P1-T8]

Command:
`mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e` and
no `scan_folders` argument, so the full configured scan set from `config/poshqc-scan.json`
(`scripts`, `tests/powershell`, `tests/scripts`) runs. The full scope is required because
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` holds the second member of the
Known-Local-Red Inventory.

EXIT_CODE: 2

ExpectedExitCode: 2

This gate asserts named test outcomes and count totals rather than a coverage number, so it does not
need the new `CodeCoverage.Path` entry honoured and the MCP runner is the valid route for it. The
self-hosted PoshQC invocation cannot run in this worktree: the runtime worktree-isolation guard
refuses every `pwsh` invocation issued here.

## Route to the recorded counts

The MCP runner returns a JSON result object and does not relay the module's console totals line, so
the counts below are read from the root `testsuites` start tag of `artifacts/pester/pester-junit.xml`
written by this run, transcribed verbatim:

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4370" errors="0" failures="2" disabled="9" time="155.285">
```

The element carries no `passed` attribute, so the passed count is derived by subtracting every
non-passing count it carries:

Passed = 4370 - 2 (`failures`) - 0 (`errors`) - 9 (`disabled`) = **4359**. Failed = **2**.

The total rose from the 4363 recorded by [P0-T7] to 4370, which is the 7 tests Batch A adds in
`tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1" tests="7" errors="0" failures="0" hostname="MEGALODON4" id="79" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1" time="0.188">
```

Derived passed for the new suite = 7 - 0 - 0 - 0 - 0 = **7**. Batch A therefore adds only passing
tests, which is why this gate is satisfiable at the point it runs; the deliberately failing tests are
added in Phase 2 and made passing in Phase 3.

## Failing nodes

Two `testcase` elements carry `status="Failed"`, enumerated in full:

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, node
   `enforce-pr-author-skill.ps1` > `allowed commands` >
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, node
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` >
   `allows every registered handler for every tool name its own matcher admits`.

The observed exit code of 2 equals the number of failing nodes this artifact names. The set is
exactly the two-member Known-Local-Red Inventory in the plan's toolchain preamble, no third node
failed, and no failing node lies outside the inventory. Both are produced by this run's own
`epic_mode` orchestration checkpoint under gitignored `artifacts/`, read by two hooks through a seam
their suites do not mock; the same two nodes pass in the canonical environment on `_poshqc.yml` run
`34186767775`. The observed count equals the declared expectation of 2, so no expectation adjustment
is required.

## Toolchain order

`mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` were run to a clean
pass immediately before this test run, in that order. The analyze step first reported
`PSScriptAnalyzer reported 1 issue(s).`; the cause was non-ASCII em-dash characters in the new
module's comments, which no existing PowerShell file in this tree carries. They were replaced with
ASCII, the loop restarted from format, and both steps then completed clean with no tracked file
rewritten.

Output Summary: Full PowerShell suite through the MCP route: **4359 passed, 2 failed, 9 skipped** of
4370 in 155.285 s, exit code 2 against a declared expectation of 2. The 7-test rise over the [P0-T7]
baseline of 4363 is the new `CleanupWorktreeManifest.Tests.ps1` suite, whose own `testsuite` element
reports `tests="7" errors="0" failures="0"`. The failing set is exactly the two-member
Known-Local-Red Inventory, named above by suite file and node; no other test failed. Format and
analyze were clean on the final pass.
