#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsExtensionShape.psm1 (extension-result manifest shapes).

.DESCRIPTION
    Record access without array unrolling, closed key sets, JSON array and size tests, the
    physical line count, the discovery diagnostics shape, and the step-1 structural check of
    a parsed manifest with one mutation per field class. Inputs are built in memory; no file
    is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsExtensionShape.psm1') -Force -ErrorAction Stop

    function Get-TestManifest {
        # Returns the parsed root of the valid in-memory manifest after an optional mutation.
        param([scriptblock] $Mutate)
        $fixture = New-DocsTestExtensionManifest
        $parsed = (ConvertFrom-DocsJsonText -Text $fixture['ManifestText'])['Value']
        if ($null -ne $Mutate) { & $Mutate $parsed }
        $parsed
    }
}

AfterAll {
    Remove-Module -Name DocsExtensionShape, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsExtensionValue' {
    It 'returns dictionary and object members, keeps an array member whole and yields null elsewhere' {
        # Arrange
        $table = [ordered]@{ one = @([ordered]@{ a = 1 }); text = 'value'; none = $null }
        $record = [pscustomobject]@{ items = @(1, 2); name = 'n' }

        # Act / Assert
        # The parenthesized form reads the returned array itself; @(...) would wrap it as one item.
        (Get-DocsExtensionValue -Record $table -Name 'one') -is [System.Collections.IList] | Should -BeTrue
        (Get-DocsExtensionValue -Record $table -Name 'one').Count | Should -Be 1
        Get-DocsExtensionValue -Record $table -Name 'text' | Should -Be 'value'
        Get-DocsExtensionValue -Record $table -Name 'none' | Should -BeNullOrEmpty
        Get-DocsExtensionValue -Record $table -Name 'absent' | Should -BeNullOrEmpty
        (Get-DocsExtensionValue -Record $record -Name 'items').Count | Should -Be 2
        (Get-DocsExtensionValue -Record ([ordered]@{ empty = @() }) -Name 'empty').Count | Should -Be 0
        Get-DocsExtensionValue -Record $record -Name 'name' | Should -Be 'n'
        Get-DocsExtensionValue -Record $record -Name 'absent' | Should -BeNullOrEmpty
        Get-DocsExtensionValue -Record $null -Name 'x' | Should -BeNullOrEmpty
        Get-DocsExtensionValue -Record 'text' -Name 'Length' | Should -BeNullOrEmpty
        Get-DocsExtensionValue -Record @(1, 2) -Name 'Count' | Should -BeNullOrEmpty
    }
}

Describe 'Shape predicates' {
    It 'tests closed key sets, JSON arrays and sizes' {
        # Act / Assert
        Test-DocsExtensionKeySet -Record ([ordered]@{ id = 1; version = 2 }) -Key @('id', 'version') | Should -BeTrue
        Test-DocsExtensionKeySet -Record ([ordered]@{ id = 1 }) -Key @('id', 'version') | Should -BeFalse
        Test-DocsExtensionKeySet -Record ([ordered]@{ id = 1; other = 2 }) -Key @('id', 'version') | Should -BeFalse
        Test-DocsExtensionKeySet -Record 'text' -Key @('id') | Should -BeFalse
        Test-DocsExtensionArray -Value @() | Should -BeTrue
        Test-DocsExtensionArray -Value @(1) | Should -BeTrue
        Test-DocsExtensionArray -Value 'text' | Should -BeFalse
        Test-DocsExtensionArray -Value $null | Should -BeFalse
        Test-DocsExtensionArray -Value ([ordered]@{}) | Should -BeFalse
        Test-DocsExtensionSize -Value ([long] 0) | Should -BeTrue
        Test-DocsExtensionSize -Value 7 | Should -BeTrue
        Test-DocsExtensionSize -Value ([long] -1) | Should -BeFalse
        Test-DocsExtensionSize -Value 1.5 | Should -BeFalse
        Test-DocsExtensionSize -Value '7' | Should -BeFalse
    }
}

Describe 'Get-DocsExtensionLineCount' {
    It 'counts physical lines for <Case>' -ForEach @(
        @{ Case = 'null text'; Text = $null; Expected = 0 }
        @{ Case = 'empty text'; Text = ''; Expected = 0 }
        @{ Case = 'one line without a newline'; Text = 'a'; Expected = 1 }
        @{ Case = 'one line with a newline'; Text = "a`n"; Expected = 1 }
        @{ Case = 'three LF lines'; Text = "a`nb`nc`n"; Expected = 3 }
        @{ Case = 'three CRLF lines'; Text = "a`r`nb`r`nc`r`n"; Expected = 3 }
        @{ Case = 'a trailing line without a newline'; Text = "a`nb"; Expected = 2 }
    ) {
        Get-DocsExtensionLineCount -Text $Text | Should -Be $Expected
    }
}

Describe 'Get-DocsExtensionDiagnosticProblem' {
    It 'accepts a well-formed discovery diagnostics array and an empty one' {
        $entry = [ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'warning'; path = 'src/a.rb'; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{ 'ruby.detail' = 1 } }
        Get-DocsExtensionDiagnosticProblem -Value @($entry) | Should -BeNullOrEmpty
        Get-DocsExtensionDiagnosticProblem -Value @() | Should -BeNullOrEmpty
    }

    It 'reports <Case>' -ForEach @(
        @{ Case = 'a non-array'; Value = 'text'; Expected = 'member diagnostics is not an array' }
        @{ Case = 'an unexpected key set'; Value = @([ordered]@{ id = 'diag-1' }); Expected = 'diagnostics entry 0 has an unexpected key set' }
        @{ Case = 'an invalid code'; Value = @([ordered]@{ id = 'diag-1'; code = 'RUBY'; severity = 'warning'; path = $null; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{} }); Expected = 'diagnostics entry 0 has an invalid code' }
        @{ Case = 'an invalid path'; Value = @([ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'warning'; path = '/abs'; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{} }); Expected = 'diagnostics entry 0 has an invalid path' }
        @{ Case = 'a blank message'; Value = @([ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'warning'; path = $null; message = ' '; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{} }); Expected = 'diagnostics entry 0 has a blank message' }
        @{ Case = 'a non-boolean blocking flag'; Value = @([ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'warning'; path = $null; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = 'yes'; extensions = [ordered]@{} }); Expected = 'diagnostics entry 0 has a non-boolean blocking flag' }
        @{ Case = 'invalid extensions'; Value = @([ordered]@{ id = 'diag-1'; code = 'ruby-warning'; severity = 'warning'; path = $null; message = 'm'; analyzer_id = 'ruby-adapter'; blocking = $false; extensions = [ordered]@{ plain = 1 } }); Expected = 'diagnostics entry 0 has invalid extensions' }
    ) {
        Get-DocsExtensionDiagnosticProblem -Value $Value | Should -Be $Expected
    }
}

Describe 'Get-DocsExtensionShapeProblem' {
    It 'returns null for the valid parsed manifest' {
        Get-DocsExtensionShapeProblem -Manifest (Get-TestManifest) -KnownManifestId @('other-run') | Should -BeNullOrEmpty
    }

    It 'reports <Case>' -ForEach @(
        @{ Case = 'a non-object root'; Mutate = $null; Root = 'text'; Expected = 'the root key set is not the closed manifest key set' }
        @{ Case = 'a missing member'; Mutate = { param($m) $m.Remove('diagnostics') }; Expected = 'the root key set is not the closed manifest key set' }
        @{ Case = 'another $schema'; Mutate = { param($m) $m['$schema'] = 'urn:other' }; Expected = 'member $schema is not the extension-result-manifest schema' }
        @{ Case = 'an id that is not an identifier'; Mutate = { param($m) $m['id'] = 'Run One' }; Expected = 'member id is not an identifier' }
        @{ Case = 'a repeated id'; Mutate = $null; Known = @('ruby-adapter-run'); Expected = 'member id repeats the id of an earlier selected manifest' }
        @{ Case = 'an adapter id that is not an identifier'; Mutate = { param($m) $m['adapter']['id'] = 'Ruby' }; Expected = 'member adapter.id is not an identifier' }
        @{ Case = 'a blank adapter version'; Mutate = { param($m) $m['adapter']['version'] = '' }; Expected = 'member adapter.version is blank' }
        @{ Case = 'a repository with an extra key'; Mutate = { param($m) $m['repository']['extra'] = 1 }; Expected = 'member repository has an unexpected key set' }
        @{ Case = 'a repository id that is not an identifier'; Mutate = { param($m) $m['repository']['id'] = 'Repo' }; Expected = 'member repository.id is not an identifier' }
        @{ Case = 'an input_manifest_sha256 that is not a digest'; Mutate = { param($m) $m['input_manifest_sha256'] = 'xyz' }; Expected = 'member input_manifest_sha256 is not a sha256' }
        @{ Case = 'source_inputs that is not an array'; Mutate = { param($m) $m['source_inputs'] = 'text' }; Expected = 'member source_inputs is not an array' }
        @{ Case = 'a source input with an invalid path'; Mutate = { param($m) $m['source_inputs'][0]['path'] = '../x' }; Expected = 'source_inputs entry 0 has an invalid path' }
        @{ Case = 'a source input with an invalid sha256'; Mutate = { param($m) $m['source_inputs'][0]['sha256'] = 'ABC' }; Expected = 'source_inputs entry 0 has an invalid sha256' }
        @{ Case = 'a result file with an invalid id'; Mutate = { param($m) $m['result_files'][0]['id'] = 'Bad Id' }; Expected = 'result_files entry 0 has an invalid id' }
        @{ Case = 'a result file with another schema_version'; Mutate = { param($m) $m['result_files'][0]['schema_version'] = '1.0.0' }; Expected = 'result_files entry 0 has an unexpected schema_version' }
        @{ Case = 'a manifest_sha256 that is not a digest'; Mutate = { param($m) $m['manifest_sha256'] = 'xyz' }; Expected = 'member manifest_sha256 is not a sha256' }
        @{ Case = 'a generated_by with an extra key'; Mutate = { param($m) $m['generated_by']['extra'] = 1 }; Expected = 'member generated_by has an unexpected key set' }
        @{ Case = 'a generated_by id that is not an identifier'; Mutate = { param($m) $m['generated_by']['id'] = 'Tool' }; Expected = 'member generated_by.id is not an identifier' }
        @{ Case = 'extensions that is not an object'; Mutate = { param($m) $m['extensions'] = @() }; Expected = 'member extensions is not a namespaced table' }
    ) {
        # Arrange
        $manifest = if ($_.ContainsKey('Root')) { $Root } else { Get-TestManifest -Mutate $Mutate }
        $known = if ($_.ContainsKey('Known')) { [string[]] $Known } else { [string[]] @() }

        # Act / Assert
        Get-DocsExtensionShapeProblem -Manifest $manifest -KnownManifestId $known | Should -Be $Expected
    }
}
