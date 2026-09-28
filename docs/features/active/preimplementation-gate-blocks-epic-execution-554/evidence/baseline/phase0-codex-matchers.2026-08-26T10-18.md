# Phase 0 — Pre-Change `.codex/config.toml` PreToolUse Matcher Baseline (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```bash
grep -n 'matcher\|\[\[hooks' .codex/config.toml
```

EXIT_CODE: 0

Output Summary:

`.codex/config.toml` declares **exactly three** `[[hooks.PreToolUse]]` blocks, and therefore exactly
three PreToolUse tool matchers:

| # | Line | Tool matcher literal |
| --- | --- | --- |
| 1 | 120 | `^Bash$` |
| 2 | 153 | `^(Bash\|shell_command\|apply_patch\|Edit\|Write\|mcp__.*)$` |
| 3 | 186 | `^(apply_patch\|Edit\|Write)$` |

**None of these three matchers admits an `Agent` or a `Task` tool name.** Matcher 1 admits only
`Bash`. Matcher 3 admits only `apply_patch`, `Edit`, and `Write`. Matcher 2 admits `Bash`,
`shell_command`, `apply_patch`, `Edit`, `Write`, and any tool name beginning `mcp__`; `Agent` and
`Task` begin with neither `mcp__` nor any of the five enumerated alternatives, and the pattern is
anchored at both ends, so neither name can match.

## The Three Non-PreToolUse Matchers Are Not Tool Matchers

Three further `matcher =` lines exist in the file and are recorded here so they are not mistaken for
PreToolUse tool matchers:

| Line | Event | Matcher | Kind |
| --- | --- | --- | --- |
| 110 | `[[hooks.SubagentStart]]` | `epic-planner\|epic-orchestrator\|orchestrator\|...` | agent-name matcher |
| 237 | `[[hooks.SubagentStop]]` | `epic-planner\|epic-orchestrator\|orchestrator\|...` | agent-name matcher |
| 246 | `[[hooks.SubagentStop]]` | `feature-review\|feature-reviewer` | agent-name matcher |

These are subagent-lifecycle matchers keyed on agent names, not `PreToolUse` tool matchers. They do
not make an `Agent` tool delegation reachable by a `PreToolUse` hook on the Codex surface.

## Consequence Carried Into Execution

This baseline confirms design decision D5 in `spec.md`: the Codex `Agent` leg is unreachable. The
Codex deliverable is therefore (i) direct unit tests of the shared logic dot-sourced from the Codex
copy, and (ii) one assertion test recording this transport gap with a cross-reference to issue #555.
Fabricating an `Agent` envelope on the Codex side and asserting a decision on it is explicitly
prohibited. Task P3-T19 authors the assertion test against this same file.
