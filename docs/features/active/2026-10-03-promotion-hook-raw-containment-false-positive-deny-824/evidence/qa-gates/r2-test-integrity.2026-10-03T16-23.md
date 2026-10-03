# r2 P7-T5 test integrity

Timestamp: 2026-10-03T16-23
Command: step script SCRATCH/steps/r2-p7-t5.ps1 (git diff --numstat bda1982bcb9048a22efe9ba124a2b53516e9e3c1 and git status --porcelain --untracked-files=all over the test trees; expected deleted-line table; NAMED, BAD-DELETES, SET-DIFFERENCES; VERDICT)
EXIT_CODE: 0
Output Summary: NAMED=13 BAD-DELETES=0 SET-DIFFERENCES=0. The numstat lists exactly the nine edited test files with the D5 deleted counts (S1 and S2 0; S3, S3X, S6, S7, S8 2; U1 and U2 7), and the status lists the four new test-tree files (BATS, FIXTURE, GT, WT) as untracked.

```text
75	2	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
75	2	tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
21	0	tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
2	2	tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
39	7	tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1
63	2	tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
21	0	tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
2	2	tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
39	7	tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1
?? tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt
?? tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1
?? tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1
?? tests/shell/test_codex_web_setup_codex_copy.bats
NAMED=13 BAD-DELETES=0 SET-DIFFERENCES=0
```
