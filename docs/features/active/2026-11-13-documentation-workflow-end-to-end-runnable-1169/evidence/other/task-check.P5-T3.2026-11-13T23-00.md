# Task Check P5-T3

Timestamp: 2026-11-13T23-00
Command: sh SCRATCH/issue-1169-apply.sh docs; sh SCRATCH/issue-1169-tc.sh P5-T3 <files> <tests> (pwsh 7: Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-Pester); sh SCRATCH/issue-1169-pyglob.sh (push-down, Codex, and brief contract tests)
EXIT_CODE: 0
Output Summary:
- Changed files: the six docs-init/SKILL.md copies gain '## Linter Configuration' (the new locations, --config docs/documentation-estate/.vale.ini or VALE_CONFIG_PATH, the explicit markdownlint configuration, no workflow step runs the linters, and the policy-level note on the admitted workflow path); docs/engineering/documentation-estate/consumer-onboarding.md '## Linting' (the same statements; 'Linting is optional' and the check page-gate sentence kept); command-reference.md validate subsection (-Revision required unless -WriteReceipt is given, the snapshot-revision default, the rule against HEAD, and a -WriteReceipt example without -Revision); workflow.md '## Sequence' (step 7 names the Commit, Receipt and Pull Request stage), '## Receipt Persistence' (the -WriteReceipt form without -Revision), and '## Integration-PR Gate' (the receipt revision rule with RECEIPT_REVISION_NOT_ANCESTOR, RECEIPT_SOURCE_DRIFT, and RECEIPT_REVISION_UNRESOLVED).
- Tests: tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1 gains one per-copy docs-init row asserting the five tokens after whitespace normalization; tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 gains section-scoped normalized-statement checks and one in-memory negative row per page (token removed, no file written). Existing cases unchanged.
- Format and lint (two suites): 0 formatter differences, 0 analyzer findings.
- Selection rule: the contract tests that read the changed pages and skill copies.
- Pester: docs-authoring-roles.Skills.Tests.ps1, DocumentationEstateOnboarding.Tests.ps1, documentation-workflow.CommitStage.Tests.ps1: 177 passed, 0 failed; exit 0.
- pytest: 1634 passed; exit 0.
