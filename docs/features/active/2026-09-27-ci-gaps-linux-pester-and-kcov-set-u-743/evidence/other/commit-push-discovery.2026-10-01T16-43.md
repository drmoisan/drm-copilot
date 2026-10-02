# Commit and Push for Discovery (P4-T1)

Timestamp: 2026-10-01T16-43
Deviation: D12 (this commit is also the Phase 3 boundary commit).

Command: git add -- .github/workflows/_poshqc.yml tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 scripts/bash/kcov_trace_env.sh scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_commands.bats tests/fixtures/shell_qc/kcov_trace/ tests/fixtures/shell_qc/stub-bin/bats-nounset-source tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/
EXIT_CODE: 0
Output Summary: staged; no gate refusal.

Command: git commit -F <session-scratchpad>/msg-p4t1.txt -- (same paths)
EXIT_CODE: 0
Output Summary: commit 90b6bd4a, 4 files changed (the workflow and three evidence files; the other Phase 1 and Phase 2 files were committed at their own phase boundaries, 10d71c99 and 0285440a).

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: CI_SHA_1 = 90b6bd4a8646f0a510509c839e9daec77dff69d1

Command: git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: `0285440a..90b6bd4a`; no force.

Command: git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: `90b6bd4a8646f0a510509c839e9daec77dff69d1`, equal to CI_SHA_1.
