Set-StrictMode -Version Latest

# Unit tests for the pure functions of scripts/powershell/PoshQC/PoshQC.Parallel.psm1 (issue #1048):
# the worker-count default, the JUnit merge, and the shard-weight conversion and export.
# Every case uses in-memory XML strings; the export case writes through an injected seam, so no file is read or written.

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force

    # Builds one shard's JUnit text. Each suite is @{ Name; Tests; Failures; Time }.
    $script:NewJunit = {
        param([object[]] $Suites, [string] $RootTime)
        $tests = 0
        $failures = 0
        $suiteText = foreach ($suite in $Suites) {
            $tests += $suite.Tests
            $failures += $suite.Failures
            '<testsuite name="{0}" tests="{1}" errors="0" failures="{2}" hostname="h" id="7" skipped="0" disabled="0" package="{0}" time="{3}"><testcase name="t" classname="c" status="Passed" assertions="0" time="0.1" /></testsuite>' -f $suite.Name, $suite.Tests, $suite.Failures, $suite.Time
        }
        '<?xml version="1.0" encoding="utf-8" standalone="no"?><testsuites name="Pester" tests="{0}" errors="0" failures="{1}" disabled="0" time="{2}">{3}</testsuites>' -f $tests, $failures, $RootTime, ($suiteText -join '')
    }
}

Describe 'Get-PoshQCParallelWorkerCount' {
    It 'PM01-WORKER-DEFAULT-HALF-LOGICAL returns the floor of half the logical processors' {
        # Act / Assert
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 12 | Should -Be 6
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 7 | Should -Be 3
    }

    It 'PM02-WORKER-CAP-EIGHT caps the worker count at 8' {
        # Act / Assert
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 64 | Should -Be 8
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 16 | Should -Be 8
    }

    It 'PM03-WORKER-FLOOR-ONE returns at least one worker' {
        # Act / Assert
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 1 | Should -Be 1
        Get-PoshQCParallelWorkerCount -LogicalProcessorCount 0 | Should -Be 1
    }
}

Describe 'Merge-PoshQCJunitReport' {
    It 'PM04-JUNIT-SUMS-AND-RENUMBERS sums the root counts and renumbers testsuite ids from 0' {
        # Arrange
        $first = & $script:NewJunit @(@{ Name = 'C:\r\tests\a.Tests.ps1'; Tests = 3; Failures = 0; Time = '1.5' }, @{ Name = 'C:\r\tests\b.Tests.ps1'; Tests = 2; Failures = 0; Time = '2' }) '3.5'
        $second = & $script:NewJunit @(@{ Name = 'C:\r\tests\c.Tests.ps1'; Tests = 4; Failures = 0; Time = '4' }) '4'

        # Act
        $merged = [xml] (Merge-PoshQCJunitReport -JunitText @($first, $second))

        # Assert
        $merged.testsuites.tests | Should -Be '9'
        $merged.testsuites.failures | Should -Be '0'
        $merged.testsuites.errors | Should -Be '0'
        $merged.testsuites.disabled | Should -Be '0'
        $merged.testsuites.name | Should -Be 'Pester' -Because 'the root keeps the attributes of the first report'
        (@($merged.testsuites.testsuite | ForEach-Object { $_.id }) -join ',') | Should -BeExactly '0,1,2'
        (@($merged.testsuites.testsuite | ForEach-Object { $_.name }) -join ',') | Should -BeExactly 'C:\r\tests\a.Tests.ps1,C:\r\tests\b.Tests.ps1,C:\r\tests\c.Tests.ps1'
    }

    It 'PM05-JUNIT-ROOT-TIME-IS-LONGEST-SHARD sets the root time to the largest shard root time' {
        # Arrange
        $reports = @(
            (& $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 1; Failures = 0; Time = '9' }) '90.25'),
            (& $script:NewJunit @(@{ Name = '/r/tests/b.Tests.ps1'; Tests = 1; Failures = 0; Time = '9' }) '120.5'),
            (& $script:NewJunit @(@{ Name = '/r/tests/c.Tests.ps1'; Tests = 1; Failures = 0; Time = '9' }) '30')
        )

        # Act
        $merged = [xml] (Merge-PoshQCJunitReport -JunitText $reports)

        # Assert
        $merged.testsuites.time | Should -BeExactly '120.5' -Because 'the shards run at the same time, so the longest shard is the wall-clock time'
    }

    It 'PM06-JUNIT-FAILING-SHARD-COUNTS-FAILURES sums the failures of a failing shard' {
        # Arrange
        $passing = & $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 5; Failures = 0; Time = '1' }) '1'
        $failing = & $script:NewJunit @(@{ Name = '/r/tests/b.Tests.ps1'; Tests = 6; Failures = 2; Time = '1' }) '1'

        # Act
        $merged = [xml] (Merge-PoshQCJunitReport -JunitText @($passing, $failing))

        # Assert
        $merged.testsuites.tests | Should -Be '11'
        $merged.testsuites.failures | Should -Be '2'
    }

    It 'PM07-JUNIT-EMPTY-SHARD-CONTRIBUTES-ZERO keeps the totals of the other shards when a shard ran no suite' {
        # Arrange
        $full = & $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 4; Failures = 1; Time = '2' }) '2'
        $empty = & $script:NewJunit @() '0'

        # Act
        $merged = [xml] (Merge-PoshQCJunitReport -JunitText @($empty, $full))

        # Assert
        $merged.testsuites.tests | Should -Be '4'
        $merged.testsuites.failures | Should -Be '1'
        @($merged.testsuites.testsuite).Count | Should -Be 1
        $merged.testsuites.testsuite.id | Should -Be '0'
    }

    It 'PM08-JUNIT-MALFORMED-THROWS rejects malformed XML, a foreign root element, and an empty report list' {
        # Arrange
        $valid = & $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 1; Failures = 0; Time = '1' }) '1'

        # Act / Assert
        { Merge-PoshQCJunitReport -JunitText @($valid, '<testsuites><unclosed>') } | Should -Throw '*JUnit report 2 is not well-formed XML*'
        { Merge-PoshQCJunitReport -JunitText @('<report />') } | Should -Throw "*JUnit report 1 has the root element 'report'*"
        { Merge-PoshQCJunitReport -JunitText @() } | Should -Throw '*requires at least one JUnit report*'
    }
}

Describe 'ConvertTo-PoshQCShardWeight and Export-PoshQCShardWeight' {
    It 'PM09-WEIGHTS-NORMALIZE-ABSOLUTE-PATHS keys files by the repository-relative path from the first tests or scripts segment' {
        # Arrange
        $report = & $script:NewJunit @(
            @{ Name = 'D:\a\drm-copilot\drm-copilot\tests\scripts\x.Tests.ps1'; Tests = 1; Failures = 0; Time = '1' },
            @{ Name = '/home/runner/work/repo/scripts/tools/y.Tests.ps1'; Tests = 1; Failures = 0; Time = '2' },
            @{ Name = 'C:\elsewhere\z.Tests.ps1'; Tests = 1; Failures = 0; Time = '3' }
        ) '6'

        # Act
        $document = ConvertTo-PoshQCShardWeight -JunitText @($report)

        # Assert
        (@($document.files.Keys) -join ',') | Should -BeExactly 'scripts/tools/y.Tests.ps1,tests/scripts/x.Tests.ps1' -Because 'a name with no tests or scripts segment is skipped'
    }

    It 'PM10-WEIGHTS-SORTED-INTEGER-MILLISECONDS returns version 1, unit ms, ordinal keys, and summed integer milliseconds' {
        # Arrange: b appears in two reports and its seconds are summed.
        $first = & $script:NewJunit @(@{ Name = '/r/tests/b.Tests.ps1'; Tests = 1; Failures = 0; Time = '1.2344' }, @{ Name = '/r/tests/a.Tests.ps1'; Tests = 1; Failures = 0; Time = '0.0016' }) '2'
        $second = & $script:NewJunit @(@{ Name = '/r/tests/b.Tests.ps1'; Tests = 1; Failures = 0; Time = '2' }) '2'

        # Act
        $document = ConvertTo-PoshQCShardWeight -JunitText @($first, $second)

        # Assert
        $document.version | Should -Be 1
        $document.unit | Should -BeExactly 'ms'
        (@($document.files.Keys) -join ',') | Should -BeExactly 'tests/a.Tests.ps1,tests/b.Tests.ps1'
        $document.files['tests/a.Tests.ps1'] | Should -Be 2
        $document.files['tests/b.Tests.ps1'] | Should -Be 3234
        $document.files['tests/b.Tests.ps1'] | Should -BeOfType [long]
    }

    It 'PM11-EXPORT-WRITES-THROUGH-SEAM reads each JUnit path and writes the weights JSON through the seams' {
        # Arrange
        $texts = @{
            '/in/shard-1.xml' = (& $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 1; Failures = 0; Time = '1' }) '1')
            '/in/shard-2.xml' = (& $script:NewJunit @(@{ Name = '/r/tests/b.Tests.ps1'; Tests = 1; Failures = 0; Time = '2' }) '2')
        }
        $capture = @{}
        $readText = { param([string] $Path) $texts[$Path] }.GetNewClosure()
        $writeText = { param([string] $Path, [string] $Text) $capture['Path'] = $Path; $capture['Text'] = $Text }.GetNewClosure()

        # Act
        Export-PoshQCShardWeight -JunitPath @('/in/shard-1.xml', '/in/shard-2.xml') -OutputPath '/out/poshqc-shard-weights.json' -ReadText $readText -WriteText $writeText

        # Assert
        $capture['Path'] | Should -BeExactly '/out/poshqc-shard-weights.json'
        $written = $capture['Text'] | ConvertFrom-Json
        $written.version | Should -Be 1
        $written.files.'tests/a.Tests.ps1' | Should -Be 1000
        $written.files.'tests/b.Tests.ps1' | Should -Be 2000
    }

    It 'PM11-EXPORT-WRITES-THROUGH-SEAM default seams read with Get-Content and write with Set-Content' {
        # Arrange: the cmdlets are mocked inside the module scope, so no file is read or written.
        $junit = & $script:NewJunit @(@{ Name = '/r/tests/a.Tests.ps1'; Tests = 1; Failures = 0; Time = '0.25' }) '1'

        InModuleScope PoshQC -Parameters @{ Junit = $junit } {
            param([string] $Junit)
            Mock -CommandName Get-Content -MockWith ([scriptblock]::Create("'" + $Junit.Replace("'", "''") + "'"))
            Mock -CommandName Set-Content -MockWith { }

            # Act
            Export-PoshQCShardWeight -JunitPath @('/in/shard-1.xml') -OutputPath '/out/poshqc-shard-weights.json'

            # Assert
            Should -Invoke -CommandName Get-Content -Times 1 -Exactly -ParameterFilter { $Raw -and $LiteralPath -eq '/in/shard-1.xml' }
            Should -Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq '/out/poshqc-shard-weights.json' -and ([string] $Value -match '"tests/a.Tests.ps1": 250') }
        }
    }
}
