<#
.SYNOPSIS
    Pure docs-estate predicates shared by the docs-estate legs of the preimplementation and
    model-routing gates (issue #1169).

.DESCRIPTION
    Defines functions and one constant only: it imports nothing, dot-sources nothing, performs
    no I/O, and has no entry point. At call time Test-DocsEstatePath uses
    Test-CleanupConsolidationRelativePath from hook-cleanup-context.ps1, which every consumer
    already loads, for the character-class and '..' rules of a repository-relative path.

      ConvertFrom-DocsEstateProfileText - the structurally valid profile object or $null: a JSON
                                          object whose artifact_kind is docs-profile, whose
                                          documentation_roots is a non-empty array of objects
                                          with plain repository-relative path values, and whose
                                          artifact_paths is an object of string values. The
                                          hooks check structure only, because the Codex hooks
                                          cannot import .claude/lib.
      Test-DocsEstatePath               - the docs path set: a plain relative path that equals
                                          the docs-init workflow path, or that starts with docs/
                                          and lies under the directory of an artifact_paths value
                                          or under a documentation root. A root or artifact
                                          directory outside docs/ admits no path. Every
                                          comparison is ordinal and segment-anchored.
      Get-DocsEstateDelegationLabel     - the branch and base of a delegation prompt that carries
                                          exactly one line-anchored 'branch: <name>' line and
                                          exactly one 'base: <branch>' line, each a conservative
                                          branch spelling without '..'; otherwise $null.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors. The
    control is policy-level, not a security boundary.
#>

# The profile path every docs-estate leg reads beneath the resolved root.
$script:DocsEstateProfileRelativePath = 'docs/documentation-estate/docs-profile.json'

function Test-DocsEstatePlainRelativePath {
    <#
    .SYNOPSIS
        Return $true when a path is non-empty, not rooted, and passes the character-class and
        '..' rules of Test-CleanupConsolidationRelativePath.
    .DESCRIPTION
        The rules are applied by calling Test-CleanupConsolidationRelativePath with the path under
        the docs/ prefix, so only its character-class and '..' rules decide; the prefix rule of
        that function is satisfied by construction.
    .PARAMETER RelativePath
        The repository-relative path.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $RelativePath)

    $path = [string]$RelativePath
    if ($path.Length -eq 0 -or $path.StartsWith('/') -or $path.EndsWith('/')) {
        return $false
    }
    return [bool](Test-CleanupConsolidationRelativePath -RelativePath ('docs/' + $path))
}

function ConvertFrom-DocsEstateProfileText {
    <#
    .SYNOPSIS
        Return the structurally valid profile object, or $null.
    .PARAMETER Text
        The profile text.
    .OUTPUTS
        System.Collections.Hashtable or $null
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()][object] $Text)

    if ($Text -isnot [string] -or $Text.Length -eq 0) {
        return $null
    }
    try {
        $value = ConvertFrom-Json -InputObject $Text -AsHashtable -ErrorAction Stop
    }
    catch {
        return $null
    }
    if ($value -isnot [hashtable] -or -not ($value['artifact_kind'] -is [string] -and $value['artifact_kind'] -ceq 'docs-profile')) {
        return $null
    }
    $roots = $value['documentation_roots']
    if ($roots -isnot [array] -or $roots.Count -eq 0) {
        return $null
    }
    foreach ($root in $roots) {
        if ($root -isnot [hashtable] -or $root['path'] -isnot [string] -or -not (Test-DocsEstatePlainRelativePath -RelativePath $root['path'])) {
            return $null
        }
    }
    $artifactPaths = $value['artifact_paths']
    if ($artifactPaths -isnot [hashtable]) {
        return $null
    }
    foreach ($key in $artifactPaths.Keys) {
        if ($artifactPaths[$key] -isnot [string]) {
            return $null
        }
    }
    return $value
}

function Test-DocsEstatePath {
    <#
    .SYNOPSIS
        Return $true when a repository-relative path is in the docs path set of a profile.
    .PARAMETER RelativePath
        The repository-relative path.
    .PARAMETER ProfileDocument
        The structurally valid profile from ConvertFrom-DocsEstateProfileText (alias Profile).
    .PARAMETER InitWorkflowPath
        The docs-init workflow path ($script:DocsOnlyInitWorkflowPath).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $RelativePath,
        [Alias('Profile')][AllowNull()][hashtable] $ProfileDocument,
        [AllowNull()][AllowEmptyString()][string] $InitWorkflowPath
    )

    $path = [string]$RelativePath
    if ($null -eq $ProfileDocument -or -not (Test-DocsEstatePlainRelativePath -RelativePath $path)) {
        return $false
    }
    if (-not [string]::IsNullOrEmpty($InitWorkflowPath) -and [string]::Equals($path, $InitWorkflowPath, [System.StringComparison]::Ordinal)) {
        return $true
    }
    if (-not $path.StartsWith('docs/', [System.StringComparison]::Ordinal)) {
        return $false
    }
    $artifactPaths = $ProfileDocument['artifact_paths']
    if ($artifactPaths -is [hashtable]) {
        foreach ($key in $artifactPaths.Keys) {
            $value = [string]$artifactPaths[$key]
            $slash = $value.LastIndexOf('/')
            if ($slash -le 0 -or -not (Test-DocsEstatePlainRelativePath -RelativePath $value)) {
                continue
            }
            $directory = $value.Substring(0, $slash + 1)
            if ($path.Length -gt $directory.Length -and $path.StartsWith($directory, [System.StringComparison]::Ordinal)) {
                return $true
            }
        }
    }
    foreach ($root in @($ProfileDocument['documentation_roots'])) {
        $rootPath = [string]$root['path']
        $prefix = $rootPath + '/'
        if ($path.Length -gt $prefix.Length -and $path.StartsWith($prefix, [System.StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

function Get-DocsEstateDelegationLabel {
    <#
    .SYNOPSIS
        Return the branch and base labels of a docs-estate delegation prompt, or $null.
    .DESCRIPTION
        The prompt must contain exactly one 'branch:' and exactly one 'base:' label (each counted
        without case at a word boundary), each on its own line in the lowercase form
        'branch: <value>' and 'base: <value>', with a value of the conservative branch spelling
        ^[A-Za-z0-9][A-Za-z0-9._/-]*$ that holds no '..'. The shape follows
        Test-CleanupConsolidationBranchLabel. The base is explicit and is not fixed to main.
    .PARAMETER PromptText
        The delegation prompt.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Branch and Base, or $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $PromptText)

    $text = [string]$PromptText
    $values = @{}
    foreach ($label in @('branch', 'base')) {
        if ([regex]::Matches($text, "(?i)\b$($label):").Count -ne 1) {
            return $null
        }
        $match = [regex]::Match($text, "(?m)^[ \t]*$($label):[ \t]*(?<value>[^\r\n]*?)[ \t]*\r?$")
        $value = if ($match.Success) { $match.Groups['value'].Value } else { '' }
        if ($value -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $value.Contains('..')) {
            return $null
        }
        $values[$label] = $value
    }
    return [pscustomobject]@{ Branch = $values['branch']; Base = $values['base'] }
}
