<#
.SYNOPSIS
    Pester tests for .claude/lib/regeneration/RegenerationConfig.psm1 (issue #1156).

.DESCRIPTION
    Exercises ConvertFrom-RegenerationConfigText and Get-RegenerationConfigError
    with in-memory JSON text only: validation rules 1 through 9, each forbidden
    pattern shape of rule 7, error accumulation order, the default-off states, and
    value preservation of a valid document. No file, process, or clock is used.
#>

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration/RegenerationConfig.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    $script:ValidText = '{"version":1,"regeneration":{"command":["gen"],"paths":["gen/**"]}}'

    function Get-ConfigErrorFor {
        param([string] $Text)
        return , @((ConvertFrom-RegenerationConfigText -Text $Text).Errors)
    }

    function Get-RegenerationTextWith {
        param([string] $Body)
        return '{"version":1,"regeneration":{' + $Body + '}}'
    }
}

AfterAll {
    Remove-Module -Name RegenerationConfig -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\Get-ConfigErrorFor, Function:\Get-RegenerationTextWith -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-RegenerationConfigText' {
    It 'returns no errors and the regeneration object for a valid version 1 document' {
        $result = ConvertFrom-RegenerationConfigText -Text $script:ValidText
        @($result.Errors).Count | Should -Be 0
        $result.Config | Should -Not -BeNullOrEmpty
        $result.Config['command'][0] | Should -BeExactly 'gen'
    }

    It 'accepts a document declaring every optional key' {
        $text = Get-RegenerationTextWith -Body '"command":["g"],"paths":["a/*.json"],"idempotency_check":["c"],"unit_gate":[["u"]]'
        (Get-ConfigErrorFor -Text $text).Count | Should -Be 0
    }

    It 'returns Config null and no error for absent text (file absent)' {
        $result = ConvertFrom-RegenerationConfigText -Text $null
        $result.Config | Should -BeNullOrEmpty
        @($result.Errors).Count | Should -Be 0
    }

    It 'returns Config null and no error when the regeneration key is absent' {
        $result = ConvertFrom-RegenerationConfigText -Text '{"version":1}'
        $result.Config | Should -BeNullOrEmpty
        @($result.Errors).Count | Should -Be 0
    }

    It 'returns Config null and no error when regeneration is null' {
        $result = ConvertFrom-RegenerationConfigText -Text '{"version":1,"regeneration":null}'
        $result.Config | Should -BeNullOrEmpty
        @($result.Errors).Count | Should -Be 0
    }

    It 'preserves every value of a valid document in order without unwrapping lists' {
        $text = Get-RegenerationTextWith -Body '"command":["gen-tool","--write"],"paths":["gen/**"],"idempotency_check":["check-tool","--strict"],"unit_gate":[["ut-a","1"],["ut-b","2"]]'
        $result = ConvertFrom-RegenerationConfigText -Text $text
        @($result.Errors).Count | Should -Be 0
        $config = $result.Config
        ($config['command'] -join '|') | Should -BeExactly 'gen-tool|--write'
        ($config['idempotency_check'] -join '|') | Should -BeExactly 'check-tool|--strict'
        $config['paths'] -is [object[]] | Should -BeTrue
        $config['paths'].Count | Should -Be 1
        $config['paths'][0] | Should -BeExactly 'gen/**'
        $config['unit_gate'].Count | Should -Be 2
        $config['unit_gate'][0] -is [object[]] | Should -BeTrue
        ($config['unit_gate'][0] -join '|') | Should -BeExactly 'ut-a|1'
        ($config['unit_gate'][1] -join '|') | Should -BeExactly 'ut-b|2'
    }
}

Describe 'Get-RegenerationConfigError rules' {
    It 'rule 1: rejects text that does not parse as JSON' {
        $errors = Get-ConfigErrorFor -Text '{not json'
        $errors.Count | Should -Be 1
        $errors[0] | Should -BeExactly '(document): text does not parse as a JSON object'
    }

    It 'rule 1: rejects a JSON value that is not an object' {
        $errors = Get-ConfigErrorFor -Text '[1]'
        $errors | Should -Contain '(document): text does not parse as a JSON object'
    }

    It 'rule 1: rejects a document passed directly that is not a dictionary' {
        $errors = Get-RegenerationConfigError -Document 'text'
        $errors | Should -Contain '(document): text does not parse as a JSON object'
    }

    It 'rule 2: rejects an absent version' {
        $errors = Get-ConfigErrorFor -Text '{"regeneration":null}'
        $errors | Should -Contain 'version: required key is absent'
    }

    It 'rule 2: rejects version <Shape>' -ForEach @(
        @{ Shape = 'as a string'; Value = '"1"' }
        @{ Shape = 'as a boolean'; Value = 'true' }
        @{ Shape = 'as a fractional value'; Value = '1.0' }
        @{ Shape = 'as the integer 2'; Value = '2' }
    ) {
        $errors = Get-ConfigErrorFor -Text ('{"version":' + $Value + ',"regeneration":null}')
        $errors | Should -Contain 'version: must be the JSON integer 1'
    }

    It 'rule 3: rejects a regeneration value that is neither an object nor null' {
        $result = ConvertFrom-RegenerationConfigText -Text '{"version":1,"regeneration":[1]}'
        @($result.Errors) | Should -Contain 'regeneration: must be an object or null'
        $result.Config | Should -BeNullOrEmpty
    }

    It 'rule 4: rejects an unknown key inside regeneration' {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body '"command":["g"],"paths":["a"],"extra":1')
        $errors | Should -Contain 'regeneration.extra: unknown key'
    }

    It 'rule 4: compares key names ordinally' {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body '"command":["g"],"paths":["a"],"Unit_Gate":[["u"]]')
        $errors | Should -Contain 'regeneration.Unit_Gate: unknown key'
    }

    It 'rule 5: rejects an absent command' {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body '"paths":["a"]')
        $errors | Should -Contain 'regeneration.command: required key is absent'
    }

    It 'rule 5: rejects command <Shape>' -ForEach @(
        @{ Shape = 'that is not an array'; Value = '"gen"' }
        @{ Shape = 'that is empty'; Value = '[]' }
        @{ Shape = 'holding a non-string'; Value = '["g",1]' }
        @{ Shape = 'holding an empty string'; Value = '[""]' }
        @{ Shape = 'holding a whitespace-only string'; Value = '["  "]' }
    ) {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body ('"command":' + $Value + ',"paths":["a"]'))
        $errors | Should -Contain 'regeneration.command: must be a non-empty array of non-empty strings'
    }

    It 'rule 6: rejects an absent paths key' {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body '"command":["g"]')
        $errors | Should -Contain 'regeneration.paths: required key is absent'
    }

    It 'rule 6: rejects paths <Shape>' -ForEach @(
        @{ Shape = 'that is not an array'; Value = '"a"' }
        @{ Shape = 'that is empty'; Value = '[]' }
    ) {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body ('"command":["g"],"paths":' + $Value))
        $errors | Should -Contain 'regeneration.paths: must be a non-empty array'
    }

    It 'rule 6: rejects a non-string paths element' {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body '"command":["g"],"paths":["a",3]')
        $errors | Should -Contain 'regeneration.paths[1]: must be a string'
    }

    It 'rule 7: rejects a pattern <Shape>' -ForEach @(
        @{ Shape = 'that is empty'; Value = ''; Reason = 'pattern is empty' }
        @{ Shape = 'with a leading slash'; Value = '/gen/**'; Reason = 'pattern begins with a forward slash' }
        @{ Shape = 'with a backslash'; Value = 'gen\\x.json'; Reason = 'pattern contains a backslash' }
        @{ Shape = 'with a drive-letter colon'; Value = 'C:gen'; Reason = 'pattern begins with a drive letter and colon' }
        @{ Shape = 'with an empty segment'; Value = 'gen//x'; Reason = 'pattern contains an empty segment' }
        @{ Shape = 'with a dot segment'; Value = 'gen/./x'; Reason = 'pattern contains a . segment' }
        @{ Shape = 'with a dot-dot segment'; Value = 'gen/../x'; Reason = 'pattern contains a .. segment' }
        @{ Shape = 'with a square bracket'; Value = 'gen/[ab].json'; Reason = 'pattern contains a square bracket' }
    ) {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body ('"command":["g"],"paths":["ok/**","' + $Value + '"]'))
        $errors | Should -Contain "regeneration.paths[1]: $Reason"
        $errors.Count | Should -Be 1
    }

    It 'rule 8: rejects an idempotency_check <Shape>' -ForEach @(
        @{ Shape = 'that is empty'; Value = '[]' }
        @{ Shape = 'holding an empty string'; Value = '[""]' }
        @{ Shape = 'that is not an array'; Value = '"c"' }
    ) {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body ('"command":["g"],"paths":["a"],"idempotency_check":' + $Value))
        $errors | Should -Contain 'regeneration.idempotency_check: must be a non-empty array of non-empty strings'
    }

    It 'rule 9: rejects a unit_gate <Shape>' -ForEach @(
        @{ Shape = 'that is empty'; Value = '[]' }
        @{ Shape = 'holding a string instead of an argv'; Value = '["u"]' }
        @{ Shape = 'holding an empty argv'; Value = '[[]]' }
        @{ Shape = 'holding a non-string argv element'; Value = '[["u",1]]' }
    ) {
        $errors = Get-ConfigErrorFor -Text (Get-RegenerationTextWith -Body ('"command":["g"],"paths":["a"],"unit_gate":' + $Value))
        $errors | Should -Contain 'regeneration.unit_gate: must be a non-empty array of non-empty arrays of non-empty strings'
    }

    It 'accumulates errors across rules in rule order' {
        $text = '{"version":"1","regeneration":{"extra":true,"command":[],"paths":["/abs"],"idempotency_check":[],"unit_gate":[]}}'
        $errors = Get-ConfigErrorFor -Text $text
        $errors | Should -Be @(
            'version: must be the JSON integer 1'
            'regeneration.extra: unknown key'
            'regeneration.command: must be a non-empty array of non-empty strings'
            'regeneration.paths[0]: pattern begins with a forward slash'
            'regeneration.idempotency_check: must be a non-empty array of non-empty strings'
            'regeneration.unit_gate: must be a non-empty array of non-empty arrays of non-empty strings'
        )
    }

    It 'keeps an invalid regeneration object as Config so the caller can report config_invalid' {
        $result = ConvertFrom-RegenerationConfigText -Text '{"version":1,"regeneration":{"command":[]}}'
        $result.Config | Should -Not -BeNullOrEmpty
        @($result.Errors).Count | Should -Be 2
    }
}
