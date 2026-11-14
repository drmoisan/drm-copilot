# docs-mcp-tools (Issue #1036) - Orchestrator Confirmations

- Issue: #1036
- Branch: `feature/docs-mcp-tools-1036`
- Timestamp: 2026-10-30T23-30
- Purpose: answers to `## Facts Needing Orchestrator Confirmation` in `research.2026-10-30T23-05.md`.
  The researcher could not run `git show` or `gh`; the orchestrator ran them.

## F1 - Re-prepared upstream contracts and PowerShell option names (supersedes the provisional table)

The re-prepared PowerShell designs are not yet merged into
`epic/documentation-estate-tooling-integration`. They are committed on the upstream feature branches
`feature/docs-page-quality-checker-1021`, `feature/docs-surface-analyzers-python-config-1022`,
`feature/docs-coverage-ledger-and-receipt-1023`, `feature/docs-reference-generator-1024` and
`feature/docs-profile-and-artifact-schemas-1020` (research addenda for all; revised spec for 1020 and
1022). Method: `git grep` over those remote branches for the dispatch-table rows.

Dispatch-table option maps (`Option` kind per PascalCase name) as committed on those branches:

| Subcommand | Owner | Option map |
|---|---|---|
| `check` | 1021 (research addendum) | `Profile` value; `Path` multi |
| `inventory` | 1022 (revised spec) | `Profile` value; `Analyzer` multi; `Revision` value; `Write` switch |
| `coverage` | 1023 (research addendum) | `Profile` value |
| `update-ledger` | 1023 (research addendum) | `Profile`, `Operation`, `Element`, `Limit`, `Disposition` value; `Page` multi; `Rationale`, `Owner`, `Target`, `Dimension`, `State`, `Claim`, `ActorKind`, `ActorId` value; `Write` switch |
| `validate` | 1023 (research addendum) | `Profile` value; `Mode` value; `Revision` value; `WriteReceipt` switch |
| `generate-reference` | 1024 (research addendum) | `Profile` value; `Snapshot` value; `OutputDirectory` value; `Write` switch |

Differences from the provisional table in the research file:

- `check` takes `-Path` (multi) and `-Profile` only; the provisional `-Root`, `-Entry` and
  `-Exclude` options do not exist.
- `generate-reference` uses `-OutputDirectory`, not `-OutputDir`.
- `update-ledger` has an additional `-Limit` value option.
- `inventory` and `generate-reference` each have a `-Write` switch; `validate` has `-WriteReceipt`.
  Under the strict reading of the "only mutating tool" criterion (research OQ-A provisional
  default), the MCP tools for `inventory`, `generate-reference` and `validate` never emit those
  switches.

These rows are still pre-clearance upstream text; the plan keeps the option names in one
declarative table per tool so a later rename is a one-line change.

### F1a - Resolutions of the feature-document open issues (orchestrator, 2026-10-30T23-40)

- Multi-value form: the revised 1020 spec `#### Dispatch table` defines `multi` as "repeatable", and
  exit 2 covers a "repeated non-`multi` option". A multi option is therefore passed as one
  `-<Name> <value>` pair per array element, in array order (for example `-Path a.md -Path b.md`).
- `check -Path`: the 1021 PowerShell addendum (`-Path <relative path>` (repeatable), finding
  `DOCS_PAGE_PATH_UNMATCHED`) takes relative paths, not globs; a path matching no page is a finding
  (exit 1), not a usage error.
- `update-ledger -Limit`: the 1023 PowerShell addendum `### 5.2 update-ledger` permits `-Limit` only
  for `set-disposition` and `remove-entry`, as an alternative to `-Element` (`-Element` xor
  `-Limit`). Grammar: docs `identifier` with the `diagnostic-` prefix. `-Limit` with a
  `-Disposition` other than `deferred` is exit 2 in PowerShell. Every operation requires
  `-ActorKind` (`human`, `agent`, `tool`) and `-ActorId`. Per-operation table (required / optional):
  `set-disposition` (`Element` xor `Limit`, `Disposition` / `Page` multi with optional `#anchor`,
  `Rationale`, `Owner`, `Target`); `remove-entry` (`Element` xor `Limit` / none); `pin` (`Element`,
  one `Page` without anchor / `Claim`); `unpin` (`Element`, one `Page` without anchor / none);
  `set-dimension` (`Element`, one `Page` without anchor, `Dimension`, `State` / `Rationale`);
  `sync-refs` (none / none). Dry run is the default; `-Write` commits.

## F2 - Envelope schema text

The revised 1020 spec on `feature/docs-profile-and-artifact-schemas-1020`, section
`### Envelope schema: docs-command-envelope`, fixes `schemas/docs/v1/docs-command-envelope.schema.json`:
`$id` `urn:drm-copilot:docs:1.0.0:docs-command-envelope`; `additionalProperties: false`; `required`
`command, exit_code, findings, ok, result`; `command` string or null with a kebab-case pattern;
`exit_code` integer enum 0-3; `findings` array, `maxItems: 101`, items referencing docs common
`finding`; `ok` boolean; `result` open. Conditional rules: exit 0 requires `ok` true and only
`warning`/`info` findings, otherwise `ok` false; exit 1 requires at least one finding; exit 2 and 3
require exactly one finding and `result` null. `## Decisions Later Children Must Honor` in that
revision states that 900007 parses the envelope "whose shape is fixed by
`docs-command-envelope.schema.json`; it adds no logic". The "no schema file" sentence is withdrawn
in that revision. The schema file itself is not yet committed on any branch.

## F3 - MCP SDK version

`extensions/drm-copilot/package-lock.json` locks `@modelcontextprotocol/sdk` at 1.32.1. The tool
`annotations` object is part of the MCP tool schema from specification revision 2025-03-26 onward.
`node_modules` is absent from this worktree, so forwarding is not verified locally; the plan's Jest
`client.listTools()` test is the verification.

## F4 - Windows argument quoting and stdout encoding through `pwsh -File`

Not verifiable before 1020-1024 land; remains a probe item for execution after the upstream
features merge into the integration branch.

## F5 - Concurrent edits

`gh pr list --state open` (60 most recent) shows no open pull request touching
`extensions/drm-copilot/src/mcp-tools.ts`, `src/repo-automation-tool-names.ts`,
`src/mcp-repo-automation-tool-definitions.ts`, `src/mcp-tool-definitions.ts`,
`src/repo-automation-service*.ts` or `test/mcp-server.test.ts`.
