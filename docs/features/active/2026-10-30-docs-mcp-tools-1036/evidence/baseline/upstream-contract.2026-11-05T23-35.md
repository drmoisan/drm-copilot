# Upstream Contract on the Execution Base ([P0-T3])

Timestamp: 2026-11-05T23-35
Command: Read `schemas/docs/v1/docs-command-envelope.schema.json`; Grep of `.claude/lib/docs/Invoke-DocsCommand.ps1` for the dispatch-table rows and `ConvertFrom-DocsCommandArgument`
EXIT_CODE: 0
Output Summary:

OPTION-MAP: check | match
OPTION-MAP: inventory | match
OPTION-MAP: coverage | match
OPTION-MAP: update-ledger | match
OPTION-MAP: validate | match
OPTION-MAP: generate-reference | match
ENVELOPE-SCHEMA: required=command,exit_code,findings,ok,result additionalProperties=false

Details:
- Dispatch rows (committed): `check` Profile value, Path multi; `inventory` Profile value, Analyzer multi, Revision value, Write switch; `coverage` Profile value; `update-ledger` Profile, Operation, Element, Limit, Disposition value, Page multi, Rationale, Owner, Target, Dimension, State, Claim, ActorKind, ActorId value, Write switch; `validate` Profile, Mode, Revision value, WriteReceipt switch; `generate-reference` Profile, Snapshot, OutputDirectory value, Write switch. Each equals UPSTREAM-MAP (confirmations `## F1`).
- Multi form: `ConvertFrom-DocsCommandArgument` exempts `multi` options from the repeated-option error and appends the token after each `-<Name>` occurrence, so a multi option is repeatable as one `-<Name> <value>` pair per element.
- Reserved names in the dispatch-table check: Command, Json, Help, RepositoryRoot.
- No adaptation required; not BLOCKED.
