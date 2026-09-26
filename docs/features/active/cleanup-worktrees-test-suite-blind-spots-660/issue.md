# cleanup-worktrees-test-suite-blind-spots

- Work Mode: minor-audit
- Issue: #660
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/660
- Consolidates: #661 (closed 2026-09-09 as consolidated into #660). Same root cause and the same test-only blast radius.
- Lifecycle trail: `docs/features/potential/promoted/2026-09-08-dirt-classifier-typechange-member-unpinned.md` (#660, item 1) and `docs/features/potential/promoted/2026-09-08-cleanup-stub-header-contradicts-add-arm.md` (#661, item 2).
- Source: GitHub issue #660 body as of 2026-09-25; the acceptance criteria below are restated from its Expected Behavior and Proposed Fix sections.

## Problem / Why

Two blind spots in the cleanup-worktrees bats suite, both found by child #632's exit re-audit and the integration merge, both with the same root cause: the stub-driven fixture model pins behavior only where a checked-in scenario carries the case, and no scenario carries these two.

1. In `scripts/bash/cleanup_worktrees_dirt_lib.sh` the content-bearing porcelain-column class is `[MARCTU]`. The `T` (typechange) member is held by no assertion: mutating the class to `[MARCU]` leaves the full suite green. The shipped code is correct; the exposure is that a later edit could drop `T` unnoticed.
2. Child #637 added an `add)` arm to `tests/fixtures/cleanup_worktrees/stub-bin/git` for its preserve-staging path. It auto-merged outside every conflict region, so the stub's header statement that no arm writes to the index is now false, and the report-mode non-mutation assertion, which enumerates a fixed denylist with no `add` entry, is blind to a future regression that made report mode issue `git add`.

Severity: Low. Future regression exposure and one stale comment; no product behavior change.

## Implementation Intent

Test-only change. Blast radius: `tests/fixtures/cleanup_worktrees/stub-bin/git` (header comment), one new scenario directory under `tests/fixtures/cleanup_worktrees/scenarios/`, and the affected suites under `tests/shell/test_cleanup_worktrees_*.bats`. No production line changes. Both #632 and #637 own regions of the same stub; the stub header becomes the single description of which arms exist and which paths may call them.

## Acceptance Criteria

- [x] AC-1: A new scenario directory under `tests/fixtures/cleanup_worktrees/scenarios/` carries a porcelain status entry whose index or worktree column is `T` (typechange), and a bats test asserts that entry's `DIRTFILE|` verdict (content-bearing) and the worktree's `DIRTSUM|` summary.
- [x] AC-2: A negative control proves AC-1 can fail: with the class in `scripts/bash/cleanup_worktrees_dirt_lib.sh` mutated from `[MARCTU]` to `[MARCU]` on a scratch copy, at least one bats test fails; the mutation is reverted and the production file is byte-identical to `origin/main` afterwards. The failing run is recorded as evidence. **RESOLVED**: this round's remediation (P1-T3) removed a `git diff origin/main -- "${DIRTLIB}"` comparison from the negative-control test that CI's shallow checkout (no local `origin/main` ref, `actions/checkout@v7` with no `fetch-depth`) could not resolve, confirmed as CI's `not ok 275` failure in `remediation-inputs.2026-09-25T17-00.md`. The retained `git status --porcelain -- "${DIRTLIB}"` triple proves the same restoration property (mutated source evaluated only in a child process; production file never opened for writing) at any checkout depth. The corrected test now passes: `ok 275 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)`, recorded in `evidence/qa-gates/final-shell-qc-test.2026-09-25T16-48.md`. Production-file byte-identity to `origin/main` is additionally confirmed branch-wide (no path under `scripts/` changed) by `evidence/qa-gates/final-ac6-scripts-diff.2026-09-25T16-48.md`.
- [x] AC-3: The header block of `tests/fixtures/cleanup_worktrees/stub-bin/git` no longer states that no index-writing arm exists; it lists every arm that writes to the index or object database (including `add`) and the code paths permitted to call each one.
- [x] AC-4: The report-mode non-mutation assertion is either an allowlist of read-only git subcommands or asserts that `add`, `commit`, `write-tree`, and `update-index` never appear in the report-mode argv log.
- [x] AC-5: A negative control proves AC-4 can fail: with a scratch `git add` call injected into the report-mode path, the widened assertion fails; the injection is reverted and every production file is byte-identical to `origin/main` afterwards. The failing run is recorded as evidence. **RESOLVED**: the negative-control test required two independent corrections. The first fix (prior round) corrected the injected `cleanup_wt_git add -- test-negative-control >/dev/null || true` line, removing the `2>&1` redirect that had silenced the git stub's stderr echo, so the injected call's argv reaches `$output` and the widened assertion can fail as intended; that fix remains true and is not undone by this round. This round's remediation (P1-T6) removed a second, independent defect: a `git diff origin/main -- "${LIB}"` comparison that CI's shallow checkout (no local `origin/main` ref, `actions/checkout@v7` with no `fetch-depth`) could not resolve, confirmed as CI's `not ok 297` failure in `remediation-inputs.2026-09-25T17-00.md`. The retained `git status --porcelain -- "${LIB}"` triple proves the same restoration property at any checkout depth. The corrected test now passes: `ok 297 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)`, recorded in `evidence/qa-gates/final-shell-qc-test.2026-09-25T16-48.md`. Production-file byte-identity to `origin/main` is additionally confirmed branch-wide (no path under `scripts/` changed) by `evidence/qa-gates/final-ac6-scripts-diff.2026-09-25T16-48.md`.
- [x] AC-6: The branch diff against `origin/main` changes no production file: no path under `scripts/` is modified, added, or deleted.
- [x] AC-7: The repository shell toolchain passes on the branch: `scripts/bash/shell-qc.sh check` (format and lint; its discovery roots exclude `tests/`) and `scripts/bash/shell-qc.sh test` (the bats suites, which exercise the new scenario and the edited suites) both exit 0, with each run recorded as final-QC evidence. **RESOLVED**: this round's remediation (P1-T3, P1-T6) removed CI-incompatible `git diff origin/main` comparisons from two negative-control tests, which had caused CI failures under its shallow, `fetch-depth`-unset checkout (`not ok 275`, `not ok 297`, per `remediation-inputs.2026-09-25T17-00.md`) despite passing in a local worktree that already has `origin/main` from prior fetch history; the retained `git status --porcelain` triples in each test prove the same restoration property at any checkout depth. Post-remediation, the check-stage run exited 0 (clean), recorded at `evidence/qa-gates/final-shell-qc-check.2026-09-25T16-24.md`. The test-stage run exited 0 with `1..463`, 463 `ok` lines, and 0 `not ok` lines, recorded at `evidence/qa-gates/final-shell-qc-test.2026-09-25T16-48.md`.

## Dependencies / Risks

- The bats suites run under WSL bash or `npx --yes bats`; the executing agent's worktree may deny direct `bash` invocations, in which case the plan must name a runnable route and CI remains the confirming gate.
- The negative controls mutate production files on a scratch basis only; the plan must guarantee restoration and prove it with a diff anchored to `origin/main`.

## Verification Steps

- Run the cleanup-worktrees bats suites and record pass counts.
- Run each negative control and record the failing run.
- Manual verification note from the issue (informational, not an acceptance criterion): confirm on a real repository that `git status --porcelain` reports `T` for a file-to-symlink replacement on the platform in use.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
