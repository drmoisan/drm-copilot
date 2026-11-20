# Isolation Runs (Issue #1011, Remediation Cycle 1, P4-T5)

Timestamp: 2026-10-31T04-48
Command: sh SCRATCH/issue-1011-r1-isolation.sh (for each seed, one PowerShell 7 process runs SCRATCH/issue-1011-pester-targeted.ps1 over the five suites in a System.Random(seed) shuffled file order, coverage off, JUnit to SCRATCH/issue-1011-r1-isolation-<seed>.xml; SCRATCH/issue-1011-r1-junit-read.ps1 reads each JUnit file)
EXIT_CODE: 0
Output Summary: seeds 13, 31, and 59 each passed 135 tests with 0 failures and 0 errors.

## Seed 13
File order:
1. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1
2. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
3. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
5. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1

JUnit: tests=135, failures=0, errors=0.

## Seed 31
File order:
1. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
2. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1
3. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
5. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1

JUnit: tests=135, failures=0, errors=0.

## Seed 59
File order:
1. tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
2. tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
3. tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
4. tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
5. tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1

JUnit: tests=135, failures=0, errors=0.

The fresh single-process run over `tests/scripts` is P4-T4 (`pester-full-r1`).
