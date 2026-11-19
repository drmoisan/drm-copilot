# Rules, Agents and Skills Generation - [P3-T4]

Timestamp: 2026-11-19T11-36
Command: sh SCRATCH/issue-1049-generate.sh (git status --porcelain; PowerShell 7 scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface rules, then -Surface agents, then -Surface skills, each in write mode; git status --porcelain; then the same script with -Surface rules -Check, -Surface agents -Check and -Surface skills -Check)
EXIT_CODE: 0
Output Summary: The three write-mode runs exited 0. The before listing held 11 entries (the [P3-T1], [P3-T2] and [P3-T3] edits, the plan and three task-check files); the after listing held 23. The 12 new or changed entries are exactly the twelve planned outputs; none lies outside them. `-Surface rules -Check`, `-Surface agents -Check` and `-Surface skills -Check` each exited 0 with `harness-generation: no drift`.

## Entries new or changed between the two listings

- .claude/rules/general-unit-test.md
- .agents/skills/general-unit-test/SKILL.md
- .github/instructions/general-unit-test.instructions.md
- extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md
- extensions/drm-copilot/resources/customizations/.github/instructions/general-unit-test.instructions.md
- .claude/agents/feature-review.md
- .codex/agents/feature-review.toml
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml
- .claude/skills/execution-environment/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md

## Check runs

| Command | Exit | Output |
| --- | --- | --- |
| Invoke-HarnessGeneration.ps1 -Surface rules -Check | 0 | `harness-generation: no drift` |
| Invoke-HarnessGeneration.ps1 -Surface agents -Check | 0 | `harness-generation: no drift` |
| Invoke-HarnessGeneration.ps1 -Surface skills -Check | 0 | `harness-generation: no drift` |

Observation: with decision RD-1 the Copilot output carries the reused section as an unnumbered `## Coverage Exclusion Policy` between `## 2. Coverage and Scenarios` and `## 3. Test Structure and Diagnostics`, as the plan anticipated.
