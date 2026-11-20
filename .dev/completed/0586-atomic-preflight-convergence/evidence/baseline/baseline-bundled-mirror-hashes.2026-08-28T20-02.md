# Baseline — Bundled Mirror Blob Hashes (Issue #586)

Timestamp: 2026-08-28T22-02

Task: [P0-T5]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Revision context: worktree state at HEAD `56dcad93cc3767de1191e89807fa31c248c4c87d`, before any Phase 1 edit.

## Command 1 — `atomic-plan-contract` pair

Command: git hash-object .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

```
e3b2198e4dac4c82d6c883bd370f04367a79e96e
e3b2198e4dac4c82d6c883bd370f04367a79e96e
```

The command printed exactly two 40-character hexadecimal SHAs, and the two SHAs are identical to each other. The target file `.claude/skills/atomic-plan-contract/SKILL.md` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` are therefore byte-identical at baseline, which confirms the premise recorded in `issue.md` `## Constraints & Risks`. No divergence to reconcile.

## Command 2 — `remediation-handoff-atomic-planner` pair

Command: git hash-object .claude/skills/remediation-handoff-atomic-planner/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md

EXIT_CODE: 0

Output Summary:

```
698f563ca0e8f5e651b422841f0e462349bd6ade
698f563ca0e8f5e651b422841f0e462349bd6ade
```

The command printed exactly two 40-character hexadecimal SHAs, and the two SHAs are identical to each other. The target file `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` are therefore byte-identical at baseline. No divergence to reconcile.

## Transcribed Baseline SHAs (Pre-Change Reference)

These four values are the pre-change reference that the [P1-T14], [P1-T15], and [P2-T10] acceptance conditions compare against. A post-change SHA equal to its baseline value below means the corresponding copy was not edited.

| # | Path | Baseline blob SHA |
| --- | --- | --- |
| 1 | `.claude/skills/atomic-plan-contract/SKILL.md` | `e3b2198e4dac4c82d6c883bd370f04367a79e96e` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | `e3b2198e4dac4c82d6c883bd370f04367a79e96e` |
| 3 | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `698f563ca0e8f5e651b422841f0e462349bd6ade` |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `698f563ca0e8f5e651b422841f0e462349bd6ade` |

Both commands exited 0. Each printed two identical SHAs. Both pairs are byte-identical at baseline, so the byte-identical-at-baseline premise holds and Phase 1 is not blocked by this task.
