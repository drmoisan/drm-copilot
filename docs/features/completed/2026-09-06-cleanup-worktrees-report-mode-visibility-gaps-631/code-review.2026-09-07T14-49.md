# Code Review: cleanup-worktrees report-mode visibility gaps (Issue #631)

**Review Date:** 2026-09-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631`
**Feature Folder Selection Rule:** the only active feature folder whose issue-number suffix (`-631`) matches the canonical issue for this branch, and the only one whose scoping documents appear in the branch diff.
**Base Branch:** `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
**Head Branch:** `local-work-631-r2` (alias of `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`) @ `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`
**Review Type:** Initial review

---

## Executive Summary

This change closes three report-mode visibility gaps in the `cleanup-worktrees` bash tool by
adding four additive record types (`ORPHAN_DIR`, `STALE_REF`, `CHILD_OF`,
`WARN|registration-lost`), and adds a classification short-circuit intended to reduce report
runtime. The implementation is 85 files and roughly 1346 inserted lines, of which about 620 are
new production bash in two new files and the rest are bats tests, checked-in fixtures, and
documentation.

The engineering craft is high in most respects. The new logic is correctly placed in a sibling
library so that `cleanup_worktrees_lib.sh` stays under the 500-line cap (491 of 500). The
filesystem-scan override seam `CLEANUP_WT_SCAN_BIN` faithfully mirrors the established
`CLEANUP_WT_GIT_BIN` pattern and is wired into every pre-existing bats driver call site, so no
test touches the real filesystem and no temporary file is created anywhere. The shared
`classify_all_branches` driver is called by both `run_report` and `run_apply`, which is exactly
the structural mitigation spec.md's Risks section demanded. `shfmt -d` and `shellcheck -x`
return exit 0 on every changed shell file, the full bats suite is 335/335 green at the head SHA,
and repo-wide bash line coverage is 93.4%.

The change nonetheless cannot ship as written. The `CHILD_OF` short-circuit rests on an
inference that is logically invalid: it concludes that a branch X which is a git *ancestor* of a
`NOT_MERGED` branch Y must itself be `NOT_MERGED`. A branch already merged into `main` is an
ancestor of `main`, and therefore an ancestor of every branch descending from `main`. Such a
branch is precisely what the tool exists to find. I constructed that scenario against the
repository's own checked-in git stub and executed both code paths: pre-change the branch
resolves `MERGED_CLEAN` and apply mode emits `ACTION|branch-delete|...|OK`; post-change it
resolves `NOT_MERGED` with a `CHILD_OF` line and apply mode emits no deletion at all. This
breaks the outcome-preservation invariant spec.md declares as hard, in both of its stated
properties, and it disables merged-branch cleanup in any repository that has at least one
unmerged descendant branch.

Neither the new tests nor the recorded "NO_DIFF" outcome-preservation sweep could have caught
this, because no fixture scenario in the repository pairs a delete-eligible branch with a
`NOT_MERGED` branch. That is a second, independent finding: the tests that exist to prove the
invariant do not exercise the case in which it fails.

A secondary cluster concerns cost. The pairwise ancestry probe is O(n^2) git subprocess spawns
with no early exit, the filesystem scan runs twice per report, and `du -sh` is computed for
every candidate directory including live worktrees though the size is only ever used for
`ORPHAN_DIR` records. All three are added by a change whose stated motivation for gap 9c was
reducing report runtime, and no runtime measurement is recorded anywhere.

**What changed:**
- New `scripts/bash/cleanup_worktrees_report_records_lib.sh` (463 lines): `cleanup_wt_scan_bin`, `scan_stale_refs`, `cleanup_wt_scan_roots`, `cleanup_wt_scan_records`, `scan_orphan_dirs`, `scan_registration_loss`, `cleanup_wt_protected_branches`, `classify_all_branches`.
- New `scripts/bash/cleanup_worktrees_scan_helper.sh` (157 lines): the bundled real implementation behind the scan seam, emitting `<path>|<has_gitfile>|<gitdir_target_exists>|<size>` per candidate directory.
- `run_report` (`cleanup_worktrees_lib.sh:451-491`): its inline per-branch loop is replaced by a `classify_all_branches` call; three scan calls are inserted after `check_main_freshness`.
- `run_apply` (`cleanup_worktrees_actions_lib.sh:334-417`): its inline per-branch loop is replaced by one `classify_all_branches` call plus a per-branch `awk` extraction of that branch's `BRANCH|`/`CHILD_OF|`/`COMMIT|` lines.
- `cleanup-worktrees.sh`: sources the new library between the enumerate lib and the classification lib; extends the usage text with the four record shapes and two new environment overrides.
- `tests/fixtures/cleanup_worktrees/stub-bin/git`: additive pattern-specific `for-each-ref.<pattern>` key with a `refs/heads/`-only fallback, target-aware `merge-base.<tip>.<up>` key with a bare-key fallback, and a new `remote)` case.
- 14 new `@test` blocks, 3 new bats files, 9 new scenario fixture directories, and a `scan_roots/basic` fixture tree.
- SKILL.md Report Line Contract gains four bullets, mirrored byte-identically into the extension bundle.

**Top 3 risks:**
1. Merged branches stop being reported as merged and stop being deleted in apply mode whenever any unmerged branch descends from `main`. This is the tool's primary function.
2. The invariant tests that exist give false assurance: both "outcome preservation" tests pass while the invariant is violated, because neither compares the same branch with and without the short-circuit on a delete-eligible verdict.
3. Report-mode runtime may have regressed rather than improved, and no measurement exists either way, so the gap 9c objective is unfalsifiable as delivered.

**PR readiness recommendation:** **Needs Revision** — one Blocker with a proven behavioral regression in apply mode, plus a test-adequacy Blocker that allowed it through; the remaining Major findings sit in the same code the fix must touch.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 434-447 (`classify_all_branches` phase 2b) | The short-circuit infers `BRANCH\|X\|NOT_MERGED` whenever X is a git ancestor of some Y that resolved `NOT_MERGED`. The inference is invalid: a branch merged into `main` is an ancestor of `main` and therefore of every branch descending from `main`. Such a branch flips from `MERGED_CLEAN` to `NOT_MERGED`, and apply mode then emits no deletion `ACTION` for it. | Do not infer a verdict from an ancestor-of relationship in this direction. The sound direction is the descendant one (X contains a `NOT_MERGED` branch's unique residuals). Note that even the inverted rule cannot distinguish `NOT_MERGED` from `HAS_UNIQUE_RESIDUALS`, and that in the originally reported scenario the epic children were ancestors of the integration branch, so an inverted rule would not short-circuit them. Alternatively gate the short-circuit on X additionally not being an ancestor of `main`, with its own soundness argument. Requires a spec.md amendment, since spec.md states the same invalid rule. | Violates spec.md's declared hard outcome-preservation invariant in both stated properties, and disables merged-branch cleanup — the tool's primary purpose — in any repository with an unmerged descendant branch, which is the normal state. | Direct execution against `tests/fixtures/cleanup_worktrees/stub-bin/git` with a 3-branch scenario. Pre-change: `BRANCH\|feature-merged\|MERGED_CLEAN` and `ACTION\|branch-delete\|feature-merged\|OK`. Post-change: `BRANCH\|feature-merged\|NOT_MERGED`, `CHILD_OF\|feature-merged\|feature-unmerged`, no `ACTION`. Full transcript in the "Reproduction" section below. |
| Blocker | `tests/fixtures/cleanup_worktrees/scenarios/**`, `tests/shell/test_cleanup_worktrees_classification.bats`, `tests/shell/test_cleanup_worktrees_deletion.bats` | `classification.bats:191-204`; `deletion.bats:130-140`; all ~30 scenario dirs | The two tests that exist to prove the outcome-preservation invariant cannot fail when it is violated. Test (a) compares `feature-child` under `child_of_not_merged` against a *different* branch under a *different* fixture (`unmerged`/`feature-unmerged`), so it asserts record shape, not value invariance for the same branch. Test (b) asserts only that a `NOT_MERGED` branch is not deleted, which was already true before the change. No scenario anywhere pairs a delete-eligible branch with a `NOT_MERGED` branch. | Add a scenario with three branches — `main`, a branch that resolves `MERGED_CLEAN` (or `MERGED_EQUIVALENT`) against `main`, and a `NOT_MERGED` branch that the merged branch is an ancestor of — and assert both the report verdict and the apply-mode `ACTION`. Re-run the pre/post `NO_DIFF` sweep with that scenario included. | The invariant is declared hard in spec.md; a hard invariant needs a test that can fail. Without one, the regression in the row above shipped through a fully green 335/335 suite. | `for-each-ref.out` line counts across all scenario dirs: 21 have 2 branches, 3 have 3 (the new `child_of_*`), rest have 1 or 0. In all three `child_of_*` fixtures the short-circuited branch is genuinely unmerged (`merge-base.feature-child.main.rc` = `1`). The recorded sweep in `evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md` is bounded by this same fixture set. |
| Major | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 200 and 253; docstring 243-244 | `scan_orphan_dirs` and `scan_registration_loss` each call `cleanup_wt_scan_records` independently, so the filesystem walk and every `du -sh` run twice per report. The docstring asserts the opposite: "consumes the same scan output ... so the two records are always derived from one consistent view of the filesystem." | Hoist the scan once in `run_report` and pass the record set to both functions, or memoize `cleanup_wt_scan_records` in a shell-level cache variable. Then the docstring becomes true. | Doubles the most expensive new operation, and the false single-view claim matters exactly under the mid-run mutation condition gap 9d describes. | Read of lines 199-206 and 252-259; both begin `recs=$(cleanup_wt_scan_records) \|\| rc=$?`. |
| Major | `scripts/bash/cleanup_worktrees_scan_helper.sh` | 119 (`size=$(scan_helper_dir_size "$path")`) | `du -sh` is computed for every immediate subdirectory of every scan root, including live registered worktrees, although `<size>` is only ever emitted on `ORPHAN_DIR` records. The issue itself cites a 6 GB orphan checkout, and a developer machine typically has several multi-gigabyte worktrees. | Emit the size lazily: have the helper accept a flag or a second subcommand that sizes only the paths the caller has already determined to be orphans, or move the `du` call behind the `has_gitfile == 0` test. | A large new synchronous cost on the report path, added by a change whose gap 9c objective was reducing report runtime. | `scan_helper_scan_dirs` sizes unconditionally at line 119, before the caller filters on `has_gitfile` at `cleanup_worktrees_report_records_lib.sh:222`. |
| Major | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 377-398 | The pairwise ancestry probe spawns up to n(n-1) `git merge-base --is-ancestor` processes and never breaks out of the inner loop after the first hit, although at most one resolved target is ever consumed at line 438. For the 20+ branch checkout described in the issue this is 400+ additional process spawns. | Break the inner loop once a target is found if the algorithm only needs one, or restrict candidate targets to branches already resolved `NOT_MERGED` in phase 2a and probe lazily. Whatever the fix for the Blocker, record a before/after runtime measurement so the gap 9c objective is falsifiable. | The stated purpose of the `CHILD_OF` work is runtime reduction; three new costs were added and none was measured. | Nested `for x`/`for y` at 377-394 with `found+=("$y")` and no `break` on success; the only consumer is the first `NOT_MERGED` match at 438-441. No runtime figure appears anywhere in the feature folder. |
| Major | `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup_worktrees_scan_helper.sh` | 81-82, 86-87, 124-129, 135, 159, 161, 173, 176-177, 202, 255, 292, 303, 364, 373, 429, 453; helper 54, 69, 88-89, 127, 145-146 | 30 of 262 instrumented lines in the two new files are unhit, and they are almost entirely the error, fallback, and override branches: both `scan_stale_refs` git-failure returns, the `CLEANUP_WT_ORPHAN_ROOTS` override, the non-executable `bash "$bin"` fallback, all three scan-failure returns, both `cleanup_wt_protected_branches` failure returns, and the helper's `du`-failure `unknown` path. The helper's production default pointer-file name `.git` (line 69) is never exercised, because every test sets the seam. | Add tests for the three spec-named edge cases (`ORPHAN_DIR\|<path>\|unknown`, scan hard failure, unreadable pointer file), for the `CLEANUP_WT_ORPHAN_ROOTS` override, and for one `scan_helper` invocation that does not set `CLEANUP_WT_SCAN_GITFILE_NAME`. | `.claude/rules/general-unit-test.md` Scenario Completeness requires error-handling coverage; spec.md's Test Strategy names three of these cases explicitly as required edge cases. Repo-wide coverage stays above the floor, so nothing else flags this. | Per-line `hits="0"` parse of `cov.xml` from the `shell-coverage` artifact of CI run 34151370364. |
| Major | (process) `docs/features/.../evidence/regression-testing/` | plan task P2-T3, unchecked | No evidence exists for the standalone regression gate the spec and plan require immediately after the `for-each-ref`/`merge-base` stub key edits and before any new fixture is authored on top of them. The named artifact `stub-git-backward-compat.2026-09-06T23-03.md` is absent, and the work landed as a single squashed commit, so the intermediate state cannot be reconstructed. | Either re-derive the gate (check out the stub edit alone onto the base tree and run the pre-existing suite) or record explicitly that the ordered gate was not performed and that only the end-state green suite is available. | spec.md calls this out as a specific risk: the stub file is shared by every scenario and an incorrect fallback could silently replay the wrong canned data for one of two distinct `for-each-ref` calls. | Plan line 231 `- [ ] [P2-T3]`; `find evidence -type f` returns 7 files, none under `regression-testing/`. The fallback logic itself reads correctly (`stub-bin/git:120-123` and `:142-146`) and the end-state suite is 335/335 green. |
| Minor | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 131 | `cleanup_wt_scan_roots` emits the literal relative path `.claude/worktrees`. The tool never chdirs to the repository root (`cleanup-worktrees.sh:10` resolves only `SCRIPT_DIR`), so run from any other directory the helper's `[[ -d $root ]] \|\| continue` silently skips the root and no record is produced for it. Separately, the registration cross-check compares this relative path against absolute porcelain paths after `normalize_wt_path`, which does not absolutize, so that gate can never match for this root. | Resolve the root against `git rev-parse --show-toplevel` (already read elsewhere in the enumerate lib) and emit an absolute path. | The `.claude/worktrees` root is where the reported orphans actually live; silently finding nothing recreates the visibility gap this feature closes. | `normalize_wt_path` at `cleanup_worktrees_enumerate_lib.sh:150-164` performs slash/case/trailing-slash normalization only. Currently masked because orphan candidates are filtered on `has_gitfile == 0` before the registration check. |
| Minor | `scripts/bash/cleanup-worktrees.sh` | 58 | The usage block heads all four new records "Advisory, read-only records (report and apply mode; ...)". `scan_stale_refs`, `scan_orphan_dirs`, and `scan_registration_loss` are called only from `run_report`; only `CHILD_OF` reaches apply mode. | Split the heading, or scope the parenthetical to `CHILD_OF`. | The usage text is the tool's user-facing contract; it currently promises apply-mode records that are never emitted. | `cleanup_worktrees_lib.sh:475-477` are the only call sites of the three scan functions; `run_apply` calls only `classify_all_branches`. |
| Minor | `scripts/bash/cleanup_worktrees_lib.sh` | 475-477 | The three scan calls run after `check_main_freshness` has already emitted output. A hard scan failure sets `rc` but the report continues, producing exactly the partial report the function's own docstring (lines 456-459) says never happens. The three consecutive `\|\| rc=$?` assignments also use last-failure rather than maximum semantics. | Either capture the scans before the first emission and abort on hard failure, matching the `parse_worktree_list`/`enumerate_branches` treatment, or amend the docstring to state that scan failures degrade rather than abort. | The early-abort contract is a stated design property of this driver; the code and its documentation now disagree. | Compare lines 464-471 (guarded pre-emission captures) with 475-477 (post-emission, non-aborting). |
| Minor | `scripts/bash/cleanup_worktrees_actions_lib.sh` | 402-409 | Hard-failure detection narrowed from "`classify_branch` returned non-zero" to "state == `ANCESTRY_ERROR`". `classify_branch` can return 2 after emitting `HAS_UNIQUE_RESIDUALS` (`cleanup_worktrees_lib.sh:437-443`), so that case no longer takes the `continue` path. Also, `printf '%s\n' "$cb_out"` emits a blank line into a one-record-per-line contract when a branch is absent from the driver output. | Have `classify_all_branches` return a per-branch status (for example an additional internal map keyed by name) rather than only a maximum rc, and guard the `printf` on a non-empty `cb_out`. | No deletion is unlocked today, because `HAS_UNIQUE_RESIDUALS` is not on the allowlist and the driver still propagates a non-zero rc, so this is latent rather than active. | Diff of `run_apply`; `select_cherry_pick_candidates` failure path at `cleanup_worktrees_lib.sh:437-443`. |
| Minor | `scripts/bash/cleanup_worktrees_scan_helper.sh` | 82-89 | spec.md states that a `WARN\|registration-lost` candidate whose `.git` file cannot be read is "skipped silently". `scan_helper_gitdir_target_exists` returns `0` for a missing, unreadable, or malformed pointer file, so such a directory is reported as registration-lost instead of skipped. | Emit a third token (for example `NA`) for "pointer present but unreadable" and have `scan_registration_loss` skip it, since it already skips any value that is neither `0` nor `1` (line 266). The tuple contract already permits `NA`. | The never-blocking half of the contract holds; the skip half does not, producing a false-positive advisory line on an unreadable file. | `grep -m1 '^gitdir:' ... \|\| line=""` then `[[ -z $target ]]` prints `0`. `scan_registration_loss` already tolerates `NA` at line 266. |
| Minor | (process) `artifacts/pr_context.summary.txt` | "Close candidates" section | The regenerated PR context lists `#545` and `#630` under "Auto-close issues (author asserted)". Neither is fixed by this branch; both appear in spec.md only as explicitly out-of-scope references. | Ensure the PR body's autoclose list is `#631` only before opening the PR. | An incorrect autoclose would close two unrelated epic children on merge. | `artifacts/pr_context.summary.txt`, regenerated at head SHA `02ce5ee` during this review; spec.md "Out of scope / non-goals" names both. |
| Info | `docs/features/.../plan.2026-09-06T23-03.md` | 153, 167, 174, 231, 269, 301, 327, 406, 421, 522, 530, 599-645 | 18 tasks are unchecked. Eleven of them (the Phase 1-7 test tasks) are in fact delivered: the named test files, `@test` blocks, and fixture directories all exist and the corresponding tests pass in CI. The genuinely outstanding ones are P2-T3 (see the Major row above) and all of Phases 10 and 11, whose evidence artifacts do not exist. | Reconcile the checklist: check off the delivered Phase 1-7 tasks, and treat P2-T3, P10, and P11 as real outstanding work. | The checklist currently understates delivery and, more importantly, hides which three items are actually outstanding. | Cross-check of each unchecked task against the tree and against the CI test tally (321 -> 335 = exactly the 14 `@test` blocks the Phase 1-7 tasks describe). |
| Info | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 317-463 | `classify_all_branches` is 147 lines with four associative arrays, a nested probe loop, and two ordering phases; its correctness argument lives in a 39-line prose comment. That prose argument is the one that turned out to be wrong. | When remediating the Blocker, consider extracting the ancestry-graph construction from the verdict-inheritance decision so the inheritance rule is small enough to state and test as a unit. | Not a defect on its own, but the function's size and prose-carried invariant are why the defect was hard to see in review. | Read of lines 317-463. |

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- **Correct structural placement of the shared driver.** spec.md's Risks section specifically
  warned that implementing the short-circuit only in `run_report`'s formatting layer would break
  apply-mode outcome preservation. The implementation put it in `classify_all_branches` and
  changed both call sites (`cleanup_worktrees_lib.sh:486`, `cleanup_worktrees_actions_lib.sh:389`),
  so the two modes provably share one code path. The design decision is right even though the
  rule that code path carries is not.
- **The scan seam is a faithful copy of an established pattern.** `cleanup_wt_scan_bin`
  (lines 42-59) reproduces `cleanup_wt_git`'s override-then-fallback shape, and the one place it
  deviates — falling back to a bundled implementation rather than a PATH lookup — is documented
  with the reason (no standard binary emits the combined tuple, lines 34-40). Both branches are
  directly tested.
- **Consistent hard-failure discipline.** Every git and scan read that must not silently degrade
  is captured in the parent shell as `out=$(...) || rc=$?` and its non-zero exit is surfaced,
  matching the capture rule documented at `cleanup_worktrees_lib.sh:20-38`. The pairwise probe
  correctly distinguishes exit 1 ("not an ancestor") from exit > 1 ("hard failure") and maps the
  latter to `ANCESTRY_ERROR` with a non-zero driver return, with a dedicated fixture proving it.
- **The `main`-protection carve-out was anticipated.** The author recognized that `main` is an
  ancestor of nearly every unmerged branch and added `cleanup_wt_protected_branches` plus the
  break at line 437 so a protected branch cannot inherit a verdict. The reasoning at lines
  343-348 is correct and well argued. It is the same class of problem as the Blocker; the
  analysis simply stopped at protected branches instead of continuing to merged ones.
- **Test-seam hygiene under a real constraint.** Git refuses to index a path component named
  `.git`, and repository policy forbids creating one at test time. The `CLEANUP_WT_SCAN_GITFILE_NAME`
  seam resolves that without a temporary file and is documented with the reason at
  `cleanup_worktrees_scan_helper.sh:32-40`.
- **Stub extensions are genuinely additive.** Both new keys fall back to their historical bare
  form (`for-each-ref` only for the literal `refs/heads/` pattern, `merge-base.<tip>` for any
  unspecified pair), and the header documentation was updated to match. The narrowing of the
  `for-each-ref` fallback to `refs/heads/` only is the right call: it makes a
  `refs/remotes/`-scoped read that lacks a fixture resolve to empty rather than silently
  replaying branch data.

#### API and safety notes

- No new CLI flag is introduced. The two new environment overrides (`CLEANUP_WT_SCAN_BIN`,
  `CLEANUP_WT_ORPHAN_ROOTS`) are optional and documented in the usage text.
- All four new records are read-only. `grep -nE '\brm\b|rmdir|update-ref|worktree remove|branch -D|--delete|prune'`
  over both new files matches only comment text. Nothing in the new code deletes a directory, a
  ref, or a branch.
- The apply-mode allowlist itself is untouched (`cleanup_worktrees_actions_lib.sh:412-418`,
  still `MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT`). The Blocker changes which
  branches reach that allowlist, not the allowlist.
- `awk -F'|' -v n="$name" '($1 == "BRANCH" || $1 == "CHILD_OF" || $1 == "COMMIT") && $2 == n'`
  is a correct name-scoped filter: all three record types carry the branch name in field 2.

#### Error handling and logging

- Failure messages go to stderr with the failing command and rc
  (`cleanup_worktrees_report_records_lib.sh:81, 86, 176`), consistent with the existing style.
- `scan_registration_loss` follows `check_main_freshness`'s never-blocking precedent: an
  unexpected tuple shape is skipped rather than raised (line 266).
- The `unknown` size fallback exists in both layers (helper line 55, library line 225), so a
  `du` failure cannot silently drop a real orphan. Neither path is covered by a test.
- Two divergences from the documented contract are recorded in the findings table: `run_report`'s
  early-abort property and the unreadable-pointer-file skip.

---

## Reproduction (Blocker)

Scenario constructed against the repository's own checked-in stub
(`tests/fixtures/cleanup_worktrees/stub-bin/git`), no real repository involved. Three branches:
`main` (protected, current), `feature-merged` (tip is an ancestor of `main`, i.e. merged), and
`feature-unmerged` (descends from `main`, has one unique residual commit). Fixture keys:
`merge-base.feature-merged.rc=0` and `merge-base.feature-merged.main.rc=0` (merged, and therefore
an ancestor of the descendant branch as well); `merge-base.feature-unmerged.rc=1`;
`merge-base.main.feature-unmerged.rc=0`; plus the ladder data that resolves `feature-unmerged` to
`NOT_MERGED`.

```
=== BASELINE: per-branch classify_branch (the pre-change driver loop) ===
BRANCH|feature-merged|MERGED_CLEAN
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT

=== NEW: classify_all_branches (the post-change shared driver) ===
BRANCH|feature-merged|NOT_MERGED
CHILD_OF|feature-merged|feature-unmerged
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
=== driver rc=0
```

Apply mode, same scenario, pre-change `run_apply` (from
`git show <base>:scripts/bash/cleanup_worktrees_actions_lib.sh`) versus post-change `run_apply`:

```
=== PRE-CHANGE run_apply ===
WORKTREE|/repo/main|main|main
BRANCH|feature-merged|MERGED_CLEAN
ACTION|branch-delete|feature-merged|OK
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
=== rc=0

=== POST-CHANGE run_apply ===
WORKTREE|/repo/main|main|main
BRANCH|feature-merged|NOT_MERGED
CHILD_OF|feature-merged|feature-unmerged
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
=== rc=0
```

The probe scripts and the fixture were written to the session scratchpad only; nothing was added
to the repository.

---

## Test Quality Audit

The delivered tests are well written as tests: deterministic, isolated, independent,
no temporary files, exact-equality assertions where the record set is closed, and a
comment on every case explaining the fixture shape and the expected outcome. The argv-log
technique used to prove the expensive rungs were skipped (`classification.bats:29-33` explains
why `classify_all()` deliberately omits `2>/dev/null`) is a good fit for a cost-only claim and
is the kind of assertion that is usually missing from performance work.

The gap is not test craft, it is scenario selection. The invariant under test is
"the verdict is unchanged whether or not the short-circuit fires", and neither test constructs a
case where those two verdicts could differ. Both pass vacuously.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_report_records.bats` (6 tests) — positive/negative pairs for all three scan records, each asserting full output equality. Verifies the emission logic thoroughly. Does not cover any error return of the functions it tests.
- `tests/shell/test_cleanup_worktrees_scan_seam.bats` (2 tests) — pins both branches of `cleanup_wt_scan_bin`. Does not cover the "set but not executable" sub-case.
- `tests/shell/test_cleanup_worktrees_scan_helper.bats` (1 test) — drives the real helper against the checked-in `scan_roots/basic` tree and asserts all three directory shapes in one case. Asserts size only as non-empty, correctly, since size is environment-dependent. Never exercises the production default pointer-file name.
- `tests/shell/test_cleanup_worktrees_classification.bats` (4 new tests) — the `CHILD_OF` positive case with argv-log negative assertions is the strongest test in the set; the ancestry-probe-error case is a clean fail-closed check; the outcome-preservation case is the weak one described above.
- `tests/shell/test_cleanup_worktrees_deletion.bats` (1 new test) — apply-mode allowlist check; passes for a reason unrelated to the invariant it names.
- `evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md` — a careful and honest artifact. It correctly records plan drift (five call-site files rather than the three the plan named) and documents the pre/post `NO_DIFF` sweep. Its stated conclusion is accurate; the broader inference drawn from it ("without altering any existing verdict or action") does not follow, because the sweep's reach is bounded by the pre-existing fixture set.
- `evidence/qa-gates/skill-md-mirror-contract.2026-09-06T23-03.md` — records the push-down contract test passing plus an independent `git diff --no-index` check. Independently re-verified here by `md5sum`: both SKILL.md copies hash to `c6353060b287c20249addf4d3d2175ea`.
- `evidence/baseline/*` — four pre-change baseline artifacts with commands, exit codes, and the 94.2% coverage figure. Complete and well formed.
- **Absent:** `evidence/regression-testing/stub-git-backward-compat.*.md`, `evidence/other/file-size-cap-verification.*.md`, `evidence/other/ac11-generic-detection-confirmation.*.md`, and all four `evidence/qa-gates/final-*.md` artifacts.

### Quality assessment prompts

- **Determinism:** strong. Every git read is stubbed via `CLEANUP_WT_GIT_BIN`; every filesystem read via `CLEANUP_WT_SCAN_BIN`; the one test that exercises the real helper uses a checked-in fixture tree and asserts only shape-stable fields. No clock, RNG, sleep, or network.
- **Isolation:** strong. Each test runs its function in a fresh `bash -c` subshell with a per-test scenario directory. The `CHILD_OF` tests drive the driver directly rather than through `run_report`, separating the short-circuit from report formatting.
- **Speed:** 335 tests in 299s under kcov instrumentation, which dominates. Acceptable for a CI-gated suite.
- **Diagnostics:** good. Exact-equality assertions produce full expected-versus-actual output; the negative argv-log assertions name the exact stub key that must be absent.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credential, token, or URL literal in any changed file. |
| No unsafe subprocess or command construction | PASS | The scan helper is invoked as `"$bin" scan-dirs "${roots[@]}"` (or `bash "$bin" ...`) with properly quoted array expansion; no `eval`, no unquoted expansion into a command position, no string-built command line. `shellcheck -x` returns zero diagnostics across all changed files. |
| Input validation at boundaries | PASS | The override seam requires the path to be both non-empty and executable before use (`cleanup_wt_scan_bin:52`); scan tuples are validated field-by-field before emission (empty path skipped, `has_gitfile` and `target_exists` matched against exact literals rather than truthiness); ref names are validated against the `refs/remotes/` prefix and a non-empty namespace before use. |
| Error handling remains explicit | PARTIAL | Hard failures are captured and surfaced everywhere they should be, and the exit > 1 versus exit 1 distinction on the ancestry probe is handled correctly. Two documented contracts are not honored in code: `run_report`'s early-abort property and the unreadable-pointer-file skip. |
| Configuration / path handling is safe | PARTIAL | Path normalization reuses the existing `normalize_wt_path`, and the pointer-file target is resolved relative to its own directory when not absolute (`scan_helper_gitdir_target_exists:91-93`), which is correct. The `.claude/worktrees` root is CWD-relative, which is not. |
| No destructive operation added | PASS | No `rm`, `rmdir`, `git worktree remove`, `git branch -D`, `git update-ref`, or prune call exists in either new file; the apply-mode allowlist is byte-for-byte unchanged. |
| Deletion behavior unchanged | FAIL | Not because a new deletion was added, but because an existing one was removed: a `MERGED_CLEAN` branch that is an ancestor of a `NOT_MERGED` branch is no longer deleted. See the Blocker. |

---

## Research Log

No external research was required. All findings are derived from the branch diff, the
repository's own policy files (`.claude/rules/general-code-change.md`,
`general-unit-test.md`, `quality-tiers.md`, `shell.md`), the feature folder's spec and evidence
artifacts, direct execution of the changed and pre-change bash against the repository's checked-in
test stubs, local `shfmt`/`shellcheck` runs, and the recorded GitHub Actions run 34151370364 with
its uploaded coverage artifact.

---

## Verdict

The feature is close to done and the parts that are done are done well. The record types are
correct, the seam design is right, the tests are clean and deterministic, the documentation and
its extension mirror are exact, and the toolchain is green with coverage comfortably above the
floor. The `CHILD_OF` optimization was also placed in the one structural location that spec.md
identified as necessary for apply-mode safety.

It is not mergeable as written. The inference rule inside that correctly-placed driver is
logically invalid, and its practical effect is that the tool stops reporting and stops deleting
merged branches whenever any unmerged branch descends from `main` — the ordinary condition in
every active repository, and the exact condition present in the checkout that motivated the
issue. Because the rule is stated the same way in spec.md, remediation is not purely an
implementation fix: the acceptance criterion and the spec's stated invariant need to be
revisited together with the code, and the performance premise for gap 9c re-examined, since the
sound form of the inference would not fire on the branches the issue actually cites.

Remediate the two Blockers, and address the four Major findings in the same cycle since they sit
in the code and the evidence that the Blocker fix must touch. Details and remediation inputs are
in `remediation-inputs.2026-09-07T14-49.md`.
