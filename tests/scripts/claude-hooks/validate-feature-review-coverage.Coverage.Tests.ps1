#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .claude/hooks/validate-feature-review-coverage.ps1 (issue #786).

.DESCRIPTION
    Exercises the artifact reader, the LCOV and JaCoCo parsers, the language dispatchers, the
    coverage-row rules, the review-artifact validation branches, and the entry point. File
    reads go through Pester mocks of Test-Path and Get-Content or of Get-ArtifactFileContent;
    no test creates, renames, moves, or deletes a file.
#>

BeforeAll {
    $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1'))
    . $script:HookFile
    $script:RealGetArtifactFileContent = ${function:Get-ArtifactFileContent}
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
    Mock Get-ArtifactFileContent { $null }
    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }

    function Get-ArtifactFileResult {
        # The Get-ArtifactFileContent result shape for an existing file.
        param([string[]] $Lines)
        return @{ Exists = $true; Text = ($Lines -join "`n"); Lines = $Lines }
    }
}

Describe 'validate-feature-review-coverage coverage (issue #786)' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
    }

    Context 'Get-ArtifactFileContent' {
        BeforeEach { Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent }

        It 'reports an absent file' {
            Mock Test-Path { $false }
            $result = Get-ArtifactFileContent -Path 'artifacts/absent.txt'
            $result.Exists | Should -BeFalse
            @($result.Lines).Count | Should -Be 0
        }

        It 'wraps a single-line file in an array' {
            Mock Test-Path { $true }
            Mock Get-Content { 'only line' } -ParameterFilter { $Raw }
            Mock Get-Content { 'only line' } -ParameterFilter { -not $Raw }
            $result = Get-ArtifactFileContent -Path 'artifacts/one.txt'
            $result.Exists | Should -BeTrue
            $result.Text | Should -Be 'only line'
            , $result.Lines | Should -BeOfType [array]
        }

        It 'returns an empty line array for an empty file' {
            Mock Test-Path { $true }
            Mock Get-Content { '' } -ParameterFilter { $Raw }
            Mock Get-Content { $null } -ParameterFilter { -not $Raw }
            $result = Get-ArtifactFileContent -Path 'artifacts/empty.txt'
            @($result.Lines).Count | Should -Be 0
        }

        It 'keeps a multi-line file as its line array' {
            Mock Test-Path { $true }
            Mock Get-Content { "a`nb" } -ParameterFilter { $Raw }
            Mock Get-Content { @('a', 'b') } -ParameterFilter { -not $Raw }
            @((Get-ArtifactFileContent -Path 'artifacts/two.txt').Lines).Count | Should -Be 2
        }
    }

    Context 'LCOV parsers' {
        It 'returns null line coverage for an absent report' {
            Mock Get-ArtifactFileContent { @{ Exists = $false; Text = $null; Lines = @() } }
            Get-LcovRepoCoverage -Path 'coverage/lcov.info' | Should -BeNullOrEmpty
        }

        It 'sums LF and LH counters into a percent' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('LF:10', 'LH:5', 'LF:10', 'LH:10', 'DA:1,1') }
            Get-LcovRepoCoverage -Path 'coverage/lcov.info' | Should -Be 75
        }

        It 'returns null line coverage when no lines are found' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('LF:0', 'LH:0') }
            Get-LcovRepoCoverage -Path 'coverage/lcov.info' | Should -BeNullOrEmpty
        }

        It 'returns null branch coverage for an absent report' {
            Mock Get-ArtifactFileContent { @{ Exists = $false; Text = $null; Lines = @() } }
            Get-LcovBranchCoverage -Path 'coverage/lcov.info' | Should -BeNullOrEmpty
        }

        It 'sums BRF and BRH counters into a percent' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('BRF:4', 'BRH:1', 'BRF:4', 'BRH:3', 'LF:1') }
            Get-LcovBranchCoverage -Path 'coverage/lcov.info' | Should -Be 50
        }

        It 'returns null branch coverage when no branches are found' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('BRF:0') }
            Get-LcovBranchCoverage -Path 'coverage/lcov.info' | Should -BeNullOrEmpty
        }
    }

    Context 'JaCoCo parsers' {
        It 'returns null for an absent line report' {
            Mock Get-ArtifactFileContent { @{ Exists = $false; Text = $null; Lines = @() } }
            Get-JacocoRepoCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }

        It 'computes line coverage from LINE counters' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="LINE" missed="1" covered="3"/></report>') }
            Get-JacocoRepoCoverage -Path 'artifacts/csharp/coverage.xml' | Should -Be 75
        }

        It 'returns null when the report has no LINE counter' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="BRANCH" missed="1" covered="1"/></report>') }
            Get-JacocoRepoCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }

        It 'returns null when the LINE counters total zero' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="LINE" missed="0" covered="0"/></report>') }
            Get-JacocoRepoCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }

        It 'returns null for an absent branch report' {
            Mock Get-ArtifactFileContent { @{ Exists = $false; Text = $null; Lines = @() } }
            Get-JacocoBranchCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }

        It 'computes branch coverage from BRANCH counters' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="BRANCH" missed="3" covered="1"/></report>') }
            Get-JacocoBranchCoverage -Path 'artifacts/csharp/coverage.xml' | Should -Be 25
        }

        It 'returns null when the report has no BRANCH counter' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="LINE" missed="1" covered="1"/></report>') }
            Get-JacocoBranchCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }

        It 'returns null when the BRANCH counters total zero' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('<report><counter type="BRANCH" missed="0" covered="0"/></report>') }
            Get-JacocoBranchCoverage -Path 'artifacts/csharp/coverage.xml' | Should -BeNullOrEmpty
        }
    }

    Context 'language dispatchers' {
        It 'routes <Language> to its line and branch report' -ForEach @(
            @{ Language = 'TypeScript'; Path = 'coverage/lcov.info' },
            @{ Language = 'Python'; Path = 'artifacts/python/lcov.info' },
            @{ Language = 'PowerShell'; Path = 'artifacts/pester/powershell-coverage.xml' },
            @{ Language = 'CSharp'; Path = 'artifacts/csharp/coverage.xml' }
        ) {
            Mock Get-LcovRepoCoverage { param($Path) "line:$Path" }
            Mock Get-JacocoRepoCoverage { param($Path) "line:$Path" }
            Mock Get-LcovBranchCoverage { param($Path) "branch:$Path" }
            Mock Get-JacocoBranchCoverage { param($Path) "branch:$Path" }
            Get-LanguageRepoCoverage -Language $Language | Should -Be "line:$Path"
            Get-LanguageBranchCoverage -Language $Language | Should -Be "branch:$Path"
        }

        It 'returns null for an unknown language' {
            Get-LanguageRepoCoverage -Language 'Rust' | Should -BeNullOrEmpty
            Get-LanguageBranchCoverage -Language 'Rust' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-LanguageCoverageRow' {
        It 'fails when the audit does not mention the language' {
            (Test-LanguageCoverageRow -AuditText 'nothing here' -Language 'Python').Reason | Should -Match 'does not mention Python'
        }

        It 'fails when no coverage-scoped row mentions the language' {
            (Test-LanguageCoverageRow -AuditText 'Python style PASS' -Language 'Python').Reason | Should -Match 'no coverage-scoped row'
        }

        It 'fails when a coverage row narrows scope' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage PASS (informational only)' -Language 'Python').Reason | Should -Match 'narrows scope'
        }

        It 'fails when coverage rows carry no verdict' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage 90%' -Language 'Python').Reason | Should -Match 'neither a PASS nor a FAIL'
        }

        It 'fails when line coverage is below the floor without a FAIL verdict' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 80).Reason | Should -Match 'below the 85% line coverage floor'
        }

        It 'fails when branch coverage is below the floor' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 90 -BranchPct 50).Reason | Should -Match 'below the 75% branch coverage floor'
        }

        It 'accepts a FAIL verdict for coverage below the line floor' {
            (Test-LanguageCoverageRow -AuditText 'Python coverage FAIL' -Language 'Python' -RepoWidePct 80).Ok | Should -BeTrue
        }
    }

    Context 'Invoke-FeatureReviewCoverageValidation' {
        BeforeAll {
            $script:Folder = 'docs/features/active/2026-10-10-sample'
            $script:Stamp = '2026-10-10T00-00'
            function ConvertTo-ReviewPayload {
                param([string] $Output)
                return (@{ output = $Output } | ConvertTo-Json -Compress)
            }
            function Get-ReviewOutput {
                param([string] $Extra = '', [string] $CodeStamp = $script:Stamp)
                return ("policy-audit-path: $script:Folder/policy-audit.$script:Stamp.md`n" +
                    "code-review-path: $script:Folder/code-review.$CodeStamp.md`n" +
                    "feature-audit-path: $script:Folder/feature-audit.$script:Stamp.md`n$Extra")
            }
        }

        It 'blocks an empty payload' {
            (Invoke-FeatureReviewCoverageValidation -RawPayload '').Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks a malformed payload' {
            (Invoke-FeatureReviewCoverageValidation -RawPayload '{not json').Message | Should -Match 'failed to parse'
        }

        It 'blocks an empty agent output' {
            (Invoke-FeatureReviewCoverageValidation -RawPayload '{"output":""}').Message | Should -Match 'agent output is empty'
        }

        It 'blocks an artifact path outside the required location' {
            $raw = ConvertTo-ReviewPayload -Output "policy-audit-path: elsewhere/policy-audit.md`ncode-review-path: x`nfeature-audit-path: y"
            (Invoke-FeatureReviewCoverageValidation -RawPayload $raw).Message | Should -Match 'outside the required'
        }

        It 'blocks an advertised artifact that does not exist' {
            Mock Get-ArtifactFileContent { @{ Exists = $false; Text = $null; Lines = @() } }
            (Invoke-FeatureReviewCoverageValidation -RawPayload (ConvertTo-ReviewPayload -Output (Get-ReviewOutput))).Message | Should -Match 'no file exists'
        }

        It 'blocks an artifact whose timestamp differs from the policy audit' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('text') }
            $raw = ConvertTo-ReviewPayload -Output (Get-ReviewOutput -CodeStamp '2026-10-10T00-01')
            (Invoke-FeatureReviewCoverageValidation -RawPayload $raw).Message | Should -Match 'code-review artifact must share'
        }

        It 'blocks a remediation-inputs path outside the required location' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('text') }
            $raw = ConvertTo-ReviewPayload -Output (Get-ReviewOutput -Extra 'remediation-inputs-path: elsewhere/r.md')
            (Invoke-FeatureReviewCoverageValidation -RawPayload $raw).Message | Should -Match 'remediation-inputs-path .* is outside'
        }

        It 'blocks a remediation-inputs artifact with a different timestamp' {
            Mock Get-ArtifactFileContent { Get-ArtifactFileResult -Lines @('text') }
            $raw = ConvertTo-ReviewPayload -Output (Get-ReviewOutput -Extra "remediation-inputs-path: $script:Folder/remediation-inputs.2026-10-10T00-05.md")
            (Invoke-FeatureReviewCoverageValidation -RawPayload $raw).Message | Should -Match 'remediation-inputs artifact must share'
        }

        It 'blocks an advertised remediation-inputs artifact that does not exist' {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($Path -like '*remediation-inputs*') { @{ Exists = $false; Text = $null; Lines = @() } } else { Get-ArtifactFileResult -Lines @('text') } }
            $raw = ConvertTo-ReviewPayload -Output (Get-ReviewOutput -Extra "remediation-inputs-path: $script:Folder/remediation-inputs.$script:Stamp.md")
            (Invoke-FeatureReviewCoverageValidation -RawPayload $raw).Message | Should -Match 'was advertised but no file exists'
        }

        It 'allows valid artifacts when the branch changes no tracked language' {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($Path -eq 'artifacts/pr_context.summary.txt') { @{ Exists = $false; Text = $null; Lines = @() } } else { Get-ArtifactFileResult -Lines @('text') } }
            (Invoke-FeatureReviewCoverageValidation -RawPayload (ConvertTo-ReviewPayload -Output (Get-ReviewOutput))).Ok | Should -BeTrue
        }

        It 'blocks when a changed language has no coverage verdict' {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($Path -eq 'artifacts/pr_context.summary.txt') { Get-ArtifactFileResult -Lines @('- src/a.py (+1/-0)') } else { Get-ArtifactFileResult -Lines @('Python coverage 90%') } }
            Mock Get-LanguageRepoCoverage { $null }
            Mock Get-LanguageBranchCoverage { $null }
            (Invoke-FeatureReviewCoverageValidation -RawPayload (ConvertTo-ReviewPayload -Output (Get-ReviewOutput))).Message | Should -Match 'coverage validation failed'
        }

        It 'allows a changed language whose coverage row carries a verdict' {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($Path -eq 'artifacts/pr_context.summary.txt') { Get-ArtifactFileResult -Lines @('- src/a.py (+1/-0)') } else { Get-ArtifactFileResult -Lines @('Python coverage PASS') } }
            Mock Get-LanguageRepoCoverage { 90 }
            Mock Get-LanguageBranchCoverage { 80 }
            (Invoke-FeatureReviewCoverageValidation -RawPayload (ConvertTo-ReviewPayload -Output (Get-ReviewOutput))).Ok | Should -BeTrue
        }
    }

    Context 'entry point' {
        It 'blocks through Write-Error when CLAUDE_HOOK_INPUT is empty' {
            $ErrorActionPreference = 'Continue'
            $priorInput = $env:CLAUDE_HOOK_INPUT
            $thrown = $null
            try {
                $env:CLAUDE_HOOK_INPUT = ''
                try { $null = & $script:HookFile 2>&1 } catch { $thrown = $_ }
            }
            finally { $env:CLAUDE_HOOK_INPUT = $priorInput }
            # The hook sets $ErrorActionPreference = 'Stop', so the Write-Error before exit 1 terminates the script.
            [string]$thrown | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }
    }
}
