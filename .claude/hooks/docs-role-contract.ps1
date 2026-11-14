<#
.SYNOPSIS
    Shared contract of the four documentation roles and their SubagentStop result tokens (issue #1037).

.DESCRIPTION
    Dot-sourced by validate-docs-role-output.ps1 and enforce-docs-role-write-scope.ps1. It is not
    registered as a hook. It imports nothing, dot-sources nothing, reads no environment variable and
    writes to no output stream at load or at call time; every function returns its result.

    A documentation role reports its result as one token per line in the form `token: value`.
    Get-DocsRoleRequiredToken names the tokens each role must report, ConvertFrom-DocsRoleOutput
    parses them, and Test-DocsRoleOutput applies the value rules. File existence is checked only
    through the injected -TestFile scriptblock, so callers and tests control the file-system boundary.
    docs-profile and docs-pages-written must exist; docs-snapshot is checked for relative form only.

.NOTES
    PowerShell 7+. Byte-identical bundled mirror at
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/docs-role-contract.ps1.
    A new documentation role extends Get-DocsRoleName, Get-DocsRoleRequiredToken, the SubagentStop
    matcher in .claude/settings.json and the docs_operations block of config/orchestration-routing.json
    together.
#>

function Get-DocsRoleName {
    <#
    .SYNOPSIS
        Returns the four documentation role names.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@('docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer')
}

function Get-DocsRoleRequiredToken {
    <#
    .SYNOPSIS
        Returns the result tokens one documentation role must report, common tokens first.
    .PARAMETER Role
        One of the names returned by Get-DocsRoleName (case-sensitive).
    .OUTPUTS
        System.String[]; an unknown role throws System.ArgumentException.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string] $Role
    )

    $common = @('docs-role', 'docs-result', 'docs-findings')
    switch -CaseSensitive ($Role) {
        'docs-architect' { return $common + @('docs-profile', 'docs-snapshot', 'docs-pages-planned') }
        'docs-author' { return $common + @('docs-pages-written', 'docs-check-exit-code') }
        'docs-reconciler' { return $common + @('docs-ledger-operations', 'docs-update-ledger-exit-code', 'docs-elements-reconciled') }
        'docs-coverage-reviewer' { return $common + @('docs-validate-mode', 'docs-revision', 'docs-validate-exit-code', 'docs-receipt-id') }
        default { throw [System.ArgumentException]::new("Unknown documentation role: '$Role'.", 'Role') }
    }
}

function ConvertFrom-DocsRoleOutput {
    <#
    .SYNOPSIS
        Parses `docs-<name>: <value>` lines into an ordinal token map (pure).
    .DESCRIPTION
        A token line starts at column 0 and matches ^(?<token>docs-[a-z-]+):[ ]*(?<value>.*)$. The
        value is trimmed of trailing whitespace. The first occurrence of a token is kept; every later
        occurrence is recorded in Duplicates once per token.
    .PARAMETER Text
        The role's final message.
    .OUTPUTS
        A hashtable with Tokens (an ordinal dictionary of token to value) and Duplicates (a string array).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Text
    )

    $tokens = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
    $duplicates = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrEmpty($Text)) {
        foreach ($line in ($Text -split "`r?`n")) {
            $match = [regex]::Match($line, '^(?<token>docs-[a-z-]+):[ ]*(?<value>.*)$')
            if (-not $match.Success) { continue }
            $token = $match.Groups['token'].Value
            $value = $match.Groups['value'].Value.TrimEnd()
            if ($tokens.ContainsKey($token)) {
                if (-not $duplicates.Contains($token)) { $duplicates.Add($token) }
                continue
            }
            $tokens[$token] = $value
        }
    }

    return @{ Tokens = $tokens; Duplicates = [string[]]$duplicates.ToArray() }
}

function Test-DocsRoleRelativePath {
    <#
    .SYNOPSIS
        Returns $true when a value is a repository-relative forward-slash path (pure).
    .DESCRIPTION
        Rejects an empty value, a backslash, a leading slash, a drive prefix, a URL scheme and any
        empty, '.' or '..' segment.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Value
    )

    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Contains('\') -or $Value.StartsWith('/')) { return $false }
    if ($Value -match '^[A-Za-z]:' -or $Value.Contains('://')) { return $false }
    foreach ($segment in $Value.Split('/')) {
        if ($segment -eq '' -or $segment -eq '.' -or $segment -eq '..') { return $false }
    }
    return $true
}

function Get-DocsRoleIntegerFinding {
    # Returns a finding for a value that is not a non-negative integer (optionally capped), or $null.
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $Token,
        [AllowEmptyString()] [string] $Value,
        [int] $Maximum = -1
    )

    if ($Value -notmatch '^[0-9]{1,9}$') { return "$Token must be a non-negative integer (found '$Value')" }
    if ($Maximum -ge 0 -and [int]$Value -gt $Maximum) { return "$Token must be an exit code from 0 to $Maximum (found '$Value')" }
    return $null
}

function Get-DocsRolePathFinding {
    # Returns the findings for one reported repository path: relative form, optional .md suffix, and existence
    # through the seam unless -SkipExistence is set, in which case only the form rules apply (issue #1173).
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] [string] $Token,
        [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory)] [scriptblock] $TestFile,
        [switch] $RequireMarkdown,
        [switch] $SkipExistence
    )

    if (-not (Test-DocsRoleRelativePath -Value $Path)) { return [string[]]@("$Token path '$Path' must be repository-relative with forward slashes") }
    if ($RequireMarkdown -and -not $Path.EndsWith('.md', [System.StringComparison]::Ordinal)) { return [string[]]@("$Token path '$Path' must end with .md") }
    if ($SkipExistence) { return [string[]]@() }
    if (-not [bool](& $TestFile $Path)) { return [string[]]@("$Token path '$Path' does not exist") }
    return [string[]]@()
}

function Get-DocsRoleSpecificFinding {
    # Applies the role-specific value rules to tokens that are present; missing tokens are reported by the caller.
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] [string] $Role,
        [Parameter(Mandatory)] [System.Collections.Generic.Dictionary[string, string]] $Tokens,
        [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory)] [scriptblock] $TestFile
    )

    $findings = [System.Collections.Generic.List[string]]::new()
    $result = if ($Tokens.ContainsKey('docs-result')) { $Tokens['docs-result'] } else { '' }
    $exitToken = $null
    switch -CaseSensitive ($Role) {
        'docs-architect' {
            # docs-profile must exist; docs-snapshot is checked for relative form only, because the role cannot
            # write it and on a first run it does not exist until the root inventory step persists it (issue #1173).
            if ($Tokens.ContainsKey('docs-profile')) { foreach ($f in (Get-DocsRolePathFinding -Token 'docs-profile' -Path $Tokens['docs-profile'] -TestFile $TestFile)) { $findings.Add($f) } }
            if ($Tokens.ContainsKey('docs-snapshot')) { foreach ($f in (Get-DocsRolePathFinding -Token 'docs-snapshot' -Path $Tokens['docs-snapshot'] -TestFile $TestFile -SkipExistence)) { $findings.Add($f) } }
            if ($Tokens.ContainsKey('docs-pages-planned')) { $f = Get-DocsRoleIntegerFinding -Token 'docs-pages-planned' -Value $Tokens['docs-pages-planned']; if ($f) { $findings.Add($f) } }
            if ($result -ceq 'PASS' -and -not [regex]::IsMatch([string]$Text, '(?m)^## Information Architecture[ \t]*\r?$')) {
                $findings.Add('docs-result PASS requires a ## Information Architecture section in the report')
            }
        }
        'docs-author' {
            if ($Tokens.ContainsKey('docs-pages-written')) {
                $value = $Tokens['docs-pages-written']
                if ($value -ceq 'none') {
                    if ($result -ceq 'PASS') { $findings.Add('docs-pages-written may be none only when docs-result is FAIL or BLOCKED') }
                }
                else {
                    foreach ($page in $value.Split(',')) {
                        foreach ($f in (Get-DocsRolePathFinding -Token 'docs-pages-written' -Path $page.Trim() -TestFile $TestFile -RequireMarkdown)) { $findings.Add($f) }
                    }
                }
            }
            $exitToken = 'docs-check-exit-code'
        }
        'docs-reconciler' {
            if ($Tokens.ContainsKey('docs-ledger-operations')) { $f = Get-DocsRoleIntegerFinding -Token 'docs-ledger-operations' -Value $Tokens['docs-ledger-operations']; if ($f) { $findings.Add($f) } }
            if ($Tokens.ContainsKey('docs-elements-reconciled') -and $Tokens['docs-elements-reconciled'] -cne 'none') {
                foreach ($id in $Tokens['docs-elements-reconciled'].Split(',')) {
                    if ($id.Trim() -cnotmatch '^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$') { $findings.Add("docs-elements-reconciled id '$($id.Trim())' does not match the element-id pattern") }
                }
            }
            $exitToken = 'docs-update-ledger-exit-code'
        }
        'docs-coverage-reviewer' {
            if ($Tokens.ContainsKey('docs-validate-mode') -and @('profile', 'ledger', 'matrix', 'docs-complete') -cnotcontains $Tokens['docs-validate-mode']) { $findings.Add("docs-validate-mode must be profile, ledger, matrix or docs-complete (found '$($Tokens['docs-validate-mode'])')") }
            if ($Tokens.ContainsKey('docs-revision') -and $Tokens['docs-revision'] -cnotmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$') { $findings.Add("docs-revision must be 40 or 64 lowercase hexadecimal characters (found '$($Tokens['docs-revision'])')") }
            if ($Tokens.ContainsKey('docs-receipt-id') -and $Tokens['docs-receipt-id'] -cnotmatch '^\S+$') { $findings.Add('docs-receipt-id must be a receipt id without whitespace or none') }
            $exitToken = 'docs-validate-exit-code'
        }
    }

    if ($null -ne $exitToken -and $Tokens.ContainsKey($exitToken)) {
        $f = Get-DocsRoleIntegerFinding -Token $exitToken -Value $Tokens[$exitToken] -Maximum 3
        if ($f) { $findings.Add($f) }
        elseif ($result -ceq 'PASS' -and $Tokens[$exitToken] -ne '0') { $findings.Add("docs-result PASS requires $exitToken 0 (found '$($Tokens[$exitToken])')") }
    }
    return [string[]]$findings.ToArray()
}

function Test-DocsRoleOutput {
    <#
    .SYNOPSIS
        Validates one documentation role's final message against its token contract.
    .DESCRIPTION
        Every required token must be present once with a valid value. A missing, duplicated or invalid
        token is repairable by the role. An unknown role is a registration defect and is not
        repairable. docs-pages-written may be none when docs-result is FAIL or BLOCKED.
    .PARAMETER Role
        The role named by the SubagentStop envelope AgentType.
    .PARAMETER Text
        The role's final message.
    .PARAMETER TestFile
        Scriptblock taking one repository-relative path and returning $true when the file exists.
    .OUTPUTS
        A hashtable with Ok, Repairable and Message; Message names every failing token.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Role,

        [AllowNull()]
        [AllowEmptyString()]
        [string] $Text,

        [Parameter(Mandatory)]
        [scriptblock] $TestFile
    )

    if ((Get-DocsRoleName) -cnotcontains $Role) {
        return @{ Ok = $false; Repairable = $false; Message = "unknown documentation role '$Role'; the docs-role contract covers only $((Get-DocsRoleName) -join ', ')." }
    }

    $parsed = ConvertFrom-DocsRoleOutput -Text $Text
    $tokens = $parsed.Tokens
    $findings = [System.Collections.Generic.List[string]]::new()
    foreach ($token in (Get-DocsRoleRequiredToken -Role $Role)) {
        if (-not $tokens.ContainsKey($token)) { $findings.Add("missing $token") }
        elseif ([string]::IsNullOrWhiteSpace($tokens[$token])) { $findings.Add("$token has an empty value") }
    }
    foreach ($duplicate in $parsed.Duplicates) { $findings.Add("$duplicate is reported more than once") }

    if ($tokens.ContainsKey('docs-role') -and $tokens['docs-role'] -cne $Role) { $findings.Add("docs-role '$($tokens['docs-role'])' does not equal the stopping agent '$Role'") }
    if ($tokens.ContainsKey('docs-result') -and @('PASS', 'FAIL', 'BLOCKED') -cnotcontains $tokens['docs-result']) { $findings.Add("docs-result must be PASS, FAIL or BLOCKED (found '$($tokens['docs-result'])')") }
    if ($tokens.ContainsKey('docs-findings')) { $f = Get-DocsRoleIntegerFinding -Token 'docs-findings' -Value $tokens['docs-findings']; if ($f) { $findings.Add($f) } }
    foreach ($f in (Get-DocsRoleSpecificFinding -Role $Role -Tokens $tokens -Text ([string]$Text) -TestFile $TestFile)) { $findings.Add($f) }

    if ($findings.Count -eq 0) { return @{ Ok = $true; Repairable = $true; Message = $null } }
    $message = "$Role output check failed; report each token on its own line as 'token: value':`n  - " + ($findings -join "`n  - ")
    return @{ Ok = $false; Repairable = $true; Message = $message }
}
