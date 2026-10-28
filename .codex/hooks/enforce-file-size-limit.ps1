<#
.SYNOPSIS
    Pre-tool-use hook that blocks a Write, Edit, or apply_patch leaving a covered file above 800 lines.

.DESCRIPTION
    This script is invoked by the Codex PreToolUse hook under the ^(apply_patch|Edit|Write)$
    matcher. It enforces the hard tier of the tiered file-size policy: 500 lines is
    guidance, 700 lines is advisory, and above 800 lines a split is enforced regardless of
    logical separability. The policy functions are the dot-sourced Codex twin
    file-size-policy.ps1, which is held text-identical to the Claude module.

    The stdin payload is parsed by ConvertFrom-CodexPreToolUsePayload and mapped to
    file-edit records by ConvertTo-CodexFileEditInput. Per record:
      - A path that is not covered, and a Delete, allow with no file read.
      - Write and apply_patch Add use the record content.
      - Edit resolves old_string to new_string in memory against the pre-edit file read
        through the ReadFileContent seam; a missing or unreadable file, or an edit that
        cannot be resolved, denies.
      - apply_patch Update is reconstructed by a second ConvertTo-CodexFileEditInput call
        with -ResolveUpdateContent and -GovernedPath set to the patched path; empty
        reconstructed content denies.
      - A rename evaluates the destination, and the source supplies the pre-edit size.
    A result above 800 lines is denied unless the file already existed and does not grow.

    Allowed payloads produce NO stdout and exit 0. A deny writes the PreToolUse JSON
    envelope to stdout and exits 0. Empty, malformed, or tool_input-less stdin writes the
    reason to stderr and exits 2.

.NOTES
    Compatible with PowerShell 7+.
    This script must not modify any state; it is a read-only validation gate.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

# Shared Codex PreToolUse transport: stdin payload parsing and tool_input-to-file
# mapping for every tool name the ^(apply_patch|Edit|Write)$ matcher admits.
try { . (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1') } catch { Add-HookDependencyFailure -Name 'codex-pretooluse-file-mapping.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'file-size-policy.ps1') } catch { Add-HookDependencyFailure -Name 'file-size-policy.ps1' -ErrorRecord $_ }

function Get-FileSizeLimitBlockDecision {
    <#
    .SYNOPSIS
        Constructs a deny-decision ordered dictionary carrying the supplied reason.
    .PARAMETER Reason
        The deny reason; it starts with FILE_SIZE_LIMIT_BLOCKED:.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function Get-CodexFileSizeRecordValue {
    <#
    .SYNOPSIS
        Returns a named property of a file-edit record, or $null when it is absent.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Record,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if ($null -eq $Record -or $Record.PSObject.Properties.Name -notcontains $Name) {
        return $null
    }
    return $Record.$Name
}

function Get-CodexFileSizeReplaceAllFlag {
    <#
    .SYNOPSIS
        Returns the boolean value of a record's replace_all property.
    .DESCRIPTION
        A boolean is returned as is; a string is true only when its trimmed value is
        'true' (case-insensitive); every other value is false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Record
    )

    $value = Get-CodexFileSizeRecordValue -Record $Record -Name 'replace_all'
    if ($value -is [bool]) {
        return $value
    }
    if ($value -is [string]) {
        return ($value.Trim() -ieq 'true')
    }
    return $false
}

function Get-CodexFileSizeUpdatedContent {
    <#
    .SYNOPSIS
        Reconstructs the post-patch content of an apply_patch Update for one patched path.
    .OUTPUTS
        The reconstructed content, or an empty string when it cannot be reconstructed.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        $Payload,

        [Parameter(Mandatory)]
        [string] $SourcePath
    )

    $resolved = @(
        ConvertTo-CodexFileEditInput -Payload $Payload -ResolveUpdateContent -GovernedPath $SourcePath |
            Where-Object { $_.operation -eq 'Update' -and $_.source_path -eq $SourcePath }
    )
    if ($resolved.Count -eq 0) {
        return ''
    }
    return [string]$resolved[0].content
}

function Invoke-CodexFileSizeLimitDecision {
    <#
    .SYNOPSIS
        Returns the deny decision for one file-edit record, or $null when it is allowed.
    .PARAMETER Record
        One record from ConvertTo-CodexFileEditInput.
    .PARAMETER Payload
        The parsed payload, used to reconstruct an apply_patch Update.
    .PARAMETER RepositoryRoot
        The repository root used to resolve relative paths. Defaults to the current location.
    .PARAMETER ReadFileContent
        Seam that returns the text of a file, $null when the file does not exist, and
        throws when it cannot be read. Tests supply in-memory content.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        $Record,

        [Parameter(Mandatory)]
        $Payload,

        [string] $RepositoryRoot = (Get-Location).ProviderPath,

        [scriptblock] $ReadFileContent = {
            param([string] $Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllText($Path)
        }
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'FILE_SIZE_LIMIT_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $operation = [string](Get-CodexFileSizeRecordValue -Record $Record -Name 'operation')
    $sourcePath = [string](Get-CodexFileSizeRecordValue -Record $Record -Name 'source_path')
    $relativePath = ConvertTo-FileSizeRelativePath -Path ([string]$Record.file_path) -RepositoryRoot $RepositoryRoot
    if ($operation -eq 'Delete' -or -not (Test-FileSizeCoveredPath -RelativePath $relativePath)) {
        return $null
    }

    # The pre-edit size comes from the source path, which differs from the target only for a rename.
    $sourceRelative = ConvertTo-FileSizeRelativePath -Path $sourcePath -RepositoryRoot $RepositoryRoot
    $isRooted = ($sourcePath -match '^[\\/]') -or ($sourcePath -match '^[A-Za-z]:[\\/]')
    $readPath = if ($isRooted -or $null -eq $sourceRelative) { $sourcePath } else { Join-Path $RepositoryRoot $sourceRelative }
    $hardLimit = (Get-FileSizePolicyLimit).HardLimit

    $resultCount = 0
    if ($operation -eq 'Update') {
        $updated = Get-CodexFileSizeUpdatedContent -Payload $Payload -SourcePath $sourcePath
        if ([string]::IsNullOrEmpty($updated)) {
            return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: the apply_patch Update to '$relativePath' could not be reconstructed to measure its size. The gate fails closed for a covered file."
        }
        $resultCount = Get-FileSizeLogicalLineCount -Content $updated
    } elseif ($operation -ne 'Edit') {
        $resultCount = Get-FileSizeLogicalLineCount -Content ([string](Get-CodexFileSizeRecordValue -Record $Record -Name 'content'))
    }
    if ($operation -ne 'Edit' -and $resultCount -le $hardLimit) {
        return $null
    }

    try {
        $preEditContent = & $ReadFileContent $readPath
    } catch {
        return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: '$relativePath' could not be read to measure its size ($($_.Exception.Message)). The gate fails closed for a covered file."
    }
    $preEditCount = $null
    if ($null -ne $preEditContent) {
        $preEditCount = Get-FileSizeLogicalLineCount -Content ([string]$preEditContent)
    }

    if ($operation -eq 'Edit') {
        if ($null -eq $preEditContent) {
            return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: '$relativePath' does not exist, so the Edit cannot be measured. The gate fails closed for a covered file."
        }
        $edit = Resolve-FileSizeEditContent -Content ([string]$preEditContent) `
            -OldString ([string](Get-CodexFileSizeRecordValue -Record $Record -Name 'old_string')) `
            -NewString ([string](Get-CodexFileSizeRecordValue -Record $Record -Name 'new_string')) `
            -ReplaceAll (Get-CodexFileSizeReplaceAllFlag -Record $Record)
        if ($null -ne $edit.Failure) {
            return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: the Edit to '$relativePath' could not be resolved in memory ($($edit.Failure)). The gate fails closed for a covered file."
        }
        $resultCount = Get-FileSizeLogicalLineCount -Content $edit.Content
    }

    $decision = Get-FileSizeHookDecision -RelativePath $relativePath -ResultLineCount $resultCount -PreEditLineCount $preEditCount
    if ($decision.Allowed) {
        return $null
    }
    return Get-FileSizeLimitBlockDecision -Reason $decision.Reason
}

function Invoke-CodexFileSizeLimitEntryPoint {
    <#
    .SYNOPSIS
        Reads one Codex PreToolUse payload and returns the process exit code.
    .PARAMETER PayloadRaw
        The raw stdin text. AllowEmptyString is required so empty input reaches the shared
        parser and fails closed with exit 2.
    .PARAMETER RepositoryRoot
        The repository root passed to the per-record decision.
    .PARAMETER ReadFileContent
        Optional file-reader seam passed to the per-record decision.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $PayloadRaw,

        [string] $RepositoryRoot = (Get-Location).ProviderPath,

        [scriptblock] $ReadFileContent
    )

    try {
        $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw $PayloadRaw -HookName 'enforce-file-size-limit'
        foreach ($record in @(ConvertTo-CodexFileEditInput -Payload $payload)) {
            $decisionArgs = @{ Record = $record; Payload = $payload; RepositoryRoot = $RepositoryRoot }
            if ($PSBoundParameters.ContainsKey('ReadFileContent')) { $decisionArgs['ReadFileContent'] = $ReadFileContent }
            $decision = Invoke-CodexFileSizeLimitDecision @decisionArgs
            if ($null -ne $decision) {
                [Console]::Out.WriteLine(($decision | ConvertTo-Json -Compress -Depth 5))
                return 0
            }
        }
        return 0
    } catch {
        [Console]::Error.WriteLine([string]$_)
        return 2
    }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('FILE_SIZE_LIMIT_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'FILE_SIZE_LIMIT_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

exit (Invoke-CodexFileSizeLimitEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
