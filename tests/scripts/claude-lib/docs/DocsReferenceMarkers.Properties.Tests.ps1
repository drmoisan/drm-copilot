#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests for DocsReferenceMarkers.psm1.

.DESCRIPTION
    One case per seed in 11, 23, 47, 101 and 211. Each case builds [System.Random]::new($Seed),
    draws bodies of author prose (with fenced marker-like lines) and generated blocks through
    DocsReference.TestSupport.psm1, asserts relations rather than drawn values, and passes
    -Because "seed $Seed". The Merge-DocsReferenceBlock cases are named for prose preservation,
    idempotence, removal reporting and edit replay. All inputs are in-memory string arrays.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceMarkers.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:PagePath = 'docs/reference/cli-reference.md'

    function Get-TestDrawnId {
        # Draws Count distinct element identifiers of drawn kinds.
        param([System.Random] $Random, [int] $Count)
        $ids = [System.Collections.Generic.List[string]]::new()
        $kinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')
        while ($ids.Count -lt $Count) {
            $id = [string] (New-DocsReferenceRandomElement -Random $Random -Kind $kinds[$Random.Next(0, $kinds.Count)])['element_id']
            if (-not $ids.Contains($id)) { $ids.Add($id) }
        }
        return , [string[]] $ids.ToArray()
    }

    function Get-TestDrawnBodyLine {
        # Draws one to three single-line block body lines.
        param([System.Random] $Random)
        $count = $Random.Next(1, 4)
        return , [string[]] @(for ($index = 0; $index -lt $count; $index++) { '- Item ' + (Get-DocsReferenceRandomText -Random $Random -ForIdentity) })
    }

    function Get-TestDrawnBody {
        # Draws a well-formed body of prose parts and blocks; returns @{ Line; Prose; Block }.
        param([System.Random] $Random, [string[]] $Id)
        $lines = [System.Collections.Generic.List[string]]::new()
        $prose = [System.Collections.Generic.List[string]]::new()
        $blocks = [System.Collections.Generic.List[object]]::new()
        $start = New-DocsReferenceRandomProse -Random $Random
        $lines.AddRange($start); $prose.AddRange($start)
        foreach ($blockId in $Id) {
            $inner = [string[]] (@('') + (Get-TestDrawnBodyLine -Random $Random) + @(''))
            $lines.Add('')
            $prose.Add('')
            $lines.Add((Get-DocsReferenceMarkerLine -ElementId $blockId -Position 'start'))
            $lines.AddRange($inner)
            $lines.Add((Get-DocsReferenceMarkerLine -ElementId $blockId -Position 'end'))
            $blocks.Add(@{ Id = $blockId; Inner = $inner })
            if ($Random.Next(0, 2) -eq 0) {
                $part = New-DocsReferenceRandomProse -Random $Random
                $lines.Add(''); $prose.Add('')
                $lines.AddRange($part); $prose.AddRange($part)
            }
        }
        $lines.Add('Closing paragraph.'); $prose.Add('Closing paragraph.')
        return @{ Line = [string[]] $lines.ToArray(); Prose = [string[]] $prose.ToArray(); Block = [object[]] $blocks.ToArray() }
    }

    function Get-TestDrawnMerge {
        # Draws a body and a desired list: a random subset of the existing blocks plus new ones, shuffled.
        param([System.Random] $Random, [switch] $SameSet)
        [string[]] $id = Get-TestDrawnId -Random $Random -Count ($Random.Next(0, 5) + 3)
        $existingCount = $Random.Next(0, $id.Count + 1)
        [string[]] $existing = @($id | Select-Object -First $existingCount)
        $body = Get-TestDrawnBody -Random $Random -Id $existing
        $desired = [System.Collections.Generic.List[object]]::new()
        foreach ($candidate in $id) {
            $isExisting = $existing -ccontains $candidate
            $keep = if ($SameSet) { $isExisting } else { $Random.Next(0, 3) -ne 0 }
            if ($keep) { $desired.Add(@{ ElementId = $candidate; Line = (Get-TestDrawnBodyLine -Random $Random) }) }
        }
        [object[]] $shuffled = Get-DocsReferenceShuffled -Random $Random -Item $desired.ToArray()
        return @{ Body = $body; Existing = $existing; Desired = $shuffled }
    }

    function Get-TestProseLine {
        # Returns the non-blank prose lines of a body, in order.
        param([string[]] $Line)
        $parsed = ConvertFrom-DocsReferenceBody -Line $Line -PagePath $script:PagePath
        return , [string[]] @($parsed.Segment | Where-Object { $_.Kind -ceq 'prose' } | ForEach-Object { $_.Line } | Where-Object { $_ -cnotmatch '\A[ \t]*\z' })
    }

    function Get-TestReplayed {
        # Applies edit records to Before, taking replaced regions from After; returns the rebuilt lines.
        param([string[]] $Before, [string[]] $After, [object[]] $Edit)
        $out = [System.Collections.Generic.List[string]]::new()
        $next = 0
        foreach ($record in $Edit) {
            while ($next -lt $record.BeforeStart) { $out.Add($Before[$next]); $next++ }
            if ($out.Count -ne $record.AfterStart) { throw "Edit AfterStart $($record.AfterStart) disagrees with the rebuilt position $($out.Count)." }
            for ($index = 0; $index -lt $record.AfterCount; $index++) { $out.Add($After[$record.AfterStart + $index]) }
            $next += $record.BeforeCount
        }
        while ($next -lt $Before.Count) { $out.Add($Before[$next]); $next++ }
        return , [string[]] $out.ToArray()
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceMarkerLine' {
    It 'round-trips every element kind and position through ConvertFrom-DocsReferenceMarkerLine (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        foreach ($kind in @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')) {
            $id = [string] (New-DocsReferenceRandomElement -Random $random -Kind $kind)['element_id']
            foreach ($position in @('start', 'end')) {
                # Act
                $marker = ConvertFrom-DocsReferenceMarkerLine -Line (Get-DocsReferenceMarkerLine -ElementId $id -Position $position)

                # Assert
                $marker.Malformed | Should -BeFalse -Because "seed $Seed"
                $marker.Position | Should -BeExactly $position -Because "seed $Seed"
                $marker.ElementId | Should -BeExactly $id -Because "seed $Seed"
            }
        }
    }
}

Describe 'ConvertFrom-DocsReferenceMarkerLine' {
    It 'parses drawn mutations of a marker line as malformed (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 30; $draw++) {
            $id = [string] (New-DocsReferenceRandomElement -Random $random)['element_id']
            $line = Get-DocsReferenceMarkerLine -ElementId $id -Position (@('start', 'end')[$random.Next(0, 2)])
            $mutated = switch ($random.Next(0, 4)) {
                0 { (' ' * $random.Next(1, 4)) + $line }
                1 { $line + ' ' + (Get-DocsReferenceRandomText -Random $random -ForIdentity) }
                2 { $line.Replace($id, $id.Substring(0, $id.Length - $random.Next(1, 10))) }
                default { $line.Replace($id, $id.ToUpperInvariant()) }
            }

            # Act
            $marker = ConvertFrom-DocsReferenceMarkerLine -Line $mutated

            # Assert
            $marker | Should -Not -BeNullOrEmpty -Because "seed $Seed"
            $marker.Malformed | Should -BeTrue -Because "seed $Seed"
        }
    }
}

Describe 'ConvertFrom-DocsReferenceBody' {
    It 'returns the drawn blocks in order and prose that reconstructs the drawn prose, never a block inside a fence (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            [string[]] $id = Get-TestDrawnId -Random $random -Count $random.Next(0, 5)
            $body = Get-TestDrawnBody -Random $random -Id $id

            # Act
            $result = ConvertFrom-DocsReferenceBody -Line $body.Line -PagePath $script:PagePath -LineOffset $random.Next(0, 9)

            # Assert
            $result.Finding.Count | Should -Be 0 -Because "seed $Seed"
            $blocks = @($result.Segment | Where-Object { $_.Kind -ceq 'block' })
            (@($blocks | ForEach-Object { $_.ElementId }) -join ',') | Should -BeExactly ($id -join ',') -Because "seed $Seed"
            for ($index = 0; $index -lt $blocks.Count; $index++) {
                ($blocks[$index].Line -join "`n") | Should -BeExactly ($body.Block[$index].Inner -join "`n") -Because "seed $Seed"
            }
            [string[]] $prose = @($result.Segment | Where-Object { $_.Kind -ceq 'prose' } | ForEach-Object { $_.Line })
            ($prose -join "`n") | Should -BeExactly ($body.Prose -join "`n") -Because "seed $Seed"
        }
    }
}

Describe 'Merge-DocsReferenceBlock' {
    It 'prose preservation: keeps every non-blank prose line in order, and every prose segment for an equal identifier set (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $case = Get-TestDrawnMerge -Random $random
            $same = Get-TestDrawnMerge -Random $random -SameSet

            # Act
            $merged = Merge-DocsReferenceBlock -Line $case.Body.Line -Desired $case.Desired -PagePath $script:PagePath
            $sameMerged = Merge-DocsReferenceBlock -Line $same.Body.Line -Desired $same.Desired -PagePath $script:PagePath

            # Assert
            ((Get-TestProseLine -Line $merged.Line) -join "`n") | Should -BeExactly ((Get-TestProseLine -Line $case.Body.Line) -join "`n") -Because "seed $Seed"
            $before = @((ConvertFrom-DocsReferenceBody -Line $same.Body.Line -PagePath $script:PagePath).Segment | Where-Object { $_.Kind -ceq 'prose' } | ForEach-Object { $_.Start.ToString() + ':' + ($_.Line -join "`n") })
            $afterSegments = @((ConvertFrom-DocsReferenceBody -Line $sameMerged.Line -PagePath $script:PagePath).Segment | Where-Object { $_.Kind -ceq 'prose' } | ForEach-Object { $_.Line -join "`n" })
            (@($before | ForEach-Object { $_.Substring($_.IndexOf(':') + 1) }) -join "`n--`n") | Should -BeExactly ($afterSegments -join "`n--`n") -Because "seed $Seed"
        }
    }

    It 'idempotence: merging the result again returns identical lines with every block unchanged (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $case = Get-TestDrawnMerge -Random $random

            # Act
            $first = Merge-DocsReferenceBlock -Line $case.Body.Line -Desired $case.Desired -PagePath $script:PagePath
            $second = Merge-DocsReferenceBlock -Line $first.Line -Desired $case.Desired -PagePath $script:PagePath

            # Assert
            ($second.Line -join "`n") | Should -BeExactly ($first.Line -join "`n") -Because "seed $Seed"
            [string[]] $desiredId = @($case.Desired | ForEach-Object { [string] $_.ElementId })
            [Array]::Sort($desiredId, [System.StringComparer]::Ordinal)
            ($second.Unchanged -join ',') | Should -BeExactly ($desiredId -join ',') -Because "seed $Seed"
            ($second.Added.Count + $second.Updated.Count + $second.Removed.Count + $second.Edit.Count + $second.Finding.Count) | Should -Be 0 -Because "seed $Seed"
        }
    }

    It 'removal reporting: reports one info REFERENCE_BLOCK_REMOVED per existing block that is not desired (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $case = Get-TestDrawnMerge -Random $random
            [string[]] $desiredId = @($case.Desired | ForEach-Object { [string] $_.ElementId })
            [string[]] $expected = @($case.Existing | Where-Object { $desiredId -cnotcontains $_ })
            [Array]::Sort($expected, [System.StringComparer]::Ordinal)

            # Act
            $merged = Merge-DocsReferenceBlock -Line $case.Body.Line -Desired $case.Desired -PagePath $script:PagePath

            # Assert
            ($merged.Removed -join ',') | Should -BeExactly ($expected -join ',') -Because "seed $Seed"
            $merged.Finding.Count | Should -Be $expected.Count -Because "seed $Seed"
            foreach ($finding in $merged.Finding) {
                $finding['code'] | Should -BeExactly 'REFERENCE_BLOCK_REMOVED' -Because "seed $Seed"
                $finding['severity'] | Should -BeExactly 'info' -Because "seed $Seed"
            }
            [string[]] $related = @($merged.Finding | ForEach-Object { $_['related_ids'] })
            [Array]::Sort($related, [System.StringComparer]::Ordinal)
            ($related -join ',') | Should -BeExactly ($expected -join ',') -Because "seed $Seed"
            [string[]] $remaining = @((ConvertFrom-DocsReferenceBody -Line $merged.Line -PagePath $script:PagePath).Segment | Where-Object { $_.Kind -ceq 'block' } | ForEach-Object { $_.ElementId })
            @($remaining | Where-Object { $expected -ccontains $_ }).Count | Should -Be 0 -Because "seed $Seed"
        }
    }

    It 'edit replay: applying the Edit records to the input reproduces the output (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 10; $draw++) {
            $case = Get-TestDrawnMerge -Random $random
            [string[]] $bodyLine = $case.Body.Line
            if ($random.Next(0, 2) -eq 0) { $bodyLine = [string[]] ($bodyLine + @('', '')) }

            # Act
            $merged = Merge-DocsReferenceBlock -Line $bodyLine -Desired $case.Desired -PagePath $script:PagePath

            # Assert
            $replayed = Get-TestReplayed -Before $bodyLine -After $merged.Line -Edit $merged.Edit
            ($replayed -join "`n") | Should -BeExactly ($merged.Line -join "`n") -Because "seed $Seed"
            foreach ($record in $merged.Edit) { ($record.BeforeCount + $record.AfterCount) | Should -BeGreaterThan 0 -Because "seed $Seed" }
        }
    }
}
