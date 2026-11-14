# Stage R Cycle 3 Ledger Gates

Timestamp: 2026-11-07T20-31
Command: sh-launched PowerShell 7 scripts stored under SCRATCH, run from the worktree root (SCRATCH/c3/issue-1097-c3-ledger.sh): (a) SCRATCH/c3/issue-1097-c3-chain.ps1 (Test-ProcessReductionLedger over Read-ProcessReductionLedger; Invoke-ProcessReductionChain over Read-ProcessReductionChainInput); (b) git apply -R --check of docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch on the live tree; (c) SCRATCH/c3/issue-1097-c3-gate.ps1, the git-level chain gate of [P1-T10] in plan.2026-11-07T12-03.md rebuilt from that task's text and the Command field of the greatest stage-r-patch-chain-gate.*.md, with each patch entry's scratch index loaded from the FinalText of Invoke-ProcessReductionChain -StopBefore <entry> over all entries, and its attribution log run as git log --full-history --no-merges <0001 merge>..HEAD -- <path>; (d) SCRATCH/r/issue-1097-c2-steps.ps1 (Get-ProcessReductionSection of the 0001 entry for Revert Steps, searched for 000[2-6])
EXIT_CODE: 0
Output Summary:
  (a) Test-ProcessReductionLedger: valid, 0 errors. Chain over the merged ledger: 6 entries, 2 patches, 298 paths; IsValid True, 0 errors. -StopBefore 0001 and -StopBefore 0006: IsValid True, 0 errors each. Landings of 0001: #1096 (22 blocks), first (4 blocks).
  (b) git apply -R --check of the 0006 patch on the live tree: exit 0.
  (c) 0006 check (newer entries 0, later landings 0, sub-chain errors 0): git apply -R --cached --check exit 0. 0001 check (newer entries 5, 0006 to 0002; later landings 1, #1096; sub-chain errors 0): exit 0, which includes the end-of-file anchoring of the `## Test Isolation Checks` hunk in the six brief sections. Index loaded 237 paths, removed 11 absent paths; 50 generated-variant paths excluded per patch (100 total). Full chain IsValid True, 0 errors. End-state comparison with the first parent of the 0001 merge commit: equal 116, attributed 34, unattributed 0; skipped 142 derived paths and 6 ledger entry files.
  (d) The 0001 Revert Steps section (3905 characters) holds 0 matches of 000[2-6].
  Comparison with P0-T1 (equal 119, attributed 18, unattributed 0): unattributed 0 against 0. The 13 #1096 paths the chain now reverts join the comparison; 12 of them are attributed and 1 is equal; 4 earlier-equal paths are now attributed. Equal 119 - 4 + 1 = 116; attributed 18 + 16 = 34. Every count change is listed per path below. All four gates pass.

## Second Change to Gate (c): Complete Commit List for Attribution

The first run of gate (c), with the attribution log unchanged (git log <0001 merge>..HEAD -- <path>), reported equal 116, attributed 30, unattributed 4, gate exit 1. The four paths were `scripts/dev_tools/atomic_executor/cli_preflight.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, `scripts/dev_tools/atomic_executor/qc_toolchain.py`, and `scripts/dev_tools/fix_all_branches_extra.py`. Default history simplification follows one same-content parent at each merge. After this cycle's merge it walked only the PR #1112 side and listed only the `reduction: 0001` commit. A separate check showed, for each of the four paths, that the chain end state equals the file at the PR #1108 commit `fix(dev-tools): target scripts/dev_tools instead of a missing package (P3-T2)`, that the first parent of the 0001 merge equals the file just before that commit, and that this commit is the only token-free non-merge commit in the range that touches the path. The #1096 `Prior` fences hold `main` after PR #1108, as the 0001 entry states. The attribution log therefore gained `--full-history --no-merges`, so that it lists every non-merge commit that touched the path, including commits on merged side branches. The attribution test is unchanged: a difference still needs a token-free commit that touched the path, and merge-commit subjects are not counted.

## Count Changes per Path

#1096 paths now reverted by the chain (13):
- Attributed (12), each with a token-free commit that touched it:
  - `.vscode/tasks.json`: docs(policy): remove the stray lexile coverage path (P3-T1).
  - `scripts/dev_tools/atomic_executor/cli_preflight.py`, `prompt_builder.py`, `qc_runner.py`, `qc_toolchain.py`, and `scripts/dev_tools/fix_all_branches_extra.py`: fix(dev-tools): target scripts/dev_tools instead of a missing package (P3-T2), PR #1108.
  - `scripts/dev_tools/fix_all_branches.py`, `tests/scripts/dev_tools/test_fix_all_branches.py`, and `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`: feat(ci): run the Pester leak scan in CI, VS Code, and fix_all (#1096), the leak-scan part of that commit, which has no block.
  - `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` and `test_prompt_builder.py`: test(atomic-executor): cover preflight gating and prompt sections.
  - `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: test(dev-tools): move QCRunner filter helper tests to keep test_qc_runner.py under 700 lines.
- Equal (1): `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py`.

Earlier-equal paths that main changed outside any recorded region (4):
- `.claude/hooks/validate-feature-review-coverage-rules.ps1`: fix(hooks): resolve feature-review artifacts and coverage inputs against the item worktree [P2-T6], PR #1113.
- `.claude/hooks/validate-planner-output.ps1`: fix(hooks): reject parent segments beneath an item root in SubagentStop hooks (#1105) [P2-T2].
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`: test(hooks): add the item-resolution baseline mocks to the SubagentStop hook suites (#1105) [P1-T3].
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: docs(skills): state the Pester leak scan in the execution-environment brief (#1096), the assertions outside the 0001 hunks.

The 18 paths attributed at P0-T1 remain attributed. `.claude/skills/execution-environment/SKILL.md` now carries three token-free commits, the latest being the PR #1113 SubagentStop bullet.
