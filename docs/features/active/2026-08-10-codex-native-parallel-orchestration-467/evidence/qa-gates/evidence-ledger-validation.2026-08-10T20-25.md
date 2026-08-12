# Evidence and Translation Ledger Validation

Timestamp: `2026-08-11T19-43-04:00`

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root docs/features/active/2026-08-10-codex-native-parallel-orchestration-467; read-only PowerShell receipt-schema, source/snapshot SHA-256, translation-diff manifest, override-marker, ledger, state, and git-diff comparators`

EXIT_CODE: `0`

Output Summary: Canonical evidence locations, all `43/43` strict command-receipt schemas, all `25/25` source/snapshot byte comparisons, all `25/25` deterministic translation-diff rows, the exact override marker, and both `16 PRESERVED / 2 DEGRADED / 0 LOST` ledgers passed. The outside-allowlist manifest remained byte-invariant, `.codex/state` was absent, and `git diff --check` exited `0`.

## Canonical location validation

- `validate_evidence_locations.py` exit: `0`.
- Forbidden `artifacts/` evidence violations: `0`.
- Canonical evidence kinds: `baseline`, `other`, `qa-gates`, and `regression-testing`.
- Canonical files: `603` (`baseline=219`, `other=27`, `qa-gates=315`, `regression-testing=42`).
- Exact override marker in translation plan: `true`.
- Exact override marker in translation diff: `true`.
- Required marker: `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.

## Command receipt schema

Required fields are `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- Strict command receipts: `43`.
- Schema-complete receipts: `43 / 43`.
- Incomplete receipts: `0`.
- The nine plan-named receipts received only their missing schema labels and concise summaries; recorded commands, exits, counts, hashes, and results remain present.

## Translation snapshots and deterministic diff

- Expected snapshots: `25`.
- Present snapshots: `25`.
- Source paths present: `25 / 25`.
- Source/snapshot SHA-256 and byte equality: `25 / 25`.
- Missing sources: `0`.
- Source/snapshot mismatches: `0`.
- Containment violations: `0`.
- Translation diff: `evidence/other/translation-diff.2026-08-10T20-25.md`.
- Translation diff SHA-256: `6174A851E2A5E7718EE4EC6366AED8E7E0BB0EF6728768AC23B3B205BD80C2F3`.
- Mapping rows: `16`.
- Unresolved conflicts: `0`.
- Snapshot-manifest rows: `25`.
- Rows matching current source and snapshot bytes, lines, and SHA-256: `25 / 25`.
- Stale rows: `0`.

The corrected G16 row is exact:

| Source path | Bytes | Lines | SHA-256 | Exact |
| --- | ---: | ---: | --- | --- |
| `tests/scripts/codex-hooks/parallel-completion-compensating-controls.Tests.ps1` | `11,957` | `267` | `D9ADCC70046BD0D8B8F13CDD3AF930131EB8FD2509ADEA61486CDA1D4B278121` | `yes` |

The source and repository-relative translation snapshot have identical bytes, line count, and SHA-256.

## Enforcement ledger

| Source | Gate rows | PRESERVED | DEGRADED | LOST |
| --- | ---: | ---: | ---: | ---: |
| `translation-plan.2026-08-10T20-25.md` | `18` | `16` | `2` | `0` |
| `translation-diff.2026-08-10T20-25.md` | `18` | `16` | `2` | `0` |

The only DEGRADED rows remain G02 and G16, each with its named tested compensating control. No row is LOST.

## Bounded-remediation invariants

- Authorized content edits: nine plan-named receipt schema additions and one G16 translation-diff row.
- Outside-allowlist changed paths: `771` before and after.
- Outside-allowlist aggregate SHA-256: `121314ECCA1411F84B7435A91A587DAA56F5AB46EC799AB090AF7BC6F8375A9F` before and after.
- Product, source, test, workflow, configuration, source-snapshot, and ledger edits: `0`.
- `.codex/state` absent: `true`.
- `git diff --check` exit: `0`.

## Result

`P6_T21_STATUS: COMPLETE`
