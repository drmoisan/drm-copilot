# docs-findings-limit-envelope-schema (Issue #1230)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1230-docs-findings-limit-envelope-schema/ (Issue #1230)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1230
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1230
- Last Updated: 2026-11-23
## Summary

A docs command that produces more than 100 findings exits 0 with output that breaks its schema. `New-DocsCommandResult` appends an `error` `FINDINGS_LIMIT` finding when the finding set exceeds its default limit of 100, but it leaves `ExitCode` at 0, while the envelope schema requires every finding of an exit-0 envelope to be `warning` or `info`.

## Environment

- OS/version: any (observed by code reading on Windows 11, PowerShell 7.6)
- Python version: not applicable (PowerShell docs library)
- Command/flags used: any docs command routed through `.claude/lib/docs/Invoke-DocsCommand.ps1` (for example `docs-check`, `coverage`, `validate`) whose finding set holds more than 100 `warning` or `info` findings
- Data source or fixture: a docs profile and snapshot that produce more than 100 non-error findings

## Steps to Reproduce

1. Build a docs estate whose command run yields more than 100 findings, all of severity `warning` or `info`.
2. Run the command through `Invoke-DocsCommand.ps1` with `-Json`.
3. Validate the emitted envelope against `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json`.

## Expected Behavior

Either the exit code is non-zero when an `error` finding is present, or the truncation marker is not an `error` finding, so that the envelope satisfies its own schema (exit 0 implies only `warning` and `info` findings).

## Actual Behavior

The envelope carries 101 findings, the last of which is an `error` `FINDINGS_LIMIT` finding, and the exit code is 0. The envelope therefore fails the schema rule that an exit-0 envelope carries no `error` finding.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: found by code reading in `New-DocsCommandResult` (`.claude/lib/docs/DocsFinding.psm1`) during research for issue #1221; recorded as Decision 13 of that item.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

`New-DocsCommandResult` in `.claude/lib/docs/DocsFinding.psm1` applies the default finding limit of 100 and appends the `FINDINGS_LIMIT` finding with severity `error` without recomputing the exit code. The envelope schema (`docs-command-envelope.schema.json`) sets `findings` `maxItems: 101` and requires exit 0 to carry only `warning` and `info` findings. The defect is independent of documentation families and affects every docs command; issue #1221 does not reach it and does not change it.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: `New-DocsCommandResult` with 101 non-error findings asserts that the result is schema-valid (either a non-zero exit code or a non-error truncation marker).
- [ ] Integration scenario to retest: envelope schema validation of a command result above the limit.
- [ ] Manual verification notes: confirm the MCP docs handlers (`docs-handlers.ts`) render the chosen shape.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
