# Surface-neutral construction and validation for immutable Codex child launches.

function ConvertFrom-CodexChildLaunchJsonCore {
    param([Parameter(Mandatory)][string] $Raw, [Parameter(Mandatory)][string] $Name)
    if ([string]::IsNullOrWhiteSpace($Raw)) {
        throw "CODEX_CHILD_LAUNCH_BLOCKED: $Name is empty."
    }
    try {
        return $Raw | ConvertFrom-Json -Depth 32 -ErrorAction Stop
    } catch {
        throw "CODEX_CHILD_LAUNCH_BLOCKED: $Name is malformed JSON: $_"
    }
}

function Get-CodexChildSha256 {
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $Value)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
    return [Convert]::ToHexString(
        [System.Security.Cryptography.SHA256]::HashData($bytes)
    ).ToLowerInvariant()
}

function Get-CodexChildCanonicalPath {
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)][string] $BasePath)
    $candidate = if ([System.IO.Path]::IsPathFullyQualified($Path)) {
        $Path
    } else {
        Join-Path $BasePath $Path
    }
    return [System.IO.Path]::GetFullPath($candidate).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Get-CodexChildEffectiveMaximum {
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][ValidateRange(1, 8)][int] $RequestedMaximum,
        [Parameter(Mandatory)][ValidateRange(1, 8)][int] $SpecMaximum
    )
    return [Math]::Min($RequestedMaximum, $SpecMaximum)
}

function Get-CodexChildProfileKey {
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $WorktreePath,
        [Parameter(Mandatory)][string] $AgentName,
        [Parameter(Mandatory)][string] $RepositoryRoot
    )
    $worktree = Get-CodexChildCanonicalPath -Path $WorktreePath -BasePath $RepositoryRoot
    return "$worktree`n$AgentName"
}

function Test-CodexChildIssueEqual {
    [OutputType([bool])]
    param([AllowNull()] $Left, [AllowNull()] $Right)
    return ($Left | ConvertTo-Json -Compress) -ceq ($Right | ConvertTo-Json -Compress)
}

function Test-CodexChildPositiveInteger {
    [OutputType([bool])]
    param([AllowNull()] $Value)
    $isInteger = $Value -is [byte] -or $Value -is [sbyte] -or
    $Value -is [int16] -or $Value -is [uint16] -or
    $Value -is [int32] -or $Value -is [uint32] -or
    $Value -is [int64] -or $Value -is [uint64]
    return $isInteger -and [decimal]$Value -gt 0
}

function Test-CodexChildActiveFeatureFolder {
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $Path)
    $normalized = $Path.Replace('\', '/')
    if ([System.IO.Path]::IsPathFullyQualified($Path) -or
        $normalized -notmatch '^docs/features/active/[^/<>]+$') {
        return $false
    }
    $leaf = ($normalized -split '/')[-1]
    if ($leaf -in @('.', '..') -or $leaf.Trim() -cne $leaf) {
        return $false
    }
    return $leaf -notmatch '(?i)(?:^|[-_.])(?:placeholder|pending|tbd|todo|unknown|none|null|temp|temporary|draft)(?:$|[-_.])'
}

function Test-CodexChildSha256 {
    [OutputType([bool])]
    param([AllowEmptyString()][string] $Value)
    return $Value -cmatch '^[a-f0-9]{64}$'
}

function Test-CodexChildRepositoryPath {
    [OutputType([bool])]
    param(
        [AllowEmptyString()][string] $Path,
        [Parameter(Mandatory)][string] $RepositoryRoot
    )
    if ([string]::IsNullOrWhiteSpace($Path) -or
        [System.IO.Path]::IsPathFullyQualified($Path) -or $Path.Contains('\')) {
        return $false
    }
    $segments = @($Path.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries))
    if ($segments.Count -eq 0 -or @($segments | Where-Object { $_ -in @('.', '..') }).Count -gt 0) {
        return $false
    }
    $root = Get-CodexChildCanonicalPath -Path $RepositoryRoot -BasePath $RepositoryRoot
    $candidate = Get-CodexChildCanonicalPath -Path $Path -BasePath $root
    $comparison = if ($IsWindows) {
        [System.StringComparison]::OrdinalIgnoreCase
    } else {
        [System.StringComparison]::Ordinal
    }
    return $candidate.StartsWith(
        $root + [System.IO.Path]::DirectorySeparatorChar,
        $comparison
    )
}

function ConvertTo-CodexChildLaunchIdentity {
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][ValidateSet('epic', 'parallel')][string] $Surface,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][string] $BaseBranch,
        [Parameter(Mandatory)] $Entry,
        [System.Collections.IDictionary] $Bindings = @{}
    )
    $identity = [ordered]@{
        schema_version         = 1
        surface                = $Surface
        repository_root        = $RepositoryRoot
        base_branch            = $BaseBranch
        head_branch            = [string]$Entry.branch_name
        worktree_path          = [string]$Entry.worktree_path
        deployment_agent       = [string]$Entry.deployment_agent
        model                  = [string]$Entry.model
        model_reasoning_effort = [string]$Entry.model_reasoning_effort
        permissions            = [string]$Entry.permissions
    }
    foreach ($name in @($Bindings.Keys)) {
        if ($identity.Contains($name)) {
            throw "CODEX_CHILD_LAUNCH_BLOCKED: duplicate immutable launch identity field: $name"
        }
        $identity[$name] = $Bindings[$name]
    }
    return $identity
}

function Test-CodexChildLaunchIdentity {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] $Identity,
        [Parameter(Mandatory)] $AgentProfile,
        [Parameter(Mandatory)][ValidateSet('epic', 'parallel')][string] $ExpectedSurface,
        [Parameter(Mandatory)][string] $ExpectedRepositoryRoot,
        [Parameter(Mandatory)][string] $ExpectedBaseBranch,
        [Parameter(Mandatory)][string] $LiveBranch,
        [string[]] $RequiredBindingFields = @()
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    if ([int]$Identity.schema_version -ne 1 -or
        [string]$Identity.surface -cne $ExpectedSurface) {
        $errors.Add("launch identity must use schema_version 1 and surface $ExpectedSurface.")
    }
    $repository = Get-CodexChildCanonicalPath -Path ([string]$Identity.repository_root) `
        -BasePath $ExpectedRepositoryRoot
    $expectedRepository = Get-CodexChildCanonicalPath -Path $ExpectedRepositoryRoot `
        -BasePath $ExpectedRepositoryRoot
    if ([string]$Identity.repository_root -cne $repository -or $repository -ne $expectedRepository) {
        $errors.Add('launch identity repository_root is not the exact canonical repository.')
    }
    if ([string]$Identity.base_branch -cne $ExpectedBaseBranch -or
        [string]::IsNullOrWhiteSpace([string]$Identity.head_branch) -or
        [string]$Identity.head_branch -cne $LiveBranch) {
        $errors.Add('launch identity base_branch or head_branch does not match live authority.')
    }
    $worktree = Get-CodexChildCanonicalPath -Path ([string]$Identity.worktree_path) `
        -BasePath $expectedRepository
    $profileWorktree = Get-CodexChildCanonicalPath -Path ([string]$AgentProfile.worktree_path) `
        -BasePath $expectedRepository
    if (-not [System.IO.Path]::IsPathFullyQualified([string]$Identity.worktree_path) -or
        [string]$Identity.worktree_path -cne $worktree -or $worktree -ne $profileWorktree) {
        $errors.Add('launch identity worktree_path is not the exact checked-in profile worktree.')
    }
    if ([string]$Identity.deployment_agent -cne [string]$AgentProfile.name -or
        [string]$Identity.model -cne [string]$AgentProfile.model -or
        [string]$Identity.model_reasoning_effort -cne [string]$AgentProfile.model_reasoning_effort -or
        [string]$Identity.permissions -cne [string]$AgentProfile.default_permissions) {
        $errors.Add('launch identity differs from its exact agent, model, reasoning, or permission profile.')
    }
    $receiptPaths = @(
        'authority_receipt_path', 'delegation_receipt_path', 'topology_receipt_path',
        'model_routing_receipt_path', 'child_status_path'
    )
    foreach ($name in $RequiredBindingFields) {
        $names = @($Identity.PSObject.Properties.Name)
        if ($Identity -is [System.Collections.IDictionary]) {
            $names = @($Identity.Keys)
        }
        if ($name -notin $names -or [string]::IsNullOrWhiteSpace([string]$Identity[$name])) {
            $errors.Add("launch identity is missing required binding: $name.")
            continue
        }
        $value = [string]$Identity[$name]
        if ($name -in $receiptPaths -and
            -not (Test-CodexChildRepositoryPath -Path $value -RepositoryRoot $expectedRepository)) {
            $errors.Add("launch identity $name must be a guarded repository-relative path.")
        }
        if ($name -in @('launch_spec_sha256', 'checkpoint_sha256', 'profile_sha256') -and
            -not (Test-CodexChildSha256 -Value $value)) {
            $errors.Add("launch identity $name must be a lowercase SHA-256 value.")
        }
        if ($name -eq 'codex_home_path') {
            $codexHome = Get-CodexChildCanonicalPath -Path $value -BasePath $expectedRepository
            $comparison = if ($IsWindows) {
                [System.StringComparison]::OrdinalIgnoreCase
            } else {
                [System.StringComparison]::Ordinal
            }
            if (-not [System.IO.Path]::IsPathFullyQualified($value) -or
                $codexHome -eq $worktree -or $codexHome.StartsWith(
                    $worktree + [System.IO.Path]::DirectorySeparatorChar,
                    $comparison
                )) {
                $errors.Add('launch identity codex_home_path must be isolated from the child worktree.')
            }
        }
    }
    return $errors.ToArray()
}

function ConvertTo-CodexChildReceiptTimestamp {
    [OutputType([datetimeoffset])]
    param([Parameter(Mandatory)][AllowNull()] $Value)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        throw 'receipt timestamp is missing.'
    }
    try {
        return [datetimeoffset]$Value
    } catch {
        throw "receipt timestamp is invalid: $_"
    }
}

function Get-CodexChildActiveReceiptErrorList {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] $Receipt,
        [AllowEmptyString()][string] $ExpectedSessionId = '',
        [datetimeoffset] $Now = [datetimeoffset]::UtcNow
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    if ([int]$Receipt.schema_version -ne 2 -or [string]$Receipt.state -cne 'active') {
        $errors.Add('launch receipt must use schema_version 2 and state active.')
    }
    $sessionId = [string]$Receipt.codex_session_id
    if ([string]::IsNullOrWhiteSpace($sessionId) -or
        (-not [string]::IsNullOrWhiteSpace($ExpectedSessionId) -and $sessionId -cne $ExpectedSessionId)) {
        $errors.Add('launch receipt session id is missing or does not match the active Codex session.')
    }
    $timestampsValid = $true
    try {
        $boundAt = ConvertTo-CodexChildReceiptTimestamp -Value $Receipt.session_bound_at
        $expiresAt = ConvertTo-CodexChildReceiptTimestamp -Value $Receipt.expires_at
    } catch {
        $timestampsValid = $false
    }
    if (-not $timestampsValid -or $boundAt -gt $Now -or $expiresAt -le $Now -or $expiresAt -le $boundAt) {
        $errors.Add('launch receipt session timestamps are invalid or expired.')
    }
    foreach ($name in @(
            'launch_id', 'delegation_id', 'feature_folder', 'deployment_agent', 'model',
            'model_reasoning_effort', 'execution_context', 'worktree_path', 'branch_name',
            'receipt_path', 'status_path', 'spec_path', 'profile_path', 'codex_home_path',
            'trusted_repository_root', 'checkpoint_kind', 'wave_lock_path'
        )) {
        if ([string]::IsNullOrWhiteSpace([string]$Receipt.$name)) {
            $errors.Add("launch receipt is missing $name.")
        }
    }
    return $errors.ToArray()
}

function Get-CodexChildTerminalReceiptErrorList {
    [OutputType([string[]])]
    param([Parameter(Mandatory)] $Receipt)
    $errors = [System.Collections.Generic.List[string]]::new()
    if ([int]$Receipt.schema_version -ne 2 -or [string]$Receipt.state -cnotin @('completed', 'failed')) {
        $errors.Add('terminal launch receipt must use schema_version 2 and state completed or failed.')
    }
    if ([string]::IsNullOrWhiteSpace([string]$Receipt.codex_session_id)) {
        $errors.Add('terminal launch receipt must preserve the bound Codex session id.')
    }
    $timestampsValid = $true
    try {
        $boundAt = ConvertTo-CodexChildReceiptTimestamp -Value $Receipt.session_bound_at
        $terminalAt = if ([string]$Receipt.state -eq 'completed') {
            ConvertTo-CodexChildReceiptTimestamp -Value $Receipt.completed_at
        } else {
            ConvertTo-CodexChildReceiptTimestamp -Value $Receipt.failed_at
        }
    } catch {
        $timestampsValid = $false
    }
    if ([string]$Receipt.state -ceq 'completed') {
        if ([int]$Receipt.exit_code -ne 0 -or
            [string]::IsNullOrWhiteSpace([string]$Receipt.completed_at)) {
            $errors.Add('completed launch receipt requires exit_code 0 and completed_at.')
        }
    } elseif ([string]$Receipt.state -ceq 'failed' -and
        [string]::IsNullOrWhiteSpace([string]$Receipt.failed_at)) {
        $errors.Add('failed launch receipt requires failed_at.')
    }
    if (-not $timestampsValid -or $terminalAt -lt $boundAt) {
        $errors.Add('terminal launch receipt timestamps are invalid or out of order.')
    }
    return $errors.ToArray()
}

function ConvertFrom-CodexAgentProfileCore {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $ProfileRaw)
    $values = [ordered]@{}
    foreach ($key in @('name', 'model', 'model_reasoning_effort', 'default_permissions')) {
        $pattern = '(?m)^{0}\s*=\s*"([^"]+)"\s*$' -f [regex]::Escape($key)
        $match = [regex]::Match($ProfileRaw, $pattern)
        if (-not $match.Success) {
            throw "CODEX_CHILD_LAUNCH_BLOCKED: generated profile is missing $key."
        }
        $values[$key] = $match.Groups[1].Value
    }
    $instructions = [regex]::Match(
        $ProfileRaw,
        "(?ms)^developer_instructions\s*=\s*'''(.*?)'''\s*$"
    )
    $skillsSection = [regex]::Match($ProfileRaw, '(?ms)^\[skills\]\s*(.*)$')
    $skills = if ($skillsSection.Success) {
        [regex]::Match($skillsSection.Groups[1].Value, '(?ms)^config\s*=\s*(\[.*\])\s*$')
    } else {
        $null
    }
    if (-not $instructions.Success -or $null -eq $skills -or -not $skills.Success) {
        throw 'CODEX_CHILD_LAUNCH_BLOCKED: generated profile must define developer_instructions and skills.config.'
    }
    $values.developer_instructions = $instructions.Groups[1].Value
    $values.skills_config = $skills.Groups[1].Value
    return [pscustomobject]$values
}
