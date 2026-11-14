<#
.SYNOPSIS
    Checkpoint read seams and run-target resolution for the epic worktree-removal gate (issue #690).

.DESCRIPTION
    Dot-sourced by enforce-epic-worktree-removal-gate.ps1 after its command-parser
    dot-sources. Holds:

    - The import guard for WorktreeRunResolution.psm1. A failed import is recorded in
      $script:HookDependencyFailures, and the gate's call to
      Get-HookDependencyFailureDecision turns it into a deny, so a missing module
      cannot make the gate exit non-zero and fail open.
    - The two checkpoint read seams, relocated from the gate file with their names kept.
      Each takes a mandatory absolute path composed beneath a resolved worktree root.
    - The resolution seam Resolve-EpicWorktreeGateRunTarget, which locates the epic or
      parallel checkpoint that records the removal target under worktree_path.
    - Read-EpicWorktreeGateRunCheckpoint, which returns the target, the parsed checkpoint
      beneath it ($null when the target is unresolved), and the Path it read ($null when
      the target is unresolved; issue #851).
    - Find-EpicWorktreeGateParallelItemRecord, which locates the parallel items[] record
      for the removal target, and Get-EpicWorktreeGateDenyDiagnostics, which builds the
      diagnostics clause of the final deny from two read results without reading any
      file (issue #851).
    - The import guard for WorktreeRunRecordPath.psm1, whose Get-WorktreeRunRecordBaseRoot
      pairs the main checkout root with a read's own root so a relative recorded
      worktree_path is compared through the shared matcher (issue #995).

.NOTES
    PowerShell 7+. Depends on Get-EpicWorktreeGateBlockDecision,
    ConvertFrom-EpicWorktreeGateJson, and Find-EpicWorktreeFeatureRecord from the gate
    file, resolved at call time. Mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/.
#>

# Shared recorded-path matcher and main-checkout-root seam (issue #995).
# Branch resolver for a host-moved worktree_path record (issue #1163).
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/AgentTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'AgentTargetWorktree.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeRunRecordPath.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeRunRecordPath.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeRunResolution.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeRunResolution.psm1' -ErrorRecord $_ }

function Get-EpicWorktreeGateCheckpointContent {
    <#
    .SYNOPSIS
        Read the raw JSON text of the epic checkpoint. Tests mock this function
        (read seam).
    .PARAMETER Path
        The absolute checkpoint path composed beneath the resolved worktree root.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-Content -LiteralPath $Path -Raw)
}

function Get-EpicWorktreeGateParallelCheckpointContent {
    <#
    .SYNOPSIS
        Read the raw JSON text of the parallel-orchestrator checkpoint. Tests mock
        this function (read seam).
    .PARAMETER Path
        The absolute checkpoint path composed beneath the resolved worktree root.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-Content -LiteralPath $Path -Raw)
}

function Resolve-EpicWorktreeGateRunTarget {
    <#
    .SYNOPSIS
        Resolve the worktree whose run checkpoint records a worktree path (issue #690 seam).
    .PARAMETER Kind
        epic or parallel.
    .PARAMETER WorktreePath
        The removal target the command names.
    .OUTPUTS
        System.Management.Automation.PSCustomObject (the worktree-resolution target result).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][ValidateSet('epic', 'parallel')][string] $Kind,
        [AllowNull()][AllowEmptyString()][string] $WorktreePath,
        [AllowNull()][scriptblock] $BranchWorktreeResolver = $null
    )

    $arguments = @{ Kind = $Kind; RecordField = 'worktree_path'; Value = $WorktreePath; SessionRoot = (Get-Location).Path }
    if ($null -ne $BranchWorktreeResolver) { $arguments['BranchWorktreeResolver'] = $BranchWorktreeResolver }
    return Resolve-WorktreeRunTargetByRecord @arguments
}

function Read-EpicWorktreeGateRunCheckpoint {
    <#
    .SYNOPSIS
        Resolve one run kind and read its checkpoint beneath the resolved root.
    .PARAMETER Kind
        epic or parallel.
    .PARAMETER WorktreePath
        The removal target the command names.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Target, Checkpoint ($null when
        unresolved, absent, or unparseable), and Path (the composed absolute checkpoint
        path, or $null when the target is unresolved).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][ValidateSet('epic', 'parallel')][string] $Kind,
        [AllowNull()][AllowEmptyString()][string] $WorktreePath,
        [AllowNull()][scriptblock] $BranchWorktreeResolver = $null
    )

    $target = Resolve-EpicWorktreeGateRunTarget -Kind $Kind -WorktreePath $WorktreePath -BranchWorktreeResolver $BranchWorktreeResolver
    $checkpoint = $null
    $path = $null
    if ($target.Status -eq 'SessionRoot' -or $target.Status -eq 'OtherWorktree') {
        $path = Get-WorktreeRunCheckpointPath -Kind $Kind -WorktreeRoot $target.WorktreeRoot
        $raw = if ($Kind -eq 'epic') { Get-EpicWorktreeGateCheckpointContent -Path $path } else { Get-EpicWorktreeGateParallelCheckpointContent -Path $path }
        $checkpoint = ConvertFrom-EpicWorktreeGateJson -Raw $raw
    }
    return [pscustomobject]@{
        Target     = $target
        Checkpoint = $checkpoint
        Path       = $path
    }
}

function Find-EpicWorktreeGateParallelItemRecord {
    <#
    .SYNOPSIS
        Locate the parallel items[] record whose worktree_path matches the target path.
    .DESCRIPTION
        Pure. Compares through Test-WorktreeRunRecordedPathMatchesTarget, exactly as
        Test-ParallelCheckpointAllowsWorktreeRemoval does, and returns the first matching
        entry (issues #851, #995).
    .PARAMETER Checkpoint
        Parsed parallel-orchestrator checkpoint, or $null when absent/unreadable.
    .PARAMETER WorktreePath
        The removal target the command names.
    .PARAMETER BaseRoot
        Optional. The roots a relative recorded worktree_path is joined to.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Checkpoint,

        [AllowNull()]
        [string] $WorktreePath,

        [AllowNull()][AllowEmptyCollection()][string[]] $BaseRoot = @(),
        [AllowNull()][AllowEmptyCollection()][string[]] $LiveWorktreeRoot = @(),
        [AllowNull()][scriptblock] $BranchWorktreeResolver = $null
    )

    if ($null -eq $Checkpoint -or [string]::IsNullOrWhiteSpace($WorktreePath)) {
        return $null
    }
    $props = @($Checkpoint.PSObject.Properties.Name)
    if ($props -notcontains 'items' -or $null -eq $Checkpoint.items) {
        return $null
    }

    # Scan the items for the first record the shared matcher accepts for the target.
    foreach ($item in @($Checkpoint.items)) {
        if ($null -eq $item) {
            continue
        }
        $itemProps = @($item.PSObject.Properties.Name)
        if ($itemProps -notcontains 'worktree_path') {
            continue
        }
        $branch = if ($itemProps -contains 'branch_name') { [string]$item.branch_name } else { '' }
        if (Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath ([string]$item.worktree_path) -TargetPath $WorktreePath -BaseRoot $BaseRoot -RecordedBranch $branch -LiveWorktreeRoot $LiveWorktreeRoot -BranchWorktreeResolver $BranchWorktreeResolver) {
            return $item
        }
    }
    return $null
}

function Get-EpicWorktreeGateDenyDiagnostics {
    <#
    .SYNOPSIS
        Build the diagnostics clause of the final deny from the two read results (issue #851).
    .DESCRIPTION
        Pure; reads no file. Names, for each run kind, the target status, the checkpoint
        path read (or that none was read), and the outcome of the record match: the
        matched record's merge_status, an absent merge_status, no matching record, an
        absent or unparseable checkpoint, or not evaluated when no checkpoint was read.
    .PARAMETER EpicRead
        The epic read result (Target, Checkpoint, Path).
    .PARAMETER ParallelRead
        The parallel read result (Target, Checkpoint, Path).
    .PARAMETER WorktreePath
        The removal target the command names.
    .PARAMETER MainRoot
        Optional. The main checkout root the gate derived; with each read's own root it
        forms the base roots a relative recorded worktree_path is joined to (issue #995).
    .OUTPUTS
        System.String
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The name is fixed by the issue #851 plan contract; the plural noun names the one diagnostics clause it returns.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] $EpicRead,
        [Parameter(Mandatory)] $ParallelRead,
        [AllowNull()][AllowEmptyString()][string] $WorktreePath,
        [AllowNull()][AllowEmptyString()][string] $MainRoot,
        [AllowNull()][scriptblock] $BranchWorktreeResolver = $null
    )

    $parts = foreach ($kind in @('epic', 'parallel')) {
        $read = if ($kind -eq 'epic') { $EpicRead } else { $ParallelRead }
        $pathText = if ($null -ne $read.Path) { "checkpoint '$($read.Path)'" } else { 'no checkpoint read' }
        if ($null -eq $read.Path) {
            $recordText = 'not evaluated'
        }
        elseif ($null -eq $read.Checkpoint) {
            $recordText = 'checkpoint absent or unparseable'
        }
        else {
            $baseRoot = Get-WorktreeRunRecordBaseRoot -MainRoot $MainRoot -Read $read
            $liveRoot = [string[]] @($read.Target.PSObject.Properties | Where-Object { $_.Name -eq 'LiveRoot' } | ForEach-Object { $_.Value })
            $record = if ($kind -eq 'epic') {
                Find-EpicWorktreeFeatureRecord -Checkpoint $read.Checkpoint -WorktreePath $WorktreePath -BaseRoot $baseRoot -LiveWorktreeRoot $liveRoot -BranchWorktreeResolver $BranchWorktreeResolver
            }
            else {
                Find-EpicWorktreeGateParallelItemRecord -Checkpoint $read.Checkpoint -WorktreePath $WorktreePath -BaseRoot $baseRoot -LiveWorktreeRoot $liveRoot -BranchWorktreeResolver $BranchWorktreeResolver
            }
            $arrayName = if ($kind -eq 'epic') { 'features' } else { 'items' }
            $recordText = if ($null -eq $record) {
                "no matching $arrayName[] record"
            }
            elseif (@($record.PSObject.Properties.Name) -contains 'merge_status') {
                "merge_status '$([string]$record.merge_status)'"
            }
            else {
                'merge_status absent'
            }
        }
        '{0} run {1} ({2}), {3}' -f $kind, $read.Target.Status, $pathText, $recordText
    }
    return ('Diagnostics: {0}; {1}.' -f $parts[0], $parts[1])
}
