# Contract and Size Baseline (P0-T3)

Timestamp: 2026-11-23T07-51
Command: (1) env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (through SCRATCH/issue-1219-suite-retry.sh, which re-runs after a launcher exit 75); (2) pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check (through SCRATCH/issue-1219-harness-check.sh); (3) @(Get-Content -LiteralPath <path>).Count per file (logical lines, through SCRATCH/issue-1219-linecount.sh)
EXIT_CODE: 0
Output Summary:
- Step 1 pytest suite: EXIT_CODE 0 on attempt 7 (2026-11-23T07-48 to 2026-11-23T07-50); attempts 1-6 (2026-11-23T07-39 to 2026-11-23T07-48) were launcher exit 75 queue timeouts and are recorded as queue timeouts, not failures. Result: 17104 passed, 6 skipped, 0 failed (pytest -n auto, 72.67 s). Python coverage: N/A (no Python production file is in scope).
- Step 2 Invoke-HarnessGeneration.ps1 -Check: EXIT_CODE 0; output `harness-generation: no drift`.
- Step 3 logical line counts (EXIT_CODE 0):
  - .claude/lib/docs/DocsLedgerCommands.psm1: 758 (matches the expected 758)
  - .claude/lib/docs/DocsProfileCommands.psm1: 270
  - tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1: 553
  - tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1: 181
  - tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1: 351
  - tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1: 216
  - tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1: 116
  - tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1: 305
