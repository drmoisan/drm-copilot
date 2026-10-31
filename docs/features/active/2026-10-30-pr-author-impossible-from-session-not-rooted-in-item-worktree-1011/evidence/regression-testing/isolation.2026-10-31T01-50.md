# Seeded Shuffled Isolation Runs (Issue #1011, AC-17)

Timestamp: 2026-10-31T01-50
Command: sh SCRATCH/issue-1011-isolation.sh (PowerShell 7, one process per seed; file order shuffled by System.Random(seed); JUnit written under SCRATCH so the concurrent full run's artifacts/pester files are not touched)
EXIT_CODE: 0
Output Summary: three seeds, 132 passed and 0 failed in each.

Seed 11, file order:
1. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
2. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1
3. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
5. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
Result: Passed, passed=132 failed=0 skipped=0 notrun=0

Seed 23, file order:
1. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
2. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
3. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
5. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
Result: Passed, passed=132 failed=0 skipped=0 notrun=0

Seed 47, file order:
1. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
2. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1
3. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
5. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
Result: Passed, passed=132 failed=0 skipped=0 notrun=0
