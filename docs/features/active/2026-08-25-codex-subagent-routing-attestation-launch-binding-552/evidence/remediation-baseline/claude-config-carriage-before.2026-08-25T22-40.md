Timestamp: 2026-08-25T22-40
Command: Get-FileHash/Get-Item/git diff --no-index for the three routing files; git status --porcelain=v1 --untracked-files=all
EXIT_CODE: 0
Output Summary: The repository root and resources/config routing files are byte-identical (SHA-256 967778EC8ABB0B0C538953AFFAD41BDAB0EC134646675199652BEBE8E97FFCC1, 11330 bytes); their diff exited 0. The Claude-customizations routing copy differs (SHA-256 D2138422CDA73225DA080F8B33E1EB0D6A9AED3D3CCCB1D69085370A5F9F67F8, 11306 bytes); both comparisons against it exited 1. The status snapshot below is the P9-T9 baseline.

## Routing-file manifest

| Path | SHA-256 | Bytes |
| --- | --- | ---: |
| `config/orchestration-routing.json` | `967778EC8ABB0B0C538953AFFAD41BDAB0EC134646675199652BEBE8E97FFCC1` | 11330 |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | `967778EC8ABB0B0C538953AFFAD41BDAB0EC134646675199652BEBE8E97FFCC1` | 11330 |
| `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | `D2138422CDA73225DA080F8B33E1EB0D6A9AED3D3CCCB1D69085370A5F9F67F8` | 11306 |

## Pairwise `git diff --no-index` exit codes

| Pair | EXIT_CODE |
| --- | ---: |
| root <> `resources/config` | 0 |
| root <> `resources/claude-customizations/config` | 1 |
| `resources/config` <> `resources/claude-customizations/config` | 1 |

## Worktree-status baseline

```text
A  .codex/agents/commit-steward-c1.toml
A  .codex/agents/commit-steward-c2.toml
A  .codex/agents/commit-steward-c3-elevated.toml
A  .codex/agents/commit-steward-c3.toml
A  .codex/agents/commit-steward-c4.toml
M  .codex/agents/commit-steward.toml
M  config/orchestration-routing.json
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/other/hook-failures.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/other/poshqc-settings-mirror-sync.2026-08-25T21-39.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/other/remediation-scope-check.2026-08-25T21-41.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/other/remediation-scope-check.2026-08-25T21-46.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-python-black.2026-08-25T22-07.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-python-black.2026-08-25T22-08.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-python-pyright.2026-08-25T22-08.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-python-ruff.2026-08-25T22-08.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-python-test-coverage.2026-08-25T22-08.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/commit-steward-routing-scope-final.2026-08-25T22-08.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/poshqc-bundled-parity-final.2026-08-25T21-52.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/powershell-analyze.2026-08-25T21-47.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/powershell-format.2026-08-25T21-47.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/powershell-test-after-counter-reset.2026-08-25T21-38.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/remediation-scope-final.2026-08-25T21-53.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/commit-steward-c3-fail-before.2026-08-25T22-03.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/commit-steward-c3-pass-after.2026-08-25T22-06.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/commit-steward-routing-focused-pytest.2026-08-25T22-06.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/commit-steward-routing-generator-drift.2026-08-25T22-06.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/poshqc-bundled-parity-fail-before.2026-08-25T17-36.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/poshqc-bundled-parity-pass-after.2026-08-25T21-39.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/batch-counter-transition.2026-08-25T18-20.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/commit-steward-routing-before.2026-08-25T22-03.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/commit-steward-routing-instructions-read.2026-08-25T22-03.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/commit-steward-routing-python-test-coverage.2026-08-25T22-03.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/phase0-instructions-read.2026-08-25T17-34.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/poshqc-settings-parity-before.2026-08-25T17-34.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-analyze.2026-08-25T17-37.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-analyze.2026-08-25T17-44.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-analyze.2026-08-25T17-55.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-format.2026-08-25T17-36.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-format.2026-08-25T17-43.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-format.2026-08-25T17-55.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-test-coverage.2026-08-25T17-42.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-test-coverage.2026-08-25T17-46.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/powershell-test-coverage.2026-08-25T18-12.md
A  docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/remediation-inputs.2026-08-25T17-20.md
AM docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/remediation-plan.2026-08-25T17-20.md
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c1.toml
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c2.toml
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c3-elevated.toml
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c3.toml
A  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c4.toml
M  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward.toml
M  extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
M  extensions/drm-copilot/resources/config/orchestration-routing.json
M  extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts
 M extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts
 M extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts
M  scripts/dev_tools/generate_codex_agent_variants.py
M  scripts/dev_tools/resolve_codex_deployment.py
M  tests/scripts/dev_tools/test_codex_model_policy_config_parity.py
M  tests/scripts/dev_tools/test_generate_codex_agent_variants.py
M  tests/scripts/dev_tools/test_resolve_codex_deployment.py
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/other/mcp-validator-parity-root-bundle-scope.2026-08-25T22-31.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-plan-validator.2026-08-25T22-36.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-scope-final.2026-08-25T22-35.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-typescript-build.2026-08-25T22-34.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-typescript-format.2026-08-25T22-32.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-typescript-lint.2026-08-25T22-32.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-typescript-typecheck.2026-08-25T22-33.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/qa-gates/mcp-validator-parity-typescript-unit-coverage.2026-08-25T22-34.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/mcp-validator-commit-steward-fail-before.2026-08-25T22-28.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/regression-testing/mcp-validator-parity-source-pass-after.2026-08-25T22-30.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/mcp-validator-parity-before.2026-08-25T22-27.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/mcp-validator-parity-instructions-read.2026-08-25T22-26.md
?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence/remediation-baseline/mcp-validator-parity-typescript-test-coverage.2026-08-25T22-29.md
```
