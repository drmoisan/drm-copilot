#Requires -Version 7.0

<#
.SYNOPSIS
    Branch tests for the pure epic-child launch contract (issue #1035, remediation F1).

.DESCRIPTION
    Dot-sources .codex/scripts/epic-child-launch-contract.ps1 and drives the JSON, timestamp,
    receipt, profile, receipt-lookup and launch-spec branches that the launcher hardening suite
    does not reach. Every input is an in-memory object; no row reads a receipt, a profile or a
    checkpoint from disk, and no row runs git.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    # The contract imports the development-docs module when dot-sourced; remove it in AfterAll
    # when this suite was the one that loaded it.
    $script:DocsModuleWasLoaded = $null -ne (Get-Module -Name DevelopmentDocsRoot)
    . (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-contract.ps1')

    function Get-ContractTestFeature {
        param([string] $Name, [int] $Issue, [string] $Worktree, [switch] $LegacyWave)
        $delegationId = "delegate-$Name"
        $agent = 'orchestrator-c3-elevated'
        $featureFolder = "docs/features/active/$Name"
        $feature = [ordered]@{
            issue_num = $Issue; feature_folder = $featureFolder
            worktree_path = $Worktree; branch_name = "feature/$Name"; merge_status = 'not_started'
            delegation_receipt    = [pscustomobject]@{
                delegation_id = $delegationId; feature_folder = $featureFolder
                issue_num = $Issue; agent_name = $agent
            }
            model_routing_receipt = [pscustomobject]@{
                delegation_id = $delegationId; deployment_agent = $agent
                model = 'gpt-6-astra'; model_reasoning_effort = 'high'
                execution_context = 'epic_execution_child'
            }
        }
        if ($LegacyWave) { $feature['wave'] = 1 } else { $feature['wave_number'] = 1 }
        return [pscustomobject]$feature
    }

    function Get-ContractTestEntry {
        param([Parameter(Mandatory)] $Feature, [string] $Context = 'epic_execution_child', [string] $Prompt)
        $text = if ($PSBoundParameters.ContainsKey('Prompt')) { $Prompt } else {
            'Epic mode: true. epic_feature_folder: sample-epic. integration_branch: epic/sample-integration. pass --base epic/sample-integration to gh pr create.'
        }
        return [pscustomobject]@{
            launch_id     = "launch-$(Split-Path ([string]$Feature.feature_folder) -Leaf)"
            delegation_id = [string]$Feature.delegation_receipt.delegation_id
            feature_folder = [string]$Feature.feature_folder; issue_num = $Feature.issue_num
            deployment_agent = 'orchestrator-c3-elevated'; model = 'gpt-6-astra'
            model_reasoning_effort = 'high'; permissions = 'orchestrator-workspace'
            execution_context = $Context; worktree_path = [string]$Feature.worktree_path
            branch_name = [string]$Feature.branch_name; prompt = $text
        }
    }

    $script:WorktreeA = Join-Path $script:RepoRoot 'worktrees/contract-a'
    $script:Profiles = @{}
    $key = Get-CodexChildProfileKey -WorktreePath $script:WorktreeA -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
    $script:Profiles[$key] = [pscustomobject]@{
        name = 'orchestrator-c3-elevated'; model = 'gpt-6-astra'
        model_reasoning_effort = 'high'; default_permissions = 'orchestrator-workspace'
    }
    $script:Branches = @{ $script:WorktreeA = 'feature/contract-a' }

    function Get-ContractTestSpec {
        param([object[]] $Launches, [string] $Kind = 'epic-orchestrator', [int] $Wave = 1)
        return [pscustomobject]@{
            schema_version = 1; checkpoint_kind = $Kind; wave_id = 'wave-1'
            wave_number = $Wave; max_parallel_features = 4; integration_branch = 'epic/sample-integration'
            checkpoint_path = "artifacts/orchestration/$Kind-state.json"; launches = $Launches
        }
    }

    function Get-ContractTestCheckpoint {
        param([object[]] $Features)
        return [pscustomobject]@{
            integration_branch = 'epic/sample-integration'; epic_feature_folder = 'sample-epic'
            max_parallel_features = 4; features = $Features
        }
    }

    $script:ValidProfileRaw = @"
name = "orchestrator-c3"
model = "gpt-6-astra"
model_reasoning_effort = "high"
default_permissions = "orchestrator-workspace"
developer_instructions = '''
Follow the plan.
'''

[skills]
config = [ "orchestrate" ]
"@
}

AfterAll {
    if (-not $script:DocsModuleWasLoaded) {
        Remove-Module -Name DevelopmentDocsRoot -ErrorAction SilentlyContinue
    }
}

Describe 'ConvertFrom-CodexChildLaunchJson' {
    It 'throws EPIC_CHILD_LAUNCH_BLOCKED for empty input' {
        { ConvertFrom-CodexChildLaunchJson -Raw '  ' -Name 'launch spec' } | Should -Throw '*EPIC_CHILD_LAUNCH_BLOCKED: launch spec is empty.*'
    }

    It 'throws EPIC_CHILD_LAUNCH_BLOCKED for malformed JSON' {
        { ConvertFrom-CodexChildLaunchJson -Raw '{ not json' -Name 'launch spec' } | Should -Throw '*EPIC_CHILD_LAUNCH_BLOCKED: launch spec is malformed JSON*'
    }

    It 'returns the parsed object for valid JSON' {
        (ConvertFrom-CodexChildLaunchJson -Raw '{"schema_version":1}' -Name 'launch spec').schema_version | Should -Be 1
    }
}

Describe 'ConvertTo-CodexChildReceiptTimestamp' {
    It 'throws for an invalid timestamp value' {
        { ConvertTo-CodexChildReceiptTimestamp -Value 'not-a-timestamp' } | Should -Throw '*receipt timestamp is invalid*'
    }

    It 'throws for a missing timestamp value' {
        { ConvertTo-CodexChildReceiptTimestamp -Value $null } | Should -Throw '*receipt timestamp is missing.*'
    }
}

Describe 'Get-CodexChildActiveReceiptErrorList' {
    BeforeAll {
        $script:Now = [datetimeoffset]'2026-07-11T12:00:00Z'
        function Get-ActiveReceipt {
            $receipt = [ordered]@{
                schema_version = 2; state = 'active'; codex_session_id = 'session-a'
                session_bound_at = '2026-07-10T12:00:00Z'; expires_at = '2026-07-12T12:00:00Z'
            }
            foreach ($name in @(
                    'launch_id', 'delegation_id', 'feature_folder', 'deployment_agent', 'model',
                    'model_reasoning_effort', 'execution_context', 'worktree_path', 'branch_name',
                    'receipt_path', 'status_path', 'spec_path', 'profile_path', 'codex_home_path',
                    'trusted_repository_root', 'checkpoint_kind', 'wave_lock_path')) {
                $receipt[$name] = "value-$name"
            }
            return [pscustomobject]$receipt
        }
    }

    It 'accepts a complete active receipt bound to the expected session' {
        Get-CodexChildActiveReceiptErrorList -Receipt (Get-ActiveReceipt) -ExpectedSessionId 'session-a' -Now $script:Now | Should -BeNullOrEmpty
    }

    It 'reports a receipt in the wrong state' {
        $receipt = Get-ActiveReceipt; $receipt.state = 'launching'
        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -Now $script:Now | Should -Contain 'launch receipt must use schema_version 2 and state active.'
    }

    It 'reports a session id that does not match the expected session' {
        Get-CodexChildActiveReceiptErrorList -Receipt (Get-ActiveReceipt) -ExpectedSessionId 'session-b' -Now $script:Now |
            Should -Contain 'launch receipt session id is missing or does not match the active Codex session.'
    }

    It 'reports an expired receipt' {
        Get-CodexChildActiveReceiptErrorList -Receipt (Get-ActiveReceipt) -Now ([datetimeoffset]'2026-07-13T12:00:00Z') |
            Should -Contain 'launch receipt session timestamps are invalid or expired.'
    }

    It 'reports an unparseable bound timestamp as invalid' {
        $receipt = Get-ActiveReceipt; $receipt.session_bound_at = 'garbage'
        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -Now $script:Now | Should -Contain 'launch receipt session timestamps are invalid or expired.'
    }

    It 'reports each missing required field' {
        $receipt = Get-ActiveReceipt; $receipt.worktree_path = ''; $receipt.wave_lock_path = ' '
        $errors = Get-CodexChildActiveReceiptErrorList -Receipt $receipt -Now $script:Now
        $errors | Should -Contain 'launch receipt is missing worktree_path.'
        $errors | Should -Contain 'launch receipt is missing wave_lock_path.'
    }
}

Describe 'Get-CodexChildTerminalReceiptErrorList' {
    It 'accepts a completed receipt with exit code 0 and ordered timestamps' {
        $receipt = [pscustomobject]@{
            schema_version = 2; state = 'completed'; codex_session_id = 's'; exit_code = 0
            session_bound_at = '2026-07-10T12:00:00Z'; completed_at = '2026-07-10T13:00:00Z'
        }
        Get-CodexChildTerminalReceiptErrorList -Receipt $receipt | Should -BeNullOrEmpty
    }

    It 'reports a completed receipt with a non-zero exit code' {
        $receipt = [pscustomobject]@{
            schema_version = 2; state = 'completed'; codex_session_id = 's'; exit_code = 3
            session_bound_at = '2026-07-10T12:00:00Z'; completed_at = '2026-07-10T13:00:00Z'
        }
        Get-CodexChildTerminalReceiptErrorList -Receipt $receipt | Should -Contain 'completed launch receipt requires exit_code 0 and completed_at.'
    }

    It 'reports a failed receipt without failed_at' {
        $receipt = [pscustomobject]@{
            schema_version = 2; state = 'failed'; codex_session_id = 's'; exit_code = 1
            session_bound_at = '2026-07-10T12:00:00Z'; failed_at = ''
        }
        $errors = Get-CodexChildTerminalReceiptErrorList -Receipt $receipt
        $errors | Should -Contain 'failed launch receipt requires failed_at.'
        $errors | Should -Contain 'terminal launch receipt timestamps are invalid or out of order.'
    }

    It 'reports out-of-order timestamps, a missing session id and a non-terminal state' {
        $receipt = [pscustomobject]@{
            schema_version = 2; state = 'active'; codex_session_id = ''; exit_code = 1
            session_bound_at = '2026-07-10T12:00:00Z'; failed_at = '2026-07-10T11:00:00Z'
        }
        $errors = Get-CodexChildTerminalReceiptErrorList -Receipt $receipt
        $errors | Should -Contain 'terminal launch receipt must use schema_version 2 and state completed or failed.'
        $errors | Should -Contain 'terminal launch receipt must preserve the bound Codex session id.'
        $errors | Should -Contain 'terminal launch receipt timestamps are invalid or out of order.'
    }
}

Describe 'ConvertFrom-CodexAgentProfile' {
    It 'parses the four keys, the developer instructions and skills.config' {
        $result = ConvertFrom-CodexAgentProfile -ProfileRaw $script:ValidProfileRaw
        $result.name | Should -Be 'orchestrator-c3'
        $result.default_permissions | Should -Be 'orchestrator-workspace'
        $result.skills_config | Should -Be '[ "orchestrate" ]'
        $result.developer_instructions | Should -Match 'Follow the plan\.'
    }

    It 'throws when a required key is missing' {
        $raw = $script:ValidProfileRaw -replace '(?m)^model = "gpt-6-astra"\r?\n', ''
        { ConvertFrom-CodexAgentProfile -ProfileRaw $raw } | Should -Throw '*generated profile is missing model.*'
    }

    It 'throws when the skills section has no config entry' {
        $raw = $script:ValidProfileRaw -replace '(?m)^config = .*$', 'enabled = true'
        { ConvertFrom-CodexAgentProfile -ProfileRaw $raw } | Should -Throw '*must define developer_instructions and skills.config.*'
    }

    It 'throws when the skills section is absent' {
        $raw = ($script:ValidProfileRaw -split '\[skills\]')[0]
        { ConvertFrom-CodexAgentProfile -ProfileRaw $raw } | Should -Throw '*must define developer_instructions and skills.config.*'
    }
}

Describe 'Find-CodexChildDelegationReceipt and Find-CodexChildModelReceipt' {
    BeforeAll {
        $script:Entry = [pscustomobject]@{
            feature_folder = 'docs/features/active/x'; issue_num = 7; delegation_id = 'd-1'
            deployment_agent = 'agent-a'; model = 'm'; model_reasoning_effort = 'high'; execution_context = 'epic_execution_child'
        }
        $script:BareFeature = [pscustomobject]@{ feature_folder = 'docs/features/active/x'; issue_num = 7 }
    }

    It 'matches a checkpoint-level delegation receipt by id and skips null entries' {
        $receipt = [pscustomobject]@{ id = 'd-1'; feature_folder = 'docs/features/active/x'; issue_num = 7; agent_name = 'agent-a' }
        $checkpoint = [pscustomobject]@{ delegation_receipts = @($null, $receipt) }
        Find-CodexChildDelegationReceipt -Checkpoint $checkpoint -Feature $script:BareFeature -Entry $script:Entry | Should -Be $receipt
    }

    It 'returns null when a receipt carries neither delegation_id nor id' {
        $receipt = [pscustomobject]@{ feature_folder = 'docs/features/active/x'; issue_num = 7; agent_name = 'agent-a' }
        $checkpoint = [pscustomobject]@{ delegation_receipts = @($receipt) }
        Find-CodexChildDelegationReceipt -Checkpoint $checkpoint -Feature $script:BareFeature -Entry $script:Entry | Should -BeNullOrEmpty
    }

    It 'matches a checkpoint-level model-routing receipt' {
        $receipt = [pscustomobject]@{ delegation_id = 'd-1'; deployment_agent = 'agent-a'; model = 'm'; model_reasoning_effort = 'high'; execution_context = 'epic_execution_child' }
        $checkpoint = [pscustomobject]@{ codex_model_routing_receipts = @($null, $receipt) }
        Find-CodexChildModelReceipt -Checkpoint $checkpoint -Feature $script:BareFeature -Entry $script:Entry | Should -Be $receipt
    }

    It 'returns null when no model-routing receipt exists' {
        Find-CodexChildModelReceipt -Checkpoint ([pscustomobject]@{}) -Feature $script:BareFeature -Entry $script:Entry | Should -BeNullOrEmpty
    }
}

Describe 'Test-CodexChildLaunchSpec' {
    It 'accepts a feature that records its wave in the legacy wave field' {
        $feature = Get-ContractTestFeature -Name contract-a -Issue 201 -Worktree $script:WorktreeA -LegacyWave
        $entry = Get-ContractTestEntry -Feature $feature
        Test-CodexChildLaunchSpec -Spec (Get-ContractTestSpec -Launches @($entry)) -Checkpoint (Get-ContractTestCheckpoint -Features @($feature)) `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches | Should -BeNullOrEmpty
    }

    It 'reports a launch with no matching checkpoint feature' {
        $feature = Get-ContractTestFeature -Name contract-a -Issue 201 -Worktree $script:WorktreeA
        $entry = Get-ContractTestEntry -Feature $feature
        $entry.issue_num = 999
        Test-CodexChildLaunchSpec -Spec (Get-ContractTestSpec -Launches @($entry)) -Checkpoint (Get-ContractTestCheckpoint -Features @($feature)) `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "launch 'launch-contract-a' has no exact checkpoint feature match."
    }

    It 'reports a planner prompt without the preparation marker' {
        $feature = Get-ContractTestFeature -Name contract-a -Issue 201 -Worktree $script:WorktreeA
        $feature.model_routing_receipt.execution_context = 'epic_preparation_child'
        $entry = Get-ContractTestEntry -Feature $feature -Context 'epic_preparation_child' -Prompt 'Prepare the feature.'
        Test-CodexChildLaunchSpec -Spec (Get-ContractTestSpec -Launches @($entry) -Kind 'epic-planner' -Wave 0) -Checkpoint (Get-ContractTestCheckpoint -Features @($feature)) `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "launch 'launch-contract-a' planner prompt is missing 'Preparation mode: true'."
    }

    It 'reports an empty launch list' {
        $errors = Test-CodexChildLaunchSpec -Spec (Get-ContractTestSpec -Launches @()) -Checkpoint (Get-ContractTestCheckpoint -Features @()) `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches
        $errors | Should -Contain 'launches must contain at least one child.'
    }
}
