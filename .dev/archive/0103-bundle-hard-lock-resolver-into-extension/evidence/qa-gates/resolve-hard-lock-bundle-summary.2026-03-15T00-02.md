Timestamp: 2026-03-15T00-02

Root Source Files:
- `scripts/dev_tools/resolve_hard_lock_prompt.py`
- `.github/codex/execute-hard-lock.prompt.md`
- `.github/codex/resume-hard-lock.prompt.md`

Bundled Resource Files:
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py`
- `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`

Command ID:
- `drmCopilotExtension.resolveExecuteHardLockPrompt`

Wrapper Path:
- `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`

Notes:
- The bundled resolver mirror rewrites imports from `scripts.dev_tools` to `dev_tools` to run inside the extension resource package.
- The wrapper injects `--template-root` only when the caller did not already provide it.
- The bundled prompt files were verified to match the root prompt text line-for-line.
