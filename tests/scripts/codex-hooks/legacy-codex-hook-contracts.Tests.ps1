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

        # Shared, entrypoint-free modules that the hooks dot-source. They are
        # subject to the same static checks (parse, 500-line cap, root/bundle
        # byte-identity, no legacy Claude environment reads) but are deliberately
        # excluded from the stdin-read assertion and from every process-level
        # invocation loop, because they define functions only and are never
        # executed as a hook process.
        $script:SharedModuleNames = @('codex-pretooluse-file-mapping.ps1')
        $script:StaticCheckNames = @($script:AllHookNames) + @($script:SharedModuleNames)
        $script:CorePackManifestPath = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json'

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
        foreach ($name in $script:StaticCheckNames) {
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
        foreach ($name in $script:StaticCheckNames) {
            $rootHash = (Get-FileHash -LiteralPath (Join-Path $script:HookRoot $name)).Hash
            $bundleHash = (Get-FileHash -LiteralPath (Join-Path $script:BundleHookRoot $name)).Hash
            $bundleHash | Should -Be $rootHash -Because "$name must publish without drift"
        }
    }

    It 'reads stdin in every hook entrypoint' {
        # Entrypoint hooks only. Shared dot-sourced modules never read stdin.
        foreach ($name in $script:AllHookNames) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $script:HookRoot $name)
            $content | Should -Match '\[Console\]::In\.ReadToEnd\(\)' -Because "$name must read its payload from stdin"
        }
    }

    It 'contains no legacy Claude environment-variable dependency in hooks or shared modules' {
        foreach ($name in $script:StaticCheckNames) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $script:HookRoot $name)
            $content | Should -Not -Match '\$env:CLAUDE_' -Because "$name must not read legacy Claude variables"
        }
    }

    It 'lists every shared hook module in the core pack manifest' {
        $manifest = Get-Content -Raw -LiteralPath $script:CorePackManifestPath | ConvertFrom-Json
        foreach ($name in $script:SharedModuleNames) {
            @($manifest.paths) | Should -Contain ".codex/hooks/$name" -Because "$name must publish with the bundle"
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
        # Update reconstruction now comes from the shared module and runs only for
        # the governed path, so the governed path is supplied explicitly here.
        . (Join-Path $script:HookRoot 'codex-pretooluse-file-mapping.ps1')
        $updatePatch = "*** Begin Patch`n*** Update File: config/orchestration-routing.json`n@@`n-{`n+{`n*** End Patch"
        $updatePayload = (ConvertTo-CodexPatchPayload -Patch $updatePatch) | ConvertFrom-Json
        $toolInput = @(
            ConvertTo-CodexFileEditInput -Payload $updatePayload -ResolveUpdateContent -GovernedPath 'config/orchestration-routing.json'
        ) | Select-Object -First 1
        $expected = (Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'config/orchestration-routing.json')) -replace "`r`n", "`n"

        $toolInput.file_path | Should -Be 'config/orchestration-routing.json'
        $toolInput.content | Should -BeExactly $expected

        # Rename mapping now comes from the shared module. Both sides of the move
        # must still be produced, because enforce-evidence-locations evaluates the
        # source and the destination.
        . (Join-Path $script:HookRoot 'codex-pretooluse-file-mapping.ps1')
        $movePatch = "*** Begin Patch`n*** Update File: README.md`n*** Move to: artifacts/research/moved.md`n@@`n-old`n+new`n*** End Patch"
        $movePayload = (ConvertTo-CodexPatchPayload -Patch $movePatch) | ConvertFrom-Json
        $paths = @(
            @(ConvertTo-CodexFileEditInput -Payload $movePayload) |
                ForEach-Object { $_.source_path; $_.file_path } |
                    Select-Object -Unique
        )
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

    Context 'enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1)' {
        BeforeAll {
            $script:GateHookPath = Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1'
            # A directory that provably contains no artifacts/orchestration checkpoint,
            # so the gate's relative checkpoint lookup is deterministic.
            $script:CheckpointFreeDirectory = Join-Path $script:RepoRoot 'tests'
            $script:ReadyCheckpointJson = @{
                'issue-num'      = '415'
                'feature-folder' = 'docs/features/active/sample'
                route_id         = 'full-bug'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress

            . $script:GateHookPath

            function Invoke-GateEntrypoint {
                <#
                    Drives the hook's own entrypoint in-process. Stdin is supplied by a
                    StringReader rather than a temporary file, and both console readers
                    are restored in finally.
                #>
                param([Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw)

                $originalIn = [System.Console]::In
                $originalError = [System.Console]::Error
                $errorWriter = [System.IO.StringWriter]::new()
                Push-Location -LiteralPath $script:CheckpointFreeDirectory
                try {
                    [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                    [System.Console]::SetError($errorWriter)
                    $stdout = & $script:GateHookPath
                    return [pscustomobject]@{
                        ExitCode = $LASTEXITCODE
                        Stdout   = ($stdout -join "`n")
                        Stderr   = $errorWriter.ToString()
                    }
                } finally {
                    [System.Console]::SetIn($originalIn)
                    [System.Console]::SetError($originalError)
                    Pop-Location
                }
            }
        }

        It 'classifies <Label> as implementation path <Expected>' -ForEach @(
            @{ Label = 'a feature documentation path'; Path = 'docs/features/active/x/spec.md'; Expected = $false }
            @{ Label = 'the orchestrator checkpoint'; Path = 'artifacts/orchestration/orchestrator-state.json'; Expected = $false }
            @{ Label = 'a production script'; Path = 'scripts/a.ps1'; Expected = $true }
            @{ Label = 'a plain text file'; Path = 'notes.txt'; Expected = $false }
        ) {
            Test-ImplementationPath -NormalizedPath $Path | Should -Be $Expected
        }

        It 'classifies <Label> as implementation command <Expected>' -ForEach @(
            @{ Label = 'an empty command'; Command = '   '; Expected = $false }
            @{ Label = 'an apply_patch add of a script'; Command = '*** Add File: scripts/a.ps1'; Expected = $true }
            @{ Label = 'an apply_patch add of documentation'; Command = '*** Add File: docs/features/active/x/spec.md'; Expected = $false }
            @{ Label = 'an apply_patch rename onto a script'; Command = '*** Move to: scripts/b.ps1'; Expected = $true }
            @{ Label = 'a git commit'; Command = 'git commit -m "wip"'; Expected = $true }
            @{ Label = 'a pytest run'; Command = 'poetry run pytest'; Expected = $true }
            @{ Label = 'an unrelated command'; Command = 'echo hello'; Expected = $false }
        ) {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected
        }

        It 'treats a null tool_input as no implementation delegation' {
            Test-ImplementationDelegation -ToolInput $null | Should -BeFalse
        }

        It 'detects an implementation delegation inside a serialized tool_input' {
            $toolInput = [pscustomobject]@{ subagent_type = 'atomic-executor' }

            Test-ImplementationDelegation -ToolInput $toolInput | Should -BeTrue
        }

        It 'treats an unrelated serialized tool_input as no delegation' {
            $toolInput = [pscustomobject]@{ subagent_type = 'task-researcher' }

            Test-ImplementationDelegation -ToolInput $toolInput | Should -BeFalse
        }

        It 'treats a null checkpoint payload as not ready' {
            Test-OrchestrationReady -Payload $null | Should -BeFalse
        }

        It 'treats a checkpoint missing lifecycle readiness as not ready' {
            $payload = @{
                'issue-num'      = '415'
                'feature-folder' = 'docs/features/active/sample'
                path_selected    = 'full-bug'
            } | ConvertTo-Json -Compress | ConvertFrom-Json

            Test-OrchestrationReady -Payload $payload | Should -BeFalse
        }

        It 'treats a complete checkpoint as ready' {
            $payload = $script:ReadyCheckpointJson | ConvertFrom-Json

            Test-OrchestrationReady -Payload $payload | Should -BeTrue
        }

        It 'returns empty checkpoint content when the checkpoint file is absent' {
            Push-Location -LiteralPath $script:CheckpointFreeDirectory
            try {
                Get-CheckpointContent | Should -Be ''
            } finally {
                Pop-Location
            }
        }

        It 'returns the checkpoint file content when the checkpoint file is present' {
            Mock Test-Path { $true }
            Mock Get-Content { 'checkpoint-body' }

            Get-CheckpointContent | Should -Be 'checkpoint-body'
        }

        It 'allows when no mapped tool_input is supplied' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws a hook-named error for malformed mapped tool_input JSON' {
            { Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw 'not json' } |
                Should -Throw -ExpectedMessage 'enforce-orchestration-preimplementation-gate received malformed mapped tool_input JSON: *'
        }

        It 'allows a documentation file path without consulting the checkpoint' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{"file_path":"docs/features/active/x/spec.md"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies an implementation command when the checkpoint is not ready' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{"command":"git commit -m wip"}' -CheckpointRaw '{}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an implementation delegation when the checkpoint is not ready' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{"subagent_type":"atomic-executor"}' -CheckpointRaw 'not json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows an implementation path when the checkpoint is ready' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{"file_path":"scripts/a.ps1"}' -CheckpointRaw $script:ReadyCheckpointJson

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'reads the checkpoint from disk when no checkpoint text is supplied' {
            Push-Location -LiteralPath $script:CheckpointFreeDirectory
            try {
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{"file_path":"scripts/a.ps1"}'

                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            } finally {
                Pop-Location
            }
        }

        It 'denies an apply_patch implementation through its own entrypoint' {
            $payload = ConvertTo-CodexPatchPayload -Patch "*** Begin Patch`n*** Add File: scripts/a.ps1`n+line`n*** End Patch"

            $result = Invoke-GateEntrypoint -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'denies a mapped Edit implementation through its own entrypoint' {
            $payload = ConvertTo-CodexPreToolPayload -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/a.ps1'; old_string = 'a'; new_string = 'b' }

            $result = Invoke-GateEntrypoint -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'allows a mapped Write of feature documentation through its own entrypoint' {
            $payload = ConvertTo-CodexPreToolPayload -ToolName 'Write' -ToolInput @{ file_path = 'docs/features/active/x/spec.md'; content = 'body' }

            $result = Invoke-GateEntrypoint -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'fails closed with exit 2 when its entrypoint receives empty stdin' {
            $result = Invoke-GateEntrypoint -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'enforce-orchestration-preimplementation-gate hook input is empty'
        }
    }
}
