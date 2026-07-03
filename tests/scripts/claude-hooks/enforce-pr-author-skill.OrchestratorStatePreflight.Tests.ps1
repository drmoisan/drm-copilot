#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Orchestrator-state preflight coverage for enforce-pr-author-skill.ps1, split from
    enforce-pr-author-skill.Tests.ps1 to keep both files under the repository's 500-line cap
    (mirrors the PoshQC.Tests.ps1 / PoshQC.Comprehensive.Tests.ps1 / PoshQC.EntryPoints.Tests.ps1
    concern-based split already established in tests/scripts/powershell/PoshQC/).
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected $Invoker stubs mirror the production scriptblock signature param($Path) for testing')]
param()

Describe 'enforce-pr-author-skill.ps1 (orchestrator-state preflight)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
    }

    Context 'orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        }

        It 'blocks gh pr create --body-file when the checkpoint is missing' {
            # Mocks a failing $Invoker seam representing a missing checkpoint: the validator
            # subprocess reports a non-zero exit with no output text, so the hook falls back to
            # its generic "checkpoint missing" summary.
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                @{ HasErrors = $true; ErrorText = '' }
            }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
        }

        It 'blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails' {
            # Mocks a failing $Invoker seam representing a checkpoint that exists but fails
            # --require-pr-creation-ready: the validator returns error text that must be
            # summarized into the block reason for operator diagnosis.
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                @{ HasErrors = $true; ErrorText = 'orchestrator-state: cycle 2 plan_path is empty' }
            }
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'cycle 2 plan_path is empty'
        }
    }

    Context 'Invoke-OrchestratorStatePreflight (direct seam tests)' {
        It 'reports HasErrors when the injected $Invoker returns a non-zero exit code' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 1; Output = 'some error' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'some error'
        }

        It 'reports no errors when the injected $Invoker returns exit 0' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 0; Output = 'orchestrator-state validation passed: x.json' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeFalse
        }

        It 'reports HasErrors with empty ErrorText when the injected $Invoker returns a non-zero exit with no output' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 1; Output = '' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -BeNullOrEmpty
        }

        It 'defaults ExitCode/Output when the injected $Invoker result carries neither property' {
            $stub = { param($Path) [pscustomobject]@{} }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -BeNullOrEmpty
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'blocks gh pr create --body-file end-to-end via the real validator subprocess (exit 0, deny, ORCHESTRATOR_STATE_PREFLIGHT_FAILED)' {
            # Spawns a real, separate pwsh process. Dot-sources the hook (bypassing its entrypoint
            # guard) and points the context-artifact seam at a real, permanently-existing file
            # (the hook script itself) so Case C does not intercept first -- the same "real seam,
            # stand-in existing file" pattern used elsewhere in enforce-pr-author-skill.Tests.ps1,
            # so no temporary file is created -- then replays the hook's own entrypoint logic. The
            # checkpoint seam is also overridden to a deliberately-nonexistent, non-temp-file
            # sibling path (a filename that is guaranteed absent from a checked-out repository) so
            # the real Invoke-OrchestratorStatePreflight default $Invoker's Python validator
            # subprocess deterministically reports a missing-checkpoint failure, independent of the
            # real, mutable artifacts/orchestration/orchestrator-state.json checkpoint's current
            # content (which is not structurally guaranteed to remain incomplete/absent).
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}'
                $innerScript = @'
. '{0}'
$script:PrContextArtifactPath = '{0}'
$script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'
try {{
    $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT
}} catch {{
    Write-Error $_
    exit 1
}}
$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
exit 0
'@ -f $script:HookPath
                $out = & $script:PwshExe -NoProfile -Command $innerScript
                $LASTEXITCODE | Should -Be 0
                $parsed = $out | ConvertFrom-Json
                $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
