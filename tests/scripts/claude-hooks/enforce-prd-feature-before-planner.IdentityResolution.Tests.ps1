#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Identity-based target resolution for the prd-feature gate (issues #673 and #672).

.DESCRIPTION
    Covers the migration's behavioural claims: identity selects the worktree, the feature
    folder only locates documents beneath it, the checkpoint consulted belongs to the
    resolved worktree, and the two reason families never appear in each other's decisions.

    Rows labelled "identity" leave the gate's resolution seam unmocked and model only
    worktree liveness and checkpoint text, so the real resolver runs. Rows labelled "seam"
    mock Resolve-PrdFeatureWorktreeTarget to state a resolution outcome directly.

    Determinism statement. No case in this suite creates a temporary file or directory, no
    case changes the process working directory, and no absolute path here is derived from
    the runtime environment, the current directory, the script file location, or a
    source-control query. Every absolute path is a bare string literal, or a value composed
    from one and a loop index. The current directory is never read: where a row needs a
    session root it is supplied as data.

    Both reason codes come only from the worktree-resolution accessors, never a literal.

    Three authoring hazards are recorded so a later row does not rediscover them. A mock body
    built with GetNewClosure captures locals only, so a script-scoped value read inside one
    compares as empty; rows that need such a value alias it into a local first. That closure
    also suppresses Pester's implicit injection of the mocked command's parameters, so a body
    reading $FeatureFolder or $Path sees an empty value unless it declares its own param
    block; a body defined directly in an It and carrying no -ModuleName needs no closure at
    all. And the gate's candidate scanner keeps a period that immediately follows a folder
    token, so a prompt ending a sentence on the token yields a candidate no checkpoint value
    matches; every prompt here separates the token from its stop.
#>

BeforeAll {
    $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
    $script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
    . $script:UnderTest
    . $script:Helpers

    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeTargetResolution.psm1')

    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode

    # Bare string literals. Neither root exists on disk, and no assertion depends on
    # whether it does: every filesystem seam a row reaches is mocked.
    $script:CoordinatingSessionRoot = '/synthetic-worktrees/coordinating-session'
    $script:ItemWorktreeRoot = '/synthetic-worktrees/item-worktree'
    $script:TargetFeatureFolder = 'docs/features/active/2026-09-13-synthetic-target-672'
    $script:OtherFeatureFolder = 'docs/features/active/2026-09-13-synthetic-other-999'
    $script:ComposedTargetFolder = "$($script:ItemWorktreeRoot)/$($script:TargetFeatureFolder)"
    $script:IssueLine = 'Canonical issue number for this feature is 901. All artifact content must use this number.'

    # Return an Agent payload for an atomic-planner delegation.
    function New-IdentityPayload {
        param([Parameter(Mandatory)] [string] $Prompt)
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'atomic-planner'; prompt = $Prompt } } |
                ConvertTo-Json -Depth 6 -Compress)
    }

    # Model worktree liveness and checkpoint text for an identity row. The bodies close
    # over local copies because a module-scoped mock body cannot see this scope otherwise.
    function Set-IdentityTopology {
        param([string[]] $Live = @(), [string[]] $BranchRoot = @(), [hashtable] $Checkpoint = @{})
        $liveSet = $Live
        $branchSet = $BranchRoot
        $textMap = $Checkpoint
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith {
            param([string] $SessionRoot, [string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Path)
            # Match the requested checkpoint path back to the root that owns it.
            foreach ($root in $textMap.Keys) {
                if ($Path.StartsWith($root + '/')) { return $textMap[$root] }
            }
            return $null
        }.GetNewClosure()
    }

    # Build a resolved target result for a seam row.
    function New-IdentityTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory over the shipped constructor; it changes no system state.')]
        param([string] $Status, [string] $SessionRoot, [string] $WorktreeRoot)
        return (New-WorktreeResolutionTargetResult -Status $Status -SessionRoot $SessionRoot `
                -WorktreeRoot $WorktreeRoot -Signal 'Branch' -SignalValue 'f5-fixture-own' `
                -Candidate @($WorktreeRoot) -Detail "modelled resolved target '$WorktreeRoot'")
    }

    $script:CheckpointJson = '{"issue-num":"901"}'
}

Describe 'enforce-prd-feature-before-planner.ps1 identity resolution' {
    It 'prd R1 allows a coordinating-session delegation whose item is identified by issue number while the folder exists in twelve worktrees' {
        # Arrange: twelve live worktrees, which is the ordinary count once a feature folder
        # has merged, and exactly one of them records the issue the prompt names. Before
        # this migration the folder token placed the call in all twelve and the gate denied.
        $roots = @(0..11 | ForEach-Object { '/synthetic-worktrees/item-worktree-{0}' -f $_ })
        $owner = $roots[7]
        Set-IdentityTopology -Live $roots -Checkpoint @{ $owner = $script:CheckpointJson }
        # These two bodies carry no GetNewClosure, and deliberately so: they have no
        # -ModuleName, so they already run in this scope and see these locals, and wrapping
        # them in a closure would break Pester's implicit injection of the mocked
        # parameters, leaving $FeatureFolder and $Path empty on every call.
        $ownerFolder = "$owner/$($script:TargetFeatureFolder)"
        $ownerSpec = "$ownerFolder/spec.md"
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
            if ($FeatureFolder -eq $ownerFolder) { "- Work Mode: full-bug`n" } else { $null }
        }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq $ownerSpec }
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) now. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload

        # Assert: the issue number resolves the one worktree the folder could not.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'prd R2 denies with the no-target code when the prompt carries neither an issue number nor a branch' {
        # Arrange: the liveness seam throws, so an unresolved identity must deny before it.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }
        $payload = New-IdentityPayload -Prompt 'Continue planning the work already in flight.'

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:NoTargetCode)*"
    }

    It 'prd R3 denies with the ambiguity code when two live worktrees record the issue' {
        # Arrange: a stale attempt and the current one both record issue 901, with no branch
        # to break the tie.
        Set-IdentityTopology -Live @($script:ItemWorktreeRoot, $script:CoordinatingSessionRoot) -Checkpoint @{
            $script:ItemWorktreeRoot        = $script:CheckpointJson
            $script:CoordinatingSessionRoot = $script:CheckpointJson
        }
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) now. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:AmbiguityCode)*"
    }

    It 'prd R4 resolves by branch when a stale attempt records the same issue' {
        # Arrange: the same two-worktree tie, plus a branch naming one of them.
        Set-IdentityTopology -Live @($script:ItemWorktreeRoot, $script:CoordinatingSessionRoot) `
            -BranchRoot @($script:ItemWorktreeRoot) -Checkpoint @{
            $script:ItemWorktreeRoot        = $script:CheckpointJson
            $script:CoordinatingSessionRoot = $script:CheckpointJson
        }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
            if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
        }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) today. $($script:IssueLine) branch: f5-fixture-own"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload

        # Assert: the branch resolves the tie the issue alone could not.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'prd R5 reads the feature folder from the checkpoint of the resolved worktree when the prompt names none' {
        # Arrange: the seam resolves to the item worktree and the prompt cites no folder.
        $script:CapturedCheckpointPath = $null
        Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedCheckpointPath = $CheckpointPath
            return $script:TargetFeatureFolder
        }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Continue the work. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:CapturedCheckpointPath | Should -Not -BeNullOrEmpty
    }

    It 'prd R5 never composes a checkpoint path under the coordinating session root' {
        # Arrange: the same capture, asserted against the root the path must sit beneath.
        $script:CapturedCheckpointPath = $null
        Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedCheckpointPath = $CheckpointPath
            return $script:TargetFeatureFolder
        }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Continue the work. $($script:IssueLine)"

        # Act
        $null = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert: the path begins at the item worktree, never at the coordinating session.
        $script:CapturedCheckpointPath | Should -BeLike "$($script:ItemWorktreeRoot)/*"
        $script:CapturedCheckpointPath | Should -Not -BeLike "$($script:CoordinatingSessionRoot)/*"
    }

    It 'prd R6 denies with the missing-document reason when a prerequisite is absent beneath the resolved worktree' {
        # Arrange: the folder exists beneath the resolved worktree and its marker reads, but
        # the required document is genuinely absent.
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) today. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert: a genuine deny, carrying neither target-resolution code.
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike '*is missing:*'
        $reason.Contains($script:AmbiguityCode) | Should -BeFalse
        $reason.Contains($script:NoTargetCode) | Should -BeFalse
    }

    It 'prd R7 ignores a feature-folder path when choosing the worktree' {
        # Arrange: the prompt's only path token is a relative folder, and the issue line
        # names the item. Only one live worktree records the issue.
        Set-IdentityTopology -Live @($script:CoordinatingSessionRoot, $script:ItemWorktreeRoot) -Checkpoint @{
            $script:ItemWorktreeRoot = $script:CheckpointJson
        }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
            if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
        }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) now. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload

        # Assert: the probe ran beneath the issue's worktree, not the session's.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'prd R8 selects among two cited folders with the checkpoint of the resolved worktree' {
        # Arrange: two folders cited, the preferred one second, and the resolved worktree's
        # checkpoint naming it. Selecting the earliest candidate would return the other.
        Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $script:TargetFeatureFolder }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Cross-reference $($script:OtherFeatureFolder) and work in $($script:TargetFeatureFolder) today. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'prd R8 denies with the ambiguity code when the resolved checkpoint names neither cited folder' {
        # Arrange: the same two citations, with a checkpoint naming a third folder.
        Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-09-13-synthetic-third-000' }
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Cross-reference $($script:OtherFeatureFolder) and work in $($script:TargetFeatureFolder) today. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert: the tie is unresolved, so the gate denies rather than selecting either.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:AmbiguityCode)*"
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*cites 2 feature folders*'
    }

    It 'prd R9 denies with the work-mode reason when the marker is absent from the resolved folder' {
        # Arrange: the folder exists beneath the resolved worktree but carries no marker.
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "no marker here`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $payload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) today. $($script:IssueLine)"

        # Act
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

        # Assert: the work-mode branch runs no required-file probe and names no
        # prerequisite set, and it carries neither target-resolution code.
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike '*Work Mode:*'
        $reason.Contains($script:AmbiguityCode) | Should -BeFalse
        $reason.Contains($script:NoTargetCode) | Should -BeFalse
        Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
    }

    It 'prd resolution-family and document-family reasons never appear in each other''s decisions' {
        # Arrange: one deny per family, each produced by the gate rather than asserted as text.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }
        $resolutionPayload = New-IdentityPayload -Prompt 'Continue planning the work already in flight.'
        $resolutionReason = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $resolutionPayload).hookSpecificOutput.permissionDecisionReason

        Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $false }
        $target = New-IdentityTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot
        $documentPayload = New-IdentityPayload -Prompt "Plan $($script:TargetFeatureFolder) today. $($script:IssueLine)"
        $documentReason = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $documentPayload -ResolvedTarget $target).hookSpecificOutput.permissionDecisionReason

        # Act / Assert: neither family's marker appears in the other's reason.
        $resolutionReason | Should -BeLike "*$($script:NoTargetCode)*"
        $resolutionReason | Should -Not -BeLike '*is missing:*'
        $documentReason | Should -BeLike '*is missing:*'
        $documentReason.Contains($script:NoTargetCode) | Should -BeFalse
        $documentReason.Contains($script:AmbiguityCode) | Should -BeFalse
    }

    It 'prd lets no feature-folder path and no file path select the worktree' {
        # Arrange: the prompt carries a relative folder token, an absolute file path, and one
        # canonical issue line. Liveness is modelled so the folder token would place the call
        # in several roots and the issue number in exactly one.
        Set-IdentityTopology -Live @($script:CoordinatingSessionRoot, $script:ItemWorktreeRoot) -Checkpoint @{
            $script:ItemWorktreeRoot = $script:CheckpointJson
        }
        $script:CapturedResolution = $null
        Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
            if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
        }
        Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }
        $prompt = "Plan $($script:TargetFeatureFolder) and read $($script:CoordinatingSessionRoot)/some/file.ps1. $($script:IssueLine)"

        # Act: the resolver receives the whole assembled text, path tokens included. What is
        # pinned here is that it reads no path signal as a worktree selector.
        $script:CapturedResolution = Resolve-PrdFeatureWorktreeTarget -Text $prompt
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw (New-IdentityPayload -Prompt $prompt)

        # Assert: the issue's worktree is chosen, the reported signal is not a path kind,
        # and the assembling function declares no envelope parameter.
        $script:CapturedResolution.WorktreeRoot | Should -Be $script:ItemWorktreeRoot
        $script:CapturedResolution.Signal | Should -Not -Be 'FeatureFolderPath'
        $script:CapturedResolution.Signal | Should -Not -Be 'FilePath'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:UnderTest, [ref] $null, [ref] $null)
        $assembler = @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $args[0].Name -eq 'Get-PrdFeatureCallTarget' }, $true))[0]
        @($assembler.Body.ParamBlock.Parameters |
                Where-Object { $_.Name.VariablePath.UserPath -eq 'Envelope' }) | Should -BeNullOrEmpty
    }
}
