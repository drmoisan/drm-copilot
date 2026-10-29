#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for scripts/ci/New-FileSizeBaseline.ps1 (issue #990).

.DESCRIPTION
    Drives New-FileSizeBaseline with a fake git seam over an in-memory tree and a capturing
    writer seam, so no process is started and no file is written. Asserts the git argv,
    coverage filtering, the over-800 filter at the 800 and 801 boundary, the writer input,
    determinism, and the throw on a git failure. Invoke-GitExe is exercised through a mocked
    git command.
#>

BeforeAll {
    $script:ScriptPath = Join-Path $PSScriptRoot '../../../scripts/ci/New-FileSizeBaseline.ps1'
    . $script:ScriptPath -Ref 'dot-source-only'

    function Get-FakeTreeText {
        param([Parameter(Mandatory)][int] $LineCount)
        return @(1..$LineCount | ForEach-Object { "line $_" })
    }

    # Fake git over an in-memory tree: ls-tree lists the keys, cat-file returns the lines.
    function Get-FakeGitInvoker {
        param([hashtable] $Tree, [System.Collections.Generic.List[string]] $Calls, [int] $FailOn = 0)
        $treeMap = $Tree
        $callLog = $Calls
        $failAt = $FailOn
        return {
            param([string[]] $GitArgs)
            $callLog.Add(($GitArgs -join ' '))
            if ($failAt -gt 0 -and $callLog.Count -eq $failAt) { return [pscustomobject]@{ ExitCode = 128; Lines = @() } }
            if ($GitArgs[0] -eq 'ls-tree') {
                return [pscustomobject]@{ ExitCode = 0; Lines = @($treeMap.Keys | Sort-Object) }
            }
            $path = $GitArgs[2].Substring($GitArgs[2].IndexOf(':') + 1)
            return [pscustomobject]@{ ExitCode = 0; Lines = @($treeMap[$path]) }
        }.GetNewClosure()
    }

    $script:Tree = @{
        'scripts/at-limit.py'    = (Get-FakeTreeText -LineCount 800)
        'scripts/over-limit.ps1' = (Get-FakeTreeText -LineCount 801)
        'src/huge.ts'            = (Get-FakeTreeText -LineCount 1200)
        'docs/huge.py'           = (Get-FakeTreeText -LineCount 2000)
        'README.md'              = (Get-FakeTreeText -LineCount 3000)
        'config/data.json'       = (Get-FakeTreeText -LineCount 3000)
        'src/small.cs'           = (Get-FakeTreeText -LineCount 10)
    }
}

AfterAll {
    Remove-Module -Name FileSizeBaseline -Force -ErrorAction SilentlyContinue
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'New-FileSizeBaseline' {
    BeforeEach {
        $script:Calls = [System.Collections.Generic.List[string]]::new()
        $script:Written = [System.Collections.Generic.List[object]]::new()
        $written = $script:Written
        $script:Writer = { param([string] $Path, [string] $Text) $written.Add([pscustomobject]@{ Path = $Path; Text = $Text }) }.GetNewClosure()
    }

    It 'lists the tracked tree at the ref with git ls-tree -r --name-only' {
        $null = New-FileSizeBaseline -Ref 'abc123' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer

        $script:Calls[0] | Should -BeExactly 'ls-tree -r --name-only abc123'
    }

    It 'reads only covered blobs at the ref with git cat-file blob' {
        $null = New-FileSizeBaseline -Ref 'abc123' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer

        @($script:Calls | Select-Object -Skip 1) | Should -Be @(
            'cat-file blob abc123:scripts/at-limit.py',
            'cat-file blob abc123:scripts/over-limit.ps1',
            'cat-file blob abc123:src/huge.ts',
            'cat-file blob abc123:src/small.cs'
        )
    }

    It 'keeps covered files above 800 lines and excludes 800 exactly' {
        $result = New-FileSizeBaseline -Ref 'abc123' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer

        @($result.Files.Keys | Sort-Object) | Should -Be @('scripts/over-limit.ps1', 'src/huge.ts')
        $result.Files['scripts/over-limit.ps1'] | Should -Be 801
        $result.Files['src/huge.ts'] | Should -Be 1200
    }

    It 'writes the canonical JSON to the output path once' {
        $result = New-FileSizeBaseline -Ref 'abc123' -OutputPath 'out/baseline.json' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer

        $script:Written.Count | Should -Be 1
        $script:Written[0].Path | Should -Be 'out/baseline.json'
        $script:Written[0].Text | Should -BeExactly $result.Json
        $script:Written[0].Text | Should -BeExactly ("{`n  `"schemaVersion`": 1,`n  `"hardLimit`": 800,`n  `"files`": {`n" +
            "    `"scripts/over-limit.ps1`": 801,`n    `"src/huge.ts`": 1200`n  }`n}`n")
    }

    It 'produces byte-identical text on two runs at the same ref' {
        $first = New-FileSizeBaseline -Ref 'abc123' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer
        $second = New-FileSizeBaseline -Ref 'abc123' -GitInvoker (Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls) -Writer $script:Writer

        $second.Json | Should -BeExactly $first.Json
    }

    It 'counts a blob whose last element is empty like the logical line count (<Name>)' -ForEach @(
        @{ Name = '800 text lines plus a final empty element'; TextLines = 800; Trailing = @(''); ExpectedCount = 801; Baselined = $true }
        @{ Name = '801 text lines'; TextLines = 801; Trailing = @(); ExpectedCount = 801; Baselined = $true }
        @{ Name = 'a single empty element'; TextLines = 0; Trailing = @(''); ExpectedCount = 1; Baselined = $false }
        @{ Name = 'an empty element array'; TextLines = 0; Trailing = @(); ExpectedCount = 0; Baselined = $false }
    ) {
        # Arrange
        $textElements = if ($TextLines -gt 0) { Get-FakeTreeText -LineCount $TextLines } else { @() }
        $elements = @($textElements + $Trailing)
        $tree = @{ 'scripts/blob-row.ps1' = $elements }
        $invoker = Get-FakeGitInvoker -Tree $tree -Calls $script:Calls
        $onDiskText = if ($elements.Count -eq 0) { '' } else { ($elements -join "`n") + "`n" }

        # Act
        $result = New-FileSizeBaseline -Ref 'abc123' -GitInvoker $invoker -Writer $script:Writer

        # Assert
        Get-FileSizeLogicalLineCount -Content $onDiskText | Should -Be $ExpectedCount
        $result.Files.ContainsKey('scripts/blob-row.ps1') | Should -Be $Baselined
        if ($Baselined) {
            $result.Files['scripts/blob-row.ps1'] | Should -Be $ExpectedCount
        }
    }

    It 'throws when git fails on call <FailOn>' -ForEach @(
        @{ FailOn = 1; Message = '*git ls-tree -r --name-only abc123 failed with exit code 128*' }
        @{ FailOn = 2; Message = '*git cat-file blob abc123:scripts/at-limit.py failed*' }
    ) {
        $invoker = Get-FakeGitInvoker -Tree $script:Tree -Calls $script:Calls -FailOn $FailOn

        { New-FileSizeBaseline -Ref 'abc123' -GitInvoker $invoker -Writer $script:Writer } | Should -Throw $Message
        $script:Written.Count | Should -Be 0
    }
}

Describe 'Invoke-GitExe and the default seams' {
    BeforeEach {
        # The git executable is replaced by a function so no process starts; the automatic
        # exit-code variable it sets is restored in AfterEach.
        $script:SavedExitCode = Get-Variable -Name LASTEXITCODE -Scope Global -ValueOnly -ErrorAction SilentlyContinue
        function git {
            if ($args[0] -eq 'ls-tree') { 'scripts/big.py'; 'README.md' } else { 1..801 | ForEach-Object { "line $_" } }
            $global:LASTEXITCODE = 0
        }
        Mock Set-Content { }
    }

    AfterEach {
        if ($null -eq $script:SavedExitCode) {
            Remove-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
        } else {
            $global:LASTEXITCODE = $script:SavedExitCode
        }
    }

    It 'returns the git exit code and output lines' {
        # Act
        $result = Invoke-GitExe -GitArgs @('ls-tree', '-r', '--name-only', 'abc123')

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Lines | Should -Be @('scripts/big.py', 'README.md')
    }

    It 'uses the default git and writer seams and writes a relative path under the current location' {
        # Act
        $result = New-FileSizeBaseline -Ref 'abc123' -OutputPath 'config/file-size-baseline.json'

        # Assert
        $result.Files['scripts/big.py'] | Should -Be 801
        Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter {
            $LiteralPath.Replace('\', '/').EndsWith('config/file-size-baseline.json') -and $NoNewline -and $Value -ceq $result.Json
        }
    }

    It 'writes a rooted output path unchanged' {
        # Arrange
        $rooted = Join-Path (Get-Location).ProviderPath 'rooted-baseline.json'

        # Act
        Write-FileSizeBaselineText -Path $rooted -Text "{}`n"

        # Assert
        Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $rooted }
    }

    It 'runs the script entry point in process and exits 0' {
        # Act
        & $script:ScriptPath -Ref 'abc123' -OutputPath 'config/file-size-baseline.json' 6>$null
        $exitCode = $LASTEXITCODE

        # Assert
        $exitCode | Should -Be 0
        Should -Invoke Set-Content -Times 1 -Exactly
    }
}
