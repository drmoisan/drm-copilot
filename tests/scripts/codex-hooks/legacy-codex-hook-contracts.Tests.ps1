#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Legacy Codex hooks use native lifecycle contracts' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:BundleHookRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
        $script:PreToolHookNames = @(
            'validate-bash.ps1',
            'enforce-promotion-mcp-only.ps1',
            'enforce-orchestration-preimplementation-gate.ps1',
            'check-python-test-purity.ps1',
            'enforce-python-batch-budget.ps1',
            'check-powershell-test-purity.ps1',
            'enforce-powershell-batch-budget.ps1',
            'enforce-evidence-locations.ps1',
            'enforce-checkpoint-monotonic.ps1',
            'enforce-completion-consistency.ps1'
        )
        $script:AllHookNames = @($script:PreToolHookNames) + @('validate-feature-review-coverage.ps1')

        function ConvertTo-CodexPreToolPayload {
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput
            )

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

        function ConvertTo-CodexPatchPayload {
            param([Parameter(Mandatory)][string] $Patch)

            return ConvertTo-CodexPreToolPayload -ToolName 'apply_patch' -ToolInput @{ command = $Patch }
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
    }

    It 'parse-checks each root and bundled hook and keeps every file within 500 lines' {
        foreach ($name in $script:AllHookNames) {
            foreach ($root in @($script:HookRoot, $script:BundleHookRoot)) {
                $path = Join-Path $root $name
                $tokens = $null
                $errors = $null
                [System.Management.Automation.Language.Parser]::ParseFile(
                    $path,
                    [ref]$tokens,
                    [ref]$errors
                ) | Out-Null

                $errors | Should -BeNullOrEmpty -Because "$path must parse"
                (Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500
            }
        }
    }

    It 'keeps the canonical hooks byte-identical to their bundled copies' {
        foreach ($name in $script:AllHookNames) {
            $rootHash = (Get-FileHash -LiteralPath (Join-Path $script:HookRoot $name)).Hash
            $bundleHash = (Get-FileHash -LiteralPath (Join-Path $script:BundleHookRoot $name)).Hash
            $bundleHash | Should -Be $rootHash -Because "$name must publish without drift"
        }
    }

    It 'reads stdin and contains no legacy Claude environment-variable dependency' {
        foreach ($name in $script:AllHookNames) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $script:HookRoot $name)
            $content | Should -Match '\[Console\]::In\.ReadToEnd\(\)'
            $content | Should -Not -Match '\$env:CLAUDE_'
        }
    }

    It 'ignores poisoned Claude variables when safe Codex stdin payloads are supplied' {
        $safePatch = "*** Begin Patch`n*** Add File: README.md`n+safe`n*** End Patch"
        $safePatchPayload = ConvertTo-CodexPatchPayload -Patch $safePatch
        $safeBashPayload = ConvertTo-CodexPreToolPayload -ToolName 'Bash' -ToolInput @{ command = 'git status' }

        foreach ($name in $script:PreToolHookNames) {
            $payload = if ($name -in @('validate-bash.ps1', 'enforce-promotion-mcp-only.ps1')) {
                $safeBashPayload
            } else {
                $safePatchPayload
            }
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $payload

            $result.ExitCode | Should -Be 0 -Because "$name must accept a valid safe stdin payload"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }
    }

    It 'fails closed with exit 2 and stderr for malformed stdin on every hook' {
        foreach ($name in $script:AllHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw '{not-json'

            $result.ExitCode | Should -Be 2 -Because "$name must fail closed"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Not -BeNullOrEmpty
        }
    }

    It 'emits the current PreToolUse deny envelope for shell and patch violations' {
        $badPythonPatch = "*** Begin Patch`n*** Add File: tests/unit/test_bad.py`n+import tempfile`n*** End Patch"
        $badPowerShellPatch = "*** Begin Patch`n*** Add File: tests/scripts/bad.Tests.ps1`n+Start-Sleep -Seconds 1`n*** End Patch"
        $badEvidencePatch = "*** Begin Patch`n*** Add File: artifacts/research/bad.md`n+bad`n*** End Patch"
        $badOrder = '{"completed_steps":["S5_atomic_execution","S4_atomic_planning"]}'
        $badOrderPatch = "*** Begin Patch`n*** Add File: artifacts/orchestration/orchestrator-state.json`n+$badOrder`n*** End Patch"
        $badCompletion = '{"next_step":"complete","completed_steps":["S12_complete"]}'
        $badCompletionPatch = "*** Begin Patch`n*** Add File: artifacts/orchestration/orchestrator-state.json`n+$badCompletion`n*** End Patch"
        $cases = @(
            @{ Name = 'validate-bash.ps1'; Payload = ConvertTo-CodexPreToolPayload -ToolName 'Bash' -ToolInput @{ command = 'git reset --hard' }; Marker = 'git reset --hard' },
            @{ Name = 'enforce-promotion-mcp-only.ps1'; Payload = ConvertTo-CodexPreToolPayload -ToolName 'Bash' -ToolInput @{ command = 'gh issue create --title bad' }; Marker = 'PROMOTION_MCP_ONLY_BLOCKED' },
            @{ Name = 'check-python-test-purity.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $badPythonPatch; Marker = 'tempfile usage forbidden' },
            @{ Name = 'check-powershell-test-purity.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $badPowerShellPatch; Marker = 'Start-Sleep forbidden' },
            @{ Name = 'enforce-evidence-locations.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $badEvidencePatch; Marker = 'EVIDENCE_LOCATION_BLOCKED' },
            @{ Name = 'enforce-checkpoint-monotonic.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $badOrderPatch; Marker = 'CHECKPOINT_ORDER_BLOCKED' },
            @{ Name = 'enforce-completion-consistency.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $badCompletionPatch; Marker = 'COMPLETION_CONSISTENCY_BLOCKED' }
        )

        foreach ($case in $cases) {
            $result = Invoke-CodexHookProcess -HookName $case.Name -PayloadRaw $case.Payload
            $decision = $result.Stdout | ConvertFrom-Json

            $result.ExitCode | Should -Be 0
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $case.Marker
        }
    }

    It 'fails closed when the canonical checkpoint is deleted or becomes invalid JSON' {
        $deletePatch = "*** Begin Patch`n*** Delete File: artifacts/orchestration/orchestrator-state.json`n*** End Patch"
        $invalidPatch = "*** Begin Patch`n*** Add File: artifacts/orchestration/orchestrator-state.json`n+{not-json`n*** End Patch"
        foreach ($case in @(
                @{ Name = 'enforce-checkpoint-monotonic.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $deletePatch; Marker = 'CHECKPOINT_ORDER_BLOCKED' },
                @{ Name = 'enforce-checkpoint-monotonic.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $invalidPatch; Marker = 'CHECKPOINT_ORDER_BLOCKED' },
                @{ Name = 'enforce-completion-consistency.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $deletePatch; Marker = 'COMPLETION_CONSISTENCY_BLOCKED' },
                @{ Name = 'enforce-completion-consistency.ps1'; Payload = ConvertTo-CodexPatchPayload -Patch $invalidPatch; Marker = 'COMPLETION_CONSISTENCY_BLOCKED' }
            )) {
            $result = Invoke-CodexHookProcess -HookName $case.Name -PayloadRaw $case.Payload
            $decision = $result.Stdout | ConvertFrom-Json

            $result.ExitCode | Should -Be 0
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $case.Marker
        }
    }

    It 'denies preimplementation and batch-budget violations through their pure decisions' {
        . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')
        $implementation = @{ file_path = 'src/contract.py'; content = 'value = 1' } | ConvertTo-Json -Compress
        $gateDecision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $implementation -CheckpointRaw '{}'
        $gateDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $gateDecision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'

        . (Join-Path $script:HookRoot 'enforce-python-batch-budget.ps1')
        $pythonState = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $pythonState.prodFiles = @('src/first.py')
        $pythonDecision = Invoke-PythonBatchBudgetDecision -FilePath 'src/second.py' -State $pythonState -StateFile '.codex/state/python.json'
        $pythonDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'

        . (Join-Path $script:HookRoot 'enforce-powershell-batch-budget.ps1')
        $powerShellState = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $powerShellState.prodFiles = @('scripts/first.ps1')
        $powerShellDecision = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $powerShellState -StateFile '.codex/state/powershell.json'
        $powerShellDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'reconstructs update patches in memory and includes move destinations' {
        . (Join-Path $script:HookRoot 'enforce-checkpoint-monotonic.ps1')
        $updatePatch = "*** Begin Patch`n*** Update File: config/orchestration-routing.json`n@@`n-{`n+{`n*** End Patch"
        $updatePayload = (ConvertTo-CodexPatchPayload -Patch $updatePatch) | ConvertFrom-Json
        $toolInput = @(ConvertTo-CodexApplyPatchCheckpointInput -Payload $updatePayload) | Select-Object -First 1
        $expected = (Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'config/orchestration-routing.json')) -replace "`r`n", "`n"

        $toolInput.file_path | Should -Be 'config/orchestration-routing.json'
        $toolInput.content | Should -BeExactly $expected

        . (Join-Path $script:HookRoot 'enforce-evidence-locations.ps1')
        $movePatch = "*** Begin Patch`n*** Update File: README.md`n*** Move to: artifacts/research/moved.md`n@@`n-old`n+new`n*** End Patch"
        $movePayload = (ConvertTo-CodexPatchPayload -Patch $movePatch) | ConvertFrom-Json
        $paths = @(Get-CodexEvidenceLocationPath -Payload $movePayload)
        $paths | Should -Contain 'README.md'
        $paths | Should -Contain 'artifacts/research/moved.md'
    }

    It 'uses one SubagentStop continuation and stops repeated continuation loops' {
        . (Join-Path $script:HookRoot 'validate-feature-review-coverage.ps1')

        $first = Get-FeatureReviewCoverageContinuation -Reason 'coverage failed' -StopHookActive $false
        $first.decision | Should -Be 'block'
        $first.reason | Should -Be 'coverage failed'

        $repeated = Get-FeatureReviewCoverageContinuation -Reason 'coverage failed' -StopHookActive $true
        $repeated.continue | Should -BeFalse
        $repeated.stopReason | Should -Be 'coverage failed'
        $repeated.systemMessage | Should -Be 'coverage failed'
    }
}
