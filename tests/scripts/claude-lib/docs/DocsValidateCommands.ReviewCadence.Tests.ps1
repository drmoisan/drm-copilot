#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the review-cadence wiring of Invoke-DocsValidateCommand in
    .claude/lib/docs/DocsValidateCommands.psm1 (issue #1220).

.DESCRIPTION
    Runs validate -Mode docs-complete through Invoke-DocsCommandCli over the recording in-memory
    context of DocsLedger.TestSupport.psm1 with a fixed UTC instant and in-memory page text: an
    overdue page reports DOCS_REVIEW_OVERDUE, the same page at its due date reports none,
    block_overdue_review decides the severity, the receipt result and the exit code, a page read
    failure exits 3, and a page under a documentation family derives its due date from the family
    interval. No file is written and no clock is read.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsFamilyCheck', 'DocsReviewCadence', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands', 'DocsValidateCommands', 'DocsReceiptRevision', 'DocsCompleteGate') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'
    $script:FamilyPage = 'docs/operations/runbook.md'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:HeadMap = @{ HEAD = $script:Revision }
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Overdue = [datetime]::new(2026, 4, 11, 8, 0, 0, [System.DateTimeKind]::Utc)
    $script:AtDueDate = [datetime]::new(2026, 4, 10, 8, 0, 0, [System.DateTimeKind]::Utc)
    $script:ExplicitPageText = "---`nowner: `"docs-team`"`nlast_reviewed: `"2026-01-10`"`nreview_due: `"2026-04-10`"`n---`n# Cli`n"
    $script:DerivedPageText = "---`nowner: `"docs-team`"`nlast_reviewed: `"2026-01-10`"`n---`n# Runbook`n"

    function Get-TestText {
        param([object] $Document)
        ConvertTo-DocsJsonText -Value $Document -Indented
    }

    function Get-TestProfile {
        # The fixture profile; BlockOverdueReview adds completion_gates.docs_complete.block_overdue_review.
        param([AllowNull()] [object] $BlockOverdueReview, [object[]] $RequiredFamily = @())
        $document = New-DocsLedgerTestProfile -RequiredFamily $RequiredFamily
        if ($null -ne $BlockOverdueReview) { $document['completion_gates']['docs_complete']['block_overdue_review'] = $BlockOverdueReview }
        $document
    }

    function Get-TestEstate {
        # The profile, snapshot, page and a consistent ledger, matrix and pin collection at a fixed instant.
        param(
            [System.Collections.IDictionary] $ProfileDocument,
            [datetime] $UtcNow,
            [string] $PageText = $script:ExplicitPageText,
            [System.Collections.IDictionary] $Extra = @{},
            [AllowNull()] [System.Collections.IDictionary] $ReadBytesFailure
        )
        $snapshot = New-DocsLedgerTestSnapshot
        $snapshotText = Get-TestText -Document $snapshot
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        $files = [ordered]@{
            $script:Page                             = $PageText
            'estate/surface-inventory-snapshot.json' = $snapshotText
            'estate/docs-coverage-ledger.json'       = (Get-TestText -Document $ledger)
            'estate/docs-parity-matrix.json'         = (Get-TestText -Document (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows))
            'estate/docs-evidence-pins.json'         = (Get-TestText -Document (New-DocsLedgerTestPinSet -Pin $pins))
            $script:ProfilePath                      = (Get-TestText -Document $ProfileDocument)
        }
        foreach ($path in $Extra.Keys) { $files[$path] = $Extra[$path] }
        New-DocsLedgerTestContext -RevisionMap $script:HeadMap -File $files -UtcNow $UtcNow -ReadBytesFailure $ReadBytesFailure
    }

    function Invoke-TestValidate {
        param([string[]] $Argument, [hashtable] $Test)
        $outcome = Invoke-DocsCommandCli -Command 'validate' -CommandArgument $Argument -Context $Test.Context -Json
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value
        @{ Outcome = $outcome; Envelope = $envelope; Result = $envelope['result'] }
    }

    function Get-TestCode {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsValidateCommand review cadence (docs-complete)' {
    It 'reports DOCS_REVIEW_OVERDUE whose message names source review_due on the day after the explicit due date' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile) -UtcNow $script:Overdue

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Result | Should -Not -BeNullOrEmpty -Because 'the profile loads and the receipt is produced'
        $overdue = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_REVIEW_OVERDUE'
        $overdue.Count | Should -Be 1
        $overdue[0]['message'] | Should -Match 'source review_due'
        $overdue[0]['message'] | Should -Match '2026-04-10'
        $overdue[0]['pointer'] | Should -BeExactly '/review_due'
        $overdue[0]['artifact_path'] | Should -BeExactly $script:Page
    }

    It 'reports no DOCS_REVIEW_OVERDUE when the command instant falls on the due date' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile) -UtcNow $script:AtDueDate

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result | Should -Not -BeNullOrEmpty
        (Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_REVIEW_OVERDUE').Count | Should -Be 0
    }

    It 'exits 1 with an error finding and writes a failing receipt when block_overdue_review is true' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile -BlockOverdueReview $true) -UtcNow $script:Overdue

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $test
        $decision = Test-DocsCompleteGateReceipt -ReceiptText $test.WriteLog[0].Text -HeadRevision $script:Revision -SnapshotRevision $script:Revision

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Result | Should -Not -BeNullOrEmpty
        $run.Result['validation_result'] | Should -BeExactly 'fail'
        $overdue = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_REVIEW_OVERDUE'
        $overdue.Count | Should -Be 1
        $overdue[0]['severity'] | Should -BeExactly 'error'
        (ConvertFrom-DocsJsonText -Text $test.WriteLog[0].Text).Value['validation_result'] | Should -BeExactly 'fail'
        $decision.Allow | Should -BeFalse
        $decision.Reason | Should -BeExactly 'RECEIPT_FAILING'
    }

    It 'exits 0 with a warning finding and a passing receipt when block_overdue_review is <Label>' -TestCases @(
        @{ Label = 'absent'; Block = $null }
        @{ Label = 'false'; Block = $false }
    ) {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile -BlockOverdueReview $Block) -UtcNow $script:Overdue

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result | Should -Not -BeNullOrEmpty
        $run.Result['validation_result'] | Should -BeExactly 'pass'
        $overdue = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_REVIEW_OVERDUE'
        $overdue.Count | Should -Be 1
        $overdue[0]['severity'] | Should -BeExactly 'warning'
        (ConvertFrom-DocsJsonText -Text $test.WriteLog[0].Text).Value['validation_result'] | Should -BeExactly 'pass'
    }

    It 'exits 3 with one DOCS_CLI_RUNTIME finding when the page read fails' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile) -UtcNow $script:Overdue -ReadBytesFailure @{ $script:Page = 'injected page read failure' }

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 3
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_RUNTIME')
        @($test.CallLog | Where-Object { $_.Member -ceq 'ReadText' -and $_.RelativePath -ceq $script:Page }).Count | Should -Be 1
    }
}

Describe 'Invoke-DocsValidateCommand review cadence with a documentation family (FamiliesState PRESENT)' {
    It 'reports DOCS_REVIEW_OVERDUE whose message names source interval for a page without review_due under a 90-day family' {
        # Arrange
        $family = [ordered]@{ id = 'operations'; directory = 'docs/operations'; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('maintainers'); review_interval_days = 90L; required = $true }
        $test = Get-TestEstate -ProfileDocument (Get-TestProfile -RequiredFamily @($family)) -UtcNow $script:Overdue -PageText '# Cli' -Extra @{ $script:FamilyPage = $script:DerivedPageText }

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Result | Should -Not -BeNullOrEmpty -Because 'the profile with a family record loads'
        $overdue = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_REVIEW_OVERDUE'
        $overdue.Count | Should -Be 1
        $overdue[0]['message'] | Should -Match 'source interval'
        $overdue[0]['message'] | Should -Match '2026-04-10'
        $overdue[0]['pointer'] | Should -BeExactly '/last_reviewed'
        $overdue[0]['artifact_path'] | Should -BeExactly $script:FamilyPage
    }
}
