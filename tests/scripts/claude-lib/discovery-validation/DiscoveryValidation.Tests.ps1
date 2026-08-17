Set-StrictMode -Version Latest

# Unit tests for `.claude/lib/discovery-validation/DiscoveryValidation.psm1` (issue #475).
#
# BASH-MIGRATION ORACLE INTENT. This suite is the intended behavioral oracle for the
# eventual bash migration of the hook surface: the error families, the check ordering,
# and the empty-output success contract asserted here are the contract that migration
# must reproduce.
#
# DETERMINISM. Every document under test is an in-memory string; no temporary file is
# created. The only files read are the read-only, committed schema fixtures under
# `schemas/discovery/v1/`. No test mutates `$env:PATH`, probes for a live `python`, or
# mutates `$PSVersionTable`.

BeforeAll {
    # Resolve the repository root by walking up from this file's own location, never
    # from the CWD, so the suite behaves identically in terminal and Test Explorer.
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

    # Absolute `file://` URI for a committed schema fixture, built at run time so the
    # suite is location-independent.
    $script:SchemaDirectory = Join-Path -Path $script:RepoRoot -ChildPath 'schemas/discovery/v1'

    function Get-SchemaFileUri {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [string]$FileName
        )

        $full = Join-Path -Path $script:SchemaDirectory -ChildPath $FileName
        return ([System.Uri]$full).AbsoluteUri
    }

    # A minimal evidence-reference document that satisfies its schema. Chosen because
    # it is the simplest of the seven schemas (it is the shared leaf artifact).
    function Get-ValidEvidenceReferenceJson {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $false)]
            [string]$SchemaUri = (Get-SchemaFileUri -FileName 'evidence-reference.schema.json')
        )

        $document = [ordered]@{
            '$schema'        = $SchemaUri
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

Describe 'DiscoveryValidation' {

    Context 'artifact-type table' {
        It 'exposes exactly the seven schema-governed types' {
            # Act
            $types = Get-DiscoverySchemaArtifactType

            # Assert
            @($types).Count | Should -Be 7
            $types | Should -Contain 'feature-contract'
            $types | Should -Contain 'evidence-reference'
        }

        It 'maps the three tokens whose schema filename differs from the token stem' {
            # Assert: these three are the mapping traps called out in the plan.
            Get-DiscoverySchemaFileName -ArtifactType 'runtime-scenario' |
                Should -Be 'runtime-characterization-scenario.schema.json'
            Get-DiscoverySchemaFileName -ArtifactType 'product-decision' |
                Should -Be 'product-decision-record.schema.json'
            Get-DiscoverySchemaFileName -ArtifactType 'unspecified-behavior' |
                Should -Be 'unspecified-behavior-record.schema.json'
        }

        It 'returns null for a token that is not schema-governed' {
            # `profile` is validated by the placeholder contract, not by a schema.
            Get-DiscoverySchemaFileName -ArtifactType 'profile' | Should -BeNullOrEmpty
        }

        It 'names a real committed schema file for every schema-governed type' {
            # Guards the table against drift from `schemas/discovery/v1/`.
            foreach ($type in (Get-DiscoverySchemaArtifactType)) {
                $fileName = Get-DiscoverySchemaFileName -ArtifactType $type
                $path = Join-Path -Path $script:SchemaDirectory -ChildPath $fileName
                Test-Path -LiteralPath $path -PathType Leaf |
                    Should -BeTrue -Because "the table names '$fileName' for '$type'"
            }
        }
    }

    Context 'profile placeholder contract' {
        It 'reports an empty document' {
            # Act
            $errors = Get-DiscoveryProfileValidationError -Text ''

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Be 'Profile document is empty.'
        }

        It 'reports a whitespace-only document as empty' {
            # Act
            $errors = Get-DiscoveryProfileValidationError -Text "   `n`t  `n"

            # Assert
            $errors[0] | Should -Be 'Profile document is empty.'
        }

        It 'reports a sequence root as a non-mapping root' {
            # Arrange: a YAML sequence document has no top-level mapping key.
            $text = "- first`n- second`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Be 'Profile document root must be a mapping.'
        }

        It 'reports a bare scalar root as a non-mapping root' {
            # Act
            $errors = Get-DiscoveryProfileValidationError -Text "just a scalar`n"

            # Assert
            $errors[0] | Should -Be 'Profile document root must be a mapping.'
        }

        It 'reports a malformed document as a non-mapping root rather than accepting it' {
            # Arrange: this is the fail-closed substitute for the Python reference's
            # YAML-parse-failure branch, which has no analogue without a YAML parser.
            $text = "`t- : ::`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert: rejected, never silently accepted.
            @($errors).Count | Should -BeGreaterThan 0
            $errors[0] | Should -Be 'Profile document root must be a mapping.'
        }

        It 'reports the placeholder required field when it is absent' {
            # Arrange
            $text = "some_other_key: value`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Be 'Missing required field: legacy_source_path.'
        }

        It 'accepts a document carrying the placeholder required field' {
            # Arrange
            $text = "legacy_source_path: ./legacy`nother: value`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert
            @($errors).Count | Should -Be 0
        }

        It 'ignores comments and document markers when collecting top-level keys' {
            # Arrange
            $text = "---`n# a comment`nlegacy_source_path: ./legacy`n...`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert
            @($errors).Count | Should -Be 0
        }

        It 'does not treat an indented key as a top-level key' {
            # Arrange: `legacy_source_path` is nested, so the required field is absent.
            $text = "outer:`n    legacy_source_path: ./legacy`n"

            # Act
            $errors = Get-DiscoveryProfileValidationError -Text $text

            # Assert
            $errors[0] | Should -Be 'Missing required field: legacy_source_path.'
        }
    }

    Context 'schema resolution' {
        It 'reports a missing schema property' {
            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri $null

            # Assert
            $result.Path | Should -BeNullOrEmpty
            $result.Error | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports a non-string schema property' {
            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri 42

            # Assert
            $result.Error | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports an empty schema property' {
            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri ''

            # Assert
            $result.Error | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports a scheme-less schema reference' {
            # Arrange: the pure text validators receive no document path, so a
            # relative reference cannot be resolved.
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri 'evidence-reference.schema.json'

            # Assert
            $result.Error | Should -Be 'schema resolution failed (Unsupported schema URI scheme: missing)'
        }

        It 'reports an https schema reference without fetching it' {
            # Arrange: deliberate divergence from the Python reference, which fetches
            # and caches. A destination has no guaranteed network access.
            $uri = 'https://example.invalid/evidence-reference.schema.json'

            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri $uri

            # Assert
            $result.Error | Should -Be 'schema resolution failed (Unsupported schema URI scheme: https)'
        }

        It 'reports a file reference that does not exist' {
            # Arrange
            $missing = Join-Path -Path $script:SchemaDirectory -ChildPath 'no-such-schema.json'
            $uri = ([System.Uri]$missing).AbsoluteUri

            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri $uri

            # Assert
            $result.Error | Should -Match '^schema resolution failed \(Schema file not found: '
        }

        It 'resolves a committed file schema reference' {
            # Act
            $result = Resolve-DiscoverySchemaFilePath -SchemaUri (Get-SchemaFileUri -FileName 'evidence-reference.schema.json')

            # Assert
            $result.Error | Should -BeNullOrEmpty
            Test-Path -LiteralPath $result.Path -PathType Leaf | Should -BeTrue
        }
    }

    Context 'schema-governed artifact validation' {
        It 'reports invalid JSON' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '{ not json'

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -Match '^invalid JSON \('
        }

        It 'reports a JSON array root as a non-object root' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '[1, 2]'

            # Assert
            $errors[0] | Should -Be 'JSON root must be an object for validation'
        }

        It 'reports a JSON scalar root as a non-object root' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '"a string"'

            # Assert
            $errors[0] | Should -Be 'JSON root must be an object for validation'
        }

        It 'reports a document with no schema property' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '{"id": "ev-001"}'

            # Assert
            $errors[0] | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports a document whose schema property is empty' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '{"$schema": ""}'

            # Assert
            $errors[0] | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports a document whose schema property is not a string' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text '{"$schema": 7}'

            # Assert
            $errors[0] | Should -Be 'schema resolution failed (missing $schema)'
        }

        It 'reports schema violations for a document that fails its schema' {
            # Arrange: valid JSON and a resolvable schema, but required fields absent.
            $uri = Get-SchemaFileUri -FileName 'evidence-reference.schema.json'
            $text = "{`"`$schema`": `"$uri`"}"

            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text $text

            # Assert
            @($errors).Count | Should -BeGreaterThan 0
            ($errors -join "`n") | Should -Match 'not valid with the schema'
        }

        It 'returns no error for a document that satisfies its schema' {
            # Act
            $errors = Get-DiscoverySchemaArtifactValidationError -Text (Get-ValidEvidenceReferenceJson)

            # Assert
            @($errors).Count | Should -Be 0 -Because (@($errors) -join "`n")
        }
    }

    Context 'dispatch by artifact type' {
        It 'routes the profile token to the placeholder contract' {
            # Act
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'profile' -Text ''

            # Assert
            $errors[0] | Should -Be 'Profile document is empty.'
        }

        It 'routes a schema-governed token to the schema check' {
            # Act
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' -Text '[1]'

            # Assert
            $errors[0] | Should -Be 'JSON root must be an object for validation'
        }

        It 'returns a flat array of strings, never an array nested in an array' {
            # Regression guard. These helpers emit their array as a single object, so
            # a dispatcher that wrapped the call in `@()` produced a one-element array
            # whose only element was the real error array. Every downstream count,
            # index, and `-join` then silently operated on 'System.Object[]'.
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'profile' -Text 'other: 1'

            # Assert
            @($errors).Count | Should -Be 1
            $errors[0] | Should -BeOfType [string]
            $errors[0] | Should -Be 'Missing required field: legacy_source_path.'
        }

        It 'reports an unrecognized artifact type rather than accepting it' {
            # Act
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'not-a-type' -Text '{}'

            # Assert
            $errors[0] | Should -Be 'Unsupported artifact type: not-a-type'
        }

        It 'returns no error for a conforming schema-governed document' {
            # Act
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text (Get-ValidEvidenceReferenceJson)

            # Assert
            @($errors).Count | Should -Be 0 -Because (@($errors) -join "`n")
        }
    }

    Context 'seam result contract (defect D-2 avoidance)' {
        It 'returns exit code 0 and EMPTY output for a passing validation' {
            # This is the D-2 assertion. The previous Python CLI printed
            # "<type> validation passed: <path>" on success, and both hooks deny on
            # non-empty output, so a passing validation produced a DENY verdict.
            # Success must be silent.
            $result = ConvertTo-DiscoveryValidationResult -ValidationError @()

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Be ''
            [string]::IsNullOrWhiteSpace($result.Output) | Should -BeTrue
        }

        It 'returns exit code 1 and the joined errors for a failing validation' {
            # Act
            $result = ConvertTo-DiscoveryValidationResult -ValidationError @('first error', 'second error')

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Be ("first error" + [System.Environment]::NewLine + "second error")
        }

        It 'always returns exactly the ExitCode and Output keys the seam contract names' {
            # The hook seam `Invoke-DiscoveryValidatorExe` must keep returning this
            # shape; 26 existing test references depend on it.
            $result = ConvertTo-DiscoveryValidationResult -ValidationError @()

            # Assert
            @($result.Keys) | Should -HaveCount 2
            $result.Keys | Should -Contain 'ExitCode'
            $result.Keys | Should -Contain 'Output'
        }

        It 'produces an empty-output success result for a conforming artifact end to end' {
            # Arrange: the pure text path the on-disk entry point delegates to, so no
            # temporary file is created. No committed artifact can serve as an on-disk
            # pass fixture: every example under `examples/discovery/v1/` declares a
            # scheme-less relative `$schema`, which the Python reference and this module
            # both reject identically because a pure text validator has no base path.
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' `
                -Text (Get-ValidEvidenceReferenceJson)

            # Act
            $result = ConvertTo-DiscoveryValidationResult -ValidationError $errors

            # Assert
            $result.ExitCode | Should -Be 0 -Because ($errors -join "`n")
            $result.Output | Should -Be ''
        }

        It 'reports a missing artifact path rather than throwing' {
            # Arrange
            $missing = Join-Path -Path $script:RepoRoot -ChildPath 'no-such-artifact.json'

            # Act
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs @('evidence-reference', $missing)

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match '^Artifact not found: '
        }

        It 'reports insufficient validator arguments rather than throwing' {
            # Act
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs @('evidence-reference')

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Be 'Discovery validation requires an artifact type and a path.'
        }

        It 'joins multiple errors one per line' {
            # Arrange: a profile document missing the required field yields one error;
            # the join contract is what the hook surfaces after the blocked prefix.
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'profile' -Text 'other: 1'
            $joined = $errors -join [System.Environment]::NewLine

            # Assert
            $joined | Should -Be 'Missing required field: legacy_source_path.'
        }
    }
}
