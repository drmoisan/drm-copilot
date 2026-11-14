#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests of .claude/lib/docs/DocsReferenceSplit.psm1 (issue #1173 B5).

.DESCRIPTION
    Get-DocsReferenceSplitPage: for random element paths under random nested roots, every element
    appears in exactly one part in family order within its group, the part paths are ordinal and
    distinct, and a second call gives the same plan. Get-DocsReferenceStaleSplitFinding: the
    findings are exactly the existing split paths that are not planned, ordinal by path. The seed
    is part of every failure message. No file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReferenceSplit.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceSplitPage' {
    It 'property: every element is planned once, in family order within its group, on ordinal distinct paths (seed <Seed>)' -ForEach @(
        @{ Seed = 117321 }
        @{ Seed = 117322 }
        @{ Seed = 117323 }
    ) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $directories = @('src/a', 'src/b', 'src/b/c', 'lib/x', 'src', 'top')
        $elements = for ($index = 0; $index -lt 30; $index++) {
            $path = $directories[$random.Next($directories.Count)] + "/f$index.py"
            New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration ("S$index" + ('y' * $random.Next(0, 700))) -Path $path
        }
        $plan = [ordered]@{ Path = 'docs/reference/api-reference.md'; Title = 'API reference'; Element = [object[]] @($elements); Owner = 'o'; RootId = 'r'; Audience = [string[]] @('a'); Finding = [object[]] @() }
        $roots = @(@('src'), @('src', 'src/b'), @('lib', 'src'))[$random.Next(3)]

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot $roots -RenderedSize 999999 -Budget 16384
        $again = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot $roots -RenderedSize 999999 -Budget 16384

        # Assert
        [string[]] $paths = @($result.Part | ForEach-Object { [string] $_['Path'] })
        [string[]] $sorted = $paths.Clone()
        [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
        ($paths -join ',') | Should -BeExactly ($sorted -join ',') -Because "seed $Seed"
        @($paths | Sort-Object -Unique).Count | Should -Be $paths.Count -Because "seed $Seed"
        [string[]] $planned = @($result.Part | ForEach-Object { @($_['Element']) } | ForEach-Object { [string] $_['element_id'] })
        @($planned | Sort-Object) | Should -Be @($elements | ForEach-Object { [string] $_['element_id'] } | Sort-Object) -Because "seed $Seed"
        foreach ($part in $result.Part) {
            [int[]] $positions = @($part['Element'] | ForEach-Object { [array]::IndexOf(@($elements), $_) })
            ($positions -join ',') | Should -BeExactly (@($positions | Sort-Object) -join ',') -Because "seed $Seed keeps the family order in $($part['Path'])"
        }
        (ConvertTo-DocsCanonicalJson -Value @($result.Index, $result.Part)) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value @($again.Index, $again.Part)) -Because "seed $Seed"
    }
}

Describe 'Get-DocsReferenceStaleSplitFinding' {
    It 'property: warns exactly for the split paths that are not planned, ordinal by path (seed <Seed>)' -ForEach @(
        @{ Seed = 117331 }
        @{ Seed = 117332 }
        @{ Seed = 117333 }
    ) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $pool = @(0..15 | ForEach-Object { "docs/reference/cli-reference/g$_.md" })
        $split = @($pool | Where-Object { $random.Next(2) -eq 0 })
        $planned = @($pool | Where-Object { $random.Next(2) -eq 0 })

        # Act
        $findings = Get-DocsReferenceStaleSplitFinding -SplitPath $split -PlannedPath $planned

        # Assert
        [string[]] $expected = @($split | Where-Object { $planned -cnotcontains $_ })
        [Array]::Sort($expected, [System.StringComparer]::Ordinal)
        (@($findings | ForEach-Object { [string] $_['artifact_path'] }) -join ',') | Should -BeExactly ($expected -join ',') -Because "seed $Seed"
        @($findings | Where-Object { $_['code'] -cne 'REFERENCE_SPLIT_GROUP_STALE' -or $_['severity'] -cne 'warning' }).Count | Should -Be 0 -Because "seed $Seed"
    }
}
