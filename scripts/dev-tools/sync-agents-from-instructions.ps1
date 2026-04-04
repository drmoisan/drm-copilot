[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path "$PSScriptRoot/../..")
)

function Convert-ToDisplayPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return ($Path -replace '\\', '/')
}

function Convert-ToNormalizedRelativePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootParam,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalizedRoot = (Convert-ToDisplayPath -Path $RepoRootParam).TrimEnd('/')
    $normalizedPath = Convert-ToDisplayPath -Path $Path

    if (-not $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Discovered instruction file is outside the repo root: $normalizedPath"
    }

    return $normalizedPath.Substring($normalizedRoot.Length).TrimStart('/')
}

function Get-InstructionFileData {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$RepoRootParam
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Instructions file not found: $Path"
    }

    $rawContent = Get-Content -Raw -LiteralPath $Path
    if ([string]::IsNullOrEmpty($rawContent)) {
        return [pscustomobject]@{
            Path            = $Path
            RelativePath    = Convert-ToNormalizedRelativePath -RepoRootParam $RepoRootParam -Path $Path
            Body            = ""
            FrontMatterName = $null
            FirstHeading    = $null
        }
    }

    $frontMatterName = $null
    $body = $rawContent
    $frontMatterPattern = '^\s*---\s*(?<frontmatter>[\s\S]*?)---\s*'

    if ($rawContent -match $frontMatterPattern) {
        $frontMatter = $Matches['frontmatter']
        if ($frontMatter -match '(?im)^\s*name:\s*["'']?(?<name>[^"''\r\n]+)["'']?\s*$') {
            $frontMatterName = $Matches['name'].Trim()
        }

        $body = $rawContent -replace $frontMatterPattern, ''
    }

    $trimmedBody = if ([string]::IsNullOrEmpty($body)) { "" } else { $body.Trim() }
    $firstHeading = $null

    if ($trimmedBody -match '(?m)^\s{0,3}#+\s+(?<heading>.+?)\s*$') {
        $firstHeading = $Matches['heading'].Trim()
    }

    return [pscustomobject]@{
        Path            = $Path
        RelativePath    = Convert-ToNormalizedRelativePath -RepoRootParam $RepoRootParam -Path $Path
        Body            = $trimmedBody
        FrontMatterName = $frontMatterName
        FirstHeading    = $firstHeading
    }
}

function Get-InstructionsBody {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Instructions file not found: $Path"
    }

    $content = Get-Content -Raw -LiteralPath $Path
    if ([string]::IsNullOrEmpty($content)) {
        return ""
    }

    if ($content -match '^\s*---\s*[\s\S]*?---\s*') {
        $content = $content -replace '^\s*---\s*[\s\S]*?---\s*', ''
    }

    if ([string]::IsNullOrEmpty($content)) {
        return ""
    }

    return $content.Trim()
}

function Get-SectionKey {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $fileName = [System.IO.Path]::GetFileName($RelativePath)
    return ($fileName -replace '\.instructions\.md$', '')
}

function Get-SectionTitle {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$InstructionFile
    )

    if (-not [string]::IsNullOrWhiteSpace($InstructionFile.FirstHeading)) {
        return $InstructionFile.FirstHeading
    }

    if (-not [string]::IsNullOrWhiteSpace($InstructionFile.FrontMatterName)) {
        return $InstructionFile.FrontMatterName
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileNameWithoutExtension($InstructionFile.RelativePath))
    $segments = $baseName -split '[-_]+'

    return (($segments | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
                $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1)
            }) -join ' ')
}

function Get-DiscoveredInstructionFile {
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootParam
    )

    $githubRoot = Join-Path $RepoRootParam '.github'
    $copilotPath = Join-Path $RepoRootParam '.github/copilot-instructions.md'

    if (-not (Test-Path -LiteralPath $copilotPath)) {
        throw "Required AGENTS preamble file not found: $(Convert-ToDisplayPath -Path $copilotPath)"
    }

    # Discover the actual instruction sources shipped in the workspace so generated output stays aligned.
    $candidateFiles = @(Get-ChildItem -LiteralPath $githubRoot -Filter '*.instructions.md' -Recurse -File)
    if ($candidateFiles.Count -eq 0) {
        throw "No supported instruction files were discovered under $(Convert-ToDisplayPath -Path $githubRoot)"
    }

    $instructionFilesByRelativePath = @{}
    $relativePaths = [System.Collections.Generic.List[string]]::new()

    # Normalize discovered paths relative to the repo root before sorting so output is deterministic across platforms.
    foreach ($candidateFile in $candidateFiles) {
        $instructionFile = Get-InstructionFileData -Path $candidateFile.FullName -RepoRootParam $RepoRootParam
        $instructionFilesByRelativePath[$instructionFile.RelativePath] = $instructionFile
        $relativePaths.Add($instructionFile.RelativePath)
    }

    $sortedRelativePaths = $relativePaths.ToArray()
    [System.Array]::Sort($sortedRelativePaths, [System.StringComparer]::Ordinal)

    return @(
        foreach ($relativePath in $sortedRelativePaths) {
            $instructionFilesByRelativePath[$relativePath]
        }
    )
}

function Get-AgentContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootParam
    )

    $copilotPath = Join-Path $RepoRootParam ".github/copilot-instructions.md"
    $agentsTarget = Join-Path $RepoRootParam "AGENTS.md"
    $instructionFiles = Get-DiscoveredInstructionFile -RepoRootParam $RepoRootParam

    $copilotBody = Get-InstructionsBody -Path $copilotPath

    $copilotSection = @"
## Repository Instructions (GitHub Copilot Canonical)

<!-- BEGIN: copilot-instructions -->
$copilotBody

<!-- END: copilot-instructions -->

"@

    $sectionBlocks = foreach ($instructionFile in $instructionFiles) {
        $sectionKey = Get-SectionKey -RelativePath $instructionFile.RelativePath
        $sectionTitle = Get-SectionTitle -InstructionFile $instructionFile

        @"
## $sectionTitle

<!-- BEGIN: $sectionKey -->
$($instructionFile.Body)

<!-- END: $sectionKey -->

"@
    }

    $headerSourceLines = @('.github/copilot-instructions.md') + $instructionFiles.RelativePath
    $generatedSources = @(
        foreach ($sourcePath in $headerSourceLines) {
            "> - $sourcePath"
        }
    ) -join "`n"

    $header = @"
# AGENTS.md

> NOTE: This file is **generated** from:
>
$generatedSources
>
> Do not edit this file manually.
> To update policies, edit the source *.instructions.md files and
> `.github/copilot-instructions.md`, then run:
>
>   pwsh -File scripts/dev-tools/sync-agents-from-instructions.ps1

## Repository Setup (High-Level)

- For coding and testing policies, always follow the sections below in the order:
  Copilot instructions -> general policies -> language-specific policies -> CI policies.
- Use the language- and domain-specific sections for Python, PowerShell, and CI behavior.
"@

    $agentsContent = $header + "`n`n" + $copilotSection + "`n" + ($sectionBlocks -join "`n")

    return [pscustomobject]@{ Path = $agentsTarget; Content = $agentsContent }
}

function Invoke-SyncAgentInstruction {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootParam
    )

    $result = Get-AgentContent -RepoRootParam $RepoRootParam
    if (-not $PSCmdlet.ShouldProcess($result.Path, 'Update AGENTS.md')) {
        return
    }

    Set-Content -LiteralPath $result.Path -Value $result.Content -NoNewline
    Write-Output "Updated $($result.Path) from .github/copilot-instructions.md and .github/instructions/*.instructions.md"
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($env:POSHQC_SKIP_SCRIPT_EXECUTION) {
    return
}

Invoke-SyncAgentInstruction -RepoRootParam $RepoRoot







