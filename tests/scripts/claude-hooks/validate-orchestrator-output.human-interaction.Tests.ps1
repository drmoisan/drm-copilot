#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the human_interaction shape validation in the
    validate-orchestrator-output.ps1 SubagentStop hook. Kept in a sibling file
    because the primary test file is already at the 500-line cap.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FileExistsCheck stubs mirror the production scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
}

Describe 'validate-orchestrator-output.ps1 human-interaction validation' {
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
