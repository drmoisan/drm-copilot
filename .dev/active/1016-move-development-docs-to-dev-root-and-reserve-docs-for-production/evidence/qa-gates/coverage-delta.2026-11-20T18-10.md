# Coverage Delta ([P5-T5], stage B)

Timestamp: 2026-11-20T18-10
Command: node SCRATCH/issue-1016-p5t5.cjs p5e issue-1016-coverage-final5.json (baselines: SCRATCH/p0t5.lcov.info from [P0-T5], SCRATCH/issue-1016-coverage-baseline.json from [P0-T6], SCRATCH/p0t7.coverage.xml from [P0-T7]; finals: pass-5 SCRATCH/p5e.lcov.info, SCRATCH/issue-1016-coverage-final5.json, SCRATCH/p5e.coverage.xml; changed production files from git diff -M --name-status BASE HEAD, BASE = merge base of INTEGRATION and HEAD)
EXIT_CODE: 0
Output Summary: 46 changed production files compared, 0 violations, 0 missing values. Hand-edited files: scripts/dev-tools/ProcessReductionChain.psm1 241/241 to 254/254 lines (100%); scripts/dev_tools/build_discovery_runtime.py 225/225 to 236/236 lines and 102/102 to 110/110 branches (100%, 100%); scripts/dev_tools/discovery/init_models.py 5/5 lines (100%), 0 branches. Every other changed file shows no per-file drop. Totals: TypeScript lines 97.59% to 97.59% and branches 94.95% to 94.95%; Python lines 96.65% to 96.66% and branches 92.52% to 92.53%; PowerShell lines 96.84% (47273/48814) to 96.84% (47286/48827), a rise from 96.843% to 96.846%. No language total drops.

Rules applied: hand-edited and new files must reach 85% lines and, for Python and TypeScript, 75% branches, with no drop against the Phase 0 baseline; every other changed file must show no per-file drop; no language total may drop. `extensions/drm-copilot/src/repo-automation-service-contract.ts` is a type contract changed in stage A; it reports 0/346 at baseline and final, so it has no drop. TypeScript files marked (A) were added on this branch by stage A before the Phase 0 baseline and are compared with that baseline.

## TypeScript (Jest lcov)

| File | Baseline lines | Final lines | Baseline branches | Final branches | Result |
| --- | --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/development-docs-migration/folder-rename-plan.ts` (A) | 217/217 (100.00) | 217/217 (100.00) | 30/35 (85.71) | 30/35 (85.71) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts` (A) | 156/156 (100.00) | 156/156 (100.00) | 21/21 (100.00) | 21/21 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts` (A) | 212/212 (100.00) | 212/212 (100.00) | 33/34 (97.06) | 33/34 (97.06) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-apply.ts` (A) | 106/106 (100.00) | 106/106 (100.00) | 12/12 (100.00) | 12/12 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-decisions.ts` (A) | 346/346 (100.00) | 346/346 (100.00) | 75/76 (98.68) | 75/76 (98.68) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-git.ts` (A) | 85/85 (100.00) | 85/85 (100.00) | 11/11 (100.00) | 11/11 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts` (A) | 587/587 (100.00) | 587/587 (100.00) | 145/148 (97.97) | 145/148 (97.97) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-report.ts` (A) | 222/222 (100.00) | 222/222 (100.00) | 25/25 (100.00) | 25/25 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/reference-rewrite.ts` (A) | 333/333 (100.00) | 333/333 (100.00) | 65/65 (100.00) | 65/65 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/subprocess-runner.ts` (M) | 147/149 (98.66) | 147/149 (98.66) | 21/22 (95.45) | 21/22 (95.45) | PASS |
| `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` (M) | 302/302 (100.00) | 302/302 (100.00) | 55/55 (100.00) | 55/55 (100.00) | PASS |
| `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` (M) | 486/494 (98.38) | 486/494 (98.38) | 91/99 (91.92) | 91/99 (91.92) | PASS |
| `extensions/drm-copilot/src/mcp-development-docs-tool-definitions.ts` (A) | 42/42 (100.00) | 42/42 (100.00) | 0/0 (100.00) | 0/0 (100.00) | PASS |
| `extensions/drm-copilot/src/mcp-handlers/development-docs-migration-handler.ts` (A) | 30/30 (100.00) | 30/30 (100.00) | 4/4 (100.00) | 4/4 (100.00) | PASS |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (M) | 438/438 (100.00) | 438/438 (100.00) | 0/0 (100.00) | 0/0 (100.00) | PASS |
| `extensions/drm-copilot/src/mcp-server.ts` (M) | 152/172 (88.37) | 152/172 (88.37) | 14/17 (82.35) | 14/17 (82.35) | PASS |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` (M) | 475/475 (100.00) | 475/475 (100.00) | 0/0 (100.00) | 0/0 (100.00) | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-development-docs.ts` (A) | 72/72 (100.00) | 72/72 (100.00) | 18/18 (100.00) | 18/18 (100.00) | PASS |
| `extensions/drm-copilot/src/mcp-tools.ts` (M) | 480/495 (96.97) | 480/495 (96.97) | 99/106 (93.40) | 99/106 (93.40) | PASS |
| `extensions/drm-copilot/src/migrate-development-docs-cli.ts` (A) | 138/143 (96.50) | 138/143 (96.50) | 39/41 (95.12) | 39/41 (95.12) | PASS |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` (M) | 0/346 (0.00) | 0/346 (0.00) | 0/1 (0.00) | 0/1 (0.00) | PASS |
| `extensions/drm-copilot/src/repo-automation-service.ts` (M) | 528/528 (100.00) | 528/528 (100.00) | 48/51 (94.12) | 48/51 (94.12) | PASS |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` (M) | 56/56 (100.00) | 56/56 (100.00) | 0/0 (100.00) | 0/0 (100.00) | PASS |
| total | 74504/76344 (97.59) | 74504/76344 (97.59) | 11903/12536 (94.95) | 11903/12536 (94.95) | PASS |

## Python (pytest-cov JSON)

| File | Baseline lines | Final lines | Baseline branches | Final branches | Result |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/build_discovery_runtime.py` (M, hand-edited) | 225/225 (100.00) | 236/236 (100.00) | 102/102 (100.00) | 110/110 (100.00) | PASS |
| `scripts/dev_tools/discovery/init_models.py` (M, hand-edited) | 5/5 (100.00) | 5/5 (100.00) | 0/0 (100.00) | 0/0 (100.00) | PASS |
| `scripts/dev_tools/parallel_lane_assertion.py` (M) | 143/143 (100.00) | 143/143 (100.00) | 44/44 (100.00) | 44/44 (100.00) | PASS |
| `scripts/dev_tools/parallel_manifest_contract.py` (M) | 168/168 (100.00) | 168/168 (100.00) | 82/82 (100.00) | 82/82 (100.00) | PASS |
| `scripts/dev_tools/plan_gate_discrimination.py` (M) | 135/136 (99.26) | 135/136 (99.26) | 51/52 (98.08) | 51/52 (98.08) | PASS |
| `scripts/dev_tools/plan_gate_observability.py` (M) | 135/139 (97.12) | 135/139 (97.12) | 57/62 (91.94) | 57/62 (91.94) | PASS |
| `scripts/dev_tools/schema_loading.py` (M) | 35/35 (100.00) | 35/35 (100.00) | 14/14 (100.00) | 14/14 (100.00) | PASS |
| total | 17707/18321 (96.65) | 17720/18332 (96.66) | 6186/6686 (92.52) | 6194/6694 (92.53) | PASS |

## PowerShell (Pester line coverage)

| File | Baseline lines | Final lines | Result |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` (M) | 103/103 (100.00) | 103/103 (100.00) | PASS |
| `.claude/hooks/enforce-evidence-locations.ps1` (M) | 41/46 (89.13) | 41/46 (89.13) | PASS |
| `.claude/hooks/hook-command-invocation.ps1` (M) | 154/154 (100.00) | 154/154 (100.00) | PASS |
| `.claude/hooks/hook-command-scanner.ps1` (M) | 160/160 (100.00) | 160/160 (100.00) | PASS |
| `.claude/hooks/subagentstop-envelope.ps1` (M) | 60/60 (100.00) | 60/60 (100.00) | PASS |
| `.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1` (M) | 5/5 (100.00) | 5/5 (100.00) | PASS |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` (M) | 72/72 (100.00) | 72/72 (100.00) | PASS |
| `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` (M) | 179/179 (100.00) | 179/179 (100.00) | PASS |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CrossEpic.ps1` (M) | 56/56 (100.00) | 56/56 (100.00) | PASS |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1` (M) | 210/210 (100.00) | 210/210 (100.00) | PASS |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` (M) | 153/153 (100.00) | 153/153 (100.00) | PASS |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` (M) | 110/114 (96.49) | 110/114 (96.49) | PASS |
| `.codex/hooks/enforce-evidence-locations.ps1` (M) | 49/49 (100.00) | 49/49 (100.00) | PASS |
| `.codex/hooks/hook-command-invocation.ps1` (M) | 154/154 (100.00) | 154/154 (100.00) | PASS |
| `.codex/hooks/hook-command-scanner.ps1` (M) | 160/160 (100.00) | 160/160 (100.00) | PASS |
| `scripts/dev-tools/ProcessReductionChain.psm1` (M, hand-edited) | 241/241 (100.00) | 254/254 (100.00) | PASS |
| total | 47273/48814 (96.84) | 47286/48827 (96.84) | PASS |

CHANGED_PRODUCTION_FILES 46
VIOLATIONS 0
MISSING 0
