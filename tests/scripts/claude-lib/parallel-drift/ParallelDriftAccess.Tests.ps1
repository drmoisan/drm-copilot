<#
.SYNOPSIS
    Pester tests for the drift access-list reader (issue #1164).

.DESCRIPTION
    Covers Get-ParallelDriftAccessList in
    .claude/lib/parallel-drift/ParallelDriftAccess.psm1, the PowerShell port of
    item_access in scripts/dev_tools/_parallel_drift_scheduling.py. Item records
    are built in memory; no file is read or created.
#>

BeforeAll {
    $script:AccessModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/parallel-drift/ParallelDriftAccess.psm1").Path
    Import-Module $script:AccessModulePath -Force
}

Describe 'Get-ParallelDriftAccessList' {
    It 'returns both declared lists' {
        $item = @{ issue_num = 446; read_paths = @('docs/spec.md'); separable_paths = @('src/app.py', 'src/other.py') }

        $access = Get-ParallelDriftAccessList -Item $item

        $access['read_paths'] | Should -Be @('docs/spec.md')
        $access['separable_paths'] | Should -Be @('src/app.py', 'src/other.py')
    }

    It 'returns empty lists when the keys are absent' {
        $access = Get-ParallelDriftAccessList -Item @{ issue_num = 446 }

        $access['read_paths'].Count | Should -Be 0
        $access['separable_paths'].Count | Should -Be 0
        (Get-ParallelDriftAccessList -Item $null)['read_paths'].Count | Should -Be 0
    }

    It 'returns empty lists for a non-list value' {
        $item = @{ issue_num = 446; read_paths = 'docs/spec.md'; separable_paths = @('src/app.py', '') }

        $access = Get-ParallelDriftAccessList -Item $item

        $access['read_paths'].Count | Should -Be 0 -Because 'a bare string is not a list'
        $access['separable_paths'].Count | Should -Be 0 -Because 'a list holding an empty string is malformed'
    }
}
