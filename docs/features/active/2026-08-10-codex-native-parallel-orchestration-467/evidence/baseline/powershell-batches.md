# PowerShell attributable-coverage batches

Timestamp: 2026-08-12T10:38:51.660Z

Source baseline: `evidence/baseline/powershell/tests-coverage.md`

The 24 root runtime paths absent from the P0-T9 coverage report are partitioned
once across eight ordered batches. Each batch has three production paths and one
focused Pester owner, which remains within the three-production and three-test
ownership cap. The shared coverage configuration owner is
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; it is test
infrastructure and is not a runtime member of any batch.

| Batch | Deficient root runtime path | Focused Pester owner | Uncovered behaviors assigned to the owner |
|---:|---|---|---|
| 1 | `.codex/hooks/authorize-root-parallel-invocation.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-1.Tests.ps1` | Root-entry classification, requested-persona resolution, and safe dot-source loading. |
| 1 | `.codex/hooks/enforce-parallel-root-invocation.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-1.Tests.ps1` | Parallel-scoped input recognition, mutation-identity derivation, and root-attestation lookup. |
| 1 | `.codex/hooks/parallel-hook-common.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-1.Tests.ps1` | Hook payload parsing, deny-envelope conversion, validation dispatch, and result transport. |
| 2 | `.codex/hooks/enforce-parallel-abandon-gate.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-2.Tests.ps1` | Abandon-call recognition, shared-validator forwarding, and safe dot-source loading. |
| 2 | `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-2.Tests.ps1` | Child-binding call recognition, launch-identity forwarding, and safe dot-source loading. |
| 2 | `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-2.Tests.ps1` | Removal-call recognition, shared-validator forwarding, and safe dot-source loading. |
| 3 | `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-3.Tests.ps1` | Cohort-barrier call recognition, shared-validator forwarding, and safe dot-source loading. |
| 3 | `.codex/hooks/enforce-parallel-drift-gate.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-3.Tests.ps1` | Drift-gate call recognition, shared-validator forwarding, and safe dot-source loading. |
| 3 | `.codex/hooks/validate-parallel-agent-output.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-3.Tests.ps1` | Agent-output validator forwarding, decision conversion, and safe dot-source loading. |
| 4 | `.codex/hooks/codex-authority-store.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-4.Tests.ps1` | Authority path-segment normalization, state-root selection, and receipt/attestation path derivation. |
| 4 | `.codex/hooks/enforce-codex-model-routing.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-4.Tests.ps1` | Gated-agent classification, attestation-key derivation, model/profile comparison, and safe dot-source loading. |
| 4 | `.codex/hooks/record-subagent-routing-attestation.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-4.Tests.ps1` | Root-receipt validation, attestation-key derivation, persisted-attestation lookup, and safe dot-source loading. |
| 5 | `.codex/hooks/validate-codex-subagent-routing.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-5.Tests.ps1` | Stop-gated-agent classification, continuation-envelope construction, attestation lookup, and safe dot-source loading. |
| 5 | `.codex/scripts/codex-child-launch-contract-core.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-5.Tests.ps1` | Effective concurrency bounds, positive-integer validation, hash/path validation, and launch-identity validation. |
| 5 | `.codex/scripts/codex-child-launch-resume.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-5.Tests.ps1` | Resume property/type validation, live-status classification, and receipt/status reconciliation. |
| 6 | `.codex/scripts/codex-child-launch-persistence.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-6.Tests.ps1` | Create-new and atomic persistence, terminal-status lookup, and schedule-status serialization. |
| 6 | `.codex/scripts/codex-child-launch-runtime.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-6.Tests.ps1` | Session-id extraction, sealed-file reads, process-start configuration, and launch-capacity calculation. |
| 6 | `.codex/scripts/epic-child-launch-contract.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-6.Tests.ps1` | Feature-key derivation, checkpoint/receipt lookup, and epic launch-spec validation. |
| 7 | `.codex/scripts/launch-epic-child-wave.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-7.Tests.ps1` | Receipt lookup, resume-status selection, wave-status persistence, and safe dot-source loading. |
| 7 | `.codex/scripts/parallel-child-post-session.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-7.Tests.ps1` | Forbidden-state detection, receipt-path validation, item selection, and post-session decision inputs. |
| 7 | `.codex/scripts/resume-epic-child.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-7.Tests.ps1` | Resume-context validation, resume start-info construction, wave-status update, and safe dot-source loading. |
| 8 | `.codex/scripts/launch-parallel-child-batch.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-8.Tests.ps1` | Deterministic batch ordering, permission/MCP restriction derivation, status serialization, and safe dot-source loading. |
| 8 | `.codex/scripts/parallel-child-launch-contract.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-8.Tests.ps1` | Checkpoint-item selection, forbidden-state detection, required binding fields, and launch-receipt construction. |
| 8 | `.codex/scripts/resume-parallel-child.ps1` | `tests/scripts/codex-hooks/powershell-attribution-batch-8.Tests.ps1` | First-incomplete selection, evidence/live-truth checks, resume-context construction, and safe dot-source loading. |

Verification result: PASS. The table contains 24 runtime rows, 24 unique root
paths, eight batches of exactly three production paths, and one focused Pester
owner per batch. `enforce-completion-consistency.ps1` is excluded because P0-T9
already recorded numeric attribution for that runtime.
