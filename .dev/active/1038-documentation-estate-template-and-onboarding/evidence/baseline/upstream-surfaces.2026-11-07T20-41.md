# Upstream MCP, enforcement and workflow surfaces (1021, 1034, 1036, 1037)

Timestamp: 2026-11-07T20-41
Command: Read extensions/drm-copilot/src/mcp-docs-tool-definitions.ts (DOCS_TOOL_DEFINITIONS, definition, DOCS_MUTATING_TOOLS) and extensions/drm-copilot/src/mcp-tool-inputs-docs.ts (DOCS_TOOL_INPUT_TABLES); grep .claude/lib/docs/DocsProfileCommands.psm1 (Get-DocsInitTemplate) and .claude/hooks/enforce-docs-complete-gate.ps1; list .claude/agents/docs-*.md and the eight skill folders under .claude/skills/
EXIT_CODE: 0
Output Summary: All surfaces match. Six tools are declared in DOCS_TOOL_DEFINITIONS through definition() calls whose first argument is the tool name as a double-quoted string on the line after `definition(`. definition() adds workspace_root to every input schema and its required list. Input fields come from the `field` values of each tool's rows in DOCS_TOOL_INPUT_TABLES. DOCS_MUTATING_TOOLS is ["update_docs_ledger"].

TOOL-FORM: definition(<newline><indent>"<tool name>",  (extraction pattern: definition\(\s*"([a-z_]+)" ; the function declaration `function definition(` carries no quoted string and does not match)
TOOL: run_docs_check | workspace_root (required), profile, paths
TOOL: run_docs_inventory | workspace_root (required), profile, analyzers, revision
TOOL: run_docs_coverage | workspace_root (required), profile
TOOL: update_docs_ledger | workspace_root (required), profile, operation (required), element, limit, disposition, pages, rationale, owner, target, dimension, state, claim, actor_kind (required), actor_id (required), write
TOOL: generate_docs_reference | workspace_root (required), profile, snapshot, output_directory
TOOL: validate_docs_artifacts | workspace_root (required), profile, mode (required), revision (required)

CONTRACT: DOCS_MUTATING_TOOLS = ["update_docs_ledger"]; update_docs_ledger is a dry run unless write is true | match
CONTRACT: workspace_root property added to every tool by definition() | match
CONTRACT: 1034 init row: Get-DocsInitTemplate row Source .claude/lib/docs/templates/_docs-quality.yml, Destination .github/workflows/_docs-quality.yml | match
CONTRACT: 1034 gate key completion_gates.integration_pr_gate.enabled in .claude/hooks/enforce-docs-complete-gate.ps1 | match
CONTRACT: 1034 deny prefix DOCS_COMPLETE_GATE_BLOCKED: ($script:DocsCompleteGatePrefix) | match
CONTRACT: 1021 init -Write linter file set: .markdownlint.json, .vale.ini, .vale/styles/DocsBase/HeadingPunctuation.yml, .vale/styles/DocsBase/Placeholders.yml, .vale/styles/config/vocabularies/Project/accept.txt | match
CONTRACT: 1037 agents docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer under .claude/agents/ | match
CONTRACT: 1037 skills documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate under .claude/skills/ | match
