# Code Review — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Head: `15aa71138bedbeb577906dd8ab05d92e0d08f30b`
- Timestamp: 2026-09-25T17-00
- Review cycle: remediation-cycle re-audit, cycle 1. This review evaluates the full branch
  diff against base, not merely the one fix commit since the prior round's review
  (`code-review.2026-09-25T15-48.md`, head `783df800...`).

## Files Reviewed (full branch diff)

| File | Change vs base | Lines at HEAD |
|---|---|---|
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | +48/-4 net vs base | 422 |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | +31/-0 net vs base | 333 |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | +30/-5 net vs base | 417 |
| `tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/*` (10 files) | new | small fixtures |
| Docs/evidence under `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/` (18 files) | new/updated | markdown, exempt from line limit |

No production file (anything under `scripts/`) is touched. This is a test-only change, as
the issue's "Implementation Intent" states, confirmed by direct diff re-derivation
(`git diff --name-status 26d57cb3..15aa7113`).

## What Changed Since the Prior Review Round (head `783df800` -> `15aa7113`)

One commit, `15aa7113` ("fix(tests): remove CI-incompatible git diff origin/main from
negative controls (#660)"), touching:

- `tests/shell/test_cleanup_worktrees_dirt_classify.bats`: removed a 3-line
  `run git -C "${REPO_ROOT}" diff origin/main -- "${DIRTLIB}"` / `[ "$status" -eq 0 ]` /
  `[ -z "$output" ]` triple from the AC-2 negative-control test.
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats`: removed the equivalent 3-line triple
  (against `"${LIB}"`) from the AC-5 negative-control test.
- `issue.md`: reconciled the AC-2/AC-5/AC-7 narratives to describe the CI failure, its root
  cause, and this fix.
- `plan.2026-09-25T08-25.md`: revised the P1-T3/P1-T6 task text in place to match the
  corrected test bodies.
- Two new evidence files recording the post-fix local re-run
  (`final-shell-qc-check.2026-09-25T16-24.md`, `final-shell-qc-test.2026-09-25T16-48.md`)
  and a second `final-ac6-scripts-diff.2026-09-25T16-48.md` run.

## Correctness Review

### The fix itself

Both removed triples were redundant with the triple immediately following them
(`git status --porcelain -- <file>`, unchanged), which proves the same property — the
mutated source was composed in-memory and evaluated in a child process, never written to the
production file on disk — using only local index/HEAD state, which is resolvable at any
checkout depth including CI's shallow (depth-1) checkout. The removed `git diff origin/main`
form additionally required a local `origin/main` ref that a depth-1 checkout of a PR merge
commit does not create, which is exactly why it failed on CI (`not ok 275`, `not ok 297`)
while passing on every local run (where `origin/main` already exists from prior fetch
history). This diagnosis, recorded in `remediation-inputs.2026-09-25T17-00.md`, was
independently re-verified by this review:

- Read `.github/workflows/_shell-coverage.yml` directly: line 14 is
  `uses: actions/checkout@v7` with no `fetch-depth` argument, confirming the default
  shallow (depth-1) checkout applies.
- Read both edited test bodies directly at HEAD: each retains exactly one
  `run git -C "${REPO_ROOT}" status --porcelain -- <file>` / `[ "$status" -eq 0 ]` /
  `[ -z "$output" ]` triple immediately following the assertions the negative control makes,
  with the removed `git diff origin/main` triple gone and no other line disturbed.
- Confirmed via `gh run view --job 108164730498 --log` that CI's `shell-coverage` job, run
  against this exact HEAD, now passes with `1..463` and zero `not ok` lines, including tests
  275 and 297 by TAP position.

The fix is minimal, correctly scoped to the two affected test bodies (no other file or test
was touched), and does not weaken what AC-2/AC-5 require: both ACs' "production file
byte-identical to `origin/main` afterward" clause remains independently and structurally
guaranteed branch-wide by AC-6 (no commit on this branch ever touches a `scripts/` file),
which the retained `git status --porcelain` check corroborates locally without needing the
removed remote-ref comparison.

### AC-1 / AC-2 — `dirt_typechange_delta` scenario and its negative control (re-verified, unaffected by content changes)

Unaffected by this round's fix beyond the triple removal addressed above. Re-confirmed at
HEAD: the positive test still asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat`
and `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`; the negative control still mutates
`[MARCTU]`→`[MARCU]` in-memory, asserts the verdict flips to `CONTENT_ON_MAIN`/
`ALL_DISPOSABLE`, and now proves non-mutation solely via the retained `git status
--porcelain` triple. `grep -n "MARCTU" scripts/bash/cleanup_worktrees_dirt_lib.sh`
re-confirmed exactly one occurrence (line 297, containing the token twice — once per
porcelain column), so the unanchored `sed` substitution remains safe and unambiguous.

### AC-3 — Stub header accuracy (unaffected by this round)

`tests/fixtures/cleanup_worktrees/stub-bin/git` is unchanged by the fix commit. Re-read at
HEAD to confirm no incidental drift: the header still replaces the previously-false "no
index-writing arm" claim with a per-arm table naming every subcommand that writes to the
index or object database and its permitted call sites. Unchanged and correct.

### AC-4 / AC-5 — Widened non-mutation assertion and its negative control (fix applied here)

`tests/shell/test_cleanup_worktrees_dirt_clear.bats`: the positive assertion set (lines
205-225, unaffected) still asserts absence of `add`, `commit`, `update-index`,
`write-tree`, `hash-object -w`, `worktree remove`, and `branch -D` in the report-mode argv
log. The negative-control test (now lines 227-253) still injects a
`cleanup_wt_git add -- test-negative-control >/dev/null || true` line via an in-memory `sed`
insertion and asserts `[[ "$log" == *" add "* ]]` (the widened assertion's negation). The
only change is the removal of the `git diff origin/main -- "${LIB}"` triple; the retained
`git status --porcelain -- "${LIB}"` triple (now the sole non-mutation proof) was
independently re-read and confirmed present, correctly placed after the mutation assertion,
and unchanged in logic from the prior round.

### AC-6 / AC-7 — Scope and toolchain (this round's primary re-verification target)

- Re-derived directly: `git diff --name-status 26d57cb3..15aa7113 -- scripts/` and
  `git status --porcelain -- scripts/` both empty. AC-6 holds at HEAD.
- AC-7's toolchain gate was the specific subject of this remediation cycle. This review
  confirmed it two ways: (1) direct re-derivation of the AC-6 diff and a read of both edited
  test bodies confirming the fix is syntactically and logically correct; (2) an independent
  CI run at HEAD (`gh pr checks 698`, polled from 6 pending required checks to 0, then
  `gh run view --job 108164730498 --log` read directly) confirming
  `shell-coverage / Shell Coverage (Bats + kcov)` passes with `1..463`, zero `not ok` lines,
  and a `Bash coverage (lines): 93.3%` summary. CI is the environment that actually exercises
  the shallow-checkout condition the original defect depended on, so this is a stronger check
  than a further local re-run (which cannot reproduce a missing `origin/main` ref on this
  worktree, which already has one from prior fetch history).

## Best-Practice Observations (non-blocking)

- **The fix correctly identifies and removes redundancy rather than patching around it.**
  Rather than, for example, adding a `fetch-depth: 0` to the CI workflow (which the branch's
  own remediation-inputs correctly identifies as an out-of-scope, unrequested workflow-file
  change for a test-only minor-audit branch) or wrapping the `git diff origin/main` call in a
  fallback, the fix recognizes that the following `git status --porcelain` triple already
  proves the same property using only locally-resolvable state, and removes the strictly
  weaker, environment-dependent duplicate. This is the simplest change that restores the
  property the test needs, consistent with the "simplicity first" design principle in
  `.claude/rules/general-code-change.md`.
- **The commit message and `issue.md` reconciliation are precise about root cause.** Both
  correctly distinguish "fails under CI's shallow checkout" from "fails because the fix is
  wrong" — the removed comparison was never asserting something false about the mutation
  under test; it was asserting something environment-dependent that happened to be
  unresolvable in one specific execution context. This is an accurate framing that this
  review's independent CI-log inspection corroborates.
- **This round closes a coverage-evidence gap the prior review flagged as UNVERIFIED,
  without the review itself needing to regenerate coverage.** The prior round could not
  confirm the repo-wide bash line-coverage percentage because no local kcov artifact existed
  and CI had not yet run cleanly against a fixed HEAD. This round's CI run (triggered by the
  fix commit, not by this review) produced that evidence as a side effect of confirming the
  toolchain fix, and this review read it from the CI log rather than rerunning coverage
  generation itself.

## Findings Requiring Remediation

None. No Blocking or Major finding was identified in this review. The fix commit under
review is a minimal, correctly-scoped, independently-corroborated (via a genuine CI run)
correction of the single defect this remediation cycle exists to address.
