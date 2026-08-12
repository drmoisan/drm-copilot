# Adapts the shared Codex child launch contract to the parallel execution surface.

. (Join-Path $PSScriptRoot 'codex-child-launch-contract-core.ps1')

function Get-CodexParallelCheckpointItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)] $Entry
    )

    $matchingItems = @($Checkpoint.items | Where-Object {
            Test-CodexChildIssueEqual -Left $_.issue_num -Right $Entry.issue_num
        })
    if ($matchingItems.Count -eq 1) {
        return $matchingItems[0]
    }
    return $null
}

function Test-CodexParallelForbiddenState {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] $Value)

    foreach ($name in @(
            'integration_branch', 'integration_pr', 'integration_pr_url',
            'final_pr', 'final_pr_url', 'fan_in', 'waves', 'wave'
        )) {
        if (@($Value.PSObject.Properties.Name) -contains $name) {
            return $true
        }
    }
    return $false
}

function Get-CodexParallelRequiredBindingFieldList {
    [OutputType([string[]])]
    param()

    return [string[]]@(
        'authority_receipt_path',
        'delegation_receipt_path',
        'topology_receipt_path',
        'model_routing_receipt_path',
        'child_status_path'
    )
}

function Test-CodexParallelChildLaunchSpec {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] $Spec,
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)] $ProfilesByKey,
        [Parameter(Mandatory)] $LiveBranchesByWorktree,
        [AllowEmptyString()][string] $VerifiedOriginMainHead = ''
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    if ([int]$Spec.schema_version -ne 2) {
        $errors.Add('schema_version must be 2.')
    }
    if ([string]$Spec.surface -cne 'parallel') {
        $errors.Add("surface must be 'parallel'.")
    }
    if ([string]$Spec.base_branch -cne 'main' -or [string]$Spec.pr_target -cne 'main') {
        $errors.Add("base_branch and pr_target must both be 'main'.")
    }
    if (Test-CodexParallelForbiddenState -Value $Spec) {
        $errors.Add('parallel launch state must not contain integration or fan-in fields.')
    }
    if ([string]$Checkpoint.route_id -cne 'parallel' -or
        [string]$Checkpoint.parallel_slug -cne [string]$Spec.parallel_slug) {
        $errors.Add('parallel launch specification differs from its checkpoint route or slug.')
    }
    if ([int]$Spec.cohort -ne [int]$Checkpoint.current_cohort) {
        $errors.Add('parallel launch cohort differs from the checkpoint current cohort.')
    }
    if ([int]$Spec.max_concurrency -lt 1 -or [int]$Spec.max_concurrency -gt 8 -or
        [int]$Spec.max_concurrency -ne [int]$Checkpoint.max_concurrency) {
        $errors.Add('max_concurrency must match the checkpoint integer from 1 through 8.')
    }
    if (-not [string]::IsNullOrWhiteSpace($VerifiedOriginMainHead)) {
        if (-not (Test-CodexChildSha256 -Value $VerifiedOriginMainHead) -or
            [string]$Spec.origin_main_head -cne $VerifiedOriginMainHead) {
            $errors.Add('origin/main must resolve to the exact sealed base commit.')
        }
    }

    $seenIssues = [System.Collections.Generic.HashSet[int]]::new()
    $seenBranches = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $pathComparer = if ($IsWindows) {
        [System.StringComparer]::OrdinalIgnoreCase
    } else {
        [System.StringComparer]::Ordinal
    }
    $seenWorktrees = [System.Collections.Generic.HashSet[string]]::new($pathComparer)
    $requiredBindings = Get-CodexParallelRequiredBindingFieldList
    foreach ($entry in @($Spec.launches)) {
        if ($null -eq $entry) {
            $errors.Add('parallel launch entry must not be null.')
            continue
        }
        if (Test-CodexParallelForbiddenState -Value $entry) {
            $errors.Add('parallel launch state must not contain integration or fan-in fields.')
        }
        foreach ($name in @(
                'launch_id', 'delegation_id', 'issue_num', 'feature_folder', 'cohort', 'batch',
                'deployment_agent', 'model', 'model_reasoning_effort', 'permissions',
                'execution_context', 'worktree_path', 'branch_name', 'authority_receipt_path',
                'delegation_receipt_path', 'topology_receipt_path', 'model_routing_receipt_path',
                'launch_status_path', 'prompt'
            )) {
            if (@($entry.PSObject.Properties.Name) -notcontains $name -or
                [string]::IsNullOrWhiteSpace([string]$entry.$name)) {
                $errors.Add("parallel launch entry is missing $name.")
            }
        }
        if (-not (Test-CodexChildPositiveInteger -Value $entry.issue_num)) {
            $errors.Add('parallel launch issue_num must be a positive integer.')
            continue
        }
        $issue = [int]$entry.issue_num
        $item = Get-CodexParallelCheckpointItem -Checkpoint $Checkpoint -Entry $entry
        if ($null -eq $item) {
            $errors.Add('each parallel item must resolve to exactly one launch entry.')
            continue
        }
        $worktree = Get-CodexChildCanonicalPath -Path ([string]$entry.worktree_path) `
            -BasePath $RepositoryRoot
        $itemWorktree = Get-CodexChildCanonicalPath -Path ([string]$item.worktree_path) `
            -BasePath $RepositoryRoot
        if ([int]$entry.cohort -ne [int]$Spec.cohort -or
            [int]$entry.batch -ne [int]$Spec.batch -or
            [int]$item.cohort -ne [int]$Spec.cohort -or
            [int]$item.batch -ne [int]$Spec.batch) {
            $errors.Add("parallel item $issue cohort or batch differs from the persisted assignment.")
        }
        if ($worktree -cne $itemWorktree -or
            [string]$entry.branch_name -cne [string]$item.branch -or
            [string]$LiveBranchesByWorktree[$worktree] -cne [string]$entry.branch_name) {
            $errors.Add("parallel item $issue branch or worktree binding differs from the checkpoint.")
        }
        if (-not $seenIssues.Add($issue) -or
            -not $seenBranches.Add([string]$entry.branch_name) -or
            -not $seenWorktrees.Add($worktree)) {
            $errors.Add('parallel launches must use distinct item, branch, and worktree bindings.')
        }
        $profileKey = Get-CodexChildProfileKey -WorktreePath $worktree `
            -AgentName ([string]$entry.deployment_agent) `
            -RepositoryRoot $RepositoryRoot
        $agentProfile = $ProfilesByKey[$profileKey]
        if ($null -eq $agentProfile) {
            $errors.Add("parallel item $issue has no exact generated profile.")
            continue
        }
        $bindings = @{
            authority_receipt_path     = [string]$entry.authority_receipt_path
            delegation_receipt_path    = [string]$entry.delegation_receipt_path
            topology_receipt_path      = [string]$entry.topology_receipt_path
            model_routing_receipt_path = [string]$entry.model_routing_receipt_path
            child_status_path          = [string]$entry.launch_status_path
        }
        $identity = ConvertTo-CodexChildLaunchIdentity -Surface parallel `
            -RepositoryRoot $RepositoryRoot -BaseBranch main -Entry $entry -Bindings $bindings
        foreach ($identityError in @(Test-CodexChildLaunchIdentity `
                    -Identity $identity -AgentProfile $agentProfile -ExpectedSurface parallel `
                    -ExpectedRepositoryRoot $RepositoryRoot -ExpectedBaseBranch main `
                    -LiveBranch ([string]$LiveBranchesByWorktree[$worktree]) `
                    -RequiredBindingFields $requiredBindings)) {
            $errors.Add("parallel item $issue $identityError")
        }
    }

    $expected = @($Checkpoint.items | Where-Object {
            [int]$_.cohort -eq [int]$Spec.cohort -and [int]$_.batch -eq [int]$Spec.batch
        })
    if (@($Spec.launches).Count -ne $expected.Count) {
        $errors.Add('each parallel item must resolve to exactly one launch entry.')
    }
    return $errors.ToArray()
}

function Get-CodexParallelChildLaunchReceipt {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] $Spec,
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)] $AgentProfile,
        [Parameter(Mandatory)] $CodexRuntime,
        [Parameter(Mandatory)][string] $SpecPath,
        [Parameter(Mandatory)][string] $SpecSha256,
        [Parameter(Mandatory)][string] $CheckpointPath,
        [Parameter(Mandatory)][string] $CheckpointSha256,
        [Parameter(Mandatory)][string] $ReceiptPath,
        [Parameter(Mandatory)][string] $StatusPath,
        [Parameter(Mandatory)][string] $CodexHomePath,
        [Parameter(Mandatory)][string] $BatchLockPath
    )

    $authorizedAt = [datetimeoffset]::UtcNow
    return [ordered]@{
        schema_version = 2; state = 'launching'; surface = 'parallel'
        launch_id = [string]$Entry.launch_id; parallel_slug = [string]$Spec.parallel_slug
        base_branch = 'main'; pr_target = 'main'; origin_main_head = [string]$Spec.origin_main_head
        cohort = [int]$Entry.cohort; batch = [int]$Entry.batch; position = [int]$Entry.position
        issue_num = $Entry.issue_num; feature_folder = [string]$Entry.feature_folder
        delegation_id = [string]$Entry.delegation_id; deployment_agent = [string]$Entry.deployment_agent
        model = [string]$Entry.model; model_reasoning_effort = [string]$Entry.model_reasoning_effort
        permissions = [string]$Entry.permissions; runtime_permissions = 'parallel-child-workspace'
        execution_context          = [string]$Entry.execution_context
        worktree_path = [string]$AgentProfile.worktree_path; branch_name = [string]$Entry.branch_name
        trusted_repository_root    = [string]$AgentProfile.trusted_repository_root
        authority_receipt_path     = [string]$Entry.authority_receipt_path
        delegation_receipt_path    = [string]$Entry.delegation_receipt_path
        topology_receipt_path      = [string]$Entry.topology_receipt_path
        model_routing_receipt_path = [string]$Entry.model_routing_receipt_path
        child_status_path          = [string]$Entry.launch_status_path
        prompt_sha256              = Get-CodexChildSha256 -Value ([string]$Entry.prompt)
        profile_path = [string]$AgentProfile.profile_path; profile_sha256 = [string]$AgentProfile.profile_sha256
        spec_path = $SpecPath; spec_sha256 = $SpecSha256
        checkpoint_path = $CheckpointPath; checkpoint_sha256 = $CheckpointSha256
        receipt_path = $ReceiptPath; status_path = $StatusPath; codex_home_path = $CodexHomePath
        batch_lock_path = $BatchLockPath; codex_command_path = [string]$CodexRuntime.CommandPath
        codex_denied_paths = [string[]]$CodexRuntime.DeniedPaths; codex_session_id = ''
        authorized_at = $authorizedAt.ToString('o'); session_bound_at = ''
        expires_at                 = $authorizedAt.AddDays(7).ToString('o')
    }
}
