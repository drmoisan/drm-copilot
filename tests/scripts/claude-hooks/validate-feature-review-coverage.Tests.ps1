#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-feature-review-coverage.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1'
    . $hookPath
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
    Mock Get-ArtifactFileContent { $null }
    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }
}

Describe 'validate-feature-review-coverage.ps1' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
    }

    Context 'required artifact tokens' {
        It 'blocks when required review artifact tokens are missing' {
            $raw = @{ output = 'Review complete.' } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'policy-audit-path'
            $result.Message | Should -Match 'code-review-path'
            $result.Message | Should -Match 'feature-audit-path'
        }

        It 'blocks when required review artifacts do not share the same timestamp' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                if ($Path -eq 'docs/features/active/foo/policy-audit.2026-05-04T08-00.md') {
                    return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') }
                }
                if ($Path -eq 'docs/features/active/foo/code-review.2026-05-04T08-01.md') {
                    return @{ Exists = $true; Text = 'code'; Lines = @('code') }
                }
                if ($Path -eq 'docs/features/active/foo/feature-audit.2026-05-04T08-00.md') {
                    return @{ Exists = $true; Text = 'feature'; Lines = @('feature') }
                }
                if ($Path -eq 'artifacts/pr_context.summary.txt') {
                    return @{ Exists = $false; Text = $null; Lines = @() }
                }
                return @{ Exists = $false; Text = $null; Lines = @() }
            }
            $raw = @{
                output = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-01.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'same feature folder and timestamp'
        }
    }

    Context 'coverage verdict enforcement' {
        It 'blocks when a changed language lacks an explicit PASS or FAIL coverage verdict' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' {
                        return @{
                            Exists = $true
                            Text   = @"
## Test Coverage Detail
Python coverage artifact present.
"@
                            Lines  = @('## Test Coverage Detail', 'Python coverage artifact present.')
                        }
                    }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' {
                        return @{ Exists = $true; Text = 'code'; Lines = @('code') }
                    }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' {
                        return @{ Exists = $true; Text = 'feature'; Lines = @('feature') }
                    }
                    'artifacts/pr_context.summary.txt' {
                        return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') }
                    }
                    default {
                        return @{ Exists = $false; Text = $null; Lines = @() }
                    }
                }
            }
            $raw = @{
                output = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PASS nor a FAIL verdict'
        }

        It 'allows termination when required artifacts exist and no changed languages need coverage validation' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                if ($Path -eq 'artifacts/pr_context.summary.txt') {
                    return @{ Exists = $false; Text = $null; Lines = @() }
                }
                return @{ Exists = $true; Text = 'ok'; Lines = @('ok') }
            }
            $raw = @{
                output = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }
}
