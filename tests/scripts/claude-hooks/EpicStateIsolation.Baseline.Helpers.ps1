<#
.SYNOPSIS
    Baseline mock registration and interception probe for the epic-state isolation guard (issue #737).

.DESCRIPTION
    Dot-sourced by a hook suite after its hook dot-source (and by the probe harness suite).

    Register-EpicStateBaselineMock registers the null-returning baseline mocks in one statement,
    so a suite near the line cap can satisfy the guard without spelling out each Import-Module and
    Mock pair. On the Claude surface a module seam is imported without -Force and mocked in its own
    module scope; every other seam, and every seam on the Codex surface, is mocked at script scope.

    Invoke-EpicStateInterceptionProbe proves that a suite's baseline mock intercepts the read. It
    registers hostile in-memory payloads for the lower seams, calls the exported resolver by name,
    and asserts the resolver result, one invocation of the suite's baseline mock, and zero
    invocations of the lower hostile read. A baseline mock bound to a different module instance
    than the resolver uses lets the hostile payload through, and the probe then fails.

    No function creates a file, runs a process, or reads gitignored state; every payload is an
    in-memory string. This file is not mirrored under extensions/drm-copilot/resources/.
#>

$script:EpicStateBaselineRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$script:EpicStateBaselineModuleSeam = @{
    'Get-EpicScopeCheckpointText'        = @{ Module = 'EpicScopeResolution'; File = '.claude/lib/worktree-resolution/EpicScopeResolution.psm1' }
    'Get-WorktreeRunCheckpointText'      = @{ Module = 'WorktreeRunResolution'; File = '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1' }
    'Get-WorktreeItemCheckpointText'     = @{ Module = 'WorktreeItemResolution'; File = '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1' }
    'Get-WorktreeItemLiveRoot'           = @{ Module = 'WorktreeItemResolution'; File = '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1' }
    'Get-OrchestratorStateCheckpoint'    = @{ Module = 'OrchestratorState'; File = '.claude/lib/orchestrator-state/OrchestratorState.psm1' }
    'Get-CleanupWorktreeManifestContent' = @{ Module = 'CleanupWorktreeManifest'; File = '.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1' }
}
$script:EpicStateProbeHostileJson = '{"route_id":"epic","integration_branch":"epic/hostile-integration","epic_feature_folder":"hostile-epic","features":[]}'
$script:EpicStateProbeSessionRoot = '/synthetic-worktrees/local-checkout'
$script:EpicStateProbeSeamOrder = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-EpicScopeCheckpointText')

function Register-EpicStateBaselineMock {
    <#
        Register the null-returning baseline mock of each named seam. An empty array registers
        nothing and does not throw (the -ForEach shape passes an ExtraSeam array that can be empty).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [string[]] $Seam,
        [Parameter(Mandatory)] [ValidateSet('Claude', 'Codex')] [string] $Surface
    )
    foreach ($name in $Seam) {
        if ($Surface -eq 'Claude' -and $script:EpicStateBaselineModuleSeam.ContainsKey($name)) {
            $entry = $script:EpicStateBaselineModuleSeam[$name]
            Import-Module (Join-Path $script:EpicStateBaselineRepoRoot $entry.File) -ErrorAction Stop
            Mock -CommandName $name -ModuleName $entry.Module -MockWith { $null }
        } else {
            Mock -CommandName $name -MockWith { $null }
        }
    }
}

function Import-EpicStateProbeModule {
    # Import a worktree-resolution module without -Force, a no-op when the hook already loaded it.
    param([Parameter(Mandatory)] [string[]] $Name)
    foreach ($item in $Name) {
        Import-Module (Join-Path $script:EpicStateBaselineRepoRoot ".claude/lib/worktree-resolution/$item.psm1") -ErrorAction Stop
    }
}

function Invoke-EpicStateProbeItemCheckpoint {
    # Item-checkpoint seam: the observer is a Test-Path mock in module scope WorktreeItemResolution, which the real seam calls before it reads.
    Import-EpicStateProbeModule -Name 'WorktreeItemResolution'
    Mock Test-Path -ModuleName WorktreeItemResolution -ParameterFilter { $LiteralPath -like '*orchestrator-state.json' } -MockWith { $true }

    $issue = Get-WorktreeItemCheckpointIssue -WorktreeRoot $script:EpicStateProbeSessionRoot

    $issue | Should -BeNullOrEmpty
    Should -Invoke Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 1 -Exactly
    Should -Invoke Test-Path -ModuleName WorktreeItemResolution -Times 0 -Exactly -ParameterFilter { $LiteralPath -like '*orchestrator-state.json' }
}

function Invoke-EpicStateProbeItemLiveRoot {
    # Live-root seam: the lower seams that enumerate real worktrees are hostile mocks and must stay uncalled.
    Import-EpicStateProbeModule -Name 'WorktreeItemResolution'
    $session = $script:EpicStateProbeSessionRoot
    Mock Find-WorktreeResolutionRoot -ModuleName WorktreeItemResolution -MockWith { $session }.GetNewClosure()
    Mock Get-WorktreeResolutionWorktreeRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] @($session) }.GetNewClosure()
    Mock Test-WorktreeResolutionRootMarker -ModuleName WorktreeItemResolution -MockWith { $true }
    $text = "Run the review for this item.`nbranch: epic/hostile-integration"

    # The baseline null root makes the branch resolver hand a null root to a mandatory parameter, which throws after the seam call; only the counts matter.
    try { $null = Resolve-WorktreeItemTarget -Text $text -SessionRoot $session }
    catch { Write-Verbose "Expected parameter-binding error after the seam call: $($_.Exception.Message)" }

    Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -Times 1 -Exactly
    Should -Invoke Find-WorktreeResolutionRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
    Should -Invoke Get-WorktreeResolutionWorktreeRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
}

function Invoke-EpicStateProbeRunCheckpoint {
    # Worktree-run seam: the only setup device is a live root, so the baseline mock is the one observed.
    Import-EpicStateProbeModule -Name 'WorktreeRunResolution'
    $session = $script:EpicStateProbeSessionRoot
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] @($session) }.GetNewClosure()
    Mock Test-Path -ModuleName WorktreeRunResolution -ParameterFilter { $LiteralPath -like '*orchestrator-state.json' } -MockWith { $true }

    $result = Resolve-WorktreeEpicTarget -IntegrationBranch 'epic/hostile-integration' -SessionRoot $session

    $result.Status | Should -Be 'NoTarget'
    Should -Invoke Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -Times 1 -Exactly
    Should -Invoke Test-Path -ModuleName WorktreeRunResolution -Times 0 -Exactly -ParameterFilter { $LiteralPath -like '*orchestrator-state.json' }
}

function Invoke-EpicStateProbeEpicScope {
    # Epic-scope seam. The two WorktreeRunResolution mocks are setup devices of this branch only: Resolve-WorktreeEpicTarget must resolve a target before the epic-scope text seam is called.
    Import-EpicStateProbeModule -Name 'EpicScopeResolution', 'WorktreeRunResolution'
    $hostile = $script:EpicStateProbeHostileJson
    $session = $script:EpicStateProbeSessionRoot
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution -MockWith {
        if ($Path -like '/synthetic-worktrees/*') { return $Path }
        return $session
    }.GetNewClosure()
    Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution -MockWith { 'File' }
    Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -MockWith { $hostile }.GetNewClosure()
    Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -MockWith { 'epic/hostile-integration' }
    Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -MockWith { $false }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] @($session) }.GetNewClosure()
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith { $hostile }.GetNewClosure()
    $arguments = @{ Text = "Run the model-routing review for this item.`nbranch: epic/hostile-integration"; SessionRoot = $session; MatchWorktreeHead = $false }

    $result = Resolve-EpicScopeCheckpoint @arguments

    $result.IsEpicScope | Should -BeFalse -Because "the baseline mock must block the hostile payload (reason: $($result.Reason))"
    $result.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
    Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
    Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
}

function Invoke-EpicStateProbeCodexEpicScope {
    # Codex script-scope seam: the hostile payload sits behind path-filtered mocks of the two lower readers.
    $hostile = $script:EpicStateProbeHostileJson
    Mock Get-WorktreeResolutionGitEntryKind -MockWith { $null }
    Mock Get-WorktreeResolutionGitEntryKind -ParameterFilter { $Path -like '*/.git' } -MockWith { 'Directory' }
    Mock Get-WorktreeResolutionGitEntryKind -ParameterFilter { $Path -like '*epic-orchestrator-state.json' } -MockWith { 'File' }
    Mock Get-WorktreeResolutionGitFileText -MockWith { $null }
    Mock Get-WorktreeResolutionGitFileText -ParameterFilter { $Path -like '*epic-orchestrator-state.json' } -MockWith { $hostile }.GetNewClosure()

    $result = Resolve-EpicScopeCheckpoint -SessionRoot $script:EpicStateProbeSessionRoot

    $result.IsEpicScope | Should -BeFalse -Because "the baseline mock must block the hostile payload (reason: $($result.Reason))"
    $result.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
    Should -Invoke Get-EpicScopeCheckpointText -Times 1 -Exactly
    Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
}

function Invoke-EpicStateInterceptionProbe {
    <#
        Prove, inside the calling It, that the suite's baseline mock of each named seam intercepts the
        read. The branches run in a fixed order whatever order -Seam gives: the epic-scope branch is
        last because it registers a hostile mock of Get-WorktreeRunCheckpointText that would otherwise
        shadow the suite's mock of the run seam for the rest of the It.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [ValidateSet('Claude', 'Codex')] [string] $Surface,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [string[]] $Seam
    )
    if (@($Seam).Count -eq 0) { throw 'Invoke-EpicStateInterceptionProbe needs at least one seam name.' }
    foreach ($name in $Seam) {
        if ($script:EpicStateProbeSeamOrder -cnotcontains $name) { throw "Invoke-EpicStateInterceptionProbe does not know the seam '$name'." }
        if ($Surface -eq 'Codex' -and $name -cne 'Get-EpicScopeCheckpointText') { throw "The Codex surface defines only Get-EpicScopeCheckpointText, not '$name'." }
    }
    foreach ($name in $script:EpicStateProbeSeamOrder) {
        if ($Seam -cnotcontains $name) { continue }
        switch ($name) {
            'Get-WorktreeItemCheckpointText' { Invoke-EpicStateProbeItemCheckpoint }
            'Get-WorktreeItemLiveRoot' { Invoke-EpicStateProbeItemLiveRoot }
            'Get-WorktreeRunCheckpointText' { Invoke-EpicStateProbeRunCheckpoint }
            'Get-EpicScopeCheckpointText' { if ($Surface -eq 'Codex') { Invoke-EpicStateProbeCodexEpicScope } else { Invoke-EpicStateProbeEpicScope } }
        }
    }
}
