# F8 Scope Verification

Timestamp: 2026-06-26T00-00
Command: `git diff --name-only` and `git status --short` (repo root); `git check-ignore`; `wc -l extensions/drm-copilot/src/repo-automation-service.ts`
EXIT_CODE: 0

## Touched files (change set)

Modified (tracked):
- `extensions/drm-copilot/src/repo-automation-service.ts` — `newActiveFeatureFolder` delegation + import swap only.
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` — Python-spawn cases reworked to in-process expectation.
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts` — removed the `--template-root` Python-spawn assertion (reworked into the inprocess file).

New (untracked, eligible to add — verified NOT gitignored via `git check-ignore` exit 1):
- `extensions/drm-copilot/src/lib/new-active-feature-folder/` — `models.ts`, `markdown.ts`, `io.ts`, `docs.ts`, `flow.ts`, `index.ts`, `new-active-feature-folder-service-call.ts`.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/` — `models.test.ts`, `markdown.test.ts`, `io.test.ts`, `docs.test.ts`, `flow.test.ts`, `new-active-feature-folder-service-call.test.ts`, `fakes.ts`.
- `extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts`.
- `extensions/drm-copilot/test/new-active-feature-folder-fs-harness.ts` (shared in-memory fs harness for the two extension test files).
- Evidence artifacts under `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/` and the plan file.

Note: `markdown-header.ts`, `io-launcher.ts`, and `flow-minor-audit.ts` were NOT created — no file approached 500 lines, so the contingent Split-Strategy extractions were unnecessary. The shared `new-active-feature-folder-fs-harness.ts` was added to keep both extension test files under 500 lines (authorized by the P4-T4 500-line watch).

## Prohibited paths — confirmed UNTOUCHED

`git status --short` reported no changes for any of:
- `extensions/drm-copilot/src/command-runtime.ts` (the `"python"` runtime branch).
- `extensions/drm-copilot/src/repo-automation-service-workflows.ts` (`buildNewActiveFeatureFolderOptions` body retained; only the import was dropped from the service file).
- `extensions/drm-copilot/src/repo-automation-args.ts` (`buildNewActiveFeatureFolderArgs`).
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` (`resolveNewActiveFeatureFolderToolInput`).
- `extensions/drm-copilot/src/mcp-handlers/` (`handleNewActiveFeatureFolder`).
- `extensions/drm-copilot/src/lib/file-system.ts`, `subprocess-runner.ts`, `prompt-mode-contract.ts` (shared F1 interfaces).
- `extensions/drm-copilot/resources/**/*.py` and `scripts/dev_tools/**` (Python sources; removal is F11).
- `executeScript` and `executeBundledScriptFromExtensionRoot` were not modified.

## Service file line count

`extensions/drm-copilot/src/repo-automation-service.ts` = 499 lines (<= 500). PASS.

Result: change set matches the allowed list; no out-of-scope file modified; service file within the limit.
