# Runbook E4: Copilot Location and File-Use Settings at Workspace Scope

Issue #1025, epic #1018 child 1. Question: Do the Copilot location and file-use settings take effect when set in the workspace `.vscode/settings.json`? (The plan A entry check X3 observed that `.vscode/settings.json` is tracked in this repository; owner question Q5 covers delivery.) This runbook uses a scratch repository and changes nothing in this repository.

## Cue

Act when the orchestrator records the plan A owner stop with an `exception` requirement whose `runbook_path` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/runbooks/e4-copilot-workspace-settings.runbook.md`. The dependent matrix entries stay `provisional` until the result is recorded or the owner records a deferral in `## Owner Overrides` of `survey/difference-approval.md`.

## Prerequisites

- The scratch repository of E1 with the probe skill in all three skill folders, plus a probe rule in `.claude/rules/harness-probe.md` and `.github/instructions/harness-probe.instructions.md`, and a probe agent in `.claude/agents/harness-probe-agent.md` and `.github/agents/harness-probe-agent.agent.md`.
- VS Code with GitHub Copilot Chat, with no user-level values for the settings below.

## Step-by-step Instructions

1. In the scratch repository, create `.vscode/settings.json` that sets `chat.agentSkillsLocations` to `{".claude/skills": false, ".github/skills": false}`, `chat.instructionsFilesLocations` to `{".claude/rules": false}`, `chat.agentFilesLocations` to `{".claude/agents": false}` and `chat.useClaudeMdFile` to `false`.
2. Reload the VS Code window.
3. Record what the Skills page, the agent picker and the References list of a chat request that matches the probe rule show.
4. Open the Settings editor, select the Workspace tab, and note whether VS Code marks any of these settings as not applicable at workspace scope.
5. Record the VS Code and Copilot Chat versions.

## Verification

Expected observation: Either the disabled locations disappear from each surface (workspace scope honored) or they remain (not honored). Record the result as `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/e4-copilot-workspace-settings-result.<timestamp>.md`, where `<timestamp>` is the UTC time of writing in `yyyy-MM-ddTHH-mm` form, using this template:

```text
Timestamp: <yyyy-MM-ddTHH-mm, UTC>
Command: <the UI action or CLI command performed>
EXIT_CODE: <0 when observed as described, 1 otherwise>
Output Summary: <one to five lines describing what was observed>
Tool versions: <each tool and version used>
Workspace-Settings-Honored: <yes, no, or partial with the setting names>
```

Result path: `e4-copilot-workspace-settings-result` under `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/`.

## Source and Citation

- https://code.visualstudio.com/docs/copilot/reference/copilot-settings (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://code.visualstudio.com/docs/copilot/customization/agent-skills (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- Steps are taken from research `## 6. Unverified-Behavior Experiments`; UI navigation was sourced web-second from the vendor documentation above because no MCP documentation source covers these products.
