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
- [x] AC-2: A negative control proves AC-1 can fail: with the class in `scripts/bash/cleanup_worktrees_dirt_lib.sh` mutated from `[MARCTU]` to `[MARCU]` on a scratch copy, at least one bats test fails; the mutation is reverted and the production file is byte-identical to `origin/main` afterwards. The failing run is recorded as evidence.
- [x] AC-3: The header block of `tests/fixtures/cleanup_worktrees/stub-bin/git` no longer states that no index-writing arm exists; it lists every arm that writes to the index or object database (including `add`) and the code paths permitted to call each one.
- [x] AC-4: The report-mode non-mutation assertion is either an allowlist of read-only git subcommands or asserts that `add`, `commit`, `write-tree`, and `update-index` never appear in the report-mode argv log.
- [ ] AC-5: A negative control proves AC-4 can fail: with a scratch `git add` call injected into the report-mode path, the widened assertion fails; the injection is reverted and every production file is byte-identical to `origin/main` afterwards. The failing run is recorded as evidence. **BLOCKED**: the inserted negative-control test (P1-T6) fails for the wrong reason — its injected `cleanup_wt_git add ... >/dev/null 2>&1 || true` line (specified verbatim by the plan) silences the git stub's stderr echo, so the test's own `[[ "$log" == *" add "* ]]` assertion can never observe the injected call. See `evidence/qa-gates/final-shell-qc-test.2026-09-25T15-08.md` for the root-cause finding. Requires a plan revision before this AC can be verified.
- [x] AC-6: The branch diff against `origin/main` changes no production file: no path under `scripts/` is modified, added, or deleted.
- [ ] AC-7: The repository shell toolchain passes on the branch: `scripts/bash/shell-qc.sh check` (format and lint; its discovery roots exclude `tests/`) and `scripts/bash/shell-qc.sh test` (the bats suites, which exercise the new scenario and the edited suites) both exit 0, with each run recorded as final-QC evidence. **BLOCKED**: the check-stage run exited 0 (clean); the test-stage run exited 1 because of the single AC-5 test failure above.

## Dependencies / Risks

- The bats suites run under WSL bash or `npx --yes bats`; the executing agent's worktree may deny direct `bash` invocations, in which case the plan must name a runnable route and CI remains the confirming gate.
- The negative controls mutate production files on a scratch basis only; the plan must guarantee restoration and prove it with a diff anchored to `origin/main`.

## Verification Steps

- Run the cleanup-worktrees bats suites and record pass counts.
- Run each negative control and record the failing run.
- Manual verification note from the issue (informational, not an acceptance criterion): confirm on a real repository that `git status --porcelain` reports `T` for a file-to-symlink replacement on the platform in use.

## Evidence Checklist
- [x] baseline
- [ ] targeted verification
- [ ] end-state
