Set-StrictMode -Version Latest

# Unit suite for the Python coverage shard helper scripts/ci/Select-PythonTestShard.ps1 (issue #1190).
#
# The helper is dot-sourced, so its dot-source guard skips the entry call and the functions are available to
# the cases. Enumeration, file reads, file writes, and file searches go through test-local fakes passed as
# seams, so the cases read their file text from memory, write nothing, and call no process. The repository
# root is the real checkout root: a fixture of fake test paths under it proves that the PowerShell millisecond
# weights file at config/poshqc-shard-weights.json is not read for Python files.

Describe 'Select-PythonTestShard.ps1' {
    BeforeAll {
        $script:HelperPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Select-PythonTestShard.ps1'
        if (-not (Test-Path -LiteralPath $script:HelperPath)) {
            throw "The helper under test does not exist: $script:HelperPath"
        }
        . $script:HelperPath
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../../..')).Path -replace '\\', '/'

        # Twelve fixture files whose texts differ in size, keyed by full path; the text is served by the read seam.
        $script:FixtureText = [ordered]@{}
        foreach ($number in 1..12) {
            $script:FixtureText["$script:RepoRoot/tests/pkg/test_f$('{0:D2}' -f $number).py"] = ('x' * (10 + (($number * 37) % 90))) + "`n"
        }
        $script:FixtureEnumerate = { [string[]] @($script:FixtureText.Keys) }
        $script:FixtureRead = { param([string] $Path) $script:FixtureText[$Path] }
        $script:NoWrite = { }

        # Selects one shard of the fixture and returns the root-relative paths.
        function Get-TestShard {
            param([int] $Index, [int] $Count, [scriptblock] $Enumerate = $script:FixtureEnumerate, [scriptblock] $Read = $script:FixtureRead, [scriptblock] $Write = $script:NoWrite)
            [string[]] @(Get-PythonTestShardSelection -RootPath $script:RepoRoot -ShardIndex $Index -ShardCount $Count -EnumerateTestFile $Enumerate -ReadTestFileText $Read -WriteFile $Write)
        }
    }

    Context 'selection' {
        It 'SH01-BALANCED-ASSIGNMENT keeps the spread of shard weights within one file and covers each file once' {
            $loads = foreach ($index in 1..3) {
                $files = Get-TestShard -Index $index -Count 3
                ($files | ForEach-Object { $script:FixtureText["$script:RepoRoot/$_"].Length } | Measure-Object -Sum).Sum
            }
            $heaviest = ($script:FixtureText.Values | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

            (($loads | Measure-Object -Maximum).Maximum - ($loads | Measure-Object -Minimum).Minimum) | Should -BeLessOrEqual $heaviest
            $union = foreach ($index in 1..3) { Get-TestShard -Index $index -Count 3 }
            @($union).Count | Should -Be 12
            @($union | Sort-Object -Unique).Count | Should -Be 12
        }

        It 'SH02-DETERMINISTIC-ORDER returns identical selections for repeated calls and for a reversed enumeration' {
            $first = Get-TestShard -Index 2 -Count 3
            $second = Get-TestShard -Index 2 -Count 3
            $reversed = Get-TestShard -Index 2 -Count 3 -Enumerate { [string[]] @($script:FixtureText.Keys)[11..0] }

            ($second -join '|') | Should -BeExactly ($first -join '|')
            ($reversed -join '|') | Should -BeExactly ($first -join '|') -Because 'the assignment depends on the ordinal path order, not the enumeration order'
        }

        It 'SH03-CRLF-EQUALS-LF serves the same text with CRLF and LF and gets one weight per file and one assignment' {
            Mock Select-PoshQCShardTestFile { $script:CapturedItems = @($TestFile); @($TestFile[0].FullName) }
            $crlf = { param([string] $Path) $script:FixtureText[$Path].Replace("`n", "`r`n") }
            Get-TestShard -Index 1 -Count 2 -Read $crlf | Out-Null
            $crlfLengths = @($script:CapturedItems | ForEach-Object { $_.Length })
            Get-TestShard -Index 1 -Count 2 | Out-Null
            $lfLengths = @($script:CapturedItems | ForEach-Object { $_.Length })

            ($crlfLengths -join ',') | Should -BeExactly ($lfLengths -join ',')
            $lfLengths[0] | Should -Be $script:FixtureText[$script:CapturedItems[0].FullName].Length
        }

        It 'SH03-CRLF-EQUALS-LF yields one assignment for both line-ending forms with the real selection' {
            $crlf = { param([string] $Path) $script:FixtureText[$Path].Replace("`n", "`r`n") }

            (Get-TestShard -Index 2 -Count 3 -Read $crlf) -join '|' | Should -BeExactly ((Get-TestShard -Index 2 -Count 3) -join '|')
        }

        It 'SH04-SIZE-WEIGHTING places one large file alone, which neither the all-one nor the median weighting does' {
            $texts = @{}
            $paths = foreach ($name in 'big', 'a', 'b', 'c', 'd') { "$script:RepoRoot/tests/z/test_$name.py" }
            foreach ($path in $paths) { $texts[$path] = 'y' * 5 }
            $texts["$script:RepoRoot/tests/z/test_big.py"] = 'y' * 5000
            $enumerate = { [string[]] $paths }.GetNewClosure()
            $read = { param([string] $Path) $texts[$Path] }.GetNewClosure()

            $first = Get-TestShard -Index 1 -Count 2 -Enumerate $enumerate -Read $read
            $second = Get-TestShard -Index 2 -Count 2 -Enumerate $enumerate -Read $read

            ($first -join '|') | Should -BeExactly 'tests/z/test_big.py'
            @($second).Count | Should -Be 4 -Because 'size weighting puts the four small files together; all-one weighting would split five files 3 and 2'
        }

        It 'SH05-EMPTY-SHARD-THROWS throws when the shard selects no file' {
            { Get-TestShard -Index 13 -Count 13 } | Should -Throw '*selects no test file*'
        }

        It 'SH05-EMPTY-SHARD-THROWS throws when no test file is enumerated' {
            { Get-TestShard -Index 1 -Count 2 -Enumerate { [string[]] @() } } | Should -Throw '*selects no test file*'
        }

        It 'SH06-WRITES-MANIFEST-AND-LIST writes shard-files.json and shard-files.txt through the write seam' {
            $writes = [ordered]@{}
            $write = { param([string] $Path, [string] $Text) $writes[$Path] = $Text }.GetNewClosure()

            $selected = Get-TestShard -Index 2 -Count 3 -Write $write

            ($writes.Keys -join ',') | Should -BeExactly 'artifacts/python/shard-files.json,artifacts/python/shard-files.txt'
            $manifest = $writes['artifacts/python/shard-files.json'] | ConvertFrom-Json
            $manifest.shardIndex | Should -Be 2
            $manifest.shardCount | Should -Be 3
            @($manifest.all).Count | Should -Be 12
            ($manifest.selected -join '|') | Should -BeExactly ($selected -join '|')
            $writes['artifacts/python/shard-files.txt'] | Should -BeExactly (($selected -join "`n") + "`n")
        }

        It 'SH07-NO-WEIGHTS-FILE ignores config/poshqc-shard-weights.json for Python files' {
            Test-Path -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'config/poshqc-shard-weights.json') | Should -BeTrue -Because 'the fixture proves the weights file exists and is skipped'
            $first = Get-TestShard -Index 1 -Count 2

            @($first).Count | Should -BeGreaterThan 0
            $loadOne = ($first | ForEach-Object { $script:FixtureText["$script:RepoRoot/$_"].Length } | Measure-Object -Sum).Sum
            $loadTwo = (Get-TestShard -Index 2 -Count 2 | ForEach-Object { $script:FixtureText["$script:RepoRoot/$_"].Length } | Measure-Object -Sum).Sum
            [math]::Abs($loadOne - $loadTwo) | Should -BeLessOrEqual 100 -Because 'a median-millisecond weighting would ignore the byte sizes'
        }
    }

    Context 'collected count and verification' {
        It 'SH08-COLLECT-COUNT-PARSE parses <Text> as <Expected>' -ForEach @(
            @{ Text = '619 tests collected in 5.20s'; Expected = 619 }
            @{ Text = "tests/a.py::test_one`ntests/a.py::test_two`n`n2 tests collected in 0.10s"; Expected = 2 }
            @{ Text = '1 test collected in 0.01s'; Expected = 1 }
        ) {
            Get-PythonCollectedTestCount -CollectCountText $Text | Should -Be $Expected
        }

        It 'SH08-COLLECT-COUNT-PARSE throws when no summary line is present' {
            { Get-PythonCollectedTestCount -CollectCountText 'no tests ran' } | Should -Throw '*tests collected*'
        }

        It 'SH09-VERIFY-PASSES returns true for complete shards whose JUnit sum equals the collected count' {
            $manifests = @(
                '{"shardIndex":1,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/a.py"]}',
                '{"shardIndex":2,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/b.py"]}'
            )
            $junit = @('<testsuites><testsuite name="pytest" tests="3"></testsuite></testsuites>', '<testsuites><testsuite name="pytest" tests="4"></testsuite></testsuites>')

            Test-PythonTestShardResult -ManifestJson $manifests -JUnitXml $junit -CollectCountText '7 tests collected in 1s' | Should -BeTrue
        }

        It 'SH09-VERIFY-MISSING-FILE throws when a test file is selected by no shard' {
            $manifests = @(
                '{"shardIndex":1,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/a.py"]}',
                '{"shardIndex":2,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":[]}'
            )
            $junit = @('<testsuites><testsuite tests="1"></testsuite></testsuites>')

            { Test-PythonTestShardResult -ManifestJson $manifests -JUnitXml $junit -CollectCountText '1 tests collected' } | Should -Throw '*do not cover every test file*'
        }

        It 'SH09-VERIFY-DUPLICATE-FILE throws when a test file is selected by two shards' {
            $manifests = @(
                '{"shardIndex":1,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/a.py","tests/b.py"]}',
                '{"shardIndex":2,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/b.py"]}'
            )
            $junit = @('<testsuites><testsuite tests="1"></testsuite></testsuites>')

            { Test-PythonTestShardResult -ManifestJson $manifests -JUnitXml $junit -CollectCountText '1 tests collected' } | Should -Throw '*more than one shard*'
        }

        It 'SH09-VERIFY-JUNIT-SUM-MISMATCH throws when the JUnit sum differs from the collected count' {
            $manifests = @(
                '{"shardIndex":1,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/a.py"]}',
                '{"shardIndex":2,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/b.py"]}'
            )
            $junit = @('<testsuites><testsuite tests="3"></testsuite></testsuites>', '<testsuites><testsuite tests="3"></testsuite></testsuites>')

            { Test-PythonTestShardResult -ManifestJson $manifests -JUnitXml $junit -CollectCountText '7 tests collected in 1s' } | Should -Throw '*sum to 6*found 7*'
        }
    }

    Context 'entry function and default boundaries' {
        It 'SH10-ENTRY-SELECT-EXIT-ZERO returns 0 and reports the selected count in Select mode' {
            Mock Get-PythonTestShardSelection { [string[]] @('tests/a.py', 'tests/b.py') }
            $messages = [System.Collections.Generic.List[string]]::new()
            $writer = { param([string] $Text) $messages.Add($Text) }.GetNewClosure()

            Invoke-PythonTestShardEntry -Mode Select -RootPath $script:RepoRoot -ShardIndex 1 -ShardCount 2 -OutputWriter $writer | Should -Be 0
            $messages[0] | Should -BeExactly 'Shard 1 of 2 selected 2 test files.'
        }

        It 'SH10-ENTRY-SELECT-EXIT-ONE returns 1 when the selection throws' {
            Mock Get-PythonTestShardSelection { throw 'Shard 3 of 3 selects no test file.' }

            Invoke-PythonTestShardEntry -Mode Select -RootPath $script:RepoRoot -ShardIndex 3 -ShardCount 3 -ErrorAction SilentlyContinue | Should -Be 1
        }

        It 'SH10-ENTRY-VERIFY-EXIT-ZERO returns 0 in Verify mode for complete shards' {
            $files = @{
                'm1' = '{"shardIndex":1,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/a.py"]}'
                'm2' = '{"shardIndex":2,"shardCount":2,"all":["tests/a.py","tests/b.py"],"selected":["tests/b.py"]}'
                'j1' = '<testsuites><testsuite tests="2"></testsuite></testsuites>'
                'j2' = '<testsuites><testsuite tests="1"></testsuite></testsuites>'
            }
            $find = { if ($args[1] -ceq 'shard-files.json') { 'm1', 'm2' } else { 'j1', 'j2' } }
            $read = { param([string] $Path) $files[$Path] }.GetNewClosure()
            $messages = [System.Collections.Generic.List[string]]::new()
            $writer = { param([string] $Text) $messages.Add($Text) }.GetNewClosure()

            Invoke-PythonTestShardEntry -Mode Verify -RootPath $script:RepoRoot -CollectCountText '3 tests collected in 1s' -FindFile $find -ReadText $read -OutputWriter $writer | Should -Be 0
            $messages[0] | Should -BeExactly 'Python shard completeness verified for 2 shards.'
        }

        It 'SH10-ENTRY-VERIFY-EXIT-ONE returns 1 in Verify mode when the JUnit sum mismatches' {
            $files = @{
                'm1' = '{"shardIndex":1,"shardCount":1,"all":["tests/a.py"],"selected":["tests/a.py"]}'
                'j1' = '<testsuites><testsuite tests="2"></testsuite></testsuites>'
            }
            $find = { if ($args[1] -ceq 'shard-files.json') { 'm1' } else { 'j1' } }
            $read = { param([string] $Path) $files[$Path] }.GetNewClosure()

            Invoke-PythonTestShardEntry -Mode Verify -RootPath $script:RepoRoot -CollectCountText '5 tests collected in 1s' -FindFile $find -ReadText $read -ErrorAction SilentlyContinue | Should -Be 1
        }

        It 'SH11-DOT-SOURCE-GUARD defines the entry function without running it' {
            Get-Command -Name Invoke-PythonTestShardEntry -CommandType Function | Should -Not -BeNullOrEmpty
        }

        It 'SH12-DEFAULT-READ-BOUNDARY reads a committed file by path' {
            Read-PythonShardFileText -Path $script:HelperPath | Should -BeLike '*Select-PoshQCShardTestFile*'
        }

        It 'SH12-DEFAULT-ENUMERATE-BOUNDARY lists committed Python test files under tests' {
            $paths = @(Get-PythonTestFilePath -RootPath $script:RepoRoot)

            $paths.Count | Should -BeGreaterThan 100
            @($paths | Where-Object { (Split-Path -Leaf $_) -notlike 'test_*.py' }).Count | Should -Be 0
        }

        It 'SH12-DEFAULT-FIND-BOUNDARY finds this suite by name filter' {
            $paths = @(Find-PythonShardFile -Folder (Join-Path -Path $script:RepoRoot -ChildPath 'tests/scripts/ci') -Filter 'Select-PythonTestShard.Tests.ps1')

            $paths.Count | Should -Be 1
        }

        It 'SH12-DEFAULT-SELECT-SEAMS enumerates and reads the committed tests by default and writes through the injected writer' {
            $writes = [System.Collections.Generic.List[string]]::new()
            $write = { param([string] $Path, [string] $Text) $writes.Add($Path + '=' + $Text.Length) }.GetNewClosure()

            $selected = @(Get-PythonTestShardSelection -RootPath $script:RepoRoot -ShardIndex 1 -ShardCount 8 -WriteFile $write)

            $selected.Count | Should -BeGreaterThan 10
            @($selected | Where-Object { $_ -notlike 'tests/*test_*.py' }).Count | Should -Be 0
            $writes.Count | Should -Be 2
        }

        It 'SH12-DEFAULT-ENTRY-SEAMS reports a verify failure through the default search seam when no manifest exists' {
            Invoke-PythonTestShardEntry -Mode Verify -RootPath $script:RepoRoot -ShardRoot (Join-Path -Path $script:RepoRoot -ChildPath 'tests/scripts/ci') -CollectCountText '1 test collected' -ErrorAction SilentlyContinue | Should -Be 1
        }

        It 'SH12-DEFAULT-OUTPUT-WRITER sends the Select report to the information stream' {
            Mock Get-PythonTestShardSelection { [string[]] @('tests/a.py') }

            $stream = Invoke-PythonTestShardEntry -Mode Select -RootPath $script:RepoRoot -ShardIndex 1 -ShardCount 1 6>&1

            @($stream | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }).Count | Should -Be 1
        }

        It 'SH12-DEFAULT-WRITE-BOUNDARY creates the folder and writes the text without a trailing newline' {
            Mock New-Item { }
            Mock Set-Content { }

            Write-PythonShardFileText -Path 'artifacts/python/shard-files.txt' -Text 'a'

            Should -Invoke New-Item -Times 1 -Exactly -ParameterFilter { (@($Path)[0] -replace '\\', '/') -ceq 'artifacts/python' }
            Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -ceq 'artifacts/python/shard-files.txt' -and $Value -ceq 'a' -and $NoNewline }
        }

        It 'SH12-DEFAULT-WRITE-BOUNDARY writes nothing under -WhatIf' {
            $target = Join-Path -Path $script:RepoRoot -ChildPath 'artifacts/python-unwritten-whatif-probe/probe.txt'

            Write-PythonShardFileText -Path $target -Text 'x' -WhatIf

            Test-Path -LiteralPath $target | Should -BeFalse
        }
    }
}
