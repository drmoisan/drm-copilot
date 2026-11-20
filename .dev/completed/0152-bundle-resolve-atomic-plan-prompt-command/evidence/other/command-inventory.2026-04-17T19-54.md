Timestamp: 2026-04-17T20:07:00-04:00
Command: & 'C:\Users\DanMoisan\AppData\Local\Programs\Microsoft VS Code Insiders\e44fc34055\resources\app\node_modules\@vscode\ripgrep\bin\rg.exe' -n "Resolve Atomic Plan Prompt|resolveExecuteHardLockPrompt|promptForActiveFeaturePlan|resolve_file_prompt\.py|generate-atomic-plan\.prompt\.md" .vscode/tasks.json extensions/drm-copilot/src extensions/drm-copilot/resources extensions/drm-copilot/test tests
EXIT_CODE: 0
Output Summary: Baseline inventory captured repo-task references in `.vscode/tasks.json`, the existing bundled command pattern centered on `resolveExecuteHardLockPrompt`, the generic active-plan helper in `extension-command-helpers.ts`, and resolver-template test baselines in `tests/scripts/dev_tools/test_resolve_file_prompt.py`. Scope remains limited to the new additive command equivalent plus directly related tests.

Categorized Matches:

repo-task baseline
- `.vscode/tasks.json:990` -> `scripts/dev_tools/resolve_file_prompt.py`
- `.vscode/tasks.json:992` -> `${workspaceFolder}/.github/prompts/generate-atomic-plan.prompt.md`
- `.vscode/tasks.json:998` -> `Dev: Resolve Atomic Plan Prompt`

active-plan helper
- `extensions/drm-copilot/src/document-workflow-commands.ts:101` -> `promptForActiveFeaturePlan(workspaceRoot)`
- `extensions/drm-copilot/src/extension-command-helpers.ts:240` -> `export async function promptForActiveFeaturePlan(`
- `extensions/drm-copilot/test/extension-command-helpers.test.ts:52,273,286,296` -> helper import and coverage baseline

existing bundled command pattern
- `extensions/drm-copilot/src/repo-automation-service.ts:118,389` -> `resolveExecuteHardLockPrompt`
- `extensions/drm-copilot/src/document-workflow-commands.ts:95-116` -> command registration and delegation
- `extensions/drm-copilot/src/extension.ts:412,438` -> extension activation wiring
- `extensions/drm-copilot/src/mcp-tools.ts:538` -> service dispatch
- `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts:151-264` -> registration, picker, and runtime-failure coverage
- `extensions/drm-copilot/test/mcp-server.test.ts:33` -> mocked service surface

bundled resolver asset
- No bundled `resolve_file_prompt.py` implementation was found under `extensions/drm-copilot/resources`.
- No command-facing bundled atomic-plan wrapper or prompt-resolution asset reference was found under `extensions/drm-copilot/resources` for this workflow.

test baseline
- `tests/scripts/dev_tools/test_resolve_file_prompt.py:448,514` -> canonical resolver clipboard-path coverage
