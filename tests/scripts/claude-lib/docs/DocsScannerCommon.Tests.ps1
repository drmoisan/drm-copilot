#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsScannerCommon.psm1.

.DESCRIPTION
    Covers input selection, module paths, token-span helpers over in-memory token records,
    literal extraction, route template joining, diagnostic aggregation and conversion with the
    precision-limit routing, the precision-limit marker builder, the captured-input code mapping,
    element de-duplication, and the precision-limit table. Inputs are in memory; no file is
    written, no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsScannerCommon.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop

    function New-TestToken {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Kind, [string] $Text, [object] $Value = $null, [bool] $Dynamic = $false, [int] $Line = 1)
        [ordered]@{ Kind = $Kind; Text = $Text; Value = $Value; Dynamic = $Dynamic; Start = 0; Line = $Line; EndLine = $Line; Depth = 0 }
    }

    function New-TestTokenStream {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Spec)
        # Each entry is kind:text or kind:text:value; strings carry their decoded value.
        $tokens = [System.Collections.Generic.List[object]]::new()
        foreach ($entry in $Spec) {
            $parts = $entry.Split(':', 3)
            $value = if ($parts.Count -gt 2) { $parts[2] } elseif ($parts[0] -ceq 'string') { $parts[1] } else { $null }
            $tokens.Add((New-TestToken -Kind $parts[0] -Text $parts[1] -Value $value))
        }
        , $tokens.ToArray()
    }

    # Registered element kinds per analyzer (spec `### Registry rows`), used to check the table.
    $script:RegisteredKinds = @{
        'typescript-cli'     = @('cli-command', 'cli-option')
        'typescript-http'    = @('http-route')
        'typescript-exports' = @('public-symbol')
        'dotnet-http'        = @('http-route')
        'dotnet-config'      = @('config-key')
        'dotnet-public-api'  = @('public-symbol')
        'extension-import'   = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')
    }
}

AfterAll {
    Remove-Module -Name Docs.ScannerTestSupport, DocsScannerCommon, DocsAnalyzerRegistry, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'DocsScannerCommon' {
    Context 'Select-DocsScannerInput' {
        BeforeAll {
            $script:Inputs = @(
                (New-DocsTestCapturedInput -Path 'src/b.ts' -Text 'b'),
                (New-DocsTestCapturedInput -Path 'src/a.TS' -Text 'a'),
                (New-DocsTestCapturedInput -Path 'src/types.d.ts' -Text 'd'),
                (New-DocsTestCapturedInput -Path 'src/c.tsx' -Text 'c'),
                (New-DocsTestCapturedInput -Path 'app/appsettings.Development.json' -Text '{}'),
                (New-DocsTestCapturedInput -Path 'app/settings.json' -Text '{}')
            )
        }

        It 'selects by case-insensitive suffix, applies exclusions and sorts by path (ordinal)' {
            # Act
            $selected = Select-DocsScannerInput -CapturedInput $script:Inputs -Suffix @('.ts', '.mts') -ExcludeSuffix @('.d.ts')

            # Assert
            @($selected | ForEach-Object { $_['path'] }) | Should -Be @('src/a.TS', 'src/b.ts')
        }

        It 'selects by basename pattern' {
            # Act
            $selected = Select-DocsScannerInput -CapturedInput $script:Inputs -Suffix @('.json') -BasenamePattern '^appsettings(\.[^/]+)?\.json$'

            # Assert
            @($selected | ForEach-Object { $_['path'] }) | Should -Be @('app/appsettings.Development.json')
        }

        It 'returns an empty array for no inputs, a null path and no match' {
            # Act / Assert
            (Select-DocsScannerInput -CapturedInput @() -Suffix @('.ts')).Count | Should -Be 0
            (Select-DocsScannerInput -CapturedInput @(@{ path = $null; text = 'x' }) -Suffix @('.ts')).Count | Should -Be 0
            (Select-DocsScannerInput -CapturedInput $script:Inputs -Suffix @('.cs')).Count | Should -Be 0
        }
    }

    Context 'Get-DocsScannerModulePath' {
        It 'uses the longest matching root and removes the extension' {
            Get-DocsScannerModulePath -Path 'packages/app/src/utils/strings.ts' -SourceRoot @('packages', 'packages/app/src') | Should -BeExactly 'utils/strings'
        }

        It 'keeps the repository-relative path when no root matches or roots are absent' {
            Get-DocsScannerModulePath -Path 'src/index.ts' -SourceRoot @('lib') | Should -BeExactly 'src/index'
            Get-DocsScannerModulePath -Path 'src/index.ts' -SourceRoot $null | Should -BeExactly 'src/index'
            Get-DocsScannerModulePath -Path 'src/index.ts' -SourceRoot @() | Should -BeExactly 'src/index'
        }

        It 'treats a root of . as the repository root and keeps a dotted directory intact' {
            Get-DocsScannerModulePath -Path 'src/types.d.ts' -SourceRoot @('.') | Should -BeExactly 'src/types.d'
            Get-DocsScannerModulePath -Path 'v1.0/README' -SourceRoot @('') | Should -BeExactly 'v1.0/README'
        }
    }

    Context 'Get-DocsScannerMatchingClose and Get-DocsScannerCallArgument' {
        BeforeAll {
            # f ( 'a' , g ( 1 , 2 ) , [ 3 , 4 ] , )
            $script:Stream = New-TestTokenStream -Spec @('identifier:f', 'punct:(', 'string:a', 'punct:,', 'identifier:g', 'punct:(', 'number:1', 'punct:,', 'number:2', 'punct:)', 'punct:,', 'punct:[', 'number:3', 'punct:,', 'number:4', 'punct:]', 'punct:,', 'punct:)')
        }

        It 'finds the matching close across nested brackets' {
            Get-DocsScannerMatchingClose -Tokens $script:Stream -OpenIndex 1 | Should -Be 17
            Get-DocsScannerMatchingClose -Tokens $script:Stream -OpenIndex 5 | Should -Be 9
            Get-DocsScannerMatchingClose -Tokens $script:Stream -OpenIndex 11 | Should -Be 15
        }

        It 'returns -1 for a non-opener, an out-of-range index and an unbalanced stream' {
            Get-DocsScannerMatchingClose -Tokens $script:Stream -OpenIndex 0 | Should -Be -1
            Get-DocsScannerMatchingClose -Tokens $script:Stream -OpenIndex 99 | Should -Be -1
            Get-DocsScannerMatchingClose -Tokens (New-TestTokenStream -Spec @('punct:(', 'number:1')) -OpenIndex 0 | Should -Be -1
        }

        It 'splits top-level arguments at depth-zero commas and ignores a trailing comma' {
            # Act
            $spans = Get-DocsScannerCallArgument -Tokens $script:Stream -OpenIndex 1

            # Assert
            $spans.Count | Should -Be 3
            @($spans | ForEach-Object { "$($_['Start'])-$($_['End'])" }) | Should -Be @('2-2', '4-9', '11-15')
        }

        It 'returns no span for an empty argument list and for an unbalanced opener' {
            (Get-DocsScannerCallArgument -Tokens (New-TestTokenStream -Spec @('punct:(', 'punct:)')) -OpenIndex 0).Count | Should -Be 0
            (Get-DocsScannerCallArgument -Tokens (New-TestTokenStream -Spec @('punct:(', 'number:1')) -OpenIndex 0).Count | Should -Be 0
        }
    }

    Context 'Get-DocsScannerLiteral' {
        It 'returns the decoded value of a single string and of a literal-only concatenation' {
            # Arrange
            $single = New-TestTokenStream -Spec @('string:x:a/b')
            $joined = New-TestTokenStream -Spec @('string:x:/api', 'punct:+', 'string:y:/items', 'punct:+', 'template:z:/x')

            # Act / Assert
            Get-DocsScannerLiteral -Tokens $single -Span @{ Start = 0; End = 0 } | Should -BeExactly 'a/b'
            Get-DocsScannerLiteral -Tokens $joined -Span @{ Start = 0; End = 4 } | Should -BeExactly '/api/items/x'
        }

        It 'returns null for a dynamic template, an identifier, a non-plus operator and a dangling plus' {
            # Arrange
            $dynamic = @((New-TestToken -Kind 'template' -Text '`a${b}`' -Value $null -Dynamic $true))
            $identifier = New-TestTokenStream -Spec @('identifier:x')
            $minus = New-TestTokenStream -Spec @('string:a', 'punct:-', 'string:b')
            $dangling = New-TestTokenStream -Spec @('string:a', 'punct:+')

            # Act / Assert
            Get-DocsScannerLiteral -Tokens $dynamic -Span @{ Start = 0; End = 0 } | Should -BeNullOrEmpty
            Get-DocsScannerLiteral -Tokens $identifier -Span @{ Start = 0; End = 0 } | Should -BeNullOrEmpty
            Get-DocsScannerLiteral -Tokens $minus -Span @{ Start = 0; End = 2 } | Should -BeNullOrEmpty
            Get-DocsScannerLiteral -Tokens $dangling -Span @{ Start = 0; End = 1 } | Should -BeNullOrEmpty
            Get-DocsScannerLiteral -Tokens $identifier -Span @{ Start = 2; End = 1 } | Should -BeNullOrEmpty
        }
    }

    Context 'Join-DocsRouteTemplate' {
        It 'joins with a single slash, keeps case and begins with a slash' {
            Join-DocsRouteTemplate -Prefix '/api/' -Template '/Items/{id}' | Should -BeExactly '/api/Items/{id}'
            Join-DocsRouteTemplate -Prefix 'api' -Template 'items' | Should -BeExactly '/api/items'
            Join-DocsRouteTemplate -Prefix '' -Template 'items//sub' | Should -BeExactly '/items/sub'
        }

        It 'handles empty and null parts' {
            Join-DocsRouteTemplate -Prefix $null -Template '' | Should -BeExactly '/'
            Join-DocsRouteTemplate -Prefix '/api' -Template $null | Should -BeExactly '/api'
            Join-DocsRouteTemplate -Prefix '' -Template '/' | Should -BeExactly '/'
        }
    }

    Context 'New-DocsScannerDiagnosticSet, Add-DocsScannerDiagnostic and ConvertTo-DocsScannerDiagnostic' {
        It 'aggregates count and first line per (code, path) and sorts records by id' {
            # Arrange
            $set = New-DocsScannerDiagnosticSet
            Add-DocsScannerDiagnostic -Set $set -Code 'DUPLICATE_DECLARATION' -Path 'src/a.ts' -Line 7
            Add-DocsScannerDiagnostic -Set $set -Code 'DUPLICATE_DECLARATION' -Path 'src/a.ts' -Line 3
            Add-DocsScannerDiagnostic -Set $set -Code 'DUPLICATE_DECLARATION' -Path 'src/b.ts' -Line 2
            Add-DocsScannerDiagnostic -Set $set -Code 'INPUT_OVER_BOUND' -Path 'src/c.ts' -Line 0 -Blocking $true

            # Act
            $records = ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId 'typescript-exports'

            # Assert
            $records.Count | Should -Be 3
            $ids = @($records | ForEach-Object { $_['id'] })
            $sorted = [string[]] $ids.Clone()
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sorted
            $a = @($records | Where-Object { $_['path'] -ceq 'src/a.ts' })[0]
            $a['message'] | Should -Match '2 occurrence'
            $a['message'] | Should -Match 'line 3'
            $a['severity'] | Should -BeExactly 'warning'
            $a['blocking'] | Should -BeFalse
            $over = @($records | Where-Object { $_['code'] -ceq 'INPUT_OVER_BOUND' })[0]
            $over['severity'] | Should -BeExactly 'error'
            $over['blocking'] | Should -BeTrue
            $over['message'] | Should -Match 'line 0'
        }

        It 'marks a precision-limit row code under its own analyzer with the row element_kind' {
            # Arrange
            $set = New-DocsScannerDiagnosticSet
            Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path 'src/cli.ts' -Line 4

            # Act
            $record = (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId 'typescript-cli')[0]

            # Assert
            $record['analyzer_id'] | Should -BeExactly 'typescript-cli'
            $record['severity'] | Should -BeExactly 'warning'
            $record['extensions'].Contains('docs.precision-limit') | Should -BeTrue
            $record['extensions']['docs.precision-limit']['element_kind'] | Should -BeExactly 'cli-command'
            @($record['extensions']['docs.precision-limit'].Keys) | Should -Be @('element_kind')
        }

        It 'adds no marker for a non-row code and for a row code under an analyzer without that row' {
            # Arrange
            $set = New-DocsScannerDiagnosticSet
            Add-DocsScannerDiagnostic -Set $set -Code 'DUPLICATE_DECLARATION' -Path 'src/a.ts' -Line 1
            Add-DocsScannerDiagnostic -Set $set -Code 'INPUT_OVER_BOUND' -Path 'src/b.ts' -Line 0 -Blocking $true
            Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path 'src/c.ts' -Line 2

            # Act
            $records = ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId 'typescript-exports'

            # Assert
            $records.Count | Should -Be 3
            foreach ($record in $records) { $record['extensions'].Contains('docs.precision-limit') | Should -BeFalse }
        }

        It 'returns an empty array for an empty set' {
            (ConvertTo-DocsScannerDiagnostic -Set (New-DocsScannerDiagnosticSet) -AnalyzerId 'dotnet-http').Count | Should -Be 0
        }
    }

    Context 'New-DocsScannerPrecisionLimitDiagnostic' {
        It 'returns a warning record with the marker whose only key is element_kind' {
            # Act
            $record = New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path 'src/Controllers/ItemsController.cs' -Message '1 occurrence; first at line 3.' -ElementKind 'http-route'

            # Assert
            $record['severity'] | Should -BeExactly 'warning'
            $record['blocking'] | Should -BeFalse
            $record['path'] | Should -BeExactly 'src/Controllers/ItemsController.cs'
            $record['analyzer_id'] | Should -BeExactly 'dotnet-http'
            $record['code'] | Should -BeExactly 'HTTP_DYNAMIC_ROUTE'
            @($record['extensions']['docs.precision-limit'].Keys) | Should -Be @('element_kind')
            $record['extensions']['docs.precision-limit']['element_kind'] | Should -BeExactly 'http-route'
        }

        It 'keeps a pre-existing extensions key and creates the map when the record has none' {
            # Arrange: New-DocsDiagnostic is mocked in the module scope to return a record with a key, then one without an extensions member.
            Mock -ModuleName DocsScannerCommon New-DocsDiagnostic { [ordered]@{ id = 'diagnostic-x'; code = $Code; severity = 'warning'; path = $Path; message = $Message; analyzer_id = $AnalyzerId; blocking = $false; extensions = [ordered]@{ 'other.key' = 1 } } }

            # Act
            $withKey = New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path 'src/a.cs' -Message 'm' -ElementKind 'http-route'

            # Assert
            $withKey['extensions']['other.key'] | Should -Be 1
            $withKey['extensions']['docs.precision-limit']['element_kind'] | Should -BeExactly 'http-route'

            # Arrange / Act: a record whose extensions member is null.
            Mock -ModuleName DocsScannerCommon New-DocsDiagnostic { [ordered]@{ id = 'diagnostic-y'; code = $Code; severity = 'warning'; path = $Path; message = $Message; analyzer_id = $AnalyzerId; blocking = $false; extensions = $null } }
            $withNull = New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path 'src/a.cs' -Message 'm' -ElementKind 'http-route'

            # Assert
            @($withNull['extensions'].Keys) | Should -Be @('docs.precision-limit')
        }

        It 'throws for a null path, an empty path and an unknown element kind' {
            { New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path $null -Message 'm' -ElementKind 'http-route' } | Should -Throw -ExpectedMessage '*Path*'
            { New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path '' -Message 'm' -ElementKind 'http-route' } | Should -Throw -ExpectedMessage '*Path*'
            { New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId 'dotnet-http' -Code 'HTTP_DYNAMIC_ROUTE' -Path 'src/a.cs' -Message 'm' -ElementKind 'not-a-kind' } | Should -Throw -ExpectedMessage '*ElementKind*'
        }
    }

    Context 'Get-DocsScannerInputDiagnosticCode' {
        It 'maps the captured diagnostic to the analyzer code and returns null for decoded text' {
            Get-DocsScannerInputDiagnosticCode -CapturedInput (New-DocsTestOversizeInput -Path 'src/big.ts') | Should -BeExactly 'INPUT_OVER_BOUND'
            Get-DocsScannerInputDiagnosticCode -CapturedInput (New-DocsTestUndecodableInput -Path 'src/bad.ts') | Should -BeExactly 'INPUT_UNDECODABLE'
            Get-DocsScannerInputDiagnosticCode -CapturedInput (New-DocsTestCapturedInput -Path 'src/ok.ts' -Text '') | Should -BeNullOrEmpty
        }
    }

    Context 'ConvertTo-DocsScannerElementList' {
        BeforeAll {
            $script:Text = "a`nb`nc`nd`n"
            function New-TestElement {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
                param([string] $Declaration, [int] $Line, [string] $Path = 'src/a.ts')
                New-DocsSurfaceElement -Kind 'public-symbol' -Path $Path -Declaration $Declaration -Name 'n' -AnalyzerId 'typescript-exports' -AnalysisMethod 'scanner' -SourceText $script:Text -LineRange @($Line, $Line)
            }
        }

        It 'keeps the first site by line, records DUPLICATE_DECLARATION for the others and sorts by element_id' {
            # Arrange
            $set = New-DocsScannerDiagnosticSet
            $elements = @((New-TestElement -Declaration 'm.z' -Line 3), (New-TestElement -Declaration 'm.a' -Line 4), (New-TestElement -Declaration 'm.z' -Line 1))

            # Act
            $kept = ConvertTo-DocsScannerElementList -Element $elements -Set $set

            # Assert
            $kept.Count | Should -Be 2
            $ids = @($kept | ForEach-Object { $_['element_id'] })
            $sorted = [string[]] $ids.Clone()
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sorted
            @($kept | Where-Object { $_['declaration'] -ceq 'm.z' })[0]['line_range']['start'] | Should -Be 1
            $records = ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId 'typescript-exports'
            $records.Count | Should -Be 1
            $records[0]['code'] | Should -BeExactly 'DUPLICATE_DECLARATION'
            $records[0]['message'] | Should -Match 'line 3'
        }

        It 'returns an empty array for no elements' {
            (ConvertTo-DocsScannerElementList -Element @() -Set (New-DocsScannerDiagnosticSet)).Count | Should -Be 0
            (ConvertTo-DocsScannerElementList -Element $null -Set (New-DocsScannerDiagnosticSet)).Count | Should -Be 0
        }
    }

    Context 'Get-DocsScannerPrecisionLimit' {
        BeforeAll { $script:Rows = Get-DocsScannerPrecisionLimit }

        It 'returns rows with exactly the five keys, ordered by analyzer_id then code' {
            # Assert
            $script:Rows.Count | Should -BeGreaterThan 0
            foreach ($row in $script:Rows) { @($row.Keys) | Should -Be @('analyzer_id', 'code', 'element_kind', 'construct', 'consequence') }
            $keys = @($script:Rows | ForEach-Object { "$($_['analyzer_id'])`n$($_['code'])" })
            $sorted = [string[]] $keys.Clone()
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $keys | Should -Be $sorted
            @($keys | Select-Object -Unique).Count | Should -Be $keys.Count
        }

        It 'uses registered analyzer identifiers, element kinds within each registration, codes in the docs grammar and no extension-import row' {
            foreach ($row in $script:Rows) {
                $script:RegisteredKinds.ContainsKey($row['analyzer_id']) | Should -BeTrue
                $script:RegisteredKinds[$row['analyzer_id']] | Should -Contain $row['element_kind']
                $row['code'] | Should -Match '^[A-Z][A-Z0-9_]*$'
                $row['analyzer_id'] | Should -Not -BeExactly 'extension-import'
                $row['code'] | Should -Not -BeExactly 'EXTENSION_FINDING_SKIPPED'
            }
            @($script:Rows | Where-Object { $_['analyzer_id'] -ceq 'typescript-cli' } | ForEach-Object { $_['element_kind'] } | Select-Object -Unique) | Should -Be @('cli-command')
        }
    }
}
