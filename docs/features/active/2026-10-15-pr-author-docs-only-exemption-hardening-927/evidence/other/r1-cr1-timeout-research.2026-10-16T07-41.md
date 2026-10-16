# R1 CR-1 Hook Timeout Research (Issue #927, decision D-R1-1)

Timestamp: 2026-10-16T07-41
Command: grep -n -i -e 'timed-out' docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md
EXIT_CODE: 0
Output Summary: A repository research addendum quotes the Claude Code hooks documentation: a timed-out command hook does not block the tool call (fail-open). The Claude merge-gate registration sets no timeout; the Codex registration sets timeout = 30 and no repository source records Codex behavior on expiry. Decision: bound the helper's gh and git calls and deny on expiry.

GREP_1_LINE: 67:### 8. Timed-out hooks do not gate
GREP_1_LINE: 71:> A timed-out `command`, `http`, or `mcp_tool` hook doesn't block the tool call. The call continues through the normal [permission flow](/docs/en/permissions), so don't count on a stalled hook to act as a gate.
GREP_1_LINE: 119:- Citation 8: a timed-out command hook does not block. (line truncated in this record)

Command 2: grep -c -F -e "doesn't block the tool call" docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md
EXIT_CODE_2: 0
COUNT_2: 1

Command 3: grep -c -F -e 'timeout' .claude/settings.json
EXIT_CODE_3: 1
COUNT_3: 0

Command 4: grep -n -F -e 'enforce-epic-merge-gate.ps1' .claude/settings.json
EXIT_CODE_4: 0
GREP_4_LINE: 114 (Claude merge-gate registration command line)

Command 5: grep -n -F -e 'enforce-epic-merge-gate.ps1' .codex/config.toml
EXIT_CODE_5: 0
GREP_5_LINES: 142 (command), 143 (command_windows)

Command 6: grep -n -F -e 'timeout = 30' .codex/config.toml
EXIT_CODE_6: 0
GREP_6_INCLUDES_LINE_144: true (timeout of the registration whose command lines are 142 and 143)

Command 7: grep -c -i -e 'timed' docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md
EXIT_CODE_7: 1
COUNT_7: 0

CLAUDE_TIMEOUT_SEMANTICS: fail-open (the tool call continues through the permission flow)
CODEX_TIMEOUT_SEMANTICS: not recorded in repository sources; treated as fail-open
CLAUDE_GATE_TIMEOUT: none registered
CODEX_GATE_TIMEOUT: 30 s
CR1_DECISION: BOUND_ADDED
