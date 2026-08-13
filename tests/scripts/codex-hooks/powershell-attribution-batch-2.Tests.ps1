#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 2' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/hooks/enforce-parallel-abandon-gate.ps1'
            '.codex/hooks/enforce-parallel-child-worktree-binding.ps1'
            '.codex/hooks/enforce-parallel-worktree-removal-gate.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/hooks/enforce-parallel-abandon-gate.ps1' }
        @{ RuntimePath = '.codex/hooks/enforce-parallel-child-worktree-binding.ps1' }
        @{ RuntimePath = '.codex/hooks/enforce-parallel-worktree-removal-gate.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'recognizes only deterministic abandon mutation commands' {
        $payload = [pscustomobject]@{ tool_name = 'shell_command' }
        Test-CodexParallelAbandonCall -Payload $payload -ToolInput (
            [pscustomobject]@{ command = 'poetry run python -m scripts.dev_tools.parallel_mutation_abandon_cli --help' }
        ) | Should -BeTrue
        Test-CodexParallelAbandonCall -Payload $payload -ToolInput (
            [pscustomobject]@{ command = 'git status' }
        ) | Should -BeFalse
        Test-CodexParallelAbandonCall `
            -Payload ([pscustomobject]@{ tool_name = 'Read' }) `
            -ToolInput ([pscustomobject]@{ command = 'python -m scripts.dev_tools.parallel_mutation_abandon_cli' }) |
            Should -BeFalse
    }

    It 'requires both a sealed launch id and a named tool for child binding' {
        Test-CodexParallelChildBindingCall `
            -Payload ([pscustomobject]@{ tool_name = 'shell_command' }) `
            -LaunchId 'launch-1' | Should -BeTrue
        Test-CodexParallelChildBindingCall `
            -Payload ([pscustomobject]@{ tool_name = 'shell_command' }) `
            -LaunchId '' | Should -BeFalse
        Test-CodexParallelChildBindingCall `
            -Payload ([pscustomobject]@{ tool_name = '' }) `
            -LaunchId 'launch-1' | Should -BeFalse
    }

    It 'recognizes only parallel-orchestrator worktree removal commands' {
        $payload = [pscustomobject]@{
            agent_type = 'parallel-orchestrator'
            tool_name  = 'shell_command'
        }
        Test-CodexParallelWorktreeRemovalCall -Payload $payload -ToolInput (
            [pscustomobject]@{ command = 'git worktree remove C:/repo/item' }
        ) | Should -BeTrue
        Test-CodexParallelWorktreeRemovalCall -Payload $payload -ToolInput (
            [pscustomobject]@{ command = 'git worktree list' }
        ) | Should -BeFalse
        Test-CodexParallelWorktreeRemovalCall `
            -Payload ([pscustomobject]@{ agent_type = 'orchestrator'; tool_name = 'shell_command' }) `
            -ToolInput ([pscustomobject]@{ command = 'git worktree remove C:/repo/item' }) |
            Should -BeFalse
    }

    It 'forwards active abandon calls and bypasses unrelated tool calls' {
        $script:Batch2AbandonCalls = 0
        $active = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{
                command = 'poetry run python -m scripts.dev_tools.parallel_mutation_abandon_cli'
            }
        } | ConvertTo-Json -Compress
        $runner = {
            param($root, $checkpoint)
            $root | Should -Be 'C:/repo'
            $checkpoint | Should -Be 'artifacts/orchestration/parallel-orchestrator-state.json'
            $script:Batch2AbandonCalls++
        }
        (Invoke-CodexParallelAbandonGate `
            -PayloadRaw $active -RepositoryRoot 'C:/repo' `
            -SharedValidatorRunner $runner).ExitCode | Should -Be 0
        $script:Batch2AbandonCalls | Should -Be 1

        $inactive = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'Read'
            tool_input      = [pscustomobject]@{}
        } | ConvertTo-Json -Compress
        (Invoke-CodexParallelAbandonGate `
            -PayloadRaw $inactive -RepositoryRoot 'C:/repo' `
            -SharedValidatorRunner $runner).ExitCode | Should -Be 0
        $script:Batch2AbandonCalls | Should -Be 1
    }

    It 'forwards only sealed child-binding calls' {
        $script:Batch2BindingCalls = 0
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{}
        } | ConvertTo-Json -Compress
        $runner = {
            param($root, $checkpoint)
            $root | Should -Be 'C:/repo'
            $checkpoint | Should -Be 'artifacts/orchestration/parallel-orchestrator-state.json'
            $script:Batch2BindingCalls++
        }
        (Invoke-CodexParallelChildWorktreeBinding `
            -PayloadRaw $raw -RepositoryRoot 'C:/repo' -LaunchId 'launch-1' `
            -SharedValidatorRunner $runner).ExitCode | Should -Be 0
        $script:Batch2BindingCalls | Should -Be 1
        (Invoke-CodexParallelChildWorktreeBinding `
            -PayloadRaw $raw -RepositoryRoot 'C:/repo' -LaunchId '' `
            -SharedValidatorRunner $runner).ExitCode | Should -Be 0
        $script:Batch2BindingCalls | Should -Be 1
    }

    It 'forwards active removal calls and returns validator denials' {
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{ command = 'git worktree remove C:/repo/item' }
            agent_type      = 'parallel-orchestrator'
        } | ConvertTo-Json -Compress
        $result = Invoke-CodexParallelWorktreeRemovalGate `
            -PayloadRaw $raw -RepositoryRoot 'C:/repo' `
            -SharedValidatorRunner {
            param($root, $checkpoint)
            $root | Should -Be 'C:/repo'
            $checkpoint | Should -Be 'artifacts/orchestration/parallel-orchestrator-state.json'
            'blocked by validator'
        }
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Match 'PARALLEL_WORKTREE_REMOVAL_BLOCKED: blocked by validator'
    }

    It 'normalizes successful shared-validator execution for <Validator>' -ForEach @(
        @{ Validator = 'Invoke-CodexParallelAbandonSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelChildBindingSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelRemovalSharedValidator' }
    ) {
        Mock poetry {
            $global:LASTEXITCODE = 0
            'validator output'
        }
        & $Validator `
            -RepositoryRoot 'C:/repo' `
            -CheckpointPath 'state.json' | Should -BeNullOrEmpty
    }

    It 'normalizes empty shared-validator failure for <Validator>' -ForEach @(
        @{ Validator = 'Invoke-CodexParallelAbandonSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelChildBindingSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelRemovalSharedValidator' }
    ) {
        Mock poetry { $global:LASTEXITCODE = 1 }
        & $Validator `
            -RepositoryRoot 'C:/repo' `
            -CheckpointPath 'state.json' | Should -Match 'exited without a diagnostic'
    }

    It 'joins shared-validator diagnostics for <Validator>' -ForEach @(
        @{ Validator = 'Invoke-CodexParallelAbandonSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelChildBindingSharedValidator' }
        @{ Validator = 'Invoke-CodexParallelRemovalSharedValidator' }
    ) {
        Mock poetry {
            $global:LASTEXITCODE = 1
            'first'
            'second'
        }
        & $Validator `
            -RepositoryRoot 'C:/repo' `
            -CheckpointPath 'state.json' | Should -Be 'first; second'
    }

    It 'runs the native abandon entrypoint through its default validator and writer' {
        Mock Invoke-CodexParallelAbandonSharedValidator { }
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{
                command = 'python -m scripts.dev_tools.parallel_mutation_abandon_cli'
            }
        } | ConvertTo-Json -Compress
        Invoke-CodexParallelAbandonHookEntrypoint `
            -RepositoryRoot 'C:/repo' `
            -PayloadReader { $raw } | Should -Be 0
        Should -Invoke Invoke-CodexParallelAbandonSharedValidator -Times 1
    }

    It 'runs the native child-binding entrypoint through its default validator and writer' {
        Mock Invoke-CodexParallelChildBindingSharedValidator { }
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{}
        } | ConvertTo-Json -Compress
        Invoke-CodexParallelChildBindingHookEntrypoint `
            -RepositoryRoot 'C:/repo' `
            -LaunchId 'launch-1' `
            -PayloadReader { $raw } | Should -Be 0
        Should -Invoke Invoke-CodexParallelChildBindingSharedValidator -Times 1
    }

    It 'runs the native removal entrypoint through its default validator and writer' {
        Mock Invoke-CodexParallelRemovalSharedValidator { }
        $raw = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'shell_command'
            tool_input      = [pscustomobject]@{ command = 'git worktree remove C:/repo/item' }
            agent_type      = 'parallel-orchestrator'
        } | ConvertTo-Json -Compress
        Invoke-CodexParallelRemovalHookEntrypoint `
            -RepositoryRoot 'C:/repo' `
            -PayloadReader { $raw } | Should -Be 0
        Should -Invoke Invoke-CodexParallelRemovalSharedValidator -Times 1
    }

    It 'returns exit code 2 when <Entrypoint> cannot read its payload' -ForEach @(
        @{ Entrypoint = 'Invoke-CodexParallelAbandonHookEntrypoint' }
        @{ Entrypoint = 'Invoke-CodexParallelChildBindingHookEntrypoint' }
        @{ Entrypoint = 'Invoke-CodexParallelRemovalHookEntrypoint' }
    ) {
        & $Entrypoint `
            -RepositoryRoot 'C:/repo' `
            -PayloadReader { throw 'payload failure' } | Should -Be 2
    }

    It 'reads native console payloads for abandon and child-binding entrypoints' {
        Mock Invoke-CodexParallelAbandonSharedValidator { }
        Mock Invoke-CodexParallelChildBindingSharedValidator { }
        $originalIn = [Console]::In
        try {
            $abandonRaw = [pscustomobject]@{
                hook_event_name = 'PreToolUse'
                tool_name       = 'shell_command'
                tool_input      = [pscustomobject]@{
                    command = 'python -m scripts.dev_tools.parallel_mutation_abandon_cli'
                }
            } | ConvertTo-Json -Compress
            [Console]::SetIn([System.IO.StringReader]::new($abandonRaw))
            Invoke-CodexParallelAbandonHookEntrypoint -RepositoryRoot 'C:/repo' |
                Should -Be 0

            $bindingRaw = [pscustomobject]@{
                hook_event_name = 'PreToolUse'
                tool_name       = 'shell_command'
                tool_input      = [pscustomobject]@{}
            } | ConvertTo-Json -Compress
            [Console]::SetIn([System.IO.StringReader]::new($bindingRaw))
            Invoke-CodexParallelChildBindingHookEntrypoint `
                -RepositoryRoot 'C:/repo' `
                -LaunchId 'launch-1' | Should -Be 0
        } finally {
            [Console]::SetIn($originalIn)
        }
    }
}
