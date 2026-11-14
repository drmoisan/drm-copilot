<#
.SYNOPSIS
    The coverage report of the documentation library: the result of the coverage subcommand and
    its text lines.

.DESCRIPTION
    Get-DocsCoverageReport builds {totals, undocumented, deferred, precision_limits, stale_pages,
    parity} over a snapshot view, a ledger, a parity matrix and a pin collection;
    ConvertTo-DocsCoverageReportLine renders it as text lines. The report is split from
    DocsLedgerCommands.psm1 under the file-size guidance. Identifier and path comparisons are
    ordinal and case-sensitive; every sort is ordinal.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1023. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsParity.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsStaleness.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReceipt.psm1') -ErrorAction Stop

$script:DocsCoverageReportMarkerKey = 'docs.precision-limit'

function Get-DocsCoverageReportMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function Get-DocsCoverageReport {
    <#
    .SYNOPSIS
        Returns the coverage result {totals, undocumented, deferred, precision_limits, stale_pages, parity}.
    .DESCRIPTION
        totals is the receipt counts object (Measure-DocsReceiptCount in docs-complete mode) plus
        by_analysis_method {native, scanner} over the unmarked ledger entries matching current
        elements. undocumented lists the elements without such an entry as
        {element_id, kind, declaration, path}; deferred lists the deferred element entries as
        {element_id, owner, target}; precision_limits lists every precision limit of the view as
        {element_id, diagnostic_id, analyzer_id, code, path, owner, target, recorded}, recorded
        false (owner and target null) when the ledger has no entry for its id. Each list is
        sorted by element_id. stale_pages is Get-DocsStalePage and parity Measure-DocsParityScore.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotView,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet
    )

    $elements = $SnapshotView['Element']
    $limits = $SnapshotView['PrecisionLimit']
    $byId = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $methods = [ordered]@{ native = [long] 0; scanner = [long] 0 }
    foreach ($entry in @(Get-DocsCoverageReportMember -Table $Ledger -Name 'entries')) {
        if ($entry -isnot [System.Collections.IDictionary]) { continue }
        $id = [string] (Get-DocsCoverageReportMember -Table $entry -Name 'element_id')
        if ($byId.ContainsKey($id)) { continue }
        $byId[$id] = $entry
        $extensions = Get-DocsCoverageReportMember -Table $entry -Name 'extensions'
        if ($extensions -is [System.Collections.IDictionary] -and $extensions.Contains($script:DocsCoverageReportMarkerKey)) { continue }
        if (-not $elements.Contains($id)) { continue }
        $method = [string] (Get-DocsCoverageReportMember -Table $entry -Name 'analysis_method')
        if ($methods.Contains($method)) { $methods[$method] = $methods[$method] + 1 }
    }
    $stale = Get-DocsStalePage -PinSet $PinSet -Element $elements
    $totals = Measure-DocsReceiptCount -Mode 'docs-complete' -SnapshotView $SnapshotView -Ledger $Ledger -StalePageCount ([long] @($stale).Count)
    $totals['by_analysis_method'] = $methods

    [string[]] $elementIds = @($elements.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($elementIds, [System.StringComparer]::Ordinal)
    $undocumented = [System.Collections.Generic.List[object]]::new()
    $deferred = [System.Collections.Generic.List[object]]::new()
    foreach ($id in $elementIds) {
        $element = $elements[$id]
        $entry = if ($byId.ContainsKey($id)) { $byId[$id] } else { $null }
        $marked = $null -ne $entry -and ((Get-DocsCoverageReportMember -Table $entry -Name 'extensions') -is [System.Collections.IDictionary]) -and (Get-DocsCoverageReportMember -Table $entry -Name 'extensions').Contains($script:DocsCoverageReportMarkerKey)
        if ($null -eq $entry -or $marked) {
            $undocumented.Add([ordered]@{ element_id = $id; kind = [string] (Get-DocsCoverageReportMember -Table $element -Name 'kind'); declaration = [string] (Get-DocsCoverageReportMember -Table $element -Name 'declaration'); path = [string] (Get-DocsCoverageReportMember -Table $element -Name 'path') })
            continue
        }
        if ([string] (Get-DocsCoverageReportMember -Table $entry -Name 'disposition') -ceq 'deferred') {
            $deferred.Add([ordered]@{ element_id = $id; owner = (Get-DocsCoverageReportMember -Table $entry -Name 'owner'); target = (Get-DocsCoverageReportMember -Table $entry -Name 'target') })
        }
    }
    [string[]] $limitIds = @($limits.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($limitIds, [System.StringComparer]::Ordinal)
    $precision = [System.Collections.Generic.List[object]]::new()
    foreach ($id in $limitIds) {
        $limit = $limits[$id]
        $entry = if ($byId.ContainsKey($id)) { $byId[$id] } else { $null }
        $precision.Add([ordered]@{
                element_id    = $id
                diagnostic_id = [string] $limit['DiagnosticId']
                analyzer_id   = [string] $limit['AnalyzerId']
                code          = [string] $limit['Code']
                path          = [string] $limit['Path']
                owner         = (Get-DocsCoverageReportMember -Table $entry -Name 'owner')
                target        = (Get-DocsCoverageReportMember -Table $entry -Name 'target')
                recorded      = ($null -ne $entry)
            })
    }
    return [ordered]@{
        totals           = $totals
        undocumented     = [object[]] $undocumented.ToArray()
        deferred         = [object[]] $deferred.ToArray()
        precision_limits = [object[]] $precision.ToArray()
        stale_pages      = [object[]] @($stale)
        parity           = (Measure-DocsParityScore -Matrix $Matrix)
    }
}

function ConvertTo-DocsCoverageReportLine {
    <#
    .SYNOPSIS
        Returns the text lines of a coverage report: one totals line, one line per listed item, and one line per parity dimension.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Report)

    $lines = [System.Collections.Generic.List[string]]::new()
    $totals = $Report['totals']
    $disposition = $totals['by_disposition']
    $method = $totals['by_analysis_method']
    $lines.Add("coverage: elements=$($totals['elements_total']) undocumented=$($totals['undocumented']) documented=$($disposition['documented']) excluded=$($disposition['excluded']) deferred=$($disposition['deferred']) native=$($method['native']) scanner=$($method['scanner']) stale_pages=$($totals['stale_pages']) precision_limits=$(@($Report['precision_limits']).Count)")
    foreach ($item in @($Report['undocumented'])) { $lines.Add("undocumented $($item['element_id']) $($item['kind']) $($item['path']): $($item['declaration'])") }
    foreach ($item in @($Report['deferred'])) { $lines.Add("deferred $($item['element_id']) owner=$($item['owner']) target=$($item['target'])") }
    foreach ($item in @($Report['precision_limits'])) { $lines.Add("precision-limit $($item['element_id']) $($item['analyzer_id']) $($item['code']) $($item['path']) recorded=$(([string] $item['recorded']).ToLowerInvariant())") }
    foreach ($item in @($Report['stale_pages'])) { $lines.Add("stale $($item['page_path']): $(@($item['pins']).Count) pin(s)") }
    foreach ($name in @($Report['parity'].Keys)) {
        $counts = $Report['parity'][$name]
        $score = if ($null -eq $counts['score_basis_points']) { 'null' } else { [string] $counts['score_basis_points'] }
        $lines.Add("parity $name pass=$($counts['pass']) fail=$($counts['fail']) not_assessed=$($counts['not_assessed']) not_applicable=$($counts['not_applicable']) score_basis_points=$score")
    }
    return , [string[]] $lines.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsCoverageReport, `
    ConvertTo-DocsCoverageReportLine
