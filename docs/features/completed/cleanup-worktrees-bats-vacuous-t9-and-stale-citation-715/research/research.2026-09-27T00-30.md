# Research: cleanup-worktrees bats vacuous T9 assertion and stale citation (#715)

## 1. Current State Analysis

### 1.1 T9 defect — call flow and observability

`tests/shell/test_cleanup_worktrees_deletion.bats:182-191`, test `"delete_candidate refuses the base branch before re-verification"`:

```
run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" \
    bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${ALIB}'; delete_candidate main '' MERGED_CLEAN"
[ "$status" -eq 1 ]
[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]
[[ "$output" != *"merge-base"* ]]          # line 188 — the vacuous assertion
[[ "$output" != *"worktree remove"* ]]
[[ "$output" != *"branch -D"* ]]
```

`delete_candidate` (`scripts/bash/cleanup_worktrees_actions_lib.sh:326-366`) checks the base branch first:

```
if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then
    printf 'ACTION|delete|%s|BLOCKED-PROTECTED-BASE\n' "$name"
    return 1
fi
reverify_delete_eligible "$name" "$state" || return 1
...
```

`reverify_delete_eligible` (`cleanup_worktrees_actions_lib.sh:247-279`) calls `classify_branch "$name"` (`cleanup_worktrees_lib.sh:315-450`), whose first rung after the protected-set check is `classify_ancestry` (`cleanup_worktrees_lib.sh:59-80`):

```
cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1 || rc=$?
```

The `>/dev/null 2>&1` redirects **both** streams of the call to the stub. The stub (`tests/fixtures/cleanup_worktrees/stub-bin/git:106-107`) writes its argv record only to its own stderr (`printf 'stub-git: %s\n' "$*" >&2`), and that fd is exactly the one `classify_ancestry` discards. Confirmed: no other channel records the call (no env-var log path, no side file — the stub is documented at lines 2-8 as writing "nothing to disk"). Consequently `[[ "$output" != *"merge-base"* ]]` is true whether or not `merge-base` ran, for any caller that redirects the call the same way `classify_ancestry` does.

### 1.2 Why an "observable merge-base" fix cannot satisfy the AC as literally stated

`classify_branch` never reaches `classify_ancestry` for the base branch, independent of `delete_candidate`'s own guard. `compute_protected` (`cleanup_worktrees_enumerate_lib.sh:171-235`) unconditionally emits `protected-branch|<CLEANUP_WT_BASE_BRANCH>` (line 212-213, guarded only by "unless the current branch already equals the base," in which case the current-branch line at 207-209 already names it). `classify_branch` line 368 checks `prot_branch[$name]` before ever calling `classify_ancestry`. `CLEANUP_WT_BASE_BRANCH="main"` (`cleanup_worktrees_enumerate_lib.sh:169`).

Fixture evidence for `base_not_checked_out` (`tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/rev-parse.abbrev-ref-HEAD.out` = `chore-cleanup`): `compute_protected` succeeds and always classifies `main` as `PROTECTED_CURRENT` in this fixture, regardless of anything `delete_candidate` does.

Consequence: if the protected-base guard in `delete_candidate` is moved to *after* `reverify_delete_eligible`, `reverify_delete_eligible("main", ...)` still resolves `classify_branch("main")` to `PROTECTED_CURRENT` (not on the delete-eligible allowlist), prints `ACTION|delete|main|BLOCKED-REVERIFY`, and returns 1 — **before `classify_ancestry` (and therefore `merge-base`) is ever reached**. `merge-base --is-ancestor` is not called under either the current code or the named mutation for this scenario. No channel — real redirection fix, stub change, or function-override spy — can make a call observable that is never issued. This is independent of the redirection defect in section 1.1; it is a second, deeper reason the literal AC1 wording ("assert absence of a merge-base call ... so the assertion fails if the guard is moved") cannot be honestly implemented by making `merge-base` itself observable.

What *does* change under that mutation is the first call inside `classify_branch`: `compute_protected` issues `cleanup_wt_git rev-parse --abbrev-ref HEAD` via a plain, unredirected command substitution (`cleanup_worktrees_enumerate_lib.sh:196`: `current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?`), and `classify_branch` captures `compute_protected`'s own output the same way (`cleanup_worktrees_lib.sh:341`: `cpout=$(compute_protected) || cprc=$?`). Neither capture redirects stderr, so the stub's `stub-git: rev-parse --abbrev-ref HEAD` line reaches the shell's real stderr and, under `bats run`, merges into `$output`. Today (guard-first order) this call never fires in the T9 test, because `delete_candidate` returns before calling `reverify_delete_eligible` at all — no git call of any kind occurs. Under the named mutation, this call would be the very first observable side effect of the now-earlier `reverify_delete_eligible`.

### 1.3 Stale citation and full inventory (issue #2)

`cleanup-worktrees.sh`'s `--clear-disposable` pre-pass (`main()`, comment at line 167, assignment `CLEANUP_WT_CLEAR_DISPOSABLE=1` at **line 197** today) is cited in `tests/shell/test_cleanup_worktrees_dirt_clear.bats:14` as `scripts/bash/cleanup-worktrees.sh:145` — stale by 52 lines.

Full inventory (`## Numeric Derivation Evidence` below) found exactly three `file.sh:NN` / `file.bats:NN` citations across every `tests/shell/test_cleanup_worktrees_*.bats` file, and all three sit inside the same header comment block (lines 1-48) of `test_cleanup_worktrees_dirt_clear.bats`:

| Line | Citation | Status |
|---|---|---|
| 14 | `scripts/bash/cleanup-worktrees.sh:145` | **Stale** — actual line is 197 |
| 21 | `tests/shell/test_cleanup_worktrees_deletion.bats:47` | Accurate — verified against current file (the `run env ... CLEANUP_WT_STUB_SCENARIO="${SCEN}/unmerged"` line of the test `"a candidate whose re-verification flips is blocked before any branch delete"` is at line 47 today) |
| 39 | `tests/shell/test_cleanup_worktrees_deletion.bats:47` | Accurate, same target as above |

No other `test_cleanup_worktrees_*.bats` file contains a `file.sh:NN` or `file.bats:NN` citation.

## 2. Candidate Approaches

### 2.1 T9 assertion fix

Four candidates were evaluated (per delegation prompt):

**(a) Function-override spy inside the `bash -c` driver.** Redefine `cleanup_wt_git` (or `classify_ancestry`) after sourcing, echoing a sentinel on a non-redirected fd when a `merge-base --is-ancestor` argv is seen. Rejected: (1) no repository precedent — a search of every `.bats` file in `tests/` for a function-redefinition/spy idiom (`grep` for bare `name() {` redefinitions, `>&3`, `SPY`/`spy_log` tokens) found none; every existing `.bats` helper function is a driver/setup helper, never a redefinition of a sourced production function. (2) It is moot: per §1.2, `merge-base` is never called for `main` in this scenario regardless of guard placement, so a spy on `merge-base` specifically still could not observe the named mutation. (3) It adds indirection (a shadowed function definition string inside an already-quoted `bash -c` argument) that conflicts with the "simplicity first" design principle.

**(c) Change the stub to log argv to fd 3 (or another channel the caller's redirection does not swallow).** Rejected: modifies `tests/fixtures/cleanup_worktrees/stub-bin/git`, a fixture shared by every cleanup-worktrees bats suite (deletion, dirt_clear, detached, classification, consolidation, hard_failures, etc. — 11+ files). Any behavior change to the shared stub risks changing observability for scenarios other test files already depend on (e.g., `test_cleanup_worktrees_dirt_clear.bats`'s own "OBSERVABILITY" comment at lines 29-34 explicitly documents and relies on the current redirection behavior of `classify_ancestry`). It is also moot for the same reason as (a): a more observable `merge-base` channel still cannot see a call that never happens in the base-branch case.

**(b) Assert absence of a different, always-issued, currently-observable call.** Use `rev-parse --abbrev-ref HEAD` (the first call `compute_protected` makes, invoked unconditionally at the top of `classify_branch`, reached via `reverify_delete_eligible`) as the forbidden-call proxy instead of `merge-base`. Confirmed via code reading (§1.2) that: (i) this call is never issued today in the T9 direct-`delete_candidate` driver (no git call precedes the base-branch guard); (ii) it is issued unconditionally, before any protected-set or ancestry decision, whenever `reverify_delete_eligible` (and therefore `classify_branch`) runs; (iii) neither `compute_protected`'s nor `classify_branch`'s capture of it redirects stderr, so it is genuinely visible in `$output` under `bats run`. Zero production-code change. Zero shared-fixture change (the `base_not_checked_out` fixture already carries `rev-parse.abbrev-ref-HEAD.out`, consumed by two other tests in the same file). Under the named mutation (moving the base-branch guard after `reverify_delete_eligible` in `delete_candidate`), `reverify_delete_eligible("main", ...)` runs first, `compute_protected` issues the `rev-parse --abbrev-ref HEAD` call, the line appears in `$output`, and the new assertion fails — directly demonstrating the guard-ordering regression the AC asks for.

**(d) Remove the vacuous line; rely on the indirect `BLOCKED-REVERIFY` vs `BLOCKED-PROTECTED-BASE` ACTION-token pin (already present at line 187).** Honest and zero-risk, but does not add a directly falsifiable "forbidden call" assertion; it only keeps the existing positive-token assertion, which already happens to catch the same mutation (a guard moved after re-verification would print `BLOCKED-REVERIFY` instead of `BLOCKED-PROTECTED-BASE`, failing the assertion at line 187). This is weaker than (b) only in that it offers no second, independent signal.

**Recommendation:** (b), combined with retaining (d)'s existing token assertion as a second, already-present signal. Both are test-only changes to `test_cleanup_worktrees_deletion.bats`; no other file requires modification for this AC.

### 2.2 Citation fix

Two options for AC2:

**Line-number citation replacement.** Keep pointing at a specific line but re-derive the number. Rejected: this reproduces the exact defect the issue reports — line numbers drift with every unrelated edit to `cleanup-worktrees.sh`.

**Stable text anchor.** Cite the function and the assignment target instead of a line number, e.g.: "the `--clear-disposable` pre-pass in `main()` in `scripts/bash/cleanup-worktrees.sh` (the block that sets `CLEANUP_WT_CLEAR_DISPOSABLE=1`)." This survives any line-shifting edit to the file as long as the variable name and function name are unchanged, both of which are the actual objects the comment needs to identify.

**Recommendation:** stable text anchor, keyed on the literal token `CLEANUP_WT_CLEAR_DISPOSABLE=1` inside `main()`, not a line number.

## 3. Behavior Semantics

- T9's forbidden-call assertion must be able to observe the guard-ordering regression named in the issue: moving the protected-base check in `delete_candidate` to after `reverify_delete_eligible` (or removing it and falling through to `reverify_delete_eligible` unconditionally).
- The assertion must not depend on any change to `scripts/bash/cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`, or the shared stub — AC3 requires the full suite to pass in CI "with no production-code change required," and the stub is shared fixture infrastructure other suites already depend on for specific redirection behavior.
- The citation fix must identify the same code object (the flag pre-pass assigning `CLEANUP_WT_CLEAR_DISPOSABLE`) regardless of future line movement in `cleanup-worktrees.sh`.
- Edge case already covered and not to be disturbed: the second base-branch test in the same file (`"delete_candidate refuses the base branch before removing its linked worktree"`, lines 193-199) carries no `merge-base` assertion and needs no change.

## 4. Requirements Mapping

| Acceptance Criterion | Design |
|---|---|
| AC1 — T9 forbidden-call assertion can fail | Replace `tests/shell/test_cleanup_worktrees_deletion.bats:188`'s `[[ "$output" != *"merge-base"* ]]` with an assertion over `"rev-parse --abbrev-ref HEAD"` (candidate (b), §2.1), with an inline comment stating why `merge-base` itself is not a viable signal for this scenario (§1.2) and that this call is `reverify_delete_eligible`'s first, always-issued, unredirected side effect. Retain the existing `BLOCKED-PROTECTED-BASE` token assertion (line 187) as a second, already-present signal. |
| AC2 — stable citation | In `tests/shell/test_cleanup_worktrees_dirt_clear.bats:14`, replace `scripts/bash/cleanup-worktrees.sh:145` with a text anchor naming `main()` and the `CLEANUP_WT_CLEAR_DISPOSABLE=1` assignment (§2.2). Optional, in-scope-by-adjacency: lines 21 and 39 of the same header comment cite `tests/shell/test_cleanup_worktrees_deletion.bats:47` (currently accurate) — since they sit in the identical comment block being edited for AC2, converting them to a text anchor (e.g., naming the test `"a candidate whose re-verification flips is blocked before any branch delete"`) removes a second latent line-drift risk at effectively no extra cost. This is a recommendation, not a requirement of the issue's stated AC2, which names only line 14. |
| AC3 — full suite passes, no production change | Both fixes are test-file-only edits (`test_cleanup_worktrees_deletion.bats`, `test_cleanup_worktrees_dirt_clear.bats`). No change to `scripts/bash/*.sh` or `tests/fixtures/cleanup_worktrees/**`. |

No state model or transition changes are introduced; this is a test-quality fix with no behavior change to the tool.

## Numeric Derivation Evidence

**Claim:** exactly three `file.sh:NN` / `file.bats:NN` line-number citations exist across `tests/shell/test_cleanup_worktrees_*.bats`, all three inside one comment block in one file.

- **Complete Family:** every `file.sh:NN` or `file.bats:NN` line-number citation appearing anywhere in the 18 files matching `tests/shell/test_cleanup_worktrees_*.bats`.
- **Exhaustive Search Scope:** all 18 files returned by `Glob tests/shell/test_cleanup_worktrees_*.bats` (test_cleanup_worktrees_classification.bats, _cli.bats, _consolidation.bats, _deletion.bats, _detached.bats, _dirt_classify.bats, _dirt_clear.bats, _dirt_content_locations.bats, _dirt_failclosed.bats, _dirt_guard_registry.bats, _dirt_regression.bats, _enumeration.bats, _hard_failures.bats, _preserve.bats, _preserve_eol.bats, _preserve_failures.bats, _report_records.bats, _scan_helper.bats).
- **Inclusion Rules:** any line matching a script or test file name immediately followed by `:` and one or more digits (covers both `scripts/bash/*.sh:NN` and `tests/shell/*.bats:NN` forms).
- **Exclusion Rules:** none (an empty result for a file is a legitimate zero-count, not an exclusion).
- **Primary Search Strategy or Query Expression:** `Grep pattern="\.(sh|bats):\d+" path=tests/shell glob="test_cleanup_worktrees_*.bats"` (single combined regex over both suffix families).
- **Primary Member Set:** `test_cleanup_worktrees_dirt_clear.bats:14`, `test_cleanup_worktrees_dirt_clear.bats:21`, `test_cleanup_worktrees_dirt_clear.bats:39`.
- **Primary Count:** 3.
- **Cross-check Search Strategy or Query Expression:** two separate, more specific anchored regexes run independently: `Grep pattern="scripts/bash/[A-Za-z_.-]+\.sh:[0-9]+"` and `Grep pattern="tests/shell/[A-Za-z_.-]+\.bats:[0-9]+"`, same path/glob scope.
- **Cross-check Member Set:** `.sh:` form → `test_cleanup_worktrees_dirt_clear.bats:14`; `.bats:` form → `test_cleanup_worktrees_dirt_clear.bats:21`, `test_cleanup_worktrees_dirt_clear.bats:39`. Union: the same three lines.
- **Cross-check Count:** 1 + 2 = 3.
- **Member-set Comparison:** primary set `{dirt_clear.bats:14, :21, :39}` equals the union of the cross-check sets `{dirt_clear.bats:14} ∪ {dirt_clear.bats:21, :39}`. Identical after normalization (same file, same line numbers, same order). No disagreement.

## 5. Sibling Contention (issue #706 and the parallel run #707-716)

Sibling issue #706 (branch `bug/cleanup-report-registration-lost-false-positive-706`) touches:
- `scripts/bash/cleanup_worktrees_scan_helper.sh`
- `tests/shell/test_cleanup_worktrees_scan_helper.bats` (appended tests)
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/` (new fixture)

The recommended design (§2.1(b), §2.2) touches only:
- `tests/shell/test_cleanup_worktrees_deletion.bats` (line 188 assertion + comment) — text anchor: the `@test` block named `"delete_candidate refuses the base branch before re-verification"`.
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats` (header comment lines 14, and optionally 21/39) — text anchor: the header comment paragraph beginning `"TWO DRIVERS."` and the one beginning `"THE SECOND OCCURRENCE IS THE SUBJECT."`.

Neither file, nor `scripts/bash/cleanup_worktrees_scan_helper.sh`, nor `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`, overlaps with #706's file set. No overlap with `scripts/bash/cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`, or `tests/fixtures/cleanup_worktrees/stub-bin/git` either (those are read, not modified, by this fix). This research did not enumerate the other in-flight items 707-716 individually (out of scope for file evidence gathering); the file-path evidence above is sufficient to confirm no collision with the one sibling explicitly named in the delegation prompt. The spec/plan author should re-run a path check against any other concurrently open cleanup-worktrees branch before merge, using text anchors (function/test names, not line numbers) exactly as listed above so the check remains valid regardless of interleaved edits.

## 6. CI Constraints

- Bats runs only in CI (`ubuntu-latest`) and under WSL locally; per `.claude/rules/shell.md`, Windows must go through WSL.
- CI job: `.github/workflows/ci.yml` → `shell-coverage: uses: ./.github/workflows/_shell-coverage.yml` (unconditional job, no path filter; `ci.yml` triggers on `pull_request: branches: [main, development]`, so a PR from this branch into `main` runs it). `_shell-coverage.yml` step "Run shell-qc test with coverage" (line 54-55) runs `bash scripts/bash/shell-qc.sh test --coverage`, which internally calls `bats tests/shell` (via `find_bats_test_dirs` / `run_test_coverage` in `scripts/bash/shell_qc_lib.sh`) — this single invocation covers every file under `tests/shell`, including both suites named in this issue. There is no separate CI step scoped to only these two files.
- Verification command to cite in the plan: `bash scripts/bash/shell-qc.sh test` (no coverage, matches `.claude/rules/shell.md` toolchain step 4) for local/CI-equivalent verification, and `bash scripts/bash/shell-qc.sh test --coverage` to reproduce the exact CI step.
- Single-file bats invocation: **not supported by the wrapper** (`scripts/bash/shell-qc.sh`'s `test` subcommand accepts only an optional `--coverage` flag and always runs `bats` over the whole `tests/shell` / `tests/bash` directories — confirmed by reading `main()` in `scripts/bash/shell-qc.sh` and `run_test`/`run_test_coverage` in `scripts/bash/shell_qc_lib.sh`). A single file can still be targeted directly with the raw `bats` binary (e.g., `bats tests/shell/test_cleanup_worktrees_deletion.bats`) for local iteration under WSL; this does not go through the wrapper and is not what CI runs, so the wrapper command remains the authoritative gate to cite.
- The issue's own "Command/flags used" field (`npx bats tests/shell`) does not correspond to any `bats` entry in `package.json`; the repository's actual toolchain command is the native `bash scripts/bash/shell-qc.sh test` path with no Node/npx involvement. This is a documentation inaccuracy in the issue, not a repository defect, and does not affect the fix.

## 7. Mutation-Proof Procedure

Because bats only runs under WSL/CI, the mutation-sensitivity of the new AC1 assertion must be demonstrated with a documented one-off edit-and-revert, not a permanent test artifact:

1. Under WSL (or a CI dispatch of the branch), confirm the baseline: `bats tests/shell/test_cleanup_worktrees_deletion.bats` — all tests pass, including the updated T9 test.
2. Apply a temporary, uncommitted edit to `scripts/bash/cleanup_worktrees_actions_lib.sh`'s `delete_candidate`: move the block
   ```
   if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then
       printf 'ACTION|delete|%s|BLOCKED-PROTECTED-BASE\n' "$name"
       return 1
   fi
   ```
   to immediately after the `reverify_delete_eligible "$name" "$state" || return 1` line (this is exactly the mutation named in the issue and in AC1).
3. Re-run `bats tests/shell/test_cleanup_worktrees_deletion.bats` and confirm the T9 test (`"delete_candidate refuses the base branch before re-verification"`) now fails, and that the failure is attributable to the new `rev-parse --abbrev-ref HEAD` assertion (or, if that assertion is not yet reached, to the pre-existing `BLOCKED-PROTECTED-BASE`/`BLOCKED-REVERIFY` token assertion — both should flip together, since `reverify_delete_eligible` now runs first).
4. Revert the temporary edit (`git checkout -- scripts/bash/cleanup_worktrees_actions_lib.sh` or equivalent) before any commit. Record the before/after `bats` output (pass → fail → pass) as the evidence artifact for this fix, per the evidence-and-timestamp conventions, rather than leaving the mutation in the tree.

This procedure requires no new fixture, no new stub, and no permanent code path; it only needs a WSL or CI shell capable of running `bats`.

## Automation Feasibility

Fully automatable, no human interaction required. Both fixes are deterministic, single-file test edits driven by static code reading (no runtime exploration needed beyond what this research already performed); the mutation-proof procedure in §7 is a scripted edit/run/revert sequence executable non-interactively under WSL or CI; verification is the existing `bash scripts/bash/shell-qc.sh test` command with no new tool, credential, or manual judgment call needed.

## Recommendations

- **D1 — T9 assertion mechanism.** Recommend candidate (b): replace the vacuous `[[ "$output" != *"merge-base"* ]]` with an assertion over `"rev-parse --abbrev-ref HEAD"`, the first unredirected call `reverify_delete_eligible` issues via `classify_branch`→`compute_protected`, proven (§1.2) to be absent today and present under the named guard-ordering mutation. Rejected: (a) function-override spy (no repo precedent, moot per §1.2), (c) stub fd change (shared-fixture risk, moot per §1.2).
- **D2 — Retain the existing indirect pin.** Keep the `ACTION|delete|main|BLOCKED-PROTECTED-BASE` token assertion (line 187) alongside the new D1 assertion as a second, independent signal for the same mutation; do not adopt candidate (d) (removal-only) as the sole fix, since it forgoes a directly falsifiable forbidden-call assertion that D1 now provides.
- **D3 — Citation anchor form.** Replace the line-14 citation with a stable text anchor naming `main()` and the literal `CLEANUP_WT_CLEAR_DISPOSABLE=1` assignment in `scripts/bash/cleanup-worktrees.sh`, rather than a re-derived line number.
- **D4 — Citation scope.** Recommend also converting the two `test_cleanup_worktrees_deletion.bats:47` citations at lines 21 and 39 of the same comment block to a text anchor (the target test's `@test` name), since they are in the same comment block already being edited and are exposed to the same future-drift risk, even though they are accurate today and not named by the issue's AC2. Treat this as optional/recommended, not required, if the spec author prefers strict scope adherence.
- **D5 — Verification command.** Cite `bash scripts/bash/shell-qc.sh test` (and `--coverage` to match the CI step exactly) as the plan's local/CI verification command; do not cite a single-file `shell-qc.sh test` invocation, since the wrapper does not support one. Cite raw `bats tests/shell/test_cleanup_worktrees_deletion.bats` only for local fast-iteration under WSL, not as a CI-equivalent gate.
- **D6 — Mutation-proof evidence.** Use the §7 edit/run/revert procedure to demonstrate D1's falsifiability before closing the issue; do not leave the mutated `delete_candidate` in the tree.
