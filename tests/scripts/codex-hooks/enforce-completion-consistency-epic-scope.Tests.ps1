#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pins the Codex completion-consistency gate (gate 5) behaviour for the epic checkpoint (issue #707).

.DESCRIPTION
    Under spec decision D12 the Codex gate 5 in .codex/hooks/enforce-completion-consistency.ps1
    already governs only the per-feature checkpoint artifacts/orchestration/orchestrator-state.json.
    These rows pin that behaviour: a completion-asserting write, edit, or apply_patch Add of
    artifacts/orchestration/epic-orchestrator-state.json is not intercepted, an apply_patch Update
    of the epic checkpoint maps to no record, and the per-feature checkpoint is still intercepted.

    The hook is dot-sourced in-process. Every decision call supplies the injectable seams
    FolderExistsCheck, RoutingMatrixReader, and CheckpointReader, so no row reads repository
    state, creates a file, or changes the working directory. No row asserts the path passed to
    a reader, so the suite does not depend on how gate 5 resolves its checkpoint path.
#>

Describe 'Codex completion-consistency gate epic checkpoint (issue #707)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-completion-consistency.ps1')
        Mock Get-CheckpointFileContent { $null }

        $script:EpicCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.json'
        $script:FeatureCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
        $script:CompletionText = '{"next_step":"complete","completed_steps":["S12_complete"]}'
        # The seams ignore their argument by design; the discard keeps the analyzer quiet.
        $script:FolderPresent = { param($p) $null = $p; $true }
        $script:NoRoutingMatrix = { $null }
        $script:FixedCheckpointReader = { param($Path) $null = $Path; '{"next_step":"complete","completed_steps":["S12_complete"]}' }

        function Invoke-EpicScopeCompletionDecision {
            <#
                Converts a tool_input record to the mapped JSON the decision consumes and
                returns the decision with every injectable seam supplied.
            #>
            param([Parameter(Mandatory)] $ToolInput)

            $decisionArgs = @{
                ToolInputRaw        = ($ToolInput | ConvertTo-Json -Compress -Depth 20)
                FolderExistsCheck   = $script:FolderPresent
                RoutingMatrixReader = $script:NoRoutingMatrix
                CheckpointReader    = $script:FixedCheckpointReader
            }
            return Invoke-CompletionConsistencyDecision @decisionArgs
        }

        function ConvertTo-EpicScopePatchPayload {
            <#
                Builds a parsed Codex apply_patch payload with a single file operation.
            #>
            param(
                [Parameter(Mandatory)][string] $Operation,
                [Parameter(Mandatory)][string] $Path,
                [Parameter(Mandatory)][string[]] $BodyLines
            )

            $lines = @('*** Begin Patch', "*** $Operation File: $Path") + $BodyLines + @('*** End Patch')
            return [pscustomobject]@{
                tool_name  = 'apply_patch'
                tool_input = [pscustomobject]@{ command = ($lines -join "`n") }
            }
        }

        function ConvertTo-EpicScopeMappedRecord {
            <#
                Maps a patch payload the way gate 5 does at its entry point.
            #>
            param([Parameter(Mandatory)] $Payload)

            return @(ConvertTo-CodexFileEditInput -Payload $Payload -ResolveUpdateContent -GovernedPath 'artifacts/orchestration/orchestrator-state.json')
        }
    }

    Context 'epic checkpoint writes are not intercepted' {
        It 'does not intercept a completion-asserting Write to the epic checkpoint' {
            $toolInput = [ordered]@{ file_path = $script:EpicCheckpointPath; content = $script:CompletionText }

            $decision = Invoke-EpicScopeCompletionDecision -ToolInput $toolInput

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'does not intercept a completion-asserting Edit to the epic checkpoint' {
            $toolInput = [ordered]@{
                file_path  = $script:EpicCheckpointPath
                old_string = '"next_step":"S11_pr_merge"'
                new_string = '"next_step":"complete"'
            }

            $decision = Invoke-EpicScopeCompletionDecision -ToolInput $toolInput

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'does not intercept an apply_patch Add of the epic checkpoint' {
            $payload = ConvertTo-EpicScopePatchPayload -Operation 'Add' -Path $script:EpicCheckpointPath -BodyLines @("+$script:CompletionText")

            $records = ConvertTo-EpicScopeMappedRecord -Payload $payload

            $records.Count | Should -Be 1 -Because 'an apply_patch Add maps to exactly one record'
            $decision = Invoke-EpicScopeCompletionDecision -ToolInput $records[0]
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'emits no mapped record for an apply_patch Update of the epic checkpoint' {
            $payload = ConvertTo-EpicScopePatchPayload -Operation 'Update' -Path $script:EpicCheckpointPath -BodyLines @('@@', '-"next_step":"S11_pr_merge"', '+"next_step":"complete"')

            $records = ConvertTo-EpicScopeMappedRecord -Payload $payload

            $records.Count | Should -Be 0 -Because 'an Update outside the governed per-feature path is not reconstructed'
        }
    }

    Context 'per-feature checkpoint writes are still intercepted' {
        It 'still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/' {
            $content = [ordered]@{
                next_step        = 'complete'
                completed_steps  = @('S12_complete')
                'issue-num'      = '707'
                'feature-folder' = 'docs/features/epics/sample-epic'
                ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = 'abc123' }
            } | ConvertTo-Json -Compress -Depth 10
            $toolInput = [ordered]@{ file_path = $script:FeatureCheckpointPath; content = $content }

            $decision = Invoke-EpicScopeCompletionDecision -ToolInput $toolInput

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*feature-folder value 'docs/features/epics/sample-epic'*"
        }

        It 'still denies a completion-asserting per-feature checkpoint that lacks ci_gate' {
            $content = [ordered]@{
                next_step        = 'complete'
                completed_steps  = @('S12_complete')
                'issue-num'      = '707'
                'feature-folder' = 'docs/features/active/sample'
            } | ConvertTo-Json -Compress -Depth 10
            $toolInput = [ordered]@{ file_path = $script:FeatureCheckpointPath; content = $content }

            $decision = Invoke-EpicScopeCompletionDecision -ToolInput $toolInput

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*ci_gate (object*'
        }
    }
}
