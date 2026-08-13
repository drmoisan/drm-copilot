#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 8' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/scripts/launch-parallel-child-batch.ps1'
            '.codex/scripts/parallel-child-launch-contract.ps1'
            '.codex/scripts/resume-parallel-child.ps1'
        )
        . (Join-Path $script:RepoRoot $script:RuntimePaths[0])
        . (Join-Path $script:RepoRoot $script:RuntimePaths[2]) -ReceiptPath 'unused'
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/scripts/launch-parallel-child-batch.ps1' }
        @{ RuntimePath = '.codex/scripts/parallel-child-launch-contract.ps1' }
        @{ RuntimePath = '.codex/scripts/resume-parallel-child.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'orders one persisted parallel batch by issue number' {
        $items = @(
            [pscustomobject]@{ issue_num = 9; cohort = 2; batch = 1; state = 'planned' }
            [pscustomobject]@{ issue_num = 3; cohort = 2; batch = 1; state = 'executing' }
            [pscustomobject]@{ issue_num = 1; cohort = 1; batch = 1; state = 'planned' }
            [pscustomobject]@{ issue_num = 4; cohort = 2; batch = 1; state = 'merged' }
        )

        $ordered = @(Get-CodexParallelChildBatchOrder -Items $items -Cohort 2 -Batch 1 `
                -MaxConcurrency 2 -AvailableThreadCount 2)

        @($ordered.issue_num) | Should -Be @(3, 9)
    }

    It 'detects forbidden parallel state and exposes every required binding field' {
        $fields = @(Get-CodexParallelRequiredBindingFieldList)

        Test-CodexParallelForbiddenState `
            -Value ([pscustomobject]@{ integration_branch = 'forbidden' }) | Should -BeTrue
        Test-CodexParallelForbiddenState `
            -Value ([pscustomobject]@{ base_branch = 'main' }) | Should -BeFalse
        $fields | Should -Be @(
            'authority_receipt_path'
            'delegation_receipt_path'
            'topology_receipt_path'
            'model_routing_receipt_path'
            'child_status_path'
        )
    }

    It 'selects the first incomplete item by cohort, batch, and issue number' {
        $checkpoint = [pscustomobject]@{ items = @(
                [pscustomobject]@{ issue_num = 8; cohort = 2; batch = 1; state = 'planned' }
                [pscustomobject]@{ issue_num = 4; cohort = 1; batch = 2; state = 'planned' }
                [pscustomobject]@{ issue_num = 9; cohort = 1; batch = 1; state = 'merged' }
                [pscustomobject]@{ issue_num = 6; cohort = 1; batch = 1; state = 'executing' }
                [pscustomobject]@{ issue_num = 2; cohort = 1; batch = 1; state = 'planned' }
            ) }

        $selected = Get-CodexParallelFirstIncompleteItem -Checkpoint $checkpoint

        $selected.issue_num | Should -Be 2
    }

    It 'rejects a persisted batch larger than the sealed concurrency limit' {
        $items = @(
            [pscustomobject]@{ issue_num = 1; cohort = 0; batch = 0; state = 'planned' }
            [pscustomobject]@{ issue_num = 2; cohort = 0; batch = 0; state = 'planned' }
        )
        { Get-CodexParallelChildBatchOrder `
                -Items $items -Cohort 0 -Batch 0 `
                -MaxConcurrency 1 -AvailableThreadCount 8 } |
            Should -Throw '*exceeds max_concurrency*'
    }

    It 'resolves and validates the exact origin main commit' {
        Mock Get-CodexChildGitScalar { 'a' * 64 }
        Get-CodexParallelOriginMainHead -RepositoryRoot $script:RepoRoot |
            Should -Be ('a' * 64)
        Mock Get-CodexChildGitScalar { 'invalid' }
        { Get-CodexParallelOriginMainHead -RepositoryRoot $script:RepoRoot } |
            Should -Throw '*did not resolve to a commit*'
    }

    It 'validates an existing child worktree against its branch and base commit' {
        $worktree = Join-Path $script:RepoRoot 'worktrees/child-1'
        $entry = [pscustomobject]@{
            worktree_path = $worktree; branch_name = 'feature/child-1'
        }
        Mock Get-CodexChildCanonicalPath { [string]$Path }
        Mock Test-Path { $true }
        Mock Get-CodexChildGitScalar {
            $joined = $GitArgs -join ' '
            if ($joined -match 'show-toplevel') { return $worktree }
            if ($joined -match 'show-current') { return 'feature/child-1' }
            return 'a' * 40
        }
        Initialize-CodexParallelChildWorktree `
            -RepositoryRoot $script:RepoRoot -Entry $entry `
            -OriginMainHead ('a' * 40) -Confirm:$false | Should -Be $worktree

        $entry.worktree_path = $script:RepoRoot
        { Initialize-CodexParallelChildWorktree `
                -RepositoryRoot $script:RepoRoot -Entry $entry `
                -OriginMainHead ('a' * 40) -Confirm:$false } |
            Should -Throw '*must be distinct*'
    }

    It 'builds permission boundaries and rejects an unsealed start command' {
        $permission = Get-CodexParallelPermissionOverride `
            -DeniedPaths @('', 'C:/denied')
        $permission | Should -Match 'parallel-child-workspace'
        $permission | Should -Match 'C:/denied'
        $info = [System.Diagnostics.ProcessStartInfo]::new('codex')
        { Add-CodexParallelMcpRestriction -StartInfo $info } |
            Should -Throw '*strict config boundary is missing*'
    }

    It 'forwards persistence, profile, receipt, and status adapters to shared cores' {
        Mock Write-CodexChildJsonCreateNewCore { }
        Write-CodexParallelChildJsonCreateNew `
            -Path 'receipt.json' -Value ([ordered]@{ state = 'active' })
        Should -Invoke Write-CodexChildJsonCreateNewCore -Times 1

        Mock Write-CodexChildJsonAtomicCore { }
        Write-CodexParallelChildJsonAtomic `
            -Path 'status.json' -Value ([ordered]@{ state = 'active' })
        Should -Invoke Write-CodexChildJsonAtomicCore -Times 1

        Mock Set-CodexChildReceiptStateCore { }
        Set-CodexParallelChildReceiptState `
            -Receipt ([pscustomobject]@{ receipt_path = 'receipt.json' }) `
            -State completed -ExitCode 0 -Confirm:$false
        Should -Invoke Set-CodexChildReceiptStateCore -Times 1

        Mock Get-CodexChildTrustedProfile {
            [pscustomobject]@{ Raw = 'profile'; Path = 'profile.toml'; Sha256 = ('a' * 64) }
        }
        Mock ConvertFrom-CodexAgentProfileCore {
            [pscustomobject]@{ name = 'worker'; model = 'model' }
        }
        $agentProfile = Get-CodexParallelChildProfile `
            -WorktreePath 'worktree' -AgentName 'worker' `
            -OriginMainHead ('a' * 40) -RepositoryRoot $script:RepoRoot
        $agentProfile.profile_path | Should -Be 'profile.toml'
        $agentProfile.trusted_repository_root | Should -Be $script:RepoRoot

        Mock Write-CodexParallelChildJsonAtomic { }
        Write-CodexParallelChildStatus `
            -Path 'status.json' `
            -Receipt ([pscustomobject]@{ launch_id = 'launch-1' }) `
            -Entry ([ordered]@{ state = 'running' })
        Should -Invoke Write-CodexParallelChildJsonAtomic -Times 1
    }

    It 'returns comprehensive contract errors for malformed launch state' {
        $entry = [pscustomobject]@{
            issue_num = 0; cohort = 2; batch = 2; launch_id = ''
            worktree_path = ''; branch_name = ''; deployment_agent = ''
            model = ''; model_reasoning_effort = ''; permissions = ''
            execution_context = ''; prompt = ''; feature_folder = ''
        }
        $spec = [pscustomobject]@{
            schema_version = 1; surface = 'parallel'; parallel_slug = 'other'
            base_branch = 'main'; pr_target = 'main'; cohort = 2; batch = 2
            max_concurrency = 9; origin_main_head = 'invalid'; launches = @($null, $entry)
        }
        $checkpoint = [pscustomobject]@{
            route_id = 'parallel'; parallel_slug = 'run'; current_cohort = 0
            max_concurrency = 2; items = @()
        }
        $errors = Test-CodexParallelChildLaunchSpec `
            -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey @{} -LiveBranchesByWorktree @{} `
            -VerifiedOriginMainHead 'invalid'
        $errors.Count | Should -BeGreaterThan 8
        $errors | Should -Contain 'schema_version must be 2.'
        $errors | Should -Contain 'parallel launch entry must not be null.'
        Get-CodexParallelCheckpointItem -Checkpoint $checkpoint -Entry $entry |
            Should -BeNullOrEmpty
    }
}
