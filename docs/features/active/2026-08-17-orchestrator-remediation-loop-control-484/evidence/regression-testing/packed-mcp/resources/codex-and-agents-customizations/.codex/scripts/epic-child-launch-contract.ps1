# Epic-only policy and error compatibility over the surface-neutral contract core.
. (Join-Path $PSScriptRoot 'codex-child-launch-contract-core.ps1')

function ConvertFrom-CodexChildLaunchJson {
    param([Parameter(Mandatory)][string] $Raw, [Parameter(Mandatory)][string] $Name)
    try {
        return ConvertFrom-CodexChildLaunchJsonCore -Raw $Raw -Name $Name
    } catch {
        throw ([string]$_.Exception.Message).Replace(
            'CODEX_CHILD_LAUNCH_BLOCKED:',
            'EPIC_CHILD_LAUNCH_BLOCKED:'
        )
    }
}

function ConvertFrom-CodexAgentProfile {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $ProfileRaw)
    try {
        return ConvertFrom-CodexAgentProfileCore -ProfileRaw $ProfileRaw
    } catch {
        throw ([string]$_.Exception.Message).Replace(
            'CODEX_CHILD_LAUNCH_BLOCKED:',
            'EPIC_CHILD_LAUNCH_BLOCKED:'
        )
    }
}

function Get-CodexChildFeatureKey {
    [OutputType([string])]
    param([Parameter(Mandatory)] $Feature)
    $issue = $Feature.issue_num | ConvertTo-Json -Compress
    return "$issue`n$([string]$Feature.feature_folder)"
}

function Find-CodexChildFeature {
    [CmdletBinding()]
    param([Parameter(Mandatory)] $Checkpoint, [Parameter(Mandatory)] $Entry)
    foreach ($feature in @($Checkpoint.features)) {
        if ($null -ne $feature -and
            (Test-CodexChildIssueEqual -Left $feature.issue_num -Right $Entry.issue_num) -and
            [string]$feature.feature_folder -ceq [string]$Entry.feature_folder) {
            return $feature
        }
    }
    return $null
}

function Find-CodexChildDelegationReceipt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)] $Feature,
        [Parameter(Mandatory)] $Entry
    )
    $featureReceipt = $null
    if (@($Feature.PSObject.Properties.Name) -contains 'delegation_receipt') {
        $featureReceipt = $Feature.delegation_receipt
        $receipts = @($featureReceipt)
    } else {
        $receipts = @()
    }
    if (@($Checkpoint.PSObject.Properties.Name) -contains 'delegation_receipts') {
        $receipts += @($Checkpoint.delegation_receipts)
    }
    foreach ($receipt in $receipts) {
        if ($null -eq $receipt) {
            continue
        }
        $names = @($receipt.PSObject.Properties.Name)
        $receiptId = if ($names -contains 'delegation_id') {
            [string]$receipt.delegation_id
        } elseif ($names -contains 'id') {
            [string]$receipt.id
        } else {
            ''
        }
        $isExact = [string]$receipt.feature_folder -ceq [string]$Entry.feature_folder -and
        (Test-CodexChildIssueEqual -Left $receipt.issue_num -Right $Entry.issue_num) -and
        $receiptId -ceq [string]$Entry.delegation_id -and
        [string]$receipt.agent_name -ceq [string]$Entry.deployment_agent
        if ($isExact) {
            return $receipt
        }
    }
    return $null
}

function Find-CodexChildModelReceipt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)] $Feature,
        [Parameter(Mandatory)] $Entry
    )
    $featureReceipt = $null
    if (@($Feature.PSObject.Properties.Name) -contains 'model_routing_receipt') {
        $featureReceipt = $Feature.model_routing_receipt
        $receipts = @($featureReceipt)
    } else {
        $receipts = @()
    }
    if (@($Checkpoint.PSObject.Properties.Name) -contains 'codex_model_routing_receipts') {
        $receipts += @($Checkpoint.codex_model_routing_receipts)
    }
    foreach ($receipt in $receipts) {
        if ($null -ne $receipt -and
            [string]$receipt.delegation_id -ceq [string]$Entry.delegation_id -and
            [string]$receipt.deployment_agent -ceq [string]$Entry.deployment_agent -and
            [string]$receipt.model -ceq [string]$Entry.model -and
            [string]$receipt.model_reasoning_effort -ceq [string]$Entry.model_reasoning_effort -and
            [string]$receipt.execution_context -ceq [string]$Entry.execution_context) {
            return $receipt
        }
    }
    return $null
}

function Test-CodexChildLaunchSpec {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] $Spec,
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][System.Collections.IDictionary] $ProfilesByKey,
        [Parameter(Mandatory)][System.Collections.IDictionary] $LiveBranchesByWorktree
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    if ($Spec.schema_version -ne 1 -or [string]$Checkpoint.integration_branch -cne [string]$Spec.integration_branch) {
        $errors.Add('schema_version must be 1 and integration_branch must match the epic checkpoint.')
    }
    $specMaximum = [int]$Spec.max_parallel_features
    if ($specMaximum -lt 1 -or $specMaximum -gt 8 -or
        $specMaximum -ne [int]$Checkpoint.max_parallel_features) {
        $errors.Add('max_parallel_features must match the checkpoint and be between 1 and 8.')
    }
    if ([string]$Spec.wave_id -cnotmatch '^[a-z0-9][a-z0-9._-]{0,79}$') {
        $errors.Add('wave_id must be a safe lowercase artifact identifier.')
    }
    if ([string]$Spec.checkpoint_kind -notin @('epic-planner', 'epic-orchestrator')) {
        $errors.Add('checkpoint_kind must be epic-planner or epic-orchestrator.')
    }
    $expectedCheckpointName = "$($Spec.checkpoint_kind)-state.json"
    if ((Split-Path ([string]$Spec.checkpoint_path) -Leaf) -ne $expectedCheckpointName) {
        $errors.Add("checkpoint_path must end with $expectedCheckpointName.")
    }
    $expectedContext = if ([string]$Spec.checkpoint_kind -eq 'epic-planner') {
        'epic_preparation_child'
    } else {
        'epic_execution_child'
    }
    $isPlanner = [string]$Spec.checkpoint_kind -eq 'epic-planner'
    if ($isPlanner -and [int]$Spec.wave_number -ne 0) {
        $errors.Add('epic-planner preparation batches must use wave_number 0.')
    }
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $seenDelegations = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $worktreeComparer = if ($IsWindows) { [System.StringComparer]::OrdinalIgnoreCase } else { [System.StringComparer]::Ordinal }
    $seenWorktrees = [System.Collections.Generic.HashSet[string]]::new($worktreeComparer)
    $expectedFeatures = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $checkpointFeatures = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $terminalStatuses = @('blocked_conflict_loop_limit', 'merged', 'worktree_removed')
    foreach ($feature in @($Checkpoint.features)) {
        if ($null -eq $feature) {
            continue
        }
        $checkpointFeatureKey = Get-CodexChildFeatureKey -Feature $feature
        if (-not $checkpointFeatures.Add($checkpointFeatureKey)) {
            $errors.Add('checkpoint features must use unique issue_num and feature_folder identities.')
        }
        $featureWave = if (@($feature.PSObject.Properties.Name) -contains 'wave_number') {
            [int]$feature.wave_number
        } else {
            [int]$feature.wave
        }
        $eligible = $isPlanner -or ($featureWave -eq [int]$Spec.wave_number -and
            [string]$feature.merge_status -notin $terminalStatuses)
        if ($eligible) {
            $expectedFeatures.Add($checkpointFeatureKey) | Out-Null
        }
    }
    $launchedFeatures = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in @($Spec.launches)) {
        $required = @(
            'launch_id', 'delegation_id', 'feature_folder', 'issue_num', 'deployment_agent',
            'model', 'model_reasoning_effort', 'permissions', 'execution_context', 'worktree_path',
            'branch_name', 'prompt'
        )
        foreach ($name in $required) {
            if (@($entry.PSObject.Properties.Name) -notcontains $name -or
                [string]::IsNullOrWhiteSpace([string]$entry.$name)) {
                $errors.Add("launch entry is missing $name.")
            }
        }
        if ([string]$entry.launch_id -cnotmatch '^[a-z0-9][a-z0-9._-]{0,79}$') {
            $errors.Add('launch_id must be a safe lowercase artifact identifier.')
        }
        if ([string]$entry.deployment_agent -notmatch '^[a-z0-9][a-z0-9._-]{0,79}$') {
            $errors.Add("launch '$($entry.launch_id)' deployment_agent must be a safe generated profile name.")
        }
        if (-not $seen.Add([string]$entry.launch_id)) {
            $errors.Add("duplicate launch_id: $($entry.launch_id)")
        }
        if (-not $seenDelegations.Add([string]$entry.delegation_id)) {
            $errors.Add("duplicate delegation_id: $($entry.delegation_id)")
        }
        $feature = Find-CodexChildFeature -Checkpoint $Checkpoint -Entry $entry
        if ($null -eq $feature) {
            $errors.Add("launch '$($entry.launch_id)' has no exact checkpoint feature match.")
            continue
        }
        $featureKey = Get-CodexChildFeatureKey -Feature $feature
        if (-not $expectedFeatures.Contains($featureKey)) {
            $errors.Add("launch '$($entry.launch_id)' targets a feature that is not eligible for this batch or wave.")
        }
        if (-not $launchedFeatures.Add($featureKey)) {
            $errors.Add("launch '$($entry.launch_id)' duplicates a checkpoint feature in this batch or wave.")
        }
        $featureWave = if (@($feature.PSObject.Properties.Name) -contains 'wave_number') {
            [int]$feature.wave_number
        } else {
            [int]$feature.wave
        }
        $issueIsPositive = (Test-CodexChildPositiveInteger -Value $entry.issue_num) -and
        (Test-CodexChildPositiveInteger -Value $feature.issue_num)
        if (-not $issueIsPositive) {
            $errors.Add("launch '$($entry.launch_id)' requires a final positive integer issue_num.")
        }
        if (-not (Test-CodexChildActiveFeatureFolder -Path ([string]$entry.feature_folder)) -or
            -not (Test-CodexChildActiveFeatureFolder -Path ([string]$feature.feature_folder))) {
            $errors.Add("launch '$($entry.launch_id)' requires a final docs/features/active feature_folder without placeholders.")
        }
        if ((-not $isPlanner -and $featureWave -ne [int]$Spec.wave_number) -or
            [string]$feature.branch_name -cne [string]$entry.branch_name) {
            $errors.Add("launch '$($entry.launch_id)' wave or branch differs from its checkpoint feature.")
        }
        $worktree = Get-CodexChildCanonicalPath -Path ([string]$entry.worktree_path) -BasePath $RepositoryRoot
        $featureWorktree = Get-CodexChildCanonicalPath -Path ([string]$feature.worktree_path) -BasePath $RepositoryRoot
        if (-not [System.IO.Path]::IsPathFullyQualified([string]$entry.worktree_path) -or
            [string]$entry.worktree_path -cne $worktree -or
            $worktree -ne $featureWorktree -or
            [string]$LiveBranchesByWorktree[$worktree] -cne [string]$entry.branch_name) {
            $errors.Add("launch '$($entry.launch_id)' worktree is not canonical or its live branch does not match.")
        }
        if (-not $seenWorktrees.Add($worktree)) {
            $errors.Add("duplicate worktree_path: $worktree")
        }
        if ([string]$entry.execution_context -cne $expectedContext) {
            $errors.Add("launch '$($entry.launch_id)' has the wrong epic execution context.")
        }
        $prompt = [string]$entry.prompt
        if ($isPlanner) {
            if (-not $prompt.Contains('Preparation mode: true', [System.StringComparison]::Ordinal)) {
                $errors.Add("launch '$($entry.launch_id)' planner prompt is missing 'Preparation mode: true'.")
            }
        } else {
            $requiredPromptValues = @(
                'Epic mode: true.',
                "epic_feature_folder: $($Checkpoint.epic_feature_folder)",
                "integration_branch: $($Checkpoint.integration_branch)",
                "--base $($Checkpoint.integration_branch)"
            )
            foreach ($requiredPromptValue in $requiredPromptValues) {
                if (-not $prompt.Contains($requiredPromptValue, [System.StringComparison]::Ordinal)) {
                    $errors.Add("launch '$($entry.launch_id)' execution prompt is missing: $requiredPromptValue")
                }
            }
            if (-not [string]::IsNullOrWhiteSpace([string]$feature.plan_path) -and
                (-not $prompt.Contains([string]$feature.plan_path, [System.StringComparison]::Ordinal) -or
                $prompt -notmatch '(?i)resumes? at atomic execution')) {
                $errors.Add("launch '$($entry.launch_id)' prepared execution prompt must include plan_path and atomic-execution resume text.")
            }
        }
        if ($null -eq (Find-CodexChildDelegationReceipt -Checkpoint $Checkpoint -Feature $feature -Entry $entry)) {
            $errors.Add("launch '$($entry.launch_id)' has no matching delegation receipt.")
        }
        if ($null -eq (Find-CodexChildModelReceipt -Checkpoint $Checkpoint -Feature $feature -Entry $entry)) {
            $errors.Add("launch '$($entry.launch_id)' has no matching model-routing receipt.")
        }
        $profileKey = Get-CodexChildProfileKey -WorktreePath $worktree `
            -AgentName ([string]$entry.deployment_agent) -RepositoryRoot $RepositoryRoot
        $agentProfile = $ProfilesByKey[$profileKey]
        if ($null -eq $agentProfile -or
            [string]$agentProfile.name -cne [string]$entry.deployment_agent -or
            [string]$agentProfile.model -cne [string]$entry.model -or
            [string]$agentProfile.model_reasoning_effort -cne [string]$entry.model_reasoning_effort -or
            [string]$agentProfile.default_permissions -cne [string]$entry.permissions) {
            $errors.Add("launch '$($entry.launch_id)' differs from its checked-in generated profile.")
        } else {
            $identity = ConvertTo-CodexChildLaunchIdentity -Surface epic -RepositoryRoot $RepositoryRoot `
                -BaseBranch ([string]$Spec.integration_branch) -Entry $entry
            $identityErrors = Test-CodexChildLaunchIdentity -Identity $identity `
                -AgentProfile $agentProfile -ExpectedSurface epic `
                -ExpectedRepositoryRoot $RepositoryRoot `
                -ExpectedBaseBranch ([string]$Spec.integration_branch) `
                -LiveBranch ([string]$LiveBranchesByWorktree[$worktree])
            foreach ($identityError in $identityErrors) {
                $errors.Add("launch '$($entry.launch_id)' $identityError")
            }
        }
    }
    if (@($Spec.launches).Count -eq 0) {
        $errors.Add('launches must contain at least one child.')
    }
    foreach ($featureKey in $expectedFeatures) {
        if (-not $launchedFeatures.Contains($featureKey)) {
            $errors.Add('launches must cover every eligible checkpoint feature exactly once.')
        }
    }
    return $errors.ToArray()
}
