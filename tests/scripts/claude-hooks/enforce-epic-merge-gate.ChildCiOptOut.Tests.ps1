#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Child CI opt-out rows for branch 1 of the Claude merge gate (issue #1233).

.DESCRIPTION
    Invoke-EpicMergeGateDecision passes -GitRoot $childRoot (the item worktree) to
    Get-EpicMergeGateChildCiDecision, which under the opt-out predicate runs stages B, R, L1, L2, and L3
    in place of stages 2 to 6. Every row drives Invoke-EpicMergeGateDecision with the checkpoint-content,
    resolution, and session-root seams mocked, and with Invoke-DocsOnlyGhExe and Invoke-DocsOnlyGitExe
    mocked by argument; per-row values are read through script-scope variables. The review guard runs
    under review_mode concurrent and makes its own gh pr view --json headRefOid call, so call-count rows
    filter by argument. No row starts a process, runs git or gh, or writes a file.
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

    function Get-OrdinalLiteralJson {
        <#
        .SYNOPSIS
            Build the default opt-out checkpoint as a literal JSON string with chosen head_sha key spellings.
        #>
        param([string] $ReviewHeadKey = 'head_sha', [string] $GateHeadKey = 'head_sha')

        return '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"child_ci":"integration_only","review_mode":"concurrent","feature-folder":"' + $folder + '","epic_context":{"integration_branch":"' + $integration + '"},"remediation_loop":{"review_outcomes":[{"verdict":"PASS","' + $ReviewHeadKey + '":"' + $head + '"}]},"local_qc_gate":{"conclusion":"success","' + $GateHeadKey + '":"' + $head + '","evidence_path":"' + $evidencePath + '","verified_at":"2026-11-24T05:00:00Z"}}'
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
        Get-DenyRow @{ Name = 'CLAUDE-OPT-B-GH-NONZERO'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrViewExit = 1; PrView = '' }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-B-UNPARSEABLE'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrView = '{oops' }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-B-BASE-ABSENT'; Stage = 'B (base)'; Checkpoint = (Get-OptOutJson); PrView = ('{"headRefOid":"' + $head + '"}') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-R-KEY-ABSENT'; Stage = 'R (review)'; Checkpoint = (Get-OptOutJson -Remove 'review_mode') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-R-SEQUENTIAL'; Stage = 'R (review)'; Checkpoint = (Get-OptOutJson -Set @{ review_mode = 'sequential' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-OBJECT-ABSENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Remove 'local_qc_gate') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-NON-OBJECT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Set @{ local_qc_gate = 'success' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-CONCLUSION-FAILURE'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ conclusion = 'failure' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-CONCLUSION-CASE-VARIANT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ conclusion = 'Success' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-HEAD-UPPERCASE'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $head.ToUpperInvariant() }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-HEAD-39'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $head.Substring(0, 39) }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-HEAD-NON-HEX'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = ('g' * 40) }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-LEADING-SLASH'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "/$evidencePath" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-BACKSLASH'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates\local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-EMPTY-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates//local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-DOT-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/./local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-DOTDOT-SEGMENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/../qa-gates/local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-OUTSIDE-FOLDER'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = '.dev/active/other-feature/evidence/qa-gates/local-qc-gate.md' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-EVIDENCE-OTHER'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/other/local-qc-gate.md" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-PATH-NOT-MD'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -GateSet @{ evidence_path = "$folder/evidence/qa-gates/local-qc-gate.txt" }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-FEATURE-FOLDER-ABSENT'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Remove 'feature-folder') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L1-FEATURE-FOLDER-REJECTED'; Stage = 'L1 (record)'; Checkpoint = (Get-OptOutJson -Set @{ 'feature-folder' = 'outside/1233-opt-out-example' }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L2-DIFFERENT-HEAD'; Stage = 'L2 (binding)'; Checkpoint = (Get-OptOutJson -GateSet @{ head_sha = $other }) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-CAT-FILE-NONZERO'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); EvidenceExit = 128; Evidence = '' }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-NO-EXIT-CODE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -ExitLines @()) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-FIRST-EXIT-CODE-ONE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -ExitLines @('EXIT_CODE: 1', 'EXIT_CODE: 0')) }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-HEAD-ABSENT'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine '') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-HEAD-MISMATCH'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine "Head: $other") }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-HEAD-CASE'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -HeadLine "Head: $($head.ToUpperInvariant())") }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-L3-NO-TIMESTAMP'; Stage = 'L3 (evidence)'; Checkpoint = (Get-OptOutJson); Evidence = (Get-EvidenceText -NoTimestamp) }
        # Case-variant keys: the opt-out reads every #1233 key by ordinal name (issue #1233 remediation).
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L1-LOCAL-QC-GATE-KEY'; Stage = 'L1 (record)'; Checkpoint = ((Get-OptOutJson) -creplace '"local_qc_gate"', '"Local_QC_Gate"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L1-CONCLUSION-KEY'; Stage = 'L1 (record)'; Checkpoint = ((Get-OptOutJson) -creplace '"conclusion"', '"Conclusion"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L1-HEAD-SHA-KEY'; Stage = 'L1 (record)'; Checkpoint = (Get-OrdinalLiteralJson -GateHeadKey 'Head_Sha') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L1-EVIDENCE-PATH-KEY'; Stage = 'L1 (record)'; Checkpoint = ((Get-OptOutJson) -creplace '"evidence_path"', '"Evidence_Path"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L1-FEATURE-FOLDER-KEY'; Stage = 'L1 (record)'; Checkpoint = ((Get-OptOutJson) -creplace '"feature-folder"', '"Feature-Folder"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L2-REMEDIATION-LOOP-KEY'; Stage = 'L2 (binding)'; Checkpoint = ((Get-OptOutJson) -creplace '"remediation_loop"', '"Remediation_Loop"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L2-REVIEW-OUTCOMES-KEY'; Stage = 'L2 (binding)'; Checkpoint = ((Get-OptOutJson) -creplace '"review_outcomes"', '"Review_Outcomes"') }
        Get-DenyRow @{ Name = 'CLAUDE-OPT-ORD-L2-REVIEW-HEAD-SHA-KEY'; Stage = 'L2 (binding)'; Checkpoint = (Get-OrdinalLiteralJson -ReviewHeadKey 'Head_Sha') }
    )

    $script:AllowRows = @(
        @{ Name = 'CLAUDE-OPT-ALLOW-HEAD-40'; Checkpoint = (Get-OptOutJson); PrView = $prView; Evidence = $evidence; LiveHead = $head }
        @{ Name = 'CLAUDE-OPT-ALLOW-HEAD-64'; Checkpoint = (Get-OptOutJson -Head $head64); PrView = ('{"headRefOid":"' + $head64 + '","baseRefName":"' + $integration + '"}'); Evidence = (Get-EvidenceText -HeadLine "Head: $head64"); LiveHead = $head64 }
    )

    $green = @{ ci_gate = [ordered]@{ conclusion = 'success'; head_sha = $head } }
    $script:BaseFallbackRows = @(
        @{ Name = 'CLAUDE-OPT-FALLBACK-BASE-MAIN'; Base = 'main' }
        @{ Name = 'CLAUDE-OPT-FALLBACK-BASE-OTHER'; Base = 'epic/another-epic-integration' }
        @{ Name = 'CLAUDE-OPT-FALLBACK-BASE-CASE-VARIANT'; Base = 'epic/Opt-Out-Example-integration' }
    ) | ForEach-Object {
        $_['PrView'] = '{"headRefOid":"' + $head + '","baseRefName":"' + $_.Base + '"}'
        $_['Bare'] = (Get-OptOutJson)
        $_['Green'] = (Get-OptOutJson -Set $green)
        $_
    }
    $script:PatternFallbackRows = @(
        @{ Name = 'CLAUDE-OPT-FALLBACK-INTEGRATION-ABSENT'; Bare = (Get-OptOutJson -Remove 'epic_context'); Green = (Get-OptOutJson -Remove 'epic_context' -Set $green) }
        @{ Name = 'CLAUDE-OPT-FALLBACK-INTEGRATION-MALFORMED'; Bare = (Get-OptOutJson -Set @{ epic_context = @{ integration_branch = 'main' } }); Green = (Get-OptOutJson -Set (@{ epic_context = @{ integration_branch = 'main' } } + $green)) }
        @{ Name = 'CLAUDE-OPT-FALLBACK-INTEGRATION-NO-SUFFIX'; Bare = (Get-OptOutJson -Set @{ epic_context = @{ integration_branch = 'epic/opt-out-example' } }); Green = (Get-OptOutJson -Set (@{ epic_context = @{ integration_branch = 'epic/opt-out-example' } } + $green)) }
        @{ Name = 'CLAUDE-OPT-ORD-FALLBACK-EPIC-CONTEXT-KEY'; Bare = ((Get-OptOutJson) -creplace '"epic_context"', '"Epic_Context"'); Green = ((Get-OptOutJson -Set $green) -creplace '"epic_context"', '"Epic_Context"') }
        @{ Name = 'CLAUDE-OPT-ORD-FALLBACK-INTEGRATION-BRANCH-KEY'; Bare = ((Get-OptOutJson) -creplace '"integration_branch"', '"Integration_Branch"'); Green = ((Get-OptOutJson -Set $green) -creplace '"integration_branch"', '"Integration_Branch"') }
    )
    $script:DefaultRows = @(
        @{ Name = 'CLAUDE-OPT-DEFAULT-KEY-ABSENT'; Checkpoint = (Get-OptOutJson -Remove 'child_ci'); Control = (Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-DEFAULT-PER-CHILD'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = 'per_child' }); Control = (Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-DEFAULT-CASE-VARIANT'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = 'Integration_Only' }); Control = (Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-DEFAULT-NON-STRING'; Checkpoint = (Get-OptOutJson -Set @{ child_ci = $true }); Control = (Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-DEFAULT-EPIC-MODE-STRING'; Checkpoint = (Get-OptOutJson -Set @{ epic_mode = 'true' }); Control = (Get-OptOutJson -Set @{ epic_mode = 'true' } -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-DEFAULT-EPIC-MODE-FALSE'; Checkpoint = (Get-OptOutJson -Set @{ epic_mode = $false }); Control = (Get-OptOutJson -Set @{ epic_mode = $false } -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-ORD-PREDICATE-CHILD-CI-KEY'; Checkpoint = ((Get-OptOutJson) -creplace '"child_ci"', '"Child_CI"'); Control = (Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') }
        @{ Name = 'CLAUDE-OPT-ORD-PREDICATE-EPIC-MODE-KEY'; Checkpoint = ((Get-OptOutJson) -creplace '"epic_mode"', '"Epic_Mode"'); Control = ((Get-OptOutJson -Remove 'child_ci', 'local_qc_gate') -creplace '"epic_mode"', '"Epic_Mode"') }
    )
}

Describe 'enforce-epic-merge-gate child CI opt-out through branch 1 (issue #1233)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:Head = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
        $script:ItemRoot = Join-Path '/synthetic-worktrees' 'item-1233'
        $script:SessionRoot = Join-Path '/synthetic-worktrees' 'session-1233'
        $script:LocalQcPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: '
        $script:PreChangeStage2 = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: stage 2 (ci_gate): the checkpoint records no ci_gate with conclusion "success" for the child head.'
        $script:GreenRuns = '[{"databaseId":901,"event":"pull_request","status":"completed","conclusion":"success","headSha":"' + $script:Head + '","workflowName":"CI","createdAt":"2026-11-08T10:00:00Z"}]'
        $script:IntegrationView = '{"headRefOid":"' + $script:Head + '","baseRefName":"epic/opt-out-example-integration"}'
        $script:EvidenceText = "# Local QC gate`nTimestamp: 2026-11-24T05-00`nHead: $($script:Head)`nCommand: final QC loop`nEXIT_CODE: 0`nOutput Summary: every final QC gate passed."

        Mock Get-EpicMergeGateSessionWorktreeRoot { $script:SessionRoot }
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $script:ItemRoot; ReasonCode = $null; Detail = 'item SessionRoot (issue #1233)' } }
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1233)' } }
        Mock Get-EpicMergeGateLivePrHeadSha { $script:Head }

        # Per-row checkpoint, gh, and git results are read through script-scope variables (no closures).
        $script:RowCheckpoint = $null
        $script:RowPrView = ''
        $script:RowPrViewExit = 0
        $script:RowLiveHead = $script:Head
        $script:RowEvidence = ''
        $script:RowEvidenceExit = 0
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' } -MockWith { [pscustomobject]@{ ExitCode = $script:RowPrViewExit; Output = $script:RowPrView } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('{"headRefOid":"' + $script:RowLiveHead + '"}') } }
        Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = $script:GreenRuns } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'cat-file' } -MockWith { [pscustomobject]@{ ExitCode = $script:RowEvidenceExit; Output = $script:RowEvidence } }

        function Initialize-OptOutRow {
            <#
            .SYNOPSIS
                Set the per-row checkpoint and the gh and git results.
            #>
            [CmdletBinding()]
            param([AllowNull()][string] $Checkpoint, [AllowEmptyString()][string] $PrView, [int] $PrViewExit = 0, [AllowEmptyString()][string] $Evidence, [int] $EvidenceExit = 0, [string] $LiveHead)

            $script:RowCheckpoint = $Checkpoint
            $script:RowPrView = $PrView
            $script:RowPrViewExit = $PrViewExit
            $script:RowEvidence = $Evidence
            $script:RowEvidenceExit = $EvidenceExit
            $script:RowLiveHead = if ($LiveHead) { $LiveHead } else { $script:Head }
        }

        function Invoke-OptOutGate {
            <#
            .SYNOPSIS
                Run the gate decision for gh pr merge 42 --merge with session id session-1233.
            #>
            $envelope = @{ session_id = 'session-1233'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }

        function Get-OptOutReason {
            <#
            .SYNOPSIS
                Return the deny reason of a decision, or an empty string for an allow.
            #>
            param([AllowNull()] $Decision)

            if ($null -eq $Decision -or $null -eq $Decision.hookSpecificOutput) { return '' }
            return [string]$Decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    BeforeEach {
        # The outermost BeforeAll keeps the $null baseline mock of the closure seam; each row reads
        # its checkpoint through this per-test mock.
        Mock Get-ChildOrchestratorCheckpointContent { $script:RowCheckpoint }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allow rows' {
        It '<Name> allows an opted-out child with no CI run on its head' -ForEach $script:AllowRows {
            # Arrange
            Initialize-OptOutRow -Checkpoint $Checkpoint -PrView $PrView -Evidence $Evidence -LiveHead $LiveHead

            # Act
            $decision = Invoke-OptOutGate

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $decision)
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }
    }

    Context 'deny rows: one per opt-out stage condition' {
        It '<Name> denies with the local-QC prefix and stage <Stage>' -ForEach $script:DenyRows {
            # Arrange
            Initialize-OptOutRow -Checkpoint $Checkpoint -PrView $PrView -PrViewExit $PrViewExit -Evidence $Evidence -EvidenceExit $EvidenceExit

            # Act
            $reason = Get-OptOutReason -Decision (Invoke-OptOutGate)

            # Assert
            $reason.StartsWith("$($script:LocalQcPrefix)stage $Stage`: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
            Should -Invoke Get-EpicOrchestratorCheckpointContent -Times 0 -Exactly -Scope It
            Should -Invoke Get-ParallelOrchestratorCheckpointContent -Times 0 -Exactly -Scope It
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }

        It 'CLAUDE-OPT-L2-REVIEW-HEAD-CASE denies stage L2 for a review head that differs only in letter case' {
            # Arrange: the review guard rejects an uppercase head first, so its decision is stubbed to pass.
            $checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"child_ci":"integration_only","review_mode":"concurrent","feature-folder":".dev/active/1233-opt-out-example","epic_context":{"integration_branch":"epic/opt-out-example-integration"},"remediation_loop":{"review_outcomes":[{"verdict":"PASS","head_sha":"' + $script:Head.ToUpperInvariant() + '"}]},"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head + '","evidence_path":".dev/active/1233-opt-out-example/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md","verified_at":"2026-11-24T05:00:00Z"}}'
            Initialize-OptOutRow -Checkpoint $checkpoint -PrView $script:IntegrationView -Evidence $script:EvidenceText
            Mock Get-EpicMergeGateReviewDecision { [ordered]@{ Denied = $false; Reason = $null } }

            # Act
            $reason = Get-OptOutReason -Decision (Invoke-OptOutGate)

            # Assert
            $reason.StartsWith("$($script:LocalQcPrefix)stage L2 (binding): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        }
    }

    Context 'fallback rows: per-child CI verification decides' {
        It '<Name> denies stage 2 without ci_gate and allows with a green run' -ForEach $script:BaseFallbackRows {
            # Arrange / Act
            Initialize-OptOutRow -Checkpoint $Bare -PrView $PrView -Evidence $script:EvidenceText
            $denied = Get-OptOutReason -Decision (Invoke-OptOutGate)
            Initialize-OptOutRow -Checkpoint $Green -PrView $PrView -Evidence $script:EvidenceText
            $allowed = Invoke-OptOutGate

            # Assert
            $denied | Should -BeExactly $script:PreChangeStage2
            $allowed.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $allowed)
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' }
        }

        It '<Name> applies no opt-out and decides on CI' -ForEach $script:PatternFallbackRows {
            # Arrange / Act
            Mock Get-EpicMergeGateChildCiLivePullRequest { $null }
            Initialize-OptOutRow -Checkpoint $Bare -PrView '' -PrViewExit 1 -Evidence $script:EvidenceText
            $denied = Get-OptOutReason -Decision (Invoke-OptOutGate)
            Initialize-OptOutRow -Checkpoint $Green -PrView '' -PrViewExit 1 -Evidence $script:EvidenceText
            $allowed = Invoke-OptOutGate

            # Assert
            $denied | Should -BeExactly $script:PreChangeStage2
            $allowed.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $allowed)
            Should -Invoke Get-EpicMergeGateChildCiLivePullRequest -Times 0 -Exactly -Scope It
        }
    }

    Context 'default rows: the gate behaves as before #1233' {
        It '<Name> never calls the opt-out seam and keeps the deny text of the same checkpoint without the opt-out keys' -ForEach $script:DefaultRows {
            # Arrange / Act
            Mock Get-EpicMergeGateChildCiLivePullRequest { $null }
            Initialize-OptOutRow -Checkpoint $Control -PrView '' -PrViewExit 1 -Evidence $script:EvidenceText
            $expected = Get-OptOutReason -Decision (Invoke-OptOutGate)
            Initialize-OptOutRow -Checkpoint $Checkpoint -PrView '' -PrViewExit 1 -Evidence $script:EvidenceText
            $observed = Get-OptOutReason -Decision (Invoke-OptOutGate)

            # Assert
            $observed | Should -Not -BeNullOrEmpty
            $observed | Should -BeExactly $expected
            Should -Invoke Get-EpicMergeGateChildCiLivePullRequest -Times 0 -Exactly -Scope It
        }
    }

    Context 'call-count and root rows' {
        BeforeAll {
            $script:Optout = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"child_ci":"integration_only","review_mode":"concurrent","feature-folder":".dev/active/1233-opt-out-example","epic_context":{"integration_branch":"epic/opt-out-example-integration"},"remediation_loop":{"review_outcomes":[{"verdict":"PASS","head_sha":"' + $script:Head + '"}]},"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head + '","evidence_path":".dev/active/1233-opt-out-example/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md","verified_at":"2026-11-24T05:00:00Z"}}'
        }

        It 'CLAUDE-OPT-COUNT-ALLOW makes one opt-out pr view and one cat-file' {
            # Arrange
            Initialize-OptOutRow -Checkpoint $script:Optout -PrView $script:IntegrationView -Evidence $script:EvidenceText

            # Act
            $decision = Invoke-OptOutGate

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $decision)
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' }
        }

        It 'CLAUDE-OPT-COUNT-L2-MISMATCH makes no cat-file call' {
            # Arrange
            Initialize-OptOutRow -Checkpoint ($script:Optout.Replace('"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head, '"local_qc_gate":{"conclusion":"success","head_sha":"9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d')) -PrView $script:IntegrationView -Evidence $script:EvidenceText

            # Act
            $reason = Get-OptOutReason -Decision (Invoke-OptOutGate)

            # Assert
            $reason | Should -BeLike "$($script:LocalQcPrefix)stage L2 (binding): *"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' }
        }

        It 'CLAUDE-OPT-COUNT-BASE-MISMATCH-ALLOW makes one opt-out pr view and one run list, and no second child pr view' {
            # Arrange
            $checkpoint = $script:Optout.TrimEnd('}') + '},"ci_gate":{"conclusion":"success","head_sha":"' + $script:Head + '"}}'
            Initialize-OptOutRow -Checkpoint $checkpoint -PrView ('{"headRefOid":"' + $script:Head + '","baseRefName":"main"}') -Evidence $script:EvidenceText

            # Act
            $decision = Invoke-OptOutGate

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $decision)
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid,baseRefName' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'run' -and $GhArgs[1] -ceq 'list' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -ceq 'pr' -and $GhArgs[-1] -ceq 'headRefOid' } -Because 'only the review guard reads the head alone'
        }

        It 'CLAUDE-OPT-GITROOT-ITEM runs cat-file in the item worktree and gh in the session root' {
            # Arrange
            Initialize-OptOutRow -Checkpoint $script:Optout -PrView $script:IntegrationView -Evidence $script:EvidenceText

            # Act
            $decision = Invoke-OptOutGate

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because (Get-OptOutReason -Decision $decision)
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -Scope It -ParameterFilter { $GitArgs[0] -ceq 'cat-file' -and $WorktreeRoot -ceq $script:ItemRoot }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[-1] -ceq 'headRefOid,baseRefName' -and $WorkingRoot -ceq $script:SessionRoot }
        }
    }
}
