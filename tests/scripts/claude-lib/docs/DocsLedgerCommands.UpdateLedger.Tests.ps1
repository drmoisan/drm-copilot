#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the update-ledger subcommand of .claude/lib/docs/DocsLedgerCommands.psm1
    (the DocsLedgerCommands suite family).

.DESCRIPTION
    Runs update-ledger through Invoke-DocsCommandCli over the recording in-memory context of
    DocsLedger.TestSupport.psm1: dry-run planning, set-disposition (element and precision
    limit), remove-entry, the newly-introduced rule, pin, unpin, set-dimension, sync-refs, the
    -Write commit path, conflicts and failures, envelopes and the text summary. Assertions use
    codes, exit codes, pointers and identifiers, never Test-Json message text. No file is written.
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
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:LedgerPath = 'estate/docs-coverage-ledger.json'
    $script:MatrixPath = 'estate/docs-parity-matrix.json'
    $script:PinPath = 'estate/docs-evidence-pins.json'
    $script:Common = @('-ActorKind', 'tool', '-ActorId', 'fixture-tool')

    function Get-TestText {
        param([object] $Document)
        ConvertTo-DocsJsonText -Value $Document -Indented
    }

    function Get-TestView {
        param([object] $Snapshot)
        $text = Get-TestText -Document $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)
    }

    function Get-TestCompleteSet {
        # A consistent ledger, matrix and pin collection: every element documented on the page with a current pin.
        param([object] $Snapshot)
        $view = Get-TestView -Snapshot $Snapshot
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        # Entries in ordinal element_id order, the order Merge-DocsLedgerEntry writes, so an identical entry changes no text.
        $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
        foreach ($entry in $entries) { $sorted[[string] $entry['element_id']] = $entry }
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @($sorted.Values)
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        @{
            View   = $view
            Ids    = $ids
            Ledger = $ledger
            Matrix = (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows)
            PinSet = (New-DocsLedgerTestPinSet -Pin $pins)
        }
    }

    function New-TestEstate {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([object] $Snapshot = (New-DocsLedgerTestSnapshot), [hashtable] $Set, [switch] $NoLedger, [switch] $NoMatrix, [switch] $NoPins)
        $files = [ordered]@{ 'docs/reference/Cli.md' = '# Cli'; $script:ProfilePath = (Get-TestText -Document (New-DocsLedgerTestProfile)); 'estate/surface-inventory-snapshot.json' = (Get-TestText -Document $Snapshot) }
        if ($null -ne $Set) {
            if (-not $NoLedger) { $files[$script:LedgerPath] = Get-TestText -Document $Set.Ledger }
            if (-not $NoMatrix) { $files[$script:MatrixPath] = Get-TestText -Document $Set.Matrix }
            if (-not $NoPins) { $files[$script:PinPath] = Get-TestText -Document $Set.PinSet }
        }
        $files
    }

    function Invoke-TestUpdate {
        # Runs update-ledger with the common actor options; returns @{ Outcome; Envelope; Result }.
        param([string[]] $Argument, [hashtable] $Test, [switch] $Text)
        $outcome = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument ($Argument + $script:Common) -Context $Test.Context -Json:(-not $Text)
        $envelope = $null
        if (-not $Text) { $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
        @{ Outcome = $outcome; Envelope = $envelope; Result = $(if ($null -eq $envelope) { $null } else { $envelope['result'] }) }
    }

    function Get-TestWrittenDocument {
        param([hashtable] $Test, [string] $Path)
        (ConvertFrom-DocsJsonText -Text ([System.Text.Encoding]::UTF8.GetString($Test.Files[$Path]))).Value
    }

    function Get-TestWriteCallCount {
        param([hashtable] $Test)
        @($Test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count
    }

    function Get-TestCode {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'update-ledger set-disposition and remove-entry' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Complete = Get-TestCompleteSet -Snapshot $script:Snapshot
        $script:Ids = $script:Complete.Ids
        $script:LimitId = @($script:Complete.View.PrecisionLimit.Keys)[0]
        $script:DiagnosticId = $script:Complete.View.PrecisionLimit[$script:LimitId]['DiagnosticId']
    }

    It 'plans the ledger write and makes no WriteText call without Write' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Get-TestWriteCallCount -Test $test | Should -Be 0
        $run.Result['dry_run'] | Should -BeTrue
        $run.Result['preexisting_errors'] | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) planned", "$($script:PinPath) planned", "$($script:MatrixPath) planned") -Because 'the dropped binding also changes the pins and the matrix; writes are sorted by path'
        $run.Result['writes'][0]['artifact_kind'] | Should -BeExactly 'docs-coverage-ledger'
        $run.Result['writes'][0]['artifact_id'] | Should -BeExactly $script:Complete.Ledger['id']
        $run.Result['writes'][0]['sha256'] | Should -Match '^[0-9a-f]{64}$'
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] + ' ' + $_['severity'] }) | Should -Be @('DOCS_MATRIX_LEDGER_REF warning') -Because 'the planned ledger text leaves the matrix ledger_ref stale until sync-refs'
        $unchanged = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'documented', '-Page', $script:Page) -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete))
        @($unchanged.Result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('skipped', 'skipped', 'skipped') -Because 'an identical entry changes no document'
    }

    It 'records analysis_method from the current element' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)
        $scanner = @($script:Ids | Where-Object { $script:Complete.View.Element[$_]['analysis_method'] -ceq 'scanner' })[0]

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $scanner, '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $ledger = Get-TestWrittenDocument -Test $test -Path $script:LedgerPath
        $entry = @($ledger['entries'] | Where-Object { $_['element_id'] -ceq $scanner })[0]
        $entry['analysis_method'] | Should -BeExactly 'scanner'
        $entry['kind'] | Should -BeExactly $script:Complete.View.Element[$scanner]['kind']
        $entry['disposition'] | Should -BeExactly 'excluded'
        $entry['rationale'] | Should -BeExactly 'Internal.'
        $entry['updated_by']['id'] | Should -BeExactly 'fixture-tool'
        $entry['page_bindings'].Count | Should -Be 0
        (Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger' -JsonText ([System.Text.Encoding]::UTF8.GetString($test.Files[$script:LedgerPath])) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
    }

    It 'removes matrix rows and pins of a dropped binding' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)
        $anchorTest = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[1], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test
        $anchorRun = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[1], '-Disposition', 'documented', '-Page', $script:Page, '-Page', 'docs/guides/Other.md#intro', '-Write') -Test $anchorTest

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $matrix = Get-TestWrittenDocument -Test $test -Path $script:MatrixPath
        @($matrix['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[1] }).Count | Should -Be 0
        $matrix['rows'].Count | Should -Be 5
        $pins = Get-TestWrittenDocument -Test $test -Path $script:PinPath
        @($pins['pins'] | Where-Object { $_['element_id'] -ceq $script:Ids[1] }).Count | Should -Be 0
        $pins['pins'].Count | Should -Be 5
        @((Get-TestWrittenDocument -Test $test -Path $script:LedgerPath)['entries'] | Where-Object { $_['element_id'] -ceq $script:Ids[1] })[0]['page_bindings'].Count | Should -Be 0
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] } | Sort-Object -Unique) | Should -Be @('DOCS_MATRIX_LEDGER_REF') -Because 'the changed ledger text makes the matrix ledger_ref a newly-introduced warning'
        $anchorRun.Outcome.ExitCode | Should -Be 0
        @($anchorRun.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) updated", "$($script:PinPath) skipped", "$($script:MatrixPath) skipped") -Because 'a kept binding drops no row or pin'
        $entry = @((Get-TestWrittenDocument -Test $anchorTest -Path $script:LedgerPath)['entries'] | Where-Object { $_['element_id'] -ceq $script:Ids[1] })[0]
        @($entry['page_bindings'] | ForEach-Object { $_['page_path'] }) | Should -Be @('docs/guides/Other.md', $script:Page)
        $entry['page_bindings'][0]['anchor'] | Should -BeExactly 'intro'
        $null -eq $entry['page_bindings'][1]['anchor'] | Should -BeTrue
    }

    It 'exits 1 naming the missing rationale for excluded and writes nothing' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $finding = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_LEDGER_RATIONALE_REQUIRED'
        $finding.Count | Should -Be 1
        $finding[0]['related_ids'] | Should -Be @($script:Ids[0])
        $finding[0]['pointer'] | Should -Match '^/entries/[0-9]+/rationale$'
        @($run.Envelope['findings'] | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('error') -Because 'only the newly-introduced errors are returned'
        $null -eq $run.Result | Should -BeTrue
        Get-TestWriteCallCount -Test $test | Should -Be 0
    }

    It 'exits 1 naming the missing owner or target for deferred' {
        # Act
        $noOwner = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'deferred', '-Target', 'Later') -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete))
        $noTarget = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'deferred', '-Owner', 'docs-team') -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete))
        $neither = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Limit', $script:DiagnosticId, '-Disposition', 'deferred') -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete))

        # Assert
        $noOwner.Outcome.ExitCode | Should -Be 1
        (Get-TestCode -Finding $noOwner.Envelope['findings'] -Code 'DOCS_LEDGER_OWNER_REQUIRED').Count | Should -Be 1
        (Get-TestCode -Finding $noOwner.Envelope['findings'] -Code 'DOCS_LEDGER_TARGET_REQUIRED').Count | Should -Be 0
        (Get-TestCode -Finding $noOwner.Envelope['findings'] -Code 'DOCS_LEDGER_OWNER_REQUIRED')[0]['related_ids'] | Should -Be @($script:Ids[0])
        $noTarget.Outcome.ExitCode | Should -Be 1
        (Get-TestCode -Finding $noTarget.Envelope['findings'] -Code 'DOCS_LEDGER_TARGET_REQUIRED').Count | Should -Be 1
        (Get-TestCode -Finding $noTarget.Envelope['findings'] -Code 'DOCS_LEDGER_OWNER_REQUIRED').Count | Should -Be 0
        $neither.Outcome.ExitCode | Should -Be 1
        (Get-TestCode -Finding $neither.Envelope['findings'] -Code 'DOCS_LEDGER_OWNER_REQUIRED').Count | Should -Be 1
        (Get-TestCode -Finding $neither.Envelope['findings'] -Code 'DOCS_LEDGER_TARGET_REQUIRED').Count | Should -Be 1
        (Get-TestCode -Finding $neither.Envelope['findings'] -Code 'DOCS_LEDGER_OWNER_REQUIRED')[0]['related_ids'] | Should -Be @($script:LimitId)
    }

    It 'exits 0 when only pre-existing errors for other elements exist and carries no error finding' {
        # Arrange: element 2 has no entry before the operation (DOCS_LEDGER_MISSING_DISPOSITION, and its row is unbound).
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Where-Object { $_['element_id'] -cne $script:Ids[2] })
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[3], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test
        $fixed = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[2], '-Disposition', 'documented', '-Page', $script:Page) -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set))

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result['preexisting_errors'] | Should -Be 2 -Because 'the missing disposition and the unbound row of element 2'
        @($run.Envelope['findings'] | Where-Object { $_['severity'] -ceq 'error' }).Count | Should -Be 0
        $run.Envelope['ok'] | Should -BeTrue
        Get-TestWriteCallCount -Test $test | Should -BeGreaterThan 0
        $fixed.Outcome.ExitCode | Should -Be 0 -Because 'recording the missing disposition introduces no new error'
        $fixed.Result['preexisting_errors'] | Should -Be 2
        @($fixed.Result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('planned', 'skipped', 'skipped')
    }

    It 'set-disposition Limit writes the deferred scanner entry and clears DOCS_LEDGER_LIMIT_UNRECORDED' {
        # Arrange: a ledger without the precision-limit entry.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Where-Object { -not $_['extensions'].Contains('docs.precision-limit') })
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)
        $before = Get-DocsLedgerFinding -Ledger $set.Ledger -SnapshotView $set.View
        (Get-TestCode -Finding $before -Code 'DOCS_LEDGER_LIMIT_UNRECORDED').Count | Should -Be 1

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Limit', $script:DiagnosticId, '-Disposition', 'deferred', '-Owner', 'scanner-team', '-Target', 'Native analyzer', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result['dry_run'] | Should -BeFalse
        @($run.Result['writes'] | Where-Object { $_['path'] -ceq $script:LedgerPath })[0]['status'] | Should -BeExactly 'updated'
        $ledger = Get-TestWrittenDocument -Test $test -Path $script:LedgerPath
        $entries = @($ledger['entries'] | Where-Object { $_['element_id'] -ceq $script:LimitId })
        $entries.Count | Should -Be 1
        $entries[0]['disposition'] | Should -BeExactly 'deferred'
        $entries[0]['analysis_method'] | Should -BeExactly 'scanner'
        $entries[0]['owner'] | Should -BeExactly 'scanner-team'
        $entries[0]['target'] | Should -BeExactly 'Native analyzer'
        $entries[0]['kind'] | Should -BeExactly 'cli-command'
        $entries[0]['element_id'] | Should -BeExactly (Get-DocsElementId -Kind 'cli-command' -Path 'src/app/Dynamic.ps1' -Declaration $script:DiagnosticId)
        $entries[0]['extensions']['docs.precision-limit']['analyzer_id'] | Should -BeExactly 'fixture-scanner'
        $entries[0]['extensions']['docs.precision-limit']['code'] | Should -BeExactly 'DOCS_SCANNER_DYNAMIC_COMMAND'
        $entries[0]['extensions']['docs.precision-limit']['diagnostic_id'] | Should -BeExactly $script:DiagnosticId
        $after = Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $set.View
        (Get-TestCode -Finding $after -Code 'DOCS_LEDGER_LIMIT_UNRECORDED').Count | Should -Be 0
        (Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger' -JsonText ([System.Text.Encoding]::UTF8.GetString($test.Files[$script:LedgerPath])) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
    }

    It 'remove-entry removes the entry, rows and pins' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)
        $limitTest = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'remove-entry', '-Element', $script:Ids[4], '-Write') -Test $test
        $limitRun = Invoke-TestUpdate -Argument @('-Operation', 'remove-entry', '-Limit', $script:DiagnosticId, '-Write') -Test $limitTest

        # Assert
        $run.Outcome.ExitCode | Should -Be 1 -Because 'removing the entry of a current element introduces DOCS_LEDGER_MISSING_DISPOSITION'
        $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_LEDGER_MISSING_DISPOSITION'
        Get-TestWriteCallCount -Test $test | Should -Be 0
        $limitRun.Outcome.ExitCode | Should -Be 1 -Because 'removing the limit entry introduces DOCS_LEDGER_LIMIT_UNRECORDED'
        $limitRun.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_LEDGER_LIMIT_UNRECORDED'
    }

    It 'remove-entry removes the entry, rows and pins of an element that left the snapshot' {
        # Arrange: a snapshot without element 4 makes its entry an orphan; removing it introduces no error.
        $droppedKind = [string] $script:Complete.View.Element[$script:Ids[4]]['kind']
        $reduced = New-DocsLedgerTestSnapshot -Element @(foreach ($kind in Get-DocsElementKind) { if ($kind -cne $droppedKind) { New-DocsLedgerTestElement -Kind $kind } })
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['snapshot_ref']['sha256'] = Get-DocsSha256Hex -Text (Get-TestText -Document $reduced)
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $reduced -Set $set)
        $absentLimit = New-DocsLedgerTestSnapshot -Diagnostic @()
        $limitTest = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $absentLimit -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'remove-entry', '-Element', $script:Ids[4], '-Write') -Test $test
        $limitRun = Invoke-TestUpdate -Argument @('-Operation', 'remove-entry', '-Limit', $script:DiagnosticId, '-Write') -Test $limitTest

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $ledger = Get-TestWrittenDocument -Test $test -Path $script:LedgerPath
        @($ledger['entries'] | Where-Object { $_['element_id'] -ceq $script:Ids[4] }).Count | Should -Be 0
        @((Get-TestWrittenDocument -Test $test -Path $script:MatrixPath)['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[4] }).Count | Should -Be 0
        @((Get-TestWrittenDocument -Test $test -Path $script:PinPath)['pins'] | Where-Object { $_['element_id'] -ceq $script:Ids[4] }).Count | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('updated', 'updated', 'updated')
        $limitRun.Outcome.ExitCode | Should -Be 0
        @((Get-TestWrittenDocument -Test $limitTest -Path $script:LedgerPath)['entries'] | Where-Object { $_['element_id'] -ceq $script:LimitId }).Count | Should -Be 0
    }

    It 'exits 1 with DOCS_UPDATE_TARGET_INVALID for an absent element or limit' {
        # Arrange
        $unknown = 'cli-command-' + ('0' * 64)
        $cases = @(
            @('-Operation', 'set-disposition', '-Element', $unknown, '-Disposition', 'excluded', '-Rationale', 'x'),
            @('-Operation', 'set-disposition', '-Limit', ('diagnostic-' + ('0' * 64)), '-Disposition', 'deferred', '-Owner', 'o', '-Target', 't'),
            @('-Operation', 'set-disposition', '-Element', $script:LimitId, '-Disposition', 'excluded', '-Rationale', 'x'),
            @('-Operation', 'remove-entry', '-Element', $unknown),
            @('-Operation', 'remove-entry', '-Limit', ('diagnostic-' + ('0' * 64)))
        )

        foreach ($arguments in $cases) {
            $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

            # Act
            $run = Invoke-TestUpdate -Argument ($arguments + @('-Write')) -Test $test

            # Assert
            $run.Outcome.ExitCode | Should -Be 1 -Because ($arguments -join ' ')
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_UPDATE_TARGET_INVALID'
            $null -eq $run.Result | Should -BeTrue
            Get-TestWriteCallCount -Test $test | Should -Be 0
        }
    }

    It 'creates a document with the 1020 header and a repository-derived id' {
        # Arrange: no ledger, matrix or pin collection exists.
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) created") -Because 'an absent, unchanged matrix or pin collection is not created'
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' } | ForEach-Object { $_.Mode }) | Should -Be @('create')
        $ledger = Get-TestWrittenDocument -Test $test -Path $script:LedgerPath
        $ledger['$schema'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:docs-coverage-ledger'
        $ledger['schema_version'] | Should -BeExactly '1.0.0'
        $ledger['artifact_kind'] | Should -BeExactly 'docs-coverage-ledger'
        $ledger['repository'] | Should -BeExactly 'fixture-repo'
        $ledger['id'] | Should -BeExactly (Get-DocsStableId -Prefix 'docs-coverage-ledger' -Value ([ordered]@{ repository = 'fixture-repo' }))
        $ledger['snapshot_ref']['sha256'] | Should -BeExactly $script:Complete.View.Sha256
        $ledger['entries'].Count | Should -Be 1
        $run.Result['writes'][0]['artifact_id'] | Should -BeExactly $ledger['id']
        (Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger' -JsonText ([System.Text.Encoding]::UTF8.GetString($test.Files[$script:LedgerPath])) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
    }
}

Describe 'update-ledger pin, unpin, set-dimension, sync-refs and the Write commit' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Complete = Get-TestCompleteSet -Snapshot $script:Snapshot
        $script:Ids = $script:Complete.Ids
        $script:LimitId = @($script:Complete.View.PrecisionLimit.Keys)[0]
        $script:NewPage = 'docs/guides/New.md'
    }

    It 're-pins the same element and page under the same pin_id and clears staleness' {
        # Arrange: the pin of element 0 records a stale digest.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $stale = @($set.PinSet['pins'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] })[0]
        $stale['source_sha256'] = '0' * 64
        $stale['pinned_at'] = '2025-01-01T00:00:00Z'
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)
        (Get-DocsStalePage -PinSet $set.PinSet -Element $set.View.Element).Count | Should -Be 1

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'pin', '-Element', $script:Ids[0], '-Page', $script:Page, '-Claim', 'Describes the command.', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) skipped", "$($script:PinPath) updated", "$($script:MatrixPath) skipped")
        $pins = Get-TestWrittenDocument -Test $test -Path $script:PinPath
        $pins['pins'].Count | Should -Be 6
        $replaced = @($pins['pins'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] })
        $replaced.Count | Should -Be 1
        $replaced[0]['pin_id'] | Should -BeExactly $stale['pin_id']
        $replaced[0]['source_sha256'] | Should -BeExactly $set.View.Element[$script:Ids[0]]['source_sha256']
        $replaced[0]['pinned_at'] | Should -BeExactly $script:IssuedAt
        $replaced[0]['revision'] | Should -BeExactly $set.View.Revision
        $replaced[0]['claim'] | Should -BeExactly 'Describes the command.'
        $replaced[0]['pinned_by']['id'] | Should -BeExactly 'fixture-tool'
        (Get-DocsStalePage -PinSet $pins -Element $set.View.Element).Count | Should -Be 0
        $run.Envelope['findings'].Count | Should -Be 0
    }

    It 'unpin removes the pin and its id from every row' {
        # Arrange: the accurate dimension of element 0 is not-assessed, so removing its pin introduces no error.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $row = @($set.Matrix['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] })[0]
        $row['dimensions']['accurate']['state'] = 'not-assessed'
        $pinId = [string] $row['dimensions']['accurate']['evidence_pin_ids'][0]
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)
        $missing = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'unpin', '-Element', $script:Ids[0], '-Page', $script:Page, '-Write') -Test $test
        $missingRun = Invoke-TestUpdate -Argument @('-Operation', 'unpin', '-Element', $script:Ids[0], '-Page', $script:NewPage) -Test $missing

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) skipped", "$($script:PinPath) updated", "$($script:MatrixPath) updated")
        $pins = Get-TestWrittenDocument -Test $test -Path $script:PinPath
        $pins['pins'].Count | Should -Be 5
        @($pins['pins'] | Where-Object { $_['pin_id'] -ceq $pinId }).Count | Should -Be 0
        $matrix = Get-TestWrittenDocument -Test $test -Path $script:MatrixPath
        $written = @($matrix['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] })[0]
        $written['dimensions']['accurate']['evidence_pin_ids'].Count | Should -Be 0
        @($matrix['rows'] | ForEach-Object { @($_['dimensions'].Values | ForEach-Object { $_['evidence_pin_ids'] }) } | Where-Object { $_ -ceq $pinId }).Count | Should -Be 0
        $missingRun.Outcome.ExitCode | Should -Be 1
        $missingRun.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_UPDATE_TARGET_INVALID'
    }

    It 'set-dimension creates the row and derives evidence_pin_ids' {
        # Arrange: element 0 is also bound to a new page (its row missing) and pinned there.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $element = $set.View.Element[$script:Ids[0]]
        $index = [Array]::IndexOf([string[]]@($set.Ledger['entries'] | ForEach-Object { $_['element_id'] }), $script:Ids[0])
        $set.Ledger['entries'][$index] = New-DocsLedgerEntry -Element $element -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }, @{ page_path = $script:NewPage; anchor = $null }) -Actor $script:Actor
        $newPin = New-DocsEvidencePin -Element $element -PagePath $script:NewPage -Revision $set.View.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor
        $set.PinSet['pins'] = [object[]](@($set.PinSet['pins']) + @($newPin))
        $set.Matrix['ledger_ref']['sha256'] = Get-DocsSha256Hex -Text (Get-TestText -Document $set.Ledger)
        $files = New-TestEstate -Snapshot $script:Snapshot -Set $set
        $files[$script:NewPage] = '# New'
        $test = New-DocsLedgerTestContext -File $files
        $update = New-DocsLedgerTestContext -File $files

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-dimension', '-Element', $script:Ids[0], '-Page', $script:NewPage, '-Dimension', 'accurate', '-State', 'pass', '-Write') -Test $test
        $updateRun = Invoke-TestUpdate -Argument @('-Operation', 'set-dimension', '-Element', $script:Ids[0], '-Page', $script:Page, '-Dimension', 'example_present', '-State', 'fail', '-Rationale', 'No example.', '-Write') -Test $update

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result['preexisting_errors'] | Should -Be 1 -Because 'the missing row was an error before the operation'
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) skipped", "$($script:PinPath) skipped", "$($script:MatrixPath) updated")
        $matrix = Get-TestWrittenDocument -Test $test -Path $script:MatrixPath
        $matrix['rows'].Count | Should -Be 7
        $created = @($matrix['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] -and $_['page_path'] -ceq $script:NewPage })
        $created.Count | Should -Be 1
        $created[0]['kind'] | Should -BeExactly $element['kind']
        $created[0]['dimensions']['accurate']['state'] | Should -BeExactly 'pass'
        $created[0]['dimensions']['accurate']['evidence_pin_ids'] | Should -Be @($newPin['pin_id'])
        @($created[0]['dimensions']['exists'], $created[0]['dimensions']['example_present'], $created[0]['dimensions']['owner_assigned'], $created[0]['dimensions']['diataxis_mode'] | ForEach-Object { $_['state'] } | Sort-Object -Unique) | Should -Be @('not-assessed')
        (Test-DocsArtifactText -ArtifactKind 'docs-parity-matrix' -JsonText ([System.Text.Encoding]::UTF8.GetString($test.Files[$script:MatrixPath])) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        $updateRun.Outcome.ExitCode | Should -Be 0
        $updated = @((Get-TestWrittenDocument -Test $update -Path $script:MatrixPath)['rows'] | Where-Object { $_['element_id'] -ceq $script:Ids[0] -and $_['page_path'] -ceq $script:Page })[0]
        $updated['dimensions']['example_present']['state'] | Should -BeExactly 'fail'
        $updated['dimensions']['example_present']['rationale'] | Should -BeExactly 'No example.'
        $updated['dimensions']['accurate']['state'] | Should -BeExactly 'pass' -Because 'the other dimensions keep their state'
    }

    It 'sync-refs refreshes analysis_method and sets both refs' {
        # Arrange: stale references and a flipped analysis method.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['snapshot_ref']['sha256'] = 'b' * 64
        $set.Ledger['entries'][0]['analysis_method'] = $(if ($set.Ledger['entries'][0]['analysis_method'] -ceq 'native') { 'scanner' } else { 'native' })
        $set.Matrix['snapshot_ref']['sha256'] = 'c' * 64
        $set.Matrix['ledger_ref']['sha256'] = 'd' * 64
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'sync-refs', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result['preexisting_errors'] | Should -Be 0
        @($run.Result['writes'] | ForEach-Object { $_['path'] + ' ' + $_['status'] }) | Should -Be @("$($script:LedgerPath) updated", "$($script:PinPath) skipped", "$($script:MatrixPath) updated")
        $ledgerBytes = $test.Files[$script:LedgerPath]
        $ledger = Get-TestWrittenDocument -Test $test -Path $script:LedgerPath
        $ledger['snapshot_ref']['sha256'] | Should -BeExactly $set.View.Sha256
        $ledger['entries'][0]['analysis_method'] | Should -BeExactly $set.View.Element[$ledger['entries'][0]['element_id']]['analysis_method']
        $matrix = Get-TestWrittenDocument -Test $test -Path $script:MatrixPath
        $matrix['snapshot_ref']['sha256'] | Should -BeExactly $set.View.Sha256
        $matrix['ledger_ref']['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $ledgerBytes) -Because 'ledger_ref pins the ledger bytes as written'
        $run.Envelope['findings'].Count | Should -Be 0 -Because 'sync-refs resolves the reference warnings and introduces none'
    }

    It 'rejects pin, unpin and set-dimension on a precision-limit id' {
        foreach ($arguments in @(
                @('-Operation', 'pin', '-Element', $script:LimitId, '-Page', $script:Page),
                @('-Operation', 'unpin', '-Element', $script:LimitId, '-Page', $script:Page),
                @('-Operation', 'set-dimension', '-Element', $script:LimitId, '-Page', $script:Page, '-Dimension', 'exists', '-State', 'pass')
            )) {
            # Arrange
            $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

            # Act
            $run = Invoke-TestUpdate -Argument ($arguments + @('-Write')) -Test $test

            # Assert
            $run.Outcome.ExitCode | Should -Be 1 -Because ($arguments -join ' ')
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_UPDATE_TARGET_INVALID'
            $run.Envelope['findings'][0]['related_ids'] | Should -Be @($script:LimitId)
            Get-TestWriteCallCount -Test $test | Should -Be 0
        }
    }

    It 'writes only through Invoke-DocsArtifactWrite with Write' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)
        $dry = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test
        $dryRun = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.') -Test $dry

        # Assert: every WriteText call follows the boundary protocol (a digest re-read of the same path right before an overwrite).
        $run.Outcome.ExitCode | Should -Be 0
        $log = @($test.CallLog)
        $writes = @(0..($log.Count - 1) | Where-Object { $log[$_].Member -ceq 'WriteText' })
        $writes.Count | Should -Be 3
        foreach ($position in $writes) {
            $log[$position].Mode | Should -BeExactly 'overwrite'
            $log[$position - 1].Member | Should -BeExactly 'ReadBytes'
            $log[$position - 1].RelativePath | Should -BeExactly $log[$position].RelativePath
        }
        @($log | Where-Object { $_.Member -ceq 'WriteText' } | ForEach-Object { $_.RelativePath }) | Should -Be @($script:LedgerPath, $script:PinPath, $script:MatrixPath) -Because 'writes happen in ascending path order'
        $run.Result['dry_run'] | Should -BeFalse
        @($run.Result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('updated', 'updated', 'updated')
        $dryRun.Outcome.ExitCode | Should -Be 0
        Get-TestWriteCallCount -Test $dry | Should -Be 0
        @($dryRun.Result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('planned', 'planned', 'planned')
    }

    It 'exits 3 with one DOCS_CLI_RUNTIME naming the path on a digest conflict' {
        # Arrange: the matrix changes between the load and the digest re-read before its overwrite.
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)
        $inner = $test.Context.ReadBytes
        $files = $test.Files
        $matrixPath = $script:MatrixPath
        $state = @{ Count = 0 }
        $test.Context.ReadBytes = {
            param($RelativePath)
            $bytes = & $inner $RelativePath
            if ([string] $RelativePath -ceq $matrixPath) {
                $state.Count++
                if ($state.Count -eq 1) { $files[$matrixPath] = [System.Text.Encoding]::UTF8.GetBytes('{"changed":true}') }
            }
            , $bytes
        }.GetNewClosure()

        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 3
        $run.Envelope['findings'].Count | Should -Be 1
        $finding = $run.Envelope['findings'][0]
        $finding['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
        $finding['artifact_path'] | Should -BeExactly $script:MatrixPath
        $finding['message'].Contains($script:MatrixPath, [System.StringComparison]::Ordinal) | Should -BeTrue
        $finding['message'].Contains('conflict', [System.StringComparison]::Ordinal) | Should -BeTrue
        $finding['related_paths'] | Should -Be @($script:LedgerPath, $script:PinPath, $script:MatrixPath) -Because 'the conflicting path and every path already written are listed'
        $null -eq $run.Envelope['result'] | Should -BeTrue
        @($test.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:LedgerPath, $script:PinPath) -Because 'earlier writes are not rolled back and the conflicting document is not written'
        $run.Outcome.Stderr | Should -Match 'exit 3 \(DOCS_CLI_RUNTIME\)'
    }

    It 'exits 3 for an injected write failure, an injected read failure and a non-UTC clock' {
        # Arrange
        $files = New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete
        $writeFail = New-DocsLedgerTestContext -File $files -WriteTextFailure @{ $script:PinPath = 'disk full' }
        $readFail = New-DocsLedgerTestContext -File $files -ReadBytesFailure @{ 'estate/surface-inventory-snapshot.json' = 'permission denied' }
        $local = New-DocsLedgerTestContext -File $files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Local))
        $arguments = @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.', '-Write')

        # Act
        $writeRun = Invoke-TestUpdate -Argument $arguments -Test $writeFail
        $readRun = Invoke-TestUpdate -Argument $arguments -Test $readFail
        $clockRun = Invoke-TestUpdate -Argument $arguments -Test $local

        # Assert
        foreach ($run in @($writeRun, $readRun, $clockRun)) {
            $run.Outcome.ExitCode | Should -Be 3
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
            $null -eq $run.Envelope['result'] | Should -BeTrue
        }
        $writeRun.Envelope['findings'][0]['message'].Contains('disk full', [System.StringComparison]::Ordinal) | Should -BeTrue
        $writeRun.Envelope['findings'][0]['related_paths'] | Should -Be @($script:LedgerPath, $script:PinPath) -Because 'the failed path and the path already written'
        @($writeFail.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:LedgerPath)
        $readRun.Envelope['findings'][0]['message'].Contains('permission denied', [System.StringComparison]::Ordinal) | Should -BeTrue
        $clockRun.Envelope['findings'][0]['message'].Contains('DOCS_CLOCK_NOT_UTC', [System.StringComparison]::Ordinal) | Should -BeTrue
        $local.CallLog.Count | Should -Be 0
    }

    It 'emits schema-valid byte-identical Json envelopes' {
        # Arrange
        $files = New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete
        $cases = @(
            @{ Argument = @('-Operation', 'sync-refs'); Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded'); Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Operation', 'pin', '-Element', $script:Ids[0]); Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Operation', 'sync-refs'); Clock = [System.DateTimeKind]::Local }
        )

        # Act and Assert
        $codes = foreach ($case in $cases) {
            $run = Invoke-TestUpdate -Argument $case.Argument -Test (New-DocsLedgerTestContext -File $files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, $case.Clock)))
            (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $run.Outcome.Stdout -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because ($case.Argument -join ' ')
            $run.Envelope['command'] | Should -BeExactly 'update-ledger'
            $run.Envelope['ok'] | Should -Be ($run.Outcome.ExitCode -eq 0)
            $run.Outcome.ExitCode
        }
        @($codes) | Should -Be @(0, 1, 2, 3)
        $first = Invoke-TestUpdate -Argument @('-Operation', 'pin', '-Element', $script:Ids[0], '-Page', $script:Page, '-Write') -Test (New-DocsLedgerTestContext -File $files)
        $second = Invoke-TestUpdate -Argument @('-Operation', 'pin', '-Element', $script:Ids[0], '-Page', $script:Page, '-Write') -Test (New-DocsLedgerTestContext -File $files)
        $first.Outcome.Stdout | Should -BeExactly $second.Outcome.Stdout
    }

    It 'prints the summary line without Json' {
        # Act
        $run = Invoke-TestUpdate -Argument @('-Operation', 'set-disposition', '-Element', $script:Ids[0], '-Disposition', 'excluded', '-Rationale', 'Internal.') -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)) -Text

        # Assert
        $lines = @($run.Outcome.Stdout.TrimEnd("`n") -split "`n")
        $lines[0] | Should -Match '^warning DOCS_MATRIX_LEDGER_REF estate/docs-parity-matrix.json/ledger_ref/sha256: '
        $lines | Should -Contain "planned $($script:LedgerPath)"
        $lines[-1] | Should -BeExactly 'update-ledger: exit=0 errors=0 warnings=1 infos=0'
        $run.Outcome.Stdout.Contains('{', [System.StringComparison]::Ordinal) | Should -BeFalse
    }
}
