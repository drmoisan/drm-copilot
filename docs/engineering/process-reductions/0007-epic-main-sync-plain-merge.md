# 0007: Epic main-sync as a plain merge

## Summary

reduction: 0007
Date: 2026-11-07
Issue: #1117
Merge commit: pending (PR #1117)

Replaces the dedicated sync child item that step 3 of the epic integration branch lifecycle ran for every sync of `origin/main` into an epic integration branch with a plain merge performed by the running `epic-orchestrator`. The sync no longer goes through a feature record, an issue number, a test baseline, gates, review, a pull request, or CI as a child item of its own.

## Reason and Evidence

The owner ruled on 2026-11-07 that a sync is a plain merge performed by the running orchestration: "Never before has a sync with main required an orchestration. It is usually a very short step." And: "A sync with main should resolve any conflicts naturally. It is still governed by the rules of the in flight orchestration. There is no need to burden a sync with additional rules."

On Epic #1019 the fourth sync took about 1 hour 12 minutes (19:04Z to 20:16Z on 2026-11-07), and the epic needed four. The merged result is tested by the next child pull request into the integration branch and by the final integration pull request, because `ci.yml` runs no CI for a direct push to an `epic/**` branch.

## Files Changed

- `.claude/skills/epic-orchestrate/SKILL.md`, step 3 of `## Epic Integration Branch Lifecycle`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`, a byte-identical bundled copy
- `.agents/skills/epic-orchestrate/SKILL.md`, the main-sync paragraph of `## Integration Branch and Child Worktrees`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`, a byte-identical bundled copy
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, the pinned digest of the Claude skill in `PINNED_FROZEN_SURFACE_HASHES`
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`, the pinned fragments, the retired child-item phrases, and the case-insensitive `contains_phrase`
- `docs/engineering/process-reductions/0007-epic-main-sync-plain-merge.md`, this entry
- `docs/engineering/process-reductions/README.md`, the index row

## Prior Text

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current
A non-zero count means `origin/main` has commits the
   integration branch lacks. Before the wave launches, `epic-orchestrator` merges `origin/main`
   into the integration branch (`git merge --no-ff origin/main`, resolving any conflicts; no
   rebase, no force-push), pushes the integration branch, re-runs step 2, and launches the wave.
   Commits that reach `origin/main` afterwards are picked up by the next wave's check or by the
   final integration PR in step 6.
````

````Prior
A non-zero count means `origin/main` has commits the
   integration branch lacks, and the main-sync runs as a dedicated chore child item before the
   wave launches, following the `epic-852-main-sync` / PR #882 pattern. Before delegating it,
   `epic-orchestrator` writes the sync child's `features[]` row (with `depends_on: []`) and its
   own `waves[]` entry to the epic checkpoint, because `enforce-epic-wave-barrier.ps1` denies a
   delegation whose feature record is absent. The sync child must not reuse a manifest child's
   issue number; it uses the epic issue number or a dedicated chore issue. Its branch is created
   from the integration branch, merges `origin/main` with a merge commit
   (`git merge --no-ff origin/main`; no rebase, no force-push), resolves any conflict inside its
   own remediation loop, and opens a PR into the integration branch. The wave does not launch
   until that PR has merged into the integration branch and the sync entry's `merge_status` is
   `merged`. At most one main-sync child runs per wave: after it merges, `epic-orchestrator`
   re-runs step 2 and launches the wave without repeating the count, and commits that reach
   `origin/main` afterwards are picked up by the next wave's check or by the final integration
   PR in step 6.
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current
A non-zero count means `origin/main` has commits the integration branch lacks. Before the wave
launches, `epic-orchestrator` merges `origin/main` into the integration branch
(`git merge --no-ff origin/main`, resolving any conflicts; no rebase, no force-push), pushes the
integration branch, re-fetches the integration tip, and launches the wave. Commits that reach
`origin/main` afterwards are picked up by the next wave's check or by the final integration PR.
````

````Prior
A non-zero count runs the main-sync as a dedicated chore child item (the `epic-852-main-sync` /
PR #882 pattern) whose branch starts from the integration tip, merges `origin/main` with a merge
commit, and opens a PR into the integration branch; that PR must merge before the wave launches.
Record the sync child's `features[]` row before its launch, and do not reuse a manifest child's
issue number for it. Run at most one main-sync child per wave, then re-fetch the integration tip.
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file.
2. Re-copy mirrors and bundles: copy `.claude/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`, and copy `.agents/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`.
3. Regenerate Codex variants: not applicable.
4. Restore pinned hashes: set the digest of `.claude/skills/epic-orchestrate/SKILL.md` in `PINNED_FROZEN_SURFACE_HASHES` to the digest of the reverted file, and replace the `RE-BASELINED by issue #1117` comment paragraph with a re-baseline note for the revert.
5. Restore contract-test literals: in `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`, restore the six retired phrases to `MAIN_SYNC_FRAGMENTS`, remove the two added pins, remove `REMOVED_CHILD_ITEM_PHRASES` with its two tests, and restore the case-sensitive comparison in `contains_phrase`.
6. Run the contract tests: run `test_epic_orchestrate_main_sync_contract.py`, `test_parallel_orchestrator_surface_contracts.py`, and the push-down resource contract tests under `tests/scripts/dev_tools/`.

## Revert Signals

- A sync of `origin/main` into an integration branch produces a conflict that the running `epic-orchestrator` cannot resolve under the in-flight orchestration rules.
- A merged sync reaches a child pull request or the final integration pull request and fails CI there repeatedly, which indicates the unreviewed merge let a defect through.
- The preimplementation gate denies the `git add` and `git commit` commands of a conflict-resolving sync in the integration checkout, which this entry's issue records as not yet observed.
