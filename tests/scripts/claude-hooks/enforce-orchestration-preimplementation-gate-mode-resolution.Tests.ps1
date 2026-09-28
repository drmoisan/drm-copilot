#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Mode-resolution and per-mode readiness cases for the Claude preimplementation gate.
.DESCRIPTION
    Literal JSON mode-resolution and readiness cases. They perform no I/O or external
    process execution; checkpoint content is supplied as a function input.
#>

Describe 'enforce-orchestration-preimplementation-gate.ps1 mode resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        # The modes sibling is dot-sourced explicitly so the predicate-level cases
        # resolved its functions during Batch A, before the main gate hook carried that
        # line. It is now redundant but harmless: dot-sourcing the same pure file twice
        # redefines identical functions and identical constants.
        $script:ModesUnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1").Path
        . $script:ModesUnderTest

        function ConvertTo-DelegationToolInputJson {
            # An Agent delegation envelope as a literal JSON string. A Description value,
            # when supplied, is written into a non-prompt field so field-scoping cases can
            # plant marker text where the classifier must not read it.
            param(
                [string] $SubagentType = 'orchestrator',
                [string] $Prompt = '',
                [string] $Description = ''
            )

            $text = '{"tool_name":"Agent","tool_input":{"subagent_type":"' +
            $SubagentType + '","prompt":"' + $Prompt + '"'
            if ($Description) { $text += ',"description":"' + $Description + '"' }
            return ($text + '}}')
        }

        function ConvertTo-SingleFeatureCheckpointJson {
            # The default single-feature orchestrator checkpoint, ready by default. Every
            # case asserting a deny must supply an explicit checkpoint: one that omitted it
            # would fall through to the on-disk checkpoint, which is ready during an
            # orchestrated run, and the assertion would pass vacuously.
            param(
                [string] $IssueNum = '554',
                [string] $FeatureFolder = 'docs/features/active/preimplementation-gate-blocks-epic-execution-554',
                [string] $RouteId = 'large',
                [bool] $LifecycleReady = $true
            )

            $readyText = if ($LifecycleReady) { 'true' } else { 'false' }
            return '{"issue-num":"' + $IssueNum + '","feature-folder":"' + $FeatureFolder +
            '","route_id":"' + $RouteId + '","lifecycle_ready":' + $readyText + '}'
        }

        function ConvertTo-EpicCheckpointJson {
            # A ready epic checkpoint by default; blank a field or set a switch to violate
            # exactly one conjunct.
            param(
                [string] $RouteId = 'epic',
                [string] $EpicFeatureFolder = 'quickfiler-bug-family',
                [string] $EpicManifestPath = 'docs/features/epics/quickfiler-bug-family/epic.md',
                [string] $IntegrationBranch = 'epic/quickfiler-bug-family-integration',
                [string] $FeatureFolder = 'docs/features/active/child-b-301',
                [string] $IssueNum = '301',
                [string] $MergeStatus = 'not_started',
                [switch] $OmitFeatures,
                [switch] $OmitMergeStatus
            )

            $features = '[]'
            if (-not $OmitFeatures) {
                $record = '{"feature_folder":"' + $FeatureFolder + '","issue_num":' + $IssueNum
                if (-not $OmitMergeStatus) { $record += ',"merge_status":"' + $MergeStatus + '"' }
                $features = '[' + $record + '}]'
            }
            return '{"route_id":"' + $RouteId + '","epic_feature_folder":"' + $EpicFeatureFolder +
            '","epic_manifest_path":"' + $EpicManifestPath + '","integration_branch":"' +
            $IntegrationBranch + '","features":' + $features + '}'
        }

        function ConvertTo-ParallelCheckpointJson {
            # A ready parallel checkpoint by default, carrying only the read keys.
            param(
                [string] $RouteId = 'parallel',
                [string] $ParallelSlug = 'critical-bug-fixes',
                [string] $ParallelManifestPath = 'docs/features/parallel/critical-bug-fixes/parallel.md',
                [string] $FeatureFolder = 'docs/features/active/child-b-301',
                [string] $IssueNum = '301',
                [string] $MergeStatus = 'not_started',
                [switch] $OmitItems,
                [switch] $OmitMergeStatus
            )

            $items = '[]'
            if (-not $OmitItems) {
                $record = '{"feature_folder":"' + $FeatureFolder + '","issue_num":' + $IssueNum +
                ',"state":"in_flight"'
                if (-not $OmitMergeStatus) { $record += ',"merge_status":"' + $MergeStatus + '"' }
                $items = '[' + $record + '}]'
            }
            return '{"route_id":"' + $RouteId + '","parallel_slug":"' + $ParallelSlug +
            '","parallel_manifest_path":"' + $ParallelManifestPath + '","items":' + $items + '}'
        }
    }

    Context 'Fault-1 wording independence, direction (b): the new allow-to-deny change' {
        It 'denies an orchestrator delegation phrased with "atomic execution" and no mode markers against an unready single-feature checkpoint' {
            # Matrix case 6b: the case that INCORRECTLY ALLOWED before the fix, and the
            # one behaviour change this fix makes in the allow-to-deny direction rather
            # than a preservation. The prompt is phrased with "atomic execution" and
            # carries NEITHER legacy free-text token - "execution" does not contain the
            # bare token "execute", and "implementation" does not appear - and no
            # allow-listed agent name appears either, so the pre-fix seven-token scan
            # over the serialized payload matched nothing and allowed. After the fix
            # subagent_type is exactly 'orchestrator' and the prompt carries no mode
            # marker, so the mode is the default, the delegation is implementation, and
            # the unready checkpoint supplied below denies.
            $json = ConvertTo-DelegationToolInputJson -SubagentType 'orchestrator' -Prompt 'Begin atomic execution of the approved plan for this feature.'
            $checkpoint = ConvertTo-SingleFeatureCheckpointJson -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'resolved issue|merge_status'
        }
    }

    Context 'mode resolution from the fixed table' {
        It 'resolves the <Expected> mode for its marker prompt' -ForEach @(
            @{ Expected = 'preparation'; Prompt = 'Preparation mode: true. route_id: preparation. Perform promotion only.' }
            @{ Expected = 'epic'; Prompt = 'Epic mode: true. epic_feature_folder: quickfiler-bug-family.' }
            @{ Expected = 'parallel'; Prompt = 'Parallel mode: true. parallel_slug: critical-bug-fixes.' }
            @{ Expected = 'single-feature'; Prompt = 'Execute the approved plan for this feature.' }
        ) {
            Resolve-OrchestrationDelegationMode -Prompt $Prompt | Should -Be $Expected
        }

        It 'evaluates preparation first when an execution marker is also present' {
            $prompt = 'Preparation mode: true. route_id: preparation. Epic mode: true. Parallel mode: true.'
            Resolve-OrchestrationDelegationMode -Prompt $prompt | Should -Be 'preparation'
        }

        It 'requires both preparation markers, so a single marker falls through to the default mode' {
            Resolve-OrchestrationDelegationMode -Prompt 'Preparation mode: true. Do the work.' | Should -Be 'single-feature'
        }

        It 'resolves the default mode for an <Label> prompt' -ForEach @(
            @{ Label = 'empty'; Prompt = '' }
            @{ Label = 'null'; Prompt = $null }
        ) {
            Resolve-OrchestrationDelegationMode -Prompt $Prompt | Should -Be 'single-feature'
        }

        It 'maps the <Mode> mode to its canonical checkpoint path' -ForEach @(
            @{ Mode = 'preparation'; Path = '' }
            @{ Mode = 'epic'; Path = 'artifacts/orchestration/epic-orchestrator-state.json' }
            @{ Mode = 'parallel'; Path = 'artifacts/orchestration/parallel-orchestrator-state.json' }
            @{ Mode = 'single-feature'; Path = 'artifacts/orchestration/orchestrator-state.json' }
        ) {
            Get-OrchestrationDelegationCheckpointPath -Mode $Mode | Should -Be $Path
        }

        It 'returns an empty checkpoint path for a mode name that is not in the table' {
            Get-OrchestrationDelegationCheckpointPath -Mode 'invented-mode' | Should -Be ''
        }
    }

    Context 'the prompt-declared checkpoint-path cross-check' {
        It 'accepts an <Label> declared epic checkpoint path' -ForEach @(
            @{ Label = 'absent'; Prompt = 'Epic mode: true. epic_feature_folder: quickfiler-bug-family.' }
            @{ Label = 'matching'; Prompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json.' }
        ) {
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt $Prompt -Mode 'epic' | Should -BeTrue
        }

        It 'rejects a declared epic checkpoint path that differs from the canonical value' {
            $prompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/rogue-epic-state.json.'
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt $prompt -Mode 'epic' | Should -BeFalse
        }

        It 'rejects a declared parallel checkpoint path that differs from the canonical value' {
            $prompt = 'Parallel mode: true. parallel_checkpoint_path: artifacts/orchestration/rogue-parallel-state.json.'
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt $prompt -Mode 'parallel' | Should -BeFalse
        }

        It 'accepts a matching declared parallel checkpoint path' {
            $prompt = 'Parallel mode: true. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json.'
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt $prompt -Mode 'parallel' | Should -BeTrue
        }

        It 'has nothing to cross-check for a mode carrying no declared-path key' {
            Test-OrchestrationDelegationDeclaredCheckpointPath -Prompt 'Do the work.' -Mode 'single-feature' | Should -BeTrue
        }
    }

    Context 'target resolution out of the prompt' {
        It 'returns nothing for a prompt carrying no feature-folder token' {
            Find-OrchestrationDelegationTargetFolder -Prompt 'Epic mode: true. Begin the work.' | Should -BeNullOrEmpty
        }

        It 'returns the parent basename for a token ending in a Markdown file' {
            Find-OrchestrationDelegationTargetFolder -Prompt 'Plan: docs/features/active/child-b-301/plan.md now.' | Should -Be 'child-b-301'
        }

        It 'returns the basename for a bare directory token' {
            Find-OrchestrationDelegationTargetFolder -Prompt 'Target docs/features/active/child-b-301.' | Should -Be 'child-b-301'
        }

        It 'returns nothing for a prompt carrying no issue number' {
            Find-OrchestrationDelegationIssueNumber -Prompt 'Epic mode: true. Begin the work.' | Should -BeNullOrEmpty
        }

        It 'returns the numeric string for a prompt carrying an <Label> issue number' -ForEach @(
            @{ Label = 'keyed'; Prompt = 'Epic mode: true. issue_num: 301.'; Expected = '301' }
            @{ Label = 'Issue number wording'; Prompt = 'Implement Issue number: 644 now.'; Expected = '644' }
            @{ Label = 'mixed-prose hash-form'; Prompt = 'Keep prior #638 evidence while resolving this task.'; Expected = '638' }
        ) {
            Find-OrchestrationDelegationIssueNumber -Prompt $Prompt | Should -Be $Expected
        }
    }

    Context 'ordered mode record resolution' {
        It 'selects the later exact folder record in epic readiness' {
            $checkpoint = '{"route_id":"epic","epic_feature_folder":"family","epic_manifest_path":"docs/features/epics/family/epic.md","integration_branch":"epic/family","features":[{"feature_folder":"docs/features/active/other-644","issue_num":644,"merge_status":"merged"},{"feature_folder":"docs/features/active/child-644","issue_num":999,"merge_status":"not_started"}]}' | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-644' -IssueNumber '644' | Should -BeTrue
        }

        It 'selects the later exact folder record in parallel readiness' {
            $checkpoint = '{"route_id":"parallel","parallel_slug":"family","parallel_manifest_path":"docs/features/parallel/family/parallel.md","items":[{"feature_folder":"docs/features/active/other-644","issue_num":644,"merge_status":"worktree_removed"},{"feature_folder":"docs/features/active/child-644","issue_num":999,"merge_status":"not_started"}]}' | ConvertFrom-Json
            Test-ParallelOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-644' -IssueNumber '644' | Should -BeTrue
        }

        It 'retains first matching issue fallback when no folder matches' {
            $records = '[{"feature_folder":"docs/features/active/first-644","issue_num":644},{"feature_folder":"docs/features/active/second-644","issue_num":644}]' | ConvertFrom-Json
            (Find-OrchestrationModeRecord -Records $records -TargetFolder 'no-match' -IssueNumber '644').feature_folder | Should -Be 'docs/features/active/first-644'
        }
    }

    Context 'the epic readiness predicate' {
        It 'names <Failure> as the failed conjunct' -ForEach @(
            @{ Failure = 'route_id'; Fixture = @{ RouteId = 'large' } }
            @{ Failure = 'epic_feature_folder'; Fixture = @{ EpicFeatureFolder = '' } }
            @{ Failure = 'epic_manifest_path'; Fixture = @{ EpicManifestPath = '' } }
            @{ Failure = 'epic_manifest_path'; Fixture = @{ EpicManifestPath = 'docs/features/active/not-an-epic/epic.md' } }
            @{ Failure = 'integration_branch'; Fixture = @{ IntegrationBranch = '' } }
            @{ Failure = 'features'; Fixture = @{ OmitFeatures = $true } }
            @{ Failure = 'target-record'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' } }
            @{ Failure = 'merge_status'; Fixture = @{ MergeStatus = 'merged' } }
        ) {
            $checkpoint = (ConvertTo-EpicCheckpointJson @Fixture) | ConvertFrom-Json
            Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Failure
        }

        It 'returns a non-empty failure name for a null checkpoint' {
            Get-EpicOrchestrationReadinessFailure -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Not -BeNullOrEmpty
        }

        It 'reports no failure for a fully ready epic checkpoint' {
            $checkpoint = (ConvertTo-EpicCheckpointJson) | ConvertFrom-Json
            Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be ''
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'treats an absent merge_status as not_started and does not fail the last conjunct' {
            $checkpoint = (ConvertTo-EpicCheckpointJson -OmitMergeStatus) | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'denies the terminal-merged merge status <MergeStatus> (decision D8)' -ForEach @(
            @{ MergeStatus = 'merged' }
            @{ MergeStatus = 'worktree_removed' }
        ) {
            $checkpoint = (ConvertTo-EpicCheckpointJson -MergeStatus $MergeStatus) | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }

        It 'allows the failure merge status <MergeStatus>, which is legitimate remediation (decision D8)' -ForEach @(
            @{ MergeStatus = 'merge_conflict' }
            @{ MergeStatus = 'blocked_conflict_loop_limit' }
        ) {
            $checkpoint = (ConvertTo-EpicCheckpointJson -MergeStatus $MergeStatus) | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'resolves the target by issue_num when no feature-folder basename matches' {
            $checkpoint = (ConvertTo-EpicCheckpointJson -FeatureFolder 'completed/child-b-301-renamed') | ConvertFrom-Json
            Test-EpicOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'returns false from the wrapper for a null checkpoint' {
            Test-EpicOrchestrationReady -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }
    }

    Context 'the parallel readiness predicate' {
        It 'names <Failure> as the failed conjunct' -ForEach @(
            @{ Failure = 'route_id'; Fixture = @{ RouteId = 'epic' } }
            @{ Failure = 'parallel_slug'; Fixture = @{ ParallelSlug = '' } }
            @{ Failure = 'parallel_manifest_path'; Fixture = @{ ParallelManifestPath = '' } }
            @{ Failure = 'items'; Fixture = @{ OmitItems = $true } }
            @{ Failure = 'target-record'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' } }
            @{ Failure = 'merge_status'; Fixture = @{ MergeStatus = 'worktree_removed' } }
        ) {
            $checkpoint = (ConvertTo-ParallelCheckpointJson @Fixture) | ConvertFrom-Json
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be $Failure
        }

        It 'returns a non-empty failure name for a null checkpoint' {
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Not -BeNullOrEmpty
        }

        It 'reports no failure for a fully ready parallel checkpoint' {
            $checkpoint = (ConvertTo-ParallelCheckpointJson) | ConvertFrom-Json
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -Be ''
            Test-ParallelOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'denies the terminal-merged merge status <MergeStatus> (decision D8)' -ForEach @(
            @{ MergeStatus = 'merged' }
            @{ MergeStatus = 'worktree_removed' }
        ) {
            $checkpoint = (ConvertTo-ParallelCheckpointJson -MergeStatus $MergeStatus) | ConvertFrom-Json
            Test-ParallelOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }

        It 'allows the blocked merge status <MergeStatus>, adding no member to the parallel enum' -ForEach @(
            @{ MergeStatus = 'blocked_drift' }
            @{ MergeStatus = 'blocked_ci_loop_limit' }
        ) {
            $checkpoint = (ConvertTo-ParallelCheckpointJson -MergeStatus $MergeStatus) | ConvertFrom-Json
            Test-ParallelOrchestrationReady -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeTrue
        }

        It 'returns false from the wrapper for a null checkpoint' {
            Test-ParallelOrchestrationReady -Checkpoint $null -TargetFolder 'child-b-301' -IssueNumber '301' |
                Should -BeFalse
        }
    }

    Context 'the implementation-agent allow-list' {
        It 'classifies the allow-listed agent <SubagentType> as an implementation agent' -ForEach @(
            @{ SubagentType = 'python-typed-engineer' }
            @{ SubagentType = 'powershell-typed-engineer' }
            @{ SubagentType = 'typescript-engineer' }
            @{ SubagentType = 'csharp-typed-engineer' }
            @{ SubagentType = 'atomic-executor' }
        ) {
            Test-OrchestrationImplementationAgent -SubagentType $SubagentType | Should -BeTrue
        }

        It 'holds exactly five members' {
            $script:OrchestrationImplementationAgentAllowList.Count | Should -Be 5
        }

        It 'does not classify <SubagentType> as an implementation agent' -ForEach @(
            @{ SubagentType = 'orchestrator' }
            @{ SubagentType = 'task-researcher' }
            @{ SubagentType = '' }
        ) {
            Test-OrchestrationImplementationAgent -SubagentType $SubagentType | Should -BeFalse
        }
    }

    Context 'the decision-level epic matrix' {
        # Every case here binds -EpicCheckpointRaw explicitly, including the empty-content
        # case, so no assertion falls through to the on-disk epic checkpoint.
        It '<Case>: <Label>' -ForEach @(
            @{ Case = 'matrix case 1'; Label = 'a ready epic checkpoint allows'; Prompt = 'Epic mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{}; Expect = 'allow'; Reason = '' }
            @{ Case = 'matrix case 2'; Label = 'empty injected epic content denies, naming the epic checkpoint'; Prompt = 'Epic mode: true. Execute docs/features/active/child-b-301.'; Fixture = $null; Expect = 'deny'; Reason = 'epic-orchestrator-state.json' }
            @{ Case = 'matrix case 3'; Label = 'a features array lacking the target record denies, naming the failed predicate'; Prompt = 'Epic mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' }; Expect = 'deny'; Reason = "'target-record'" }
            @{ Case = 'matrix case 4'; Label = 'a non-canonical declared epic_checkpoint_path denies'; Prompt = 'Epic mode: true. epic_checkpoint_path: artifacts/orchestration/rogue-epic-state.json. Execute docs/features/active/child-b-301.'; Fixture = @{}; Expect = 'deny'; Reason = "'declared-checkpoint-path'" }
            @{ Case = 'epic target unresolvable'; Label = 'a prompt with no resolvable target token and no issue number denies'; Prompt = 'Epic mode: true. Begin the wave-0 child now.'; Fixture = @{}; Expect = 'deny'; Reason = "'target-record'" }
            @{ Case = 'decision D8'; Label = 'a target record in a terminal-merged state denies'; Prompt = 'Epic mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{ MergeStatus = 'merged' }; Expect = 'deny'; Reason = "'merge_status'" }
            @{ Case = 'decision D8'; Label = 'a target record in a failure state allows, as legitimate remediation'; Prompt = 'Epic mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{ MergeStatus = 'merge_conflict' }; Expect = 'allow'; Reason = '' }
        ) {
            $raw = if ($null -eq $Fixture) { '' } else { ConvertTo-EpicCheckpointJson @Fixture }
            $json = ConvertTo-DelegationToolInputJson -Prompt $Prompt

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -EpicCheckpointRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expect
            if ($Reason) { $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ('*' + $Reason + '*') }
        }

        It 'matrix case 5: an epic marker in a non-prompt field resolves to the default single-feature mode' {
            # The marker is planted in 'description' and the prompt is clean. Had the mode
            # resolved to epic, the empty bound epic content would have denied naming the
            # epic checkpoint; naming the single-feature one proves the source consulted.
            $json = ConvertTo-DelegationToolInputJson -Prompt 'Begin atomic execution of the approved plan.' -Description 'Epic mode: true.'
            $unready = ConvertTo-SingleFeatureCheckpointJson -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $unready -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*orchestrator-state.json*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -BeLike '*epic-orchestrator-state.json*'
        }

    }

    Context 'the decision-level single-feature matrix' {
        It 'matrix case <Case>: <Label>' -ForEach @(
            @{ Case = '6a'; Label = 'an allow-listed implementation agent denies against an unready checkpoint whatever its prompt says'; SubagentType = 'atomic-executor'; Prompt = 'Carry out the approved plan for this feature.'; Expect = 'deny' }
            @{ Case = '7'; Label = 'both preparation markers exempt the delegation'; SubagentType = 'orchestrator'; Prompt = 'Preparation mode: true. route_id: preparation. Perform promotion only.'; Expect = 'allow' }
        ) {
            # Case 6a carries none of the seven legacy tokens: no allow-listed agent name
            # appears in the prompt text, and neither free-text token does either.
            $json = ConvertTo-DelegationToolInputJson -SubagentType $SubagentType -Prompt $Prompt
            $unready = ConvertTo-SingleFeatureCheckpointJson -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $unready

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expect
        }

        It 'matrix case 8: a standalone orchestrator allows against a ready single-feature checkpoint' {
            $json = ConvertTo-DelegationToolInputJson -Prompt 'Execute the approved plan for this feature.'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw (ConvertTo-SingleFeatureCheckpointJson)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'matrix case 8: a standalone orchestrator denies against an unready single-feature checkpoint' {
            $json = ConvertTo-DelegationToolInputJson -Prompt 'Execute the approved plan for this feature.'
            $unready = ConvertTo-SingleFeatureCheckpointJson -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $unready

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'the decision-level parallel matrix' {
        It '<Label>' -ForEach @(
            @{ Label = 'a ready parallel checkpoint allows'; Prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{}; Expect = 'allow'; Reason = '' }
            @{ Label = 'an items array lacking the target record denies, naming the parallel checkpoint'; Prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301.'; Fixture = @{ FeatureFolder = 'docs/features/active/other-child-999'; IssueNum = '999' }; Expect = 'deny'; Reason = 'parallel-orchestrator-state.json' }
            @{ Label = 'a non-canonical declared parallel_checkpoint_path denies'; Prompt = 'Parallel mode: true. parallel_checkpoint_path: artifacts/orchestration/rogue-parallel-state.json. Execute docs/features/active/child-b-301.'; Fixture = @{}; Expect = 'deny'; Reason = 'parallel-orchestrator-state.json' }
        ) {
            $json = ConvertTo-DelegationToolInputJson -Prompt $Prompt

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -ParallelCheckpointRaw (ConvertTo-ParallelCheckpointJson @Fixture)

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expect
            if ($Reason) { $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ('*' + $Reason + '*') }
        }
    }

    Context 'deny-by-default is preserved, with no new permissive path' {
        It 'denies <Label>' -ForEach @(
            @{ Label = 'an unparseable payload'; Raw = '{not json' }
            @{ Label = 'a payload carrying no tool_input key'; Raw = '{"tool_name":"Agent","subagent_type":"orchestrator"}' }
        ) {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $Raw -CheckpointRaw '{}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
        }

        It 'denies an epic-mode delegation whose injected epic content is empty, with no filesystem read' {
            # The read seam is shadowed by a throwing definition in this case's own scope.
            # PowerShell resolves a call through the caller's dynamic scope chain, so had
            # the empty string fallen through to the seam this case would error rather than
            # pass. Binding suppresses the seam: ContainsKey, not a truthiness test.
            function Get-EpicCheckpointContent { throw 'the epic read seam was consulted' }
            $json = ConvertTo-DelegationToolInputJson -Prompt 'Epic mode: true. Execute docs/features/active/child-b-301.'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }
}
