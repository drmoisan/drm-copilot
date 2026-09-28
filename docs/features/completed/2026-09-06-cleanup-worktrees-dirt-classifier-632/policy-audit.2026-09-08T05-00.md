# Policy Audit — cleanup-worktrees dirt classifier (Issue #632)

- Timestamp: 2026-09-08T05-00
- HostClockAtWrite: 2026-09-08T03-17Z (nominal run-timestamp scheme, continuing the
  scheme used by this feature's evidence artifacts)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
- Commit under review: `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
- Base (resolved): `origin/epic/cleanup-merged-worktrees-hardening-integration` at
  `4ffe680ebcebaabbba10faaa490e46a717686535` (epic integration branch, not `main`)
- Work mode: `full-bug` (from `issue.md`); AC source is `spec.md` only
- Reviewer: feature-review agent

## Scope

The audit scope is the full branch diff against the resolved base:
217 files changed, 4626 insertions, 153 deletions.

Languages with changed files on this branch:

| Language | Changed files | In scope |
|---|---|---|
| bash / bats | `scripts/bash/*.sh` (4), `tests/shell/*.bats` (11), `tests/fixtures/cleanup_worktrees/stub-bin/git` | Yes |
| Markdown | `SKILL.md` (canonical + mirror), spec/plan/evidence | Yes (documentation policy only) |
| Fixture data | `tests/fixtures/cleanup_worktrees/scenarios/**`, `expected/**` | Yes (test-asset policy) |
| TypeScript | 0 | No |
| Python | 0 | No |
| PowerShell | 0 | No |
| C# | 0 | No |

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope, limit it to a plan/task/phase,
mark a language "informational only", or skip a toolchain or coverage check. The caller
supplied a known-state list (coverage in flight, stale plan citations, three accepted
`@test`-body exceptions), which is context rather than narrowing. Nothing to record here.

The one point where I depart from the caller's framing is stated openly rather than
silently: the caller asked that AC-31/AC-32 be evaluated as PENDING. I do so in the
feature-audit. Separately, the mandatory coverage gate in this agent's own contract is
evaluated on its own terms below, and a coverage artifact landed at this exact commit
during the review (see Coverage Verification), so the gate is evaluated on real evidence
rather than deferred.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are ABSENT in
this worktree. `artifacts/` contains only `orchestration/` and an empty `pester/`.

Mitigation taken, recorded as an assumption: scope and evidence were derived directly from
`git diff <base>..HEAD`, from the feature folder documents, and from first-hand execution
of the changed code against both the base tree and the head tree. No conclusion in this
audit rests on a PR-context artifact. The regeneration path was not taken because it would
write to `artifacts/`, and every finding below was obtainable from the diff itself.

## Policy Reading Order Followed

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md` (path-scoped: `**/*.sh`, `**/*.bats`, `scripts/bash/**`,
   `tests/shell/**`)
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`

## Verdict Summary

| # | Policy area | Verdict |
|---|---|---|
| P1 | Tone (`tonality.md`) | PASS |
| P2 | File size limit (500 lines) | PASS |
| P3 | shfmt formatting | PASS (independently re-run) |
| P4 | shellcheck linting | PASS (independently re-run) |
| P5 | Type checking | N/A (bash; `shell.md` states no type-check stage) |
| P6 | Architecture-boundary tests | N/A (no architecture tooling for bash) |
| P7 | Unit tests (bats) | PASS (390 tests, 0 failures, per CI run 34182198357) |
| P8 | Contract / schema compatibility | PASS (record contract additive; verified below) |
| P9 | Integration tests | N/A (no integration tier for this tool) |
| P10 | Single consecutive clean pass | PARTIAL — see P10 |
| P11 | Coverage — bash repo-wide | PASS (92.9% >= 85.0%) |
| P12 | Coverage — new file | **FAIL** (82.63% < 85.0%) |
| P13 | Coverage — branch (bash) | N/A by rule (kcov measures no branch coverage) |
| P14 | Coverage exclusions | PASS (none added; no `exclude` entry touched) |
| P15 | Test file location | PASS |
| P16 | No temporary files in tests | PASS |
| P17 | Determinism infrastructure | PASS |
| P18 | Scenario completeness (both directions) | **FAIL** — see P18 |
| P19 | Error handling / fail-fast | PARTIAL — see P19 |
| P20 | Dependencies | PASS (none added) |
| P21 | I/O boundaries | PASS |
| P22 | Public API compatibility | PARTIAL — see P22 |
| P23 | `.claude/**` mirror parity | PASS (byte-identical) |
| P24 | Evidence location compliance | PASS |
| P25 | Module rigor tier classification | PASS (no new project entry required) |

Blocking verdicts: P12, P18. Blocking-PARTIAL verdicts: P10, P19, P22.

---

## P1 — Tone

All prose added by this change — the library header, the function docstrings, the test
suite headers, the SKILL.md amendments, and the evidence artifacts — is factual, measured,
and free of humour, hyperbole, and decorative metaphor. The evidence artifacts are notably
disciplined about evidence-first wording: `single-consecutive-pass-blocked.2026-09-08T03-30.md`
declines to use the declaration filename precisely because the loop was incomplete, and
`shell-qc-test-coverage.2026-09-08T04-30.md` states "P7-T5 fails" about the author's own
work. **PASS.**

## P2 — File Size Limit

Measured at review time (`wc -l`):

| File | Lines | Limit |
|---|---|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` (new) | 425 | 500 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 500 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | 500 |
| `scripts/bash/cleanup-worktrees.sh` | 187 | 500 |
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` (new) | 300 | 500 |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` (new) | 283 | 500 |
| `tests/shell/test_cleanup_worktrees_dirt_regression.bats` (new) | 126 | 500 |
| `tests/shell/test_cleanup_worktrees_cli.bats` | 150 | 500 |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 362 | 500 |

Maximum 496. The decision to place the classifier in a new sibling library rather than
extend `cleanup_worktrees_lib.sh` (479 lines at the time of scoping) is the correct
response to the cap. **PASS.**

## P3 / P4 — Formatting and Linting

Independently re-run at this commit, not taken from the executor's evidence:

```
shfmt -d <the five changed shell files>        -> no diff, EXIT 0
shellcheck -x <the five changed shell files>   -> no findings, EXIT 0
```

`shfmt` and `shellcheck` were present natively on this host. The one suppression added by
this change, `# shellcheck disable=SC2034` at `scripts/bash/cleanup-worktrees.sh:145`, is
line-scoped and carries an inline justification naming the two cross-library consumers of
`CLEANUP_WT_CLEAR_DISPOSABLE`, which satisfies `shell.md`'s "justified inline" requirement.
**PASS both.**

## P7 — Unit Tests

CI run 34182198357 at headSha `ad6bc946bbf0ad9e69756b2155eae19771a232d8`: TAP plan
`1..390`, 390 `ok`, 0 `not ok`. That is +47 over the 343-test baseline at
`4ffe680e`. `bats` is not installed on this host, so the suite was not re-run
first-hand; the CI figure is at the exact commit under review and is treated as
authoritative per `shell.md` ("CI versions are canonical"). **PASS.**

## P8 — Record Contract Compatibility

The record contract is the public interface of this tool. I verified additivity
first-hand by extracting the base tree with `git archive 4ffe680e` and replaying every
pinned scenario through the BASE libraries, then comparing against the checked-in
expected files this branch adds:

```
MATCH  report.merged_with_worktree      MATCH  report.residual_on_main
MATCH  report.merged_no_worktree        MATCH  report.residual_unique_doc
MATCH  report.unmerged                  MATCH  report.current_exclusion
MATCH  report.content_neutral           MATCH  report.main_divergence
MATCH  apply.dirty_worktree             MATCH  apply.dirty_worktree_status_error
fail=0
```

All ten `tests/fixtures/cleanup_worktrees/expected/*.out` files reproduce the BASE tree's
output byte for byte. They are new files (`git diff --name-status` shows `A` for all ten),
and they were genuinely captured pre-change, so the byte-identity pins in
`test_cleanup_worktrees_dirt_regression.bats` are able to fail. This is the single most
load-bearing regression claim in the change and it holds.

Field counts and relative order confirmed unchanged for `BRANCH|`, `COMMIT|`, `WORKTREE|`,
`WARN|`, `ACTION|`, and the three-field `DIRTY|`. `DIRTY|` remains emitted only from
`remove_worktree_safe`, which is textually unmodified. **PASS.**

One qualification is carried to P22: stdout is byte-identical, but the report-mode *exit
code* is not.

## P10 — Single Consecutive Clean Pass

Per `general-code-change.md`, the loop must complete with every stage passing in one pass.

| Stage | Result at `ad6bc946` | Source |
|---|---|---|
| 1 format | EXIT 0, before/after digests identical | executor artifact + my re-run |
| 2 lint | EXIT 0, no findings | executor artifact + my re-run |
| 3 type check | N/A for bash | `shell.md` |
| 5 test | EXIT 0, 390/390 | CI run 34182198357 |
| coverage | EXIT 0, 92.9% repo-wide | CI run 34182198357 |

Every stage that ran, passed. The loop is nonetheless **not declarable complete**, because
P12 and P18 below require new test scenarios, and adding them restarts the loop from stage 1.
The executor's own artifact `single-consecutive-pass-blocked.2026-09-08T03-30.md` reaches
the same conclusion for a different reason and correctly refuses to write the declaration
filename. **PARTIAL (blocking).**

## P11 / P12 / P13 — Coverage Verification

Coverage artifact for bash per `shell.md` is the merged Cobertura report at
`artifacts/pester/kcov/cov.xml` (or `SHELL_QC_KCOV_OUT_DIR`). No such file exists in this
worktree. However, a coverage run against this exact commit completed during the review
window and its results are recorded at
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`,
sourced from the `shell-coverage` artifact of CI run 34182198357 at headSha
`ad6bc946bbf0ad9e69756b2155eae19771a232d8`. That is a real measurement of the tree under
review, so the coverage gate is evaluated rather than deferred.

**P11 — repo-wide bash line coverage: 92.9%. Threshold 85.0%. PASS.** Baseline at the
resolved base was 93.5%; the 0.6-point movement is the arithmetic effect of adding a
425-line file below the family average, not a regression on any pre-existing line.

**P13 — branch coverage: not evaluated.** kcov measures line coverage only.
`quality-tiers.md` and `general-unit-test.md` both exempt bash from the branch threshold
because the tooling cannot produce the figure. No FAIL is recorded for the absent number,
and the spec correctly does not assert one (AC-32 states "no branch-coverage gate applies
to bash, and none is asserted").

**P12 — new-file line coverage: `scripts/bash/cleanup_worktrees_dirt_lib.sh` at 82.63%
(138/167 instrumented lines). Threshold 85.0% under the uniform tier rule. FAIL.**

This is the lowest-covered file in the family. Per-file figures from `kcov-merged/cov.xml`:

| File | Line coverage |
|---|---|
| `cleanup_worktrees_dirt_lib.sh` | **82.63%** |
| `cleanup_worktrees_scan_helper.sh` | 86.79% |
| `cleanup_worktrees_report_records_lib.sh` | 89.01% |
| `cleanup_worktrees_enumerate_lib.sh` | 92.13% |
| `cleanup_worktrees_actions_lib.sh` | 94.08% |
| `cleanup_worktrees_lib.sh` | 95.41% |
| `cleanup-worktrees.sh` | 97.44% |
| `cleanup_worktrees_detached_lib.sh` | 100.00% |

No modified file regressed: every pre-existing file is at or above its family position and
all clear 85% except `scan_helper` (86.79%) and `report_records_lib` (89.01%), both of
which clear the threshold and neither of which this branch modifies.

The distribution of the 29 uncovered lines is the substantive problem, not the 2.4-point
shortfall. They are:

- `95`, `98` — the staged-tree probe's `rev-list` hard-failure return.
- `113`, `114` — the staged-tree probe's `diff-index` exit-above-1 hard-failure return.
- `117` — the staged-tree probe's ordinary "no candidate matched" return.
- `148`, `151`, `155` — the HintPath diff read's failure return.
- `160` — a diff-line `case` arm.
- `190`, `191` — the build-artifact filename fallthrough.
- `233`, `234` — rung 1's `staged == "ERROR"` → `UNIQUE` fail-closed emission.
- `258`, `259`, `273`, `274`, `308`, `309` — the remaining fail-closed `UNIQUE` emissions.
- `269`, `270` — the tracked-half `CONTENT_ON_MAIN` emission (one of two sites).
- `305` — `log --find-object` read-failure capture.
- `343` — the staged-probe return propagation in `classify_worktree_dirt`.
- `415`, `416` — the `ACTION|dirt-clear|<path>|FAILED` record for a failed `reset --hard`.
- `74`–`77` — the session-artifact constant array (see P22/F7 for why this one is not
  merely an artefact of measurement).

That set is close to an exact enumeration of the fail-closed machinery — the branches that
decide what happens when a classifier git read fails. Fail-closed behaviour is the single
property that prevents this tool from reporting "safe to delete" about content that exists
nowhere else. AC-13 supplies one `dirt_classifier_read_error` scenario and it exercises one
of these sites (`hash-object`); a read failure at any other site reaches a line no test has
executed.

I verified two of the uncovered branches behave correctly by driving them directly, so the
residual risk is that they are *unpinned*, not that they are wrong today:

```
REPRO C  staged entry, index matches no ancestor tree
         -> DIRTFILE|/repo-wt/dirt|UNIQUE||M |src/a.cs   DIRTSUM|...|HAS_UNIQUE|   correct
REPRO D  staged entry, rev-list exits 128
         -> DIRTFILE|/repo-wt/dirt|UNIQUE||M |src/a.cs   DIRTSUM|...|HAS_UNIQUE|   correct
```

Remediation: add scenario entries that drive the uncovered fail-closed branches. The
executor's own coverage artifact reaches the same conclusion and records it as "a finding
requiring a new scenario entry, not a waiver".

## P14 — Coverage Exclusions

No coverage configuration file is touched by this branch. The kcov include pattern
(`tools/`, `scripts/`, `.claude/lib/bash/`) is unchanged and the new library sits under
`scripts/`, so it is in the denominator, which the 82.63% figure confirms. No production
path was excluded. **PASS.**

## P15 — Test File Location

All new tests are under `tests/shell/` and mirror `scripts/bash/`:
`cleanup_worktrees_dirt_lib.sh` → `test_cleanup_worktrees_dirt_classify.bats`,
`test_cleanup_worktrees_dirt_clear.bats`, `test_cleanup_worktrees_dirt_regression.bats`.
No test file was placed in the production tree. **PASS.**

## P16 — No Temporary Files in Tests

Every scenario is a checked-in directory under
`tests/fixtures/cleanup_worktrees/scenarios/`. Every suite header states "No temporary
files; no scratch git repositories" and the bodies bear that out: no `mktemp`, no
`$BATS_TMPDIR`, no scratch repository creation. The `git` binary itself is replaced by the
checked-in stub through `CLEANUP_WT_GIT_BIN`, so no test can reach a real repository.
**PASS.**

## P17 — Determinism

No `sleep`, no wall-clock read, no randomness. Every git response is a canned `.out`/`.rc`
file. The stub is stateless, which the clear-path suite header calls out explicitly as the
reason the retry's own outcome is not asserted — an honest statement of a harness limit
rather than a papered-over one. **PASS.**

## P18 — Scenario Completeness (Both Directions)

`general-unit-test.md` requires positive flows, negative flows, edge cases, and
error-handling behaviour for each unit. This feature carries the stronger standing
obligation that each of the six verdicts be pinned in both directions.

| Verdict | Positive pin | Near-miss pin | Verdict |
|---|---|---|---|
| `DISPOSABLE_BUILD_ARTIFACT` | `dirt_build_artifact` | `dirt_build_artifact_mixed` (one non-HintPath diff line) | PASS |
| `DISPOSABLE_SESSION_ARTIFACT` | `dirt_session_artifact` | `dirt_quoted_path` (C-quoted path whose unquoted prefix is a listed path) | PASS |
| `CONTENT_ON_MAIN` | `dirt_content_on_main` | `dirt_unique`, `dirt_content_in_history` | PASS |
| `CONTENT_IN_HISTORY` | `dirt_content_in_history` | `dirt_unique` | PASS |
| `STAGED_TREE_IS_COMMIT` | `dirt_staged_tree_is_commit` | only `dirt_build_artifact` (X column is a space) | **FAIL** |
| `UNIQUE` | `dirt_unique`, `dirt_classifier_read_error`, `dirt_build_artifact_mixed`, `dirt_quoted_path` | every disposable scenario | PASS |

Five of six are pinned properly, and the near-misses chosen for those five are well
targeted — `dirt_quoted_path` in particular is an intelligent choice, because its unquoted
prefix is exactly a session-artifact path, so it fails both a prefix match and an unquoting
implementation.

`STAGED_TREE_IS_COMMIT` is the exception, and it is the verdict where a false positive is
most expensive: it is the only verdict that declares *staged, tracked, modified* content
disposable. The single near-miss pinned is "the X column is a space, so rung 1 does not
fire". Three near-misses that matter are absent:

1. A staged entry whose index matches **no** ancestor commit tree. Nothing pins that the
   probe's no-match return produces something other than `STAGED_TREE_IS_COMMIT`.
   `dirt_staged_tree_is_commit` is the only scenario in the entire fixture set with a
   non-space X column, and its probe matches.
2. A rung-1 **hard read failure** (`rev-list` non-zero, or `diff-index` above 1). The
   `staged == "ERROR"` → `UNIQUE` branch at lines 232–235 is executed by no test, which
   kcov confirms (lines 233, 234 uncovered). AC-13's `dirt_classifier_read_error` scenario
   uses an untracked entry, so the probe never runs at all in it.
3. A staged entry that **also carries an unstaged worktree modification** (`MM`, `AM`).
   This one is not merely unpinned — it is a live defect, detailed in the code review as
   F1.

**FAIL.**

## P19 — Error Handling and Fail-Fast

The library's fail-closed discipline is, in the main, correct and unusually well
documented. The "TWO-WAY CLASSIFICATION OF NON-ZERO EXITS" header block draws exactly the
right distinction between a probe whose non-zero exit is its defined negative answer
(`rev-parse main:<path>`, `diff --quiet main`) and one whose non-zero carries no verdict
(`status`, `hash-object`, `log --find-object`, `diff-index` above 1), and notes that
collapsing the two would make `CONTENT_IN_HISTORY` unreachable. Every git read whose exit
code is authoritative is captured in the parent shell with `out=$(cmd) || rc=$?`, never
inside a pipeline. I found no path on which a non-zero classifier read advances toward a
clear.

Three deductions:

- The `run_report` call site uses `classify_worktree_dirt "$wpath" || rc=$?`, which
  overwrites `rc` rather than taking the maximum, in a function whose own docstring says it
  "Returns the maximum return code observed". A classifier failure (rc 1) can therefore
  mask a higher `run_report_scans` rc (rc 2). The non-max idiom is pre-existing at the
  adjacent `report_detached_worktrees` line; this change adds a second instance rather than
  introducing the pattern. Detail in the code review as F10.
- `cleanup_worktrees_lib.sh` now calls `classify_worktree_dirt`, a function it neither
  sources nor guards for. A consumer that sources the report libraries without the dirt
  library gets rc 127 swallowed by the `||` and a report with all dirt classification
  silently missing. Detail as F9.
- `clear_disposable_dirt` is invoked whenever `remove_worktree_safe` returns non-zero, not
  only when the failure was dirt. `remove_worktree_safe` returns 1 for any
  `git worktree remove` failure and always labels it `BLOCKED-DIRTY`, so the hook can fire
  for a locked or otherwise unremovable worktree. The clear still refuses unless every
  entry is disposable, so this is a widening of *when* the clear may run, not of *what* it
  may destroy. Detail as F12.

**PARTIAL (blocking on F9 only; F10 and F12 are advisory).**

## P20 — Dependencies

No new dependency. The library uses only `git`, `printf`, `awk`, and bash builtins, all
already in use by the sibling libraries. **PASS.**

## P21 — I/O Boundaries

Every git call routes through `cleanup_wt_git`, the existing seam, so the classifier is
fully testable without a repository — which the 390-test suite demonstrates. Pure decision
logic (`dirt_is_session_artifact`, the diff-line confinement loop, the aggregate rule) is
separated from the git-backed probes. **PASS.**

## P22 — Public API / Behaviour Compatibility

Stdout compatibility is proven (P8). Two behavioural changes on the default, unflagged path
are not covered by any acceptance criterion and not pinned by any test:

**Report-mode exit code.** Verified first-hand by running `run_report` under the
`dirty_worktree_status_error` scenario against both trees:

```
HEAD report-mode exit code = 128
BASE report-mode exit code = 0
```

The wrapper propagates this (`run_report || exit_code=$?` then `return "$exit_code"`), so
`bash scripts/bash/cleanup-worktrees.sh` now exits 128 in a checkout where any candidate
worktree's `status --porcelain` fails, where previously it exited 0 and produced a full
report. AC-16 pins report-mode *stdout* for eight scenarios, none of which has a failing
status read; `dirty_worktree_status_error` is pinned only in apply mode. `SKILL.md` gained
no note about report-mode exit status. The intent (a read failure must not be mistaken for
a clean worktree) is defensible and stated in the library docstring, but the consequence
for the caller is undocumented and untested. Detail as F6.

**Reachability of `DISPOSABLE_SESSION_ARTIFACT` in this repository.** All three hard-coded
session-artifact paths are gitignored here:

```
$ git check-ignore -v artifacts/pr_context.summary.txt \
      artifacts/pr_context.appendix.txt artifacts/orchestration/orchestrator-state.json
.gitignore:6:/artifacts   artifacts/pr_context.summary.txt
.gitignore:6:/artifacts   artifacts/pr_context.appendix.txt
.gitignore:6:/artifacts   artifacts/orchestration/orchestrator-state.json
```

The library reads status without `--ignored` by deliberate design, so ignored files are
never classified. Confirmed empirically: `artifacts/orchestration/orchestrator-state.json`
exists on disk in this worktree and does not appear in `git status --porcelain`. Rung 2
therefore cannot fire against a real checkout of this repository; it fires only against
hand-written fixture status lines that real git would not emit. This is consistent with
kcov reporting lines 74–77 (the constant array) as uncovered. This is an efficacy gap
against the issue's own primary evidence, not a safety gap, and it needs a recorded
resolution. Detail as F7.

**PARTIAL (blocking).**

## P23 — `.claude/**` Mirror Parity

Exactly one `.claude/**` file changed, and its mirror changed with it. Verified
independently:

```
fbe6ef448196d4ee371285c025db53fc919c25db881095eb5e04ab6d4d610537
  .claude/skills/cleanup-merged-worktrees/SKILL.md
fbe6ef448196d4ee371285c025db53fc919c25db881095eb5e04ab6d4d610537
  extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
```

Byte-identical. No other `.claude/**` path appears in the branch diff, so there is no
unmirrored edit. **PASS.**

## P24 — Evidence Location Compliance

`git diff --name-only <base>..HEAD | grep -E '^artifacts/'` returns nothing. Every evidence
artifact this branch adds is under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`
with `<kind>` in `{baseline, qa-gates, regression-testing, other}`. No file was written to
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`.
No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose. **PASS.**

One housekeeping note, not a violation: the coverage artifact
`evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md` is present in the working
tree but **untracked**. It is in the canonical location; it is simply not yet committed, so
it is not in the branch diff and would not travel with the PR.

## P25 — Module Rigor Tier

The change adds a file to an existing project, not a new project, so no
`quality-tiers.yml` entry is required and none was added. The uniform coverage thresholds
applied above (85% line, no bash branch gate) are the tier-independent ones, which is
correct under Authoritative Decision #2.

## Assumptions Recorded

1. PR context artifacts were absent; scope was derived from the branch diff and first-hand
   execution instead. No finding depends on them.
2. `bats` and `kcov` are not installed on this host. Test-count and coverage figures are
   taken from CI run 34182198357 at the exact commit under review, which `shell.md`
   designates canonical. `shfmt` and `shellcheck` were available and were re-run
   first-hand.
3. The three `@test`-body hunks in `test_cleanup_worktrees_deletion.bats` were confirmed by
   inspection to change only inline `bash -c` source lists; no assertion text differs.
4. Stale plan citations recorded in `evidence/other/plan-to-tree-drift.2026-09-08T01-30.md`
   were not re-reported as deviations.
