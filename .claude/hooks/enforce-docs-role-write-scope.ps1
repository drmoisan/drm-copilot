<#
.SYNOPSIS
    PreToolUse hook that restricts writes and shell calls made by the four documentation roles (issue #1037).

.DESCRIPTION
    Registered on the matcher Write|Edit|MultiEdit|NotebookEdit|Bash. The hook acts only when the
    payload agent_type is docs-architect, docs-author, docs-reconciler or docs-coverage-reviewer
    (Get-DocsRoleName). A payload without agent_type (the main thread) or with any other agent type is
    allowed with no output.

    Deny rules (deny JSON at exit 0; every reason starts with DOCS_ROLE_WRITE_SCOPE_BLOCKED: and names
    its rule):
      1. a Write-class call (Write, Edit, MultiEdit, NotebookEdit) by docs-architect, docs-reconciler
         or docs-coverage-reviewer;
      2. a Bash call by any documentation role;
      3. a docs-author write whose target lies outside the repository root, or names no target;
      4. a docs-author write whose target does not end in .md;
      5. a docs-author write whose target equals the profile path or a profile artifact_paths value;
      6. a docs-author write whose target lies under .claude/, .github/, .codex/ or .agents/.
    Rules are evaluated in the order 3, 6, 5, 4 for docs-author, so a profile or artifact path is
    reported as rule 5. An absent, unreadable or unparseable profile, or a non-string artifact_paths
    value, disables rule 5 for that value only; the other rules stay in force.

.NOTES
    The payload is read through the shared reader (.claude/lib/hook-payload/HookPayload.psm1). The
    repository root comes from the seam Get-DocsWriteScopeRepositoryRoot (payload cwd) and the profile
    text from the seam Get-DocsWriteScopeProfileText (docs/documentation-estate/docs-profile.json),
    parsed with ConvertFrom-Json -AsHashtable; the hook imports nothing from .claude/lib/docs/.
    Byte-identical bundled mirror at
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-role-write-scope.ps1.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'docs-role-contract.ps1') } catch { Add-HookDependencyFailure -Name 'docs-role-contract.ps1' -ErrorRecord $_ }

$script:DocsWriteScopeWriteTools = @('Write', 'Edit', 'MultiEdit', 'NotebookEdit')
$script:DocsWriteScopeProtectedPrefixes = @('.claude/', '.github/', '.codex/', '.agents/')
$script:DocsWriteScopeProfilePath = 'docs/documentation-estate/docs-profile.json'
$script:DocsWriteScopeArtifactKeys = @('inventory_snapshot', 'coverage_ledger', 'parity_matrix', 'evidence_pins', 'validation_receipt')

function Get-DocsWriteScopeRepositoryRoot {
    <#
    .SYNOPSIS
        Root seam: returns the payload cwd, or the current location when the payload carries none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $HookInput)

    $cwd = [string](Get-ClaudeHookEnvelopeValue -Envelope $HookInput -Name 'cwd')
    if ([string]::IsNullOrWhiteSpace($cwd)) { return (Get-Location).ProviderPath }
    return $cwd
}

function Get-DocsWriteScopeProfileText {
    <#
    .SYNOPSIS
        Profile seam: returns the text of the default docs profile, or $null when no file exists.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $RepositoryRoot)

    $path = Join-Path -Path $RepositoryRoot -ChildPath $script:DocsWriteScopeProfilePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    return Get-Content -LiteralPath $path -Raw -ErrorAction Stop
}

function Get-DocsWriteScopeDenyDecision {
    # Builds the PreToolUse deny decision for one rule.
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] [int] $Rule, [Parameter(Mandatory)] [string] $Detail)

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "DOCS_ROLE_WRITE_SCOPE_BLOCKED: rule $Rule - $Detail"
        }
    }
}

function ConvertTo-DocsWriteScopeRelativePath {
    <#
    .SYNOPSIS
        Normalizes a write target to a repository-relative forward-slash path, or returns $null when it lies outside the root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $Target, [Parameter(Mandatory)] [string] $RepositoryRoot)

    $comparison = if ($IsWindows) { [System.StringComparison]::OrdinalIgnoreCase } else { [System.StringComparison]::Ordinal }
    $root = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([char[]]@('\', '/'))
    $candidate = if ([System.IO.Path]::IsPathRooted($Target)) { $Target } else { [System.IO.Path]::Combine($root, $Target) }
    $full = [System.IO.Path]::GetFullPath($candidate)
    $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($prefix, $comparison)) { return $null }
    return $full.Substring($prefix.Length).Replace('\', '/')
}

function Get-DocsWriteScopeProtectedArtifactPath {
    <#
    .SYNOPSIS
        Returns the profile path and every string artifact_paths value, or an empty set when the profile is unusable.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([AllowNull()] [AllowEmptyString()] [string] $ProfileText)

    if ([string]::IsNullOrWhiteSpace($ProfileText)) { return [string[]]@() }
    try { $docsProfile = ConvertFrom-Json -InputObject $ProfileText -AsHashtable -ErrorAction Stop }
    catch { return [string[]]@() }
    if ($docsProfile -isnot [System.Collections.IDictionary]) { return [string[]]@() }

    $paths = [System.Collections.Generic.List[string]]::new()
    $paths.Add($script:DocsWriteScopeProfilePath)
    $artifactPaths = $docsProfile['artifact_paths']
    if ($artifactPaths -is [System.Collections.IDictionary]) {
        foreach ($key in $script:DocsWriteScopeArtifactKeys) {
            $value = $artifactPaths[$key]
            if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace($value)) { $paths.Add(($value.Replace('\', '/') -replace '^\./', '')) }
        }
    }
    return [string[]]$paths.ToArray()
}

function Get-DocsAuthorWriteDecision {
    # Applies rules 3, 6, 5 and 4 to one docs-author write target; returns a deny decision or $null.
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowEmptyString()] [string] $Target, [Parameter(Mandatory)] [string] $RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($Target)) { return Get-DocsWriteScopeDenyDecision -Rule 3 -Detail 'docs-author write names no target path; the hook cannot place it inside the repository.' }
    $relative = ConvertTo-DocsWriteScopeRelativePath -Target $Target -RepositoryRoot $RepositoryRoot
    if ($null -eq $relative) { return Get-DocsWriteScopeDenyDecision -Rule 3 -Detail "docs-author may not write '$Target' because it lies outside the repository root." }
    foreach ($prefix in $script:DocsWriteScopeProtectedPrefixes) {
        if ($relative.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { return Get-DocsWriteScopeDenyDecision -Rule 6 -Detail "docs-author may not write '$relative' under $prefix; customization directories are outside the documentation write scope." }
    }

    try { $profileText = Get-DocsWriteScopeProfileText -RepositoryRoot $RepositoryRoot } catch { $profileText = $null }
    foreach ($protected in (Get-DocsWriteScopeProtectedArtifactPath -ProfileText $profileText)) {
        if ($relative.Equals($protected, [System.StringComparison]::OrdinalIgnoreCase)) { return Get-DocsWriteScopeDenyDecision -Rule 5 -Detail "docs-author may not write '$relative' because it is the docs profile or a profile artifact; change ledger, matrix, pin and receipt artifacts through update_docs_ledger or a root step." }
    }
    if (-not $relative.EndsWith('.md', [System.StringComparison]::Ordinal)) { return Get-DocsWriteScopeDenyDecision -Rule 4 -Detail "docs-author may write only .md pages; '$relative' is not a .md file." }
    return $null
}

function Invoke-DocsRoleWriteScopeDecision {
    <#
    .SYNOPSIS
        Parses the PreToolUse envelope and returns a deny decision for a documentation role, or $null to allow with no output.
    .PARAMETER HookInputRaw
        The raw PreToolUse envelope JSON acquired by Read-ClaudeHookRawPayload.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary or $null.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $HookInputRaw
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_ROLE_WRITE_SCOPE_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $parsed = ConvertFrom-ClaudeHookEnvelope -Raw $HookInputRaw
    $hookInput = if ($parsed.IsValid) { $parsed.Value } else { $null }
    $role = [string](Get-ClaudeHookEnvelopeValue -Envelope $hookInput -Name 'agent_type')
    if ([string]::IsNullOrWhiteSpace($role) -or (Get-DocsRoleName) -cnotcontains $role) { return $null }

    $toolName = [string](Get-ClaudeHookEnvelopeValue -Envelope $hookInput -Name 'tool_name')
    if ($toolName -ceq 'Bash') { return Get-DocsWriteScopeDenyDecision -Rule 2 -Detail "$role may not run Bash; documentation roles use the docs MCP tools, and root steps run from the main session." }
    if ($script:DocsWriteScopeWriteTools -cnotcontains $toolName) { return $null }
    if ($role -cne 'docs-author') { return Get-DocsWriteScopeDenyDecision -Rule 1 -Detail "$role is read-only and may not call $toolName; only docs-author writes pages." }

    $toolInput = (Get-ClaudeHookToolInput -Envelope $hookInput).Value
    $target = Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'file_path'
    if ([string]::IsNullOrWhiteSpace($target)) { $target = Get-ClaudeHookToolInputString -ToolInput $toolInput -Name 'notebook_path' }
    return Get-DocsAuthorWriteDecision -Target $target -RepositoryRoot (Get-DocsWriteScopeRepositoryRoot -HookInput $hookInput)
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DOCS_ROLE_WRITE_SCOPE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_ROLE_WRITE_SCOPE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$decision = Invoke-DocsRoleWriteScopeDecision -HookInputRaw (Read-ClaudeHookRawPayload)
if ($null -ne $decision) { $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output }
exit 0
