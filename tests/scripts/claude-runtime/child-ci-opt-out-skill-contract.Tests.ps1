#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the child CI opt-out text of the skills, rule, brief, and template (issue #1233).

.DESCRIPTION
    Every paragraph or list item that issue #1233 adds to a skill or the rule begins with the label
    "Child CI opt-out (issue #1233):", and every one it adds to the execution-environment brief begins
    with "Child-CI opt-out (#1233):". Each row reads one copy, extracts the named level-two section,
    selects the labeled units of that section (the paragraph or list item that begins with the label,
    up to the next blank line, list item, or heading, with line breaks replaced by single spaces), and
    requires every token of the row inside one unit, compared ordinally with String.Contains. The rule
    section added by the issue is read as a whole section, and the template row reads the manifest
    frontmatter. No row reads a whole file where a section is named.

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
#>

BeforeDiscovery {
    $claudeBundle = 'extensions/drm-copilot/resources/claude-customizations/'
    $codexBundle = 'extensions/drm-copilot/resources/codex-and-agents-customizations/'
    $dash = [string][char]0x2014
    $skillLabel = 'Child CI opt-out (issue #1233):'
    $briefLabel = 'Child-CI opt-out (#1233):'

    $orchestrateClaude = '.claude/skills/orchestrate/SKILL.md'
    $orchestrateCodex = '.agents/skills/orchestrate/SKILL.md'
    $epicClaude = '.claude/skills/epic-orchestrate/SKILL.md'
    $epicCodex = '.agents/skills/epic-orchestrate/SKILL.md'
    $runClaude = '.claude/skills/epic-run/SKILL.md'
    $runCodex = '.agents/skills/epic-run/SKILL.md'
    $planCodex = '.agents/skills/epic-plan/SKILL.md'
    $planClaude = '.claude/skills/epic-plan/SKILL.md'
    $rule = '.claude/rules/orchestrator-state.md'
    $briefClaude = '.claude/skills/execution-environment/SKILL.md'
    $briefCodex = '.agents/skills/execution-environment/SKILL.md'

    $s9Tokens = @('first checkpoint write', 'Child CI: integration_only.', 'baseRefName', 'does not query checks', 'never dispatches', 'local-qc-gate.', 'local_qc_gate', 'step9_status: "passed"', 'review_mode: "concurrent"', 'per_child', 'item 5', 'item 11', 'pending integration CI')
    $unitSpec = @(
        @{ Unit = 'O-S9'; Claude = @($orchestrateClaude, "## Step S9 $dash CI Green Gate"); Codex = @($orchestrateCodex, '## CI Green Gate'); Tokens = $s9Tokens }
        @{ Unit = 'O-FIELDS'; Claude = @($orchestrateClaude, "## Checkpoint Schema $dash CI Gate Fields"); Codex = @($orchestrateCodex, '## CI Green Gate'); Tokens = @('child_ci', 'local_qc_gate', 'evidence_path', 'verified_at') }
        @{ Unit = 'O-PR'; Claude = @($orchestrateClaude, '## PR Creation Gate'); Codex = @($orchestrateCodex, '## PR Creation Gate'); Tokens = @('child_ci', 'local_qc_gate') }
        @{ Unit = 'E-MAN'; Claude = @($epicClaude, '## Epic Dependency Manifest'); Codex = @($epicCodex, '## Manifest Contract'); Tokens = @('child_ci', 'per_child', 'integration_only', 'synthetic Blocking finding') }
        @{ Unit = 'E-CP'; Claude = @($epicClaude, '## Epic-Level Checkpoint'); Codex = @($epicCodex, '## Status Projection and Checkpoint'); Tokens = @('child_ci', 'manifest') }
        @{ Unit = 'E-KICK'; Claude = @($epicClaude, '## Merge-on-Green Kickoff Parameter'); Codex = @($epicCodex, '## Integration Branch and Child Worktrees'); Tokens = @('Child CI: integration_only.', 'first checkpoint write') }
        @{ Unit = 'E-MERGE'; Claude = @($epicClaude, '## Merge-on-Green Kickoff Parameter'); Codex = @($epicCodex, '## Fan-In and Conflict Handling'); Tokens = @('never dispatches', 'pr_open', 'never recorded as', 'ci_green') }
        @{ Unit = 'E-FINAL'; Claude = @($epicClaude, '## Epic Integration Branch Lifecycle'); Codex = @($epicCodex, '## Final Integration PR'); Tokens = @('integration_only', 'green', 'integration worktree', '#1141') }
        @{ Unit = 'R-RUN'; Claude = @($runClaude, '## Scope'); Codex = @($runCodex, '## Procedure'); Tokens = @('integration_only', 'replaced') }
    )

    $rows = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($spec in $unitSpec) {
        foreach ($copy in @(
                @{ Copy = 'claude'; File = $spec.Claude[0]; Heading = $spec.Claude[1] }
                @{ Copy = 'claude-bundle'; File = $claudeBundle + $spec.Claude[0]; Heading = $spec.Claude[1] }
                @{ Copy = 'codex'; File = $spec.Codex[0]; Heading = $spec.Codex[1] }
                @{ Copy = 'codex-bundle'; File = $codexBundle + $spec.Codex[0]; Heading = $spec.Codex[1] }
            )) {
            $rows.Add(@{ Case = "$($spec.Unit) [$($copy.Copy)]"; File = $copy.File; Heading = $copy.Heading; Label = $skillLabel; Tokens = $spec.Tokens })
        }
    }
    foreach ($copy in @(@{ Copy = 'codex'; File = $planCodex }, @{ Copy = 'claude'; File = $planClaude }, @{ Copy = 'claude-bundle'; File = $claudeBundle + $planClaude }, @{ Copy = 'codex-bundle'; File = $codexBundle + $planCodex })) {
        $rows.Add(@{ Case = "P-PLAN [$($copy.Copy)]"; File = $copy.File; Heading = '## Decomposition and Wave Design'; Label = $skillLabel; Tokens = @('child_ci', 'integration_only', 'pending integration CI', 'owner') })
    }
    foreach ($copy in @(@{ Copy = 'claude'; File = $rule }, @{ Copy = 'claude-bundle'; File = $claudeBundle + $rule })) {
        $rows.Add(@{ Case = "X-ENF [$($copy.Copy)]"; File = $copy.File; Heading = '## Enforcement'; Label = $skillLabel; Tokens = @('EPIC_CHILD_LOCAL_QC_NOT_VERIFIED', 'child_ci') })
    }
    $briefSpec = @(
        @{ Unit = 'B-HOOK'; Heading = '## Hook Execution Context'; Tokens = @('integration_only', 'EPIC_CHILD_LOCAL_QC_NOT_VERIFIED', '-GitRoot') }
        @{ Unit = 'B-CI'; Heading = '## CI Shape and Required Checks'; Tokens = @('integration_only', 'does not dispatch') }
        @{ Unit = 'B-MCP'; Heading = '## MCP Surfaces Run the Installed Extension'; Tokens = @('integration_only', 'validate_orchestration_artifacts.py', 'Codex') }
        @{ Unit = 'B-TEST'; Heading = '## Contract Tests That Pin Mirrored Files'; Tokens = @('child-ci-opt-out-skill-contract.Tests.ps1') }
    )
    foreach ($spec in $briefSpec) {
        foreach ($copy in @(@{ Copy = 'claude'; File = $briefClaude }, @{ Copy = 'codex'; File = $briefCodex }, @{ Copy = 'claude-bundle'; File = $claudeBundle + $briefClaude }, @{ Copy = 'codex-bundle'; File = $codexBundle + $briefCodex })) {
            $rows.Add(@{ Case = "$($spec.Unit) [$($copy.Copy)]"; File = $copy.File; Heading = $spec.Heading; Label = $briefLabel; Tokens = $spec.Tokens })
        }
    }
    $script:UnitRow = $rows.ToArray()

    $script:RuleSectionRow = @(
        @{ Case = 'X-SECTION [claude]'; File = $rule }
        @{ Case = 'X-SECTION [claude-bundle]'; File = $claudeBundle + $rule }
    )
    $script:LimitRow = @(
        @{ Case = 'X-LIMIT [claude]'; File = $rule }
        @{ Case = 'X-LIMIT [claude-bundle]'; File = $claudeBundle + $rule }
    )
    $script:TemplateRow = @(
        @{ Case = 'T-TEMPLATE [source]'; File = '.dev/templates/epic/epic.md' }
        @{ Case = 'T-TEMPLATE [bundle]'; File = 'extensions/drm-copilot/resources/feature-templates/epic/epic.md' }
    )
    $script:CaseCount = @(@{ Cases = @($script:UnitRow.Case + $script:RuleSectionRow.Case + $script:LimitRow.Case + $script:TemplateRow.Case) })
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path

    function Get-CcoText {
        <#
        .SYNOPSIS
            Return the LF-normalized text of one repository file.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory)][string] $RelativePath)

        return ([System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $RelativePath))).Replace("`r`n", "`n")
    }

    function Get-CcoSection {
        <#
        .SYNOPSIS
            Return the lines of the level-two section that starts with the exact heading, or an empty array.
        #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param([Parameter(Mandatory)][AllowEmptyString()][string] $Text, [Parameter(Mandatory)][string] $Heading)

        $lines = $Text.Split("`n")
        $start = [Array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { return [string[]]@() }
        $section = [System.Collections.Generic.List[string]]::new()
        $inFence = $false
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            # A line inside a fenced block (for example a YAML comment) never ends the section.
            if ($lines[$index].StartsWith('```', [System.StringComparison]::Ordinal)) { $inFence = -not $inFence }
            if (-not $inFence -and ($lines[$index].StartsWith('## ', [System.StringComparison]::Ordinal) -or $lines[$index].StartsWith('# ', [System.StringComparison]::Ordinal))) { break }
            $section.Add($lines[$index])
        }
        return [string[]]$section.ToArray()
    }

    function Get-CcoLabeledUnit {
        <#
        .SYNOPSIS
            Return each paragraph or list item of the section lines that begins with the label.
        .DESCRIPTION
            A unit starts at a line whose text, after an optional list marker ("- " or "N. ") and
            leading spaces, begins with the label. It ends before the next blank line, list item, or
            heading. Its line breaks become single spaces and its runs of spaces collapse to one.
        #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Line, [Parameter(Mandatory)][string] $Label)

        $units = [System.Collections.Generic.List[string]]::new()
        $current = $null
        foreach ($text in $Line) {
            $trimmed = $text.Trim()
            $isBoundary = $trimmed.Length -eq 0 -or $trimmed.StartsWith('#', [System.StringComparison]::Ordinal) -or $trimmed -match '^(?:[-*]|\d+\.)\s'
            $body = $trimmed -replace '^(?:[-*]|\d+\.)\s+', ''
            if ($isBoundary -or $body.StartsWith($Label, [System.StringComparison]::Ordinal)) {
                if ($null -ne $current) { $units.Add(($current -replace '\s+', ' ').Trim()); $current = $null }
                if ($body.StartsWith($Label, [System.StringComparison]::Ordinal)) { $current = $body }
                continue
            }
            if ($null -ne $current) { $current = "$current $trimmed" }
        }
        if ($null -ne $current) { $units.Add(($current -replace '\s+', ' ').Trim()) }
        return [string[]]$units.ToArray()
    }

    function Get-CcoMissingToken {
        <#
        .SYNOPSIS
            Return the tokens that no single labeled unit of the named section contains.
        #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param([Parameter(Mandatory)][string] $File, [Parameter(Mandatory)][string] $Heading, [Parameter(Mandatory)][string] $Label, [Parameter(Mandatory)][string[]] $Tokens)

        $units = @(Get-CcoLabeledUnit -Line (Get-CcoSection -Text (Get-CcoText -RelativePath $File) -Heading $Heading) -Label $Label)
        if ($units.Count -eq 0) { return [string[]]@("<no labeled unit in $Heading>") }
        $best = $Tokens
        foreach ($unit in $units) {
            $missing = @($Tokens | Where-Object { -not $unit.Contains($_) })
            if ($missing.Count -lt $best.Count) { $best = $missing }
        }
        return [string[]]@($best)
    }
}

Describe 'child CI opt-out skill, rule, brief, and template text (issue #1233)' {
    It 'CCO-CASE-LABELS-DISTINCT gives every row a distinct case label' -ForEach $script:CaseCount {
        @($Cases | Sort-Object -Unique).Count | Should -Be @($Cases).Count
    }

    It 'CCO <Case> holds every token in one labeled unit of <Heading>' -ForEach $script:UnitRow {
        # Act
        $missing = @(Get-CcoMissingToken -File $File -Heading $Heading -Label $Label -Tokens $Tokens)

        # Assert
        $missing.Count | Should -Be 0 -Because "$File is missing: $($missing -join ' | ')"
    }

    It 'CCO <Case> states the self-declared-key disclosure in its own section' -ForEach $script:RuleSectionRow {
        # Arrange
        $section = (@(Get-CcoSection -Text (Get-CcoText -RelativePath $File) -Heading '## Epic-child CI opt-out (issue #1233)') -join ' ') -replace '\s+', ' '

        # Act
        $missing = @(@('self-declared', 'policy-level', 'D10', 'baseRefName', 'review_mode: "concurrent"', 'Head:') | Where-Object { -not $section.Contains($_) })

        # Assert
        $section.Length | Should -BeGreaterThan 0 -Because 'the rule carries the issue #1233 section'
        $missing.Count | Should -Be 0 -Because "missing: $($missing -join ' | ')"
    }

    It 'CCO <Case> states the whitespace-set known limitation in its own section' -ForEach $script:LimitRow {
        # Arrange
        $section = (@(Get-CcoSection -Text (Get-CcoText -RelativePath $File) -Heading '## Epic-child CI opt-out (issue #1233)') -join ' ') -replace '\s+', ' '

        # Act
        $missing = @(@('Known limitation:', 'str.strip', 'IsNullOrWhiteSpace', 'U+0085', 'U+001C', 'U+FEFF') | Where-Object { -not $section.Contains($_) })

        # Assert
        $section.Length | Should -BeGreaterThan 0 -Because 'the rule carries the issue #1233 section'
        $missing.Count | Should -Be 0 -Because "missing: $($missing -join ' | ')"
    }

    It 'CCO <Case> names child_ci and its values in the manifest frontmatter' -ForEach $script:TemplateRow {
        # Arrange
        $lines = (Get-CcoText -RelativePath $File).Split("`n")
        $close = [Array]::IndexOf($lines, '---', 1)
        $frontmatter = ($lines[1..($close - 1)] -join ' ')

        # Act
        $missing = @(@('child_ci', 'per_child', 'integration_only') | Where-Object { -not $frontmatter.Contains($_) })

        # Assert
        $close | Should -BeGreaterThan 0 -Because 'the template has a closed frontmatter block'
        $missing.Count | Should -Be 0 -Because "missing: $($missing -join ' | ')"
    }

    Context 'labeled-unit helper' {
        It 'CCO-HELPER-NO-LABEL returns no unit for a section without the label' {
            # Arrange
            $line = [string[]]@('Plain paragraph naming child_ci.', '', '- A list item naming integration_only.')

            # Act
            $units = @(Get-CcoLabeledUnit -Line $line -Label 'Child CI opt-out (issue #1233):')

            # Assert
            $units.Count | Should -Be 0
        }

        It 'CCO-HELPER-STOPS-AT-BLANK ends a unit at the next blank line and joins its lines' {
            # Arrange
            $line = [string[]]@('Child CI opt-out (issue #1233): first', 'second line', '', 'outside token')

            # Act
            $units = @(Get-CcoLabeledUnit -Line $line -Label 'Child CI opt-out (issue #1233):')

            # Assert
            $units.Count | Should -Be 1
            $units[0] | Should -BeExactly 'Child CI opt-out (issue #1233): first second line'
        }
    }
}
