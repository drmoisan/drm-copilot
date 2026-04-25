Set-StrictMode -Version Latest

Describe "claude-architecture-doc" {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
    }

    It "requires the architecture document to cover research sufficiency, main-thread orchestration, and full migration tables" {
        $docPath = Join-Path -Path $script:RepoRoot -ChildPath 'docs' -AdditionalChildPath 'engineering', 'claude-code-architecture.md'
        $content = Get-Content -Path $docPath -Raw

        $content | Should -Match '20260412-claude-code-github-skills-agents-migration-research\.md'
        $content | Should -Match 'main-thread orchestrator'
        $content | Should -Match '### Canonical `\.github/skills` migration map'
        $content | Should -Match '### Canonical `\.github/agents` migration map'
        $content | Should -Match '### Direct-use `\.github/prompts` migration map'
    }

    It "requires the architecture document to keep .github/skills/README.md documentation-only and not require .claude/skills/README.md" {
        $docPath = Join-Path -Path $script:RepoRoot -ChildPath 'docs' -AdditionalChildPath 'engineering', 'claude-code-architecture.md'
        $content = Get-Content -Path $docPath -Raw

        $content | Should -Match '\.github/skills/README\.md'
        $content | Should -Match 'documentation-only'
        $content | Should -Not -Match '\.claude/skills/README\.md'
    }

    It "requires .claude/rules/powershell.md to use the active PowerShell MCP contract" {
        $powershellRulePath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'rules', 'powershell.md'
        $powershellRuleContent = Get-Content -Path $powershellRulePath -Raw

        $powershellRuleContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_format'
        $powershellRuleContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze'
        $powershellRuleContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_test'
        $powershellRuleContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze_autofix'
        $powershellRuleContent | Should -Not -Match 'mcp_drmcopilotext_run_poshqc_test'
    }

    It "requires .claude/agents/atomic-executor.md to use the active PowerShell MCP contract" {
        $atomicExecutorPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', 'atomic-executor.md'
        $atomicExecutorContent = Get-Content -Path $atomicExecutorPath -Raw

        $atomicExecutorContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_format'
        $atomicExecutorContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze'
        $atomicExecutorContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_test'
        $atomicExecutorContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze_autofix'
        $atomicExecutorContent | Should -Not -Match 'mcp_drmcopilotext_run_poshqc_test'
    }

    It "requires docs/engineering/claude-code-architecture.md to use the active PowerShell MCP contract" {
        $docPath = Join-Path -Path $script:RepoRoot -ChildPath 'docs' -AdditionalChildPath 'engineering', 'claude-code-architecture.md'
        $docContent = Get-Content -Path $docPath -Raw

        $docContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_format'
        $docContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze'
        $docContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_test'
        $docContent | Should -Match 'mcp__drmCopilotExtension__run_poshqc_analyze_autofix'
        $docContent | Should -Not -Match 'mcp_drmcopilotext_run_poshqc_test'
    }

    It "requires .claude/agents/feature-review.md to support writing review artifacts into a selected version folder" {
        $featureReviewPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents', 'feature-review.md'
        $content = Get-Content -Path $featureReviewPath -Raw

        $content | Should -Match 'selected version folder|/v2/|version folder'
    }
}
