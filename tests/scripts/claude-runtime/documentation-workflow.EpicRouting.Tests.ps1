#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    The epic-scale routing section of the documentation-workflow skill in all four copies, the
    matching behavior in its standard, and the brief listing of this suite (issue #1223).

.DESCRIPTION
    Each row reads one committed copy, takes the text of one level-two section (from its heading to
    the next level-two heading), collapses whitespace runs to one space, and checks ordinal tokens.
    Wave segments run from the first ordinal occurrence of a wave marker to the next marker or the
    end of the section. The page threshold is defined once, in DefaultPageThreshold. No row writes a
    file, reads a clock, or starts a process.
#>

BeforeDiscovery {
    $script:SkillCopyRows = @(
        @{ Path = '.claude/skills/documentation-workflow/SKILL.md' }
        @{ Path = '.agents/skills/documentation-workflow/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/documentation-workflow/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/documentation-workflow/SKILL.md' }
    )
    $script:StandardCopyRows = @(
        @{ Path = '.agents/skills/documentation-workflow/references/standard.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/documentation-workflow/references/standard.md' }
    )
    $script:BriefCopyRows = @(
        @{ Path = '.claude/skills/execution-environment/SKILL.md' }
        @{ Path = '.agents/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:DefaultPageThreshold = 40
    $script:RoutingHeading = '## Epic-Scale Routing'
    $script:SourceStandardPath = '.agents/skills/documentation-workflow/references/standard.md'

    function Get-EpicRoutingSection {
        # Pure over the committed text: the normalized body of one level-two section, or $null.
        param([Parameter(Mandatory)] [string] $RelativePath, [Parameter(Mandatory)] [string] $Heading)
        $text = (Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n"
        $match = [regex]::Match($text, '(?ms)^' + [regex]::Escape($Heading) + '[ \t]*\n(?<body>.*?)(?=^## |\z)')
        if (-not $match.Success) { return $null }
        return ($match.Groups['body'].Value -replace '\s+', ' ')
    }

    function Get-EpicRoutingHeadingIndex {
        param([Parameter(Mandatory)] [string] $RelativePath, [Parameter(Mandatory)] [string] $Heading)
        $lines = @((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -split "`r?`n")
        return [array]::IndexOf([string[]]$lines, $Heading)
    }

    function Get-EpicRoutingHeadingCount {
        param([Parameter(Mandatory)] [string] $RelativePath, [Parameter(Mandatory)] [string] $Heading)
        $lines = @((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -split "`r?`n")
        return @($lines | Where-Object { $_ -ceq $Heading }).Count
    }

    function Get-EpicRoutingText {
        param([Parameter(Mandatory)] [string] $RelativePath)
        return ((Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n")
    }
}

AfterAll {
    foreach ($name in 'Get-EpicRoutingSection', 'Get-EpicRoutingHeadingIndex', 'Get-EpicRoutingHeadingCount', 'Get-EpicRoutingText') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation-workflow epic-scale routing (issue #1223)' {
    It 'places ## Epic-Scale Routing once, after ## Rules and before ## Commit, Receipt and Pull Request in <Path>' -ForEach $script:SkillCopyRows {
        # Act
        $count = Get-EpicRoutingHeadingCount -RelativePath $Path -Heading $script:RoutingHeading
        $rules = Get-EpicRoutingHeadingIndex -RelativePath $Path -Heading '## Rules'
        $routing = Get-EpicRoutingHeadingIndex -RelativePath $Path -Heading $script:RoutingHeading
        $stage = Get-EpicRoutingHeadingIndex -RelativePath $Path -Heading '## Commit, Receipt and Pull Request'

        # Assert
        $count | Should -Be 1 -Because 'the section is present exactly once'
        $rules | Should -BeGreaterThan -1
        $routing | Should -BeGreaterThan $rules
        $routing | Should -BeLessThan $stage
    }

    It 'states the routing condition and the page threshold in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading $script:RoutingHeading
        $tokens = @('first full estate', "more than $($script:DefaultPageThreshold) planned pages", 'epic-plan', 'main session', 'single-run route', 'epic-worthiness', 'recorded decision')

        # Assert
        $null -eq $section | Should -BeFalse -Because 'the section exists'
        foreach ($token in $tokens) { $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the section states '$token'" }
    }

    It 'lists the waves in order with each family id in its own wave segment in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading $script:RoutingHeading
        $waves = [ordered]@{
            'Wave 0' = @()
            'Wave 1' = @('architecture', 'adr', 'reference', 'product-overview', 'getting-started')
            'Wave 2' = @('user-guides', 'administration', 'security')
            'Wave 3' = @('operations', 'service-management')
        }
        $markers = @($waves.Keys)

        # Act
        $null -eq $section | Should -BeFalse -Because 'the section exists'
        $starts = @($markers | ForEach-Object { $section.IndexOf($_, [System.StringComparison]::Ordinal) })

        # Assert
        $starts | Should -Not -Contain -1
        $starts | Should -Be @($starts | Sort-Object) -Because 'the wave markers appear in order'
        for ($i = 0; $i -lt $markers.Count; $i++) {
            $end = if ($i + 1 -lt $markers.Count) { $starts[$i + 1] } else { $section.Length }
            $segment = $section.Substring($starts[$i], $end - $starts[$i])
            foreach ($id in $waves[$markers[$i]]) {
                $token = ('`{0}`' -f $id)
                [regex]::Matches($section, [regex]::Escape($token)).Count | Should -Be 1 -Because "$token appears once in the section"
                $segment.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "$token belongs to $($markers[$i])"
            }
        }
        $foundation = $section.Substring($starts[0], $starts[1] - $starts[0])
        foreach ($id in @($waves.Values | ForEach-Object { $_ })) {
            $foundation.Contains(('`{0}`' -f $id), [System.StringComparison]::Ordinal) | Should -BeFalse -Because 'the foundation wave owns no family id'
        }
    }

    It 'states ownership and omits family-record field names in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading $script:RoutingHeading
        $fields = @('required_families', 'diataxis_mode', 'review_interval_days', 'audience', 'exclusion', 'legacy_exclusions')

        # Assert
        $null -eq $section | Should -BeFalse -Because 'the section exists'
        $section.Contains('docs-family-profile-model', [System.StringComparison]::Ordinal) | Should -BeTrue
        $section.Contains('authoritative', [System.StringComparison]::Ordinal) | Should -BeTrue
        foreach ($field in $fields) { $section.Contains($field, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "the section does not restate the field '$field'" }
    }

    It 'states the dispatch rule in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading $script:RoutingHeading

        # Assert
        $null -eq $section | Should -BeFalse -Because 'the section exists'
        foreach ($token in 'for its families only', 'docs-init', 'root inventory step', 'foundation child') {
            $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the section states '$token'"
        }
    }

    It 'states the receipt rule in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading $script:RoutingHeading
        $tokens = @('integration branch', 'at its head', 'final integration step', 'before the integration pull request', 'no wave child', 'docs-family-gate-and-ia')

        # Assert
        $null -eq $section | Should -BeFalse -Because 'the section exists'
        foreach ($token in $tokens) { $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the section states '$token'" }
    }

    It 'qualifies the single-run statements in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $when = Get-EpicRoutingSection -RelativePath $Path -Heading '## When to Use This Skill'
        $stage = Get-EpicRoutingSection -RelativePath $Path -Heading '## Commit, Receipt and Pull Request'
        $refresh = Get-EpicRoutingSection -RelativePath $Path -Heading '## Refresh After Rebase or Source Change'

        # Assert
        $null -eq $when | Should -BeFalse
        $null -eq $stage | Should -BeFalse
        $null -eq $refresh | Should -BeFalse
        $when.Contains('epic-plan', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the first section names epic-plan for the estate route'
        foreach ($token in 'single-run route', 'orchestrator pull request stages', 'checkpoint-free single run', 'SECURITY.md', 'CODEOWNERS') {
            $stage.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the stage section states '$token'"
        }
        foreach ($token in 'integration branch', 'before the final receipt') {
            $refresh.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the refresh section states '$token'"
        }
    }

    It 'states the epic standard behavior in <Path>' -ForEach $script:StandardCopyRows {
        # Arrange
        $text = Get-EpicRoutingText -RelativePath $Path
        $source = Get-EpicRoutingText -RelativePath $script:SourceStandardPath

        # Assert
        foreach ($token in '**OB-6**', '**AC-7** (OB-6)', '(OB-1, OB-2, OB-3, OB-4, OB-5, OB-6)') {
            $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the standard states '$token'"
        }
        ($text -ceq $source) | Should -BeTrue -Because 'the copy is byte-identical to the source'
    }
}

Describe 'execution-environment brief listing of the epic routing suite (issue #1223)' {
    It 'lists this suite in ## Contract Tests That Pin Mirrored Files of <Path>' -ForEach $script:BriefCopyRows {
        # Arrange
        $section = Get-EpicRoutingSection -RelativePath $Path -Heading '## Contract Tests That Pin Mirrored Files'

        # Assert
        $null -eq $section | Should -BeFalse
        $section.Contains('documentation-workflow.EpicRouting.Tests.ps1', [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the brief lists the suite'
    }
}
