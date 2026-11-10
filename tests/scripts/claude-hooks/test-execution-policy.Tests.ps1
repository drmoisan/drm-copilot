#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the pure test-execution policy helper (issue #1158).

.DESCRIPTION
    Every case runs against both byte-identical copies, .claude/hooks/test-execution-policy.ps1
    and .codex/hooks/test-execution-policy.ps1. Configuration text is supplied in memory
    through the ReadText seam of Get-TestExecutionPolicy; no test reads or writes a file,
    sets an environment variable, or waits.
#>

BeforeDiscovery {
    $script:PolicyCopies = @(
        @{ Copy = '.claude/hooks/test-execution-policy.ps1' }
        @{ Copy = '.codex/hooks/test-execution-policy.ps1' }
    )
}

Describe 'test-execution-policy helper <Copy> (issue #1158)' -ForEach $script:PolicyCopies {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot $Copy)
        $script:DefaultSuffixes = @('.integration.test.ts', '.integration.test.js', '_integration.py', '.integration.tests.ps1', '.golden.test.ts', '.golden.test.js', '_golden.py', '.golden.tests.ps1')

        function Get-TestPolicy {
            param([AllowNull()] $Text)
            $captured = $Text
            return (Get-TestExecutionPolicy -ReadText { $captured }.GetNewClosure())
        }

        function Get-TestPolicyError {
            param([string] $Text)
            try { $null = Get-TestPolicy -Text $Text; return '' } catch { return $_.Exception.Message }
        }
    }

    Context 'defaults' {
        It 'returns every default when no configuration text exists' {
            # Arrange / Act
            $policy = Get-TestPolicy -Text $null

            # Assert
            $policy['version'] | Should -Be 1
            ($policy['localLanes']['exclude'] -join ',') | Should -Be 'integration,golden'
            $policy['machineLock']['enabled'] | Should -BeTrue
            $policy['machineLock']['waitMilliseconds'] | Should -Be 90000
            $policy['machineLock']['pollMilliseconds'] | Should -Be 2000
            $policy['requireLauncher'] | Should -BeTrue
            (@($policy['suites'].Keys) -join ',') | Should -Be 'pytest,pester,jest,dotnet-test'
            (@($policy['suites'].Values | ForEach-Object { $_['runner'] }) -join ',') | Should -Be 'pytest,pester,jest,mstest'
            ($policy['lanes']['integration']['pytestMarkers'] -join ',') | Should -Be 'integration'
            ($policy['lanes']['golden']['pesterTags'] -join ',') | Should -Be 'Golden'
            ($policy['lanes']['integration']['mstestCategories'] -join ',') | Should -Be 'Integration'
            (@($policy['lanes']['integration']['fileNameSuffixes']) + @($policy['lanes']['golden']['fileNameSuffixes'])) -join ',' | Should -Be ($script:DefaultSuffixes -join ',')
        }

        It 'gives <Name> the exact command words <Expected>' -ForEach @(
            @{ Name = 'pytest'; Expected = 'poetry run pytest -n auto' }
            @{ Name = 'pester'; Expected = 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1' }
            @{ Name = 'jest'; Expected = 'node run-jest.cjs' }
            @{ Name = 'dotnet-test'; Expected = 'dotnet test' }
        ) {
            # Arrange
            $policy = Get-TestPolicy -Text $null
            $words = @($policy['suites'][$Name]['command'])

            # Act
            $token = Get-TestExecutionWorkerReductionToken -Runner $policy['suites'][$Name]['runner'] -ArgumentList $words

            # Assert
            ($words -join ' ') | Should -BeExactly $Expected
            $token | Should -BeNullOrEmpty
        }

        It 'starts the pester suite through -File and never through a command payload flag' {
            # Arrange / Act
            $words = @((Get-TestPolicy -Text $null)['suites']['pester']['command'])

            # Assert
            $words | Should -Contain '-File'
            @($words | Where-Object { @('-Command', '-c', '-EncodedCommand') -contains $_ }).Count | Should -Be 0
        }

        It 'uses the supplied PesterSuiteScript as the last pester word' {
            # Arrange
            $path = '.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'

            # Act
            $policy = Get-TestExecutionPolicy -ReadText { $null } -PesterSuiteScript $path

            # Assert
            @($policy['suites']['pester']['command'])[-1] | Should -BeExactly $path
        }
    }

    Context 'validation' {
        It 'rejects <Text> naming <Field>' -ForEach @(
            @{ Text = '{'; Field = "'(document)'" }
            @{ Text = '[]'; Field = "'(document)'" }
            @{ Text = '{"extra":1}'; Field = "'extra' is not a known top-level key" }
            @{ Text = '{"version":2}'; Field = "'version'" }
            @{ Text = '{"version":"1"}'; Field = "'version'" }
            @{ Text = '{"localLanes":[]}'; Field = "'localLanes'" }
            @{ Text = '{"lanes":[]}'; Field = "'lanes'" }
            @{ Text = '{"machineLock":true}'; Field = "'machineLock'" }
            @{ Text = '{"suites":[]}'; Field = "'suites'" }
            @{ Text = '{"localLanes":{"exclude":"integration"}}'; Field = "'localLanes.exclude'" }
            @{ Text = '{"localLanes":{"exclude":[""]}}'; Field = "'localLanes.exclude'" }
            @{ Text = '{"localLanes":{"exclude":["slow"]}}'; Field = "'localLanes.exclude' names the lane 'slow'" }
            @{ Text = '{"lanes":{"integration":{"pytestMarkers":[" "]}}}'; Field = "'lanes.integration.pytestMarkers'" }
            @{ Text = '{"lanes":{"integration":{"pesterTags":"Integration"}}}'; Field = "'lanes.integration.pesterTags'" }
            @{ Text = '{"lanes":{"golden":{"mstestCategories":[1]}}}'; Field = "'lanes.golden.mstestCategories'" }
            @{ Text = '{"lanes":{"golden":{"fileNameSuffixes":[""]}}}'; Field = "'lanes.golden.fileNameSuffixes'" }
            @{ Text = '{"lanes":{"slow":3}}'; Field = "'lanes.slow'" }
            @{ Text = '{"machineLock":{"enabled":"yes"}}'; Field = "'machineLock.enabled'" }
            @{ Text = '{"machineLock":{"waitMilliseconds":-1}}'; Field = "'machineLock.waitMilliseconds'" }
            @{ Text = '{"machineLock":{"waitMilliseconds":540001}}'; Field = "'machineLock.waitMilliseconds'" }
            @{ Text = '{"machineLock":{"waitMilliseconds":1.5}}'; Field = "'machineLock.waitMilliseconds'" }
            @{ Text = '{"machineLock":{"pollMilliseconds":99}}'; Field = "'machineLock.pollMilliseconds'" }
            @{ Text = '{"machineLock":{"pollMilliseconds":10001}}'; Field = "'machineLock.pollMilliseconds'" }
            @{ Text = '{"requireLauncher":1}'; Field = "'requireLauncher'" }
            @{ Text = '{"suites":{"x":3}}'; Field = "'suites.x'" }
            @{ Text = '{"suites":{"x":{"command":["a"],"runner":"nose"}}}'; Field = "'suites.x.runner'" }
            @{ Text = '{"suites":{"x":{"command":[],"runner":"bats"}}}'; Field = "'suites.x.command'" }
            @{ Text = '{"suites":{"x":{"command":["pytest","-n","4"],"runner":"pytest"}}}'; Field = "'suites.x.command' carries the worker-reduction token '-n 4'" }
            @{ Text = '{"suites":{"x":{"command":["a"],"runner":"bats","workingDirectory":"/abs"}}}'; Field = "'suites.x.workingDirectory'" }
            @{ Text = '{"suites":{"x":{"command":["a"],"runner":"bats","workingDirectory":"C:/abs"}}}'; Field = "'suites.x.workingDirectory'" }
            @{ Text = '{"suites":{"x":{"command":["a"],"runner":"bats","workingDirectory":"a/../b"}}}'; Field = "'suites.x.workingDirectory'" }
        ) {
            # Act
            $message = Get-TestPolicyError -Text $Text

            # Assert
            $message | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*'
            $message | Should -BeLike '*config/test-execution-policy.json*'
            $message | Should -BeLike '*test-execution policy*'
            $message.Contains("field $Field") | Should -BeTrue -Because $message
        }

        It 'accepts the range endpoint <Text>' -ForEach @(
            @{ Text = '{"machineLock":{"waitMilliseconds":0}}' }
            @{ Text = '{"machineLock":{"waitMilliseconds":540000}}' }
            @{ Text = '{"machineLock":{"pollMilliseconds":100}}' }
            @{ Text = '{"machineLock":{"pollMilliseconds":10000}}' }
            @{ Text = '{"version":1,"localLanes":{"exclude":[]},"suites":{"x":{"command":["a"],"runner":"bats","workingDirectory":"a/b"}}}' }
        ) {
            # Act / Assert
            Get-TestPolicyError -Text $Text | Should -BeNullOrEmpty
        }

        It 'returns an error list from Test-TestExecutionPolicyDocument for a valid and an invalid document' {
            # Act
            $valid = @(Test-TestExecutionPolicyDocument -Document ([ordered]@{ version = 1 }))
            $invalid = @(Test-TestExecutionPolicyDocument -Document ([ordered]@{ version = 1; extra = 1; requireLauncher = 'x' }))

            # Assert
            $valid.Count | Should -Be 0
            $invalid.Count | Should -Be 1
            $invalid[0] | Should -BeLike "*'extra'*"
        }
    }

    Context 'merge semantics' {
        It 'merges objects by key and replaces arrays' {
            # Act
            $policy = Get-TestPolicy -Text '{"machineLock":{"waitMilliseconds":4000},"lanes":{"integration":{"pytestMarkers":["slow"]}},"suites":{"bats":{"command":["bash","x.sh"],"runner":"bats"}}}'

            # Assert
            $policy['machineLock']['waitMilliseconds'] | Should -Be 4000
            $policy['machineLock']['pollMilliseconds'] | Should -Be 2000
            $policy['machineLock']['enabled'] | Should -BeTrue
            ($policy['lanes']['integration']['pytestMarkers'] -join ',') | Should -Be 'slow'
            ($policy['lanes']['integration']['pesterTags'] -join ',') | Should -Be 'Integration'
            (@($policy['suites'].Keys) -join ',') | Should -Be 'pytest,pester,jest,dotnet-test,bats'
        }

        It 'keeps a one-element array as an array after the merge' {
            # Act
            $policy = Get-TestPolicy -Text '{"localLanes":{"exclude":["golden"]}}'

            # Assert
            , $policy['localLanes']['exclude'] | Should -BeOfType [System.Collections.IList]
            @($policy['localLanes']['exclude']).Count | Should -Be 1
        }
    }

    Context 'lane selection' {
        It 'selects the <Expected> lane for the default suffix in mixed case <Path>' -ForEach @(
            @{ Path = 'test/a.INTEGRATION.Test.ts'; Expected = 'integration' }
            @{ Path = 'test/a.Integration.TEST.js'; Expected = 'integration' }
            @{ Path = 'tests/a_INTEGRATION.py::test_one'; Expected = 'integration' }
            @{ Path = 'tests\a.Integration.Tests.PS1'; Expected = 'integration' }
            @{ Path = 'test/a.GOLDEN.test.TS'; Expected = 'golden' }
            @{ Path = 'test/a.Golden.Test.Js'; Expected = 'golden' }
            @{ Path = 'tests/a_Golden.PY'; Expected = 'golden' }
            @{ Path = 'tests/a.GOLDEN.tests.ps1'; Expected = 'golden' }
        ) {
            # Act
            $lane = Get-TestExecutionLaneSelection -Policy (Get-TestPolicy -Text $null) -Runner 'pytest' -ArgumentList @($Path)

            # Assert
            $lane | Should -Be $Expected
        }

        It 'returns <Expected> for runner <Runner> and arguments <Arguments>' -ForEach @(
            @{ Runner = 'pytest'; Arguments = @('-m', 'integration'); Expected = 'integration' }
            @{ Runner = 'pytest'; Arguments = @('-m', 'smoke or golden'); Expected = 'golden' }
            @{ Runner = 'pytest'; Arguments = @('-m', 'not integration'); Expected = $null }
            @{ Runner = 'pytest'; Arguments = @('-mintegration'); Expected = 'integration' }
            @{ Runner = 'pytest'; Arguments = @('-k', 'integration'); Expected = $null }
            @{ Runner = 'pester'; Arguments = @('-Tag', 'Integration'); Expected = 'integration' }
            @{ Runner = 'pester'; Arguments = @('-Tag', 'Unit,Golden'); Expected = 'golden' }
            @{ Runner = 'pester'; Arguments = @('-Tag', 'Unit'); Expected = $null }
            @{ Runner = 'mstest'; Arguments = @('--filter', 'TestCategory=Golden'); Expected = 'golden' }
            @{ Runner = 'mstest'; Arguments = @('--filter=Category=Integration'); Expected = 'integration' }
            @{ Runner = 'mstest'; Arguments = @('--filter', 'TestCategory!=Golden'); Expected = $null }
            @{ Runner = 'jest'; Arguments = @('tests/unit/a.test.ts'); Expected = $null }
        ) {
            # Act
            $lane = Get-TestExecutionLaneSelection -Policy (Get-TestPolicy -Text $null) -Runner $Runner -ArgumentList $Arguments

            # Assert
            $lane | Should -Be $Expected
        }

        It 'selects nothing when localLanes.exclude is empty' {
            # Act
            $lane = Get-TestExecutionLaneSelection -Policy (Get-TestPolicy -Text '{"localLanes":{"exclude":[]}}') -Runner 'pytest' -ArgumentList @('a_integration.py', '-m', 'golden')

            # Assert
            $lane | Should -BeNullOrEmpty
        }
    }

    Context 'worker-reduction tokens' {
        It 'reports <Arguments> for <Runner> as <Expected>' -ForEach @(
            @{ Runner = 'pytest'; Arguments = @('-n', '4'); Expected = '-n 4' }
            @{ Runner = 'pytest'; Arguments = @('-n=4'); Expected = '-n=4' }
            @{ Runner = 'pytest'; Arguments = @('--numprocesses', '2'); Expected = '--numprocesses 2' }
            @{ Runner = 'pytest'; Arguments = @('--numprocesses=2'); Expected = '--numprocesses=2' }
            @{ Runner = 'pytest'; Arguments = @('-p', 'no:xdist'); Expected = '-p no:xdist' }
            @{ Runner = 'pytest'; Arguments = @('-pno:xdist'); Expected = '-pno:xdist' }
            @{ Runner = 'pytest'; Arguments = @('-n', 'auto'); Expected = $null }
            @{ Runner = 'pytest'; Arguments = @('-i'); Expected = $null }
            @{ Runner = 'jest'; Arguments = @('--maxWorkers=2'); Expected = '--maxWorkers=2' }
            @{ Runner = 'jest'; Arguments = @('-w', '2'); Expected = '-w' }
            @{ Runner = 'jest'; Arguments = @('--runInBand'); Expected = '--runInBand' }
            @{ Runner = 'jest'; Arguments = @('-i'); Expected = '-i' }
            @{ Runner = 'pester'; Arguments = @('-WorkerCount', '2'); Expected = '-WorkerCount' }
            @{ Runner = 'pester'; Arguments = @('-workercount:2'); Expected = '-workercount:2' }
            @{ Runner = 'mstest'; Arguments = @('-i', '-n', '4'); Expected = $null }
            @{ Runner = 'bats'; Arguments = @('-j', '1'); Expected = $null }
        ) {
            # Act / Assert
            Get-TestExecutionWorkerReductionToken -Runner $Runner -ArgumentList $Arguments | Should -Be $Expected
        }
    }

    Context 'suite command builder' {
        It 'builds the pytest suite with one -m word and one --ignore-glob word per suffix' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'pytest')

            # Assert
            $expected = @('poetry', 'run', 'pytest', '-n', 'auto', '-m', 'not integration and not golden') + @($script:DefaultSuffixes | ForEach-Object { "--ignore-glob=*$_" })
            ($words -join "`n") | Should -BeExactly ($expected -join "`n")
        }

        It 'builds the pester suite with -ExcludeTag and -ExcludeTestFileSuffix values' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'pester')

            # Assert
            $expected = @('pwsh', '-NoProfile', '-NonInteractive', '-File', '.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1', '-ExcludeTag', 'Integration', 'Golden', '-ExcludeTestFileSuffix') + $script:DefaultSuffixes
            ($words -join "`n") | Should -BeExactly ($expected -join "`n")
        }

        It 'builds the jest suite with one --testPathIgnorePatterns word per pattern and keeps a positional extra' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'jest' -ExtraArgument @('tests/unit/a.test.ts'))

            # Assert
            $words[0..3] -join ' ' | Should -BeExactly 'node run-jest.cjs --testPathIgnorePatterns=/node_modules/ --testPathIgnorePatterns=/out/'
            $words | Should -Contain '--testPathIgnorePatterns=\.integration\.test\.ts$'
            @($words | Where-Object { $_ -like '--testPathIgnorePatterns=*' }).Count | Should -Be 10
            $words[-1] | Should -BeExactly 'tests/unit/a.test.ts'
            $words.Count | Should -Be 13
        }

        It 'builds the dotnet-test suite with one --filter word negating each category' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'dotnet-test')

            # Assert
            ($words -join ' ') | Should -BeExactly 'dotnet test --filter=TestCategory!=Integration&TestCategory!=Golden'
        }

        It 'adds no exclusion for a bats suite' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text '{"suites":{"bats":{"command":["bash","scripts/bash/shell-qc.sh","test"],"runner":"bats"}}}') -SuiteName 'bats' -ExtraArgument @('--coverage'))

            # Assert
            ($words -join ' ') | Should -BeExactly 'bash scripts/bash/shell-qc.sh test --coverage'
        }

        It 'emits no exclusion for <Suite> when localLanes.exclude is empty' -ForEach @(
            @{ Suite = 'pytest'; Expected = 'poetry run pytest -n auto' }
            @{ Suite = 'pester'; Expected = 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1' }
            @{ Suite = 'jest'; Expected = 'node run-jest.cjs' }
            @{ Suite = 'dotnet-test'; Expected = 'dotnet test' }
        ) {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text '{"localLanes":{"exclude":[]}}') -SuiteName $Suite)

            # Assert
            ($words -join ' ') | Should -BeExactly $Expected
        }

        It 'carries non-default lane fields to <Suite>' -ForEach @(
            @{ Suite = 'pytest'; Expected = 'poetry run pytest -n auto -m not slow --ignore-glob=*_slow.py' }
            @{ Suite = 'pester'; Expected = 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1 -ExcludeTag Slow -ExcludeTestFileSuffix _slow.py' }
            @{ Suite = 'dotnet-test'; Expected = 'dotnet test --filter=TestCategory!=Slow' }
        ) {
            # Arrange
            $text = '{"localLanes":{"exclude":["integration"]},"lanes":{"integration":{"pytestMarkers":["slow"],"pesterTags":["Slow"],"mstestCategories":["Slow"],"fileNameSuffixes":["_slow.py"]}}}'

            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $text) -SuiteName $Suite)

            # Assert
            ($words -join ' ') | Should -BeExactly $Expected
        }

        It 'emits only the integration exclusions when localLanes.exclude names integration alone' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text '{"localLanes":{"exclude":["integration"]}}') -SuiteName 'pester')

            # Assert
            ($words[5..($words.Count - 1)] -join ' ') | Should -BeExactly '-ExcludeTag Integration -ExcludeTestFileSuffix .integration.test.ts .integration.test.js _integration.py .integration.tests.ps1'
        }

        It 'orders suite words, exclusions, then extras' {
            # Act
            $words = @(New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'pytest' -ExtraArgument @('-v', '-k', 'smoke'))

            # Assert
            ($words[-3..-1] -join ' ') | Should -BeExactly '-v -k smoke'
            $words[5] | Should -BeExactly '-m'
            ($words[0..4] -join ' ') | Should -BeExactly 'poetry run pytest -n auto'
        }

        It 'throws for an unknown suite' {
            # Act / Assert
            { New-TestExecutionSuiteCommand -Policy (Get-TestPolicy -Text $null) -SuiteName 'nope' } | Should -Throw '*nope*'
        }
    }
}
