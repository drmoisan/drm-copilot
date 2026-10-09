#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Feature-folder resolution cases for the enforce-parallel-drift-gate.ps1 PreToolUse hook
    (issue #565, consolidated #567).

.DESCRIPTION
    Drives Invoke-ParallelDriftGateDecision through the issue #565 test matrix: the folder
    alone, the folder plus a nested research or evidence artifact, the nested artifact alone,
    a target plus another run item's folder with and without the canonical issue-number line,
    two non-member folders, tokens that truncate to fewer than four segments, a simulated
    dot-source failure of the shared resolver, and the finding-presence probe receiving the
    resolved basename for a nested evidence citation.

    The worktree-resolution, checkpoint-read, and finding-presence seams are mocked; no case
    reads orchestration state or writes a file.
#>

Describe 'enforce-parallel-drift-gate.ps1 feature-folder resolution (issue #565)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-drift-gate.ps1").Path
        . $script:HookPath
        Mock Resolve-ParallelDriftGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Mock Get-ParallelDriftGateCheckpointContent { $script:CheckpointJson }

        $script:Target = '2026-08-07-parallel-alpha-501'
        $script:Other = '2026-08-07-parallel-bravo-502'
        $script:Kickoff = 'Parallel mode: true. parallel_slug: demo.'
        $script:SyntheticWorktree = if ($IsWindows) { 'C:/worktrees/alpha' } else { '/worktrees/alpha' }

        function Get-DriftCheckpoint {
            # Two items; with -Unresolved the target carries one unresolved drift event.
            param([switch] $Unresolved)
            $events = '[]'
            if ($Unresolved) {
                $events = '[{"item_key":501,"declared":["scripts/declared/"],"observed":["scripts/other/escape.py"],' +
                '"escaped_paths":["scripts/other/escape.py"],"at":"2026-01-02T00-00","action":"raised_blocking_finding"}]'
            }
            return '{"items":[' +
            '{"issue_num":501,"feature_folder":"' + $script:Target + '","state":"in_flight","worktree_path":"' + $script:SyntheticWorktree + '",' +
            '"blast_radius":{"paths":["scripts/declared/"],"modules":[],"shared_surfaces":[],"contracts":[],"source":"declared","computed_at":"2026-01-01T00-00"}},' +
            '{"issue_num":502,"feature_folder":"' + $script:Other + '","state":"in_flight"}' +
            '],"drift_events":' + $events + '}'
        }

        function Invoke-DriftDecision {
            param([string] $Prompt)
            $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'feature-review'; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5
            return (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput
        }
    }

    BeforeEach {
        $script:CheckpointJson = Get-DriftCheckpoint
    }

    Context 'nested-artifact citations resolve to the target folder' {
        It 'D1: allows the target folder cited alone when it has no drift event' {
            (Invoke-DriftDecision -Prompt "$script:Kickoff Review docs/features/active/$script:Target now").permissionDecision | Should -Be 'allow'
        }

        It 'D2a: allows the target folder cited together with a research artifact' {
            $prompt = "$script:Kickoff Review docs/features/active/$script:Target and read docs/features/active/$script:Target/research/notes.md first."
            (Invoke-DriftDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'D2b: allows the target folder cited together with an evidence artifact' {
            $prompt = "$script:Kickoff Review docs/features/active/$script:Target and read docs/features/active/$script:Target/evidence/baseline/run.md first."
            (Invoke-DriftDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'D3a: allows a research artifact cited alone' {
            (Invoke-DriftDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/research/notes.md first.").permissionDecision | Should -Be 'allow'
        }

        It 'D3b: allows an evidence artifact cited alone' {
            (Invoke-DriftDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/evidence/baseline/run.md first.").permissionDecision | Should -Be 'allow'
        }
    }

    Context 'another run item cited alongside the target' {
        It 'D4a: denies as ambiguous and names both folders when no canonical issue-number line is present' {
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff Review docs/features/active/$script:Target against docs/features/active/$script:Other now"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_DRIFT_GATE_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match $script:Target
            $decision.permissionDecisionReason | Should -Match $script:Other
        }

        It 'D4b: allows when the canonical issue-number line selects the target' {
            $prompt = "$script:Kickoff Canonical issue number for this feature is 501. Review docs/features/active/$script:Target against docs/features/active/$script:Other now"
            (Invoke-DriftDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }
    }

    Context 'two non-member folders are ambiguous' {
        It 'D5a: denies as ambiguous and names both candidates' {
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff docs/features/active/zulu-901 and docs/features/active/yankee-with-a-much-longer-slug-902/spec.md"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_DRIFT_GATE_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'zulu-901'
            $decision.permissionDecisionReason | Should -Match 'yankee-with-a-much-longer-slug-902'
        }

        It 'D5b: denies as ambiguous for the reversed order with the longer slug first' {
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff docs/features/active/yankee-with-a-much-longer-slug-902/spec.md and docs/features/active/zulu-901"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_DRIFT_GATE_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'zulu-901'
            $decision.permissionDecisionReason | Should -Match 'yankee-with-a-much-longer-slug-902'
        }
    }

    Context 'tokens that truncate to fewer than four segments' {
        It 'D6a: denies a bare docs/features/active/ token as naming no folder' {
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff See docs/features/active/ for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target item feature folder'
        }

        It 'D6b: denies a docs/features/active/. token as naming no folder' {
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff See docs/features/active/. for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target item feature folder'
        }
    }

    Context 'shared resolver import failure' {
        It 'D7: denies naming feature-folder-resolution.ps1 and guards the dot-source' {
            # Arrange: simulate the recorded dot-source failure.
            $script:ParallelDriftGateResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                # Act
                $decision = Invoke-DriftDecision -Prompt "$script:Kickoff Review docs/features/active/$script:Target now"
            }
            finally {
                $script:ParallelDriftGateResolutionImportFailure = $null
            }

            # Assert: the decision denies naming the shared file.
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PARALLEL_DRIFT_GATE_BLOCKED:'
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
                            $node.Left.Extent.Text -eq '$script:ParallelDriftGateResolutionImportFailure'
                        }, $true)
                })
            $assignments.Count | Should -BeGreaterThan 0 -Because 'the catch clause must record the failure'
        }
    }

    Context 'the finding-presence probe receives the resolved basename' {
        It 'D8: probes the target folder, not the nested evidence kind, for an unresolved drift event' {
            # Arrange: the target carries an unresolved drift event and its finding exists.
            $script:CheckpointJson = Get-DriftCheckpoint -Unresolved
            Mock Test-ParallelDriftFindingPresent { $true }

            # Act
            $decision = Invoke-DriftDecision -Prompt "$script:Kickoff Review docs/features/active/$script:Target/evidence/qa-gates/x.md now"

            # Assert
            $decision.permissionDecision | Should -Be 'allow'
            Should -Invoke Test-ParallelDriftFindingPresent -Times 1 -Exactly -ParameterFilter { $FeatureFolder -ceq '2026-08-07-parallel-alpha-501' }
        }
    }
}
