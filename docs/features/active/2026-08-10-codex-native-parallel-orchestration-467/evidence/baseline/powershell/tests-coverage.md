# PowerShell Tests and Coverage Baseline

Timestamp: 2026-08-12T05-19

Command: `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"})`

EXIT_CODE: 0

Output Summary: The bundled PoshQC Pester run completed with `ok: true`. JUnit recorded 2,294 tests, 0 errors, 0 failures, and 9 disabled tests in 120.403 seconds. Generated coverage recorded 5,489 covered and 325 missed instructions (94.4100447196422%) and 4,040 covered and 220 missed lines (94.8356807511737%). Of the 25 authoritative changed/new PowerShell runtime files, 1 had source attribution and 24 were absent from the generated coverage XML.

## Authoritative 25-file attribution

Pester's JaCoCo-compatible XML represents executable PowerShell commands as `INSTRUCTION` counters. `Not present` means the generated coverage XML contained no source record for the authoritative root path, so no numeric percentage can be claimed. This reproduces each missing-attribution finding.

| Authoritative root runtime path | Analyzed commands | Covered | Missed | Command coverage | Baseline result |
|---|---:|---:|---:|---:|---|
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/codex-authority-store.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-codex-model-routing.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-completion-consistency.ps1` | 220 | 215 | 5 | 97.72727272727273% | Present; 157/159 lines covered (98.74213836477988%); missed lines 401 and 429 |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/parallel-hook-common.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/hooks/validate-parallel-agent-output.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/codex-child-launch-persistence.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/codex-child-launch-resume.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/codex-child-launch-runtime.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/epic-child-launch-contract.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/launch-epic-child-wave.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/launch-parallel-child-batch.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/parallel-child-launch-contract.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/parallel-child-post-session.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/resume-epic-child.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |
| `.codex/scripts/resume-parallel-child.ps1` | 0 | 0 | 0 | N/A | Not present; missing attribution reproduced |

The 24 absent records exactly match the 24 missing-attribution findings. The existing `enforce-completion-consistency.ps1` record supplies its numeric baseline and remains in full-gate scope.

