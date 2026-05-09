#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-executor-output.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'
    . $hookPath
}

Describe 'validate-executor-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            $result = Invoke-ExecutorOutputValidation -RawPayload ''

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when the output does not advertise a plan-path token' {
            $raw = @{ output = 'Done. All phases complete.' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a plan-path'
        }
    }

    Context 'preflight validation' {
        It 'allows a preflight plan to stop with PREFLIGHT: ALL CLEAR even when tasks remain unchecked' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        'DIRECTIVE: PREFLIGHT VALIDATION ONLY',
                        '### Phase 0 - Baseline',
                        '- [ ] [P0-T1] Read docs/features/active/foo/issue.md and write docs/features/active/foo/evidence/baseline/phase0.md',
                        '### Phase 1 - QA',
                        '- [ ] [P1-T1] Run pwsh ./tests/foo.Tests.ps1 and update docs/features/active/foo/evidence/qa-gates/qa.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
        }

        It 'blocks a preflight plan when the exact preflight signal is missing' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        'DIRECTIVE: PREFLIGHT VALIDATION ONLY',
                        '### Phase 0 - Baseline',
                        '- [ ] [P0-T1] Read docs/features/active/foo/issue.md and write docs/features/active/foo/evidence/baseline/phase0.md'
                    )
                }
            }
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'preflight output must include'
        }

        It 'blocks malformed preflight blocked text' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        'DIRECTIVE: PREFLIGHT VALIDATION ONLY',
                        '### Phase 0 - Baseline',
                        '- [ ] [P0-T1] Read docs/features/active/foo/issue.md and write docs/features/active/foo/evidence/baseline/phase0.md'
                    )
                }
            }
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md BLOCKED during preflight without delta' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'exact text `BLOCKED at preflight'
        }
    }

    Context 'execution validation' {
        BeforeEach {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '### Phase 0 - Baseline',
                        '- [x] [P0-T1] Read docs/features/active/foo/issue.md and write docs/features/active/foo/evidence/baseline/phase0.md',
                        '### Phase 1 - Implement',
                        '- [x] [P1-T1] Update .claude/hooks/validate-executor-output.ps1 and tests/scripts/claude-hooks/validate-executor-output.Tests.ps1',
                        '### Phase 2 - QA',
                        '- [x] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
        }

        It 'blocks non-preflight output that claims a blocked state' {
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md BLOCKED at preflight (before [P0-T1])' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'blocking is permitted only during preflight'
        }

        It 'blocks when AC Status Summary is missing' {
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md Commands Run: pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 PowerShell PASS' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'AC Status Summary'
        }

        It 'blocks when command/status reporting is missing' {
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`nAC Status Summary`nPowerShell PASS" } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'commands run and pass/fail status'
        }

        It 'blocks when a touched language lacks an explicit PASS or FAIL status line' {
            $raw = @{
                output = @"
plan-path: docs/features/active/foo/plan.md
AC Status Summary
Commands Run:
- pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
Results:
- PASS overall
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PowerShell'
        }

        It 'allows termination when checklist, AC summary, commands, and language status lines are present' {
            $raw = @{
                output = @"
plan-path: docs/features/active/foo/plan.md
AC Status Summary
Commands Run:
- pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
Results:
- PowerShell PASS
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'path parsing helpers' {
        It 'extracts a quoted plan-path value' {
            Get-PlanPathFromOutput -AgentOutput 'plan-path: "docs/features/active/foo/plan.md"' |
                Should -Be 'docs/features/active/foo/plan.md'
        }

        It 'detects preflight plans from the directive line' {
            Test-IsPreflightPlan -Lines @('DIRECTIVE: PREFLIGHT VALIDATION ONLY') |
                Should -BeTrue
        }

        It 'detects touched PowerShell files from plan paths' {
            $languages = Get-TouchedLanguagesFromPlan -Lines @(
                '- [x] [P1-T1] Update .claude/hooks/validate-executor-output.ps1 and tests/scripts/claude-hooks/validate-executor-output.Tests.ps1'
            )

            $languages | Should -Contain 'PowerShell'
        }
    }

    # fixture-marker-for-coverage
}
