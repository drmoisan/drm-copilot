# Phase 0 Upstream Re-check (P0-T1, rerun under plan revision 2.1)

Timestamp: 2026-11-18T07-50
Command: gh pr view 1199 --json number,state,baseRefName,mergedAt,headRefName; gh pr view 1203 --json number,state,baseRefName,mergedAt,headRefName; git fetch origin epic/shared-agent-harness-layer-integration main; sh SCRATCH/issue-1029-anc.sh (git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD); node SCRATCH/issue-1029-shared-set.cjs; node SCRATCH/issue-1029-s-list.cjs; node SCRATCH/issue-1029-child3.cjs; find extensions/drm-copilot/resources ( -name CLAUDE.md -o -name .mcp.json ); cmp .mcp.json extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json
EXIT_CODE: 0
Output Summary: #1025 (PR #1199) and #1028 (PR #1203) are merged into epic/shared-agent-harness-layer-integration, which is an ancestor of HEAD (ancestry exit 0). Schema `$id` and major match; the six fields resolve; 65 shared skills resolve. The shared set S under D15 with the D16 exceptions has 143 paths. The only code files in a shared skill's bundle folder are the three D16 entries; each is present in the Codex bundle, listed in Codex `core.json`, and its stated reason is confirmed against the file. No `.py` or `.ts` file is in a shared skill folder. `.mcp.json` has a Claude-layer source at `claude-dir-customizations/.mcp.json` (byte-identical to the repository root copy, the location `Get-HarnessBundlePath` assigns); `CLAUDE.md` is absent from every `resources/` folder. The earlier record (`phase0-upstream-recheck.2026-11-18T07-25.md`) stays unchanged.

Result: PASS

## Upstream merge state

| Child | Pull request | Merged into integration branch |
| --- | --- | --- |
| #1025 harness survey, contracts, parity matrix | #1199 | yes, MERGED, 2026-11-17T08:21:25Z |
| #1028 shared-source generators | #1203 | yes, MERGED, 2026-11-18T07:09:59Z |

Ancestry: `git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD` exited 0 (HEAD is the integration tip plus the three plan-revision documentation commits).

## Assumption re-check (spec `## Upstream Dependencies and Phase 0 Gate`, amendment A-1)

| Assumption | Observed | Status |
| --- | --- | --- |
| Matrix and schema files exist | `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` present | match |
| Schema `$id` and `schema_version` major 1 | unchanged since the 07-25 record; matrix keys `$schema`, `schema_version`, `features` | match |
| Fields `ecosystem`, `kind`, `name`, `disposition`, `target_paths`, `generated_from` | resolve on the entries used | match |
| Shared-skill set (`kind` `skill`, `ecosystem` `codex`, `disposition` `shared`) | 65 skills, each with a bundle folder | match |
| Shared-skill bundle copies byte-identical | no `DIFF REPO COPY` or `NO REPO COPY` line from the check | match |
| Shared configuration paths and `AGENTS.md` bundle copy | present (D2) | match |
| D16 assumption: no `.py` or `.ts` in a shared skill folder; every `.ps1`, `.psm1` or `.sh` either has dependencies inside S or is a D16 entry | code files found: exactly the three D16 paths; no `.py`, `.ts` or `.psm1` | match |
| `.mcp.json` bundle location named by child 3 | `Get-HarnessBundlePath` maps `.mcp.json` to `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`; the file is present and byte-identical to the root `.mcp.json` (cmp exit 0) | match |

## D16 entries

| Path | In Codex bundle | Listed in Codex `core.json` | Reason confirmed against the file |
| --- | --- | --- | --- |
| `.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1` | yes | yes | imports `scripts/powershell/PoshQC/PoshQC.psd1` (repository PoshQC module) and states it runs only through the launcher |
| `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | yes | yes | loads its helpers from `.claude/hooks`, else `.codex/hooks`, and reads `config/test-execution-policy.json`; none is in S |
| `.agents/skills/test-execution-policy/scripts/run-test-suite.sh` | yes | yes | runs the sibling `Invoke-TestSuite.ps1` with PowerShell 7 |

## Other code files in shared skill bundle folders

none (the scan found no `.ps1`, `.psm1`, `.sh`, `.py` or `.ts` file other than the three D16 entries).

## Claude-layer root files

Searched under every folder of `extensions/drm-copilot/resources/`, including `claude-dir-customizations/`.

- `CLAUDE.md`: absent
- `.mcp.json`: `claude-dir-customizations/.mcp.json` (resources-relative source); destination `.mcp.json`

## Child 3 files that no manifest lists, per bundle

- claude: `.mcp.json` (source `claude-dir-customizations/.mcp.json`; no Claude pack manifest lists it). No `.claude/` path is unlisted.
- codex: `.agents/skills/architecture-boundaries/SKILL.md`, `.agents/skills/benchmark-baselines/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, `.agents/skills/self-explanatory-code-commenting/SKILL.md`, `.agents/skills/tonality/SKILL.md`, `.codex/agents/epic-review.toml`, `.codex/agents/feature-review.toml`, `.codex/agents/staged-review.toml`, `.codex/agents/status-updater.toml`, `AGENTS.md` (`AGENTS.md` goes to `shared.json` under D15).
- copilot: 68 files (50 under `.github/agents/`, 18 under `.github/instructions/`); the Copilot bundle has no pack manifests yet, and P2-T1 creates them.
- Generated or shared target paths with no bundle copy (outside S under D15): `.agents/skills/` `SKILL.md` of `cleanup-merged-worktrees`, `epic-progress-report`, `mermaid-diagram`, `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-plan`, `parallel-remove`, `parallel-run` (Claude-only shared entries whose `.agents` copy is not in the tree).

## Resolved shared set S (D15 with D16), code-point order

143 paths.

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
