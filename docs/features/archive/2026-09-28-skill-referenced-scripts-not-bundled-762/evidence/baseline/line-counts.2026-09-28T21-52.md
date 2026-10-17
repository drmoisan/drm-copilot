# Pre-Change Line Counts (P0-T9)

Timestamp: 2026-09-28T21-52
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 scripts/ba?h/cleanup* .claude/skills/cleanup-merged-worktrees/SKILL.md tests/shell/test_cleanup_worktrees_*.bats tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats scripts/ba?h/shell_qc_lib.sh scripts/orchestration/Invoke-CiGateParser.ps1 tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary: 36 `LineCount=` lines (10 scripts, 1 skill text, 19 cleanup suites, 2 shell QC suites, shell QC library, parser, parser suite, runsettings). Largest production file: cleanup_worktrees_lib.sh at 496 lines. SKILL.md (571) is Markdown documentation and exempt from the 500-line limit.

```text
scripts/bash/cleanup_worktrees_actions_lib.sh LineCount=451
scripts/bash/cleanup_worktrees_detached_lib.sh LineCount=301
scripts/bash/cleanup_worktrees_dirt_lib.sh LineCount=495
scripts/bash/cleanup_worktrees_enumerate_lib.sh LineCount=252
scripts/bash/cleanup_worktrees_lib.sh LineCount=496
scripts/bash/cleanup_worktrees_preserve_eol_lib.sh LineCount=212
scripts/bash/cleanup_worktrees_preserve_lib.sh LineCount=492
scripts/bash/cleanup_worktrees_report_records_lib.sh LineCount=476
scripts/bash/cleanup_worktrees_scan_helper.sh LineCount=182
scripts/bash/cleanup-worktrees.sh LineCount=234
.claude/skills/cleanup-merged-worktrees/SKILL.md LineCount=571
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
tests/shell/test_shell_qc_discovery.bats LineCount=92
tests/shell/test_shell_qc_commands.bats LineCount=168
scripts/bash/shell_qc_lib.sh LineCount=379
scripts/orchestration/Invoke-CiGateParser.ps1 LineCount=330
tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 LineCount=205
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=330
```
