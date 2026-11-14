#Requires -Version 7.0
<#
.SYNOPSIS
    Unit tests for .claude/lib/hook-dispatch/HookDispatchRunner.psm1 (issue #1159).

.DESCRIPTION
    The runner is driven through its script-invoker, stdin-replayer and process-starter seams with
    in-memory registries. Two cases run the committed fixture hook
    tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1 through the default '&' call and
    the default child-process seam; no test writes a file. Every console writer, stdin and the
    location are captured before each case and compared after it.
#>

BeforeAll {
    $script:LibRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../../.claude/lib/hook-dispatch')).ProviderPath
    $script:FixtureHook = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1')).ProviderPath
    Import-Module -Name (Join-Path $script:LibRoot 'HookDispatchRunner.psm1') -Force

    function Get-TestRegistry {
        param([string[]] $Leaf, [AllowNull()] [string] $Isolation = 'in-process', [string] $Matcher = 'Bash', [string] $Directory = 'hooks')
        $hooks = foreach ($name in $Leaf) { [pscustomobject]@{ Type = 'command'; Command = "pwsh -NoProfile -File .claude/hooks/$name"; Leaf = $name; Path = "$Directory/$name"; Timeout = $null } }
        [pscustomobject]@{ IsValid = $true; Reason = $null; Isolation = $Isolation; Notes = @(); Groups = @([pscustomobject]@{ Matcher = $Matcher; Hooks = @($hooks) }) }
    }

    $script:Payload = '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
}

AfterAll {
    Remove-Module -Name HookDispatchRunner, HookDispatch -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-HookDispatchRunner (in-process)' {
    BeforeEach {
        $script:ConsoleIn = [Console]::In
        $script:ConsoleOut = [Console]::Out
        $script:ConsoleError = [Console]::Error
        $script:Location = (Get-Location).ProviderPath
    }

    AfterEach {
        [Console]::SetIn($script:ConsoleIn)
        [Console]::SetOut($script:ConsoleOut)
        [Console]::SetError($script:ConsoleError)
        Set-Location -LiteralPath $script:Location
    }

    It 'runs every later hook when the first hook denies' {
        # Arrange: the first hook denies through exit 2; the later hooks record their invocation.
        $invoked = [System.Collections.Generic.List[string]]::new()
        $invoker = {
            param([string] $Path)
            $invoked.Add($Path)
            if ($Path -like '*first.ps1') { [Console]::Error.WriteLine('FIRST_BLOCKED: no'); Set-Variable -Name LASTEXITCODE -Scope Global -Value 2 }
        }.GetNewClosure()
        # Act
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'first.ps1', 'second.ps1', 'third.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        # Assert
        @($invoked) | Should -Be @('hooks/first.ps1', 'hooks/second.ps1', 'hooks/third.ps1')
        $results[0].Decision | Should -Be 'deny'
        $results[0].Reason | Should -Be 'FIRST_BLOCKED: no'
        @($results | ForEach-Object Hook) | Should -Be @('first.ps1', 'second.ps1', 'third.ps1')
    }

    It 'replays the payload on stdin for every hook' {
        $seen = [System.Collections.Generic.List[string]]::new()
        $invoker = { param([string] $Path) $seen.Add("$Path=$([Console]::In.ReadToEnd())") }.GetNewClosure()
        $null = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'a.ps1', 'b.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        @($seen) | Should -Be @("hooks/a.ps1=$($script:Payload)", "hooks/b.ps1=$($script:Payload)")
    }

    It 'captures stdout written through Console.Out as the hook stdout' {
        # Arrange: a deny written only through [Console]::Out.WriteLine, with the test's own writer captured.
        $testWriter = [System.IO.StringWriter]::new()
        [Console]::SetOut($testWriter)
        $invoker = { param([string] $Path) [Console]::Out.WriteLine('{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"OUT_BLOCKED: x"}}'); $null = $Path }
        # Act
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'out.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        [Console]::SetOut($script:ConsoleOut)
        # Assert
        $results[0].Decision | Should -Be 'deny'
        $results[0].Reason | Should -Be 'OUT_BLOCKED: x'
        $testWriter.ToString() | Should -BeNullOrEmpty
    }

    It 'captures the success, warning and information streams after the Console.Out text' {
        $invoker = { param([string] $Path) [Console]::Out.Write('A'); Write-Output 'B'; Write-Warning 'C'; Write-Information 'D' -InformationAction Continue; $null = $Path }
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 's.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        $results[0].Stdout -split "`r?`n" | Where-Object { $_ } | Should -Be @('AB', 'C', 'D')
        $results[0].Error | Should -Be 'InvalidJson'
    }

    It 'captures error records and the error writer as stderr' {
        $invoker = { param([string] $Path) [Console]::Error.Write('E1 '); Write-Error 'E2' -ErrorAction Continue; $null = $Path }
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'e.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        $results[0].Stderr | Should -BeLike 'E1 E2*'
        $results[0].ExitCode | Should -Be 0
    }

    It 'maps a hook that ends without exit to exit code 0' {
        $invoker = { param([string] $Path) Write-Output '{"hookSpecificOutput":{"permissionDecision":"allow"}}'; $null = $Path }
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'noexit.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        $results[0].ExitCode | Should -Be 0
        $results[0].Decision | Should -Be 'allow'
    }

    It 'maps a terminating error to a non-blocking error' {
        $invoked = [System.Collections.Generic.List[string]]::new()
        $invoker = { param([string] $Path) $invoked.Add($Path); if ($Path -like '*throws.ps1') { throw 'hook failed' } }.GetNewClosure()
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'throws.ps1', 'later.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        $results[0].Decision | Should -BeNullOrEmpty
        $results[0].Error | Should -Be 'TerminatingError'
        $results[0].Stderr | Should -BeLike '*hook failed*'
        @($invoked) | Should -Be @('hooks/throws.ps1', 'hooks/later.ps1')
    }

    It 'restores stdin, error writer, output writer and location after a hook that throws' {
        # Arrange
        $inBefore = [Console]::In; $errorBefore = [Console]::Error; $outBefore = [Console]::Out; $locationBefore = (Get-Location).ProviderPath
        $elsewhere = Split-Path -Path $script:LibRoot -Parent
        $invoker = { param([string] $Path) Set-Location -LiteralPath $elsewhere; [Console]::SetOut([System.IO.StringWriter]::new()); throw "boom $Path" }.GetNewClosure()
        # Act
        $null = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'throws.ps1') -ToolName 'Bash' -InvokeScript $invoker)
        # Assert
        [object]::ReferenceEquals([Console]::In, $inBefore) | Should -BeTrue
        [object]::ReferenceEquals([Console]::Error, $errorBefore) | Should -BeTrue
        [object]::ReferenceEquals([Console]::Out, $outBefore) | Should -BeTrue
        (Get-Location).ProviderPath | Should -Be $locationBefore
    }

    It 'runs only the hooks whose group admits the tool name' {
        $invoked = [System.Collections.Generic.List[string]]::new()
        $invoker = { param([string] $Path) $invoked.Add($Path) }.GetNewClosure()
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'a.ps1' -Matcher 'Write|Edit') -ToolName 'Bash' -InvokeScript $invoker)
        $results.Count | Should -Be 0
        $invoked.Count | Should -Be 0
    }

    It 'invokes the resolved hook script with the default call and reads its exit code' {
        # The committed fixture reads stdin, prints its length and exits 2 when the payload contains 'deny'.
        $registry = Get-TestRegistry -Leaf 'stdin-exit-hook.ps1' -Directory (Split-Path -Path $script:FixtureHook -Parent)
        $deny = @(Invoke-HookDispatchRunner -PayloadText '{"tool_name":"Bash","note":"deny"}' -Registry $registry -ToolName 'Bash')
        $allow = @(Invoke-HookDispatchRunner -PayloadText '{"tool_name":"Bash"}' -Registry $registry -ToolName 'Bash')
        $deny[0].ExitCode | Should -Be 2
        $deny[0].Decision | Should -Be 'deny'
        $deny[0].Stdout.Trim() | Should -Be '34'
        $allow[0].ExitCode | Should -Be 0
        $allow[0].Error | Should -Be 'InvalidJson'
    }
}

Describe 'Invoke-HookDispatchRunner (per-process)' {
    It 'runs each hook as a child process when isolation is absent' {
        # Arrange: Read-HookDispatchRegistry maps an absent isolation field to per-process.
        $started = [System.Collections.Generic.List[object]]::new()
        $starter = { param([string] $Path, [string] $PayloadText) $started.Add([pscustomobject]@{ Path = $Path; Payload = $PayloadText }); [pscustomobject]@{ ExitCode = 2; Stdout = ''; Stderr = "CHILD_BLOCKED: $Path" } }.GetNewClosure()
        $invoker = { param([string] $Path) throw "in-process call for $Path" }
        # Act
        $results = @(Invoke-HookDispatchRunner -PayloadText $script:Payload -Registry (Get-TestRegistry -Leaf 'a.ps1', 'b.ps1' -Isolation 'per-process') -ToolName 'Bash' -StartProcess $starter -InvokeScript $invoker)
        # Assert
        @($started | ForEach-Object Path) | Should -Be @('hooks/a.ps1', 'hooks/b.ps1')
        @($started | ForEach-Object Payload) | Should -Be @($script:Payload, $script:Payload)
        @($results | ForEach-Object Reason) | Should -Be @('CHILD_BLOCKED: hooks/a.ps1', 'CHILD_BLOCKED: hooks/b.ps1')
        @($results | ForEach-Object Isolation) | Should -Be @('per-process', 'per-process')
    }

    It 'starts pwsh -NoProfile -File with the payload on stdin through the default process seam' -Tag 'Integration' {
        $result = Invoke-HookDispatchChildProcess -Path $script:FixtureHook -PayloadText '{"note":"deny"}'
        $result.ExitCode | Should -Be 2
        $result.Stdout.Trim() | Should -Be '15'
    }
}
