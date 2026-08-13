# TypeScript coverage-remediation batches

Source baseline: `evidence/baseline/typescript/tests-coverage.md`

The five modified files with reviewed line-coverage regressions are partitioned
once each into two ordered batches. Existing focused owners remain assigned when
they have adequate space under the 500-line policy. One new focused owner is
reserved for the model-routing state module because its existing owner was 458
lines at baseline.

## Batch 1 — routing merge and dispatch validation

| Production path | Reviewed baseline | Exact uncovered lines | Focused test owner |
|---|---:|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 466/491 (94.90%) | 121-122, 146-147, 173-179, 201-202, 216, 218-219, 226-228, 271-276 | `extensions/drm-copilot/test/lib/push-down/codex-routing-merge.test.ts` |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | 308/320 (96.25%) | 108-109, 113-117, 241-245 | `extensions/drm-copilot/test/lib/validate/codex-topology-resolver.test.ts` |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 354/360 (98.33%) | 341-346 | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` |

Ownership: 3 production files and 3 test owners.

## Batch 2 — model-routing state and kickoff validation

| Production path | Reviewed baseline | Exact uncovered lines | Focused test owner |
|---|---:|---|---|
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | 466/497 (93.76%) | 164-165, 230-234, 239-243, 339-343, 353-356, 366-370, 374, 376-379 | `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing-coverage.test.ts` |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 409/417 (98.08%) | 387-390, 392-395 | `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts` |

Ownership: 2 production files and 2 test owners.

## Reconciliation

- Production rows: 5.
- Unique production paths: 5.
- Production paths assigned more than once: 0.
- Missing reviewed production paths: 0.
- Batch sizes: 3 and 2 production paths; 3 and 2 test owners.
- Every row records numeric baseline coverage, exact uncovered lines, and one
  focused test owner.

Acceptance result: PASS.
