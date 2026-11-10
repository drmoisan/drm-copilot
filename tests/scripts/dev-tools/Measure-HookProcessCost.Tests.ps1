# Pester tests for scripts/dev-tools/Measure-HookProcessCost.ps1 (issue #1159).
# The script is dot-sourced, which defines its functions and runs nothing. Invoke-MeasureHookProcessCost
# is driven through stub reader, process-starter, clock and writer seams with in-memory data. One
# integration case runs Start-HookCostProcessSet against the committed fixture hook
# tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1; no test writes a file.

BeforeAll {
    $script:ScriptPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../scripts/dev-tools/Measure-HookProcessCost.ps1')).ProviderPath
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).ProviderPath
    . $script:ScriptPath

    $script:Files = @{
        '.claude/settings.json' = '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/a.ps1"},{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/b.ps1"}]},{"matcher":"Agent","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/c.ps1"}]}]}}'
        '.codex/config.toml'    = "[[hooks.PreToolUse]]`nmatcher = `"^Bash`$`"`n`n[[hooks.PreToolUse.hooks]]`ntype = `"command`"`ncommand = 'pwsh -NoProfile -File `".codex/hooks/a.ps1`"'`ntimeout = 30`n"
    }
}

AfterAll {
    Remove-Module -Name HookProcessCost -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-MeasureHookProcessCost' {
    BeforeEach {
        $files = $script:Files
        $script:Reader = { param([string] $Path) if ($files.ContainsKey($Path)) { $files[$Path] } else { $null } }.GetNewClosure()
        $script:Started = [System.Collections.Generic.List[object]]::new()
        $started = $script:Started
        $script:Starter = { param($Scenario) $started.Add($Scenario); [pscustomobject]@{ ProcessCount = @($Scenario.Hooks).Count; CpuSeconds = 0.5; StartTicks = 0; EndTicks = [TimeSpan]::TicksPerSecond; ExitCode = 0 } }.GetNewClosure()
        $script:Written = [System.Collections.Generic.List[object]]::new()
        $written = $script:Written
        $script:Writer = { param([string] $Path, [string[]] $Lines) $written.Add([pscustomobject]@{ Path = $Path; Lines = $Lines }) }.GetNewClosure()
    }

    It 'samples every scenario of both runtimes and returns the report lines' {
        $lines = @(Invoke-MeasureHookProcessCost -Source Registration -Iterations 2 -RepositoryRoot 'repo' -ReadText $script:Reader -StartHookProcess $script:Starter -GetTimestamp { '2026-11-10T00-00' } -WriteReport $script:Writer)

        $script:Started.Count | Should -Be 16
        $lines | Should -Contain 'Timestamp: 2026-11-10T00-00'
        $lines | Should -Contain 'Command: pwsh -NoProfile -File scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Registration -Iterations 2'
        $lines | Should -Contain 'EXIT_CODE: 0'
        $lines | Should -Contain '| claude | bash | `Bash` | 2 | 0.500/0.500/0.500 | 1.000/1.000/1.000 | 0 |'
        $lines | Should -Contain '| codex | bash | `Bash` | 1 | 0.500/0.500/0.500 | 1.000/1.000/1.000 | 0 |'
        $script:Written.Count | Should -Be 0
    }

    It 'passes the report to the writer when an output path is given' {
        $lines = @(Invoke-MeasureHookProcessCost -Source Registration -Iterations 1 -RepositoryRoot 'repo' -OutputPath 'out.md' -ReadText $script:Reader -StartHookProcess $script:Starter -GetTimestamp { 't' } -WriteReport $script:Writer)

        $script:Written.Count | Should -Be 1
        $script:Written[0].Path | Should -Be 'out.md'
        $script:Written[0].Lines | Should -Be $lines
    }

    It 'propagates a scenario derivation failure' {
        # The in-memory files hold no registry, so the dispatcher source cannot derive its scenarios.
        { Invoke-MeasureHookProcessCost -Source Dispatcher -Iterations 1 -RepositoryRoot 'repo' -ReadText $script:Reader -StartHookProcess $script:Starter -GetTimestamp { 't' } -WriteReport $script:Writer } | Should -Throw '*pretooluse-dispatch.json*'
        $script:Started.Count | Should -Be 0
    }

    It 'uses the default reader against the repository root' {
        $lines = @(Invoke-MeasureHookProcessCost -Source Registration -Iterations 1 -RepositoryRoot $script:RepositoryRoot -StartHookProcess $script:Starter -GetTimestamp { 't' } -WriteReport $script:Writer)

        @($lines | Where-Object { $_ -like '| claude | bash |*' }).Count | Should -Be 1
        $script:Started.Count | Should -Be 8
    }
}

Describe 'Start-HookCostProcessSet' -Tag 'Integration' {
    It 'starts every hook concurrently with the payload on stdin and reports count, CPU, wall and max exit code' {
        $hook = 'tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1'
        $allow = [pscustomobject]@{ Hooks = @($hook, $hook); PayloadTemplate = '{"cwd":"{{REPOSITORY_ROOT}}","note":"ok"}' }
        $deny = [pscustomobject]@{ Hooks = @($hook); PayloadTemplate = '{"note":"deny"}' }

        $allowResult = Start-HookCostProcessSet -Scenario $allow -RepositoryRoot $script:RepositoryRoot
        $denyResult = Start-HookCostProcessSet -Scenario $deny -RepositoryRoot $script:RepositoryRoot

        $allowResult.ProcessCount | Should -Be 2
        $allowResult.ExitCode | Should -Be 0
        $allowResult.CpuSeconds | Should -BeGreaterThan 0
        $allowResult.EndTicks | Should -BeGreaterThan $allowResult.StartTicks
        $denyResult.ProcessCount | Should -Be 1
        $denyResult.ExitCode | Should -Be 2
    }

    It 'returns zero processes for a scenario without hooks' {
        $result = Start-HookCostProcessSet -Scenario ([pscustomobject]@{ Hooks = @(); PayloadTemplate = '{}' }) -RepositoryRoot $script:RepositoryRoot

        $result.ProcessCount | Should -Be 0
        $result.CpuSeconds | Should -Be 0
    }
}
