#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unhandled-error behaviour of every SubagentStop validator that uses the shared envelope helper (issue #928).

.DESCRIPTION
    A SubagentStop hook blocks only with exit code 2; an unhandled error that escapes the validation
    call ends the script with exit code 1, which does not block. U1 drives each validator through the
    & route with Read-SubagentStopEnvelope mocked to throw, and asserts that the validator catches the
    error, writes a reason that starts with its own prefix to stderr, and exits with code 2. U2 keeps
    the U1 table complete: every hook under .claude/hooks that dot-sources subagentstop-envelope.ps1
    inside a guarded try must have a U1 row, and every U1 row must name such a hook.
    Standard input and standard error are swapped for in-memory readers and writers and restored after
    each invocation. No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    $script:ValidatorRows = @(
        @{ Hook = '.claude/hooks/validate-discovery-artifact-gate.ps1'; Parameters = @{}; Prefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:' }
        @{ Hook = '.claude/hooks/validate-executor-output.ps1'; Parameters = @{}; Prefix = 'validate-executor-output:' }
        @{ Hook = '.claude/hooks/validate-feature-review-coverage.ps1'; Parameters = @{}; Prefix = 'validate-feature-review-coverage:' }
        @{ Hook = '.claude/hooks/validate-orchestrator-output.ps1'; Parameters = @{}; Prefix = 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED:' }
        @{ Hook = '.claude/hooks/validate-planner-output.ps1'; Parameters = @{}; Prefix = 'validate-planner-output:' }
        @{ Hook = '.claude/hooks/validate-pr-author-output.ps1'; Parameters = @{}; Prefix = 'PR_AUTHOR_OUTPUT_MISSING:' }
        @{ Hook = '.claude/hooks/validate-prd-feature-output.ps1'; Parameters = @{}; Prefix = 'validate-prd-feature-output:' }
        @{ Hook = '.claude/hooks/validate-required-artifact-output.ps1'; Parameters = @{ AgentName = 'status-updater'; RequiredArtifact = @('status-path|^docs/.+$|status artifact') }; Prefix = 'validate-required-artifact-output:' }
        @{ Hook = '.claude/hooks/validate-task-researcher-output.ps1'; Parameters = @{}; Prefix = 'validate-task-researcher-output:' }
    )
    $script:TableHooks = @($script:ValidatorRows | ForEach-Object { $_.Hook })
    $script:StatementTerminatingRows = @(
        @{ Hook = '.claude/hooks/validate-discovery-artifact-gate.ps1'; Parameters = @{}; Prefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:' }
        @{ Hook = '.claude/hooks/validate-pr-author-output.ps1'; Parameters = @{}; Prefix = 'PR_AUTHOR_OUTPUT_MISSING:' }
    )
}

Describe 'SubagentStop validator unhandled-error block (issue #928)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        . (Join-Path $script:RepoRoot '.claude/hooks/subagentstop-envelope.ps1')
        # Baseline null mocks for the epic-state read seams in the loaded-source closure (issue #737 guard).
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-ArtifactFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ArtifactFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChangedLanguageSet' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-JacocoRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-LcovRepoCoverage' -Surface 'Codex' }
        $script:EnvelopeJson = '{"session_id":"u-928","hook_event_name":"SubagentStop"}'
        $script:HelperDotSourceText = ". (Join-Path `$PSScriptRoot 'subagentstop-envelope.ps1')"

        function Invoke-ValidatorUnderTest {
            <#
            .SYNOPSIS
                Runs one validator through the & route with in-memory stdin and stderr.
            .OUTPUTS
                A hashtable with ExitCode, Stderr and Thrown (the captured exception, or $null).
            #>
            param(
                [Parameter(Mandatory)] [string] $HookPath,
                [Parameter(Mandatory)] [hashtable] $Parameters
            )

            $originalIn = [Console]::In
            $originalError = [Console]::Error
            $savedFailures = Get-Variable -Name HookDependencyFailures -Scope Script -ErrorAction SilentlyContinue
            $savedGuardFlag = Get-Variable -Name HookDependencyGuardLoadFailed -Scope Script -ErrorAction SilentlyContinue
            $savedLastExitCode = $global:LASTEXITCODE
            $stderr = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [Console]::SetIn([System.IO.StringReader]::new($script:EnvelopeJson))
                [Console]::SetError($stderr)
                $global:LASTEXITCODE = 0
                try {
                    & $HookPath @Parameters
                }
                catch {
                    $thrown = $_.Exception
                }
                $exitCode = $global:LASTEXITCODE
            }
            finally {
                [Console]::SetIn($originalIn)
                [Console]::SetError($originalError)
                if ($null -eq $savedFailures) { Remove-Variable -Name HookDependencyFailures -Scope Script -ErrorAction SilentlyContinue }
                else { Set-Variable -Name HookDependencyFailures -Scope Script -Value $savedFailures.Value }
                if ($null -eq $savedGuardFlag) { Remove-Variable -Name HookDependencyGuardLoadFailed -Scope Script -ErrorAction SilentlyContinue }
                else { Set-Variable -Name HookDependencyGuardLoadFailed -Scope Script -Value $savedGuardFlag.Value }
                $global:LASTEXITCODE = $savedLastExitCode
            }

            return @{ ExitCode = $exitCode; Stderr = $stderr.ToString(); Thrown = $thrown }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'U1: <Hook> blocks with exit 2 when the validation call throws' -ForEach $script:ValidatorRows {
        # Arrange
        Mock Read-SubagentStopEnvelope { throw 'simulated unhandled error (issue #928)' }
        Mock Import-Module { }
        $hookPath = Join-Path $script:RepoRoot $Hook

        # Act
        $outcome = Invoke-ValidatorUnderTest -HookPath $hookPath -Parameters $Parameters

        # Assert
        $outcome.Thrown | Should -BeNullOrEmpty -Because "$Hook must catch the validation error instead of letting it escape (exit 1 does not block)"
        $outcome.ExitCode | Should -Be 2 -Because "$Hook must block the SubagentStop with exit code 2"
        $outcome.Stderr.StartsWith($Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the stderr reason must start with '$Prefix'; actual stderr: '$($outcome.Stderr)'"
        $outcome.Stderr | Should -BeLike '*simulated unhandled error (issue #928)*' -Because 'the reason must carry the first line of the error message'
        Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly
    }

    It 'U1-ST: <Hook> blocks with exit 2 when the validation call raises a statement-terminating error' -ForEach $script:StatementTerminatingRows {
        # Arrange: a .NET method exception is statement-terminating, unlike the script-terminating throw used by U1.
        Mock Read-SubagentStopEnvelope { [System.Runtime.ExceptionServices.ExceptionDispatchInfo]::Capture([System.InvalidOperationException]::new('simulated statement-terminating error (issue #928)')).Throw() }
        Mock Import-Module { }
        $hookPath = Join-Path $script:RepoRoot $Hook
        $global:LASTEXITCODE = 0

        # Act
        $outcome = Invoke-ValidatorUnderTest -HookPath $hookPath -Parameters $Parameters

        # Assert
        $outcome.Thrown | Should -BeNullOrEmpty -Because "$Hook must catch the statement-terminating error instead of letting it escape"
        $outcome.ExitCode | Should -Be 2 -Because "$Hook must block the SubagentStop with exit code 2"
        $outcome.Stderr.StartsWith($Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the stderr reason must start with '$Prefix'; actual stderr: '$($outcome.Stderr)'"
        $outcome.Stderr | Should -BeLike '*simulated statement-terminating error (issue #928)*' -Because 'the reason must carry the first line of the error message'
        Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly
        $global:LASTEXITCODE | Should -Be 0 -Because 'Invoke-ValidatorUnderTest restores the previous LASTEXITCODE'
    }

    It 'U2: has a row for every hook that dot-sources subagentstop-envelope.ps1 and no other' -TestCases @(@{ TableHooks = $script:TableHooks }) {
        # Arrange
        $hookFiles = Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot '.claude/hooks') -Filter '*.ps1' -File

        # Act
        $discovered = foreach ($file in $hookFiles) {
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
            $guardedDotSource = $ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.TryStatementAst] -and
                    $node.Body.Statements.Count -eq 1 -and
                    $node.Body.Statements[0].Extent.Text -eq $script:HelperDotSourceText
                }, $true)
            if (@($guardedDotSource).Count -gt 0) { '.claude/hooks/' + $file.Name }
        }

        # Assert
        @($discovered).Count | Should -BeGreaterThan 0 -Because 'at least one hook dot-sources the envelope helper'
        $difference = Compare-Object -ReferenceObject @($TableHooks) -DifferenceObject @($discovered)
        $difference | Should -BeNullOrEmpty -Because "the U1 table must list exactly the hooks that dot-source the helper; difference: $(($difference | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }) -join ', ')"
    }
}
