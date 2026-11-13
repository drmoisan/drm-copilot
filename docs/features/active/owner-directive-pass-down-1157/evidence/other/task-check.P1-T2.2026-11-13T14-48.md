# Task check P1-T2 (issue #1157, cycle 1)

Timestamp: 2026-11-13T14-48
Command: sh SCRATCH/issue-1157-static.sh -File .claude/hooks/enforce-owner-directive-pass-down.ps1; sh SCRATCH/issue-1157-taskcheck.sh -Path tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1; sh SCRATCH/issue-1157-taskcheck.sh -Path <the four other suites below>; sh SCRATCH/issue-1157-pytest-sel.sh tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py; sha256sum of the hook and its bundle copy
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/hooks/enforce-owner-directive-pass-down.ps1 (ledger branch of Get-OwnerDirectivePassDownDecision: [string]::Equals and EndsWith with OrdinalIgnoreCase) and its byte copy extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-owner-directive-pass-down.ps1.
- Selection rule: the mirrored suite tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1, every test file that names the changed file (cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, claude-runtime/owner-directive-pass-down.Registration.Tests.ps1, claude-runtime/owner-directives-skill-contract.Tests.ps1), and the bundle contract test that reads the bundled copy.
- Format: drift 0 (EXIT_CODE 0). Lint: 0 findings (EXIT_CODE 0). Type check: not applicable.
- enforce-owner-directive-pass-down.Tests.ps1: 83 passed, 0 failed (EXIT_CODE 0), including both P1-T1 case-variant rows and every ledger guard (AC-27) row.
- Four naming suites: 330 passed, 0 failed (EXIT_CODE 0).
- test_push_down_claude_resource_contracts.py: 14 passed (EXIT_CODE 0).
- SHA-256 hook: 3ba3a12b2d4820172748bd7cbfd98bc0968c06526616be51fdcdfc652e19091e; bundle copy: 3ba3a12b2d4820172748bd7cbfd98bc0968c06526616be51fdcdfc652e19091e (equal).
