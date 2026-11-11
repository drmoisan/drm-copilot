#Requires -Version 7.0

<#
.SYNOPSIS
    Grammar, decision-rule, path, pending-set, agent-id, and ledger-append tests for
    OrchestratorStateOwnerDirectiveDecision.psm1 (issue #1157).

.DESCRIPTION
    Every case passes in-memory text and a fixed -Now. No test writes a file, reads a clock, or
    starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1'
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    Import-Module $script:ModulePath -Force -ErrorAction Stop
    $script:Now = [datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc)
    $script:Reason = 'The owner asked for parallel execution of the items.'

    function Get-DecisionTestDirective {
        param([string] $Class = 'scheduling', [bool] $Refused = $false, [string] $Expires = '2026-11-11T12:00:00Z')
        return [pscustomobject]@{ Id = 'OD-1'; Class = $Class; IsRefusedClass = $Refused; ExpiresAt = $Expires }
    }

    function Get-DecisionTestError {
        param([string] $Line, [object] $Directive = (Get-DecisionTestDirective))
        return @(Test-OwnerDirectiveDecision -Decision (ConvertFrom-OwnerDirectiveDecisionLine -Line $Line) -Directive $Directive -Now $script:Now)
    }

    function Get-DecisionTestLedgerLine {
        param([string] $Id = 'OD-1', [string] $Text = 'Run the items in parallel.')
        $digest = [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.UTF8Encoding]::new($false).GetBytes($Text))).ToLowerInvariant()
        return ([ordered]@{
                id = $Id; text = $Text; text_sha256 = $digest; class = 'scheduling'; recorded_at = '2026-11-01T00:00:00Z'; expires_at = '2026-11-11T00:00:00Z'
                scope = [ordered]@{ issue = 1157; branch = 'feature/owner-directive-pass-down-1157'; step = 'any' }; issued_by_session = 'session-1157'
            } | ConvertTo-Json -Compress -Depth 4)
    }
}

Describe 'ConvertFrom-OwnerDirectiveDecisionLine (AC-16)' {
    It 'parses a line matching the anchored grammar' {
        $decision = ConvertFrom-OwnerDirectiveDecisionLine -Line ('OWNER-DIRECTIVE-DECISION: OD-12 | scheduling | honored | 2026-11-10T11:00:00Z | ' + $script:Reason)
        $decision.Id | Should -BeExactly 'OD-12'
        $decision.Class | Should -BeExactly 'scheduling'
        $decision.Outcome | Should -BeExactly 'honored'
        $decision.DecidedAt | Should -BeExactly '2026-11-10T11:00:00Z'
        $decision.Reason | Should -BeExactly $script:Reason
    }

    It 'accepts - as decided_at and keeps | inside the reason' {
        $decision = ConvertFrom-OwnerDirectiveDecisionLine -Line 'OWNER-DIRECTIVE-DECISION: OD-1 | gate_bypass | refused | - | refused: a | b | c are all gates'
        $decision.DecidedAt | Should -BeExactly '-'
        $decision.Reason | Should -BeExactly 'refused: a | b | c are all gates'
    }

    It 'rejects <Case>' -ForEach @(
        @{ Case = 'a missing field'; Line = 'OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-10T11:00:00Z' }
        @{ Case = 'an id outside OD-<positive integer>'; Line = 'OWNER-DIRECTIVE-DECISION: OD-0 | scheduling | honored | - | The reason is long enough here.' }
        @{ Case = 'an outcome other than honored or refused'; Line = 'OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | accepted | - | The reason is long enough here.' }
        @{ Case = 'leading text'; Line = 'Decision: OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | The reason is long enough here.' }
        @{ Case = 'trailing text after a line break'; Line = "OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | The reason is long enough here.`nextra" }
        @{ Case = 'a lower-case keyword'; Line = 'owner-directive-decision: OD-1 | scheduling | honored | - | The reason is long enough here.' }
    ) {
        ConvertFrom-OwnerDirectiveDecisionLine -Line $Line | Should -BeNullOrEmpty
    }
}

Describe 'Test-OwnerDirectiveDecision (AC-17)' {
    It 'accepts a valid honored decision' {
        Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-10T11:00:00Z | ' + $script:Reason) | Should -BeNullOrEmpty
    }

    It 'rejects a class that differs from the directive class (R4)' {
        $errors = Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | merge_timing | honored | - | ' + $script:Reason)
        $errors | Should -Be @('R4: class merge_timing does not match directive OD-1 class scheduling.')
    }

    It 'rejects honored for refused class <Class> (R6) and accepts refused' -ForEach @(
        @{ Class = 'gate_bypass' }, @{ Class = 'force_push' }, @{ Class = 'tag_or_publish' }
        @{ Class = 'policy_or_settings_edit' }, @{ Class = 'evidence_alteration' }, @{ Class = 'unclassified' }
    ) {
        $directive = Get-DecisionTestDirective -Class $Class -Refused $true
        $errors = Get-DecisionTestError -Directive $directive -Line ("OWNER-DIRECTIVE-DECISION: OD-1 | $Class | honored | - | " + $script:Reason)
        $errors | Should -Be @("R6: directive OD-1 of refused class $Class accepts only refused.")
        Get-DecisionTestError -Directive $directive -Line ("OWNER-DIRECTIVE-DECISION: OD-1 | $Class | refused | - | " + $script:Reason) | Should -BeNullOrEmpty
    }

    It 'rejects an honored decision later than expires_at (R10)' {
        $errors = Get-DecisionTestError -Directive (Get-DecisionTestDirective -Expires '2026-11-10T10:00:00Z') -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-10T11:00:00Z | ' + $script:Reason)
        $errors | Should -Be @('R10: an honored decision at 2026-11-10T11:00:00Z is later than expires_at 2026-11-10T10:00:00Z of directive OD-1.')
    }

    It 'rejects decided_at later than Now' {
        $errors = Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | refused | 2026-11-10T12:00:01Z | ' + $script:Reason)
        $errors | Should -Be @('decided_at 2026-11-10T12:00:01Z is later than the hook clock 2026-11-10T12:00:00Z.')
    }

    It 'rejects a decided_at that is not a date-time' {
        $errors = Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | refused | yesterday | ' + $script:Reason)
        $errors | Should -Be @('decided_at yesterday must be an ISO 8601 UTC date-time or -.')
    }

    It 'rejects a reason of 19 characters after trimming and accepts 20 (R8)' {
        $short = '  ' + ('r' * 19) + '  '
        Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | ' + $short) | Should -Be @('R8: the reason must be at least 20 characters after trimming.')
        Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | ' + ('r' * 20) + '  ') | Should -BeNullOrEmpty
    }

    It 'rejects an unparseable line and a decision for another id' {
        Get-DecisionTestError -Line 'not a decision' | Should -Be @('the decision line does not match OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason>.')
        Get-DecisionTestError -Line ('OWNER-DIRECTIVE-DECISION: OD-2 | scheduling | honored | - | ' + $script:Reason) | Should -Be @('the decision names OD-2 but answers directive OD-1.')
    }
}

Describe 'Decision path, pending set, and agent id' {
    It 'composes the decision path beneath the item root' {
        $path = (Get-OwnerDirectiveDecisionPath -ItemRoot '/synthetic-worktrees/item-1157' -AgentId 'a1b2' -Id 'OD-3').Replace('\', '/')
        $path | Should -BeExactly '/synthetic-worktrees/item-1157/artifacts/orchestration/owner-directive-decisions/a1b2/OD-3.md'
    }

    It 'returns the selected entries without a decision file' {
        $selected = @([pscustomobject]@{ Id = 'OD-1' }, [pscustomobject]@{ Id = 'OD-2' })
        @(Get-OwnerDirectivePendingSet -Selected $selected -ExistingDecisionId @('OD-1') | ForEach-Object Id) | Should -Be @('OD-2')
        @(Get-OwnerDirectivePendingSet -Selected $selected -ExistingDecisionId @()).Count | Should -Be 2
    }

    It 'agent id <AgentId> is valid: <Expected>' -ForEach @(
        @{ AgentId = 'a0c7bd4da3f16ed71'; Expected = $true }, @{ AgentId = 'agent.1_x-2'; Expected = $true }
        @{ AgentId = '-leading'; Expected = $false }, @{ AgentId = 'a/b'; Expected = $false }
        @{ AgentId = '..'; Expected = $false }, @{ AgentId = ''; Expected = $false }
    ) {
        Test-OwnerDirectiveAgentId -AgentId $AgentId | Should -Be $Expected
    }
}

Describe 'Test-OwnerDirectiveLedgerAppend (pure part of AC-27)' {
    It 'accepts a first write and an append that keeps the existing lines as a prefix' {
        $first = Get-DecisionTestLedgerLine
        Test-OwnerDirectiveLedgerAppend -ExistingText $null -NewText ($first + "`n") | Should -BeNullOrEmpty
        Test-OwnerDirectiveLedgerAppend -ExistingText ($first + "`r`n") -NewText ($first + "`n" + (Get-DecisionTestLedgerLine -Id 'OD-2') + "`n") | Should -BeNullOrEmpty
    }

    It 'rejects a write that changes an existing line' {
        $errors = Test-OwnerDirectiveLedgerAppend -ExistingText (Get-DecisionTestLedgerLine) -NewText (Get-DecisionTestLedgerLine -Text 'Changed text.')
        $errors | Should -Be @('the write changes existing ledger line #1.')
    }

    It 'rejects a write that removes an existing line' {
        $existing = (Get-DecisionTestLedgerLine) + "`n" + (Get-DecisionTestLedgerLine -Id 'OD-2')
        $errors = Test-OwnerDirectiveLedgerAppend -ExistingText $existing -NewText (Get-DecisionTestLedgerLine)
        $errors | Should -Be @('the write removes existing ledger lines: 1 lines remain of 2.')
    }

    It 'rejects an appended line that fails a B rule and ignores errors of existing lines' {
        $existing = '{broken'
        $errors = Test-OwnerDirectiveLedgerAppend -ExistingText $existing -NewText ($existing + "`n" + (Get-DecisionTestLedgerLine -Id 'OD-x'))
        $errors | Should -Be @('Ledger line #2 id must match OD-<positive integer>.')
    }

    It 'rejects an appended line that duplicates an existing id' {
        $first = Get-DecisionTestLedgerLine
        $errors = Test-OwnerDirectiveLedgerAppend -ExistingText $first -NewText ($first + "`n" + $first)
        $errors | Should -Be @('Ledger line #2 id OD-1 is duplicated.')
    }
}

Describe 'OrchestratorStateOwnerDirectiveDecision purity (AC-9)' {
    It 'the module text references no clock, file, or process command' {
        $text = Get-Content -Raw -LiteralPath $script:ModulePath
        foreach ($forbidden in @('Get-Date', '[DateTime]::Now', '[DateTime]::UtcNow', 'Get-Content', 'Test-Path', ('Start-' + 'Process'), '& git')) {
            $text.Contains($forbidden, [System.StringComparison]::OrdinalIgnoreCase) | Should -BeFalse -Because "the module must not reference $forbidden"
        }
    }

    It 'every time-dependent function declares -Now' {
        (Get-Command -Name 'Test-OwnerDirectiveDecision' -Module 'OrchestratorStateOwnerDirectiveDecision').Parameters.ContainsKey('Now') | Should -BeTrue
    }
}
