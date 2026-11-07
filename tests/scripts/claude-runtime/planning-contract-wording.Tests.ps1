Set-StrictMode -Version Latest

# Contract guard for issue #1097: the planning contract, its mirrored copies, and the
# surfaces that restate it carry the planning-side wording of the process-reduction
# work. Each `PCW-` row reads one file in place with whitespace runs collapsed; the
# suite writes nothing.

BeforeDiscovery {
    $resources = 'extensions/drm-copilot/resources'
    $script:ContractCopy = @(
        @{ Copy = 'CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md' }
        @{ Copy = 'CLAUDE-BUNDLE'; Path = "$resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md" }
        @{ Copy = 'AGENTS-BUNDLE'; Path = "$resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md" }
        @{ Copy = 'GITHUB-BUNDLE'; Path = "$resources/customizations/.github/skills/atomic-plan-contract/SKILL.md" }
    )
}

Describe 'Planning contract wording' {
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
        function Get-PcwSurfaceText {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)]
                [string] $RelativePath
            )

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            return ([System.IO.File]::ReadAllText($path) -replace '\s+', ' ')
        }
    }

    It 'PCW-STANDING-RULE-<Copy> states the process-reduction ledger rule' -ForEach $script:ContractCopy {
        # Arrange
        $required = @(
            '`docs/engineering/process-reductions/` exists',
            'adds its ledger entry in the same commit',
            'One-off waivers for a single item are not entries.'
        )

        # Act
        $text = Get-PcwSurfaceText -RelativePath $Path
        $missing = @($required | Where-Object { -not $text.Contains($_) })

        # Assert
        $text.Contains('## Process-Reduction Ledger') | Should -BeTrue -Because "$Path must carry the standing-rule section"
        $missing | Should -BeNullOrEmpty -Because "$Path must state the planning-side ledger rule"
    }
}
