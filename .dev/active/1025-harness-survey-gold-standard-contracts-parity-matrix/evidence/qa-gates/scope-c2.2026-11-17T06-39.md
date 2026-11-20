# Scope Check — Remediation Cycle 2 (Issue 1025, [P2-T5])

Timestamp: 2026-11-17T06-39
Command: `git diff --name-only 5bb41dc645b24aa0b19f3f6fd811fb087b1e018e` (the `Head:` of the newest `cycle-2-contract-text.*.md`, `cycle-2-contract-text.2026-11-17T04-47.md`) together with `git status --porcelain` (both through `sh SCRATCH/issue-1025-scope.sh`)
EXIT_CODE: 0
Output Summary: DIFF_COUNT=100 PORCELAIN_COUNT=5 PATHS=104 BASE_CONTRACTS=43 TWIN_MISSING=0 OUT_OF_SCOPE=0 FORBIDDEN=0 

## Classification

- Every listed path is a `references/standard.md` under `.agents/skills/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, a file under `<FEATURE>/evidence/`, or this plan file (`OUT_OF_SCOPE=0`).
- Every changed base contract (43) has its twin listed (`TWIN_MISSING=0`).
- No `SKILL.md`, survey, matrix, schema, module, test, spec, user-story or remediation-inputs path is listed (`FORBIDDEN=0`).
- The porcelain entries are the uncommitted Phase 2 evidence files and the plan check-off edits; the owner-directive decision file is under the gitignored `artifacts/` tree and is not listed.

## Output

```text
--- git diff --name-only 5bb41dc645b24aa0b19f3f6fd811fb087b1e018e
.agents/skills/acceptance-criteria-tracking/references/standard.md
.agents/skills/adjudicate-unspecified-behavior/references/standard.md
.agents/skills/atomic-plan-contract/references/standard.md
.agents/skills/characterize-runtime-behavior/references/standard.md
.agents/skills/commit-message/references/standard.md
.agents/skills/csharp-change-budget-router/references/standard.md
.agents/skills/csharp-orchestration-state-machine/references/standard.md
.agents/skills/csharp-qa-gate/references/standard.md
.agents/skills/epic-plan/references/standard.md
.agents/skills/evidence-and-timestamp-conventions/references/standard.md
.agents/skills/execute-hard-lock/references/standard.md
.agents/skills/extract-feature-contract/references/standard.md
.agents/skills/feature-promotion-lifecycle/references/standard.md
.agents/skills/feature-review-workflow/references/standard.md
.agents/skills/fill-feature-docs/references/standard.md
.agents/skills/generate-acceptance-scenarios/references/standard.md
.agents/skills/human-exception-runbook/references/standard.md
.agents/skills/initialize-discovery-workspace/references/standard.md
.agents/skills/inventory-legacy-system/references/standard.md
.agents/skills/invoke-csharp-engineer/references/standard.md
.agents/skills/invoke-powershell-engineer/references/standard.md
.agents/skills/invoke-python-engineer/references/standard.md
.agents/skills/make-skill-template/references/standard.md
.agents/skills/orchestrate/references/standard.md
.agents/skills/owner-directives/references/standard.md
.agents/skills/policy-audit-template-usage/references/standard.md
.agents/skills/policy-compliance-order/references/standard.md
.agents/skills/powershell-change-budget-router/references/standard.md
.agents/skills/powershell-orchestration-state-machine/references/standard.md
.agents/skills/powershell-qa-gate/references/standard.md
.agents/skills/pr-author/references/standard.md
.agents/skills/pr-context-artifacts/references/standard.md
.agents/skills/python-qa-gate/references/standard.md
.agents/skills/reconcile-parity-matrix/references/standard.md
.agents/skills/research-issue/references/standard.md
.agents/skills/review-discovery-coverage/references/standard.md
.agents/skills/review-epic/references/standard.md
.agents/skills/review-feature/references/standard.md
.agents/skills/review-staged/references/standard.md
.agents/skills/skill-canonical-location-audit/references/standard.md
.agents/skills/translate-copilot-to-claude/references/standard.md
.agents/skills/update-status/references/standard.md
.agents/skills/validate-discovery-artifacts/references/standard.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/preflight-fixes.2026-11-17T04-46.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/source-comparison.2026-11-17T05-30.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/sweep-fixes.2026-11-17T05-40.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T1.2026-11-17T05-08.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T2.2026-11-17T05-15.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T3.2026-11-17T05-22.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T4.2026-11-17T05-25.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T5.2026-11-17T05-29.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/other/task-check.P1-T7.2026-11-17T05-40.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/phase-gate.P1.2026-11-17T05-57.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/remediation-baseline/cycle-2-contract-checks.2026-11-17T05-04.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/remediation-baseline/cycle-2-contract-text.2026-11-17T04-47.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/remediation-baseline/cycle-2-pester.2026-11-17T05-03.md
docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-plan.2026-11-16T06-14.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/adjudicate-unspecified-behavior/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/characterize-runtime-behavior/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/commit-message/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-change-budget-router/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-orchestration-state-machine/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execute-hard-lock/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/extract-feature-contract/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/fill-feature-docs/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/generate-acceptance-scenarios/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/human-exception-runbook/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/initialize-discovery-workspace/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/inventory-legacy-system/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/make-skill-template/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/policy-audit-template-usage/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/policy-compliance-order/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-change-budget-router/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-orchestration-state-machine/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-author/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/reconcile-parity-matrix/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/review-discovery-coverage/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/review-epic/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/review-feature/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/review-staged/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/skill-canonical-location-audit/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-copilot-to-claude/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/update-status/references/standard.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/validate-discovery-artifacts/references/standard.md
--- git status --porcelain
 M docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-plan.2026-11-16T06-14.md
?? docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/final-contract-checks-c2.2026-11-17T06-37.md
?? docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/final-contract-text-c2.2026-11-17T06-38.md
?? docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/final-pester-c2.2026-11-17T06-37.md
?? docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/final-qc-static-powershell-c2.2026-11-17T06-37.md
```

Acceptance: every listed path is in scope, every changed base contract has its twin, and no forbidden path is listed. PASS.
