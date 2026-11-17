#Requires -Version 7.0
# Unit tests for scripts/harness/HarnessInventory.psm1 (issue #1025, spec `### Parity Matrix: Feature Kinds
# and Inventory Rules` and `### Parity Matrix: Identifier Encoding`). File listings and contents are
# injected in memory; no file is created and no repository file is read.

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../scripts/harness/HarnessInventory.psm1') -Force

    function Get-TestInventory {
        param([hashtable] $Files)
        $copy = $Files.Clone()
        $list = { param($Root) $null = $Root; @($copy.Keys) }.GetNewClosure()
        $read = { param($Root, $Path) $null = $Root; $copy[$Path] }.GetNewClosure()
        return @(Get-HarnessInventory -RepositoryRoot 'memory' -ListFiles $list -ReadFile $read)
    }

    function Get-SettingsJson {
        param([string] $HooksJson = '{}', [string] $Extra = '')
        return "{ `"`$schema`": `"https://json.schemastore.org/claude-code-settings.json`", `"permissions`": { `"allow`": [], `"deny`": [] }, `"hooks`": $HooksJson$Extra }"
    }

    function Get-RegistrationJson {
        param([string] $Matcher, [string] $Command, [switch] $NoMatcher)
        $matcherText = if ($NoMatcher) { '' } else { "`"matcher`": $(ConvertTo-Json -InputObject $Matcher -Compress), " }
        return "{ $matcherText`"hooks`": [ { `"type`": `"command`", `"command`": $(ConvertTo-Json -InputObject $Command -Compress) } ] }"
    }

    $script:AgentFrontmatter = @(
        '---', 'name: atomic-planner', 'tools:', '  - Read', 'hooks:', '  SubagentStop:', '    - matcher: "atomic-planner"', '      hooks:',
        '        - type: command', '          command: "pwsh -NoProfile -File .claude/hooks/validate-planner-output.ps1"', '---', 'Body.'
    ) -join "`n"

    $script:KindFixture = @{
        'AGENTS.md'                                     = '# Agents'
        'CLAUDE.md'                                     = '# Claude'
        '.github/copilot-instructions.md'               = '# Copilot'
        '.claude/rules/python.md'                       = '# rule'
        '.github/instructions/python.instructions.md'   = '# rule'
        '.claude/skills/orchestrate/SKILL.md'           = "---`nname: orchestrate`nallowed-tools: Read`n---`nBody"
        '.agents/skills/orchestrate/SKILL.md'           = "---`nname: orchestrate`ndescription: x`n---`nBody"
        '.github/skills/orchestrate/SKILL.md'           = "---`nname: orchestrate`n---`nBody"
        '.agents/skills/orchestrate/agents/openai.yaml' = 'interface: {}'
        '.claude/agents/atomic-planner.md'              = $script:AgentFrontmatter
        '.codex/agents/orchestrator.toml'               = "name = `"orchestrator`"`nmodel = `"gpt`"`n[extra]`nkey = 1"
        '.github/agents/planner.agent.md'               = "---`nname: planner`nhandoffs:`n  - label: go`n---`nBody"
        '.github/prompts/drafts/commit.prompt.md'       = 'prompt'
        '.codex/prompts/review.md'                      = 'prompt'
        '.claude/settings.json'                         = (Get-SettingsJson -HooksJson ('{ "SessionStart": [ ' + (Get-RegistrationJson -NoMatcher -Command 'pwsh -File .claude/hooks/persist-session-id.ps1') + ' ] }') -Extra ', "enabledPlugins": {}')
        '.mcp.json'                                     = '{ "mcpServers": { "drm-copilot": { "command": "npx" } } }'
        '.codex/config.toml'                            = "[mcp_servers.drm-copilot]`ncommand = `"npx`"`n[permissions.orchestrator-workspace]`nextends = `":workspace`"`n[features]`nhooks = true"
        '.github/hooks/discovery.json'                  = '{ "version": 1, "hooks": { "SubagentStart": [ { "type": "command", "powershell": "pwsh -File .github/hooks/discovery-agent-start.ps1", "bash": "pwsh -File .github/hooks/discovery-agent-start.ps1" } ] } }'
    }
}

AfterAll {
    Remove-Module HarnessInventory -Force -ErrorAction SilentlyContinue
}

Describe 'Get-HarnessInventory kind rules' {
    BeforeAll {
        $script:KindInventory = Get-TestInventory -Files $script:KindFixture
    }

    It 'inventories kind <Kind>' -ForEach @(
        @{ Kind = 'instructions'; Expected = @('claude:instructions:CLAUDE.md', 'copilot:instructions:copilot-instructions.md', 'cross-tool:instructions:AGENTS.md') }
        @{ Kind = 'path-scoped-rule'; Expected = @('claude:path-scoped-rule:python', 'copilot:path-scoped-rule:python') }
        @{ Kind = 'skill'; Expected = @('claude:skill:orchestrate', 'codex:skill:orchestrate', 'copilot:skill:orchestrate') }
        @{ Kind = 'skill-frontmatter-field'; Expected = @('claude:skill-frontmatter-field:allowed-tools', 'claude:skill-frontmatter-field:name', 'codex:skill-frontmatter-field:description', 'codex:skill-frontmatter-field:name', 'copilot:skill-frontmatter-field:name') }
        @{ Kind = 'skill-metadata-file'; Expected = @('codex:skill-metadata-file:orchestrate') }
        @{ Kind = 'agent'; Expected = @('claude:agent:atomic-planner', 'codex:agent:orchestrator', 'copilot:agent:planner') }
        @{ Kind = 'subagent-frontmatter-field'; Expected = @('claude:subagent-frontmatter-field:hooks', 'claude:subagent-frontmatter-field:name', 'claude:subagent-frontmatter-field:tools', 'codex:subagent-frontmatter-field:model', 'codex:subagent-frontmatter-field:name', 'copilot:subagent-frontmatter-field:handoffs', 'copilot:subagent-frontmatter-field:name') }
        @{ Kind = 'handoff'; Expected = @('copilot:handoff:planner') }
        @{ Kind = 'prompt'; Expected = @('codex:prompt:review', 'copilot:prompt:commit') }
        @{ Kind = 'hook-registration'; Expected = @('claude:hook-registration:SessionStart//persist-session-id', 'claude:hook-registration:SubagentStop/atomic-planner/validate-planner-output', 'copilot:hook-registration:SubagentStart//discovery-agent-start') }
        @{ Kind = 'permission'; Expected = @('claude:permission:allow', 'claude:permission:deny', 'codex:permission:orchestrator-workspace') }
        @{ Kind = 'setting'; Expected = @('claude:setting:enabledPlugins', 'codex:setting:features') }
        @{ Kind = 'mcp-server'; Expected = @('claude:mcp-server:drm-copilot', 'codex:mcp-server:drm-copilot') }
    ) {
        @($script:KindInventory | Where-Object kind -EQ $Kind | ForEach-Object id) | Should -Be $Expected
    }

    It 'sorts entries ordinally by id' {
        $ids = @($script:KindInventory.id)
        $sorted = [string[]]$ids.Clone()
        [Array]::Sort($sorted, [StringComparer]::Ordinal)
        $ids | Should -Be $sorted
        $ids.IndexOf('claude:agent:atomic-planner') | Should -BeLessThan $ids.IndexOf('cross-tool:instructions:AGENTS.md')
    }

    It 'returns name, source_path and source_pointer fields' {
        $entry = $script:KindInventory | Where-Object id -EQ 'codex:mcp-server:drm-copilot'
        $entry.name | Should -Be 'drm-copilot'
        $entry.source_path | Should -Be '.codex/config.toml'
        $entry.source_pointer | Should -Be '[mcp_servers.drm-copilot]'
    }
}

Describe 'Test-HarnessInventoryPathExcluded exclusion list' {
    It 'excludes group <Group>' -ForEach @(
        @{ Group = 'local-scope settings'; Paths = @('.claude/settings.local.json', '.vscode/settings.json') }
        @{ Group = 'local-scope state'; Paths = @('.claude/agent-memory/x/m.md', '.claude/state/s.json', '.claude/worktrees/w/CLAUDE.md', '.codex/state/s.json', 'artifacts/a.json') }
        @{ Group = 'implementation libraries'; Paths = @('.claude/lib/docs/Invoke-DocsCommand.ps1', '.codex/scripts/helper.ps1') }
        @{ Group = 'bundle copies'; Paths = @('extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md') }
        @{ Group = 'readme files'; Paths = @('.agents/README.md', '.agents/skills/README.md', '.github/skills/README.md') }
        @{ Group = 'skill supporting files'; Paths = @('.claude/skills/mermaid-diagram/references/flow.md', '.agents/skills/orchestrate/references/standard.md', '.claude/skills/cleanup-merged-worktrees/scripts/run.sh') }
    ) {
        foreach ($path in $Paths) { Test-HarnessInventoryPathExcluded -Path $path | Should -BeTrue -Because "$path is in group $Group" }
    }

    It 'keeps the skill metadata file and registered sources' {
        foreach ($path in @('.agents/skills/orchestrate/agents/openai.yaml', '.claude/settings.json', '.claude/skills/orchestrate/SKILL.md')) { Test-HarnessInventoryPathExcluded -Path $path | Should -BeFalse }
    }

    It 'excludes listed files from the inventory itself' {
        $files = @{ '.claude/settings.local.json' = '{ "enabledPlugins": {} }'; '.agents/skills/README.md' = '# readme'; 'artifacts/x.md' = 'x'; '.claude/worktrees/w/CLAUDE.md' = '# w' }
        @(Get-TestInventory -Files $files).Count | Should -Be 0
    }

    It 'does not inventory the settings schema key' {
        $inventory = Get-TestInventory -Files @{ '.claude/settings.json' = (Get-SettingsJson) }
        @($inventory | Where-Object { $_.name -eq '$schema' }).Count | Should -Be 0
        @($inventory.id) | Should -Be @('claude:permission:allow', 'claude:permission:deny')
    }
}

Describe 'Identifier encoding' {
    It 'encodes pipe star caret dollar and parentheses in a hook matcher' {
        $toml = "[[hooks.PreToolUse]]`nmatcher = `"^(Bash|mcp__.*)$`"`n[[hooks.PreToolUse.hooks]]`ntype = `"command`"`ncommand = 'pwsh -File .codex/hooks/validate-bash.ps1'"
        @((Get-TestInventory -Files @{ '.codex/config.toml' = $toml }).id) | Should -Be @('codex:hook-registration:PreToolUse/%5E%28Bash%7Cmcp__.%2A%29%24/validate-bash')
    }

    It 'encodes an absent matcher as an empty component' {
        $settings = Get-SettingsJson -HooksJson ('{ "SessionStart": [ ' + (Get-RegistrationJson -NoMatcher -Command 'pwsh -File .claude/hooks/persist-session-id.ps1') + ' ] }')
        @(Get-TestInventory -Files @{ '.claude/settings.json' = $settings } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id) | Should -Be @('claude:hook-registration:SessionStart//persist-session-id')
    }

    It 'round-trips encoded ids' {
        $components = @('Pre/Tool', '100%', 'a~b:c d', "na$([char]0x00EF)ve-$([char]0x20AC)")
        $id = ConvertTo-HarnessFeatureId -Ecosystem 'claude' -Kind 'hook-registration' -NameComponent $components -SourcePath '.claude/settings.json' -Occurrence 2
        $decoded = ConvertFrom-HarnessFeatureId -Id $id
        $decoded.NameComponent | Should -Be $components
        $decoded.SourcePath | Should -Be '.claude/settings.json'
        (ConvertTo-HarnessFeatureId -Ecosystem $decoded.Ecosystem -Kind $decoded.Kind -NameComponent $decoded.NameComponent -SourcePath $decoded.SourcePath -Occurrence $decoded.Occurrence) | Should -BeExactly $id
    }

    It 'rejects non-canonical ids' {
        foreach ($id in @('claude:setting:a%7cb', 'claude:setting:%41', 'claude:setting:a%7', 'claude:setting:%FF')) {
            { ConvertFrom-HarnessFeatureId -Id $id } | Should -Throw -Because "$id is not canonical"
        }
        (ConvertFrom-HarnessFeatureId -Id 'claude:setting:a%7Cb').NameComponent | Should -Be @('a|b')
    }

    It 'qualifies every member of a cross-source duplicate' {
        $settings = Get-SettingsJson -HooksJson ('{ "SubagentStop": [ ' + (Get-RegistrationJson -Matcher 'atomic-planner' -Command 'pwsh -NoProfile -File .claude/hooks/validate-planner-output.ps1') + ' ], "SessionStart": [ ' + (Get-RegistrationJson -NoMatcher -Command 'pwsh -File .claude/hooks/persist-session-id.ps1') + ' ] }')
        $ids = @(Get-TestInventory -Files @{ '.claude/settings.json' = $settings; '.claude/agents/atomic-planner.md' = $script:AgentFrontmatter } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id)
        $ids | Should -Be @(
            'claude:hook-registration:SessionStart//persist-session-id'
            'claude:hook-registration:SubagentStop/atomic-planner/validate-planner-output~.claude%2Fagents%2Fatomic-planner.md'
            'claude:hook-registration:SubagentStop/atomic-planner/validate-planner-output~.claude%2Fsettings.json'
        )
    }

    It 'numbers same-file duplicates in document order' {
        $registration = Get-RegistrationJson -Matcher 'Bash' -Command 'pwsh -File .claude/hooks/validate-bash.ps1'
        $ids = @(Get-TestInventory -Files @{ '.claude/settings.json' = (Get-SettingsJson -HooksJson "{ `"PreToolUse`": [ $registration, $registration ] }") } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id)
        $ids | Should -Be @('claude:hook-registration:PreToolUse/Bash/validate-bash~.claude%2Fsettings.json~01', 'claude:hook-registration:PreToolUse/Bash/validate-bash~.claude%2Fsettings.json~02')
    }

    It 'numbers only the same-file members of a mixed duplicate group' {
        $registration = Get-RegistrationJson -Matcher 'atomic-planner' -Command 'pwsh -NoProfile -File .claude/hooks/validate-planner-output.ps1'
        $settings = Get-SettingsJson -HooksJson "{ `"SubagentStop`": [ $registration, $registration ] }"
        $ids = @(Get-TestInventory -Files @{ '.claude/settings.json' = $settings; '.claude/agents/atomic-planner.md' = $script:AgentFrontmatter } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id)
        $base = 'claude:hook-registration:SubagentStop/atomic-planner/validate-planner-output'
        $ids | Should -Be @("$base~.claude%2Fagents%2Fatomic-planner.md", "$base~.claude%2Fsettings.json~01", "$base~.claude%2Fsettings.json~02")
    }

    It 'rejects more than 99 same-file members of one group' {
        $registration = Get-RegistrationJson -Matcher 'Bash' -Command 'pwsh -File .claude/hooks/validate-bash.ps1'
        $ninetyNine = @(Get-TestInventory -Files @{ '.claude/settings.json' = (Get-SettingsJson -HooksJson "{ `"PreToolUse`": [ $((@($registration) * 99) -join ', ') ] }") } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id)
        $ninetyNine.Count | Should -Be 99
        $ninetyNine[0] | Should -BeExactly 'claude:hook-registration:PreToolUse/Bash/validate-bash~.claude%2Fsettings.json~01'
        $ninetyNine[98] | Should -BeExactly 'claude:hook-registration:PreToolUse/Bash/validate-bash~.claude%2Fsettings.json~99'
        $hundred = Get-SettingsJson -HooksJson "{ `"PreToolUse`": [ $((@($registration) * 100) -join ', ') ] }"
        { Get-TestInventory -Files @{ '.claude/settings.json' = $hundred } } | Should -Throw -ExpectedMessage '*claude:hook-registration:PreToolUse/Bash/validate-bash*'
    }

    It 'inventories dispatch registry groups and keeps the dispatcher entry' {
        $codexRegistry = '{ "isolation": "in-process", "notes": "n", "hooks": { "PreToolUse": [ { "matcher": "^(apply_patch|Edit|Write)$", "hooks": [ { "type": "command", "command": "pwsh -File .codex/hooks/enforce-evidence-locations.ps1" } ] } ] } }'
        $claudeRegistry = '{ "isolation": "in-process", "hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": "pwsh -File .claude/hooks/validate-bash.ps1" } ] } ] } }'
        $settings = Get-SettingsJson -HooksJson ('{ "PreToolUse": [ ' + (Get-RegistrationJson -Matcher 'Bash|Write' -Command 'pwsh -File .claude/hooks/invoke-pretooluse-dispatch.ps1') + ' ] }')
        $inventory = Get-TestInventory -Files @{ '.codex/hooks/pretooluse-dispatch.json' = $codexRegistry; '.claude/hooks/pretooluse-dispatch.json' = $claudeRegistry; '.claude/settings.json' = $settings }
        $codex = $inventory | Where-Object id -EQ 'codex:hook-registration:PreToolUse/%5E%28apply_patch%7CEdit%7CWrite%29%24/enforce-evidence-locations'
        $codex.source_path | Should -Be '.codex/hooks/pretooluse-dispatch.json'
        ($inventory | Where-Object id -EQ 'claude:hook-registration:PreToolUse/Bash/validate-bash').source_path | Should -Be '.claude/hooks/pretooluse-dispatch.json'
        ($inventory | Where-Object id -EQ 'claude:hook-registration:PreToolUse/Bash%7CWrite/invoke-pretooluse-dispatch').source_path | Should -Be '.claude/settings.json'
        @($inventory | Where-Object { $_.name -in @('isolation', 'notes') }).Count | Should -Be 0
    }

    It 'ignores nested codex config sub-tables and table-scoped keys' {
        $toml = @(
            '[mcp_servers.drm-copilot]', 'command = "npx"', '[mcp_servers.drm-copilot.tools.run_poshqc_test]', 'approval_mode = "approve"',
            '[permissions.orchestrator-workspace]', 'extends = ":workspace"', '[permissions.orchestrator-workspace.network]', 'enabled = true',
            '[permissions.orchestrator-workspace.filesystem.":workspace_roots"]', '"." = "write"', '[features]', 'hooks = true',
            '[[hooks.PreToolUse]]', 'matcher = "Bash"', '[[hooks.PreToolUse.hooks]]', 'command = "pwsh -File .codex/hooks/validate-bash.ps1"'
        ) -join "`n"
        $ids = @((Get-TestInventory -Files @{ '.codex/config.toml' = $toml }).id)
        $ids | Should -Be @('codex:hook-registration:PreToolUse/Bash/validate-bash', 'codex:mcp-server:drm-copilot', 'codex:permission:orchestrator-workspace', 'codex:setting:features')
    }

    It 'inventories a top-level codex bare key as a setting' {
        @((Get-TestInventory -Files @{ '.codex/config.toml' = "default_permissions = `":danger-full-access`"`n[features]`nhooks = true" }).id) | Should -Be @('codex:setting:default_permissions', 'codex:setting:features')
    }

    It 'ignores nested agent frontmatter keys' {
        $ids = @(Get-TestInventory -Files @{ '.claude/agents/atomic-planner.md' = $script:AgentFrontmatter } | Where-Object kind -EQ 'subagent-frontmatter-field' | ForEach-Object name)
        $ids | Should -Be @('hooks', 'name', 'tools')
    }

    It 'falls back to the full command text when no script is named' {
        $settings = Get-SettingsJson -HooksJson ('{ "Stop": [ ' + (Get-RegistrationJson -NoMatcher -Command 'npx tsc --noEmit') + ' ] }')
        $entry = Get-TestInventory -Files @{ '.claude/settings.json' = $settings } | Where-Object kind -EQ 'hook-registration'
        $entry.name | Should -BeExactly 'Stop//npx tsc --noEmit'
        $entry.id | Should -BeExactly 'claude:hook-registration:Stop//npx%20tsc%20--noEmit'
    }

    It 'takes the github hook stem from the powershell field' {
        $json = '{ "hooks": { "PreToolUse": [ { "type": "command", "powershell": "pwsh -File .github/hooks/discovery-pre-tool.ps1", "bash": "sh .github/hooks/discovery-pre-tool-posix.sh" } ] } }'
        @((Get-TestInventory -Files @{ '.github/hooks/discovery.json' = $json }).id) | Should -Be @('copilot:hook-registration:PreToolUse//discovery-pre-tool')
    }

    It 'takes the codex hook stem from command not command_windows' {
        $toml = "[[hooks.PreToolUse]]`nmatcher = `"Bash`"`n[[hooks.PreToolUse.hooks]]`ncommand = 'pwsh -File .codex/hooks/validate-bash.ps1'`ncommand_windows = 'pwsh -File .codex/hooks/validate-bash-windows.ps1'"
        @((Get-TestInventory -Files @{ '.codex/config.toml' = $toml }).id) | Should -Be @('codex:hook-registration:PreToolUse/Bash/validate-bash')
    }

    It 'derives the stem of a sh script' {
        $settings = Get-SettingsJson -HooksJson ('{ "PreToolUse": [ ' + (Get-RegistrationJson -Matcher 'Bash' -Command 'sh .claude/hooks/check-shape.sh') + ' ] }')
        $entry = Get-TestInventory -Files @{ '.claude/settings.json' = $settings } | Where-Object kind -EQ 'hook-registration'
        $entry.name | Should -BeExactly 'PreToolUse/Bash/check-shape'
        $entry.id | Should -BeExactly 'claude:hook-registration:PreToolUse/Bash/check-shape'
    }

    It 'keeps an untrimmed matcher' {
        $hooks = '{ "PreToolUse": [ ' + (Get-RegistrationJson -Matcher ' Bash ' -Command 'pwsh -File .claude/hooks/validate-bash.ps1') + ', ' + (Get-RegistrationJson -Matcher 'Bash' -Command 'pwsh -File .claude/hooks/validate-bash.ps1') + ' ] }'
        $ids = @(Get-TestInventory -Files @{ '.claude/settings.json' = (Get-SettingsJson -HooksJson $hooks) } | Where-Object kind -EQ 'hook-registration' | ForEach-Object id)
        $ids | Should -Be @('claude:hook-registration:PreToolUse/%20Bash%20/validate-bash', 'claude:hook-registration:PreToolUse/Bash/validate-bash')
    }
}
