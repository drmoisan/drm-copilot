#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsLedgerMutation.psm1.

.DESCRIPTION
    Covers write-plan statuses, the dry run that invokes no scriptblock, create after TestFile,
    the digest-checked overwrite, conflicts that stop the sequence and list the written paths,
    a throwing WriteText, and ascending path order, all over the recording in-memory context of
    DocsLedger.TestSupport.psm1. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedgerMutation.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    function New-TestDocument {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Path, [string] $Text, [string] $BeforeText)
        $before = if ([string]::IsNullOrEmpty($BeforeText)) { $null } else { Get-DocsSha256Hex -Text $BeforeText }
        @{ Path = $Path; ArtifactKind = 'docs-coverage-ledger'; ArtifactId = 'docs-coverage-ledger-' + ('a' * 64); Text = $Text; BeforeSha256 = $before }
    }

    function Invoke-TestWrite {
        param([hashtable] $Test, [object[]] $Plan, [switch] $DryRun)
        Invoke-DocsArtifactWrite -Plan $Plan -ReadBytes $Test.Context.ReadBytes -TestFile $Test.Context.TestFile -WriteText $Test.Context.WriteText -DryRun:$DryRun
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsArtifactWritePlan' {
    It 'marks unchanged text skipped and changed text planned' {
        # Arrange
        $documents = @(
            (New-TestDocument -Path 'estate/b.json' -Text "{}`n" -BeforeText "{}`n")
            (New-TestDocument -Path 'estate/a.json' -Text "{}`n" -BeforeText "{ }`n")
            (New-TestDocument -Path 'estate/c.json' -Text "{}`n")
        )

        # Act
        $plans = Get-DocsArtifactWritePlan -Document $documents

        # Assert
        @($plans | ForEach-Object { $_['Path'] }) | Should -Be @('estate/a.json', 'estate/b.json', 'estate/c.json')
        @($plans | ForEach-Object { $_['Status'] }) | Should -Be @('planned', 'skipped', 'planned')
        $plans[0]['Sha256'] | Should -BeExactly (Get-DocsSha256Hex -Text "{}`n")
        $null -eq $plans[2]['BeforeSha256'] | Should -BeTrue
        $plans[1]['ArtifactKind'] | Should -BeExactly 'docs-coverage-ledger'
        $plans[1]['ArtifactId'] | Should -BeExactly ('docs-coverage-ledger-' + ('a' * 64))
        (Get-DocsArtifactWritePlan -Document @()).Count | Should -Be 0
        { Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path 'estate/a.json' -Text 'x'), (New-TestDocument -Path 'estate/a.json' -Text 'y')) } | Should -Throw -ExpectedMessage 'DOCS_MUTATION_INPUT_INVALID*'
        { Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path '/abs.json' -Text 'x')) } | Should -Throw -ExpectedMessage 'DOCS_MUTATION_INPUT_INVALID*'
    }
}

Describe 'Invoke-DocsArtifactWrite' {
    It 'dry run invokes none of ReadBytes, TestFile and WriteText' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/a.json' = "old`n" }
        $plans = Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path 'estate/a.json' -Text "new`n" -BeforeText "old`n"), (New-TestDocument -Path 'estate/b.json' -Text "{}`n"))

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans -DryRun

        # Assert
        $test.CallLog.Count | Should -Be 0
        $test.WriteLog.Count | Should -Be 0
        @($outcome.Write | ForEach-Object { $_['Status'] }) | Should -Be @('planned', 'planned')
        $null -eq $outcome.Failed | Should -BeTrue
        $outcome.WrittenPath.Count | Should -Be 0
        $plans[0]['Status'] | Should -BeExactly 'planned' -Because 'the input plans are not mutated'
    }

    It 'creates an absent document only after TestFile returns false' {
        # Arrange
        $test = New-DocsLedgerTestContext
        $plans = Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path 'estate/a.json' -Text "{}`n"))

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans

        # Assert
        @($test.CallLog | ForEach-Object { $_.Member + ' ' + $_.RelativePath }) | Should -Be @('TestFile estate/a.json', 'WriteText estate/a.json')
        $test.WriteLog[0].Mode | Should -BeExactly 'create'
        $test.WriteLog[0].Text | Should -BeExactly "{}`n"
        $outcome.Write[0]['Status'] | Should -BeExactly 'created'
        $outcome.WrittenPath | Should -Be @('estate/a.json')
        $null -eq $outcome.Failed | Should -BeTrue
    }

    It 'reports conflict when a document expected absent exists' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/a.json' = "surprise`n" }
        $plans = Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path 'estate/a.json' -Text "{}`n"))

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans

        # Assert
        $test.WriteLog.Count | Should -Be 0
        $outcome.Write[0]['Status'] | Should -BeExactly 'conflict'
        $outcome.Failed['Path'] | Should -BeExactly 'estate/a.json'
        $outcome.Failed['Status'] | Should -BeExactly 'conflict'
        $outcome.Failed['Message'].Contains('estate/a.json', [System.StringComparison]::Ordinal) | Should -BeTrue
        $outcome.WrittenPath.Count | Should -Be 0
    }

    It 'overwrites only when the re-read digest equals BeforeSha256' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/a.json' = "old`n" }
        $plans = Get-DocsArtifactWritePlan -Document @((New-TestDocument -Path 'estate/a.json' -Text "new`n" -BeforeText "old`n"))

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans

        # Assert
        @($test.CallLog | ForEach-Object { $_.Member }) | Should -Be @('ReadBytes', 'WriteText')
        $test.WriteLog[0].Mode | Should -BeExactly 'overwrite'
        $outcome.Write[0]['Status'] | Should -BeExactly 'updated'
        [System.Text.Encoding]::UTF8.GetString($test.Files['estate/a.json']) | Should -BeExactly "new`n"
    }

    It 'reports conflict on a digest mismatch, stops, and lists written paths' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/b.json' = "changed`n"; 'estate/c.json' = "c`n" }
        $plans = Get-DocsArtifactWritePlan -Document @(
            (New-TestDocument -Path 'estate/a.json' -Text "{}`n")
            (New-TestDocument -Path 'estate/b.json' -Text "new`n" -BeforeText "old`n")
            (New-TestDocument -Path 'estate/c.json' -Text "new`n" -BeforeText "c`n")
        )

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans

        # Assert
        @($outcome.Write | ForEach-Object { $_['Status'] }) | Should -Be @('created', 'conflict', 'planned')
        $outcome.Failed['Path'] | Should -BeExactly 'estate/b.json'
        $outcome.Failed['Status'] | Should -BeExactly 'conflict'
        $outcome.WrittenPath | Should -Be @('estate/a.json')
        @($test.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @('estate/a.json') -Because 'the sequence stops at the conflict and c.json is not written'
        [System.Text.Encoding]::UTF8.GetString($test.Files['estate/b.json']) | Should -BeExactly "changed`n" -Because 'the conflicting document is left as found'
    }

    It 'stops on a throwing WriteText and reports the failed path' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/a.json' = "old`n" } -WriteTextFailure @{ 'estate/b.json' = 'disk full' }
        $plans = Get-DocsArtifactWritePlan -Document @(
            (New-TestDocument -Path 'estate/a.json' -Text "new`n" -BeforeText "old`n")
            (New-TestDocument -Path 'estate/b.json' -Text "{}`n")
            (New-TestDocument -Path 'estate/c.json' -Text "{}`n")
        )

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $plans

        # Assert
        @($outcome.Write | ForEach-Object { $_['Status'] }) | Should -Be @('updated', 'planned', 'planned')
        $outcome.Failed['Path'] | Should -BeExactly 'estate/b.json'
        $outcome.Failed['Status'] | Should -BeExactly 'planned' -Because 'a write failure keeps the status unchanged'
        $outcome.Failed['Message'].Contains('disk full', [System.StringComparison]::Ordinal) | Should -BeTrue
        $outcome.WrittenPath | Should -Be @('estate/a.json')
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' } | ForEach-Object { $_.RelativePath }) | Should -Be @('estate/a.json', 'estate/b.json')
    }

    It 'writes in ordinal path order and never writes skipped plans' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/B.json' = "same`n"; 'estate/a.json' = "old`n" }
        $plans = Get-DocsArtifactWritePlan -Document @(
            (New-TestDocument -Path 'estate/a.json' -Text "new`n" -BeforeText "old`n")
            (New-TestDocument -Path 'estate/B.json' -Text "same`n" -BeforeText "same`n")
            (New-TestDocument -Path 'estate/Z.json' -Text "{}`n")
            (New-TestDocument -Path 'estate/c.json' -Text "{}`n")
        )
        $reversed = @($plans[3], $plans[2], $plans[1], $plans[0])

        # Act
        $outcome = Invoke-TestWrite -Test $test -Plan $reversed

        # Assert
        @($outcome.Write | ForEach-Object { $_['Path'] }) | Should -Be @('estate/B.json', 'estate/Z.json', 'estate/a.json', 'estate/c.json') -Because 'upper-case letters sort before lower-case ones ordinally'
        @($outcome.Write | ForEach-Object { $_['Status'] }) | Should -Be @('skipped', 'created', 'updated', 'created')
        $outcome.WrittenPath | Should -Be @('estate/Z.json', 'estate/a.json', 'estate/c.json')
        @($test.CallLog | Where-Object { $_.RelativePath -ceq 'estate/B.json' }).Count | Should -Be 0 -Because 'a skipped plan touches no scriptblock'
    }
}
