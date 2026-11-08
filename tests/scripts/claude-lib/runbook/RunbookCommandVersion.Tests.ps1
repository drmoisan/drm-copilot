#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for .claude/lib/runbook/RunbookCommandVersion.psm1 (issue #1128).

.DESCRIPTION
    Every case supplies lockfile and runbook text in memory. The tests create no temporary file,
    start no process, and read no clock.
#>

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/runbook/RunbookCommandVersion.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    function Get-PoetryLockText {
        # Builds a poetry.lock text pinning the given name/version pairs.
        param([hashtable] $Package)
        return (($Package.GetEnumerator() | Sort-Object Name | ForEach-Object {
                    "[[package]]`nname = `"$($_.Key)`"`nversion = `"$($_.Value)`"`ndescription = `"x`"`n"
                }) -join "`n")
    }

    function Get-FencedRunbookText {
        # Builds a runbook with one fenced block and the given text immediately after the closing fence.
        param([string] $Info = 'sh', [string[]] $Command, [string[]] $AfterFence = @())
        return (@('# Runbook', '', ('```' + $Info)) + $Command + @('```') + $AfterFence + @('', '## Verification')) -join "`n"
    }
}

AfterAll {
    Remove-Module -Name RunbookCommandVersion -Force -ErrorAction SilentlyContinue
}

Describe 'Get-RunbookCommandVersionFinding reproduction (AC 1)' {
    It 'reports a finding naming nuitka and 4.3.4 for an unmarked nuitka command' {
        # Arrange
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'poetry.lock' -Content (Get-PoetryLockText -Package @{ nuitka = '4.3.4' })
        $runbook = Get-FencedRunbookText -Command @('python -m nuitka --clean-cache=clcache')

        # Act
        $finding = @(Get-RunbookCommandVersionFinding -RunbookText $runbook -PinnedVersion $pinned)

        # Assert
        $finding.Count | Should -Be 1
        $finding[0] | Should -BeLike '*nuitka*'
        $finding[0] | Should -BeLike '*4.3.4*'
    }
}
