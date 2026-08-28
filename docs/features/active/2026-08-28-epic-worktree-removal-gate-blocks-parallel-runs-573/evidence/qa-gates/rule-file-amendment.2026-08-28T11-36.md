# Rule-File Amendment Scope Check (P4-T6)

Timestamp: 2026-08-28T11-36

Task: [P4-T6]
Issue: #573
Acceptance criterion discharged: AC-20
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. `git diff c7133fe75ce1ea1737843330b2232c175a689e37 -- .claude/rules/parallel-orchestration.md`
2. Companion span, same step: `git status --porcelain`

`c7133fe75ce1ea1737843330b2232c175a689e37` is the merge-base commit recorded on the `MergeBaseSha:` line of the [P0-T7] baseline artifact, substituted for the plan's `<merge-base-sha>` operand. The two-dot single-ref form is used deliberately: it compares the working tree against that commit, so it observes the edit whether or not intermediate phases were committed. The three-dot form would emit nothing useful here and the gate would pass vacuously.

EXIT_CODE: 0

## The diff, verbatim

```diff
diff --git a/.claude/rules/parallel-orchestration.md b/.claude/rules/parallel-orchestration.md
index 37af4d96..148b1ce4 100644
--- a/.claude/rules/parallel-orchestration.md
+++ b/.claude/rules/parallel-orchestration.md
@@ -409,3 +409,4 @@ an unclassified key or a key present in only one copy fails loudly and names its
 - Enforcement is therefore Python validator logic, plus the TypeScript parity port, plus this prose file. It is NEVER an imported JSON Schema. No schema file is read at validation time.
 - The `parallel` route entry lives in `config/orchestration-routing.json` with `requires_pr_gate: false` (there is no run-level pull request to gate; each child's own route checkpoint enforces its per-item pull-request gate) and is mirrored byte-for-byte in `extensions/drm-copilot/resources/config/orchestration-routing.json`.
 - The `PreToolUse` merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel allow-branch that authorizes a per-item `gh pr merge --merge` from the parallel-orchestrator checkpoint when `route_id == "parallel"`, the target item's `merge_status == "ci_green"`, and the command's PR number matches that item's `pr_number`; any other case fails closed with `EPIC_MERGE_GATE_BLOCKED`.
+- The `PreToolUse` worktree-removal gate `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` likewise carries a parallel allow-branch that authorizes a per-item worktree removal from the parallel-orchestrator checkpoint when `route_id == "parallel"` and the `items[]` entry whose `worktree_path` matches the normalized removal target has `merge_status` in `{merged, worktree_removed}`; any other case — neither checkpoint present, either checkpoint unparseable, `route_id` absent or not `"parallel"`, no matching `worktree_path`, or a matched entry whose `merge_status` is outside that set or absent — fails closed with `EPIC_WORKTREE_REMOVAL_BLOCKED`. Removal is keyed on the worktree path rather than on `pr_number`, because the command names a path. This gate and the sibling gate `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, which owns `PARALLEL_WORKTREE_REMOVAL_BLOCKED`, both fire on the same command, and `PreToolUse` denials are conjunctive, so both must allow for a removal to proceed.
```

## Scope assertions

**The diff is non-empty and contains at least one added content line.** It carries exactly one `+` line that is not the `+++` file header — the appended enforcement bullet — and zero `-` lines that are not the `---` file header. The hunk header `@@ -409,3 +409,4 @@` shows a three-line context window growing to four lines, which is an append with no deletion and no reflow.

**Every added content line falls within the `## Enforcement` section.** The single hunk sits at line 409 onward. The three context lines above the addition are the last three existing `## Enforcement` bullets (the enforcement-mechanism bullet, the routing-config bullet, and the merge-gate bullet), and the addition follows the merge-gate bullet as the section's new final bullet. `## Enforcement` is the last section of the file, so there is no following section for the addition to spill into. A bullet count confirms the shape: the `## Enforcement` section carries 9 bullets in the working tree against 8 at `HEAD`, a delta of exactly one.

**No prohibited region is touched.** The diff contains:

- no change to the Foreign Schema Warning text (that section sits near line 28 and is absent from the single hunk),
- no change to any numbered invariant (orchestrator 1-21, planner P1-P9, manifest M1-M8; all sit between roughly lines 44 and 144 and are absent from the hunk),
- no change to any enum-table row (the Enum Ownership table near line 198 and the Omitted Epic Schema Fields table near line 160 are absent from the hunk),
- no change to the Cache Doctrine text (near line 146, absent from the hunk).

Because the diff is a single hunk at line 409 with one added line and zero removed lines, no line outside the `## Enforcement` section could have been altered.

**No new invariant, enum member, or configuration key is introduced.** The bullet describes existing enforcement behaviour using existing enum members (`merged` and `worktree_removed`, both members of the `merge_status` enum fixed by invariant 7) and the existing `route_id` value `parallel` fixed by invariant 2.

## Companion porcelain status

```
 M .claude/rules/parallel-orchestration.md
 M .claude/skills/parallel-orchestrate/SKILL.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
?? docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/qa-gates/mirror-identity-rule.2026-08-28T11-36.md
?? docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/qa-gates/mirror-identity-skill.2026-08-28T11-36.md
```

Four modified files, all in scope (the two Phase 4 prose files and their two bundle mirrors), plus two untracked evidence artifacts under the feature folder. The Phase 2 and Phase 3 files do not appear because they are already committed; the merge-base-anchored diff, not this status, is the authoritative whole-change enumeration, and it is taken at [P5-T11].

Output Summary: PASS (AC-20). The merge-base-anchored diff of `.claude/rules/parallel-orchestration.md` is non-empty and consists of exactly one hunk at line 409 carrying one added content line and zero removed content lines. That line is the appended `## Enforcement` bullet; the section's bullet count goes from 8 at `HEAD` to 9 in the working tree. No Foreign Schema Warning text, no numbered invariant, no enum-table row, and no Cache Doctrine text appears in the diff, so the edit is confined as the scope limit requires. The companion `git status --porcelain` shows four modified in-scope files and two untracked feature-folder evidence artifacts.
