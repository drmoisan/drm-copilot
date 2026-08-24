# Final QA Summary — Cycle 2 (CR-1), Issue #396

Timestamp: 2026-07-22T21-12

## Single-pass toolchain loop

The full shell toolchain loop (format -> lint/check -> test) completed in one clean pass with no restarts:

1. P4-T1 — `bash scripts/bash/shell-qc.sh format`: EXIT 0, no rewrites.
2. P4-T2 — `bash scripts/bash/shell-qc.sh check` (shfmt -d + shellcheck): EXIT 0, shfmt diff-clean, 0 shellcheck findings.
3. P4-T3 — coverage-enabled bats via CI dispatch of `_shell-coverage.yml` (run 29970805348): green, TAP `1..85`, 0 failures, overall line coverage 90.4%.

Restarts: none. (Type-check is not applicable to bash per `.claude/rules/shell.md`.)

## Phase 4 artifacts

- Format: `evidence/qa-gates/final-shell-format.2026-07-23T00-30.md`
- Check: `evidence/qa-gates/final-shell-check.2026-07-23T00-30.md`
- Coverage (CI): `evidence/qa-gates/final-shell-coverage-ci.2026-07-23T00-30.md`
- Pass-after regression: `evidence/regression-testing/cr1-hard-failure.pass-after.2026-07-23T00-30.md`
- Coverage delta: `evidence/qa-gates/coverage-delta.2026-07-23T00-30.md`
- File-size caps: `evidence/qa-gates/file-size-caps.2026-07-23T00-30.md`

Related earlier-phase artifacts: `evidence/regression-testing/cr1-hard-failure.fail-before.2026-07-23T00-30.md` (fail-before, run 29970355445), `evidence/other/split-shell-qc-check.2026-07-23T00-30.md` (P1), `evidence/other/fix-shell-qc-check.2026-07-23T00-30.md` (P3), and the Phase 0 baselines under `evidence/remediation-baseline/`.

## CR-1 closure

- Three fail-open call sites fixed with guarded parent-shell capture (`out=$(cmd) || rc=$?`, iterate over `<<<"$out"`): `git worktree list --porcelain` (in `parse_worktree_list`), `git cherry` (in `classify_cherry_equivalent`), and `git rev-list` (in `select_cherry_pick_candidates`). The consuming reads in `compute_protected`, `classify_branch` (x2), and `run_report` were converted to the same guarded pattern so the propagated exit code is not re-lost.
- Hard-error verdict mapping: a non-zero `git cherry` exit yields the internal `CHERRY_ERROR` token; every hard enumeration/cherry/rev-list failure maps to the `BRANCH|<name>|ANCESTRY_ERROR` report state (or a non-zero `run_report` return) and never to a `MERGED_*` verdict or a weakened protected set.
- Hard-failure regression tests: the 5 new tests (P2-T4..P2-T7) were red in the fail-before run and green in the pass-after run; all 80 pre-existing tests pass in both runs.
- Coverage non-regressed: overall 90.4% (baseline 89.0%); all in-scope files >= 85% line coverage.
- File-size cap preserved: `cleanup_worktrees_lib.sh` 411 lines after the Phase 1 pure-move split; all in-scope files <= 500.

Scope note: CR-2, CR-3, and CR-4 remain out of scope as findings; `scripts/bash/cleanup_worktrees_actions_lib.sh` was not modified.

Output Summary: CR-1 is closed. The single-pass QA loop is clean (format 0, check 0, CI test green 85/85, coverage 90.4%). The three fail-open call sites are fixed and verified by fail-before/pass-after CI evidence.
