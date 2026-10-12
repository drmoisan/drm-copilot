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

    Determinism: every case except F824-9 reads its artifacts from the in-memory map that
    Set-ReviewArtifactMap builds, through one literal Get-ArtifactFileContent mock per
    Context, so no case reads live repository state. F824-9 reads this test file and probes
    one absent path; nothing is written, no process is started, and no clock is read.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1')
    $script:RealGetArtifactFileContent = ${function:Get-ArtifactFileContent}
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
    Mock Get-ArtifactFileContent { $null }
    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }
}

Describe 'validate-feature-review-coverage.ps1 (issue #824)' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage

        function ConvertTo-FeatureReviewPayload {
            <#
                Builds the SubagentStop envelope whose last_assistant_message advertises the
                three default review artifacts, followed by any extra output lines.
            #>
            param([string[]] $ExtraLine = @())

            $outputLines = @(
                'policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md'
                'code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md'
                'feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md'
            ) + $ExtraLine
            return ([ordered]@{ session_id = 'f824'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = ($outputLines -join "`n") } | ConvertTo-Json -Compress)
        }

        function Get-ArtifactFileResult {
            # The Get-ArtifactFileContent result shape for an existing file.
            param([string[]] $Lines)
            return @{ Exists = $true; Text = ($Lines -join "`n"); Lines = $Lines }
        }

        function Set-ReviewArtifactMap {
            <#
                Builds the artifact map the Context mock reads: the three default review
                artifacts merged with the given overrides. Values are multi-line strings.
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param([hashtable] $Override = @{})

            $map = @{
                'docs/features/active/foo/policy-audit.2026-05-04T08-00.md'  = 'Python coverage PASS'
                'docs/features/active/foo/code-review.2026-05-04T08-00.md'   = 'code'
                'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' = 'feature'
            }
            foreach ($key in $Override.Keys) { $map[$key] = $Override[$key] }
            if ($PSCmdlet.ShouldProcess('ReviewArtifactMap', 'Set')) { $script:ReviewArtifactMap = $map }
        }
    }

    Context 'issue #824 - governing coverage thresholds (FU-823-1)' {
        BeforeEach {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($script:ReviewArtifactMap.ContainsKey($Path)) { Get-ArtifactFileResult -Lines @($script:ReviewArtifactMap[$Path] -split "`n") } else { @{ Exists = $false; Text = $null; Lines = @() } } }
        }

        It 'F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'artifacts/pr_context.summary.txt' = '- src/foo.py (+1/-0)'
                'artifacts/python/lcov.info'       = "LF:100`nLH:80`nBRF:100`nBRH:65"
                'CLAUDE.md'                        = "Line coverage must remain >= 70%.`nBranch coverage must remain >= 60%."
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeTrue -Because '80 percent line and 65 percent branch meet the stated 70 and 60 percent thresholds'
        }

        It 'F824-2 falls back to the default floors when the root CLAUDE.md states no figures' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'artifacts/pr_context.summary.txt' = '- src/foo.py (+1/-0)'
                'artifacts/python/lcov.info'       = "LF:100`nLH:80`nBRF:100`nBRH:80"
                'CLAUDE.md'                        = 'Project notes without coverage figures.'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 85% line coverage floor'
        }

        It 'F824-3 applies a line-only figure and keeps the default branch floor' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'artifacts/pr_context.summary.txt' = '- src/foo.py (+1/-0)'
                'artifacts/python/lcov.info'       = "LF:100`nLH:80`nBRF:100`nBRH:70"
                'CLAUDE.md'                        = 'Line coverage must remain >= 70%.'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 75% branch coverage floor'
            $result.Message | Should -Not -Match 'line coverage floor'
        }
    }

    Context 'issue #824 - coverage parsing paths (coverage support)' {
        BeforeEach {
            Mock Get-ArtifactFileContent { param([string] $Path) if ($script:ReviewArtifactMap.ContainsKey($Path)) { Get-ArtifactFileResult -Lines @($script:ReviewArtifactMap[$Path] -split "`n") } else { @{ Exists = $false; Text = $null; Lines = @() } } }
        }

        It 'F824-4 reads PowerShell line coverage from the JaCoCo report' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' = 'PowerShell coverage PASS'
                'artifacts/pr_context.summary.txt'                          = '- scripts/foo.ps1 (+1/-0)'
                'artifacts/pester/powershell-coverage.xml'                  = '<report><counter type="LINE" missed="20" covered="80"/></report>'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 85% line coverage floor'
        }

        It 'F824-5 reads branch coverage from the JaCoCo report' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' = 'PowerShell coverage PASS'
                'artifacts/pr_context.summary.txt'                          = '- scripts/foo.ps1 (+1/-0)'
                'artifacts/pester/powershell-coverage.xml'                  = '<report><counter type="LINE" missed="10" covered="90"/><counter type="BRANCH" missed="40" covered="60"/></report>'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'below the 75% branch coverage floor'
        }

        It 'F824-6 rejects a coverage row that narrows scope' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' = 'Python coverage N/A PASS'
                'artifacts/pr_context.summary.txt'                          = '- src/foo.py (+1/-0)'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'narrows scope'
        }

        It 'F824-7 rejects an audit that does not mention a changed language' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'artifacts/pr_context.summary.txt' = '- src/a.ts (+1/-0)'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not mention TypeScript'
        }

        It 'F824-8 rejects a language mention with no coverage-scoped row' -Tag 'Issue824' {
            # Arrange
            Set-ReviewArtifactMap -Override @{
                'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' = 'C# notes PASS'
                'artifacts/pr_context.summary.txt'                          = '- src/A.cs (+1/-0)'
            }

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no coverage-scoped row'
        }
    }

    Context 'issue #824 - artifact reader (coverage support)' {
        BeforeEach {
            # Restore the real Get-ArtifactFileContent over the file-level null mock.
            Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent
        }

        It 'F824-9 reads a tracked file and reports a missing one' -Tag 'Issue824' {
            # Arrange: this test file is the tracked file that is read.
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
            @{ Id = 1; Label = 'an empty payload'; InputText = ''; Pattern = 'payload anomaly' }
            @{ Id = 2; Label = 'a malformed payload'; InputText = '{not json'; Pattern = 'payload anomaly' }
            @{ Id = 3; Label = 'an empty agent output'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":""}'; Pattern = '^validate-feature-review-coverage:' }
            @{ Id = 4; Label = 'an artifact outside the active-feature location'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/other/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md"}'; Pattern = 'outside the required' }
            @{ Id = 5; Label = 'an advertised artifact that does not exist'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T09-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md"}'; Pattern = 'no file exists at that location' }
            @{ Id = 6; Label = 'a remediation-inputs path outside the location'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/other/remediation-inputs.2026-05-04T08-00.md"}'; Pattern = 'remediation-inputs-path .+ is outside' }
            @{ Id = 7; Label = 'a remediation-inputs timestamp that differs'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/features/active/foo/remediation-inputs.2026-05-04T08-01.md"}'; Pattern = 'remediation-inputs artifact must share' }
            @{ Id = 8; Label = 'a remediation-inputs file that does not exist'; InputText = '{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md\ncode-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md\nfeature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md\nremediation-inputs-path: docs/features/active/foo/remediation-inputs.2026-05-04T08-00.md"}'; Pattern = 'was advertised but no file exists' }
        ) {
            # Arrange: the row supplies InputText and the expected message Pattern.

            # Act
            $result = Invoke-FeatureReviewCoverageValidation -InputText $InputText

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match $Pattern
        }
    }
}
