#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Wording contract for the planner worktree-removal records and gate documentation (issue #1161, R7).

.DESCRIPTION
    Each row extracts one heading section, paragraph, or gate .DESCRIPTION help text from a committed
    file, collapses its whitespace, and requires the tokens the plan names, so a reflowed line still
    matches. The files are read in place; no file is written. Test files are not pushed down, so this
    suite has no mirror.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path

    function Get-ContractFileText {
        # The committed text of one repository file.
        param([Parameter(Mandatory)][string] $RelativePath)
        return Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot $RelativePath)
    }

    function ConvertTo-ContractCollapsed {
        # Collapse every whitespace run to one space.
        param([AllowEmptyString()][string] $Text)
        return ([regex]::Replace($Text, '\s+', ' ')).Trim()
    }

    function Get-ContractSection {
        # The body of the heading named exactly, up to the next heading of the same or a higher level.
        param([Parameter(Mandatory)][string] $Text, [Parameter(Mandatory)][string] $Heading)
        $level = ($Heading -split ' ')[0].Length
        $lines = $Text -split "`r?`n"
        $start = [Array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return $null }
        $body = [System.Collections.Generic.List[string]]::new()
        for ($i = $start + 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^(#{1,6}) ' -and $Matches[1].Length -le $level) { break }
            $body.Add($lines[$i])
        }
        return ConvertTo-ContractCollapsed -Text ($body -join "`n")
    }

    function Get-ContractParagraph {
        # The paragraph that begins with the given text, up to the next blank line.
        param([Parameter(Mandatory)][string] $Text, [Parameter(Mandatory)][string] $Start)
        $lines = $Text -split "`r?`n"
        $index = -1
        for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].StartsWith($Start)) { $index = $i; break } }
        if ($index -lt 0) { return $null }
        $body = [System.Collections.Generic.List[string]]::new()
        for ($i = $index; $i -lt $lines.Count -and $lines[$i].Trim() -ne ''; $i++) { $body.Add($lines[$i]) }
        return ConvertTo-ContractCollapsed -Text ($body -join "`n")
    }

    function Get-ContractHelpDescription {
        # The .DESCRIPTION help text of a script, from its parsed comment-based help.
        param([Parameter(Mandatory)][string] $RelativePath)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:RepoRoot $RelativePath), [ref] $tokens, [ref] $errors)
        $help = $ast.GetHelpContent()
        if ($null -eq $help) { return $null }
        return ConvertTo-ContractCollapsed -Text $help.Description
    }

    $script:PlannerCodes = @('PLANNER_WORKTREE_NOT_ELIGIBLE', 'PLANNER_WORKTREE_DIRTY', 'PLANNER_WORKTREE_NOT_PUSHED', 'PLANNER_WORKTREE_IN_USE', 'PLANNER_WORKTREE_AMBIGUOUS', 'PLANNER_WORKTREE_GIT_FAILED')
}

Describe 'planner worktree-removal wording contract (issue #1161)' {
    Context 'epic-plan skill: Preparation Worktree Records (P3-T1)' {
        It '<File> carries the recording protocol tokens' -ForEach @(
            @{ File = '.claude/skills/epic-plan/SKILL.md' }
            @{ File = '.agents/skills/epic-plan/SKILL.md' }
        ) {
            $section = Get-ContractSection -Text (Get-ContractFileText -RelativePath $File) -Heading '## Preparation Worktree Records'
            $section | Should -Not -BeNullOrEmpty
            foreach ($token in @('planner_worktrees', 'prepared', 'fanned_in', 'removed', 'git worktree remove', '--force', 'detach', 'repository-relative', 'absolute path', 'PLANNER_WORKTREE_', 'policy-level control', 'ignored files')) {
                $section.Contains($token) | Should -BeTrue -Because "$File ## Preparation Worktree Records must name '$token'"
            }
        }
        It '<File> points its <Heading> section to the records section' -ForEach @(
            @{ File = '.claude/skills/epic-plan/SKILL.md'; Heading = '## Fan-In to the Integration Branch' }
            @{ File = '.agents/skills/epic-plan/SKILL.md'; Heading = '## Fan-In' }
        ) {
            $section = Get-ContractSection -Text (Get-ContractFileText -RelativePath $File) -Heading $Heading
            $section.Contains('Preparation Worktree Records') | Should -BeTrue
        }
    }

    Context 'epic-planner agents: checkpoint field list (P3-T2)' {
        It '<File> lists planner_worktrees and its fields in <Heading>' -ForEach @(
            @{ File = '.claude/agents/epic-planner.md'; Heading = '## Checkpoint Persistence' }
            @{ File = '.codex/agents/epic-planner.toml'; Heading = '## Checkpoint' }
        ) {
            $section = Get-ContractSection -Text (Get-ContractFileText -RelativePath $File) -Heading $Heading
            $section | Should -Not -BeNullOrEmpty
            foreach ($token in @('planner_worktrees', 'branch', 'path', 'purpose', 'preparation_status', 'feature_folder', 'recorded_at', 'absolute path')) {
                $section.Contains($token) | Should -BeTrue -Because "$File $Heading must name '$token'"
            }
        }
    }

    Context 'parallel surfaces and gate help (P3-T3)' {
        It 'names the planner branch in the Worktree removal gate paragraph of the parallel-orchestrate skill' {
            $paragraph = Get-ContractParagraph -Text (Get-ContractFileText -RelativePath '.claude/skills/parallel-orchestrate/SKILL.md') -Start '**Worktree removal gate.**'
            $paragraph.Contains('planner_worktrees') | Should -BeTrue
        }
        It 'names the planner branch in the Enforcement section of the parallel-orchestration rule' {
            $section = Get-ContractSection -Text (Get-ContractFileText -RelativePath '.claude/rules/parallel-orchestration.md') -Heading '## Enforcement'
            $section.Contains('planner_worktrees') | Should -BeTrue
        }
        It '<File> documents the planner branch in its .DESCRIPTION help' -ForEach @(
            @{ File = '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'; Cascade = 'before the manifest branch' }
            @{ File = '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'; Cascade = 'before the manifest branch' }
            @{ File = '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'; Cascade = 'after the epic check' }
        ) {
            $description = Get-ContractHelpDescription -RelativePath $File
            $description | Should -Not -BeNullOrEmpty
            foreach ($token in @('planner_worktrees', 'epic-planner-state.json', 'policy-level control', $Cascade) + $script:PlannerCodes) {
                $description.Contains($token) | Should -BeTrue -Because "$File .DESCRIPTION must name '$token'"
            }
        }
    }
}
