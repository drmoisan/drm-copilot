# No-Python Enforcement-Hook Guard — Final Confirmation After All Production Changes

Timestamp: 2026-09-08T04-25

Task: [P6-T7]

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and **no**
`scan_folders` argument, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

## Why the suite is read from the JUnit XML

`pwsh` cannot be invoked in this worktree, so the self-hosted PoshQC invocation cannot run here and
the suite's result is read from a full-suite run through the MCP route, exactly as [P0-T7] and
[P1-T9] read it. The MCP runner returns a JSON result object and does not relay the module's console
totals line, so no value in this artifact is read from console text. The run settings set
`Run.Exit = $true` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`) and
`Invoke-PoshQCTest` does not override it, so the process exit code equals the Pester failed count.

## Transcribed `testsuite` start tag for the guard suite

From `artifacts/pester/pester-junit.xml` written by this run:

```xml
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" tests="27" errors="0" failures="0" hostname="MEGALODON4" id="113" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" time="1.905">
```

The element carries `failures="0"` and `errors="0"` and a `tests` count of 27, which is at least 27.
Derived passed count, by subtracting from `tests` every non-passing count the element carries:
27 − 0 failures − 0 errors − 0 skipped − 0 disabled = **27 passed**. The transcribed start tag is
not an exit code and carries no `EXIT_CODE:` row.

## Allowlist still empty

Search command:
`git grep -c -F "ships an empty allowlist" -- tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`

Printed output: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:1`,
reported with exit status 0 because the count is at least 1. That per-command status is recorded in
this wording rather than as its own `EXIT_CODE:` row because
`scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last row whose text before
the first colon is exactly `EXIT_CODE` as this artifact's result; a bare row carrying 0 would replace
the observed 2, disagree with the declared expectation, and render this passing gate as a failed one.
This file carries exactly one line whose pre-colon text is exactly `EXIT_CODE`.

The named test `It 'ships an empty allowlist'` is therefore still present and green. No allowlist
entry was added by this work:
`git diff --name-only d250cf72ee24139735e7f08b07d002ae0e4f1d00 -- tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
printed no path and exited 0, so the suite file is unchanged from the anchor commit. The new module
`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` and both changed gate hooks are inside
the AST scan this suite performs over `.claude/hooks` and `.claude/lib`, and all 27 of its tests
pass.

## Run totals

Root `testsuites` start tag, transcribed verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4460" errors="0" failures="2" disabled="9" time="145.779">
```

Derived passed count: 4460 − 2 failures − 0 errors − 9 disabled = **4449 passed**, with 2 failed and
9 skipped.

## Failing set

Every failing node in the run, by suite file and node name:

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (`tests="43" errors="0"
   failures="1"`), node
   `enforce-pr-author-skill.ps1` > `allowed commands` >
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (`tests="6" errors="0"
   failures="1"`), node
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` >
   `allows every registered handler for every tool name its own matcher admits`.

The observed `EXIT_CODE` of 2 equals the number of failing nodes this artifact names. That set is
exactly the two-member Known-Local-Red Inventory recorded in the plan's toolchain preamble, and no
other test fails. Both are produced by this run's own `epic_mode: true` orchestration checkpoint at
the gitignored path `artifacts/orchestration/orchestrator-state.json`, and both pass in the canonical
CI environment on run `34186767775`. `ExpectedExitCode: 2` records that expected steady state and
equals the observed code, so this gate normalizes to `pass`.

Output Summary: The no-Python enforcement-hook guard is green after all production changes: its
`testsuite` element reports `tests="27" errors="0" failures="0"`, giving 27 passed, and its
empty-allowlist test is still present and unchanged from the anchor commit. The full run reports
4449 passed, 2 failed, 9 skipped, and the two failing nodes are exactly the two Known-Local-Red
Inventory members, so the observed exit code 2 matches the declared expectation. This satisfies
AC-23.
