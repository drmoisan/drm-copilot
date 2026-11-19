# Phase 0 Upstream Re-check (P0-T1)

Timestamp: 2026-11-18T07-25
Command: gh pr list --state merged --base epic/shared-agent-harness-layer-integration --json number,title,headRefName,mergedAt,mergeCommit; git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD; node SCRATCH/issue-1029-shared-set.cjs; node SCRATCH/issue-1029-child3.cjs
EXIT_CODE: 0
Output Summary: #1025 (PR #1199) and #1028 (PR #1203) are merged into epic/shared-agent-harness-layer-integration, which is an ancestor of HEAD (HEAD equals the integration tip). The schema `$id` and major version match, and the six fields and the shared set resolve. One assumption fails: the shared skill `test-execution-policy` carries code files in its bundle folder, and `scripts/Invoke-TestSuite.ps1` loads its helpers from `.claude/hooks` or `.codex/hooks` at run time.

Result: BLOCKED

## Upstream merge state

| Child | Pull request | Merged into integration branch |
| --- | --- | --- |
| #1025 harness survey, contracts, parity matrix | #1199 | yes, 2026-11-17T08:21:25Z |
| #1028 shared-source generators | #1203 | yes, 2026-11-18T07:09:59Z |

Ancestry: `git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD` exited 0.

## Assumption re-check (spec `## Upstream Dependencies and Phase 0 Gate`)

| Assumption | Observed | Status |
| --- | --- | --- |
| Matrix `config/harness-parity-matrix.json` and schema `config/harness-parity-matrix.schema.json` exist | both present | match |
| Schema `$id` `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`, `schema_version` major 1 | `$id` identical; matrix `schema_version` `1.0.0` | match |
| Fields `ecosystem`, `kind`, `name`, `disposition`, `target_paths`, `generated_from` | first four required on every entry; the schema requires `target_paths` for `shared` and `generated` and `generated_from` for `generated`; the entries that omit them are entries where the schema allows the omission | match |
| Shared-skill set (`kind` `skill`, `ecosystem` `codex`, `disposition` `shared`) | 65 skills, each with a bundle folder under `codex-and-agents-customizations/.agents/skills/` | match |
| `references/standard.md` per shared skill with a byte-identical bundle copy | present for all 65; every shared-skill bundle file is byte-identical to its repository copy | match |
| Shared configuration paths | `config/orchestration-routing.json`, `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json` are byte-identical under `resources/config/` and delivered through `VIRTUAL_RESOURCE_PAIRS` (D2) | match |
| `AGENTS.md` bundle copy at `codex-and-agents-customizations/AGENTS.md` | present, byte-identical | match |
| No `.ps1`, `.psm1`, `.py` or `.ts` file in a shared skill's bundle folder | `.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1` and `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` (plus the bash launcher `scripts/run-test-suite.sh`). `Invoke-TestSuite.ps1` dot-sources `test-execution-policy.ps1`, `test-execution-lock-decision.ps1` and `test-execution-lock.ps1` from `.claude/hooks` or `.codex/hooks`, which are ecosystem-layer files, and reads `config/test-execution-policy.json`, which is not in S | **MISMATCH** |
| Child 3 names a `.mcp.json` bundle location | no `.mcp.json` exists under any bundle; matrix entry `claude:mcp-server:drm-copilot` targets the repository-root `.mcp.json` only | recorded; the plan handles `absent` |
| Child 3 generated paths and bundle locations | 311 `generated` or `shared` target paths; 10 have no bundle copy: nine `claude:skill:*` entries with disposition `shared` whose `.agents/skills/<name>/SKILL.md` is not in the tree (`cleanup-merged-worktrees`, `epic-progress-report`, `mermaid-diagram`, `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-plan`, `parallel-remove`, `parallel-run`), and `.mcp.json` | recorded; outside S under D15 |

## Claude-bundle root files

- `CLAUDE.md`: absent
- `.mcp.json`: absent

## Child 3 files that no manifest lists, per bundle

- claude: none
- codex: `.agents/skills/architecture-boundaries/SKILL.md`, `.agents/skills/benchmark-baselines/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, `.agents/skills/self-explanatory-code-commenting/SKILL.md`, `.agents/skills/tonality/SKILL.md`, `.codex/agents/epic-review.toml`, `.codex/agents/feature-review.toml`, `.codex/agents/staged-review.toml`, `.codex/agents/status-updater.toml`, `AGENTS.md`
- copilot: 68 files (50 under `.github/agents/`, 18 under `.github/instructions/`); the Copilot bundle has no pack manifests yet, and P2-T1 creates them.

## Resolved shared set S (D15), 146 paths, code-point order

```text
.agents/skills/acceptance-criteria-tracking/SKILL.md
.agents/skills/acceptance-criteria-tracking/references/standard.md
.agents/skills/adjudicate-unspecified-behavior/SKILL.md
.agents/skills/adjudicate-unspecified-behavior/references/standard.md
.agents/skills/atomic-plan-contract/SKILL.md
.agents/skills/atomic-plan-contract/references/standard.md
.agents/skills/characterize-runtime-behavior/SKILL.md
.agents/skills/characterize-runtime-behavior/references/standard.md
.agents/skills/commit-message/SKILL.md
.agents/skills/commit-message/references/standard.md
.agents/skills/csharp-change-budget-router/SKILL.md
.agents/skills/csharp-change-budget-router/references/standard.md
.agents/skills/csharp-orchestration-state-machine/SKILL.md
.agents/skills/csharp-orchestration-state-machine/references/standard.md
.agents/skills/csharp-qa-gate/SKILL.md
.agents/skills/csharp-qa-gate/references/standard.md
.agents/skills/discovery-behavior-reconciliation/SKILL.md
.agents/skills/discovery-behavior-reconciliation/references/standard.md
.agents/skills/discovery-coverage-ledger/SKILL.md
.agents/skills/discovery-coverage-ledger/references/standard.md
.agents/skills/discovery-parity-matrix/SKILL.md
.agents/skills/discovery-parity-matrix/references/standard.md
.agents/skills/discovery-repo-inventory/SKILL.md
.agents/skills/discovery-repo-inventory/references/standard.md
.agents/skills/discovery-runtime-characterization/SKILL.md
.agents/skills/discovery-runtime-characterization/references/standard.md
.agents/skills/discovery-validate-artifacts/SKILL.md
.agents/skills/discovery-validate-artifacts/references/standard.md
.agents/skills/discovery-workflow/SKILL.md
.agents/skills/discovery-workflow/references/standard.md
.agents/skills/docs-author-page/SKILL.md
.agents/skills/docs-author-page/references/standard.md
.agents/skills/docs-author-page/templates/api-reference.md
.agents/skills/docs-author-page/templates/architecture-overview.md
.agents/skills/docs-author-page/templates/cli-reference.md
.agents/skills/docs-author-page/templates/config-reference.md
.agents/skills/docs-author-page/templates/explanation.md
.agents/skills/docs-author-page/templates/how-to.md
.agents/skills/docs-author-page/templates/http-reference.md
.agents/skills/docs-author-page/templates/tutorial.md
.agents/skills/docs-init/SKILL.md
.agents/skills/docs-init/references/standard.md
.agents/skills/docs-inventory-surface/SKILL.md
.agents/skills/docs-inventory-surface/references/standard.md
.agents/skills/docs-plan-ia/SKILL.md
.agents/skills/docs-plan-ia/references/standard.md
.agents/skills/docs-reconcile-behavior/SKILL.md
.agents/skills/docs-reconcile-behavior/references/standard.md
.agents/skills/docs-review-coverage/SKILL.md
.agents/skills/docs-review-coverage/references/standard.md
.agents/skills/docs-validate/SKILL.md
.agents/skills/docs-validate/references/standard.md
.agents/skills/documentation-workflow/SKILL.md
.agents/skills/documentation-workflow/references/standard.md
.agents/skills/epic-orchestrate/SKILL.md
.agents/skills/epic-orchestrate/references/standard.md
.agents/skills/epic-plan/SKILL.md
.agents/skills/epic-plan/references/standard.md
.agents/skills/epic-run/SKILL.md
.agents/skills/epic-run/references/standard.md
.agents/skills/evidence-and-timestamp-conventions/SKILL.md
.agents/skills/evidence-and-timestamp-conventions/references/standard.md
.agents/skills/execute-hard-lock/SKILL.md
.agents/skills/execute-hard-lock/references/standard.md
.agents/skills/execution-environment/SKILL.md
.agents/skills/execution-environment/references/standard.md
.agents/skills/extract-feature-contract/SKILL.md
.agents/skills/extract-feature-contract/references/standard.md
.agents/skills/feature-promotion-lifecycle/SKILL.md
.agents/skills/feature-promotion-lifecycle/references/standard.md
.agents/skills/feature-review-workflow/SKILL.md
.agents/skills/feature-review-workflow/references/standard.md
.agents/skills/fill-feature-docs/SKILL.md
.agents/skills/fill-feature-docs/references/standard.md
.agents/skills/generate-acceptance-scenarios/SKILL.md
.agents/skills/generate-acceptance-scenarios/references/standard.md
.agents/skills/human-exception-runbook/SKILL.md
.agents/skills/human-exception-runbook/example.runbook.md
.agents/skills/human-exception-runbook/references/standard.md
.agents/skills/initialize-discovery-workspace/SKILL.md
.agents/skills/initialize-discovery-workspace/references/standard.md
.agents/skills/inventory-legacy-system/SKILL.md
.agents/skills/inventory-legacy-system/references/standard.md
.agents/skills/invoke-csharp-engineer/SKILL.md
.agents/skills/invoke-csharp-engineer/references/standard.md
.agents/skills/invoke-powershell-engineer/SKILL.md
.agents/skills/invoke-powershell-engineer/references/standard.md
.agents/skills/invoke-python-engineer/SKILL.md
.agents/skills/invoke-python-engineer/references/standard.md
.agents/skills/make-skill-template/SKILL.md
.agents/skills/make-skill-template/references/standard.md
.agents/skills/orchestrate/SKILL.md
.agents/skills/orchestrate/references/standard.md
.agents/skills/owner-directives/SKILL.md
.agents/skills/owner-directives/references/standard.md
.agents/skills/policy-audit-template-usage/SKILL.md
.agents/skills/policy-audit-template-usage/references/standard.md
.agents/skills/policy-compliance-order/SKILL.md
.agents/skills/policy-compliance-order/references/standard.md
.agents/skills/powershell-change-budget-router/SKILL.md
.agents/skills/powershell-change-budget-router/references/standard.md
.agents/skills/powershell-orchestration-state-machine/SKILL.md
.agents/skills/powershell-orchestration-state-machine/references/standard.md
.agents/skills/powershell-qa-gate/SKILL.md
.agents/skills/powershell-qa-gate/references/standard.md
.agents/skills/pr-author/SKILL.md
.agents/skills/pr-author/references/standard.md
.agents/skills/pr-base-branch-merge-base/SKILL.md
.agents/skills/pr-base-branch-merge-base/references/standard.md
.agents/skills/pr-context-artifacts/SKILL.md
.agents/skills/pr-context-artifacts/references/standard.md
.agents/skills/python-change-budget-router/SKILL.md
.agents/skills/python-change-budget-router/references/standard.md
.agents/skills/python-qa-gate/SKILL.md
.agents/skills/python-qa-gate/references/standard.md
.agents/skills/reconcile-parity-matrix/SKILL.md
.agents/skills/reconcile-parity-matrix/references/standard.md
.agents/skills/remediation-handoff-atomic-planner/SKILL.md
.agents/skills/remediation-handoff-atomic-planner/references/standard.md
.agents/skills/research-issue/SKILL.md
.agents/skills/research-issue/references/standard.md
.agents/skills/review-discovery-coverage/SKILL.md
.agents/skills/review-discovery-coverage/references/standard.md
.agents/skills/review-epic/SKILL.md
.agents/skills/review-epic/references/standard.md
.agents/skills/review-feature/SKILL.md
.agents/skills/review-feature/references/standard.md
.agents/skills/review-staged/SKILL.md
.agents/skills/review-staged/references/standard.md
.agents/skills/skill-canonical-location-audit/SKILL.md
.agents/skills/skill-canonical-location-audit/references/standard.md
.agents/skills/test-execution-policy/SKILL.md
.agents/skills/test-execution-policy/references/standard.md
.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1
.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1
.agents/skills/test-execution-policy/scripts/run-test-suite.sh
.agents/skills/translate-copilot-to-claude/SKILL.md
.agents/skills/translate-copilot-to-claude/references/standard.md
.agents/skills/update-status/SKILL.md
.agents/skills/update-status/references/standard.md
.agents/skills/validate-discovery-artifacts/SKILL.md
.agents/skills/validate-discovery-artifacts/references/standard.md
AGENTS.md
config/orchestration-handoff-registry.json
config/orchestration-handoff.schema.json
config/orchestration-routing.json
```

## Why the mismatch blocks

Under D15 and D1 the three `test-execution-policy/scripts/` files belong to S, so the shared layer installs them on every run, including a Copilot-only run. A Copilot-only destination has neither `.claude/hooks` nor `.codex/hooks`, and S does not contain `config/test-execution-policy.json`, so the launcher would exit 2 with `TEST_EXECUTION_POLICY_BLOCKED:` there. No plan task assigns these files outside S, records them as a shared-layer exception, or tests the dependency. The plan's acceptance rule for this gate is that any mismatch gives `Result: BLOCKED`, and the delegation brief directs a stop for one plan revision.
