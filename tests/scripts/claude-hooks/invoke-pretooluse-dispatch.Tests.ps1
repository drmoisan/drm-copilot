#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for .claude/hooks/invoke-pretooluse-dispatch.ps1 (issue #1159).

.DESCRIPTION
    The entry script is dot-sourced, which defines its functions and runs nothing. The payload
    reader, the registry reader and the trace writer are seams, and Invoke-HookDispatchRunner is
    mocked, so no hook runs, no process starts and no file is written.
#>

BeforeAll {
    $script:EntryPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../.claude/hooks/invoke-pretooluse-dispatch.ps1')).ProviderPath
    . $script:EntryPath

    $script:Registry = '{"isolation":"in-process","hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/validate-bash.ps1"},{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-promotion-mcp-only.ps1"}]}]}}'
    $script:Payload = '{"tool_name":"Bash","tool_input":{"command":"git status"}}'

    function Get-TestHookResult {
        param([string] $Hook, [AllowNull()] [string] $Decision, [AllowNull()] [string] $Reason)
        [pscustomobject]@{ Hook = $Hook; Command = "pwsh -NoProfile -File .claude/hooks/$Hook"; Isolation = 'in-process'; ExitCode = 0; Stdout = ''; Stderr = ''; Decision = $Decision; Reason = $Reason; AdditionalContext = $null; Error = $null; ModulesLoaded = [string[]]@('m.psm1') }
    }
}

AfterAll {
    Remove-Module -Name HookDispatchRunner, HookDispatch -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-PreToolUseDispatchEntryPoint' {
    BeforeEach {
        Mock Invoke-HookDispatchRunner { @((Get-TestHookResult -Hook 'validate-bash.ps1' -Decision 'deny' -Reason 'BASH_BLOCKED: a'), (Get-TestHookResult -Hook 'enforce-promotion-mcp-only.ps1' -Decision 'deny' -Reason 'PROMOTION_BLOCKED: b')) }
        $registryText = $script:Registry
        $script:ReadRegistry = { $registryText }.GetNewClosure()
    }

    It 'reads the payload once through Read-ClaudeHookRawPayload' {
        Mock Read-ClaudeHookRawPayload { $script:Payload }
        $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadRegistry $script:ReadRegistry)
        Should -Invoke Read-ClaudeHookRawPayload -Times 1 -Exactly
        Should -Invoke Invoke-HookDispatchRunner -Times 1 -Exactly -ParameterFilter { $PayloadText -eq $script:Payload -and $ToolName -eq 'Bash' }
    }

    It 'writes no environment variable' {
        $before = @(Get-ChildItem -Path Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object)
        $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $after = @(Get-ChildItem -Path Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object)
        $after | Should -Be $before
    }

    It 'emits the combined decision as compact JSON followed by exit code 0' {
        $output = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $output.Count | Should -Be 2
        $output[0] | Should -BeExactly '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BASH_BLOCKED: a\nPROMOTION_BLOCKED: b"}}'
        $output[1] | Should -Be 0
    }

    It 'emits nothing and exit code 0 when no hook decides' {
        Mock Invoke-HookDispatchRunner { @((Get-TestHookResult -Hook 'validate-bash.ps1')) }
        $output = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $output | Should -Be @(0)
    }

    It 'denies with HOOK_DISPATCH_BLOCKED when the registry is <Case>' -ForEach @(
        @{ Case = 'missing'; Reader = { $null } }
        @{ Case = 'unreadable'; Reader = { throw 'locked' } }
        @{ Case = 'invalid'; Reader = { '{"hooks":{}}' } }
        @{ Case = 'naming a missing hook'; Reader = { '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -File .claude/hooks/no-such-hook-1159.ps1"}]}]}}' } }
    ) {
        $output = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $Reader)
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *'
        $output[1] | Should -Be 0
        Should -Invoke Invoke-HookDispatchRunner -Times 0 -Exactly
    }

    It 'denies with HOOK_DISPATCH_BLOCKED when the payload carries no tool name' {
        $output = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { '{not-json' } -ReadRegistry $script:ReadRegistry)
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *tool_name*'
        Should -Invoke Invoke-HookDispatchRunner -Times 0 -Exactly
    }

    It 'writes one trace line per hook with -PerHookTrace' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $writer = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
        $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace -WriteTrace $writer)
        $lines.Count | Should -Be 2
        $first = $lines[0] | ConvertFrom-Json
        $first.hook | Should -Be 'validate-bash.ps1'
        $first.decision | Should -Be 'deny'
        $first.reason | Should -Be 'BASH_BLOCKED: a'
        @($first.modulesLoaded) | Should -Be @('m.psm1')
    }

    It 'writes no trace without -PerHookTrace' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $writer = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
        $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -WriteTrace $writer)
        $lines.Count | Should -Be 0
    }
}

Describe 'Invoke-PreToolUseDispatchDecision' {
    It 'returns the dependency-failure deny before reading the registry' {
        Mock Get-HookDependencyFailureDecision { [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = 'HOOK_DISPATCH_BLOCKED: dep' } } }
        Mock Read-HookDispatchRegistry { throw 'must not be read' }
        $sink = [System.Collections.Generic.List[object]]::new()
        $decision = Invoke-PreToolUseDispatchDecision -PayloadText $script:Payload -RegistryText $script:Registry -ResultSink $sink
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Be 'HOOK_DISPATCH_BLOCKED: dep'
        $sink.Count | Should -Be 0
    }
}
