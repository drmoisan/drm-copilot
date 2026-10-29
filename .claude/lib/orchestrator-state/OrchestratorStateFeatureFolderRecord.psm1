<#
.SYNOPSIS
    Feature-folder adoption record validation (issue #992).

.DESCRIPTION
    Destination-runtime PowerShell port of `feature_folder_record_errors` in
    `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`. The optional
    `issue_adoption.feature_folder_record` object declares that an adopted feature
    folder already existed and was committed before the finishing run started. A
    valid record lets the adoption waive the `new_active_feature_folder` receipt.

    Invariants:
      - Rule 10: waiving `new_active_feature_folder` requires an object record.
      - Rules 11a to 11e run whenever the record is an object, waived or not;
        rule 11b runs only when `path` passed rule 11a.
      - Every string comparison is ordinal and case-sensitive; the path pattern is
        applied with -cmatch and the \A...\z anchors.
      - The record is a declaration. The Claude SubagentStop hook performs the git
        probe separately.

    Every function is pure: it reads no file, starts no process, and never mutates
    its input.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import the shared checkpoint-value primitives, resolved relative to this
# module's directory so the import travels with the pushed-down pack.
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'OrchestratorStateCheckpointValue.psm1') -Force -ErrorAction Stop

$script:FEATURE_FOLDER_TOOL = 'new_active_feature_folder'
$script:FEATURE_FOLDER_RECORD_KEY = 'feature_folder_record'
$script:FEATURE_FOLDER_PATH_PATTERN = '\Adocs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*\z'
$script:FEATURE_FOLDER_VERIFIED_VIA = [string[]]@('git_cat_file_head', 'git_ls_tree_head')

$script:ERROR_RECORD_NOT_OBJECT = 'Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.'
$script:ERROR_PATH_FORMAT = 'Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.'
$script:ERROR_PATH_EQUAL = 'Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.'
$script:ERROR_VERIFIED_VIA = 'Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.'
$script:ERROR_VERIFIED_AT = 'Checkpoint issue_adoption.feature_folder_record.verified_at must be present.'
$script:ERROR_EVIDENCE = 'Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.'


function Test-OrchestratorStateFeatureFolderPath {
    <#
    .SYNOPSIS
        Report whether a value is a valid adopted feature-folder path.
    .DESCRIPTION
        True only for a string that fully matches the shared path pattern: a folder
        under docs/features/active/ whose every segment starts with a letter or
        digit, so dot segments, empty segments, a trailing slash, backslashes,
        drive letters, glob characters, and a leading hyphen are rejected.
    .PARAMETER Value
        The deserialized JSON value to inspect. May be $null.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [object] $Value
    )

    return (($Value -is [string]) -and ([string]$Value -cmatch $script:FEATURE_FOLDER_PATH_PATTERN))
}

function Get-FeatureFolderRecordFieldError {
    <#
    .SYNOPSIS
        Validate the fields of an object-shaped record (rules 11a to 11e).
    .PARAMETER Record
        The feature_folder_record object.
    .PARAMETER State
        The parsed checkpoint, read for its feature-folder member.
    .OUTPUTS
        System.String[] - zero or more error strings in rule order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Record,

        [Parameter(Mandatory = $true)]
        [psobject] $State
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $path = (Get-CheckpointObjectMember -Owner $Record -Name 'path').Value
    # Rule 11b compares a well-formed path only; a malformed path is reported once by rule 11a.
    if (-not (Test-OrchestratorStateFeatureFolderPath -Value $path)) {
        $errors.Add($script:ERROR_PATH_FORMAT)
    }
    else {
        $checkpointFolder = (Get-CheckpointObjectMember -Owner $State -Name 'feature-folder').Value
        if (-not (($checkpointFolder -is [string]) -and [string]::Equals([string]$checkpointFolder, [string]$path, [System.StringComparison]::Ordinal))) {
            $errors.Add($script:ERROR_PATH_EQUAL)
        }
    }

    $verifiedVia = (Get-CheckpointObjectMember -Owner $Record -Name 'verified_via').Value
    if (-not (($verifiedVia -is [string]) -and ($script:FEATURE_FOLDER_VERIFIED_VIA -ccontains [string]$verifiedVia))) {
        $errors.Add($script:ERROR_VERIFIED_VIA)
    }

    # Presence-only, matching the adoption-level verified_at rule; a System.DateTime
    # produced by ConvertFrom-Json passes.
    $verifiedAt = (Get-CheckpointObjectMember -Owner $Record -Name 'verified_at').Value
    if (($null -ceq $verifiedAt) -or (($verifiedAt -is [string]) -and [string]::IsNullOrWhiteSpace([string]$verifiedAt))) {
        $errors.Add($script:ERROR_VERIFIED_AT)
    }

    $evidence = (Get-CheckpointObjectMember -Owner $Record -Name 'evidence').Value
    if (-not (($evidence -is [string]) -and -not [string]::IsNullOrWhiteSpace([string]$evidence))) {
        $errors.Add($script:ERROR_EVIDENCE)
    }
    return $errors.ToArray()
}

function Get-OrchestratorStateFeatureFolderRecordError {
    <#
    .SYNOPSIS
        Validate issue_adoption.feature_folder_record (rules 10 and 11a-11e).
    .DESCRIPTION
        An object record is always validated (rules 11a to 11e). A missing or
        non-object record yields the rule-10 error only when waived_tools contains
        new_active_feature_folder; otherwise nothing is reported.
    .PARAMETER Adoption
        The issue_adoption object.
    .PARAMETER State
        The parsed checkpoint, read for its feature-folder member.
    .PARAMETER WaivedTool
        The well-formed waived_tools list, in checkpoint order.
    .OUTPUTS
        System.String[] - zero or more error strings in rule order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Adoption,

        [Parameter(Mandatory = $true)]
        [psobject] $State,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]] $WaivedTool
    )

    $record = (Get-CheckpointObjectMember -Owner $Adoption -Name $script:FEATURE_FOLDER_RECORD_KEY).Value
    if (Test-CheckpointObjectValue -Value $record) {
        return [string[]]@(Get-FeatureFolderRecordFieldError -Record $record -State $State)
    }
    if ($WaivedTool -ccontains $script:FEATURE_FOLDER_TOOL) {
        return [string[]]@($script:ERROR_RECORD_NOT_OBJECT)
    }
    return [string[]]@()
}

Export-ModuleMember -Function Test-OrchestratorStateFeatureFolderPath, Get-OrchestratorStateFeatureFolderRecordError
