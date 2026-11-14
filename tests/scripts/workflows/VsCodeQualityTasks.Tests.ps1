Set-StrictMode -Version Latest

# Invariants of the quality tasks in .vscode/tasks.json (issue #1096). The file carries full-line //
# comments, which are removed before the JSON is parsed.
Describe '.vscode/tasks.json quality task invariants' {
    BeforeAll {
        $tasksPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../.vscode/tasks.json')).Path
        $jsonLines = @(Get-Content -LiteralPath $tasksPath | Where-Object { $_ -notmatch '^\s*//' })
        $script:Tasks = @((($jsonLines -join "`n") | ConvertFrom-Json).tasks)
        $script:TaskByLabel = @{}
        foreach ($task in $script:Tasks) {
            $script:TaskByLabel[[string] $task.label] = $task
        }
    }

    It 'VT-LEAK-SCAN-TASK defines PoshQC: 2c leak scan, which calls Invoke-PoshQCLeakScan' {
        $script:TaskByLabel.ContainsKey('PoshQC: 2c leak scan') | Should -BeTrue -Because 'the leak scan has a VS Code task'
        $commandText = @($script:TaskByLabel['PoshQC: 2c leak scan'].args) -join ' '
        $commandText | Should -Match 'Invoke-PoshQCLeakScan -Root'
    }

    It 'VT-AGGREGATES-PARALLEL-ONLY makes <Label> depend on the parallel test tasks and on no serial test task' -ForEach @(
        @{ Label = 'QC: Coverage: All Providers' }
        @{ Label = 'QC: 5 Run All Checks' }
    ) {
        $dependsOn = @($script:TaskByLabel[$Label].dependsOn)
        $dependsOn | Should -Contain 'QC: 4 Pytest: run tests with coverage (parallel)'
        $dependsOn | Should -Contain 'PoshQC: 4 test (Pester, parallel)'
        foreach ($serial in @('QC: 4 Pytest: run tests', 'QC: 4 Pytest: run tests with coverage', 'QC: Pytest: run tests with coverage', 'PoshQC: 4 test (Pester)')) {
            $dependsOn | Should -Not -Contain $serial -Because "'$Label' is a gate aggregate and runs no serial test task"
        }
    }

    It 'VT-DEPENDS-ON-RESOLVES resolves every dependsOn name to a task label' {
        $unresolved = foreach ($task in $script:Tasks) {
            $property = $task.PSObject.Properties['dependsOn']
            if ($null -eq $property) { continue }
            foreach ($name in @($property.Value)) {
                if (-not $script:TaskByLabel.ContainsKey([string] $name)) { "$($task.label) -> $name" }
            }
        }
        @($unresolved) | Should -BeNullOrEmpty
    }

    It 'VT-DEFAULT-TEST-TASK makes QC: 4 Pytest: run tests (parallel) the only default of the test group' {
        $defaults = @($script:Tasks | Where-Object {
                $group = $_.PSObject.Properties['group']
                $null -ne $group -and $group.Value -isnot [string] -and $group.Value.kind -eq 'test' -and $group.Value.isDefault -eq $true
            } | ForEach-Object label)
        $defaults | Should -Be @('QC: 4 Pytest: run tests (parallel)')
    }

    It 'VT-SERIAL-TASKS-REMAIN keeps the serial test tasks available for debugging' {
        foreach ($serial in @('QC: 4 Pytest: run tests', 'QC: 4 Pytest: run tests with coverage', 'PoshQC: 4 test (Pester)')) {
            $script:TaskByLabel.ContainsKey($serial) | Should -BeTrue -Because "'$serial' stays for debugging one failure"
        }
    }

    # Issue #1158 (spec D18, D27): the parallel test tasks start the test-execution launcher with the
    # suite name as the first script argument, and every argument survives the shell task's word joining.
    It 'VT-TEST-TASKS-USE-LAUNCHER runs <Label> through Invoke-TestSuite.ps1 with suite <Suite>' -ForEach @(
        @{ Label = 'QC: 4 Pytest: run tests (parallel)'; Suite = 'pytest'; Coverage = $false }
        @{ Label = 'QC: 4 Pytest: run tests with coverage (parallel)'; Suite = 'pytest'; Coverage = $false }
        @{ Label = 'PoshQC: 4 test (Pester, parallel)'; Suite = 'pester'; Coverage = $false }
        @{ Label = 'Shell QC: 4 bats: run tests'; Suite = 'bats'; Coverage = $false }
        @{ Label = 'TS: 4 Jest: unit tests'; Suite = 'jest'; Coverage = $false }
        @{ Label = 'TS: 4 Jest: unit tests with coverage'; Suite = 'jest'; Coverage = $true }
    ) {
        $task = $script:TaskByLabel[$Label]
        $taskArgs = @($task.args | ForEach-Object { [string] $_ })
        $commandText = (@([string] $task.command) + $taskArgs) -join ' '

        $task.command | Should -Be 'pwsh'
        $taskArgs | Should -Contain '-File'
        $commandText | Should -Match ('Invoke-TestSuite\.ps1 ' + [regex]::Escape($Suite) + '(\s|$)')
        $taskArgs | Should -Not -Contain '-Suite'
        ($taskArgs -contains '--coverage') | Should -Be $Coverage -Because 'only the Jest coverage task passes --coverage'
        foreach ($argument in $taskArgs) {
            $argument | Should -Not -Match '[\s"''`;&|$]' -Because "'$argument' must reach pwsh as one word"
        }
    }

    It 'VT-SERIAL-TASKS-DIRECT keeps <Label> off the launcher' -ForEach @(
        @{ Label = 'QC: 4 Pytest: run tests' }
        @{ Label = 'QC: 4 Pytest: run tests with coverage' }
        @{ Label = 'PoshQC: 4 test (Pester)' }
    ) {
        $task = $script:TaskByLabel[$Label]
        $commandText = (@([string] $task.command) + @($task.args | ForEach-Object { [string] $_ })) -join ' '
        $commandText | Should -Not -Match 'Invoke-TestSuite\.ps1' -Because 'the launcher rejects worker reduction (D9)'
    }
}
