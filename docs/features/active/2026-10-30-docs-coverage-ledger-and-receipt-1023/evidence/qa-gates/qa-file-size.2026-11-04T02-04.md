# Final QA: File Size ([P7-T9])

Timestamp: 2026-11-04T02-04
Command: sh SCRATCH/issue-1023-line-count.sh (wc -l over every file this feature created or edited under .claude/lib/docs, extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs and tests/scripts/claude-lib/docs, listed by git diff --name-only MERGE_BASE HEAD and git status --porcelain); then sh SCRATCH/issue-1023-pester-run.sh tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (Invoke-PoshQCTest -ScanFolders over that suite alone; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: 48 files counted; largest 785 (DocsLedgerCommands.psm1 and its bundle copy); no file exceeds 800. Above the 700 advisory tier: DocsLedgerCommands.psm1 (785, non-blocking Warning; reason recorded below). Above the 500 guidance tier: DocsLedger.psm1 533, DocsParity.psm1 545, DocsLedger.TestSupport.psm1 538, DocsLedgerCommands.Tests.ps1 536, DocsLedgerCommands.UpdateLedger.Tests.ps1 651 (reasons below). FileSizePolicy.RepoGate.Tests.ps1: tests=5 failures=0 errors=0 (JUnit root tests=5 errors=0 failures=0). config/file-size-baseline.json is unchanged.

## Logical line counts (production: LIB and BUNDLE)

| File | Lines | Tier |
|---|---|---|
| `DocsCoverageReport.psm1` | 163 | below 500 |
| `DocsEvidencePins.psm1` | 285 | below 500 |
| `DocsLedger.psm1` | 533 | guidance (500) |
| `DocsLedgerCommands.psm1` | 785 | advisory (700), non-blocking Warning |
| `DocsLedgerMutation.psm1` | 168 | below 500 |
| `DocsLedgerRules.psm1` | 265 | below 500 |
| `DocsParity.psm1` | 545 | guidance (500) |
| `DocsReceipt.psm1` | 299 | below 500 |
| `DocsStaleness.psm1` | 150 | below 500 |
| `DocsValidation.psm1` | 367 | below 500 |
| `Invoke-DocsCommand.ps1` | 465 | below 500 |

Each bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` has the same count as its source (byte-identical).

## Logical line counts (tests under TESTS)

| File | Lines |
|---|---|
| `DocsCompleteIntegration.Tests.ps1` | 181 |
| `DocsCoverageReport.Properties.Tests.ps1` | 105 |
| `DocsCoverageReport.Tests.ps1` | 154 |
| `DocsEvidencePins.Properties.Tests.ps1` | 195 |
| `DocsEvidencePins.Tests.ps1` | 197 |
| `DocsLedger.Properties.Tests.ps1` | 307 |
| `DocsLedger.TestSupport.Tests.ps1` | 179 |
| `DocsLedger.TestSupport.psm1` | 538 |
| `DocsLedger.Tests.ps1` | 361 |
| `DocsLedgerCommands.Properties.Tests.ps1` | 109 |
| `DocsLedgerCommands.Tests.ps1` | 536 |
| `DocsLedgerCommands.UpdateLedger.Tests.ps1` | 651 |
| `DocsLedgerCommands.Validate.Tests.ps1` | 343 |
| `DocsLedgerMutation.Properties.Tests.ps1` | 65 |
| `DocsLedgerMutation.Tests.ps1` | 194 |
| `DocsLedgerRules.Properties.Tests.ps1` | 114 |
| `DocsLedgerRules.Tests.ps1` | 296 |
| `DocsParity.Properties.Tests.ps1` | 329 |
| `DocsParity.Tests.ps1` | 373 |
| `DocsReceipt.Properties.Tests.ps1` | 191 |
| `DocsReceipt.Tests.ps1` | 291 |
| `DocsStaleness.Properties.Tests.ps1` | 124 |
| `DocsStaleness.Tests.ps1` | 153 |
| `DocsValidation.Properties.Tests.ps1` | 171 |
| `DocsValidation.Tests.ps1` | 492 |
| `DocsWriteBoundary.Tests.ps1` | 201 |

## Splits applied and recorded reasons

- `DocsLedgerCommands.psm1` (785, advisory tier): the pre-approved `DocsCoverageReport.psm1` split was applied in [P4-T3]; the plan pre-approves no further split of this module and `## Artifact Classification` lists no other module, so the remaining size (the three command functions, the operation dispatcher and the shared input loader) is recorded as the advisory reason, as in `regression-testing/p4-update-ledger-pins`. Below the 800 hard limit; no line was added in Phases 6-7.
- `DocsLedger.psm1` (533, guidance tier): the pre-approved `DocsLedgerRules.psm1` split was applied in [P1-T3], moving the ledger rules out; the remaining module holds the snapshot view, the precision-limit derivation, the entry and document constructors and the three merge/removal operations.
- `DocsParity.psm1` (545, guidance tier): no split is pre-approved; the glob matcher, owner lookup, row and document constructors, scoring, matrix rules and the four merge/removal operations form one artifact-kind module. No gate fails at this tier.
- `DocsLedger.TestSupport.psm1` (538), `DocsLedgerCommands.Tests.ps1` (536), `DocsLedgerCommands.UpdateLedger.Tests.ps1` (651): test files at the guidance tier; the command suites are already the three-file family of `## Design Notes`. No gate fails at this tier.

## Repository gate

`tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 5 tests, 0 failures, 0 errors (4.218 s). No file above 800 lines outside `config/file-size-baseline.json`, which this feature does not edit.
