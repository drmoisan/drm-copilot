# Runbook E3: Copilot CLI and Copilot Cloud Agent Reading .claude/agents

Issue #1025, epic #1018 child 1. Question: Do the Copilot CLI and the Copilot cloud agent list a Claude-format agent defined only in `.claude/agents`? This runbook uses a scratch repository and changes nothing in this repository.

## Cue

Act when the orchestrator records the plan A owner stop with an `exception` requirement whose `runbook_path` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md`. The dependent matrix entries stay `provisional` until the result is recorded or the owner records a deferral in `## Owner Overrides` of `survey/difference-approval.md`.

## Prerequisites

- A scratch GitHub repository (not this repository) holding only `.claude/agents/harness-probe-agent.md` in Claude format (frontmatter `name: harness-probe-agent` and `description`), with no `.github/agents` folder.
- The GitHub Copilot CLI installed and signed in.
- The Copilot cloud agent enabled for the scratch repository.

## Step-by-step Instructions

1. In a terminal at the scratch repository root, start the Copilot CLI and run its `/agent` command; record the listed agents.
2. On GitHub.com, open the scratch repository, start a new Copilot cloud agent task, open the agent picker and record the listed agents.
3. Record the Copilot CLI version and the date of the cloud-agent observation.

## Verification

Expected observation: Each surface either lists `harness-probe-agent` or does not; documentation indicates that neither does. Record the result as `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/e3-copilot-cli-cloud-claude-agents-result.<timestamp>.md`, where `<timestamp>` is the UTC time of writing in `yyyy-MM-ddTHH-mm` form, using this template:

```text
Timestamp: <yyyy-MM-ddTHH-mm, UTC>
Command: <the UI action or CLI command performed>
EXIT_CODE: <0 when observed as described, 1 otherwise>
Output Summary: <one to five lines describing what was observed>
Tool versions: <each tool and version used>
CLI-Lists-Claude-Agent: <yes or no>
Cloud-Lists-Claude-Agent: <yes or no>
```

Result path: `e3-copilot-cli-cloud-claude-agents-result` under `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/`.

## Source and Citation

- https://code.visualstudio.com/docs/copilot/customization/custom-agents (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://docs.github.com/en/copilot/reference/custom-agents-configuration (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- Steps are taken from research `## 6. Unverified-Behavior Experiments`; UI navigation was sourced web-second from the vendor documentation above because no MCP documentation source covers these products.
