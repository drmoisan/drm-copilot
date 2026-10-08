<#
.SYNOPSIS
    Back-compat replay of the remediation-loop checkpoint corpus (issue #484).

.DESCRIPTION
    Each committed checkpoint under
    tests/fixtures/orchestrator_state_remediation_loop_backcompat carries none of
    the #484 keys. The companion file
    tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json
    records, under its powershell section, the full ordered error list the
    unmodified modules returned for each fixture in each supported mode. This
    suite replays every fixture and requires the same list with case-sensitive
    element comparison, so the remediation-loop change cannot alter the output
    for a checkpoint that does not use the new keys.

    The fixtures are committed and read in place. No temporary file is created
    and no external process is started.
#>

# Discovery-time corpus enumeration. Pester executes the file body during
# discovery, so the case list must be built here for -ForEach to generate one It
# per fixture and mode.
$fixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop_backcompat").Path
$fixtureFile = @(
    Get-ChildItem -LiteralPath $fixtureDirectory -Filter '*.json' -File |
        Sort-Object -Property Name
)
$modeName = @('plain', 'require_complete', 'require_pr_creation_ready')
$replayCase = @(
    foreach ($file in $fixtureFile) {
        foreach ($mode in $modeName) {
            @{ Stem = $file.BaseName; FixturePath = $file.FullName; Mode = $mode }
        }
    }
)

BeforeAll {
    # Resolve the module directory four levels up: orchestrator-state ->
    # claude-lib -> scripts -> tests -> repo root.
    $moduleDirectory = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateUnconditional.psm1') -Force
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorState.psm1') -Force

    $expectedPath = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json").Path
    $script:Expected = Get-Content -LiteralPath $expectedPath -Raw | ConvertFrom-Json -AsHashtable

    # Split a readiness Output string into its error lines; empty Output is an
    # empty list.
    function Split-ReadinessOutput {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyString()]
            [string] $Text
        )

        if ([string]::IsNullOrEmpty($Text)) {
            return , [string[]]@()
        }
        return , [string[]]($Text -split "`r?`n")
    }

    # Return the error list the unmodified entry point produces for one mode.
    function Get-ModeError {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param(
            [Parameter(Mandatory = $true)]
            [string] $Path,
            [Parameter(Mandatory = $true)]
            [string] $Mode
        )

        switch -CaseSensitive ($Mode) {
            'plain' {
                $state = (Get-OrchestratorStateCheckpoint -CheckpointPath $Path).State
                return , [string[]]@(Get-OrchestratorStateUnconditionalError -State $state)
            }
            'require_complete' {
                return , (Split-ReadinessOutput -Text (Test-OrchestratorStateCompletionReadiness -CheckpointPath $Path).Output)
            }
            'require_pr_creation_ready' {
                return , (Split-ReadinessOutput -Text (Test-OrchestratorStatePrCreationReadiness -CheckpointPath $Path).Output)
            }
            default {
                throw "Unknown back-compat mode: $Mode"
            }
        }
    }
}

Describe 'Remediation-loop back-compat corpus discovery' {
    BeforeAll {
        $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop_backcompat").Path
    }

    It 'discovers exactly eleven remediation back-compat fixtures' {
        # Arrange / Act: enumerate the committed corpus directory.
        $discovered = @(Get-ChildItem -LiteralPath $script:FixtureDirectory -Filter '*.json' -File).Count

        # Assert: the corpus is fixed at eleven checkpoints.
        $discovered | Should -Be 11
    }
}

Describe 'Remediation-loop back-compat replay' {
    It 'keeps the captured <Mode> error list for <Stem>' -ForEach $replayCase {
        # Arrange: the captured expectation for this fixture and mode.
        $expected = [string[]]@($script:Expected[$Stem]['powershell'][$Mode])

        # Act
        $actual = Get-ModeError -Path $FixturePath -Mode $Mode

        # Assert: same length, then case-sensitive equality element by element.
        $actual.Count | Should -Be $expected.Count
        $mismatch = @(
            for ($index = 0; $index -lt $expected.Count; $index++) {
                if (-not ($actual[$index] -ceq $expected[$index])) {
                    "#${index}: expected '$($expected[$index])' got '$($actual[$index])'"
                }
            }
        )
        $mismatch | Should -BeNullOrEmpty
    }
}
