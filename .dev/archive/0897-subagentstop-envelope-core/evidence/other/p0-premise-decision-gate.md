# Phase 0 Premise Decision Gate (issue #897, epic child E1)

Timestamp: 2026-10-11T12-31
Task: [P0-T3]
Source: `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` lines 7-11 (Output Summary) and lines 28-32 (per-run table), re-read in this session. The differential was not re-run.
Spec claim source: `docs/features/active/subagentstop-envelope-core-897/spec.md` line 12.

## Contract facts

FACT: stdin JSON transport | SPEC: the SubagentStop payload arrives as JSON on stdin | EVIDENCE: "in all three runs the SubagentStop hook received the payload as JSON on stdin (1249 bytes in the exit-0 run)" (line 7); per-run table column `stdin JSON` reads `yes` for exit 0, exit 1 and exit 2 (lines 30-32) | AGREES: yes
FACT: root field last_assistant_message | SPEC: the assistant text is the root field `last_assistant_message` | EVIDENCE: "the stdin root carried `last_assistant_message` (value \"PONG\")" (line 8); table column `last_assistant_message (per invocation)` reads "PONG" / "PONG" / "PONG", then "BLOCKED-ACK-exit2" (lines 30-32) | AGREES: yes
FACT: no root output key | SPEC: the root carries no `output` key | EVIDENCE: "had NO `output` key (stdin_has_output_key: false in 4 of 4 invocations)" (line 8); table column `output key` reads `absent` for all three runs (lines 30-32) | AGREES: yes
FACT: CLAUDE_HOOK_INPUT not set | SPEC: `CLAUDE_HOOK_INPUT` is not set | EVIDENCE: "The environment variable CLAUDE_HOOK_INPUT was NOT set in any invocation (env_CLAUDE_HOOK_INPUT_set: false in 4 of 4 hook invocations)" (line 7); table column `CLAUDE_HOOK_INPUT set` reads `no` for all three runs (lines 30-32) | AGREES: yes
FACT: exit 1 does not block | SPEC: exit 1 does not block | EVIDENCE: "Exit 1 does not block: one hook invocation only; the subagent stopped and the parent printed \"PONG\". The stderr instruction was not acted on." (line 9); table row `exit 1` reads `Blocked: no` (line 31) | AGREES: yes
FACT: exit 2 blocks with stderr delivered and re-entry carrying stop_hook_active true | SPEC: exit 2 blocks with stderr delivered to the subagent and re-entry carrying `stop_hook_active: true` | EVIDENCE: "Exit 2 blocks: the first invocation exited 2 with a stderr instruction; the subagent resumed, obeyed it, and stopped again. The second invocation received `stop_hook_active: true` and `last_assistant_message: \"BLOCKED-ACK-exit2\"`" (line 10); table row `exit 2` reads `Hook invocations: 2`, `stop_hook_active: false, then true`, `Blocked: yes` (line 32) | AGREES: yes

## Token check

Command: `Select-String -LiteralPath docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md -SimpleMatch 'stdin_has_output_key: false'`
Match count: 1

Command: `Select-String -LiteralPath docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md -SimpleMatch 'env_CLAUDE_HOOK_INPUT_set: false'`
Match count: 1

EXIT_CODE: 0
Output Summary: six of six facts agree; both token counts are 1 (at least 1).

## Decision

All six `FACT:` lines read `AGREES: yes` and both token counts are at least 1.

DECISION: PROCEED
