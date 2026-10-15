# SubagentStop Live Differential Capture (issue #897, epic child E1)

Timestamp: 2026-10-11T12-01
Command: claude -p "Use the Agent tool exactly once to launch a general-purpose subagent with the prompt: Reply with exactly the word PONG and nothing else. Then print verbatim the full text the subagent returned." --settings <scratch>/settings-exit<N>.json --model haiku --allowedTools "Agent" --max-turns 6   (run three times, N = 0, 1, 2, each from its own empty scratch working directory)
EXIT_CODE: 0
Output Summary:
- Transport: in all three runs the SubagentStop hook received the payload as JSON on stdin (1249 bytes in the exit-0 run). The environment variable CLAUDE_HOOK_INPUT was NOT set in any invocation (env_CLAUDE_HOOK_INPUT_set: false in 4 of 4 hook invocations).
- Shape: the stdin root carried `last_assistant_message` (value "PONG") and had NO `output` key (stdin_has_output_key: false in 4 of 4 invocations). `hook_event_name` was "SubagentStop" and `agent_type` was "general-purpose".
- Exit 1 does not block: one hook invocation only; the subagent stopped and the parent printed "PONG". The stderr instruction was not acted on.
- Exit 2 blocks: the first invocation exited 2 with a stderr instruction; the subagent resumed, obeyed it, and stopped again. The second invocation received `stop_hook_active: true` and `last_assistant_message: "BLOCKED-ACK-exit2"`; the parent printed "BLOCKED-ACK-exit2".
- Conclusion: the epic Shared Design premise (stdin JSON, `last_assistant_message`, exit 2 blocks, exit 1 does not, no CLAUDE_HOOK_INPUT) is confirmed by observation. No contract rename is required.

## Method

- Claude Code version: 2.1.296 (`claude --version`), headless `-p` mode, Windows 11, PowerShell 7.
- Isolation: each run used an empty scratch working directory outside the repository, so no repository `.claude/settings.json` hooks were loaded. The only project-level hook registered was the probe passed through `--settings`. The probe is read-only apart from writing its own log file and a one-shot marker file in the scratch directory.
- Probe script: `subagentstop-probe.2026-10-11T12-01.ps1.txt` in this folder (stored with a `.txt` suffix so it is not picked up as production PowerShell). It reads stdin to end, records the top-level keys, `last_assistant_message`, `stop_hook_active`, whether `output` exists, whether `CLAUDE_HOOK_INPUT` is set, and the names of all `CLAUDE*` environment variables. In exit-1 and exit-2 modes it refuses exactly once (guarded by a marker file, so no loop is possible) by writing `PROBE_BLOCK_<mode>: before stopping, reply with the single token BLOCKED-ACK-<mode>.` to stderr and exiting with the mode's code; every later invocation exits 0.
- Settings file shape (absolute scratch paths replaced by `<scratch>`):

```json
{ "hooks": { "SubagentStop": [ { "matcher": "", "hooks": [
  { "type": "command", "command": "pwsh -NoProfile -File \"<scratch>/subagentstop-probe.ps1\" -ExitCode <N> -Mode exit<N> -LogDir \"<scratch>/logs-exit<N>\"" }
] } ] } }
```

## Per-run results

| Run | Hook invocations | stdin JSON | `output` key | `last_assistant_message` (per invocation) | `stop_hook_active` (per invocation) | CLAUDE_HOOK_INPUT set | Parent printed | Blocked |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| exit 0 | 1 | yes | absent | "PONG" | false | no | PONG | n/a |
| exit 1 | 1 | yes | absent | "PONG" | false | no | PONG | no |
| exit 2 | 2 | yes | absent | "PONG", then "BLOCKED-ACK-exit2" | false, then true | no | BLOCKED-ACK-exit2 | yes |

## Recorded stdin envelope (exit-0 run, absolute paths and ids redacted)

```json
{
  "session_id": "<redacted>",
  "transcript_path": "<redacted absolute path>.jsonl",
  "cwd": "<redacted scratch directory>",
  "prompt_id": "<redacted>",
  "permission_mode": "default",
  "agent_id": "<redacted>",
  "agent_type": "general-purpose",
  "effort": { "level": "medium" },
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_transcript_path": "<redacted absolute path>/subagents/agent-<id>.jsonl",
  "last_assistant_message": "PONG",
  "background_tasks": [ { "id": "<redacted>", "type": "subagent", "status": "running", "description": "Reply with PONG", "agent_type": "general-purpose" } ],
  "session_crons": []
}
```

Top-level keys observed, in order: `session_id`, `transcript_path`, `cwd`, `prompt_id`, `permission_mode`, `agent_id`, `agent_type`, `effort`, `hook_event_name`, `stop_hook_active`, `agent_transcript_path`, `last_assistant_message`, `background_tasks`, `session_crons`.

`CLAUDE*` environment variable names present in the hook process (values not recorded): `CLAUDE_CODE_BRIDGE_SESSION_ID`, `CLAUDE_CODE_CHILD_SESSION`, `CLAUDE_CODE_ENTRYPOINT`, `CLAUDE_CODE_EXECPATH`, `CLAUDE_CODE_MESSAGING_SOCKET`, `CLAUDE_CODE_MESSAGING_TOKEN`, `CLAUDE_CODE_SESSION_ATTENDED`, `CLAUDE_CODE_SESSION_ID`, `CLAUDE_CODE_SSE_PORT`, `CLAUDE_EFFORT`, `CLAUDE_PID`, `CLAUDE_PROJECT_DIR`, `CLAUDECODE`. `CLAUDE_HOOK_INPUT` is not among them.

## Design consequences recorded for the spec

1. `Read-SubagentStopEnvelope` reads stdin; it must not consult `CLAUDE_HOOK_INPUT`.
2. The assistant text is `last_assistant_message`; `output` does not exist on the real envelope.
3. `Exit-SubagentStopBlock` must exit 2; exit 1 is fail-open for SubagentStop.
4. `agent_type` carries the subagent type, which is what the SubagentStop `matcher` is evaluated against.
5. A blocked subagent is re-invoked with `stop_hook_active: true`. The helper should surface this flag so validators can decide whether a second refusal is appropriate; the observed run shows the re-entry is real, so an unconditional refusal on re-entry would keep the subagent running until it complies.

## Limits of this evidence

- One run per mode, one agent type (`general-purpose`), haiku model, headless mode. Named project agents were not exercised; the matcher-on-`agent_type` behavior for named agents is taken from the documented semantics, not from this capture.
- Empty, absent, and malformed stdin cannot be produced by a real hook invocation and were not observed; their handling is a design decision in the spec, not a measurement.
