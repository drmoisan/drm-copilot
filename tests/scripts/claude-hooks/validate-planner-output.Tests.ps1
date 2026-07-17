#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-planner-output.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'
    . $hookPath
}

Describe 'validate-planner-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            $result = Invoke-PlannerOutputValidation -RawPayload ''

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when the output is missing an exact preflight signal' {
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @() } }
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PREFLIGHT: ALL CLEAR'
        }
    }

    Context 'plan structure validation' {
        It 'blocks when the advertised plan-path does not exist on disk' {
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $false; Lines = @() } }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists'
        }

        It 'blocks when Phase 0 baseline and policy-read tasks are missing' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1',
                        "### Phase 2 `u{2014} QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'Phase 0'
        }

        It 'blocks when a task omits an explicit path' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read policy files',
                        '- [ ] [P0-T2] Capture baseline for docs/features/active/foo/issue.md',
                        "### Phase 1 `u{2014} QA",
                        '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: REVISIONS REQUIRED" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'explicit path'
        }

        It 'allows termination when the plan satisfies the structural contract' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read AGENTS.md and .agents/skills/powershell/SKILL.md and record docs/features/active/foo/evidence/baseline/phase0-instructions-read.md',
                        '- [ ] [P0-T2] Capture baseline with pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/baseline/pester.md',
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1',
                        "### Phase 2 `u{2014} Final QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'allows termination when phase headings use the canonical em dash (U+2014)' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read AGENTS.md and .agents/skills/powershell/SKILL.md and record docs/features/active/foo/evidence/baseline/phase0-instructions-read.md',
                        '- [ ] [P0-T2] Capture baseline with pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/baseline/pester.md',
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1',
                        "### Phase 2 `u{2014} Final QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }
}
