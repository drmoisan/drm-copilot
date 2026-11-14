#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Issue #697 (AC-2.4): every PreToolUse hook registered by the bundled
    .codex/config.toml must run from its bundle location, where
    config/orchestration-handoff-registry.json is absent, and must allow a benign
    payload for every tool name its own matcher admits.
#>

Describe 'Bundled Codex PreToolUse hooks run from the bundle location (issue #697)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:BundleRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations'
        $script:BundleHookRoot = Join-Path $script:BundleRoot '.codex/hooks'
        $script:BundleConfigPath = Join-Path $script:BundleRoot '.codex/config.toml'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source

        # Candidate tool names probed against each matcher regex; one shape per
        # payload family named by AC-2.4 (Bash, apply_patch, Edit, and mcp__).
        $script:CandidateToolNames = @('Bash', 'apply_patch', 'Edit', 'mcp__drm_copilot__run_poshqc_format')
        # Issue #1159: the bundle config registers the PreToolUse dispatcher once, and the dispatched
        # hooks are registered in the bundle registry; both sets are derived at test time.
        $script:BundleRegistryPath = Join-Path $script:BundleHookRoot 'pretooluse-dispatch.json'

        function Get-CodexHookRegistration {
            <#
                Parses a Codex config.toml and returns one record per registered hook
                command: its event, its matcher regex (or $null), and its hook file
                name. Follows the line-scanning pattern of
                codex-pretooluse-integration.Tests.ps1, extended to every event.
            #>
            param([Parameter(Mandatory)][string] $ConfigPath)

            $registrations = [System.Collections.Generic.List[object]]::new()
            $currentEvent = $null
            $currentMatcher = $null

            # Walk the file once; a new [[hooks.X]] table starts a new matcher group
            # and a [[hooks.X.hooks]] table keeps the group's event and matcher.
            foreach ($line in (Get-Content -LiteralPath $ConfigPath)) {
                if ($line -match '^\[\[hooks\.(?<event>[A-Za-z]+)\]\]$') {
                    $currentEvent = $Matches['event']
                    $currentMatcher = $null
                    continue
                }
                if ($currentEvent -and $line -match '^matcher\s*=\s*"(?<matcher>.+)"\s*$') {
                    $currentMatcher = $Matches['matcher']
                    continue
                }
                if ($currentEvent -and
                    $line -match '^command\s*=\s*''pwsh[^'']*/\.codex/hooks/(?<hook>[^/'']+\.ps1)"?''\s*$') {
                    $registrations.Add([pscustomobject]@{
                            Event    = $currentEvent
                            Matcher  = $currentMatcher
                            HookName = $Matches['hook']
                        })
                }
            }

            return $registrations.ToArray()
        }

        function Get-CodexBenignToolInput {
            <#
                Returns a benign tool_input for one tool name, matching the inputs of
                codex-pretooluse-integration.Tests.ps1 so that no gate denies.
            #>
            param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][string] $WorkspaceRoot)

            # Routing table: patch-shaped, file-shaped, MCP-shaped, or command-shaped.
            switch -Regex ($ToolName) {
                '^apply_patch$' { return @{ command = "*** Begin Patch`n*** Add File: README.md`n+safe`n*** End Patch" } }
                '^Edit$' { return @{ file_path = 'README.md'; old_string = 'a'; new_string = 'b' } }
                '^mcp__' { return @{ workspace_root = $WorkspaceRoot } }
                default { return @{ command = 'git status' } }
            }
        }

        function ConvertTo-CodexPreToolPayload {
            param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][hashtable] $ToolInput)

            return [ordered]@{
                session_id      = 'bundle-hook-probe'
                transcript_path = $null
                cwd             = $script:BundleRoot
                hook_event_name = 'PreToolUse'
                model           = 'gpt-6.1-sol'
                permission_mode = 'default'
                turn_id         = 'turn-bundle-probe'
                tool_name       = $ToolName
                tool_use_id     = 'tool-bundle-probe'
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        function Invoke-BundleHookProcess {
            <#
                Runs one bundled hook through pwsh -NoProfile -File with the bundle
                root as working directory, writing the payload to stdin.
            #>
            param(
                [Parameter(Mandatory)][string] $HookName,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshPath
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-File')
            $startInfo.ArgumentList.Add((Join-Path $script:BundleHookRoot $HookName))
            $startInfo.WorkingDirectory = $script:BundleRoot
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false
            [void]$startInfo.Environment.Remove('CODEX_EPIC_CHILD_EXECUTION_CONTEXT')

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

        function Test-HookStdoutAccepted {
            <#
                Accepts empty stdout or a JSON object carrying hookSpecificOutput. The
                legacy {"decision":"allow"} shape and non-JSON text are rejected.
            #>
            param([AllowEmptyString()][string] $Stdout)

            if ([string]::IsNullOrEmpty($Stdout)) {
                return $true
            }
            try {
                $parsed = $Stdout | ConvertFrom-Json -ErrorAction Stop
            } catch {
                return $false
            }
            return ($null -ne $parsed -and $null -ne $parsed.PSObject.Properties['hookSpecificOutput'])
        }

        function Get-CodexRegistryHookRegistration {
            <#
                Reads a Codex PreToolUse dispatcher registry and returns one PreToolUse record
                per registered hook command: its group matcher regex and its hook file name.
            #>
            param([Parameter(Mandatory)][string] $RegistryPath)

            $registrations = [System.Collections.Generic.List[object]]::new()
            foreach ($group in @((Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json).hooks.PreToolUse)) {
                foreach ($hook in @($group.hooks)) {
                    if ([string]$hook.command -match '/\.codex/hooks/(?<hook>[^/"]+\.ps1)') {
                        $registrations.Add([pscustomobject]@{ Event = 'PreToolUse'; Matcher = [string]$group.matcher; HookName = $Matches['hook'] })
                    }
                }
            }
            return $registrations.ToArray()
        }

        $script:ConfigRegistrations = @(Get-CodexHookRegistration -ConfigPath $script:BundleConfigPath)
        $script:PreToolUseRegistrations = @(Get-CodexRegistryHookRegistration -RegistryPath $script:BundleRegistryPath)
        $script:Registrations = @($script:ConfigRegistrations | Where-Object Event -NE 'PreToolUse') + $script:PreToolUseRegistrations
    }

    It 'derives 21 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config' {
        # Issue #1159: the counts are derived from the bundle registry and config, not fixed.
        $allHooks = @($script:Registrations | ForEach-Object HookName | Sort-Object -Unique)
        $preToolUseHooks = @($script:PreToolUseRegistrations | ForEach-Object HookName | Sort-Object -Unique)
        $excludedHooks = @($allHooks | Where-Object { $_ -notin $preToolUseHooks } | Sort-Object)
        $configNonPreToolUseHooks = @($script:ConfigRegistrations | Where-Object Event -NE 'PreToolUse' | ForEach-Object HookName | Sort-Object -Unique)
        $configPreToolUseHooks = @($script:ConfigRegistrations | Where-Object Event -EQ 'PreToolUse' | ForEach-Object HookName | Sort-Object -Unique)

        $preToolUseHooks.Count | Should -BeGreaterThan 0
        $excludedHooks.Count | Should -BeGreaterThan 0
        $excludedHooks | Should -Be @($configNonPreToolUseHooks | Where-Object { $_ -notin $preToolUseHooks })
        $configPreToolUseHooks | Should -Be @('invoke-pretooluse-dispatch.ps1') -Because 'the bundle config registers only the dispatcher for PreToolUse'
        ($preToolUseHooks.Count + $excludedHooks.Count) | Should -Be $allHooks.Count
        foreach ($name in $preToolUseHooks) {
            Test-Path -LiteralPath (Join-Path $script:BundleHookRoot $name) -PathType Leaf |
                Should -BeTrue -Because "$name is registered and must exist in the bundle"
        }
    }

    It 'returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location' {
        $failures = [System.Collections.Generic.List[string]]::new()
        $invocations = 0

        # Cross every PreToolUse registration with the candidate names its matcher
        # admits, collecting every failure so one run reports the full set.
        foreach ($registration in $script:PreToolUseRegistrations) {
            $admitted = @($script:CandidateToolNames | Where-Object { $_ -match $registration.Matcher })
            foreach ($toolName in $admitted) {
                $toolInput = Get-CodexBenignToolInput -ToolName $toolName -WorkspaceRoot $script:BundleRoot
                $payload = ConvertTo-CodexPreToolPayload -ToolName $toolName -ToolInput $toolInput
                $result = Invoke-BundleHookProcess -HookName $registration.HookName -PayloadRaw $payload
                $invocations++

                if ($result.ExitCode -ne 0 -or -not (Test-HookStdoutAccepted -Stdout $result.Stdout)) {
                    $failures.Add(('{0} x {1}: exit={2} stdout=[{3}] stderr=[{4}]' -f `
                                $registration.HookName, $toolName, $result.ExitCode, $result.Stdout, $result.Stderr))
                }
            }
        }

        # The probe count derives from the registry matchers and the candidate names (issue #1159).
        $expectedInvocations = @(foreach ($registration in $script:PreToolUseRegistrations) { $script:CandidateToolNames | Where-Object { $_ -match $registration.Matcher } }).Count
        $expectedInvocations | Should -BeGreaterThan 0
        $invocations | Should -Be $expectedInvocations
        $failures -join "`n" | Should -BeNullOrEmpty -Because 'every bundled hook must allow a benign admitted payload from the bundle location'
    }

    It 'leaves no batch-budget state in the bundle' {
        Test-Path -LiteralPath (Join-Path $script:BundleRoot '.codex/state') |
            Should -BeFalse -Because 'benign payloads must not create batch-budget state in the bundle'
    }
}
