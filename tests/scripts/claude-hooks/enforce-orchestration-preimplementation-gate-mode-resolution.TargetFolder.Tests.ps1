#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Target-folder resolution cases for the Claude preimplementation gate's -modes.ps1
    (issue #565, including the #621/#508 occurrence from epic #770).

.DESCRIPTION
    Drives Find-OrchestrationDelegationTargetFolder, the epic and parallel readiness
    predicates, and the epic decision leg through the issue #565 test matrix: the folder
    alone, nested research and evidence citations, upstream-dependency citation lines, two
    non-dependency folders, tokens that truncate to fewer than four segments together with
    the decision-D3 issue-number fallback, the #621/#508 regression fixture, and a simulated
    dot-source failure of the shared resolver.

    Checkpoint content is supplied as a literal (-EpicCheckpointRaw at decision level, a
    parsed object at predicate level), and the worktree-resolution seam is mocked, so no case
    reads orchestration state or writes a file. Prompts used to prove the nested-artifact
    cases carry no issue number, so the D3 fallback cannot mask a misselected folder.
#>

Describe 'enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565)' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1").Path
        Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }

        $script:TargetFeatures = '[{"feature_folder":"docs/features/active/child-a-300","issue_num":300,"depends_on":[],"merge_status":"merged"},' +
        '{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"depends_on":[300],"merge_status":"not_started"}]'
        $script:PairFeatures = '[{"feature_folder":"alpha-401","issue_num":401,"depends_on":[],"merge_status":"not_started"},' +
        '{"feature_folder":"bravo-with-a-much-longer-slug-402","issue_num":402,"depends_on":[],"merge_status":"not_started"}]'
        $script:F507 = '2026-08-22-push-down-root-folders-divergence-507'
        $script:F508 = '2026-08-22-blast-radius-config-has-no-merge-decorator-508'
        $script:F621 = '2026-09-29-push-down-destination-exclusion-manifest-621'
        $script:Features621 = '[{"feature_folder":"' + $script:F507 + '","issue_num":507,"depends_on":[],"merge_status":"merged"},' +
        '{"feature_folder":"' + $script:F508 + '","issue_num":508,"depends_on":[],"merge_status":"merged"},' +
        '{"feature_folder":"' + $script:F621 + '","issue_num":621,"depends_on":[507,508],"merge_status":"not_started"}]'
        # Issue #565 CR-1 fixtures: a terminal target cited with a non-terminal sibling (one fixture for epic features and parallel items).
        $script:CrossRecords = '[{"feature_folder":"docs/features/active/target-a-with-a-much-longer-slug-301","issue_num":301,"depends_on":[],"merge_status":"merged"},' +
        '{"feature_folder":"docs/features/active/b-302","issue_num":302,"depends_on":[],"merge_status":"not_started"}]'
        $script:CrossTail = 'Execute docs/features/active/target-a-with-a-much-longer-slug-301 with context from docs/features/active/b-302 now.'
        $script:SingleRecord = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"depends_on":[],"merge_status":"not_started"}]'

        function Invoke-ModesParallelDecision {
            param([string] $Prompt, [string] $ItemsJson)
            $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5
            $raw = ConvertTo-ModesParallelCheckpointJson -ItemsJson $ItemsJson
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -ParallelCheckpointRaw $raw).hookSpecificOutput
        }

        function ConvertTo-ModesEpicCheckpointJson {
            param([string] $FeaturesJson)
            return '{"route_id":"epic","epic_feature_folder":"x-family","epic_manifest_path":"docs/features/epics/x-family/epic.md",' +
            '"integration_branch":"epic/x-integration","features":' + $FeaturesJson + '}'
        }

        function ConvertTo-ModesParallelCheckpointJson {
            param([string] $ItemsJson)
            return '{"route_id":"parallel","parallel_slug":"demo","parallel_manifest_path":"docs/features/parallel/demo/parallel.md","items":' + $ItemsJson + '}'
        }

        function Get-UpstreamLine {
            # The .claude/skills/epic-orchestrate/SKILL.md upstream-context line shape.
            param([string] $Number, [string] $Dependency, [string] $Folder)
            return "Upstream context for ${Number}: depends on $Dependency (spec: docs/features/active/$Folder/spec.md; " +
            "plan: docs/features/active/$Folder/plan.2026-10-01T00-00.md; merged as PR #900, commit 0000000, into epic/x-integration)."
        }

        function Invoke-ModesEpicDecision {
            param([string] $Prompt, [string] $FeaturesJson)
            $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5
            $raw = ConvertTo-ModesEpicCheckpointJson -FeaturesJson $FeaturesJson
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -EpicCheckpointRaw $raw).hookSpecificOutput
        }

        function Get-ModesEpicFailure {
            param([string] $Prompt, [string] $FeaturesJson)
            $checkpoint = (ConvertTo-ModesEpicCheckpointJson -FeaturesJson $FeaturesJson) | ConvertFrom-Json
            return Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint `
                -TargetFolder (Find-OrchestrationDelegationTargetFolder -Prompt $Prompt) `
                -IssueNumber (Find-OrchestrationDelegationIssueNumber -Prompt $Prompt)
        }
    }

    Context 'nested-artifact citations resolve to the target folder' {
        It 'M1: allows the target folder cited alone at decision level' {
            (Invoke-ModesEpicDecision -Prompt 'Epic mode: true. Execute docs/features/active/child-b-301 now' -FeaturesJson $script:TargetFeatures).permissionDecision |
                Should -Be 'allow'
        }

        It 'M2a: allows the target folder cited together with a research artifact' {
            $prompt = 'Epic mode: true. Execute docs/features/active/child-b-301 and read docs/features/active/child-b-301/research/notes.md first.'
            (Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:TargetFeatures).permissionDecision | Should -Be 'allow'
        }

        It 'M2b: allows the target folder cited together with an evidence artifact' {
            $prompt = 'Epic mode: true. Execute docs/features/active/child-b-301 and read docs/features/active/child-b-301/evidence/baseline/run.md first.'
            (Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:TargetFeatures).permissionDecision | Should -Be 'allow'
        }

        It 'M3a: allows a research artifact cited alone' {
            $prompt = 'Epic mode: true. Read docs/features/active/child-b-301/research/notes.md first.'
            (Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:TargetFeatures).permissionDecision | Should -Be 'allow'
        }

        It 'M3b: allows an evidence artifact cited alone' {
            $prompt = 'Epic mode: true. Read docs/features/active/child-b-301/evidence/baseline/run.md first.'
            (Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:TargetFeatures).permissionDecision | Should -Be 'allow'
        }
    }

    Context 'upstream and sibling citations' {
        It 'M4e: prunes a cited epic dependency and reports no readiness failure' {
            $prompt = 'Epic mode: true. Execute docs/features/active/child-b-301/spec.md. ' + (Get-UpstreamLine -Number '301' -Dependency '300' -Folder 'child-a-300')
            Get-ModesEpicFailure -Prompt $prompt -FeaturesJson $script:TargetFeatures | Should -Be ''
        }

        It 'M4p: reports target-ambiguous for a parallel target cited with another item and no issue number' {
            $items = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"},' +
            '{"feature_folder":"docs/features/active/child-c-302","issue_num":302,"merge_status":"not_started"}]'
            $checkpoint = (ConvertTo-ModesParallelCheckpointJson -ItemsJson $items) | ConvertFrom-Json
            $prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301 with docs/features/active/child-c-302 now'
            $failure = Get-ParallelOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder (Find-OrchestrationDelegationTargetFolder -Prompt $prompt) -IssueNumber $null
            $failure | Should -Match '^target-ambiguous: '
            $failure | Should -Match 'child-b-301'
            $failure | Should -Match 'child-c-302'
        }

        It 'M4q: resolves a parallel target cited with another item through the declared issue number' {
            $items = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"},' +
            '{"feature_folder":"docs/features/active/child-c-302","issue_num":302,"merge_status":"not_started"}]'
            $checkpoint = (ConvertTo-ModesParallelCheckpointJson -ItemsJson $items) | ConvertFrom-Json
            $prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301 with docs/features/active/child-c-302 now'
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder (Find-OrchestrationDelegationTargetFolder -Prompt $prompt) -IssueNumber '301' |
                Should -Be ''
        }
    }

    Context 'two non-dependency folders are ambiguous at decision level' {
        It 'M5: denies with target-ambiguous naming both candidates' {
            $prompt = 'Epic mode: true. Execute docs/features/active/alpha-401 and docs/features/active/bravo-with-a-much-longer-slug-402/spec.md now'
            $decision = Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:PairFeatures
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PREIMPLEMENTATION_GATE_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'target-ambiguous'
            $decision.permissionDecisionReason | Should -Match 'alpha-401'
            $decision.permissionDecisionReason | Should -Match 'bravo-with-a-much-longer-slug-402'
        }

        It 'M5r: denies with target-ambiguous for the reversed order with the longer slug first' {
            $prompt = 'Epic mode: true. Execute docs/features/active/bravo-with-a-much-longer-slug-402/spec.md and docs/features/active/alpha-401 now'
            $decision = Invoke-ModesEpicDecision -Prompt $prompt -FeaturesJson $script:PairFeatures
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PREIMPLEMENTATION_GATE_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'target-ambiguous'
            $decision.permissionDecisionReason | Should -Match 'alpha-401'
            $decision.permissionDecisionReason | Should -Match 'bravo-with-a-much-longer-slug-402'
        }
    }

    Context 'tokens that truncate to fewer than four segments' {
        It 'M6a: falls back to the keyed issue number when the bare token yields no candidate' {
            Get-ModesEpicFailure -Prompt 'Epic mode: true. See docs/features/active/ for issue_num: 301.' -FeaturesJson $script:TargetFeatures | Should -Be ''
        }

        It 'M6b: reports target-record when the token yields no candidate and no issue number is cited' {
            Get-ModesEpicFailure -Prompt 'Epic mode: true. See docs/features/active/. for the work.' -FeaturesJson $script:TargetFeatures | Should -Be 'target-record'
        }
    }

    Context 'the #621/#508 regression fixture' {
        BeforeAll {
            $script:Prompt621 = "Epic mode: true. Execute docs/features/active/$script:F621/spec.md. " +
            (Get-UpstreamLine -Number '621' -Dependency '507' -Folder $script:F507) + ' ' +
            (Get-UpstreamLine -Number '621' -Dependency '508' -Folder $script:F508)
        }

        It 'M7: resolves feature 621 and does not fail the merge_status predicate' {
            Get-ModesEpicFailure -Prompt $script:Prompt621 -FeaturesJson $script:Features621 | Should -Be ''
        }

        It 'M7d: allows the 621 launch at decision level' {
            (Invoke-ModesEpicDecision -Prompt $script:Prompt621 -FeaturesJson $script:Features621).permissionDecision | Should -Be 'allow'
        }
    }

    Context 'decision-D3 issue-number fallback for an unmatched folder' {
        It 'M8: resolves the record by the keyed issue number when the folder record was renamed' {
            $features = '[{"feature_folder":"completed/child-b-301-renamed","issue_num":301,"merge_status":"not_started"}]'
            Get-ModesEpicFailure -Prompt 'Epic mode: true. issue_num: 301. Execute docs/features/active/child-b-301 now' -FeaturesJson $features | Should -Be ''
        }
    }

    Context 'shared resolver import failure' {
        It 'M9: returns no target folder and a feature-folder-resolution-import readiness failure' {
            # Arrange
            $prompt = 'Epic mode: true. Execute docs/features/active/child-b-301 now'
            $checkpoint = (ConvertTo-ModesEpicCheckpointJson -FeaturesJson $script:TargetFeatures) | ConvertFrom-Json
            $script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                # Act
                $folders = @(Find-OrchestrationDelegationTargetFolder -Prompt $prompt)
                $failure = Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint -TargetFolder 'child-b-301' -IssueNumber $null
            }
            finally {
                $script:OrchestrationFeatureFolderResolutionImportFailure = $null
            }

            # Assert
            $folders.Count | Should -Be 0
            $failure | Should -Be 'feature-folder-resolution-import'
        }
    }

    Context 'issue #565 CR-1: only the keyed issue number breaks a tie' {
        It 'M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited' {
            $decision = Invoke-ModesParallelDecision -Prompt ('Parallel mode: true. Coordinate with #302. ' + $script:CrossTail) -ItemsJson $script:CrossRecords
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PREIMPLEMENTATION_GATE_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'target-ambiguous'
            $decision.permissionDecisionReason | Should -Match 'target-a-with-a-much-longer-slug-301'
            $decision.permissionDecisionReason | Should -Match 'b-302'
        }

        It 'M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited' {
            $decision = Invoke-ModesEpicDecision -Prompt ('Epic mode: true. Coordinate with #302. ' + $script:CrossTail) -FeaturesJson $script:CrossRecords
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^PREIMPLEMENTATION_GATE_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'target-ambiguous'
            $decision.permissionDecisionReason | Should -Match 'target-a-with-a-much-longer-slug-301'
            $decision.permissionDecisionReason | Should -Match 'b-302'
        }

        It 'M11p: selects the terminal parallel target through the keyed issue number despite a bare #302 sibling reference' {
            $decision = Invoke-ModesParallelDecision -Prompt ('Parallel mode: true. issue_num: 301. Coordinate with #302. ' + $script:CrossTail) -ItemsJson $script:CrossRecords
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "predicate is 'merge_status'"
            $decision.permissionDecisionReason | Should -Not -Match 'target-ambiguous'
        }

        It 'M11e: selects the terminal epic target through the keyed issue number despite a bare #302 sibling reference' {
            $decision = Invoke-ModesEpicDecision -Prompt ('Epic mode: true. issue_num: 301. Coordinate with #302. ' + $script:CrossTail) -FeaturesJson $script:CrossRecords
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "predicate is 'merge_status'"
            $decision.permissionDecisionReason | Should -Not -Match 'target-ambiguous'
        }
    }

    Context 'issue #565 CR-1: keyed-only issue source and the D3 hash fallback' {
        It 'M12a: returns no keyed issue number when only a bare hash form is present' {
            Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. Coordinate with #302.' -KeyedOnly | Should -BeNullOrEmpty
        }

        It 'M12b: returns the keyed issue number and ignores a bare hash form' {
            Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. issue_num: 301. Coordinate with #302.' -KeyedOnly | Should -Be '301'
        }

        It 'M12c: keeps the bare hash form as the default issue-number source' {
            Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. Coordinate with #302.' | Should -Be '302'
        }

        It 'M8h: allows a zero-candidate delegation through the bare hash D3 fallback' {
            (Invoke-ModesEpicDecision -Prompt 'Epic mode: true. Deliver the fix for #301 in this wave.' -FeaturesJson $script:SingleRecord).permissionDecision |
                Should -Be 'allow'
        }

        It 'M8m: denies a zero-candidate delegation with no issue number as target-record' {
            $decision = Invoke-ModesEpicDecision -Prompt 'Epic mode: true. Deliver the fix in this wave.' -FeaturesJson $script:SingleRecord
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "predicate is 'target-record'"
        }
    }
}
