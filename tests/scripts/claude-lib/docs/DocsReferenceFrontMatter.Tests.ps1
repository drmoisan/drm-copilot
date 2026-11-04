#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Example tests for DocsReferenceFrontMatter.psm1.

.DESCRIPTION
    Pins REFERENCE_FRONT_MATTER_INVALID for 1021 parse and validation findings (the message names
    the 1021 code and no returned code starts with DOCS_PAGE_), REFERENCE_MARKER_IN_FRONT_MATTER,
    REFERENCE_OWNER_UNRESOLVED, REFERENCE_AUDIENCE_MISSING, the page-level
    REFERENCE_MODE_CONFLICT, preservation of valid existing values, the title rule, the rendered
    block form, U+0085, U+2028 and U+2029 escaping, and BOM and CRLF inputs built in memory.
    COMPOSED-SET comes from New-DocsReferenceComposedSchemaSet; the only committed files read are
    the runtime schema files.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceFrontMatter.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsPageFrontMatter.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ComposedSet = New-DocsReferenceComposedSchemaSet
    $script:PagePath = 'docs/reference/cli-reference.md'
    $script:AudienceId = [string[]]@('admins', 'users')

    function Get-TestPagePlan {
        param([AllowNull()] [string] $Owner = 'docs-team', [string[]] $Audience = @('users'))
        return [ordered]@{ Path = $script:PagePath; Title = 'CLI reference'; Owner = $Owner; Audience = $Audience }
    }

    function Get-TestPageText {
        # Returns a page whose front matter holds the given lines, followed by a body line.
        param([string[]] $Field)
        return "---`n" + (($Field | ForEach-Object { $_ + "`n" }) -join '') + "---`nBody text.`n"
    }

    function Get-TestConverted {
        param([string] $Text)
        return ConvertFrom-DocsReferencePageText -Text $Text -PagePath $script:PagePath -ComposedSchemaSet $script:ComposedSet -AudienceId $script:AudienceId
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Split-DocsReferenceFrontMatter' {
    It 'splits a terminated block into front-matter lines and body lines' {
        # Act
        $split = Split-DocsReferenceFrontMatter -Text "---`nowner: `"a`"`n...`nbody`n"

        # Assert
        $split.HasFrontMatter | Should -BeTrue
        $split.Terminated | Should -BeTrue
        $split.FrontMatterLine | Should -Be @('owner: "a"')
        $split.ClosingDelimiter | Should -BeExactly '...'
        $split.BodyLine | Should -Be @('body', '')
        $split.BodyLineOffset | Should -Be 3
    }

    It 'returns the whole text as body when line 1 is not exactly ---' {
        # Act
        $split = Split-DocsReferenceFrontMatter -Text " ---`nowner: x`n---`n"

        # Assert
        $split.HasFrontMatter | Should -BeFalse
        $split.BodyLine | Should -Be @(' ---', 'owner: x', '---', '')
        $split.BodyLineOffset | Should -Be 0
    }

    It 'reports an unterminated block with an empty body' {
        # Act
        $split = Split-DocsReferenceFrontMatter -Text "---`nowner: x`n"

        # Assert
        $split.HasFrontMatter | Should -BeTrue
        $split.Terminated | Should -BeFalse
        $split.FrontMatterLine | Should -Be @('owner: x', '')
        $split.BodyLine.Count | Should -Be 0
        $split.BodyLineOffset | Should -Be 3
    }

    It 'gives identical output for BOM and CRLF variants built in memory' {
        # Arrange
        $plain = "---`nowner: `"a`"`n---`nbody`n"
        $variant = [string][char]0xFEFF + $plain.Replace("`n", "`r`n")

        # Act
        $expected = Split-DocsReferenceFrontMatter -Text $plain
        $actual = Split-DocsReferenceFrontMatter -Text $variant

        # Assert
        ($actual.FrontMatterLine -join '|') | Should -BeExactly ($expected.FrontMatterLine -join '|')
        ($actual.BodyLine -join '|') | Should -BeExactly ($expected.BodyLine -join '|')
        $actual.BodyLineOffset | Should -Be $expected.BodyLineOffset
    }
}

Describe 'ConvertFrom-DocsReferencePageText' {
    It 'reports REFERENCE_FRONT_MATTER_INVALID naming <Upstream> for <Case>' -ForEach @(
        @{ Case = 'an unterminated block'; Text = "---`nowner: `"a`"`n"; Upstream = 'DOCS_PAGE_FRONT_MATTER_UNTERMINATED' }
        @{ Case = 'a duplicate key'; Text = "---`nowner: `"a`"`nowner: `"b`"`n---`n"; Upstream = 'DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY' }
        @{ Case = 'an unsupported construct'; Text = "---`nowner: |`n---`n"; Upstream = 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED' }
        @{ Case = 'an unknown key'; Text = "---`ncolour: `"red`"`n---`n"; Upstream = 'DOCS_PAGE_FIELD_UNKNOWN' }
        @{ Case = 'an owner violating the page-metadata constraint'; Text = "---`nowner: `"Not Valid`"`n---`n"; Upstream = 'DOCS_PAGE_OWNER_INVALID' }
        @{ Case = 'a non-calendar last_reviewed'; Text = "---`nlast_reviewed: `"2026-02-30`"`n---`n"; Upstream = 'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE' }
        @{ Case = 'an audience outside the profile audiences'; Text = "---`naudience: [`"ghosts`"]`n---`n"; Upstream = 'DOCS_PAGE_AUDIENCE_UNDECLARED' }
    ) {
        # Act
        $result = Get-TestConverted -Text $Text

        # Assert
        $result.Value | Should -BeNullOrEmpty
        $result.Finding.Count | Should -Be 1
        $result.Finding[0]['code'] | Should -BeExactly 'REFERENCE_FRONT_MATTER_INVALID'
        $result.Finding[0]['severity'] | Should -BeExactly 'error'
        $result.Finding[0]['artifact_path'] | Should -BeExactly $script:PagePath
        $result.Finding[0]['message'].Contains($Upstream) | Should -BeTrue
        @($result.Finding | Where-Object { ([string] $_['code']).StartsWith('DOCS_PAGE_') }).Count | Should -Be 0
    }

    It 'reports REFERENCE_MARKER_IN_FRONT_MATTER with the page line of the marker' {
        # Arrange
        $text = Get-TestPageText -Field @('owner: "a"', '  <!-- docs:generated:start id=x -->')

        # Act
        $result = Get-TestConverted -Text $text

        # Assert
        @($result.Finding | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_MARKER_IN_FRONT_MATTER')
        $result.Finding[0]['message'] | Should -Match '^line 3: '
        $result.Value | Should -BeNullOrEmpty
    }

    It 'returns the parsed values, the body and its offset for valid front matter' {
        # Arrange
        $text = Get-TestPageText -Field @('owner: "docs-team"', 'audience: ["users"]', 'diataxis_mode: "reference"')

        # Act
        $result = Get-TestConverted -Text $text

        # Assert
        $result.Finding.Count | Should -Be 0
        $result.Value['owner'] | Should -BeExactly 'docs-team'
        $result.Value['audience'] | Should -Be @('users')
        $result.BodyLine | Should -Be @('Body text.', '')
        $result.BodyLineOffset | Should -Be 5
    }

    It 'returns no value and the whole body for a page without front matter' {
        # Act
        $result = Get-TestConverted -Text "# Title`n"

        # Assert
        $result.HasFrontMatter | Should -BeFalse
        $result.Value | Should -BeNullOrEmpty
        $result.Finding.Count | Should -Be 0
        $result.BodyLine | Should -Be @('# Title', '')
    }

    It 'reads BOM and CRLF variants built in memory like the LF form' {
        # Arrange
        $plain = Get-TestPageText -Field @('owner: "docs-team"', 'last_reviewed: "2026-01-02"')
        $variant = [string][char]0xFEFF + $plain.Replace("`n", "`r`n")

        # Act
        $expected = Get-TestConverted -Text $plain
        $actual = Get-TestConverted -Text $variant

        # Assert
        $actual.Finding.Count | Should -Be 0
        (ConvertTo-DocsCanonicalJson -Value $actual.Value) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $expected.Value)
        ($actual.BodyLine -join '|') | Should -BeExactly ($expected.BodyLine -join '|')
    }
}

Describe 'Resolve-DocsReferenceFrontMatterValue' {
    It 'preserves valid existing owner, audience, last_reviewed, title and extensions' {
        # Arrange
        $existing = (Get-TestConverted -Text (Get-TestPageText -Field @('owner: "page-owner"', 'audience: ["admins"]', 'last_reviewed: "2025-05-06"', 'title: "My title"', 'extensions: {"acme.note": "kept"}', 'surface_refs: []'))).Value

        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $existing -PagePlan (Get-TestPagePlan) -SurfaceRef @() -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $false

        # Assert
        $result.Finding.Count | Should -Be 0
        $result.Value['owner'] | Should -BeExactly 'page-owner'
        $result.Value['audience'] | Should -Be @('admins')
        $result.Value['last_reviewed'] | Should -BeExactly '2025-05-06'
        $result.Value['title'] | Should -BeExactly 'My title'
        $result.Value['extensions']['acme.note'] | Should -BeExactly 'kept'
    }

    It 'fills missing values from the page plan and the snapshot capture date, and sorts surface_refs' {
        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $null -PagePlan (Get-TestPagePlan -Audience @('users', 'admins')) -SurfaceRef @(('public-symbol-' + ('b' * 64)), ('config-key-' + ('a' * 64))) -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $true

        # Assert
        $result.Finding.Count | Should -Be 0
        @($result.Value.Keys) | Should -Be @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs', 'title')
        $result.Value['owner'] | Should -BeExactly 'docs-team'
        $result.Value['last_reviewed'] | Should -BeExactly '2026-01-02'
        $result.Value['audience'] | Should -Be @('users', 'admins')
        $result.Value['diataxis_mode'] | Should -BeExactly 'reference'
        $result.Value['surface_refs'] | Should -Be @(('config-key-' + ('a' * 64)), ('public-symbol-' + ('b' * 64)))
        $result.Value['title'] | Should -BeExactly 'CLI reference'
    }

    It 'adds no title to an existing page without one' {
        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $null -PagePlan (Get-TestPagePlan) -SurfaceRef @() -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $false

        # Assert
        $result.Value.Contains('title') | Should -BeFalse
    }

    It 'reports REFERENCE_OWNER_UNRESOLVED when no existing owner and no page owner exist' {
        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $null -PagePlan (Get-TestPagePlan -Owner $null) -SurfaceRef @() -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $true

        # Assert
        @($result.Finding | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_OWNER_UNRESOLVED')
        $result.Finding[0]['pointer'] | Should -BeExactly '/owner'
        $result.Finding[0]['severity'] | Should -BeExactly 'error'
        $result.Value.Contains('owner') | Should -BeFalse
    }

    It 'reports REFERENCE_AUDIENCE_MISSING when no existing audience and the root has none' {
        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $null -PagePlan (Get-TestPagePlan -Audience @()) -SurfaceRef @() -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $true

        # Assert
        @($result.Finding | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_AUDIENCE_MISSING')
        $result.Finding[0]['pointer'] | Should -BeExactly '/audience'
    }

    It 'reports a page REFERENCE_MODE_CONFLICT for an existing diataxis_mode other than reference' {
        # Arrange
        $existing = (Get-TestConverted -Text (Get-TestPageText -Field @('diataxis_mode: "how-to"'))).Value

        # Act
        $result = Resolve-DocsReferenceFrontMatterValue -Existing $existing -PagePlan (Get-TestPagePlan) -SurfaceRef @() -CapturedAt '2026-01-02T03:04:05Z' -IsNewPage $false

        # Assert
        @($result.Finding | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_MODE_CONFLICT')
        $result.Finding[0]['artifact_path'] | Should -BeExactly $script:PagePath
        $result.Value['diataxis_mode'] | Should -BeExactly 'reference'
    }
}

Describe 'ConvertTo-DocsReferenceFrontMatterText' {
    It 'renders --- delimiters around one key and JSON value line per field in the fixed order' {
        # Arrange
        $value = [ordered]@{ title = 'T'; surface_refs = [string[]]@(); diataxis_mode = 'reference'; audience = [string[]]@('users'); last_reviewed = '2026-01-02'; owner = 'docs-team' }

        # Act
        $text = ConvertTo-DocsReferenceFrontMatterText -Value $value

        # Assert
        $text.EndsWith("---`n") | Should -BeTrue
        [string[]] $lines = $text.Substring(0, $text.Length - 1).Split("`n")
        $lines[0] | Should -BeExactly '---'
        $lines[$lines.Count - 1] | Should -BeExactly '---'
        @($lines[1..($lines.Count - 2)] | ForEach-Object { $_.Substring(0, $_.IndexOf(':')) }) | Should -Be @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs', 'title')
        foreach ($line in $lines[1..($lines.Count - 2)]) {
            $line | Should -Match '^[a-z_]+: \S'
            (ConvertFrom-DocsJsonText -Text $line.Substring($line.IndexOf(': ') + 2)).Findings.Count | Should -Be 0
        }
        $lines[1] | Should -BeExactly 'owner: "docs-team"'
        $lines[5] | Should -BeExactly 'surface_refs: []'
    }

    It 're-escapes U+0085, U+2028 and U+2029 so the value stays on one line and parses back' {
        # Arrange
        $title = 'a' + [char]0x85 + 'b' + [char]0x2028 + 'c' + [char]0x2029 + 'd'

        # Act
        $text = ConvertTo-DocsReferenceFrontMatterText -Value ([ordered]@{ owner = 'docs-team'; title = $title })

        # Assert
        $text | Should -Not -Match '[\x85\p{Zl}\p{Zp}]'
        $text.Contains('"a\u0085b\u' + '2028c\u' + '2029d"') | Should -BeTrue
        (ConvertFrom-DocsPageFrontMatter -Text ($text + "body`n") -PagePath $script:PagePath).Value['title'] | Should -BeExactly $title
    }

    It 'writes a non-integral extension number with the JSON writer' {
        # Act
        $text = ConvertTo-DocsReferenceFrontMatterText -Value ([ordered]@{ extensions = [ordered]@{ 'acme.ratio' = 1.5 } })

        # Assert
        $text | Should -BeExactly ("---`n" + 'extensions: {"acme.ratio":1.5}' + "`n---`n")
    }
}
