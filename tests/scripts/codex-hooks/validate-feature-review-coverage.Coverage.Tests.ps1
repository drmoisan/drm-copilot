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
            Get-LatestPolicyAudit -RepoRoot 'C:\repo' | Should -BeNullOrEmpty
        }

        It 'returns the most recently written audit' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { @([pscustomobject]@{ Name = 'old'; LastWriteTime = [datetime]'2026-01-01' }, [pscustomobject]@{ Name = 'new'; LastWriteTime = [datetime]'2026-02-01' }) }
            (Get-LatestPolicyAudit -RepoRoot 'C:\repo').Name | Should -Be 'new'
        }

        It 'returns no language when the PR summary is absent' {
            Mock Test-Path { $false }
            (Get-ChangedLanguageSet -RepoRoot 'C:\repo').Count | Should -Be 0
        }

        It 'maps changed files to their languages' {
            Mock Test-Path { $true }
            Mock Get-Content { @('- a.ts (+1/-0)', '- b.py (+1/-0)', '- c.ps1 (+1/-0)', '- d.cs (+1/-0)', 'not a file line', '- e.md (+1/-0)') }
            @((Get-ChangedLanguageSet -RepoRoot 'C:\repo').Keys) | Should -Be @('TypeScript', 'Python', 'PowerShell', 'CSharp')
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
            Get-LanguageRepoCoverage -RepoRoot 'C:\repo' -Language $Language | Should -Be $Leaf
        }

        It 'returns null for an unknown language' {
            Get-LanguageRepoCoverage -RepoRoot 'C:\repo' -Language 'Rust' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-LanguageCoverageRow and continuation' {
        It 'reports <Case>' -ForEach @(
            @{ Case = 'an unmentioned language'; Text = 'nothing'; Pct = $null; Pattern = 'does not mention' },
            @{ Case = 'no coverage row'; Text = 'Python style PASS'; Pct = $null; Pattern = 'no coverage-scoped row' },
            @{ Case = 'a narrowing row'; Text = 'Python coverage PASS (out of scope)'; Pct = $null; Pattern = 'narrows scope' },
            @{ Case = 'a row without a verdict'; Text = 'Python coverage 90%'; Pct = $null; Pattern = 'neither a PASS nor a FAIL' },
            @{ Case = 'low coverage without FAIL'; Text = 'Python coverage PASS'; Pct = 70.0; Pattern = 'below the 80% floor' }
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
            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { 'audit text' }
            (Invoke-CodexReviewEntry -Stdin $script:ReviewStop).ExitCode | Should -Be 0
        }

        It 'requests a continuation when a changed language lacks a verdict' {
            Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.info') -and -not ([string]$Path).EndsWith('.xml') }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { param($Path) if (([string]$Path).EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } else { 'Python coverage 90%' } }
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStop
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
        }

        It 'stops the continuation loop when a validator error occurs with the stop hook active' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
            Mock Get-Content { throw 'simulated read failure' }
            $result = Invoke-CodexReviewEntry -Stdin $script:ReviewStopActive
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).continue | Should -BeFalse
        }
    }
}
