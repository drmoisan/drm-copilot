# Command Reference

Every subcommand runs through `.claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name>`. The
examples run from a PowerShell 7.4 session at the repository root. Revisions are full 40- or
64-character lowercase hexadecimal values; the examples use a placeholder revision.

## Common Parameters

- `-Command <name>`: the subcommand to run.
- `-Json`: write one JSON envelope to standard output instead of the text report.
- `-Help`: print the usage of the subcommand and exit 0.
- `-RepositoryRoot <path>`: the repository root; the current directory when omitted.

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success, or `-Help`. |
| 1 | The command reported at least one error finding. |
| 2 | Usage error: exactly one `DOCS_CLI_ARGUMENTS` finding and a null `result`. |
| 3 | Internal or environment error: one `DOCS_CLI_RUNTIME` finding, or `DOCS_RUNTIME_UNSUPPORTED` when PowerShell is older than 7.4. |

## JSON Envelope

With `-Json`, standard output is one JSON object with the keys `command`, `exit_code`, `findings`,
`ok` and `result`. `findings` is a list of finding objects with a `code`, a `severity` and a
message; `result` is the command-specific result or `null`. The envelope is governed by
`schemas/docs/v1/docs-command-envelope.schema.json`.

## Subcommands

### `init`

Writes the starter docs profile, the page-check configuration and the `_docs-quality.yml` workflow.
It is a dry run unless `-Write` is given; `-Force` overwrites existing files.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command init -RepositoryId example-repository -Write
```

### `validate-profile`

Validates the docs profile against its schema and the profile rules.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate-profile -Profile docs/documentation-estate/docs-profile.json
```

### `check`

Checks the pages under the documentation roots: structure, metadata and links. It is the required
page gate. The `result` has the keys `page_count`, `profile_path` and `roots`.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command check -Json
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command check -Path docs/guide/index.md -Path docs/guide/install.md
```

### `inventory`

Builds the surface inventory snapshot. `-Analyzer` (repeatable) selects analyzers, `-Revision` pins
the snapshot to a full revision, `-AnalysisMethod` selects `auto` (default), `native` or `scanner`,
and `-Write` writes the snapshot to the `artifact_paths.inventory_snapshot` path of the profile.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Revision 0123456789abcdef0123456789abcdef01234567 -AnalysisMethod scanner -Write
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Analyzer python-cli -Analyzer config-files -Json
```

### `coverage`

Reports documentation coverage over the profile, snapshot, ledger, parity matrix and pins. It is
read-only.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command coverage -Json
```

### `update-ledger`

Changes the coverage ledger, the parity matrix or the evidence pins with one `-Operation`:
`set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension` or `sync-refs`. Every call names
the actor with `-ActorKind` (`human`, `agent` or `tool`) and `-ActorId`. It is a dry run unless
`-Write` is given.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command update-ledger -Operation set-disposition -Element cli-command-0000000000000000000000000000000000000000000000000000000000000000 -Disposition documented -Page docs/reference/cli-reference.md -ActorKind human -ActorId maintainer -Write
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command update-ledger -Operation pin -Element cli-command-0000000000000000000000000000000000000000000000000000000000000000 -Page docs/reference/cli-reference.md -ActorKind tool -ActorId docs-pipeline -Write
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command update-ledger -Operation set-dimension -Element cli-command-0000000000000000000000000000000000000000000000000000000000000000 -Page docs/reference/cli-reference.md -Dimension accurate -State pass -ActorKind agent -ActorId docs-reconciler -Write
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command update-ledger -Operation sync-refs -ActorKind tool -ActorId docs-pipeline -Write
```

Other options: `-Limit` names a precision-limit diagnostic instead of `-Element`; `-Rationale`,
`-Owner`, `-Target` and `-Claim` add text to an entry or pin; `-Profile` selects the profile.

### `validate`

Validates the artifacts in one `-Mode`: `profile`, `ledger`, `matrix` or `docs-complete`.
`-Revision` is required unless `-WriteReceipt` is given: with `-WriteReceipt` in `docs-complete`,
`-Revision` defaults to the snapshot revision of the inventory, and a null or absent snapshot
revision is a usage error that names `inventory -Revision`. `-WriteReceipt` persists the
validation receipt and applies only to `docs-complete`. In `docs-complete` mode a passing result is
also checked with the receipt revision rule against the repository `HEAD`; a denial is reported as
the error finding `DOCS_RECEIPT_REVISION_REJECTED` and no receipt is written. For profile-only checks use `validate-profile`; `validate -Mode profile` overlaps
with it.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -Revision 0123456789abcdef0123456789abcdef01234567 -Json
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -Revision 0123456789abcdef0123456789abcdef01234567 -WriteReceipt
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt
```

### `generate-reference`

Plans or writes the generated reference pages from the snapshot. It is a dry run unless `-Write` is
given. `-Snapshot` and `-OutputDirectory` override the profile paths. The `result` has the keys
`mode`, `output_directory`, `pages`, `summary` and `unrendered`. It exits 1 on
`REFERENCE_WRITE_CONFLICT` and 3 when a write fails.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Json
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Write
```

### `surface-delta`

Compares the surface inventory, coverage ledger and evidence pins of the working tree with the same
artifacts at `-Base`, a full revision or a branch or ref name. The `result` has the keys
`base_revision`, `added`, `changed` and `removed`, for review before a merge.

```powershell
& ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command surface-delta -Base main -Json
```

## MCP Tools

The docs MCP tools wrap the subcommands for agents. Their MCP names are
`mcp__drm-copilot__<tool>`. Every tool requires `workspace_root`, the absolute path of the
repository. `init`, `validate-profile` and `surface-delta` have no MCP tool. `update_docs_ledger` is
the only mutating tool, and it writes only with `write: true`. `validate_docs_artifacts` never
persists a receipt.

### `run_docs_check`

Runs `check`.

```json
{ "workspace_root": "/home/user/repository", "paths": ["docs/guide/index.md"] }
```

### `run_docs_inventory`

Runs `inventory` and returns the snapshot in the envelope `result` without writing it.

```json
{ "workspace_root": "/home/user/repository", "analyzers": ["python-cli"], "revision": "0123456789abcdef0123456789abcdef01234567" }
```

### `run_docs_coverage`

Runs `coverage`.

```json
{ "workspace_root": "/home/user/repository", "profile": "docs/documentation-estate/docs-profile.json" }
```

### `update_docs_ledger`

Runs `update-ledger`. It is a dry run unless `write` is `true`.

```json
{ "workspace_root": "/home/user/repository", "operation": "pin", "element": "cli-command-0000000000000000000000000000000000000000000000000000000000000000", "pages": ["docs/reference/cli-reference.md"], "actor_kind": "agent", "actor_id": "docs-reconciler", "write": true }
```

### `generate_docs_reference`

Runs `generate-reference` as a dry run; it never writes pages.

```json
{ "workspace_root": "/home/user/repository", "output_directory": "docs/reference" }
```

### `validate_docs_artifacts`

Runs `validate` for one mode and revision; it never persists a receipt.

```json
{ "workspace_root": "/home/user/repository", "mode": "docs-complete", "revision": "0123456789abcdef0123456789abcdef01234567" }
```
