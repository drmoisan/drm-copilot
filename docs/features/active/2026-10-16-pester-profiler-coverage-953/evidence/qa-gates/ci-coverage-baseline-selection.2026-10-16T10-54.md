# CI Coverage Baseline Selection (P7-T5)

Timestamp: 2026-10-16T10-54
Command: git fetch origin main ; git merge-base origin/main 2004de667b7e6c6930fcc065c0431b8457a60b7f ; git diff --name-only 072df404177564ff9f247fd422cce69bb6136ad6 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea -- .claude/hooks .claude/lib .codex/hooks .codex/scripts scripts ; git status --porcelain -- .claude/hooks .claude/lib .codex/hooks .codex/scripts scripts ; gh run list --workflow ci.yml --branch main --event push --json databaseId,headSha,conclusion --limit 100 ; gh run download 38885440106 -n poshqc-test-results -D "SCRATCH/issue-953-baseline-artifact-reselected"
EXIT_CODE: 0
Output Summary: Kept list (.ps1/.psm1, not .Tests.ps1) between the P0-T4 baseline head and the PR merge base is non-empty (13 files): .claude/hooks/enforce-epic-wave-barrier.ps1, .claude/hooks/subagentstop-envelope.ps1, .claude/hooks/validate-discovery-artifact-gate.ps1, .claude/hooks/validate-executor-output.ps1, .claude/hooks/validate-orchestrator-output.ps1, .claude/hooks/validate-planner-output.ps1, .claude/hooks/validate-pr-author-output.ps1, .claude/hooks/validate-prd-feature-output.ps1, .claude/hooks/validate-required-artifact-output.ps1, .claude/hooks/validate-task-researcher-output.ps1, scripts/dev-tools/HostBootstrap.psm1, scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1, scripts/dev-tools/Invoke-FullReleaseFlow.ps1. Authorized reselection branch applied: main push run 38885440106 has headSha equal to the merge base and conclusion success; its poshqc-test-results artifact was downloaded (powershell-coverage.xml SHA256 068b373c737dafb7d75a22d3c48d0718e6fd722d0da9be8f1c05ef648c599c2b).

PR_MERGE_BASE: 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea
WORKTREE_PORCELAIN: (empty)
COMPARISON_BASELINE_RUN_ID: 38885440106
