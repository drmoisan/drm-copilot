# Pre-Edit Mirror-Identity Baseline and Diff Anchor (P0-T7)

Timestamp: 2026-08-28T11-36

Task: [P0-T7]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. `Get-FileHash .claude/hooks/enforce-epic-worktree-removal-gate.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1, .claude/skills/parallel-orchestrate/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md, .claude/rules/parallel-orchestration.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` (SHA-256, the `Get-FileHash` default)
2. `git merge-base origin/main HEAD`

EXIT_CODE: 0

## Six hashes, three pairs

| # | Path | SHA-256 |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `FB986221CDACCC1CBEBB48A61013CA569E5254068EC09C9812D1BF71C35A872D` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `FB986221CDACCC1CBEBB48A61013CA569E5254068EC09C9812D1BF71C35A872D` |
| 3 | `.claude/skills/parallel-orchestrate/SKILL.md` | `1ED3EFB818C29F19F5003ED2EAFF4804AC97EA53C2A4218E7919B8791C04ABB7` |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `1ED3EFB818C29F19F5003ED2EAFF4804AC97EA53C2A4218E7919B8791C04ABB7` |
| 5 | `.claude/rules/parallel-orchestration.md` | `20D0E12BA4916B8A5383236B40B835ED4531031617E7C5995A748CEAC6ACAFA0` |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` | `20D0E12BA4916B8A5383236B40B835ED4531031617E7C5995A748CEAC6ACAFA0` |

Pair equality before any edit:

- **Pair A (hook)** — entries 1 and 2 are EQUAL.
- **Pair B (skill)** — entries 3 and 4 are EQUAL.
- **Pair C (rule)** — entries 5 and 6 are EQUAL.

All three pairs are currently byte-identical. This closes research open item 1 with a real hash comparison and establishes that any post-edit inequality is caused by this change and by nothing pre-existing.

## Diff anchor

MergeBaseSha: c7133fe75ce1ea1737843330b2232c175a689e37

`git merge-base origin/main HEAD` reported the 40-character hexadecimal commit SHA above. This is the anchor every two-dot diff later in this plan substitutes for the `<merge-base-sha>` operand — specifically [P4-T6] (`git diff <merge-base-sha> -- .claude/rules/parallel-orchestration.md`) and [P5-T11] (`git diff --name-only <merge-base-sha>`). `origin/main` is already an ancestor of `HEAD`, so no rebase or merge is required and this SHA remains the correct anchor for the whole run.

Output Summary: Six SHA-256 hashes recorded. All three mirrored pairs are byte-identical before the edit (hook pair `FB98…872D`, skill pair `1ED3…ABB7`, rule pair `20D0…AFA0`). The merge-base anchor is recorded on its own labelled line as `MergeBaseSha: c7133fe75ce1ea1737843330b2232c175a689e37`, a 40-character hexadecimal commit SHA, and is the operand substituted into the two-dot diffs at [P4-T6] and [P5-T11].
