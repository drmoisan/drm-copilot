# PowerShell Coverage Gate (issue #1165, reviewer run)

Timestamp: 2026-11-10T01-38
Command: from the item worktree root, pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; run by the feature-review agent to satisfy the validate-feature-review-coverage Stop hook (finding PA-2 of policy-audit.2026-11-10T01-15.md)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=631.76s; ExitCode=0; all 8 shards exited 0.
- Merged JUnit: tests=21311 failures=0 errors=0 skipped=10 (same counts as evidence/qa-gates/pester-gate.2026-11-10T00-54.md).
- artifacts/pester/powershell-coverage.xml written 2026-11-10T01:38:48Z, after the head commit eaf42f48d (2026-11-10T01:07:06Z); clean worktree.
- Repo-wide line coverage: 95.80% (covered 37557, missed 1646), identical to the 00:52Z run.
- .claude/hooks/bash-command-shape-guidance.ps1: 100.00% (65 of 65).
- .claude/hooks/validate-bash.ps1: 94.23% (98 covered, 6 missed: lines 320, 443, 445, 446, 447, 450; none changed by the branch).
- .claude/hooks/worktree-poetry-venv-policy.ps1 and .codex/hooks/worktree-poetry-venv-policy.ps1: 100.00% (117 of 117).
