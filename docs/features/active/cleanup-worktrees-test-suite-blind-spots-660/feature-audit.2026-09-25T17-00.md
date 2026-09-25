# Feature Audit — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Head: `15aa71138bedbeb577906dd8ab05d92e0d08f30b`
- Work mode: `minor-audit`
- AC source: `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/issue.md`,
  `## Acceptance Criteria` section, AC-1 through AC-7 (the sole AC source under
  `minor-audit`; `spec.md`/`user-story.md` are absent from this feature folder, expected and
  not a blocker under this work mode).
- Timestamp: 2026-09-25T17-00
- Review cycle: remediation-cycle re-audit, cycle 1 of the R1-R5 loop. The prior audit
  (`feature-audit.2026-09-25T15-48.md`, head `783df800...`) found PASS on all 7 AC. This
  audit independently re-evaluates all 7 AC at the current HEAD, because one commit
  (`15aa7113`) landed since that audit in direct response to a CI failure on the required
  `shell-coverage` check, and a re-audit that only re-confirmed the delta would not itself
  verify the CI failure is actually resolved.

## AC Evaluation

| AC | Requirement (paraphrased) | Verdict | Evidence |
|---|---|---|---|
| AC-1 | New `dirt_typechange_delta` scenario carries a `T` porcelain column and a bats test asserts its `DIRTFILE`/`DIRTSUM` verdict | **PASS** | Unaffected by this round's fix. Re-confirmed at HEAD: fixture directory still carries the 10 files the plan specifies; `status._repo-wt_dirt.out` = `MT src/typechange.dat` (read directly); test asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat` and `DIRTSUM|...|HAS_UNIQUE|`. Recorded `ok 274` in `evidence/qa-gates/final-shell-qc-test.2026-09-25T16-48.md`, and independently confirmed via CI job log for run `36163252436`/job `108164730498` (`1..463`, 0 `not ok`). |
| AC-2 | A negative control (mutate `[MARCTU]`→`[MARCU]` on a scratch copy) proves AC-1 can fail; production file byte-identical to `origin/main` afterward | **PASS** | The negative control still performs the mutation in-memory via `sed` into a shell variable, `eval`s it in a `bash -c` child, and asserts the verdict flips to `CONTENT_ON_MAIN`/`ALL_DISPOSABLE`. This round's fix (`15aa7113`) removed a `git diff origin/main -- "${DIRTLIB}"` triple that CI's shallow checkout could not resolve; the retained `git status --porcelain -- "${DIRTLIB}"` triple, re-read directly at HEAD, still proves the same non-mutation property using only locally-resolvable state. Recorded `ok 275` in both `final-shell-qc-test.2026-09-25T16-48.md` (local) and CI's job log for run `36163252436` (the environment the original defect depended on). |
| AC-3 | Stub header no longer claims no index-writing arm exists; lists every such arm and its permitted callers | **PASS** | Unaffected by this round's fix. `tests/fixtures/cleanup_worktrees/stub-bin/git` header (lines 68-97) still carries the per-arm table (`add`, `worktree add`, `worktree remove`, `cherry-pick`, `branch -D`, `reset --hard`, `clean -fd`) naming call sites and reachable modes; re-confirmed by direct read at HEAD. |
| AC-4 | Report-mode non-mutation assertion is an allowlist of read-only subcommands, or asserts `add`/`commit`/`write-tree`/`update-index` never appear | **PASS** | Unaffected by this round's fix. `test_cleanup_worktrees_dirt_clear.bats` lines 205-225 still assert absence of `add`, `commit`, `update-index`, `write-tree`, `hash-object -w`, `worktree remove`, `branch -D`; re-confirmed by direct read at HEAD. |
| AC-5 | A negative control (inject a scratch `git add` into report mode) proves AC-4 can fail; production files byte-identical to `origin/main` afterward | **PASS** | See "AC-5 detail" below — this AC is the other half of this round's fix. |
| AC-6 | Branch diff against `origin/main` changes no file under `scripts/` | **PASS** | Independently re-ran `git diff --name-status 26d57cb3..15aa7113 -- scripts/` and `git status --porcelain -- scripts/` at HEAD: both empty. Matches `evidence/qa-gates/final-ac6-scripts-diff.2026-09-25T16-48.md`, which post-dates this round's fix commit. |
| AC-7 | `shell-qc.sh check` and `shell-qc.sh test` both exit 0, each recorded as final-QC evidence, **and** the CI required check that surfaced a shallow-checkout failure now passes | **PASS** | See "AC-7 detail" below — this is the specific gate the task context identified as needing re-verification. |

### AC-5 detail

This round's fix commit (`15aa7113`) removed a `run git -C "${REPO_ROOT}" diff origin/main
-- "${LIB}"` triple from the negative-control test at
`test_cleanup_worktrees_dirt_clear.bats`. This audit independently verified the fix does not
weaken AC-5's substance:

1. The removed triple was diagnosed by `remediation-inputs.2026-09-25T17-00.md` as failing
   only under CI's shallow (depth-1, `fetch-depth`-unset) checkout, which does not create a
   local `origin/main` ref — confirmed by this audit's direct read of
   `.github/workflows/_shell-coverage.yml` line 14 (`actions/checkout@v7`, no
   `fetch-depth`).
2. The test's actual negative-control assertion — `[[ "$log" == *" add "* ]]`, proving the
   widened AC-4 assertion would fail if `run_report` regressed to calling `add` — is
   unaffected by the fix; it was already passing on CI before this fix (per
   `remediation-inputs.2026-09-25T17-00.md`: "Everything before that line in each test
   passed on the CI (Linux) runner, including the real negative-control assertions").
3. The retained `git status --porcelain -- "${LIB}"` triple, re-read directly at HEAD, still
   proves the production file was never opened for writing, using only locally-resolvable
   state (working tree vs. local index/HEAD), which the removed remote-ref comparison did
   not add anything beyond for this property.
4. AC-5's "production files byte-identical to `origin/main` afterward" clause is additionally
   and independently guaranteed branch-wide by AC-6 (verified above): no commit on this
   branch ever touches a `scripts/` file, so the property holds structurally regardless of
   which of the two triples any single test asserts.
5. CI's job log for run `36163252436` (this audit's own independent inspection via
   `gh run view --job 108164730498 --log`) confirms `ok 297` at the position matching this
   test's description string, with zero `not ok` lines in the full 463-test run.

This audit treats AC-5 as **PASS at HEAD**, confirmed by direct read of the corrected test
body and by an independent CI run against this exact commit.

### AC-7 detail

AC-7 is the acceptance criterion the task context specifically flagged as needing
re-verification: the prior review round found PASS on AC-7 based on local evidence, but a
subsequent CI run of PR #698 (at that round's HEAD) failed the required
`shell-coverage / Shell Coverage (Bats + kcov)` check because of the same `git diff
origin/main` defect addressed above, and CI had not been re-checked against the fix.

This audit re-checked CI directly rather than relying on the task context's assertion that
the fix was applied:

1. `gh pr view 698 --json headRefOid` confirmed PR #698's head SHA matches this branch's
   current HEAD (`15aa71138bedbeb577906dd8ab05d92e0d08f30b`).
2. `gh pr checks 698`, polled from an initial state of 6 pending required checks (including
   `shell-coverage`) to 0 pending after approximately 5 minutes, confirmed all 16 required
   checks now report `pass`, including `shell-coverage / Shell Coverage (Bats + kcov)` at
   7m25s.
3. `gh pr view 698 --json mergeStateStatus,mergeable` now reports `CLEAN`/`MERGEABLE`
   (previously `BLOCKED` while the check was pending).
4. Direct inspection of the job log (`gh run view --job 108164730498 --log`) confirmed
   `1..463`, zero `not ok` lines, and a `Bash coverage (lines): 93.3%` summary — this CI run
   genuinely exercised the shallow-checkout condition the original defect depended on, unlike
   any local re-run on this worktree (which already has `origin/main` from prior fetch
   history).

This audit treats AC-7 as **PASS at HEAD**, confirmed by a live, independently-polled CI run
against the exact commit under review — not by trusting the task context's claim that the fix
was applied, and not merely by re-running the toolchain locally (which cannot itself confirm
the shallow-checkout-specific fix).

## Independent Verification Limits

This audit did not re-run the full local bats suite a third time; the branch's own evidence
already records two post-fix local runs (`final-shell-qc-check.2026-09-25T16-24.md`,
`final-shell-qc-test.2026-09-25T16-48.md`, both exit 0), and a third local run on this
Windows worktree — which already has `origin/main` locally — would not exercise the
shallow-checkout condition the fix specifically targets. Instead, this audit substituted a
genuinely independent verification: polling and reading CI's own execution against this exact
HEAD, which is the one environment capable of falsifying the fix. This is judged a stronger,
not weaker, form of independent verification for this specific remediation cycle, because the
defect under re-audit is CI-environment-specific by construction.

This audit also independently re-read both edited test bodies in full
(`tests/shell/test_cleanup_worktrees_dirt_classify.bats`,
`tests/shell/test_cleanup_worktrees_dirt_clear.bats`) and the CI workflow file
(`.github/workflows/_shell-coverage.yml`) rather than accepting the remediation-inputs'
root-cause narrative without direct confirmation.

## Acceptance Criteria Status

- Source: `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/issue.md`
- Total AC items: 7
- Checked off (delivered): 7 (AC-1 through AC-7, all marked `[x]` in `issue.md` at HEAD)
- Remaining (unchecked): 0
- Items remaining: none

No AC item required a check-off change by this audit; all seven were already `[x]` in the
source file at HEAD, and this audit's independent evidence — including a live CI run against
the exact commit under review — supports all seven as PASS at HEAD.

## Overall Verdict

**PASS.** All seven acceptance criteria are met at HEAD, independently corroborated against
primary evidence: direct command re-runs, direct source reads, direct fixture inspection, and
— specific to this remediation cycle's purpose — a live, independently-polled CI run against
the exact commit under review confirming the previously-failing `shell-coverage` required
check now passes. No Blocking finding was identified. No remediation-inputs artifact is
required from this audit.
