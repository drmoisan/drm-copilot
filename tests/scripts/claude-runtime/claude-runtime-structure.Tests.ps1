Set-StrictMode -Version Latest

Describe "claude-runtime-structure" {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
    }

    It "requires .claude/skills/orchestrate/SKILL.md to avoid context fork and orchestrator agent routing" {
        $skillPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'skills', 'orchestrate', 'SKILL.md'
        $content = Get-Content -Path $skillPath -Raw

        $content | Should -Not -Match 'context:\s*fork'
        $content | Should -Not -Match 'agent:\s*orchestrator'
    }

    It "requires the five wrapper skills to exist under .claude/skills" {
        $requiredSkills = @(
            'review-feature',
            'review-staged',
            'review-epic',
            'update-status',
            'fill-feature-docs'
        )

        foreach ($skill in $requiredSkills) {
            $skillPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'skills', $skill, 'SKILL.md'
            Test-Path -Path $skillPath -PathType Leaf | Should -BeTrue
        }
    }

    It "requires .claude/agents/orchestrator.md to allow Agent(prd-feature)" {
        $agentPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', 'orchestrator.md'
        $content = Get-Content -Path $agentPath -Raw

        $content | Should -Match 'Agent\([^)]*prd-feature'
    }

    It "requires .claude/agents/orchestrator.md to allow Agent(staged-review), Agent(epic-review), and Agent(status-updater)" {
        $agentPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', 'orchestrator.md'
        $content = Get-Content -Path $agentPath -Raw

        $content | Should -Match 'Agent\([^)]*staged-review'
        $content | Should -Match 'Agent\([^)]*epic-review'
        $content | Should -Match 'Agent\([^)]*status-updater'
    }

    It "requires .claude/agents/orchestrator.md to allow Agent(python-typed-engineer), Agent(powershell-typed-engineer), Agent(csharp-typed-engineer), and Agent(typescript-engineer)" {
        $agentPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', 'orchestrator.md'
        $content = Get-Content -Path $agentPath -Raw

        $content | Should -Match 'Agent\([^)]*python-typed-engineer'
        $content | Should -Match 'Agent\([^)]*powershell-typed-engineer'
        $content | Should -Match 'Agent\([^)]*csharp-typed-engineer'
        $content | Should -Match 'Agent\([^)]*typescript-engineer'
    }

    It "requires bounded worker agents and excludes repository-disallowed persona files" {
        $requiredAgents = @(
            'prd-feature.md',
            'staged-review.md',
            'epic-review.md',
            'status-updater.md',
            'python-typed-engineer.md',
            'powershell-typed-engineer.md',
            'csharp-typed-engineer.md',
            'typescript-engineer.md'
        )

        foreach ($agent in $requiredAgents) {
            $agentPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', $agent
            Test-Path -Path $agentPath -PathType Leaf | Should -BeTrue
        }

        $excludedAgents = @(
            'mentor.md',
            'api-architect.md',
            'hlbpa.md',
            '5.1-Beast-adjusted.md',
            '5.1-Thinking-Beast-Mode-adjusted.md',
            'gpt-5-beast-mode.md',
            'voidbeast-gpt41enhanced.md'
        )

        foreach ($agent in $excludedAgents) {
            $agentPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', $agent
            Test-Path -Path $agentPath -PathType Leaf | Should -BeFalse
        }
    }
}
