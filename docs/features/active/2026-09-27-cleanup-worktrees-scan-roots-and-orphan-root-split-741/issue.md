# cleanup-worktrees-scan-roots-and-orphan-root-split (Issue #741)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-scan-roots-and-orphan-root-split/ (Issue #741)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #741
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/741
- Last Updated: 2026-09-27
- Work Mode: minor-audit

## Summary

After #706 fixed the Windows drive-letter false positive for `registration-lost`, two more defects remain in `scripts/bash/cleanup-worktrees.sh`: report mode scans a fixed pair of roots, and orphan-root parsing breaks on Windows drive letters.

## Environment

- OS/version: Windows (Git Bash)
- Python version: n/a (bash)
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh`; `CLEANUP_WT_ORPHAN_ROOTS`
- Data source or fixture: #706 final report (FU-706-1, FU-706-2 and FU-706-7)

## Steps to Reproduce

1. Report mode scans only `<main>-wt/` and `<main>/.claude/worktrees/`. Worktrees elsewhere, such as scratchpad plan homes and `drm-copilot-parallel-*-plan` directories, are not scanned. This is likely why 4 of 71 worktrees went unflagged on 2026-09-25 (unconfirmed).
2. `CLEANUP_WT_ORPHAN_ROOTS` is split on `:` (`cleanup_worktrees_report_records_lib.sh:129-136`), so `C:/...` roots are cut apart.
3. The `load_helper` wrapper is duplicated across three tests, and the drive-letter check duplicates `cleanup_worktrees_preserve_lib.sh:161`.

## Expected Behavior

Scan roots derive from every registered worktree's parent (`git worktree list`) plus the configured roots. The root list uses a Windows-safe separator.

## Actual Behavior

As above.

## Scope Decisions

Recorded 2026-09-29 during preparation, from `research/research.2026-09-29T22-35.md`:

- The scripts live under `.claude/skills/cleanup-merged-worktrees/scripts/` with a byte-identical bundle mirror under `extensions/drm-copilot/resources/claude-customizations/`; the `scripts/bash/` paths above are stale.
- Derived scan roots are the parent directories of non-main registered worktrees, excluding any candidate that equals or is an ancestor of the main worktree (including the repositories directory that holds the main checkout) and any candidate equal to or inside a registered worktree. Leftover directories that sit directly in the repositories directory remain undetected by derivation; operators add that directory through `CLEANUP_WT_ORPHAN_ROOTS` when needed.
- `CLEANUP_WT_ORPHAN_ROOTS`, when set, replaces the fixed default pair; registration-derived roots are always added.
- The separator contract splits on `;` and newline, then on `:` except where the `:` follows a single drive letter and precedes `/` or `\`, so existing `:`-separated lists keep working.
- Issue #756 scope (`classify_all_branches`, `run_report_scans`, `tests/shell/test_cleanup_worktrees_report_records.bats`) is excluded.

## Acceptance Criteria

- [x] AC-1: With `CLEANUP_WT_ORPHAN_ROOTS` unset, `cleanup_wt_scan_roots` emits `<main>/.claude/worktrees`, `<main>-wt`, and then the parent directory of every non-main registered worktree, deduplicated by `normalize_wt_path`, verified by a bats test against a `scan_roots_derived` scenario asserting exact ordered lines.
- [x] AC-2: A derived candidate root that equals the main worktree, is an ancestor of it (including the main worktree's parent directory), or is equal to or inside any registered worktree is not emitted; each exclusion class has a scenario entry asserted absent.
- [x] AC-3: When `parse_worktree_list` hard-fails and no override is set, no root is emitted, and the existing test at `tests/shell/test_cleanup_worktrees_report_records.bats` covering that case passes unchanged.
- [x] AC-4: When the override is set and `parse_worktree_list` hard-fails, exactly the override roots are emitted.
- [x] AC-5: `CLEANUP_WT_ORPHAN_ROOTS` is parsed per the separator contract above; bats cases cover `/a/one:/b/two`, `C:/a/one`, `C:/a/one:D:\b\two`, `C:/a/one;D:/b/two`, newline separation, empty segments, a glob character kept literally, and a relative segment dropped with a stderr diagnostic; the existing override test passes unchanged.
- [x] AC-6: A full `run_report` under the scan stub performs exactly one `scan-dirs` invocation, and its argv includes a registration-derived root.
- [x] AC-7: Exactly one bash definition of the drive-letter absolute-path predicate (`cleanup_wt_is_absolute_path`) exists under `.claude/skills/cleanup-merged-worktrees/scripts/`; `preserve_relative_path_reason` and the scan helper call it; `scan_helper_is_absolute_path` no longer exists; the #706 predicate cases pass against the shared function, and a drive-letter `source_path` is rejected as absolute by the preserve validator.
- [x] AC-8: The inline `load_helper` definition is removed from the three test bodies in `tests/shell/test_cleanup_worktrees_scan_helper.bats`; the source-then-`set +u` idiom appears in exactly one file-local helper with its kcov rationale stated once.
- [x] AC-9: Each changed canonical file is byte-identical to its bundle mirror, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [x] AC-10: The wrapper usage text for `CLEANUP_WT_ORPHAN_ROOTS` and the `SKILL.md` `ORPHAN_DIR` bullet state the separator contract, the override-replaces-default-pair rule, and the always-added derived roots with their exclusions.
- [x] AC-11: Every changed shell or bats file is at or below 500 lines; `shfmt -d` and `shellcheck` report no finding on changed files; the bats suite passes in the `_shell-coverage.yml` CI run on the branch head, with kcov line coverage at or above 85% for each changed production file.
- [x] AC-12: `classify_all_branches` and `run_report_scans` are byte-unchanged, and `tests/shell/test_cleanup_worktrees_report_records.bats` is unmodified, preserving the #756 boundary.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #706 FU-706-1, FU-706-2 and FU-706-7.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Roots were hard-coded for the common layout.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: derive the scan roots from the registrations; accept a `;`- or newline-separated `CLEANUP_WT_ORPHAN_ROOTS`, or split with drive letters in mind; add bats cases for `C:/` roots; deduplicate the helpers.
- [ ] Integration scenario to retest: report mode on a Windows checkout finds worktrees in non-standard directories.
- [ ] Manual verification notes: mind the kcov `set -u` + `bash -c` trap (memory note kcov-bash-c-source-set-u).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
