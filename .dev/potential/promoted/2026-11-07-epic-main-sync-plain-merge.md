# epic-main-sync-plain-merge (Issue #1117)

- Date captured: 2026-11-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-main-sync-plain-merge/ (Issue #1117)

- Issue: #1117
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1117
- Last Updated: 2026-11-07
## Problem / Why

Step 3 of `## Epic Integration Branch Lifecycle` in the `epic-orchestrate` skill runs every sync of `main` into an epic integration branch as a dedicated chore child item. The child goes through the full feature process: a feature record, an issue number, a test baseline, gates, review, a PR into the integration branch, and CI. On Epic #1019, the fourth sync took about 1 hour 12 minutes (19:04Z to 20:16Z on 2026-11-07), and the epic needed four.

The owner ruled on 2026-11-07 that a sync is a plain merge performed by the running orchestration: "Never before has a sync with main required an orchestration. It is usually a very short step." And: "A sync with main should resolve any conflicts naturally. It is still governed by the rules of the in flight orchestration. There is no need to burden a sync with additional rules."

## Proposed Behavior

Replace everything in step 3 from "A non-zero count means" to the end of the step, in all four copies, with this text:

> A non-zero count means `origin/main` has commits the integration branch lacks. Before the wave launches, `epic-orchestrator` merges `origin/main` into the integration branch (`git merge --no-ff origin/main`, resolving any conflicts; no rebase, no force-push), pushes the integration branch, re-runs step 2, and launches the wave. Commits that reach `origin/main` afterwards are picked up by the next wave's check or by the final integration PR in step 6.

The four copies:

- `.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.agents/skills/epic-orchestrate/SKILL.md` (Codex heading `## Integration Branch and Child Worktrees`; apply the same change to its equivalent text)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`

Update `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`:

- Remove these six pinned phrases: "dedicated chore child item", "`epic-852-main-sync`", "PR into the integration branch", "`features[]`", "manifest child's issue number", "one main-sync child".
- Keep "`git fetch origin main` and then", the `rev-list` count, "zero count proceeds directly to the wave", "merges `origin/main`", and "before the wave launches".
- Add pins for "pushes the integration branch" and "no rebase, no force-push".

Add a process-reduction ledger entry under `docs/engineering/process-reductions/`, with the prior text and revert steps.

## Out of scope

- No new sync rules, routes, gates, or conflict-handling paths.
- No change to hooks, validators, or other skills.

## Known facts (verified 2026-11-07)

- `ci.yml` runs on push to `main` and `development` only, and on pull requests into `main`, `development`, and `epic/**`. A direct push of the merge to the integration branch therefore runs no CI. The merged result is tested by the next child PR into the integration branch and by the final integration PR.
- The integration branch has no branch protection, and the only ruleset, `protect-main`, targets `main`.
- `validate-bash.ps1` denies only force pushes. The preimplementation gate inspects `git add` and `git commit`, resolving epic scope through the integration branch in the epic checkpoint. A conflict-free `git merge --no-ff` followed by `git push` touches neither. A merge that needs conflict resolution uses `git add` and `git commit` in the integration checkout, and whether the gate admits those commands there has not been observed.

## Acceptance Criteria (early draft)

- [ ] All four copies carry the replacement text and nothing else of the old sync procedure.
- [ ] The contract test passes, and fails if the child-item wording returns.
- [ ] A ledger entry records the reduction with its prior text and revert steps.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/epic-main-sync-plain-merge/` folder from the template
