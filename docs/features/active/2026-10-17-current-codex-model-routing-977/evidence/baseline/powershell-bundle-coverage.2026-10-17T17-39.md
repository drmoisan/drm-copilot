Timestamp: 2026-10-17T17:39:54.597860+00:00
Command: foreach ($target in @('resolver-1','resolver-2','hook')) { & pwsh -NoProfile -File 'SCRATCH/issue-977-bundle.ps1' -Kind baseline -Target $target; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
EXIT_CODE: 0
Output Summary:

ACTUAL_TARGET: extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1; lines 68/68 (100%); tests passed=28 failed=0 skipped=0.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1; lines 103/192 (53.6458%); tests passed=50 failed=0 skipped=0.
        $receipt.expires_at = '2026-07-10T21:00:00Z'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a checkpoint that does not match the epic child context' {
        $receipt = Get-TestLaunchReceipt -Context epic_execution_child
        $receipt.checkpoint_path = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-planner-state.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a receipt outside the trusted launch-artifact root' {
        $receipt = Get-TestLaunchReceipt
        $receipt.receipt_path = Join-Path $script:RepoRoot 'outside.receipt.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }
}
 318ms (219ms|64ms)
Tests completed in 1.42s
Tests Passed: 50, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 55.28% / 0%. 246 analyzed Commands in 1 File.
ACTUAL_TARGET: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1; lines 103/192 (53.6458%); tests passed=50 failed=0 skipped=0.

Full sanitized output: SCRATCH/issue-977-baseline-powershell-bundle-coverage.log
