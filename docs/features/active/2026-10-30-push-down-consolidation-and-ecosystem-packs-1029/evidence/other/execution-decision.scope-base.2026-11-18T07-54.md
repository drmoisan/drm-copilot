# Execution Decision: Scope Base for Size and Scope Comparisons

Timestamp: 2026-11-18T07-54
Command: sh SCRATCH/issue-1029-bases.sh (git merge-base origin/main HEAD; git merge-base origin/epic/shared-agent-harness-layer-integration HEAD; git diff --stat between the two)
EXIT_CODE: 0
Output Summary: The plan defines `BASE` as the merge base of `origin/main` and `HEAD`. This item is an epic child, and the integration branch carries the merged changes of #1025 and #1028 that are not on `main`. Between the main merge base and the integration merge base, 72 files differ, including files under `.claude/hooks`, `quality-tiers.yml`, `extensions/drm-copilot/src/repo-automation-service.ts` (476 to 495 lines) and the `VIRTUAL_RESOURCE_DIRECTORIES` value in `codex-agents-customizations.ts` (one added `.codex/lib/development-docs` pair). Comparisons against the main merge base would attribute upstream changes to this item.

## Decision

Recommended option, taken under the autonomous-mode directive (OD-1) and the cost-benefit rule (OD-4): the comparisons that judge this item's own change use `IBASE`, the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`, recomputed when used. This applies to:

- P2-T3, P2-T5, P3-T2, P3-T3 physical line-count comparisons ("fewer than" or "no more than at `BASE`");
- P2-T4 "pinned Codex declarations byte-identical to `BASE`";
- P5-T6 scope, size and isolation checks over the branch changes;
- P5-T7 self-review diff.

P0-T2 itself reads every citation at both the main merge base and `HEAD`, as written; that record is unchanged by this decision.

## Reason

- The plan's acceptance intent is that this item does not grow the cited files, does not change the pinned declarations, and does not touch hooks, `quality-tiers.yml` or the ledger. Upstream merges already changed those at the main merge base, so the literal comparison would fail through no change of this item, or would require reverting upstream work, which is outside scope.
- The plan text itself states the pre-change figure it expects for `repo-automation-service.ts` (495 at re-plan), which equals the integration merge base and not the main merge base (476).
- The alternative (comparing with the main merge base) would either block the plan on a premise that is not falsified (the design is unaffected) or require out-of-scope edits.
