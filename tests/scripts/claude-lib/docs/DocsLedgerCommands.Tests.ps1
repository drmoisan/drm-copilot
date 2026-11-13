#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsLedgerCommands.psm1: argument validation, input loading,
    the dispatch rows and the coverage subcommand (the DocsLedgerCommands suite family).

.DESCRIPTION
    Covers Test-DocsUpdateLedgerArgument over every operation and value grammar (the
    Test-DocsValidateArgument cases live in DocsValidateCommands.Tests.ps1, issue #1169), Read-DocsLedgerInputSet over the recording in-memory context of
    DocsLedger.TestSupport.psm1, the 1023 dispatch rows of Invoke-DocsCommand.ps1 and the
    coverage subcommand through Invoke-DocsCommandCli. Assertions use codes, exit codes,
    pointers and identifiers, never Test-Json message text. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    # Dot-sourced to load the entry functions (the top-level body runs only when not dot-sourced).
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:ElementId = 'cli-command-' + ('a' * 64)
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:Composed = Get-DocsLedgerTestSchemaSet
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:IssuedAt = '2026-03-01T12:00:00Z'
    $script:Page = 'docs/reference/Cli.md'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

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
        # A consistent ledger, matrix and pin collection over the snapshot: every element documented on the page
        # with a current pin, the required dimensions pass, the precision limit deferred.
        param([object] $Snapshot)
        $view = Get-TestView -Snapshot $Snapshot
        $ids = @($view.Element.Keys | Sort-Object)
        $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Page; anchor = $null }) -Actor $script:Actor })
        $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $script:Actor })
        $ledger = New-DocsLedgerTestLedger -SnapshotSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $Snapshot)) -Entry $entries
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
            Ledger = $ledger
            Matrix = (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text (Get-TestText -Document $ledger)) -Row $rows)
            PinSet = (New-DocsLedgerTestPinSet -Pin $pins)
        }
    }

    function New-TestEstate {
        # The in-memory repository files of one estate: profile, snapshot, page, and the optional documents.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([object] $Snapshot = (New-DocsLedgerTestSnapshot), [object] $ProfileDocument = (New-DocsLedgerTestProfile), [hashtable] $Set, [switch] $NoProfile, [switch] $NoSnapshot)
        $files = [ordered]@{ 'docs/reference/Cli.md' = '# Cli' }
        if (-not $NoProfile) { $files[$script:ProfilePath] = Get-TestText -Document $ProfileDocument }
        if (-not $NoSnapshot) { $files['estate/surface-inventory-snapshot.json'] = Get-TestText -Document $Snapshot }
        if ($null -ne $Set) {
            $files['estate/docs-coverage-ledger.json'] = Get-TestText -Document $Set.Ledger
            $files['estate/docs-parity-matrix.json'] = Get-TestText -Document $Set.Matrix
            $files['estate/docs-evidence-pins.json'] = Get-TestText -Document $Set.PinSet
        }
        $files
    }

    function Invoke-TestCli {
        # Runs one subcommand through the entry function with the recording context; returns @{ Outcome; Envelope }.
        param([string] $Command, [string[]] $Argument = @(), [hashtable] $Test, [switch] $Json)
        $outcome = Invoke-DocsCommandCli -Command $Command -CommandArgument $Argument -Context $Test.Context -Json:$Json
        $envelope = $null
        if ($Json) { $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
        @{ Outcome = $outcome; Envelope = $envelope }
    }

    function Get-TestEnvelopeFindingCount {
        param([string] $Text)
        (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $Text -ComposedSchemaSet $script:Composed).Count
    }

    function Get-TestWriteCallCount {
        param([hashtable] $Test)
        @($Test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count
    }

    function New-TestArgument {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Operation, [hashtable] $Extra)
        $argument = [ordered]@{ Operation = $Operation; ActorKind = 'tool'; ActorId = 'fixture-tool' }
        switch ($Operation) {
            'set-disposition' { $argument['Element'] = $script:ElementId; $argument['Disposition'] = 'documented'; $argument['Page'] = [string[]]@('docs/reference/Cli.md') }
            'remove-entry' { $argument['Element'] = $script:ElementId }
            'pin' { $argument['Element'] = $script:ElementId; $argument['Page'] = [string[]]@('docs/reference/Cli.md') }
            'unpin' { $argument['Element'] = $script:ElementId; $argument['Page'] = [string[]]@('docs/reference/Cli.md') }
            'set-dimension' { $argument['Element'] = $script:ElementId; $argument['Page'] = [string[]]@('docs/reference/Cli.md'); $argument['Dimension'] = 'exists'; $argument['State'] = 'pass' }
        }
        if ($null -ne $Extra) { foreach ($key in $Extra.Keys) { $argument[$key] = $Extra[$key] } }
        $argument
    }

    function Assert-TestUsageFinding {
        param([object] $Finding, [string] $Fragment)
        $null -eq $Finding | Should -BeFalse -Because "a finding is expected ($Fragment)"
        $Finding['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
        $Finding['severity'] | Should -BeExactly 'error'
        if ($Fragment.Length -gt 0) { $Finding['message'].Contains($Fragment, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the message names $Fragment" }
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Test-DocsUpdateLedgerArgument' {
    It 'returns one DOCS_CLI_ARGUMENTS finding for an option outside the operation set' {
        # Arrange
        $outside = @{
            'set-disposition' = @{ Claim = 'c' }
            'remove-entry'    = @{ Page = [string[]]@('docs/a.md') }
            'pin'             = @{ Disposition = 'documented' }
            'unpin'           = @{ Claim = 'c' }
            'set-dimension'   = @{ Owner = 'docs-team' }
            'sync-refs'       = @{ Element = $script:ElementId }
        }
        foreach ($operation in $outside.Keys) {
            # Act
            $finding = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation $operation -Extra $outside[$operation])

            # Assert
            Assert-TestUsageFinding -Finding $finding -Fragment $operation
            $finding['message'].Contains("-$(@($outside[$operation].Keys)[0])", [System.StringComparison]::Ordinal) | Should -BeTrue
        }
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'other')) -Fragment 'other'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument @{ ActorKind = 'tool'; ActorId = 'fixture-tool' }) -Fragment '-Operation'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument @{ Operation = 'sync-refs'; ActorId = 'fixture-tool' }) -Fragment '-ActorKind'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument @{ Operation = 'sync-refs'; ActorKind = 'robot'; ActorId = 'fixture-tool' }) -Fragment 'robot'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument @{ Operation = 'sync-refs'; ActorKind = 'tool' }) -Fragment '-ActorId'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-dimension' -Extra @{ State = $null; Dimension = $null })) -Fragment 'requires -Dimension'
    }

    It 'rejects Element with Limit and Limit with a non-deferred disposition' {
        # Act
        $both = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Limit = 'diagnostic-' + ('b' * 64) })
        $neither = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Element = $null })
        $documented = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Element = $null; Page = $null; Limit = 'diagnostic-' + ('b' * 64) })
        $deferred = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Element = $null; Page = $null; Limit = 'diagnostic-' + ('b' * 64); Disposition = 'deferred'; Owner = 'docs-team'; Target = 'Next release' })
        $pinLimit = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'pin' -Extra @{ Element = $null; Limit = 'diagnostic-' + ('b' * 64) })

        # Assert
        Assert-TestUsageFinding -Finding $both -Fragment '-Element and -Limit'
        Assert-TestUsageFinding -Finding $neither -Fragment '-Element or -Limit'
        Assert-TestUsageFinding -Finding $documented -Fragment 'deferred'
        $null -eq $deferred | Should -BeTrue
        Assert-TestUsageFinding -Finding $pinLimit -Fragment '-Limit'
    }

    It 'rejects a repeated Page value' {
        # Act
        $repeated = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('docs/a.md', 'docs/b.md#intro', 'docs/a.md') })
        $distinct = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('docs/a.md', 'docs/a.md#intro', 'docs/A.md') })
        $two = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'pin' -Extra @{ Page = [string[]]@('docs/a.md', 'docs/b.md') })
        $anchored = Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'unpin' -Extra @{ Page = [string[]]@('docs/a.md#intro') })

        # Assert
        Assert-TestUsageFinding -Finding $repeated -Fragment 'more than once'
        $null -eq $distinct | Should -BeTrue -Because 'an anchor and a letter-case difference make distinct values'
        Assert-TestUsageFinding -Finding $two -Fragment 'exactly one -Page'
        Assert-TestUsageFinding -Finding $anchored -Fragment 'without an anchor'
    }

    It 'rejects invalid Element, Limit, Revision, ActorId, Owner, Page and relative path values' {
        # Act and Assert
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Element = 'widget-' + ('a' * 64) })) -Fragment 'element id'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Element = 'cli-command-' + ('A' * 64) })) -Fragment 'element id'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Element = $null; Limit = 'pin-' + ('b' * 64) })) -Fragment 'diagnostic identifier'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'remove-entry' -Extra @{ Element = $null; Limit = 'diagnostic-' + ('B' * 64) })) -Fragment 'diagnostic identifier'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'sync-refs' -Extra @{ ActorId = 'Fixture Tool' })) -Fragment 'identifier'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Owner = 'Docs Team' })) -Fragment 'identifier'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('/docs/a.md') })) -Fragment 'Page'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('docs/a.md#') })) -Fragment 'Page'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('../a.md') })) -Fragment 'Page'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'sync-refs' -Extra @{ Profile = 'C:/abs.json' })) -Fragment 'repository-relative'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Disposition = 'planned' })) -Fragment 'planned'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-dimension' -Extra @{ Dimension = 'tone' })) -Fragment 'tone'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-dimension' -Extra @{ State = 'maybe' })) -Fragment 'maybe'
        Assert-TestUsageFinding -Finding (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Rationale = '   ' })) -Fragment '-Rationale'
    }

    It 'returns null for valid arguments' {
        foreach ($operation in 'set-disposition', 'remove-entry', 'pin', 'unpin', 'set-dimension', 'sync-refs') {
            $null -eq (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation $operation)) | Should -BeTrue -Because $operation
        }
        $null -eq (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Disposition = 'excluded'; Page = $null; Rationale = 'Internal.'; Profile = 'p.json'; Write = $true })) | Should -BeTrue
        $null -eq (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-disposition' -Extra @{ Page = [string[]]@('docs/a.md#intro', 'docs/b.md') })) | Should -BeTrue
        $null -eq (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'pin' -Extra @{ Claim = 'Describes the command.' })) | Should -BeTrue
        $null -eq (Test-DocsUpdateLedgerArgument -Argument (New-TestArgument -Operation 'set-dimension' -Extra @{ State = 'fail'; Rationale = 'Missing.' })) | Should -BeTrue
    }
}

Describe 'Dispatch rows' {
    It 'Get-DocsCommandTable carries the coverage and update-ledger rows bound to DocsLedgerCommands.psm1 and the validate row bound to DocsValidateCommands.psm1' {
        # Act
        $table = Get-DocsCommandTable
        $rows = @{}
        foreach ($name in 'coverage', 'update-ledger', 'validate') { $rows[$name] = @($table | Where-Object { [string] $_.Name -ceq $name }) }

        # Assert (membership; no row-count assertion)
        foreach ($name in 'coverage', 'update-ledger', 'validate') {
            $rows[$name].Count | Should -Be 1 -Because "one row is named $name"
            $expectedModule = if ($name -ceq 'validate') { 'DocsValidateCommands.psm1' } else { 'DocsLedgerCommands.psm1' }
            [System.IO.Path]::GetFileName([string] $rows[$name][0].Module) | Should -BeExactly $expectedModule
            Test-Path -LiteralPath $rows[$name][0].Module | Should -BeTrue
        }
        $rows['coverage'][0].Function | Should -BeExactly 'Invoke-DocsCoverageCommand'
        $rows['update-ledger'][0].Function | Should -BeExactly 'Invoke-DocsUpdateLedgerCommand'
        $rows['validate'][0].Function | Should -BeExactly 'Invoke-DocsValidateCommand'
        @($rows['coverage'][0].Option.Keys) | Should -Be @('Profile')
        [string[]] $updateOptions = @($rows['update-ledger'][0].Option.Keys)
        [Array]::Sort($updateOptions, [System.StringComparer]::Ordinal)
        $updateOptions | Should -Be @('ActorId', 'ActorKind', 'Claim', 'Dimension', 'Disposition', 'Element', 'Limit', 'Operation', 'Owner', 'Page', 'Profile', 'Rationale', 'State', 'Target', 'Write')
        $rows['update-ledger'][0].Option['Page'] | Should -BeExactly 'multi'
        $rows['update-ledger'][0].Option['Write'] | Should -BeExactly 'switch'
        [string[]] $validateOptions = @($rows['validate'][0].Option.Keys)
        [Array]::Sort($validateOptions, [System.StringComparer]::Ordinal)
        $validateOptions | Should -Be @('Mode', 'Profile', 'Revision', 'WriteReceipt')
        $rows['validate'][0].Option['WriteReceipt'] | Should -BeExactly 'switch'
        $text = Get-Content -LiteralPath (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1') -Raw
        $anchor = $text.IndexOf('# --- 1023: coverage, update-ledger, validate ---', [System.StringComparison]::Ordinal)
        $next = $text.IndexOf('# --- 1024: generate-reference ---', [System.StringComparison]::Ordinal)
        $anchor | Should -BeGreaterThan 0
        $text.IndexOf("Name = 'coverage'", [System.StringComparison]::Ordinal) | Should -BeGreaterThan $anchor
        $text.IndexOf("Name = 'validate'", [System.StringComparison]::Ordinal) | Should -BeLessThan $next -Because 'the three rows sit directly under the 1023 anchor'
    }

    It 'Test-DocsCommandTable returns no finding for the committed table' {
        (Test-DocsCommandTable -Table (Get-DocsCommandTable)).Count | Should -Be 0
    }
}

Describe 'Read-DocsLedgerInputSet' {
    BeforeAll {
        $script:Profile = New-DocsLedgerTestProfile
        $script:Need = @('surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt', 'page-path-set')
    }

    It 'returns null for an absent artifact and propagates other read failures' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'estate/surface-inventory-snapshot.json' = '{"a":1}'; 'estate/docs-parity-matrix.json' = ''; 'estate/docs-evidence-pins.json' = '{}' } -ReadBytesFailure @{ 'estate/docs-evidence-pins.json' = 'permission denied' }

        # Act
        $set = Read-DocsLedgerInputSet -Profile $script:Profile -Need @('surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-validation-receipt') -ReadBytes $test.Context.ReadBytes -TestFile $test.Context.TestFile -ListFile $test.Context.ListFile

        # Assert
        $set.Artifact['surface-inventory-snapshot']['Path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        [System.Text.Encoding]::UTF8.GetString($set.Artifact['surface-inventory-snapshot']['Bytes']) | Should -BeExactly '{"a":1}'
        $null -eq $set.Artifact['docs-coverage-ledger'] | Should -BeTrue
        $set.Artifact['docs-parity-matrix']['Bytes'].Count | Should -Be 0 -Because 'an empty file is present with zero bytes'
        $null -eq $set.Artifact['docs-validation-receipt'] | Should -BeTrue
        @($set.Artifact.Keys) | Should -Be @('surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-validation-receipt')
        $set.PagePath.Count | Should -Be 0 -Because 'page-path-set was not needed'
        @($test.CallLog | Where-Object { $_.Member -ceq 'ReadBytes' } | ForEach-Object { $_.RelativePath }) | Should -Be @('estate/surface-inventory-snapshot.json', 'estate/docs-parity-matrix.json') -Because 'absent artifacts are not read'
        { Read-DocsLedgerInputSet -Profile $script:Profile -Need @('docs-evidence-pin') -ReadBytes $test.Context.ReadBytes -TestFile $test.Context.TestFile -ListFile $test.Context.ListFile } | Should -Throw -ExpectedMessage '*permission denied*'
    }

    It 'builds the ordinal page-path set from ListFile over documentation_roots' {
        # Arrange
        $document = New-DocsLedgerTestProfile
        $document['documentation_roots'] = @(
            [ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('maintainers') }
            [ordered]@{ id = 'guides-root'; path = 'guides'; audience_ids = @('maintainers') }
        )
        $test = New-DocsLedgerTestContext -File @{ 'docs/b.md' = ''; 'docs/A.md' = ''; 'docs/sub/c.md' = ''; 'guides/z.md' = ''; 'other/x.md' = ''; 'docs2/y.md' = '' }

        # Act
        $set = Read-DocsLedgerInputSet -Profile $document -Need @('page-path-set') -ReadBytes $test.Context.ReadBytes -TestFile $test.Context.TestFile -ListFile $test.Context.ListFile

        # Assert
        $set.PagePath | Should -Be @('docs/A.md', 'docs/b.md', 'docs/sub/c.md', 'guides/z.md')
        @($set.Artifact.Keys).Count | Should -Be 0
        @($test.CallLog | ForEach-Object { $_.Member + ' ' + $_.RelativePath }) | Should -Be @('ListFile docs', 'ListFile guides')
    }
}

Describe 'coverage' {
    BeforeAll {
        $script:Snapshot = New-DocsLedgerTestSnapshot
        $script:Complete = Get-TestCompleteSet -Snapshot $script:Snapshot
    }

    It 'returns totals with by_analysis_method, undocumented, deferred, precision_limits, stale_pages and parity' {
        # Arrange: one entry removed (undocumented), one deferred, one stale pin.
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $ids = @($set.View.Element.Keys | Sort-Object)
        $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Where-Object { $_['element_id'] -cne $ids[0] })
        $set.Ledger['entries'][0] = New-DocsLedgerEntry -Element $set.View.Element[$ids[1]] -Disposition 'deferred' -Owner 'docs-team' -Target 'Later' -Actor $script:Actor
        $set.PinSet['pins'][2]['source_sha256'] = '0' * 64
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)

        # Act
        $run = Invoke-TestCli -Command 'coverage' -Test $test -Json

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $result = $run.Envelope['result']
        @($result.Keys | Sort-Object) | Should -Be @('deferred', 'parity', 'precision_limits', 'stale_pages', 'totals', 'undocumented')
        $result['totals']['elements_total'] | Should -Be 6
        $result['totals']['undocumented'] | Should -Be 1
        $result['totals']['by_disposition']['documented'] | Should -Be 4
        $result['totals']['by_disposition']['deferred'] | Should -Be 1
        ($result['totals']['by_analysis_method']['native'] + $result['totals']['by_analysis_method']['scanner']) | Should -Be 5
        $result['undocumented'][0]['element_id'] | Should -BeExactly $ids[0]
        $result['deferred'][0]['element_id'] | Should -BeExactly $ids[1]
        $result['precision_limits'].Count | Should -Be 1
        $result['precision_limits'][0]['recorded'] | Should -BeTrue
        $result['stale_pages'].Count | Should -Be 1
        $result['stale_pages'][0]['page_path'] | Should -BeExactly $script:Page
        $result['parity']['accurate']['pass'] | Should -Be 6
        $run.Envelope['findings'].Count | Should -Be 0
        $run.Envelope['command'] | Should -BeExactly 'coverage'
    }

    It 'marks an unrecorded precision limit recorded false' {
        # Arrange
        $set = Get-TestCompleteSet -Snapshot $script:Snapshot
        $set.Ledger['entries'] = [object[]]@($set.Ledger['entries'] | Where-Object { -not $_['extensions'].Contains('docs.precision-limit') })
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $set)

        # Act
        $run = Invoke-TestCli -Command 'coverage' -Test $test -Json

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $limit = $run.Envelope['result']['precision_limits'][0]
        $limit['recorded'] | Should -BeFalse
        $null -eq $limit['owner'] | Should -BeTrue
        $limit['analyzer_id'] | Should -BeExactly 'fixture-scanner'
        $limit['diagnostic_id'] | Should -BeExactly $script:Snapshot['diagnostics'][0]['id']
    }

    It 'lists every element as undocumented and exits 0 without ledger, matrix or pins' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot)

        # Act
        $run = Invoke-TestCli -Command 'coverage' -Test $test -Json

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Envelope['ok'] | Should -BeTrue
        $run.Envelope['result']['undocumented'].Count | Should -Be 6
        $run.Envelope['result']['totals']['undocumented'] | Should -Be 6
        $run.Envelope['result']['stale_pages'].Count | Should -Be 0
        $null -eq $run.Envelope['result']['parity']['exists']['score_basis_points'] | Should -BeTrue
        @($test.CallLog | Where-Object { $_.Member -ceq 'TestFile' } | ForEach-Object { $_.RelativePath }) | Should -Contain 'estate/docs-coverage-ledger.json'
    }

    It 'makes zero WriteText calls' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

        # Act
        $run = Invoke-TestCli -Command 'coverage' -Test $test -Json

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Get-TestWriteCallCount -Test $test | Should -Be 0
        $test.WriteLog.Count | Should -Be 0
        @($test.CallLog | ForEach-Object { $_.Member } | Sort-Object -Unique) | Should -Be @('ListFile', 'ReadBytes', 'TestFile')
    }

    It 'exits 1 with DOCS_INPUT_UNREADABLE and null result for an absent snapshot' {
        # Arrange
        $test = New-DocsLedgerTestContext -File (New-TestEstate -NoSnapshot)
        $noProfile = New-DocsLedgerTestContext -File (New-TestEstate -NoProfile)

        # Act
        $run = Invoke-TestCli -Command 'coverage' -Test $test -Json
        $profileRun = Invoke-TestCli -Command 'coverage' -Test $noProfile -Json

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Envelope['findings'].Count | Should -Be 1
        $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_INPUT_UNREADABLE'
        $run.Envelope['findings'][0]['artifact_path'] | Should -BeExactly 'estate/surface-inventory-snapshot.json'
        $null -eq $run.Envelope['result'] | Should -BeTrue
        $run.Envelope['ok'] | Should -BeFalse
        $profileRun.Outcome.ExitCode | Should -Be 1
        $profileRun.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_PROFILE_MISSING'
        $null -eq $profileRun.Envelope['result'] | Should -BeTrue
    }

    It 'exits 1 for a schema-invalid snapshot' {
        # Arrange
        $broken = New-DocsLedgerTestSnapshot
        $broken.Remove('analyzers')
        $tampered = New-DocsLedgerTestSnapshot
        $tampered['elements'][0]['element_id'] = 'cli-command-' + ('0' * 64)
        $badLedger = Get-TestCompleteSet -Snapshot $script:Snapshot
        $badLedger.Ledger['entries'][0]['disposition'] = 'unknown'

        # Act
        $schema = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $broken)) -Json
        $rebuild = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $tampered)) -Json
        $ledger = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $badLedger)) -Json

        # Assert
        $schema.Outcome.ExitCode | Should -Be 1
        $schema.Envelope['findings'][0]['code'] | Should -Match '^DOCS_SCHEMA_'
        $null -eq $schema.Envelope['result'] | Should -BeTrue
        $rebuild.Outcome.ExitCode | Should -Be 1
        $rebuild.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_SNAPSHOT_ELEMENT_INVALID'
        $ledger.Outcome.ExitCode | Should -Be 1
        @($ledger.Envelope['findings'] | Where-Object { $_['artifact_path'] -ceq 'estate/docs-coverage-ledger.json' }).Count | Should -BeGreaterThan 0
        $null -eq $ledger.Envelope['result'] | Should -BeTrue
    }

    It 'exits 2 with one DOCS_CLI_ARGUMENTS before any read' {
        foreach ($arguments in @(, @('-Unknown', 'x')), @(, @('-Profile')), @(, @('-Profile', '/abs.json')), @(, @('-Profile', '../p.json')), @(, @('extra'))) {
            # Arrange
            $test = New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)

            # Act
            $run = Invoke-TestCli -Command 'coverage' -Argument $arguments[0] -Test $test -Json

            # Assert
            $run.Outcome.ExitCode | Should -Be 2 -Because ($arguments[0] -join ' ')
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
            $null -eq $run.Envelope['result'] | Should -BeTrue
            $test.CallLog.Count | Should -Be 0 -Because 'a usage error is reported before any context read'
        }
    }

    It 'exits 3 with one DOCS_CLI_RUNTIME for an injected read failure and a non-UTC clock' {
        # Arrange
        $files = New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete
        $failing = New-DocsLedgerTestContext -File $files -ReadBytesFailure @{ 'estate/docs-coverage-ledger.json' = 'permission denied' }
        $local = New-DocsLedgerTestContext -File $files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Local))

        # Act
        $readRun = Invoke-TestCli -Command 'coverage' -Test $failing -Json
        $clockRun = Invoke-TestCli -Command 'coverage' -Test $local -Json

        # Assert
        foreach ($run in @($readRun, $clockRun)) {
            $run.Outcome.ExitCode | Should -Be 3
            $run.Envelope['findings'].Count | Should -Be 1
            $run.Envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
            $null -eq $run.Envelope['result'] | Should -BeTrue
            $run.Outcome.Stderr | Should -Match 'exit 3'
        }
        $readRun.Envelope['findings'][0]['message'].Contains('permission denied', [System.StringComparison]::Ordinal) | Should -BeTrue
        $clockRun.Envelope['findings'][0]['message'].Contains('DOCS_CLOCK_NOT_UTC', [System.StringComparison]::Ordinal) | Should -BeTrue
        $local.CallLog.Count | Should -Be 0 -Because 'the clock is read before any file'
    }

    It 'emits an envelope with no finding from Test-DocsArtifactText docs-command-envelope' {
        # Arrange
        $cases = @(
            @{ Test = (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)); Argument = @() }
            @{ Test = (New-DocsLedgerTestContext -File (New-TestEstate -NoSnapshot)); Argument = @() }
            @{ Test = (New-DocsLedgerTestContext -File (New-TestEstate)); Argument = @('-Nope') }
            @{ Test = (New-DocsLedgerTestContext -File (New-TestEstate) -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Unspecified))); Argument = @() }
        )

        # Act and Assert
        $codes = foreach ($case in $cases) {
            $run = Invoke-TestCli -Command 'coverage' -Argument $case.Argument -Test $case.Test -Json
            Get-TestEnvelopeFindingCount -Text $run.Outcome.Stdout | Should -Be 0 -Because "exit $($run.Outcome.ExitCode)"
            $run.Envelope['command'] | Should -BeExactly 'coverage'
            $run.Envelope['ok'] | Should -Be ($run.Outcome.ExitCode -eq 0)
            $run.Outcome.ExitCode
        }
        @($codes) | Should -Be @(0, 1, 2, 3)
    }

    It 'produces byte-identical Json stdout for identical runs' {
        # Act
        $first = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)) -Json
        $second = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete)) -Json

        # Assert
        $first.Outcome.Stdout | Should -BeExactly $second.Outcome.Stdout
        $first.Outcome.Stdout.EndsWith("`n") | Should -BeTrue
    }

    It 'prints finding lines and the summary line without Json' {
        # Act
        $pass = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -Snapshot $script:Snapshot -Set $script:Complete))
        $fail = Invoke-TestCli -Command 'coverage' -Test (New-DocsLedgerTestContext -File (New-TestEstate -NoSnapshot))

        # Assert
        $passLines = @($pass.Outcome.Stdout.TrimEnd("`n") -split "`n")
        $passLines[0] | Should -Match '^coverage: elements=6 '
        $passLines[-1] | Should -BeExactly 'coverage: exit=0 errors=0 warnings=0 infos=0'
        $passLines | Should -Contain 'parity exists pass=6 fail=0 not_assessed=0 not_applicable=0 score_basis_points=10000'
        $failLines = @($fail.Outcome.Stdout.TrimEnd("`n") -split "`n")
        $failLines[0] | Should -Match '^error DOCS_INPUT_UNREADABLE estate/surface-inventory-snapshot.json: '
        $failLines[-1] | Should -BeExactly 'coverage: exit=1 errors=1 warnings=0 infos=0'
        $pass.Outcome.Stdout.Contains('{', [System.StringComparison]::Ordinal) | Should -BeFalse
    }
}
