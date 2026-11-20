# Line Counts of Changed Files (P7-T13, AC-22)

Timestamp: 2026-10-01T17-25
Command: wc -l .github/workflows/_poshqc.yml scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh tests/shell/test_shell_qc_commands.bats tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh tests/fixtures/shell_qc/stub-bin/bats-nounset-source tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
EXIT_CODE: 0
Output Summary: every listed file is at most 500 lines (largest: epic-child-worktree-launcher.Tests.ps1 at 495). The SKILL.md copies are Markdown and exempt.

| File | Lines |
| --- | --- |
| .github/workflows/_poshqc.yml | 90 |
| scripts/bash/shell_qc_lib.sh | 394 |
| scripts/bash/kcov_trace_env.sh | 9 |
| tests/shell/test_shell_qc_commands.bats | 203 |
| tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh | 6 |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source | 11 |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset | 12 |
| tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | 95 |
| tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | 469 |
| tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | 495 |
| tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | 258 |
