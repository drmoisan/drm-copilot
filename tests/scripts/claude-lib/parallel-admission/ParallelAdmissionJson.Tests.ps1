<#
.SYNOPSIS
    Behavioral tests for the parallel admission JSON module (issue #1047).

.DESCRIPTION
    Covers .claude/lib/parallel-admission/ParallelAdmissionJson.psm1, which reads
    JSON with System.Text.Json and writes it with ordinally sorted keys and LF
    line endings. Every function is pure, so the suite passes in-memory text and
    values only: no file is read or created, no process is started, and no clock
    is read.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-admission -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/ParallelAdmissionJson.psm1') -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name ParallelAdmissionJson -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-ParallelAdmissionJson' {
    It 'keeps object keys that differ only in case distinct' {
        # Act
        $value = ConvertFrom-ParallelAdmissionJson -Text '{"Key": 1, "key": 2}'

        # Assert: an ordinal table holds both keys; a case-insensitive one would collide.
        $value.Count | Should -Be 2
        $value['Key'] | Should -Be 1
        $value['key'] | Should -Be 2
    }

    It 'returns an integer as Int64 and a fraction as Double' {
        $value = ConvertFrom-ParallelAdmissionJson -Text '{"whole": 7, "fraction": 2.5}'

        $value['whole'] | Should -BeOfType ([long])
        $value['whole'] | Should -Be 7
        $value['fraction'] | Should -BeOfType ([double])
        $value['fraction'] | Should -Be 2.5
    }

    It 'maps <Text> to <Expected>' -ForEach @(
        @{ Text = 'true'; Expected = $true }
        @{ Text = 'false'; Expected = $false }
    ) {
        $value = ConvertFrom-ParallelAdmissionJson -Text "{`"flag`": $Text}"

        $value['flag'] | Should -BeOfType ([bool])
        $value['flag'] | Should -Be $Expected
    }

    It 'maps null to a null value' {
        $value = ConvertFrom-ParallelAdmissionJson -Text '{"absent": null}'

        $value.ContainsKey('absent') | Should -BeTrue
        $value['absent'] | Should -BeNullOrEmpty
    }

    It 'returns an array root as one array without unrolling it' {
        # Act: a one-member array root is the case the pipeline would unroll.
        $value = ConvertFrom-ParallelAdmissionJson -Text '[[1101]]'

        # Assert
        , $value | Should -BeOfType ([System.Object[]])
        $value.Count | Should -Be 1
        , $value[0] | Should -BeOfType ([System.Object[]])
        $value[0][0] | Should -Be 1101
    }

    It 'keeps a timestamp string as a string' {
        $value = ConvertFrom-ParallelAdmissionJson -Text '{"recorded_at": "2026-11-03T10-00", "iso": "2026-11-03T10:00:00Z"}'

        $value['recorded_at'] | Should -BeOfType ([string])
        $value['recorded_at'] | Should -BeExactly '2026-11-03T10-00'
        $value['iso'] | Should -BeOfType ([string])
        $value['iso'] | Should -BeExactly '2026-11-03T10:00:00Z'
    }
}

Describe 'ConvertTo-ParallelAdmissionJson' {
    It 'sorts keys ordinally at every depth' {
        # Arrange: uppercase sorts before lowercase under the ordinal comparer.
        $value = [ordered]@{ zeta = 1; Alpha = [ordered]@{ b = 2; C = 3; a = 4 } }

        # Act
        $text = ConvertTo-ParallelAdmissionJson -Value $value

        # Assert
        $text | Should -BeExactly "{`n  `"Alpha`": {`n    `"C`": 3,`n    `"a`": 4,`n    `"b`": 2`n  },`n  `"zeta`": 1`n}"
    }

    It 'serializes a pscustomobject like a hashtable' {
        $fromObject = ConvertTo-ParallelAdmissionJson -Value ([pscustomobject]@{ b = 'x'; a = 1 })
        $fromTable = ConvertTo-ParallelAdmissionJson -Value @{ a = 1; b = 'x' }

        $fromObject | Should -BeExactly $fromTable
    }

    It 'round-trips integers, doubles, booleans, nulls, and nested arrays' {
        # Arrange
        $text = '{"flags": [true, false], "nested": [[1, 2], []], "none": null, "ratio": 0.25, "size": 9007199254740993}'

        # Act
        $value = ConvertFrom-ParallelAdmissionJson -Text (ConvertTo-ParallelAdmissionJson -Value (ConvertFrom-ParallelAdmissionJson -Text $text))

        # Assert
        $value['size'] | Should -Be 9007199254740993
        $value['size'] | Should -BeOfType ([long])
        $value['ratio'] | Should -Be 0.25
        $value['flags'] | Should -Be @($true, $false)
        $value['none'] | Should -BeNullOrEmpty
        $value['nested'].Count | Should -Be 2
        $value['nested'][0] | Should -Be @(1, 2)
        $value['nested'][1].Count | Should -Be 0
    }

    It 'writes no carriage return' {
        $text = ConvertTo-ParallelAdmissionJson -Value @{ items = @(@{ a = 1 }, @{ b = 2 }) }

        $text.Contains("`r") | Should -BeFalse
        $text.Contains("`n") | Should -BeTrue
    }

    It 'throws for a value it cannot serialize' {
        { ConvertTo-ParallelAdmissionJson -Value @{ when = [datetime]::new(2026, 11, 3) } } | Should -Throw -ExpectedMessage 'ConvertTo-ParallelAdmissionJson cannot serialize*'
    }
}
