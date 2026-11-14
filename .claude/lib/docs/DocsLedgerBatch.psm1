<#
.SYNOPSIS
    The update-ledger operations document of issue #1173 (B2, B3): parsing, item validation and
    batch-level option checks.

.DESCRIPTION
    ConvertFrom-DocsLedgerOperationText parses { "operations": [ ... ] }. Item keys are the MCP
    field names of update_docs_ledger (operation, element, limit, disposition, pages, rationale,
    owner, target, dimension, state, claim), mapped to the update-ledger argument names
    (Operation, Element, Limit, Disposition, Page, Rationale, Owner, Target, Dimension, State,
    Claim). Each item is validated by the injected ValidateArgument scriptblock (the unchanged
    Test-DocsUpdateLedgerArgument) with the batch actor and profile, so the single-operation
    grammar stays the only grammar. A claim is accepted only on a set-dimension item with
    dimension accurate and state pass, where it is applied as a pin first (B3); it is removed
    from the argument map before validation. Text that is not JSON, a root without an
    operations array, an empty array, an item that is not an object, an unknown key, a
    sync-refs item, a value of the wrong type, a misplaced claim and an item the validator
    rejects each give one DOCS_CLI_ARGUMENTS finding (exit 2); item findings carry the pointer
    /operations/<i>.

    Read-DocsLedgerOperationText reads the document from standard input ('-') or a repository-relative
    path through the injected ReadStdin and ReadText scriptblocks.

    Test-DocsLedgerBatchArgument checks the batch-level options of -Operations: the value is '-'
    or a repository-relative path, -Operation is absent, and no per-operation option is given.

    This module does not import DocsLedgerCommands.psm1 (decision D-1 of the plan); the
    validator is passed in as a scriptblock. Every function is pure apart from the injected
    scriptblocks.

.NOTES
    Issue #1173. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsLedgerBatchField = [ordered]@{
    operation   = 'Operation'
    element     = 'Element'
    limit       = 'Limit'
    disposition = 'Disposition'
    pages       = 'Page'
    rationale   = 'Rationale'
    owner       = 'Owner'
    target      = 'Target'
    dimension   = 'Dimension'
    state       = 'State'
    claim       = 'Claim'
}
$script:DocsLedgerBatchSeparator = [string][char]0
$script:DocsLedgerBatchPerOperationOption = [string[]]@('Element', 'Limit', 'Disposition', 'Page', 'Rationale', 'Owner', 'Target', 'Dimension', 'State', 'Claim')

function New-DocsLedgerBatchFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_ARGUMENTS error finding of the operations document (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowEmptyString()] [string] $Pointer = ''
    )

    return New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $Message -NextAction 'Correct the operations document; see the docs-reconcile-behavior skill for its shape.' -Pointer $Pointer
}

function Test-DocsLedgerBatchArgument {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_ARGUMENTS finding for invalid batch-level options of -Operations, or $null.
    .DESCRIPTION
        -Operations must be '-' (standard input) or a repository-relative path; -Operation and every
        per-operation option (Element, Limit, Disposition, Page, Rationale, Owner, Target,
        Dimension, State, Claim) are rejected together with -Operations.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument)

    $value = [string] $Argument['Operations']
    if ($value -cne '-' -and -not (Test-DocsRelativePath -Path $value)) { return New-DocsLedgerBatchFinding -Message "Operations '$value' is not '-' or a repository-relative path." }
    if ($Argument.Contains('Operation') -and $null -ne $Argument['Operation']) { return New-DocsLedgerBatchFinding -Message '-Operation and -Operations cannot both be given.' }
    foreach ($name in $script:DocsLedgerBatchPerOperationOption) {
        if ($Argument.Contains($name) -and $null -ne $Argument[$name]) { return New-DocsLedgerBatchFinding -Message "Option '-$name' is not accepted with -Operations; give it inside an operations item." }
    }
    return $null
}

function ConvertFrom-DocsLedgerOperationItem {
    <#
    .SYNOPSIS
        Maps one operations item to an argument map; returns @{ Argument; Claim; Message } (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [object] $Item)

    if ($Item -isnot [System.Collections.IDictionary]) { return @{ Message = 'the item is not an object' } }
    $argument = [ordered]@{}
    foreach ($key in @($Item.Keys)) {
        $name = [string] $key
        # Item keys are matched ordinally; an [ordered] dictionary would also accept 'Operation' for 'operation'.
        if (@($script:DocsLedgerBatchField.Keys) -cnotcontains $name) { return @{ Message = "the key '$name' is not an operations item field" } }
        $value = $Item[$key]
        if ($name -ceq 'pages') {
            if ($value -isnot [System.Array] -or @($value | Where-Object { $_ -isnot [string] }).Count -gt 0) { return @{ Message = 'pages is not an array of strings' } }
            $argument['Page'] = [string[]] @($value)
            continue
        }
        if ($value -isnot [string]) { return @{ Message = "$name is not a string" } }
        $argument[$script:DocsLedgerBatchField[$name]] = $value
    }
    $operation = if ($argument.Contains('Operation')) { [string] $argument['Operation'] } else { '' }
    if ($operation -ceq 'sync-refs') { return @{ Message = 'sync-refs is not a batch item; run it as its own update-ledger call' } }
    $claim = $null
    if ($argument.Contains('Claim')) {
        $accuratePass = $operation -ceq 'set-dimension' -and [string] $argument['Dimension'] -ceq 'accurate' -and [string] $argument['State'] -ceq 'pass'
        if (-not $accuratePass) { return @{ Message = 'claim is accepted only on a set-dimension item with dimension accurate and state pass' } }
        $claim = [string] $argument['Claim']
        if ([string]::IsNullOrWhiteSpace($claim)) { return @{ Message = 'claim must contain a non-whitespace character' } }
        $argument.Remove('Claim')
    }
    return @{ Argument = $argument; Claim = $claim; Message = $null }
}

function ConvertFrom-DocsLedgerOperationText {
    <#
    .SYNOPSIS
        Parses and validates an operations document; returns @{ Item; Finding }.
    .DESCRIPTION
        Item lists @{ Index; Argument; Claim } in input order, where Argument is the update-ledger
        argument map of the item with ActorKind, ActorId and (when given) ProfilePath as Profile added, and Claim
        is the accurate-pass claim or $null. Finding is $null, or one DOCS_CLI_ARGUMENTS finding
        (pointer /operations/<i> for an item) and Item is then empty. ValidateArgument receives
        each argument map and returns a finding or $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ActorKind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ActorId,
        [AllowNull()] [string] $ProfilePath,
        [Parameter(Mandatory = $true)] [scriptblock] $ValidateArgument
    )

    $parsed = ConvertFrom-DocsJsonText -Text $Text
    if (@($parsed.Findings).Count -gt 0) { return @{ Item = @(); Finding = (New-DocsLedgerBatchFinding -Message "The operations document is not valid JSON: $($parsed.Findings[0]['message'])") } }
    $root = $parsed.Value
    if ($root -isnot [System.Collections.IDictionary] -or -not $root.Contains('operations') -or $root['operations'] -isnot [System.Array]) { return @{ Item = @(); Finding = (New-DocsLedgerBatchFinding -Message 'The operations document has no operations array.' -Pointer '/operations') } }
    $operations = @($root['operations'])
    if ($operations.Count -eq 0) { return @{ Item = @(); Finding = (New-DocsLedgerBatchFinding -Message 'The operations array is empty.' -Pointer '/operations') } }
    $items = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $operations.Count; $index++) {
        $mapped = ConvertFrom-DocsLedgerOperationItem -Item $operations[$index]
        if ($null -ne $mapped.Message) { return @{ Item = @(); Finding = (New-DocsLedgerBatchFinding -Message "Operations item ${index}: $($mapped.Message)." -Pointer "/operations/$index") } }
        $argument = $mapped.Argument
        $argument['ActorKind'] = $ActorKind
        $argument['ActorId'] = $ActorId
        if (-not [string]::IsNullOrEmpty($ProfilePath)) { $argument['Profile'] = $ProfilePath }
        $finding = & $ValidateArgument $argument
        if ($null -ne $finding) { return @{ Item = @(); Finding = (New-DocsLedgerBatchFinding -Message "Operations item ${index}: $($finding['message'])" -Pointer "/operations/$index") } }
        $items.Add(@{ Index = $index; Argument = $argument; Claim = $mapped.Claim })
    }
    return @{ Item = $items.ToArray(); Finding = $null }
}

function Get-DocsLedgerBatchMember {
    <#
    .SYNOPSIS
        Returns a dictionary member, or $null when the key is absent (private helper).
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

function Copy-DocsLedgerBatchDocument {
    <#
    .SYNOPSIS
        Returns a shallow copy of Document whose Collection member holds Value (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Document,
        [Parameter(Mandatory = $true)] [string] $Collection,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Value
    )

    $copy = [ordered]@{}
    foreach ($key in @($Document.Keys)) { $copy[[string] $key] = $Document[$key] }
    $copy[$Collection] = [object[]] $Value
    return $copy
}

function Copy-DocsLedgerBatchFinding {
    <#
    .SYNOPSIS
        Returns a copy of Finding whose message names the operations item and whose pointer is /operations/<i> (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $copy = [ordered]@{}
    foreach ($key in @($Finding.Keys)) { $copy[[string] $key] = $Finding[$key] }
    $copy['message'] = "Operations item ${Index}: $($Finding['message'])"
    $copy['pointer'] = "/operations/$Index"
    return $copy
}

function Get-DocsLedgerBatchIndex {
    <#
    .SYNOPSIS
        Indexes the records of one collection by record key and by owner key; returns @{ Record; Owner } (private helper).
    .DESCRIPTION
        Record is an ordinal sorted dictionary from the record key to the record; Owner maps an
        owner key (element:<id> or limit:<diagnostic id>) to the record keys it owns.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Record,
        [Parameter(Mandatory = $true)] [scriptblock] $RecordKey,
        [Parameter(Mandatory = $true)] [scriptblock] $OwnerKey
    )

    $records = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $owners = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Record)) {
        if ($null -eq $item) { continue }
        $key = [string] (& $RecordKey $item)
        $records[$key] = $item
        foreach ($owner in @(& $OwnerKey $item)) {
            if (-not $owners.ContainsKey($owner)) { $owners[$owner] = [System.Collections.Generic.List[string]]::new() }
            $owners[$owner].Add($key)
        }
    }
    return @{ Record = $records; Owner = $owners }
}

function Get-DocsLedgerBatchRecordKey {
    <#
    .SYNOPSIS
        Returns the record key of a ledger entry (element_id), matrix row (element_id + NUL + page_path) or pin (pin_id) (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('Ledger', 'Matrix', 'PinSet')] [string] $Collection,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Record
    )

    if ($Collection -ceq 'Matrix') { return [string] (Get-DocsLedgerBatchMember -Table $Record -Name 'element_id') + $script:DocsLedgerBatchSeparator + [string] (Get-DocsLedgerBatchMember -Table $Record -Name 'page_path') }
    $name = if ($Collection -ceq 'Ledger') { 'element_id' } else { 'pin_id' }
    return [string] (Get-DocsLedgerBatchMember -Table $Record -Name $name)
}

function Read-DocsLedgerOperationText {
    <#
    .SYNOPSIS
        Returns the operations document text: standard input through ReadStdin for '-', else the repository-relative Source through ReadText.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Source,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadText,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadStdin
    )

    if ($Source -ceq '-') { return [string] (& $ReadStdin) }
    return [string] (& $ReadText $Source)
}

function Get-DocsLedgerBatchPartitionKey {
    <#
    .SYNOPSIS
        Returns the partition key of an argument map: limit:<diagnostic id> or element:<element id> (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument)

    $limit = [string] (Get-DocsLedgerBatchMember -Table $Argument -Name 'Limit')
    if ($limit.Length -gt 0) { return "limit:$limit" }
    return 'element:' + [string] (Get-DocsLedgerBatchMember -Table $Argument -Name 'Element')
}

function Invoke-DocsLedgerBatch {
    <#
    .SYNOPSIS
        Applies batch items to the loaded documents in one pass; returns @{ Documents; After; Outcome; Finding }.
    .DESCRIPTION
        LoadDocument is called once and returns the update-ledger document set; when its Result
        member is set, the set is returned as Documents and nothing is applied. Items (from
        ConvertFrom-DocsLedgerOperationText) are partitioned by target key, the element id or the
        precision-limit diagnostic id, keeping input order within a partition. For each partition
        reduced documents that hold only that key's ledger entries, matrix rows and pins are
        built, each item runs through ApplyOperation (the unchanged Invoke-DocsLedgerOperation),
        and the result is spliced into ordinal dictionaries keyed by element_id (ledger),
        element_id + NUL + page_path (matrix rows) and pin_id (pins). An item with a claim (a
        set-dimension accurate pass item, B3) runs a pin with that claim for the same element and
        page first. A bind-page-refs item without an element expands, in input order, into one
        bind item per referenced snapshot element of the PageReference member of the document set
        (decision D-2). A collection that no item touched (no merge helper returned a new document
        for it) keeps its loaded document; a touched one is rebuilt once in the order of the sort
        helpers, as the sequential path re-sorts a collection whenever a helper runs on it.
        CompareRule is called once with the loaded and the resulting documents and returns
        @{ NewErrors; ... }. A DOCS_UPDATE_TARGET_INVALID
        item or a new error rejects the whole batch: After is $null and Finding holds the findings
        with the item index in the message and the pointer /operations/<i> (a new error is
        attributed to the last item of the partition its related ids name). Otherwise After holds
        @{ Ledger; Matrix; PinSet } and Finding is empty. The function writes nothing.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [Parameter(Mandatory = $true)] [scriptblock] $LoadDocument,
        [Parameter(Mandatory = $true)] [scriptblock] $ApplyOperation,
        [Parameter(Mandatory = $true)] [scriptblock] $CompareRule,
        [Parameter(Mandatory = $true)] [string] $IssuedAt
    )

    $documents = & $LoadDocument
    if ($null -ne (Get-DocsLedgerBatchMember -Table $documents -Name 'Result')) { return @{ Documents = $documents; After = $null; Outcome = $null; Finding = @() } }
    $entryOwner = {
        param($Entry)
        $extensions = Get-DocsLedgerBatchMember -Table $Entry -Name 'extensions'
        $marker = Get-DocsLedgerBatchMember -Table $extensions -Name 'docs.precision-limit'
        if ($null -ne $marker) { 'limit:' + [string] (Get-DocsLedgerBatchMember -Table $marker -Name 'diagnostic_id') }
        'element:' + [string] (Get-DocsLedgerBatchMember -Table $Entry -Name 'element_id')
    }
    $elementOwner = { param($Record) 'element:' + [string] (Get-DocsLedgerBatchMember -Table $Record -Name 'element_id') }
    $collection = [ordered]@{
        Ledger = @{ Member = 'entries'; Index = (Get-DocsLedgerBatchIndex -Record @(Get-DocsLedgerBatchMember -Table $documents.Ledger -Name 'entries') -RecordKey { param($Entry) Get-DocsLedgerBatchRecordKey -Collection 'Ledger' -Record $Entry } -OwnerKey $entryOwner); Changed = $false }
        Matrix = @{ Member = 'rows'; Index = (Get-DocsLedgerBatchIndex -Record @(Get-DocsLedgerBatchMember -Table $documents.Matrix -Name 'rows') -RecordKey { param($Row) Get-DocsLedgerBatchRecordKey -Collection 'Matrix' -Record $Row } -OwnerKey $elementOwner); Changed = $false }
        PinSet = @{ Member = 'pins'; Index = (Get-DocsLedgerBatchIndex -Record @(Get-DocsLedgerBatchMember -Table $documents.PinSet -Name 'pins') -RecordKey { param($Pin) Get-DocsLedgerBatchRecordKey -Collection 'PinSet' -Record $Pin } -OwnerKey $elementOwner); Changed = $false }
    }

    # D-2: a bind-page-refs item without an element expands into one bind item per referenced snapshot element.
    $expanded = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Item) {
        $isBind = [string] (Get-DocsLedgerBatchMember -Table $entry.Argument -Name 'Operation') -ceq 'bind-page-refs' -and [string]::IsNullOrEmpty([string] (Get-DocsLedgerBatchMember -Table $entry.Argument -Name 'Element'))
        if (-not $isBind) { $expanded.Add($entry); continue }
        $reference = Get-DocsLedgerBatchMember -Table $documents -Name 'PageReference'
        foreach ($id in @($(if ($reference -is [System.Collections.IDictionary]) { $reference.Keys }) | Sort-Object -CaseSensitive)) {
            if (-not $documents.View.Element.Contains([string] $id)) { continue }
            $expanded.Add(@{ Index = $entry.Index; Argument = [ordered]@{ Operation = 'bind-page-refs'; Element = [string] $id; ActorKind = $entry.Argument['ActorKind']; ActorId = $entry.Argument['ActorId'] }; Claim = $null })
        }
    }
    # Partitions in order of first appearance; input order kept within each partition.
    $partitions = [ordered]@{}
    foreach ($entry in $expanded) {
        $key = Get-DocsLedgerBatchPartitionKey -Argument $entry.Argument
        if (-not $partitions.Contains($key)) { $partitions[$key] = [System.Collections.Generic.List[object]]::new() }
        $partitions[$key].Add($entry)
    }
    foreach ($key in @($partitions.Keys)) {
        $reduced = @{}
        foreach ($name in @($documents.Keys)) { $reduced[$name] = $documents[$name] }
        $inputKeys = @{}
        $touched = @{}
        foreach ($name in @($collection.Keys)) {
            $index = $collection[$name].Index
            $keys = if ($index.Owner.ContainsKey($key)) { [string[]] @($index.Owner[$key] | Where-Object { $index.Record.ContainsKey($_) }) } else { [string[]] @() }
            $inputKeys[$name] = $keys
            $records = [object[]] @($keys | ForEach-Object { $index.Record[$_] })
            $touched[$name] = $false
            $reduced[$name] = Copy-DocsLedgerBatchDocument -Document $documents[$name] -Collection $collection[$name].Member -Value $records
        }
        foreach ($entry in $partitions[$key]) {
            $steps = [System.Collections.Generic.List[object]]::new()
            if (-not [string]::IsNullOrEmpty([string] $entry.Claim)) {
                $steps.Add([ordered]@{ Operation = 'pin'; Element = $entry.Argument['Element']; Page = $entry.Argument['Page']; Claim = [string] $entry.Claim; ActorKind = $entry.Argument['ActorKind']; ActorId = $entry.Argument['ActorId'] })
            }
            $steps.Add($entry.Argument)
            foreach ($step in $steps) {
                $applied = & $ApplyOperation -Argument $step -Documents $reduced -IssuedAt $IssuedAt
                if ($null -ne $applied.Finding) { return @{ Documents = $documents; After = $null; Outcome = $null; Finding = @((Copy-DocsLedgerBatchFinding -Finding $applied.Finding -Index ([int] $entry.Index))) } }
                # A merge helper returns a new document whenever it runs, and the sequential path then
                # re-sorts that whole collection, so a new reference marks the collection as touched.
                foreach ($name in @($collection.Keys)) {
                    if (-not [object]::ReferenceEquals($applied[$name], $reduced[$name])) { $touched[$name] = $true }
                    $reduced[$name] = $applied[$name]
                }
            }
        }
        foreach ($name in @($collection.Keys)) {
            if (-not $touched[$name]) { continue }
            $records = [object[]] @(Get-DocsLedgerBatchMember -Table $reduced[$name] -Name $collection[$name].Member)
            $collection[$name].Changed = $true
            $index = $collection[$name].Index
            foreach ($removed in $inputKeys[$name]) { [void] $index.Record.Remove($removed) }
            foreach ($record in $records) { $index.Record[(Get-DocsLedgerBatchRecordKey -Collection $name -Record $record)] = $record }
        }
    }

    $after = @{}
    foreach ($name in @($collection.Keys)) {
        $after[$name] = if ($collection[$name].Changed) { Copy-DocsLedgerBatchDocument -Document $documents[$name] -Collection $collection[$name].Member -Value ([object[]] @($collection[$name].Index.Record.Values)) } else { $documents[$name] }
    }
    $outcome = & $CompareRule $documents $after
    $newErrors = @(Get-DocsLedgerBatchMember -Table $outcome -Name 'NewErrors' | Where-Object { $null -ne $_ })
    if ($newErrors.Count -eq 0) { return @{ Documents = $documents; After = $after; Outcome = $outcome; Finding = @() } }
    $lastIndex = @{}
    foreach ($key in @($partitions.Keys)) { $lastIndex[$key] = [int] $partitions[$key][$partitions[$key].Count - 1].Index }
    $fallback = [int] @($Item)[-1].Index
    $findings = @(foreach ($finding in $newErrors) {
            $index = $fallback
            foreach ($id in @(Get-DocsLedgerBatchMember -Table $finding -Name 'related_ids')) {
                foreach ($candidate in @("element:$id", "limit:$id")) { if ($lastIndex.ContainsKey($candidate)) { $index = $lastIndex[$candidate] } }
            }
            Copy-DocsLedgerBatchFinding -Finding $finding -Index $index
        })
    return @{ Documents = $documents; After = $null; Outcome = $outcome; Finding = $findings }
}

Export-ModuleMember -Function Test-DocsLedgerBatchArgument, ConvertFrom-DocsLedgerOperationText, Read-DocsLedgerOperationText, Invoke-DocsLedgerBatch
