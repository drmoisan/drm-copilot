# Feature Audit — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Head: `783df800710ab0b9ebf9ae0119521bd34c112838`
- Work mode: `minor-audit`
- AC source: `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/issue.md`,
  `## Acceptance Criteria` section, AC-1 through AC-7 (the sole AC source under
  `minor-audit`; `spec.md`/`user-story.md` are absent from this feature folder, which is
  expected and not a blocker under this work mode).
- Timestamp: 2026-09-25T15-48

## AC Evaluation

| AC | Requirement (paraphrased) | Verdict | Evidence |
|---|---|---|---|
| AC-1 | New `dirt_typechange_delta` scenario carries a `T` porcelain column and a bats test asserts its `DIRTFILE`/`DIRTSUM` verdict | **PASS** | Fixture directory confirmed to exist with the 10 files the plan specifies (`Glob` over the directory); `status._repo-wt_dirt.out` = `MT src/typechange.dat` (read directly); new test asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat` and `DIRTSUM|...|HAS_UNIQUE|`; recorded as `ok` on TAP line for test 274 in `final-shell-qc-test.2026-09-25T15-37.md`. |
| AC-2 | A negative control (mutate `[MARCTU]`→`[MARCU]` on a scratch copy) proves AC-1 can fail; production file byte-identical to `origin/main` afterward | **PASS** | Test at `test_cleanup_worktrees_dirt_classify.bats` (new, second of the pair) performs the mutation in-memory via `sed` into a shell variable, `eval`s it in a `bash -c` child, asserts the verdict flips to `CONTENT_ON_MAIN`/`ALL_DISPOSABLE`, then asserts `git diff origin/main -- "${DIRTLIB}"` and `git status --porcelain -- "${DIRTLIB}"` are both empty. Independently confirmed the single `[MARCTU]` occurrence (line 297) makes the substitution unambiguous. Recorded as `ok` (test 275) in the final-QC evidence. |
| AC-3 | Stub header no longer claims no index-writing arm exists; lists every such arm and its permitted callers | **PASS** | `tests/fixtures/cleanup_worktrees/stub-bin/git` header (lines 68-97) replaces the false claim with a per-arm table (`add`, `worktree add`, `worktree remove`, `cherry-pick`, `branch -D`, `reset --hard`, `clean -fd`) naming call sites and reachable modes; confirmed by direct read of the file. |
| AC-4 | Report-mode non-mutation assertion is an allowlist of read-only subcommands, or asserts `add`/`commit`/`write-tree`/`update-index` never appear | **PASS** | `test_cleanup_worktrees_dirt_clear.bats` lines 205-225 assert absence of `add`, `commit`, `update-index` (new) and `write-tree`, `hash-object -w`, `worktree remove`, `branch -D` (pre-existing); confirmed by direct read. Recorded `ok` (test 296) in final-QC evidence. |
| AC-5 | A negative control (inject a scratch `git add` into report mode) proves AC-4 can fail; production files byte-identical to `origin/main` afterward | **PASS** — with a documented interim regression, corrected on the branch before this audit | See "AC-5 detail" below. |
| AC-6 | Branch diff against `origin/main` changes no file under `scripts/` | **PASS** | Independently re-ran `git diff origin/main --name-status -- scripts/` and `git status --porcelain -- scripts/`: both empty. Matches `final-ac6-scripts-diff.2026-09-25T15-09.md`. |
| AC-7 | `shell-qc.sh check` and `shell-qc.sh test` both exit 0, each recorded as final-QC evidence | **PASS** | Check stage independently re-run: exit 0, no output. Test stage: recorded final evidence (`final-shell-qc-test.2026-09-25T15-37.md`) shows `EXIT_CODE: 0`, `1..463`, 463 `ok`, 0 `not ok`. This review's own attempt to re-run the full 463-test suite did not complete inside the session window (no failure observed, no completion observed); see "Independent verification limits" below. |

### AC-5 detail

The issue's own AC-5 text (`issue.md`) already documents an interim finding and its
resolution inline, marked `**RESOLVED**`. This audit independently corroborates that
account against the primary evidence rather than accepting the issue text at face value:

1. `final-shell-qc-test.2026-09-25T15-08.md` (an earlier final-QC run) recorded
   `EXIT_CODE: 1` with test 297 (`dirt_staged_tree_is_commit: injecting a git add call into
   run_report makes the widened non-mutation assertion fail (negative control)`) as
   `not ok`, and a detailed, correctly-diagnosed root cause: the injected line's
   `>/dev/null 2>&1` redirect silenced the stub's stderr argv-log echo, which is the same
   channel the test's own assertion reads, so the assertion could not pass regardless of
   the mutation's actual effect.
2. `remediation-inputs.2026-09-25T15-13.md` records this as "Finding 1 (Blocking — AC-5,
   AC-7)" and specifies the exact one-line fix (narrow the redirect to `>/dev/null`).
3. Commit `dd32bf0e` ("fix(660): correct P1-T6 negative-control redirect and pass full bats
   suite") applies that fix. Direct read of the current test body confirms the corrected
   redirect is in place.
4. `final-shell-qc-test.2026-09-25T15-37.md` records the re-run: `EXIT_CODE: 0`, test 297
   now `ok`.

This audit treats AC-5 as **PASS at HEAD**, on the same basis as the memory guidance for
grading "same commit"/interim-failure clauses: the interim `not ok` was a real, correctly
diagnosed and corrected defect in the plan's literal task text, not a fabricated or
glossed-over failure, and the corrected test's logic was independently re-read and confirmed
sound in this audit (see `code-review.2026-09-25T15-48.md`, AC-4/AC-5 section) — the fix
narrows the redirect from `2>&1` to nothing added on stderr, which is exactly what restores
the stub's argv-log visibility to the test's own assertion, and nothing else about the test
changed.

## Independent Verification Limits

This audit independently re-executed the check-stage toolchain command
(`sh scripts/bash/shell-qc.sh check`, exit 0, matching recorded evidence) and the AC-6
diff/status commands (both empty, matching recorded evidence) directly, rather than relying
solely on the branch's own recorded artifacts for those two gates.

The full bats suite re-run (`npx --yes bats tests/shell`) was attempted as an independent
check but did not complete within this session's available time budget (463 tests, many
spawning per-assertion `bash -c` subshells, running under git-bash on Windows). No failure
or error was observed from the attempt — it simply had not produced TAP output before this
audit needed to conclude. `npx --yes bats --version` was confirmed to resolve immediately in
the same environment, establishing the toolchain itself is reachable. In place of a completed
independent full-suite run, this audit performed a targeted, line-by-line trace of every
new/modified test's logic against the production stub and library source (documented in
`code-review.2026-09-25T15-48.md`) and relies on the branch's own `final-shell-qc-test.2026-09-25T15-37.md`
artifact for the full-suite pass/fail count, which names all three new tests' exact
description strings on `ok` lines.

## Acceptance Criteria Status

- Source: `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/issue.md`
- Total AC items: 7
- Checked off (delivered): 7 (AC-1 through AC-7, all already marked `[x]` in `issue.md`
  prior to this audit, by the plan's own executor)
- Remaining (unchecked): 0
- Items remaining: none

No AC item required a check-off change by this audit; all seven were already `[x]` in the
source file, and this audit's independent evidence supports all seven as PASS at HEAD.

## Overall Verdict

**PASS.** All seven acceptance criteria are met at HEAD, independently corroborated against
primary evidence (direct command re-runs, direct source reads, and direct fixture
inspection) rather than accepted from the issue/plan text alone. No Blocking finding was
identified. No remediation-inputs artifact is required from this audit.
