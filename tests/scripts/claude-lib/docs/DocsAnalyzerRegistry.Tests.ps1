#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerRegistry.psm1.

.DESCRIPTION
    Covers the two committed provider tables by membership only (anchors, declaration order and
    existence; no row-count assertion), registration order with in-memory rows, registration
    validation across both tables, selection with the native rule, captured-input bounds, and
    analyzer invocation with the fixture analyzer loaded through the -ImportModule seam. Inputs
    are in memory; no file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:DocsRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $script:LibraryRoot -ChildPath 'docs'))
    $script:ModulePath = Join-Path -Path $script:DocsRoot -ChildPath 'DocsAnalyzerRegistry.psm1'
    $script:FixturePath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath 'fixtures/DocsAnalyzerFixture.psm1'))
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:DocsRoot -ChildPath 'DocsSurface.psm1') -Force -ErrorAction Stop
    $script:ModuleText = Get-Content -LiteralPath $script:ModulePath -Raw

    function New-TestRow {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param(
            [string] $Id = 'example-scanner',
            [string] $AnalysisMethod = 'scanner',
            [string[]] $ElementKinds = @('cli-command'),
            [string] $Module = (Join-Path -Path $script:DocsRoot -ChildPath 'DocsAnalyzerExample.psm1'),
            [string] $Function = 'Invoke-DocsAnalyzerExample',
            [string] $Version = '1.0.0'
        )
        [pscustomobject]@{ Id = $Id; Version = $Version; AnalysisMethod = $AnalysisMethod; ElementKinds = $ElementKinds; Module = $Module; Function = $Function }
    }

    $script:SourceText = "line one`ntool docs inventory`nline three`n"
    $script:Captured = @(New-DocsCapturedInput -Path 'src/example_pkg/cli.py' -Bytes ([System.Text.Encoding]::UTF8.GetBytes($script:SourceText)))
    $script:FixtureRow = New-TestRow -Id 'fixture' -AnalysisMethod 'scanner' -ElementKinds @('cli-command') -Module $script:FixturePath -Function 'Invoke-DocsAnalyzerFixture'

    function New-TestSelection {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Kind = 'cli-command', [string] $AnalysisMethod = 'scanner', [string] $AnalyzerId = 'fixture')
        @{ Kind = $Kind; AnalysisMethod = $AnalysisMethod; AnalyzerId = $AnalyzerId; Declaration = 'tool docs inventory'; Name = 'inventory'; LineRange = @(2, 2) }
    }

    function New-RecordingImport {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Returns an in-memory recording seam in a test file; it changes no system state.')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Log and Path are captured by the returned closure.')]
        param([System.Collections.Generic.List[string]] $Log, [string] $Path)
        # -Global makes the fixture function resolvable from the registry module and the test scope.
        { param($ModulePath) $Log.Add([string] $ModulePath); Import-Module -Name $Path -Global -ErrorAction Stop }.GetNewClosure()
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerRegistry, DocsAnalyzerFixture, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Committed provider tables (membership only)' {
    It 'declares the scanner table with the 1022 then 1033 anchors and the native table after it with the 1031 anchor' {
        # Arrange
        $text = $script:ModuleText
        $scannerAt = $text.IndexOf('$script:DocsAnalyzerRow = @(', [System.StringComparison]::Ordinal)
        $anchor1022 = $text.IndexOf('# --- 1022: Python and configuration analyzers ---', [System.StringComparison]::Ordinal)
        $anchor1033 = $text.IndexOf('# --- 1033: TypeScript and .NET analyzers ---', [System.StringComparison]::Ordinal)
        $nativeAt = $text.IndexOf('$script:DocsAnalyzerNativeRow = @(', [System.StringComparison]::Ordinal)
        $anchor1031 = $text.IndexOf('# --- 1031: Python-native analyzers ---', [System.StringComparison]::Ordinal)

        # Assert
        $scannerAt | Should -BeGreaterThan 0
        $anchor1022 | Should -BeGreaterThan $scannerAt
        $anchor1033 | Should -BeGreaterThan $anchor1022
        $nativeAt | Should -BeGreaterThan $anchor1033
        $anchor1031 | Should -BeGreaterThan $nativeAt
    }

    It 'holds both tables in module scope (read only)' {
        InModuleScope DocsAnalyzerRegistry {
            Test-Path -Path 'variable:script:DocsAnalyzerRow' | Should -BeTrue
            Test-Path -Path 'variable:script:DocsAnalyzerNativeRow' | Should -BeTrue
        }
    }

    It 'carries no placeholder-numbered anchor, and the guard regex matches a positive control' {
        # Arrange
        $pattern = '# --- 900[0-9]{3}:'

        # Assert
        @($script:ModuleText -split "`n" | Where-Object { $_ -match $pattern }).Count | Should -Be 0
        '# --- 900004: x ---' | Should -Match $pattern
    }

    It 'reports no finding for the committed registry' {
        (Test-DocsAnalyzerRegistration -Registration (Get-DocsAnalyzerRegistration)).Count | Should -Be 0
    }
}

Describe 'Get-DocsAnalyzerRegistration' {
    It 'returns the scanner rows followed by the native rows, each found by Id and AnalysisMethod' {
        # Arrange
        $scanner = @((New-TestRow -Id 'alpha'), (New-TestRow -Id 'beta'))
        $native = @(New-TestRow -Id 'alpha' -AnalysisMethod 'native')

        # Act
        $rows = Get-DocsAnalyzerRegistration -ScannerRow $scanner -NativeRow $native

        # Assert
        @($rows | ForEach-Object { "$($_.Id)/$($_.AnalysisMethod)" }) | Should -Be @('alpha/scanner', 'beta/scanner', 'alpha/native')
        foreach ($row in $scanner + $native) {
            @($rows | Where-Object { $_.Id -ceq $row.Id -and $_.AnalysisMethod -ceq $row.AnalysisMethod }).Count | Should -Be 1
        }
    }
}

Describe 'Test-DocsAnalyzerRegistration' {
    It 'accepts a scanner row and a native row that share an Id across the two tables' {
        # Arrange
        $rows = Get-DocsAnalyzerRegistration -ScannerRow @((New-TestRow -Id 'alpha'), (New-TestRow -Id 'beta')) -NativeRow @(New-TestRow -Id 'alpha' -AnalysisMethod 'native')

        # Act and Assert
        (Test-DocsAnalyzerRegistration -Registration $rows).Count | Should -Be 0
    }

    It 'reports a defective native-table row at a pointer beginning /2/ and a defective scanner-table row at /0/' {
        # Arrange
        $nativeDefect = Get-DocsAnalyzerRegistration -ScannerRow @((New-TestRow -Id 'alpha'), (New-TestRow -Id 'beta')) -NativeRow @(New-TestRow -Id 'alpha' -AnalysisMethod 'native' -Version ' ')
        $scannerDefect = Get-DocsAnalyzerRegistration -ScannerRow @((New-TestRow -Id 'alpha' -Version ''), (New-TestRow -Id 'beta')) -NativeRow @()

        # Act
        $nativeResult = Test-DocsAnalyzerRegistration -Registration $nativeDefect
        $scannerResult = Test-DocsAnalyzerRegistration -Registration $scannerDefect

        # Assert
        $nativeResult.Count | Should -Be 1
        $nativeResult[0].code | Should -BeExactly 'DOCS_ANALYZER_REGISTRATION_INVALID'
        $nativeResult[0].pointer | Should -BeExactly '/2/Version'
        $scannerResult[0].pointer | Should -BeLike '/0/*'
    }

    It 'reports a duplicate (Id, AnalysisMethod) pair when the native table repeats a native row' {
        # Arrange
        $rows = Get-DocsAnalyzerRegistration -ScannerRow @(New-TestRow -Id 'alpha') -NativeRow @((New-TestRow -Id 'alpha' -AnalysisMethod 'native'), (New-TestRow -Id 'alpha' -AnalysisMethod 'native'))

        # Act
        $result = Test-DocsAnalyzerRegistration -Registration $rows

        # Assert
        $result.Count | Should -Be 1
        $result[0].pointer | Should -BeExactly '/2/Id'
    }

    It 'reports <Case> at <Pointer>' -ForEach @(
        @{ Case = 'a duplicate scanner pair'; Rows = { @((New-TestRow -Id 'alpha'), (New-TestRow -Id 'alpha')) }; Pointer = '/1/Id' }
        @{ Case = 'an AnalysisMethod outside the set'; Rows = { @(New-TestRow -AnalysisMethod 'heuristic') }; Pointer = '/0/AnalysisMethod' }
        @{ Case = 'a native row without a scanner row'; Rows = { @(New-TestRow -Id 'alpha' -AnalysisMethod 'native') }; Pointer = '/0/AnalysisMethod' }
        @{ Case = 'a Module outside .claude/lib/docs'; Rows = { @(New-TestRow -Module (Join-Path -Path $script:DocsRoot -ChildPath '../DocsAnalyzerExample.psm1')) }; Pointer = '/0/Module' }
        @{ Case = 'a Module without a DocsAnalyzer leaf'; Rows = { @(New-TestRow -Module (Join-Path -Path $script:DocsRoot -ChildPath 'Other.psm1')) }; Pointer = '/0/Module' }
        @{ Case = 'an Id outside the identifier grammar'; Rows = { @(New-TestRow -Id 'Bad Id') }; Pointer = '/0/Id' }
        @{ Case = 'empty ElementKinds'; Rows = { @(New-TestRow -ElementKinds @()) }; Pointer = '/0/ElementKinds' }
        @{ Case = 'an unknown element kind'; Rows = { @(New-TestRow -ElementKinds @('widget')) }; Pointer = '/0/ElementKinds' }
        @{ Case = 'a Function outside the grammar'; Rows = { @(New-TestRow -Function 'Get-Example') }; Pointer = '/0/Function' }
    ) {
        # Act
        $result = Test-DocsAnalyzerRegistration -Registration (& $Rows)

        # Assert
        @($result | Where-Object { $_.code -eq 'DOCS_ANALYZER_REGISTRATION_INVALID' -and $_.pointer -eq $Pointer }).Count | Should -Be 1
    }
}

Describe 'Select-DocsAnalyzerRegistration' {
    BeforeAll {
        $script:Registry = Get-DocsAnalyzerRegistration -ScannerRow @((New-TestRow -Id 'alpha' -ElementKinds @('cli-command')), (New-TestRow -Id 'beta' -ElementKinds @('http-route'))) -NativeRow @(New-TestRow -Id 'alpha' -AnalysisMethod 'native' -ElementKinds @('cli-command'))
    }

    It 'reports DOCS_ANALYZER_UNKNOWN for an unknown identifier and imports nothing' {
        # Arrange
        $log = [System.Collections.Generic.List[string]]::new()
        $seam = New-RecordingImport -Log $log -Path $script:FixturePath

        # Act
        $selection = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('cli-command') -AnalyzerId @('alpha', 'gamma')
        foreach ($row in $selection.Rows) { [void](Invoke-DocsAnalyzer -Registration $row -CapturedInput $script:Captured -Selection (New-TestSelection) -ImportModule $seam) }

        # Assert
        $selection.Findings.Count | Should -Be 1
        $selection.Findings[0].code | Should -BeExactly 'DOCS_ANALYZER_UNKNOWN'
        $selection.Findings[0].message | Should -Match 'gamma'
        $selection.Rows.Count | Should -Be 0
        $log.Count | Should -Be 0
    }

    It 'returns the native row for an Id in NativeAvailable and the scanner row otherwise' {
        # Act
        $native = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('cli-command') -AnalyzerId @('alpha') -NativeAvailable @('alpha')
        $scanner = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('cli-command') -AnalyzerId @('alpha')
        $fallback = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('http-route') -AnalyzerId @('beta') -NativeAvailable @('beta')

        # Assert
        $native.Rows[0].AnalysisMethod | Should -BeExactly 'native'
        $scanner.Rows[0].AnalysisMethod | Should -BeExactly 'scanner'
        $fallback.Rows[0].AnalysisMethod | Should -BeExactly 'scanner'
    }

    It 'selects by element kind without AnalyzerId and is invariant under input order' {
        # Arrange
        $reversed = [object[]]@($script:Registry)
        [Array]::Reverse($reversed)

        # Act
        $forward = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('http-route', 'cli-command')
        $backward = Select-DocsAnalyzerRegistration -Registration $reversed -ElementKind @('cli-command', 'http-route')
        $onlyRoutes = Select-DocsAnalyzerRegistration -Registration $script:Registry -ElementKind @('http-route')

        # Assert
        @($forward.Rows | ForEach-Object { "$($_.Id)/$($_.AnalysisMethod)" }) | Should -Be @('alpha/scanner', 'beta/scanner')
        @($backward.Rows | ForEach-Object { "$($_.Id)/$($_.AnalysisMethod)" }) | Should -Be @('alpha/scanner', 'beta/scanner')
        @($onlyRoutes.Rows | ForEach-Object { $_.Id }) | Should -Be @('beta')
    }
}

Describe 'New-DocsCapturedInput' {
    It 'decodes valid UTF-8 and records path, digest and size' {
        # Act
        $captured = New-DocsCapturedInput -Path 'a/b.txt' -Bytes ([byte[]](0x61, 0x62))

        # Assert
        $captured.text | Should -BeExactly 'ab'
        $captured.size | Should -Be 2
        $captured.sha256 | Should -Match '^[0-9a-f]{64}$'
        $captured.diagnostic | Should -BeNullOrEmpty
    }

    It 'carries a diagnostic and text null for an input above MaxBytes' {
        # Act
        $captured = New-DocsCapturedInput -Path 'a/b.txt' -Bytes ([byte[]](0x61, 0x62, 0x63)) -MaxBytes 2

        # Assert
        $captured.text | Should -BeNullOrEmpty
        $captured.diagnostic.code | Should -BeExactly 'DOCS_INPUT_TOO_LARGE'
    }

    It 'carries a diagnostic and text null for invalid UTF-8' {
        # Act
        $captured = New-DocsCapturedInput -Path 'a/b.txt' -Bytes ([byte[]](0xC3, 0x28))

        # Assert
        $captured.text | Should -BeNullOrEmpty
        $captured.diagnostic.code | Should -BeExactly 'DOCS_INPUT_NOT_UTF8'
    }

    It 'rejects a non-relative path' {
        { New-DocsCapturedInput -Path '/abs/b.txt' -Bytes ([byte[]]@()) } | Should -Throw -ExpectedMessage '*DOCS_IDENTITY_INPUT_INVALID*'
    }
}

Describe 'Invoke-DocsAnalyzer' {
    It 'accepts in-registration fixture output loaded through the seam' {
        # Arrange
        $log = [System.Collections.Generic.List[string]]::new()

        # Act
        $result = Invoke-DocsAnalyzer -Registration $script:FixtureRow -CapturedInput $script:Captured -Selection (New-TestSelection) -ImportModule (New-RecordingImport -Log $log -Path $script:FixturePath)

        # Assert
        $log.Count | Should -Be 1
        $result.Findings.Count | Should -Be 0
        $result.Elements.Count | Should -Be 1
        $result.Elements[0].source_sha256 | Should -BeExactly (Get-DocsDeclarationSha256 -Text $script:SourceText -LineRange @(2, 2))
    }

    It 'imports the registered module through the default seam' {
        # Act
        $result = Invoke-DocsAnalyzer -Registration $script:FixtureRow -CapturedInput $script:Captured -Selection (New-TestSelection)

        # Assert
        $result.Findings.Count | Should -Be 0
        $result.Elements[0].kind | Should -BeExactly 'cli-command'
    }

    It 'rejects output whose kind is outside the registration' {
        # Arrange
        $row = New-TestRow -Id 'fixture' -ElementKinds @('http-route') -Module $script:FixturePath -Function 'Invoke-DocsAnalyzerFixture'

        # Act
        $result = Invoke-DocsAnalyzer -Registration $row -CapturedInput $script:Captured -Selection (New-TestSelection) -ImportModule (New-RecordingImport -Log ([System.Collections.Generic.List[string]]::new()) -Path $script:FixturePath)

        # Assert
        $result.Elements.Count | Should -Be 0
        $result.Findings[0].code | Should -BeExactly 'DOCS_ANALYZER_OUTPUT_INVALID'
        $result.Findings[0].message | Should -Match 'outside the registration'
    }

    It 'rejects output whose analysis_method differs from the row' {
        # Act
        $result = Invoke-DocsAnalyzer -Registration $script:FixtureRow -CapturedInput $script:Captured -Selection (New-TestSelection -AnalysisMethod 'native') -ImportModule (New-RecordingImport -Log ([System.Collections.Generic.List[string]]::new()) -Path $script:FixturePath)

        # Assert
        @($result.Findings | Where-Object { $_.message -match 'analysis_method differs' }).Count | Should -Be 1
    }

    It 'rejects output whose source_sha256 differs from the recomputed digest' {
        # Arrange
        $altered = {
            param($CapturedInput, $Selection)
            $output = Invoke-DocsAnalyzerFixture -CapturedInput $CapturedInput -Selection $Selection
            $output['Elements'][0]['source_sha256'] = '0' * 64
            $output
        }

        # Act
        $result = Invoke-DocsAnalyzer -Registration $script:FixtureRow -CapturedInput $script:Captured -Selection (New-TestSelection) -ImportModule (New-RecordingImport -Log ([System.Collections.Generic.List[string]]::new()) -Path $script:FixturePath) -AnalyzerFunction $altered

        # Assert
        @($result.Findings | Where-Object { $_.message -match 'source_sha256 differs' }).Count | Should -Be 1
    }

    It 'rejects output with a foreign analyzer_id, a tampered element_id, a missing input and a non-object element' {
        # Arrange
        $altered = {
            param($CapturedInput, $Selection)
            $output = Invoke-DocsAnalyzerFixture -CapturedInput $CapturedInput -Selection $Selection
            $first = $output['Elements'][0]
            $first['analyzer_id'] = 'other'
            $first['element_id'] = 'cli-command-' + ('1' * 64)
            $first['path'] = 'src/missing.py'
            @{ Elements = @($first, 'not-an-element'); Diagnostics = @() }
        }

        # Act
        $result = Invoke-DocsAnalyzer -Registration $script:FixtureRow -CapturedInput $script:Captured -Selection (New-TestSelection) -ImportModule (New-RecordingImport -Log ([System.Collections.Generic.List[string]]::new()) -Path $script:FixturePath) -AnalyzerFunction $altered

        # Assert
        $messages = @($result.Findings | ForEach-Object { $_.message })
        @($messages | Where-Object { $_ -match 'analyzer_id differs' }).Count | Should -Be 1
        @($messages | Where-Object { $_ -match 'DOCS_ELEMENT_ID_MISMATCH' }).Count | Should -Be 1
        @($messages | Where-Object { $_ -match 'no captured input' }).Count | Should -Be 1
        @($result.Findings | Where-Object { $_.pointer -eq '/elements/1' }).Count | Should -Be 1
    }
}
