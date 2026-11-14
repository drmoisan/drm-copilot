<#
.SYNOPSIS
    Shared readers and named sets for the documentation-authoring structural suites (issue #1037).

.DESCRIPTION
    Dot-sourced by tests/scripts/claude-runtime/docs-authoring-roles.*.Tests.ps1. Every function
    reads committed repository files or parses text passed to it; nothing writes a file. The named
    sets restate the role, skill, template and tool contract of the feature so the suites can
    compare the committed files with it.
#>

function Get-DocsAuthoringRepoRoot {
    # Returns the repository root as a forward-slash path.
    return ((Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path -replace '\\', '/')
}

function Read-DocsAuthoringText {
    # Returns the raw text of one repository-relative file.
    param([Parameter(Mandatory)] [string] $RelativePath)
    return [System.IO.File]::ReadAllText((Join-Path (Get-DocsAuthoringRepoRoot) $RelativePath))
}

function Get-DocsAuthoringNamedSet {
    <#
    .SYNOPSIS
        Returns the roles, skills, templates, docs MCP tools, the role table, the skill table and the template mode map.
    #>
    $roleTable = [ordered]@{
        'docs-architect'         = @{ Native = @('Read', 'Grep', 'Glob'); Mcp = @('run_docs_inventory', 'run_docs_coverage', 'run_docs_check'); Skills = @('docs-inventory-surface', 'docs-plan-ia') }
        'docs-author'            = @{ Native = @('Read', 'Grep', 'Glob', 'Write', 'Edit'); Mcp = @('generate_docs_reference', 'run_docs_check'); Skills = @('docs-author-page') }
        'docs-reconciler'        = @{ Native = @('Read', 'Grep', 'Glob'); Mcp = @('run_docs_coverage', 'update_docs_ledger', 'validate_docs_artifacts'); Skills = @('docs-reconcile-behavior') }
        'docs-coverage-reviewer' = @{ Native = @('Read', 'Grep', 'Glob'); Mcp = @('run_docs_coverage', 'validate_docs_artifacts', 'run_docs_check'); Skills = @('docs-review-coverage', 'docs-validate') }
    }
    $skillTable = [ordered]@{
        'documentation-workflow'  = @{ Agent = 'root'; Mcp = @() }
        'docs-init'               = @{ Agent = 'root'; Mcp = @() }
        'docs-inventory-surface'  = @{ Agent = 'docs-architect'; Mcp = @('run_docs_inventory') }
        'docs-plan-ia'            = @{ Agent = 'docs-architect'; Mcp = @('run_docs_inventory', 'run_docs_coverage', 'run_docs_check') }
        'docs-author-page'        = @{ Agent = 'docs-author'; Mcp = @('generate_docs_reference', 'run_docs_check') }
        'docs-reconcile-behavior' = @{ Agent = 'docs-reconciler'; Mcp = @('run_docs_coverage', 'update_docs_ledger', 'validate_docs_artifacts') }
        'docs-review-coverage'    = @{ Agent = 'docs-coverage-reviewer'; Mcp = @('run_docs_coverage', 'validate_docs_artifacts', 'run_docs_check') }
        'docs-validate'           = @{ Agent = 'docs-coverage-reviewer'; Mcp = @('validate_docs_artifacts', 'run_docs_check') }
    }
    $templateModes = [ordered]@{
        'tutorial' = 'tutorial'; 'how-to' = 'how-to'; 'explanation' = 'explanation'; 'architecture-overview' = 'explanation'
        'cli-reference' = 'reference'; 'http-reference' = 'reference'; 'config-reference' = 'reference'; 'api-reference' = 'reference'
    }
    return @{
        Roles         = @($roleTable.Keys)
        Skills        = @($skillTable.Keys)
        Templates     = @($templateModes.Keys)
        McpTools      = @('run_docs_check', 'run_docs_inventory', 'run_docs_coverage', 'update_docs_ledger', 'generate_docs_reference', 'validate_docs_artifacts')
        RoleTable     = $roleTable
        SkillTable    = $skillTable
        TemplateModes = $templateModes
    }
}

function Get-DocsAuthoringAgentPath {
    # Returns the six agent locations of one role, keyed by host and bundle.
    param([Parameter(Mandatory)] [string] $Role)
    $bundle = 'extensions/drm-copilot/resources'
    return [ordered]@{
        Copilot       = ".github/agents/$Role.agent.md"
        CopilotBundle = "$bundle/customizations/.github/agents/$Role.agent.md"
        Claude        = ".claude/agents/$Role.md"
        ClaudeBundle  = "$bundle/claude-customizations/.claude/agents/$Role.md"
        Codex         = ".codex/agents/$Role.toml"
        CodexBundle   = "$bundle/codex-and-agents-customizations/.codex/agents/$Role.toml"
    }
}

function Get-DocsAuthoringSkillRoot {
    # Returns the six skill roots, keyed by host and bundle.
    $bundle = 'extensions/drm-copilot/resources'
    return [ordered]@{
        Claude        = '.claude/skills'
        ClaudeBundle  = "$bundle/claude-customizations/.claude/skills"
        Copilot       = '.github/skills'
        CopilotBundle = "$bundle/customizations/.github/skills"
        Codex         = '.agents/skills'
        CodexBundle   = "$bundle/codex-and-agents-customizations/.agents/skills"
    }
}

function Get-DocsFrontMatterList {
    <#
    .SYNOPSIS
        Returns the items of one YAML list key in the leading front matter of a text, quotes removed.
    #>
    param([Parameter(Mandatory)] [string] $Text, [Parameter(Mandatory)] [string] $Key)
    $lines = @(($Text -replace "`r`n", "`n") -split "`n")
    $items = [System.Collections.Generic.List[string]]::new()
    $inFrontMatter = $false
    $inKey = $false
    foreach ($line in $lines) {
        if ($line -eq '---') { if ($inFrontMatter) { break }; $inFrontMatter = $true; continue }
        if (-not $inFrontMatter) { continue }
        if ($line -match '^[A-Za-z_-]+:') { $inKey = $line -eq "${Key}:"; continue }
        if ($inKey -and $line -match '^\s+-\s+(?<item>.+)$') { $items.Add($Matches['item'].Trim().Trim('"')) }
    }
    return [string[]]$items.ToArray()
}

function Get-DocsCodexEmbeddedText {
    # Returns the developer_instructions literal string of a Codex role file.
    param([Parameter(Mandatory)] [string] $Text)
    $match = [regex]::Match($Text, "(?s)developer_instructions = '''\n(?<body>.*?)'''")
    if (-not $match.Success) { return '' }
    return $match.Groups['body'].Value
}

function Get-DocsCommandRowOption {
    <#
    .SYNOPSIS
        Parses the $script:DocsCommandRow lines of Invoke-DocsCommand.ps1 into a map of row name to option names.
    #>
    $text = Read-DocsAuthoringText -RelativePath '.claude/lib/docs/Invoke-DocsCommand.ps1'
    $rows = @{}
    foreach ($match in [regex]::Matches($text, "\[pscustomobject\]@\{ Name = '(?<name>[a-z-]+)';.*?Option = @\{(?<options>[^}]*)\}")) {
        $options = @([regex]::Matches($match.Groups['options'].Value, '(?<key>[A-Za-z]+) = ') | ForEach-Object { $_.Groups['key'].Value })
        $rows[$match.Groups['name'].Value] = $options
    }
    return $rows
}

function Get-DocsMcpToolNameDefinition {
    # Returns every quoted docs tool name defined in repo-automation-tool-names.ts.
    $text = Read-DocsAuthoringText -RelativePath 'extensions/drm-copilot/src/repo-automation-tool-names.ts'
    return @([regex]::Matches($text, '"(?<name>[a-z_]+_docs_[a-z_]+)"') | ForEach-Object { $_.Groups['name'].Value } | Sort-Object -Unique)
}

function Get-DocsPackManifestPath {
    # Returns the paths array of one pack manifest under extensions/drm-copilot/resources.
    param([Parameter(Mandatory)] [string] $RelativeManifest)
    return @((Read-DocsAuthoringText -RelativePath "extensions/drm-copilot/resources/$RelativeManifest" | ConvertFrom-Json).paths)
}
