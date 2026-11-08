#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Wording contract for the subagent nesting-depth preflight and documentation (issue #1138).

.DESCRIPTION
    Reads the agent, skill, and execution-environment brief files in place, live and bundle
    copies, collapses whitespace so a reflowed line still matches, and asserts each required
    literal per file with a failure message that names the file and the literal. The last
    test compares each bundle copy with its live file byte for byte. No test writes a file.
#>

Describe 'Nesting-depth wording contract (issue #1138)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
        $script:BundlePrefix = 'extensions/drm-copilot/resources/claude-customizations/'
        $script:AgentFiles = @('orchestrator', 'epic-planner', 'epic-orchestrator', 'parallel-planner', 'parallel-orchestrator' | ForEach-Object { ".claude/agents/$_.md" })
        $script:CoordinatorAgentFiles = @('epic-planner', 'epic-orchestrator', 'parallel-planner', 'parallel-orchestrator' | ForEach-Object { ".claude/agents/$_.md" })
        $script:CoordinatorSkillFiles = @('epic-plan', 'epic-run', 'epic-orchestrate', 'parallel-plan', 'parallel-run', 'parallel-orchestrate' | ForEach-Object { ".claude/skills/$_/SKILL.md" })
        $script:OrchestrateSkillFile = '.claude/skills/orchestrate/SKILL.md'
        $script:HookFiles = @('.claude/hooks/epic-invocation-nesting-depth.ps1', '.claude/hooks/enforce-epic-invocation-origin.ps1')
        $script:BriefFiles = @(
            '.claude/skills/execution-environment/SKILL.md'
            '.agents/skills/execution-environment/SKILL.md'
            '.github/skills/execution-environment/SKILL.md'
            'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md'
            'extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md'
        )
        $script:SkillLiterals = @(
            'depth 1', 'depth 2', 'depth 3', '2.1.219', 'CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH', 'at least 3',
            'invoked from the main session', 'AGENT_TOOL_UNAVAILABLE', 'spawn_agent_unavailable',
            'Agent(orchestrator)', 'same delegation prompt', 'Preparation mode: true'
        )

        function Get-ContractCopyPath {
            # Returns the live path and its bundle mirror path for each repository-relative file.
            param([string[]] $RelativePath)
            foreach ($relative in $RelativePath) {
                $relative
                $script:BundlePrefix + $relative
            }
        }

        function Get-ContractText {
            # Reads one repository file in place.
            param([string] $RelativePath)
            $fullPath = Join-Path $script:RepoRoot $RelativePath
            return (Get-Content -LiteralPath $fullPath -Raw)
        }

        function Get-ContractSection {
            # Returns the lines after an exact level-two heading up to the next level-two heading, or $null.
            param([string] $Text, [string] $Heading)
            $lines = $Text -split "`r?`n"
            $start = [Array]::IndexOf($lines, $Heading)
            if ($start -lt 0) { return $null }
            $body = [System.Collections.Generic.List[string]]::new()
            for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                if ($lines[$index].StartsWith('## ', [System.StringComparison]::Ordinal)) { break }
                $body.Add($lines[$index])
            }
            return ($body -join "`n")
        }

        function Get-StartupPreflightText {
            # Returns the collapsed Startup Protocol text that precedes its first numbered step.
            param([string] $Text)
            $section = Get-ContractSection -Text $Text -Heading '## Startup Protocol'
            if ($null -eq $section) { return '' }
            $lead = [System.Collections.Generic.List[string]]::new()
            foreach ($line in ($section -split "`n")) {
                if ($line -match '^\s*\d+\.\s') { break }
                $lead.Add($line)
            }
            return (ConvertTo-CollapsedText -Text ($lead -join ' '))
        }

        function ConvertTo-CollapsedText {
            # Collapses every whitespace run to one space so a reflowed literal still matches.
            param([AllowNull()][string] $Text)
            return ([string]$Text -replace '\s+', ' ')
        }

        function Assert-ContractLiteral {
            # Asserts that each literal occurs in the collapsed text, naming the file and the literal on failure.
            param([string] $Text, [string[]] $Literal, [string] $File, [string] $Region)
            foreach ($item in $Literal) {
                $Text.Contains($item) | Should -BeTrue -Because "$File ($Region) must contain the literal '$item'"
            }
        }
    }

    It 'agent files carry the Agent-tool preflight' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:AgentFiles)) {
            $preflight = Get-StartupPreflightText -Text (Get-ContractText -RelativePath $file)
            Assert-ContractLiteral -Text $preflight -Literal @('AGENT_TOOL_UNAVAILABLE:', 'spawn_agent_unavailable', 'no specialist work') -File $file -Region 'Startup Protocol preflight'
        }
    }

    It 'coordinators halt on child AGENT_TOOL_UNAVAILABLE' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:CoordinatorAgentFiles)) {
            $text = ConvertTo-CollapsedText -Text (Get-ContractText -RelativePath $file)
            Assert-ContractLiteral -Text $text -Literal @('halt with the same reason') -File $file -Region 'agent body'
        }
    }

    It 'coordinators halt on a NESTING_DEPTH_INSUFFICIENT deny' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:CoordinatorAgentFiles)) {
            $preflight = Get-StartupPreflightText -Text (Get-ContractText -RelativePath $file)
            Assert-ContractLiteral -Text $preflight -Literal @('NESTING_DEPTH_INSUFFICIENT:', 'halt with that reason') -File $file -Region 'Startup Protocol preflight'
        }
    }

    It 'preflight names both remedies' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:AgentFiles)) {
            $preflight = Get-StartupPreflightText -Text (Get-ContractText -RelativePath $file)
            Assert-ContractLiteral -Text $preflight -Literal @('CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH', 'main-session fallback') -File $file -Region 'Startup Protocol preflight'
        }
    }

    It 'preflight names the three causes' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:AgentFiles)) {
            $preflight = Get-StartupPreflightText -Text (Get-ContractText -RelativePath $file)
            Assert-ContractLiteral -Text $preflight -Literal @('below 3', 'inside a subagent', '2.1.219') -File $file -Region 'Startup Protocol preflight'
        }
    }

    It 'coordinator skills document Nesting Depth and fallback' {
        foreach ($file in (Get-ContractCopyPath -RelativePath $script:CoordinatorSkillFiles)) {
            $text = Get-ContractText -RelativePath $file
            @([regex]::Matches($text, '(?m)^## Nesting Depth\r?$')).Count | Should -Be 1 -Because "$file must carry exactly one '## Nesting Depth' heading"
            $section = ConvertTo-CollapsedText -Text (Get-ContractSection -Text $text -Heading '## Nesting Depth')
            Assert-ContractLiteral -Text $section -Literal $script:SkillLiterals -File $file -Region '## Nesting Depth'
        }
    }

    It 'orchestrate documents Nesting Depth' {
        foreach ($file in (Get-ContractCopyPath -RelativePath @($script:OrchestrateSkillFile))) {
            $text = Get-ContractText -RelativePath $file
            @([regex]::Matches($text, '(?m)^## Nesting Depth\r?$')).Count | Should -Be 1 -Because "$file must carry exactly one '## Nesting Depth' heading"
            $section = ConvertTo-CollapsedText -Text (Get-ContractSection -Text $text -Heading '## Nesting Depth')
            Assert-ContractLiteral -Text $section -Literal ($script:SkillLiterals + @('needs depth 1 only', 'at its own depth')) -File $file -Region '## Nesting Depth'
        }
    }

    It 'brief carries nesting-depth line' {
        foreach ($file in $script:BriefFiles) {
            $section = ConvertTo-CollapsedText -Text (Get-ContractSection -Text (Get-ContractText -RelativePath $file) -Heading '## Tool Routes by Agent')
            Assert-ContractLiteral -Text $section -Literal @('2.1.219', 'CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH', 'at least 3', 'AGENT_TOOL_UNAVAILABLE:', 'spawn_agent_unavailable') -File $file -Region '## Tool Routes by Agent'
        }
    }

    It 'bundle copy matches live file' {
        $mirrored = @($script:HookFiles + $script:AgentFiles + $script:CoordinatorSkillFiles + @($script:OrchestrateSkillFile))
        $mirrored.Count | Should -Be 14
        foreach ($file in $mirrored) {
            $liveHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $file) -Algorithm SHA256).Hash
            $bundleHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot ($script:BundlePrefix + $file)) -Algorithm SHA256).Hash
            $bundleHash | Should -Be $liveHash -Because "$($script:BundlePrefix + $file) must be byte-identical to $file"
        }
    }
}
