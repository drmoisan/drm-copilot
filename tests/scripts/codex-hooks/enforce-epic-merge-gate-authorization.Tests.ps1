#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Standalone-merge authorization cases for the Codex epic merge gate (issue #670).
.DESCRIPTION
    Pins the Codex counterpart of the Claude standalone authorization branch. Checkpoint
    text arrives through the decision seam's parameters and an allow is asserted as $null,
    which is the Codex allow representation. The Codex hook has two checkpoint sources, so
    only the per-feature and epic placements are exercised here.

    Determinism rules for this suite:
      - Every case drives the pure decision seam Invoke-CodexEpicMergeDecision directly,
        with every checkpoint supplied as a literal parameter value.
      - Every case writes nothing to disk, starts no process, and reads no clock.
      - The spelling-parity case reads the two hook source files as text only.
#>

Describe 'Codex enforce-epic-merge-gate standalone authorization (issue #670)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        $script:ClaudeHelpers = Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-merge-gate-authorization.ps1'
        . $script:CodexHook

        $script:SessionId = 'session-670-a1b2'

        function Get-CodexRecordJson {
            <#
            .SYNOPSIS
                Build a checkpoint JSON text carrying one well-formed record for a PR.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][int] $PrNumber)

            return '{"standalone_merge_authorizations":[{"pr_number":' + $PrNumber +
            ',"pr_url":"https://github.com/drmoisan/drm-copilot/pull/' + $PrNumber +
            '","issue_num":670,"branch_name":"fix/epic-merge-gate-authorization-record-670"' +
            ',"authorized_by":"orchestrator","authorized_at":"2026-09-13T21:04:00Z"' +
            ',"session_id":"' + $script:SessionId + '"' +
            ',"basis":"Standalone fix for #670 unblocks the run; all required checks passed."}]}'
        }

        $script:Fixtures = @{
            'none'         = ''
            'record-691'   = (Get-CodexRecordJson -PrNumber 691)
            'record-777'   = (Get-CodexRecordJson -PrNumber 777)
            'blanket-true' = '{"standalone_merge_authorizations":true}'
            'child-ready'  = '{"epic_mode":true,"step9_status":"passed"}'
            'epic-ready'   = '{"epic_merge_pr":{"pr_number":688,"ci_gate":{"conclusion":"success"}}}'
        }

        function ConvertTo-CodexPayload {
            <#
            .SYNOPSIS
                Wrap a Bash command in a PreToolUse payload, with or without a session_id.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command, [Parameter(Mandatory)][string] $Session)

            $payload = [ordered]@{ tool_name = 'Bash'; tool_input = @{ command = $Command } }
            if ($Session -ne 'absent') {
                $payload['session_id'] = $Session
            }
            return ($payload | ConvertTo-Json -Depth 5 -Compress)
        }

        $script:CodexDenyText = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'
    }

    Context 'decision matrix' {
        It 'decides <Expected> for <Name>' -ForEach @(
            @{ Name = 'a valid 691 record in the child checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a valid 691 record in the epic checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'none'; Epic = 'record-691'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a record naming 777 only'; Command = 'gh pr merge 691 --merge'; Child = 'record-777'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH' }
            @{ Name = 'no authorization key on either checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'none'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_ABSENT' }
            @{ Name = 'a blanket boolean block value'; Command = 'gh pr merge 691 --merge'; Child = 'blanket-true'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC' }
            @{ Name = 'a session_id that differs from the payload'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Session = 'session-other-9z'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED' }
            @{ Name = 'a payload carrying no session_id'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Session = 'absent'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED' }
            @{ Name = 'the unchanged branch-1 child guard'; Command = 'gh pr merge --merge'; Child = 'child-ready'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'the unchanged branch-2 epic guard'; Command = 'gh pr merge 688 --merge'; Child = 'none'; Epic = 'epic-ready'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a squash merge of 691 with a valid 691 record'; Command = 'gh pr merge 691 --squash'; Child = 'record-691'; Epic = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
        ) {
            $payload = ConvertTo-CodexPayload -Command $Command -Session $Session
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $script:Fixtures[$Child] -EpicCheckpointRaw $script:Fixtures[$Epic]

            if ($Expected -eq 'allow') {
                $decision | Should -BeNullOrEmpty
            }
            else {
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
                $reason | Should -BeLike ('EPIC_MERGE_GATE_BLOCKED: ' + $Token + ': *')
                if ($Token -eq 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED') {
                    $reason | Should -Match "'session_id'"
                }
            }
        }
    }

    Context 'reason text and the throw channel' {
        It 'denies an explicit PR with no record using both the gate token and the absent code' {
            $payload = ConvertTo-CodexPayload -Command 'gh pr merge 691 --merge' -Session $script:SessionId
            $reason = [string](Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '').hookSpecificOutput.permissionDecisionReason

            $reason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
            $reason | Should -Match 'STANDALONE_MERGE_AUTHORIZATION_ABSENT'
        }

        It 'keeps the existing deny text for a bare merge even with a valid record present' {
            $payload = ConvertTo-CodexPayload -Command 'gh pr merge --merge' -Session $script:SessionId
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $script:Fixtures['record-691'] -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:CodexDenyText
        }

        It 'still raises through the throw channel for <Name>' -ForEach @(
            @{ Name = 'a whitespace-only payload'; Payload = '   '; Message = 'EPIC_MERGE_GATE_BLOCKED: PreToolUse input is empty.' }
            @{ Name = 'an unparseable payload'; Payload = '{not-json'; Message = 'EPIC_MERGE_GATE_BLOCKED: PreToolUse input is malformed JSON:*' }
        ) {
            { Invoke-CodexEpicMergeDecision -PayloadRaw $Payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' } |
                Should -Throw -ExpectedMessage $Message
        }
    }

    Context 'record shape counterparts' {
        BeforeAll {
            function ConvertTo-CodexShapedCheckpoint {
                <#
                .SYNOPSIS
                    Build checkpoint text holding one 691 record with a single field overridden.
                #>
                [CmdletBinding()]
                [OutputType([string])]
                param([Parameter(Mandatory)][string] $Field, [AllowEmptyString()][string] $Value)

                $record = (Get-CodexRecordJson -PrNumber 691 | ConvertFrom-Json).standalone_merge_authorizations[0]
                $record | Add-Member -NotePropertyName 'run_slug' -NotePropertyValue 'bugs-2026-09-11'
                $record.$Field = $Value
                return (@{ standalone_merge_authorizations = @($record) } | ConvertTo-Json -Depth 5 -Compress)
            }
        }

        It 'denies a non-PR-specific block when <Name>' -ForEach @(
            @{ Name = 'the array is empty'; Json = '{"standalone_merge_authorizations":[]}' }
            @{ Name = 'an entry is not an object'; Json = '{"standalone_merge_authorizations":[691]}' }
            @{ Name = 'an entry has no pr_number'; Json = '{"standalone_merge_authorizations":[{"issue_num":670}]}' }
            @{ Name = 'pr_number spells digits as a string'; Json = '{"standalone_merge_authorizations":[{"pr_number":"691"}]}' }
            @{ Name = 'pr_number is an array'; Json = '{"standalone_merge_authorizations":[{"pr_number":[691]}]}' }
        ) {
            $payload = ConvertTo-CodexPayload -Command 'gh pr merge 691 --merge' -Session $script:SessionId
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Json -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC: *'
        }

        It 'denies a malformed record naming <Field> when <Name>' -ForEach @(
            @{ Name = 'pr_url ends with a different pull number'; Field = 'pr_url'; Value = 'https://github.com/drmoisan/drm-copilot/pull/6910' }
            @{ Name = 'issue_num is a string'; Field = 'issue_num'; Value = '670' }
            @{ Name = 'branch_name is whitespace'; Field = 'branch_name'; Value = '   ' }
            @{ Name = 'authorized_by is empty'; Field = 'authorized_by'; Value = '' }
            @{ Name = 'authorized_at is unparseable'; Field = 'authorized_at'; Value = 'not-a-timestamp' }
            @{ Name = 'basis is shorter than twenty characters'; Field = 'basis'; Value = 'merge it, please' }
            @{ Name = 'run_slug is present but blank'; Field = 'run_slug'; Value = ' ' }
        ) {
            $payload = ConvertTo-CodexPayload -Command 'gh pr merge 691 --merge' -Session $script:SessionId
            $checkpoint = ConvertTo-CodexShapedCheckpoint -Field $Field -Value $Value
            $reason = [string](Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw $checkpoint).hookSpecificOutput.permissionDecisionReason

            $reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_MALFORMED: *'
            $reason | Should -Match ([regex]::Escape("'$Field'"))
        }

        It 'allows a record whose authorized_at is a parseable non-ISO date-time' {
            $payload = ConvertTo-CodexPayload -Command 'gh pr merge 691 --merge' -Session $script:SessionId
            $checkpoint = ConvertTo-CodexShapedCheckpoint -Field 'authorized_at' -Value 'September 13, 2026 21:04'

            Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $checkpoint -EpicCheckpointRaw '' | Should -BeNullOrEmpty
        }
    }

    Context 'reason-code spelling parity' {
        It 'spells the four reason codes identically in the Claude helpers file and the Codex hook' {
            $pattern = 'STANDALONE_MERGE_AUTHORIZATION_[A-Z_]+'
            $claudeCodes = @([regex]::Matches((Get-Content -Raw -LiteralPath $script:ClaudeHelpers), $pattern) | ForEach-Object Value | Sort-Object -Unique)
            $codexCodes = @([regex]::Matches((Get-Content -Raw -LiteralPath $script:CodexHook), $pattern) | ForEach-Object Value | Sort-Object -Unique)

            $claudeCodes.Count | Should -Be 4
            ($codexCodes -join ',') | Should -BeExactly ($claudeCodes -join ',')
        }
    }
}
