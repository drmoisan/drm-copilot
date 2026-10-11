# Final QC — Bats Suites (Local)

Timestamp: 2026-10-10T08-41
Task: [P8-T9] (Phase 8 loop pass 1)
Command: npx --yes bats tests/shell/parallel_mutation_remove.bats tests/shell/parallel_mutation_remove_parity.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats (not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes
CI-DEFERRED-ACS: AC-8, AC-9, AC-10, AC-11, AC-12
Reason: operator constraint prohibits local bats execution
Output Summary:
- The plan's authorized bats-cannot-start-equivalent branch is taken under the operator constraint; no local bats process was started, so no TAP plan line or `not ok` line exists locally.
- [P4-T12] pre-check applied: `command -v python3` exit 0, printing the project virtual-environment `python3` under `.venv/Scripts/`; `PARALLEL_PARITY_PYTHON` would therefore not be set. The parity-interpreter branch is not taken.
- The four suites are verified from the CI bats job log on the pull request (the CI shell-qc test job runs every `tests/shell/*.bats` file).
- AC-8, AC-9, AC-10, AC-11, and AC-12 are left for CI confirmation in [P9-T1].
