# Research: #756 cleanup-worktrees #631 spec contradiction and untested error paths

- Date: 2026-09-30
- Issue: #756 (bug, work mode minor-audit)
- Scope: preparation only; no production code, test, or fixture was modified.
- Method: file reads and searches only. The Bash tool is disabled in this session, so no test, kcov, or diff command was executed. Every statement below about runtime behavior is derived from reading code and fixtures, not from running them.

Paths below are repository-relative. The #631 folder is `docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/` (it is under `completed/`, not `active/`). Note that issue #756 AC-1 names the `active/` path for that spec; the file is actually under `completed/`. The plan and the executor must edit the `completed/` path.

## 1. CR-R4-01: spec.md contradiction

### 1.1 Governing contract (spec.md, "outcome-preservation" section, lines 202-212)

Verbatim, lines 202-208:

> The pairwise `merge-base --is-ancestor` probe runs **after** classification, so a hard git
> failure of that probe (exit code greater than 1) must not be mapped onto `X`'s verdict: doing so
> would overwrite an already-correct `BRANCH|` line and would itself break the invariant this
> section states. The delivered contract is instead that such a failure emits no `CHILD_OF` record
> for that pair, leaves the branch's own `BRANCH|` line exactly as `classify_branch` produced it,
> and raises the driver's return code to 2, so the failure surfaces in the exit status rather than
> degrading silently to "not an ancestor."

Lines 210-212 (separate, correct case, leave unchanged):

> A hard failure of the ladder's own rung-2 ancestry probe inside `classify_branch` is a separate,
> unaffected case. It still maps to `BRANCH|<name>|ANCESTRY_ERROR` under the fail-closed convention
> documented at `cleanup_worktrees_lib.sh:36-38`.

### 1.2 Contradicting passages (full-file search, `spec.md`)

Searches run over `spec.md`: `ANCESTRY_ERROR|is-ancestor|pairwise|overwrit` and `hard (git )?fail|short-circuit|hard-fail|fail-closed`. Hits for `ANCESTRY_ERROR`: lines 179, 211, 280, 411. Line 179 (verdict-list of "not exactly NOT_MERGED" states) and line 211 are consistent with the delivered code. Lines 280 and 411 contradict it. Line 341 (performance paragraph) is consistent. No other passage of the class exists in `spec.md`.

Passage A, spec.md lines 279-281 (section "Error handling and logging updates"), verbatim:

> - A hard failure in the new pairwise ancestry probe maps to `BRANCH|<name>|ANCESTRY_ERROR`,
>   matching every other hard-failure case in the ladder.

Passage B, spec.md lines 410-414 (section "Test Strategy", bullet "Edge cases and negative scenarios"), verbatim for the contradicting clause at 410-411:

> - Edge cases and negative scenarios: a hard git failure during the new pairwise
>   `merge-base --is-ancestor` probe maps to `ANCESTRY_ERROR`, not a silent "not an ancestor"
>   fallback; an unresolvable directory size is emitted as `ORPHAN_DIR|<path>|unknown` rather than
>   dropped; a `WARN|registration-lost` candidate whose `.git` file cannot be read is skipped
>   silently rather than erroring the whole report.

Passage B additionally prescribes a test that cannot exist: a pairwise-probe failure that yields `BRANCH|<name>|ANCESTRY_ERROR`. Under the delivered code no BRANCH verdict is ever produced from the pairwise probe. The only `ANCESTRY_ERROR` reachable in `classify_all_branches` comes from `classify_branch` (rung 2 and other ladder reads).

### 1.3 Proposed replacement wording

Passage A (replace the two lines 280-281):

> - A hard failure in the pairwise ancestry probe (exit code greater than 1) emits no `CHILD_OF`
>   record for that pair, leaves the branch's own `BRANCH|` line exactly as `classify_branch`
>   produced it, and raises `classify_all_branches`' return code to at least 2. It does not map
>   to `BRANCH|<name>|ANCESTRY_ERROR`; that mapping applies only to a hard failure of the ladder's
>   own rung-2 probe inside `classify_branch` (see the outcome-preservation section).

Passage B (replace only the first clause at 410-411; keep the two remaining clauses verbatim, re-wrapped):

> - Edge cases and negative scenarios: a hard git failure (exit code greater than 1) during the
>   pairwise `merge-base --is-ancestor` probe emits no `CHILD_OF` record for the pair, leaves the
>   branches' `BRANCH|` lines unchanged, and raises the driver's return code to 2, not a silent
>   "not an ancestor" fallback;

Justification: both replacements use the same terms as spec.md 202-208 and the code comment block in `classify_all_branches` ("Any exit above 1 is a hard git failure: it emits no CHILD_OF record for that pair, leaves X's already-correct BRANCH| line exactly as classify_branch produced it ... and raises rc to at least 2"). The code raises rc to at least 2 (`if ((mrc > 1)) && ((rc < 2)); then rc=2`), so "at least 2" is more precise than "2" for the driver as a whole; spec.md 207 says "to 2", which is equivalent for the pair-level effect. Either wording is acceptable; keeping "2" in Passage B matches line 207 exactly.

### 1.4 Other #631 documents

- `user-story.md`: search for `ANCESTRY_ERROR|is-ancestor|pairwise|overwrit` returned no hits. It has no pairwise-failure contradiction. Lines 50-52 use "short-circuit" terminology (a different, stale-terminology class; see 1.5).
- `issue.md` (#631): no `ANCESTRY_ERROR`/pairwise hit; lines 42, 58, 79 use "short-circuit" (historical problem statement, accurate to the original report).
- `research/2026-09-06-report-mode-visibility-gaps-research.md` lines 350-355: states a pairwise hard failure "should likewise map X to ANCESTRY_ERROR". This is a pre-implementation research artifact with the same class of contradiction. Recommendation: leave unchanged (historical research record; AC-1 names `spec.md` only). Record the decision in the plan so a reviewer does not treat it as missed.
- `code-review.2026-09-07T20-15.md` CR-R4-01 (lines 262-274) quotes Passages A and B exactly as above; the quotes match current spec.md text, which confirms spec.md has not changed since review.

### 1.5 Adjacent stale terminology (not the same class; do not absorb)

spec.md lines 28, 107, 153, 194-200, 216, 277, 309, 321, 330, 485-495 still describe a `CHILD_OF` "short-circuit" that skips ladder rungs (for example line 309: "whose `NOT_MERGED` resolution licensed the short-circuit"; lines 194-198 "Because the short-circuit lives inside the shared classification driver"). The delivered code skips no rung (`classify_all_branches` header comment). This is a separate documentation-drift class, outside CR-R4-01 and AC-1 ("the same class" = pairwise hard failure mapping). Flag to the planner as out of scope; AC-1's "search finds no other passage of the same class" is satisfied after Passages A and B are fixed.

## 2. Delivered code contract

File: `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` (line numbers are current HEAD, secondary locators).

### 2.1 Pairwise probe in `classify_all_branches` (lines 346-476)

- Phase 1 (lines 418-426): for every branch from `enumerate_branches`, `cbout=$(classify_branch "$x") || crc=$?`; output stored in `branch_out[$x]`, state read from first `BRANCH|` line field 3 into `branch_state[$x]`; `rc` is the max of `crc` values.
- Phase 2 (lines 430-469): the `not_merged` set is branches whose state equals exactly `NOT_MERGED`. If it has more than one member, the set is `LC_ALL=C` sorted into `probe`; for each ordered pair (x, y), x != y, it runs `cleanup_wt_git merge-base --is-ancestor "$x" "$y" >/dev/null 2>&1 || mrc=$?` (line 454).
  - `mrc == 0`: `hit=$y`, break; a `CHILD_OF|x|y` line is appended to `branch_out[$x]` (line 466).
  - `mrc == 1`: not an ancestor; nothing happens.
  - `mrc > 1` (hard failure): lines 461-463, `if ((mrc > 1)) && ((rc < 2)); then rc=2; fi`. No line is emitted for the pair, no `branch_out`/`branch_state` entry is modified, the loop continues with the next y.
- Phase 3 (lines 470-474): emits `branch_out[$x]` in `enumerate_branches` order; returns `rc` (line 475). The `BRANCH|` line is therefore byte-identical to `classify_branch`'s.
- The probe function is `classify_all_branches` itself (no helper). The hard-failure statement is at line 462 (`rc=2`).
- Failure return: rc = 2 (or higher if any `classify_branch` returned higher; `classify_branch` returns 0 or 2).

### 2.2 `run_report_scans` (lines 306-344)

Scans run, in order:
1. `cleanup_wt_scan_records` (captured once into `recs`, line 323). This calls `cleanup_wt_scan_roots` (line 166, via `done < <(cleanup_wt_scan_roots)`) then the `CLEANUP_WT_SCAN_BIN` seam with `scan-dirs <roots...>`; it returns the scan's rc after printing `cleanup-worktrees: filesystem scan failed (rc=N)` to stderr when rc != 0 (lines 182-185), and returns 0 with no output when the root list is empty (lines 167-169).
2. `scan_stale_refs` (two git reads: `for-each-ref --format=%(refname) refs/remotes/`, then `remote`; returns the git rc on failure, lines 83-92).
3. `scan_orphan_dirs "$recs"` and `scan_registration_loss "$recs"` (only when the scan succeeded). With a supplied argument they never perform a scan and always return 0 (lines 224-226, 251; 288-290, 303). `parse_worktree_list` failure inside `scan_orphan_dirs` is tolerated (`wlrc` ignored, line 229).

Branches:
- Scan-failure branch (lines 324-330): `scanrc != 0` -> `scan_stale_refs || srrc=$?` still runs (STALE_REF does not need scan records); returns `srrc` if `srrc > scanrc` (lines 326-328), else `scanrc` (line 329). No ORPHAN_DIR or registration-lost output.
- Success path (lines 331-343): `rc` = max of `srrc`, `orc`, `lrc`; returns `rc`. The `orc`/`lrc` updates (lines 336-338, 340-342) can only be non-zero if those two functions return non-zero, which they cannot do when given pre-scanned records. So the `rc=$orc` (line 337) and `rc=$lrc` (line 341) assignments are unreachable through any fixture; only `rc=$srrc` (line 333) is reachable by fixture (via `scan_stale_refs` hard failure).

### 2.3 How a scan can be made to fail in tests, with no production change

- Filesystem scan failure: add `scan-dirs.rc` (for example containing `3`) to a scenario directory. The scan stub (`tests/fixtures/cleanup_worktrees/stub-bin/scan`) `respond "scan-dirs"` replays `<scenario>/scan-dirs.out` and exits with `<scenario>/scan-dirs.rc`. No existing scenario defines `scan-dirs.rc` (glob over `scenarios/*/scan-dirs.rc` found none).
- The scan only runs when the root list is non-empty. Either the scenario supplies `worktree-list.out` with a `worktree /repo/main` first stanza (as `report_single_scan` and `orphan_dir_present` do), or the test sets `CLEANUP_WT_ORPHAN_ROOTS=/a/one`.
- `scan_stale_refs` failure: `for-each-ref.refs_remotes_.rc` (key from pattern `refs/remotes/`, sanitized; stub lines 198-213) or `remote.rc` (stub line 357-359).
- Reaching lines 337 and 341 (`orc`/`lrc` maximization): only by redefining `scan_orphan_dirs` / `scan_registration_loss` inside the test's `bash -c` string after sourcing the libraries (function override, for example `scan_orphan_dirs() { return 7; }`). This is a test-only technique and needs no production seam.

## 3. Test harness

### 3.1 How the bats suites drive the library

File `tests/shell/test_cleanup_worktrees_report_records.bats` (132 lines):
- `setup()` resolves `ELIB` (`cleanup_worktrees_enumerate_lib.sh`), `LIB`, `RLIB` (the report records lib), `DLIB`, `DIRTLIB`, `STUB` (`tests/fixtures/cleanup_worktrees/stub-bin/git`), `SCAN` (`.../stub-bin/scan`), `SCEN` (`tests/fixtures/cleanup_worktrees/scenarios`).
- `rr <scenario> <invocation>` (lines 25-31): `run env CLEANUP_WT_GIT_BIN=$STUB CLEANUP_WT_SCAN_BIN=$SCAN CLEANUP_WT_STUB_SCENARIO=$SCEN/<scenario> bash -c "source ELIB && source RLIB && <invocation> 2>/dev/null"`. It sources only ELIB and RLIB, so it cannot run `classify_all_branches` (which calls `classify_branch` from LIB and dirt functions from DIRTLIB). It is sufficient for `run_report_scans`, which uses only `cleanup_wt_git`, `parse_worktree_list`, `normalize_wt_path` (ELIB) and RLIB functions.
- `report_raw <scenario>` (lines 33-42): sources ELIB, LIB, DIRTLIB, RLIB, DLIB and runs `run_report` with stderr retained.
- The classification suite `tests/shell/test_cleanup_worktrees_classification.bats` (273 lines) has `classify_all <scenario>` (lines 29-39): sources ELIB, LIB, DIRTLIB, RLIB and runs `classify_all_branches` with stderr retained, so `stub-git:` argv lines appear in `$output`; and `cb <scenario> <branch>` for `classify_branch`.

### 3.2 Fixture conventions

- Scenario directory: `tests/fixtures/cleanup_worktrees/scenarios/<name>/`. Files: `<KEY>.out` (stdout replay), `<KEY>.rc` (exit code; default 0). Key derivation is documented at the top of `stub-bin/git`.
- `merge-base --is-ancestor <tip> <up>` (stub lines 222-238): tries `merge-base.<sanitized tip>.<sanitized up>` (`.out` or `.rc` present) first; otherwise falls back to bare `merge-base.<sanitized tip>`; if neither exists, stdout empty and exit 0 (meaning "is an ancestor").
  - Therefore the stub DOES support pair-keyed rc files. No change to `tests/fixtures/cleanup_worktrees/stub-bin/git` is needed. `merge-base.<a>.<b>.rc` is already used (for example `child_of_not_merged/merge-base.feature-child.main.rc`).
- `cherry.<branch>.out`, `diff-quiet.<branch>.rc`, `diff-tree.<sha>.out`, `rev-list.<branch>.out`, `rev-parse.<ref>_<path>.out` feed the ladder. `for-each-ref.out` supplies `enumerate_branches` (format `<name> <sha>`), `worktree-list.out` supplies the porcelain listing, `rev-parse.abbrev-ref-HEAD.out` and `rev-parse.show-toplevel.out` feed protection.
- Scan stub: `scan-dirs.out` / `scan-dirs.rc`, record shape `path|has_gitfile|gitdir_target_exists|size`.

### 3.3 Why `child_of_ancestry_probe_error` does not reach the pairwise `rc=2` path

Scenario files: `for-each-ref.out` (feature-child, feature-parent, main), `merge-base.feature-child.rc` = 128, `worktree-list.out`, `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`. In Phase 1, `classify_branch feature-child` reaches `classify_ancestry`, which runs `cleanup_wt_git merge-base --is-ancestor "$tip" main` (`cleanup_worktrees_lib.sh` line 71). The stub key is `merge-base.feature-child.main`; no such file exists, so it falls back to bare `merge-base.feature-child` = 128. `classify_ancestry` returns `ANCESTRY_ERROR`, and `classify_branch` prints `BRANCH|feature-child|ANCESTRY_ERROR` and returns 2 (`cleanup_worktrees_lib.sh` lines 379-382). feature-child's state is `ANCESTRY_ERROR`, so it is excluded from the `NOT_MERGED` set; feature-parent has no other members to pair with (set size <= 1, `${#not_merged[@]} > 1` false at line 436). The pairwise loop never executes, so line 462 is not hit. The test at classification.bats lines 187-196 pins the rung-2 mapping only (its own comment states this), and its `[ "$status" -ne 0 ]` assertion is satisfied by `classify_branch`'s return 2.

### 3.4 Design (a): pairwise hard failure test

New scenario directory (proposed name `child_of_pairwise_probe_error`), a copy of `child_of_not_merged` plus one new file. The existing scenario cannot be edited in place because adding `merge-base.feature-child.feature-parent.rc` there would change the existing CHILD_OF positive test (`child_of_not_merged` is also used by `test_cleanup_worktrees_classification.bats` lines 154-212 and `test_cleanup_worktrees_deletion.bats` line 137).

Files to create, under `tests/fixtures/cleanup_worktrees/scenarios/child_of_pairwise_probe_error/` (contents are verbatim copies of the `child_of_not_merged` counterparts, which were read):
- `for-each-ref.out`: `feature-child cccc4444`, `feature-parent cccc3333`, `main aaaa0000`.
- `worktree-list.out`: `worktree /repo/main`, `HEAD aaaa0000`, `branch refs/heads/main`, blank line.
- `rev-parse.show-toplevel.out`: `/repo/main`. `rev-parse.abbrev-ref-HEAD.out`: `main`.
- `merge-base.feature-child.main.rc`: `1`. `merge-base.feature-parent.rc`: `1`. `merge-base.main.rc`: `1`.
- `diff-quiet.feature-child.rc`: `1`. `diff-quiet.feature-parent.rc`: `1`.
- `cherry.feature-child.out`: `+ dead0002`. `cherry.feature-parent.out`: `+ dead0001`.
- `diff-tree.dead0001.out`: `M<TAB>src/app.py`. `diff-tree.dead0002.out`: `M<TAB>src/child.py`.
- `rev-list.feature-parent.out`: `commit dead0001` then `dead0001|Dan Moisan|2026-07-20T09:00:00-07:00`.
- `rev-parse.feature-parent_src_app.py.out`: `blobbranchAAA`. `rev-parse.main_src_app.py.out`: `blobmainBBB`. `rev-parse.feature-child_src_child.py.out`: `blobchildAAA`. `rev-parse.main_src_child.py.out`: `blobmainCCC`.
- NEW: `merge-base.feature-child.feature-parent.rc`: `128`.

(Copying the complete `child_of_not_merged` file set is the conservative route because the existing scenario is known to drive both branches to exactly `NOT_MERGED` with driver rc 0; the executor should re-read every source file when copying rather than rely on the transcription above, including the tab in diff-tree files.)

Expected behavior, derived from code reading: Phase 1 both branches `NOT_MERGED`, `crc=0`. Phase 2 sorted probe `feature-child, feature-parent`. Pair (feature-child, feature-parent) hits pair key -> rc 128 -> `mrc > 1` -> `rc=2`; no `hit`. Pair (feature-parent, feature-child): pair key `merge-base.feature-parent.feature-child` absent, bare `merge-base.feature-parent` = 1 -> not an ancestor. Output: the two `BRANCH|...|NOT_MERGED` lines (plus any `COMMIT|` lines the ladder emits), no `CHILD_OF|`, return code 2.

Bats test (recommended location: `tests/shell/test_cleanup_worktrees_report_records.bats`, satisfying AC-2's literal file requirement; it needs a new helper because `rr` does not source LIB/DIRTLIB). Proposed helper `classify_all_rr <scenario>`: `run env CLEANUP_WT_GIT_BIN=$STUB CLEANUP_WT_STUB_SCENARIO=$SCEN/$1 bash -c "source ELIB && source LIB && source DIRTLIB && source RLIB && classify_all_branches"` with stderr retained. Assertions:
- `[ "$status" -eq 2 ]`.
- `[[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]` and `BRANCH|feature-parent|NOT_MERGED`.
- `[[ "$output" != *"CHILD_OF|"* ]]` and `[[ "$output" != *"ANCESTRY_ERROR"* ]]` (the verdict is not overwritten).
- `[[ "$output" == *"merge-base --is-ancestor feature-child feature-parent"* ]]` (proves the pair probe ran; the stub logs argv to stderr).
- Optional byte-identity check against `classify_branch` (mirror classification.bats lines 198-212) using `cb`-style call, or skip since the classification suite already covers that invariant.

Tests must contain no temporary files and no real waits (policy in `.claude/rules/general-unit-test.md`).

### 3.5 Design (b): `run_report_scans` scan failure and rc maximization

Fixtures alone suffice. Proposed scenarios, each a small directory with `worktree-list.out` (first stanza `worktree /repo/main`) so `cleanup_wt_scan_roots` yields roots:
1. `report_scan_failure`: `worktree-list.out`, `scan-dirs.rc` = `3`. Invoke `rr report_scan_failure "run_report_scans"`; assert `[ "$status" -eq 3 ]` and `[ "$output" = "" ]` (scan-derived records absent; `2>/dev/null` hides the `filesystem scan failed` message). Covers lines 323-330 (`scanrc` return path, `srrc == 0`).
2. `report_scan_failure_git_higher`: as (1) plus `for-each-ref.refs_remotes_.rc` = `5`. Assert `[ "$status" -eq 5 ]`. Covers lines 326-328 (the `srrc > scanrc` return).
3. `report_scan_ok_stale_ref_failure`: `worktree-list.out`, `for-each-ref.refs_remotes_.rc` = `4`, scan stub default (no `scan-dirs.rc`). Assert `[ "$status" -eq 4 ]`. Covers lines 331-334 (success-path maximization via `srrc`).
4. Optional, to reach lines 337 and 341 (the `orc`/`lrc` updates, unreachable by fixtures as shown in 2.2): a test that overrides `scan_orphan_dirs` and `scan_registration_loss` in the `bats` command text. `rr` accepts an arbitrary second argument, which is placed after the source statements in the `bash -c` string, so a function-definition prefix is possible: `rr <scenario> "scan_orphan_dirs() { return 7; }; scan_registration_loss() { return 9; }; run_report_scans"` and assert `[ "$status" -eq 9 ]`. A variant returning 7 and 0 distinguishes `orc`; this keeps line coverage of lines 337 and 341 without a production change. If the executor prefers to keep the tests free of function overrides, these two lines remain unhit; the library-level 85% line threshold (see 4) is still expected to hold, but AC-5 states "rc-maximization block as executed", so option 4 is recommended to meet it literally.

No production seam is missing. `CLEANUP_WT_SCAN_BIN` and `CLEANUP_WT_GIT_BIN` already make both failure classes injectable. The stub already supports pair-keyed rc files, so `tests/fixtures/cleanup_worktrees/stub-bin/git` and `.../stub-bin/scan` need no change.

## 4. Coverage tooling

- Local entry: `scripts/bash/shell-qc.sh test --coverage`, implemented by `run_test_coverage` in `scripts/bash/shell_qc_lib.sh` (lines 294-376). It runs `bats` per test directory (`tests/shell`, `tests/bash`) under `kcov --include-pattern=<repo>/tools,<repo>/scripts,<repo>/.claude/lib/bash,<repo>/.claude/skills ...`, merges the runs with `kcov --merge`, copies `kcov-merged/cov.xml` to `<out_dir>/cov.xml`, and prints `Bash coverage (lines): NN.N%`. Output directory: `SHELL_QC_KCOV_OUT_DIR`, default `artifacts/pester/kcov`. The include pattern covers `.claude/skills`, so the library under `.claude/skills/cleanup-merged-worktrees/scripts/` is measured.
- CI: `.github/workflows/ci.yml` job `shell-coverage` (line 26) uses `.github/workflows/_shell-coverage.yml`, job `shell-coverage` ("Shell Coverage (Bats + kcov)", ubuntu-latest). It builds kcov v43 (cached), runs `bash scripts/bash/shell-qc.sh check`, then `bash scripts/bash/shell-qc.sh test --coverage`, and uploads `artifacts/pester/kcov/**` as artifact `shell-coverage` (this is where per-line evidence is downloaded from).
- Threshold: policy line coverage >= 85% (`.claude/rules/general-unit-test.md`, `quality-tiers.md`); no bash branch-coverage gate. The script prints the percentage and I found no automated threshold comparison in `shell_qc_lib.sh` or the workflow (searched for `85`, `threshold`; none), so the 85% gate is applied by review against the printed and archived numbers. The report-records lib coverage must not fall from its pre-change value (issue AC-5).
- Confirming a specific line is hit: the merged kcov HTML report (`artifacts/pester/kcov/kcov-merged/index.html` and per-file pages) marks each executable line covered/uncovered; the Cobertura `cov.xml` has `<class filename="...cleanup_worktrees_report_records_lib.sh">` with `<line number="N" hits="H">` entries. Evidence to capture: `hits` greater than zero for the `rc=2` line (462 at current HEAD, may shift) and for lines 324-343 of `run_report_scans` (324-330, 331-343). Since kcov attributes hits to executed lines, a hit on line 462 proves the pairwise hard-failure path ran.
- Local command for this single bats file (agent worktree denies Bash commands whose text contains the words bash, pwsh, or wsl; `sh <file>.sh` and `npx --yes bats` are the permitted routes): `npx --yes bats tests/shell/test_cleanup_worktrees_report_records.bats` from the worktree root (and likewise `tests/shell/test_cleanup_worktrees_classification.bats` if the test is placed there). The libraries and stubs are `#!/usr/bin/env bash` scripts; the test itself spawns `bash -c`, which is internal to the bats file and not part of the command text the guard inspects. Whether `npx --yes bats` resolves on this Windows host is unverified (the tool was not executable in this session); the project memory records `npx` as a permitted route and WSL as the host that runs bats/kcov. If `npx bats` cannot spawn `bash` on Windows, bats evidence comes from CI.
- kcov availability: kcov v43 exists only in WSL Ubuntu (per #631 spec assumptions) and in CI. kcov is not available from the agent worktree, where `wsl` text is denied; state kcov evidence as coming from the CI artifact `shell-coverage` for the PR run. I did not verify local kcov presence in this session.

## 5. Bundle parity and spec edit constraints

- The recommended fix changes no production file under `.claude/` (see section 6), so no bundled mirror edit is required. If the executor nevertheless edits `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`, the mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` must be updated identically (issue AC-6). The mirror exists and contains the same functions (`run_report_scans` at line 306, `classify_all_branches` at line 346, `cleanup_wt_scan_roots` at line 114, matching the source line numbers).
- Enforcement found: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserts byte identity for specific named resources (`test_planner_review_resources_exist_and_are_byte_identical`, `test_handoff_runtime_has_bundle_pack_and_effective_install_parity`), and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs` asserts that every skill folder file is bundled and carried by packs. I found no test that performs a whole-file byte comparison of the cleanup-merged-worktrees scripts, so a production edit without mirroring may not fail a named test, but AC-6 and the #631 spec (line 222: "Every `.claude/**` edit ... is mirrored byte-identically") require the mirror. I did not diff the two library copies (no command execution available); parity at HEAD is unverified.
- New test and fixture files are outside `.claude/` and outside the bundle; no mirroring applies. The skill-folder carriage test applies only to files inside `.claude/skills/<skill>/`.
- `spec.md` edits: the file is under `docs/features/completed/` and is a Markdown documentation file. I found no test or hook in the tests tree that references it (searches of `tests` for `cleanup-merged-worktrees|cleanup_worktrees_report_records_lib` outside `.bats` returned only manifest, hook, and fixture files, none of which reference this spec.md). Markdown files are exempt from the 500-line cap (`general-code-change.md`). Constraints that still apply from repository policy: the `.github/` policy files and `.claude/` runtime are not to be modified by this edit, the evidence location convention applies to any evidence files, and hook enforcement on `completed/` paths was not verified (a PreToolUse hook could restrict edits to a completed feature folder; unverified, flag for the executor).

## 6. Coordination with #741

- `run_report_scans` does not call `cleanup_wt_scan_roots` directly. The call chain is `run_report_scans` (line 323) -> `cleanup_wt_scan_records` (line 152) -> `cleanup_wt_scan_roots` (called at line 166, `done < <(cleanup_wt_scan_roots)`). Only `cleanup_wt_scan_records` would need a call-site change if #741 moves the function. The bats helpers source `ELIB` (`cleanup_worktrees_enumerate_lib.sh`) and `RLIB`, so a function moved into an enumerate library is still defined for the tests provided the test helper sources that library.
- Risk: #741 may change the root derivation (for example split orphan roots), the override environment variable (`CLEANUP_WT_ORPHAN_ROOTS`), or the function location. The planned tests in 3.5 depend on roots being non-empty so the scan stub is invoked.
- Mitigation for test validity either way:
  - Give every new `run_report_scans` scenario a `worktree-list.out` with a `/repo/main` first stanza (same as `report_single_scan`), which any derivation from the main worktree path supports.
  - Additionally export `CLEANUP_WT_ORPHAN_ROOTS=/a/one` through the `rr` invocation string only if the executor confirms #741 leaves that variable unchanged; otherwise rely on the worktree-list derivation alone.
  - Do not assert on the roots passed to the scan stub (the `stub-scan: scan-dirs <roots>` argv line); assert only on return code and emitted records.
  - Do not add tests that call `cleanup_wt_scan_roots` by name; the existing tests (report_records.bats lines 91-118) already do and will be #741's responsibility.
  - Do not edit the library or move `cleanup_wt_scan_roots`; both #741 and this issue touch neither's files if only tests and fixtures are added, which also avoids a merge conflict on the library file. The report_records.bats file is touched by both; expect a textual merge near the `cleanup_wt_scan_roots` tests (lines 91-118) and append new tests at the end of the file to minimize conflict.
- I did not inspect the #741 branch (`bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741`); git commands were unavailable, so its current state is unverified.

## Recommended minimal fix

Files to write (repository-relative); no production file changes:

1. `docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md` (edit Passage A at lines 280-281 and Passage B at lines 410-411 per 1.3).
2. `tests/shell/test_cleanup_worktrees_report_records.bats` (add helper `classify_all_rr`, test (a), and tests for scenarios 1-3 of 3.5, plus optional function-override test 4; file currently 132 lines, stays well under 500).
3. New fixture directory `tests/fixtures/cleanup_worktrees/scenarios/child_of_pairwise_probe_error/` with the files listed in 3.4 (20 copied from `child_of_not_merged`, 1 new `merge-base.feature-child.feature-parent.rc`).
4. New fixture directory `tests/fixtures/cleanup_worktrees/scenarios/report_scan_failure/`: `worktree-list.out`, `scan-dirs.rc` (`3`).
5. New fixture directory `tests/fixtures/cleanup_worktrees/scenarios/report_scan_failure_git_higher/`: `worktree-list.out`, `scan-dirs.rc` (`3`), `for-each-ref.refs_remotes_.rc` (`5`).
6. New fixture directory `tests/fixtures/cleanup_worktrees/scenarios/report_scan_ok_stale_ref_failure/`: `worktree-list.out`, `for-each-ref.refs_remotes_.rc` (`4`).
7. Feature evidence files under `docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/<kind>/` (QA gate output, CI kcov summary).

Scenarios 4-6 could be consolidated (for example a single directory with `scan-dirs.rc` and a second with only the git rc) but separate directories keep each test independent, which matches the `general-unit-test.md` independence rule.

Not needed: any change to `stub-bin/git`, `stub-bin/scan`, the library, or the bundled mirror. Issue AC-1 cites the `active/` path for the #631 spec; it should be treated as `completed/`.

## Testing implications

- Required: format, lint (`shell-qc.sh format`, `shell-qc.sh check`), bats, and coverage per the seven-stage loop in `.claude/rules/general-code-change.md`; bash has no type-check stage. Bats and shell-qc run under WSL or CI; the agent-side route is `npx --yes bats <file>`.
- Fail-before evidence: the new tests should pass at HEAD because they only exercise existing behavior (they are coverage pins). Demonstrating they can fail: temporarily reasoning by mutation (for example, removing line 462 `rc=2` would make test (a) fail on `status -eq 2`; changing line 329 to `return 0` would fail scenario 1). Mutation of production code is out of scope for preparation; suggest executor record the reasoning only.
- Determinism: fixtures and stubs are checked in; no clock, no temp files.

## Numeric Derivation Evidence

No numeric count is proposed for any `spec.md` acceptance criterion in this research. The return codes (2, 3, 4, 5, 7, 9) are test-chosen fixture values, not derived populations. The fixture-file count in the "Recommended minimal fix" (20 copied files) is a convenience figure for the planner derived from a single directory listing of `child_of_not_merged` and is not proposed as an acceptance assertion; if the planner wants to assert a fixture file count, a cross-checked derivation must be performed first.

## Automation Feasibility

No human interaction is required. All changes are Markdown, bats test, and fixture text files. The only constraints are environmental: local bats execution depends on `npx --yes bats` working in the agent worktree (unverified), and kcov evidence (AC-5) must come from the CI `shell-coverage` job artifact because kcov runs only in WSL or CI. PR creation and merge follow the normal orchestration path.
