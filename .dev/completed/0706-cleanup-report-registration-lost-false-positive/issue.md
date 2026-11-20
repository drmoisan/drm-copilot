# cleanup-report-registration-lost-false-positive (Issue #706)

- Date captured: 2026-09-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-report-registration-lost-false-positive-706/ (Issue #706)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #706
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/706
- Last Updated: 2026-09-26
- Work Mode: full-bug

Note: the GitHub issue body carries `Work Mode: minor-audit`. This active folder was created under the preparation-mode delegation with work mode `full-bug`, which is the selected mode persisted above.

## Summary

`scripts/bash/cleanup-worktrees.sh` report mode emits `WARN|registration-lost|<path>` for healthy, fully registered worktrees. On 2026-09-25 it flagged 67 of 71 worktrees, which buries any genuine half-removed registration.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Git Bash
- Python version: n/a (bash)
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh` (report mode, no flags)
- Data source or fixture: the drm-copilot main checkout with 71 registered worktrees

## Steps to Reproduce

1. On Windows, register worktrees under `drm-copilot-wt/` and `.claude/worktrees/`.
2. Run `bash scripts/bash/cleanup-worktrees.sh`.
3. Observe `WARN|registration-lost|<path>` for worktrees that `git worktree list` shows as valid.

## Expected Behavior

`WARN|registration-lost` is emitted only when a worktree's `.git` pointer names a `gitdir:` target that does not exist.

## Actual Behavior

The warning is emitted for healthy worktrees. Verified by hand on `drm-copilot-wt/no-target-followup`:

- its `.git` pointer is LF-terminated (`od -c` shows `\n`, no `\r`);
- the target `.git/worktrees/no-target-followup` exists;
- `git -C <worktree> rev-parse --git-dir` resolves it.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `WARN|registration-lost|C:/Users/DanMoisan/repos/drm-copilot-wt/no-target-followup` (one of 67 such lines).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

The record is advisory and read-only, so nothing is deleted on its basis. The cost is that the report's signal for a genuinely half-removed registration is lost in false positives.

## Acceptance Criteria

- [ ] AC-1: Report mode does not emit `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that exists, including when the target is written in a Windows drive-letter form.
- [ ] AC-2: Report mode still emits `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that does not exist.
- [ ] AC-3: The root cause of the false positive is identified and documented in `spec.md`, and a regression test reproduces the pre-fix false positive and passes after the fix.
- [ ] AC-4: The shell toolchain (format, lint, bats tests, coverage) passes for the changed files, with line coverage at or above 85% and no regression on changed lines.

## Source

From: docs/features/potential/2026-09-26-cleanup-report-registration-lost-false-positive.md (lifecycle record not present on this branch).
