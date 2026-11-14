# Pester tests that pin the stage_timing writer documentation of issue #1097 (stage B) in every copy
# of the orchestrate skill, the orchestrator agent, and the orchestrator-state rule. The files are
# read in place through an in-process read; no test writes a file.

BeforeAll {
    $script:repoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../../..')).ProviderPath

    function Get-TestNormalizedText {
        # Reads a repository file and collapses every whitespace run to one space, so a wrapped phrase reads as one phrase.
        param([string] $RelativePath)
        $raw = [System.IO.File]::ReadAllText((Join-Path -Path $script:repoRoot -ChildPath $RelativePath))
        $raw -replace '\s+', ' '
    }

    function Get-TestMissingStageTimingToken {
        # Returns each required token that the normalized text lacks.
        param([string] $Text)
        $required = @('stage_timing', 'stage-timing.', 'wall-clock', 'The merge stage is not captured.')
        @($required | Where-Object { -not $Text.Contains($_) })
    }
}

Describe 'stage_timing writer documentation' {
    It 'STD-SKILL-DOCUMENTS-STAGE-TIMING-IN-EVERY-COPY' -ForEach @(
        @{ Path = '.claude/skills/orchestrate/SKILL.md' },
        @{ Path = '.agents/skills/orchestrate/SKILL.md' },
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md' },
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md' }
    ) {
        $text = Get-TestNormalizedText -RelativePath $Path

        $missing = @(Get-TestMissingStageTimingToken -Text $text)

        $missing.Count | Should -Be 0 -Because "$Path must carry every stage_timing token; missing: $($missing -join ', ')"
        $text.Contains('scripts/dev-tools/Get-StageTimingReport.ps1') | Should -BeTrue -Because "$Path must name the report entry"
    }

    It 'STD-AGENT-DOCUMENTS-STAGE-TIMING-IN-BOTH-COPIES' -ForEach @(
        @{ Path = '.claude/agents/orchestrator.md' },
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md' }
    ) {
        $text = Get-TestNormalizedText -RelativePath $Path

        $missing = @(Get-TestMissingStageTimingToken -Text $text)

        $missing.Count | Should -Be 0 -Because "$Path must carry every stage_timing token; missing: $($missing -join ', ')"
        $text.Contains('orchestrate skill') | Should -BeTrue -Because "$Path must point to the orchestrate skill"
    }

    It 'STD-RULE-LISTS-STAGE-TIMING-AS-TOLERATED-IN-BOTH-COPIES' -ForEach @(
        @{ Path = '.claude/rules/orchestrator-state.md' },
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md' }
    ) {
        $text = Get-TestNormalizedText -RelativePath $Path
        $raw = [System.IO.File]::ReadAllText((Join-Path -Path $script:repoRoot -ChildPath $Path))
        $paragraphs = @([regex]::Split($raw, '(?:\r?\n){2,}') | Where-Object { $_.Contains('stage_timing') -and $_.Contains('tolerated') })

        $missing = @(Get-TestMissingStageTimingToken -Text $text)

        $missing.Count | Should -Be 0 -Because "$Path must carry every stage_timing token; missing: $($missing -join ', ')"
        $paragraphs.Count | Should -BeGreaterThan 0 -Because "$Path must list stage_timing as tolerated in the same paragraph"
    }
}
