# Phase 0 Gate (b) - Children 3 and 1 - [P0-T2]

Timestamp: 2026-11-19T08-18
Command: ls of scripts/harness-generation/, sources/rules/, sources/agents/, tests/scripts/harness/; Read of scripts/harness-generation/sources/rules/general-unit-test.json and sources/agents/feature-review.json; Grep of Get-HarnessRuleFileMap and the -Surface ValidateSet; Grep of config/harness-parity-matrix.json
EXIT_CODE: 0
Output Summary: Every item PRESENT on both refs (identical commit). COPILOT_SECTION: NOT-LISTED. FEATURE_REVIEW_OWNER: generated. BRIEF_OWNER: generated.

| Item | HEAD | integration |
| --- | --- | --- |
| scripts/harness-generation/sources/rules/general-unit-test.md | PRESENT | PRESENT |
| scripts/harness-generation/sources/rules/general-unit-test.json | PRESENT | PRESENT |
| `Get-HarnessRuleFileMap` in scripts/harness-generation/HarnessRuleGeneration.psm1 | PRESENT | PRESENT |
| Invoke-HarnessGeneration.ps1 accepts `-Surface rules -Check` (ValidateSet skills, rules, mcp, agents, instructions, all; `-Check` switch) | PRESENT | PRESENT |
| config/harness-parity-matrix.json entry `claude:path-scoped-rule:general-unit-test` with `generated_from` `scripts/harness-generation/sources/rules/general-unit-test.json` | PRESENT | PRESENT |
| tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 | PRESENT | PRESENT |

COPILOT_SECTION: NOT-LISTED
- The `copilot` target of general-unit-test.json lists sections `head-2`, `1-core-principles`, `2-coverage-and-scenarios`, `3-test-structure-and-diagnostics`, `4-external-dependencies-and-environment`, `5-policy-audit`; `coverage-exclusion-policy` is not listed. The claude and codex targets list `coverage-exclusion-policy`.

FEATURE_REVIEW_OWNER: generated
- config/harness-parity-matrix.json `claude:agent:feature-review` and `codex:agent:feature-review` are `disposition: generated`, `generator: harness-generation/agents`, `generated_from: scripts/harness-generation/sources/agents/feature-review.json`. The source body is scripts/harness-generation/sources/agents/feature-review.md, which holds two `## Coverage Verification` sections: section `coverage-verification` (rendered into `.claude/agents/feature-review.md`) and section `coverage-verification-2` (rendered into `.codex/agents/feature-review.toml`); each has `### Verification Procedure` step 2 `Check whether the coverage artifact exists for that language.`

BRIEF_OWNER: generated
- config/harness-parity-matrix.json `claude:skill:execution-environment` is `disposition: generated`, `generator: harness-generation/skills`, `generated_from: .agents/skills/execution-environment/SKILL.md` (HarnessSkillMirror renders `.claude/skills/<name>/` and its bundle copy from `.agents/skills/<name>/`).
