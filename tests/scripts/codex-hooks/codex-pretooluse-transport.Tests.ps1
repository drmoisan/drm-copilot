#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex PreToolUse hooks honour the native stdin transport contract' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source

        # The eight handlers registered under the ^(apply_patch|Edit|Write)$ matcher.
        $script:GroupHookNames = @(
            'check-python-test-purity.ps1',
            'enforce-python-batch-budget.ps1',
            'check-powershell-test-purity.ps1',
            'enforce-powershell-batch-budget.ps1',
            'enforce-evidence-locations.ps1',
            'enforce-orchestration-preimplementation-gate.ps1',
            'enforce-checkpoint-monotonic.ps1',
            'enforce-completion-consistency.ps1'
        )
        $script:BatchBudgetHookNames = @(
            'enforce-python-batch-budget.ps1',
            'enforce-powershell-batch-budget.ps1'
        )
        $script:CheckpointHookNames = @(
            'enforce-checkpoint-monotonic.ps1',
            'enforce-completion-consistency.ps1'
        )
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

        function Invoke-CodexHookProcess {
            <#
                Feeds one payload to a hook over stdin. Legacy Claude variables are
                poisoned on every invocation, so each case doubles as proof that no
                hook reads them.
            #>
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
    }

    It 'allows a safe <ToolName> payload on every group handler' -ForEach @(
        @{ ToolName = 'Edit'; ToolInput = @{ file_path = 'README.md'; old_string = 'a'; new_string = 'b' } }
        @{ ToolName = 'Write'; ToolInput = @{ file_path = 'README.md'; content = 'safe' } }
        @{ ToolName = 'apply_patch'; ToolInput = @{ command = "*** Begin Patch`n*** Add File: README.md`n+safe`n*** End Patch" } }
    ) {
        $payload = ConvertTo-CodexPreToolPayload -ToolName $ToolName -ToolInput $ToolInput

        foreach ($name in $script:GroupHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $payload

            $result.ExitCode | Should -Be 0 -Because "$name must accept a safe $ToolName payload"
            $result.Stdout | Should -BeNullOrEmpty -Because "$name must allow silently"
            $result.Stderr | Should -BeNullOrEmpty -Because "$name must not report a transport error"
        }
    }

    It 'allows a well-formed apply_patch payload whose tool_input maps to no file edit (<Label>)' -ForEach @(
        @{ Label = "command:''"; Command = '' }
        @{ Label = "command:'noop'"; Command = 'noop' }
    ) {
        # Well-formed input naming nothing the hook governs is an allow, not a
        # transport failure. This is the second half of the defect in issue #415.
        $payload = ConvertTo-CodexPreToolPayload -ToolName 'apply_patch' -ToolInput @{ command = $Command }

        foreach ($name in $script:GroupHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $payload

            $result.ExitCode | Should -Be 0 -Because "$name must allow unmapped apply_patch input"
            $result.Stdout | Should -BeNullOrEmpty -Because "$name must produce no stdout when allowing"
        }
    }

    It 'fails closed with exit 2 when a batch-budget payload omits session_id' {
        # The batch counter is keyed by session_id, so its absence stays fatal.
        $payload = '{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"README.md","old_string":"a","new_string":"b"}}'

        foreach ($name in $script:BatchBudgetHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $payload

            $result.ExitCode | Should -Be 2 -Because "$name requires session_id"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Not -BeNullOrEmpty
            $result.Stderr | Should -Match 'session_id'
        }
    }

    It 'allows an apply_patch update that touches only ungoverned files with a missing source' {
        # Regression for the latent defect at spec.md:98. Before the fix, any
        # unreadable update source made the checkpoint hooks exit 2 even when they
        # governed none of the patched files.
        $patch = "*** Begin Patch`n*** Update File: does/not/exist/anywhere.json`n@@`n-old`n+new`n*** End Patch"
        $payload = ConvertTo-CodexPreToolPayload -ToolName 'apply_patch' -ToolInput @{ command = $patch }

        foreach ($name in $script:CheckpointHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $payload

            $result.ExitCode | Should -Be 0 -Because "$name governs none of the patched files"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }
    }

    It 'emits only the native deny envelope for <HookName> on a forbidden <ToolName> payload' -ForEach @(
        # Purity hooks. The Edit record carries new_string, the Write record carries
        # content, and the apply_patch record carries the added patch lines; each
        # reaches the same unchanged forbidden-pattern policy.
        @{ HookName = 'check-python-test-purity.ps1'; ToolName = 'Edit'; Marker = 'tempfile usage forbidden'
            ToolInput = @{ file_path = 'tests/unit/test_bad.py'; old_string = 'x'; new_string = 'import tempfile' }
        }
        @{ HookName = 'check-python-test-purity.ps1'; ToolName = 'Write'; Marker = 'tempfile usage forbidden'
            ToolInput = @{ file_path = 'tests/unit/test_bad.py'; content = 'import tempfile' }
        }
        @{ HookName = 'check-python-test-purity.ps1'; ToolName = 'apply_patch'; Marker = 'tempfile usage forbidden'
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: tests/unit/test_bad.py`n+import tempfile`n*** End Patch" }
        }
        @{ HookName = 'check-powershell-test-purity.ps1'; ToolName = 'Edit'; Marker = 'Start-Sleep forbidden'
            ToolInput = @{ file_path = 'tests/scripts/bad.Tests.ps1'; old_string = 'x'; new_string = 'Start-Sleep -Seconds 1' }
        }
        @{ HookName = 'check-powershell-test-purity.ps1'; ToolName = 'Write'; Marker = 'Start-Sleep forbidden'
            ToolInput = @{ file_path = 'tests/scripts/bad.Tests.ps1'; content = 'Start-Sleep -Seconds 1' }
        }
        @{ HookName = 'check-powershell-test-purity.ps1'; ToolName = 'apply_patch'; Marker = 'Start-Sleep forbidden'
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: tests/scripts/bad.Tests.ps1`n+Start-Sleep -Seconds 1`n*** End Patch" }
        }
        # Evidence locations.
        @{ HookName = 'enforce-evidence-locations.ps1'; ToolName = 'Edit'; Marker = 'EVIDENCE_LOCATION_BLOCKED'
            ToolInput = @{ file_path = 'artifacts/research/bad.md'; old_string = 'a'; new_string = 'b' }
        }
        @{ HookName = 'enforce-evidence-locations.ps1'; ToolName = 'Write'; Marker = 'EVIDENCE_LOCATION_BLOCKED'
            ToolInput = @{ file_path = 'artifacts/research/bad.md'; content = 'bad' }
        }
        @{ HookName = 'enforce-evidence-locations.ps1'; ToolName = 'apply_patch'; Marker = 'EVIDENCE_LOCATION_BLOCKED'
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: artifacts/research/bad.md`n+bad`n*** End Patch" }
        }
        # Checkpoint monotonicity. The Write and apply_patch rows carry regressing
        # completed_steps. The Edit row supplies no content, which the unchanged
        # policy at enforce-checkpoint-monotonic.ps1 treats as deletion and denies;
        # it is a reachable, deterministic deny rather than an allow. Both Edit
        # rows use an old_string sentinel that cannot occur in the on-disk
        # checkpoint, so they resolve identically whatever the checkpoint holds.
        # These literals are inlined because -ForEach data is evaluated at
        # discovery time, before BeforeAll has run.
        @{ HookName = 'enforce-checkpoint-monotonic.ps1'; ToolName = 'Write'; Marker = 'CHECKPOINT_ORDER_BLOCKED'
            ToolInput = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'
                content              = '{"completed_steps":["S5_atomic_execution","S4_atomic_planning"]}'
            }
        }
        @{ HookName = 'enforce-checkpoint-monotonic.ps1'; ToolName = 'apply_patch'; Marker = 'CHECKPOINT_ORDER_BLOCKED'
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: artifacts/orchestration/orchestrator-state.json`n+{`"completed_steps`":[`"S5_atomic_execution`",`"S4_atomic_planning`"]}`n*** End Patch" }
        }
        @{ HookName = 'enforce-checkpoint-monotonic.ps1'; ToolName = 'Edit'; Marker = 'cannot be deleted or replaced with empty content'
            ToolInput = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'
                old_string = 'ZZZ-SENTINEL-NEVER-PRESENT-IN-CHECKPOINT-415'; new_string = 'b'
            }
        }
        # Completion consistency. The Edit row cannot resolve its patch against the
        # on-disk checkpoint, which the unchanged policy denies fail-closed.
        @{ HookName = 'enforce-completion-consistency.ps1'; ToolName = 'Write'; Marker = 'COMPLETION_CONSISTENCY_BLOCKED'
            ToolInput = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'
                content              = '{"next_step":"complete","completed_steps":["S12_complete"]}'
            }
        }
        @{ HookName = 'enforce-completion-consistency.ps1'; ToolName = 'apply_patch'; Marker = 'COMPLETION_CONSISTENCY_BLOCKED'
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: artifacts/orchestration/orchestrator-state.json`n+{`"next_step`":`"complete`",`"completed_steps`":[`"S12_complete`"]}`n*** End Patch" }
        }
        @{ HookName = 'enforce-completion-consistency.ps1'; ToolName = 'Edit'; Marker = 'replaced through an unresolved patch'
            ToolInput = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'
                old_string = 'ZZZ-SENTINEL-NEVER-PRESENT-IN-CHECKPOINT-415'; new_string = 'b'
            }
        }
    ) {
        $payload = ConvertTo-CodexPreToolPayload -ToolName $ToolName -ToolInput $ToolInput
        $result = Invoke-CodexHookProcess -HookName $HookName -PayloadRaw $payload

        $result.ExitCode | Should -Be 0 -Because 'a deny is reported through stdout, not an exit code'
        $result.Stdout | Should -Not -BeNullOrEmpty

        $decision = $result.Stdout | ConvertFrom-Json
        $decision.PSObject.Properties.Name | Should -Not -Contain 'decision' -Because 'the legacy decision envelope must never be emitted'
        $decision.PSObject.Properties.Name | Should -Contain 'hookSpecificOutput'
        $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $Marker
    }

    It 'denies a preimplementation-gate implementation path mapped from <ToolName>' -ForEach @(
        @{ ToolName = 'Edit'; ToolInput = @{ file_path = 'src/contract.py'; old_string = 'a'; new_string = 'value = 1' } }
        @{ ToolName = 'Write'; ToolInput = @{ file_path = 'src/contract.py'; content = 'value = 1' } }
        @{ ToolName = 'apply_patch'; ToolInput = @{ command = "*** Begin Patch`n*** Add File: src/contract.py`n+value = 1`n*** End Patch" } }
    ) {
        # Kept unit-level so the case never depends on the repository's live
        # checkpoint: the non-ready checkpoint is injected through -CheckpointRaw.
        . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $script:HookRoot 'codex-pretooluse-file-mapping.ps1')

        $payload = (ConvertTo-CodexPreToolPayload -ToolName $ToolName -ToolInput $ToolInput) | ConvertFrom-Json
        $mapped = @(ConvertTo-CodexFileEditInput -Payload $payload)
        $mapped.Count | Should -BeGreaterThan 0 -Because "a $ToolName implementation path must map to a record"

        $mappedRaw = @{ file_path = [string]$mapped[0].file_path } | ConvertTo-Json -Compress
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $mappedRaw -CheckpointRaw '{}'

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
    }

    It 'fails closed with exit 2 for <Label> on every group handler' -ForEach @(
        @{ Label = 'a missing tool_input'; Payload = '{"session_id":"s","hook_event_name":"PreToolUse","tool_name":"Edit"}' }
        @{ Label = 'a null tool_input'; Payload = '{"session_id":"s","hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":null}' }
    ) {
        # Scoped to the eight group handlers only. The seven non-implicated
        # handlers allow this input today and must not be behaviourally changed.
        foreach ($name in $script:GroupHookNames) {
            $result = Invoke-CodexHookProcess -HookName $name -PayloadRaw $Payload

            $result.ExitCode | Should -Be 2 -Because "$name must reject $Label"
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Not -BeNullOrEmpty
            $result.Stderr | Should -Match 'tool_input'
        }
    }
}
