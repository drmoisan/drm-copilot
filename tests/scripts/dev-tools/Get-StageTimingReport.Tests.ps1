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
    # D-P16 (issue #1035): the default branch resolves the development-docs root through this module.
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
    $script:repositoryRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $script:entryPath -Parent) -Parent) -Parent
    # Loaded here so a case can mock Read-StageTimingEvidence before the entry runs.
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/StageTiming.psm1') -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name StageTiming -Force -ErrorAction SilentlyContinue
}

Describe 'Get-StageTimingReport.ps1 entry' {
    BeforeEach {
        # D-P16 (issue #1035): no case reads the real routing file.
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = 'docs/features'; Reason = $null } }
    }

    It 'STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS' {
        # Issues 9001 and 9002: S4 totals 600 and 1000 seconds (median 0:13:20); S5 totals 1500 and 900
        # seconds (median 0:20:00). A run without a parameter also prints the labels from the default root.
        $lines = @(& $script:entryPath -EvidenceRoot $script:fixtureRoot)
        # F3 (issue #1016): the default root is not read from the real checkout, which a clean CI checkout lacks.
        Mock Read-StageTimingEvidence { @() }
        $defaultLines = @(& $script:entryPath)

        Should -Invoke Read-StageTimingEvidence -Times 1 -Exactly -ParameterFilter { (Split-Path -Path $Root -Leaf) -ceq 'features' }

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

    It 'STR-ENTRY-DEFAULT-ROOT-FROM-RESOLVER' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:entryPath, [ref] $null, [ref] $null)
        $defaultBranch = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.IfStatementAst] -and $node.Clauses[0].Item1.Extent.Text.Contains('EvidenceRoot') }, $true)
        $calls = @($defaultBranch.Clauses[0].Item2.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Resolve-DevelopmentDocsRoot' }, $true))

        $calls.Count | Should -Be 1
    }

    It 'STR-ENTRY-DEFAULT-ROOT-USES-RESOLVED-ROOT' {
        # Arrange: the repository resolves the .dev root; the evidence read is mocked.
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = '.dev'; Reason = $null } }
        Mock Read-StageTimingEvidence { @() }

        # Act
        $null = @(& $script:entryPath)

        # Assert: the default root is the .dev leaf below the repository root two parents above the script folder.
        Should -Invoke Read-StageTimingEvidence -Times 1 -Exactly -ParameterFilter { (Split-Path -Path $Root -Leaf) -ceq '.dev' }
        Should -Invoke Resolve-DevelopmentDocsRoot -Times 1 -Exactly -ParameterFilter { $WorkspaceRoot -ceq $script:repositoryRoot }
    }

    It 'STR-ENTRY-THROWS-ON-FAILED-RESOLUTION' {
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $false; Root = $null; Reason = 'config/orchestration-routing.json development_docs_root value "x" is not one of: docs/features, .dev.' } }

        { & $script:entryPath } | Should -Throw '*development_docs_root value "x" is not one of*'
    }
}
