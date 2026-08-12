#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex child authoritative resume reconciliation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/codex-child-launch-contract-core.ps1')
        . (Join-Path $script:RepoRoot '.codex/scripts/codex-child-launch-resume.ps1')

        function Get-TestResumeReceipt {
            $prompt = 'Continue the sealed child session.'
            return [pscustomobject]@{
                launch_id = 'launch-a'; delegation_id = 'delegation-a'
                feature_folder = 'docs/features/active/child-a'; issue_num = 101
                deployment_agent = 'orchestrator-c3-elevated'; model = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'; permissions = 'orchestrator-workspace'
                execution_context = 'epic_execution_child'; worktree_path = 'C:\worktree-a'
                branch_name = 'feature/child-a'; prompt_sha256 = Get-CodexChildSha256 -Value $prompt
                codex_session_id = 'session-a'; receipt_path = 'C:\receipts\launch-a.json'
            }
        }

        function Get-TestResumeSpec {
            return [pscustomobject]@{
                launches = @([pscustomobject]@{
                        launch_id = 'launch-a'; delegation_id = 'delegation-a'
                        feature_folder = 'docs/features/active/child-a'; issue_num = 101
                        deployment_agent = 'orchestrator-c3-elevated'; model = 'gpt-5.6-sol'
                        model_reasoning_effort = 'high'; permissions = 'orchestrator-workspace'
                        execution_context = 'epic_execution_child'; worktree_path = 'C:\worktree-a'
                        branch_name = 'feature/child-a'; prompt = 'Continue the sealed child session.'
                    })
            }
        }

        function Get-TestResumeStatus {
            param(
                [string] $State = 'completed',
                [int] $ProcessId = 4200,
                [string] $ReceiptPath = 'C:\receipts\launch-a.json',
                [string] $SessionId = 'session-a'
            )
            $entry = [pscustomobject]@{
                state = $State; pid = $ProcessId
                receipt_path = $ReceiptPath; codex_session_id = $SessionId
            }
            return [pscustomobject]@{
                schema_version = 2
                launches       = [pscustomobject]@{ 'launch-a' = $entry }
            }
        }

        function Invoke-TestResumeReconciliation {
            param(
                [AllowNull()] $Status = (Get-TestResumeStatus),
                [scriptblock] $GetLiveProcess = { param([int] $ProcessId) $null = $ProcessId; return $null },
                $Receipt = (Get-TestResumeReceipt),
                $Spec = (Get-TestResumeSpec)
            )
            return @(Get-CodexChildResumeReconciliationCore `
                    -Receipt $Receipt `
                    -Spec $Spec `
                    -Status $Status `
                    -ReceiptPath ([string]$Receipt.receipt_path) `
                    -GetLiveProcess $GetLiveProcess)
        }
    }

    It 'allows relaunch only when the authoritative live process is absent' {
        $errors = Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -State running) `
            -GetLiveProcess { param([int] $ProcessId) $null = $ProcessId; return $null }

        $errors | Should -BeNullOrEmpty
    }

    It 'rejects a still-running live process regardless of cached terminal state' {
        $errors = Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -State completed) `
            -GetLiveProcess {
            param([int] $ProcessId)
            [pscustomobject]@{ Id = $ProcessId; HasExited = $false }
        }

        $errors | Should -Contain 'live child process is still running; relaunch is prohibited.'
    }

    It 'rejects missing, corrupt, and unbound child status evidence' {
        Invoke-TestResumeReconciliation -Status $null |
            Should -Contain 'child status data is missing or corrupt.'

        $wrongSchema = Get-TestResumeStatus
        $wrongSchema.schema_version = 1
        Invoke-TestResumeReconciliation -Status $wrongSchema |
            Should -Contain 'child status must use schema_version 2.'

        $missingLaunch = Get-TestResumeStatus
        $missingLaunch.launches = [pscustomobject]@{}
        Invoke-TestResumeReconciliation -Status $missingLaunch |
            Should -Contain 'child status lacks the launch receipt launch_id.'
    }

    It 'rejects mismatched child status paths, sessions, states, and process identifiers' {
        Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -ReceiptPath 'C:\receipts\other.json') |
            Should -Contain "child status entry property 'receipt_path' does not match the launch identity."
        Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -SessionId 'session-b') |
            Should -Contain "child status entry property 'codex_session_id' does not match the launch identity."
        Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -State queued) |
            Should -Contain 'child status entry state must be running, completed, or failed.'
        Invoke-TestResumeReconciliation `
            -Status (Get-TestResumeStatus -ProcessId 0) |
            Should -Contain 'child status entry pid must be a positive integer.'

        $errors = Invoke-TestResumeReconciliation -GetLiveProcess {
            param([int] $ProcessId)
            [pscustomobject]@{ Id = $ProcessId + 1; HasExited = $true }
        }
        $errors | Should -Contain 'live process identity differs from the child status pid.'
    }

    It 'rejects every sealed spec-to-receipt identity mismatch before relaunch' {
        foreach ($name in @(
                'delegation_id', 'feature_folder', 'deployment_agent', 'model',
                'model_reasoning_effort', 'permissions', 'execution_context',
                'worktree_path', 'branch_name'
            )) {
            $spec = Get-TestResumeSpec
            $spec.launches[0].$name = "mismatch-$name"
            Invoke-TestResumeReconciliation -Spec $spec |
                Should -Contain "sealed launch specification $name differs from the receipt."
        }

        $issueSpec = Get-TestResumeSpec
        $issueSpec.launches[0].issue_num = 202
        Invoke-TestResumeReconciliation -Spec $issueSpec |
            Should -Contain 'sealed launch specification issue_num differs from the receipt.'

        $promptSpec = Get-TestResumeSpec
        $promptSpec.launches[0].prompt = 'changed'
        Invoke-TestResumeReconciliation -Spec $promptSpec |
            Should -Contain 'sealed launch specification prompt hash differs from the receipt.'
    }

    It 'rejects the complete shared launch identity mismatch matrix' {
        $identity = [pscustomobject]@{
            spec_sha256 = ('a' * 64); checkpoint_sha256 = ('b' * 64)
            trusted_repository_root = 'C:\repo'; branch_name = 'feature/child-a'
            worktree_path = 'C:\worktree-a'; deployment_agent = 'orchestrator-c3-elevated'
            model = 'gpt-5.6-sol'; model_reasoning_effort = 'high'
            authority_receipt_path = 'authority.json'; delegation_receipt_path = 'delegation.json'
            topology_receipt_path = 'topology.json'; model_routing_receipt_path = 'model.json'
            permissions = 'orchestrator-workspace'; child_status_path = 'status.json'
        }

        foreach ($name in @($identity.PSObject.Properties.Name)) {
            $receipt = $identity.PSObject.Copy()
            $receipt.$name = "mismatch-$name"
            {
                Assert-CodexChildResumeLaunchIdentityCore `
                    -Expected $identity `
                    -Receipt $receipt
            } | Should -Throw "*property '$name' does not match*"

            $missing = $identity.PSObject.Copy()
            $missing.PSObject.Properties.Remove($name)
            {
                Assert-CodexChildResumeLaunchIdentityCore `
                    -Expected $identity `
                    -Receipt $missing
            } | Should -Throw "*missing required property '$name'*"

            $corrupt = $identity.PSObject.Copy()
            $corrupt.$name = 42
            {
                Assert-CodexChildResumeLaunchIdentityCore `
                    -Expected $identity `
                    -Receipt $corrupt
            } | Should -Throw "*property '$name' must be a non-empty string*"
        }
    }

    It 'preserves the epic resume public parameter contract and shared-core delegation' {
        $adapterPath = Join-Path $script:RepoRoot '.codex/scripts/resume-epic-child.ps1'
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $adapterPath,
            [ref]$tokens,
            [ref]$parseErrors
        )
        $adapter = Get-Content -Raw -LiteralPath $adapterPath

        $parseErrors | Should -BeNullOrEmpty
        ($ast.ParamBlock.Parameters.Name.VariablePath.UserPath -join ',') |
            Should -BeExactly 'ReceiptPath,Prompt,LastMessagePath'
        $adapter | Should -Match 'codex-child-launch-resume\.ps1'
        $adapter | Should -Match 'Get-CodexChildResumeReconciliationCore'
        $adapter | Should -Not -Match 'function Test-CodexChildResumeSpecEntry'
    }
}
