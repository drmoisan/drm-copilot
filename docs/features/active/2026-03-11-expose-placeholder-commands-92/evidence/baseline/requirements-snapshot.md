Timestamp: 2026-03-11T22-16
Work Mode: full-feature
Requirements Sources:
- /workspaces/drm-copilot/docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md
- /workspaces/drm-copilot/docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md
- /workspaces/drm-copilot/docs/features/active/2026-03-11-expose-placeholder-commands-92/research.md
- /workspaces/drm-copilot/docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md
Implementation Order:
- newPotentialBugEntry -> newPotentialEntry -> potentialToIssue -> newActiveFeatureFolder

Command IDs:
- drmCopilotExtension.newPotentialBugEntry
- drmCopilotExtension.newPotentialEntry
- drmCopilotExtension.potentialToIssue
- drmCopilotExtension.newActiveFeatureFolder
- Placeholder IDs to remove:
  - drmCopilotExtension.newPotentialBugEntryPyPlaceholder
  - drmCopilotExtension.newPotentialEntryPsPlaceholder
  - drmCopilotExtension.potentialToIssuePlaceholder
  - drmCopilotExtension.newActiveFeatureFolderPlaceholder

Bundled File Manifest:
- resources/templates/new_potential_bug_entry.py
- resources/templates/new-potential-entry.ps1
- resources/templates/vscode-cli.helpers.ps1
- resources/templates/potential_to_issue.py
- resources/templates/new_active_feature_folder.py
- resources/scripts/dev_tools/prompt_mode_contract.py
- resources/scripts/dev_tools/potential_to_issue.py
- resources/scripts/dev_tools/potential_to_issue_content.py
- resources/scripts/dev_tools/new_active_feature_folder.py
- resources/scripts/dev_tools/new_active_feature_folder_flow.py
- resources/scripts/dev_tools/new_active_feature_folder_io.py
- resources/scripts/dev_tools/new_active_feature_folder_models.py
- resources/scripts/dev_tools/new_active_feature_folder_markdown.py
- resources/scripts/dev_tools/new_active_feature_folder_docs.py

Notes:
- Real handlers must gather user input via VS Code UI and delegate to executeBundledScript().
- Thin wrapper templates must follow the existing extension-side bundling pattern.
