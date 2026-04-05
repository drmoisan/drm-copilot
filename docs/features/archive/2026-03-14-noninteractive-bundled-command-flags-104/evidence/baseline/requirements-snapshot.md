Objective:
- Extend the four existing workflow command IDs in `extensions/drm-copilot` so zero arguments preserve the current interactive human flow while any supplied CLI-style string arguments trigger strict non-interactive validation and direct bundled-script invocation.
- Update root orchestrator agents and mirrored customization resources to use direct extension-command invocation with explicit canonical work-mode values.

Constraints Preserved:
- Keep existing public interactive command IDs available.
- Do not replace the human-friendly interactive flow; add direct invocation only when explicit args are provided.
- Prefer CLI-style string arg arrays matching underlying script flags.
- Use canonical work modes (`minor-audit`, `full-feature`, `full-bug`; legacy `full` only where compatibility requires it).
- No new runtime dependencies unless absolutely necessary.
- If orchestrator docs/resources change, mirrored customization resources must stay aligned.

Command IDs:
- drmCopilotExtension.newPotentialEntry
- drmCopilotExtension.newPotentialBugEntry
- drmCopilotExtension.potentialToIssue
- drmCopilotExtension.newActiveFeatureFolder

Direct Flag Contracts:
- `drmCopilotExtension.newPotentialEntry`: `-ShortName <kebab-case>` plus extension-managed `-TemplateRoot <bundled template root>` in direct mode.
- `drmCopilotExtension.newPotentialBugEntry`: `--short-name <kebab-case>` plus extension-managed `--template-root <bundled template root>` in direct mode.
- `drmCopilotExtension.potentialToIssue`: `--potential-path <path> --promotion-type <epic|feature|refactor|bug> --work-mode <minor-audit|full-feature|full-bug|full>`.
- `drmCopilotExtension.newActiveFeatureFolder`: `--feature-name <slug> --type <epic|feature|refactor|bug> [--issue-number <digits>] --work-mode <minor-audit|full-feature|full-bug|full>` plus extension-managed `--template-root <bundled template root>` in direct mode.

Large-Path Orchestrator Files:
- .github/agents/orchestrator.agent.md
- .github/agents/python-orchestrator.agent.md
- .github/agents/powershell-orchestrator.agent.md
- .github/agents/csharp-orchestrator.agent.md

Mirrored Agent Files:
- extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md
- extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md
- extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md
- extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md
