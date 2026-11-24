#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Child CI opt-out rows for the Codex copy of enforce-epic-merge-gate-child-ci.ps1 (issue #1233).
.DESCRIPTION
    Under the opt-out predicate (epic_mode the JSON boolean true, child_ci the exact string
    integration_only, and an epic_context.integration_branch matching the integration pattern),
    Get-EpicMergeGateChildCiDecision runs stages B, R, L1, L2, and L3 in place of stages 2 to 6. The
    allow rows drive Invoke-CodexEpicMergeDecision; the deny, fallback, default, and call-count rows call
    Get-EpicMergeGateChildCiDecision directly, so no review-guard call is counted. Invoke-DocsOnlyGhExe,
    Invoke-DocsOnlyGitExe, and the checkpoint read seams are mocked by name; per-row values are read
    through script-scope variables. No row writes to disk, starts a process, or reads a clock; roots are
    synthetic forward-slash paths.
#>

BeforeDiscovery {
    $head = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
    $head64 = ('5' * 24) + $head
    $other = '9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d'
    $folder = '.dev/active/1233-opt-out-example'
    $evidencePath = "$folder/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md"
    $integration = 'epic/opt-out-example-integration'

    function Get-OptOutJson {
        <#
        .SYNOPSIS
            Build an opt-out child checkpoint as compressed JSON with optional overrides.
        #>
        param(
            [hashtable] $Set = @{},
            [string[]] $Remove = @(),
            [hashtable] $GateSet = @{},
            [string[]] $GateRemove = @(),
            [string] $Head = $head,
            [string] $ReviewHead = $Head
        )

        $gate = [ordered]@{ conclusion = 'success'; head_sha = $Head; evidence_path = $evidencePath; verified_at = '2026-11-24T05:00:00Z' }
        foreach ($key in $GateSet.Keys) { $gate[$key] = $GateSet[$key] }
        foreach ($key in $GateRemove) { $gate.Remove($key) }
        $checkpoint = [ordered]@{
            epic_mode        = $true
            step9_status     = 'passed'
            pr_gate          = [ordered]@{ pr_number = 42 }
            child_ci         = 'integration_only'
            review_mode      = 'concurrent'
            'feature-folder' = $folder
            epic_context     = [ordered]@{ integration_branch = $integration }
            remediation_loop = [ordered]@{ review_outcomes = @([ordered]@{ verdict = 'PASS'; head_sha = $ReviewHead }) }
            local_qc_gate    = $gate
        }
        foreach ($key in $Set.Keys) { $checkpoint[$key] = $Set[$key] }
        foreach ($key in $Remove) { $checkpoint.Remove($key) }
        return ($checkpoint | ConvertTo-Json -Depth 8 -Compress)
    }

    function Get-EvidenceText {
        <#
        .SYNOPSIS
            Build a local-QC evidence file body.
        #>
        param([string] $HeadLine = "Head: $head", [string[]] $ExitLines = @('EXIT_CODE: 0'), [switch] $NoTimestamp)

        $lines = @('# Local QC gate')
        if (-not $NoTimestamp) { $lines += 'Timestamp: 2026-11-24T05-00' }
        if ($HeadLine) { $lines += $HeadLine }
        $lines += 'Command: final QC loop'
        $lines += $ExitLines
        $lines += 'Output Summary: every final QC gate passed.'
        return ($lines -join "`n")
    }

    $prView = '{"headRefOid":"' + $head + '","baseRefName":"' + $integration + '"}'
    $evidence = Get-EvidenceText
    $base = @{ PrView = $prView; PrViewExit = 0; Evidence = $evidence; EvidenceExit = 0 }

    function Get-DenyRow {
        <#
        .SYNOPSIS
            Merge a deny row over the default gh and git results.
        #>
        param([hashtable] $Row)

        $merged = $base.Clone()
        foreach ($key in $Row.Keys) { $merged[$key] = $Row[$key] }
        return $merged
    }

    $script:DenyRows = @(
        Get-DenyRow @{ Name = 'OPT-B-GH-NONZERO'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrViewExit = 1; PrView = '' }
        Get-DenyRow @{ Name = 'OPT-B-UNPARSEABLE'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrView = '{oops' }
        Get-DenyRow @{ Name = 'OPT-B-BASE-ABSENT'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrView = ('{"headRefOid":"' + $head + '"}') }
        Get-DenyRow @{ Name = 'OPT-R-KEY-ABSENT'; Stage = 'R (review)'; Checkpoint = (Get-OptOutJson -Remove 'review_mode') }
        Get-DenyRow @{ Name = 'OPT-R-SEQUENTIAL'; Stage = 'R (review)'; Checkpoint = (Get-OptOutJson -Set @{ review_mode = 'sequential' }) }
        Get-DenyRow @{ Name = 'OPT-L1-OBJECT-ABSENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Remove 'local_qc_gate') }
        Get-DenyRow @{ Name = 'OPT-L1-NON-OBJECT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Set @{ local_qc_gate = 'success' }) }
        Get-DenyRow @{ Name = 'OPT-L1-CONCLUSION-FAILURE'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ conclusion = 'failure' }) }
        Get-DenyRow @{ Name = 'OPT-L1-CONCLUSION-CASE-VARIANT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ conclusion = 'Success' }) }
        Get-DenyRow @{ Name = 'OPT-L1-HEAD-UPPERCASE'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $head.ToUpperInvariant() }) }
        Get-DenyRow @{ Name = 'OPT-L1-HEAD-39'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $head.Substring(0, 39) }) }
        Get-DenyRow @{ Name = 'OPT-L1-HEAD-NON-HEX'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = ('g' * 40) }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-LEADING-SLASH'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "/$evidencePath" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-BACKSLASH'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates\local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-EMPTY-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates//local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-DOT-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/./local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-DOTDOT-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/../qa-gates/local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-OUTSIDE-FOLDER'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = '.dev/active/other-feature/evidence/qa-gates/local-qc-gate.md' }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-EVIDENCE-OTHER'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/other/local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'OPT-L1-PATH-NOT-MD'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/local-qc-gate.txt" }) }
        Get-DenyRow @{ Name = 'OPT-L1-FEATURE-FOLDER-ABSENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Remove 'feature-folder') }
        Get-DenyRow @{ Name = 'OPT-L1-FEATURE-FOLDER-REJECTED'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Set @{ 'feature-folder' = 'outside/1233-opt-out-example' }) }
        Get-DenyRow @{ Name = 'OPT-L2-DIFFERENT-HEAD'; Stage = 'L2 (binding)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $other }) }
        Get-DenyRow @{ Name = 'OPT-L2-REVIEW-HEAD-CASE'; Stage = 'L2 (binding)'; Checkpoint = (Get-OptOutJson -ReviewHead $head.ToUpperInvariant()) }
        Get-DenyRow @{ Name = 'OPT-L3-CAT-FILE-NONZERO'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); EvidenceExit = 128; Evidence = '' }
        Get-DenyRow @{ Name = 'OPT-L3-NO-EXIT-CODE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -ExitLines @()) }
        Get-DenyRow @{ Name = 'OPT-L3-FIRST-EXIT-CODE-ONE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -ExitLines @('EXIT_CODE: 1', 'EXIT_CODE: 0')) }
        Get-DenyRow @{ Name = 'OPT-L3-HEAD-ABSENT'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine '') }
        Get-DenyRow @{ Name = 'OPT-L3-HEAD-MISMATCH'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine "Head: $other") }
        Get-DenyRow @{ Name = 'OPT-L3-HEAD-CASE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine "Head: $($head.ToUpperInvariant())") }
        Get-DenyRow @{ Name = 'OPT-L3-NO-TIMESTAMP'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -NoTimestamp) }
    )

    $script:AllowRows = @(
        @{ Name = 'OPT-ALLOW-HEAD-40'; Checkpoint = (Get-OptOutJson); PrView = $prView; Evidence = $evidence; LiveHead = $head }
        @{ Name = 'OPT-ALLOW-HEAD-64'; Checkpoint = (Get-OptOutJson -Head $head64); PrView = ('{"headRefOid":"' + $head64 + '","baseRefName":"' + $integration + '"}'); Evidence = (Get-EvidenceText -HeadLine "Head: $head64"); LiveHead = $head64 }
    )

    $green = @{ ci_gate = [ordered]@{ conclusion = 'success'; head_sha = $head } }
    $script:BaseFallbackRows = @(
        @{ Name = 'OPT-FALLBACK-BASE-MAIN'; Base = 'main' }
        @{ Name = 'OPT-FALLBACK-BASE-OTHER'; Base = 'epic/another-epic-integration' }
        @{ Name = 'OPT-FALLBACK-BASE-CASE-VARIANT'; Base = 'epic/Opt-Out-Example-integration' }
    ) | ForEach-Object {
        $_['PrView'] = '{"headRefOid":"' + $head + '","baseRefName":"' + $_.Base + '"}'
        $_['Bare'] = (Get-OptOutJson)
        $_['Green'] = (Get-OptOutJson -Set $green)
        $_
    }
    $script:PatternFallbackRows = @(
        @{ Name = 'OPT-FALLBACK-INTEGRATION-ABSENT'; Bare = (Get-OptOutJson -Remove 'epic_context'); Green = (Get-OptOutJson -Remove 'epic_context' -Set $green) }
        @{ Name = 'OPT-FALLBACK-INTEGRATION-MALFORMED'; Bare = (Get-OptOutJson -Set @{ epic_context = @{ integration_branch = 'main' } }); Green = (Get-OptOutJson -Set (@{ epic_context = @{ integration_branch = 'main' } } + $green)) }
        @{ Name = 'OPT-FALLBACK-INTEGRATION-NO-SUFFIX'; Bare = (Get-OptOutJson -Set @{ epic_context = @{ integration_branch = 'epic/opt-out-example' } }); Green = (Get-OptOutJson -Set (@{ epic_context = @{ integration_branch = 'epic/opt-out-example' } } + $green)) }
    )
    $script:DefaultRows = @(
        @{ Name = 'OPT-DEFAULT-KEY-ABSENT'; Checkpoint = (Get-OptOutJson -Remove 'child_ci') }
        @{ Name = 'OPT-DEFAULT-PER-CHILD'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = 'per_child' }) }
        @{ Name = 'OPT-DEFAULT-CASE-VARIANT'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = 'Integration_Only' }) }
        @{ Name = 'OPT-DEFAULT-NON-STRING'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = $true }) }
        @{ Name = 'OPT-DEFAULT-EPIC-MODE-STRING'; Checkpoint = (Get-OptOutJson -Set @{ epic_mode = 'true' }) }
        @{ Name = 'OPT-DEFAULT-EPIC-MODE-FALSE'; Checkpoint = (Get-OptOutJson -Set @{ epic_mode = $false }) }
    )
}

Describe 'Codex child CI opt-out in enforce-epic-merge-gate-child-ci.ps1 (issue #1233)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:Head = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
        $script:RepositoryRoot = Join-Path '/synthetic-worktrees' 'codex-1233'
        $script:OtherRoot = Join-Path '/synthetic-worktrees' 'item-1233'
        $script:LocalQcPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: '
        $script:PreChangeStage2 = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: stage 2 (ci_gate): the checkpoint records no ci_gate with conclusion "success" for the child head.'
        # An epic checkpoint that would allow PR 42, so any fall-through past the child branch allows.
        $script:EpicReady = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"success"}}}'
        $script:GreenRuns = '[{"databaseId":901,"event":"pull_request","status":"completed","conclusion":"success","headSha":"' + $script:Head + '","workflowName":"CI","createdAt":"2026-11-08T10:00:00Z"}]'

        # Per-row gh and git results are read through script-scope variables (no closures).
        $script:RowPrView = ''
        $script:RowPrViewExit = 0
        $script:RowLiveHead = $script:Head
        $script:RowEvidence = ''
        $script:RowEvidenceExit = 0
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' } -MockWith { [pscustomobject]@{ ExitCode = $script:RowPrViewExit; Output = $script:RowPrView } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('{"headRefOid":"' + $script:RowLiveHead + '"}') } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = $script:GreenRuns } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'cat-file' } -MockWith { [pscustomobject]@{ ExitCode = $script:RowEvidenceExit; Output = $script:RowEvidence } }

        function Invoke-OptOutDecision {
            <#
            .SYNOPSIS
                Call Get-EpicMergeGateChildCiDecision directly for checkpoint text and PR 42.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)][string] $Checkpoint, [AllowEmptyString()][string] $GitRoot = '')

            $parsed = ConvertFrom-Json -InputObject $Checkpoint
            if ($GitRoot) { return Get-EpicMergeGateChildCiDecision -Checkpoint $parsed -CommandPrNumber 42 -GhRoot $script:RepositoryRoot -GitRoot $GitRoot }
            return Get-EpicMergeGateChildCiDecision -Checkpoint $parsed -CommandPrNumber 42 -GhRoot $script:RepositoryRoot
        }

        function Initialize-OptOutRow {
            <#
            .SYNOPSIS
                Set the per-row gh and git results.
            #>
            [CmdletBinding()]
            param([AllowEmptyString()][string] $PrView, [int] $PrViewExit = 0, [AllowEmptyString()][string] $Evidence, [int] $EvidenceExit = 0, [string] $LiveHead)

            $script:RowPrView = $PrView
            $script:RowPrViewExit = $PrViewExit
            $script:RowEvidence = $Evidence
            $script:RowEvidenceExit = $EvidenceExit
            $script:RowLiveHead = if ($LiveHead) { $LiveHead } else { $script:Head }
        }

        function Get-OptOutEvidenceText {
            <#
            .SYNOPSIS
                Return a passing evidence body for the default head.
            #>
            return "# Local QC gate`nTimestamp: 2026-11-24T05-00`nHead: $($script:Head)`nCommand: final QC loop`nEXIT_CODE: 0`nOutput Summary: every final QC gate passed."
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allow rows through Invoke-CodexEpicMergeDecision' {
        It '<Name> allows an opted-out child with no CI run on its head' -ForEach $script:AllowRows {
            # Arrange
            Initialize-OptOutRow -PrView $PrView -Evidence $Evidence -LiveHead $LiveHead
            $payload = @{ session_id = 'session-1233'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress

            # Act
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Checkpoint -EpicCheckpointRaw '' -RepositoryRoot $script:RepositoryRoot

            # Assert
            $decision | Should -BeNullOrEmpty -Because "the opt-out allows (reason: $($decision.hookSpecificOutput.permissionDecisionReason))"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' -and $GitArgs[2] -ceq "${LiveHead}:.dev/active/1233-opt-out-example/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md" }
        }

        It 'OPT-ENTRY-DENY-NO-FALL-THROUGH denies an L3 failure even when the epic checkpoint would allow' {
            # Arrange
            Initialize-OptOutRow -PrView ('{"headRefOid":"' + $script:Head + '","baseRefName":"epic/opt-out-example-integration"}') -Evidence '' -EvidenceExit 128
            $checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"child_ci":"integration_only","review_mode":"concurrent","feature-folder":".dev/active/1233-opt-out-example","epic_context":{"integration_branch":"epic/opt-out-example-integration"},"remediation_loop":{"review_outcomes":[{"verdict":"PASS","head_sha":"' + $script:Head + '"}]},"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head + '","evidence_path":".dev/active/1233-opt-out-example/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md","verified_at":"2026-11-24T05:00:00Z"}}'
            $payload = @{ session_id = 'session-1233'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress

            # Act
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $checkpoint -EpicCheckpointRaw $script:EpicReady -RepositoryRoot $script:RepositoryRoot

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            ([string]$decision.hookSpecificOutput.permissionDecisionReason).StartsWith($script:LocalQcPrefix + 'stage L3 (evidence): ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
        }
    }

    Context 'deny rows: one per opt-out stage condition' {
        It '<Name> denies with the local-QC prefix and stage <Stage>' -ForEach $script:DenyRows {
            # Arrange
            Initialize-OptOutRow -PrView $PrView -PrViewExit $PrViewExit -Evidence $Evidence -EvidenceExit $EvidenceExit

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $Checkpoint

            # Assert
            $decision.Verified | Should -BeFalse
            $decision.Reason.StartsWith("$($script:LocalQcPrefix)stage $Stage`: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }
    }

    Context 'fallback rows: per-child CI verification decides' {
        It '<Name> denies stage 2 without ci_gate and allows with a green run' -ForEach $script:BaseFallbackRows {
            # Arrange
            Initialize-OptOutRow -PrView $PrView -Evidence (Get-OptOutEvidenceText)

            # Act
            $denied = Invoke-OptOutDecision -Checkpoint $Bare
            $allowed = Invoke-OptOutDecision -Checkpoint $Green

            # Assert
            $denied.Reason | Should -BeExactly $script:PreChangeStage2
            $allowed.Verified | Should -BeTrue -Because $allowed.Reason
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' }
        }

        It '<Name> applies no opt-out, never calls the opt-out seam, and decides on CI' -ForEach $script:PatternFallbackRows {
            # Arrange
            Initialize-OptOutRow -PrView '' -PrViewExit 1 -Evidence (Get-OptOutEvidenceText)
            Mock Get-EpicMergeGateChildCiLivePullRequest { $null }

            # Act
            $denied = Invoke-OptOutDecision -Checkpoint $Bare
            $allowed = Invoke-OptOutDecision -Checkpoint $Green

            # Assert
            $denied.Reason | Should -BeExactly $script:PreChangeStage2
            $allowed.Verified | Should -BeTrue -Because $allowed.Reason
            Should -Invoke Get-EpicMergeGateChildCiLivePullRequest -Times 0 -Exactly -Scope It
        }
    }

    Context 'default rows: the helper behaves as before #1233' {
        It '<Name> never calls the opt-out seam and keeps the pre-change deny text' -ForEach $script:DefaultRows {
            # Arrange
            Initialize-OptOutRow -PrView '' -PrViewExit 1 -Evidence (Get-OptOutEvidenceText)
            Mock Get-EpicMergeGateChildCiLivePullRequest { $null }

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $Checkpoint

            # Assert
            $decision.Verified | Should -BeFalse
            $decision.Reason | Should -BeExactly $script:PreChangeStage2
            Should -Invoke Get-EpicMergeGateChildCiLivePullRequest -Times 0 -Exactly -Scope It
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -Scope It
        }
    }

    Context 'call-count rows' {
        BeforeAll {
            $script:Optout = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"child_ci":"integration_only","review_mode":"concurrent","feature-folder":".dev/active/1233-opt-out-example","epic_context":{"integration_branch":"epic/opt-out-example-integration"},"remediation_loop":{"review_outcomes":[{"verdict":"PASS","head_sha":"' + $script:Head + '"}]},"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head + '","evidence_path":".dev/active/1233-opt-out-example/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md","verified_at":"2026-11-24T05:00:00Z"}}'
            $script:IntegrationView = '{"headRefOid":"' + $script:Head + '","baseRefName":"epic/opt-out-example-integration"}'
        }

        It 'OPT-COUNT-ALLOW makes one pr view, no run list, and one cat-file' {
            # Arrange
            Initialize-OptOutRow -PrView $script:IntegrationView -Evidence (Get-OptOutEvidenceText)

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $script:Optout

            # Assert
            $decision.Verified | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' }
        }

        It 'OPT-COUNT-L2-MISMATCH makes no git call' {
            # Arrange
            Initialize-OptOutRow -PrView $script:IntegrationView -Evidence (Get-OptOutEvidenceText)
            $checkpoint = $script:Optout.Replace('"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head, '"local_qc_gate":{"conclusion":"success","head_sha":"9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d')

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $checkpoint

            # Assert
            $decision.Reason | Should -BeLike "$($script:LocalQcPrefix)stage L2 (binding): *"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -Scope It
        }

        It 'OPT-COUNT-BASE-MISMATCH-ALLOW makes one pr view and one run list' {
            # Arrange
            Initialize-OptOutRow -PrView ('{"headRefOid":"' + $script:Head + '","baseRefName":"main"}') -Evidence (Get-OptOutEvidenceText)
            $checkpoint = $script:Optout.TrimEnd('}') + '},"ci_gate":{"conclusion":"success","head_sha":"' + $script:Head + '"}}'

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $checkpoint

            # Assert
            $decision.Verified | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGhExe -Times 2 -Exactly -Scope It
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' -and $GhArgs[1] -ceq 'list' }
        }

        It 'OPT-COUNT-GITROOT-DEFAULT runs cat-file at GhRoot when -GitRoot is omitted' {
            # Arrange
            Initialize-OptOutRow -PrView $script:IntegrationView -Evidence (Get-OptOutEvidenceText)

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $script:Optout

            # Assert
            $decision.Verified | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' -and $WorktreeRoot -ceq $script:RepositoryRoot }
        }

        It 'OPT-COUNT-GITROOT-EXPLICIT runs cat-file at the given -GitRoot and gh at GhRoot' {
            # Arrange
            Initialize-OptOutRow -PrView $script:IntegrationView -Evidence (Get-OptOutEvidenceText)

            # Act
            $decision = Invoke-OptOutDecision -Checkpoint $script:Optout -GitRoot $script:OtherRoot

            # Assert
            $decision.Verified | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' -and $WorktreeRoot -ceq $script:OtherRoot }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $WorkingRoot -ceq $script:RepositoryRoot }
        }
    }

    Context 'pure helpers of the opt-out' {
        It 'Test-EpicMergeGateChildCiEvidencePath returns <Expected> for <Label>' -ForEach @(
            @{ Label = 'a clean qa-gates path'; Value = '.dev/active/f/evidence/qa-gates/local-qc-gate.md'; Expected = $true }
            @{ Label = 'a non-string value'; Value = 7; Expected = $false }
            @{ Label = 'an empty string'; Value = ''; Expected = $false }
        ) {
            Test-EpicMergeGateChildCiEvidencePath -Path $Value -FeatureFolder '.dev/active/f' | Should -Be $Expected
        }

        It 'Get-EpicMergeGateChildCiLivePullRequest returns <Label>' -ForEach @(
            @{ Label = 'null for a malformed head'; Output = '{"headRefOid":"abc","baseRefName":"epic/x-integration"}' }
            @{ Label = 'null for a blank base'; Output = '{"headRefOid":"3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f","baseRefName":"  "}' }
        ) {
            # Arrange
            Initialize-OptOutRow -PrView $Output -Evidence ''

            # Act / Assert
            Get-EpicMergeGateChildCiLivePullRequest -PrNumber 42 -WorktreeRoot $script:RepositoryRoot | Should -BeNullOrEmpty
        }
    }
}
