#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Regeneration consistency check of the merge gate (issue #1156), Codex copy.

.DESCRIPTION
    Exercises Get-EpicMergeGateRegenerationDecision of .codex/hooks/enforce-epic-merge-gate-regeneration.ps1
    directly with in-memory checkpoints, checks the helper's load shape and byte identity with the
    Claude copy, and shows the review guard's stale-head denial precedes the check. No case starts a
    process, runs git or gh, or writes a file.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'The stub mirrors the production git seam signature.')]
param()

Describe 'enforce-epic-merge-gate-regeneration.ps1 (issue #1156)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:CodexHelperPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate-regeneration.ps1'
        $script:ClaudeHelperPath = Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-merge-gate-regeneration.ps1'
        . $script:CodexHelperPath
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:LiveHead = 'a' * 40
        $script:OtherHead = 'b' * 40
        $script:DenyPrefix = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: '

        function Get-RegenerationGateEvent {
            <#
            .SYNOPSIS
                Return a complete regeneration_events entry as an ordered dictionary.
            .PARAMETER HeadSha
                The head_sha value.
            #>
            [CmdletBinding()]
            [OutputType([System.Collections.Specialized.OrderedDictionary])]
            param([string] $HeadSha = $script:LiveHead)

            return [ordered]@{
                head_sha    = $HeadSha
                outcome     = 'regenerated'
                idempotent  = $true
                confined    = $true
                unit_gate   = 'pass'
                delta_check = 'pass'
            }
        }

        function ConvertTo-RegenerationGateCheckpoint {
            <#
            .SYNOPSIS
                Build a parsed checkpoint (PSCustomObject) from review outcomes and optional events.
            .PARAMETER Outcomes
                The review_outcomes list.
            .PARAMETER EventList
                The regeneration_events value; omitted when -NoEvents is set.
            .PARAMETER NoEvents
                Omit the regeneration_events key.
            .PARAMETER Extra
                Additional top-level keys.
            #>
            [CmdletBinding()]
            param(
                [object[]] $Outcomes = @(),
                [AllowNull()] $EventList = @(),
                [switch] $NoEvents,
                [hashtable] $Extra = @{}
            )

            $document = [ordered]@{ remediation_loop = [ordered]@{ review_outcomes = @($Outcomes) } }
            if (-not $NoEvents) { $document['regeneration_events'] = $EventList }
            foreach ($key in $Extra.Keys) { $document[$key] = $Extra[$key] }
            return ($document | ConvertTo-Json -Depth 10 | ConvertFrom-Json)
        }

        $script:DeltaOutcome = [ordered]@{ verdict = 'PASS'; findings = @(); head_sha = $script:LiveHead; review_kind = 'regeneration_delta'; evidence_path = 'docs/features/active/x-1/evidence/qa-gates/regeneration-delta.2026-11-09T22-00.md' }
        $script:FullReviewOutcome = [ordered]@{ verdict = 'PASS'; findings = @(); head_sha = $script:LiveHead }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'decision rules' {
        It 'allows a delta outcome with a matching complete event' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @(Get-RegenerationGateEvent)

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse -Because $decision.Reason
        }

        It 'allows when a later complete event follows an incomplete event with the same head_sha' {
            # Arrange
            $incomplete = Get-RegenerationGateEvent
            $incomplete['unit_gate'] = 'not_run'
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @($incomplete, (Get-RegenerationGateEvent))

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse -Because $decision.Reason
        }

        It 'denies a delta outcome with no matching event' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @()

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            $decision.Reason | Should -BeLikeExactly '*no regeneration_events entry has head_sha*'
        }

        It 'denies when the only complete event carries a different head_sha' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @(Get-RegenerationGateEvent -HeadSha $script:OtherHead)

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'denies when <Field> is <Value> and names the field' -ForEach @(
            @{ Field = 'idempotent'; Value = $false }
            @{ Field = 'idempotent'; Value = 'true' }
            @{ Field = 'confined'; Value = $false }
            @{ Field = 'unit_gate'; Value = 'fail' }
            @{ Field = 'unit_gate'; Value = 'not_run' }
            @{ Field = 'delta_check'; Value = 'fail' }
            @{ Field = 'outcome'; Value = 'fell_back' }
        ) {
            # Arrange
            $regenerationEvent = Get-RegenerationGateEvent
            $regenerationEvent[$Field] = $Value
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @($regenerationEvent)

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            $decision.Reason | Should -BeLikeExactly "*fails the $Field check*"
        }

        It 'is inert when the last outcome carries no review_kind' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:FullReviewOutcome) -NoEvents

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse
        }

        It 'is inert for the case variant Regeneration_Delta (ordinal comparison)' {
            # Arrange
            $outcome = [ordered]@{} + $script:DeltaOutcome
            $outcome['review_kind'] = 'Regeneration_Delta'
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($outcome) -NoEvents

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse
        }

        It 'is inert when an earlier outcome is a delta outcome and the last is not' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome, $script:FullReviewOutcome) -NoEvents

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse
        }

        It 'denies a delta outcome when regeneration_events is absent' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -NoEvents

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'denies a delta outcome when regeneration_events is not a list' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList 'not-a-list'

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'denies a delta outcome without a matching event on a checkpoint with no review_mode' {
            # Arrange
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @(Get-RegenerationGateEvent -HeadSha $script:OtherHead) -Extra @{ step9_status = 'passed' }

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            @($checkpoint.PSObject.Properties.Name) -ccontains 'review_mode' | Should -BeFalse
            $decision.Denied | Should -BeTrue
        }

        It 'is inert for <Name>' -ForEach @(
            @{ Name = 'a null checkpoint'; Value = $null }
            @{ Name = 'a string checkpoint'; Value = 'text' }
            @{ Name = 'a checkpoint without remediation_loop'; Value = [pscustomobject]@{ step9_status = 'passed' } }
            @{ Name = 'review_outcomes that is not a list'; Value = [pscustomobject]@{ remediation_loop = [pscustomobject]@{ review_outcomes = 'x' } } }
            @{ Name = 'a last outcome that is not an object'; Value = [pscustomobject]@{ remediation_loop = [pscustomobject]@{ review_outcomes = @('x') } } }
        ) {
            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $Value

            # Assert
            $decision.Denied | Should -BeFalse
        }

        It 'reads a checkpoint parsed as a hashtable' {
            # Arrange
            $text = [ordered]@{ remediation_loop = [ordered]@{ review_outcomes = @($script:DeltaOutcome) }; regeneration_events = @(Get-RegenerationGateEvent) } | ConvertTo-Json -Depth 10
            $checkpoint = ConvertFrom-Json -InputObject $text -AsHashtable

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse -Because $decision.Reason
        }

        It 'denies a delta outcome without a head_sha' {
            # Arrange
            $outcome = [ordered]@{} + $script:DeltaOutcome
            $outcome['head_sha'] = $null
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($outcome) -EventList @(Get-RegenerationGateEvent)

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason | Should -BeLikeExactly '*carries no head_sha*'
        }
    }

    Context 'review guard precedes the check' {
        BeforeAll {
            . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate-review.ps1')
            function Invoke-DocsOnlyGitExe { param([string] $WorktreeRoot, [string[]] $GitArgs) }
        }

        It 'returns REVIEW_GATE_HEAD_STALE for a stale reviewed head before the regeneration check is reached' {
            # Arrange
            $liveHead = $script:OtherHead
            Mock Get-EpicMergeGateReviewLiveHeadSha -MockWith ({ $liveHead }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Get-EpicMergeGateRegenerationDecision { [ordered]@{ Denied = $false; Reason = $null } }
            $checkpoint = ConvertTo-RegenerationGateCheckpoint -Outcomes @($script:DeltaOutcome) -EventList @(Get-RegenerationGateEvent) -Extra @{ review_mode = 'concurrent'; 'feature-folder' = 'docs/features/active/x-1' }

            # Act
            $decision = Get-EpicMergeGateReviewDecision -Checkpoint $checkpoint -CommandPrNumber 42 -GhRoot '/synthetic-root' -GitRoot '/synthetic-root'
            if (-not $decision.Denied) { $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint }

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_STALE: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs -contains '--is-ancestor' }
            Should -Invoke Get-EpicMergeGateRegenerationDecision -Times 0 -Exactly
        }
    }

    Context 'file shape' {
        It 'the Claude and Codex copies are byte-identical' {
            # Act
            $claude = (Get-FileHash -LiteralPath $script:ClaudeHelperPath -Algorithm SHA256).Hash
            $codex = (Get-FileHash -LiteralPath $script:CodexHelperPath -Algorithm SHA256).Hash

            # Assert
            $codex | Should -BeExactly $claude
        }

        It 'starts no process: no git, gh, process-start, or Import-Module command, no dot-source, and no call operator' {
            # Arrange
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:CodexHelperPath, [ref]$null, [ref]$null)
            $forbiddenNames = @('git', 'gh', (@('Start', 'Process') -join '-'), 'Import-Module')

            # Act
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            $names = @($commands | ForEach-Object { $_.GetCommandName() })
            $invocationOperators = @($commands | Where-Object { $_.InvocationOperator -ne [System.Management.Automation.Language.TokenKind]::Unknown })

            # Assert
            foreach ($forbidden in $forbiddenNames) { $names -contains $forbidden | Should -BeFalse -Because $forbidden }
            $invocationOperators.Count | Should -Be 0
        }

        It '<Name> holds only function definitions at top level' -ForEach @(
            @{ Name = 'the Codex copy'; Key = 'Codex' }
            @{ Name = 'the Claude copy'; Key = 'Claude' }
        ) {
            # Arrange
            $path = if ($Key -ceq 'Codex') { $script:CodexHelperPath } else { $script:ClaudeHelperPath }
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$null)

            # Act
            $statements = @($ast.EndBlock.Statements)
            $nonFunction = @($statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })

            # Assert
            $statements.Count | Should -BeGreaterThan 0
            $nonFunction.Count | Should -Be 0
            ($null -eq $ast.BeginBlock -and $null -eq $ast.ProcessBlock -and $null -eq $ast.ParamBlock) | Should -BeTrue
        }
    }
}

Describe 'Codex enforce-epic-merge-gate.ps1 regeneration wiring (issue #1156)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:EntryPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        $script:HelperDefinedBeforeGate = $null -ne (Get-Command Get-EpicMergeGateRegenerationDecision -ErrorAction SilentlyContinue)
        . $script:EntryPath
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $script:Head = 'c' * 40
        $script:DenyPrefix = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: '
        $script:SyntheticRoot = Join-Path '/synthetic-worktrees' 'codex-1156'

        function Invoke-CodexRegenerationDecision {
            <#
            .SYNOPSIS
                Run gh pr merge 42 through the Codex gate with the given child checkpoint text.
            .PARAMETER Child
                The child checkpoint text.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)][string] $Child)

            $payload = @{ session_id = 'session-1156'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Child -EpicCheckpointRaw '' -RepositoryRoot $script:SyntheticRoot
            if ($null -eq $decision) { return [pscustomobject]@{ Decision = 'allow'; Reason = '' } }
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }

        function ConvertTo-CodexRegenerationChild {
            <#
            .SYNOPSIS
                Return a sequential epic-child checkpoint text with the given outcome and optional events.
            .PARAMETER Outcome
                The last review outcome.
            .PARAMETER EventList
                The regeneration_events list; omitted when $null.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)] $Outcome, [AllowNull()] $EventList)

            $document = [ordered]@{
                epic_mode        = $true
                step9_status     = 'passed'
                pr_gate          = [ordered]@{ pr_number = 42 }
                ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = $script:Head }
                remediation_loop = [ordered]@{ review_outcomes = @($Outcome) }
            }
            if ($null -ne $EventList) { $document['regeneration_events'] = @($EventList) }
            return ($document | ConvertTo-Json -Depth 8 -Compress)
        }

        $script:DeltaOutcome = [ordered]@{ verdict = 'PASS'; findings = @(); head_sha = $script:Head; review_kind = 'regeneration_delta'; evidence_path = 'docs/features/active/x-1/evidence/qa-gates/regeneration-delta.2026-11-09T22-00.md' }
        $script:FullOutcome = [ordered]@{ verdict = 'PASS'; findings = @(); head_sha = $script:Head }
        $script:CompleteEvent = [ordered]@{ head_sha = $script:Head; outcome = 'regenerated'; idempotent = $true; confined = $true; unit_gate = 'pass'; delta_check = 'pass' }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'loads Get-EpicMergeGateRegenerationDecision only through the entry file' {
        # Assert
        $script:HelperDefinedBeforeGate | Should -BeFalse
        Get-Command Get-EpicMergeGateRegenerationDecision -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    Context 'gate decisions with the review guard not denied' {
        BeforeEach {
            Mock Get-EpicMergeGateReviewDecision { [ordered]@{ Denied = $false; Reason = $null } }
        }

        It 'denies a delta outcome without a matching event with REVIEW_GATE_REGENERATION_UNVERIFIED' {
            # Act
            $result = Invoke-CodexRegenerationDecision -Child (ConvertTo-CodexRegenerationChild -Outcome $script:DeltaOutcome -EventList @())

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        }

        It 'gives a checkpoint with regeneration_events but no review_kind the same decision as without them' {
            # Act
            $without = Invoke-CodexRegenerationDecision -Child (ConvertTo-CodexRegenerationChild -Outcome $script:FullOutcome -EventList $null)
            $with = Invoke-CodexRegenerationDecision -Child (ConvertTo-CodexRegenerationChild -Outcome $script:FullOutcome -EventList @($script:CompleteEvent))

            # Assert
            $with.Decision | Should -BeExactly $without.Decision
            $with.Reason | Should -BeExactly $without.Reason
            $with.Reason.Contains('REVIEW_GATE_REGENERATION_UNVERIFIED') | Should -BeFalse
        }
    }

    Context 'placement after the review guard' {
        It 'returns the review guard denial and never calls the regeneration check' {
            # Arrange
            Mock Get-EpicMergeGateReviewDecision { [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_STALE: fixture.' } }
            Mock Get-EpicMergeGateRegenerationDecision { [ordered]@{ Denied = $false; Reason = $null } }

            # Act
            $result = Invoke-CodexRegenerationDecision -Child (ConvertTo-CodexRegenerationChild -Outcome $script:DeltaOutcome -EventList @())

            # Assert
            $result.Reason | Should -BeExactly 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_STALE: fixture.'
            Should -Invoke Get-EpicMergeGateRegenerationDecision -Times 0 -Exactly
        }

        It 'calls the regeneration check once with the child checkpoint and returns its denial' {
            # Arrange
            Mock Get-EpicMergeGateReviewDecision { [ordered]@{ Denied = $false; Reason = $null } }
            Mock Get-EpicMergeGateRegenerationDecision { [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: fixture.' } }

            # Act
            $result = Invoke-CodexRegenerationDecision -Child (ConvertTo-CodexRegenerationChild -Outcome $script:DeltaOutcome -EventList @())

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason | Should -BeExactly 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: fixture.'
            Should -Invoke Get-EpicMergeGateRegenerationDecision -Times 1 -Exactly -ParameterFilter { $Checkpoint.step9_status -ceq 'passed' -and $Checkpoint.remediation_loop.review_outcomes[0].review_kind -ceq 'regeneration_delta' }
        }
    }

    Context 'entry-body wiring (AST)' {
        BeforeAll {
            $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:EntryPath, [ref]$null, [ref]$null)
        }

        It 'holds exactly one guarded dot-source of the helper after the child-CI dot-source and before the first function' {
            # Arrange
            $statements = @($script:Ast.EndBlock.Statements)
            $tryIndex = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.TryStatementAst] -and $statements[$i].Body.Extent.Text.Contains('enforce-epic-merge-gate-regeneration.ps1')) { $i } })
            $childCiIndex = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.TryStatementAst] -and $statements[$i].Body.Extent.Text.Contains('enforce-epic-merge-gate-child-ci.ps1')) { $i } })
            $firstFunction = @(for ($i = 0; $i -lt $statements.Count; $i++) { if ($statements[$i] -is [System.Management.Automation.Language.FunctionDefinitionAst]) { $i } })[0]

            # Assert
            $tryIndex.Count | Should -Be 1
            $try = $statements[$tryIndex[0]]
            ($try.Body.Statements[0].Extent.Text -replace '\s+', ' ') | Should -BeExactly ". (Join-Path `$PSScriptRoot 'enforce-epic-merge-gate-regeneration.ps1')"
            ($try.CatchClauses[0].Body.Extent.Text -replace '\s+', ' ') | Should -BeExactly "{ Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-regeneration.ps1' -ErrorRecord `$_ }"
            $tryIndex[0] | Should -BeGreaterThan $childCiIndex[0]
            $tryIndex[0] | Should -BeLessThan $firstFunction
        }

        It 'calls Get-EpicMergeGateRegenerationDecision once inside the outer review block of Invoke-CodexEpicMergeDecision' {
            # Arrange
            $calls = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-EpicMergeGateRegenerationDecision' }, $true))
            $function = $script:Ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Invoke-CodexEpicMergeDecision' }, $true)
            $reviewCall = $function.Find({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-EpicMergeGateReviewDecision' }, $true)
            $firstDeniedIf = $function.Find({ param($node) $node -is [System.Management.Automation.Language.IfStatementAst] -and $node.Clauses[0].Item1.Extent.Text -ceq '$reviewDecision.Denied' }, $true)

            # Assert
            $calls.Count | Should -Be 1
            $call = $calls[0]
            $assignment = $call.Parent.Parent
            $assignment | Should -BeOfType ([System.Management.Automation.Language.AssignmentStatementAst])
            $assignment.Left.Extent.Text | Should -BeExactly '$reviewDecision'
            $guard = $assignment.Parent.Parent
            $guard | Should -BeOfType ([System.Management.Automation.Language.IfStatementAst])
            $guard.Clauses[0].Item1.Extent.Text | Should -BeExactly '-not $reviewDecision.Denied'
            $outer = $guard.Parent.Parent
            $outer | Should -BeOfType ([System.Management.Automation.Language.IfStatementAst])
            $outer.Clauses[0].Item1.Extent.Text | Should -BeExactly '-not $reviewDecision.Denied'
            ($reviewCall.Extent.StartOffset -gt $outer.Extent.StartOffset -and $reviewCall.Extent.EndOffset -lt $outer.Extent.EndOffset) | Should -BeTrue
            ($outer.Extent.StartOffset -gt $function.Extent.StartOffset -and $outer.Extent.EndOffset -lt $function.Extent.EndOffset) | Should -BeTrue
            $call.CommandElements[1].ParameterName | Should -BeExactly 'Checkpoint'
            $call.CommandElements[2].Extent.Text | Should -BeExactly '$child'
            $reviewIndex = [array]::IndexOf(@($reviewCall.CommandElements | ForEach-Object { if ($_ -is [System.Management.Automation.Language.CommandParameterAst]) { $_.ParameterName } else { '' } }), 'Checkpoint')
            $reviewCall.CommandElements[$reviewIndex + 1].Extent.Text | Should -BeExactly '$child'
            $call.Extent.StartOffset | Should -BeGreaterThan $reviewCall.Extent.StartOffset
            $call.Extent.StartOffset | Should -BeLessThan $firstDeniedIf.Extent.StartOffset
        }
    }
}
