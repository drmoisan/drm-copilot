# Pester tests for scripts/dev-tools/HookProcessCost.psm1 (issue #1159).
# Every input is an in-memory string; the process starter and timestamp seams are stubs, so no
# test starts a process, writes a file, or reads the clock.

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../scripts/dev-tools/HookProcessCost.psm1') -Force

    $script:ClaudeSettings = @'
{
  "hooks": {
    "SessionStart": [ { "hooks": [ { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/persist-session-id.ps1" } ] } ],
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/a-bash.ps1" }, { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/b-bash.ps1" } ] },
      { "matcher": "Write|Edit", "hooks": [ { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/c-write.ps1" } ] },
      { "matcher": "Bash|Write|Agent|mcp__.*", "hooks": [ { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/d-broad.ps1" } ] },
      { "matcher": "Agent", "hooks": [ { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/e-agent.ps1" } ] }
    ]
  }
}
'@
    $script:CodexConfig = @'
[mcp_servers.x]
command = "npx"

[[hooks.UserPromptSubmit]]

[[hooks.UserPromptSubmit.hooks]]
type = "command"
command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/prompt.ps1"'
timeout = 15

[[hooks.PreToolUse]]
matcher = "^Bash$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/a-bash.ps1"'
command_windows = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/a-bash.ps1"'
timeout = 30

[[hooks.PreToolUse]]
matcher = "^(Edit|Write)$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = "pwsh -NoProfile -File \".codex/hooks/c-write.ps1\""
timeout = 20

[[hooks.PreToolUse]]
matcher = "^(Bash|mcp__.*)$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/d-broad.ps1"'
timeout = 30

[[hooks.SubagentStop]]
matcher = "x"
'@
    $script:ClaudeDispatcherSettings = '{"hooks":{"PreToolUse":[{"matcher":"Bash|Write|Agent|mcp__.*","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/invoke-pretooluse-dispatch.ps1"}]}]}}'
    $script:ClaudeRegistry = '{"isolation":"in-process","notes":[],"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/a-bash.ps1"},{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/b-bash.ps1"}]},{"matcher":"Agent","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/e-agent.ps1"}]}]}}'
    $script:CodexDispatcherConfig = @'
[[hooks.PreToolUse]]
matcher = "^(Bash|apply_patch|Edit|Write|Agent|mcp__.*)$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/invoke-pretooluse-dispatch.ps1"'
command_windows = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/invoke-pretooluse-dispatch.ps1"'
timeout = 60
'@
    $script:CodexRegistry = '{"isolation":"in-process","notes":[],"hooks":{"PreToolUse":[{"matcher":"^(Edit|Write)$","hooks":[{"type":"command","command":"pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)/.codex/hooks/c-write.ps1\"","timeout":30}]}]}}'

    function script:New-Reader {
        param([hashtable] $Files)
        $captured = $Files
        return { param([string] $Path) if ($captured.ContainsKey($Path)) { $captured[$Path] } else { $null } }.GetNewClosure()
    }
}

AfterAll {
    Remove-Module -Name HookProcessCost -Force -ErrorAction SilentlyContinue
}

Describe 'Test-HookCostMatcher' {
    It 'treats a Claude letter-only matcher as an exact list' {
        Test-HookCostMatcher -Runtime claude -Matcher 'Write|Edit' -ToolName 'Edit' | Should -BeTrue
        Test-HookCostMatcher -Runtime claude -Matcher 'Write|Edit' -ToolName 'MultiEdit' | Should -BeFalse
        Test-HookCostMatcher -Runtime claude -Matcher 'Bash' -ToolName 'BashX' | Should -BeFalse
    }

    It 'treats a Claude matcher with regex characters as an unanchored regex' {
        Test-HookCostMatcher -Runtime claude -Matcher 'mcp__.*' -ToolName 'mcp__drm-copilot__x' | Should -BeTrue
        Test-HookCostMatcher -Runtime claude -Matcher 'Bash|mcp__.*' -ToolName 'XBashY' | Should -BeTrue
    }

    It 'admits every tool for an empty or star matcher' {
        Test-HookCostMatcher -Runtime claude -Matcher '' -ToolName 'Anything' | Should -BeTrue
        Test-HookCostMatcher -Runtime codex -Matcher '*' -ToolName 'Anything' | Should -BeTrue
    }

    It 'applies the Codex regex as written and the apply_patch alias' {
        Test-HookCostMatcher -Runtime codex -Matcher '^Bash$' -ToolName 'Bash' | Should -BeTrue
        Test-HookCostMatcher -Runtime codex -Matcher '^(Edit|Write)$' -ToolName 'apply_patch' | Should -BeTrue
        Test-HookCostMatcher -Runtime codex -Matcher '^Bash$' -ToolName 'apply_patch' | Should -BeFalse
        Test-HookCostMatcher -Runtime codex -Matcher '^Bash$' -ToolName 'Agent' | Should -BeFalse
    }
}

Describe 'ConvertFrom-HookCostCodexConfig' {
    It 'reads PreToolUse tables only, in order, with commands and timeouts' {
        $groups = @(ConvertFrom-HookCostCodexConfig -Text $script:CodexConfig)

        $groups.Count | Should -Be 3
        $groups[0].Matcher | Should -Be '^Bash$'
        $groups[0].Hooks[0].Command | Should -BeLike '*/.codex/hooks/a-bash.ps1"'
        $groups[0].Hooks[0].CommandWindows | Should -BeLike '*a-bash.ps1"'
        $groups[0].Hooks[0].Timeout | Should -Be 30
        $groups[0].Hooks[0].Type | Should -Be 'command'
        $groups[1].Hooks[0].Command | Should -Be 'pwsh -NoProfile -File ".codex/hooks/c-write.ps1"'
        $groups[1].Hooks[0].Timeout | Should -Be 20
    }

    It 'returns nothing for text without PreToolUse tables' {
        @(ConvertFrom-HookCostCodexConfig -Text "[[hooks.Stop]]`ncommand = 'x'").Count | Should -Be 0
    }
}

Describe 'Get-HookCostScenario -Source Registration' {
    BeforeAll {
        $reader = New-Reader @{ '.claude/settings.json' = $script:ClaudeSettings; '.codex/config.toml' = $script:CodexConfig }
        $script:Scenarios = @(Get-HookCostScenario -Source Registration -ReadText $reader)
    }

    It 'returns four scenarios per runtime' {
        $script:Scenarios.Count | Should -Be 8
        @($script:Scenarios | Where-Object Runtime -EQ 'claude').Scenario | Should -Be @('bash', 'write', 'agent', 'mcp')
        @($script:Scenarios | Where-Object Runtime -EQ 'codex' | Where-Object Scenario -EQ 'write').ToolName | Should -Be 'apply_patch'
    }

    It 'selects the Claude hooks whose matcher admits the tool, in registration order' {
        $bash = $script:Scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'bash' }
        $bash.Hooks | Should -Be @('.claude/hooks/a-bash.ps1', '.claude/hooks/b-bash.ps1', '.claude/hooks/d-broad.ps1')
        $bash.ProcessCount | Should -Be 3
        $bash.MemberHooks | Should -Be $bash.Hooks
        ($script:Scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'agent' }).ProcessCount | Should -Be 2
        ($script:Scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'mcp' }).Hooks | Should -Be @('.claude/hooks/d-broad.ps1')
    }

    It 'selects the Codex hooks under regex semantics with the apply_patch alias' {
        ($script:Scenarios | Where-Object { $_.Runtime -eq 'codex' -and $_.Scenario -eq 'bash' }).ProcessCount | Should -Be 2
        ($script:Scenarios | Where-Object { $_.Runtime -eq 'codex' -and $_.Scenario -eq 'write' }).Hooks | Should -Be @('.codex/hooks/c-write.ps1')
        ($script:Scenarios | Where-Object { $_.Runtime -eq 'codex' -and $_.Scenario -eq 'agent' }).ProcessCount | Should -Be 0
    }

    It 'builds payload templates that carry the root token and no host path' {
        $write = $script:Scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'write' }
        $payload = $write.PayloadTemplate | ConvertFrom-Json
        $payload.tool_name | Should -Be 'Write'
        $payload.tool_input.file_path | Should -Be 'docs/hook-cost-probe.md'
        $payload.cwd | Should -Be '{{REPOSITORY_ROOT}}'
        $payload.hook_event_name | Should -Be 'PreToolUse'
        (($script:Scenarios | Where-Object { $_.Runtime -eq 'codex' -and $_.Scenario -eq 'write' }).PayloadTemplate | ConvertFrom-Json).tool_input.command | Should -BeLike '*Update File: docs/hook-cost-probe.md*'
    }

    It 'throws when a registration file cannot be read' {
        $reader = New-Reader @{ '.claude/settings.json' = $script:ClaudeSettings }
        { Get-HookCostScenario -Source Registration -ReadText $reader } | Should -Throw '*config.toml*'
    }

    It 'returns no hooks for settings without a PreToolUse block' {
        $reader = New-Reader @{ '.claude/settings.json' = '{"hooks":{}}'; '.codex/config.toml' = '' }
        $all = @(Get-HookCostScenario -Source Registration -ReadText $reader)
        @($all | Where-Object { $_.ProcessCount -ne 0 }).Count | Should -Be 0
    }
}

Describe 'Get-HookCostScenario -Source Dispatcher' {
    It 'counts one dispatcher process per call and records the registry members' {
        $reader = New-Reader @{
            '.claude/settings.json' = $script:ClaudeDispatcherSettings; '.claude/hooks/pretooluse-dispatch.json' = $script:ClaudeRegistry
            '.codex/config.toml' = $script:CodexDispatcherConfig; '.codex/hooks/pretooluse-dispatch.json' = $script:CodexRegistry
        }
        $scenarios = @(Get-HookCostScenario -Source Dispatcher -ReadText $reader)

        @($scenarios | Where-Object { $_.ProcessCount -ne 1 }).Count | Should -Be 0
        ($scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'bash' }).MemberHooks | Should -Be @('.claude/hooks/a-bash.ps1', '.claude/hooks/b-bash.ps1')
        ($scenarios | Where-Object { $_.Runtime -eq 'codex' -and $_.Scenario -eq 'write' }).MemberHooks | Should -Be @('.codex/hooks/c-write.ps1')
        ($scenarios | Where-Object { $_.Runtime -eq 'claude' -and $_.Scenario -eq 'bash' }).Hooks | Should -Be @('.claude/hooks/invoke-pretooluse-dispatch.ps1')
        $scenarios[0].Source | Should -Be 'Dispatcher'
    }

    It 'throws when a registration other than the dispatcher is selected' {
        $reader = New-Reader @{
            '.claude/settings.json' = $script:ClaudeSettings; '.claude/hooks/pretooluse-dispatch.json' = $script:ClaudeRegistry
            '.codex/config.toml' = $script:CodexDispatcherConfig; '.codex/hooks/pretooluse-dispatch.json' = $script:CodexRegistry
        }
        { Get-HookCostScenario -Source Dispatcher -ReadText $reader } | Should -Throw '*invoke-pretooluse-dispatch.ps1*'
    }

    It 'throws when a registry cannot be read' {
        $reader = New-Reader @{ '.claude/settings.json' = $script:ClaudeDispatcherSettings }
        { Get-HookCostScenario -Source Dispatcher -ReadText $reader } | Should -Throw '*pretooluse-dispatch.json*'
    }
}

Describe 'Measure-HookCostSample' {
    It 'records one sample per iteration from the starter and timestamp seams' {
        $scenario = [pscustomobject]@{ Runtime = 'claude'; Scenario = 'bash'; ToolName = 'Bash' }
        $calls = [System.Collections.Generic.List[object]]::new()
        $starter = { param($s) $calls.Add($s); [pscustomobject]@{ ProcessCount = 3; CpuSeconds = 1.5; StartTicks = 0; EndTicks = 2 * [TimeSpan]::TicksPerSecond; ExitCode = 0 } }.GetNewClosure()
        $stamps = [System.Collections.Generic.Queue[string]]::new([string[]]@('t1', 't2'))
        $clock = { $stamps.Dequeue() }.GetNewClosure()

        $samples = @(Measure-HookCostSample -Scenario $scenario -Iterations 2 -StartHookProcess $starter -GetTimestamp $clock)

        $calls.Count | Should -Be 2
        $samples.Count | Should -Be 2
        $samples[0].WallSeconds | Should -Be 2
        $samples[0].CpuSeconds | Should -Be 1.5
        $samples[0].ProcessCount | Should -Be 3
        $samples[1].Iteration | Should -Be 2
        $samples.SampledAt | Should -Be @('t1', 't2')
    }

    It 'throws when the starter returns nothing' {
        $scenario = [pscustomobject]@{ Runtime = 'codex'; Scenario = 'mcp' }
        { Measure-HookCostSample -Scenario $scenario -Iterations 1 -StartHookProcess { $null } -GetTimestamp { 't' } } | Should -Throw '*no result*'
    }
}

Describe 'Get-HookCostSummary' {
    It 'computes median, mean and max with an odd sample count' {
        $samples = @(1.0, 3.0, 2.0) | ForEach-Object { [pscustomobject]@{ Runtime = 'claude'; Scenario = 'bash'; ProcessCount = 12; CpuSeconds = $_; WallSeconds = $_ * 2; ExitCode = 0 } }
        $summary = @(Get-HookCostSummary -Samples $samples)

        $summary.Count | Should -Be 1
        $summary[0].Cpu.Median | Should -Be 2
        $summary[0].Cpu.Mean | Should -Be 2
        $summary[0].Cpu.Max | Should -Be 3
        $summary[0].Wall.Median | Should -Be 4
        $summary[0].ProcessCount | Should -Be 12
        $summary[0].ProcessCountStable | Should -BeTrue
        $summary[0].Samples | Should -Be 3
    }

    It 'averages the two middle values with an even sample count and keeps group order' {
        $samples = @(
            [pscustomobject]@{ Runtime = 'codex'; Scenario = 'write'; ProcessCount = 1; CpuSeconds = 4.0; WallSeconds = 1.0; ExitCode = 0 }
            [pscustomobject]@{ Runtime = 'claude'; Scenario = 'bash'; ProcessCount = 1; CpuSeconds = 1.0; WallSeconds = 1.0; ExitCode = 2 }
            [pscustomobject]@{ Runtime = 'codex'; Scenario = 'write'; ProcessCount = 2; CpuSeconds = 1.0; WallSeconds = 3.0; ExitCode = 1 }
            [pscustomobject]@{ Runtime = 'codex'; Scenario = 'write'; ProcessCount = 1; CpuSeconds = 2.0; WallSeconds = 2.0; ExitCode = 0 }
            [pscustomobject]@{ Runtime = 'codex'; Scenario = 'write'; ProcessCount = 1; CpuSeconds = 3.0; WallSeconds = 4.0; ExitCode = 0 }
        )
        $summary = @(Get-HookCostSummary -Samples $samples)

        $summary[0].Runtime | Should -Be 'codex'
        $summary[0].Cpu.Median | Should -Be 2.5
        $summary[0].Wall.Median | Should -Be 2.5
        $summary[0].ProcessCount | Should -Be 2
        $summary[0].ProcessCountStable | Should -BeFalse
        $summary[0].MaxExitCode | Should -Be 1
        $summary[1].MaxExitCode | Should -Be 2
    }

    It 'returns nothing for no samples' {
        @(Get-HookCostSummary -Samples @()).Count | Should -Be 0
    }
}

Describe 'Format-HookCostReport' {
    BeforeAll {
        $script:Rows = @([pscustomobject]@{
                Runtime = 'claude'; Scenario = 'bash'; Samples = 2; ProcessCount = 12; ProcessCountStable = $true
                Cpu = [pscustomobject]@{ Median = 1.0; Mean = 1.25; Max = 1.5 }; Wall = [pscustomobject]@{ Median = 0.5; Mean = 0.5; Max = 0.75 }; MaxExitCode = 0
            }, [pscustomobject]@{
                Runtime = 'codex'; Scenario = 'write'; Samples = 2; ProcessCount = 2; ProcessCountStable = $false
                Cpu = [pscustomobject]@{ Median = 2.0; Mean = 2.0; Max = 2.0 }; Wall = [pscustomobject]@{ Median = 1.0; Mean = 1.0; Max = 1.0 }; MaxExitCode = 2
            })
        $script:ReportScenarios = @(
            [pscustomobject]@{ Runtime = 'claude'; Scenario = 'bash'; ToolName = 'Bash'; Hooks = @('.claude/hooks/a.ps1'); MemberHooks = @('.claude/hooks/a.ps1', '.claude/hooks/b.ps1'); PayloadTemplate = '{"tool_name":"Bash"}' }
        )
    }

    It 'carries the four evidence fields and the grandchild exclusion statement' {
        $lines = @(Format-HookCostReport -Source Registration -Summary $script:Rows -Scenarios $script:ReportScenarios -Timestamp '2026-11-10T00-00' -Command 'measure' -ExitCode 0 -Iterations 2)

        $lines | Should -Contain 'Timestamp: 2026-11-10T00-00'
        $lines | Should -Contain 'Command: measure'
        $lines | Should -Contain 'EXIT_CODE: 0'
        @($lines | Where-Object { $_ -like 'Output Summary: 2 iteration(s) per scenario; hook processes per call: claude bash=12, codex write=2.*' }).Count | Should -Be 1
        @($lines | Where-Object { $_ -like '*Grandchild processes (git, gh)*excluded*' }).Count | Should -BeGreaterOrEqual 1
    }

    It 'renders one table row per summary row with median/mean/max figures' {
        $lines = @(Format-HookCostReport -Source Registration -Summary $script:Rows -Scenarios $script:ReportScenarios -Timestamp 't' -Command 'c' -ExitCode 0 -Iterations 2)

        $lines | Should -Contain '| claude | bash | `Bash` | 12 | 1.000/1.250/1.500 | 0.500/0.500/0.750 | 0 |'
        $lines | Should -Contain '| codex | write | `` | 2 (varied) | 2.000/2.000/2.000 | 1.000/1.000/1.000 | 2 |'
        $lines | Should -Contain '- claude bash: .claude/hooks/a.ps1'
        $lines | Should -Contain '- claude bash: `{"tool_name":"Bash"}`'
    }

    It 'names the dispatched member count for the dispatcher source' {
        $lines = @(Format-HookCostReport -Source Dispatcher -Summary $script:Rows -Scenarios $script:ReportScenarios -Timestamp 't' -Command 'c' -ExitCode 1 -Iterations 2)

        $lines[0] | Should -Be '# Hook process cost report (-Source Dispatcher)'
        $lines | Should -Contain 'EXIT_CODE: 1'
        $lines | Should -Contain '- claude bash: .claude/hooks/a.ps1 (dispatched members: 2)'
    }
}

Describe 'Resolve-HookCostPayload' {
    It 'replaces the root token with a forward-slash, JSON-escaped root' {
        $resolved = Resolve-HookCostPayload -PayloadTemplate '{"cwd":"{{REPOSITORY_ROOT}}"}' -RepositoryRoot 'base\repo\a"b'
        ($resolved | ConvertFrom-Json).cwd | Should -Be 'base/repo/a"b'
    }
}
