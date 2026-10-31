#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for the parallel mutation rejection helpers in validate-orchestrator-output-rejection.ps1 (issue #1012).

.DESCRIPTION
    Covers the signal parser Get-ParallelMutationRejectionCode, the live-root state-absence scan
    Test-ParallelRunStateAbsent, the allow decision Get-OrchestratorOutputRejectionDecision, and the
    block-message hint Get-ParallelMutationRejectionHint. One AST row pins the sibling's function set
    and the absence of module imports, process starts, and call-operator invocations.

    The live-root and checkpoint-text seams are mocked in script scope (the sibling calls them
    directly) and null-mocked in module scope, so no row reads, creates, or writes a checkpoint file,
    uses a temporary path, reads a clock, starts a process, or touches the network. Synthetic roots
    use the /synthetic-worktrees/<name> form, and every comparison is ordinal.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output-rejection.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

    $script:SiblingPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output-rejection.ps1").Path
    $script:AllCodes = @('kickoff_artifact_missing', 'run_not_started', 'items_in_flight', 'unknown_item')
    $script:RuleHeading = '## Mutation Rejection Signal (issue #1012)'
    $script:Session = '/synthetic-worktrees/session'
    # The forbidden command names the AST row searches for; the process-start name is assembled from
    # its parts so this suite carries no literal invocation of it.
    $script:ForbiddenCommand = @('Import-Module', (@('Start', 'Process') -join '-'))

    # Model the live roots and their parallel checkpoint texts for the sibling's direct seam calls.
    function Set-RejectionLiveText {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Parallel = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -MockWith { return , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    function New-RejectionResolution {
        param([string] $Status)
        return [pscustomobject]@{ Resolved = $false; CheckpointPath = $null; WorktreeRoot = $null; Status = $Status; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'synthetic' }
    }
}

Describe 'validate-orchestrator-output-rejection helpers' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Get-ParallelMutationRejectionCode' {

        It 'parses the code <Code> from a valid final line' -ForEach @(
            @{ Code = 'kickoff_artifact_missing' }
            @{ Code = 'run_not_started' }
            @{ Code = 'items_in_flight' }
            @{ Code = 'unknown_item' }
        ) {
            # Arrange
            $output = "The run has no committed kickoff artifact.`nPARALLEL_MUTATION_REJECTED: $Code"

            # Act
            $result = Get-ParallelMutationRejectionCode -AgentOutput $output

            # Assert
            $result | Should -BeExactly $Code
        }

        It 'tolerates a trailing CRLF after a valid line' {
            # Arrange
            $output = "Stopped.`r`nPARALLEL_MUTATION_REJECTED: run_not_started`r`n"

            # Act
            $result = Get-ParallelMutationRejectionCode -AgentOutput $output

            # Assert
            $result | Should -BeExactly 'run_not_started'
        }

        It 'tolerates trailing blank lines after a valid line' {
            # Arrange
            $output = "Stopped.`nPARALLEL_MUTATION_REJECTED: unknown_item`n`n   `n"

            # Act
            $result = Get-ParallelMutationRejectionCode -AgentOutput $output

            # Assert
            $result | Should -BeExactly 'unknown_item'
        }

        It 'returns null for <Case>' -ForEach @(
            @{ Case = 'the token on an earlier line'; Output = "PARALLEL_MUTATION_REJECTED: run_not_started`nFinal summary." }
            @{ Case = 'the token followed by text'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started because the run is pending' }
            @{ Case = 'a lowercase prefix'; Output = 'parallel_mutation_rejected: run_not_started' }
            @{ Case = 'an uppercase code'; Output = 'PARALLEL_MUTATION_REJECTED: RUN_NOT_STARTED' }
            @{ Case = 'a backtick-wrapped line'; Output = '`PARALLEL_MUTATION_REJECTED: run_not_started`' }
            @{ Case = 'a bold-wrapped line'; Output = '**PARALLEL_MUTATION_REJECTED: run_not_started**' }
            @{ Case = 'a double space after the colon'; Output = 'PARALLEL_MUTATION_REJECTED:  run_not_started' }
            @{ Case = 'an unknown code'; Output = 'PARALLEL_MUTATION_REJECTED: bogus_code' }
            @{ Case = 'empty output'; Output = '' }
        ) {
            # Act
            $result = Get-ParallelMutationRejectionCode -AgentOutput $Output

            # Assert
            $result | Should -BeNullOrEmpty -Because "$Case is not a signal"
        }
    }

    Context 'Test-ParallelRunStateAbsent' {

        It 'returns true for <Case>' -ForEach @(
            @{ Case = 'no live roots'; Live = @(); Parallel = @{}; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started' }
            @{ Case = 'null checkpoint text'; Live = @('/synthetic-worktrees/w-a'); Parallel = @{}; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started' }
            @{ Case = 'blank checkpoint text'; Live = @('/synthetic-worktrees/w-a'); Parallel = @{ '/synthetic-worktrees/w-a' = "  `n " }; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started' }
            @{ Case = 'an other-slug parallel checkpoint'; Live = @('/synthetic-worktrees/w-a'); Parallel = @{ '/synthetic-worktrees/w-a' = '{"objective":"run","route_id":"parallel","parallel_slug":"run-b"}' }; Output = "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started" }
            @{ Case = 'an on-route slugged checkpoint when the output names no slug'; Live = @('/synthetic-worktrees/w-a'); Parallel = @{ '/synthetic-worktrees/w-a' = '{"objective":"run","route_id":"parallel","parallel_slug":"run-b"}' }; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started' }
        ) {
            # Arrange
            Set-RejectionLiveText -Live $Live -Parallel $Parallel

            # Act
            $result = Test-ParallelRunStateAbsent -AgentOutput $Output -SessionRoot $script:Session

            # Assert
            $result | Should -BeTrue -Because "$Case does not record state for the named run"
        }

        It 'returns false for <Case>' -ForEach @(
            @{ Case = 'unparseable text'; Text = '{ not json' }
            @{ Case = 'a JSON array root'; Text = '[{"route_id":"parallel","parallel_slug":"run-b"}]' }
            @{ Case = 'an off-route checkpoint'; Text = '{"objective":"run","route_id":"epic","parallel_slug":"run-b"}' }
            @{ Case = 'a parallel checkpoint without parallel_slug'; Text = '{"objective":"run","route_id":"parallel"}' }
            @{ Case = 'a checkpoint recording the named slug'; Text = '{"objective":"run","route_id":"parallel","parallel_slug":"run-a"}' }
        ) {
            # Arrange
            Set-RejectionLiveText -Live @('/synthetic-worktrees/w-a') -Parallel @{ '/synthetic-worktrees/w-a' = $Text }

            # Act
            $result = Test-ParallelRunStateAbsent -AgentOutput "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started" -SessionRoot $script:Session

            # Assert
            $result | Should -BeFalse -Because "$Case defeats the allow"
        }
    }

    Context 'Get-OrchestratorOutputRejectionDecision' {

        It 'allows when every gate holds' {
            # Arrange
            Set-RejectionLiveText -Live @('/synthetic-worktrees/w-a')

            # Act
            $result = Get-OrchestratorOutputRejectionDecision -ArtifactType 'parallel-orchestrator-state' -Resolution (New-RejectionResolution -Status 'NoTarget') `
                -AgentOutput 'PARALLEL_MUTATION_REJECTED: kickoff_artifact_missing' -SessionRoot $script:Session

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'returns null for <Case>' -ForEach @(
            @{ Case = 'artifact type orchestrator-state'; ArtifactType = 'orchestrator-state'; Status = 'NoTarget'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started'; Absent = $true }
            @{ Case = 'artifact type epic-orchestrator-state'; ArtifactType = 'epic-orchestrator-state'; Status = 'NoTarget'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started'; Absent = $true }
            @{ Case = 'Status Ambiguous'; ArtifactType = 'parallel-orchestrator-state'; Status = 'Ambiguous'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started'; Absent = $true }
            @{ Case = 'Status Rejected'; ArtifactType = 'parallel-orchestrator-state'; Status = 'Rejected'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started'; Absent = $true }
            @{ Case = 'no signal'; ArtifactType = 'parallel-orchestrator-state'; Status = 'NoTarget'; Output = 'Final summary.'; Absent = $true }
            @{ Case = 'a failing absence scan'; ArtifactType = 'parallel-orchestrator-state'; Status = 'NoTarget'; Output = 'PARALLEL_MUTATION_REJECTED: run_not_started'; Absent = $false }
        ) {
            # Arrange
            $absent = $Absent
            Mock Test-ParallelRunStateAbsent { $absent }.GetNewClosure()

            # Act
            $result = Get-OrchestratorOutputRejectionDecision -ArtifactType $ArtifactType -Resolution (New-RejectionResolution -Status $Status) `
                -AgentOutput $Output -SessionRoot $script:Session

            # Assert
            $result | Should -BeNullOrEmpty -Because "$Case must not allow"
        }
    }

    Context 'Get-ParallelMutationRejectionHint' {

        It 'returns an empty string for <Case>' -ForEach @(
            @{ Case = 'an epic NoTarget block'; ArtifactType = 'epic-orchestrator-state'; Status = 'NoTarget' }
            @{ Case = 'a parallel Ambiguous block'; ArtifactType = 'parallel-orchestrator-state'; Status = 'Ambiguous' }
        ) {
            # Act
            $result = Get-ParallelMutationRejectionHint -ArtifactType $ArtifactType -Status $Status -AgentOutput 'PARALLEL_MUTATION_REJECTED: bogus_code'

            # Assert
            $result | Should -BeExactly ''
        }

        It 'names the signal form and the rule heading for a parallel NoTarget block' {
            # Act
            $result = Get-ParallelMutationRejectionHint -ArtifactType 'parallel-orchestrator-state' -Status 'NoTarget' -AgentOutput 'Final summary.'

            # Assert
            $result.Contains('PARALLEL_MUTATION_REJECTED: <code>') | Should -BeTrue -Because $result
            $result.Contains($script:RuleHeading) | Should -BeTrue -Because $result
            foreach ($code in $script:AllCodes) { $result.Contains($code) | Should -BeFalse -Because 'no allowed-code list follows a line without the prefix' }
        }

        It 'lists every allowed code when the final line carries the prefix and an invalid code' {
            # Act
            $result = Get-ParallelMutationRejectionHint -ArtifactType 'parallel-orchestrator-state' -Status 'NoTarget' -AgentOutput "Stopped.`nPARALLEL_MUTATION_REJECTED: bogus_code"

            # Assert
            $result.Contains('PARALLEL_MUTATION_REJECTED: <code>') | Should -BeTrue -Because $result
            foreach ($code in $script:AllCodes) { $result.Contains($code) | Should -BeTrue -Because "the allowed-code list names $code" }
        }
    }

    Context 'sibling structure' {

        It 'defines exactly the four helpers and contains no import, process start, or call-operator invocation' {
            # Arrange
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:SiblingPath, [ref] $tokens, [ref] $errors)

            # Act
            $functionNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Name })
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            $forbidden = @($commands | Where-Object { $script:ForbiddenCommand -ccontains $_.GetCommandName() })
            $callOperator = @($commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand })
            $sortedNames = [string[]] $functionNames
            [System.Array]::Sort($sortedNames, [System.StringComparer]::Ordinal)

            # Assert
            @($errors).Count | Should -Be 0
            ($sortedNames -join ',') | Should -BeExactly 'Get-OrchestratorOutputRejectionDecision,Get-ParallelMutationRejectionCode,Get-ParallelMutationRejectionHint,Test-ParallelRunStateAbsent'
            $forbidden.Count | Should -Be 0
            $callOperator.Count | Should -Be 0
        }
    }
}
