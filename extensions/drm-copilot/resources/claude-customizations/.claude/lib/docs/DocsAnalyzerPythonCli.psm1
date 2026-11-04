<#
.SYNOPSIS
    The python-cli analyzer of issue #1022: merges the argparse, Click and Typer site
    recognizers with the pyproject.toml console-script tables into cli-command and cli-option
    elements.

.DESCRIPTION
    Invoke-DocsAnalyzerPythonCli -CapturedInput -Selection returns @{ Elements; Diagnostics }
    (1020 analyzer contract). Every Python input runs the shared front-end; its diagnostics are
    reported under python-cli and a blocking one removes the file's elements. A console script
    is a cli-command at its pyproject.toml path; when its module:attr target resolves to exactly
    one input whose root site is named by attr, the root is attached: the script element is the
    root, its subcommands and options carry the script name and the script's parent_id, and the
    root itself is not emitted. The module:attr target is never exported. Root names follow
    Resolve-DocsCliRootName (console-script name, then literal, then module dotted name).
    Elements are built by ConvertTo-DocsCliElement through 1020 New-DocsSurfaceElement
    -SourceText -LineRange (the site span reduced by ConvertTo-DocsLineRange) with
    analysis_method scanner; this module computes no digest. Duplicate declarations and
    rejected declarations are handled by Select-DocsUniqueElement.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1022. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonBindings.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTomlKeys.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonCliArgparse.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonCliClick.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonCliTyper.psm1') -ErrorAction Stop

$script:DocsCliAnalyzerId = 'python-cli'

function Resolve-DocsCliRootName {
    <#
    .SYNOPSIS
        Returns @{ Name; Source } for a root site: the attached console-script name, then the literal name, then the module dotted name.
    .DESCRIPTION
        Source is console-script, literal or module. A root with no literal name and no module
        name (a path outside every source root) returns $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Site,
        [AllowNull()] [AllowEmptyString()] [string] $ScriptName,
        [AllowNull()] [AllowEmptyString()] [string] $ModuleName
    )

    if (-not [string]::IsNullOrEmpty($ScriptName)) { return @{ Name = $ScriptName; Source = 'console-script' } }
    if ($Site.ContainsKey('Name') -and -not [string]::IsNullOrEmpty([string] $Site['Name'])) { return @{ Name = [string] $Site['Name']; Source = 'literal' } }
    if (-not [string]::IsNullOrEmpty($ModuleName)) { return @{ Name = $ModuleName; Source = 'module' } }
    return $null
}

function ConvertTo-DocsCliElement {
    <#
    .SYNOPSIS
        Returns the Select-DocsUniqueElement candidate of one site: @{ Line; Parameter }.
    .DESCRIPTION
        Parameter is the New-DocsSurfaceElement argument set (Kind cli-command or cli-option,
        Path, Declaration, Name, AnalyzerId python-cli, AnalysisMethod scanner, SourceText, the
        parent element identifier, LineRange reduced from the site span by
        ConvertTo-DocsLineRange, and Property). The digest is computed by New-DocsSurfaceElement
        when the candidate is built; this function supplies the captured input text only.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Site,
        [Parameter(Mandatory = $true)] [string] $Declaration,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SourceText,
        [AllowNull()] [AllowEmptyString()] [string] $ParentId,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Property
    )

    $isOption = $Site['Kind'] -ceq 'option'
    $name = if ($isOption) { [string] $Site['Name'] } else { $Declaration.Split(' ')[-1] }
    $parameter = @{
        Kind           = $(if ($isOption) { 'cli-option' } else { 'cli-command' })
        Path           = $Path
        Declaration    = $Declaration
        Name           = $name
        AnalyzerId     = $script:DocsCliAnalyzerId
        AnalysisMethod = 'scanner'
        SourceText     = $SourceText
        ParentId       = $(if ([string]::IsNullOrEmpty($ParentId)) { $null } else { $ParentId })
        LineRange      = (ConvertTo-DocsLineRange -Span @(, $Site['Span']))
        Property       = $Property
    }
    return @{ Line = [int] $Site['Line']; Parameter = $parameter }
}

function Add-DocsCliRecordDiagnostic {
    <#
    .SYNOPSIS
        Adds recognizer diagnostic records to the aggregate under python-cli (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Aggregate, [Parameter(Mandatory = $true)] [string] $Path, [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Record)

    foreach ($entry in $Record) {
        Add-DocsDiagnosticOccurrence -Aggregate $Aggregate -AnalyzerId $script:DocsCliAnalyzerId -Code $entry['Code'] -Path $Path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity'])
    }
}

function Resolve-DocsCliDeclaration {
    <#
    .SYNOPSIS
        Resolves the declaration and parent of one site with memoization: @{ Declaration; Path; Property } or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Id,
        [Parameter(Mandatory = $true)] [hashtable] $File,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.Dictionary[string, object]] $Memo,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visiting
    )

    $known = $null
    if ($Memo.TryGetValue($Id, [ref] $known)) { return $known }
    $site = $null
    if (-not $File['SiteById'].TryGetValue($Id, [ref] $site) -or -not $Visiting.Add($Id)) { return $null }
    $resolved = $null
    if ($null -eq $site['ParentId']) {
        $script = $null
        [void] $File['Attached'].TryGetValue($Id, [ref] $script)
        $root = Resolve-DocsCliRootName -Site $site -ScriptName $(if ($null -ne $script) { $script['Name'] } else { $null }) -ModuleName $File['Module']
        if ($null -ne $root) {
            $resolved = @{ Declaration = $root['Name']; Path = $(if ($null -ne $script) { $script['Path'] } else { $File['Path'] }); Emit = ($null -eq $script); Source = $root['Source'] }
        }
    } else {
        $parent = Resolve-DocsCliDeclaration -Id $site['ParentId'] -File $File -Memo $Memo -Visiting $Visiting
        if ($null -ne $parent) {
            $segment = if (-not [string]::IsNullOrEmpty([string] $site['Name'])) { [string] $site['Name'] } elseif ($site.ContainsKey('DefaultName')) { [string] $site['DefaultName'] } else { '' }
            if ($segment.Length -gt 0) { $resolved = @{ Declaration = $parent['Declaration'] + ' ' + $segment; Path = $File['Path']; Emit = $true; Source = $null; ParentDeclaration = $parent['Declaration']; ParentPath = $parent['Path'] } }
        }
    }
    [void] $Visiting.Remove($Id)
    $Memo[$Id] = $resolved
    return $resolved
}

function Invoke-DocsAnalyzerPythonCli {
    <#
    .SYNOPSIS
        Runs the python-cli scanner over the captured inputs and returns @{ Elements; Diagnostics }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection
    )

    $sourceRoots = [string[]]@('.')
    if ($Selection -is [System.Collections.IDictionary] -and $Selection.Contains('source_roots') -and $null -ne $Selection['source_roots']) { $sourceRoots = [string[]]@($Selection['source_roots']) }
    $aggregate = New-DocsDiagnosticAggregate
    [object[]] $inputs = @($CapturedInput | Where-Object { $null -ne $_ -and $null -ne $_['text'] })
    [string[]] $inputKeys = @($inputs | ForEach-Object { [string] $_['path'] })
    [Array]::Sort($inputKeys, $inputs, [System.StringComparer]::Ordinal)
    $moduleMap = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $files = [System.Collections.Generic.List[object]]::new()
    $scripts = [System.Collections.Generic.List[object]]::new()
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        $text = [string] $captured['text']
        if ($path -ceq 'pyproject.toml' -or $path.EndsWith('/pyproject.toml', [System.StringComparison]::Ordinal)) {
            $table = Get-DocsTomlScriptEntry -Text $text
            Add-DocsCliRecordDiagnostic -Aggregate $aggregate -Path $path -Record $table['Diagnostics']
            foreach ($entry in $table['Entries']) { $scripts.Add(@{ Name = $entry['Name']; Table = $entry['Table']; Target = $entry['Target']; Span = $entry['Span']; Path = $path; Text = $text; Attached = $false }) }
            continue
        }
        if (-not $path.EndsWith('.py', [System.StringComparison]::Ordinal)) { continue }
        $frontEnd = Get-DocsPythonFrontEnd -Text $text
        Add-DocsCliRecordDiagnostic -Aggregate $aggregate -Path $path -Record $frontEnd['Diagnostics']
        if ($frontEnd['Blocked']) { continue }
        $module = Get-DocsModuleDottedName -Path $path -SourceRoot $sourceRoots
        if ($null -ne $module) {
            if (-not $moduleMap.ContainsKey($module)) { $moduleMap[$module] = [System.Collections.Generic.List[object]]::new() }
            $moduleMap[$module].Add($files.Count)
        }
        $siteById = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
        $sites = [System.Collections.Generic.List[object]]::new()
        foreach ($result in @((Get-DocsArgparseCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']), (Get-DocsClickCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']), (Get-DocsTyperCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']))) {
            Add-DocsCliRecordDiagnostic -Aggregate $aggregate -Path $path -Record $result['Diagnostics']
            foreach ($site in $result['Site']) {
                $id = [string] $site['Framework'] + ':' + [string] $site['Id']
                $copy = $site.Clone()
                $copy['Id'] = $id
                if ($null -ne $copy['ParentId']) { $copy['ParentId'] = [string] $site['Framework'] + ':' + [string] $copy['ParentId'] }
                $sites.Add($copy)
                $siteById[$id] = $copy
            }
        }
        $files.Add(@{ Path = $path; Text = $text; Module = $module; Site = $sites.ToArray(); SiteById = $siteById; Attached = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal) })
    }

    foreach ($script in $scripts) {
        $separator = ([string] $script['Target']).IndexOf(':')
        if ($separator -le 0) { continue }
        $targetModule = ([string] $script['Target']).Substring(0, $separator)
        $attribute = ([string] $script['Target']).Substring($separator + 1)
        $indices = $null
        if (-not $moduleMap.TryGetValue($targetModule, [ref] $indices) -or $indices.Count -ne 1) { continue }
        $file = $files[$indices[0]]
        foreach ($site in $file['Site']) {
            if ($site['Kind'] -ceq 'root' -and $null -eq $site['ParentId'] -and [string] $site['Attach'] -ceq $attribute) {
                $file['Attached'][[string] $site['Id']] = $script
                $script['Attached'] = $true
                break
            }
        }
    }

    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($script in $scripts) {
        $site = @{ Kind = 'command'; Name = $script['Name']; Span = $script['Span']; Line = [int] $script['Span'][0] }
        $property = @{ framework = 'console-script'; name_source = 'console-script'; table = $script['Table']; attached = [bool] $script['Attached'] }
        $candidates.Add((ConvertTo-DocsCliElement -Site $site -Declaration $script['Name'] -Path $script['Path'] -SourceText $script['Text'] -ParentId $null -Property $property))
    }
    foreach ($file in $files) {
        $memo = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
        $visiting = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($site in $file['Site']) {
            $resolved = Resolve-DocsCliDeclaration -Id $site['Id'] -File $file -Memo $memo -Visiting $visiting
            if ($null -eq $resolved -or -not $resolved['Emit']) { continue }
            $property = @{}
            foreach ($key in $site['Property'].Keys) { $property[[string] $key] = $site['Property'][$key] }
            $parentId = $null
            if ($null -eq $site['ParentId']) { $property['name_source'] = $resolved['Source'] }
            else { $parentId = Get-DocsElementId -Kind 'cli-command' -Path $resolved['ParentPath'] -Declaration $resolved['ParentDeclaration'] }
            $candidates.Add((ConvertTo-DocsCliElement -Site $site -Declaration $resolved['Declaration'] -Path $file['Path'] -SourceText $file['Text'] -ParentId $parentId -Property $property))
        }
    }
    $elements = Select-DocsUniqueElement -Candidate $candidates.ToArray() -Aggregate $aggregate
    return @{ Elements = [object[]]@($elements); Diagnostics = [object[]]@($aggregate.Diagnostics) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerPythonCli, Resolve-DocsCliRootName, ConvertTo-DocsCliElement
