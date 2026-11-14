#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsValidation.psm1.

.DESCRIPTION
    Covers the profile and ledger layers of Invoke-DocsValidation over in-memory inputs from
    DocsLedger.TestSupport.psm1: profile findings, the null receipt, absent inputs, schema
    findings, the revision rule, the unbounded finding set, the receipt defect guard and
    schema-valid receipts pinned to the revision. Assertions use codes, pointers, severities and
    identifiers, never Test-Json message text. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)
    $script:Paths = @{
        'surface-inventory-snapshot' = 'estate/surface-inventory-snapshot.json'
        'docs-coverage-ledger'       = 'estate/docs-coverage-ledger.json'
        'docs-parity-matrix'         = 'estate/docs-parity-matrix.json'
        'docs-evidence-pin'          = 'estate/docs-evidence-pins.json'
    }

    function Get-TestByte {
        param([object] $Document)
        , $script:Utf8.GetBytes((ConvertTo-DocsJsonText -Value $Document -Indented))
    }

    function Get-TestArtifact {
        # Builds the Artifact map of Invoke-DocsValidation; an omitted document is an absent artifact.
        param([object] $Snapshot, [object] $Ledger, [object] $Matrix, [object] $PinSet, [object] $ProfileDocument)
        $map = [ordered]@{}
        if ($null -ne $ProfileDocument) { $map['docs-profile'] = @{ Path = $script:ProfilePath; Bytes = (Get-TestByte -Document $ProfileDocument) } }
        $map['surface-inventory-snapshot'] = $(if ($null -eq $Snapshot) { $null } else { @{ Path = $script:Paths['surface-inventory-snapshot']; Bytes = (Get-TestByte -Document $Snapshot) } })
        $map['docs-coverage-ledger'] = $(if ($null -eq $Ledger) { $null } else { @{ Path = $script:Paths['docs-coverage-ledger']; Bytes = (Get-TestByte -Document $Ledger) } })
        $map['docs-parity-matrix'] = $(if ($null -eq $Matrix) { $null } else { @{ Path = $script:Paths['docs-parity-matrix']; Bytes = (Get-TestByte -Document $Matrix) } })
        $map['docs-evidence-pin'] = $(if ($null -eq $PinSet) { $null } else { @{ Path = $script:Paths['docs-evidence-pin']; Bytes = (Get-TestByte -Document $PinSet) } })
        $map
    }

    function Get-TestView {
        param([object] $Snapshot)
        $bytes = Get-TestByte -Document $Snapshot
        ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $script:Utf8.GetString($bytes)).Value -SnapshotSha256 (Get-DocsBytesSha256Hex -Bytes $bytes)
    }

    function Get-TestCompleteLedger {
        # A documented entry per element plus the precision-limit entry, with the snapshot bytes digest.
        param([object] $Snapshot, [string] $PagePath = 'docs/reference/Cli.md')
        $view = Get-TestView -Snapshot $Snapshot
        $entries = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $PagePath; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
    }

    function Get-TestCompleteSet {
        # A consistent ledger, matrix, pin collection and profile over the snapshot: every element documented on
        # PagePath with a current pin, the required dimensions pass, the precision limit deferred.
        param([object] $Snapshot, [bool] $AllowDeferred = $true, [long] $MaxStalePages = 0, [string] $PagePath = 'docs/reference/Cli.md', [string[]] $RequiredDimension = @('exists', 'accurate', 'owner_assigned'))
        $view = Get-TestView -Snapshot $Snapshot
        $ledger = Get-TestCompleteLedger -Snapshot $Snapshot -PagePath $PagePath
        $ledgerSha256 = Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $ledger)
        $pins = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $PagePath -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $PagePath -Dimension $dimension
            })
        @{
            View    = $view
            Ledger  = $ledger
            Matrix  = (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 $ledgerSha256 -Row $rows)
            PinSet  = (New-DocsLedgerTestPinSet -Pin $pins)
            Profile = (New-DocsLedgerTestProfile -AllowDeferred $AllowDeferred -MaxStalePages $MaxStalePages -RequiredParityDimension $RequiredDimension)
        }
    }

    function Invoke-TestSet {
        param([string] $Mode, [hashtable] $Set, [object] $Snapshot, [string] $Revision = $script:Revision, [string[]] $PagePath = @('docs/reference/Cli.md'))
        Invoke-TestValidation -Mode $Mode -Artifact (Get-TestArtifact -Snapshot $Snapshot -Ledger $Set.Ledger -Matrix $Set.Matrix -PinSet $Set.PinSet -ProfileDocument $Set.Profile) -Revision $Revision -ProfileDocument $Set.Profile -PagePath $PagePath
    }

    function Invoke-TestValidation {
        param([string] $Mode, [System.Collections.IDictionary] $Artifact, [string] $Revision = $script:Revision, [object] $ProfileDocument, [string[]] $PagePath = @('docs/reference/Cli.md'))
        $document = if ($null -eq $ProfileDocument) { New-DocsLedgerTestProfile } else { $ProfileDocument }
        Invoke-DocsValidation -Mode $Mode -Revision $Revision -IssuedAt $script:IssuedAt -ProfileText (ConvertTo-DocsJsonText -Value $document) -ProfilePath $script:ProfilePath -Artifact $Artifact -PagePath $PagePath -ComposedSchemaSet $script:Composed
    }

    function Get-TestCode {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }

    function Get-TestReceiptFindingCount {
        param([object] $Receipt)
        (Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $Receipt) -ComposedSchemaSet $script:Composed).Count
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsValidation profile and ledger layers' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Ledger = Get-TestCompleteLedger -Snapshot $script:Snapshot
    }

    It 'profile mode returns ConvertFrom-DocsProfileText findings' {
        # Arrange
        $broken = New-DocsLedgerTestProfile
        $broken['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators')

        # Act
        $result = Invoke-TestValidation -Mode 'profile' -Artifact (Get-TestArtifact -ProfileDocument $broken) -ProfileDocument $broken
        $clean = Invoke-TestValidation -Mode 'profile' -Artifact (Get-TestArtifact)

        # Assert
        $result.Ok | Should -BeFalse
        (Get-TestCode -Finding $result.Findings -Code 'DOCS_PROFILE_AUDIENCE_UNKNOWN').Count | Should -Be 1
        $result.Receipt['validation_result'] | Should -BeExactly 'fail'
        $result.Receipt['mode'] | Should -BeExactly 'profile'
        $result.Receipt['inputs'].Count | Should -Be 1
        $result.Receipt['inputs'][0]['artifact_kind'] | Should -BeExactly 'docs-profile'
        $clean.Ok | Should -BeTrue
        $clean.Findings.Count | Should -Be 0
        $clean.Receipt['inputs'].Count | Should -Be 0 -Because 'no artifact entry was supplied for the profile'
        $clean.Receipt['counts']['elements_total'] | Should -Be 0 -Because 'profile mode reads no snapshot'
    }

    It 'returns a null receipt when the profile does not load' {
        # Arrange
        $missing = New-DocsLedgerTestProfile
        $missing.Remove('audiences')

        # Act
        $schema = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger) -ProfileDocument $missing
        $parse = Invoke-DocsValidation -Mode 'ledger' -Revision $script:Revision -IssuedAt $script:IssuedAt -ProfileText '{"id":' -ProfilePath $script:ProfilePath -Artifact (Get-TestArtifact) -PagePath @() -ComposedSchemaSet $script:Composed

        # Assert
        $null -eq $schema.Receipt | Should -BeTrue
        $schema.Ok | Should -BeFalse
        (Get-TestCode -Finding $schema.Findings -Code 'DOCS_SCHEMA_REQUIRED_MISSING').Count | Should -BeGreaterThan 0
        $null -eq $parse.Receipt | Should -BeTrue
        $parse.Findings[0]['code'] | Should -BeExactly 'DOCS_JSON_INVALID'
    }

    It 'reports DOCS_INPUT_UNREADABLE for an absent snapshot or ledger' {
        # Act
        $noSnapshot = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Ledger $script:Ledger)
        $noLedger = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot)
        $profileOnly = Invoke-TestValidation -Mode 'profile' -Artifact (Get-TestArtifact)

        # Assert
        $noSnapshot.Ok | Should -BeFalse
        $snapshotFinding = Get-TestCode -Finding $noSnapshot.Findings -Code 'DOCS_INPUT_UNREADABLE'
        $snapshotFinding.Count | Should -Be 1
        $snapshotFinding[0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $snapshotFinding[0]['severity'] | Should -BeExactly 'error'
        $noSnapshot.Receipt['inputs'].Count | Should -Be 1 -Because 'only the ledger was read'
        $ledgerFinding = Get-TestCode -Finding $noLedger.Findings -Code 'DOCS_INPUT_UNREADABLE'
        $ledgerFinding.Count | Should -Be 1
        $ledgerFinding[0]['artifact_path'] | Should -BeExactly 'estate/docs-coverage-ledger.json'
        $noLedger.Receipt['counts']['elements_total'] | Should -Be 6
        $noLedger.Receipt['counts']['undocumented'] | Should -Be 6
        $profileOnly.Ok | Should -BeTrue -Because 'profile mode needs no snapshot or ledger'
    }

    It 'reports schema findings for a schema-invalid ledger' {
        # Arrange
        $invalid = Get-TestCompleteLedger -Snapshot $script:Snapshot
        $invalid['entries'][0]['disposition'] = 'unknown'
        $badSnapshot = New-DocsLedgerTestSnapshot
        $badSnapshot.Remove('analyzers')

        # Act
        $result = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $invalid)
        $snapshotResult = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $badSnapshot -Ledger $script:Ledger)

        # Assert
        $result.Ok | Should -BeFalse
        $schemaFinding = @($result.Findings | Where-Object { $_['code'].StartsWith('DOCS_SCHEMA_', [System.StringComparison]::Ordinal) })
        $schemaFinding.Count | Should -BeGreaterThan 0
        $schemaFinding[0]['artifact_path'] | Should -BeExactly 'estate/docs-coverage-ledger.json'
        (Get-TestCode -Finding $result.Findings -Code 'DOCS_LEDGER_MISSING_DISPOSITION').Count | Should -Be 0 -Because 'the ledger rules do not run over a schema-invalid ledger'
        $result.Receipt['counts']['by_disposition']['documented'] | Should -Be 0
        $snapshotResult.Ok | Should -BeFalse
        @($snapshotResult.Findings | Where-Object { $_['artifact_path'] -ceq 'estate/surface-inventory-snapshot.json' -and $_['code'].StartsWith('DOCS_SCHEMA_', [System.StringComparison]::Ordinal) }).Count | Should -BeGreaterThan 0
        $snapshotResult.Receipt['counts']['elements_total'] | Should -Be 0 -Because 'no view is built from a schema-invalid snapshot'
    }

    It 'reports DOCS_REVISION_MISMATCH for a differing non-null snapshot revision' {
        # Arrange
        $unpinned = New-DocsLedgerTestSnapshot -NoRevision

        # Act
        $mismatch = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger) -Revision ('f' * 40)
        $longer = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger) -Revision ($script:Revision + ('0' * 24))
        $same = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger)
        $nullRevision = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $unpinned -Ledger (Get-TestCompleteLedger -Snapshot $unpinned)) -Revision ('f' * 40)

        # Assert
        $finding = Get-TestCode -Finding $mismatch.Findings -Code 'DOCS_REVISION_MISMATCH'
        $finding.Count | Should -Be 1
        $finding[0]['severity'] | Should -BeExactly 'error'
        $finding[0]['pointer'] | Should -BeExactly '/revision'
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $mismatch.Receipt['revision'] | Should -BeExactly ('f' * 40) -Because 'the receipt pins the validated revision'
        (Get-TestCode -Finding $longer.Findings -Code 'DOCS_REVISION_MISMATCH').Count | Should -Be 1 -Because 'a 64-character revision sharing the 40-character prefix is a different revision'
        (Get-TestCode -Finding $same.Findings -Code 'DOCS_REVISION_MISMATCH').Count | Should -Be 0
        $same.Ok | Should -BeTrue
        (Get-TestCode -Finding $nullRevision.Findings -Code 'DOCS_REVISION_MISMATCH').Count | Should -Be 0 -Because 'a null snapshot revision is not a mismatch in ledger mode'
        $nullRevision.Ok | Should -BeTrue
    }

    It 'fails validation_result on an error beyond the finding bound' {
        # Arrange: 101 analysis-method warnings on the ledger path sort before one error on the snapshot path.
        $elements = @(for ($index = 0; $index -lt 101; $index++) { New-DocsSurfaceElement -Kind 'public-symbol' -Path 'src/app/Many.psm1' -Declaration "function Get-Thing$index" -Name "Get-Thing$index" -AnalyzerId 'fixture-native' -AnalysisMethod 'native' -SourceText "function Get-Thing$index`n" -LineRange @(1, 1) })
        $snapshot = New-DocsLedgerTestSnapshot -Element $elements -Diagnostic @()
        $view = Get-TestView -Snapshot $snapshot
        $entries = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { $entry = New-DocsLedgerTestEntry -Element $view.Element[$id]; $entry['analysis_method'] = 'scanner'; $entry })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries

        # Act
        $result = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $snapshot -Ledger $ledger) -Revision ('f' * 40)
        $bounded = Get-DocsOrderedFinding -Finding $result.Findings -Limit 100

        # Assert
        $result.Ok | Should -BeFalse
        $result.Receipt['validation_result'] | Should -BeExactly 'fail'
        $result.Findings.Count | Should -BeGreaterThan 101
        $result.Receipt['findings'].Count | Should -Be $result.Findings.Count -Because 'the receipt carries the unbounded ordered set'
        (Get-TestCode -Finding $result.Findings -Code 'FINDINGS_LIMIT').Count | Should -Be 0
        @($bounded | Where-Object { $_['severity'] -ceq 'error' -and $_['code'] -cne 'FINDINGS_LIMIT' }).Count | Should -Be 0 -Because 'the only error sorts beyond the default bound of 100'
        (Get-TestCode -Finding $result.Findings -Code 'DOCS_REVISION_MISMATCH').Count | Should -Be 1
        Get-TestReceiptFindingCount -Receipt $result.Receipt | Should -Be 0
    }

    It 'raises the receipt defect guard for a receipt that fails its schema' {
        # Act and Assert
        { Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger) -Revision 'not-a-revision' } | Should -Throw -ExpectedMessage 'DOCS_RECEIPT_INVALID*'
        { Invoke-TestValidation -Mode 'other' -Artifact (Get-TestArtifact) } | Should -Throw -ExpectedMessage 'DOCS_VALIDATION_INPUT_INVALID*'
    }

    It 'returns a schema-valid receipt pinned to the revision in profile and ledger modes on pass and fail' {
        # Arrange
        $broken = New-DocsLedgerTestProfile
        $broken['documentation_roots'][0]['audience_ids'] = @('maintainers', 'operators')
        $incomplete = New-DocsLedgerTestLedger -SnapshotSha256 ('a' * 64) -Entry @()
        $revision = 'f' * 64

        # Act
        $profilePass = Invoke-TestValidation -Mode 'profile' -Artifact (Get-TestArtifact -ProfileDocument (New-DocsLedgerTestProfile)) -Revision $revision
        $profileFail = Invoke-TestValidation -Mode 'profile' -Artifact (Get-TestArtifact -ProfileDocument $broken) -ProfileDocument $broken -Revision $revision
        $ledgerPass = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $script:Ledger -ProfileDocument (New-DocsLedgerTestProfile))
        $ledgerFail = Invoke-TestValidation -Mode 'ledger' -Artifact (Get-TestArtifact -Snapshot $script:Snapshot -Ledger $incomplete -ProfileDocument (New-DocsLedgerTestProfile))

        # Assert
        foreach ($result in @($profilePass, $profileFail, $ledgerPass, $ledgerFail)) {
            Get-TestReceiptFindingCount -Receipt $result.Receipt | Should -Be 0
            $result.Receipt['issued_at'] | Should -BeExactly $script:IssuedAt
            $result.Receipt['repository'] | Should -BeExactly 'fixture-repo'
        }
        $profilePass.Receipt['revision'] | Should -BeExactly $revision
        $profileFail.Receipt['revision'] | Should -BeExactly $revision
        $ledgerPass.Receipt['revision'] | Should -BeExactly $script:Revision
        $ledgerFail.Receipt['revision'] | Should -BeExactly $script:Revision
        $profilePass.Receipt['validation_result'] | Should -BeExactly 'pass'
        $profileFail.Receipt['validation_result'] | Should -BeExactly 'fail'
        $ledgerPass.Receipt['validation_result'] | Should -BeExactly 'pass'
        $ledgerPass.Ok | Should -BeTrue
        $ledgerPass.Receipt['counts']['by_disposition']['documented'] | Should -Be 6
        @($ledgerPass.Receipt['inputs'] | ForEach-Object { $_['artifact_kind'] }) | Should -Be @('docs-coverage-ledger', 'docs-profile', 'surface-inventory-snapshot')
        $ledgerPass.Receipt['inputs'][2]['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $script:Snapshot))
        $ledgerFail.Receipt['validation_result'] | Should -BeExactly 'fail'
        (Get-TestCode -Finding $ledgerFail.Findings -Code 'DOCS_LEDGER_MISSING_DISPOSITION').Count | Should -Be 6
        (Get-TestCode -Finding $ledgerFail.Findings -Code 'DOCS_LEDGER_LIMIT_UNRECORDED').Count | Should -Be 1
        (Get-TestCode -Finding $ledgerFail.Findings -Code 'DOCS_LEDGER_SNAPSHOT_REF').Count | Should -Be 1
    }
}

Describe 'Invoke-DocsValidation matrix and docs-complete layers' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Complete = Get-TestCompleteSet -Snapshot $script:Snapshot
    }

    It 'matrix mode reports DOCS_STALE_PAGE as a warning' {
        # Arrange
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.PinSet['pins'][0]['source_sha256'] = '0' * 64

        # Act
        $stale = Invoke-TestSet -Mode 'matrix' -Set $set -Snapshot $script:Snapshot
        $clean = Invoke-TestSet -Mode 'matrix' -Set $script:Complete -Snapshot $script:Snapshot
        $gate = Invoke-TestSet -Mode 'docs-complete' -Set $set -Snapshot $script:Snapshot

        # Assert
        $finding = Get-TestCode -Finding $stale.Findings -Code 'DOCS_STALE_PAGE'
        $finding.Count | Should -Be 1
        $finding[0]['severity'] | Should -BeExactly 'warning'
        $finding[0]['related_paths'] | Should -Be @('docs/reference/Cli.md')
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/docs-evidence-pins.json'
        $stale.Ok | Should -BeTrue
        $stale.Receipt['counts']['stale_pages'] | Should -Be 1
        $stale.Receipt['validation_result'] | Should -BeExactly 'pass'
        $clean.Findings.Count | Should -Be 0
        $clean.Receipt['counts']['stale_pages'] | Should -Be 0
        (Get-TestCode -Finding $gate.Findings -Code 'DOCS_STALE_PAGE')[0]['severity'] | Should -BeExactly 'error' -Because 'docs-complete with max_stale_pages 0 makes the stale page an error'
    }

    It 'reports DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete' {
        # Arrange
        $unpinned = New-DocsLedgerTestSnapshot -NoRevision
        $set = Get-TestCompleteSet -Snapshot $unpinned

        # Act
        $complete = Invoke-TestSet -Mode 'docs-complete' -Set $set -Snapshot $unpinned
        $matrix = Invoke-TestSet -Mode 'matrix' -Set $set -Snapshot $unpinned
        $pinned = Invoke-TestSet -Mode 'docs-complete' -Set $script:Complete -Snapshot $script:Snapshot

        # Assert
        $finding = Get-TestCode -Finding $complete.Findings -Code 'DOCS_SNAPSHOT_UNPINNED'
        $finding.Count | Should -Be 1
        $finding[0]['severity'] | Should -BeExactly 'error'
        $finding[0]['pointer'] | Should -BeExactly '/revision'
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $complete.Ok | Should -BeFalse
        $complete.Receipt['revision'] | Should -BeExactly $script:Revision
        (Get-TestCode -Finding $matrix.Findings -Code 'DOCS_SNAPSHOT_UNPINNED').Count | Should -Be 0 -Because 'matrix mode applies no completion gate'
        $matrix.Ok | Should -BeTrue
        (Get-TestCode -Finding $pinned.Findings -Code 'DOCS_SNAPSHOT_UNPINNED').Count | Should -Be 0
        $pinned.Ok | Should -BeTrue
    }

    It 'reports DOCS_PARITY_REQUIRED_DIMENSION for fail and not-assessed' {
        # Arrange
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $rows = $set.Matrix['rows']
        $rows[0]['dimensions']['accurate']['state'] = 'fail'
        $rows[0]['dimensions']['accurate']['rationale'] = 'The page describes an older signature.'
        $rows[1]['dimensions']['exists']['state'] = 'not-assessed'
        $rows[2]['dimensions']['example_present']['state'] = 'fail'
        $rows[2]['dimensions']['example_present']['rationale'] = 'No example yet.'
        $rows[3]['dimensions']['owner_assigned']['state'] = 'not-applicable'
        $rows[3]['dimensions']['owner_assigned']['rationale'] = 'Generated page.'

        # Act
        $result = Invoke-TestSet -Mode 'docs-complete' -Set $set -Snapshot $script:Snapshot
        $matrix = Invoke-TestSet -Mode 'matrix' -Set $set -Snapshot $script:Snapshot

        # Assert
        $finding = Get-TestCode -Finding $result.Findings -Code 'DOCS_PARITY_REQUIRED_DIMENSION'
        $finding.Count | Should -Be 2 -Because 'example_present is not required and not-applicable passes the gate'
        @($finding | ForEach-Object { $_['pointer'] } | Sort-Object) | Should -Be @('/rows/0/dimensions/accurate/state', '/rows/1/dimensions/exists/state')
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/docs-parity-matrix.json'
        $finding[0]['related_ids'] | Should -Be @($rows[0]['element_id'])
        $finding[0]['related_paths'] | Should -Be @('docs/reference/Cli.md')
        $result.Ok | Should -BeFalse
        (Get-TestCode -Finding $matrix.Findings -Code 'DOCS_PARITY_REQUIRED_DIMENSION').Count | Should -Be 0
    }

    It 'reports DOCS_BOUND_PAGE_MISSING for a bound page outside the page-path set' {
        # Act
        $missing = Invoke-TestSet -Mode 'docs-complete' -Set $script:Complete -Snapshot $script:Snapshot -PagePath @('docs/other/Page.md')
        $present = Invoke-TestSet -Mode 'docs-complete' -Set $script:Complete -Snapshot $script:Snapshot -PagePath @('docs/other/Page.md', 'docs/reference/Cli.md')
        $matrix = Invoke-TestSet -Mode 'matrix' -Set $script:Complete -Snapshot $script:Snapshot -PagePath @()

        # Assert
        $finding = Get-TestCode -Finding $missing.Findings -Code 'DOCS_BOUND_PAGE_MISSING'
        $finding.Count | Should -Be 6 -Because 'every documented entry is bound to the missing page; the precision-limit entry has no binding'
        $finding[0]['pointer'] | Should -BeExactly '/entries/0/page_bindings/0/page_path'
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/docs-coverage-ledger.json'
        $finding[0]['related_paths'] | Should -Be @('docs/reference/Cli.md')
        $finding[0]['severity'] | Should -BeExactly 'error'
        (Get-TestCode -Finding $present.Findings -Code 'DOCS_BOUND_PAGE_MISSING').Count | Should -Be 0
        $present.Ok | Should -BeTrue
        (Get-TestCode -Finding $matrix.Findings -Code 'DOCS_BOUND_PAGE_MISSING').Count | Should -Be 0 -Because 'matrix mode applies no completion gate'
        (Get-TestCode -Finding $matrix.Findings -Code 'DOCS_MATRIX_EXISTS_INCONSISTENT').Count | Should -Be 6 -Because 'the matrix rule still sees the exists pass for a page outside the set'
    }

    It 'makes DOCS_STALE_PAGE an error only above max_stale_pages' {
        # Arrange: two stale pages beyond the bound page.
        $view = $script:Complete.View
        $ids = @($view.Element.Keys | Sort-Object)
        $results = @{}
        foreach ($max in 1, 2, 3) {
            $set = Get-TestCompleteSet -Snapshot $script:Snapshot -MaxStalePages $max
            $extra = @(
                (New-DocsEvidencePin -Element $view.Element[$ids[0]] -PagePath 'docs/guides/A.md' -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor)
                (New-DocsEvidencePin -Element $view.Element[$ids[1]] -PagePath 'docs/guides/B.md' -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor)
            )
            foreach ($pin in $extra) { $pin['source_sha256'] = '0' * 64 }
            $set.PinSet['pins'] = [object[]](@($set.PinSet['pins']) + $extra)

            # Act
            $results[$max] = Invoke-TestSet -Mode 'docs-complete' -Set $set -Snapshot $script:Snapshot
        }

        # Assert
        foreach ($max in 1, 2, 3) {
            $finding = Get-TestCode -Finding $results[$max].Findings -Code 'DOCS_STALE_PAGE'
            $finding.Count | Should -Be 2 -Because "max_stale_pages=$max"
            $results[$max].Receipt['counts']['stale_pages'] | Should -Be 2 -Because "max_stale_pages=$max"
        }
        @((Get-TestCode -Finding $results[3].Findings -Code 'DOCS_STALE_PAGE') | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('warning') -Because 'below the bound'
        $results[3].Ok | Should -BeTrue
        @((Get-TestCode -Finding $results[2].Findings -Code 'DOCS_STALE_PAGE') | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('warning') -Because 'equal to the bound'
        $results[2].Ok | Should -BeTrue
        @((Get-TestCode -Finding $results[1].Findings -Code 'DOCS_STALE_PAGE') | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('error') -Because 'above the bound'
        $results[1].Ok | Should -BeFalse
        $results[1].Receipt['validation_result'] | Should -BeExactly 'fail'
    }

    It 'passes deferred and precision-limit entries with allow_deferred true and reports DOCS_DEFERRED_NOT_ALLOWED with false' {
        # Arrange: the first element becomes deferred (its row and pin removed), the precision-limit entry stays deferred.
        $sets = @{}
        foreach ($allow in $true, $false) {
            $set = Get-TestCompleteSet -Snapshot $script:Snapshot -AllowDeferred $allow
            $first = $set.Ledger['entries'][0]
            $set.Ledger['entries'][0] = New-DocsLedgerEntry -Element $set.View.Element[$first['element_id']] -Disposition 'deferred' -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor
            $set.Matrix['rows'] = [object[]]@($set.Matrix['rows'] | Where-Object { $_['element_id'] -cne $first['element_id'] })
            $set.PinSet['pins'] = [object[]]@($set.PinSet['pins'] | Where-Object { $_['element_id'] -cne $first['element_id'] })
            $set.Matrix['ledger_ref']['sha256'] = Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $set.Ledger)
            $sets[$allow] = $set
        }

        # Act
        $allowed = Invoke-TestSet -Mode 'docs-complete' -Set $sets[$true] -Snapshot $script:Snapshot
        $denied = Invoke-TestSet -Mode 'docs-complete' -Set $sets[$false] -Snapshot $script:Snapshot

        # Assert
        $allowed.Ok | Should -BeTrue
        (Get-TestCode -Finding $allowed.Findings -Code 'DOCS_DEFERRED_NOT_ALLOWED').Count | Should -Be 0
        $allowed.Receipt['counts']['by_disposition']['deferred'] | Should -Be 1 -Because 'the precision-limit entry is excluded from the counts'
        $denied.Ok | Should -BeFalse
        $finding = Get-TestCode -Finding $denied.Findings -Code 'DOCS_DEFERRED_NOT_ALLOWED'
        $finding.Count | Should -Be 2 -Because 'the element entry and the precision-limit entry are both deferred'
        @($finding | ForEach-Object { $_['pointer'] } | Sort-Object) | Should -Be @('/entries/0/disposition', '/entries/6/disposition')
        $finding[0]['artifact_path'] | Should -BeExactly 'estate/docs-coverage-ledger.json'
        $limitId = @($sets[$false].View.PrecisionLimit.Keys)[0]
        @($finding | Where-Object { $_['related_ids'] -ccontains $limitId }).Count | Should -Be 1
        @($finding | ForEach-Object { $_['severity'] } | Sort-Object -Unique) | Should -Be @('error')
    }

    It 'returns a schema-valid receipt pinned to the revision in matrix and docs-complete modes on pass and fail' {
        # Arrange
        $brokenMatrix = Get-TestCompleteSet -Snapshot $script:Snapshot
        $brokenMatrix.Matrix['rows'][0]['dimensions']['accurate']['evidence_pin_ids'] = [string[]]@('pin-' + ('0' * 64))
        $denied = Get-TestCompleteSet -Snapshot $script:Snapshot -AllowDeferred $false

        # Act
        $matrixPass = Invoke-TestSet -Mode 'matrix' -Set $script:Complete -Snapshot $script:Snapshot
        $matrixFail = Invoke-TestSet -Mode 'matrix' -Set $brokenMatrix -Snapshot $script:Snapshot
        $completePass = Invoke-TestSet -Mode 'docs-complete' -Set $script:Complete -Snapshot $script:Snapshot
        $completeFail = Invoke-TestSet -Mode 'docs-complete' -Set $denied -Snapshot $script:Snapshot

        # Assert
        foreach ($result in @($matrixPass, $matrixFail, $completePass, $completeFail)) {
            Get-TestReceiptFindingCount -Receipt $result.Receipt | Should -Be 0
            $result.Receipt['revision'] | Should -BeExactly $script:Revision
            $result.Receipt['inputs'].Count | Should -Be 5
            @($result.Receipt['inputs'] | ForEach-Object { $_['artifact_kind'] }) | Should -Be @('docs-coverage-ledger', 'docs-evidence-pin', 'docs-parity-matrix', 'docs-profile', 'surface-inventory-snapshot')
            $result.Receipt['counts']['elements_total'] | Should -Be 6
        }
        $matrixPass.Receipt['mode'] | Should -BeExactly 'matrix'
        $matrixPass.Receipt['validation_result'] | Should -BeExactly 'pass'
        $matrixFail.Receipt['validation_result'] | Should -BeExactly 'fail'
        (Get-TestCode -Finding $matrixFail.Findings -Code 'DOCS_MATRIX_PIN_UNKNOWN').Count | Should -Be 1
        $completePass.Receipt['mode'] | Should -BeExactly 'docs-complete'
        $completePass.Receipt['validation_result'] | Should -BeExactly 'pass'
        $completePass.Findings.Count | Should -Be 0
        $completeFail.Receipt['validation_result'] | Should -BeExactly 'fail'
        (Get-TestCode -Finding $completeFail.Findings -Code 'DOCS_DEFERRED_NOT_ALLOWED').Count | Should -Be 1
    }
}
