#Requires -Version 7.0

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-prd-feature-output.ps1')

    function Get-CompleteNumericDerivationEvidence {
        param(
            [string] $PrimaryStrategy = "rg '(GetMethod|GetField)\\(' entire repository",
            [string] $CrossCheckStrategy = 'AST traversal of GetMethod and GetField across entire repository',
            [string] $PrimaryMembers = 'A, B',
            [string] $CrossCheckMembers = 'A, B',
            [int] $PrimaryCount = 2,
            [int] $CrossCheckCount = 2
        )

        return @"
## Numeric Derivation Evidence
- Complete Family: GetMethod, GetField
- Exhaustive Search Scope: entire repository source tree
- Inclusion Rules: variable arguments only
- Exclusion Rules: generated calls
- Primary Search Strategy or Query Expression: $PrimaryStrategy
- Primary Member Set: $PrimaryMembers
- Primary Count: $PrimaryCount
- Cross-check Search Strategy or Query Expression: $CrossCheckStrategy
- Cross-check Member Set: $CrossCheckMembers
- Cross-check Count: $CrossCheckCount
- Member-set Comparison: normalized sets match
"@
    }
}

Describe 'validate-prd-feature-output.ps1' {
    It 'allows a spec without numeric acceptance criteria' {
        $result = Test-SpecNumericCriterion -SpecContent "## Acceptance Criteria`n- [ ] A textual criterion"

        $result | Should -BeFalse
    }

    It 'detects a numeric spec acceptance criterion' {
        $result = Test-SpecNumericCriterion -SpecContent "## Acceptance Criteria`n- [ ] 8 call sites are covered"

        $result | Should -BeTrue
    }

    It 'does not count numeric boxes outside Acceptance Criteria' {
        $result = Test-SpecNumericCriterion -SpecContent "- [ ] 99 unrelated boxes`n## Acceptance Criteria`n- [ ] A textual criterion`n## Notes`n- [ ] 7 unrelated boxes"

        $result | Should -BeFalse
    }

    It 'rejects a numeric claim without a complete research record' {
        $result = Test-NumericDerivationEvidence -Content "## Numeric Derivation Evidence`n- Family: GetMethod"

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'missing'
    }

    It 'rejects a research record whose independent cross-check disagrees' {
        $content = Get-CompleteNumericDerivationEvidence -CrossCheckMembers 'A, B, C' -CrossCheckCount 3

        $result = Test-NumericDerivationEvidence -Content $content

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'disagree'
    }

    It 'accepts an independently exhaustive complete-family research record' {
        $content = Get-CompleteNumericDerivationEvidence

        $result = Test-NumericDerivationEvidence -Content $content

        $result.Ok | Should -BeTrue
    }

    It 'rejects empty, malformed, and output-free invocation payloads' {
        (Invoke-PrdFeatureOutputValidation -RawPayload '').Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -RawPayload '{bad').Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -RawPayload '{}').Ok | Should -BeFalse
    }

    It 'rejects missing and nonexistent spec paths' {
        Mock Test-Path { $false }

        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = 'spec-path: missing.md' } | ConvertTo-Json -Compress)).Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = 'spec-path: nonexistent.md' } | ConvertTo-Json -Compress)).Ok | Should -BeFalse
    }

    It 'accepts a nonnumeric spec without research evidence' {
        Mock Test-Path { $true }
        Mock Get-Content { '## Acceptance Criteria' + [Environment]::NewLine + '- [ ] A textual criterion' }

        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = 'spec-path: textual.md' } | ConvertTo-Json -Compress)).Ok | Should -BeTrue
    }

    It 'rejects numeric specs with missing or nonexistent research paths' {
        Mock Test-Path { param($LiteralPath) $LiteralPath -eq 'numeric.md' }
        Mock Get-Content { '## Acceptance Criteria' + [Environment]::NewLine + '- [ ] 1 call site is covered' }

        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = 'spec-path: numeric.md' } | ConvertTo-Json -Compress)).Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = "spec-path: numeric.md`nresearch-path: missing.md" } | ConvertTo-Json -Compress)).Ok | Should -BeFalse
    }

    It 'accepts matching numeric provenance and extracts artifact labels' {
        $complete = Get-CompleteNumericDerivationEvidence
        Mock Test-Path { $true }
        Mock Get-Content { param($LiteralPath) if ($LiteralPath -eq 'numeric.md') { "## Acceptance Criteria`n- [ ] 1 call" } else { $complete } }

        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = "spec-path: numeric.md`nresearch-path: research.md" } | ConvertTo-Json -Compress)).Ok | Should -BeTrue
        Get-ArtifactPathFromOutput -Output 'spec-path: numeric.md' -Label 'spec-path' | Should -Be 'numeric.md'
    }

    It 'rejects every missing numeric-evidence field and a missing section' {
        $fields = @('Complete Family', 'Exhaustive Search Scope', 'Inclusion Rules', 'Exclusion Rules', 'Primary Search Strategy or Query Expression', 'Primary Member Set', 'Primary Count', 'Cross-check Search Strategy or Query Expression', 'Cross-check Member Set', 'Cross-check Count', 'Member-set Comparison')
        foreach ($field in $fields) {
            $content = (Get-CompleteNumericDerivationEvidence) -replace "- $([regex]::Escape($field)): .+", "- $($field):"

            (Test-NumericDerivationEvidence -Content $content).Ok | Should -BeFalse
        }

        (Test-NumericDerivationEvidence -Content '## Other Evidence').Ok | Should -BeFalse
    }

    It 'rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records' {
        $copiedCount = Get-CompleteNumericDerivationEvidence -CrossCheckCount 3
        $duplicateSearch = Get-CompleteNumericDerivationEvidence -CrossCheckStrategy "rg '(GetMethod|GetField)\\(' entire repository"
        $memberMismatch = Get-CompleteNumericDerivationEvidence -CrossCheckMembers 'A, C'
        $scopeMissing = (Get-CompleteNumericDerivationEvidence) -replace '- Exhaustive Search Scope: .+', '- Exhaustive Search Scope: focused directory'
        $narrowSearch = Get-CompleteNumericDerivationEvidence -PrimaryStrategy 'narrow named-pattern GetMethod('

        foreach ($content in @($copiedCount, $duplicateSearch, $memberMismatch, $scopeMissing, $narrowSearch)) {
            (Test-NumericDerivationEvidence -Content $content).Ok | Should -BeFalse
        }
    }
}
