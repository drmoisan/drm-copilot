<#
.SYNOPSIS
    Pester tests for .claude/lib/regeneration/RegenerationDelta.psm1 (issue #1156).

.DESCRIPTION
    Exercises the confinement, idempotency, and delta decisions and every builder
    with in-memory values. Field-mapping cases supply a distinct value per
    parameter so a swapped, dropped, or hard-coded field fails. The suite imports
    only RegenerationDelta.psm1, so the confinement and delta cases fail when the
    module's own classifier import is removed. No file, process, or clock is used.
#>

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration/RegenerationDelta.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    $script:Pattern = [string[]] @('gen/**')
    $script:EventArgument = @{
        At = '2026-11-09T22:00:00Z'; Trigger = 'main_sync'; FeatureHeadSha = 'feature-sha'; MergeHeadSha = 'merge-sha'
        MergeBaseSha = 'base-sha'; Decision = 'decision-x'; Reason = 'reason-x'; UnmatchedPaths = @('u/one.json')
        CommandExitCode = 7; Confined = $true; Idempotent = $false; UnitGate = 'fail'; DeltaCheck = 'pass'
        Outcome = 'regenerated'; HeadSha = 'head-sha'; EvidencePath = 'ev/path.md'
    }
    $script:EntryArgument = @{
        Trigger = 'post_feature_merge'; AfterFeatureIssueNum = 1156; MergeCommitSha = 'merge-commit'
        RegenerationCommitSha = 'regen-commit'; CommandExitCode = 4; Confined = $false; Idempotent = $true
        Outcome = 'applied'; CiRunId = 9001; CiConclusion = 'success'; VerifiedAt = '2026-11-09T23:00:00Z'
    }

    function Get-SortedKeyList {
        param([System.Collections.IDictionary] $Map)
        return (@($Map.Keys | Sort-Object -CaseSensitive) -join ',')
    }
}

AfterAll {
    Remove-Module -Name RegenerationDelta, RegenerationClassifier -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\Get-SortedKeyList -ErrorAction SilentlyContinue
}

Describe 'Get-RegenerationConfinementDecision' {
    It 'returns true when every changed path matches a declared pattern' {
        Get-RegenerationConfinementDecision -ChangedPath @('gen/a.json', 'gen/b/c.json') -Pattern $script:Pattern | Should -BeTrue
    }

    It 'returns false when a changed path matches no declared pattern' {
        Get-RegenerationConfinementDecision -ChangedPath @('gen/a.json', 'src/x.ps1') -Pattern $script:Pattern | Should -BeFalse
    }
}

Describe 'Get-RegenerationIdempotencyDecision' {
    It 'Merge: returns true for an empty C2 and a check that exited 0' {
        Get-RegenerationIdempotencyDecision -SecondRunChange @() -CheckExitCode 0 | Should -BeTrue
    }

    It 'Merge: returns true for an empty C2 and no declared check' {
        Get-RegenerationIdempotencyDecision -SecondRunChange @() -CheckExitCode $null | Should -BeTrue
    }

    It 'Merge: returns false for a non-empty C2' {
        Get-RegenerationIdempotencyDecision -SecondRunChange @('gen/a.json') -CheckExitCode $null | Should -BeFalse
    }

    It 'Merge: returns false for a non-zero check exit' {
        Get-RegenerationIdempotencyDecision -SecondRunChange @() -CheckExitCode 2 | Should -BeFalse
    }

    It 'Tip: returns true when the snapshot after run 2 equals the run-1 snapshot' {
        Get-RegenerationIdempotencyDecision -FirstSnapshot @{ 'gen/a' = 'b1' } -SecondSnapshot @{ 'gen/a' = 'b1' } -CheckExitCode $null | Should -BeTrue
    }

    It 'Tip: returns false when run 2 adds a path' {
        Get-RegenerationIdempotencyDecision -FirstSnapshot @{ 'gen/a' = 'b1' } -SecondSnapshot @{ 'gen/a' = 'b1'; 'gen/b' = 'b2' } -CheckExitCode $null | Should -BeFalse
    }

    It 'Tip: returns false when a blob id changes' {
        Get-RegenerationIdempotencyDecision -FirstSnapshot @{ 'gen/a' = 'b1' } -SecondSnapshot @{ 'gen/a' = 'b9' } -CheckExitCode $null | Should -BeFalse
    }

    It 'Tip: returns false when a path is replaced by another' {
        Get-RegenerationIdempotencyDecision -FirstSnapshot @{ 'gen/a' = 'b1' } -SecondSnapshot @{ 'gen/z' = 'b1' } -CheckExitCode $null | Should -BeFalse
    }

    It 'Tip: returns false for a non-zero check exit with equal snapshots' {
        Get-RegenerationIdempotencyDecision -FirstSnapshot @{} -SecondSnapshot @{} -CheckExitCode 1 | Should -BeFalse
    }
}

Describe 'Get-RegenerationDeltaDecision' {
    It 'returns pass when each non-generated path is in the other parent diff from the base' {
        $result = Get-RegenerationDeltaDecision -StagedAgainstFeatureHead @('src/theirs.ps1') -StagedAgainstIncomingTip @('src/ours.ps1') -BaseToFeatureHead @('src/ours.ps1') -BaseToIncomingTip @('src/theirs.ps1') -Pattern $script:Pattern
        $result | Should -BeExactly 'pass'
    }

    It 'returns fail for a violation against the feature head' {
        $result = Get-RegenerationDeltaDecision -StagedAgainstFeatureHead @('src/stray.ps1') -StagedAgainstIncomingTip @() -BaseToFeatureHead @() -BaseToIncomingTip @('src/theirs.ps1') -Pattern $script:Pattern
        $result | Should -BeExactly 'fail'
    }

    It 'returns fail for a violation against the incoming tip' {
        $result = Get-RegenerationDeltaDecision -StagedAgainstFeatureHead @() -StagedAgainstIncomingTip @('src/stray.ps1') -BaseToFeatureHead @('src/ours.ps1') -BaseToIncomingTip @() -Pattern $script:Pattern
        $result | Should -BeExactly 'fail'
    }

    It 'returns pass when a generated path changed against both parents' {
        $result = Get-RegenerationDeltaDecision -StagedAgainstFeatureHead @('gen/lock.json') -StagedAgainstIncomingTip @('gen/lock.json') -BaseToFeatureHead @() -BaseToIncomingTip @() -Pattern $script:Pattern
        $result | Should -BeExactly 'pass'
    }
}

Describe 'New-RegenerationEvent' {
    It 'carries the fourteen top-level keys and the three classifier keys' {
        $regenerationEvent = New-RegenerationEvent @script:EventArgument
        Get-SortedKeyList -Map $regenerationEvent | Should -BeExactly 'at,classifier,command_exit_code,confined,delta_check,evidence_path,feature_head_sha,head_sha,idempotent,merge_base_sha,merge_head_sha,outcome,trigger,unit_gate'
        Get-SortedKeyList -Map $regenerationEvent['classifier'] | Should -BeExactly 'decision,reason,unmatched_paths'
    }

    It 'maps every key from the parameter of the same name' {
        $regenerationEvent = New-RegenerationEvent @script:EventArgument
        $regenerationEvent['at'] | Should -BeExactly '2026-11-09T22:00:00Z'
        $regenerationEvent['trigger'] | Should -BeExactly 'main_sync'
        $regenerationEvent['feature_head_sha'] | Should -BeExactly 'feature-sha'
        $regenerationEvent['merge_head_sha'] | Should -BeExactly 'merge-sha'
        $regenerationEvent['merge_base_sha'] | Should -BeExactly 'base-sha'
        $regenerationEvent['classifier']['decision'] | Should -BeExactly 'decision-x'
        $regenerationEvent['classifier']['reason'] | Should -BeExactly 'reason-x'
        $regenerationEvent['classifier']['unmatched_paths'] -is [array] | Should -BeTrue
        $regenerationEvent['classifier']['unmatched_paths'].Count | Should -Be 1
        $regenerationEvent['classifier']['unmatched_paths'][0] | Should -BeExactly 'u/one.json'
        $regenerationEvent['command_exit_code'] | Should -Be 7
        $regenerationEvent['confined'] | Should -BeOfType [bool]
        $regenerationEvent['confined'] | Should -BeTrue
        $regenerationEvent['idempotent'] | Should -BeOfType [bool]
        $regenerationEvent['idempotent'] | Should -BeFalse
        $regenerationEvent['unit_gate'] | Should -BeExactly 'fail'
        $regenerationEvent['delta_check'] | Should -BeExactly 'pass'
        $regenerationEvent['outcome'] | Should -BeExactly 'regenerated'
        $regenerationEvent['head_sha'] | Should -BeExactly 'head-sha'
        $regenerationEvent['evidence_path'] | Should -BeExactly 'ev/path.md'
    }

    It 'renders the injected at value through the ISO-8601 UTC converter' {
        $at = ConvertTo-RegenerationIsoUtc -Value ([datetime]::new(2026, 11, 9, 22, 0, 0, [System.DateTimeKind]::Utc))
        $argument = $script:EventArgument.Clone(); $argument.At = $at
        (New-RegenerationEvent @argument)['at'] | Should -BeExactly '2026-11-09T22:00:00Z'
    }

    It 'sets head_sha to null for a fell_back event' {
        $argument = $script:EventArgument.Clone(); $argument.Outcome = 'fell_back'
        $regenerationEvent = New-RegenerationEvent @argument
        $regenerationEvent.Contains('head_sha') | Should -BeTrue
        $regenerationEvent['head_sha'] | Should -BeNullOrEmpty
    }

    It 'keeps head_sha and evidence_path present with null values when both are null' {
        $argument = $script:EventArgument.Clone(); $argument.HeadSha = $null; $argument.EvidencePath = $null
        $json = (New-RegenerationEvent @argument) | ConvertTo-Json -Depth 5 -Compress
        $json | Should -Match '"head_sha":null'
        $json | Should -Match '"evidence_path":null'
    }

    It 'throws for a rejected <Name> value' -ForEach @(
        @{ Name = 'trigger'; Key = 'Trigger' }
        @{ Name = 'outcome'; Key = 'Outcome' }
        @{ Name = 'unit_gate'; Key = 'UnitGate' }
        @{ Name = 'delta_check'; Key = 'DeltaCheck' }
    ) {
        $argument = $script:EventArgument.Clone(); $argument[$Key] = 'bogus'
        { New-RegenerationEvent @argument } | Should -Throw "*$Name 'bogus'*"
    }
}

Describe 'New-RegenerationDeltaReviewOutcome' {
    It 'carries the five keys with the constant verdict, findings, and review_kind' {
        $outcome = New-RegenerationDeltaReviewOutcome -HeadSha 'head-sha' -EvidencePath 'ev/path.md'
        Get-SortedKeyList -Map $outcome | Should -BeExactly 'evidence_path,findings,head_sha,review_kind,verdict'
        $outcome['head_sha'] | Should -BeExactly 'head-sha'
        $outcome['evidence_path'] | Should -BeExactly 'ev/path.md'
        $outcome['verdict'] | Should -BeExactly 'PASS'
        $outcome['review_kind'] | Should -BeExactly 'regeneration_delta'
        $null -ne $outcome['findings'] | Should -BeTrue
        $outcome['findings'].Count | Should -Be 0
    }

    It 'keeps head_sha and evidence_path present with null values when both are null' {
        $json = (New-RegenerationDeltaReviewOutcome -HeadSha $null -EvidencePath $null) | ConvertTo-Json -Depth 5 -Compress
        $json | Should -BeExactly '{"verdict":"PASS","findings":[],"head_sha":null,"review_kind":"regeneration_delta","evidence_path":null}'
    }
}

Describe 'New-IntegrationRegenerationEntry' {
    It 'carries the eleven keys, each from the parameter of the same name' {
        $entry = New-IntegrationRegenerationEntry @script:EntryArgument
        Get-SortedKeyList -Map $entry | Should -BeExactly 'after_feature_issue_num,ci_conclusion,ci_run_id,command_exit_code,confined,idempotent,merge_commit_sha,outcome,regeneration_commit_sha,trigger,verified_at'
        $entry['trigger'] | Should -BeExactly 'post_feature_merge'
        $entry['after_feature_issue_num'] | Should -Be 1156
        $entry['merge_commit_sha'] | Should -BeExactly 'merge-commit'
        $entry['regeneration_commit_sha'] | Should -BeExactly 'regen-commit'
        $entry['command_exit_code'] | Should -Be 4
        $entry['confined'] | Should -BeFalse
        $entry['idempotent'] | Should -BeTrue
        $entry['outcome'] | Should -BeExactly 'applied'
        $entry['ci_run_id'] | Should -Be 9001
        $entry['ci_conclusion'] | Should -BeExactly 'success'
        $entry['verified_at'] | Should -BeExactly '2026-11-09T23:00:00Z'
    }

    It 'sets after_feature_issue_num to null for main_sync' {
        $argument = $script:EntryArgument.Clone(); $argument.Trigger = 'main_sync'
        (New-IntegrationRegenerationEntry @argument)['after_feature_issue_num'] | Should -BeNullOrEmpty
    }

    It 'keeps regeneration_commit_sha null when no diff was committed' {
        $argument = $script:EntryArgument.Clone(); $argument.RegenerationCommitSha = $null
        ((New-IntegrationRegenerationEntry @argument) | ConvertTo-Json -Compress) | Should -Match '"regeneration_commit_sha":null'
    }

    It 'throws for a rejected <Name> value' -ForEach @(
        @{ Name = 'trigger'; Key = 'Trigger' }
        @{ Name = 'outcome'; Key = 'Outcome' }
    ) {
        $argument = $script:EntryArgument.Clone(); $argument[$Key] = 'integration_sync'
        { New-IntegrationRegenerationEntry @argument } | Should -Throw "*$Name 'integration_sync'*"
    }
}

Describe 'New-RegenerationEvidenceText' {
    It 'maps every field distinctly into the five LF-terminated lines' {
        $text = New-RegenerationEvidenceText -Timestamp '2026-11-10T01-02' -Command 'cmd-x' -ExitCode 5 -Reason 'reason-x' -Confined $true -Idempotent $false -UnitGate 'fail' -DeltaCheck 'not_run'
        $text | Should -BeExactly ("# Regeneration Delta`nTimestamp: 2026-11-10T01-02`nCommand: cmd-x`nEXIT_CODE: 5`nOutput Summary: reason=reason-x; confined=true; idempotent=false; unit_gate=fail; delta_check=not_run`n")
    }

    It 'builds the D18 text for a Merge result without a ConfigPath suffix' {
        $command = Get-RegenerationInvocationText -MergeRef 'origin/main' -Trigger 'main_sync' -ConfigPath $null
        $text = New-RegenerationEvidenceText -Timestamp '2026-11-09T22-00' -Command $command -ExitCode 0 -Reason 'all_match' -Confined $true -Idempotent $true -UnitGate 'not_run' -DeltaCheck 'pass'
        $text | Should -BeExactly ("# Regeneration Delta`nTimestamp: 2026-11-09T22-00`nCommand: pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef origin/main -Trigger main_sync`nEXIT_CODE: 0`nOutput Summary: reason=all_match; confined=true; idempotent=true; unit_gate=not_run; delta_check=pass`n")
        $text | Should -Not -Match '[A-Za-z]:[\\/]'
        $text | Should -Not -Match '(^|\s)/[A-Za-z]'
    }

    It 'builds the text with the ConfigPath suffix when ConfigPath is supplied' {
        $command = Get-RegenerationInvocationText -MergeRef 'origin/main' -Trigger 'main_sync' -ConfigPath 'config/alt.json'
        $text = New-RegenerationEvidenceText -Timestamp '2026-11-09T22-00' -Command $command -ExitCode 0 -Reason 'all_match' -Confined $true -Idempotent $true -UnitGate 'not_run' -DeltaCheck 'pass'
        ($text -split "`n")[2] | Should -BeExactly 'Command: pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef origin/main -Trigger main_sync -ConfigPath config/alt.json'
    }
}

Describe 'Get-RegenerationInvocationText' {
    It 'maps MergeRef, Trigger, and ConfigPath into the invocation text' {
        Get-RegenerationInvocationText -MergeRef 'origin/epic/x' -Trigger 'integration_sync' -ConfigPath 'config/alt.json' |
            Should -BeExactly 'pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef origin/epic/x -Trigger integration_sync -ConfigPath config/alt.json'
    }
}

Describe 'Clock and path converters' {
    It 'renders one fixed UTC value in the at and stamp shapes' {
        $value = [datetime]::new(2026, 11, 9, 22, 0, 0, [System.DateTimeKind]::Utc)
        ConvertTo-RegenerationIsoUtc -Value $value | Should -BeExactly '2026-11-09T22:00:00Z'
        ConvertTo-RegenerationStamp -Value $value | Should -BeExactly '2026-11-09T22-00'
    }

    It 'returns the feature-relative evidence path for a valid stamp' {
        Get-RegenerationEvidencePath -FeatureFolder 'docs/features/active/x-1' -Timestamp '2026-11-09T22-00' |
            Should -BeExactly 'docs/features/active/x-1/evidence/qa-gates/regeneration-delta.2026-11-09T22-00.md'
    }

    It 'throws for a timestamp outside the yyyy-MM-ddTHH-mm shape' {
        { Get-RegenerationEvidencePath -FeatureFolder 'docs/features/active/x-1' -Timestamp '2026-11-09T22:00' } | Should -Throw
    }
}
