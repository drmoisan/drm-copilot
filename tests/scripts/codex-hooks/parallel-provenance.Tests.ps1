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
        . (Join-Path $script:RepoRoot '.codex/hooks/record-subagent-routing-attestation.ps1')
        $script:ParallelNow = [datetimeoffset]'2026-08-12T12:00:00Z'
        $script:ParallelHead = 'a' * 40

        function Get-ParallelPersonaContract {
            param(
                [Parameter(Mandatory)]
                [string]$Persona
            )

            $content = Get-Content -Raw -LiteralPath `
            (Join-Path $script:AgentRoot "$Persona.toml")
            $permission = [regex]::Match(
                $content,
                '(?m)^default_permissions = "(?<value>[^"]+)"$'
            )
            $prompt = [regex]::Match(
                $content,
                "(?ms)^developer_instructions = '''\r?\n(?<value>.*?)\r?\n'''$"
            )
            $skills = [regex]::Matches(
                $content,
                '(?m)^\s*\{ name = "(?<value>[^"]+)", enabled = true \},?$'
            )

            $permission.Success | Should -BeTrue
            $prompt.Success | Should -BeTrue
            $skills.Count | Should -BeGreaterThan 0

            return [pscustomobject]@{
                Permission    = $permission.Groups['value'].Value
                Prompt        = $prompt.Groups['value'].Value
                EnabledSkills = @($skills | ForEach-Object { $_.Groups['value'].Value })
            }
        }

        function Get-TestParallelRootReceipt {
            param(
                [ValidateSet('parallel-plan', 'parallel-run', 'parallel-orchestrate')]
                [string] $EntryKind = 'parallel-run'
            )

            $persona = if ($EntryKind -eq 'parallel-plan') {
                'parallel-planner'
            } else {
                'parallel-orchestrator'
            }
            $identity = Get-CodexAuthoritySha256 -Text "run-a|$EntryKind"
            return [pscustomobject][ordered]@{
                schema_version      = 1
                surface             = 'parallel'
                repository_root     = Get-CodexCanonicalAuthorityPath -Path $script:RepoRoot
                repository_sha256   = Get-CodexAuthorityRepositoryKey -RepositoryRoot $script:RepoRoot
                repository_head_sha = $script:ParallelHead
                session_id          = 'session-parallel'
                turn_id             = 'turn-parallel'
                prompt_sha256       = 'b' * 64
                requested_persona   = $persona
                entry_kind          = $EntryKind
                parallel_reference  = 'run-a'
                parallel_slug       = 'run-a'
                parallel_identity   = $identity
                mutation_identity   = $identity
                kickoff_path        = $(if ($EntryKind -eq 'parallel-run') {
                        'docs/features/parallel/run-a/parallel-kickoff.md'
                    } else { '' })
                created_at          = $script:ParallelNow.AddMinutes(-1).ToString('o')
                expires_at          = $script:ParallelNow.AddMinutes(30).ToString('o')
                consumed            = $false
                consumed_by         = $null
                consumed_at         = $null
            }
        }
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

    It 'aligns the planner prompt tool and permission statements with its dedicated profile' {
        $contract = Get-ParallelPersonaContract -Persona 'parallel-planner'
        $toolStatements = [regex]::Matches(
            $contract.Prompt,
            '(?m)^Apply `(?<value>[^`]+)` as the canonical procedure\.'
        )
        $permissionStatements = [regex]::Matches(
            $contract.Prompt,
            'sandbox authority `(?<value>[^`]+)`'
        )

        $toolStatements.Count | Should -BeGreaterThan 0
        foreach ($statement in $toolStatements) {
            $contract.EnabledSkills | Should -Contain $statement.Groups['value'].Value
        }

        $permissionStatements.Count | Should -BeGreaterThan 0
        foreach ($statement in $permissionStatements) {
            $statement.Groups['value'].Value | Should -BeExactly $contract.Permission `
                -Because 'the planner prompt authority must match default_permissions'
        }
    }

    It 'aligns the orchestrator prompt tool and permission statements with its dedicated profile' {
        $contract = Get-ParallelPersonaContract -Persona 'parallel-orchestrator'
        $toolStatements = [regex]::Matches(
            $contract.Prompt,
            '(?m)(?:^Apply|and) `(?<value>parallel-(?:run|orchestrate))` (?:for|as) '
        )
        $permissionStatements = [regex]::Matches(
            $contract.Prompt,
            'sandbox authority `(?<value>[^`]+)`'
        )

        $toolStatements.Count | Should -BeGreaterThan 0
        foreach ($statement in $toolStatements) {
            $contract.EnabledSkills | Should -Contain $statement.Groups['value'].Value
        }

        $permissionStatements.Count | Should -BeGreaterThan 0
        foreach ($statement in $permissionStatements) {
            $statement.Groups['value'].Value | Should -BeExactly $contract.Permission `
                -Because 'the orchestrator prompt authority must match default_permissions'
        }
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

    It 'validates every supported parallel root-entry receipt shape' {
        foreach ($entryKind in @('parallel-plan', 'parallel-run', 'parallel-orchestrate')) {
            $receipt = Get-TestParallelRootReceipt -EntryKind $entryKind
            $payload = [pscustomobject]@{
                session_id = 'session-parallel'
                turn_id    = 'turn-parallel'
                agent_type = [string]$receipt.requested_persona
            }

            Test-RootParallelReceipt `
                -Receipt $receipt -Payload $payload -RepositoryRoot $script:RepoRoot `
                -CurrentHeadSha $script:ParallelHead -Now $script:ParallelNow |
                Should -BeTrue
        }
        Test-RootParallelReceipt `
            -Receipt $null -Payload ([pscustomobject]@{}) -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:ParallelHead -Now $script:ParallelNow |
            Should -BeFalse
    }

    It 'rejects malformed, drifted, consumed, and expired parallel receipts' {
        $base = Get-TestParallelRootReceipt
        $payload = [pscustomobject]@{
            session_id = 'session-parallel'; turn_id = 'turn-parallel'
            agent_type = 'parallel-orchestrator'
        }
        $cases = @(
            { param($r) $r.PSObject.Properties.Remove('surface') }
            { param($r) Add-Member -InputObject $r -NotePropertyName unexpected -NotePropertyValue value }
            { param($r) $r.surface = 'epic' }
            { param($r) $r.parallel_identity = 'invalid' }
            { param($r) $r.mutation_identity = 'c' * 64 }
            { param($r) $r.kickoff_path = 'other.md' }
            { param($r) $r.consumed = $true }
            { param($r) $r.expires_at = $script:ParallelNow.AddMinutes(-1).ToString('o') }
            { param($r) $r.requested_persona = 'unknown' }
        )
        foreach ($mutate in $cases) {
            $receipt = $base | ConvertTo-Json | ConvertFrom-Json
            & $mutate $receipt
            Test-RootParallelReceipt `
                -Receipt $receipt -Payload $payload -RepositoryRoot $script:RepoRoot `
                -CurrentHeadSha $script:ParallelHead -Now $script:ParallelNow |
                Should -BeFalse
        }
    }

    It 'builds a complete parallel attestation and fails closed without root authority' {
        $receipt = Get-TestParallelRootReceipt
        $payload = [pscustomobject]@{
            session_id      = 'session-parallel'
            turn_id         = 'turn-parallel'
            agent_id        = 'agent-parallel'
            agent_type      = 'parallel-orchestrator'
            model           = 'gpt-5.6-sol'
            transcript_path = 'parallel.jsonl'
        }
        $accepted = Get-CodexSubagentAttestation `
            -Payload $payload -RootReceipt $receipt -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:ParallelHead `
            -Now $script:ParallelNow
        $accepted.root_authorized | Should -BeTrue
        $accepted.provenance_valid | Should -BeTrue
        $accepted.surface | Should -Be 'parallel'
        $accepted.fallback_used | Should -BeFalse
        $accepted.parallel_identity | Should -Be $receipt.parallel_identity

        $rejected = Get-CodexSubagentAttestation `
            -Payload $payload -RootReceipt $null -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:ParallelHead `
            -Now $script:ParallelNow
        $rejected.root_authorized | Should -BeFalse
        $rejected.provenance_valid | Should -BeFalse
        $rejected.enforcement_marker | Should -Be 'PARALLEL_INVOCATION_ORIGIN_BLOCKED'
    }

    It 'uses the no-receipt authority path without creating files' {
        $payload = [pscustomobject]@{
            session_id = 'session'; turn_id = 'turn'; agent_id = 'agent'
            agent_type = 'default'; model = 'gpt-5.6-terra'; transcript_path = ''
        }
        $result = Get-CodexSubagentAttestationFromAuthority `
            -Payload $payload -ReceiptPath (Join-Path $script:RepoRoot 'absent-receipt.json') `
            -Checkpoints @() -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:ParallelHead -Now $script:ParallelNow
        $result.agent_id | Should -Be 'agent'
        $result.routing_valid | Should -BeTrue
        $result.attestation_key | Should -Match '^[0-9a-f]{64}$'
    }
}
