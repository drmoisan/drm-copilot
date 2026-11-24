#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Batch-3 coverage for the remaining dot-source-reachable lines of
    .codex/hooks/enforce-completion-consistency.ps1 (issue #415 remediation cycle 1,
    R1, plan task [P4-T1]).

    Scope is exactly the residual itemized at [P3-T3] section (iii):
      - the pr_gate evidence block of Get-MissingCompletionEvidence, reached through
        an injected RoutingMatrixReader whose selected route sets requires_pr_gate;
      - the invalid-checkpoint-JSON deny branch of Invoke-CompletionConsistencyDecision;
      - the all-evidence-present allow branch of Invoke-CompletionConsistencyDecision.

    The hook is dot-sourced in-process. Every external dependency is supplied through
    the hook's existing injectable seams (FolderExistsCheck, RoutingMatrixReader,
    CheckpointReader), so no temporary file is created and no repository state is read
    or mutated.
#>

Describe 'enforce-completion-consistency route-driven pr_gate evidence' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-completion-consistency.ps1'
        $script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'

        . $script:HookPath
        Mock Get-CheckpointFileContent { $null }

        # A routing matrix whose single route opts into PR-gate evidence, and one
        # that does not. Both are supplied through the hook's RoutingMatrixReader
        # seam so no configuration file is read.
        $script:PrGateRoute = { '{"routes":{"full-bug":{"requires_pr_gate":true}}}' | ConvertFrom-Json }
        $script:NoPrGateRoute = { '{"routes":{"full-bug":{"requires_pr_gate":false}}}' | ConvertFrom-Json }
        $script:FolderPresent = { param($p) if ($p) { $true } }

        function ConvertTo-CompletionPayload {
            <#
                Builds a completion-asserting checkpoint payload object. Callers pass
                only the parts a case varies.
            #>
            param([Parameter(Mandatory)][hashtable] $Overrides)

            $base = [ordered]@{
                next_step        = 'complete'
                route_id         = 'full-bug'
                'issue-num'      = '415'
                'feature-folder' = '.dev/active/sample'
                ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = 'abc123' }
            }
            foreach ($key in $Overrides.Keys) {
                $base[$key] = $Overrides[$key]
            }
            return ($base | ConvertTo-Json -Compress -Depth 10 | ConvertFrom-Json)
        }
    }

    Context 'Get-MissingCompletionEvidence with a route that requires a PR gate' {
        It 'reports the whole pr_gate object as missing when the checkpoint has none' {
            $payload = ConvertTo-CompletionPayload -Overrides @{}

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute)

            $missing | Should -Contain 'pr_gate (object with pr_number, pr_url, head_branch, and head_sha)'
        }

        It 'names each absent pr_gate field individually' {
            $payload = ConvertTo-CompletionPayload -Overrides @{
                pr_gate = [ordered]@{ pr_number = '42' }
            }

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute)

            $missing | Should -Not -Contain 'pr_gate.pr_number'
            $missing | Should -Contain 'pr_gate.pr_url'
            $missing | Should -Contain 'pr_gate.head_branch'
            $missing | Should -Contain 'pr_gate.head_sha'
        }

        It 'requires the pr_gate head_sha to match the ci_gate head_sha' {
            $payload = ConvertTo-CompletionPayload -Overrides @{
                pr_gate = [ordered]@{
                    pr_number   = '42'
                    pr_url      = 'https://example.invalid/pr/42'
                    head_branch = 'bug/sample'
                    head_sha    = 'def456'
                }
            }

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute)

            $missing | Should -Contain 'ci_gate.head_sha matching pr_gate.head_sha'
        }

        It 'reports no missing evidence when the pr_gate is complete and agrees with the ci_gate' {
            $payload = ConvertTo-CompletionPayload -Overrides @{
                pr_gate = [ordered]@{
                    pr_number   = '42'
                    pr_url      = 'https://example.invalid/pr/42'
                    head_branch = 'bug/sample'
                    head_sha    = 'abc123'
                }
            }

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute)

            $missing.Count | Should -Be 0
        }

        It 'reports the whole ci_gate object as missing when the checkpoint has none' {
            $payload = '{"next_step":"complete","route_id":"full-bug","issue-num":"415","feature-folder":".dev/active/sample"}' |
                ConvertFrom-Json

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:NoPrGateRoute)

            $missing | Should -Contain 'ci_gate (object with conclusion == "success" and non-empty head_sha)'
        }

        It 'does not require pr_gate evidence when the route opts out' {
            $payload = ConvertTo-CompletionPayload -Overrides @{}

            $missing = @(Get-MissingCompletionEvidence -Payload $payload -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:NoPrGateRoute)

            $missing.Count | Should -Be 0
        }
    }

    Context 'Invoke-CompletionConsistencyDecision terminal branches' {
        It 'denies a governed checkpoint write whose content is not valid JSON' {
            $raw = @{ file_path = $script:CheckpointPath; content = 'not valid json' } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'must remain valid JSON'
        }

        It 'allows a completion-asserting checkpoint that carries every required piece of evidence' {
            $content = @{
                next_step        = 'complete'
                route_id         = 'full-bug'
                'issue-num'      = '415'
                'feature-folder' = '.dev/active/sample'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            } | ConvertTo-Json -Compress -Depth 10
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:NoPrGateRoute

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a completion-asserting checkpoint whose pr_gate evidence is incomplete' {
            $content = @{
                next_step        = 'complete'
                route_id         = 'full-bug'
                'issue-num'      = '415'
                'feature-folder' = '.dev/active/sample'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            } | ConvertTo-Json -Compress -Depth 10
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate'
        }
    }

    Context 'child CI opt-out (issue #1233)' {
        BeforeAll {
            $script:PreChangeReason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: ci_gate (object with conclusion == `"success`" and non-empty head_sha). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."

            function ConvertTo-OptOutContent {
                <#
                    Builds the JSON content of an opted-out completion checkpoint; Gate replaces
                    local_qc_gate and RemoveGate drops it.
                #>
                param([hashtable] $Gate, [switch] $RemoveGate)

                $base = [ordered]@{
                    next_step        = 'complete'
                    route_id         = 'full-bug'
                    'issue-num'      = '1233'
                    'feature-folder' = '.dev/active/sample'
                    epic_mode        = $true
                    child_ci         = 'integration_only'
                    pr_gate          = [ordered]@{ pr_number = 42; pr_url = 'https://github.com/o/r/pull/42'; head_branch = 'feature/x'; head_sha = 'ffffffffffffffffffffffffffffffffffffffff' }
                    local_qc_gate    = [ordered]@{ conclusion = 'success'; head_sha = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'; evidence_path = '.dev/active/sample/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md'; verified_at = '2026-11-24T05:00:00Z' }
                }
                if ($Gate) { $base['local_qc_gate'] = $Gate }
                if ($RemoveGate) { $base.Remove('local_qc_gate') }
                return ($base | ConvertTo-Json -Compress -Depth 10)
            }
        }

        It 'allows DONE with a valid local_qc_gate, no ci_gate, and a pr_gate head that differs from the local head' {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent) } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
        }

        It 'denies DONE naming <Missing> for <Label>' -ForEach @(
            @{ Label = 'an absent local_qc_gate'; Gate = $null; Remove = $true; Missing = 'local_qc_gate (object with' }
            @{ Label = 'a failure conclusion'; Gate = @{ conclusion = 'failure'; head_sha = 'h'; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.conclusion == "success"' }
            @{ Label = 'an empty head_sha'; Gate = @{ conclusion = 'success'; head_sha = ''; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.head_sha' }
            @{ Label = 'an empty evidence_path'; Gate = @{ conclusion = 'success'; head_sha = 'h'; evidence_path = '' }; Remove = $false; Missing = 'local_qc_gate.evidence_path' }
        ) {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent -Gate $Gate -RemoveGate:$Remove) } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains($Missing) | Should -BeTrue -Because $reason
        }

        It 'names the local_qc_gate alternative in the opt-out deny reason' {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent -RemoveGate) } | ConvertTo-Json -Compress

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*local_qc_gate object with conclusion*in place of a ci_gate object*'
        }

        It 'keeps the pre-change deny reason byte-unchanged for a keyless checkpoint' {
            # Arrange
            $content = '{"next_step":"complete","route_id":"full-bug","issue-num":"1233","feature-folder":".dev/active/sample"}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:NoPrGateRoute).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeExactly $script:PreChangeReason
        }
    }
}
