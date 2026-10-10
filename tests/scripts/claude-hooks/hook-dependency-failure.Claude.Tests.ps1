#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Dependency-failure behaviour of every registered Claude PreToolUse and SubagentStop hook (issue #786).

.DESCRIPTION
    Hooks come from .claude/settings.json and their direct edges from the AST at discovery time, so a
    new hook or a new import is covered without editing a list. B1 fails one direct edge at a time
    with a Pester mock (Import-Module for a module, Join-Path for a dot-source) and drives the hook
    through the & route: a PreToolUse hook must emit the deny JSON at exit 0 with its leading token,
    name the dependency, and call no HookPayload function; a SubagentStop hook must exit 2 with the
    reason on stderr. B2 and B3 fail the helper bootstrap. B4 keeps the reason-prefix table complete.
    Edges listed by a Handler entry of the exemption list are judged by their fail-closed proofs.
    No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
    . (Join-Path $PSScriptRoot '../claude-runtime/HookImportFailureExemptions.Helpers.ps1')
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
    $exemptions = @(Get-HookImportFailureExemption)
    $registrations = @(Get-HookRegistration -ClaudeRoot $repoRoot -CodexRoot $repoRoot | Where-Object { $_.Surface -eq 'claude' -and $_.Hook -ne 'INLINE' })
    $script:HookRows = @($registrations | ForEach-Object { @{ Event = $_.Event; Hook = $_.Hook } })
    $script:EdgeRows = foreach ($r in $registrations) {
        $text = Get-Content -LiteralPath (Join-HookGraphPath -Left $repoRoot -Right $r.Hook) -Raw
        $listed = @($exemptions | Where-Object { $_.Kind -eq 'Handler' -and $_.HandlerFile -eq $r.Hook } | ForEach-Object { $_.Leaf })
        foreach ($edge in @(Get-HookScriptEdge -ScriptText $text -SourcePath $r.Hook | Where-Object { -not $_.Runtime -and -not $_.Conditional -and $_.Leaf -ne 'hook-dependency-guard.ps1' -and $listed -notcontains $_.Leaf })) {
            $child = if ($edge.ChildPathLiteral -and $edge.ChildPathLiteral -ne 'VARIABLE') { $edge.ChildPathLiteral } else { $edge.Leaf }
            @{ Event = $r.Event; Hook = $r.Hook; Dependency = $edge.Leaf; Kind = $edge.Kind; ChildPath = $child }
        }
    }
}

Describe 'Claude hook dependency-failure behaviour (issue #786)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-ArtifactFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ArtifactFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChangedLanguageSet' -Surface 'Codex' }
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-JacocoRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-LcovRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-ModelRoutingCheckpoint -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ModelRoutingCheckpoint' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Invoke-PowerShellBatchBudgetHook -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Invoke-PowerShellBatchBudgetHook' -Surface 'Codex' }
        if (Get-Command Invoke-PythonBatchBudgetHook -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Invoke-PythonBatchBudgetHook' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/hook-payload/HookPayload.psm1') -ErrorAction Stop

        # The R-PREFIX value of every registered Claude hook (hook-guard-worklist.md, W-HOOKS).
        $script:ReasonPrefix = @{
            '.claude/hooks/check-powershell-test-purity.ps1'                 = 'PowerShell unit test purity hook:'
            '.claude/hooks/check-python-test-purity.ps1'                     = 'Python unit test purity hook:'
            '.claude/hooks/enforce-checkpoint-monotonic.ps1'                 = 'CHECKPOINT_MONOTONIC_BLOCKED:'
            '.claude/hooks/enforce-completion-consistency.ps1'               = 'COMPLETION_CONSISTENCY_BLOCKED:'
            '.claude/hooks/enforce-discovery-artifact-gate.ps1'              = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
            '.claude/hooks/enforce-epic-invocation-origin.ps1'               = 'EPIC_INVOCATION_ORIGIN_BLOCKED:'
            '.claude/hooks/enforce-epic-merge-gate.ps1'                      = 'EPIC_MERGE_GATE_BLOCKED:'
            '.claude/hooks/enforce-epic-wave-barrier.ps1'                    = 'EPIC_WAVE_BARRIER_BLOCKED:'
            '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'           = 'EPIC_WORKTREE_REMOVAL_BLOCKED:'
            '.claude/hooks/enforce-evidence-locations.ps1'                   = 'EVIDENCE_LOCATION_BLOCKED:'
            '.claude/hooks/enforce-feature-folder-order.ps1'                 = 'FEATURE_FOLDER_ORDER_BLOCKED:'
            '.claude/hooks/enforce-mermaid-validation.ps1'                   = 'MERMAID_VALIDATION_BLOCKED:'
            '.claude/hooks/enforce-model-routing-receipt.ps1'                = 'MODEL_ROUTING_RECEIPT_BLOCKED:'
            '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1' = 'PREIMPLEMENTATION_GATE_BLOCKED:'
            '.claude/hooks/enforce-parallel-abandon-gate.ps1'                = 'enforce-parallel-abandon-gate:'
            '.claude/hooks/enforce-parallel-cohort-barrier.ps1'              = 'PARALLEL_COHORT_BARRIER_BLOCKED:'
            '.claude/hooks/enforce-parallel-drift-gate.ps1'                  = 'PARALLEL_DRIFT_GATE_BLOCKED:'
            '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'       = 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:'
            '.claude/hooks/enforce-powershell-batch-budget.ps1'              = 'POWERSHELL_LARGE_PATH_REQUIRED:'
            '.claude/hooks/enforce-pr-author-skill.ps1'                      = 'PR_AUTHOR_SKILL_BLOCKED:'
            '.claude/hooks/enforce-prd-feature-before-planner.ps1'           = 'PRD_FEATURE_BLOCKED:'
            '.claude/hooks/enforce-promotion-mcp-only.ps1'                   = 'PROMOTION_MCP_ONLY_BLOCKED:'
            '.claude/hooks/enforce-python-batch-budget.ps1'                  = 'PYTHON_LARGE_PATH_REQUIRED:'
            '.claude/hooks/validate-bash.ps1'                                = 'HOOK_DEPENDENCY_LOAD_FAILED:'
            '.claude/hooks/validate-discovery-artifact-gate.ps1'             = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
            '.claude/hooks/validate-feature-review-coverage.ps1'             = 'validate-feature-review-coverage:'
            '.claude/hooks/validate-orchestrator-output.ps1'                 = 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED:'
            '.claude/hooks/validate-planner-output.ps1'                      = 'validate-planner-output:'
            '.claude/hooks/validate-pr-author-output.ps1'                    = 'PR_AUTHOR_OUTPUT_MISSING:'
            '.claude/hooks/validate-prd-feature-output.ps1'                  = 'validate-prd-feature-output:'
        }

        function Invoke-HookProcess {
            # Drives one hook through the & route with stdin and stderr redirected; both restored in finally. A hook exception propagates to the It.
            param([string] $Hook, [string] $HookEvent)
            $stdin = if ($HookEvent -eq 'SubagentStop') { '{"session_id":"b-786","hook_event_name":"SubagentStop"}' } else { '{"session_id":"b-786","hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"README.md"}}' }
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& (Get-HookInvocationPath -Left $script:RepoRoot -Right $Hook))
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
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    It 'B1: <Event> <Hook> blocks naming <Dependency> when that direct edge fails' -ForEach $script:EdgeRows {
        # Arrange: fail only this edge; every other import is a no-op.
        Mock Import-Module { }
        # The mock bodies are literal scriptblocks that read the row through these locals; scriptblocks built with
        # [scriptblock]::Create stop the coverage tracer from recording later containers in a full run.
        $failedDependency = $Dependency
        $failedChildPath = $ChildPath
        if ($Kind -eq 'Module') { Mock Import-Module { throw "simulated load failure: $failedDependency" } -ParameterFilter { $Name -like "*$failedDependency" } }
        else { Mock Join-Path { throw "simulated load failure: $failedDependency" } -ParameterFilter { $ChildPath -eq $failedChildPath } }
        Mock Read-ClaudeHookRawPayload { '' }
        Mock Resolve-ClaudeHookToolInput { [pscustomobject]@{ IsValid = $false; Anomaly = 'Empty'; Value = $null } }
        $prefix = $script:ReasonPrefix[$Hook]
        # Act
        try { $result = Invoke-HookProcess -Hook $Hook -HookEvent $Event }
        finally { Reset-HookDependencyState }
        # Assert
        if ($Event -eq 'PreToolUse') {
            $result.ExitCode | Should -Be 0
            $reason = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
            $reason.permissionDecision | Should -Be 'deny'
            $reason.permissionDecisionReason.StartsWith($prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason.permissionDecisionReason
            $reason.permissionDecisionReason.Contains($Dependency) | Should -BeTrue -Because $reason.permissionDecisionReason
            Should -Invoke Read-ClaudeHookRawPayload -Times 0 -Exactly
            Should -Invoke Resolve-ClaudeHookToolInput -Times 0 -Exactly
        }
        else {
            $result.ExitCode | Should -Be 2
            $result.Stderr.StartsWith($prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
            $result.Stderr.Contains($Dependency) | Should -BeTrue -Because $result.Stderr
        }
    }

    It 'B2: <Event> <Hook> sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load' -ForEach $script:HookRows {
        # Arrange: no helper function is defined in the test scope, and the helper dot-source fails.
        foreach ($name in 'Add-HookDependencyFailure', 'Test-HookDependencyFailure', 'Get-HookDependencyFailureReason', 'Get-HookDependencyFailureDecision') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: hook-dependency-guard.ps1' } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }
        # Act
        try {
            . (Get-HookInvocationPath -Left $script:RepoRoot -Right $Hook)
            $flag = $script:HookDependencyGuardLoadFailed
            $helperDefined = [bool](Get-Command -Name Add-HookDependencyFailure -CommandType Function -ErrorAction SilentlyContinue)
        }
        finally { Reset-HookDependencyState }
        # Assert
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

    It 'B4: has a reason-prefix entry for every discovered Claude hook and no other' {
        $discovered = @(Get-HookRegistration -ClaudeRoot $script:RepoRoot -CodexRoot $script:RepoRoot | Where-Object { $_.Surface -eq 'claude' -and $_.Hook -ne 'INLINE' } | ForEach-Object Hook | Sort-Object -Unique)
        @(Compare-Object -ReferenceObject $discovered -DifferenceObject @($script:ReasonPrefix.Keys | Sort-Object)) | Should -BeNullOrEmpty
    }
}
