# cleanup-worktrees-dirty-triage-procedure (Issue #584)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-dirty-triage-procedure/ (Issue #584)

- Issue: #584
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/584
- Last Updated: 2026-08-28
- Work Mode: minor-audit

## Problem / Why

The `cleanup-merged-worktrees` skill correctly classifies worktrees as MERGED_CLEAN and correctly refuses to force-remove a worktree that is dirty (BLOCKED-DIRTY), leaving it untouched. That part is right and must not change. What is missing is a systematic procedure for triaging those dirty worktrees afterward: deciding whether the uncommitted/unmerged content is disposable or must be preserved before the worktree can ever be deleted. Today that triage is done ad hoc; it should become part of the skill.

## Proposed Behavior

Add a "Dirty Worktree Triage Procedure" section to `.claude/skills/cleanup-merged-worktrees/SKILL.md`, following the ten-step procedure below, per BLOCKED-DIRTY worktree.

## Acceptance Criteria

Title: Add a "dirty worktree triage" procedure to the cleanup-merged-worktrees skill

Procedure to add, per BLOCKED-DIRTY worktree:

- [x] 1. Re-verify current state before analyzing. Worktrees can be actively in use by another concurrent session. Re-run `git status --porcelain` and check the branch's merge status fresh — don't trust the original scan's snapshot. If a worktree's .git-worktree index/HEAD mtimes show activity in the last few minutes, treat it as possibly live and pause rather than analyze it as abandoned.
- [x] 2. Check committed-but-unmerged commits too, not just the working tree. `git log main..<branch> --oneline` — some worktrees have real commits that never merged, separate from uncommitted working-tree dirt. Both need the same treatment below.
- [x] 3. For every dirty/untracked/unmerged file, determine whether equivalent content already exists on main — not just at the same path (`git show main:<path>`), but by topic: grep broadly across the relevant shared namespace (e.g., .claude/agent-memory/** for lesson files, docs/features/** for feature docs) since the same fact often gets re-recorded under a different filename.
- [x] 4. For feature-folder doc snapshots (issue.md/plan.md/spec.md/research/*), check whether the feature is fully closed on main (acceptance criteria all checked, code-review/feature-audit/policy-audit artifacts and an evidence trail present). An earlier draft of an already-closed feature is almost always fully superseded — diff it to confirm rather than assume.
- [x] 5. Classify any content that isn't obviously superseded into one of four outcomes, each with a different disposition:
  - DEAD_ONE_OFF — real, but tied to an already-executed, closed plan with no reuse elsewhere (check whether the same pattern appears in shared .claude/skills/** templates or in other feature plans). Low value; safe to discard even though it's not technically duplicated.
  - ALREADY_SOLVED_ELSEWHERE — the underlying problem it documents is fixed a different way on main (check main's actual current code/config/script, not just its memory files, since a memory file can describe a bug that no longer exists).
  - STALE_OR_CONTRADICTED — main's current version of the same lesson has since been corrected to state something different or opposite. This is not just redundant — it's actively wrong, and discarding is the right call.
  - GENUINELY_NEW / STILL_RELEVANT — not found anywhere else, or it corrects something main currently gets wrong, or it documents unresolved scope on a still-open issue (verify open/closed via `gh issue view`, don't assume). Must be preserved before the worktree is deleted.
- [x] 6. Handle non-memory dirty content on its own terms. Some worktrees carry stale build artifacts (modified .csproj/packages.config/app.config from a build run in that worktree) rather than documentation — diff a representative sample against main to characterize what changed before deciding it's disposable.
- [x] 7. Recognize orphaned non-worktree directories. A path can still exist on disk under a worktree-tracking folder after `git worktree remove` partially ran or failed, with no .git file inside and no entry in `git worktree list`. These aren't worktrees anymore — flag them for plain filesystem removal (`rm -rf`), not `git worktree remove`, which will misfire or no-op on them.
- [x] 8. Parallelize the triage. Since this is pure read-only investigation, fan out one investigation pass per worktree (or a small batch) concurrently, each following steps 1-7 and returning a structured verdict (SAFE_TO_DELETE / PRESERVE) with justification citing specific files or commit SHAs. This scales far better than doing it serially.
- [x] 9. Route PRESERVE findings through the existing consolidation flow (the documentationandmemories branch/PR mechanism already in the skill) before running apply-mode deletion on the now-triaged worktree. If a finding describes unresolved product scope (not a process lesson), promote it to a real follow-up issue instead of folding it into the docs/memory PR.
- [x] 10. After local branch deletion, check origin too. The skill is explicitly local-only by design, but that leaves stale branches on the remote for anything already merged. Add an explicit, confirmed follow-up step: after --apply finishes, diff the deleted-local-branch list against `git branch -r` (post-prune) and offer to delete the remainder on origin — since that's shared, visible state, it should require explicit user confirmation, unlike the local deletions.

Note for feature-review / AC checkoff: the committed implementation already reachable at commit `00663e1151d0777e8e74d468b89bacd61c5c45b8` delivers all ten steps above, plus consistency fixes it required — clarifying that the script's own deterministic `BLOCKED-DIRTY` refusal and `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` apply-mode exclusion are unchanged, and that `SAFE_TO_DELETE` dispositions and origin-branch/orphaned-directory deletions are individually confirmed manual actions outside the script's automated allowlist. Verify the cherry-picked file actually reflects this before checking any AC box.

## Constraints & Risks

- Delivered via `git cherry-pick -x 00663e1151d0777e8e74d468b89bacd61c5c45b8` of an already-authored, already-reviewed commit rather than fresh authorship; the implementation phase must reuse that work, not re-author it.
- Touches exactly one production file (`.claude/skills/cleanup-merged-worktrees/SKILL.md`, a Markdown skill definition, not a code file) — no test file applies.
- The existing MERGED_CLEAN classification and BLOCKED-DIRTY refusal behavior must not change.

## Test Conditions to Consider

- [ ] N/A — Markdown-only skill-definition change; no executable code, no automated test suite applies.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/cleanup-worktrees-dirty-triage-procedure-<issue>/` folder from the template

