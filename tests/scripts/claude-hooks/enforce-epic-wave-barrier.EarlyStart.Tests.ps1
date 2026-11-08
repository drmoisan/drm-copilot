#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Early-start rows for the Claude epic wave-barrier gate (issue #1097).

.DESCRIPTION
    Runs every row of EpicWaveEarlyStart.Cases.Helpers.ps1 through Invoke-EpicWaveBarrierDecision
    with the checkpoint read seam mocked, and compares each deny with today's literal reason.
    Further rows pin the dependency-aware target selection, the union-index match of an issue
    number and a folder reference, the byte identity of the sibling's Claude and Codex copies,
    and that the sibling dot-sources and imports nothing. No row writes a file or starts a
    process; paths are synthetic and joined with Join-Path.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'EpicWaveEarlyStart.Cases.Helpers.ps1')
    $script:EarlyStartRow = @(Get-EpicWaveEarlyStartCase)
}

Describe 'enforce-epic-wave-barrier.ps1 early start (issue #1097)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-wave-barrier.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'EpicWaveEarlyStart.Cases.Helpers.ps1')
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1') -ErrorAction Stop
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -ErrorAction Stop
        Mock Get-EpicWaveBarrierCheckpointContent -MockWith { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Mock Test-CodexEpicChildRoutingLaunchAuthority { $null } }
        Mock Resolve-EpicWaveBarrierTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/early-start'; ReasonCode = $null; Detail = 'synthetic early-start target' } }

        $script:DenyReason = "EPIC_WAVE_BARRIER_BLOCKED: '2026-11-08-dependent-902' cannot start until every dependency in its depends_on list is durably confirmed merged or worktree_removed in the epic checkpoint. The checkpoint was unreadable, the feature record was not found, or a dependency is not yet safe."

        function ConvertTo-EarlyStartPayload {
            # The Agent payload of an epic-mode orchestrator delegation with the given prompt.
            param([string] $Prompt)
            return (ConvertTo-Json -InputObject ([ordered]@{ tool_name = 'Agent'; tool_input = [ordered]@{ subagent_type = 'orchestrator'; prompt = $Prompt } }) -Depth 4 -Compress)
        }

        $script:DependentPrompt = 'Epic mode: true. integration_branch: epic/early-start-1097-integration. docs/features/active/2026-11-08-dependent-902/spec.md'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'EWS-<Name> decides <Expected>' -ForEach $script:EarlyStartRow {
        # Arrange
        $checkpointText = $Json
        Mock Get-EpicWaveBarrierCheckpointContent -MockWith { $checkpointText }

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-EarlyStartPayload -Prompt $script:DependentPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly $Expected
        if ($Expected -ceq 'deny') {
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:DenyReason
        }
    }

    It 'EWS-PROMPT-CITING-UPSTREAM-TARGETS-DEPENDENT' {
        # Arrange: the prompt cites the dependent and, in its upstream context line, the upstream.
        # The record lacks interface_evidence, so the dependent is denied; a gate that selected
        # the upstream instead would allow, because the upstream has no dependency.
        $record = Get-EpicWaveEarlyStartRecord -Override @{ interface_evidence = '<remove>' }
        $checkpointText = ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open' -Dependent @{ early_start = $record }
        Mock Get-EpicWaveBarrierCheckpointContent -MockWith { $checkpointText }
        $prompt = $script:DependentPrompt + ' Upstream context for 902: early start on 901 (spec: docs/features/active/2026-11-08-upstream-901/spec.md; not merged).'

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-EarlyStartPayload -Prompt $prompt)

        # Assert: the upstream is pruned as a dependency of the dependent, which is the target.
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:DenyReason
    }

    It 'EWS-ISSUE-AND-FOLDER-REFERENCES-MATCH' {
        # Arrange: the record names the upstream folder while depends_on names its issue number.
        $record = Get-EpicWaveEarlyStartRecord -Override @{ dependency = 'docs/features/active/2026-11-08-upstream-901' }
        $checkpointText = ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open' -Dependent @{ early_start = $record }
        Mock Get-EpicWaveBarrierCheckpointContent -MockWith { $checkpointText }

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-EarlyStartPayload -Prompt $script:DependentPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'allow'
    }

    It 'EWS-TWIN-IS-BYTE-IDENTICAL' {
        # Arrange
        $claudeCopy = Join-Path $script:RepoRoot '.claude/hooks/epic-wave-barrier-early-start.ps1'
        $codexCopy = Join-Path $script:RepoRoot '.codex/hooks/epic-wave-barrier-early-start.ps1'

        # Act
        $claudeHash = (Get-FileHash -LiteralPath $claudeCopy -Algorithm SHA256).Hash
        $codexHash = (Get-FileHash -LiteralPath $codexCopy -Algorithm SHA256).Hash

        # Assert
        $codexHash | Should -BeExactly $claudeHash
    }

    It 'EWS-SIBLING-DOT-SOURCES-NOTHING' {
        # Arrange
        $siblingPath = Join-Path $script:RepoRoot '.claude/hooks/epic-wave-barrier-early-start.ps1'
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($siblingPath, [ref]$tokens, [ref]$parseErrors)

        # Act: collect dot-source and Import-Module commands, and every top-level statement that is not a function.
        $loads = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    ($node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot -or
                    $node.GetCommandName() -in @('Import-Module', 'Add-Type'))
                }, $true))
        $nonFunction = @($ast.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })

        # Assert
        $parseErrors | Should -BeNullOrEmpty
        $loads | Should -BeNullOrEmpty
        $nonFunction | Should -BeNullOrEmpty
    }
}
