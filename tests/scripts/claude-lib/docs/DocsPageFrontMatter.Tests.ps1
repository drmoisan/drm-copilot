#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageFrontMatter.psm1.

.DESCRIPTION
    Parser contexts cover block detection, every line-grammar row and value-form row of the
    front-matter subset, the parse finding codes, field and body line numbers and a seeded
    property test (comment and blank line insertion). Validation contexts cover the field codes,
    the calendar check, audience declaration, the fail-closed rule and the agreement of accepted
    fixtures with Test-Json. The constraint evaluator and value checks of the refinement module
    DocsPageMetadata.psm1 are also tested directly in DocsPageMetadata.Tests.ps1. Page texts are
    in-memory strings; schema texts come from the committed runtime files through
    Docs.TestSupport.psm1. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageFrontMatter.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instance that DocsPageFrontMatter imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop

    function ConvertFrom-TestBlock {
        # Parses a front-matter block whose inner lines are given.
        param([string[]] $Line, [string] $Terminator = '---')
        ConvertFrom-DocsPageFrontMatter -Text ((@('---') + $Line + @($Terminator, 'body')) -join "`n") -PagePath 'docs/page.md'
    }

    function Get-TestCode {
        param([object] $Result)
        @($Result.Findings | ForEach-Object { $_.code })
    }
}

AfterAll {
    Remove-Module -Name DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-DocsPageFrontMatter block detection' {
    It 'reports no block when line 1 is not exactly ---' {
        # Act
        $result = ConvertFrom-DocsPageFrontMatter -Text "# Title`n---" -PagePath 'docs/page.md'

        # Assert
        $result.Present | Should -BeFalse
        $result.Value | Should -BeNullOrEmpty
        $result.BodyStartLine | Should -Be 1
        $result.Findings.Count | Should -Be 0
    }

    It 'detects a block after a byte order mark and ends it at ---' {
        # Act
        $result = ConvertFrom-DocsPageFrontMatter -Text ([string][char]0xFEFF + "---`r`nowner: team-a`r`n---`r`nbody") -PagePath 'docs/page.md'

        # Assert
        $result.Present | Should -BeTrue
        $result.Terminated | Should -BeTrue
        $result.Value['owner'] | Should -BeExactly 'team-a'
        $result.BodyStartLine | Should -Be 4
    }

    It 'ends a block at the ... terminator' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('owner: team-a') -Terminator '...'

        # Assert
        $result.Terminated | Should -BeTrue
        $result.BodyStartLine | Should -Be 4
    }

    It 'reports DOCS_PAGE_FRONT_MATTER_UNTERMINATED with BodyStartLine 1 for an unclosed block' {
        # Act
        $result = ConvertFrom-DocsPageFrontMatter -Text "---`nowner: team-a`n# body" -PagePath 'docs/page.md'

        # Assert
        Get-TestCode -Result $result | Should -Be @('DOCS_PAGE_FRONT_MATTER_UNTERMINATED')
        $result.Findings[0].artifact_path | Should -BeExactly 'docs/page.md'
        $result.Findings[0].pointer | Should -BeExactly ''
        $result.Value | Should -BeNullOrEmpty
        $result.BodyStartLine | Should -Be 1
    }

    It 'records FieldLine for each key in page lines' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('# comment', 'owner: team-a', '', 'title: T')

        # Assert
        $result.FieldLine['owner'] | Should -Be 3
        $result.FieldLine['title'] | Should -Be 5
    }

    It 'keeps keys case-sensitive' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('Owner: a', 'owner: b')

        # Assert
        $result.Findings.Count | Should -Be 0
        $result.Value['owner'] | Should -BeExactly 'b'
        $result.Value['Owner'] | Should -BeExactly 'a'
    }
}

Describe 'ConvertFrom-DocsPageFrontMatter line grammar' {
    It 'ignores blank, whitespace-only and comment lines' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('', '   ', '# c', '   # indented comment', 'owner: a')

        # Assert
        $result.Findings.Count | Should -Be 0
        @($result.Value.Keys) | Should -Be @('owner')
    }

    It 'reads a block sequence of scalars under a key with an empty value' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('audience:', '  - dev', '', '# c', '- "ops"', "  - 'qa'")

        # Assert
        $result.Findings.Count | Should -Be 0
        $result.Value['audience'] | Should -Be @('dev', 'ops', 'qa')
    }

    It 'keeps a one-item block sequence as an array' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('audience:', '  - dev', 'owner: a')

        # Assert
        $result.Value['audience'] -is [array] | Should -BeTrue
        @($result.Value['audience']).Count | Should -Be 1
        (ConvertTo-DocsJsonText -Value $result.Value['audience']).Trim() | Should -BeExactly '["dev"]'
    }

    It 'resolves a key with an empty value and no items to $null' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('title:', 'owner: a')

        # Assert
        $result.Value.ContainsKey('title') | Should -BeTrue
        $result.Value['title'] | Should -BeNullOrEmpty
    }

    It 'reports <Construct> for <Line>' -ForEach @(
        @{ Line = "`towner: a"; Construct = 'tab indentation' }
        @{ Line = '"owner": a'; Construct = 'quoted key' }
        @{ Line = '? owner'; Construct = 'complex key' }
        @{ Line = '  owner: a'; Construct = 'indented line' }
        @{ Line = '- key: value'; Construct = 'mapping in sequence item' }
        @{ Line = '- - x'; Construct = 'nested sequence' }
    ) {
        # Act
        $result = ConvertFrom-TestBlock -Line @($Line)

        # Assert
        Get-TestCode -Result $result | Should -Be @('DOCS_PAGE_FRONT_MATTER_UNSUPPORTED')
        $result.Findings[0].message | Should -Match ([regex]::Escape("'$Construct'"))
        $result.Value | Should -BeNullOrEmpty
    }

    It 'reports <Construct> for the sequence item <Item>' -ForEach @(
        @{ Item = '- key: value'; Construct = 'mapping in sequence item' }
        @{ Item = '- - x'; Construct = 'nested sequence' }
        @{ Item = '- [a]'; Construct = 'flow collection in sequence item' }
    ) {
        # Act
        $result = ConvertFrom-TestBlock -Line @('audience:', $Item)

        # Assert
        Get-TestCode -Result $result | Should -Be @('DOCS_PAGE_FRONT_MATTER_UNSUPPORTED')
        $result.Findings[0].message | Should -Match ([regex]::Escape("'$Construct'"))
    }

    It 'reports DOCS_PAGE_FRONT_MATTER_SYNTAX for <Line>' -ForEach @(
        @{ Line = 'owner' }
        @{ Line = 'owner:a' }
        @{ Line = '- orphan item' }
        @{ Line = '9key: a' }
    ) {
        # Act
        $result = ConvertFrom-TestBlock -Line @($Line)

        # Assert
        Get-TestCode -Result $result | Should -Be @('DOCS_PAGE_FRONT_MATTER_SYNTAX')
        $result.Findings[0].pointer | Should -BeExactly ''
        $result.Findings[0].message | Should -Match '^line 2: '
    }

    It 'reports DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY at /<key> naming the first line' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('owner: a', 'title: T', 'owner: b')

        # Assert
        Get-TestCode -Result $result | Should -Be @('DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY')
        $result.Findings[0].pointer | Should -BeExactly '/owner'
        $result.Findings[0].message | Should -Match 'repeats the key on line 2'
        $result.Value | Should -BeNullOrEmpty
    }

    It 'reports every malformed line of one block' {
        # Act
        $result = ConvertFrom-TestBlock -Line @('oops', 'owner: |', 'also wrong')

        # Assert
        (Get-TestCode -Result $result).Count | Should -Be 3
    }
}

Describe 'ConvertFrom-DocsPageYamlScalar value forms' {
    It 'resolves <Text> to <Expected>' -ForEach @(
        @{ Text = ''; Expected = $null }
        @{ Text = '~'; Expected = $null }
        @{ Text = 'Null'; Expected = $null }
        @{ Text = '# only a comment'; Expected = $null }
        @{ Text = 'true'; Expected = $true }
        @{ Text = 'FALSE'; Expected = $false }
        @{ Text = '42'; Expected = [long] 42 }
        @{ Text = '-7'; Expected = [long] -7 }
        @{ Text = '1.5e3'; Expected = [double] 1500 }
        @{ Text = '.5'; Expected = [double] 0.5 }
        @{ Text = '2026-10-30'; Expected = '2026-10-30' }
        @{ Text = 'plain text # comment'; Expected = 'plain text' }
        @{ Text = 'a:b'; Expected = 'a:b' }
        @{ Text = "'it''s' # c"; Expected = "it's" }
        @{ Text = '"team-a"'; Expected = 'team-a' }
        @{ Text = '"x" # c'; Expected = 'x' }
        @{ Text = ('"' + [char] 92 + 'u00e9"'); Expected = [string][char]0x00E9 }
        @{ Text = 'yes   '; Expected = 'yes' }
    ) {
        # Act
        $result = ConvertFrom-DocsPageYamlScalar -Text $Text

        # Assert
        $result.Ok | Should -BeTrue
        if ($null -eq $Expected) { $result.Value | Should -BeNullOrEmpty } else {
            $result.Value | Should -Be $Expected
            $result.Value.GetType() | Should -Be $Expected.GetType()
        }
    }

    It 'resolves the JSON values of the 1024 shape' {
        # Act
        $array = ConvertFrom-DocsPageYamlScalar -Text '["dev", "ops"]'
        $empty = ConvertFrom-DocsPageYamlScalar -Text '[]'
        $object = ConvertFrom-DocsPageYamlScalar -Text '{"vendor.note": 1}'

        # Assert
        $array.Value | Should -Be @('dev', 'ops')
        @($empty.Value).Count | Should -Be 0
        $object.Value['vendor.note'] | Should -Be 1
    }

    It 'resolves a flow sequence of plain, single-quoted and double-quoted scalars' {
        # Act
        $result = ConvertFrom-DocsPageYamlScalar -Text "[dev, 'o''ps', `"qa`", 3,] # c"

        # Assert
        $result.Ok | Should -BeTrue
        $result.Value | Should -Be @('dev', "o'ps", 'qa', [long] 3)
    }

    It 'resolves a flow sequence whose double-quoted item ends in an escaped backslash' {
        # Act (single-quoted literals: each backslash is an ordinary character)
        $backslash = ConvertFrom-DocsPageYamlScalar -Text '["a\\", b]'
        $escapedQuote = ConvertFrom-DocsPageYamlScalar -Text '["a\\\"", b]'
        $backslashBlock = ConvertFrom-TestBlock -Line @('tags: ["a\\", b]')
        $escapedQuoteBlock = ConvertFrom-TestBlock -Line @('tags: ["a\\\"", b]')
        $unterminatedBlock = ConvertFrom-TestBlock -Line @('tags: ["a\", b]')

        # Assert
        $backslash.Ok | Should -BeTrue
        $backslash.Value | Should -Be @('a\', 'b')
        $escapedQuote.Ok | Should -BeTrue
        $escapedQuote.Value | Should -Be @('a\"', 'b')
        @(Get-TestCode -Result $backslashBlock).Count | Should -Be 0
        $backslashBlock.Value['tags'] | Should -Be @('a\', 'b')
        @(Get-TestCode -Result $escapedQuoteBlock).Count | Should -Be 0
        Get-TestCode -Result $unterminatedBlock | Should -Be @('DOCS_PAGE_FRONT_MATTER_UNSUPPORTED')
    }

    It 'reports the construct <Construct> for <Text>' -ForEach @(
        @{ Text = '[a, [b]]'; Construct = 'nested flow collection' }
        @{ Text = '[a, {b: 1}]'; Construct = 'nested flow collection' }
        @{ Text = '[a, b'; Construct = 'unclosed flow sequence' }
        @{ Text = '["a\", b]'; Construct = 'unclosed flow sequence' }
        @{ Text = '{a: 1}'; Construct = 'flow mapping' }
        @{ Text = '"\x41"'; Construct = 'YAML escape' }
        @{ Text = '[a, "\x41"]'; Construct = 'YAML escape' }
        @{ Text = '|'; Construct = 'block scalar' }
        @{ Text = '>-'; Construct = 'block scalar' }
        @{ Text = '&a x'; Construct = 'anchor' }
        @{ Text = '*a'; Construct = 'alias' }
        @{ Text = '!!str x'; Construct = 'tag' }
        @{ Text = '%x'; Construct = 'reserved indicator' }
        @{ Text = '@x'; Construct = 'reserved indicator' }
        @{ Text = '`x'; Construct = 'reserved indicator' }
        @{ Text = ', x'; Construct = 'reserved indicator' }
        @{ Text = '] x'; Construct = 'reserved indicator' }
        @{ Text = '} x'; Construct = 'reserved indicator' }
        @{ Text = '? x'; Construct = 'reserved indicator' }
        @{ Text = '- x'; Construct = 'reserved indicator' }
        @{ Text = 'a: b'; Construct = 'mapping in plain scalar' }
        @{ Text = '99999999999999999999'; Construct = 'integer outside Int64' }
        @{ Text = '.inf'; Construct = 'special float' }
        @{ Text = '-.Inf'; Construct = 'special float' }
        @{ Text = '.NaN'; Construct = 'special float' }
    ) {
        # Act
        $result = ConvertFrom-DocsPageYamlScalar -Text $Text

        # Assert
        $result.Ok | Should -BeFalse
        $result.Construct | Should -BeExactly $Construct
    }

    It 'reports a syntax error (no construct) for <Text>' -ForEach @(
        @{ Text = "'open" }
        @{ Text = "'a' b" }
        @{ Text = '"open' }
        @{ Text = '[a, , b]' }
        @{ Text = '[a] b' }
        @{ Text = "[a, 'b' c]" }
    ) {
        # Act
        $result = ConvertFrom-DocsPageYamlScalar -Text $Text

        # Assert
        $result.Ok | Should -BeFalse
        $result.Construct | Should -BeNullOrEmpty
    }

    It 'maps a syntax error inside a block to DOCS_PAGE_FRONT_MATTER_SYNTAX and a construct to UNSUPPORTED' {
        # Act
        $syntax = ConvertFrom-TestBlock -Line @("title: 'open")
        $unsupported = ConvertFrom-TestBlock -Line @('title: &a x')

        # Assert
        Get-TestCode -Result $syntax | Should -Be @('DOCS_PAGE_FRONT_MATTER_SYNTAX')
        Get-TestCode -Result $unsupported | Should -Be @('DOCS_PAGE_FRONT_MATTER_UNSUPPORTED')
    }
}

Describe 'ConvertFrom-DocsPageFrontMatter properties' {
    It 'returns the same value under seeded insertion of comment and blank lines inside the block' {
        # Arrange
        $seed = 1021
        $random = [System.Random]::new($seed)
        $base = @('owner: team-a', 'last_reviewed: 2026-10-30', 'audience:', '  - dev', '  - ops', 'diataxis_mode: "reference"', 'surface_refs: []', 'title: Page title')
        $expected = ConvertTo-DocsJsonText -Value (ConvertFrom-TestBlock -Line $base).Value

        for ($round = 0; $round -lt 25; $round++) {
            $lines = [System.Collections.Generic.List[string]]::new()
            foreach ($line in $base) {
                $count = $random.Next(0, 3)
                for ($n = 0; $n -lt $count; $n++) { $lines.Add($(if ($random.Next(0, 2) -eq 0) { '' } else { '# inserted ' + $random.Next() })) }
                $lines.Add($line)
            }

            # Act
            $actual = ConvertFrom-TestBlock -Line $lines.ToArray()

            # Assert (the seed is printed through -Because on failure)
            $actual.Findings.Count | Should -Be 0 -Because "seed $seed round $round"
            (ConvertTo-DocsJsonText -Value $actual.Value) | Should -BeExactly $expected -Because "seed $seed round $round"
        }
    }
}

Describe 'Test-DocsPageFrontMatter' {
    BeforeAll {
        # No -Force: the test binds to the DocsSchema instance that DocsPageFrontMatter imported, so the Test-Json mock reaches it.
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop
        $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
        $script:AllFields = @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs')
        $script:ElementId = 'cli-command-' + ('0123456789abcdef' * 4)
        $script:ValidLines = @(
            'owner: "team-docs"'
            'last_reviewed: "2026-10-30"'
            'audience: ["developers", "operators"]'
            'diataxis_mode: "reference"'
            "surface_refs: [`"$script:ElementId`"]"
            'title: "Command reference"'
            'extensions: {"vendor.note": "kept"}'
        )
        # Every fixture below that Test-DocsPageFrontMatter accepts with no finding is also checked against Test-Json.
        $script:AcceptedFixture = @(
            , $script:ValidLines
            , @('owner: team-docs', 'last_reviewed: 2028-02-29', 'audience:', '  - developers', 'diataxis_mode: how-to', 'surface_refs: []')
            , @('owner: a.b', 'last_reviewed: 2026-01-01', 'audience: [operators]', 'diataxis_mode: tutorial', 'surface_refs: []', 'title: T', 'extensions: {}')
        )

        function Invoke-TestValidation {
            param([string[]] $Line, [string[]] $RequiredField = $script:AllFields, [string[]] $AudienceId = @('developers', 'operators'))
            $parsed = ConvertFrom-TestBlock -Line $Line
            if ($null -eq $parsed.Value) { throw "fixture did not parse: $(@($parsed.Findings | ForEach-Object { $_.message }) -join '; ')" }
            Test-DocsPageFrontMatter -FrontMatter $parsed.Value -PagePath 'docs/page.md' -ComposedSchemaSet $script:Composed -RequiredField $RequiredField -AudienceId $AudienceId -FieldLine $parsed.FieldLine
        }

        function Get-TestLineVariant {
            # Returns the valid lines with the line of Key replaced (or removed when Value is $null).
            # Value is [object] because a [string] parameter turns $null into the empty string.
            param([string] $Key, [AllowNull()] [object] $Value)
            @($script:ValidLines | ForEach-Object { if ($_ -like "${Key}:*") { if ($null -ne $Value) { "${Key}: $Value" } } else { $_ } })
        }
    }

    It 'returns no finding for a complete valid page' {
        # Act
        $findings = Invoke-TestValidation -Line $script:ValidLines

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'reports DOCS_PAGE_FIELD_MISSING at /<_> for a required field that is absent' -ForEach @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs') {
        # Act
        $findings = Invoke-TestValidation -Line (Get-TestLineVariant -Key $_ -Value $null)

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_FIELD_MISSING'
        $findings[0].pointer | Should -BeExactly "/$_"
        $findings[0].artifact_path | Should -BeExactly 'docs/page.md'
        $findings[0].severity | Should -BeExactly 'error'
    }

    It 'reports no missing field when RequiredField is empty' {
        # Act
        $findings = Invoke-TestValidation -Line @('title: Only a title') -RequiredField @()

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'reports DOCS_PAGE_FIELD_UNKNOWN at the key pointer with the key line' {
        # Act
        $findings = Invoke-TestValidation -Line ($script:ValidLines + @('reviewer: someone'))

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_FIELD_UNKNOWN'
        $findings[0].pointer | Should -BeExactly '/reviewer'
        $findings[0].message | Should -Match '^line 9: '
    }

    It 'reports <Code> at <Pointer> for <Key>: <Value>' -ForEach @(
        @{ Key = 'owner'; Value = '5'; Code = 'DOCS_PAGE_OWNER_INVALID'; Pointer = '/owner' }
        @{ Key = 'owner'; Value = 'Team Docs'; Code = 'DOCS_PAGE_OWNER_INVALID'; Pointer = '/owner' }
        @{ Key = 'last_reviewed'; Value = '20261030'; Code = 'DOCS_PAGE_LAST_REVIEWED_INVALID'; Pointer = '/last_reviewed' }
        @{ Key = 'last_reviewed'; Value = 'true'; Code = 'DOCS_PAGE_LAST_REVIEWED_INVALID'; Pointer = '/last_reviewed' }
        @{ Key = 'audience'; Value = '[]'; Code = 'DOCS_PAGE_AUDIENCE_INVALID'; Pointer = '/audience' }
        @{ Key = 'audience'; Value = 'developers'; Code = 'DOCS_PAGE_AUDIENCE_INVALID'; Pointer = '/audience' }
        @{ Key = 'audience'; Value = '[developers, developers]'; Code = 'DOCS_PAGE_AUDIENCE_INVALID'; Pointer = '/audience/1' }
        @{ Key = 'diataxis_mode'; Value = 'guide'; Code = 'DOCS_PAGE_MODE_INVALID'; Pointer = '/diataxis_mode' }
        @{ Key = 'surface_refs'; Value = '[x]'; Code = 'DOCS_PAGE_SURFACE_REFS_INVALID'; Pointer = '/surface_refs/0' }
        @{ Key = 'surface_refs'; Value = 'x'; Code = 'DOCS_PAGE_SURFACE_REFS_INVALID'; Pointer = '/surface_refs' }
        @{ Key = 'title'; Value = "' '"; Code = 'DOCS_PAGE_TITLE_INVALID'; Pointer = '/title' }
        @{ Key = 'title'; Value = '[1]'; Code = 'DOCS_PAGE_TITLE_INVALID'; Pointer = '/title' }
        @{ Key = 'extensions'; Value = '{"note": 1}'; Code = 'DOCS_PAGE_EXTENSIONS_INVALID'; Pointer = '/extensions/note' }
        @{ Key = 'extensions'; Value = 'x'; Code = 'DOCS_PAGE_EXTENSIONS_INVALID'; Pointer = '/extensions' }
    ) {
        # Act
        $findings = Invoke-TestValidation -Line (Get-TestLineVariant -Key $Key -Value $Value)

        # Assert
        @($findings | Where-Object { $_.code -eq $Code -and $_.pointer -eq $Pointer }).Count | Should -BeGreaterThan 0
        @($findings | Where-Object { $_.code -ne $Code }).Count | Should -Be 0
        $findings[0].message | Should -Match "front matter field '$Key'"
    }

    It 'reports DOCS_PAGE_AUDIENCE_INVALID at /audience/0 for Dev_Ops' {
        # Act
        $findings = Invoke-TestValidation -Line (Get-TestLineVariant -Key 'audience' -Value '[Dev_Ops]')

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_AUDIENCE_INVALID'
        $findings[0].pointer | Should -BeExactly '/audience/0'
    }

    It 'reports DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE for 2026-02-30 and nothing for the leap day 2028-02-29' {
        # Act
        $invalid = Invoke-TestValidation -Line (Get-TestLineVariant -Key 'last_reviewed' -Value '2026-02-30')
        $leap = Invoke-TestValidation -Line (Get-TestLineVariant -Key 'last_reviewed' -Value '2028-02-29')

        # Assert
        $invalid.Count | Should -Be 1
        $invalid[0].code | Should -BeExactly 'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE'
        $invalid[0].pointer | Should -BeExactly '/last_reviewed'
        $invalid[0].message | Should -Match "^line 3: .*'2026-02-30'"
        $leap.Count | Should -Be 0
    }

    It 'reports DOCS_PAGE_AUDIENCE_UNDECLARED at /audience/<i> for a valid identifier outside the profile' {
        # Act
        $findings = Invoke-TestValidation -Line (Get-TestLineVariant -Key 'audience' -Value '[developers, qa]')

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_AUDIENCE_UNDECLARED'
        $findings[0].pointer | Should -BeExactly '/audience/1'
    }

    It 'fails closed with DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID at the root when Test-Json rejects a page with no field finding' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $false }

        # Act
        $findings = Invoke-TestValidation -Line $script:ValidLines

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID'
        $findings[0].pointer | Should -BeExactly ''
        Should -Invoke -CommandName Test-Json -ModuleName DocsSchema -Times 1 -Exactly
    }

    It 'drops the schema gate finding when a field finding explains the failure' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $false }

        # Act
        $findings = Invoke-TestValidation -Line (Get-TestLineVariant -Key 'owner' -Value $null)

        # Assert
        @($findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_FIELD_MISSING')
    }

    It 'accepts fixture <_> with no finding and Test-Json True against the composed page-metadata schema' -ForEach @(0, 1, 2) {
        # Arrange
        $parsed = ConvertFrom-TestBlock -Line $script:AcceptedFixture[$_]

        # Act
        $findings = Test-DocsPageFrontMatter -FrontMatter $parsed.Value -PagePath 'docs/page.md' -ComposedSchemaSet $script:Composed -RequiredField $script:AllFields -AudienceId @('developers', 'operators')
        $testJson = Test-Json -Json (ConvertTo-DocsJsonText -Value $parsed.Value) -Schema $script:Composed['page-metadata'].Text -ErrorAction SilentlyContinue

        # Assert
        $findings.Count | Should -Be 0
        $testJson | Should -BeTrue
    }
}

