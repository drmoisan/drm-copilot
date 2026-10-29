<#
.SYNOPSIS
    Pre-tool-use hook that blocks a Write or Edit leaving a covered file above 800 lines.

.DESCRIPTION
    This script is invoked by the Claude Code PreToolUse hook before any Write or Edit
    operation. It enforces the hard tier of the tiered file-size policy: 500 lines is
    guidance, 700 lines is advisory, and above 800 lines a split is enforced regardless
    of logical separability. The policy functions live in the shared module
    ../lib/file-size-policy/FileSizePolicy.psm1.

    Decision order:
      1. A dependency-load failure denies (fail closed).
      2. An unreadable envelope denies.
      3. A path that is not covered (outside the extension allowlist, under an excluded
         directory, or outside the repository root) allows with no file read.
      4. Write: the resulting size is the logical line count of content. The pre-write
         file is read only when that size is above 800.
         Edit: the pre-edit file is read through the ReadFileContent seam and the
         old_string to new_string replacement is applied in memory. An unreadable or
         missing file, or an edit that cannot be resolved, denies.
      5. The baseline-free pre-edit-size ratchet decides: a result above 800 lines is
         denied unless the file already existed and does not grow.

    The hook does not read config/file-size-baseline.json, because it ships to
    repositories that have no baseline; the repository's CI gate is the
    baseline-aware check. The deny shape is hookSpecificOutput.permissionDecision =
    'deny' with permissionDecisionReason, exit 0.

.NOTES
    Compatible with PowerShell 7+.
    This script must not modify any state; it is a read-only validation gate.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/file-size-policy/FileSizePolicy.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'FileSizePolicy.psm1' -ErrorRecord $_ }

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

function Get-FileSizeLimitAllowDecision {
    <#
    .SYNOPSIS
        Constructs the allow-decision ordered dictionary.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
}

function Get-FileSizeLimitReplaceAllFlag {
    <#
    .SYNOPSIS
        Returns the boolean value of the replace_all property of an Edit tool input.
    .DESCRIPTION
        A boolean is returned as is; a string is true only when its trimmed value is
        'true' (case-insensitive); every other value, and an absent property, is false.
        No [bool] cast is used because [bool]'false' is $true in PowerShell.
    .PARAMETER ToolInput
        The tool_input object.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object] $ToolInput
    )

    $value = Get-ClaudeHookEnvelopeValue -Envelope $ToolInput -Name 'replace_all'
    if ($value -is [bool]) {
        return $value
    }
    if ($value -is [string]) {
        return ($value.Trim() -ieq 'true')
    }
    return $false
}

function Invoke-FileSizeLimitDecision {
    <#
    .SYNOPSIS
        Parses the PreToolUse envelope and returns an allow-or-deny decision.
    .PARAMETER ToolInputRaw
        The raw JSON hook payload acquired by Read-ClaudeHookRawPayload.
    .PARAMETER RepositoryRoot
        The repository root used to resolve relative paths. Defaults to the current
        location, which is the project root when Claude Code runs the hook.
    .PARAMETER ReadFileContent
        Seam that returns the text of a file, $null when the file does not exist, and
        throws when it cannot be read. Tests supply in-memory content.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [string] $RepositoryRoot = (Get-Location).ProviderPath,

        [scriptblock] $ReadFileContent = {
            param([string] $Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllText($Path)
        }
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'FILE_SIZE_LIMIT_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $payload = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $payload.IsValid) {
        return Get-FileSizeLimitBlockDecision -Reason ('FILE_SIZE_LIMIT_BLOCKED: payload anomaly - ' +
            (Get-ClaudeHookPayloadAnomalyReason -Anomaly $payload.Anomaly) +
            '. The gate fails closed on an envelope it cannot read.')
    }

    $toolInput = $payload.Value
    $filePath = Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'file_path'
    $relativePath = ConvertTo-FileSizeRelativePath -Path $filePath -RepositoryRoot $RepositoryRoot
    if (-not (Test-FileSizeCoveredPath -RelativePath $relativePath)) {
        return Get-FileSizeLimitAllowDecision
    }

    $isRooted = ($filePath -match '^[\\/]') -or ($filePath -match '^[A-Za-z]:[\\/]')
    $readPath = if ($isRooted) { $filePath } else { Join-Path $RepositoryRoot $relativePath }
    $toolName = Get-ClaudeHookToolInputString -ToolInput $payload.Envelope -Name 'tool_name'
    $isEdit = ($toolName -eq 'Edit')

    $resultCount = 0
    if (-not $isEdit) {
        $resultCount = Get-FileSizeLogicalLineCount -Content (Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'content')
        if ($resultCount -le (Get-FileSizePolicyLimit).HardLimit) {
            return Get-FileSizeLimitAllowDecision
        }
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

    if ($isEdit) {
        if ($null -eq $preEditContent) {
            return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: '$relativePath' does not exist, so the Edit cannot be measured. The gate fails closed for a covered file."
        }
        $edit = Resolve-FileSizeEditContent -Content ([string]$preEditContent) `
            -OldString (Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'old_string') `
            -NewString (Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'new_string') `
            -ReplaceAll (Get-FileSizeLimitReplaceAllFlag -ToolInput $toolInput)
        if ($null -ne $edit.Failure) {
            return Get-FileSizeLimitBlockDecision -Reason "FILE_SIZE_LIMIT_BLOCKED: the Edit to '$relativePath' could not be resolved in memory ($($edit.Failure)). The gate fails closed for a covered file."
        }
        $resultCount = Get-FileSizeLogicalLineCount -Content $edit.Content
    }

    $decision = Get-FileSizeHookDecision -RelativePath $relativePath -ResultLineCount $resultCount -PreEditLineCount $preEditCount
    if ($decision.Allowed) {
        return Get-FileSizeLimitAllowDecision
    }
    return Get-FileSizeLimitBlockDecision -Reason $decision.Reason
}

function Invoke-FileSizeLimitEntryPoint {
    <#
    .SYNOPSIS
        Runs the file-size decision and returns the process exit code.
    .DESCRIPTION
        Acquires the payload through the shared reader unless the caller supplies one,
        writes the compact JSON decision to the output stream, and returns 0. It never
        returns 1: exit 1 is non-blocking for PreToolUse, so every anomaly is already a
        deny decision by the time control reaches here.
    .PARAMETER ToolInputRaw
        Optional pre-acquired payload text. When omitted the ReadPayload seam runs.
    .PARAMETER ReadPayload
        Seam for payload acquisition.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload }
    )

    if (-not $PSBoundParameters.ContainsKey('ToolInputRaw')) {
        $ToolInputRaw = [string](& $ReadPayload)
    }

    $decision = Invoke-FileSizeLimitDecision -ToolInputRaw $ToolInputRaw

    $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('FILE_SIZE_LIMIT_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'FILE_SIZE_LIMIT_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

# The entry point returns its [int] exit code as the last pipeline element and the
# decision JSON before it, so the decision is written explicitly here first.
$entryPointResult = @(Invoke-FileSizeLimitEntryPoint)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
