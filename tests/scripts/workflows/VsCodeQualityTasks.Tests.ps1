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
}
