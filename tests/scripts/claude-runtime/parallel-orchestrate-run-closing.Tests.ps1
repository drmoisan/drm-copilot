#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Content checks for the Run Closing procedure of the parallel-orchestrate skill and the
    parallel-orchestrator agent, and their bundle copies (issue #995).

.DESCRIPTION
    For each skill copy, the ### Run Closing section (up to the next heading of level three
    or higher) must name every closing-step token, and ## Completion Requirements must name
    Run Closing. Every backticked git add or git commit span in the skill section must stage
    or commit only literal paths under docs/features/; the only
    permitted git add -A or git add . spans are those inside a sentence that opens a
    prohibition with the word Never.

    For each agent copy, the frontmatter tools: list must grant Agent(pr-author), the body
    must carry ### Run Closing with the same tokens, and ## Completion Requirements must
    name Run Closing.

    The suite reads committed repository files only. It creates or writes no file, reads no
    wall clock, starts no process, and touches no network.
#>

BeforeDiscovery {
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $bundle = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/.claude'
    $script:SkillCopies = @(
        @{ Copy = 'repository'; Path = (Join-Path $repoRoot '.claude/skills/parallel-orchestrate/SKILL.md') }
        @{ Copy = 'bundle'; Path = (Join-Path $bundle 'skills/parallel-orchestrate/SKILL.md') }
    )
    $script:AgentCopies = @(
        @{ Copy = 'repository'; Path = (Join-Path $repoRoot '.claude/agents/parallel-orchestrator.md') }
        @{ Copy = 'bundle'; Path = (Join-Path $bundle 'agents/parallel-orchestrator.md') }
    )
}

BeforeAll {
    $script:AllowedPathPrefixes = @('docs/features/')

    # The staging sentence names the removed artifacts/orchestration/ alternative (issue #995).
    $script:RemovedAlternativePattern = 'or\s+`artifacts/orchestration/`'

    # The text of one heading's section, up to the next heading of the same or a higher
    # level, or $null when the heading is absent.
    function Get-MarkdownSection {
        param([string] $Text, [string] $Heading)
        $lines = $Text -split "\r?\n"
        $level = ($Heading -split ' ')[0].Length
        $start = -1
        for ($index = 0; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -ceq $Heading) { $start = $index; break }
        }
        if ($start -lt 0) { return $null }
        $end = $lines.Count
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match ('^#{1,' + $level + '} ')) { $end = $index; break }
        }
        return ($lines[$start..($end - 1)] -join "`n")
    }

    # The tools: entries of a Markdown file's YAML frontmatter, unquoted.
    function Get-FrontmatterTool {
        param([string] $Text)
        $lines = $Text -split "\r?\n"
        $tools = [System.Collections.Generic.List[string]]::new()
        $inTools = $false
        for ($index = 1; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($line -eq '---') { break }
            if ($line -match '^tools:\s*$') { $inTools = $true; continue }
            if ($inTools -and $line -match '^\s+-\s+(?<entry>.+)$') { $tools.Add($Matches['entry'].Trim().Trim('"').Trim("'")); continue }
            if ($inTools -and $line -match '^\S') { $inTools = $false }
        }
        return $tools.ToArray()
    }

    # The pathspec and option violations of one git add or git commit span.
    function Get-StagingSpanViolation {
        param([string] $Span)
        $tokens = @([regex]::Matches($Span, '"[^"]*"|''[^'']*''|\S+') | ForEach-Object { $_.Value })
        $violations = [System.Collections.Generic.List[string]]::new()
        $pathspecs = [System.Collections.Generic.List[string]]::new()
        $afterSeparator = $false
        $skipNext = $false
        $arguments = if ($tokens.Count -gt 2) { @($tokens[2..($tokens.Count - 1)]) } else { @() }
        foreach ($token in $arguments) {
            if ($skipNext) { $skipNext = $false; continue }
            if ($afterSeparator) { $pathspecs.Add($token); continue }
            if ($token -eq '--') { $afterSeparator = $true; continue }
            if (@('-A', '--all') -ccontains $token) { $violations.Add("option $token"); continue }
            if (@('-m', '-F', '--message', '--file') -ccontains $token) { $skipNext = $true; continue }
            if ($token.StartsWith('-')) { continue }
            $pathspecs.Add($token)
        }
        foreach ($pathspec in $pathspecs) {
            $allowed = @($script:AllowedPathPrefixes | Where-Object { $pathspec.StartsWith($_, [System.StringComparison]::Ordinal) })
            if ($pathspec -eq '.' -or $allowed.Count -eq 0) { $violations.Add("pathspec $pathspec") }
        }
        return $violations.ToArray()
    }
}

Describe 'parallel-orchestrate skill Run Closing (<Copy> copy)' -ForEach $script:SkillCopies {
    BeforeAll {
        $script:Text = Get-Content -LiteralPath $Path -Raw
        $script:Section = Get-MarkdownSection -Text $script:Text -Heading '### Run Closing'
    }

    It 'RC1 carries a ### Run Closing section' {
        $script:Section | Should -Not -BeNullOrEmpty
    }

    It 'RC2 names <_> in the Run Closing section' -ForEach @(
        'git worktree list --porcelain', 'git worktree unlock', 'git worktree remove', 'worktree_removed_at',
        'completed_steps', 'parallel-status.md', 'Agent(pr-author)', 'branch:', 'gh pr merge',
        'cleanup-merged-worktrees', 'deferral'
    ) {
        $script:Section.Contains($_) | Should -BeTrue -Because "the Run Closing section must name '$_'"
    }

    It 'RC3 references Run Closing from ## Completion Requirements' {
        $completion = Get-MarkdownSection -Text $script:Text -Heading '## Completion Requirements'
        $completion | Should -Not -BeNullOrEmpty
        $completion.Contains('Run Closing') | Should -BeTrue
    }

    It 'RC5 does not offer artifacts/orchestration/ as a staging pathspec alternative' {
        # Arrange: collapse whitespace so a wrapped sentence cannot hide the alternative.
        $collapsed = ($script:Section -replace '\s+', ' ')

        # Act / Assert
        $collapsed | Should -Not -Match $script:RemovedAlternativePattern -Because 'artifacts/ is gitignored and Run Closing never stages it'
    }

    It 'RC4 stages and commits only literal docs/features/ paths (AC-11)' {
        # Arrange
        $spans = @([regex]::Matches($script:Section, '`(?<span>git (add|commit)[^`]*)`') | ForEach-Object { $_.Groups['span'].Value })
        $sentences = @($script:Section -split '(?<=[.!?])\s+')
        $violations = [System.Collections.Generic.List[string]]::new()

        # Act
        foreach ($span in $spans) {
            if ($span -ceq 'git add -A' -or $span -ceq 'git add .') {
                $owner = @($sentences | Where-Object { $_.Contains('`' + $span + '`') })
                if (@($owner | Where-Object { $_ -cmatch '\bNever\b' }).Count -eq 0) { $violations.Add("'$span' outside a Never sentence") }
                continue
            }
            foreach ($violation in (Get-StagingSpanViolation -Span $span)) { $violations.Add("'$span': $violation") }
        }

        # Assert
        @($spans | Where-Object { $_ -like 'git add *' -and $_ -cne 'git add -A' -and $_ -cne 'git add .' }).Count | Should -BeGreaterThan 0 -Because 'the section must show the literal-path staging command'
        @($spans | Where-Object { $_ -like 'git commit *' }).Count | Should -BeGreaterThan 0 -Because 'the section must show the commit command'
        $violations | Should -BeNullOrEmpty -Because ($violations -join '; ')
    }
}

Describe 'parallel-orchestrator agent Run Closing (<Copy> copy)' -ForEach $script:AgentCopies {
    BeforeAll {
        $script:Text = Get-Content -LiteralPath $Path -Raw
        $script:Section = Get-MarkdownSection -Text $script:Text -Heading '### Run Closing'
    }

    It 'RA1 grants Agent(pr-author) in the frontmatter tools: list' {
        Get-FrontmatterTool -Text $script:Text | Should -Contain 'Agent(pr-author)'
    }

    It 'RA2 carries a ### Run Closing section' {
        $script:Section | Should -Not -BeNullOrEmpty
    }

    It 'RA3 names <_> in the Run Closing section' -ForEach @(
        'git worktree list --porcelain', 'git worktree unlock', 'git worktree remove', 'worktree_removed_at',
        'completed_steps', 'parallel-status.md', 'Agent(pr-author)', 'branch:', 'gh pr merge',
        'cleanup-merged-worktrees', 'deferral'
    ) {
        $script:Section.Contains($_) | Should -BeTrue -Because "the Run Closing section must name '$_'"
    }

    It 'RA4 references Run Closing from ## Completion Requirements' {
        $completion = Get-MarkdownSection -Text $script:Text -Heading '## Completion Requirements'
        $completion | Should -Not -BeNullOrEmpty
        $completion.Contains('Run Closing') | Should -BeTrue
    }

    It 'RA5 does not offer artifacts/orchestration/ as a staging pathspec alternative' {
        # Arrange: collapse whitespace so a wrapped sentence cannot hide the alternative.
        $collapsed = ($script:Section -replace '\s+', ' ')

        # Act / Assert
        $collapsed | Should -Not -Match $script:RemovedAlternativePattern -Because 'artifacts/ is gitignored and Run Closing never stages it'
    }
}
