#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the epic-invocation-nesting-depth.ps1 hook helper (issue #1138).

.DESCRIPTION
    Drives the nesting-depth decision with Get-SubagentSpawnDepthSetting mocked in each It, so
    no test sets an environment variable. The hook-integration context dot-sources
    enforce-epic-invocation-origin.ps1 and checks that the depth deny precedes the non-gated
    allow, that the origin rule is unchanged, and that a failed helper import denies.
    No test creates, renames, moves, or deletes a file.
#>

Describe 'epic-invocation-nesting-depth.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
        $script:HelperPath = Join-Path $script:RepoRoot '.claude/hooks/epic-invocation-nesting-depth.ps1'
        $script:HookPath = Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-invocation-origin.ps1'
        . $script:HelperPath
        $script:DepthSetting = $null
        $script:GatedCoordinators = @('epic-planner', 'epic-orchestrator', 'parallel-planner', 'parallel-orchestrator')
    }

    Context 'helper decision' {
        It 'allows when unset' {
            # Arrange
            Mock Get-SubagentSpawnDepthSetting { $script:DepthSetting }
            foreach ($value in @($null, '', '   ')) {
                $script:DepthSetting = $value
                # Act
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target 'epic-planner' -Caller $null
                # Assert
                $reason | Should -BeNullOrEmpty -Because "value '$value' is treated as unset"
            }
        }

        It 'allows at or above 3' {
            Mock Get-SubagentSpawnDepthSetting { $script:DepthSetting }
            foreach ($value in @('3', '4', '10', ' 4 ', '99999999999')) {
                $script:DepthSetting = $value
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target 'epic-orchestrator' -Caller $null
                $reason | Should -BeNullOrEmpty -Because "value '$value' is at least 3"
            }
        }

        It 'denies below 3 with remedy text' {
            Mock Get-SubagentSpawnDepthSetting { $script:DepthSetting }
            foreach ($value in @('2', '1', '0', '-1', '-99999999999')) {
                $script:DepthSetting = $value
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target 'parallel-planner' -Caller $null
                $reason | Should -Not -BeNullOrEmpty -Because "value '$value' is below 3"
                $reason.StartsWith('NESTING_DEPTH_INSUFFICIENT:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
                foreach ($literal in @('CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH', 'raise or unset', 'main-session fallback')) {
                    $reason.Contains($literal) | Should -BeTrue -Because "the reason for '$value' must name '$literal': $reason"
                }
            }
        }

        It 'denies non-integer value' {
            Mock Get-SubagentSpawnDepthSetting { $script:DepthSetting }
            foreach ($value in @('two', '2.5')) {
                $script:DepthSetting = $value
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target 'parallel-orchestrator' -Caller $null
                $reason | Should -Not -BeNullOrEmpty -Because "value '$value' is not an integer"
                $reason.StartsWith('NESTING_DEPTH_INSUFFICIENT:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
                $reason.Contains('is not an integer') | Should -BeTrue -Because $reason
            }
        }

        It 'caller and target matrix' {
            # Arrange: a limit of 2 denies every pair the check applies to.
            Mock Get-SubagentSpawnDepthSetting { '2' }
            $applying = @(
                foreach ($coordinator in $script:GatedCoordinators) {
                    [pscustomobject]@{ Caller = $null; Target = $coordinator }
                    [pscustomobject]@{ Caller = $coordinator; Target = 'orchestrator' }
                }
            )
            $notApplying = @(
                [pscustomobject]@{ Caller = 'orchestrator'; Target = 'atomic-planner' }
                [pscustomobject]@{ Caller = $null; Target = 'orchestrator' }
                [pscustomobject]@{ Caller = 'orchestrator'; Target = 'epic-planner' }
                [pscustomobject]@{ Caller = 'epic-planner'; Target = 'pr-author' }
            )
            # Act and Assert
            $applying.Count | Should -Be 8
            foreach ($pair in $applying) {
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target $pair.Target -Caller $pair.Caller
                $reason | Should -Not -BeNullOrEmpty -Because "caller '$($pair.Caller)' to '$($pair.Target)' is in the chain"
            }
            foreach ($pair in $notApplying) {
                $reason = Get-EpicInvocationNestingDepthDenyReason -Target $pair.Target -Caller $pair.Caller
                $reason | Should -BeNullOrEmpty -Because "caller '$($pair.Caller)' to '$($pair.Target)' is outside the chain"
            }
        }

        It 'seam is the only environment reader' {
            # Arrange
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperPath, [ref] $tokens, [ref] $parseErrors)
            $seam = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-SubagentSpawnDepthSetting' }, $true)
            # Act
            $environmentReads = @($ast.FindAll({
                        param($node)
                        ($node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Member.Extent.Text -eq 'GetEnvironmentVariable') -or
                        ($node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.DriveName -eq 'env')
                    }, $true))
            $outsideSeam = @($environmentReads | Where-Object { $_.Extent.StartOffset -lt $seam.Extent.StartOffset -or $_.Extent.StartOffset -ge $seam.Extent.EndOffset })
            # Assert
            @($parseErrors).Count | Should -Be 0
            $seam | Should -Not -BeNullOrEmpty
            $environmentReads.Count | Should -BeGreaterThan 0 -Because 'the seam itself reads the variable'
            $outsideSeam.Count | Should -Be 0 -Because (@($outsideSeam | ForEach-Object { $_.Extent.Text }) -join '; ')
        }

        It 'reads the seam without mocking' {
            # Arrange: nothing is set; the read is compared with the process value.
            $expected = [Environment]::GetEnvironmentVariable('CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH')
            # Act
            $actual = Get-SubagentSpawnDepthSetting
            # Assert
            [object]::Equals($actual, $expected) | Should -BeTrue -Because "seam '$actual' and process '$expected' must agree"
        }
    }

    Context 'hook integration' {
        BeforeAll {
            . $script:HookPath

            function ConvertTo-NestingDepthEnvelope {
                param(
                    [Parameter(Mandatory)]
                    [string] $Target,

                    [string] $CallerAgentType
                )

                $envelope = [ordered]@{ session_id = 'nesting-1138'; tool_name = 'Agent' }
                if ($PSBoundParameters.ContainsKey('CallerAgentType')) {
                    $envelope.agent_type = $CallerAgentType
                }
                $envelope.tool_input = [ordered]@{ subagent_type = $Target; prompt = 'delegate' }
                return ($envelope | ConvertTo-Json -Compress -Depth 5)
            }
        }

        It 'denies a main-thread epic-planner delegation below 3' {
            Mock Get-SubagentSpawnDepthSetting { '2' }
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw (ConvertTo-NestingDepthEnvelope -Target 'epic-planner')
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('NESTING_DEPTH_INSUFFICIENT:', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'denies an epic-planner delegation to orchestrator below 3' {
            Mock Get-SubagentSpawnDepthSetting { '2' }
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw (ConvertTo-NestingDepthEnvelope -Target 'orchestrator' -CallerAgentType 'epic-planner')
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('NESTING_DEPTH_INSUFFICIENT:', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'keeps the origin rule for an orchestrator caller' {
            Mock Get-SubagentSpawnDepthSetting { '2' }
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw (ConvertTo-NestingDepthEnvelope -Target 'epic-planner' -CallerAgentType 'orchestrator')
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('EPIC_INVOCATION_ORIGIN_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'guarded import failure denies' {
            # Arrange: fail only the helper dot-source (the B1 pattern of hook-dependency-failure.Claude.Tests.ps1).
            Mock Get-SubagentSpawnDepthSetting { $null }
            $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
            Mock Join-Path {
                if ($ChildPath -eq 'epic-invocation-nesting-depth.ps1') { throw 'simulated load failure: epic-invocation-nesting-depth.ps1' }
                & $originalJoinPath @PesterBoundParameters
            }
            # Act
            try {
                . $script:HookPath
                $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw (ConvertTo-NestingDepthEnvelope -Target 'epic-planner')
            }
            finally {
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
                $script:HookDependencyGuardLoadFailed = $false
            }
            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason.StartsWith('EPIC_INVOCATION_ORIGIN_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
            $reason.Contains('epic-invocation-nesting-depth.ps1') | Should -BeTrue -Because $reason
        }
    }
}
