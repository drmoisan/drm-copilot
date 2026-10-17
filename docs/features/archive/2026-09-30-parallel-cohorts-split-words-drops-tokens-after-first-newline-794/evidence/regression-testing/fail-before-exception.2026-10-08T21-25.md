# Fail-before exception dossier (P1-T6)

Timestamp: 2026-10-09T07-03
Command: (none run; BATS flag is absent, so `bats --tap tests/shell/parallel_cohorts.bats` was not attempted)
EXIT_CODE: 0
Output Summary: local bats fail-before cannot run because bats is not installed in this worktree; the authoritative fail-before is the pair of P1-T9 and P1-T10 CI artifacts.

WhyFailingRunImpossible: bats is not installed in this worktree (BATS: absent in tool-availability.2026-10-08T21-25.md; `command -v bats` printed no path).

Absence proof: evidence/baseline/tool-availability.2026-10-08T21-25.md records `BATS: absent`. Local `sh scripts/bash/shell-qc.sh test` prints `bats not installed; skipping shell tests.` (baseline-shell-test-local.2026-10-08T21-25.md).

Alternative proof: repro-before-keys (stdout `[[1]]`, truncated), repro-before-edges (stdout `[[1,3],[2]]`, dropped edge), and repro-before-combined (exit 1, false membership error) artifacts in this folder show the defects the new rows assert.

Authoritative fail-before: the P1-T9 and P1-T10 CI artifacts (ci-fail-first-run and ci-fail-first-lines).
