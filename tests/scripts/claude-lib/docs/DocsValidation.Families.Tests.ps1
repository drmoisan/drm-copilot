#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the documentation family check of Invoke-DocsValidation in
    .claude/lib/docs/DocsValidation.psm1 (issue #1221).

.DESCRIPTION
    Runs Invoke-DocsValidation over a consistent in-memory docs-complete set from
    DocsLedger.TestSupport.psm1 with a profile that declares documentation families and family
    evidence read through the recording in-memory context: a missing family fails, a page or an
    exclusion passes, absent root files fail, the check runs without a snapshot or ledger and only
    in docs-complete mode, $null evidence fails closed, and a profile without families keeps the
    pre-change result. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsFamilyCheck', 'DocsValidation') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Page = 'docs/reference/Cli.md'
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestByte {
        param([object] $Document)
        , $script:Utf8.GetBytes((ConvertTo-DocsJsonText -Value $Document -Indented))
    }

    function Get-TestFamily {
        param([string] $Id, [bool] $Required = $true, [string] $Reason)
        $family = [ordered]@{ id = $Id; directory = "docs/$Id"; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('maintainers'); review_interval_days = 90L; required = $Required }
        if ($PSBoundParameters.ContainsKey('Reason')) { $family['exclusion'] = [ordered]@{ reason = $Reason; recorded_at = '2026-11-23T00:00:00Z' } }
        $family
    }

    function Get-TestCompleteSet {
        # A consistent ledger, matrix and pin collection over the snapshot: every element documented on the page.
        param([object] $Snapshot)
        $bytes = Get-TestByte -Document $Snapshot
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $script:Utf8.GetString($bytes)).Value -SnapshotSha256 (Get-DocsBytesSha256Hex -Bytes $bytes)
        $entries = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry $entries
        $pins = @(foreach ($id in @($view.Element.Keys | Sort-Object)) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        @{
            Ledger = $ledger
            Matrix = (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsBytesSha256Hex -Bytes (Get-TestByte -Document $ledger)) -Row $rows)
            PinSet = (New-DocsLedgerTestPinSet -Pin $pins)
        }
    }

    function Get-TestArtifact {
        param([object] $Snapshot, [hashtable] $Set, [switch] $NoSnapshot, [switch] $NoLedger)
        $map = [ordered]@{}
        $map['surface-inventory-snapshot'] = $(if ($NoSnapshot) { $null } else { @{ Path = 'estate/surface-inventory-snapshot.json'; Bytes = (Get-TestByte -Document $Snapshot) } })
        $map['docs-coverage-ledger'] = $(if ($NoLedger) { $null } else { @{ Path = 'estate/docs-coverage-ledger.json'; Bytes = (Get-TestByte -Document $Set.Ledger) } })
        $map['docs-parity-matrix'] = @{ Path = 'estate/docs-parity-matrix.json'; Bytes = (Get-TestByte -Document $Set.Matrix) }
        $map['docs-evidence-pin'] = @{ Path = 'estate/docs-evidence-pins.json'; Bytes = (Get-TestByte -Document $Set.PinSet) }
        $map
    }

    function Get-TestEvidence {
        # Reads the family evidence of the profile through the recording in-memory context over File.
        param([System.Collections.IDictionary] $ProfileDocument, [string[]] $File = @())
        $map = @{}
        foreach ($path in $File) { $map[$path] = '# page' }
        $test = New-DocsLedgerTestContext -File $map
        Read-DocsFamilyEvidence -Profile $ProfileDocument -TestFile $test.Context.TestFile -ListFile $test.Context.ListFile
    }

    function Invoke-TestValidation {
        param([string] $Mode = 'docs-complete', [System.Collections.IDictionary] $ProfileDocument, [System.Collections.IDictionary] $Artifact, [object] $FamilyEvidence, [switch] $OmitEvidence)
        $parameters = @{
            Mode              = $Mode
            Revision          = $script:Revision
            IssuedAt          = $script:IssuedAt
            ProfileText       = (ConvertTo-DocsJsonText -Value $ProfileDocument)
            ProfilePath       = $script:ProfilePath
            Artifact          = $Artifact
            PagePath          = @($script:Page)
            ComposedSchemaSet = $script:Composed
        }
        if (-not $OmitEvidence) { $parameters['FamilyEvidence'] = $FamilyEvidence }
        Invoke-DocsValidation @parameters
    }

    function Get-TestCode {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsValidation documentation family check' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $script:Artifact = Get-TestArtifact -Snapshot $script:Snapshot -Set $script:Set
        $script:Operations = New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'operations'))
    }

    It 'fails docs-complete with DOCS_FAMILY_PAGE_MISSING for a required family without a page' {
        # Act
        $result = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $script:Operations)

        # Assert
        $missing = Get-TestCode -Finding $result.Findings -Code 'DOCS_FAMILY_PAGE_MISSING'
        $missing.Count | Should -Be 1
        $missing[0]['severity'] | Should -BeExactly 'error'
        $missing[0]['pointer'] | Should -BeExactly '/required_families/0/directory'
        $missing[0]['related_ids'] | Should -Be @('operations')
        $missing[0]['related_paths'] | Should -Be @('docs/operations')
        $result.Ok | Should -BeFalse
        $result.Receipt['validation_result'] | Should -BeExactly 'fail'
    }

    It 'passes docs-complete once a page exists under the family directory' {
        # Act
        $result = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $script:Operations -File @('docs/operations/runbook.md'))

        # Assert
        @($result.Findings).Count | Should -Be 0
        $result.Ok | Should -BeTrue
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'passes docs-complete with DOCS_FAMILY_NOT_APPLICABLE for an excluded family' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'operations' -Reason 'No operated service.'))

        # Act
        $result = Invoke-TestValidation -ProfileDocument $profileDocument -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $profileDocument)

        # Assert
        @($result.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_FAMILY_NOT_APPLICABLE')
        $result.Findings[0]['severity'] | Should -BeExactly 'info'
        $result.Findings[0]['pointer'] | Should -BeExactly '/required_families/0/exclusion'
        $result.Findings[0]['related_ids'] | Should -Be @('operations')
        $result.Ok | Should -BeTrue
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'fails docs-complete with one DOCS_FAMILY_ROOT_FILE_MISSING per absent repository-root file' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'security'))

        # Act
        $result = Invoke-TestValidation -ProfileDocument $profileDocument -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $profileDocument -File @('docs/security/overview.md', 'CODEOWNERS', '.github/CODEOWNERS'))

        # Assert
        $root = Get-TestCode -Finding $result.Findings -Code 'DOCS_FAMILY_ROOT_FILE_MISSING'
        $root.Count | Should -Be 1
        $root[0]['related_paths'] | Should -Be @('SECURITY.md')
        $root[0]['pointer'] | Should -BeExactly '/required_families/0'
        $root[0]['related_ids'] | Should -Be @('security')
        $result.Receipt['validation_result'] | Should -BeExactly 'fail'
    }

    It 'reports the legacy exclusions as one info finding and keeps pass' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile -LegacyExclusion @([ordered]@{ path = 'docs/legacy/old.md'; reason = 'Kept for history.' })

        # Act
        $result = Invoke-TestValidation -ProfileDocument $profileDocument -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $profileDocument)

        # Assert
        @($result.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_LEGACY_EXCLUSIONS_REPORTED')
        $result.Findings[0]['related_paths'] | Should -Be @('docs/legacy/old.md')
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'runs the family check in docs-complete mode with the snapshot or the ledger absent' {
        # Arrange
        $noSnapshot = Get-TestArtifact -Snapshot $script:Snapshot -Set $script:Set -NoSnapshot
        $noLedger = Get-TestArtifact -Snapshot $script:Snapshot -Set $script:Set -NoLedger
        $evidence = Get-TestEvidence -ProfileDocument $script:Operations

        # Act
        $withoutSnapshot = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $noSnapshot -FamilyEvidence $evidence
        $withoutLedger = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $noLedger -FamilyEvidence $evidence

        # Assert
        (Get-TestCode -Finding $withoutSnapshot.Findings -Code 'DOCS_FAMILY_PAGE_MISSING').Count | Should -Be 1
        (Get-TestCode -Finding $withoutLedger.Findings -Code 'DOCS_FAMILY_PAGE_MISSING').Count | Should -Be 1
    }

    It 'does not run the family check in the <_> mode' -ForEach @('profile', 'ledger', 'matrix') {
        # Act
        $result = Invoke-TestValidation -Mode $_ -ProfileDocument $script:Operations -Artifact $script:Artifact -FamilyEvidence (Get-TestEvidence -ProfileDocument $script:Operations)

        # Assert
        @($result.Findings | Where-Object { ([string] $_['code']).StartsWith('DOCS_FAMILY_', [System.StringComparison]::Ordinal) }).Count | Should -Be 0
        $result.Receipt['validation_result'] | Should -BeExactly 'pass'
    }

    It 'fails closed with DOCS_FAMILY_PAGE_MISSING when -FamilyEvidence is $null' {
        # Arrange
        $evidence = $null

        # Act
        $explicit = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $script:Artifact -FamilyEvidence $evidence
        $omitted = Invoke-TestValidation -ProfileDocument $script:Operations -Artifact $script:Artifact -OmitEvidence

        # Assert
        (Get-TestCode -Finding $explicit.Findings -Code 'DOCS_FAMILY_PAGE_MISSING').Count | Should -Be 1
        $explicit.Receipt['validation_result'] | Should -BeExactly 'fail'
        (Get-TestCode -Finding $omitted.Findings -Code 'DOCS_FAMILY_PAGE_MISSING').Count | Should -Be 1
    }

    It 'keeps the findings and result of a profile without families equal to a call that omits -FamilyEvidence' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile
        $evidence = Get-TestEvidence -ProfileDocument $profileDocument

        # Act
        $with = Invoke-TestValidation -ProfileDocument $profileDocument -Artifact $script:Artifact -FamilyEvidence $evidence
        $without = Invoke-TestValidation -ProfileDocument $profileDocument -Artifact $script:Artifact -OmitEvidence

        # Assert
        (ConvertTo-DocsJsonText -Value ([object[]] @($with.Findings))) | Should -BeExactly (ConvertTo-DocsJsonText -Value ([object[]] @($without.Findings)))
        $with.Receipt['validation_result'] | Should -BeExactly $without.Receipt['validation_result']
        $with.Receipt['validation_result'] | Should -BeExactly 'pass'
        @($with.Findings).Count | Should -Be 0
    }
}
