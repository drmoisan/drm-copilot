#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSourceText.psm1 (issue #1022).

.DESCRIPTION
    Covers the canonical source lines against the 1020 declaration text, line-range reduction,
    key-path declarations, module dotted names, path-or-glob matching, diagnostic aggregation
    and element de-duplication. Inputs are in-memory strings; no file is read.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSourceText.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop

    function New-TestCandidate {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file.')]
        param([string] $Declaration, [int] $Line, [string] $Kind = 'config-key', [string] $Path = 'config/app.yaml')
        return @{
            Line      = $Line
            Parameter = @{ Kind = $Kind; Path = $Path; Declaration = $Declaration; Name = 'n'; AnalyzerId = 'config-files'; AnalysisMethod = 'scanner'; SourceText = "a`nb`nc`n"; LineRange = [int[]]@($Line, $Line) }
        }
    }
}

AfterAll {
    Remove-Module -Name DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsSourceLine' {
    It 'normalizes BOM, CRLF and CR and keeps form feed and U+2028 inside a line' {
        # Arrange
        $text = [string][char]0xFEFF + "a`r`nb`rc" + [char]0x0C + "d" + [char]0x2028 + "e`n"

        # Act
        $lines = ConvertTo-DocsSourceLine -Text $text

        # Assert
        $lines.Count | Should -Be 3
        $lines[0] | Should -BeExactly 'a'
        $lines[1] | Should -BeExactly 'b'
        $lines[2] | Should -BeExactly ('c' + [char]0x0C + 'd' + [char]0x2028 + 'e')
    }

    It 'returns zero lines for the empty text and one trailing LF only is dropped' {
        $empty = ConvertTo-DocsSourceLine -Text ''
        $empty.Count | Should -Be 0
        $newlineOnly = ConvertTo-DocsSourceLine -Text "`n"
        $newlineOnly.Count | Should -Be 0
        $two = ConvertTo-DocsSourceLine -Text "x`n`n"
        $two.Count | Should -Be 2
        $two[1] | Should -BeExactly ''
    }

    It 'property: ConvertTo-DocsSourceLine line i plus LF equals ConvertTo-DocsDeclarationText with range i to i' {
        # Arrange
        $seed = 102201
        $random = [System.Random]::new($seed)
        $alphabet = 'ab c=:(){}.' + [char]0x0C + [char]0x2028
        $endings = @("`n", "`r`n", "`r")

        for ($iteration = 0; $iteration -lt 120; $iteration++) {
            $count = $random.Next(1, 9)
            $builder = [System.Text.StringBuilder]::new()
            if ($random.Next(2) -eq 0) { [void] $builder.Append([char]0xFEFF) }
            for ($line = 0; $line -lt $count; $line++) {
                $length = $random.Next(0, 7)
                for ($c = 0; $c -lt $length; $c++) { [void] $builder.Append($alphabet[$random.Next($alphabet.Length)]) }
                if ($line -lt $count - 1 -or $random.Next(2) -eq 0) { [void] $builder.Append($endings[$random.Next($endings.Length)]) }
            }
            $text = $builder.ToString()
            $because = "seed $seed, iteration $iteration"

            # Act
            $lines = ConvertTo-DocsSourceLine -Text $text

            # Assert: the canonical text holds one LF per line.
            $lines.Count | Should -Be ([regex]::Matches((ConvertTo-DocsDeclarationText -Text $text), "`n").Count) -Because $because
            for ($index = 1; $index -le $lines.Count; $index++) {
                ($lines[$index - 1] + "`n") | Should -BeExactly (ConvertTo-DocsDeclarationText -Text $text -LineRange @($index, $index)) -Because "$because, line $index"
            }
        }
    }
}

Describe 'ConvertTo-DocsLineRange' {
    It 'returns the first start and the last end of several spans and accepts a flat pair' {
        ConvertTo-DocsLineRange -Span @(@(4, 6), @(9, 9), @(12, 15)) | Should -Be @(4, 15)
        ConvertTo-DocsLineRange -Span @(7, 8) | Should -Be @(7, 8)
    }

    It 'throws DOCS_LINE_RANGE_INVALID for an empty list, a malformed span or a start below 1' {
        { ConvertTo-DocsLineRange -Span @() } | Should -Throw -ExpectedMessage 'DOCS_LINE_RANGE_INVALID*'
        { ConvertTo-DocsLineRange -Span @(@(1, 2), @(3)) } | Should -Throw -ExpectedMessage 'DOCS_LINE_RANGE_INVALID*'
        { ConvertTo-DocsLineRange -Span @(0, 2) } | Should -Throw -ExpectedMessage 'DOCS_LINE_RANGE_INVALID*'
    }

    It 'property: ConvertTo-DocsLineRange returns the first start and the last end' {
        $seed = 102202
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 200; $iteration++) {
            $count = $random.Next(1, 6)
            $spans = [System.Collections.Generic.List[object]]::new()
            $cursor = $random.Next(1, 20)
            for ($i = 0; $i -lt $count; $i++) {
                $start = $cursor + $random.Next(0, 4)
                $end = $start + $random.Next(0, 5)
                $spans.Add([int[]]@($start, $end))
                $cursor = $end
            }
            $result = ConvertTo-DocsLineRange -Span $spans.ToArray()
            $result | Should -Be @($spans[0][0], $spans[$count - 1][1]) -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'ConvertTo-DocsKeyPathDeclaration' {
    It 'keeps bare segments and the array marker and quotes any other segment' {
        ConvertTo-DocsKeyPathDeclaration -Segment @('tool', 'black', 'line-length') | Should -BeExactly 'tool.black.line-length'
        ConvertTo-DocsKeyPathDeclaration -Segment @('items', '[]', 'name') | Should -BeExactly 'items.[].name'
        ConvertTo-DocsKeyPathDeclaration -Segment @('a.b', 'q"x', 'back\slash', '') | Should -BeExactly '"a.b"."q\"x"."back\\slash".""'
    }

    It 'property: ConvertTo-DocsKeyPathDeclaration is injective' {
        $seed = 102203
        $random = [System.Random]::new($seed)
        $alphabet = 'ab_-9."\[] '
        $seen = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
        for ($iteration = 0; $iteration -lt 400; $iteration++) {
            $count = $random.Next(1, 4)
            $segments = [string[]]@(1..$count | ForEach-Object { -join @(1..($random.Next(0, 5)) | ForEach-Object { $alphabet[$random.Next($alphabet.Length)] }) })
            $key = $segments -join "`u{1}"
            $declaration = ConvertTo-DocsKeyPathDeclaration -Segment $segments
            $previous = $null
            if ($seen.TryGetValue($declaration, [ref] $previous)) {
                $previous | Should -BeExactly $key -Because "seed $seed, iteration ${iteration}: two segment lists share one declaration"
            } else {
                $seen[$declaration] = $key
            }
        }
    }
}

Describe 'Get-DocsModuleDottedName' {
    It 'returns the dotted name relative to the longest containing root and the package name for __init__.py' {
        Get-DocsModuleDottedName -Path 'src/pkg/sub/mod.py' -SourceRoot @('src') | Should -BeExactly 'pkg.sub.mod'
        Get-DocsModuleDottedName -Path 'src/pkg/__init__.py' -SourceRoot @('src', 'src/pkg') | Should -BeNullOrEmpty
        Get-DocsModuleDottedName -Path 'src/pkg/__init__.py' -SourceRoot @('src') | Should -BeExactly 'pkg'
        Get-DocsModuleDottedName -Path 'tool.py' -SourceRoot @('.') | Should -BeExactly 'tool'
        Get-DocsModuleDottedName -Path 'lib/x.py' -SourceRoot @('src') | Should -BeNullOrEmpty
        Get-DocsModuleDottedName -Path 'src/x.txt' -SourceRoot @('src') | Should -BeNullOrEmpty
        Get-DocsModuleDottedName -Path 'src/__init__.py' -SourceRoot @('src') | Should -BeNullOrEmpty
    }

    It 'property: Get-DocsModuleDottedName splits the relative path on slashes only' {
        $seed = 102204
        $random = [System.Random]::new($seed)
        $names = @('a', 'b_c', 'd1', 'App', 'app')
        for ($iteration = 0; $iteration -lt 200; $iteration++) {
            $depth = $random.Next(1, 5)
            $segments = @(1..$depth | ForEach-Object { $names[$random.Next($names.Length)] })
            $root = $names[$random.Next($names.Length)]
            $path = $root + '/' + ($segments -join '/') + '.py'
            Get-DocsModuleDottedName -Path $path -SourceRoot @($root) | Should -BeExactly ($segments -join '.') -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Find-DocsPathOrGlobMatch' {
    It 'matches exact, prefix, * (no slash), ** (any), ? and is case-sensitive, first entry wins' {
        $entries = @(
            @{ path_or_glob = 'src/vendor/**' }
            @{ path_or_glob = 'docs' }
            @{ path_or_glob = 'src/*.py' }
            @{ path_or_glob = 'src/?.txt' }
            @{ path_or_glob = 'src/vendor/a.py' }
        )
        (Find-DocsPathOrGlobMatch -Path 'docs' -Entry $entries)['path_or_glob'] | Should -BeExactly 'docs'
        (Find-DocsPathOrGlobMatch -Path 'docs/guide.md' -Entry $entries)['path_or_glob'] | Should -BeExactly 'docs'
        Find-DocsPathOrGlobMatch -Path 'docsx/guide.md' -Entry $entries | Should -BeNullOrEmpty
        (Find-DocsPathOrGlobMatch -Path 'src/vendor/deep/x.py' -Entry $entries)['path_or_glob'] | Should -BeExactly 'src/vendor/**'
        (Find-DocsPathOrGlobMatch -Path 'src/vendor/a.py' -Entry $entries)['path_or_glob'] | Should -BeExactly 'src/vendor/**'
        (Find-DocsPathOrGlobMatch -Path 'src/m.py' -Entry $entries)['path_or_glob'] | Should -BeExactly 'src/*.py'
        Find-DocsPathOrGlobMatch -Path 'src/pkg/m.py' -Entry $entries | Should -BeNullOrEmpty
        (Find-DocsPathOrGlobMatch -Path 'src/a.txt' -Entry $entries)['path_or_glob'] | Should -BeExactly 'src/?.txt'
        Find-DocsPathOrGlobMatch -Path 'src/ab.txt' -Entry $entries | Should -BeNullOrEmpty
        Find-DocsPathOrGlobMatch -Path 'Docs/guide.md' -Entry $entries | Should -BeNullOrEmpty
        Find-DocsPathOrGlobMatch -Path 'src/m.py' -Entry @('src/*.py') | Should -BeExactly 'src/*.py'
    }

    It 'property: Find-DocsPathOrGlobMatch matches a path against its own ** prefix glob and not against a sibling' {
        $seed = 102205
        $random = [System.Random]::new($seed)
        $names = @('a', 'b', 'c', 'd')
        for ($iteration = 0; $iteration -lt 200; $iteration++) {
            $depth = $random.Next(2, 5)
            $segments = @(1..$depth | ForEach-Object { $names[$random.Next($names.Length)] })
            $path = $segments -join '/'
            $glob = $segments[0] + '/**'
            $sibling = 'z' + $segments[0] + '/**'
            (Find-DocsPathOrGlobMatch -Path $path -Entry @($sibling, $glob)) | Should -BeExactly $glob -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Diagnostic aggregate' {
    It 'keeps one diagnostic per (analyzer, code, path) with the count and first line in the message' {
        # Arrange
        $aggregate = New-DocsDiagnosticAggregate

        # Act
        Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-cli' -Code 'CLI_DYNAMIC_REGISTRATION' -Path 'src/cli.py' -Line 12
        Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-cli' -Code 'CLI_DYNAMIC_REGISTRATION' -Path 'src/cli.py' -Line 4
        Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-cli' -Code 'CLI_DYNAMIC_REGISTRATION' -Path 'src/Cli.py' -Line 7
        Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-cli' -Code 'PYTHON_LEXER_UNTERMINATED' -Path 'src/cli.py' -Line 1 -Severity 'error'

        # Assert
        $aggregate.Diagnostics.Count | Should -Be 3
        $first = @($aggregate.Diagnostics | Where-Object { $_['path'] -ceq 'src/cli.py' -and $_['code'] -ceq 'CLI_DYNAMIC_REGISTRATION' })[0]
        $first['message'] | Should -BeExactly '2 occurrence(s); first at line 4.'
        $first['severity'] | Should -BeExactly 'warning'
        $first['blocking'] | Should -BeFalse
        $first['analyzer_id'] | Should -BeExactly 'python-cli'
        $blocking = @($aggregate.Diagnostics | Where-Object { $_['code'] -ceq 'PYTHON_LEXER_UNTERMINATED' })[0]
        $blocking['severity'] | Should -BeExactly 'error'
        $blocking['blocking'] | Should -BeTrue
        @($aggregate.Diagnostics | ForEach-Object { $_['path'] }) | Should -Be @('src/Cli.py', 'src/cli.py', 'src/cli.py')
    }

    It 'rejects a code outside the 1020 grammar through New-DocsDiagnostic' {
        $aggregate = New-DocsDiagnosticAggregate
        { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-cli' -Code 'cli-dynamic' -Path 'src/cli.py' -Line 1 } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID*'
    }

    It 'property: New-DocsDiagnosticAggregate starts empty and independent of earlier aggregates' {
        $seed = 102206
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 50; $iteration++) {
            $earlier = New-DocsDiagnosticAggregate
            $adds = $random.Next(1, 5)
            for ($i = 0; $i -lt $adds; $i++) { Add-DocsDiagnosticOccurrence -Aggregate $earlier -AnalyzerId 'x' -Code 'CODE_A' -Path 'p.py' -Line ($i + 1) }
            $fresh = New-DocsDiagnosticAggregate
            $fresh.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $fresh.Entry.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $earlier.Diagnostics.Count | Should -Be 1 -Because "seed $seed, iteration $iteration"
        }
    }

    It 'property: Add-DocsDiagnosticOccurrence reports the minimum line and the number of calls regardless of order' {
        $seed = 102207
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $aggregate = New-DocsDiagnosticAggregate
            $count = $random.Next(1, 12)
            $lines = @(1..$count | ForEach-Object { $random.Next(1, 500) })
            foreach ($line in $lines) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId 'python-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path 'a/b.py' -Line $line }
            $minimum = ($lines | Measure-Object -Minimum).Minimum
            $aggregate.Diagnostics.Count | Should -Be 1 -Because "seed $seed, iteration $iteration"
            $aggregate.Diagnostics[0]['message'] | Should -BeExactly "$count occurrence(s); first at line $minimum." -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Select-DocsUniqueElement' {
    It 'drops an invalid declaration with DECLARATION_INVALID and a repeat with DUPLICATE_DECLARATION, keeping the first site by line' {
        # Arrange
        $aggregate = New-DocsDiagnosticAggregate
        $candidates = @(
            (New-TestCandidate -Declaration 'tool.b' -Line 3)
            (New-TestCandidate -Declaration ' bad ' -Line 1)
            (New-TestCandidate -Declaration 'tool.a' -Line 2)
            (New-TestCandidate -Declaration 'tool.b' -Line 2)
        )

        # Act
        $elements = Select-DocsUniqueElement -Candidate $candidates -Aggregate $aggregate

        # Assert
        $elements.Count | Should -Be 2
        @($elements | ForEach-Object { $_['declaration'] }) | Should -Be @('tool.a', 'tool.b')
        @($elements | ForEach-Object { $_['line_range']['start'] }) | Should -Be @(2, 2)
        $elements[0]['element_id'] | Should -BeExactly (Get-DocsElementId -Kind 'config-key' -Path 'config/app.yaml' -Declaration 'tool.a')
        $elements[0]['analysis_method'] | Should -BeExactly 'scanner'
        @($aggregate.Diagnostics | ForEach-Object { $_['code'] }) | Should -Be @('DECLARATION_INVALID', 'DUPLICATE_DECLARATION')
        foreach ($diagnostic in $aggregate.Diagnostics) {
            $diagnostic['analyzer_id'] | Should -BeExactly 'docs-inventory'
            $diagnostic['blocking'] | Should -BeFalse
        }
        $aggregate.Diagnostics[1]['message'] | Should -BeExactly '1 occurrence(s); first at line 3.'
    }

    It 'returns an empty list for no candidates' {
        $aggregate = New-DocsDiagnosticAggregate
        $elements = Select-DocsUniqueElement -Candidate @() -Aggregate $aggregate
        $elements.Count | Should -Be 0
    }

    It 'property: Select-DocsUniqueElement keeps one element per distinct declaration and never a later duplicate' {
        $seed = 102208
        $random = [System.Random]::new($seed)
        $pool = @('k.a', 'k.b', 'k.c', 'k.d')
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $aggregate = New-DocsDiagnosticAggregate
            $count = $random.Next(1, 10)
            $candidates = @(1..$count | ForEach-Object { New-TestCandidate -Declaration $pool[$random.Next($pool.Length)] -Line $random.Next(1, 4) })
            $elements = Select-DocsUniqueElement -Candidate $candidates -Aggregate $aggregate
            $distinct = @($candidates | ForEach-Object { $_['Parameter']['Declaration'] } | Sort-Object -Unique)
            $elements.Count | Should -Be $distinct.Count -Because "seed $seed, iteration $iteration"
            foreach ($element in $elements) {
                $minimum = (@($candidates | Where-Object { $_['Parameter']['Declaration'] -ceq $element['declaration'] } | ForEach-Object { $_['Line'] }) | Measure-Object -Minimum).Minimum
                $element['line_range']['start'] | Should -Be $minimum -Because "seed $seed, iteration $iteration"
            }
        }
    }
}
