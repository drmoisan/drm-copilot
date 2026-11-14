#Requires -Version 7.0
<#
.SYNOPSIS
    Unit tests for .claude/lib/hook-dispatch/HookDispatch.psm1 (issue #1159).

.DESCRIPTION
    Matcher classes, payload tool-name extraction, per-hook result normalization (spec D4), decision
    combination (spec D4), and registry validation (spec D8). Every input is an in-memory string and
    the file-existence question is answered by a stub seam; no file is read or written.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../../.claude/lib/hook-dispatch/HookDispatch.psm1')).ProviderPath
    Import-Module -Name $script:ModulePath -Force

    function Get-TestResult {
        param([AllowNull()] [string] $Decision, [AllowNull()] [string] $Reason, [AllowNull()] [string] $Context)
        [pscustomobject]@{ Decision = $Decision; Reason = $Reason; AdditionalContext = $Context; Error = $null }
    }

    $script:AllExist = { param([string] $Path) $null -ne $Path }
    $script:NoneExist = { param([string] $Path) $false -and $Path }
    $script:ValidRegistry = '{"isolation":"in-process","notes":["n1"],"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/validate-bash.ps1"},{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-x.ps1"}]},{"matcher":"Write|Edit","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-y.ps1"}]}]}}'
}

AfterAll {
    Remove-Module -Name HookDispatch -Force -ErrorAction SilentlyContinue
}

Describe 'Test-HookDispatchMatcher' {
    It 'admits every tool for an empty matcher or a star matcher' {
        Test-HookDispatchMatcher -Matcher '' -ToolName 'Bash' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher $null -ToolName 'mcp__x__y' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher '*' -ToolName 'Agent' | Should -BeTrue
    }

    It 'treats a plain name as an exact, case-sensitive match' {
        Test-HookDispatchMatcher -Matcher 'Bash' -ToolName 'Bash' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher 'Bash' -ToolName 'BashOutput' | Should -BeFalse
        Test-HookDispatchMatcher -Matcher 'Bash' -ToolName 'bash' | Should -BeFalse
    }

    It 'treats a pipe or comma list as an exact list of names' {
        Test-HookDispatchMatcher -Matcher 'Write|Edit' -ToolName 'Edit' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher 'Write, Edit' -ToolName 'Write' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher 'Write|Edit' -ToolName 'MultiEdit' | Should -BeFalse
    }

    It 'treats any other matcher as an unanchored regular expression' {
        Test-HookDispatchMatcher -Matcher 'mcp__.*' -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher 'Bash|mcp__.*' -ToolName 'xBashx' | Should -BeTrue
        Test-HookDispatchMatcher -Matcher '^Agent$' -ToolName 'Agents' | Should -BeFalse
    }

    It 'admits nothing for an invalid regular expression' {
        Test-HookDispatchMatcher -Matcher 'Bash(' -ToolName 'Bash(' | Should -BeFalse
    }
}

Describe 'Get-HookDispatchToolName' {
    It 'returns the tool_name of a payload' {
        Get-HookDispatchToolName -PayloadText '{"tool_name":"Bash","tool_input":{}}' | Should -Be 'Bash'
    }

    It 'returns an empty string for empty, invalid, non-object or tool-less payloads' {
        Get-HookDispatchToolName -PayloadText '' | Should -Be ''
        Get-HookDispatchToolName -PayloadText '{not-json' | Should -Be ''
        Get-HookDispatchToolName -PayloadText '[1,2]' | Should -Be ''
        Get-HookDispatchToolName -PayloadText '{"tool_input":{}}' | Should -Be ''
    }
}

Describe 'ConvertTo-HookDispatchResult' {
    It 'maps exit 2 to deny with the stderr reason' {
        $r = ConvertTo-HookDispatchResult -ExitCode 2 -Stdout '' -Stderr "GATE_BLOCKED: no`n"
        $r.Decision | Should -Be 'deny'
        $r.Reason | Should -Be 'GATE_BLOCKED: no'
    }

    It 'maps exit 2 with empty stderr to deny with the JSON reason' {
        $r = ConvertTo-HookDispatchResult -ExitCode 2 -Stdout '{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"JSON_BLOCKED: x"}}' -Stderr ''
        $r.Decision | Should -Be 'deny'
        $r.Reason | Should -Be 'JSON_BLOCKED: x'
    }

    It 'maps exit 0 with a JSON permissionDecision to that decision and reason' {
        foreach ($decision in @('deny', 'defer', 'ask', 'allow')) {
            $r = ConvertTo-HookDispatchResult -ExitCode 0 -Stdout "{`"hookSpecificOutput`":{`"permissionDecision`":`"$decision`",`"permissionDecisionReason`":`"R`"}}" -Stderr ''
            $r.Decision | Should -Be $decision
            $r.Reason | Should -Be 'R'
        }
    }

    It 'maps the legacy block and approve decisions' {
        (ConvertTo-HookDispatchResult -ExitCode 0 -Stdout '{"decision":"block","reason":"L"}' -Stderr '').Decision | Should -Be 'deny'
        (ConvertTo-HookDispatchResult -ExitCode 0 -Stdout '{"decision":"block","reason":"L"}' -Stderr '').Reason | Should -Be 'L'
        (ConvertTo-HookDispatchResult -ExitCode 0 -Stdout '{"decision":"approve"}' -Stderr '').Decision | Should -Be 'allow'
    }

    It 'maps exit 0 with empty stdout to no decision' {
        $r = ConvertTo-HookDispatchResult -ExitCode 0 -Stdout "  `n" -Stderr 'noise'
        $r.Decision | Should -BeNullOrEmpty
        $r.Error | Should -BeNullOrEmpty
    }

    It 'maps another exit code to no decision as a non-blocking error' {
        $r = ConvertTo-HookDispatchResult -ExitCode 1 -Stdout '{"hookSpecificOutput":{"permissionDecision":"deny"}}' -Stderr 'boom'
        $r.Decision | Should -BeNullOrEmpty
        $r.Error | Should -Be 'NonBlockingExit'
    }

    It 'maps invalid JSON at exit 0 to no decision' {
        $r = ConvertTo-HookDispatchResult -ExitCode 0 -Stdout 'WARNING: text' -Stderr ''
        $r.Decision | Should -BeNullOrEmpty
        $r.Error | Should -Be 'InvalidJson'
    }

    It 'maps a terminating error to no decision' {
        $r = ConvertTo-HookDispatchResult -ExitCode 0 -Stdout '{"hookSpecificOutput":{"permissionDecision":"deny"}}' -Stderr '' -TerminatingError
        $r.Decision | Should -BeNullOrEmpty
        $r.Error | Should -Be 'TerminatingError'
    }

    It 'keeps additionalContext and ignores an unknown decision value' {
        $r = ConvertTo-HookDispatchResult -ExitCode 0 -Stdout '{"hookSpecificOutput":{"permissionDecision":"maybe","additionalContext":"ctx"}}' -Stderr ''
        $r.Decision | Should -BeNullOrEmpty
        $r.AdditionalContext | Should -Be 'ctx'
    }
}

Describe 'Join-HookDispatchDecision' {
    It 'orders precedence deny over defer over ask over allow over none' {
        (Join-HookDispatchDecision -Result @((Get-TestResult 'allow'), (Get-TestResult 'ask'), (Get-TestResult 'defer'), (Get-TestResult 'deny'), (Get-TestResult $null))).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        (Join-HookDispatchDecision -Result @((Get-TestResult 'allow'), (Get-TestResult 'defer'), (Get-TestResult 'ask'))).hookSpecificOutput.permissionDecision | Should -Be 'defer'
        (Join-HookDispatchDecision -Result @((Get-TestResult 'allow'), (Get-TestResult 'ask'))).hookSpecificOutput.permissionDecision | Should -Be 'ask'
    }

    It 'emits allow when allow is the strongest decision' {
        $joined = Join-HookDispatchDecision -Result @((Get-TestResult $null), (Get-TestResult 'allow' 'ok'))
        $joined.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $joined.hookSpecificOutput.permissionDecisionReason | Should -Be 'ok'
        $joined.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
    }

    It 'joins deny reasons in registry order by a line feed' {
        $joined = Join-HookDispatchDecision -Result @((Get-TestResult 'deny' 'A_BLOCKED: first'), (Get-TestResult 'allow' 'skip'), (Get-TestResult 'deny' 'B_BLOCKED: second'))
        $joined.hookSpecificOutput.permissionDecisionReason | Should -BeExactly "A_BLOCKED: first`nB_BLOCKED: second"
    }

    It 'concatenates additionalContext values in registry order' {
        $joined = Join-HookDispatchDecision -Result @((Get-TestResult -Context 'one'), (Get-TestResult -Decision 'allow' -Context 'two'))
        $joined.hookSpecificOutput.additionalContext | Should -BeExactly "one`ntwo"
    }

    It 'emits only additionalContext when no hook decides' {
        $joined = Join-HookDispatchDecision -Result @((Get-TestResult -Context 'ctx'))
        $joined.hookSpecificOutput.Contains('permissionDecision') | Should -BeFalse
        $joined.hookSpecificOutput.additionalContext | Should -Be 'ctx'
    }

    It 'returns nothing when no hook decides and none adds context' {
        Join-HookDispatchDecision -Result @((Get-TestResult $null), (Get-TestResult $null)) | Should -BeNullOrEmpty
        Join-HookDispatchDecision -Result @() | Should -BeNullOrEmpty
    }

    It 'renders as compact JSON' {
        $json = Join-HookDispatchDecision -Result @((Get-TestResult 'deny' 'X')) | ConvertTo-Json -Compress -Depth 5
        $json | Should -BeExactly '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"X"}}'
    }
}

Describe 'Read-HookDispatchRegistry' {
    It 'parses groups, hooks, isolation and notes in registry order' {
        $registry = Read-HookDispatchRegistry -RegistryText $script:ValidRegistry -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.IsValid | Should -BeTrue
        $registry.Isolation | Should -Be 'in-process'
        $registry.Notes | Should -Be @('n1')
        @($registry.Groups).Count | Should -Be 2
        @($registry.Groups[0].Hooks | ForEach-Object Leaf) | Should -Be @('validate-bash.ps1', 'enforce-x.ps1')
        $registry.Groups[0].Hooks[0].Path | Should -Be (Join-Path 'hooks' 'validate-bash.ps1')
    }

    It 'defaults an absent isolation field to per-process' {
        $registry = Read-HookDispatchRegistry -RegistryText '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/a.ps1"}]}]}}' -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.IsValid | Should -BeTrue
        $registry.Isolation | Should -Be 'per-process'
    }

    It 'reads the script leaf of a Codex command and keeps its timeout' {
        $text = '{"hooks":{"PreToolUse":[{"matcher":"^Bash$","hooks":[{"type":"command","command":"pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)/.codex/hooks/validate-bash.ps1\"","timeout":30}]}]}}'
        $registry = Read-HookDispatchRegistry -RegistryText $text -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.Groups[0].Hooks[0].Leaf | Should -Be 'validate-bash.ps1'
        $registry.Groups[0].Hooks[0].Timeout | Should -Be 30
    }

    It 'blocks a <Case> registry with HOOK_DISPATCH_BLOCKED' -ForEach @(
        @{ Case = 'missing'; Text = $null }
        @{ Case = 'empty'; Text = '  ' }
        @{ Case = 'non-JSON'; Text = '{not-json' }
        @{ Case = 'non-object'; Text = '[1]' }
        @{ Case = 'bad-isolation'; Text = '{"isolation":"shared","hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'bad-notes'; Text = '{"notes":[1],"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'no-groups'; Text = '{"hooks":{"PreToolUse":[]}}' }
        @{ Case = 'no-hooks-key'; Text = '{"isolation":"in-process"}' }
        @{ Case = 'non-object-group'; Text = '{"hooks":{"PreToolUse":["x"]}}' }
        @{ Case = 'non-string-matcher'; Text = '{"hooks":{"PreToolUse":[{"matcher":5,"hooks":[{"type":"command","command":"a.ps1"}]}]}}' }
        @{ Case = 'hookless-group'; Text = '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[]}]}}' }
        @{ Case = 'non-command-hook'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"prompt","command":"a.ps1"}]}]}}' }
        @{ Case = 'commandless-hook'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command"}]}]}}' }
        @{ Case = 'non-script-command'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"pwsh -NoProfile -Command exit 0"}]}]}}' }
        @{ Case = 'uppercase-leaf'; Text = '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"pwsh -File .claude/hooks/Bad.ps1"}]}]}}' }
    ) {
        $registry = Read-HookDispatchRegistry -RegistryText $Text -HooksDirectory 'hooks' -TestPath $script:AllExist
        $registry.IsValid | Should -BeFalse
        $registry.Reason.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $registry.Reason.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *'
    }

    It 'blocks a registry hook that does not resolve to a hooks-folder file' {
        $registry = Read-HookDispatchRegistry -RegistryText $script:ValidRegistry -HooksDirectory 'hooks' -TestPath $script:NoneExist
        $registry.IsValid | Should -BeFalse
        $registry.Reason.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *validate-bash.ps1*'
    }
}

Describe 'Select-HookDispatchHook and Resolve-HookDispatchScriptPath' {
    It 'selects the hooks of every admitting group in registry order' {
        $registry = Read-HookDispatchRegistry -RegistryText $script:ValidRegistry -HooksDirectory 'hooks' -TestPath $script:AllExist
        @(Select-HookDispatchHook -Registry $registry -ToolName 'Bash' | ForEach-Object Leaf) | Should -Be @('validate-bash.ps1', 'enforce-x.ps1')
        @(Select-HookDispatchHook -Registry $registry -ToolName 'Edit' | ForEach-Object Leaf) | Should -Be @('enforce-y.ps1')
        @(Select-HookDispatchHook -Registry $registry -ToolName 'Agent').Count | Should -Be 0
    }

    It 'resolves a validated hook to its hooks-folder path and rejects any other leaf' {
        Resolve-HookDispatchScriptPath -Hook ([pscustomobject]@{ Leaf = 'a-b.ps1'; Path = 'hooks/a-b.ps1' }) | Should -Be 'hooks/a-b.ps1'
        { Resolve-HookDispatchScriptPath -Hook ([pscustomobject]@{ Leaf = '../x.ps1'; Path = 'x' }) } | Should -Throw '*HOOK_DISPATCH_BLOCKED*'
    }
}

Describe 'Get-HookDispatchBlockDecision' {
    It 'prefixes the reason with HOOK_DISPATCH_BLOCKED and states the fail-closed outcome' {
        (Get-HookDispatchBlockDecision -Detail 'why').hookSpecificOutput.permissionDecisionReason | Should -BeExactly 'HOOK_DISPATCH_BLOCKED: why; the dispatcher fails closed.'
    }
}
