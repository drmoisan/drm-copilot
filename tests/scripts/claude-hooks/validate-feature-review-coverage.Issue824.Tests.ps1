#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Issue #824 follow-up FU-823-1 cases for validate-feature-review-coverage.ps1.

.DESCRIPTION
    The first Context pins FU-823-1: the feature-review hook applies the coverage
    thresholds the repository's root CLAUDE.md states, and each metric falls back to its
    default (85 percent line, 75 percent branch) when the root CLAUDE.md states none.

    The remaining Contexts are coverage support. They drive the artifact-parsing and
    review-artifact validation paths of the hook that no other suite reaches, so the
    modified hook meets the repository line-coverage threshold.

    Determinism: every case except F824-9 mocks Get-ArtifactFileContent with literal
    values, so no case reads live repository state. F824-9 reads this test file and probes
    one absent path; nothing is written, no process is started, and no clock is read.
#>

Describe 'validate-feature-review-coverage.ps1 (issue #824)' {
    BeforeAll {
        . "$PSScriptRoot/../../../.claude/hooks/validate-feature-review-coverage.ps1"

        function ConvertTo-FeatureReviewPayload {
            <#
                Builds the SubagentStop payload that advertises the three default review
                artifacts, followed by any extra output lines.
            #>
            param([string[]] $ExtraLine = @())

            $outputLines = @(
                'policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md'
                'code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md'
                'feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md'
            ) + $ExtraLine
            return (@{ output = ($outputLines -join "`n") } | ConvertTo-Json -Compress)
        }
    }

    Context 'issue #824 - governing coverage thresholds (FU-823-1)' {
        It 'F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') } }
                    'artifacts/python/lcov.info' { return @{ Exists = $true; Text = 'LF:100'; Lines = @('LF:100', 'LH:80', 'BRF:100', 'BRH:65') } }
                    'CLAUDE.md' { return @{ Exists = $true; Text = "Line coverage must remain >= 70%.`nBranch coverage must remain >= 60%."; Lines = @('Line coverage must remain >= 70%.', 'Branch coverage must remain >= 60%.') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue -Because '80 percent line and 65 percent branch meet the stated 70 and 60 percent thresholds'
        }

        It 'F824-2 falls back to the default floors when the root CLAUDE.md states no figures' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') } }
                    'artifacts/python/lcov.info' { return @{ Exists = $true; Text = 'LF:100'; Lines = @('LF:100', 'LH:80', 'BRF:100', 'BRH:80') } }
                    'CLAUDE.md' { return @{ Exists = $true; Text = 'Project notes without coverage figures.'; Lines = @('Project notes without coverage figures.') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 85% line coverage floor'
        }

        It 'F824-3 applies a line-only figure and keeps the default branch floor' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') } }
                    'artifacts/python/lcov.info' { return @{ Exists = $true; Text = 'LF:100'; Lines = @('LF:100', 'LH:80', 'BRF:100', 'BRH:70') } }
                    'CLAUDE.md' { return @{ Exists = $true; Text = 'Line coverage must remain >= 70%.'; Lines = @('Line coverage must remain >= 70%.') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 75% branch coverage floor'
            $result.Message | Should -Not -Match 'line coverage floor'
        }
    }

    Context 'issue #824 - coverage parsing paths (coverage support)' {
        It 'F824-4 reads PowerShell line coverage from the JaCoCo report' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'PowerShell coverage PASS'; Lines = @('PowerShell coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- scripts/foo.ps1 (+1/-0)'; Lines = @('- scripts/foo.ps1 (+1/-0)') } }
                    'artifacts/pester/powershell-coverage.xml' { return @{ Exists = $true; Text = '<report><counter type="LINE" missed="20" covered="80"/></report>'; Lines = @('<report><counter type="LINE" missed="20" covered="80"/></report>') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 85% line coverage floor'
        }

        It 'F824-5 reads branch coverage from the JaCoCo report' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'PowerShell coverage PASS'; Lines = @('PowerShell coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- scripts/foo.ps1 (+1/-0)'; Lines = @('- scripts/foo.ps1 (+1/-0)') } }
                    'artifacts/pester/powershell-coverage.xml' { return @{ Exists = $true; Text = '<report><counter type="LINE" missed="10" covered="90"/><counter type="BRANCH" missed="40" covered="60"/></report>'; Lines = @('<report/>') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 75% branch coverage floor'
        }

        It 'F824-6 rejects a coverage row that narrows scope' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'Python coverage N/A PASS'; Lines = @('Python coverage N/A PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'narrows scope'
        }

        It 'F824-7 rejects an audit that does not mention a changed language' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/a.ts (+1/-0)'; Lines = @('- src/a.ts (+1/-0)') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not mention TypeScript'
        }

        It 'F824-8 rejects a language mention with no coverage-scoped row' -Tag 'Issue824' {
            # Arrange
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'C# notes PASS'; Lines = @('C# notes PASS') } }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'code'; Lines = @('code') } }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' { return @{ Exists = $true; Text = 'feature'; Lines = @('feature') } }
                    'artifacts/pr_context.summary.txt' { return @{ Exists = $true; Text = '- src/A.cs (+1/-0)'; Lines = @('- src/A.cs (+1/-0)') } }
                    default { return @{ Exists = $false; Text = $null; Lines = @() } }
                }
            }
            $raw = ConvertTo-FeatureReviewPayload

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no coverage-scoped row'
        }

        It 'F824-9 reads a tracked file and reports a missing one' -Tag 'Issue824' {
            # Arrange: no mock; this test file is the tracked file that is read.
            $absentPath = 'docs/features/active/__absent__/none.md'

            # Act
            $present = Get-ArtifactFileContent -Path $PSCommandPath
            $absent = Get-ArtifactFileContent -Path $absentPath

            # Assert
            $present.Exists | Should -BeTrue
            @($present.Lines).Count | Should -BeGreaterThan 1
            $absent.Exists | Should -BeFalse
        }
    }

    Context 'issue #824 - review artifact validation paths (coverage support)' {
        BeforeEach {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                if ($Path -match '^docs/features/active/foo/(policy-audit|code-review|feature-audit)\.2026-05-04T08-00\.md$') {
                    return @{ Exists = $true; Text = 'ok'; Lines = @('ok') }
                }
                return @{ Exists = $false; Text = $null; Lines = @() }
            }
        }

        It 'F824-V<Id> blocks <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'an empty payload'; RawPayload = ''; Pattern = 'CLAUDE_HOOK_INPUT is empty' }
            @{ Id = 2; Label = 'a malformed payload'; RawPayload = '{not json'; Pattern = 'failed to parse CLAUDE_HOOK_INPUT' }
            @{ Id = 3; Label = 'an empty agent output'; RawPayload = '{"output":""}'; Pattern = 'agent output is empty' }
            @{ Id = 4; Label = 'an artifact outside the active-feature location'; RawPayload = '{"output":"policy-audit-path: docs/other/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md"}'; Pattern = 'outside the required' }
            @{ Id = 5; Label = 'an advertised artifact that does not exist'; RawPayload = '{"output":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T09-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md"}'; Pattern = 'no file exists at that location' }
            @{ Id = 6; Label = 'a remediation-inputs path outside the location'; RawPayload = '{"output":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/other/remediation-inputs.2026-05-04T08-00.md"}'; Pattern = 'remediation-inputs-path .+ is outside' }
            @{ Id = 7; Label = 'a remediation-inputs timestamp that differs'; RawPayload = '{"output":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/features/active/foo/remediation-inputs.2026-05-04T08-01.md"}'; Pattern = 'remediation-inputs artifact must share' }
            @{ Id = 8; Label = 'a remediation-inputs file that does not exist'; RawPayload = '{"output":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/features/active/foo/remediation-inputs.2026-05-04T08-00.md"}'; Pattern = 'was advertised but no file exists' }
        ) {
            # Arrange: the row supplies RawPayload and the expected message Pattern.

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -RawPayload $RawPayload

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match $Pattern
        }
    }
}
