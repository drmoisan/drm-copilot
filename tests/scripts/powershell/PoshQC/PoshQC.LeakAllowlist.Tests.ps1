Set-StrictMode -Version Latest

BeforeAll {
    # Module-collision guard following PoshQC.TestingInvokeConfigPaths.Tests.ps1: remove any PoshQC
    # instance loaded from another path, then import the repository-root module (issue #392).
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force

    # In-memory scan seams: file text keyed by repository-relative path, with no file system access.
    function Get-LeakScanSeam {
        param([hashtable] $Files, [string] $Allowlist)
        $calls = [System.Collections.Generic.List[string]]::new()
        $messages = [System.Collections.Generic.List[string]]::new()
        $fileMap = $Files
        $allowlistText = $Allowlist
        [pscustomobject]@{
            Calls          = $calls
            Messages       = $messages
            ReadText       = { param([string] $Path) $fileMap[($Path -replace '^.*?/(tests/)', '$1')] }.GetNewClosure()
            ReadAllowlist  = { param([string] $Path) [void] $Path; $allowlistText }.GetNewClosure()
            EnumerateFiles = {
                param([string] $Path)
                $calls.Add(($Path -replace '^.*?/(tests/)', '$1'))
                foreach ($key in $fileMap.Keys) { $Path + '/' + ($key -replace '^tests/[^/]+/', '') }
            }.GetNewClosure()
            Logger         = { param([string] $Message) $messages.Add($Message) }.GetNewClosure()
        }
    }
}

Describe 'ConvertFrom-PoshQCLeakAllowlist validation (issue #1096)' {
    It 'LA-01 returns the exemption and entries of a valid file' {
        # Arrange
        $text = '{ "version": 1, "exemptGlobalVariables": [ { "name": "LASTEXITCODE", "reason": "native commands overwrite it" } ], "entries": [ { "path": "tests/scripts/a.Tests.ps1", "kind": "env", "name": "FOO", "reason": "restored by a scriptblock variable" } ] }'

        # Act
        $allowlist = InModuleScope PoshQC -Parameters @{ Text = $text } {
            param([string] $Text)
            ConvertFrom-PoshQCLeakAllowlist -Text $Text -SourceName 'config/poshqc-leak-allowlist.json'
        }

        # Assert
        $allowlist.Exempt.Contains('LASTEXITCODE') | Should -BeTrue
        $allowlist.Entries.Count | Should -Be 1
        $allowlist.Entries[0].Path | Should -BeExactly 'tests/scripts/a.Tests.ps1'
        $allowlist.Entries[0].Reason | Should -BeExactly 'restored by a scriptblock variable'
    }

    It 'LA-02 treats <Label> input as an empty allowlist' -ForEach @(
        @{ Label = 'absent'; Text = $null }
        @{ Label = 'blank'; Text = "  `n " }
    ) {
        # Act
        $allowlist = InModuleScope PoshQC -Parameters @{ Text = $Text } {
            param([string] $Text)
            ConvertFrom-PoshQCLeakAllowlist -Text $Text -SourceName 'config/poshqc-leak-allowlist.json'
        }

        # Assert
        $allowlist.Exempt.Count | Should -Be 0
        $allowlist.Entries.Count | Should -Be 0
    }

    It 'LA-03 rejects <Label> and names the file' -ForEach @(
        @{ Label = 'a wrong version'; Text = '{ "version": 2 }'; Expected = '*version*' }
        @{ Label = 'a string version'; Text = '{ "version": "1" }'; Expected = '*version*' }
        @{ Label = 'bad JSON'; Text = '{ "version": 1, '; Expected = '*Invalid JSON*' }
        @{ Label = 'an unknown kind'; Text = '{ "version": 1, "entries": [ { "path": "tests/a.Tests.ps1", "kind": "registry", "name": "X", "reason": "r" } ] }'; Expected = '*unknown kind*' }
        @{ Label = 'a blank path'; Text = '{ "version": 1, "entries": [ { "path": " ", "kind": "env", "name": "X", "reason": "r" } ] }'; Expected = '*blank*path*' }
        @{ Label = 'a blank name'; Text = '{ "version": 1, "entries": [ { "path": "tests/a.Tests.ps1", "kind": "env", "name": "", "reason": "r" } ] }'; Expected = '*blank*name*' }
        @{ Label = 'a missing reason'; Text = '{ "version": 1, "entries": [ { "path": "tests/a.Tests.ps1", "kind": "env", "name": "X" } ] }'; Expected = '*blank*reason*' }
        @{ Label = 'a blank reason'; Text = '{ "version": 1, "entries": [ { "path": "tests/a.Tests.ps1", "kind": "env", "name": "X", "reason": "  " } ] }'; Expected = '*blank*reason*' }
        @{ Label = 'an absolute path'; Text = '{ "version": 1, "entries": [ { "path": "/tests/a.Tests.ps1", "kind": "env", "name": "X", "reason": "r" } ] }'; Expected = '*absolute*' }
        @{ Label = 'a parent segment'; Text = '{ "version": 1, "entries": [ { "path": "tests/../a.Tests.ps1", "kind": "env", "name": "X", "reason": "r" } ] }'; Expected = '*..*' }
        @{ Label = 'a duplicate entry'; Text = '{ "version": 1, "entries": [ { "path": "tests/a.Tests.ps1", "kind": "env", "name": "X", "reason": "r" }, { "path": "tests/a.Tests.ps1", "kind": "env", "name": "x", "reason": "s" } ] }'; Expected = '*more than once*' }
        @{ Label = 'an exempt name other than LASTEXITCODE'; Text = '{ "version": 1, "exemptGlobalVariables": [ { "name": "ErrorActionPreference", "reason": "r" } ] }'; Expected = '*only LASTEXITCODE*' }
        @{ Label = 'an exemption without a reason'; Text = '{ "version": 1, "exemptGlobalVariables": [ { "name": "LASTEXITCODE" } ] }'; Expected = '*blank name or reason*' }
        @{ Label = 'entries that are not an array'; Text = '{ "version": 1, "entries": { "path": "tests/a.Tests.ps1" } }'; Expected = '*must be an array*' }
    ) {
        # Act
        $action = {
            InModuleScope PoshQC -Parameters @{ Text = $Text } {
                param([string] $Text)
                ConvertFrom-PoshQCLeakAllowlist -Text $Text -SourceName 'config/poshqc-leak-allowlist.json'
            }
        }

        # Assert
        $action | Should -Throw -ExpectedMessage $Expected
        $action | Should -Throw -ExpectedMessage '*config/poshqc-leak-allowlist.json*'
    }
}

Describe 'Compare-PoshQCLeakAllowlist (issue #1096)' {
    BeforeAll {
        $script:allowlistText = '{ "version": 1, "exemptGlobalVariables": [ { "name": "LASTEXITCODE", "reason": "r" } ], "entries": [ { "path": "tests/scripts/a.Tests.ps1", "kind": "env", "name": "FOO", "reason": "r" }, { "path": "tests/scripts/gone.Tests.ps1", "kind": "location", "name": "location", "reason": "r" } ] }'
        $script:findings = @(
            [pscustomobject]@{ Path = 'tests/scripts/a.Tests.ps1'; Line = 1; Kind = 'global-variable'; Name = 'lastexitcode' }
            [pscustomobject]@{ Path = 'tests\scripts\a.Tests.ps1'; Line = 2; Kind = 'env'; Name = 'foo' }
            [pscustomobject]@{ Path = 'tests/scripts/a.Tests.ps1'; Line = 3; Kind = 'env'; Name = 'LASTEXITCODE' }
            [pscustomobject]@{ Path = 'tests/scripts/A.Tests.ps1'; Line = 4; Kind = 'env'; Name = 'FOO' }
        )
        $script:comparison = InModuleScope PoshQC -Parameters @{ Text = $script:allowlistText; Findings = $script:findings } {
            param([string] $Text, [object[]] $Findings)
            Compare-PoshQCLeakAllowlist -Finding $Findings -Allowlist (ConvertFrom-PoshQCLeakAllowlist -Text $Text -SourceName 'config/poshqc-leak-allowlist.json')
        }
    }

    It 'LA-04 removes an exempt global variable but not an env variable of the same name' {
        $script:comparison.ExemptCount | Should -Be 1
        @($script:comparison.Unallowed | ForEach-Object Line) | Should -Contain 3
    }

    It 'LA-05 removes an allowlisted finding after normalizing its path' {
        $script:comparison.AllowlistedCount | Should -Be 1
        @($script:comparison.Unallowed | ForEach-Object Line) | Should -Not -Contain 2
    }

    It 'LA-06 returns an unallowed finding, comparing paths ordinally' {
        @($script:comparison.Unallowed | ForEach-Object Line) | Should -Be @(3, 4)
    }

    It 'LA-07 returns an entry that matches no raw finding as stale' {
        @($script:comparison.Stale).Count | Should -Be 1
        $script:comparison.Stale[0].Path | Should -BeExactly 'tests/scripts/gone.Tests.ps1'
    }
}

Describe 'Invoke-PoshQCLeakScan (issue #1096)' {
    It 'LI-01 passes when every finding is exempt or allowlisted' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = "`$global:LASTEXITCODE = 1`n`$env:FOO = 1" } -Allowlist '{ "version": 1, "exemptGlobalVariables": [ { "name": "LASTEXITCODE", "reason": "r" } ], "entries": [ { "path": "tests/scripts/a.Tests.ps1", "kind": "env", "name": "FOO", "reason": "r" } ] }'

        # Act
        { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger } | Should -Not -Throw

        # Assert
        @($seam.Messages | Where-Object { $_ -like '* | *' }).Count | Should -Be 0
        $seam.Messages[-1] | Should -BeLike '*1 exempt, 1 allowlisted, 0 failures*'
    }

    It 'LI-02 throws on an unallowlisted finding, naming path, line, and kind' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = "`$x = 1`n`$env:FOO = 1" } -Allowlist $null

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*tests/scripts/a.Tests.ps1 | 2 | env | FOO*'
        $seam.Messages | Should -Contain 'tests/scripts/a.Tests.ps1 | 2 | env | FOO'
    }

    It 'LI-03 throws on a parse error and names the file' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/broken.Tests.ps1' = 'function {' } -Allowlist $null

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*tests/scripts/broken.Tests.ps1 | 0 | parse-error*'
    }

    It 'LI-04 throws on an invalid allowlist' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$x = 1' } -Allowlist '{ "version": 3 }'

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*config/poshqc-leak-allowlist.json*version*'
    }

    It 'LI-05 throws on a stale allowlist entry' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$x = 1' } -Allowlist '{ "version": 1, "entries": [ { "path": "tests/scripts/a.Tests.ps1", "kind": "env", "name": "FOO", "reason": "r" } ] }'

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*tests/scripts/a.Tests.ps1 | stale | env | FOO*'
    }

    It 'LI-06 enumerates .ps1 helpers and ignores other extensions' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/Support/Helper.ps1' = 'function global:Import-Helper { }'; 'tests/scripts/Module.psm1' = '$env:IGNORED = 1' } -Allowlist $null

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*tests/scripts/Support/Helper.ps1 | 1 | global-function | Import-Helper*'
        @($seam.Messages | Where-Object { $_ -like '*IGNORED*' }).Count | Should -Be 0
    }

    It 'LI-07 ignores supplied folders outside tests/' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$x = 1' } -Allowlist $null

        # Act
        Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('scripts', 'tests/scripts', 'testsuite') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger

        # Assert
        @($seam.Calls) | Should -Be @('tests/scripts')
    }

    It 'LI-08 passes when no supplied folder lies under tests/' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$env:FOO = 1' } -Allowlist $null

        # Act
        { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger } | Should -Not -Throw

        # Assert
        $seam.Calls.Count | Should -Be 0
    }

    It 'LI-09 reads the default folders and keeps those under tests/' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$x = 1' } -Allowlist $null

        # Act: Mock and call share InModuleScope, because Mock -ModuleName from test code is not honored in a PoshQC-hosted run.
        InModuleScope PoshQC -Parameters @{ Seam = $seam } {
            param($Seam)
            Mock Get-PoshQCScanConfigFolder { @('scripts', 'tests/scripts') }
            Invoke-PoshQCLeakScan -Root '/repo' -ReadText $Seam.ReadText -ReadAllowlist $Seam.ReadAllowlist -EnumerateFiles $Seam.EnumerateFiles -Logger $Seam.Logger
            Should -Invoke Get-PoshQCScanConfigFolder -Times 1 -Exactly
        }

        # Assert
        @($seam.Calls) | Should -Be @('tests/scripts')
    }

    It 'LI-10 passes when the default folders hold none under tests/' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$env:FOO = 1' } -Allowlist $null

        # Act
        $action = {
            InModuleScope PoshQC -Parameters @{ Seam = $seam } {
                param($Seam)
                Mock Get-PoshQCScanConfigFolder { @('scripts') }
                Invoke-PoshQCLeakScan -Root '/repo' -ReadText $Seam.ReadText -ReadAllowlist $Seam.ReadAllowlist -EnumerateFiles $Seam.EnumerateFiles -Logger $Seam.Logger
            }
        }

        # Assert
        $action | Should -Not -Throw
        $seam.Calls.Count | Should -Be 0
    }

    It 'LI-11 lets the Get-PoshQCScanConfigFolder throw reach the caller' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{} -Allowlist $null

        # Act
        $action = {
            InModuleScope PoshQC -Parameters @{ Seam = $seam } {
                param($Seam)
                Mock Get-PoshQCScanConfigFolder { throw 'Scan configuration lists only folders that do not exist.' }
                Invoke-PoshQCLeakScan -Root '/repo' -ReadText $Seam.ReadText -ReadAllowlist $Seam.ReadAllowlist -EnumerateFiles $Seam.EnumerateFiles -Logger $Seam.Logger
            }
        }

        # Assert
        $action | Should -Throw -ExpectedMessage '*only folders that do not exist*'
    }

    It 'LI-12 treats an absent allowlist as empty, so LASTEXITCODE is reported' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = '$global:LASTEXITCODE = 0' } -Allowlist $null

        # Act
        $action = { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger }

        # Assert
        $action | Should -Throw -ExpectedMessage '*global-variable | LASTEXITCODE*'
    }

    It 'LI-13 logs one message per failure before the summary' {
        # Arrange
        $seam = Get-LeakScanSeam -Files @{ 'tests/scripts/a.Tests.ps1' = "Set-Location `$x`n`$env:FOO = 1" } -Allowlist $null

        # Act
        try { Invoke-PoshQCLeakScan -Root '/repo' -ScanFolders @('tests/scripts') -ReadText $seam.ReadText -ReadAllowlist $seam.ReadAllowlist -EnumerateFiles $seam.EnumerateFiles -Logger $seam.Logger } catch { [void] $_ }

        # Assert
        @($seam.Messages)[0..1] | Should -Be @('tests/scripts/a.Tests.ps1 | 1 | location | location', 'tests/scripts/a.Tests.ps1 | 2 | env | FOO')
        $seam.Messages[-1] | Should -BeLike 'Leak scan: 1 files, 2 findings, 0 exempt, 0 allowlisted, 2 failures.'
    }
}
