#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Compatibility-contract tests for `.claude/lib/discovery-validation/DiscoveryValidation.psm1` (issues #475, #980).
.DESCRIPTION
    The module no longer evaluates artifact semantics. These tests pin the deliberate
    contract: the artifact-type table and the host floor are retained, every former
    validation entry returns a validation-required result naming the authoritative service
    and never an empty error list, `Invoke-DiscoveryArtifactValidation` never returns exit
    code 0 whatever the document says, and `Get-DiscoveryValidationAuthority` reports the
    protected activation or an unsupported host. No file, process, network or clock is
    touched; the artifact-path and store seams are in-memory.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    Import-Module (Join-Path $lib 'DiscoveryValidation.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    $script:Supported = [version]'7.4.0'
    $script:ConformingDocument = '{"$schema":"file:///schemas/discovery/v1/evidence-reference.schema.json","schema_version":"1.0.0","id":"ev-001","kind":"file","location":"artifacts/example.txt","captured_at":"2026-08-15T12:00:00Z","description":"Example evidence."}'
}

Describe 'DiscoveryValidation compatibility surface' {
    Context 'artifact-type table' {
        It 'exposes exactly the seven schema-governed types' {
            @(Get-DiscoverySchemaArtifactType | Sort-Object) | Should -Be @('coverage-ledger', 'evidence-reference', 'feature-contract', 'parity-matrix', 'product-decision', 'runtime-scenario', 'unspecified-behavior')
        }

        It 'maps the three tokens whose schema filename differs from the token stem' {
            Get-DiscoverySchemaFileName -ArtifactType 'runtime-scenario' | Should -Be 'runtime-characterization-scenario.schema.json'
            Get-DiscoverySchemaFileName -ArtifactType 'unspecified-behavior' | Should -Be 'unspecified-behavior-record.schema.json'
            Get-DiscoverySchemaFileName -ArtifactType 'product-decision' | Should -Be 'product-decision-record.schema.json'
        }

        It 'returns null for a token that is not schema-governed' {
            Get-DiscoverySchemaFileName -ArtifactType 'profile' | Should -BeNullOrEmpty
            Resolve-DiscoverySchemaFilePath -ArtifactType 'unknown' -RepositoryRoot $script:RepoRoot | Should -BeNullOrEmpty
        }

        It 'names a real committed schema file for every schema-governed type' {
            foreach ($type in Get-DiscoverySchemaArtifactType) {
                Test-Path -LiteralPath (Resolve-DiscoverySchemaFilePath -ArtifactType $type -RepositoryRoot $script:RepoRoot) -PathType Leaf | Should -BeTrue -Because $type
            }
        }
    }

    Context 'retired semantics return a validation-required result' {
        It 'exports exactly the twelve compatibility names' {
            @((Get-Module DiscoveryValidation).ExportedFunctions.Keys | Sort-Object) | Should -Be @(
                'ConvertTo-DiscoveryValidationResult', 'Get-DiscoveryArtifactValidationError', 'Get-DiscoveryProfileTopLevelKey', 'Get-DiscoveryProfileValidationError',
                'Get-DiscoveryRuntimeVersionError', 'Get-DiscoverySchemaArtifactType', 'Get-DiscoverySchemaArtifactValidationError', 'Get-DiscoverySchemaFileName',
                'Get-DiscoveryValidationAuthority', 'Get-DiscoveryValidationRequiredMessage', 'Invoke-DiscoveryArtifactValidation', 'Resolve-DiscoverySchemaFilePath')
        }

        It 'reports no profile key and never parses the profile text' {
            @(Get-DiscoveryProfileTopLevelKey -Text "legacy_source_path: ./legacy`nextra: 1`n").Count | Should -Be 0
            $errors = Get-DiscoveryProfileValidationError -Text "legacy_source_path: ./legacy`n" -PowerShellVersion $script:Supported
            @($errors).Count | Should -Be 1
            $errors[0] | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED: the profile artifact is validated only by the installed discovery service (validate_discovery_artifacts)*'
        }

        It 'returns the validation-required message for a <Name> document' -ForEach @(
            @{ Name = 'conforming'; Text = '{"$schema":"file:///x.json","id":"ev-001"}' }
            @{ Name = 'malformed'; Text = '{ not json' }
            @{ Name = 'empty'; Text = '' }
        ) {
            $schema = Get-DiscoverySchemaArtifactValidationError -Text $Text -ArtifactType 'evidence-reference' -PowerShellVersion $script:Supported
            @($schema).Count | Should -Be 1
            $schema[0] | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED:*evidence-reference*'
            $dispatch = Get-DiscoveryArtifactValidationError -ArtifactType 'evidence-reference' -Text $Text -PowerShellVersion $script:Supported
            @($dispatch).Count | Should -Be 1
            (ConvertTo-DiscoveryValidationResult -ValidationError $dispatch).ExitCode | Should -Be 1
        }

        It 'reports an unrecognized artifact type before the validation-required message' {
            $errors = Get-DiscoveryArtifactValidationError -ArtifactType 'mystery' -Text '{}' -PowerShellVersion $script:Supported
            @($errors).Count | Should -Be 2
            $errors[0] | Should -Be "Unrecognized discovery artifact type 'mystery'."
            $errors[1] | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED:*'
        }

        It 'keeps the D-2 result shape for caller-assembled lists' {
            $pass = ConvertTo-DiscoveryValidationResult -ValidationError @()
            $pass.ExitCode | Should -Be 0
            $pass.Output | Should -Be ''
            $fail = ConvertTo-DiscoveryValidationResult -ValidationError @('a', 'b')
            $fail.ExitCode | Should -Be 1
            $fail.Output | Should -Be ('a' + [System.Environment]::NewLine + 'b')
        }
    }

    Context 'Invoke-DiscoveryArtifactValidation cannot mint a passing gate' {
        It 'returns exit code 1 with the validation-required message for an existing conforming artifact' {
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs @('evidence-reference', 'docs/migration/discovery/evidence-reference.json') -PowerShellVersion $script:Supported -TestArtifactPath { $true }
            $result.ExitCode | Should -Be 1
            $result.Output | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED: the evidence-reference artifact at docs/migration/discovery/evidence-reference.json is validated only by*'
            @($result.Keys | Sort-Object) | Should -Be @('ExitCode', 'Output')
        }

        It 'reports <Name> with exit code 1' -ForEach @(
            @{ Name = 'a missing artifact path'; Arguments = @('evidence-reference', 'docs/missing.json'); Exists = $false; Text = 'Artifact not found: docs/missing.json' }
            @{ Name = 'insufficient validator arguments'; Arguments = @('evidence-reference'); Exists = $true; Text = 'Discovery validation requires an artifact type and a path.' }
            @{ Name = 'no validator arguments'; Arguments = @(); Exists = $true; Text = 'Discovery validation requires an artifact type and a path.' }
        ) {
            $exists = $Exists
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs $Arguments -PowerShellVersion $script:Supported -TestArtifactPath { $exists }.GetNewClosure()
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Be $Text
        }

        It 'reports the floor before anything else on an unsupported host' {
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs @('evidence-reference', 'x.json') -PowerShellVersion ([version]'7.3.0') -TestArtifactPath { $true }
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'PowerShell 7\.4'
        }

        It 'reads no artifact bytes and never returns a passing result whatever the document' {
            $probe = { param([string]$Candidate) $script:Probed = $Candidate; $true }
            $result = Invoke-DiscoveryArtifactValidation -ValidatorArgs @('coverage-ledger', $script:ConformingDocument) -PowerShellVersion $script:Supported -TestArtifactPath $probe
            $result.ExitCode | Should -Be 1
            $script:Probed | Should -Be $script:ConformingDocument
            # Source assertion: no schema evaluation, no artifact read, no interpreter. The floor message may quote
            # 'Test-Json -SchemaFile' as its reason, so only an invocation shape (a parameter followed by an argument) is rejected.
            $source = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryValidation.psm1'))
            $source | Should -Not -MatchExactly 'Test-Json\s+-(Json|SchemaFile)\s+\$|Get-Content|ReadAllText|ReadAllBytes|ConvertFrom-Json|ConvertFrom-Yaml|python|poetry'
        }
    }

    Context 'Get-DiscoveryValidationAuthority' {
        It 'reports <Status> for <Name> and directs to the service' -ForEach @(
            @{ Name = 'an active workspace'; Status = 'active'; Supported = $true; Store = @{} }
            @{ Name = 'a workspace without an activation'; Status = 'missing'; Supported = $false; Store = @{ NoActivation = $true } }
            @{ Name = 'a deactivated workspace'; Status = 'inactive'; Supported = $false; Store = @{ ActivationAction = 'deactivate' } }
        ) {
            $store = Get-GateStore @Store
            $authority = Get-DiscoveryValidationAuthority -WorkspaceRoot $script:GateWorkspaceRoot -HostEnvironment $script:GateHostEnvironment -ReadText $store.ReadText
            $authority.Status | Should -Be $Status
            $authority.Supported | Should -Be $Supported
            $authority.Service | Should -Be 'validate_discovery_artifacts'
            $authority.Directory | Should -Be $script:GateLocation.Directory
            $authority.Message | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED:*'
        }

        It 'reports an unreadable activation as invalid and a host that cannot resolve authority as unsupported' {
            $store = Get-GateStore
            $store.Files[(Get-DiscoveryActivationRecordPath -Location $script:GateLocation)] = '{"action":"activate"}'
            (Get-DiscoveryValidationAuthority -WorkspaceRoot $script:GateWorkspaceRoot -HostEnvironment $script:GateHostEnvironment -ReadText $store.ReadText).Status | Should -Be 'invalid'
            $unsupported = Get-DiscoveryValidationAuthority -WorkspaceRoot $script:GateWorkspaceRoot -HostEnvironment @{ Platform = 'windows'; UserHome = 'C:/Users/Example'; LocalAppData = ''; XdgStateHome = $null }
            $unsupported.Status | Should -Be 'unsupported-host'
            $unsupported.Supported | Should -BeFalse
            $unsupported.Message | Should -BeLike 'DISCOVERY_VALIDATION_REQUIRED:*fail-closed*'
        }
    }
}
