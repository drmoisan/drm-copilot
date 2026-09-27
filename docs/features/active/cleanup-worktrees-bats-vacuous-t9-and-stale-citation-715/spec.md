# cleanup-worktrees-bats-vacuous-t9-and-stale-citation (Spec)

- **Issue:** #715
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-45
- **Status:** Draft
- **Version:** 0.2

## Context

- Summary: the review of issue #594 (PR #705) found two test-quality defects in the
  `cleanup-worktrees` bats suites: a negative assertion in test 9 ("T9") of
  `tests/shell/test_cleanup_worktrees_deletion.bats` that cannot fail under the mutation it
  is meant to guard against, and a stale production line-number citation in a comment block
  in `tests/shell/test_cleanup_worktrees_dirt_clear.bats`.
- Observed environment(s): any (bats runs under WSL locally and on `ubuntu-latest` in CI;
  the defect is in test source, not in an environment-dependent code path).
- Customer impact and severity: Low. No production behavior is affected. The impact is a
  reduced ability of the test suite to detect a specific regression (an ordering change to
  the protected-base guard in `delete_candidate`) and an increasing risk that a future
  reader of the stale citation is misdirected to the wrong line.
- First observed date and version(s) impacted: found during the #594 code review dated
  2026-09-27 (`code-review.2026-09-27T02-18.md`, rows 35-36); present in the suite as
  merged in PR #705.

## Repro & Evidence

- Steps to reproduce:
  1. Open `tests/shell/test_cleanup_worktrees_deletion.bats`, test
     `"delete_candidate refuses the base branch before re-verification"` (T9).
  2. Observe the assertion `[[ "$output" != *"merge-base"* ]]`.
  3. `classify_ancestry` (`scripts/bash/cleanup_worktrees_lib.sh`) issues
     `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1`, redirecting both
     stdout and stderr. The stub records its argv only to its own stderr
     (`tests/fixtures/cleanup_worktrees/stub-bin/git`), which is exactly the stream this
     call redirects away. The assertion is therefore true whether or not `merge-base` ran,
     for this call site.
  4. Separately, `tests/shell/test_cleanup_worktrees_dirt_clear.bats` line 14 cites
     `scripts/bash/cleanup-worktrees.sh:145` for the `--clear-disposable` flag pre-pass;
     the assignment `CLEANUP_WT_CLEAR_DISPOSABLE=1` is at line 197 on the current branch.
- Expected vs actual behavior: T9's forbidden-call assertion should fail if the guard order
  it is meant to pin is changed; today it cannot fail under that mutation because the call
  it names is never observable via the channel it inspects. The comment citation should
  identify the flag pre-pass regardless of future line movement in
  `scripts/bash/cleanup-worktrees.sh`; today it is already 52 lines stale.
- Logs/screenshots/error snippets: `docs/features/potential/2026-09-26-cleanup-worktrees-bats-vacuous-t9-and-stale-citation.md`
  (source issue body); `research/research.2026-09-27T00-30.md` in this feature folder
  (full call-path analysis, §1.1-1.3).
- Frequency / determinism: always (the vacuity is structural, not intermittent — it holds
  for every scenario that redirects the `merge-base` call the same way `classify_ancestry`
  does).

## Scope & Non-Goals

- In scope:
  - `tests/shell/test_cleanup_worktrees_deletion.bats`: replace the vacuous negative
    assertion in T9 with one that can observe the named guard-ordering regression.
  - `tests/shell/test_cleanup_worktrees_dirt_clear.bats`: replace the stale
    `scripts/bash/cleanup-worktrees.sh:145` line-number citation, and the two
    `tests/shell/test_cleanup_worktrees_deletion.bats:47` citations in the same header
    comment block, with stable text anchors.
  - A static falsifiability trace demonstrating that the new T9 assertion can fail under
    the named mutation, recorded as an evidence artifact, since bats cannot be executed in
    this agent worktree.
- Out of scope / non-goals:
  - Any change to production script behavior. No file under `scripts/` is modified by this
    fix (see Root Cause Analysis and AC7).
  - Any change to `tests/fixtures/cleanup_worktrees/stub-bin/git` or any other shared
    fixture. The stub's redirection-sensitive behavior is depended on by other suites
    (e.g., the "OBSERVABILITY" comment in `test_cleanup_worktrees_dirt_clear.bats`).
  - Re-deriving a new line number for the stale citation. A re-derived line number
    reproduces the defect class the issue reports.
  - Any file touched by sibling issue #706
    (`scripts/bash/cleanup_worktrees_scan_helper.sh`,
    `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
    `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`) — no overlap exists with
    the files this fix changes.

## Root Cause Analysis

- Confirmed root cause (T9): `classify_ancestry` (`scripts/bash/cleanup_worktrees_lib.sh`)
  calls `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1`. The stub
  binary (`tests/fixtures/cleanup_worktrees/stub-bin/git`) writes its argv record only to
  its own stderr, which this call site redirects to `/dev/null` along with stdout. No other
  channel records the call. `[[ "$output" != *"merge-base"* ]]` is therefore true
  independent of whether `merge-base` executed, for any caller using this redirection
  pattern.
- Additional confirmed finding, deeper than the redirection issue above: for the T9
  scenario (`base_not_checked_out`, branch name `main` equal to `CLEANUP_WT_BASE_BRANCH`),
  `compute_protected` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh`) unconditionally
  classifies `main` as `PROTECTED_CURRENT` before `classify_ancestry` is ever reached.
  Under the guard-ordering mutation named in the issue (moving the protected-base check in
  `delete_candidate` to after `reverify_delete_eligible`), `reverify_delete_eligible`
  resolves `classify_branch("main")` to `PROTECTED_CURRENT`, prints
  `ACTION|delete|main|BLOCKED-REVERIFY`, and returns before `classify_ancestry` — and
  therefore `merge-base` — is ever called. No channel change to the `merge-base` call
  itself (spy, stub fd change, or redirection fix) can make an uncalled command
  observable. A forbidden-call assertion for this test must instead target a call that
  *is* issued as soon as `reverify_delete_eligible` runs, which the guard-ordering mutation
  would then expose.
- The unconditional, unredirected candidate call identified: `compute_protected` issues
  `cleanup_wt_git rev-parse --abbrev-ref HEAD` via plain command substitution
  (`current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?`), and
  `classify_branch` captures `compute_protected`'s own output the same way, without
  redirecting stderr in either capture. The stub's `stub-git: rev-parse --abbrev-ref HEAD`
  line therefore reaches `$output` under `bats run` whenever `reverify_delete_eligible`
  runs. Today, T9's direct `delete_candidate` driver returns before
  `reverify_delete_eligible` is ever called, so this line does not appear. Under the named
  mutation, it would be the first observable side effect of the now-earlier
  `reverify_delete_eligible` call.
- Confirmed root cause (stale citation): `tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  line 14 cites `scripts/bash/cleanup-worktrees.sh:145` as the location of the
  `--clear-disposable` flag pre-pass. On the current branch, `main()`'s comment describing
  this pre-pass is at line 167 and the assignment `CLEANUP_WT_CLEAR_DISPOSABLE=1` is at
  line 197 — the citation has drifted by 52 lines and will continue to drift with any
  unrelated edit to `cleanup-worktrees.sh`. The same header comment block also cites
  `tests/shell/test_cleanup_worktrees_deletion.bats:47` twice (lines 21 and 39); these are
  accurate today (line 47 is the `run env ... CLEANUP_WT_STUB_SCENARIO="${SCEN}/unmerged"`
  line of test `"a candidate whose re-verification flips is blocked before any branch
  delete"`) but carry the same latent line-drift exposure and sit in the exact block
  already being edited for the primary citation fix.
- Affected components/modules (paths): test files only —
  `tests/shell/test_cleanup_worktrees_deletion.bats`,
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats`. The production modules read (not
  modified) during root-cause analysis are `scripts/bash/cleanup_worktrees_actions_lib.sh`
  (`delete_candidate`, `reverify_delete_eligible`),
  `scripts/bash/cleanup_worktrees_lib.sh` (`classify_branch`, `classify_ancestry`), and
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (`compute_protected`).

## Proposed Fix

### Design summary (what changes where)

Two test-file-only edits, no production-code change:

1. In `tests/shell/test_cleanup_worktrees_deletion.bats`, in the `@test` named
   `"delete_candidate refuses the base branch before re-verification"`, replace the line
   `[[ "$output" != *"merge-base"* ]]` with a negative assertion over
   `"rev-parse --abbrev-ref HEAD"`, plus an inline comment explaining why `merge-base`
   itself cannot serve as the forbidden-call signal for this scenario. The existing
   `[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]` assertion, and the two
   other negative assertions already present in the same test (forbidding
   `"worktree remove"` and `"branch -D"`), are retained unchanged.
2. In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, in the header comment block
   (lines 1-48), replace the `scripts/bash/cleanup-worktrees.sh:145` citation with a text
   anchor naming `main()` and the literal assignment `CLEANUP_WT_CLEAR_DISPOSABLE=1`. In
   the same comment block, replace the two
   `tests/shell/test_cleanup_worktrees_deletion.bats:47` citations with a text anchor
   naming the target `@test`, `"a candidate whose re-verification flips is blocked before
   any branch delete"`.

### Boundaries and invariants to preserve

- No change to `scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
  `scripts/bash/cleanup-worktrees.sh`, or any other file under `scripts/`.
- No change to `tests/fixtures/cleanup_worktrees/stub-bin/git` or any other file under
  `tests/fixtures/cleanup_worktrees/`.
- The `@test` named `"delete_candidate refuses the base branch before removing its linked
  worktree"` (the second base-branch test in `test_cleanup_worktrees_deletion.bats`) is
  unaffected; it carries no `merge-base` assertion and needs no change.
- The `"OBSERVABILITY"` comment in `test_cleanup_worktrees_dirt_clear.bats` documenting the
  redirection behavior of `classify_ancestry` is preserved as-is; it is not one of the
  citations named in scope.

### Dependencies or blocked work

None. The fix requires no coordination with sibling issue #706 or any other concurrently
open `cleanup-worktrees` branch; the file set edited here (`test_cleanup_worktrees_deletion.bats`,
`test_cleanup_worktrees_dirt_clear.bats`) does not overlap with #706's file set
(`scripts/bash/cleanup_worktrees_scan_helper.sh`,
`tests/shell/test_cleanup_worktrees_scan_helper.bats`,
`tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`).

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change:

- `tests/shell/test_cleanup_worktrees_deletion.bats`
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats`

#### Functions/classes/CLI commands impacted:

- No production function, class, or CLI command is impacted. The edited assertions target
  the existing behavior of `delete_candidate`, `reverify_delete_eligible`,
  `classify_branch`, and `compute_protected` (all in `scripts/bash/`) as already
  implemented; none of these functions is modified.

#### Data flow and validation changes:

- None. This is a test-assertion and comment-text change; no runtime data flow changes.

#### Error handling and logging updates:

- None.

#### Rollback/feature-flag considerations (if applicable):

- Not applicable. The change is confined to test source; reverting the two edited files
  restores the prior (defective) test state with no other effect.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats:

- No interface or contract change. `bats` invocation, exit codes, and `$output` capture
  semantics are unchanged.

#### Required configuration keys and defaults:

- None.

#### Backward-compatibility expectations:

- Not applicable; test-only change with no consumer outside the CI shell-coverage job.

#### Performance constraints (latency/throughput/memory):

- Not applicable.

## Assumptions, Constraints, Dependencies

- Assumptions: `bats` is not runnable inside this agent worktree because the Bash
  isolation guard refuses text containing `bash`/`pwsh`/`wsl`; verification of the bats
  suite itself is deferred to the CI shell-coverage job.
- Constraints: no production-code change is permitted (AC7); the fix must not alter or
  depend on changes to the shared stub `tests/fixtures/cleanup_worktrees/stub-bin/git`.
- External dependencies: CI workflow `.github/workflows/_shell-coverage.yml`, invoked from
  `.github/workflows/ci.yml`, runs `bash scripts/bash/shell-qc.sh test --coverage` (which
  internally invokes `bats tests/shell`) as the authoritative test gate for this change.

## Data / API / Config Impact

- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: none.

## Test Strategy

- Regression tests to add or update:
  - `tests/shell/test_cleanup_worktrees_deletion.bats`, `@test`
    `"delete_candidate refuses the base branch before re-verification"`: replace the
    vacuous `merge-base` negative assertion with a negative assertion over
    `"rev-parse --abbrev-ref HEAD"`.
  - `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, header comment block (lines
    1-48): replace the stale `scripts/bash/cleanup-worktrees.sh:145` citation and the two
    `tests/shell/test_cleanup_worktrees_deletion.bats:47` citations with text anchors.
- Edge cases and negative scenarios: the `"delete_candidate refuses the base branch before
  removing its linked worktree"` test is confirmed unaffected and requires no edit; its
  existing assertions remain the regression backstop for the linked-worktree base-branch
  path.
- Error handling and logging verification: not applicable (test-source-only change).
- Coverage impact and targets for changed lines/modules: no production line is added,
  removed, or changed; the existing >= 85% line-coverage gate for
  `scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `scripts/bash/cleanup_worktrees_lib.sh`, and `scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  is unaffected by this change.
- Toolchain commands to run: `bash scripts/bash/shell-qc.sh format`,
  `bash scripts/bash/shell-qc.sh check`, `bash scripts/bash/shell-qc.sh test`, and
  `bash scripts/bash/shell-qc.sh test --coverage` (the last reproduces the CI
  shell-coverage step exactly). All four require WSL or CI; none can run inside this
  agent worktree.
- Manual validation steps: because `bats` cannot run in this agent worktree, falsifiability
  of the new T9 assertion is demonstrated by a static call-path trace (not a live
  mutation-and-revert run), recorded as an evidence artifact at
  `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other/<timestamp>-falsifiability-trace.md`.
  The trace records, by citing the relevant source lines: (a) under the current code, the
  protected-base guard in `delete_candidate` returns before `reverify_delete_eligible` is
  called, so no `rev-parse --abbrev-ref HEAD` call reaches `$output`; and (b) under the
  named mutation (moving the guard to after `reverify_delete_eligible` in
  `delete_candidate`, `scripts/bash/cleanup_worktrees_actions_lib.sh`), the call sequence
  `classify_branch` -> `compute_protected` issues `cleanup_wt_git rev-parse --abbrev-ref
  HEAD` unredirected, which the stub logs to stderr and which the new assertion would then
  detect. The trace does not commit a mutated production file; the mutation is described,
  not applied, in the tree.

## Acceptance Criteria

- [x] AC1: In `tests/shell/test_cleanup_worktrees_deletion.bats`, the `@test`
      `"delete_candidate refuses the base branch before re-verification"` replaces the
      assertion `[[ "$output" != *"merge-base"* ]]` with a negative assertion asserting the
      absence of `"rev-parse --abbrev-ref HEAD"` in `$output`.
- [x] AC2: In the same `@test`, the assertion
      `[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]` and the assertions
      forbidding `"worktree remove"` and `"branch -D"` in `$output` remain present and
      unchanged.
- [x] AC3: No citation of the form `scripts/bash/cleanup-worktrees.sh:<line-number>` remains
      anywhere in `tests/shell/test_cleanup_worktrees_dirt_clear.bats`; the replacement text
      names `main()` and the literal assignment `CLEANUP_WT_CLEAR_DISPOSABLE=1`.
- [x] AC4: No citation of the form
      `tests/shell/test_cleanup_worktrees_deletion.bats:47` remains anywhere in
      `tests/shell/test_cleanup_worktrees_dirt_clear.bats`.
- [x] AC5: A falsifiability trace artifact exists at
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other/<timestamp>-falsifiability-trace.md`,
      showing by source-line citation both (i) that no `rev-parse --abbrev-ref HEAD` call
      reaches `$output` under the current guard ordering in `delete_candidate`, and (ii)
      that such a call would reach `$output`, unredirected, if the protected-base guard in
      `delete_candidate` were moved to after `reverify_delete_eligible`.
- [ ] AC6: The CI shell-coverage job (`.github/workflows/_shell-coverage.yml`, invoked from
      `.github/workflows/ci.yml`) passes for the branch head, with every test in
      `tests/shell/test_cleanup_worktrees_deletion.bats` and
      `tests/shell/test_cleanup_worktrees_dirt_clear.bats` passing.
- [x] AC7: No file under `scripts/` is changed by this branch.

## Risks & Mitigations

- Risk: without a live `bats` run available in this agent worktree, the new T9 assertion's
  falsifiability rests on static call-path analysis rather than an executed
  mutate-and-revert cycle. Mitigation: the CI shell-coverage job (AC6) executes the actual
  `bats` suite on every PR into `main`/`development` and is the authoritative pass/fail
  gate; the static trace (AC5) is a supplementary, auditable record of the reasoning, not a
  substitute for CI execution.
- Risk: a future edit to `scripts/bash/cleanup-worktrees.sh` could rename `main()` or the
  `CLEANUP_WT_CLEAR_DISPOSABLE` variable, which would make the new text anchor stale in the
  same way the old line-number citation was. Mitigation: a text anchor drifts only on a
  rename, which is a far less frequent event than a line-number shift from any unrelated
  edit; this is the same trade-off the researcher's D3 recommendation accepts.
- Risk: sibling PRs for issues #706-716 editing other parts of the `cleanup-worktrees`
  suite could reintroduce a conflict if a text anchor's target (a function or `@test` name)
  is renamed concurrently. Mitigation: this fix identifies every edit location by text
  anchor (the `@test` name, the literal assertion line, the citation text) rather than by
  line number, and touches no file listed in sibling issue #706's file set.

## Rollout & Follow-up

- Release/rollout steps: standard PR merge; no feature flag or staged rollout applies to a
  test-only change.
- Post-fix monitoring or clean-up tasks: none identified beyond confirming the CI
  shell-coverage job passes on the branch head (AC6).
- Links: issue #715; source potential-lifecycle record
  `docs/features/potential/2026-09-26-cleanup-worktrees-bats-vacuous-t9-and-stale-citation.md`;
  research `research/research.2026-09-27T00-30.md` (this feature folder); related PR #705
  (issue #594); sibling issue #706.

## Design Decisions

- **D1 — T9 assertion mechanism.**
  - Options: (a) a function-override spy redefining `cleanup_wt_git`/`classify_ancestry`
    inside the `bash -c` driver to echo a sentinel on a non-redirected fd; (b) assert
    absence of `"rev-parse --abbrev-ref HEAD"` — the first unredirected call
    `reverify_delete_eligible` issues via `classify_branch` -> `compute_protected`; (c)
    change the shared stub to log argv to a channel the caller's redirection does not
    swallow; (d) remove the vacuous line and rely solely on the existing
    `BLOCKED-PROTECTED-BASE` token assertion.
  - Decision: (b).
  - Rationale: (a) has no repository precedent (no `.bats` file in the repo redefines a
    sourced production function as a spy) and is moot regardless, because `merge-base` is
    never called for the base branch under either the current code or the named mutation
    (§ Root Cause Analysis); a spy on a call that never fires cannot observe anything. (c)
    is moot for the identical reason and additionally risks changing observability for the
    ten-plus other `cleanup-worktrees` bats suites that share the same stub. (d) is honest
    and zero-risk but forgoes a directly falsifiable forbidden-call assertion, leaving only
    the pre-existing indirect token pin. (b) is proven, by code reading, to be absent today
    and present under the named guard-ordering mutation, requires no production or fixture
    change, and gives a second, independent, directly falsifiable signal.
- **D2 — Retain the indirect pin.**
  - Options: keep the `ACTION|delete|main|BLOCKED-PROTECTED-BASE` token assertion alongside
    the new D1 assertion; or drop it now that D1 supplies a direct signal.
  - Decision: keep it.
  - Rationale: it is a second, already-present, independent signal for the same mutation (a
    guard moved after re-verification prints `BLOCKED-REVERIFY` instead of
    `BLOCKED-PROTECTED-BASE`); removing it would reduce test signal for no benefit.
- **D3 — Citation anchor form (`cleanup-worktrees.sh:145`).**
  - Options: re-derive and cite a corrected line number; or replace the line-number
    citation with a stable text anchor naming the function and assignment target.
  - Decision: stable text anchor, naming `main()` and the literal
    `CLEANUP_WT_CLEAR_DISPOSABLE=1` assignment.
  - Rationale: a re-derived line number reproduces the exact defect class the issue
    reports — it will drift again with the next unrelated edit to
    `scripts/bash/cleanup-worktrees.sh`. A text anchor keyed on the function name and the
    literal assignment token survives any line-shifting edit as long as those two objects
    are not renamed, which is the actual identification the comment needs to make.
- **D4 — Citation scope (`test_cleanup_worktrees_deletion.bats:47`, two occurrences).**
  - Options: leave the two accurate-today `tests/shell/test_cleanup_worktrees_deletion.bats:47`
    citations unchanged (out of the issue's literal AC2 wording, which names only line 14);
    or convert them to a text anchor naming the target `@test` in the same edit pass.
  - Decision: convert them.
  - Rationale: both citations sit inside the identical header comment block already being
    edited for D3, carry the same latent line-drift risk, and the target `@test` name
    (`"a candidate whose re-verification flips is blocked before any branch delete"`) was
    verified to still be the test occupying line 47 in the current file. Converting them in
    the same pass removes a second known drift risk at no additional file-scope cost.
- **D5 — Verification command.**
  - Options: cite `npx bats tests/shell` (the issue's own "Command/flags used" field); cite
    a single-file `shell-qc.sh test` invocation scoped to only the two edited files; or cite
    the repository's actual toolchain wrapper run over the full suite.
  - Decision: `bash scripts/bash/shell-qc.sh test` (and `--coverage` to match the CI step
    exactly), run in CI via `.github/workflows/_shell-coverage.yml`.
  - Rationale: `npx bats` does not correspond to any `bats` entry in `package.json` and is
    a documentation inaccuracy in the issue, not the repository's actual command. The
    `shell-qc.sh` wrapper's `test` subcommand accepts only an optional `--coverage` flag
    and always runs `bats` over the full `tests/shell`/`tests/bash` directories — it does
    not support single-file scoping — so the full-suite wrapper invocation is the
    authoritative, CI-equivalent command. Raw `bats tests/shell/test_cleanup_worktrees_deletion.bats`
    remains useful only for local fast-iteration under WSL and is not the CI-equivalent
    gate.
- **D6 — Falsifiability proof method.**
  - Options: run a live mutate-and-revert `bats` cycle on a scratch CI dispatch of the
    branch; run the same cycle locally under WSL; or record a static call-path trace
    describing the same before/after behavior without executing it.
  - Decision: static call-path trace, recorded as an evidence artifact; no mutated
    production file is committed.
  - Rationale: a scratch CI dispatch would consume an extra CI cycle and risk confusion
    with the branch's real CI history; a local WSL run is unavailable inside this agent
    worktree, whose Bash isolation guard refuses text containing `bash`/`pwsh`/`wsl`. A
    static trace, grounded in the source-line evidence already gathered during root-cause
    analysis, documents the same reasoning without executing or committing a mutation, and
    the actual `bats` execution is still covered by the CI shell-coverage job (AC6).
- **D7 — Work mode.**
  - Options: `minor-audit` (as declared in the GitHub issue body) or `full-bug` (per
    operator directive for this run).
  - Decision: `full-bug`.
  - Rationale: the operator directive for this run explicitly selects `full-bug` and takes
    precedence over the issue body's self-declared mode for the purpose of this spec's
    acceptance-criteria source resolution.
- **D8 — Change scope (no production-code change).**
  - Options: fix only the test files; or additionally adjust production comments/line
    references inside `scripts/bash/cleanup-worktrees.sh` to keep the (rejected) line-number
    citation approach viable.
  - Decision: test-files-only; no change under `scripts/`.
  - Rationale: the issue explicitly requires the full suite to pass with no production-code
    change, and both defects (a vacuous assertion, a stale citation) are fully addressable
    within the two affected test files.
- **D9 — Merge-order independence.**
  - Options: identify edit locations by line number (fast to write, matches the defect
    being fixed) or by text anchor (stable across concurrent sibling edits).
  - Decision: text anchor for every edit location (the `@test` name, the literal assertion
    line, the citation text) in this spec and in the eventual plan/PR.
  - Rationale: sibling issue #706 and other concurrently open `cleanup-worktrees` issues
    (#707-716) may edit other parts of the same file tree; #706's confirmed file set
    (`scripts/bash/cleanup_worktrees_scan_helper.sh`,
    `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
    `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`) does not overlap this
    fix's file set, but line numbers within the two edited files could still shift if any
    other concurrently open branch also touches them. Text anchors remain valid
    regardless of interleaved, unrelated edits.
