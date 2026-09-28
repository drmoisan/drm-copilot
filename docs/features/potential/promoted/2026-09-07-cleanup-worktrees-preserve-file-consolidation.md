# cleanup-worktrees-preserve-file-consolidation (Issue #637)

- Date captured: 2026-09-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-preserve-file-consolidation/ (Issue #637)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #637
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/637
- Last Updated: 2026-09-07
## Summary

The `cleanup-merged-worktrees` consolidation step can only carry committed residual content. It has no
mechanism to stage untracked or modified working-tree files that the editorial pass marked `PRESERVE`, so
the content that actually needed preserving during the 2026-09-06 run had to be consolidated by hand.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, with the bash toolchain under WSL Ubuntu
- Python version: not applicable; the affected surface is native bash (`scripts/bash/cleanup_worktrees_actions_lib.sh`)
- Command/flags used: `/cleanup-merged-worktrees` report mode, then `--consolidate`
- Data source or fixture: 20 live agent worktrees under `.claude/worktrees/`

## Steps to Reproduce

1. Run `/cleanup-merged-worktrees` in report mode across a set of worktrees whose only unique content is
   never-committed: untracked `.claude/agent-memory/**` lesson files and modified feature-folder drafts.
2. Observe that report mode emits `COMMIT|<worktree>|UNIQUE|<sha>` records only for committed residuals,
   and emits nothing for untracked or modified working-tree files.
3. Run the consolidation step (`--consolidate`), which cherry-picks the reported commits with `git cherry-pick -x`.

## Expected Behavior

The consolidation step stages the untracked and modified files that the editorial pass marked `PRESERVE`,
carrying each new lesson file's `MEMORY.md` index line, normalizing line endings to the target file's
existing convention, and refusing to commit any file still carrying account or host tokens. Each such file
is reported as a `PRESERVE|<worktree>|<path>|<verdict>` record.

## Actual Behavior

There were no committed residuals in the run, so `cherry_pick_candidates` had nothing to do and the
consolidation step completed without moving any content. Approximately 140 never-committed
`.claude/agent-memory/**` lesson files and feature-folder drafts sat untracked or modified across 20
worktrees and were invisible to the script. The consolidation was performed by hand: copy the files into a
manually created `documentationandmemories` worktree, append each file's `MEMORY.md` index line taken from
the source worktree, normalize the index files to CRLF (the consumer checkout is CRLF and appended LF lines
produce mixed endings), sanitize account and host tokens, commit, push.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: report mode emitted zero `COMMIT|` records for the run; the `--consolidate` pass exited without
  a cherry-pick because `cherry_pick_candidates` iterates only the `COMMIT|` record set.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The automated path silently does nothing in the case that matters most, and the manual substitute is
error-prone in three specific ways that were each observed in the 2026-09-06 run: a dropped `MEMORY.md`
index line leaves a lesson file unreachable from the index; an LF line appended to a CRLF index file
produces mixed endings; and an unsanitized account or host token reaches a pushed commit.

## Suspected Cause / Notes

- `scripts/bash/cleanup_worktrees_actions_lib.sh` — `cherry_pick_candidates` consumes only `COMMIT|`
  records and emits `COMMIT|` results; there is no untracked/modified staging path anywhere in the file.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## Report Line Contract` defines no `PRESERVE|`
  record type, so the editorial pass has nowhere to record a per-file preserve finding for the script to
  consume.
- `_shared_no_absolute_host_paths`, named in the run observations as the token pattern set to enforce, does
  not exist anywhere in this repository. A repository-wide search returns only the run-observations
  document that names it. The pattern set must be defined by this work, not reused.
- Issue #635 defines `artifacts/orchestration/cleanup-worktrees-manifest.json` with a `preserved_files[]`
  array that is the intended input for this work. Its `line_ending` field is marked ADVISORY and must be
  re-derived at consolidation time rather than trusted.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: a new bats suite driving a new consolidation library through the existing
      `CLEANUP_WT_GIT_BIN` stub seam against new checked-in fixture scenario directories.
- [x] Integration scenario to retest: a run whose only unique content is untracked, asserting that
      `PRESERVE|` records are emitted and the files are staged.
- [x] Manual verification notes: confirm the host-token refusal is a hard stop rather than a warning, and
      confirm that a stale advisory `line_ending` value does not determine the written convention.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
