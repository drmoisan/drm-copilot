# Policy Audit — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 1 exit

- Timestamp: 2026-09-08T06-51 (UTC; the executor's evidence artifacts in this folder use a
  forward-skewed clock, so their 07-00 and 08-18 stamps sort after this file by name while
  preceding it in wall-clock terms)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ed84aac2`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
  (epic child; the base is the integration branch, not `main`)
- Work mode: `full-bug`. AC source is `spec.md` only.
- Prior cycle artifacts: `policy-audit.2026-09-08T05-00.md`,
  `code-review.2026-09-08T05-00.md`, `feature-audit.2026-09-08T05-00.md`,
  `remediation-inputs.2026-09-08T05-00.md`

## Verdict

**FAIL.** Two blocking findings. All six prior blocking findings (R1 through R6) are
verified closed against the current tree. Two new findings are opened, both in the same
class as the prior cycle's R1/R2 and R4: one reproducible fail-open data-loss path in the
ladder's rung 4, and one set of four safety guards whose direction no checked-in fixture
discriminates.

Remediation cycle 2 is required.

## Scope

The audit scope is the full branch diff against `origin/epic/cleanup-merged-worktrees-hardening-integration`
at `4ffe680e`: 364 changed files, 10,690 insertions, 168 deletions.

### Rejected Scope Narrowing

None. The delegating prompt supplied verification targets and a known-and-accepted list but
did not attempt to narrow the audit to a plan, task, phase, or file subset, and did not
mark any language's coverage as out of scope. The known-and-accepted list (F7 through F13,
F14's documentation half, and the ten residual uncovered lines) is a disposition of
findings already recorded in this feature's own artifacts, not a scope narrowing, and is
honoured as such.

## Changed-language inventory

| Language | Changed files on branch | Coverage artifact | Coverage verdict |
|---|---:|---|---|
| bash (`.sh`, `.bats`, `tests/fixtures/cleanup_worktrees/stub-bin/git`) | 17 | CI run `34194469882`, `kcov-merged/cov.xml` | **PASS** |
| TypeScript | 0 | n/a | n/a (zero changed files) |
| Python | 0 | n/a | n/a (zero changed files) |
| PowerShell | 0 | n/a | n/a (zero changed files) |
| C# | 0 | n/a | n/a (zero changed files) |

The remaining 347 changed files are Markdown (100), checked-in stub fixture payloads
(172 `.out`, 75 `.rc`). None is executable production code.

## Coverage Verification — bash

Verified independently by this reviewer, not read from the executor's evidence artifact.
The artifact zip for run `34194469882` was downloaded via
`gh api repos/drmoisan/drm-copilot/actions/artifacts/10043508097/zip` and
`kcov-merged/cov.xml` parsed directly.

- Run `34194469882`: conclusion `success`, headSha `ea1baef8`.
- `HEAD` is `ed84aac2`. `git diff --name-only ea1baef8 ed84aac2` returns ten paths, all
  under `docs/features/active/.../`. No production or test file changed after the measured
  commit, so the measurement applies to `HEAD`.
- Report root `line-rate`: `0.937`. Recomputed from the per-class line elements:
  **2164 / 2310 = 93.68%** repository-wide. Threshold 85%. **PASS.**
- New file `scripts/bash/cleanup_worktrees_dirt_lib.sh`: **158 / 168 = 94.05%**.
  Threshold 85% for new code. **PASS.** (Baseline at `ad6bc946` was 82.63%; +11.42.)
- Modified files, per-file, from the same report: `cleanup_worktrees_lib.sh` 95.41%,
  `cleanup_worktrees_actions_lib.sh` 94.08%, `cleanup-worktrees.sh` 97.44%. All at or
  above their recorded baselines; no regression. **PASS.**
- Branch coverage: not evaluated. kcov measures no branch coverage, so the 75% branch
  threshold does not apply to bash per `.claude/rules/quality-tiers.md` and
  `.claude/rules/general-unit-test.md`. This is a threshold exemption only; no bash
  production file is excluded from measurement.
- Residual uncovered lines in the new file, read from the same report:
  `74, 75, 76, 77, 95, 161, 164, 173, 203, 334`. This list matches
  `evidence/qa-gates/dirt-lib-coverage.2026-09-08T07-00.md` exactly.

One repository file sits below the 85% line threshold: `.claude/lib/bash/compute-concurrency-batches.sh`
at 81.82%. It has zero changed lines on this branch and is therefore pre-existing; the
repository-wide figure of 93.68% is the gate that applies and it passes.

## Toolchain Loop

Re-run independently by this reviewer where local tooling permits.

| Stage | Result | Evidence |
|---|---|---|
| 1. Formatting | **PASS** | `shfmt -d` over the five changed shell files exits 0 with no diff output (reviewer-run) |
| 2. Linting | **PASS** | `shellcheck` over the same five files exits 0 with no findings (reviewer-run) |
| 3. Type checking | n/a | Skipped for bash per `.claude/rules/general-code-change.md` |
| 4. Architecture-boundary | n/a | No architecture-boundary tool is configured for bash in this repository |
| 5. Unit tests | **PASS** | CI run `34194469882` log: `1..404`, 404 `ok` lines, 0 `not ok` lines (reviewer-counted from `gh run view --log`) |
| 6. Contract / schema | **PASS** | `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` → `11 passed` (reviewer-run) |
| 7. Integration | **PASS** | The bats scenario suites are the integration surface; covered by stage 5 |

Local `bats` and `kcov` binaries are absent from this worktree, so stage 5 was verified
from the CI run log rather than re-executed locally. Stages 1, 2, and 6 were re-executed
locally and are not taken on the executor's word.

## Evidence Location Compliance

`git diff --name-only <base>...HEAD` filtered for `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, and `artifacts/coverage/` returns no paths. All evidence artifacts
are under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`
with `baseline`, `remediation-baseline`, `qa-gates`, `expect-fail`, and `other` kinds.
**PASS.**

## File Size Limit

Every changed or added `.sh` and `.bats` file measured at `HEAD`:

| Lines | File |
|---:|---|
| 496 | `scripts/bash/cleanup_worktrees_lib.sh` |
| 463 | `scripts/bash/cleanup_worktrees_dirt_lib.sh` |
| 437 | `scripts/bash/cleanup_worktrees_actions_lib.sh` |
| 377 | `tests/shell/test_cleanup_worktrees_dirt_classify.bats` |
| 329 | `tests/shell/test_cleanup_worktrees_detached.bats` |
| 302 | `tests/shell/test_cleanup_worktrees_dirt_clear.bats` |
| 259 | `tests/shell/test_cleanup_worktrees_classification.bats` |
| 187 | `scripts/bash/cleanup-worktrees.sh` |
| 182 | `tests/shell/test_cleanup_worktrees_hard_failures.bats` |
| 158 | `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` |
| 153 | `tests/shell/test_cleanup_worktrees_deletion.bats` |
| 150 | `tests/shell/test_cleanup_worktrees_cli.bats` |
| 143 | `tests/shell/test_cleanup_worktrees_dirt_regression.bats` |
| 132 | `tests/shell/test_cleanup_worktrees_report_records.bats` |
| 113 | `tests/shell/test_cleanup_worktrees_enumeration.bats` |
| 79 | `tests/shell/test_cleanup_worktrees_consolidation.bats` |

All at or under 500. **PASS.** `cleanup_worktrees_lib.sh` at 496 leaves four lines of
headroom, which is the constraint the deferred findings F7 and F9 are blocked on.

## Policy Compliance by Rule

### `.claude/rules/general-code-change.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | The ladder is six sequential rungs with first-match-wins and no indirection. |
| Reusability | PASS | The dirt library is a separate sourceable unit; every git read routes through the shared `cleanup_wt_git`. |
| Extensibility | PASS | The clearing path is gated on one variable with a parameter-expansion default, so the bats suites drive it without the wrapper. |
| Separation of concerns | PASS | Classification is read-only and separated from the clearing sequence and from the report driver. |
| Mandatory toolchain loop | PASS | See the toolchain table above. |
| File size limit | PASS | See the table above. |
| Fail fast and explicitly | **PARTIAL** | The stated fail-closed rule holds on every path this reviewer exercised, but rung 4's tracked half infers a positive verdict from an exit code that also means "the pathspec matched nothing". See finding N1. |
| No silent error suppression | PASS | Every git read captures its exit code in the parent shell; the `|| rc=$?` idiom is used throughout. |
| Naming | PASS | `snake_case` functions, descriptive names, no non-standard abbreviations. |
| Public API compatibility | PASS | No existing record shape changed; byte-identity pins cover eight report scenarios and two apply scenarios. |
| Dependencies | PASS | No new dependency. |
| I/O boundaries | PASS | All git I/O is behind `cleanup_wt_git` and is stubbable through `CLEANUP_WT_GIT_BIN`. |

### `.claude/rules/general-unit-test.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each test sets its own scenario through the environment; no shared mutable state. |
| Isolation | PASS | Each test targets one verdict, one ordering property, or one flag behaviour. |
| Fast execution | PASS | 404 tests complete inside the CI step. |
| Determinism | PASS | Every response is replayed from a checked-in fixture; no clock, no RNG, no network. |
| Readability | PASS | Each test carries a comment stating the scenario and why the assertion can fail. |
| Line coverage >= 85% | PASS | 93.68% repo-wide; 94.05% for the new file. |
| Branch coverage >= 75% | n/a | kcov measures no branch coverage; bash is exempt from the threshold only. |
| No regression on changed lines | PASS | Every changed region is executed by tests added this cycle; verified against the per-file baseline table. |
| Coverage exclusion policy | PASS | No `exclude` entry matches a production source path. |
| Scenario completeness | **FAIL** | Four safety guards have no discriminating fixture. See finding N2. |
| Arrange-Act-Assert | PASS | Each test arranges through the scenario environment, acts through one driver call, and asserts on records or the argv log. |
| No external dependencies | PASS | The git binary is replaced by the checked-in stub. |
| **No temporary files in tests** | PASS | All 25 `dirt_*` scenarios and both expected-output sets are checked in. No test creates a scratch repository or a temporary file. |
| Test file location | PASS (pre-existing convention) | Bash suites live under `tests/shell/`, which is this repository's established layout for all 14 `test_cleanup_worktrees_*.bats` suites. This change introduces no new deviation. |
| Documentation | PASS | Every suite carries a header stating its subject and its driver. |

### `.claude/rules/quality-tiers.md`

The cleanup-worktrees toolchain is developer tooling (T4 by the tier definitions). Under
Authoritative Decision #2 the line-coverage threshold is uniform at 85% regardless of tier,
and that threshold is met. No tier-specific lower floor was applied anywhere in this audit.

### `.claude/rules/tonality.md`

The added `SKILL.md` prose, the library header comments, and the spec additions are factual
and measured. No hyperbole, humour, or decorative metaphor observed. **PASS.**

### Policy document integrity

No file under `.claude/rules/` or `.github/instructions/` is modified by this branch.
`.claude/skills/cleanup-merged-worktrees/SKILL.md` is a skill document, not a policy
document, and its modification is required by AC-34 through AC-37. **PASS.**

## Prior Blocking Findings — verification against the current tree

Each was verified by re-running the original reproduction and, where the fix is a control-flow
change, by re-applying the pre-fix form to a scratch copy of the library and confirming the
observable output flips. No verdict below is taken from the executor's claim.

### R1 — rung 1 ignored the porcelain Y column. **CLOSED (PASS).**

`classify_dirt_entry` declares `y="${xy:1:1}"` at line 230 and rung 1 at line 260 reads
`[[ $x != " " && $x != "?" && $x != "!" && $y == " " ]]`.

Reproduction re-run over `dirt_staged_tree_worktree_delta`:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE   (rc 1)
```

The `MM` entry no longer clears. Mutation probe M1 (delete `&& $y == " "`) restores the
defect exactly — `STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs` and `ALL_DISPOSABLE` — so
the fixture discriminates the fix in both directions from one probe result.

### R2 — the ` -> ` split ran unconditionally. **CLOSED (PASS).**

Line 403 reads `if [[ ${xy:0:1} == R || ${xy:0:1} == C ]]; then`.

Reproduction re-run over `dirt_rename_split`:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||R |new.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

The untracked path is reported in full and is not disposable; the genuine `R` entry is
still split to its destination. Two mutation probes confirm the gate is load-bearing and
that the variable choice matters: M2 (unconditional split) and M3 (gate on the enclosing
function's leaked `x` instead of `xy`) both produce
`CONTENT_ON_MAIN||??|draft.md` and `ALL_DISPOSABLE`.

### R3 — new-file line coverage below the uniform threshold. **CLOSED (PASS).**

94.05% (158/168) verified from the CI Cobertura report, not from the evidence artifact.
The specific claim that no residual uncovered line is a fail-closed branch was checked line
by line against the file at `HEAD`:

| Line | Content at HEAD | Class |
|---:|---|---|
| 74 | `CLEANUP_WT_SESSION_ARTIFACT_PATHS=(` | array assignment opener; the statement is attributed to the closing `)` at 78, which is covered |
| 75-77 | the three array elements | array literal interior |
| 95 | `out=$(cleanup_wt_git ... rev-list \` | first physical line of a backslash-continued command; attributed to 96, covered |
| 161 | `out=$(cleanup_wt_git ... diff --no-color -U0 \` (cached arm) | same, attributed to 162 |
| 164 | `out=$(cleanup_wt_git ... diff --no-color -U0 \` (worktree arm) | same, attributed to 165 |
| 173 | `"+"* \| "-"*) ;;` | empty `case` arm, no instrumentable statement |
| 203 | `*.csproj \| packages.config \| ... ) ;;` | empty `case` arm, no instrumentable statement |
| 334 | `found=$(cleanup_wt_git ... log "$range" \` | same, attributed to 335 |

None is a decision, a verdict emission, or a fail-closed branch. The claim is accurate.

### R4 — `STAGED_TREE_IS_COMMIT` pinned in one of five directions. **CLOSED (PASS).**

All five are now pinned in `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`:
probe match (`dirt_staged_tree_worktree_delta`, `M ` half, plus
`dirt_staged_tree_is_commit`); probe no-match (`dirt_staged_tree_no_match`); `rev-list`
hard failure (`dirt_staged_probe_revlist_error`); `diff-index` exit above 1
(`dirt_staged_probe_diffindex_error`); non-space Y column
(`dirt_staged_tree_worktree_delta`, `MM` half). Mutation probe M5 (treat the `ERROR`
sentinel as a no-match) flips both hard-failure fixtures to
`STAGED_TREE_IS_COMMIT|ERROR` and `ALL_DISPOSABLE|ERROR`, so both are discriminating.
Both argv-log positive controls are present and correct.

### R5 — the diff header filter was content-blind. **CLOSED (PASS).**

Line 172 reads `"--- a/"* | "+++ b/"* | "--- /dev/null" | "+++ /dev/null") continue ;;`.
`dirt_build_artifact_plus_content` resolves `UNIQUE`; `dirt_build_artifact_added_file`
resolves `DISPOSABLE_BUILD_ARTIFACT` through the `/dev/null` header. Mutation probe M4
(restore the bare `"+++ "*` / `"--- "*` prefixes) flips the first fixture to
`DISPOSABLE_BUILD_ARTIFACT` and `ALL_DISPOSABLE`, so the anchor is load-bearing.

The self-reported fifth vacuous-assertion class is also closed: the added content line in
`dirt_build_artifact_plus_content` now reads
`+++ this line is real added content and is not an analyzer path rewrite` and contains no
literal `HintPath`, so the fixture can discriminate.

### R6a — undocumented report-mode exit-code change. **CLOSED (PASS).**

`.claude/skills/cleanup-merged-worktrees/SKILL.md` gained a "Report-mode exit status"
paragraph in the Report Line Contract stating the behaviour and its rationale.
`tests/shell/test_cleanup_worktrees_dirt_regression.bats:128` asserts `status -eq 128`
over `dirty_worktree_status_error` with a positive control on the `WORKTREE|` record and
two absence assertions. AC-43 was added covering it.

### R6b — `DISPOSABLE_SESSION_ARTIFACT` unreachable in this repository. **CLOSED (PASS).**

`SKILL.md` records the verdict as repository-agnostic, inert in drm-copilot because
`.gitignore:6` ignores `/artifacts`, retained for consumer checkouts, and explicitly not to
be made reachable by adding `--ignored`. The inert behaviour is pinned by the test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:365`, which asserts `--ignored` is
absent from the argv log with a `status --porcelain` positive control. AC-44 was added
covering it.

## New Blocking Findings

### N1 — rung 4 reads a pathspec that matched nothing as `CONTENT_ON_MAIN`

- Severity: **FAIL.** Data loss on the feature's own destructive flag.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`.

`git diff --quiet main -- "$rel"` exits 0 both when the working-tree content equals main's
content and when the pathspec matches nothing in either tree. Rung 4's tracked half treats
exit 0 as the former unconditionally. Rung 3 guards against exactly this shape of vacuous
confinement at line 213 (`((total == 0)) && return 1`, with the header comment "A diff pair
with zero changed content lines is NOT a build artifact"); rung 4 has no equivalent guard.

Confirmed against real git 2.53.0 in a scratch repository:

```
$ git diff --quiet main -- "no/such/file.md" ; echo $?
0
$ git add staged_only.md && rm staged_only.md && git status --porcelain
AD staged_only.md
$ git diff --quiet main -- staged_only.md ; echo $?
0
$ git hash-object -- staged_only.md ; echo $?
fatal: could not open 'staged_only.md' for reading: No such file or directory
128
```

An `AD` entry is a file added to the index and then removed from the working tree. Its
content exists only as a staged blob; it is in no commit and not on disk. Driving the
classifier with only those observed exit codes:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||AD|staged_only.md
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
ACTION|dirt-clear|/repo-wt/dirt|OK          (rc 0; reset --hard and clean -fd both ran)
```

`reset --hard` discards the index entry and the blob becomes unreachable. The record also
asserts the content is on `main`, which it is not.

This is not a regression introduced by the R1 fix. A control run with the R1 fix reverted
labels the same entry `STAGED_TREE_IS_COMMIT|eeee7777` and still aggregates
`ALL_DISPOSABLE`, so the entry was disposable before the fix as well. The R1 fix changes
which rung answers it, not whether it clears. The finding is a hole in the delivered
classifier that cycle 1 did not detect, and the whole classifier is new on this branch, so
it is in scope.

Required change: make rung 4's positive answer conditional on the path existing. A
`cleanup_wt_git -C "$wt" ls-files --error-unmatch -- "$rel"` probe, or a check that the
working-tree file exists before trusting exit 0, both close it in the safe direction. A
`diff --quiet` exit 0 over a pathspec that matched nothing must advance the ladder rather
than resolve a verdict.

Required test: a fixture with `AD <path>`, `diff-quiet..<path>.rc` of 0 and
`hash-object.<path>.rc` of 128, asserting the verdict is not `CONTENT_ON_MAIN` and the
aggregate is not `ALL_DISPOSABLE`; plus the positive direction, a genuine tracked entry
whose content does equal main's, so restricting rung 4 does not disable it.

### N2 — four safety guards that no checked-in fixture discriminates

- Severity: **FAIL** against the standing both-directions obligation and against the
  Scenario Completeness clause of `.claude/rules/general-unit-test.md`.
- Locations: `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`,
  `:336-339`.

Each of the four is covered by the coverage report and asserted over by a passing test,
but removing the guard leaves every checked-in scenario's output unchanged. The tests
therefore hold nothing. Each was demonstrated to be safety-load-bearing by constructing a
scenario from exit-code combinations alone:

| Line | Guard | Checked-in scenario that names it | Output with the guard removed | Flips a checked-in scenario? |
|---|---|---|---|---|
| 336-339 | `((lrc != 0))` after `log --find-object` | `dirt_history_read_error` | `CONTENT_IN_HISTORY\|ffff8888` and `ALL_DISPOSABLE` when the failing read also emits stdout | **No** |
| 311-314 | the `((hrc != 0))` clause of the `hash-object` guard | `dirt_classifier_read_error` | `CONTENT_ON_MAIN` and `ALL_DISPOSABLE` when the failing read also emits a blob id | **No** |
| 301-304 | `((drc > 1))` in rung 4's tracked half | `dirt_tracked_read_errors` | `CONTENT_IN_HISTORY` and `ALL_DISPOSABLE` when the entry's blob resolves and is in history | **No** |
| 213 | `((total == 0)) && return 1` vacuous-confinement guard | none | `DISPOSABLE_BUILD_ARTIFACT` and `ALL_DISPOSABLE` for a csproj whose baseline verdict is `UNIQUE`/`HAS_UNIQUE` | **No** |

The mechanism is the same in all four cases: the fixture that exercises the guard supplies
a non-zero exit code *and no stdout*, so a second, weaker condition further down the
function reaches the same verdict. `dirt_history_read_error` gives
`log.find-object.cccc2222.rc` of 128 with no `.out`, so `found` is empty and rung 6 is
reached whether or not line 336 exists. `dirt_classifier_read_error` gives
`hash-object.notes.md.rc` of 128 with no `.out`, so the `[[ -z $blob ]]` clause alone
carries it. `dirt_tracked_read_errors` supplies no `hash-object.docs_tracked.md.out`, so
the entry reaches the empty-blob branch regardless.

Line 213 is the sharpest case: the library header names it as a safety property in its own
paragraph ("Vacuous confinement would let a read that returned nothing resolve to a
disposable verdict, which is the fail-open direction"), and no scenario in the checked-in
set exercises a csproj whose worktree and cached diffs are both empty. Removing it turns a
`UNIQUE`/`HAS_UNIQUE` worktree into `DISPOSABLE_BUILD_ARTIFACT`/`ALL_DISPOSABLE`.

Required change: for each of the four, add a fixture whose failing read also returns
stdout, or whose lower rungs would otherwise resolve to a disposable verdict, so the
guard's removal is observable. The four fixtures are cheap: three are one added `.out` file
on an existing scenario, and the fourth is an existing csproj scenario with both diff
payloads emptied and the lower rungs made a miss.

## Non-Blocking Observations

| ID | Observation |
|---|---|
| O1 | AC-8's text says "no other verdict token is produced by any of the **ten** `dirt_*` scenarios". There are now 25, and the test at `test_cleanup_worktrees_dirt_classify.bats:214` enforces 25 with an on-disk count assertion and a 30-record union assertion. The criterion is satisfied more broadly than its text states; the count is stale documentation, not a false pass. |
| O2 | The `any_staged` pre-scan at `cleanup_worktrees_dirt_lib.sh:377-384` is deliberately ungated on the Y column, so a worktree whose only staged entries are `MM` still issues the bounded `rev-list` walk and up to 200 `diff-index` probes whose result no entry consumes. Verified to produce no wrong verdict: the probe answers a worktree-wide question about the index, and rung 1's Y gate is what decides whether an entry consumes it. Cost only. |
| O3 | The X-only gate on the ` -> ` split leaves a `Y`-column rename (` R`, `MR`) unsplit. Probed against real git 2.53.0: an unstaged rename is reported as ` D` plus `??`, and a staged rename keeps `R` in the X column across four scenarios including a re-rename. No `[ M]R` porcelain output was reproducible. The gate matches observed behaviour; recorded as checked, not as a defect. |
| O4 | `.claude/lib/bash/compute-concurrency-batches.sh` reports 81.82% line coverage, below the 85% floor. It has zero changed lines on this branch. Out of this feature's remit; recorded so it is not lost. |
| O5 | `dirt_build_artifact_added_file` reaches `DISPOSABLE_BUILD_ARTIFACT` for a wholly added csproj. Because the rule requires every changed line to be a `HintPath` rewrite, this can only fire for a project file consisting solely of `HintPath` lines, which is not a valid project file. Not reachable in practice; noted because it is the only place the build-artifact class is asserted over an added file. |

## Deferred Findings — carried, not re-reported

F7 through F13 are deferred whole and F14's documentation half is deferred, with
dispositions recorded in `evidence/other/deferred-findings.2026-09-08T07-00.md`. This
reviewer confirms each disposition names a reason and that F7 and F9 are genuinely blocked
by the 496-line measurement of `cleanup_worktrees_lib.sh`, re-measured at `HEAD` as 496.
F14's acceptance-criteria half is closed by the AC-15 narrowing, which is verified accurate
in `feature-audit.2026-09-08T06-51.md`.

## Blocking Count

**2** (N1 FAIL, N2 FAIL). Remediation cycle 2 opens.
