# Policy and Scope Baseline

Timestamp: 2026-09-03T02-49

## Policy Order

- [x] `AGENTS.md`
- [x] `.agents/skills/general-code-change/SKILL.md`
- [x] `.agents/skills/general-unit-test/SKILL.md`
- [x] `.agents/skills/python/SKILL.md`
- [x] `.agents/skills/python-suppressions/SKILL.md`
- [x] `.agents/skills/typescript/SKILL.md`
- [x] `.agents/skills/typescript-suppressions/SKILL.md`
- [x] `.agents/skills/powershell/SKILL.md`
- [x] `.agents/skills/quality-tiers/SKILL.md`
- [x] `.agents/skills/architecture-boundaries/SKILL.md`
- [x] `.agents/skills/atomic-plan-contract/SKILL.md`
- [x] `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- [x] `.agents/skills/acceptance-criteria-tracking/SKILL.md`

## Binding Constraints

- Preserve the plan-of-record task IDs and execute them in exact order.
- Keep production, test, and reusable script files at or below 500 lines; raw text fixtures and Markdown documentation are exempt.
- Do not create or use temporary files in tests.
- Run the complete seven-stage QA sequence in order and restart at formatting if a stage fails or changes a governed file.
- Python and TypeScript lint/type suppressions require the policy-defined narrow authorization; no suppression is authorized by this remediation.
- Use the named PoshQC MCP tools for PowerShell formatting, analysis, and testing; omit `scan_folders` for the repository-wide test run.
- Keep line coverage at or above 85%; keep measured branch coverage at or above 75%; PowerShell branch coverage is exempt because Pester does not measure it.
- Preserve architecture boundaries and introduce zero unshipped `scripts.dev_tools` imports in TypeScript production code.
- Store all baseline, regression, and QA evidence only under the active feature's canonical `evidence/<kind>/` tree.
- Record `Timestamp`, exact `Command`, numeric `EXIT_CODE`, and `Output Summary` for command evidence. Record `ExpectedExitCode` for expected-failure evidence.
- Check an authoritative acceptance criterion only after direct passing evidence exists, preserve its text, and change only its checkbox marker.
- The implementation scope is limited to `.gitattributes` and the two TaskMaster #469 plan fixtures named in the plan; no production code, test code, fixture manifest, dependency, or setup/test hydration mechanism may change.

## [P0-T2] Immutable Comparison and Pre-Implementation Scope

Timestamp: 2026-09-03T02-49

Command: `git rev-parse HEAD`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
6230d7912e1ea6ab600609c11420caad74ffed6e
```

Command: `git rev-parse 9f3514bf5da84110f23617382cbbeabf54f27427`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
9f3514bf5da84110f23617382cbbeabf54f27427
```

Command: `git merge-base HEAD 9f3514bf5da84110f23617382cbbeabf54f27427`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
9f3514bf5da84110f23617382cbbeabf54f27427
```

Command: `git status --short --branch`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
## feature/portable-prepared-orchestration-handoff-614...origin/feature/portable-prepared-orchestration-handoff-614 [ahead 1]
 M docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md
 M docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-02T22-17.md
```

Command: `git status --porcelain=v1 --untracked-files=all`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
 M docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md
 M docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-02T22-17.md
?? docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-02T22-17.md
```

Command: `git diff --name-status`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
M	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md
M	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md
```

Command: `git diff --cached --name-status`

EXIT_CODE: 0

Output Summary: Command completed with no output.

Command: `git diff --name-status 9f3514bf5da84110f23617382cbbeabf54f27427...HEAD`

EXIT_CODE: 0

Output Summary: Command completed; exact output follows.

```text
M	.agents/skills/orchestrate/SKILL.md
M	.agents/skills/orchestrator-state/SKILL.md
M	.claude/skills/orchestrate/SKILL.md
M	.claude/skills/powershell-orchestration-state-machine/SKILL.md
M	.codex/hooks/enforce-epic-planning-only.ps1
A	config/orchestration-handoff-registry.json
A	config/orchestration-handoff.schema.json
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-08-31T17-20.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/baseline-summary.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/phase0-instructions-read.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/powershell-analyze.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/powershell-format.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/powershell-pester-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-black.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-pyright.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-pytest-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-ruff.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/target-surface-map.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-eslint.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-jest-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-prettier.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-tsc.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/worktree-status.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/issue-updates/issue-614.2026-08-31T08-02.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/progress-commit-001.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/progress-commit-002.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/progress-commit-003.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/remediation-ac-reopen.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/architecture-consumer-import-boundary.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/contract-schema-compatibility.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/integration-taskmaster-publishing.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-analyze.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-coverage-comparison.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-format.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-pester-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-black.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-coverage-comparison.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-pyright.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-pytest-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-ruff.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-acceptance-reconciliation.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-architecture-boundary.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-contract-schema-compatibility.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-final-policy-coverage-and-scope.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-integration-and-parity.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-powershell-analyze.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-powershell-format.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-powershell-pester-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-python-black.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-python-pyright.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-python-pytest-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-python-ruff.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-typescript-eslint.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-typescript-jest-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-typescript-prettier.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-typescript-tsc.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-coverage-comparison.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-eslint.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-jest-coverage.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-prettier.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-tsc.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/typescript-authority-containment.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/typescript-materializer-containment.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/phase0-instructions-read.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/powershell-pester-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/python-pytest-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-eslint.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-jest-coverage.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-prettier.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-tsc.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/worktree-and-scope.2026-09-02T20-55.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-08-31T17-20.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/issue.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-08-31T17-20.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-08-31T17-20.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-08-31T17-20.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/research/20260831-portable-prepared-orchestration-handoff-implementation-research.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md
A	docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md
A	docs/features/potential/promoted/2026-08-31-portable-prepared-orchestration-handoff.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-orchestration-state-machine/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
A	extensions/drm-copilot/resources/config/orchestration-handoff-registry.json
A	extensions/drm-copilot/resources/config/orchestration-handoff.schema.json
M	extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract-support.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-support.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-provider-adapters.ts
A	extensions/drm-copilot/src/lib/validate/orchestration-handoff-validation.ts
A	extensions/drm-copilot/src/lib/validate/semantic-mcp-identity.ts
A	extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts
A	extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts
M	extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
M	extensions/drm-copilot/src/mcp-tool-definitions.ts
M	extensions/drm-copilot/src/mcp-tools.ts
M	extensions/drm-copilot/src/repo-automation-service-contract.ts
M	extensions/drm-copilot/src/repo-automation-service.ts
M	extensions/drm-copilot/src/repo-automation-tool-names.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract-negative-coverage.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-path-boundary.test.ts
A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-provider-adapters.test.ts
A	extensions/drm-copilot/test/lib/validate/semantic-mcp-identity.test.ts
A	extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts
M	extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts
A	extensions/drm-copilot/test/mcp-server-test-service.ts
M	extensions/drm-copilot/test/mcp-server.test.ts
M	extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts
A	scripts/dev_tools/orchestration_handoff_adapters.py
A	scripts/dev_tools/orchestration_handoff_contract.py
A	scripts/dev_tools/orchestration_handoff_contract_support.py
M	scripts/dev_tools/push_down_codex_and_agents_customizations.py
M	scripts/dev_tools/validate_orchestrator_state.py
A	tests/fixtures/orchestration-handoff/contract/invalid-contract-cases.json
A	tests/fixtures/orchestration-handoff/contract/semantic-mcp-alias-cases.json
A	tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json
A	tests/fixtures/orchestration-handoff/contract/valid-parallel-codex-to-claude.json
A	tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json
A	tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
A	tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/source-checkpoint.json
A	tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json
A	tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
A	tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/source-checkpoint.json
M	tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
M	tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
M	tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
M	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
A	tests/scripts/dev_tools/orchestration_handoff_taskmaster_469_test_support.py
A	tests/scripts/dev_tools/push_down_handoff_test_support.py
A	tests/scripts/dev_tools/test_orchestration_handoff_adapters.py
A	tests/scripts/dev_tools/test_orchestration_handoff_contract.py
A	tests/scripts/dev_tools/test_orchestration_handoff_paths.py
A	tests/scripts/dev_tools/test_orchestration_handoff_provenance.py
A	tests/scripts/dev_tools/test_orchestration_handoff_schema.py
A	tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py
A	tests/scripts/dev_tools/test_orchestration_handoff_versions.py
M	tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
M	tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
M	tests/scripts/dev_tools/test_validate_orchestrator_state.py
A	tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py
A	tests/scripts/dev_tools/validate_orchestrator_state_test_support.py
```

### Working-tree classification

- `spec.md` and `user-story.md`: pre-existing unstaged requirement-marker changes created by the second review/remediation preparation; preserve until P2-T20 and P2-T21 perform the authorized evidence-backed closure.
- `code-review.2026-09-02T22-17.md`, `feature-audit.2026-09-02T22-17.md`, `policy-audit.2026-09-02T22-17.md`, `remediation-inputs.2026-09-02T22-17.md`, and `remediation-plan.2026-09-02T22-17.md`: pre-existing untracked second-review/remediation artifacts owned by the parent workflow; preserve.
- `evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md`: pre-existing untracked causal evidence owned by the second review; preserve.
- `evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md`: executor-created canonical evidence for P0-T1 and P0-T2.
- Index scope: empty before implementation; `git diff --cached --name-status` produced no paths.
- The base-to-HEAD diff is the already committed feature scope. It is not a current unstaged or staged mutation set and remains outside this remediation's implementation ownership.
- Implementation ownership remains exactly `.gitattributes` and the two TaskMaster #469 plan fixtures. No unrelated working-tree path is claimed or reverted.
