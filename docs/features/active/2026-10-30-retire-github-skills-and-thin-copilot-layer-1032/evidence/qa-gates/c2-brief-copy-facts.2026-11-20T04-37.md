# Brief and Contract Copy Facts, Cycle-2 Merge Head ([P1-T6])

Plan: remediation-plan.2026-11-19T19-58.md
Timestamp: 2026-11-20T04-37
Command: git hash-object over the four REMAINING-BRIEF-COPIES and the four REMAINING-CONTRACT-COPIES; git ls-files '*execution-environment/SKILL.md' '*atomic-plan-contract/SKILL.md'; fixed-string grep of each S1 to S6 target token in the `.claude` brief and contract copies (the other copies share the hash)
EXIT_CODE: 0
Output Summary: the four brief copies carry one hash; the contract copies form the two pre-existing pairs (AD-8); S1 to S6 hold; git ls-files lists exactly four brief copies and four contract copies, none under RETIRED-SKILL-TREES.

## Brief copies (REMAINING-BRIEF-COPIES)

BriefHash: a566b17e4fb95bde750603ccf1728eeb7ace83d1 (all four copies)

- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`

## Contract copies (REMAINING-CONTRACT-COPIES, AD-8 pairs)

- Claude pair: `.claude/skills/atomic-plan-contract/SKILL.md` and its claude-customizations bundle copy: da7e12b0c620e2d18412e702cf7d6f93333886fe
- Agents pair: `.agents/skills/atomic-plan-contract/SKILL.md` and its codex-and-agents-customizations bundle copy: ace630fce696ebfe458009b8efb0ced32f7bb90d

## Statement checks

| Statement | Target | Result |
| --- | --- | --- |
| S1 | `## Purpose and Maintenance`: "byte-identical in four locations" with a location list naming exactly the four brief copies and no retired path | holds |
| S2 | "in all four byte-identical copies" (1 occurrence in the brief) | holds |
| S3 | "in the four `documentation-workflow` copies" and "in the four copies of this brief" | holds |
| S4 | `planning-contract-wording.Tests.ps1` bullet: "in the four `atomic-plan-contract` copies" | holds |
| S5 | `test-cadence-wording.Tests.ps1` bullet: "in the four `atomic-plan-contract` copies" | holds |
| S6 | each contract copy: "in all four byte-identical copies" (1 occurrence each in the `.claude` and `.agents` copies; bundle copies equal by hash); "in all six" 0 occurrences | holds |

The two remaining occurrences of the word "six" in the brief state unrelated facts ("the six artifact hooks" in `## Hook Execution Context`, "six shards since issue #1190" in `## CI Shape and Required Checks`) and are not BRIEF-COUNT-STATEMENTS.
