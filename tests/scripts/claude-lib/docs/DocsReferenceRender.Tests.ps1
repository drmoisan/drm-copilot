#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Example and seeded property tests for DocsReferenceRender.psm1.

.DESCRIPTION
    Example tests pin each heading word, the source-line parenthesis, the code-span padding and
    delimiter rules, property-line ordering and value forms, and the rejection of
    architecture-component. Seeded property tests run one case per seed in 11, 23, 47, 101 and
    211; each case builds [System.Random]::new($Seed), draws a bounded number of inputs through
    DocsReference.TestSupport.psm1, asserts relations rather than drawn values, and passes
    -Because "seed $Seed". All inputs are in-memory strings, arrays and dictionaries; the suite
    reads no file, creates no file and starts no process.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceRender.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:HeadingWord = @{
        'cli-command'   = '## Command'
        'cli-option'    = '### Option'
        'http-route'    = '## Route'
        'config-key'    = '## Key'
        'public-symbol' = '## Symbol'
    }

    function Get-TestHeadingText {
        # Returns the text after the ATX heading marker of a heading line, else $null.
        param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line)
        $match = [regex]::Match($Line, '^#{1,6} (?<text>.*)$')
        if ($match.Success) { return $match.Groups['text'].Value }
        return $null
    }

    function Get-TestLongestBacktickRun {
        param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)
        $longest = 0
        foreach ($run in [regex]::Matches($Text, '`+')) { if ($run.Length -gt $longest) { $longest = $run.Length } }
        return $longest
    }

    function Get-TestElement {
        # Builds an in-memory element dictionary with the fields the renderer reads.
        param(
            [string] $Kind = 'cli-command',
            [string] $Declaration = 'tool run',
            [string] $Name = 'run',
            [string] $Path = 'src/tool.py',
            [AllowNull()] [object] $LineRange = ([ordered]@{ start = [long] 2; end = [long] 9 }),
            [AllowEmptyCollection()] [object[]] $Property = @()
        )
        return [ordered]@{ kind = $Kind; declaration = $Declaration; name = $Name; path = $Path; line_range = $LineRange; properties = $Property }
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsReferenceSingleLine' {
    It 'replaces control and separator characters with spaces, collapses runs and trims' {
        # Arrange
        $text = "  a`tb" + [char]0x2028 + 'c' + [char]0x2029 + [char]0x85 + 'd  '

        # Act
        $result = ConvertTo-DocsReferenceSingleLine -Text $text

        # Assert
        $result | Should -BeExactly 'a b c d'
    }

    It 'returns the empty string for a text made only of control characters' {
        ConvertTo-DocsReferenceSingleLine -Text ("`t" + [char]0x7F + "`n") | Should -BeExactly ''
    }

    It 'has no control, separator, double or edge space and is idempotent (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 40; $draw++) {
            $text = Get-DocsReferenceRandomText -Random $random -MaxFragment 12

            # Act
            $once = ConvertTo-DocsReferenceSingleLine -Text $text
            $twice = ConvertTo-DocsReferenceSingleLine -Text $once

            # Assert
            $once | Should -Not -Match '[\p{Cc}\p{Zl}\p{Zp}]' -Because "seed $Seed"
            $once.Contains('  ') | Should -BeFalse -Because "seed $Seed"
            ($once.StartsWith(' ') -or $once.EndsWith(' ')) | Should -BeFalse -Because "seed $Seed"
            $twice | Should -BeExactly $once -Because "seed $Seed"
        }
    }
}

Describe 'ConvertTo-DocsReferenceCodeSpan' {
    It 'renders <Case>' -ForEach @(
        @{ Case = 'plain text with a single backtick delimiter'; Text = 'abc'; Expected = '`abc`' }
        @{ Case = 'an internal backtick with a longer delimiter'; Text = 'a`b'; Expected = '``a`b``' }
        @{ Case = 'a leading backtick with padding'; Text = '`x'; Expected = '`` `x ``' }
        @{ Case = 'a trailing backtick run with padding'; Text = 'x``'; Expected = '``` x`` ```' }
        @{ Case = 'leading and trailing spaces with padding'; Text = ' a '; Expected = '`  a  `' }
        @{ Case = 'a leading space only without padding'; Text = ' a'; Expected = '` a`' }
    ) {
        ConvertTo-DocsReferenceCodeSpan -Text $Text | Should -BeExactly $Expected
    }

    It 'rejects an empty text' {
        { ConvertTo-DocsReferenceCodeSpan -Text '' } | Should -Throw '*non-empty*'
    }

    It 'rejects a multi-line text' {
        { ConvertTo-DocsReferenceCodeSpan -Text "a`nb" } | Should -Throw '*single-line*'
    }

    It 'decodes to the input and uses a delimiter longer than every internal backtick run (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 40; $draw++) {
            $text = ConvertTo-DocsReferenceSingleLine -Text (Get-DocsReferenceRandomText -Random $random -MaxFragment 12)
            if ($text.Length -eq 0) { $text = 'x' }

            # Act
            $span = ConvertTo-DocsReferenceCodeSpan -Text $text

            # Assert
            ConvertFrom-DocsReferenceCodeSpanText -Text $span | Should -BeExactly $text -Because "seed $Seed"
            ([regex]::Match($span, '^`+')).Length | Should -BeGreaterThan (Get-TestLongestBacktickRun -Text $text) -Because "seed $Seed"
        }
    }
}

Describe 'Format-DocsReferenceSourceLine' {
    It 'appends the line range in parentheses when a range is given' {
        Format-DocsReferenceSourceLine -Path 'src/a.py' -LineRange ([ordered]@{ start = [long] 3; end = [long] 7 }) | Should -BeExactly '- Source: `src/a.py` (lines 3-7)'
    }

    It 'omits the parenthesis when the range is null' {
        Format-DocsReferenceSourceLine -Path 'src/a.py' -LineRange $null | Should -BeExactly '- Source: `src/a.py`'
    }

    It 'renders one source line whose code span decodes to the single-line path, with the range exactly when given (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 40; $draw++) {
            $path = 'src/' + (Get-DocsReferenceRandomText -Random $random -MaxFragment 10)
            $range = $null
            $suffix = ''
            if ($random.Next(0, 2) -eq 1) {
                $start = $random.Next(1, 500)
                $end = $random.Next($start, 1000)
                $range = [ordered]@{ start = [long] $start; end = [long] $end }
                $suffix = " (lines $start-$end)"
            }

            # Act
            $line = Format-DocsReferenceSourceLine -Path $path -LineRange $range

            # Assert
            ($line.Contains("`n") -or $line.Contains("`r")) | Should -BeFalse -Because "seed $Seed"
            $line.StartsWith('- Source: ') | Should -BeTrue -Because "seed $Seed"
            if ($null -eq $range) {
                $line.EndsWith('`') | Should -BeTrue -Because "seed $Seed"
            } else {
                $line.EndsWith($suffix) | Should -BeTrue -Because "seed $Seed"
            }
            $span = $line.Substring('- Source: '.Length, $line.Length - '- Source: '.Length - $suffix.Length)
            ConvertFrom-DocsReferenceCodeSpanText -Text $span | Should -BeExactly (ConvertTo-DocsReferenceSingleLine -Text $path) -Because "seed $Seed"
        }
    }
}

Describe 'Format-DocsReferencePropertyLine' {
    It 'orders properties by ordinal name and renders canonical JSON values' {
        # Arrange
        $property = @(
            [ordered]@{ name = 'type'; value = 'str' }
            [ordered]@{ name = 'Alias'; value = $null }
            [ordered]@{ name = 'count'; value = [long] 3 }
            [ordered]@{ name = 'enabled'; value = $true }
        )

        # Act
        $lines = Format-DocsReferencePropertyLine -Property $property

        # Assert
        $lines | Should -Be @(
            '- Property `Alias`: `null`'
            '- Property `count`: `3`'
            '- Property `enabled`: `true`'
            '- Property `type`: `"str"`'
        )
    }

    It 'writes a non-integral number with the JSON writer and an integral double as an integer' {
        # Act
        $lines = Format-DocsReferencePropertyLine -Property @([ordered]@{ name = 'ratio'; value = 1.5 }, [ordered]@{ name = 'whole'; value = [double] 2 })

        # Assert
        $lines | Should -Be @('- Property `ratio`: `1.5`', '- Property `whole`: `2`')
    }

    It 'single-lines a string value that contains a line separator' {
        # Act
        $lines = Format-DocsReferencePropertyLine -Property @([ordered]@{ name = 'note'; value = 'a' + [char]0x2028 + 'b' })

        # Assert
        $lines | Should -Be @('- Property `note`: `"a b"`')
    }

    It 'returns no line for an empty property array' {
        # Act
        [string[]] $lines = Format-DocsReferencePropertyLine -Property @()

        # Assert
        $lines.Count | Should -Be 0
    }

    It 'renders one ordinal-ordered property line per property, invariant under permutation (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $pool = @('default', 'type', 'required', 'env-var', 'alias', 'since.v1', 'Zed', 'a_b')

        for ($draw = 0; $draw -lt 40; $draw++) {
            $shuffledPool = Get-DocsReferenceShuffled -Random $random -Item $pool
            $names = @($shuffledPool | Select-Object -First ($random.Next(0, 6)))
            $property = @($names | ForEach-Object {
                    $value = switch ($random.Next(0, 4)) { 0 { Get-DocsReferenceRandomText -Random $random } 1 { [long] $random.Next(-50, 50) } 2 { $true } default { $null } }
                    [ordered]@{ name = [string] $_; value = $value }
                })
            [string[]] $expectedOrder = @($names | ForEach-Object { [string] $_ })
            [Array]::Sort($expectedOrder, [System.StringComparer]::Ordinal)

            # Act
            [string[]] $lines = Format-DocsReferencePropertyLine -Property $property
            [string[]] $permuted = Format-DocsReferencePropertyLine -Property (Get-DocsReferenceShuffled -Random $random -Item $property)

            # Assert
            $lines.Count | Should -Be $property.Count -Because "seed $Seed"
            [string[]] $renderedNames = @($lines | ForEach-Object { [regex]::Match($_, '^- Property `(?<name>[^`]+)`: ').Groups['name'].Value })
            ($renderedNames -join "`n") | Should -BeExactly ($expectedOrder -join "`n") -Because "seed $Seed"
            @($lines | Where-Object { -not $_.StartsWith('- Property ') }).Count | Should -Be 0 -Because "seed $Seed"
            ($permuted -join "`n") | Should -BeExactly ($lines -join "`n") -Because "seed $Seed"
        }
    }
}

Describe 'Get-DocsReferenceBlockLine' {
    It 'starts the block with <Heading> for kind <Kind>' -ForEach @(
        @{ Kind = 'cli-command'; Heading = '## Command' }
        @{ Kind = 'cli-option'; Heading = '### Option' }
        @{ Kind = 'http-route'; Heading = '## Route' }
        @{ Kind = 'config-key'; Heading = '## Key' }
        @{ Kind = 'public-symbol'; Heading = '## Symbol' }
    ) {
        # Act
        $lines = Get-DocsReferenceBlockLine -Element (Get-TestElement -Kind $Kind -Declaration 'decl x')

        # Assert
        $lines[0] | Should -BeExactly ($Heading + ' `decl x`')
    }

    It 'renders the heading, a blank line, the name, the source and the property lines in order' {
        # Arrange
        $element = Get-TestElement -Property @([ordered]@{ name = 'type'; value = 'int' })

        # Act
        $lines = Get-DocsReferenceBlockLine -Element $element

        # Assert
        $lines | Should -Be @(
            '## Command `tool run`'
            ''
            '- Name: `run`'
            '- Source: `src/tool.py` (lines 2-9)'
            '- Property `type`: `"int"`'
        )
    }

    It 'renders an element without a properties key and without a line range' {
        # Arrange
        $element = [ordered]@{ kind = 'config-key'; declaration = 'server.port'; name = 'port'; path = 'config/app.toml'; line_range = $null }

        # Act
        $lines = Get-DocsReferenceBlockLine -Element $element

        # Assert
        $lines | Should -Be @('## Key `server.port`', '', '- Name: `port`', '- Source: `config/app.toml`')
    }

    It 'keeps a declaration that starts with <Case> inside a code span after the fixed heading word' -ForEach @(
        @{ Case = 'how to'; Declaration = 'how to install'; Expected = '## Command `how to install`' }
        @{ Case = 'Step 1'; Declaration = 'Step 1 run'; Expected = '## Command `Step 1 run`' }
        @{ Case = 'an angle bracket'; Declaration = '<b>x</b>'; Expected = '## Command `<b>x</b>`' }
    ) {
        (Get-DocsReferenceBlockLine -Element (Get-TestElement -Declaration $Declaration))[0] | Should -BeExactly $Expected
    }

    It 'throws for an architecture-component element' {
        { Get-DocsReferenceBlockLine -Element (Get-TestElement -Kind 'architecture-component') } | Should -Throw '*architecture-component*'
    }

    It 'throws for an unknown kind' {
        { Get-DocsReferenceBlockLine -Element (Get-TestElement -Kind 'Cli-Command') } | Should -Throw '*Cli-Command*'
    }

    It 'renders the kind heading word, no instructional heading, no line starting with an angle bracket or a marker and no trailing space (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $prefixes = @('how to ', 'How To ', 'Step 1 ', 'step 22 ', '<', '<!-- docs:generated:start id=x --> ', '')

        for ($draw = 0; $draw -lt 40; $draw++) {
            $prefix = $prefixes[$random.Next(0, $prefixes.Count)]
            $declaration = ($prefix + (Get-DocsReferenceRandomText -Random $random -ForIdentity)).Trim()
            $element = New-DocsReferenceRandomElement -Random $random -Declaration $declaration

            # Act
            [string[]] $lines = Get-DocsReferenceBlockLine -Element $element

            # Assert
            $lines[0].StartsWith($script:HeadingWord[[string] $element['kind']] + ' ') | Should -BeTrue -Because "seed $Seed"
            foreach ($line in $lines) {
                $heading = Get-TestHeadingText -Line $line
                if ($null -ne $heading) {
                    $heading | Should -Not -Match '(?i)^how to ' -Because "seed $Seed"
                    $heading | Should -Not -Match '(?i)^step\s+[0-9]+\b' -Because "seed $Seed"
                }
                $line.StartsWith('<') | Should -BeFalse -Because "seed $Seed"
                $line.TrimStart().StartsWith('<!-- docs:generated:') | Should -BeFalse -Because "seed $Seed"
                $line.EndsWith(' ') | Should -BeFalse -Because "seed $Seed"
                ($line.Contains("`n") -or $line.Contains("`r")) | Should -BeFalse -Because "seed $Seed"
            }
        }
    }
}
