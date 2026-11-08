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

Describe 'Get-RunbookPinnedToolVersion (AC 2)' {
    It 'reads name and version pairs from poetry.lock' {
        # Arrange
        $text = Get-PoetryLockText -Package @{ nuitka = '4.3.4'; black = '24.1.0' }

        # Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'poetry.lock' -Content $text

        # Assert
        $pinned['nuitka'] | Should -Be '4.3.4'
        $pinned['black'] | Should -Be '24.1.0'
        $pinned.Count | Should -Be 2
    }

    It 'reads name and version pairs from uv.lock and ignores inline dependency names' {
        # Arrange
        $text = @'
version = 1
[[package]]
name = "ruff"
version = "0.5.1"
source = { registry = "https://pypi.org/simple" }
dependencies = [
    { name = "ignored-dependency" },
]

[[package]]
name = "pyright"
version = "1.1.370"
'@

        # Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'uv.lock' -Content $text

        # Assert
        $pinned['ruff'] | Should -Be '0.5.1'
        $pinned['pyright'] | Should -Be '1.1.370'
        $pinned.ContainsKey('ignored-dependency') | Should -BeFalse
    }

    It 'reads top-level node_modules entries from package-lock.json and ignores nested paths' {
        # Arrange
        $text = '{"packages":{"":{"name":"root"},"node_modules/prettier":{"version":"3.3.2"},"node_modules/@types/node":{"version":"20.1.0"},"node_modules/prettier/node_modules/inner":{"version":"9.9.9"}}}'

        # Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'package-lock.json' -Content $text

        # Assert
        $pinned['prettier'] | Should -Be '3.3.2'
        $pinned['@types/node'] | Should -Be '20.1.0'
        $pinned.ContainsKey('inner') | Should -BeFalse
        $pinned.Count | Should -Be 2
    }

    It 'returns an empty map for a package-lock.json without a packages property' {
        # Arrange / Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'package-lock.json' -Content '{"lockfileVersion":3}'

        # Assert
        $pinned.Count | Should -Be 0
    }

    It 'reads name==version lines from a requirements file and skips other lines' {
        # Arrange
        $text = "# comment`nPyYAML==6.0.1`nrequests[security]==2.31.0 ; python_version > '3.8'`nflask>=2.0`n"

        # Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'requirements-dev.txt' -Content $text

        # Assert
        $pinned['pyyaml'] | Should -Be '6.0.1'
        $pinned['requests'] | Should -Be '2.31.0'
        $pinned.ContainsKey('flask') | Should -BeFalse
    }

    It 'applies PEP 503 normalization to a pinned name' {
        # Arrange
        $text = Get-PoetryLockText -Package @{ 'Zope_Interface' = '6.0'; 'a.b__c' = '1.0' }

        # Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'poetry.lock' -Content $text

        # Assert
        $pinned['zope-interface'] | Should -Be '6.0'
        $pinned['a-b-c'] | Should -Be '1.0'
    }

    It 'returns an empty map for an unsupported lockfile name' {
        # Arrange / Act
        $pinned = Get-RunbookPinnedToolVersion -LockfileName 'Gemfile.lock' -Content "name = `"x`""

        # Assert
        $pinned.Count | Should -Be 0
    }
}
