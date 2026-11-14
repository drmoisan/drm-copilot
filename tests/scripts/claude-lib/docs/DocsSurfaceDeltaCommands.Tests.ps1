#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 and the surface-delta dispatch
    row of .claude/lib/docs/Invoke-DocsCommand.ps1 (issue #1034).

.DESCRIPTION
    Drives Invoke-DocsSurfaceDeltaCommand and Invoke-DocsCommandCli with the in-memory command
    context of Docs.TestSupport.psm1, using its RevisionMap and RevisionFile parameters for base
    revisions and base artifacts. Each tested exit path's -Json envelope is validated against the
    composed envelope schema. No file is written and no process is started.
#>

BeforeAll {
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:ScriptPath = Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/Invoke-DocsCommand.ps1'
    . $script:ScriptPath
    Import-Module -Name (Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/DocsSurfaceDeltaCommands.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfileText = (Get-DocsTestExampleText)['docs-profile']
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:SnapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'
    $script:LedgerPath = 'docs/documentation-estate/docs-coverage-ledger.json'
    $script:PinsPath = 'docs/documentation-estate/docs-evidence-pins.json'
    $script:BaseRevision = 'fedcba9876543210fedcba9876543210fedcba98'
    $script:SourcePath = 'src/example_pkg/cli.py'
    $script:SourceText = "def inventory():`n    pass`n"
    $script:ElementId = 'cli-command-' + ('a' * 64)

    function Get-TestSnapshotText {
        param([string[]] $Id = @(), [string] $InputSha)
        $sha = if ($InputSha) { $InputSha } else { Get-DocsBytesSha256Hex -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($script:SourceText)) }
        $elements = @(foreach ($item in $Id) { [ordered]@{ element_id = $item; kind = 'cli-command'; path = $script:SourcePath; source_sha256 = ('1' * 64); analysis_method = 'native'; line_range = [ordered]@{ start = 1; end = 1 } } })
        return ConvertTo-Json -InputObject ([ordered]@{ artifact_kind = 'surface-inventory-snapshot'; inputs = @([ordered]@{ path = $script:SourcePath; sha256 = $sha; size = 1 }); elements = $elements }) -Depth 6 -Compress
    }

    function Get-TestLedgerText {
        param([string[]] $Id = @())
        $entries = @(foreach ($item in $Id) { [ordered]@{ element_id = $item; kind = 'cli-command'; disposition = 'documented' } })
        return ConvertTo-Json -InputObject ([ordered]@{ artifact_kind = 'docs-coverage-ledger'; entries = $entries }) -Depth 6 -Compress
    }

    function Get-TestDeltaContext {
        # Builds an in-memory context with a mapped base ref 'main' and base artifacts that hold no element.
        param([AllowNull()] [object] $HeadSnapshot, [string[]] $HeadLedgerId = @(), [switch] $UnmappedBase, [string] $WorkingSource)
        $files = @{ $script:ProfilePath = $script:ProfileText; $script:SourcePath = $(if ($WorkingSource) { $WorkingSource } else { $script:SourceText }); $script:LedgerPath = (Get-TestLedgerText -Id $HeadLedgerId) }
        if ($null -ne $HeadSnapshot) { $files[$script:SnapshotPath] = $HeadSnapshot }
        $revisionMap = if ($UnmappedBase) { @{} } else { @{ 'main' = $script:BaseRevision } }
        $revisionFile = @{ $script:BaseRevision = @{ $script:SnapshotPath = (Get-TestSnapshotText); $script:LedgerPath = (Get-TestLedgerText) } }
        return (New-DocsTestContext -File $files -RevisionMap $revisionMap -RevisionFile $revisionFile).Context
    }

    function Invoke-TestDeltaCli {
        param([object] $Context, [string[]] $CommandArgument)
        $outcome = Invoke-DocsCommandCli -Command 'surface-delta' -Json -Context $Context -CommandArgument $CommandArgument
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value
        $schemaFindings = Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $outcome.Stdout -ComposedSchemaSet $script:Composed
        return @{ Outcome = $outcome; Envelope = $envelope; SchemaFindings = @($schemaFindings); Codes = [string[]]@($envelope['findings'] | ForEach-Object { [string] $_['code'] }) }
    }
}

AfterAll {
    Remove-Module -Name DocsSurfaceDeltaCommands, DocsSurfaceDelta, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'surface-delta dispatch row' {
    It 'holds the surface-delta row on the line after the 1034 anchor' {
        # Arrange
        $lines = @(Get-Content -LiteralPath $script:ScriptPath)
        $index = [array]::IndexOf(@($lines | ForEach-Object { $_.Trim() }), '# --- 1034: surface-delta ---')

        # Assert
        $index | Should -BeGreaterThan 0
        $lines[$index + 1].Trim() | Should -BeLike "``[pscustomobject``]@{ Name = 'surface-delta'; *"
    }

    It 'registers exactly one surface-delta row bound to Invoke-DocsSurfaceDeltaCommand with Base and Profile' {
        # Act
        $rows = @((Get-DocsCommandTable) | Where-Object { [string] $_.Name -ceq 'surface-delta' })

        # Assert
        $rows.Count | Should -Be 1
        $rows[0].Function | Should -BeExactly 'Invoke-DocsSurfaceDeltaCommand'
        [System.IO.Path]::GetFileName([string] $rows[0].Module) | Should -BeExactly 'DocsSurfaceDeltaCommands.psm1'
        [string[]] $options = @($rows[0].Option.Keys)
        [Array]::Sort($options, [System.StringComparer]::Ordinal)
        $options | Should -Be @('Base', 'Profile')
        $rows[0].Option['Base'] | Should -BeExactly 'value'
        (Test-DocsCommandTable -Table (Get-DocsCommandTable)).Count | Should -Be 0
    }
}

Describe 'Invoke-DocsSurfaceDeltaCommand' {
    It 'exits 2 with one DOCS_CLI_ARGUMENTS finding and a null result for -Base <Base>' -ForEach @(
        @{ Base = '--upload-pack=x' }
        @{ Base = 'main..topic' }
    ) {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText)) -CommandArgument @('-Base', $Base)

        # Assert
        $run.Outcome.ExitCode | Should -Be 2
        $run.Codes | Should -Be @('DOCS_CLI_ARGUMENTS')
        $run.Envelope['result'] | Should -BeNullOrEmpty
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 2 when -Base is omitted or -Profile is not repository-relative' -ForEach @(
        @{ Argument = @() }
        @{ Argument = @('-Base', 'main', '-Profile', '/abs/profile.json') }
    ) {
        # Act
        $result = Invoke-DocsSurfaceDeltaCommand -Argument (ConvertFrom-DocsCommandArgument -CommandArgument $Argument -OptionSpec @{ Base = 'value'; Profile = 'value' }).Argument -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText))

        # Assert
        $result.ExitCode | Should -Be 2
    }

    It 'exits 1 with DOCS_SURFACE_BASE_UNRESOLVED for an unmapped base' {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText) -UnmappedBase) -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Codes | Should -Be @('DOCS_SURFACE_BASE_UNRESOLVED')
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 1 with DOCS_SURFACE_SNAPSHOT_MISSING when the head snapshot is absent' {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot $null) -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Codes | Should -Be @('DOCS_SURFACE_SNAPSHOT_MISSING')
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 1 with DOCS_SURFACE_SNAPSHOT_STALE when the working-tree bytes changed' {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText) -WorkingSource 'changed text') -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Codes | Should -Be @('DOCS_SURFACE_SNAPSHOT_STALE')
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 1 with DOCS_SURFACE_UNLEDGERED_ADDITION for an added cli-command with an unchanged ledger' {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText -Id $script:ElementId)) -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Codes | Should -Be @('DOCS_SURFACE_UNLEDGERED_ADDITION')
        $run.Envelope['result']['added'] | Should -Be @($script:ElementId)
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 0 with the element in result.added when the head ledger records it' {
        # Act
        $run = Invoke-TestDeltaCli -Context (Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText -Id $script:ElementId) -HeadLedgerId @($script:ElementId)) -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        [string[]] $keys = @($run.Envelope['result'].Keys)
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        $keys | Should -Be @('added', 'base_revision', 'changed', 'removed')
        $run.Envelope['result']['base_revision'] | Should -BeExactly $script:BaseRevision
        $run.Envelope['result']['added'] | Should -Be @($script:ElementId)
        $run.SchemaFindings.Count | Should -Be 0
    }

    It 'exits 1 with DOCS_PROFILE_MISSING when the profile is absent' {
        # Arrange
        $context = (New-DocsTestContext -File @{} -RevisionMap @{ 'main' = $script:BaseRevision }).Context

        # Act
        $run = Invoke-TestDeltaCli -Context $context -CommandArgument @('-Base', 'main')

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Codes | Should -Be @('DOCS_PROFILE_MISSING')
    }

    It 'exits 1 with the profile findings for an invalid profile' {
        # Arrange
        $context = (New-DocsTestContext -File @{ $script:ProfilePath = '{}' } -RevisionMap @{ 'main' = $script:BaseRevision }).Context

        # Act
        $result = Invoke-DocsSurfaceDeltaCommand -Argument @{ Base = 'main' } -Context $context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings).Count | Should -BeGreaterThan 0
    }

    It 'exits 1 with a JSON finding for an unreadable head ledger' {
        # Arrange
        $context = Get-TestDeltaContext -HeadSnapshot (Get-TestSnapshotText)
        $null = & $context.WriteText $script:LedgerPath '{"entries":' 'overwrite'

        # Act
        $result = Invoke-DocsSurfaceDeltaCommand -Argument @{ Base = 'main' } -Context $context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | ForEach-Object { [string] $_['code'] }) | Should -Contain 'DOCS_JSON_INVALID'
    }

    It 'accepts a full revision as -Base' {
        # Arrange
        $context = (New-DocsTestContext -File @{ $script:ProfilePath = $script:ProfileText; $script:SourcePath = $script:SourceText; $script:SnapshotPath = (Get-TestSnapshotText) } -RevisionMap @{ $script:BaseRevision = $script:BaseRevision }).Context

        # Act
        $result = Invoke-DocsSurfaceDeltaCommand -Argument @{ Base = $script:BaseRevision } -Context $context

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Result['base_revision'] | Should -BeExactly $script:BaseRevision
    }
}
