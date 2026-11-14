#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for Get-DocsReceiptRevisionDecision in .claude/lib/docs/DocsReceiptRevision.psm1
    (issue #1169).

.DESCRIPTION
    Seeded [System.Random] generation over revisions, ancestry values, changed-path sets, and
    source roots. Each -Because message states the seed and round, so a failure is reproducible.
    The oracle restates the rule independently: the function allows exactly when the receipt
    revision equals the snapshot revision and either equals the head or is an ancestor of it with
    a readable changed-path list that holds no path under a source root. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReceiptRevision.psm1') -Force -ErrorAction Stop
    $script:Seeds = @(1169, 20261113, 7, 424242)
    $script:RevisionPool = @('1111111111111111111111111111111111111111', '2222222222222222222222222222222222222222', '3333333333333333333333333333333333333333')
    $script:Segments = @('src', 'srcx', 'lib', 'docs', 'scripts', 'tools')

    function Get-TestRandomPath {
        param([System.Random] $Random)
        $depth = $Random.Next(1, 4)
        $parts = @(1..$depth | ForEach-Object { $script:Segments[$Random.Next($script:Segments.Count)] })
        return ($parts -join '/')
    }

    function Test-TestUnderRoot {
        param([string] $Path, [string] $Root)
        return ($Path -ceq $Root) -or $Path.StartsWith($Root + '/', [System.StringComparison]::Ordinal)
    }
}

AfterAll {
    Remove-Module -Name DocsReceiptRevision -Force -ErrorAction SilentlyContinue
}

Describe 'DocsReceiptRevision properties' {
    It 'property Get-DocsReceiptRevisionDecision: allows exactly when equality, ancestry, and no drift hold' {
        foreach ($seed in $script:Seeds) {
            $random = [System.Random]::new($seed)
            for ($round = 0; $round -lt 60; $round++) {
                # Arrange
                $receipt = $script:RevisionPool[$random.Next($script:RevisionPool.Count)]
                $snapshot = $script:RevisionPool[$random.Next($script:RevisionPool.Count)]
                $head = $script:RevisionPool[$random.Next($script:RevisionPool.Count)]
                $ancestorChoice = $random.Next(3)
                $isAncestor = if ($ancestorChoice -eq 0) { $null } elseif ($ancestorChoice -eq 1) { $true } else { $false }
                $changed = if ($random.Next(5) -eq 0) { $null } else { [string[]]@(0..($random.Next(0, 5)) | Select-Object -Skip 1 | ForEach-Object { Get-TestRandomPath -Random $random }) }
                $roots = [string[]]@(1..$random.Next(1, 3) | ForEach-Object { $script:Segments[$random.Next($script:Segments.Count)] })
                $drift = $false
                foreach ($path in @($changed)) { foreach ($root in $roots) { if ($null -ne $path -and (Test-TestUnderRoot -Path $path -Root $root)) { $drift = $true } } }
                $expected = ($receipt -ceq $snapshot) -and (($head -ceq $receipt) -or (($true -eq $isAncestor) -and ($null -ne $changed) -and -not $drift))

                # Act
                $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $receipt -SnapshotRevision $snapshot -HeadRevision $head -IsAncestor $isAncestor -ChangedPath $changed -SourceRoot $roots

                # Assert
                $result.Allow | Should -Be $expected -Because "seed=$seed round=$round reason=$($result.Reason)"
                if (-not $result.Allow) {
                    $result.Message | Should -BeLike '*Refresh After Rebase or Source Change*' -Because "seed=$seed round=$round"
                }
            }
        }
    }
}
