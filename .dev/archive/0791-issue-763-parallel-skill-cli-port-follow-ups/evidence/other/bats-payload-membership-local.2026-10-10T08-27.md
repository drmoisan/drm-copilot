# Bats Payload and Membership Suites (Local) — [P4-T13]

Timestamp: 2026-10-10T08-27
Command: npx --yes bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats (not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes
CI-DEFERRED-ACS: AC-11, AC-12
Reason: operator constraint prohibits local bats execution
Output Summary:
- The plan's authorized skip branch for [P4-T13] is taken under the operator constraint; no local bats process was started.
- `tests/shell/parallel_payload_only.bats` now holds 16 `@test` cases (two added: `the payload runs remove-parallel-item.sh without Python on PATH`, `the payload recolors unstarted items without Python on PATH`); `tests/shell/parallel_bash_manifest_membership.bats` holds 6 `@test` cases (entry-point case renamed to `the six CLI entry points are present in both trees`, `remove-parallel-item.sh` added). The expected CI TAP plan count for the two files is the [P0-T11] baseline count plus 2; the [P0-T11] baseline count is itself CI-deferred and is read from the same CI bats job log.
- Pre-CI check: the bundled `remove-parallel-item.sh` was run with `env -i PATH=<worktree>/tests/fixtures/parallel_payload_path /usr/bin/sh ...` for both added cases' argument vectors; both exited 0 and printed the expected literals.
- AC-11 and AC-12 are left for CI confirmation in [P9-T1].
