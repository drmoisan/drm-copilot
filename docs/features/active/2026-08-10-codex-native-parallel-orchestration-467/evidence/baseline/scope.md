# Remediation Scope Inventory

Timestamp: 2026-08-12T05-05

Source: `remediation-inputs.2026-08-12T01-42.md`

Reviewed base: `fe0413d4aca1e76b2d02d05701fba79a887d5405`

Reviewed/remediation-start head: `35323f412f752467f3d787326399218d9564c8b2`

## Finding-to-plan mapping

| Finding | Required outcome | Later task IDs |
|---|---|---|
| R1 — Python new/modified file coverage | Five added modules reach at least 90% line coverage; three modified modules preserve their individual P0-T8 numeric baselines; repository line/branch and changed-line gates pass. | P3-T1 through P5-T5; P9-T1 through P9-T4; P13-T1 through P13-T4 |
| R2 — PowerShell source-attributable coverage | All 25 authoritative runtime files have numeric source attribution; the 24 currently absent paths are covered through eight bounded batches; root/bundle parity remains exact. | P0-T9; P6-T1 through P6-T18; P8-T1 through P8-T4; P10-T1 through P10-T3; P13-T1 through P13-T4 |
| R3 — TypeScript modified-file coverage regression | Five modified files restore their individual baselines or higher; repository and changed-line gates pass. | P0-T10; P7-T1 through P7-T6; P11-T1 through P11-T4; P13-T1 through P13-T4 |
| R4 — Dedicated parallel authority contract | Planner and orchestrator prompt authority equals each dedicated profile, entry skills, and byte-identical bundle. | P0-T7; P1-T1 through P2-T5; P8-T1 through P8-T4; P13-T3 through P13-T4 |
| R5 — Python documentation and intent comments | All seven added Python modules and affected helpers pass the complete docstring/comment policy audit without suppressions. | P3-T3 and P3-T5; P4-T3 and P4-T5; P5-T3 and P5-T5; P9-T1 through P9-T4; P13-T3 through P13-T4 |
| R6 — Acceptance/evidence reconciliation and final QA | Four-language QA and numeric coverage are current; locally proven criteria are reconciled; hosted-CI and re-review criteria stay deferred for orchestrator ownership. | P8-T1 through P13-T7 |

## R1 Python production paths and test owners

The R1 ownership table is authoritative and preserves the plan's three bounded
batches.

| Batch | Production path | Status/threshold | Test owner |
|---|---|---|---|
| 1 | `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | Added; >=90% line coverage | `tests/scripts/dev_tools/test_parallel_completion_receipts.py` |
| 1 | `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | Added; >=90% line coverage | `tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py` |
| 1 | `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | Added; >=90% line coverage | `tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py` |
| 2 | `scripts/dev_tools/push_down_codex_routing_merge.py` | Added; >=90% line coverage | `tests/scripts/dev_tools/test_push_down_codex_routing_merge.py` |
| 2 | `scripts/dev_tools/validate_parallel_codex_readiness.py` | Added; >=90% line coverage | `tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py` |
| 2 | `scripts/dev_tools/parallel_kickoff_contract.py` | Modified; >= individual P0-T8 baseline | `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` |
| 3 | `scripts/dev_tools/resolve_codex_deployment.py` | Modified; >= individual P0-T8 baseline | `tests/scripts/dev_tools/test_resolve_codex_deployment.py` |
| 3 | `scripts/dev_tools/resolve_codex_topology.py` | Modified; >= individual P0-T8 baseline | `tests/scripts/dev_tools/test_resolve_codex_topology.py` |

Required Python commands:

```powershell
poetry run black . --check
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:<canonical-evidence-path>
```

Post-edit write-mode formatting uses `poetry run black .`, followed by a clean
restart at Black. P0-T8 retains numeric repository line/branch coverage and exact
per-file missing lines; P9-T4 compares all eight files to those values.

## R2 PowerShell runtime, bundle, and current owner inventory

Every root runtime has a byte-identical mirror beneath
`extensions/drm-copilot/resources/codex-and-agents-customizations/` at the same
relative path. The owner shown is the current most focused related suite; P6-T1
uses the P0-T9 uncovered-line inventory to select the final bounded owner for each
of the 24 absent paths. `enforce-completion-consistency.ps1` is the one path with
existing changed-line attribution and remains in full-gate scope but outside the
eight deficient batches.

| Authoritative root production path | Byte-identical bundle mirror | Current related test owner | P0 status |
|---|---|---|---|
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/authorize-root-parallel-invocation.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/codex-authority-store.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-authority-store.ps1` | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-codex-model-routing.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1` | `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-completion-consistency.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1` | `tests/scripts/codex-hooks/parallel-completion-compensating-controls.Tests.ps1` | Existing attribution |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-abandon-gate.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-cohort-barrier.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-drift-gate.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-root-invocation.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/parallel-hook-common.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/parallel-hook-common.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1` | `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` | Missing attribution |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1` | `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` | Missing attribution |
| `.codex/hooks/validate-parallel-agent-output.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-parallel-agent-output.ps1` | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` | Missing attribution |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-child-launch-contract-core.ps1` | `tests/scripts/codex-hooks/codex-child-launch-resume-core.Tests.ps1` | Missing attribution |
| `.codex/scripts/codex-child-launch-persistence.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-child-launch-persistence.ps1` | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/codex-child-launch-resume.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-child-launch-resume.ps1` | `tests/scripts/codex-hooks/codex-child-launch-resume-core.Tests.ps1` | Missing attribution |
| `.codex/scripts/codex-child-launch-runtime.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-child-launch-runtime.ps1` | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/epic-child-launch-contract.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/epic-child-launch-contract.ps1` | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/launch-epic-child-wave.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/launch-epic-child-wave.ps1` | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/launch-parallel-child-batch.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/launch-parallel-child-batch.ps1` | `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/parallel-child-launch-contract.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/parallel-child-launch-contract.ps1` | `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1` | Missing attribution |
| `.codex/scripts/parallel-child-post-session.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/parallel-child-post-session.ps1` | `tests/scripts/codex-hooks/parallel-child-post-session.Tests.ps1` | Missing attribution |
| `.codex/scripts/resume-epic-child.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/resume-epic-child.ps1` | `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` | Missing attribution |
| `.codex/scripts/resume-parallel-child.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/resume-parallel-child.ps1` | `tests/scripts/codex-hooks/parallel-child-resume-live-truth.Tests.ps1` | Missing attribution |

PowerShell coverage/configuration owner:
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Scan configuration:
`config/poshqc-scan.json`.

Required PowerShell commands, in order:

```text
mcp__drm_copilot__run_poshqc_format(workspace_root=<workspace>)
mcp__drm_copilot__run_poshqc_analyze(workspace_root=<workspace>)
mcp__drm_copilot__run_poshqc_test(workspace_root=<workspace>)
```

Targeted batches may pass their owner paths through `scan_folders`. Attribution is
derived from Pester's generated coverage XML and records analyzed commands,
covered commands, missed commands, and numeric percentage for every root runtime.

## R3 TypeScript production paths and primary test owners

| Production path | Baseline regression | Primary focused owner |
|---|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 98.05% -> 94.91% | `extensions/drm-copilot/test/lib/push-down/codex-routing-merge.test.ts` |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | 97.39% -> 96.25% | `extensions/drm-copilot/test/lib/validate/codex-topology-resolver.test.ts` |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 100% -> 98.33% | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | 95.66% -> 93.75% | `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts` |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 100% -> 98.08% | `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts` |

P7-T1 may create smaller focused owners when an existing owner cannot accept new
cases without violating the 500-line gate; each production path still appears in
exactly one of its two batches.

Required TypeScript commands:

```powershell
npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=lcov --coverageReporters=text --coverageReporters=json-summary
```

Post-edit formatting uses `npm --prefix extensions/drm-copilot run format`, then
restarts the sequence at formatting.

## R4 prompt sources, profiles, entry skills, bundles, and tests

| Persona | Canonical prompt/profile source | Required authority | Entry skill authority sources | Generated/bundled copy | Test owner |
|---|---|---|---|---|---|
| Planner | `.codex/agents/parallel-planner.toml` | `parallel-planner-workspace` | `.agents/skills/parallel-plan/SKILL.md`; `.codex/config.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/parallel-planner.toml` | `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` |
| Orchestrator | `.codex/agents/parallel-orchestrator.toml` | `parallel-orchestrator-workspace` | `.agents/skills/parallel-run/SKILL.md`; `.agents/skills/parallel-orchestrate/SKILL.md`; `.codex/config.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/parallel-orchestrator.toml` | `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` |

The test must parse the real TOML developer-instruction body, compare its sandbox
authority statement with `default_permissions`, verify the corresponding entry
skill authority, and reject ordinary `orchestrator-workspace`. The parity owner is
`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`;
the pack/registration owners are
`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
and `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`.

Required R4 commands include targeted PoshQC/Pester for
`tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`, targeted Pytest for the
resource contract, SHA-256 equality for the two root/bundle pairs, and the full
source/bundle parity validators in P8-T2/P13-T3.

## R5 seven added Python documentation paths

| Added production module | Affected test/helper owner |
|---|---|
| `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | `tests/scripts/dev_tools/test_parallel_completion_receipts.py` |
| `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | `tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py` |
| `scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py` | `tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py` |
| `scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py` | `tests/scripts/dev_tools/test_parallel_resume_truth.py` |
| `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | `tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py` |
| `scripts/dev_tools/push_down_codex_routing_merge.py` | `tests/scripts/dev_tools/test_push_down_codex_routing_merge.py` |
| `scripts/dev_tools/validate_parallel_codex_readiness.py` | `tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py` |

The policy audit covers every callable, loop/comprehension, non-trivial branch,
and multi-step block. P13-T3 is the final repository-policy validator gate for
the complete seven-file R5 set.

## R6 requirements and evidence sources

Work mode is `full-feature`; authoritative acceptance-criteria sources are:

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`

Existing mapping receipt:
`docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/issue-updates/issue-467.2026-08-10T20-25.md`.

S-D02, S-D13, S-D14, U01, U19, and U20 remain unchecked until current local
remediation evidence proves them. S-D15, U21, and the issue-level exact-current-
head CI criterion remain unchecked for the parent orchestrator because they need
feature re-review or hosted CI at the final head.

## Bash full-regression commands

Bash has no remediation production edit, but R6 requires a current four-language
QA pass. Run under WSL from the repository root:

```bash
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check
bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/<kind>/bash/kcov' bash scripts/bash/shell-qc.sh test --coverage"
```

The baseline uses `<kind>` = `baseline`; final QA uses `qa-gates`. Each command
must produce its required schema-complete receipt, with numeric line coverage and
branch coverage recorded as unsupported/not-PASS.
