# Resumes one receipt-bound parallel child through shared authoritative reconciliation.

[CmdletBinding(SupportsShouldProcess)]
param(
    [AllowEmptyString()][string] $ReceiptPath = '',
    [AllowEmptyString()][string] $Prompt = '',
    [AllowEmptyString()][string] $LastMessagePath = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'launch-parallel-child-batch.ps1')
. (Join-Path $PSScriptRoot 'codex-child-launch-resume.ps1')
. (Join-Path $PSScriptRoot 'parallel-child-post-session.ps1')

function Get-CodexParallelFirstIncompleteItem {
    [CmdletBinding()]
    param([Parameter(Mandatory)] $Checkpoint)

    return @($Checkpoint.items | Where-Object {
            [string]$_.state -notin @('merged', 'worktree_removed', 'abandoned')
        } | Sort-Object `
        { [int]$_.cohort },
        { [int]$_.batch },
        { [int]$_.issue_num } | Select-Object -First 1)[0]
}

function Test-CodexParallelChildResumeEvidence {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)] $Spec,
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)] $Status,
        [AllowNull()] $LiveTruth,
        [switch] $RequireCompleteEvidence
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    foreach ($value in @($Receipt, $Spec, $Checkpoint, $Status)) {
        if ($null -eq $value -or ($null -ne $value -and (Test-CodexParallelForbiddenState -Value $value))) {
            $errors.Add('parallel resume evidence must not contain integration or fan-in state.')
        }
    }
    if ([string]$Receipt.surface -cne 'parallel' -or [string]$Spec.surface -cne 'parallel') {
        $errors.Add('parallel resume requires the parallel launch surface.')
    }
    if ([string]$Spec.base_branch -cne 'main' -or [string]$Spec.pr_target -cne 'main') {
        $errors.Add('parallel resume requires main as both base and PR target.')
    }

    $entries = @($Spec.launches | Where-Object {
            [string]$_.launch_id -ceq [string]$Receipt.launch_id
        })
    if ($entries.Count -ne 1) {
        $errors.Add('parallel resume requires one exact launch entry.')
        return $errors.ToArray()
    }
    $entry = $entries[0]
    $item = Get-CodexParallelCheckpointItem -Checkpoint $Checkpoint -Entry $entry
    if ($null -eq $item) {
        $errors.Add('parallel resume requires one exact checkpoint item.')
        return $errors.ToArray()
    }

    foreach ($name in @(
            'issue_num', 'worktree_path', 'branch_name', 'deployment_agent', 'model',
            'model_reasoning_effort', 'permissions'
        )) {
        if ([string]$Receipt.$name -cne [string]$entry.$name) {
            $errors.Add("parallel resume $name differs from the sealed launch entry.")
        }
    }
    if ([string]$Receipt.runtime_permissions -cne 'parallel-child-workspace') {
        $errors.Add('parallel resume runtime permissions differ from the sealed child profile.')
    }
    if ([string]$item.worktree_path -cne [string]$Receipt.worktree_path -or
        [string]$item.branch -cne [string]$Receipt.branch_name) {
        $errors.Add('parallel resume worktree or branch differs from the checkpoint item.')
    }
    $firstIncomplete = Get-CodexParallelFirstIncompleteItem -Checkpoint $Checkpoint
    if ($null -eq $firstIncomplete -or
        -not (Test-CodexChildIssueEqual -Left $firstIncomplete.issue_num -Right $Receipt.issue_num)) {
        $errors.Add('parallel resume must select the first incomplete persisted cohort, batch, and item.')
    }

    $statusNames = @($Status.PSObject.Properties.Name)
    if ($statusNames -contains 'launch_id' -and
        [string]$Status.launch_id -cne [string]$Receipt.launch_id) {
        $errors.Add('parallel resume child status launch_id differs from the receipt.')
    }
    if ([string]$Status.spec_sha256 -cne [string]$Receipt.spec_sha256 -or
        [string]$Status.checkpoint_sha256 -cne [string]$Receipt.checkpoint_sha256) {
        $errors.Add('resume launch hashes do not match the sealed evidence.')
    }
    if ($RequireCompleteEvidence) {
        foreach ($name in @(
                'authority_receipt_path', 'delegation_receipt_path', 'topology_receipt_path',
                'model_routing_receipt_path', 'child_status_path', 'origin_main_head'
            )) {
            if (@($Receipt.PSObject.Properties.Name) -notcontains $name -or
                [string]::IsNullOrWhiteSpace([string]$Receipt.$name)) {
                $errors.Add("parallel resume receipt is missing $name.")
            }
        }
        if ([string]$Receipt.child_status_path -cne [string]$entry.launch_status_path) {
            $errors.Add('parallel resume child-status path differs from the launch entry.')
        }
    }
    if ($PSBoundParameters.ContainsKey('LiveTruth')) {
        if ($null -eq $LiveTruth) {
            $errors.Add('PARALLEL_RESUME_TRUTH_REQUIRED')
            return $errors.ToArray()
        }
        $truthNames = @($LiveTruth.PSObject.Properties.Name)
        if ((Test-CodexParallelForbiddenState -Value $LiveTruth) -or
            @($truthNames | Where-Object { $_ -in @('fan_in_pr', 'fan_in_pr_url') }).Count -gt 0) {
            $errors.Add('PARALLEL_RESUME_FAN_IN_FORBIDDEN')
        }
        $requiredTruth = @(
            'schema_version', 'selected_issue_num', 'repository', 'origin_main_head',
            'worktree_path', 'branch_name', 'worktree_head', 'pr_number',
            'pr_base_branch', 'pr_head_branch', 'pr_head_sha', 'pr_state',
            'checks_head_sha', 'checks_conclusion', 'launch_id', 'spec_sha256',
            'checkpoint_sha256', 'latest_mutation_sequence', 'recolor_generation',
            'drift_resolution_generation', 'unresolved_drift', 'authority_receipt_path',
            'delegation_receipt_path', 'topology_receipt_path',
            'model_routing_receipt_path', 'deployment_agent', 'model',
            'model_reasoning_effort', 'permissions', 'child_status_path',
            'child_status_launch_id', 'child_status_pid', 'live_process_pid',
            'live_process_running', 'should_relaunch'
        )
        if ([int]$LiveTruth.schema_version -ne 1 -or
            @($requiredTruth | Where-Object { $truthNames -notcontains $_ }).Count -gt 0) {
            $errors.Add('PARALLEL_RESUME_TRUTH_INVALID')
        }
        if (-not (Test-CodexChildIssueEqual -Left $LiveTruth.selected_issue_num -Right $Receipt.issue_num)) {
            $errors.Add('PARALLEL_RESUME_ORDER_MISMATCH')
        }
        $duplicateIdentity = $false
        foreach ($name in @('launch_id', 'worktree_path', 'branch_name', 'pr_number')) {
            $seenValues = @{}
            foreach ($checkpointItem in @($Checkpoint.items)) {
                $value = [string]$checkpointItem.$name
                if ([string]$checkpointItem.state -ceq 'withdrawn' -or
                    [string]::IsNullOrWhiteSpace($value)) {
                    continue
                }
                if ($seenValues.ContainsKey($value)) {
                    $duplicateIdentity = $true
                    break
                }
                $seenValues[$value] = $true
            }
            if ($duplicateIdentity) {
                break
            }
        }
        if ($duplicateIdentity) {
            $errors.Add('PARALLEL_RESUME_IDENTITY_DUPLICATE')
        }
        if ([string]$LiveTruth.repository -cne [string]$Receipt.repository -or
            [string]$LiveTruth.repository -cne [string]$Spec.repository -or
            [string]$LiveTruth.origin_main_head -cne [string]$Receipt.origin_main_head) {
            $errors.Add('PARALLEL_RESUME_GIT_MISMATCH')
        }
        if ([string]$LiveTruth.worktree_path -cne [string]$Receipt.worktree_path -or
            [string]$LiveTruth.branch_name -cne [string]$Receipt.branch_name) {
            $errors.Add('PARALLEL_RESUME_WORKTREE_MISMATCH')
        }
        if ([int]$LiveTruth.pr_number -le 0 -or
            [string]$LiveTruth.pr_base_branch -cne 'main' -or
            [string]$LiveTruth.pr_head_branch -cne [string]$Receipt.branch_name -or
            [string]$LiveTruth.pr_head_sha -cne [string]$LiveTruth.worktree_head -or
            [string]$LiveTruth.checks_head_sha -cne [string]$LiveTruth.pr_head_sha -or
            [string]$LiveTruth.checks_conclusion -cne 'success' -or
            [string]$LiveTruth.pr_state -cne 'OPEN') {
            $errors.Add('PARALLEL_RESUME_GITHUB_MISMATCH')
        }
        if ([string]$LiveTruth.launch_id -cne [string]$Receipt.launch_id -or
            [string]$LiveTruth.spec_sha256 -cne [string]$Receipt.spec_sha256 -or
            [string]$LiveTruth.checkpoint_sha256 -cne [string]$Receipt.checkpoint_sha256) {
            $errors.Add('PARALLEL_RESUME_LAUNCH_MISMATCH')
        }
        $mutationSequences = @($Checkpoint.mutations | ForEach-Object {
                if ($null -ne $_.sequence) { [int]$_.sequence }
            })
        $latestMutation = if ($mutationSequences.Count -eq 0) {
            0
        } else {
            [int]($mutationSequences | Measure-Object -Maximum).Maximum
        }
        if ([int]$LiveTruth.latest_mutation_sequence -ne $latestMutation) {
            $errors.Add('PARALLEL_RESUME_MUTATION_MISMATCH')
        }
        if ([bool]$LiveTruth.unresolved_drift -or
            [int]$LiveTruth.recolor_generation -ne [int]$Checkpoint.recolor_generation -or
            [int]$LiveTruth.drift_resolution_generation -ne [int]$Checkpoint.recolor_generation) {
            $errors.Add('PARALLEL_RESUME_DRIFT_UNRESOLVED')
        }
        foreach ($name in @(
                'authority_receipt_path', 'delegation_receipt_path',
                'topology_receipt_path', 'model_routing_receipt_path',
                'deployment_agent', 'model', 'model_reasoning_effort', 'permissions'
            )) {
            if ([string]$LiveTruth.$name -cne [string]$Receipt.$name) {
                $errors.Add('PARALLEL_RESUME_ROUTING_MISMATCH')
                break
            }
        }
        if ([string]$LiveTruth.child_status_path -cne [string]$Receipt.child_status_path -or
            [string]$LiveTruth.child_status_launch_id -cne [string]$Receipt.launch_id -or
            [int]$LiveTruth.child_status_pid -ne [int]$LiveTruth.live_process_pid -or
            [int]$LiveTruth.child_status_pid -ne [int]$Status.pid) {
            $errors.Add('PARALLEL_RESUME_CHILD_STATUS_MISMATCH')
        }
        if ([bool]$LiveTruth.live_process_running -and [bool]$LiveTruth.should_relaunch) {
            $errors.Add('PARALLEL_RESUME_PROCESS_RUNNING')
        } elseif (-not [bool]$LiveTruth.live_process_running -and
            -not [bool]$LiveTruth.should_relaunch) {
            $errors.Add('PARALLEL_RESUME_RELAUNCH_NOT_AUTHORIZED')
        }
    }
    return $errors.ToArray()
}

function Get-CodexParallelChildResumeLiveTruth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)] $Status,
        [Parameter(Mandatory)][string] $OriginMainHead,
        [Parameter(Mandatory)][string] $WorktreePath,
        [Parameter(Mandatory)][string] $BranchName,
        [Parameter(Mandatory)][string] $WorktreeHead,
        [scriptblock] $InvokeGh = (Get-CodexParallelPostSessionDefaultGhInvoker)
    )

    $items = @($Checkpoint.items | Where-Object {
            Test-CodexChildIssueEqual -Left $_.issue_num -Right $Receipt.issue_num
        })
    if ($items.Count -ne 1) {
        throw 'PARALLEL_RESUME_ORDER_MISMATCH'
    }
    try {
        $pr = Get-CodexParallelPostSessionPr -Item $items[0] `
            -HeadSha $WorktreeHead -InvokeGh $InvokeGh
        $checks = Get-CodexParallelPostSessionCheckReceipt -PrNumber ([int]$pr.number) `
            -HeadSha $WorktreeHead -InvokeGh $InvokeGh `
            -VerifiedAt ([DateTimeOffset]::UtcNow.ToString('o'))
    } catch {
        throw "PARALLEL_RESUME_GITHUB_MISMATCH: $($_.Exception.Message)"
    }
    $mutationSequences = @($Checkpoint.mutations | ForEach-Object {
            if ($null -ne $_.sequence) { [int]$_.sequence }
        })
    $latestMutation = if ($mutationSequences.Count -eq 0) {
        0
    } else {
        [int]($mutationSequences | Measure-Object -Maximum).Maximum
    }
    $unresolvedDrift = @($Checkpoint.drift_events | Where-Object {
            [string]$_.status -cne 'resolved'
        }).Count -gt 0
    $processId = [int]$Status.pid
    $liveProcess = if ($processId -gt 0) {
        Get-Process -Id $processId -ErrorAction SilentlyContinue
    } else {
        $null
    }
    return [pscustomobject]@{
        schema_version              = 1
        selected_issue_num          = $Receipt.issue_num
        repository                  = $Receipt.repository
        origin_main_head            = $OriginMainHead
        worktree_path               = $WorktreePath
        branch_name                 = $BranchName
        worktree_head               = $WorktreeHead
        pr_number                   = $pr.number
        pr_base_branch              = $pr.baseRefName
        pr_head_branch              = $pr.headRefName
        pr_head_sha                 = $pr.headRefOid
        pr_state                    = $pr.state
        checks_head_sha             = $checks.head_sha
        checks_conclusion           = $checks.conclusion
        launch_id                   = $Receipt.launch_id
        spec_sha256                 = $Receipt.spec_sha256
        checkpoint_sha256           = $Receipt.checkpoint_sha256
        latest_mutation_sequence    = $latestMutation
        recolor_generation          = $Checkpoint.recolor_generation
        drift_resolution_generation = $Checkpoint.recolor_generation
        unresolved_drift            = $unresolvedDrift
        authority_receipt_path      = $Receipt.authority_receipt_path
        delegation_receipt_path     = $Receipt.delegation_receipt_path
        topology_receipt_path       = $Receipt.topology_receipt_path
        model_routing_receipt_path  = $Receipt.model_routing_receipt_path
        deployment_agent            = $Receipt.deployment_agent
        model                       = $Receipt.model
        model_reasoning_effort      = $Receipt.model_reasoning_effort
        permissions                 = $Receipt.permissions
        child_status_path           = $Receipt.child_status_path
        child_status_launch_id      = $Status.launch_id
        child_status_pid            = $processId
        live_process_pid            = $processId
        live_process_running        = $null -ne $liveProcess
        should_relaunch             = $null -eq $liveProcess
    }
}

function Get-CodexParallelChildResumeContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [scriptblock] $GetLiveTruth = ${function:Get-CodexParallelChildResumeLiveTruth}
    )

    if (-not [System.IO.Path]::IsPathFullyQualified($Path)) {
        throw 'PARALLEL_CHILD_RESUME_BLOCKED: ReceiptPath must be absolute.'
    }
    $receiptPathFull = Get-CodexChildCanonicalPath -Path $Path -BasePath (Get-Location).Path
    $receipt = ConvertFrom-CodexChildLaunchJsonCore `
        -Raw (Get-Content -Raw -LiteralPath $receiptPathFull) -Name 'parallel launch receipt'
    $root = Get-CodexChildCanonicalPath -Path ([string]$receipt.trusted_repository_root) `
        -BasePath (Get-Location).Path
    $specPath = Get-CodexChildCanonicalPath -Path ([string]$receipt.spec_path) -BasePath $root
    $checkpointPath = Get-CodexChildCanonicalPath -Path ([string]$receipt.checkpoint_path) -BasePath $root
    if ((Get-FileHash -LiteralPath $specPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne
        [string]$receipt.spec_sha256 -or
        (Get-FileHash -LiteralPath $checkpointPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne
        [string]$receipt.checkpoint_sha256) {
        throw 'PARALLEL_CHILD_RESUME_BLOCKED: sealed launch or checkpoint hash changed.'
    }
    $spec = ConvertFrom-CodexChildLaunchJsonCore `
        -Raw (Get-Content -Raw -LiteralPath $specPath) -Name 'parallel launch spec'
    $checkpoint = ConvertFrom-CodexChildLaunchJsonCore `
        -Raw (Get-Content -Raw -LiteralPath $checkpointPath) -Name 'parallel checkpoint'
    $statusPath = Get-CodexChildCanonicalPath -Path ([string]$receipt.status_path) -BasePath $root
    $status = ConvertFrom-CodexChildLaunchJsonCore `
        -Raw (Get-Content -Raw -LiteralPath $statusPath) -Name 'parallel child status'
    $statusEntry = Get-CodexChildResumeStatusEntryCore `
        -Status $status -LaunchId ([string]$receipt.launch_id)
    foreach ($name in @('spec_sha256', 'checkpoint_sha256', 'launch_id')) {
        if (@($statusEntry.PSObject.Properties.Name) -notcontains $name) {
            $statusEntry | Add-Member -NotePropertyName $name -NotePropertyValue $receipt.$name
        }
    }
    $evidenceErrors = Test-CodexParallelChildResumeEvidence -Receipt $receipt `
        -Spec $spec -Checkpoint $checkpoint -Status $statusEntry -RequireCompleteEvidence
    $getLiveProcess = {
        param([int] $ProcessId)
        try {
            return Get-Process -Id $ProcessId -ErrorAction Stop
        } catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
            return $null
        }
    }
    $evidenceErrors += @(Get-CodexChildResumeReconciliationCore -Receipt $receipt `
            -Spec $spec -Status $status -ReceiptPath $receiptPathFull `
            -GetLiveProcess $getLiveProcess)
    if ($evidenceErrors.Count -gt 0) {
        throw "PARALLEL_CHILD_RESUME_BLOCKED: $($evidenceErrors -join ' ')"
    }

    $originMainHead = Get-CodexParallelOriginMainHead -RepositoryRoot $root
    $worktree = Get-CodexChildCanonicalPath -Path ([string]$receipt.worktree_path) -BasePath $root
    $branch = Get-CodexChildGitScalar -GitArgs @('-C', $worktree, 'branch', '--show-current')
    $childHead = Get-CodexChildGitScalar -GitArgs @('-C', $worktree, 'rev-parse', 'HEAD')
    if ($originMainHead -cne [string]$receipt.origin_main_head -or
        $branch -cne [string]$receipt.branch_name -or
        -not (Test-CodexChildGit -GitArgs @(
                '-C', $worktree, 'merge-base', '--is-ancestor', $originMainHead, $childHead
            ))) {
        throw 'PARALLEL_CHILD_RESUME_BLOCKED: live origin/main, branch, or worktree ancestry differs.'
    }
    $liveTruth = & $GetLiveTruth -Receipt $receipt -Checkpoint $checkpoint `
        -Status $statusEntry -OriginMainHead $originMainHead -WorktreePath $worktree `
        -BranchName $branch -WorktreeHead $childHead
    $liveErrors = Test-CodexParallelChildResumeEvidence -Receipt $receipt `
        -Spec $spec -Checkpoint $checkpoint -Status $statusEntry -LiveTruth $liveTruth `
        -RequireCompleteEvidence
    if ($liveErrors.Count -gt 0) {
        throw "PARALLEL_CHILD_RESUME_BLOCKED: $($liveErrors -join ' ')"
    }
    $agentProfile = Get-CodexParallelChildProfile -WorktreePath $worktree `
        -AgentName ([string]$receipt.deployment_agent) -OriginMainHead $childHead `
        -RepositoryRoot $root
    return [pscustomobject]@{
        Receipt = $receipt; Spec = $spec; Checkpoint = $checkpoint
        Status = $status; StatusEntry = $statusEntry; Profile = $agentProfile
        RepositoryRoot = $root
    }
}

function Get-CodexParallelChildResumeStartInfo {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.ProcessStartInfo])]
    param(
        [Parameter(Mandatory)] $Context,
        [AllowEmptyString()][string] $ResumePrompt = '',
        [AllowEmptyString()][string] $OutputPath = ''
    )

    $receipt = $Context.Receipt
    $commandPath = [string]$receipt.codex_command_path
    $isPowerShellShim = $commandPath.EndsWith('.ps1', [System.StringComparison]::OrdinalIgnoreCase)
    $info = [System.Diagnostics.ProcessStartInfo]::new($(if ($isPowerShellShim) { 'pwsh' } else { $commandPath }))
    $info.UseShellExecute = $false
    $info.WorkingDirectory = [string]$receipt.worktree_path
    if ($isPowerShellShim) {
        foreach ($argument in @('-NoProfile', '-File', $commandPath)) { $info.ArgumentList.Add($argument) }
    }
    $permission = Get-CodexParallelPermissionOverride `
        -DeniedPaths ([string[]]@($receipt.codex_denied_paths))
    $projects = Get-CodexChildProjectsOverride -WorktreePath ([string]$receipt.worktree_path)
    $shell = Get-CodexChildShellEnvironmentOverrideList -WorktreePath ([string]$receipt.worktree_path)
    foreach ($argument in @(
            'exec', 'resume', '--ignore-user-config', '-c', $projects, '-c', $permission,
            '-c', $shell[0], '-c', $shell[1], '-m', [string]$receipt.model,
            '-c', "model_reasoning_effort=$($receipt.model_reasoning_effort)",
            '-c', "default_permissions=`"$($receipt.runtime_permissions)`"", '-c', 'approval_policy="never"',
            '-c', ('developer_instructions=' + ([string]$Context.Profile.developer_instructions | ConvertTo-Json -Compress)),
            '-c', "skills.config=$($Context.Profile.skills_config)", '--strict-config',
            '--dangerously-bypass-hook-trust', '--json'
        )) {
        $info.ArgumentList.Add($argument)
    }
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $info.ArgumentList.Add('-o'); $info.ArgumentList.Add($OutputPath)
    }
    $info.ArgumentList.Add([string]$receipt.codex_session_id)
    if (-not [string]::IsNullOrWhiteSpace($ResumePrompt)) { $info.ArgumentList.Add($ResumePrompt) }
    foreach ($item in ([ordered]@{
                CODEX_PARALLEL_CHILD_LAUNCH_ID         = [string]$receipt.launch_id
                CODEX_PARALLEL_CHILD_EXPECTED_WORKTREE = [string]$receipt.worktree_path
                CODEX_PARALLEL_CHILD_SESSION_ID        = [string]$receipt.codex_session_id
                CODEX_HOME                             = [string]$receipt.codex_home_path
            }).GetEnumerator()) {
        $info.Environment[$item.Key] = $item.Value
    }
    return Add-CodexParallelMcpRestriction -StartInfo $info
}

if ($MyInvocation.InvocationName -eq '.') { return }
if ([string]::IsNullOrWhiteSpace($ReceiptPath)) {
    throw 'PARALLEL_CHILD_RESUME_BLOCKED: ReceiptPath is required.'
}
$context = Get-CodexParallelChildResumeContext -Path $ReceiptPath
$outputPath = if ([string]::IsNullOrWhiteSpace($LastMessagePath)) {
    Join-Path (Split-Path ([string]$context.Receipt.receipt_path) -Parent) `
        "$($context.Receipt.launch_id).resume.last-message.txt"
} else {
    Get-CodexChildCanonicalPath -Path $LastMessagePath `
        -BasePath ([string]$context.Receipt.worktree_path)
}
if (-not $PSCmdlet.ShouldProcess(
        [string]$context.Receipt.worktree_path,
        "Resume Codex parallel child $($context.Receipt.launch_id)"
    )) { return }
$process = [System.Diagnostics.Process]::new()
$process.StartInfo = Get-CodexParallelChildResumeStartInfo `
    -Context $context -ResumePrompt $Prompt -OutputPath $outputPath
Set-CodexParallelChildReceiptState -Receipt $context.Receipt -State launching -Confirm:$false
if (-not $process.Start()) { throw 'PARALLEL_CHILD_RESUME_BLOCKED: failed to start Codex resume process.' }
Set-CodexParallelChildReceiptState -Receipt $context.Receipt -State active `
    -SessionId ([string]$context.Receipt.codex_session_id) -Confirm:$false
$process.WaitForExit()
if ($process.ExitCode -eq 0) {
    Set-CodexParallelChildReceiptState -Receipt $context.Receipt -State completed -ExitCode 0 -Confirm:$false
} else {
    Set-CodexParallelChildReceiptState -Receipt $context.Receipt -State failed `
        -ExitCode $process.ExitCode -FailureReason 'Codex parallel resume returned a nonzero exit code.' `
        -Confirm:$false
}
exit $process.ExitCode
