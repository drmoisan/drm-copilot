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
}
