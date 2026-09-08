# Remediation Plan — cleanup-worktrees dirt classifier (Issue #632), cycle 2

- Timestamp: 2026-09-08T06-51 (UTC)
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/`
- Work mode: `full-bug` (`issue.md:12`). Acceptance-criteria source is `spec.md`,
  `## Acceptance Criteria` section only.
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
- Worktree: `.claude/worktrees/agent-ac72d35e7980bc69d`
- Findings source: `remediation-inputs.2026-09-08T06-51.md`,
  `code-review.2026-09-08T06-51.md`, `feature-audit.2026-09-08T06-51.md`,
  `policy-audit.2026-09-08T06-51.md`
- Blocking findings: 2 (N1, N2). Non-blocking carried into scope: 1 (O1).
- Cycle 1 exit status: all six cycle-1 findings (R1 through R6b) verified closed. This
  cycle does not revisit them; it must not disturb them.

## Scope

Three obligations.

1. **N1** — rung 4's tracked half resolves `CONTENT_ON_MAIN` from a `git diff --quiet`
   exit 0 that also means "the pathspec matched nothing". An `AD` entry, whose content
   exists only as a staged blob, therefore aggregates `ALL_DISPOSABLE` and is destroyed
   by `--clear-disposable`. Data loss.
2. **N2** — four guards at `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301`,
   `:311`, and `:336` whose removal leaves every checked-in `dirt_*` scenario
   byte-identical. Each is covered and named by a passing test that cannot fail when the
   guard is violated.
3. **The systemic finding** — two consecutive cycles have shipped a data-loss defect
   that passed the whole 45-criterion set. Neither N1 nor N2 maps to any criterion. This
   cycle adds the general criterion the reviewer proposed and, more importantly, makes it
   machine-enforced: the guards are enumerated mechanically from the library source, each
   is registered, and a bats gate fails when a registered guard's neutralization changes
   nothing observable.

Out of scope, carried forward unchanged: F7 through F13, F14's documentation half, the
ten residual uncovered lines, and observations O2 through O5. `cleanup_worktrees_lib.sh`
is not modified by this cycle.

## Constraints that bound every task

- `scripts/bash/cleanup_worktrees_dirt_lib.sh` is **463** lines at the start of this
  cycle. `scripts/bash/cleanup_worktrees_lib.sh` is **496** and is excluded from
  modification. No production, test, or reusable shell file may reach 500 lines.
- No temporary files in tests. Every fixture is checked in under
  `tests/fixtures/cleanup_worktrees/scenarios/`.
- Every git call goes through the `cleanup_wt_git` seam; tests drive
  `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`.
- Report mode stays non-mutating. No new subcommand that writes the index or the object
  database may be introduced, and none may be added to
  `tests/fixtures/cleanup_worktrees/stub-bin/git`.
- Both directions of every classification stay pinned.
- All evidence goes to
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
  No `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or
  `artifacts/evidence/` path is valid for evidence in this plan.

## Gate ownership

`shfmt`, `shellcheck`, and `bats` have a local route in this worktree; `bats` is supplied
through the documented `SHELL_QC_BATS_BIN` seam or invoked directly as
`npx --yes bats`. `kcov` has **no** local route: `bash scripts/bash/shell-qc.sh test --coverage`
exits 127 here. Coverage is measured only by a dispatch of
`.github/workflows/_shell-coverage.yml` against a pushed commit, and the numbers are read
from that run's merged Cobertura artifact. No task in this plan asserts a local coverage
figure.

The current measured position, from CI run `34194469882`: 404 tests, 0 failures, 93.7%
repository-wide line coverage, 94.05% on `scripts/bash/cleanup_worktrees_dirt_lib.sh`.

## Design decisions this plan fixes

These are settled here so no task has to choose.

**D1 — the N1 guard.** Rung 4's tracked half keeps `git diff --quiet main -- "$rel"` as
its first read. When that read exits 0, the positive verdict becomes conditional on the
path being present in `main`, probed through the same seam with
`cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"`.
The exit code is captured in the parent shell into a new local `erc`, following the
library's stated capture rule. Only `erc` equal to 0 emits `CONTENT_ON_MAIN`; any other
value falls through without emitting, so the entry advances to the `hash-object` guard,
which is where an `AD` entry fails closed to `UNIQUE`.

`ls-files --error-unmatch` was considered and rejected: an `AD` path is present in the
index, so that probe exits 0 for exactly the entry the guard must catch. `rev-parse
--verify --quiet main:<path>` answers the question the inference actually rests on —
whether `main` has content at that path to be equal to — and it is a read.

The stub already keys `rev-parse --verify --quiet <ref>` as
`rev-parse.verify.<sanitized ref>` at `tests/fixtures/cleanup_worktrees/stub-bin/git:270-271`.
No stub change is required, and no existing scenario supplies that key for a tracked
path, so every existing scenario replays the stub default of exit 0 and its verdict is
unchanged.

The new read is redirected with `>/dev/null` only, **not** with `>/dev/null 2>&1`. The
existing bounded-range probe at `cleanup_worktrees_dirt_lib.sh:331-332` suppresses both
streams, and that is the one shape not to copy here: the stub writes its `stub-git: <argv>`
log to stderr, so `2>&1` would erase this invocation from the argv log and make it
unobservable to every argv assertion and to the `ARGV` row kind defined in D3. `--quiet`
already suppresses real git's own diagnostic on the negative answer, so nothing is gained
by the second redirect.

Reachability of the new read, checked against the current tree so the narrowing does not
change an existing verdict: the read is issued only when `drc` is 0, and of the tracked
entries in the checked-in set only `dirt_rename_split`'s `R ` entry reaches that state.
`dirt_build_artifact_mixed` and `dirt_build_artifact_plus_content` each supply
`diff-quiet..src_Legacy_Legacy.csproj.rc` of `1`, and `dirt_tracked_read_errors` supplies
`diff-quiet..docs_tracked.md.rc` of `128`, so none of the three reaches the new read at
all. `dirt_rename_split` supplies no `rev-parse.verify.main_new.md` fixture and therefore
replays the stub default of exit 0, keeping its `CONTENT_ON_MAIN` verdict.

**D2 — the guard-registry gate.** A guard-shaped line is defined mechanically as any line
in `scripts/bash/cleanup_worktrees_dirt_lib.sh` matching the extended regular expression
`\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)` — an arithmetic comparison of a
variable against a numeric literal. There are exactly 30 such lines at the start of this
cycle and 31 after D1. Each carries a trailing `# guard:<id>` marker. Each appears exactly
once in `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`. A new bats suite
neutralizes each guard by applying a marker-addressed `sed` substitution to the library
**in memory** — no temporary file — checks the result with `bash -n`, evaluates it in a
child shell in place of the real library, and requires an observable difference.

Marker-addressed substitution is what makes the mutation unambiguous: the sed program is
`/# guard:<id>/s/<pattern>/<replacement>/`, so a pattern such as `((drc > 1))` that occurs
on two different lines perturbs only the registered one.

**D3 — registry row kinds.**

| Kind | What the gate proves |
|---|---|
| `SEPARATED` | Under the named scenario, the mutated library's `DIRTSUM\|` aggregate differs from the unmutated library's. |
| `ARGV` | The aggregate is identical, but the stub argv log differs. |
| `EXEMPT` | Neither channel differs. The gate requires only a non-empty `reason`. |

The five guards this cycle remediates must be `SEPARATED`. Every other guard is
classified by observation and recorded with its evidence.

The gate deliberately does **not** re-assert the absence of a difference for an `EXEMPT`
row. Asserting absence would make the gate fail on an improvement: a later change that
gives an exempt guard a separating scenario would break a passing test, which is the wrong
incentive. The `EXEMPT` kind records a classification and forces a written reason; the
`SEPARATED` and `ARGV` kinds are the ones the gate proves.

**D4 — scenario and record counts.** The membership test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:214-252` names each `dirt_*`
scenario explicitly, asserts the iterated count equals the on-disk directory count, and
asserts a literal record total of 30 over 25 scenarios. This cycle adds three scenario
directories carrying four status entries in total, so the end state is 28 scenarios and
34 records. Each task that adds a directory updates the list, the literal, and the
explanatory comment in the same task, so the suite is never left failing on a count.

| Point in the plan | Scenarios | Records |
|---|---:|---:|
| Start | 25 | 30 |
| After Phase 1 | 26 | 32 |
| After Phase 3 | 28 | 34 |

## New scenarios and fixture payloads this plan creates

Fixed here so the acceptance conditions can name concrete literals.

**`dirt_tracked_staged_only_blob`** (Phase 1, two entries)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | `AD staged_only.md` then `M  docs/tracked.md` |
| `diff-quiet..staged_only.md.rc` | `0` |
| `rev-parse.verify.main_staged_only.md.rc` | `1` |
| `hash-object.staged_only.md.rc` | `128` |
| `diff-quiet..docs_tracked.md.rc` | `0` |
| `rev-parse.verify.main_docs_tracked.md.rc` | `0` |

**`dirt_tracked_probe_error_in_history`** (Phase 3, one entry)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | ` M docs/tracked.md` |
| `diff-quiet..docs_tracked.md.rc` | `128` |
| `hash-object.docs_tracked.md.out` | `dddd4444` |
| `log.find-object.dddd4444.out` | `aaaa5555` |

**`dirt_build_artifact_empty_diff`** (Phase 3, one entry)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | ` M src/Legacy/Legacy.csproj` |
| `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` | empty file, zero bytes |
| `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` | empty file, zero bytes |
| `diff-quiet..src_Legacy_Legacy.csproj.rc` | `1` |
| `hash-object.src_Legacy_Legacy.csproj.out` | `bbbb3333` |

Each of the three directories also carries the six non-classifier fixture files copied
verbatim from `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`:
`worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
`rev-parse.show-toplevel.out`, `merge-base.feature-dirt.rc`, `worktree-remove.rc`.

**Additions to two existing scenarios** (Phase 3). Both leave the scenario's emitted
records byte-identical while the guard is present, because the guard returns before the
added payload is read.

| Scenario | Added file | Content |
|---|---|---|
| `dirt_history_read_error` | `log.find-object.cccc2222.out` | `ffff8888` |
| `dirt_classifier_read_error` | `hash-object.notes.md.out` | `bbbb6666` |
| `dirt_classifier_read_error` | `rev-parse.main_notes.md.out` | `bbbb6666` |

## The five remediated guards

| Guard id | Site at cycle start | Mutation substitution | Scenario | Baseline aggregate |
|---|---|---|---|---|
| `build-artifact-vacuous-confinement` | `:213` `((total == 0)) && return 1` | `s/((total == 0))/((0))/` | `dirt_build_artifact_empty_diff` | `HAS_UNIQUE` |
| `rung4-tracked-path-in-main` | new, added by Phase 1 | `s/((erc == 0))/((1))/` | `dirt_tracked_staged_only_blob` | `HAS_UNIQUE` |
| `rung4-tracked-hard-fail` | `:301` `((drc > 1))` | `s/((drc > 1))/((0))/` | `dirt_tracked_probe_error_in_history` | `HAS_UNIQUE` |
| `hash-object-hard-fail` | `:311` `((hrc != 0))` | `s/((hrc != 0))/((0))/` | `dirt_classifier_read_error` | `HAS_UNIQUE` |
| `find-object-hard-fail` | `:336` `((lrc != 0))` | `s/((lrc != 0))/((0))/` | `dirt_history_read_error` | `HAS_UNIQUE` |

Every one of the five must produce `ALL_DISPOSABLE` under mutation. That is the concrete
form of "deleting the guard changes the `DIRTSUM|` aggregate", and for all five the
change is precisely from refusing to clear to clearing.

## Task-ordering note

At the end of Phase 2 the full local bats stage is expected to fail: the new gate suite is
in place and the four N2 fixtures are not, which is the fail-before evidence Phase 3
closes. No acceptance condition in Phase 2 or Phase 3 requires a clean full-suite run.
The first task that requires one is in Phase 5.

---

### Phase 0 — Baseline capture

- [ ] [P0-T1] Read, in this order, `.github/copilot-instructions.md`,
  `.github/instructions/general-code-change.instructions.md`,
  `.github/instructions/general-unit-test.instructions.md`, and `.claude/rules/shell.md`.
  Write `evidence/remediation-baseline/phase0-instructions-read.2026-09-08T07-30.md`
  carrying `Timestamp:`, `Policy Order:`, and the explicit list of the four files read.
  Acceptance: the artifact exists and lists all four paths.

- [ ] [P0-T2] Read the four cycle-2 finding documents in the feature folder:
  `remediation-inputs.2026-09-08T06-51.md`, `code-review.2026-09-08T06-51.md`,
  `feature-audit.2026-09-08T06-51.md`, `policy-audit.2026-09-08T06-51.md`. Write
  `evidence/remediation-baseline/phase0-findings-read.2026-09-08T07-30.md` recording, for
  each of N1 and N2, the file and the line range the finding names. Acceptance: the
  artifact names `scripts/bash/cleanup_worktrees_dirt_lib.sh` with the ranges `294-305`
  for N1 and the four sites `213`, `301-304`, `311-314`, `336-339` for N2.

- [ ] [P0-T3] Run `bash scripts/bash/shell-qc.sh format` and record it in
  `evidence/remediation-baseline/shell-qc-format.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:`. Because `shfmt` in write mode prints
  nothing and exits 0 whether or not it rewrote a file, the exit code alone cannot
  distinguish a clean run from a repairing one, so the artifact must additionally carry two
  before-and-after tree observations taken around the run:
  `git status --porcelain` under the field names `StatusBefore:` and `StatusAfter:`, and a
  digest over the three discovery roots computed with
  `find tools scripts .claude/lib/bash -type f -name '*.sh' 2>/dev/null | LC_ALL=C sort | xargs md5sum | md5sum`
  under the field names `TreeDigestBefore:` and `TreeDigestAfter:`. Acceptance: all four
  fields are present and non-empty, and the artifact states explicitly whether
  `TreeDigestBefore:` and `TreeDigestAfter:` are equal and whether `StatusAfter:` lists any
  path absent from `StatusBefore:`.

- [ ] [P0-T4] Run `bash scripts/bash/shell-qc.sh check` and record it in
  `evidence/remediation-baseline/shell-qc-check.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE:` is recorded and
  the summary states the shfmt-diff and shellcheck findings counts.

- [ ] [P0-T5] Resolve the bats binary with `npx --yes bats --version`, then run the full
  local test stage as
  `env SHELL_QC_BATS_BIN=<resolved path> bash scripts/bash/shell-qc.sh test`. Record
  `evidence/remediation-baseline/shell-qc-test.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `ResolvedBatsVersion:`, the TAP plan line, the count of lines
  beginning `ok`, the count of lines beginning `not ok`, and a field
  `BaselineLocalTestTotal:` carrying the `ok` count. Acceptance: `EXIT_CODE:` is `0`, the
  `not ok` count is `0`, and `BaselineLocalTestTotal:` is a number the later delta task
  compares against.

- [ ] [P0-T6] Record the coverage baseline from the last successful CI coverage run rather
  than from any local invocation. Write
  `evidence/remediation-baseline/shell-coverage.2026-09-08T07-30.md` carrying
  `Timestamp:`, `Command:` naming the `gh` read used, `EXIT_CODE:`,
  `BaselineRepoLineCoverage: 93.7`, `BaselineDirtLibLineCoverage: 94.05`, `Threshold: 85.0`,
  the run id `34194469882`, and a per-file table for the eight
  `scripts/bash/cleanup_worktrees*` files with their current percentages. Acceptance: both
  headline numeric fields are present as numbers, and the artifact states explicitly that
  `kcov` has no local route in this worktree and that
  `bash scripts/bash/shell-qc.sh test --coverage` exits 127 here.

- [ ] [P0-T7] Measure the guard-shaped line count in the classifier library with
  `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  and the marked-guard count with
  `grep -c '# guard:' scripts/bash/cleanup_worktrees_dirt_lib.sh`. Record both in
  `evidence/remediation-baseline/guard-enumeration.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `Output Summary:`, and the full numbered list of the matching
  lines. Acceptance: the guard-shaped count is `30`, the marked count is `0`, and the
  artifact lists thirty line numbers.

- [ ] [P0-T8] Measure the current line count of every shell file this cycle may touch with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record it in `evidence/remediation-baseline/file-size-limit.2026-09-08T07-30.md`.
  The same artifact also records `StubDigest:`, the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`, which P5-T5 compares against to show
  this cycle added no stub arm. Acceptance:
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` is recorded as `463`,
  `scripts/bash/cleanup_worktrees_lib.sh` as `496`, `StubDigest:` is present and
  non-empty, and the artifact states the remaining headroom to 500 for each file.

- [ ] [P0-T9] Measure the current scenario and record counts. Run
  `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`
  and read the two literals in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`. Record
  `evidence/remediation-baseline/scenario-counts.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `OnDiskScenarioCount:`, and `AssertedRecordTotal:`. Acceptance:
  `OnDiskScenarioCount:` is `25` and `AssertedRecordTotal:` is `30`.

- [ ] [P0-T10] Run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and record `evidence/remediation-baseline/pytest-push-down-contract.2026-09-08T07-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed
  count. Acceptance: `EXIT_CODE:` is `0` and the summary records `11 passed`.

---

### Phase 1 — N1: rung 4's tracked half must not resolve from an empty pathspec

- [ ] [P1-T1] Create the scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/` and copy
  into it, verbatim, the six non-classifier fixture files listed in this plan's fixture
  section from `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`. Acceptance: for
  each of the six filenames, `cmp -s` between the `dirt_unique` copy and the new copy exits
  `0`, and `git status --porcelain tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob`
  lists the new directory as untracked.

- [ ] [P1-T2] Write the six classifier fixture files for
  `dirt_tracked_staged_only_blob` exactly as tabulated in this plan's fixture section:
  `status._repo-wt_dirt.out`, `diff-quiet..staged_only.md.rc`,
  `rev-parse.verify.main_staged_only.md.rc`, `hash-object.staged_only.md.rc`,
  `diff-quiet..docs_tracked.md.rc`, and `rev-parse.verify.main_docs_tracked.md.rc`.
  Acceptance: `status._repo-wt_dirt.out` has exactly two lines, its first line is
  `AD staged_only.md`, and the five `.rc` files contain `0`, `1`, `128`, `0`, and `0`
  respectively.

- [ ] [P1-T3] Add a test titled
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`
  to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, driving
  `classify_worktree_dirt` through the existing `dirt` helper. It asserts the record
  `DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md`, the record
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of the substrings
  `CONTENT_ON_MAIN||AD|` and `ALL_DISPOSABLE`. Acceptance: the `@test` title appears once
  in that file.

- [ ] [P1-T4] Add the positive-direction test titled
  `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN`
  to the same file, asserting the record
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md` from the same scenario.
  Acceptance: the `@test` title appears once in that file, and both new tests name the
  same scenario, so one probe result serves both directions.

- [ ] [P1-T5] `[expect-fail]` Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  before any library change and record
  `evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and the verbatim TAP
  lines for the two new tests. Acceptance: the output contains a line beginning `not ok`
  whose text ends with
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`,
  and a line beginning `ok ` whose text ends with
  `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN`.
  The second line proves the fixture drives the ladder rather than failing to load.

- [ ] [P1-T6] Apply decision D1 to `scripts/bash/cleanup_worktrees_dirt_lib.sh`: declare
  `erc=0` among the locals of `classify_dirt_entry`, and inside the existing
  `if ((drc == 0)); then` branch of rung 4's tracked half, issue
  `cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"`
  with its exit code captured into `erc` in the parent shell, redirected with `>/dev/null`
  and **not** with `>/dev/null 2>&1` for the reason given in D1, and emit `CONTENT_ON_MAIN`
  only under `if ((erc == 0)); then`. A non-zero `erc` emits nothing and falls through.
  The two literals this task creates, quoted here verbatim so the searches below have a
  defined target: `main:$rel` and `((erc == 0))`.
  Acceptance: `grep -cF 'main:$rel' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
  `2`, where it reported `1` before this task because rung 4's untracked half already
  carries that token; `grep -cF '((erc == 0))' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`; and `grep -cF '2>&1' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
  `1`, unchanged from the single pre-existing occurrence on the bounded-range probe, which
  is the wrap-independent way to show the new read did not acquire a stderr redirect.

- [ ] [P1-T7] Extend the library's header comment block with a paragraph explaining why
  rung 4's tracked positive answer is conditional, in the same register and layout as the
  existing `TWO-WAY CLASSIFICATION OF NON-ZERO EXITS` and `NO --ignored ON THE STATUS READ`
  paragraphs: `diff --quiet` exits 0 both when the compared content is identical and when
  the pathspec matched nothing, and only the first meaning supports a disposable verdict.
  Following the file's convention, the paragraph opens with an all-capital heading
  sentence, and this plan fixes that heading verbatim as `EMPTY PATHSPEC IS NOT A MATCH.`
  so the acceptance search has a short single-line target that cannot be split by
  rewrapping. Acceptance:
  `grep -cF 'EMPTY PATHSPEC IS NOT A MATCH.' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`.

- [ ] [P1-T8] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record `evidence/regression-testing/pass-after-rung4-path-in-main.2026-09-08T08-00.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, the TAP plan line, and the `ok`/`not ok`
  counts. Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`, and the output
  contains a line beginning `ok ` whose text ends with
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`.

- [ ] [P1-T9] Update the membership test in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`: add
  `dirt_tracked_staged_only_blob` to the explicit scenario list, change the asserted
  record literal from `30` to `32`, and update the explanatory comment above it so the
  stated scenario count and two-entry count match. Acceptance:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  exits 0 with 0 lines beginning `not ok`, and
  `grep -c 'dirt_tracked_staged_only_blob' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  reports `1`.

- [ ] [P1-T10] Re-run the three suites that exercise the rung-4 tracked half or the
  non-mutation property, to confirm the narrowing disturbed nothing:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`.
  Record `evidence/regression-testing/sibling-check-phase1.2026-09-08T08-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, plan line, and `ok`/`not ok` counts. The artifact
  must also record the sibling-region check stated in D1: for each of
  `dirt_rename_split`, `dirt_build_artifact_mixed`, `dirt_build_artifact_plus_content`,
  and `dirt_tracked_read_errors`, the `drc` value the scenario produces and whether the new
  read was therefore issued. Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`,
  the artifact records that `dirt_rename_split`'s `R ` entry still resolves
  `CONTENT_ON_MAIN`, and it records that the three scenarios whose `diff-quiet` fixture is
  non-zero did not reach the new read.

---

### Phase 2 — Mechanical guard enumeration, the registry, and the enforcement gate

- [ ] [P2-T1] Append a `# guard:<id>` trailing comment to every guard-shaped line in
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`. Ids are lowercase, hyphen-separated, and
  unique. The five ids named in this plan's guard table are mandatory and must be spelled
  exactly as tabulated. No line is added or removed by this task; only trailing comments
  are appended. Acceptance:
  `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `31`, `grep -c '# guard:' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
  `31`, and `grep -o '# guard:[a-z0-9-]*' scripts/bash/cleanup_worktrees_dirt_lib.sh | sort | uniq -d`
  produces no output.

- [ ] [P2-T2] Verify the marker pass changed no behaviour: re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
  and record `evidence/regression-testing/marker-pass-neutral.2026-09-08T08-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, plan line, `ok`/`not ok` counts, and the line
  count of the library before and after the marker pass. Acceptance: `EXIT_CODE:` is `0`,
  the `not ok` count is `0`, and the two line counts are equal.

- [ ] [P2-T3] Create `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` with a
  leading comment line documenting the columns and one tab-separated row per guard,
  columns in this order: `id`, `kind`, `scenario`, `baseline_aggregate`, `mutation`,
  `reason`. Populate the five rows named in this plan's guard table with kind `SEPARATED`
  and the scenario, aggregate, and substitution given there; leave `reason` empty for
  them. Acceptance: the file exists, `grep -c $'\t' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
  reports at least `5`, and each of the five literals
  `build-artifact-vacuous-confinement`, `rung4-tracked-path-in-main`,
  `rung4-tracked-hard-fail`, `hash-object-hard-fail`, and `find-object-hard-fail` appears
  exactly once in the file.

- [ ] [P2-T4] Create `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` with a
  header stating its subject and the mechanism, and with a helper that, given a guard id,
  reads the registry row, builds the marker-addressed sed program
  `/# guard:<id>/s/<pattern>/<replacement>/`, applies it to the library with `sed` to a
  shell variable, rejects the result if `bash -n` fails, and evaluates it in a child shell
  in place of sourcing the real library. The helper creates no file on disk. Acceptance:
  the file exists, `grep -c 'bash -n' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `1`, and `grep -c 'mktemp' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `0`.

- [ ] [P2-T5] Add the enumeration test titled
  `every guard-shaped line in the dirt library is marked and registered exactly once` to
  that suite. It derives the marked id set from the library, derives the row id set from
  the registry, and asserts: the guard-shaped line count equals the marked line count;
  every marked id has exactly one registry row; every registry row has exactly one marked
  id; and no id is duplicated in either. Acceptance: the `@test` title appears once in the
  file, and the test body reads the id set from
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` rather than from a list written in the
  suite.

- [ ] [P2-T6] Add the separation test titled
  `every registered guard is observable under its own neutralization` to that suite. For
  each registry row it captures the unmutated and mutated runs of the named scenario and
  requires: for `SEPARATED`, the `DIRTSUM|` aggregate field differs; for `ARGV`, the
  aggregate is identical and the `stub-git: ` argv log differs; for `EXEMPT`, the `reason`
  column is non-empty. It also asserts, for every row, that the sed program actually
  changed the source. Offending ids are printed to stderr before the assertion so a
  failure names them. Acceptance: the `@test` title appears once in the file, and the test
  prints the offending ids on failure.

- [ ] [P2-T7] Add the third test titled
  `the five guards remediated in cycle 2 are registered SEPARATED` to that suite,
  asserting each of the five ids has kind `SEPARATED` in the registry. This is what stops
  a later downgrade to `EXEMPT` from silently reopening N1 or N2. Acceptance: the `@test`
  title appears once in the file, and the five ids are named as literals in the test body.

- [ ] [P2-T8] Complete the registry: add a row for each of the 26 guards not named in this
  plan's guard table, classifying each by observation. For each, run the harness against a
  scenario that exercises it, observe whether the `DIRTSUM|` aggregate changes, whether
  only the argv log changes, or whether neither changes, and set the kind to `SEPARATED`,
  `ARGV`, or `EXEMPT` accordingly. Every `EXEMPT` row carries a non-empty `reason` stating
  the mechanism that makes the guard unobservable through this seam. This task completes
  the registry before the fail-before run, so the only failures that run reports are
  separation failures rather than a mixture of separation and enumeration failures.
  Acceptance:
  `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `31`,
  every row's kind column is one of the three literals `SEPARATED`, `ARGV`, `EXEMPT`, and
  every `EXEMPT` row has a non-empty final column.

- [ ] [P2-T9] Record the classification evidence in
  `evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md`: a table of all 31
  ids with the library line each marks, the kind, the scenario, and the observed difference
  or its absence. Acceptance: the table has 31 rows, the counts of `SEPARATED`, `ARGV`, and
  `EXEMPT` are stated and sum to 31, and every `EXEMPT` row's reason is reproduced.

- [ ] [P2-T10] `[expect-fail]` Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  with the registry complete at 31 rows and the four N2 fixtures not yet present.
  Record `evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and the verbatim TAP
  output. Acceptance: the output contains a line beginning `not ok` whose text ends with
  `every registered guard is observable under its own neutralization`; the diagnostic
  names all four of `build-artifact-vacuous-confinement`, `rung4-tracked-hard-fail`,
  `hash-object-hard-fail`, and `find-object-hard-fail`, and does **not** name
  `rung4-tracked-path-in-main`, whose Phase 1 fixture already separates it; and the other
  two tests each report a line beginning `ok `, so the failure observed is a separation
  failure and not an enumeration or registry-shape failure.

- [ ] [P2-T11] Record the harness design in
  `evidence/other/guard-registry-design.2026-09-08T08-30.md`, stating the guard-shaped
  line regular expression verbatim, the three row kinds and what the gate proves for each,
  why the sed program is marker-addressed rather than pattern-only, and why the mutated
  source is evaluated from a shell variable rather than written to disk. Acceptance: the
  artifact contains the regular expression and names all three kinds.

---

### Phase 3 — The four separating fixtures

- [ ] [P3-T1] Add `log.find-object.cccc2222.out` containing `ffff8888` to
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_history_read_error/`. Acceptance: the
  file exists with that single line, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  still exits 0 with 0 lines beginning `not ok`, proving the existing
  `dirt_history_read_error` verdict is unchanged while the guard is present.

- [ ] [P3-T2] Add `hash-object.notes.md.out` containing `bbbb6666` and
  `rev-parse.main_notes.md.out` containing `bbbb6666` to
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_classifier_read_error/`. Acceptance:
  both files exist with that single line each, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  exits 0 with 0 lines beginning `not ok`, proving the `UNIQUE` verdict and the refused
  clear are unchanged while the guard is present.

- [ ] [P3-T3] Create
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_probe_error_in_history/` with
  the six copied non-classifier files and the four classifier files tabulated in this
  plan's fixture section. Acceptance: `status._repo-wt_dirt.out` contains the single line
  ` M docs/tracked.md`, `diff-quiet..docs_tracked.md.rc` contains `128`,
  `hash-object.docs_tracked.md.out` contains `dddd4444`, and
  `log.find-object.dddd4444.out` contains `aaaa5555`.

- [ ] [P3-T4] Create
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_empty_diff/` with the
  six copied non-classifier files and the five classifier files tabulated in this plan's
  fixture section, including the two zero-byte diff payloads. Acceptance:
  `wc -c tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_empty_diff/diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out`
  reports `0`, the cached counterpart also reports `0`,
  `diff-quiet..src_Legacy_Legacy.csproj.rc` contains `1`, and
  `hash-object.src_Legacy_Legacy.csproj.out` contains `bbbb3333`.

- [ ] [P3-T5] Add two tests to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`,
  titled
  `dirt_tracked_probe_error_in_history: a rung-4 hard read failure is UNIQUE even when the blob is in history`
  and
  `dirt_build_artifact_empty_diff: a csproj whose diff pair is empty is UNIQUE not a build artifact`.
  The first asserts `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|docs/tracked.md`,
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of `CONTENT_IN_HISTORY`. The second
  asserts `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj`,
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of `DISPOSABLE_BUILD_ARTIFACT`.
  Acceptance: both `@test` titles appear once in that file and the suite exits 0 with 0
  lines beginning `not ok`.

- [ ] [P3-T6] Update the membership test in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`: add
  `dirt_tracked_probe_error_in_history` and `dirt_build_artifact_empty_diff` to the
  explicit scenario list, change the asserted record literal from `32` to `34`, and update
  the explanatory comment so its stated scenario count is 28 and its two-entry count is 6.
  Acceptance: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  exits 0 with 0 lines beginning `not ok`, and
  `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`
  reports `28`.

- [ ] [P3-T7] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  and record `evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, and the `ok`/`not ok` counts.
  Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`, and the output contains a
  line beginning `ok ` whose text ends with
  `every registered guard is observable under its own neutralization`. This is the
  pass-after half of P2-T10 and the proof that all five remediated guards now change the
  `DIRTSUM|` aggregate under neutralization.

- [ ] [P3-T8] Record the per-guard separation evidence in
  `evidence/qa-gates/guard-separation-probe.2026-09-08T09-00.md`, giving for each of the
  five remediated ids: the scenario, the unmutated `DIRTSUM|` line, the mutated `DIRTSUM|`
  line, and the mutated `DIRTFILE|` verdict. Acceptance: all five ids appear, every
  unmutated aggregate recorded is `HAS_UNIQUE`, and every mutated aggregate recorded is
  `ALL_DISPOSABLE`.

---

### Phase 4 — Acceptance criteria and documentation

- [ ] [P4-T1] Correct the stale count in AC-8 of
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`: the
  criterion's phrase naming the number of `dirt_*` scenarios becomes twenty-eight. The box
  stays checked; this is a text correction to a criterion the code already exceeds.
  Acceptance: `grep -c 'ten `dirt_\*` scenarios' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `0`, and `grep -c 'twenty-eight' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`.

- [ ] [P4-T2] Append AC-46 to the `## Acceptance Criteria` section of `spec.md` as an
  **unchecked** box: rung 4's tracked half resolves `CONTENT_ON_MAIN` only when the path
  is present in `main`; a `diff --quiet` exit 0 over a pathspec matching nothing in either
  tree advances the ladder rather than resolving a verdict, so an `AD` entry whose content
  exists only as a staged blob is `UNIQUE` and its worktree is `HAS_UNIQUE`; both
  directions are pinned by a single checked-in fixture carrying one `AD` entry and one
  tracked entry whose content is present in `main`. Acceptance:
  `grep -c '^- \[ \] AC-46 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`.

- [ ] [P4-T3] Append AC-47 to the same section as an **unchecked** box: every guard-shaped
  line in `scripts/bash/cleanup_worktrees_dirt_lib.sh`, enumerated mechanically as every
  line carrying an arithmetic comparison of a variable against a numeric literal, carries
  a `# guard:` marker, appears exactly once in
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, and is proven observable by
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`, which neutralizes each
  guard in an in-memory copy of the library and requires the named scenario's `DIRTSUM|`
  aggregate to change, or its stub argv log to change, or the row to carry a stated
  reason; the five guards remediated in cycle 2 are registered as separating the
  aggregate; a guard-shaped line with no marker, or a marker with no registry row, fails
  the suite. Acceptance:
  `grep -c '^- \[ \] AC-47 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`.

- [ ] [P4-T4] Reconcile the criterion count. Record
  `evidence/other/ac-count-reconciliation.2026-09-08T09-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the total checkbox count inside the `## Acceptance Criteria`
  section, the checked count, and the unchecked count, and state that the two unchecked
  boxes are AC-46 and AC-47. Acceptance: the artifact records a total of `47`, a checked
  count of `45`, and an unchecked count of `2`.

- [ ] [P4-T5] Add one sentence to the `DIRTFILE|` bullet of the Report Line Contract in
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` stating that `CONTENT_ON_MAIN` is
  emitted for a tracked entry only when `main` contains the path, so an entry whose
  content exists only as a staged blob is reported `UNIQUE` rather than as content that is
  already on `main`. Acceptance:
  `grep -c 'only when `main` contains the path' .claude/skills/cleanup-merged-worktrees/SKILL.md`
  reports `1`.

- [ ] [P4-T6] Mirror the edited skill file to
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  and verify byte identity with `md5sum` over both paths. Record
  `evidence/qa-gates/skill-mirror-parity.2026-09-08T09-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and both digests. Acceptance: the two recorded digests are
  identical and the artifact states so explicitly.

- [ ] [P4-T7] Run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and record `evidence/qa-gates/pytest-push-down-contract.2026-09-08T09-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed count.
  Acceptance: `EXIT_CODE:` is `0` and the summary records `11 passed`.

---

### Phase 5 — Final QA loop, coverage, and reconciliation

- [ ] [P5-T1] Run `bash scripts/bash/shell-qc.sh format` and record
  `evidence/qa-gates/shell-qc-format.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `Output Summary:`, and the same four observation fields defined in P0-T3 —
  `StatusBefore:`, `StatusAfter:`, `TreeDigestBefore:`, `TreeDigestAfter:` — computed with
  the identical commands. Acceptance: `EXIT_CODE:` is `0`, all four fields are present, and
  the artifact states whether the write-mode run rewrote any file. If the two digests
  differ, the toolchain loop restarts from this task after the rewrite is reviewed.

- [ ] [P5-T2] Run `bash scripts/bash/shell-qc.sh check` and record
  `evidence/qa-gates/shell-qc-check.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, and `Output Summary:` stating the shfmt-diff finding count and the
  shellcheck finding count. Acceptance: `EXIT_CODE:` is `0` and both counts are `0`.

- [ ] [P5-T3] Run the full local test stage as
  `env SHELL_QC_BATS_BIN=<resolved path> bash scripts/bash/shell-qc.sh test` and record
  `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the TAP plan line, the `ok` count, the `not ok` count, and a field
  `PostChangeLocalTestTotal:`. This plan adds exactly seven tests and removes none: two in
  P1-T3 and P1-T4, three in P2-T5 through P2-T7, and two in P3-T5. Acceptance: `EXIT_CODE:`
  is `0`, the `not ok` count is `0`, and `PostChangeLocalTestTotal:` equals
  `BaselineLocalTestTotal:` from P0-T5 plus exactly `7`. The artifact enumerates the seven
  added `@test` titles so the delta is attributable rather than merely arithmetic.

- [ ] [P5-T4] Confirm the file-size limit with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record `evidence/qa-gates/file-size-limit.2026-09-08T10-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and the per-file counts with the headroom to 500 for each.
  Acceptance: every recorded count is at or under `500`, and the artifact states the
  classifier library's count and the number of lines it grew relative to the `463`
  recorded in P0-T8.

- [ ] [P5-T5] Confirm report mode is still non-mutating after the new probe was added.
  Run `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  and record `evidence/qa-gates/report-mode-non-mutating.2026-09-08T10-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the `ok`/`not ok` counts, an explicit statement
  that the subcommand added by P1-T6 is `rev-parse`, which reads and does not write, and
  the field `StubDigest:` recomputed as the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`. Acceptance: `EXIT_CODE:` is `0`, the
  `not ok` count is `0`, and the recomputed `StubDigest:` equals the value P0-T8 recorded,
  which is what shows this cycle added no arm to the stub. The comparison is made against
  the cycle-start digest rather than against the epic base, because cycle 1 legitimately
  changed the stub and a base-anchored diff would report those changes as this cycle's.

- [ ] [P5-T6] Stage the cycle-2 changes with `git add -A`, commit them, and push the
  branch. Record `evidence/other/remediation-commit-and-push.2026-09-08T10-00.md` with
  `Timestamp:`, the commands, `EXIT_CODE:` for each, the branch name, the
  `git status --porcelain` output taken immediately after `git add -A` and before the
  commit, and the list of changed paths obtained from
  `git diff --name-only origin/epic/cleanup-merged-worktrees-hardening-integration`
  after the commit. The staged-status span is recorded because an anchored name-listing
  diff enumerates tracked changes only and would not show the fixture directories this
  cycle creates until they are staged. Acceptance: the push command's `EXIT_CODE:` is `0`
  and the recorded path list contains `scripts/bash/cleanup_worktrees_dirt_lib.sh`,
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, and
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`.

- [ ] [P5-T7] Dispatch the coverage workflow against the pushed branch with
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`,
  wait for the run to conclude, and record
  `evidence/qa-gates/shell-coverage-dispatch.2026-09-08T10-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the run id, the run conclusion, the run's head SHA, and the
  TAP figures from the run log. Acceptance: the recorded conclusion is `success`, the
  recorded `not ok` count is `0`, and the recorded head SHA equals the commit P5-T6
  pushed, recorded as an observation rather than asserted against a literal written into
  this plan.

- [ ] [P5-T8] Download that run's merged Cobertura artifact and read the figures directly
  from `kcov-merged/cov.xml`. Record
  `evidence/qa-gates/dirt-lib-coverage.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `PostChangeRepoLineCoverage:`, `PostChangeDirtLibLineCoverage:`,
  `Threshold: 85.0`, and the covered-over-total line pair for
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`. Acceptance: both percentage fields are
  numbers, both are at or above `85.0`, and the artifact states that kcov measures no
  branch coverage so no branch gate applies to bash.

- [ ] [P5-T9] Compare against the P0-T6 baseline and record
  `evidence/qa-gates/coverage-delta.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `BaselineRepoLineCoverage:`, `PostChangeRepoLineCoverage:`,
  `BaselineDirtLibLineCoverage:`, `PostChangeDirtLibLineCoverage:`, a per-file table
  covering the eight `scripts/bash/cleanup_worktrees*` files with a "fell below baseline"
  column, and a changed-lines section naming the region P1-T6 added and the test that
  executes it. Acceptance: no file's post-change percentage is below its baseline
  percentage, and the changed-lines section names
  `dirt_tracked_staged_only_blob` as the fixture that executes the new guard in both
  directions.

- [ ] [P5-T10] Check off AC-46 and AC-47 in `spec.md` and record
  `evidence/other/ac-checkoff.2026-09-08T10-00.md` with `Timestamp:`, the evidence artifact
  path supporting each of the two criteria, the total checkbox count inside the
  `## Acceptance Criteria` section, and the checked count. Acceptance: the artifact records
  a total of `47` and a checked count of `47`, and
  `grep -c '^- \[ \] AC-4' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `0`.

- [ ] [P5-T11] Record the single-consecutive-pass declaration in
  `evidence/qa-gates/single-consecutive-pass.2026-09-08T10-00.md`, listing the four local
  stages in order — format, lint, test, contract — with each stage's artifact path and
  exit code, and stating that the four ran consecutively with no intervening edit.
  Acceptance: all four stages are listed with exit code `0`, and the artifact names the
  coverage stage as CI-measured with its run id rather than claiming a local run.

- [ ] [P5-T12] Write the cycle-2 closing summary at
  `evidence/other/cycle2-closure.2026-09-08T10-00.md`, stating for each of N1, N2's four
  sites, the systemic gate, and O1 the change made, the test that holds it, and the
  evidence artifact. Then stage and commit the documentation and evidence written after
  P5-T6 — the spec check-off from P5-T10, the coverage artifacts from P5-T7 through P5-T9,
  the declaration from P5-T11, and this summary — and push, so the branch tip carries the
  complete cycle rather than only its code half. Acceptance: the artifact names all seven
  items and, for each of the five remediated guards, names the registry row that now
  separates it; and after the push,
  `git status --porcelain docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632`
  produces no output, which is the observation that no evidence file was left uncommitted.

---

## Evidence index

| Kind | Path |
|---|---|
| Baseline | `evidence/remediation-baseline/*.2026-09-08T07-30.md` |
| Regression testing | `evidence/regression-testing/*.2026-09-08T08-00.md`, `*.2026-09-08T08-30.md`, `*.2026-09-08T09-00.md` |
| QA gates | `evidence/qa-gates/*.2026-09-08T08-30.md`, `*.2026-09-08T09-00.md`, `*.2026-09-08T09-30.md`, `*.2026-09-08T10-00.md` |
| Other | `evidence/other/guard-registry-design.2026-09-08T08-30.md`, `evidence/other/ac-count-reconciliation.2026-09-08T09-30.md`, `evidence/other/remediation-commit-and-push.2026-09-08T10-00.md`, `evidence/other/ac-checkoff.2026-09-08T10-00.md`, `evidence/other/cycle2-closure.2026-09-08T10-00.md` |

Task-to-artifact map for the two artifacts whose phase moved during authoring:
`evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md` is written by P2-T9,
and there is no separate Phase 4 gate re-run artifact: the completed registry's clean gate
run is recorded by P3-T7 and again by the full local test stage at P5-T3.

All evidence paths in this plan resolve under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
No `artifacts/` sub-path is used for evidence.
