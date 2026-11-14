#Requires -Version 7.0

<#
.SYNOPSIS
    Tests for Get-OrchestratorStateOwnerDirectiveValidEntry and the optional record fields (issue #1157).

.DESCRIPTION
    Every case passes in-memory JSON text: a JSON array of owner_directives entries or ledger text
    with one directive object per line. The valid entry is built from the committed fixture
    tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json, read into memory
    once. No test writes a file, reads a clock, or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    $script:FixtureText = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json')

    # The first fixture directive as a JSON node, edited by the caller and returned as compact text.
    function Get-EntryTestDirective {
        param([scriptblock] $Edit = {}, [string] $Id = 'OD-1')
        $root = [System.Text.Json.Nodes.JsonNode]::Parse($script:FixtureText)
        $entry = $root['owner_directives'][0].DeepClone()
        $entry['id'] = [System.Text.Json.Nodes.JsonValue]::Create($Id)
        & $Edit $entry
        return $entry.ToJsonString()
    }

    $script:Valid = Get-EntryTestDirective
}

Describe 'Get-OrchestratorStateOwnerDirectiveValidEntry input forms' {
    It 'returns no entry and no error for blank text' {
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text ''
        $result.Entries.Count | Should -Be 0
        $result.Errors.Count | Should -Be 0
    }

    It 'returns the valid entries of a JSON array with their fields' {
        $text = '[' + $script:Valid + ',' + (Get-EntryTestDirective -Id 'OD-2') + ']'
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text $text
        $result.Errors.Count | Should -Be 0 -Because ($result.Errors -join ' | ')
        $result.Entries.Count | Should -Be 2
        $result.Entries[0].Id | Should -BeExactly 'OD-1'
        $result.Entries[0].Class | Should -BeExactly 'extra_planner_revision'
        $result.Entries[0].ExpiresAt | Should -BeExactly '2026-11-09T14:05:00Z'
        $result.Entries[0].ExpiresAtUtc.Ticks | Should -Be ([datetime]::new(2026, 11, 9, 14, 5, 0, [System.DateTimeKind]::Utc).Ticks)
        $result.Entries[0].ScopeIssue | Should -Be 1139
        $result.Entries[0].ScopeBranch | Should -BeExactly 'feature/owner-directive-relay'
        $result.Entries[0].ScopeStep | Should -BeExactly 'S5'
        $result.Entries[1].Id | Should -BeExactly 'OD-2'
    }

    It 'keeps the recorded field order on one line in the Json field' {
        $pretty = "[`n  {`n" + ($script:Valid.TrimStart('{').TrimEnd('}') -replace ',"', ",`n    `"") + "`n  }`n]"
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text $pretty
        $result.Entries.Count | Should -Be 1
        $result.Entries[0].Json | Should -Not -Match "`n"
        ($result.Entries[0].Json | ConvertFrom-Json).PSObject.Properties.Name[0] | Should -BeExactly 'id'
        $result.Entries[0].Json.IndexOf('"text"') | Should -BeLessThan $result.Entries[0].Json.IndexOf('"scope"')
    }

    It 'reports a ledger line that is not a JSON object and keeps the valid lines' {
        $text = $script:Valid + "`n`n{not json`n" + (Get-EntryTestDirective -Id 'OD-3') + "`n"
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text $text
        @($result.Entries | ForEach-Object Id) | Should -Be @('OD-1', 'OD-3')
        $result.Errors.Count | Should -Be 1
        $result.Errors[0] | Should -BeExactly 'Ledger line #3 is not a JSON object.'
        $result.ErrorNumber[0] | Should -Be 3
        $result.InvalidNumber | Should -Be @(3)
    }

    It 'reports a ledger line that parses as JSON but is not an object' {
        $text = $script:Valid + "`n[1, 2]`n"
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text $text
        @($result.Entries | ForEach-Object Id) | Should -Be @('OD-1')
        $result.Errors | Should -Be @('Ledger line #2 is not a JSON object.')
        $result.InvalidNumber | Should -Be @(2)
    }

    It 'reports a JSON array that is not a non-empty list of objects with the B1 string' {
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text '[]'
        $result.Entries.Count | Should -Be 0
        $result.Errors | Should -Be @('Checkpoint owner_directives must be a non-empty list of objects when present.')
    }

    It 'reports unparseable JSON array text without throwing' {
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text '[{'
        $result.Entries.Count | Should -Be 0
        $result.Errors.Count | Should -Be 1
        $result.Errors[0] | Should -Match '^OWNER_DIRECTIVE_UNEVALUABLE:'
    }
}

Describe 'Get-OrchestratorStateOwnerDirectiveValidEntry rejects one violating entry per B rule' {
    It '<Rule> drops the violating ledger line and keeps the valid sibling' -ForEach @(
        @{ Rule = 'B2'; Expected = 'Ledger line #1 field issued_by_session must be a non-empty string.'; Edit = { param($e) $e['issued_by_session'] = [System.Text.Json.Nodes.JsonValue]::Create(' ') } }
        @{ Rule = 'B3'; Expected = 'Ledger line #1 id must match OD-<positive integer>.'; Edit = { param($e) $e['id'] = [System.Text.Json.Nodes.JsonValue]::Create('OD-0') } }
        @{ Rule = 'B5'; Expected = 'Ledger line #1 text_sha256 does not match text.'; Edit = { param($e) $e['text'] = [System.Text.Json.Nodes.JsonValue]::Create('Changed owner text that no longer matches.') } }
        @{ Rule = 'B6'; Expected = 'Ledger line #1 class must be one of: scheduling, merge_timing, extra_planner_revision, scope_narrowing, accept_nonblocking_deviation, gate_bypass, force_push, tag_or_publish, policy_or_settings_edit, evidence_alteration, unclassified.'; Edit = { param($e) $e['class'] = [System.Text.Json.Nodes.JsonValue]::Create('approval') } }
        @{ Rule = 'B7'; Expected = 'Ledger line #1 expires_at must be a date-time later than recorded_at.'; Edit = { param($e) $e['expires_at'] = [System.Text.Json.Nodes.JsonValue]::Create('2026-11-08T14:05:00Z') } }
        @{ Rule = 'B8'; Expected = 'Ledger line #1 scope must be an object with issue, branch, and step.'; Edit = { param($e) $e['scope']['issue'] = [System.Text.Json.Nodes.JsonValue]::Create(0) } }
    ) {
        $text = (Get-EntryTestDirective -Id 'OD-1' -Edit $Edit) + "`n" + (Get-EntryTestDirective -Id 'OD-2')
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text $text
        $result.Errors | Should -Be @($Expected)
        @($result.Entries | ForEach-Object Id) | Should -Be @('OD-2')
    }

    It 'B4 drops the second entry of a duplicated id in a JSON array and keeps the first' {
        $result = Get-OrchestratorStateOwnerDirectiveValidEntry -Text ('[' + $script:Valid + ',' + $script:Valid + ']')
        $result.Errors | Should -Be @('Checkpoint owner_directives entry #2 id OD-1 is duplicated.')
        @($result.Entries | ForEach-Object Id) | Should -Be @('OD-1')
        $result.InvalidNumber | Should -Be @(2)
    }
}

Describe 'Get-OrchestratorStateOwnerDirectiveError tolerates the optional record fields (AC-21)' {
    BeforeAll {
        function Get-RecordTestCheckpoint {
            param([scriptblock] $Edit)
            $root = [System.Text.Json.Nodes.JsonNode]::Parse($script:FixtureText)
            foreach ($record in $root['owner_directive_records'].AsArray()) {
                $record['agent_id'] = [System.Text.Json.Nodes.JsonValue]::Create('a1b2c3')
                $record['decision_source'] = [System.Text.Json.Nodes.JsonValue]::Create('decision_file')
            }
            if ($null -ne $Edit) { & $Edit $root }
            return $root.ToJsonString()
        }
    }

    It 'returns no error for valid records carrying agent_id and decision_source' {
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText (Get-RecordTestCheckpoint)
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'R3 still fires on a record carrying the optional fields' {
        $text = Get-RecordTestCheckpoint -Edit { param($root) $root['owner_directive_records'][1]['directive_id'] = [System.Text.Json.Nodes.JsonValue]::Create('OD-9') }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors | Should -Contain 'Checkpoint owner_directive_records entry #2 references directive OD-9 that is not in owner_directives.'
    }

    It 'R6 still fires on a record carrying the optional fields' {
        $text = Get-RecordTestCheckpoint -Edit { param($root) $root['owner_directive_records'][1]['outcome'] = [System.Text.Json.Nodes.JsonValue]::Create('honored') }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors | Should -Contain 'Checkpoint owner_directive_records entry #2 honors directive OD-2 of refused class gate_bypass.'
    }
}
