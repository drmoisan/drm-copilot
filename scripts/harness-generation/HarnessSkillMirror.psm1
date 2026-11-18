Set-StrictMode -Version Latest

# Skill mirror surface (issue #1028). For each parity-matrix entry of kind skill, ecosystem claude, disposition
# generated and owner_child 3 whose generated_from lies under .agents/skills/, renders every file of the source
# folder .agents/skills/<name>/ (except the Codex metadata agents/openai.yaml and the judging contract
# references/standard.md) to .claude/skills/<name>/ and to its bundle copy. The superset frontmatter is copied as
# written. Per-target body differences are ordered exact-text substitutions read from
# scripts/harness-generation/sources/skills/<name>.substitutions.json; each find must occur exactly once in the
# text it applies to. Skills without a selected entry are neither listed, written nor deleted.

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1')

function Get-HarnessSkillMirrorExcludedFile {
    <#
    .SYNOPSIS
        Returns the skill-relative paths that are never mirrored to the Claude copy.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    return [string[]]@('agents/openai.yaml', 'references/standard.md')
}

function Get-HarnessSkillSubstitutionPath {
    <#
    .SYNOPSIS
        Returns the repository-relative path of a skill's Claude substitution source.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string] $Name)
    return "scripts/harness-generation/sources/skills/$Name.substitutions.json"
}

function Read-HarnessSkillSubstitution {
    <#
    .SYNOPSIS
        Reads and validates a skill's substitution source; returns an empty list when the file does not exist.
    .DESCRIPTION
        The source is an object with a 'substitutions' array; each item has 'file' (skill-relative path),
        'find' (non-empty) and 'replace'. A malformed source throws naming its path.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context, [Parameter(Mandatory = $true)][string] $Name)
    $path = Get-HarnessSkillSubstitutionPath -Name $Name
    $text = & $Context.ReadFile $path
    if ($null -eq $text) { return @() }
    try { $source = $text | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Malformed source '$path': not valid JSON." }
    if ($null -eq $source -or $null -eq $source.PSObject.Properties['substitutions']) { throw "Malformed source '${path}': missing 'substitutions'." }
    $items = @($source.substitutions)
    $index = 0
    foreach ($item in $items) {
        $index++
        foreach ($field in @('file', 'find', 'replace')) {
            if ($null -eq $item -or $null -eq $item.PSObject.Properties[$field] -or $item.$field -isnot [string]) { throw "Malformed source '${path}': substitution $index has no string '$field'." }
        }
        if ($item.find.Length -eq 0) { throw "Malformed source '${path}': substitution $index has an empty 'find'." }
    }
    return $items
}

function Get-HarnessOccurrenceCount {
    <#
    .SYNOPSIS
        Counts the non-overlapping ordinal occurrences of a value in a text.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text, [Parameter(Mandatory = $true)][string] $Value)
    $count = 0
    $position = $Text.IndexOf($Value, [System.StringComparison]::Ordinal)
    while ($position -ge 0) {
        $count++
        $position = $Text.IndexOf($Value, $position + $Value.Length, [System.StringComparison]::Ordinal)
    }
    return $count
}

function Invoke-HarnessSkillSubstitution {
    <#
    .SYNOPSIS
        Applies, in order, the substitutions that target one skill file; each find must occur exactly once.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Substitution,
        [Parameter(Mandatory = $true)][string] $File,
        [Parameter(Mandatory = $true)][string] $SourcePath
    )
    $result = $Text
    $index = 0
    foreach ($item in $Substitution) {
        $index++
        if ([string]$item.file -cne $File) { continue }
        $find = ConvertTo-HarnessGeneratedText -Text ([string]$item.find)
        $count = Get-HarnessOccurrenceCount -Text $result -Value $find
        if ($count -ne 1) { throw "Malformed source '${SourcePath}': substitution $index find occurs $count time(s) in '$File'; it must occur exactly once." }
        $position = $result.IndexOf($find, [System.StringComparison]::Ordinal)
        $result = $result.Substring(0, $position) + (ConvertTo-HarnessGeneratedText -Text ([string]$item.replace)) + $result.Substring($position + $find.Length)
    }
    return $result
}

function Get-HarnessSkillMirrorSelection {
    <#
    .SYNOPSIS
        Returns the selected skill entries with their source folder name (from generated_from, never from the id).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] $Matrix)
    $selected = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @(Get-HarnessMatrixSelection -Matrix $Matrix -Kind 'skill' -Ecosystem 'claude' -Disposition 'generated' -OwnerChild 3)) {
        $from = if ($null -ne $entry.PSObject.Properties['generated_from']) { [string]$entry.generated_from } else { '' }
        if ($from -notmatch '^\.agents/skills/([^/]+)/') { continue }
        $selected.Add([pscustomobject]@{ Entry = $entry; Name = $Matches[1] })
    }
    return $selected.ToArray()
}

function Get-HarnessSkillMirrorFileMap {
    <#
    .SYNOPSIS
        Returns the skill mirror surface result: the Claude copy and bundle copy of every selected skill file.
    .DESCRIPTION
        Every selected skill renders first; a missing source folder, a malformed substitution source, a find that does
        not occur exactly once, or a substitution naming a file the source does not have throws before any write.
        ManagedFolders lists the two generated folders of each selected skill only, so an extra file there is EXTRA.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $matrix = Import-HarnessGenerationMatrix -Context $Context
    $excludedFiles = Get-HarnessSkillMirrorExcludedFile
    $files = [ordered]@{}
    $managed = [System.Collections.Generic.List[string]]::new()
    foreach ($selection in @(Get-HarnessSkillMirrorSelection -Matrix $matrix)) {
        $name = $selection.Name
        $sourceFolder = ".agents/skills/$name"
        $relativePaths = [string[]]@(& $Context.ListFiles $sourceFolder | ForEach-Object { ([string]$_).Substring($sourceFolder.Length + 1) } | Where-Object { $excludedFiles -cnotcontains $_ })
        [System.Array]::Sort($relativePaths, [System.StringComparer]::Ordinal)
        if ($relativePaths.Count -eq 0) { throw "Malformed source '$sourceFolder': the selected skill has no source files." }
        $substitutionPath = Get-HarnessSkillSubstitutionPath -Name $name
        $substitutions = @(Read-HarnessSkillSubstitution -Context $Context -Name $name)
        foreach ($item in $substitutions) {
            if ($relativePaths -cnotcontains [string]$item.file) { throw "Malformed source '${substitutionPath}': substitution file '$($item.file)' is not a file of '$sourceFolder'." }
        }
        $targetFolder = ".claude/skills/$name"
        $bundleFolder = Get-HarnessBundlePath -Path $targetFolder
        foreach ($relative in $relativePaths) {
            $text = ConvertTo-HarnessGeneratedText -Text ([string](& $Context.ReadFile "$sourceFolder/$relative"))
            $text = Invoke-HarnessSkillSubstitution -Text $text -Substitution $substitutions -File $relative -SourcePath $substitutionPath
            $files["$targetFolder/$relative"] = $text
            $files["$bundleFolder/$relative"] = $text
        }
        $managed.Add($targetFolder)
        $managed.Add($bundleFolder)
    }
    return [pscustomobject]@{ Files = $files; ManagedFolders = $managed.ToArray(); Findings = [object[]]@() }
}

Export-ModuleMember -Function @(
    'Get-HarnessSkillMirrorExcludedFile', 'Get-HarnessSkillSubstitutionPath', 'Read-HarnessSkillSubstitution',
    'Get-HarnessOccurrenceCount', 'Invoke-HarnessSkillSubstitution', 'Get-HarnessSkillMirrorSelection',
    'Get-HarnessSkillMirrorFileMap'
)
