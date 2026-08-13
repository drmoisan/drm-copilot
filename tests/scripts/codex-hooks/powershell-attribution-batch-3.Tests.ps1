#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 3' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/hooks/enforce-parallel-cohort-barrier.ps1'
            '.codex/hooks/enforce-parallel-drift-gate.ps1'
            '.codex/hooks/validate-parallel-agent-output.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/hooks/enforce-parallel-cohort-barrier.ps1' }
        @{ RuntimePath = '.codex/hooks/enforce-parallel-drift-gate.ps1' }
        @{ RuntimePath = '.codex/hooks/validate-parallel-agent-output.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'recognizes only forced-orchestrator cohort launch calls' {
        $payload = [pscustomobject]@{
            agent_type = 'parallel-orchestrator'
            tool_name  = 'spawn_agent'
        }
        Test-CodexParallelCohortBarrierCall `
            -Payload $payload `
            -ToolInput ([pscustomobject]@{ task_name = 'item-1' }) | Should -BeTrue
        Test-CodexParallelCohortBarrierCall `
            -Payload $payload `
            -ToolInput ([pscustomobject]@{ message = 'item-1' }) | Should -BeFalse
    }

    It 'recognizes only forced-orchestrator drift launch calls' {
        $payload = [pscustomobject]@{
            agent_type = 'parallel-orchestrator'
            tool_name  = 'spawn_agent'
        }
        Test-CodexParallelDriftGateCall `
            -Payload $payload `
            -ToolInput ([pscustomobject]@{ task_name = 'item-1' }) | Should -BeTrue
        Test-CodexParallelDriftGateCall `
            -Payload ([pscustomobject]@{ agent_type = 'orchestrator'; tool_name = 'spawn_agent' }) `
            -ToolInput ([pscustomobject]@{ task_name = 'item-1' }) | Should -BeFalse
    }

    It 'returns no stop decision for a valid forced parallel persona' {
        $raw = @{
            hook_event_name  = 'SubagentStop'
            agent_type       = 'parallel-planner'
            agent_id         = 'planner-1'
            stop_hook_active = $false
        } | ConvertTo-Json -Compress
        $decision = Invoke-CodexParallelAgentOutputDecision `
            -PayloadRaw $raw `
            -WorkspaceRoot $script:RepoRoot `
            -Validator {
            param($AgentType, $RepositoryRoot)
            if ($AgentType -ne 'parallel-planner' -or $RepositoryRoot -ne $script:RepoRoot) {
                throw 'The agent-output decision forwarded unexpected validator inputs.'
            }
            @()
        }

        $decision | Should -BeNullOrEmpty
    }

    It 'forwards active cohort and drift launches through their shared validators' {
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'spawn_agent'
            tool_input      = [pscustomobject]@{ task_name = 'item-1' }
            agent_type      = 'parallel-orchestrator'
        } | ConvertTo-Json -Compress
        foreach ($gate in @(
                'Invoke-CodexParallelCohortBarrier'
                'Invoke-CodexParallelDriftGate'
            )) {
            $script:Batch3ValidatorCalls = 0
            $result = & $gate `
                -PayloadRaw $raw `
                -RepositoryRoot 'C:/repo' `
                -SharedValidatorRunner {
                param($root, $checkpoint)
                $root | Should -Be 'C:/repo'
                $checkpoint | Should -Be 'artifacts/orchestration/parallel-orchestrator-state.json'
                $script:Batch3ValidatorCalls++
            }
            $result.ExitCode | Should -Be 0
            $script:Batch3ValidatorCalls | Should -Be 1
        }
    }

    It 'bypasses cohort and drift validators for unrelated tool calls' {
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'Read'
            tool_input      = [pscustomobject]@{}
            agent_type      = 'parallel-orchestrator'
        } | ConvertTo-Json -Compress
        foreach ($gate in @(
                'Invoke-CodexParallelCohortBarrier'
                'Invoke-CodexParallelDriftGate'
            )) {
            $result = & $gate `
                -PayloadRaw $raw `
                -RepositoryRoot 'C:/repo' `
                -SharedValidatorRunner { throw 'unexpected validator call' }
            $result.ExitCode | Should -Be 0
        }
    }

    It 'normalizes shared validator outcomes for <Validator>' -ForEach @(
        @{ Validator = 'Invoke-CodexParallelCohortSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelDriftSharedValidator' }
    ) {
        Mock poetry { $global:LASTEXITCODE = 0 }
        & $Validator -RepositoryRoot 'C:/repo' -CheckpointPath 'state.json' |
            Should -BeNullOrEmpty

        Mock poetry { $global:LASTEXITCODE = 1 }
        & $Validator -RepositoryRoot 'C:/repo' -CheckpointPath 'state.json' |
            Should -Match 'exited without a diagnostic'

        Mock poetry {
            $global:LASTEXITCODE = 1
            'first'
            'second'
        }
        & $Validator -RepositoryRoot 'C:/repo' -CheckpointPath 'state.json' |
            Should -Be 'first; second'
    }

    It 'selects the correct shared agent-output validator contract' {
        Mock poetry { $global:LASTEXITCODE = 0 }
        Invoke-CodexParallelAgentOutputSharedValidator `
            -AgentType 'parallel-planner' `
            -WorkspaceRoot 'C:/repo' | Should -BeNullOrEmpty
        Should -Invoke poetry -ParameterFilter {
            $args -contains 'parallel-planner-state' -and
            $args -contains '--require-ready-for-execution'
        }

        Invoke-CodexParallelAgentOutputSharedValidator `
            -AgentType 'parallel-orchestrator' `
            -WorkspaceRoot 'C:/repo' | Should -BeNullOrEmpty
        Should -Invoke poetry -ParameterFilter {
            $args -contains 'parallel-orchestrator-state' -and
            $args -contains '--require-complete'
        }
    }

    It 'returns stable shared agent-output validator failures' {
        Mock poetry { $global:LASTEXITCODE = 3 }
        Invoke-CodexParallelAgentOutputSharedValidator `
            -AgentType 'parallel-planner' `
            -WorkspaceRoot 'C:/repo' | Should -Match 'exited 3 without a diagnostic'

        Mock poetry {
            $global:LASTEXITCODE = 2
            ' first '
            ''
            ' second '
        }
        Invoke-CodexParallelAgentOutputSharedValidator `
            -AgentType 'parallel-planner' `
            -WorkspaceRoot 'C:/repo' | Should -Be @('first', 'second')
    }

    It 'validates agent-output payload boundaries and continuation decisions' {
        $base = [ordered]@{
            hook_event_name  = 'SubagentStop'
            agent_type       = 'parallel-planner'
            agent_id         = 'planner-1'
            stop_hook_active = $false
        }
        $raw = $base | ConvertTo-Json -Compress
        $decision = Invoke-CodexParallelAgentOutputDecision `
            -PayloadRaw $raw `
            -WorkspaceRoot 'C:/repo' `
            -Validator { ' first '; ''; 'second' }
        $decision.decision | Should -Be 'block'
        $decision.reason | Should -Match 'first; second'

        $base.stop_hook_active = $true
        $decision = Invoke-CodexParallelAgentOutputDecision `
            -PayloadRaw ($base | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo' `
            -Validator { 'failure' }
        $decision.continue | Should -BeFalse

        $base.hook_event_name = 'PreToolUse'
        { Invoke-CodexParallelAgentOutputDecision `
                -PayloadRaw ($base | ConvertTo-Json -Compress) `
                -WorkspaceRoot 'C:/repo' } | Should -Throw '*must be SubagentStop*'
        $base.hook_event_name = 'SubagentStop'
        $base.agent_type = 'worker'
        Invoke-CodexParallelAgentOutputDecision `
            -PayloadRaw ($base | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo' | Should -BeNullOrEmpty
        $base.agent_type = 'parallel-planner'
        $base.stop_hook_active = 'invalid'
        { Invoke-CodexParallelAgentOutputDecision `
                -PayloadRaw ($base | ConvertTo-Json -Compress) `
                -WorkspaceRoot 'C:/repo' } | Should -Throw '*must be boolean*'
    }

    It 'uses the default agent-output validator boundary' {
        Mock Invoke-CodexParallelAgentOutputSharedValidator { [string[]]@() }
        $raw = @{
            hook_event_name  = 'SubagentStop'
            agent_type       = 'parallel-planner'
            agent_id         = 'planner-1'
            stop_hook_active = $false
        } | ConvertTo-Json -Compress
        Invoke-CodexParallelAgentOutputDecision `
            -PayloadRaw $raw `
            -WorkspaceRoot 'C:/repo' | Should -BeNullOrEmpty
        Should -Invoke Invoke-CodexParallelAgentOutputSharedValidator -Times 1
    }

    It 'runs cohort and drift entrypoints through native console and default boundaries' {
        Mock Invoke-CodexParallelCohortSharedValidator { }
        Mock Invoke-CodexParallelDriftSharedValidator { }
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'spawn_agent'
            tool_input      = [pscustomobject]@{ task_name = 'item-1' }
            agent_type      = 'parallel-orchestrator'
        } | ConvertTo-Json -Compress
        $originalIn = [Console]::In
        try {
            [Console]::SetIn([System.IO.StringReader]::new($raw))
            Invoke-CodexParallelCohortHookEntrypoint -RepositoryRoot 'C:/repo' |
                Should -Be 0
            [Console]::SetIn([System.IO.StringReader]::new($raw))
            Invoke-CodexParallelDriftHookEntrypoint -RepositoryRoot 'C:/repo' |
                Should -Be 0
        } finally {
            [Console]::SetIn($originalIn)
        }
        Should -Invoke Invoke-CodexParallelCohortSharedValidator -Times 1
        Should -Invoke Invoke-CodexParallelDriftSharedValidator -Times 1
    }

    It 'returns exit code 2 for unreadable <Entrypoint> payloads' -ForEach @(
        @{ Entrypoint = 'Invoke-CodexParallelCohortHookEntrypoint' }
        @{ Entrypoint = 'Invoke-CodexParallelDriftHookEntrypoint' }
    ) {
        & $Entrypoint `
            -RepositoryRoot 'C:/repo' `
            -PayloadReader { throw 'payload failure' } | Should -Be 2
    }

    It 'normalizes native agent-output success and failure results' {
        $valid = [ordered]@{
            hook_event_name  = 'SubagentStop'
            agent_type       = 'parallel-planner'
            agent_id         = 'planner-1'
            stop_hook_active = $false
        }
        $result = Invoke-CodexParallelAgentOutputHookEntrypoint `
            -PayloadRaw ($valid | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo' `
            -Validator { @() }
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be ''

        $result = Invoke-CodexParallelAgentOutputHookEntrypoint `
            -PayloadRaw ($valid | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo' `
            -Validator { 'failed validation' }
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Match 'failed validation'

        $invalid = [ordered]@{
            hook_event_name  = 'PreToolUse'
            agent_type       = 'parallel-planner'
            agent_id         = 'planner-1'
            stop_hook_active = $true
        }
        $result = Invoke-CodexParallelAgentOutputHookEntrypoint `
            -PayloadRaw ($invalid | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo'
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Match 'continue'

        $invalid.stop_hook_active = $false
        $result = Invoke-CodexParallelAgentOutputHookEntrypoint `
            -PayloadRaw ($invalid | ConvertTo-Json -Compress) `
            -WorkspaceRoot 'C:/repo'
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'must be SubagentStop'
    }

    It 'writes native agent-output result streams and returns the exit code' {
        $script:Batch3Output = ''
        $script:Batch3Error = ''
        $result = ConvertTo-CodexParallelAgentOutputHookResult `
            -ExitCode 2 -Stdout 'out' -Stderr 'err'
        Write-CodexParallelAgentOutputHookResult `
            -Result $result `
            -OutputWriter { param($value) $script:Batch3Output = $value } `
            -ErrorWriter { param($value) $script:Batch3Error = $value } |
            Should -Be 2
        $script:Batch3Output | Should -Be 'out'
        $script:Batch3Error | Should -Be 'err'

        $originalOut = [Console]::Out
        $output = [System.IO.StringWriter]::new()
        try {
            [Console]::SetOut($output)
            Write-CodexParallelAgentOutputHookResult `
                -Result (ConvertTo-CodexParallelAgentOutputHookResult -ExitCode 0 -Stdout 'native') |
                Should -Be 0
        } finally {
            [Console]::SetOut($originalOut)
        }
        $output.ToString() | Should -Match 'native'
    }
}
