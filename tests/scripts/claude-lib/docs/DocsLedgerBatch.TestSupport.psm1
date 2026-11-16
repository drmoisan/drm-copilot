<#
.SYNOPSIS
    Test support for DocsLedgerBatch.Tests.ps1 and DocsLedgerBatch.Properties.Tests.ps1 (issue #1173 B2).

.DESCRIPTION
    New-DocsLedgerBatchTestEstate builds a consistent in-memory estate (every fixture element
    documented on one page with a current pin, the precision limit deferred) plus a second page.
    Get-DocsLedgerBatchTestDocument loads it through the private loader of DocsLedgerCommands.psm1
    (read in that module's scope), and Get-DocsLedgerBatchTestApply returns its private
    Invoke-DocsLedgerOperation, so the batch and the sequential path run the same single
    operation. Invoke-DocsLedgerBatchTestSequential applies items one at a time in input order
    (a claim item is a pin followed by the dimension), and New-DocsLedgerBatchTestSample returns
    the item sample that covers every batchable operation. Nothing is read from or written to
    disk except the committed schemas the loader composes.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The support module imports its own dependencies: in a PoshQC shard, the test file's imports are not visible here.
foreach ($name in 'DocsJson', 'DocsSurface', 'DocsLedger', 'DocsParity', 'DocsEvidencePins') { Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath "../../../../.claude/lib/docs/$name.psm1") -ErrorAction Stop }
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -ErrorAction Stop
$script:DocsLedgerBatchTestCommands = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsLedgerCommands.psm1') -PassThru -ErrorAction Stop

$script:DocsLedgerBatchTestActor = @{ kind = 'tool'; id = 'fixture-tool' }
$script:DocsLedgerBatchTestIssuedAt = '2026-03-01T12:00:00Z'
$script:DocsLedgerBatchTestPage = 'docs/reference/Cli.md'
$script:DocsLedgerBatchTestOtherPage = 'docs/reference/Other.md'

function Get-DocsLedgerBatchTestModule {
    <#
    .SYNOPSIS
        Returns the DocsLedgerCommands module instance this support module imported (private helper).
    #>
    [CmdletBinding()]
    [OutputType([psmoduleinfo])]
    param()

    return $script:DocsLedgerBatchTestCommands
}

function New-DocsLedgerBatchTestEstate {
    <#
    .SYNOPSIS
        Returns @{ Files; Ids; LimitId; Page; OtherPage; IssuedAt } for a consistent in-memory estate.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $snapshotText = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot) -Indented
    $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $snapshotText).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $snapshotText)
    $ids = [string[]] @($view.Element.Keys | Sort-Object)
    $page = $script:DocsLedgerBatchTestPage
    $actor = $script:DocsLedgerBatchTestActor
    $entries = @(foreach ($id in $ids) { New-DocsLedgerEntry -Element $view.Element[$id] -Disposition 'documented' -PageBinding @(@{ page_path = $page; anchor = $null }) -Actor $actor })
    $entries += @(foreach ($id in @($view.PrecisionLimit.Keys | Sort-Object)) { New-DocsPrecisionLimitEntry -Limit $view.PrecisionLimit[$id] -Owner 'docs-team' -Target 'Next release' -Actor $actor })
    $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $entries) { $sorted[[string] $entry['element_id']] = $entry }
    $ledgerText = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @($sorted.Values)) -Indented
    $pins = @(foreach ($id in $ids) { New-DocsEvidencePin -Element $view.Element[$id] -PagePath $page -Revision $view.Revision -PinnedAt $script:DocsLedgerBatchTestIssuedAt -Actor $actor })
    $rows = @(foreach ($pin in $pins) {
            $dimension = @{
                exists         = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
                accurate       = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@($pin['pin_id']) }
                owner_assigned = [ordered]@{ state = 'pass'; rationale = $null; evidence_pin_ids = [string[]]@() }
            }
            New-DocsLedgerTestRow -Element $view.Element[$pin['element_id']] -PagePath $page -Dimension $dimension
        })
    $files = [ordered]@{
        $page                                         = '# Cli'
        $script:DocsLedgerBatchTestOtherPage          = '# Other'
        'docs/documentation-estate/docs-profile.json' = (ConvertTo-DocsJsonText -Value (New-DocsLedgerTestProfile) -Indented)
        'estate/surface-inventory-snapshot.json'      = $snapshotText
        'estate/docs-coverage-ledger.json'            = $ledgerText
        'estate/docs-parity-matrix.json'              = (ConvertTo-DocsJsonText -Value (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 (Get-DocsSha256Hex -Text $ledgerText) -Row $rows) -Indented)
        'estate/docs-evidence-pins.json'              = (ConvertTo-DocsJsonText -Value (New-DocsLedgerTestPinSet -Pin $pins) -Indented)
    }
    $limitId = [string] $view.PrecisionLimit[@($view.PrecisionLimit.Keys)[0]]['DiagnosticId']
    return @{ Files = $files; Ids = $ids; LimitId = $limitId; Page = $page; OtherPage = $script:DocsLedgerBatchTestOtherPage; IssuedAt = $script:DocsLedgerBatchTestIssuedAt }
}

function Get-DocsLedgerBatchTestDocument {
    <#
    .SYNOPSIS
        Loads the document set of an in-memory estate through the private loader of DocsLedgerCommands.psm1.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $File)

    $context = (New-DocsLedgerTestContext -File $File).Context
    return & (Get-DocsLedgerBatchTestModule) {
        param($Context)
        $schemas = Get-DocsLedgerCommandSchemaSet
        $profileRead = Read-DocsLedgerCommandProfile -Command 'update-ledger' -ProfilePath (Get-DocsDefaultProfilePath) -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ComposedSchemaSet $schemas
        Read-DocsLedgerCommandDocumentSet -Command 'update-ledger' -Profile $profileRead.Profile -ComposedSchemaSet $schemas -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile
    } $context
}

function Get-DocsLedgerBatchTestApply {
    <#
    .SYNOPSIS
        Returns the private Invoke-DocsLedgerOperation of DocsLedgerCommands.psm1 as a scriptblock.
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param()

    return & (Get-DocsLedgerBatchTestModule) { ${function:Invoke-DocsLedgerOperation} }
}

function New-DocsLedgerBatchTestItem {
    <#
    .SYNOPSIS
        Returns one batch item @{ Index; Argument; Claim } with the fixture actor.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [AllowNull()] [string] $Claim
    )

    $map = [ordered]@{ ActorKind = 'tool'; ActorId = 'fixture-tool' }
    foreach ($key in $Argument.Keys) { $map[[string] $key] = $Argument[$key] }
    return @{ Index = $Index; Argument = $map; Claim = $(if ([string]::IsNullOrEmpty($Claim)) { $null } else { $Claim }) }
}

function New-DocsLedgerBatchTestSample {
    <#
    .SYNOPSIS
        Returns batch items that cover every batchable operation, interleaved across partitions.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [hashtable] $Estate)

    $ids = $Estate.Ids
    $page = $Estate.Page
    $other = $Estate.OtherPage
    $arguments = @(
        @{ Argument = [ordered]@{ Operation = 'set-disposition'; Element = $ids[0]; Disposition = 'excluded'; Rationale = 'Internal helper.' } }
        @{ Argument = [ordered]@{ Operation = 'set-disposition'; Element = $ids[2]; Disposition = 'documented'; Page = [string[]] @($page, $other) } }
        @{ Argument = [ordered]@{ Operation = 'unpin'; Element = $ids[1]; Page = [string[]] @($page) } }
        @{ Argument = [ordered]@{ Operation = 'remove-entry'; Limit = $Estate.LimitId } }
        @{ Argument = [ordered]@{ Operation = 'set-dimension'; Element = $ids[2]; Page = [string[]] @($other); Dimension = 'accurate'; State = 'pass' }; Claim = 'The page states the behavior.' }
        @{ Argument = [ordered]@{ Operation = 'remove-entry'; Element = $ids[3] } }
        @{ Argument = [ordered]@{ Operation = 'set-dimension'; Element = $ids[1]; Page = [string[]] @($page); Dimension = 'accurate'; State = 'fail'; Rationale = 'The page omits the option.' } }
        @{ Argument = [ordered]@{ Operation = 'pin'; Element = $ids[4]; Page = [string[]] @($page) } }
        @{ Argument = [ordered]@{ Operation = 'set-disposition'; Limit = $Estate.LimitId; Disposition = 'deferred'; Owner = 'docs-team'; Target = 'Next quarter' } }
        @{ Argument = [ordered]@{ Operation = 'set-dimension'; Element = $ids[4]; Page = [string[]] @($page); Dimension = 'owner_assigned'; State = 'fail'; Rationale = 'No owner.' } }
        @{ Argument = [ordered]@{ Operation = 'pin'; Element = $ids[2]; Page = [string[]] @($page) } }
        @{ Argument = [ordered]@{ Operation = 'set-dimension'; Element = $ids[5]; Page = [string[]] @($page); Dimension = 'exists'; State = 'not-assessed' } }
    )
    $items = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $arguments.Count; $index++) {
        $claim = if ($arguments[$index].ContainsKey('Claim')) { $arguments[$index]['Claim'] } else { $null }
        $items.Add((New-DocsLedgerBatchTestItem -Index $index -Argument $arguments[$index]['Argument'] -Claim $claim))
    }
    return , $items.ToArray()
}

function Invoke-DocsLedgerBatchTestSequential {
    <#
    .SYNOPSIS
        Applies items one at a time in input order through Invoke-DocsLedgerOperation; returns @{ Ledger; Matrix; PinSet; Finding }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Document,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [Parameter(Mandatory = $true)] [string] $IssuedAt
    )

    $apply = Get-DocsLedgerBatchTestApply
    $state = @{}
    foreach ($key in $Document.Keys) { $state[$key] = $Document[$key] }
    foreach ($item in $Item) {
        $steps = @()
        if ($null -ne $item.Claim) { $steps += , ([ordered]@{ Operation = 'pin'; Element = $item.Argument['Element']; Page = $item.Argument['Page']; Claim = $item.Claim; ActorKind = $item.Argument['ActorKind']; ActorId = $item.Argument['ActorId'] }) }
        $steps += , $item.Argument
        foreach ($step in $steps) {
            $result = & $apply -Argument $step -Documents $state -IssuedAt $IssuedAt
            if ($null -ne $result.Finding) { return @{ Finding = $result.Finding } }
            $state.Ledger = $result.Ledger
            $state.Matrix = $result.Matrix
            $state.PinSet = $result.PinSet
        }
    }
    return @{ Ledger = $state.Ledger; Matrix = $state.Matrix; PinSet = $state.PinSet; Finding = $null }
}

function ConvertTo-DocsLedgerBatchTestText {
    <#
    .SYNOPSIS
        Returns the indented JSON text of the ledger, matrix and pin collection of a result, joined by NUL.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Result)

    return (@($Result['Ledger'], $Result['Matrix'], $Result['PinSet']) | ForEach-Object { ConvertTo-DocsJsonText -Value $_ -Indented }) -join [string][char]0
}

Export-ModuleMember -Function New-DocsLedgerBatchTestEstate, Get-DocsLedgerBatchTestDocument, Get-DocsLedgerBatchTestApply, New-DocsLedgerBatchTestItem, New-DocsLedgerBatchTestSample, Invoke-DocsLedgerBatchTestSequential, ConvertTo-DocsLedgerBatchTestText
