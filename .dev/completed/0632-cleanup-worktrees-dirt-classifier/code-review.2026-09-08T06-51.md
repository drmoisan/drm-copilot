# Code Review — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 1 exit

- Timestamp: 2026-09-08T06-51 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ed84aac2`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Prior review: `code-review.2026-09-08T05-00.md` (findings F1 through F14)

## Summary

The remediation cycle fixed all three live defects the prior review found (F1/R1, F2/R2,
F4/R5), added the missing staged-tree pins (F3/R4), closed the coverage gap (R3), and
recorded both pending decisions (R6a, R6b). Every fix was re-verified here by reproduction
and by re-applying the pre-fix form to a scratch copy of the library; all six hold.

Two new findings are opened. Both belong to the class this feature has been iterating on:
a rung that resolves a disposable verdict from a read whose result does not support it, and
tests that name a safety property without being able to fail when it is violated.

The change's engineering quality is otherwise high. The library header is unusually
explicit about its own invariants, the exit-code capture discipline is applied consistently,
the record contract puts the variable-length field last, and the test suites carry positive
controls on nearly every absence assertion. The two findings below are precisely where that
discipline has a gap, not a general shortfall.

## Method

- Read `scripts/bash/cleanup_worktrees_dirt_lib.sh` in full, plus the diffs to
  `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup-worktrees.sh`,
  and `tests/fixtures/cleanup_worktrees/stub-bin/git`.
- Read all four dirt bats suites and the four modified suites in full.
- Drove `classify_worktree_dirt` and `clear_disposable_dirt` directly over nine checked-in
  scenarios through the `CLEANUP_WT_GIT_BIN` seam.
- Ran eleven mutation probes: for each, a `sed`-perturbed copy of the library was sourced
  in place of the original and the affected scenarios re-run. A mutation that does not
  change the output identifies a property nothing holds.
- Probed real git 2.53.0.windows.1 in two scratch repositories outside the repository tree
  to establish the actual exit codes and porcelain output the classifier reasons about.

## Findings

### N1 — rung 4 resolves `CONTENT_ON_MAIN` from a pathspec that matched nothing

**Severity: Blocking. Data loss.**
**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`

```bash
cleanup_wt_git --no-optional-locks -C "$wt" diff --quiet main -- "$rel" \
    >/dev/null || drc=$?
if ((drc == 0)); then
    printf 'CONTENT_ON_MAIN|\n'
    return 0
fi
```

`git diff --quiet` exits 0 for two distinct reasons: the compared content is identical, and
the pathspec selected no paths at all. The code reads only the first meaning.

The prior review established the library's own standard for this shape of inference. Rung 3
carries it explicitly at line 213:

```bash
total=$((wout + cout))
((total == 0)) && return 1
```

with the header comment "A diff pair with zero changed content lines is NOT a build
artifact. Vacuous confinement would let a read that returned nothing resolve to a disposable
verdict, which is the fail-open direction." Rung 4 makes the same inference without the same
guard.

Verified against real git 2.53.0 rather than against the stub, because the stub's default
exit code is also 0 and would not distinguish an intended answer from an absent fixture:

```
$ git diff --quiet main -- "no/such/file.md" ; echo $?
0
```

The reachable status code is `AD`: a file added to the index and then removed from the
working tree. Its content exists only as a staged blob — in no commit, and not on disk.
Real git confirms both the porcelain code and the two exit codes the ladder then reads:

```
$ git add staged_only.md && rm staged_only.md && git status --porcelain
AD staged_only.md
$ git diff --quiet main -- staged_only.md ; echo $?
0
$ git hash-object -- staged_only.md ; echo $?
fatal: could not open 'staged_only.md' for reading: No such file or directory
128
```

Driving the delivered classifier with only those observed values:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||AD|staged_only.md
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
ACTION|dirt-clear|/repo-wt/dirt|OK
```

`ACTION|...|OK` is emitted only after `reset --hard` and `clean -fd` both returned 0.
`reset --hard` drops the index entry and the blob becomes unreachable. The `DIRTFILE|`
record additionally asserts the content is on `main`, which it is not, so the audit trail
misdescribes what was destroyed.

**This is not a consequence of the R1 fix.** A control run with the Y-column gate reverted
labels the same entry `STAGED_TREE_IS_COMMIT|eeee7777` and still aggregates
`ALL_DISPOSABLE`. The R1 fix changes which rung answers an `AD` entry, not whether it
clears. The hole is in the classifier as originally delivered and was missed in cycle 1.

**Remedy.** Condition rung 4's positive answer on the path actually existing. Either probe
`ls-files --error-unmatch -- "$rel"` before trusting exit 0, or test the working-tree file's
presence. A `diff --quiet` exit 0 over an empty pathspec must advance the ladder, which
routes the entry to the `hash-object` guard and then to `UNIQUE` — the safe direction that
the rest of the file already takes.

**Required tests.** A fixture with `AD <path>`, `diff-quiet..<path>.rc` of 0, and
`hash-object.<path>.rc` of 128, asserting the verdict is not `CONTENT_ON_MAIN` and the
aggregate is not `ALL_DISPOSABLE`; and the positive direction, a tracked entry whose
content genuinely equals main's, so the narrowing does not disable the rung. Both
directions, per the standing obligation.

### N2 — four safety guards that no checked-in fixture can distinguish from their absence

**Severity: Blocking.**
**Locations:** `cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`, `:336-339`

This is the same defect class as the three vacuous assertions fixed earlier in this feature
and the fixture-prose case the executor self-reported during this cycle, in a fourth form:
the assertion is not vacuous in isolation, but the *fixture* cannot separate the guarded
path from the unguarded one, because a second and weaker condition downstream reaches the
same verdict.

Each guard was removed in a scratch copy and every checked-in `dirt_*` scenario re-run. In
all four cases the entire checked-in set is byte-identical with and without the guard. A
purpose-built scenario then shows the guard is load-bearing:

**`:336-339` — the `log --find-object` fail-closed guard.**
`dirt_history_read_error` supplies `log.find-object.cccc2222.rc` of 128 and no `.out`, so
`found` is empty and the entry reaches rung 6 whether or not the guard exists. Add stdout
to the failing read and the guard's removal produces
`CONTENT_IN_HISTORY|ffff8888` and `ALL_DISPOSABLE`. This matters because `git log` can emit
commits and then fail — a partially unreadable pack is the ordinary case.

**`:311-314` — the `((hrc != 0))` clause of the `hash-object` guard.**
`dirt_classifier_read_error` supplies rc 128 with no `.out`, so `[[ -z $blob ]]` alone
carries the verdict. With a blob id in the failing read's stdout, removing the rc clause
produces `CONTENT_ON_MAIN` and `ALL_DISPOSABLE`.

**`:301-304` — the `((drc > 1))` fail-closed guard in rung 4's tracked half.**
`dirt_tracked_read_errors` supplies no `hash-object.docs_tracked.md.out`, so the entry
reaches the empty-blob branch regardless. Give the entry a resolvable blob that is in
history and removing the guard produces `CONTENT_IN_HISTORY` and `ALL_DISPOSABLE`.

**`:213` — the vacuous-confinement guard.**
No checked-in scenario exercises a `*.csproj` entry whose worktree diff and cached diff are
both empty and both succeed. Constructed: baseline `UNIQUE`/`HAS_UNIQUE`; with the guard
removed, `DISPOSABLE_BUILD_ARTIFACT`/`ALL_DISPOSABLE`. This is the guard the library header
devotes a paragraph to, and it is the only one of the four with no scenario naming it at
all.

**Remedy.** Four fixtures. Three are a single added `.out` file on an existing scenario
directory so the failing read carries stdout as well as a non-zero exit; the fourth is an
existing csproj scenario with both diff payloads emptied and the lower rungs set to miss.
Each needs one assertion on the resulting verdict and aggregate.

## Verification of the prior findings

| ID | Prior severity | Verdict now | How verified |
|---|---|---|---|
| F1 / R1 | FAIL, data loss | **Closed** | `dirt_staged_tree_worktree_delta` reproduces `UNIQUE`/`HAS_UNIQUE`/`REFUSED-UNIQUE`; mutation M1 restores the defect exactly |
| F2 / R2 | FAIL, data loss | **Closed** | `dirt_rename_split` reproduces the full path and `UNIQUE`; mutations M2 and M3 both restore the truncation |
| R3 | FAIL | **Closed** | 94.05% parsed from the CI Cobertura artifact; all ten residual uncovered lines inspected and classified |
| F3 / R4 | FAIL | **Closed** | Five directions present in `test_cleanup_worktrees_dirt_failclosed.bats`; mutation M5 flips both hard-failure fixtures |
| F4 / R5 | Blocking-PARTIAL | **Closed** | Header skip anchored; mutation M4 flips both fixtures; the fixture prose no longer contains the literal it discriminates on |
| F5 / R6a | Blocking-PARTIAL | **Closed** | Documented in `SKILL.md`; pinned at exit 128 with a positive control; AC-43 added |
| F6 / R6b | Blocking-PARTIAL | **Closed** | Documented in `SKILL.md` as retained-but-inert; `--ignored` absence pinned with a positive control; AC-44 added |

## Positive observations

These are recorded because they are the parts of the change that should not be disturbed by
cycle 2.

- **Exit-code capture discipline.** Every git-backed read whose exit code is authoritative
  is captured in the parent shell with `out=$(cmd) || rc=$?`. No pipeline or process
  substitution swallows a non-zero exit anywhere in the new library.
- **Two-way classification of non-zero exits.** The distinction between a probe whose
  non-zero exit is its defined negative answer (`rev-parse main:<path>`,
  `diff --quiet ... -- <path>` exiting 1) and one that carries no verdict is stated in the
  header and applied consistently. Collapsing the two would make `CONTENT_IN_HISTORY`
  unreachable, and the header says so.
- **Record field order.** Placing the file path last is the right call and is pinned by
  `dirt_pipe_path`, which uses a path containing the delimiter.
- **The C-quoted early return.** Returning `UNIQUE` without attempting to unquote is the
  correct trade: the only use of an unquoting surface would be to widen what can be
  cleared. `dirt_quoted_path` pins it in a way that does fail when the guard is removed —
  the argv-log assertion catches the probes issued against the quoted payload, even though
  the verdict itself is unchanged. This is the standard the four guards in N2 should meet.
- **The wrapper-driven test pair.** The two tests at the foot of
  `test_cleanup_worktrees_dirt_clear.bats` use `env -u CLEANUP_WT_CLEAR_DISPOSABLE` and
  differ only in the flag, which is what makes the flag pre-pass falsifiable. The header
  states why the direct driver alone would not be enough. This is well done.
- **Ordinal assertions over the second occurrence.** The suite header explains that
  `remove_worktree_safe` issues `worktree remove` before it reads status, so a first-match
  idiom would compare against a line preceding `reset --hard`. Getting this right and
  documenting why is the difference between a passing test and a meaningful one.
- **Argv-log filtering.** `argv_log()` filters to `stub-git: ` lines specifically because
  the emitted records also carry file paths; a search over the merged output would report a
  path as "named by a git invocation" when it appeared only in a record. Correct and
  non-obvious.
- **The `run_report` main/bare guard.** Adding `[[ ,$wflags, != *,main,* && ,$wflags, != *,bare,* ]]`
  alongside the existing `is_detached_candidate` skip keeps classification off the three
  registration kinds that are never deletion candidates, at a four-line cost in a file with
  four lines of headroom.

## Best-practice notes (non-blocking)

- **`rc=$?` at the new `run_report` call site** (`cleanup_worktrees_lib.sh:485`) departs
  from the documented max-rc contract used elsewhere in the same function. Recorded as F9
  and deferred; the disposition correctly observes the effect is a lower code replacing a
  higher one, never a zero replacing a non-zero. Carried forward.
- **AC-8's "ten `dirt_*` scenarios"** is now 25. The test enforces the correct number with
  an on-disk count assertion, so the code is ahead of the criterion text. Worth a one-word
  correction when the spec is next touched.
- **The `any_staged` pre-scan** issues the bounded probe for a worktree whose only staged
  entries have a non-space Y column, producing a result no entry consumes. Verified to
  cause no wrong verdict — the probe answers a worktree-wide question about the index and
  rung 1's Y gate decides consumption — so this is cost, not correctness. The header
  comment at lines 375-376 remains accurate as written.
- **The Y-column rename form.** The split gate reads the X column only. Probed against real
  git 2.53.0 across four rename shapes: an unstaged rename is reported as ` D` plus `??`,
  and a staged rename keeps `R` in X even after a second worktree rename. No `[ M]R`
  porcelain output was reproducible, so the X-only gate matches observed behaviour.
  Recorded as checked rather than as a gap.
- **`dirt_build_artifact_added_file`** asserts `DISPOSABLE_BUILD_ARTIFACT` for a wholly
  added csproj. Because the rule requires every changed line to be a `HintPath` rewrite,
  the class can only fire for a project file consisting solely of `HintPath` lines, which
  is not a valid project file. Harmless; noted because it is the only assertion of the
  build-artifact class over an added file, and the fixture is therefore doing less work
  than its name suggests.

## Files reviewed

| File | Lines | Notes |
|---|---:|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 463 | New. Subject of N1 and N2. |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | +6 lines: record contract comment and the classification call site. |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | +22 lines: the clear-and-retry hook and its header note. `remove_worktree_safe` textually unchanged. |
| `scripts/bash/cleanup-worktrees.sh` | 187 | +61 lines: the flag pre-pass, usage text, and the source of the new library. |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 393 | New keys for `hash-object`, `log --find-object`, `diff-index`, `reset`, `clean`, the non-quiet `diff` forms, and the `GIT_INDEX_FILE` sentinel. |
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 377 | 19 tests. |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | 302 | 13 tests. |
| `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` | 158 | 7 tests. New this cycle. |
| `tests/shell/test_cleanup_worktrees_dirt_regression.bats` | 143 | 12 tests. |
| `tests/shell/test_cleanup_worktrees_cli.bats` | 150 | +4 tests. |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | — | +85 lines across five sections; byte-identical to its push-down mirror (md5 `0735a744...`). |

## Blocking count

**2** (N1, N2).
