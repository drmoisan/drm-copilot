Set-StrictMode -Version Latest

# Contract guard for issue #1106: the policy surfaces and their bundle copies
# name MSTest as the C# test framework and Pester v6 as the supported Pester
# version, and no surface or approved command carries the coverage path or the
# example text of another project. Each `PTN-` row reads one root in place and
# reports every file that holds a forbidden phrase; the suite writes nothing.

BeforeDiscovery {
    $script:Resources = 'extensions/drm-copilot/resources'
}

Describe 'Policy toolchain naming' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

        # Phrases that state another C# framework, a superseded Pester version, or
        # another project's coverage path or example text. Bare `xUnit` is not listed,
        # because the C# unit-test policy prohibits xUnit by name and a generic CI
        # framework list names it; neither states this repository's framework.
        $script:PolicyPhrase = @(
            'Use **xUnit**', 'xUnit +', 'xUnit toolchain', 'xUnit gate', 'xUnit coverage', 'xUnit scenario',
            '(xUnit)', 'foundation: xUnit', 'Nullable Analysis, xUnit', 'Theory tests', 'Verify.Xunit',
            '[Fact]', '[Theory]', 'IClassFixture', 'Pester (v5.x)', 'Pester v5', '--cov=src/lexile_corpus_tuner',
            'lexile', 'gutenberg'
        )

        # Code and task configuration keep operational names, so only the stray
        # coverage argument is forbidden there.
        $script:CodePhrase = @('--cov=src/lexile_corpus_tuner')

        <#
        .SYNOPSIS
            Returns the forbidden phrases that a text holds.
        .DESCRIPTION
            Collapses whitespace runs in the text so a phrase wrapped across lines is
            still found, then compares ordinally and ignores case.
        .PARAMETER Content
            The text to search.
        .PARAMETER Phrase
            The forbidden phrases.
        .OUTPUTS
            [System.Object[]] The phrases found in the text.
        #>
        function Get-PtnForbiddenHit {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)]
                [AllowEmptyString()]
                [string] $Content,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [string[]] $Phrase
            )

            $collapsed = $Content -replace '\s+', ' '
            return @($Phrase | Where-Object { $collapsed.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })
        }

        <#
        .SYNOPSIS
            Returns the repository-relative paths of the files under the given roots.
        .PARAMETER Root
            Repository-relative folders or files.
        .PARAMETER Extension
            The file extensions to keep, including the leading dot.
        .OUTPUTS
            [System.Object[]] The relative paths, with forward slashes.
        #>
        function Get-PtnFile {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)]
                [string[]] $Root,

                [Parameter(Mandatory = $true)]
                [string[]] $Extension
            )

            # A root is either a single file or a folder searched recursively.
            $files = foreach ($entry in $Root) {
                $path = Join-Path -Path $script:RepoRoot -ChildPath $entry
                if (Test-Path -LiteralPath $path -PathType Leaf) {
                    Get-Item -LiteralPath $path -Force
                } elseif (Test-Path -LiteralPath $path -PathType Container) {
                    Get-ChildItem -LiteralPath $path -Recurse -File -Force | Where-Object { $_.Extension -in $Extension }
                }
            }
            return @($files | ForEach-Object { [System.IO.Path]::GetRelativePath($script:RepoRoot, $_.FullName).Replace('\', '/') })
        }

        <#
        .SYNOPSIS
            Returns one `<file>: <phrase>` line for each forbidden phrase in each file.
        .PARAMETER RelativePath
            The repository-relative files to read.
        .PARAMETER Phrase
            The forbidden phrases.
        .OUTPUTS
            [System.Object[]] The violation lines.
        #>
        function Get-PtnViolation {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [string[]] $RelativePath,

                [Parameter(Mandatory = $true)]
                [string[]] $Phrase
            )

            # Read each file in place and report every phrase it holds.
            return @(foreach ($file in $RelativePath) {
                    $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepoRoot -ChildPath $file))
                    foreach ($hit in @(Get-PtnForbiddenHit -Content $text -Phrase $Phrase)) { '{0}: {1}' -f $file, $hit }
                })
        }
    }

    It 'PTN-<Id> holds no forbidden toolchain or example phrase' -ForEach @(
        @{ Id = 'CLAUDE-RULES'; Root = @('.claude/rules'); Kind = 'Policy' }
        @{ Id = 'CLAUDE-AGENTS'; Root = @('.claude/agents'); Kind = 'Policy' }
        @{ Id = 'CLAUDE-SKILLS'; Root = @('.claude/skills'); Kind = 'Policy' }
        @{ Id = 'AGENTS-SKILLS'; Root = @('.agents/skills'); Kind = 'Policy' }
        @{ Id = 'GITHUB-INSTRUCTIONS'; Root = @('.github/instructions'); Kind = 'Policy' }
        @{ Id = 'GITHUB-AGENTS'; Root = @('.github/agents'); Kind = 'Policy' }
        @{ Id = 'GITHUB-PROMPTS'; Root = @('.github/prompts'); Kind = 'Policy' }
        @{ Id = 'CODEX-AGENTS'; Root = @('.codex/agents'); Kind = 'Policy' }
        @{ Id = 'TEMPLATES'; Root = @('docs/features/templates'); Kind = 'Policy' }
        @{ Id = 'README'; Root = @('README.md'); Kind = 'Policy' }
        @{ Id = 'CLAUDE-BUNDLE'; Root = @("$script:Resources/claude-customizations"); Kind = 'Policy' }
        @{ Id = 'GITHUB-BUNDLE'; Root = @("$script:Resources/customizations"); Kind = 'Policy' }
        @{ Id = 'CODEX-AGENTS-BUNDLE'; Root = @("$script:Resources/codex-and-agents-customizations"); Kind = 'Policy' }
        @{ Id = 'TEMPLATES-BUNDLE'; Root = @("$script:Resources/templates"); Kind = 'Policy' }
        @{ Id = 'CODE'; Root = @('.vscode/tasks.json', 'scripts/dev_tools'); Kind = 'Code' }
    ) {
        # Arrange
        # A file root is read whatever its extension; a folder root keeps only these.
        $extension = if ($Kind -eq 'Code') { @('.py') } else { @('.md', '.toml') }
        $phrase = if ($Kind -eq 'Code') { $script:CodePhrase } else { $script:PolicyPhrase }
        $files = @(Get-PtnFile -Root $Root -Extension $extension)

        # Act
        $violation = @(Get-PtnViolation -RelativePath $files -Phrase $phrase)

        # Assert
        $files.Count | Should -BeGreaterThan 0 -Because "the row must read files under $($Root -join ', ')"
        $violation | Should -BeNullOrEmpty -Because 'a policy surface must name MSTest and Pester v6 and no other project'
    }

    It 'PTN-HELPER reports each forbidden phrase in in-memory text' {
        # Arrange
        $phrase = $script:PolicyPhrase

        # Act
        # Fold case in the text, because the scan ignores case. A longer phrase can also
        # hold a shorter one, so each phrase is checked for presence, not for equality.
        $missed = @(foreach ($item in $phrase) {
                $hits = @(Get-PtnForbiddenHit -Content "A surface that states $($item.ToUpperInvariant()) in prose." -Phrase $phrase)
                if ($hits -cnotcontains $item) { $item }
            })

        # Assert
        $phrase.Count | Should -Be 19 -Because 'the plan names 19 policy phrases'
        $missed | Should -BeNullOrEmpty -Because 'a reintroduced phrase must fail the scan'
    }

    It 'PTN-HELPER-CLEAN reports nothing for MSTest and Pester v6 text' {
        # Arrange
        $text = "Use **MSTest** with ``[TestClass]``, ``[TestMethod]``, and ``[DataRow]``.`nUse **Pester** (v6.x); deterministic Pester v6 coverage; ``--cov=scripts/dev_tools``."

        # Act
        $hits = @(Get-PtnForbiddenHit -Content $text -Phrase $script:PolicyPhrase)

        # Assert
        $hits | Should -BeNullOrEmpty -Because 'current framework and version text is allowed'
    }

    It 'PTN-HELPER-EXEMPT reports nothing for the xUnit prohibition and a generic framework list' {
        # Arrange
        $text = 'Do not introduce xUnit or NUnit into existing test projects. (Jest, Vitest, Pytest, Go testing, JUnit, NUnit, XUnit, RSpec)'

        # Act
        $hits = @(Get-PtnForbiddenHit -Content $text -Phrase $script:PolicyPhrase)

        # Assert
        $hits | Should -BeNullOrEmpty -Because 'a prohibition and a generic list do not state this repository framework'
    }
}
