#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    The commit, receipt, and pull-request stage and the refresh procedure of the
    documentation-workflow skill in all six copies (issue #1169).

.DESCRIPTION
    Each row reads one committed copy, takes the text of one level-two section (from its heading to
    the next level-two heading), collapses whitespace runs to one space, and checks ordinal tokens.
    Step order is the order of the first ordinal occurrence of each step token inside the section.
    No row writes a file or starts a process.
#>

BeforeDiscovery {
    $script:WorkflowCopyRows = @(
        @{ Path = '.claude/skills/documentation-workflow/SKILL.md' }
        @{ Path = '.agents/skills/documentation-workflow/SKILL.md' }
        @{ Path = '.github/skills/documentation-workflow/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/documentation-workflow/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/documentation-workflow/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/customizations/.github/skills/documentation-workflow/SKILL.md' }
    )
    $script:BriefCopyRows = @(
        @{ Path = '.claude/skills/execution-environment/SKILL.md' }
        @{ Path = '.agents/skills/execution-environment/SKILL.md' }
        @{ Path = '.github/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    function Get-CommitStageSection {
        # Pure over the committed text: the normalized body of one level-two section, or $null.
        param([Parameter(Mandatory)] [string] $RelativePath, [Parameter(Mandatory)] [string] $Heading)
        $text = (Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n"
        $match = [regex]::Match($text, '(?ms)^' + [regex]::Escape($Heading) + '[ \t]*\n(?<body>.*?)(?=^## |\z)')
        if (-not $match.Success) { return $null }
        return ($match.Groups['body'].Value -replace '\s+', ' ')
    }

    function Get-CommitStageHeadingIndex {
        param([Parameter(Mandatory)] [string] $RelativePath, [Parameter(Mandatory)] [string] $Heading)
        $lines = @((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -split "`r?`n")
        return [array]::IndexOf([string[]]$lines, $Heading)
    }
}

AfterAll {
    foreach ($name in 'Get-CommitStageSection', 'Get-CommitStageHeadingIndex') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
}

Describe 'documentation-workflow commit stage (issue #1169)' {
    It 'places ## Commit, Receipt and Pull Request after ## Dispatch Order in <Path>' -ForEach $script:WorkflowCopyRows {
        # Act
        $dispatch = Get-CommitStageHeadingIndex -RelativePath $Path -Heading '## Dispatch Order'
        $stage = Get-CommitStageHeadingIndex -RelativePath $Path -Heading '## Commit, Receipt and Pull Request'

        # Assert
        $dispatch | Should -BeGreaterThan -1
        $stage | Should -BeGreaterThan $dispatch
    }

    It 'orders the commit, receipt, push, and delegate steps in <Path>' -ForEach $script:WorkflowCopyRows {
        # Arrange
        $section = Get-CommitStageSection -RelativePath $Path -Heading '## Commit, Receipt and Pull Request'

        # Act
        $positions = @('git commit -F', '-WriteReceipt', 'git push', 'Agent(pr-author)' | ForEach-Object { $section.IndexOf($_, [System.StringComparison]::Ordinal) })

        # Assert
        $positions | Should -Not -Contain -1
        $positions | Should -Be @($positions | Sort-Object) -Because 'the steps run commit, receipt, push, then delegate'
        $section.Contains('git add --', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the commit step stages with git add --'
    }

    It 'states the delegation-prompt contract and the stage rules in <Path>' -ForEach $script:WorkflowCopyRows {
        # Arrange
        $section = Get-CommitStageSection -RelativePath $Path -Heading '## Commit, Receipt and Pull Request'
        $tokens = @(
            'branch:', 'base:', 'Canonical issue number for this feature is', 'Author-asserted autoclose issues:',
            'gh pr create --head <branch> --base <base>',
            'tracking issue', 'artifacts/pr_body_<N>.md',
            "another item's checkpoint", 'decline',
            'docs path set', 'denied at commit, PR creation, and merge'
        )

        # Assert
        foreach ($token in $tokens) { $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the stage states '$token'" }
    }

    It 'lists the seven refresh steps in order in <Path>' -ForEach $script:WorkflowCopyRows {
        # Arrange
        $section = Get-CommitStageSection -RelativePath $Path -Heading '## Refresh After Rebase or Source Change'
        $steps = @('Re-inventory at the new revision', 'Regenerate the reference pages', 'surface_refs', 'Re-review the changed elements', 'Rebuild the ledger', 'Re-validate', 'Write a new receipt')

        # Act
        $positions = @($steps | ForEach-Object { $section.IndexOf($_, [System.StringComparison]::Ordinal) })

        # Assert
        $null -eq $section | Should -BeFalse
        $positions | Should -Not -Contain -1
        $positions | Should -Be @($positions | Sort-Object) -Because 'the refresh steps keep the order of the specification'
    }
}

Describe 'execution-environment brief docs-estate entries (issue #1169)' {
    It 'carries the Docs-estate legs (#1169) bullet in ## Hook Execution Context of <Path>' -ForEach $script:BriefCopyRows {
        # Arrange
        $text = (Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw) -replace "`r`n", "`n"
        $match = [regex]::Match($text, '(?ms)^## Hook Execution Context[ \t]*\n(?<body>.*?)(?=^## |\z)')

        # Act
        $bullet = [regex]::IsMatch($match.Groups['body'].Value, '(?m)^- Docs-estate legs \(#1169\)')

        # Assert
        $match.Success | Should -BeTrue
        $bullet | Should -BeTrue
    }

    It 'lists the four new contract suites in ## Contract Tests That Pin Mirrored Files of <Path>' -ForEach $script:BriefCopyRows {
        # Arrange
        $section = Get-CommitStageSection -RelativePath $Path -Heading '## Contract Tests That Pin Mirrored Files'
        $names = @('documentation-workflow.CommitStage.Tests.ps1', 'pr-author-docs-estate-delegation-contract.Tests.ps1', 'hook-docs-estate-context.Parity.Tests.ps1', 'hook-docs-only-diff.InitWorkflowParity.Tests.ps1')

        # Assert
        $null -eq $section | Should -BeFalse
        foreach ($name in $names) { $section.Contains($name, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the brief lists $name" }
    }
}
