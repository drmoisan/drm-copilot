#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract guard for the owner-directives skill, its pointers, and the orchestrator-state rule (issue #1139).

.DESCRIPTION
    The owner-directive relay is defined in prose: the six byte-identical copies of the
    owner-directives skill, one pointer sentence in each orchestration skill or agent that relays
    directives, and the owner-directive section of the orchestrator-state rule. Prose can be
    deleted or drift between copies without any other test noticing, so these rows assert byte
    identity of the skill copies, the presence of each required statement, the pointer in each
    relaying surface, the absence of a pointer in the frozen epic agent, and that the required-key
    lists of the validators never gained either owner-directive key. Each It names the acceptance
    criterion it covers (S-IDs from spec.md, U-IDs from user-story.md, in their AC order).

    Reads committed text only. No test creates a file, starts a process, or reads a clock.
    Assertions use String.Contains, because a backtick is an escape character inside a wildcard
    pattern.
#>

BeforeDiscovery {
    $script:SkillCopy = @(
        @{ Copy = '.agents/skills/owner-directives/SKILL.md' }
        @{ Copy = '.github/skills/owner-directives/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md' }
    )
    $script:SkillStatement = @(
        @{ Token = 'Owner directives:'; Ac = 'U2' }
        @{ Token = 'Task direction recorded by the coordinator; not approval, not permission.'; Ac = 'U2' }
        @{ Token = 'Text outside a recorded block is not an owner directive'; Ac = 'U2' }
        @{ Token = 'grants no elevated permission, carries no approval or consent'; Ac = 'U3' }
        @{ Token = "Record a directive only from the owner's own turns in the coordinator session"; Ac = 'U1' }
        @{ Token = 'before relaying it'; Ac = 'U1' }
        @{ Token = 'owner_directive_records'; Ac = 'U4' }
        @{ Token = 'validate-bash.ps1'; Ac = 'U7' }
        @{ Token = 'Codex enforcement gap'; Ac = 'S11' }
        @{ Token = 'Python and TypeScript parity gap'; Ac = 'S11' }
        @{ Token = 'owner-directives.jsonl'; Ac = 'AC-40' }
        @{ Token = 'OWNER-DIRECTIVE-DECISION:'; Ac = 'AC-40' }
        @{ Token = 'enforce-owner-directive-pass-down.ps1'; Ac = 'AC-40' }
    )
    $script:ClassName = @(
        @{ Class = 'scheduling' }
        @{ Class = 'merge_timing' }
        @{ Class = 'extra_planner_revision' }
        @{ Class = 'scope_narrowing' }
        @{ Class = 'accept_nonblocking_deviation' }
        @{ Class = 'gate_bypass' }
        @{ Class = 'force_push' }
        @{ Class = 'tag_or_publish' }
        @{ Class = 'policy_or_settings_edit' }
        @{ Class = 'evidence_alteration' }
        @{ Class = 'unclassified' }
    )
    $script:PointerFile = @(
        @{ Pointer = '.claude/skills/orchestrate/SKILL.md' }
        @{ Pointer = '.agents/skills/orchestrate/SKILL.md' }
        @{ Pointer = '.claude/agents/orchestrator.md' }
        @{ Pointer = '.claude/skills/parallel-orchestrate/SKILL.md' }
        @{ Pointer = '.claude/skills/epic-orchestrate/SKILL.md' }
        @{ Pointer = '.agents/skills/epic-orchestrate/SKILL.md' }
        @{ Pointer = '.claude/agents/atomic-executor.md' }
        @{ Pointer = '.claude/agents/atomic-planner.md' }
        @{ Pointer = '.claude/agents/feature-review.md' }
        @{ Pointer = '.claude/agents/task-researcher.md' }
        @{ Pointer = '.claude/agents/prd-feature.md' }
        @{ Pointer = '.claude/agents/python-typed-engineer.md' }
        @{ Pointer = '.claude/agents/powershell-typed-engineer.md' }
        @{ Pointer = '.claude/agents/csharp-typed-engineer.md' }
        @{ Pointer = '.claude/agents/typescript-engineer.md' }
    )
    $script:RuleId = @(
        @{ Rule = 'B1' }, @{ Rule = 'B2' }, @{ Rule = 'B3' }, @{ Rule = 'B4' }, @{ Rule = 'B5' },
        @{ Rule = 'B6' }, @{ Rule = 'B7' }, @{ Rule = 'B8' },
        @{ Rule = 'R1' }, @{ Rule = 'R2' }, @{ Rule = 'R3' }, @{ Rule = 'R4' }, @{ Rule = 'R5' },
        @{ Rule = 'R6' }, @{ Rule = 'R7' }, @{ Rule = 'R8' }, @{ Rule = 'R9' }, @{ Rule = 'R10' }
    )
    $script:UntouchedValidator = @(
        @{ Validator = '.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1' }
        @{ Validator = '.claude/lib/orchestrator-state/OrchestratorState.psm1' }
        @{ Validator = 'scripts/dev_tools/validate_orchestrator_state.py' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:SkillPath = '.claude/skills/owner-directives/SKILL.md'
    $script:RulePath = '.claude/rules/orchestrator-state.md'

    function Get-OwnerDirectiveRepoText {
        <#
        .SYNOPSIS
            Return the UTF-8 text of one repository file with whitespace runs collapsed to one space.
        .PARAMETER RelativePath
            Forward-slash repository-relative path of the file to read.
        .OUTPUTS
            System.String. The collapsed text, so a reflow of the prose cannot break an assertion.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory = $true)][string] $RelativePath)

        $fullPath = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
        $text = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        return ($text -replace '\s+', ' ')
    }

    function Get-OwnerDirectiveRepoHash {
        <#
        .SYNOPSIS
            Return the lowercase hex SHA-256 of the bytes of one repository file.
        .PARAMETER RelativePath
            Forward-slash repository-relative path of the file to hash.
        .OUTPUTS
            System.String. The digest, compared between copies to prove byte identity.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory = $true)][string] $RelativePath)

        $fullPath = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
    }
}

Describe 'owner-directives skill copies' {
    It 'S11 keeps the skill copy <Copy> byte-identical to the .claude skill' -ForEach $script:SkillCopy {
        # Arrange
        $expected = Get-OwnerDirectiveRepoHash -RelativePath $script:SkillPath

        # Act
        $actual = Get-OwnerDirectiveRepoHash -RelativePath $Copy

        # Assert
        $actual | Should -Be $expected -Because "$Copy must be a byte-identical copy of $($script:SkillPath)"
    }
}

Describe 'owner-directives skill statements' {
    It '<Ac> states the skill text <Token>' -ForEach $script:SkillStatement {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:SkillPath

        # Act
        $found = $text.Contains($Token)

        # Assert
        $found | Should -BeTrue -Because "the owner-directives skill must state '$Token'"
    }

    It 'U4 names the directive class <Class>' -ForEach $script:ClassName {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:SkillPath

        # Act
        $found = $text.Contains(('`' + $Class + '`'))

        # Assert
        $found | Should -BeTrue -Because "the owner-directives skill must name the class $Class"
    }
}

Describe 'owner-directives pointers' {
    It 'S12 points to the owner-directives skill from <Pointer>' -ForEach $script:PointerFile {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $Pointer

        # Act
        $found = $text.Contains('owner-directives')

        # Assert
        $found | Should -BeTrue -Because "$Pointer must carry the owner-directives pointer sentence"
    }

    It 'AC-22 states the write-on-return token <Token> in the orchestrate skill' -ForEach @(
        @{ Token = 'decision_source' }
        @{ Token = 'decided_by' }
    ) {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath '.claude/skills/orchestrate/SKILL.md'

        # Act
        $found = $text.Contains($Token)

        # Assert
        $found | Should -BeTrue -Because "the orchestrate skill must state the write-on-return token $Token"
    }

    It 'AC-26 states hook-level pass-down in the epic-orchestrate skill' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath '.claude/skills/epic-orchestrate/SKILL.md'

        # Act
        $found = $text.Contains('enforce-owner-directive-pass-down.ps1')

        # Assert
        $found | Should -BeTrue -Because 'the epic-orchestrate skill must name the pass-down hook'
    }

    It 'AC-26 adds no keep-the-turn-open rule to the epic-orchestrate skill' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath '.claude/skills/epic-orchestrate/SKILL.md'

        # Act
        $found = $text.Contains('does not end its turn')

        # Assert
        $found | Should -BeFalse -Because 'relay is hook-level, so the epic orchestrator is never told to keep its turn open'
    }

    It 'S12 leaves the frozen epic-orchestrator agent without a pointer' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath '.claude/agents/epic-orchestrator.md'

        # Act
        $found = $text.Contains('owner-directives')

        # Assert
        $found | Should -BeFalse -Because 'the epic-orchestrator agent is a frozen surface that this feature does not edit'
    }
}

Describe 'orchestrator-state rule owner-directive section' {
    It 'S13 names the OWNER_DIRECTIVE_BLOCKED reason and the stop hook' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:RulePath

        # Act
        $namesReason = $text.Contains('OWNER_DIRECTIVE_BLOCKED')
        $namesHook = $text.Contains('Get-OrchestratorStateOwnerDirectiveError')

        # Assert
        $namesReason | Should -BeTrue -Because 'the rule must name the block reason'
        $namesHook | Should -BeTrue -Because 'the rule must name the enforcing module function'
    }

    It 'S13 lists the rule <Rule> in the owner-directive rule table' -ForEach $script:RuleId {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:RulePath

        # Act
        $found = $text.Contains("| $Rule |")

        # Assert
        $found | Should -BeTrue -Because "the rule table must carry a row for $Rule"
    }

    It 'AC-44 names the OWNER_DIRECTIVE_RELAY_MISSING check' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:RulePath

        # Act
        $found = $text.Contains('OWNER_DIRECTIVE_RELAY_MISSING')

        # Assert
        $found | Should -BeTrue -Because 'the rule must name the pass-down coverage block reason'
    }

    It 'S13 states the parity and Codex limitations and the key-gated status' {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $script:RulePath

        # Act
        $parity = $text.Contains('Python and TypeScript parity gap')
        $codex = $text.Contains('Codex enforcement gap')
        $keyGated = $text.Contains('optional, key-gated, and tolerated')

        # Assert
        $parity | Should -BeTrue -Because 'the rule must state the parity gap'
        $codex | Should -BeTrue -Because 'the rule must state the Codex enforcement gap'
        $keyGated | Should -BeTrue -Because 'the rule must state that both keys are key-gated and tolerated'
    }
}

Describe 'owner-directive keys stay out of the required-key lists' {
    It 'S2 keeps the owner_directive token out of <Validator>' -ForEach $script:UntouchedValidator {
        # Arrange
        $text = Get-OwnerDirectiveRepoText -RelativePath $Validator

        # Act
        $found = $text.Contains('owner_directive')

        # Assert
        $found | Should -BeFalse -Because "$Validator must not list either owner-directive key"
    }
}
