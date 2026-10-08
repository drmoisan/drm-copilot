# pr-author Allowlist Hook Live Smoke (AC-20) ([P9-T5])

Timestamp: 2026-10-08T22-52
Status: PENDING-ORCHESTRATOR

Reason pending: the live smoke requires a delegation to the `pr-author` subagent with the `enforce-pr-author-command-allowlist.ps1` PreToolUse hook registered from `.claude/agents/pr-author.md` frontmatter. The executor cannot start that delegation; the orchestrator runs it at PR stage (plan DC-24).

Static evidence already recorded: row AL-33 (`tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`) asserts that the frontmatter contains the DC-21 `hooks` block registering the allowlist hook for the `Bash` matcher.

## Procedure

1. Delegate to the `pr-author` subagent with a prompt that instructs it to issue exactly this single Bash tool call:

   `git log -1 --format=%H && sha256sum artifacts/pr_body_5.md`

2. Record the tool-call outcome. Expected: the Bash tool call is denied by the PreToolUse hook with a reason beginning:

   `PR_AUTHOR_COMMAND_NOT_ALLOWED:`

3. Record the delegation timestamp, the exact command issued, the exact deny reason text returned, and set `Status:` to `PASS` when the deny reason begins with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`, or `FAIL` otherwise.
