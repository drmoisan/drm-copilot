Timestamp: 2026-10-17T18:06:18.218478+00:00
Command: foreach ($target in @('resolver-1','resolver-2','hook')) { & pwsh -NoProfile -NonInteractive -File 'SCRATCH/issue-977-bundle.ps1' -Kind auxiliary -Target $target; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
EXIT_CODE: 0
Output Summary:

ACTUAL_TARGET: extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%); tests passed=86 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).
ACTUAL_TARGET: extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%); tests passed=86 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-bundle-coverage.log
