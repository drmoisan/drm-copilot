<#
.SYNOPSIS
    Mints one bounded root authority receipt for an explicit parallel entry skill.

.DESCRIPTION
    UserPromptSubmit hook. Only explicit parallel-plan, parallel-run, or
    parallel-orchestrate invocations from a root session mint authority.
    Mutation operations never mint a second authority; their receipts must bind
    to the parallel_identity recorded here. Ordinary prompts are ignored, while
    a child or epic persona attempting an explicit parallel entry is rejected.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'codex-authority-store.ps1')

$script:ParallelReceiptLifetimeMinutes = 60
$script:ParallelEntryKinds = @(
    'parallel-plan',
    'parallel-run',
    'parallel-orchestrate'
)

function ConvertFrom-RootParallelHookPayload {
    <#
    .SYNOPSIS
        Parses one native UserPromptSubmit payload.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $PayloadRaw
    )

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is empty.'
    }
    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is malformed JSON.'
    }
    if ($null -eq $payload -or $payload -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input must be one JSON object.'
    }
    return $payload
}

function Get-RootParallelEntryKind {
    <#
    .SYNOPSIS
        Resolves an explicit parallel entry skill, or an empty string.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Prompt
    )

    if ($Prompt -match '(?im)^\s*(?:/|\$)?parallel-plan(?:\s+|$)') {
        return 'parallel-plan'
    }
    if ($Prompt -match '(?im)^\s*(?:/|\$)?parallel-run(?:\s+|$)') {
        return 'parallel-run'
    }
    if ($Prompt -match '(?im)^\s*(?:/|\$)?parallel-orchestrate(?:\s+|$)') {
        return 'parallel-orchestrate'
    }
    return ''
}

function Get-RootParallelRequestedPersona {
    <#
    .SYNOPSIS
        Maps one explicit entry skill to its sole forced persona.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $EntryKind
    )

    if ($EntryKind -eq 'parallel-plan') {
        return 'parallel-planner'
    }
    if ($EntryKind -in @('parallel-run', 'parallel-orchestrate')) {
        return 'parallel-orchestrator'
    }
    return ''
}

function Get-RootParallelReference {
    <#
    .SYNOPSIS
        Returns the explicit entry skill argument without changing its bytes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Prompt,

        [Parameter(Mandatory)]
        [ValidateSet('parallel-plan', 'parallel-run', 'parallel-orchestrate')]
        [string] $EntryKind
    )

    $escaped = [regex]::Escape($EntryKind)
    if ($Prompt -match "(?im)^\s*(?:/|\$)?$escaped\s+(?<reference>[^\r\n]+)") {
        return $Matches.reference.Trim()
    }
    return ''
}

function Get-RootParallelSlug {
    <#
    .SYNOPSIS
        Derives a stable slug from a run or manifest reference.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Reference
    )

    $parts = @(
        ($Reference -replace '\\', '/').Trim('/').Split('/') |
            Where-Object { $_ }
    )
    if ($parts.Count -eq 0) {
        return ''
    }
    if ($parts[-1] -in @('parallel.md', 'parallel-kickoff.md') -and $parts.Count -ge 2) {
        return [string]$parts[-2]
    }
    return ([string]$parts[-1]).TrimEnd('.', ',', ';')
}

function Test-RootParallelSessionOrigin {
    <#
    .SYNOPSIS
        Rejects an explicit parallel entry submitted from any child persona.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] $Payload)

    foreach ($field in @('agent_id', 'agent_type', 'parent_agent_id')) {
        if ($Payload.PSObject.Properties.Name -contains $field -and
            -not [string]::IsNullOrWhiteSpace([string]$Payload.$field)) {
            return $false
        }
    }
    return $true
}

function Get-RootParallelInvocationReceipt {
    <#
    .SYNOPSIS
        Constructs one immutable, turn-bound parallel authority receipt.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)][datetimeoffset] $Now,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][string] $HeadSha
    )

    $prompt = [string]$Payload.prompt
    $entryKind = Get-RootParallelEntryKind -Prompt $prompt
    if (-not $entryKind) {
        return $null
    }
    if (-not (Test-RootParallelSessionOrigin -Payload $Payload)) {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: parallel entry skills may be invoked only by the root session.'
    }

    $turnId = [string]$Payload.turn_id
    $sessionId = [string]$Payload.session_id
    if ([string]::IsNullOrWhiteSpace($turnId) -or
        [string]::IsNullOrWhiteSpace($sessionId)) {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: a root parallel invocation requires session_id and turn_id.'
    }

    $reference = Get-RootParallelReference -Prompt $prompt -EntryKind $entryKind
    if ([string]::IsNullOrWhiteSpace($reference)) {
        throw "PARALLEL_INVOCATION_ORIGIN_BLOCKED: $entryKind requires an explicit reference."
    }
    $persona = Get-RootParallelRequestedPersona -EntryKind $entryKind
    $slug = Get-RootParallelSlug -Reference $reference
    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: the parallel identity could not be resolved.'
    }
    $kickoffPath = if ($entryKind -eq 'parallel-run') {
        "docs/features/parallel/$slug/parallel-kickoff.md"
    } else {
        ''
    }
    $parallelIdentity = Get-CodexAuthoritySha256 -Text (
        "parallel`n$slug`n$reference"
    )

    return [ordered]@{
        schema_version      = 1
        surface             = 'parallel'
        repository_root     = Get-CodexCanonicalAuthorityPath -Path $RepositoryRoot
        repository_sha256   = Get-CodexAuthorityRepositoryKey -RepositoryRoot $RepositoryRoot
        repository_head_sha = $HeadSha
        session_id          = $sessionId
        turn_id             = $turnId
        prompt_sha256       = Get-CodexAuthoritySha256 -Text $prompt
        requested_persona   = $persona
        entry_kind          = $entryKind
        parallel_reference  = $reference
        parallel_slug       = $slug
        parallel_identity   = $parallelIdentity
        mutation_identity   = $parallelIdentity
        kickoff_path        = $kickoffPath
        created_at          = $Now.ToUniversalTime().ToString('o')
        expires_at          = $Now.AddMinutes($script:ParallelReceiptLifetimeMinutes).ToUniversalTime().ToString('o')
        consumed            = $false
        consumed_by         = $null
        consumed_at         = $null
    }
}

function Write-RootParallelInvocationReceipt {
    <#
    .SYNOPSIS
        Creates one sealed receipt in the external parallel authority store.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Receipt
    )

    $directory = Get-CodexAuthorityStateRoot `
        -RepositoryRoot $RepositoryRoot `
        -SessionId ([string]$Receipt.session_id) `
        -Surface parallel
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    $path = Get-CodexAuthorityReceiptPath `
        -RepositoryRoot $RepositoryRoot `
        -SessionId ([string]$Receipt.session_id) `
        -TurnId ([string]$Receipt.turn_id) `
        -Surface parallel
    $stream = [System.IO.File]::Open(
        $path,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try {
        $writer = [System.IO.StreamWriter]::new(
            $stream,
            [System.Text.UTF8Encoding]::new($false)
        )
        try {
            $writer.Write(($Receipt | ConvertTo-Json -Depth 8))
            $writer.Flush()
        } finally {
            $writer.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
    return $path
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $payload = ConvertFrom-RootParallelHookPayload -PayloadRaw ([Console]::In.ReadToEnd())
    $entryKind = Get-RootParallelEntryKind -Prompt ([string]$payload.prompt
    )
    if (-not $entryKind) {
        exit 0
    }
    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $headSha = [string](& git -C $repositoryRoot rev-parse HEAD 2>$null)
    if ($LASTEXITCODE -ne 0 -or $headSha -notmatch '^[0-9a-fA-F]{40,64}$') {
        throw 'PARALLEL_INVOCATION_ORIGIN_BLOCKED: repository HEAD could not be resolved.'
    }
    $receipt = Get-RootParallelInvocationReceipt `
        -Payload $payload `
        -Now ([datetimeoffset]::UtcNow) `
        -RepositoryRoot $repositoryRoot `
        -HeadSha $headSha
    $receiptPath = Write-RootParallelInvocationReceipt `
        -RepositoryRoot $repositoryRoot `
        -Receipt $receipt
    [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName     = 'UserPromptSubmit'
            additionalContext = (
                "Root parallel invocation authorized for $($receipt.requested_persona); " +
                "parallel identity: $($receipt.parallel_identity); receipt: $receiptPath"
            )
        }
    } | ConvertTo-Json -Compress -Depth 5 | Write-Output
    exit 0
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
