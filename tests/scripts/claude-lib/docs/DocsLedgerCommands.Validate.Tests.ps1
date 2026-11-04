#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the validate subcommand of .claude/lib/docs/DocsLedgerCommands.psm1 (the
    DocsLedgerCommands suite family).

.DESCRIPTION
    Runs validate through Invoke-DocsCommandCli over the recording in-memory context of
    DocsLedger.TestSupport.psm1: zero writes without -WriteReceipt, the receipt write on pass and
    fail, the revision pin, mode checks, exit codes 0 to 3, envelopes and the text summary.
    Assertions use codes, exit codes, pointers and identifiers, never Test-Json message text. No
    file is written.
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
    $script:Modes = @('profile', 'ledger', 'matrix', 'docs-complete')

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
        param([object] $Snapshot)
        $view = Get-TestView -Snapshot $Snapshot
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        @{ View = $view; Ids = $ids; Ledger = $ledger; Matrix = (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows); PinSet = (New-DocsLedgerTestPinSet -Pin $pins) }
    }

    function New-TestEstate {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([object] $Snapshot = (New-DocsLedgerTestSnapshot), [object] $ProfileDocument = (New-DocsLedgerTestProfile), [hashtable] $Set, [switch] $NoProfile)
        $files = [ordered]@{ 'docs/reference/Cli.md' = '# Cli'; 'estate/surface-inventory-snapshot.json' = (Get-TestText -Document $Snapshot) }
        if (-not $NoProfile) { $files[$script:ProfilePath] = Get-TestText -Document $ProfileDocument }
        if ($null -ne $Set) {
            $files['estate/docs-coverage-ledger.json'] = Get-TestText -Document $Set.Ledger
            $files['estate/docs-parity-matrix.json'] = Get-TestText -Document $Set.Matrix
            $files['estate/docs-evidence-pins.json'] = Get-TestText -Document $Set.PinSet
        }
        $files
    }

    function Invoke-TestValidate {
        param([string[]] $Argument, [hashtable] $Test, [switch] $Text)
        $outcome = Invoke-DocsCommandCli -Command 'validate' -CommandArgument $Argument -Context $Test.Context -Json:(-not $Text)
        $envelope = $null
        if (-not $Text) { $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
        @{ Outcome = $outcome; Envelope = $envelope; Result = $(if ($null -eq $envelope) { $null } else { $envelope['result'] }) }
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

Describe 'validate' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Complete = Get-TestCompleteSet -Snapshot $script:Snapshot
        $script:Files = New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete
    }

    It 'makes zero WriteText calls without WriteReceipt in every mode' {
        foreach ($mode in $script:Modes) {
            # Arrange
            $test = New-DocsLedgerTestContext -File $script:Files
            $failing = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot)

            # Act
            $run = Invoke-TestValidate -Argument @('-Mode', $mode, '-Revision', $script:Revision) -Test $test
            $failRun = Invoke-TestValidate -Argument @('-Mode', $mode, '-Revision', $script:Revision) -Test $failing

            # Assert
            $run.Outcome.ExitCode | Should -Be 0 -Because $mode
            $run.Result['validation_result'] | Should -BeExactly 'pass' -Because $mode
            $run.Result['mode'] | Should -BeExactly $mode
            Get-TestWriteCallCount -Test $test | Should -Be 0 -Because $mode
            $test.WriteLog.Count | Should -Be 0
            Get-TestWriteCallCount -Test $failing | Should -Be 0 -Because "$mode on fail"
            if ($mode -ceq 'profile') { $failRun.Outcome.ExitCode | Should -Be 0 } else { $failRun.Outcome.ExitCode | Should -Be 1 -Because "$mode needs the absent ledger" }
        }
    }

    It 'writes only the receipt at validation_receipt on pass and on fail with WriteReceipt' {
        # Arrange
        $pass = New-DocsLedgerTestContext -File $script:Files
        $failFiles = New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete
        $failFiles[$script:ReceiptPath] = '{"old": true}'
        $fail = New-DocsLedgerTestContext -File $failFiles -UtcNow ([datetime]::new(2026, 3, 2, 8, 0, 0, [System.DateTimeKind]::Utc))

        # Act
        $passRun = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $pass
        $failRun = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', ('f' * 40), '-WriteReceipt') -Test $fail

        # Assert
        $passRun.Outcome.ExitCode | Should -Be 0
        @($pass.WriteLog | ForEach-Object { $_.RelativePath + ' ' + $_.Mode }) | Should -Be @("$($script:ReceiptPath) create")
        Get-TestWriteCallCount -Test $pass | Should -Be 1
        $written = (ConvertFrom-DocsJsonText -Text $pass.WriteLog[0].Text).Value
        foreach ($field in 'id', 'mode', 'repository', 'revision', 'validation_result') { $written[$field] | Should -BeExactly $passRun.Result[$field] -Because "the hook reads $field" }
        $written['artifact_kind'] | Should -BeExactly 'docs-validation-receipt'
        $written['validation_result'] | Should -BeExactly 'pass'
        (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText $pass.WriteLog[0].Text -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        $failRun.Outcome.ExitCode | Should -Be 1
        (Get-TestCode -Finding $failRun.Envelope['findings'] -Code 'DOCS_REVISION_MISMATCH').Count | Should -Be 1
        @($fail.WriteLog | ForEach-Object { $_.RelativePath + ' ' + $_.Mode }) | Should -Be @("$($script:ReceiptPath) overwrite")
        $failWritten = (ConvertFrom-DocsJsonText -Text $fail.WriteLog[0].Text).Value
        $failWritten['validation_result'] | Should -BeExactly 'fail'
        $failWritten['id'] | Should -BeExactly $failRun.Result['id']
        $failWritten['issued_at'] | Should -BeExactly '2026-03-02T08:00:00Z'
        @($failRun.Result['inputs'] | ForEach-Object { $_['artifact_kind'] }) | Should -Not -Contain 'docs-validation-receipt' -Because 'the receipt is not an input of itself'
    }

    It 'pins the receipt revision to the Revision argument' {
        # Arrange
        $other = 'e' * 64
        $unpinned = New-DocsLedgerTestSnapshot -NoRevision
        $unpinnedSet = Get-TestCompleteSet -Snapshot $unpinned

        # Act
        $ledger = Invoke-TestValidate -Argument @('-Mode', 'ledger', '-Revision', $other) -Test (New-DocsLedgerTestContext -File $script:Files)
        $matrix = Invoke-TestValidate -Argument @('-Mode', 'matrix', '-Revision', $script:Revision) -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $unpinned -Set $unpinnedSet))

        # Assert
        $ledger.Result['revision'] | Should -BeExactly $other
        $ledger.Outcome.ExitCode | Should -Be 1 -Because 'the snapshot revision differs'
        $matrix.Result['revision'] | Should -BeExactly $script:Revision -Because 'a null snapshot revision does not change the pinned revision'
        $matrix.Outcome.ExitCode | Should -Be 0
    }

    It 'exits 2 for WriteReceipt with any other mode' {
        foreach ($mode in 'profile', 'ledger', 'matrix') {
            # Arrange
            $test = New-DocsLedgerTestContext -File $script:Files

            # Act
            $run = Invoke-TestValidate -Argument @('-Mode', $mode, '-Revision', $script:Revision, '-WriteReceipt') -Test $test

            # Assert
            $run.Outcome.ExitCode | Should -Be 2 -Because $mode
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
            $null -eq $run.Result | Should -BeTrue
            $test.CallLog.Count | Should -Be 0
        }
    }

    It 'reports DOCS_LEDGER_LIMIT_UNRECORDED in ledger mode' {
        # Arrange
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Where-Object { -not $_['extensions'].Contains('docs.precision-limit') })
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)
        $limit = $set.View.PrecisionLimit[@($set.View.PrecisionLimit.Keys)[0]]

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'ledger', '-Revision', $script:Revision) -Test $test
        $profileRun = Invoke-TestValidate -Argument @('-Mode', 'profile', '-Revision', $script:Revision) -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set))

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $finding = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_LEDGER_LIMIT_UNRECORDED'
        $finding.Count | Should -Be 1
        $finding[0]['related_ids'] | Should -Contain $limit['ElementId']
        $finding[0]['related_ids'] | Should -Contain $limit['DiagnosticId']
        $finding[0]['related_paths'] | Should -Be @($limit['Path'])
        foreach ($token in @($limit['AnalyzerId'], $limit['Code'], $limit['Path'], $limit['DiagnosticId'], $limit['ElementId'])) { $finding[0]['message'].Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the message names $token" }
        $run.Result['validation_result'] | Should -BeExactly 'fail'
        $profileRun.Outcome.ExitCode | Should -Be 0 -Because 'profile mode reads no ledger'
    }

    It 'exits 1 with DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete' {
        # Arrange
        $unpinned = New-DocsLedgerTestSnapshot -NoRevision
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $unpinned -Set (Get-TestCompleteSet -Snapshot $unpinned))

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $finding = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_SNAPSHOT_UNPINNED'
        $finding.Count | Should -Be 1
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $run.Result['validation_result'] | Should -BeExactly 'fail'
        $run.Result['revision'] | Should -BeExactly $script:Revision
    }

    It 'exits 1 with null result when the profile does not load' {
        # Arrange
        $broken = New-DocsLedgerTestProfile
        $broken.Remove('audiences')
        $semantic = New-DocsLedgerTestProfile
        $semantic['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators')

        # Act
        $missing = Invoke-TestValidate -Argument @('-Mode', 'profile', '-Revision', $script:Revision) -Test (New-DocsLedgerTestContext -File (New-TestEstate -NoProfile))
        $schema = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test (New-DocsLedgerTestContext -File (New-TestEstate -ProfileDocument $broken -Set $script:Complete))
        $parse = Invoke-TestValidate -Argument @('-Mode', 'profile', '-Revision', $script:Revision, '-Profile', 'p.json') -Test (New-DocsLedgerTestContext -File @{ 'p.json' = '{"id":' })
        $semanticRun = Invoke-TestValidate -Argument @('-Mode', 'profile', '-Revision', $script:Revision) -Test (New-DocsLedgerTestContext -File (New-TestEstate -ProfileDocument $semantic))

        # Assert
        $missing.Outcome.ExitCode | Should -Be 1
        $missing.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_PROFILE_MISSING'
        $null -eq $missing.Result | Should -BeTrue
        $schema.Outcome.ExitCode | Should -Be 1
        $null -eq $schema.Result | Should -BeTrue
        @($schema.Envelope['findings'] | Where-Object { $_['code'].StartsWith('DOCS_SCHEMA_', [System.StringComparison]::Ordinal) }).Count | Should -BeGreaterThan 0
        $parse.Outcome.ExitCode | Should -Be 1
        $parse.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_JSON_INVALID'
        $null -eq $parse.Result | Should -BeTrue
        $semanticRun.Outcome.ExitCode | Should -Be 1
        $null -eq $semanticRun.Result | Should -BeFalse -Because 'a profile with a semantic finding still loads and yields a fail receipt'
        $semanticRun.Result['validation_result'] | Should -BeExactly 'fail'
    }

    It 'exits 2 for a missing Mode, an invalid Revision and an unknown option before any read' {
        foreach ($arguments in @(, @('-Revision', $script:Revision)), @(, @('-Mode', 'ledger')), @(, @('-Mode', 'ledger', '-Revision', 'ABC')), @(, @('-Mode', 'ledger', '-Revision', $script:Revision, '-Unknown', 'x')), @(, @('-Mode', 'all', '-Revision', $script:Revision)), @(, @('-Mode', 'ledger', '-Revision', $script:Revision, '-Profile', '/abs.json'))) {
            # Arrange
            $test = New-DocsLedgerTestContext -File $script:Files

            # Act
            $run = Invoke-TestValidate -Argument $arguments[0] -Test $test

            # Assert
            $run.Outcome.ExitCode | Should -Be 2 -Because ($arguments[0] -join ' ')
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
            $null -eq $run.Result | Should -BeTrue
            $test.CallLog.Count | Should -Be 0
        }
    }

    It 'exits 3 for an injected read failure, a receipt write failure and a non-UTC clock' {
        # Arrange
        $readFail = New-DocsLedgerTestContext -File $script:Files -ReadBytesFailure @{ 'estate/docs-parity-matrix.json' = 'permission denied' }
        $writeFail = New-DocsLedgerTestContext -File $script:Files -WriteTextFailure @{ $script:ReceiptPath = 'disk full' }
        $local = New-DocsLedgerTestContext -File $script:Files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Local))

        # Act
        $readRun = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $readFail
        $writeRun = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $writeFail
        $clockRun = Invoke-TestValidate -Argument @('-Mode', 'profile', '-Revision', $script:Revision) -Test $local

        # Assert
        foreach ($run in @($readRun, $writeRun, $clockRun)) {
            $run.Outcome.ExitCode | Should -Be 3
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
            $null -eq $run.Result | Should -BeTrue
            $run.Outcome.Stderr | Should -Match 'exit 3'
        }
        $readRun.Envelope['findings'][0]['message'].Contains('permission denied', [System.StringComparison]::Ordinal) | Should -BeTrue
        $writeRun.Envelope['findings'][0]['message'].Contains('disk full', [System.StringComparison]::Ordinal) | Should -BeTrue
        $writeRun.Envelope['findings'][0]['artifact_path'] | Should -BeExactly $script:ReceiptPath
        $writeRun.Envelope['findings'][0]['related_paths'] | Should -Be @($script:ReceiptPath)
        $clockRun.Envelope['findings'][0]['message'].Contains('DOCS_CLOCK_NOT_UTC', [System.StringComparison]::Ordinal) | Should -BeTrue
        $local.CallLog.Count | Should -Be 0
    }

    It 'emits schema-valid byte-identical Json envelopes' {
        # Arrange
        $cases = @(
            @{ Argument = @('-Mode', 'docs-complete', '-Revision', $script:Revision); Files = $script:Files; Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Mode', 'docs-complete', '-Revision', ('f' * 40)); Files = $script:Files; Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Mode', 'docs-complete'); Files = $script:Files; Clock = [System.DateTimeKind]::Utc }
            @{ Argument = @('-Mode', 'profile', '-Revision', $script:Revision); Files = $script:Files; Clock = [System.DateTimeKind]::Local }
        )

        # Act and Assert
        $codes = foreach ($case in $cases) {
            $run = Invoke-TestValidate -Argument $case.Argument -Test (New-DocsLedgerTestContext -File $case.Files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, $case.Clock)))
            (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $run.Outcome.Stdout -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because ($case.Argument -join ' ')
            $run.Envelope['command'] | Should -BeExactly 'validate'
            $run.Envelope['ok'] | Should -Be ($run.Outcome.ExitCode -eq 0)
            $run.Outcome.ExitCode
        }
        @($codes) | Should -Be @(0, 1, 2, 3)
        $first = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test (New-DocsLedgerTestContext -File $script:Files)
        $second = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test (New-DocsLedgerTestContext -File $script:Files)
        $first.Outcome.Stdout | Should -BeExactly $second.Outcome.Stdout
        (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $first.Result) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
    }

    It 'prints the summary line without Json' {
        # Act
        $pass = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test (New-DocsLedgerTestContext -File $script:Files) -Text
        $fail = Invoke-TestValidate -Argument @('-Mode', 'ledger', '-Revision', ('f' * 40)) -Test (New-DocsLedgerTestContext -File $script:Files) -Text

        # Assert
        $passLines = @($pass.Outcome.Stdout.TrimEnd("`n") -split "`n")
        $passLines[0] | Should -Match '^receipt docs-validation-receipt-[0-9a-f]{64} docs-complete pass$'
        $passLines[1] | Should -BeExactly "created $($script:ReceiptPath)"
        $passLines[-1] | Should -BeExactly 'validate: exit=0 errors=0 warnings=0 infos=0'
        $failLines = @($fail.Outcome.Stdout.TrimEnd("`n") -split "`n")
        $failLines[0] | Should -Match '^error DOCS_REVISION_MISMATCH estate/surface-inventory-snapshot.json/revision: '
        $failLines[-1] | Should -BeExactly 'validate: exit=1 errors=1 warnings=0 infos=0'
        $pass.Outcome.Stdout.Contains('{', [System.StringComparison]::Ordinal) | Should -BeFalse
    }
}
