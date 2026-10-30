# P15-T8 verification — host observations and the sentinel grant

Timestamp: 2026-10-29T21-52
Command: sh SCRATCH/issue-980-p15-pssa.sh <3 files>; sh SCRATCH/issue-980-pester.sh tests/scripts/claude-lib/discovery-validation/{DiscoveryObservation,DiscoveryValidation.Manifest,DiscoveryAuthorization}.Tests.ps1; poetry run pytest -q --no-cov tests/scripts/dev_tools/test_push_down_{claude_pack_manifest_completeness,codex_and_agents_pack_manifest_completeness,pack_manifest_dependency_closure,claude_resource_contracts,codex_and_agents_resource_contracts}.py
EXIT_CODE: 0
Output Summary:
- Static stages: 3 files, 0 reformatted, 0 PSScriptAnalyzer findings.
- Pester: 83 total, 83 passed, 0 failed. The new DiscoveryObservation.Tests.ps1 covers: record keys equal the committed host-observation example keys; sentinel Bash denied SHELL and observed with no grant fields; sentinel tool allowed SENTINEL with grant fields tool, input_sha256, expires_at and state issued; a sentinel tool call with no agent_id observed with null identity; a second write to the same reference refused with STORE; the nonce reference when no tool-call identifier is present; sentinel-envelope recognition.
- DiscoveryAuthorization.Tests.ps1 sentinel cases (`Get-DiscoveryPreToolDecision for the sentinel`) pass. They confirm that the store's only write for a sentinel envelope is the observation: no root grant and no tool authorization.
- Push-down contracts: 45 passed.
- Size: .claude/lib/discovery-validation/DiscoveryObservation.psm1 is 217 lines, within the 300-line limit.

## Changes

- DiscoveryObservation.psm1 was created by the P15-T6 commit as the gate's delegation target. Its behavior matched this task's text, so it was not edited.
- Added tests/scripts/claude-lib/discovery-validation/DiscoveryObservation.Tests.ps1.
- Registered the module in DiscoveryValidation.Manifest.Tests.ps1 (ExpectedPaths and the Codex published-name list) and in the Claude and Codex core.json pack manifests. The test's assertion that every on-disk module is registered now passes.
