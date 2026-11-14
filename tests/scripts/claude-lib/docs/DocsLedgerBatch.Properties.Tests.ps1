#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests of Invoke-DocsLedgerBatch in .claude/lib/docs/DocsLedgerBatch.psm1 (issue #1173 B2.2).

.DESCRIPTION
    Each seed builds a random sequence of order-sensitive items over three elements and the
    precision limit (dimension states that overwrite each other, disposition and binding changes,
    pins). Property 1: the batch output equals sequential single-operation application in input
    order, so the order within each partition is preserved. Property 2: interleaving the
    partitions differently, with the order inside each partition kept, gives byte-identical
    output. The seed is part of every failure message. No file is read or written except the
    committed schemas the loader composes.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsLedgerCommands', 'DocsLedgerBatch') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerBatch.TestSupport.psm1') -Force -ErrorAction Stop
    $script:Estate = New-DocsLedgerBatchTestEstate
    $script:Apply = Get-DocsLedgerBatchTestApply
    $script:NoError = { param($Documents, $After) [void] $Documents; [void] $After; @{ NewErrors = @() } }

    function New-TestRandomItem {
        # Returns a random list of order-sensitive argument maps with their partition key.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([System.Random] $Random, [int] $Count)
        $estate = $script:Estate
        $elements = @($estate.Ids[0], $estate.Ids[2], $estate.Ids[4])
        $list = [System.Collections.Generic.List[object]]::new()
        for ($index = 0; $index -lt $Count; $index++) {
            $choice = $Random.Next(6)
            if ($choice -eq 5) {
                $argument = [ordered]@{ Operation = 'set-disposition'; Limit = $estate.LimitId; Disposition = 'deferred'; Owner = 'docs-team'; Target = "Target $($Random.Next(3))" }
                $list.Add(@{ Key = 'limit'; Argument = $argument })
                continue
            }
            $element = $elements[$Random.Next($elements.Count)]
            $bound = if ($Random.Next(2) -eq 0) { [string[]] @($estate.Page) } else { [string[]] @($estate.Page, $estate.OtherPage) }
            $argument = switch ($choice) {
                0 { [ordered]@{ Operation = 'set-dimension'; Element = $element; Page = [string[]] @($estate.Page); Dimension = 'exists'; State = @('pass', 'fail', 'not-assessed')[$Random.Next(3)]; Rationale = 'r' } }
                1 { [ordered]@{ Operation = 'set-dimension'; Element = $element; Page = [string[]] @($estate.Page); Dimension = 'owner_assigned'; State = @('pass', 'fail')[$Random.Next(2)]; Rationale = 'r' } }
                2 { [ordered]@{ Operation = 'set-disposition'; Element = $element; Disposition = 'documented'; Page = $bound } }
                3 { [ordered]@{ Operation = 'pin'; Element = $element; Page = [string[]] @($estate.Page) } }
                default { [ordered]@{ Operation = 'set-disposition'; Element = $element; Disposition = 'excluded'; Rationale = 'Internal.' } }
            }
            $list.Add(@{ Key = $element; Argument = $argument })
        }
        return , $list.ToArray()
    }

    function ConvertTo-TestItem {
        # Numbers argument maps in their list order as batch items.
        param([object[]] $Entry)
        $items = [System.Collections.Generic.List[object]]::new()
        for ($index = 0; $index -lt $Entry.Count; $index++) { $items.Add((New-DocsLedgerBatchTestItem -Index $index -Argument $Entry[$index].Argument)) }
        return , $items.ToArray()
    }

    function Invoke-TestBatchText {
        param([object[]] $Item)
        $documents = Get-DocsLedgerBatchTestDocument -File $script:Estate.Files
        $result = Invoke-DocsLedgerBatch -Item $Item -LoadDocument { $documents }.GetNewClosure() -ApplyOperation $script:Apply -CompareRule $script:NoError -IssuedAt $script:Estate.IssuedAt
        ConvertTo-DocsLedgerBatchTestText -Result $result.After
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestRandomItem, Function:\ConvertTo-TestItem, Function:\Invoke-TestBatchText -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsLedgerBatch' {
    It 'property: preserves the order within a partition, equal to sequential application (seed <Seed>)' -ForEach @(
        @{ Seed = 117301 }
        @{ Seed = 117302 }
        @{ Seed = 117303 }
    ) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $items = ConvertTo-TestItem -Entry (New-TestRandomItem -Random $random -Count 14)
        $sequential = Invoke-DocsLedgerBatchTestSequential -Document (Get-DocsLedgerBatchTestDocument -File $script:Estate.Files) -Item $items -IssuedAt $script:Estate.IssuedAt

        # Act
        $batch = Invoke-TestBatchText -Item $items

        # Assert
        $sequential.Finding | Should -BeNullOrEmpty -Because "seed $Seed"
        $batch | Should -BeExactly (ConvertTo-DocsLedgerBatchTestText -Result $sequential) -Because "seed $Seed"
    }

    It 'property: an interleaving of the partitions that keeps each partition order gives the same bytes (seed <Seed>)' -ForEach @(
        @{ Seed = 117311 }
        @{ Seed = 117312 }
        @{ Seed = 117313 }
    ) {
        # Arrange (group by partition, then interleave the partitions in a random order)
        $random = [System.Random]::new($Seed)
        $entries = New-TestRandomItem -Random $random -Count 14
        $queues = [ordered]@{}
        foreach ($entry in $entries) {
            if (-not $queues.Contains($entry.Key)) { $queues[$entry.Key] = [System.Collections.Generic.Queue[object]]::new() }
            $queues[$entry.Key].Enqueue($entry)
        }
        $permuted = [System.Collections.Generic.List[object]]::new()
        while ($permuted.Count -lt $entries.Count) {
            $open = @($queues.Values | Where-Object { $_.Count -gt 0 })
            $permuted.Add($open[$random.Next($open.Count)].Dequeue())
        }

        # Act
        $original = Invoke-TestBatchText -Item (ConvertTo-TestItem -Entry $entries)
        $reordered = Invoke-TestBatchText -Item (ConvertTo-TestItem -Entry $permuted.ToArray())

        # Assert
        $reordered | Should -BeExactly $original -Because "seed $Seed"
    }
}
