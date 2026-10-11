#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-feature-folder-order.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-feature-folder-order.ps1").Path
        . $script:UnderTest
        Mock Get-FeatureFolderIssueContent { $null }
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'FEATURE_FOLDER_ORDER_BLOCKED'
        }

        It 'allows when file_path is missing' {
            $json = '{"tool_input":{"other":"value"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when file_path is not a plan.md path' {
            $json = '{"tool_input":{"file_path":"docs/features/active/foo/issue.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows for plan.md outside docs/features' {
            $json = '{"tool_input":{"file_path":"some/other/dir/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"file_path":"docs/features/active/foo/issue.md"}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'plan.md in a feature folder' {
        It 'allows when all three sibling files exist' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $true }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when issue.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/issue\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue\.md'
        }

        It 'denies when spec.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
        }

        It 'denies when user-story.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }

        It 'deny reason names all missing files when multiple are absent' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'prd-feature'
        }

        It 'serializes the deny decision into the PreToolUse hookSpecificOutput envelope' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'normalizes backslashes in the file_path' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs\\features\\active\\2026-01-01-foo-1\\plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'Get-FeatureFolderMissingFile defaults to the full-feature prerequisite set when no required set is supplied' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $missing = @(Get-FeatureFolderMissingFile -PlanFilePath 'docs/features/active/2026-01-01-foo-1/plan.2026-08-23T23-22.md')
            ($missing -join '|') | Should -BeExactly 'issue.md|spec.md|user-story.md'
            Should -Invoke Get-FeatureFolderFileExistence -Times 1 -Exactly -ParameterFilter { $Path -eq 'docs/features/active/2026-01-01-foo-1/user-story.md' }
        }

        It 'handles archive feature folders too' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/archive/2025-12-01-old-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'Entrypoint (exit code seam, no child process)' {
        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ReadPayload $emptyReader)
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $output.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 and emits an allow decision JSON for an out-of-scope path' {
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"src/hello.ts","content":"x"}}'
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ToolInputRaw $nested)
            $emitted[-1] | Should -Be 0
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $output.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'returns exit code 0 and emits a deny decision JSON when prerequisites are missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            # Point at a non-existent feature folder so Test-Path returns false.
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"docs/features/active/__nonexistent_feature_for_test__/plan.md","content":"x"}}'
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ToolInputRaw $nested)
            $emitted[-1] | Should -Be 0
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $output.hookSpecificOutput.permissionDecisionReason | Should -Match 'FEATURE_FOLDER_ORDER_BLOCKED'
        }

        It 'real Test-Path wrapper returns $false for a nonexistent path' {
            (Get-FeatureFolderFileExistence -Path 'C:/__nonexistent_path_for_test__.md') | Should -BeFalse
        }
    }

    Context 'Test-IsFeaturePlanPath' {
        It 'recognizes a canonical active plan.md path' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/plan.md') | Should -BeTrue
        }
        It 'recognizes a canonical archive plan.md path' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/archive/foo/plan.md') | Should -BeTrue
        }
        It 'rejects non-plan files' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/issue.md') | Should -BeFalse
        }
        It 'rejects paths outside docs/features' {
            (Test-IsFeaturePlanPath -NormalizedPath 'other/plan.md') | Should -BeFalse
        }
    }

    Context 'issue #568 plan-path matching' {
        It 'F1: recognizes a timestamped plan file in an active feature folder' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/plan.2026-08-23T23-22.md') | Should -BeTrue
        }

        It 'F2: recognizes a timestamped plan file in an archive feature folder' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/archive/foo/plan.2026-08-23T23-22.md') | Should -BeTrue
        }

        It 'F3: denies a timestamped plan write when the prerequisite documents are missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/active/foo/plan.2026-08-23T23-22.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^FEATURE_FOLDER_ORDER_BLOCKED:'
        }

        It 'F4: rejects a plan file whose timestamp carries no time component' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/plan.2026-08-23.md') | Should -BeFalse
        }

        It 'F5: rejects a planning document whose name only starts with plan' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/planning.md') | Should -BeFalse
        }

        It 'F6: rejects a plan file nested below the feature folder' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/research/plan.md') | Should -BeFalse
        }
    }

    Context 'issue #568 work-mode prerequisites' {
        BeforeAll {
            # The issue-content seam returns $script:IssueContent, and the existence seam
            # reports a sibling present when its leaf name is in $script:PresentFiles.
            Mock Get-FeatureFolderIssueContent { $script:IssueContent }
            Mock Get-FeatureFolderFileExistence {
                param([string] $Path)
                return ($script:PresentFiles -contains (($Path -split '/')[-1]))
            }

            function Invoke-PlanWrite {
                param([string] $PlanPath = 'docs/features/active/foo/plan.2026-08-23T23-22.md')
                $json = '{"tool_input":{"file_path":"' + $PlanPath + '"}}'
                return (Invoke-FeatureFolderOrderDecision -ToolInputRaw $json).hookSpecificOutput
            }
        }

        It 'F7: allows a minor-audit plan write when only issue.md exists' {
            $script:IssueContent = "# Issue`n- Work Mode: minor-audit`n"
            $script:PresentFiles = @('issue.md')
            (Invoke-PlanWrite).permissionDecision | Should -Be 'allow'
        }

        It 'F8: allows a full-bug plan write when issue.md and spec.md exist' {
            $script:IssueContent = "# Issue`n- Work Mode: full-bug`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            (Invoke-PlanWrite).permissionDecision | Should -Be 'allow'
        }

        It 'F9: allows a full-feature plan write when all three documents exist' {
            $script:IssueContent = "# Issue`n- Work Mode: full-feature`n"
            $script:PresentFiles = @('issue.md', 'spec.md', 'user-story.md')
            (Invoke-PlanWrite).permissionDecision | Should -Be 'allow'
        }

        It 'F10: denies a legacy full plan write without user-story.md as full-feature' {
            $script:IssueContent = "# Issue`n- Work Mode: full`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'user-story\.md'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F11: enforces the full-feature set when the marker is missing' {
            $script:IssueContent = "# Issue`nNo work-mode marker here.`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'user-story\.md'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F12: enforces the full-feature set when issue.md is empty' {
            $script:IssueContent = ''
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F13: enforces the full-feature set when the marker is malformed' {
            $script:IssueContent = "# Issue`n- Work Mode full-bug`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F14: enforces the full-feature set when the marker value is unrecognized' {
            $script:IssueContent = "# Issue`n- Work Mode: quick`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F15: enforces the full-feature set when issue.md cannot be read' {
            $script:IssueContent = $null
            $script:PresentFiles = @('issue.md', 'spec.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match "work mode 'full-feature'"
        }

        It 'F16: names the plan file, the work mode, and the missing file for a full-bug folder without spec.md' {
            $script:IssueContent = "# Issue`n- Work Mode: full-bug`n"
            $script:PresentFiles = @('issue.md')
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match '^FEATURE_FOLDER_ORDER_BLOCKED:'
            $decision.permissionDecisionReason | Should -Match 'plan\.2026-08-23T23-22\.md'
            $decision.permissionDecisionReason | Should -Match 'full-bug'
            $decision.permissionDecisionReason | Should -Match 'spec\.md'
        }

        It 'F17: denies a minor-audit plan write when issue.md is missing' {
            $script:IssueContent = "# Issue`n- Work Mode: minor-audit`n"
            $script:PresentFiles = @()
            $decision = Invoke-PlanWrite
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -Match 'issue\.md'
        }

        It 'F18: denies plan writes but allows other paths when the shared resolver failed to load' {
            $script:IssueContent = "# Issue`n- Work Mode: full-bug`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            $script:FeatureFolderOrderResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                $planDecision = Invoke-PlanWrite
                $issueDecision = Invoke-PlanWrite -PlanPath 'docs/features/active/foo/issue.md'
            }
            finally {
                $script:FeatureFolderOrderResolutionImportFailure = $null
            }
            $planDecision.permissionDecision | Should -Be 'deny'
            $planDecision.permissionDecisionReason | Should -Match '^FEATURE_FOLDER_ORDER_BLOCKED:'
            $planDecision.permissionDecisionReason | Should -Match 'feature-folder-resolution\.ps1'
            $issueDecision.permissionDecision | Should -Be 'allow'
        }

        It 'F19: allows a literal plan.md write in a full-bug folder with issue.md and spec.md' {
            $script:IssueContent = "# Issue`n- Work Mode: full-bug`n"
            $script:PresentFiles = @('issue.md', 'spec.md')
            (Invoke-PlanWrite -PlanPath 'docs/features/active/foo/plan.md').permissionDecision | Should -Be 'allow'
        }
    }
}

Describe 'Get-FeatureFolderIssueContent read seam' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-feature-folder-order.ps1").Path
    }

    It 'E1: returns the issue.md content when the file is present' {
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-features/active/f-1/issue.md' }
        Mock Get-Content { '- Work Mode: full-bug' } -ParameterFilter { $LiteralPath -eq '/synthetic-features/active/f-1/issue.md' }
        Get-FeatureFolderIssueContent -FeatureFolder '/synthetic-features/active/f-1' | Should -Be '- Work Mode: full-bug'
        Should -Invoke Get-Content -Times 1 -Exactly
    }

    It 'E2: returns $null without reading when issue.md is absent' {
        Mock Test-Path { $false } -ParameterFilter { $LiteralPath -eq '/synthetic-features/active/f-1/issue.md' }
        Mock Get-Content { 'unexpected read' }
        Get-FeatureFolderIssueContent -FeatureFolder '/synthetic-features/active/f-1' | Should -BeNullOrEmpty
        Should -Invoke Get-Content -Times 0 -Exactly
    }

    It 'E3: returns $null when reading issue.md throws' {
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-features/active/f-1/issue.md' }
        Mock Get-Content { throw 'simulated read failure' } -ParameterFilter { $LiteralPath -eq '/synthetic-features/active/f-1/issue.md' }
        Get-FeatureFolderIssueContent -FeatureFolder '/synthetic-features/active/f-1' | Should -BeNullOrEmpty
    }
}
