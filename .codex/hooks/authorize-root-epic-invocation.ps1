<#
.SYNOPSIS
    Records a bounded root-session authorization receipt for Codex epic personas.

.DESCRIPTION
    UserPromptSubmit hook. Reads the documented Codex JSON payload from stdin. Exact epic skill
    commands and direct requests to invoke an epic persona produce one turn-bound receipt in the
    non-workspace Codex authority store. Non-epic prompts are ignored. The receipt is consumed by
    the SubagentStart attestation hook.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'codex-authority-store.ps1')
# Development-docs root module (issue #1035): the published .codex/lib copy first, the self-hosted .claude/lib copy otherwise.
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -PathType Leaf) {
    Import-Module (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
}
else {
    Import-Module (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) '.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
}

$script:ReceiptLifetimeMinutes = 60

function ConvertFrom-RootEpicHookPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'EPIC_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is empty.'
    }
    try {
        return $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "EPIC_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is malformed JSON: $_"
    }
}

function Get-RootEpicRequestedPersona {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Prompt)

    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-plan(?:\s+|$)' -or
        $Prompt -match '(?im)^\s*(?:please\s+)?(?:invoke|spawn|use|run|delegate(?:\s+this)?\s+to)\s+(?:the\s+)?(?:Codex\s+)?epic-planner\b') {
        return 'epic-planner'
    }
    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-(?:run|orchestrate)(?:\s+|$)' -or
        $Prompt -match '(?im)^\s*(?:please\s+)?(?:invoke|spawn|use|run|delegate(?:\s+this)?\s+to)\s+(?:the\s+)?(?:Codex\s+)?epic-orchestrator\b') {
        return 'epic-orchestrator'
    }
    return ''
}

function Get-RootEpicReference {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Prompt)

    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-(?:plan|run|orchestrate)\s+(?<reference>[^\r\n]+)') {
        return $Matches.reference.Trim()
    }
    # An epic reference under the epics area of either known development-docs root (issue #1035).
    if ($Prompt -match ('(?i)(?<reference>' + (Get-DevelopmentDocsKnownRootPattern -Area 'epics') + '[\\/][^\s"'']+)')) {
        return ($Matches.reference -replace '\\', '/').TrimEnd('.', ',', ';')
    }
    return ''
}

function Get-RootEpicEntryKind {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Prompt)

    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-plan(?:\s+|$)') {
        return 'epic-plan'
    }
    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-run(?:\s+|$)') {
        return 'epic-run'
    }
    if ($Prompt -match '(?im)^\s*(?:/|\$)?epic-orchestrate(?:\s+|$)') {
        return 'epic-orchestrate'
    }
    return 'direct'
}

function Get-RootEpicSlug {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Reference)

    $parts = @(($Reference -replace '\\', '/').Trim('/').Split('/') | Where-Object { $_ })
    if ($parts.Count -eq 0) {
        return ''
    }
    if ($parts[-1] -in @('epic.md', 'epic-kickoff.md') -and $parts.Count -ge 2) {
        return [string]$parts[-2]
    }
    return [string]$parts[-1]
}

function Get-LowerSha256 {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    return [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Get-RootEpicReceiptFileName {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $TurnId)

    $safeTurnId = $TurnId -replace '[^A-Za-z0-9._-]', '_'
    return "epic-root-invocation.$safeTurnId.json"
}

function Get-RootEpicInvocationReceipt {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)][datetimeoffset] $Now,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][string] $HeadSha
    )

    $prompt = [string]$Payload.prompt
    $persona = Get-RootEpicRequestedPersona -Prompt $prompt
    if (-not $persona) {
        return $null
    }

    $turnId = [string]$Payload.turn_id
    $sessionId = [string]$Payload.session_id
    if ([string]::IsNullOrWhiteSpace($turnId) -or [string]::IsNullOrWhiteSpace($sessionId)) {
        throw 'EPIC_INVOCATION_ORIGIN_BLOCKED: an epic root invocation requires session_id and turn_id.'
    }

    $reference = Get-RootEpicReference -Prompt $prompt
    $entryKind = Get-RootEpicEntryKind -Prompt $prompt
    $kickoffPath = ''
    if ($persona -eq 'epic-orchestrator' -and $entryKind -eq 'epic-run') {
        $slug = Get-RootEpicSlug -Reference $reference
        if ($slug) {
            # The kickoff lives in the epics area of the root configured in RepositoryRoot (issue #1035).
            $docsRoot = Resolve-DevelopmentDocsRoot -WorkspaceRoot $RepositoryRoot
            if (-not $docsRoot.Succeeded) {
                throw "EPIC_INVOCATION_ORIGIN_BLOCKED: $($docsRoot.Reason)"
            }
            $kickoffPath = (Get-DevelopmentDocsPath -Root $docsRoot.Root -Area 'epics') + "/$slug/epic-kickoff.md"
        }
    }

    return [ordered]@{
        schema_version      = 1
        repository_root     = Get-CodexCanonicalAuthorityPath -Path $RepositoryRoot
        repository_sha256   = Get-CodexAuthorityRepositoryKey -RepositoryRoot $RepositoryRoot
        repository_head_sha = $HeadSha
        session_id          = $sessionId
        turn_id             = $turnId
        prompt_sha256       = Get-LowerSha256 -Text $prompt
        requested_persona   = $persona
        entry_kind          = $entryKind
        epic_reference      = $reference
        kickoff_path        = $kickoffPath
        created_at          = $Now.ToUniversalTime().ToString('o')
        expires_at          = $Now.AddMinutes($script:ReceiptLifetimeMinutes).ToUniversalTime().ToString('o')
        consumed            = $false
        consumed_by         = $null
        consumed_at         = $null
    }
}

function Write-RootEpicInvocationReceipt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Receipt,
        # Testability seams (issue #1035): the defaults create the authority directory and open
        # the receipt with CreateNew, exactly as before.
        [scriptblock] $EnsureDirectory = {
            param([string] $DirectoryPath)
            [System.IO.Directory]::CreateDirectory($DirectoryPath) | Out-Null
        },
        [scriptblock] $OpenFile = {
            param([string] $FilePath)
            [System.IO.File]::Open($FilePath, [System.IO.FileMode]::CreateNew,
                [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        }
    )

    $directory = Get-CodexAuthorityStateRoot `
        -RepositoryRoot $RepositoryRoot `
        -SessionId ([string]$Receipt.session_id)
    & $EnsureDirectory $directory
    $path = Get-CodexAuthorityReceiptPath `
        -RepositoryRoot $RepositoryRoot `
        -SessionId ([string]$Receipt.session_id) `
        -TurnId ([string]$Receipt.turn_id)
    $json = $Receipt | ConvertTo-Json -Depth 8
    $stream = & $OpenFile $path
    try {
        $writer = [System.IO.StreamWriter]::new(
            $stream,
            [System.Text.UTF8Encoding]::new($false)
        )
        try {
            $writer.Write($json)
            $writer.Flush()
        } finally {
            $writer.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
    return $path
}

function Invoke-RootEpicGitExe {
    # Wrapper seam for the git executable: returns the standard output and the native exit code.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string[]] $GitArgs)

    return [pscustomobject]@{ Output = @(& git @GitArgs 2>$null); ExitCode = $LASTEXITCODE }
}

function Invoke-RootEpicInvocationHook {
    # The hook decision (issue #1035): exit 0 with no output for a non-epic prompt, exit 0 with the
    # UserPromptSubmit JSON for a written receipt, and exit 2 with the error text for any failure.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [datetimeoffset] $Now = [datetimeoffset]::UtcNow
    )

    try {
        $payload = ConvertFrom-RootEpicHookPayload -PayloadRaw $PayloadRaw
        if (-not (Get-RootEpicRequestedPersona -Prompt ([string]$payload.prompt))) {
            return [pscustomobject]@{ ExitCode = 0; Output = $null; ErrorText = $null }
        }
        $head = Invoke-RootEpicGitExe -GitArgs @('-C', $RepositoryRoot, 'rev-parse', 'HEAD')
        $headSha = [string]$head.Output
        if ($head.ExitCode -ne 0 -or $headSha -notmatch '^[0-9a-fA-F]{40,64}$') {
            throw 'EPIC_INVOCATION_ORIGIN_BLOCKED: repository HEAD could not be resolved.'
        }
        $receipt = Get-RootEpicInvocationReceipt -Payload $payload -Now $Now -RepositoryRoot $RepositoryRoot -HeadSha $headSha
        if ($null -eq $receipt) {
            return [pscustomobject]@{ ExitCode = 0; Output = $null; ErrorText = $null }
        }
        $receiptPath = Write-RootEpicInvocationReceipt -RepositoryRoot $RepositoryRoot -Receipt $receipt
        $json = [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName     = 'UserPromptSubmit'
                additionalContext = "Root epic invocation authorized for $($receipt.requested_persona); receipt: $receiptPath"
            }
        } | ConvertTo-Json -Compress -Depth 5
        return [pscustomobject]@{ ExitCode = 0; Output = $json; ErrorText = $null }
    } catch {
        return [pscustomobject]@{ ExitCode = 2; Output = $null; ErrorText = [string]$_ }
    }
}

function Write-RootEpicInvocationHookResult {
    # Writes the hook output to stdout and the error text to stderr, and returns the exit code.
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)] $Result,
        [scriptblock] $WriteStdout = { param([string] $Text) [Console]::Out.WriteLine($Text) },
        [scriptblock] $WriteStderr = { param([string] $Text) [Console]::Error.WriteLine($Text) }
    )

    if ($Result.Output) { & $WriteStdout ([string]$Result.Output) }
    if ($Result.ErrorText) { & $WriteStderr ([string]$Result.ErrorText) }
    return [int]$Result.ExitCode
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

exit (Write-RootEpicInvocationHookResult -Result (Invoke-RootEpicInvocationHook -PayloadRaw ([Console]::In.ReadToEnd()) -RepositoryRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)))
