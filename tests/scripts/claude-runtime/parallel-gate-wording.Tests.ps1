Set-StrictMode -Version Latest

# Contract guard for issue #1094: the mirrored skills, agents, prompts, and
# templates name only the parallel test gates and read coverage from the single
# gate run. Each `PGW-` row holds one file with its required and forbidden
# tokens, so a removed requirement that returns to any mirrored copy fails that
# copy's row. Files are read in place; the suite writes nothing.

BeforeDiscovery {
    $script:ContractForbidden = @('baseline test-step', 'baseline and final-QC coverage', 'delta/threshold verification', 'baseline coverage')
    $script:QaGateForbidden = @('Phase A baseline', 'Delta Requirements', 'zero-regression', 'baseline coverage', 'Targeted runs are allowed')
    $script:PowerShellQaGateForbidden = $script:QaGateForbidden + @('run_poshqc_test')
    $script:PythonQaGateForbidden = $script:QaGateForbidden + @('poetry run pytest --cov')
    $script:ReviewRequired = @('debugging only', 'N/A - no pre-change run')
    $script:ReviewForbidden = @('smallest relevant subset', 'regression on changed lines')
    $script:ReviewCommandForbidden = $script:ReviewForbidden + @('run_poshqc_test')
    $script:ExecutorListForbidden = @('`mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`')
    $script:CopilotPesterForbidden = @('mcp_drmcopilotext_run_poshqc_test')
    $script:CopilotFocusedForbidden = @('-k slug_extraction')
    $script:AuditRequired = @('N/A - no pre-change run', 'poetry run pytest -n auto', 'Invoke-PoshQCParallelTest')
    $script:AuditForbidden = @('numeric baseline', 'Baseline (pre-development)', 'Invoke-PoshQCTest')
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
            [string[]] The tokens found in the text.
        #>
        function Get-PgwTokenHit {
            [CmdletBinding()]
            [OutputType([string[]])]
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
        @{ Id = 'PLAN-CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'PLAN-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md'; Required = @('single gate run'); Forbidden = $script:ContractForbidden }
        @{ Id = 'QA-PS-CLAUDE'; Path = '.claude/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only'); Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-AGENTS'; Path = '.agents/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only'); Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only'); Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PS-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md'; Required = @('single gate run', 'Invoke-PoshQCParallelTest', 'debugging only'); Forbidden = $script:PowerShellQaGateForbidden }
        @{ Id = 'QA-PY-CLAUDE'; Path = '.claude/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only'); Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-AGENTS'; Path = '.agents/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only'); Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only'); Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'QA-PY-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md'; Required = @('single gate run', 'poetry run pytest -n auto', 'debugging only'); Forbidden = $script:PythonQaGateForbidden }
        @{ Id = 'REVIEW-CLAUDE'; Path = '.claude/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewCommandForbidden }
        @{ Id = 'REVIEW-AGENTS'; Path = '.agents/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewCommandForbidden }
        @{ Id = 'REVIEW-GITHUB'; Path = '.github/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewForbidden }
        @{ Id = 'REVIEW-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewCommandForbidden }
        @{ Id = 'REVIEW-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewCommandForbidden }
        @{ Id = 'REVIEW-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewForbidden }
        @{ Id = 'ADAPTER-AGENTS'; Path = '.agents/skills/repo-automation-adapter/SKILL.md'; Required = @('not a validation gate', 'Invoke-PoshQCParallelTest'); Forbidden = @() }
        @{ Id = 'ADAPTER-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md'; Required = @('not a validation gate', 'Invoke-PoshQCParallelTest'); Forbidden = @() }
        @{ Id = 'EXEC-CLAUDE'; Path = '.claude/agents/atomic-executor.md'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto'); Forbidden = $script:ExecutorListForbidden }
        @{ Id = 'EXEC-CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto'); Forbidden = $script:ExecutorListForbidden }
        @{ Id = 'EXEC-CODEX'; Path = '.codex/agents/atomic-executor.toml'; Required = @('Invoke-PoshQCParallelTest', 'poetry run pytest -n auto'); Forbidden = $script:ExecutorListForbidden }
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
        @{ Id = 'AUDIT-TEMPLATE'; Path = 'docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md'; Required = $script:AuditRequired; Forbidden = $script:AuditForbidden }
        @{ Id = 'AUDIT-TEMPLATE-BUNDLE'; Path = 'extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md'; Required = $script:AuditRequired; Forbidden = $script:AuditForbidden }
        @{ Id = 'AUDIT-AGENTS'; Path = 'docs/features/templates/policy_audit/AGENTS.md'; Required = @('pytest -n auto', 'Invoke-PoshQCParallelTest'); Forbidden = @('Document baseline coverage') }
        @{ Id = 'AUDIT-AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md'; Required = @('pytest -n auto', 'Invoke-PoshQCParallelTest'); Forbidden = @('Document baseline coverage') }
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
            # The removed-class tokens. `baseline coverage` is not listed, because the
            # policy-audit template keeps it as a validator anchor.
            $script:SweepToken = @(
                'zero-regression', 'numeric baseline', 'coverage delta', 'coverage-comparison', 'coverage-bearing',
                'captured baseline', 'Phase A baseline', 'coverage baseline', '>= baseline', 'baseline/post',
                'regression on changed lines', 'regressed from baseline', 'test deltas', 'coverage deltas',
                'failing tests delta', 'failing-test delta', 'failing-tests delta', 'Pester delta', 'Pytest delta',
                'xUnit delta', 'Delta Requirements'
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
                [string[]] The sweep tokens found in the text.
            #>
            function Get-PgwSweepHit {
                [CmdletBinding()]
                [OutputType([string[]])]
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
                [string[]] The relative paths, with forward slashes.
            #>
            function Get-PgwSweepFile {
                [CmdletBinding()]
                [OutputType([string[]])]
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
            $tokens.Count | Should -Be 21 -Because 'the plan names 21 sweep tokens'
            $missed | Should -BeNullOrEmpty -Because 'a reintroduced token must fail the sweep'
        }
    }
}
