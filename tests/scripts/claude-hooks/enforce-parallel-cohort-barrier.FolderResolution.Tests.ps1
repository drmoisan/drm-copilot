#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Feature-folder resolution cases for the enforce-parallel-cohort-barrier.ps1 PreToolUse
    hook (issue #565, consolidated #566).

.DESCRIPTION
    Drives Invoke-ParallelCohortBarrierDecision through the issue #565 test matrix: the
    folder alone, the folder plus a nested research or evidence artifact, the nested
    artifact alone, a target plus another run member's folder with and without the canonical
    issue-number line, two non-member folders, tokens that truncate to fewer than four
    segments, a simulated dot-source failure of the shared resolver, and lifecycle-prefixed
    record values.

    The canonical fixture records two current-generation cohorts and one conflict edge: item
    101 (merged) sits in cohort 0 and item 102 (the target) sits in cohort 1, so the target
    is clear to start. The worktree-resolution and checkpoint-read seams are mocked; no case
    reads orchestration state or writes a file.
#>

Describe 'enforce-parallel-cohort-barrier.ps1 feature-folder resolution (issue #565)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
        . $script:HookPath
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex'
        Mock Resolve-ParallelCohortBarrierTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Mock Get-ParallelCohortBarrierCheckpointContent { $script:CheckpointJson }

        $script:Target = 'item-b-102'
        $script:Member = 'item-a-101'
        $script:Kickoff = 'Parallel mode: true. parallel_slug: demo.'

        function Get-CohortCheckpoint {
            param(
                [string] $MemberFolder = "docs/features/active/$script:Member",
                [string] $TargetFolder = "docs/features/active/$script:Target"
            )
            return '{"recolor_generation":2,"items":[' +
            '{"issue_num":101,"feature_folder":"' + $MemberFolder + '","merge_status":"merged"},' +
            '{"issue_num":102,"feature_folder":"' + $TargetFolder + '","merge_status":"not_started"}' +
            '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],' +
            '"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
        }

        function Invoke-CohortDecision {
            param([string] $Prompt)
            $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5
            return (Invoke-ParallelCohortBarrierDecision -ToolInputRaw $payload).hookSpecificOutput
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        $script:CheckpointJson = Get-CohortCheckpoint
    }

    Context 'nested-artifact citations resolve to the target folder' {
        It 'C1: allows the target folder cited alone' {
            (Invoke-CohortDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target now").permissionDecision | Should -Be 'allow'
        }

        It 'C2a: allows the target folder cited together with a research artifact' {
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target and read docs/features/active/$script:Target/research/notes.md first."
            (Invoke-CohortDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'C2b: allows the target folder cited together with an evidence artifact' {
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target and read docs/features/active/$script:Target/evidence/baseline/run.md first."
            (Invoke-CohortDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'C3a: allows a research artifact cited alone' {
            (Invoke-CohortDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/research/notes.md first.").permissionDecision | Should -Be 'allow'
        }

        It 'C3b: allows an evidence artifact cited alone' {
            (Invoke-CohortDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/evidence/baseline/run.md first.").permissionDecision | Should -Be 'allow'
        }
    }

    Context 'another run member cited alongside the target' {
        It 'C4a: denies as ambiguous and names both folders when no canonical issue-number line is present' {
            $decision = Invoke-CohortDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target after docs/features/active/$script:Member merged."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_COHORT_BARRIER_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match $script:Target
            $decision.permissionDecisionReason | Should -Match $script:Member
        }

        It 'C4b: allows when the canonical issue-number line selects the target' {
            $prompt = "$script:Kickoff Canonical issue number for this feature is 102. Execute docs/features/active/$script:Target after docs/features/active/$script:Member merged."
            (Invoke-CohortDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }
    }

    Context 'two non-member folders are ambiguous' {
        It 'C5a: denies as ambiguous and names both candidates' {
            $decision = Invoke-CohortDecision -Prompt "$script:Kickoff docs/features/active/zulu-901 and docs/features/active/yankee-with-a-much-longer-slug-902/spec.md"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_COHORT_BARRIER_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'zulu-901'
            $decision.permissionDecisionReason | Should -Match 'yankee-with-a-much-longer-slug-902'
        }

        It 'C5b: denies as ambiguous for the reversed order with the longer slug first' {
            $decision = Invoke-CohortDecision -Prompt "$script:Kickoff docs/features/active/yankee-with-a-much-longer-slug-902/spec.md and docs/features/active/zulu-901"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_COHORT_BARRIER_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'zulu-901'
            $decision.permissionDecisionReason | Should -Match 'yankee-with-a-much-longer-slug-902'
        }
    }

    Context 'tokens that truncate to fewer than four segments' {
        It 'C6a: denies a bare docs/features/active/ token as naming no folder' {
            $decision = Invoke-CohortDecision -Prompt "$script:Kickoff See docs/features/active/ for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target item feature folder'
        }

        It 'C6b: denies a docs/features/active/. token as naming no folder' {
            $decision = Invoke-CohortDecision -Prompt "$script:Kickoff See docs/features/active/. for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target item feature folder'
        }
    }

    Context 'shared resolver import failure' {
        It 'C7: denies naming feature-folder-resolution.ps1 and guards the dot-source' {
            # Arrange: simulate the recorded dot-source failure.
            $script:ParallelCohortBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                # Act
                $decision = Invoke-CohortDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target now"
            }
            finally {
                $script:ParallelCohortBarrierResolutionImportFailure = $null
            }

            # Assert: the decision denies naming the shared file.
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_COHORT_BARRIER_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'feature-folder-resolution\.ps1'
            $decision.permissionDecisionReason | Should -Match "the dependency 'feature-folder-resolution\.ps1' failed to import"

            # Assert: exactly one try statement dot-sources the shared file, and its catch
            # clause records the failure in the hook's import-failure variable.
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookPath, [ref]$null, [ref]$null)
            $guards = @($ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.TryStatementAst] -and
                        $null -ne $node.Body.Find({
                                param($inner)
                                $inner -is [System.Management.Automation.Language.CommandAst] -and
                                $inner.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot -and
                                @($inner.CommandElements | Where-Object { $_.Extent.Text -match 'feature-folder-resolution\.ps1' }).Count -gt 0
                            }, $true)
                    }, $true))
            $guards.Count | Should -Be 1 -Because 'the shared resolver must be dot-sourced inside exactly one try statement'
            $assignments = @($guards[0].CatchClauses | ForEach-Object {
                    $_.FindAll({
                            param($node)
                            $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                            $node.Left.Extent.Text -eq '$script:ParallelCohortBarrierResolutionImportFailure'
                        }, $true)
                })
            $assignments.Count | Should -BeGreaterThan 0 -Because 'the catch clause must record the failure'
        }
    }

    Context 'lifecycle-prefixed record values' {
        It 'C8: matches records recorded with active/ and docs/features/active/ prefixes' {
            $script:CheckpointJson = Get-CohortCheckpoint -MemberFolder "docs/features/active/$script:Member" -TargetFolder "active/$script:Target"
            (Invoke-CohortDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target now").permissionDecision | Should -Be 'allow'
        }
    }
}
