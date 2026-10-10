# 2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups (Plan)

- **Issue:** #842
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08
- **Status:** Draft
- **Version:** 1.1
- **Work Mode:** minor-audit
- **Branch:** `bug/cleanup-worktrees-scan-root-derivation-follow-ups-842`
- **Language in scope:** shell scripts and bats tests; one Python pytest run for bundle-mirror parity only
- **Requirements source (sole AC source):** `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`, section `## Acceptance Criteria` (AC-1 through AC-7) and its `### Assumptions`.
- **Design input (not a requirements source):** `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/research/2026-10-09T02-22-scan-root-derivation-follow-ups-research.md`. Every line number and test name this plan takes from it was re-derived against the current tree at planning time.
- **Precedent:** the approved plan of issue #741 (`docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md`) used the same toolchain on the same scripts. Its command shapes are reused.

**Mode note (minor-audit):** `spec.md` and `user-story.md` must not exist in the feature folder and are not required. Only the `## Acceptance Criteria` section of `issue.md` is the acceptance-criteria source. Execution fails closed if `spec.md` or `user-story.md` appears in the feature folder, if the `## Acceptance Criteria` section is missing from `issue.md`, if a required Phase 0 artifact is missing or incomplete, or if checklist state contradicts evidence on disk.

**Fail-closed evidence rule:** Shell policy (`.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`) requires kcov line coverage >= 85%; kcov measures no branch coverage for shell scripts, so no branch gate applies. Baseline and final coverage tasks record numeric values. If any required baseline artifact, final-QC artifact, or numeric coverage value is missing, the outcome is remediation-required and the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the task's last command other than a grep; a task made only of greps records the last grep's exit code. Every other command's exit code and printed value are recorded inside `Output Summary:`. No planned command task may record `EXIT_CODE: SKIPPED`.

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no override was recorded.
- TS means the execution time of the task in yyyy-MM-ddTHH-mm form, read from the host clock.
- SCRATCH means the executor's session scratchpad directory, outside the repository. Artifacts record it as the literal token SCRATCH, never as a host path.
- MERGE_BASE means the commit printed by `git merge-base origin/main HEAD` in P0-T3. Every scope diff is anchored to MERGE_BASE and never to `origin/main`, because `origin/main` advances during execution; a comparison against a moving ref would report upstream changes as changes made by this plan.
- BRANCH means `bug/cleanup-worktrees-scan-root-derivation-follow-ups-842`.
- SCRIPTS means the directory `.claude/skills/cleanup-merged-worktrees/scripts`. MIRROR-SCRIPTS means the directory `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts`.
- BATS means `npx --yes bats --formatter tap`. The TAP formatter is fixed so every run prints a `1..N` plan line and one `ok` or `not ok` line per test.
- TARGETED-SET means these six suites, in this order: `tests/shell/test_cleanup_worktrees_scan_roots.bats`, `tests/shell/test_cleanup_worktrees_report_records.bats`, `tests/shell/test_cleanup_worktrees_scan_helper.bats`, `tests/shell/test_cleanup_worktrees_scan_seam.bats`, `tests/shell/test_cleanup_worktrees_enumeration.bats`, `tests/shell/test_cleanup_worktrees_detached.bats`. Planning-time static `@test` counts are 16, 18, 3, 2, 15, and 26 (total 80). The TAP plan line recorded by P0-T9 is authoritative and is named BASELINE_N.
- CHANGED-SH means the three production scripts this plan edits: `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
- Appendix A holds the exact fixture contents and the exact bats text. Appendix B holds the exact production-script edits.

## Execution constraints

- Host: Windows with Git for Windows. The agent worktree may refuse command text containing the words bash, pwsh, or wsl and may refuse heredocs. Every command in this plan avoids them and none starts with an interpreter name. Files are written with the Write or Edit tools; mirrors are written with `cp` only.
- Local tools: `shfmt`, `shellcheck`, `npx --yes bats`, `poetry`, `gh`, `git`, `grep`, `awk`, `wc`, `cp`, `cmp`. kcov has no local route; kcov line coverage is CI-authoritative and comes only from the `_shell-coverage.yml` job (`.github/workflows/_shell-coverage.yml`, called by `.github/workflows/ci.yml`). CI tool versions (shfmt 3.8.0, apt shellcheck and bats, kcov v43) are canonical when local and CI results disagree (`.claude/rules/shell.md`). `jq` is not installed locally; use `gh ... --json ... --jq`.
- Report mode and fixtures only. No command in this plan removes a worktree, deletes a branch, prunes, resets, or force-pushes, and the tests create no temporary files.
- Hooks. If a hook or the isolation guard denies a command, stop and report the denial text. Do not bypass it. If a stated local bats command cannot run, the task fails: the artifact records the denial or error text and the plan stops for the caller. No task substitutes another command.
- Stop conditions. When a task's stop condition is reached, write the task's artifact with the stop reason and report to the caller. Do not improvise a substitute design.
- Scope exclusions. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` and `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh` carry further `SC1091` directives; AC-4 names only the scan helper, so they are not edited. Line 23 of the detached library cites `cleanup_worktrees_actions_lib.sh:19-35`, which matches the "Guarded-read invariant" paragraph at planning time; it is not edited.

## Recorded design decisions

- D1 — M-3 drops, it does not emit `D:/`. `cleanup_wt_derive_scan_roots` in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` gains the line `cleanup_wt_is_absolute_path "$parent" || continue`, which drops a derived parent that is not absolute. This is the `### Assumptions` choice of `issue.md`, matches override handling at the predicate call in `cleanup_wt_split_roots`, and matches the existing POSIX behavior for a registration `/wt` (empty parent, already skipped by the existing guard). Emitting `D:/` would add every immediate subdirectory of the drive root to an advisory scan.
- D2 — Insertion point. At planning time `cleanup_wt_derive_scan_roots` spans lines 319-372; line 349 is `parent=${p%/*}`, line 350 is `[[ -z $parent || $parent == "$p" ]] && continue`, and line 351 is `n=$(normalize_wt_path "$parent")`. The new code line goes immediately after line 350 and before line 351, so `normalize_wt_path` is never called on a drive-relative value and `D:` never reaches `seen` or `kept`. The check runs after the backslash conversion because `parent` derives from `p`, the output of the `${paths[i]//\\//}` conversion on line 348. A one-line comment is added directly above the code line. The comment must not contain the identifier `cleanup_wt_is_absolute_path`, so the code line is the only line of the file with the literal `cleanup_wt_is_absolute_path "$parent"`. Net growth: 2 lines.
- D3 — Which new tests fail before the fix. The three drive-relative tests (AC-1, AC-3) fail before the fix and are tagged `[expect-fail]`. The two backslash tests (AC-2) pass before the fix, because the `${paths[i]//\\//}` conversion already works; they close the coverage gap named by N-1 and are not expect-fail. The fail-before artifact therefore records exactly 3 `not ok` lines and the pass-after run records 0.
- D4 — Two new checked-in fixtures, each a single `worktree-list.out` replayed by the git stub (`tests/fixtures/cleanup_worktrees/stub-bin/git`, `worktree list --porcelain` key `worktree-list`). Both are LF-only with no CR bytes; the backslash fixture carries literal backslash bytes. `.gitattributes` line 1 is `* text=auto eol=lf` and no `.gitattributes` change is needed.
- D5 — Tooling scope for `shfmt -d` and `shellcheck` is CHANGED-SH only. The repository's bats files use 4-space indentation rather than shfmt's default tabs, so `shfmt -d` exits non-zero on them before any edit (recorded in the #741 plan, decision D9, and its preflight round 1 artifact); the bats files are gated by execution (P1-T14, P2-T3) and by line count (P2-T6). Mirror copies are byte-identical to their canonical files and are not linted separately.
- D6 — Baseline and final coverage come from the same kind of source: the `Shell Coverage (Bats + kcov)` job of a `ci.yml` run, its log line `Bash coverage (lines): NN.N%`, and the `shell-coverage` artifact `cov.xml`. Per-file line rate is read from the `<class ... filename="<repo-relative path>" ... line-rate="0.NNN">` element of that `cov.xml`.
- D7 — Commit, push, and pull-request creation are performed by the orchestrator's commit and pr-author flow, not by a task in this plan. P2-T17 and P2-T18 are post-push tasks executed by the later execution run once the pull request exists.
- D8 — Tier and obligations. The skill scripts are developer tooling (T4 in `.claude/rules/quality-tiers.md`). No property-test or mutation obligation applies.

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Verify the minor-audit preconditions for FEATURE and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `grep -c -x -F "## Acceptance Criteria" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "Work Mode: minor-audit" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `ls docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842`.
      Acceptance: the first two greps print 1; the third prints 7; the fourth prints 0 and exits 1 (the pass condition here); the listing contains neither `spec.md` nor `user-story.md`. Any other result stops the plan. `ls` is the last non-grep command, so the artifact's top-level `EXIT_CODE:` is its exit code.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/shell.md`; (5) `.claude/rules/quality-tiers.md`; (6) `.claude/rules/tonality.md`.
      Acceptance: the artifact has the three required headers and lists all 6 files in that order.
- [x] [P0-T3] Record MERGE_BASE and the clean pre-edit state of every path this plan edits, and record FEATURE/evidence/baseline/merge-base.TS.md.
      Commands: `git fetch origin main`; `git branch --show-current`; `git rev-parse HEAD`; `git merge-base origin/main HEAD`; `git diff --name-only MERGE_BASE -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell tests/fixtures/cleanup_worktrees` (substitute the SHA printed by the merge-base command for MERGE_BASE); `git status --porcelain --untracked-files=all -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell tests/fixtures/cleanup_worktrees`.
      Acceptance: the branch name printed equals BRANCH; `git rev-parse HEAD` prints one 40-character SHA; the merge-base prints one 40-character SHA, recorded as MERGE_BASE; the anchored diff prints nothing (the branch carries no script, test, or fixture change relative to its merge base); the status command prints nothing. Any other output stops the plan, because the baseline would not measure the committed code.
- [x] [P0-T4] Baseline line counts for CHANGED-SH and the bats suite this plan edits, and record FEATURE/evidence/baseline/line-counts.TS.md.
      Command: `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: exit 0; the four counts are recorded as BASE_LINES_ENUM, BASE_LINES_HELPER, BASE_LINES_DETACHED, and BASE_LINES_BATS (planning-time values 416, 171, 301, and 242). Each of the first three must be at most 497 so the +2 growth stays within the 500-line cap, and BASE_LINES_BATS must be at most 400 so the added tests stay within it; a larger value stops the plan.
- [x] [P0-T5] Baseline mirror identity for the three source and mirror pairs and record FEATURE/evidence/baseline/mirror-identity.TS.md.
      Commands: `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: each `cmp` exits 0 and prints nothing (cmp prints a `differ: byte` line and exits 1 only on a difference). An unequal pair stops the plan, because a later copy would then not be a pure sync. The artifact's top-level `EXIT_CODE:` is the exit code of the last `cmp`; the first two exit codes are recorded in `Output Summary:`.
- [x] [P0-T6] Baseline absence of the new fixtures and new test names, and record FEATURE/evidence/baseline/new-artifacts-absent.TS.md.
      Commands: `git ls-files -- tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash`; `grep -c -F "scan_roots_drive_relative" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "scan_roots_backslash" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c "^@test " tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the `git ls-files` output is empty; the two fixture-name greps each print 0 and exit 1; the `@test` grep prints 16. `git ls-files` lists tracked files only, which is the intended scope because the fixtures do not exist yet; the later fixture checks (P1-T2, P1-T3, P2-T7) use plain `grep` on the files. Any other result stops the plan.
- [x] [P0-T7] Baseline format check over CHANGED-SH in diff mode, and record FEATURE/evidence/baseline/shfmt.TS.md.
      Command: `shfmt -d .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: the command runs and its exit code and output are recorded. `shfmt -d` is read-only; it prints nothing and exits 0 on a clean file set, and prints a unified diff and exits non-zero otherwise. A non-empty diff is recorded verbatim as pre-existing drift, which P2-T1 must show cleared.
- [x] [P0-T8] Baseline lint over CHANGED-SH, and record FEATURE/evidence/baseline/shellcheck.TS.md.
      Command: `shellcheck .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: the exit code and output are recorded. shellcheck prints nothing and exits 0 when it finds nothing. Every finding line is recorded verbatim as pre-existing, which P2-T2 must show cleared.
- [x] [P0-T9] Baseline local bats run over TARGETED-SET (`tests/shell/`), and record FEATURE/evidence/baseline/bats-targeted.TS.md.
      Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_detached.bats`.
      Acceptance: the exit code, the `1..N` plan line, and every `not ok` line are recorded; N is recorded as BASELINE_N (planning-time static expectation 80). The `not ok` lines, if any, are the local baseline failure set. A `not ok` line from `tests/shell/test_cleanup_worktrees_scan_roots.bats`, `tests/shell/test_cleanup_worktrees_report_records.bats`, or `tests/shell/test_cleanup_worktrees_scan_helper.bats` stops the plan, because those suites gate AC-1 through AC-3.
- [x] [P0-T10] Baseline bundle-parity pytest (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`), and record FEATURE/evidence/baseline/bundle-parity-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
      Acceptance: the exit code and the pytest summary line (passed and failed counts) are recorded; a clean run prints a line of the form `N passed` and exits 0 (the #741 run printed `14 passed`). A failure whose only assertion message begins with the literal "Repo file missing from bundle:" and names a path for which `git check-ignore -q` exits 0 is recorded as the known local issue #510 (`KL-510: STATE-ONLY`, with `ExpectedExitCode: 1`). Any other failure stops the plan.
- [x] [P0-T11] Baseline kcov line coverage from the most recent green main run (`.github/workflows/_shell-coverage.yml`, called by `.github/workflows/ci.yml`), and record FEATURE/evidence/baseline/shell-coverage-main.TS.md. A numeric value is required.
      Commands: `git fetch origin main`; `gh run list --workflow ci.yml --branch main --event push --limit 10 --json databaseId,headSha,createdAt`; then, for each listed databaseId in the printed order (newest first) until one prints `success`, `gh run view RUN_ID --json jobs --jq '.jobs[] | select(.name | contains("Shell Coverage")) | .conclusion'`; for the first run that prints `success` (recorded as BASELINE_RUN_ID, with its headSha), `gh run view BASELINE_RUN_ID --json jobs --jq '.jobs[] | select(.name | contains("Shell Coverage")) | .databaseId'` (recorded as BASELINE_JOB_ID); `gh run view BASELINE_RUN_ID --log --job BASELINE_JOB_ID | grep -F "coverage (lines)"`; `gh run view BASELINE_RUN_ID --log --job BASELINE_JOB_ID | grep -c "not ok"`; `gh run download BASELINE_RUN_ID -n shell-coverage -D SCRATCH/ci-baseline`; `grep -F 'filename=".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"' SCRATCH/ci-baseline/cov.xml`.
      Acceptance: a run whose Shell Coverage job prints `success` is found among the 10 listed; the log line `Bash coverage (lines): NN.N%` is recorded with its number as BASELINE_AGGREGATE; the `not ok` count is 0 (grep prints 0 and exits 1, which is the pass condition here); the `<class>` line printed by the last grep carries `line-rate="0.NNN"`, recorded as BASELINE_ENUM_RATE together with the cov.xml line number of that element (add `-n` to read it). BASELINE_AGGREGATE and BASELINE_ENUM_RATE are the baseline numeric values for P2-T17. Remediation-required, not PASS, applies when no listed run prints `success`, when the log line is absent, when the artifact has expired or does not download, or when the `<class>` line is absent: the artifact then records `REMEDIATION-REQUIRED` with the failing command and its output, the task is not checked off, and the plan stops for the caller. A recorded BASELINE_ENUM_RATE below 0.850 is a pre-existing shortfall; it is recorded and reported to the caller, and P2-T17 still requires the final value to reach 0.850.

### Phase 1 — Constrained Small-Path Implementation

This phase is one delegated handoff. The small-path implementation engineer performs P1-T2 through P1-T14 in order. No implementation is performed during planning. Each of P1-T2 through P1-T14 writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number) recording its commands, exit codes, and output summary, except P1-T7 and P1-T14, whose artifacts are named in those tasks. Each such artifact carries exactly one top-level `EXIT_CODE:`, equal to the exit code of the task's last non-grep command. Each grep's printed value and exit code are recorded inside `Output Summary:` as `GREP value=<v> exit=<n>`, in command order. The exact text of every fixture, test, and script edit is in Appendix A and Appendix B.

- [x] [P1-T1] Delegated implementation handoff: apply P1-T2 through P1-T14 to the nine repository files listed in the Write list at the end of this plan (the three canonical scripts, their three bundle mirrors, the bats suite, and the two fixtures) and to no other repository file.
      Constraints: report mode and fixtures only, with no real-worktree cleanup, removal, prune, reset, or force-push command; no edit to `cleanup-worktrees.sh`, `cleanup_worktrees_preserve_eol_lib.sh`, `cleanup_worktrees_actions_lib.sh`, or any other script; no temporary files in tests; no `set -u` added to any `*_lib.sh`; mirrors are produced by `cp`, never by Write or Edit; fixtures carry LF line endings and no CR byte.
      Acceptance: every acceptance condition of P1-T2 through P1-T14 holds, and FEATURE/evidence/other/p1-t1.TS.md records the engineer's completion report (no `EXIT_CODE:` line, because P1-T1 runs no command).
- [x] [P1-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out` with LF line endings and exactly the content of fixture F1 in Appendix A (three stanzas: main `C:/repo/main`, then `D:/wt`, then `D:/other/x`).
      Commands: `grep -c "^worktree " tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`; `grep -c -F "worktree D:/wt" tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`; `grep -c -P "\r" tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`; `wc -l tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`; `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative`.
      Acceptance: the first grep prints 3; the second prints 1; the third prints 0 and exits 1 (no CR byte; the pass condition here); `wc -l` prints 12; the status output lists the new file as untracked. The checks use plain `grep`, because `git grep` does not search untracked files.
- [x] [P1-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out` with LF line endings and exactly the content of fixture F2 in Appendix A (three stanzas: main `C:/repo/main`, then `C:\repo\main-wt\a`, then `C:\scratch\plan\p1`, the last two with literal backslash bytes).
      Commands: `grep -c "^worktree " tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`; `grep -c -F 'worktree C:\repo\main-wt\a' tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`; `grep -c -F 'worktree C:\scratch\plan\p1' tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`; `grep -c -P "\r" tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`; `wc -l tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`; `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash`.
      Acceptance: the first grep prints 3; the second and third each print 1; the CR grep prints 0 and exits 1 (the pass condition here); `wc -l` prints 12; the status output lists the new file as untracked.
- [x] [P1-T4] Add the file-local helper `derive_run` to `tests/shell/test_cleanup_worktrees_scan_roots.bats`, placed immediately after the existing `report_run` helper, with the exact text of helper H1 in Appendix A.
      Commands: `grep -c -F "derive_run()" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c "^@test " tests/shell/test_cleanup_worktrees_scan_roots.bats`; `git status --porcelain -- tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the first grep prints 1; the second prints 16 (no test added yet); the status lists the file as modified. `git status` is the last command, so the artifact's top-level `EXIT_CODE:` is its exit code.
- [x] [P1-T5] [expect-fail] Add the three drive-relative regression tests to the end of `tests/shell/test_cleanup_worktrees_scan_roots.bats`, in this order, with these exact names and the exact text of tests T1, T2, and T3 in Appendix A: (T1) `cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root`; (T2) `cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration`; (T3) `run_report passes no drive-relative root to its single filesystem scan`.
      Commands: `grep -c "^@test " tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "drops a drive-relative parent for a registration directly under another drive root" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "does not emit a drive-relative root for a D:/wt registration" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "passes no drive-relative root to its single filesystem scan" tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the first grep prints 19; each of the other three prints 1. These tests are expected to fail until P1-T8; the run that proves it is P1-T7.
- [x] [P1-T6] Add the two backslash tests to the end of `tests/shell/test_cleanup_worktrees_scan_roots.bats`, after the three tests of P1-T5, with these exact names and the exact text of tests T4 and T5 in Appendix A: (T4) `cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent`; (T5) `cleanup_wt_scan_roots emits forward-slash roots for backslash registrations`. These tests are not tagged expect-fail: the conversion on line 348 already works, so they pass before the M-3 fix (decision D3).
      Commands: `grep -c "^@test " tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "converts a backslash registration path before taking its parent" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `grep -c -F "emits forward-slash roots for backslash registrations" tests/shell/test_cleanup_worktrees_scan_roots.bats`; `wc -l tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the first grep prints 21; each name grep prints 1; the line count is at most 500.
- [x] [P1-T7] [expect-fail] Run the new suite before any production edit and record FEATURE/evidence/regression-testing/expect-fail-scan-root-derivation.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain --untracked-files=all -- .claude/skills extensions`; `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the status command prints nothing (no production file or mirror has changed yet); bats exits 1 and prints `1..21`; exactly 3 `not ok` lines, `not ok 17` naming T1, `not ok 18` naming T2, and `not ok 19` naming T3; `ok` lines for tests 1 through 16, `ok 20` naming T4, and `ok 21` naming T5. Every line of TAP output is recorded. Any other pass/fail split stops the plan. The artifact's top-level `EXIT_CODE:` is the bats exit code (1).
- [x] [P1-T8] Edit `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` to fix M-3: insert the two lines of edit E1 in Appendix B between the guard line `[[ -z $parent || $parent == "$p" ]] && continue` and the line `n=$(normalize_wt_path "$parent")` inside `cleanup_wt_derive_scan_roots`, indented with two tabs. The inserted code line is `cleanup_wt_is_absolute_path "$parent" || continue`.
      Commands: `grep -c -F 'cleanup_wt_is_absolute_path "$parent"' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `grep -n -F -e 'cleanup_wt_is_absolute_path "$parent"' -e '[[ -z $parent || $parent == "$p" ]] && continue' -e 'n=$(normalize_wt_path "$parent")' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `npx --yes bats --formatter tap --filter "drive-relative parent|drive-relative root" tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: the first grep prints 1 (it printed 0 before the edit); the second grep prints three lines in this order: the guard line at line number G (planning-time value 350), the new code line at G+2, and the `n=` line at G+3; the `wc -l` count equals BASE_LINES_ENUM plus 2; bats exits 0, prints `1..3`, and prints 3 `ok` lines naming T1, T2, and T3. The filter matches the three new tests only, because the existing test name containing `drive-relative` reads "relative, drive-relative, and empty paths" and matches neither alternative.
- [x] [P1-T9] Edit M-2 in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`: insert the two comment lines of edit E2 in Appendix B immediately after the line `set -euo pipefail` and before the line `# shellcheck source=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`. No other line changes.
      Commands: `grep -c -F "benign result" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `grep -n -F -e 'benign result' -e 'shellcheck source=' -e 'shellcheck disable=SC1091' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_helper.bats`.
      Acceptance: the first grep prints 1; the second grep prints exactly three lines, `44:` the reason line, `45:` the `shellcheck source=` line, and `46:` the `shellcheck disable=SC1091` line (planning-time numbering: `set -euo pipefail` is line 42 and the two inserted lines become 43 and 44); the line count equals BASE_LINES_HELPER plus 2; bats exits 0, prints `1..3`, and prints 3 `ok` lines.
- [x] [P1-T10] Edit M-1 in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`: replace the single line 46 of `is_detached_candidate` with the replacement line of edit E3 in Appendix B, so the comment names `emit_record`, nested in `parse_worktree_list`, instead of a line range. No other line changes.
      Commands: `grep -c -F "enumerate_lib.sh:115" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; `grep -c -F "emit_record, nested in parse_worktree_list" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_detached.bats`.
      Acceptance: the first grep prints 0 and exits 1 (it printed 1 before the edit; the pass condition here); the second prints 1; the line count equals BASE_LINES_DETACHED; bats exits 0 with a `1..N` plan line, N equal to the planning-time static count of 26, and every line `ok`.
- [x] [P1-T11] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` by byte copy from its canonical file.
      Commands: `cp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`.
      Acceptance: cp exits 0; cmp exits 0 and prints nothing; the status shows the mirror modified.
- [x] [P1-T12] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` by byte copy from its canonical file.
      Commands: `cp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`.
      Acceptance: cp exits 0; cmp exits 0 and prints nothing; the status shows the mirror modified.
- [x] [P1-T13] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` by byte copy from its canonical file.
      Commands: `cp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; `cmp .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: cp exits 0; cmp exits 0 and prints nothing; the status shows the mirror modified.
- [x] [P1-T14] Pass-after gate: run TARGETED-SET (`tests/shell/`) together after every production change, and record FEATURE/evidence/regression-testing/pass-after-scan-root-derivation.TS.md.
      Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_detached.bats`.
      Acceptance: exit 0; the plan line is `1..M` with M equal to BASELINE_N plus 5; all 21 tests of `tests/shell/test_cleanup_worktrees_scan_roots.bats` print `ok`, including the 3 that printed `not ok` in P1-T7; no `not ok` line appears outside the P0-T9 baseline failure set. The artifact lists each of the 3 P1-T7 failures with its new `ok` line.

### Phase 2 — Final QC Loop, Targeted Verification, and End State

Run the shell toolchain in this order: format check (P2-T1), lint (P2-T2), type checking (not applicable to shell scripts per `.claude/rules/shell.md`; no task), bats (P2-T3), bundle-parity pytest (P2-T4), mirror byte-identity (P2-T5). If any of P2-T1 through P2-T5 fails or its remediation changes a file, the small-path engineer remediates, re-runs the matching mirror copy task (P1-T11 through P1-T13) for every changed canonical file, and restarts from P2-T1. Every Phase 2 command task is unconditional; none has a SKIPPED outcome. P2-T17 and P2-T18 are post-push tasks (decision D7). Artifacts go to FEATURE/evidence/qa-gates/ unless stated.

- [x] [P2-T1] Format check over CHANGED-SH in diff mode, and record FEATURE/evidence/qa-gates/shfmt.TS.md.
      Command: `shfmt -d .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: exit 0 and no output, which is the literal success-case observation of `shfmt -d` (it prints a unified diff and exits non-zero when a file is not formatted). On a diff, the engineer corrects the formatting by Edit to match the printed diff, re-copies the mirrors per P1-T11 through P1-T13, and restarts from P2-T1.
- [x] [P2-T2] Lint over CHANGED-SH, and record FEATURE/evidence/qa-gates/shellcheck.TS.md.
      Command: `shellcheck .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`.
      Acceptance: exit 0 and no output. Every pre-existing finding recorded by P0-T8 is absent.
- [x] [P2-T3] Local bats run over TARGETED-SET (`tests/shell/`), and record FEATURE/evidence/qa-gates/bats-targeted.TS.md.
      Command: the P1-T14 command.
      Acceptance: exit 0 or the P0-T9 failure set only; the plan line is `1..M` with M equal to BASELINE_N plus 5; no `not ok` line from `tests/shell/test_cleanup_worktrees_scan_roots.bats`, `tests/shell/test_cleanup_worktrees_report_records.bats`, or `tests/shell/test_cleanup_worktrees_scan_helper.bats`; no `not ok` line outside the P0-T9 baseline failure set. The full suite is gated in CI by P2-T17.
- [x] [P2-T4] Bundle parity pytest for AC-6 (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`), and record FEATURE/evidence/qa-gates/bundle-parity-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
      Acceptance, case (a): exit 0 and a summary line of the form `N passed` with no failure; the artifact records `KL-510: PASSED`. Case (b), the known local issue #510: the only failing node is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, its assertion message begins with the literal "Repo file missing from bundle:" followed by one path, `git check-ignore -q` on that path exits 0, and no output line contains the literal "Bundle content differs from repo for:"; the artifact records `KL-510: STATE-ONLY`, quotes the message, and carries `ExpectedExitCode: 1`. Any other outcome fails the task. P2-T5 remains the direct identity proof.
- [x] [P2-T5] Mirror byte-identity for AC-6 over the three source and mirror pairs, and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: the three `cmp` commands of P0-T5; `git status --porcelain --untracked-files=all -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees`.
      Acceptance: each `cmp` exits 0 and prints nothing. Before the orchestrator commits, the status lists exactly the three canonical scripts and the three mirrors as modified and nothing else; after a commit it prints nothing.
- [x] [P2-T6] Line limits for the 500-line cap over CHANGED-SH and the edited suite (`.claude/skills/cleanup-merged-worktrees/scripts/`, `tests/shell/`), and record FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh tests/shell/test_cleanup_worktrees_scan_roots.bats`.
      Acceptance: exit 0; every per-file count is at most 500; the enumeration library count equals BASE_LINES_ENUM plus 2, the scan helper count equals BASE_LINES_HELPER plus 2, and the detached library count equals BASE_LINES_DETACHED. The artifact reports the bats count against BASE_LINES_BATS (informational).
- [x] [P2-T7] Structural checks for AC-1 through AC-5 over the edited files, and record FEATURE/evidence/qa-gates/structural-checks.TS.md.
      Commands, run in this order: (1) `grep -c -F 'cleanup_wt_is_absolute_path "$parent"' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; (2) `grep -n -F -e 'cleanup_wt_is_absolute_path "$parent"' -e '[[ -z $parent || $parent == "$p" ]] && continue' -e 'n=$(normalize_wt_path "$parent")' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`; (3) `grep -n -F -e 'benign result' -e 'shellcheck source=' -e 'shellcheck disable=SC1091' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; (4) `grep -c -F "enumerate_lib.sh:115" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; (5) `grep -c -F "emit_record, nested in parse_worktree_list" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`; (6) `grep -c "^@test " tests/shell/test_cleanup_worktrees_scan_roots.bats`; (7) `grep -c -F "drops a drive-relative parent for a registration directly under another drive root" tests/shell/test_cleanup_worktrees_scan_roots.bats`; (8) `grep -c -F "does not emit a drive-relative root for a D:/wt registration" tests/shell/test_cleanup_worktrees_scan_roots.bats`; (9) `grep -c -F "converts a backslash registration path before taking its parent" tests/shell/test_cleanup_worktrees_scan_roots.bats`; (10) `grep -c -F "emits forward-slash roots for backslash registrations" tests/shell/test_cleanup_worktrees_scan_roots.bats`; (11) `grep -c -P "\r" tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`; (12) `grep -c -P "\r" tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`.
      Acceptance: (1) prints 1; (2) prints three lines: the guard line at line number G, the new code line at G+2, and the `n=` line at G+3; (3) prints `44:`, `45:`, and `46:` lines for the reason, source, and disable directives respectively; (4) prints 0 and exits 1; (5) prints 1; (6) prints 21; (7) through (10) each print 1; (11) and (12) each print 0 and exit 1. Every grep uses plain `grep` and none uses `git grep`, so the untracked fixtures and tests are searched. The artifact's top-level `EXIT_CODE:` is the last grep's exit code (1), with `ExpectedExitCode: 1`.
- [x] [P2-T8] Scope check against the Write list (`.claude/skills`, `extensions`, `tests`, `scripts`, `.github`), and record FEATURE/evidence/qa-gates/scope.TS.md.
      Commands: `git diff --name-only MERGE_BASE -- .claude/skills extensions tests scripts .github` (substitute the SHA recorded by P0-T3); `git status --porcelain --untracked-files=all -- .claude/skills extensions tests scripts .github` (`--untracked-files=all` lists the new fixture files themselves rather than collapsed directories). The pathspec leaves out `.claude/agent-memory`, which other agents may write during the run.
      Acceptance: the union of the paths listed by the two commands equals exactly the 9 repository paths in the Write list that sit under those pathspecs (the three canonical scripts, the three mirrors, the bats suite, and the two fixtures), and each of the 9 appears. No other path appears.
- [x] [P2-T9] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-1 (M-3) in `## Acceptance Criteria`, changing only `- [ ]` to `- [x]` on the AC-1 line, and record FEATURE/evidence/other/ac-checkoff-ac-1.TS.md. Evidence required before the edit: P1-T7 (T1 fails before), P1-T14 and P2-T3 (T1 `ok`), and P2-T7 checks (1) and (2). After the edit the line begins with the literal "- [x] AC-1 (M-3):".
      Commands: `grep -c -F "[x] AC-1 (M-3)" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 1, and 6.
- [x] [P2-T10] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-2 (N-1), changing only `- [ ]` to `- [x]` on the AC-2 line, and record FEATURE/evidence/other/ac-checkoff-ac-2.TS.md. Evidence required before the edit: P1-T14 and P2-T3 (T4 and T5 `ok`), and P2-T7 checks (9) and (10). After the edit the line begins with the literal "- [x] AC-2 (N-1):".
      Commands: `grep -c -F "[x] AC-2 (N-1)" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 2, and 5.
- [x] [P2-T11] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-3, changing only `- [ ]` to `- [x]` on the AC-3 line, and record FEATURE/evidence/other/ac-checkoff-ac-3.TS.md. Evidence required before the edit: P1-T7 (T2 fails before), P1-T14 and P2-T3 (T2 `ok`, asserting no output line equals `D:`), and P2-T7 check (8). After the edit the line begins with the literal "- [x] AC-3:".
      Commands: `grep -c -F "[x] AC-3:" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 3, and 4.
- [x] [P2-T12] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-4 (M-2), changing only `- [ ]` to `- [x]` on the AC-4 line, and record FEATURE/evidence/other/ac-checkoff-ac-4.TS.md. Evidence required before the edit: P1-T9, P2-T1, P2-T2, and P2-T7 check (3). After the edit the line begins with the literal "- [x] AC-4 (M-2):".
      Commands: `grep -c -F "[x] AC-4 (M-2)" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 4, and 3.
- [x] [P2-T13] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-5 (M-1), changing only `- [ ]` to `- [x]` on the AC-5 line, and record FEATURE/evidence/other/ac-checkoff-ac-5.TS.md. Evidence required before the edit: P1-T10 and P2-T7 checks (4) and (5). After the edit the line begins with the literal "- [x] AC-5 (M-1):".
      Commands: `grep -c -F "[x] AC-5 (M-1)" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 5, and 2.
- [x] [P2-T14] Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-6, changing only `- [ ]` to `- [x]` on the AC-6 line, and record FEATURE/evidence/other/ac-checkoff-ac-6.TS.md. Evidence required before the edit: P1-T11 through P1-T13, P2-T4, and P2-T5. After the edit the line begins with the literal "- [x] AC-6:".
      Commands: `grep -c -F "[x] AC-6:" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 6, and 1. AC-7 remains unchecked because it is CI-dependent (see `.claude/skills/acceptance-criteria-tracking/SKILL.md`, section "CI-Dependent Criteria"); it is checked off by P2-T18.
- [x] [P2-T15] Update `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md` so its checklist state matches the evidence on disk: change `- [ ]` to `- [x]` for each of P0-T1 through P2-T14 whose artifact exists with every required field, and for no other task. Record FEATURE/evidence/other/plan-checklist-state.TS.md.
      Commands: `grep -c "^- \[x\] \[P" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md`; `grep -c "^- \[ \] \[P" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md`.
      Acceptance: the first grep prints 39 (P0-T1 through P2-T14); the second prints 4 (this task, P2-T16, P2-T17, and P2-T18). Any mismatch means an artifact is missing or incomplete for an unchecked task, and that task is named in the artifact.
- [x] [P2-T16] Reduced-audit handoff: record FEATURE/evidence/other/small-audit-handoff.TS.md listing AC-1 through AC-7, each with the artifact paths that evidence it per the traceability table below, and stating that AC-7 is pending CI until P2-T17 and P2-T18 run. The orchestrator then delegates the minor-audit review with that file as its evidence index.
      Command: `ls docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/evidence/baseline docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/evidence/regression-testing docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/evidence/qa-gates docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/evidence/other`.
      Acceptance: every artifact path named in the handoff file appears in the listing.
- [ ] [P2-T17] Post-push coverage (executed by the later execution run after the orchestrator has committed and pushed and the pull request exists; the numeric value is required): record FEATURE/evidence/qa-gates/shell-coverage-pr-run.TS.md from the pull request's `ci.yml` run, whose `Shell Coverage (Bats + kcov)` job runs `.github/workflows/_shell-coverage.yml`. kcov line coverage is CI-authoritative; no local run substitutes for it.
      Commands: `git rev-parse HEAD`; `git rev-parse origin/bug/cleanup-worktrees-scan-root-derivation-follow-ups-842`; `gh run list --workflow ci.yml --branch bug/cleanup-worktrees-scan-root-derivation-follow-ups-842 --event pull_request --limit 10 --json databaseId,headSha,status,conclusion,createdAt`, repeated until the newest entry whose headSha equals the recorded PUSHED_SHA has status `completed` (record its databaseId as FINAL_RUN_ID); `gh run view FINAL_RUN_ID --json jobs --jq '.jobs[] | select(.name | contains("Shell Coverage")) | .conclusion'`; `gh run view FINAL_RUN_ID --json jobs --jq '.jobs[] | select(.name | contains("Shell Coverage")) | .databaseId'` (FINAL_JOB_ID); `gh run view FINAL_RUN_ID --log --job FINAL_JOB_ID | grep -F "coverage (lines)"`; `gh run view FINAL_RUN_ID --log --job FINAL_JOB_ID | grep -c "not ok"`; `gh run download FINAL_RUN_ID -n shell-coverage -D SCRATCH/ci-final`; `grep -n -F 'filename=".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"' SCRATCH/ci-final/cov.xml`; `grep -n -F 'cleanup_wt_is_absolute_path "$parent"' .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (the line number printed is CHANGED_LINE; planning-time prediction 352); `awk -v file='.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh' -v n=CHANGED_LINE '/<class /{inside=(index($0,"filename=\"" file "\"")>0)} /<\/class>/{inside=0} inside && index($0,"<line number=\"" n "\"")>0{print}' SCRATCH/ci-final/cov.xml` (substitute the recorded CHANGED_LINE value for CHANGED_LINE).
      Acceptance: the two `git rev-parse` values are equal and are recorded as PUSHED_SHA; the Shell Coverage job prints `success`; the log line `Bash coverage (lines): NN.N%` is recorded with its number as FINAL_AGGREGATE and is at least 85.0; the `not ok` count is 0 (grep prints 0 and exits 1, the pass condition here); the `<class>` element for `cleanup_worktrees_enumerate_lib.sh` carries `line-rate="0.NNN"`, recorded as FINAL_ENUM_RATE, and FINAL_ENUM_RATE is at least 0.850 and at least BASELINE_ENUM_RATE (no regression of the changed library); the awk command prints one `<line number="CHANGED_LINE" hits="K" .../>` element and K is at least 1 (the changed line is executed by the new tests). The artifact records BASELINE_AGGREGATE, FINAL_AGGREGATE, their difference, BASELINE_ENUM_RATE, FINAL_ENUM_RATE, and K, all as numbers. The line rates of `cleanup_worktrees_scan_helper.sh` and `cleanup_worktrees_detached_lib.sh` are recorded for information (their edits are comments only). Remediation-required, not PASS, applies when any of these numbers is missing or unobtainable (no run for PUSHED_SHA, expired artifact, absent log line, absent `<class>` element, or no `<line>` element for CHANGED_LINE) and when any threshold above fails: the artifact then records `REMEDIATION-REQUIRED` with the failing command and its output, and P2-T18 is not executed.
- [ ] [P2-T18] Post-push (executed by the later execution run, only after P2-T17 passes): Edit `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` to check off AC-7, changing only `- [ ]` to `- [x]` on the AC-7 line, and record FEATURE/evidence/other/ac-checkoff-ac-7.TS.md. Evidence required before the edit: P2-T1 (shfmt clean), P2-T2 (shellcheck clean), P2-T3 (local bats), and P2-T17 (CI bats with 0 `not ok` and numeric coverage with no regression). After the edit the line begins with the literal "- [x] AC-7:".
      Commands: `grep -c -F "[x] AC-7:" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[x] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md`.
      Acceptance: the three greps print 1, 7, and 0 (the last exits 1, the pass condition here). The artifact's top-level `EXIT_CODE:` is 1 with `ExpectedExitCode: 1`.

## Acceptance-criteria traceability

| AC | Criterion (abridged) | Implementation | Tests | Evidence |
| --- | --- | --- | --- | --- |
| AC-1 | Derived parents pass through `cleanup_wt_is_absolute_path`; `D:/wt` emits no `D:` root; named bats test | P1-T2, P1-T8 | `tests/shell/test_cleanup_worktrees_scan_roots.bats` T1 `cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root`, plus T3 | regression-testing/expect-fail-scan-root-derivation, regression-testing/pass-after-scan-root-derivation, qa-gates/bats-targeted, qa-gates/structural-checks |
| AC-2 | A bats test drives a backslash registration (`C:\repo\main-wt\a`) and asserts the forward-slash parent | P1-T3, P1-T6 | T4 `cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent`, T5 `cleanup_wt_scan_roots emits forward-slash roots for backslash registrations` | regression-testing/pass-after-scan-root-derivation, qa-gates/bats-targeted, qa-gates/structural-checks |
| AC-3 | A bats test covers `D:/wt` and asserts the drive-relative root is absent | P1-T2, P1-T5, P1-T8 | T2 `cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration` | regression-testing/expect-fail-scan-root-derivation, regression-testing/pass-after-scan-root-derivation, qa-gates/bats-targeted |
| AC-4 | SC1091 suppression in the scan helper carries an inline reason | P1-T9 | shellcheck (P2-T2) and `tests/shell/test_cleanup_worktrees_scan_helper.bats` (3 tests) | other/p1-t9, qa-gates/shellcheck, qa-gates/structural-checks |
| AC-5 | Detached-library comment names `emit_record` in `parse_worktree_list` instead of a line range | P1-T10 | `tests/shell/test_cleanup_worktrees_detached.bats` (comment-only change; structural greps) | other/p1-t10, qa-gates/structural-checks |
| AC-6 | Each changed script's mirror byte-identical; mirror and bundle-parity checks pass | P1-T11 through P1-T13 | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; `cmp` pairs | qa-gates/mirror-identity, qa-gates/bundle-parity-pytest |
| AC-7 | shfmt and shellcheck clean on changed scripts; bats suites pass (CI authoritative); changed-library coverage not regressed | P1-T8 through P1-T10 | P2-T1, P2-T2, P2-T3, P2-T17 | qa-gates/shfmt, qa-gates/shellcheck, qa-gates/bats-targeted, qa-gates/shell-coverage-pr-run, baseline/shell-coverage-main |

## Appendix A — exact fixture and test text

Fixture F1, file `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out` (12 lines, the last line blank, LF endings):

```text
worktree C:/repo/main
HEAD aaaa0000
branch refs/heads/main

worktree D:/wt
HEAD aaaa0001
branch refs/heads/wt-d

worktree D:/other/x
HEAD aaaa0002
branch refs/heads/wt-x

```

Fixture F2, file `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out` (12 lines, the last line blank, LF endings; the two non-main paths contain literal backslash bytes):

```text
worktree C:/repo/main
HEAD aaaa0000
branch refs/heads/main

worktree C:\repo\main-wt\a
HEAD aaaa0001
branch refs/heads/wt-a

worktree C:\scratch\plan\p1
HEAD aaaa0002
branch refs/heads/p1

```

Expected results, derived by tracing `cleanup_wt_derive_scan_roots` on each fixture. F1 before the fix: derived parents `D:` and `D:/other` (output 2 lines, `D:` first by `LC_ALL=C` order of the normalized keys `d:` and `d:/other`); after the fix: `D:/other` only. F2 before and after the fix: `C:/repo/main-wt` then `C:/scratch/plan`. Default pair for both fixtures: `C:/repo/main/.claude/worktrees` then `C:/repo/main-wt`; `cleanup_wt_scan_roots` deduplicates `C:/repo/main-wt` by normalized value.

Helper H1, placed after the existing `report_run` helper (4-space indentation, as in the rest of the file):

```bash
derive_run() { # derive_run <scenario> -> cleanup_wt_derive_scan_roots over parse_worktree_list output, stderr discarded
    # Derivation reads only the git stub's worktree list. The brace group sends the stub's
    # argv log (stderr) to /dev/null so $output is the emitted roots only.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && { cleanup_wt_derive_scan_roots \"\$(parse_worktree_list)\"; } 2>/dev/null"
}
```

Test T1 (expect-fail before P1-T8):

```bash
@test "cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root" {
    # AC-1 (M-3): D:/wt has the drive-relative parent D:, which is not absolute and is
    # dropped; D:/other/x still contributes D:/other.
    derive_run scan_roots_drive_relative
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "D:/other" ]
}
```

Test T2 (expect-fail before P1-T8):

```bash
@test "cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration" {
    # AC-3 (M-3): the combined root list keeps the default pair and D:/other and never
    # contains the bare drive D:.
    roots_run scan_roots_drive_relative ""
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
    [ "${lines[0]}" = "C:/repo/main/.claude/worktrees" ]
    [ "${lines[1]}" = "C:/repo/main-wt" ]
    [ "${lines[2]}" = "D:/other" ]
    local line
    for line in "${lines[@]}"; do
        if [ "$line" = "D:" ]; then
            echo "drive-relative root emitted: ${line}"
            return 1
        fi
    done
}
```

Test T3 (expect-fail before P1-T8):

```bash
@test "run_report passes no drive-relative root to its single filesystem scan" {
    # AC-1 (M-3): run_report still performs exactly one scan, and its argv carries no D:.
    report_run scan_roots_drive_relative
    # grep -c exits 1 on a zero count; neutralize it so each assertion reports the count.
    scan_calls=$(printf '%s\n' "$output" | grep -c 'stub-scan: scan-dirs' || true)
    [ "$scan_calls" -eq 1 ]
    argv_lines=$(printf '%s\n' "$output" | grep -cxF "stub-scan: scan-dirs C:/repo/main/.claude/worktrees C:/repo/main-wt D:/other" || true)
    [ "$argv_lines" -eq 1 ]
}
```

Test T4 (passes before and after the fix):

```bash
@test "cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent" {
    # AC-2 (N-1): C:\repo\main-wt\a and C:\scratch\plan\p1 are converted to / before the
    # parent is taken, so the emitted parents use forward slashes.
    derive_run scan_roots_backslash
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "C:/repo/main-wt" ]
    [ "${lines[1]}" = "C:/scratch/plan" ]
}
```

Test T5 (passes before and after the fix):

```bash
@test "cleanup_wt_scan_roots emits forward-slash roots for backslash registrations" {
    # AC-2 (N-1): the combined root list is three forward-slash roots; C:/repo/main-wt
    # from the derivation duplicates the default and is emitted once.
    roots_run scan_roots_backslash ""
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
    [ "${lines[0]}" = "C:/repo/main/.claude/worktrees" ]
    [ "${lines[1]}" = "C:/repo/main-wt" ]
    [ "${lines[2]}" = "C:/scratch/plan" ]
    local line
    for line in "${lines[@]}"; do
        if [[ $line == *\\* ]]; then
            echo "backslash in emitted root: ${line}"
            return 1
        fi
    done
}
```

## Appendix B — exact production-script edits

Edit E1, in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`, inserted between the guard line and the `n=` line, each line indented with two tabs:

```text
		# A drive-relative parent (a registration directly under a drive root, such as D:/wt) is not an absolute root and is dropped.
		cleanup_wt_is_absolute_path "$parent" || continue
```

Edit E2, in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`, inserted after `set -euo pipefail` and before the `# shellcheck source=` line, no indentation:

```text
# The library path is computed at runtime from BASH_SOURCE, so shellcheck (run without
# -x) cannot follow it; SC1091 is the expected, benign result.
```

Edit E3, in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`, replacement for line 46 (one tab of indentation; the original line is the comment line that begins with the parenthesized path ending in `enumerate_lib.sh:115-116)` followed by `, which is also true of a`):

```text
	# (emit_record, nested in parse_worktree_list in cleanup_worktrees_enumerate_lib.sh), which is also true of a
```

## Write list (every repository file this plan writes)

Canonical production scripts (3):

1. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (P1-T8)
2. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` (P1-T9)
3. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` (P1-T10)

Bundle mirrors (3):

4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (P1-T11)
5. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` (P1-T12)
6. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` (P1-T13)

Tests and fixtures (3):

7. `tests/shell/test_cleanup_worktrees_scan_roots.bats` (P1-T4, P1-T5, P1-T6)
8. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out` (P1-T2, new)
9. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out` (P1-T3, new)

Feature documents (outside the P2-T8 pathspec):

10. `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md` (P2-T9 through P2-T14 and P2-T18, AC check-off only)
11. `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md` (P2-T15, checklist state only)

Evidence artifacts are written under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/ and are not listed individually.
