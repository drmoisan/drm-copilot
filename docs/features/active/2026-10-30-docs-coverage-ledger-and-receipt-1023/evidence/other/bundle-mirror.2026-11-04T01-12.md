# Bundle Mirror ([P6-T1])

Timestamp: 2026-11-04T01-12
Command: sh SCRATCH/issue-1023-mirror.sh (copies each new .claude/lib/docs module and Invoke-DocsCommand.ps1 to extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs, compares the SHA-256 of source and copy, then prints git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs)
EXIT_CODE: 0
Output Summary: 11 files copied (10 new module copies, 1 modified entry-script copy); every copy's SHA-256 equals its source; the porcelain listing holds exactly those 11 paths (1 ` M`, 10 `??`) and nothing else.

## Listing (`git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs`)

```text
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCoverageReport.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsEvidencePins.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedger.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedgerCommands.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedgerMutation.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedgerRules.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsParity.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsReceipt.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsStaleness.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsValidation.psm1
```

## Digests (SHA-256 of the source; the copy is equal)

| File | SHA-256 |
|---|---|
| `DocsLedger.psm1` | `7f0be2befe3f1e9fbf9d8492d6824e44f036e99b77188141fe8b888bb8252d4a` |
| `DocsLedgerRules.psm1` | `f55d888f6322b7e5a3b33e44c3c826705cbdb71f355af11f8bb2997118dda147` |
| `DocsEvidencePins.psm1` | `c1264d45061077b650adb2922410eee4c3c7039b32d97f1c6ef01615849fc5d7` |
| `DocsStaleness.psm1` | `1fa728e712f79e241764ba3d43b5068ebee93f1eed61643a0bedc438fdc204d2` |
| `DocsParity.psm1` | `65bf0004d7895a80b169ce9bcc3764f0dd82a8662f1e529152fc51ae532da4f6` |
| `DocsReceipt.psm1` | `1504afc8d275fc91aea7aff783ab6b44b7a181725ce49d761699919012b6c7ed` |
| `DocsLedgerMutation.psm1` | `ae761b7f7577eba22408ff1a9fc1518ebe600a399d42759fe2963619012ef6f7` |
| `DocsValidation.psm1` | `7905da420b487c8075c43e85df9cce341c0d614893353b990e0f7b9defbda1a3` |
| `DocsCoverageReport.psm1` | `110b47e32d4d9a0f9daec96dd721aefbf2ebc557c45597fa6b14f729d71dcfae` |
| `DocsLedgerCommands.psm1` | `da6b65f935a9c395aefcec61fc4d6992b980215ed6eed05c28ee3c09b3752158` |
| `Invoke-DocsCommand.ps1` | `8743cc179a1b908406ddb0fbbe2c27c1b057b157789e749bb73345685a0d496c` |

The two pre-approved splits (`DocsLedgerRules.psm1`, `DocsCoverageReport.psm1`) are included, so the bundle gains ten module copies.
