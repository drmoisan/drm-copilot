# 2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main (Spec)

- **Issue:** #1027
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T20-58
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Research:** `research/2026-10-30T21-30-preserve-modified-merge-research.md`

## Context
- Summary of the bug and its impact: `cleanup-worktrees.sh --preserve` (skill `cleanup-merged-worktrees`) copies each `preserved_files[]` source file whole onto `target_path` in the consolidation worktree. For a `change_class: modified` record, the worktree copy is often an older snapshot of a documentation or memory note that `main` has since extended. The whole-file copy silently replaces `main`'s newer version, so `main`'s newer lines are lost when the consolidation branch is committed. Repro source: `issue.md`, `## Steps to Reproduce`.
- Observed environment(s): any host running the bash preserve path (Git Bash on Windows, Linux). OS version was not recorded in the issue. The defect is in platform-independent bash logic.
- Customer impact and severity: Medium (issue severity). Affects every operator who preserves a `modified` record whose target already exists on the consolidation branch with lines the source lacks. The loss is silent (the pass reports `ACTION|preserve-stage|<tgt>|OK`) and falls on lesson and memory notes, which are the content the preserve workflow exists to protect.
- First observed date and version(s) impacted: captured 2026-10-30. Every revision of `cleanup_worktrees_preserve_lib.sh` since preserve mode was introduced is affected, because the library documents the uniform copy as a design rule.

## Repro & Evidence
- Steps to reproduce:
  1. Have a linked worktree that holds an older snapshot of a documentation or memory note that `main` has since extended.
  2. Write a sanctioned removal manifest with a `preserved_files[]` record for that file, `change_class: modified`, and `target_path` equal to the note's path.
  3. Run `cleanup-worktrees.sh --preserve`.
  4. Compare the staged file on the `documentationandmemories` consolidation branch with `main`'s version.
- Expected vs actual behavior:
  - Expected: for `modified` records, only the worktree's added lines are staged onto `main`'s current version; otherwise the record is refused with `ACTION|preserve-stage|<path>|REFUSED-WOULD-REGRESS`; a target whose `main` version has lines absent from the source is never overwritten.
  - Actual: the source file is copied whole onto `target_path` and staged, and `main`'s newer lines are lost.
- Logs/screenshots/error snippets: none. The failure is silent; the pass emits `ACTION|preserve-stage|<tgt>|OK` and exits 0.
- Frequency / determinism: deterministic and data-dependent. It occurs on every pass in which an existing target on the consolidation branch contains lines absent from the source file.

## Scope & Non-Goals
- In scope:
  - A staging decision for every preserve record whose `<consolidation-worktree>/<target_path>` is a regular file, implemented in a new bash library `cleanup_worktrees_preserve_merge_lib.sh`.
  - A three-way `git merge-file --union --object-id` merge bounded by guards G1, G2, and G3, with the line-subsequence guard (b) as the fallback when no merge base is available.
  - Guard (b) for `untracked` records whose target already exists as a regular file.
  - Refusal of a duplicate `target_path` within one pass.
  - The new result token `REFUSED-WOULD-REGRESS` on the existing `ACTION|preserve-stage` channel.
  - Commit-phase support for staging a merged blob.
  - Documentation updates to `SKILL.md`, the wrapper `usage` text, and the affected library header comments.
  - Bats tests, git stub extensions, fixtures, bundle mirrors, and the pack-manifest entry.
- Out of scope / non-goals:
  - No new `ACTION|preserve-merge` record or any result token other than `REFUSED-WOULD-REGRESS`.
  - No change to manifest schema, field validation vocabulary, or `CleanupWorktreeManifest.psm1` (it never reads `preserved_files[]`).
  - No change to `cleanup_worktrees_preserve_eol_lib.sh` or the `MEMORY.md` index-append behavior.
  - No transformation of the preserved file's bytes in the copy path.
  - No Python and no PowerShell implementation.
  - No change to records whose target is absent (verbatim copy, unchanged).
- Explicitly excluded systems, integrations, or datasets: `.agents/`, `.github/`, and `.codex/` surfaces (no copy of this skill exists there); the execution-environment brief (no stated fact changes); the Codex generator.

## Root Cause Analysis
- Confirmed root cause:
  - `preserve_commit_plan` (phase 2, the only writer) writes each plan entry with a whole-file `cat -- "$srcfile" >"$dstfile"` and stages the result. It never reads the destination's existing content.
  - `preserve_validate_record` treats `change_class` as vocabulary only. Its header comment states as a design rule that `change_class` "does NOT change the staging action: an untracked and a modified record are both copied to target_path and staged".
  - `preserve_plan_one` (phase 1) performs no step that reads `<consolidation-worktree>/<target_path>` before admitting the record to the plan stream.
- Signals/evidence supporting it: direct reading of `cleanup_worktrees_preserve_lib.sh` (research section 1). The `SKILL.md` manifest section acknowledges that `target_path` "may already exist on `main` with different content", but no consumer guards that case. The wrapper `usage` text states that preserve mode "Copies each named source file verbatim".
- Affected components/modules:
  - `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
  - `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
  - `.claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Bundle mirrors of the above under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/`

## Proposed Fix

### Design summary (what changes where):

Add `cleanup_worktrees_preserve_merge_lib.sh`, sourced by the wrapper immediately before `cleanup_worktrees_preserve_lib.sh`. It defines:

- A trailing-CR-tolerant line-subsequence helper.
- A multiset-difference containment helper.
- A base resolver.
- A decision function that sets `PRESERVE_STAGE_MODE` (`copy` | `merge`) and `PRESERVE_STAGE_OID`, or refuses the record.

`preserve_plan_one` calls the decision function after the `IGNORED-TARGET` check and before `preserve_plan_index`. The decision short-circuits to `copy` with no git call when `<cwt>/<target_path>` is not a regular file (`-f` test, not `-e`).

For an existing target:

- Untracked record: apply guard (b).
- Modified record with a resolvable base: G1, then `git -C <cwt> merge-file --union --object-id <main-oid> <base-oid> <wt-oid>`, then G2, then G3.
- Modified record without a base: guard (b).

The plan entry gains column 9 (mode) and column 10 (merged blob oid). An empty column 9 means `copy`. `preserve_commit_plan` writes `git -C <cwt> cat-file blob <oid> >"$dstfile"` for `merge` and keeps the existing `cat` copy for `copy` or empty.

Guards, defined over lines compared with one trailing carriage return stripped per line:

- **G1 (worktree change is insertion-only):** the base content is a line-subsequence of the worktree file.
- **G2 (no main line lost):** main's version is a line-subsequence of the merged content.
- **G3 (no resurrected or foreign lines):** multiset(merged) minus multiset(main) is contained in multiset(worktree) minus multiset(base).
- **Guard (b) (fallback):** main's version is a line-subsequence of the source file.

Behavioral contract (per-case verdict table):

| Case | Behavior | Result record |
|---|---|---|
| `untracked`, target not a regular file | Verbatim copy and stage; no git call by the decision | `ACTION\|preserve-stage\|<tgt>\|OK` |
| `untracked`, target is a regular file, main is a line-subsequence of source | Verbatim copy and stage | `OK` |
| `untracked`, target is a regular file, main has lines absent from source | Refuse | `REFUSED-WOULD-REGRESS` |
| `modified`, target not a regular file | Verbatim copy and stage; no git call by the decision | `OK` |
| `modified`, base available, G1 fails | Refuse | `REFUSED-WOULD-REGRESS` |
| `modified`, base available, merge exits non-zero or errors (including Git older than 2.43) | Refuse; stderr names the git exit code | `REFUSED-WOULD-REGRESS` |
| `modified`, base available, clean or union merge, G2 and G3 pass | Stage the merged blob (main plus only the worktree's added lines) | `OK` |
| `modified`, base available, G2 or G3 fails | Refuse | `REFUSED-WOULD-REGRESS` |
| `modified`, base unavailable, main is a line-subsequence of source | Verbatim copy and stage | `OK` |
| `modified`, base unavailable, main has lines absent from source | Refuse | `REFUSED-WOULD-REGRESS` |
| Any record whose `target_path` repeats an earlier record's in the same pass | Refuse the later record | `REFUSED-WOULD-REGRESS` |

The base is unavailable when any of the following holds:

- The worktree `HEAD` does not resolve.
- No merge base with the consolidation `HEAD` exists.
- `<merge-base>:<source_path>` does not exist.
- `source_path` differs from `target_path`.

Refusal semantics:

- `PRESERVE|<wt>|<src>|<verdict>` is still emitted, because it precedes the decision.
- A `cleanup-worktrees: ...` diagnostic naming the failed guard is written to stderr.
- `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS` is emitted on stdout.
- `PRESERVE_EXIT` is set to 1.
- No plan-stream entry is appended, and no index append or `ACTION|preserve-index` record is produced.
- The pass exits 1. A refusal is not a hard stop (exit 3 remains reserved for host-token blocks).

### Boundaries and invariants to preserve:

- The source file is read by plain file I/O, never through git (the repository-root `.claude/agent-memory` tree is gitignored).
- Every git call goes through `cleanup_wt_git` (seam `CLEANUP_WT_GIT_BIN`). No git call passes `-f` or `--force`.
- Phase 1 writes no index, ref, or working-tree file. Phase-1 write exception: `git hash-object -w --path=<target_path>` and `git merge-file --object-id` write unreferenced blob objects to the object store during planning. The `preserve_plan` header and the library header comments must state this exception explicitly.
- Phase 2 remains policy-free: it executes the plan entry's mode and makes no staging decision.
- Records whose target is not a regular file keep the existing argv log and outcome exactly, including no `merge-file`, `hash-object`, `merge-base`, or `rev-parse` call issued by the decision.
- Existing exit contract: 0 clean, 1 skipped/refused/failed or index created, 3 host-token hard stop, 127 tool unresolved.
- Existing plan-entry columns 1 through 8 keep their meaning and order.
- The new library defines functions only and performs no work at source time. `test_cleanup_worktrees_scan_roots.bats` sources the preserve library without it and must continue to pass.
- The `MEMORY.md` index behavior and the EOL library are unchanged.

### Dependencies or blocked work:

- Git 2.43 or later for `git merge-file --object-id`. An older Git fails with a usage error, which maps to `REFUSED-WOULD-REGRESS` (fail-closed). The orchestrator observed `git version 2.53.0.windows.1` on the operator host on 2026-10-31; the `ubuntu-latest` Git version is unverified. Tests use the stub and do not depend on either.
- No blocking issues.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production:
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (new)
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
- `.claude/skills/cleanup-merged-worktrees/SKILL.md`

Mirrors and manifest:
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (new entry in sorted position after `cleanup_worktrees_preserve_lib.sh`)

Tests and fixtures:
- `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (new)
- `tests/shell/test_cleanup_worktrees_preserve.bats` (source-guard case for the new library, setup sourcing, rewritten `modified` test comment)
- `tests/shell/test_cleanup_worktrees_preserve_eol.bats` (setup sourcing)
- `tests/shell/test_cleanup_worktrees_preserve_failures.bats` (setup sourcing; commit-phase merge-mode tests)
- `tests/fixtures/cleanup_worktrees/stub-bin/git` (new `merge-base <a> <b>`, `cat-file`, `merge-file`, and `hash-object -w` handling; corrected header comments that cite production line numbers and state that no `-w` behavior exists)
- `tests/fixtures/cleanup_worktrees/preserve/merge-*/` (new scenario directories)
- `tests/fixtures/cleanup_worktrees/preserve/modified/` `jq.out` and `manifest.json` (optional evidence-text correction)

#### Functions/classes/CLI commands impacted:

- New (names indicative): line-subsequence helper, multiset containment helper, base resolver, staging decision function.
- `preserve_plan_one`: calls the decision function, tracks seen `target_path` values for the pass, and appends columns 9 and 10.
- `preserve_plan`: header comment states the phase-1 blob-write exception.
- `preserve_commit_plan`: branches on column 9 (`merge` writes from `cat-file blob <oid>`; `copy` or empty keeps `cat`).
- `preserve_validate_record`: header comment rewritten so that it no longer states that `change_class` does not affect staging.
- `cleanup-worktrees.sh`: sources the new library before `cleanup_worktrees_preserve_lib.sh`; `usage` text no longer describes preserve mode as an unconditional verbatim copy.
- CLI surface `cleanup-worktrees.sh --preserve`: unchanged flags; new possible result token.

#### Data flow and validation changes:

1. Record validated (unchanged).
2. `PRESERVE|` emitted.
3. `MISSING-SOURCE`, `PATTERN-SET-MISMATCH`, `HOST-TOKEN-BLOCKED`, and `IGNORED-TARGET` checks (unchanged).
4. New: duplicate-target check, then staging decision.
5. `preserve_plan_index` (unchanged).
6. Plan entry appended with columns 9 and 10.

Phase 2 executes the entry by mode.

Inputs to the decision:
- The worktree file `<wt>/<source_path>` (plain I/O).
- Main's version `<cwt>/<target_path>` (plain I/O, and hashed with `hash-object -w --path=<target_path>` when merging).
- The base blob, resolved by:
  - `git -C <wt> rev-parse --verify --quiet HEAD`
  - `git -C <cwt> merge-base <wt-head> HEAD`
  - `git -C <cwt> rev-parse --verify --quiet <merge-base>:<source_path>`
  - Any failure means the base is unavailable.

#### Error handling and logging updates:

- Every guard failure, merge failure, Git version failure, and duplicate target emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS` plus a stderr diagnostic prefixed `cleanup-worktrees:` naming the reason (G1, merge exit code, G2, G3, guard (b), or duplicate target).
- A successful merge emits `ACTION|preserve-stage|<tgt>|OK` and may write a stderr note that the record was merged. No new stdout record type is added.
- A `cat-file blob` failure in phase 2 emits the existing `ACTION|preserve-stage|<tgt>|FAILED`.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of the change set. The refusal path is fail-closed and leaves the consolidation worktree untouched for the refused record.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Manifest input: unchanged (`preserved_files[]`, 14-column TSV projection).
- Plan-stream entry: columns 1 through 8 unchanged. Column 9 holds the mode (`copy`, `merge`, or empty meaning `copy`). Column 10 holds the merged blob oid (empty unless mode is `merge`).
- Stdout records: `ACTION|preserve-stage` vocabulary becomes `OK`, `FAILED`, `SKIPPED-INVALID`, `MISSING-SOURCE`, `HOST-TOKEN-BLOCKED`, `IGNORED-TARGET`, `MISSING-WORKTREE`, `REFUSED-WOULD-REGRESS`. Sibling channels (`preserve-manifest`, `preserve-scan`, `preserve-index`, `preserve-eol`) are unchanged.
- Line comparison: lines are split with the existing `while IFS= read -r line || [[ -n $line ]]` idiom (an unterminated final line counts), and one trailing carriage return is stripped per line before comparison.

#### Required configuration keys and defaults:

None added. Existing seams (`CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_JQ_BIN`, `CLEANUP_WT_CONSOLIDATION_PATH`, `CLEANUP_WT_MANIFEST_PATH`) are unchanged.

#### Backward-compatibility expectations:

- Records whose target is absent behave exactly as before.
- Consumers that parse `ACTION|preserve-stage` must tolerate the new `REFUSED-WOULD-REGRESS` token. No in-repository consumer enumerates the vocabulary outside the bash library (research section 2).

#### Performance constraints (latency/throughput/memory):

Bounded by a small number of git calls per record with an existing target, and linear-time line comparisons over note-sized files. No measurable constraint is set.

## Assumptions, Constraints, Dependencies
- Assumptions:
  - `worktree_path` names a linked worktree of the same repository and shares its object store with the consolidation worktree.
  - "Main's current version" of a target is the working-tree file `<cwt>/<target_path>` on the `documentationandmemories` branch.
- Constraints:
  - Bash only (bash 4+ for `declare -A`, or `sort | uniq -c`). No new Python, no PowerShell.
  - No process substitution as a git file argument, because native `git.exe` under Git Bash cannot open MSYS `/dev/fd` paths.
  - Tests must not use real Git history, `origin/main`, temporary files, or writes to checked-in fixtures (CI checkout is depth one).
- External dependencies:
  - Git 2.43 or later at runtime for the merge path (fail-closed otherwise).
  - shfmt, shellcheck, bats, and kcov in the shell-coverage CI job.

## Data / API / Config Impact
- User-facing or API changes: new `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS` result token; `modified` records with an existing target may stage merged content rather than the verbatim source.
- Data or migration considerations: none. No manifest schema change.
- Logging/telemetry updates: new stderr diagnostics for refusals and merges, prefixed `cleanup-worktrees:`.
- Compatibility notes: CLI flags unchanged; plan-stream columns appended after column 8; pack manifest gains one entry.
- Documentation:
  - `SKILL.md` gains a subsection in the `## Sanctioned Removal Manifest` area that enumerates the full `ACTION|preserve-stage` vocabulary including `REFUSED-WOULD-REGRESS`, and describes per-`change_class` staging behavior and the documented residuals.
  - Edits stay outside the `## End-to-End Workflow` fragments pinned by `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`.

## Test Strategy
- Regression tests to add or update:
  - New bats suite `tests/shell/test_cleanup_worktrees_preserve_merge.bats` with fixtures under `tests/fixtures/cleanup_worktrees/preserve/merge-*/`.
  - All git interaction goes through the recording stub `tests/fixtures/cleanup_worktrees/stub-bin/git`.
  - Merge scenarios drive `preserve_plan` only (read-only).
  - The commit-phase merge branch is driven through the `preserve_commit_one` helper pattern with destination `/dev/null` and a stubbed `cat-file`.
- Unit tests (bats, replacing pytest for this shell change) for the fixed behavior and boundaries:
  - One scenario per verdict-table row.
  - One scenario per base-unavailable cause, with and without main being a line-subsequence of the source.
  - Pure helper tests for the subsequence and multiset functions (positive, negative, empty inputs).
  - Source-guard test for the new library.
  - Negative-control assertions that `merge-file` and `hash-object` are not invoked when the target is absent.
- Edge cases and negative scenarios:
  - Both sides appended at end of file (union merge, OK).
  - Worktree addition already present on main (merged equals main, OK).
  - `main` deleted a base line adjacent to a worktree insertion (G3 refusal).
  - `source_path` differs from `target_path`.
  - Duplicate `target_path` in one pass.
  - Untracked record with an existing target (both outcomes).
  - CRLF content built inline in the test body (fixtures are LF because `eol=lf` normalizes them in CI).
  - Unterminated final line.
  - Merge usage error simulating Git older than 2.43.
- Error handling and logging verification:
  - Each refusal asserts the stdout `REFUSED-WOULD-REGRESS` record, the stderr diagnostic, `PRESERVE_EXIT=1`, no plan-stream entry, and no `preserve-index` record.
  - The commit-phase `cat-file` failure asserts `FAILED`.
- Python contract tests:
  - `test_push_down_claude_resource_contracts.py` (bundle text equality, including the new library).
  - `test_push_down_claude_pack_manifest_completeness.py` (the new bundled file is listed in `core.json`).
  - Both run through Poetry.
- Coverage impact and targets: the `shell-coverage / Shell Coverage (Bats + kcov)` job measures `.claude/skills/` with an aggregate line threshold of 85%. The new library must reach at least 85% line coverage, with per-file figures recorded from `cov.xml`. Branch coverage is not measured for bash (kcov), per `.claude/rules/general-unit-test.md`.
- Toolchain commands to run (format, lint, test):
  - `bash scripts/bash/shell-qc.sh check` (shfmt diff and shellcheck).
  - `bash scripts/bash/shell-qc.sh test --coverage` (bats over `tests/shell` with kcov).
  - Locally these run under WSL per `.claude/rules/shell.md`; type checking does not apply to bash.
  - The two Python contract tests via `poetry run pytest <path>`.
- Manual validation steps:
  - Fail-before: run the issue's repro test against the unchanged library and record the failing result under `evidence/regression-testing/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Optional: run a real-Git `--union` ordering probe under the `SCRATCH` token (outside the worktree and outside any test) and record it under `evidence/other/` with no absolute paths.

## Acceptance Criteria
- [ ] Issue repro fixed: when a `modified` record's target exists and `main`'s version contains lines absent from the older worktree snapshot, the pass never writes a file that omits any of `main`'s lines. The record either stages merged content containing every `main` line (`OK`) or emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`.
- [ ] Clean or union merge: for a `modified` record with an available base where G1, G2, and G3 pass, the plan entry has mode `merge` with the merged blob oid. Phase 2 writes the blob via `cat-file blob <oid>`. The staged content equals `main`'s version plus only the worktree's added lines, including the case where both sides appended at end of file.
- [ ] Addition already on main: a `modified` record whose worktree additions are already present on `main` produces `OK` with merged content equal to `main`'s version.
- [ ] G1 refusal: a `modified` record whose worktree file is not a line-superset (in order) of the base emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`.
- [ ] Merge-error refusal: a `merge-file` non-zero exit or usage error (simulating Git older than 2.43) emits `REFUSED-WOULD-REGRESS`, and the stderr diagnostic names the git exit code.
- [ ] G2 and G3 refusals: a merged result missing any `main` line (G2), or containing a line not among the worktree's additions such as a resurrected base line (G3), emits `REFUSED-WOULD-REGRESS`.
- [ ] Base-unavailable fallback: for each cause (no worktree `HEAD`, no merge base, file absent at the base, `source_path` differing from `target_path`), a record is copied verbatim with `OK` when `main` is a line-subsequence of the source, and emits `REFUSED-WOULD-REGRESS` otherwise.
- [ ] Refusal side effects: every `REFUSED-WOULD-REGRESS` case still emits the preceding `PRESERVE|` record, writes a `cleanup-worktrees:` stderr diagnostic naming the failed guard, and sets `PRESERVE_EXIT=1` so the pass exits 1. It appends no plan-stream entry, emits no `ACTION|preserve-index` record, and performs no index append.
- [ ] Absent target unchanged: `untracked` and `modified` records whose target is not a regular file are copied verbatim with `OK`, and the decision issues no git call (asserted on the stub argv log).
- [ ] Untracked with existing target: an `untracked` record whose target is a regular file is copied with `OK` only when `main` is a line-subsequence of the source, and otherwise emits `REFUSED-WOULD-REGRESS`.
- [ ] Duplicate target: a second record in the same pass with a `target_path` already seen emits `REFUSED-WOULD-REGRESS`, and only the first record reaches the plan stream.
- [ ] CRLF and terminator tolerance: line comparisons strip one trailing carriage return per line, and count an unterminated final line, demonstrated by bats tests with CRLF content built inline.
- [ ] Phase-1 write exception documented: the `preserve_plan` header and the library header comments state that planning writes only unreferenced blob objects (`hash-object -w`, `merge-file --object-id`) and touches no index, ref, or working-tree file.
- [ ] Existing preserve bats suites pass unchanged in outcome: `test_cleanup_worktrees_preserve.bats`, `test_cleanup_worktrees_preserve_eol.bats`, `test_cleanup_worktrees_preserve_failures.bats`, and the preserve tests in `test_cleanup_worktrees_scan_roots.bats` and `test_cleanup_worktrees_dirt_clear.bats`. The `modified` test comment is rewritten to describe the absent-target copy.
- [ ] Fail-before evidence recorded: the issue repro test was run against the unchanged library, and its failing result is recorded under `evidence/regression-testing/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] Bundle mirrors and manifest updated: the new library and the edited `SKILL.md`, `cleanup-worktrees.sh`, and `cleanup_worktrees_preserve_lib.sh` are byte-identical in the bundle, and `core.json` lists the new library. `test_push_down_claude_resource_contracts.py` and `test_push_down_claude_pack_manifest_completeness.py` pass.
- [ ] Documentation updated: `SKILL.md` contains a subsection that enumerates the full `ACTION|preserve-stage` vocabulary including `REFUSED-WOULD-REGRESS` and describes per-`change_class` staging. The `cleanup-worktrees.sh` `usage` text no longer describes preserve mode as an unconditional verbatim copy. The `preserve_validate_record` comment no longer says `change_class` does not affect staging. `merge_queue_documentation_expectations.py` assertions still pass.
- [ ] Git stub comments corrected: the stub header no longer cites production line numbers or states that no `-w` behavior exists.
- [ ] Shell QC passes: `bash scripts/bash/shell-qc.sh check` (shfmt and shellcheck) and `bash scripts/bash/shell-qc.sh test --coverage` (bats with kcov) pass. The aggregate line coverage stays at or above 85%, and `cleanup_worktrees_preserve_merge_lib.sh` reaches at least 85% line coverage per the recorded `cov.xml`.
- [ ] File-size tiers respected: no changed or new production file exceeds 500 logical lines without a recorded justification, no file reaches 801 lines, and `tests/fixtures/cleanup_worktrees/stub-bin/git` stays below 500 lines.

## Risks & Mitigations
- Technical or operational risks:
  - **Unproven fix:** the failure is silent, so the fix could be unproven without fail-before evidence.
  - **Write-free claim:** reviewers may flag phase 1 as no longer write-free.
  - **Coverage:** the new library's error and fallback branches may go undriven, lowering coverage.
  - **Mirror and manifest drift:** the bundle copies or the pack manifest may drift from the source.
  - **File size:** `cleanup_worktrees_preserve_lib.sh` (near the 500-line guidance tier) may grow past it.
  - **Fixture overwrite:** driving the commit phase against a real target file would overwrite a checked-in fixture.
  - **Git version:** the runtime Git may be older than 2.43.
  - **Union ordering:** `--union` ordering on same-position insertions is not specified in the Git manual page.
  - **Undetectable resurrection:** a resurrected line textually identical to a worktree-added line cannot be distinguished by G3.
- Mitigations and rollbacks:
  - **Unproven fix:** record fail-before evidence for the repro.
  - **Write-free claim:** document the unreferenced-blob exception in both headers.
  - **Coverage:** add one stubbed scenario per verdict row and per base-unavailable cause, plus pure helper tests.
  - **Mirror and manifest drift:** use a dedicated mirror task that runs both contract tests.
  - **File size:** put all merge logic in the new library.
  - **Fixture overwrite:** drive merge scenarios through `preserve_plan` only, and the commit phase with `/dev/null`.
  - **Git version:** fail closed to `REFUSED-WOULD-REGRESS`.
  - **Union ordering:** G2 and G3 bound the result regardless of order; the optional `SCRATCH` probe records the observed order.
  - **Undetectable resurrection:** document it as a known residual in `SKILL.md`.
  - **Rollback:** revert the change set.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge to `main`.
  - The push-down bundle carries the updated skill on the next extension build.
  - Consumers receive the change through the normal push-down path.
- Post-fix monitoring or clean-up tasks:
  - Confirm the Git version on the operator host and on `ubuntu-latest` with `git --version`.
  - Observe `REFUSED-WOULD-REGRESS` frequency in subsequent preserve passes. Refused records require manual consolidation by the operator.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/1027
  - Research: `research/2026-10-30T21-30-preserve-modified-merge-research.md`
  - Skill: `.claude/skills/cleanup-merged-worktrees/SKILL.md`
