#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Predicate-level tests for .claude/hooks/enforce-epic-merge-gate-authorization.ps1
    (issue #670).
.DESCRIPTION
    Drives the standalone-merge authorization predicates directly against checkpoint
    literals parsed with ConvertFrom-Json: the record-selection function, the field-shape
    validator, and the checkpoint-level predicate that composes them.

    Determinism rules for this suite:
      - Every case drives a pure predicate directly; no decision envelope is built.
      - No checkpoint read seam is reached, because every checkpoint is a parsed literal,
        so every checkpoint read seam is effectively mocked by construction.
      - Every case writes nothing to disk, starts no process, and reads no clock.
#>

Describe 'enforce-epic-merge-gate-authorization.ps1 predicates (issue #670)' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate-authorization.ps1").Path

        $script:SessionId = 'session-670-a1b2'

        function New-ValidRecord {
            <#
            .SYNOPSIS
                Return an ordered dictionary holding a well-formed record for PR 691.
            #>
            [CmdletBinding()]
            [OutputType([System.Collections.Specialized.OrderedDictionary])]
            param()

            return [ordered]@{
                pr_number     = 691
                pr_url        = 'https://github.com/drmoisan/drm-copilot/pull/691'
                issue_num     = 670
                branch_name   = 'fix/epic-merge-gate-authorization-record-670'
                authorized_by = 'parallel-orchestrator'
                authorized_at = '2026-09-13T21:04:00Z'
                session_id    = 'session-670-a1b2'
                basis         = 'Standalone fix for #670 unblocks the run; all required checks passed.'
                run_slug      = 'bugs-2026-09-11'
            }
        }

        function ConvertTo-ParsedJson {
            <#
            .SYNOPSIS
                Round-trip a value through JSON so it has the shape ConvertFrom-Json produces.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)] $Value)

            return ($Value | ConvertTo-Json -Depth 5 -Compress | ConvertFrom-Json)
        }
    }

    Context 'blocks that are not PR specific' {
        It 'rejects <Name> as not PR specific' -ForEach @(
            @{ Name = 'block value true'; Json = '{"standalone_merge_authorizations":true}' }
            @{ Name = 'block value a string'; Json = '{"standalone_merge_authorizations":"all"}' }
            @{ Name = 'block value an object'; Json = '{"standalone_merge_authorizations":{"pr_number":691}}' }
            @{ Name = 'empty array'; Json = '{"standalone_merge_authorizations":[]}' }
            @{ Name = 'entry not an object'; Json = '{"standalone_merge_authorizations":[691]}' }
            @{ Name = 'pr_number absent'; Json = '{"standalone_merge_authorizations":[{"issue_num":670}]}' }
            @{ Name = 'pr_number null'; Json = '{"standalone_merge_authorizations":[{"pr_number":null}]}' }
            @{ Name = 'pr_number zero'; Json = '{"standalone_merge_authorizations":[{"pr_number":0}]}' }
            @{ Name = 'pr_number negative'; Json = '{"standalone_merge_authorizations":[{"pr_number":-691}]}' }
            @{ Name = 'pr_number a non-integer number'; Json = '{"standalone_merge_authorizations":[{"pr_number":691.5}]}' }
            @{ Name = 'pr_number a digit-spelling string'; Json = '{"standalone_merge_authorizations":[{"pr_number":"691"}]}' }
            @{ Name = 'pr_number the wildcard string'; Json = '{"standalone_merge_authorizations":[{"pr_number":"*"}]}' }
            @{ Name = 'pr_number an array'; Json = '{"standalone_merge_authorizations":[{"pr_number":[691]}]}' }
        ) {
            $checkpoint = $Json | ConvertFrom-Json
            $verdict = Test-StandaloneCheckpointAllowsMerge -Checkpoints @($checkpoint, $null, $null) -CommandPrNumber 691 -EnvelopeSessionId $script:SessionId

            $verdict.Allowed | Should -BeFalse
            $verdict.ReasonCode | Should -BeExactly 'STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC'
        }
    }

    Context 'field shape failures on the matched record' {
        It 'names <Field> when <Name>' -ForEach @(
            @{ Name = 'pr_url ends with a different pull number'; Field = 'pr_url'; Value = 'https://github.com/drmoisan/drm-copilot/pull/6910' }
            @{ Name = 'issue_num is a string'; Field = 'issue_num'; Value = '670' }
            @{ Name = 'branch_name is whitespace'; Field = 'branch_name'; Value = '   ' }
            @{ Name = 'authorized_by is empty'; Field = 'authorized_by'; Value = '' }
            @{ Name = 'authorized_at is unparseable'; Field = 'authorized_at'; Value = 'not-a-timestamp' }
            @{ Name = 'basis is empty'; Field = 'basis'; Value = '' }
            @{ Name = 'basis is shorter than twenty characters'; Field = 'basis'; Value = 'merge it, please' }
            @{ Name = 'run_slug is present but empty'; Field = 'run_slug'; Value = ' ' }
        ) {
            $record = New-ValidRecord
            $record[$Field] = $Value
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $script:SessionId

            $failure.ReasonCode | Should -BeExactly 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED'
            $failure.Message | Should -Match ([regex]::Escape("'$Field'"))
        }

        It 'names pr_url first when both pr_url and basis fail' {
            $record = New-ValidRecord
            $record['pr_url'] = 'https://github.com/drmoisan/drm-copilot/pull/777'
            $record['basis'] = 'short'
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $script:SessionId

            $failure.ReasonCode | Should -BeExactly 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED'
            $failure.Message | Should -Match "'pr_url'"
            $failure.Message | Should -Not -Match "'basis'"
        }
    }

    Context 'valid records and session binding' {
        It 'accepts a well-formed record whose session matches' {
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value (New-ValidRecord)) -EnvelopeSessionId $script:SessionId
            $failure | Should -BeNullOrEmpty
        }

        It 'accepts a well-formed record that omits the optional run_slug' {
            $record = New-ValidRecord
            $record.Remove('run_slug')
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $script:SessionId
            $failure | Should -BeNullOrEmpty
        }

        It 'accepts an authorized_at value that is not an ISO date-time but still parses' {
            $record = New-ValidRecord
            $record['authorized_at'] = 'September 13, 2026 21:04'
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $script:SessionId
            $failure | Should -BeNullOrEmpty
        }

        It 'rejects a non-string authorized_at value' {
            $record = New-ValidRecord
            $record['authorized_at'] = 20260913
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $script:SessionId
            $failure.Message | Should -Match "'authorized_at'"
        }

        It 'names session_id when <Name>' -ForEach @(
            @{ Name = 'the envelope session differs'; Envelope = 'session-other-9z'; RecordSession = 'session-670-a1b2' }
            @{ Name = 'the envelope carries no session'; Envelope = ''; RecordSession = 'session-670-a1b2' }
            @{ Name = 'the record session is blank'; Envelope = 'session-670-a1b2'; RecordSession = '  ' }
            @{ Name = 'the sessions differ only by case'; Envelope = 'SESSION-670-A1B2'; RecordSession = 'session-670-a1b2' }
        ) {
            $record = New-ValidRecord
            $record['session_id'] = $RecordSession
            $failure = Test-StandaloneMergeAuthorizationRecord -Record (ConvertTo-ParsedJson -Value $record) -EnvelopeSessionId $Envelope

            $failure.ReasonCode | Should -BeExactly 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED'
            $failure.Message | Should -Match "'session_id'"
        }

        It 'selects the entry for the requested PR and returns nothing for another PR' {
            $checkpoint = '{"standalone_merge_authorizations":[{"pr_number":501},{"pr_number":691,"basis":"selected"}]}' | ConvertFrom-Json

            (Get-StandaloneMergeAuthorizationRecord -Checkpoint $checkpoint -PrNumber 691).basis | Should -BeExactly 'selected'
            Get-StandaloneMergeAuthorizationRecord -Checkpoint $checkpoint -PrNumber 777 | Should -BeNullOrEmpty
            Get-StandaloneMergeAuthorizationRecord -Checkpoint $null -PrNumber 691 | Should -BeNullOrEmpty
        }
    }

    Context 'checkpoint-level verdicts' {
        It 'reports <Expected> for <Name>' -ForEach @(
            @{ Name = 'three absent checkpoints'; Slots = @('none', 'none', 'none'); Expected = 'STANDALONE_MERGE_AUTHORIZATION_ABSENT' }
            @{ Name = 'a checkpoint without the key'; Slots = @('plain', 'none', 'none'); Expected = 'STANDALONE_MERGE_AUTHORIZATION_ABSENT' }
            @{ Name = 'a record for another pull request'; Slots = @('none', 'other', 'none'); Expected = 'STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH' }
            @{ Name = 'a blanket flag beside a valid record'; Slots = @('blanket', 'valid', 'none'); Expected = 'STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC' }
            @{ Name = 'a matched record with a bad field'; Slots = @('none', 'none', 'bad'); Expected = 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED' }
        ) {
            $valid = New-ValidRecord
            $other = New-ValidRecord
            $other['pr_number'] = 777
            $other['pr_url'] = 'https://github.com/drmoisan/drm-copilot/pull/777'
            $bad = New-ValidRecord
            $bad['issue_num'] = 0
            $shapes = @{
                none    = $null
                plain   = ConvertTo-ParsedJson -Value @{ step9_status = 'passed' }
                other   = ConvertTo-ParsedJson -Value @{ standalone_merge_authorizations = @($other) }
                blanket = ConvertTo-ParsedJson -Value @{ standalone_merge_authorizations = $true }
                valid   = ConvertTo-ParsedJson -Value @{ standalone_merge_authorizations = @($valid) }
                bad     = ConvertTo-ParsedJson -Value @{ standalone_merge_authorizations = @($bad) }
            }
            $checkpoints = @($shapes[$Slots[0]], $shapes[$Slots[1]], $shapes[$Slots[2]])

            $verdict = Test-StandaloneCheckpointAllowsMerge -Checkpoints $checkpoints -CommandPrNumber 691 -EnvelopeSessionId $script:SessionId

            $verdict.Allowed | Should -BeFalse
            $verdict.ReasonCode | Should -BeExactly $Expected
            $verdict.Message | Should -Match 'orchestrator-state\.md'
        }

        It 'allows a valid record held in any checkpoint slot' {
            $parsed = ConvertTo-ParsedJson -Value @{ standalone_merge_authorizations = @(New-ValidRecord) }
            $verdict = Test-StandaloneCheckpointAllowsMerge -Checkpoints @($null, $null, $parsed) -CommandPrNumber 691 -EnvelopeSessionId $script:SessionId

            $verdict.Allowed | Should -BeTrue
            $verdict.ReasonCode | Should -BeNullOrEmpty
        }
    }
}
