#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-parallel-cohort-barrier.ps1 PreToolUse hook
    (Layer 1 deterrent).

.DESCRIPTION
    Every checkpoint fixture is injected through the mocked read seam
    Get-ParallelCohortBarrierCheckpointContent. No test reads the real
    artifacts/orchestration/parallel-orchestrator-state.json and no test writes a temporary
    file, so the suite is deterministic regardless of live orchestration state. The
    canonical fixture records two current-generation cohorts and one conflict edge: item
    101 sits in cohort 0, item 102 sits in cohort 1, and the edge {a:101, b:102} makes 101
    a strictly-prior-cohort conflicting neighbor of 102.
#>

Describe 'enforce-parallel-cohort-barrier.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
        . $script:UnderTest
    }

    Context 'allow (no-op) when the call is out of scope' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-orchestrator subagent delegation' {
            $json = '{"subagent_type":"parallel-planner","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker' {
            $json = '{"subagent_type":"orchestrator","prompt":"Canonical issue number for this item is 102. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an orchestrator delegation with an empty prompt' {
            $json = '{"subagent_type":"orchestrator","prompt":""}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-ParallelCohortBarrierDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'allow when every conflicting prior-cohort neighbor is merged or worktree_removed' {
        It 'allows when the conflicting prior-cohort neighbor has merge_status merged' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the conflicting prior-cohort neighbor has merge_status worktree_removed' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"worktree_removed"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a cohort-0 target whose only conflicting neighbor sits in a later cohort' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"not_started"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-a-101"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a target that has no conflict edges at all' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"pr_open"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when a same-cohort conflicting neighbor is not terminal (not a Layer 1 concern)' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"pr_open"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101,102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'ignores a superseded-generation cohort row when projecting the current coloring' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":9,"generation":1,"item_keys":[102]},' +
                '{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],' +
                '"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny PARALLEL_COHORT_BARRIER_BLOCKED when a conflicting prior-cohort neighbor is not terminal' {
        It 'denies when the conflicting prior-cohort neighbor has merge_status pr_open' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"pr_open"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflicting prior-cohort neighbor has merge_status ci_green' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"ci_green"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflicting prior-cohort neighbor has merge_status not_started' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"not_started"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflicting prior-cohort neighbor has merge_status blocked_drift' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"blocked_drift"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflicting prior-cohort neighbor record has no merge_status key' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflicting prior-cohort neighbor has no items[] record' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the conflict edge names the target as endpoint a' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"pr_open"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],' +
                '"conflict_edges":[{"a":102,"b":101,"reason":"module_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }
    }

    Context 'deny fail-closed on an unusable checkpoint or an unresolvable target' {
        It 'denies when the parallel checkpoint file is absent' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { $null }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the parallel checkpoint content is malformed JSON' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { '{ broken json' }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the prompt carries no feature-folder token' {
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. no path token here"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when no items[] record matches the resolved feature folder' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]}],"conflict_edges":[]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the target has no current-generation cohort assignment' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":1,"item_keys":[102]}],"conflict_edges":[]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'denies when the target items[] record carries no issue_num' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[102]}],"conflict_edges":[]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }
    }

    Context 'read seam binding (the mocked seam value determines the decision)' {
        It 'calls the read seam exactly once and allows when the seam reports a merged neighbor' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-ParallelCohortBarrierCheckpointContent -Times 1 -Exactly
        }

        It 'calls the read seam exactly once and denies for the identical payload when the seam reports ci_green' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith {
                '{"recolor_generation":2,"items":[' +
                '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"ci_green"},' +
                '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
                '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke -CommandName Get-ParallelCohortBarrierCheckpointContent -Times 1 -Exactly
        }

        It 'does not call the read seam when the call is out of scope' {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { $null }
            $json = '{"subagent_type":"atomic-planner","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $null = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $json
            Should -Invoke -CommandName Get-ParallelCohortBarrierCheckpointContent -Times 0 -Exactly
        }
    }

    Context 'Get-ParallelCohortBarrierFolderBasename helper' {
        It 'returns $null for an empty value' {
            Get-ParallelCohortBarrierFolderBasename -FolderPath '' | Should -BeNullOrEmpty
        }

        It 'reduces a full docs path to its basename' {
            Get-ParallelCohortBarrierFolderBasename -FolderPath 'docs/features/active/item-b-102' |
                Should -Be 'item-b-102'
        }

        It 'resolves a .md-suffixed value to its parent directory basename' {
            Get-ParallelCohortBarrierFolderBasename -FolderPath 'docs\features\active\item-b-102\spec.md' |
                Should -Be 'item-b-102'
        }
    }

    Context 'Find-ParallelCohortBarrierFeatureFolderFromPrompt helper' {
        It 'returns $null for an empty prompt' {
            Find-ParallelCohortBarrierFeatureFolderFromPrompt -Prompt '' | Should -BeNullOrEmpty
        }

        It 'resolves a bare docs/features/active token to its basename' {
            Find-ParallelCohortBarrierFeatureFolderFromPrompt -Prompt 'target docs/features/active/item-b-102 now' |
                Should -Be 'item-b-102'
        }

        It 'returns $null when no path token is present' {
            Find-ParallelCohortBarrierFeatureFolderFromPrompt -Prompt 'no path token here' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-ParallelCohortBarrierItemRecord helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-ParallelCohortBarrierItemRecord -Checkpoint $null -FeatureFolder 'a' | Should -BeNullOrEmpty
        }

        It 'returns $null when the items key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-ParallelCohortBarrierItemRecord -Checkpoint $checkpoint -FeatureFolder 'a' | Should -BeNullOrEmpty
        }

        It 'skips item records that carry no feature_folder' {
            $checkpoint = '{"items":[{"issue_num":101}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierItemRecord -Checkpoint $checkpoint -FeatureFolder 'a' | Should -BeNullOrEmpty
        }

        It 'matches a checkpoint that records a bare basename feature_folder' {
            $checkpoint = '{"items":[{"issue_num":102,"feature_folder":"item-b-102"}]}' | ConvertFrom-Json
            $record = Find-ParallelCohortBarrierItemRecord -Checkpoint $checkpoint -FeatureFolder 'item-b-102'
            $record.issue_num | Should -Be 102
        }
    }

    Context 'Find-ParallelCohortBarrierItemByKey helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-ParallelCohortBarrierItemByKey -Checkpoint $null -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'returns $null when the items key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-ParallelCohortBarrierItemByKey -Checkpoint $checkpoint -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'skips item records that carry no issue_num' {
            $checkpoint = '{"items":[{"feature_folder":"item-a-101"}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierItemByKey -Checkpoint $checkpoint -IssueKey '101' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-ParallelCohortBarrierCohortIndex helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-ParallelCohortBarrierCohortIndex -Checkpoint $null -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'returns $null when recolor_generation is absent' {
            $checkpoint = '{"cohorts":[{"index":0,"generation":0,"item_keys":[101]}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierCohortIndex -Checkpoint $checkpoint -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'skips cohort rows that are missing a required key' {
            $checkpoint = '{"recolor_generation":0,"cohorts":[{"index":0,"generation":0}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierCohortIndex -Checkpoint $checkpoint -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'skips cohort rows whose index is not an integer' {
            $checkpoint = '{"recolor_generation":0,"cohorts":[{"index":"x","generation":0,"item_keys":[101]}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierCohortIndex -Checkpoint $checkpoint -IssueKey '101' | Should -BeNullOrEmpty
        }

        It 'returns cohort index 0 for a current-generation match' {
            $checkpoint = '{"recolor_generation":0,"cohorts":[{"index":0,"generation":0,"item_keys":[101]}]}' | ConvertFrom-Json
            Find-ParallelCohortBarrierCohortIndex -Checkpoint $checkpoint -IssueKey '101' | Should -Be 0
        }
    }

    Context 'Get-ParallelCohortBarrierConflictNeighborList helper' {
        It 'returns an empty list when Checkpoint is $null' {
            @(Get-ParallelCohortBarrierConflictNeighborList -Checkpoint $null -IssueKey '101').Count | Should -Be 0
        }

        It 'returns an empty list when conflict_edges is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            @(Get-ParallelCohortBarrierConflictNeighborList -Checkpoint $checkpoint -IssueKey '101').Count | Should -Be 0
        }

        It 'skips edges that are missing an endpoint' {
            $checkpoint = '{"conflict_edges":[{"a":101}]}' | ConvertFrom-Json
            @(Get-ParallelCohortBarrierConflictNeighborList -Checkpoint $checkpoint -IssueKey '101').Count | Should -Be 0
        }

        It 'returns the opposite endpoint regardless of which side matches' {
            $checkpoint = '{"conflict_edges":[{"a":101,"b":102},{"a":100,"b":101}]}' | ConvertFrom-Json
            $neighborList = @(Get-ParallelCohortBarrierConflictNeighborList -Checkpoint $checkpoint -IssueKey '101')
            $neighborList | Should -Be @('102', '100')
        }
    }

    Context 'Test-ParallelCohortBarrierClear helper' {
        It 'returns $false when Checkpoint is $null' {
            Test-ParallelCohortBarrierClear -Checkpoint $null -ItemRecord $null | Should -BeFalse
        }

        It 'returns $false when ItemRecord is $null' {
            $checkpoint = '{"items":[]}' | ConvertFrom-Json
            Test-ParallelCohortBarrierClear -Checkpoint $checkpoint -ItemRecord $null | Should -BeFalse
        }

        It 'returns $false when the item record carries no issue_num' {
            $checkpoint = '{"recolor_generation":0,"items":[],"cohorts":[],"conflict_edges":[]}' | ConvertFrom-Json
            $item = '{"feature_folder":"item-b-102"}' | ConvertFrom-Json
            Test-ParallelCohortBarrierClear -Checkpoint $checkpoint -ItemRecord $item | Should -BeFalse
        }
    }

    Context 'real Test-Path read seam' {
        It 'Get-ParallelCohortBarrierCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelCohortBarrierCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-ParallelCohortBarrierCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"items":[]}' } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelCohortBarrierCheckpointContent | Should -Be '{"items":[]}'
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
