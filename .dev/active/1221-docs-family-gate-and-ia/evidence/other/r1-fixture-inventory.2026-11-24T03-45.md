# R1 Fixture Inventory (re-derivation on resume) - Issue #1221 (P1-T2)

Timestamp: 2026-11-24T03-45
Command: grep -rln "New-DocsStarterProfile" tests/ ; grep -rln "docs-complete" tests/ ; grep -rlnE "'init'|-Command init|docs-init|Invoke-DocsInitCommand" tests/ (union, sorted, unique)
EXIT_CODE: 0
Output Summary: 48 distinct paths at head 1326fb931 (after the integration-branch merge). Every path of `r1-fixture-inventory.2026-11-23T13-25.md` is still found, with the same disposition. Two paths are new since that inventory, and both are unchanged R1 fixtures (listed below). No fixture needs a family page, root file, or exclusion; no assertion was removed or weakened.

## Derivation

The derivation and drop rule are those of `r1-fixture-inventory.2026-11-23T13-25.md` (verbatim there). This file appends the resume re-run; the earlier inventory is not edited.

## Paths New Since the Earlier Inventory

| File | Disposition | Reason |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` | unchanged by P1-T2 | It is the helper itself (`New-DocsLedgerTestProfile`), updated by P1-T1; not a fixture. |
| `tests/scripts/claude-lib/docs/DocsValidation.Families.Tests.ps1` | unchanged by P1-T2 | The new P1-T4 test file; it declares families on purpose through `-RequiredFamily` and `-LegacyExclusion`. |

## Plan-Named Files (re-verified)

- `DocsCompleteIntegration.Tests.ps1`: only profile source `New-DocsLedgerTestProfile -AllowDeferred $false -MaxStalePages 0`; unchanged.
- `EndToEndDocumentationEstate.Tests.ps1`: profile from `Get-DocumentationEstateProfileText` (no `required_families`, no `legacy_exclusions`); unchanged.
- `docs-estate-workflow.EndToEnd.Tests.ps1`: no docs-complete validation run; unchanged.
- `DocsHashLineEnding.Tests.ps1`: docs-complete runs use `New-DocsLedgerTestProfile`; unchanged.
