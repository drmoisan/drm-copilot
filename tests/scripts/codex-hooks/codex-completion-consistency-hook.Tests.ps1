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
                'feature-folder' = 'docs/features/active/sample'
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
            $payload = '{"next_step":"complete","route_id":"full-bug","issue-num":"415","feature-folder":"docs/features/active/sample"}' |
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
                'feature-folder' = 'docs/features/active/sample'
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
                'feature-folder' = 'docs/features/active/sample'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            } | ConvertTo-Json -Compress -Depth 10
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate'
        }
    }
}
