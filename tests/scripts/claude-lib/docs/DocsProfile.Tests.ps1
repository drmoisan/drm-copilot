#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsProfile.psm1.

.DESCRIPTION
    Covers profile parsing and schema validation, each semantic finding at its pointer, the
    starter profile for several repository identifiers, and the audience identifier pattern.
    Profiles are in-memory variants of the committed example; schemas are the committed runtime
    copies read through Docs.TestSupport.psm1. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ExampleProfile = (Get-DocsTestExampleText)['docs-profile']

    function Get-TestProfile {
        (ConvertFrom-DocsJsonText -Text $script:ExampleProfile).Value
    }

    function Invoke-TestProfile {
        param([object] $Value, [string[]] $AnalyzerId)
        $text = if ($Value -is [string]) { $Value } else { ConvertTo-DocsJsonText -Value $Value }
        if ($PSBoundParameters.ContainsKey('AnalyzerId')) {
            return ConvertFrom-DocsProfileText -Text $text -ArtifactPath 'docs/documentation-estate/docs-profile.json' -ComposedSchemaSet $script:Composed -AnalyzerId $AnalyzerId
        }
        ConvertFrom-DocsProfileText -Text $text -ArtifactPath 'docs/documentation-estate/docs-profile.json' -ComposedSchemaSet $script:Composed
    }
}

AfterAll {
    Remove-Module -Name DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsDefaultProfilePath' {
    It 'returns the repository-relative default profile path' {
        Get-DocsDefaultProfilePath | Should -BeExactly 'docs/documentation-estate/docs-profile.json'
    }
}

Describe 'ConvertFrom-DocsProfileText' {
    It 'accepts the example profile with no finding' {
        # Act
        $result = Invoke-TestProfile -Value $script:ExampleProfile

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        $result.Profile['repository']['id'] | Should -BeExactly 'example-repo'
    }

    It 'rejects <Case> with <Code> and no profile' -ForEach @(
        @{ Case = 'empty text'; Text = ''; Code = 'DOCS_JSON_INVALID' }
        @{ Case = 'invalid JSON'; Text = '{"a":'; Code = 'DOCS_JSON_INVALID' }
        @{ Case = 'a repeated member'; Text = '{"id":"a","id":"b"}'; Code = 'DOCS_JSON_DUPLICATE_KEY' }
    ) {
        # Act
        $result = Invoke-TestProfile -Value $Text

        # Assert
        $result.Ok | Should -BeFalse
        $result.Profile | Should -BeNullOrEmpty
        $result.Findings[0].code | Should -BeExactly $Code
    }

    It 'reports <Code> at <Pointer>' -ForEach @(
        @{ Code = 'DOCS_PROFILE_AUDIENCE_DUPLICATE'; Pointer = '/audiences/1/id'; Mutate = { param($p) $p['audiences'][1]['id'] = 'maintainers' } }
        @{ Code = 'DOCS_PROFILE_ROOT_DUPLICATE'; Pointer = '/documentation_roots/1/id'; Mutate = { param($p) $p['documentation_roots'] = @($p['documentation_roots'][0], [ordered]@{ id = 'docs-root'; path = 'guides'; audience_ids = @('maintainers') }) } }
        @{ Code = 'DOCS_PROFILE_ROOT_DUPLICATE'; Pointer = '/documentation_roots/1/path'; Mutate = { param($p) $p['documentation_roots'] = @($p['documentation_roots'][0], [ordered]@{ id = 'other-root'; path = 'docs'; audience_ids = @('maintainers') }) } }
        @{ Code = 'DOCS_PROFILE_AUDIENCE_UNKNOWN'; Pointer = '/documentation_roots/0/audience_ids/1'; Mutate = { param($p) $p['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators') } }
        @{ Code = 'DOCS_PROFILE_MODE_NOT_IN_POLICY'; Pointer = '/diataxis_policy/directory_modes/1/mode'; Mutate = { param($p) $p['diataxis_policy']['modes'] = @('tutorial', 'reference', 'explanation') } }
        @{ Code = 'DOCS_ANALYZER_UNKNOWN'; Pointer = '/surface_selection/analyzers/0'; Mutate = { param($p) $p['surface_selection']['analyzers'] = @('unregistered-analyzer') } }
    ) {
        # Arrange
        $value = Get-TestProfile
        & $Mutate $value

        # Act
        $result = Invoke-TestProfile -Value $value

        # Assert
        $result.Ok | Should -BeFalse
        @($result.Findings | Where-Object { $_.code -eq $Code -and $_.pointer -eq $Pointer -and $_.severity -eq 'error' }).Count | Should -Be 1
    }

    It 'accepts a selected analyzer that is in AnalyzerId' {
        # Arrange
        $value = Get-TestProfile
        $value['surface_selection']['analyzers'] = @('known-analyzer')

        # Act
        $result = Invoke-TestProfile -Value $value -AnalyzerId @('known-analyzer')

        # Assert
        $result.Ok | Should -BeTrue
    }
}

Describe 'New-DocsStarterProfile' {
    It 'returns a profile accepted with no finding for repository id <_>' -ForEach @('repository', 'example-repo', 'a', 'docs.site_2') {
        # Act
        $starter = New-DocsStarterProfile -RepositoryId $_
        $result = Invoke-TestProfile -Value $starter

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        $starter['repository']['id'] | Should -BeExactly $_
        $starter['surface_selection'].Contains('analyzers') | Should -BeFalse
        $starter['completion_gates']['integration_pr_gate']['enabled'] | Should -BeFalse
    }

    It 'uses the default repository id' {
        (New-DocsStarterProfile)['repository']['id'] | Should -BeExactly 'repository'
    }

    It 'defaults the documentation root to docs/guide with id guide and the source root to src, and holds no root under docs/features/ (issue #1173 B6, B7)' {
        # Act
        $starter = New-DocsStarterProfile

        # Assert
        @($starter['documentation_roots']).Count | Should -Be 1
        $starter['documentation_roots'][0]['id'] | Should -BeExactly 'guide'
        $starter['documentation_roots'][0]['path'] | Should -BeExactly 'docs/guide'
        @($starter['documentation_roots'] | Where-Object { ([string] $_['path']).StartsWith('docs/features', [System.StringComparison]::Ordinal) }).Count | Should -Be 0
        @($starter['surface_selection']['source_roots']) | Should -Be @('src')
    }

    It 'honors -SourceRoot and -DocumentationRoot and stays accepted with no finding' {
        # Act
        $starter = New-DocsStarterProfile -RepositoryId 'repo' -SourceRoot @('my_pkg', 'lib') -DocumentationRoot 'handbook/user'
        $result = Invoke-TestProfile -Value $starter

        # Assert
        @($starter['surface_selection']['source_roots']) | Should -Be @('my_pkg', 'lib')
        $starter['documentation_roots'][0]['path'] | Should -BeExactly 'handbook/user'
        $starter['documentation_roots'][0]['id'] | Should -BeExactly 'guide'
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
    }
}

Describe 'Audience identifiers' {
    It 'rejects the audience id <Id>' -ForEach @(
        @{ Id = 'Readers' }
        @{ Id = 'docs.v2' }
        @{ Id = 'a_b' }
        @{ Id = '-x' }
        @{ Id = "readers`n" }
    ) {
        # Arrange
        $value = Get-TestProfile
        $value['audiences'][0]['id'] = $Id
        $value['documentation_roots'][0]['audience_ids'] = @($Id, 'end-users')

        # Act
        $result = Invoke-TestProfile -Value $value

        # Assert
        $result.Ok | Should -BeFalse
        @($result.Findings | Where-Object { $_.severity -eq 'error' }).Count | Should -BeGreaterThan 0
    }

    It 'accepts the audience id <_>' -ForEach @('2nd-line', 'maintainers') {
        # Arrange
        $value = Get-TestProfile
        $value['audiences'][0]['id'] = $_
        $value['documentation_roots'][0]['audience_ids'] = @($_, 'end-users')

        # Act
        $result = Invoke-TestProfile -Value $value

        # Assert
        $result.Ok | Should -BeTrue
    }
}
