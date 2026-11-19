#Requires -Version 7.0
# Unit tests for scripts/harness/HarnessHookParity.psm1 (issue #1030). Every entry is an in-memory object;
# no file is read or written.

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessHookParity.psm1') -Force
    $script:Ref = '#1030:hook-parity-dispositions.md'

    function ConvertTo-HookEntry {
        # Builds one hook-registration entry; a $null Notes value omits the notes property.
        param([string] $Ecosystem, [string] $Name, [string] $Group, [object] $Notes = $null, [string] $Disposition = 'native', [string] $Status = 'provisional', [string] $Ref = '#1030:hook-parity-dispositions.md', [object] $OwnerChild = 5, [string] $Id = '', [string] $Kind = 'hook-registration')
        $entry = [ordered]@{ id = $(if ($Id) { $Id } else { "$Ecosystem`:hook-registration:$Name" }); ecosystem = $Ecosystem; kind = $Kind; name = $Name; source_path = 'x.json'; disposition = $Disposition; parity_group = $Group; consumers = @(); owner_child = $OwnerChild; decision_status = $Status; decision_ref = $Ref }
        if ($null -ne $Notes) { $entry['notes'] = $Notes }
        return [pscustomobject]$entry
    }
}

AfterAll {
    Remove-Module HarnessHookParity -Force -ErrorAction SilentlyContinue
}

Describe 'Get-HarnessHookRegistrationStem' {
    It 'returns the text after the last slash of name' {
        Get-HarnessHookRegistrationStem -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'PreToolUse/Bash/validate-bash' -Group 'hook:validate-bash') | Should -BeExactly 'validate-bash'
    }

    It 'returns the stem when the matcher contains a slash' {
        Get-HarnessHookRegistrationStem -Entry (ConvertTo-HookEntry -Ecosystem codex -Name 'PreToolUse/^(a/b|c)$/enforce-x' -Group 'hook:enforce-x') | Should -BeExactly 'enforce-x'
    }

    It 'derives the stem from name when id is opaque' {
        $entry = ConvertTo-HookEntry -Ecosystem claude -Name 'SubagentStop/atomic-planner/validate-planner-output' -Group 'hook:validate-planner-output' -Id 'entry-opaque-1'
        Get-HarnessHookRegistrationStem -Entry $entry | Should -BeExactly 'validate-planner-output'
    }
}

Describe 'Get-HarnessHookGapClass' {
    It 'returns <Class> for the prefix <Prefix>' -ForEach @(
        @{ Prefix = 'GAP:NOT-APPLICABLE: '; Class = 'NOT-APPLICABLE' }
        @{ Prefix = 'GAP:NOT-EXPRESSIBLE: '; Class = 'NOT-EXPRESSIBLE' }
        @{ Prefix = 'GAP:DEFER: '; Class = 'DEFER' }
        @{ Prefix = 'CODEX-NATIVE: '; Class = 'CODEX-NATIVE' }
    ) {
        $gap = Get-HarnessHookGapClass -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes ($Prefix + 'reason text'))
        $gap.Class | Should -BeExactly $Class
        $gap.Reason | Should -BeExactly 'reason text'
    }

    It 'returns INVALID for an unrecognized GAP class' {
        (Get-HarnessHookGapClass -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes 'GAP:LATER: reason')).Class | Should -BeExactly 'INVALID'
    }

    It 'returns INVALID for an empty reason after a recognized prefix' {
        (Get-HarnessHookGapClass -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes 'GAP:DEFER:    ')).Class | Should -BeExactly 'INVALID'
    }

    It 'returns $null for an unknown prefix' {
        Get-HarnessHookGapClass -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes 'Divergence: text') | Should -BeNullOrEmpty
    }

    It 'returns $null when the entry has no notes' {
        Get-HarnessHookGapClass -Entry (ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s') | Should -BeNullOrEmpty
    }
}

Describe 'Get-HarnessHookParityViolation' {
    It 'H1 passes for a Claude-only group whose member carries a gap class' {
        $entries = @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/only' -Group 'hook:only' -Notes 'GAP:NOT-APPLICABLE: no workflow')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'H1 fails for a Claude-only group whose member carries no gap class' {
        $entries = @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/only' -Group 'hook:only')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H1')
    }

    It 'H1 fails for a Claude-only group whose member carries an INVALID or CODEX-NATIVE note' {
        $entries = @(
            ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/a' -Group 'hook:a' -Notes 'GAP:LATER: x'
            ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/b' -Group 'hook:b' -Notes 'CODEX-NATIVE: x'
        )
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H1', 'H1')
    }

    It 'H2 passes for a Codex-only group with a CODEX-NATIVE note' {
        $entries = @(ConvertTo-HookEntry -Ecosystem codex -Name 'E/m/native' -Group 'hook:native' -Notes 'CODEX-NATIVE: agent allowlist')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'H2 fails for a Codex-only group without a CODEX-NATIVE note' {
        $entries = @(ConvertTo-HookEntry -Ecosystem codex -Name 'E/m/native' -Group 'hook:native' -Notes 'GAP:DEFER: x')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H2')
    }

    It 'H3 passes for a native provisional entry naming the decision reference' {
        $entries = @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes 'GAP:DEFER: x')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'H3 fails for a non-native entry and for a provisional entry with another decision reference' {
        $entries = @(
            ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/s' -Group 'hook:s' -Notes 'GAP:DEFER: x' -Disposition 'shared'
            ConvertTo-HookEntry -Ecosystem codex -Name 'E/m/s' -Group 'hook:s' -Ref '#9:other.md'
        )
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H3', 'H3')
    }

    It 'H3 ignores the decision reference of an approved entry' {
        $entries = @(ConvertTo-HookEntry -Ecosystem codex -Name 'E/m/s' -Group 'hook:s' -Notes 'CODEX-NATIVE: x' -Status 'approved' -Ref '#9:other.md')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'H4 passes for a Copilot entry owned by child 6 and fails for child 5' {
        $pass = @(ConvertTo-HookEntry -Ecosystem copilot -Name 'E//discovery' -Group 'hook:discovery' -OwnerChild 6)
        $fail = @(ConvertTo-HookEntry -Ecosystem copilot -Name 'E//discovery' -Group 'hook:discovery' -OwnerChild 5)
        @(Get-HarnessHookParityViolation -Entry $pass -DecisionRef $script:Ref).Count | Should -Be 0
        @(Get-HarnessHookParityViolation -Entry $fail -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H4')
    }

    It 'H5 passes for a deferred stem carrying DEFER and fails for one carrying NOT-APPLICABLE' {
        $pass = @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/deferred' -Group 'hook:deferred' -Notes 'GAP:DEFER: .claude/lib/x.psm1, child 4')
        $fail = @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/deferred' -Group 'hook:deferred' -Notes 'GAP:NOT-APPLICABLE: x')
        @(Get-HarnessHookParityViolation -Entry $pass -DeferStem 'deferred' -DecisionRef $script:Ref).Count | Should -Be 0
        @(Get-HarnessHookParityViolation -Entry $fail -DeferStem 'deferred' -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H5')
    }

    It 'applies H5 by name when id is opaque' {
        $entries = @(
            ConvertTo-HookEntry -Ecosystem claude -Name 'SubagentStop/atomic-planner/validate-planner-output' -Group 'hook:validate-planner-output' -Id 'entry-opaque-1' -Notes 'GAP:NOT-APPLICABLE: x'
        )
        @(Get-HarnessHookParityViolation -Entry $entries -DeferStem 'validate-planner-output' -DecisionRef $script:Ref | ForEach-Object Rule) | Should -Be @('H5')
    }

    It 'accepts a group with members in all three ecosystems and no notes' {
        $entries = @(
            ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/claude-start' -Group 'hook:start'
            ConvertTo-HookEntry -Ecosystem codex -Name 'E/m/codex-start' -Group 'hook:start'
            ConvertTo-HookEntry -Ecosystem copilot -Name 'E//copilot-start' -Group 'hook:start' -OwnerChild 6
        )
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'ignores entries of other kinds' {
        $entries = @(ConvertTo-HookEntry -Ecosystem claude -Name 'skill-name' -Group 'skill:x' -Kind 'skill' -Disposition 'shared')
        @(Get-HarnessHookParityViolation -Entry $entries -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'returns no violation for an empty entry set' {
        @(Get-HarnessHookParityViolation -Entry @() -DecisionRef $script:Ref).Count | Should -Be 0
    }

    It 'names the rule, the ecosystem and the entry name in each message' {
        $violation = @(Get-HarnessHookParityViolation -Entry @(ConvertTo-HookEntry -Ecosystem claude -Name 'E/m/only' -Group 'hook:only') -DecisionRef $script:Ref)[0]
        $violation.Subject | Should -BeExactly 'E/m/only'
        $violation.Message | Should -BeLike '`[H1`] claude E/m/only: *'
    }
}
