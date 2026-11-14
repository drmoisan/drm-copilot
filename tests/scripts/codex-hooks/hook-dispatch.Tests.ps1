#Requires -Version 7.0
<#
.SYNOPSIS
    Unit tests for the Codex dispatcher helpers in .codex/hooks/hook-dispatch.ps1 (issue #1159).

.DESCRIPTION
    Mirrors tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1 and HookDispatchRunner.Tests.ps1
    for Codex: regex matchers with the apply_patch alias, result normalization, combination, registry
    validation, and the runner through its seams. Inputs are in-memory strings; two cases run the
    committed fixture tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1. No file is written.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.codex/hooks/hook-dispatch.ps1')
    $script:FixtureHook = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1')).ProviderPath
    $script:Payload = '{"tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch"}}'
    $script:AllExist = { param([string] $Path) $null -ne $Path }
    $script:NoneExist = { param([string] $Path) $false -and $Path }

    function Get-TestResult {
        param([AllowNull()] [string] $Decision, [AllowNull()] [string] $Reason, [AllowNull()] [string] $Context)
        [pscustomobject]@{ Decision = $Decision; Reason = $Reason; AdditionalContext = $Context; Error = $null }
    }

    function Get-TestRegistry {
        param([string[]] $Leaf, [string] $Isolation = 'in-process', [string] $Matcher = '^(apply_patch|Edit|Write)$', [string] $Directory = 'hooks')
        $hooks = foreach ($name in $Leaf) { [pscustomobject]@{ Type = 'command'; Command = "pwsh -NoProfile -File `"`$(git rev-parse --show-toplevel)/.codex/hooks/$name`""; Leaf = $name; Path = "$Directory/$name"; Timeout = 30 } }
        [pscustomobject]@{ IsValid = $true; Reason = $null; Isolation = $Isolation; Notes = @(); Groups = @([pscustomobject]@{ Matcher = $Matcher; Hooks = @($hooks) }) }
    }
}

Describe 'Test-CodexHookDispatchMatcher' {
    It 'evaluates the matcher as a regular expression as written' {
        Test-CodexHookDispatchMatcher -Matcher '^Bash$' -ToolName 'Bash' | Should -BeTrue
        Test-CodexHookDispatchMatcher -Matcher '^Bash$' -ToolName 'BashX' | Should -BeFalse
        Test-CodexHookDispatchMatcher -Matcher '^(Bash|mcp__.*)$' -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' | Should -BeTrue
    }

    It 'admits apply_patch when the matcher admits Edit or Write' {
        Test-CodexHookDispatchMatcher -Matcher '^(Edit|Write)$' -ToolName 'apply_patch' | Should -BeTrue
        Test-CodexHookDispatchMatcher -Matcher '^Write$' -ToolName 'apply_patch' | Should -BeTrue
        Test-CodexHookDispatchMatcher -Matcher '^Bash$' -ToolName 'apply_patch' | Should -BeFalse
    }

    It 'admits every tool for an empty or star matcher and nothing for an invalid regex' {
        Test-CodexHookDispatchMatcher -Matcher '' -ToolName 'Agent' | Should -BeTrue
        Test-CodexHookDispatchMatcher -Matcher '*' -ToolName 'Agent' | Should -BeTrue
        Test-CodexHookDispatchMatcher -Matcher '(' -ToolName 'Agent' | Should -BeFalse
    }
}

Describe 'Get-CodexHookDispatchToolName' {
    It 'returns the tool name or an empty string' {
        Get-CodexHookDispatchToolName -PayloadText $script:Payload | Should -Be 'apply_patch'
        Get-CodexHookDispatchToolName -PayloadText '' | Should -Be ''
        Get-CodexHookDispatchToolName -PayloadText '{not-json' | Should -Be ''
        Get-CodexHookDispatchToolName -PayloadText '[1]' | Should -Be ''
    }
}

Describe 'ConvertTo-CodexHookDispatchResult' {
    It 'maps exit 2 to deny with the stderr reason, or the JSON reason when stderr is empty' {
        (ConvertTo-CodexHookDispatchResult -ExitCode 2 -Stdout '' -Stderr 'GATE_BLOCKED: e').Reason | Should -Be 'GATE_BLOCKED: e'
        $r = ConvertTo-CodexHookDispatchResult -ExitCode 2 -Stdout '{"reason":"JSON_BLOCKED"}' -Stderr ''
        $r.Decision | Should -Be 'deny'
        $r.Reason | Should -Be 'JSON_BLOCKED'
    }

    It 'maps exit 0 JSON decisions, legacy decisions and additionalContext' {
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '{"hookSpecificOutput":{"permissionDecision":"ask","permissionDecisionReason":"Q"}}' -Stderr '').Decision | Should -Be 'ask'
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '{"decision":"block","reason":"L"}' -Stderr '').Decision | Should -Be 'deny'
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '{"decision":"approve"}' -Stderr '').Decision | Should -Be 'allow'
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '{"hookSpecificOutput":{"additionalContext":"c"}}' -Stderr '').AdditionalContext | Should -Be 'c'
    }

    It 'maps empty stdout, other exit codes, invalid JSON and terminating errors to no decision' {
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '' -Stderr '').Decision | Should -BeNullOrEmpty
        (ConvertTo-CodexHookDispatchResult -ExitCode 1 -Stdout '{"decision":"block"}' -Stderr '').Error | Should -Be 'NonBlockingExit'
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout 'text' -Stderr '').Error | Should -Be 'InvalidJson'
        (ConvertTo-CodexHookDispatchResult -ExitCode 0 -Stdout '{"decision":"block"}' -Stderr '' -TerminatingError).Error | Should -Be 'TerminatingError'
    }
}

Describe 'Join-CodexHookDispatchDecision' {
    It 'orders precedence deny over defer over ask over allow over none' {
        (Join-CodexHookDispatchDecision -Result @((Get-TestResult 'allow'), (Get-TestResult 'deny'), (Get-TestResult 'ask'))).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        (Join-CodexHookDispatchDecision -Result @((Get-TestResult 'ask'), (Get-TestResult 'defer'))).hookSpecificOutput.permissionDecision | Should -Be 'defer'
        (Join-CodexHookDispatchDecision -Result @((Get-TestResult 'allow'), (Get-TestResult 'ask'))).hookSpecificOutput.permissionDecision | Should -Be 'ask'
        (Join-CodexHookDispatchDecision -Result @((Get-TestResult $null), (Get-TestResult 'allow'))).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'joins deny reasons in registry order and concatenates additionalContext as JSON' {
        $joined = Join-CodexHookDispatchDecision -Result @((Get-TestResult -Decision 'deny' -Reason 'A' -Context 'c1'), (Get-TestResult -Decision 'deny' -Reason 'B' -Context 'c2'))
        $joined | ConvertTo-Json -Compress -Depth 5 | Should -BeExactly '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"A\nB","additionalContext":"c1\nc2"}}'
    }

    It 'returns nothing when no hook decides and none adds context' {
        Join-CodexHookDispatchDecision -Result @((Get-TestResult $null)) | Should -BeNullOrEmpty
    }
}

Describe 'Read-CodexHookDispatchRegistry' {
    It 'parses the Codex command shape with its timeout and defaults isolation to per-process' {
        $text = '{"hooks":{"PreToolUse":[{"matcher":"^Bash$","hooks":[{"type":"command","command":"pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)/.codex/hooks/validate-bash.ps1\"","command_windows":"x","timeout":30}]}]}}'
        $registry = Read-CodexHookDispatchRegistry -RegistryText $text -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.IsValid | Should -BeTrue
        $registry.Isolation | Should -Be 'per-process'
        $registry.Groups[0].Hooks[0].Leaf | Should -Be 'validate-bash.ps1'
        $registry.Groups[0].Hooks[0].Timeout | Should -Be 30
    }

    It 'blocks a <Case> registry with HOOK_DISPATCH_BLOCKED' -ForEach @(
        @{ Case = 'missing'; Text = $null }
        @{ Case = 'non-JSON'; Text = '{x' }
        @{ Case = 'non-object'; Text = '[1]' }
        @{ Case = 'bad-isolation'; Text = '{"isolation":"x","hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'bad-notes'; Text = '{"notes":[2],"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'no-groups'; Text = '{"hooks":{"PreToolUse":[]}}' }
        @{ Case = 'non-object-group'; Text = '{"hooks":{"PreToolUse":[1]}}' }
        @{ Case = 'non-string-matcher'; Text = '{"hooks":{"PreToolUse":[{"matcher":1,"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'hookless-group'; Text = '{"hooks":{"PreToolUse":[{"hooks":[]}]}}' }
        @{ Case = 'non-command-hook'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"x","command":"a.ps1"}]}]}}' }
        @{ Case = 'non-script-command'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"pwsh -Command 1"}]}]}}' }
    ) {
        $registry = Read-CodexHookDispatchRegistry -RegistryText $Text -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.IsValid | Should -BeFalse
        $registry.Reason.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *'
    }

    It 'blocks a registry hook that does not resolve to a hooks-folder file' {
        $text = '{"isolation":"in-process","hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"pwsh -File .codex/hooks/gone.ps1"}]}]}}'
        (Read-CodexHookDispatchRegistry -RegistryText $text -HooksDirectory 'hooks' -TestPath $script:NoneExist).Reason.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*gone.ps1*'
    }

    It 'rejects an unvalidated leaf at resolution time' {
        { Resolve-CodexHookDispatchScriptPath -Hook ([pscustomobject]@{ Leaf = 'X.ps1'; Path = 'x' }) } | Should -Throw '*HOOK_DISPATCH_BLOCKED*'
    }
}

Describe 'Invoke-CodexHookDispatchRunner' {
    BeforeEach {
        $script:ConsoleIn = [Console]::In; $script:ConsoleOut = [Console]::Out; $script:ConsoleError = [Console]::Error
        $script:Location = (Get-Location).ProviderPath
    }

    AfterEach {
        [Console]::SetIn($script:ConsoleIn); [Console]::SetOut($script:ConsoleOut); [Console]::SetError($script:ConsoleError)
        Set-Location -LiteralPath $script:Location
    }

    It 'runs every later hook when the first hook denies' {
        $invoked = [System.Collections.Generic.List[string]]::new()
        $invoker = { param([string] $Path) $invoked.Add("$Path=$([Console]::In.ReadToEnd().Length)"); if ($Path -like '*first.ps1') { [Console]::Error.WriteLine('FIRST_BLOCKED'); Set-Variable -Name LASTEXITCODE -Scope Global -Value 2 } }.GetNewClosure()
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'first.ps1', 'second.ps1') -ToolName 'apply_patch' -InvokeScript $invoker)
        @($invoked) | Should -Be @("hooks/first.ps1=$($script:Payload.Length)", "hooks/second.ps1=$($script:Payload.Length)")
        $results[0].Decision | Should -Be 'deny'
        $results[0].Reason | Should -Be 'FIRST_BLOCKED'
    }

    It 'captures stdout written through Console.Out as the hook stdout' {
        $testWriter = [System.IO.StringWriter]::new()
        [Console]::SetOut($testWriter)
        $invoker = { param([string] $Path) [Console]::Out.WriteLine('{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"OUT_BLOCKED"}}'); $null = $Path }
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'out.ps1') -ToolName 'apply_patch' -InvokeScript $invoker)
        [Console]::SetOut($script:ConsoleOut)
        $results[0].Reason | Should -Be 'OUT_BLOCKED'
        $testWriter.ToString() | Should -BeNullOrEmpty
    }

    It 'maps a hook that ends without exit to exit code 0' {
        $invoker = { param([string] $Path) Write-Output '{"hookSpecificOutput":{"permissionDecision":"allow"}}'; Write-Warning 'w'; Write-Error 'e' -ErrorAction Continue; $null = $Path }
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'noexit.ps1') -ToolName 'apply_patch' -InvokeScript $invoker)
        $results[0].ExitCode | Should -Be 0
        $results[0].Stderr | Should -BeLike 'e*'
        $results[0].Error | Should -Be 'InvalidJson'
    }

    It 'maps a terminating error to a non-blocking error' {
        $invoked = [System.Collections.Generic.List[string]]::new()
        $invoker = { param([string] $Path) $invoked.Add($Path); if ($Path -like '*throws.ps1') { throw 'hook failed' } }.GetNewClosure()
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'throws.ps1', 'later.ps1') -ToolName 'apply_patch' -InvokeScript $invoker)
        $results[0].Error | Should -Be 'TerminatingError'
        $results[0].Decision | Should -BeNullOrEmpty
        $invoked.Count | Should -Be 2
    }

    It 'restores stdin, error writer, output writer and location after a hook that throws' {
        $inBefore = [Console]::In; $errorBefore = [Console]::Error; $outBefore = [Console]::Out; $locationBefore = (Get-Location).ProviderPath
        $elsewhere = Split-Path -Path $script:FixtureHook -Parent
        $invoker = { param([string] $Path) Set-Location -LiteralPath $elsewhere; [Console]::SetError([System.IO.StringWriter]::new()); throw "boom $Path" }.GetNewClosure()
        $null = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'throws.ps1') -ToolName 'apply_patch' -InvokeScript $invoker)
        [object]::ReferenceEquals([Console]::In, $inBefore) | Should -BeTrue
        [object]::ReferenceEquals([Console]::Error, $errorBefore) | Should -BeTrue
        [object]::ReferenceEquals([Console]::Out, $outBefore) | Should -BeTrue
        (Get-Location).ProviderPath | Should -Be $locationBefore
    }

    It 'selects no hook for a tool name no group admits' {
        @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'a.ps1' -Matcher '^Bash$') -ToolName 'Agent' -InvokeScript { param([string] $Path) throw $Path }).Count | Should -Be 0
    }

    It 'runs each hook as a child process when isolation is absent' {
        $started = [System.Collections.Generic.List[string]]::new()
        $starter = { param([string] $Path, [string] $PayloadText) $started.Add($Path); [pscustomobject]@{ ExitCode = 0; Stdout = '{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"C"}}'; Stderr = $PayloadText.Substring(0, 0) } }.GetNewClosure()
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'a.ps1', 'b.ps1' -Isolation 'per-process') -ToolName 'apply_patch' -StartProcess $starter)
        @($started) | Should -Be @('hooks/a.ps1', 'hooks/b.ps1')
        @($results | ForEach-Object Decision) | Should -Be @('deny', 'deny')
    }

    It 'invokes the resolved hook script with the default call and reads its exit code' {
        $registry = Get-TestRegistry -Leaf 'stdin-exit-hook.ps1' -Directory (Split-Path -Path $script:FixtureHook -Parent)
        $results = @(Invoke-CodexHookDispatchRunner -PayloadText '{"tool_name":"apply_patch","note":"deny"}' -Registry $registry -ToolName 'apply_patch')
        $results[0].ExitCode | Should -Be 2
        $results[0].Stdout.Trim() | Should -Be '41'
    }

    It 'starts pwsh -NoProfile -File with the payload on stdin through the default process seam' -Tag 'Integration' {
        $result = Invoke-CodexHookDispatchChildProcess -Path $script:FixtureHook -PayloadText 'x'
        $result.ExitCode | Should -Be 0
        $result.Stdout.Trim() | Should -Be '1'
    }
}
