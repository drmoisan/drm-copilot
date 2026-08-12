<#
.SYNOPSIS
    Shared native transport adapter for validation-only parallel hooks.

.DESCRIPTION
    Parses a Codex hook JSON object from stdin, validates the native event,
    tool, and tool_input fields, invokes an injected shared parallel validator,
    and normalizes the result to the repository's exact allow, deny, or
    transport-error contract. The module performs no state mutation and has no
    entrypoint side effects when dot-sourced.

.NOTES
    Compatible with PowerShell 7+.
#>
[CmdletBinding()]
param()

function ConvertFrom-CodexParallelHookPayload {
    <#
    .SYNOPSIS
        Parses and validates one native Codex hook payload.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $PayloadRaw,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $HookName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $ExpectedHookEventName = 'PreToolUse'
    )

    if (-not $PSBoundParameters.ContainsKey('PayloadRaw')) {
        $PayloadRaw = [Console]::In.ReadToEnd()
    }
    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw "$HookName hook input is empty."
    }

    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "$HookName hook input is malformed JSON."
    }

    if ($null -eq $payload -or $payload -isnot [System.Management.Automation.PSCustomObject]) {
        throw "$HookName hook input must be one JSON object."
    }

    $properties = @($payload.PSObject.Properties.Name)
    if ($properties -notcontains 'hook_event_name' -or
        [string]::IsNullOrWhiteSpace([string]$payload.hook_event_name)) {
        throw "$HookName hook input is missing hook_event_name."
    }
    if ([string]$payload.hook_event_name -ne $ExpectedHookEventName) {
        throw "$HookName hook input has unexpected hook_event_name '$($payload.hook_event_name)'."
    }
    if ($properties -notcontains 'tool_name' -or
        [string]::IsNullOrWhiteSpace([string]$payload.tool_name)) {
        throw "$HookName hook input is missing tool_name."
    }
    if ($properties -notcontains 'tool_input' -or
        $null -eq $payload.tool_input -or
        $payload.tool_input -isnot [System.Management.Automation.PSCustomObject]) {
        throw "$HookName hook input is missing object-valued tool_input."
    }

    return $payload
}

function ConvertTo-CodexParallelHookDenyEnvelope {
    <#
    .SYNOPSIS
        Builds one compact native Codex deny envelope.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $HookEventName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Reason
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = $HookEventName
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function ConvertTo-CodexParallelHookResult {
    <#
    .SYNOPSIS
        Creates one immutable transport result for a consuming entrypoint.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet(0, 2)]
        [int] $ExitCode,

        [Parameter()]
        [AllowEmptyString()]
        [string] $Stdout = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $Stderr = ''
    )

    return [pscustomobject]@{
        ExitCode = $ExitCode
        Stdout   = $Stdout
        Stderr   = $Stderr
    }
}

function Invoke-CodexParallelHookValidation {
    <#
    .SYNOPSIS
        Parses native input and invokes one injected shared validator.

    .DESCRIPTION
        The validator receives tool_input followed by the complete parsed
        payload and returns zero or more stable error strings. Zero errors is a
        silent allow. One or more errors produce one compact native deny
        envelope. Transport or validator exceptions produce exit 2 with one
        hook-named diagnostic and empty stdout.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $HookName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ReasonCode,

        [Parameter(Mandatory)]
        [scriptblock] $Validator,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $PayloadRaw,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $ExpectedHookEventName = 'PreToolUse'
    )

    try {
        $parserArguments = @{
            HookName              = $HookName
            ExpectedHookEventName = $ExpectedHookEventName
        }
        if ($PSBoundParameters.ContainsKey('PayloadRaw')) {
            $parserArguments['PayloadRaw'] = $PayloadRaw
        }
        $payload = ConvertFrom-CodexParallelHookPayload @parserArguments
        $errors = @(& $Validator $payload.tool_input $payload) |
            ForEach-Object { ([string]$_).Trim() } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        if ($errors.Count -eq 0) {
            return ConvertTo-CodexParallelHookResult -ExitCode 0
        }

        $reason = "$ReasonCode`: $($errors -join '; ')"
        $envelope = ConvertTo-CodexParallelHookDenyEnvelope `
            -HookEventName $ExpectedHookEventName `
            -Reason $reason
        return ConvertTo-CodexParallelHookResult -ExitCode 0 `
            -Stdout ($envelope | ConvertTo-Json -Compress -Depth 5)
    } catch {
        $message = ([string]$_).Trim()
        if (-not $message.StartsWith($HookName, [System.StringComparison]::Ordinal)) {
            $message = "$HookName validation failed: $message"
        }
        return ConvertTo-CodexParallelHookResult -ExitCode 2 -Stderr $message
    }
}

function Write-CodexParallelHookResult {
    <#
    .SYNOPSIS
        Writes one normalized result and returns its process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $Result
    )

    if (-not [string]::IsNullOrEmpty([string]$Result.Stdout)) {
        [Console]::Out.WriteLine([string]$Result.Stdout)
    }
    if (-not [string]::IsNullOrEmpty([string]$Result.Stderr)) {
        [Console]::Error.WriteLine([string]$Result.Stderr)
    }
    return [int]$Result.ExitCode
}
