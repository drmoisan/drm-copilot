# Phase 0 Gate (b) - Children 3 and 1 - [P0-T2] (re-run, plan revision 2.1)

Timestamp: 2026-11-19T08-48
Command: Glob of the rule source pair, feature-review.json and tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1; Grep of `Get-HarnessRuleFileMap`, the `-Surface` ValidateSet and the `-Check` switch; Grep of sections in scripts/harness-generation/sources/rules/general-unit-test.json; grep and sed of `generated_from` and `generator` in config/harness-parity-matrix.json
EXIT_CODE: 0
Output Summary: Every item PRESENT on both refs (source files identical between the refs; HEAD differs only under this feature folder). COPILOT_SECTION: NOT-LISTED. FEATURE_REVIEW_OWNER: generated. BRIEF_OWNER: generated. All three equal the expected values; no mismatch.

| Item | HEAD | integration |
| --- | --- | --- |
| scripts/harness-generation/sources/rules/general-unit-test.md | PRESENT | PRESENT |
| scripts/harness-generation/sources/rules/general-unit-test.json | PRESENT | PRESENT |
| `Get-HarnessRuleFileMap` in scripts/harness-generation/HarnessRuleGeneration.psm1 | PRESENT | PRESENT |
| Invoke-HarnessGeneration.ps1 `-Surface` ValidateSet includes `rules`; `-Check` switch | PRESENT | PRESENT |
| config/harness-parity-matrix.json entry `claude:path-scoped-rule:general-unit-test` with `generated_from` the rule source JSON | PRESENT | PRESENT |
| tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 | PRESENT | PRESENT |

COPILOT_SECTION: NOT-LISTED
- The `copilot` target's `sections` list holds `2-coverage-and-scenarios` and not `coverage-exclusion-policy`; the claude and codex targets list `coverage-exclusion-policy`.

FEATURE_REVIEW_OWNER: generated
- `claude:agent:feature-review` and `codex:agent:feature-review`: `disposition: generated`, `generator: harness-generation/agents`, `generated_from: scripts/harness-generation/sources/agents/feature-review.json`.

BRIEF_OWNER: generated
- `claude:skill:execution-environment`: `disposition: generated`, `generator: harness-generation/skills`, `generated_from: .agents/skills/execution-environment/SKILL.md`.
