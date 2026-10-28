#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Convention tests for every shared PowerShell module under .claude/lib.

.DESCRIPTION
    Asserts the fail-fast calling convention across the whole .claude/lib tree:
    the module-scope error-preference guard on the line immediately following
    Set-StrictMode -Version Latest, an explicit -ErrorAction Stop on every
    column-0 load-time Import-Module statement, the fixed convention sentence in
    the leading comment-based-help block, non-leakage of the module-scope
    preference into the caller scope, and the shared file-size hard limit (800
    lines, from Get-FileSizePolicyLimit in the file-size-policy module).

    The module list is discovered from disk with Get-ChildItem -Recurse and is
    never restated, so a module added later cannot escape the convention. Files
    are read with Get-Content only: these tests create no temporary file, invoke
    no external process, read no clock, and do not depend on $PSVersionTable.
#>

BeforeAll {
    # Resolve the repository root three levels up: claude-lib -> scripts -> tests
    # -> repo root, then into the shared library root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:LibraryRoot = (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib')).Path

    # Discover the modules from disk rather than restating them, so a module added
    # later cannot be added without also carrying the convention.
    $script:DiscoveredModule = @(
        Get-ChildItem -Path $script:LibraryRoot -Filter '*.psm1' -File -Recurse |
            Sort-Object -Property FullName
    )

    # The fixed literals the convention is expressed in.
    $script:StrictModeLine = 'Set-StrictMode -Version Latest'
    $script:GuardLine = '$ErrorActionPreference = ''Stop'''
    $script:ConventionToken = 'imports its siblings with -ErrorAction Stop'
    $script:ImportStatementPrefix = 'Import-Module'
    $script:ImportGuardToken = '-ErrorAction Stop'

    # The general size gate uses the shared policy hard limit, so this suite and the
    # repository gate apply one limit to .psm1 files rather than two competing ones.
    Import-Module -Name (Join-Path $script:LibraryRoot 'file-size-policy/FileSizePolicy.psm1') -Force -ErrorAction Stop
    $script:MaximumModuleLine = (Get-FileSizePolicyLimit).HardLimit
}

AfterAll {
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'Claude library module conventions' {
    It 'discovers the claude library modules on disk' {
        # Arrange / Act: the disk-discovered module list.
        $discovered = $script:DiscoveredModule

        # Assert: an empty discovery would make every later assertion vacuous.
        $discovered.Count | Should -BeGreaterThan 0
    }

    It 'sets the fail-fast error preference at module scope in every discovered module' {
        # Arrange / Act: collect every module whose line immediately following
        # Set-StrictMode is not the guard. Trimming before the lookup prevents a
        # trailing space on either anchor from producing a false negative.
        $offender = @()
        foreach ($module in $script:DiscoveredModule) {
            $trimmed = @(@(Get-Content -LiteralPath $module.FullName) | ForEach-Object { $_.Trim() })
            $index = [array]::IndexOf($trimmed, $script:StrictModeLine)
            $isGuarded = ($index -ge 0) -and (($index + 1) -lt $trimmed.Count) -and ($trimmed[$index + 1] -ceq $script:GuardLine)
            if (-not $isGuarded) { $offender += $module.Name }
        }

        # Assert: an unguarded module leaves a failed load importable.
        $offender | Should -BeNullOrEmpty
    }

    It 'guards every load-time sibling import with an explicit stop preference' {
        # Arrange / Act: collect every column-0 Import-Module line that omits the
        # explicit stop preference. Column 0 selects load-time imports only, which
        # are the statements that run while the enclosing module is importing.
        $offender = @()
        foreach ($module in $script:DiscoveredModule) {
            foreach ($line in @(Get-Content -LiteralPath $module.FullName)) {
                $isLoadTimeImport = $line.StartsWith($script:ImportStatementPrefix)
                if ($isLoadTimeImport -and -not $line.Contains($script:ImportGuardToken)) {
                    $offender += "$($module.Name): $line"
                }
            }
        }

        # Assert: an unguarded sibling import fails non-terminating and lets the
        # enclosing module finish importing partially initialized.
        $offender | Should -BeNullOrEmpty
    }

    It 'states the fail-fast convention in the module help block' {
        # Arrange / Act: collect every module that does not carry the convention
        # token on a line preceding its Set-StrictMode line. That region is the
        # module's leading comment-based-help block.
        $offender = @()
        foreach ($module in $script:DiscoveredModule) {
            $line = @(Get-Content -LiteralPath $module.FullName)
            $trimmed = @($line | ForEach-Object { $_.Trim() })
            $index = [array]::IndexOf($trimmed, $script:StrictModeLine)
            $isStated = $false
            for ($position = 0; $position -lt $index; $position++) {
                if ($line[$position].Contains($script:ConventionToken)) { $isStated = $true }
            }
            if (-not $isStated) { $offender += $module.Name }
        }

        # Assert: the convention is stated in the modules themselves, not only in
        # the feature documents, because consumer repositories receive the modules.
        $offender | Should -BeNullOrEmpty
    }

    It 'leaves the caller error preference unchanged after import' {
        # Arrange: capture the caller-scope preference before the import. The
        # module is taken from the disk-discovered list, so no module is named.
        $before = $ErrorActionPreference
        $module = $script:DiscoveredModule[0]

        # Act: import a guarded module into the caller's session.
        Import-Module -Name $module.FullName -Force

        # Assert: a module-root preference governs that module's own scope and its
        # children, and does not alter the importing caller's preference.
        $ErrorActionPreference | Should -Be $before
    }

    It 'keeps every claude library module within the shared hard file-size limit' {
        # Arrange / Act: count physical lines per module. Measure-Object -Line
        # counts non-empty lines only and would under-report a module at the cap.
        $offender = @()
        foreach ($module in $script:DiscoveredModule) {
            $path = $module.FullName
            if (@(Get-Content -LiteralPath $path).Count -gt $script:MaximumModuleLine) {
                $offender += $module.Name
            }
        }

        # Assert: the tiered file-size policy blocks a production file above its
        # hard limit (800 lines); the 500 and 700 tiers are guidance only.
        $offender | Should -BeNullOrEmpty
    }
}
