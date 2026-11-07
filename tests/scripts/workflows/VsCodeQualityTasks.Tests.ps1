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
}
