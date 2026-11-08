#Requires -Version 7.0

<#
.SYNOPSIS
    Block-rule (B1-B8), absence, ordering, and purity tests for OrchestratorStateOwnerDirectives.psm1 (issue #1139).

.DESCRIPTION
    Every case passes JSON text to Get-OrchestratorStateOwnerDirectiveError -CheckpointText, the
    read path the stop hook uses. Violating cases are derived from the fixture text
    tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json through
    System.Text.Json.Nodes edits or written as literal JSON text. The fixture is read into
    memory once; no test creates, writes, or deletes a file, reads a clock, or starts a process.
    The record rules (R1-R10) are covered by OrchestratorStateOwnerDirectives.Records.Tests.ps1.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1'
    Import-Module $script:ModulePath -Force -ErrorAction Stop
    $script:FixtureText = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json')

    $script:B1 = 'Checkpoint owner_directives must be a non-empty list of objects when present.'
    $script:B3 = 'Checkpoint owner_directives entry #1 id must match OD-<positive integer>.'
    $script:B5 = 'Checkpoint owner_directives entry #1 text_sha256 does not match text.'
    $script:B6 = 'Checkpoint owner_directives entry #1 class must be one of: scheduling, merge_timing, extra_planner_revision, scope_narrowing, accept_nonblocking_deviation, gate_bypass, force_push, tag_or_publish, policy_or_settings_edit, evidence_alteration, unclassified.'
    $script:B7 = 'Checkpoint owner_directives entry #1 expires_at must be a date-time later than recorded_at.'
    $script:B8 = 'Checkpoint owner_directives entry #1 scope must be an object with issue, branch, and step.'

    # Parse the fixture text, apply an edit to the node tree, and return the edited JSON text.
    function Edit-OwnerDirectiveFixture {
        param([scriptblock] $Edit, [switch] $WithoutRecords)
        $root = [System.Text.Json.Nodes.JsonNode]::Parse($script:FixtureText)
        if ($WithoutRecords) { $null = $root.AsObject().Remove('owner_directive_records') }
        & $Edit $root
        return $root.ToJsonString()
    }

    # A JSON node holding one string or number value.
    function ConvertTo-OwnerDirectiveJsonValue {
        param([object] $Value)
        return [System.Text.Json.Nodes.JsonValue]::Create($Value)
    }

    # The lowercase hexadecimal SHA-256 digest of Text under the given encoding.
    function Get-TestTextDigest {
        param([string] $Text, [System.Text.Encoding] $Encoding = [System.Text.UTF8Encoding]::new($false))
        return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($Encoding.GetBytes($Text))).ToLowerInvariant()
    }

    # Assert that the module returns exactly the one expected error for Text.
    function Assert-OwnerDirectiveSingleError {
        param([string] $Text, [string] $Expected)
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $Text
        $errors.Count | Should -Be 1 -Because ($errors -join ' | ')
        $errors[0] | Should -BeExactly $Expected
    }

    # Parse the module file and return its AST, its non-comment tokens, and its parse errors.
    function Get-OwnerDirectiveModuleSyntax {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $tokens, [ref] $parseErrors)
        $codeTokens = @($tokens | Where-Object { $_.Kind -ne [System.Management.Automation.Language.TokenKind]::Comment })
        return [pscustomobject]@{ Ast = $ast; Tokens = $codeTokens; Errors = @($parseErrors) }
    }
}

Describe 'OrchestratorStateOwnerDirectives absence, eligibility, and parsing' {
    It 'S1 returns an empty array when neither owner key is present' {
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText '{"objective":"run","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z"}'
        $errors.Count | Should -Be 0
    }

    It 'S1 returns an empty array for the non-object root <Root>' -ForEach @(
        @{ Root = '[{"owner_directives":[]}]' }
        @{ Root = '"owner_directives"' }
    ) {
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $Root
        $errors.Count | Should -Be 0
    }

    It 'S3 returns an empty array for the valid fixture with honored and refused records' {
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $script:FixtureText
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'S1 throws OWNER_DIRECTIVE_UNEVALUABLE for a NaN value in text that carries owner_directives' {
        $text = '{"budget": NaN, ' + $script:FixtureText.TrimStart().Substring(1)
        { Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text } | Should -Throw -ExpectedMessage 'OWNER_DIRECTIVE_UNEVALUABLE:*'
    }

    It 'S1 throws OWNER_DIRECTIVE_UNEVALUABLE for a NaN value in text with neither owner key' {
        $text = '{"objective":"run","budget":NaN,"completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z"}'
        { Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text } | Should -Throw -ExpectedMessage 'OWNER_DIRECTIVE_UNEVALUABLE:*'
    }

    It 'S1 returns an empty array when both key names appear only in string values' {
        $text = '{"objective":"relay owner_directives and owner_directive_records","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z"}'
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 0
    }

    It 'B1 compares the decoded name of a JSON-escaped owner_directives key' {
        $text = '{"owner' + [string][char]92 + 'u005fdirectives":[]}'
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B1
    }

    It 'B1 eligibility is ordinal so an Owner_Directives key holding an empty list is ignored' {
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText '{"Owner_Directives":[]}'
        $errors.Count | Should -Be 0
    }

    It 'B5 accepts a date-looking directive text that carries its correct digest' {
        $dateText = '2026-11-08T10:00:00Z'
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['text'] = ConvertTo-OwnerDirectiveJsonValue $dateText
            $root['owner_directives'][0]['text_sha256'] = ConvertTo-OwnerDirectiveJsonValue (Get-TestTextDigest -Text $dateText)
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }
}

Describe 'OrchestratorStateOwnerDirectives block rules B1-B8' {
    It 'B1 rejects an owner_directives value that is <Shape>' -ForEach @(
        @{ Shape = 'an empty list'; Json = '[]' }
        @{ Shape = 'an object'; Json = '{}' }
        @{ Shape = 'a list holding a number'; Json = '[1]' }
        @{ Shape = 'a string'; Json = '"OD-1"' }
    ) {
        Assert-OwnerDirectiveSingleError -Text ('{"owner_directives":' + $Json + '}') -Expected $script:B1
    }

    It 'B2 reports field <Field> of entry #1 when it is <Mode>' -ForEach @(
        foreach ($fieldName in @('id', 'text', 'text_sha256', 'class', 'recorded_at', 'expires_at', 'issued_by_session')) {
            @{ Field = $fieldName; Mode = 'removed' }
            @{ Field = $fieldName; Mode = 'blank' }
        }
    ) {
        $fieldName = $Field
        $blank = ($Mode -eq 'blank')
        $text = Edit-OwnerDirectiveFixture -Edit {
            param($root)
            if ($blank) { $root['owner_directives'][0][$fieldName] = ConvertTo-OwnerDirectiveJsonValue '' }
            else { $null = $root['owner_directives'][0].AsObject().Remove($fieldName) }
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors | Should -Contain ('Checkpoint owner_directives entry #1 field {0} must be a non-empty string.' -f $Field)
    }

    It 'B2 reports a whitespace-only issued_by_session as one non-empty-string error' {
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit { param($root) $root['owner_directives'][0]['issued_by_session'] = ConvertTo-OwnerDirectiveJsonValue '   ' }
        Assert-OwnerDirectiveSingleError -Text $text -Expected 'Checkpoint owner_directives entry #1 field issued_by_session must be a non-empty string.'
    }

    It 'B3 rejects the id <Id>' -ForEach @(
        @{ Id = 'OD-0' }
        @{ Id = 'od-1' }
        @{ Id = 'OD-1x' }
        @{ Id = 'OD-01' }
    ) {
        $idValue = $Id
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit { param($root) $root['owner_directives'][0]['id'] = ConvertTo-OwnerDirectiveJsonValue $idValue }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B3
    }

    It 'B4 rejects a duplicated directive id on the later entry' {
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit { param($root) $root['owner_directives'][1]['id'] = ConvertTo-OwnerDirectiveJsonValue 'OD-1' }
        Assert-OwnerDirectiveSingleError -Text $text -Expected 'Checkpoint owner_directives entry #2 id OD-1 is duplicated.'
    }

    It 'B5 rejects the uppercase hexadecimal form of the correct digest' {
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $directiveText = $root['owner_directives'][0]['text'].GetValue[string]()
            $root['owner_directives'][0]['text_sha256'] = ConvertTo-OwnerDirectiveJsonValue (Get-TestTextDigest -Text $directiveText).ToUpperInvariant()
        }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B5
    }

    It 'B5 accepts a non-ASCII text whose digest is taken over its UTF-8 bytes' {
        $nonAscii = 'Zusammenf' + [char]0x00FC + 'hrung sp' + [char]0x00E4 + 'ter'
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['text'] = ConvertTo-OwnerDirectiveJsonValue $nonAscii
            $root['owner_directives'][0]['text_sha256'] = ConvertTo-OwnerDirectiveJsonValue (Get-TestTextDigest -Text $nonAscii)
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'B5 rejects a non-ASCII text whose digest is taken over its UTF-16 bytes' {
        $nonAscii = 'Zusammenf' + [char]0x00FC + 'hrung sp' + [char]0x00E4 + 'ter'
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['text'] = ConvertTo-OwnerDirectiveJsonValue $nonAscii
            $root['owner_directives'][0]['text_sha256'] = ConvertTo-OwnerDirectiveJsonValue (Get-TestTextDigest -Text $nonAscii -Encoding ([System.Text.Encoding]::Unicode))
        }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B5
    }

    It 'B6 rejects the class <Class>' -ForEach @(
        @{ Class = 'approval' }
        @{ Class = 'Scheduling' }
    ) {
        $classValue = $Class
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit { param($root) $root['owner_directives'][0]['class'] = ConvertTo-OwnerDirectiveJsonValue $classValue }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B6
    }

    It 'B7 rejects recorded_at <Recorded> with expires_at <Expires>' -ForEach @(
        @{ Recorded = '2026-11-08T10:00:00Z'; Expires = '2026-11-08T10:00:00Z' }
        @{ Recorded = '2026-11-08T11:00:00Z'; Expires = '2026-11-08T10:00:00Z' }
        @{ Recorded = 'not-a-date'; Expires = '2026-11-09T10:00:00Z' }
        @{ Recorded = '2026-11-08T10:00:00Z'; Expires = 'tomorrow' }
        @{ Recorded = '2026-11-08T09:00:00-02:00'; Expires = '2026-11-08T10:00:00Z' }
        @{ Recorded = '2026-11-08T10:00:00'; Expires = '2026-11-08T10:00:00Z' }
        @{ Recorded = '11/08/2026'; Expires = '2026-11-30T10:00:00Z' }
        @{ Recorded = 'Monday, 09 November 2026'; Expires = '2026-11-30T10:00:00Z' }
        @{ Recorded = '8 Nov 2026 3pm'; Expires = '2026-11-30T10:00:00Z' }
        @{ Recorded = '2026-11-01T10:00:00Z'; Expires = '11/08/2026' }
        @{ Recorded = '2026-11-01T10:00:00Z'; Expires = 'Monday, 09 November 2026' }
        @{ Recorded = '2026-11-01T10:00:00Z'; Expires = '8 Nov 2026 3pm' }
        @{ Recorded = '2026-11-08 10:00:00Z'; Expires = '2026-11-30T10:00:00Z' }
        @{ Recorded = '2026-11-08'; Expires = '2026-11-30T10:00:00Z' }
    ) {
        $recordedValue = $Recorded
        $expiresValue = $Expires
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['recorded_at'] = ConvertTo-OwnerDirectiveJsonValue $recordedValue
            $root['owner_directives'][0]['expires_at'] = ConvertTo-OwnerDirectiveJsonValue $expiresValue
        }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B7
    }

    It 'B7 accepts an offset recorded_at that is earlier than expires_at in UTC' {
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['recorded_at'] = ConvertTo-OwnerDirectiveJsonValue '2026-11-08T12:00:00+05:00'
            $root['owner_directives'][0]['expires_at'] = ConvertTo-OwnerDirectiveJsonValue '2026-11-08T08:00:00Z'
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'B7 accepts the ISO 8601 shape <Recorded>' -ForEach @(
        @{ Recorded = '2026-11-08T10:00Z' }
        @{ Recorded = '2026-11-08T10:00:00.5Z' }
        @{ Recorded = '2026-11-08T10:00' }
    ) {
        $recordedValue = $Recorded
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $root['owner_directives'][0]['recorded_at'] = ConvertTo-OwnerDirectiveJsonValue $recordedValue
            $root['owner_directives'][0]['expires_at'] = ConvertTo-OwnerDirectiveJsonValue '2026-11-30T10:00:00Z'
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'B8 rejects entry #1 when <Case>' -ForEach @(
        @{ Case = 'scope is a string'; Path = ''; Json = '"S5"' }
        @{ Case = 'scope is removed'; Path = ''; Json = $null }
        @{ Case = 'scope.issue is removed'; Path = 'issue'; Json = $null }
        @{ Case = 'scope.issue is 0'; Path = 'issue'; Json = '0' }
        @{ Case = 'scope.issue is the string 1139'; Path = 'issue'; Json = '"1139"' }
        @{ Case = 'scope.issue is the fraction 1.5'; Path = 'issue'; Json = '1.5' }
        @{ Case = 'scope.issue is -1'; Path = 'issue'; Json = '-1' }
        @{ Case = 'scope.branch is removed'; Path = 'branch'; Json = $null }
        @{ Case = 'scope.branch is blank'; Path = 'branch'; Json = '""' }
        @{ Case = 'scope.step is removed'; Path = 'step'; Json = $null }
        @{ Case = 'scope.step is blank'; Path = 'step'; Json = '""' }
    ) {
        $scopeField = $Path
        $jsonValue = $Json
        $text = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
            param($root)
            $entry = $root['owner_directives'][0]
            # Plain assignments: an if-expression would enumerate a JsonObject into its pairs.
            $target = $entry
            $name = 'scope'
            if ($scopeField) {
                $target = $entry['scope']
                $name = $scopeField
            }
            if ($null -eq $jsonValue) { $null = $target.AsObject().Remove($name) }
            else { $target[$name] = [System.Text.Json.Nodes.JsonNode]::Parse($jsonValue) }
        }
        Assert-OwnerDirectiveSingleError -Text $text -Expected $script:B8
    }

    It 'B6 R4 R3 block errors precede record errors whatever the key order of the text' {
        $text = Edit-OwnerDirectiveFixture -Edit {
            param($root)
            $block = $root['owner_directives']
            $null = $root.AsObject().Remove('owner_directives')
            $root['owner_directives'] = $block
            $block[0]['class'] = ConvertTo-OwnerDirectiveJsonValue 'approval'
            $root['owner_directive_records'][1]['directive_id'] = ConvertTo-OwnerDirectiveJsonValue 'OD-9'
        }
        $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $text
        $errors.Count | Should -Be 3 -Because ($errors -join ' | ')
        $errors[0] | Should -BeExactly $script:B6
        $errors[1] | Should -BeExactly 'Checkpoint owner_directive_records entry #1 class does not match directive OD-1.'
        $errors[2] | Should -BeExactly 'Checkpoint owner_directive_records entry #2 references directive OD-9 that is not in owner_directives.'
    }
}

Describe 'OrchestratorStateOwnerDirectives host independence and purity' {
    It 'B7 reads zone-less dates as UTC strings under the de-DE culture' {
        $priorCulture = [System.Globalization.CultureInfo]::CurrentCulture
        try {
            [System.Globalization.CultureInfo]::CurrentCulture = [System.Globalization.CultureInfo]::new('de-DE')
            $zoneLessText = Edit-OwnerDirectiveFixture -WithoutRecords -Edit {
                param($root)
                $root['owner_directives'][0]['recorded_at'] = ConvertTo-OwnerDirectiveJsonValue '2026-11-08T10:00:00'
                $root['owner_directives'][0]['expires_at'] = ConvertTo-OwnerDirectiveJsonValue '2026-11-08T10:00:00Z'
            }
            InModuleScope OrchestratorStateOwnerDirectives -Parameters @{ Text = $zoneLessText; Expected = $script:B7 } {
                param($Text, $Expected)
                $document = [System.Text.Json.JsonDocument]::Parse('{"recorded_at":"2026-11-08T10:00:00"}')
                try { $value = Get-OwnerDirectiveString -Element $document.RootElement -Name 'recorded_at' } finally { $document.Dispose() }
                $value | Should -BeOfType [string]
                $value | Should -BeExactly '2026-11-08T10:00:00'
                $parsed = ConvertFrom-OwnerDirectiveDateText -Text $value
                $parsed.Ticks | Should -Be ([datetime]::new(2026, 11, 8, 10, 0, 0, [System.DateTimeKind]::Utc).Ticks)
                $errors = Get-OrchestratorStateOwnerDirectiveError -CheckpointText $Text
                $errors.Count | Should -Be 1
                $errors[0] | Should -BeExactly $Expected
            }
        }
        finally {
            [System.Globalization.CultureInfo]::CurrentCulture = $priorCulture
        }
    }

    It 'B7 every date parse in the module assumes and adjusts to UTC and no local style is named' {
        $syntax = Get-OwnerDirectiveModuleSyntax
        $syntax.Errors.Count | Should -Be 0
        $parseCalls = @($syntax.Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                    $node.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    $node.Expression.TypeName.Name -match '^(System\.)?(datetime|DateTimeOffset)$' -and
                    $node.Member.Extent.Text -match 'Parse'
                }, $true))
        $parseCalls.Count | Should -BeGreaterThan 0
        foreach ($call in $parseCalls) {
            $function = $call
            while ($null -ne $function -and $function -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $function = $function.Parent }
            $function | Should -Not -BeNullOrEmpty
            $function.Extent.Text | Should -Match 'AssumeUniversal'
            $function.Extent.Text | Should -Match 'AdjustToUniversal'
        }
        $localStyles = @($syntax.Tokens | Where-Object { $_.Text -match 'AssumeLocal|AdjustToLocal' })
        $localStyles.Count | Should -Be 0
    }

    It 'S1 the module calls no clock, file, process, or import command' {
        $syntax = Get-OwnerDirectiveModuleSyntax
        $commands = @($syntax.Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) |
                ForEach-Object { $_.GetCommandName() } | Where-Object { $_ })
        foreach ($forbidden in @('Get-Date', 'Get-Content', ('Start-' + 'Process'), 'Import-Module')) {
            $commands | Should -Not -Contain $forbidden
        }
        $clockMembers = @($syntax.Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Member.Extent.Text -in @('UtcNow', 'Now')
                }, $true))
        $clockMembers.Count | Should -Be 0
    }
}
