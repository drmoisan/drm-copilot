#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for the documentation role token contract (.claude/hooks/docs-role-contract.ps1, issue #1037).

.DESCRIPTION
    Every case parses in-memory role output. File existence goes through a scriptblock passed as
    -TestFile, so no case touches the file system. AfterAll removes the dot-sourced functions.
#>

BeforeDiscovery {
    # Literal role-by-token table: the three common tokens for each role plus that role's own tokens.
    $script:TokenRows = @(
        foreach ($role in 'docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer') {
            foreach ($token in 'docs-role', 'docs-result', 'docs-findings') { @{ Role = $role; Token = $token } }
        }
        @{ Role = 'docs-architect'; Token = 'docs-profile' }
        @{ Role = 'docs-architect'; Token = 'docs-snapshot' }
        @{ Role = 'docs-architect'; Token = 'docs-pages-planned' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written' }
        @{ Role = 'docs-author'; Token = 'docs-check-exit-code' }
        @{ Role = 'docs-reconciler'; Token = 'docs-ledger-operations' }
        @{ Role = 'docs-reconciler'; Token = 'docs-update-ledger-exit-code' }
        @{ Role = 'docs-reconciler'; Token = 'docs-elements-reconciled' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-mode' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-revision' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-exit-code' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-receipt-id' }
    )
    $script:RoleRows = @(
        @{ Role = 'docs-architect' }, @{ Role = 'docs-author' }, @{ Role = 'docs-reconciler' }, @{ Role = 'docs-coverage-reviewer' }
    )
}

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/docs-role-contract.ps1')
    $script:ContractFunctions = @(
        'Get-DocsRoleName', 'Get-DocsRoleRequiredToken', 'ConvertFrom-DocsRoleOutput', 'Test-DocsRoleRelativePath',
        'Get-DocsRoleIntegerFinding', 'Get-DocsRolePathFinding', 'Get-DocsRoleSpecificFinding', 'Test-DocsRoleOutput'
    )
    $script:Element = 'cli-command-' + ('a' * 64)
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    $script:ValidOutput = @{
        'docs-architect'         = "Planned the pages.`ndocs-role: docs-architect`ndocs-result: PASS`ndocs-findings: 0`ndocs-profile: docs/documentation-estate/docs-profile.json`ndocs-snapshot: docs/documentation-estate/inventory.json`ndocs-pages-planned: 3`n`n## Information Architecture`n`n- docs/guide/index.md"
        'docs-author'            = "docs-role: docs-author`ndocs-result: PASS`ndocs-findings: 0`ndocs-pages-written: docs/guide/index.md, docs/guide/install.md`ndocs-check-exit-code: 0"
        'docs-reconciler'        = "docs-role: docs-reconciler`ndocs-result: PASS`ndocs-findings: 0`ndocs-ledger-operations: 2`ndocs-update-ledger-exit-code: 0`ndocs-elements-reconciled: $script:Element"
        'docs-coverage-reviewer' = "docs-role: docs-coverage-reviewer`ndocs-result: PASS`ndocs-findings: 0`ndocs-validate-mode: docs-complete`ndocs-revision: $script:Revision`ndocs-validate-exit-code: 0`ndocs-receipt-id: none"
    }
    $script:AllExist = { param([string] $Path) $null -ne $Path }

    function Get-DocsRoleOutputWithValue {
        # Returns the valid output of a role with one token line replaced by the given value.
        param([string] $Role, [string] $Token, [AllowEmptyString()] [string] $Value)
        $lines = foreach ($line in ($script:ValidOutput[$Role] -split "`n")) { if ($line.StartsWith("${Token}:")) { "${Token}: $Value" } else { $line } }
        return ($lines -join "`n")
    }

    function Get-DocsRoleOutputWithoutToken {
        # Returns the valid output of a role without the line that carries the given token.
        param([string] $Role, [string] $Token)
        return ((@($script:ValidOutput[$Role] -split "`n") | Where-Object { -not $_.StartsWith("${Token}:") }) -join "`n")
    }
}

AfterAll {
    foreach ($name in $script:ContractFunctions + 'Get-DocsRoleOutputWithValue', 'Get-DocsRoleOutputWithoutToken') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
}

Describe 'docs-role-contract.ps1 role names and tokens' {
    It 'names exactly the four documentation roles' {
        # Act
        $roles = Get-DocsRoleName

        # Assert
        $roles | Should -Be @('docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer')
    }

    It 'lists the common tokens first and the role tokens of <Role>' -ForEach $script:RoleRows {
        # Act
        $tokens = @(Get-DocsRoleRequiredToken -Role $Role)

        # Assert
        $tokens[0..2] | Should -Be @('docs-role', 'docs-result', 'docs-findings')
        $tokens.Count | Should -BeGreaterThan 4
    }

    It 'throws an ArgumentException for an unknown role' {
        # Act / Assert
        { Get-DocsRoleRequiredToken -Role 'Docs-Author' } | Should -Throw -ExceptionType ([System.ArgumentException])
    }
}

Describe 'ConvertFrom-DocsRoleOutput' {
    It 'parses token lines with CRLF endings and trims trailing whitespace' {
        # Act
        $parsed = ConvertFrom-DocsRoleOutput -Text "intro`r`ndocs-result: PASS  `r`ndocs-findings:3`r`n"

        # Assert
        $parsed.Tokens['docs-result'] | Should -Be 'PASS'
        $parsed.Tokens['docs-findings'] | Should -Be '3'
        $parsed.Duplicates.Count | Should -Be 0
    }

    It 'ignores indented, uppercase and non-docs lines' {
        # Act
        $parsed = ConvertFrom-DocsRoleOutput -Text "  docs-result: PASS`nDOCS-RESULT: FAIL`nresult: PASS`n- docs-findings: 1"

        # Assert
        $parsed.Tokens.Count | Should -Be 0
    }

    It 'keeps the first value of a duplicated token and reports it once' {
        # Act
        $parsed = ConvertFrom-DocsRoleOutput -Text "docs-result: PASS`ndocs-result: FAIL`ndocs-result: BLOCKED"

        # Assert
        $parsed.Tokens['docs-result'] | Should -Be 'PASS'
        $parsed.Duplicates | Should -Be @('docs-result')
    }

    It 'returns an empty map for null text' {
        # Act
        $parsed = ConvertFrom-DocsRoleOutput -Text $null

        # Assert
        $parsed.Tokens.Count | Should -Be 0
    }
}

Describe 'Test-DocsRoleRelativePath' {
    It 'returns <Expected> for <Value>' -ForEach @(
        @{ Value = 'docs/guide/index.md'; Expected = $true }
        @{ Value = 'README.md'; Expected = $true }
        @{ Value = ''; Expected = $false }
        @{ Value = '/docs/a.md'; Expected = $false }
        @{ Value = 'docs\a.md'; Expected = $false }
        @{ Value = 'c:/docs/a.md'; Expected = $false }
        @{ Value = 'https://example.com/a.md'; Expected = $false }
        @{ Value = 'docs/../a.md'; Expected = $false }
        @{ Value = './a.md'; Expected = $false }
        @{ Value = 'docs//a.md'; Expected = $false }
    ) {
        # Act / Assert
        Test-DocsRoleRelativePath -Value $Value | Should -Be $Expected
    }
}

Describe 'Test-DocsRoleOutput' {
    It 'accepts a complete valid output from <Role>' -ForEach $script:RoleRows {
        # Act
        $result = Test-DocsRoleOutput -Role $Role -Text $script:ValidOutput[$Role] -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        $result.Message | Should -BeNullOrEmpty
    }

    It 'blocks <Role> output missing <Token> with a repairable reason naming it' -ForEach $script:TokenRows {
        # Act
        $result = Test-DocsRoleOutput -Role $Role -Text (Get-DocsRoleOutputWithoutToken -Role $Role -Token $Token) -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message.Contains("missing $Token") | Should -BeTrue -Because $result.Message
    }

    It 'blocks <Role> output with an invalid <Token> value <Value>' -ForEach @(
        @{ Role = 'docs-author'; Token = 'docs-result'; Value = 'DONE'; Expect = 'docs-result must be PASS, FAIL or BLOCKED' }
        @{ Role = 'docs-author'; Token = 'docs-result'; Value = 'pass'; Expect = 'docs-result must be PASS, FAIL or BLOCKED' }
        @{ Role = 'docs-author'; Token = 'docs-findings'; Value = '-1'; Expect = 'docs-findings must be a non-negative integer' }
        @{ Role = 'docs-author'; Token = 'docs-findings'; Value = '1234567890'; Expect = 'docs-findings must be a non-negative integer' }
        @{ Role = 'docs-author'; Token = 'docs-role'; Value = 'docs-architect'; Expect = "docs-role 'docs-architect' does not equal" }
        @{ Role = 'docs-author'; Token = 'docs-check-exit-code'; Value = '1'; Expect = 'docs-result PASS requires docs-check-exit-code 0' }
        @{ Role = 'docs-author'; Token = 'docs-check-exit-code'; Value = '4'; Expect = 'docs-check-exit-code must be an exit code from 0 to 3' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written'; Value = '/docs/guide/index.md'; Expect = 'docs-pages-written path ''/docs/guide/index.md'' must be repository-relative' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written'; Value = 'docs/guide/index.json'; Expect = 'docs-pages-written path ''docs/guide/index.json'' must end with .md' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written'; Value = 'none'; Expect = 'docs-pages-written may be none only when' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written'; Value = ' '; Expect = 'docs-pages-written has an empty value' }
        @{ Role = 'docs-architect'; Token = 'docs-pages-planned'; Value = 'three'; Expect = 'docs-pages-planned must be a non-negative integer' }
        @{ Role = 'docs-architect'; Token = 'docs-snapshot'; Value = 'docs\inventory.json'; Expect = 'docs-snapshot path' }
        @{ Role = 'docs-reconciler'; Token = 'docs-ledger-operations'; Value = '2.5'; Expect = 'docs-ledger-operations must be a non-negative integer' }
        @{ Role = 'docs-reconciler'; Token = 'docs-update-ledger-exit-code'; Value = '2'; Expect = 'docs-result PASS requires docs-update-ledger-exit-code 0' }
        @{ Role = 'docs-reconciler'; Token = 'docs-elements-reconciled'; Value = ('mcp-tool-' + ('a' * 64)); Expect = 'does not match the element-id pattern' }
        @{ Role = 'docs-reconciler'; Token = 'docs-elements-reconciled'; Value = ('cli-command-' + ('A' * 64)); Expect = 'does not match the element-id pattern' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-mode'; Value = 'complete'; Expect = 'docs-validate-mode must be profile, ledger, matrix or docs-complete' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-revision'; Value = ('a' * 39); Expect = 'docs-revision must be 40 or 64 lowercase hexadecimal' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-revision'; Value = ('A' * 40); Expect = 'docs-revision must be 40 or 64 lowercase hexadecimal' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-receipt-id'; Value = 'receipt 1'; Expect = 'docs-receipt-id must be a receipt id without whitespace' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-exit-code'; Value = '1'; Expect = 'docs-result PASS requires docs-validate-exit-code 0' }
    ) {
        # Act
        $result = Test-DocsRoleOutput -Role $Role -Text (Get-DocsRoleOutputWithValue -Role $Role -Token $Token -Value $Value) -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message.Contains($Expect) | Should -BeTrue -Because $result.Message
    }

    It 'blocks a page that the -TestFile seam reports as absent' {
        # Arrange
        $testFile = { param([string] $Path) $Path -ne 'docs/guide/install.md' }

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-author' -Text $script:ValidOutput['docs-author'] -TestFile $testFile

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.Contains("docs-pages-written path 'docs/guide/install.md' does not exist") | Should -BeTrue -Because $result.Message
    }

    It 'blocks an architect profile path that the -TestFile seam reports as absent' {
        # Arrange
        $testFile = { param([string] $Path) $Path -ne 'docs/documentation-estate/docs-profile.json' }

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-architect' -Text $script:ValidOutput['docs-architect'] -TestFile $testFile

        # Assert
        $result.Message.Contains('docs-profile path') | Should -BeTrue -Because $result.Message
    }

    It 'blocks a duplicated token and names it' {
        # Act
        $result = Test-DocsRoleOutput -Role 'docs-author' -Text ($script:ValidOutput['docs-author'] + "`ndocs-findings: 2") -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.Contains('docs-findings is reported more than once') | Should -BeTrue -Because $result.Message
    }

    It 'blocks an architect PASS without the Information Architecture section' {
        # Arrange
        $text = $script:ValidOutput['docs-architect'].Replace('## Information Architecture', '## Plan')

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-architect' -Text $text -TestFile $script:AllExist

        # Assert
        $result.Message.Contains('docs-result PASS requires a ## Information Architecture section') | Should -BeTrue -Because $result.Message
    }

    It 'accepts an architect FAIL without the Information Architecture section' {
        # Arrange
        $text = (Get-DocsRoleOutputWithValue -Role 'docs-architect' -Token 'docs-result' -Value 'FAIL').Replace('## Information Architecture', '## Plan')

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-architect' -Text $text -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'accepts an author BLOCKED report with docs-pages-written none and a non-zero check exit code' {
        # Arrange
        $text = (Get-DocsRoleOutputWithValue -Role 'docs-author' -Token 'docs-result' -Value 'BLOCKED') -replace 'docs-pages-written: .*', 'docs-pages-written: none' -replace 'docs-check-exit-code: 0', 'docs-check-exit-code: 3'

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-author' -Text $text -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'accepts a reviewer FAIL report with validate exit code 1 and a receipt id' {
        # Arrange
        $text = (Get-DocsRoleOutputWithValue -Role 'docs-coverage-reviewer' -Token 'docs-result' -Value 'FAIL') -replace 'docs-validate-exit-code: 0', 'docs-validate-exit-code: 1' -replace 'docs-receipt-id: none', 'docs-receipt-id: receipt-20261107'

        # Act
        $result = Test-DocsRoleOutput -Role 'docs-coverage-reviewer' -Text $text -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'accepts a reconciler report with docs-elements-reconciled none and a 64-character revision reviewer report' {
        # Arrange
        $reconciler = Get-DocsRoleOutputWithValue -Role 'docs-reconciler' -Token 'docs-elements-reconciled' -Value 'none'
        $reviewer = Get-DocsRoleOutputWithValue -Role 'docs-coverage-reviewer' -Token 'docs-revision' -Value ('b' * 64)

        # Act
        $first = Test-DocsRoleOutput -Role 'docs-reconciler' -Text $reconciler -TestFile $script:AllExist
        $second = Test-DocsRoleOutput -Role 'docs-coverage-reviewer' -Text $reviewer -TestFile $script:AllExist

        # Assert
        $first.Ok | Should -BeTrue -Because $first.Message
        $second.Ok | Should -BeTrue -Because $second.Message
    }

    It 'returns a non-repairable result for an unknown role' {
        # Act
        $result = Test-DocsRoleOutput -Role 'atomic-executor' -Text 'docs-role: atomic-executor' -TestFile $script:AllExist

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeFalse
        $result.Message.Contains("unknown documentation role 'atomic-executor'") | Should -BeTrue
    }

    It 'names every required token when the output is empty' {
        # Act
        $result = Test-DocsRoleOutput -Role 'docs-coverage-reviewer' -Text '' -TestFile $script:AllExist

        # Assert
        foreach ($token in (Get-DocsRoleRequiredToken -Role 'docs-coverage-reviewer')) { $result.Message.Contains("missing $token") | Should -BeTrue -Because $token }
    }
}
