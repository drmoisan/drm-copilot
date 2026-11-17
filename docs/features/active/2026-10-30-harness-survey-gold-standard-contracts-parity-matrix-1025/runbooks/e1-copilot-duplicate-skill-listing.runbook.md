# Runbook E1: Copilot Listing of a Skill Present in Three Skill Folders

Issue #1025, epic #1018 child 1. Question: How do Copilot in VS Code and the Copilot CLI list a skill whose folder exists in `.github/skills`, `.claude/skills` and `.agents/skills` of the same repository? This runbook uses a scratch repository and changes nothing in this repository.

## Cue

Act when the orchestrator records the plan A owner stop with an `exception` requirement whose `runbook_path` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/runbooks/e1-copilot-duplicate-skill-listing.runbook.md`. The dependent matrix entries stay `provisional` until the result is recorded or the owner records a deferral in `## Owner Overrides` of `survey/difference-approval.md`.

## Prerequisites

- A scratch repository (not this repository) holding the probe skill `harness-probe-dup` in `.github/skills/harness-probe-dup/SKILL.md`, `.claude/skills/harness-probe-dup/SKILL.md` and `.agents/skills/harness-probe-dup/SKILL.md`, each with `name: harness-probe-dup` and a different `description`: `from-github`, `from-claude` and `from-agents`.
- VS Code with GitHub Copilot Chat signed in, with no user-level override of `chat.agentSkillsLocations`.
- The GitHub Copilot CLI installed and signed in.

## Step-by-step Instructions

1. Open the scratch repository in VS Code.
2. Open the Copilot Chat Skills page and count the `harness-probe-dup` entries; note the description each entry shows.
3. In the chat input, type `/` and count the `harness-probe-dup` entries in the menu; note the descriptions.
4. In a terminal at the scratch repository root, start the Copilot CLI and run its `/skills` command; count the `harness-probe-dup` entries and note the descriptions.
5. Record the VS Code and Copilot CLI versions.

## Verification

Expected observation: Each surface lists the probe skill a definite number of times, and each entry shows one of the three descriptions. Record the result as `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/e1-copilot-duplicate-skill-listing-result.<timestamp>.md`, where `<timestamp>` is the UTC time of writing in `yyyy-MM-ddTHH-mm` form, using this template:

```text
Timestamp: <yyyy-MM-ddTHH-mm, UTC>
Command: <the UI action or CLI command performed>
EXIT_CODE: <0 when observed as described, 1 otherwise>
Output Summary: <one to five lines describing what was observed>
Tool versions: <each tool and version used>
VSCode-Entries: <count and descriptions shown on the Skills page and the / menu>
CLI-Entries: <count and descriptions shown by /skills>
```

Result path: `e1-copilot-duplicate-skill-listing-result` under `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/`.

## Source and Citation

- https://code.visualstudio.com/docs/copilot/customization/agent-skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://code.visualstudio.com/docs/copilot/reference/copilot-settings (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- Steps are taken from research `## 6. Unverified-Behavior Experiments`; UI navigation was sourced web-second from the vendor documentation above because no MCP documentation source covers these products.
