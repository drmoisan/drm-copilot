# Launches one persisted parallel cohort batch through shared external-process and receipt cores.

[CmdletBinding(SupportsShouldProcess)]
param(
    [AllowEmptyString()][string] $LaunchSpecPath = '',
    [ValidateRange(1, 8)][int] $MaxParallel = 4,
    [switch] $Supervisor,
    [switch] $Wait,
    [AllowEmptyString()][string] $RepositoryRoot = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'parallel-child-launch-contract.ps1')
. (Join-Path $PSScriptRoot 'codex-child-launch-runtime.ps1')
. (Join-Path $PSScriptRoot 'codex-child-launch-persistence.ps1')
. (Join-Path $PSScriptRoot 'epic-child-launch-runtime.ps1')
. (Join-Path $PSScriptRoot 'epic-child-sandbox-preflight.ps1')

function Get-CodexParallelChildBatchOrder {
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory)] $Items,
        [Parameter(Mandatory)][ValidateRange(0, [int]::MaxValue)][int] $Cohort,
        [Parameter(Mandatory)][ValidateRange(0, [int]::MaxValue)][int] $Batch,
        [Parameter(Mandatory)][ValidateRange(1, 8)][int] $MaxConcurrency,
        [Parameter(Mandatory)][ValidateRange(0, [int]::MaxValue)][int] $AvailableThreadCount
    )

    $persisted = @($Items | Where-Object {
            [int]$_.cohort -eq $Cohort -and [int]$_.batch -eq $Batch -and
            [string]$_.state -notin @('merged', 'worktree_removed', 'abandoned')
        } | Sort-Object { [int]$_.issue_num })
    if ($persisted.Count -gt $MaxConcurrency) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: persisted batch exceeds max_concurrency.'
    }
    $null = $AvailableThreadCount
    return $persisted
}

function Get-CodexParallelOriginMainHead {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $RepositoryRoot)

    $head = Get-CodexChildGitScalar -GitArgs @(
        '-C', $RepositoryRoot, 'rev-parse', '--verify', 'refs/remotes/origin/main^{commit}'
    )
    if (-not (Test-CodexChildSha256 -Value $head)) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: origin/main did not resolve to a commit.'
    }
    return $head
}

function Initialize-CodexParallelChildWorktree {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)][string] $OriginMainHead
    )

    $worktree = Get-CodexChildCanonicalPath -Path ([string]$Entry.worktree_path) `
        -BasePath $RepositoryRoot
    if ($worktree -eq $RepositoryRoot) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: child worktree must be distinct from RepositoryRoot.'
    }
    if (-not (Test-Path -LiteralPath $worktree -PathType Container)) {
        if (-not $PSCmdlet.ShouldProcess($worktree, "Create branch $($Entry.branch_name) from origin/main")) {
            return $worktree
        }
        $null = Invoke-CodexChildGit -GitArgs @(
            '-C', $RepositoryRoot, 'worktree', 'add', '-b', [string]$Entry.branch_name,
            $worktree, $OriginMainHead
        )
    }
    $top = Get-CodexChildGitScalar -GitArgs @('-C', $worktree, 'rev-parse', '--show-toplevel')
    $branch = Get-CodexChildGitScalar -GitArgs @('-C', $worktree, 'branch', '--show-current')
    $head = Get-CodexChildGitScalar -GitArgs @('-C', $worktree, 'rev-parse', 'HEAD')
    if ((Get-CodexChildCanonicalPath -Path $top -BasePath $RepositoryRoot) -cne $worktree -or
        $branch -cne [string]$Entry.branch_name -or $head -cne $OriginMainHead) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: worktree, branch, or origin/main base commit differs.'
    }
    return $worktree
}

function Get-CodexParallelChildProcessStartInfo {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.ProcessStartInfo])]
    param(
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)] $AgentProfile,
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)][string] $LastMessagePath
    )

    $permissionOverride = Get-CodexParallelPermissionOverride `
        -DeniedPaths ([string[]]@($Receipt.codex_denied_paths))
    $projectsOverride = Get-CodexChildProjectsOverride `
        -WorktreePath ([string]$Receipt.worktree_path)
    $shellOverrides = Get-CodexChildShellEnvironmentOverrideList `
        -WorktreePath ([string]$Receipt.worktree_path)
    $startInfo = Get-CodexChildProcessStartInfoCore -Entry $Entry -AgentProfile $AgentProfile `
        -Receipt $Receipt -LastMessagePath $LastMessagePath `
        -RuntimePermissions 'parallel-child-workspace' `
        -EnvironmentPrefix 'CODEX_PARALLEL_CHILD' `
        -PermissionOverride $permissionOverride -ProjectsOverride $projectsOverride `
        -ShellOverrides $shellOverrides
    $startInfo = Add-CodexParallelMcpRestriction -StartInfo $startInfo
    foreach ($name in @($startInfo.Environment.Keys | Where-Object {
                [string]$_ -like 'CODEX_EPIC_*'
            })) {
        $startInfo.Environment.Remove([string]$name) | Out-Null
    }
    return $startInfo
}

function Get-CodexParallelPermissionOverride {
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyCollection()][string[]] $DeniedPaths = @())

    $entries = foreach ($path in $DeniedPaths) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }
        $key = ConvertTo-CodexChildTomlString -Value $path
        "$key = 'deny'"
    }
    return "permissions.parallel-child-workspace={ extends='orchestrator-workspace', filesystem={ $($entries -join ', ') }, network={ enabled=true } }"
}

function Add-CodexParallelMcpRestriction {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.ProcessStartInfo])]
    param([Parameter(Mandatory)][System.Diagnostics.ProcessStartInfo] $StartInfo)

    $allowed = @(
        'collect_commit_context', 'collect_pr_context', 'run_poshqc_format',
        'run_poshqc_analyze', 'run_poshqc_test', 'run_poshqc_analyze_autofix',
        'run_poshqc_suite', 'resolve_policy_audit_template_asset',
        'resolve_execute_hard_lock_prompt', 'resolve_atomic_plan_prompt',
        'validate_orchestration_artifacts'
    ) | ForEach-Object { ConvertTo-CodexChildTomlString -Value $_ }
    $blocked = @(
        'run_codex_native_converter', 'push_down_copilot_customizations',
        'push_down_codex_and_agents_customizations', 'push_down_claude_customizations',
        'new_potential_bug_entry', 'new_potential_entry', 'link_parent_child',
        'potential_to_issue', 'new_active_feature_folder'
    ) | ForEach-Object { ConvertTo-CodexChildTomlString -Value $_ }
    $index = $StartInfo.ArgumentList.IndexOf('--strict-config')
    if ($index -lt 0) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: strict config boundary is missing.'
    }
    foreach ($override in @(
            "mcp_servers.drm-copilot.enabled_tools=[$($allowed -join ', ')]",
            "mcp_servers.drm-copilot.disabled_tools=[$($blocked -join ', ')]"
        )) {
        $StartInfo.ArgumentList.Insert($index, '-c')
        $StartInfo.ArgumentList.Insert($index + 1, $override)
        $index += 2
    }
    return $StartInfo
}

function Write-CodexParallelChildJsonCreateNew {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)] $Value)

    $ensureDirectory = {
        param([string] $DirectoryPath)
        [System.IO.Directory]::CreateDirectory($DirectoryPath) | Out-Null
    }
    $openFile = {
        param([string] $FilePath)
        [System.IO.File]::Open(
            $FilePath,
            [System.IO.FileMode]::CreateNew,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None
        )
    }
    Write-CodexChildJsonCreateNewCore -Path $Path -Value $Value `
        -EnsureDirectory $ensureDirectory -OpenFile $openFile
}

function Write-CodexParallelChildJsonAtomic {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)] $Value)

    $createNew = { param([string] $FilePath, $FileValue) Write-CodexParallelChildJsonCreateNew $FilePath $FileValue }
    $moveFile = { param([string] $Source, [string] $Destination) Move-Item -LiteralPath $Source -Destination $Destination -Force }
    $deleteFile = { param([string] $FilePath) Remove-Item -LiteralPath $FilePath -Force }
    $pathExists = { param([string] $FilePath) Test-Path -LiteralPath $FilePath -PathType Leaf }
    Write-CodexChildJsonAtomicCore -Path $Path -Value $Value -CreateNew $createNew `
        -MoveFile $moveFile -DeleteFile $deleteFile -PathExists $pathExists
}

function Set-CodexParallelChildReceiptState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)][ValidateSet('launching', 'active', 'completed', 'failed')][string] $State,
        [AllowEmptyString()][string] $SessionId = '',
        [Nullable[int]] $ExitCode = $null,
        [AllowEmptyString()][string] $FailureReason = ''
    )

    if (-not $PSCmdlet.ShouldProcess([string]$Receipt.receipt_path, "Set parallel child state to $State")) {
        return
    }
    $writeReceipt = {
        param([string] $Path, $Value)
        Write-CodexParallelChildJsonAtomic -Path $Path -Value $Value
    }
    Set-CodexChildReceiptStateCore -Receipt $Receipt -State $State -SessionId $SessionId `
        -ExitCode $ExitCode -FailureReason $FailureReason `
        -ErrorPrefix 'PARALLEL_CHILD_LAUNCH_BLOCKED:' -WriteReceipt $writeReceipt -Confirm:$false
}

function Get-CodexParallelChildProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $WorktreePath,
        [Parameter(Mandatory)][string] $AgentName,
        [Parameter(Mandatory)][string] $OriginMainHead,
        [Parameter(Mandatory)][string] $RepositoryRoot
    )

    $profileData = Get-CodexChildTrustedProfile -WorktreePath $WorktreePath `
        -ChildHead $OriginMainHead -AgentName $AgentName
    $agentProfile = ConvertFrom-CodexAgentProfileCore -ProfileRaw ([string]$profileData.Raw)
    foreach ($item in ([ordered]@{
                profile_path            = [string]$profileData.Path
                profile_sha256          = [string]$profileData.Sha256
                worktree_path           = $WorktreePath
                trusted_repository_root = $RepositoryRoot
                child_head              = $OriginMainHead
            }).GetEnumerator()) {
        $agentProfile | Add-Member -NotePropertyName $item.Key -NotePropertyValue $item.Value
    }
    return $agentProfile
}

function Write-CodexParallelChildStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)] $Entry
    )

    $launches = [ordered]@{}
    $launches[[string]$Receipt.launch_id] = $Entry
    $status = [ordered]@{
        schema_version = 2
        state          = [string]$Entry.state
        launches       = $launches
        updated_at     = [datetimeoffset]::UtcNow.ToString('o')
    }
    Write-CodexParallelChildJsonAtomic -Path $Path -Value $status
}

function Start-CodexParallelChildProcess {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] $Context,
        [Parameter(Mandatory)] $Entry
    )

    $item = Get-CodexParallelCheckpointItem -Checkpoint $Context.Checkpoint -Entry $Entry
    $receiptPath = Get-CodexChildCanonicalPath -Path ([string]$item.launch_receipt_path) `
        -BasePath ([string]$Context.RepositoryRoot)
    $statusPath = Get-CodexChildCanonicalPath -Path ([string]$Entry.launch_status_path) `
        -BasePath ([string]$Context.RepositoryRoot)
    $key = Get-CodexChildProfileKey -WorktreePath ([string]$Entry.worktree_path) `
        -AgentName ([string]$Entry.deployment_agent) `
        -RepositoryRoot ([string]$Context.RepositoryRoot)
    $agentProfile = $Context.Profiles[$key]
    $codexHome = New-CodexChildIsolatedHome `
        -RepositoryRoot ([string]$Context.RepositoryRoot) `
        -WaveId ([string]$Context.Spec.parallel_slug) `
        -LaunchId ([string]$Entry.launch_id) `
        -OriginalAuthPath ([string]$Context.CodexRuntime.OriginalAuthPath) `
        -Confirm:$false
    $launchRuntime = [pscustomobject]@{
        CommandPath      = [string]$Context.CodexRuntime.CommandPath
        DeniedPaths      = [string[]]@($Context.CodexRuntime.DeniedPaths) + @(
            $codexHome,
            [string]$Context.RepositoryRoot
        )
        OriginalAuthPath = [string]$Context.CodexRuntime.OriginalAuthPath
    }
    $receipt = Get-CodexParallelChildLaunchReceipt `
        -Spec $Context.Spec -Entry $Entry -AgentProfile $agentProfile `
        -CodexRuntime $launchRuntime -SpecPath ([string]$Context.SpecPath) `
        -SpecSha256 ([string]$Context.SpecSha256) `
        -CheckpointPath ([string]$Context.CheckpointPath) `
        -CheckpointSha256 ([string]$Context.CheckpointSha256) `
        -ReceiptPath $receiptPath -StatusPath $statusPath `
        -CodexHomePath $codexHome -BatchLockPath ([string]$Context.BatchLockPath)
    Write-CodexParallelChildJsonCreateNew -Path $receiptPath -Value $receipt
    $probe = Get-CodexChildSandboxProbeStartInfo `
        -WorktreePath ([string]$Entry.worktree_path) -CodexHomePath $codexHome `
        -CommandPath ([string]$launchRuntime.CommandPath) `
        -DeniedPaths ([string[]]$launchRuntime.DeniedPaths) `
        -DeniedProbePath ([string]$launchRuntime.OriginalAuthPath)
    Assert-CodexChildSandboxPreflight -StartInfo $probe
    $startInfo = Get-CodexParallelChildProcessStartInfo -Entry $Entry `
        -AgentProfile $agentProfile -Receipt $receipt `
        -LastMessagePath (Join-Path (Split-Path $receiptPath -Parent) `
            "$($Entry.launch_id).last-message.txt")
    $setReceiptState = {
        param($ReceiptValue, [string] $StateValue, [string] $SessionIdValue,
            [Nullable[int]] $ExitCodeValue, [string] $FailureReasonValue)
        Set-CodexParallelChildReceiptState -Receipt $ReceiptValue `
            -State $StateValue -SessionId $SessionIdValue `
            -ExitCode $ExitCodeValue -FailureReason $FailureReasonValue -Confirm:$false
    }
    $child = Start-CodexChildProcessCore -Entry $Entry -Receipt $receipt `
        -ArtifactRoot (Split-Path $receiptPath -Parent) -StartInfo $startInfo `
        -SurfaceLabel parallel -ErrorPrefix 'PARALLEL_CHILD_LAUNCH_BLOCKED:' `
        -SetReceiptState $setReceiptState -Confirm:$false
    $child | Add-Member -NotePropertyName ReceiptPath -NotePropertyValue $receiptPath
    $child | Add-Member -NotePropertyName StatusPath -NotePropertyValue $statusPath
    $runningStatus = [ordered]@{
        state = 'running'; pid = $child.Process.Id; launch_id = [string]$Entry.launch_id
        codex_session_id = $child.SessionId; receipt_path = $receiptPath
        spec_sha256       = [string]$Context.SpecSha256
        checkpoint_sha256 = [string]$Context.CheckpointSha256
        started_at        = $child.StartedAt
    }
    Write-CodexParallelChildStatus -Path $statusPath -Receipt $receipt -Entry $runningStatus
    return $child
}

function Complete-CodexParallelChildProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Context,
        [Parameter(Mandatory)] $Child,
        [scriptblock] $WriteText = {
            param([string] $Path, [string] $Value)
            [System.IO.File]::WriteAllText($Path, $Value)
        }
    )

    $result = Complete-CodexChildProcessCore -Child $Child
    & $WriteText "$($Child.BasePath).stdout.jsonl" ([string]$result.output)
    & $WriteText "$($Child.BasePath).stderr.log" ([string]$result.error)
    if ([int]$result.exit_code -eq 0) {
        Set-CodexParallelChildReceiptState -Receipt $Child.Receipt -State completed `
            -ExitCode 0 -Confirm:$false
    } else {
        Set-CodexParallelChildReceiptState -Receipt $Child.Receipt -State failed `
            -ExitCode ([int]$result.exit_code) `
            -FailureReason 'Codex parallel child returned a nonzero exit code.' -Confirm:$false
    }
    Remove-CodexChildIsolatedAuth -HomePath ([string]$Child.Receipt.codex_home_path) -Confirm:$false
    $resumeScript = Join-Path ([string]$Child.Entry.worktree_path) `
        '.codex/scripts/resume-parallel-child.ps1'
    $terminal = Get-CodexChildTerminalStatusEntryCore -Child $Child `
        -ReceiptPath ([string]$Child.ReceiptPath) -ResumeScriptPath $resumeScript
    $terminal.launch_id = [string]$Child.Entry.launch_id
    $terminal.spec_sha256 = [string]$Context.SpecSha256
    $terminal.checkpoint_sha256 = [string]$Context.CheckpointSha256
    Write-CodexParallelChildStatus -Path ([string]$Child.StatusPath) `
        -Receipt $Child.Receipt -Entry $terminal
    return $terminal
}

function Start-CodexParallelChildBatch {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] $Context)

    $queue = [System.Collections.Generic.Queue[object]]::new()
    foreach ($entry in @($Context.OrderedLaunches)) { $queue.Enqueue($entry) }
    $running = [System.Collections.Generic.List[object]]::new()
    $terminal = [ordered]@{}
    while ($queue.Count -gt 0 -or $running.Count -gt 0) {
        $available = Get-CodexChildAvailableLaunchCount -Maximum ([int]$Context.Maximum) `
            -RunningCount $running.Count -QueuedCount $queue.Count
        while ($available -gt 0) {
            $entry = $queue.Dequeue()
            $running.Add((Start-CodexParallelChildProcess -Context $Context `
                        -Entry $entry -Confirm:$false))
            $available--
        }
        if ($running.Count -eq 0) { continue }
        [System.Threading.Tasks.Task]::WaitAny(
            [System.Threading.Tasks.Task[]]@($running | ForEach-Object ExitTask)
        ) | Out-Null
        foreach ($child in @($running | Where-Object { $_.ExitTask.IsCompleted })) {
            $terminal[[string]$child.Entry.launch_id] = Complete-CodexParallelChildProcess `
                -Context $Context -Child $child
            $running.Remove($child) | Out-Null
        }
    }
    return $terminal
}

function Invoke-CodexParallelChildBatch {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $SpecPath,
        [Parameter(Mandatory)][string] $Root,
        [Parameter(Mandatory)][ValidateRange(1, 8)][int] $Maximum
    )

    $specPathFull = Get-CodexChildCanonicalPath -Path $SpecPath -BasePath $Root
    $specSeal = Get-CodexChildSealedJsonFileCore -Path $specPathFull `
        -Name 'parallel launch spec' -ErrorPrefix 'PARALLEL_CHILD_LAUNCH_BLOCKED:'
    $spec = $specSeal.Value
    $checkpointPath = Get-CodexChildCanonicalPath -Path ([string]$spec.checkpoint_path) -BasePath $Root
    $checkpointSeal = Get-CodexChildSealedJsonFileCore -Path $checkpointPath `
        -Name 'parallel checkpoint' -ErrorPrefix 'PARALLEL_CHILD_LAUNCH_BLOCKED:'
    $checkpoint = $checkpointSeal.Value
    $originMainHead = Get-CodexParallelOriginMainHead -RepositoryRoot $Root
    if ([string]$spec.origin_main_head -cne $originMainHead) {
        throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: sealed origin/main commit changed.'
    }
    $maximumEffective = Get-CodexChildEffectiveMaximum `
        -RequestedMaximum $Maximum -SpecMaximum ([int]$spec.max_concurrency)
    $ordered = @(Get-CodexParallelChildBatchOrder -Items $spec.launches `
            -Cohort ([int]$spec.cohort) -Batch ([int]$spec.batch) `
            -MaxConcurrency ([int]$spec.max_concurrency) -AvailableThreadCount $maximumEffective)
    $profiles = @{}; $branches = @{}
    foreach ($entry in $ordered) {
        $worktree = Initialize-CodexParallelChildWorktree -RepositoryRoot $Root `
            -Entry $entry -OriginMainHead $originMainHead -Confirm:$false
        $agentProfile = Get-CodexParallelChildProfile -WorktreePath $worktree `
            -AgentName ([string]$entry.deployment_agent) -OriginMainHead $originMainHead `
            -RepositoryRoot $Root
        $key = Get-CodexChildProfileKey -WorktreePath $worktree `
            -AgentName ([string]$entry.deployment_agent) -RepositoryRoot $Root
        $profiles[$key] = $agentProfile; $branches[$worktree] = [string]$entry.branch_name
    }
    $errors = Test-CodexParallelChildLaunchSpec -Spec $spec -Checkpoint $checkpoint `
        -RepositoryRoot $Root -ProfilesByKey $profiles -LiveBranchesByWorktree $branches `
        -VerifiedOriginMainHead $originMainHead
    if ($errors.Count -gt 0) {
        throw "PARALLEL_CHILD_LAUNCH_BLOCKED: $($errors -join ' ')"
    }
    $batchLockPath = Join-Path (Split-Path $specPathFull -Parent) `
        "parallel.$($spec.parallel_slug).cohort.$($spec.cohort).batch.$($spec.batch).lock"
    $context = [pscustomobject]@{
        Spec = $spec; Checkpoint = $checkpoint; OrderedLaunches = $ordered
        Profiles = $profiles; OriginMainHead = $originMainHead; Maximum = $maximumEffective
        RepositoryRoot = $Root; SpecPath = $specPathFull; CheckpointPath = $checkpointPath
        SpecSha256 = [string]$specSeal.Sha256; CheckpointSha256 = [string]$checkpointSeal.Sha256
        BatchLockPath = $batchLockPath; CodexRuntime = Get-CodexChildCommandContext
    }
    $batchLock = Enter-CodexChildScheduleLockCore -Path $batchLockPath `
        -ScheduleKind batch -ErrorPrefix 'PARALLEL_CHILD_LAUNCH_BLOCKED:'
    try {
        return Start-CodexParallelChildBatch -Context $context -Confirm:$false
    } finally {
        $batchLock.Dispose()
    }
}

if ($MyInvocation.InvocationName -eq '.') { return }
if ([string]::IsNullOrWhiteSpace($LaunchSpecPath)) {
    throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: LaunchSpecPath is required.'
}
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (Get-CodexChildGitScalar -GitArgs @('rev-parse', '--show-toplevel')).Trim()
}
$repositoryRootPath = Get-CodexChildCanonicalPath -Path $RepositoryRoot `
    -BasePath (Get-Location).Path
if ($Supervisor -or $Wait) {
    Invoke-CodexParallelChildBatch -SpecPath $LaunchSpecPath `
        -Root $repositoryRootPath -Maximum $MaxParallel -Confirm:$false
    exit 0
}
$supervisorInfo = [System.Diagnostics.ProcessStartInfo]::new('pwsh')
$supervisorInfo.UseShellExecute = $false
$supervisorInfo.CreateNoWindow = $true
$supervisorInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
foreach ($argument in @('-NoProfile', '-File', $PSCommandPath, '-LaunchSpecPath',
        $LaunchSpecPath, '-RepositoryRoot', $repositoryRootPath, '-MaxParallel',
        [string]$MaxParallel, '-Supervisor')) {
    $supervisorInfo.ArgumentList.Add($argument)
}
$supervisorProcess = [System.Diagnostics.Process]::Start($supervisorInfo)
if ($null -eq $supervisorProcess) {
    throw 'PARALLEL_CHILD_LAUNCH_BLOCKED: failed to start the background supervisor.'
}
[ordered]@{
    parallel_slug  = Split-Path (Split-Path $LaunchSpecPath -Parent) -Leaf
    supervisor_pid = $supervisorProcess.Id
} | ConvertTo-Json -Compress | Write-Output
