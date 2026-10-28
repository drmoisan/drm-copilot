#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Repository gate for the 800-line hard limit of the tiered file-size policy (issue #990).

.DESCRIPTION
    Discovers every covered file on disk under the repository root with a traversal that does
    not descend into excluded directories (the excluded names of Test-FileSizeCoveredPath and
    .claude/worktrees/), counts each file's logical lines with Get-FileSizeLogicalLineCount,
    reads config/file-size-baseline.json with Get-Content, and applies the strict ratchet with
    Get-FileSizeRatchetViolation:

      - a covered file above 800 lines with no baseline entry fails;
      - a baselined file that grows fails, and one that shrinks fails until its entry is
        tightened;
      - an entry for a file at or below 800 lines, or for a file that no longer exists, fails.

    No gate fails for a file of 500 through 800 lines. The suite starts no process and needs
    no git history, so it runs in the existing PowerShell CI shards on a depth-one checkout.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    Import-Module -Name (Join-Path $script:RepoRoot '.claude/lib/file-size-policy/FileSizePolicy.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path $script:RepoRoot 'scripts/ci/FileSizeBaseline.psm1') -Force -ErrorAction Stop

    # Directory names never descended into; a file below one is never covered.
    $script:ExcludedDirectory = @('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs',
        'build', '.venv', 'venv', 'env', '__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', '.tox',
        '.nox', 'htmlcov', '.vscode-test')

    # Breadth-first traversal from the root. Returns repository-relative forward-slash paths of
    # the covered files and skips excluded directories and .claude/worktrees without entering them.
    function Get-FileSizeCoveredFileOnDisk {
        param([Parameter(Mandatory)][string] $Root)
        $pending = [System.Collections.Generic.Queue[string]]::new()
        $pending.Enqueue('')
        $found = [System.Collections.Generic.List[string]]::new()
        while ($pending.Count -gt 0) {
            $relativeDirectory = $pending.Dequeue()
            $directory = if ($relativeDirectory) { Join-Path $Root $relativeDirectory } else { $Root }
            foreach ($item in @(Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop)) {
                $relative = if ($relativeDirectory) { "$relativeDirectory/$($item.Name)" } else { $item.Name }
                if ($item.PSIsContainer) {
                    $skip = ($script:ExcludedDirectory -ccontains $item.Name) -or ($relative -eq '.claude/worktrees')
                    if (-not $skip) { $pending.Enqueue($relative) }
                } elseif (Test-FileSizeCoveredPath -RelativePath $relative) {
                    $found.Add($relative)
                }
            }
        }
        return , $found.ToArray()
    }

    $script:CoveredPath = Get-FileSizeCoveredFileOnDisk -Root $script:RepoRoot
    $script:CurrentSize = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    foreach ($path in $script:CoveredPath) {
        $text = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $path))
        $script:CurrentSize[$path] = Get-FileSizeLogicalLineCount -Content $text
    }

    $baselinePath = Join-Path $script:RepoRoot 'config/file-size-baseline.json'
    $script:BaselineText = Get-Content -LiteralPath $baselinePath -Raw -ErrorAction Stop
    $script:Baseline = ConvertFrom-FileSizeBaselineJson -Json $script:BaselineText
}

AfterAll {
    Remove-Module -Name FileSizeBaseline -Force -ErrorAction SilentlyContinue
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'File-size policy repository gate' {
    It 'discovers a non-empty covered population that includes the policy module' {
        # Assert: an empty or truncated discovery would make the ratchet vacuous.
        $script:CoveredPath.Count | Should -BeGreaterThan 0
        $script:CoveredPath | Should -Contain '.claude/lib/file-size-policy/FileSizePolicy.psm1'
    }

    It 'parses the baseline with the policy hard limit' {
        $script:Baseline.HardLimit | Should -Be (Get-FileSizePolicyLimit).HardLimit
    }

    It 'keeps the baseline keys in ordinal order' {
        # Arrange
        [string[]] $keys = @($script:Baseline.Files.Keys)
        [string[]] $sorted = @($keys)
        [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)

        # Assert: the generator writes ordinal order; a hand edit out of order is rejected.
        $keys | Should -Be $sorted
    }

    It 'reports zero ratchet violations against config/file-size-baseline.json' {
        # Act
        $violations = @(Get-FileSizeRatchetViolation -CurrentSize $script:CurrentSize -Baseline $script:Baseline.Files)

        # Assert: each violation names its path and the ratchet rule it broke.
        $report = @($violations | ForEach-Object { "$($_.Path): $($_.Message)" }) -join "`n"
        $violations.Count | Should -Be 0 -Because "the file-size ratchet reported:`n$report"
    }
}
