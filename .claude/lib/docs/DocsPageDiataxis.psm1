<#
.SYNOPSIS
    The Diataxis mode audit of the documentation page checker: path-or-glob matching, directory
    modes, mode signals and the five DOCS_PAGE_MODE_* rule findings.

.DESCRIPTION
    Test-DocsPagePathMatch is the shared path-or-glob rule: an exact match (-ceq), an ordinal
    prefix match followed by /, or, when the pattern contains *, ? or [, a case-sensitive
    WildcardPattern match with WildcardOptions.None in which * crosses /. PowerShell wildcards
    have no [!x] negation and use a backtick escape. Get-DocsPageDirectoryMode returns the first
    covering diataxis_policy.directory_modes entry in profile order.

    Get-DocsPageModeSignal reads the line model of DocsPageMarkdown.psm1: an ordered step is a
    text line whose masked text matches ^ {0,3}[0-9]{1,9}[.)] +\S; an instructional heading
    starts with "how to " or matches ^step\s+[0-9]+\b, both case-insensitively (English
    constants); a generated block is a line holding a generated-block start marker. Fenced code
    and HTML comments therefore produce no signal. Prose judgment stays with the reviewer.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop

$script:DocsPageOrderedStepPattern = '^ {0,3}[0-9]{1,9}[.)] +\S'
$script:DocsPageStepHeadingPattern = '^step\s+[0-9]+\b'
$script:DocsPageStepModes = @('tutorial', 'how-to')
$script:DocsPageNoInstructionModes = @('reference', 'explanation')
$script:DocsPageNoGeneratedModes = @('tutorial', 'how-to', 'explanation')
$script:DocsPageModeNextAction = @{
    'DOCS_PAGE_MODE_NOT_IN_POLICY'       = 'Use a diataxis_mode listed in diataxis_policy.modes, or add the mode to the policy.'
    'DOCS_PAGE_MODE_DIRECTORY_MISMATCH'  = 'Set diataxis_mode to the mode required for the page directory, or move the page.'
    'DOCS_PAGE_MODE_STEPS_MISSING'       = 'Add an ordered step list, or change diataxis_mode.'
    'DOCS_PAGE_MODE_INSTRUCTION_HEADING' = 'Rename the heading, or move the instructions to a tutorial or how-to page.'
    'DOCS_PAGE_MODE_GENERATED_BLOCK'     = 'Move the generated reference block to a reference page, or set diataxis_mode to reference.'
}

function Test-DocsPagePathMatch {
    <#
    .SYNOPSIS
        Returns $true when Path matches PathOrGlob: exact, prefix plus /, or a case-sensitive wildcard.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $PathOrGlob
    )

    if ($Path -ceq $PathOrGlob) { return $true }
    if ($Path.StartsWith("$PathOrGlob/", [System.StringComparison]::Ordinal)) { return $true }
    if ($PathOrGlob.IndexOfAny([char[]] @('*', '?', '[')) -lt 0) { return $false }
    return [System.Management.Automation.WildcardPattern]::new($PathOrGlob, [System.Management.Automation.WildcardOptions]::None).IsMatch($Path)
}

function Get-DocsPageDirectoryMode {
    <#
    .SYNOPSIS
        Returns @{ Mode; PathOrGlob; Index } of the first directory-mode entry covering the page, or $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $DirectoryMode
    )

    for ($index = 0; $index -lt $DirectoryMode.Count; $index++) {
        $entry = $DirectoryMode[$index]
        if (Test-DocsPagePathMatch -Path $PagePath -PathOrGlob ([string] $entry['path_or_glob'])) {
            return @{ Mode = [string] $entry['mode']; PathOrGlob = [string] $entry['path_or_glob']; Index = $index }
        }
    }
    return $null
}

function Get-DocsPageModeSignal {
    <#
    .SYNOPSIS
        Returns @{ OrderedStepLine; InstructionHeadingLine; InstructionHeadingText; GeneratedBlockLine }.
    .DESCRIPTION
        Each line value is the page line number of the first occurrence, or 0 when absent;
        InstructionHeadingText is $null when no instructional heading exists.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $LineModel)

    $signal = @{ OrderedStepLine = 0; InstructionHeadingLine = 0; InstructionHeadingText = $null; GeneratedBlockLine = 0 }
    foreach ($record in $LineModel) {
        $kind = [string] $record.Kind
        if ($signal.OrderedStepLine -eq 0 -and $kind -ceq 'text' -and [string] $record.Masked -match $script:DocsPageOrderedStepPattern) { $signal.OrderedStepLine = [int] $record.Number }
        if ($signal.InstructionHeadingLine -eq 0 -and $kind -ceq 'heading') {
            $heading = [string] $record.HeadingText
            if ($heading.StartsWith('how to ', [System.StringComparison]::OrdinalIgnoreCase) -or $heading -match $script:DocsPageStepHeadingPattern) {
                $signal.InstructionHeadingLine = [int] $record.Number
                $signal.InstructionHeadingText = $heading
            }
        }
        if ($signal.GeneratedBlockLine -eq 0 -and [bool] $record.HasGeneratedStartMarker) { $signal.GeneratedBlockLine = [int] $record.Number }
    }
    return $signal
}

function New-DocsPageModeFinding {
    <#
    .SYNOPSIS
        Builds one Diataxis rule finding with the fixed next action of its code (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $script:DocsPageModeNextAction[$Code] -ArtifactPath $PagePath -Pointer $Pointer
}

function Get-DocsPageDiataxisFinding {
    <#
    .SYNOPSIS
        Returns the ordered Diataxis rule findings of one page whose diataxis_mode is valid.
    .DESCRIPTION
        DiataxisPolicy is the profile diataxis_policy object (modes, directory_modes). A page
        with no covering directory-mode entry yields no directory finding.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [string] $DeclaredMode,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $LineModel,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $DiataxisPolicy
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $modes = [string[]] @(if ($DiataxisPolicy.Contains('modes')) { $DiataxisPolicy['modes'] })
    if ($modes -cnotcontains $DeclaredMode) {
        $findings.Add((New-DocsPageModeFinding -Code 'DOCS_PAGE_MODE_NOT_IN_POLICY' -PagePath $PagePath -Pointer '/diataxis_mode' -Message "diataxis_mode '$DeclaredMode' is not listed in diataxis_policy.modes"))
    }
    $entries = [object[]] @(if ($DiataxisPolicy.Contains('directory_modes')) { $DiataxisPolicy['directory_modes'] })
    $directory = Get-DocsPageDirectoryMode -PagePath $PagePath -DirectoryMode $entries
    if ($null -ne $directory -and $directory.Mode -cne $DeclaredMode) {
        $findings.Add((New-DocsPageModeFinding -Code 'DOCS_PAGE_MODE_DIRECTORY_MISMATCH' -PagePath $PagePath -Pointer '/diataxis_mode' -Message "diataxis_mode '$DeclaredMode' differs from '$($directory.Mode)' required for '$($directory.PathOrGlob)'"))
    }
    $signal = Get-DocsPageModeSignal -LineModel $LineModel
    if ($script:DocsPageStepModes -ccontains $DeclaredMode -and $signal.OrderedStepLine -eq 0) {
        $findings.Add((New-DocsPageModeFinding -Code 'DOCS_PAGE_MODE_STEPS_MISSING' -PagePath $PagePath -Pointer '/diataxis_mode' -Message "diataxis_mode '$DeclaredMode' requires an ordered step list"))
    }
    if ($script:DocsPageNoInstructionModes -ccontains $DeclaredMode -and $signal.InstructionHeadingLine -gt 0) {
        $findings.Add((New-DocsPageModeFinding -Code 'DOCS_PAGE_MODE_INSTRUCTION_HEADING' -PagePath $PagePath -Pointer '' -Message "line $($signal.InstructionHeadingLine): heading '$($signal.InstructionHeadingText)' is instructional, which diataxis_mode '$DeclaredMode' does not allow"))
    }
    if ($script:DocsPageNoGeneratedModes -ccontains $DeclaredMode -and $signal.GeneratedBlockLine -gt 0) {
        $findings.Add((New-DocsPageModeFinding -Code 'DOCS_PAGE_MODE_GENERATED_BLOCK' -PagePath $PagePath -Pointer '' -Message "line $($signal.GeneratedBlockLine): generated reference block in a page whose diataxis_mode is '$DeclaredMode'"))
    }
    if ($findings.Count -eq 0) { return , [object[]] @() }
    return , [object[]] (Get-DocsOrderedFinding -Finding $findings.ToArray() -Limit 10000)
}

Export-ModuleMember -Function `
    Test-DocsPagePathMatch, `
    Get-DocsPageDirectoryMode, `
    Get-DocsPageModeSignal, `
    Get-DocsPageDiataxisFinding
