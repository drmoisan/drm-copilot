# Spec: detached-worktree classification and consolidation-branch ordering (Issue #630)

- Issue: #630 (<https://github.com/drmoisan/drm-copilot/issues/630>)
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`
- Branch: `bug/cleanup-worktrees-skips-detached-head-worktrees-630`
- Work mode: `full-bug`
- Epic: `cleanup-merged-worktrees-hardening`, child A (gaps 1 and 6)
- Authoritative research: `research/2026-09-06-detached-worktree-classification-and-consolidation-ordering.md`
  (cited below as "research §N")
- Scope source of truth for the observed gaps: `research/2026-09-06-cleanup-run-observations-user-context.md`

Under `full-bug`, this document is the sole acceptance-criteria source per
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. The `## Acceptance Criteria` section below
is the authoritative list that the executor and the reviewer check off. `user-story.md` in this
folder carries no acceptance criteria.

Where `issue.md` and the research artifact disagree, the research artifact governs. Every such
correction is recorded in `## Research Corrections Adopted`.

---

## Summary

`scripts/bash/cleanup-worktrees.sh` and its libraries never classify or remove a worktree whose
HEAD is detached, and they treat the consolidation branch `documentationandmemories` as
delete-eligible during the window between its creation at `main` and its first commit.

This feature adds a detached-worktree classification and removal path in a new library file,
`scripts/bash/cleanup_worktrees_detached_lib.sh`, and adds a tip-equality pre-check to
`verify_consolidation_merged`. Detached worktrees are classified against `main` using the existing
ladder rungs applied to the worktree HEAD SHA, reported with their state, and removed in apply mode
under the same allowlist, the same same-process re-verification, and the same no-force removal that
govern branch-backed worktrees.

---

## Problem Statement

### Mechanism 1 — apply mode is keyed on branch names, so a detached worktree is unreachable

`run_apply` builds a branch-to-path map and then iterates branches only:

- `scripts/bash/cleanup_worktrees_actions_lib.sh:342-348` builds `wt_of` under the guard
  `[[ -n $wbranch && $wbranch != DETACHED ]] && wt_of[$wbranch]=$wpath` at line 347, so a detached
  registration is never entered into the map (research §Summary, §4.1).
- `scripts/bash/cleanup_worktrees_actions_lib.sh:358-380` iterates `enumerate_branches` output, and
  the sole destructive call site is `delete_candidate "$name" "${wt_of[$name]:-}" "$state"` at
  line 376.

A worktree with no branch has no key in `wt_of` and no entry in `enumerate_branches`, so it never
reaches `delete_candidate` or `remove_worktree_safe`.

Report mode has the mirror-image gap. `run_report`
(`scripts/bash/cleanup_worktrees_lib.sh:445-479`) emits the raw registration line at line 468 and
then classifies branches only at lines 470-477. No classification is ever performed against a
detached HEAD commit. The omission is silent in both modes: no error and no diagnostic is produced
(research §Summary).

The research derived, by two independent query strategies, that the production tool contains
exactly two `WORKTREE|` emission sites — `scripts/bash/cleanup_worktrees_lib.sh:468` and
`scripts/bash/cleanup_worktrees_actions_lib.sh:346` (research `## Numeric Derivation Evidence`,
N1). Both discard the record's `head` field via the `_` placeholder in their `read`, so the new
code must re-read the record with the head bound (research §4.1).

Observed scale: in the 2026-09-06 TaskMaster cleanup run, 30 of 57 registered worktrees had a
detached HEAD and were invisible to apply mode
(`research/2026-09-06-cleanup-run-observations-user-context.md`, gap 1). That figure is the issue
author's run observation and was not re-derived in this repository.

### Mechanism 2 — the consolidation branch is delete-eligible before its first commit

`create_consolidation_worktree` runs
`cleanup_wt_git worktree add "$path" -b "$CLEANUP_WT_CONSOLIDATION_BRANCH" main` at
`scripts/bash/cleanup_worktrees_actions_lib.sh:94`, so at creation the branch tip equals `main`
(research §7.1). `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"` is set at
`scripts/bash/cleanup_worktrees_actions_lib.sh:37`.

`verify_consolidation_merged` (`scripts/bash/cleanup_worktrees_actions_lib.sh:198-216`) decides
solely on `merge-base --is-ancestor "$CLEANUP_WT_CONSOLIDATION_BRANCH" main` at line 206, which
exits 0 for a branch whose tip equals `main`. It therefore prints `MERGED_CLEAN` and returns 0,
which sets `consolidation_ok=0` at line 355, which skips the `BLOCKED-CONSOLIDATION-UNMERGED`
short-circuit at lines 360-363. `classify_branch` independently reaches `MERGED_CLEAN` through its
own ancestry rung (`scripts/bash/cleanup_worktrees_lib.sh:366-371`), so `delete_candidate` at
line 376 removes the consolidation worktree and deletes the branch (research §7.3).

The window opens when the `git worktree add -b ... main` at line 94 returns and closes when the
first commit lands on `documentationandmemories`.

---

## Goals

1. Classify every detached-HEAD worktree registration against `main` on its own HEAD SHA, using the
   existing ladder rungs, and report the resulting state.
2. Remove delete-eligible detached worktrees in apply mode under the same allowlist, the same
   same-process re-verification, and the same non-forced `git worktree remove` used for
   branch-backed worktrees.
3. Leave every non-eligible, protected, dirty, locked, or prunable detached worktree in place, and
   report it.
4. Prevent apply mode from deleting `documentationandmemories` or its worktree while the branch tip
   equals `main`, without blocking the documented post-merge cleanup step.
5. Deliver the change with bats coverage driven through the existing stub seam and checked-in
   fixtures, no temporary files, and no shell file in `scripts/bash/` exceeding 500 lines.

---

## Non-Goals

The following belong to sibling children of the `cleanup-merged-worktrees-hardening` epic and are
explicitly out of scope here. This child introduces no code and no acceptance criterion for any of
them.

- **The dirt classifier and the `DIRTY|` line vocabulary (child C, issue 902, gap 2).** This child
  introduces no `DIRTY|` producer of its own and does not modify `remove_worktree_safe`
  (`scripts/bash/cleanup_worktrees_actions_lib.sh:252-279`). It consumes that function as an opaque
  contract: path in; `OK` or `BLOCKED-DIRTY` and return code 0 or 1 out (research §5.3). The
  `--clear-disposable` flag is child C's.
- **Report-mode orphan directory, stale ref, `CHILD_OF`, and `WARN|registration-lost` records
  (child B, issue 901, gaps 7, 9c, 9d).**
- **The removal manifest and the worktree-removal hook (child D, issue 903, gaps 3 and 9a).**
- **`PRESERVE` consolidation of untracked files (child F, issue 904, gap 5).**
- Patching consumer-repository copies of the skill or scripts. All changes land in `drm-copilot`
  and reach consumers through the existing push-down mechanism (epic Shared Design Constraint 1).
- Unifying the locked-worktree result token across the branch-backed and detached paths. See
  `## Known Limitations`, L2.

---

## Behavioral Contract

### Report line: worktree registrations

**Before.** One shape for every registration, emitted at
`scripts/bash/cleanup_worktrees_lib.sh:468` and `scripts/bash/cleanup_worktrees_actions_lib.sh:346`:

```
WORKTREE|<path>|<branch-or-DETACHED>|<flags>
```

Documented at `.claude/skills/cleanup-merged-worktrees/SKILL.md:66`, restated non-normatively at
`scripts/bash/cleanup_worktrees_lib.sh:43` and `scripts/bash/cleanup-worktrees.sh:44`.

**After.** Two shapes. A branch-backed registration keeps the existing four-field record unchanged:

```
WORKTREE|<path>|<branch>|<flags>
```

A detached candidate is emitted once, by the new code, as a five-field record:

```
WORKTREE|<path>|DETACHED|<state>|<flags>
```

The first four fields are exactly the shape `issue.md` names, so any prefix or substring assertion
written against `WORKTREE|<path>|DETACHED|<state>` matches unchanged. The fifth field preserves the
`locked` and `prunable` flags, which apply mode treats distinctly and which a report consumer
otherwise could not see before running `--apply` (research §4.3, R1). This settles research R1 in
favour of the five-field form.

The emission is a **replacement, not an addition**: the loops at
`scripts/bash/cleanup_worktrees_lib.sh:465-469` and
`scripts/bash/cleanup_worktrees_actions_lib.sh:343-348` skip detached candidates so that exactly one
`WORKTREE|` record is produced per detached registration.

**Detached state vocabulary.** `<state>` is one of the following tokens, produced by applying the
existing ladder rungs to the worktree HEAD SHA against `main` (research §1.4):

`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`,
`HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, `ANCESTRY_ERROR`.

Note that `.claude/skills/cleanup-merged-worktrees/SKILL.md:61-62` omits `ANCESTRY_ERROR` from the
documented `BRANCH|` state list even though `classify_branch` emits it. The detached bullet added by
this feature lists `ANCESTRY_ERROR` explicitly.

**Detection predicate.** A registration is a detached candidate when its `flags` field contains
`detached` and contains neither `main` nor `bare`. Testing `branch == DETACHED` is not sufficient:
`parse_worktree_list` writes the literal `DETACHED` into the branch field whenever the branch
accumulator is empty (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:115-116`), which is also true
of a bare-repository stanza, and a local branch literally named `DETACHED` would produce the same
branch field with no `detached` flag (research §2.3).

**Record ordering.** Detached records are emitted in `parse_worktree_list` order, which is
`git worktree list --porcelain` order. The tool does not sort `WORKTREE|` records today, so this
introduces no new nondeterminism; no sort is added (research R6).

### ACTION lines: apply-mode results

**Before.** The research derived, by two independent query strategies, the complete set of result
tokens emitted today: `OK`, `FAILED`, `SKIPPED-BRANCH`, `CONFLICT`, `BLOCKED-DIRTY`,
`BLOCKED-REVERIFY`, `BLOCKED-CONSOLIDATION-UNMERGED`. A dedicated zero-match search confirmed that
`BLOCKED-LOCKED`, `--force`, and `worktree prune` appear nowhere in `scripts/bash/`
(research `## Numeric Derivation Evidence`, N2).

**After.** `BLOCKED-LOCKED` is a **new** ACTION result token introduced by this feature. `--force`
and `git worktree prune` remain absent from `scripts/bash/` after the change.

Detached-path outcomes:

| Detached state / condition | Apply-mode behavior |
|---|---|
| `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, clean, unlocked, not prunable | Re-verify in-process, then `git worktree remove <path>` with no force. `ACTION\|worktree-remove\|<path>\|OK` on success. |
| Same states, but the removal fails and `git -C <path> status --porcelain` reports content | `DIRTY\|<path>\|<status-line>` per line, then `ACTION\|worktree-remove\|<path>\|BLOCKED-DIRTY`, return 1. Inherited unchanged from `remove_worktree_safe`. |
| `flags` contains `locked` | `ACTION\|worktree-remove\|<path>\|BLOCKED-LOCKED`, no git command invoked, return 1. |
| `flags` contains `prunable` (and not `locked`) | Report-only. No `git worktree remove`, no `git worktree prune`, no ACTION line. |
| Re-verification returns a state outside the three-token allowlist | `ACTION\|worktree-remove\|<path>\|BLOCKED-REVERIFY`, return 1, no removal. |
| `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT` | No removal, no ACTION line. |
| `ANCESTRY_ERROR` (hard git failure during classification) | No removal, apply return code 1. |

The locked and prunable checks are pure string tests on already-read flags and must precede any git
invocation, so that "no `git worktree remove` was invoked" is observable in the stub argv log
(research §Proposed Design).

**Apply-mode exit code.** A blocked detached removal sets `rc=1` and propagates through
`delete_candidate`/`run_apply` (`scripts/bash/cleanup_worktrees_actions_lib.sh:376`, `:381`) into the
CLI exit (`scripts/bash/cleanup-worktrees.sh:70-72`, `:82`, `:88-92`). This is a visible change: a
checkout with dirty or locked detached worktrees will begin exiting non-zero from `--apply` where it
previously exited 0. This is intended, for consistency with branch-backed behavior, and is recorded
here so it is not later mistaken for a regression (research §6.4, R3).

### Consolidation guard

**Before.** `verify_consolidation_merged` prints `MERGED_CLEAN` and returns 0 whenever
`merge-base --is-ancestor documentationandmemories main` exits 0, which includes the case where the
branch tip equals `main`.

**After.** A pre-check runs before the best-effort `git fetch origin main`:

```
tip_branch = git rev-parse documentationandmemories
tip_main   = git rev-parse main
either capture fails, or either result is empty -> print ANCESTRY_ERROR, return 2
tip_branch == tip_main                          -> print NOT_ANCESTOR, return 1
otherwise                                       -> existing merge-base behavior, unchanged
```

With the pre-check returning `NOT_ANCESTOR`, `consolidation_ok` stays 1 at
`scripts/bash/cleanup_worktrees_actions_lib.sh:351`, the guard at `:360` fires, and the existing
emission at `:361` produces exactly
`ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` followed by `continue`.
**No change to `run_apply` is required for this** (research §7.4).

---

## Research Corrections Adopted

Each item below corrects an assumption carried in `issue.md`. The research artifact governs.

1. **Tip equality, not a zero `rev-list --count`.** `issue.md:74` offers
   `git rev-list --count main..documentationandmemories` as one candidate guard. Research §7.4
   evaluated it against three states and rejected it: the count is also `0` after the consolidation
   PR merges with a merge commit, so a guard on that value would permanently block the documented
   post-merge cleanup step at `.claude/skills/cleanup-merged-worktrees/SKILL.md:113-117`. The
   adopted guard compares `git rev-parse documentationandmemories` against `git rev-parse main` for
   equality. The second option offered in gap 6 — "refuse apply mode while the consolidation
   worktree exists with no commits" — was also evaluated and rejected in research §7.4, because the
   consolidation worktree still exists after the merge, so that form blocks the same documented
   step.
2. **An empty `rev-parse` result is a hard failure, not an equality match.** Research §Test Design
   case 17 and R4 identified that the existing fixture
   `tests/fixtures/cleanup_worktrees/deletion/consolidated_merged/` has no `rev-parse.main` or
   `rev-parse.documentationandmemories` keys, so under the stub both sides resolve to the empty
   string, compare equal, and would wrongly trigger the guard. Both halves of the mitigation are
   required: treat an empty or unresolvable `rev-parse` on either side as `ANCESTRY_ERROR` with
   return 2, and add the two fixture files with distinct values so the scenario models reality.
3. **The detection predicate is the porcelain `detached` flag, not the branch field.** A bare
   stanza also yields a branch field of `DETACHED`
   (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:115-116`; research §2.3). The predicate is the
   `detached` flag together with the absence of the `main` and `bare` markers.
4. **`classify_branch` must not be reused wholesale for a detached HEAD.** Its worktree lookup
   matches on `wbranch == "$name"` (`scripts/bash/cleanup_worktrees_lib.sh:353-360`), and a detached
   record's branch field is the literal `DETACHED`, so `wt_norm` stays empty, the `prot_path` half of
   the test at `:361` is skipped, and the caller's own detached worktree would escape
   `PROTECTED_CURRENT`. It also emits into the `BRANCH|` namespace and its final rung fabricates
   SHA-keyed `COMMIT|` records that `cherry_pick_candidates` would misread
   (`scripts/bash/cleanup_worktrees_actions_lib.sh:127`, `:129`). Research §1.3. Protection for a
   detached candidate is therefore by normalized path against `compute_protected`'s
   `protected-path|` records (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:212`, `:214`;
   research §3). The four ladder rungs themselves accept a bare committish and are reusable
   (research §1.2).
5. **`BLOCKED-LOCKED` does not exist today.** Research N2 confirmed, by a dedicated zero-match
   search over `scripts/bash/`, that `BLOCKED-LOCKED`, `--force`, and `worktree prune` have no
   occurrences. `BLOCKED-LOCKED` is a new ACTION result token this feature introduces; `--force` and
   `git worktree prune` remain absent after the change.
6. **The `main`-behind residual is documented, not fixed.** See `## Known Limitations`, L1.
7. **The push-down mirror is content-identical and covers only the skill text.** See
   `## Design Constraints`, D4.
8. **`format` and `check` print nothing on a clean run.** See `## Verification`.

---

## Design Constraints

**D1 — File-size cap and the new-file requirement.** `.claude/rules/general-code-change.md` caps
every shell file at 500 lines. Current counts (research §9.1):
`scripts/bash/cleanup_worktrees_lib.sh` 479, `cleanup_worktrees_actions_lib.sh` 382,
`cleanup_worktrees_enumerate_lib.sh` 236, `cleanup-worktrees.sh` 92. The 21 lines of headroom in
`cleanup_worktrees_lib.sh` is the binding constraint, so the detached function group ships in a new
file, `scripts/bash/cleanup_worktrees_detached_lib.sh`, sourced last in
`scripts/bash/cleanup-worktrees.sh` after the actions library (research §9.2). Bash resolves
function names at call time, so `run_report` may call a function defined in the later-sourced file.

Changes to existing files are confined to small additive hunks: the two `WORKTREE|` emission loops,
the header contract comment at `scripts/bash/cleanup_worktrees_lib.sh:43`, the first three
statements of `verify_consolidation_merged`, the source block and the report-lines paragraph in
`scripts/bash/cleanup-worktrees.sh` (research §9.3).

**D2 — bats and fixture contract.** Tests live in `tests/shell/*.bats` and drive the checked-in git
stub through `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`
(`scripts/bash/cleanup_worktrees_enumerate_lib.sh:45`, `:47`;
`tests/fixtures/cleanup_worktrees/stub-bin/git:47`). No temporary files and no scratch git
repositories, per `.claude/rules/general-unit-test.md` and `.claude/rules/shell.md:90-93`.

Two stub constraints shape the fixture design (research §8.4): the stub keys `worktree remove` on
the subcommand alone (`tests/fixtures/cleanup_worktrees/stub-bin/git:104`), so a single scenario
cannot contain one succeeding and one failing removal; and the same holds for `worktree-list`,
`for-each-ref`, `worktree-add`, and `fetch`. One scenario per removal outcome is therefore required.

Apply-mode cases must retain stderr so the stub's argv log (written at
`tests/fixtures/cleanup_worktrees/stub-bin/git:45`, before option stripping) merges into `$output`
and negative argv assertions are meaningful. The helper shape is
`tests/shell/test_cleanup_worktrees_deletion.bats:21-24`, not the stderr-discarding shape at
`tests/shell/test_cleanup_worktrees_classification.bats:20-22` (research §8.5).

Because `run_report` and `run_apply` will call a function defined in the new library, the bats
helpers that source only the enumerate and classification libraries must also source the new file.
A `declare -F` soft guard is rejected: it would silently skip detached classification if the
sourcing order regressed, which is the failure mode this feature exists to remove (research §4.4).

**D3 — Coverage denominator.** The kcov include pattern is
`$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash` with `$repo_root/tests` excluded
(`scripts/bash/shell_qc_lib.sh:335-336`), so `scripts/bash/cleanup_worktrees_detached_lib.sh` is in
the coverage denominator and every function in it must be exercised (research §11.3).

**D4 — Push-down mirror.** Exactly one file is mirrored:
`.claude/skills/cleanup-merged-worktrees/SKILL.md` to
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
The bash scripts are **not** in the bundle; a search of the bundled root for
`cleanup-worktrees`/`cleanup_worktrees` returns only that SKILL.md, and the pack manifests contain
no `scripts/bash` reference (research §10).

The governing test is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
which compares the two files with `Path.read_text(encoding="utf-8")` — Python text mode with
universal-newline translation. The enforced requirement is therefore **content-identical**, not
byte-identical. The stricter `read_bytes()` comparison in the same module applies only to the three
`PLANNER_REVIEW_RESOURCE_PATHS`, which do not include this skill. A CRLF/LF divergence would pass
that test and should still be avoided. The epic's Shared Design Constraint 1 says
"byte-identically"; the requirement stated here is the form the test actually enforces.

**D5 — Sibling-collision containment.** The detached logic lives in its own file and its own
function group so that concurrent epic children do not collide on the same file regions
(research §9.4, epic "Dependency Edges"). Specifically: this child does not edit
`remove_worktree_safe` (child C's region), emits no `DIRTY|` line of its own, and confines its
consolidation change to the first three statements of `verify_consolidation_merged` (child F's
region is the cherry-pick and staging path). Its `run_report` insert is a single call appended after
the existing `WORKTREE|` loop, so a textual conflict with child B resolves by concatenation.

**D6 — Guarded-read discipline.** Every git-backed read in the new file is captured in the parent
shell with `|| rc=$?` and fails closed, matching the invariant documented at
`scripts/bash/cleanup_worktrees_actions_lib.sh:19-35`. The new file defines functions only and runs
nothing at source time.

---

## Known Limitations

**L1 — The consolidation guard does not distinguish "behind `main` with zero commits ahead" from the
legitimate post-merge state.** After the consolidation PR merges with a merge commit, the
consolidation branch is strictly behind `main` with zero commits ahead, which is structurally
identical to a freshly created branch whose `main` has since advanced. Neither the tip-equality form
nor the `rev-list --count` form separates them; separating them would require persisting the
branch's creation point (research §7.4). This residual is accepted and documented, not fixed. The
harmful variant — a consolidation worktree holding uncommitted consolidated content — is already
blocked by the non-forced `git worktree remove` and the `BLOCKED-DIRTY` path. A clean, zero-commit
consolidation worktree that is deleted loses nothing `create_consolidation_worktree` cannot
recreate.

**L2 — `BLOCKED-LOCKED` is introduced asymmetrically.** This child adds the token only on the
detached path. A branch-backed locked worktree keeps today's behavior: `git worktree remove` fails,
the status read runs, and the result is reported as `BLOCKED-DIRTY` even though the cause is a lock.
That mislabel is pre-existing and out of scope here. It should be recorded as a follow-up rather
than widening this child (research R2).

**L3 — One live-checkout claim rests on the issue author's observation.** That commit `fb30a9a5`
(the HEAD of the live `base-wt` detached worktree) is an ancestor of `main` is asserted at
`issue.md:26` and `:37` and could not be re-verified during research, which had no shell tool
available (research §12, R8). Everything else about that worktree — its registration, its detached
HEAD, its exact SHA, and the absence of a lock file — was verified directly from the git
administrative files. No acceptance criterion below depends on this claim; every criterion is
verifiable through the stub-driven bats suite.

**L4 — The 30-of-57 and 45/32/7 figures are run observations.** The scale figures in
`## Problem Statement` come from the user-supplied 2026-09-06 run record and were not re-derived
against this repository.

---

## Acceptance Criteria

- [ ] AC1 — Report mode emits exactly one `WORKTREE|` record per detached registration, in the form `WORKTREE|<path>|DETACHED|<state>|<flags>`. Verified by a new bats case in `tests/shell/test_cleanup_worktrees_detached.bats` named `report emits one detached record with MERGED_CLEAN`, running report mode against `tests/fixtures/cleanup_worktrees/scenarios/detached_merged` and asserting that `$output` contains the literal `WORKTREE|/repo-wt/det|DETACHED|MERGED_CLEAN|detached` and that exactly one output line begins with `WORKTREE|/repo-wt/det`.
- [ ] AC2 — The detached state is produced by the existing ladder applied to the worktree HEAD SHA, and a non-ancestor detached HEAD with a unique residual yields `NOT_MERGED`. Verified by a new bats case named `report emits NOT_MERGED for an unmerged detached HEAD` against `tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged`, asserting `$output` contains the literal `WORKTREE|/repo-wt/det|DETACHED|NOT_MERGED`.
- [ ] AC3 — The detached-candidate predicate is the `detached` flag with the `main` and `bare` markers absent, not the branch field. Verified by a new bats case named `is_detached_candidate flag matrix` that calls `is_detached_candidate` directly with no git access and asserts return 0 for each of `detached`, `detached,locked`, `detached,prunable`, and return non-zero for each of `main`, `main,bare`, `main,detached`, `prunable`, and the empty string.
- [ ] AC4 — Branch-backed worktree records keep the four-field shape `WORKTREE|<path>|<branch>|<flags>` unchanged. Verified by a new bats case named `branch-backed worktree records keep the four-field shape` against `tests/fixtures/cleanup_worktrees/scenarios/merged_with_worktree`, asserting `$output` contains the literal `WORKTREE|/repo-wt/feat|feature-wt|`.
- [ ] AC5 — `parse_worktree_list` emits the same records as before the change. Verified by the existing assertions at `tests/shell/test_cleanup_worktrees_enumeration.bats:33`, `:34`, `:41`, and `:48` passing unchanged, with their pinned literals `/repo/main|aaaa0000|main|main`, `/repo-wt/onbranch|bbbb1111|some-branch|`, `/repo-wt/detachedlocked|cccc2222|DETACHED|detached,locked`, and `/repo-wt/pruned|dddd3333|gonebranch|prunable` unmodified in the test source (research §2.2, §4.4).
- [ ] AC6 — Each existing `WORKTREE|` assertion enumerated in research §4.4 continues to pass with its assertion text unmodified: `tests/shell/test_cleanup_worktrees_classification.bats:37`, `:44`, `:108`; `tests/shell/test_cleanup_worktrees_cli.bats:33`, `:61`; `tests/shell/test_cleanup_worktrees_hard_failures.bats:90`, `:107`. Verified by running the full bats suite and confirming no `not ok` line names any of the tests containing those assertions, and by `git diff` showing no change to those assertion lines.
- [ ] AC7 — Apply mode removes a delete-eligible detached worktree with a non-forced `git worktree remove`. Verified by a new bats case named `apply removes a merged detached worktree without force` against `tests/fixtures/cleanup_worktrees/scenarios/detached_merged`, asserting `$output` contains `ACTION|worktree-remove|/repo-wt/det|OK` and contains `worktree remove /repo-wt/det`, and does not contain `--force` and does not contain `worktree prune`.
- [ ] AC8 — Apply mode attempts no removal for a detached worktree whose state is outside the `MERGED_CLEAN`/`MERGED_CONTENT_NEUTRAL`/`MERGED_EQUIVALENT` allowlist. Verified by a new bats case named `apply never touches an unmerged detached worktree` against `tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged`, asserting `$output` does not contain `worktree remove` and does not contain `ACTION|worktree-remove`.
- [ ] AC9 — The caller's own detached worktree is protected by normalized path, not by branch name, and short-circuits before any classification git call. Verified by a new bats case named `the caller's own detached worktree is PROTECTED_CURRENT` against `tests/fixtures/cleanup_worktrees/scenarios/detached_current` (which sets `rev-parse.abbrev-ref-HEAD.out` to `HEAD` and `rev-parse.show-toplevel.out` to `/repo-wt/current`), asserting `$output` contains `WORKTREE|/repo-wt/current|DETACHED|PROTECTED_CURRENT`, does not contain `merge-base --is-ancestor det00005`, and that apply mode against the same scenario emits no `ACTION|worktree-remove` line.
- [ ] AC10 — The main worktree is never a detached candidate. Verified by the `main` and `main,bare` and `main,detached` rows of the AC3 flag matrix returning non-zero, and by no scenario in the new suite producing a `WORKTREE|/repo/main|DETACHED|` line in either mode.
- [ ] AC11 — A dirty delete-eligible detached worktree is blocked without force and reports the git status content. Verified by a new bats case named `dirty detached worktree blocks with DIRTY lines` against `tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty`, asserting `$output` contains `DIRTY|/repo-wt/det|?? untracked-artifact.txt` and `ACTION|worktree-remove|/repo-wt/det|BLOCKED-DIRTY`, does not contain `--force`, and that apply-mode status is non-zero. `scripts/bash/cleanup_worktrees_actions_lib.sh:252-279` is unmodified by this feature, verified by `git diff` on that range being empty.
- [ ] AC12 — A locked detached worktree yields the new `BLOCKED-LOCKED` token and invokes no git removal command. Verified by a new bats case named `locked detached worktree yields BLOCKED-LOCKED and invokes no removal` against `tests/fixtures/cleanup_worktrees/scenarios/detached_locked`, asserting `$output` contains `ACTION|worktree-remove|/repo-wt/det|BLOCKED-LOCKED` and does not contain `worktree remove` and does not contain `worktree prune`.
- [ ] AC13 — A prunable detached worktree is report-only. Verified by a new bats case named `prunable detached worktree is report-only` against `tests/fixtures/cleanup_worktrees/scenarios/detached_prunable`, asserting report mode emits a `WORKTREE|/repo-wt/det|DETACHED|` line and that apply mode against the same scenario produces no `ACTION|worktree-remove` line, no `worktree remove` in `$output`, and no `worktree prune` in `$output`.
- [ ] AC14 — A hard git failure during detached classification maps to `ANCESTRY_ERROR`, performs no removal, and yields a non-zero apply return code. Verified by a new bats case named `a hard git failure maps to ANCESTRY_ERROR with no removal` against `tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error` (`merge-base.det00006.rc` = `128`), asserting `$output` contains `WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR`, does not contain `worktree remove`, and that apply-mode `$status` is non-zero; and by a unit case named `classify_detached_head returns 2 on a hard failure` asserting `$status` equals 2, `$output` contains `ANCESTRY_ERROR`, and `$output` does not contain `MERGED_CLEAN`. Substring form is required rather than equality: the case retains stderr, and the git stub writes one `stub-git: ` argv line to stderr per invocation, so `$output` always carries those lines alongside the echoed token.
- [ ] AC15 — Same-process re-verification blocks a detached removal when the re-check verdict is outside the allowlist. Verified by a new bats case named `reverify_detached_delete_eligible blocks on a flipped verdict` against `tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged`, asserting `$output` contains `BLOCKED-REVERIFY`, `$status` equals 1, and `$output` does not contain `worktree remove`.
- [ ] AC16 — `verify_consolidation_merged` refuses a zero-commit consolidation branch by tip equality, and apply mode emits the block line and deletes nothing. Verified by two cases added to `tests/shell/test_cleanup_worktrees_deletion.bats` against a new fixture `tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/` (with `rev-parse.documentationandmemories.out` and `rev-parse.main.out` both `aaaa0000`): a unit case asserting `$status` equals 1, `$output` contains `NOT_ANCESTOR`, and `$output` does not contain `MERGED_CLEAN` (substring form for the stderr-retention reason given in AC14); and an apply case asserting `$output` contains `ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED`, does not contain `branch -D documentationandmemories`, and does not contain `worktree remove /repo-wt/dm`.
- [ ] AC17 — The rejected `rev-list --count` guard form does not ship, and the post-merge cleanup path is not blocked. Verified by (a) a repository search for `rev-list --count` over `scripts/bash/` returning no match, and (b) the existing assertions at `tests/shell/test_cleanup_worktrees_deletion.bats:74-83` against `tests/fixtures/cleanup_worktrees/deletion/consolidated_merged/` passing unchanged after `rev-parse.main.out` = `aaaa0000` and `rev-parse.documentationandmemories.out` = `dm000001` are added to that fixture directory.
- [ ] AC18 — An empty or unresolvable `rev-parse` on either side of the tip comparison is a hard failure, not an equality match. Verified by a new bats case in `tests/shell/test_cleanup_worktrees_deletion.bats` named `verify_consolidation_merged fails closed on an empty rev-parse` against a scenario in which `rev-parse.main.out` is absent, asserting `$status` equals 2, `$output` contains `ANCESTRY_ERROR`, `$output` does not contain `MERGED_CLEAN` (substring form for the stderr-retention reason given in AC14), and `$output` does not contain `branch -D documentationandmemories`.
- [ ] AC19 — All new coverage runs through the `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seams against newly checked-in fixture scenario directories, with no temporary files and no scratch repositories. Verified by the presence in git of the new suite `tests/shell/test_cleanup_worktrees_detached.bats` and each of the new fixture directories `tests/fixtures/cleanup_worktrees/scenarios/detached_merged/`, `.../detached_unmerged/`, `.../detached_merged_dirty/`, `.../detached_locked/`, `.../detached_current/`, `.../detached_prunable/`, `.../detached_ancestry_error/`, and `tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/`; and by a search of `tests/shell/test_cleanup_worktrees_detached.bats` for `mktemp`, `$BATS_TMPDIR`, `$BATS_TEST_TMPDIR`, and `git init` returning no match.
- [ ] AC20 — `.claude/skills/cleanup-merged-worktrees/SKILL.md` documents the detached record, the new result token, the detached apply-mode behavior, and the consolidation guard. Verified by the file containing the literal `WORKTREE|<path>|DETACHED|<state>|<flags>`, the literal `BLOCKED-LOCKED`, and a sentence in the apply-mode workflow step stating that a consolidation branch whose tip equals `main` is not delete-eligible.
- [ ] AC21 — The push-down mirror is content-identical. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing, which compares `.claude/skills/cleanup-merged-worktrees/SKILL.md` against `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` with `Path.read_text(encoding="utf-8")`.
- [ ] AC22 — `bash scripts/bash/cleanup-worktrees.sh --help` describes the detached record. Verified by the command exiting 0 and its stdout containing the literal `WORKTREE|<path>|DETACHED|<state>|<flags>`.
- [ ] AC23 — No shell file in `scripts/bash/` exceeds 500 lines, and the detached function group ships in a new file. Verified by `awk 'END { if (NR > 500) { print FILENAME, NR; rc = 1 } } END { exit rc }'` (or an equivalent per-file line count) reporting no file over 500 for every file under `scripts/bash/`, and by `scripts/bash/cleanup_worktrees_detached_lib.sh` existing in git and being sourced by `scripts/bash/cleanup-worktrees.sh`.
- [ ] AC24 — The bash toolchain loop completes in a single pass. Verified by, in order: `git status --porcelain -- tools scripts .claude/lib/bash` captured immediately before `bash scripts/bash/shell-qc.sh format` and again immediately after, with both listings recorded verbatim and byte-identical to each other (the porcelain listing is non-empty at that point because this feature has modified tracked files, so an emptiness test would be unsatisfiable; a formatter that rewrote nothing leaves the two listings identical, and one that rewrote something does not); `bash scripts/bash/shell-qc.sh check` exiting 0 with empty stdout and empty stderr (its `shfmt -d` stage prints a unified diff when any discovered file is unformatted, so empty output is the falsifiable observation); and `bash scripts/bash/shell-qc.sh test --coverage` exiting 0, printing a TAP stream with no line beginning `not ok`, and printing a line matching `Bash coverage (lines): NN.N%` whose value is at least 85.0.

---

## Verification

All three toolchain commands run under WSL Ubuntu, per `.claude/rules/shell.md:39` and epic Shared
Design Constraint 4. `bats` and `kcov` are not on the Windows PATH.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh format'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh check'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh test --coverage'
```

Restart from `format` if any stage fails or rewrites a file (`.claude/rules/shell.md:17`).

### What a clean run of each command actually prints

**`format` prints nothing.** `run_format` (`scripts/bash/shell_qc_lib.sh:204-224`) produces output on only two
paths — the no-scripts message at `:213` and the missing-tool block emitted through
`print_missing_tool_block shfmt` at `:218` — and `shfmt -w` rewrites in place without output. Exit code 0 alone is therefore not an
observation that nothing was rewritten. The assertable substitute is
`git status --porcelain -- tools scripts .claude/lib/bash` captured immediately before and
immediately after the `format` run: the two listings are byte-identical when shfmt rewrote nothing
and differ when it rewrote something. An emptiness test is not used, because this feature modifies
tracked files under `scripts/bash` and the listing is non-empty by construction (research §11.5).
Those three paths are the
discovery roots (`.claude/rules/shell.md:48-51`); `tests/shell/*.bats` files are not discovered by
shfmt or shellcheck (`scripts/bash/shell_qc_lib.sh:75-102`) and are exercised by `test` instead.

**`check` prints nothing.** `run_check` (`scripts/bash/shell_qc_lib.sh:164-202`) has only the
no-scripts message at `:174` and the missing-tool block via `:179`/`:183`. `shfmt -d` at `:188`
emits a unified diff only when a discovered file differs, and `shellcheck` at `:194-200` emits
findings only. Empty stdout and stderr with exit code 0 is therefore the positive, falsifiable
evidence that both formatting and lint are clean.

**`test --coverage` prints a TAP stream and a coverage headline.** bats prints `1..N` and one
`ok N <name>` line per case; the observation is that no line begins with `not ok`. The coverage
headline is emitted at `scripts/bash/shell_qc_lib.sh:291`
(`printf 'Bash coverage (lines): %s%%\n' "$percent"`, with `percent` formatted to one decimal at
`:290`), so the exact literal is `Bash coverage (lines): NN.N%`. The threshold is at least 85% line
coverage per `.claude/rules/quality-tiers.md`; kcov does not measure branch coverage for bash, so no
branch-coverage gate applies (`.claude/rules/shell.md:68-70`). The most recent value recorded in this
repository is `Bash coverage (lines): 92.3%`, at
`docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/final-bash-coverage.2026-08-30T20-45.md:19`
(research §11.4).

### Non-toolchain verification

- **Push-down mirror (AC21):** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k bundled_claude_payload_contains_all_repo_runtime_contracts`.
- **CLI help (AC22):** `bash scripts/bash/cleanup-worktrees.sh --help`.
- **File-size cap (AC23):** a per-file line count over `scripts/bash/`.
- **Optional live confirmation (not an acceptance criterion):** the manual notes at `issue.md:82-83`
  ask that a real `--apply` run remove the live `base-wt` registration. Every acceptance criterion
  above is verifiable through the stub-driven bats suite without it (research §Automation
  Feasibility).

### Evidence location

All evidence artifacts produced while verifying this feature are written under
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Paths such as
`artifacts/baselines/`, `artifacts/qa/`, and `artifacts/coverage/` are not used.
