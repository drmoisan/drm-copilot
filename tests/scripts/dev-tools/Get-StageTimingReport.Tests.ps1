# Pester tests for the scripts/dev-tools/Get-StageTimingReport.ps1 entry (issue #1097, stage B).
# The entry runs in process against the committed fixtures under tests/fixtures/dev-tools/stage-timing
# (issues 9001 and 9002) and against an existing fixture folder that holds no stage-timing file.
# No test writes a file.

BeforeAll {
    $script:entryPath = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/Get-StageTimingReport.ps1')).ProviderPath
    $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../fixtures/dev-tools/stage-timing'
    $script:emptyRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../fixtures/orchestrator_state_blocked_reason_backcompat'
    $script:wallClockLabel = 'Figures are wall-clock time and include queueing; they are not agent time.'
    $script:mergeLabel = 'The merge stage is not captured.'
}

AfterAll {
    Remove-Module -Name StageTiming -Force -ErrorAction SilentlyContinue
}

Describe 'Get-StageTimingReport.ps1 entry' {
    It 'STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS' {
        # Issues 9001 and 9002: S4 totals 600 and 1000 seconds (median 0:13:20); S5 totals 1500 and 900
        # seconds (median 0:20:00). A run without a parameter also prints the labels from the default root.
        $lines = @(& $script:entryPath -EvidenceRoot $script:fixtureRoot)
        $defaultLines = @(& $script:entryPath)

        $lines | Should -Contain $script:wallClockLabel
        $lines | Should -Contain $script:mergeLabel
        $lines | Should -Contain '  S4_atomic_planning: 2 issue(s), median 0:13:20'
        $lines | Should -Contain '  S5_atomic_execution: 2 issue(s), median 0:20:00'
        $lines | Should -Contain '  Issue 9001, S5_atomic_execution: 2 attempt(s), 0 open, total 0:25:00'
        $defaultLines | Should -Contain $script:wallClockLabel
        $defaultLines | Should -Contain $script:mergeLabel
    }

    It 'STR-ENTRY-PRINTS-LABELS-FOR-EMPTY-ROOT' {
        # The folder exists and holds JSON files, none named stage-timing.*.json.
        $lines = @(& $script:entryPath -EvidenceRoot $script:emptyRoot)

        $lines | Should -Contain $script:wallClockLabel
        $lines | Should -Contain $script:mergeLabel
        $lines | Should -Contain 'No stage timing evidence was found.'
    }

    It 'STR-ENTRY-THROWS-ON-MISSING-ROOT' {
        $missing = Join-Path -Path $script:fixtureRoot -ChildPath 'no-such-folder'

        { & $script:entryPath -EvidenceRoot $missing } | Should -Throw '*not found*'
    }

    It 'STR-ENTRY-HAS-NO-PARAMETER-OTHER-THAN-ROOT-AND-NO-FUNCTIONS' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:entryPath, [ref] $tokens, [ref] $parseErrors)

        $parameterNames = @($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
        $functions = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true))

        $parseErrors.Count | Should -Be 0
        $parameterNames | Should -Be @('EvidenceRoot')
        $functions.Count | Should -Be 0
    }
}
