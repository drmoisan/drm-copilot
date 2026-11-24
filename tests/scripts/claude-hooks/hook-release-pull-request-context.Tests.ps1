#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pure predicates shared by the release pull-request legs (issue #1231).

.DESCRIPTION
    Dot-sources .claude/hooks/hook-release-allowance-context.ps1 (the #1201 parser and branch
    matcher) and .claude/hooks/hook-release-pull-request-context.ps1, then drives
    Get-ReleasePullRequestConfigState with in-memory reader and probe scriptblocks and
    Get-ReleasePullRequestPathDecision with in-memory allowances. No row creates a file, starts a
    process, or reads a worktree.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    . (Join-Path $script:HookRoot 'hook-release-allowance-context.ps1')
    . (Join-Path $script:HookRoot 'hook-release-pull-request-context.ps1')
    $script:Root = '/synthetic-worktrees/release'
    $script:ValidConfig = '{"schema_version":1,"allowances":[{"id":"npm","branch_patterns":["release/*"],"allowed_paths":["package.json","package-lock.json"]},{"id":"changelog","branch_patterns":["release/*"],"allowed_paths":["CHANGELOG.md"]},{"id":"hotfix","branch_patterns":["hotfix/*"],"allowed_paths":["package.json","CHANGELOG.md"]}]}'
    $script:NoDirectory = { $false }

    function Get-ReleasePullRequestTestAllowance {
        # Parse the valid configuration into allowances.
        return @((ConvertFrom-ReleaseAllowanceConfig -Text $script:ValidConfig).Allowances)
    }
}

AfterAll {
    foreach ($leaf in 'hook-release-allowance-context.ps1', 'hook-release-pull-request-context.ps1') {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:HookRoot $leaf), [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
    Remove-Item -LiteralPath 'Function:\Get-ReleasePullRequestTestAllowance' -ErrorAction SilentlyContinue
}

Describe 'Get-ReleasePullRequestConfigState (#1231)' {
    It 'returns Absent for a blank root without calling the reader (#1231)' {
        # Arrange
        $script:ReaderCalls = 0
        $reader = { $script:ReaderCalls++; 'unused' }

        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot '' -ConfigReader $reader -ContainerProbe $script:NoDirectory

        # Assert
        $state.State | Should -BeExactly 'Absent'
        $script:ReaderCalls | Should -Be 0
    }

    It 'returns Absent when the reader returns null and never probes (#1231)' {
        # Arrange
        $script:ProbeCalls = 0
        $probe = { $script:ProbeCalls++; $false }

        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader { $null } -ContainerProbe $probe

        # Assert
        $state.State | Should -BeExactly 'Absent'
        $state.Detail | Should -BeExactly ''
        $script:ProbeCalls | Should -Be 0
    }

    It 'returns Invalid when the reader throws (#1231)' {
        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader { throw 'synthetic read failure' } -ContainerProbe $script:NoDirectory

        # Assert
        $state.State | Should -BeExactly 'Invalid'
        $state.Detail | Should -BeExactly 'the file could not be read'
    }

    It 'returns Invalid with the parser detail for an invalid file (#1231)' {
        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader { '{"schema_version":2,"allowances":[]}' } -ContainerProbe $script:NoDirectory

        # Assert
        $state.State | Should -BeExactly 'Invalid'
        $state.Detail | Should -BeExactly 'schema_version is not the integer 1'
    }

    It 'returns Invalid when an allowed_paths entry is a directory (#1231)' {
        # Arrange
        $config = $script:ValidConfig
        $probe = { param([string] $Root, [string] $RelativePath) $null = $Root; $RelativePath -ceq 'CHANGELOG.md' }

        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader { $config }.GetNewClosure() -ContainerProbe $probe

        # Assert
        $state.State | Should -BeExactly 'Invalid'
        $state.Detail | Should -BeExactly "allowed_paths entry 'CHANGELOG.md' is a directory"
    }

    It 'returns Invalid when the container probe throws (#1231)' {
        # Arrange
        $config = $script:ValidConfig

        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader { $config }.GetNewClosure() -ContainerProbe { throw 'synthetic probe failure' }

        # Assert
        $state.State | Should -BeExactly 'Invalid'
        $state.Detail | Should -BeExactly "allowed_paths entry 'package.json' could not be checked"
    }

    It 'returns Valid with the parsed allowances in file order (#1231)' {
        # Arrange
        $script:ReaderRoot = ''
        $reader = { param([string] $WorktreeRoot) $script:ReaderRoot = $WorktreeRoot; $script:ValidConfig }

        # Act
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $script:Root -ConfigReader $reader -ContainerProbe $script:NoDirectory

        # Assert
        $state.State | Should -BeExactly 'Valid'
        @($state.Allowances | ForEach-Object { $_.Id }) | Should -Be @('npm', 'changelog', 'hotfix')
        $script:ReaderRoot | Should -BeExactly $script:Root
    }
}

Describe 'Get-ReleasePullRequestPathDecision (#1231)' {
    It 'allows when the first matching allowance lists every path (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1.2.3' -Path @('package.json', 'package-lock.json')

        # Assert
        $decision.Allowed | Should -BeTrue
        $decision.Failure | Should -BeExactly ''
        $decision.AllowanceId | Should -BeExactly 'npm'
    }

    It 'allows through a later candidate when an earlier one does not list every path (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1.2.3' -Path @('CHANGELOG.md')

        # Assert
        $decision.Allowed | Should -BeTrue
        $decision.AllowanceId | Should -BeExactly 'changelog'
    }

    It 'never combines the paths of two allowances (#1231)' {
        # Act: package.json is in npm and CHANGELOG.md is in changelog, but no single allowance lists both.
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1.2.3' -Path @('package.json', 'CHANGELOG.md')

        # Assert
        $decision.Allowed | Should -BeFalse
        $decision.Failure | Should -BeExactly 'PathNotAllowed'
        $decision.Detail | Should -BeExactly "'CHANGELOG.md' is not listed in allowed_paths of allowance 'npm'"
    }

    It 'considers only the allowances whose patterns match the branch (#1231)' {
        # Act: hotfix lists both paths, but its pattern does not match a release branch.
        $release = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1.2.3' -Path @('package.json', 'CHANGELOG.md')
        $hotfix = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'hotfix/v1.2.4' -Path @('package.json', 'CHANGELOG.md')

        # Assert
        $release.Allowed | Should -BeFalse
        $hotfix.Allowed | Should -BeTrue
        $hotfix.AllowanceId | Should -BeExactly 'hotfix'
    }

    It 'reports BranchNotMatched for a branch that matches no allowance (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'feature/x' -Path @('package.json')

        # Assert
        $decision.Allowed | Should -BeFalse
        $decision.Failure | Should -BeExactly 'BranchNotMatched'
        $decision.Detail | Should -BeExactly "branch 'feature/x' matches no allowance"
    }

    It 'reports BranchNotMatched for a blank branch and for no allowances (#1231)' {
        # Act
        $blank = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch '' -Path @('package.json')
        $none = Get-ReleasePullRequestPathDecision -Allowances @() -Branch 'release/v1' -Path @('package.json')

        # Assert
        $blank.Failure | Should -BeExactly 'BranchNotMatched'
        $none.Failure | Should -BeExactly 'BranchNotMatched'
    }

    It 'reports EmptyPath for an empty path list on a matching branch (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1' -Path @()

        # Assert
        $decision.Allowed | Should -BeFalse
        $decision.Failure | Should -BeExactly 'EmptyPath'
    }

    It 'compares paths case-sensitively, so Package.json is not package.json (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1' -Path @('Package.json')

        # Assert
        $decision.Allowed | Should -BeFalse
        $decision.Failure | Should -BeExactly 'PathNotAllowed'
        $decision.Detail | Should -BeExactly "'Package.json' is not listed in allowed_paths of allowance 'npm'"
    }

    It 'reports the first unlisted path of the first candidate (#1231)' {
        # Act
        $decision = Get-ReleasePullRequestPathDecision -Allowances (Get-ReleasePullRequestTestAllowance) -Branch 'release/v1' -Path @('package.json', 'src/app.ps1', 'README.md')

        # Assert
        $decision.Failure | Should -BeExactly 'PathNotAllowed'
        $decision.Detail | Should -BeExactly "'src/app.ps1' is not listed in allowed_paths of allowance 'npm'"
    }
}
