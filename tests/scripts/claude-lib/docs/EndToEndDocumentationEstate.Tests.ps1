#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end test of the documentation-estate tooling over one in-memory fixture repository
    (issue #1038).

.DESCRIPTION
    Dot-sources .claude/lib/docs/Invoke-DocsCommand.ps1 and runs inventory, update-ledger,
    generate-reference and validate -Mode docs-complete in process through Invoke-DocsCommandCli,
    with one stateful in-memory context from DocumentationEstateFixture.TestSupport.psm1 per Context.
    Each Context replays the scenario once, in its BeforeAll, through Invoke-EstateScenario up to a
    named step (D-3a); its It blocks only read that result, so no state is shared between Context
    blocks:
    - Baseline: at revision R1 every element is documented, bound to the CLI reference page,
      generated, pinned and assessed, and docs-complete passes.
    - Defects: a line inside command A's declaration lines changes and command B is added at R2;
      docs-complete fails with DOCS_LEDGER_MISSING_DISPOSITION for B and DOCS_STALE_PAGE for A.
    - Fixed: B is recorded, A is re-pinned, the page is regenerated and docs-complete passes.
    - Unpinned: inventory without -Revision makes docs-complete fail closed with
      DOCS_SNAPSHOT_UNPINNED.
    Every inventory runs with -AnalysisMethod scanner, so the InvokeProcess fake records no call.
    No file is written and no process starts.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Each Context BeforeAll assigns the scenario result that its It blocks read')]
param()

BeforeAll {
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    . (Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/Invoke-DocsCommand.ps1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocumentationEstateFixture.TestSupport.psm1') -Force -ErrorAction Stop

    # The commands read the runtime schemas through the context, so the in-memory repository holds
    # the committed schema texts at their runtime paths (read once here).
    $script:SchemaFile = @{}
    $schemaText = Get-DocsTestSchemaText
    foreach ($name in @($schemaText.Keys)) { $script:SchemaFile[".claude/lib/docs/schemas/v1/$name.schema.json"] = [string] $schemaText[$name] }

    $script:Page = 'docs/reference/cli-reference.md'
    $script:SnapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'
    $script:LedgerPath = 'docs/documentation-estate/docs-coverage-ledger.json'
    $script:DeclarationA = 'fixture-tool sync'
    $script:DeclarationB = 'fixture-tool export'
    $script:Actor = @('-ActorKind', 'tool', '-ActorId', 'estate-fixture')

    function Invoke-EstateCommand {
        # Runs one subcommand in process and parses its envelope; throws when ExpectedExitCode differs.
        param(
            [Parameter(Mandatory = $true)] [hashtable] $Test,
            [Parameter(Mandatory = $true)] [string] $Command,
            [AllowEmptyCollection()] [string[]] $Argument = @(),
            [int] $ExpectedExitCode = -1
        )
        $outcome = Invoke-DocsCommandCli -Command $Command -Json -CommandArgument $Argument -Context $Test.Context
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value
        if ($ExpectedExitCode -ge 0 -and $outcome.ExitCode -ne $ExpectedExitCode) {
            $codes = @($envelope['findings'] | ForEach-Object { '{0}: {1}' -f $_['code'], $_['message'] }) -join ' | '
            throw "$Command $($Argument -join ' ') exited $($outcome.ExitCode), expected $ExpectedExitCode. Findings: $codes"
        }
        return @{ ExitCode = $outcome.ExitCode; Envelope = $envelope }
    }

    function Get-EstateDocument {
        # Reads one JSON artifact from the context map.
        param([Parameter(Mandatory = $true)] [hashtable] $Test, [Parameter(Mandatory = $true)] [string] $Path)
        return (ConvertFrom-DocsJsonText -Text $Test.Files[$Path]).Value
    }

    function Get-EstateElementId {
        # Returns the element identifier of a cli-command declaration in the current snapshot.
        param([Parameter(Mandatory = $true)] [hashtable] $Test, [Parameter(Mandatory = $true)] [string] $Declaration)
        $snapshot = Get-EstateDocument -Test $Test -Path $script:SnapshotPath
        $match = @($snapshot['elements'] | Where-Object { $_['kind'] -ceq 'cli-command' -and $_['declaration'] -ceq $Declaration })
        if ($match.Count -ne 1) { throw "The snapshot holds $($match.Count) cli-command elements declared '$Declaration'." }
        return [string] $match[0]['element_id']
    }

    function Add-EstateCapture {
        # Records the snapshot and ledger of the context map after one step.
        param([Parameter(Mandatory = $true)] [hashtable] $Test, [Parameter(Mandatory = $true)] [hashtable] $Capture, [Parameter(Mandatory = $true)] [string] $Step)
        $Capture[$Step] = @{
            Snapshot = Get-EstateDocument -Test $Test -Path $script:SnapshotPath
            Ledger   = Get-EstateDocument -Test $Test -Path $script:LedgerPath
        }
    }

    function Invoke-EstateDocumentElement {
        # Runs the named update-ledger operations for one element in the order disposition, pin,
        # dimension: records it as documented on the page, pins it, assesses the required dimension.
        param(
            [Parameter(Mandatory = $true)] [hashtable] $Test,
            [Parameter(Mandatory = $true)] [string] $ElementId,
            [Parameter(Mandatory = $true)] [ValidateSet('Disposition', 'Pin', 'Dimension')] [string[]] $LedgerOperation
        )
        if ($LedgerOperation -contains 'Disposition') {
            $null = Invoke-EstateCommand -Test $Test -Command 'update-ledger' -Argument (@('-Operation', 'set-disposition', '-Element', $ElementId, '-Disposition', 'documented', '-Page', $script:Page, '-Write') + $script:Actor) -ExpectedExitCode 0
        }
        if ($LedgerOperation -contains 'Pin') {
            $null = Invoke-EstateCommand -Test $Test -Command 'update-ledger' -Argument (@('-Operation', 'pin', '-Element', $ElementId, '-Page', $script:Page, '-Write') + $script:Actor) -ExpectedExitCode 0
        }
        if ($LedgerOperation -contains 'Dimension') {
            $null = Invoke-EstateCommand -Test $Test -Command 'update-ledger' -Argument (@('-Operation', 'set-dimension', '-Element', $ElementId, '-Page', $script:Page, '-Dimension', 'exists', '-State', 'pass', '-Write') + $script:Actor) -ExpectedExitCode 0
        }
    }

    function Invoke-EstateScenario {
        # Builds a fresh fixture context and replays the scenario up to Through (D-3).
        param([Parameter(Mandatory = $true)] [ValidateSet('Baseline', 'Defects', 'Fixed', 'Unpinned')] [string] $Through)
        $files = Get-DocumentationEstateFixtureFile
        foreach ($path in $script:SchemaFile.Keys) { $files[$path] = $script:SchemaFile[$path] }
        $test = New-DocumentationEstateFixtureContext -Files $files
        $runs = @{}
        $capture = @{}

        # Baseline at R1: inventory, dispositions, generation, pins, dimensions, sync-refs, validate.
        $null = Invoke-EstateCommand -Test $test -Command 'inventory' -Argument @('-Revision', $DocumentationEstateRevision1, '-AnalysisMethod', 'scanner', '-Write') -ExpectedExitCode 0
        $ids = @((Get-EstateDocument -Test $test -Path $script:SnapshotPath)['elements'] | ForEach-Object { [string] $_['element_id'] })
        foreach ($id in $ids) { Invoke-EstateDocumentElement -Test $test -ElementId $id -LedgerOperation 'Disposition' }
        $null = Invoke-EstateCommand -Test $test -Command 'generate-reference' -Argument @('-Write') -ExpectedExitCode 0
        foreach ($id in $ids) { Invoke-EstateDocumentElement -Test $test -ElementId $id -LedgerOperation 'Pin', 'Dimension' }
        $null = Invoke-EstateCommand -Test $test -Command 'update-ledger' -Argument (@('-Operation', 'sync-refs', '-Write') + $script:Actor) -ExpectedExitCode 0
        $runs['Baseline'] = Invoke-EstateCommand -Test $test -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $DocumentationEstateRevision1)
        Add-EstateCapture -Test $test -Capture $capture -Step 'Baseline'
        if ($Through -ceq 'Baseline') { return @{ Test = $test; Run = $runs; Capture = $capture } }

        # Unpinned: from the complete R1 estate, inventory without -Revision writes a snapshot whose
        # revision is null; validate requires -Revision, so it names R1 and fails closed.
        if ($Through -ceq 'Unpinned') {
            $null = Invoke-EstateCommand -Test $test -Command 'inventory' -Argument @('-AnalysisMethod', 'scanner', '-Write') -ExpectedExitCode 0
            $runs['Unpinned'] = Invoke-EstateCommand -Test $test -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $DocumentationEstateRevision1)
            return @{ Test = $test; Run = $runs; Capture = $capture }
        }

        # Defects at R2: A's help line changes inside its line range and B is added.
        $edit = Get-DocumentationEstateRevision2Edit
        $test.Files[$edit.Path] = $edit.Text
        $null = Invoke-EstateCommand -Test $test -Command 'inventory' -Argument @('-Revision', $DocumentationEstateRevision2, '-AnalysisMethod', 'scanner', '-Write') -ExpectedExitCode 0
        $null = Invoke-EstateCommand -Test $test -Command 'update-ledger' -Argument (@('-Operation', 'sync-refs', '-Write') + $script:Actor) -ExpectedExitCode 0
        $runs['Defects'] = Invoke-EstateCommand -Test $test -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $DocumentationEstateRevision2)
        Add-EstateCapture -Test $test -Capture $capture -Step 'Defects'
        if ($Through -ceq 'Defects') { return @{ Test = $test; Run = $runs; Capture = $capture } }

        # Fixed: B recorded and assessed, the page regenerated, A re-pinned.
        $idA = Get-EstateElementId -Test $test -Declaration $script:DeclarationA
        $idB = Get-EstateElementId -Test $test -Declaration $script:DeclarationB
        Invoke-EstateDocumentElement -Test $test -ElementId $idB -LedgerOperation 'Disposition'
        $null = Invoke-EstateCommand -Test $test -Command 'generate-reference' -Argument @('-Write') -ExpectedExitCode 0
        Invoke-EstateDocumentElement -Test $test -ElementId $idB -LedgerOperation 'Pin', 'Dimension'
        Invoke-EstateDocumentElement -Test $test -ElementId $idA -LedgerOperation 'Pin'
        $null = Invoke-EstateCommand -Test $test -Command 'update-ledger' -Argument (@('-Operation', 'sync-refs', '-Write') + $script:Actor) -ExpectedExitCode 0
        $runs['Fixed'] = Invoke-EstateCommand -Test $test -Command 'validate' -Argument @('-Mode', 'docs-complete', '-Revision', $DocumentationEstateRevision2)
        Add-EstateCapture -Test $test -Capture $capture -Step 'Fixed'
        return @{ Test = $test; Run = $runs; Capture = $capture }
    }

    function Get-EstateErrorFinding {
        # Returns the error findings of an envelope with the given code.
        param([Parameter(Mandatory = $true)] [object] $Envelope, [Parameter(Mandatory = $true)] [string] $Code)
        return @($Envelope['findings'] | Where-Object { $_['code'] -ceq $Code -and $_['severity'] -ceq 'error' })
    }
}

AfterAll {
    Remove-Module -Name 'DocumentationEstateFixture.TestSupport', 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'documentation estate end to end' {
    Context 'baseline at revision R1' {
        BeforeAll {
            $scenario = Invoke-EstateScenario -Through 'Baseline'
        }

        It 'passes docs-complete at revision R1 after inventory, ledger and generation' {
            # Act
            $run = $scenario.Run['Baseline']

            # Assert
            $run.ExitCode | Should -Be 0 -Because (@($run.Envelope['findings'] | ForEach-Object { $_['code'] }) -join ', ')
            $run.Envelope['result']['validation_result'] | Should -BeExactly 'pass'
            $run.Envelope['result']['revision'] | Should -BeExactly $DocumentationEstateRevision1
            $scenario.Test.Files.ContainsKey($script:Page) | Should -BeTrue -Because 'generate-reference -Write created the bound page'
        }
    }

    Context 'defects at revision R2' {
        BeforeAll {
            $scenario = Invoke-EstateScenario -Through 'Defects'
        }

        It 'fails docs-complete at revision R2 with exit code 1' {
            # Act
            $run = $scenario.Run['Defects']

            # Assert
            $run.ExitCode | Should -Be 1
            @($run.Envelope['findings'] | Where-Object { $_['severity'] -ceq 'error' } | ForEach-Object { $_['code'] } | Sort-Object -Unique) | Should -Be @('DOCS_LEDGER_MISSING_DISPOSITION', 'DOCS_STALE_PAGE')
        }

        It "reports DOCS_LEDGER_MISSING_DISPOSITION with the new command's element identifier and declaration" {
            # Arrange
            $idB = Get-EstateElementId -Test $scenario.Test -Declaration $script:DeclarationB

            # Act
            $missing = @(Get-EstateErrorFinding -Envelope $scenario.Run['Defects'].Envelope -Code 'DOCS_LEDGER_MISSING_DISPOSITION')

            # Assert
            $missing.Count | Should -Be 1
            @($missing[0]['related_ids']) | Should -Contain $idB
            $missing[0]['message'].Contains($script:DeclarationB, [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the finding names the declaration of B'
        }

        It "reports DOCS_STALE_PAGE with the stale page path and the changed command's declaration" {
            # Act
            $stale = @(Get-EstateErrorFinding -Envelope $scenario.Run['Defects'].Envelope -Code 'DOCS_STALE_PAGE')

            # Assert
            $stale.Count | Should -Be 1
            @($stale[0]['related_paths']) | Should -Contain $script:Page
            $stale[0]['message'].Contains($script:DeclarationA, [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the finding names the declaration of A'
            $stale[0]['message'].Contains('digest-changed', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'returns a receipt whose validation_result is fail' {
            # Act
            $run = $scenario.Run['Defects']

            # Assert
            $run.Envelope['result']['validation_result'] | Should -BeExactly 'fail'
            $run.Envelope['result']['revision'] | Should -BeExactly $DocumentationEstateRevision2
        }
    }

    Context 'fixes at revision R2' {
        BeforeAll {
            $scenario = Invoke-EstateScenario -Through 'Fixed'
        }

        It 'passes docs-complete at revision R2 after the ledger and page are fixed' {
            # Act
            $run = $scenario.Run['Fixed']

            # Assert
            $run.ExitCode | Should -Be 0 -Because (@($run.Envelope['findings'] | ForEach-Object { $_['code'] }) -join ', ')
            $run.Envelope['result']['validation_result'] | Should -BeExactly 'pass'
        }

        It 'records analysis_method scanner on every inventory snapshot element in every step' {
            # Act
            $capture = $scenario.Capture

            # Assert
            foreach ($step in 'Baseline', 'Defects', 'Fixed') {
                $elements = @($capture[$step].Snapshot['elements'])
                $elements.Count | Should -BeGreaterThan 0 -Because "the $step snapshot holds elements"
                foreach ($element in $elements) { $element['analysis_method'] | Should -BeExactly 'scanner' -Because "$step element $($element['declaration'])" }
            }
        }

        It 'records analysis_method scanner on every ledger entry in every step' {
            # Act
            $capture = $scenario.Capture

            # Assert
            foreach ($step in 'Baseline', 'Defects', 'Fixed') {
                $entries = @($capture[$step].Ledger['entries'])
                $entries.Count | Should -BeGreaterThan 0 -Because "the $step ledger holds entries"
                foreach ($entry in $entries) { $entry['analysis_method'] | Should -BeExactly 'scanner' -Because "$step entry $($entry['element_id'])" }
            }
        }

        It 'records no InvokeProcess call under -AnalysisMethod scanner' {
            # Act: the Context BeforeAll replays the scenario through the Fixed step.

            # Assert
            $scenario.Test.ProcessCallLog.Count | Should -Be 0
        }
    }

    Context 'inventory without a revision' {
        BeforeAll {
            $scenario = Invoke-EstateScenario -Through 'Unpinned'
        }

        It 'fails closed with DOCS_SNAPSHOT_UNPINNED when inventory ran without a revision' {
            # Act
            $run = $scenario.Run['Unpinned']

            # Assert
            $codes = @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) -join ', '
            $run.ExitCode | Should -Be 1 -Because $codes
            @(Get-EstateErrorFinding -Envelope $run.Envelope -Code 'DOCS_SNAPSHOT_UNPINNED').Count | Should -Be 1 -Because $codes
            $scenario.Test.ProcessCallLog.Count | Should -Be 0
        }
    }
}
