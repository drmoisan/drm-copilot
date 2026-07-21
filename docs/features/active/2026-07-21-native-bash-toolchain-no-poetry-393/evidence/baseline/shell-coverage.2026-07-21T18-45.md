# Baseline — Existing shell-qc test --coverage (bash line coverage) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run shell-qc test --coverage
EXIT_CODE: NOT-EXECUTED (kcov unavailable locally; see note)

Note: kcov is not installed on this Windows host (would be exit 127 locally), and the old
Poetry entry point is not executed by the executor. Per the plan's authorized fallback
(P0-T9), the numeric bash line-coverage baseline is obtained from a green `_shell-coverage.yml`
run. That run is produced/observed at P5-T9 (AC9) against the branch head; the executor does
not push branches (staging/commit/push are the orchestrator's responsibility).

Bash coverage (lines) baseline: DEFERRED to P5-T9 CI run (authorized fallback chain:
local kcov -> cited green `_shell-coverage.yml` run URL). The value will be recorded in
`evidence/qa-gates/ci-green-run.<ts>.md` and reconciled in
`evidence/qa-gates/coverage-delta.<ts>.md`.

Output Summary: Local kcov absent; numeric baseline deferred to the CI coverage run (AC2/AC9).
The coverage-run behavior contract is captured from
`scripts/dev_tools/shell_qc.py::run_test_with_options` (lines 389-435) and reproduced by
`run_test_coverage` in the bash library.
