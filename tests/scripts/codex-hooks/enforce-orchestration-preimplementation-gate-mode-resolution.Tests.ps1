#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex-side logic-parity cases for the issue #554 mode dispatch and readiness
    predicates, plus the recorded Agent-transport gap.
.DESCRIPTION
    Decision D5. `.codex/config.toml` registers no PreToolUse matcher admitting an
    Agent or Task tool name, so an Agent delegation cannot reach the Codex gate at
    all. The honest Codex deliverable is therefore exactly two things and nothing
    more: direct unit tests of the shared logic, which prove LOGIC PARITY between
    the two copies without claiming a reachable transport; and one assertion test
    recording the transport gap as a deliberate, tested fact.

    Fabricating an Agent envelope on this surface and asserting a decision on it is
    explicitly PROHIBITED by decision D5: it would assert behaviour on a code path
    the Codex runtime never exercises and produce a green test proving nothing
    about the shipped surface. No case below constructs an Agent tool payload for
    the Codex decision function.

    The constructed inputs are the same literal fixtures the Claude-side suite
    `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
    uses, and the asserted outcomes are the same outcomes it asserts.

    Determinism. Every fixture is a literal string; the suite makes no temporary
    file, performs no filesystem write, reads no wall clock, opens no network
    connection, and starts no external process. The single sanctioned disk read is
    the tracked `.codex/config.toml`, permitted by the spec's test strategy because
    the fact that case records is a property of that committed file and cannot be
    expressed any other way. It is resolved through a `$PSScriptRoot`-relative
    `Resolve-Path`, so the suite carries no working-directory assumption.
#>

Describe 'Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        # Dot-sourced explicitly as well as through the gate hook above, so a future
        # change to the hook's dot-source line cannot silently leave these cases
        # asserting against functions that came from somewhere else.
        $script:ModesUnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1").Path
        . $script:ModesUnderTest

        function ConvertTo-CodexEpicCheckpointJson {
            # Byte-for-byte the Claude-side fixture shape: a ready epic checkpoint by
            # default; blank a field or set a switch to violate exactly one conjunct.
            param(
                [string] $RouteId = 'epic',
                [string] $EpicFeatureFolder = 'quickfiler-bug-family',
                [string] $EpicManifestPath = 'docs/features/epics/quickfiler-bug-family/epic.md',
                [string] $IntegrationBranch = 'epic/quickfiler-bug-family-integration',
                [string] $FeatureFolder = 'docs/features/active/child-b-301',
                [string] $IssueNum = '301',
                [string] $MergeStatus = 'not_started',
                [switch] $OmitFeatures
            )

            $features = '[]'
            if (-not $OmitFeatures) {
                $features = '[{"feature_folder":"' + $FeatureFolder + '","issue_num":' + $IssueNum +
                ',"merge_status":"' + $MergeStatus + '"}]'
            }
            return '{"route_id":"' + $RouteId + '","epic_feature_folder":"' + $EpicFeatureFolder +
            '","epic_manifest_path":"' + $EpicManifestPath + '","integration_branch":"' +
            $IntegrationBranch + '","features":' + $features + '}'
        }

        function ConvertTo-CodexParallelCheckpointJson {
            # A ready parallel checkpoint by default, carrying only the read keys.
            param(
                [string] $RouteId = 'parallel',
                [string] $ParallelSlug = 'critical-bug-fixes',
                [string] $ParallelManifestPath = 'docs/features/parallel/critical-bug-fixes/parallel.md',
                [string] $FeatureFolder = 'docs/features/active/child-b-301',
                [string] $IssueNum = '301',
                [string] $MergeStatus = 'not_started',
                [switch] $OmitItems
            )

            $items = '[]'
            if (-not $OmitItems) {
                $items = '[{"feature_folder":"' + $FeatureFolder + '","issue_num":' + $IssueNum +
                ',"state":"in_flight","merge_status":"' + $MergeStatus + '"}]'
            }
            return '{"route_id":"' + $RouteId + '","parallel_slug":"' + $ParallelSlug +
            '","parallel_manifest_path":"' + $ParallelManifestPath + '","items":' + $items + '}'
        }
    }

    Context 'mode resolution parity' {
        It 'resolves the <Expected> mode for its marker prompt' -ForEach @(
            @{ Expected = 'preparation'; Prompt = 'Preparation mode: true. route_id: preparation. Perform promotion only.' }
            @{ Expected = 'epic'; Prompt = 'Epic mode: true. epic_feature_folder: quickfiler-bug-family.' }
            @{ Expected = 'parallel'; Prompt = 'Parallel mode: true. parallel_slug: critical-bug-fixes.' }
            @{ Expected = 'single-feature'; Prompt = 'Execute the approved plan for this feature.' }
            @{ Expected = 'preparation'; Prompt = 'Preparation mode: true. route_id: preparation. Epic mode: true.' }
            @{ Expected = 'single-feature'; Prompt = 'Preparation mode: true. Do the work.' }
            @{ Expected = 'single-feature'; Prompt = '' }
        ) {
            Resolve-OrchestrationDelegationMode -Prompt $Prompt | Should -Be $Expected
        }

        It 'maps the <Mode> mode to its canonical checkpoint path' -ForEach @(
            @{ Mode = 'preparation'; Path = '' }
            @{ Mode = 'epic'; Path = 'artifacts/orchestration/epic-orchestrator-state.json' }
            @{ Mode = 'parallel'; Path = 'artifacts/orchestration/parallel-orchestrator-state.json' }
            @{ Mode = 'single-feature'; Path = 'artifacts/orchestration/orchestrator-state.json' }
        ) {
            Get-OrchestrationDelegationCheckpointPath -Mode $Mode | Should -Be $Path
        }

        It '<Verdict> the declared checkpoint path for <Mode> mode' -ForEach @(
            @{ Verdict = 'accepts'; Mode = 'epic'; Expect = $true; Prompt = 'Epic mode: true. epic_feature_folder: quickfiler-bug-family.' }
            @{ Verdict = 'accepts'; Mode = 'epic'; Expect = $true; Prompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json.' }
            @{ Verdict = 'rejects'; Mode = 'epic'; Expect = $false; Prompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/rogue-epic-state.json.' }
            @{ Verdict = 'accepts'; Mode = 'parallel'; Expect = $true; Prompt = 'Parallel mode: true. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json.' }
            @{ Verdict = 'rejects'; Mode = 'parallel'; Expect = $false; Prompt = 'Parallel mode: true. parallel_checkpoint_path: artifacts/orchestration/rogue-parallel-state.json.' }
        ) {
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt $Prompt -Mode $Mode | Should -Be $Expect
        }
    }

    Context 'epic readiness predicate parity' {
        It 'names <Failure> as the failed conjunct' -ForEach @(
            @{ Failure = 'route_id'; Fixture = @{ RouteId = 'large' } }
            @{ Failure = 'epic_feature_folder'; Fixture = @{ EpicFeatureFolder = '' } }
            @{ Failure = 'epic_manifest_path'; Fixture = @{ EpicManifestPath = '' } }
            @{ Failure = 'integration_branch'; Fixture = @{ IntegrationBranch = '' } }
            @{ Failure = 'features'; Fixture = @{ OmitFeatures = $true } }
            @{ Failure = 'target-record'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' } }
            @{ Failure = 'merge_status'; Fixture = @{ MergeStatus = 'merged' } }
        ) {
            $checkpoint = (ConvertTo-CodexEpicCheckpointJson @Fixture) | ConvertFrom-Json
            Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Failure
        }

        It '<Label> for the epic readiness wrapper' -ForEach @(
            @{ Label = 'reports ready'; Expect = $true; Fixture = @{} }
            @{ Label = 'denies the terminal-merged worktree_removed status'; Expect = $false; Fixture = @{ MergeStatus = 'worktree_removed' } }
            @{ Label = 'allows the failure status blocked_conflict_loop_limit'; Expect = $true; Fixture = @{ MergeStatus = 'blocked_conflict_loop_limit' } }
        ) {
            $checkpoint = (ConvertTo-CodexEpicCheckpointJson @Fixture) | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Expect
        }

        It 'returns false from the wrapper for a null checkpoint' {
            Test-EpicOrchestrationReady -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }
    }

    Context 'parallel readiness predicate parity' {
        It 'names <Failure> as the failed conjunct' -ForEach @(
            @{ Failure = 'route_id'; Fixture = @{ RouteId = 'epic' } }
            @{ Failure = 'parallel_slug'; Fixture = @{ ParallelSlug = '' } }
            @{ Failure = 'parallel_manifest_path'; Fixture = @{ ParallelManifestPath = '' } }
            @{ Failure = 'items'; Fixture = @{ OmitItems = $true } }
            @{ Failure = 'target-record'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' } }
            @{ Failure = 'merge_status'; Fixture = @{ MergeStatus = 'merged' } }
        ) {
            $checkpoint = (ConvertTo-CodexParallelCheckpointJson @Fixture) | ConvertFrom-Json
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Failure
        }

        It '<Label> for the parallel readiness wrapper' -ForEach @(
            @{ Label = 'reports ready'; Expect = $true; Fixture = @{} }
            @{ Label = 'denies the terminal-merged worktree_removed status'; Expect = $false; Fixture = @{ MergeStatus = 'worktree_removed' } }
            @{ Label = 'allows the blocked status blocked_drift, adding no enum member'; Expect = $true; Fixture = @{ MergeStatus = 'blocked_drift' } }
        ) {
            $checkpoint = (ConvertTo-CodexParallelCheckpointJson @Fixture) | ConvertFrom-Json
            Test-ParallelOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Expect
        }

        It 'returns false from the wrapper for a null checkpoint' {
            Test-ParallelOrchestrationReady -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }
    }

    Context 'classifier parity through the mapped flat tool_input the Codex seam consumes' {
        It 'classifies <SubagentType> as implementation: <Expect>' -ForEach @(
            @{ SubagentType = 'atomic-executor'; Prompt = ''; Expect = $true }
            @{ SubagentType = 'powershell-typed-engineer'; Prompt = ''; Expect = $true }
            @{ SubagentType = 'task-researcher'; Prompt = 'atomic-executor implementation execute'; Expect = $false }
            @{ SubagentType = 'orchestrator'; Prompt = 'Preparation mode: true. route_id: preparation. Promote only.'; Expect = $false }
            @{ SubagentType = 'orchestrator'; Prompt = 'Begin atomic execution of the approved plan.'; Expect = $true }
        ) {
            # A flat tool_input object, which is the shape the Codex seam consumes. This
            # is NOT an Agent envelope and no Agent transport is claimed for it; the
            # object is passed straight to the pure classifier.
            $toolInput = [pscustomobject]@{ subagent_type = $SubagentType; prompt = $Prompt }
            Test-ImplementationDelegation -ToolInput $toolInput | Should -Be $Expect
        }
    }

    Context 'the recorded Agent-transport gap (decision D5, deliverable ii)' {
        It 'registers no PreToolUse matcher admitting an Agent or Task tool name' {
            # Issue #555 owns this gap. It is recorded here as a deliberate, tested fact
            # rather than an oversight: because no PreToolUse tool matcher in
            # .codex/config.toml admits an Agent or Task tool name, an Agent delegation
            # never reaches this hook on the Codex surface, which is why the parity cases
            # above call the shared predicates directly instead of fabricating an
            # envelope. Closing the gap is issue #555's scope, not issue #554's.
            $configPath = (Resolve-Path "$PSScriptRoot/../../../.codex/config.toml").Path
            $lines = Get-Content -LiteralPath $configPath

            $toolMatchers = @()
            for ($index = 0; $index -lt $lines.Count; $index++) {
                if ($lines[$index].Trim() -ne '[[hooks.PreToolUse]]') { continue }
                for ($scan = $index + 1; $scan -lt $lines.Count; $scan++) {
                    $candidate = [regex]::Match($lines[$scan], '^\s*matcher\s*=\s*"(?<value>.*)"\s*$')
                    if ($candidate.Success) {
                        $toolMatchers += $candidate.Groups['value'].Value
                        break
                    }
                    if ($lines[$scan].Trim().StartsWith('[')) { break }
                }
            }

            $toolMatchers.Count | Should -BeGreaterThan 0 -Because 'the parse must find the PreToolUse tool matchers'
            foreach ($matcher in $toolMatchers) {
                'Agent' | Should -Not -Match $matcher -Because "$matcher must not admit an Agent tool name"
                'Task' | Should -Not -Match $matcher -Because "$matcher must not admit a Task tool name"
                $matcher | Should -Not -Match 'Agent|Task' -Because "$matcher must not name the Agent or Task transport"
            }
        }
    }
}
