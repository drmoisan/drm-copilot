#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSurface.psm1.

.DESCRIPTION
    Covers element identifier determinism over a seeded input set, boundary distinctness, the
    golden vectors V1..V4 and D1 recorded in the feature evidence, identity input validation,
    element records (analysis method, line range, cli-option parent, tamper detection), the
    declaration-lines digest (locality, a seeded property, bounds, empty text and the
    architecture-component exception) and diagnostics with the severity and blocking coupling.
    Inputs are in-memory strings; the only file read is the committed docs common schema, read once
    to obtain the diagnostic key set.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop

    $commonPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../schemas/docs/v1/common.schema.json'
    $common = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath $commonPath -Raw)).Value
    $script:DiagnosticKeys = [string[]]@($common['$defs']['diagnostic']['required'])
    $script:DiagnosticSeverities = [string[]]@($common['$defs']['diagnostic']['properties']['severity']['enum'])

    # Golden vectors computed independently with sha256sum ([P1-T1], evidence/other/golden-identity-vectors).
    $script:Golden = @(
        @{ Name = 'V1'; Kind = 'cli-command'; Path = 'src/example_pkg/cli.py'; Declaration = 'tool docs inventory'; Canonical = '{"declaration":"tool docs inventory","kind":"cli-command","path":"src/example_pkg/cli.py"}'; Digest = 'b9cda1283b765831a04bf07223320d70c1f07de9da312b21731f40e8790cf00a' }
        @{ Name = 'V2'; Kind = 'cli-option'; Path = 'src/example_pkg/cli.py'; Declaration = 'tool docs inventory --analyzer'; Canonical = '{"declaration":"tool docs inventory --analyzer","kind":"cli-option","path":"src/example_pkg/cli.py"}'; Digest = '4dac82ff130bd249bc5405947e1c0d29de1b7374d2aba5fb490213d36cd1ba85' }
        @{ Name = 'V3'; Kind = 'http-route'; Path = 'src/example_pkg/routes.py'; Declaration = 'GET /items/{id}'; Canonical = '{"declaration":"GET /items/{id}","kind":"http-route","path":"src/example_pkg/routes.py"}'; Digest = '953dac18dfc986f87330003d45e387536b6fa02b8b34b64b49245a2482d5136f' }
        @{ Name = 'V4'; Kind = 'config-key'; Path = 'config/settings.json'; Declaration = 'tool.settings.timeout'; Canonical = '{"declaration":"tool.settings.timeout","kind":"config-key","path":"config/settings.json"}'; Digest = 'c861a7d842f18ab03e7ad64dbca3ac7283e51566286b3810ae6163f096fcc69b' }
    )
    $script:CommandId = 'cli-command-b9cda1283b765831a04bf07223320d70c1f07de9da312b21731f40e8790cf00a'
    $script:IdentifierSeed = 1020
    $script:DigestSeed = 20261030

    # Six lines with LF endings and a final newline; the declaration occupies lines 3 and 4.
    $script:SixLines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 2')

    function Join-TestLine {
        param([string[]] $Line, [string] $Ending = "`n", [switch] $NoFinalNewline)
        $text = $Line -join $Ending
        if (-not $NoFinalNewline) { $text += $Ending }
        return $text
    }

    function New-TestElement {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Kind = 'cli-command', [string] $AnalysisMethod = 'scanner', [string] $ParentId, [object] $LineRange = @(1, 1))
        $splat = @{ Kind = $Kind; Path = 'src/example_pkg/cli.py'; Declaration = 'tool docs inventory'; Name = 'inventory'; AnalyzerId = 'example-cli'; AnalysisMethod = $AnalysisMethod; SourceText = "line one`nline two`n" }
        if ($PSBoundParameters.ContainsKey('ParentId')) { $splat['ParentId'] = $ParentId }
        if ($null -ne $LineRange) { $splat['LineRange'] = [int[]]$LineRange }
        New-DocsSurfaceElement @splat
    }
}

AfterAll {
    Remove-Module -Name DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Element kinds and analysis methods' {
    It 'returns the six element kinds in contract order' {
        Get-DocsElementKind | Should -Be @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')
    }

    It 'tests element kinds case-sensitively' {
        Test-DocsElementKind -Kind 'http-route' | Should -BeTrue
        Test-DocsElementKind -Kind 'HTTP-route' | Should -BeFalse
        Test-DocsElementKind -Kind '' | Should -BeFalse
    }

    It 'returns the analysis methods native then scanner' {
        Get-DocsAnalysisMethod | Should -Be @('native', 'scanner')
    }
}

Describe 'Path, revision and element identifier grammar' {
    It 'accepts relative POSIX paths and rejects other spellings: <Path>' -TestCases @(
        @{ Path = 'src/a.py'; Expected = $true }
        @{ Path = 'a'; Expected = $true }
        @{ Path = '/abs/a.py'; Expected = $false }
        @{ Path = '../a.py'; Expected = $false }
        @{ Path = 'a/./b'; Expected = $false }
        @{ Path = 'a\b'; Expected = $false }
        @{ Path = 'c:/a'; Expected = $false }
        @{ Path = 'a/*.py'; Expected = $false }
        @{ Path = ''; Expected = $false }
    ) {
        param($Path, $Expected)
        Test-DocsRelativePath -Path $Path | Should -Be $Expected
    }

    It 'accepts a full revision of 40 or 64 lowercase hex characters only' {
        Test-DocsFullRevision -Revision ('a' * 40) | Should -BeTrue
        Test-DocsFullRevision -Revision ('0' * 64) | Should -BeTrue
        Test-DocsFullRevision -Revision ('A' * 40) | Should -BeFalse
        Test-DocsFullRevision -Revision ('a' * 41) | Should -BeFalse
    }

    It 'validates element identifiers against the element-id pattern' {
        Test-DocsElementId -ElementId $script:CommandId | Should -BeTrue
        Test-DocsElementId -ElementId ('widget-' + ('a' * 64)) | Should -BeFalse
        Test-DocsElementId -ElementId ($script:CommandId + "`n") | Should -BeFalse
    }
}

Describe 'Get-DocsElementId' {
    It 'matches golden vector <Name>: canonical string and hex digest' -TestCases @(
        @{ Index = 0; Name = 'V1' }
        @{ Index = 1; Name = 'V2' }
        @{ Index = 2; Name = 'V3' }
        @{ Index = 3; Name = 'V4' }
    ) {
        param($Index, $Name)

        # Arrange
        $vector = $script:Golden[$Index]

        # Act
        $canonical = ConvertTo-DocsCanonicalJson -Value ([ordered]@{ kind = $vector.Kind; path = $vector.Path; declaration = $vector.Declaration })
        $elementId = Get-DocsElementId -Kind $vector.Kind -Path $vector.Path -Declaration $vector.Declaration

        # Assert
        $canonical | Should -BeExactly ($vector.Canonical + "`n") -Because "golden vector $Name"
        $elementId | Should -BeExactly ($vector.Kind + '-' + $vector.Digest) -Because "golden vector $Name"
    }

    It 'is deterministic and collision-free over a seeded input set' {
        # Arrange
        $random = [System.Random]::new($script:IdentifierSeed)
        $kinds = Get-DocsElementKind
        $alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_'
        $declarationAlphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJ0123456789-./{}:' + [char]0x00E9
        $tuples = @{}
        for ($n = 0; $n -lt 200; $n++) {
            $segments = @(1..($random.Next(1, 4)) | ForEach-Object { -join @(1..($random.Next(1, 7)) | ForEach-Object { $alphabet[$random.Next($alphabet.Length)] }) })
            $path = ($segments -join '/') + '.py'
            $words = @(1..($random.Next(1, 4)) | ForEach-Object { -join @(1..($random.Next(1, 9)) | ForEach-Object { $declarationAlphabet[$random.Next($declarationAlphabet.Length)] }) })
            $kind = $kinds[$random.Next($kinds.Count)]
            $tuples["$kind|$path|$($words -join ' ')"] = @($kind, $path, ($words -join ' '))
        }

        # Act
        $identifiers = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($tuple in $tuples.Values) {
            $first = Get-DocsElementId -Kind $tuple[0] -Path $tuple[1] -Declaration $tuple[2]
            $second = Get-DocsElementId -Kind $tuple[0] -Path $tuple[1] -Declaration $tuple[2]

            # Assert: repeated computation agrees and the identifier is well formed.
            $second | Should -BeExactly $first -Because "seed $($script:IdentifierSeed), input $($tuple -join ' | ')"
            Test-DocsElementId -ElementId $first | Should -BeTrue -Because "seed $($script:IdentifierSeed), input $($tuple -join ' | ')"
            [void]$identifiers.Add($first)
        }

        # Assert: distinct inputs give distinct identifiers.
        $identifiers.Count | Should -Be $tuples.Count -Because "seed $($script:IdentifierSeed)"
    }

    It 'gives distinct identifiers for enumerated boundary cases' {
        # Arrange
        $pairs = @(
            @(@('cli-command', 'a/b', 'c'), @('cli-command', 'a', 'b/c')),
            @(@('cli-command', 'src/a.py', 'tool x'), @('cli-option', 'src/a.py', 'tool x')),
            @(@('config-key', 'src/a.py', 'Key'), @('config-key', 'src/a.py', 'key')),
            @(@('http-route', 'src/a.py', 'GET /a'), @('http-route', 'src/a.py', 'GET  /a')),
            @(@('public-symbol', 'src/a.py', 'a.b'), @('public-symbol', 'src/a.pyb', '.b'))
        )

        # Act / Assert
        foreach ($pair in $pairs) {
            $left = Get-DocsElementId -Kind $pair[0][0] -Path $pair[0][1] -Declaration $pair[0][2]
            $right = Get-DocsElementId -Kind $pair[1][0] -Path $pair[1][1] -Declaration $pair[1][2]
            $left | Should -Not -Be $right -Because "$($pair[0] -join ' | ') versus $($pair[1] -join ' | ')"
        }
    }

    It 'rejects an invalid identity input naming the argument: <Name>' -TestCases @(
        @{ Name = 'unpaired surrogate'; Kind = 'cli-command'; Path = 'src/a.py'; Declaration = ('tool ' + [char]0xD800); Argument = 'Declaration' }
        @{ Name = 'absolute path'; Kind = 'cli-command'; Path = '/src/a.py'; Declaration = 'tool'; Argument = 'Path' }
        @{ Name = 'parent path'; Kind = 'cli-command'; Path = '../a.py'; Declaration = 'tool'; Argument = 'Path' }
        @{ Name = 'unknown kind'; Kind = 'widget'; Path = 'src/a.py'; Declaration = 'tool'; Argument = 'Kind' }
        @{ Name = 'blank declaration'; Kind = 'cli-command'; Path = 'src/a.py'; Declaration = '  '; Argument = 'Declaration' }
        @{ Name = 'leading whitespace'; Kind = 'cli-command'; Path = 'src/a.py'; Declaration = ' tool'; Argument = 'Declaration' }
        @{ Name = 'control character'; Kind = 'cli-command'; Path = 'src/a.py'; Declaration = "tool`tx"; Argument = 'Declaration' }
    ) {
        # Pester supplies $Kind, $Path, $Declaration and $Argument from the test case.
        { Get-DocsElementId -Kind $Kind -Path $Path -Declaration $Declaration } | Should -Throw -ExpectedMessage "DOCS_IDENTITY_INPUT_INVALID: $Argument*"
    }
}

Describe 'Get-DocsStableId' {
    It 'prefixes the digest of the canonical JSON of the value' {
        Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ a = 1 }) | Should -BeExactly ('pin-' + (Get-DocsSha256Hex -Text ('{"a":1}' + "`n")))
    }

    It 'rethrows a canonical JSON rejection as DOCS_IDENTITY_INPUT_INVALID' {
        { Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ a = 1.5 }) } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: *'
    }

    It 'rejects a prefix outside the lower-case hyphenated grammar' {
        { Get-DocsStableId -Prefix 'Pin' -Value 1 } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Prefix*'
    }
}

Describe 'New-DocsSurfaceElement and ConvertFrom-DocsSurfaceElement' {
    It 'returns the snapshot element key set with computed identifier and digest' {
        # Act
        $element = New-DocsSurfaceElement -Kind 'cli-command' -Path 'src/example_pkg/cli.py' -Declaration 'tool docs inventory' -Name 'inventory' -AnalyzerId 'example-cli' -AnalysisMethod 'native' -SourceText "a`nb`nc`n" -LineRange @(2, 2) -Property @{ hidden = $false } -Extension @{ 'vendor.note' = 'x' }

        # Assert
        @($element.Keys) | Should -Be @('element_id', 'kind', 'path', 'declaration', 'name', 'parent_id', 'analyzer_id', 'analysis_method', 'source_sha256', 'line_range', 'properties', 'extensions')
        $element.element_id | Should -BeExactly $script:CommandId
        $element.source_sha256 | Should -BeExactly (Get-DocsSha256Hex -Text "b`n")
        $element.line_range.start | Should -Be 2
        $element.line_range.end | Should -Be 2
        $element.properties[0].name | Should -BeExactly 'hidden'
        $element.extensions['vendor.note'] | Should -BeExactly 'x'
    }

    It 'rejects an AnalysisMethod outside Get-DocsAnalysisMethod' {
        { New-TestElement -AnalysisMethod 'ast' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: AnalysisMethod*'
    }

    It 'gives equal element_id to elements that differ only in AnalysisMethod, and accepts both' {
        # Act
        $native = New-TestElement -AnalysisMethod 'native'
        $scanner = New-TestElement -AnalysisMethod 'scanner'

        # Assert
        $native.element_id | Should -BeExactly $scanner.element_id
        (ConvertFrom-DocsSurfaceElement -Record $native).analysis_method | Should -BeExactly 'native'
        (ConvertFrom-DocsSurfaceElement -Record $scanner).analysis_method | Should -BeExactly 'scanner'
    }

    It 'rejects a cli-command without a LineRange' {
        { New-TestElement -Kind 'cli-command' -LineRange $null } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: LineRange*'
    }

    It 'accepts an architecture-component without a LineRange and digests every normalized line' {
        # Act
        $element = New-DocsSurfaceElement -Kind 'architecture-component' -Path 'src/example_pkg/analyzers' -Declaration 'example_pkg.analyzers' -Name 'analyzers' -AnalyzerId 'example-arch' -AnalysisMethod 'scanner' -SourceText "one`r`ntwo"

        # Assert
        $null -eq $element.line_range | Should -BeTrue
        $element.source_sha256 | Should -BeExactly (Get-DocsSha256Hex -Text "one`ntwo`n")
    }

    It 'requires a cli-command parent for a cli-option' {
        # Act / Assert
        { New-TestElement -Kind 'cli-option' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: ParentId*'
        { New-TestElement -Kind 'cli-option' -ParentId ('http-route-' + ('a' * 64)) } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: ParentId*'
        (New-TestElement -Kind 'cli-option' -ParentId $script:CommandId).parent_id | Should -BeExactly $script:CommandId
    }

    It 'rejects a malformed ParentId, a blank Name, a bad AnalyzerId, a bad property and a bad extension key' {
        { New-TestElement -ParentId 'cli-command-xyz' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: ParentId*'
        { New-DocsSurfaceElement -Kind 'cli-command' -Path 'a.py' -Declaration 'x' -Name ' ' -AnalyzerId 'a' -AnalysisMethod 'scanner' -SourceText 'x' -LineRange @(1, 1) } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Name*'
        { New-DocsSurfaceElement -Kind 'cli-command' -Path 'a.py' -Declaration 'x' -Name 'x' -AnalyzerId 'Bad' -AnalysisMethod 'scanner' -SourceText 'x' -LineRange @(1, 1) } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: AnalyzerId*'
        { New-DocsSurfaceElement -Kind 'cli-command' -Path 'a.py' -Declaration 'x' -Name 'x' -AnalyzerId 'a' -AnalysisMethod 'scanner' -SourceText 'x' -LineRange @(1, 1) -Property @{ Bad = 1 } } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Property*'
        { New-DocsSurfaceElement -Kind 'cli-command' -Path 'a.py' -Declaration 'x' -Name 'x' -AnalyzerId 'a' -AnalysisMethod 'scanner' -SourceText 'x' -LineRange @(1, 1) -Property @{ list = @(1) } } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Property*'
        { New-DocsSurfaceElement -Kind 'cli-command' -Path 'a.py' -Declaration 'x' -Name 'x' -AnalyzerId 'a' -AnalysisMethod 'scanner' -SourceText 'x' -LineRange @(1, 1) -Extension @{ note = 1 } } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Extension*'
    }

    It 'throws DOCS_DIGEST_RANGE_INVALID for a LineRange outside the source text' {
        { New-TestElement -LineRange @(3, 3) } | Should -Throw -ExpectedMessage 'DOCS_DIGEST_RANGE_INVALID*'
    }

    It 'throws DOCS_ELEMENT_ID_MISMATCH for a record whose element_id was altered' {
        # Arrange
        $record = New-TestElement
        $record['element_id'] = 'cli-command-' + ('0' * 64)

        # Act / Assert
        { ConvertFrom-DocsSurfaceElement -Record $record } | Should -Throw -ExpectedMessage 'DOCS_ELEMENT_ID_MISMATCH*'
    }

    It 'requires analysis_method in the record and a known value' {
        # Arrange
        $missing = New-TestElement
        $missing.Remove('analysis_method')
        $unknown = New-TestElement
        $unknown['analysis_method'] = 'ast'

        # Act / Assert
        { ConvertFrom-DocsSurfaceElement -Record $missing } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: field analysis_method*'
        { ConvertFrom-DocsSurfaceElement -Record $unknown } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: analysis_method*'
    }

    It 'rebuilds a partial record with the full element key set' {
        # Arrange
        $record = @{ element_id = $script:CommandId; kind = 'cli-command'; path = 'src/example_pkg/cli.py'; declaration = 'tool docs inventory'; analysis_method = 'native' }

        # Act
        $rebuilt = ConvertFrom-DocsSurfaceElement -Record $record

        # Assert
        $rebuilt.Count | Should -Be 12
        $rebuilt.properties.Count | Should -Be 0
        $null -eq $rebuilt.line_range | Should -BeTrue
    }
}

Describe 'Declaration-lines digest' {
    It 'matches golden vector D1: canonical text and hex digest' {
        # Arrange
        $source = "a = 1`r`ndef handler():`r`n    return 1`r`nb = 2"

        # Act / Assert
        ConvertTo-DocsDeclarationText -Text $source -LineRange @(2, 3) | Should -BeExactly "def handler():`n    return 1`n"
        Get-DocsDeclarationSha256 -Text $source -LineRange @(2, 3) | Should -BeExactly '4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea'
    }

    It 'leaves the digest unchanged for an edit outside the range: <Case>' -TestCases @(
        @{ Case = 'line 1 changed'; Lines = @('import y', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(3, 4); Ending = "`n"; NoFinal = $false; Bom = $false }
        @{ Case = 'line 6 changed'; Lines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 3'); Range = @(3, 4); Ending = "`n"; NoFinal = $false; Bom = $false }
        @{ Case = 'two lines inserted above, range shifted'; Lines = @('# a', '# b', 'import x', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(5, 6); Ending = "`n"; NoFinal = $false; Bom = $false }
        @{ Case = 'CRLF line endings'; Lines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(3, 4); Ending = "`r`n"; NoFinal = $false; Bom = $false }
        @{ Case = 'final newline removed'; Lines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(3, 4); Ending = "`n"; NoFinal = $true; Bom = $false }
        @{ Case = 'byte order mark added'; Lines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(3, 4); Ending = "`n"; NoFinal = $false; Bom = $true }
    ) {
        param($Case, $Lines, $Range, $Ending, $NoFinal, $Bom)

        # Arrange
        $baseline = Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $script:SixLines) -LineRange @(3, 4)
        $text = Join-TestLine -Line $Lines -Ending $Ending -NoFinalNewline:$NoFinal
        if ($Bom) { $text = [string][char]0xFEFF + $text }

        # Act / Assert
        Get-DocsDeclarationSha256 -Text $text -LineRange ([int[]]$Range) | Should -BeExactly $baseline -Because $Case
    }

    It 'changes the digest for an edit inside the range or a wider range: <Case>' -TestCases @(
        @{ Case = 'one character in line 3'; Lines = @('import x', '', 'def handler(:', '    return 1', '', 'tail = 2'); Range = @(3, 4) }
        @{ Case = 'one character in line 4'; Lines = @('import x', '', 'def handler():', '    return 2', '', 'tail = 2'); Range = @(3, 4) }
        @{ Case = 'range extended to line 5'; Lines = @('import x', '', 'def handler():', '    return 1', '', 'tail = 2'); Range = @(3, 5) }
    ) {
        param($Case, $Lines, $Range)

        # Arrange
        $baseline = Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $script:SixLines) -LineRange @(3, 4)

        # Act / Assert
        Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $Lines) -LineRange ([int[]]$Range) | Should -Not -Be $baseline -Because $Case
    }

    It 'never changes for an outside mutation and always changes for an inside append (seeded property)' {
        # Arrange
        $random = [System.Random]::new($script:DigestSeed)
        $alphabet = 'abcdefghijklmnopqrstuvwxyz (){}=:.0123456789'

        for ($iteration = 0; $iteration -lt 150; $iteration++) {
            $count = $random.Next(3, 13)
            $lines = [string[]]@(1..$count | ForEach-Object { -join @(1..($random.Next(0, 12)) | ForEach-Object { $alphabet[$random.Next($alphabet.Length)] }) })
            $start = $random.Next(1, $count + 1)
            $end = $random.Next($start, $count + 1)
            $range = [int[]]@($start, $end)
            $baseline = Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $lines) -LineRange $range
            $context = "seed $($script:DigestSeed), iteration $iteration, lines $count, range $start..$end"

            # Act / Assert: mutate a random line outside the range.
            $outside = @(1..$count | Where-Object { $_ -lt $start -or $_ -gt $end })
            if ($outside.Count -gt 0) {
                $target = $outside[$random.Next($outside.Count)]
                $mutated = [string[]]$lines.Clone()
                $mutated[$target - 1] = $mutated[$target - 1] + 'x'
                Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $mutated) -LineRange $range | Should -BeExactly $baseline -Because $context
            }

            # Act / Assert: append one character to a random line inside the range.
            $inside = $random.Next($start, $end + 1)
            $appended = [string[]]$lines.Clone()
            $appended[$inside - 1] = $appended[$inside - 1] + 'q'
            Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $appended) -LineRange $range | Should -Not -Be $baseline -Because $context
        }
    }

    It 'throws DOCS_DIGEST_RANGE_INVALID for a range outside the text: <Case>' -TestCases @(
        @{ Case = 'start 0'; Range = @(0, 1) }
        @{ Case = 'start after end'; Range = @(3, 2) }
        @{ Case = 'end beyond the line count'; Range = @(5, 7) }
        @{ Case = 'one value only'; Range = @(2) }
    ) {
        # Pester supplies $Range from the test case.
        { Get-DocsDeclarationSha256 -Text (Join-TestLine -Line $script:SixLines) -LineRange ([int[]]$Range) } | Should -Throw -ExpectedMessage 'DOCS_DIGEST_RANGE_INVALID*'
    }

    It 'returns the digest of the empty string for empty text without a range' {
        ConvertTo-DocsDeclarationText -Text '' | Should -BeExactly ''
        Get-DocsDeclarationSha256 -Text '' | Should -BeExactly (Get-DocsSha256Hex -Text '')
        { Get-DocsDeclarationSha256 -Text '' -LineRange @(1, 1) } | Should -Throw -ExpectedMessage 'DOCS_DIGEST_RANGE_INVALID*'
    }

    It 'selects every normalized line without a range' {
        ConvertTo-DocsDeclarationText -Text "a`r`nb`rc" | Should -BeExactly "a`nb`nc`n"
    }
}

Describe 'New-DocsDiagnostic' {
    It 'couples severity <Severity> with blocking <ExpectedBlocking>' -TestCases @(
        @{ Severity = 'error'; ExpectedBlocking = $true }
        @{ Severity = 'warning'; ExpectedBlocking = $false }
        @{ Severity = 'information'; ExpectedBlocking = $false }
    ) {
        param($Severity, $ExpectedBlocking)

        # Act
        $diagnostic = New-DocsDiagnostic -Code 'DOCS_TEST' -Path 'src/a.py' -Message 'Text.' -AnalyzerId 'example-scanner' -Severity $Severity

        # Assert
        $diagnostic.severity | Should -BeExactly $Severity
        $diagnostic.blocking | Should -Be $ExpectedBlocking
        @($diagnostic.Keys | Sort-Object) | Should -Be @($script:DiagnosticKeys | Sort-Object)
        $script:DiagnosticSeverities | Should -Contain $diagnostic.severity
    }

    It 'selects error or warning from Blocking when Severity is omitted' {
        # Act
        $blocking = New-DocsDiagnostic -Code 'DOCS_TEST' -Path $null -Message 'Text.' -AnalyzerId 'example-scanner' -Blocking $true
        $nonBlocking = New-DocsDiagnostic -Code 'DOCS_TEST' -Path $null -Message 'Text.' -AnalyzerId 'example-scanner' -Blocking $false
        $default = New-DocsDiagnostic -Code 'DOCS_TEST' -Path $null -Message 'Text.' -AnalyzerId 'example-scanner'

        # Assert
        $blocking.severity | Should -BeExactly 'error'
        $nonBlocking.severity | Should -BeExactly 'warning'
        $nonBlocking.blocking | Should -BeFalse
        $default.severity | Should -BeExactly 'error'
        @($default.Keys | Sort-Object) | Should -Be @($script:DiagnosticKeys | Sort-Object)
        $null -eq $default.path | Should -BeTrue
    }

    It 'rejects Severity information with Blocking true, naming Blocking' {
        { New-DocsDiagnostic -Code 'DOCS_TEST' -Path 'src/a.py' -Message 'Text.' -AnalyzerId 'example-scanner' -Severity 'information' -Blocking $true } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Blocking*'
    }

    It 'rejects the unknown severity info, naming Severity' {
        { New-DocsDiagnostic -Code 'DOCS_TEST' -Path 'src/a.py' -Message 'Text.' -AnalyzerId 'example-scanner' -Severity 'info' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Severity*'
    }

    It 'derives the identifier from analyzer, code and path' {
        # Act
        $diagnostic = New-DocsDiagnostic -Code 'DOCS_EXAMPLE_NOTICE' -Path 'config/settings.json' -Message 'Text.' -AnalyzerId 'example-scanner' -Severity 'information'

        # Assert: the value recorded in the snapshot example, computed independently with sha256sum.
        $diagnostic.id | Should -BeExactly 'diagnostic-a2e8cd3ba6dc343e900b6bfac71ac0b54a396bd7ddf36ba387f119093f48e1cc'
        $diagnostic.id | Should -BeExactly (Get-DocsStableId -Prefix 'diagnostic' -Value ([ordered]@{ analyzer = 'example-scanner'; code = 'DOCS_EXAMPLE_NOTICE'; path = 'config/settings.json' }))
    }

    It 'rejects an invalid code, path, message or analyzer identifier' {
        { New-DocsDiagnostic -Code 'bad' -Path $null -Message 'Text.' -AnalyzerId 'a' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Code*'
        { New-DocsDiagnostic -Code 'DOCS_X' -Path '/abs' -Message 'Text.' -AnalyzerId 'a' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Path*'
        { New-DocsDiagnostic -Code 'DOCS_X' -Path $null -Message ' ' -AnalyzerId 'a' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: Message*'
        { New-DocsDiagnostic -Code 'DOCS_X' -Path $null -Message 'Text.' -AnalyzerId 'A' } | Should -Throw -ExpectedMessage 'DOCS_IDENTITY_INPUT_INVALID: AnalyzerId*'
    }
}
