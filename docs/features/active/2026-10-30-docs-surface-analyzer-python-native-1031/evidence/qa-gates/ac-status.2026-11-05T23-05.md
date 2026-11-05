# [P6-T19] Acceptance criteria status

Timestamp: 2026-11-05T23-05
Command: line-addressed `sed` replacement of `- [ ] ` with `- [x] ` on the verified criteria of `FEATURE/spec.md` and `FEATURE/user-story.md` (`## Acceptance Criteria` only), followed by a normalized comparison against `HEAD` (checkbox markers masked)
EXIT_CODE: 0
Output Summary: 19 of 22 criteria checked in each source. S9/U9, S10/U10 and S22/U22 remain unchecked as pending-CI. Criterion text is unchanged in both files (the masked comparison is byte-identical), and the Definition of Done and Seeded Test Conditions lists were not touched.

Numbering: S1 to S22 and U1 to U22 in document order, as the plan preamble defines.

## Check-off basis (plan `## Acceptance Criteria Traceability`)

| AC | Status | Evidence (all report 0 failed or the stated observation) |
|---|---|---|
| S1, U1 | checked | `p3-corpus` (4 passed), `p4-parity` (21 passed, 105 shared rows), [P6-T13] shuffled runs |
| S2, U2 | checked | `p2-*` (argparse 8, click 12, typer 21, cli 6, routes 17, public-api 7, architecture 3 passed), `p3-corpus`, `native-corpus-census` (57 rows) |
| S3, U3 | checked | `p4-inventory` (32 passed) |
| S4, U4 | checked | `p4-protocol` (26), `p4-interpreter` (14), `p4-inventory` (32) passed |
| S5, U5 | checked | `p4-native-inventory` (20 passed) |
| S6, U6 | checked | `p4-inventory` (32 passed) |
| S7, U7 | checked | `p3-safety` (5 passed) |
| S8, U8 | checked | `manifests`, `p5-existing-pester` (162 passed), `p5-push-down-contracts` (34 passed) |
| S9, U9 | unchecked (pending-CI) | Mapped to [P6-T5], [P6-T9] and [P6-T10]. [P6-T9] (single-process Pester with coverage) remains unchecked pending `poshqc / PowerShell QC`. The local run carries pre-existing failures unrelated to this branch. The recorded figures (`qa-python-per-file-coverage`, `coverage-delta.2026-11-04T20-43`) meet the thresholds, but the criterion depends on the pending Pester run. |
| S10, U10 | unchecked (pending-CI) | pending `quality-checks7 / Code Quality & Tests (3.11)`, `(3.12)` and `(3.13)` (3.11 floor) |
| S11, U11 | checked | `p4-native-inventory`, `p4-inventory` (envelope and snapshot schema checks) |
| S12, U12 | checked | `p3-safety`, `p4-protocol`, `p4-parity` token check |
| S13, U13 | checked | `p4-registry` (58 passed; registry numstat 4 added, 0 deleted) |
| S14, U14 | checked | `bundle-mirror`, `p5-push-down-contracts`; on the current head, 17 of 17 source/mirror SHA-256 pairs are equal (re-verified 2026-11-05) |
| S15, U15 | checked | `qa-bytecode.2026-11-04T20-01` (empty listings), `p4-interpreter` argument-list case |
| S16, U16 | checked | `p4-interpreter`, `qa-test-hygiene.2026-11-05T23-01` |
| S17, U17 | checked | `p4-guard` (89 passed) |
| S18, U18 | checked | `p5-packaging` (14 passed) |
| S19, U19 | checked | `qa-test-hygiene.2026-11-05T23-01` (token search empty; no decision for any new file or any branch-added content; the two guard files' whole-file decision is pre-existing at `MERGE_BASE`) |
| S20, U20 | checked | `p3-determinism` (3 passed), `p3-protocol` (31 passed) |
| S21, U21 | checked | `qa-tiers-and-size.2026-11-05T22-58` (all 18 files below 500, tier check exit 0), `p5-existing-pester` (`ClaudeLibModuleConvention.Tests.ps1`) |
| S22, U22 | unchecked (pending-CI) | pending `poshqc / PowerShell QC` and `quality-checks7 / Code Quality & Tests (3.11)` to `(3.13)` on the pull request head |

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md`
- Total AC items: 22
- Checked off (delivered): 19
- Remaining (unchecked): 3
- Items remaining: S9 (E5 per-file Python and Pester coverage; depends on pending-CI [P6-T9]), S10 (E5, R: Black, Ruff, Pyright and the 3.11 floor verified by the CI matrix), S22 (CI-dependent: `poshqc / PowerShell QC` and the `quality-checks` Python jobs on the pull request head)

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/user-story.md`
- Total AC items: 22
- Checked off (delivered): 19
- Remaining (unchecked): 3
- Items remaining: U9 (E5 per-file coverage; depends on pending-CI [P6-T9]), U10 (E5: Black, Ruff, Pyright and the 3.11 floor verified by the CI matrix), U22 (CI-dependent: `poshqc / PowerShell QC` and the Python quality jobs on the pull request head)
