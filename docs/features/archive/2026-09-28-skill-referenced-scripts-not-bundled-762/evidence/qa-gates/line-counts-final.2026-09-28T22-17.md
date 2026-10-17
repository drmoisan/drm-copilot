# File-Size Limit Check (P9-T6)

Timestamp: 2026-09-28T22-17
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <six P9-T1 Python files> .claude/skills/cleanup-merged-worktrees/scripts/*.sh scripts/ba?h/shell_qc_lib.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats tests/shell/test_cleanup_worktrees_*.bats .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/*.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary: Every `LineCount=` value is at most 500 (the largest is 496, `cleanup_worktrees_lib.sh`). Each relocated or path-edited file's count equals its P0-T9 value, matched by basename: the ten moved scripts, the 19 cleanup suites, the shell QC library (379), the parser (330), and the parser suite (205). The three planned exceptions differ: `test_shell_qc_discovery.bats` 92 to 99 (+7, per B9), `test_shell_qc_commands.bats` 168 to 169 (+1, per B10), and `pester.runsettings.psd1` 330 to 335 (+5, per B11). The remaining files are new: the six Python files and `CiGate.Manifest.Tests.ps1` (39).

Loop restart recorded: the first run of this check reported `scripts/dev_tools/skill_bundle_contract.py LineCount=510`, which exceeds the limit. The module docstring was condensed with no code change, bringing the file to 495 lines. The Python loop was re-run from P9-T1: black printed `6 files left unchanged.`, ruff printed `All checks passed!`, pyright reported `0 errors` on the six files and both trees, and P9-T4 gave 42 passed with 96.45/95.00 and 92.98/77.27. P9-T5 gave the KL-510 case (b) failure only, with 93.11/85.92. The P6-T1 guard passed 5 of 5 inside P9-T4, and the P6-T3 sweep printed `SWEEP-EXIT=1`.

```text
scripts/dev_tools/skill_bundle_contract.py LineCount=495
scripts/dev_tools/skill_bundle_contract_cli.py LineCount=219
tests/scripts/dev_tools/test_skill_bundle_contract.py LineCount=282
tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py LineCount=268
tests/scripts/dev_tools/test_skill_bundle_contract_cli.py LineCount=152
tests/scripts/dev_tools/test_skill_bundle_contract_repo.py LineCount=117
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh LineCount=451
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh LineCount=301
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh LineCount=495
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh LineCount=252
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh LineCount=496
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh LineCount=212
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh LineCount=492
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh LineCount=476
.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh LineCount=182
.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh LineCount=234
scripts/bash/shell_qc_lib.sh LineCount=379
tests/shell/test_shell_qc_discovery.bats LineCount=99
tests/shell/test_shell_qc_commands.bats LineCount=169
tests/shell/test_cleanup_worktrees_classification.bats LineCount=273
tests/shell/test_cleanup_worktrees_cli.bats LineCount=150
tests/shell/test_cleanup_worktrees_consolidation.bats LineCount=79
tests/shell/test_cleanup_worktrees_deletion.bats LineCount=203
tests/shell/test_cleanup_worktrees_detached.bats LineCount=329
tests/shell/test_cleanup_worktrees_dirt_classify.bats LineCount=422
tests/shell/test_cleanup_worktrees_dirt_clear.bats LineCount=335
tests/shell/test_cleanup_worktrees_dirt_content_locations.bats LineCount=208
tests/shell/test_cleanup_worktrees_dirt_failclosed.bats LineCount=283
tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats LineCount=437
tests/shell/test_cleanup_worktrees_dirt_regression.bats LineCount=143
tests/shell/test_cleanup_worktrees_enumeration.bats LineCount=142
tests/shell/test_cleanup_worktrees_hard_failures.bats LineCount=182
tests/shell/test_cleanup_worktrees_preserve.bats LineCount=471
tests/shell/test_cleanup_worktrees_preserve_eol.bats LineCount=175
tests/shell/test_cleanup_worktrees_preserve_failures.bats LineCount=264
tests/shell/test_cleanup_worktrees_report_records.bats LineCount=132
tests/shell/test_cleanup_worktrees_scan_helper.bats LineCount=101
tests/shell/test_cleanup_worktrees_scan_seam.bats LineCount=28
.claude/lib/ci-gate/Invoke-CiGateParser.ps1 LineCount=330
tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 LineCount=39
tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 LineCount=205
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=335
```
