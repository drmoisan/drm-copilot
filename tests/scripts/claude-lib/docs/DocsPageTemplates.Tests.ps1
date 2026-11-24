#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for the page-check base configuration templates and their init template rows.

.DESCRIPTION
    Reads the committed templates under .claude/lib/docs/templates/page-check/ and the module
    text of DocsProfileCommands.psm1 read-only. Covers the rows under the 1021 anchor, the
    zero-byte consumer-owned vocabulary, the Vale rule kinds, the DocsTonality styles of the 1219
    anchor (issue #1219), repository-name neutrality, the
    markdownlint object, and init dry-run and -Write behavior through the in-memory command
    context of Docs.TestSupport.psm1. No file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    $script:ModulePath = Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileCommands.psm1'
    $script:TemplateRoot = Join-Path -Path $script:LibraryRoot -ChildPath 'docs/templates/page-check'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
    # No -Force: bind to the sibling instance that DocsProfileCommands imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Expected = [ordered]@{
        '.claude/lib/docs/templates/page-check/markdownlint.json'                    = 'docs/documentation-estate/.markdownlint.json'
        '.claude/lib/docs/templates/page-check/vale.ini'                             = 'docs/documentation-estate/.vale.ini'
        '.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml' = 'docs/documentation-estate/.vale/styles/DocsBase/HeadingPunctuation.yml'
        '.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml'       = 'docs/documentation-estate/.vale/styles/DocsBase/Placeholders.yml'
        '.claude/lib/docs/templates/page-check/vale/Project/accept.txt'              = 'docs/documentation-estate/.vale/styles/config/vocabularies/Project/accept.txt'
    }
    $script:TonalityName = @('Certainty', 'Exclamation', 'Filler', 'Hyperbole', 'Intensifiers')
    $script:TonalitySource = [ordered]@{}
    foreach ($name in $script:TonalityName) { $script:TonalitySource[".claude/lib/docs/templates/page-check/vale/DocsTonality/$name.yml"] = "docs/documentation-estate/.vale/styles/DocsTonality/$name.yml" }
    $script:TemplateFile = @(Get-ChildItem -LiteralPath $script:TemplateRoot -File -Recurse)
    # The committed text of every init template source (1021, 1034 and 1219 rows), so init -Write reads no absent source.
    $script:SourceText = @{}
    foreach ($row in (Get-DocsInitTemplate)) { $script:SourceText[[string] $row.Source] = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepositoryRoot -ChildPath $row.Source)) }
    # Issue #1173 B6: init exits 0 only when the starter source root lists a file.
    $script:SourceText['src/app.py'] = "value = 1`n"

    function Get-TestAnchorRowSource {
        # Returns the Source literals of the row lines between the 1021 and 1034 anchors of the module text.
        $lines = @(Get-Content -LiteralPath $script:ModulePath)
        $start = [array]::IndexOf([string[]] @($lines | ForEach-Object { $_.Trim() }), '# --- 1021: page-check configuration ---')
        $sources = [System.Collections.Generic.List[string]]::new()
        for ($index = $start + 1; $index -lt $lines.Count -and $lines[$index].Trim() -cne '# --- 1034: docs workflow ---'; $index++) {
            $match = [regex]::Match($lines[$index], "Source = '(?<source>[^']+)'")
            if ($match.Success) { $sources.Add($match.Groups['source'].Value) }
        }
        return , $sources.ToArray()
    }
}

AfterAll {
    Remove-Module -Name DocsProfileCommands, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'page-check template rows' {
    It 'places one row per template under the 1021 anchor, each naming a committed file under templates/page-check/' {
        # Act
        $sources = Get-TestAnchorRowSource
        $rows = Get-DocsInitTemplate

        # Assert
        $sources | Should -Be @($script:Expected.Keys)
        foreach ($source in $sources) {
            $source | Should -BeLike '.claude/lib/docs/templates/page-check/*'
            [System.IO.File]::Exists((Join-Path -Path $script:RepositoryRoot -ChildPath $source)) | Should -BeTrue -Because $source
            $row = @($rows | Where-Object { $_.Source -ceq $source })
            $row.Count | Should -Be 1
            $row[0].Destination | Should -BeExactly $script:Expected[$source]
        }
        $script:TemplateFile.Count | Should -Be ($script:Expected.Count + $script:TonalitySource.Count) -Because 'the page-check folder holds the 1021 templates and the 1219 DocsTonality styles'
    }
}

Describe 'page-check template content' {
    It 'ships the consumer-owned vocabulary file with zero bytes' {
        (Get-Item -LiteralPath (Join-Path -Path $script:TemplateRoot -ChildPath 'vale/Project/accept.txt')).Length | Should -Be 0
    }

    It 'uses no substitution or spelling rule in any Vale style' {
        # Arrange
        $styles = @($script:TemplateFile | Where-Object { $_.Extension -eq '.yml' })

        # Assert
        $styles.Count | Should -Be 7
        foreach ($style in $styles) {
            $text = [System.IO.File]::ReadAllText($style.FullName)
            $text | Should -Match '(?m)^extends: existence$'
            $text | Should -Not -Match '(?m)^extends:\s*(substitution|spelling)\b'
        }
    }

    It 'contains no framework repository name in any template' {
        foreach ($file in $script:TemplateFile) {
            [System.IO.File]::ReadAllText($file.FullName).IndexOf('drm-copilot', [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1 -Because $file.Name
        }
    }

    It 'parses markdownlint.json with ConvertFrom-DocsJsonText to the specified object' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text $script:SourceText['.claude/lib/docs/templates/page-check/markdownlint.json']
        $expected = [ordered]@{ default = $true; MD013 = $false; MD025 = [ordered]@{ front_matter_title = '' }; MD033 = [ordered]@{ allowed_elements = @('a') } }

        # Assert
        @($parsed.Findings).Count | Should -Be 0
        (ConvertTo-DocsCanonicalJson -Value $parsed.Value) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $expected)
    }

    It 'configures Vale with the styles path, alert level, vocabulary and base styles and no Packages key' {
        # Arrange
        $text = $script:SourceText['.claude/lib/docs/templates/page-check/vale.ini']

        # Assert
        $text | Should -Match '(?m)^StylesPath = \.vale/styles$'
        $text | Should -Match '(?m)^MinAlertLevel = warning$'
        $text | Should -Match '(?m)^Vocab = Project$'
        $text | Should -Match '(?m)^\[\*\.md\]$'
        $text | Should -Match '(?m)^BasedOnStyles = Vale, DocsBase, DocsTonality$'
        $text | Should -Match '(?ms)^\[\*\.md\]$(?:(?!^\[).)*^Vale\.Spelling = warning$' -Because 'Vale.Spelling = warning is set under [*.md]'
        $text | Should -Not -Match '(?m)^Packages'
    }

    It 'lists TODO, TBD and FIXME as placeholder tokens and scopes the punctuation rule to headings' {
        $script:SourceText['.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml'] | Should -Match '(?s)tokens:\s*- TODO\s*- TBD\s*- FIXME'
        $script:SourceText['.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml'] | Should -Match '(?m)^scope: heading$'
    }
}

Describe 'DocsTonality styles' {
    BeforeDiscovery {
        $script:TonalityCase = @(
            @{ Name = 'Certainty'; Level = 'error' }
            @{ Name = 'Exclamation'; Level = 'error' }
            @{ Name = 'Filler'; Level = 'error' }
            @{ Name = 'Hyperbole'; Level = 'error' }
            @{ Name = 'Intensifiers'; Level = 'warning' }
        )
    }

    It 'writes the five DocsTonality styles with their template text under -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceText

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        foreach ($source in $script:TonalitySource.Keys) {
            $write = @($test.WriteLog | Where-Object { $_.RelativePath -ceq $script:TonalitySource[$source] })
            $write.Count | Should -Be 1 -Because $source
            $write[0].Mode | Should -BeExactly 'create'
            $write[0].Text | Should -BeExactly $script:SourceText[$source] -Because $source
            $write[0].Text.Length | Should -BeGreaterThan 0
        }
    }

    It 'declares existence, ignorecase, scope and level in <Name>' -ForEach $script:TonalityCase {
        # Arrange
        $text = $script:SourceText[".claude/lib/docs/templates/page-check/vale/DocsTonality/$Name.yml"]

        # Assert
        $text | Should -Match '(?m)^extends: existence$'
        $text | Should -Match '(?m)^ignorecase: true$'
        $text | Should -Match '(?m)^scope: ~blockquote$'
        $text | Should -Match ('(?m)^level: ' + $Level + '$')
        $text | Should -Match '(?m)^tokens:$'
    }

    It 'carries the tonality policy comment and no repository name in <Name>' -ForEach $script:TonalityCase {
        # Arrange: the leading comment block is the # lines before the first non-comment line.
        $text = $script:SourceText[".claude/lib/docs/templates/page-check/vale/DocsTonality/$Name.yml"]
        $lines = @($text -split "`r?`n")
        $first = [array]::FindIndex([string[]] $lines, [Predicate[string]] { param($line) -not $line.StartsWith('#', [System.StringComparison]::Ordinal) })
        $comment = (@($lines | Select-Object -First $first) -join "`n")

        # Assert
        $first | Should -BeGreaterThan 0
        $comment.Contains('.claude/rules/tonality.md', [System.StringComparison]::Ordinal) | Should -BeTrue
        if ($Name -ceq 'Intensifiers') {
            foreach ($word in 'just', 'very', 'easy', 'easily', 'absent') { $comment | Should -Match "\b$word\b" -Because "the Intensifiers comment names '$word'" }
        }
        foreach ($token in 'drm-copilot', 'rgf', 'Rgf') { $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "$Name names no repository ('$token')" }
    }

    It 'lists perfect and world-class in Hyperbole and the nonword exclamation tokens' {
        # Arrange
        $hyperbole = $script:SourceText['.claude/lib/docs/templates/page-check/vale/DocsTonality/Hyperbole.yml']
        $exclamation = $script:SourceText['.claude/lib/docs/templates/page-check/vale/DocsTonality/Exclamation.yml']

        # Assert
        $hyperbole | Should -Match '(?m)^  - perfect$'
        $hyperbole | Should -Match '(?m)^  - world-class$'
        $exclamation | Should -Match '(?m)^nonword: true$'
        $exclamation.Contains('  - ''!\s*$''', [System.StringComparison]::Ordinal) | Should -BeTrue
        $exclamation.Contains('  - ''!\s+[A-Z]''', [System.StringComparison]::Ordinal) | Should -BeTrue
    }
}

Describe 'init with the page-check templates' {
    It 'lists the five destinations in planned_writes and writes nothing without -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceText

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context $test.Context
        $paths = @($result.Result.planned_writes | ForEach-Object { $_.path })

        # Assert
        $result.ExitCode | Should -Be 0
        $test.WriteLog.Count | Should -Be 0
        foreach ($destination in $script:Expected.Values) { $paths | Should -Contain $destination }
    }

    It 'writes each destination with the text of its template source under -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceText

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 0
        foreach ($source in $script:Expected.Keys) {
            $write = @($test.WriteLog | Where-Object { $_.RelativePath -ceq $script:Expected[$source] })
            $write.Count | Should -Be 1 -Because $source
            $write[0].Mode | Should -BeExactly 'create'
            $write[0].Text | Should -BeExactly $script:SourceText[$source] -Because $source
        }
        $test.Files['docs/documentation-estate/.vale/styles/config/vocabularies/Project/accept.txt'] | Should -BeExactly ''
    }

    It 'plans and writes no linter configuration at the repository root (issue #1169)' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceText

        # Act
        $planned = Invoke-DocsInitCommand -Argument @{} -Context $test.Context
        $written = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context
        $paths = @(@($planned.Result.planned_writes | ForEach-Object { [string] $_.path }) + @($test.WriteLog | ForEach-Object { [string] $_.RelativePath }))

        # Assert
        $written.ExitCode | Should -Be 0
        $paths.Count | Should -BeGreaterThan 0
        foreach ($path in $paths) {
            $path | Should -Not -BeExactly '.markdownlint.json'
            $path | Should -Not -BeExactly '.vale.ini'
            $path.StartsWith('.vale/', [System.StringComparison]::Ordinal) | Should -BeFalse -Because "'$path' must not be written under the root .vale/ directory"
        }
    }
}
