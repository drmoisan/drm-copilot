# Code Review: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Review Date:** 2026-09-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`
**Feature Folder Selection Rule:** Supplied by the caller and confirmed — it is the only active feature folder whose suffix matches the issue number in the branch name (`...-630-r2`), and it holds the scoping docs changed by this branch.
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration` (merge base `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`)
**Head Branch:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` (head `65a56cb94352c2a19c381acf4008837fa84aee69`)
**Review Type:** Initial review
**Work Mode:** `full-bug` — AC source is `spec.md` only

---

## Executive Summary

This branch closes two apply-mode defects in the `cleanup-merged-worktrees` tool. First, a worktree
with a detached HEAD was listed in the report but never classified and never removable, because
classification iterated `enumerate_branches` output and the apply-mode `wt_of` map explicitly skipped
`DETACHED` registrations. Second, the consolidation branch `documentationandmemories` was classified
`MERGED_CLEAN` during the window between its creation at `main` and its first commit, so an apply
pass in that window would delete it.

The fix adds a new 301-line sourceable library, `scripts/bash/cleanup_worktrees_detached_lib.sh`,
holding six functions that classify a detached registration on its own HEAD SHA using the four
existing ladder rungs, emit a five-field `WORKTREE|<path>|DETACHED|<state>|<flags>` record, and
remove delete-eligible detached worktrees under the same allowlist, the same same-process
re-verification, and the same non-forced `git worktree remove` that govern branch-backed worktrees.
The consolidation fix is a 20-line tip-equality pre-check inside `verify_consolidation_merged` that
returns `NOT_ANCESTOR` when the branch tip equals `main`, and `ANCESTRY_ERROR` when either
`rev-parse` is empty or fails.

The evidence reviewed is substantial and honest: 28 evidence artifacts, all in canonical locations,
each recording the exact command, exit code, and — where a substitution was necessary — the
substitution itself. This reviewer independently re-executed the full `tests/shell/` bats suite
(exit 0), the lint gate at head (`sh scripts/bash/shell-qc.sh check`, exit 0 with empty output), the
CLI help contract, the file-size cap, the push-down mirror diff, and the evidence-location
validator; and verified both CI coverage runs with `gh run view`. Implementation quality is high:
the design constraints in `spec.md` are followed exactly, the deliberate non-reuse of
`classify_branch` is correctly reasoned and correctly implemented, and every git-backed read is
parent-shell captured and fails closed.

**What changed:**

- **New (1 file, 301 lines):** `scripts/bash/cleanup_worktrees_detached_lib.sh` — `is_detached_candidate`, `classify_detached_head`, `report_detached_worktrees`, `reverify_detached_delete_eligible`, `remove_detached_worktree`, `apply_detached_worktrees`.
- **Modified (3 files, +41/-3 net on production shell):** one `source` line and usage text in `cleanup-worktrees.sh`; a tip-equality pre-check plus a skip guard and driver call in `cleanup_worktrees_actions_lib.sh`; a contract comment plus a skip guard and driver call in `cleanup_worktrees_lib.sh`.
- **Tests (+18 cases):** a new 166-line 14-case suite plus 3 consolidation cases and 1 CLI case; four existing suites gained only a `DLIB` sourcing link.
- **Fixtures (54 files):** 7 new detached scenarios, 1 new consolidation scenario, 4 added `rev-parse` keys on 2 existing scenarios.
- **Docs (31 files):** `SKILL.md` (+29) and its content-identical push-down mirror, plus `spec.md`, the plan, and 28 evidence artifacts.
- `remove_worktree_safe` — sibling epic child C's region — is byte-unmodified, as the spec's containment constraint D5 requires.

**Top 3 risks:**

1. **Two of the three verdicts that authorize a destructive `git worktree remove` are never produced
   by any test.** `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` are on the delete-eligible
   allowlist, but every one of the seven new fixtures resolves to `MERGED_CLEAN`, `NOT_MERGED`,
   `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`. The removal path is therefore proven for one of three
   entry conditions. Four fail-closed `ANCESTRY_ERROR` branches guarding the same path are also
   unexercised. This is the whole of the 80.6% per-file coverage figure and is the branch's only
   substantive gap.
2. **Apply mode now exits non-zero on checkouts that previously exited 0.** A dirty or locked
   detached worktree sets `rc=1` and propagates to the CLI exit. `spec.md` records this as intended;
   `SKILL.md` and the `--help` text do not mention it. No in-repo automation reads that exit code, so
   the exposure is to a human operator or an out-of-repo script.
3. **Unique work in a detached worktree is retained but never surfaced for triage.**
   `classify_detached_head` deliberately emits no `COMMIT|` records, so a detached HEAD classified
   `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` produces no cherry-pick candidate for the consolidation
   flow. The retention decision is correct and safe; the visibility gap is undocumented.

**PR readiness recommendation:** **Conditional Go** — the implementation is correct and every
toolchain gate passes with 24/24 acceptance criteria verified, but new-file test coverage of 80.6%
falls below the 85% new-code threshold, and the specific uncovered region is the destructive
allowlist, so remediation is required before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/bash/cleanup_worktrees_detached_lib.sh` | `classify_detached_head`, lines ~104-165 | `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` — two of the three states on the delete-eligible allowlist that authorize `git worktree remove` — are never produced by any test. All seven new fixtures resolve to `MERGED_CLEAN`, `NOT_MERGED`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR`. `HAS_UNIQUE_RESIDUALS` is likewise never produced. | Add two stub fixture directories: `detached_content_neutral` (`merge-base.<sha>.rc` = 1, `diff-quiet.<sha>.rc` = 0) and `detached_equivalent` (`merge-base` rc 1, `diff-quiet` rc 1, `cherry.<sha>.out` = `- <sha>`). Add report-mode assertions for both tokens plus an apply-mode assertion that `MERGED_EQUIVALENT` reaches `ACTION\|worktree-remove\|...\|OK` without `--force`. Optionally add `detached_unique_residuals` (cherry emitting both a `-` line and a `+` line) for `HAS_UNIQUE_RESIDUALS`. | The delete-eligible allowlist is the gate on an irreversible action. Proving one of its three entry conditions leaves the other two unverified against a live regression. `.claude/rules/general-unit-test.md`: "Untested critical behavior is not acceptable even if the overall percentage looks good." | Fixture inputs read directly: `tests/fixtures/cleanup_worktrees/scenarios/detached_*/merge-base.*.rc` are `0,0,0,0` (merged set), `1` (unmerged), absent (current), `128` (error). Suite read in full: no case asserts either token. Per-file coverage 80.6% from CI run 34118811332 `shell-coverage/cov.xml`. |
| Major | `scripts/bash/cleanup_worktrees_detached_lib.sh` | fail-closed branches at ~lines 84-89, 118-121, 128-131, 143-146, 216-220 | Five `ANCESTRY_ERROR` / `BLOCKED-REVERIFY` fail-closed branches are unexercised: `compute_protected` hard failure, `CONTENT_NEUTRAL_ERROR`, `CHERRY_ERROR`/`DIFF_TREE_ERROR`, `RESIDUAL_ERROR`, and the `((crc != 0))` half of `reverify_detached_delete_eligible`. Only the rung-1 `merge-base` failure is tested. | Extend `detached_ancestry_error` into a small family, or parameterise a single scenario, so each rung's hard-failure exit is asserted to reach `ANCESTRY_ERROR` with no removal. Note that the branch-backed counterparts already have this coverage in `test_cleanup_worktrees_hard_failures.bats` cases 1-5, which is the pattern to mirror. | These branches exist precisely to stop a git failure from being read as a merge verdict. An untested fail-closed guard on a destructive path is the highest-value thing to test in this file, and the branch-backed side of the same library already sets the precedent. | Read all six functions; cross-checked the five uncovered branches against the 14 test cases and the seven fixture key sets. `tests/shell/test_cleanup_worktrees_hard_failures.bats` cases 1-5 demonstrate the equivalent branch-backed coverage. |
| Minor | `.claude/skills/cleanup-merged-worktrees/SKILL.md` | apply-mode workflow step 5 (added block, ~lines 130-150) | Apply mode's exit code becomes non-zero when a detached worktree is dirty or locked, where the same checkout previously exited 0. `spec.md` records this under "Apply-mode exit code ... a visible change ... recorded here so it is not later mistaken for a regression." The operator-facing skill and `--help` text do not mention it. | Add one sentence to the SKILL.md apply-mode step and to the `cleanup-worktrees.sh` usage text stating that a blocked detached removal sets a non-zero exit status. | `.claude/rules/general-code-change.md` requires a breaking change to be "called out clearly in the change description." The spec is the design record; SKILL.md is what the operator reads at run time. | `scripts/bash/cleanup_worktrees_detached_lib.sh` `remove_detached_worktree` returns 1 on `BLOCKED-LOCKED`; `apply_detached_worktrees` sets `rc=1`; `run_apply` propagates via `apply_detached_worktrees "$wlout" \|\| rc=1`; `cleanup-worktrees.sh:70-92` exits with it. `grep -n "exit\|non-zero\|return code" SKILL.md` returns one unrelated hit. |
| Minor | `scripts/bash/cleanup_worktrees_detached_lib.sh` | `classify_detached_head`, `HAS_UNIQUE_RESIDUALS` and `NOT_MERGED` terminals | A detached worktree carrying unique commits is correctly retained but emits no `COMMIT\|<...>\|UNIQUE\|...` record, so `cherry_pick_candidates` never sees it and the consolidation/triage flow cannot recover that work. The omission is deliberate and correctly reasoned (spec Research Correction 4: reusing `classify_branch` would fabricate SHA-keyed `COMMIT\|` records that `cherry_pick_candidates` would misread), but it is absent from `spec.md` `## Known Limitations` L1-L4 and from `SKILL.md`. | Record it as L5 in `spec.md` and add a sentence to `SKILL.md`, or file a follow-up issue to emit detached residuals in a namespace the consolidation flow can consume safely. Do not widen this child to implement it. | The skill's documented workflow depends on `COMMIT\|...\|UNIQUE` records to route unmerged work into consolidation. A silent blind spot in that routing is exactly the class of defect this feature exists to remove, even though the direction of failure here is safe. | `classify_detached_head` prints only state tokens; `report_detached_worktrees` and `apply_detached_worktrees` print only `WORKTREE\|` records. `cherry_pick_candidates` reads `COMMIT\|` records (`scripts/bash/cleanup_worktrees_actions_lib.sh:127,129`). |
| Minor | `tests/shell/test_cleanup_worktrees_cli.bats` | new case `--help documents the detached worktree record`, lines 65-73 | AC22 names the literal `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` as the thing `--help` must contain; the shipped assertion checks only `ANCESTRY_ERROR`. The stated reason ("bracket-free, single-line literal ... survives reflow") is a robustness argument, but a `[[ "$output" == *"WORKTREE\|<path>\|DETACHED\|<state>\|<flags>"* ]]` test would work: the pattern contains no glob metacharacter and is quoted. | Assert the record literal in addition to the token. | The test named as the AC's verification should assert the AC's literal. As written, the help text could lose the record shape while keeping the state list and the test would stay green. | This reviewer verified the actual requirement directly: `sh scripts/bash/cleanup-worktrees.sh --help` exits 0 and its stdout contains the literal. The AC is satisfied; the automated guard is weaker than the AC text. |
| Minor | `tests/shell/test_cleanup_worktrees_detached.bats` | `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`, lines 111-116 | The case asserts the `BLOCKED-LOCKED` token and the absence of removal argv but does not assert `$status -ne 0`, even though the locked path is the main source of the apply-mode exit-code change described in risk 2. The sibling dirty case does assert non-zero status. | Add `[ "$status" -ne 0 ]`. | The exit-code propagation for the locked path is a documented visible behavior change with no test guarding it. One line closes the gap. | Suite read in full; the dirty case at lines 103-109 includes `[ "$status" -ne 0 ]`, the locked case does not. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` | `run_report` ~line 469, `run_apply` ~line 371 | All branch-backed `WORKTREE\|` records now precede all detached records, whereas previously both interleaved in `git worktree list --porcelain` order. Output remains fully deterministic. | No action. Note it if a downstream consumer ever depends on registration ordering. | Report consumers in this repository match by prefix or substring, not by position, so nothing breaks. The `--help` text's "LC_ALL=C ordered" phrasing was already loose for `WORKTREE\|` records, which have never been sorted. | Both emission loops read; all `WORKTREE\|` assertions across the five suites are substring or prefix based. Full suite exit 0. |
| Info | `scripts/bash/cleanup_worktrees_detached_lib.sh` | `classify_detached_head` line ~83; `reverify_detached_delete_eligible` line ~215 | `compute_protected` is invoked once per detached candidate and re-invoked during re-verification; each call costs three git subprocesses (`rev-parse --abbrev-ref HEAD`, `rev-parse --show-toplevel`, `worktree list --porcelain`). On the 30-detached-worktree checkout described in `issue.md` this is roughly 90 extra spawns in report mode and up to 180 in apply mode. | No action for this child. If a sibling epic child adds a shared protected-set cache, this call site should adopt it. | The cost profile is identical to the pre-existing `classify_branch`, which also recomputes the protected set and the worktree list per branch. This is consistent with the surrounding design, not a regression introduced here. | `classify_branch` (`scripts/bash/cleanup_worktrees_lib.sh:335-353`) performs the same per-item `compute_protected` + `parse_worktree_list` pair. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` | the two `is_detached_candidate "$wflags" && continue` guards | `run_report` and `run_apply` now hard-depend on a function defined in a file sourced after them. Any consumer that sources only the enumerate and classification libraries and calls `run_report` dies with exit 127 under `set -e`. All five in-repo bats helper chains were updated. | No action. | This is the deliberate design (`spec.md` D2 rejects a `declare -F` soft guard because it "would silently skip detached classification if the sourcing order regressed, which is the failure mode this feature exists to remove"). Failing loudly is correct. The contract is documented in the new file's header. | `tests/shell/test_cleanup_worktrees_consolidation.bats` is the one unmodified suite that sources the libs; it calls only `create_consolidation_worktree`, `cherry_pick_candidates`, and `cleanup_consolidation_on_abort`, none of which reach the guard. Full suite exit 0 confirms. |
| Info | branch integration | `epic/cleanup-merged-worktrees-hardening-integration` @ `288ca214` | The base branch has advanced 5 commits since the merge base, and one of those commits edits the same file this branch edits (`.claude/skills/cleanup-merged-worktrees/SKILL.md`, from sibling child 634). | No action; re-check after any further base movement. | A same-file concurrent edit is the epic's stated collision risk. This one is textually disjoint: child 634's hunks land at original lines 104-112, 249-258, and 262-266; this branch's land at 64-72 and 119-124. | `git merge-tree --write-tree 288ca214 65a56cb9` exits **0** — no conflict. |

**No Blocker findings.** Two Major findings, both concerning test coverage of the destructive path
and both closable without production-code change.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- **The new-file decision is structurally forced and correctly executed.** `cleanup_worktrees_lib.sh`
  stood at 479 lines against a hard 500-line cap, leaving 21 lines of headroom. A 301-line function
  group could not go there. The new file keeps the maximum across `scripts/bash/` at 483.

- **The deliberate non-reuse of `classify_branch` is the strongest decision in the change.** The
  header states three independent reasons and each is verifiable in the source: (a) `classify_branch`
  locates a worktree by matching `wbranch == "$name"`
  (`scripts/bash/cleanup_worktrees_lib.sh:353-360`), and a detached record's branch field is the
  literal `DETACHED`, so `wt_norm` stays empty, the `prot_path` half of the test at `:361` is skipped,
  and the caller's own detached worktree would silently escape `PROTECTED_CURRENT` — a
  delete-the-caller's-own-worktree bug; (b) it emits into the `BRANCH|` namespace, which would be
  wrong for a registration that has no branch; (c) its final rung can fabricate SHA-keyed `COMMIT|`
  records that `cherry_pick_candidates` would misread. The chosen alternative — reuse only the four
  ladder rungs, which accept a bare committish, and decide protection by normalized path against
  `compute_protected`'s `protected-path|` records — is the minimal correct response.

- **The detection predicate is right, and the reason it is right is subtle.** Testing
  `branch == DETACHED` would be wrong twice over: `parse_worktree_list`'s `emit_record` writes the
  literal `DETACHED` whenever the branch accumulator is empty
  (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:110-116`), which is also true of a bare-repository
  stanza; and a local branch literally named `DETACHED` would produce the same field with no
  `detached` flag. `is_detached_candidate` tests the porcelain `detached` flag and excludes `main` and
  `bare`, and the eight-row flag matrix test asserts exactly that distinction, including the
  `main,detached` row.

- **The locked and prunable short-circuits precede every git invocation, deliberately.** This makes
  "no removal was attempted" observable as an absent argv line in the stub log rather than inferred
  from a report line. The header comment says so explicitly, and the tests assert the negative argv
  form (`[[ "$output" != *"worktree remove"* ]]`) that this ordering makes meaningful.

- **The tip-equality pre-check runs before the best-effort `git fetch origin main`,** so the blocked
  case makes no network call. Three outcomes, all asserted: equal tips → `NOT_ANCESTOR` return 1;
  either side empty or failing → `ANCESTRY_ERROR` return 2; otherwise the pre-existing merge-base
  behavior, unchanged.

- **The empty-`rev-parse` trap was found before it shipped, and both halves of the mitigation
  landed.** Two empty strings compare equal, so a naive tip-equality test would have fired on any
  fixture lacking `rev-parse` keys — including the existing `consolidated_merged` fixture, which
  would have turned a passing regression test into a false confirmation of the guard. The
  implementation treats empty-or-failed as a hard failure, and the fixtures gained distinct values
  (`aaaa0000` vs `dm000001`). This reviewer read all three consolidation fixture directories and
  confirms the values.

- **The rejected guard form genuinely does not ship.** `git rev-list --count main..documentationandmemories`
  was evaluated and rejected in research because the count is also 0 after the consolidation PR merges
  with a merge commit, which would permanently block the documented post-merge cleanup step.
  `grep -rn "rev-list --count" scripts/bash/` returns no match. Likewise `--force` returns no match,
  and `worktree prune` appears only in a comment asserting it is never invoked.

- **`remove_worktree_safe` is consumed as an opaque contract and is byte-unmodified.** Both diff
  hunks in `cleanup_worktrees_actions_lib.sh` are at old lines 202-207 and 343-351; the function
  occupies old 252-279 and lies strictly between them. This respects the epic's sibling-collision
  containment constraint and means `BLOCKED-DIRTY`, the `DIRTY|` lines, and the non-forced removal
  are inherited rather than duplicated.

- **The `MINUS_PRESENT` signal is read from the already-captured cherry verdict** rather than from a
  second `git cherry` invocation whose exit code would be discarded in a pipeline. The comment says
  so. This is a small point that shows the guarded-read discipline is understood rather than
  pattern-matched.

- **`set -e` interaction is correct.** The `is_detached_candidate "$wflags" && continue` guards sit
  in a `while` loop under the wrapper's `set -euo pipefail`. A command preceding the final `&&` in an
  AND-list is exempt from errexit, so a non-candidate does not abort the loop. Confirmed empirically:
  the wrapper runs to completion and every affected bats case passes.

#### API and safety notes

- Six functions, all `snake_case`, all named to parallel their branch-backed counterparts
  (`reverify_detached_delete_eligible` ↔ `reverify_delete_eligible`; `remove_detached_worktree` ↔
  `remove_worktree_safe`; `report_detached_worktrees` ↔ the `run_report` emission loop).
- All arguments are positional with documented meanings. No hidden global input. `is_detached_candidate`
  is pure, makes no git call, and is tested that way.
- Return-code contracts are stated per function and consistent: `classify_detached_head` returns 0 or
  2; `reverify_detached_delete_eligible` returns 0 or 1; `remove_detached_worktree` returns 0 or 1;
  `report_detached_worktrees` returns the maximum classification return code so a hard failure folds
  into `run_report`'s rc; `apply_detached_worktrees` returns 0 or 1, matching `run_apply`'s existing
  convention of collapsing hard failures to 1.
- The four-field branch-backed record is unchanged, and the detached record's first four fields are
  exactly the shape `issue.md` specified, so any prefix or substring assertion written against
  `WORKTREE|<path>|DETACHED|<state>` still matches. The fifth field adds the `locked` and `prunable`
  markers that a report consumer previously could not see without running `--apply`.
- No secret, credential, or environment value is read or written. No `eval`, no unquoted expansion in
  a command position, no dynamic command construction.

#### Error handling and logging

- Every git-backed read is captured in the parent shell with `|| rc=$?`. There is no path from a hard
  git failure to a `MERGED_*` verdict or to a removal. Traced by hand through all six functions:
  `compute_protected` failure → `ANCESTRY_ERROR`/2; `classify_ancestry` → `ANCESTRY_ERROR`/2;
  `classify_content_neutral` → `CONTENT_NEUTRAL_ERROR` → `ANCESTRY_ERROR`/2;
  `classify_cherry_equivalent` → `CHERRY_ERROR`/`DIFF_TREE_ERROR` → `ANCESTRY_ERROR`/2;
  `classify_residual_commit` → `RESIDUAL_ERROR` → `ANCESTRY_ERROR`/2. In `apply_detached_worktrees`
  a non-zero classification return sets `rc=1` and `continue`s before the allowlist `case`, so an
  error state can never fall through into removal.
- The `compute_protected` guard deserves specific mention: it fails closed rather than degrading to an
  empty protected set. An empty set would silently let the caller's own worktree reach a
  delete-eligible verdict, which is the worst outcome available in this code path. The comment names
  that reasoning.
- The file defines functions only and executes nothing at source time.
- Report lines are the logging mechanism; the module adds one new result token, `BLOCKED-LOCKED`,
  and reuses the existing `DIRTY|`, `BLOCKED-DIRTY`, and `BLOCKED-REVERIFY` vocabulary rather than
  inventing parallel forms.

---

## Test Quality Audit

The verification evidence is unusually complete for its size: 28 artifacts across `baseline/`,
`regression-testing/`, `qa-gates/`, and `other/`, each recording the exact command, exit code, and
working directory, and each stating any substitution rather than presenting a substituted result as
the planned one. The failing-test-first sequence is provable from commit order alone
(`bf0bf088` fixtures → `669e5b88` failing tests → `853f8930` fix), and
`evidence/regression-testing/fail-before-detached-and-consolidation.2026-09-07T14-30.md` records the
18 pre-fix failures that match the 18 post-fix additions (290 → 308).

The gap is not in the evidence discipline; it is in fixture breadth. The seven detached scenarios
were designed one-per-apply-outcome, which is the right axis given the stub's constraint that
`worktree remove` is keyed on the subcommand alone and so a single scenario cannot hold both a
succeeding and a failing removal. But the classification axis was not covered to the same depth:
four scenarios all resolve to `MERGED_CLEAN` because they differ only in flags and dirtiness, leaving
`MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, and `HAS_UNIQUE_RESIDUALS` with no fixture at all.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_detached.bats` — 14 cases, 166 lines. Verifies the five-field
  record, the flag-matrix predicate, four state tokens, all five apply-mode outcomes, and three
  direct unit contracts. Re-executed by this reviewer: 14/14 ok. Gap: no case produces
  `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, or `HAS_UNIQUE_RESIDUALS`, and no case asserts
  non-zero status on the locked path.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — 3 new cases fully covering the tip-equality
  pre-check's three outcomes, plus the pre-existing case proving a genuinely merged consolidation
  branch is still deletable after the pre-check. Re-executed: 9/9 ok in this file.
- `tests/shell/test_cleanup_worktrees_cli.bats` — 1 new case; see the Minor finding on assertion
  strength. Re-executed: 6/6 ok.
- `tests/shell/test_cleanup_worktrees_classification.bats`, `...hard_failures.bats` — `DLIB` sourcing
  only; no assertion text altered. Re-executed together with `...enumeration.bats`: 41/41 ok.
- `evidence/qa-gates/coverage-delta.2026-09-07T14-45.md` — proves the new library is inside the kcov
  include pattern both structurally and empirically, correctly refuses to read kcov's
  `branch-rate="1.0"` placeholder as a measurement, and states the -0.7 delta plainly as a decrease.
  It also asserts that "no per-file gate exists in this repository," which is accurate for
  `quality-tiers.md` but not for the review contract that governs this audit; that disagreement is
  recorded in the policy audit rather than left implicit.
- `evidence/qa-gates/toolchain-single-pass.2026-09-07T14-45.md` — iteration 1, no restart condition
  met at any stage.
- `evidence/qa-gates/final-bash-format.2026-09-07T14-30.md` — uses the correct falsifiable
  observation for a formatter that prints nothing on success: before/after `git status --porcelain`
  listings that are byte-identical, rather than an emptiness test that would be unsatisfiable on a
  branch with modified tracked files.
- `evidence/qa-gates/push-down-mirror.2026-09-07T14-30.md` — independently re-verified here with a
  direct `diff` of the two SKILL.md files, which reported them identical. This matters because the
  governing pytest fails locally on an unrelated pre-existing condition (issue #510, green in CI), so
  the byte-level diff is the stronger evidence for the actual requirement.

### Quality assessment prompts

- **Determinism:** Strong. Every git call is intercepted by the checked-in stub through
  `CLEANUP_WT_GIT_BIN`; scenario data is checked in (41 + 9 tracked fixture files); no wall-clock
  read, no randomness, no network, no temporary file. A zero-match search for `mktemp`,
  `$BATS_TMPDIR`, `$BATS_TEST_TMPDIR`, and `git init` confirms the no-temp-file rule.
- **Isolation:** Strong. Each case spawns its own subshell with its own scenario. The one table-style
  case (`is_detached_candidate flag matrix`) covers eight rows of a pure predicate, which is
  acceptable and keeps the eight rows visibly adjacent.
- **Speed:** Adequate. The 14-case suite completes quickly; the full 308-case directory run exceeds
  600 s under Git Bash on Windows, but that cost is dominated by process spawn overhead in the
  pre-existing corpus, not by this branch's additions. On the Linux CI runner the same suite completes
  within the workflow's normal budget.
- **Diagnostics:** Adequate. Retaining stderr merges the stub's `stub-git:` argv log into `$output`,
  so a failure shows the exact git command sequence that was attempted — genuinely useful. The
  trade-off, correctly documented in the file header, is that every verdict assertion must be
  substring rather than equality. Bare `[[ ]]` tests report only the failed expression, so a
  maintainer must read the source line to learn the expected literal; that matches the pre-existing
  convention in all four sibling suites.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Read the full new library and all diff hunks. No credential, token, key, or environment secret is read, written, or logged. Fixture data is synthetic (`det00001`-`det00007`, `aaaa0000`, `dm000001`, `blobA`/`blobB`). |
| No unsafe subprocess or command construction | ✅ PASS | All git access routes through the existing `cleanup_wt_git` wrapper with separate argv words. No `eval`, no unquoted expansion in command position, no string-built command line. Every variable used as a git argument (`"$head"`, `"$path"`, `"$sha"`) is double-quoted. |
| Destructive action is gated | ✅ PASS | Removal requires: `is_detached_candidate` true, state on the three-token allowlist, not locked, not prunable, and a fresh same-process re-classification still on the allowlist. Any failure at any gate returns 1 and performs no removal. `--force` is absent from `scripts/bash/` and `git worktree prune` is never invoked. |
| Protection of the caller's own worktree | ✅ PASS | Decided by normalized path against `compute_protected`'s `protected-path\|` records, and it short-circuits before any classification git call. The `detached_current` case asserts both the `PROTECTED_CURRENT` record and the absence of `merge-base --is-ancestor det00005` from the stub argv log — the correct falsifiable form for a short-circuit claim. |
| Main worktree is never a candidate | ✅ PASS | `parse_worktree_list`'s `emit_record` always tags the first stanza with the `main` flag; `is_detached_candidate` returns 1 for any flag set containing `main` or `bare`. Asserted by the flag matrix (`main`, `main,bare`, `main,detached` all non-zero) and by the negative assertion in the first report case. |
| Input validation at boundaries | ✅ PASS | Empty flag sets, empty records, and empty `rev-parse` results are all handled explicitly. `is_detached_candidate ''` returns non-zero; both driver loops skip empty records; the consolidation pre-check treats an empty tip on either side as a hard failure rather than an equality match. |
| Error handling remains explicit | ✅ PASS | Every git-backed read is parent-shell captured with `\|\| rc=$?` and fails closed. No broad catch-all. No silent degradation. Traced through all six functions. |
| Configuration / path handling is safe | ✅ PASS | Paths are normalized once via `normalize_wt_path` (backslash→slash, lowercase, single trailing-slash strip) and compared as strings. No path is constructed by concatenation, and no path is passed to a shell for re-parsing. |
| Fail-closed branches are tested | ❌ **FAIL** | Only the rung-1 `merge-base` hard failure is exercised. Five other fail-closed branches on the same destructive path have no test. See the second Major finding. |

---

## Research Log

No external research was required. Every claim in this review is grounded in files inside the
repository or in commands executed against this worktree. The two design questions that could have
required outside input — whether `git cherry` and `git merge-base --is-ancestor` accept a bare
committish in place of a branch name, and whether kcov emits branch coverage for bash — are both
settled inside the repository: the first by the existing rung implementations and their passing
tests, the second by `.claude/rules/shell.md:68-70` and by direct inspection of the uploaded
Cobertura report's uniform `branch-rate="1.0"` placeholder.

---

## Verdict

This is a well-executed bug fix. The two defects it targets are real and were correctly diagnosed;
the design constraints recorded in `spec.md` are followed exactly; the deliberate non-reuse of
`classify_branch` avoids a subtle protection bug that a naive implementation would have shipped; and
the empty-`rev-parse` trap in the consolidation guard was identified during research and mitigated on
both halves before any code landed. The change is contained — one new file, three small additive
hunks in existing files, `remove_worktree_safe` untouched — which matters because four sibling epic
children are extending the same libraries concurrently, and a `git merge-tree` dry run against the
current integration head confirms it still merges clean. Every toolchain gate passes, and this
reviewer independently reproduced the lint gate at head and the full test suite rather than relying
solely on the recorded evidence.

The change is not ready to merge as-is. New-file line coverage of 80.6% is below the 85% new-code
threshold, and — more importantly than the number — the uncovered region is concentrated exactly
where it should not be: `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT`, two of the three verdicts
that authorize an irreversible `git worktree remove`, are never produced by any test, and five
fail-closed guards on that same path are never taken. The branch-backed side of this library already
has the corresponding hard-failure coverage in `test_cleanup_worktrees_hard_failures.bats`, so the
pattern to follow exists in-repo. Closing the gap needs two or three additional stub fixture
directories and roughly six bats cases, with no production-code change and no design revision.

**Recommendation: Conditional Go.** Route the two Major findings and the three Minor findings through
`remediation-inputs.2026-09-07T12-45.md`. The Minor documentation findings (apply-mode exit code,
detached `COMMIT|` blind spot) may reasonably be handled as follow-up issues rather than in this
branch; the two Major coverage findings should be closed here, because the destructive allowlist is
the part of this change that most warrants a regression guard.
