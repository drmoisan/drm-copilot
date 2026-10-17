# Codex Orchestrator Variant Regeneration — P7-T7

Timestamp: 2026-09-30T14-43
Task: P7-T7
Working directory: worktree root

Edit: in `.codex/agents/orchestrator.toml` line 160, appended "unless a valid `issue_adoption` record waives it" after "Each required MCP tool must have an `mcp_call_receipts[]` entry with `ok = true` and non-empty `evidence`". No `'''` was added.

## Step 1 — regenerate

Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants
EXIT_CODE: 0
Output Summary: no stdout; stderr empty.

## Step 2 — check

Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: no stdout; stderr empty.

## Step 3 — porcelain listing

Command: git status --porcelain -- .codex extensions/drm-copilot/resources/codex-and-agents-customizations
EXIT_CODE: 0

First listing (immediately after step 2) named 21 paths: the 15 expected paths plus six pack manifests under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` (`core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json`, `typescript.json`). Inspection: `git diff --stat` over that folder printed no content change, only the warning `CRLF will be replaced by LF the next time Git touches it` for each of the six files. The generator rewrote them with CRLF line endings on Windows; the committed content is unchanged after normalization. This is pre-existing line-ending drift repaired by the generator, recorded here and escalated at completion. The six files are outside the Scope-of-the-diff enumeration, so they were restored with:

Command: git checkout -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/csharp-legacy.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/csharp-modern.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/powershell.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/python.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/typescript.json
EXIT_CODE: 0

The `--check` run was repeated after the restore (EXIT_CODE 0, no output), then the listing was repeated.

Final listing (Output Summary), exactly fifteen paths:
```
 M .codex/agents/orchestrator-c1.toml
 M .codex/agents/orchestrator-c2.toml
 M .codex/agents/orchestrator-c3-elevated.toml
 M .codex/agents/orchestrator-c3.toml
 M .codex/agents/orchestrator-c4.toml
 M .codex/agents/orchestrator.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml
```
The twelve `orchestrator*.toml` paths each carry a one-line content change (`git diff --stat`: 12 files, 12 insertions, 12 deletions).

Result: PASS (with the pack-manifest line-ending drift recorded and escalated)
