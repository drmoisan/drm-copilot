#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageCheck.psm1.

.DESCRIPTION
    Rule contexts call the pure functions over in-memory page maps with the committed runtime
    schemas: each failure family, the finding-code catalog (one minimal input per code and the
    DOCS_PAGE_ literal set of the page modules), decode suppression, root findings, -Path
    selection, masked regions, the 1024-shape fixture and a seeded permutation property test.
    Command and CLI contexts run Invoke-DocsCheckCommand and Invoke-DocsCommandCli with the
    in-memory command context of Docs.TestSupport.psm1. No file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageCheck.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instances that DocsPageCheck imported, so a Test-Json mock reaches DocsSchema.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:ElementId = 'cli-command-' + ('0123456789abcdef' * 4)
    $script:Marker = "<!-- docs:generated:start id=$script:ElementId -->"
    $script:EndMarker = "<!-- docs:generated:end id=$script:ElementId -->"
    $script:FrontMatter = [ordered]@{
        owner         = 'owner: "team-docs"'
        last_reviewed = 'last_reviewed: "2026-10-30"'
        audience      = 'audience: ["developers"]'
        diataxis_mode = 'diataxis_mode: "explanation"'
        surface_refs  = 'surface_refs: []'
    }

    function New-TestProfile {
        # Returns a parsed docs profile (ordinal keys are not required by the pure functions).
        param([object[]] $Root = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') }), [string[]] $Mode = @('tutorial', 'how-to', 'reference', 'explanation'))
        $text = Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRoot -ChildPath 'examples/docs/v1/docs-profile.example.json') -Raw
        $value = (ConvertFrom-DocsJsonText -Text $text).Value
        $value['audiences'] = @([ordered]@{ id = 'developers'; description = 'People who change the code.' })
        $value['documentation_roots'] = $Root
        $value['diataxis_policy']['modes'] = $Mode
        $value['diataxis_policy']['directory_modes'] = @([ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' })
        return $value
    }

    function New-TestPage {
        # Builds page text from front-matter overrides (a $null value removes the field) and body lines.
        param([hashtable] $Field = @{}, [string[]] $Body = @('# Page', 'Text.'), [string[]] $ExtraLine = @())
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add('---')
        foreach ($key in $script:FrontMatter.Keys) {
            if ($Field.ContainsKey($key)) { if ($null -ne $Field[$key]) { $lines.Add("${key}: $($Field[$key])") } } else { $lines.Add($script:FrontMatter[$key]) }
        }
        foreach ($line in $ExtraLine) { $lines.Add($line) }
        $lines.Add('---')
        foreach ($line in $Body) { $lines.Add($line) }
        return ($lines -join "`n") + "`n"
    }

    function New-TestPageSet {
        # The clean base set: an entry page linking a guide; Page entries replace or add pages, Remove drops them.
        param([hashtable] $Page = @{}, [string[]] $Remove = @())
        $set = [ordered]@{
            'docs/README.md' = New-TestPage -Body @('# Documentation', '- [Guide](guide.md)', '- [Reference](reference/cli.md)', '- [Lost](lost.md)')
            'docs/guide.md'  = New-TestPage -Body @('# Guide', 'See [the top](#guide).')
        }
        foreach ($key in $Page.Keys) { $set[$key] = $Page[$key] }
        foreach ($key in $Remove) { $set.Remove($key) }
        return $set
    }

    function Invoke-TestCheck {
        param([System.Collections.IDictionary] $PageText = (New-TestPageSet), [System.Collections.IDictionary] $Profile = (New-TestProfile), [string[]] $ExistingPath = @(), [string[]] $SelectedPath)
        Get-DocsPageCheckFinding -PageText $PageText -Profile $Profile -ProfilePath $script:ProfilePath -ComposedSchemaSet $script:Composed -ExistingPath $ExistingPath -SelectedPath $SelectedPath
    }

    function Get-TestCodePath {
        param([object] $Outcome)
        @($Outcome.Findings | ForEach-Object { "$($_.code) $($_.artifact_path)$($_.pointer)" })
    }

    # The base set links two pages that the cases below add; a case that does not add them sees broken links, so the clean set adds both.
    $script:ReferencePage = New-TestPage -Field @{ diataxis_mode = '"reference"'; surface_refs = "[`"$script:ElementId`"]" } -Body @('# CLI reference', '', $script:Marker, '', '## Command `docs check`', '', '- Runs the page checker.', '', $script:EndMarker)
    $script:LostPage = New-TestPage -Body @('# Lost', 'Back to [the index](README.md).')
    $script:CleanSet = New-TestPageSet -Page @{ 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }
    $script:ProfileText = ConvertTo-DocsJsonText -Value (New-TestProfile) -Indented

    function New-TestCommandContext {
        # Returns the in-memory context with recording TestFile and ListFile members and a UtcNow member that throws.
        param([System.Collections.IDictionary] $Page = $script:CleanSet, [hashtable] $Extra = @{}, [AllowNull()] [string] $ProfileText = $script:ProfileText, [switch] $ReverseListing)
        $files = @{}
        if (-not [string]::IsNullOrEmpty($ProfileText)) { $files[$script:ProfilePath] = $ProfileText }
        foreach ($key in $Page.Keys) { $files[$key] = $Page[$key] }
        foreach ($key in $Extra.Keys) { $files[$key] = $Extra[$key] }
        $test = New-DocsTestContext -File $files
        $testCalls = [System.Collections.Generic.List[string]]::new()
        $listCalls = [System.Collections.Generic.List[string]]::new()
        $testFile = $test.Context.TestFile
        $listFile = $test.Context.ListFile
        $reverse = [bool] $ReverseListing
        $test.Context.TestFile = { param($RelativePath) $testCalls.Add([string] $RelativePath); & $testFile $RelativePath }.GetNewClosure()
        $test.Context.ListFile = {
            param($RelativeRoot)
            $listCalls.Add([string] $RelativeRoot)
            [string[]] $listed = & $listFile $RelativeRoot
            if ($reverse) { [Array]::Reverse($listed) }
            return , $listed
        }.GetNewClosure()
        $test.Context.UtcNow = { throw 'check must not read the clock' }
        $test['TestCalls'] = $testCalls
        $test['ListCalls'] = $listCalls
        return $test
    }
}

AfterAll {
    Remove-Module -Name DocsPageCheck, DocsPageOrphans, DocsPageDiataxis, DocsPageLinks, DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'DocsPageCheck pure helpers' {
    It 'keeps .md paths case-sensitively, de-duplicates nested roots and sorts ordinally' {
        # Act
        $paths = Get-DocsPageCandidatePath -RootListing ([ordered]@{ 'docs' = @('docs/b.md', 'docs/a.MD', 'docs/api/x.md', 'docs/img.png'); 'docs/api' = @('docs/api/x.md') })

        # Assert
        $paths | Should -Be @('docs/api/x.md', 'docs/b.md')
    }

    It 'decodes strict UTF-8 and removes a leading byte order mark' {
        # Act
        $result = ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0xEF, 0xBB, 0xBF, 0x23, 0x20, 0xC3, 0xA9)) -PagePath 'docs/a.md'

        # Assert
        $result.Text | Should -BeExactly ('# ' + [char]0xE9)
        $result.Findings.Count | Should -Be 0
    }

    It 'decodes an empty page to the empty string' {
        (ConvertFrom-DocsPageBytes -Bytes ([byte[]] @()) -PagePath 'docs/a.md').Text | Should -BeExactly ''
    }

    It 'reports DOCS_PAGE_TOO_LARGE above MaxBytes and DOCS_PAGE_ENCODING_INVALID for invalid UTF-8' {
        # Act
        $large = ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0x61, 0x62)) -PagePath 'docs/a.md' -MaxBytes 1
        $invalid = ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0xC3, 0x28)) -PagePath 'docs/b.md'

        # Assert
        $large.Text | Should -BeNullOrEmpty
        $large.Findings[0].code | Should -BeExactly 'DOCS_PAGE_TOO_LARGE'
        $invalid.Text | Should -BeNullOrEmpty
        $invalid.Findings[0].code | Should -BeExactly 'DOCS_PAGE_ENCODING_INVALID'
        $invalid.Findings[0].artifact_path | Should -BeExactly 'docs/b.md'
    }
}

Describe 'Get-DocsPageCheckFinding rules' {
    It 'returns no finding and the result shape for the clean page set' {
        # Act
        $outcome = Invoke-TestCheck -PageText $script:CleanSet

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @()
        @($outcome.Result.Keys) | Should -Be @('page_count', 'profile_path', 'roots')
        $outcome.Result.page_count | Should -Be 4
        $outcome.Result.profile_path | Should -BeExactly $script:ProfilePath
        $outcome.Result.roots[0].id | Should -BeExactly 'docs-root'
        $outcome.Result.roots[0].page_count | Should -Be 4
    }

    It 'reports <Code> with the failing page as artifact_path for the <Family> family' -ForEach @(
        @{ Family = 'missing field'; Page = 'docs/guide.md'; Field = @{ owner = $null }; Body = $null; Code = 'DOCS_PAGE_FIELD_MISSING' }
        @{ Family = 'malformed front matter (syntax)'; Page = 'docs/guide.md'; Field = @{ owner = $null }; Extra = @('not a key line'); Code = 'DOCS_PAGE_FRONT_MATTER_SYNTAX' }
        @{ Family = 'malformed front matter (unsupported)'; Page = 'docs/guide.md'; Field = @{ owner = '&anchor x' }; Code = 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED' }
        @{ Family = 'malformed front matter (per-field)'; Page = 'docs/guide.md'; Field = @{ owner = '"Team Docs"' }; Code = 'DOCS_PAGE_OWNER_INVALID' }
        @{ Family = 'broken link'; Page = 'docs/guide.md'; Body = @('# Guide', '[x](missing.md)'); Code = 'DOCS_PAGE_LINK_BROKEN' }
        @{ Family = 'same-page anchor'; Page = 'docs/guide.md'; Body = @('# Guide', '[x](#nowhere)'); Code = 'DOCS_PAGE_ANCHOR_MISSING' }
        @{ Family = 'cross-page anchor'; Page = 'docs/guide.md'; Body = @('# Guide', '[x](README.md#nowhere)'); Code = 'DOCS_PAGE_LINK_ANCHOR_MISSING' }
        @{ Family = 'Diataxis mismatch'; Page = 'docs/guide.md'; Field = @{ diataxis_mode = '"how-to"' }; Code = 'DOCS_PAGE_MODE_STEPS_MISSING' }
    ) {
        # Arrange
        $arguments = @{ Field = $(if ($_.ContainsKey('Field')) { $Field } else { @{} }) }
        if ($_.ContainsKey('Body') -and $null -ne $Body) { $arguments['Body'] = $Body }
        if ($_.ContainsKey('Extra')) { $arguments['ExtraLine'] = $Extra }
        $set = New-TestPageSet -Page @{ $Page = (New-TestPage @arguments); 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert
        @($outcome.Findings | ForEach-Object { $_.code }) | Should -Be @($Code)
        $outcome.Findings[0].artifact_path | Should -BeExactly $Page
    }

    It 'reports DOCS_PAGE_FRONT_MATTER_UNTERMINATED and DOCS_PAGE_ORPHAN for their families' {
        # Arrange
        $set = New-TestPageSet -Page @{ 'docs/guide.md' = "---`nowner: x`n# Guide"; 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage; 'docs/extra.md' = (New-TestPage) }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @('DOCS_PAGE_ORPHAN docs/extra.md', 'DOCS_PAGE_FRONT_MATTER_UNTERMINATED docs/guide.md')
    }

    It 'suppresses every rule except DOCS_PAGE_ORPHAN for an oversize or undecodable page' {
        # Arrange: the oversize page holds a broken link and no front matter, and is linked; the undecodable one is not linked
        $large = ConvertFrom-DocsPageBytes -Bytes ([System.Text.Encoding]::UTF8.GetBytes('[x](missing.md)')) -PagePath 'docs/guide.md' -MaxBytes 4
        $invalid = ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0xC3, 0x28)) -PagePath 'docs/bad.md'
        $set = New-TestPageSet -Page @{ 'docs/guide.md' = $large; 'docs/bad.md' = $invalid; 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert: links to the oversize page still resolve to it
        Get-TestCodePath -Outcome $outcome | Should -Be @('DOCS_PAGE_ENCODING_INVALID docs/bad.md', 'DOCS_PAGE_ORPHAN docs/bad.md', 'DOCS_PAGE_TOO_LARGE docs/guide.md')
    }

    It 'suppresses Diataxis rules when diataxis_mode is invalid or the front matter has a parse finding' {
        # Arrange
        $set = New-TestPageSet -Page @{
            'docs/guide.md'         = New-TestPage -Field @{ diataxis_mode = '"story"' } -Body @('# How to x')
            'docs/lost.md'          = New-TestPage -Field @{ diataxis_mode = '"how-to"'; owner = '|' }
            'docs/reference/cli.md' = $script:ReferencePage
        }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert
        @($outcome.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_MODE_INVALID', 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED')
    }

    It 'reports DOCS_PAGE_ROOT_EMPTY and DOCS_PAGE_ROOT_ENTRY_MISSING on the profile path at the root pointer' {
        # Arrange
        $roots = @(
            [ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') }
            [ordered]@{ id = 'empty-root'; path = 'empty'; audience_ids = @('developers') }
            [ordered]@{ id = 'api-root'; path = 'api/'; audience_ids = @('developers') }
        )
        $set = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $set[$key] = $script:CleanSet[$key] }
        $set['api/x.md'] = New-TestPage

        # Act
        $outcome = Invoke-TestCheck -PageText $set -Profile (New-TestProfile -Root $roots)

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @('DOCS_PAGE_ORPHAN api/x.md', "DOCS_PAGE_ROOT_EMPTY $script:ProfilePath/documentation_roots/1/path", "DOCS_PAGE_ROOT_ENTRY_MISSING $script:ProfilePath/documentation_roots/2/path")
        @($outcome.Result.roots | ForEach-Object { "$($_.id)=$($_.page_count) $($_.path)" }) | Should -Be @('docs-root=4 docs', 'empty-root=0 empty', 'api-root=1 api/')
        $outcome.Result.page_count | Should -Be 5
    }

    It 'counts a page under nested roots once and reaches it from either entry page' {
        # Arrange
        $roots = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') }, [ordered]@{ id = 'ref-root'; path = 'docs/reference'; audience_ids = @('developers') })
        $set = New-TestPageSet -Page @{ 'docs/reference/README.md' = (New-TestPage -Field @{ diataxis_mode = '"reference"' } -Body @('# Ref', '[cli](cli.md)')); 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set -Profile (New-TestProfile -Root $roots)

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @()
        $outcome.Result.page_count | Should -Be 5
        @($outcome.Result.roots | ForEach-Object { $_.page_count }) | Should -Be @(5, 2)
    }

    It 'restricts reported page findings to -SelectedPath and reports DOCS_PAGE_PATH_UNMATCHED' {
        # Arrange: guide and lost each hold a broken link; the profile gains an empty root
        $roots = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') }, [ordered]@{ id = 'empty-root'; path = 'empty'; audience_ids = @('developers') })
        $set = New-TestPageSet -Page @{ 'docs/guide.md' = (New-TestPage -Body @('[x](a.md)')); 'docs/lost.md' = (New-TestPage -Body @('[x](b.md)')); 'docs/reference/cli.md' = $script:ReferencePage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set -Profile (New-TestProfile -Root $roots) -SelectedPath @('docs/guide.md', 'docs/none/')

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @('DOCS_PAGE_PATH_UNMATCHED ', "DOCS_PAGE_ROOT_EMPTY $script:ProfilePath/documentation_roots/1/path", 'DOCS_PAGE_LINK_BROKEN docs/guide.md')
        $outcome.Findings[0].related_paths | Should -Be @('docs/none')
        $outcome.Findings[0].message | Should -BeExactly "-Path 'docs/none/' matches no page in the documentation roots"
    }

    It 'produces no link, anchor or Diataxis-step finding from markers, comments and fences' {
        # Arrange: a how-to page whose only ordered list, broken link and instructional heading sit in a fence or comment
        $body = @('# Guide', '1. Real step', $script:Marker, '<!-- [hidden](gone.md) # How to x [a](#nowhere) -->', $script:EndMarker, '```', '[broken](broken.md)', '## How to fenced', '1. fenced step', '```')
        $guide = New-TestPage -Field @{ diataxis_mode = '"reference"' } -Body $body
        $set = New-TestPageSet -Page @{ 'docs/guide.md' = $guide; 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @()
    }

    It 'returns zero findings for a page set in the 1024 output shape' {
        # Arrange: JSON-valued front matter, a reference page in the reference directory entry, linked from the entry page
        $entry = "---`nowner: `"team-docs`"`nlast_reviewed: `"2026-10-30`"`naudience: [`"developers`"]`ndiataxis_mode: `"explanation`"`nsurface_refs: []`n---`n# Reference`n`n- [CLI](reference/cli.md)`n"
        $set = [ordered]@{ 'docs/README.md' = $entry; 'docs/reference/cli.md' = $script:ReferencePage }

        # Act
        $outcome = Invoke-TestCheck -PageText $set

        # Assert
        Get-TestCodePath -Outcome $outcome | Should -Be @()
        $outcome.Result.page_count | Should -Be 2
    }

    It 'returns byte-identical findings under seeded permutation of the page map insertion order' {
        # Arrange
        $seed = 20261030
        $random = [System.Random]::new($seed)
        $pages = New-TestPageSet -Page @{ 'docs/guide.md' = (New-TestPage -Field @{ owner = $null } -Body @('[x](a.md) [y](#n)')); 'docs/z.md' = (New-TestPage -Body @('## How to', '[r](reference/cli.md#nope)')); 'docs/reference/cli.md' = $script:ReferencePage }
        $expected = ConvertTo-DocsCanonicalJson -Value ([object[]] (Invoke-TestCheck -PageText $pages).Findings)

        for ($round = 0; $round -lt 15; $round++) {
            $set = [ordered]@{}
            foreach ($key in @($pages.Keys | Sort-Object { $random.Next() })) { $set[$key] = $pages[$key] }

            # Act
            $actual = ConvertTo-DocsCanonicalJson -Value ([object[]] (Invoke-TestCheck -PageText $set).Findings)

            # Assert (the seed is printed through -Because on failure)
            $actual | Should -BeExactly $expected -Because "seed $seed round $round"
        }
    }
}

Describe 'DocsPageCheck finding-code catalog' {
    BeforeAll {
        $script:CatalogCode = @(
            'DOCS_PAGE_FRONT_MATTER_MISSING', 'DOCS_PAGE_FRONT_MATTER_UNTERMINATED', 'DOCS_PAGE_FRONT_MATTER_SYNTAX', 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED',
            'DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY', 'DOCS_PAGE_FIELD_MISSING', 'DOCS_PAGE_FIELD_UNKNOWN', 'DOCS_PAGE_OWNER_INVALID', 'DOCS_PAGE_LAST_REVIEWED_INVALID',
            'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE', 'DOCS_PAGE_AUDIENCE_INVALID', 'DOCS_PAGE_AUDIENCE_UNDECLARED', 'DOCS_PAGE_MODE_INVALID', 'DOCS_PAGE_SURFACE_REFS_INVALID',
            'DOCS_PAGE_TITLE_INVALID', 'DOCS_PAGE_EXTENSIONS_INVALID', 'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID', 'DOCS_PAGE_LINK_BROKEN', 'DOCS_PAGE_LINK_ESCAPES_REPOSITORY',
            'DOCS_PAGE_ANCHOR_MISSING', 'DOCS_PAGE_LINK_ANCHOR_MISSING', 'DOCS_PAGE_MODE_NOT_IN_POLICY', 'DOCS_PAGE_MODE_DIRECTORY_MISMATCH', 'DOCS_PAGE_MODE_STEPS_MISSING',
            'DOCS_PAGE_MODE_INSTRUCTION_HEADING', 'DOCS_PAGE_MODE_GENERATED_BLOCK', 'DOCS_PAGE_ORPHAN', 'DOCS_PAGE_TOO_LARGE', 'DOCS_PAGE_ENCODING_INVALID',
            'DOCS_PAGE_ROOT_EMPTY', 'DOCS_PAGE_ROOT_ENTRY_MISSING', 'DOCS_PAGE_PATH_UNMATCHED'
        )
    }

    It 'produces <Code> at <Artifact><Pointer> with severity error' -ForEach @(
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_MISSING'; Guide = "# Guide`n"; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_UNTERMINATED'; Guide = "---`nowner: x`n"; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_SYNTAX'; Extra = @('not a key line'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED'; Field = @{ owner = '|' }; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY'; Extra = @('owner: "team-b"'); Artifact = 'docs/guide.md'; Pointer = '/owner' }
        @{ Code = 'DOCS_PAGE_FIELD_MISSING'; Field = @{ surface_refs = $null }; Artifact = 'docs/guide.md'; Pointer = '/surface_refs' }
        @{ Code = 'DOCS_PAGE_FIELD_UNKNOWN'; Extra = @('color: "red"'); Artifact = 'docs/guide.md'; Pointer = '/color' }
        @{ Code = 'DOCS_PAGE_OWNER_INVALID'; Field = @{ owner = '"Bad Owner"' }; Artifact = 'docs/guide.md'; Pointer = '/owner' }
        @{ Code = 'DOCS_PAGE_LAST_REVIEWED_INVALID'; Field = @{ last_reviewed = '"2026/10/30"' }; Artifact = 'docs/guide.md'; Pointer = '/last_reviewed' }
        @{ Code = 'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE'; Field = @{ last_reviewed = '"2026-02-30"' }; Artifact = 'docs/guide.md'; Pointer = '/last_reviewed' }
        @{ Code = 'DOCS_PAGE_AUDIENCE_INVALID'; Field = @{ audience = '["Dev_Ops"]' }; Artifact = 'docs/guide.md'; Pointer = '/audience/0' }
        @{ Code = 'DOCS_PAGE_AUDIENCE_UNDECLARED'; Field = @{ audience = '["operators"]' }; Artifact = 'docs/guide.md'; Pointer = '/audience/0' }
        @{ Code = 'DOCS_PAGE_MODE_INVALID'; Field = @{ diataxis_mode = '"story"' }; Artifact = 'docs/guide.md'; Pointer = '/diataxis_mode' }
        @{ Code = 'DOCS_PAGE_SURFACE_REFS_INVALID'; Field = @{ surface_refs = '["Not An Id"]' }; Artifact = 'docs/guide.md'; Pointer = '/surface_refs/0' }
        @{ Code = 'DOCS_PAGE_TITLE_INVALID'; Extra = @("title: ' '"); Artifact = 'docs/guide.md'; Pointer = '/title' }
        @{ Code = 'DOCS_PAGE_EXTENSIONS_INVALID'; Extra = @('extensions: {"note": 1}'); Artifact = 'docs/guide.md'; Pointer = '/extensions/note' }
        @{ Code = 'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID'; MockTestJson = $true; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_LINK_BROKEN'; Body = @('[x](missing.md)'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_LINK_ESCAPES_REPOSITORY'; Body = @('[x](../../up.md)'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_ANCHOR_MISSING'; Body = @('[x](#nope)'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_LINK_ANCHOR_MISSING'; Body = @('[x](README.md#nope)'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_MODE_NOT_IN_POLICY'; Field = @{ diataxis_mode = '"tutorial"' }; Body = @('1. Step'); Mode = @('explanation', 'reference'); Artifact = 'docs/guide.md'; Pointer = '/diataxis_mode' }
        @{ Code = 'DOCS_PAGE_MODE_DIRECTORY_MISMATCH'; GuidePath = 'docs/reference/guide.md'; Body = @('[up](../README.md)'); Artifact = 'docs/reference/guide.md'; Pointer = '/diataxis_mode' }
        @{ Code = 'DOCS_PAGE_MODE_STEPS_MISSING'; Field = @{ diataxis_mode = '"how-to"' }; Artifact = 'docs/guide.md'; Pointer = '/diataxis_mode' }
        @{ Code = 'DOCS_PAGE_MODE_INSTRUCTION_HEADING'; Body = @('## How to start'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_MODE_GENERATED_BLOCK'; Body = @('<!-- docs:generated:start id=x -->'); Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_ORPHAN'; GuidePath = 'docs/unlinked.md'; Artifact = 'docs/unlinked.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_TOO_LARGE'; Decode = 'large'; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_ENCODING_INVALID'; Decode = 'invalid'; Artifact = 'docs/guide.md'; Pointer = '' }
        @{ Code = 'DOCS_PAGE_ROOT_EMPTY'; Root = 'empty'; Artifact = 'docs/documentation-estate/docs-profile.json'; Pointer = '/documentation_roots/1/path' }
        @{ Code = 'DOCS_PAGE_ROOT_ENTRY_MISSING'; Root = 'entry'; Artifact = 'docs/documentation-estate/docs-profile.json'; Pointer = '/documentation_roots/1/path' }
        @{ Code = 'DOCS_PAGE_PATH_UNMATCHED'; Selected = @('docs/none.md'); Artifact = ''; Pointer = '' }
    ) {
        # Arrange
        $arguments = @{ Field = $(if ($_.ContainsKey('Field')) { $Field } else { @{} }) }
        if ($_.ContainsKey('Body')) { $arguments['Body'] = @('# Guide') + $Body }
        if ($_.ContainsKey('Extra')) { $arguments['ExtraLine'] = $Extra }
        $path = if ($_.ContainsKey('GuidePath')) { $GuidePath } else { 'docs/guide.md' }
        $text = if ($_.ContainsKey('Guide')) { $Guide } else { New-TestPage @arguments }
        if ($_.ContainsKey('Decode')) { $text = if ($Decode -ceq 'large') { ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0x61, 0x62)) -PagePath $path -MaxBytes 1 } else { ConvertFrom-DocsPageBytes -Bytes ([byte[]] @(0xC3, 0x28)) -PagePath $path } }
        $set = New-TestPageSet -Page @{ $path = $text; 'docs/reference/cli.md' = $script:ReferencePage; 'docs/lost.md' = $script:LostPage }
        $roots = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
        if ($_.ContainsKey('Root')) {
            $roots += [ordered]@{ id = 'extra-root'; path = 'extra'; audience_ids = @('developers') }
            if ($Root -ceq 'entry') { $set['extra/page.md'] = New-TestPage }
        }
        $profileArguments = @{ Root = $roots }
        if ($_.ContainsKey('Mode')) { $profileArguments['Mode'] = $Mode }
        if ($_.ContainsKey('MockTestJson')) { Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $false } }
        $selected = if ($_.ContainsKey('Selected')) { $Selected } else { $null }

        # Act
        $outcome = Invoke-TestCheck -PageText $set -Profile (New-TestProfile @profileArguments) -SelectedPath $selected

        # Assert
        $hits = @($outcome.Findings | Where-Object { $_.code -ceq $Code -and [string] $_.artifact_path -ceq $Artifact })
        $hits.Count | Should -BeGreaterThan 0 -Because (@($outcome.Findings | ForEach-Object { "$($_.code) $($_.artifact_path)" }) -join ', ')
        $hits[0].pointer | Should -BeExactly $Pointer
        $hits[0].severity | Should -BeExactly 'error'
        @($outcome.Findings | Where-Object { $_.code -like 'DOCS_PAGE_*' -and $script:CatalogCode -cnotcontains $_.code }).Count | Should -Be 0
    }

    It 'finds exactly the catalog codes as DOCS_PAGE_ string literals of the page modules' {
        # Arrange
        $names = @('DocsPageMarkdown', 'DocsPageFrontMatter', 'DocsPageMetadata', 'DocsPageLinks', 'DocsPageDiataxis', 'DocsPageOrphans', 'DocsPageCheck')
        $extra = @(Get-ChildItem -LiteralPath (Join-Path -Path $script:LibraryRoot -ChildPath 'docs') -Filter 'DocsPage*.psm1' | ForEach-Object { $_.BaseName } | Where-Object { $names -cnotcontains $_ })
        $literals = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)

        # Act
        foreach ($name in @($names + $extra)) {
            $text = Get-Content -LiteralPath (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Raw
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $null, [ref] $null)
            foreach ($node in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true)) {
                if ($node.Value -cmatch '^DOCS_PAGE_[A-Z0-9_]+$') { [void]$literals.Add($node.Value) }
            }
        }

        # Assert
        [string[]] $expected = $script:CatalogCode
        [Array]::Sort($expected, [System.StringComparer]::Ordinal)
        @($literals) | Should -Be $expected
    }
}

Describe 'Invoke-DocsCheckCommand' {
    It 'exits 0 with no finding, the result shape and the command line for the clean set' {
        # Arrange
        $test = New-TestCommandContext

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.Command | Should -BeExactly 'check'
        $result.ExitCode | Should -Be 0
        @($result.Findings).Count | Should -Be 0
        @($result.Result.Keys) | Should -Be @('page_count', 'profile_path', 'roots')
        $result.Result.page_count | Should -Be 4
        $result.Line | Should -Be @('check: pages=4 roots=1')
        $test.ListCalls | Should -Be @('docs')
    }

    It 'exits 1 for the <Family> family' -ForEach @(
        @{ Family = 'missing field'; Field = @{ owner = $null }; Body = @('# Guide'); Code = 'DOCS_PAGE_FIELD_MISSING' }
        @{ Family = 'broken link'; Field = @{}; Body = @('[x](gone.md)'); Code = 'DOCS_PAGE_LINK_BROKEN' }
        @{ Family = 'Diataxis'; Field = @{ diataxis_mode = '"tutorial"' }; Body = @('# Guide'); Code = 'DOCS_PAGE_MODE_STEPS_MISSING' }
    ) {
        # Arrange (the page text is built here because discovery runs before BeforeAll defines New-TestPage)
        $set = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $set[$key] = $script:CleanSet[$key] }
        $set['docs/guide.md'] = New-TestPage -Field $Field -Body $Body

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context (New-TestCommandContext -Page $set).Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @($Code)
    }

    It 'exits 1 with DOCS_PROFILE_MISSING and result null for an absent profile' {
        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{ Profile = 'docs/none.json' }) -Context (New-TestCommandContext -ProfileText $null).Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PROFILE_MISSING')
        $result.Findings[0].artifact_path | Should -BeExactly 'docs/none.json'
        $result.Result | Should -BeNullOrEmpty
    }

    It 'returns the profile findings with exit 1, result null and no ListFile call for an invalid profile' {
        # Arrange
        $test = New-TestCommandContext -ProfileText '{"schema_version": "1.0.0"}'

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings).Count | Should -BeGreaterThan 0
        @($result.Findings | Where-Object { $_.code -like 'DOCS_PAGE_*' }).Count | Should -Be 0
        $result.Result | Should -BeNullOrEmpty
        $test.ListCalls.Count | Should -Be 0
    }

    It 'exits 2 with exactly one DOCS_CLI_ARGUMENTS and no context call for a non-relative <Name>' -ForEach @(
        @{ Name = 'Profile'; Argument = [ordered]@{ Profile = '/abs/p.json' } }
        @{ Name = 'Path'; Argument = [ordered]@{ Path = [string[]] @('docs', 'C:/x') } }
    ) {
        # Arrange
        $test = New-TestCommandContext

        # Act
        $result = Invoke-DocsCheckCommand -Argument $Argument -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 2
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_CLI_ARGUMENTS')
        $result.Result | Should -BeNullOrEmpty
        $test.ListCalls.Count | Should -Be 0
    }

    It 'calls TestFile once per external target and never for a page' {
        # Arrange: two pages link the same image, one links a data file and one links a missing file
        $set = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $set[$key] = $script:CleanSet[$key] }
        $set['docs/guide.md'] = New-TestPage -Body @('# Guide', '![i](img.png) [d](data/x.json) [m](missing.txt) [g](README.md)')
        $set['docs/lost.md'] = New-TestPage -Body @('[back](README.md) ![i](img.png)')
        $test = New-TestCommandContext -Page $set -Extra @{ 'docs/img.png' = 'png'; 'docs/data/x.json' = '{}' }

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $test.TestCalls | Should -Be @('docs/data/x.json', 'docs/img.png', 'docs/missing.txt')
        @($result.Findings | ForEach-Object { "$($_.code) $($_.related_paths)" }) | Should -Be @('DOCS_PAGE_LINK_BROKEN docs/missing.txt')
        $result.ExitCode | Should -Be 1
    }

    It 'lists roots in profile order and counts pages of nested roots once' {
        # Arrange
        $roots = @([ordered]@{ id = 'ref-root'; path = 'docs/reference'; audience_ids = @('developers') }, [ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
        $set = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $set[$key] = $script:CleanSet[$key] }
        $set['docs/reference/index.md'] = New-TestPage -Field @{ diataxis_mode = '"reference"' } -Body @('# Ref', '[cli](cli.md)')
        $test = New-TestCommandContext -Page $set -ProfileText (ConvertTo-DocsJsonText -Value (New-TestProfile -Root $roots) -Indented)

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        @($result.Result.roots | ForEach-Object { "$($_.id)=$($_.page_count)" }) | Should -Be @('ref-root=2', 'docs-root=5')
        $result.Result.page_count | Should -Be 5
        $result.Line | Should -Be @('check: pages=5 roots=2')
    }

    It 'exits 0 with zero findings for the 1024-shape fixture page set' {
        # Arrange
        $entry = "---`nowner: `"team-docs`"`nlast_reviewed: `"2026-10-30`"`naudience: [`"developers`"]`ndiataxis_mode: `"explanation`"`nsurface_refs: []`n---`n# Reference`n`n- [CLI](reference/cli.md)`n"
        $test = New-TestCommandContext -Page ([ordered]@{ 'docs/README.md' = $entry; 'docs/reference/cli.md' = $script:ReferencePage })

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        @($result.Findings).Count | Should -Be 0
    }

    It 'applies -Path selection and reports DOCS_PAGE_PATH_UNMATCHED' {
        # Arrange
        $set = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $set[$key] = $script:CleanSet[$key] }
        $set['docs/lost.md'] = New-TestPage -Body @('[back](README.md) [x](gone.md)')

        # Act
        $selected = Invoke-DocsCheckCommand -Argument ([ordered]@{ Path = [string[]] @('docs/guide.md') }) -Context (New-TestCommandContext -Page $set).Context
        $unmatched = Invoke-DocsCheckCommand -Argument ([ordered]@{ Path = [string[]] @('docs/nowhere') }) -Context (New-TestCommandContext -Page $set).Context

        # Assert
        $selected.ExitCode | Should -Be 0
        @($selected.Findings).Count | Should -Be 0
        $unmatched.ExitCode | Should -Be 1
        @($unmatched.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_PATH_UNMATCHED')
    }

    It 'throws for an uncomposable schema set so the entry boundary reports exit 3' {
        # Arrange
        Mock -CommandName Get-DocsComposedSchemaSet -ModuleName DocsPageCheck -MockWith { @{ Schemas = [ordered]@{}; Findings = @([ordered]@{ code = 'DOCS_SCHEMA_COMPOSITION_CONFLICT'; message = 'conflict' }) } }

        # Act and Assert
        { Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context (New-TestCommandContext).Context } | Should -Throw -ExpectedMessage 'DOCS_SCHEMA_COMPOSITION_FAILED*'
    }
}

Describe 'check through Invoke-DocsCommandCli' {
    BeforeAll {
        . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

        function Invoke-TestCli {
            param([string[]] $Argument = @(), [object] $Context = (New-TestCommandContext).Context, [switch] $Text)
            Invoke-DocsCommandCli -Command 'check' -CommandArgument $Argument -Context $Context -Json:(-not $Text)
        }

        function Get-TestEnvelope {
            param([hashtable] $Outcome)
            (ConvertFrom-DocsJsonText -Text $Outcome.Stdout).Value
        }

        function Test-TestEnvelopeValid {
            # The CR-9 route: the envelope is a composed docs schema validated through Test-DocsArtifactText.
            param([hashtable] $Outcome)
            (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $Outcome.Stdout -ComposedSchemaSet $script:Composed).Count -eq 0
        }

        $script:FindingSet = [ordered]@{}
        foreach ($key in $script:CleanSet.Keys) { $script:FindingSet[$key] = $script:CleanSet[$key] }
        $script:FindingSet['docs/guide.md'] = New-TestPage -Field @{ owner = $null } -Body @('[a](a.md) [b](b.md#x) [c](#none)')
        $script:FindingSet['docs/zz.md'] = New-TestPage -Body @('## How to x')
    }

    It 'registers check in the committed dispatch table with no table finding' {
        (Test-DocsCommandTable -Table (Get-DocsCommandTable)).Count | Should -Be 0
        @((Get-DocsCommandTable) | Where-Object { $_.Name -ceq 'check' }).Count | Should -Be 1
    }

    It 'exits 0 on the clean set and writes the text report with the check line' {
        # Act
        $outcome = Invoke-TestCli -Text

        # Assert
        $outcome.ExitCode | Should -Be 0
        $outcome.Stderr | Should -BeExactly ''
        @($outcome.Stdout.TrimEnd("`n") -split "`n") | Should -Be @('check: pages=4 roots=1', 'check: exit=0 errors=0 warnings=0 infos=0')
    }

    It 'exits 1 when a finding is present and exits 1 with DOCS_PROFILE_MISSING for an absent profile' {
        # Act
        $findings = Invoke-TestCli -Context (New-TestCommandContext -Page $script:FindingSet).Context
        $missing = Invoke-TestCli -Context (New-TestCommandContext -ProfileText '').Context

        # Assert
        $findings.ExitCode | Should -Be 1
        $missing.ExitCode | Should -Be 1
        @((Get-TestEnvelope -Outcome $missing).findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PROFILE_MISSING')
        (Get-TestEnvelope -Outcome $missing).result | Should -BeNullOrEmpty
    }

    It 'exits 2 with exactly one DOCS_CLI_ARGUMENTS and result null for <Case>' -ForEach @(
        @{ Case = 'a non-relative -Profile'; Argument = @('-Profile', '/abs/profile.json') }
        @{ Case = 'a non-relative -Path'; Argument = @('-Path', 'docs', '-Path', '../outside') }
        @{ Case = 'a repeated -Profile'; Argument = @('-Profile', 'a.json', '-Profile', 'b.json') }
    ) {
        # Act
        $outcome = Invoke-TestCli -Argument $Argument
        $envelope = Get-TestEnvelope -Outcome $outcome

        # Assert
        $outcome.ExitCode | Should -Be 2
        @($envelope.findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_CLI_ARGUMENTS')
        $envelope.result | Should -BeNullOrEmpty
        $envelope.command | Should -BeExactly 'check'
    }

    It 'exits 3 with DOCS_CLI_RUNTIME when ReadBytes fails with a non-absence error' {
        # Arrange
        $context = (New-TestCommandContext).Context
        $context.ReadBytes = { param($RelativePath) throw [System.IO.IOException]::new("The device is not ready: $RelativePath") }

        # Act
        $outcome = Invoke-TestCli -Context $context
        $envelope = Get-TestEnvelope -Outcome $outcome

        # Assert
        $outcome.ExitCode | Should -Be 3
        @($envelope.findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_CLI_RUNTIME')
        $outcome.Stderr | Should -BeExactly "Invoke-DocsCommand.ps1: exit 3 (DOCS_CLI_RUNTIME)`n"
    }

    It 'writes byte-identical -Json across two runs and across a reversed ListFile order, with findings in Get-DocsOrderedFinding order' {
        # Act
        $first = Invoke-TestCli -Context (New-TestCommandContext -Page $script:FindingSet).Context
        $second = Invoke-TestCli -Context (New-TestCommandContext -Page $script:FindingSet).Context
        $reversed = Invoke-TestCli -Context (New-TestCommandContext -Page $script:FindingSet -ReverseListing).Context
        $findings = @((Get-TestEnvelope -Outcome $first).findings)

        # Assert
        $first.ExitCode | Should -Be 1
        $findings.Count | Should -BeGreaterThan 3
        $second.Stdout | Should -BeExactly $first.Stdout
        $reversed.Stdout | Should -BeExactly $first.Stdout
        $first.Stdout.EndsWith("}`n") | Should -BeTrue
        (ConvertTo-DocsCanonicalJson -Value ([object[]] (Get-DocsOrderedFinding -Finding $findings))) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value ([object[]] $findings))
        [string[]] $keys = @((Get-TestEnvelope -Outcome $first).result.Keys)
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        $keys | Should -Be @('page_count', 'profile_path', 'roots')
    }

    It 'writes a -Json document that validates against the envelope schema for the <Case> run' -ForEach @(
        @{ Case = 'clean'; ExitCode = 0 }
        @{ Case = 'findings'; ExitCode = 1 }
        @{ Case = 'usage-error'; ExitCode = 2 }
    ) {
        # Arrange
        $outcome = switch ($Case) {
            'clean' { Invoke-TestCli }
            'findings' { Invoke-TestCli -Context (New-TestCommandContext -Page $script:FindingSet).Context }
            'usage-error' { Invoke-TestCli -Argument @('-Path', '/abs') }
        }

        # Act and Assert
        $outcome.ExitCode | Should -Be $ExitCode
        Test-TestEnvelopeValid -Outcome $outcome | Should -BeTrue
    }
}
