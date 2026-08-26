#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Companion test file for .claude/hooks/enforce-prd-feature-before-planner.ps1.

    The sibling file tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1
    has insufficient headroom against the 500-line file-size limit in
    .claude/rules/general-code-change.md to carry the cases added for issue #518,
    so the folder-resolution, deterministic-selection, decision-equivalence,
    preserved-behavior, indeterminate-marker, and block-message cases live here.
    The measured placement decision is recorded under the feature folder's
    evidence/other/ tree with the stem test-placement-decision.

    The same convention is used by
    tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1.
#>

Describe 'enforce-prd-feature-before-planner.ps1 folder resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . $script:UnderTest
    }

    Context 'folder resolution by four-segment truncation' {
        # Every matched docs/features/active/... token truncates to exactly four
        # path segments, so the depth at which an artifact is cited cannot change
        # which feature folder the gate believes is in scope.

        It 'resolves the same folder when the prompt cites the feature folder alone' {
            $prompt = 'Plan the work in docs/features/active/2026-08-23-equivalence-1 now.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-equivalence-1'
        }

        It 'resolves the same folder when the prompt cites a research artifact path' {
            $prompt = 'Feature docs/features/active/2026-08-23-equivalence-1 with research at ' +
            'docs/features/active/2026-08-23-equivalence-1/research/2026-08-23T23-40-findings.md'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-equivalence-1'
        }

        It 'resolves the same folder when the prompt cites an evidence artifact path' {
            $prompt = 'Feature docs/features/active/2026-08-23-equivalence-1 with baseline at ' +
            'docs/features/active/2026-08-23-equivalence-1/evidence/baseline/baseline-poshqc-test.md'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-equivalence-1'
        }

        It 'resolves the folder from a nested artifact path with no folder citation' {
            $prompt = 'Read docs/features/active/2026-08-23-equivalence-1/research/2026-08-23T23-40-findings.md first.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-equivalence-1'
        }

        It 'rejects a token that truncates to fewer than four segments' {
            # A degenerate token such as docs/features/active/. carries no feature
            # folder segment once the no-op '.' component is discarded, so it must
            # be rejected rather than returned as a folder.
            $prompt = 'A degenerate token docs/features/active/. appears in this prompt.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt | Should -BeNullOrEmpty
        }

        It 'yields one distinct candidate when one folder is cited at three depths' {
            # One distinct candidate is used directly, so the checkpoint
            # disambiguator is never consulted. Zero invocations of the checkpoint
            # seam is the observable proof that deduplication collapsed the three
            # citations to a single candidate.
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-08-23-other-9' }
            $prompt = 'Folder docs/features/active/2026-08-23-dedupe-1, research ' +
            'docs/features/active/2026-08-23-dedupe-1/research/notes.md, and evidence ' +
            'docs/features/active/2026-08-23-dedupe-1/evidence/baseline/capture.md.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-dedupe-1'
            Should -Invoke -CommandName Get-PrdFeatureCheckpointFolder -Times 0 -Exactly
        }
    }

    Context 'deterministic selection among two feature folders' {
        # In every case below the expected winner carries the shorter slug of the
        # two candidates, so a length-ordered selection rule cannot agree with the
        # specified rule by coincidence. The first case additionally places the
        # checkpoint folder later in the prompt than the other candidate, so
        # checkpoint preference is distinguished from earliest occurrence.

        It 'prefers the checkpoint folder when it occurs later in the prompt' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-08-23-second-2' }
            $prompt = 'Cross-reference docs/features/active/2026-08-23-first-long-candidate-1 and then ' +
            'work in docs/features/active/2026-08-23-second-2 today.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-second-2'
        }

        It 'uses the earliest candidate when the checkpoint folder is absent' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            $prompt = 'Primary docs/features/active/2026-08-23-alpha-1 and secondary ' +
            'docs/features/active/2026-08-23-beta-long-candidate-2 later.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-alpha-1'
        }

        It 'uses the earliest candidate when the checkpoint folder is not a candidate' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-08-23-unrelated-9' }
            $prompt = 'Primary docs/features/active/2026-08-23-alpha-1 and secondary ' +
            'docs/features/active/2026-08-23-beta-long-candidate-2 later.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-08-23-alpha-1'
        }
    }

    Context 'decision equivalence and the reproduction differential' {
        # The existence mocks below key on the EXACT expected folder path rather
        # than on a file-name suffix, so a folder misresolved to a nested
        # subdirectory reports the prerequisite as missing and the decision flips.

        It 'returns the same decision for all four prompt forms' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return $Path -eq 'docs/features/active/2026-08-23-equivalence-2/spec.md'
            }

            $folder = 'docs/features/active/2026-08-23-equivalence-2'
            $prompts = @(
                "Plan the work in $folder now."
                "Feature $folder with research at $folder/research/2026-08-23T23-40-findings.md"
                "Feature $folder with baseline at $folder/evidence/baseline/baseline-poshqc-test.md"
                "Read $folder/research/2026-08-23T23-40-findings.md first."
            )

            $decisions = foreach ($p in $prompts) {
                $json = (@{
                        tool_name  = 'Agent'
                        tool_input = @{ subagent_type = 'atomic-planner'; prompt = $p }
                    } | ConvertTo-Json -Compress -Depth 5)
                (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput
            }

            @($decisions).Count | Should -Be 4
            foreach ($d in $decisions) {
                $d.permissionDecision | Should -Be 'allow'
                $d.permissionDecision | Should -Be $decisions[0].permissionDecision
                $d.permissionDecisionReason | Should -Be $decisions[0].permissionDecisionReason
            }
        }

        It 'returns the same decision for folder-relative and repo-relative research paths' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return $Path -eq 'docs/features/active/2026-08-23-differential-1/spec.md'
            }

            $folder = 'docs/features/active/2026-08-23-differential-1'
            $folderRelative = "Feature $folder. Research at research/2026-08-23T23-40-findings.md."
            $repoRelative = "Feature $folder. Research at $folder/research/2026-08-23T23-40-findings.md."

            $decisions = foreach ($p in @($folderRelative, $repoRelative)) {
                $json = (@{
                        tool_name  = 'Agent'
                        tool_input = @{ subagent_type = 'atomic-planner'; prompt = $p }
                    } | ConvertTo-Json -Compress -Depth 5)
                (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput
            }

            $decisions[1].permissionDecision | Should -Be $decisions[0].permissionDecision
            $decisions[1].permissionDecisionReason | Should -Be $decisions[0].permissionDecisionReason
            $decisions[0].permissionDecision | Should -Be 'allow'
        }

        It 'allows full-bug with spec present and user-story absent citing a nested research artifact' {
            # The reproduction from issue #518: a correctly prepared full-bug
            # folder whose user-story.md is legitimately absent, delegated with a
            # prompt whose only citation is a nested research artifact.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return $Path -eq 'docs/features/active/2026-08-23-full-bug-nested-1/spec.md'
            }

            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{
                        subagent_type = 'atomic-planner'
                        prompt        = 'Research findings: docs/features/active/2026-08-23-full-bug-nested-1/research/2026-08-23T23-40-findings.md'
                    }
                } | ConvertTo-Json -Compress -Depth 5)

            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }
    }

    Context 'preserved gate behavior' {
        # A resolution fix that also relaxed the prerequisite check would remove
        # the gate's purpose while appearing to pass. These cases pin the gate's
        # denials so that cannot happen silently.

        It 'denies full-feature when spec.md is missing' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-preserved-ff-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
        }

        It 'denies full-bug when spec.md is missing' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-preserved-fb-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'user-story\.md'
        }

        It 'denies full-feature when user-story.md is missing and names it' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-preserved-ff-2' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }

        It 'allows minor-audit when neither prerequisite file is present' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: minor-audit`n## Acceptance Criteria" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-preserved-ma-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'normalizes the legacy full marker to the full-feature prerequisite set' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-preserved-legacy-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'work mode: full-feature'
        }
    }

    Context 'indeterminate work-mode marker' {
        # When the mode is unknown no prerequisite set is knowable, so the gate
        # denies with a distinct reason naming marker repair as the remedy and
        # never runs the required-file probe. It still DENIES, so this is not a
        # relaxation of the fail-closed contract.

        It 'denies with the indeterminate-marker reason when the marker line is absent' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "## Overview`nNo marker line here." }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-indeterminate-absent' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }

        It 'denies with the indeterminate-marker reason when issue.md is unreadable' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { $null }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-indeterminate-unreadable' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }

        It 'denies with the indeterminate-marker reason when the marker value is unrecognized' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: sort-of-audit`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-indeterminate-unrecognized' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be determined'
        }

        It 'names the resolved folder and the issue.md path in the indeterminate reason' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "## Overview`nNo marker line here." }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{
                        subagent_type = 'atomic-planner'
                        prompt        = 'Read docs/features/active/2026-08-23-indeterminate-named/research/notes.md first.'
                    }
                } | ConvertTo-Json -Compress -Depth 5)
            $reason = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike '*docs/features/active/2026-08-23-indeterminate-named*'
            $reason | Should -BeLike '*docs/features/active/2026-08-23-indeterminate-named/issue.md*'
            $reason | Should -BeLike '*Work Mode:*'
        }

        It 'omits spec.md and user-story.md from the indeterminate reason' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "## Overview`nNo marker line here." }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-indeterminate-omits' }
                } | ConvertTo-Json -Compress -Depth 5)
            $reason = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecisionReason
            $reason | Should -Not -Match 'spec\.md'
            $reason | Should -Not -Match 'user-story\.md'
            $reason | Should -Not -Match 'Missing:'
        }

        It 'does not invoke the file-existence probe in the indeterminate branch' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "## Overview`nNo marker line here." }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-indeterminate-noprobe' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision |
                Should -Be 'deny'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
        }
    }

    Context 'block message' {
        It 'names the resolved folder ahead of the prd-feature remedy phrase' {
            # A reader who sees a wrong folder in the headline diagnoses a path
            # problem immediately instead of re-running a completed step. The
            # ordinal comparison is deliberate: PRD_FEATURE_BLOCKED uses
            # underscores, so it never matches the hyphenated remedy phrase.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-message-order-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $reason = [string] (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecisionReason

            $folderIndex = $reason.IndexOf('docs/features/active/2026-08-23-message-order-1', [System.StringComparison]::Ordinal)
            $remedyIndex = $reason.IndexOf('prd-feature', [System.StringComparison]::Ordinal)

            $folderIndex | Should -BeGreaterOrEqual 0
            $remedyIndex | Should -BeGreaterOrEqual 0
            $folderIndex | Should -BeLessThan $remedyIndex
        }

        It 'retains the PRD_FEATURE_BLOCKED prefix on every deny reason' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n## Overview" }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }

            $missingPrerequisite = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-08-23-prefix-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $noFolder = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'plan something generic' }
                } | ConvertTo-Json -Compress -Depth 5)
            $flatShape = (@{ subagent_type = 'atomic-planner'; prompt = 'irrelevant' } | ConvertTo-Json -Compress)

            foreach ($payload in @($missingPrerequisite, $noFolder, $flatShape, '', '{not-json')) {
                $output = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload).hookSpecificOutput
                $output.permissionDecision | Should -Be 'deny'
                $output.permissionDecisionReason | Should -BeLike 'PRD_FEATURE_BLOCKED:*'
            }
        }
    }
}
