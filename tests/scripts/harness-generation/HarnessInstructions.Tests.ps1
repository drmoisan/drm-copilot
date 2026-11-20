Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessInstructions.psm1 (issue #1028).
#
# Each finding kind has one failing-input case, and a passing AGENTS.md and CLAUDE.md pair produces no finding.
# Inputs are strings in an in-memory tree read through the context seam. No temporary file, process or
# network call is made.

Describe 'HarnessInstructions module' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessInstructions.psm1') -Force

        $script:GoodAgents = "# AGENTS.md`n`n## Tone Policy`n`nUse a professional tone.`n`n## Skills`n`nSee ``.agents/skills/tone/SKILL.md``.`n"
        $script:GoodClaude = "---`ndescription: d`n---`n@AGENTS.md`n`n# CLAUDE.md`n`n## Claude Only`n`nClaude-specific text.`n"
        $script:BundlePath = 'extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md'

        function Get-Finding {
            param([System.Collections.IDictionary] $Override = @{})
            $store = [ordered]@{
                'AGENTS.md'                    = $script:GoodAgents
                'CLAUDE.md'                    = $script:GoodClaude
                $script:BundlePath             = $script:GoodAgents
                '.agents/skills/tone/SKILL.md' = "skill`n"
                '.claude/rules/tonality.md'    = "# Tonality`n`n## Rule Body`n`nNever joke.`n"
            }
            foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $store.Remove($key) } else { $store[$key] = $Override[$key] } }
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { param([string] $Folder) @($store.Keys | Where-Object { $_.StartsWith("$Folder/") }) }.GetNewClosure() `
                -TestReparse { $false }
            $result = Get-HarnessInstructionFindings -Context $context
            return @($result.Findings)
        }
    }

    AfterAll {
        Remove-Module -Name HarnessInstructions, HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    It 'reports no finding for a passing AGENTS.md and CLAUDE.md pair' {
        @(Get-Finding).Count | Should -Be 0
    }

    It 'returns no generated file' {
        $context = New-HarnessGenerationContext -Root 'fake-root' -ReadFile { $null } -ListFiles { @() } -TestReparse { $false }
        (Get-HarnessInstructionFindings -Context $context).Files.Count | Should -Be 0
    }

    It 'reports <Kind>' -ForEach @(
        @{ Kind = 'CONVERTER-HEADING'; Override = @{ 'AGENTS.md' = "# Converted standing guidance`n`n## A`n`nx`n" } }
        @{ Kind = 'GENERATED-NOTE'; Override = @{ 'AGENTS.md' = "# AGENTS.md`n`n> NOTE: This file is **generated** from:`n" } }
        @{ Kind = 'EMBEDDED-RULE'; Override = @{ 'AGENTS.md' = "# AGENTS.md`n`n## Copied`n`nNever   joke.`n" } }
        @{ Kind = 'MISSING-SKILL'; Override = @{ 'AGENTS.md' = "# AGENTS.md`n`nSee .agents/skills/absent/SKILL.md.`n" } }
        @{ Kind = 'CLAUDE-IMPORT'; Override = @{ 'CLAUDE.md' = "---`ndescription: d`n---`n`n@AGENTS.md`n" } }
        @{ Kind = 'DUPLICATE-SECTION'; Override = @{ 'CLAUDE.md' = "---`ndescription: d`n---`n@AGENTS.md`n`n# CLAUDE.md`n`n## Tone Again`n`nUse a professional tone.`n" } }
        @{ Kind = 'BUNDLE-DRIFT'; Override = @{ 'extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md' = "stale`n" } }
        @{ Kind = 'COVERAGE-THRESHOLD'; Override = @{ 'AGENTS.md' = "# AGENTS.md`n`n## Testing`n`nLine coverage must stay at or above 85% for every file.`n" } }
    ) {
        $kinds = @(Get-Finding -Override $Override | ForEach-Object Kind)
        $kinds | Should -Contain $Kind
    }

    It 'reports a missing AGENTS.md and a missing CLAUDE.md' {
        $findings = @(Get-Finding -Override @{ 'AGENTS.md' = $null; 'CLAUDE.md' = $null })
        @($findings | ForEach-Object { "$($_.Kind) $($_.Path)" }) | Should -Be @('MISSING AGENTS.md', 'MISSING CLAUDE.md')
    }

    It 'reports an absent bundle copy as drift' {
        @(Get-Finding -Override @{ 'extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md' = $null } | ForEach-Object Kind) | Should -Contain 'BUNDLE-DRIFT'
    }

    It 'reads no heading inside a fenced code block' {
        $sections = @(Get-HarnessH2Section -Text "## A`n`n``````text`n## not a heading`n```````nbody`n# Top`n## B`nb`n")
        @($sections | ForEach-Object Heading) | Should -Be @('## A', '## B')
        $sections[0].Body | Should -BeExactly '```text ## not a heading ``` body'
    }

    It 'returns the first line when there is no frontmatter and an empty line for unterminated frontmatter' {
        Get-HarnessLineAfterFrontmatter -Text "@AGENTS.md`nrest" | Should -BeExactly '@AGENTS.md'
        Get-HarnessLineAfterFrontmatter -Text "---`na: b" | Should -BeExactly ''
        Get-HarnessLineAfterFrontmatter -Text "---`na: b`n---" | Should -BeExactly ''
    }

    It 'does not report a percentage on a line without the word coverage' {
        @(Get-Finding -Override @{ 'AGENTS.md' = "# AGENTS.md`n`n## Limits`n`nKeep 20% headroom.`n"; $script:BundlePath = "# AGENTS.md`n`n## Limits`n`nKeep 20% headroom.`n" }).Count | Should -Be 0
    }
}
