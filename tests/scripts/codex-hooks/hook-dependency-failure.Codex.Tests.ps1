#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Dependency-failure behaviour of every registered Codex PreToolUse and SubagentStop hook (issue #786).

.DESCRIPTION
    Hooks come from .codex/config.toml and their direct edges from the AST at discovery time. B1 fails
    one direct dot-source at a time with a Join-Path mock and drives the hook through the & route: a
    PreToolUse hook must emit the deny JSON at exit 0 with its leading token naming the dependency; a
    SubagentStop hook must exit 2 with the reason on stderr. B2 and B3 fail the helper bootstrap; B4
    keeps the reason-prefix table complete. X1 and X2 cover the D3 conditional dot-source of
    .codex/scripts/epic-child-launch-contract.ps1 (absence is a skip; a present file that fails to load
    denies), and X3 the validate-bash token. No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
    . (Join-Path $PSScriptRoot '../claude-runtime/HookImportFailureExemptions.Helpers.ps1')
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
    $exemptions = @(Get-HookImportFailureExemption)
    $registrations = @(Get-HookRegistration -ClaudeRoot $repoRoot -CodexRoot $repoRoot | Where-Object { $_.Surface -eq 'codex' -and $_.Hook -ne 'INLINE' })
    $script:HookRows = @($registrations | ForEach-Object { @{ Event = $_.Event; Hook = $_.Hook } })
    $script:EdgeRows = foreach ($r in $registrations) {
        $text = Get-Content -LiteralPath (Join-HookGraphPath -Left $repoRoot -Right $r.Hook) -Raw
        $listed = @($exemptions | Where-Object { $_.Kind -eq 'Handler' -and $_.HandlerFile -eq $r.Hook } | ForEach-Object { $_.Leaf })
        foreach ($edge in @(Get-HookScriptEdge -ScriptText $text -SourcePath $r.Hook | Where-Object { -not $_.Runtime -and -not $_.Conditional -and $_.Leaf -ne 'hook-dependency-guard.ps1' -and $listed -notcontains $_.Leaf })) {
            $child = if ($edge.ChildPathLiteral -and $edge.ChildPathLiteral -ne 'VARIABLE') { $edge.ChildPathLiteral } else { $edge.Leaf }
            @{ Event = $r.Event; Hook = $r.Hook; Dependency = $edge.Leaf; Kind = $edge.Kind; ChildPath = $child }
        }
    }
    $script:ContractRows = @(@{ Hook = '.codex/hooks/enforce-epic-wave-barrier.ps1' }, @{ Hook = '.codex/hooks/enforce-epic-child-worktree-binding.ps1' })
}

Describe 'Codex hook dependency-failure behaviour (issue #786)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-ArtifactFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ArtifactFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChangedLanguageSet' -Surface 'Codex' }
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicPlanningRegisteredMcpTool -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicPlanningRegisteredMcpTool' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-JacocoRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-LcovRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Invoke-PowerShellBatchBudgetHook -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Invoke-PowerShellBatchBudgetHook' -Surface 'Codex' }
        if (Get-Command Invoke-PythonBatchBudgetHook -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Invoke-PythonBatchBudgetHook' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        if (Get-Command Test-EpicPlanningBashAllowed -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-EpicPlanningBashAllowed' -Surface 'Codex' }

        # The R-PREFIX value of every registered Codex hook (hook-guard-worklist.md, W-HOOKS).
        $script:ReasonPrefix = @{
            '.codex/hooks/check-powershell-test-purity.ps1'                 = 'check-powershell-test-purity:'
            '.codex/hooks/check-python-test-purity.ps1'                     = 'check-python-test-purity:'
            '.codex/hooks/enforce-checkpoint-monotonic.ps1'                 = 'CHECKPOINT_ORDER_BLOCKED:'
            '.codex/hooks/enforce-codex-model-routing.ps1'                  = 'MODEL_ROUTING_ATTESTATION_BLOCKED:'
            '.codex/hooks/enforce-completion-consistency.ps1'               = 'COMPLETION_CONSISTENCY_BLOCKED:'
            '.codex/hooks/enforce-epic-child-worktree-binding.ps1'          = 'EPIC_WORKTREE_BINDING_BLOCKED:'
            '.codex/hooks/enforce-epic-merge-gate.ps1'                      = 'EPIC_MERGE_GATE_BLOCKED:'
            '.codex/hooks/enforce-epic-planning-only.ps1'                   = 'EPIC_PLANNING_ONLY_BLOCKED:'
            '.codex/hooks/enforce-epic-root-invocation.ps1'                 = 'EPIC_INVOCATION_ORIGIN_BLOCKED:'
            '.codex/hooks/enforce-epic-wave-barrier.ps1'                    = 'EPIC_WAVE_BARRIER_BLOCKED:'
            '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'           = 'EPIC_WORKTREE_REMOVAL_BLOCKED:'
            '.codex/hooks/enforce-evidence-locations.ps1'                   = 'EVIDENCE_LOCATION_BLOCKED:'
            '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1' = 'PREIMPLEMENTATION_GATE_BLOCKED:'
            '.codex/hooks/enforce-powershell-batch-budget.ps1'              = 'POWERSHELL_LARGE_PATH_REQUIRED:'
            '.codex/hooks/enforce-promotion-mcp-only.ps1'                   = 'PROMOTION_MCP_ONLY_BLOCKED:'
            '.codex/hooks/enforce-python-batch-budget.ps1'                  = 'PYTHON_LARGE_PATH_REQUIRED:'
            '.codex/hooks/validate-bash.ps1'                                = 'HOOK_DEPENDENCY_LOAD_FAILED:'
            '.codex/hooks/validate-codex-subagent-routing.ps1'              = 'MODEL_ROUTING_ATTESTATION_BLOCKED:'
            '.codex/hooks/validate-feature-review-coverage.ps1'             = 'validate-feature-review-coverage:'
        }

        function Invoke-HookProcess {
            # Drives one hook through the & route with stdin and stderr redirected; both restored in finally. A hook exception propagates to the It.
            param([string] $Hook, [string] $HookEvent)
            $stdin = if ($HookEvent -eq 'SubagentStop') { '{"session_id":"b-786","hook_event_name":"SubagentStop"}' } else { '{"session_id":"b-786","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"echo sample"}}' }
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& (Join-HookGraphPath -Left $script:RepoRoot -Right $Hook))
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }

        function Reset-HookDependencyState {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function Assert-DependencyBlock {
            # PreToolUse: deny JSON at exit 0; SubagentStop: exit 2 with the reason on stderr.
            param($Result, [string] $HookEvent, [string] $Prefix, [string] $Dependency)
            if ($HookEvent -eq 'PreToolUse') {
                $Result.ExitCode | Should -Be 0
                $reason = ($Result.Stdout | ConvertFrom-Json).hookSpecificOutput
                $reason.permissionDecision | Should -Be 'deny'
                $reason.permissionDecisionReason.StartsWith($Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason.permissionDecisionReason
                $reason.permissionDecisionReason.Contains($Dependency) | Should -BeTrue -Because $reason.permissionDecisionReason
            }
            else {
                $Result.ExitCode | Should -Be 2
                $Result.Stderr.StartsWith($Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $Result.Stderr
                $Result.Stderr.Contains($Dependency) | Should -BeTrue -Because $Result.Stderr
            }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    It 'B1: <Event> <Hook> blocks naming <Dependency> when that direct edge fails' -ForEach $script:EdgeRows {
        # Arrange: fail only this edge.
        Mock Import-Module { }
        if ($Kind -eq 'Module') { Mock Import-Module ([scriptblock]::Create("throw 'simulated load failure: $Dependency'")) -ParameterFilter ([scriptblock]::Create("`$Name -like '*$Dependency'")) }
        else { Mock Join-Path ([scriptblock]::Create("throw 'simulated load failure: $Dependency'")) -ParameterFilter ([scriptblock]::Create("`$ChildPath -eq '$ChildPath'")) }
        # Act
        try { $result = Invoke-HookProcess -Hook $Hook -HookEvent $Event }
        finally { Reset-HookDependencyState }
        # Assert
        Assert-DependencyBlock -Result $result -HookEvent $Event -Prefix $script:ReasonPrefix[$Hook] -Dependency $Dependency
    }

    It 'B2: <Event> <Hook> sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load' -ForEach $script:HookRows {
        foreach ($name in 'Add-HookDependencyFailure', 'Test-HookDependencyFailure', 'Get-HookDependencyFailureReason', 'Get-HookDependencyFailureDecision') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: hook-dependency-guard.ps1' } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }
        try {
            . (Join-HookGraphPath -Left $script:RepoRoot -Right $Hook)
            $flag = $script:HookDependencyGuardLoadFailed
            $helperDefined = [bool](Get-Command -Name Add-HookDependencyFailure -CommandType Function -ErrorAction SilentlyContinue)
        }
        finally { Reset-HookDependencyState }
        $flag | Should -BeTrue
        $helperDefined | Should -BeFalse
    }

    It 'B3: <Event> <Hook> exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load' -ForEach $script:HookRows {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: hook-dependency-guard.ps1' } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }
        try { $result = Invoke-HookProcess -Hook $Hook -HookEvent $Event }
        finally { Reset-HookDependencyState }
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith("$($script:ReasonPrefix[$Hook]) hook-dependency-guard.ps1 failed to load", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'B4: has a reason-prefix entry for every discovered Codex hook and no other' {
        $discovered = @(Get-HookRegistration -ClaudeRoot $script:RepoRoot -CodexRoot $script:RepoRoot | Where-Object { $_.Surface -eq 'codex' -and $_.Hook -ne 'INLINE' } | ForEach-Object Hook | Sort-Object -Unique)
        @(Compare-Object -ReferenceObject $discovered -DifferenceObject @($script:ReasonPrefix.Keys | Sort-Object)) | Should -BeNullOrEmpty
    }

    It 'X1: <Hook> skips the absent epic-child-launch-contract.ps1 without a dependency failure' -ForEach $script:ContractRows {
        # Arrange: the contract file is reported absent.
        Mock Test-Path { $false } -ParameterFilter { $LiteralPath -like '*epic-child-launch-contract.ps1' }
        # Act
        try {
            . (Join-HookGraphPath -Left $script:RepoRoot -Right $Hook)
            $failed = Test-HookDependencyFailure
            $count = @($script:HookDependencyFailures).Count
        }
        finally { Reset-HookDependencyState }
        # Assert
        $failed | Should -BeFalse
        $count | Should -Be 0
        Should -Invoke Test-Path -ParameterFilter { $LiteralPath -like '*epic-child-launch-contract.ps1' } -Times 1
    }

    It 'X2: <Hook> denies naming epic-child-launch-contract.ps1 when the present file fails to load' -ForEach $script:ContractRows {
        # Arrange: the contract is reported present, and its path resolves to a file that does not exist.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -like '*epic-child-launch-contract.ps1' }
        Mock Join-Path { 'synthetic-missing/epic-child-launch-contract.ps1' } -ParameterFilter { $ChildPath -eq 'scripts/epic-child-launch-contract.ps1' }
        # Act
        try { $result = Invoke-HookProcess -Hook $Hook -HookEvent 'PreToolUse' }
        finally { Reset-HookDependencyState }
        # Assert
        Assert-DependencyBlock -Result $result -HookEvent 'PreToolUse' -Prefix $script:ReasonPrefix[$Hook] -Dependency 'epic-child-launch-contract.ps1'
    }

    It 'X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:' {
        Mock Join-Path { throw 'simulated load failure: hook-command-scanner.ps1' } -ParameterFilter { $ChildPath -eq 'hook-command-scanner.ps1' }
        try { $result = Invoke-HookProcess -Hook '.codex/hooks/validate-bash.ps1' -HookEvent 'PreToolUse' }
        finally { Reset-HookDependencyState }
        Assert-DependencyBlock -Result $result -HookEvent 'PreToolUse' -Prefix 'HOOK_DEPENDENCY_LOAD_FAILED:' -Dependency 'hook-command-scanner.ps1'
    }
}
