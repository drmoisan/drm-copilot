# cleanup-report-registration-lost-false-positive (Spec)

- **Issue:** #706
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26T22-56
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Research:** `docs/features/active/cleanup-report-registration-lost-false-positive-706/research/2026-09-26-registration-lost-false-positive-research.md`

## Context
- Summary of the bug and its impact: `scripts/bash/cleanup-worktrees.sh` report mode emits `WARN|registration-lost|<path>` for healthy, fully registered worktrees whenever the worktree's `.git` pointer names its `gitdir:` target in Windows drive-letter form (`C:/...`). The record is advisory and read-only, so nothing is deleted on its basis; the cost is that a genuinely half-removed registration cannot be distinguished from the false positives. Reproduction is recorded in `issue.md` (Steps to Reproduce).
- Observed environment(s): Windows 11 Pro 10.0.26200, Git Bash (MSYS), Git for Windows. The research refutes WSL bash as a contributor (research section 2.1).
- Customer impact and severity: Low. Affects any operator running the cleanup report on Windows; on 2026-09-25 the report flagged 67 of 71 registered worktrees.
- First observed date and version(s) impacted: reported 2026-09-25. Every version of `scripts/bash/cleanup_worktrees_scan_helper.sh` that contains the `!= /*` absolute-path test at line 91 is affected.

## Repro & Evidence
- Steps to reproduce: on Windows, register worktrees under `<main>-wt/` and `<main>/.claude/worktrees/`, run `bash scripts/bash/cleanup-worktrees.sh` (report mode, no flags), and observe `WARN|registration-lost|<path>` for worktrees that `git worktree list` reports as valid.
- Expected vs actual behavior: expected, the warning is emitted only when the pointer's `gitdir:` target does not exist. Actual, the warning is emitted for worktrees whose target exists and resolves through `git -C <worktree> rev-parse --git-dir`.
- Logs/screenshots/error snippets: `WARN|registration-lost|C:/Users/DanMoisan/repos/drm-copilot-wt/no-target-followup`. That worktree's pointer file contains `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/no-target-followup`, is LF-terminated, and its target exists (issue.md Actual Behavior; research section 2).
- Frequency / determinism: deterministic and data-dependent. Every scanned pointer file whose target is written in drive-letter form is misclassified. Pointers with relative or `/`-leading targets are classified correctly.

## Scope & Non-Goals
- In scope:
  - Correct absolute-path classification of the `gitdir:` target in `scan_helper_gitdir_target_exists` so drive-letter targets are not prefixed with the worktree directory.
  - Isolation of the single existence check behind a function seam so the defect can be reproduced on Linux CI.
  - New bats tests and one new checked-in fixture reproducing the defect and pinning the preserved behavior.
- Out of scope / non-goals:
  - The 4 of 71 worktrees that were not flagged on 2026-09-25. The research attributes this, as likely but unverified, to registrations outside the two scanned roots (research section 2.2). See D7.
  - Colon-splitting of `CLEANUP_WT_ORPHAN_ROOTS` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:129-136`), which would split a drive-letter root at the drive colon. See D7.
  - Any change to the report record shape, the WARN line format, `scan_registration_loss`, or `run_report_scans`.
- Explicitly excluded systems, integrations, or datasets:
  - `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup-worktrees.sh`, and `tests/shell/test_cleanup_worktrees_report_records.bats` are not modified (D3).
  - Both `cleanup-merged-worktrees/SKILL.md` copies (`.claude/skills/...` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...`) are not modified (D4).
  - The existing fixture tree `tests/fixtures/cleanup_worktrees/scan_roots/basic/` and the existing `@test` in `tests/shell/test_cleanup_worktrees_scan_helper.bats` are not modified (D3).

## Root Cause Analysis
- Confirmed root cause: `scan_helper_gitdir_target_exists` in `scripts/bash/cleanup_worktrees_scan_helper.sh:72-99` recognises only a leading `/` as an absolute target (`if [[ $target != /* ]]`, line 91). A Git for Windows pointer target such as `C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/no-target-followup` does not begin with `/`, so the function treats it as relative and prefixes the worktree directory (line 92), producing `C:/Users/DanMoisan/repos/drm-copilot-wt/no-target-followup/C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/no-target-followup`. That path does not exist, `[[ -e $target ]]` fails (line 94), the helper emits `0` in the `gitdir_target_exists` field, and `scan_registration_loss` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:254-304`) emits `WARN|registration-lost|<path>` for the record (lines 296-298). The header comment at `cleanup_worktrees_scan_helper.sh:20-23` states that the target is "resolved relative to <path> when the target is not absolute" without defining "absolute".
- Signals/evidence supporting it (research section 2):
  - The issue's worktree pointer file contains a `gitdir: C:/...` target, and that target exists.
  - Every pointer file present directly under both scan roots on the reporting host uses the `gitdir: C:/...` form; a search for a non-`C` target over both roots returned no match.
  - Alternative causes were evaluated and refuted: WSL bash (a WARN line requires `[[ -d $root ]]` at line 109 and `[[ -f "$path/$gitfile" ]]` at line 115 to succeed on `C:/` paths, which WSL would not satisfy), and CRLF termination (already stripped at line 85; the issue records LF termination).
  - Existing tests did not detect the defect: `tests/shell/test_cleanup_worktrees_scan_helper.bats:23-34` uses only relative fixture targets (`gitdir: ../good_wt_target`, `gitdir: ../missing_target_does_not_exist`); `tests/shell/test_cleanup_worktrees_report_records.bats:76-89` replays canned records through `tests/fixtures/cleanup_worktrees/stub-bin/scan` and never runs the real helper.
- Affected components/modules:
  - Defective: `scripts/bash/cleanup_worktrees_scan_helper.sh` (`scan_helper_gitdir_target_exists`, lines 72-99; header comment lines 20-23). This is the only implementation; no bundled or mirrored copy exists (research section 3).
  - Consumer only, no path logic: `scripts/bash/cleanup_worktrees_report_records_lib.sh` (`cleanup_wt_scan_roots` lines 114-150, `cleanup_wt_scan_records` lines 152-190, `scan_registration_loss` lines 254-304, `run_report_scans` lines 306-344).
  - Related precedent, not a copy: `.claude/lib/worktree-resolution/WorktreeResolution.psm1:155-161` (`Test-WorktreeResolutionAbsolutePath`, pattern `^([A-Za-z]:(/|$)|/)` after backslash normalisation) and lines 185-213 (`Resolve-WorktreeResolutionPathAgainst`, prefixes the base only for non-absolute targets).

## Proposed Fix

### Design summary (what changes where):

In `scripts/bash/cleanup_worktrees_scan_helper.sh`:

1. Add `scan_helper_is_absolute_path <path>`, a pure predicate (no I/O) that returns 0 when the path matches `/*` or `[A-Za-z]:[/\\]*`, and 1 otherwise (D1).
2. Add `scan_helper_target_present <path>`, a one-line function containing the single filesystem existence check `[[ -e $1 ]]`, with a comment stating that it is a test seam that bats tests redefine after sourcing the helper (D2).
3. In `scan_helper_gitdir_target_exists`, replace lines 91-94 so the worktree directory is prefixed only when `scan_helper_is_absolute_path` fails, and the existence check calls `scan_helper_target_present`.
4. Update the header comment (lines 20-23) to state which target forms are treated as absolute.

Both new functions are placed immediately above `scan_helper_gitdir_target_exists` to keep the edit contiguous (D3).

### Boundaries and invariants to preserve:

- The helper remains read-only and filesystem-only; it does not execute git (`cleanup_worktrees_report_records_lib.sh:38-44` contract).
- Record shape `<path>|<has_gitfile>|<gitdir_target_exists>|<size>`, field order, `NA` semantics, glob-order emission, and exit codes are unchanged.
- An empty or missing `gitdir:` target still yields `0` (lines 87-90 unchanged).
- CR stripping and leading-whitespace stripping (lines 85-86) are unchanged.
- `/`-leading targets and relative targets behave as before.

### Dependencies or blocked work:

None. No new tool or package is introduced.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

- `scripts/bash/cleanup_worktrees_scan_helper.sh`
- `tests/shell/test_cleanup_worktrees_scan_helper.bats`
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit` (new)

The fixture path follows the existing convention in `tests/fixtures/cleanup_worktrees/scan_roots/`: one subdirectory per fixture root (`basic/`), one subdirectory per candidate worktree (`good_wt/`, `broken_wt/`), and a pointer file named `dotgit` read through `CLEANUP_WT_SCAN_GITFILE_NAME`. Its content is the single LF-terminated line `gitdir: C:/fixture-repo/.git/worktrees/wt_drive`. No target directory is checked in for it.

Evidence produced during execution is written under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/<kind>/`; those are records, not code changes.

#### Functions/classes/CLI commands impacted:

- New: `scan_helper_is_absolute_path`, `scan_helper_target_present`.
- Modified: `scan_helper_gitdir_target_exists` (classification and existence-check lines only).
- Indirectly corrected, not edited: `scan_helper_scan_dirs`, the `scan-dirs` subcommand, `scan_registration_loss`, and `cleanup-worktrees.sh` report mode.

#### Data flow and validation changes:

Target resolution becomes: read the first `gitdir:` line, strip CR and leading whitespace, return `0` if empty, prefix `<dir>/` only if `scan_helper_is_absolute_path` returns non-zero, then emit `1` if `scan_helper_target_present` succeeds, else `0`.

Classification table:

| Target form | Example | Classified as | Change |
|---|---|---|---|
| Slash-leading | `/repo/.git/worktrees/x` | absolute | none |
| Drive letter, forward slash | `C:/repo/.git/worktrees/x` | absolute | fixed |
| Lowercase drive letter | `c:/repo/.git/worktrees/x` | absolute | fixed |
| Drive letter, backslash | `C:\repo\.git\worktrees\x` | absolute | fixed |
| MSYS form | `/c/repo/.git/worktrees/x` | absolute | none |
| Relative | `../good_wt_target` | relative | none |
| Drive-relative | `C:rel` | relative | none |
| Empty | (empty) | relative (not reached; empty yields `0` earlier) | none |

#### Error handling and logging updates:

None. The helper continues to emit `0` rather than fail for a missing, unreadable, or malformed pointer. No logging is added.

#### Rollback/feature-flag considerations (if applicable):

No flag. Rollback is a revert of the single production file; the new tests would then fail, which is the intended signal.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `scan_helper_is_absolute_path <path>`: no output; exit status 0 (absolute) or 1 (not absolute).
- `scan_helper_target_present <path>`: no output; exit status 0 when the path exists, non-zero otherwise.
- `scan-dirs` output format is unchanged.

#### Required configuration keys and defaults:

No new keys. `CLEANUP_WT_SCAN_GITFILE_NAME` (default `.git`) is used unchanged by the new tests.

#### Backward-compatibility expectations:

Output format and CLI are unchanged. The only observable difference is that drive-letter targets that exist now yield `1`, which removes the false-positive WARN lines.

#### Performance constraints (latency/throughput/memory):

One additional in-process glob comparison and one function call per pointer file; no additional processes. No measurable change is expected.

## Design Decisions

- **D1 — Fix mechanism.**
  - Options considered: (a) pure-bash predicate `scan_helper_is_absolute_path` treating `/*` and `[A-Za-z]:[/\\]*` as absolute; (b) normalise the target with `cygpath -u` when available; (c) resolve each directory with `git -C <dir> rev-parse --git-dir`.
  - Adopted: (a).
  - Rationale: (a) is pure, deterministic on the ubuntu CI runner, adds no dependency, and mirrors the in-repo precedent `Test-WorktreeResolutionAbsolutePath` in `.claude/lib/worktree-resolution/WorktreeResolution.psm1:155-161`. (b) is rejected because `cygpath` exists only under MSYS/Cygwin, so its branch cannot execute in CI and would leave uncovered lines in a file whose recorded line coverage was 86.79% (46/53) on 2026-09-08; it is also unnecessary because MSYS bash already resolves `C:/...` natively. (c) is rejected because it spawns one git process per scanned directory, breaks the helper's filesystem-only contract (`cleanup_worktrees_report_records_lib.sh:38-44`), conflates a missing target with other git exit-128 failures, and would require extending the git stub. One intentional divergence from the PowerShell precedent: a bare `C:` with no separator is classified relative here, because git does not write that form and the research (section 2.1) recommends keeping drive-relative forms relative.
- **D2 — Test seam.**
  - Options considered: (a) extract the existence check into a one-line `scan_helper_target_present` function that a bats test redefines after sourcing the helper; (b) add an environment-variable seam in the repository's usual `*_BIN` style; (c) check in a fixture directory literally named `C:`.
  - Adopted: (a).
  - Rationale: the defect can only be reproduced on Linux if the existence check can be answered for a drive-letter path that does not exist on the runner. (a) is the smallest change and keeps classification (pure) separate from existence (I/O), per `.claude/rules/general-code-change.md`. No bats file in `tests/shell/` currently redefines a sourced function, so the function and the new tests carry a comment explaining the pattern. (b) would add configuration surface to production code for a single boolean check. (c) is rejected because a directory named `C:` cannot be checked out on Windows.
- **D3 — Merge-order independence.**
  - Options considered: (a) add new tests and a new fixture root, leaving existing tests and fixtures untouched; (b) extend the existing `@test` and the `scan_roots/basic/` fixture tree.
  - Adopted: (a).
  - Rationale: sibling items (issues 707-716) may touch cleanup-worktrees files (research section 8). New `@test` blocks are appended after the existing one, the fixture lives in a new `scan_roots/drive_letter/` subtree, the production edit is confined to `scan_helper_gitdir_target_exists` plus two functions placed directly above it, and acceptance is stated as named bats tests passing rather than as a total test count or a whole-file diff. `scripts/bash/cleanup_worktrees_report_records_lib.sh` and `tests/shell/test_cleanup_worktrees_report_records.bats` are not modified.
- **D4 — SKILL.md copies.**
  - Options considered: (a) leave both `cleanup-merged-worktrees/SKILL.md` copies unchanged; (b) edit both to describe drive-letter handling.
  - Adopted: (a).
  - Rationale: lines 142-144 of both copies already state the intended contract ("names a gitdir target that no longer exists"). Editing them would add a mirror-parity obligation under `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` with no behavioral benefit.
- **D5 — Quality tier.**
  - Options considered: (a) assume T4 (dev tooling) because `quality-tiers.yml` is absent on this branch; (b) create `quality-tiers.yml`; (c) assume a stricter tier.
  - Adopted: (a).
  - Rationale: the helper is developer tooling, which `.claude/rules/quality-tiers.md` lists under T4. Creating the tier file is outside this bug's scope. Under T4 no property-test or mutation obligation applies; the table-driven predicate tests are included regardless. The uniform gates apply: format, lint, and line coverage at or above 85% measured by kcov (line-only; no branch gate for bash), with no regression on changed lines.
- **D6 — Work mode.**
  - Options considered: (a) `full-bug`, as selected by the orchestration delegation and persisted in `issue.md`; (b) `minor-audit`, as carried in the GitHub issue body.
  - Adopted: (a).
  - Rationale: the persisted `- Work Mode:` marker in `issue.md` is the single source of truth for acceptance-criteria resolution. Under `full-bug`, this `spec.md` is the sole AC source and no `user-story.md` is produced.
- **D7 — Out-of-scope follow-up candidates.**
  - Options considered: (a) record as follow-up candidates without fixing; (b) include in this change.
  - Adopted: (a).
  - Rationale: neither contributes to the defect. The 4-of-71 unflagged worktrees are most likely registrations outside the two scanned roots (main checkout, scratchpad `planhome*` worktrees, a sibling `-plan` checkout, depth-2 nested worktrees); this is a likely explanation, not a verified one, and the 2026-09-25 worktree set is not preserved. The `CLEANUP_WT_ORPHAN_ROOTS` colon split affects only a documented test override, not the derived roots. Both are candidates for separate issues.
- **D8 — Invocation form of test 2.**
  - Options considered: (a) run test 2 inside a `bash -c` child that sources the helper, as originally specified in the Test Strategy; (b) invoke the helper as a script (`bash "${HELPER}" scan-dirs <root>`), the same form the existing test in `tests/shell/test_cleanup_worktrees_scan_helper.bats` uses.
  - Adopted: (b). Recorded from the atomic plan `plan.2026-09-26T22-56.md` (originally a Spec reconciliation item in plan revision 1; the plan now implements it directly under D8), adopted by the orchestrator under autonomous mode.
  - Rationale: test 2 is the test that executes the real body of `scan_helper_target_present`. Invoking the helper as a script means kcov attributes those lines the same way it attributes the existing test's lines, which removes, for test 2, the `bash -c` child-attribution risk recorded under Risks & Mitigations. Test 2 performs no function redefinition, so the script form loses no capability.
- **D9 — Placement of tests 3 and 4 and the fail-before obligation.**
  - Options considered: (a) add all four tests before the fix, as the Test Strategy's single list implied; (b) add tests 1 and 2 before the fix and append tests 3 and 4 after the fix.
  - Adopted: (b). Recorded from the atomic plan `plan.2026-09-26T22-56.md` (originally a Spec reconciliation item in plan revision 1; the plan now implements it directly under D9), adopted by the orchestrator under autonomous mode.
  - Rationale: tests 3 and 4 call `scan_helper_is_absolute_path` directly, and that function does not exist before the fix, so a pre-fix run of those tests would fail for a reason unrelated to the defect. Test 1 remains the fail-before regression test that AC-3 requires. To show that test 3 can fail, a mutation check temporarily restores the pre-fix `/`-only rule inside `scan_helper_is_absolute_path` (`[[ $path == /* ]]`), runs test 3 and records its failure, then restores the fixed line and confirms the restoration. Evidence is written under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/regression-testing/`.
- **D10 — Sibling changes to the edit sites on `origin/main`.**
  - Options considered: (a) halt the plan when the Phase 0 sibling-detection step finds that a sibling item (issues 707-716) has already changed an edit site on `origin/main`; (b) continue, and resolve any resulting conflict when the branch is rebased on `main`, performed by the executing orchestrator.
  - Adopted: (b), by the orchestrator under autonomous mode.
  - Rationale: the repository practice is to rebase the branch on `main` before creating the PR, which is the point where a sibling change to the same lines appears as a conflict and can be resolved against the merged content. Edits are located by content anchors rather than line numbers (D3), so an unrelated sibling change does not invalidate them. A missing anchor on the working branch itself still stops the plan, because the edit cannot be applied.

## Assumptions, Constraints, Dependencies
- Assumptions: Git for Windows writes pointer targets with forward slashes and an uppercase drive letter (verified on the reporting host); lowercase and backslash forms are handled at no extra cost. The bats working directory in CI does not contain an entry named `C:`, so a drive-letter path classified absolute is reported as missing on Linux.
- Constraints: tests run in Linux CI (`.github/workflows/_shell-coverage.yml`, `ubuntu-latest`) with a depth-1 checkout, no `origin/main`, no gitignored state, no temporary files, no scratch git repositories, no CRLF fixtures, and no existing Windows drive letters. Files stay under 500 lines. Local bats execution may be refused in agent worktrees on the Windows host; CI results are canonical.
- External dependencies: none beyond the existing shell toolchain (shfmt 3.8.0, shellcheck, bats, kcov v43 in CI).

## Data / API / Config Impact
- User-facing or API changes: report mode stops emitting `WARN|registration-lost` for healthy worktrees with drive-letter pointer targets. No flag or format changes.
- Data or migration considerations: none. The report is read-only.
- Logging/telemetry updates: none.
- Compatibility notes: CLI flags, record format, and `CLEANUP_WT_*` variables are unchanged.

## Test Strategy
- Regression tests to add (appended to `tests/shell/test_cleanup_worktrees_scan_helper.bats`, after the existing `@test`, in the order 1-4). Tests 1 and 2 are appended before the fix; tests 3 and 4 are appended after the fix (D9).
  1. `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory` — sources the helper in a `bash -c` child, redefines `scan_helper_target_present` to succeed only for the exact string `C:/fixture-repo/.git/worktrees/wt_drive`, sets `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit`, calls `scan_helper_scan_dirs` on `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter`, and asserts the output matches `*/wt_drive|1|1|`. Against the pre-fix helper the redefined function is never called, the inline check on the prefixed path fails, the record is `|1|0|`, and the test fails. After the fix, the exact-match comparison proves the directory was not prepended. This is the fail-before regression test for AC-3.
  2. `scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist` — invokes the helper as a script (`bash "${HELPER}" scan-dirs <drive_letter root>` with `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit`), the same form as the existing test, with no function redefinition, and asserts `*/wt_drive|1|0|` (D8). This executes the real `scan_helper_target_present` and pins that genuine losses are still reported.
  3. `scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths` — table-driven over `/abs`, `C:/x`, `c:/x`, and `C:\x`. Appended after the fix because the function does not exist before it (D9). A mutation check that temporarily restores the pre-fix `/`-only rule in the predicate demonstrates that this test can fail; the fixed line is then restored.
  4. `scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths` — table-driven over `../rel`, `rel`, `C:rel`, and the empty string. Appended after the fix (D9).
- Unit tests: bats (not pytest); all four tests above are unit tests of the helper. The existing test `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` is kept unchanged and continues to pin the relative-present (`good_wt|1|1|`), relative-missing (`broken_wt|1|0|`), and no-pointer (`no_git|0|NA|`) cases.
- Edge cases and negative scenarios: lowercase drive, backslash separator, drive-relative `C:rel`, empty string, and missing drive-letter target are covered by tests 2-4. The empty-target path (lines 87-90) is unchanged.
- Error handling and logging verification: no error paths change; test 2 confirms a missing target yields `0` rather than a failure exit.
- Coverage impact and targets: capture a fresh per-file baseline for `scripts/bash/cleanup_worktrees_scan_helper.sh` from `artifacts/pester/kcov/cov.xml` before the change (the 46/53, 86.79% figure dates from 2026-09-08), then confirm after the change that every new or modified line has non-zero hits and that the file and the overall bash line coverage remain at or above 85%. Test 1 executes the predicate's true path and the seam call, test 2 executes the real seam body through a script invocation that kcov attributes the same way as the existing test (D8), and tests 3-4 execute both predicate outcomes. Record baseline and post-change figures under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/<kind>/`.
- Toolchain commands to run, in order, restarting on any failure or rewrite: `bash scripts/bash/shell-qc.sh format`; `bash scripts/bash/shell-qc.sh check`; (type-check not applicable; optional `bash -n`); `bash scripts/bash/shell-qc.sh test`; `bash scripts/bash/shell-qc.sh test --coverage`. CI (`.github/workflows/_shell-coverage.yml`) is canonical.
- Manual validation steps: optional, not required by any criterion. On the Windows host, `bash scripts/bash/cleanup-worktrees.sh` should emit no `WARN|registration-lost` line for a worktree whose pointer target exists.

## Acceptance Criteria
- [x] AC-1: Report mode does not emit `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that exists, including when the target is written in a Windows drive-letter form. Verified by the bats tests `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory` and `scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths` passing in `tests/shell/test_cleanup_worktrees_scan_helper.bats`, and by the existing test `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` continuing to pass unchanged.
- [x] AC-2: Report mode still emits `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that does not exist. Verified by the bats tests `scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist` and `scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths` passing, by the existing `broken_wt|1|0|` assertion continuing to pass, and by `tests/shell/test_cleanup_worktrees_report_records.bats` passing without modification.
- [x] AC-3: The root cause of the false positive is identified and documented in this `spec.md` (Root Cause Analysis, with file and line citations), and the regression test `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory` is shown to fail against the pre-fix helper and to pass after the fix, with both outcomes recorded under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/<kind>/`.
- [x] AC-4: The shell toolchain passes for the changed files: `bash scripts/bash/shell-qc.sh format` makes no changes, `bash scripts/bash/shell-qc.sh check` reports no shfmt diff and no shellcheck finding, and `bash scripts/bash/shell-qc.sh test --coverage` passes in CI; overall bash line coverage and the per-file line coverage of `scripts/bash/cleanup_worktrees_scan_helper.sh` are each at or above 85%, and every new or modified line in that file has non-zero hits in `cov.xml`.

## Risks & Mitigations
- Technical or operational risks:
  - Redefining a sourced function is a new test pattern in `tests/shell/`; a future refactor could inline the existence check and silently bypass the seam. Mitigation: test 1 asserts `|1|1|` for a path that does not exist on the runner, so bypassing the seam makes the test fail; the seam carries an explanatory comment.
  - The per-file coverage margin is small. Mitigation: each new line is executed by a named test, and the per-file figure is recorded before and after.
  - kcov attribution of lines executed inside a `bash -c` child that sources the helper is assumed but not yet verified for this file; tests 1, 3, and 4 use that form. Mitigation: test 2 invokes the helper as a script (D8), so the real existence-check body does not depend on child attribution; confirm non-zero hits for the new lines in `cov.xml`; if any are missing, invoke the helper in a way the existing coverage run already attributes.
  - Sibling items may edit the same files. Mitigation: D3 confinement and named-test acceptance; a sibling change already merged to `origin/main` is resolved at rebase time (D10).
- Mitigations and rollbacks: revert the production file; no data or configuration migration is involved.

## Rollout & Follow-up
- Release/rollout steps: merge through the standard PR flow; no release-specific step. The scan helper is not part of the extension payload, so no push-down or rebuild is required.
- Post-fix monitoring or clean-up tasks: optional manual run of report mode on the Windows host. Candidate follow-up issues (D7): unscanned worktree locations explaining the 4-of-71 gap, and `CLEANUP_WT_ORPHAN_ROOTS` colon-splitting of drive-letter roots.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/706; research `docs/features/active/cleanup-report-registration-lost-false-positive-706/research/2026-09-26-registration-lost-false-positive-research.md`; precedent `.claude/lib/worktree-resolution/WorktreeResolution.psm1`.
