Set-StrictMode -Version Latest

# Instructions surface (issue #1028), check-only. AGENTS.md is the hand-authored source of repository standing
# guidance; CLAUDE.md imports it and carries Claude-only text. This module reports, without writing anything:
#   CONVERTER-HEADING  AGENTS.md carries the Codex native converter heading '# Converted standing guidance'
#   GENERATED-NOTE     AGENTS.md carries the generated-file note of scripts/dev-tools/sync-agents-from-instructions.ps1
#   EMBEDDED-RULE      an H2 body of AGENTS.md equals (whitespace-normalized) an H2 body of a .claude/rules file
#   MISSING-SKILL      AGENTS.md cites a .agents/skills/<name>/SKILL.md that does not exist
#   CLAUDE-IMPORT      the first line of CLAUDE.md after its frontmatter is not '@AGENTS.md'
#   DUPLICATE-SECTION  CLAUDE.md and AGENTS.md share a whitespace-normalized H2 body
#   BUNDLE-DRIFT       the bundle AGENTS.md differs from AGENTS.md
#   COVERAGE-THRESHOLD a line of AGENTS.md holds the word 'coverage' and a percentage (OQ-7)
#   MISSING            AGENTS.md or CLAUDE.md does not exist

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1')

function Get-HarnessInstructionPathSet {
    <#
    .SYNOPSIS
        Returns the paths the instructions check reads.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()
    return [pscustomobject]@{
        Agents       = 'AGENTS.md'
        Claude       = 'CLAUDE.md'
        BundleAgents = 'extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md'
        RulesFolder  = '.claude/rules'
    }
}

function ConvertTo-HarnessNormalizedBody {
    <#
    .SYNOPSIS
        Collapses every whitespace run to one space and trims the ends.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text)
    return ([regex]::Replace($Text, '\s+', ' ')).Trim()
}

function Get-HarnessH2Section {
    <#
    .SYNOPSIS
        Returns each H2 section of a Markdown text: its heading and its body up to the next H1 or H2 heading.
    .DESCRIPTION
        Lines inside fenced code blocks are never read as headings. Body holds the whitespace-normalized text.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text)
    $sections = [System.Collections.Generic.List[object]]::new()
    $heading = $null
    $body = [System.Collections.Generic.List[string]]::new()
    $inFence = $false
    foreach ($line in ($Text.Replace("`r`n", "`n") -split "`n")) {
        if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence }
        $isHeading = (-not $inFence) -and ($line -match '^#{1,2} ')
        if ($isHeading) {
            if ($null -ne $heading) { $sections.Add([pscustomobject]@{ Heading = $heading; Body = (ConvertTo-HarnessNormalizedBody -Text ($body -join "`n")) }) }
            $heading = if ($line.StartsWith('## ')) { $line } else { $null }
            $body.Clear()
            continue
        }
        if ($null -ne $heading) { $body.Add($line) }
    }
    if ($null -ne $heading) { $sections.Add([pscustomobject]@{ Heading = $heading; Body = (ConvertTo-HarnessNormalizedBody -Text ($body -join "`n")) }) }
    return $sections.ToArray()
}

function Get-HarnessLineAfterFrontmatter {
    <#
    .SYNOPSIS
        Returns the line directly after a leading YAML frontmatter block, or the first line when there is none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text)
    $lines = @($Text.Replace("`r`n", "`n") -split "`n")
    if ($lines.Count -eq 0 -or $lines[0] -cne '---') { return $lines[0] }
    for ($index = 1; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -ceq '---') { return $(if ($index + 1 -lt $lines.Count) { $lines[$index + 1] } else { '' }) }
    }
    return ''
}

function Get-HarnessAgentsTextFinding {
    <#
    .SYNOPSIS
        Returns the line-level findings of AGENTS.md: converter heading, generated note, missing skill citation, coverage threshold.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context, [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text, [Parameter(Mandatory = $true)][string] $Path)
    $findings = [System.Collections.Generic.List[object]]::new()
    $lines = @($Text.Replace("`r`n", "`n") -split "`n")
    if ($lines -ccontains '# Converted standing guidance') { $findings.Add((New-HarnessFinding -Kind 'CONVERTER-HEADING' -Path $Path -Detail 'carries the Codex native converter heading')) }
    if (@($lines | Where-Object { $_.StartsWith('> NOTE: This file is **generated** from:') }).Count -gt 0) {
        $findings.Add((New-HarnessFinding -Kind 'GENERATED-NOTE' -Path $Path -Detail 'carries the sync-agents-from-instructions generated-file note'))
    }
    $cited = @([regex]::Matches($Text, '\.agents/skills/[A-Za-z0-9._-]+/SKILL\.md') | ForEach-Object { $_.Value } | Select-Object -Unique)
    foreach ($skillPath in $cited) {
        if ($null -eq (& $Context.ReadFile $skillPath)) { $findings.Add((New-HarnessFinding -Kind 'MISSING-SKILL' -Path $Path -Detail "cites $skillPath, which does not exist")) }
    }
    foreach ($line in $lines) {
        if ($line -imatch 'coverage' -and $line -match '\d+(\.\d+)?\s*%') {
            $findings.Add((New-HarnessFinding -Kind 'COVERAGE-THRESHOLD' -Path $Path -Detail "states a coverage percentage: $($line.Trim())"))
        }
    }
    return $findings.ToArray()
}

function Get-HarnessInstructionFindings {
    <#
    .SYNOPSIS
        Returns the instructions surface result: no generated file, and one finding per violated rule.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The name is fixed by the issue #1028 plan and returns a set of findings.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $paths = Get-HarnessInstructionPathSet
    $findings = [System.Collections.Generic.List[object]]::new()
    $agents = & $Context.ReadFile $paths.Agents
    $claude = & $Context.ReadFile $paths.Claude
    if ($null -eq $agents) { $findings.Add((New-HarnessFinding -Kind 'MISSING' -Path $paths.Agents)) }
    if ($null -eq $claude) { $findings.Add((New-HarnessFinding -Kind 'MISSING' -Path $paths.Claude)) }
    if ($null -ne $agents) {
        foreach ($finding in @(Get-HarnessAgentsTextFinding -Context $Context -Text ([string]$agents) -Path $paths.Agents)) { $findings.Add($finding) }
        $agentSections = @(Get-HarnessH2Section -Text ([string]$agents) | Where-Object { $_.Body -ne '' })
        foreach ($rulePath in @(& $Context.ListFiles $paths.RulesFolder | Where-Object { $_ -like '*.md' })) {
            $ruleBodies = @(Get-HarnessH2Section -Text ([string](& $Context.ReadFile $rulePath)) | ForEach-Object { $_.Body })
            foreach ($section in $agentSections) {
                if ($ruleBodies -ccontains $section.Body) { $findings.Add((New-HarnessFinding -Kind 'EMBEDDED-RULE' -Path $paths.Agents -Detail "$($section.Heading) repeats a section of $rulePath")) }
            }
        }
        $bundle = & $Context.ReadFile $paths.BundleAgents
        if ($null -eq $bundle -or -not [string]::Equals([string]$bundle, [string]$agents, [System.StringComparison]::Ordinal)) { $findings.Add((New-HarnessFinding -Kind 'BUNDLE-DRIFT' -Path $paths.BundleAgents -Detail 'differs from AGENTS.md')) }
    }
    if ($null -ne $claude) {
        if ((Get-HarnessLineAfterFrontmatter -Text ([string]$claude)) -cne '@AGENTS.md') { $findings.Add((New-HarnessFinding -Kind 'CLAUDE-IMPORT' -Path $paths.Claude -Detail 'the first line after the frontmatter is not @AGENTS.md')) }
        if ($null -ne $agents) {
            $agentBodies = @(Get-HarnessH2Section -Text ([string]$agents) | Where-Object { $_.Body -ne '' } | ForEach-Object { $_.Body })
            foreach ($section in @(Get-HarnessH2Section -Text ([string]$claude) | Where-Object { $_.Body -ne '' })) {
                if ($agentBodies -ccontains $section.Body) { $findings.Add((New-HarnessFinding -Kind 'DUPLICATE-SECTION' -Path $paths.Claude -Detail "$($section.Heading) repeats a section of AGENTS.md")) }
            }
        }
    }
    return [pscustomobject]@{ Files = [ordered]@{}; ManagedFolders = [string[]]@(); Findings = $findings.ToArray() }
}

Export-ModuleMember -Function @(
    'Get-HarnessInstructionPathSet', 'ConvertTo-HarnessNormalizedBody', 'Get-HarnessH2Section', 'Get-HarnessLineAfterFrontmatter',
    'Get-HarnessAgentsTextFinding', 'Get-HarnessInstructionFindings'
)
