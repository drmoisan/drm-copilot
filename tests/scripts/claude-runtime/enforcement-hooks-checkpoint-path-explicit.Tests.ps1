#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Structural guard: every checkpoint reader is given its path explicitly (issue #673).

.DESCRIPTION
    Issue #673 removed three bindings in which a gate read whichever orchestrator
    checkpoint occupied the calling process's directory. Each removal took the same shape:
    a parameter default holding a relative path was deleted, and the caller began passing
    the absolute path that target resolution selected.

    A behavioural test cannot see a binding reintroduced on a path it does not exercise, so
    this file guards the shape instead. It parses every production PowerShell file under
    .claude/hooks and .claude/lib and asserts that each call to a checkpoint reader carries
    a CheckpointPath argument, and that no in-scope hook carries the checkpoint filename in
    any string expression. A reintroduced default would fail the second assertion even if
    no caller relied on it yet.

    Each call-site row also asserts its collection is non-empty, so a renamed function
    cannot turn the row into a vacuous pass over zero call sites.

.NOTES
    Reads source through the PowerShell parser only. No test creates a file, spawns a
    process, reads a wall clock, or touches the network.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:ProductionFile = @(
        Get-ChildItem -Path (Join-Path $script:RepoRoot '.claude/hooks'), (Join-Path $script:RepoRoot '.claude/lib') `
            -Recurse -File -Include '*.ps1', '*.psm1'
    )

    # Return one record per production call to the named command, noting whether it carries
    # an explicit CheckpointPath argument. A command name that is not a bareword yields
    # $null from GetCommandName and is skipped, which is correct: an invocation through a
    # variable or a call operator names no target this guard can attribute.
    function Get-CheckpointCallSite {
        param([Parameter(Mandatory)] [string] $CommandName)
        $found = [System.Collections.Generic.List[object]]::new()
        foreach ($file in $script:ProductionFile) {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
            foreach ($command in @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true))) {
                if ($command.GetCommandName() -ne $CommandName) { continue }
                $explicit = @($command.CommandElements | Where-Object {
                        $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'CheckpointPath'
                    }).Count -gt 0
                $found.Add([pscustomobject]@{
                        File              = $file.Name
                        Line              = $command.Extent.StartLineNumber
                        HasCheckpointPath = $explicit
                    })
            }
        }
        return , $found.ToArray()
    }
}

Describe 'enforcement hooks supply the checkpoint path explicitly' {
    It 'every production call to Invoke-OrchestratorStatePreflight supplies CheckpointPath explicitly' {
        # Arrange / Act
        $sites = Get-CheckpointCallSite -CommandName 'Invoke-OrchestratorStatePreflight'
        $calls = @($sites)

        # Assert: a zero-length collection would make this row vacuous, so it is rejected first.
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'every production call to Get-PrAuthorCheckpointContent supplies CheckpointPath explicitly' {
        # Arrange / Act
        $calls = @(Get-CheckpointCallSite -CommandName 'Get-PrAuthorCheckpointContent')

        # Assert
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'every production call to Get-ModelRoutingCheckpoint supplies CheckpointPath explicitly' {
        # Arrange / Act
        $calls = @(Get-CheckpointCallSite -CommandName 'Get-ModelRoutingCheckpoint')

        # Assert
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'every production call to Test-EpicBaseBranchOverride supplies CheckpointPath explicitly' {
        # Arrange / Act
        $calls = @(Get-CheckpointCallSite -CommandName 'Test-EpicBaseBranchOverride')

        # Assert
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'every production call to Test-PrAuthorReceiptVerification supplies CheckpointPath explicitly' {
        # Arrange / Act
        $calls = @(Get-CheckpointCallSite -CommandName 'Test-PrAuthorReceiptVerification')

        # Assert
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'every production call to Get-PrdFeatureCheckpointFolder supplies CheckpointPath explicitly' {
        # Arrange / Act
        $calls = @(Get-CheckpointCallSite -CommandName 'Get-PrdFeatureCheckpointFolder')

        # Assert
        $calls.Count | Should -BeGreaterThan 0
        @($calls | Where-Object { -not $_.HasCheckpointPath }) | Should -BeNullOrEmpty
    }

    It 'the in-scope hook files carry the checkpoint path literal in no string expression' {
        # Arrange: the in-scope hook files, as one array literal so the set can be widened
        # in a single line when another gate joins it.
        $inScope = @(
            '.claude/hooks/enforce-pr-author-skill.ps1'
            '.claude/hooks/enforce-pr-author-skill-helpers.ps1'
            '.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1'
            '.claude/hooks/enforce-model-routing-receipt.ps1'
            '.claude/hooks/enforce-prd-feature-before-planner.ps1'
        )
        $literal = 'orchestrator-state.json'

        # Act: collect every string expression in those files that carries the literal. A
        # comment is not a string expression, so prose naming the file is untouched; only a
        # value a reader could actually use is reported.
        $offender = [System.Collections.Generic.List[string]]::new()
        foreach ($relative in $inScope) {
            $path = Join-Path $script:RepoRoot $relative
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref] $null, [ref] $null)
            $strings = @($ast.FindAll({
                        $args[0] -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
                        $args[0] -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
                    }, $true))
            foreach ($node in $strings) {
                if ($node.Extent.Text.Contains($literal)) {
                    $offender.Add(('{0}:{1}' -f $relative, $node.Extent.StartLineNumber))
                }
            }
        }

        # Assert: the in-scope set is non-empty, and no file in it names the checkpoint by
        # filename in a value. A reintroduced relative default would fail here.
        $inScope.Count | Should -BeGreaterThan 0
        $offender | Should -BeNullOrEmpty
    }

    It 'the orchestrator-state module keeps its four hundred ninety-nine line count' {
        # Arrange: the module the spec requires this change set to leave unmodified, one
        # line below the repository's cap.
        $modulePath = Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorState.psm1'

        # Act
        $lineCount = @(Get-Content -LiteralPath $modulePath).Count

        # Assert: any edit to that file would move this number, and the file has no headroom
        # for one, so the count is pinned rather than bounded.
        $lineCount | Should -Be 499
    }
}
