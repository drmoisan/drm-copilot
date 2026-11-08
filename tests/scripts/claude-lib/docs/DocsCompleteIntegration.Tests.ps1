#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Integration tests of the docs-complete validation over one recording in-memory context.

.DESCRIPTION
    The fixture profile sets allow_deferred false and max_stale_pages 0; the snapshot is pinned
    to a full revision and carries no precision-limit diagnostic. Over the complete estate,
    validate -Mode docs-complete exits 0 with a pass receipt; with one element without a ledger
    entry and one pin whose digest differs it exits 1 with a fail receipt naming the element
    (declaration and element id) and the stale page; after update-ledger set-disposition -Write
    and pin -Write through the same context it exits 0 with a pass receipt. Every command runs
    through Invoke-DocsCommandCli. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:ReceiptPath = 'estate/docs-validation-receipt.json'
    $script:Common = @('-ActorKind', 'tool', '-ActorId', 'fixture-tool')

    function Get-TestText {
        param([object] $Document)
        ConvertTo-DocsJsonText -Value $Document -Indented
    }

    function New-TestEstate {
        # The in-memory files of a complete estate; -Undocumented drops one entry, -Stale ages one pin's digest.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([switch] $Undocumented, [switch] $Stale)
        $snapshot = New-DocsLedgerTestSnapshot -Diagnostic @() -Revision $script:Revision
        $snapshotText = Get-TestText -Document $snapshot
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = [System.Collections.Generic.List[object]]::new()
        foreach ($id in $ids) {
            if ($Undocumented -and $id -ceq $ids[2]) { continue }
            $entries.Add((New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor))
        }
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries.ToArray()
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $script:Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        if ($Stale) { $pins[4]['source_sha256'] = '0' * 64 }
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows
        $profileDocument = New-DocsLedgerTestProfile -AllowDeferred $false -MaxStalePages 0
        @{
            View  = $view
            Ids   = $ids
            Files = [ordered]@{
                'docs/reference/Cli.md'                  = '# Cli'
                $script:ProfilePath                      = (Get-TestText -Document $profileDocument)
                'estate/surface-inventory-snapshot.json' = $snapshotText
                'estate/docs-coverage-ledger.json'       = (Get-TestText -Document $ledger)
                'estate/docs-parity-matrix.json'         = (Get-TestText -Document $matrix)
                'estate/docs-evidence-pins.json'         = (Get-TestText -Document (New-DocsLedgerTestPinSet -Pin $pins))
            }
        }
    }

    function Invoke-TestCommand {
        param([string] $Command, [string[]] $Argument, [hashtable] $Test)
        $outcome = Invoke-DocsCommandCli -Command $Command -CommandArgument $Argument -Context $Test.Context -Json
        @{ Outcome = $outcome; Envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
    }

    function Assert-TestReceipt {
        param([object] $Envelope, [string] $Result)
        $receipt = $Envelope['result']
        $null -eq $receipt | Should -BeFalse
        $receipt['artifact_kind'] | Should -BeExactly 'docs-validation-receipt'
        $receipt['mode'] | Should -BeExactly 'docs-complete'
        $receipt['validation_result'] | Should -BeExactly $Result
        $receipt['revision'] | Should -BeExactly $script:Revision
        (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $receipt) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText (ConvertTo-DocsJsonText -Value $Envelope) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'docs-complete integration' {
    It 'exits 0 with a pass receipt on the complete fixture' {
        # Arrange
        $estate = New-TestEstate
        $test = New-DocsLedgerTestContext -File $estate.Files

        # Act
        $run = Invoke-TestCommand -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Assert-TestReceipt -Envelope $run.Envelope -Result 'pass'
        $run.Envelope['findings'].Count | Should -Be 0
        $run.Envelope['result']['counts']['elements_total'] | Should -Be 6
        $run.Envelope['result']['counts']['undocumented'] | Should -Be 0
        $run.Envelope['result']['counts']['stale_pages'] | Should -Be 0
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count | Should -Be 0
    }

    It 'exits 1 with a fail receipt naming the undocumented element and the stale page' {
        # Arrange
        $estate = New-TestEstate -Undocumented -Stale
        $element = $estate.View.Element[$estate.Ids[2]]
        $staleElement = $estate.View.Element[$estate.Ids[4]]
        $test = New-DocsLedgerTestContext -File $estate.Files

        # Act
        $run = Invoke-TestCommand -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        Assert-TestReceipt -Envelope $run.Envelope -Result 'fail'
        $findings = @($run.Envelope['findings'])
        $missing = @($findings | Where-Object { $_['code'] -ceq 'DOCS_LEDGER_MISSING_DISPOSITION' })
        $missing.Count | Should -Be 1
        $missing[0]['message'].Contains($element['declaration'], [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the finding names the declaration'
        $missing[0]['message'].Contains($element['element_id'], [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the finding names the element id'
        $missing[0]['related_ids'] | Should -Be @($element['element_id'])
        $stale = @($findings | Where-Object { $_['code'] -ceq 'DOCS_STALE_PAGE' })
        $stale.Count | Should -Be 1
        $stale[0]['severity'] | Should -BeExactly 'error' -Because 'max_stale_pages is 0'
        $stale[0]['related_paths'] | Should -Be @($script:Page)
        $stale[0]['message'].Contains($script:Page, [System.StringComparison]::Ordinal) | Should -BeTrue
        $stale[0]['message'].Contains($staleElement['element_id'], [System.StringComparison]::Ordinal) | Should -BeTrue
        $run.Envelope['result']['counts']['undocumented'] | Should -Be 1
        $run.Envelope['result']['counts']['stale_pages'] | Should -Be 1
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count | Should -Be 0
    }

    It 'exits 0 with a pass receipt after set-disposition Write and pin Write' {
        # Arrange: one recording context carries the estate through the three commands.
        $estate = New-TestEstate -Undocumented -Stale
        $test = New-DocsLedgerTestContext -File $estate.Files
        $before = Invoke-TestCommand -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test
        $before.Outcome.ExitCode | Should -Be 1

        # Act
        $disposition = Invoke-TestCommand -Command 'update-ledger' -Argument (@('-Operation', 'set-disposition', '-Element', $estate.Ids[2], '-Disposition', 'documented', '-Page', $script:Page, '-Write') + $script:Common) -Test $test
        $pin = Invoke-TestCommand -Command 'update-ledger' -Argument (@('-Operation', 'pin', '-Element', $estate.Ids[4], '-Page', $script:Page, '-Write') + $script:Common) -Test $test
        $after = Invoke-TestCommand -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $test

        # Assert
        $disposition.Outcome.ExitCode | Should -Be 0
        @($disposition.Envelope['result']['writes'] | Where-Object { $_['status'] -ceq 'updated' } | ForEach-Object { $_['path'] }) | Should -Be @('estate/docs-coverage-ledger.json')
        $pin.Outcome.ExitCode | Should -Be 0
        @($pin.Envelope['result']['writes'] | Where-Object { $_['status'] -ceq 'updated' } | ForEach-Object { $_['path'] }) | Should -Be @('estate/docs-evidence-pins.json')
        $after.Outcome.ExitCode | Should -Be 0
        Assert-TestReceipt -Envelope $after.Envelope -Result 'pass'
        @($after.Envelope['findings'] | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('warning') -Because 'the matrix ledger_ref is stale after the ledger changed, a warning only'
        $after.Envelope['result']['counts']['undocumented'] | Should -Be 0
        $after.Envelope['result']['counts']['stale_pages'] | Should -Be 0
        @($test.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @('estate/docs-coverage-ledger.json', 'estate/docs-evidence-pins.json', $script:ReceiptPath)
        $receipt = (ConvertFrom-DocsJsonText -Text $test.WriteLog[2].Text).Value
        $receipt['id'] | Should -BeExactly $after.Envelope['result']['id']
        $receipt['validation_result'] | Should -BeExactly 'pass'
        (Get-DocsReceiptGateDecision -ReceiptText $test.WriteLog[2].Text -HeadRevision $script:Revision -ComposedSchemaSet $script:Composed).Allow | Should -BeTrue
        (Get-DocsReceiptGateDecision -ReceiptText $test.WriteLog[2].Text -HeadRevision ('f' * 40) -ComposedSchemaSet $script:Composed).Reason | Should -BeExactly 'revision-mismatch'
    }
}
