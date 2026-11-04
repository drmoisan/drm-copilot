#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure function of .claude/lib/docs/DocsLedgerMutation.psm1.

.DESCRIPTION
    Get-DocsArtifactWritePlan is checked over seeded document sets (each -Because message states
    the seed): plans are sorted ordinally by path and a plan is skipped exactly when the digest
    of its text equals the digest read at load time. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsLedgerMutation.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsLedgerMutation properties' {
    It 'property Get-DocsArtifactWritePlan: ordinal-sorted by path; skipped exactly when the digest is unchanged' {
        $kinds = @('docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt')
        foreach ($seed in Get-DocsLedgerTestSeed) {
            # Arrange
            $random = [System.Random]::new($seed)
            $documents = [System.Collections.Generic.List[object]]::new()
            $expectedSkipped = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            $paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            for ($index = 0; $index -lt 1 + $random.Next(8); $index++) {
                $path = 'estate/' + [string][char](65 + $random.Next(26)) + [string][char](97 + $random.Next(26)) + [string] $random.Next(3) + '.json'
                if (-not $paths.Add($path)) { continue }
                $text = '{"n":' + [string] $random.Next(100) + "}`n"
                $before = switch ($random.Next(3)) {
                    0 { $null }
                    1 { Get-DocsSha256Hex -Text $text }
                    default { Get-DocsSha256Hex -Text ($text + ' ') }
                }
                if ($before -ceq (Get-DocsSha256Hex -Text $text)) { [void]$expectedSkipped.Add($path) }
                $documents.Add(@{ Path = $path; ArtifactKind = $kinds[$random.Next(4)]; ArtifactId = 'id-' + ('b' * 64); Text = $text; BeforeSha256 = $before })
            }

            # Act
            $plans = Get-DocsArtifactWritePlan -Document (Get-DocsLedgerTestShuffle -Item $documents.ToArray() -Seed $seed)

            # Assert
            [string[]] $planPaths = @($plans | ForEach-Object { $_['Path'] })
            [string[]] $sorted = @($planPaths)
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $planPaths | Should -Be $sorted -Because "seed=$seed plans are ordinal-sorted by path"
            $plans.Count | Should -Be $paths.Count -Because "seed=$seed one plan per document"
            foreach ($plan in $plans) {
                $expected = if ($expectedSkipped.Contains($plan['Path'])) { 'skipped' } else { 'planned' }
                $plan['Status'] | Should -BeExactly $expected -Because "seed=$seed $($plan['Path']) is skipped exactly when the digest is unchanged"
                $plan['Sha256'] | Should -BeExactly (Get-DocsSha256Hex -Text $plan['Text']) -Because "seed=$seed"
            }
        }
    }
}
