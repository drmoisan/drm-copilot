#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Text contract for the early dependent starts of issue #1097 in the epic skills and agents.

.DESCRIPTION
    Reads the `## Early Dependent Starts (early_start)` section of both epic-orchestrate skills
    and their bundle copies, the closing pointer of both epic-run skills, and the exception text
    of the epic-orchestrator agent and its Codex twin, each with whitespace collapsed, and checks
    the opt-in, the procedure order, the sync, the writers, both messages, the fallback, and the
    runtime differences. Every row runs over the source and its bundle copy. The files are read
    read-only; no file is written and no process is started.
#>

BeforeDiscovery {
    $claudeBundle = 'extensions/drm-copilot/resources/claude-customizations'
    $codexBundle = 'extensions/drm-copilot/resources/codex-and-agents-customizations'
    $script:ClaudeSkill = @(
        @{ Path = '.claude/skills/epic-orchestrate/SKILL.md' }
        @{ Path = "$claudeBundle/.claude/skills/epic-orchestrate/SKILL.md" }
    )
    $script:CodexSkill = @(
        @{ Path = '.agents/skills/epic-orchestrate/SKILL.md' }
        @{ Path = "$codexBundle/.agents/skills/epic-orchestrate/SKILL.md" }
    )
    $script:AnySkill = $script:ClaudeSkill + $script:CodexSkill
    $script:RunSkill = @(
        @{ Path = '.claude/skills/epic-run/SKILL.md' }
        @{ Path = "$claudeBundle/.claude/skills/epic-run/SKILL.md" }
        @{ Path = '.agents/skills/epic-run/SKILL.md' }
        @{ Path = "$codexBundle/.agents/skills/epic-run/SKILL.md" }
    )
    $script:AgentFile = @(
        @{ Path = '.claude/agents/epic-orchestrator.md' }
        @{ Path = "$claudeBundle/.claude/agents/epic-orchestrator.md" }
        @{ Path = '.codex/agents/epic-orchestrator.toml' }
        @{ Path = "$codexBundle/.codex/agents/epic-orchestrator.toml" }
    )
}

Describe 'early-start skill contract (issue #1097)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:Heading = '## Early Dependent Starts (early_start)'

        function Get-EarlyStartFileText {
            # The whitespace-collapsed text of one repository file.
            param([string] $RelativePath)
            $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw
            return (($text -replace '\s+', ' ').Trim())
        }

        function Get-EarlyStartMissingToken {
            # The tokens, in order, that do not occur (ordinal) in the text after the token before them.
            param([string] $Text, [string[]] $Token)
            $from = 0
            foreach ($item in $Token) {
                $at = $Text.IndexOf($item, $from, [System.StringComparison]::Ordinal)
                if ($at -lt 0) { $item } else { $from = $at + $item.Length }
            }
        }

        function Get-EarlyStartSection {
            # The whitespace-collapsed body of the early-start section, or an empty string.
            param([string] $RelativePath)
            $text = (Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw) -replace "`r`n", "`n"
            $start = $text.IndexOf("`n$script:Heading`n", [System.StringComparison]::Ordinal)
            if ($start -lt 0) { return '' }
            $end = $text.IndexOf("`n## ", $start + 1, [System.StringComparison]::Ordinal)
            $body = if ($end -lt 0) { $text.Substring($start) } else { $text.Substring($start, $end - $start) }
            return (($body -replace '\s+', ' ').Trim())
        }
    }

    It 'ESS-SECTION-STATES-NO-FIELD-MEANS-UNCHANGED in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('Without that field this section does not apply, and every other section of this skill governs unchanged.')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-NAMES-OPT-IN-FIELD in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('`early_start_on: <upstream issue_num>`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('must be one of its `depends_on` values')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-SYNC-IS-A-MERGE in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('`git merge --no-ff origin/<integration_branch>`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('The sync is a merge, not a rebase.')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-ORDERS-THE-PROCEDURE in <Path>' -ForEach $script:AnySkill {
        # Arrange
        $section = Get-EarlyStartSection -RelativePath $Path
        $steps = @('1. Parent:', '2. Parent:', '3. Parent:', '4. Child:', '5. Child:', '6. Child:', '7. Child:', '8. Child:', '9. Parent:', '10. Parent:')

        # Act: find each step after the one before it.
        $positions = [System.Collections.Generic.List[int]]::new()
        $from = 0
        foreach ($step in $steps) {
            $at = $section.IndexOf(" $step", $from, [System.StringComparison]::Ordinal)
            $positions.Add($at)
            if ($at -ge 0) { $from = $at + 1 }
        }

        # Assert
        $positions | Should -Not -Contain -1
    }

    It 'ESS-SECTION-SYNC-PRECEDES-REVIEW in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('before S7 and S8')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('record `early_start_synced_at`, and only then start S7 or S8')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-STOPS-ON-INTERFACE-CHANGE in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('`git diff --name-only <Upstream-Head> <merge commit> -- <Interface-Paths>`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('`blocked_reason: "premise_falsified"`')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-NAMES-WRITERS in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('`features[].early_start`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('`early_start_synced_at`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('`early_start.synced_at`')) | Should -BeNullOrEmpty
        @(Get-EarlyStartMissingToken -Text $section -Token @('interface-settled.<timestamp>.md')) | Should -BeNullOrEmpty
    }

    It 'ESS-SECTION-STATES-BOTH-MESSAGES in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        $section.Contains('EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later while early_start dependency <d> is not merged', [System.StringComparison]::Ordinal) | Should -BeTrue
        $section.Contains('EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later without a string synced_at for early_start dependency <d>', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'ESS-SECTION-STATES-FALLBACK in <Path>' -ForEach $script:AnySkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('remove the three values and keep the barrier')) | Should -BeNullOrEmpty
    }

    It 'ESS-CLAUDE-NAMES-PYTHON-CLI-ROUTE in <Path>' -ForEach $script:ClaudeSkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @(
                'the repository CLI `scripts.dev_tools.validate_orchestration_artifacts` with its `epic-orchestrator-state` subcommand'
                'When the repository CLI is absent or does not run (a destination repository without `scripts/dev_tools/`), the parent likewise removes the three values and keeps the barrier.'
            )) | Should -BeNullOrEmpty
    }

    It 'ESS-CODEX-STATES-UNAVAILABLE-UNTIL-RELEASE in <Path>' -ForEach $script:CodexSkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('The early start is therefore unavailable on Codex until that release is installed.')) | Should -BeNullOrEmpty
    }

    It 'ESS-CODEX-STATES-WHOLE-WAVE-RULE in <Path>' -ForEach $script:CodexSkill {
        $section = Get-EarlyStartSection -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $section -Token @('`Test-CodexChildLaunchSpec`', 'every non-terminal feature of its wave')) | Should -BeNullOrEmpty
    }

    It 'ESS-RUN-POINTS-TO-SECTION in <Path>' -ForEach $script:RunSkill {
        $text = Get-EarlyStartFileText -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $text -Token @('`early_start_on`', '`## Early Dependent Starts (early_start)` of the `epic-orchestrate` skill')) | Should -BeNullOrEmpty
    }

    It 'ESS-AGENT-NAMES-THE-EXCEPTION in <Path>' -ForEach $script:AgentFile {
        $text = Get-EarlyStartFileText -RelativePath $Path
        @(Get-EarlyStartMissingToken -Text $text -Token @('Exception', '`early_start_on`', '`## Early Dependent Starts (early_start)`')) | Should -BeNullOrEmpty
    }

    It 'ESS-KICKOFF-LITERAL-INTACT in <Path>' -ForEach $script:AnySkill {
        # Arrange
        $text = Get-EarlyStartFileText -RelativePath $Path
        $literal = '`Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json.'

        # Act
        $count = ([regex]::Matches($text, [regex]::Escape($literal))).Count

        # Assert
        $count | Should -Be 1
    }
}
