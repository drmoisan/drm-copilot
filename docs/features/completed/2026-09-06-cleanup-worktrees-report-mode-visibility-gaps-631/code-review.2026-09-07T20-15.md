# Code Review — cleanup-worktrees report-mode visibility gaps (#631)

- **Timestamp:** 2026-09-07T20-15
- **Cycle:** remediation cycle 1, round 4 (re-audit)
- **Branch / head:** `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r3` @ `ebe50907`
- **Base / merge-base:** `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed`
- **Reviewed surface:** the full branch diff, not the remediation plan's task list

## Method

This review does not rest on the executor's evidence artifacts or on the commit messages. Every
load-bearing claim below was re-derived by reading the delivered source and, where behavior was
the question, by executing the delivered code directly against the checked-in fixtures outside the
bats harness. Two ad-hoc drivers were used, both written to the session scratchpad and neither
touching the repository:

1. A sweep running `classify_all_branches` and `classify_branch` over all six `child_of_*`
   scenarios and all three branches in each, plus `run_apply` over two scenarios and `run_report`
   over `report_single_scan` with stderr retained.
2. A scratch scenario constructed outside the repository to reach the pairwise-probe
   hard-failure path, which no checked-in fixture exercises.

`shfmt -d` and `shellcheck -x -s bash` were re-run locally over all seven changed shell files
(both exit 0). CI run `34162347134` at `9f0a3e6c` was confirmed to be the toolchain evidence of
record: `git diff --stat 1f702f68 HEAD -- scripts/ tests/` is empty, so no code changed after the
tested commit.

---

## Verification of the remediation's core claims

### D1 — is there truly no sound cut point in `classify_branch`'s ladder?

Independently confirmed by reading `classify_branch` (`scripts/bash/cleanup_worktrees_lib.sh:313-447`)
rung by rung. The claim under test is: *X is a git ancestor of Y, and Y resolved exactly
`NOT_MERGED`, therefore X resolves `NOT_MERGED`.* It fails at three separate rungs:

- **Rung 2 (`classify_ancestry`, `:57-78`, called at `:371`).** The probe is
  `merge-base --is-ancestor <tip> main`. A branch merged into `main` by a merge commit is an
  ancestor of `main`, and is simultaneously an ancestor of every branch cut from a `main` that
  already contains it. It yields `MERGED_CLEAN` — a delete-eligible state — while being an
  ancestor of an unmerged branch.
- **Rung 3 (`classify_content_neutral`, `:80-103`, called at `:382`).** `git diff --quiet
  main...<branch>` is evaluated against the branch alone. Ancestry of an unmerged branch places no
  constraint on it, so `MERGED_CONTENT_NEUTRAL` is reachable for an ancestor of a `NOT_MERGED`
  branch.
- **Rung 5 (`classify_residual_commit`, `:190-257`, consumed at `:408-420`).** This rung resolves
  each residual commit by comparing the **branch tip's** blob against `main`'s (`_blob_equal
  "$branch" main "$relpath"`). Two branches in an ancestor relationship have different tips, so the
  same residual SHA can resolve `CONTENT_ON_MAIN` for one and `UNIQUE` for the other. Because this
  is the last rung before the verdict, no earlier cut point can be sound either: a design that ran
  rungs 1-4 and then inherited would still produce the wrong answer here.

Rung 4 (`classify_cherry_equivalent`) is likewise not inheritable, since `git cherry`'s
upstream-side commit set for X is a superset of Y's whenever Y contains `main` commits X lacks.

**Conclusion: the "no sound cut point" claim holds.** It is not merely asserted in the delivered
docstring (`cleanup_worktrees_report_records_lib.sh:352-369`) — it is now pinned by three executable
counterexample fixtures, one per delete-eligible state.

### D1 — does the delivered driver inherit any verdict?

No. `classify_all_branches` (`cleanup_worktrees_report_records_lib.sh:346-476`) has exactly one
place where a verdict enters the output, at line 421:

```
cbout=$(classify_branch "$x") || crc=$?
branch_out[$x]=$cbout
```

and exactly one place where the recorded output is subsequently altered, at line 466:

```
branch_out[$x]="${branch_out[$x]:-}"$'\n'"CHILD_OF|$x|$hit"
```

which appends only. There is no `printf 'BRANCH|...'` anywhere in the file, no substitution, and no
rewrite of a recorded line. The `BRANCH|` line the driver emits is therefore the byte-identical line
`classify_branch` produced, by construction.

**Executed confirmation.** Driving both functions over six scenarios × three branches (18 pairs):

| Scenario | Branch | `classify_all_branches` | `classify_branch` | Match |
|---|---|---|---|---|
| `child_of_not_merged` | feature-child | `BRANCH\|feature-child\|NOT_MERGED` (+ `CHILD_OF\|feature-child\|feature-parent`) | `BRANCH\|feature-child\|NOT_MERGED` | yes |
| `child_of_not_merged` | feature-parent | `BRANCH\|feature-parent\|NOT_MERGED` | same | yes |
| `child_of_not_merged` | main | `BRANCH\|main\|PROTECTED_CURRENT` | same | yes |
| `child_of_subject_merged_clean` | feature-child | `BRANCH\|feature-child\|MERGED_CLEAN` | same | yes |
| `child_of_subject_content_neutral` | feature-child | `BRANCH\|feature-child\|MERGED_CONTENT_NEUTRAL` | same | yes |
| `child_of_subject_merged_equivalent` | feature-child | `BRANCH\|feature-child\|MERGED_EQUIVALENT` | same | yes |
| `child_of_merged_equivalent` | feature-parent | `BRANCH\|feature-parent\|MERGED_EQUIVALENT` | same | yes |
| `child_of_ancestry_probe_error` | feature-child | `BRANCH\|feature-child\|ANCESTRY_ERROR`, driver rc 2 | same, ladder rc 2 | yes |

All 18 pairs matched byte-for-byte, and the driver's return code equalled the maximum per-branch
ladder return code in every case.

### D2 — is the pairwise probe restricted to `NOT_MERGED`?

Yes. Lines 430-435 build the probe set by filtering `branch_state[$x] == "NOT_MERGED"`; lines
436-469 run the probe only when that set has more than one member. `main` is excluded by its own
`PROTECTED_CURRENT` verdict and needs no separate protection lookup, which is exactly why D3's
function could be deleted. The inner loop breaks on the first hit (line 457), bounding the probe at
`k*(k-1)` worst case for `k` `NOT_MERGED` branches.

Confirmed by execution: in `child_of_subject_merged_clean`, `child_of_subject_content_neutral`,
`child_of_subject_merged_equivalent`, and `child_of_merged_equivalent` the `NOT_MERGED` set has one
member, so no pair exists and **no `CHILD_OF` record is emitted** — observed in all four runs. In
`child_of_not_merged` the set has two members and exactly one directed record
(`CHILD_OF|feature-child|feature-parent`) is emitted; the reverse direction is correctly suppressed
because `merge-base.feature-parent` returns 1.

### D2 — the pairwise hard-failure contract (untested path, verified here)

No checked-in scenario reaches lines 459-463. `child_of_ancestry_probe_error` supplies
`merge-base.feature-child.rc = 128`, but that value is consumed by `classify_branch`'s own rung-2
probe (the test's own comment says so), and the resulting `ANCESTRY_ERROR` keeps `feature-child` out
of the probe set, so the pairwise branch is never entered.

I constructed a scenario outside the repository with two branches that both resolve `NOT_MERGED`
through their own ladders and with `merge-base.feature-a.feature-b.rc = 128`. Result:

```
BRANCH|feature-a|NOT_MERGED
BRANCH|feature-b|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
driver_rc=2
```

versus the ladder alone, which returns `BRANCH|feature-a|NOT_MERGED` (rc 0) and
`BRANCH|feature-b|NOT_MERGED` (rc 0). The delivered behavior is exactly the contract
`spec.md:202-208` states: no `CHILD_OF` record for the failed pair, both verdicts left untouched,
rc raised to 2. **The path is correct but unpinned** — see CR-R4-02.

### Are the two invariant tests non-vacuous?

Yes, and by two independent lines of evidence.

- **Structurally.** `test_cleanup_worktrees_classification.bats:197-211` holds branch *and* fixture
  fixed: it runs `classify_all` and `cb` against the same `child_of_not_merged/feature-child` pair
  and asserts `[ "$driver_line" = "$ladder_line" ]`. This is precisely the defect the prior cycle's
  R-01/CR-02 identified in the superseded test, which compared two different branches in two
  different scenarios. `test_cleanup_worktrees_deletion.bats:143-152` asserts a *positive* deletion
  (`ACTION|branch-delete|feature-child|OK`) for a delete-eligible ancestor of a `NOT_MERGED` branch —
  an assertion the pre-fix code could not satisfy, because it reported that branch `NOT_MERGED`.
- **Empirically.** `evidence/regression-testing/fail-before-r01-r02-r04.2026-09-07T14-40.md` records
  CI run `34160727312` at commit `43d2a76c` (fixtures and tests only, production fixes held out):
  exit 1 with exactly 8 `not ok` lines, named, comprising the four `child_of_*` verdict tests, the
  apply-mode deletion test, both `cleanup_wt_scan_roots` tests, and the single-scan test. 335 of 343
  passed. Red-before / green-after is established.

### Do the three counterexample fixtures exercise rungs 2, 3, and 5 as claimed?

Verified by tracing each fixture through the git stub's documented key derivation
(`tests/fixtures/cleanup_worktrees/stub-bin/git:108-246`) and confirming against execution.

- **`child_of_subject_merged_clean` → rung 2.** `merge-base.feature-child.main.rc = 0` resolves the
  target-aware pair key, so `classify_ancestry` returns `MERGED_CLEAN` and the ladder exits at rung 2
  before any `diff --quiet` or `cherry` runs. The fixture supplies no `cherry.feature-child.out` and
  no `diff-quiet.feature-child.rc`, which is consistent with that early exit. Confirmed:
  `BRANCH|feature-child|MERGED_CLEAN`.
- **`child_of_subject_content_neutral` → rung 3.** `merge-base.feature-child.main.rc = 1` passes
  rung 2; the fixture deliberately omits `diff-quiet.feature-child.rc`, so the stub exits 0 and
  `classify_content_neutral` returns `MERGED_CONTENT_NEUTRAL`. Confirmed:
  `BRANCH|feature-child|MERGED_CONTENT_NEUTRAL`.
- **`child_of_subject_merged_equivalent` → rung 5.** `merge-base.feature-child.main.rc = 1` and
  `diff-quiet.feature-child.rc = 1` pass rungs 2 and 3; `cherry.feature-child.out` is `+ eqvc0001`
  and `diff-tree.eqvc0001.out` is non-empty (`M docs/readme.md`), so rung 4 does *not* short the
  ladder to `MERGED_EQUIVALENT`. The verdict is reached only at the blob tier, where
  `rev-parse.feature-child_docs_readme.md.out` and `rev-parse.main_docs_readme.md.out` are both
  `blobsame111` → `CONTENT_ON_MAIN` → `unique_count == 0` → `MERGED_EQUIVALENT` at
  `cleanup_worktrees_lib.sh:422-426`. This is genuinely the rung-5 path, not a rung-4 shortcut.
  Confirmed: `BRANCH|feature-child|MERGED_EQUIVALENT`.

Each of the three corresponding tests asserts the correct verdict, asserts the absence of the
`NOT_MERGED` token for that branch, asserts no `CHILD_OF|feature-child|` record, and re-asserts
driver/ladder agreement via a direct `cb` call. The assertions match the fixtures.

### R-02 — exactly one scan per report?

Yes. `run_report` (`cleanup_worktrees_lib.sh:474`) contains a single `run_report_scans || rc=$?`
line; the three former independent scan call sites are gone. `run_report_scans`
(`cleanup_worktrees_report_records_lib.sh:306-344`) makes one `cleanup_wt_scan_records` call at line
323 and passes the same captured `$recs` to `scan_orphan_dirs` (335) and `scan_registration_loss`
(339). Both callees test on **argument count** (`(($# > 0))`, lines 216 and 280) rather than on
value, so "records supplied and empty" is distinguishable from "no records supplied" and the six
pre-existing single-function tests remain valid with no argument.

Executed confirmation against `report_single_scan` with stderr retained:

```
stub-scan: scan-dirs /repo/main/.claude/worktrees /repo/main-wt
ORPHAN_DIR|/repo/main/.claude/worktrees/agent-old|128K
WARN|registration-lost|/repo/main-wt/half-gone
```

Exactly one `stub-scan:` line, with both scan-derived records present. The scan-stub argv log
(`tests/fixtures/cleanup_worktrees/stub-bin/scan:29`) is D6's observability addition and is what
makes `test_cleanup_worktrees_report_records.bats:119-131` able to count invocations at all.
`scan_registration_loss`'s "one consistent view of the filesystem" docstring is now true, and the
docstring at `:263-267` correctly names `run_report_scans` as the mechanism that makes it true.

### R-04 — do both roots derive from the main worktree path?

Yes, on all three branches of `cleanup_wt_scan_roots` (`:114-150`):

- **Override branch** (`:129-137`): `CLEANUP_WT_ORPHAN_ROOTS` is split on `:` and emitted verbatim,
  unchanged from the prior implementation. Pinned by
  `test_cleanup_worktrees_report_records.bats:101-109`.
- **Derived branch** (`:138-148`): `parse_worktree_list`'s first stanza yields `main_wt`, and both
  roots are printed as `"${main_wt}/.claude/worktrees"` and `"${main_wt}-wt"`. The CWD-relative
  literal `.claude/worktrees` is gone. Pinned by `..._report_records.bats:90-99`.
- **Hard-failure branch** (`:139-142`): a non-zero `parse_worktree_list` returns 0 with **no root
  emitted**, and `cleanup_wt_scan_records` returns 0 with no record for an empty root list
  (`:167-169`), so the advisory records degrade to silence rather than to a misleading scan. Pinned
  by `..._report_records.bats:111-117`.

Executed confirmation: the argv line above shows the helper being invoked with
`/repo/main/.claude/worktrees /repo/main-wt` — both absolute, both derived, neither relative to the
process CWD.

### D3 — is `cleanup_wt_protected_branches` removed?

Yes. A repository-wide search for the literal returns matches only in `docs/` prose (the plan and
the prior review artifacts). Zero matches under `scripts/` or `tests/`. It is deleted, not merely
unreferenced.

### Contract impact on other suites

`run_apply` was rewritten to consume the shared driver. The behavioral surface was checked against
every affected call site:

- The allowlist (`cleanup_worktrees_actions_lib.sh:411-413`) is unchanged:
  `MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT`, with `*) : ;;` for everything else.
- The per-branch extraction (`:397-398`) filters on `($1 == "BRANCH" || $1 == "CHILD_OF" ||
  $1 == "COMMIT") && $2 == n`. I verified that `classify_branch` and `select_cherry_pick_candidates`
  emit no other line type on stdout (`cleanup_worktrees_lib.sh` — only `BRANCH|` and `COMMIT|`
  printf targets stdout; the `rev-list failed` diagnostic goes to stderr), so the filter is complete.
  Branch names cannot contain `\` or `|` under `git check-ref-format`, so neither the `-v n=`
  assignment nor the `-F'|'` split can be confused.
- `delete_candidate` still calls `reverify_delete_eligible` in-process before every destructive step
  (`:328`), so even a stale classification cannot unlock a wrong deletion. This is the load-bearing
  safety property and it is untouched.
- Executed confirmation: `run_apply` over `child_of_subject_merged_clean` emits
  `BRANCH|feature-child|MERGED_CLEAN` then `ACTION|branch-delete|feature-child|OK`; over
  `child_of_not_merged` it emits `BRANCH|feature-child|NOT_MERGED` plus the `CHILD_OF` line and **no**
  `ACTION` for that branch. Both match the delivered tests.

The other five bats suites were changed only by adding `RLIB` to their source chains and the scan
seam to their `env` (diffs inspected in full for `_cli`, `_detached`, `_hard_failures`). No
assertion value changed. `test_cleanup_worktrees_cli.bats` and `test_cleanup_worktrees_detached.bats`
are the two sites that retain stderr and reach `run_report`, so they see the new `stub-scan:` line;
neither carries an `$output` equality assertion or an unanchored line count, so the added line
changes nothing. The full suite is green at 343/343.

No pre-existing scenario fixture directory was modified: `git diff --name-status 6dff80ed..HEAD --
tests/fixtures/cleanup_worktrees/scenarios/` contains only `A` (added) entries.

---

## Findings

### CR-R4-01 — `spec.md` still states the removed verdict-overwrite mechanism in two places
**Severity: Major. Non-blocking.**

`spec.md:280` (Implementation strategy → Error handling and logging updates) reads:

> A hard failure in the new pairwise ancestry probe maps to `BRANCH|<name>|ANCESTRY_ERROR`,
> matching every other hard-failure case in the ladder.

and `spec.md:411` (Test Strategy → Edge cases) reads:

> a hard git failure during the new pairwise `merge-base --is-ancestor` probe maps to
> `ANCESTRY_ERROR`, not a silent "not an ancestor" fallback

Both directly contradict the corrected invariant section at `spec.md:202-208`, which states — and
the delivered code implements — that such a failure must **not** be mapped onto the branch's verdict,
because doing so would overwrite an already-correct `BRANCH|` line and break the invariant. My
execution of that path confirmed the code follows lines 202-208, not lines 280/411.

The remediation plan's bounded documentation scope committed to correcting "the invariant section's
pairwise-probe hard-failure paragraph (P6-T3), which carries no occurrence of `short-circuit` but
does describe the verdict-overwrite mechanism D2 removes." It corrected that one paragraph and left
two others of exactly the same class. Line 411 additionally prescribes a required test case that
cannot exist under the delivered contract.

**Why non-blocking:** the delivered behavior is verified correct and matches the authoritative
invariant section; no acceptance criterion is checked off on the strength of either sentence; and
the residual-prose decision was recorded in advance in the plan's scope boundary rather than
overlooked silently. **Recommended fix:** rewrite both sentences to the `:202-208` contract in the
next documentation pass, alongside the deferred R-08 items.

### CR-R4-02 — the pairwise hard-failure and `run_report_scans` error paths carry no test
**Severity: Major. Non-blocking.**

From the CI Cobertura report for run `34162347134`, unhit lines in
`scripts/bash/cleanup_worktrees_report_records_lib.sh`: 85, 86, 90, 91, 166, 168, 180, 183, 184,
221, 285, 325, 326, 327, 329, 333, 337, 341, 403, 462. In `cleanup_worktrees_scan_helper.sh`: 54,
69, 88, 89, 127, 145, 146.

Two items are worth separating from the deferred R-06 bulk:

1. **Line 462** (`rc=2` on a pairwise-probe hard failure) is named as a required edge case by
   `spec.md:411` and has no test. `child_of_ancestry_probe_error` looks like it covers this but does
   not — its `merge-base.feature-child.rc = 128` is consumed by the ladder's own rung-2 probe, and
   the test's own comment says so. I exercised the path manually and it is correct; it is unpinned,
   not unknown. A fixture supplying `merge-base.<a>.<b>.rc = 128` between two branches that both
   resolve `NOT_MERGED` would close it in one scenario directory.
2. **Lines 325-341** are the entire scan-failure and rc-maximization block of `run_report_scans`,
   which is **new code introduced by this cycle**. Eight of the twenty uncovered lines in the file
   did not exist before this remediation. The rc-maximization logic (`if ((orc > rc)); then rc=$orc`
   and siblings) is never executed with a non-zero operand by any test.

**Why non-blocking:** both files clear the 85% per-file floor (89.0% and 86.8%), repo-wide bash
coverage is 93.5%, and the uncovered behavior is advisory-path error handling that never unlocks a
destructive action. R-06 was explicitly deferred by the calling orchestrator for this cycle.

### CR-R4-03 — `run_report` can lower a return code set by the new scan driver
**Severity: Minor.**

`cleanup_worktrees_lib.sh:474-484`:

```
run_report_scans || rc=$?
...
report_detached_worktrees "$wlout" || rc=$?
crc=0
classify_all_branches || crc=$?
if ((crc > rc)); then rc=$crc; fi
```

The `report_detached_worktrees` line uses plain assignment, not maximization. If `run_report_scans`
returns 2 and `report_detached_worktrees` subsequently returns 1, `rc` becomes 1. The
classification driver twelve lines later correctly maximizes, and `run_report_scans` itself
maximizes internally, so this is the one remaining inconsistent site. The assignment form predates
this branch (it arrived with #630), but the *interaction* is new, because nothing previously set
`rc` before that line. Impact is limited to which non-zero code is reported; the failure signal
itself survives. **Fix:** `report_detached_worktrees "$wlout" || { drc=$?; ((drc > rc)) && rc=$drc; }`.

### CR-R4-04 — `usage()` documentation defects remain open (carried R-08)
**Severity: Minor.**

`scripts/bash/cleanup-worktrees.sh:58` still heads all four new records
"(report and apply mode; none unlocks a destructive action)". Only `CHILD_OF` reaches apply mode —
`ORPHAN_DIR`, `STALE_REF`, and `WARN|registration-lost` are emitted solely by `run_report` via
`run_report_scans`, which `run_apply` never calls. Separately,
`CLEANUP_WT_SCAN_GITFILE_NAME` is still absent from the "Environment overrides" list, although its
two siblings `CLEANUP_WT_SCAN_BIN` and `CLEANUP_WT_ORPHAN_ROOTS` were added there. Both items were
explicitly deferred as R-08 in this cycle's scope boundary; recorded here so they do not lapse.

### CR-R4-05 — `run_apply`'s hard-failure gate remains state-based (carried CR-07)
**Severity: Minor. Latent, not active.**

`cleanup_worktrees_actions_lib.sh:400-406` gates on `state == "ANCESTRY_ERROR"` rather than on a
non-zero per-branch return. `classify_branch` can return 2 after emitting `HAS_UNIQUE_RESIDUALS`
(`cleanup_worktrees_lib.sh:437-443`, the `select_cherry_pick_candidates` failure path). I re-traced
every `return 2` in `classify_branch`: that is the only non-`ANCESTRY_ERROR` case, and
`HAS_UNIQUE_RESIDUALS` falls to the `*) : ;;` arm of the allowlist `case`, so no deletion is
unlocked. The driver-level `rc=1` at `:390` still propagates. No behavioral regression. Closing it
properly requires the driver to return a per-branch status, which is a larger interface change than
this cycle's scope.

### CR-R4-06 — classification now precedes all deletions in apply mode
**Severity: Informational.**

Previously `classify_branch` ran inside the deletion loop, so branch *N+1* was classified after
branch *N*'s worktree had been removed. Now all branches are classified up front. The only inputs
that could differ are `compute_protected` and `parse_worktree_list`, and a worktree that
`delete_candidate` removes cannot be the current one (the current worktree's branch resolves
`PROTECTED_CURRENT` and is never on the allowlist). The in-loop `reverify_delete_eligible` re-check
is unchanged and re-reads git state at deletion time, so no deletion can be unlocked by a stale
classification. Recorded as a semantic change worth knowing, not a defect.

### CR-R4-07 — `enumerate_branches` is invoked twice per report and per apply
**Severity: Informational.**

`run_report:470` calls `enumerate_branches >/dev/null` purely as an early-abort probe, then
`classify_all_branches:401` reads the branch list again. `run_apply` does the same. One extra git
process per invocation, negligible against the per-branch ladder cost, and the early-abort-before-
any-output property it buys is worth stating. Noted because the prior cycle's CR-08 raised it and it
is unchanged.

### CR-R4-08 — one fixture retains a record shape the helper can no longer produce
**Severity: Informational.**

`tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_present/scan-dirs.out` contains
`.claude/worktrees/agent-old|0|NA|128K` — a CWD-relative path. After R-04 the real helper is always
invoked with absolute roots and therefore always emits absolute record paths. The scan stub replays
canned bytes regardless of the roots it is handed, so the test is valid and its assertion is exact;
the fixture is simply no longer representative of production output. The sibling
`report_single_scan` fixture uses the correct absolute shape.

### CR-R4-09 — an evidence artifact overclaims AC6
**Severity: Minor.**

`evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md` closes with "This
satisfies AC6", while the plan's scope boundary, `evidence/other/remediation-closure.2026-09-07T14-40.md`,
and the unchecked checkbox in `spec.md` all treat AC6 as unmet pending R-07. The artifact does
substantiate the *end-state* property (no pre-existing test regressed on the final tree); it does not
substantiate the *sequencing* property AC6 states. The conservative disposition is the one on disk,
so no criterion is wrongly checked, but the sentence should be amended to match.

---

## Positive observations

- The `(($# > 0))` argument-count test in `scan_orphan_dirs` and `scan_registration_loss`
  (`:216`, `:280`) is the right discriminator. Testing the value instead would have conflated "the
  scan found nothing" with "no records were supplied" and silently reintroduced the duplicate scan
  for an empty tree. The docstrings state that reasoning explicitly at `:207-212` and `:274-276`.
- Restricting the probe set to `NOT_MERGED` is what allowed `cleanup_wt_protected_branches` to be
  deleted rather than left as coverage-depressing dead code. The dependency is stated at `:427-429`
  and holds: `main` resolves `PROTECTED_CURRENT` at rung 1 and never enters the set.
- Choosing the `LC_ALL=C`-first ancestor target (`:439-446`) makes `CHILD_OF` deterministic when a
  branch has several `NOT_MERGED` ancestor-targets. Without it the record would vary with
  enumeration order.
- The rewritten `classify_all_branches` header (`:352-369`) documents the counterexamples per rung
  rather than asserting soundness. That is the right form for a claim a future maintainer will be
  tempted to re-derive incorrectly, and it is the third independent place (code, spec, tests) the
  argument is now recorded.
- The `spec.md` performance paragraph was rewritten to withdraw the cost-reduction claim outright
  (`:333-341`) rather than quietly leaving it. Accurate documentation of a capability the design no
  longer provides.

---

## Code Review Verdict

**PASS.** Blocking findings from this artifact: **0**.

Two Major non-blocking findings (CR-R4-01 documentation contradiction, CR-R4-02 error-path coverage),
three Minor, three Informational. None affects delivered behavior, and none unlocks or blocks a
destructive action.
