# Additional Remediation Cycle 1 Acceptance-Criteria Inventory

Timestamp: `2026-08-15T00:41:53-04:00`

Plan task: `[P5-T22]`

The source hashes bind the complete criterion text, including continuation lines:

- `spec.md`: SHA-256 `2F6F96B9DFAD126D0052EF6DBE98B67322A74F6B2BECE034D2E855D68F50B849`
- `user-story.md`: SHA-256 `4FC607A52466B1B894CDE0D3BEDD2819039FD4475F63E826E418E69C89B30E32`

S-D13 and U19 changed from unchecked to checked only after the ordered four-language QA, preservation, parity, registration, destination, diff-hygiene, and zero-regression evidence passed. S-D14 and U20 remain unchecked and `FAIL` because PowerShell has zero branch counters and no genuine source-attributable branch denominator. S-D15 and U21 remain unchecked and `UNVERIFIED` because hosted CI has not run for the exact final published head. All other supported criteria retain their prior checked state.

## Exact 43-item inventory

| ID | Source | Line | State | Disposition |
|---|---|---:|---|---|
| S-D01 | `spec.md` | 298 | CHECKED | PASS; preserved |
| S-D02 | `spec.md` | 301 | CHECKED | PASS; preserved |
| S-D03 | `spec.md` | 304 | CHECKED | PASS; preserved |
| S-D04 | `spec.md` | 307 | CHECKED | PASS; preserved |
| S-D05 | `spec.md` | 310 | CHECKED | PASS; preserved |
| S-D06 | `spec.md` | 313 | CHECKED | PASS; preserved |
| S-D07 | `spec.md` | 316 | CHECKED | PASS; preserved |
| S-D08 | `spec.md` | 319 | CHECKED | PASS; preserved |
| S-D09 | `spec.md` | 321 | CHECKED | PASS; preserved |
| S-D10 | `spec.md` | 328 | CHECKED | PASS; preserved |
| S-D11 | `spec.md` | 331 | CHECKED | PASS; preserved |
| S-D12 | `spec.md` | 333 | CHECKED | PASS; preserved |
| S-D13 | `spec.md` | 335 | CHECKED | PASS; changed from unchecked after complete ordered QA evidence |
| S-D14 | `spec.md` | 339 | UNCHECKED | FAIL; `POWERSHELL_BRANCH_POLICY_UNRESOLVED` |
| S-D15 | `spec.md` | 344 | UNCHECKED | UNVERIFIED; exact-final-head hosted CI deferred |
| S-T01 | `spec.md` | 350 | CHECKED | PASS; preserved |
| S-T02 | `spec.md` | 353 | CHECKED | PASS; preserved |
| S-T03 | `spec.md` | 356 | CHECKED | PASS; preserved |
| S-T04 | `spec.md` | 359 | CHECKED | PASS; preserved |
| S-T05 | `spec.md` | 362 | CHECKED | PASS; preserved |
| S-T06 | `spec.md` | 365 | CHECKED | PASS; preserved |
| S-T07 | `spec.md` | 367 | CHECKED | PASS; preserved |
| U01 | `user-story.md` | 79 | CHECKED | PASS; preserved |
| U02 | `user-story.md` | 83 | CHECKED | PASS; preserved |
| U03 | `user-story.md` | 86 | CHECKED | PASS; preserved |
| U04 | `user-story.md` | 89 | CHECKED | PASS; preserved |
| U05 | `user-story.md` | 92 | CHECKED | PASS; preserved |
| U06 | `user-story.md` | 95 | CHECKED | PASS; preserved |
| U07 | `user-story.md` | 98 | CHECKED | PASS; preserved |
| U08 | `user-story.md` | 102 | CHECKED | PASS; preserved |
| U09 | `user-story.md` | 106 | CHECKED | PASS; preserved |
| U10 | `user-story.md` | 109 | CHECKED | PASS; preserved |
| U11 | `user-story.md` | 112 | CHECKED | PASS; preserved |
| U12 | `user-story.md` | 115 | CHECKED | PASS; preserved |
| U13 | `user-story.md` | 118 | CHECKED | PASS; preserved |
| U14 | `user-story.md` | 120 | CHECKED | PASS; preserved |
| U15 | `user-story.md` | 127 | CHECKED | PASS; preserved |
| U16 | `user-story.md` | 130 | CHECKED | PASS; preserved |
| U17 | `user-story.md` | 133 | CHECKED | PASS; preserved |
| U18 | `user-story.md` | 137 | CHECKED | PASS; preserved |
| U19 | `user-story.md` | 140 | CHECKED | PASS; changed from unchecked after complete ordered QA evidence |
| U20 | `user-story.md` | 144 | UNCHECKED | FAIL; `POWERSHELL_BRANCH_POLICY_UNRESOLVED` |
| U21 | `user-story.md` | 150 | UNCHECKED | UNVERIFIED; exact-final-head hosted CI deferred |

## Evidence and totals

- Ordered QA and numeric comparison: `evidence/qa-gates/remediation-final-comparison.2026-08-14T09-36.md`.
- QA index: `evidence/qa-gates/index.md`.
- Orchestration preservation: `evidence/qa-gates/cycle1-orchestration-preservation.2026-08-14T09-36.md`.
- Final scope, policy, dependency, suppression, evidence-location, and file-size receipts: `evidence/qa-gates/cycle1-final-*.2026-08-14T09-36.md`.
- `spec.md`: 22 total, 20 checked, 2 unchecked.
- `user-story.md`: 21 total, 19 checked, 2 unchecked.
- Combined: 43 total, 39 checked, 4 unchecked.
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`.
- Acceptance result: `REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`.
