#Requires -Version 7.0

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-prd-feature-output.ps1')

    function Get-CompleteNumericDerivationEvidence {
        param(
            [string] $PrimaryStrategy = "rg '(GetMethod|GetField)\\(' entire repository",
            [string] $CrossCheckStrategy = 'AST traversal of GetMethod and GetField across entire repository',
            [string] $PrimaryMembers = 'A, B',
            [string] $CrossCheckMembers = 'A, B',
            [int] $PrimaryCount = 2,
            [int] $CrossCheckCount = 2
        )

        return @"
## Numeric Derivation Evidence
- Complete Family: GetMethod, GetField
- Exhaustive Search Scope: entire repository source tree
- Inclusion Rules: variable arguments only
- Exclusion Rules: generated calls
- Primary Search Strategy or Query Expression: $PrimaryStrategy
- Primary Member Set: $PrimaryMembers
- Primary Count: $PrimaryCount
- Cross-check Search Strategy or Query Expression: $CrossCheckStrategy
- Cross-check Member Set: $CrossCheckMembers
- Cross-check Count: $CrossCheckCount
- Member-set Comparison: normalized sets match
"@
    }

    . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
}

Describe 'validate-prd-feature-output.ps1' {
    It 'allows a spec without numeric acceptance criteria' {
        $result = Test-SpecNumericCriterion -SpecContent "## Acceptance Criteria`n- [ ] A textual criterion"

        $result | Should -BeFalse
    }

    It 'detects a numeric spec acceptance criterion' {
        $result = Test-SpecNumericCriterion -SpecContent "## Acceptance Criteria`n- [ ] All 8 call sites are covered"

        $result | Should -BeTrue
    }

    It 'does not count numeric boxes outside Acceptance Criteria' {
        $result = Test-SpecNumericCriterion -SpecContent "- [ ] All 99 unrelated boxes`n## Acceptance Criteria`n- [ ] A textual criterion`n## Notes`n- [ ] All 7 unrelated boxes"

        $result | Should -BeFalse
    }

    It 'rejects a numeric claim without a complete research record' {
        $result = Test-NumericDerivationEvidence -Content "## Numeric Derivation Evidence`n- Family: GetMethod"

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'missing'
    }

    It 'rejects a research record whose independent cross-check disagrees' {
        $content = Get-CompleteNumericDerivationEvidence -CrossCheckMembers 'A, B, C' -CrossCheckCount 3

        $result = Test-NumericDerivationEvidence -Content $content

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'disagree'
    }

    It 'accepts an independently exhaustive complete-family research record' {
        $content = Get-CompleteNumericDerivationEvidence

        $result = Test-NumericDerivationEvidence -Content $content

        $result.Ok | Should -BeTrue
    }

    It 'rejects an invalid envelope and a blank assistant message' {
        (Invoke-PrdFeatureOutputValidation -InputText '').Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -InputText '{bad').Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -InputText '{}').Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage '')).Ok | Should -BeFalse
    }

    It 'rejects missing and nonexistent spec paths' {
        Mock Test-Path { $false }

        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: missing.md')).Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: nonexistent.md')).Ok | Should -BeFalse
    }

    It 'accepts a nonnumeric spec without research evidence' {
        Mock Test-Path { $true }
        Mock Get-Content { '## Acceptance Criteria' + [Environment]::NewLine + '- [ ] A textual criterion' }

        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: textual.md')).Ok | Should -BeTrue
    }

    It 'rejects numeric specs with missing or nonexistent research paths' {
        Mock Test-Path { param($LiteralPath) $LiteralPath -eq 'numeric.md' }
        Mock Get-Content { '## Acceptance Criteria' + [Environment]::NewLine + '- [ ] The 2 call sites are covered' }

        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: numeric.md')).Ok | Should -BeFalse
        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage "spec-path: numeric.md`nresearch-path: missing.md")).Ok | Should -BeFalse
    }

    It 'accepts matching numeric provenance and extracts artifact labels' {
        $complete = Get-CompleteNumericDerivationEvidence
        Mock Test-Path { $true }
        Mock Get-Content { param($LiteralPath) if ($LiteralPath -eq 'numeric.md') { "## Acceptance Criteria`n- [ ] The 2 call sites are covered" } else { $complete } }

        (Invoke-PrdFeatureOutputValidation -InputText (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage "spec-path: numeric.md`nresearch-path: research.md")).Ok | Should -BeTrue
        Get-ArtifactPathFromOutput -Output 'spec-path: numeric.md' -Label 'spec-path' | Should -Be 'numeric.md'
    }

    It 'rejects every missing numeric-evidence field and a missing section' {
        $fields = @('Complete Family', 'Exhaustive Search Scope', 'Inclusion Rules', 'Exclusion Rules', 'Primary Search Strategy or Query Expression', 'Primary Member Set', 'Primary Count', 'Cross-check Search Strategy or Query Expression', 'Cross-check Member Set', 'Cross-check Count', 'Member-set Comparison')
        foreach ($field in $fields) {
            $content = (Get-CompleteNumericDerivationEvidence) -replace "- $([regex]::Escape($field)): .+", "- $($field):"

            (Test-NumericDerivationEvidence -Content $content).Ok | Should -BeFalse
        }

        (Test-NumericDerivationEvidence -Content '## Other Evidence').Ok | Should -BeFalse
    }

    It 'rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records' {
        $copiedCount = Get-CompleteNumericDerivationEvidence -CrossCheckCount 3
        $duplicateSearch = Get-CompleteNumericDerivationEvidence -CrossCheckStrategy "rg '(GetMethod|GetField)\\(' entire repository"
        $memberMismatch = Get-CompleteNumericDerivationEvidence -CrossCheckMembers 'A, C'
        $scopeMissing = (Get-CompleteNumericDerivationEvidence) -replace '- Exhaustive Search Scope: .+', '- Exhaustive Search Scope: focused directory'
        $narrowSearch = Get-CompleteNumericDerivationEvidence -PrimaryStrategy 'narrow named-pattern GetMethod('

        foreach ($content in @($copiedCount, $duplicateSearch, $memberMismatch, $scopeMissing, $narrowSearch)) {
            (Test-NumericDerivationEvidence -Content $content).Ok | Should -BeFalse
        }
    }

    Context 'Test-SpecNumericCriterion rule R2 (issue #905)' {
        # Each row is a single acceptance-criterion line; R2 triggers only on a determiner-led cardinal count of a plural noun
        # that cites no policy file.
        It 'R2 triggers on <Name>' -ForEach @(
            @{ Name = 'all with a digit cardinal'; Line = 'All 12 agent files contain the marker.' }
            @{ Name = 'all with a word cardinal'; Line = 'All twelve agent files contain the marker.' }
            @{ Name = 'exactly with a digit cardinal'; Line = 'The managed block lists exactly 2 entries.' }
            @{ Name = 'exactly with a word cardinal'; Line = 'The managed block lists exactly two entries.' }
            @{ Name = 'the with a digit cardinal'; Line = 'Each of the 24 PreToolUse hooks has a guard.' }
            @{ Name = 'the with a word cardinal'; Line = 'None of the nine Python files invokes Python.' }
            @{ Name = 'these with a digit cardinal'; Line = 'These 3 suites pass.' }
            @{ Name = 'these with a word cardinal'; Line = 'These three suites pass.' }
            @{ Name = 'those with a digit cardinal'; Line = 'Those 4 mirrors are byte-identical.' }
            @{ Name = 'those with a word cardinal'; Line = 'Those four mirrors are byte-identical.' }
        ) {
            # Arrange
            $specContent = "## Acceptance Criteria`n- [ ] " + $Line
            # Act
            $result = Test-SpecNumericCriterion -SpecContent $specContent
            # Assert
            $result | Should -BeTrue -Because "R2 must trigger on: $Line"
        }

        It 'R2 does not trigger on <Name>' -ForEach @(
            @{ Name = 'a threshold'; Line = 'Line coverage is at or above 85% for each changed file.' }
            @{ Name = 'a comparator'; Line = 'Repository-wide line coverage is >= 85% after the change.' }
            @{ Name = 'an exit code'; Line = 'The hook exits 2 with a reason on stderr.' }
            @{ Name = 'an issue or PR number'; Line = 'The PR body contains Refs #905 and Refs #897.' }
            @{ Name = 'a line number or file:line'; Line = 'The rule at typescript.md:57 and Pester.psm1:8567-8588 stays unchanged.' }
            @{ Name = 'an AC or task identifier'; Line = 'AC-01, AC-5.4, P1-T2 and E4-ST3 are recorded.' }
            @{ Name = 'a version'; Line = 'The extension requires node >=18.0.0 to run.' }
            @{ Name = 'a date or timestamp'; Line = 'Evidence is written on 2026-10-11 at 2026-10-11T17-00.' }
            @{ Name = 'a section reference'; Line = "The behavior follows research $([char]0x00A7)12." }
            @{ Name = 'zero'; Line = 'PSScriptAnalyzer reports zero findings and 0 errors.' }
            @{ Name = 'a unit of size or duration'; Line = 'No file exceeds the 500 lines limit within the 30 seconds timeout.' }
            @{ Name = 'a count citing .claude/rules/'; Line = 'The four toolchain stages pass per .claude/rules/general-code-change.md.' }
            @{ Name = 'a count citing .github/instructions/'; Line = 'The three rule files under .github/instructions/ stay unchanged.' }
            @{ Name = 'a count citing .github/copilot-instructions.md'; Line = 'The two tone sections of .github/copilot-instructions.md apply.' }
            @{ Name = 'a non-noun word after the cardinal'; Line = 'The value is exactly 2 as documented.' }
        ) {
            # Arrange
            $specContent = "## Acceptance Criteria`n- [ ] " + $Line
            # Act
            $result = Test-SpecNumericCriterion -SpecContent $specContent
            # Assert
            $result | Should -BeFalse -Because "R2 must not trigger on: $Line"
        }
    }

    Context 'Test-NumericDerivationEvidence rule R3 (issue #905)' {
        # Each row replaces only the Exhaustive Search Scope value of the complete evidence record.
        It 'R3 accepts the exhaustive scope <Name>' -ForEach @(
            @{ Name = 'entire worktree'; Value = 'entire worktree.' }
            @{ Name = 'whole worktree with all directories'; Value = 'the whole worktree, all directories.' }
            @{ Name = 'entire repository accepted before R3'; Value = 'entire repository' }
            @{ Name = 'complete source tree'; Value = 'the complete source tree' }
            @{ Name = 'whole repo'; Value = 'the whole repo' }
            @{ Name = 'upper-case entire worktree'; Value = 'ENTIRE WORKTREE' }
            @{ Name = 'entire worktree root'; Value = 'entire worktree root.' }
            @{ Name = 'whole repository excluding docs'; Value = 'the whole repository excluding `docs/`' }
            # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; a whole-worktree value that lists a narrower covered set is accepted.
            @{ Name = 'NB-2 whole worktree restricted to code'; Value = 'the whole worktree with ripgrep, restricted to code by excluding `docs/`; covers `.claude/hooks`, `.claude/lib`, `.codex/hooks`, and both bundle roots.' }
            # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; an entire-repository value with an exclusion is accepted.
            @{ Name = 'NB-2 entire repository excluding docs'; Value = 'entire repository excluding docs/**' }
        ) {
            # Arrange
            $content = (Get-CompleteNumericDerivationEvidence).Replace('- Exhaustive Search Scope: entire repository source tree', '- Exhaustive Search Scope: ' + $Value)
            # Act
            $result = Test-NumericDerivationEvidence -Content $content
            # Assert
            $result.Ok | Should -BeTrue -Because "$($result.Message)"
        }

        It 'R3 rejects the exhaustive scope <Name>' -ForEach @(
            @{ Name = 'the hooks folder'; Value = 'the hooks folder' }
            @{ Name = 'noun without a quantifier'; Value = 'those four files on the current worktree.' }
            @{ Name = 'quantifier without a noun'; Value = 'the whole file, lines 1-335.' }
            @{ Name = 'path-shaped value'; Value = '`.claude/hooks/`' }
            @{ Name = 'all inside allocated'; Value = 'the allocated repository subset' }
            @{ Name = 'tree inside subtree'; Value = 'the entire subtree' }
            @{ Name = 'worktree inside worktrees'; Value = 'the whole worktrees folder' }
        ) {
            # Arrange
            $content = (Get-CompleteNumericDerivationEvidence).Replace('- Exhaustive Search Scope: entire repository source tree', '- Exhaustive Search Scope: ' + $Value)
            # Act
            $result = Test-NumericDerivationEvidence -Content $content
            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Be 'prd-feature hook: numeric derivation evidence does not declare an exhaustive repository search scope.'
        }
    }
}
