#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 7' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/scripts/launch-epic-child-wave.ps1'
            '.codex/scripts/parallel-child-post-session.ps1'
            '.codex/scripts/resume-epic-child.ps1'
        )
        . (Join-Path $script:RepoRoot $script:RuntimePaths[0])
        . (Join-Path $script:RepoRoot $script:RuntimePaths[1])
        . (Join-Path $script:RepoRoot $script:RuntimePaths[2]) -ReceiptPath 'unused'
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/scripts/launch-epic-child-wave.ps1' }
        @{ RuntimePath = '.codex/scripts/parallel-child-post-session.ps1' }
        @{ RuntimePath = '.codex/scripts/resume-epic-child.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'constructs an immutable epic launch receipt identity' {
        $spec = [pscustomobject]@{
            wave_id = 'wave-1'; checkpoint_kind = 'epic-orchestrator'
            wave_number = 1; max_parallel_features = 2; integration_branch = 'epic/run'
        }
        $entry = [pscustomobject]@{
            launch_id = 'launch-1'; feature_folder = 'feature-1'; issue_num = 1
            prompt = 'run'; permissions = 'epic-child-workspace'
        }
        $agentProfile = [pscustomobject]@{ developer_instructions = 'instructions'; skills_config = '[]' }
        $runtime = [pscustomobject]@{ CommandPath = 'codex'; DeniedPaths = @('auth.json') }
        $receipt = Get-CodexChildLaunchReceipt -Spec $spec -Entry $entry `
            -AgentProfile $agentProfile -CodexRuntime $runtime -SpecPath 'spec.json' `
            -SpecSha256 ('a' * 64) -CheckpointPath 'checkpoint.json' `
            -CheckpointSha256 ('b' * 64) -ReceiptPath 'receipt.json' `
            -StatusPath 'status.json' -CodexHomePath 'home' -WaveLockPath 'wave.lock'

        $receipt.launch_id | Should -BeExactly 'launch-1'
        $receipt.wave_id | Should -BeExactly 'wave-1'
        $receipt.runtime_permissions | Should -BeExactly 'epic-child-workspace'
    }

    It 'detects forbidden integration state recursively' {
        Test-CodexParallelPostSessionForbiddenState `
            -Value ([pscustomobject]@{ child = [pscustomobject]@{ integration_pr = 4 } }) |
            Should -BeTrue
        Test-CodexParallelPostSessionForbiddenState `
            -Value ([pscustomobject]@{ child = [pscustomobject]@{ pr_number = 4 } }) |
            Should -BeFalse
    }

    It 'honors WhatIf before resume wave status I/O' {
        $receipt = [pscustomobject]@{ status_path = 'absent-status.json' }

        { Set-CodexChildResumeWaveStatus -Receipt $receipt -WhatIf } | Should -Not -Throw
    }

    It 'rejects malformed command results and failed command diagnostics' {
        { Get-CodexParallelPostSessionCommandResult `
                -Invoker { [pscustomobject]@{} } `
                -Arguments @('status') `
                -Label 'git status' } | Should -Throw '*did not return an ExitCode*'
        { Get-CodexParallelPostSessionCommandResult `
                -Invoker {
                [pscustomobject]@{ ExitCode = 2; StdOut = 'stdout'; StdErr = 'stderr' }
            } `
                -Arguments @('status') `
                -Label 'git status' } | Should -Throw '*stderr stdout*'
    }

    It 'rejects empty and malformed post-session JSON' {
        { ConvertFrom-CodexParallelPostSessionJson -Json '' -Label 'PR list' } |
            Should -Throw '*returned empty JSON*'
        { ConvertFrom-CodexParallelPostSessionJson -Json '{' -Label 'PR list' } |
            Should -Throw '*returned invalid JSON*'
        (ConvertFrom-CodexParallelPostSessionJson `
            -Json '{"number":42}' -Label 'PR list').number | Should -Be 42
    }

    It 'rejects missing, duplicate, and incomplete checkpoint item identities' {
        $checkpoint = [pscustomobject]@{ route_id = 'parallel'; items = @() }
        { Get-CodexParallelPostSessionItem -Checkpoint $checkpoint -ItemKey 42 } |
            Should -Throw '*must resolve exactly once*'
        $item = [pscustomobject]@{
            issue_num = 42; base_branch = 'main'; branch_name = ''; worktree_path = ''
        }
        $checkpoint.items = @($item)
        { Get-CodexParallelPostSessionItem -Checkpoint $checkpoint -ItemKey 42 } |
            Should -Throw '*requires branch_name and worktree_path*'
        $item.branch_name = 'feature/item'
        $item.worktree_path = 'C:/worktree'
        $checkpoint.items = @($item, $item)
        { Get-CodexParallelPostSessionItem -Checkpoint $checkpoint -ItemKey 42 } |
            Should -Throw '*must resolve exactly once*'
    }

    It 'rejects unsafe receipt paths and missing atomic checkpoint publication' {
        $checkpoint = [pscustomobject]@{
            route_id = 'parallel'
            items    = @([pscustomobject]@{
                    issue_num = 42; base_branch = 'main'; branch_name = 'feature/item'
                    worktree_path = 'C:/worktree'
                })
        }
        { Invoke-CodexParallelChildPostSession `
                -Checkpoint $checkpoint -ItemKey 42 -RepositoryRoot $script:RepoRoot `
                -CompletionReceiptPath 'C:\receipt.json' } |
            Should -Throw '*must be repository-relative*'
        { Invoke-CodexParallelChildPostSession `
                -Checkpoint $checkpoint -ItemKey 42 -RepositoryRoot $script:RepoRoot `
                -CompletionReceiptPath 'artifacts/receipt.json' } |
            Should -Throw '*PersistCheckpoint is required*'
    }
}
