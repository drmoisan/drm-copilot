<#
.SYNOPSIS
    Pure decision logic for the worktree Poetry virtual-environment guard (issue #1127).

.DESCRIPTION
    Poetry honors an inherited VIRTUAL_ENV over the in-project configuration, so a
    mutating Poetry command run in an agent worktree writes into the main checkout's
    environment when the session exported VIRTUAL_ENV for that checkout. These functions
    decide whether a Bash command would do that.

    Pure string logic only: no environment, disk, process, or $IsWindows read. Path
    comparison treats Windows, forward-slash, and Git Bash drive forms as strings, so the
    same results hold on every host. The command text is segmented by
    Read-CommandLineInvocationSegment, which the calling hook loads by dot-sourcing
    hook-command-invocation.ps1 before this file; the shared option tables are not used.

    Dot-sourced as: . (Join-Path $PSScriptRoot 'worktree-poetry-venv-policy.ps1')
#>

# Poetry subcommands that install into, or remove from, the active environment.
$script:WorktreePoetryMutatingSubcommand = @('install', 'sync', 'add', 'remove', 'update')

# Poetry global options that take a directory value as the following token.
$script:WorktreePoetryDirectoryOption = @('-C', '--directory', '-P', '--project')

$script:WorktreePoetryVenvBlockedReason = "WORKTREE_VENV_BLOCKED: a mutating Poetry command would write into the virtual environment named by VIRTUAL_ENV, which lies outside the target project. From the worktree root run env -u VIRTUAL_ENV poetry install to create the worktree's own in-project .venv; never repoint the main checkout's environment. An agent whose Bash working directory is not the worktree root runs env -u VIRTUAL_ENV poetry -C <worktree root> install instead of changing directory first."

function Get-WorktreePoetryVenvBlockedReason {
    <#
    .SYNOPSIS
        Return the deny reason of the worktree Poetry virtual-environment guard.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return $script:WorktreePoetryVenvBlockedReason
}

function ConvertTo-WorktreePoetryComparablePath {
    <#
    .SYNOPSIS
        Normalize a path string for comparison.
    .DESCRIPTION
        Converts backslashes to forward slashes, rewrites a Git Bash drive prefix such as
        /c/ to c:/, resolves '.' and '..' segments, trims trailing separators, and
        lower-cases the result. Returns an empty string for a null or blank value.
    .PARAMETER Path
        The path text.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][AllowEmptyString()][string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    $text = $Path.Trim().Replace('\', '/')
    if ($text -match '^/([A-Za-z])(/.*)?$') { $text = $Matches[1] + ':' + $Matches[2] }
    $rooted = $text.StartsWith('/')
    $segments = [System.Collections.Generic.List[string]]::new()
    foreach ($segment in $text.Split('/')) {
        if ($segment -eq '' -or $segment -eq '.') { continue }
        if ($segment -eq '..') {
            if ($segments.Count -gt 1 -or ($segments.Count -eq 1 -and -not $segments[0].EndsWith(':'))) { $segments.RemoveAt($segments.Count - 1) }
            continue
        }
        $segments.Add($segment)
    }
    $joined = $segments -join '/'
    if ($rooted) { $joined = '/' + $joined }
    return $joined.ToLowerInvariant()
}

function Test-WorktreePoetryPathWithin {
    <#
    .SYNOPSIS
        Report whether a path is equal to, or beneath, a container path.
    .DESCRIPTION
        Both values are normalized first. A prefix match requires a separator boundary,
        so c:/repo/.venv-old is not within c:/repo/.venv.
    .PARAMETER Path
        The candidate path.
    .PARAMETER Container
        The container path.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Path,
        [AllowNull()][AllowEmptyString()][string] $Container
    )

    $candidate = ConvertTo-WorktreePoetryComparablePath -Path $Path
    $root = ConvertTo-WorktreePoetryComparablePath -Path $Container
    if ($candidate -eq '' -or $root -eq '') { return $false }
    if ($candidate -eq $root) { return $true }
    $prefix = if ($root.EndsWith('/')) { $root } else { $root + '/' }
    return $candidate.StartsWith($prefix, [System.StringComparison]::Ordinal)
}

function Test-WorktreePoetryRootedPath {
    <#
    .SYNOPSIS
        Report whether a path string is rooted (drive letter, leading separator).
    .PARAMETER Path
        The path text.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Path)

    return (-not [string]::IsNullOrEmpty($Path)) -and ($Path -match '^([A-Za-z]:|[\\/])')
}

function Join-WorktreePoetryTargetPath {
    <#
    .SYNOPSIS
        Resolve a directory value against a base directory.
    .DESCRIPTION
        A rooted value is returned unchanged. A relative value is joined to the base. The
        result is $null when the value cannot be derived as a string: a blank value, a
        home-relative value, a value carrying a shell expansion, or a relative value with
        no base.
    .PARAMETER BasePath
        The directory the value is relative to.
    .PARAMETER ChildPath
        The directory value.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $BasePath,
        [AllowNull()][AllowEmptyString()][string] $ChildPath
    )

    if ([string]::IsNullOrWhiteSpace($ChildPath) -or $ChildPath.StartsWith('~') -or $ChildPath.Contains('$')) { return $null }
    if (Test-WorktreePoetryRootedPath -Path $ChildPath) { return $ChildPath }
    if ([string]::IsNullOrWhiteSpace($BasePath)) { return $null }
    return ($BasePath.TrimEnd('\', '/') + '/' + $ChildPath)
}

function Get-WorktreePoetryPrefixEnd {
    <#
    .SYNOPSIS
        Skip VAR=value words and transparent wrappers before a command word.
    .DESCRIPTION
        Returns Index (the position of the command word) and Neutralized, true when an env
        prefix unsets VIRTUAL_ENV (-u VIRTUAL_ENV, -uVIRTUAL_ENV, or --unset=VIRTUAL_ENV).
    .PARAMETER Token
        The words of one command record.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    $index = 0
    $neutralized = $false
    while ($index -lt $Token.Count) {
        if ($Token[$index] -match '^[A-Za-z_][A-Za-z0-9_]*=') { $index++; continue }
        $leaf = (ConvertTo-CommandLineLeafWord -Word $Token[$index]).ToLowerInvariant()
        if (@('env', 'command', 'nohup', 'time', 'timeout') -notcontains $leaf) { break }
        $index++
        if ($leaf -eq 'env') {
            while ($index -lt $Token.Count) {
                $word = $Token[$index]
                if ($word -ceq '-u' -or $word -ceq '--unset') {
                    if ($index + 1 -lt $Token.Count -and $Token[$index + 1] -ceq 'VIRTUAL_ENV') { $neutralized = $true }
                    $index += 2
                } elseif ($word -ceq '-uVIRTUAL_ENV' -or $word -ceq '--unset=VIRTUAL_ENV') {
                    $neutralized = $true
                    $index++
                } elseif ($word.StartsWith('-') -or $word -match '^[A-Za-z_][A-Za-z0-9_]*=') {
                    $index++
                } else {
                    break
                }
            }
        } elseif ($leaf -eq 'timeout') {
            while ($index -lt $Token.Count -and $Token[$index].StartsWith('-')) { $index++ }
            if ($index -lt $Token.Count) { $index++ }
        } elseif ($leaf -eq 'time') {
            if ($index -lt $Token.Count -and $Token[$index] -ceq '-p') { $index++ }
        } elseif ($leaf -eq 'command') {
            while ($index -lt $Token.Count -and @('-p', '-v', '-V') -ccontains $Token[$index]) { $index++ }
        }
    }
    return [pscustomobject]@{ Index = $index; Neutralized = $neutralized }
}

function Get-WorktreePoetryCommandShape {
    <#
    .SYNOPSIS
        Read the Poetry subcommand and directory option from one command record.
    .DESCRIPTION
        Returns $null when the record does not invoke Poetry with a subcommand. Otherwise
        returns Subcommand (lower-cased), Directory (the -C, --directory, -P, or --project
        value, or $null), and Neutralized from the env prefix.
    .PARAMETER Token
        The words of one command record.
    .OUTPUTS
        System.Management.Automation.PSCustomObject or $null
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    $prefix = Get-WorktreePoetryPrefixEnd -Token $Token
    $index = $prefix.Index
    if ($index -ge $Token.Count -or (ConvertTo-CommandLineLeafWord -Word $Token[$index]).ToLowerInvariant() -ne 'poetry') { return $null }
    $index++
    $directory = $null
    while ($index -lt $Token.Count -and $Token[$index].StartsWith('-')) {
        $word = $Token[$index]
        if ($script:WorktreePoetryDirectoryOption -ccontains $word) {
            if ($index + 1 -lt $Token.Count) { $directory = $Token[$index + 1] }
            $index += 2
            continue
        }
        if ($word -cmatch '^--(directory|project)=(.*)$') { $directory = $Matches[2] }
        $index++
    }
    if ($index -ge $Token.Count) { return $null }
    return [pscustomobject]@{ Subcommand = $Token[$index].ToLowerInvariant(); Directory = $directory; Neutralized = $prefix.Neutralized }
}

function Get-WorktreePoetryMutatingInvocation {
    <#
    .SYNOPSIS
        Return one record per mutating Poetry invocation in a command line.
    .DESCRIPTION
        Walks the records of Read-CommandLineInvocationSegment. Unbalanced and Opaque
        records are skipped. Each result carries Subcommand, Directory (the Poetry
        directory option or $null), CdPath (the cd values of earlier records at the same
        depth, in order), CdUnknown (an earlier cd whose value is not a literal path), and
        Neutralized (an env prefix that unsets VIRTUAL_ENV, an earlier unset VIRTUAL_ENV at
        the same depth, or a neutralized root record of a wrapper payload).
    .PARAMETER CommandText
        The raw Bash command text.
    .OUTPUTS
        System.Management.Automation.PSCustomObject[]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param([AllowNull()][AllowEmptyString()][string] $CommandText)

    $results = [System.Collections.Generic.List[pscustomobject]]::new()
    $records = @(Read-CommandLineInvocationSegment -CommandText $CommandText)
    $rootNeutralized = @{}
    for ($position = 0; $position -lt $records.Count; $position++) {
        $record = $records[$position]
        if ($record.Unbalanced -or $record.Opaque) { continue }
        $token = [string[]]@($record.Tokens)
        $shape = Get-WorktreePoetryCommandShape -Token $token
        $prefix = Get-WorktreePoetryPrefixEnd -Token $token
        $neutralized = $prefix.Neutralized -or ($record.Depth -gt 0 -and $rootNeutralized.ContainsKey($record.RootIndex))
        $cdPath = [System.Collections.Generic.List[string]]::new()
        $cdUnknown = $false
        for ($earlier = 0; $earlier -lt $position; $earlier++) {
            $previous = $records[$earlier]
            if ($previous.Depth -ne $record.Depth) { continue }
            $words = [string[]]@($previous.Tokens)
            if ($words.Count -eq 0) { continue }
            $leaf = (ConvertTo-CommandLineLeafWord -Word $words[0]).ToLowerInvariant()
            if ($leaf -eq 'unset' -and $words -ccontains 'VIRTUAL_ENV') { $neutralized = $true }
            if ($leaf -eq 'cd') {
                $value = @($words | Select-Object -Skip 1 | Where-Object { -not $_.StartsWith('-') }) | Select-Object -First 1
                if ([string]::IsNullOrWhiteSpace($value) -or $value.StartsWith('~') -or $value.Contains('$')) { $cdUnknown = $true } else { $cdPath.Add($value) }
            }
        }
        if ($record.Depth -eq 0 -and $neutralized) { $rootNeutralized[$record.Index] = $true }
        if ($null -eq $shape -or $script:WorktreePoetryMutatingSubcommand -notcontains $shape.Subcommand) { continue }
        $results.Add([pscustomobject]@{
                Subcommand  = $shape.Subcommand
                Directory   = $shape.Directory
                CdPath      = [string[]]$cdPath.ToArray()
                CdUnknown   = $cdUnknown
                Neutralized = $neutralized
            })
    }
    return $results.ToArray()
}

function Resolve-WorktreePoetryTargetDirectory {
    <#
    .SYNOPSIS
        Resolve the project directory one Poetry invocation targets.
    .DESCRIPTION
        Starts from cwd, applies each earlier cd value in order, then the Poetry directory
        option. Returns $null when any step cannot be derived.
    .PARAMETER Invocation
        One result of Get-WorktreePoetryMutatingInvocation.
    .PARAMETER Cwd
        The payload working directory.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Invocation,
        [AllowNull()][AllowEmptyString()][string] $Cwd
    )

    if ($Invocation.CdUnknown) { return $null }
    $current = if ([string]::IsNullOrWhiteSpace($Cwd)) { $null } else { $Cwd }
    foreach ($value in @($Invocation.CdPath)) {
        $current = Join-WorktreePoetryTargetPath -BasePath $current -ChildPath $value
        if ($null -eq $current) { return $null }
    }
    if ($null -ne $Invocation.Directory) {
        return (Join-WorktreePoetryTargetPath -BasePath $current -ChildPath $Invocation.Directory)
    }
    return $current
}

function Get-WorktreePoetryVenvDenyReason {
    <#
    .SYNOPSIS
        Return the deny reason when a command would write into an outside VIRTUAL_ENV.
    .DESCRIPTION
        Denies when the command invokes Poetry install, sync, add, remove, or update, the
        VIRTUAL_ENV value is non-empty, the command does not neutralize VIRTUAL_ENV, and the
        VIRTUAL_ENV path is not equal to or beneath the target directory. A target that
        cannot be derived allows.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER Cwd
        The payload working directory.
    .PARAMETER VirtualEnv
        The VIRTUAL_ENV value of the hook process.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][AllowEmptyString()][string] $Cwd,
        [AllowNull()][AllowEmptyString()][string] $VirtualEnv
    )

    if ([string]::IsNullOrWhiteSpace($VirtualEnv) -or [string]::IsNullOrWhiteSpace($CommandText)) { return $null }
    foreach ($invocation in @(Get-WorktreePoetryMutatingInvocation -CommandText $CommandText)) {
        if ($invocation.Neutralized) { continue }
        $target = Resolve-WorktreePoetryTargetDirectory -Invocation $invocation -Cwd $Cwd
        if ($null -eq $target) { continue }
        if (-not (Test-WorktreePoetryPathWithin -Path $VirtualEnv -Container $target)) { return (Get-WorktreePoetryVenvBlockedReason) }
    }
    return $null
}
