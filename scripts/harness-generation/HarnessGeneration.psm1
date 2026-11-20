Set-StrictMode -Version Latest

# Harness generation framework (issue #1028). Pure render functions in the surface modules return an
# expected file map (repository-relative POSIX path -> text); this module selects matrix entries by field,
# normalizes generated text, compares a file map with the tree, writes a validated map, formats the drift
# report, and runs the surfaces in a fixed order. Reading, listing, the reparse-point probe and writing are
# injected script blocks; the defaults below are the only file-system access. No process is started and no
# git history is read.

function Get-HarnessSurfaceOrder {
    <#
    .SYNOPSIS
        Returns the surfaces run by '-Surface all', in run order (instructions, mcp, skills, rules, agents).
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    return [string[]]@('instructions', 'mcp', 'skills', 'rules', 'agents')
}

function Get-HarnessSurfaceModuleMap {
    <#
    .SYNOPSIS
        Returns, per surface, the generator module file under scripts/harness-generation/ and its entry function.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()
    return [ordered]@{
        instructions = [pscustomobject]@{ Module = 'HarnessInstructions.psm1'; Function = 'Get-HarnessInstructionFindings' }
        mcp          = [pscustomobject]@{ Module = 'HarnessMcpConfig.psm1'; Function = 'Get-HarnessMcpFileMap' }
        skills       = [pscustomobject]@{ Module = 'HarnessSkillMirror.psm1'; Function = 'Get-HarnessSkillMirrorFileMap' }
        rules        = [pscustomobject]@{ Module = 'HarnessRuleGeneration.psm1'; Function = 'Get-HarnessRuleFileMap' }
        agents       = [pscustomobject]@{ Module = 'HarnessAgentGeneration.psm1'; Function = 'Get-HarnessAgentFileMap' }
    }
}

function Get-HarnessMatrixSelection {
    <#
    .SYNOPSIS
        Selects parity-matrix entries by field. The id string is never parsed.
    .DESCRIPTION
        Each filter applies only when it is bound; string filters compare ordinally. An entry whose field is
        absent never matches a bound filter on that field.
    .PARAMETER Matrix
        The parsed matrix (an object with a 'features' array).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] $Matrix,
        [string] $Ecosystem,
        [string] $Kind,
        [string] $Disposition,
        [int] $OwnerChild
    )
    $filters = [ordered]@{}
    if ($PSBoundParameters.ContainsKey('Ecosystem')) { $filters['ecosystem'] = $Ecosystem }
    if ($PSBoundParameters.ContainsKey('Kind')) { $filters['kind'] = $Kind }
    if ($PSBoundParameters.ContainsKey('Disposition')) { $filters['disposition'] = $Disposition }
    $selected = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @($Matrix.features)) {
        $names = @($entry.PSObject.Properties | ForEach-Object { $_.Name })
        $match = $true
        foreach ($field in $filters.Keys) {
            if ($names -notcontains $field -or [string]$entry.$field -cne $filters[$field]) { $match = $false; break }
        }
        if ($match -and $PSBoundParameters.ContainsKey('OwnerChild')) {
            $match = ($names -contains 'owner_child') -and ($null -ne $entry.owner_child) -and ([int]$entry.owner_child -eq $OwnerChild)
        }
        if ($match) { $selected.Add($entry) }
    }
    return $selected.ToArray()
}

function Import-HarnessGenerationMatrix {
    <#
    .SYNOPSIS
        Reads and parses config/harness-parity-matrix.json through the context reader.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $path = 'config/harness-parity-matrix.json'
    $text = & $Context.ReadFile $path
    if ($null -eq $text) { throw "The parity matrix '$path' does not exist." }
    return ($text | ConvertFrom-Json)
}

function Get-HarnessBundlePath {
    <#
    .SYNOPSIS
        Returns the bundle copy path under extensions/drm-copilot/resources/ of a generated target, or $null when the target has none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string] $Path)
    $resources = 'extensions/drm-copilot/resources'
    if ($Path -ceq '.mcp.json') { return "$resources/claude-dir-customizations/.mcp.json" }
    if ($Path.StartsWith('.claude/')) { return "$resources/claude-customizations/$Path" }
    if ($Path.StartsWith('.agents/') -or $Path.StartsWith('.codex/') -or $Path -ceq 'AGENTS.md') { return "$resources/codex-and-agents-customizations/$Path" }
    if ($Path.StartsWith('.github/')) { return "$resources/customizations/$Path" }
    return $null
}

function ConvertTo-HarnessGeneratedText {
    <#
    .SYNOPSIS
        Normalizes generated text: LF line endings and no leading byte order mark.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text)
    $normalized = $Text.Replace("`r`n", "`n").Replace("`r", "`n")
    # Ordinal character test: a culture-aware StartsWith treats U+FEFF as ignorable and matches every string.
    if ($normalized.Length -gt 0 -and $normalized[0] -eq [char]0xFEFF) { $normalized = $normalized.Substring(1) }
    return $normalized
}

function Test-HarnessGeneratedPath {
    <#
    .SYNOPSIS
        Returns $true for a repository-relative POSIX path (no leading '/', drive, backslash, '.' or '..' segment).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][object] $Path)
    if ($Path -isnot [string] -or $Path.Length -eq 0) { return $false }
    if ($Path.StartsWith('/') -or $Path -match '^[A-Za-z]:' -or $Path.Contains('\')) { return $false }
    foreach ($segment in $Path.Split('/')) { if ($segment -in @('', '.', '..')) { return $false } }
    return $true
}

function New-HarnessFinding {
    <#
    .SYNOPSIS
        Builds one finding: a kind (DRIFT, MISSING, EXTRA or a surface-specific check kind), a path and a detail.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory constructor; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $Kind,
        [Parameter(Mandatory = $true)][string] $Path,
        [AllowEmptyString()][string] $Detail = ''
    )
    return [pscustomobject]@{ Kind = $Kind; Path = $Path; Detail = $Detail }
}

function Read-HarnessRepositoryFile {
    <#
    .SYNOPSIS
        Default reader: returns the UTF-8 text of a repository file (a byte order mark is kept), or $null when absent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string] $Root, [Parameter(Mandatory = $true)][string] $Path)
    $fullPath = Join-Path -Path $Root -ChildPath $Path
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { return $null }
    return [System.Text.UTF8Encoding]::new($false).GetString([System.IO.File]::ReadAllBytes($fullPath))
}

function Get-HarnessRepositoryFileList {
    <#
    .SYNOPSIS
        Default lister: returns the repository-relative POSIX paths of every file under a folder (empty when absent).
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)][string] $Root, [Parameter(Mandatory = $true)][string] $Folder)
    $fullFolder = Join-Path -Path $Root -ChildPath $Folder
    if (-not (Test-Path -LiteralPath $fullFolder -PathType Container)) { return [string[]]@() }
    $rootFull = [System.IO.Path]::GetFullPath($Root)
    $paths = foreach ($item in @(Get-ChildItem -LiteralPath $fullFolder -File -Recurse -Force)) {
        [System.IO.Path]::GetRelativePath($rootFull, $item.FullName).Replace('\', '/')
    }
    return [string[]]@($paths | Sort-Object)
}

function Test-HarnessReparsePoint {
    <#
    .SYNOPSIS
        Default reparse probe: returns $true when the repository path exists and is a reparse point or symbolic link.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][string] $Root, [Parameter(Mandatory = $true)][string] $Path)
    $item = Get-Item -LiteralPath (Join-Path -Path $Root -ChildPath $Path) -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $false }
    return [bool]($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

function Write-HarnessRepositoryFile {
    <#
    .SYNOPSIS
        Default writer: writes text as UTF-8 without byte order mark, creating the parent folder.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text
    )
    $fullPath = Join-Path -Path $Root -ChildPath $Path
    if (-not $PSCmdlet.ShouldProcess($Path, 'Write generated file')) { return }
    $parent = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { $null = New-Item -ItemType Directory -Path $parent -Force }
    Set-Content -LiteralPath $fullPath -Value $Text -NoNewline -Encoding utf8NoBOM
}

function New-HarnessGenerationContext {
    <#
    .SYNOPSIS
        Builds the context passed to every surface: the root and the read, list and reparse seams.
    .DESCRIPTION
        An unbound seam defaults to the repository file system under -Root.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory constructor; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [scriptblock] $ReadFile,
        [scriptblock] $ListFiles,
        [scriptblock] $TestReparse
    )
    $rootPath = $Root
    $reader = ${function:Read-HarnessRepositoryFile}
    $lister = ${function:Get-HarnessRepositoryFileList}
    $probe = ${function:Test-HarnessReparsePoint}
    if ($null -eq $ReadFile) { $ReadFile = { param([string] $Path) & $reader -Root $rootPath -Path $Path }.GetNewClosure() }
    if ($null -eq $ListFiles) { $ListFiles = { param([string] $Folder) & $lister -Root $rootPath -Folder $Folder }.GetNewClosure() }
    if ($null -eq $TestReparse) { $TestReparse = { param([string] $Path) & $probe -Root $rootPath -Path $Path }.GetNewClosure() }
    return [pscustomobject]@{ Root = $Root; ReadFile = $ReadFile; ListFiles = $ListFiles; TestReparse = $TestReparse }
}

function Compare-HarnessFileMap {
    <#
    .SYNOPSIS
        Compares an expected file map with the tree and returns DRIFT, MISSING and EXTRA findings.
    .DESCRIPTION
        Exact text comparison: a CRLF or byte-order-mark target, and a target that is a reparse point, is drift.
        Each managed folder is listed; a file there that the map does not hold is EXTRA.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $FileMap,
        [Parameter(Mandatory = $true)][pscustomobject] $Context,
        [string[]] $ManagedFolders = @()
    )
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($path in @($FileMap.Keys)) {
        if (& $Context.TestReparse $path) { $findings.Add((New-HarnessFinding -Kind 'DRIFT' -Path $path -Detail 'reparse point or symbolic link')); continue }
        $actual = & $Context.ReadFile $path
        if ($null -eq $actual) { $findings.Add((New-HarnessFinding -Kind 'MISSING' -Path $path)); continue }
        $expected = [string]$FileMap[$path]
        if ([string]::Equals([string]$actual, $expected, [System.StringComparison]::Ordinal)) { continue }
        $detail = 'content differs'
        if ([string]$actual -match "`r") { $detail = 'CRLF line endings' }
        elseif ([string]$actual -ne '' -and ([string]$actual)[0] -eq [char]0xFEFF) { $detail = 'byte order mark' }
        $findings.Add((New-HarnessFinding -Kind 'DRIFT' -Path $path -Detail $detail))
    }
    $known = [System.Collections.Generic.HashSet[string]]::new([string[]]@($FileMap.Keys), [System.StringComparer]::Ordinal)
    foreach ($folder in $ManagedFolders) {
        foreach ($listed in @(& $Context.ListFiles $folder)) {
            if ($null -ne $listed -and -not $known.Contains([string]$listed)) { $findings.Add((New-HarnessFinding -Kind 'EXTRA' -Path ([string]$listed))) }
        }
    }
    return $findings.ToArray()
}

function Write-HarnessFileMap {
    <#
    .SYNOPSIS
        Validates the whole file map, then writes each entry whose current text differs.
    .DESCRIPTION
        Every path must be repository-relative POSIX and every text LF without a byte order mark; the first
        invalid entry throws before any write. Returns the written paths.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $FileMap,
        [Parameter(Mandatory = $true)][pscustomobject] $Context,
        [Parameter(Mandatory = $true)][scriptblock] $WriteFile
    )
    foreach ($path in @($FileMap.Keys)) {
        if (-not (Test-HarnessGeneratedPath -Path $path)) { throw "Generated path '$path' is not a repository-relative POSIX path; nothing was written." }
        $text = $FileMap[$path]
        if ($text -isnot [string]) { throw "Generated text for '$path' is not a string; nothing was written." }
        if ($text.Contains("`r") -or ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF)) { throw "Generated text for '$path' is not LF without a byte order mark; nothing was written." }
    }
    $written = [System.Collections.Generic.List[string]]::new()
    foreach ($path in @($FileMap.Keys)) {
        if (-not [bool](& $Context.TestReparse $path)) {
            $current = & $Context.ReadFile $path
            if ($null -ne $current -and [string]::Equals([string]$current, [string]$FileMap[$path], [System.StringComparison]::Ordinal)) { continue }
        }
        if ($PSCmdlet.ShouldProcess($path, 'Write generated file')) {
            & $WriteFile $path ([string]$FileMap[$path])
            $written.Add($path)
        }
    }
    return $written.ToArray()
}

function Format-HarnessDriftReport {
    <#
    .SYNOPSIS
        Formats findings as one line per path ('<KIND> <path>' plus an optional detail) and a summary line.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowEmptyCollection()][object[]] $Findings = @())
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($finding in @($Findings | Sort-Object -Property @{ Expression = { $_.Path } }, @{ Expression = { $_.Kind } })) {
        if ([string]::IsNullOrEmpty($finding.Detail)) { $lines.Add("$($finding.Kind) $($finding.Path)") }
        else { $lines.Add("$($finding.Kind) $($finding.Path) ($($finding.Detail))") }
    }
    if ($lines.Count -eq 0) { $lines.Add('harness-generation: no drift') }
    else { $lines.Add("harness-generation: $($lines.Count) finding(s)") }
    return $lines.ToArray()
}

function Get-HarnessSurfaceProvider {
    <#
    .SYNOPSIS
        Returns the default provider of a surface: a script block that imports the surface module and calls its entry function.
    .DESCRIPTION
        The provider takes the generation context and returns an object with Files (ordered path -> text map),
        ManagedFolders and Findings. A surface whose module file does not exist throws when invoked.
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('instructions', 'mcp', 'skills', 'rules', 'agents')][string] $Surface,
        [string] $ModuleRoot = $PSScriptRoot
    )
    $entry = (Get-HarnessSurfaceModuleMap)[$Surface]
    $modulePath = Join-Path -Path $ModuleRoot -ChildPath $entry.Module
    $functionName = $entry.Function
    $surfaceName = $Surface
    return {
        param($Context)
        if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) { throw "Surface '$surfaceName' has no generator module '$modulePath'." }
        $module = Import-Module -Name $modulePath -PassThru -ErrorAction Stop
        & $module.ExportedCommands[$functionName] -Context $Context
    }.GetNewClosure()
}

function Invoke-HarnessGeneration {
    <#
    .SYNOPSIS
        Runs one surface or all surfaces in check or write mode and returns the exit code, findings and report.
    .DESCRIPTION
        Every selected surface renders first, so a malformed source throws before any write. Check mode writes
        nothing. Write mode writes the merged map and then re-compares it. 'instructions' is check-only, both on
        its own (write mode throws) and inside 'all'. ExitCode is 0 when no finding remains, otherwise 1.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('skills', 'rules', 'mcp', 'agents', 'instructions', 'all')][string] $Surface,
        [Parameter(Mandatory = $true)][pscustomobject] $Context,
        [switch] $Check,
        [System.Collections.IDictionary] $Providers = @{},
        [scriptblock] $WriteFile
    )
    if ($Surface -eq 'instructions' -and -not $Check) { throw "Surface 'instructions' is check-only; pass -Check." }
    $surfaces = if ($Surface -eq 'all') { Get-HarnessSurfaceOrder } else { [string[]]@($Surface) }
    $merged = [ordered]@{}
    $managed = [System.Collections.Generic.List[string]]::new()
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($name in $surfaces) {
        $provider = if ($Providers.Contains($name)) { $Providers[$name] } else { Get-HarnessSurfaceProvider -Surface $name }
        $result = & $provider $Context
        foreach ($path in @($result.Files.Keys)) {
            if ($merged.Contains($path)) { throw "Generated path '$path' is produced by more than one surface; nothing was written." }
            $merged[$path] = $result.Files[$path]
        }
        foreach ($folder in @($result.ManagedFolders)) { if ($folder) { $managed.Add([string]$folder) } }
        foreach ($finding in @($result.Findings)) { if ($null -ne $finding) { $findings.Add($finding) } }
    }
    $written = [string[]]@()
    if (-not $Check -and $merged.Count -gt 0) {
        if ($null -eq $WriteFile) {
            # Module-bound block (no closure): it resolves the writer by name and reads $generationRoot from
            # this function's scope when Write-HarnessFileMap invokes it.
            $generationRoot = $Context.Root
            $WriteFile = { param([string] $Path, [string] $Text) Write-HarnessRepositoryFile -Root $generationRoot -Path $Path -Text $Text }
        }
        $written = [string[]]@(Write-HarnessFileMap -FileMap $merged -Context $Context -WriteFile $WriteFile -WhatIf:$WhatIfPreference)
    }
    foreach ($finding in @(Compare-HarnessFileMap -FileMap $merged -Context $Context -ManagedFolders $managed.ToArray())) { $findings.Add($finding) }
    $all = $findings.ToArray()
    return [pscustomobject]@{
        ExitCode = $(if ($all.Count -eq 0) { 0 } else { 1 })
        Findings = $all
        Report   = [string[]]@(Format-HarnessDriftReport -Findings $all)
        Written  = $written
    }
}

function Get-HarnessRepositoryDrift {
    <#
    .SYNOPSIS
        Runs every surface in check mode and returns the findings (empty when the tree has no drift).
    .DESCRIPTION
        Starts no process and reads no git history; used by the repository gate.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject] $Context,
        [System.Collections.IDictionary] $Providers = @{}
    )
    $result = Invoke-HarnessGeneration -Surface 'all' -Context $Context -Check -Providers $Providers
    return @($result.Findings)
}

Export-ModuleMember -Function @(
    'Get-HarnessSurfaceOrder', 'Get-HarnessSurfaceModuleMap', 'Get-HarnessMatrixSelection', 'Import-HarnessGenerationMatrix',
    'Get-HarnessBundlePath', 'ConvertTo-HarnessGeneratedText',
    'Test-HarnessGeneratedPath', 'New-HarnessFinding', 'Read-HarnessRepositoryFile', 'Get-HarnessRepositoryFileList',
    'Test-HarnessReparsePoint', 'Write-HarnessRepositoryFile', 'New-HarnessGenerationContext', 'Compare-HarnessFileMap',
    'Write-HarnessFileMap', 'Format-HarnessDriftReport', 'Get-HarnessSurfaceProvider', 'Invoke-HarnessGeneration',
    'Get-HarnessRepositoryDrift'
)
