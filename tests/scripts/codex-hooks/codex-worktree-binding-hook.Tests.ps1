#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Coverage-closure unit tests for .codex/hooks/enforce-epic-child-worktree-binding.ps1.

.DESCRIPTION
    Issue #415 remediation cycle 2 added this hook to CodeCoverage.Path (R-COV), which
    exposed uncovered decision branches above the dot-source guard. These tests target
    exactly the exercisable missed lines catalogued in
    FEATURE/evidence/qa-gates/per-file-coverage.2026-07-26T15-17.md.

    All cases dot-source the hook and exercise its functions directly. No temporary file
    is created, no worktree is created, and no live executable is invoked.
#>

Describe 'enforce-epic-child-worktree-binding.ps1 guard functions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-child-worktree-binding.ps1'

        . $script:HookPath

        $script:SpecPath = Join-Path $script:RepoRoot 'artifacts/orchestration/launch-spec.json'
        $script:ReceiptPath = Join-Path $script:RepoRoot 'artifacts/orchestration/launch-receipt.json'
        $script:SpecHash = ('b' * 64)
        $script:ProfileHash = ('a' * 64)

        function Get-BindingReceiptFixture {
            <# Returns a launch receipt that validates cleanly, so each test can perturb one field. #>
            return [pscustomobject]@{
                schema_version          = 2
                state                   = 'active'
                codex_session_id        = '019f-session-id'
                session_bound_at        = '2026-07-10T12:00:00Z'
                expires_at              = '2999-07-10T12:00:00Z'
                launch_id               = 'wave-1-child-a'
                delegation_id           = 'delegate-child-a'
                feature_folder          = 'child-a'
                deployment_agent        = 'orchestrator-c3-elevated'
                model                   = 'gpt-5.6-sol'
                model_reasoning_effort  = 'high'
                execution_context       = 'epic_execution_child'
                worktree_path           = $script:RepoRoot
                branch_name             = 'feature/child-a'
                profile_sha256          = $script:ProfileHash
                profile_path            = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
                receipt_path            = $script:ReceiptPath
                status_path             = Join-Path $script:RepoRoot 'artifacts/orchestration/status.json'
                spec_path               = $script:SpecPath
                spec_sha256             = $script:SpecHash
                codex_home_path         = 'C:\isolated'
                checkpoint_kind         = 'epic-orchestrator'
                wave_lock_path          = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/.locks/wave.lock'
                trusted_repository_root = $script:RepoRoot
            }
        }

        function Get-BindingAttestationFixture {
            <# Returns an environment attestation that matches Get-BindingReceiptFixture exactly. #>
            return [pscustomobject]@{
                launch_id         = 'wave-1-child-a'
                delegation_id     = 'delegate-child-a'
                execution_context = 'epic_execution_child'
                agent             = 'orchestrator-c3-elevated'
                model             = 'gpt-5.6-sol'
                reasoning_effort  = 'high'
                expected_worktree = $script:RepoRoot
                profile_sha256    = $script:ProfileHash
                receipt_path      = $script:ReceiptPath
                spec_path         = $script:SpecPath
            }
        }

        function Get-BindingPayloadFixture {
            <# Builds a PSCustomObject payload; PSObject property presence is load-bearing. #>
            param([Parameter(Mandatory)][hashtable] $Properties)

            $defaults = [ordered]@{
                cwd        = $script:RepoRoot
                session_id = '019f-session-id'
                tool_name  = 'apply_patch'
                tool_input = @{ command = '*** Update File: src/service.py' }
            }
            foreach ($key in $Properties.Keys) { $defaults[$key] = $Properties[$key] }
            return [pscustomobject]$defaults
        }

        function Invoke-BindingAttestationCheck {
            <# Calls the attestation checker with a matching baseline plus per-test overrides. #>
            param(
                $Payload = (Get-BindingPayloadFixture -Properties @{}),
                $Receipt = (Get-BindingReceiptFixture),
                $Attestation = (Get-BindingAttestationFixture),
                [string] $LiveBranch = 'feature/child-a',
                [string] $ActualSpecSha256 = ('b' * 64),
                [string] $ActualProfileSha256 = ('a' * 64)
            )

            return @(Test-CodexChildGuardAttestation -Payload $Payload -Receipt $Receipt `
                    -Attestation $Attestation -HookRepositoryRoot $script:RepoRoot `
                    -LiveBranch $LiveBranch -ActualSpecSha256 $ActualSpecSha256 `
                    -ActualProfileSha256 $ActualProfileSha256)
        }
    }

    Context 'ConvertFrom-CodexChildGuardJson' {
        It 'throws a blocked message when the raw payload is whitespace only' {
            # Arrange / Act / Assert
            { ConvertFrom-CodexChildGuardJson -Raw '   ' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage '*PreToolUse input is empty.*'
        }

        It 'throws a blocked message when the raw payload is malformed JSON' {
            # Arrange / Act / Assert
            { ConvertFrom-CodexChildGuardJson -Raw '{ "unterminated": ' -Name 'launch receipt' } |
                Should -Throw -ExpectedMessage '*launch receipt is malformed JSON*'
        }
    }

    Context 'Get-CodexChildGuardCanonicalPath' {
        It 'resolves a relative path against the supplied base path' {
            # Arrange
            $base = $script:RepoRoot

            # Act
            $result = Get-CodexChildGuardCanonicalPath -Path 'artifacts/orchestration' -BasePath $base

            # Assert
            $result | Should -Be ([System.IO.Path]::GetFullPath((Join-Path $base 'artifacts/orchestration')))
        }
    }

    Context 'Test-CodexChildGuardMutation' {
        It 'classifies a shell tool as a mutation' -ForEach @(
            @{ ToolName = 'Bash' }
            @{ ToolName = 'shell_command' }
        ) {
            # Arrange
            $payload = Get-BindingPayloadFixture -Properties @{ tool_name = $ToolName }

            # Act / Assert
            Test-CodexChildGuardMutation -Payload $payload | Should -BeTrue
        }

        It 'classifies an unlisted read-only tool as a non-mutation' {
            # Arrange
            $payload = Get-BindingPayloadFixture -Properties @{ tool_name = 'Read' }

            # Act / Assert
            Test-CodexChildGuardMutation -Payload $payload | Should -BeFalse
        }
    }

    Context 'Test-CodexChildGuardProtectedPathMutation' {
        It 'short-circuits to false when the tool is not a mutation' {
            # Arrange: a read-only tool must not be path-inspected at all.
            $payload = Get-BindingPayloadFixture -Properties @{
                tool_name  = 'Read'
                tool_input = @{ file_path = Join-Path $script:RepoRoot '.codex/config.toml' }
            }

            # Act
            $result = Test-CodexChildGuardProtectedPathMutation -Payload $payload `
                -ReceiptPath $script:ReceiptPath -SpecPath $script:SpecPath `
                -ProfilePath (Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml') `
                -WorktreePath $script:RepoRoot

            # Assert
            $result | Should -BeFalse
        }
    }

    Context 'Test-CodexChildGuardAttestation' {
        It 'reports no error when the receipt, attestation, and hashes all match' {
            # Arrange / Act
            $errors = Invoke-BindingAttestationCheck

            # Assert: establishes the clean baseline the perturbation cases depend on.
            $errors.Count | Should -Be 0
        }

        It 'propagates every error the launch-receipt validator returns' {
            # Arrange: an inactive receipt makes the validator emit a schema/state error.
            $receipt = Get-BindingReceiptFixture
            $receipt.state = 'expired'

            # Act
            $errors = Invoke-BindingAttestationCheck -Receipt $receipt

            # Assert
            $errors | Should -Contain 'launch receipt must use schema_version 2 and state active.'
        }

        It 'reports the validator as unavailable when it cannot be resolved' {
            # Arrange: simulate a checkout where the launch-contract sibling is absent.
            Mock -CommandName Get-Command -MockWith { $null } -ParameterFilter {
                $Name -eq 'Get-CodexChildActiveReceiptErrorList'
            }

            # Act
            $errors = Invoke-BindingAttestationCheck

            # Assert
            $errors | Should -Contain 'launch receipt validator is unavailable.'
        }

        It 'reports a changed deployment profile hash' {
            # Arrange / Act
            $errors = Invoke-BindingAttestationCheck -ActualProfileSha256 ('c' * 64)

            # Assert
            $errors | Should -Contain 'the checked-in deployment profile path or hash has changed.'
        }

        It 'reports a payload model that disagrees with the launch receipt' {
            # Arrange
            $payload = Get-BindingPayloadFixture -Properties @{ model = 'gpt-5.6-mini' }

            # Act
            $errors = Invoke-BindingAttestationCheck -Payload $payload

            # Assert
            $errors | Should -Contain 'the hook payload model does not match the launch receipt.'
        }

        It 'reports a payload agent type that disagrees with the launch receipt' {
            # Arrange
            $payload = Get-BindingPayloadFixture -Properties @{ agent_type = 'orchestrator-c3' }

            # Act
            $errors = Invoke-BindingAttestationCheck -Payload $payload

            # Assert
            $errors | Should -Contain 'the hook payload agent type does not match the launch receipt.'
        }

        It 'reads the reasoning effort from model_reasoning_effort when that property is present' {
            # Arrange: the preferred property name, set to a mismatching value.
            $payload = Get-BindingPayloadFixture -Properties @{ model_reasoning_effort = 'low' }

            # Act
            $errors = Invoke-BindingAttestationCheck -Payload $payload

            # Assert
            $errors | Should -Contain 'the hook payload reasoning effort does not match the launch receipt.'
        }

        It 'falls back to reasoning_effort when model_reasoning_effort is absent' {
            # Arrange: only the fallback property name is present, set to a mismatching value.
            $payload = Get-BindingPayloadFixture -Properties @{ reasoning_effort = 'minimal' }

            # Act
            $errors = Invoke-BindingAttestationCheck -Payload $payload

            # Assert
            $errors | Should -Contain 'the hook payload reasoning effort does not match the launch receipt.'
        }

        It 'accepts a matching reasoning effort supplied under either property name' -ForEach @(
            @{ PropertyName = 'model_reasoning_effort' }
            @{ PropertyName = 'reasoning_effort' }
        ) {
            # Arrange
            $payload = Get-BindingPayloadFixture -Properties @{ $PropertyName = 'high' }

            # Act
            $errors = Invoke-BindingAttestationCheck -Payload $payload

            # Assert
            $errors | Should -Not -Contain 'the hook payload reasoning effort does not match the launch receipt.'
        }
    }

    Context 'Invoke-CodexEpicChildGuardDecision' {
        BeforeAll {
            $script:ReceiptRaw = (Get-BindingReceiptFixture) | ConvertTo-Json -Compress
            $script:Attestation = Get-BindingAttestationFixture
        }

        It 'allows a tool that is neither an MCP call nor a mutation' {
            # Arrange: a read-only tool under an active attestation is out of the guard's remit.
            $payloadRaw = (Get-BindingPayloadFixture -Properties @{
                    tool_name  = 'Read'
                    tool_input = @{ file_path = 'README.md' }
                }) | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw `
                -ReceiptRaw $script:ReceiptRaw -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 $script:ProfileHash

            # Assert
            $decision | Should -BeNullOrEmpty
        }

        It 'denies a mutation when the launcher authorization receipt is missing' {
            # Arrange
            $payloadRaw = (Get-BindingPayloadFixture -Properties @{}) | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw `
                -ReceiptRaw '' -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 $script:ProfileHash

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'the launcher authorization receipt is missing'
        }

        It 'denies an MCP tool outside the repository-scoped drm-copilot surface' {
            # Arrange
            $payloadRaw = (Get-BindingPayloadFixture -Properties @{
                    tool_name  = 'mcp__other-server__do_thing'
                    tool_input = @{ workspace_root = $script:RepoRoot }
                }) | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw `
                -ReceiptRaw $script:ReceiptRaw -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 $script:ProfileHash

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'only repository-scoped drm-copilot MCP tools are authorized'
        }

        It 'denies a nested Codex invocation from inside an epic child' {
            # Arrange
            $payloadRaw = (Get-BindingPayloadFixture -Properties @{
                    tool_name  = 'Bash'
                    tool_input = @{ command = 'codex exec --profile orchestrator' }
                }) | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw `
                -ReceiptRaw $script:ReceiptRaw -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 $script:ProfileHash

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'nested Codex execution is prohibited'
        }
    }
}
