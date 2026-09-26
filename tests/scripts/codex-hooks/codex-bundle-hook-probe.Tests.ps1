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
        $script:ExpectedExcludedHooks = @(
            'authorize-root-epic-invocation.ps1',
            'record-subagent-routing-attestation.ps1',
            'validate-codex-subagent-routing.ps1',
            'validate-feature-review-coverage.ps1'
        )

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
                model           = 'gpt-5.6-terra'
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

        $script:Registrations = @(Get-CodexHookRegistration -ConfigPath $script:BundleConfigPath)
        $script:PreToolUseRegistrations = @($script:Registrations | Where-Object Event -EQ 'PreToolUse')
    }

    It 'derives 17 PreToolUse hooks and excludes 4 non-PreToolUse registrations from the bundle config' {
        $allHooks = @($script:Registrations | ForEach-Object HookName | Sort-Object -Unique)
        $preToolUseHooks = @($script:PreToolUseRegistrations | ForEach-Object HookName | Sort-Object -Unique)
        $excludedHooks = @($allHooks | Where-Object { $_ -notin $preToolUseHooks } | Sort-Object)

        $allHooks.Count | Should -Be 21
        $preToolUseHooks.Count | Should -Be 17
        $excludedHooks | Should -Be @($script:ExpectedExcludedHooks | Sort-Object)
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

        $invocations | Should -Be 41
        $failures -join "`n" | Should -BeNullOrEmpty -Because 'every bundled hook must allow a benign admitted payload from the bundle location'
    }

    It 'leaves no batch-budget state in the bundle' {
        Test-Path -LiteralPath (Join-Path $script:BundleRoot '.codex/state') |
            Should -BeFalse -Because 'benign payloads must not create batch-budget state in the bundle'
    }
}
