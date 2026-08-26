#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-prd-feature-before-planner.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PRD_FEATURE_BLOCKED'
        }

        It 'allows when subagent_type is not atomic-planner' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'something-else'; prompt = 'docs/features/active/foo' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when subagent_type is missing from a well-formed tool_input' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ prompt = 'irrelevant' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = (@{ subagent_type = 'atomic-planner'; prompt = 'irrelevant' } | ConvertTo-Json -Compress)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'atomic-planner delegation' {
        # Every case in this context supplies the work-mode marker its assertions
        # were written against. Without it the folder's issue.md is unreadable on
        # disk, the work mode is indeterminate, and the decision is taken by the
        # indeterminate-marker path rather than by the prerequisite probe these
        # cases exercise. full-feature is the mode whose prerequisite set is the
        # spec.md/user-story.md pair the cases assert against.
        It 'allows when both spec.md and user-story.md exist in the target folder (prompt path)' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1 for details.' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks when spec.md is missing' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-05-10-foo-1/' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'prd-feature'
        }

        It 'blocks when user-story.md is missing' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-05-10-foo-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }

        It 'blocks when no feature folder is found in prompt and no checkpoint exists' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'plan something generic' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature folder'
        }

        It 'falls back to orchestrator-state.json when prompt has no folder reference' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-05-10-bar-2' }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'continue planning' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'prefers the prompt-derived folder over the checkpoint folder' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            $script:capturedPaths = @()
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                $script:capturedPaths += $Path
                return $true
            }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/checkpoint-folder' }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'work in docs/features/active/prompt-folder now' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            ($script:capturedPaths -join '|') | Should -Match 'prompt-folder'
            ($script:capturedPaths -join '|') | Should -Not -Match 'checkpoint-folder'
        }

        It 'treats a path ending in .md as a file and uses its parent directory' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            $script:capturedPaths = @()
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                $script:capturedPaths += $Path
                return $true
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1/spec.md for the spec.' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            # Parent directory should be checked, not the .md path itself
            # Parent directory derivation: the spec.md leaf in the prompt should be stripped,
            # and the sibling spec.md / user-story.md should be probed under the parent folder.
            ($script:capturedPaths -join '|') | Should -Match '2026-05-10-foo-1/spec\.md'
            ($script:capturedPaths -join '|') | Should -Match '2026-05-10-foo-1/user-story\.md'
        }

        It 'accepts backslash separators inside the prompt path' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs\features\active\2026-05-10-foo-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Entrypoint transport' {
        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'emits a block decision JSON when prerequisites are missing (AC-7)' {
            $payload = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/__nonexistent_feature_for_test__' }
                } | ConvertTo-Json -Compress -Depth 5)

            $output = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload |
                ConvertTo-Json -Compress -Depth 5

            $output | Should -Match '"permissionDecision"\s*:\s*"deny"'
            $output | Should -Match 'PRD_FEATURE_BLOCKED'
        }

        It 'real Test-Path wrapper returns $false for a nonexistent path' {
            (Get-PrdFeatureFileExistence -Path 'C:/__nonexistent_path_for_test__.md') | Should -BeFalse
        }

        It 'Get-PrdFeatureCheckpointFolder returns $null when checkpoint is absent' {
            (Get-PrdFeatureCheckpointFolder -CheckpointPath 'C:/__nonexistent_checkpoint_for_test__.json') | Should -BeNullOrEmpty
        }
    }

    Context 'Find-PrdFeatureFolderFromPrompt' {
        It 'returns $null for empty prompt' {
            Find-PrdFeatureFolderFromPrompt -Prompt '' | Should -BeNullOrEmpty
        }
        It 'returns $null when no docs/features/active path is present' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'just text here' | Should -BeNullOrEmpty
        }
        It 'returns the folder when one is present' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'in docs/features/active/abc-1 we have' | Should -Be 'docs/features/active/abc-1'
        }
        It 'strips .md suffix to a folder parent' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'see docs/features/active/abc-1/spec.md' | Should -Be 'docs/features/active/abc-1'
        }
    }

    Context 'Resolve-PrdFeatureWorkMode' {
        It 'returns full-feature for an exact full-feature marker' {
            Resolve-PrdFeatureWorkMode -IssueContent "- Work Mode: full-feature`n## Overview" | Should -Be 'full-feature'
        }

        It 'returns full-bug for an exact full-bug marker' {
            Resolve-PrdFeatureWorkMode -IssueContent "- Work Mode: full-bug`n## Overview" | Should -Be 'full-bug'
        }

        It 'returns minor-audit for an exact minor-audit marker' {
            Resolve-PrdFeatureWorkMode -IssueContent "- Work Mode: minor-audit`n## Overview" | Should -Be 'minor-audit'
        }

        It 'normalizes the legacy full marker to full-feature' {
            Resolve-PrdFeatureWorkMode -IssueContent "- Work Mode: full`n## Overview" | Should -Be 'full-feature'
        }

        It 'is case-insensitive on the marker label' {
            Resolve-PrdFeatureWorkMode -IssueContent "- work mode: minor-audit`n## Overview" | Should -Be 'minor-audit'
        }

        It 'returns $null when no marker line is present' {
            Resolve-PrdFeatureWorkMode -IssueContent "## Overview`nSome content with no marker." | Should -BeNullOrEmpty
        }

        It 'returns $null for an unrecognized marker value' {
            Resolve-PrdFeatureWorkMode -IssueContent "- Work Mode: bogus`n## Overview" | Should -BeNullOrEmpty
        }

        It 'returns $null for empty content' {
            Resolve-PrdFeatureWorkMode -IssueContent '' | Should -BeNullOrEmpty
        }

        It 'returns $null for $null content' {
            Resolve-PrdFeatureWorkMode -IssueContent $null | Should -BeNullOrEmpty
        }
    }

    Context 'Get-PrdFeatureRequiredFile' {
        It 'requires spec.md and user-story.md for full-feature' {
            (Get-PrdFeatureRequiredFile -WorkMode 'full-feature') | Should -Be @('spec.md', 'user-story.md')
        }

        It 'requires spec.md only for full-bug' {
            (Get-PrdFeatureRequiredFile -WorkMode 'full-bug') | Should -Be @('spec.md')
        }

        It 'requires neither file for minor-audit' {
            @(Get-PrdFeatureRequiredFile -WorkMode 'minor-audit').Count | Should -Be 0
        }

        # The default arm no longer returns user-story.md. An indeterminate mode
        # is denied by its own decision path without a required-file probe, so no
        # reachable path can demand a document the lifecycle contract requires to
        # be absent for full-bug and minor-audit work.
        It 'returns spec.md alone for a $null mode so no reachable path can demand user-story.md' {
            (Get-PrdFeatureRequiredFile -WorkMode $null) | Should -Be @('spec.md')
        }

        It 'returns spec.md alone for an unrecognized mode string so no reachable path can demand user-story.md' {
            (Get-PrdFeatureRequiredFile -WorkMode 'bogus') | Should -Be @('spec.md')
        }
    }

    Context 'Get-PrdFeatureIssueContent' {
        It 'returns $null when issue.md does not exist' {
            Get-PrdFeatureIssueContent -FeatureFolder 'C:/__nonexistent_feature_folder_for_test__' | Should -BeNullOrEmpty
        }

        It 'returns $null when issue.md exists but Get-Content throws (unreadable)' {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { throw 'simulated io error' }
            Get-PrdFeatureIssueContent -FeatureFolder 'docs/features/active/unreadable-case' | Should -BeNullOrEmpty
        }
    }

    Context 'work-mode aware prerequisite resolution' {
        It 'allows full-feature mode when spec.md and user-story.md are both present' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-full-feature-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks full-feature mode when spec.md is missing, naming the work mode' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-full-feature-2' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'work mode: full-feature'
        }

        It 'allows full-bug mode when only spec.md is present (user-story.md absent)' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return $Path -match '/spec\.md$'
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-full-bug-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks full-bug mode when spec.md is missing and does not demand user-story.md' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-full-bug-2' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'user-story\.md'
        }

        It 'allows minor-audit mode even when spec.md and user-story.md are both absent' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: minor-audit`n## Acceptance Criteria" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-minor-audit-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'treats the legacy full marker as the full-feature requirement set' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-legacy-full-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }
    }

    Context 'fail-closed prerequisite resolution (AC: unable to determine work mode)' {
        # These four scenarios (marker absent, unreadable issue.md, unrecognized
        # marker value, missing issue.md) all collapse to an undeterminable work
        # mode. An undeterminable mode denies on its own distinct decision path,
        # which names no prerequisite document and runs no required-file probe,
        # because no prerequisite set is knowable when the mode is unknown. The
        # decision is still deny, so the fail-open defect class issue #501
        # corrected (a PreToolUse gate that appears to enforce a prerequisite
        # but always allows) remains locked.
        It 'fails closed when the work-mode marker line is absent from issue.md' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "## Overview`nNo marker line here." }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-marker-absent' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
            # The reason is the distinct indeterminate-marker reason: it names the
            # resolved folder and the issue.md path it probed, and it names neither
            # prerequisite document, because no prerequisite set is knowable when
            # the mode is unknown.
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -BeLike '*docs/features/active/2026-08-22-marker-absent/issue.md*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'user-story\.md'
        }

        It 'fails closed when issue.md exists but is unreadable' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { throw 'simulated io error' }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-unreadable' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }

        It 'fails closed when the marker value is unrecognized' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: sort-of-audit`n## Overview" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-22-marker-unrecognized' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }

        It 'fails closed when issue.md itself does not exist' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/__nonexistent_issue_md_for_test__' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }
    }
}
