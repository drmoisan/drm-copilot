#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Registered Codex parallel hook transport' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:ConfigPath = Join-Path $script:RepoRoot '.codex/config.toml'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
        $script:Eol = [Environment]::NewLine
        $script:StatePath = Join-Path $script:RepoRoot '.codex/state'
        $script:InitialState = @(
            Get-ChildItem -LiteralPath $script:StatePath -File -ErrorAction SilentlyContinue |
                ForEach-Object { "$( $_.Name )|$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)" }
        )
        $script:DirectHooks = @(
            'authorize-root-parallel-invocation.ps1',
            'enforce-parallel-root-invocation.ps1',
            'enforce-parallel-cohort-barrier.ps1',
            'enforce-parallel-drift-gate.ps1',
            'enforce-parallel-child-worktree-binding.ps1',
            'enforce-parallel-worktree-removal-gate.ps1',
            'enforce-parallel-abandon-gate.ps1'
        )
        $script:TransportCells = @(
            'allow',
            'deny',
            'malformed-stdin',
            'missing-stdin',
            'poisoned-CLAUDE_TOOL_INPUT',
            'poisoned-CLAUDE_SESSION_ID'
        )
        $script:DispatcherCells = @(
            'valid-parallel',
            'invalid-parallel',
            'malformed-stdin',
            'missing-stdin',
            'poisoned-CLAUDE_TOOL_INPUT',
            'poisoned-CLAUDE_SESSION_ID'
        )
        $script:ReasonCodes = @{
            'enforce-parallel-root-invocation.ps1'        = 'PARALLEL_INVOCATION_ORIGIN_BLOCKED'
            'enforce-parallel-cohort-barrier.ps1'         = 'PARALLEL_COHORT_BARRIER_BLOCKED'
            'enforce-parallel-drift-gate.ps1'             = 'PARALLEL_DRIFT_GATE_BLOCKED'
            'enforce-parallel-child-worktree-binding.ps1' = 'PARALLEL_CHILD_WORKTREE_BINDING_BLOCKED'
            'enforce-parallel-worktree-removal-gate.ps1'  = 'PARALLEL_WORKTREE_REMOVAL_BLOCKED'
            'enforce-parallel-abandon-gate.ps1'           = 'PARALLEL_ABANDON_BLOCKED'
        }

        function Get-CodexHookRegistration {
            <# Parses the nested handler schema without deriving executable paths outside the config. #>
            param([Parameter(Mandatory)][string] $ConfigPath)

            $registrations = [System.Collections.Generic.List[object]]::new()
            $eventName = ''
            $matcher = $null
            $handler = $null

            $configLines = @(Get-Content -LiteralPath $ConfigPath)
            $configLines += '[[hooks.End]]'
            foreach ($line in $configLines) {
                $outerMatch = [regex]::Match($line, '^\[\[hooks\.(?<event>[A-Za-z]+)\]\]$')
                if ($outerMatch.Success) {
                    if ($null -ne $handler) {
                        $registrations.Add([pscustomobject]$handler)
                    }
                    $eventName = $outerMatch.Groups['event'].Value
                    $matcher = $null
                    $handler = $null
                    continue
                }
                $innerMatch = [regex]::Match($line, '^\[\[hooks\.(?<event>[A-Za-z]+)\.hooks\]\]$')
                if ($innerMatch.Success) {
                    if ($null -ne $handler) {
                        $registrations.Add([pscustomobject]$handler)
                    }
                    $handler = [ordered]@{
                        Event          = $eventName
                        Matcher        = $matcher
                        Type           = ''
                        Command        = ''
                        CommandWindows = ''
                        Timeout        = 0
                        StatusMessage  = ''
                    }
                    continue
                }
                $matcherMatch = [regex]::Match($line, '^matcher\s*=\s*"(?<value>.*)"\s*$')
                if ($null -eq $handler -and $matcherMatch.Success) {
                    $matcher = $matcherMatch.Groups['value'].Value
                    continue
                }
                if ($null -eq $handler) {
                    continue
                }
                $fieldMatch = [regex]::Match(
                    $line,
                    '^(?<key>type|command|command_windows|statusMessage)\s*=\s*(?<quote>[''"])(?<value>.*)\k<quote>\s*$'
                )
                $timeoutMatch = [regex]::Match($line, '^timeout\s*=\s*(?<value>\d+)\s*$')
                if ($fieldMatch.Success) {
                    switch ($fieldMatch.Groups['key'].Value) {
                        'type' { $handler.Type = $fieldMatch.Groups['value'].Value }
                        'command' { $handler.Command = $fieldMatch.Groups['value'].Value }
                        'command_windows' { $handler.CommandWindows = $fieldMatch.Groups['value'].Value }
                        'statusMessage' { $handler.StatusMessage = $fieldMatch.Groups['value'].Value }
                    }
                } elseif ($timeoutMatch.Success) {
                    $handler.Timeout = [int]$timeoutMatch.Groups['value'].Value
                }
            }

            foreach ($registration in $registrations) {
                $hookMatch = [regex]::Match($registration.Command, '/(?<hook>[^/"]+\.ps1)"$')
                if ($hookMatch.Success) {
                    $registration | Add-Member -NotePropertyName HookName `
                        -NotePropertyValue $hookMatch.Groups['hook'].Value
                } else {
                    $registration | Add-Member -NotePropertyName HookName -NotePropertyValue ''
                }
            }
            return $registrations.ToArray()
        }

        function Resolve-CodexRegisteredHookPath {
            param([Parameter(Mandatory)] $Registration)

            $Registration.Command | Should -BeExactly $Registration.CommandWindows
            $commandMatch = [regex]::Match(
                $Registration.Command,
                '^pwsh -NoProfile -File "\$\(git rev-parse --show-toplevel\)/(?<relative>\.codex/hooks/[^"]+\.ps1)"$'
            )
            $commandMatch.Success | Should -BeTrue
            $relative = $commandMatch.Groups['relative'].Value.Replace('/', [IO.Path]::DirectorySeparatorChar)
            return Join-Path $script:RepoRoot $relative
        }

        function ConvertTo-CodexRegisteredPayload {
            param(
                [Parameter(Mandatory)] $Registration,
                [Parameter(Mandatory)][ValidateSet('allow', 'deny')][string] $Disposition
            )

            if ($Registration.Event -eq 'UserPromptSubmit') {
                $payload = [ordered]@{
                    hook_event_name = 'UserPromptSubmit'
                    session_id      = 'registered-transport'
                    turn_id         = 'registered-turn'
                    prompt          = 'ordinary request'
                }
                if ($Disposition -eq 'deny') {
                    $payload.prompt = '$parallel-plan docs/features/parallel/registered/parallel.md'
                    $payload.agent_type = 'orchestrator'
                }
                return $payload | ConvertTo-Json -Compress -Depth 20
            }

            $toolName = if ($Registration.Matcher -eq '^spawn_agent$') { 'spawn_agent' } else { 'shell_command' }
            $toolInput = [ordered]@{ command = 'git status' }
            $payload = [ordered]@{
                hook_event_name = 'PreToolUse'
                session_id      = 'registered-transport'
                turn_id         = 'registered-turn'
                agent_id        = 'registered-agent'
                agent_type      = 'default'
                cwd             = $script:RepoRoot
                tool_name       = $toolName
                tool_use_id     = 'registered-tool'
                tool_input      = $toolInput
            }
            if ($Disposition -eq 'allow') {
                return $payload | ConvertTo-Json -Compress -Depth 20
            }

            $payload.agent_type = 'parallel-orchestrator'
            switch ($Registration.HookName) {
                'enforce-parallel-root-invocation.ps1' {
                    $payload.tool_input = [ordered]@{ surface = 'parallel' }
                }
                { $_ -in @('enforce-parallel-cohort-barrier.ps1', 'enforce-parallel-drift-gate.ps1') } {
                    $payload.tool_input = [ordered]@{ task_name = 'registered-deny' }
                }
                'enforce-parallel-worktree-removal-gate.ps1' {
                    $payload.tool_input = [ordered]@{ command = 'git worktree remove registered-missing-worktree' }
                }
                'enforce-parallel-abandon-gate.ps1' {
                    $payload.tool_input = [ordered]@{
                        command = 'python -m scripts.dev_tools.parallel_mutation_abandon_cli --operation abandon --item 999 --worktree registered --confirmation missing'
                    }
                }
            }
            return $payload | ConvertTo-Json -Compress -Depth 20
        }

        function ConvertTo-CodexDispatcherPayload {
            param(
                [Parameter(Mandatory)] $Registration,
                [Parameter(Mandatory)][bool] $Valid
            )

            $payload = [ordered]@{
                hook_event_name  = $Registration.Event
                session_id       = if ($Valid) { 'registered-dispatcher' } else { '' }
                turn_id          = 'registered-dispatcher-turn'
                agent_id         = 'registered-dispatcher-agent'
                agent_type       = if ($Registration.Event -eq 'SubagentStart') {
                    'parallel-planner'
                } else {
                    'parallel-orchestrator'
                }
                model            = 'gpt-5.6-sol'
                transcript_path  = 'registered-dispatcher-transcript'
                stop_hook_active = $false
            }
            return $payload | ConvertTo-Json -Compress -Depth 20
        }

        function Invoke-CodexRegisteredHook {
            param(
                [Parameter(Mandatory)] $Registration,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw,
                [Parameter()][AllowEmptyString()][string] $PoisonVariable = '',
                [switch] $ActivateChildBinding,
                [switch] $RejectAuthorityWrite
            )

            $hookPath = Resolve-CodexRegisteredHookPath -Registration $Registration
            Test-Path -LiteralPath $hookPath -PathType Leaf | Should -BeTrue
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshPath
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-File')
            $startInfo.ArgumentList.Add($hookPath)
            $startInfo.WorkingDirectory = $script:RepoRoot
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false
            $null = $startInfo.Environment.Remove('CLAUDE_TOOL_INPUT')
            $null = $startInfo.Environment.Remove('CLAUDE_SESSION_ID')
            $null = $startInfo.Environment.Remove('CODEX_PARALLEL_CHILD_LAUNCH_ID')
            if ($PoisonVariable) {
                $startInfo.Environment[$PoisonVariable] = '{"poisoned":true}'
            }
            if ($ActivateChildBinding) {
                $startInfo.Environment['CODEX_PARALLEL_CHILD_LAUNCH_ID'] = 'registered-missing-launch'
            }
            if ($RejectAuthorityWrite) {
                $startInfo.Environment['CODEX_HOME'] = Join-Path $script:RepoRoot '.codex'
            }

            $process = [System.Diagnostics.Process]::Start($startInfo)
            $process.StandardInput.Write($PayloadRaw)
            $process.StandardInput.Close()
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout; Stderr = $stderr }
        }

        function Assert-CodexExactAllow {
            param([Parameter(Mandatory)] $Result)
            $Result.ExitCode | Should -Be 0
            $Result.Stdout | Should -BeExactly ''
            $Result.Stderr | Should -BeExactly ''
        }

        function Assert-CodexExactTransportFailure {
            param(
                [Parameter(Mandatory)] $Registration,
                [Parameter(Mandatory)] $Result,
                [Parameter(Mandatory)][ValidateSet('empty', 'malformed JSON')][string] $Failure
            )

            $name = [IO.Path]::GetFileNameWithoutExtension($Registration.HookName)
            $message = if ($Registration.HookName -eq 'authorize-root-parallel-invocation.ps1') {
                "PARALLEL_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is $Failure."
            } else {
                "$name hook input is $Failure."
            }
            $Result.ExitCode | Should -Be 2
            $Result.Stdout | Should -BeExactly ''
            $Result.Stderr | Should -BeExactly ($message + $script:Eol)
        }

        function Assert-CodexExactDeny {
            param([Parameter(Mandatory)] $Registration, [Parameter(Mandatory)] $Result)

            if ($Registration.HookName -eq 'authorize-root-parallel-invocation.ps1') {
                $Result.ExitCode | Should -Be 2
                $Result.Stdout | Should -BeExactly ''
                $Result.Stderr | Should -BeExactly (
                    'PARALLEL_INVOCATION_ORIGIN_BLOCKED: parallel entry skills may be invoked only by the root session.' +
                    $script:Eol
                )
                return
            }
            $Result.ExitCode | Should -Be 0
            $Result.Stderr | Should -BeExactly ''
            $decision = $Result.Stdout.TrimEnd("`r", "`n") | ConvertFrom-Json -ErrorAction Stop
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision |
                Should -BeExactly 'deny' -Because $Registration.HookName
            $reason | Should -Match ('^' + [regex]::Escape($script:ReasonCodes[$Registration.HookName]) + ':')
            $Result.Stdout | Should -BeExactly (($decision | ConvertTo-Json -Compress -Depth 5) + $script:Eol)
        }

        $script:AllRegistrations = @(Get-CodexHookRegistration -ConfigPath $script:ConfigPath)
        $script:ParallelRegistrations = @($script:AllRegistrations | Where-Object {
                $_.HookName -in $script:DirectHooks -or
                ($_.Event -in @('SubagentStart', 'SubagentStop') -and
                $_.Matcher -match 'parallel-planner' -and $_.Matcher -match 'parallel-orchestrator')
            })
        $script:DirectRegistrations = @($script:ParallelRegistrations | Where-Object HookName -In $script:DirectHooks)
        $script:DispatcherRegistrations = @($script:ParallelRegistrations | Where-Object Event -In @(
                'SubagentStart', 'SubagentStop'
            ))
    }

    It 'resolves all nine parallel registration rows from config with exact native metadata' {
        $script:ParallelRegistrations.Count | Should -Be 9
        $script:DirectRegistrations.Count | Should -Be 7
        @($script:ParallelRegistrations | Select-Object -ExpandProperty HookName -Unique).Count | Should -Be 9
        foreach ($registration in $script:ParallelRegistrations) {
            $registration.Type | Should -BeExactly 'command'
            $registration.Command | Should -BeExactly $registration.CommandWindows
            $registration.Timeout | Should -BeIn @(15, 30)
            Test-Path -LiteralPath (Resolve-CodexRegisteredHookPath -Registration $registration) -PathType Leaf |
                Should -BeTrue
        }
        @($script:ParallelRegistrations | Where-Object HookName -EQ 'parallel-hook-common.ps1').Count | Should -Be 0
        @($script:AllRegistrations | Where-Object HookName -EQ 'validate-parallel-agent-output.ps1').Count | Should -Be 0
    }

    It 'covers the complete seven-row by six-cell direct registered process matrix' {
        $visited = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($registration in $script:DirectRegistrations) {
            $allowPayload = ConvertTo-CodexRegisteredPayload -Registration $registration -Disposition allow
            $denyPayload = ConvertTo-CodexRegisteredPayload -Registration $registration -Disposition deny
            foreach ($cell in $script:TransportCells) {
                $null = $visited.Add("$($registration.HookName)|$cell")
                $activateChild = $registration.HookName -eq 'enforce-parallel-child-worktree-binding.ps1' -and $cell -eq 'deny'
                switch ($cell) {
                    'allow' {
                        Assert-CodexExactAllow (Invoke-CodexRegisteredHook $registration $allowPayload)
                    }
                    'deny' {
                        Assert-CodexExactDeny $registration (
                            Invoke-CodexRegisteredHook $registration $denyPayload -ActivateChildBinding:$activateChild
                        )
                    }
                    'malformed-stdin' {
                        Assert-CodexExactTransportFailure `
                            -Registration $registration `
                            -Result (Invoke-CodexRegisteredHook $registration '{not-json') `
                            -Failure 'malformed JSON'
                    }
                    'missing-stdin' {
                        Assert-CodexExactTransportFailure `
                            -Registration $registration `
                            -Result (Invoke-CodexRegisteredHook $registration '') `
                            -Failure empty
                    }
                    'poisoned-CLAUDE_TOOL_INPUT' {
                        Assert-CodexExactAllow (
                            Invoke-CodexRegisteredHook $registration $allowPayload -PoisonVariable CLAUDE_TOOL_INPUT
                        )
                    }
                    'poisoned-CLAUDE_SESSION_ID' {
                        Assert-CodexExactAllow (
                            Invoke-CodexRegisteredHook $registration $allowPayload -PoisonVariable CLAUDE_SESSION_ID
                        )
                    }
                }
            }
        }
        $visited.Count | Should -Be 42
        foreach ($registration in $script:DirectRegistrations) {
            foreach ($cell in $script:TransportCells) {
                $visited.Contains("$($registration.HookName)|$cell") | Should -BeTrue
            }
        }
    }

    It 'binds the G02 PreToolUse denial matrix to every registered parallel gate' {
        $preToolUseRegistrations = @(
            $script:DirectRegistrations | Where-Object Event -EQ 'PreToolUse'
        )
        $expectedHooks = @($script:ReasonCodes.Keys | Sort-Object)
        $actualHooks = @($preToolUseRegistrations.HookName | Sort-Object)

        $preToolUseRegistrations.Count | Should -Be 6
        $actualHooks | Should -BeExactly $expectedHooks
        $script:TransportCells | Should -Contain 'allow'
        $script:TransportCells | Should -Contain 'deny'
        foreach ($registration in $preToolUseRegistrations) {
            $script:ReasonCodes[$registration.HookName] |
                Should -Match '^PARALLEL_[A-Z_]+_BLOCKED$'
        }
    }

    It 'covers both config-resolved parallel persona dispatchers without duplicate direct validation' {
        $script:DispatcherRegistrations.Count | Should -Be 2
        @($script:DispatcherRegistrations | Where-Object Event -EQ 'SubagentStart').Count | Should -Be 1
        @($script:DispatcherRegistrations | Where-Object Event -EQ 'SubagentStop').Count | Should -Be 1
        $visited = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($registration in $script:DispatcherRegistrations) {
            $registration.Matcher | Should -Match 'parallel-planner'
            $registration.Matcher | Should -Match 'parallel-orchestrator'
            $registration.Command | Should -BeExactly $registration.CommandWindows
            $validPayload = ConvertTo-CodexDispatcherPayload $registration $true
            $invalidPayload = ConvertTo-CodexDispatcherPayload $registration $false
            foreach ($cell in $script:DispatcherCells) {
                $visited.Add("$($registration.Event)|$cell") | Should -BeTrue
                $arguments = @{ Registration = $registration; RejectAuthorityWrite = $true }
                switch ($cell) {
                    'valid-parallel' { $arguments.PayloadRaw = $validPayload }
                    'invalid-parallel' { $arguments.PayloadRaw = $invalidPayload }
                    'malformed-stdin' { $arguments.PayloadRaw = '{not-json' }
                    'missing-stdin' { $arguments.PayloadRaw = '' }
                    'poisoned-CLAUDE_TOOL_INPUT' {
                        $arguments.PayloadRaw = $validPayload
                        $arguments.PoisonVariable = 'CLAUDE_TOOL_INPUT'
                    }
                    'poisoned-CLAUDE_SESSION_ID' {
                        $arguments.PayloadRaw = $validPayload
                        $arguments.PoisonVariable = 'CLAUDE_SESSION_ID'
                    }
                }
                $result = Invoke-CodexRegisteredHook @arguments
                $result.ExitCode | Should -Be 2 -Because "$($registration.Event)|$cell"
                $result.Stdout | Should -BeExactly '' -Because "$($registration.Event)|$cell"
                if ($cell -in @('valid-parallel', 'poisoned-CLAUDE_TOOL_INPUT', 'poisoned-CLAUDE_SESSION_ID')) {
                    $result.Stderr | Should -BeExactly (
                        'EPIC_INVOCATION_ORIGIN_BLOCKED: the Codex authority store must be outside the repository workspace.' +
                        $script:Eol
                    )
                } elseif ($cell -eq 'invalid-parallel') {
                    $expected = if ($registration.Event -eq 'SubagentStart') {
                        "Cannot bind argument to parameter 'SessionId' because it is an empty string."
                    } else {
                        'MODEL_ROUTING_ATTESTATION_BLOCKED: SubagentStop session_id is empty.'
                    }
                    $result.Stderr | Should -BeExactly ($expected + $script:Eol)
                } elseif ($cell -eq 'missing-stdin') {
                    $expected = if ($registration.Event -eq 'SubagentStart') {
                        'MODEL_ROUTING_ATTESTATION_BLOCKED: SubagentStart input is empty.'
                    } else {
                        "Cannot bind argument to parameter 'Raw' because it is an empty string."
                    }
                    $result.Stderr | Should -BeExactly ($expected + $script:Eol)
                } else {
                    $result.Stderr | Should -BeExactly (
                        "MODEL_ROUTING_ATTESTATION_BLOCKED: $($registration.Event) input is malformed JSON: " +
                        "Conversion from JSON failed with error: Invalid JavaScript property identifier character: -. " +
                        "Path '', line 1, position 4." + $script:Eol
                    )
                }
            }
        }
        $visited.Count | Should -Be 12
        @($visited | Where-Object { $_ -match '\.ps1\|' }).Count | Should -Be 0
    }

    It 'leaves repository state unchanged' {
        $finalState = @(
            Get-ChildItem -LiteralPath $script:StatePath -File -ErrorAction SilentlyContinue |
                ForEach-Object { "$( $_.Name )|$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)" }
        )
        $finalState | Should -BeExactly $script:InitialState
    }
}
