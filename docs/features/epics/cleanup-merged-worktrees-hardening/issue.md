# cleanup-merged-worktrees-hardening-epic (Issue #655)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-merged-worktrees-hardening-epic/ (Issue #655)

- Issue: #655
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/655
- Last Updated: 2026-09-08
- Work Mode: full-feature

## Problem / Why

On 2026-09-06 the `/cleanup-merged-worktrees` skill was run in the TaskMaster checkout against 57 registered worktrees and 69 local branches. The deterministic script did its part correctly (45 branches classified merged, 32 deleted, 7 worktrees removed), but finishing the job required hand-written scripts, a manual consolidation commit, and hook workarounds. Nine gaps were observed in that run and are recorded verbatim at `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`:

1. `--apply` never considers detached worktrees.
2. Dirty worktrees are blocked with no classification of the dirt.
3. The worktree-removal hook contradicts the skill's manual-action step.
4. The merge gate blocks the consolidation PR the skill itself produces.
5. Untracked lesson files are the bulk of the preserved content, and the script cannot see them.
6. Ordering hazard: the consolidation branch is delete-eligible before its first commit.
7. Orphaned directories and stale refs are not reported.
8. Hook text-matching false positives.
9. Smaller items: the hard-coded `<N> = 396` receipt number, `collect_pr_context` omitting `.claude/**` from the changed-files overview, per-commit classification cost on epic child branches, and lost worktree registrations.

The fixes span four surfaces (bash script libraries, PowerShell gate hooks, the TypeScript `collect_pr_context` extension code, and the skill document), so the work was planned and executed as the epic `cleanup-merged-worktrees-hardening` (`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`) with eight child features: #630, #631, #632, #545, #633, #634, #635, #637. This entry is the epic's own tracking issue. It exists so that the integration-to-`main` pull request, the closure of #591 as superseded by #545, and the follow-up defects surfaced during execution have a parent record; the epic-level checkpoint for the integration PR is keyed to this issue rather than to any single child.

## Proposed Behavior

Deliver every fix in `drm-copilot` so the next push-down carries it; do not patch consumer-repository copies. The skill, the bash scripts, and the PowerShell hooks push down together. After the epic merges, a `/cleanup-merged-worktrees` run on a large checkout can be carried from report through apply, consolidation, and merge without hand-written scripts, manual consolidation commits, or hook workarounds.

## Acceptance Criteria (early draft)

- [ ] Report mode classifies detached worktrees and emits `DIRTY|` lines with a dirt verdict; apply mode with the new opt-in flag clears and removes worktrees whose dirt is entirely non-`UNIQUE`.
- [ ] The skill can remove a `SAFE_TO_DELETE` worktree without invoking a command the removal hook denies, and the hook still denies unmanifested removals of epic/parallel item worktrees.
- [ ] The consolidation step carries untracked `PRESERVE` files with index lines, line-ending normalization, and host-token refusal; the skill text documents whether the consolidation PR merge is human-only or checkpoint-gated.
- [ ] An apply pass cannot delete a zero-commit `documentationandmemories` branch.
- [ ] Orphan directories and stale `child/*` refs appear in report output.
- [ ] Hook command matching no longer triggers on quoted text.
- [ ] bats coverage for every new lib function per `.claude/rules/shell.md` (no temp files; use the `CLEANUP_WT_GIT_BIN` seam), Pester coverage for the hook changes, and the skill, script, and hooks pushed down together.
- [ ] All eight child features are merged into `epic/cleanup-merged-worktrees-hardening-integration`, the integration branch is merged into `main` through a pull request with the full `ci.yml` gate green, and #591 is closed as superseded by #545.

## Constraints & Risks

- Epic child PRs into the integration branch trigger no `ci.yml` run, so each bash child verified through a `workflow_dispatch` of `_shell-coverage.yml` against its head SHA; the integration PR into `main` is the first run of the full CI gate over the combined change.
- `scripts/bash/cleanup_worktrees_lib.sh` was at 479 of the 500-line cap; new behavior lives in sibling libraries.
- Gap 8 was consolidated into #545 after two reversals; issues #636 (closed as superseded) and #591 (open until the epic merges) were withdrawn from the epic.
- Follow-up defects recorded by the epic orchestrator during execution (removal-gate cross-mode gap, child-PR CI trigger gap, wave-barrier validator noise, upstream-citation misresolution, and the child-632 findings NF-1 and NF-2) are filed separately and are not in this epic's scope.

## Test Conditions to Consider

- [x] Unit coverage areas: per-child bats, Pester, and Jest suites, each verified at or above the 85% line-coverage floor on its own branch.
- [x] Integration scenarios: the merged integration branch runs the full `ci.yml` pipeline on the integration-to-`main` pull request.
- [ ] CLI/API examples: a report and apply run of `scripts/bash/cleanup-worktrees.sh` against the live checkout after the push-down.

## Next Step

- [x] Promote to GitHub issue (epic template)
- [ ] Create `docs/features/active/cleanup-merged-worktrees-hardening-epic/` folder from the template (not applicable: the epic home is `docs/features/epics/cleanup-merged-worktrees-hardening/`)
