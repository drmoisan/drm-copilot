# cleanup-worktrees-report-mode-visibility-gaps (Spec)

- **Issue:** #631
- **Parent (optional):** Epic `cleanup-merged-worktrees-hardening` (`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`), child B, gaps 7, 9c, 9d
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-03
- **Status:** Draft
- **Version:** 0.2

## Context
`/cleanup-merged-worktrees` report mode does not surface orphaned worktree directories, stale
`refs/remotes/child/*` refs, or worktree-registration loss, and spends unnecessary time
re-classifying branches that are already known to be unmerged ancestors of another branch.

Environment:
- OS/version: Windows 11 (host), WSL Ubuntu (bash toolchain)
- Python version: not applicable (bash tool)
- Command/flags used: `/cleanup-merged-worktrees` (report mode)
- Data source or fixture: 2026-09-06 TaskMaster repository cleanup run

Impact / Severity:
- [ ] Blocker
- [x] Medium
- [ ] Low

This feature is epic child B of `cleanup-merged-worktrees-hardening`, assessed at complexity band
C2: "Three additive report-mode record types on an existing emission path. The `CHILD_OF`
short-circuit changes classification cost, not classification outcome. Localized to report mode
with no apply-mode effect." It carries no dependency edges and runs in wave 0.

## Repro & Evidence
Steps to Reproduce:
1. Run `/cleanup-merged-worktrees` report mode against a large checkout that has accumulated
   orphaned worktree directories, stale remote-tracking refs from a prior epic run, up to 20
   epic child branches (some with up to 64 commits) descending from a common unmerged
   integration branch, and at least one worktree whose `.git` file references a
   `.git/worktrees/<name>` entry that has gone missing mid-run.
2. Observe the report output and the run duration.

Expected:
- Orphaned directories under `.claude/worktrees/` and `<repo>-wt/` that have no `.git` file and
  no worktree registration are reported as `ORPHAN_DIR|<path>|<size>`.
- Stale `refs/remotes/child/*` refs left over from an epic run (with no corresponding remote
  named `child`) are reported as `STALE_REF|<refname>`.
- A branch whose tip is already an ancestor of another `NOT_MERGED` branch is short-circuited
  and reported as `CHILD_OF|<branch>|<ancestor>` instead of re-classifying every commit, reducing
  report runtime without changing the classification outcome relative to full classification.
- A worktree whose on-disk `.git` file points at a missing `.git/worktrees/<name>` entry is
  reported as `WARN|registration-lost|<path>`.
- Deletion of orphan directories and stale refs remains a manual, per-item confirmed action;
  report mode only surfaces the finding.

Actual:
- Four directories under `.claude/worktrees/` and `<repo>-wt/` had no `.git` file and no
  registration (one was a 6 GB checkout from July) and were not reported.
- 17 `refs/remotes/child/*` refs remained from a prior epic run, although no remote named
  `child` exists, and were not reported.
- Report mode took approximately 6 minutes, dominated by per-commit patch-id classification of
  20 epic child branches with up to 64 commits each, even though many of those branches were
  already ancestors of the epic integration branch and could have been short-circuited.
- `git worktree list` registrations for two session worktrees disappeared mid-run while their
  directories stayed on disk (cause not established; a concurrent session was active), and no
  warning was emitted for the resulting dangling `.git` file references.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: See run observations at
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`
  (gaps 7, 9c, 9d).

The historical counts above (four directories, 17 refs, two worktrees) are facts about one past
run. They are cited here as reproduction evidence only. The fix under this spec is generic,
parameterized detection logic; no acceptance criterion in this document asserts a specific count
derived from those historical numbers (see Acceptance Criteria).

## Scope & Non-Goals

### In scope
Exactly four additive report-mode record types, added to the existing `run_report`/
`classify_branch` emission path in `scripts/bash/cleanup_worktrees_lib.sh` and
`scripts/bash/cleanup_worktrees_enumerate_lib.sh`:

- `ORPHAN_DIR|<path>|<size>` (gap 7) — an unregistered directory under a known worktree-tracking
  root with no `.git` file.
- `STALE_REF|<refname>` (gap 7) — a `refs/remotes/<name>/*` ref whose `<name>` has no
  corresponding configured remote.
- `CHILD_OF|<branch>|<ancestor>` (gap 9c) — a cost-only classification short-circuit, emitted
  alongside an unchanged `BRANCH|<branch>|NOT_MERGED` line, per the outcome-preservation
  invariant below.
- `WARN|registration-lost|<path>` (gap 9d) — a detection line for a worktree whose `.git` file
  points at a missing `.git/worktrees/<name>` entry. Detection only; no root cause is
  established or fixed by this work.

### Out of scope / non-goals
- Automatic deletion of orphan directories or stale refs. Deletion stays manual and confirmed
  per item; this feature adds reporting only.
- Root-causing the gap 9d mid-run worktree deregistration. This feature adds a
  `WARN|registration-lost|<path>` detection line, not an investigation or a fix for why
  registrations are lost.
- Detached-worktree classification and the consolidation-branch delete-eligibility ordering
  hazard (epic child A, issue #630).
- The dirt classifier and the `--clear-disposable` apply-mode flag (epic child C, gap 2).
- The sanctioned removal manifest (epic child D) and `PRESERVE` file consolidation (epic child
  F).
- Any change to default apply-mode deletion behavior. Gap 7's output is report-only, and the
  `CHILD_OF` short-circuit changes classification cost, never classification outcome (see
  invariant below).

### Explicitly excluded systems, integrations, or datasets
- `enforce-epic-worktree-removal-gate.ps1` and `enforce-epic-merge-gate.ps1` (PowerShell
  surface, epic children D/G) are not touched.
- The `collect_pr_context` TypeScript changed-files overview (epic child H) is not touched.
- The command-word matcher used by the preimplementation gate (epic child E, issue #545) is not
  touched.

## Root Cause Analysis

- `classify_branch` (`scripts/bash/cleanup_worktrees_lib.sh:308-443`) is the sole emitter of
  `BRANCH|` lines and has no short-circuit for a branch whose tip is already an ancestor of
  another unmerged branch. `classify_ancestry` (52-73) only checks a branch's tip against the
  literal ref `main` (line 64); nothing in the ladder checks a branch's tip against any other
  branch's tip. Consequently a branch `X` that is a git ancestor of branch `Y` runs the full
  ladder — including rung 3's `git cherry main <branch>` (100-169, O(commits-in-branch)) and
  rungs 4-5's per-commit rename-aware blob comparisons (185-252) — exactly as it would for an
  unrelated branch, even when `Y`'s resolution alone already implies `X`'s resolution. This is
  the mechanism behind gap 9c's "per-commit patch-id classification of 20 epic child branches
  with up to 64 commits each" runtime cost.
- `run_report` (`cleanup_worktrees_lib.sh:445-479`) and `run_apply`
  (`scripts/bash/cleanup_worktrees_actions_lib.sh:316-382`) both loop independently over
  `enumerate_branches`'s output, each calling `classify_branch` once per branch with no shared
  state across branches and no shared state between the two loops (`run_report:470-477`,
  `run_apply:357-380`). Neither loop has a scan for orphaned directories, stale remote-tracking
  refs, or worktree-registration loss; `run_report`'s only pre-branch-loop emission is
  `check_main_freshness`'s `WARN|main-divergence` line (464).
- `check_main_freshness` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:221-236`) is the
  existing precedent for the `WARN|` line shape (`printf 'WARN|main-divergence|%s|%s\n'
  "$local_sha" "$origin_sha"`, line 233): advisory-only, always returns 0, skips silently when
  the underlying read cannot resolve. There is no equivalent scan for a missing
  `.git/worktrees/<name>` entry.
- `parse_worktree_list` (`cleanup_worktrees_enumerate_lib.sh:85-148`) only sees what `git
  worktree list --porcelain` itself reports; it has no concept of a directory that is not
  registered as a worktree at all, so it cannot by itself detect an orphan directory or a lost
  registration — both are filesystem-side facts absent from git's own porcelain output.
- `cleanup_worktrees_lib.sh` is at 479 of the 500-line cap in
  `.claude/rules/general-code-change.md`; new report-record logic must go in a new sibling
  library file, not by growing this file.

## Proposed Fix

### Design summary (what changes where)
Add a new sibling library, `scripts/bash/cleanup_worktrees_report_records_lib.sh`, that houses
all new detection and short-circuit logic. `run_report` and `run_apply` are each changed to call
a new shared classification driver from that file instead of running their own independent
per-branch loops, so both modes get the `CHILD_OF` cost optimization from the same code path with
an identical outcome guarantee. `cleanup_worktrees_lib.sh`'s own line count grows only by the
small `run_report` call-site edit that replaces its inline loop.

### The `CHILD_OF` outcome-preservation invariant

This is a hard invariant, not a design preference. Today, a branch `X` that is a full git
ancestor of another unmerged branch `Y` runs the complete classification ladder — including the
expensive per-commit `git cherry`/`diff-tree` rungs — and resolves to `BRANCH|X|NOT_MERGED`. The
`CHILD_OF` short-circuit MUST preserve that exact `BRANCH|X|NOT_MERGED` outcome, and it applies
**only** when `Y` resolves to exactly `NOT_MERGED` — not `HAS_UNIQUE_RESIDUALS`,
`MERGED_EQUIVALENT`, `MERGED_CONTENT_NEUTRAL`, `MERGED_CLEAN`, or `ANCESTRY_ERROR`. The subset
argument that justifies skipping the expensive rungs holds only in the `NOT_MERGED` case: if `Y`
resolved to anything else, `X` being an ancestor of `Y` does not by itself determine `X`'s state,
and skipping the ladder would risk a wrong verdict rather than merely a slower one.

The short-circuit changes classification **cost** only, never classification **outcome**. This
must be provable for both report mode and apply mode:

- Report mode: the `BRANCH|X|NOT_MERGED` line's value is byte-identical whether or not the
  short-circuit fired; the only observable difference is the presence of an additive
  `CHILD_OF|X|Y` line and the absence of the skipped rungs' side effects (none of which are
  externally visible beyond the `BRANCH|` line itself).
- Apply mode: `run_apply` (`cleanup_worktrees_actions_lib.sh:316-382`) does not parse
  `run_report`'s serialized text output. It calls `classify_branch` directly and extracts the
  allowlist-governing state with `state=$(printf '%s\n' "$cb_out" | awk -F'|'
  '/^BRANCH\|/{print $3; exit}')` (line 373) — this matches only lines beginning `BRANCH|` and
  takes the first such line's third field. An additive, non-`BRANCH|`-prefixed `CHILD_OF` line is
  invisible to this extraction. Because the short-circuit lives inside the shared classification
  driver (not only inside `run_report`'s text-formatting layer), `run_apply` calls the same
  function and therefore inherits the identical `BRANCH|X|NOT_MERGED` first line, whether or not
  the short-circuit fired. The apply-mode allowlist decision (line 375:
  `MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT`) for a `CHILD_OF`-short-circuited
  branch is therefore provably unaffected: `NOT_MERGED` was never in the allowlist before this
  change and is not moved into it by this change.

A hard git failure during the new pairwise `merge-base --is-ancestor` probe (exit code greater
than 1) maps `X` to `ANCESTRY_ERROR`, consistent with the file's documented convention that a
hard failure of any enumeration/protection/cherry/diff-tree/ls-tree/rev-list read maps to
`BRANCH|<name>|ANCESTRY_ERROR` (`cleanup_worktrees_lib.sh:36-38`). It must not silently fall
through to "not an ancestor."

### Boundaries and invariants to preserve
- `classify_branch`'s existing six-rung ladder is unchanged for every branch that is not
  short-circuited.
- `run_report`'s and `run_apply`'s existing output shapes for `BRANCH|`, `COMMIT|`, `WORKTREE|`,
  `WARN|main-divergence|`, `DIRTY|`, and `ACTION|` lines are unchanged.
- `ORPHAN_DIR`, `STALE_REF`, and `WARN|registration-lost` are report-mode additions only; none of
  the three participates in the apply-mode allowlist decision.
- `cleanup_worktrees_lib.sh` stays at or under the 500-line cap.
- Every `.claude/**` edit (the SKILL.md Report Line Contract update) is mirrored byte-identically
  into `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

### Dependencies or blocked work
None. This child has an empty `depends_on` list in the epic manifest and runs in wave 0,
independent of children A, C, E, and H. No edge is recorded among A, B, C, and F for their shared
use of the `cleanup_worktrees_*_lib.sh` family; the new logic is isolated in a new sibling file,
which is what keeps this child conflict-free with the others rather than a dependency ordering.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change
- `scripts/bash/cleanup_worktrees_report_records_lib.sh` (new file) — override-seam resolvers
  for filesystem-scan tools (mirroring `cleanup_wt_git`'s pattern in
  `cleanup_worktrees_enumerate_lib.sh:34-57`), `scan_orphan_dirs`, `scan_stale_refs`,
  `scan_registration_loss`, and a shared two-phase classification driver (e.g.
  `classify_all_branches`) that both `run_report` and `run_apply` call.
- `scripts/bash/cleanup_worktrees_lib.sh` — replace `run_report`'s inline per-branch loop
  (470-477) with a call to the new shared driver; invoke the new scan functions at the
  appropriate point in the emission order.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — replace `run_apply`'s inline per-branch loop
  (357-380) with a call to the same shared driver, so apply mode inherits the `CHILD_OF`
  cost optimization with an unchanged outcome.
- `scripts/bash/cleanup-worktrees.sh` — extend the inline `usage()` report-line-contract summary
  (42-45) with the four new record shapes; add the new sibling file's `source` line in the
  correct order (after the enumerate lib, consistent with the enumerate-before-classification
  convention documented in `cleanup_worktrees_lib.sh`'s header comment).
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` — extend the Report Line Contract section
  (line 57 onward) with the four new record types, cross-referencing (not duplicating) the
  existing manual orphan-directory guidance in the Dirty Worktree Triage Procedure step 7.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  — byte-identical mirror of the SKILL.md edit, required by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — additive extension only: (a) a
  pattern-specific `for-each-ref` key with fallback to the existing bare key, preserving all
  existing scenario fixtures; (b) a new `remote` case (currently falls through to the no-op
  default).
- New stub binary/binaries (e.g. `tests/fixtures/cleanup_worktrees/stub-bin/find` and/or `du`)
  for the filesystem-scan seam, following the git stub's KEY-derivation-and-replay shape.
- New scenario fixture directories under `tests/fixtures/cleanup_worktrees/scenarios/`.
- New or extended bats coverage under `tests/shell/`.

#### Functions/classes/CLI commands impacted
- `classify_branch` — no change to its own ladder; consumed unchanged by the new shared driver.
- New: `classify_all_branches` (shared driver), `scan_orphan_dirs`, `scan_stale_refs`,
  `scan_registration_loss`, `cleanup_wt_du`/`cleanup_wt_find` (or a single combined
  filesystem-scan resolver).
- `run_report`, `run_apply` — call sites changed to use the shared driver.
- `check_main_freshness` — unchanged; remains the precedent, not a modification target.

#### Data flow and validation changes
`run_report`'s emission order gains the three scan-based record types (`ORPHAN_DIR`,
`STALE_REF`, `WARN|registration-lost`) colocated with the existing pre-branch-loop output
(alongside `WARN|main-divergence`, before the `WORKTREE|` lines), since none of the three depend
on per-branch classification results. `CHILD_OF` lines are additive within the per-branch
section, alongside the `BRANCH|`/`COMMIT|` lines for the short-circuited branch.

#### Error handling and logging updates
- A hard failure in the new pairwise ancestry probe maps to `BRANCH|<name>|ANCESTRY_ERROR`,
  matching every other hard-failure case in the ladder.
- A directory whose size cannot be resolved is still emitted as `ORPHAN_DIR|<path>|unknown`
  rather than silently dropped, to avoid recreating the exact visibility gap this feature closes.
- `WARN|registration-lost` follows `WARN|main-divergence`'s advisory pattern: never blocks
  classification, and a failure to read a candidate `.git` file is skipped silently rather than
  erroring the whole report.

#### Rollback/feature-flag considerations (if applicable)
No feature flag is introduced. All four record types are purely additive report-mode output;
disabling the feature is equivalent to reverting the change, since no existing behavior depends
on their presence.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats
- `ORPHAN_DIR|<path>|<size>` — `<path>` is a directory under a known worktree-tracking root with
  no `.git` file and no entry in `parse_worktree_list`'s output. `<size>` is a best-effort,
  informational field computed via the new filesystem-scan seam; when unresolvable it is emitted
  as the literal `unknown` rather than omitted. Size is inherently environment-dependent in
  production, though deterministic in tests via the stub seam — no acceptance criterion asserts
  a specific numeric size value.
- `STALE_REF|<refname>` — `<refname>` is any `refs/remotes/<name>/*` ref where `<name>` has no
  corresponding entry in the current `git remote` list. Detection must be general: it must
  identify any stale remote-tracking namespace, not hardcode the literal name `child` from the
  one observed instance. `LC_ALL=C` sorted, consistent with `enumerate_branches`'s existing sort
  convention.
- `CHILD_OF|<branch>|<ancestor>` — emitted only alongside an unchanged
  `BRANCH|<branch>|NOT_MERGED` line, per the outcome-preservation invariant above. `<ancestor>`
  is the other branch (`Y`) whose `NOT_MERGED` resolution licensed the short-circuit.
- `WARN|registration-lost|<path>` — `<path>` is a directory with a `.git` file present (i.e. not
  an `ORPHAN_DIR`) whose `gitdir:` pointer target does not exist. Advisory only, mirroring
  `WARN|main-divergence`'s never-blocking behavior; not a classification input for any other
  record type.

#### Required configuration keys and defaults
- New override-seam environment variables for the filesystem-scan resolvers (e.g.
  `CLEANUP_WT_DU_BIN`, `CLEANUP_WT_FIND_BIN`, or a single combined seam variable), following
  `CLEANUP_WT_GIT_BIN`'s existing precedent: fall back to `command -v <tool>` when unset or not
  executable.
- No new required configuration; all new behavior is unconditional in report mode and additive
  in apply mode (the `CHILD_OF` short-circuit fires automatically whenever its precondition
  holds, with no opt-in flag).

#### Backward-compatibility expectations
- All ~27 existing bats scenario fixtures under `tests/fixtures/cleanup_worktrees/scenarios/`
  continue to pass unchanged after the `for-each-ref` stub key-specificity edit, verified by a
  full existing-suite bats run immediately after that edit and before any new fixtures are
  authored on top of it.
- `run_apply`'s allowlist decision for every branch state is unchanged, including for
  `CHILD_OF`-short-circuited branches (see invariant above).
- `cleanup-worktrees.sh`'s existing `usage()` substring check
  (`test_cleanup_worktrees_cli.bats`, which only checks `"Usage: cleanup-worktrees.sh"`) is
  unaffected by the report-line-contract text extension.

#### Performance constraints (latency/throughput/memory)
The `CHILD_OF` short-circuit is expected to reduce report-mode runtime for checkouts with
multiple branches descending from a common unmerged integration branch, by skipping the O(commits)
`git cherry`/`diff-tree` rungs for every branch identified as an ancestor of an already-resolved
`NOT_MERGED` branch. No specific latency or throughput number is asserted as an acceptance
criterion; the qualitative expectation (fewer expensive-rung invocations for short-circuited
branches) is verified directly via argv-log assertions in the test suite (see Test Strategy).

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the bash toolchain runs under WSL Ubuntu with `bats`
  1.13.0, `kcov` 43, `shfmt`, and `shellcheck` available; `shfmt`/`shellcheck` are also on the
  Windows PATH. The known worktree-tracking roots (`.claude/worktrees/`, `<repo>-wt/`) are
  per-repo and CLI-tool-managed, outside git's own worktree bookkeeping.
- Constraints (budget, performance, compatibility): `cleanup_worktrees_lib.sh` must stay at or
  under the 500-line cap; new logic goes in a new sibling file. No temporary files are permitted
  in tests; all new coverage uses checked-in fixtures and the established stub-seam pattern.
- External dependencies (services, libraries, releases): none beyond the existing toolchain
  (`bats`, `kcov`, `shfmt`, `shellcheck`) and the existing `git` stub-binary seam pattern, which
  is extended additively for filesystem-scan tools.

## Data / API / Config Impact
- User-facing or API changes: `/cleanup-merged-worktrees` report-mode output gains four new
  line-based record types, documented in SKILL.md's Report Line Contract. No existing record
  type's shape or meaning changes.
- Data or migration considerations: none. No persisted data format changes.
- Logging/telemetry updates (if any): none beyond the new report-line record types themselves,
  which are the feature's primary output.
- Compatibility notes (CLI flags, config schemas, versioning): no new CLI flags are introduced.
  New environment-variable override seams for filesystem-scan tools are optional and
  backward-compatible (unset behaves as `command -v <tool>` today would for an equivalent
  hand-written scan).

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: bats coverage for `ORPHAN_DIR`, `STALE_REF`, `CHILD_OF`, and
      `WARN|registration-lost` emission, driven through the `CLEANUP_WT_GIT_BIN` stub seam
      against new checked-in fixture scenarios.
- [x] Integration scenario to retest: a report-mode run against a fixture tree containing an
      orphan directory, a stale `child` remote-tracking ref, a branch that is an ancestor of
      another `NOT_MERGED` branch, and a worktree with a missing `.git/worktrees/<name>` entry.
- [ ] Manual verification notes

All new coverage follows the established no-temp-file, checked-in-fixture, stub-seam pattern
(`CLEANUP_WT_GIT_BIN`-style), mandatory per `.claude/rules/general-unit-test.md` and
`.claude/rules/shell.md`.

- Regression tests to add or update: new bats coverage in a new file (e.g.
  `tests/shell/test_cleanup_worktrees_report_records.bats`) for the three scan-based record
  types, plus new `@test` blocks in `tests/shell/test_cleanup_worktrees_classification.bats` for
  `CHILD_OF`.
- Required test cases:
  - A `CHILD_OF` positive case: `X` is a verified ancestor of a `Y` that resolves `NOT_MERGED`,
    asserting both `BRANCH|X|NOT_MERGED` and `CHILD_OF|X|Y` are present, and asserting via
    argv-log assertions against the stub's `stub-git:` stderr lines that none of `X`'s
    expensive-rung stub keys (`cherry.X`, `diff-tree.*`, `rev-list.X`) were invoked.
  - A `CHILD_OF` negative case: `X` is an ancestor of a `Y` that resolves
    `HAS_UNIQUE_RESIDUALS` or `MERGED_EQUIVALENT`, asserting the short-circuit does not apply and
    `X` is fully classified via the normal ladder with no `CHILD_OF` line.
  - An apply-mode test proving the allowlist decision for a `CHILD_OF`-short-circuited
    `NOT_MERGED` branch is unchanged (no deletion `ACTION` emitted), directly exercising the
    outcome-preservation invariant in apply mode.
  - Positive/negative pairs for `ORPHAN_DIR` (present when unregistered and `.git`-less;
    absent when registered), `STALE_REF` (present when the remote is missing; absent when the
    remote exists), and `WARN|registration-lost` (present when the `.git` pointer target is
    missing; absent when it resolves).
- Edge cases and negative scenarios: a hard git failure during the new pairwise
  `merge-base --is-ancestor` probe maps to `ANCESTRY_ERROR`, not a silent "not an ancestor"
  fallback; an unresolvable directory size is emitted as `ORPHAN_DIR|<path>|unknown` rather than
  dropped; a `WARN|registration-lost` candidate whose `.git` file cannot be read is skipped
  silently rather than erroring the whole report.
- Error handling and logging verification: covered by the edge-case tests above.
- Coverage impact and targets for changed lines/modules: line coverage >= 85% per
  `.claude/rules/quality-tiers.md`; bash has no branch-coverage gate (kcov limitation). Every new
  function in `cleanup_worktrees_report_records_lib.sh` carries direct bats coverage.
- Toolchain commands to run (format → lint → type-check → test):
  ```
  wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && bash scripts/bash/shell-qc.sh format'
  wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && bash scripts/bash/shell-qc.sh check'
  wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && bash scripts/bash/shell-qc.sh test'
  wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && bash scripts/bash/shell-qc.sh test --coverage'
  ```
  `shfmt` and `shellcheck` are also available directly on the Windows PATH. Type-checking is not
  applicable to bash; the sequence is format → lint → test → test with coverage.
- Manual validation steps (if required): the `for-each-ref` stub key-specificity edit requires an
  immediate full existing-suite `bash scripts/bash/shell-qc.sh test` run (all suites, not only
  the new ones) as a standalone regression gate, before any new scenario fixtures are authored on
  top of it, because that edit is shared by every existing scenario.

## Acceptance Criteria
- [ ] `ORPHAN_DIR|<path>|<size>` is emitted for a directory under a known worktree-tracking root
      that has no `.git` file and no entry in `parse_worktree_list`'s output, and is absent for a
      registered worktree directory, verified by a positive/negative bats pair against checked-in
      fixtures.
- [ ] `STALE_REF|<refname>` is emitted for any `refs/remotes/<name>/*` ref whose `<name>` has no
      corresponding configured remote (verified against a fixture using a name other than the
      literal `child`, to confirm the detection is general rather than hardcoded), and is absent
      when the remote exists, verified by a positive/negative bats pair.
- [ ] `CHILD_OF|<branch>|<ancestor>` is emitted alongside an unchanged
      `BRANCH|<branch>|NOT_MERGED` line when the branch is a git ancestor of another branch that
      resolves to exactly `NOT_MERGED`, and is absent (with the branch running the full ladder
      normally) when the ancestor resolves to `HAS_UNIQUE_RESIDUALS` or `MERGED_EQUIVALENT`,
      verified by a positive/negative bats pair that additionally asserts via argv-log checks
      that the expensive-rung stub keys were not invoked in the positive case.
- [ ] `WARN|registration-lost|<path>` is emitted for a worktree directory whose `.git` file
      points at a missing `.git/worktrees/<name>` entry, and is absent when the pointer resolves,
      verified by a positive/negative bats pair.
- [ ] The `CHILD_OF` outcome-preservation invariant is verified as two separately-tested
      properties: (a) the report-mode `BRANCH|<branch>|NOT_MERGED` line's value is unchanged
      whether or not the short-circuit fires, and (b) the apply-mode allowlist decision for a
      `CHILD_OF`-short-circuited branch is unchanged (no deletion `ACTION` emitted for a
      `NOT_MERGED` branch, short-circuited or not).
- [ ] The `for-each-ref` stub key-specificity edit in
      `tests/fixtures/cleanup_worktrees/stub-bin/git` is backward compatible: the full existing
      bats suite passes unchanged immediately after that edit, before any new scenario fixtures
      are authored on top of it.
- [x] The SKILL.md Report Line Contract section documents all four new record types, cross-
      referencing (not duplicating) the existing manual orphan-directory guidance in the Dirty
      Worktree Triage Procedure, and the edit is mirrored byte-identically into
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`,
      verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [x] `scripts/bash/cleanup_worktrees_lib.sh` remains at or under the 500-line cap in
      `.claude/rules/general-code-change.md` after the `run_report` call-site edit.
- [ ] The full toolchain loop (`shell-qc.sh format`, `check`, `test`, `test --coverage`) passes
      with line coverage >= 85%, with no bash branch-coverage gate, per
      `.claude/rules/quality-tiers.md`.
- [ ] No automatic deletion of orphan directories or stale refs is introduced; deletion remains a
      manual, per-item confirmed action outside this feature's scope.
- [ ] No acceptance criterion in this document, and no test authored to satisfy it, asserts a
      fixed numeric count (e.g., a specific number of orphan directories or stale refs) derived
      from the historical 2026-09-06 run observations; all detection logic is generic and
      parameterized.

## Risks & Mitigations
- Technical or operational risks:
  - The `for-each-ref` stub key-specificity edit touches a fixture file shared by every existing
    bats scenario (~27 directories); an incorrect fallback could silently replay the wrong
    canned data for one of two distinct `for-each-ref` calls in a test.
  - Implementing the `CHILD_OF` short-circuit only in `run_report`'s text-formatting layer
    (rather than inside the shared classification driver) would break the outcome-preservation
    invariant for apply mode, since `run_apply` would then need its own separate short-circuit
    logic that could drift from report mode's.
  - A directory-size scan or `.git` pointer read that touches the real filesystem with no
    override seam would make tests non-deterministic and environment-dependent, violating the
    no-temp-file test policy.
- Mitigations and rollbacks:
  - Require a full existing-suite bats run as a standalone regression gate immediately after the
    `for-each-ref` stub edit, before any new scenario fixtures are authored on top of it.
  - Implement the `CHILD_OF` short-circuit inside the new shared classification driver
    (`classify_all_branches`) called by both `run_report` and `run_apply`, so both modes inherit
    the identical guarantee from one code path rather than two independently-maintained ones.
  - Extend the existing `CLEANUP_WT_GIT_BIN`-style override-seam pattern to the filesystem-scan
    tools (`cleanup_wt_du`/`cleanup_wt_find`), following `cleanup_wt_git`'s exact shape, so all
    new scans are driven deterministically from checked-in fixture stubs with no real filesystem
    access in tests.
  - Because all four record types are purely additive, rollback is a straightforward revert with
    no data migration or feature-flag cleanup required.

## Rollout & Follow-up
- Release/rollout steps: ships as part of the `cleanup-merged-worktrees-hardening` epic's wave 0.
  No consumer-repository copy is patched directly; the `.claude/**` SKILL.md edit reaches
  consumers through the existing push-down mechanism once merged.
- Post-fix monitoring or clean-up tasks: none required beyond the existing toolchain gates. The
  root cause of gap 9d's registration loss remains an open item for future investigation, tracked
  separately from this detection-only fix.
- Links: issue #631; epic `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`;
  research `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/research/2026-09-06-report-mode-visibility-gaps-research.md`;
  related run observations at
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`.
