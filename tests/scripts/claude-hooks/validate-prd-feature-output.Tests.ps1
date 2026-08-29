#Requires -Version 7.0

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-prd-feature-output.ps1')
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
        $content = @'
## Numeric Derivation Evidence
- Family: GetMethod, GetField
- Inclusion Rules: variable arguments
- Exclusion Rules: generated calls
- Member Set: A, B
- Primary Count: 2
- Cross-check Count: 3
'@

        $result = Test-NumericDerivationEvidence -Content $content

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'disagree'
    }

    It 'accepts a complete matching research record' {
        $content = @'
## Numeric Derivation Evidence
- Family: GetMethod, GetField
- Inclusion Rules: variable arguments
- Exclusion Rules: generated calls
- Member Set: A, B
- Primary Count: 2
- Cross-check Count: 2
'@

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
        $complete = "## Numeric Derivation Evidence`n- Family: GetMethod`n- Inclusion Rules: all`n- Exclusion Rules: none`n- Member Set: A`n- Primary Count: 1`n- Cross-check Count: 1"
        Mock Test-Path { $true }
        Mock Get-Content { param($LiteralPath) if ($LiteralPath -eq 'numeric.md') { "## Acceptance Criteria`n- [ ] 1 call" } else { $complete } }

        (Invoke-PrdFeatureOutputValidation -RawPayload (@{ output = "spec-path: numeric.md`nresearch-path: research.md" } | ConvertTo-Json -Compress)).Ok | Should -BeTrue
        Get-ArtifactPathFromOutput -Output 'spec-path: numeric.md' -Label 'spec-path' | Should -Be 'numeric.md'
    }

    It 'rejects every missing numeric-evidence field and a missing section' {
        $fields = @('Family', 'Inclusion Rules', 'Exclusion Rules', 'Member Set', 'Primary Count', 'Cross-check Count')
        foreach ($field in $fields) {
            $content = @(
                '## Numeric Derivation Evidence',
                '- Family: GetMethod',
                '- Inclusion Rules: all',
                '- Exclusion Rules: none',
                '- Member Set: A',
                '- Primary Count: 1',
                '- Cross-check Count: 1'
            ) | Where-Object { $_ -notmatch "^- $([regex]::Escape($field)):" }

            (Test-NumericDerivationEvidence -Content ($content -join [Environment]::NewLine)).Ok | Should -BeFalse
        }

        (Test-NumericDerivationEvidence -Content '## Other Evidence').Ok | Should -BeFalse
    }
}
