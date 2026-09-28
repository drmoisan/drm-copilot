# Remediation Inputs — #660 — 2026-09-25T17-00

## Source

CI failure on PR #698 (https://github.com/drmoisan/drm-copilot/pull/698), head SHA
`8a81f90352945a421ffc78c0a7d50543b39791ef`, required check `shell-coverage / Shell Coverage
(Bats + kcov)`, workflow run
https://github.com/drmoisan/drm-copilot/actions/runs/36157710856, failing job
https://github.com/drmoisan/drm-copilot/actions/runs/36157710856/job/108146248367. 15 of 16
required checks passed; this one failed. Independently confirmed via `gh pr checks 698` and
`gh run view --job 108146248367 --log-failed`.

## Finding (Blocking) — both new negative-control tests call `git diff origin/main`, which does not exist under the workflow's default shallow checkout

Two `not ok` results in the failing job's bats output:

- `not ok 275 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away
  from UNIQUE (negative control)` — fails at `tests/shell/test_cleanup_worktrees_dirt_classify.bats:239`
  (`[ "$status" -eq 0 ]` immediately after `run git -C "${REPO_ROOT}" diff origin/main --
  "${DIRTLIB}"` at line 238).
- `not ok 297 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the
  widened non-mutation assertion fail (negative control)` — fails at
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats:251` (`[ "$status" -eq 0 ]` immediately
  after `run git -C "${REPO_ROOT}" diff origin/main -- "${LIB}"` at line 250).

Everything before that line in each test passed on the CI (Linux) runner, including the real
negative-control assertions: test 275's `CONTENT_ON_MAIN`/`ALL_DISPOSABLE`/no-`UNIQUE` checks
(current `test_cleanup_worktrees_dirt_classify.bats` lines 232-235) and test 297's
`[[ "$log" == *" add "* ]]` (current `test_cleanup_worktrees_dirt_clear.bats` line 247). The
P1-T6 fix (the stderr-redirect correction) is confirmed working on Linux CI by this same run.

**Root cause, independently verified:** `.github/workflows/_shell-coverage.yml` line 14 uses
`actions/checkout@v7` with no `fetch-depth` argument, so the action's default depth-1
(shallow) checkout applies. A depth-1 checkout of a pull-request merge ref fetches only that
single commit; it does not create a local `origin/main` ref. `git -C "${REPO_ROOT}" diff
origin/main -- <file>` therefore fails with an unresolvable revision and a non-zero exit,
which the test observes as `[ "$status" -eq 0 ]` failing. On a developer machine `origin/main`
already exists from prior `git fetch`/`clone` history, which is why both tests pass locally
(confirmed on this branch by two independent local Windows bats runs, both `ok` at 275/297).
Confirmed no `fetch-depth` override anywhere in `_shell-coverage.yml`; confirmed via `grep -n
"checkout@\|fetch-depth"` that no other checkout step in that file sets it either.

**Scope confirmation:** `grep -rn "origin/main" tests/shell/` shows exactly three matches:
the two `git diff origin/main` calls above, and one unrelated pre-existing test name string
(`test_cleanup_worktrees_enumeration.bats:98`, `"check_main_freshness emits nothing when main
matches origin/main"` — this test passed in the same CI run as test 344, `ok`, and does not
invoke real git). No other test in this branch's diff references `origin/main`.

## Requested plan revision

Revise `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md`
(same canonical plan file) so P1-T3's and P1-T6's quoted test text drops the
`run git -C "${REPO_ROOT}" diff origin/main -- <lib>` / `[ "$status" -eq 0 ]` / `[ -z
"$output" ]` triple in each test, keeping the following `run git -C "${REPO_ROOT}" status
--porcelain -- <lib>` / `[ "$status" -eq 0 ]` / `[ -z "$output" ]` triple unchanged. The
`git status --porcelain` guard alone proves the intended property (the mutated source was
composed in-memory and evaluated in a child process; the production file on disk was never
opened for writing) without needing any remote ref, because it compares the working tree
against the local index/HEAD, which is available under any checkout depth. AC-2's and AC-5's
"production file byte-identical to origin/main afterward" requirement remains structurally
guaranteed on this branch independent of this test (no commit on this branch ever touches a
production file — the same fact AC-6/P2-T3 verifies branch-wide), so removing the redundant
remote-ref comparison from these two tests does not weaken what the acceptance criteria
actually require.

Do not add `fetch-depth` to `.github/workflows/_shell-coverage.yml` or any other workflow
file — that would be an out-of-scope, unrequested production/CI-config change on a test-only
minor-audit branch, and per `.claude/skills/orchestrate/SKILL.md` ("The orchestrator must not
commit workflow-file changes outside the remediation loop" / `modified-workflow-needs-green-run`)
a workflow-file edit carries its own gating obligations this branch does not need to take on.

## Re-execution scope after revision

Only the two affected `@test` bodies need editing (in place, not re-inserted) in
`tests/shell/test_cleanup_worktrees_dirt_classify.bats` and
`tests/shell/test_cleanup_worktrees_dirt_clear.bats`. No other task, file, or AC is in scope.
Re-run the full bats suite locally as a sanity check (expected: still all-`ok`, since the
removed lines were passing locally already), commit, push, and let CI re-run — CI is the only
route that can confirm the shallow-checkout-dependent fix, per `.claude/rules/shell.md`
("CI versions are canonical. When local and CI results disagree, defer to CI.").
