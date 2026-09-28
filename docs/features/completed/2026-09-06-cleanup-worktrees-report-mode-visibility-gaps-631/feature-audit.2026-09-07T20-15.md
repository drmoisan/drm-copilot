# Feature Audit — cleanup-worktrees report-mode visibility gaps (#631)

- **Timestamp:** 2026-09-07T20-15
- **Cycle:** remediation cycle 1, round 4 (re-audit)
- **Work mode:** `full-bug` (`issue.md:12`) → **AC source is `spec.md` only**; `user-story.md` is
  not an AC source in this mode and `issue.md` is context only
- **Branch / head:** `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r3` @ `ebe50907`
- **Baseline:** `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed`
- **Toolchain evidence of record:** CI run
  [34162347134](https://github.com/drmoisan/drm-copilot/actions/runs/34162347134) at `9f0a3e6c`
  (343/343 bats, `Bash coverage (lines): 93.5%`); confirmed valid for `ebe50907` because
  `git diff --stat 9f0a3e6c HEAD` touches only `docs/`

---

## 1. Remediation findings — disposition

### R-01 — `CHILD_OF` short-circuit produced a wrong verdict (was Blocking)

**FIXED.**

Evidence:

- `scripts/bash/cleanup_worktrees_report_records_lib.sh:346-476` — `classify_all_branches` contains
  no verdict inheritance. Every branch is classified by one `classify_branch` call at line 421,
  whose captured output is stored verbatim at line 422. The only mutation of stored output is the
  append at line 466 (`branch_out[$x]="${branch_out[$x]:-}"$'\n'"CHILD_OF|$x|$hit"`). There is no
  `printf 'BRANCH|'` in the file and no line rewrite anywhere.
- Phase 2 (`:427-469`) filters the probe set to branches whose recorded state is exactly
  `NOT_MERGED` (`:432`) and runs only when that set exceeds one member (`:436`), so a
  non-`NOT_MERGED` branch is neither a probe subject nor a probe target.
- The "no sound cut point" premise was independently re-derived against the ladder:
  rung 2 `classify_ancestry` (`cleanup_worktrees_lib.sh:57-78`, called at `:371`), rung 3
  `classify_content_neutral` (`:80-103`, called at `:382`), and rung 5 `classify_residual_commit`
  (`:190-257`, whose `_blob_equal "$branch" main "$relpath"` compares the **branch tip's** blob)
  each admit a counterexample. Rung 5 being decisive means no earlier cut can be sound either.
- Three counterexample fixtures pin one delete-eligible state each and were traced through the stub
  key derivation to confirm they reach the claimed rung:
  `child_of_subject_merged_clean` → rung 2 (`merge-base.feature-child.main.rc = 0`);
  `child_of_subject_content_neutral` → rung 3 (`diff-quiet.feature-child.rc` deliberately absent → 0);
  `child_of_subject_merged_equivalent` → rung 5 (non-empty `diff-tree.eqvc0001.out` denies the rung-4
  shortcut; equal `rev-parse.*_docs_readme.md.out` blobs force `CONTENT_ON_MAIN` at the blob tier).
- `cleanup_wt_protected_branches` (D3) is deleted; zero matches under `scripts/` or `tests/`.
- **Executed independently by this audit:** driver-vs-ladder `BRANCH|` line comparison over six
  `child_of_*` scenarios × three branches = 18 pairs, all byte-identical, with driver rc equal to
  the maximum ladder rc in every case. Apply mode over `child_of_subject_merged_clean` emits
  `ACTION|branch-delete|feature-child|OK`; over `child_of_not_merged` it emits no deletion `ACTION`
  for the `NOT_MERGED` branch.
- Non-vacuity of the fix is corroborated by
  `evidence/regression-testing/fail-before-r01-r02-r04.2026-09-07T14-40.md`: CI run `34160727312` at
  `43d2a76c` (tests only, production fixes held out) exited 1 with exactly 8 named `not ok` lines,
  including all four `child_of_*` verdict tests and the apply-mode deletion test.

### R-02 — duplicate filesystem scan per report (was Major)

**FIXED.**

Evidence:

- `scripts/bash/cleanup_worktrees_lib.sh:474` — `run_report` now has a single `run_report_scans ||
  rc=$?` line. The three original independent scan call sites are gone.
- `scripts/bash/cleanup_worktrees_report_records_lib.sh:306-344` — `run_report_scans` performs one
  `cleanup_wt_scan_records` call (`:323`) and passes the same `$recs` to `scan_orphan_dirs` (`:335`)
  and `scan_registration_loss` (`:339`).
- Both callees gate on argument **count** (`(($# > 0))`, `:216` and `:280`), preserving the
  no-argument direct-call contract that the six pre-existing single-function tests rely on.
- `test_cleanup_worktrees_report_records.bats:119-131` asserts
  `grep -c 'stub-scan: scan-dirs'` equals 1 for a full `run_report`, enabled by D6's argv log at
  `tests/fixtures/cleanup_worktrees/stub-bin/scan:29`.
- **Executed independently by this audit:** `run_report` over `report_single_scan` with stderr
  retained emits exactly one `stub-scan: scan-dirs /repo/main/.claude/worktrees /repo/main-wt` line
  alongside both scan-derived records.

### R-04 — `.claude/worktrees` scan root was CWD-relative (was Major)

**FIXED.**

Evidence:

- `scripts/bash/cleanup_worktrees_report_records_lib.sh:138-148` — the derived branch reads
  `parse_worktree_list`'s first stanza into `main_wt` and prints
  `"${main_wt}/.claude/worktrees"` and `"${main_wt}-wt"`. The bare relative literal is gone.
- Override branch (`:129-137`) unchanged and pinned by `..._report_records.bats:101-109`.
- Hard-failure branch (`:139-142`) returns 0 emitting **no** root; `cleanup_wt_scan_records`
  returns 0 with no record for an empty root list (`:167-169`), so the records degrade to silence
  rather than to a misleading CWD-relative scan. Pinned by `..._report_records.bats:111-117`.
- Derived branch pinned by `..._report_records.bats:90-99`, asserting exactly
  `/repo/main/.claude/worktrees` and `/repo/main-wt`.
- **Executed independently by this audit:** the argv line the scan stub logged shows both roots
  absolute and derived, confirming the CWD dependency is removed on the live path, not only in the
  unit assertion.

---

## 2. Acceptance Criteria Evaluation

**Source:** `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`,
section `## Acceptance Criteria` (lines 433-479). 11 items.

| # | Criterion (abbreviated) | Checkbox on disk | Audit verdict | Evidence |
|---|---|---|---|---|
| AC1 | `ORPHAN_DIR\|<path>\|<size>` present for an unregistered `.git`-less dir, absent for a registered one; positive/negative bats pair | `[x]` | **PASS** | `test_cleanup_worktrees_report_records.bats:59-73` against `orphan_dir_present` / `orphan_dir_absent`; emission logic `..._report_records_lib.sh:192-252` with `normalize_wt_path` comparison at `:243-244` and the `unknown` fallback at `:245` |
| AC2 | `STALE_REF\|<refname>` present when the remote is missing, absent when it exists; fixture uses a name other than `child` | `[x]` | **PASS** | `..._report_records.bats:43-57`; fixtures use `upstream`, and `remote.out` differs only by that line between the pair. Detection is generic over `refs/remotes/<name>/` (`..._report_records_lib.sh:99-107`), with no hardcoded name |
| AC3 | `CHILD_OF` emitted alongside an unchanged `BRANCH\|<b>\|NOT_MERGED` when the branch is an ancestor of a branch resolving exactly `NOT_MERGED`; absent when the ancestor resolves otherwise; positive case asserts the subject's `BRANCH\|` line equals its own ladder's | `[x]` | **PASS** | Positive `test_cleanup_worktrees_classification.bats:153-168` (asserts both lines plus `cherry main feature-child` in the argv log, proving the subject's own ladder ran); negative `:170-184` against `child_of_merged_equivalent`; equality `:197-211` holding branch and fixture fixed. Independently reproduced. Criterion text was corrected in this cycle to the informational-record contract and now matches the delivered code |
| AC4 | `WARN\|registration-lost\|<path>` present for a broken gitdir pointer, absent when it resolves; positive/negative pair | `[x]` | **PASS** | `..._report_records.bats:75-88` against `registration_lost_present` / `registration_lost_absent`; logic `..._report_records_lib.sh:254-304`, skipping unexpected shapes silently per the never-blocking contract at `:268-272` |
| AC5 | Outcome preservation as two properties: (a) driver `BRANCH\|` line byte-identical to `classify_branch`'s for the same branch and fixture; (b) apply mode emits no deletion for a `NOT_MERGED` branch carrying `CHILD_OF`, and **does** emit one for a delete-eligible ancestor of a `NOT_MERGED` branch | `[x]` | **PASS** | (a) `..._classification.bats:197-211`, plus the three counterexample tests each re-asserting driver/ladder agreement at `:225-226`, `:240-241`, `:256-257`. (b) `test_cleanup_worktrees_deletion.bats:130-141` (negative) and `:143-152` (positive deletion — the assertion the pre-fix code could not satisfy). Invariant additionally holds **by construction**: the driver stores `classify_branch`'s output verbatim and only appends. Independently reproduced across 18 branch/fixture pairs |
| AC6 | The `for-each-ref` stub key-specificity edit is backward compatible, verified by a full suite run **immediately after** that edit and **before** any new scenario fixture is authored | `[ ]` | **PARTIAL — correctly left unchecked; NOT a new blocking gap** | See section 3 |
| AC7 | SKILL.md Report Line Contract documents all four record types, cross-references the Dirty Worktree Triage Procedure, mirrored byte-identically | `[x]` | **PASS** | `.claude/skills/cleanup-merged-worktrees/SKILL.md:80-95` adds all four with a cross-reference to "the Dirty Worktree Triage Procedure's step 7" rather than duplicating it. **`diff` between the repo copy and `extensions/drm-copilot/resources/claude-customizations/...` returns no differences** (re-verified by this audit); push-down contract test passes |
| AC8 | `cleanup_worktrees_lib.sh` remains <= 500 lines after the `run_report` call-site edit | `[x]` | **PASS** | 490 lines (`wc -l`, re-counted by this audit). Every other touched shell/bats file also <= 500; the largest is `test_cleanup_worktrees_detached.bats` at 328 and `cleanup_worktrees_report_records_lib.sh` at 476 |
| AC9 | Full toolchain loop (`format`, `check`, `test`, `test --coverage`) passes with line coverage >= 85%, no bash branch gate | `[x]` | **PASS** | `shfmt -d` and `shellcheck -x -s bash` re-run locally over all seven changed shell files, both exit 0. CI run 34162347134: `1..343`, 343 pass, `Bash coverage (lines): 93.5%`. Per-file from the run's Cobertura artifact: new files 89.0% and 86.8%; modified files 94.3%, 93.9%, 100.0%. All >= 85%. No branch gate applies to kcov |
| AC10 | No automatic deletion of orphan directories or stale refs is introduced | `[x]` | **PASS** | Grep of both new files for `rm`, `rmdir`, `update-ref`, `worktree remove`, `branch -D`, `unlink`, `mv` finds only two occurrences, both inside comments (`:75`, `:195`). `cleanup_worktrees_scan_helper.sh` performs read-only observations only. None of the four record types enters `run_apply`'s allowlist `case` (`cleanup_worktrees_actions_lib.sh:411-413`) |
| AC11 | No criterion or test asserts a fixed numeric count derived from the 2026-09-06 run observations; detection is generic | `[x]` | **PASS** | Each scan fixture supplies exactly one canned record per shape; every assertion is on record content, not on a count. The one numeric assertion in the suite (`scan_calls -eq 1`, `..._report_records.bats:130`) counts scan-stub invocations, a property of the code under test, not a historical observation. `STALE_REF` detection is parameterized over `git remote` output with no hardcoded remote name |

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC6 — "The `for-each-ref` stub key-specificity edit in
  tests/fixtures/cleanup_worktrees/stub-bin/git is backward compatible: the full existing bats suite
  passes unchanged immediately after that edit, before any new scenario fixtures are authored on top
  of it."
```

No checkbox was changed by this audit. All ten checked items were independently verified as
honestly justified by the delivered code and tests; AC6 remains `[ ]` as required.

---

## 3. AC6 — is the deferral still defensible?

**Assessment: yes. AC6 is correctly left unchecked, and its remaining unmet does NOT constitute a
new blocking finding.**

AC6 states two things: a *substantive* property (the stub edit breaks no pre-existing scenario) and
a *sequencing* property (the proof must be obtained at a specific intermediate tree state).

**The substantive property is verified, by three independent lines of evidence:**

1. **Structural.** The stub's `for-each-ref` handler (`tests/fixtures/cleanup_worktrees/stub-bin/git:109-124`)
   prefers a pattern-specific key and falls back to the bare `for-each-ref` key when the pattern is
   the literal `refs/heads/`. I checked every `for-each-ref` call site in the production libraries:
   the only pre-existing one is `cleanup_worktrees_enumerate_lib.sh:74-75`, whose pattern is exactly
   `refs/heads/`. The new call at `cleanup_worktrees_report_records_lib.sh:83` uses `refs/remotes/`,
   which resolves to its own key. The edit is additive with an exact-match fallback for the sole
   historical shape. The `merge-base` edit (`stub-bin/git:133-149`) has the same structure: prefer
   `merge-base.<tip>.<up>`, fall back to the historical bare `merge-base.<tip>`.
2. **Fixture immutability.** `git diff --name-status 6dff80ed..ebe50907 --
   tests/fixtures/cleanup_worktrees/scenarios/` contains only `A` entries. No pre-existing scenario
   directory was modified to accommodate the stub edit.
3. **Empirical.** All 321 tests present in the epic-tip baseline still pass at head (343 total, 0
   failures), and the intermediate fail-before run at `43d2a76c` failed exactly 8 named tests, all
   of them new or rewritten by this cycle, with 335 of 343 passing.

**The sequencing property is not verified, and cannot be re-derived.** The original work landed as a
squashed commit, so the tree state "after the stub edit, before the new fixtures" does not exist in
history. `gh workflow run --ref` dispatches branch HEAD only, and no `bats`/`kcov` binary is
available on the Windows PATH in this environment, so the run cannot be produced locally. The
remediation plan's scope boundary recorded this deferral in advance as R-07 and explicitly stated
"Because R-07 is deferred, spec.md's AC6 remains unchecked after this cycle."

**Judgment.** The residual risk is that a pre-existing scenario silently depends on the old stub
behavior and is masked by a compensating new fixture. That hypothesis is excluded by lines 1 and 2
above: no pre-existing fixture directory changed, and the fallback preserves the exact historical
key for the exact historical pattern. What remains unmet is the form of the proof, not the property.
I therefore concur with the deferral and **do not count AC6 as a blocking finding.**

Recommended disposition for a future cycle: amend AC6 to state the property that is actually
obtainable (the end-state regression gate plus the structural fallback argument), or file R-07 as a
follow-up issue. The one thing that should be corrected sooner is the overclaim in
`evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md`, which closes with "This
satisfies AC6" while every other artifact treats it as unmet (code review CR-R4-09).

---

## 4. New defects introduced by this remediation

Searched for: regressions in previously-passing tests, contract changes affecting other bats suites,
sibling-region issues near every edited line, and stale `spec.md` prose outside the plan's bounded
documentation scope.

| ID | Finding | Severity | Blocking? |
|---|---|---|---|
| CR-R4-01 | `spec.md:280` and `spec.md:411` still state that a pairwise-probe hard failure maps to `ANCESTRY_ERROR`, contradicting the corrected invariant at `:202-208` and the delivered code. Line 411 also prescribes a test case that cannot exist under the delivered contract | Major | No |
| CR-R4-02 | The pairwise hard-failure `rc=2` line (`..._report_records_lib.sh:462`) and the entire `run_report_scans` failure/rc-maximization block (`:325-341`, eight lines new in this cycle) have zero test coverage. Behavior of line 462 was verified correct by direct execution in this audit | Major | No |
| CR-R4-03 | `run_report`'s `report_detached_worktrees "$wlout" \|\| rc=$?` can lower an `rc` newly set by `run_report_scans` (last-failure rather than maximum semantics). Non-zero-ness survives; only the specific code degrades | Minor | No |
| CR-R4-04 | `cleanup-worktrees.sh:58` still labels all four records "(report and apply mode)"; only `CHILD_OF` reaches apply mode. `CLEANUP_WT_SCAN_GITFILE_NAME` still missing from the overrides list. Both are the deferred R-08 | Minor | No |
| CR-R4-05 | `run_apply`'s hard-failure gate remains `state == ANCESTRY_ERROR` rather than a non-zero per-branch return. Re-traced: latent only, no deletion unlocked, driver `rc=1` still propagates | Minor | No |
| CR-R4-06 | Apply mode now classifies every branch before any deletion, rather than interleaving. Mitigated by the unchanged in-loop `reverify_delete_eligible` | Informational | No |
| CR-R4-07 | `enumerate_branches` runs twice per `run_report` / `run_apply` | Informational | No |
| CR-R4-08 | `orphan_dir_present/scan-dirs.out` retains a CWD-relative canned record path the helper can no longer produce post-R-04. Test remains valid | Informational | No |
| CR-R4-09 | `stub-git-backward-compat.2026-09-06T23-03.md` asserts "This satisfies AC6" while the checkbox, the plan, and the closure artifact all treat AC6 as unmet | Minor | No |
| — | PR context lists `#545` and `#630` as author-asserted autoclose candidates alongside `#631`. Neither is fixed by this branch. Carried R9; a PR-authoring concern, not a code defect | Minor | No |

**No test regressions.** 343/343 pass; the 321 tests present in the epic-tip baseline all still
pass; no pre-existing bats assertion value was altered by the source-chain and seam additions in
`_cli`, `_detached`, and `_hard_failures` (diffs read in full).

**No contract regressions.** `BRANCH|`, `COMMIT|`, `WORKTREE|`, `WARN|main-divergence|`, `DIRTY|`,
and `ACTION|` shapes are unchanged. `run_apply`'s allowlist is unchanged. The per-branch awk
extraction was checked against every stdout `printf` in the classification path and is complete.

---

## 5. Baseline comparison

| Metric | Epic tip `6dff80ed` | Post-implementation `02ce5eec` | Head `ebe50907` |
|---|---|---|---|
| bats tests | 321 | 335 | **343** |
| bash line coverage | 94.2% | 93.4% | **93.5%** |
| Blocking review findings | — | 1 (R-01) | **0** |
| AC checked (of 11) | — | 11 (later reverted to 8 as premature) | **10** |
| `cleanup_worktrees_lib.sh` lines | 479 | 491 | **490** |

The 0.7pp aggregate coverage movement against the epic tip reflects 235 newly instrumented lines
across two new files; both new files clear the 85% per-file floor and no changed line regressed.

---

## 6. Verdict

**PASS.**

- **R-01: FIXED** — verdict inheritance removed entirely; driver/ladder equality confirmed on 18
  branch/fixture pairs and pinned by four non-vacuous tests plus a recorded red-before run.
- **R-02: FIXED** — one `cleanup_wt_scan_records` call per `run_report`, observed directly via the
  scan stub's argv log and pinned by a dedicated counting test.
- **R-04: FIXED** — both scan roots derive from the main worktree path on all three branches
  (derived, override, hard-failure), each with its own test, and confirmed on the live path.

- **AC6:** correctly left unchecked; deferral remains defensible; **not counted as blocking**.

### blocking_count: 0

Counting FAIL findings and blocking-PARTIAL findings across
`policy-audit.2026-09-07T20-15.md` (0 FAIL, 1 non-blocking PARTIAL),
`code-review.2026-09-07T20-15.md` (0 Blocking), and this artifact (0 FAIL AC, 1 non-blocking
PARTIAL AC). **Total: 0.**

The remediation-loop exit gate condition `blocking_count == 0` is satisfied and this cycle may
close. The Major non-blocking items CR-R4-01 and CR-R4-02, together with the previously deferred
R-05 through R-08 and the R9 PR-body item, should be carried to a follow-up documentation-and-
coverage pass rather than being lost.

No remediation-inputs artifact is produced for this cycle, because no remediation-required finding
was identified.
