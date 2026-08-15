#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for the shared checkpoint-value primitives of the parity family.

.DESCRIPTION
    Exercises .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1,
    the sibling helper module created under the plan's pre-authorized split. The
    primitives are the single implementation every ported check family depends on,
    so their Python-equivalence contracts are pinned here directly: the JSON shape
    predicates, the absent-versus-null member accessor, Python-ordinal key sorting,
    Python zero-equivalence (under which boolean False equals 0), and the str() and
    repr() interpolation renderers used by the inventory error templates.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port must
    reproduce these Python-equivalence contracts exactly, because every ported
    error string is rendered through them.

    Every fixture is an in-memory value or JSON string. The suite creates no
    temporary files, starts no external process, and never mutates $PSVersionTable
    or $env:PATH.
#>

param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCheckpointValue.psm1') -Force
}

Describe 'Checkpoint shape predicates' {

    It 'classifies a JSON object as an object' {
        Test-CheckpointObjectValue -Value ('{"a":1}' | ConvertFrom-Json) | Should -BeTrue
    }

    It 'does not classify a JSON array as an object' {
        Test-CheckpointObjectValue -Value (ConvertFrom-Json -InputObject '[1]' -NoEnumerate) | Should -BeFalse
    }

    It 'does not classify null as an object' {
        Test-CheckpointObjectValue -Value $null | Should -BeFalse
    }

    It 'classifies a JSON array as a list' {
        Test-CheckpointListValue -Value (ConvertFrom-Json -InputObject '[1,2]' -NoEnumerate) | Should -BeTrue
    }

    It 'does not classify a string as a list, matching Python isinstance' {
        Test-CheckpointListValue -Value 'abc' | Should -BeFalse
    }

    It 'does not classify a JSON object as a list' {
        Test-CheckpointListValue -Value ('{"a":1}' | ConvertFrom-Json) | Should -BeFalse
    }
}

Describe 'Checkpoint member-name enumeration' {

    It 'lists the member names of an object' {
        Get-CheckpointObjectMemberName -Owner ('{"a":1,"b":2}' | ConvertFrom-Json) |
            Should -Be @('a', 'b')
    }

    It 'returns an empty list for an empty object instead of throwing under strict mode' {
        @(Get-CheckpointObjectMemberName -Owner ('{}' | ConvertFrom-Json)).Count | Should -Be 0
    }

    It 'returns an empty list for a non-object value' {
        @(Get-CheckpointObjectMemberName -Owner 'scalar').Count | Should -Be 0
    }
}

Describe 'Checkpoint member accessor' {

    It 'reports a present member with its value' {
        $result = Get-CheckpointObjectMember -Owner ('{"a":7}' | ConvertFrom-Json) -Name 'a'
        $result.Present | Should -BeTrue
        $result.Value | Should -Be 7
    }

    It 'distinguishes a present null member from an absent one' {
        $present = Get-CheckpointObjectMember -Owner ('{"a":null}' | ConvertFrom-Json) -Name 'a'
        $absent = Get-CheckpointObjectMember -Owner ('{"a":null}' | ConvertFrom-Json) -Name 'b'
        $present.Present | Should -BeTrue
        $absent.Present | Should -BeFalse
    }

    It 'reports a member as absent when the owner is not an object' {
        (Get-CheckpointObjectMember -Owner 'scalar' -Name 'a').Present | Should -BeFalse
    }

    It 'reports a member as absent when the owner is null' {
        (Get-CheckpointObjectMember -Owner $null -Name 'a').Present | Should -BeFalse
    }
}

Describe 'Ordinal key sorting' {

    It 'orders uppercase before lowercase, matching Python sorted()' {
        Get-CheckpointOrdinalSortedName -Name @('weird', 'Alpha', 'beta') |
            Should -Be @('Alpha', 'beta', 'weird')
    }

    It 'returns an empty result for an empty input' {
        @(Get-CheckpointOrdinalSortedName -Name @()).Count | Should -Be 0
    }
}

Describe 'Python zero equivalence' {

    It 'treats integer 0 as zero-equivalent' {
        Test-PythonZeroEquivalent -Value (('{"n":0}' | ConvertFrom-Json).n) | Should -BeTrue
    }

    It 'treats float 0.0 as zero-equivalent' {
        Test-PythonZeroEquivalent -Value (('{"n":0.0}' | ConvertFrom-Json).n) | Should -BeTrue
    }

    It 'treats boolean false as zero-equivalent, matching Python False == 0' {
        Test-PythonZeroEquivalent -Value $false | Should -BeTrue
    }

    It 'does not treat boolean true as zero-equivalent' {
        Test-PythonZeroEquivalent -Value $true | Should -BeFalse
    }

    It 'does not treat a non-zero number as zero-equivalent' {
        Test-PythonZeroEquivalent -Value 3 | Should -BeFalse
    }

    It 'does not treat null as zero-equivalent, matching Python None != 0' {
        Test-PythonZeroEquivalent -Value $null | Should -BeFalse
    }

    It 'does not treat the string "0" as zero-equivalent' {
        Test-PythonZeroEquivalent -Value '0' | Should -BeFalse
    }
}

Describe 'Python value equality' {

    It 'treats null as equal only to null' {
        Test-PythonValueEqual -Actual $null -Expected $null | Should -BeTrue
        Test-PythonValueEqual -Actual '' -Expected $null | Should -BeFalse
        Test-PythonValueEqual -Actual $null -Expected 'x' | Should -BeFalse
    }

    It 'compares booleans by value' {
        Test-PythonValueEqual -Actual $true -Expected $true | Should -BeTrue
        Test-PythonValueEqual -Actual $false -Expected $true | Should -BeFalse
    }

    It 'never equates a boolean with its string rendering' {
        Test-PythonValueEqual -Actual 'True' -Expected $true | Should -BeFalse
    }

    It 'compares strings case-sensitively, unlike PowerShell -eq' {
        Test-PythonValueEqual -Actual 'powershell' -Expected 'powershell' | Should -BeTrue
        Test-PythonValueEqual -Actual 'PowerShell' -Expected 'powershell' | Should -BeFalse
    }

    It 'never equates a string with a number' {
        Test-PythonValueEqual -Actual '2' -Expected 2 | Should -BeFalse
    }

    It 'compares numbers numerically' {
        Test-PythonValueEqual -Actual (('{"n":2}' | ConvertFrom-Json).n) -Expected 2 | Should -BeTrue
        Test-PythonValueEqual -Actual (('{"n":3}' | ConvertFrom-Json).n) -Expected 2 | Should -BeFalse
    }

    It 'compares lists element-wise and in order' {
        $actual = ConvertFrom-Json -InputObject '["a","b"]' -NoEnumerate
        Test-PythonValueEqual -Actual $actual -Expected ([string[]]@('a', 'b')) | Should -BeTrue
        Test-PythonValueEqual -Actual $actual -Expected ([string[]]@('b', 'a')) | Should -BeFalse
    }

    It 'reports lists of differing length as unequal' {
        $actual = ConvertFrom-Json -InputObject '["a"]' -NoEnumerate
        Test-PythonValueEqual -Actual $actual -Expected ([string[]]@('a', 'b')) | Should -BeFalse
    }

    It 'never equates a list with a scalar' {
        $actual = ConvertFrom-Json -InputObject '["a"]' -NoEnumerate
        Test-PythonValueEqual -Actual $actual -Expected 'a' | Should -BeFalse
    }

    It 'compares mappings by member name and value, order-independently' {
        $actual = '{"a":1,"b":"x"}' | ConvertFrom-Json
        $expected = '{"b":"x","a":1}' | ConvertFrom-Json
        Test-PythonValueEqual -Actual $actual -Expected $expected | Should -BeTrue
    }

    It 'reports mappings with differing member sets as unequal' {
        $actual = '{"a":1}' | ConvertFrom-Json
        $expected = '{"a":1,"b":2}' | ConvertFrom-Json
        Test-PythonValueEqual -Actual $actual -Expected $expected | Should -BeFalse
        Test-PythonValueEqual -Actual ('{"c":1}' | ConvertFrom-Json) -Expected ('{"a":1}' | ConvertFrom-Json) | Should -BeFalse
    }

    It 'reports mappings with a differing member value as unequal' {
        Test-PythonValueEqual -Actual ('{"a":1}' | ConvertFrom-Json) -Expected ('{"a":2}' | ConvertFrom-Json) | Should -BeFalse
    }
}

Describe 'Python str() rendering' {

    It 'renders null as None' {
        ConvertTo-PythonDisplayText -Value $null | Should -Be 'None'
    }

    It 'renders booleans with Python capitalization' {
        ConvertTo-PythonDisplayText -Value $true | Should -Be 'True'
        ConvertTo-PythonDisplayText -Value $false | Should -Be 'False'
    }

    It 'renders a string bare, without quotes' {
        ConvertTo-PythonDisplayText -Value 'C9' | Should -Be 'C9'
    }

    It 'renders an integer without a decimal separator' {
        ConvertTo-PythonDisplayText -Value (('{"n":42}' | ConvertFrom-Json).n) | Should -Be '42'
    }

    It 'renders a list literal whose elements use repr()' {
        ConvertTo-PythonDisplayText -Value (ConvertFrom-Json -InputObject '["a",1]' -NoEnumerate) | Should -Be "['a', 1]"
    }

    It 'renders an empty list literal' {
        ConvertTo-PythonDisplayText -Value (ConvertFrom-Json -InputObject '[]' -NoEnumerate) | Should -Be '[]'
    }

    It 'renders a dict literal with repr() keys and values' {
        ConvertTo-PythonDisplayText -Value ('{"a":1}' | ConvertFrom-Json) | Should -Be "{'a': 1}"
    }
}

Describe 'Python repr() rendering' {

    It 'quotes a string with single quotes' {
        ConvertTo-PythonReprText -Value 'S5_atomic_execution' | Should -Be "'S5_atomic_execution'"
    }

    It 'escapes an embedded backslash' {
        ConvertTo-PythonReprText -Value 'a\b' | Should -Be "'a\\b'"
    }

    It 'escapes an embedded single quote (documented quote-selection divergence)' {
        ConvertTo-PythonReprText -Value "it's" | Should -Be "'it\'s'"
    }

    It 'renders null as None, matching str()' {
        ConvertTo-PythonReprText -Value $null | Should -Be 'None'
    }

    It 'renders booleans identically to str()' {
        ConvertTo-PythonReprText -Value $true | Should -Be 'True'
    }

    It 'renders a number identically to str()' {
        ConvertTo-PythonReprText -Value (('{"n":7}' | ConvertFrom-Json).n) | Should -Be '7'
    }
}
