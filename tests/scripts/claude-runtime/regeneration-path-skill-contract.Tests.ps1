#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the regenerate-path text of the skills, rule, agents, and brief (issue #1156).

.DESCRIPTION
    The regenerate path, its default-off boundary, and its attempt accounting live in prose, and
    prose can be deleted or moved without any other test noticing. Each row reads one .claude file
    and its bundle copy under extensions/drm-copilot/resources/claude-customizations/, extracts the
    owning scope from the raw text (a level-two section ends at the next level-two heading, a
    level-three subsection at the next heading of any level, a numbered item at the next column-0
    numbered start), collapses whitespace, and compares ordinally with String.Contains, because a
    backtick is an escape character inside a wildcard pattern.

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
#>

BeforeDiscovery {
    $bundle = 'extensions/drm-copilot/resources/claude-customizations/'
    $script:Surface = @(@{ Prefix = '' }, @{ Prefix = $bundle })

    $orchestrate = '.claude/skills/orchestrate/SKILL.md'
    $epic = '.claude/skills/epic-orchestrate/SKILL.md'
    $remediation = '## Merge-Conflict Remediation'
    $configRules = @(
        'version is the JSON integer 1', 'command is a non-empty array of non-empty strings',
        'paths is a non-empty array of path patterns', 'a paths entry with a backslash',
        'idempotency_check is a non-empty array of non-empty strings', 'unit_gate is a non-empty array of argv arrays',
        'any violation yields config_invalid', 'regeneration: null yields no_config'
    )

    $script:SectionRow = @(
        @{ Id = 'RSC-CONFIG'; File = $orchestrate; Heading = $remediation; Literal = $configRules + @("An absent file, an absent regeneration key, or regeneration: null yields no_config and today's behavior.") }
        @{ Id = 'RSC-INVOKE'; File = $orchestrate; Heading = $remediation; Literal = @('does not invoke the entry point', '-Mode Merge', '-MergeRef', '-Trigger integration_sync', '-Trigger main_sync', "config_errors are recorded under the checkpoint's artifact_errors", 'config/orchestration-regeneration.json') }
        @{ Id = 'RSC-CLASSIFY'; File = $orchestrate; Heading = $remediation; Literal = @('captures the conflicted-file list', 'all_match', 'unmatched_path', 'multiple_merge_bases', 'empty_set') }
        @{ Id = 'RSC-REGENERATE'; File = $orchestrate; Heading = $remediation; Literal = @(
                'runs the standard parallel unit gates when unit_gate is not_run', 'never edits an existing evidence file', 'evidence/qa-gates/regeneration-delta.',
                'Get-RegenerationEvidencePath', 'Get-RegenerationEvidencePath -FeatureFolder', 'git commit -F', 'pushes the merge commit', 'head_sha equal to the pushed head',
                're-runs S9 on the new head', 'regeneration_delta', 'a failure after the entry point exits runs git merge --abort',
                'returns head_sha null and evidence_path null in event and review_outcome', 'evidence_path to the Get-RegenerationEvidencePath value on both objects',
                'writes evidence_text as the evidence file content', 'appends the returned event with outcome fell_back, head_sha null, and evidence_path null',
                "When the entry point reports unit_gate not_run and the standard parallel gates pass, the orchestrator sets the event's unit_gate to pass before appending it.",
                'The evidence file keeps evidence_text unchanged, including unit_gate=not_run.') }
        @{ Id = 'RSC-FALLBACK'; File = $orchestrate; Heading = $remediation; Literal = @('appends a regeneration_events[] entry with outcome fell_back', "today's procedure runs unchanged from its first step") }
        @{ Id = 'RSC-ACCOUNTING'; File = $orchestrate; Heading = $remediation; Literal = @('consumes no remediation attempt', 'writes no remediation_loop.cycles[] entry', 'leaves completed_attempts unchanged on success or fallback') }
        @{ Id = 'RSC-TIP-DEFAULT-OFF'; File = $epic; Heading = '## Integration-Tip Regeneration'; Literal = @('the integration-tip flow runs only when the integration worktree holds a valid config/orchestration-regeneration.json', '-Mode Validate', 'a valid config is one for which Validate mode exits 0') }
        @{ Id = 'RSC-TIP'; File = $epic; Heading = '## Integration-Tip Regeneration'; Literal = @(
                'fetches and fast-forwards the integration worktree', '-Mode Tip', 'git add --', 'git commit -F', 'pushes the regeneration commit', 'gh workflow run CI --ref',
                'even when no regeneration commit was made', 'gh run list --commit', 'the epic orchestrator polls every 30 seconds for at most 90 minutes',
                'appends an integration_regenerations[] entry', 'does not merge another child and does not launch another wave until the integration tip has a successful completed CI run',
                'records outcome not_applied') }
        @{ Id = 'RSC-CHILD'; File = $epic; Heading = '## Integration-Tip Regeneration'; Literal = @('child-side check', 'the child runs Validate mode in its feature worktree', 'before merging the integration branch', 'the child polls every 30 seconds for at most 90 minutes', 'blocked_reason: "awaiting_ci"', 'Without a valid config the child does not wait') }
        @{ Id = 'RSC-PARALLEL'; File = '.claude/skills/parallel-orchestrate/SKILL.md'; Heading = '## Per-Item Merge-Conflict Handling'; Literal = @($remediation, 'issue #643 resolver escalates', 'applies the regenerate path of', 'only a fallback writes the synthetic Blocking finding and consumes an attempt') }
        @{ Id = 'RSC-RULES'; File = '.claude/rules/orchestrator-state.md'; Heading = '## Regeneration-Path Scope and Backward Compatibility'; Literal = $configRules + @(
                'config/orchestration-regeneration.json', 'regeneration_events[]', 'review_kind', 'evidence_path', 'integration_regenerations[]',
                'tolerated and unvalidated by the Python, TypeScript, and PowerShell validators', 'no REQUIRED_STATE_KEYS change', 'R7 holds by construction',
                'the portable handoff projection drops the new keys', 'Claude runtime only', 'REVIEW_GATE_REGENERATION_UNVERIFIED', 'Get-EpicRegenerationAllowance',
                'are policy-level controls, not security controls', "the review/verdict status names the last full review's audit file") }
        @{ Id = 'RSC-AGENT'; File = '.claude/agents/orchestrator.md'; Heading = '### Remediation Loop Checkpoint Shape'; Literal = @('writes no remediation_loop.cycles[] entry', 'leaves completed_attempts unchanged on success or fallback', 'regeneration_events[]', 'regeneration_delta review outcome') }
        @{ Id = 'RSC-BRIEF-HOOKS'; File = '.claude/skills/execution-environment/SKILL.md'; Heading = '## Hook Execution Context'; Literal = @('Get-EpicRegenerationAllowance', 'REVIEW_GATE_REGENERATION_UNVERIFIED') }
        @{ Id = 'RSC-BRIEF-CI'; File = '.claude/skills/execution-environment/SKILL.md'; Heading = '## CI Shape and Required Checks'; Literal = @('dispatches CI on the integration branch after each child merge') }
        @{ Id = 'RSC-BRIEF-CONTRACT'; File = '.claude/skills/execution-environment/SKILL.md'; Heading = '## Contract Tests That Pin Mirrored Files'; Literal = @('regeneration-path-skill-contract.Tests.ps1') }
    )

    $script:StartRow = @(
        @{ File = $orchestrate; Scope = 'item 2 of ## Merge-Conflict Remediation'; Kind = 'Item' }
        @{ File = '.claude/rules/orchestrator-state.md'; Scope = 'the Config rules paragraph of ## Regeneration-Path Scope and Backward Compatibility'; Kind = 'Paragraph' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:RemediationHeading = '## Merge-Conflict Remediation'
    $script:S9Heading = '## Step S9 ' + [char]0x2014 + ' CI Green Gate'
    $script:RemovedChildItemPhrase = @('dedicated chore child item', '`epic-852-main-sync`', 'PR into the integration branch', '`features[]`', "manifest child's issue number", 'one main-sync child')

    function Get-RscText {
        # Return the LF-normalized text of one repository file.
        param([Parameter(Mandatory)][string] $Path)
        return ((Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw) -replace "`r`n", "`n")
    }

    function Get-RscCollapsed {
        # Collapse every whitespace run to one space.
        param([AllowNull()][AllowEmptyString()][string] $Text)
        if ($null -eq $Text) { return $null }
        return ($Text -replace '\s+', ' ')
    }

    function Get-RscSection {
        # Return the raw text of a section: a level-two heading ends at the next level-two heading, a deeper heading at the next heading of any level; $null when absent.
        param([Parameter(Mandatory)][AllowEmptyString()][string] $Text, [Parameter(Mandatory)][string] $Heading)
        $lines = $Text -split "`n"
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return $null }
        $endPattern = if ($Heading.StartsWith('## ')) { '^## ' } else { '^#{1,6} ' }
        $end = $lines.Count
        for ($i = $start + 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -cmatch $endPattern) { $end = $i; break } }
        return ($lines[$start..($end - 1)] -join "`n")
    }

    function Get-RscNumberedItem {
        # Return the raw text of numbered item N of a section, from its column-0 start to the next column-0 numbered start; $null when absent.
        param([Parameter(Mandatory)][AllowEmptyString()][string] $Text, [Parameter(Mandatory)][int] $Number)
        $lines = $Text -split "`n"
        $start = -1
        for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -cmatch "^$Number\. ") { $start = $i; break } }
        if ($start -lt 0) { return $null }
        $end = $lines.Count
        for ($i = $start + 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -cmatch '^[0-9]+\. ') { $end = $i; break } }
        return ($lines[$start..($end - 1)] -join "`n")
    }

    function Get-RscNumberedStart {
        # Return the numbers of the column-0 numbered starts of a section, in order.
        param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
        return @(($Text -split "`n") | Where-Object { $_ -cmatch '^[0-9]+\. ' } | ForEach-Object { [int]($_ -replace '^([0-9]+)\. .*$', '$1') })
    }

    function Assert-RscLiteralPresent {
        # Assert every literal occurs ordinally in the collapsed scope text.
        param([AllowNull()][string] $Scope, [Parameter(Mandatory)][string[]] $Literal, [Parameter(Mandatory)][string] $Label)
        $Scope | Should -Not -BeNullOrEmpty -Because "$Label must exist"
        $collapsed = Get-RscCollapsed -Text $Scope
        foreach ($item in $Literal) { $collapsed.Contains($item) | Should -BeTrue -Because "$Label must contain: $item" }
    }
}

Describe 'regenerate-path skill contract (issue #1156)' {
    It '<Id> in <Prefix><File>' -ForEach @(foreach ($row in $script:SectionRow) { foreach ($surface in $script:Surface) { $row + @{ Prefix = $surface.Prefix } } }) {
        # Arrange
        $text = Get-RscText -Path ($Prefix + $File)

        # Act
        $scope = Get-RscSection -Text $text -Heading $Heading

        # Assert
        Assert-RscLiteralPresent -Scope $scope -Literal $Literal -Label "$Heading of $Prefix$File"
    }

    It 'states the start-time resolution and batch refusal in <Scope> of <Prefix><File>' -ForEach @(foreach ($row in $script:StartRow) { foreach ($surface in $script:Surface) { $row + @{ Prefix = $surface.Prefix } } }) {
        # Arrange
        $text = Get-RscText -Path ($Prefix + $File)
        $startLiteral = @(
            'resolves to an application through PATH (and PATHEXT on Windows)', 'runs through ComSpec /d /c',
            'a batch path holding a double quote or one of & | < > ^ %',
            'a batch argument holding whitespace, a double quote, or one of & | < > ^ % ( )', 'is refused before the start'
        )

        # Act
        if ($Kind -ceq 'Item') {
            $scopeText = Get-RscNumberedItem -Text (Get-RscSection -Text $text -Heading $script:RemediationHeading) -Number 2
        }
        else {
            $section = Get-RscSection -Text $text -Heading '## Regeneration-Path Scope and Backward Compatibility'
            $paragraph = @(($section -split "`n`n") | Where-Object { $_.Contains('Config rules,') })
            $paragraph.Count | Should -Be 1
            $scopeText = $paragraph[0]
        }
        $refusalCount = ([regex]::Matches((Get-RscCollapsed -Text $text), [regex]::Escape('is refused before the start'))).Count

        # Assert
        Assert-RscLiteralPresent -Scope $scopeText -Literal $startLiteral -Label "$Scope of $Prefix$File"
        $refusalCount | Should -Be 1
    }

    Context 'orchestrate skill structure in <Prefix>' -ForEach $script:Surface {
        BeforeAll {
            $script:OrchestrateText = Get-RscText -Path ($Prefix + '.claude/skills/orchestrate/SKILL.md')
        }

        It 'holds ## Merge-Conflict Remediation exactly once, after the S9 section, which still names it' {
            # Arrange
            $lines = $script:OrchestrateText -split "`n"

            # Act
            $headingIndex = @(for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -ceq $script:RemediationHeading) { $i } })
            $s9Index = [array]::IndexOf($lines, $script:S9Heading)
            $s9 = Get-RscSection -Text $script:OrchestrateText -Heading $script:S9Heading

            # Assert
            $headingIndex.Count | Should -Be 1
            $s9Index | Should -BeGreaterOrEqual 0
            $headingIndex[0] | Should -BeGreaterThan $s9Index
            (Get-RscCollapsed -Text $s9).Contains('Merge-Conflict Remediation') | Should -BeTrue
        }

        It 'states the delta-outcome rules inside items 7 and 11 of the concurrent-review section only' {
            # Arrange
            $section = Get-RscSection -Text $script:OrchestrateText -Heading '## Concurrent Review and CI (review_mode)'

            # Act
            $starts = Get-RscNumberedStart -Text $section
            $hits = @{ 'is the new review for the new head' = @(); 'applies to feature-review outcomes only' = @() }
            foreach ($number in $starts) {
                $item = Get-RscCollapsed -Text (Get-RscNumberedItem -Text $section -Number $number)
                foreach ($literal in @($hits.Keys)) { if ($item.Contains($literal)) { $hits[$literal] += $number } }
            }

            # Assert
            ($hits['is the new review for the new head'] -join ',') | Should -BeExactly '7'
            ($hits['applies to feature-review outcomes only'] -join ',') | Should -BeExactly '11'
        }
    }

    Context 'epic skill structure in <Prefix>' -ForEach $script:Surface {
        BeforeAll {
            $script:EpicText = Get-RscText -Path ($Prefix + '.claude/skills/epic-orchestrate/SKILL.md')
        }

        It 'states the integration-tip default-off boundary in its own section only' {
            # Act
            $count = ([regex]::Matches((Get-RscCollapsed -Text $script:EpicText), [regex]::Escape('the integration-tip flow runs only when'))).Count

            # Assert
            $count | Should -Be 1
        }

        It 'runs the child-side check and the regenerate path first in the fan-in section' {
            # Arrange
            $section = Get-RscSection -Text $script:EpicText -Heading '## Merge-Conflict Handling (Fan-In)'

            # Act
            $paragraphs = @(($section -split "`n`n") | ForEach-Object { Get-RscCollapsed -Text $_ } | Where-Object { $_.Contains('the child-side check and the regenerate path run first') -and $_.Contains($script:RemediationHeading) })

            # Assert
            $paragraphs.Count | Should -Be 1
        }

        It 'runs the child-side check and the regenerate path first in early-start step 7' {
            # Arrange
            $section = Get-RscSection -Text $script:EpicText -Heading '## Early Dependent Starts (early_start)'

            # Act
            $item = Get-RscCollapsed -Text (Get-RscNumberedItem -Text $section -Number 7)

            # Assert
            $item.Contains('the child-side check and the regenerate path run first') | Should -BeTrue
            $item.Contains($script:RemediationHeading) | Should -BeTrue
        }

        It 'keeps the main-sync literals inside step 3 of the lifecycle section only' {
            # Arrange
            $section = Get-RscSection -Text $script:EpicText -Heading '## Epic Integration Branch Lifecycle'
            $literals = @(
                'the main-sync regenerate path runs only when the integration worktree holds a valid config/orchestration-regeneration.json',
                '-Mode Merge -MergeRef origin/main -Trigger main_sync', 'commits during the in-progress merge', 'dispatches and verifies CI before the wave launches',
                'appends an integration_regenerations[] entry with trigger main_sync', 'the fallback runs this step unchanged'
            )

            # Act
            $starts = Get-RscNumberedStart -Text $section
            $stepThree = Get-RscNumberedItem -Text $section -Number 3

            # Assert
            ($starts -join ',') | Should -BeExactly '1,2,3,4,5,6'
            Assert-RscLiteralPresent -Scope $stepThree -Literal $literals -Label 'step 3 of the lifecycle section'
            foreach ($number in @($starts | Where-Object { $_ -ne 3 })) {
                $other = Get-RscCollapsed -Text (Get-RscNumberedItem -Text $section -Number $number)
                foreach ($literal in $literals) { $other.Contains($literal) | Should -BeFalse -Because "step $number must not contain: $literal" }
            }
            $collapsed = Get-RscCollapsed -Text $section
            foreach ($phrase in $script:RemovedChildItemPhrase) { $collapsed.Contains($phrase) | Should -BeFalse -Because "retired wording: $phrase" }
        }
    }

    Context 'epic agent grant in <Prefix>' -ForEach $script:Surface {
        It 'holds exactly one Invoke-RegenerationPath.ps1 grant in the Invoke-CiGateParser form and no generic route' {
            # Arrange
            $text = Get-RscText -Path ($Prefix + '.claude/agents/epic-orchestrator.md')
            $frontmatter = ($text -split "`n---`n", 2)[0]

            # Act
            $entries = @(($frontmatter -split "`n") | Where-Object { $_ -cmatch '^\s*-\s*"' } | ForEach-Object { ($_ -replace '^\s*-\s*"', '') -replace '"\s*$', '' })
            $grants = @($entries | Where-Object { $_.Contains('Invoke-RegenerationPath.ps1') })

            # Assert
            $grants.Count | Should -Be 1
            $grants[0] | Should -BeExactly 'Bash(pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1*)'
            $entries -ccontains 'Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1*)' | Should -BeTrue
            foreach ($generic in @('Bash(pwsh *)', 'Bash(sh *)', 'Bash(*)', 'Bash')) { $entries -ccontains $generic | Should -BeFalse -Because $generic }
        }
    }

    Context 'Codex scope and absence' {
        It 'keeps Invoke-RegenerationPath out of <Copy>' -ForEach @(
            @{ Copy = '.agents/skills/orchestrate/SKILL.md' }
            @{ Copy = '.agents/skills/epic-orchestrate/SKILL.md' }
        ) {
            # Act
            $text = Get-RscText -Path $Copy

            # Assert
            $text.Contains('Invoke-RegenerationPath') | Should -BeFalse
        }

        It 'does not ship <Path>' -ForEach @(
            @{ Path = 'config/orchestration-regeneration.json' }
            @{ Path = 'extensions/drm-copilot/resources/config/orchestration-regeneration.json' }
        ) {
            # Assert
            Test-Path -LiteralPath (Join-Path $script:RepoRoot $Path) | Should -BeFalse
        }
    }

    Context 'scope helpers' {
        BeforeAll {
            $script:Sample = @('# Title', '## Alpha', 'alpha text', '### Inner', 'inner text', '## Beta', 'beta text', '1. one', '   one more', '2. two', '10. ten') -join "`n"
        }

        It 'a level-two section stops at the next level-two heading' {
            # Act
            $section = Get-RscSection -Text $script:Sample -Heading '## Alpha'

            # Assert
            $section.Contains('inner text') | Should -BeTrue
            $section.Contains('beta text') | Should -BeFalse
        }

        It 'a level-three subsection stops at the next heading of any level' {
            # Act
            $section = Get-RscSection -Text $script:Sample -Heading '### Inner'

            # Assert
            $section.Contains('inner text') | Should -BeTrue
            $section.Contains('beta text') | Should -BeFalse
        }

        It 'a numbered item stops at the next column-0 numbered start' {
            # Arrange
            $section = Get-RscSection -Text $script:Sample -Heading '## Beta'

            # Act
            $item = Get-RscNumberedItem -Text $section -Number 1

            # Assert
            $item.Contains('one more') | Should -BeTrue
            $item.Contains('two') | Should -BeFalse
            (Get-RscNumberedStart -Text $section) -join ',' | Should -BeExactly '1,2,10'
        }

        It 'returns $null for an absent heading or item' {
            # Assert
            $null -eq (Get-RscSection -Text $script:Sample -Heading '## Gamma') | Should -BeTrue
            $null -eq (Get-RscNumberedItem -Text $script:Sample -Number 5) | Should -BeTrue
        }
    }
}
