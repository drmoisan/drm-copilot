#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 (extension-import).

.DESCRIPTION
    Validation: a valid manifest built in memory (manifest_sha256 computed by
    ConvertTo-DocsCanonicalJson and Get-DocsSha256Hex) is accepted; a selection without
    repository_id or revision yields exactly the two non-blocking unverified diagnostics; one
    mutation per validation step yields exactly one blocking diagnostic with that step's code.
    Merge: findings become inert elements with recomputed identifiers and digests, only
    value_type is copied for config-key, unmappable findings yield one unmarked
    EXTENSION_FINDING_SKIPPED, and the registry import inside the function does not re-enter
    the registry seam. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerExtensionImport.psm1') -Force -ErrorAction Stop

    $script:RepositoryId = 'example-repo'
    $script:Revision = 'a' * 40
    $script:Selection = @{ repository_id = $script:RepositoryId; revision = $script:Revision }
    $script:MergeSelection = @{ repository_id = $script:RepositoryId; revision = $script:Revision; registered_analyzer_ids = @('typescript-cli', 'dotnet-config') }
    $script:SourcePath = 'src/other/service.rb'
    $script:ManifestPath = 'discovery/extensions/ruby-adapter.manifest.json'
    $script:ModulePath = [System.IO.Path]::GetFullPath((Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerExtensionImport.psm1'))

    function New-TestFinding {
        # Builds one finding against the default fixture identities; Kind, Symbol, LineRange and Property vary per case.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([object] $Source, [string] $FindingId, [string] $Kind, [AllowNull()] [string] $Symbol, [AllowNull()] [int[]] $LineRange, [AllowNull()] [System.Collections.IDictionary] $Property)
        New-DocsTestFinding -FindingId $FindingId -Kind $Kind -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol $Symbol -LineRange $LineRange -Property $Property
    }

    function Get-TestElementProperty {
        param([System.Collections.IDictionary] $Element, [string] $Name)
        $found = @($Element['properties'] | Where-Object { [string] $_['name'] -ceq $Name })
        if ($found.Count -eq 0) { return $null }
        $found[0]['value']
    }

    function Get-TestDiagnostic {
        param([object[]] $Diagnostic, [string] $Code)
        $found = @($Diagnostic | Where-Object { [string] $_['code'] -ceq $Code })
        $found.Count | Should -Be 1 -Because "exactly one '$Code' diagnostic is expected"
        $found[0]
    }

    function Invoke-TestValidation {
        # Builds the fixture from the case table and validates it; Case keys select the mutation.
        param([hashtable] $Case)
        $builder = @{}
        foreach ($name in 'MutateManifest', 'MutateManifestAfterDigest', 'MutateResult', 'Finding') { if ($Case.ContainsKey($name)) { $builder[$name] = $Case[$name] } }
        $fixture = New-DocsTestExtensionManifest @builder
        $captured = @($fixture['CapturedInput'])
        if ($Case.ContainsKey('DropSource')) { $captured = @($captured | Where-Object { [string] $_['path'] -cne $script:SourcePath }) }
        $text = if ($Case.ContainsKey('ManifestText')) { [string] $Case['ManifestText'] } else { [string] $fixture['ManifestText'] }
        $selection = if ($Case.ContainsKey('Selection')) { $Case['Selection'] } else { $script:Selection }
        $registered = if ($Case.ContainsKey('Registered')) { [string[]] $Case['Registered'] } else { [string[]] @('typescript-cli', 'dotnet-config') }
        $known = @{}
        foreach ($name in 'KnownManifestId', 'KnownAdapterId') { if ($Case.ContainsKey($name)) { $known[$name] = [string[]] $Case[$name] } }
        Test-DocsExtensionManifest -ManifestText $text -ManifestPath $fixture['ManifestPath'] -CapturedInput $captured -Selection $selection -RegisteredAnalyzerId $registered @known
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerExtensionImport, DocsExtensionShape, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Test-DocsExtensionManifest' {
    Context 'validation' {
        It 'accepts a valid manifest with a matching selection and returns the parsed documents' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest

            # Act
            $result = Test-DocsExtensionManifest -ManifestText $fixture['ManifestText'] -ManifestPath $fixture['ManifestPath'] -CapturedInput $fixture['CapturedInput'] -Selection $script:Selection -RegisteredAnalyzerId @('typescript-cli')

            # Assert
            $result['Ok'] | Should -BeTrue
            @($result['Diagnostics']).Count | Should -Be 0
            $result['Manifest']['id'] | Should -Be 'ruby-adapter-run'
            $result['Manifest']['input_manifest_sha256'] | Should -Be ('c' * 64)
            @($result['ResultDocument']).Count | Should -Be 1
            $result['ResultDocument'][0]['id'] | Should -Be 'ruby-adapter-inventory'
        }

        It 'accepts a valid manifest against a selection object with properties' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest
            $selection = [pscustomobject]@{ repository_id = $script:RepositoryId; revision = $script:Revision }

            # Act
            $result = Test-DocsExtensionManifest -ManifestText $fixture['ManifestText'] -ManifestPath $fixture['ManifestPath'] -CapturedInput $fixture['CapturedInput'] -Selection $selection -RegisteredAnalyzerId @()

            # Assert
            $result['Ok'] | Should -BeTrue
            @($result['Diagnostics']).Count | Should -Be 0
        }

        It 'accepts a valid manifest with a <Case> selection, emitting exactly the two unverified diagnostics' -ForEach @(
            @{ Case = 'empty'; Selection = @{} }
            @{ Case = 'null'; Selection = $null }
            @{ Case = 'null-valued'; Selection = @{ repository_id = $null; revision = $null } }
            @{ Case = 'non-dictionary'; Selection = 'selection' }
        ) {
            # Arrange
            $fixture = New-DocsTestExtensionManifest

            # Act
            $result = Test-DocsExtensionManifest -ManifestText $fixture['ManifestText'] -ManifestPath $fixture['ManifestPath'] -CapturedInput $fixture['CapturedInput'] -Selection $Selection -RegisteredAnalyzerId @('typescript-cli')

            # Assert
            $result['Ok'] | Should -BeTrue
            @($result['Diagnostics']).Count | Should -Be 2
            foreach ($code in 'EXTENSION_REPOSITORY_UNVERIFIED', 'EXTENSION_REVISION_UNVERIFIED') {
                $diagnostic = Get-TestDiagnostic -Diagnostic $result['Diagnostics'] -Code $code
                $diagnostic['blocking'] | Should -BeFalse
                $diagnostic['severity'] | Should -Be 'warning'
                $diagnostic['path'] | Should -Be $fixture['ManifestPath']
                $diagnostic['analyzer_id'] | Should -Be 'extension-import'
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            @($result['ResultDocument']).Count | Should -Be 1
        }

        It 'accepts a manifest with no result file when a blocking manifest diagnostic exists' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -MutateManifest {
                param($Manifest)
                $Manifest['result_files'] = @()
                $Manifest['diagnostics'] = @([ordered]@{ id = 'diag-ruby-failed'; code = 'ruby-parse-failed'; severity = 'error'; path = $null; message = 'The adapter could not parse its inputs.'; analyzer_id = 'ruby-adapter'; blocking = $true; extensions = [ordered]@{} })
            }

            # Act
            $result = Test-DocsExtensionManifest -ManifestText $fixture['ManifestText'] -ManifestPath $fixture['ManifestPath'] -CapturedInput $fixture['CapturedInput'] -Selection $script:Selection -RegisteredAnalyzerId @()

            # Assert
            $result['Ok'] | Should -BeTrue
            @($result['Diagnostics']).Count | Should -Be 0
            @($result['ResultDocument']).Count | Should -Be 0
        }

        It 'rejects <Case> with exactly one blocking <Code>' -ForEach @(
            @{ Case = 'an unparseable manifest text'; Code = 'EXTENSION_MANIFEST_INVALID'; ManifestText = '{ "id": ' }
            @{ Case = 'an empty manifest text'; Code = 'EXTENSION_MANIFEST_INVALID'; ManifestText = '' }
            @{ Case = 'a manifest whose root is an array'; Code = 'EXTENSION_MANIFEST_INVALID'; ManifestText = '[]' }
            @{ Case = 'an extra root member'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['extra'] = 'x' } }
            @{ Case = 'a wrong schema_version'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['schema_version'] = '1.0.0' } }
            @{ Case = 'a wrong artifact_kind'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['artifact_kind'] = 'inventory-snapshot' } }
            @{ Case = 'an adapter with an extra key'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['adapter']['extra'] = 'x' } }
            @{ Case = 'a repository revision that is not full'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['repository']['revision'] = 'abc' } }
            @{ Case = 'a source input with a negative size'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['source_inputs'][0]['size'] = [long] -1 } }
            @{ Case = 'a repeated source input'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['source_inputs'] = @($Manifest['source_inputs'][0], $Manifest['source_inputs'][0]) } }
            @{ Case = 'a result file with another artifact_kind'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['result_files'][0]['artifact_kind'] = 'source-snapshot-manifest' } }
            @{ Case = 'a generated_at that is not a timestamp'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['generated_at'] = 'yesterday' } }
            @{ Case = 'a generated_by kind outside the enumeration'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['generated_by']['kind'] = 'robot' } }
            @{ Case = 'a manifest diagnostic with an invalid severity'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['diagnostics'] = @([ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'loud'; path = $null; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{} }) } }
            @{ Case = 'an extensions key without a namespace'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['extensions']['plain'] = 'x' } }
            @{ Case = 'a docs.analysis-method outside the analysis methods'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['extensions']['docs.analysis-method'] = 'guessed' } }
            @{ Case = 'a manifest with no result file and no blocking diagnostic'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifest = { param($Manifest) $Manifest['result_files'] = @() } }
            @{ Case = 'a fractional number in extensions (step 1 code)'; Code = 'EXTENSION_MANIFEST_INVALID'; MutateManifestAfterDigest = { param($Manifest) $Manifest['extensions']['docs.weight'] = 1.5 } }
            @{ Case = 'a manifest id already selected'; Code = 'EXTENSION_MANIFEST_INVALID'; KnownManifestId = @('ruby-adapter-run') }
            @{ Case = 'a manifest_sha256 that does not match'; Code = 'EXTENSION_MANIFEST_DIGEST_MISMATCH'; MutateManifestAfterDigest = { param($Manifest) $Manifest['generated_at'] = '2026-01-02T00:00:00Z' } }
            @{ Case = 'a repository id that differs from the selection'; Code = 'EXTENSION_REPOSITORY_MISMATCH'; Selection = @{ repository_id = 'other-repo'; revision = ('a' * 40) } }
            @{ Case = 'a revision that differs from the selection'; Code = 'EXTENSION_REPOSITORY_MISMATCH'; Selection = @{ repository_id = 'example-repo'; revision = ('b' * 40) } }
            @{ Case = 'an adapter id that is a registered analyzer'; Code = 'EXTENSION_ADAPTER_INVALID'; Registered = @('typescript-cli', 'ruby-adapter') }
            @{ Case = 'an adapter id already selected'; Code = 'EXTENSION_ADAPTER_INVALID'; KnownAdapterId = @('ruby-adapter') }
            @{ Case = 'a source input that is not captured'; Code = 'EXTENSION_INPUT_NOT_CAPTURED'; DropSource = $true }
            @{ Case = 'a source input whose sha256 differs from the captured input'; Code = 'EXTENSION_INPUT_DIGEST_MISMATCH'; MutateManifest = { param($Manifest) $Manifest['source_inputs'][0]['sha256'] = 'd' * 64 } }
            @{ Case = 'a source input whose size differs from the captured input'; Code = 'EXTENSION_INPUT_DIGEST_MISMATCH'; MutateManifest = { param($Manifest) $Manifest['source_inputs'][0]['size'] = [long] 7 } }
            @{ Case = 'a result file whose sha256 differs from the captured input'; Code = 'EXTENSION_RESULT_DIGEST_MISMATCH'; MutateManifest = { param($Manifest) $Manifest['result_files'][0]['sha256'] = 'd' * 64 } }
            @{ Case = 'a result file that is not captured'; Code = 'EXTENSION_RESULT_DIGEST_MISMATCH'; MutateManifest = { param($Manifest) $Manifest['result_files'][0]['path'] = 'discovery/extensions/missing.json' } }
            @{ Case = 'a result document with another id'; Code = 'EXTENSION_RESULT_INVALID'; MutateResult = { param($Result) $Result['id'] = 'other-inventory' } }
            @{ Case = 'a result document with another revision'; Code = 'EXTENSION_RESULT_INVALID'; MutateResult = { param($Result) $Result['revision'] = 'b' * 40 } }
            @{ Case = 'a result document whose tool differs from the adapter'; Code = 'EXTENSION_RESULT_INVALID'; MutateResult = { param($Result) $Result['tool']['version'] = '9.9.9' } }
            @{ Case = 'a result document with an empty analyzers list'; Code = 'EXTENSION_RESULT_INVALID'; MutateResult = { param($Result) $Result['analyzers'] = @() } }
            @{ Case = 'a result document whose findings member is not an array'; Code = 'EXTENSION_RESULT_INVALID'; MutateResult = { param($Result) $Result['findings'] = $null } }
            @{ Case = 'a finding whose analyzer differs from the adapter'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { param($Source) @(New-DocsTestFinding -FindingId 'finding-x' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '9.9.9' -Symbol 'Service.handle' -LineRange @(2, 2)) } }
            @{ Case = 'a finding whose source path is not a declared source input'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { param($Source) @(New-DocsTestFinding -FindingId 'finding-x' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/missing.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Service.handle' -LineRange @(2, 2)) } }
            @{ Case = 'a finding whose source sha256 differs from the declared source input'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { @(New-DocsTestFinding -FindingId 'finding-x' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 ('e' * 64) -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Service.handle' -LineRange @(2, 2)) } }
            @{ Case = 'a finding whose line_range ends beyond the captured text'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { param($Source) @(New-DocsTestFinding -FindingId 'finding-x' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Service.handle' -LineRange @(2, 99)) } }
            @{ Case = 'a finding whose line_range ends before it starts'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { param($Source) @(New-DocsTestFinding -FindingId 'finding-x' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Service.handle' -LineRange @(3, 2)) } }
            @{ Case = 'a finding that is not an object'; Code = 'EXTENSION_FINDING_SOURCE_MISMATCH'; Finding = { @('finding') } }
        ) {
            # Act
            $result = Invoke-TestValidation -Case $_

            # Assert
            $result['Ok'] | Should -BeFalse
            @($result['Diagnostics']).Count | Should -Be 1
            $diagnostic = $result['Diagnostics'][0]
            $diagnostic['code'] | Should -Be $Code
            $diagnostic['blocking'] | Should -BeTrue
            $diagnostic['severity'] | Should -Be 'error'
            $diagnostic['path'] | Should -Be 'discovery/extensions/ruby-adapter.manifest.json'
            $diagnostic['analyzer_id'] | Should -Be 'extension-import'
            $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            @($result['ResultDocument']).Count | Should -Be 0
        }

        It 'returns no parsed manifest for a step 1 rejection and the parsed manifest for a later one' {
            # Act
            $invalid = Invoke-TestValidation -Case @{ MutateManifest = { param($Manifest) $Manifest['extra'] = 'x' } }
            $mismatch = Invoke-TestValidation -Case @{ DropSource = $true }

            # Assert
            $invalid['Manifest'] | Should -BeNullOrEmpty
            $mismatch['Manifest']['id'] | Should -Be 'ruby-adapter-run'
        }

        It 'reports the first failing step only when several steps would fail' {
            # Arrange: repository mismatch (step 3) and an uncaptured source input (step 5a).
            $result = Invoke-TestValidation -Case @{ Selection = @{ repository_id = 'other-repo'; revision = ('a' * 40) }; DropSource = $true }

            # Assert
            @($result['Diagnostics']).Count | Should -Be 1
            $result['Diagnostics'][0]['code'] | Should -Be 'EXTENSION_REPOSITORY_MISMATCH'
        }
    }
}

Describe 'Invoke-DocsAnalyzerExtensionImport' {
    Context 'merge' {
        It 'takes the manifest schema URN and artifact kind from DocsExtensionShape and carries no copy of either literal' {
            # Arrange / Act: the module source is read as text; nothing is written.
            $moduleText = Get-Content -LiteralPath $script:ModulePath -Raw

            # Assert
            $moduleText.Contains('Get-DocsExtensionManifestIdentity') | Should -BeTrue -Because 'the values come from DocsExtensionShape.psm1'
            $moduleText.Contains('urn:drm-copilot:discovery') | Should -BeFalse -Because 'the schema URN has one source'
            $moduleText.Contains("'extension-result-manifest'") | Should -BeFalse -Because 'the artifact kind has one source'
        }

        It 'merges a mappable finding as an element with recomputed identity and digest and copied scalars' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Diagnostics']).Count | Should -Be 0
            @($output['Elements']).Count | Should -Be 1
            $element = $output['Elements'][0]
            $element['kind'] | Should -Be 'public-symbol'
            $element['path'] | Should -Be $script:SourcePath
            $element['declaration'] | Should -Be 'Service.handle'
            $element['name'] | Should -Be 'handle'
            $element['analyzer_id'] | Should -Be 'extension-import'
            $element['analysis_method'] | Should -Be 'scanner'
            $element['parent_id'] | Should -BeNullOrEmpty
            $element['element_id'] | Should -Be (Get-DocsElementId -Kind 'public-symbol' -Path $script:SourcePath -Declaration 'Service.handle')
            $element['source_sha256'] | Should -Be (Get-DocsDeclarationSha256 -Text $fixture['SourceText'] -LineRange @(2, 2))
            $element['line_range']['start'] | Should -Be 2
            $element['line_range']['end'] | Should -Be 2
            Get-TestElementProperty -Element $element -Name 'adapter_id' | Should -Be 'ruby-adapter'
            Get-TestElementProperty -Element $element -Name 'adapter_version' | Should -Be '1.2.3'
            Get-TestElementProperty -Element $element -Name 'classification' | Should -Be 'detected'
            Get-TestElementProperty -Element $element -Name 'confidence' | Should -Be 'high'
            Get-TestElementProperty -Element $element -Name 'finding_id' | Should -Be 'finding-handle'
            { ConvertFrom-DocsSurfaceElement -Record $element } | Should -Not -Throw
        }

        It 'copies only value_type for a config-key finding' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -Finding {
                param($Source)
                @(New-TestFinding -Source $Source -FindingId 'finding-key' -Kind 'config-key' -Symbol 'Logging.Level' -LineRange @(1, 1) -Property ([ordered]@{ name = 'Level'; value_type = 'string'; configured_value = 'SECRET_VALUE_q7z'; classification = 'inferred' }))
            }

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 1
            $element = $output['Elements'][0]
            $element['name'] | Should -Be 'Level'
            Get-TestElementProperty -Element $element -Name 'value_type' | Should -Be 'string'
            @($element['properties'] | ForEach-Object { [string] $_['name'] }) | Should -Be @('adapter_id', 'adapter_version', 'classification', 'confidence', 'finding_id', 'value_type')
            Get-TestElementProperty -Element $element -Name 'classification' | Should -Be 'detected'
            (ConvertTo-DocsTestOutputText -Output $output).Contains('SECRET_VALUE_q7z') | Should -BeFalse
        }

        It 'maps a cli-option with a parent_symbol and skips unmappable findings with one unmarked EXTENSION_FINDING_SKIPPED' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -Finding {
                param($Source)
                @(
                    (New-TestFinding -Source $Source -FindingId 'finding-port' -Kind 'cli-option' -Symbol 'tool serve --port' -LineRange @(3, 3) -Property ([ordered]@{ parent_symbol = 'tool serve' })),
                    (New-TestFinding -Source $Source -FindingId 'finding-other' -Kind 'cli-option' -Symbol 'tool serve --other' -LineRange @(3, 3) -Property ([ordered]@{ parent_symbol = 'tool serve'; parent_path = 'src/other/cli.rb' })),
                    (New-TestFinding -Source $Source -FindingId 'finding-orphan' -Kind 'cli-option' -Symbol 'tool serve --orphan' -LineRange @(3, 3)),
                    (New-TestFinding -Source $Source -FindingId 'finding-unknown' -Kind 'ruby-thing' -Symbol 'Thing' -LineRange @(1, 1)),
                    (New-TestFinding -Source $Source -FindingId 'finding-nosymbol' -Kind 'public-symbol' -LineRange @(1, 1)),
                    (New-TestFinding -Source $Source -FindingId 'finding-norange' -Kind 'public-symbol' -Symbol 'Service')
                )
            }

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 2
            $port = @($output['Elements'] | Where-Object { [string] $_['declaration'] -ceq 'tool serve --port' })[0]
            $port['parent_id'] | Should -Be (Get-DocsElementId -Kind 'cli-command' -Path $script:SourcePath -Declaration 'tool serve')
            $other = @($output['Elements'] | Where-Object { [string] $_['declaration'] -ceq 'tool serve --other' })[0]
            $other['parent_id'] | Should -Be (Get-DocsElementId -Kind 'cli-command' -Path 'src/other/cli.rb' -Declaration 'tool serve')
            @($output['Diagnostics']).Count | Should -Be 1
            $skipped = Get-TestDiagnostic -Diagnostic $output['Diagnostics'] -Code 'EXTENSION_FINDING_SKIPPED'
            $skipped['severity'] | Should -Be 'warning'
            $skipped['blocking'] | Should -BeFalse
            $skipped['path'] | Should -Be $script:ManifestPath
            $skipped['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            $skipped['message'] | Should -Be '4 finding(s) were not mapped to an element (kind-not-docs-element 1, line-range-missing 1, parent-symbol-missing 1, symbol-missing 1).'
        }

        It 'reads the analysis method from docs.analysis-method and defaults to scanner' {
            # Arrange
            $native = New-DocsTestExtensionManifest -ManifestExtension @{ 'docs.analysis-method' = 'native' }
            $plain = New-DocsTestExtensionManifest

            # Act
            $nativeOutput = Invoke-DocsAnalyzerExtensionImport -CapturedInput $native['CapturedInput'] -Selection $script:MergeSelection
            $plainOutput = Invoke-DocsAnalyzerExtensionImport -CapturedInput $plain['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            $nativeOutput['Elements'][0]['analysis_method'] | Should -Be 'native'
            $plainOutput['Elements'][0]['analysis_method'] | Should -Be 'scanner'
        }

        It 'rejects a source-input digest mismatch with exactly one blocking EXTENSION_INPUT_DIGEST_MISMATCH and no element' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -MutateManifest { param($Manifest) $Manifest['source_inputs'][0]['sha256'] = 'd' * 64 }

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 0
            @($output['Diagnostics']).Count | Should -Be 1
            $output['Diagnostics'][0]['code'] | Should -Be 'EXTENSION_INPUT_DIGEST_MISMATCH'
            $output['Diagnostics'][0]['blocking'] | Should -BeTrue
            $output['Diagnostics'][0]['path'] | Should -Be $script:ManifestPath
        }

        It 'copies manifest and result-document diagnostics under extension-import with mapped codes and blocking flags' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -MutateManifest {
                param($Manifest)
                $Manifest['diagnostics'] = @([ordered]@{ id = 'diag-warn'; code = 'ruby-warning'; severity = 'warning'; path = 'src/other/service.rb'; message = 'A warning from the adapter.'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{} })
            } -MutateResult {
                param($Result)
                $Result['diagnostics'] = @([ordered]@{ id = 'diag-parse'; code = 'ruby.parse-error'; severity = 'error'; path = $null; message = 'A parse error from the adapter.'; analyzer_id = 'ruby-adapter'; blocking = $true; extensions = [ordered]@{} })
            }

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 1
            @($output['Diagnostics']).Count | Should -Be 2
            $warning = Get-TestDiagnostic -Diagnostic $output['Diagnostics'] -Code 'RUBY_WARNING'
            $warning['blocking'] | Should -BeFalse
            $warning['path'] | Should -Be $script:SourcePath
            $warning['analyzer_id'] | Should -Be 'extension-import'
            $parse = Get-TestDiagnostic -Diagnostic $output['Diagnostics'] -Code 'RUBY_PARSE_ERROR'
            $parse['blocking'] | Should -BeTrue
            $parse['path'] | Should -BeNullOrEmpty
            [string[]] $ids = @($output['Diagnostics'] | ForEach-Object { [string] $_['id'] })
            [string[]] $sortedIds = $ids.Clone()
            [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sortedIds
        }

        It 'records DECLARATION_INVALID for a finding whose property name is not an identifier' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest -Finding {
                param($Source)
                @(New-TestFinding -Source $Source -FindingId 'finding-bad' -Kind 'public-symbol' -Symbol 'Service.bad' -LineRange @(2, 2) -Property ([ordered]@{ 'Bad Name' = 'x' }))
            }

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 0
            $invalid = Get-TestDiagnostic -Diagnostic $output['Diagnostics'] -Code 'DECLARATION_INVALID'
            $invalid['blocking'] | Should -BeFalse
            $invalid['path'] | Should -Be $script:SourcePath
            $invalid['extensions'].Contains('docs.precision-limit') | Should -BeFalse
        }

        It 'selects manifests by their parsed root and ignores other JSON inputs and an empty input set' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest
            $other = New-DocsTestCapturedInput -Path 'config/other.json' -Text '{ "artifact_kind": "extension-result-manifest", "note": "urn:drm-copilot:discovery:2.0.0:extension-result-manifest" }'
            $broken = New-DocsTestCapturedInput -Path 'config/broken.json' -Text '{ "$schema": "urn:drm-copilot:discovery:2.0.0:extension-result-manifest"'

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput (@($fixture['CapturedInput']) + @($other, $broken)) -Selection $script:MergeSelection
            $empty = Invoke-DocsAnalyzerExtensionImport -CapturedInput @() -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 1
            @($output['Diagnostics']).Count | Should -Be 0
            @($empty['Elements']).Count | Should -Be 0
            @($empty['Diagnostics']).Count | Should -Be 0
        }

        It 'rejects a second manifest that repeats the adapter and keeps the first' {
            # Arrange
            $first = New-DocsTestExtensionManifest
            $second = New-DocsTestExtensionManifest -ManifestId 'ruby-adapter-run-2' -ManifestPath 'discovery/extensions/second.manifest.json' -ResultPath 'discovery/extensions/second.inventory.json' -ResultId 'second-inventory' -SourcePath 'src/other/second.rb'

            # Act
            $output = Invoke-DocsAnalyzerExtensionImport -CapturedInput (@($first['CapturedInput']) + @($second['CapturedInput'])) -Selection $script:MergeSelection

            # Assert
            @($output['Elements']).Count | Should -Be 1
            $output['Elements'][0]['path'] | Should -Be $script:SourcePath
            @($output['Diagnostics']).Count | Should -Be 1
            $output['Diagnostics'][0]['code'] | Should -Be 'EXTENSION_ADAPTER_INVALID'
            $output['Diagnostics'][0]['path'] | Should -Be 'discovery/extensions/second.manifest.json'
        }

        It 'imports the registry inside the function when registered_analyzer_ids is absent and survives two calls through Invoke-DocsAnalyzer' {
            # Arrange
            $fixture = New-DocsTestExtensionManifest
            $row = [pscustomobject]@{ Id = 'extension-import'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component'); Module = $script:ModulePath; Function = 'Invoke-DocsAnalyzerExtensionImport' }
            # -Global makes the analyzer function resolvable from the registry module (the form of 1020's suite).
            $seam = { param($ModulePath) Import-Module -Name $ModulePath -Force -Global -ErrorAction Stop }

            # Act
            $first = Invoke-DocsAnalyzer -Registration $row -CapturedInput $fixture['CapturedInput'] -Selection $script:Selection -ImportModule $seam
            $secondRun = Invoke-DocsAnalyzer -Registration $row -CapturedInput $fixture['CapturedInput'] -Selection $script:Selection -ImportModule $seam
            $direct = Invoke-DocsAnalyzerExtensionImport -CapturedInput $fixture['CapturedInput'] -Selection $null

            # Assert
            @($first['Findings']).Count | Should -Be 0
            @($first['Elements']).Count | Should -Be 1
            @($secondRun['Findings']).Count | Should -Be 0
            @($secondRun['Elements']).Count | Should -Be 1
            @($direct['Elements']).Count | Should -Be 1
            @($direct['Diagnostics'] | ForEach-Object { [string] $_['code'] } | Sort-Object) | Should -Be @('EXTENSION_REPOSITORY_UNVERIFIED', 'EXTENSION_REVISION_UNVERIFIED')
            (Test-DocsAnalyzerRegistration -Registration (Get-DocsAnalyzerRegistration)).Count | Should -Be 0
        }
    }
}
