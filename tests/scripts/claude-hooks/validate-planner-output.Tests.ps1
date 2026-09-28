#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-planner-output.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'
    . $hookPath

    function Get-ValidPlannerReviewRecord {
        param([string] $Preflight = 'ALL CLEAR')

        @"
PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-planner-output.ps1 | planner review parser
AC-TRACEABILITY: PASS
AC-INVENTORY: AC1, AC2
AC-MAPPING: AC1 | IMPLEMENTATION: .claude/hooks/validate-planner-output.ps1 | TESTS: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | EVIDENCE: docs/features/active/foo/evidence/qa-gates/pester.md
AC-MAPPING: AC2 | IMPLEMENTATION: .claude/agents/atomic-planner.md | TESTS: tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py | EVIDENCE: docs/features/active/foo/evidence/qa-gates/contracts.md
SCOPE-BOUNDARY: PASS
UNRESOLVED-GAPS: NONE
PREFLIGHT: $Preflight
"@.Trim()
    }
}

Describe 'validate-planner-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            $result = Invoke-PlannerOutputValidation -RawPayload ''

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when the output is missing an exact preflight signal' {
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = @() } }
            $raw = @{ output = 'plan-path: docs/features/active/foo/plan.md' } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PREFLIGHT: ALL CLEAR'
        }

        It 'blocks when CLAUDE_HOOK_INPUT is not valid JSON' {
            $result = Invoke-PlannerOutputValidation -RawPayload '{not valid json'

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse'
        }

        It 'blocks when the parsed payload has no output property' {
            $result = Invoke-PlannerOutputValidation -RawPayload '{}'

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'plan-path extraction' {
        It 'blocks when the output has a valid preflight signal but no plan-path token' {
            $raw = @{ output = 'PREFLIGHT: ALL CLEAR' } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a plan-path'
        }

        It 'blocks when the markdown-link plan-path form points at a nonexistent file' {
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $false; Lines = @() } }
            $raw = @{ output = "[plan-path](docs/features/active/foo/plan.md)`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists'
            $result.Message | Should -Match 'docs/features/active/foo/plan.md'
        }

        It 'blocks when the markdown-link plan-path form captures a whitespace-only value' {
            $raw = @{ output = "[plan-path]( )`nPREFLIGHT: ALL CLEAR" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a plan-path'
        }
    }

    Context 'Get-PlanFileContent direct invocation' {
        It 'reports Exists = $false and an empty Lines array for a path guaranteed not to exist' {
            $missingPath = "$PSCommandPath.does-not-exist"

            $file = Get-PlanFileContent -Path $missingPath

            $file.Exists | Should -BeFalse
            ($file.Lines -is [array]) | Should -BeTrue
            $file.Lines.Count | Should -Be 0
        }

        It 'reports Exists = $true and a populated Lines array for a path that already exists on disk' {
            $file = Get-PlanFileContent -Path $PSCommandPath

            $file.Exists | Should -BeTrue
            $file.Lines.Count | Should -BeGreaterThan 0
        }

        It 'normalizes null and scalar content to line arrays' {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { $null }

            $nullContent = Get-PlanFileContent -Path 'null-content.md'

            $nullContent.Exists | Should -BeTrue
            $nullContent.Lines.Count | Should -Be 0

            Mock -CommandName Get-Content -MockWith { 'single line' }

            $scalarContent = Get-PlanFileContent -Path 'scalar-content.md'

            $scalarContent.Exists | Should -BeTrue
            $scalarContent.Lines | Should -Be @('single line')
        }
    }

    Context 'plan structure validation' {
        It 'blocks when the advertised plan-path does not exist on disk' {
            Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $false; Lines = @() } }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord)" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists'
        }

        It 'blocks when Phase 0 baseline and policy-read tasks are missing' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1',
                        "### Phase 2 `u{2014} QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord)" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'Phase 0'
        }

        It 'blocks when a task omits an explicit path' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read policy files',
                        '- [ ] [P0-T2] Capture baseline for docs/features/active/foo/issue.md',
                        "### Phase 1 `u{2014} QA",
                        '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            # Intentional structural negative: review validation is masked by the malformed task path.
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord -Preflight 'REVISIONS REQUIRED')" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'explicit path'
        }

        It 'blocks when a phase heading is malformed (missing the em dash separator)' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        '### Phase 1 Implement',
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1'
                    )
                }
            }
            # Intentional structural negative: review validation is masked by the malformed phase heading.
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord)" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'phase heading must match'
        }

        It 'allows termination when the plan satisfies the structural contract' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read AGENTS.md and .agents/skills/powershell/SKILL.md and record docs/features/active/foo/evidence/baseline/phase0-instructions-read.md',
                        '- [ ] [P0-T2] Capture baseline with pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/baseline/pester.md',
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1',
                        "### Phase 2 `u{2014} Final QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            $raw = @{ output = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord)" } | ConvertTo-Json -Compress

            $result = Invoke-PlannerOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'Get-PlanStructureValidationReport direct invocation' {
        It 'reports an error when a task-like line does not match the full task pattern' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T1] Read policy files and capture baseline for docs/features/active/foo/issue.md',
                '- [ ] not a real task line',
                "### Phase 1 `u{2014} QA",
                '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'task line must match').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when a task line names a phase number that does not match the current phase heading' {
            $lines = @(
                "### Phase 1 `u{2014} Implement",
                '- [ ] [P2-T1] Update .claude/hooks/validate-planner-output.ps1'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'does not match current phase').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when a phase''s first task number skips T1' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T2] Read policy files and capture baseline for docs/features/active/foo/issue.md'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'expected task number').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when the plan has phase headings but no canonical task lines' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                "### Phase 1 `u{2014} QA"
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'canonical task lines').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when Phase 0 mentions baseline but no policy-read wording' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T1] Capture baseline for docs/features/active/foo/issue.md',
                "### Phase 1 `u{2014} QA",
                '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'policy-read task').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when Phase 0 mentions policy but no baseline wording' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T1] Read policy files for docs/features/active/foo/issue.md',
                "### Phase 1 `u{2014} QA",
                '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'baseline task').Count | Should -BeGreaterThan 0
        }

        It 'reports an error when the final phase contains no QA or toolchain wording' {
            $lines = @(
                "### Phase 0 `u{2014} Baseline",
                '- [ ] [P0-T1] Read policy files and capture baseline for docs/features/active/foo/issue.md',
                "### Phase 1 `u{2014} Implement",
                '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1'
            )

            $errors = @(Get-PlanStructureValidationReport -Lines $lines)

            ($errors -match 'QA or toolchain validation').Count | Should -BeGreaterThan 0
        }
    }

    Context 'planner internal review' {
        It 'accepts both preflight signals, multiple citations and mappings, and unrelated prose' {
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read policy files and capture baseline for docs/features/active/foo/issue.md',
                        "### Phase 1 `u{2014} QA",
                        '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }
            foreach ($signal in @('ALL CLEAR', 'REVISIONS REQUIRED')) {
                $output = "Unrelated prose.`nplan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord -Preflight $signal)`nMore unrelated prose."
                $result = Invoke-PlannerOutputValidation -RawPayload (@{ output = $output } | ConvertTo-Json -Compress)

                $result.Ok | Should -BeTrue
            }
        }

        It 'rejects every malformed planner internal review fixture' {
            $valid = Get-ValidPlannerReviewRecord
            $dimensions = @('CITATION-TO-TREE', 'AC-TRACEABILITY', 'SCOPE-BOUNDARY')
            $cases = @(
                @{ Name = 'no record fixture'; Text = 'PREFLIGHT: ALL CLEAR' },
                @{ Name = 'label-only record fixture'; Text = 'PLANNER-INTERNAL-REVIEW: citation-to-tree; ac-traceability; scope-boundary`nPREFLIGHT: ALL CLEAR' },
                @{ Name = 'blank review record fixture'; Text = $valid -replace 'PLANNER-INTERNAL-REVIEW: PASS', 'PLANNER-INTERNAL-REVIEW: ' },
                @{ Name = 'failed review record fixture'; Text = $valid -replace 'PLANNER-INTERNAL-REVIEW: PASS', 'PLANNER-INTERNAL-REVIEW: FAILED' },
                @{ Name = 'duplicate review record fixture'; Text = "PLANNER-INTERNAL-REVIEW: PASS`n$valid" },
                @{ Name = 'no citation fixture'; Text = $valid -replace '(?m)^CITATION:.*\r?\n', '' },
                @{ Name = 'citation path fixture'; Text = $valid -replace 'CITATION: .claude/hooks/validate-planner-output.ps1', 'CITATION: C:\\invalid.ps1' },
                @{ Name = 'citation locator fixture'; Text = $valid -replace ' \| planner review parser', ' | ' },
                @{ Name = 'no inventory fixture'; Text = $valid -replace '(?m)^AC-INVENTORY:.*\r?\n', '' },
                @{ Name = 'blank inventory fixture'; Text = $valid -replace 'AC-INVENTORY: AC1, AC2', 'AC-INVENTORY: ' },
                @{ Name = 'duplicate inventory-ID fixture'; Text = $valid -replace 'AC-INVENTORY: AC1, AC2', 'AC-INVENTORY: AC1, AC1' },
                @{ Name = 'duplicate inventory declaration fixture'; Text = $valid -replace 'AC-INVENTORY: AC1, AC2', "AC-INVENTORY: AC1, AC2`nAC-INVENTORY: AC1, AC2" },
                @{ Name = 'no mapping fixture'; Text = $valid -replace '(?m)^AC-MAPPING:.*\r?\n', '' },
                @{ Name = 'blank mapping fixture'; Text = $valid -replace 'AC-MAPPING: AC1 \| IMPLEMENTATION: .claude/hooks/validate-planner-output.ps1 \| TESTS: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 \| EVIDENCE: docs/features/active/foo/evidence/qa-gates/pester.md', 'AC-MAPPING: ' },
                @{ Name = 'blank mapping ID fixture'; Text = $valid -replace 'AC-MAPPING: AC1 \|', 'AC-MAPPING:  |' },
                @{ Name = 'blank implementation fixture'; Text = $valid -replace 'IMPLEMENTATION: .claude/hooks/validate-planner-output.ps1', 'IMPLEMENTATION: ' },
                @{ Name = 'blank tests fixture'; Text = $valid -replace 'TESTS: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1', 'TESTS: ' },
                @{ Name = 'blank evidence fixture'; Text = $valid -replace 'EVIDENCE: docs/features/active/foo/evidence/qa-gates/pester.md', 'EVIDENCE: ' },
                @{ Name = 'duplicate mapping ID fixture'; Text = $valid -replace 'AC-MAPPING: AC2', 'AC-MAPPING: AC1' },
                @{ Name = 'missing mapping ID fixture'; Text = $valid -replace '(?m)^AC-MAPPING: AC2.*\r?\n', '' },
                @{ Name = 'extra mapping ID fixture'; Text = $valid -replace 'AC-MAPPING: AC2', 'AC-MAPPING: AC3' },
                @{ Name = 'missing unresolved-gap fixture'; Text = $valid -replace '(?m)^UNRESOLVED-GAPS:.*\r?\n', '' },
                @{ Name = 'blank unresolved-gap fixture'; Text = $valid -replace 'UNRESOLVED-GAPS: NONE', 'UNRESOLVED-GAPS: ' },
                @{ Name = 'failed unresolved-gap fixture'; Text = $valid -replace 'UNRESOLVED-GAPS: NONE', 'UNRESOLVED-GAPS: BLOCKED' },
                @{ Name = 'duplicate unresolved-gap fixture'; Text = $valid -replace 'UNRESOLVED-GAPS: NONE', "UNRESOLVED-GAPS: NONE`nUNRESOLVED-GAPS: NONE" },
                @{ Name = 'review label before bounded record fixture'; Text = "CITATION: docs/features/active/foo/plan.md | outside`n$valid" },
                @{ Name = 'review label after bounded record fixture'; Text = "$valid`nAC-INVENTORY: AC1" }
            )
            foreach ($dimension in $dimensions) {
                $cases += @(
                    @{ Name = "missing $dimension fixture"; Text = $valid -replace "(?m)^${dimension}:.*\r?\n", '' },
                    @{ Name = "blank $dimension fixture"; Text = $valid -replace "${dimension}: PASS", "${dimension}: " },
                    @{ Name = "duplicate $dimension fixture"; Text = $valid -replace "${dimension}: PASS", "${dimension}: PASS`n${dimension}: PASS" },
                    @{ Name = "failed $dimension fixture"; Text = $valid -replace "${dimension}: PASS", "${dimension}: BLOCKED" }
                )
            }
            foreach ($case in $cases) {
                $result = Get-PlannerInternalReviewValidation -AgentOutput $case.Text

                $result.Ok | Should -BeFalse -Because $case.Name
            }
        }
    }
}
