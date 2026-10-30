# Execution-Environment Brief Tokens (issue #1009)

Timestamp: 2026-10-30T17-45
Command: poetry run python SCRATCH/issue-1009-section-tokens.py .claude/skills/execution-environment/SKILL.md (fixed-string line search of the working-tree file, not git grep, restricted to the lines between each named heading and the next `## ` heading)
EXIT_CODE: 0
Output Summary: every section condition holds.

| Section | Token | Matching lines | Required |
|---|---|---|---|
| `## Batch Budget` | `holds the hook script` | 0 | 0 |
| `## Batch Budget` | `Resolve-HookTargetWorktree` | 1 | at least 1 |
| `## Batch Budget` | `sibling` | 1 | at least 1 |
| `## Hook Execution Context` | `Resolve-HookTargetWorktree` | 1 | at least 1 |
| `## Preflight Defect Classes the Validator Cannot See` | `Batch-budget exhaustion across a session` | 0 | 0 |
| `## Preflight Defect Classes the Validator Cannot See` | `Batch-budget exhaustion within one worktree` | 1 | exactly 1 |

No line number or commit identifier was added to the brief. Every phrase pinned by `test_brief_batch_budget_section_states_cap_codes_and_exemptions`, `test_brief_preflight_classes_include_changed_existing_behavior`, and `test_brief_preflight_classes_include_brief_maintenance` is kept.
