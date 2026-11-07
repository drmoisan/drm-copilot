# Upstream Contracts (P0-T2)

Timestamp: 2026-11-07T15-59
Command: Grep of `.claude/lib/docs/Invoke-DocsCommand.ps1` (`$script:DocsCommandRow` rows), `extensions/drm-copilot/src/repo-automation-tool-names.ts`, `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` (`DOCS_TOOL_INPUT_TABLES`) and `.claude/settings.json` (`enforce-docs-complete-gate.ps1`) on the branch head after the integration merge that carries PR #1107.
EXIT_CODE: 0
Output Summary: PASS. Nine dispatch rows present with option maps; six docs MCP tool names present; the 1034 `enforce-docs-complete-gate.ps1` PreToolUse entry is present in `.claude/settings.json`. Supersedes the failing record `upstream-contracts.2026-11-06T12-41.md`.

## Dispatch rows (`Get-DocsCommandTable`)

| Name | Option map |
|---|---|
| `init` | `RepositoryId` value, `Profile` value, `Write` switch, `Force` switch |
| `validate-profile` | `Profile` value |
| `check` | `Profile` value, `Path` multi |
| `inventory` | `Profile` value, `Analyzer` multi, `Revision` value, `Write` switch, `AnalysisMethod` value |
| `coverage` | `Profile` value |
| `update-ledger` | `Profile`, `Operation`, `Element`, `Limit`, `Disposition` value; `Page` multi; `Rationale`, `Owner`, `Target`, `Dimension`, `State`, `Claim`, `ActorKind`, `ActorId` value; `Write` switch |
| `validate` | `Profile` value, `Mode` value, `Revision` value, `WriteReceipt` switch |
| `generate-reference` | `Profile` value, `Snapshot` value, `OutputDirectory` value, `Write` switch |
| `surface-delta` | `Base` value, `Profile` value |

Common options accepted on every row: `Json`, `Help`, `RepositoryRoot`.

## Docs MCP tools (1036) and input field names

Every tool also takes the required `workspace_root`.

| Tool | Subcommand | Input fields (required marked *) |
|---|---|---|
| `run_docs_check` | `check` | `profile`, `paths` |
| `run_docs_inventory` | `inventory` | `profile`, `analyzers`, `revision` |
| `run_docs_coverage` | `coverage` | `profile` |
| `update_docs_ledger` | `update-ledger` | `profile`, `operation`*, `element`, `limit`, `disposition`, `pages`, `rationale`, `owner`, `target`, `dimension`, `state`, `claim`, `actor_kind`*, `actor_id`*, `write` |
| `generate_docs_reference` | `generate-reference` | `profile`, `snapshot`, `output_directory` |
| `validate_docs_artifacts` | `validate` | `profile`, `mode`*, `revision`* |

Enumerations: operation `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`; disposition `documented`, `excluded`, `deferred`; dimension `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`; state `pass`, `fail`, `not-assessed`, `not-applicable`; actor_kind `human`, `agent`, `tool`; mode `profile`, `ledger`, `matrix`, `docs-complete`.

## 1034 settings entry

`.claude/settings.json` carries the command `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1`.
