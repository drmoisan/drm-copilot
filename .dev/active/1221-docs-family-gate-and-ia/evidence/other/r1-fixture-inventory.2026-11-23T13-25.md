# R1 Fixture Inventory - Issue #1221 (P1-T2)

Timestamp: 2026-11-23T13-25
Command: grep -rln "New-DocsStarterProfile" tests/ ; grep -rln "docs-complete" tests/ ; grep -rlnE "'init'|-Command init|docs-init|Invoke-DocsInitCommand" tests/ ; per-file classification grep (docs-complete mode token, validate invocation, New-DocsLedgerTestProfile use, starter or init use)
EXIT_CODE: 0
Output Summary: 36 distinct files found by the three searches. No end-to-end docs-complete fixture builds a family-declaring profile outside New-DocsLedgerTestProfile, so no fixture needed a family page, root file, or exclusion. Every file is listed below with its disposition; all are unchanged.

## Derivation (verbatim)

1. `grep -rln "New-DocsStarterProfile" tests/`
2. `grep -rln "docs-complete" tests/`
3. `grep -rlnE "'init'|-Command init|docs-init|Invoke-DocsInitCommand" tests/`
4. Drop rule (plan P1-T2): drop a file whose only profile source is `New-DocsLedgerTestProfile` (covered by P1-T1, which now returns empty `required_families` and `legacy_exclusions`) and a file that runs no docs-complete validation (no `validate -Mode docs-complete` and no `Invoke-DocsValidation` call in docs-complete mode).

## Plan-Named Files

| File | Disposition | Reason |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1` | unchanged | Its only profile source is `New-DocsLedgerTestProfile -AllowDeferred $false -MaxStalePages 0`; after P1-T1 that profile declares no families, so the family check adds no finding and every pass assertion holds. |
| `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | unchanged | Runs `validate -Mode docs-complete` over `Get-DocumentationEstateProfileText` (`DocumentationEstateFixture.TestSupport.psm1`), a literal profile JSON that declares no `required_families` and no `legacy_exclusions`; it is not built from `New-DocsStarterProfile` or `docs-init`, so the family check adds no finding. |
| `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1` | unchanged | Runs no docs-complete validation: it composes hook legs over a hand-written receipt text (`validation_result` `pass`) and a minimal literal profile; the docs-complete gate reads that receipt only. |
| `tests/scripts/claude-lib/docs/DocsHashLineEnding.Tests.ps1` | unchanged | Its docs-complete runs use `New-DocsLedgerTestProfile`; its other profile source, the committed `examples/docs/v1/docs-profile.example.json`, declares no families and feeds only `surface-delta`. |

## Every Other File Found

| File | Disposition | Reason |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsValidation.Tests.ps1` | unchanged | Profile source is `New-DocsLedgerTestProfile` only. |
| `tests/scripts/claude-lib/docs/DocsValidation.Properties.Tests.ps1` | unchanged | Profile source is `New-DocsLedgerTestProfile` only. |
| `tests/scripts/claude-lib/docs/DocsValidateCommands.Tests.ps1` | unchanged | Profile source is `New-DocsLedgerTestProfile` only. |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1` | unchanged | Runs no docs-complete validation (argument-validator properties only). |
| `tests/scripts/claude-lib/docs/DocsReceipt.Tests.ps1` | unchanged | Calls `New-DocsValidationReceipt` directly; no profile and no validation run. |
| `tests/scripts/claude-lib/docs/DocsReceipt.Properties.Tests.ps1` | unchanged | Calls `New-DocsValidationReceipt` directly; no profile and no validation run. |
| `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1` | unchanged | Gate over hand-written receipt texts; no validation run. |
| `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` | unchanged | Asserts workflow template text only; no validation run. |
| `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | unchanged | Uses `New-DocsStarterProfile` for inventory only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsInventory.PythonNative.Tests.ps1` | unchanged | Inventory only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | unchanged | Inventory only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | unchanged | Inventory only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1` | unchanged | Profile loader tests; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.InventoryParity.Tests.ps1` | unchanged | Inventory parity only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1` | unchanged | Matches the init search only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` | unchanged | Matches the init search only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | unchanged | Runs `init`; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | unchanged | Matches the init search only; no docs-complete validation. |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | unchanged | Runs `init` and other commands; no docs-complete validation. |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | unchanged | Mentions docs-complete in hook text only; no validation run. |
| `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1` | unchanged | Text contract only. |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | unchanged | Hook over hand-written receipts; no validation run. |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.ReceiptRevision.Tests.ps1` | unchanged | Hook over hand-written receipts; no validation run. |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1` | unchanged | Hook command parsing only. |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1` | unchanged | Hook target resolution only. |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.DocsEstate.Tests.ps1` | unchanged | Hook leg over hand-written receipts; no validation run. |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | unchanged | Mentions docs-complete in hook names only. |
| `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Claude.ps1` | unchanged | Corpus text only. |
| `tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1` | unchanged | Text only. |
| `tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1` | unchanged | Text only. |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` | unchanged | Matches the init search only (workflow path); no validation run. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1` | unchanged | Matches the init search only; no validation run. |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` | unchanged | Matches the init search only; no validation run. |
| `tests/scripts/claude-hooks/hook-docs-estate-context.Tests.ps1` | unchanged | Matches the init search only; no validation run. |
| `tests/scripts/claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1` | unchanged | Matches the init search only; no validation run. |
| `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` | unchanged | Matches the init search only; no validation run. |
| `tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.WorkflowText.Tests.ps1`, `DocsAuthoringRoles.Helpers.ps1` | unchanged | Skill text only; no validation run. |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` | unchanged | Matches the init search only; no validation run. |

## Conclusion

No fixture is updated, so no pass assertion is removed or weakened. The R1 risk is fully absorbed by P1-T1. The task check for this inventory runs the four plan-named files (and the remaining `New-DocsLedgerTestProfile` users) after the family check lands, in the P1-T4 and P1-T5 task checks and in the P1-T6 phase gate, which names the R1 fixtures.
