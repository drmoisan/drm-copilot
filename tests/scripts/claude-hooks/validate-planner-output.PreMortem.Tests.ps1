#Requires -Version 7.0
<#
.SYNOPSIS
    Pre-Mortem and citation-locator rules of .claude/hooks/validate-planner-output.ps1 (issue #964).

.DESCRIPTION
    Plan content reaches the hook through a Pester mock of Get-PlanFileContent, so every fixture is an
    in-memory line array; no test creates, reads, or deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1')

    function Get-PreMortemPlanLine {
        # Returns a structurally valid plan; -PreMortem supplies the Pre-Mortem section lines.
        param([string[]] $PreMortem)
        $head = @('# Plan', '')
        $phases = @(
            "### Phase 0 `u{2014} Baseline",
            '- [ ] [P0-T1] Read policy files in `.claude/rules/general-code-change.md`.',
            '- [ ] [P0-T2] Capture baseline tests in `docs/features/active/foo/evidence/baseline/`.',
            "### Phase 1 `u{2014} Final QA",
            '- [ ] [P1-T1] Run the test toolchain for `tests/scripts/claude-hooks/`.'
        )
        return [string[]]@($head + $PreMortem + @('') + $phases)
    }

    function Get-CompletePreMortem {
        # Returns a valid Pre-Mortem section.
        return [string[]]@('## Pre-Mortem', '') + @(Get-PreMortemLabel | ForEach-Object { "- ${_}: mitigated." }) + @('', '## Phases')
    }

    function Get-ReviewRecord {
        # Returns a valid internal-review record whose CITATION locator is supplied.
        param([string] $Locator = 'Get-PlannerInternalReviewValidation')
        @"
plan-path: docs/features/active/foo/plan.md
PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-planner-output.ps1 | $Locator
AC-TRACEABILITY: PASS
AC-INVENTORY: AC1
AC-MAPPING: AC1 | IMPLEMENTATION: .claude/hooks/validate-planner-output.ps1 | TESTS: tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1 | EVIDENCE: docs/features/active/foo/evidence/qa-gates/pester.md
SCOPE-BOUNDARY: PASS
UNRESOLVED-GAPS: NONE
PREFLIGHT: ALL CLEAR
"@.Trim()
    }
}

Describe 'validate-planner-output Pre-Mortem and locator rules (issue #964)' {
    It 'blocks repairably when the plan has no Pre-Mortem section' {
        # Arrange
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = (Get-PreMortemPlanLine -PreMortem @('## Phases')) } }

        # Act
        $decision = Get-PlannerOutputBlockDecision -AgentOutput (Get-ReviewRecord)

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'no `## Pre-Mortem` section'
    }

    It 'blocks repairably when the Pre-Mortem section misses one label' {
        # Arrange
        $section = @(Get-CompletePreMortem | Where-Object { -not $_.StartsWith('- Test isolation:') })
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = (Get-PreMortemPlanLine -PreMortem $section) } }

        # Act
        $decision = Get-PlannerOutputBlockDecision -AgentOutput (Get-ReviewRecord)

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'Test isolation'
    }

    It 'blocks repairably on the line-reference locator <Locator>' -ForEach @(
        @{ Locator = '42' }
        @{ Locator = '120-134' }
        @{ Locator = 'L42' }
        @{ Locator = '#L42' }
        @{ Locator = 'line 42' }
        @{ Locator = 'lines 12-20' }
        @{ Locator = 'validate-planner-output.ps1:42' }
    ) {
        # Arrange
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = (Get-PreMortemPlanLine -PreMortem (Get-CompletePreMortem)) } }

        # Act
        $decision = Get-PlannerOutputBlockDecision -AgentOutput (Get-ReviewRecord -Locator $Locator)

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'is a line reference'
    }

    It 'allows a plan with a valid Pre-Mortem and a <Kind> locator' -ForEach @(
        @{ Kind = 'symbol'; Locator = 'Get-PlannerInternalReviewValidation' }
        @{ Kind = 'heading'; Locator = '## Preflight Validation' }
        @{ Kind = 'test name'; Locator = 'test_brief_has_required_headings' }
    ) {
        # Arrange
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = (Get-PreMortemPlanLine -PreMortem (Get-CompletePreMortem)) } }

        # Act
        $decision = Get-PlannerOutputBlockDecision -AgentOutput (Get-ReviewRecord -Locator $Locator)

        # Assert
        $decision.Ok | Should -BeTrue
        $decision.Message | Should -BeNullOrEmpty
    }
}
