<#
.SYNOPSIS
    PowerShell port of the issue #1162 cross-epic started-while-held check (Layer 2).

.DESCRIPTION
    Ports validate_cross_epic_started_while_held (scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py):
    a feature that the wave-barrier start guard treats as started (a string
    worktree_created_at, or a merge_status other than the literal not_started, an absent
    merge_status included) must not carry a cross_epic_depends_on entry whose status is not
    integrated or in_main. Each such entry yields
    'EPIC_CROSS_DEPENDENCY_VIOLATION: <feature_folder> is treated as started while cross-epic dependency <epic>#<issue_num> is not integrated'.
    Entries without a plain-segment epic or a positive integer issue_num token are left to
    the Python and TypeScript shape checks. A checkpoint without the key yields nothing.

    The checkpoint is parsed with System.Text.Json (JsonDocument), not ConvertFrom-Json, so
    ISO-8601 strings stay strings and property names compare ordinally; a duplicate
    property resolves to its last definition, as Python json does. The strings are pinned
    by tests/fixtures/epic_cross_dependency/cross-dependency-cases.json.

.NOTES
    PowerShell 7+. Reads no file and starts no process. Imported by
    OrchestratorStateEpicWaveBarrier.psm1, which appends its result. Mirrored
    byte-identically into the bundled extension payload.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:CrossKey = 'cross_epic_depends_on'
$script:IntegratedStatuses = @('integrated', 'in_main')
$script:ViolationFormat = 'EPIC_CROSS_DEPENDENCY_VIOLATION: {0} is treated as started while cross-epic dependency {1}#{2} is not integrated'
$script:UnevaluableToken = 'EPIC_CROSS_DEPENDENCY_UNEVALUABLE:'

# Private: the last property of an object element whose name equals Name (ordinal), or
# Found = $false when there is none.
function Get-EpicCrossJsonProperty {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $found = $false
    $value = $null
    foreach ($property in $Element.EnumerateObject()) {
        if ([string]::Equals($property.Name, $Name, [System.StringComparison]::Ordinal)) {
            $found = $true
            $value = $property.Value
        }
    }
    return [pscustomobject]@{ Found = $found; Value = $value }
}

# Private: the string value of a named property, or $null when it is absent or not a string.
function Get-EpicCrossJsonString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $property = Get-EpicCrossJsonProperty -Element $Element -Name $Name
    if ($property.Found -and $property.Value.ValueKind -eq [System.Text.Json.JsonValueKind]::String) {
        return $property.Value.GetString()
    }
    return $null
}

# Private: the start guard of feature_has_started.
function Test-EpicCrossFeatureStarted {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Feature)

    if ($null -ne (Get-EpicCrossJsonString -Element $Feature -Name 'worktree_created_at')) { return $true }
    $status = Get-EpicCrossJsonProperty -Element $Feature -Name 'merge_status'
    if (-not $status.Found) { return $true }
    $notStarted = ($status.Value.ValueKind -eq [System.Text.Json.JsonValueKind]::String) -and
    [string]::Equals($status.Value.GetString(), 'not_started', [System.StringComparison]::Ordinal)
    return (-not $notStarted)
}

# Private: the violation line of one entry, or nothing when it is integrated or not well formed.
function Get-EpicCrossEntryViolation {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Entry,
        [Parameter(Mandatory = $true)] [string] $Folder
    )

    if ($Entry.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return }
    $epic = Get-EpicCrossJsonString -Element $Entry -Name 'epic'
    if ($null -eq $epic -or $epic -cnotmatch '^[A-Za-z0-9._-]+$' -or $epic -ceq '.' -or $epic -ceq '..') { return }
    $issue = Get-EpicCrossJsonProperty -Element $Entry -Name 'issue_num'
    # Python reads only a plain positive integer token as a positive int.
    if (-not $issue.Found -or $issue.Value.ValueKind -ne [System.Text.Json.JsonValueKind]::Number) { return }
    $issueText = $issue.Value.GetRawText()
    if ($issueText -cnotmatch '^[1-9][0-9]*$') { return }
    $status = Get-EpicCrossJsonString -Element $Entry -Name 'status'
    if ($null -ne $status -and $script:IntegratedStatuses -ccontains $status) { return }
    $script:ViolationFormat -f $Folder, $epic, $issueText
}

function Get-OrchestratorStateEpicCrossDependencyError {
    <#
    .SYNOPSIS
        Return the EPIC_CROSS_DEPENDENCY_VIOLATION lines for an epic checkpoint's text.
    .DESCRIPTION
        Returns an empty array when the root is not an object, when features is absent or
        not a list, or when no started feature carries an unintegrated cross-epic entry.
        Throws an error whose message starts with EPIC_CROSS_DEPENDENCY_UNEVALUABLE: for
        text System.Text.Json does not parse.
    .PARAMETER CheckpointText
        The raw epic checkpoint JSON text.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CheckpointText)

    $document = $null
    try {
        $document = [System.Text.Json.JsonDocument]::Parse($CheckpointText, [System.Text.Json.JsonDocumentOptions]::new())
    }
    catch {
        throw ('{0} the checkpoint is not parseable by System.Text.Json with default options: {1}' -f $script:UnevaluableToken, $_.Exception.Message)
    }
    try {
        $lines = [System.Collections.Generic.List[string]]::new()
        $root = $document.RootElement
        if ($root.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return , [string[]] @() }
        $features = Get-EpicCrossJsonProperty -Element $root -Name 'features'
        if (-not $features.Found -or $features.Value.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) { return , [string[]] @() }
        # Check every started object feature with a string folder and a list value.
        foreach ($feature in $features.Value.EnumerateArray()) {
            if ($feature.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { continue }
            $folder = Get-EpicCrossJsonString -Element $feature -Name 'feature_folder'
            $entries = Get-EpicCrossJsonProperty -Element $feature -Name $script:CrossKey
            if ($null -eq $folder -or -not $entries.Found -or $entries.Value.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) { continue }
            if (-not (Test-EpicCrossFeatureStarted -Feature $feature)) { continue }
            foreach ($entry in $entries.Value.EnumerateArray()) {
                $line = Get-EpicCrossEntryViolation -Entry $entry -Folder $folder
                if ($line) { $lines.Add([string] $line) }
            }
        }
        return , [string[]] $lines.ToArray()
    }
    finally {
        $document.Dispose()
    }
}

Export-ModuleMember -Function Get-OrchestratorStateEpicCrossDependencyError
