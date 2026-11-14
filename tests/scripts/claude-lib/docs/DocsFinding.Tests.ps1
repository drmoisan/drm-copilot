#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsFinding.psm1.

.DESCRIPTION
    Covers the finding grammar, sorting and de-duplication, the finding bound, the command result,
    the canonical -Json envelope (ok rule, null command, byte identity) and the text report summary
    line. All inputs are in memory; no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop

    function New-TestFinding {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Code = 'DOCS_TEST', [string] $Severity = 'error', [string] $Pointer = '', [string] $ArtifactPath, [string] $Message = 'Message text.')
        New-DocsFinding -Code $Code -Severity $Severity -Message $Message -NextAction 'Act on it.' -Pointer $Pointer -ArtifactPath $ArtifactPath
    }
}

AfterAll {
    Remove-Module -Name DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'New-DocsFinding' {
    It 'returns exactly the eight docs common finding keys' {
        # Act
        $finding = New-DocsFinding -Code 'DOCS_X' -Severity 'warning' -Message 'm' -NextAction 'n' -ArtifactPath 'docs/a.json' -Pointer '/a/0'

        # Assert
        @($finding.Keys) | Should -Be @('code', 'severity', 'artifact_path', 'pointer', 'related_ids', 'related_paths', 'message', 'next_action')
        $finding.artifact_path | Should -BeExactly 'docs/a.json'
        $finding.pointer | Should -BeExactly '/a/0'
        $finding.related_ids.Count | Should -Be 0
    }

    It 'sets artifact_path to null when no path is given' {
        # Act
        $finding = New-DocsFinding -Code 'DOCS_X' -Severity 'info' -Message 'm' -NextAction 'n'

        # Assert
        $null -eq $finding.artifact_path | Should -BeTrue
        $finding.pointer | Should -BeExactly ''
    }

    It 'sorts and de-duplicates related identifiers and paths by ordinal order' {
        # Act
        $finding = New-DocsFinding -Code 'DOCS_X' -Severity 'error' -Message 'm' -NextAction 'n' -RelatedId @('b', 'a', 'b') -RelatedPath @('src/z.py', 'src/a.py', 'src/z.py')

        # Assert
        $finding.related_ids | Should -Be @('a', 'b')
        $finding.related_paths | Should -Be @('src/a.py', 'src/z.py')
    }

    It 'throws for an argument outside its grammar: <Name>' -TestCases @(
        @{ Name = 'lower-case code'; Splat = @{ Code = 'docs_x'; Severity = 'error'; Message = 'm'; NextAction = 'n' } }
        @{ Name = 'unknown severity'; Splat = @{ Code = 'DOCS_X'; Severity = 'fatal'; Message = 'm'; NextAction = 'n' } }
        @{ Name = 'pointer without slash'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; Pointer = 'a' } }
        @{ Name = 'pointer with bad escape'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; Pointer = '/a~2' } }
        @{ Name = 'blank message'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = ' '; NextAction = 'n' } }
        @{ Name = 'blank next action'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = '' } }
        @{ Name = 'absolute artifact path'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; ArtifactPath = '/etc/a.json' } }
        @{ Name = 'parent artifact path'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; ArtifactPath = '../a.json' } }
        @{ Name = 'upper-case related id'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; RelatedId = @('Bad') } }
        @{ Name = 'backslash related path'; Splat = @{ Code = 'DOCS_X'; Severity = 'error'; Message = 'm'; NextAction = 'n'; RelatedPath = @('src\a.py') } }
    ) {
        # Act / Assert: Pester supplies $Splat from the test case.
        { New-DocsFinding @Splat } | Should -Throw -ExpectedMessage 'DOCS_FINDING_INVALID*'
    }
}

Describe 'Get-DocsChildPointer' {
    It 'escapes tilde before slash and accepts integer parts' {
        # Act / Assert
        Get-DocsChildPointer -Pointer '' -Part 'a/b~c' | Should -BeExactly '/a~1b~0c'
        Get-DocsChildPointer -Pointer '/items' -Part 3 | Should -BeExactly '/items/3'
    }
}

Describe 'Get-DocsOrderedFinding' {
    It 'sorts by artifact path, pointer and code, and removes exact duplicates' {
        # Arrange
        $first = New-TestFinding -Code 'DOCS_B' -Pointer '/b' -ArtifactPath 'a.json'
        $second = New-TestFinding -Code 'DOCS_A' -Pointer '/b' -ArtifactPath 'a.json'
        $third = New-TestFinding -Code 'DOCS_Z' -Pointer '/a' -ArtifactPath 'a.json'
        $pathless = New-TestFinding -Code 'DOCS_Y' -Pointer '/z'

        # Act
        $ordered = Get-DocsOrderedFinding -Finding @($first, $second, $third, $first, $pathless)

        # Assert: a null path sorts as the empty string, so it comes first.
        $ordered.Count | Should -Be 4
        @($ordered | ForEach-Object { $_.code }) | Should -Be @('DOCS_Y', 'DOCS_Z', 'DOCS_A', 'DOCS_B')
    }

    It 'returns the same order whatever the input order' {
        # Arrange
        $items = @(
            (New-TestFinding -Code 'DOCS_A' -Severity 'warning'),
            (New-TestFinding -Code 'DOCS_A' -Severity 'error'),
            (New-TestFinding -Code 'DOCS_B' -Message 'z'),
            (New-TestFinding -Code 'DOCS_B' -Message 'a')
        )

        # Act
        $forward = Get-DocsOrderedFinding -Finding $items
        $reverse = Get-DocsOrderedFinding -Finding ($items[3], $items[2], $items[1], $items[0])

        # Assert
        (ConvertTo-DocsCanonicalJson -Value $forward) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $reverse)
        $forward[0].severity | Should -BeExactly 'error'
        $forward[2].message | Should -BeExactly 'a'
    }

    It 'bounds the findings at Limit and appends one FINDINGS_LIMIT error finding' {
        # Arrange
        $items = @(1..5 | ForEach-Object { New-TestFinding -Code ('DOCS_N' + $_) })

        # Act
        $ordered = Get-DocsOrderedFinding -Finding $items -Limit 3

        # Assert
        $ordered.Count | Should -Be 4
        @($ordered | Where-Object { $_.code -ceq 'FINDINGS_LIMIT' }).Count | Should -Be 1
        $ordered[3].code | Should -BeExactly 'FINDINGS_LIMIT'
        $ordered[3].severity | Should -BeExactly 'error'
    }

    It 'returns an empty array for no findings' {
        # Act
        $ordered = Get-DocsOrderedFinding -Finding @()

        # Assert
        $ordered.Count | Should -Be 0
    }
}

Describe 'Test-DocsFindingHasError' {
    It 'returns true exactly when an error finding exists' {
        # Act / Assert
        Test-DocsFindingHasError -Finding @((New-TestFinding -Severity 'warning'), (New-TestFinding -Severity 'error')) | Should -BeTrue
        Test-DocsFindingHasError -Finding @((New-TestFinding -Severity 'warning'), (New-TestFinding -Severity 'info')) | Should -BeFalse
        Test-DocsFindingHasError -Finding @() | Should -BeFalse
    }
}

Describe 'New-DocsCommandResult and ConvertTo-DocsEnvelopeText' {
    It 'renders the envelope keys command, exit_code, findings, ok and result' {
        # Arrange
        $result = New-DocsCommandResult -Command 'validate-profile' -ExitCode 0 -Finding @() -Result ([ordered]@{ profile_path = 'p.json' })

        # Act
        $parsed = (ConvertFrom-DocsJsonText -Text (ConvertTo-DocsEnvelopeText -CommandResult $result)).Value

        # Assert
        @($parsed.Keys | Sort-Object) | Should -Be @('command', 'exit_code', 'findings', 'ok', 'result')
        $parsed['command'] | Should -BeExactly 'validate-profile'
        $parsed['findings'].Count | Should -Be 0
        $parsed['result']['profile_path'] | Should -BeExactly 'p.json'
    }

    It 'sets ok to true exactly when exit_code is 0: exit <ExitCode>' -TestCases @(
        @{ ExitCode = 0; Ok = $true }
        @{ ExitCode = 1; Ok = $false }
        @{ ExitCode = 2; Ok = $false }
        @{ ExitCode = 3; Ok = $false }
    ) {
        param($ExitCode, $Ok)

        # Act
        $text = ConvertTo-DocsEnvelopeText -CommandResult (New-DocsCommandResult -Command 'init' -ExitCode $ExitCode -Finding @())

        # Assert
        (ConvertFrom-DocsJsonText -Text $text).Value['ok'] | Should -Be $Ok
    }

    It 'serializes a null command as JSON null' {
        # Act
        $text = ConvertTo-DocsEnvelopeText -CommandResult (New-DocsCommandResult -Command $null -ExitCode 2 -Finding @((New-TestFinding -Code 'DOCS_CLI_ARGUMENTS')))

        # Assert
        $text | Should -BeLike '{"command":null,*'
        $text.EndsWith("`n") | Should -BeTrue
    }

    It 'produces byte-identical envelopes for two identical results' {
        # Arrange
        $findings = @((New-TestFinding -Code 'DOCS_B'), (New-TestFinding -Code 'DOCS_A'))

        # Act
        $first = ConvertTo-DocsEnvelopeText -CommandResult (New-DocsCommandResult -Command 'init' -ExitCode 1 -Finding $findings)
        $second = ConvertTo-DocsEnvelopeText -CommandResult (New-DocsCommandResult -Command 'init' -ExitCode 1 -Finding @($findings[1], $findings[0]))

        # Assert
        [System.Text.Encoding]::UTF8.GetBytes($first) | Should -Be ([System.Text.Encoding]::UTF8.GetBytes($second))
    }

    It 'rejects a command that is not a string' {
        # Act / Assert
        { New-DocsCommandResult -Command 5 -ExitCode 0 -Finding @() } | Should -Throw -ExpectedMessage 'DOCS_FINDING_INVALID*'
    }

    It 'keeps command-specific lines' {
        # Act
        $result = New-DocsCommandResult -Command 'init' -ExitCode 0 -Finding @() -Line @('planned: a.json')

        # Assert
        $result.Line | Should -Be @('planned: a.json')
    }
}

Describe 'ConvertTo-DocsReportText' {
    It 'writes one line per finding, the command lines, and the summary line last' {
        # Arrange
        $findings = @(
            (New-TestFinding -Code 'DOCS_E' -Severity 'error' -ArtifactPath 'p.json' -Pointer '/a' -Message 'Error text.'),
            (New-TestFinding -Code 'DOCS_W' -Severity 'warning' -Pointer '/b' -Message 'Warning text.'),
            (New-TestFinding -Code 'DOCS_I' -Severity 'info' -Message 'Info text.')
        )
        $result = New-DocsCommandResult -Command 'validate-profile' -ExitCode 1 -Finding $findings -Line @('extra line')

        # Act
        $lines = (ConvertTo-DocsReportText -CommandResult $result).TrimEnd("`n").Split("`n")

        # Assert
        $lines | Should -Contain 'error DOCS_E p.json/a: Error text.'
        $lines | Should -Contain 'warning DOCS_W /b: Warning text.'
        $lines | Should -Contain 'info DOCS_I: Info text.'
        $lines | Should -Contain 'extra line'
        $lines[-1] | Should -BeExactly 'validate-profile: exit=1 errors=1 warnings=1 infos=1'
    }

    It 'names a missing command docs in the summary line' {
        # Act
        $text = ConvertTo-DocsReportText -CommandResult (New-DocsCommandResult -Command $null -ExitCode 2 -Finding @((New-TestFinding)))

        # Assert
        $text.TrimEnd("`n").Split("`n")[-1] | Should -BeExactly 'docs: exit=2 errors=1 warnings=0 infos=0'
    }
}
