# Remediation Evidence Validation

Timestamp: `2026-08-13T15-38`

Plan task: `[P6-T3]`

Overall result: `PASS`

## Canonical evidence locations

Command: `python scripts/dev_tools/validate_evidence_locations.py --root .`

- Exit code: `0`.
- Standard output: empty.
- Standard error: empty.
- Non-canonical evidence paths: `0`.

## Changed-evidence scope

The read-only inventory used:

```powershell
git diff --name-only --diff-filter=ACMRTUXB fe0413d4aca1e76b2d02d05701fba79a887d5405 -- docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence
```

- Existing changed evidence files: `1,217`.
- Changed Markdown evidence files: `202`.
- Markdown files containing complete SHA-256 literals: `76`.
- Complete 64-hex SHA-256 literal occurrences: `2,083`.
- Remediation-specific evidence files reviewed for current versus historical hash meaning: `48`.
- Complete SHA-256 literals in that remediation-specific set: `100`.

## Link validation

The scanner removed fenced code blocks and inline code spans, then inspected Markdown link syntax. It classified a remaining `[int](...)`-shaped PowerShell command expression whose destination begins with `$` as code, not an evidence link.

- Intended Markdown links: `0`.
- Missing intended local links: `0`.
- Code-expression false positives excluded: `1`.

Two preliminary syntax-insensitive scans reported three and then one false positives from PowerShell expressions embedded in historical command evidence. Neither result represented a repository link. The final syntax- and destination-aware scan exited `0`.

## Current integrity references

The validator resolved repository-root paths, feature-root `evidence/**` paths, and the exact current artifacts named by the remediation receipts. It calculated file SHA-256 values with `Get-FileHash -Algorithm SHA256`.

| Integrity group | Result |
|---|---|
| R4 post-normalization generated-file `After` rows | `22/22` current files match; `0` mismatches |
| Other unique current raw-file bindings | `12/12` match after the correction below; `0` mismatches |
| R5 executable-AST semantic digests | `3/3` match using the recorded docstring-stripping `ast.dump(..., include_attributes=False)` algorithm |
| P6-T1 line-count scope manifest | Producing-task acceptance evidence remains verified: 167/167 applicable paths, SHA-256 `49753A407AE1CB9AE616F8A1E52ED29CFAD9A5664A65BAE642EF146A43B8B322` |
| P4 semantic and report-data aggregates | Producing-task acceptance evidence remains verified: authored digest equality, generated non-whitespace equality, and 72/72 Istanbul display tuples |

The current raw-file group covers the R4 source receipt, current P2 Pester artifacts, current and prior-preserved Python coverage artifacts, the modified Python test owner, three unchanged R5 test owners, restored root `testResults.xml`, and the two historical-count source receipts named by the restoration evidence. Duplicate references to the same current files were reconciled to the same bytes.

The 100 remediation-specific literals were also classified by meaning. Values explicitly labeled baseline, prior, before-normalization, expected-red, diagnostic-stream, or transient focused-run values remain historical evidence and are not presented as hashes of the current mutable destination. Aggregate and semantic values were routed to their recorded producing algorithm and completed acceptance evidence. No historical value was rewritten as a current-state assertion.

## Corrected stale reference

The initial current-file comparison found one stale reference:

- Reference: `evidence/other/r4-whitespace-path-inventory.2026-08-13T15-38.md`.
- Target: `evidence/regression-testing/r4-full-diff-whitespace-red.2026-08-13T15-38.md`.
- Recorded pre-final-newline SHA-256: `B3D5ADB8DF931BA159B901F1D1C043F49C5DA5B766588F93E728C48E74E883EB`.
- Current SHA-256: `0CF6AD9AA671C53D9C9FACD0998F262FE160875725F18BE7BDEC53715AA4EF92`.

The inventory reference was updated to the current hash. A direct reread then reported recorded/current equality and exit `0`. No other current integrity reference was stale.

## Acceptance summary

- Canonical evidence-location validation: `PASS`.
- Missing intended evidence links: `0`.
- Stale current integrity references after correction: `0`.
- Historical integrity records preserved: `PASS`.

`P6_T3_STATUS: COMPLETE`
