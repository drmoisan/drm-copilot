#Requires -Version 7.0
<#
.SYNOPSIS
    Parity and behavior tests for the Codex twin .codex/hooks/validate-feature-review-coverage-freshness.ps1
    (issue #1114).

.DESCRIPTION
    Parses the twin and .claude/hooks/validate-feature-review-coverage-freshness.ps1 and asserts that
    both define the same function names with identical extent text and that the twin holds no
    statement outside its function definitions. Then runs the freshness scenarios of
    tests/scripts/claude-hooks/validate-feature-review-coverage-freshness.Tests.ps1 against the
    dot-sourced twin. Report times come from a Pester mock of Get-FeatureReviewReportLastWriteUtc and
    git output from an in-memory GitInvoker script block, so no test reads a file, runs git, or
    creates a file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    $script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
    $script:TwinPath = Join-Path $script:RepoRoot '.codex/hooks/validate-feature-review-coverage-freshness.ps1'
    $script:ClaudePath = Join-Path $script:RepoRoot '.claude/hooks/validate-feature-review-coverage-freshness.ps1'
    . $script:TwinPath

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.codex/worktrees/bug-1114'
    $script:CommitSeconds = 1762525200L
    $script:CommitTime = [DateTimeOffset]::FromUnixTimeSeconds($script:CommitSeconds).UtcDateTime
    $script:PowerShellOnly = [ordered]@{ PowerShell = $true }

    function Get-FreshnessFunctionText {
        # Returns an ordered map of top-level function name to extent text for a parsed file.
        param([Parameter(Mandatory)] [string] $Path)
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $null)
        $map = [ordered]@{}
        foreach ($function in @($ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })) {
            $map[$function.Name] = $function.Extent.Text
        }
        return $map
    }

    function Get-GitInvoker {
        # Returns a GitInvoker seam that records its calls and returns the given exit code and output.
        param([int] $ExitCode = 0, [string] $Output = '', [System.Collections.Generic.List[object]] $Calls)
        $exit = $ExitCode
        $text = $Output
        $log = $Calls
        return {
            param([string] $Root, [string[]] $Pathspec)
            if ($null -ne $log) { $log.Add([pscustomobject]@{ Root = $Root; Pathspec = $Pathspec }) }
            [pscustomobject]@{ ExitCode = $exit; Output = $text }
        }.GetNewClosure()
    }

    function Set-ReportTime {
        # Serves last-write times by absolute path through the Get-FeatureReviewReportLastWriteUtc seam.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([hashtable] $Time)
        $table = $Time
        Mock Get-FeatureReviewReportLastWriteUtc { param([string] $Path) if ($table.ContainsKey($Path)) { $table[$Path] } else { $null } }.GetNewClosure()
    }
}

Describe 'Codex freshness twin parity (issue #1114)' {
    It '1114: the Codex twin defines the same function names as the Claude file' {
        # Arrange
        $twin = Get-FreshnessFunctionText -Path $script:TwinPath
        $claude = Get-FreshnessFunctionText -Path $script:ClaudePath

        # Act
        $twinNames = @($twin.Keys) -join ','
        $claudeNames = @($claude.Keys) -join ','

        # Assert
        $claudeNames | Should -BeExactly 'Get-FeatureReviewCoverageReportPath,Get-FeatureReviewCoveragePathspec,Get-FeatureReviewReportLastWriteUtc,Get-FeatureReviewCoverageFreshnessDecision'
        $twinNames | Should -BeExactly $claudeNames
    }

    It '1114: each Codex twin function has the Claude extent text' {
        # Arrange
        $twin = Get-FreshnessFunctionText -Path $script:TwinPath
        $claude = Get-FreshnessFunctionText -Path $script:ClaudePath

        # Act and Assert
        foreach ($name in @($claude.Keys)) {
            $twin[$name] | Should -BeExactly $claude[$name] -Because "the Codex twin of $name must keep the Claude function text"
        }
    }

    It '1114: the Codex twin has no statement outside function definitions' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:TwinPath, [ref] $null, [ref] $null)

        # Act
        $other = @($ast.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })

        # Assert
        $other.Count | Should -Be 0
        $ast.ParamBlock | Should -BeNullOrEmpty
        $ast.BeginBlock | Should -BeNullOrEmpty
        $ast.ProcessBlock | Should -BeNullOrEmpty
    }
}

Describe 'Get-FeatureReviewCoverageFreshnessDecision (issue #1114, Codex twin)' {
    Context 'session-root invariant' {
        It 'runs no probe when the resolver source is SessionRoot' {
            # Arrange
            Mock Get-FeatureReviewReportLastWriteUtc { $null }
            $calls = [System.Collections.Generic.List[object]]::new()

            # Act
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'SessionRoot' -ChangedLanguage $script:PowerShellOnly -GitInvoker (Get-GitInvoker -Calls $calls)

            # Assert
            $result | Should -BeNullOrEmpty
            Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 0 -Exactly
            $calls.Count | Should -Be 0
        }

        It 'runs no probe when the resolved root equals the session root' {
            # Arrange
            Mock Get-FeatureReviewReportLastWriteUtc { $null }
            $calls = [System.Collections.Generic.List[object]]::new()

            # Act
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot '/synthetic-worktrees/MAIN/' -SessionRoot $script:SessionRoot -Source 'FilePath' -ChangedLanguage $script:PowerShellOnly -GitInvoker (Get-GitInvoker -Calls $calls)

            # Assert
            $result | Should -BeNullOrEmpty
            Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 0 -Exactly
            $calls.Count | Should -Be 0
        }

        It 'runs no probe for a blank root' {
            Mock Get-FeatureReviewReportLastWriteUtc { $null }
            Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot '' -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage $script:PowerShellOnly | Should -BeNullOrEmpty
            Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 0 -Exactly
        }
    }

    Context 'absent inputs beneath the item root' {
        It 'blocks repairably on an absent PR context summary' {
            # Arrange
            Set-ReportTime -Time @{}

            # Act
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{}) -GitInvoker (Get-GitInvoker)

            # Assert
            $result.HasRepairable | Should -BeTrue
            $result.HasNonRepairable | Should -BeFalse
            $result.Reasons[0] | Should -BeLike "*PR context summary 'artifacts/pr_context.summary.txt' is absent beneath the item worktree '$script:ItemRoot'*"
        }

        It 'blocks repairably on an absent report naming the language, the expected path, and the item root' {
            # Arrange
            Set-ReportTime -Time @{ "$script:ItemRoot/artifacts/pr_context.summary.txt" = $script:CommitTime }

            # Act
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage $script:PowerShellOnly -GitInvoker (Get-GitInvoker -Output "$script:CommitSeconds")

            # Assert
            $result.HasRepairable | Should -BeTrue
            @($result.Reasons).Count | Should -Be 1
            $result.Reasons[0] | Should -BeLike "PowerShell has changed files but its coverage report 'artifacts/pester/powershell-coverage.xml' is absent beneath the item worktree '$script:ItemRoot'*"
        }
    }

    Context 'report freshness against the newest language-touching commit' {
        BeforeEach {
            Set-ReportTime -Time @{
                "$script:ItemRoot/artifacts/pr_context.summary.txt"         = $script:CommitTime
                "$script:ItemRoot/artifacts/pester/powershell-coverage.xml" = $script:CommitTime.AddMinutes(-5)
                "$script:ItemRoot/artifacts/python/lcov.info"               = $script:CommitTime
                "$script:ItemRoot/coverage/lcov.info"                       = $script:CommitTime.AddMinutes(10)
                "$script:ItemRoot/artifacts/csharp/coverage.xml"            = $script:CommitTime.AddSeconds(1)
            }
        }

        It 'blocks repairably on a report older than the reference commit, stating both times' {
            # Act
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage $script:PowerShellOnly -GitInvoker (Get-GitInvoker -Output "$script:CommitSeconds")

            # Assert
            $result.HasRepairable | Should -BeTrue
            $result.HasNonRepairable | Should -BeFalse
            $result.Reasons[0] | Should -BeLike "*'artifacts/pester/powershell-coverage.xml'*is stale*$($script:CommitTime.AddMinutes(-5).ToString('yyyy-MM-ddTHH:mm:ssZ'))*$($script:CommitTime.ToString('yyyy-MM-ddTHH:mm:ssZ'))*"
        }

        It 'passes a report written at the reference commit time' {
            Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'FilePath' -ChangedLanguage ([ordered]@{ Python = $true }) -GitInvoker (Get-GitInvoker -Output "$script:CommitSeconds") | Should -BeNullOrEmpty
        }

        It 'passes reports written after the reference commit time' {
            Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'FilePath' -ChangedLanguage ([ordered]@{ TypeScript = $true; CSharp = $true }) -GitInvoker (Get-GitInvoker -Output "$script:CommitSeconds`n") | Should -BeNullOrEmpty
        }

        It 'queries git in the item root with the language pathspecs' {
            # Arrange
            $calls = [System.Collections.Generic.List[object]]::new()

            # Act
            $null = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ TypeScript = $true }) -GitInvoker (Get-GitInvoker -Output "$script:CommitSeconds" -Calls $calls)

            # Assert
            $calls.Count | Should -Be 1
            $calls[0].Root | Should -Be $script:ItemRoot
            $calls[0].Pathspec | Should -Be @('*.ts', '*.tsx')
        }

        It 'fails closed when git exits non-zero' {
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ Python = $true }) -GitInvoker (Get-GitInvoker -ExitCode 128 -Output 'fatal: not a git repository')
            $result.HasNonRepairable | Should -BeTrue
            $result.HasRepairable | Should -BeFalse
            $result.Reasons[0] | Should -BeLike '*git query*failed (exit code 128*the gate fails closed.'
        }

        It 'fails closed when git returns empty output' {
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ Python = $true }) -GitInvoker (Get-GitInvoker -Output '')
            $result.HasNonRepairable | Should -BeTrue
            $result.Reasons[0] | Should -BeLike '*exit code 0, output ''''*'
        }

        It 'fails closed when git returns non-integer output' {
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ Python = $true }) -GitInvoker (Get-GitInvoker -Output 'yesterday')
            $result.HasNonRepairable | Should -BeTrue
            $result.Reasons[0] | Should -BeLike '*output ''yesterday''*'
        }

        It 'fails closed when the git invoker throws' {
            $result = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ Python = $true }) -GitInvoker { param([string] $Root, [string[]] $Pathspec) throw "git missing for $Root $Pathspec" }
            $result.HasNonRepairable | Should -BeTrue
            $result.Reasons[0] | Should -BeLike '*exit code none*'
        }

        It 'skips a language with no known coverage report' {
            Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot -Source 'DelegationPrompt' -ChangedLanguage ([ordered]@{ Rust = $true }) -GitInvoker (Get-GitInvoker -Output 'unused') | Should -BeNullOrEmpty
        }
    }
}

Describe 'freshness lookup helpers (issue #1114, Codex twin)' {
    It 'maps each language to its coverage report path' {
        Get-FeatureReviewCoverageReportPath -Language 'TypeScript' | Should -Be 'coverage/lcov.info'
        Get-FeatureReviewCoverageReportPath -Language 'Python' | Should -Be 'artifacts/python/lcov.info'
        Get-FeatureReviewCoverageReportPath -Language 'PowerShell' | Should -Be 'artifacts/pester/powershell-coverage.xml'
        Get-FeatureReviewCoverageReportPath -Language 'CSharp' | Should -Be 'artifacts/csharp/coverage.xml'
        Get-FeatureReviewCoverageReportPath -Language 'Rust' | Should -BeNullOrEmpty
    }

    It 'maps each language to its git pathspecs' {
        Get-FeatureReviewCoveragePathspec -Language 'PowerShell' | Should -Be @('*.ps1', '*.psm1', '*.psd1')
        Get-FeatureReviewCoveragePathspec -Language 'Python' | Should -Be @('*.py')
        Get-FeatureReviewCoveragePathspec -Language 'CSharp' | Should -Be @('*.cs')
        @(Get-FeatureReviewCoveragePathspec -Language 'Rust').Count | Should -Be 0
    }

    It 'returns null from the last-write seam when no file exists' {
        Mock Test-Path { $false }
        Get-FeatureReviewReportLastWriteUtc -Path '/synthetic-worktrees/main/absent.xml' | Should -BeNullOrEmpty
    }

    It 'returns the UTC last-write time from the last-write seam' {
        Mock Test-Path { $true }
        Mock Get-Item { [pscustomobject]@{ LastWriteTimeUtc = $script:CommitTime } }
        Get-FeatureReviewReportLastWriteUtc -Path '/synthetic-worktrees/main/present.xml' | Should -Be $script:CommitTime
    }
}
