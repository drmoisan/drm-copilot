# PowerShell Owner Coverage Comparison

Timestamp: `2026-08-13T15-38`

## Command and result

Command:

```powershell
Import-Module './scripts/powershell/PoshQC/PoshQC.psd1' -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath './scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -DisableKoverageCopy
```

- Process exit code: `1`.
- Pester: 2,456 discovered; 2,446 passed; 1 failed; 9 disabled/skipped; 0 errors; 0 inconclusive; 0 not run; 126.112 seconds.
- The sole failure is the unchanged Phase 0 baseline failure at `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:195-196`: the test expects `.codex/state` to be absent, but the pre-existing state directory is present. The directory was inspected read-only and was not deleted or modified.
- Coverage XML repository line counter: 6,529/7,035 = 92.807392% (`PASS`, required >=85%).
- Coverage XML contains all 25 authoritative runtime owners (`PASS`, required 25/25).

## Authoritative owner inventory

| Authoritative runtime path | Base status | Current line coverage | Requirement | Result |
|---|:---:|---:|---:|:---:|
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | A | 116/126 = 92.063492% | >=90% | PASS |
| `.codex/hooks/codex-authority-store.ps1` | M | 49/58 = 84.482759% | >=80% | PASS |
| `.codex/hooks/enforce-codex-model-routing.ps1` | M | 68/79 = 86.075949% | >=80% | PASS |
| `.codex/hooks/enforce-completion-consistency.ps1` | M | 157/159 = 98.742138% | no regression from 157/159 = 98.742138% | PASS |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | A | 27/29 = 93.103448% | >=90% | PASS |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | A | 27/30 = 90.000000% | >=90% | PASS |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | A | 26/28 = 92.857143% | >=90% | PASS |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | A | 26/28 = 92.857143% | >=90% | PASS |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | A | 76/83 = 91.566265% | >=90% | PASS |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | A | 27/30 = 90.000000% | >=90% | PASS |
| `.codex/hooks/parallel-hook-common.ps1` | A | 50/51 = 98.039216% | >=90% | PASS |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | M | 186/229 = 81.222707% | >=80% | PASS |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | M | 76/86 = 88.372093% | >=80% | PASS |
| `.codex/hooks/validate-parallel-agent-output.ps1` | A | 72/76 = 94.736842% | >=90% | PASS |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | A | 142/147 = 96.598639% | >=90% | PASS |
| `.codex/scripts/codex-child-launch-persistence.ps1` | A | 91/98 = 92.857143% | >=90% | PASS |
| `.codex/scripts/codex-child-launch-resume.ps1` | A | 133/135 = 98.518519% | >=90% | PASS |
| `.codex/scripts/codex-child-launch-runtime.ps1` | A | 105/111 = 94.594595% | >=90% | PASS |
| `.codex/scripts/epic-child-launch-contract.ps1` | M | 135/160 = 84.375000% | no regression from 134/160 = 83.750000% | PASS |
| `.codex/scripts/launch-epic-child-wave.ps1` | M | 182/225 = 80.888889% | >=80% | PASS |
| `.codex/scripts/launch-parallel-child-batch.ps1` | A | 217/241 = 90.041494% | >=90% | PASS |
| `.codex/scripts/parallel-child-launch-contract.ps1` | A | 105/108 = 97.222222% | >=90% | PASS |
| `.codex/scripts/parallel-child-post-session.ps1` | A | 159/175 = 90.857143% | >=90% | PASS |
| `.codex/scripts/resume-epic-child.ps1` | M | 156/178 = 87.640449% | >=80% | PASS |
| `.codex/scripts/resume-parallel-child.ps1` | A | 238/264 = 90.151515% | >=90% | PASS |

## Acceptance reconciliation

- Attribution: 25/25 owners have exactly one numeric source-attributed `LINE` counter (`PASS`).
- Added owners: 17/17 are >=90%; minimum 90.000000%; combined 1,637/1,760 = 93.011364% (`PASS`).
- Six remediated modified owners: 6/6 are >=80%; minimum 80.888889% (`PASS`).
- Other modified owners: `.codex/hooks/enforce-completion-consistency.ps1` held at 98.742138%, and `.codex/scripts/epic-child-launch-contract.ps1` increased from 83.750000% to 84.375000% (`PASS`).
- All 25 owners combined: 2,646/2,934 = 90.184049%.
- Repository aggregate: 6,529/7,035 = 92.807392%, above the 85% floor (`PASS`).
- P2-T6 numeric coverage criteria: `PASS`. The full test command retains the known Phase 0 state-directory failure and is not represented as a clean Pester pass.

## Artifact integrity

- `artifacts/pester/pester-junit.xml` SHA-256: `A863A46462A57A890600BE902F8047501E48843614E4F8A54AFF316F2D519EB9`.
- `artifacts/pester/powershell-coverage.xml` SHA-256: `72E8E6FA41B6C62CF020FA97D7EC9B877FA0C7FE5FEFC361D4EB8FF355782BF3`.
