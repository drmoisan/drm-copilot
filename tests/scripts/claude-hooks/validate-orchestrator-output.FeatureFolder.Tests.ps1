#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the adopted feature-folder probe of the validate-orchestrator-output.ps1
    SubagentStop hook (issue #992).

.DESCRIPTION
    Every probe runs through an injected -FeatureFolderGitInvoker scriptblock that records its
    arguments and sets $global:LASTEXITCODE; git is never started and never mocked. Checkpoints are
    in-memory JSON returned by a mocked Get-CheckpointFileContent, the run resolution is mocked with
    a forward-slash worktree root, and the routing contract is a passing -RoutingInvoker.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture values are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    # Dot-source the hook so the test file can exercise its functions without the entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CheckpointFileContent { $null }
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

    $script:WorktreeRoot = '/synthetic-worktrees/feature-folder-session'
    $script:FeatureFolder = 'docs/features/active/2026-09-29-sample-feature-509'
    $script:BlockMessage = "ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: $($script:FeatureFolder)."
    $script:PassingRouting = { param($Path, $Type) $null = $Path, $Type; [pscustomobject]@{ ExitCode = 0; Output = '' } }

    # Return checkpoint JSON text; the waiver and feature-folder vary per case.
    function script:Get-ProbeCheckpointText {
        param([string[]] $WaivedTools = @('potential_to_issue', 'new_active_feature_folder'), [string] $Folder = $script:FeatureFolder, [string] $AdoptionJson)
        $adoption = if ($PSBoundParameters.ContainsKey('AdoptionJson')) { $AdoptionJson } else { ConvertTo-Json -InputObject ([ordered]@{ waived_tools = $WaivedTools }) -Compress }
        $state = [ordered]@{ objective = 'work'; completed_steps = @('S1_scope'); next_step = 'done'; last_updated = '2026-09-29T15:30:00Z'; 'feature-folder' = $Folder }
        $text = ConvertTo-Json -InputObject $state -Compress
        return $text.Substring(0, $text.Length - 1) + ',"issue_adoption":' + $adoption + '}'
    }

    # Build a recording invoker: each call appends its argument list to $Calls and returns $Output.
    function script:New-ProbeInvoker {
        param([System.Collections.Generic.List[object]] $Calls, [AllowNull()][object] $ExitCode, [AllowEmptyString()][string] $Output)
        # Copy the parameters into locals that the closure captures.
        $recorded = $Calls
        $exitValue = $ExitCode
        $printed = $Output
        return {
            $recorded.Add([string[]]@($args))
            $global:LASTEXITCODE = $exitValue
            if ($printed.Length -gt 0) { $printed }
        }.GetNewClosure()
    }

    function script:Invoke-ProbeDecision {
        param([string] $CheckpointText, [scriptblock] $GitInvoker, [string] $ArtifactType = 'orchestrator-state')
        $content = $CheckpointText
        Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $content } }.GetNewClosure()
        return Get-OrchestratorOutputBlockDecision -AgentOutput 'Done.' -ArtifactType $ArtifactType -RoutingInvoker $script:PassingRouting -FeatureFolderGitInvoker $GitInvoker
    }
}

Describe 'validate-orchestrator-output.ps1 adopted feature-folder probe' {
    # The recording invokers set $global:LASTEXITCODE; reset it so no later test observes it.
    AfterEach { $global:LASTEXITCODE = 0 }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeAll { Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/feature-folder-session/artifacts/orchestration/orchestrator-state.json'; WorktreeRoot = '/synthetic-worktrees/feature-folder-session'; Status = 'SessionRoot'; ReasonCode = $null; Detail = 'feature-folder probe target (issue #992)' } } }

    Context 'allow (AC-9)' {
        It 'allows a waived folder when git exits 0 and prints tree' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output "tree`n")
            $decision.Ok | Should -BeTrue
            $calls.Count | Should -Be 1
        }

        It 'threads the invoker through Invoke-OrchestratorOutputValidation' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $text = Get-ProbeCheckpointText
            Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $text } }.GetNewClosure()
            $result = Invoke-OrchestratorOutputValidation -InputText '{"last_assistant_message":"Done."}' -RoutingInvoker $script:PassingRouting -FeatureFolderGitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree')
            $result.Ok | Should -BeTrue
            $calls.Count | Should -Be 1
        }
    }

    Context 'block (AC-10)' {
        It 'blocks when git exits <ExitCode> with output <Label>' -ForEach @(
            @{ Label = 'fatal'; ExitCode = 128; Output = 'fatal: path does not exist in HEAD' }
            @{ Label = 'empty'; ExitCode = 0; Output = '' }
            @{ Label = 'blob'; ExitCode = 0; Output = 'blob' }
            @{ Label = 'unstartable'; ExitCode = -1; Output = '' }
            @{ Label = 'without-exit-code'; ExitCode = $null; Output = 'tree' }
        ) {
            $calls = [System.Collections.Generic.List[object]]::new()
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode $ExitCode -Output $Output)
            $decision.Ok | Should -BeFalse
            $decision.Repairable | Should -BeTrue
            $decision.Message | Should -BeExactly $script:BlockMessage
        }

        It 'blocks when the invoker throws' {
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText) -GitInvoker { throw 'git cannot start' }
            $decision.Ok | Should -BeFalse
            $decision.Repairable | Should -BeTrue
            $decision.Message | Should -BeExactly $script:BlockMessage
        }

        It 'surfaces the block through Invoke-OrchestratorOutputValidation' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $text = Get-ProbeCheckpointText
            Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $text } }.GetNewClosure()
            $result = Invoke-OrchestratorOutputValidation -InputText '{"last_assistant_message":"Done."}' -RoutingInvoker $script:PassingRouting -FeatureFolderGitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 128 -Output '')
            $result.Ok | Should -BeFalse
            $result.Message | Should -BeExactly $script:BlockMessage
        }
    }

    Context 'scope and command (AC-11)' {
        It 'runs the fixed cat-file command against the worktree root' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $null = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree')
            ($calls[0] -join '|') | Should -BeExactly ('-C|' + $script:WorktreeRoot + '|cat-file|-t|HEAD:' + $script:FeatureFolder)
        }

        It 'never calls git when the folder tool is not waived' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText -WaivedTools @('potential_to_issue')) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree')
            $decision.Ok | Should -BeTrue
            $calls.Count | Should -Be 0
        }

        It 'never calls git for artifact type <ArtifactType>' -ForEach @(
            @{ ArtifactType = 'epic-orchestrator-state' }
            @{ ArtifactType = 'parallel-orchestrator-state' }
        ) {
            $calls = [System.Collections.Generic.List[object]]::new()
            $null = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree') -ArtifactType $ArtifactType
            $calls.Count | Should -Be 0
        }

        It 'blocks without calling git when feature-folder fails the path pattern' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $badFolder = 'docs/features/active/../active/2026-09-29-sample-feature-509'
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText -Folder $badFolder) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree')
            $decision.Ok | Should -BeFalse
            $decision.Message | Should -BeExactly "ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: $badFolder."
            $calls.Count | Should -Be 0
        }

        It 'never calls git when issue_adoption is <Label>' -ForEach @(
            @{ Label = 'not an object'; AdoptionJson = '"waived"' }
            @{ Label = 'missing waived_tools'; AdoptionJson = '{}' }
            @{ Label = 'carrying a string waived_tools'; AdoptionJson = '{"waived_tools":"new_active_feature_folder"}' }
        ) {
            $calls = [System.Collections.Generic.List[object]]::new()
            $decision = Invoke-ProbeDecision -CheckpointText (Get-ProbeCheckpointText -AdoptionJson $AdoptionJson) -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output 'tree')
            $decision.Ok | Should -BeTrue
            $calls.Count | Should -Be 0
        }
    }

    Context 'direct seam and decision calls' {
        It 'returns ExitCode -1 without throwing when the invoker throws' {
            $result = Invoke-FeatureFolderGitExe -GitArgs @('cat-file', '-t', 'HEAD:docs') -GitInvoker { throw 'boom' }
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }

        It 'returns the trimmed output and exit code of the invoker' {
            $calls = [System.Collections.Generic.List[object]]::new()
            $result = Invoke-FeatureFolderGitExe -GitArgs @('cat-file', '-t', 'HEAD:docs') -GitInvoker (New-ProbeInvoker -Calls $calls -ExitCode 0 -Output "  tree  ")
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'tree'
        }

        It 'allows a checkpoint that has no issue_adoption member' {
            $checkpoint = '{"objective":"work"}' | ConvertFrom-Json
            (Get-OrchestratorOutputFeatureFolderDecision -Checkpoint $checkpoint -WorktreeRoot $script:WorktreeRoot -GitInvoker { throw 'not reached' }).Ok | Should -BeTrue
        }

        It 'allows a checkpoint value that is not an object' {
            (Get-OrchestratorOutputFeatureFolderDecision -Checkpoint $null -WorktreeRoot $script:WorktreeRoot -GitInvoker { throw 'not reached' }).Ok | Should -BeTrue
        }
    }
}
