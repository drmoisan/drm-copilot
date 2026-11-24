#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the documentation family evidence that Invoke-DocsValidateCommand in
    .claude/lib/docs/DocsValidateCommands.psm1 reads and passes to Invoke-DocsValidation
    (issue #1221).

.DESCRIPTION
    Runs validate through Invoke-DocsCommandCli over the recording in-memory context of
    DocsLedger.TestSupport.psm1 with a profile that declares documentation families: a missing
    family exits 1 with a failing receipt that Test-DocsCompleteGateReceipt denies as
    RECEIPT_FAILING, info-only family findings keep exit 0 and a passing receipt, the security
    root files are probed through the context, and a profile without families reads the same
    inputs as before. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsFamilyCheck', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands', 'DocsValidateCommands', 'DocsReceiptRevision', 'DocsCompleteGate') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:HeadMap = @{ HEAD = $script:Revision }
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:ReceiptPath = 'estate/docs-validation-receipt.json'

    function Get-TestText {
        param([object] $Document)
        ConvertTo-DocsJsonText -Value $Document -Indented
    }

    function Get-TestFamily {
        param([string] $Id, [string] $Reason)
        $family = [ordered]@{ id = $Id; directory = "docs/$Id"; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('maintainers'); review_interval_days = 90L; required = $true }
        if ($PSBoundParameters.ContainsKey('Reason')) { $family['exclusion'] = [ordered]@{ reason = $Reason; recorded_at = '2026-11-23T00:00:00Z' } }
        $family
    }

    function Get-TestEstate {
        # The profile, snapshot, page and a consistent ledger, matrix and pin collection; Extra adds files.
        param([System.Collections.IDictionary] $ProfileDocument, [string[]] $Extra = @())
        $snapshot = New-DocsLedgerTestSnapshot
        $snapshotText = Get-TestText -Document $snapshot
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
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
        $files = [ordered]@{
            $script:Page                             = '# Cli'
            'estate/surface-inventory-snapshot.json' = $snapshotText
            'estate/docs-coverage-ledger.json'       = (Get-TestText -Document $ledger)
            'estate/docs-parity-matrix.json'         = (Get-TestText -Document (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows))
            'estate/docs-evidence-pins.json'         = (Get-TestText -Document (New-DocsLedgerTestPinSet -Pin $pins))
            $script:ProfilePath                      = (Get-TestText -Document $ProfileDocument)
        }
        foreach ($path in $Extra) { $files[$path] = '# page' }
        New-DocsLedgerTestContext -RevisionMap $script:HeadMap -File $files
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

    function Get-TestReadLog {
        # The ordered ListFile and TestFile calls of a context, one 'Member RelativePath' line each.
        param([hashtable] $Test)
        , @($Test.CallLog | Where-Object { $_.Member -ceq 'ListFile' -or $_.Member -ceq 'TestFile' } | ForEach-Object { "$($_.Member) $($_.RelativePath)" })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsValidateCommand documentation family evidence' {
    It 'exits 1 with a failing receipt and DOCS_FAMILY_PAGE_MISSING for a missing family' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'operations')))

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Result['validation_result'] | Should -BeExactly 'fail'
        $missing = Get-TestCode -Finding $run.Envelope['findings'] -Code 'DOCS_FAMILY_PAGE_MISSING'
        $missing.Count | Should -Be 1
        $missing[0]['pointer'] | Should -BeExactly '/required_families/0/directory'
        $missing[0]['artifact_path'] | Should -BeExactly $script:ProfilePath
        $readLog = Get-TestReadLog -Test $test
        $readLog | Should -Contain 'ListFile docs/operations'
    }

    It 'writes a failing receipt that the docs-complete gate denies as RECEIPT_FAILING' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'operations')))

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $test
        $decision = Test-DocsCompleteGateReceipt -ReceiptText $test.WriteLog[0].Text -HeadRevision $script:Revision -SnapshotRevision $script:Revision

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        @($test.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:ReceiptPath)
        (ConvertFrom-DocsJsonText -Text $test.WriteLog[0].Text).Value['validation_result'] | Should -BeExactly 'fail'
        $decision.Allow | Should -BeFalse
        $decision.Reason | Should -BeExactly 'RECEIPT_FAILING'
    }

    It 'keeps exit 0 and a passing receipt when the family findings are info only' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'operations' -Reason 'No operated service.')) -LegacyExclusion @([ordered]@{ path = 'docs/legacy/old.md'; reason = 'Kept for history.' })
        $test = Get-TestEstate -ProfileDocument $profileDocument

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Test $test
        $decision = Test-DocsCompleteGateReceipt -ReceiptText $test.WriteLog[0].Text -HeadRevision $script:Revision -SnapshotRevision $script:Revision

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Result['validation_result'] | Should -BeExactly 'pass'
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_LEGACY_EXCLUSIONS_REPORTED', 'DOCS_FAMILY_NOT_APPLICABLE') -Because 'Get-DocsOrderedFinding orders /legacy_exclusions before /required_families'
        $decision.Allow | Should -BeTrue
    }

    It 'probes the repository-root security files through the context and passes when every family is satisfied' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'security'))) -Extra @('docs/security/overview.md', 'SECURITY.md', 'CODEOWNERS')

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Envelope['findings']).Count | Should -Be 0
        $readLog = Get-TestReadLog -Test $test
        $readLog | Should -Contain 'ListFile docs/security'
        $readLog | Should -Contain 'TestFile SECURITY.md'
        $readLog | Should -Contain 'TestFile CODEOWNERS'
    }

    It 'reads no family evidence outside docs-complete mode' {
        # Arrange
        $test = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'security')))

        # Act
        $run = Invoke-TestValidate -Argument @('-Mode', 'matrix', '-Revision', $script:Revision) -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $readLog = Get-TestReadLog -Test $test
        $readLog | Should -Not -Contain 'ListFile docs/security'
        $readLog | Should -Not -Contain 'TestFile SECURITY.md'
    }

    It 'records the matrix-mode context reads plus one ReadText per page for a profile without families' {
        # Arrange
        $complete = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile)
        $matrix = Get-TestEstate -ProfileDocument (New-DocsLedgerTestProfile)

        # Act
        $completeRun = Invoke-TestValidate -Argument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Test $complete
        $matrixRun = Invoke-TestValidate -Argument @('-Mode', 'matrix', '-Revision', $script:Revision) -Test $matrix

        # Assert: issue #1220 reads the page front matter through ReadText in docs-complete mode only.
        $completeRun.Outcome.ExitCode | Should -Be 0
        $matrixRun.Outcome.ExitCode | Should -Be 0
        $completeLog = @($complete.CallLog | ForEach-Object { "$($_.Member) $($_.RelativePath)" })
        $pageReads = @($completeLog | Where-Object { $_.StartsWith('ReadText ', [System.StringComparison]::Ordinal) -and $_.EndsWith('.md', [System.StringComparison]::Ordinal) })
        $pageReads | Should -Be @("ReadText $script:Page")
        @($completeLog | Where-Object { $pageReads -cnotcontains $_ }) | Should -Be @($matrix.CallLog | ForEach-Object { "$($_.Member) $($_.RelativePath)" })
        $completeReadLog = Get-TestReadLog -Test $complete
        $completeReadLog | Should -Not -Contain 'TestFile SECURITY.md'
    }
}
