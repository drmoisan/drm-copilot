# Main-sync merge derivation (remediation cycle 1, [P0-T1])

Timestamp: 2026-11-14T07-05
Command: git fetch origin main; git rev-parse origin/main; git merge-base origin/main HEAD; git rev-parse <main-sync merge commit>^2; git merge-base --is-ancestor 2c8dee6dd3a82f210561d9efe623767ae902de51 HEAD; git diff --name-status 063504dc4b2ea08a2c5bd39b57d70ce5963815ed 2c8dee6dd3a82f210561d9efe623767ae902de51 -- .claude/hooks .codex/hooks .claude/lib .codex/lib tests
EXIT_CODE: 0
Output Summary: Main-sync merge commit 1083e7680 (subject `Merge remote-tracking branch 'origin/main' into feature/hook-dispatcher-process-cost-1159`) merged origin/main 2c8dee6dd3a82f210561d9efe623767ae902de51 (second parent). Previous merge base, from the `Merge` section of main-integration.2026-11-14T06-37.md: 063504dc4b2ea08a2c5bd39b57d70ce5963815ed. New merge base (git merge-base origin/main HEAD): 2c8dee6dd3a82f210561d9efe623767ae902de51, equal to origin/main after the fetch. Ancestry check exit 0. 52 changed paths between the two merge bases: 17 under .claude/hooks, .codex/hooks and .claude/lib, 35 under tests, none under .codex/lib. Every hook and module path named in the inputs `## Context` section is in the list. No inputs discrepancy for path membership. The inputs call `hook-docs-only-diff.ps1` "new, both runtimes", but it is modified (M) in both runtimes. That is a wording difference only.

## Merge bases
- Previous: 063504dc4b2ea08a2c5bd39b57d70ce5963815ed
- New: 2c8dee6dd3a82f210561d9efe623767ae902de51
- origin/main after fetch: 2c8dee6dd3a82f210561d9efe623767ae902de51 (no further movement)

## Changed paths between the merge bases (hooks, libs)
| Status | Path |
|---|---|
| M | .claude/hooks/enforce-docs-complete-gate.ps1 |
| A | .claude/hooks/enforce-model-routing-receipt-docs.ps1 |
| M | .claude/hooks/enforce-model-routing-receipt.ps1 |
| A | .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 |
| M | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 |
| A | .claude/hooks/hook-docs-estate-context.ps1 |
| M | .claude/hooks/hook-docs-only-diff.ps1 |
| M | .claude/lib/docs/DocsCompleteGate.psm1 |
| M | .claude/lib/docs/DocsLedgerCommands.psm1 |
| M | .claude/lib/docs/DocsProfileCommands.psm1 |
| A | .claude/lib/docs/DocsReceiptRevision.psm1 |
| A | .claude/lib/docs/DocsValidateCommands.psm1 |
| M | .claude/lib/docs/Invoke-DocsCommand.ps1 |
| A | .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 |
| M | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 |
| A | .codex/hooks/hook-docs-estate-context.ps1 |
| M | .codex/hooks/hook-docs-only-diff.ps1 |

## Changed paths between the merge bases (tests)
A tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1; A tests/scripts/claude-hooks/enforce-docs-complete-gate.ReceiptRevision.Tests.ps1; M tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1; M tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1; A tests/scripts/claude-hooks/enforce-model-routing-receipt.DocsEstate.Tests.ps1; A tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1; M tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1; A tests/scripts/claude-hooks/hook-docs-estate-context.Parity.Tests.ps1; A tests/scripts/claude-hooks/hook-docs-estate-context.Tests.ps1; A tests/scripts/claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1; M tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1; M tests/scripts/claude-lib/docs/Docs.TestSupport.psm1; M tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1; M tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1; M tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1; M tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1; M tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1; M tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1; M tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1; A tests/scripts/claude-lib/docs/DocsReceiptRevision.Properties.Tests.ps1; A tests/scripts/claude-lib/docs/DocsReceiptRevision.Tests.ps1; R061 tests/scripts/claude-lib/docs/DocsLedgerCommands.Validate.Tests.ps1 -> tests/scripts/claude-lib/docs/DocsValidateCommands.Tests.ps1; M tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1; M tests/scripts/claude-lib/docs/DocumentationEstateFixture.TestSupport.psm1; M tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1; M tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1; M tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1; M tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1; A tests/scripts/claude-runtime/documentation-workflow.CommitStage.Tests.ps1; A tests/scripts/claude-runtime/pr-author-docs-estate-delegation-contract.Tests.ps1; M tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1; A tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1; M tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1; M tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
