# 2026-09-06-cleanup-worktrees-dirt-classifier (User Story)

- **Issue:** #632
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening` (child C)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-55
- **Status:** Draft
- **Version:** 0.1

## Why this document exists

The work mode for issue #632 is `full-bug`. Under the `acceptance-criteria-tracking` skill, the
acceptance-criteria source for `full-bug` is `spec.md` only, and `user-story.md` is normally absent.
It is required here for a separate reason: `scripts/dev_tools/epic_planner_readiness.py` iterates
`for name in ("issue.md", "spec.md", "user-story.md")` at line 187 and requires all three files in
every prepared epic child folder. An epic child folder without `user-story.md` fails epic execution
readiness regardless of work mode.

This document therefore exists to satisfy that readiness check and to record the operator-facing
value of the change. It is **not** an acceptance-criteria source. The authoritative and sole
acceptance-criteria source for this issue is
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`.

## Persona

The operator running `/cleanup-merged-worktrees` on a large checkout — a developer or agent
performing periodic worktree hygiene across a repository that accumulates many worktrees on
already-merged branches. The operator is not the author of most of the dirt they encounter: it is
left behind by tooling runs, restore steps, and prior sessions.

## Story

As the operator running `/cleanup-merged-worktrees` on a large checkout,
I want each dirty worktree's uncommitted content labelled with a deterministic verdict in report
mode, and an explicit opt-in way to clear the dirt that is provably disposable,
so that I can complete a cleanup run without inspecting every changed file by hand, and without
risking content that exists only in that worktree.

## Value and motivation

On the 2026-09-06 run, 14 worktrees on already-merged branches were reported `BLOCKED-DIRTY` with no
verdict. The report told the operator that removal was blocked and nothing else. In every one of
those cases the dirt turned out to be one of a small number of recognisable, disposable classes:

- `*.csproj`, `packages.config`, and `app.config` analyzer-`HintPath` rewrites left by
  `nuget restore`;
- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`;
- `artifacts/orchestration/orchestrator-state.json`;
- untracked files whose exact content already matched `main`'s current blob at the same path or
  already existed somewhere in `main`'s history;
- one worktree whose staged changes were exactly an earlier commit's tree.

Because the report carried no verdict, the operator had to open and diff those files
worktree-by-worktree and file-by-file. That manual triage is precisely the work the skill exists to
automate, and its cost scales with the number of worktrees rather than with the amount of genuinely
unique work.

The value of this change is that the same run produces a decision the operator can act on directly:
a per-file `DIRTFILE|` verdict and a per-worktree `DIRTSUM|` aggregate. A worktree whose aggregate is
`ALL_DISPOSABLE` needs no editorial judgement at all. A worktree carrying even one `UNIQUE` verdict
is still blocked, and the operator's attention goes only to the entries that actually warrant it.

## Operator-visible behavior

1. **Report mode, unchanged invocation.** For every dirty worktree the report now carries one
   `DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>` record per
   `git status --porcelain` entry, followed by one
   `DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>` record. A clean worktree produces
   neither record, so a report over a checkout with no dirt is unchanged.
2. **The six verdicts** are `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`,
   `CONTENT_ON_MAIN`, `CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT` (with the commit SHA in the
   detail field), and `UNIQUE`. Anything the classifier cannot positively place — including any
   entry whose classification read fails — is `UNIQUE`.
3. **Report mode still changes nothing.** It issues only read-only git plumbing. It does not write
   objects, does not redirect or rewrite an index, and does not remove anything.
4. **Apply mode is unchanged by default.** Without the new flag, the output and the actions taken
   are exactly what they were before, including the existing three-field `DIRTY|` record and the
   `ACTION|worktree-remove|<path>|BLOCKED-DIRTY` record.
5. **`--clear-disposable` is opt-in and apply-mode-only.** For a worktree whose every verdict is
   non-`UNIQUE`, it runs `git reset --hard` and `git clean -fd` in that worktree, re-verifies
   delete-eligibility, and then retries the same non-forced `git worktree remove`. Supplying the
   flag without `--apply` is a usage error, not a silent no-op.
6. **`UNIQUE` dirt still blocks.** A single `UNIQUE` verdict refuses the clear for the whole
   worktree and the operator falls back to the existing Dirty Worktree Triage Procedure — now
   starting from the classifier's records rather than from raw status lines.

## Safety expectations the operator can rely on

- Clearing never happens without the explicit flag, and the flag has no configuration default.
- Clearing never removes ignored files. Ignored files do not appear in `git status --porcelain`, are
  therefore never classified, and clearing something unclassified is exactly what the design
  forbids: `git clean` is never given `-x`, `-X`, or `-ff`.
- No force flag ever reaches `git worktree remove`. Clearing first and then retrying the unforced
  removal is not force-removal, and the removal still fails on any worktree git still considers
  dirty. The skill's **Prohibited Shortcuts** section is amended to state this explicitly so the
  distinction is auditable rather than inferred.
- The definition of "disposable" is narrow and not user-extensible. The session-artifact path list
  is a fixed in-script array matched on exact repo-relative paths, and the build-artifact rule
  requires both the project-file path pattern and a content check confining the changed lines to
  analyzer `HintPath` rewrites. A hand edit to a project file is reported `UNIQUE`.
- Every failure mode fails closed toward `UNIQUE`, which blocks clearing. A transient git failure
  costs the operator a manual triage, never a deleted file.

## Scope boundary for this story

This story covers dirt classification and the opt-in clearing path only. It does not cover
detached-worktree classification or consolidation-branch ordering (epic child A, issue #630), the
orphan / stale-ref / `CHILD_OF` / `registration-lost` report records (child B), the removal manifest
(child D), or `PRESERVE` consolidation (child F). Delivery is in `drm-copilot` only; consumer
checkouts receive the change through the normal bundle push-down rather than through a patched copy.

One environment note the operator should expect: `/artifacts` is gitignored in `drm-copilot`
(`.gitignore:6`), so `DISPOSABLE_SESSION_ARTIFACT` will not appear when running against a
`drm-copilot` worktree. The verdict targets consumer checkouts, such as the one that produced the
2026-09-06 observations, where those paths are tracked or not ignored.

## Acceptance criteria

None in this document. Acceptance criteria for issue #632 live in
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`, which is the sole
acceptance-criteria source for `full-bug` work mode. Do not add checkbox criteria here; doing so
would create a second, unauthoritative source.
