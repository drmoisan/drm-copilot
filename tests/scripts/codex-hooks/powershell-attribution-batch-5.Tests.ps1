#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 5' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/hooks/validate-codex-subagent-routing.ps1'
            '.codex/scripts/codex-child-launch-contract-core.ps1'
            '.codex/scripts/codex-child-launch-resume.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/hooks/validate-codex-subagent-routing.ps1' }
        @{ RuntimePath = '.codex/scripts/codex-child-launch-contract-core.ps1' }
        @{ RuntimePath = '.codex/scripts/codex-child-launch-resume.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'classifies stop-gated personas and bounds continuation responses' {
        Test-CodexStopGatedAgent -AgentType 'parallel-orchestrator' | Should -BeTrue
        Test-CodexStopGatedAgent -AgentType 'worker-c4' | Should -BeTrue
        Test-CodexStopGatedAgent -AgentType 'default' | Should -BeFalse
        (Get-CodexStopContinuation -Reason 'blocked' -AlreadyContinued $false).decision |
            Should -Be 'block'
        (Get-CodexStopContinuation -Reason 'blocked' -AlreadyContinued $true).continue |
            Should -BeFalse
    }

    It 'enforces launch concurrency and scalar identity boundaries' {
        Get-CodexChildEffectiveMaximum -RequestedMaximum 8 -SpecMaximum 3 | Should -Be 3
        Test-CodexChildPositiveInteger -Value 1 | Should -BeTrue
        Test-CodexChildPositiveInteger -Value 0 | Should -BeFalse
        Test-CodexChildPositiveInteger -Value '1' | Should -BeFalse
        Test-CodexChildSha256 -Value ('a' * 64) | Should -BeTrue
        Test-CodexChildSha256 -Value ('A' * 64) | Should -BeFalse
    }

    It 'reads and validates resume record values without coercion' {
        $record = [pscustomobject]@{ launch_id = 'launch-1'; process_id = [int]42 }

        Get-CodexChildResumePropertyCore `
            -Record $record `
            -Name 'launch_id' `
            -RecordName 'receipt' | Should -BeExactly 'launch-1'
        { Assert-CodexChildResumeTextCore -Record $record -Name 'launch_id' `
                -RecordName 'receipt' -Expected 'launch-2' } | Should -Throw '*does not match*'
        { Assert-CodexChildResumeIntegerCore -Record $record -Name 'process_id' `
                -RecordName 'status' -Expected 42 } | Should -Not -Throw
    }

    It 'parses launch JSON and validates canonical repository paths' {
        (ConvertFrom-CodexChildLaunchJsonCore -Raw '{"value":1}' -Name 'spec').value |
            Should -Be 1
        { ConvertFrom-CodexChildLaunchJsonCore -Raw ' ' -Name 'spec' } |
            Should -Throw '*spec is empty*'
        { ConvertFrom-CodexChildLaunchJsonCore -Raw '{' -Name 'spec' } |
            Should -Throw '*malformed JSON*'

        $relative = Get-CodexChildCanonicalPath -Path 'child' -BasePath $script:RepoRoot
        $absolute = Get-CodexChildCanonicalPath -Path $relative -BasePath $script:RepoRoot
        $absolute | Should -BeExactly $relative
        Get-CodexChildProfileKey `
            -WorktreePath 'child' -AgentName 'worker' -RepositoryRoot $script:RepoRoot |
            Should -Be "$relative`nworker"
        Test-CodexChildIssueEqual -Left 42 -Right 42 | Should -BeTrue
        Test-CodexChildIssueEqual -Left 42 -Right '42' | Should -BeFalse
        Test-CodexChildActiveFeatureFolder -Path 'docs/features/active/feature-a' |
            Should -BeTrue
        foreach ($path in @(
                $script:RepoRoot,
                'docs/features/active/../feature-a',
                'docs/features/active/pending'
            )) {
            Test-CodexChildActiveFeatureFolder -Path $path | Should -BeFalse
        }
        Test-CodexChildRepositoryPath -Path 'artifacts/state.json' `
            -RepositoryRoot $script:RepoRoot | Should -BeTrue
        foreach ($path in @('', 'C:\outside.json', '../outside.json', 'folder\file.json')) {
            Test-CodexChildRepositoryPath -Path $path -RepositoryRoot $script:RepoRoot |
                Should -BeFalse
        }
    }

    It 'constructs and validates immutable launch identities' {
        $worktree = Get-CodexChildCanonicalPath -Path 'child-worktree' -BasePath $script:RepoRoot
        $entry = [pscustomobject]@{
            branch_name            = 'feature/child'
            worktree_path          = $worktree
            deployment_agent       = 'worker-c3'
            model                  = 'gpt-5.6-terra'
            model_reasoning_effort = 'high'
            permissions            = 'workspace-write'
        }
        $bindings = [ordered]@{
            authority_receipt_path = 'artifacts/authority.json'
            launch_spec_sha256     = ('a' * 64)
            codex_home_path        = Get-CodexChildCanonicalPath `
                -Path '.codex-home' -BasePath $script:RepoRoot
        }
        $identity = ConvertTo-CodexChildLaunchIdentity `
            -Surface parallel `
            -RepositoryRoot $script:RepoRoot `
            -BaseBranch main `
            -Entry $entry `
            -Bindings $bindings
        $agentProfile = [pscustomobject]@{
            name                   = 'worker-c3'
            model                  = 'gpt-5.6-terra'
            model_reasoning_effort = 'high'
            default_permissions    = 'workspace-write'
            worktree_path          = $worktree
        }
        Test-CodexChildLaunchIdentity `
            -Identity $identity `
            -AgentProfile $agentProfile `
            -ExpectedSurface parallel `
            -ExpectedRepositoryRoot $script:RepoRoot `
            -ExpectedBaseBranch main `
            -LiveBranch 'feature/child' `
            -RequiredBindingFields @(
            'authority_receipt_path', 'launch_spec_sha256', 'codex_home_path'
        ) | Should -BeNullOrEmpty

        { ConvertTo-CodexChildLaunchIdentity `
                -Surface parallel -RepositoryRoot $script:RepoRoot -BaseBranch main `
                -Entry $entry -Bindings @{ surface = 'duplicate' } } |
            Should -Throw '*duplicate immutable*'

        $invalid = [ordered]@{}
        foreach ($key in $identity.Keys) {
            $invalid[$key] = $identity[$key]
        }
        $invalid.schema_version = 2
        $invalid.repository_root = '.'
        $invalid.base_branch = 'other'
        $invalid.worktree_path = 'relative-worktree'
        $invalid.deployment_agent = 'other'
        $invalid.Remove('authority_receipt_path')
        $invalid.launch_spec_sha256 = 'BAD'
        $invalid.codex_home_path = Join-Path (
            Get-CodexChildCanonicalPath -Path 'relative-worktree' -BasePath $script:RepoRoot
        ) 'nested'
        $errors = Test-CodexChildLaunchIdentity `
            -Identity $invalid `
            -AgentProfile $agentProfile `
            -ExpectedSurface parallel `
            -ExpectedRepositoryRoot $script:RepoRoot `
            -ExpectedBaseBranch main `
            -LiveBranch 'feature/child' `
            -RequiredBindingFields @(
            'authority_receipt_path', 'launch_spec_sha256', 'codex_home_path'
        )
        $errors.Count | Should -BeGreaterThan 5
        $errors -join ';' | Should -Match 'missing required binding'
        $errors -join ';' | Should -Match 'lowercase SHA-256'
        $errors -join ';' | Should -Match 'isolated from the child worktree'
    }

    It 'validates active and terminal receipt timestamps and required fields' {
        $now = [datetimeoffset]'2026-08-12T12:00:00Z'
        ConvertTo-CodexChildReceiptTimestamp -Value '2026-08-12T11:00:00Z' |
            Should -BeOfType ([datetimeoffset])
        { ConvertTo-CodexChildReceiptTimestamp -Value $null } |
            Should -Throw '*missing*'
        { ConvertTo-CodexChildReceiptTimestamp -Value 'invalid' } |
            Should -Throw '*invalid*'

        $active = [pscustomobject]@{
            schema_version = 2; state = 'active'; codex_session_id = 'session-1'
            session_bound_at = '2026-08-12T11:00:00Z'; expires_at = '2026-08-12T13:00:00Z'
            launch_id = 'launch-1'; delegation_id = 'delegation-1'; feature_folder = 'feature'
            deployment_agent = 'worker'; model = 'model'; model_reasoning_effort = 'high'
            execution_context = 'child'; worktree_path = 'worktree'; branch_name = 'branch'
            receipt_path = 'receipt'; status_path = 'status'; spec_path = 'spec'
            profile_path = 'profile'; codex_home_path = 'home'; trusted_repository_root = 'root'
            checkpoint_kind = 'parallel'; wave_lock_path = 'lock'
        }
        Get-CodexChildActiveReceiptErrorList `
            -Receipt $active -ExpectedSessionId 'session-1' -Now $now |
            Should -BeNullOrEmpty
        $active.schema_version = 1
        $active.codex_session_id = 'other'
        $active.expires_at = '2026-08-12T10:00:00Z'
        $active.launch_id = ''
        (Get-CodexChildActiveReceiptErrorList `
            -Receipt $active -ExpectedSessionId 'session-1' -Now $now).Count |
            Should -BeGreaterThan 3

        $terminal = [pscustomobject]@{
            schema_version = 2; state = 'completed'; codex_session_id = 'session-1'
            session_bound_at = '2026-08-12T11:00:00Z'; completed_at = '2026-08-12T12:00:00Z'
            failed_at = ''; exit_code = 0
        }
        Get-CodexChildTerminalReceiptErrorList -Receipt $terminal |
            Should -BeNullOrEmpty
        $terminal.state = 'failed'
        $terminal.failed_at = '2026-08-12T12:00:00Z'
        Get-CodexChildTerminalReceiptErrorList -Receipt $terminal |
            Should -BeNullOrEmpty
        $terminal.schema_version = 1
        $terminal.codex_session_id = ''
        $terminal.failed_at = ''
        (Get-CodexChildTerminalReceiptErrorList -Receipt $terminal).Count |
            Should -BeGreaterThan 2
    }

    It 'parses complete profiles and rejects incomplete generated profiles' {
        $raw = @'
name = "worker-c3"
model = "gpt-5.6-terra"
model_reasoning_effort = "high"
default_permissions = "workspace-write"
developer_instructions = '''instructions'''
[skills]
config = ["powershell"]
'@
        $agentProfile = ConvertFrom-CodexAgentProfileCore -ProfileRaw $raw
        $agentProfile.name | Should -Be 'worker-c3'
        $agentProfile.skills_config | Should -Be '["powershell"]'
        { ConvertFrom-CodexAgentProfileCore -ProfileRaw 'name = "worker"' } |
            Should -Throw '*missing model*'
        $missingSkills = $raw -replace '(?ms)\[skills\].*$', ''
        { ConvertFrom-CodexAgentProfileCore -ProfileRaw $missingSkills } |
            Should -Throw '*must define developer_instructions*'
    }

    It 'rejects missing and incorrectly typed resume scalar properties' {
        { Get-CodexChildResumePropertyCore `
                -Record $null -Name 'value' -RecordName 'record' } |
            Should -Throw '*record is missing*'
        { Get-CodexChildResumePropertyCore `
                -Record ([pscustomobject]@{}) -Name 'value' -RecordName 'record' } |
            Should -Throw '*missing required property*'
        { Assert-CodexChildResumeTextCore `
                -Record ([pscustomobject]@{ value = 42 }) `
                -Name value -RecordName record -Expected expected } |
            Should -Throw '*must be a non-empty string*'
        { Assert-CodexChildResumeIntegerCore `
                -Record ([pscustomobject]@{ value = '42' }) `
                -Name value -RecordName record -Expected 42 } |
            Should -Throw '*must be an integer*'
        { Assert-CodexChildResumeIntegerCore `
                -Record ([pscustomobject]@{ value = 41 }) `
                -Name value -RecordName record -Expected 42 } |
            Should -Throw '*does not match the live process*'
    }

    It 'validates complete resume identity, process, and status records' {
        $identity = [ordered]@{
            spec_sha256 = ('a' * 64); checkpoint_sha256 = ('b' * 64)
            trusted_repository_root = 'C:\repo'; branch_name = 'feature/child'
            worktree_path = 'C:\worktree'; deployment_agent = 'worker-c3'
            model = 'gpt-5.6-terra'; model_reasoning_effort = 'high'
            authority_receipt_path = 'authority.json'; delegation_receipt_path = 'delegation.json'
            topology_receipt_path = 'topology.json'; model_routing_receipt_path = 'model.json'
            permissions = 'workspace-write'; child_status_path = 'status.json'
        }
        $receiptIdentity = [pscustomobject]$identity
        { Assert-CodexChildResumeLaunchIdentityCore `
                -Expected ([pscustomobject]$identity) `
                -Receipt $receiptIdentity } | Should -Not -Throw
        $badExpected = [ordered]@{}
        foreach ($key in $identity.Keys) {
            $badExpected[$key] = $identity[$key]
        }
        $badExpected.spec_sha256 = ''
        { Assert-CodexChildResumeLaunchIdentityCore `
                -Expected ([pscustomobject]$badExpected) `
                -Receipt $receiptIdentity } | Should -Throw '*must be a non-empty string*'

        $started = '2026-08-12T12:00:00.0000000+00:00'
        $processReceipt = [pscustomobject]@{
            process_id = 42; process_started_at_utc = $started
        }
        $live = [pscustomobject]@{
            process_id = 42; process_started_at_utc = $started
        }
        { Assert-CodexChildResumeProcessCore `
                -Receipt $processReceipt -LiveProcess $live } | Should -Not -Throw
        foreach ($value in @('42', 0)) {
            $invalidReceipt = [pscustomobject]@{
                process_id = $value; process_started_at_utc = $started
            }
            { Assert-CodexChildResumeProcessCore `
                    -Receipt $invalidReceipt -LiveProcess $live } | Should -Throw
        }
        foreach ($value in @('', 'not-a-timestamp')) {
            $invalidReceipt = [pscustomobject]@{
                process_id = 42; process_started_at_utc = $value
            }
            { Assert-CodexChildResumeProcessCore `
                    -Receipt $invalidReceipt -LiveProcess $live } | Should -Throw
        }

        $expectedStatus = [pscustomobject]@{
            launch_hash = 'hash'; repository = 'repo'; head_branch = 'branch'
            worktree_path = 'worktree'; agent = 'worker'
        }
        $receipt = [pscustomobject]@{ process_id = 42 }
        $status = [pscustomobject]@{
            launch_hash = 'hash'; repository = 'repo'; head_branch = 'branch'
            worktree_path = 'worktree'; agent = 'worker'; process_id = 42
            state = 'completed'
        }
        { Assert-CodexChildResumeStatusCore `
                -Expected $expectedStatus -Receipt $receipt -ChildStatus $status } |
            Should -Not -Throw
        $status.state = 'queued'
        { Assert-CodexChildResumeStatusCore `
                -Expected $expectedStatus -Receipt $receipt -ChildStatus $status } |
            Should -Throw '*must be running, completed, or failed*'
    }

    It 'reconciles exited live status and legacy direct resume evidence' {
        $receipt = [pscustomobject]@{ codex_session_id = 'session-1' }
        $childStatus = [pscustomobject]@{
            state = 'completed'; receipt_path = 'receipt.json'
            codex_session_id = 'session-1'; pid = 42
        }
        $liveStatus = Get-CodexChildResumeLiveStatusCore `
            -Receipt $receipt `
            -ChildStatus $childStatus `
            -ReceiptPath 'receipt.json' `
            -GetLiveProcess { [pscustomobject]@{ Id = 42; HasExited = $true } }
        $liveStatus.authoritative_source | Should -Be 'live-process-exited'
        $liveStatus.process_id | Should -Be 42

        $identity = [ordered]@{
            spec_sha256 = ('a' * 64); checkpoint_sha256 = ('b' * 64)
            trusted_repository_root = 'C:\repo'; branch_name = 'feature/child'
            worktree_path = 'C:\worktree'; deployment_agent = 'worker-c3'
            model = 'gpt-5.6-terra'; model_reasoning_effort = 'high'
            authority_receipt_path = 'authority.json'; delegation_receipt_path = 'delegation.json'
            topology_receipt_path = 'topology.json'; model_routing_receipt_path = 'model.json'
            permissions = 'workspace-write'; child_status_path = 'status.json'
            launch_hash = 'hash'; repository = 'repo'; head_branch = 'feature/child'
            agent = 'worker-c3'
        }
        $started = '2026-08-12T12:00:00.0000000+00:00'
        $directReceipt = [ordered]@{}
        foreach ($key in @(
                'spec_sha256', 'checkpoint_sha256', 'trusted_repository_root',
                'branch_name', 'worktree_path', 'deployment_agent', 'model',
                'model_reasoning_effort', 'authority_receipt_path',
                'delegation_receipt_path', 'topology_receipt_path',
                'model_routing_receipt_path', 'permissions', 'child_status_path'
            )) {
            $directReceipt[$key] = $identity[$key]
        }
        $directReceipt.process_id = 42
        $directReceipt.process_started_at_utc = $started
        $liveProcess = [pscustomobject]@{
            process_id = 42; process_started_at_utc = $started
        }
        $directStatus = [pscustomobject]@{
            launch_hash = 'hash'; repository = 'repo'; head_branch = 'feature/child'
            worktree_path = 'C:\worktree'; agent = 'worker-c3'; process_id = 42
            state = 'completed'
        }
        $result = Get-CodexChildResumeReconciliationCore `
            -Expected ([pscustomobject]$identity) `
            -Receipt ([pscustomobject]$directReceipt) `
            -LiveProcess $liveProcess `
            -ChildStatus $directStatus
        $result.state | Should -Be 'completed'
        $result.authoritative_source | Should -Be 'live-process-and-child-status'
        { Get-CodexChildResumeReconciliationCore `
                -Receipt ([pscustomobject]$directReceipt) } |
            Should -Throw '*requires expected identity*'
    }

    It 'requires path and process-query evidence for sealed-spec reconciliation' {
        $receipt = [pscustomobject]@{
            launch_id = 'launch-1'; delegation_id = 'delegation-1'; feature_folder = 'feature'
            issue_num = 1; deployment_agent = 'worker'; model = 'model'
            model_reasoning_effort = 'high'; permissions = 'workspace'
            execution_context = 'child'; worktree_path = 'worktree'; branch_name = 'branch'
            prompt_sha256 = Get-CodexChildSha256 -Value 'prompt'
        }
        $spec = [pscustomobject]@{
            launches = @([pscustomobject]@{
                    launch_id = 'launch-1'; delegation_id = 'delegation-1'
                    feature_folder = 'feature'; issue_num = 1; deployment_agent = 'worker'
                    model = 'model'; model_reasoning_effort = 'high'; permissions = 'workspace'
                    execution_context = 'child'; worktree_path = 'worktree'
                    branch_name = 'branch'; prompt = 'prompt'
                })
        }
        $errors = Get-CodexChildResumeReconciliationCore `
            -Receipt $receipt `
            -Spec $spec `
            -Status ([pscustomobject]@{ schema_version = 2; launches = [pscustomobject]@{} })
        $errors | Should -Contain 'child status reconciliation requires receipt path and live process query evidence.'
    }
}
