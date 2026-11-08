#Requires -Version 7.0

<#
.SYNOPSIS
    Record-rule (R1-R10) tests for OrchestratorStateOwnerDirectives.psm1 (issue #1139).

.DESCRIPTION
    Every case passes JSON text to Get-OrchestratorStateOwnerDirectiveError -CheckpointText. The
    texts are derived from tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json
    through System.Text.Json.Nodes edits or written as literal JSON text. The fixture holds OD-1
    (extra_planner_revision, one honored record) and OD-2 (gate_bypass, one refused record).
    The fixture is read into memory once; no test creates, writes, or deletes a file.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    $script:FixtureText = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json')

    $script:R1 = 'Checkpoint owner_directive_records must be a list of objects when present.'
    $script:R5 = 'Checkpoint owner_directive_records entry #1 outcome must be honored or refused.'
    $script:R8 = 'Checkpoint owner_directive_records entry #1 reason must be at least 20 characters.'
    $script:R9 = 'Checkpoint owner_directive_records entry #1 decided_at must be a date-time.'
    $script:R10 = 'Checkpoint owner_directive_records entry #1 honors directive OD-1 after its expires_at.'

    # Parse the fixture text, apply an edit to the node tree, and return the edited JSON text.
    function Edit-OwnerDirectiveRecordFixture {
        param([scriptblock] $Edit)
        $root = [System.Text.Json.Nodes.JsonNode]::Parse($script:FixtureText)
        & $Edit $root
        return $root.ToJsonString()
    }

    # A JSON node holding one string value.
    function ConvertTo-OwnerDirectiveRecordJsonValue {
        param([string] $Value)
        return [System.Text.Json.Nodes.JsonValue]::Create($Value)
    }

    # A record object for directive Id with the given class, outcome, and decision time.
    function ConvertTo-OwnerDirectiveRecordNode {
        param([string] $Id, [string] $Class, [string] $Outcome, [string] $DecidedAt = '2026-11-08T15:30:00Z')
        $record = [System.Text.Json.Nodes.JsonNode]::Parse('{"reason":"The coordinator relayed this recorded directive.","decided_by":"orchestrator"}')
        $record['directive_id'] = ConvertTo-OwnerDirectiveRecordJsonValue $Id
        $record['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $Class
        $record['outcome'] = ConvertTo-OwnerDirectiveRecordJsonValue $Outcome
        $record['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue $DecidedAt
        return , $record
    }

    # Assert that the module returns exactly the expected errors, in order, for Text.
    function Assert-OwnerDirectiveRecordError {
        param([string] $Text, [AllowEmptyCollection()] [string[]] $Expected)
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $Text
        $errors.Count | Should -Be $Expected.Count -Because ($errors -join ' | ')
        for ($i = 0; $i -lt $Expected.Count; $i++) { $errors[$i] | Should -BeExactly $Expected[$i] }
    }
}

Describe 'OrchestratorStateOwnerDirectives record list shape R1 R2' {
    It 'R1 rejects an owner_directive_records value that is <Shape>' -ForEach @(
        @{ Shape = 'an object'; Json = '{}' }
        @{ Shape = 'a list holding a number'; Json = '[1]' }
        @{ Shape = 'a string'; Json = '"OD-1"' }
    ) {
        $jsonValue = $Json
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'] = [System.Text.Json.Nodes.JsonNode]::Parse($jsonValue) }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R1)
    }

    It 'R1 accepts an empty record list next to a valid owner_directives block' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'] = [System.Text.Json.Nodes.JsonNode]::Parse('[]') }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R2 reports field <Field> of record #1 when it is <Mode>' -ForEach @(
        foreach ($fieldName in @('directive_id', 'class', 'outcome', 'reason', 'decided_by', 'decided_at')) {
            @{ Field = $fieldName; Mode = 'removed' }
            @{ Field = $fieldName; Mode = 'blank' }
        }
    ) {
        $fieldName = $Field
        $blank = ($Mode -eq 'blank')
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            if ($blank) { $root['owner_directive_records'][0][$fieldName] = ConvertTo-OwnerDirectiveRecordJsonValue '' }
            else { $null = $root['owner_directive_records'][0].AsObject().Remove($fieldName) }
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors | Should -Contain ('Checkpoint owner_directive_records entry #1 field {0} must be a non-empty string.' -f $Field)
    }
}

Describe 'OrchestratorStateOwnerDirectives record reference and outcome rules R3-R7' {
    It 'R3 rejects every record when the owner_directives block is absent' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $null = $root.AsObject().Remove('owner_directives') }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @(
            'Checkpoint owner_directive_records entry #1 references directive OD-1 that is not in owner_directives.'
            'Checkpoint owner_directive_records entry #2 references directive OD-2 that is not in owner_directives.'
        )
    }

    It 'R3 rejects a record that cites an unknown directive id' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['directive_id'] = ConvertTo-OwnerDirectiveRecordJsonValue 'OD-9' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @('Checkpoint owner_directive_records entry #1 references directive OD-9 that is not in owner_directives.')
    }

    It 'R4 rejects a record whose class differs from its directive class' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue 'scheduling' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @('Checkpoint owner_directive_records entry #1 class does not match directive OD-1.')
    }

    It 'R5 rejects the outcome <Outcome>' -ForEach @(
        @{ Outcome = 'approved' }
        @{ Outcome = 'Honored' }
    ) {
        $outcomeValue = $Outcome
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['outcome'] = ConvertTo-OwnerDirectiveRecordJsonValue $outcomeValue }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R5)
    }

    It 'R6 rejects an honored record for the refused class <Class>' -ForEach @(
        @{ Class = 'gate_bypass' }
        @{ Class = 'force_push' }
        @{ Class = 'tag_or_publish' }
        @{ Class = 'policy_or_settings_edit' }
        @{ Class = 'evidence_alteration' }
        @{ Class = 'unclassified' }
    ) {
        $classValue = $Class
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $root['owner_directives'][1]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $classValue
            $root['owner_directive_records'][1]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $classValue
            $root['owner_directive_records'][1]['outcome'] = ConvertTo-OwnerDirectiveRecordJsonValue 'honored'
        }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @(('Checkpoint owner_directive_records entry #2 honors directive OD-2 of refused class {0}.' -f $Class))
    }

    It 'R6 accepts a refused record for the refused class <Class>' -ForEach @(
        @{ Class = 'gate_bypass' }
        @{ Class = 'force_push' }
        @{ Class = 'tag_or_publish' }
        @{ Class = 'policy_or_settings_edit' }
        @{ Class = 'evidence_alteration' }
        @{ Class = 'unclassified' }
    ) {
        $classValue = $Class
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $root['owner_directives'][1]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $classValue
            $root['owner_directive_records'][1]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $classValue
            $root['owner_directive_records'][1]['outcome'] = ConvertTo-OwnerDirectiveRecordJsonValue 'refused'
        }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R6 accepts an honored record for the honorable class <Class>' -ForEach @(
        @{ Class = 'scheduling' }
        @{ Class = 'merge_timing' }
        @{ Class = 'extra_planner_revision' }
        @{ Class = 'scope_narrowing' }
        @{ Class = 'accept_nonblocking_deviation' }
    ) {
        $classValue = $Class
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $null = $root['owner_directives'].AsArray().RemoveAt(0)
            $root['owner_directives'][0]['class'] = ConvertTo-OwnerDirectiveRecordJsonValue $classValue
            $records = $root['owner_directive_records'].AsArray()
            $records.Clear()
            $records.Insert(0, (ConvertTo-OwnerDirectiveRecordNode -Id 'OD-2' -Class $classValue -Outcome 'honored'))
        }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R7 rejects a second honored record for one extra_planner_revision directive' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $records = $root['owner_directive_records'].AsArray()
            $records.Insert($records.Count, (ConvertTo-OwnerDirectiveRecordNode -Id 'OD-1' -Class 'extra_planner_revision' -Outcome 'honored'))
        }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @('Checkpoint owner_directive_records directive OD-1 grants more than one extra planner revision.')
    }

    It 'R7 accepts one honored and one refused record for one extra_planner_revision directive' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $records = $root['owner_directive_records'].AsArray()
            $records.Insert($records.Count, (ConvertTo-OwnerDirectiveRecordNode -Id 'OD-1' -Class 'extra_planner_revision' -Outcome 'refused'))
        }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }
}

Describe 'OrchestratorStateOwnerDirectives record reason and date rules R8-R10' {
    It 'R8 rejects the reason <Case>' -ForEach @(
        @{ Case = 'of 19 characters'; Reason = ('r' * 19) }
        @{ Case = 'of 19 non-space characters padded to a raw length of 25'; Reason = ('   ' + ('r' * 19) + '   ') }
    ) {
        $reasonValue = $Reason
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['reason'] = ConvertTo-OwnerDirectiveRecordJsonValue $reasonValue }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R8)
    }

    It 'R8 accepts a reason of exactly 20 characters' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['reason'] = ConvertTo-OwnerDirectiveRecordJsonValue ('r' * 20) }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R9 rejects an unparseable decided_at' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue 'yesterday afternoon' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R9)
    }

    It 'R9 rejects the non-ISO decided_at <Decided>' -ForEach @(
        @{ Decided = '11/08/2026' }
        @{ Decided = 'Monday, 09 November 2026' }
        @{ Decided = '8 Nov 2026 3pm' }
    ) {
        $decidedValue = $Decided
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue $decidedValue }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R9)
    }

    It 'R10 rejects an honored record decided after the directive expires_at' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue '2026-11-09T14:06:00Z' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @($script:R10)
    }

    It 'R10 accepts a refused record decided after the directive expires_at' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][1]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue '2026-11-10T00:00:00Z' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R10 accepts an honored record decided exactly at the directive expires_at' {
        $text = Edit-OwnerDirectiveRecordFixture -Edit { param($root) $root['owner_directive_records'][0]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue '2026-11-09T14:05:00Z' }
        Assert-OwnerDirectiveRecordError -Text $text -Expected @()
    }

    It 'R10 compares decided_at <Decided> with expires_at 12:00Z in UTC' -ForEach @(
        @{ Decided = '2026-11-08T13:00:00+02:00'; Rejected = $false }
        @{ Decided = '2026-11-08T11:00:00-02:00'; Rejected = $true }
        @{ Decided = '2026-11-08T12:30:00'; Rejected = $true }
    ) {
        $decidedValue = $Decided
        $text = Edit-OwnerDirectiveRecordFixture -Edit {
            param($root)
            $root['owner_directives'][0]['recorded_at'] = ConvertTo-OwnerDirectiveRecordJsonValue '2026-11-08T10:00:00Z'
            $root['owner_directives'][0]['expires_at'] = ConvertTo-OwnerDirectiveRecordJsonValue '2026-11-08T12:00:00Z'
            $root['owner_directive_records'][0]['decided_at'] = ConvertTo-OwnerDirectiveRecordJsonValue $decidedValue
        }
        $expected = if ($Rejected) { @($script:R10) } else { @() }
        Assert-OwnerDirectiveRecordError -Text $text -Expected $expected
    }
}
