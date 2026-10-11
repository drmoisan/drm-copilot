#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Regression tests for the guarded feature-review-coverage-thresholds.ps1 dot-source in
    validate-feature-review-coverage.ps1 (issue #852, 786 import-guard rule).

.DESCRIPTION
    The thresholds dot-source must sit in its own single-statement try whose catch records the
    failure through Add-HookDependencyFailure, so a load failure blocks the SubagentStop hook
    (exit 2) instead of throwing. Each case fails only that dot-source with a literal-scriptblock
    Join-Path mock (the B1 harness of hook-dependency-failure.Claude.Tests.ps1) and runs for the
    repository copy and the bundle mirror.

    TG1 drives the hook through the & route and reads exit code and stderr. TG2 dot-sources the
    hook and reads the recorded failure. TG3 calls Invoke-FeatureReviewCoverageValidation after
    the TG2 arrangement. No test creates, renames, moves, or deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1')
    Mock Get-ArtifactFileContent { $null }
    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }
}

Describe 'validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'

        function Invoke-ThresholdsGuardHookProcess {
            # Runs one hook copy through the & route with stderr and CLAUDE_HOOK_INPUT redirected; both restored in finally.
            param([string] $Hook)
            $priorError = [System.Console]::Error
            $priorInput = $env:CLAUDE_HOOK_INPUT
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                $env:CLAUDE_HOOK_INPUT = '{"output":""}'
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $null = & (Join-Path $script:RepoRoot $Hook)
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetError($priorError)
                $env:CLAUDE_HOOK_INPUT = $priorInput
            }
            return [pscustomobject]@{ Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }

        function Initialize-ThresholdsGuardDependencyState {
            # Clears the script-scope dependency-failure state the hook and its guard helper write.
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }
    }

    It 'TG1: <Copy> exits 2 naming feature-review-coverage-thresholds.ps1 when the thresholds dot-source fails' -ForEach @(
        @{ Copy = 'claude'; Hook = '.claude/hooks/validate-feature-review-coverage.ps1' }
        @{ Copy = 'bundle'; Hook = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1' }
    ) {
        # Arrange: fail only the thresholds dot-source; every other Join-Path call runs normally.
        Mock Join-Path { throw 'simulated load failure: feature-review-coverage-thresholds.ps1' } -ParameterFilter { $ChildPath -eq 'feature-review-coverage-thresholds.ps1' }
        Initialize-ThresholdsGuardDependencyState

        # Act
        try { $result = Invoke-ThresholdsGuardHookProcess -Hook $Hook }
        finally { Initialize-ThresholdsGuardDependencyState }

        # Assert
        $result.ExitCode | Should -Be 2 -Because $result.Stderr
        $result.Stderr.StartsWith('validate-feature-review-coverage:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('feature-review-coverage-thresholds.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'TG2: <Copy> records the thresholds load failure through Add-HookDependencyFailure when dot-sourced' -ForEach @(
        @{ Copy = 'claude'; Hook = '.claude/hooks/validate-feature-review-coverage.ps1' }
        @{ Copy = 'bundle'; Hook = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1' }
    ) {
        # Arrange: fail only the thresholds dot-source and start from an empty failure list.
        Mock Join-Path { throw 'simulated load failure: feature-review-coverage-thresholds.ps1' } -ParameterFilter { $ChildPath -eq 'feature-review-coverage-thresholds.ps1' }
        Initialize-ThresholdsGuardDependencyState
        $hookPath = Join-Path $script:RepoRoot $Hook
        $thrown = $null

        # Act: the try statement does not open a scope, so the dot-source defines the hook functions in this It.
        try {
            try { . $hookPath } catch { $thrown = $_ }
            $recorded = Test-HookDependencyFailure
            $firstName = if ($recorded) { $script:HookDependencyFailures[0].Name } else { $null }
        }
        finally { Initialize-ThresholdsGuardDependencyState }

        # Assert
        $thrown | Should -BeNullOrEmpty -Because 'the guarded dot-source must not throw'
        $recorded | Should -BeTrue
        $firstName | Should -Be 'feature-review-coverage-thresholds.ps1'
    }

    It 'TG3: <Copy> Invoke-FeatureReviewCoverageValidation returns ExitCode 2 when the thresholds dependency failure is recorded' -ForEach @(
        @{ Copy = 'claude'; Hook = '.claude/hooks/validate-feature-review-coverage.ps1' }
        @{ Copy = 'bundle'; Hook = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1' }
    ) {
        # Arrange: the TG2 arrangement, which records the thresholds failure in this It.
        Mock Join-Path { throw 'simulated load failure: feature-review-coverage-thresholds.ps1' } -ParameterFilter { $ChildPath -eq 'feature-review-coverage-thresholds.ps1' }
        Initialize-ThresholdsGuardDependencyState
        $hookPath = Join-Path $script:RepoRoot $Hook

        # Act
        try {
            . $hookPath
            $decision = Invoke-FeatureReviewCoverageValidation -RawPayload '{"output":""}'
        }
        finally { Initialize-ThresholdsGuardDependencyState }

        # Assert
        $decision.ExitCode | Should -Be 2
        $decision.Reason | Should -BeLike '*feature-review-coverage-thresholds.ps1*'
    }
}
