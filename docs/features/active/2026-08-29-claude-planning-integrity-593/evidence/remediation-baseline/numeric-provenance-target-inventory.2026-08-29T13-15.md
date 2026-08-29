Timestamp: 2026-08-29T13-37

## Contract owners

- `.claude/agents/task-researcher.md`: numeric-derivation research instruction at the research-process step.
- `.claude/skills/research-issue/SKILL.md`: numeric-derivation research-process instruction.
- `.claude/agents/prd-feature.md`: numeric-criterion approval instruction.
- `.claude/skills/fill-feature-docs/SKILL.md`: numeric-criterion input requirement.

## Validator owners

- `.claude/hooks/validate-task-researcher-output.ps1`: `Test-NumericDerivationEvidence` and `Invoke-TaskResearcherOutputValidation`.
- `.claude/hooks/validate-prd-feature-output.ps1`: `Test-NumericDerivationEvidence` and `Invoke-PrdFeatureOutputValidation`.

## Focused tests

- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`: `numeric derivation evidence` context.
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`: numeric provenance fixtures and invocation validation.
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`: `test_numeric_provenance_contract_requires_full_family_and_cross_check`.

## Scope boundary

Issue #586 preflight files are excluded. This remediation does not modify `.claude/hooks/validate-planner-output.ps1`, `.claude/agents/atomic-planner.md`, or `.claude/skills/atomic-plan-contract/SKILL.md`.
