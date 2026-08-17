Set-StrictMode -Version Latest

# Destination version-floor tests for `.claude/lib/discovery-validation/DiscoveryValidation.psm1`
# (issue #475). Authorized sibling split of `DiscoveryValidation.Tests.ps1`, which reached
# the 500-line cap once these `It`s were added.
#
# BASH-MIGRATION ORACLE INTENT. This suite is part of the intended behavioral oracle for
# the eventual bash migration of the hook surface: the fail-closed floor behavior and the
# three required message elements asserted here are contract, not incidental wording.
#
# DETERMINISM. Every test drives the injectable `-PowerShellVersion` seam. No test mutates
# `$PSVersionTable`, and no assertion depends on the version of the host running the
# suite, so results are identical on any PowerShell 7.x host and in Test Explorer.

BeforeAll {
    # Resolve the repo root by walking up from this file's own location, never from the
    # CWD, so the suite behaves identically in terminal and Test Explorer.
    $testsRoot = $PSScriptRoot
    while ($null -ne $testsRoot -and (Split-Path -Path $testsRoot -Leaf) -ne 'tests') {
        $testsRoot = Split-Path -Path $testsRoot -Parent
    }
    if ($null -eq $testsRoot) {
        throw "Unable to resolve the 'tests' root by walking up from '$PSScriptRoot'."
    }
    $script:RepoRoot = Split-Path -Path $testsRoot -Parent

    Import-Module (Join-Path -Path $script:RepoRoot `
            -ChildPath '.claude/lib/discovery-validation/DiscoveryValidation.psm1') -Force

    $script:SchemaDirectory = Join-Path -Path $script:RepoRoot -ChildPath 'schemas/discovery/v1'

    # A minimal evidence-reference document that satisfies its schema, so any error
    # observed below can only have come from the version floor.
    function Get-ValidEvidenceReferenceJson {
        [CmdletBinding()]
        [OutputType([string])]
        param()

        $schemaPath = Join-Path -Path $script:SchemaDirectory -ChildPath 'evidence-reference.schema.json'
        $document = [ordered]@{
            '$schema'        = ([System.Uri]$schemaPath).AbsoluteUri
            'schema_version' = '1.0.0'
            'id'             = 'ev-001'
            'kind'           = 'file'
            'location'       = 'artifacts/example.txt'
            'captured_at'    = '2026-08-15T12:00:00Z'
            'description'    = 'Example evidence for a unit test.'
        }
        return ($document | ConvertTo-Json -Depth 5)
    }
}

Describe 'DiscoveryValidation destination version floor' {

    Context 'floor boundary' {
        It 'returns no error at the 7.4.0 floor' {
            Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.4.0') |
                Should -BeNullOrEmpty
        }

        It 'returns no error above the floor' {
            Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.6.3') |
                Should -BeNullOrEmpty
        }

        It 'returns an error below the floor' {
            Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.9') |
                Should -Not -BeNullOrEmpty
        }
    }

    Context 'message content (all three required elements)' {
        It 'names the required version' {
            $message = Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.0')
            $message | Should -Match 'PowerShell 7\.4'
        }

        It 'names the Test-Json SchemaFile Draft 2020-12 reason' {
            $message = Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.0')
            $message | Should -Match 'Test-Json -SchemaFile'
            $message | Should -Match 'Draft 2020-12'
        }

        It 'identifies issue 475' {
            $message = Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.0')
            $message | Should -Match '#475'
        }

        It 'reports the actual host version so the message is actionable' {
            $message = Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.0')
            $message | Should -Match '7\.3\.0'
        }
    }

    Context 'fail-closed at every entry point' {
        It 'fails closed from the profile entry point on an unsupported host' {
            # Arrange: a document that would otherwise PASS, proving the floor is
            # checked before the document is considered.
            $text = "legacy_source_path: ./legacy`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text -PowerShellVersion ([version]'7.3.0')

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Match 'PowerShell 7\.4'
        }

        It 'fails closed from the schema entry point on an unsupported host' {
            # Arrange / Act: a conforming document, so only the floor can raise an error.
            $errors = Get-DiscoverySchemaArtifactValidationError -Text (Get-ValidEvidenceReferenceJson) `
                -PowerShellVersion ([version]'7.3.0')

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Match '#475'
        }

        It 'fails closed from the dispatch entry point on an unsupported host' {
            # Act
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text (Get-ValidEvidenceReferenceJson) -PowerShellVersion ([version]'7.3.0')

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Match 'PowerShell 7\.4'
        }

        It 'reports the floor before reporting a document defect' {
            # Arrange: a document that is ALSO invalid. The floor must win, so the
            # unsupported host gets one actionable message, not an opaque parse error.
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text '{ not json' -PowerShellVersion ([version]'7.3.0')

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Match 'PowerShell 7\.4'
        }
    }

    Context 'no silent degradation' {
        It 'never returns a passing result on an unsupported host' {
            # The same conforming document passes above the floor and fails below it.
            $supported = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text (Get-ValidEvidenceReferenceJson) -PowerShellVersion ([version]'7.4.0')
            $unsupported = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text (Get-ValidEvidenceReferenceJson) -PowerShellVersion ([version]'7.3.0')

            # Assert
            (ConvertTo-DiscoveryValidationResult -ValidationError $supported).ExitCode | Should -Be 0
            (ConvertTo-DiscoveryValidationResult -ValidationError $unsupported).ExitCode | Should -Be 1
        }

        It 'does not mutate the host version table' {
            # Guards the seam contract: the module READS the version, never writes it.
            $before = $PSVersionTable.PSVersion.ToString()
            $null = Get-DiscoveryRuntimeVersionError -PowerShellVersion ([version]'7.3.0')

            # Assert
            $PSVersionTable.PSVersion.ToString() | Should -Be $before
        }
    }
}
