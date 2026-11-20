#Requires -Version 7.0
# Repository gate for hook parity (issue #1030): loads the committed config/harness-parity-matrix.json through
# Import-HarnessParityMatrix and applies the H1 to H5 rules of scripts/harness/HarnessHookParity.psm1 with the
# deferred stem set and decision reference of the issue #1030 plan. Read-only; the negative cases are in memory.

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessParityMatrix.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessHookParity.psm1') -Force
    $script:Matrix = Import-HarnessParityMatrix -Path (Join-Path $script:RepoRoot 'config/harness-parity-matrix.json')
    $script:Hooks = @($script:Matrix.features | Where-Object { $_.kind -ceq 'hook-registration' })
    $script:DecisionRef = '#1030:hook-parity-dispositions.md'
    $script:DeferStem = @(
        'enforce-prd-feature-before-planner', 'enforce-mermaid-validation', 'enforce-pr-author-skill', 'validate-orchestrator-output',
        'validate-planner-output', 'validate-task-researcher-output', 'validate-executor-output', 'validate-prd-feature-output',
        'validate-required-artifact-output', 'enforce-feature-folder-order', 'enforce-pr-author-command-allowlist'
    )

    function Get-HookByStem {
        # Returns the hook-registration entries of one ecosystem whose name ends with the given stem.
        param([string] $Ecosystem, [string] $Stem)
        @($script:Hooks | Where-Object { $_.ecosystem -ceq $Ecosystem -and (Get-HarnessHookRegistrationStem -Entry $_) -ceq $Stem })
    }

    function Get-NotesText {
        # Returns the notes of an entry, or an empty string when the entry has none.
        param($Entry)
        if (@($Entry.PSObject.Properties.Name) -contains 'notes') { [string]$Entry.notes } else { '' }
    }
}

AfterAll {
    Remove-Module HarnessHookParity, HarnessParityMatrix, HarnessInventory -Force -ErrorAction SilentlyContinue
}

Describe 'Hook parity repository gate' {
    It 'reports no H1 to H5 violation on the committed matrix' {
        $violations = @(Get-HarnessHookParityViolation -Entry $script:Hooks -DeferStem $script:DeferStem -DecisionRef $script:DecisionRef)
        $violations.Count | Should -Be 0 -Because ("violations:`n" + (@($violations.Message) -join "`n"))
    }

    It 'records C1 as NOT-EXPRESSIBLE naming issue 555' {
        $entries = @($script:Hooks | Where-Object { $_.ecosystem -ceq 'claude' -and $_.source_path -ceq '.claude/hooks/pretooluse-dispatch.json' -and $_.name -ceq 'PreToolUse/Agent/enforce-orchestration-preimplementation-gate' })
        $entries.Count | Should -Be 1
        $gap = Get-HarnessHookGapClass -Entry $entries[0]
        $gap.Class | Should -BeExactly 'NOT-EXPRESSIBLE'
        $gap.Reason.Contains('#555', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'records C2 as DEFER naming agent_type' {
        $entries = @(Get-HookByStem -Ecosystem 'claude' -Stem 'enforce-pr-author-command-allowlist')
        $entries.Count | Should -BeGreaterThan 0
        foreach ($entry in $entries) {
            $gap = Get-HarnessHookGapClass -Entry $entry
            $gap.Class | Should -BeExactly 'DEFER'
            $gap.Reason.Contains('agent_type', [System.StringComparison]::Ordinal) | Should -BeTrue
        }
    }

    It 'records DEFER on every claude entry of the deferred stem <Stem>' -ForEach @(
        @{ Stem = 'enforce-prd-feature-before-planner' }, @{ Stem = 'enforce-mermaid-validation' }, @{ Stem = 'enforce-pr-author-skill' }
        @{ Stem = 'validate-orchestrator-output' }, @{ Stem = 'validate-planner-output' }, @{ Stem = 'validate-task-researcher-output' }
        @{ Stem = 'validate-executor-output' }, @{ Stem = 'validate-prd-feature-output' }, @{ Stem = 'validate-required-artifact-output' }
        @{ Stem = 'enforce-feature-folder-order' }, @{ Stem = 'enforce-pr-author-command-allowlist' }
    ) {
        $entries = @(Get-HookByStem -Ecosystem 'claude' -Stem $Stem)
        $entries.Count | Should -BeGreaterThan 0
        foreach ($entry in $entries) { (Get-HarnessHookGapClass -Entry $entry).Class | Should -BeExactly 'DEFER' }
    }

    It 'names the claude lib module and child 4 in each non-C2 DEFER reason' {
        $entries = @($script:Hooks | Where-Object { $_.ecosystem -ceq 'claude' -and $script:DeferStem -ccontains (Get-HarnessHookRegistrationStem -Entry $_) -and (Get-HarnessHookRegistrationStem -Entry $_) -cne 'enforce-pr-author-command-allowlist' })
        $entries.Count | Should -BeGreaterThan 0
        foreach ($entry in $entries) {
            $reason = (Get-HarnessHookGapClass -Entry $entry).Reason
            $reason.Contains('.claude/lib/', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $entry.name
            $reason.Contains('child 4', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $entry.name
        }
    }

    It 'records the feature-folder-order port as deferred' {
        $members = @($script:Hooks | Where-Object { $_.parity_group -ceq 'hook:enforce-feature-folder-order' })
        @($members | Where-Object { $_.ecosystem -ceq 'claude' }).Count | Should -BeGreaterThan 0
        @($members | Where-Object { $_.ecosystem -ceq 'codex' }).Count | Should -Be 0
        foreach ($entry in @($members | Where-Object { $_.ecosystem -ceq 'claude' })) {
            $notes = Get-NotesText -Entry $entry
            $notes.StartsWith('GAP:DEFER: ', [System.StringComparison]::Ordinal) | Should -BeTrue
            $notes.Contains('.claude/lib/development-docs/DevelopmentDocsRoot.psm1', [System.StringComparison]::Ordinal) | Should -BeTrue
            $notes.Contains('child 4', [System.StringComparison]::Ordinal) | Should -BeTrue
        }
    }

    It 'assigns exactly the listed member stems to <Group>' -ForEach @(
        @{ Group = 'hook:model-routing'; Claude = @('enforce-model-routing-receipt'); Codex = @('enforce-codex-model-routing', 'validate-codex-subagent-routing'); Copilot = @() }
        @{ Group = 'hook:epic-invocation-origin'; Claude = @('enforce-epic-invocation-origin'); Codex = @('authorize-root-epic-invocation', 'enforce-epic-root-invocation'); Copilot = @() }
        @{ Group = 'hook:subagent-start-attestation'; Claude = @('record-discovery-agent-start'); Codex = @('record-subagent-routing-attestation'); Copilot = @('discovery-agent-start') }
        @{ Group = 'hook:discovery-stop'; Claude = @('validate-discovery-artifact-gate'); Codex = @('validate-discovery-agent-output'); Copilot = @('discovery-agent-stop') }
    ) {
        $members = @($script:Hooks | Where-Object { $_.parity_group -ceq $Group })
        foreach ($pair in @(@('claude', $Claude), @('codex', $Codex), @('copilot', $Copilot))) {
            $actual = [string[]]@($members | Where-Object { $_.ecosystem -ceq $pair[0] } | ForEach-Object { Get-HarnessHookRegistrationStem -Entry $_ } | Sort-Object -Unique)
            $expected = [string[]]@($pair[1] | Sort-Object)
            ($actual -join '|') | Should -BeExactly ($expected -join '|') -Because "$Group $($pair[0]) members"
        }
        $listed = @($Claude) + @($Codex) + @($Copilot)
        $elsewhere = @($script:Hooks | Where-Object { $_.parity_group -cne $Group -and $listed -ccontains (Get-HarnessHookRegistrationStem -Entry $_) })
        $elsewhere.Count | Should -Be 0 -Because 'a listed stem belongs to exactly one group'
    }

    It 'records the cd-chained divergence on every validate-bash entry' {
        foreach ($ecosystem in @('claude', 'codex')) {
            $entries = @(Get-HookByStem -Ecosystem $ecosystem -Stem 'validate-bash')
            $entries.Count | Should -BeGreaterThan 0
            foreach ($entry in $entries) { (Get-NotesText -Entry $entry).Contains('cd-chained', [System.StringComparison]::Ordinal) | Should -BeTrue }
        }
    }

    It 'records the payload-anomaly divergence on every enforce-evidence-locations entry' {
        foreach ($ecosystem in @('claude', 'codex')) {
            $entries = @(Get-HookByStem -Ecosystem $ecosystem -Stem 'enforce-evidence-locations')
            $entries.Count | Should -BeGreaterThan 0
            foreach ($entry in $entries) {
                $notes = Get-NotesText -Entry $entry
                $notes.Contains('payload-anomaly', [System.StringComparison]::Ordinal) | Should -BeTrue
                $notes.Contains('skill-pointer', [System.StringComparison]::Ordinal) | Should -BeTrue
            }
        }
    }

    It 'records the one-continuation rule on the Codex validate-pr-author-output entry' {
        $entries = @(Get-HookByStem -Ecosystem 'codex' -Stem 'validate-pr-author-output')
        $entries.Count | Should -Be 1
        (Get-NotesText -Entry $entries[0]).Contains('one-continuation', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'records every Copilot entry as native with owner_child 6' {
        $entries = @($script:Hooks | Where-Object { $_.ecosystem -ceq 'copilot' })
        $entries.Count | Should -BeGreaterThan 0
        foreach ($entry in $entries) {
            $entry.disposition | Should -BeExactly 'native'
            $entry.owner_child | Should -Be 6
        }
    }

    It 'gives hook:validate-pr-author-output claude and codex members' {
        $members = @($script:Hooks | Where-Object { $_.parity_group -ceq 'hook:validate-pr-author-output' })
        @($members | Where-Object { $_.ecosystem -ceq 'claude' }).Count | Should -BeGreaterThan 0
        @($members | Where-Object { $_.ecosystem -ceq 'codex' }).Count | Should -BeGreaterThan 0
    }

    It 'fails for a Claude group with no Codex member and no gap class' {
        $entry = [pscustomobject]@{ id = 'claude:hook-registration:E/m/neg'; ecosystem = 'claude'; kind = 'hook-registration'; name = 'E/m/neg'; disposition = 'native'; parity_group = 'hook:neg-claude'; decision_status = 'provisional'; decision_ref = $script:DecisionRef; owner_child = 5 }
        @(Get-HarnessHookParityViolation -Entry (@($script:Hooks) + $entry) -DeferStem $script:DeferStem -DecisionRef $script:DecisionRef | ForEach-Object Rule) | Should -Be @('H1')
    }

    It 'fails for an unmatched Codex group with no CODEX-NATIVE note' {
        $entry = [pscustomobject]@{ id = 'codex:hook-registration:E/m/neg'; ecosystem = 'codex'; kind = 'hook-registration'; name = 'E/m/neg'; disposition = 'native'; parity_group = 'hook:neg-codex'; decision_status = 'provisional'; decision_ref = $script:DecisionRef; owner_child = 5 }
        @(Get-HarnessHookParityViolation -Entry (@($script:Hooks) + $entry) -DeferStem $script:DeferStem -DecisionRef $script:DecisionRef | ForEach-Object Rule) | Should -Be @('H2')
    }
}
