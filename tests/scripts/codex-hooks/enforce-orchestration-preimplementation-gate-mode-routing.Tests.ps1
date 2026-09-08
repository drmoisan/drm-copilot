#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Mode-routing coverage for the Codex preimplementation gate (issue #545, [P12-T9]).

.DESCRIPTION
    tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
    drives the mode helpers directly: the mode resolver, the checkpoint-path table, the
    declared-path cross-check, the two target resolvers, the deny-reason builder, and the
    two readiness predicates each have named cases there. What no Codex case exercised is
    the epic and parallel LEG of Invoke-OrchestrationPreimplementationGateDecision that
    calls those helpers in sequence, together with the two per-mode read seams
    Get-EpicCheckpointContent and Get-ParallelCheckpointContent that the leg falls back to
    when no checkpoint text is injected. This file supplies that routing coverage.

    Injection idiom (issue #554, decision D2): -EpicCheckpointRaw and -ParallelCheckpointRaw
    override their read seam whenever the caller BINDS them, decided with ContainsKey. A
    case that binds one supplies its checkpoint entirely from a literal and touches no file.
    The two cases below that deliberately omit the parameter exercise the read seam; each
    asserts only that the gate DENIES and that the deny reason names the mode's canonical
    checkpoint, which holds whether or not the file exists and whatever it contains, because
    the fixture target folder child-b-301 and issue 301 are synthetic and appear in no real
    orchestration checkpoint.

    Determinism: no case writes to disk, no case creates a temporary file, no case starts a
    child process, and no assertion depends on ambient state.
#>

Describe 'Codex enforce-orchestration-preimplementation-gate mode routing (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest

        # The delegation prompts. Each carries its mode marker, the synthetic target
        # folder token the folder resolver reads, and the bare-hash issue number.
        $script:EpicPrompt = 'Epic mode: true. epic_feature_folder: quickfiler-bug-family. ' +
        'Execute the approved plan in docs/features/active/child-b-301 for issue #301.'
        $script:ParallelPrompt = 'Parallel mode: true. parallel_slug: critical-bug-fixes. ' +
        'Execute the approved plan in docs/features/active/child-b-301 for issue #301.'
        $script:RogueEpicPrompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/rogue-epic-state.json. ' +
        'Execute the approved plan in docs/features/active/child-b-301 for issue #301.'

        function ConvertTo-CodexDelegationToolInput {
            <#
                Builds the FLAT mapped tool_input JSON the Codex decision seam consumes.
                This is not an Agent envelope and claims no Agent transport; it is the
                same shape the classifier parity cases in the mode-resolution suite use.
            #>
            param(
                [Parameter(Mandatory)][string] $Prompt,
                [string] $SubagentType = 'atomic-executor'
            )

            return (@{ subagent_type = $SubagentType; prompt = $Prompt } | ConvertTo-Json -Compress -Depth 3)
        }

        function ConvertTo-CodexRoutingEpicCheckpointJson {
            <# A ready epic checkpoint; blank one field to violate exactly one conjunct. #>
            param(
                [string] $RouteId = 'epic',
                [string] $EpicFeatureFolder = 'quickfiler-bug-family',
                [string] $EpicManifestPath = 'docs/features/epics/quickfiler-bug-family/epic.md',
                [string] $IntegrationBranch = 'epic/quickfiler-bug-family-integration'
            )

            $features = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"}]'
            return '{"route_id":"' + $RouteId + '","epic_feature_folder":"' + $EpicFeatureFolder +
            '","epic_manifest_path":"' + $EpicManifestPath + '","integration_branch":"' +
            $IntegrationBranch + '","features":' + $features + '}'
        }

        function ConvertTo-CodexRoutingParallelCheckpointJson {
            <# A ready parallel checkpoint; blank one field to violate exactly one conjunct. #>
            param(
                [string] $RouteId = 'parallel',
                [string] $ParallelSlug = 'critical-bug-fixes',
                [string] $ParallelManifestPath = 'docs/features/parallel/critical-bug-fixes/parallel.md'
            )

            $items = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,' +
            '"state":"in_flight","merge_status":"not_started"}]'
            return '{"route_id":"' + $RouteId + '","parallel_slug":"' + $ParallelSlug +
            '","parallel_manifest_path":"' + $ParallelManifestPath + '","items":' + $items + '}'
        }
    }

    Context 'the epic leg of the decision router' {
        It 'allows an epic-mode delegation against an injected ready epic checkpoint' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt) `
                -EpicCheckpointRaw (ConvertTo-CodexRoutingEpicCheckpointJson)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies an epic-mode delegation and names integration_branch as the failed predicate' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt) `
                -EpicCheckpointRaw (ConvertTo-CodexRoutingEpicCheckpointJson -IntegrationBranch '')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match "the failed readiness predicate is 'integration_branch'"
        }

        It 'denies an epic-mode delegation whose injected checkpoint text is malformed JSON' {
            # The parse failure degrades the checkpoint to null rather than throwing, and
            # the readiness predicate then denies.
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt) `
                -EpicCheckpointRaw '{broken'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'artifacts/orchestration/epic-orchestrator-state\.json'
        }

        It 'denies an epic-mode delegation whose injected checkpoint text is empty' {
            # An explicitly bound empty string suppresses the read seam instead of falling
            # through to disk, so the gate denies rather than consulting a file.
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt) `
                -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies an epic-mode delegation that declares a non-canonical checkpoint path' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:RogueEpicPrompt) `
                -EpicCheckpointRaw (ConvertTo-CodexRoutingEpicCheckpointJson)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match "the failed readiness predicate is 'declared-checkpoint-path'"
        }
    }

    Context 'the parallel leg of the decision router' {
        It 'allows a parallel-mode delegation against an injected ready parallel checkpoint' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:ParallelPrompt) `
                -ParallelCheckpointRaw (ConvertTo-CodexRoutingParallelCheckpointJson)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a parallel-mode delegation and names parallel_slug as the failed predicate' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:ParallelPrompt) `
                -ParallelCheckpointRaw (ConvertTo-CodexRoutingParallelCheckpointJson -ParallelSlug '')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match "the failed readiness predicate is 'parallel_slug'"
        }

        It 'denies a parallel-mode delegation whose injected checkpoint declares the epic route' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:ParallelPrompt) `
                -ParallelCheckpointRaw (ConvertTo-CodexRoutingParallelCheckpointJson -RouteId 'epic')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match "the failed readiness predicate is 'route_id'"
        }
    }

    Context 'the per-mode read seams supply the checkpoint when no text is injected' {
        It 'denies an epic-mode delegation against the canonical epic checkpoint read seam' {
            # No -EpicCheckpointRaw, so Get-EpicCheckpointContent supplies the text. The
            # synthetic target child-b-301 appears in no real epic checkpoint, so the deny
            # holds whether the canonical file is present or absent.
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'artifacts/orchestration/epic-orchestrator-state\.json'
        }

        It 'denies a parallel-mode delegation against the canonical parallel checkpoint read seam' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:ParallelPrompt)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'artifacts/orchestration/parallel-orchestrator-state\.json'
        }
    }

    Context 'the mode legs do not capture a non-implementation delegation' {
        It 'allows a research delegation that carries the epic marker' {
            # The classifier decides scope before the mode leg runs, so a non-implementation
            # subagent type never reaches the epic readiness check.
            $decision = Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexDelegationToolInput -Prompt $script:EpicPrompt -SubagentType 'task-researcher') `
                -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
