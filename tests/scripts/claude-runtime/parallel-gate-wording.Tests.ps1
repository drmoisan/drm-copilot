Set-StrictMode -Version Latest

# Contract guard for issue #1094, with the test-suite baseline restored by issue
# #1097: the mirrored skills, agents, prompts, and templates name only the
# parallel test gates, read coverage from the single gate run, and compare it
# with the Phase 0 baseline, which is one run of the same parallel gate. Each
# `PGW-` row holds one file with its required and forbidden tokens, so a removed
# serial or targeted run that returns to any mirrored copy fails that copy's row.
# Files are read in place; the suite writes nothing.

BeforeDiscovery {
    $script:ContractForbidden = @('no test suite runs', 'no earlier figure')
    $script:QaGateForbidden = @('Targeted runs are allowed')
    $script:PowerShellQaGateForbidden = $script:QaGateForbidden + @('run_poshqc_test')
    $script:PythonQaGateForbidden = $script:QaGateForbidden + @('poetry run pytest --cov')
    $script:ReviewRequired = @('debugging only', 'N/A - no pre-change run', 'Phase 0 baseline')
    $script:ReviewForbidden = @('smallest relevant subset')
    $script:ReviewCommandForbidden = $script:ReviewForbidden + @('run_poshqc_test')
    $script:ExecutorListForbidden = @('`mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`')
    $script:D13Required = @('CI integration and golden lanes are evidence', 'non-blocking deviation', 'machine test-suite lock')
    # Finding F1 of the #1158 review: the direct pytest toolchain commands that the launcher pytest suite replaces.
    $script:DirectPytestForbidden = @('`poetry run pyright`, `poetry run pytest ', '4. `poetry run pytest ', 'Test (`poetry run pytest ')
    $script:ExecutorRouteForbidden = $script:ExecutorListForbidden + @('Bash(poetry run pytest', 'Bash(npx jest')
    $script:ReviewLauncherForbidden = $script:ReviewCommandForbidden + @('npm run test:unit:coverage')
    $script:CopilotPesterForbidden = @('mcp_drmcopilotext_run_poshqc_test')
    $script:CopilotFocusedForbidden = @('-k slug_extraction')
    $script:AuditRequired = @('N/A - no pre-change run', 'poetry run pytest -n auto', 'Invoke-PoshQCParallelTest', 'Phase 0 baseline')
    $script:AuditForbidden = @('Invoke-PoshQCTest')
}

Describe 'Parallel gate wording' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

        <#
        .SYNOPSIS
            Returns the text of a repository file with whitespace runs collapsed.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .OUTPUTS
            [string] The collapsed file text.
        #>
        function Get-PgwSurfaceText {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)]
                [string] $RelativePath
            )

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            return ([System.IO.File]::ReadAllText($path) -replace '\s+', ' ')
        }

        <#
        .SYNOPSIS
            Returns the tokens that a text holds, ignoring case.
        .PARAMETER Content
            The text to search.
        .PARAMETER SearchToken
            The tokens to look for.
        .OUTPUTS
            [System.Object[]] The tokens found in the text.
        #>
        function Get-PgwTokenHit {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)]
                [AllowEmptyString()]
                [string] $Content,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [string[]] $SearchToken
            )

            return @($SearchToken | Where-Object { $Content.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })
        }
    }

    It 'PGW-<Id> carries the required wording and no forbidden wording' -ForEach @(
        @{ Id = 'PLAN-CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:ContractForbidden }
        @{ Id = 'QA-PS-CLAUDE'; Path = '.claude/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-AGENTS'; Path = '.agents/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PY-CLAUDE'; Path = '.claude/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-AGENTS'; Path = '.agents/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only', 'Phase 0 baseline') + $script:D13Required; Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'REVIEW-CLAUDE'; Path = '.claude/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired + $script:D13Required + @('run-test-suite.sh'); Forbidden = $script:ReviewLauncherForbidden }
        @{ Id = 'REVIEW-AGENTS'; Path = '.agents/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired + $script:D13Required + @('run-test-suite.sh'); Forbidden = $script:ReviewLauncherForbidden }
        @{ Id = 'REVIEW-GITHUB'; Path = '.github/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewForbidden }
        @{ Id = 'REVIEW-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired + $script:D13Required + @('run-test-suite.sh'); Forbidden = $script:ReviewLauncherForbidden }
        @{ Id = 'REVIEW-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired + $script:D13Required + @('run-test-suite.sh'); Forbidden = $script:ReviewLauncherForbidden }
        @{ Id = 'REVIEW-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewForbidden }
        @{ Id = 'ADAPTER-AGENTS'; Path = '.agents/skills/repo-automation-adapter/SKILL.md'; Required = @('not a validation gate', 'Invoke-PoshQCParallelTest'); Forbidden = @() }
        @{ Id = 'ADAPTER-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md'; Required = @('not a validation gate', 'Invoke-PoshQCParallelTest'); Forbidden = @() }
        @{ Id = 'EXEC-CLAUDE'; Path = '.claude/agents/atomic-executor.md'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto', 'Phase 0 baseline') + @('run-test-suite.sh'); Forbidden = $script:ExecutorRouteForbidden }
        @{ Id = 'EXEC-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto', 'Phase 0 baseline') + @('run-test-suite.sh'); Forbidden = $script:ExecutorRouteForbidden }
        @{ Id = 'EXEC-CODEX'; Path = '.codex/agents/atomic-executor.toml'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto', 'Phase 0 baseline') + @('run-test-suite.sh'); Forbidden = $script:ExecutorRouteForbidden }
        @{ Id = 'EXEC-CODEX-POWERSHELL'; Path = '.codex/agents/powershell-atomic-executor.toml'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = @('run_poshqc_test') }
        @{ Id = 'COPILOT-EXEC'; Path = '.github/agents/atomic_executor.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-EXEC-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-PS-EXEC'; Path = '.github/agents/powershell-atomic-executor.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-PS-EXEC-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-PS-TYPED'; Path = '.github/agents/powershell-typed-engineer.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-PS-TYPED-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md'; Required = @('Invoke-PoshQCParallelTest'); Forbidden = $script:CopilotPesterForbidden }
        @{ Id = 'COPILOT-PY-EXEC'; Path = '.github/agents/python-atomic-executor.agent.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-PY-EXEC-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-COMMENTARY'; Path = '.github/agents/commentary-remediation.agent.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-COMMENTARY-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/commentary-remediation.agent.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-REMEDIATE-PROMPT'; Path = '.github/prompts/remediate-comments.prompt.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-REMEDIATE-PROMPT-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/prompts/remediate-comments.prompt.md'; Required = @('poetry run pytest -n auto'); Forbidden = @() }
        @{ Id = 'COPILOT-PLANNING'; Path = '.github/agents/atomic_planning.agent.md'; Required = @('pytest -n auto'); Forbidden = $script:CopilotFocusedForbidden }
        @{ Id = 'COPILOT-PLANNING-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md'; Required = @('pytest -n auto'); Forbidden = $script:CopilotFocusedForbidden }
        @{ Id = 'COPILOT-PS-PLANNING'; Path = '.github/agents/powershell-atomic-planning.agent.md'; Required = @('pytest -n auto'); Forbidden = $script:CopilotFocusedForbidden }
        @{ Id = 'COPILOT-PS-PLANNING-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md'; Required = @('pytest -n auto'); Forbidden = $script:CopilotFocusedForbidden }
        @{ Id = 'COPILOT-TDD-GREEN'; Path = '.github/agents/tdd-green.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-TDD-GREEN-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/tdd-green.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-TDD-RED'; Path = '.github/agents/tdd-red.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-TDD-RED-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/tdd-red.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-TS-ENGINEER'; Path = '.github/agents/typescript-engineer.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-TS-ENGINEER-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md'; Required = @('debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-STAGED-REVIEW'; Path = '.github/agents/staged-review.agent.md'; Required = @('Invoke-PoshQCParallelTest', 'pytest -n auto', 'debugging only'); Forbidden = @() }
        @{ Id = 'COPILOT-STAGED-REVIEW-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md'; Required = @('Invoke-PoshQCParallelTest', 'pytest -n auto', 'debugging only'); Forbidden = @() }
        @{ Id = 'AUDIT-TEMPLATE'; Path = 'docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md'; Required = $script:AuditRequired; Forbidden = $script:AuditForbidden }
        @{ Id = 'AUDIT-TEMPLATE-BUNDLE'; Path = 'extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md'; Required = $script:AuditRequired; Forbidden = $script:AuditForbidden }
        @{ Id = 'AUDIT-AGENTS'; Path = 'docs/features/templates/policy_audit/AGENTS.md'; Required = @('pytest -n auto', 'Invoke-PoshQCParallelTest', 'Phase 0 baseline'); Forbidden = @() }
        @{ Id = 'AUDIT-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md'; Required = @('pytest -n auto', 'Invoke-PoshQCParallelTest', 'Phase 0 baseline'); Forbidden = @() }
        @{ Id = 'BRIEF-CLAUDE'; Path = '.claude/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'BRIEF-AGENTS'; Path = '.agents/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'BRIEF-GITHUB'; Path = '.github/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'BRIEF-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'BRIEF-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'BRIEF-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md'; Required = $script:D13Required + @('run-test-suite.sh'); Forbidden = @() }
        @{ Id = 'QA-CS-CLAUDE'; Path = '.claude/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'QA-CS-AGENTS'; Path = '.agents/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'QA-CS-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'QA-CS-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'QA-CS-CLAUDE-LEGACY'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'QA-CS-AGENTS-LEGACY'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md'; Required = $script:D13Required; Forbidden = $script:QaGateForbidden }
        @{ Id = 'INVOKE-PY-CLAUDE'; Path = '.claude/skills/invoke-python-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PY-AGENTS'; Path = '.agents/skills/invoke-python-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PY-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PY-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PS-CLAUDE'; Path = '.claude/skills/invoke-powershell-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PS-AGENTS'; Path = '.agents/skills/invoke-powershell-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PS-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-PS-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-CLAUDE'; Path = '.claude/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-AGENTS'; Path = '.agents/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-CLAUDE-LEGACY'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'INVOKE-CS-AGENTS-LEGACY'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-CLAUDE'; Path = '.claude/agents/typescript-engineer.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-CODEX'; Path = '.codex/agents/typescript-engineer.toml'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-CODEX-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer.toml'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-COPILOT'; Path = '.github/agents/typescript-engineer.agent.md'; Required = $script:D13Required; Forbidden = @() }
        @{ Id = 'TS-AGENT-COPILOT-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md'; Required = $script:D13Required; Forbidden = @() }
    ) {
        # Arrange
        $text = Get-PgwSurfaceText -RelativePath $Path

        # Act
        $missing = @($Required | Where-Object { -not $text.Contains($_) })
        $held = @(Get-PgwTokenHit -Content $text -SearchToken $Forbidden)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must state the parallel gates"
        $held | Should -BeNullOrEmpty -Because "$Path must not name a removed run"
    }

    Context 'Class sweep' {
        BeforeAll {
            # The removed run-class tokens: targeted, per-batch, and subset test runs.
            # Baseline wording is not swept, because issue #1097 restored the Phase 0
            # baseline as one run of the parallel gate.
            $script:SweepToken = @(
                'targeted Pester', 'targeted Pytest', 'targeted xUnit', 'targeted MSTest', 'targeted tests',
                'run tests after each', 'relevant tests using', 'running tests frequently',
                'smallest applicable subset', 'relevant tests pass', 'repro and regression test',
                'Run the regression to confirm'
            )

            $resources = 'extensions/drm-copilot/resources'
            $script:SweepRoot = @(
                '.claude/skills', '.claude/agents', '.agents/skills', '.github/agents', '.github/skills', '.github/prompts',
                '.github/codex', '.codex/agents', 'docs/features/templates',
                "$resources/claude-customizations", "$resources/codex-and-agents-customizations", "$resources/customizations",
                "$resources/templates/policy_audit", "$resources/feature-templates"
            )

            # Each entry matches a path segment, so it covers the base file, its
            # bundle copy, and any bundle variant of the same folder.
            $script:SweepExclusion = @(
                @{ Segment = '/.claude/rules/'; Reason = 'Policy file; this item does not edit policy files.' }
                @{ Segment = '/.claude-variants/csharp-legacy/rules/'; Reason = 'Bundle variant of a policy file.' }
                @{ Segment = '/.github/instructions/'; Reason = 'Policy file; this item does not edit policy files.' }
                @{ Segment = '/.agents/skills/powershell/'; Reason = 'Mirror of a policy rule.' }
                @{ Segment = '/.agents/skills/python/'; Reason = 'Mirror of a policy rule.' }
                @{ Segment = '/.agents/skills/csharp/'; Reason = 'Mirror of a policy rule.' }
                @{ Segment = '/.agents-variants/csharp-legacy/skills/csharp/'; Reason = 'Bundle variant of a mirror of a policy rule.' }
                @{ Segment = '/.agents/skills/typescript/'; Reason = 'Mirror of a policy rule.' }
                @{ Segment = '/.agents/skills/quality-tiers/'; Reason = 'Mirror of a policy rule.' }
                @{ Segment = '/skills/benchmark-baselines/'; Reason = 'A performance baseline, not a test-suite baseline.' }
                @{ Segment = '/skills/translate-copilot-to-claude/'; Reason = 'Lists zero-regression as a phrase to translate, not a requirement.' }
            )

            <#
            .SYNOPSIS
                Returns the removed-class tokens that a text holds.
            .PARAMETER Content
                The text to search.
            .OUTPUTS
                [System.Object[]] The sweep tokens found in the text.
            #>
            function Get-PgwSweepHit {
                [CmdletBinding()]
                [OutputType([System.Object[]])]
                param(
                    [Parameter(Mandatory = $true)]
                    [AllowEmptyString()]
                    [string] $Content
                )

                return @(Get-PgwTokenHit -Content $Content -SearchToken $script:SweepToken)
            }

            <#
            .SYNOPSIS
                Returns the repository-relative paths of the swept surface files.
            .OUTPUTS
                [System.Object[]] The relative paths, with forward slashes.
            #>
            function Get-PgwSweepFile {
                [CmdletBinding()]
                [OutputType([System.Object[]])]
                param()

                $files = foreach ($folder in $script:SweepRoot) {
                    $path = Join-Path -Path $script:RepoRoot -ChildPath $folder
                    Get-ChildItem -LiteralPath $path -Recurse -File -Force | Where-Object { $_.Extension -in '.md', '.toml' }
                }
                $relative = @($files | ForEach-Object { [System.IO.Path]::GetRelativePath($script:RepoRoot, $_.FullName).Replace('\', '/') })
                return @($relative | Where-Object {
                        $candidate = "/$_"
                        -not ($script:SweepExclusion | Where-Object { $candidate.Contains($_.Segment) })
                    })
            }
        }

        It 'PGW-SWEEP-SURFACES finds no removed-class token in any surface' {
            # Arrange
            $files = Get-PgwSweepFile

            # Act
            $offending = @(foreach ($file in $files) {
                    $hits = @(Get-PgwSweepHit -Content (Get-PgwSurfaceText -RelativePath $file))
                    if ($hits.Count -gt 0) { '{0}: {1}' -f $file, ($hits -join ', ') }
                })

            # Assert
            $files.Count | Should -BeGreaterThan 0 -Because 'the sweep must read the surfaces'
            $offending | Should -BeNullOrEmpty -Because 'a removed requirement must not return to a skill, agent, or template'
        }

        It 'PGW-SWEEP-HELPER finds each removed-class token in in-memory text' {
            # Arrange
            $tokens = $script:SweepToken

            # Act
            # Fold case in the text, because the sweep ignores case. A longer token can also
            # hold a shorter one, so each token is checked for presence, not for equality.
            $missed = @(foreach ($token in $tokens) {
                    $hits = @(Get-PgwSweepHit -Content "A surface that states $($token.ToUpperInvariant()) in prose.")
                    if ($hits -cnotcontains $token) { $token }
                })

            # Assert
            $tokens.Count | Should -Be 12 -Because 'the plan names 12 run-class sweep tokens'
            $missed | Should -BeNullOrEmpty -Because 'a reintroduced token must fail the sweep'
        }
    }

    It 'PGW-LAUNCHER-<Id> names the launcher and no direct pytest toolchain command' -ForEach @(
        @{ Id = 'EXEC-CLAUDE'; Path = '.claude/agents/atomic-executor.md'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX'; Path = '.codex/agents/atomic-executor.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX-C1'; Path = '.codex/agents/atomic-executor-c1.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX-C2'; Path = '.codex/agents/atomic-executor-c2.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX-C3'; Path = '.codex/agents/atomic-executor-c3.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX-C3-ELEVATED'; Path = '.codex/agents/atomic-executor-c3-elevated.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'EXEC-CODEX-C4'; Path = '.codex/agents/atomic-executor-c4.toml'; Required = @('run-test-suite.sh pytest', 'run-test-suite.sh pester'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'QA-PY-CLAUDE'; Path = '.claude/skills/python-qa-gate/SKILL.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'QA-PY-AGENTS'; Path = '.agents/skills/python-qa-gate/SKILL.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'QA-PY-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'QA-PY-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'COPILOT-PY-EXEC'; Path = '.github/agents/python-atomic-executor.agent.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
        @{ Id = 'COPILOT-PY-EXEC-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md'; Required = @('run-test-suite.sh pytest'); Forbidden = $script:DirectPytestForbidden }
    ) {
        # Arrange
        $text = Get-PgwSurfaceText -RelativePath $Path

        # Act
        $missing = @($Required | Where-Object { -not $text.Contains($_) })
        $held = @(Get-PgwTokenHit -Content $text -SearchToken $Forbidden)

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must name the launcher suites"
        $held | Should -BeNullOrEmpty -Because "$Path must not name a direct pytest toolchain command"
    }

    It 'PGW-SCOPED-<Id> names the scoped Pester route' -ForEach @(
        @{ Id = 'CLAUDE'; Path = '.claude/skills/test-execution-policy/SKILL.md' }
        @{ Id = 'AGENTS'; Path = '.agents/skills/test-execution-policy/SKILL.md' }
        @{ Id = 'GITHUB'; Path = '.github/skills/test-execution-policy/SKILL.md' }
        @{ Id = 'CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/SKILL.md' }
        @{ Id = 'AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/SKILL.md' }
        @{ Id = 'GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/test-execution-policy/SKILL.md' }
    ) {
        # Arrange
        $text = Get-PgwSurfaceText -RelativePath $Path

        # Act
        $missing = @(@('-TestPath', 'fail-before proof') | Where-Object { -not $text.Contains($_) })

        # Assert
        $missing | Should -BeNullOrEmpty -Because "$Path must state the scoped Pester route (C1)"
    }
}
