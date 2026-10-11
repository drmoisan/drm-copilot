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

## Result (orchestrator run, PR #855 creation delegation)

Timestamp: 2026-10-09T01-29
Status: FAIL (environmental; operator action required)
Command: `git log -1 --format=%H && sha256sum artifacts/pr_body_5.md`
EXIT_CODE: 1
Output Summary: The command was not denied. It printed `99cec29930006a09c183a9f5305a1f658a6be57f` and exited 1 only because `artifacts/pr_body_5.md` does not exist. No `PR_AUTHOR_COMMAND_NOT_ALLOWED:` text appeared for this or other chained/piped commands in the same delegation.

Observed cause (likely, not confirmed): the delegation loaded `.claude/agents/pr-author.md` from the session root checkout (`drm-copilot-wt/2026-09-29T13-45`), whose copy registers only the `SubagentStop` hook. The `PreToolUse` `Bash` registration exists only on this branch. The smoke can pass only from a session whose root contains this branch's `pr-author.md` (after the change reaches the session root's branch). AC-20 remains unchecked pending that operator-run smoke.
