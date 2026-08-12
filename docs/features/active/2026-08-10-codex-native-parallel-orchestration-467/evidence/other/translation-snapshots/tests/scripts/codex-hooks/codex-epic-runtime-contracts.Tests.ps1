#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic runtime configuration and distribution contracts' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:BundleRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations'
        $script:ConfigPath = Join-Path $script:RepoRoot '.codex/config.toml'
        $script:ManifestPath = Join-Path $script:BundleRoot 'pack-manifests/core.json'
        $script:RuntimePaths = @(
            '.agents/skills/epic-plan/SKILL.md',
            '.agents/skills/epic-run/SKILL.md',
            '.agents/skills/epic-orchestrate/SKILL.md',
            '.agents/skills/orchestrate/SKILL.md',
            '.agents/skills/orchestrator-workflow/SKILL.md',
            '.codex/agents/epic-planner.toml',
            '.codex/agents/epic-orchestrator.toml',
            '.codex/agents/orchestrator.toml',
            '.codex/config.toml',
            '.codex/hooks/authorize-root-epic-invocation.ps1',
            '.codex/hooks/codex-agent-profile-attestation.ps1',
            '.codex/hooks/codex-epic-child-launch-attestation.ps1',
            '.codex/hooks/record-subagent-routing-attestation.ps1',
            '.codex/hooks/enforce-epic-root-invocation.ps1',
            '.codex/hooks/enforce-epic-planning-only.ps1',
            '.codex/hooks/enforce-codex-model-routing.ps1',
            '.codex/hooks/enforce-epic-child-worktree-binding.ps1',
            '.codex/hooks/enforce-epic-wave-barrier.ps1',
            '.codex/hooks/enforce-epic-merge-gate.ps1',
            '.codex/hooks/enforce-epic-worktree-removal-gate.ps1',
            '.codex/hooks/validate-codex-subagent-routing.ps1',
            '.codex/scripts/epic-child-launch-contract.ps1',
            '.codex/scripts/launch-epic-child-wave.ps1'
        )
    }

    It 'uses the current nested command-handler hook schema' {
        $lines = Get-Content -LiteralPath $script:ConfigPath
        $content = $lines -join [Environment]::NewLine

        $content | Should -Match '\[\[hooks\.UserPromptSubmit\.hooks\]\]'
        $content | Should -Match '\[\[hooks\.SubagentStart\.hooks\]\]'
        $content | Should -Match '\[\[hooks\.PreToolUse\.hooks\]\]'
        $content | Should -Match '\[\[hooks\.SubagentStop\.hooks\]\]'
        $content | Should -Match '(?m)^type = "command"\r?$'

        $insideMatcherGroup = $false
        foreach ($line in $lines) {
            if ($line -match '^\[\[hooks\.[A-Za-z]+\]\]$') {
                $insideMatcherGroup = $true
                continue
            }
            if ($line -match '^\[\[hooks\.[A-Za-z]+\.hooks\]\]$') {
                $insideMatcherGroup = $false
                continue
            }
            if ($insideMatcherGroup) {
                $line | Should -Not -Match '^command(?:_windows)?\s*='
            }
        }
    }

    It 'registers root provenance, attestation, planning, wave, merge, worktree, and stop gates' {
        $content = Get-Content -Raw -LiteralPath $script:ConfigPath
        foreach ($name in @(
                'authorize-root-epic-invocation.ps1',
                'record-subagent-routing-attestation.ps1',
                'enforce-epic-root-invocation.ps1',
                'enforce-epic-planning-only.ps1',
                'enforce-codex-model-routing.ps1',
                'enforce-epic-wave-barrier.ps1',
                'enforce-epic-merge-gate.ps1',
                'enforce-epic-worktree-removal-gate.ps1',
                'validate-codex-subagent-routing.ps1',
                'authorize-root-parallel-invocation.ps1',
                'enforce-parallel-root-invocation.ps1',
                'enforce-parallel-cohort-barrier.ps1',
                'enforce-parallel-drift-gate.ps1',
                'enforce-parallel-child-worktree-binding.ps1',
                'enforce-parallel-worktree-removal-gate.ps1',
                'enforce-parallel-abandon-gate.ps1'
            )) {
            $content | Should -Match ([regex]::Escape($name))
        }
        $content | Should -Match '(?m)^max_depth = 3$'
        $content | Should -Match '(?m)^max_threads = 12$'
        $content | Should -Match '(?m)^\[permissions\.orchestrator-workspace\]$'
        $content | Should -Match '(?m)^extends = ":workspace"$'
        $content | Should -Not -Match '(?m)^agent\s*='
    }

    It 'pins both epic personas to Sol with ultra reasoning' -ForEach @(
        @{ Name = 'epic-planner' }
        @{ Name = 'epic-orchestrator' }
    ) {
        $path = Join-Path $script:RepoRoot ".codex/agents/$Name.toml"
        $content = Get-Content -Raw -LiteralPath $path

        $content | Should -Match ('(?m)^name = "' + [regex]::Escape($Name) + '"$')
        $content | Should -Match '(?m)^model = "gpt-5\.6-sol"$'
        $content | Should -Match '(?m)^model_reasoning_effort = "ultra"$'
        $content | Should -Match '(?m)^developer_instructions = '
    }

    It 'keeps the ordinary orchestrator out of the positive epic delegation surface' {
        $content = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.codex/agents/orchestrator.toml')

        $content | Should -Match 'EPIC_ENTRY_REQUIRES_ROOT'
        $content | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        $content | Should -Not -Match '(?m)^-\s+epic-(?:planner|orchestrator)\s*:'
    }

    It 'preserves the merged planner lifecycle boundary' {
        $content = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.agents/skills/epic-plan/SKILL.md')

        $content | Should -Match 'all child preparations in one preparation batch'
        $content | Should -Match 'launch-epic-child-wave\.ps1'
        $content | Should -Match 'Do not use native `spawn_agent`'
        $content | Should -Match 'There is no additional approval pause|There is no mid-planning approval pause|no mid-planning approval'
        $content | Should -Match 'artifacts/orchestration/epic-kickoff-<epic-slug>\.md'
        $content | Should -Match 'docs/features/epics/<epic-slug>/epic-kickoff\.md'
        $content | Should -Match 'S5_atomic_execution'
    }

    It 'keeps deterministic topology independent from C1-C4 deployment selection' {
        $entry = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.agents/skills/orchestrate/SKILL.md')
        $workflow = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.agents/skills/orchestrator-workflow/SKILL.md')

        $entry | Should -Match 'Inside the applicable language budget'
        $entry | Should -Match 'orchestrator-<profile>'
        $entry | Should -Match 'epic-planner.*Sol/Ultra'
        $entry | Should -Match 'epic-orchestrator.*Sol/Ultra'
        $entry | Should -Match 'File\s+count does not choose a model'
        $workflow | Should -Match 'Delegate constrained implementation'
        $workflow | Should -Match 'python-typed-engineer-<profile>'
        $workflow | Should -Match 'TypeScript has no canonical small-path budget'
        $workflow | Should -Match 'topology, model-routing, and delegation receipts'
        $workflow | Should -Not -Match 'steps that are not modeled as required delegated handoffs may execute directly'
    }

    It 'includes every epic runtime surface in the core pack manifest' {
        $manifest = Get-Content -Raw -LiteralPath $script:ManifestPath | ConvertFrom-Json
        foreach ($path in @(
                '.agents/skills/epic-plan/SKILL.md',
                '.agents/skills/epic-run/SKILL.md',
                '.agents/skills/epic-orchestrate/SKILL.md',
                '.codex/agents/epic-planner.toml',
                '.codex/agents/epic-orchestrator.toml',
                '.codex/hooks/authorize-root-epic-invocation.ps1',
                '.codex/hooks/codex-agent-profile-attestation.ps1',
                '.codex/hooks/codex-authority-store.ps1',
                '.codex/hooks/codex-epic-child-launch-attestation.ps1',
                '.codex/hooks/record-subagent-routing-attestation.ps1',
                '.codex/hooks/enforce-epic-root-invocation.ps1',
                '.codex/hooks/enforce-epic-planning-only.ps1',
                '.codex/hooks/enforce-codex-model-routing.ps1',
                '.codex/hooks/enforce-epic-child-worktree-binding.ps1',
                '.codex/hooks/enforce-epic-wave-barrier.ps1',
                '.codex/hooks/enforce-epic-merge-gate.ps1',
                '.codex/hooks/enforce-epic-worktree-removal-gate.ps1',
                '.codex/hooks/validate-codex-subagent-routing.ps1',
                '.codex/scripts/epic-child-launch-contract.ps1',
                '.codex/scripts/launch-epic-child-wave.ps1'
            )) {
            @($manifest.paths) | Should -Contain $path
        }
    }

    It 'keeps root and tracked bundle runtime copies byte-identical' {
        foreach ($relativePath in $script:RuntimePaths) {
            $rootPath = Join-Path $script:RepoRoot $relativePath
            $bundlePath = Join-Path $script:BundleRoot $relativePath
            Test-Path -LiteralPath $bundlePath -PathType Leaf | Should -BeTrue
            (Get-FileHash -LiteralPath $bundlePath -Algorithm SHA256).Hash |
                Should -Be (Get-FileHash -LiteralPath $rootPath -Algorithm SHA256).Hash
        }
    }

    It 'keeps hook, config, and agent files within the 500-line limit' {
        $files = @(
            Get-ChildItem (Join-Path $script:RepoRoot '.codex/hooks') -Filter '*.ps1' -File
            Get-ChildItem (Join-Path $script:RepoRoot '.codex/scripts') -Filter '*.ps1' -File
            Get-ChildItem (Join-Path $script:RepoRoot '.codex/agents') -Filter '*.toml' -File
            Get-Item $script:ConfigPath
        )
        foreach ($file in $files) {
            (Get-Content -LiteralPath $file.FullName).Count |
                Should -BeLessOrEqual 500 -Because $file.FullName
        }
    }
}
