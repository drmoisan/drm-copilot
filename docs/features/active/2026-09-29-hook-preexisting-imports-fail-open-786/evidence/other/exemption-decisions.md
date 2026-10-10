# Exemption Decisions ([P1-T13])

Timestamp: 2026-10-09T22-42

DECISION: H1 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H1.md
DECISION: H2 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H2.md
DECISION: H3 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H3.md
DECISION: H4 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H4.md
DECISION: H5 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H5.md
DECISION: H6 | EXEMPT | PROOF_RESULT=FAIL-CLOSED | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H6.md
DECISION: H7 | CONVERT | PROOF_RESULT=FAIL-OPEN | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H7.md
DECISION: H8 | CONVERT | PROOF_RESULT=FAIL-OPEN | proof=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H8.md

W-EXEMPT: H1, H2, H3, H4, H5, H6
W-CONVERT: H7, H8
W-EXEMPT-VARIABLES: FeatureFolderOrderResolutionImportFailure, OrchestrationFeatureFolderResolutionImportFailure, PrdFeatureFolderResolutionImportFailure, EpicWaveBarrierResolutionImportFailure, ParallelDriftGateResolutionImportFailure, ParallelCohortBarrierResolutionImportFailure
W-EXEMPT-EDGES: (claude, .claude/hooks/enforce-feature-folder-order.ps1, feature-folder-resolution.ps1); (claude, .claude/hooks/enforce-epic-wave-barrier.ps1, feature-folder-resolution.ps1); (claude, .claude/hooks/enforce-parallel-drift-gate.ps1, feature-folder-resolution.ps1); (claude, .claude/hooks/enforce-parallel-cohort-barrier.ps1, feature-folder-resolution.ps1)
W-CONVERT-EDGES: (claude, .claude/hooks/validate-orchestrator-output.ps1, validate-orchestrator-output-resolution.ps1); (claude, .claude/hooks/validate-orchestrator-output.ps1, WorktreeItemResolution.psm1); (claude, .claude/hooks/validate-orchestrator-output.ps1, WorktreeRunResolution.psm1); (claude, .claude/hooks/validate-orchestrator-output.ps1, OrchestratorStateEpicWaveBarrier.psm1)
W-CONVERT-HOOKS: .claude/hooks/validate-orchestrator-output.ps1
PRELIMINARY-MISMATCH: none

Notes: H2 and H3 are nested handlers in sibling files, so they contribute no W-HELD-EDGES row; the H2 handler file is reached through .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, and the H3 handler file through .claude/hooks/enforce-prd-feature-before-planner.ps1. Every decision equals its section 2.6.2 planning-time finding.
