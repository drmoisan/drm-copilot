# repo-housekeeping-audit

- Work Mode: minor-audit
- Issue: 340
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/340
- Status: Implementation already committed (commit `541efcd`, branch `drm-copilot-wt-2026-07-09T09-26`). This `issue.md` formalizes that already-completed work retroactively, through the standard small-path lifecycle, to satisfy the orchestration checkpoint's routing-contract requirements for traceability. The plan and verification steps below were authored after the implementation, not before it.

## Problem / Why

`docs/features/` had accumulated housekeeping gaps: twelve folders under `docs/features/active/` corresponded to work already merged to `main`, one closed-worthy issue (#116) remained open with its merging PRs not linked via a closing keyword, the root `CLAUDE.md` had been accidentally deleted by an unrelated prior commit, `README.md` had drifted from the current skill/agent/command inventory, and several previously-identified technical-debt items had never been converted into tracked GitHub issues.

## Implementation Intent

The audit performed a repository-wide reconciliation pass, executed and committed prior to this formalization:

1. Identified the 12 `docs/features/active/*` folders whose underlying work was already delivered to `main`, per the delivery-status audit (`docs/research/2026-07-09-active-features-delivery-status-audit.md`), and relocated them to `docs/features/completed/*` via `git mv` (pure renames, no content edits).
2. Checked `docs/features/potential/*` for entries duplicating `active/`, `archive/`, or `completed/` content, per the duplicate audit (`docs/research/2026-07-09-potential-entries-duplicate-audit.md`); no deletions were warranted because no genuine duplicates were found.
3. Scanned `docs/`, `README.md`, and feature-folder audit artifacts for identified-but-unresolved technical debt, per the technical-debt audit (`docs/research/2026-07-09-remaining-technical-debt-audit.md`), and opened/promoted tracked GitHub issues for genuinely outstanding items.
4. Reconciled GitHub issue #116 (open, with merged PRs #119/#137 lacking a closing keyword) against the delivery-status audit's recommendation.
5. Restored the accidentally-deleted root `CLAUDE.md` from git history, after confirming every path it references resolves in the current tree.
6. Refreshed `README.md` for accuracy against the current skills/agents/hooks/commands/MCP-tools inventory.

All of the above is captured in commit `541efcd` ("docs: complete feature-audit housekeeping and reconcile docs") on branch `drm-copilot-wt-2026-07-09T09-26`, except for the GitHub issue open/close actions in items 3 and 4, which are GitHub API-side changes and are not part of that commit's file diff.

## Acceptance Criteria

- [x] All `docs/features/active/*` folders confirmed delivered are relocated to `docs/features/completed/*`, with GitHub issues closed and linked to their merging PR.
- [x] `docs/features/potential/*` duplicate entries (if any) are deleted; retained entries are confirmed non-duplicate.
- [x] Genuinely outstanding technical debt is captured as new, promoted GitHub issues.
- [x] `README.md` accuracy is verified against current skills/agents/hooks/commands/MCP tools and corrected where stale.

## Dependencies / Risks

- This is a documentation/GitHub-metadata task with no production code diff; the standard per-language toolchain (format/lint/type-check/test) does not apply to any changed file.
- Risk: folder relocation could break relative links inside moved feature-folder artifacts; mitigated by using `git mv` (pure renames, no content edits) and confirming no absolute-path-dependent tooling references the old `active/` location.
- Risk: restoring `CLAUDE.md` from git history could reintroduce stale content; mitigated by verifying every file/path it references still resolves in the current tree before restoring it. This verification was performed once during implementation and must be re-confirmed independently in Phase 3 of the plan, since the calling agent for this document did not itself re-run that check.
- Dependency: Phase 3 verification depends on read access to the GitHub issue tracker (`gh issue view`) for issues #116, #335, #336, #337, #338, and #340. If that access is unavailable at verification time, the corresponding verification task cannot be marked pass and must be reported as blocked, not assumed.

## Verification Steps

The steps below are the genuine remaining work for this feature. They must be executed for real against the current repository state by `atomic-executor`, per Phase 3 of `plan.2026-07-09T11-29.md`; they are not a restatement of work already done.

1. Confirm `git log`/`git status` shows commit `541efcd` present on branch `drm-copilot-wt-2026-07-09T09-26` with a clean working tree at that point.
2. Confirm `docs/features/active/` contains no folder other than `repo-housekeeping-audit` itself (no regression: no other delivered-but-unrelocated folder has appeared).
3. Confirm all 12 folders identified in the delivery-status audit are present under `docs/features/completed/` and absent from `docs/features/active/`.
4. Confirm every file path referenced in the restored root `CLAUDE.md` resolves in the current working tree.
5. Confirm every skill/agent/command/MCP-tool claim added to `README.md` in this change matches its current source-of-truth file.
6. Confirm GitHub issues #335, #336, #337, #338, and #340 exist and report state OPEN, and issue #116 exists and reports state CLOSED, via `gh issue view`.
7. Record a pass/fail verification summary artifact under `docs/features/active/repo-housekeeping-audit/evidence/other/`.

## Evidence Checklist

- [x] baseline — `docs/research/2026-07-09-active-features-delivery-status-audit.md`, `docs/research/2026-07-09-potential-entries-duplicate-audit.md`, `docs/research/2026-07-09-remaining-technical-debt-audit.md` (audit inventory captured before the structural changes were made).
- [x] targeted verification — re-verification of the current repository state against the six checks above; performed by `atomic-executor`. See Phase 3 of `plan.2026-07-09T11-29.md` and `docs/features/active/repo-housekeeping-audit/evidence/baseline/p3-t1.git-state.2026-07-09T13-00.md` plus `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t2.active-folder-listing.2026-07-09T13-00.md` through `p3-t6.issue-state-verification.2026-07-09T13-00.md`.
- [x] end-state — pass/fail verification summary artifact written by `atomic-executor` at `docs/features/active/repo-housekeeping-audit/evidence/other/p3-verification-summary.2026-07-09T13-00.md`.
