#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-executor-output.ps1 SubagentStop hook.
#>

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'
    . $hookPath
}

Describe 'validate-executor-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            # Arrange
            $raw = ''

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when CLAUDE_HOOK_INPUT contains malformed JSON' {
            # Arrange
            $raw = '{ this is not valid json'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse CLAUDE_HOOK_INPUT as JSON'
        }

        It 'blocks when the output field is missing or empty' {
            # Arrange
            $raw = '{"output":""}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'blocks when the output does not advertise a plan-path token' {
            # Arrange
            $raw = '{"output":"Done. All phases complete."}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a plan-path'
        }
    }

    Context 'plan file presence' {
        It 'blocks when the advertised plan-path does not exist on disk' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $false; Lines = @() } }
            $raw = '{"output":"plan-path: docs/features/active/missing/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "no file exists"
            $result.Message | Should -Match 'docs/features/active/missing/plan.md'
        }
    }

    Context 'checkbox enforcement' {
        It 'blocks when the plan file contains no task checkboxes' {
            # Arrange
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '# Plan',
                        '',
                        'No tasks here, just prose.'
                    )
                }
            }
            $raw = '{"output":"plan-path: docs/features/active/x/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no task checkboxes'
        }

        It 'blocks with the line number when one task is unchecked' {
            # Arrange — the unchecked checkbox sits on line 3 (1-based)
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '# Plan',
                        '## Phase 0',
                        '- [ ] [P0-T1] Capture baseline',
                        '- [x] [P0-T2] Read policy'
                    )
                }
            }
            $raw = '{"output":"plan-path: docs/features/active/x/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'docs/features/active/x/plan.md'
            $result.Message | Should -Match '1 unchecked task'
            $result.Message | Should -Match 'line\(s\) 3\b'
        }

        It 'blocks and reports the count when multiple tasks are unchecked' {
            # Arrange — three unchecked items mixed with one checked item
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '- [ ] [P0-T1] one',
                        '- [x] [P0-T2] two',
                        '- [ ] [P1-T1] three',
                        '- [ ] [P1-T2] four'
                    )
                }
            }
            $raw = '{"output":"plan-path: docs/features/active/x/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '3 unchecked task'
        }

        It 'reports only the first 5 line numbers when many tasks are unchecked' {
            # Arrange — seven unchecked items; expect first 5 reported with suffix
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '- [ ] [P0-T1] a',
                        '- [ ] [P0-T2] b',
                        '- [ ] [P0-T3] c',
                        '- [ ] [P0-T4] d',
                        '- [ ] [P0-T5] e',
                        '- [ ] [P0-T6] f',
                        '- [ ] [P0-T7] g'
                    )
                }
            }
            $raw = '{"output":"plan-path: docs/features/active/x/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '7 unchecked task'
            $result.Message | Should -Match 'showing first 5'
            $result.Message | Should -Match '1, 2, 3, 4, 5'
        }

        It 'allows termination when all checkboxes are ticked using - [x] or - [X]' {
            # Arrange — both lowercase and uppercase ticked forms must pass
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '- [x] [P0-T1] lowercase done',
                        '- [X] [P0-T2] uppercase done',
                        '- [x] [P1-T1] more done'
                    )
                }
            }
            $raw = '{"output":"plan-path: docs/features/active/x/plan.md"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'payload edge cases' {
        It 'blocks when the JSON payload omits the output field entirely' {
            # Arrange — payload is valid JSON but has no "output" property
            $raw = '{"sessionId":"abc"}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'Get-PlanPathFromOutput' {
        It 'returns $null when the markdown-link form contains only whitespace' {
            # Arrange — regex matches but trimmed value is empty
            $output = 'see [plan-path](    )'

            # Act
            $result = Get-PlanPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It 'extracts a quoted plan-path value' {
            # Arrange
            $output = 'plan-path: "docs/features/active/foo/plan.md"'

            # Act
            $result = Get-PlanPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -Be 'docs/features/active/foo/plan.md'
        }

        It 'extracts a plan-path value using = separator' {
            # Arrange
            $output = 'plan-path = docs/foo/plan.md'

            # Act
            $result = Get-PlanPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -Be 'docs/foo/plan.md'
        }
    }

    Context 'Get-PlanFileContent' {
        It 'reports Exists=$false for a path that does not exist' {
            # Arrange — a path that cannot exist
            $missing = Join-Path $PSScriptRoot 'this-file-definitely-does-not-exist.xyz'

            # Act
            $result = Get-PlanFileContent -Path $missing

            # Assert
            $result.Exists | Should -BeFalse
            $result.Lines | Should -BeNullOrEmpty
        }

        It 'reads lines from a real file on disk (uses the test file as fixture)' {
            # Arrange — read this very test file; it is guaranteed to exist
            $self = $PSCommandPath

            # Act
            $result = Get-PlanFileContent -Path $self

            # Assert — the test file contains a line with this exact marker
            $result.Exists | Should -BeTrue
            $result.Lines.Count | Should -BeGreaterThan 0
            ($result.Lines -join "`n") | Should -Match 'fixture-marker-for-coverage'
        }
    }
    # fixture-marker-for-coverage

    Context 'plan-path token forms' {
        It 'parses the markdown-link form [plan-path](docs/.../plan.md)' {
            # Arrange — agent output uses markdown-link form
            Mock -CommandName Get-PlanFileContent -MockWith {
                param($Path)
                $script:capturedPath = $Path
                @{
                    Exists = $true
                    Lines  = @('- [x] [P0-T1] done')
                }
            }
            $raw = '{"output":"Final summary: see [plan-path](docs/features/active/foo/plan.md)."}'

            # Act
            $result = Invoke-ExecutorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue
            $script:capturedPath | Should -Be 'docs/features/active/foo/plan.md'
        }
    }
}
