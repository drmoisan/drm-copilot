# F2 specification edit record ([P2-T5])

Timestamp: 2026-11-04T14-59
Command: sh SCRATCH/issue-1033-sections.sh (PowerShell 7: SHA-256 over each section text, from its `## ` heading up to the next `## ` heading, in `git show CYCLE_HEAD:FEATURE/spec.md` and in the working `FEATURE/spec.md`; `git diff CYCLE_HEAD -- FEATURE/user-story.md`)
EXIT_CODE: 0
Output Summary: all three section digest pairs are equal; the `user-story.md` diff against `CYCLE_HEAD` is empty (0 lines). Acceptance-criteria text and checkbox state are unchanged.

## Section digests

| Section | CYCLE_HEAD | Working | Equal |
|---|---|---|---|
| `## Acceptance Criteria` | `2c9a51137d6313189dad046465624961a89b1dd4ccaafc75ff2a888dbfa7e1d1` | `2c9a51137d6313189dad046465624961a89b1dd4ccaafc75ff2a888dbfa7e1d1` | yes |
| `## Definition of Done` | `869b03817b919425f96b6139b6d36f84cc350334aecdb36a5882d518fda9d0c0` | `869b03817b919425f96b6139b6d36f84cc350334aecdb36a5882d518fda9d0c0` | yes |
| `## Seeded Test Conditions (from potential)` | `93a5d5b26480640f33353913c1b07a5f6a2921464b1e0c076601a0ff3a8eaefc` | `93a5d5b26480640f33353913c1b07a5f6a2921464b1e0c076601a0ff3a8eaefc` | yes |

## Edited regions (the plan's record of the F2 edit)

1. [P2-T1] `## Recognition Rules`: new first subsection `### Diagnostic code spelling (C7)`, stating that a hyphenated code named in the specification is the code's specification name and is emitted in its mapped form (every letter uppercased, every `-` replaced with `_`, grammar `^[A-Z][A-Z0-9_]*$`), with the examples `http-dynamic-route` -> `HTTP_DYNAMIC_ROUTE` and `extension-finding-skipped` -> `EXTENSION_FINDING_SKIPPED`, the `Get-DocsScannerPrecisionLimit` `code` column, and the reference to `evidence/other/contract-reconciliation.2026-11-03T21-46.md` `## C7 adopted code spellings`. Token check: `### Diagnostic code spelling (C7)` occurs once; it lies between `## Recognition Rules` and `### Declaration strings (1020 per-kind convention)`.
2. [P2-T2] `## Scanner Precision Limit`: the first paragraph now states that each code is emitted in its mapped uppercase-underscore form and names `### Diagnostic code spelling (C7)`; "emitted at most once per `(analyzer_id, code, path)`" and the rest of the paragraph are kept; table rows and code lists are unchanged.
3. [P2-T3] `## Contract Dependencies on 1020 and 1022`, row C7: default column rewritten to the merged 1020 grammar (`New-DocsDiagnostic`, `schemas/docs/v1/common.schema.json`, `^[A-Z][A-Z0-9_]*$`), the mapped form, and the reconciliation record. Rows C1 to C6 and C8 to C10 unchanged.
4. [P2-T4] `## Decisions Later Children Must Honor`, diagnostic-code bullet: uppercase words joined by `_` matching `^[A-Z][A-Z0-9_]*$`, the mapping rule, the kept stability sentence, and the shared codes `INPUT_OVER_BOUND`, `INPUT_UNDECODABLE`, `DECLARATION_INVALID`, `DUPLICATE_DECLARATION`.

Token counts after the edit: `A-Z0-9_` occurs in 3 lines (subsection, C7 row, decisions bullet); case-insensitive `lowercase` occurs in 2 lines (the `lowercase hex` sentence of `## Inputs / Outputs` and the `Get-DocsDeclarationSha256` row), down from 5.

## Checkbox state check ([P5-T8], appended 2026-11-04T15-33)

Command: sh SCRATCH/issue-1033-sections.sh (counts of `- [x]` and `- [ ]` lines in `git show CYCLE_HEAD:<file>` and in the working file); EXIT_CODE: 0.

| File | CYCLE_HEAD `[x]` / `[ ]` | Working `[x]` / `[ ]` | Equal |
|---|---|---|---|
| `FEATURE/spec.md` | 21 / 11 | 21 / 11 | yes |
| `FEATURE/user-story.md` | 11 / 1 | 11 / 1 | yes |

The CI-dependent criteria remain unchecked: S22 (`spec.md` `## Acceptance Criteria`, the `(CI-dependent)` item) and U12 (`user-story.md`, the `(CI-dependent)` item). No other checkbox changed.
