#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Feature-folder resolution cases for the enforce-epic-wave-barrier.ps1 PreToolUse hook
    (issue #565).

.DESCRIPTION
    Drives Invoke-EpicWaveBarrierDecision through every prompt form of the issue #565 test
    matrix: the folder alone, the folder plus a nested research or evidence artifact, the
    nested artifact alone, a target plus the skill-mandated upstream context line, two
    non-dependency folders, tokens that truncate to fewer than four segments, the #621/#508
    regression fixture, integer depends_on edges, a simulated dot-source failure of the
    shared resolver, and lifecycle-prefixed record values.

    The worktree-resolution seam and the checkpoint-read seam are mocked, so no case reads
    the repository's orchestration state and no case writes a file. The import-failure case
    also parses the hook file to prove the shared resolver is dot-sourced inside a guard.
#>

Describe 'enforce-epic-wave-barrier.ps1 feature-folder resolution (issue #565)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
        . $script:HookPath
        Mock Resolve-EpicWaveBarrierTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Mock Get-EpicWaveBarrierCheckpointContent { $script:CheckpointJson }

        $script:Target = '2026-07-02-target-301'
        $script:Upstream = '2026-07-02-upstream-300'
        $script:Kickoff = 'Epic mode: true. integration_branch: epic/x-integration.'

        function ConvertTo-WavePayload {
            param([string] $Prompt)
            return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-UpstreamLine {
            # The .claude/skills/epic-orchestrate/SKILL.md upstream-context line shape.
            param([string] $Number, [string] $Dependency, [string] $Folder)
            return "Upstream context for ${Number}: depends on $Dependency (spec: docs/features/active/$Folder/spec.md; " +
            "plan: docs/features/active/$Folder/plan.2026-10-01T00-00.md; merged as PR #900, commit 0000000, into epic/x-integration)."
        }

        function Get-TargetCheckpoint {
            # Target 301 depends on upstream 300 through a folder-string edge.
            param([string] $UpstreamStatus = 'merged')
            return '{"features":[' +
            '{"issue_num":300,"feature_folder":"' + $script:Upstream + '","depends_on":[],"merge_status":"' + $UpstreamStatus + '"},' +
            '{"issue_num":301,"feature_folder":"' + $script:Target + '","depends_on":["' + $script:Upstream + '"],"merge_status":"not_started"}' +
            ']}'
        }

        function Invoke-WaveDecision {
            param([string] $Prompt)
            return (Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-WavePayload -Prompt $Prompt)).hookSpecificOutput
        }
    }

    Context 'nested-artifact citations resolve to the target folder' {
        BeforeEach {
            $script:CheckpointJson = Get-TargetCheckpoint
        }

        It 'W1: allows the target folder cited alone when its dependencies are merged' {
            (Invoke-WaveDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target now").permissionDecision | Should -Be 'allow'
        }

        It 'W2a: allows the target folder cited together with a research artifact' {
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target and read docs/features/active/$script:Target/research/notes.md first."
            (Invoke-WaveDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'W2b: allows the target folder cited together with an evidence artifact' {
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target and read docs/features/active/$script:Target/evidence/baseline/run.md first."
            (Invoke-WaveDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'W3a: allows a research artifact cited alone' {
            (Invoke-WaveDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/research/notes.md first.").permissionDecision | Should -Be 'allow'
        }

        It 'W3b: allows an evidence artifact cited alone' {
            (Invoke-WaveDecision -Prompt "$script:Kickoff Read docs/features/active/$script:Target/evidence/baseline/run.md first.").permissionDecision | Should -Be 'allow'
        }
    }

    Context 'upstream-dependency citation lines' {
        It 'W4a: prunes the cited upstream dependency and allows when it is merged' {
            $script:CheckpointJson = Get-TargetCheckpoint -UpstreamStatus 'merged'
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target/spec.md. " + (Get-UpstreamLine -Number '301' -Dependency '300' -Folder $script:Upstream)
            (Invoke-WaveDecision -Prompt $prompt).permissionDecision | Should -Be 'allow'
        }

        It 'W4b: evaluates the target, not the upstream, and denies when the dependency is pr_open' {
            $script:CheckpointJson = Get-TargetCheckpoint -UpstreamStatus 'pr_open'
            $prompt = "$script:Kickoff Execute docs/features/active/$script:Target/spec.md. " + (Get-UpstreamLine -Number '301' -Dependency '300' -Folder $script:Upstream)
            $decision = Invoke-WaveDecision -Prompt $prompt
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "^EPIC_WAVE_BARRIER_BLOCKED: '$script:Target'"
        }
    }

    Context 'two non-dependency folders are ambiguous' {
        BeforeEach {
            $script:CheckpointJson = '{"features":[' +
            '{"issue_num":401,"feature_folder":"alpha-401","depends_on":[],"merge_status":"not_started"},' +
            '{"issue_num":402,"feature_folder":"bravo-with-a-much-longer-slug-402","depends_on":[],"merge_status":"not_started"}' +
            ']}'
        }

        It 'W5a: denies as ambiguous and names both candidates' {
            $decision = Invoke-WaveDecision -Prompt "$script:Kickoff docs/features/active/alpha-401 and docs/features/active/bravo-with-a-much-longer-slug-402/spec.md"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^EPIC_WAVE_BARRIER_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'alpha-401'
            $decision.permissionDecisionReason | Should -Match 'bravo-with-a-much-longer-slug-402'
        }

        It 'W5b: denies as ambiguous for the reversed order with the longer slug first' {
            $decision = Invoke-WaveDecision -Prompt "$script:Kickoff docs/features/active/bravo-with-a-much-longer-slug-402/spec.md and docs/features/active/alpha-401"
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^EPIC_WAVE_BARRIER_BLOCKED: ambiguous target feature folder'
            $decision.permissionDecisionReason | Should -Match 'alpha-401'
            $decision.permissionDecisionReason | Should -Match 'bravo-with-a-much-longer-slug-402'
        }
    }

    Context 'tokens that truncate to fewer than four segments' {
        BeforeEach {
            $script:CheckpointJson = Get-TargetCheckpoint
        }

        It 'W6a: denies a bare docs/features/active/ token as naming no folder' {
            $decision = Invoke-WaveDecision -Prompt "$script:Kickoff See docs/features/active/ for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target feature folder'
        }

        It 'W6b: denies a docs/features/active/. token as naming no folder' {
            $decision = Invoke-WaveDecision -Prompt "$script:Kickoff See docs/features/active/. for the work."
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'must reference the target feature folder'
        }
    }

    Context 'the #621/#508 regression fixture with integer depends_on edges' {
        BeforeAll {
            $script:F507 = '2026-08-22-push-down-root-folders-divergence-507'
            $script:F508 = '2026-08-22-blast-radius-config-has-no-merge-decorator-508'
            $script:F621 = '2026-09-29-push-down-destination-exclusion-manifest-621'
            $script:Prompt621 = "$script:Kickoff Execute docs/features/active/$script:F621/spec.md. " +
            (Get-UpstreamLine -Number '621' -Dependency '507' -Folder $script:F507) + ' ' +
            (Get-UpstreamLine -Number '621' -Dependency '508' -Folder $script:F508)

            function Get-Fixture621 {
                param([string] $Status508 = 'merged')
                return '{"features":[' +
                '{"issue_num":507,"feature_folder":"' + $script:F507 + '","depends_on":[],"merge_status":"merged"},' +
                '{"issue_num":508,"feature_folder":"' + $script:F508 + '","depends_on":[],"merge_status":"' + $Status508 + '"},' +
                '{"issue_num":621,"feature_folder":"' + $script:F621 + '","depends_on":[507,508],"merge_status":"not_started"}' +
                ']}'
            }
        }

        It 'W7a: evaluates feature 621 and allows while 507 and 508 are merged' {
            $script:CheckpointJson = Get-Fixture621
            (Invoke-WaveDecision -Prompt $script:Prompt621).permissionDecision | Should -Be 'allow'
        }

        It 'W7b: evaluates feature 621 and denies when 508 is pr_open' {
            $script:CheckpointJson = Get-Fixture621 -Status508 'pr_open'
            $decision = Invoke-WaveDecision -Prompt $script:Prompt621
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "^EPIC_WAVE_BARRIER_BLOCKED: '$script:F621'"
        }

        It 'W8a: matches a minimal integer depends_on edge and allows when the dependency is merged' {
            $script:CheckpointJson = '{"features":[' +
            '{"issue_num":300,"feature_folder":"edge-a-300","depends_on":[],"merge_status":"merged"},' +
            '{"issue_num":301,"feature_folder":"edge-b-301","depends_on":[300],"merge_status":"not_started"}]}'
            (Invoke-WaveDecision -Prompt "$script:Kickoff Execute docs/features/active/edge-b-301.").permissionDecision | Should -Be 'allow'
        }

        It 'W8b: matches a minimal integer depends_on edge and denies when the dependency is pr_open' {
            $script:CheckpointJson = '{"features":[' +
            '{"issue_num":300,"feature_folder":"edge-a-300","depends_on":[],"merge_status":"pr_open"},' +
            '{"issue_num":301,"feature_folder":"edge-b-301","depends_on":[300],"merge_status":"not_started"}]}'
            (Invoke-WaveDecision -Prompt "$script:Kickoff Execute docs/features/active/edge-b-301.").permissionDecision | Should -Be 'deny'
        }
    }

    Context 'shared resolver import failure' {
        It 'W9: denies naming feature-folder-resolution.ps1 and guards the dot-source' {
            # Arrange: simulate the recorded dot-source failure.
            $script:CheckpointJson = Get-TargetCheckpoint
            $script:EpicWaveBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                # Act
                $decision = Invoke-WaveDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target."
            }
            finally {
                $script:EpicWaveBarrierResolutionImportFailure = $null
            }

            # Assert: the decision denies naming the shared file.
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^EPIC_WAVE_BARRIER_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'feature-folder-resolution\.ps1'

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
                            $node.Left.Extent.Text -eq '$script:EpicWaveBarrierResolutionImportFailure'
                        }, $true)
                })
            $assignments.Count | Should -BeGreaterThan 0 -Because 'the catch clause must record the failure'
        }
    }

    Context 'lifecycle-prefixed record values' {
        It 'W10: matches records recorded with active/ and docs/features/active/ prefixes' {
            $script:CheckpointJson = '{"features":[' +
            '{"issue_num":300,"feature_folder":"docs/features/active/' + $script:Upstream + '","depends_on":[],"merge_status":"merged"},' +
            '{"issue_num":301,"feature_folder":"active/' + $script:Target + '","depends_on":["docs/features/active/' + $script:Upstream + '"],"merge_status":"not_started"}' +
            ']}'
            (Invoke-WaveDecision -Prompt "$script:Kickoff Execute docs/features/active/$script:Target.").permissionDecision | Should -Be 'allow'
        }
    }
}
