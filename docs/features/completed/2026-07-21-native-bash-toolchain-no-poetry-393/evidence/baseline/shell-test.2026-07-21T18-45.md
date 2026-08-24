# Baseline — Existing shell-qc test (parity reference) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run shell-qc test
EXIT_CODE: NOT-EXECUTED (see note)

Note: The old Poetry entry point is not executed by the executor (Python/Poetry surface being
removed). bats is not installed on this Windows host and is not on the executor Bash
allowlist. Parity captured from `scripts/dev_tools/shell_qc.py::run_test_with_options`
(lines 344-387, non-coverage path).

Behavior contract (to be reproduced by `run_test` in the bash library):
- Test dirs: `tests/shell` then `tests/bash`, existing only, in that order.
- No test dir: print "No shell test directories found; skipping." and return 0.
- bats missing (non-coverage): print "bats not installed; skipping shell tests." and return 0.
- Non-coverage: `bats <dir>` once per test dir; run all dirs; return max exit.

Output Summary: In the current repo, `tests/shell` exists (contains 4 .bats files), so the
non-coverage run would invoke `bats tests/shell`. Actual pass/fail is a runtime property of
bats, deferred to CI (AC8/AC9). The byte-identical skip markers are recorded in
`skip-marker-contract.2026-07-21T18-45.md`.
