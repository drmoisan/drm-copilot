#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Every registered Codex PreToolUse handler accepts every tool name its matcher admits' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:ConfigPath = Join-Path $script:RepoRoot '.codex/config.toml'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source

        # Candidate tool names probed against each matcher regex. A future
        # registration cannot silently escape coverage, because the registration
        # set and the admitted names are both derived from config.toml.
        $script:CandidateToolNames = @('Bash', 'shell_command', 'apply_patch', 'Edit', 'Write', 'mcp__drm_copilot__run_poshqc_format')

        function Get-CodexPreToolUseRegistration {
            <#
                Parses .codex/config.toml and returns one record per registered
                PreToolUse handler: its matcher regex and its hook file name.
                Follows the line-scanning pattern of
                codex-epic-runtime-contracts.Tests.ps1.
            #>
            param([Parameter(Mandatory)][string] $ConfigPath)

            $registrations = [System.Collections.Generic.List[object]]::new()
            $currentMatcher = $null
            $inPreToolUseGroup = $false

            # Walk the file once, tracking which matcher group each handler block
            # belongs to. A new [[hooks.X]] table resets the current matcher.
            foreach ($line in (Get-Content -LiteralPath $ConfigPath)) {
                if ($line -match '^\[\[hooks\.PreToolUse\]\]$') {
                    $inPreToolUseGroup = $true
                    $currentMatcher = $null
                    continue
                }
                if ($line -match '^\[\[hooks\.(?<event>[A-Za-z]+)\]\]$') {
                    $inPreToolUseGroup = ($Matches['event'] -eq 'PreToolUse')
                    $currentMatcher = $null
                    continue
                }
                if ($inPreToolUseGroup -and $line -match '^matcher\s*=\s*"(?<matcher>.+)"\s*$') {
                    $currentMatcher = $Matches['matcher']
                    continue
                }
                if ($inPreToolUseGroup -and $currentMatcher -and
                    $line -match '^command\s*=\s*''pwsh[^'']*/\.codex/hooks/(?<hook>[^/'']+\.ps1)"?''\s*$') {
                    $registrations.Add([pscustomobject]@{
                            Matcher  = $currentMatcher
                            HookName = $Matches['hook']
                        })
                }
            }

            return $registrations.ToArray()
        }

        function Get-CodexBenignToolInput {
            <#
                Returns a benign tool_input for one tool name. Every payload targets
                README.md or a read-only command so no handler writes state and no
                handler denies.
            #>
            param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][string] $RepoRoot)

            # Routing table: patch-shaped, file-shaped, command-shaped, or MCP-shaped.
            switch -Regex ($ToolName) {
                '^apply_patch$' { return @{ command = "*** Begin Patch`n*** Add File: README.md`n+safe`n*** End Patch" } }
                '^Edit$' { return @{ file_path = 'README.md'; old_string = 'a'; new_string = 'b' } }
                '^Write$' { return @{ file_path = 'README.md'; content = 'safe' } }
                '^mcp__' { return @{ workspace_root = $RepoRoot } }
                default { return @{ command = 'git status' } }
            }
        }

        function Invoke-CodexHookProcess {
            param(
                [Parameter(Mandatory)][string] $HookName,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshPath
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-File')
            $startInfo.ArgumentList.Add((Join-Path $script:HookRoot $HookName))
            $startInfo.WorkingDirectory = $script:RepoRoot
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false
            $startInfo.Environment['CLAUDE_TOOL_INPUT'] = '{"command":"git reset --hard"}'
            $startInfo.Environment['CLAUDE_SESSION_ID'] = 'poisoned-legacy-session'

            $process = [System.Diagnostics.Process]::Start($startInfo)
            $process.StandardInput.Write($PayloadRaw)
            $process.StandardInput.Close()
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()

            return [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout   = $stdout.Trim()
                Stderr   = $stderr.Trim()
            }
        }

        function ConvertTo-CodexPreToolPayload {
            param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][hashtable] $ToolInput)

            return [ordered]@{
                session_id      = 'native-hook-contract'
                transcript_path = $null
                cwd             = $script:RepoRoot
                hook_event_name = 'PreToolUse'
                model           = 'gpt-5.6-terra'
                permission_mode = 'default'
                turn_id         = 'turn-contract'
                tool_name       = $ToolName
                tool_use_id     = 'tool-contract'
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        $script:Registrations = Get-CodexPreToolUseRegistration -ConfigPath $script:ConfigPath
        $script:RegisteredHookNames = @($script:Registrations | ForEach-Object { $_.HookName } | Select-Object -Unique)
    }

    It 'parses at least three matcher groups and every registered handler from config.toml' {
        # Guards the derivation itself: a silently empty parse would make the
        # matrix below vacuously green.
        @($script:Registrations).Count | Should -BeGreaterThan 0
        @($script:Registrations | ForEach-Object { $_.Matcher } | Select-Object -Unique).Count | Should -BeGreaterOrEqual 3
        $script:RegisteredHookNames | Should -Contain 'check-python-test-purity.ps1'
        $script:RegisteredHookNames | Should -Contain 'enforce-completion-consistency.ps1'
        $script:RegisteredHookNames | Should -Contain 'validate-bash.ps1'

        foreach ($name in $script:RegisteredHookNames) {
            Test-Path -LiteralPath (Join-Path $script:HookRoot $name) -PathType Leaf |
                Should -BeTrue -Because "$name is registered and must exist on disk"
        }
    }

    It 'allows every registered handler for every tool name its own matcher admits' {
        $failures = [System.Collections.Generic.List[string]]::new()

        # Cross every registration with the candidate names its matcher admits, so
        # coverage tracks config.toml rather than a hand-maintained list.
        foreach ($registration in $script:Registrations) {
            $admitted = @($script:CandidateToolNames | Where-Object { $_ -match $registration.Matcher })

            foreach ($toolName in $admitted) {
                $toolInput = Get-CodexBenignToolInput -ToolName $toolName -RepoRoot $script:RepoRoot
                $payload = ConvertTo-CodexPreToolPayload -ToolName $toolName -ToolInput $toolInput
                $result = Invoke-CodexHookProcess -HookName $registration.HookName -PayloadRaw $payload

                if ($result.ExitCode -ne 0 -or -not [string]::IsNullOrEmpty($result.Stdout)) {
                    $failures.Add(("{0} x {1}: exit={2} stdout=[{3}] stderr=[{4}]" -f `
                                $registration.HookName, $toolName, $result.ExitCode, $result.Stdout, $result.Stderr))
                }
            }
        }

        $failures -join "`n" | Should -BeNullOrEmpty -Because 'every registered handler must allow a benign admitted payload'
    }

    It 'fails closed with exit 2 for <Label> on every registered handler' -ForEach @(
        @{ Label = 'empty stdin'; Payload = '' }
        @{ Label = 'invalid JSON'; Payload = '{not-json' }
    ) {
        foreach ($name in $script:RegisteredHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $Payload

            $result.ExitCode | Should -Be 2 -Because "$name must fail closed on $Label"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Not -BeNullOrEmpty
        }
    }

    It 'reports enforce-completion-consistency in its own stderr rather than its neighbour' {
        # Regression for the shared-validator misattribution recorded in spec.md:52.
        foreach ($payload in @('', '{not-json', '{"session_id":"s","tool_input":null}')) {
            $result = Invoke-CodexHookProcess -HookName 'enforce-completion-consistency.ps1' -PayloadRaw $payload

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'enforce-completion-consistency'
            $result.Stderr | Should -Not -Match 'enforce-checkpoint-monotonic'
        }
    }

    It 'leaves no Codex batch-budget state behind' {
        # Convention C4: every payload above targets README.md or a read-only
        # command, so the batch-budget entrypoints must never write state.
        $syntheticPythonState = Join-Path $script:RepoRoot '.codex/state/python-batch-budget.native-hook-contract.json'
        $syntheticPowerShellState = Join-Path $script:RepoRoot '.codex/state/powershell-batch-budget.native-hook-contract.json'

        Test-Path -LiteralPath $syntheticPythonState |
            Should -BeFalse -Because 'benign payloads must not create Python batch-budget state for the synthetic session'
        Test-Path -LiteralPath $syntheticPowerShellState |
            Should -BeFalse -Because 'benign payloads must not create PowerShell batch-budget state for the synthetic session'
    }
}
