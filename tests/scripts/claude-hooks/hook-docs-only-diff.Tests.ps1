#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for the shared docs-only helper .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Exercises the pure classifiers (relocated from the issue #901 suite under their shared
    names), the NUL guard, and the bodies of both process seams through test-local functions
    passed as scriptblocks, so no row starts a process. No row creates, writes, or deletes a file.
#>

Describe 'hook-docs-only-diff shared helper (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')

        # Test-local stand-ins for git and gh, passed as scriptblocks to the seams' invoker parameters.
        function Invoke-DocsOnlyFakeEcho {
            $global:LASTEXITCODE = 0
            ($args -join '|') + "`0"
        }
        function Invoke-DocsOnlyFakeLocation {
            $global:LASTEXITCODE = 0
            (Split-Path -Leaf -Path (Get-Location).Path) + '|' + ($args -join '|')
        }
        function Invoke-DocsOnlyFakeExit2 {
            $global:LASTEXITCODE = 2
        }
        function Invoke-DocsOnlyFakeThrow {
            throw 'simulated process start failure'
        }
        function Invoke-DocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    Context 'Get-DocsOnlyPathViolation' {
        It 'returns null for an all-docs set' {
            # Arrange
            $paths = @('docs/a.md', 'docs/features/x/plan.md')

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeNullOrEmpty -Because 'every path is under docs/'
        }

        It 'returns NON_DOCS_PATH for <Path>' -ForEach @(
            @{ Path = '.claude/hooks/x.ps1' }
            @{ Path = '.github/workflows/ci.yml' }
            @{ Path = 'README.md' }
            @{ Path = 'docsx/a.md' }
            @{ Path = 'doc/a.md' }
            @{ Path = 'Docs/a.md' }
            @{ Path = 'docs' }
        ) {
            # Arrange
            $paths = @($Path)

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Contains($Path) | Should -BeTrue -Because 'the denial names the offending path'
        }

        It 'names the first offending path of a mixed set' {
            # Arrange
            $paths = @('docs/a.md', 'src/b.ps1', '.github/c.yml')

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result.Contains('src/b.ps1') | Should -BeTrue -Because 'the first non-docs path is reported'
            $result.Contains('.github/c.yml') | Should -BeFalse -Because 'evaluation stops at the first violation'
        }

        It 'returns EMPTY_DIFF for an empty set' {
            # Arrange
            $paths = @()

            # Act
            $result = Get-DocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }
    }

    Context 'ConvertFrom-DocsOnlyNameList' {
        It 'splits a NUL list with spaces and non-ASCII names' {
            # Arrange
            $accented = 'docs/' + [char]0x00E9 + '.md'
            $text = "docs/a b.md`0" + $accented + "`0"

            # Act
            $result = @(ConvertFrom-DocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 2
            $result[0] | Should -BeExactly 'docs/a b.md'
            $result[1] | Should -BeExactly $accented
        }

        It 'keeps a line feed inside a name as one element' {
            # Arrange
            $text = "docs/line`nbreak.md`0"

            # Act
            $result = @(ConvertFrom-DocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 1 -Because 'only NUL separates entries'
            $result[0].Contains("`n") | Should -BeTrue
        }

        It 'returns no element for empty and null text' {
            # Arrange and Act
            $fromEmpty = @(ConvertFrom-DocsOnlyNameList -Text '')
            $fromNull = @(ConvertFrom-DocsOnlyNameList -Text $null)

            # Assert
            $fromEmpty.Count | Should -Be 0
            $fromNull.Count | Should -Be 0
        }
    }

    Context 'Get-DocsOnlyDiffTextViolation' {
        It 'denies non-empty output that lacks the trailing NUL (issue #927)' {
            # Arrange
            $text = 'docs/a.md'

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result | Should -Match 'NUL-terminated'
            $result.Contains('origin/main') | Should -BeTrue -Because 'the denial names the base'
        }

        It 'returns EMPTY_DIFF for <Name> (issue #927)' -ForEach @(
            @{ Name = 'empty diff text'; Text = '' }
            @{ Name = 'null diff text'; Text = $null }
        ) {
            # Arrange: the row supplies the text.

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }

        It 'returns NON_DOCS_PATH for a NUL-terminated list with a path outside docs (issue #927)' {
            # Arrange
            $text = "docs/a.md`0src/b.ps1`0"

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Contains('src/b.ps1') | Should -BeTrue
        }

        It 'returns null for a NUL-terminated list of docs paths (issue #927)' {
            # Arrange
            $text = "docs/a.md`0docs/b.md`0"

            # Act
            $result = Get-DocsOnlyDiffTextViolation -DiffText $text -BaseName 'main'

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Invoke-DocsOnlyGitExe' {
        It 'passes -C, the root, and the arguments in order and keeps the trailing NUL (issue #927)' {
            # Arrange
            $gitArgs = @('diff', '--name-only', '-z')
            $expected = '-C|' + $PSScriptRoot + '|diff|--name-only|-z' + "`0"

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeEcho}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly $expected
        }

        It 'returns the non-zero exit code of the injected git command (issue #927)' {
            # Arrange: the injected stand-in sets exit code 2 and emits nothing.

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeExit2}

            # Assert
            $result.ExitCode | Should -Be 2
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object when the injected git command throws (issue #927)' {
            # Arrange: the injected stand-in throws.

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object without running git for <Name> (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $Root -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeMarker}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            $global:LASTEXITCODE | Should -Be 0 -Because 'the injected command never ran'
        }
    }

    Context 'Invoke-DocsOnlyGhExe' {
        It 'runs inside the working root with the arguments in order and restores the location (issue #927)' {
            # Arrange
            $before = (Get-Location).Path

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeLocation}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'claude-hooks|pr|view|5'
            (Get-Location).Path | Should -Be $before
        }

        It 'returns the non-zero exit code of the injected gh command (issue #927)' {
            # Arrange: the injected stand-in sets exit code 2 and emits nothing.

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeExit2}

            # Assert
            $result.ExitCode | Should -Be 2
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object and restores the location when the injected gh command throws (issue #927)' {
            # Arrange
            $before = (Get-Location).Path

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            (Get-Location).Path | Should -Be $before
        }

        It 'returns the failure object without running gh for <Name> (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $Root -GhArgs @('pr', 'view', '5') -GhInvoker ${function:Invoke-DocsOnlyFakeMarker}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
            $global:LASTEXITCODE | Should -Be 0 -Because 'the injected command never ran'
        }
    }

    Context 'shared copies' {
        It 'is byte-identical across all four copies (issue #927)' {
            # Arrange
            $paths = @('.claude/hooks/hook-docs-only-diff.ps1', '.codex/hooks/hook-docs-only-diff.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1')

            # Act
            $hashes = @($paths | ForEach-Object { (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $script:RepoRoot $_)).Hash })

            # Assert
            @($hashes | Sort-Object -Unique).Count | Should -Be 1 -Because "all four copies must be byte-identical ($($hashes -join ', '))"
        }

        It 'imports nothing, dot-sources nothing, and names no fetch argument (issue #927)' {
            # Arrange
            $path = Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1'
            $tokens = $null
            $parseErrors = $null

            # Act
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
            $loads = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and ($node.GetCommandName() -eq 'Import-Module' -or $node.InvocationOperator -eq 'Dot') }, $true))
            $fetchArguments = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $node.Value -ceq 'fetch' }, $true))

            # Assert
            @($parseErrors) | Should -BeNullOrEmpty
            $loads | Should -BeNullOrEmpty
            $fetchArguments | Should -BeNullOrEmpty
        }
    }
}
