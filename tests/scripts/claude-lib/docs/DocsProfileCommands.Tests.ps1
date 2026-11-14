#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsProfileCommands.psm1.

.DESCRIPTION
    Covers the init template table (anchors and repository-relative sources, by membership),
    init planning and writing through the in-memory command context of Docs.TestSupport.psm1
    (dry run, create, existing target, overwrite, empty and non-empty templates), and
    validate-profile exit codes and findings. No file is read from or written to the repository
    by the commands under test.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:ModulePath = Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileCommands.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ExampleProfile = (Get-DocsTestExampleText)['docs-profile']
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    # The committed text of every default init template source, read read-only, so -Write tests can supply them in memory.
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:DefaultTemplateFiles = @{}
    $defaultRows = Get-DocsInitTemplate
    foreach ($row in $defaultRows) { $script:DefaultTemplateFiles[[string] $row.Source] = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepositoryRoot -ChildPath $row.Source)) }
    # Issue #1173 B6: an exit-0 init or validate-profile needs a listed file under every source root.
    $script:SourceFile = @{ 'src/app.py' = "value = 1`n" }

    function Join-TestFile {
        # Returns a new map holding every entry of the given maps; a later map wins on a repeated key.
        param([hashtable[]] $Map)
        $joined = @{}
        foreach ($item in $Map) { foreach ($key in $item.Keys) { $joined[$key] = $item[$key] } }
        return $joined
    }

    function New-TestProfileText {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([scriptblock] $Mutate)
        $value = (ConvertFrom-DocsJsonText -Text $script:ExampleProfile).Value
        if ($null -ne $Mutate) { & $Mutate $value }
        ConvertTo-DocsJsonText -Value $value
    }
}

AfterAll {
    Remove-Item -Path Function:\Join-TestFile -ErrorAction SilentlyContinue
    Remove-Module -Name DocsProfileCommands, DocsProfileSourceRoot, DocsTomlKeys, DocsSourceText, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsInitTemplate' {
    It 'carries the 1021 and 1034 anchors in order with no placeholder-numbered anchor' {
        # Arrange
        $text = Get-Content -LiteralPath $script:ModulePath -Raw
        $anchor1021 = $text.IndexOf('# --- 1021: page-check configuration ---', [System.StringComparison]::Ordinal)
        $anchor1034 = $text.IndexOf('# --- 1034: docs workflow ---', [System.StringComparison]::Ordinal)

        # Assert
        $anchor1021 | Should -BeGreaterThan 0
        $anchor1034 | Should -BeGreaterThan $anchor1021
        @($text -split "`n" | Where-Object { $_ -match '# --- 900[0-9]{3}:' }).Count | Should -Be 0
    }

    It 'returns only rows whose Source is repository-relative under .claude/lib/docs/templates/' {
        # Act
        $rows = Get-DocsInitTemplate

        # Assert (membership loop; no row-count assertion)
        foreach ($row in $rows) {
            Test-DocsRelativePath -Path $row.Source | Should -BeTrue
            $row.Source | Should -BeLike '.claude/lib/docs/templates/*'
        }
    }
}

Describe 'Invoke-DocsInitCommand' {
    BeforeAll {
        $script:EmptyTemplate = [pscustomobject]@{ Source = '.claude/lib/docs/templates/accept.txt'; Destination = 'docs-config/accept.txt' }
        $script:TextTemplate = [pscustomobject]@{ Source = '.claude/lib/docs/templates/x.txt'; Destination = 'docs-config/x.txt' }
        $script:TemplateFiles = @{ '.claude/lib/docs/templates/accept.txt' = ''; '.claude/lib/docs/templates/x.txt' = 'x'; 'src/app.py' = "value = 1`n" }
    }

    It 'lists a template destination with action create and writes nothing without -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:TemplateFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context $test.Context -TemplateRow @($script:EmptyTemplate)

        # Assert
        $result.ExitCode | Should -Be 0
        $test.WriteLog.Count | Should -Be 0
        @($result.Result.planned_writes | Where-Object { $_.path -eq 'docs-config/accept.txt' -and $_.action -eq 'create' }).Count | Should -Be 1
    }

    It 'writes an empty template as an empty file and a non-empty template with its text under -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:TemplateFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context -TemplateRow @($script:EmptyTemplate, $script:TextTemplate)

        # Assert
        $result.ExitCode | Should -Be 0
        $empty = @($test.WriteLog | Where-Object { $_.RelativePath -eq 'docs-config/accept.txt' })
        $empty.Count | Should -Be 1
        $empty[0].Text | Should -BeExactly ''
        @($test.WriteLog | Where-Object { $_.RelativePath -eq 'docs-config/x.txt' })[0].Text | Should -BeExactly 'x'
    }

    It 'reads an empty in-memory entry as a non-null empty string' {
        # Arrange
        $test = New-DocsTestContext -File $script:TemplateFiles

        # Act
        $text = & $test.Context.ReadText '.claude/lib/docs/templates/accept.txt'

        # Assert
        $null -eq $text | Should -BeFalse
        $text | Should -BeExactly ''
    }

    It 'returns a starter profile accepted by ConvertFrom-DocsProfileText for <_> and writes nothing without -Write' -ForEach @('repository', 'example-repo', 'a', 'docs.site_2') {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceFile

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ RepositoryId = $_ } -Context $test.Context
        $check = ConvertFrom-DocsProfileText -Text (ConvertTo-DocsJsonText -Value $result.Result.profile) -ArtifactPath $script:ProfilePath -ComposedSchemaSet $script:Composed

        # Assert
        $result.ExitCode | Should -Be 0
        $test.WriteLog.Count | Should -Be 0
        $check.Ok | Should -BeTrue
        $check.Findings.Count | Should -Be 0
    }

    It 'creates the profile with mode create under -Write' {
        # Arrange (the default template rows read their sources, so the context supplies them)
        $test = New-DocsTestContext -File (Join-TestFile -Map @($script:DefaultTemplateFiles, $script:SourceFile))

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context

        # Assert: the profile plus one write per default template row
        $result.ExitCode | Should -Be 0
        $test.WriteLog.Count | Should -Be (1 + $script:DefaultTemplateFiles.Count)
        $test.WriteLog[0].RelativePath | Should -BeExactly $script:ProfilePath
        $test.WriteLog[0].Mode | Should -BeExactly 'create'
    }

    It 'exits 1 with DOCS_INIT_TARGET_EXISTS and writes nothing when the target exists' {
        # Arrange
        $test = New-DocsTestContext -File @{ $script:ProfilePath = '{}'; 'src/app.py' = "value = 1`n" }

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        $result.Findings.Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_INIT_TARGET_EXISTS'
        $test.WriteLog.Count | Should -Be 0
        @($result.Result.planned_writes)[0].action | Should -BeExactly 'exists'
    }

    It 'overwrites the profile with mode overwrite under -Write -Force' {
        # Arrange
        $files = Join-TestFile -Map @(@{ $script:ProfilePath = '{}' }, $script:DefaultTemplateFiles, $script:SourceFile)
        $test = New-DocsTestContext -File $files

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true; Force = $true } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        $test.WriteLog[0].Mode | Should -BeExactly 'overwrite'
        $test.Files[$script:ProfilePath] | Should -Match '"artifact_kind": "docs-profile"'
    }

    It 'exits 2 with one DOCS_CLI_ARGUMENTS for <Case>' -ForEach @(
        @{ Case = 'an invalid repository id'; Argument = @{ RepositoryId = 'Bad Id' } }
        @{ Case = 'a non-relative profile path'; Argument = @{ Profile = '/abs/profile.json' } }
    ) {
        # Act
        $result = Invoke-DocsInitCommand -Argument $Argument -Context (New-DocsTestContext).Context

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Findings.Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
        $result.Result | Should -BeNullOrEmpty
    }

    It 'exits 3 with DOCS_CLI_RUNTIME for a template row whose Source is not repository-relative' {
        # Arrange
        $row = [pscustomobject]@{ Source = '/abs/template.txt'; Destination = 'docs-config/t.txt' }

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context (New-DocsTestContext).Context -TemplateRow @($row)

        # Assert
        $result.ExitCode | Should -Be 3
        $result.Findings[0].code | Should -BeExactly 'DOCS_CLI_RUNTIME'
    }

    It 'exits 1 with DOCS_PROFILE_SOURCE_ROOT_MISSING for the retained src root and still writes under -Write (issue #1173 B6)' {
        # Arrange (no src file, no pyproject.toml)
        $dry = New-DocsTestContext -File $script:DefaultTemplateFiles
        $written = New-DocsTestContext -File $script:DefaultTemplateFiles

        # Act
        $dryResult = Invoke-DocsInitCommand -Argument @{} -Context $dry.Context
        $writeResult = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $written.Context

        # Assert
        foreach ($result in @($dryResult, $writeResult)) {
            $result.ExitCode | Should -Be 1
            @($result.Findings | ForEach-Object { "$($_.code) $($_.pointer) $($_.artifact_path)" }) | Should -Be @("DOCS_PROFILE_SOURCE_ROOT_MISSING /surface_selection/source_roots/0 $($script:ProfilePath)")
            @($result.Result.profile['surface_selection']['source_roots']) | Should -Be @('src')
        }
        $dry.WriteLog.Count | Should -Be 0
        $written.WriteLog.Count | Should -Be (1 + $script:DefaultTemplateFiles.Count)
        $written.Files[$script:ProfilePath] | Should -Match '"src"'
    }

    It 'selects the pyproject.toml package directory when src lists no file and exits 0 (issue #1173 B6)' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'pyproject.toml' = "[project]`nname = `"my-app`"`n"; 'my_app/__init__.py' = '' }

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        @($result.Findings).Count | Should -Be 0
        @($result.Result.profile['surface_selection']['source_roots']) | Should -Be @('my_app')
        $result.Result.profile['documentation_roots'][0]['path'] | Should -BeExactly 'docs/guide'
    }
}

Describe 'Invoke-DocsValidateProfileCommand' {
    It 'exits 0 with no error finding for the example profile' {
        # Arrange (the example profile names the source roots src and config)
        $test = New-DocsTestContext -File @{ $script:ProfilePath = $script:ExampleProfile; 'src/example_pkg/a.py' = ''; 'config/settings.yaml' = '' }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{} -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        @($result.Findings | Where-Object { $_.severity -eq 'error' }).Count | Should -Be 0
        $result.Result.repository_id | Should -BeExactly 'example-repo'
        $result.Result.profile_path | Should -BeExactly $script:ProfilePath
    }

    It 'exits 1 with DOCS_SCHEMA_REQUIRED_MISSING at /audiences for a profile without audiences' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'p.json' = (New-TestProfileText -Mutate { param($p) $p.Remove('audiences') }) }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{ Profile = 'p.json' } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        $finding = @($result.Findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_REQUIRED_MISSING' -and $_.pointer -eq '/audiences' })
        $finding.Count | Should -Be 1
        $finding[0].message | Should -Match 'audiences'
        $result.Result | Should -BeNullOrEmpty
    }

    It 'exits 1 with DOCS_SCHEMA_VALUE_NOT_ALLOWED at the element_kinds item for an unknown element kind' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'p.json' = (New-TestProfileText -Mutate { param($p) $p['surface_selection']['element_kinds'][2] = 'widget' }) }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{ Profile = 'p.json' } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' -and $_.pointer -eq '/surface_selection/element_kinds/2' }).Count | Should -Be 1
    }

    It 'exits 1 with DOCS_JSON_DUPLICATE_KEY for a repeated member' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'p.json' = '{"id":"a","id":"b"}' }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{ Profile = 'p.json' } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_JSON_DUPLICATE_KEY'
    }

    It 'exits 1 with DOCS_PROFILE_AUDIENCE_UNKNOWN for an undeclared audience reference' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'p.json' = (New-TestProfileText -Mutate { param($p) $p['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators') }) }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{ Profile = 'p.json' } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | Where-Object { $_.code -eq 'DOCS_PROFILE_AUDIENCE_UNKNOWN' }).Count | Should -Be 1
        $result.Result.repository_id | Should -BeExactly 'example-repo'
    }

    It 'exits 1 with DOCS_PROFILE_SOURCE_ROOT_MISSING at the pointer of the source root that lists no file (issue #1173 B6)' {
        # Arrange (src lists a file; config lists none)
        $test = New-DocsTestContext -File @{ $script:ProfilePath = $script:ExampleProfile; 'src/example_pkg/a.py' = '' }

        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{} -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | Where-Object { $_.severity -eq 'error' } | ForEach-Object { "$($_.code) $($_.pointer)" }) | Should -Be @('DOCS_PROFILE_SOURCE_ROOT_MISSING /surface_selection/source_roots/1')
        $result.Result.repository_id | Should -BeExactly 'example-repo'
    }

    It 'exits 1 with DOCS_PROFILE_MISSING for an absent profile' {
        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{} -Context (New-DocsTestContext).Context

        # Assert
        $result.ExitCode | Should -Be 1
        $result.Findings.Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_PROFILE_MISSING'
        $result.Findings[0].pointer | Should -BeExactly ''
        $result.Findings[0].artifact_path | Should -BeExactly $script:ProfilePath
    }

    It 'exits 2 with one DOCS_CLI_ARGUMENTS for a non-relative profile path' {
        # Act
        $result = Invoke-DocsValidateProfileCommand -Argument @{ Profile = 'C:/abs.json' } -Context (New-DocsTestContext).Context

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Findings[0].code | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
    }
}
