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
        It 'X9 blocks when last_assistant_message is empty' {
            $result = Invoke-ExecutorOutputValidation -InputText '{"last_assistant_message":""}'

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'blocks when the output does not advertise a plan-path token' {
            $raw = @{ last_assistant_message = 'Done. All phases complete.' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

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
            $raw = @{ last_assistant_message = "plan-path: docs/features/active/foo/plan.md`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

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
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

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
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md BLOCKED during preflight without delta' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

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
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md BLOCKED at preflight (before [P0-T1])' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'blocking is permitted only during preflight'
        }

        It 'blocks when AC Status Summary is missing' {
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md Commands Run: pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 PowerShell PASS' } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'AC Status Summary'
        }

        It 'blocks when command/status reporting is missing' {
            $raw = @{ last_assistant_message = "plan-path: docs/features/active/foo/plan.md`nAC Status Summary`nPowerShell PASS" } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'commands run and pass/fail status'
        }

        It 'blocks when a touched language lacks an explicit PASS or FAIL status line' {
            $raw = @{
                last_assistant_message = @"
plan-path: docs/features/active/foo/plan.md
AC Status Summary
Commands Run:
- pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
Results:
- PASS overall
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PowerShell'
        }

        It 'allows termination when checklist, AC summary, commands, and language status lines are present' {
            $raw = @{
                last_assistant_message = @"
plan-path: docs/features/active/foo/plan.md
AC Status Summary
Commands Run:
- pwsh tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
Results:
- PowerShell PASS
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-ExecutorOutputValidation -InputText $raw

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

        It 'CORPUS-EXE-1 accepts a plan line array that contains an empty line' {
            $lines = @('- [x] [P1-T1] Update .claude/hooks/validate-executor-output.ps1', '')

            Test-IsPreflightPlan -Lines $lines | Should -BeFalse
            Get-TouchedLanguagesFromPlan -Lines $lines | Should -Contain 'PowerShell'
        }
    }

    Context 'coverage rows' {
        It 'X1 Get-PlanFileContent reports Exists = $false for a path that does not exist' {
            # Arrange
            $missingPath = Join-Path $PSScriptRoot 'no-such-plan-903.md'

            # Act
            $file = Get-PlanFileContent -Path $missingPath

            # Assert
            $file.Exists | Should -BeFalse
            @($file.Lines).Count | Should -Be 0
        }

        It 'X2 Get-PlanFileContent reports Exists = $true and lines for an existing file' {
            # Act
            $file = Get-PlanFileContent -Path $PSCommandPath

            # Assert
            $file.Exists | Should -BeTrue
            $file.Lines.Count | Should -BeGreaterThan 1
            $file.Lines[0] | Should -Be '#Requires -Version 7.0'
        }

        It 'X3 Get-PlanFileContent normalizes null and scalar content to line arrays' {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { $null }

            # Act
            $nullFile = Get-PlanFileContent -Path 'docs/features/active/foo/plan.md'
            Mock -CommandName Get-Content -MockWith { 'single line' }
            $scalarFile = Get-PlanFileContent -Path 'docs/features/active/foo/plan.md'

            # Assert
            $nullFile.Exists | Should -BeTrue
            @($nullFile.Lines).Count | Should -Be 0
            $scalarFile.Lines -is [array] | Should -BeTrue
            $scalarFile.Lines[0] | Should -Be 'single line'
        }

        It 'X4 blocks when the advertised plan does not exist' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $false; Lines = @() } }
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-ExecutorOutputValidation -InputText $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists at that location'
        }

        It 'X5 blocks when the plan contains no task checkboxes' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @('### Phase 0 - Baseline', 'No tasks here.') } }
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-ExecutorOutputValidation -InputText $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'contains no task checkboxes'
        }

        It 'X6 reports only the first five unchecked lines when more than five remain' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @(1..7 | ForEach-Object { "- [ ] [P1-T$_] Update docs/features/active/foo/file$_.md" }) } }
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-ExecutorOutputValidation -InputText $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '7 unchecked task'
            $result.Message.Contains('(showing first 5)') | Should -BeTrue
        }

        It 'X7 allows a preflight stop that carries the canonical blocked text and a plan delta' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @('DIRECTIVE: PREFLIGHT VALIDATION ONLY', '### Phase 0 - Baseline', '- [ ] [P0-T1] Read docs/features/active/foo/issue.md') } }
            $raw = @{ last_assistant_message = 'plan-path: docs/features/active/foo/plan.md BLOCKED at preflight (before [P0-T1]) plan delta: add a path to [P1-T2]' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-ExecutorOutputValidation -InputText $raw

            # Assert
            $result.Ok | Should -BeTrue
        }

        It 'X8 Test-HasCanonicalBlockedText returns true for text without BLOCKED' {
            Test-HasCanonicalBlockedText -AgentOutput 'All phases complete.' | Should -BeTrue
        }

        It 'X10 Get-TouchedLanguagesFromPlan detects TypeScript, Python, and C# paths' {
            # Act
            $languages = Get-TouchedLanguagesFromPlan -Lines @('- [x] [P1-T1] Update src/a.ts, scripts/b.py, and src/C.cs')

            # Assert
            $languages | Should -Contain 'TypeScript'
            $languages | Should -Contain 'Python'
            $languages | Should -Contain 'CSharp'
        }

        It 'X11 accepts poetry run command evidence' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @('### Phase 1 - Implement', '- [x] [P1-T1] Update .claude/hooks/validate-executor-output.ps1') } }
            $raw = @{ last_assistant_message = "plan-path: docs/features/active/foo/plan.md`nAC Status Summary`npoetry run pytest`nPowerShell PASS" } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-ExecutorOutputValidation -InputText $raw

            # Assert
            $result.Ok | Should -BeTrue
        }
    }

    # fixture-marker-for-coverage
}
