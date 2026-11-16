# Runbook E2: Codex Tolerance of Claude-Only Skill Frontmatter

Issue #1025, epic #1018 child 1. Question: Does Codex list and run a skill whose frontmatter carries the Claude-only fields `allowed-tools`, `argument-hint`, `context`, `agent`, `disable-model-invocation` and `user-invocable`? Optional: does VS Code fork on `context: fork`? This runbook uses a scratch repository and changes nothing in this repository.

## Cue

Act when the orchestrator records the plan A owner stop with an `exception` requirement whose `runbook_path` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/runbooks/e2-codex-claude-frontmatter.runbook.md`. The dependent matrix entries stay `provisional` until the result is recorded or the owner records a deferral in `## Owner Overrides` of `survey/difference-approval.md`.

## Prerequisites

- A scratch repository (not this repository), trusted in Codex, holding `.agents/skills/harness-probe-fm/SKILL.md` with `name`, `description`, `allowed-tools: Read`, `argument-hint: <text>`, `context: fork`, `agent: some-agent`, `disable-model-invocation: false` and `user-invocable: true`, and a one-line body that asks the agent to reply `probe-ok`.
- Codex installed and signed in.
- Optional: VS Code with GitHub Copilot Chat.

## Step-by-step Instructions

1. Start Codex at the scratch repository root and read the startup output for any warning or parse error that names a frontmatter field.
2. List the available skills and note whether `harness-probe-fm` appears.
3. Invoke the skill as `$harness-probe-fm` and note whether the reply is `probe-ok`.
4. Inspect the Codex log output of the session for warnings that name a field.
5. Optional: open the same folder in VS Code, invoke the skill from Copilot Chat, and note whether the run forks into a separate context.
6. Record the Codex version (and the VS Code version for the optional step).

## Verification

Expected observation: The skill is listed and runs, or a warning or parse error names the field that Codex rejects. Record the result as `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/e2-codex-claude-frontmatter-result.<timestamp>.md`, where `<timestamp>` is the UTC time of writing in `yyyy-MM-ddTHH-mm` form, using this template:

```text
Timestamp: <yyyy-MM-ddTHH-mm, UTC>
Command: <the UI action or CLI command performed>
EXIT_CODE: <0 when observed as described, 1 otherwise>
Output Summary: <one to five lines describing what was observed>
Tool versions: <each tool and version used>
Codex-Lists-Skill: <yes or no>
Codex-Warning-Fields: <field names named by a warning or error, or none>
```

Result path: `e2-codex-claude-frontmatter-result` under `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/`.

## Source and Citation

- https://learn.chatgpt.com/docs/build-skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://code.claude.com/docs/en/skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://agentskills.io/specification (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://code.visualstudio.com/docs/copilot/customization/agent-skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- Steps are taken from research `## 6. Unverified-Behavior Experiments`; UI navigation was sourced web-second from the vendor documentation above because no MCP documentation source covers these products.
