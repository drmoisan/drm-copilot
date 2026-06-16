#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-orchestrator-output.ps1 SubagentStop hook.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FileExistsCheck stubs mirror the production scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
}

Describe 'validate-orchestrator-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            # Arrange
            $raw = ''

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when CLAUDE_HOOK_INPUT contains malformed JSON' {
            # Arrange
            $raw = '{ this is not valid json'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse CLAUDE_HOOK_INPUT as JSON'
        }

        It 'blocks when the output field is empty' {
            # Arrange
            $raw = '{"output":""}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'blocks when the JSON payload omits the output field entirely' {
            # Arrange — valid JSON but no "output" property
            $raw = '{"sessionId":"abc"}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'checkpoint file presence' {
        It 'blocks when the checkpoint file does not exist' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $false; Content = $null } }
            $raw = '{"output":"All steps complete."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'checkpoint file'
            $result.Message | Should -Match 'does not exist'
        }

        It 'blocks when the checkpoint file content is empty' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = '   ' } }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is empty'
        }
    }

    Context 'checkpoint structure validation' {
        It 'blocks when the checkpoint file is not valid JSON' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = '{ broken json' } }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is not valid JSON'
        }

        It 'blocks when checkpoint is missing required fields' {
            # Arrange — only objective present, others missing
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{ Exists = $true; Content = '{"objective":"work"}' }
            }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'missing required field'
            $result.Message | Should -Match 'completed_steps'
            $result.Message | Should -Match 'next_step'
            $result.Message | Should -Match 'last_updated'
        }

        It 'blocks when checkpoint has empty objective' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"","completed_steps":[],"next_step":"x","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "empty 'objective'"
        }

        It 'allows termination when all required fields are present and objective is set' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"step2","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Final summary: orchestration complete."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'Get-CheckpointFileContent' {
        It 'reports Exists=$false for a path that does not exist' {
            # Arrange
            $missing = Join-Path $PSScriptRoot 'this-checkpoint-definitely-does-not-exist.json'

            # Act
            $result = Get-CheckpointFileContent -Path $missing

            # Assert
            $result.Exists | Should -BeFalse
            $result.Content | Should -BeNullOrEmpty
        }

        It 'reads content from a real file on disk (uses the test file as fixture)' {
            # Arrange — read this very test file; it is guaranteed to exist
            $self = $PSCommandPath

            # Act
            $result = Get-CheckpointFileContent -Path $self

            # Assert — the test file contains a marker for coverage verification
            $result.Exists | Should -BeTrue
            $result.Content | Should -Match 'orchestrator-fixture-marker-for-coverage'
        }
    }
    # orchestrator-fixture-marker-for-coverage

    Context 'Test-HumanInteractionShape' {
        It 'passes when human_interaction is absent (backward-compatible)' {
            # Arrange — null input represents an absent top-level key
            $humanInteraction = $null

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'blocks when requirements is missing' {
            # Arrange — human_interaction present but with no requirements array
            $humanInteraction = [pscustomobject]@{ note = 'no requirements here' }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "'requirements' array is missing"
        }

        It 'blocks when a requirement has no response' {
            # Arrange — a requirement object without a response value
            $humanInteraction = [pscustomobject]@{
                requirements = @([pscustomobject]@{ id = 'r1' })
            }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "has no resolved 'response'"
        }

        It 'blocks when a requirement response is outside the enum' {
            # Arrange — response value not in (scope_change, exception, halt)
            $humanInteraction = [pscustomobject]@{
                requirements = @([pscustomobject]@{ response = 'maybe' })
            }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'outside the allowed set'
        }

        It 'blocks when a requirement response is halt' {
            # Arrange — an unresolved halt must block DONE
            $humanInteraction = [pscustomobject]@{
                requirements = @([pscustomobject]@{ response = 'halt' })
            }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "'response' == 'halt'"
        }

        It 'blocks when an exception requirement has no existing runbook (injected FileExistsCheck returns false)' {
            # Arrange — exception with a runbook_path that does not exist on disk
            $humanInteraction = [pscustomobject]@{
                requirements = @([pscustomobject]@{
                        response     = 'exception'
                        runbook_path = 'docs/features/active/x/runbooks/missing.runbook.md'
                    })
            }
            $fileExistsStub = { param($Path) $false }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction -FileExistsCheck $fileExistsStub

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists at that location'
        }

        It 'passes when an exception requirement has an existing runbook (injected FileExistsCheck returns true)' {
            # Arrange — exception with a runbook_path the injected seam confirms exists
            $humanInteraction = [pscustomobject]@{
                requirements = @(
                    [pscustomobject]@{ response = 'scope_change' },
                    [pscustomobject]@{
                        response     = 'exception'
                        runbook_path = 'docs/features/active/x/runbooks/admin-consent.runbook.md'
                    }
                )
            }
            $fileExistsStub = { param($Path) $true }

            # Act
            $result = Test-HumanInteractionShape -HumanInteraction $humanInteraction -FileExistsCheck $fileExistsStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }
}
