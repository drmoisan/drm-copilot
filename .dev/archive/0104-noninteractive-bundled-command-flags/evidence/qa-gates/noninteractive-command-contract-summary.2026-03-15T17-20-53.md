Changed TypeScript Files:
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
- `extensions/drm-copilot/test/extension.test.ts`
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`

Changed PowerShell Files:
- `scripts/dev-tools/new-potential-entry.ps1`
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`
- `tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1`

Changed Orchestrator Files:
- `.github/agents/orchestrator.agent.md`
- `.github/agents/python-orchestrator.agent.md`
- `.github/agents/powershell-orchestrator.agent.md`
- `.github/agents/csharp-orchestrator.agent.md`

Mirrored Files:
- `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md`

Preserved Public Command IDs:
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`
- `extensions/drm-copilot/package.json` continues to expose the existing workflow command IDs only; both interactive and direct execution still run through the same bundled script backends.

Interactive Fallback Preserved:
- Zero-argument invocation keeps the existing prompt-driven flows for all four workflow commands.
- Interactive cancellation still returns without launching the bundled script.
- The direct-mode resolver is only engaged when invocation arguments are supplied.

Direct Validation Guards:
- Rejects non-string arguments before any workflow execution.
- Rejects unknown flags, duplicate flags, missing flag values, and missing required flags.
- Enforces short-name, feature-name, promotion-type/type, work-mode, and issue-number validation rules before any UI prompt or bundled script launch.
- Skips `showInputBox`, `showQuickPick`, and `showOpenDialog` entirely in direct mode and appends template-root arguments only for the workflows that require them.

Coverage Artifacts:
- `evidence/other/extension-direct-command-green.2026-03-14T23-57.md`
- `evidence/other/orchestrator-direct-command-contracts-green.2026-03-15T00-07-24.md`
- `evidence/qa-gates/typescript-test.2026-03-15T00-33-57.md`
- `evidence/qa-gates/typescript-coverage-delta.2026-03-15T00-34-00.md`
- `evidence/qa-gates/python-test.2026-03-15T00-34-51.md`
- `evidence/qa-gates/python-coverage-delta.2026-03-15T00-34-54.md`
- `evidence/qa-gates/powershell-test.2026-03-15T00-21-26.md`
- `evidence/qa-gates/powershell-coverage-delta.2026-03-15T17-20-53.md`
