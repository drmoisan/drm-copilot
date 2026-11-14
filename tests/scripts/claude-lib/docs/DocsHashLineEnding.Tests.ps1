#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Line-ending stability of the estate artifact hashes at every reference and conflict-check site (issue #1173 B11).

.DESCRIPTION
    One in-memory CRLF case per site of Get-DocsTextSha256Hex: the update-ledger artifact load
    (ConvertFrom-DocsLedgerCommandArtifact), the validation artifact read (DocsValidation.psm1),
    Get-DocsArtifactPin, the conflict re-read of Invoke-DocsArtifactWrite, the receipt
    before-hash of the validate command, the existing-page hash of generate-reference, and the
    stale check of surface-delta. Every CRLF byte form is built in memory from the LF text the
    commands write, because committed text fixtures are normalized to LF. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands', 'DocsValidateCommands') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:SnapshotPath = 'estate/surface-inventory-snapshot.json'
    $script:LedgerPath = 'estate/docs-coverage-ledger.json'
    $script:MatrixPath = 'estate/docs-parity-matrix.json'
    $script:PinPath = 'estate/docs-evidence-pins.json'
    $script:ReceiptPath = 'estate/docs-validation-receipt.json'
    $script:RefCodes = @('DOCS_LEDGER_SNAPSHOT_REF', 'DOCS_MATRIX_LEDGER_REF', 'DOCS_MATRIX_SNAPSHOT_REF')

    function ConvertTo-TestCrlf {
        # Returns Text with every LF written as CRLF.
        param([string] $Text)
        return $Text.Replace("`n", "`r`n")
    }

    function Get-TestText {
        param([object] $Document)
        ConvertTo-DocsJsonText -Value $Document -Indented
    }

    function New-TestEstate {
        # Returns the file map of a consistent estate (every element documented on the page with a current pin); Crlf writes the snapshot, ledger, matrix and pins as CRLF.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([switch] $Crlf)
        $snapshotText = Get-TestText -Document (New-DocsLedgerTestSnapshot)
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
        foreach ($entry in $entries) { $sorted[[string] $entry['element_id']] = $entry }
        $ledgerText = Get-TestText -Document (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @($sorted.Values))
        $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $script:Page -Revision $view.Revision -PinnedAt $script:IssuedAt -Actor $script:Actor })
        $rows = @(foreach ($pin in $pins) {
                $dimension = @{
                    exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                    accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                    owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                }
                New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $script:Page -Dimension $dimension
            })
        $matrixText = Get-TestText -Document (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text $ledgerText) -Row $rows)
        $pinText = Get-TestText -Document (New-DocsLedgerTestPinSet -Pin $pins)
        $files = [ordered]@{ $script:Page = '# Cli'; $script:ProfilePath = (Get-TestText -Document (New-DocsLedgerTestProfile)) }
        foreach ($pair in @(@($script:SnapshotPath, $snapshotText), @($script:LedgerPath, $ledgerText), @($script:MatrixPath, $matrixText), @($script:PinPath, $pinText))) {
            $files[$pair[0]] = if ($Crlf) { ConvertTo-TestCrlf -Text $pair[1] } else { $pair[1] }
        }
        return @{ Files = $files; Ids = $ids }
    }

    function Get-TestCode {
        # Returns the finding codes of one CLI outcome envelope.
        param([object] $Outcome)
        @((ConvertFrom-DocsJsonText -Text $Outcome.Stdout).Value['findings'] | ForEach-Object { [string] $_['code'] })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\ConvertTo-TestCrlf, Function:\Get-TestText, Function:\New-TestEstate, Function:\Get-TestCode -ErrorAction SilentlyContinue
}

Describe 'estate artifact reference hashes over CRLF bytes (issue #1173 B11)' {
    It 'update-ledger over a CRLF ledger, matrix and snapshot reports no reference drift and plans no write for an identical entry' {
        # Arrange
        $estate = New-TestEstate -Crlf
        $test = New-DocsLedgerTestContext -File $estate.Files

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument @('-Operation', 'set-disposition', '-Element', $estate.Ids[0], '-Disposition', 'documented', '-Page', $script:Page, '-ActorKind', 'tool', '-ActorId', 'fixture-tool') -Context $test.Context -Json
        $result = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value['result']

        # Assert
        $outcome.ExitCode | Should -Be 0
        @(Get-TestCode -Outcome $outcome | Where-Object { $script:RefCodes -ccontains $_ }) | Should -BeNullOrEmpty
        @($result['writes'] | ForEach-Object { $_['status'] }) | Should -Be @('skipped', 'skipped', 'skipped') -Because 'the CRLF documents equal the planned LF text in LF form'
    }

    It 'validate over the same CRLF set reports no reference drift and the receipt equals the LF receipt' {
        # Arrange
        $crlf = New-DocsLedgerTestContext -RevisionMap @{ HEAD = $script:Revision } -File (New-TestEstate -Crlf).Files
        $lf = New-DocsLedgerTestContext -RevisionMap @{ HEAD = $script:Revision } -File (New-TestEstate).Files

        # Act
        $crlfRun = Invoke-DocsCommandCli -Command 'validate' -CommandArgument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Context $crlf.Context -Json
        $lfRun = Invoke-DocsCommandCli -Command 'validate' -CommandArgument @('-Mode', 'docs-complete', '-Revision', $script:Revision) -Context $lf.Context -Json

        # Assert
        @(Get-TestCode -Outcome $crlfRun | Where-Object { $script:RefCodes -ccontains $_ }) | Should -BeNullOrEmpty
        $crlfRun.ExitCode | Should -Be $lfRun.ExitCode
        (ConvertFrom-DocsJsonText -Text $crlfRun.Stdout).Value['result']['id'] | Should -BeExactly (ConvertFrom-DocsJsonText -Text $lfRun.Stdout).Value['result']['id']
    }

    It 'pins CRLF bytes with the same sha256 as their LF form' {
        # Arrange
        $text = "{`n  `"a`": 1`n}`n"
        $lfBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($text)
        $crlfBytes = [System.Text.UTF8Encoding]::new($false).GetBytes((ConvertTo-TestCrlf -Text $text))

        # Act / Assert
        (Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path $script:LedgerPath -Bytes $crlfBytes)['sha256'] | Should -BeExactly (Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path $script:LedgerPath -Bytes $lfBytes)['sha256']
    }

    It 'treats a CRLF current document equal in LF form to the planned before-hash as no conflict' {
        # Arrange
        $text = "{`n  `"b`": 2`n}`n"
        $current = [System.Text.UTF8Encoding]::new($false).GetBytes((ConvertTo-TestCrlf -Text $text))
        $written = [System.Collections.Generic.List[string]]::new()
        $plan = @{ Path = $script:LedgerPath; ArtifactKind = 'docs-coverage-ledger'; ArtifactId = 'x'; Text = "{`n  `"b`": 3`n}`n"; BeforeSha256 = (Get-DocsBytesSha256Hex -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($text))); Sha256 = ('0' * 64); Status = 'planned' }

        # Act
        $readBytes = { param($Path) if ($Path -cne 'estate/docs-coverage-ledger.json') { throw "unexpected read of $Path" }; , $current }.GetNewClosure()
        $testFile = { param($Path) -not [string]::IsNullOrEmpty($Path) }
        $writeText = { param($Path, $Text, $Mode) $written.Add("$Mode $Path $($Text.Length -gt 0)") }.GetNewClosure()
        $outcome = Invoke-DocsArtifactWrite -Plan @($plan) -ReadBytes $readBytes -TestFile $testFile -WriteText $writeText

        # Assert
        $outcome.Failed | Should -BeNullOrEmpty
        @($written) | Should -Be @("overwrite $($script:LedgerPath) True")
        @($outcome.Write | ForEach-Object { $_['Status'] }) | Should -Be @('updated')
    }

    It 'skips the receipt write when the existing CRLF receipt equals the new receipt in LF form' {
        # Arrange
        $first = New-DocsLedgerTestContext -RevisionMap @{ HEAD = $script:Revision } -File (New-TestEstate).Files
        [void] (Invoke-DocsCommandCli -Command 'validate' -CommandArgument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Context $first.Context -Json)
        $receiptText = [System.Text.Encoding]::UTF8.GetString($first.Files[$script:ReceiptPath])
        $files = (New-TestEstate).Files
        $files[$script:ReceiptPath] = ConvertTo-TestCrlf -Text $receiptText
        $second = New-DocsLedgerTestContext -RevisionMap @{ HEAD = $script:Revision } -File $files

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate' -CommandArgument @('-Mode', 'docs-complete', '-Revision', $script:Revision, '-WriteReceipt') -Context $second.Context

        # Assert
        $outcome.ExitCode | Should -Be 0
        @($outcome.Stdout.TrimEnd("`n") -split "`n") | Should -Contain "skipped $($script:ReceiptPath)"
        @($second.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count | Should -Be 0
    }
}

Describe 'generate-reference existing-page hash over CRLF bytes (issue #1173 B11)' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
        $script:ReferenceElement = [object[]]@(
            (New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'tool run')
            (New-DocsReferenceFixedElement -Kind 'config-key' -Declaration 'tool.level' -Path 'conf/tool.toml')
        )
        $script:ReferenceMap = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:ReferenceElement -Page $null -SchemaTextMap (Get-DocsReferenceSchemaTextMap)
    }

    It 'reports action none for an existing CRLF page equal in LF form to the generated page' {
        # Arrange
        $first = New-DocsReferenceMemoryContext -File $script:ReferenceMap
        [void] (Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument @('-Write') -Context $first.Context -Json)
        $map = [ordered]@{}
        foreach ($key in $script:ReferenceMap.Keys) { $map[$key] = $script:ReferenceMap[$key] }
        foreach ($entry in $first.WriteLog) { $map[[string] $entry.RelativePath] = ConvertTo-TestCrlf -Text ([string] $entry.Text) }
        $second = New-DocsReferenceMemoryContext -File $map

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument @() -Context $second.Context -Json
        $pages = @((ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value['result']['pages'])

        # Assert
        $first.WriteLog.Count | Should -BeGreaterThan 0
        $outcome.ExitCode | Should -Be 0
        @($pages | ForEach-Object { [string] $_['action'] } | Sort-Object -Unique) | Should -Be @('none')
    }
}

Describe 'surface-delta stale check over CRLF bytes (issue #1173 B11)' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurfaceDeltaCommands.psm1') -Force -ErrorAction Stop
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop
    }

    It 'does not report a CRLF source equal in LF form to its snapshot input as stale' {
        # Arrange
        $sourcePath = 'src/example_pkg/cli.py'
        $sourceText = "def inventory():`n    pass`n"
        $inputSha = Get-DocsBytesSha256Hex -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($sourceText))
        $snapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'
        $ledgerPath = 'docs/documentation-estate/docs-coverage-ledger.json'
        $snapshot = ConvertTo-Json -InputObject ([ordered]@{ artifact_kind = 'surface-inventory-snapshot'; inputs = @([ordered]@{ path = $sourcePath; sha256 = $inputSha; size = 1 }); elements = @() }) -Depth 6 -Compress
        $ledger = ConvertTo-Json -InputObject ([ordered]@{ artifact_kind = 'docs-coverage-ledger'; entries = @() }) -Depth 6 -Compress
        $baseRevision = 'fedcba9876543210fedcba9876543210fedcba98'
        $files = @{ $script:ProfilePath = (Get-DocsTestExampleText)['docs-profile']; $sourcePath = (ConvertTo-TestCrlf -Text $sourceText); $snapshotPath = $snapshot; $ledgerPath = $ledger }
        $context = (New-DocsTestContext -File $files -RevisionMap @{ main = $baseRevision } -RevisionFile @{ $baseRevision = @{ $snapshotPath = $snapshot; $ledgerPath = $ledger } }).Context

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'surface-delta' -CommandArgument @('-Base', 'main') -Context $context -Json

        # Assert
        Get-TestCode -Outcome $outcome | Should -Not -Contain 'DOCS_SURFACE_SNAPSHOT_STALE'
        $outcome.ExitCode | Should -Be 0
    }
}
