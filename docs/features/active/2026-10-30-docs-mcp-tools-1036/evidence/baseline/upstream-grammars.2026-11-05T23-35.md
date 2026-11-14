# Upstream Grammars and Ledger Rules ([P0-T4])

Timestamp: 2026-11-05T23-35
Command: Read `schemas/docs/v1/common.schema.json`; Read `.claude/lib/docs/DocsLedgerCommands.psm1` (`$script:DocsLedgerCommandOperation`, `Test-DocsUpdateLedgerArgument`, `Get-DocsLedgerCommandPageBinding`)
EXIT_CODE: 0
Output Summary:

PARITY-SOURCE: schemas/docs/v1/common.schema.json
PATTERN: relative-path | present
PATTERN: identifier | present
PATTERN: revision | present
PATTERN: element-id | present
PATTERN: page-reference | absent
LEDGER-RULES: match

Details:
- `schemas/docs/v1/common.schema.json` exists, so PARITY-SOURCE is the docs v1 common schema (D-3).
- `relative-path`, `identifier` and `revision` patterns end with the `(?![\s\S])` lookahead; the committed `element-id` pattern has no terminating lookahead, so the TypeScript constant equals the committed string without one (parity is string equality with the committed value).
- No page-reference definition exists in PARITY-SOURCE (`page-binding` is an object definition). The ledger module parses a `-Page` value as `<relative path>[#<anchor>]`: split at the first `#`, the path must satisfy `Test-DocsRelativePath`, and an anchor, when present, must contain a non-whitespace character. The page-reference grammar is pinned by literal accept and reject tests ([P2-T4]).
- Committed per-operation table (`$script:DocsLedgerCommandOperation`) compared with confirmations `### F1a`:
  - `set-disposition`: required Disposition, optional Page, Rationale, Owner, Target, target Element xor Limit. match
  - `remove-entry`: no required or optional option, target Element xor Limit. match
  - `pin`: required Page (exactly one, no anchor), optional Claim, target Element. match
  - `unpin`: required Page (exactly one, no anchor), target Element. match
  - `set-dimension`: required Page (exactly one, no anchor), Dimension, State; optional Rationale; target Element. match
  - `sync-refs`: none. match
  - Common to every operation: Profile, Operation, ActorKind (required, `human`, `agent`, `tool`), ActorId (required identifier), Write. match
  - `-Limit` grammar: identifier pattern plus `diagnostic-` prefix; `-Limit` with a `-Disposition` other than `deferred` is a usage error in PowerShell. match
- Not BLOCKED.
