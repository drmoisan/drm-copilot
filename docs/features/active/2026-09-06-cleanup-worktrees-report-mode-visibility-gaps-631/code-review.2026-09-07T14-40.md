# Code Review — issue #631 (cleanup-worktrees report-mode visibility gaps)

- Timestamp: 2026-09-07T14-40
- Branch: `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
- Diff: `6dff80ed4596bec088d548b23013e6077e32c484...HEAD` (92 files, +1467 / -110)
- Reviewer constraint: bats/kcov/shfmt/shellcheck are not runnable in this session (`wsl`
  denied by the worktree-isolation guard; no binaries on the Windows PATH). All dynamic
  claims below are derived by reading source and fixture files and reasoning about the
  stub's documented lookup contract, not by execution.

## Verdict: changes requested — 1 blocking finding

## What the change does

Adds `scripts/bash/cleanup_worktrees_report_records_lib.sh` (463 lines) with four new
report records and a shared classification driver `classify_all_branches`, plus
`scripts/bash/cleanup_worktrees_scan_helper.sh` (157 lines) as the bundled implementation
behind a new `CLEANUP_WT_SCAN_BIN` seam. `run_report` and `run_apply` both drop their
independent per-branch loops in favour of the shared driver. Documentation is extended in
`cleanup-worktrees.sh`'s `usage()`, the `cleanup_worktrees_lib.sh` header contract, and
both copies of `SKILL.md`.

The overall structure is sound and follows the file's established conventions closely:
parent-shell capture of git output with `|| rc=$?`, echo-verdict helpers that always
return 0, `LC_ALL=C` sorting, override seams that fall back safely, and a new sibling file
rather than growth of an at-cap file. Comment quality is well above average. The findings
below are specific defects, not objections to the approach.

---

## CR-01 — `classify_all_branches` can produce a wrong verdict — **Blocking**

`scripts/bash/cleanup_worktrees_report_records_lib.sh:431-447`

```bash
for target in "${target_list[@]:-}"; do
	[[ -z $target ]] && continue
	[[ -n ${protected[$x]:-} ]] && break
	if [[ ${branch_state[$target]:-} == "NOT_MERGED" ]]; then
		hit=$target
		break
	fi
done
if [[ -n $hit ]]; then
	branch_out[$x]="BRANCH|$x|NOT_MERGED"$'\n'"CHILD_OF|$x|$hit"
	branch_state[$x]="NOT_MERGED"
	continue
fi
```

The only guard on inheritance is whether `X` itself is protected. Nothing checks `X`'s own
relationship to `main`. The justifying premise in the file's own comment (line 339) —

> a branch contained in a branch that is not merged cannot itself be merged

— is false. A branch can be fully merged into `main` *and* be a git ancestor of a
different, unmerged branch. `spec.md`'s "subset argument" carries the same flaw; the
implementation faithfully implements a design defect rather than introducing one.

### Evidence 1 — the feature's own positive fixture already demonstrates it

`tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/` contains no
`diff-quiet.feature-child.rc`. Per the stub's documented contract
(`tests/fixtures/cleanup_worktrees/stub-bin/git:67-81`), an absent `.rc` file yields exit
0. Tracing `classify_branch feature-child` under that scenario without the short-circuit:

1. rung 1 protection — `feature-child` is not the current branch (`rev-parse.abbrev-ref-HEAD.out` is `main`) and has no worktree -> not protected.
2. rung 2 `classify_ancestry` — key `merge-base.feature-child.main` -> `.rc` is `1` -> `NOT_ANCESTOR`.
3. rung 3 `classify_content_neutral` — `git diff --quiet main...feature-child` -> key `diff-quiet.feature-child` -> absent -> exit 0 -> **`MERGED_CONTENT_NEUTRAL`**.

`MERGED_CONTENT_NEUTRAL` is on the apply-mode delete-eligible allowlist
(`cleanup_worktrees_actions_lib.sh:409`). The short-circuit emits
`BRANCH|feature-child|NOT_MERGED` instead. The outcome-preservation invariant is violated
inside the very fixture authored to prove it holds.

### Evidence 2 — the general case, independent of any fixture

Let `X` be a local branch already merged into `main` (so `merge-base --is-ancestor X main`
exits 0 and rung 2 yields `MERGED_CLEAN`), and let `Y` be an open branch created from a
`main` that already contains `X`'s merge. Then `X` is a git ancestor of `Y`, and `Y`
resolves `NOT_MERGED`.

In phase 1, `ancestor_targets[X]` = `{Y, main}` (sorted), so `X` is deferred. In phase 2b,
`main` contributes no hit (it resolves `PROTECTED_CURRENT`, not `NOT_MERGED`), the loop
continues to `Y`, and `X` inherits `NOT_MERGED`. True verdict: `MERGED_CLEAN`.

This is the ordinary steady state of this repository: `main` is at a merge commit
(`0542c92a`), so every stale local branch merged before any currently-open branch's fork
point becomes an ancestor of that open branch. The failure is not exotic.

### Why the test suite does not catch it

Every pre-existing scenario fixture has exactly one feature branch plus `main` (verified
across all 22 `for-each-ref.out` files), so no fixture pairs a delete-eligible branch with
an unmerged branch. The two new multi-branch fixtures deliberately set
`merge-base.feature-child.main.rc = 1`, i.e. they explicitly exclude the failing case. The
negative test varies the *ancestor's* state (`MERGED_EQUIVALENT`); no test varies the
*subject's* own relationship to `main`.

### Impact

Direction is fail-safe for data (a merged branch is under-deleted, never over-deleted),
but the tool's primary function — cleaning up merged branches and their worktrees —
silently stops working for any merged branch with an unmerged descendant. Two evidence
artifacts and two acceptance criteria (AC3's "unchanged `BRANCH|` line" clause and all of
AC5) rest on the invalidated invariant.

### Suggested direction (not prescriptive)

The cheap rungs are exactly the ones that establish merged-ness. Inheriting is only sound
after `X` has been shown not to be merged by any rung. One shape that preserves both the
invariant and most of the saving: run rungs 1-3 for `X` unconditionally (protection, one
`merge-base --is-ancestor X main`, one `git diff --quiet main...X` — all O(1)), and only
if both return "not merged" inherit `NOT_MERGED` and skip rungs 4-6 (`git cherry`,
`diff-tree`, `ls-tree`, `rev-list`), which are the O(commits) rungs the spec identifies as
the actual cost. That still requires an argument that a branch reaching rung 4 and
contained in a `NOT_MERGED` branch cannot resolve `MERGED_EQUIVALENT` or
`HAS_UNIQUE_RESIDUALS`; a cherry-picked ancestor is a counterexample there too, so the
safe version may need rungs 1-4 and only skip 5-6. Whatever shape is chosen, it needs a
fixture in which the subject branch *is* delete-eligible under the full ladder while being
an ancestor of a `NOT_MERGED` branch.

---

## CR-02 — the outcome-preservation test is vacuous — **Major**

`tests/shell/test_cleanup_worktrees_classification.bats`, test
`"child_of_not_merged: report-mode BRANCH line is unchanged by the short-circuit"`:

```bash
report child_of_not_merged
[[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]
cb unmerged feature-unmerged
[ "$output" = "BRANCH|feature-unmerged|NOT_MERGED" ]
```

This compares two *different branches* in two *different scenarios*. It establishes that
the string `BRANCH|<name>|NOT_MERGED` has a consistent shape — which was never in doubt —
and says nothing about whether `feature-child`'s verdict is the one the full ladder would
have produced for `feature-child`. The property AC5(a) names ("the `BRANCH|` line's value
is unchanged whether or not the short-circuit fired") requires holding the branch and the
scenario fixed and varying only whether the short-circuit ran.

The apply-mode companion test in `test_cleanup_worktrees_deletion.bats` has the same
problem in a more consequential form: it asserts no `ACTION|delete|feature-child|` is
emitted, but under the un-short-circuited ladder with that same fixture `feature-child` is
`MERGED_CONTENT_NEUTRAL` and *would* be deleted. The test therefore pins the changed
behaviour in place as if it were the invariant.

A test that would actually verify the property: classify the same branch under the same
scenario twice — once through `classify_all_branches`, once through `classify_branch`
directly — and assert the `BRANCH|` lines are equal. Applied to `child_of_not_merged`
today, that test fails, which is the correct signal.

---

## CR-03 — `cleanup_wt_scan_records` runs twice per report; the docstring says otherwise — **Major**

`scan_orphan_dirs:200` and `scan_registration_loss:253` each call
`cleanup_wt_scan_records` independently. `run_report` calls both
(`cleanup_worktrees_lib.sh:475-476`), so a single report performs two complete filesystem
scans. Each scan invokes `du -sh` once per candidate directory
(`cleanup_worktrees_scan_helper.sh:119`).

Two consequences:

1. Cost. The issue this feature fixes cites a 6 GB orphan checkout. `du -sh` on that
   directory is the single most expensive operation the tool performs, and it now runs
   twice. This partly offsets the runtime reduction the feature exists to deliver, and
   `scan_registration_loss` does not use the `size` field at all.
2. The docstring at `scan_registration_loss:243-244` states: "It consumes the same scan
   output and the same root resolution as `scan_orphan_dirs`, so the two records are
   always derived from one consistent view of the filesystem." The implementation
   provides no such guarantee — the two scans are separate process invocations with a
   window between them.

Suggested fix: hoist the scan into `run_report` (or memoize it in a caller-scoped
variable) and pass the records into both functions, which also makes the docstring true.
A cheaper partial fix is to add a mode flag that skips `du` when the caller does not need
`size`.

---

## CR-04 — `.claude/worktrees` scan root is CWD-relative — **Major**

`cleanup_wt_scan_roots:131`:

```bash
printf '%s\n' ".claude/worktrees"
```

The second root is derived absolutely from `parse_worktree_list`'s first stanza
(`"${main_wt}-wt"`, lines 137-140), but the first is a bare relative path resolved against
the process CWD. `scan_helper_scan_dirs` skips a non-directory root silently
(`[[ -d $root ]] || continue`), so the failure mode is invisible: no error, no record.

`.claude/skills/cleanup-merged-worktrees/SKILL.md` describes agent worktrees living under
`.claude/worktrees/`, and this very review session is running from
`.claude/worktrees/agent-a8598ea9e9820be11`. Whenever the tool is invoked from anywhere
other than the main worktree root, the primary `ORPHAN_DIR` /
`WARN|registration-lost` source is silently skipped — precisely the visibility gap the
feature is meant to close.

Suggested fix: derive it as `"${main_wt}/.claude/worktrees"` from the same
`parse_worktree_list` first stanza already read four lines below, and move the `printf`
after that read so both roots share one derivation and one failure path. Add a test that
pins the derived root list (the `CLEANUP_WT_ORPHAN_ROOTS` override branch is currently the
only one any test touches).

---

## CR-05 — the production `.git` default of the scan seam is untested — **Minor**

`scan_helper_gitfile_name` (`cleanup_worktrees_scan_helper.sh:59-70`) is correct: an unset
or empty `CLEANUP_WT_SCAN_GITFILE_NAME` falls back to the literal `.git`, so the
production path is not weakened by the seam's existence. The rationale for the seam (git
refuses to index a path component named `.git`, and the test policy forbids creating one
at test time) is sound and is documented in both the helper and the bats file.

However, `tests/shell/test_cleanup_worktrees_scan_helper.bats` sets
`CLEANUP_WT_SCAN_GITFILE_NAME=dotgit` in its only test, so the override branch is the only
one exercised. The exact property the seam must preserve — that production still looks for
`.git` — has no test. A change to the fallback literal would be caught by no gate.

A two-line test closes it:

```bash
@test "scan_helper_gitfile_name defaults to .git when the seam is unset" {
    run env -u CLEANUP_WT_SCAN_GITFILE_NAME \
        bash -c "source '${HELPER}' 2>/dev/null; scan_helper_gitfile_name"
    [ "$output" = ".git" ]
}
```

Note that sourcing the helper executes its file-scope `set -euo pipefail`
(`cleanup_worktrees_scan_helper.sh:41`), which is outside the `BASH_SOURCE`/`$0` guard at
line 153. The guard protects only `scan_helper_main`, not the shell-option mutation. If a
test is going to source this file, moving `set -euo pipefail` inside the guard would be
worth doing; it also brings the file in line with the "defines functions only; never runs
work at source time" sourcing contract the sibling libraries advertise.

---

## CR-06 — advisory scan failures now change `run_report`'s exit code and produce a partial report — **Minor**

`cleanup_worktrees_lib.sh:474-476`:

```bash
scan_stale_refs || rc=$?
scan_orphan_dirs || rc=$?
scan_registration_loss || rc=$?
```

`scan_stale_refs` returns git's exit code if `git for-each-ref refs/remotes/` or
`git remote` hard-fails, and `cleanup_wt_scan_records` returns the scan helper's exit code.
Those are folded into `run_report`'s return value after `check_main_freshness` has already
emitted output, so a failure of a purely advisory read now yields a partial report plus a
non-zero exit. The docstring six lines above still promises the opposite:

> A worktree-list OR enumerate-branches hard failure aborts the report before any line is
> emitted and returns git's non-zero exit code, so a git failure never resolves to a
> partial, misleading report.

Two coherent resolutions: either treat the advisory scans like `check_main_freshness` (log
and continue, never affect `rc`), which matches how the spec describes
`WARN|registration-lost` ("never blocks classification"); or move them into the up-front
guarded-capture block so a failure aborts before any emission. The current middle position
matches neither the docstring nor the spec.

Also note `rc=$?` assigns rather than maximizes, unlike the `((crc > rc))` comparison used
for the classification driver twelve lines later. With three sequential assignments the
last failure wins. Minor inconsistency; worth aligning.

---

## CR-07 — `run_apply`'s hard-failure gate narrowed from "non-zero rc" to "state == ANCESTRY_ERROR" — **Minor (verified safe, but worth pinning)**

Before:

```bash
cb_out=$(classify_branch "$name") || crc=$?
if ((crc != 0)); then rc=1; continue; fi
```

After (`cleanup_worktrees_actions_lib.sh:403-408`): the `continue` is now conditioned on
`state == "ANCESTRY_ERROR"`.

I traced every `return 2` in `classify_branch` (`cleanup_worktrees_lib.sh:312-443`). All
of them emit `BRANCH|<name>|ANCESTRY_ERROR` except one: the terminal
`select_cherry_pick_candidates` failure, which returns 2 after emitting
`BRANCH|<name>|HAS_UNIQUE_RESIDUALS`. `HAS_UNIQUE_RESIDUALS` is not on the delete
allowlist, so the deletion decision is unchanged, and the driver-level `crc != 0 -> rc=1`
at line 388 still propagates the non-zero exit. **No behavioural regression** — but the
equivalence is non-obvious and rests on an invariant of a function in a different file
that nothing enforces. A regression test asserting `rev_list_error` under apply mode still
exits non-zero and emits no `ACTION|delete` would pin it.

Related: `printf '%s\n' "$cb_out"` at line 402 now prints an empty line if `$name` is
absent from `$all_out`, where the old code was guaranteed a `BRANCH|` line. That can only
happen if the two independent `enumerate_branches` calls disagree, which is unlikely but
no longer impossible now that there are two of them.

---

## CR-08 — phase 1 is O(n^2) git subprocesses with no measured benefit — **Minor**

`classify_all_branches:377-398` probes every ordered pair, so `n` branches cost
`n*(n-1)` `git merge-base --is-ancestor` process spawns before any classification begins:
20 branches -> 380 spawns, 60 branches -> 3540. The inner loop does not break after the
first hit, and the results beyond the first `NOT_MERGED` target are never used.

The spec explicitly declines to assert a latency number, and the argv-log assertions do
prove the expensive rungs are skipped, so this is not an AC failure. But the feature's
stated motivation is a ~6-minute report, and the change trades an O(commits) cost on some
branches for an unconditional O(branches^2) cost on all of them, with no before/after
measurement in evidence. Combined with CR-03's duplicate `du` pass and the second
`enumerate_branches` call in `run_report` (`cleanup_worktrees_lib.sh:466` probes, then
`classify_all_branches:362` reads it again), the net runtime direction is genuinely
unknown.

Two low-cost improvements: `break` out of the inner loop once a target is found whose
state could license a short-circuit is not possible in phase 1 (states are not yet known),
but capping `found` at the first few targets, or restricting probes to pairs where
`X`'s tip is reachable, would bound the cost. At minimum, a recorded wall-clock
before/after on a realistic checkout would convert the performance claim from asserted to
observed.

---

## CR-09 — documentation inaccuracies — **Minor**

1. `scripts/bash/cleanup-worktrees.sh:58` heads the new block "Advisory, read-only records
   (report and apply mode; none unlocks a destructive action)". Only `CHILD_OF` reaches
   apply mode. `run_apply` never calls `scan_stale_refs`, `scan_orphan_dirs`, or
   `scan_registration_loss`, and its awk filter (`cleanup_worktrees_actions_lib.sh:399-400`)
   passes only `BRANCH`, `CHILD_OF`, and `COMMIT`. The three scan records are report-mode
   only, as `spec.md` states.
2. `CLEANUP_WT_SCAN_GITFILE_NAME` is absent from `usage()`'s "Environment overrides" list,
   which documents its two siblings `CLEANUP_WT_SCAN_BIN` and `CLEANUP_WT_ORPHAN_ROOTS`.
   It is documented in the helper's header, but a user reading `--help` will not find it.
3. `scan_registration_loss`'s "one consistent view of the filesystem" claim — see CR-03.
4. `classify_all_branches`'s inheritance premise — see CR-01.

---

## CR-10 — style nit: protection check inside the target loop — **Trivial**

`cleanup_worktrees_report_records_lib.sh:437`: `[[ -n ${protected[$x]:-} ]] && break` is a
loop-invariant test on `$x` evaluated once per target. Functionally equivalent to a guard
before the loop (deferred branches always have at least one non-empty target), but hoisting
it makes the carve-out's intent legible at a glance, which matters for a guard whose
absence was a correctness bug.

---

## Things done well (worth preserving through remediation)

- The `merge-base.<tip>.<upstream>` target-aware stub key with fallback to the historical
  bare `merge-base.<tip>` key is a careful, minimal extension: it lets a scenario answer
  the same tip differently for two upstreams without touching any of the 22 pre-existing
  scenario directories. The parallel `for-each-ref.<pattern>` key with fallback restricted
  to the single literal `refs/heads/` is equally tight, and the reasoning is written down
  in the stub header.
- `scan_stale_refs` detects any stale remote namespace by set-difference against
  `git remote`, with no reference to the literal `child` from the observed incident, and
  the fixture deliberately uses `upstream` to prove it. This is exactly the generic
  detection the spec asked for.
- `ORPHAN_DIR|<path>|unknown` for an unresolvable size, rather than dropping the record,
  correctly refuses to recreate the visibility gap the feature closes.
- Placing the short-circuit inside the shared driver rather than in `run_report`'s
  formatting layer is the right architectural call, and is what makes CR-01 a single-site
  fix rather than two.
- The new library and helper are cohesive, single-purpose, and each well under the
  500-line cap, with the seam pattern faithfully mirroring `cleanup_wt_git`.
