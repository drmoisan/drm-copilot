# CI Test Discovery Audit

- Timestamp: `2026-08-11T15:00:31.129-04:00`
- Plan task: `[P5-T10]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Result: `PASS_WITH_REQUIRED_BACKSTOP_GAP`
- EXIT_CODE: `0`

## Audit scope

The baseline worktree contained only the feature folder as untracked state. The current baseline-owned diff therefore identifies `58` executable issue #467 test files: `21` Python, `23` extension TypeScript, `12` Pester, and `2` Bats files. Two shared JSON parity fixtures are mapped as dependencies rather than executable suites. Documentation snapshots under the feature evidence tree are excluded because CI must not discover them as test owners.

## Suite-to-workflow mapping

| Ecosystem | Root workflow job | Reusable workflow job | CI command | Recursive selector | Changed files discovered | Repository total discovered | Failure propagation |
| --- | --- | --- | --- | --- | ---: | ---: | --- |
| Python | `.github/workflows/ci.yml: quality-checks7` | `_quality-checks.yml: quality-checks7` | `poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing` | `pyproject.toml` has `testpaths=["tests"]`; standard `test_*.py` naming | 21/21 | 454 collected from the scoped changed-file command | Required calling job; test step has `continue-on-error: false` |
| TypeScript | `.github/workflows/ci.yml: drm-copilot-extension-tests` | `_drm-copilot-extension-tests.yml: drm-copilot-extension-tests` | `npm --prefix extensions/drm-copilot run test` | `jest.config.cjs` has `testMatch=["**/test/**/*.test.ts"]` | 23/23 | 193 listed | Required calling job; failures propagate by default on Windows and Ubuntu |
| PowerShell | `.github/workflows/ci.yml: poshqc` | `_poshqc.yml: poshqc` | `Invoke-PoshQCTest -Root "${{ github.workspace }}"` | `config/poshqc-scan.json` scans `scripts`, `tests/powershell`, and `tests/scripts`; `PoshQC.Testing.psm1` recursively enumerates `*.Tests.ps1` | 12/12 | 118 listed | Required calling job; failures propagate by default |
| Bash | `.github/workflows/ci.yml: shell-coverage` | `_shell-coverage.yml: shell-coverage` | `bash scripts/bash/shell-qc.sh test --coverage` | `shell_qc_lib.sh` passes existing `tests/shell` and `tests/bash` directories to Bats | 2/2 | 21 listed | Required calling job; failures propagate by default |

The root CI workflow triggers these jobs for pushes and pull requests targeting `main` or `development`. Every mapped test job is present in the root workflow, and no test command is optional or configured to continue after failure.

## Machine discovery results

1. `poetry run pytest --collect-only -q --no-cov <21 changed Python test paths>`: exit `0`; `454` tests collected in `0.45s`; `21/21` changed files emitted node IDs; process elapsed `1,455 ms`.
2. `npm --prefix extensions/drm-copilot run test:unit -- --listTests --runInBand`: exit `0`; `193` test files listed; `23/23` changed TypeScript files matched; process elapsed `541 ms`.
3. Parsed `config/poshqc-scan.json` and applied the repository owner at `scripts/powershell/PoshQC/PoshQC.Testing.psm1:246`: `118` Pester files listed; `12/12` changed Pester files matched.
4. Sourced `scripts/bash/shell_qc_lib.sh` and invoked `find_bats_test_dirs`: exit `0`; `tests/shell` resolved; `21` Bats files listed; `2/2` changed Bats files matched.
5. A read-only Python validator parsed TOML, JSON, and all workflow YAML files with `yaml.BaseLoader`, verified the four root-to-reusable workflow calls and their exact test commands, checked all `58` test paths plus both parity fixtures, and asserted zero workflow diff. Result: `suite_unmapped=0`, `required_backstop_unmapped=1`, `unmapped_total=1`.

## Baseline-owned changed test inventory

`A` means absent at baseline and added by issue #467. `M` means present at baseline and modified by issue #467.

### Python: 21

- [A] `tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py`
- [A] `tests/scripts/dev_tools/test_parallel_completion_receipts.py`
- [A] `tests/scripts/dev_tools/test_parallel_drift_parity.py`
- [M] `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`
- [A] `tests/scripts/dev_tools/test_parallel_mutation_parity.py`
- [A] `tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py`
- [A] `tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py`
- [A] `tests/scripts/dev_tools/test_parallel_resume_truth.py`
- [M] `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
- [M] `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- [M] `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`
- [A] `tests/scripts/dev_tools/test_push_down_codex_portable_assets.py`
- [A] `tests/scripts/dev_tools/test_push_down_codex_routing_merge.py`
- [M] `tests/scripts/dev_tools/test_resolve_codex_deployment.py`
- [M] `tests/scripts/dev_tools/test_resolve_codex_topology.py`
- [M] `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py`
- [A] `tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`
- [M] `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py`
- [M] `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutation_modes.py`
- [M] `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`
- [M] `tests/scripts/dev_tools/test_validate_parallel_planner_state.py`

### Extension TypeScript: 23

- [M] `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`
- [M] `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`
- [A] `extensions/drm-copilot/test/lib/push-down/codex-portable-assets.test.ts`
- [A] `extensions/drm-copilot/test/lib/push-down/codex-routing-merge.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/codex-topology-resolver.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-drift-parity.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-mutation-parity.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-mutation-receipts.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-receipt-cohort.test.ts`
- [A] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-resume-truth.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts`
- [M] `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`
- [M] `extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts`
- [M] `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts`

### Pester: 12

- [A] `tests/scripts/codex-hooks/codex-child-launch-resume-core.Tests.ps1`
- [M] `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
- [A] `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1`
- [M] `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`
- [M] `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`
- [M] `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-child-post-session.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-child-resume-live-truth.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-completion-compensating-controls.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`
- [A] `tests/scripts/codex-hooks/parallel-runtime-lifecycle.Tests.ps1`

### Bats: 2

- [M] `tests/shell/parallel_bash_manifest_membership.bats`
- [M] `tests/shell/parallel_payload_only.bats`

The three unchanged P5-T9 Bats dependencies—`parallel_manifest_validate.bats`, `parallel_cohorts.bats`, and `parallel_cohorts_parity.bats`—are also present among the `21` recursively discovered Bats files and passed in P5-T9.

### Shared parity fixtures: 2

- [A] `tests/fixtures/parallel-orchestration/drift-parity.json`
- [A] `tests/fixtures/parallel-orchestration/mutation-parity.json`

Both fixtures are consumed by the paired Python and TypeScript drift/mutation parity suites, so they require no independent CI selector.

## Named contract coverage

- Pack and publisher owners map to the Python and extension TypeScript jobs through the recursive selectors, including manifest completeness, pack selection, resource contracts, portable assets, and additive routing merge.
- Drift and mutation parity owners map in both Python and TypeScript; both shared fixtures are present.
- `codex-parallel-registered-transport.Tests.ps1` maps to PoshQC.
- `parallel_payload_only.bats` and `parallel_bash_manifest_membership.bats` map to shell coverage.
- `parallel-completion-compensating-controls.Tests.ps1` maps to PoshQC and is executable, but its required independent CI status is not registered.

## Demonstrated P5-T11 delta

All `58/58` executable suites are discovered. No Pytest, Jest, PoshQC, Bats, pack, parity, registration, or payload selector change is required. `_shell-coverage.yml` already covers the changed Bats paths and must remain unchanged.

The required G16 backstop is the sole gap: no workflow currently defines a job key named `parallel-completion-gate`. The smallest monotonic P5-T11 delta is:

1. Extend `parallel-completion-compensating-controls.Tests.ps1` with a real-workflow assertion that the root job exists, calls the existing PoshQC reusable workflow, and is not optional or non-failing.
2. Add a root `.github/workflows/ci.yml` job named `parallel-completion-gate` that reuses `./.github/workflows/_poshqc.yml`. The existing reusable workflow already recursively runs the full parallel completion, receipt, and negative-state Pester contracts, and its failure propagates to the calling job.

No reusable workflow selector change is demonstrated. `NO_WORKFLOW_DELTA_REQUIRED` is not applicable because the required G16 status is missing.

## Terminal state

- Workflow diff before P5-T11: `0` files.
- `.claude/**`: `150` tracked files and `0` status entries.
- `.codex/state`: absent.
- `git diff --check`: exit `0`; only the existing non-failing `testResults.xml` CRLF-to-LF warning was emitted.
- P5-T11 work: not started.

P5_T10_RESULT: PASS_WITH_REQUIRED_BACKSTOP_GAP
SUITE_UNMAPPED: 0
REQUIRED_BACKSTOP_UNMAPPED: 1
UNMAPPED_TOTAL: 1
