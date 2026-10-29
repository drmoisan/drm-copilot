<#
.SYNOPSIS
    Adopted feature-folder probe for the orchestrator SubagentStop hook validate-orchestrator-output.ps1 (issue #992).

.DESCRIPTION
    Dot-sourced by validate-orchestrator-output.ps1 through a guarded load whose catch records the
    failure with Add-HookDependencyFailure, so a missing or broken copy of this file blocks the hook
    instead of failing open. It defines Invoke-FeatureFolderGitExe, the single git seam, and
    Get-OrchestratorOutputFeatureFolderDecision.

    When an orchestrator-state checkpoint waives new_active_feature_folder through
    issue_adoption.waived_tools, the validators accept a declared feature_folder_record but cannot
    read the repository. This probe confirms that HEAD of the run worktree holds a tree at the
    checkpoint feature-folder, so a staged-only, untracked, or absent folder blocks. It proves only
    that a tree exists at that path at stop time; it does not prove which tool created the folder
    or that its contents are correct.

    The file imports nothing. Test-OrchestratorStateFeatureFolderPath comes from
    OrchestratorStateFeatureFolderRecord.psm1, which the main hook imports through its own guarded
    load. The file invokes no Python.
#>

$script:FeatureFolderProbeTool = 'new_active_feature_folder'

function Invoke-FeatureFolderGitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments. The single executable seam of the feature-folder probe.
    .DESCRIPTION
        Never throws: a git that cannot start, or an invoker that throws, returns ExitCode -1 so the
        caller blocks instead of failing open. The default invoker merges standard error into Output;
        success requires the exact output tree, so error text is never read as success.
    .PARAMETER GitArgs
        The git arguments.
    .PARAMETER GitInvoker
        The scriptblock that runs git; a unit test passes a test-local stand-in that sets
        $global:LASTEXITCODE, so this body runs without starting a process.
    .OUTPUTS
        System.Collections.Hashtable with keys ExitCode (int) and Output (string, trimmed).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $GitArgs,

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [scriptblock] $GitInvoker = { git @args 2>&1 }
    )

    try {
        $lines = @(& $GitInvoker @GitArgs)
        $code = $LASTEXITCODE
    }
    catch {
        return @{ ExitCode = -1; Output = '' }
    }
    if ($null -eq $code) { $code = -1 }
    return @{ ExitCode = [int]$code; Output = ((@($lines | ForEach-Object { [string]$_ }) -join "`n").Trim()) }
}

function Test-FeatureFolderProbeWaived {
    <#
    .SYNOPSIS
        Report whether the checkpoint's issue_adoption.waived_tools lists new_active_feature_folder.
    .PARAMETER Checkpoint
        The parsed checkpoint object. May be $null.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Checkpoint
    )

    if ($Checkpoint -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    $adoptionProperty = $Checkpoint.PSObject.Properties['issue_adoption']
    if ($null -eq $adoptionProperty -or $adoptionProperty.Value -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    $waivedProperty = $adoptionProperty.Value.PSObject.Properties['waived_tools']
    if ($null -eq $waivedProperty -or $waivedProperty.Value -isnot [System.Array]) { return $false }
    return (@($waivedProperty.Value | Where-Object { $_ -is [string] }) -ccontains $script:FeatureFolderProbeTool)
}

function Get-OrchestratorOutputFeatureFolderDecision {
    <#
    .SYNOPSIS
        Confirm that HEAD of the run worktree holds a tree at the adopted feature-folder.
    .DESCRIPTION
        Returns @{ Ok = $true; Message = $null } when the checkpoint does not waive
        new_active_feature_folder. Otherwise the checkpoint feature-folder is re-checked against the
        shared path pattern before any git call (a failing path never reaches git), and
        git -C <WorktreeRoot> cat-file -t HEAD:<feature-folder> must exit 0 and print exactly tree.
        Every other outcome (non-zero exit, -1, empty output, other output) blocks with a repairable
        ROUTING_CONTRACT_BLOCKED message naming the path.
    .PARAMETER Checkpoint
        The parsed checkpoint object. May be $null.
    .PARAMETER WorktreeRoot
        The root of the worktree whose run stopped.
    .PARAMETER GitInvoker
        Optional. Forwarded to Invoke-FeatureFolderGitExe; omitted, the seam's default runs git.
    .OUTPUTS
        System.Collections.Hashtable with keys Ok, Message, and (on a block) Repairable.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Checkpoint,

        [Parameter(Mandatory = $true)]
        [string] $WorktreeRoot,

        [Parameter(Mandatory = $false)]
        [scriptblock] $GitInvoker
    )

    if (-not (Test-FeatureFolderProbeWaived -Checkpoint $Checkpoint)) {
        return @{ Ok = $true; Message = $null }
    }

    $folderProperty = $Checkpoint.PSObject.Properties['feature-folder']
    $folder = if ($null -ne $folderProperty) { $folderProperty.Value } else { $null }
    $blocked = @{ Ok = $false; Repairable = $true; Message = ('ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: {0}.' -f [string]$folder) }
    # Defense in depth: the validators already require the record path to match the pattern and to
    # equal feature-folder, but a value that fails the pattern must never become a git argument.
    if (-not (Test-OrchestratorStateFeatureFolderPath -Value $folder)) {
        return $blocked
    }

    $gitArgs = [string[]]@('-C', $WorktreeRoot, 'cat-file', '-t', ('HEAD:' + [string]$folder))
    $probe = if ($PSBoundParameters.ContainsKey('GitInvoker') -and $null -ne $GitInvoker) {
        Invoke-FeatureFolderGitExe -GitArgs $gitArgs -GitInvoker $GitInvoker
    }
    else {
        Invoke-FeatureFolderGitExe -GitArgs $gitArgs
    }
    if (($probe.ExitCode -eq 0) -and [string]::Equals([string]$probe.Output, 'tree', [System.StringComparison]::Ordinal)) {
        return @{ Ok = $true; Message = $null }
    }
    return $blocked
}
