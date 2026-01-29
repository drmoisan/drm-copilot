Set-StrictMode -Version Latest

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1') -Force
}

Describe 'Get-PoshQCFileList (default excludes)' {
    It 'excludes files under .vscode-test by default' {
        $resolvePath = {
            param([string] $Path)
            $Path
        }
        $enumerateFiles = {
            param([string] $Path)
            [void] $Path
            @(
                [pscustomobject]@{ FullName = '/repo/.vscode-test/shellIntegration.ps1'; Extension = '.ps1' },
                [pscustomobject]@{ FullName = '/repo/scripts/dev-tools/foo.ps1'; Extension = '.ps1' }
            )
        }

        $result = Get-PoshQCFileList -Root '/repo' -ResolvePath $resolvePath -EnumerateFiles $enumerateFiles

        $result | Should -HaveCount 1
        $result[0].FullName | Should -Be '/repo/scripts/dev-tools/foo.ps1'
    }
}
