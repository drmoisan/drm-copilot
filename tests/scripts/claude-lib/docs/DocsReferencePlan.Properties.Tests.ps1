#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests for every exported function of DocsReferencePlan.psm1.

.DESCRIPTION
    One case per seed in 11, 23, 47, 101 and 211. Each case builds [System.Random]::new($Seed),
    draws a bounded number of inputs through DocsReference.TestSupport.psm1, asserts relations
    rather than drawn values, and passes -Because "seed $Seed". Inputs are in-memory strings and
    dictionaries; the only committed files read are the runtime schema files.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferencePlan.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ComposedSet = New-DocsReferenceComposedSchemaSet
    $script:FamilyFile = @('api-reference.md', 'cli-reference.md', 'config-reference.md', 'http-reference.md')
    $script:FamilyOfKind = @{
        'cli-command'   = 'cli-reference.md'
        'cli-option'    = 'cli-reference.md'
        'http-route'    = 'http-reference.md'
        'config-key'    = 'config-reference.md'
        'public-symbol' = 'api-reference.md'
    }

    function Get-TestUniqueElement {
        # Keeps the first element of each element_id.
        param([AllowEmptyCollection()] [object[]] $Element)
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        return , [object[]] @($Element | Where-Object { $seen.Add([string] $_['element_id']) })
    }

    function Get-TestSnapshotText {
        # Serializes a schema-valid snapshot holding the given element records.
        param([AllowEmptyCollection()] [object[]] $Element)
        return ConvertTo-DocsJsonText -Value ([ordered]@{
                '$schema'      = 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'
                schema_version = '1.0.0'
                artifact_kind  = 'surface-inventory-snapshot'
                id             = 'example-repo.snapshot'
                extensions     = [ordered]@{}
                repository     = 'example-repo'
                revision       = $null
                profile_sha256 = 'b' * 64
                analyzers      = [object[]]@([ordered]@{ id = 'test-analyzer'; version = '1'; analysis_method = 'scanner' })
                inputs         = [object[]]@()
                elements       = [object[]] $Element
                diagnostics    = [object[]]@()
                captured_at    = '2026-01-02T03:04:05Z'
            })
    }

    function Get-TestDrawnPath {
        # Draws a relative path of one to four segments over letters, digits, '-' and '.'.
        param([System.Random] $Random)
        $segment = @('docs', 'Ref', 'api', 'v2', 'a-b', 'x.y', 'Guide', 'm0')
        $count = $Random.Next(1, 5)
        return (@(1..$count | ForEach-Object { $segment[$Random.Next(0, $segment.Count)] }) -join '/')
    }

    function Get-TestDrawnElement {
        # Draws Count elements of the given kind (a drawn rendered kind when Kind is empty); Count may be zero.
        param([System.Random] $Random, [int] $Count, [string] $Kind = '', [string[]] $ParentId = @())
        $list = [System.Collections.Generic.List[object]]::new()
        for ($index = 0; $index -lt $Count; $index++) {
            $parent = if ($ParentId.Count -gt 0 -and $Random.Next(0, 4) -ne 0) { $ParentId[$Random.Next(0, $ParentId.Count)] } else { $null }
            $list.Add((New-DocsReferenceRandomElement -Random $Random -Kind $Kind -ParentId $parent))
        }
        return , [object[]] $list.ToArray()
    }

    function Get-TestOrdinalSorted {
        param([AllowEmptyCollection()] [string[]] $Item)
        $copy = [string[]]::new($Item.Count)
        [Array]::Copy($Item, $copy, $Item.Count)
        [Array]::Sort($copy, [System.StringComparer]::Ordinal)
        return , $copy
    }

    function Get-TestPlanSignature {
        # Joins page paths, element identifiers and finding codes of a plan into one string.
        param([hashtable] $Plan)
        $parts = foreach ($page in $Plan.Page) {
            $page.Path + '=' + (@($page.Element | ForEach-Object { [string] $_['element_id'] }) -join ',') + '|' + (@($page.Finding | ForEach-Object { [string] $_['code'] }) -join ',')
        }
        return (@($parts) -join "`n") + "`nunrendered=" + $Plan.Unrendered
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-DocsReferenceSnapshotText' {
    It 'parses drawn elements back to the same identifiers in ordinal order and reports a duplicated element (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 3; $draw++) {
            $element = Get-TestUniqueElement -Element (Get-TestDrawnElement -Random $random -Count $random.Next(1, 7))
            [string[]] $expected = Get-TestOrdinalSorted -Item @($element | ForEach-Object { [string] $_['element_id'] })
            $copy = [ordered]@{}
            $original = $element[$random.Next(0, $element.Count)]
            foreach ($key in $original.Keys) { $copy[$key] = $original[$key] }
            $copy['name'] = 'duplicate of ' + $original['name']
            $withDuplicate = [object[]] (Get-DocsReferenceShuffled -Random $random -Item (@($element) + @(, $copy)))

            # Act
            $parsed = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element $element) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet
            $duplicated = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element $withDuplicate) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

            # Assert
            $parsed.Finding.Count | Should -Be 0 -Because "seed $Seed"
            (@($parsed.Element | ForEach-Object { [string] $_['element_id'] }) -join ',') | Should -BeExactly ($expected -join ',') -Because "seed $Seed"
            @($duplicated.Finding | ForEach-Object { [string] $_['code'] }) | Should -Be @('REFERENCE_SNAPSHOT_INVALID') -Because "seed $Seed"
            $duplicated.Element.Count | Should -Be 0 -Because "seed $Seed"
        }
    }
}

Describe 'Test-DocsReferencePathCovered' {
    It 'agrees with the coverage oracle for prefixes, case flips, globs and siblings (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 40; $draw++) {
            $path = Get-TestDrawnPath -Random $random
            $segments = $path.Split('/')
            $flipAt = -1
            for ($at = 0; $at -lt $path.Length; $at++) { if ([char]::IsLetter($path[$at])) { $flipAt = $at; break } }
            $globSegments = @($segments | ForEach-Object { if ($random.Next(0, 3) -eq 0) { '*' } else { $_ } })
            $charAt = $random.Next(0, $path.Length)
            $questioned = if ($path[$charAt] -eq [char]'/') { $path } else { $path.Substring(0, $charAt) + '?' + $path.Substring($charAt + 1) }

            # Act and Assert
            Test-DocsReferencePathCovered -Path $path -Pattern $path | Should -BeTrue -Because "seed $Seed"
            for ($depth = 1; $depth -lt $segments.Count; $depth++) {
                $prefix = ($segments[0..($depth - 1)]) -join '/'
                Test-DocsReferencePathCovered -Path $path -Pattern $prefix | Should -BeTrue -Because "seed $Seed"
                Test-DocsReferencePathCovered -Path ($prefix + 'x/' + $segments[$depth]) -Pattern $prefix | Should -BeFalse -Because "seed $Seed"
            }
            if ($flipAt -ge 0) {
                $flipped = $path.Substring(0, $flipAt) + $(if ([char]::IsUpper($path[$flipAt])) { [char]::ToLowerInvariant($path[$flipAt]) } else { [char]::ToUpperInvariant($path[$flipAt]) }) + $path.Substring($flipAt + 1)
                Test-DocsReferencePathCovered -Path $flipped -Pattern $path | Should -BeFalse -Because "seed $Seed"
            }
            Test-DocsReferencePathCovered -Path $path -Pattern ($globSegments -join '/') | Should -BeTrue -Because "seed $Seed"
            Test-DocsReferencePathCovered -Path $path -Pattern $questioned | Should -BeTrue -Because "seed $Seed"
        }
    }
}

Describe 'Resolve-DocsReferenceOutputDirectory' {
    It 'returns an override unchanged, a directory exactly for one non-glob reference entry, invariant under permutation (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 20; $draw++) {
            $directory = Get-TestDrawnPath -Random $random
            $drawn = New-DocsReferenceRandomProfile -Random $random -OutputDirectory $directory
            $policy = $drawn['diataxis_policy']
            $modes = [System.Collections.Generic.List[object]]::new()
            foreach ($entry in $policy['directory_modes']) { if ($entry['mode'] -cne 'reference' -or $random.Next(0, 4) -ne 0) { $modes.Add($entry) } }
            $extraCount = $random.Next(0, 3)
            for ($extra = 0; $extra -lt $extraCount; $extra++) {
                $glob = if ($random.Next(0, 2) -eq 0) { (Get-TestDrawnPath -Random $random) + '/*' } else { Get-TestDrawnPath -Random $random }
                $modes.Insert($random.Next(0, $modes.Count + 1), [ordered]@{ path_or_glob = $glob; mode = 'reference' })
            }
            $policy['directory_modes'] = [object[]] $modes.ToArray()
            $hasReferenceMode = $random.Next(0, 5) -ne 0
            if (-not $hasReferenceMode) { $policy['modes'] = [string[]] @($policy['modes'] | Where-Object { $_ -cne 'reference' }) }
            [string[]] $plain = @($modes | Where-Object { $_['mode'] -ceq 'reference' -and ([string] $_['path_or_glob']).IndexOfAny([char[]]@('*', '?', '[')) -lt 0 } | ForEach-Object { [string] $_['path_or_glob'] })
            $override = Get-TestDrawnPath -Random $random

            # Act
            $withOverride = Resolve-DocsReferenceOutputDirectory -Profile $drawn -ProfilePath 'docs/profile.json' -OutputDirectory $override
            $resolved = Resolve-DocsReferenceOutputDirectory -Profile $drawn -ProfilePath 'docs/profile.json'
            $reference = @($modes | Where-Object { $_['mode'] -ceq 'reference' })
            $other = Get-DocsReferenceShuffled -Random $random -Item @($modes | Where-Object { $_['mode'] -cne 'reference' })
            $policy['directory_modes'] = [object[]] (@($reference) + @($other))
            $permuted = Resolve-DocsReferenceOutputDirectory -Profile $drawn -ProfilePath 'docs/profile.json'

            # Assert
            foreach ($finding in (@($withOverride.Finding) + @($resolved.Finding) + @($permuted.Finding))) {
                @('REFERENCE_OUTPUT_DIR_UNRESOLVED', 'REFERENCE_MODE_CONFLICT') -ccontains [string] $finding['code'] | Should -BeTrue -Because "seed $Seed"
            }
            if (-not $hasReferenceMode) {
                $withOverride.OutputDirectory | Should -BeNullOrEmpty -Because "seed $Seed"
                $resolved.Finding[0]['code'] | Should -BeExactly 'REFERENCE_MODE_CONFLICT' -Because "seed $Seed"
                continue
            }
            $withOverride.OutputDirectory | Should -BeExactly $override -Because "seed $Seed"
            $withOverride.Finding.Count | Should -Be 0 -Because "seed $Seed"
            if ($plain.Count -eq 1) {
                $resolved.OutputDirectory | Should -BeExactly $plain[0] -Because "seed $Seed"
                $resolved.Finding.Count | Should -Be 0 -Because "seed $Seed"
            } else {
                $resolved.OutputDirectory | Should -BeNullOrEmpty -Because "seed $Seed"
                $resolved.Finding[0]['code'] | Should -BeExactly 'REFERENCE_OUTPUT_DIR_UNRESOLVED' -Because "seed $Seed"
            }
            [string] $permuted.OutputDirectory | Should -BeExactly ([string] $resolved.OutputDirectory) -Because "seed $Seed"
            $permuted.Finding.Count | Should -Be $resolved.Finding.Count -Because "seed $Seed"
        }
    }
}

Describe 'Get-DocsReferenceCandidatePagePath' {
    It 'returns the four family pages under any valid directory, ordinal-sorted and stable (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 40; $draw++) {
            $directory = Get-TestDrawnPath -Random $random
            Test-DocsRelativePath -Path $directory | Should -BeTrue -Because "seed $Seed"

            # Act
            $first = Get-DocsReferenceCandidatePagePath -OutputDirectory $directory
            $second = Get-DocsReferenceCandidatePagePath -OutputDirectory $directory

            # Assert
            $first.Count | Should -Be 4 -Because "seed $Seed"
            foreach ($path in $first) {
                $path.StartsWith($directory + '/', [System.StringComparison]::Ordinal) | Should -BeTrue -Because "seed $Seed"
                Test-DocsRelativePath -Path $path | Should -BeTrue -Because "seed $Seed"
            }
            [string[]] $leaves = @($first | ForEach-Object { $_.Substring($directory.Length + 1) })
            ((Get-TestOrdinalSorted -Item $leaves) -join ',') | Should -BeExactly ($script:FamilyFile -join ',') -Because "seed $Seed"
            ($first -join ',') | Should -BeExactly ((Get-TestOrdinalSorted -Item $first) -join ',') -Because "seed $Seed"
            ($second -join ',') | Should -BeExactly ($first -join ',') -Because "seed $Seed"
        }
    }

    It 'adds exactly the listed one-level split pages of the family stems, ordinal and duplicate-free (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }) {
        # Arrange (issue #1173 B5: split directories are now listed)
        $random = [System.Random]::new($Seed)
        $stems = @('api-reference', 'cli-reference', 'config-reference', 'http-reference', 'other')
        $listed = [System.Collections.Generic.List[string]]::new()
        for ($draw = 0; $draw -lt 30; $draw++) {
            $stem = $stems[$random.Next($stems.Count)]
            $leaf = @("g$($random.Next(5)).md", "g$($random.Next(5)).txt", "d/g$($random.Next(5)).md")[$random.Next(3)]
            $listed.Add("docs/reference/$stem/$leaf")
        }
        [string[]] $expectedSplit = @($listed | Where-Object { $_ -cmatch '^docs/reference/(?:api|cli|config|http)-reference/[^/]+\.md$' } | Select-Object -Unique)

        # Act
        $paths = Get-DocsReferenceCandidatePagePath -OutputDirectory 'docs/reference' -ListedPath $listed.ToArray()

        # Assert
        # The candidate function returns with the unary comma; the assignment unwraps it.
        [string[]] $family = Get-DocsReferenceCandidatePagePath -OutputDirectory 'docs/reference'
        [string[]] $expected = @($family) + @($expectedSplit)
        ($paths -join ',') | Should -BeExactly ((Get-TestOrdinalSorted -Item $expected) -join ',') -Because "seed $Seed"
    }
}

Describe 'Get-DocsReferencePagePlan' {
    It 'places each rendered element on exactly one page, options after their parent, invariant under permutation (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 15; $draw++) {
            $drawnProfile = New-DocsReferenceRandomProfile -Random $random
            $items = [System.Collections.Generic.List[object]]::new()
            [object[]] $commands = Get-TestDrawnElement -Random $random -Count $random.Next(0, 4) -Kind 'cli-command'
            $items.AddRange($commands)
            [string[]] $commandId = @($commands | ForEach-Object { [string] $_['element_id'] })
            $items.AddRange([object[]] (Get-TestDrawnElement -Random $random -Count $random.Next(0, 5) -Kind 'cli-option' -ParentId $commandId))
            $otherCount = $random.Next(0, 6)
            for ($other = 0; $other -lt $otherCount; $other++) {
                $items.Add((New-DocsReferenceRandomElement -Random $random -Kind (@('http-route', 'config-key', 'public-symbol', 'architecture-component')[$random.Next(0, 4)])))
            }
            $element = Get-TestUniqueElement -Element $items.ToArray()
            $candidate = Get-DocsReferenceCandidatePagePath -OutputDirectory 'docs/reference'
            [string[]] $existingPath = @($candidate | Where-Object { $random.Next(0, 3) -eq 0 })
            $architecture = @($element | Where-Object { $_['kind'] -ceq 'architecture-component' }).Count
            $expectedPage = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
            foreach ($item in $element) { if ($script:FamilyOfKind.ContainsKey([string] $item['kind'])) { [void]$expectedPage.Add('docs/reference/' + $script:FamilyOfKind[[string] $item['kind']]) } }
            foreach ($path in $existingPath) { [void]$expectedPage.Add($path) }

            # Act
            $plan = Get-DocsReferencePagePlan -Profile $drawnProfile -Element $element -OutputDirectory 'docs/reference' -ExistingPagePath $existingPath -ProfilePath 'docs/profile.json'
            $permuted = Get-DocsReferencePagePlan -Profile $drawnProfile -Element (Get-DocsReferenceShuffled -Random $random -Item $element) -OutputDirectory 'docs/reference' -ExistingPagePath $existingPath -ProfilePath 'docs/profile.json'

            # Assert
            $plan.Unrendered | Should -Be $architecture -Because "seed $Seed"
            (@($plan.Page | ForEach-Object { $_.Path }) -join ',') | Should -BeExactly (@($expectedPage) -join ',') -Because "seed $Seed"
            foreach ($item in $element) {
                $id = [string] $item['element_id']
                $hosts = @($plan.Page | Where-Object { @($_.Element | ForEach-Object { [string] $_['element_id'] }) -ccontains $id })
                $expectedCount = if ($item['kind'] -ceq 'architecture-component') { 0 } else { 1 }
                $hosts.Count | Should -Be $expectedCount -Because "seed $Seed"
            }
            $cli = @($plan.Page | Where-Object { $_.Path -ceq 'docs/reference/cli-reference.md' })
            if ($cli.Count -eq 1) {
                [object[]] $order = $cli[0].Element
                for ($at = 0; $at -lt $order.Count; $at++) {
                    if ($order[$at]['kind'] -cne 'cli-option') { continue }
                    $parentAt = -1
                    for ($back = $at - 1; $back -ge 0; $back--) { if ($order[$back]['kind'] -ceq 'cli-command') { $parentAt = $back; break } }
                    $parentPresent = @($commands | Where-Object { [string] $_['element_id'] -ceq [string] $order[$at]['parent_id'] }).Count -gt 0
                    if ($parentPresent) { [string] $order[$parentAt]['element_id'] | Should -BeExactly ([string] $order[$at]['parent_id']) -Because "seed $Seed" }
                }
            }
            (Get-TestPlanSignature -Plan $permuted) | Should -BeExactly (Get-TestPlanSignature -Plan $plan) -Because "seed $Seed"
        }
    }
}
