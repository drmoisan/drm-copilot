#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Release receipt leg of the Claude preimplementation gate (issue #1231, Leg 3).

.DESCRIPTION
    Unit rows call Get-OrchestrationReleaseReceiptResult directly with the synthetic root
    /synthetic-worktrees/release. The allowance reader, the container probe, the checkpoint
    presence probe, and the HEAD branch reader are mocked per row; the root derivation
    (Get-OrchestrationGateBookkeepingWorktreeRoot) and the relative-path helper run unmocked.

    Decision rows drive Invoke-OrchestrationPreimplementationGateDecision with a Write payload. The
    checkpoint read returns the synthetic item checkpoint path with no text, the bookkeeping
    configuration disables that leg, and the docs-estate and parallel records legs are kept off the
    file system. No row creates a file, starts a process, or reads a real worktree.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate-release-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }

    $script:Root = '/synthetic-worktrees/release'
    $script:CheckpointPath = $script:Root + '/artifacts/orchestration/orchestrator-state.json'
    $script:Receipt = 'artifacts/pr_body_7.receipt.json'
    $script:ValidConfig = '{"schema_version":1,"allowances":[{"id":"npm","branch_patterns":["release/*"],"allowed_paths":["package.json","package-lock.json"]}]}'
    $script:GenericDeny = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:Prefix = ' Release receipt leg not applied: '

    function Set-ReleaseReceiptFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()][object] $Config = $script:ValidConfig,
            [switch] $ConfigThrows,
            [string] $Directory = '',
            [bool] $CheckpointPresent = $false,
            [AllowNull()][string] $Branch = 'release/v1.2.3'
        )
        $configText = $Config
        $script:ReleaseReceiptDirectory = $Directory
        $present = $CheckpointPresent
        $branchName = $Branch
        if ($ConfigThrows) { Mock Get-OrchestrationGateReleaseAllowanceConfigText { throw 'synthetic read failure' } }
        else { Mock Get-OrchestrationGateReleaseAllowanceConfigText { $configText }.GetNewClosure() }
        Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $RelativePath -ceq $script:ReleaseReceiptDirectory }
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $present }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch { $branchName }.GetNewClosure()
    }
}

AfterAll {
    Remove-Item -LiteralPath 'Function:\Set-ReleaseReceiptFixture' -ErrorAction SilentlyContinue
}

Describe 'Get-OrchestrationReleaseReceiptResult unit rows (#1231)' {
    BeforeEach {
        Set-ReleaseReceiptFixture
    }

    It 'allows a relative receipt Write with a valid file and a matching branch (#1231)' {
        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeTrue
        $result.DenySuffix | Should -BeExactly ''
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' }
    }

    It 'allows an absolute receipt Write beneath R (#1231)' {
        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath "$($script:Root)/artifacts/pr_body_12.receipt.json" -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeTrue
    }

    It 'reports RELEASE_RECEIPT_CONFIG_INVALID for <Label> (#1231)' -ForEach @(
        @{ Label = 'a read failure'; Throws = $true; Config = $null; Directory = ''; Detail = 'the file could not be read' }
        @{ Label = 'an invalid file'; Throws = $false; Config = '{"schema_version":1}'; Directory = ''; Detail = "missing top-level key 'allowances'" }
        @{ Label = 'a directory entry'; Throws = $false; Config = '{"schema_version":1,"allowances":[{"id":"npm","branch_patterns":["release/*"],"allowed_paths":["package.json"]}]}'; Directory = 'package.json'; Detail = "allowed_paths entry 'package.json' is a directory" }
    ) {
        # Arrange
        Set-ReleaseReceiptFixture -Config $Config -ConfigThrows:$Throws -Directory $Directory

        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_RECEIPT_CONFIG_INVALID: $Detail"
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
    }

    It 'reports RELEASE_RECEIPT_CHECKPOINT_PRESENT when a checkpoint exists beneath R (#1231)' {
        # Arrange
        Set-ReleaseReceiptFixture -CheckpointPresent $true

        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeLike "$($script:Prefix)RELEASE_RECEIPT_CHECKPOINT_PRESENT: *"
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
    }

    It 'reports RELEASE_RECEIPT_BRANCH_NOT_MATCHED for <Label> (#1231)' -ForEach @(
        @{ Label = 'a detached HEAD'; Branch = $null; Detail = 'HEAD is detached or unreadable' }
        @{ Label = 'an unmatched branch'; Branch = 'feature/x'; Detail = "branch 'feature/x' matches no allowance" }
    ) {
        # Arrange
        Set-ReleaseReceiptFixture -Branch $Branch

        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_RECEIPT_BRANCH_NOT_MATCHED: $Detail"
    }

    It 'declines <Label> with an empty suffix and no config read (#1231)' -ForEach @(
        @{ Label = 'a blank path'; Path = '' }
        @{ Label = 'a non-numeric number'; Path = 'artifacts/pr_body_x.receipt.json' }
        @{ Label = 'a body file'; Path = 'artifacts/pr_body_7.md' }
        @{ Label = 'a path outside artifacts/'; Path = 'pr_body_7.receipt.json' }
        @{ Label = 'a relative nested path'; Path = 'sub/artifacts/pr_body_7.receipt.json' }
    ) {
        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $Path -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeExactly ''
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
    }

    It 'declines when no worktree root derives from the checkpoint path (#1231)' {
        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath ''
        $other = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath '/synthetic-worktrees/release/other.json'

        # Assert
        foreach ($entry in @($result, $other)) {
            $entry.Allowed | Should -BeFalse
            $entry.DenySuffix | Should -BeExactly ''
        }
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
    }

    It 'declines an absolute path whose remainder beneath R is not the receipt path (#1231)' {
        # Act
        $nested = Get-OrchestrationReleaseReceiptResult -FilePath "$($script:Root)/sub/artifacts/pr_body_1.receipt.json" -CheckpointPath $script:CheckpointPath
        $outside = Get-OrchestrationReleaseReceiptResult -FilePath '/synthetic-worktrees/other/artifacts/pr_body_1.receipt.json' -CheckpointPath $script:CheckpointPath

        # Assert
        foreach ($entry in @($nested, $outside)) {
            $entry.Allowed | Should -BeFalse
            $entry.DenySuffix | Should -BeExactly ''
        }
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
    }

    It 'declines an absent allowance file with no further seam call (#1231)' {
        # Arrange
        Set-ReleaseReceiptFixture -Config $null

        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeExactly ''
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 1 -Exactly
        Should -Invoke Test-OrchestrationGateReleaseAllowancePathIsContainer -Times 0 -Exactly
        Should -Invoke Test-OrchestrationDocsEstateCheckpointPresent -Times 0 -Exactly
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
    }

    It 'declines with an empty suffix and a Write-Debug record when a seam throws (#1231)' {
        # Arrange
        Mock Write-Debug { }
        Mock Test-OrchestrationDocsEstateCheckpointPresent { throw 'synthetic presence failure' }

        # Act
        $result = Get-OrchestrationReleaseReceiptResult -FilePath $script:Receipt -CheckpointPath $script:CheckpointPath

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -BeExactly ''
        Should -Invoke Write-Debug -Times 1 -ParameterFilter { $Message -like 'PREIMPL_RELEASE_RECEIPT_LEG_ERROR:*' }
    }
}

Describe 'preimplementation gate decision with the release receipt leg (#1231)' {
    BeforeAll {
        $checkpointPath = $script:CheckpointPath
        Mock Read-OrchestrationGateCheckpoint { [pscustomobject]@{ Resolved = $true; Raw = ''; Path = $checkpointPath; DenyReason = $null } }.GetNewClosure()
        Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": []}' }

        function Invoke-ReleaseReceiptGateDecision {
            param([string] $FilePath = $script:Receipt)
            $raw = @{ tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = '{}' } } | ConvertTo-Json -Compress -Depth 5
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $raw)
        }
    }

    AfterAll {
        Remove-Item -LiteralPath 'Function:\Invoke-ReleaseReceiptGateDecision' -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Set-ReleaseReceiptFixture
    }

    It 'allows a checkpoint-free receipt Write on a matching branch (AC-07) (#1231)' {
        # Act
        $decision = Invoke-ReleaseReceiptGateDecision

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
    }

    It 'keeps PREIMPLEMENTATION_GATE_BLOCKED with the <Code> suffix (AC-08) (#1231)' -ForEach @(
        @{ Code = 'RELEASE_RECEIPT_CONFIG_INVALID'; Config = '{"schema_version":1}'; Present = $false; Branch = 'release/v1.2.3' }
        @{ Code = 'RELEASE_RECEIPT_CHECKPOINT_PRESENT'; Config = $null; Present = $true; Branch = 'release/v1.2.3' }
        @{ Code = 'RELEASE_RECEIPT_BRANCH_NOT_MATCHED'; Config = $null; Present = $false; Branch = 'feature/x' }
    ) {
        # Arrange
        $configText = if ($null -ne $Config) { $Config } else { $script:ValidConfig }
        Set-ReleaseReceiptFixture -Config $configText -CheckpointPresent $Present -Branch $Branch

        # Act
        $decision = Invoke-ReleaseReceiptGateDecision
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith($script:GenericDeny, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' keeps the gate text"
        $reason | Should -Match ([regex]::Escape("$($script:Prefix)$($Code): "))
        ([regex]::Matches($reason, 'Release receipt leg not applied:')).Count | Should -Be 1
    }

    It 'keeps the pre-change deny text when the allowance file is absent (AC-10) (#1231)' {
        # Arrange
        Set-ReleaseReceiptFixture -Config $null

        # Act
        $decision = Invoke-ReleaseReceiptGateDecision

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDeny
    }

    It 'keeps the pre-change deny text for a Write to a non-receipt path (#1231)' {
        # Act
        $decision = Invoke-ReleaseReceiptGateDecision -FilePath 'src/app.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDeny
        Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
    }
}
