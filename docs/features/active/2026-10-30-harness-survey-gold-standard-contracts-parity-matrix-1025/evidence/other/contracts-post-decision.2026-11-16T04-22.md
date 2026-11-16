# Contracts After Decisions (P1-T4)

Timestamp: 2026-11-16T04-22
Command: pwsh -NoProfile -File SCRATCH/issue-1025-contracts-post-decision.ps1 (Get-HarnessSkillContractRequiredSet of the current matrix and of PlanAMatrix; review of the contracts of every name with a disputed-case decision or Diff ID override; Get-HarnessSkillContractViolation; on-disk set and byte comparison with the bundle copies)
EXIT_CODE: 0
Output Summary: required set 65 names (PlanAMatrix 65); created 0, revised 0, deleted 0, reviewed unchanged 5; Violations 0; ContractSetMismatch 0; BundleMismatch 0.

Created: none (no Codex-only name is approved `shared`; the nine single-ecosystem names approved `shared` are Claude-only, whose contracts come from child 3 under the F2 constraint)
Revised: none
Deleted: none (no `codex:skill` name moved off `shared`)

Unchanged with reason:
- `.agents/skills/epic-plan/references/standard.md`: unchanged; 1 disputed case(s) (D-epic-plan-11) decided A, which is the proposed class and port direction the contract was written from, so no stated objective or behavior changes
- `.agents/skills/feature-promotion-lifecycle/references/standard.md`: unchanged; 6 disputed case(s) (D-feature-promotion-lifecycle-08, D-feature-promotion-lifecycle-09, D-feature-promotion-lifecycle-10, D-feature-promotion-lifecycle-11, D-feature-promotion-lifecycle-12, D-feature-promotion-lifecycle-13) decided A, which is the proposed class and port direction the contract was written from, so no stated objective or behavior changes
- `.agents/skills/orchestrate/references/standard.md`: unchanged; 8 disputed case(s) (D-orchestrate-09, D-orchestrate-12, D-orchestrate-13, D-orchestrate-15, D-orchestrate-24, D-orchestrate-34, D-orchestrate-42, D-orchestrate-43) decided A, which is the proposed class and port direction the contract was written from, so no stated objective or behavior changes
- `.agents/skills/remediation-handoff-atomic-planner/references/standard.md`: unchanged; 2 disputed case(s) (D-remediation-handoff-atomic-planner-17, D-remediation-handoff-atomic-planner-21) decided A, which is the proposed class and port direction the contract was written from, so no stated objective or behavior changes
- `.agents/skills/translate-copilot-to-claude/references/standard.md`: unchanged; 2 disputed case(s) (D-translate-copilot-to-claude-03, D-translate-copilot-to-claude-14) decided A, which is the proposed class and port direction the contract was written from, so no stated objective or behavior changes

Violations: 0
ReviewedContractViolations: 0
ContractSetMismatch: 0
BundleMismatch: 0
