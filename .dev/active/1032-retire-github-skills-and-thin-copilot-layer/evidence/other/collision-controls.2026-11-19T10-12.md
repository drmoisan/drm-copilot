# Copilot Collision Controls (AD-3) ([P1-T15])

Timestamp: 2026-11-19T10-12
Plan: plan.2026-10-30T18-39.md
Command: grep -c -F -e <key and value> README.md (one search per COLLISION-KEYS entry and the heading); grep -c '"chat\.' .vscode/settings.json; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_vscode_workspace_settings.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: WorkspaceScope read as `no`, so the user-scope case applies: `README.md` `### Copilot collision controls` names each COLLISION-KEYS key with its value (1 match each); `.vscode/settings.json` holds no `chat.` key (0); `.vscode/settings_required.json` does not exist; `test_workspace_settings_pin_vscode_to_powershell_7` and `test_workspace_settings_contain_no_host_specific_paths` pass (2 passed).

## Case Applied

WorkspaceScope (from `agents-branch-selection.2026-11-19T07-48.md`): no
Case: user scope (`README.md` section `### Copilot collision controls`, under `## Requirements`); no key is added to `.vscode/settings.json` and no test is added to `test_vscode_workspace_settings.py`.

## Fixed-String Search of README.md

| Search string | Matches |
| --- | --- |
| `### Copilot collision controls` | 1 |
| `"chat.agentSkillsLocations": { ".claude/skills": false }` | 1 |
| `"chat.instructionsFilesLocations": { ".claude/rules": false }` | 1 |
| `"chat.agentFilesLocations": { ".claude/agents": false }` | 1 |
| `"chat.useClaudeMdFile": false` | 1 |

KEPT-DEFAULT-KEYS (`chat.useAgentsMdFile`, `chat.useClaudeHooks`, `github.copilot.chat.codeGeneration.useInstructionFiles`) are named in the README only as keys to leave at their defaults; none is written to `.vscode/settings.json` or any other settings file.

## Child 4 Request

Request to child 4 (#1029, push-down consolidation and ecosystem packs): deliver every COLLISION-KEYS key with its value — `chat.agentSkillsLocations` with `".claude/skills": false`, `chat.instructionsFilesLocations` with `".claude/rules": false`, `chat.agentFilesLocations` with `".claude/agents": false`, and `chat.useClaudeMdFile` set to `false` — to the destination repository's `.vscode/settings.json` when it pushes the Copilot and Claude packs to the same destination, as research section 5.3 (Option 3) proposes (spec `## Scope` item 4). This feature does not deliver them to destinations (spec `## Non-Goals`).
