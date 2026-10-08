#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-runtime parity assertions over the blocked_reason corpus (#523).

.DESCRIPTION
    Enumerates tests/fixtures/orchestrator_state_blocked_reason/*.json at discovery
    time and asserts that the PowerShell validators emit exactly the blocked_reason
    errors each file records:
      - Get-OrchestratorStateUnconditionalError on the case checkpoint, filtered to
        errors containing blocked_reason, equals expected_errors;
      - Get-OrchestratorStateCompletionBlockedReasonError equals
        expected_completion_errors where that key is present.

    The same corpus is asserted by the Python and Jest parity suites, so the corpus
    binds the three runtimes. The pattern follows
    tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1. Corpus
    files are read in place; no file is written.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Discovery-time case lists are consumed by -ForEach and It blocks')]
param()

# Discovery-time enumeration. Pester executes the file body during discovery, so
# the case lists must be built here for -ForEach.
$corpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason").Path
$corpusFile = @(Get-ChildItem -LiteralPath $corpusDirectory -Filter '*.json' -File | Sort-Object -Property Name)
$corpusCase = @(
    foreach ($file in $corpusFile) {
        $document = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        @{
            Stem          = $file.BaseName
            CasePath      = $file.FullName
            HasCompletion = ($document.PSObject.Properties.Name -contains 'expected_completion_errors')
        }
    }
)
$completionCase = @($corpusCase | Where-Object { $_.HasCompletion })

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCompletionChecks.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateUnconditional.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorState.psm1') -Force

    # Run-phase copies of the corpus location and its floor. Discovery-time
    # variables are not visible inside It blocks, so they are resolved again here.
    # The floor guards against an empty or partial enumeration passing vacuously.
    $script:CorpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason").Path
    $MinimumCorpusCount = 20
    $script:MinimumCorpusCount = $MinimumCorpusCount

    # Return the ordered mismatches between two string arrays, compared
    # case-sensitively; an empty result means the arrays are equal.
    function script:Get-OrderedMismatch {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [string[]] $Actual,

            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [string[]] $Expected
        )

        if ($Actual.Count -ne $Expected.Count) {
            "count actual=$($Actual.Count) expected=$($Expected.Count): $($Actual -join ' | ')"
            return
        }
        for ($index = 0; $index -lt $Expected.Count; $index++) {
            if (-not ($Actual[$index] -ceq $Expected[$index])) {
                "[$index] actual='$($Actual[$index])' expected='$($Expected[$index])'"
            }
        }
    }
}

Describe 'OrchestratorState blocked_reason corpus parity' {
    It 'discovers at least the minimum corpus count' {
        # Arrange / Act
        $count = @(Get-ChildItem -LiteralPath $script:CorpusDirectory -Filter '*.json' -File).Count

        # Assert
        $count | Should -BeGreaterOrEqual $script:MinimumCorpusCount
    }

    It '<Stem>: name equals the file stem' -ForEach $corpusCase {
        # Act
        $document = Get-Content -LiteralPath $CasePath -Raw | ConvertFrom-Json

        # Assert
        $document.name | Should -BeExactly $Stem
    }

    It '<Stem>: plain blocked_reason errors match the corpus' -ForEach $corpusCase {
        # Arrange
        $document = Get-Content -LiteralPath $CasePath -Raw | ConvertFrom-Json
        $expected = [string[]]@($document.expected_errors)

        # Act
        $actual = [string[]]@(Get-OrchestratorStateUnconditionalError -State $document.checkpoint | Where-Object { $_ -clike '*blocked_reason*' })

        # Assert
        $mismatch = @(Get-OrderedMismatch -Actual $actual -Expected $expected)
        $mismatch.Count | Should -Be 0 -Because ($mismatch -join '; ')
    }

    It '<Stem>: completion blocked_reason errors match the corpus' -ForEach $completionCase {
        # Arrange
        $document = Get-Content -LiteralPath $CasePath -Raw | ConvertFrom-Json
        $expected = [string[]]@($document.expected_completion_errors)

        # Act
        $actual = [string[]]@(Get-OrchestratorStateCompletionBlockedReasonError -State $document.checkpoint)

        # Assert
        $mismatch = @(Get-OrderedMismatch -Actual $actual -Expected $expected)
        $mismatch.Count | Should -Be 0 -Because ($mismatch -join '; ')
    }
}
