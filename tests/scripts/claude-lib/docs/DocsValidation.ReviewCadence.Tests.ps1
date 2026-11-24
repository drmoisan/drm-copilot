#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the review cadence check of Invoke-DocsValidation in
    .claude/lib/docs/DocsValidation.psm1 (issue #1220).

.DESCRIPTION
    Runs Invoke-DocsValidation over a consistent in-memory docs-complete set from
    DocsLedger.TestSupport.psm1 with in-memory page front matter: DOCS_REVIEW_OVERDUE is reported
    only in docs-complete mode and only with -PageFrontMatter, its severity follows
    completion_gates.docs_complete.block_overdue_review, and a failing receipt is denied by
    Test-DocsCompleteGateReceipt as RECEIPT_FAILING. The family cases run because the profile
    schema declares required_families and legacy_exclusions (upstream verification state
    PRESENT). Every case asserts a non-null receipt before it asserts on findings. No file is
    written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsFamilyCheck', 'DocsReviewCadence', 'DocsValidation', 'DocsReceiptRevision', 'DocsCompleteGate') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:PinnedAt = '2026-03-01T12:00:00Z'
    $script:IssuedAt = '2026-04-11T08:00:00Z'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Page = 'docs/reference/Cli.md'
    $script:GuidePage = 'docs/guide/page.md'
    $script:Runbook = 'docs/operations/runbook.md'
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestByte {
        param([object] $Document)
        , $script:Utf8.GetBytes((ConvertTo-DocsJsonText -Value $Document -Indented))
    }

    function Get-TestArtifact {
        # A consistent snapshot, ledger, matrix and pin collection: every element documented on the page.
        $snapshot = New-DocsLedgerTestSnapshot
        $bytes = Get-TestByte -Document $snapshot
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $script:Utf8.GetString($bytes)).Value -SnapshotSha256 (Get-DocsBytesSha256Hex -Bytes $bytes)
        $entries = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
        $pins = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:PinnedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        $matrix = New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $ledger)) -Row $rows
        [ordered]@{
            'surface-inventory-snapshot' = @{ Path = 'estate/surface-inventory-snapshot.json'; Bytes = $bytes }
            'docs-coverage-ledger'       = @{ Path = 'estate/docs-coverage-ledger.json'; Bytes = (Get-TestByte -Document $ledger) }
            'docs-parity-matrix'         = @{ Path = 'estate/docs-parity-matrix.json'; Bytes = (Get-TestByte -Document $matrix) }
            'docs-evidence-pin'          = @{ Path = 'estate/docs-evidence-pins.json'; Bytes = (Get-TestByte -Document (New-DocsLedgerTestPinSet -Pin $pins)) }
        }
    }

    function Get-TestProfile {
        # The fixture profile; Block adds block_overdue_review with that value.
        param([object] $Block, [object[]] $RequiredFamily = @(), [object[]] $LegacyExclusion = @())
        $document = New-DocsLedgerTestProfile -RequiredFamily $RequiredFamily -LegacyExclusion $LegacyExclusion
        if ($PSBoundParameters.ContainsKey('Block')) { $document['completion_gates']['docs_complete']['block_overdue_review'] = $Block }
        $document
    }

    function Get-TestPageMap {
        # One page with last_reviewed 2026-01-10 and, unless NoReviewDue, review_due 2026-04-10.
        param([string] $PagePath = $script:GuidePage, [switch] $NoReviewDue)
        $frontMatter = @{ owner = 'team-docs'; last_reviewed = '2026-01-10' }
        if (-not $NoReviewDue) { $frontMatter['review_due'] = '2026-04-10' }
        @{ $PagePath = $frontMatter }
    }

    function Invoke-TestValidation {
        param([string] $Mode = 'docs-complete', [System.Collections.IDictionary] $ProfileDocument, [object] $PageFrontMatter, [switch] $OmitPageFrontMatter, [object] $FamilyEvidence)
        $parameters = @{
            Mode              = $Mode
            Revision          = $script:Revision
            IssuedAt          = $script:IssuedAt
            ProfileText       = (ConvertTo-DocsJsonText -Value $ProfileDocument)
            ProfilePath       = $script:ProfilePath
            Artifact          = $script:Artifact
            PagePath          = @($script:Page)
            ComposedSchemaSet = $script:Composed
            FamilyEvidence    = $FamilyEvidence
        }
        if (-not $OmitPageFrontMatter) { $parameters['PageFrontMatter'] = $PageFrontMatter }
        Invoke-DocsValidation @parameters
    }

    function Get-TestOverdue {
        param([object[]] $Finding)
        , @($Finding | Where-Object { $_['code'] -ceq 'DOCS_REVIEW_OVERDUE' })
    }
}

AfterAll {
    foreach ($name in 'Get-TestByte', 'Get-TestArtifact', 'Get-TestProfile', 'Get-TestPageMap', 'Invoke-TestValidation', 'Get-TestOverdue') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'DocsReviewCadence' -Force -ErrorAction SilentlyContinue
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsValidation review cadence' {
    BeforeAll {
        $script:Artifact = Get-TestArtifact
    }

    It 'reports no DOCS_REVIEW_OVERDUE in the <_> mode' -ForEach @('profile', 'ledger', 'matrix') {
        # Act
        $result = Invoke-TestValidation -Mode $_ -ProfileDocument (Get-TestProfile) -PageFrontMatter (Get-TestPageMap)

        # Assert
        $result.Receipt | Should -Not -BeNullOrEmpty
        (Get-TestOverdue -Finding $result.Findings).Count | Should -Be 0
    }

    It 'reports no DOCS_REVIEW_OVERDUE when -PageFrontMatter is omitted' {
        # Act
        $result = Invoke-TestValidation -ProfileDocument (Get-TestProfile) -OmitPageFrontMatter

        # Assert
        $result.Receipt | Should -Not -BeNullOrEmpty
        (Get-TestOverdue -Finding $result.Findings).Count | Should -Be 0
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'reports a warning and keeps pass when block_overdue_review is <Case>' -ForEach @(
        @{ Case = 'absent'; Absent = $true; Block = $null }
        @{ Case = 'false'; Absent = $false; Block = $false }
    ) {
        # Arrange
        $profileDocument = if ($Absent) { Get-TestProfile } else { Get-TestProfile -Block $Block }

        # Act
        $result = Invoke-TestValidation -ProfileDocument $profileDocument -PageFrontMatter (Get-TestPageMap)

        # Assert
        $result.Receipt | Should -Not -BeNullOrEmpty
        $overdue = Get-TestOverdue -Finding $result.Findings
        $overdue.Count | Should -Be 1
        $overdue[0]['severity'] | Should -BeExactly 'warning'
        $overdue[0]['pointer'] | Should -BeExactly '/review_due'
        $overdue[0]['artifact_path'] | Should -BeExactly $script:GuidePage
        $result.Ok | Should -BeTrue
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'reports an error and fails the receipt when block_overdue_review is true, and the gate denies it as RECEIPT_FAILING' {
        # Act
        $result = Invoke-TestValidation -ProfileDocument (Get-TestProfile -Block $true) -PageFrontMatter (Get-TestPageMap)

        # Assert
        $result.Receipt | Should -Not -BeNullOrEmpty
        $overdue = Get-TestOverdue -Finding $result.Findings
        $overdue.Count | Should -Be 1
        $overdue[0]['severity'] | Should -BeExactly 'error'
        $result.Ok | Should -BeFalse
        $result.Receipt['validation_result'] | Should -BeExactly 'fail'
        @($result.Findings | Where-Object { $_['severity'] -ceq 'error' } | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_REVIEW_OVERDUE')
        $decision = Test-DocsCompleteGateReceipt -ReceiptText (ConvertTo-DocsJsonText -Value $result.Receipt -Indented) -HeadRevision $script:Revision -SnapshotRevision $script:Revision
        $decision.Allow | Should -BeFalse
        $decision.Reason | Should -BeExactly 'RECEIPT_FAILING'
    }

    It 'reports nothing for a page without review_due under a profile without required_families' {
        # Act
        $result = Invoke-TestValidation -ProfileDocument (Get-TestProfile) -PageFrontMatter (Get-TestPageMap -PagePath $script:Runbook -NoReviewDue)

        # Assert
        $result.Receipt | Should -Not -BeNullOrEmpty
        (Get-TestOverdue -Finding $result.Findings).Count | Should -Be 0
    }

    Context 'documentation families (FamiliesState PRESENT)' {
        BeforeAll {
            $script:Family = [ordered]@{ id = 'operations'; directory = 'docs/operations'; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('maintainers'); review_interval_days = 90L; required = $true }
            $context = (New-DocsLedgerTestContext -File @{ $script:Runbook = '# Runbook' }).Context
            $script:Evidence = Read-DocsFamilyEvidence -Profile (Get-TestProfile -RequiredFamily @($script:Family)) -TestFile $context.TestFile -ListFile $context.ListFile
        }

        It 'reports DOCS_REVIEW_OVERDUE at /last_reviewed for a page whose due date derives from the family interval' {
            # Act
            $result = Invoke-TestValidation -ProfileDocument (Get-TestProfile -RequiredFamily @($script:Family)) -PageFrontMatter (Get-TestPageMap -PagePath $script:Runbook -NoReviewDue) -FamilyEvidence $script:Evidence

            # Assert
            $result.Receipt | Should -Not -BeNullOrEmpty
            $overdue = Get-TestOverdue -Finding $result.Findings
            $overdue.Count | Should -Be 1
            $overdue[0]['pointer'] | Should -BeExactly '/last_reviewed'
            $overdue[0]['artifact_path'] | Should -BeExactly $script:Runbook
            $overdue[0]['message'] | Should -BeLike '*source interval*'
        }

        It 'reports nothing for the same page listed in legacy_exclusions (LegacyExclusionsState PRESENT)' {
            # Arrange
            $profileDocument = Get-TestProfile -RequiredFamily @($script:Family) -LegacyExclusion @([ordered]@{ path = $script:Runbook; reason = 'Kept for history.' })

            # Act
            $result = Invoke-TestValidation -ProfileDocument $profileDocument -PageFrontMatter (Get-TestPageMap -PagePath $script:Runbook -NoReviewDue) -FamilyEvidence $script:Evidence

            # Assert
            $result.Receipt | Should -Not -BeNullOrEmpty
            (Get-TestOverdue -Finding $result.Findings).Count | Should -Be 0
        }
    }
}
