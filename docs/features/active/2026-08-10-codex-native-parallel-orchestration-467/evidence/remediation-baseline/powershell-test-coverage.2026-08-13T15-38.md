# PowerShell Remediation Baseline - Tests and Coverage

Timestamp: 2026-08-13T17-37-04:00
Command: `mcp__drm-copilot__run_poshqc_test(workspace_root="C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25")`
EXIT_CODE: 1
Output Summary: Pester discovered 2,430 tests. Results were 2,420 passed, 1 failed, 9 disabled, and 0 errors. Current aggregate line coverage was 4,040/4,260 = 94.835681%. The JaCoCo-compatible XML contained zero `BRANCH` counters, so branch coverage is unsupported and not PASS. The single test failure was caused by a pre-existing `.codex/state` directory containing the active session's Python batch-budget receipt. The bundled MCP coverage configuration attributed only 1 of the 25 issue #467 runtime owners; the missing current-run attribution is recorded explicitly below, together with the complete 25-owner values preserved by the authoritative pre-remediation QA receipt.

## Test result

- Discovered: 2,430
- Passed: 2,420
- Failed: 1
- Disabled/skipped: 9
- Errors: 0
- Failure owner: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:195-196`
- Failure name: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.leaves no Codex batch-budget state behind`
- Failure message: `Expected $false, because benign payloads must not create batch-budget state, but got $true.`
- MCP stderr excerpt: five occurrences of `payload failure`

Read-only containment inspection resolved `.codex/state` to `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25\.codex\state`, confirmed that it is inside the workspace, and found exactly one 289-byte entry: `.codex/state/python-batch-budget.019fedff-89e0-7eb2-ac57-889779169374.json`. No state file or directory was removed.

## Current machine-readable aggregate

| Counter | Covered | Total | Percentage | Disposition |
|---|---:|---:|---:|---|
| Line | 4,040 | 4,260 | 94.835681% | PASS >=85% |
| Instruction | 5,489 | 5,814 | 94.410045% | Recorded |
| Method | 336 | 363 | 92.561983% | Recorded |
| Class | 50 | 52 | 96.153846% | Recorded |
| Branch | 0 | 0 | unsupported | Not PASS |

- `artifacts/pester/pester-junit.xml` SHA-256: `95A5C9C13D9C45AA5440BD24CF7EE557F5216DEF9A08D3D7A0DBD040E08C3E05`
- `artifacts/pester/powershell-coverage.xml` SHA-256: `57487EC24BC411AE76F4B40D6D17D955F524E88E5A2FC76F9B5456B2286F6CF7`
- XML `BRANCH` counter count: `0`

## Complete issue #467 owner inventory

The current bundled MCP report attributed only `.codex/hooks/enforce-completion-consistency.ps1` from this 25-owner set. `MISSING` means the current XML contains no source class for that configured owner; no value is inferred or fabricated. The preserved numeric value is from `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-tests-coverage.txt`, the authoritative full run immediately preceding this remediation cycle.

| Runtime owner | Base status | Current MCP run | Preserved authoritative value |
|---|:---:|---:|---:|
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | A | MISSING | 116/126 = 92.063492% |
| `.codex/hooks/codex-authority-store.ps1` | M | MISSING | 46/58 = 79.310345% |
| `.codex/hooks/enforce-codex-model-routing.ps1` | M | MISSING | 46/79 = 58.227848% |
| `.codex/hooks/enforce-completion-consistency.ps1` | M | 157/159 = 98.742138% | 157/159 = 98.742138% |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | A | MISSING | 27/29 = 93.103448% |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | A | MISSING | 27/30 = 90.000000% |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | A | MISSING | 26/28 = 92.857143% |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | A | MISSING | 26/28 = 92.857143% |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | A | MISSING | 76/83 = 91.566265% |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | A | MISSING | 27/30 = 90.000000% |
| `.codex/hooks/parallel-hook-common.ps1` | A | MISSING | 50/51 = 98.039216% |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | M | MISSING | 111/229 = 48.471616% |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | M | MISSING | 28/86 = 32.558140% |
| `.codex/hooks/validate-parallel-agent-output.ps1` | A | MISSING | 72/76 = 94.736842% |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | A | MISSING | 142/147 = 96.598639% |
| `.codex/scripts/codex-child-launch-persistence.ps1` | A | MISSING | 91/98 = 92.857143% |
| `.codex/scripts/codex-child-launch-resume.ps1` | A | MISSING | 133/135 = 98.518519% |
| `.codex/scripts/codex-child-launch-runtime.ps1` | A | MISSING | 105/111 = 94.594595% |
| `.codex/scripts/epic-child-launch-contract.ps1` | M | MISSING | 134/160 = 83.750000% |
| `.codex/scripts/launch-epic-child-wave.ps1` | M | MISSING | 45/225 = 20.000000% |
| `.codex/scripts/launch-parallel-child-batch.ps1` | A | MISSING | 217/241 = 90.041494% |
| `.codex/scripts/parallel-child-launch-contract.ps1` | A | MISSING | 105/108 = 97.222222% |
| `.codex/scripts/parallel-child-post-session.ps1` | A | MISSING | 159/175 = 90.857143% |
| `.codex/scripts/resume-epic-child.ps1` | M | MISSING | 40/178 = 22.471910% |
| `.codex/scripts/resume-parallel-child.ps1` | A | MISSING | 238/264 = 90.151515% |

## Threshold inventories preserved for remediation

- Attribution in the authoritative pre-remediation run: 25/25.
- Added owners: 17/17 had numeric values and were at least 90%; minimum 90.000000%.
- Modified owners: 8/8 had numeric values.
- Modified owners already at or above 80%: `enforce-completion-consistency.ps1` at 98.742138% and `epic-child-launch-contract.ps1` at 83.750000%.
- Six modified owners below 80%: `codex-authority-store.ps1` 79.310345%; `enforce-codex-model-routing.ps1` 58.227848%; `record-subagent-routing-attestation.ps1` 48.471616%; `validate-codex-subagent-routing.ps1` 32.558140%; `launch-epic-child-wave.ps1` 20.000000%; `resume-epic-child.ps1` 22.471910%.

Acceptance result: PASS for remediation baseline capture. The command's non-zero result, unsupported branch metric, state-dependent test failure, and current bundled-MCP attribution loss are retained as failures and are not represented as green QA.
