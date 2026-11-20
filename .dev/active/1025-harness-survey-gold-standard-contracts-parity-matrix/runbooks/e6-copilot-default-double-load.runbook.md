# Runbook E6: Default Double Loading by Copilot

Issue #1025, epic #1018 child 1. Question: With default settings, does Copilot load both `.github/instructions` and `.claude/rules` (and `CLAUDE.md`), and does it remove duplicates? This runbook uses a scratch repository and changes nothing in this repository.

## Cue

Act when the orchestrator records the plan A owner stop with an `exception` requirement whose `runbook_path` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/runbooks/e6-copilot-default-double-load.runbook.md`. The dependent matrix entries stay `provisional` until the result is recorded or the owner records a deferral in `## Owner Overrides` of `survey/difference-approval.md`.

## Prerequisites

- The scratch repository of E4 with no `.vscode/settings.json` (remove it after E4), plus `CLAUDE.md` and `AGENTS.md` with distinct one-line texts.
- VS Code with GitHub Copilot Chat; the GitHub Copilot CLI installed and signed in.

## Step-by-step Instructions

1. Open the scratch repository in VS Code with default settings.
2. Send a chat request in a file that matches the probe rule pattern and record every entry of its References list.
3. In a terminal at the scratch repository root, start the Copilot CLI and run its `/instructions` command; record the listed files.
4. Record the VS Code, Copilot Chat and Copilot CLI versions.

## Verification

Expected observation: The References list shows one or both probe rules, and the CLI list shows whether `CLAUDE.md` is loaded. Record the result as `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/e6-copilot-default-double-load-result.<timestamp>.md`, where `<timestamp>` is the UTC time of writing in `yyyy-MM-ddTHH-mm` form, using this template:

```text
Timestamp: <yyyy-MM-ddTHH-mm, UTC>
Command: <the UI action or CLI command performed>
EXIT_CODE: <0 when observed as described, 1 otherwise>
Output Summary: <one to five lines describing what was observed>
Tool versions: <each tool and version used>
VSCode-References-Both-Rules: <yes or no>
CLI-Lists-CLAUDE-md: <yes or no>
```

Result path: `e6-copilot-default-double-load-result` under `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/`.

## Source and Citation

- https://code.visualstudio.com/docs/copilot/reference/copilot-settings (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions (updated_at: 2026-10-30, captured for research section 6 of research/research.2026-10-30T21-08.md)
- Steps are taken from research `## 6. Unverified-Behavior Experiments`; UI navigation was sourced web-second from the vendor documentation above because no MCP documentation source covers these products.
