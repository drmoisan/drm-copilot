#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests for Get-DocsReferenceGeneration (DocsReferenceWriter.psm1) and for
    Format-DocsReferenceDiff, ConvertTo-DocsReferenceResult and Get-DocsReferenceReportLine
    (DocsReferenceReport.psm1, the file-size contingency), plus the generated-page layout property.

.DESCRIPTION
    One case per seed in 11, 23, 47, 101 and 211. Each case builds [System.Random]::new($Seed),
    draws profiles, elements, prose, line edits and page records through
    DocsReference.TestSupport.psm1 or local generators over that Random, asserts relations rather
    than drawn values, and passes -Because "seed $Seed". Get-DocsReferenceGeneration receives
    COMPOSED-SET from New-DocsReferenceComposedSchemaSet. Every input is in memory.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceWriter.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceReport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ComposedSet = New-DocsReferenceComposedSchemaSet
    $script:OutputDirectory = 'docs/reference'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Family = [ordered]@{ 'api-reference.md' = 'API reference'; 'cli-reference.md' = 'CLI reference'; 'config-reference.md' = 'Configuration reference'; 'http-reference.md' = 'HTTP reference' }
    $script:MarkerPattern = '\A<!-- docs:generated:(?:start|end) id=[^ ]+ -->\z'

    function Get-TestDrawnElement {
        # Draws one to eight rendered elements, options of drawn commands and possibly components.
        param([System.Random] $Random)
        $byId = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
        $commands = [System.Collections.Generic.List[object]]::new()
        $count = $Random.Next(1, 9)
        for ($index = 0; $index -lt $count; $index++) {
            $element = New-DocsReferenceRandomElement -Random $Random
            if ([string] $element['kind'] -ceq 'cli-command') { $commands.Add($element) }
            $byId[[string] $element['element_id']] = $element
        }
        foreach ($command in $commands) {
            if ($Random.Next(0, 2) -eq 1) {
                $option = New-DocsReferenceRandomElement -Random $Random -Kind 'cli-option' -ParentId ([string] $command['element_id'])
                $byId[[string] $option['element_id']] = $option
            }
        }
        if ($Random.Next(0, 2) -eq 1) {
            $component = New-DocsReferenceRandomElement -Random $Random -Kind 'architecture-component'
            $byId[[string] $component['element_id']] = $component
        }
        return , [object[]] @($byId.Values)
    }

    function Get-TestExistingPage {
        # Returns an ordinal map of every family path to $null or a drawn prose page (WithProse).
        param([System.Random] $Random, [switch] $WithProse)
        $existing = [ordered]@{}
        foreach ($name in $script:Family.Keys) {
            $path = "$($script:OutputDirectory)/$name"
            $existing[$path] = $null
            if ($WithProse -and $Random.Next(0, 2) -eq 1) {
                $text = "# $($script:Family[$name])`n`n" + ((New-DocsReferenceRandomProse -Random $Random) -join "`n") + "`n"
                $existing[$path] = @{ Text = $text; Sha256 = (Get-DocsSha256Hex -Text $text) }
            }
        }
        return $existing
    }

    function Invoke-TestGeneration {
        # Calls Get-DocsReferenceGeneration with COMPOSED-SET over drawn inputs.
        param([System.Collections.IDictionary] $DocsProfile, [object[]] $Element, [System.Collections.IDictionary] $ExistingPage)
        return Get-DocsReferenceGeneration -Profile $DocsProfile -Snapshot ([ordered]@{ repository = 'example-repo'; captured_at = '2026-03-04T05:06:07Z' }) -Element $Element -ExistingPage $ExistingPage -OutputDirectory $script:OutputDirectory -ProfilePath $script:ProfilePath -ComposedSchemaSet $script:ComposedSet
    }

    function Get-TestPageImage {
        # Returns path, action and text of every page, for byte-identity comparison.
        param([System.Collections.IDictionary] $Generation)
        return [string[]] @($Generation.Page | ForEach-Object { "$($_['Path'])|$($_['Action'])|$($_['Text'])" })
    }

    function Get-TestDrawnEdit {
        # Draws before lines, then keeps, deletes, inserts or replaces runs to build after lines and edits.
        param([System.Random] $Random)
        $before = [string[]] @(1..$Random.Next(0, 25) | Where-Object { $_ -gt 0 } | ForEach-Object { "line $_ " + @('a', '', ' b', '-x', '+y', '@@ z')[$Random.Next(0, 6)] })
        $after = [System.Collections.Generic.List[string]]::new()
        $edits = [System.Collections.Generic.List[object]]::new()
        $at = 0
        while ($at -le $before.Count) {
            $choice = $Random.Next(0, 6)
            $removeCount = if ($choice -eq 1 -or $choice -eq 3) { [math]::Min($Random.Next(1, 4), $before.Count - $at) } else { 0 }
            $insertCount = if ($choice -eq 2 -or $choice -eq 3) { $Random.Next(1, 4) } else { 0 }
            if ($removeCount + $insertCount -gt 0) {
                $edits.Add([ordered]@{ BeforeStart = $at; BeforeCount = $removeCount; AfterStart = $after.Count; AfterCount = $insertCount })
                for ($k = 0; $k -lt $insertCount; $k++) { $after.Add("new $at.$k") }
                $at += $removeCount
            }
            if ($at -lt $before.Count) { $after.Add($before[$at]) }
            $at++
        }
        return @{ Before = $before; After = [string[]] $after.ToArray(); Edit = [object[]] $edits.ToArray() }
    }

    function Get-TestDrawnGeneration {
        # Draws one to four page records with distinct paths in the Get-DocsReferenceGeneration shape.
        param([System.Random] $Random)
        $pool = Get-DocsReferenceShuffled -Random $Random -Item @('docs/a.md', 'docs/B.md', 'docs/b.md', 'docs/a/z.md', 'docs/ab.md', 'docs/_x.md')
        $pages = [System.Collections.Generic.List[object]]::new()
        for ($index = 0; $index -lt $Random.Next(1, 5); $index++) {
            $action = @('create', 'update', 'none', 'blocked')[$Random.Next(0, 4)]
            $list = { if ($action -ceq 'blocked') { [string[]]@() } else { [string[]] @(1..$Random.Next(1, 4) | ForEach-Object { "id-$($Random.Next(0, 99))" } | Select-Object -Unique) } }
            $diff = if ($action -ceq 'create' -or $action -ceq 'update') { "--- a/p`n+++ b/p`n@@ -1,1 +1,1 @@`n-x`n+y`n" } else { $null }
            $pages.Add([ordered]@{
                    Path = [string] $pool[$index]; Action = $action; Added = (& $list); Updated = (& $list); Unchanged = (& $list); Removed = (& $list)
                    Text = 'text'; Sha256Before = $(if ($action -ceq 'create') { $null } else { 'b' * 64 }); Sha256After = $(if ($action -ceq 'blocked') { $null } else { 'a' * 64 }); Diff = $diff
                })
        }
        return @{ Page = [object[]] $pages.ToArray(); Unrendered = $Random.Next(0, 5) }
    }

    function Get-TestKeySet {
        # Returns the ordinal-sorted keys of a dictionary, unrolled so that Should compares items.
        param([System.Collections.IDictionary] $Value)
        [string[]] $keys = @($Value.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        return $keys
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceGeneration' {
    It 'is byte-identical across two runs and a shuffled element order, and regeneration gives none (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $docsProfile = New-DocsReferenceRandomProfile -Random $random
        $element = Get-TestDrawnElement -Random $random
        $existing = Get-TestExistingPage -Random $random -WithProse

        # Act
        $first = Invoke-TestGeneration -DocsProfile $docsProfile -Element $element -ExistingPage $existing
        $second = Invoke-TestGeneration -DocsProfile $docsProfile -Element $element -ExistingPage $existing
        $shuffled = Invoke-TestGeneration -DocsProfile $docsProfile -Element (Get-DocsReferenceShuffled -Random $random -Item $element) -ExistingPage $existing
        $regenerated = [ordered]@{}
        foreach ($key in $existing.Keys) { $regenerated[$key] = $existing[$key] }
        foreach ($page in $first.Page) { $regenerated[$page['Path']] = @{ Text = $page['Text']; Sha256 = (Get-DocsSha256Hex -Text $page['Text']) } }
        $third = Invoke-TestGeneration -DocsProfile $docsProfile -Element $element -ExistingPage $regenerated

        # Assert
        @($first.Finding | Where-Object { $_['severity'] -ceq 'error' }).Count | Should -Be 0 -Because "seed $Seed"
        $first.Page.Count | Should -BeGreaterThan 0 -Because "seed $Seed"
        Get-TestPageImage -Generation $second | Should -Be (Get-TestPageImage -Generation $first) -Because "seed $Seed"
        Get-TestPageImage -Generation $shuffled | Should -Be (Get-TestPageImage -Generation $first) -Because "seed $Seed"
        @($third.Page | ForEach-Object { $_['Action'] }) | Should -Be @($third.Page | ForEach-Object { 'none' }) -Because "seed $Seed"
        @($third.Page | ForEach-Object { $_['Text'] }) | Should -Be @($first.Page | ForEach-Object { $_['Text'] }) -Because "seed $Seed"
    }
}

Describe 'Format-DocsReferenceDiff' {
    It 'is reconstructed by the test-local hunk applier, and an empty edit list gives an empty text (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 25; $draw++) {
            $drawn = Get-TestDrawnEdit -Random $random
            $isNew = $drawn.Before.Count -eq 0

            # Act
            $diff = Format-DocsReferenceDiff -PagePath 'docs/reference/x.md' -BeforeLine $drawn.Before -AfterLine $drawn.After -Edit $drawn.Edit -IsNewPage:$isNew
            $patched = Get-DocsReferencePatchedLine -BeforeLine $drawn.Before -DiffText $diff
            $empty = Format-DocsReferenceDiff -PagePath 'docs/reference/x.md' -BeforeLine $drawn.Before -AfterLine $drawn.Before -Edit @()

            # Assert
            @($patched) | Should -Be @($drawn.After) -Because "seed $Seed draw $draw"
            $empty | Should -BeExactly '' -Because "seed $Seed draw $draw"
            if ($drawn.Edit.Count -gt 0) {
                $header = if ($isNew) { "--- /dev/null`n" } else { "--- a/docs/reference/x.md`n" }
                $diff.StartsWith($header + "+++ b/docs/reference/x.md`n", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "seed $Seed draw $draw"
                $diff.EndsWith("`n") | Should -BeTrue -Because "seed $Seed draw $draw"
            }
        }
    }
}

Describe 'ConvertTo-DocsReferenceResult' {
    It 'derives the summary from pages, has the fixed key sets, and is invariant under page permutation (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $generation = Get-TestDrawnGeneration -Random $random
            $mode = @('dry-run', 'write')[$random.Next(0, 2)]
            $status = [ordered]@{}
            foreach ($page in $generation.Page) { if ($random.Next(0, 2) -eq 1) { $status[$page['Path']] = @('created', 'updated', 'skipped', 'conflict')[$random.Next(0, 4)] } }
            $permuted = @{ Page = (Get-DocsReferenceShuffled -Random $random -Item $generation.Page); Unrendered = $generation.Unrendered }

            # Act
            $result = ConvertTo-DocsReferenceResult -Generation $generation -Mode $mode -WriteStatus $status -OutputDirectory 'docs'
            $again = ConvertTo-DocsReferenceResult -Generation $permuted -Mode $mode -WriteStatus $status -OutputDirectory 'docs'
            $pages = @($result['pages'])
            $summary = $result['summary']

            # Assert
            Get-TestKeySet -Value $result | Should -Be @('mode', 'output_directory', 'pages', 'summary', 'unrendered') -Because "seed $Seed draw $draw"
            Get-TestKeySet -Value $summary | Should -Be @('blocks_added', 'blocks_removed', 'blocks_unchanged', 'blocks_updated', 'page_count', 'pages_blocked', 'pages_changed', 'pages_unchanged') -Because "seed $Seed draw $draw"
            foreach ($page in $pages) {
                Get-TestKeySet -Value $page | Should -Be @('action', 'blocks', 'diff', 'path', 'sha256_after', 'sha256_before', 'status') -Because "seed $Seed draw $draw"
                Get-TestKeySet -Value $page['blocks'] | Should -Be @('added', 'removed', 'unchanged', 'updated') -Because "seed $Seed draw $draw"
            }
            foreach ($name in @('added', 'removed', 'unchanged', 'updated')) {
                $summary["blocks_$name"] | Should -Be ((@($pages | ForEach-Object { @($_['blocks'][$name]).Count }) | Measure-Object -Sum).Sum) -Because "seed $Seed draw $draw"
            }
            $summary['page_count'] | Should -Be $pages.Count -Because "seed $Seed draw $draw"
            $summary['pages_blocked'] | Should -Be @($pages | Where-Object { $_['action'] -ceq 'blocked' }).Count -Because "seed $Seed draw $draw"
            $summary['pages_changed'] | Should -Be @($pages | Where-Object { $_['action'] -ceq 'create' -or $_['action'] -ceq 'update' }).Count -Because "seed $Seed draw $draw"
            $summary['pages_unchanged'] | Should -Be @($pages | Where-Object { $_['action'] -ceq 'none' }).Count -Because "seed $Seed draw $draw"
            (ConvertTo-DocsCanonicalJson -Value $again) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $result) -Because "seed $Seed draw $draw"
        }
    }
}

Describe 'Get-DocsReferenceReportLine' {
    It 'lists pages in ordinal path order for every permutation, with single lines, one note per create page and equal repeat calls (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $generation = Get-TestDrawnGeneration -Random $random
            $result = ConvertTo-DocsReferenceResult -Generation $generation -Mode (@('dry-run', 'write')[$random.Next(0, 2)])
            [string[]] $paths = @($result['pages'] | ForEach-Object { [string] $_['path'] })
            [Array]::Sort($paths, [System.StringComparer]::Ordinal)
            $createCount = @($result['pages'] | Where-Object { $_['action'] -ceq 'create' }).Count

            for ($permutation = 0; $permutation -lt 6; $permutation++) {
                $permuted = [ordered]@{}
                foreach ($key in $result.Keys) { $permuted[$key] = $result[$key] }
                $permuted['pages'] = Get-DocsReferenceShuffled -Random $random -Item @($result['pages'])

                # Act
                [string[]] $lines = Get-DocsReferenceReportLine -Result $permuted
                [string[]] $repeat = Get-DocsReferenceReportLine -Result $permuted

                # Assert
                @($lines | Select-Object -First $paths.Count | ForEach-Object { $_.Split(' ')[1] }) | Should -Be $paths -Because "seed $Seed draw $draw"
                @($lines | Where-Object { $_.Contains("`r") -or $_.Contains("`n") }).Count | Should -Be 0 -Because "seed $Seed draw $draw"
                @($lines | Where-Object { $_.StartsWith('note: ', [System.StringComparison]::Ordinal) }).Count | Should -Be $createCount -Because "seed $Seed draw $draw"
                $repeat | Should -Be $lines -Because "seed $Seed draw $draw"
            }
        }
    }
}

Describe 'generated page layout' {
    It 'writes standalone markers with blank-line separation, no instructional heading and no other line starting with an angle bracket (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $docsProfile = New-DocsReferenceRandomProfile -Random $random
        $element = Get-TestDrawnElement -Random $random

        # Act
        $generation = Invoke-TestGeneration -DocsProfile $docsProfile -Element $element -ExistingPage (Get-TestExistingPage -Random $random)

        # Assert
        foreach ($page in $generation.Page) {
            [string[]] $lines = $page['Text'].Substring(0, $page['Text'].Length - 1).Split("`n")
            $because = "seed $Seed page $($page['Path'])"
            for ($index = 0; $index -lt $lines.Count; $index++) {
                $line = $lines[$index]
                $line.EndsWith(' ') | Should -BeFalse -Because $because
                if ($line -cmatch $script:MarkerPattern) {
                    $lines[$index - 1] | Should -BeExactly '' -Because "$because line $($index + 1) is preceded by a blank line"
                    if ($index + 1 -lt $lines.Count) { $lines[$index + 1] | Should -BeExactly '' -Because "$because line $($index + 1) is followed by a blank line" }
                    continue
                }
                $line.StartsWith('<') | Should -BeFalse -Because "$because line $($index + 1)"
                $heading = [regex]::Match($line, '\A#{1,6} (?<text>.*)\z')
                if ($heading.Success) {
                    $heading.Groups['text'].Value | Should -Not -Match '(?i)^how to ' -Because $because
                    $heading.Groups['text'].Value | Should -Not -Match '(?i)^step\s+[0-9]+\b' -Because $because
                }
            }
        }
    }
}
