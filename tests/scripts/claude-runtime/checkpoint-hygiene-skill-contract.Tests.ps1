#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the checkpoint-hygiene and delegation-identity skill rules (#673).

.DESCRIPTION
    Issue #673 anchors each gate's checkpoint read to the worktree identity resolution
    selects, which removes the mechanism by which a foreign checkpoint at a session root
    could produce an allow. Three other gates still read a process-directory-relative
    checkpoint and are out of scope for that change, so hygiene continues to matter for
    them: a coordinating session must not leave a per-feature checkpoint at its own root.

    That rule lives in prose, in three orchestration skills. Prose can be deleted without
    any test noticing, so these rows assert each statement is present. They read the skill
    text with whitespace collapsed, so a reflow cannot break an assertion, and extract the
    owning section by heading, so a statement placed under the wrong heading fails.

    The delegation-identity rows guard the other half: the gates can only identify an item
    if the delegation prompt carries the canonical issue line and a branch label. One row
    compares the skill's list of receipt-gated subagent types against the gate's own
    Get-ModelRoutingGatedAgent, so the two cannot drift apart silently.

.NOTES
    Assertions on a token containing a backtick use String.Contains rather than -BeLike.
    A backtick is an escape character inside a wildcard pattern, so such a token matches
    nothing even when the text carries it verbatim, and the row would fail while the rule
    it guards was correctly stated.

    Reads committed text only. No test creates a file, spawns a process, reads a wall
    clock, or touches the network.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:OrchestrateSkill = Join-Path $script:RepoRoot '.claude/skills/orchestrate/SKILL.md'
    $script:ParallelSkill = Join-Path $script:RepoRoot '.claude/skills/parallel-orchestrate/SKILL.md'
    $script:EpicSkill = Join-Path $script:RepoRoot '.claude/skills/epic-orchestrate/SKILL.md'
    # Issue #663: the epic-level issue promotion and integration-PR checkpoint contracts.
    $script:EpicPlanSkill = Join-Path $script:RepoRoot '.claude/skills/epic-plan/SKILL.md'
    $script:EpicPlannerAgent = Join-Path $script:RepoRoot '.claude/agents/epic-planner.md'
    $script:EpicOrchestratorAgent = Join-Path $script:RepoRoot '.claude/agents/epic-orchestrator.md'

    # The model-routing gate is dot-sourced so its gated-agent list is read from the gate
    # itself rather than restated here, which is what makes the drift row meaningful.
    . (Join-Path $script:RepoRoot '.claude/hooks/enforce-model-routing-receipt.ps1')

    # Return one section of a Markdown file, from its heading to the next heading of the
    # same or a shallower level, with all runs of whitespace collapsed to single spaces so
    # a reflow of the prose cannot break a token assertion.
    function Get-SkillSection {
        param(
            [Parameter(Mandatory)] [string] $Path,
            [Parameter(Mandatory)] [string] $Heading
        )
        $lines = @(Get-Content -LiteralPath $Path)
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return '' }
        $depth = ($Heading -split ' ')[0].Length
        $collected = [System.Collections.Generic.List[string]]::new()
        # Walk forward from the heading until a heading of equal or shallower depth ends the
        # section; everything between is the section body.
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($line -match '^(#{1,6})\s') {
                if ($Matches[1].Length -le $depth) { break }
            }
            $collected.Add($line)
        }
        return (($collected -join ' ') -replace '\s+', ' ').Trim()
    }
}

Describe 'checkpoint hygiene and delegation identity skill contract' {
    It 'orchestrate skill archives a foreign per-feature checkpoint to the handoff folder' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## Checkpoint Handling'

        # Assert: the rule names the condition, the destination, and the alternative it rules
        # out, so a restatement that drops the archive step fails.
        $section | Should -Not -BeNullOrEmpty
        $section | Should -BeLike '*Checkpoint hygiene (issue #673)*'
        # Containment rather than -BeLike: a backtick is an escape character inside a
        # wildcard pattern, so a token carrying one silently never matches.
        $section.Contains('records an `issue-num` other than the item this invocation is about') | Should -BeTrue
        $section | Should -BeLike '*artifacts/orchestration/handoff/orchestrator-state.issue-*'
        $section | Should -BeLike '*rather than overwriting it or leaving it in place*'
        $section | Should -BeLike '*hands an item whose checkpoint it holds to another session or worktree*'
    }

    It 'parallel-orchestrate skill keeps the coordinator root free of a per-feature checkpoint' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:ParallelSkill -Heading '## Per-Item Branch and Worktree Lifecycle'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section | Should -BeLike '*Checkpoint hygiene (issue #673)*'
        $section | Should -BeLike '*never holds a per-feature checkpoint at its own root*'
        $section | Should -BeLike '*artifacts/orchestration/handoff/orchestrator-state.issue-*'
        $section | Should -BeLike '*resolved by the item*s issue number and branch, never by the coordinator root*'
    }

    It 'epic-orchestrate skill keeps the coordinator root free of a per-feature checkpoint' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:EpicSkill -Heading '## Epic-Level Checkpoint'

        # Assert
        $section | Should -Not -BeNullOrEmpty
        $section | Should -BeLike '*Checkpoint hygiene (issue #673)*'
        $section | Should -BeLike '*never holds a per-feature checkpoint at its own root*'
        $section | Should -BeLike '*artifacts/orchestration/handoff/orchestrator-state.issue-*'
        $section | Should -BeLike '*before the first child delegation of a run*'
    }

    It 'orchestrate skill requires the canonical issue line on every receipt-gated delegation' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## Issue Number Consistency'

        # Assert: the requirement is stated over the receipt-gated set, not over a subset.
        $section | Should -Not -BeNullOrEmpty
        $section | Should -BeLike '*Every delegation prompt to a receipt-gated subagent type*'
        $section | Should -BeLike '*Canonical issue number for this feature is <issue_num>.*'
    }

    It 'orchestrate skill requires a branch label on every receipt-gated delegation' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## Issue Number Consistency'

        # Assert: the label, its placement rule, and the pre-promotion case are all stated.
        # Containment for both, because each token carries a backtick.
        $section.Contains('Each such prompt also carries a `branch: <name>` label') | Should -BeTrue
        $section.Contains('first `branch:` occurrence in the prompt') | Should -BeTrue
        $section | Should -BeLike '*Before promotion assigns an issue number, the branch label alone is required*'
    }

    It 'orchestrate skill names every subagent type the model-routing gate receipt-gates' {
        # Arrange: the gate's own list, read from the dot-sourced gate.
        $gated = @(Get-ModelRoutingGatedAgent)
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## Issue Number Consistency'

        # Act / Assert: every name the gate gates is named in the rule, so the skill cannot
        # fall behind the gate without this row failing.
        $gated.Count | Should -BeGreaterThan 0
        foreach ($agent in $gated) {
            $section | Should -BeLike ("*{0}*" -f $agent) -Because "$agent is receipt-gated and must be named in the rule"
        }
    }

    It 'orchestrate skill names both gates that identify the item from the delegation prompt' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:OrchestrateSkill -Heading '## Issue Number Consistency'

        # Assert: both identity-resolving gates are named, because after the prd-feature
        # migration an atomic-planner delegation is read for identity by both of them.
        $section | Should -BeLike '*enforce-model-routing-receipt.ps1*'
        $section | Should -BeLike '*enforce-prd-feature-before-planner.ps1*'
    }

    It 'epic-plan skill promotes an epic-level issue and records epic_issue_num (issue #663)' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:EpicPlanSkill -Heading '## Epic-Level Issue Promotion'

        # Assert: the promotion route, its type, the recorded field, and the gated checkpoint.
        $section | Should -Not -BeNullOrEmpty
        $section | Should -BeLike '*mcp__drm-copilot__potential_to_issue*'
        $section | Should -BeLike '*promotion_type: epic*'
        $section | Should -BeLike '*epic_issue_num*'
        $section | Should -BeLike '*epic-orchestrator-state.json*'
    }

    It 'epic-planner agent lists the promotion tool and records epic_issue_num (issue #663)' {
        # Arrange: the frontmatter is every line before the second '---' delimiter.
        $lines = @(Get-Content -LiteralPath $script:EpicPlannerAgent)
        $delimiters = @(for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index] -eq '---') { $index } })
        $frontmatter = ($lines[0..($delimiters[1] - 1)] -join "`n")
        $section = Get-SkillSection -Path $script:EpicPlannerAgent -Heading '## Checkpoint Persistence'

        # Assert: containment for the tool entries, because '*' in a wildcard pattern is not literal.
        $frontmatter.Contains('"mcp__drm-copilot__potential_to_issue"') | Should -BeTrue
        $frontmatter.Contains('"Write(docs/features/potential/**)"') | Should -BeTrue
        $section | Should -BeLike '*epic_issue_num*'
        $section | Should -BeLike '*promotion_type: epic*'
    }

    It 'epic-orchestrate skill states the integration-PR checkpoint shape and receipt location (issue #663)' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:EpicSkill -Heading '## Epic-Level Checkpoint'

        # Assert
        $section | Should -BeLike '*Integration-PR checkpoint shape (issue #663)*'
        $section | Should -BeLike '*no per-feature checkpoint is written for them*'
        $section | Should -BeLike '*epic_issue_num*'
        $section | Should -BeLike '*worktree_removed*'
        $section | Should -BeLike '*model_routing_receipts*'
        $section | Should -BeLike '*pr-author*'
        $section | Should -BeLike '*route_id: "epic"*'
    }

    It 'epic-orchestrator agent lists epic_issue_num and model_routing_receipts in its checkpoint fields (issue #663)' {
        # Arrange / Act
        $section = Get-SkillSection -Path $script:EpicOrchestratorAgent -Heading '## Checkpoint Persistence'

        # Assert
        $section | Should -BeLike '*epic_issue_num*'
        $section | Should -BeLike '*model_routing_receipts*'
    }
}
