#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsReferenceSplit.psm1 (issue #1173 B5).

.DESCRIPTION
    Covers the unchanged page at or below the budget, the index plus group pages above it, the
    index links and inherited owner, root and audience, the longest of two nested roots, the
    _root group, ordinal parts for an oversize group, determinism, the per-page size estimate
    at or below the budget, and the stale split-page warning. Elements and plans are in memory;
    no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReferenceSplit.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReferenceRender.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    function New-TestFamilyPlan {
        # Returns an API family plan whose elements sit at the given paths with declarations of the given length.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Path, [int] $DeclarationLength = 20)
        $elements = for ($index = 0; $index -lt $Path.Count; $index++) {
            New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration ("Symbol$index" + ('x' * $DeclarationLength)) -Path $Path[$index]
        }
        [ordered]@{ Path = 'docs/reference/api-reference.md'; Title = 'API reference'; Element = [object[]] @($elements); Owner = 'docs-team'; RootId = 'docs-root'; Audience = [string[]] @('developers'); Finding = [object[]] @() }
    }

    function Get-TestPartSize {
        # Returns the estimated bytes of one part: the rendered blocks plus the surface_refs entries.
        param([System.Collections.IDictionary] $Part)
        $total = [long] 0
        foreach ($element in @($Part['Element'])) {
            [string[]] $line = Get-DocsReferenceBlockLine -Element $element
            $total += [System.Text.Encoding]::UTF8.GetByteCount(($line -join "`n") + "`n`n") + ([string] $element['element_id']).Length + 4
        }
        return $total
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestFamilyPlan, Function:\Get-TestPartSize -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceSplitPage' {
    It 'returns the family plan unchanged at or below the budget' {
        # Arrange
        $plan = New-TestFamilyPlan -Path @('src/a/x.py')

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 921600

        # Assert
        $result.Split | Should -BeFalse
        $result.Index | Should -BeNullOrEmpty
        [object]::ReferenceEquals($result.Part[0], $plan) | Should -BeTrue
    }

    It 'plans an index at the family path plus one page per group above the budget, with _root for paths beneath no directory' {
        # Arrange
        $plan = New-TestFamilyPlan -Path @('src/beta/x.py', 'src/alpha/y.py', 'src/z.py', 'other/w.py', 'src/alpha/deep/v.py')

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 921601

        # Assert
        $result.Split | Should -BeTrue
        @($result.Part | ForEach-Object { $_['Path'] }) | Should -Be @('docs/reference/api-reference/_root.md', 'docs/reference/api-reference/alpha.md', 'docs/reference/api-reference/beta.md')
        @($result.Part[1]['Element'] | ForEach-Object { $_['path'] }) | Should -Be @('src/alpha/y.py', 'src/alpha/deep/v.py') -Because 'elements keep the family order'
        @($result.Part[0]['Element'] | ForEach-Object { $_['path'] }) | Should -Be @('src/z.py', 'other/w.py')
        $result.Index['Path'] | Should -BeExactly 'docs/reference/api-reference.md'
        @($result.Index['Element']).Count | Should -Be 0
    }

    It 'links every group page from the index and carries the family owner, root and audience' {
        # Arrange
        $plan = New-TestFamilyPlan -Path @('src/beta/x.py', 'src/alpha/y.py')

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 2000000

        # Assert
        $result.Index['BodyLine'][0] | Should -BeExactly '# API reference'
        $result.Index['BodyLine'] | Should -Contain '- [alpha](api-reference/alpha.md)'
        $result.Index['BodyLine'] | Should -Contain '- [beta](api-reference/beta.md)'
        foreach ($page in @($result.Index) + @($result.Part)) {
            $page['Owner'] | Should -BeExactly 'docs-team'
            $page['RootId'] | Should -BeExactly 'docs-root'
            $page['Audience'] | Should -Be @('developers')
        }
        $result.Part[0]['Title'] | Should -BeExactly 'API reference: alpha'
    }

    It 'groups by the first segment beneath the longest of two nested roots' {
        # Arrange
        $plan = New-TestFamilyPlan -Path @('src/pkg/sub/x.py', 'src/pkg/y.py', 'src/other/z.py')

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src', 'src/pkg') -RenderedSize 921601

        # Assert
        @($result.Part | ForEach-Object { [System.IO.Path]::GetFileName([string] $_['Path']) }) | Should -Be @('_root.md', 'other.md', 'sub.md')
        @($result.Part[0]['Element'] | ForEach-Object { $_['path'] }) | Should -Be @('src/pkg/y.py')
    }

    It 'splits an oversize group into ordinal parts that keep the element order and stay at or below the budget' {
        # Arrange (a 16,384-byte budget leaves 8,192 bytes for the blocks of each part)
        $plan = New-TestFamilyPlan -Path @(1..12 | ForEach-Object { "src/big/m$_.py" }) -DeclarationLength 900

        # Act
        $result = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 999999 -Budget 16384

        # Assert
        $names = @($result.Part | ForEach-Object { [System.IO.Path]::GetFileName([string] $_['Path']) })
        $names.Count | Should -BeGreaterThan 1
        $names[0] | Should -BeExactly 'big-1.md'
        @($result.Part | ForEach-Object { @($_['Element']) } | ForEach-Object { $_['path'] }) | Should -Be @(1..12 | ForEach-Object { "src/big/m$_.py" })
        foreach ($part in $result.Part) { Get-TestPartSize -Part $part | Should -BeLessOrEqual (16384 - 8192) }
    }

    It 'is deterministic for the same plan' {
        # Arrange
        $plan = New-TestFamilyPlan -Path @('src/b/x.py', 'src/a/y.py', 'src/a/z.py')

        # Act
        $first = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 921601
        $second = Get-DocsReferenceSplitPage -PagePlan $plan -SourceRoot @('src') -RenderedSize 921601

        # Assert
        (ConvertTo-DocsCanonicalJson -Value @($first.Index, $first.Part)) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value @($second.Index, $second.Part))
    }
}

Describe 'Get-DocsReferenceStaleSplitFinding' {
    It 'warns for each existing split page that no group plans, ordinal by path, and for none that is planned' {
        # Act
        $findings = Get-DocsReferenceStaleSplitFinding -SplitPath @('docs/reference/api-reference/old.md', 'docs/reference/api-reference/alpha.md', 'docs/reference/api-reference/gone.md') -PlannedPath @('docs/reference/api-reference/alpha.md')

        # Assert
        @($findings | ForEach-Object { "$($_['code']) $($_['severity']) $($_['artifact_path'])" }) | Should -Be @('REFERENCE_SPLIT_GROUP_STALE warning docs/reference/api-reference/gone.md', 'REFERENCE_SPLIT_GROUP_STALE warning docs/reference/api-reference/old.md')
        $none = Get-DocsReferenceStaleSplitFinding -SplitPath @() -PlannedPath @('x.md')
        $none.Count | Should -Be 0
    }
}
