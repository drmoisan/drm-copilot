#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex PreToolUse hooks honour the native stdin transport contract' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source

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

    Context 'enforce-completion-consistency in-process behaviour (issue #415 R1)' {
        BeforeAll {
            $script:ConsistencyHookPath = Join-Path $script:HookRoot 'enforce-completion-consistency.ps1'
            $script:CheckpointRelativePath = 'artifacts/orchestration/orchestrator-state.json'

            . $script:ConsistencyHookPath

            function ConvertTo-CompletionCheckpointJson {
                param([hashtable] $Overrides = @{})

                $base = [ordered]@{
                    next_step        = 'complete'
                    'issue-num'      = '415'
                    'feature-folder' = 'docs/features/active/sample'
                    ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = 'abc123' }
                }
                foreach ($key in $Overrides.Keys) {
                    $base[$key] = $Overrides[$key]
                }
                return ($base | ConvertTo-Json -Compress -Depth 10)
            }

            function Invoke-ConsistencyEntrypoint {
                <#
                    Drives the hook's own entrypoint in-process with a StringReader on
                    stdin. No temporary file is used and both console readers are
                    restored in finally.
                #>
                param([Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw)

                $originalIn = [System.Console]::In
                $originalError = [System.Console]::Error
                $errorWriter = [System.IO.StringWriter]::new()
                try {
                    [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                    [System.Console]::SetError($errorWriter)
                    $stdout = & $script:ConsistencyHookPath
                    return [pscustomobject]@{
                        ExitCode = $LASTEXITCODE
                        Stdout   = ($stdout -join "`n")
                        Stderr   = $errorWriter.ToString()
                    }
                } finally {
                    [System.Console]::SetIn($originalIn)
                    [System.Console]::SetError($originalError)
                }
            }
        }

        It 'returns null checkpoint content when the path is not a file' {
            Get-CheckpointFileContent -Path (Join-Path $script:RepoRoot 'no-such-checkpoint.json') |
                Should -BeNullOrEmpty
        }

        It 'returns the file text when the checkpoint path resolves to a file' {
            $content = Get-CheckpointFileContent -Path $script:ConsistencyHookPath

            $content | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
        }

        It 'returns an empty string for a null checkpoint payload property lookup' {
            Get-CheckpointStringValue -Payload $null -Name 'next_step' | Should -Be ''
        }

        It 'returns an empty string when the checkpoint property value is null' {
            $payload = '{"next_step":null}' | ConvertFrom-Json

            Get-CheckpointStringValue -Payload $payload -Name 'next_step' | Should -Be ''
        }

        It 'treats a null payload as asserting no completion' {
            Test-CompletionAsserted -Payload $null | Should -BeFalse
        }

        It 'detects completion asserted by <Label>' -ForEach @(
            @{ Label = 'next_step'; Json = '{"next_step":"complete"}' }
            @{ Label = 'completed_steps'; Json = '{"completed_steps":["S11","S12_complete"]}' }
            @{ Label = 'step8_status'; Json = '{"step8_status":"completed"}' }
            @{ Label = 'step9_status'; Json = '{"step9_status":"completed"}' }
            @{ Label = 'step10_status'; Json = '{"step10_status":"completed"}' }
        ) {
            Test-CompletionAsserted -Payload ($Json | ConvertFrom-Json) | Should -BeTrue
        }

        It 'detects no completion assertion for <Label>' -ForEach @(
            @{ Label = 'an in-progress next_step'; Json = '{"next_step":"S07_review"}' }
            @{ Label = 'completed_steps without the terminal step'; Json = '{"completed_steps":["S11"]}' }
            @{ Label = 'an empty completed_steps list'; Json = '{"completed_steps":[]}' }
            @{ Label = 'an in-progress step8_status'; Json = '{"step8_status":"in_progress"}' }
        ) {
            Test-CompletionAsserted -Payload ($Json | ConvertFrom-Json) | Should -BeFalse
        }

        It 'returns null edited content when the tool input carries no old_string' {
            $toolInput = [pscustomobject]@{ file_path = $script:CheckpointRelativePath }

            Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader { param($Path) if ($Path) { 'ignored' } } |
                Should -BeNullOrEmpty
        }

        It 'returns null edited content when the on-disk checkpoint is empty' {
            $toolInput = [pscustomobject]@{ old_string = 'a'; new_string = 'b' }

            Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader { param($Path) if ($Path) { '' } } |
                Should -BeNullOrEmpty
        }

        It 'returns null edited content when the old_string is absent from the checkpoint' {
            $toolInput = [pscustomobject]@{ old_string = 'absent'; new_string = 'b' }

            Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader { param($Path) if ($Path) { '{"next_step":"S07"}' } } |
                Should -BeNullOrEmpty
        }

        It 'applies the old_string to new_string replacement in memory' {
            $toolInput = [pscustomobject]@{ old_string = 'S07'; new_string = 'complete' }

            $patched = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader { param($Path) if ($Path) { '{"next_step":"S07"}' } }

            $patched | Should -Be '{"next_step":"complete"}'
        }

        It 'reads the governed checkpoint path through the injected reader' {
            $script:ObservedReaderPath = ''
            $toolInput = [pscustomobject]@{ old_string = 'S07'; new_string = 'complete' }

            $null = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader {
                param($Path)
                $script:ObservedReaderPath = $Path
                return '{"next_step":"S07"}'
            }

            $script:ObservedReaderPath | Should -Be 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'allows when no mapped tool_input is supplied' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws a hook-named error for malformed mapped tool_input JSON' {
            { Invoke-CompletionConsistencyDecision -ToolInputRaw 'not json' } |
                Should -Throw -ExpectedMessage 'enforce-completion-consistency received malformed mapped tool_input JSON: *'
        }

        It 'allows mapped tool_input that carries no file_path' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw '{"content":"{}"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a file path that is not the governed checkpoint' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw '{"file_path":"docs/notes.md","content":"{}"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a checkpoint edit whose patch cannot be resolved' {
            $raw = @{ file_path = $script:CheckpointRelativePath; old_string = 'absent-marker' } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -CheckpointReader { param($Path) if ($Path) { '{"next_step":"S07"}' } }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'unresolved patch'
        }

        It 'allows a checkpoint write that does not assert completion' {
            $raw = @{ file_path = $script:CheckpointRelativePath; content = '{"next_step":"S07_review"}' } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a completion-asserting checkpoint write through its own entrypoint' {
            $content = ConvertTo-CompletionCheckpointJson -Overrides @{ 'issue-num' = '' }
            $payload = ConvertTo-CodexPreToolPayload -ToolName 'Write' -ToolInput @{
                file_path = $script:CheckpointRelativePath
                content   = $content
            }

            $result = Invoke-ConsistencyEntrypoint -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'allows an unrelated mapped write through its own entrypoint' {
            $payload = ConvertTo-CodexPreToolPayload -ToolName 'Write' -ToolInput @{
                file_path = 'docs/notes.md'
                content   = 'body'
            }

            $result = Invoke-ConsistencyEntrypoint -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'fails closed with exit 2 when its entrypoint receives empty stdin' {
            $result = Invoke-ConsistencyEntrypoint -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'enforce-completion-consistency hook input is empty'
        }

        It 'reads issue-num and feature-folder from variables and reports ci_gate gaps' {
            $payload = '{"variables":{"issue-num":"415","feature-folder":"docs/features/active/absent"},"ci_gate":{"conclusion":"failure"}}' |
                ConvertFrom-Json

            $missing = @(Get-MissingCompletionEvidence -Payload $payload)

            $missing | Should -Not -Contain "issue-num value '415' is not a valid issue number (must be digits-only)"
            $missing | Should -Contain 'ci_gate.conclusion == "success"'
            $missing | Should -Contain 'ci_gate.head_sha'
        }
    }
}
