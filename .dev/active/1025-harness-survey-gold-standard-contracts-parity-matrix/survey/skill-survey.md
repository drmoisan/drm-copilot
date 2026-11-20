# Skill Survey Index (Issue #1025)

One row per skill folder name in the union of `.claude/skills`, `.agents/skills` and `.github/skills` (folders that hold `SKILL.md`). Identity classes come from the latest `evidence/baseline/skill-identity.*.md`; batches follow plan `## Definitions`.

| Skill | Claude | Codex | Copilot | Identity | Proposed disposition | Batch | Record |
| --- | --- | --- | --- | --- | --- | --- | --- |
| acceptance-criteria-tracking | yes | yes | yes | wording-only | shared | B | [acceptance-criteria-tracking](batch-b-foundation-and-policy.md#acceptance-criteria-tracking) |
| adjudicate-unspecified-behavior | yes | yes | yes | wording-only | shared | A | [adjudicate-unspecified-behavior](batch-a-discovery.md#adjudicate-unspecified-behavior) |
| architecture-boundaries | no | yes | no | single-ecosystem | native (approved) | single | [architecture-boundaries](single-ecosystem.md#architecture-boundaries) |
| atomic-executor | no | yes | no | single-ecosystem | native (approved) | single | [atomic-executor](single-ecosystem.md#atomic-executor) |
| atomic-plan-contract | yes | yes | yes | substantive | shared | B | [atomic-plan-contract](batch-b-foundation-and-policy.md#atomic-plan-contract) |
| atomic-planner | no | yes | no | single-ecosystem | native (approved) | single | [atomic-planner](single-ecosystem.md#atomic-planner) |
| bash-command-shape | no | yes | no | single-ecosystem | native (approved) | single | [bash-command-shape](single-ecosystem.md#bash-command-shape) |
| benchmark-baselines | no | yes | no | single-ecosystem | native (approved) | single | [benchmark-baselines](single-ecosystem.md#benchmark-baselines) |
| characterize-runtime-behavior | yes | yes | yes | wording-only | shared | A | [characterize-runtime-behavior](batch-a-discovery.md#characterize-runtime-behavior) |
| ci-workflows | no | yes | no | single-ecosystem | native (approved) | single | [ci-workflows](single-ecosystem.md#ci-workflows) |
| cleanup-merged-worktrees | yes | no | no | single-ecosystem | shared (approved) | single | [cleanup-merged-worktrees](single-ecosystem.md#cleanup-merged-worktrees) |
| codex-model-routing | no | yes | no | single-ecosystem | native (approved) | single | [codex-model-routing](single-ecosystem.md#codex-model-routing) |
| commit-message | yes | yes | no | substantive | shared | F | [commit-message](batch-f-authoring-and-review-wrappers.md#commit-message) |
| commit-message-conventions | no | yes | no | single-ecosystem | native (approved) | single | [commit-message-conventions](single-ecosystem.md#commit-message-conventions) |
| csharp | no | yes | no | single-ecosystem | native (approved) | single | [csharp](single-ecosystem.md#csharp) |
| csharp-change-budget-router | yes | yes | yes | substantive | shared | D | [csharp-change-budget-router](batch-d-language-routing-and-gates.md#csharp-change-budget-router) |
| csharp-orchestration-state-machine | yes | yes | yes | wording-only | shared | D | [csharp-orchestration-state-machine](batch-d-language-routing-and-gates.md#csharp-orchestration-state-machine) |
| csharp-qa-gate | yes | yes | no | substantive | shared | D | [csharp-qa-gate](batch-d-language-routing-and-gates.md#csharp-qa-gate) |
| discovery-behavior-reconciliation | yes | yes | yes | byte-identical | shared | A | [discovery-behavior-reconciliation](batch-a-discovery.md#discovery-behavior-reconciliation) |
| discovery-coverage-ledger | yes | yes | yes | byte-identical | shared | A | [discovery-coverage-ledger](batch-a-discovery.md#discovery-coverage-ledger) |
| discovery-parity-matrix | yes | yes | yes | byte-identical | shared | A | [discovery-parity-matrix](batch-a-discovery.md#discovery-parity-matrix) |
| discovery-repo-inventory | yes | yes | yes | byte-identical | shared | A | [discovery-repo-inventory](batch-a-discovery.md#discovery-repo-inventory) |
| discovery-runtime-characterization | yes | yes | yes | byte-identical | shared | A | [discovery-runtime-characterization](batch-a-discovery.md#discovery-runtime-characterization) |
| discovery-validate-artifacts | yes | yes | yes | byte-identical | shared | A | [discovery-validate-artifacts](batch-a-discovery.md#discovery-validate-artifacts) |
| discovery-workflow | yes | yes | yes | byte-identical | shared | A | [discovery-workflow](batch-a-discovery.md#discovery-workflow) |
| docs-author-page | yes | yes | yes | wording-only | shared | F | [docs-author-page](batch-f-authoring-and-review-wrappers.md#docs-author-page) |
| docs-init | yes | yes | yes | wording-only | shared | F | [docs-init](batch-f-authoring-and-review-wrappers.md#docs-init) |
| docs-inventory-surface | yes | yes | yes | substantive | shared | F | [docs-inventory-surface](batch-f-authoring-and-review-wrappers.md#docs-inventory-surface) |
| docs-plan-ia | yes | yes | yes | wording-only | shared | F | [docs-plan-ia](batch-f-authoring-and-review-wrappers.md#docs-plan-ia) |
| docs-reconcile-behavior | yes | yes | yes | wording-only | shared | F | [docs-reconcile-behavior](batch-f-authoring-and-review-wrappers.md#docs-reconcile-behavior) |
| docs-review-coverage | yes | yes | yes | substantive | shared | F | [docs-review-coverage](batch-f-authoring-and-review-wrappers.md#docs-review-coverage) |
| docs-validate | yes | yes | yes | substantive | shared | F | [docs-validate](batch-f-authoring-and-review-wrappers.md#docs-validate) |
| documentation-workflow | yes | yes | yes | wording-only | shared | F | [documentation-workflow](batch-f-authoring-and-review-wrappers.md#documentation-workflow) |
| epic-orchestrate | yes | yes | no | substantive | shared | E | [epic-orchestrate](batch-e-orchestration.md#epic-orchestrate) |
| epic-plan | yes | yes | no | substantive | shared | E | [epic-plan](batch-e-orchestration.md#epic-plan) |
| epic-progress-report | yes | no | no | single-ecosystem | shared (approved) | single | [epic-progress-report](single-ecosystem.md#epic-progress-report) |
| epic-run | yes | yes | no | substantive | shared | E | [epic-run](batch-e-orchestration.md#epic-run) |
| evidence-and-timestamp-conventions | yes | yes | yes | substantive | shared | B | [evidence-and-timestamp-conventions](batch-b-foundation-and-policy.md#evidence-and-timestamp-conventions) |
| execute-hard-lock | yes | yes | no | substantive | shared | E | [execute-hard-lock](batch-e-orchestration.md#execute-hard-lock) |
| execution-environment | yes | yes | yes | byte-identical | shared | B | [execution-environment](batch-b-foundation-and-policy.md#execution-environment) |
| extract-feature-contract | yes | yes | yes | wording-only | shared | A | [extract-feature-contract](batch-a-discovery.md#extract-feature-contract) |
| feature-promotion-lifecycle | yes | yes | yes | substantive | shared | C | [feature-promotion-lifecycle](batch-c-integration.md#feature-promotion-lifecycle) |
| feature-review | no | yes | no | single-ecosystem | native (approved) | single | [feature-review](single-ecosystem.md#feature-review) |
| feature-review-workflow | yes | yes | yes | substantive | shared | C | [feature-review-workflow](batch-c-integration.md#feature-review-workflow) |
| fill-feature-docs | yes | yes | no | wording-only | shared | F | [fill-feature-docs](batch-f-authoring-and-review-wrappers.md#fill-feature-docs) |
| general-code-change | no | yes | no | single-ecosystem | native (approved) | single | [general-code-change](single-ecosystem.md#general-code-change) |
| general-unit-test | no | yes | no | single-ecosystem | native (approved) | single | [general-unit-test](single-ecosystem.md#general-unit-test) |
| generate-acceptance-scenarios | yes | yes | yes | wording-only | shared | A | [generate-acceptance-scenarios](batch-a-discovery.md#generate-acceptance-scenarios) |
| human-exception-runbook | yes | yes | no | wording-only | shared | E | [human-exception-runbook](batch-e-orchestration.md#human-exception-runbook) |
| identify-session-id | yes | no | no | single-ecosystem | native (approved) | single | [identify-session-id](single-ecosystem.md#identify-session-id) |
| initialize-discovery-workspace | yes | yes | yes | wording-only | shared | A | [initialize-discovery-workspace](batch-a-discovery.md#initialize-discovery-workspace) |
| inventory-legacy-system | yes | yes | yes | wording-only | shared | A | [inventory-legacy-system](batch-a-discovery.md#inventory-legacy-system) |
| invoke-csharp-engineer | yes | yes | no | substantive | shared | D | [invoke-csharp-engineer](batch-d-language-routing-and-gates.md#invoke-csharp-engineer) |
| invoke-powershell-engineer | yes | yes | no | substantive | shared | D | [invoke-powershell-engineer](batch-d-language-routing-and-gates.md#invoke-powershell-engineer) |
| invoke-python-engineer | yes | yes | no | substantive | shared | D | [invoke-python-engineer](batch-d-language-routing-and-gates.md#invoke-python-engineer) |
| make-skill-template | yes | yes | yes | wording-only | shared | B | [make-skill-template](batch-b-foundation-and-policy.md#make-skill-template) |
| mermaid-diagram | yes | no | no | single-ecosystem | shared (approved) | single | [mermaid-diagram](single-ecosystem.md#mermaid-diagram) |
| orchestrate | yes | yes | no | substantive | shared | E | [orchestrate](batch-e-orchestration.md#orchestrate) |
| orchestrator-state | no | yes | no | single-ecosystem | native (approved) | single | [orchestrator-state](single-ecosystem.md#orchestrator-state) |
| orchestrator-workflow | no | yes | no | single-ecosystem | native (approved) | single | [orchestrator-workflow](single-ecosystem.md#orchestrator-workflow) |
| owner-directives | yes | yes | yes | byte-identical | shared | E | [owner-directives](batch-e-orchestration.md#owner-directives) |
| parallel-add | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-add](single-ecosystem.md#parallel-add) |
| parallel-close | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-close](single-ecosystem.md#parallel-close) |
| parallel-orchestrate | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-orchestrate](single-ecosystem.md#parallel-orchestrate) |
| parallel-plan | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-plan](single-ecosystem.md#parallel-plan) |
| parallel-remove | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-remove](single-ecosystem.md#parallel-remove) |
| parallel-run | yes | no | no | single-ecosystem | shared (approved) | single | [parallel-run](single-ecosystem.md#parallel-run) |
| policy-audit-template-usage | yes | yes | yes | substantive | shared | B | [policy-audit-template-usage](batch-b-foundation-and-policy.md#policy-audit-template-usage) |
| policy-compliance-order | yes | yes | yes | substantive | shared | B | [policy-compliance-order](batch-b-foundation-and-policy.md#policy-compliance-order) |
| powershell | no | yes | no | single-ecosystem | native (approved) | single | [powershell](single-ecosystem.md#powershell) |
| powershell-change-budget-router | yes | yes | yes | substantive | shared | D | [powershell-change-budget-router](batch-d-language-routing-and-gates.md#powershell-change-budget-router) |
| powershell-orchestration-state-machine | yes | yes | yes | substantive | shared | D | [powershell-orchestration-state-machine](batch-d-language-routing-and-gates.md#powershell-orchestration-state-machine) |
| powershell-qa-gate | yes | yes | no | wording-only | shared | D | [powershell-qa-gate](batch-d-language-routing-and-gates.md#powershell-qa-gate) |
| pr-author | yes | yes | no | substantive | shared | F | [pr-author](batch-f-authoring-and-review-wrappers.md#pr-author) |
| pr-authoring | no | yes | no | single-ecosystem | native (approved) | single | [pr-authoring](single-ecosystem.md#pr-authoring) |
| pr-base-branch-merge-base | yes | yes | yes | substantive | shared | C | [pr-base-branch-merge-base](batch-c-integration.md#pr-base-branch-merge-base) |
| pr-context-artifacts | yes | yes | yes | wording-only | shared | C | [pr-context-artifacts](batch-c-integration.md#pr-context-artifacts) |
| python | no | yes | no | single-ecosystem | native (approved) | single | [python](single-ecosystem.md#python) |
| python-change-budget-router | yes | yes | no | substantive | shared | D | [python-change-budget-router](batch-d-language-routing-and-gates.md#python-change-budget-router) |
| python-qa-gate | yes | yes | no | wording-only | shared | D | [python-qa-gate](batch-d-language-routing-and-gates.md#python-qa-gate) |
| python-suppressions | no | yes | no | single-ecosystem | native (approved) | single | [python-suppressions](single-ecosystem.md#python-suppressions) |
| quality-tiers | no | yes | no | single-ecosystem | native (approved) | single | [quality-tiers](single-ecosystem.md#quality-tiers) |
| quota-throttling | yes | no | no | single-ecosystem | native (approved) | single | [quota-throttling](single-ecosystem.md#quota-throttling) |
| reconcile-parity-matrix | yes | yes | yes | wording-only | shared | A | [reconcile-parity-matrix](batch-a-discovery.md#reconcile-parity-matrix) |
| remediation-handoff-atomic-planner | yes | yes | yes | substantive | shared | C | [remediation-handoff-atomic-planner](batch-c-integration.md#remediation-handoff-atomic-planner) |
| repo-automation-adapter | no | yes | no | single-ecosystem | native (approved) | single | [repo-automation-adapter](single-ecosystem.md#repo-automation-adapter) |
| research-issue | yes | yes | no | substantive | shared | F | [research-issue](batch-f-authoring-and-review-wrappers.md#research-issue) |
| review-discovery-coverage | yes | yes | yes | wording-only | shared | A | [review-discovery-coverage](batch-a-discovery.md#review-discovery-coverage) |
| review-epic | yes | yes | no | byte-identical | shared | F | [review-epic](batch-f-authoring-and-review-wrappers.md#review-epic) |
| review-feature | yes | yes | no | byte-identical | shared | F | [review-feature](batch-f-authoring-and-review-wrappers.md#review-feature) |
| review-staged | yes | yes | no | byte-identical | shared | F | [review-staged](batch-f-authoring-and-review-wrappers.md#review-staged) |
| self-explanatory-code-commenting | no | yes | no | single-ecosystem | native (approved) | single | [self-explanatory-code-commenting](single-ecosystem.md#self-explanatory-code-commenting) |
| show-my-agent-tree | yes | no | no | single-ecosystem | native (approved) | single | [show-my-agent-tree](single-ecosystem.md#show-my-agent-tree) |
| skill-canonical-location-audit | yes | yes | yes | wording-only | shared | B | [skill-canonical-location-audit](batch-b-foundation-and-policy.md#skill-canonical-location-audit) |
| test-execution-policy | yes | yes | yes | byte-identical | shared | B | [test-execution-policy](batch-b-foundation-and-policy.md#test-execution-policy) |
| tonality | no | yes | no | single-ecosystem | native (approved) | single | [tonality](single-ecosystem.md#tonality) |
| translate-claude-to-codex | no | yes | no | single-ecosystem | native (approved) | single | [translate-claude-to-codex](single-ecosystem.md#translate-claude-to-codex) |
| translate-copilot-to-claude | yes | yes | no | substantive | shared | F | [translate-copilot-to-claude](batch-f-authoring-and-review-wrappers.md#translate-copilot-to-claude) |
| typescript | no | yes | no | single-ecosystem | native (approved) | single | [typescript](single-ecosystem.md#typescript) |
| typescript-suppressions | no | yes | no | single-ecosystem | native (approved) | single | [typescript-suppressions](single-ecosystem.md#typescript-suppressions) |
| update-status | yes | yes | no | byte-identical | shared | F | [update-status](batch-f-authoring-and-review-wrappers.md#update-status) |
| validate-discovery-artifacts | yes | yes | yes | wording-only | shared | A | [validate-discovery-artifacts](batch-a-discovery.md#validate-discovery-artifacts) |
