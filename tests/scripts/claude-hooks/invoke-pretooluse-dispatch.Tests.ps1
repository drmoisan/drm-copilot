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

    It 'writes each trace line to the console error writer by default' {
        # Arrange: capture [Console]::Error, restored in finally.
        $priorError = [Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            # Act
            [Console]::SetError($errorWriter)
            $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace)
        } finally {
            [Console]::SetError($priorError)
        }

        # Assert
        $lines = @($errorWriter.ToString().Trim() -split "`r?`n")
        $lines.Count | Should -Be 2
        ($lines[1] | ConvertFrom-Json).hook | Should -Be 'enforce-promotion-mcp-only.ps1'
    }
}

Describe 'invoke-pretooluse-dispatch.ps1 script tail' {
    It 'denies a payload without a tool name through the registry beside the script when run in process' {
        # Arrange: the default payload reader calls Read-ClaudeHookRawPayload, mocked to return a payload without
        # tool_name, so no row reads the process stdin; the default registry reader runs.
        Mock Read-ClaudeHookRawPayload { '{"session_id":"dispatch-tail","hook_event_name":"PreToolUse"}' }

        # Act: run the script through the & route so the statements after the dot-source guard execute.
        $emitted = @(& $script:EntryPath)
        $exitCode = $LASTEXITCODE

        # Assert
        $exitCode | Should -Be 0
        $emitted.Count | Should -Be 1
        ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *tool_name*'
        Should -Invoke Read-ClaudeHookRawPayload -Times 1 -Exactly -ParameterFilter { $null -ne $ReadStandardInput -and $ReadStandardInput.ToString().Contains('Read-PreToolUseDispatchStandardInput') }
    }
}

Describe 'Read-PreToolUseDispatchStandardInput (issue #1187)' {
    It 'decodes <Name> from UTF-8 bytes exactly' -ForEach @(
        @{ Name = 'an em dash'; Text = ('{"t":"a' + [char]0x2014 + 'b"}') }
        @{ Name = 'curly quotes'; Text = ('{"t":"' + [char]0x201C + 'q' + [char]0x201D + '"}') }
        @{ Name = 'a non-BMP character'; Text = ('{"t":"x' + [char]::ConvertFromUtf32(0x1F600) + '"}') }
    ) {
        # Arrange
        $stream = [System.IO.MemoryStream]::new([System.Text.UTF8Encoding]::new($false).GetBytes($Text))

        # Act
        $result = Read-PreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure()

        # Assert
        $result | Should -BeExactly $Text
    }

    It 'strips a leading UTF-8 byte order mark' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0xEF, 0xBB, 0xBF, 0x61, 0x62, 0x63))
        Read-PreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure() | Should -BeExactly 'abc'
    }

    It 'maps an invalid byte to U+FFFD without throwing' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0x61, 0xFF, 0x62))
        Read-PreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure() | Should -BeExactly ('a' + [char]0xFFFD + 'b')
    }

    It 'disposes the stream it reads' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0x61))
        $null = Read-PreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure()
        $stream.CanRead | Should -BeFalse
    }

    It 'opens the process standard input through the default stream seam without reading it' {
        # Arrange: the default OpenStream script block of the dot-sourced function, taken from its syntax tree.
        $function = (Get-Command -Name Read-PreToolUseDispatchStandardInput -CommandType Function).ScriptBlock.Ast
        $default = $function.Body.ParamBlock.Parameters[0].DefaultValue.ScriptBlock.GetScriptBlock()

        # Act: run only the seam; nothing is read from the stream.
        $stream = & $default
        try {
            # Assert
            $stream -is [System.IO.Stream] | Should -BeTrue
        } finally {
            $stream.Dispose()
        }
    }
}

Describe 'Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187)' {
    BeforeAll {
        $script:NonAsciiReason = 'BASH_BLOCKED: a ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)
    }

    BeforeEach {
        Mock Invoke-HookDispatchRunner { @((Get-TestHookResult -Hook 'validate-bash.ps1' -Decision 'deny' -Reason $script:NonAsciiReason)) }
        $registryText = $script:Registry
        $script:ReadRegistry = { $registryText }.GetNewClosure()
    }

    It 'emits the decision with every character below U+0080 and restores the reason' {
        $output = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $output.Count | Should -Be 2
        [regex]::IsMatch([string] $output[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the decision JSON escapes every non-ASCII character'
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:NonAsciiReason
    }

    It 'writes the trace line with every character below U+0080 and restores the reason' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $writer = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
        $null = @(Invoke-PreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace -WriteTrace $writer)
        $lines.Count | Should -Be 1
        [regex]::IsMatch($lines[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the trace JSON escapes every non-ASCII character'
        ($lines[0] | ConvertFrom-Json).reason | Should -BeExactly $script:NonAsciiReason
    }

    It 'emits the dependency-failure deny of the script tail with every character below U+0080' {
        # Arrange: a dependency-failure deny whose reason holds an em dash, curly quotes, and a non-BMP character. The
        # mock body builds the reason itself because it runs under the script scope of the &-invoked entry script.
        $expected = 'HOOK_DISPATCH_BLOCKED: dep ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)
        Mock Get-HookDependencyFailureDecision { [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = ('HOOK_DISPATCH_BLOCKED: dep ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)) } } }

        # Act: run the script through the & route so the dependency-failure emit after the dot-source guard executes.
        $emitted = @(& $script:EntryPath)

        # Assert
        $emitted.Count | Should -Be 1
        [regex]::IsMatch([string] $emitted[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the emitted JSON escapes every non-ASCII character'
        ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeExactly $expected
    }

    It 'defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader' {
        $tokens = $null; $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:EntryPath, [ref] $tokens, [ref] $parseErrors)
        $function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Invoke-PreToolUseDispatchEntryPoint' }, $true)
        $parameter = @($function.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -ceq 'ReadPayload' })
        $parameter.Count | Should -Be 1
        $parameter[0].DefaultValue.Extent.Text | Should -BeExactly '{ Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput } }'
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
