#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex parallel root provenance contracts' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:SkillRoot = Join-Path $script:RepoRoot '.agents/skills'
        $script:AgentRoot = Join-Path $script:RepoRoot '.codex/agents'
        $script:BundleAgentRoot = Join-Path $script:RepoRoot `
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents'
        $script:ConfigContent = Get-Content -Raw -LiteralPath `
        (Join-Path $script:RepoRoot '.codex/config.toml')
    }

    It 'publishes root-only skill <Name>' -ForEach @(
        @{ Name = 'parallel-plan' }
        @{ Name = 'parallel-run' }
        @{ Name = 'parallel-orchestrate' }
        @{ Name = 'parallel-add' }
        @{ Name = 'parallel-remove' }
        @{ Name = 'parallel-close' }
    ) {
        $path = Join-Path $script:SkillRoot "$Name/SKILL.md"

        Test-Path -LiteralPath $path -PathType Leaf | Should -BeTrue
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            return
        }

        $content = Get-Content -Raw -LiteralPath $path
        $content | Should -Match '(?m)^Use this skill only from the root session\.$'
    }

    It 'routes <Name> only to <Persona>' -ForEach @(
        @{ Name = 'parallel-plan'; Persona = 'parallel-planner' }
        @{ Name = 'parallel-run'; Persona = 'parallel-orchestrator' }
        @{ Name = 'parallel-orchestrate'; Persona = 'parallel-orchestrator' }
    ) {
        $path = Join-Path $script:SkillRoot "$Name/SKILL.md"
        Test-Path -LiteralPath $path -PathType Leaf | Should -BeTrue
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            return
        }

        $content = Get-Content -Raw -LiteralPath $path
        $route = [regex]::Match(
            $content,
            '(?m)^Delegate only to the project custom agent `(?<persona>[^`]+)`\.$'
        )

        $route.Success | Should -BeTrue
        $route.Groups['persona'].Value | Should -Be $Persona
        $route.Groups['persona'].Value | Should -Not -BeIn @(
            'orchestrator',
            'epic-planner',
            'epic-orchestrator'
        )
    }

    It 'keeps mutation skill <Name> as a non-delegating validated client' -ForEach @(
        @{ Name = 'parallel-add' }
        @{ Name = 'parallel-remove' }
        @{ Name = 'parallel-close' }
    ) {
        $path = Join-Path $script:SkillRoot "$Name/SKILL.md"
        Test-Path -LiteralPath $path -PathType Leaf | Should -BeTrue
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            return
        }

        $content = Get-Content -Raw -LiteralPath $path
        $content | Should -Match '(?m)^This root mutation skill is a validated client and does not delegate\.$'
        $content | Should -Not -Match '(?m)^Delegate only to the project custom agent '
    }

    It 'defines forced persona <Persona> with the exact deployment' -ForEach @(
        @{
            Persona = 'parallel-planner'; RoleMarker = 'planning-only'
            Permission = 'parallel-planner-workspace'
        }
        @{
            Persona = 'parallel-orchestrator'; RoleMarker = 'root-scheduler-only'
            Permission = 'parallel-orchestrator-workspace'
        }
    ) {
        $path = Join-Path $script:AgentRoot "$Persona.toml"
        $bundlePath = Join-Path $script:BundleAgentRoot "$Persona.toml"

        Test-Path -LiteralPath $path -PathType Leaf | Should -BeTrue
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            return
        }

        $content = Get-Content -Raw -LiteralPath $path
        $escapedPersona = [regex]::Escape($Persona)
        $content | Should -Match "(?m)^name = `"$escapedPersona`"$"
        $content | Should -Match '(?m)^model = "gpt-5\.6-sol"$'
        $content | Should -Match '(?m)^model_reasoning_effort = "ultra"$'
        $content | Should -Match "(?m)^default_permissions = `"$Permission`"$"
        $content | Should -Match ([regex]::Escape($RoleMarker))
        $content | Should -BeExactly (Get-Content -Raw -LiteralPath $bundlePath)
        $script:ConfigContent | Should -Match `
            "(?m)^\[permissions\.$([regex]::Escape($Permission))\]$"
    }

    It 'limits G02 root persona writes to the dedicated <Permission> profile' -ForEach @(
        @{
            Permission    = 'parallel-planner-workspace'
            WritablePaths = @(
                '.git'
                '.git/**'
                '.codex/state/**'
                'artifacts/orchestration/parallel-planner-state.json'
                'docs/features/**'
                'docs/research/**'
            )
        }
        @{
            Permission    = 'parallel-orchestrator-workspace'
            WritablePaths = @(
                '.git'
                '.git/**'
                '.codex/state/**'
                'artifacts/orchestration/parallel-*.json'
                'artifacts/orchestration/parallel/**'
                'docs/features/parallel/**'
            )
        }
    ) {
        $escapedPermission = [regex]::Escape($Permission)
        $section = [regex]::Match(
            $script:ConfigContent,
            '(?ms)^\[permissions\.' + $escapedPermission +
            '\.filesystem\.":workspace_roots"\]\r?\n(?<body>.*?)(?=^\[|\z)'
        )

        $section.Success | Should -BeTrue
        $body = $section.Groups['body'].Value
        $body | Should -Match '(?m)^"\*\*" = "read"$'
        $body | Should -Match '(?m)^"\.claude/\*\*" = "deny"$'
        foreach ($writablePath in $WritablePaths) {
            $body | Should -Match (
                '(?m)^"' + [regex]::Escape($writablePath) + '" = "write"$'
            )
        }
        $body | Should -Not -Match '(?m)^"(?:scripts|extensions)/\*\*" = "write"$'
        $body | Should -Not -Match '(?m)^"\*\*" = "write"$'
    }

    It 'denies protected customization writes in the G02 child profile' {
        $section = [regex]::Match(
            $script:ConfigContent,
            '(?ms)^\[permissions\.parallel-child-workspace\.filesystem\."' +
            ':workspace_roots"\]\r?\n(?<body>.*?)(?=^\[|\z)'
        )

        $section.Success | Should -BeTrue
        $body = $section.Groups['body'].Value
        $body | Should -Match '(?m)^"\.claude/\*\*" = "deny"$'
        foreach ($readOnlyPath in @(
                '.codex/**'
                '.agents/**'
                'AGENTS.md'
                'config/orchestration-routing.json'
            )) {
            $body | Should -Match (
                '(?m)^"' + [regex]::Escape($readOnlyPath) + '" = "read"$'
            )
            $body | Should -Not -Match (
                '(?m)^"' + [regex]::Escape($readOnlyPath) + '" = "write"$'
            )
        }
        $body | Should -Not -Match '(?m)^"\*\*" = "write"$'
    }
}
