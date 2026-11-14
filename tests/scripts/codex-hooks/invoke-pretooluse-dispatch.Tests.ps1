#Requires -Version 7.0
<#
.SYNOPSIS
    Tests for .codex/hooks/invoke-pretooluse-dispatch.ps1 (issue #1159).

.DESCRIPTION
    The entry script is dot-sourced, which defines its functions and runs nothing. The payload
    reader, the registry reader and the trace writer are seams, and Invoke-CodexHookDispatchRunner is
    mocked, so no hook runs, no process starts and no file is written. Environment variables set by a
    case are restored in 'finally'.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.codex/hooks/invoke-pretooluse-dispatch.ps1')
    $script:Registry = '{"isolation":"in-process","hooks":{"PreToolUse":[{"matcher":"^Bash$","hooks":[{"type":"command","command":"pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)/.codex/hooks/validate-bash.ps1\"","timeout":30}]}]}}'
    $script:Payload = '{"tool_name":"Bash","tool_input":{"command":"git status"}}'

    function Get-TestHookResult {
        param([AllowNull()] [string] $Decision, [AllowNull()] [string] $Reason)
        [pscustomobject]@{ Hook = 'validate-bash.ps1'; Command = 'c'; Isolation = 'in-process'; ExitCode = 0; Stdout = ''; Stderr = ''; Decision = $Decision; Reason = $Reason; AdditionalContext = $null; Error = $null; ModulesLoaded = [string[]]@() }
    }
}

Describe 'Invoke-CodexPreToolUseDispatchEntryPoint' {
    BeforeEach {
        Mock Invoke-CodexHookDispatchRunner { @((Get-TestHookResult 'deny' 'BASH_BLOCKED: x')) }
        $registryText = $script:Registry
        $script:ReadRegistry = { $registryText }.GetNewClosure()
    }

    It 'reads the payload once' {
        $calls = [System.Collections.Generic.List[int]]::new()
        $payload = $script:Payload
        $reader = { $calls.Add(1); $payload }.GetNewClosure()
        $null = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload $reader -ReadRegistry $script:ReadRegistry)
        $calls.Count | Should -Be 1
        Should -Invoke Invoke-CodexHookDispatchRunner -Times 1 -Exactly -ParameterFilter { $ToolName -eq 'Bash' }
    }

    It 'uses no environment fallback when stdin is empty' {
        $savedHook = $env:CLAUDE_HOOK_INPUT; $savedTool = $env:CLAUDE_TOOL_INPUT
        try {
            $env:CLAUDE_HOOK_INPUT = $script:Payload
            $env:CLAUDE_TOOL_INPUT = $script:Payload
            $output = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { '' } -ReadRegistry $script:ReadRegistry)
        } finally {
            $env:CLAUDE_HOOK_INPUT = $savedHook
            $env:CLAUDE_TOOL_INPUT = $savedTool
        }
        Should -Invoke Invoke-CodexHookDispatchRunner -Times 0 -Exactly
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *tool_name*'
    }

    It 'writes no environment variable' {
        $before = @(Get-ChildItem -Path Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object)
        $null = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $after = @(Get-ChildItem -Path Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object)
        $after | Should -Be $before
    }

    It 'emits the combined decision as JSON followed by exit code 0' {
        $output = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $output[0] | Should -BeExactly '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BASH_BLOCKED: x"}}'
        $output[1] | Should -Be 0
    }

    It 'emits nothing when no hook decides' {
        Mock Invoke-CodexHookDispatchRunner { @((Get-TestHookResult $null $null)) }
        @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry) | Should -Be @(0)
    }

    It 'denies with HOOK_DISPATCH_BLOCKED when the registry is <Case>' -ForEach @(
        @{ Case = 'missing'; Reader = { $null } }
        @{ Case = 'unreadable'; Reader = { throw 'locked' } }
        @{ Case = 'invalid'; Reader = { '{"isolation":"in-process"}' } }
        @{ Case = 'naming a missing hook'; Reader = { '{"hooks":{"PreToolUse":[{"matcher":"^Bash$","hooks":[{"type":"command","command":"pwsh -File .codex/hooks/no-such-hook-1159.ps1"}]}]}}' } }
    ) {
        $output = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $Reader)
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *'
        Should -Invoke Invoke-CodexHookDispatchRunner -Times 0 -Exactly
    }

    It 'writes one trace line per hook with -PerHookTrace' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $writer = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
        $null = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace -WriteTrace $writer)
        $lines.Count | Should -Be 1
        ($lines[0] | ConvertFrom-Json).reason | Should -Be 'BASH_BLOCKED: x'
    }

    It 'writes each trace line to the console error writer by default' {
        # Arrange: capture [Console]::Error, restored in finally.
        $priorError = [Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            # Act
            [Console]::SetError($errorWriter)
            $null = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace)
        } finally {
            [Console]::SetError($priorError)
        }

        # Assert
        $lines = @($errorWriter.ToString().Trim() -split "`r?`n")
        $lines.Count | Should -Be 1
        ($lines[0] | ConvertFrom-Json).reason | Should -Be 'BASH_BLOCKED: x'
    }
}

Describe 'Codex invoke-pretooluse-dispatch.ps1 script tail' {
    It 'denies a payload without a tool name through the registry beside the script when run in process' {
        # Arrange: the default payload reader is mocked to return a payload without tool_name, so no row reads the
        # process stdin; the default registry reader runs.
        $entryPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../.codex/hooks/invoke-pretooluse-dispatch.ps1')).ProviderPath
        Mock Read-CodexPreToolUseDispatchStandardInput { '{"session_id":"dispatch-tail","hook_event_name":"PreToolUse"}' }

        # Act: run the script through the & route so the statements after the dot-source guard execute.
        $emitted = @(& $entryPath)
        $exitCode = $LASTEXITCODE

        # Assert
        $exitCode | Should -Be 0
        $emitted.Count | Should -Be 1
        ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'HOOK_DISPATCH_BLOCKED: *tool_name*'
        Should -Invoke Read-CodexPreToolUseDispatchStandardInput -Times 1 -Exactly
    }
}

Describe 'Read-CodexPreToolUseDispatchStandardInput (issue #1187)' {
    It 'decodes <Name> from UTF-8 bytes exactly' -ForEach @(
        @{ Name = 'an em dash'; Text = ('{"t":"a' + [char]0x2014 + 'b"}') }
        @{ Name = 'curly quotes'; Text = ('{"t":"' + [char]0x201C + 'q' + [char]0x201D + '"}') }
        @{ Name = 'a non-BMP character'; Text = ('{"t":"x' + [char]::ConvertFromUtf32(0x1F600) + '"}') }
    ) {
        # Arrange
        $stream = [System.IO.MemoryStream]::new([System.Text.UTF8Encoding]::new($false).GetBytes($Text))

        # Act
        $result = Read-CodexPreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure()

        # Assert
        $result | Should -BeExactly $Text
    }

    It 'strips a leading UTF-8 byte order mark' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0xEF, 0xBB, 0xBF, 0x61, 0x62, 0x63))
        Read-CodexPreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure() | Should -BeExactly 'abc'
    }

    It 'maps an invalid byte to U+FFFD without throwing' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0x61, 0xFF, 0x62))
        Read-CodexPreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure() | Should -BeExactly ('a' + [char]0xFFFD + 'b')
    }

    It 'disposes the stream it reads' {
        $stream = [System.IO.MemoryStream]::new([byte[]] @(0x61))
        $null = Read-CodexPreToolUseDispatchStandardInput -OpenStream { $stream }.GetNewClosure()
        $stream.CanRead | Should -BeFalse
    }

    It 'opens the process standard input through the default stream seam without reading it' {
        # Arrange: the default OpenStream script block of the dot-sourced function, taken from its syntax tree.
        $function = (Get-Command -Name Read-CodexPreToolUseDispatchStandardInput -CommandType Function).ScriptBlock.Ast
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

Describe 'Invoke-CodexPreToolUseDispatchEntryPoint non-ASCII output (issue #1187)' {
    BeforeAll {
        $script:NonAsciiReason = 'BASH_BLOCKED: x ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)
    }

    BeforeEach {
        Mock Invoke-CodexHookDispatchRunner { @((Get-TestHookResult 'deny' $script:NonAsciiReason)) }
        $registryText = $script:Registry
        $script:ReadRegistry = { $registryText }.GetNewClosure()
    }

    It 'emits the decision with every character below U+0080 and restores the reason' {
        $output = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry)
        $output.Count | Should -Be 2
        [regex]::IsMatch([string] $output[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the decision JSON escapes every non-ASCII character'
        ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:NonAsciiReason
    }

    It 'writes the trace line with every character below U+0080 and restores the reason' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $writer = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
        $null = @(Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload { $script:Payload } -ReadRegistry $script:ReadRegistry -PerHookTrace -WriteTrace $writer)
        $lines.Count | Should -Be 1
        [regex]::IsMatch($lines[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the trace JSON escapes every non-ASCII character'
        ($lines[0] | ConvertFrom-Json).reason | Should -BeExactly $script:NonAsciiReason
    }

    It 'emits the dependency-failure deny of the script tail with every character below U+0080' {
        # Arrange: a dependency-failure deny whose reason holds an em dash, curly quotes, and a non-BMP character. The
        # mock body builds the reason itself because it runs under the script scope of the &-invoked entry script.
        $entryPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../.codex/hooks/invoke-pretooluse-dispatch.ps1')).ProviderPath
        $expected = 'HOOK_DISPATCH_BLOCKED: dep ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)
        Mock Get-HookDependencyFailureDecision { [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = ('HOOK_DISPATCH_BLOCKED: dep ' + [char]0x2014 + ' ' + [char]0x201C + 'q' + [char]0x201D + ' ' + [char]::ConvertFromUtf32(0x1F600)) } } }

        # Act: run the script through the & route so the dependency-failure emit after the dot-source guard executes.
        $emitted = @(& $entryPath)

        # Assert
        $emitted.Count | Should -Be 1
        [regex]::IsMatch([string] $emitted[0], '[^\u0000-\u007F]') | Should -BeFalse -Because 'the emitted JSON escapes every non-ASCII character'
        ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeExactly $expected
    }

    It 'defaults ReadPayload to the Codex UTF-8 reader' {
        $entryPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../.codex/hooks/invoke-pretooluse-dispatch.ps1')).ProviderPath
        $tokens = $null; $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($entryPath, [ref] $tokens, [ref] $parseErrors)
        $function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Invoke-CodexPreToolUseDispatchEntryPoint' }, $true)
        $parameter = @($function.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -ceq 'ReadPayload' })
        $parameter.Count | Should -Be 1
        $parameter[0].DefaultValue.Extent.Text | Should -BeExactly '{ Read-CodexPreToolUseDispatchStandardInput }'
    }
}

Describe 'Invoke-CodexPreToolUseDispatchDecision' {
    It 'returns the dependency-failure deny before reading the registry' {
        Mock Get-HookDependencyFailureDecision { [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = 'HOOK_DISPATCH_BLOCKED: dep' } } }
        Mock Read-CodexHookDispatchRegistry { throw 'must not be read' }
        (Invoke-CodexPreToolUseDispatchDecision -PayloadText $script:Payload -RegistryText $script:Registry).hookSpecificOutput.permissionDecisionReason | Should -Be 'HOOK_DISPATCH_BLOCKED: dep'
    }
}
