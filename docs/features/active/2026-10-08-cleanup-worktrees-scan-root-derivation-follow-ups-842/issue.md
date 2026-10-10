# cleanup-worktrees-scan-root-derivation-follow-ups (Issue #842)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-scan-root-derivation-follow-ups/ (Issue #842)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #842
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/842
- Last Updated: 2026-10-08
- Work Mode: minor-audit

## Summary

The registration-derived scan roots added by #741 (PR #819, merge `ef80c57d`) do not pass derived candidates through the shared absolute-path predicate, so a worktree registered directly under a drive root (`D:/wt`) yields the drive-relative root `D:` (M-3). The same review recorded three smaller gaps: no test drives a backslash-form registration path through the derivation (N-1), a new `# shellcheck disable=SC1091` has no inline reason (M-2), and a cross-file line reference is stale (M-1).

## Environment

- OS/version: Windows 11 Pro (Git for Windows); the derivation also runs under Linux CI
- Python version: n/a (bash)
- Command/flags used: `cleanup-worktrees.sh` report mode (`run_report` -> `cleanup_wt_scan_roots` -> `cleanup_wt_derive_scan_roots`)
- Data source or fixture: #741 review artifacts on main fb413fce: `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/code-review.2026-10-02T04-30.md` lines 27-42 and `policy-audit.2026-10-02T04-30.md` lines 312-314 and 420; PR #819 body, Follow-ups section

## Steps to Reproduce

1. M-3: supply `parse_worktree_list` output whose main worktree is on `C:` and whose second record is `D:/wt` to `cleanup_wt_derive_scan_roots`; observe the emitted roots.
2. N-1: search the derivation tests and fixtures for a backslash registration path: `git grep -n -F 'C:\' -- 'tests/fixtures/cleanup_worktrees/**/worktree-list.out'` returns no match (exit 1); `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out` contains only `/`-separated paths.
3. M-2: read `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` lines 43-45.
4. M-1: read `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` line 46 and compare with `cleanup_worktrees_enumerate_lib.sh` lines 115-119.

## Expected Behavior

- M-3: derived candidates satisfy the same "no relative root" invariant as override entries; a drive-relative candidate such as `D:` is dropped (or the drive root is emitted as `D:/`).
- N-1: at least one test drives a backslash-form registration path (`C:\x\y`) through the `${paths[i]//\\//}` conversion and asserts the emitted parent.
- M-2: every SC1091 suppression states its reason inline, as `.claude/rules/shell.md` lines 85-86 require and as `cleanup-worktrees.sh:11-12` does.
- M-1: the comment points to the current lines, or names the function instead of a line range.

## Actual Behavior

- M-3: `cleanup_worktrees_enumerate_lib.sh:348-353` computes `p=${paths[i]//\\//}` and `parent=${p%/*}`, then applies only empty, seen, main-ancestor and inside-a-worktree checks. For `D:/wt`, `parent` is `D:`, which `cleanup_wt_is_absolute_path` (lines 257-271, `[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]`) would classify as not absolute, but that predicate is not called in the derivation. It is called only for override entries (line 310), the preserve library (`cleanup_worktrees_preserve_lib.sh:161`), and the scan helper (`cleanup_worktrees_scan_helper.sh:105`). Verified by reading the code and `git grep -n cleanup_wt_is_absolute_path` on main fb413fce; not executed.
- N-1: no backslash path exists in the derivation fixture (step 2). The only backslash cases in `tests/shell/test_cleanup_worktrees_scan_roots.bats` exercise the override splitter (line 122) and the predicate (line 198), not the derivation.
- M-2: `cleanup_worktrees_scan_helper.sh:44` is a bare `# shellcheck disable=SC1091`; line 43 is the `# shellcheck source=` directive and no reason is stated.
- M-1: `cleanup_worktrees_detached_lib.sh:46` cites `cleanup_worktrees_enumerate_lib.sh:115-116` for the `DETACHED` branch-field write; on main those lines are `local flags=""` and `local IFS=,`. The write is at lines 118-119 (`local branch_field="DETACHED"` / `[[ -n $branch ]] && branch_field=$branch`). The bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` carries the same comment.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `policy-audit.2026-10-02T04-30.md:313`: "A registered worktree located directly under a drive root on a drive other than the main worktree's (for example `D:/wt`) would produce the drive-relative candidate `D:`. The record is advisory and read-only, and git porcelain paths are absolute, so the impact is limited to an extra scan root."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Report mode is advisory and read-only. M-3 can add a drive-relative scan root, which resolves against the process's current directory on that drive. N-1 leaves the Windows path form that motivated #741 untested in the derivation. M-1 and M-2 are documentation and lint-hygiene items.

## Suspected Cause / Notes

- Recorded as non-blocking in the #741 code review and policy audit, and listed as follow-ups in the PR #819 body; issue #741 is closed.
- The enumeration library header grew by three lines in commit `598691e7`, which moved the cited lines (M-1).
- Each script under `.claude/skills/cleanup-merged-worktrees/scripts/` has a bundle mirror under `extensions/drm-copilot/resources/claude-customizations/`; fixes must be applied to both to keep the mirror-identity check green.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add `cleanup_wt_is_absolute_path "$parent" || continue` before normalization in `cleanup_wt_derive_scan_roots`; add bats scenarios for a `D:/wt` registration and for a backslash registration such as `C:\repo\main-wt\a`, asserting the emitted parent.
- [ ] Integration scenario to retest: `run_report` with the new fixtures passes the expected roots to the single filesystem scan.
- [ ] Manual verification notes: add a one-line reason to the SC1091 suppression; replace the line range in `cleanup_worktrees_detached_lib.sh:46` with the function name (`emit_record` in `parse_worktree_list`); run `shellcheck`, `shfmt`, and the mirror-identity and bundle-parity checks.

## Acceptance Criteria

- [x] AC-1 (M-3): `cleanup_wt_derive_scan_roots` passes each derived parent candidate through `cleanup_wt_is_absolute_path` and drops a candidate that is not absolute; a registration at `D:/wt` with the main worktree on `C:` emits no `D:` root. Verified by a named bats test in `tests/shell/test_cleanup_worktrees_scan_roots.bats`.
- [x] AC-2 (N-1): At least one bats test drives a backslash-form registration path (for example `C:\repo\main-wt\a`) through the derivation and asserts the emitted forward-slash parent.
- [x] AC-3: A bats test covers the `D:/wt` drive-root registration case and asserts the drive-relative root is absent from the output.
- [x] AC-4 (M-2): The `# shellcheck disable=SC1091` in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` carries an inline reason, consistent with `.claude/rules/shell.md` and the pattern at `cleanup-worktrees.sh`.
- [x] AC-5 (M-1): The comment in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` that cites `cleanup_worktrees_enumerate_lib.sh` line numbers for the `DETACHED` branch-field write names the function (`emit_record` in `parse_worktree_list`) instead of a line range.
- [x] AC-6: Each changed script's bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/` is byte-identical to its source, and the repository mirror-identity and bundle-parity checks pass.
- [ ] AC-7: `shfmt` and `shellcheck` report no findings on the changed scripts, and the cleanup-worktrees bats suites pass (CI is authoritative for bats), with bash line coverage of the changed library not regressed.

### Assumptions

- AC-1 drops the non-absolute candidate (the proposed `cleanup_wt_is_absolute_path "$parent" || continue`) rather than emitting the drive root as `D:/`.
- Report mode is advisory and read-only, so no real-worktree cleanup command is run during verification.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
