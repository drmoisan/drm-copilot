# Fail-Before Exception Dossier (P1-T7 and P1-T8)

Timestamp: 2026-10-01T23:27:00-04:00
Command: bats --tap tests/shell/parallel_lane_assertion.bats ; bats --tap tests/shell/parallel_lane_assertion_parity.bats   (NOT RUN locally; deviation D4)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: a failing run before the fix cannot be produced in this worktree. Fail-before exception recorded for both suites; the CI job `shell-coverage` is the authority.

## Section 1: tests/shell/parallel_lane_assertion.bats (P1-T7, expect-fail)

WhyFailingRunImpossible: bats is not available for local execution in this worktree (`BATS: absent` in the P0-T3 artifact `evidence/baseline/tool-availability.2026-09-29T18-45.md`, and the operator rule Option A withholds the plan's bats and shell-entry invocations). A fail-first run of the six new cases against the unmodified library therefore cannot be recorded locally.

Absence proof: `command -v bats kcov shfmt shellcheck python3` printed paths for shfmt, shellcheck, and python3 only; no path for bats or kcov (P0-T3 artifact).

Alternative proof: from the plan's analysis of the unmodified library, cases (1), (3), (4), and (6) fail before the fix (newline, CR, CRLF-terminated, and mixed-separator values are truncated or not split by `read -ra`), while cases (2) tab and (5) undeclared-vertices pass as boundary guards. The Python lane output for the newline input is pinned locally (P1-T2 and P1-T6 artifacts: `Lane assertion: 1 derived conflict component(s); 0 disagreement(s).`). The bash-lane `2 derived` line (P1-T5) was not observed locally (operator-run blocker, deviation D5), so the divergence on the bash side is not independently reproduced by this worktree.

Authority: CI job `shell-coverage` (Shell Coverage (Bats + kcov)) runs the full bats suite on the post-fix head and is the pass-after source; fail-before is not required from CI.

## Section 2: tests/shell/parallel_lane_assertion_parity.bats (P1-T8, expect-fail)

WhyFailingRunImpossible: same as Section 1; additionally the parity harness needs both bats and the shell-entry invocation, and neither is run locally.

Absence proof: identical to Section 1 (P0-T3 artifact, `BATS: absent`; PYTHON3 is present but the harness cannot run without bats).

Alternative proof: the new corpus record `edges_newline_separated` is pinned to the Python authority output by the local pytest node `test_reference_reproduces_every_corpus_fixture[edges_newline_separated]` (1 passed; fixture-created and python-parity-control artifacts). The bats parity case `the bash lane reproduces every lane-assertion corpus fixture` is expected to report `not ok` against the unmodified library for that record and `ok` after the fix; neither state is observed locally.

Authority: CI job `shell-coverage` on the pushed head.
