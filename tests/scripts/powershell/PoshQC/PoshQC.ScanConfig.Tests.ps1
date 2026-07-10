Set-StrictMode -Version Latest

BeforeAll {
    $modulePath = (Resolve-Path -Path (Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1')).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $modulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module $modulePath -Force
}

Describe 'Get-PoshQCScanConfigFolder' {
    It 'returns an empty array when the configuration file is absent' {
        # The config existence check returns false, so no read is attempted.
        $result = Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $false } -ReadContent { throw 'should not read' }

        $result | Should -BeNullOrEmpty
    }

    It 'returns an empty array when the file content is blank' {
        $result = Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '   ' }

        $result | Should -BeNullOrEmpty
    }

    It 'returns an empty array when test.scanFolders is absent' {
        $result = Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 1, "test": {} }' }

        $result | Should -BeNullOrEmpty
    }

    It 'returns an empty array when test.scanFolders is an empty list' {
        $result = Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 1, "test": { "scanFolders": [] } }' }

        $result | Should -BeNullOrEmpty
    }

    It 'throws an error naming the file for malformed JSON' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ not-valid-json' }
        } | Should -Throw '*config/poshqc-scan.json*'
    }

    It 'throws an error naming the file when version is not 1' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 2, "test": { "scanFolders": ["scripts"] } }' }
        } | Should -Throw "*config/poshqc-scan.json*version*"
    }

    It 'throws an error naming the file for a blank entry' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 1, "test": { "scanFolders": ["scripts", "  "] } }' }
        } | Should -Throw "*config/poshqc-scan.json*blank*"
    }

    It 'throws an error naming the file for an absolute-path entry' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 1, "test": { "scanFolders": ["C:/absolute/path"] } }' }
        } | Should -Throw "*config/poshqc-scan.json*absolute*"
    }

    It 'throws an error naming the file for an entry containing a parent traversal segment' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { param([string] $Path) [void] $Path; '{ "version": 1, "test": { "scanFolders": ["../outside"] } }' }
        } | Should -Throw "*config/poshqc-scan.json*'..'*"
    }

    It 'skips a nonexistent config-sourced folder with a logged warning and returns the survivors' {
        $script:warnings = @()

        $result = Get-PoshQCScanConfigFolder -Root '/repo' -ReadContent {
            param([string] $Path)
            [void] $Path
            '{ "version": 1, "test": { "scanFolders": ["scripts", "tests/powershell"] } }'
        } -TestPathExists {
            param([string] $Path)
            # The configuration file and existing folders resolve true; the missing folder resolves false.
            if ($Path -like '*poshqc-scan.json') { return $true }
            if ($Path -like '*tests?powershell') { return $false }
            return $true
        } -Logger {
            param([string] $Message)
            $script:warnings += $Message
        }

        $result | Should -Be @('scripts')
        $script:warnings | Should -HaveCount 1
        $script:warnings[0] | Should -BeLike '*tests/powershell*'
    }

    It 'throws a clear error when every config-sourced folder is missing' {
        {
            Get-PoshQCScanConfigFolder -Root '/repo' -ReadContent {
                param([string] $Path)
                [void] $Path
                '{ "version": 1, "test": { "scanFolders": ["scripts", "tests/powershell"] } }'
            } -TestPathExists {
                param([string] $Path)
                # Only the configuration file exists; both configured folders are missing.
                if ($Path -like '*poshqc-scan.json') { return $true }
                return $false
            } -Logger { param([string] $Message) [void] $Message }
        } | Should -Throw "*config/poshqc-scan.json*do not exist*"
    }

    It 'returns every configured folder when all of them exist' {
        $result = Get-PoshQCScanConfigFolder -Root '/repo' -ReadContent {
            param([string] $Path)
            [void] $Path
            '{ "version": 1, "test": { "scanFolders": ["scripts", "tests/scripts"] } }'
        } -TestPathExists {
            param([string] $Path)
            [void] $Path
            $true
        } -Logger { param([string] $Message) [void] $Message }

        $result | Should -Be @('scripts', 'tests/scripts')
    }
}
