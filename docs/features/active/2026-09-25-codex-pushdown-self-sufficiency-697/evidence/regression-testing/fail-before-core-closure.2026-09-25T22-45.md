# Fail-Before: core.json Closure Guard (Issue #697, AC-5.2 red)

Timestamp: 2026-09-25T22-45
Command: poetry run pytest tests/scripts/dev_tools/test_codex_core_manifest_closure.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1 failed, 4 passed`. The failure is `test_core_manifest_contains_registered_hook_closure_and_resolver_paths` with `core.json is missing:` exactly these 17 paths:
- `.codex/hooks/check-powershell-test-purity.ps1`
- `.codex/hooks/check-python-test-purity.ps1`
- `.codex/hooks/enforce-checkpoint-monotonic.ps1`
- `.codex/hooks/enforce-completion-consistency.ps1`
- `.codex/hooks/enforce-completion-helpers.ps1`
- `.codex/hooks/enforce-evidence-locations.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-powershell-batch-budget.ps1`
- `.codex/hooks/enforce-promotion-mcp-only.ps1`
- `.codex/hooks/enforce-python-batch-budget.ps1`
- `.codex/hooks/validate-bash.ps1`
- `.codex/hooks/validate-feature-review-coverage.ps1`
- `.codex/lib/codex-routing/CodexDeployment.psm1`
- `.codex/lib/codex-routing/CodexTopology.psm1`
- `.codex/scripts/Resolve-CodexDeployment.ps1`
- `.codex/scripts/Resolve-CodexTopology.ps1`
- `.codex/scripts/codex-routing-cli-common.ps1`
