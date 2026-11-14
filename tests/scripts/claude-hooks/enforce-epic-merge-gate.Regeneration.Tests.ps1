#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Regeneration consistency check through the Claude merge gate (issue #1156).

.DESCRIPTION
    Drives Invoke-EpicMergeGateDecision of .claude/hooks/enforce-epic-merge-gate.ps1 with the review
    guard fixtures and mocked target resolvers, checkpoint read seams, and process seams, and checks
    the entry file's dot-source and call wiring by AST. The suite does not dot-source
    enforce-epic-merge-gate-regeneration.ps1 itself, so Get-EpicMergeGateRegenerationDecision exists
    only through the entry file. A direct-decision context calls that function on in-memory
    checkpoints, including hashtable-parsed ones, so the Claude copy's own branches are exercised.
    No case starts a process, runs git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate regeneration check (issue #1156)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-epic-merge-gate.ps1')).Path
        $script:HelperDefinedBeforeGate = $null -ne (Get-Command Get-EpicMergeGateRegenerationDecision -ErrorAction SilentlyContinue)
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'EpicMergeGateReview.Cases.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-1156'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-1156'
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item OtherWorktree (issue #1156)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1156)' } }

        $script:Reviewed = Get-EpicMergeGateReviewHead -Kind Reviewed
        $script:Live = Get-EpicMergeGateReviewHead -Kind Live
        $script:DenyPrefix = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: '

        function Get-GateRegenerationEvent {
            <#
            .SYNOPSIS
                Return a complete regeneration_events entry for the given head.
            .PARAMETER HeadSha
                The head_sha value.
            #>
            [CmdletBinding()]
            [OutputType([System.Collections.Specialized.OrderedDictionary])]
            param([string] $HeadSha = $script:Reviewed)

            return [ordered]@{ head_sha = $HeadSha; outcome = 'regenerated'; idempotent = $true; confined = $true; unit_gate = 'pass'; delta_check = 'pass' }
        }

        function Invoke-RegenerationGateDecision {
            <#
            .SYNOPSIS
                Run gh pr merge 42 through the gate with a checkpoint built from the given overrides.
            .PARAMETER Override
                Top-level checkpoint keys to set.
            .PARAMETER Remove
                Top-level checkpoint keys to drop.
            .PARAMETER LiveHead
                The live head the review guard reads.
            #>
            [CmdletBinding()]
            param([hashtable] $Override = @{}, [string[]] $Remove = @(), [string] $LiveHead = $script:Reviewed)

            $checkpoint = ConvertTo-EpicMergeGateReviewCheckpointJson -Override $Override -Remove $Remove
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $checkpoint }.GetNewClosure())
            $liveHeadSha = $LiveHead
            Mock Get-EpicMergeGateReviewLiveHeadSha -MockWith ({ $liveHeadSha }.GetNewClosure())
            Register-EpicMergeGateReviewChildCiSeam -HeadSha $script:Reviewed
            $envelope = @{ session_id = 'session-1156'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }

        function Get-DeltaOverride {
            <#
            .SYNOPSIS
                Return checkpoint overrides holding a delta outcome at the given head and the given events.
            .PARAMETER HeadSha
                The head_sha of the delta outcome.
            .PARAMETER EventList
                The regeneration_events list.
            #>
            [CmdletBinding()]
            [OutputType([hashtable])]
            param([string] $HeadSha = $script:Reviewed, [object[]] $EventList = @())

            $outcome = [ordered]@{ verdict = 'PASS'; findings = @(); head_sha = $HeadSha; review_kind = 'regeneration_delta'; evidence_path = 'docs/features/active/item-42/evidence/qa-gates/regeneration-delta.2026-11-09T22-00.md' }
            return @{ remediation_loop = [ordered]@{ review_outcomes = @($outcome) }; regeneration_events = @($EventList) }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'loads Get-EpicMergeGateRegenerationDecision only through the entry file' {
        # Assert
        $script:HelperDefinedBeforeGate | Should -BeFalse
        Get-Command Get-EpicMergeGateRegenerationDecision -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It 'allows a delta outcome at the live head with a matching complete event' {
        # Act
        $result = Invoke-RegenerationGateDecision -Override (Get-DeltaOverride -EventList @(Get-GateRegenerationEvent))

        # Assert
        $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
    }

    It 'denies a delta outcome without a matching event with the new code' {
        # Act
        $result = Invoke-RegenerationGateDecision -Override (Get-DeltaOverride -EventList @())

        # Assert
        $result.Decision | Should -Be 'deny'
        $result.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    }

    It 'denies when <Field> is <Value> with the new code' -ForEach @(
        @{ Field = 'outcome'; Value = 'fell_back' }
        @{ Field = 'idempotent'; Value = $false }
        @{ Field = 'confined'; Value = $false }
        @{ Field = 'unit_gate'; Value = 'not_run' }
        @{ Field = 'delta_check'; Value = 'fail' }
        @{ Field = 'head_sha'; Value = 'fedcba9876543210fedcba9876543210fedcba98' }
    ) {
        # Arrange
        $regenerationEvent = Get-GateRegenerationEvent
        $regenerationEvent[$Field] = $Value

        # Act
        $result = Invoke-RegenerationGateDecision -Override (Get-DeltaOverride -EventList @($regenerationEvent))

        # Assert
        $result.Decision | Should -Be 'deny'
        $result.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    }

    It 'denies a delta outcome at a stale ancestor with REVIEW_GATE_HEAD_STALE before the regeneration check' {
        # Arrange: the live head moved and the ancestry check exits 1.
        Mock Get-EpicMergeGateRegenerationDecision { [ordered]@{ Denied = $false; Reason = $null } }

        # Act
        $result = Invoke-RegenerationGateDecision -Override (Get-DeltaOverride -EventList @(Get-GateRegenerationEvent)) -LiveHead $script:Live

        # Assert
        $result.Decision | Should -Be 'deny'
        $result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_STALE: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        Should -Invoke Get-EpicMergeGateRegenerationDecision -Times 0 -Exactly
    }

    It 'denies a delta outcome without a matching event under sequential review (no review_mode)' {
        # Act
        $result = Invoke-RegenerationGateDecision -Override (Get-DeltaOverride -EventList @()) -Remove 'review_mode'

        # Assert
        $result.Decision | Should -Be 'deny'
        $result.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    }

    Context 'direct decision cases on the Claude copy of the helper' {
        It 'allows a checkpoint parsed as a hashtable with a matching complete event' {
            # Arrange
            $text = (Get-DeltaOverride -EventList @(Get-GateRegenerationEvent)) | ConvertTo-Json -Depth 10
            $checkpoint = ConvertFrom-Json -InputObject $text -AsHashtable

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeFalse -Because $decision.Reason
        }

        It 'denies a checkpoint parsed as a hashtable that has no regeneration_events key' {
            # Arrange
            $override = Get-DeltaOverride -EventList @()
            $override.Remove('regeneration_events')
            $checkpoint = ConvertFrom-Json -InputObject ($override | ConvertTo-Json -Depth 10) -AsHashtable

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason | Should -BeLikeExactly '*no regeneration_events list*'
        }

        It 'denies a delta outcome without a head_sha' {
            # Arrange
            $override = Get-DeltaOverride -EventList @(Get-GateRegenerationEvent)
            $override.remediation_loop.review_outcomes[0]['head_sha'] = $null
            $checkpoint = $override | ConvertTo-Json -Depth 10 | ConvertFrom-Json

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            $decision.Reason | Should -BeLikeExactly '*carries no head_sha*'
        }

        It 'denies a delta outcome when regeneration_events is not a list' {
            # Arrange
            $override = Get-DeltaOverride -EventList @()
            $override['regeneration_events'] = 'not-a-list'
            $checkpoint = $override | ConvertTo-Json -Depth 10 | ConvertFrom-Json

            # Act
            $decision = Get-EpicMergeGateRegenerationDecision -Checkpoint $checkpoint

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason | Should -BeLikeExactly '*no regeneration_events list*'
        }
    }

    It 'denies with EPIC_MERGE_GATE_BLOCKED naming the file when enforce-epic-merge-gate-regeneration.ps1 fails to load' {
        # Arrange: re-load the entry file with only the regeneration helper's path join failing.
        Mock Import-Module { }
        $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
        Mock Join-Path {
            if ($ChildPath -eq 'enforce-epic-merge-gate-regeneration.ps1') { throw 'simulated load failure: enforce-epic-merge-gate-regeneration.ps1' }
            & $originalJoinPath @PesterBoundParameters
        }
        try {
            . $script:UnderTest
            $envelope = @{ session_id = 'session-1156'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }
        finally {
            $script:HookDependencyFailures.Clear()
        }
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        [string]$decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith('EPIC_MERGE_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains('enforce-epic-merge-gate-regeneration.ps1') | Should -BeTrue -Because $reason
    }

    Context 'R73 builder output against the gate (spec D18 items 1 and 5)' {
        BeforeAll {
            Import-Module (Join-Path $PSScriptRoot '../../../.claude/lib/regeneration/RegenerationDelta.psm1') -ErrorAction Stop

            function Get-R73Pair {
                <#
                .SYNOPSIS
                    Build the event and delta outcome from the given cells and apply the orchestrator completion.
                .PARAMETER UnitGate
                    The unit_gate cell of the row.
                .PARAMETER PromoteUnitGate
                    Set the event's unit_gate to pass after the standard gates.
                #>
                [CmdletBinding()]
                [OutputType([hashtable])]
                param([string] $UnitGate, [switch] $PromoteUnitGate)

                $regenerationEvent = New-RegenerationEvent -At '2026-11-09T22:00:00Z' -Trigger main_sync -FeatureHeadSha $null -MergeHeadSha $null -MergeBaseSha $null -Decision regenerate -Reason all_match -UnmatchedPaths @() -CommandExitCode 0 -Confined $true -Idempotent $true -UnitGate $UnitGate -DeltaCheck pass -Outcome regenerated -HeadSha $null -EvidencePath $null
                $outcome = New-RegenerationDeltaReviewOutcome -HeadSha $null -EvidencePath $null
                $evidencePath = Get-RegenerationEvidencePath -FeatureFolder (Get-EpicMergeGateReviewFolder) -Timestamp '2026-11-09T22-00'
                foreach ($entry in @($regenerationEvent, $outcome)) {
                    $entry['head_sha'] = $script:Reviewed
                    $entry['evidence_path'] = $evidencePath
                }
                if ($PromoteUnitGate) { $regenerationEvent['unit_gate'] = 'pass' }
                return @{ remediation_loop = [ordered]@{ review_outcomes = @($outcome) }; regeneration_events = @($regenerationEvent) }
            }
        }

        AfterAll {
            Remove-Module -Name RegenerationDelta, RegenerationClassifier -Force -ErrorAction SilentlyContinue
        }

        It 'allows the completed R73 checkpoint' {
            # Act
            $result = Invoke-RegenerationGateDecision -Override (Get-R73Pair -UnitGate not_run -PromoteUnitGate)

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }

        It 'denies the R73 checkpoint without the unit_gate step, naming unit_gate' {
            # Act
            $result = Invoke-RegenerationGateDecision -Override (Get-R73Pair -UnitGate not_run)

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith($script:DenyPrefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
            $result.Reason | Should -BeLikeExactly '*unit_gate*'
        }

        It 'allows an R72 event (unit_gate pass) completed with head_sha and evidence_path only' {
            # Act
            $result = Invoke-RegenerationGateDecision -Override (Get-R73Pair -UnitGate pass)

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }
    }

    Context 'entry-body wiring (AST)' {
        BeforeAll {
            $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:UnderTest, [ref]$null, [ref]$null)
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

        It 'calls Get-EpicMergeGateRegenerationDecision once in Invoke-EpicMergeGateDecision, guarded and placed after the review decision' {
            # Arrange
            $calls = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-EpicMergeGateRegenerationDecision' }, $true))
            $function = $script:Ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Invoke-EpicMergeGateDecision' }, $true)
            $reviewCall = $function.Find({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-EpicMergeGateReviewDecision' }, $true)
            $firstDeniedIf = $function.Find({ param($node) $node -is [System.Management.Automation.Language.IfStatementAst] -and $node.Clauses[0].Item1.Extent.Text -ceq '$reviewDecision.Denied' }, $true)

            # Assert
            $calls.Count | Should -Be 1
            $call = $calls[0]
            $call.Extent.StartOffset | Should -BeGreaterThan $function.Extent.StartOffset
            $call.Extent.EndOffset | Should -BeLessThan $function.Extent.EndOffset
            $assignment = $call.Parent.Parent
            $assignment | Should -BeOfType ([System.Management.Automation.Language.AssignmentStatementAst])
            $assignment.Left.Extent.Text | Should -BeExactly '$reviewDecision'
            $guard = $assignment.Parent.Parent
            $guard | Should -BeOfType ([System.Management.Automation.Language.IfStatementAst])
            $guard.Clauses[0].Item1.Extent.Text | Should -BeExactly '-not $reviewDecision.Denied'
            $call.CommandElements[1].ParameterName | Should -BeExactly 'Checkpoint'
            $call.CommandElements[2].Extent.Text | Should -BeExactly '$childCheckpoint'
            $reviewIndex = [array]::IndexOf(@($reviewCall.CommandElements | ForEach-Object { if ($_ -is [System.Management.Automation.Language.CommandParameterAst]) { $_.ParameterName } else { '' } }), 'Checkpoint')
            $reviewCall.CommandElements[$reviewIndex + 1].Extent.Text | Should -BeExactly '$childCheckpoint'
            $call.Extent.StartOffset | Should -BeGreaterThan $reviewCall.Extent.StartOffset
            $call.Extent.StartOffset | Should -BeLessThan $firstDeniedIf.Extent.StartOffset
        }
    }
}
