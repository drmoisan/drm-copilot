# Code Review — Issue #584 (cleanup-worktrees-dirty-triage-procedure)

- Branch: `feature/cleanup-worktrees-dirty-triage-procedure-584` vs `main`
- Files changed: 33, all `.md`. Single production file: `.claude/skills/cleanup-merged-worktrees/SKILL.md` (+136/-4, 264 lines total). The remaining 32 files are the active feature folder's documentation and evidence trail plus the promoted-potential record.

## Change Composition

Two commits beyond `main`:
1. `c7e0a28f` — `git cherry-pick -x 00663e1151d0777e8e74d468b89bacd61c5c45b8`, verified clean: `git show c7e0a28f` carries the `(cherry picked from commit 00663e1151d0777e8e74d468b89bacd61c5c45b8)` trailer, and `git status --porcelain` / `git diff --diff-filter=U` were empty immediately after (per `evidence/other/cherry-pick-clean-tree.2026-08-28T18-43.md`, independently re-confirmed no unmerged paths exist on the branch today).
2. `9283c6bb` — documentation/evidence bookkeeping only (feature folder, promoted-potential record).

No hand-authored production-code changes exist on this branch; the entire behavioral delta was reused verbatim from an already-reviewed commit, consistent with the constraint stated in `issue.md`: "Delivered via `git cherry-pick -x`... rather than fresh authorship."

## Production File: `.claude/skills/cleanup-merged-worktrees/SKILL.md`

### Strengths

- The new "Dirty Worktree Triage Procedure" section is well-structured: a clear trigger condition, an explicit statement that it never overrides the existing `BLOCKED-DIRTY` refusal, ten numbered steps matching `issue.md`'s AC text closely (paraphrased for skill-prose register, not copy-pasted, with clarifying additions), and forward/backward cross-references (a pointer added to the existing "End-to-End Workflow" section, and a new "Cross-References" entry pointing to `feature-promotion-lifecycle`).
- "Prohibited Shortcuts" is updated consistently: the existing `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS`/`PROTECTED_CURRENT` restriction is expanded (not weakened) to clarify that the new triage procedure's `SAFE_TO_DELETE` verdict authorizes only a distinct, manually-confirmed action outside the script's automated allowlist — the deterministic apply-mode boundary is preserved, and this is stated explicitly rather than left implicit.
- New destructive actions introduced by the procedure (origin-branch deletion, orphaned-directory filesystem removal) are each explicitly gated behind "explicit per-item user confirmation," consistent with the repository's existing pattern of never letting a skill silently perform an irreversible, shared-state mutation.
- The frontmatter `allowed-tools` list grew from 6 to 18 entries, all narrowly scoped `Bash(...)` prefix patterns (e.g., `"Bash(git log *)"`, `"Bash(git branch -r*)"`) except for the three items noted below — this matches the existing convention used throughout the rest of the file's frontmatter (narrow verb/flag scoping rather than a bare `Bash` grant).

### Findings

**1. Unscoped `Agent` tool grant (advisory, non-blocking).**
Line 8 of the frontmatter adds a bare `- Agent` entry with no subagent-name restriction. This is inconsistent with the only other precedent for Agent-delegation grants in the repository — `.claude/agents/epic-orchestrator.md` and `.claude/agents/epic-planner.md`, both of which scope to specific named targets (`"Agent(orchestrator)"`, `"Agent(pr-author)"`) — and with `.claude/settings.json`'s permission allow-list, which enumerates every other Agent-delegation target by name (`Agent(atomic-planner)`, `Agent(feature-review)`, etc.) but does not include `Agent(general-purpose)` at all. The new prose (steps 8 and 9 of the triage procedure) only ever documents delegating to `Agent(general-purpose)`, so the frontmatter grant is broader than the skill's own documented usage requires, and the specific target it does document is not present in the project-level permission allow-list. Recommend either narrowing the frontmatter entry to `"Agent(general-purpose)"` and adding that entry to `.claude/settings.json`, or documenting why an unscoped grant is intentional here. Not merge-blocking: this is a least-privilege/consistency observation, not a demonstrated defect, and Claude Code's permission system will still prompt interactively for any delegation not covered by an allow-list entry rather than silently permitting it.

**2. New MCP tool references are consistent with existing usage.**
`mcp__drm-copilot__new_potential_bug_entry` and `mcp__drm-copilot__potential_to_issue` (step 9, for promoting unresolved product-scope findings) are both already used in `.claude/skills/feature-promotion-lifecycle/SKILL.md` and present in `.claude/settings.json`'s allow-list — no new tool surface is introduced, and the cross-reference to `feature-promotion-lifecycle/SKILL.md` is accurate.

**3. Step-9 wording accurately reflects the script's actual behavior.**
The claim that `--apply` "never deletes [`NOT_MERGED`/`HAS_UNIQUE_RESIDUALS`] on its own, before or after triage" and that a `SAFE_TO_DELETE` verdict "is never automated" is consistent with the unchanged "Prohibited Shortcuts" language elsewhere in the same file (`Never act on NOT_MERGED, HAS_UNIQUE_RESIDUALS, or PROTECTED_CURRENT candidates through the script or its apply-mode allowlist`). No internal contradiction found between the new section and the pre-existing deterministic-behavior guarantees.

**4. Pre-existing deterministic terms unaltered.**
`BLOCKED-DIRTY`, `NOT_MERGED`, and `HAS_UNIQUE_RESIDUALS` all remain present and are used consistently with their pre-existing meaning (independently confirmed via `grep -c` against the final file: all three present, no removals). The change is additive to documentation, not a behavioral rewrite of the script's classification logic (the script itself, `scripts/bash/cleanup-worktrees.sh`, is not touched by this diff — 0 non-`.md` files changed).

## Documentation / Evidence-Trail Files

The feature folder (`issue.md`, `plan.2026-08-28T18-43.md`, 29 evidence artifacts) is documentation and process bookkeeping, not production code, and is exempt from the toolchain loop and coverage requirements. One process-quality issue was found and is detailed fully in `policy-audit.2026-08-28T23-00.md` under "Evidence Integrity / atomic-plan-contract Adherence": task `[P1-T15]` in `plan.2026-08-28T18-43.md` still states a self-defeating acceptance command (an `awk` range that self-terminates on its own start pattern, always producing `0`/exit `1`, and never able to equal the task's own stated target of `5`), while the parallel, functionally-identical defect in `[P0-T5]` and `[P1-T16]` was fixed by revising the plan text to a working `sed`-range form. `[P1-T15]` was instead checked off using an ad hoc, unstated substitute command recorded only in the evidence artifact, bypassing the plan-revision-and-re-validation discipline applied to the other five originally-failing gates. This is a process-consistency defect in the plan/evidence text, not a defect in `SKILL.md`: independent re-verification (`sed -n '41,56p' ... | grep -c "^- "` after locating the section bounds via `grep -n`) confirms the true count is genuinely `5`, matching the requirement. Recommend a low-cost follow-up correcting `[P1-T15]`'s stated command to the same fixed `sed`-range form already used elsewhere in this plan, through the normal plan-revision channel — not a merge blocker.

## Summary

The single production-file change is well-scoped, internally consistent with the file's pre-existing deterministic-behavior guarantees, and delivered via a clean, verifiable cherry-pick. Two non-blocking findings: an unscoped `Agent` tool grant not fully backed by the project's permission configuration, and one plan task (`[P1-T15]`) whose stated acceptance command cannot literally pass, checked off via an undocumented substitute rather than a plan revision. Neither finding indicates a defect in the delivered `SKILL.md` content itself.
