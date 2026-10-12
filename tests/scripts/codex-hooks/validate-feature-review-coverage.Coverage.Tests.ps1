#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/validate-feature-review-coverage.ps1 (issue #786).

.DESCRIPTION
    Exercises the audit locator, the changed-language reader, the LCOV and JaCoCo parsers, the
    language dispatcher, the coverage-row rules, the continuation shape, and the entry point
    with stdin redirected and restored in finally. File reads go through Pester mocks of
    Test-Path, Get-ChildItem, and Get-Content; no test creates, renames, moves, or deletes a file.
#>

Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
    BeforeAll {
        $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.codex/hooks/validate-feature-review-coverage.ps1'))
        . $script:HookFile
        $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
        $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
        $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Get-ArtifactFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ArtifactFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChangedLanguageSet' -Surface 'Codex' }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-JacocoRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-LcovRepoCoverage' -Surface 'Codex' }

        function Invoke-CodexReviewEntry {
            # Drives the entry point with the given stdin; stdin and stderr are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:HookFile)
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Stdout = (($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString() }
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
        }

        $script:ReviewStop = '{"hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false}'
        $script:ReviewStopActive = '{"hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":true}'
    }

    Context 'readers and parsers' {
        BeforeAll {
            # The suite-level baseline mocks return null; these tests exercise the real readers.
            Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
            Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
            Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
        }

        It 'resolves the repository root two levels above the hooks folder' {
            Get-RepoRoot | Should -Not -BeNullOrEmpty
        }

        It 'returns no audit when the active folder is absent' {
            Mock Test-Path { $false }
            Get-LatestPolicyAudit -RepoRoot '/synthetic-root/repo' | Should -BeNullOrEmpty
        }

        It 'returns the most recently written audit' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { @([pscustomobject]@{ Name = 'old'; LastWriteTime = [datetime]'2026-01-01' }, [pscustomobject]@{ Name = 'new'; LastWriteTime = [datetime]'2026-02-01' }) }
            (Get-LatestPolicyAudit -RepoRoot '/synthetic-root/repo').Name | Should -Be 'new'
        }

        It 'returns no language when the PR summary is absent' {
            Mock Test-Path { $false }
            (Get-ChangedLanguageSet -RepoRoot '/synthetic-root/repo').Count | Should -Be 0
        }

        It 'maps changed files to their languages' {
            Mock Test-Path { $true }
            Mock Get-Content { @('- a.ts (+1/-0)', '- b.py (+1/-0)', '- c.ps1 (+1/-0)', '- d.cs (+1/-0)', 'not a file line', '- e.md (+1/-0)') }
            @((Get-ChangedLanguageSet -RepoRoot '/synthetic-root/repo').Keys) | Should -Be @('TypeScript', 'Python', 'PowerShell', 'CSharp')
        }

        It 'parses LCOV line counters' {
            Mock Test-Path { $true }
            Mock Get-Content { @('LF:4', 'LH:3', 'DA:1,1') }
            Get-LcovRepoCoverage -Path 'lcov.info' | Should -Be 75
        }

        It 'returns null LCOV coverage when absent or empty' {
            Mock Test-Path { $false }
            Get-LcovRepoCoverage -Path 'lcov.info' | Should -BeNullOrEmpty
            Mock Test-Path { $true }
            Mock Get-Content { @('LF:0') }
            Get-LcovRepoCoverage -Path 'lcov.info' | Should -BeNullOrEmpty
        }

        It 'parses JaCoCo LINE counters' {
            Mock Test-Path { $true }
            Mock Get-Content { '<report><counter type="LINE" missed="1" covered="1"/></report>' }
            Get-JacocoRepoCoverage -Path 'coverage.xml' | Should -Be 50
        }

        It 'returns null JaCoCo coverage when absent, counter-free, or zero' {
            Mock Test-Path { $false }
            Get-JacocoRepoCoverage -Path 'coverage.xml' | Should -BeNullOrEmpty
            Mock Test-Path { $true }
            Mock Get-Content { '<report/>' }
            Get-JacocoRepoCoverage -Path 'coverage.xml' | Should -BeNullOrEmpty
            Mock Get-Content { '<report><counter type="LINE" missed="0" covered="0"/></report>' }
            Get-JacocoRepoCoverage -Path 'coverage.xml' | Should -BeNullOrEmpty
        }

        It 'routes <Language> to its report' -ForEach @(
            @{ Language = 'TypeScript'; Leaf = 'lcov.info' },
            @{ Language = 'Python'; Leaf = 'lcov.info' },
            @{ Language = 'PowerShell'; Leaf = 'powershell-coverage.xml' },
            @{ Language = 'CSharp'; Leaf = 'coverage.xml' }
        ) {
            Mock Get-LcovRepoCoverage { param($Path) Split-Path -Leaf $Path }
            Mock Get-JacocoRepoCoverage { param($Path) Split-Path -Leaf $Path }
            Get-LanguageRepoCoverage -RepoRoot '/synthetic-root/repo' -Language $Language | Should -Be $Leaf
        }

        It 'returns null for an unknown language' {
            Get-LanguageRepoCoverage -RepoRoot '/synthetic-root/repo' -Language 'Rust' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-LanguageCoverageRow and continuation' {
        It 'reports <Case>' -ForEach @(
            @{ Case = 'an unmentioned language'; Text = 'nothing'; Pct = $null; Pattern = 'does not mention' },
            @{ Case = 'no coverage row'; Text = 'Python style PASS'; Pct = $null; Pattern = 'no coverage-scoped row' },
            @{ Case = 'a narrowing row'; Text = 'Python coverage PASS (out of scope)'; Pct = $null; Pattern = 'narrows scope' },
            @{ Case = 'a row without a verdict'; Text = 'Python coverage 90%'; Pct = $null; Pattern = 'neither a PASS nor a FAIL' },
            @{ Case = 'low coverage without FAIL'; Text = 'Python coverage PASS'; Pct = 70.0; Pattern = 'below the 85% line coverage floor' }
        ) {
            (Test-LanguageCoverageRow -AuditText $Text -Language 'Python' -RepoWidePct $Pct).Reason | Should -Match $Pattern
        }

        It 'accepts a FAIL verdict for low coverage' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage FAIL' -Language 'Python' -RepoWidePct 70.0).Ok | Should -BeTrue
        }

        It 'requests one continuation, then stops when the stop hook is already active' {
            (Get-FeatureReviewCoverageContinuation -Reason 'r' -StopHookActive $false).decision | Should -Be 'block'
            (Get-FeatureReviewCoverageContinuation -Reason 'r' -StopHookActive $true).continue | Should -BeFalse
        }
    }

    Context 'entry point' {
        BeforeAll {
            # Pester mocks shadow the hook's own definitions, so the real readers are restored for the & route.
            Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
            Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
            Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
        }

        It 'exits 2 for <Case>' -ForEach @(
            @{ Case = 'empty stdin'; Stdin = ''; Pattern = 'hook input is empty' },
            @{ Case = 'malformed stdin'; Stdin = '{bad'; Pattern = 'malformed JSON' },
            @{ Case = 'a missing stop_hook_active'; Stdin = '{"hook_event_name":"SubagentStop","agent_type":"feature-review"}'; Pattern = 'boolean stop_hook_active' },
            @{ Case = 'a non-review payload'; Stdin = '{"hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":false}'; Pattern = 'feature-review SubagentStop payload' }
        ) {
            $result = Invoke-CodexReviewEntry -Stdin $Stdin
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match $Pattern
        }

        It 'exits 0 when no policy audit exists' {
            Mock Test-Path { $false }
            (Invoke-CodexReviewEntry -Stdin $script:ReviewStop).ExitCode | Should -Be 0
        }

        It 'exits 0 when the branch changes no tracked language' {
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('pr_context.summary.txt') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { 'audit text' }
            (Invoke-CodexReviewEntry -Stdin $script:ReviewStop).ExitCode | Should -Be 0
        }

        It 'requests a continuation when a changed language lacks a verdict' {
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.info') -and -not ([string]$Path).EndsWith('.xml') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { param($Path) if (([string]$Path).EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } else { 'Python coverage 90%' } }
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStop
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
        }

        It 'stops the continuation loop when a validator error occurs with the stop hook active' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { throw 'simulated read failure' }
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStopActive
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).continue | Should -BeFalse
        }

        It 'E4-TR7: with no CLAUDE.md figure an 80.5% line row fails against the 85% floor' -Tag 'E4-Regression', 'E4-TR7' {
            # Arrange: a Python change, an 80.5 percent LCOV report, and a root CLAUDE.md without coverage figures.
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.xml') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:1000', 'LH:805') } elseif ($p.EndsWith('CLAUDE.md')) { 'Project notes without coverage figures.' } else { 'Python coverage PASS' } }

            # Act
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStop

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Not -BeNullOrEmpty
            ($result.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
            ($result.Stdout | ConvertFrom-Json).reason | Should -BeLike '*below the 85% line coverage floor*'
        }

        It 'E4-TR8: a CLAUDE.md line floor of 70 lets a 72% row pass' {
            # Arrange: a Python change, a 72 percent LCOV report, and a root CLAUDE.md stating a 70 percent line floor.
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.xml') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:100', 'LH:72') } elseif ($p.EndsWith('CLAUDE.md')) { 'Line coverage >= 70%' } else { 'Python coverage PASS' } }

            # Act
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStop

            # Assert
            $result.ExitCode | Should -Be 0 -Because $result.Stderr
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'E4-TR9: an unreadable CLAUDE.md <Case>' -ForEach @(
            @{ Case = 'stop_hook_active false exits 2'; Active = $false }
            @{ Case = 'stop_hook_active true emits continue false'; Active = $true }
        ) {
            # Arrange: the root CLAUDE.md exists but its read throws.
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.xml') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('CLAUDE.md')) { throw 'simulated read failure: access denied' } elseif ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:1000', 'LH:805') } else { 'Python coverage PASS' } }
            $stdin = if ($Active) { $script:ReviewStopActive } else { $script:ReviewStop }

            # Act
            $result = Invoke-CodexReviewEntry -Stdin $stdin

            # Assert
            if ($Active) {
                $result.ExitCode | Should -Be 0 -Because $result.Stderr
                $result.Stdout | Should -BeLike '*"continue":false*'
                ($result.Stdout | ConvertFrom-Json).continue | Should -BeFalse
            }
            else {
                $result.ExitCode | Should -Be 2
                $result.Stderr | Should -BeLike '*root CLAUDE.md*'
                $result.Stderr | Should -BeLike '*could not be read*'
            }
        }

        It 'E4-ST7: the Codex hook reads the floor from its own thresholds copy' {
            # Arrange
            $tokens = $null
            $parseErrors = $null
            $guarded = "try { . (Join-Path `$PSScriptRoot 'feature-review-coverage-thresholds.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord `$_ }"

            # Act
            $text = Get-Content -Raw -LiteralPath $script:HookFile
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookFile, [ref]$tokens, [ref]$parseErrors)
            $claudeDotSources = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot -and $node.Extent.Text.Contains('.claude') }, $true))

            # Assert
            $text.Contains($guarded) | Should -BeTrue
            $claudeDotSources.Count | Should -Be 0 -Because 'the Codex hook must not dot-source a .claude path'
            $text.Contains('subagentstop-envelope.ps1') | Should -BeFalse
            $text.Contains('Exit-SubagentStopBlock') | Should -BeFalse
            foreach ($figure in @('80.0', '80%', '80 percent')) { $text.Contains($figure) | Should -BeFalse -Because "the Codex hook must not carry the retired figure '$figure'" }
        }
    }
}
