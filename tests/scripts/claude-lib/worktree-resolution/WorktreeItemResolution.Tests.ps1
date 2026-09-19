#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for portable-identity item resolution (issue #673).

.DESCRIPTION
    Covers the checkpoint-path definition, issue-number normalisation, the canonical
    issue-line reader, the checkpoint-issue reader, the liveness seam, and every row of
    the resolution algorithm, including the stale-attempt tie-break.

    Worktree topologies are modelled entirely by mocks registered with -ModuleName
    'WorktreeItemResolution', because every enumeration and filesystem read runs inside
    that module even when the call starts here; a seam called directly from a test is
    exercised through mocks of its own dependencies for the same reason. A mock body
    closes only over local values, because the closure does not capture a script-scoped
    variable once the body is re-bound to the module. Synthetic roots are composed at
    run time from the path root of $PSScriptRoot, so no absolute host path and no drive
    letter is written here.

    No test creates, writes, or reads a file of any kind, uses the Pester-supplied
    scratch drive, reads a wall clock, spawns a process, or touches the network. Both
    expected reason codes come only from the worktree-resolution accessors.
#>

BeforeAll {
    # Resolve the three modules four levels up (worktree-resolution -> claude-lib ->
    # scripts -> tests -> repo root). Resolve-Path normalizes separators so Pester
    # coverage breakpoints bind to the run-settings paths. Imported without -Force so
    # the suite binds to the instance an earlier loader already placed in the session.
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeTargetResolution.psm1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

    # Synthetic roots derived from the path root of this script's directory, so they
    # are absolute for the normaliser without any host path appearing in this file.
    $script:SeamRoot = ([System.IO.Path]::GetPathRoot($PSScriptRoot) + 'f5-seam-root').Replace([string][char]92, '/')
    $script:Session = "$($script:SeamRoot)/session"
    $script:Own = "$($script:SeamRoot)/own"
    $script:Sibling = "$($script:SeamRoot)/sibling"
    $script:Third = "$($script:SeamRoot)/third"
    $script:OrchestratorModule = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorState.psm1").Path

    # Return checkpoint text recording an issue number. IssueNumber is a raw JSON
    # fragment, so a test can supply a quoted string or a bare number.
    function New-CheckpointJson {
        param([Parameter(Mandatory)] [AllowEmptyString()] [string] $IssueNumber)
        return ('{{"issue-num":{0}}}' -f $IssueNumber)
    }

    # Register the two module-scoped seam mocks that model a worktree topology. Live is
    # the unfiltered live-root set, BranchRoot what the seam returns under a branch
    # filter, and Checkpoint a root-to-checkpoint-text map whose absent key models a
    # worktree with no checkpoint. The bodies close over local copies, because a
    # re-bound mock body cannot see this scope otherwise.
    function Set-ItemTopology {
        param(
            [string[]] $Live = @(),
            [string[]] $BranchRoot = @(),
            [hashtable] $Checkpoint = @{}
        )
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
            # Match the requested checkpoint path back to the root that owns it. A root
            # with no entry models a worktree carrying no checkpoint at all.
            foreach ($root in $textMap.Keys) {
                if ($Path.StartsWith($root + '/')) { return $textMap[$root] }
            }
            return $null
        }.GetNewClosure()
    }
}

Describe 'WorktreeItemResolution checkpoint path' {
    It 'returns the repository-relative orchestrator checkpoint path' {
        # Arrange / Act: the module's single definition of the checkpoint location.
        $relative = Get-WorktreeItemCheckpointRelativePath

        # Assert: the value is repository-relative and names the canonical file.
        $relative | Should -Be 'artifacts/orchestration/orchestrator-state.json'
    }

    It 'matches the default checkpoint path of Invoke-OrchestratorStatePreflight' {
        # Arrange: parse the orchestrator-state module and locate the preflight's own
        # CheckpointPath parameter default, which is the latent fourth binding.
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:OrchestratorModule, [ref] $null, [ref] $null)
        $function = @($ast.FindAll({
                    $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $args[0].Name -eq 'Invoke-OrchestratorStatePreflight'
                }, $true))[0]
        $parameter = @($function.Body.ParamBlock.Parameters |
                Where-Object { $_.Name.VariablePath.UserPath -eq 'CheckpointPath' })[0]

        # Act: read the literal default from the parse tree.
        $default = $parameter.DefaultValue.Value

        # Assert: the two definitions agree, so composing against a resolved root
        # cannot drift from the path the preflight would otherwise have used.
        $default | Should -Be (Get-WorktreeItemCheckpointRelativePath)
    }

    It 'composes the absolute checkpoint path under a worktree root' {
        # Arrange / Act: compose beneath a synthetic root.
        $composed = Get-WorktreeItemCheckpointPath -WorktreeRoot $script:Own

        # Assert: the result is the root followed by the relative path, forward-slashed.
        $composed | Should -Be "$($script:Own)/$(Get-WorktreeItemCheckpointRelativePath)"
    }
}

Describe 'WorktreeItemResolution issue signals' {
    It 'reads every distinct issue number from canonical issue lines' {
        # Arrange: a text carrying two distinct numbers and a repeat of the first.
        $text = 'Canonical issue number for this feature is 901. ' +
        'Canonical issue number for this feature is #902. ' +
        'Canonical issue number for this feature is 901.'

        # Act: assigned before wrapping, because the reader returns its array as one object.
        $signal = Find-WorktreeItemIssueSignal -Text $text
        $numbers = @($signal)

        # Assert: distinct numbers in first-appearance order.
        $numbers.Count | Should -Be 2
        $numbers[0] | Should -Be '901'
        $numbers[1] | Should -Be '902'
    }

    It 'returns no issue number for text without a canonical issue line' {
        # Arrange: text mentioning a number but not through the contract sentence, plus
        # a lowercase near-miss that the case-sensitive pattern must not accept.
        $text = 'Work on issue 901 please. canonical issue number for this feature is 902.'

        # Act
        $signal = Find-WorktreeItemIssueSignal -Text $text
        $numbers = @($signal)

        # Assert
        $numbers.Count | Should -Be 0
    }

    It 'normalises string and integer issue-num values' {
        # Arrange / Act / Assert: each accepted spelling yields the same digit string.
        ConvertTo-WorktreeItemIssueNumber -Value '901' | Should -Be '901'
        ConvertTo-WorktreeItemIssueNumber -Value 901 | Should -Be '901'
        ConvertTo-WorktreeItemIssueNumber -Value '#901' | Should -Be '901'
        ConvertTo-WorktreeItemIssueNumber -Value '  901  ' | Should -Be '901'
        ConvertTo-WorktreeItemIssueNumber -Value '0901' | Should -Be '901'
    }

    It 'rejects zero, none, empty, and non-numeric issue-num values' {
        # Arrange / Act / Assert: every rejected spelling yields $null rather than a
        # value a caller could match a worktree against.
        ConvertTo-WorktreeItemIssueNumber -Value 0 | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value '0' | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value -5 | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value 'none' | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value '' | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value $null | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value '90a' | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value '901.5' | Should -BeNullOrEmpty
        ConvertTo-WorktreeItemIssueNumber -Value '99999999999999999999' | Should -BeNullOrEmpty
    }
}

Describe 'WorktreeItemResolution checkpoint reader' {
    It 'reads the issue number from a worktree checkpoint through the checkpoint text seam' {
        # Arrange: the text seam answers for the own root only.
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith {
            return '{"issue-num":"901","objective":"fixture"}'
        }

        # Act
        $recorded = Get-WorktreeItemCheckpointIssue -WorktreeRoot $script:Own

        # Assert
        $recorded | Should -Be '901'
    }

    It 'returns no issue number for an absent, empty, or unparseable checkpoint' {
        # Arrange: four rejected checkpoint bodies, one per rejection cause.
        $bodies = @{
            absent      = $null
            empty       = ''
            unparseable = '{ this is not valid json'
            scalar      = '"901"'
            noKey       = '{"route_id":"large"}'
        }

        # Act / Assert: each body yields $null, so no unreadable checkpoint can be
        # matched to an issue and silently selected.
        foreach ($name in $bodies.Keys) {
            $body = $bodies[$name]
            Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith { return $body }.GetNewClosure()
            Get-WorktreeItemCheckpointIssue -WorktreeRoot $script:Own | Should -BeNullOrEmpty -Because "a $name checkpoint records no issue"
        }
    }
}

Describe 'WorktreeItemResolution liveness seam' {
    It 'keeps only registered worktrees that still carry a root marker' {
        # Arrange: three registered roots, of which the sibling's directory is gone. Each
        # value is aliased into a local first, because GetNewClosure captures locals and
        # not script-scoped variables, and an uncaptured value would silently be null.
        $ascent = $script:Session
        $registered = @($script:Session, $script:Own, $script:Sibling)
        $prunable = $script:Sibling
        Mock -CommandName Find-WorktreeResolutionRoot -ModuleName WorktreeItemResolution -MockWith { return $ascent }.GetNewClosure()
        Mock -CommandName Get-WorktreeResolutionWorktreeRoot -ModuleName WorktreeItemResolution -MockWith { return , [string[]] $registered }.GetNewClosure()
        Mock -CommandName Test-WorktreeResolutionRootMarker -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Path)
            return ($Path -ne $prunable)
        }.GetNewClosure()

        # Act
        $result = Get-WorktreeItemLiveRoot -SessionRoot $script:Session
        $live = @($result)

        # Assert: the prunable registration is excluded.
        $live.Count | Should -Be 2
        $live | Should -Not -Contain $script:Sibling
    }

    It 'returns no live worktree when the session path is inside no repository' {
        # Arrange: the ascent finds no worktree root above the session path.
        Mock -CommandName Find-WorktreeResolutionRoot -ModuleName WorktreeItemResolution -MockWith { return $null }
        Mock -CommandName Get-WorktreeResolutionWorktreeRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }

        # Act
        $result = Get-WorktreeItemLiveRoot -SessionRoot $script:Session
        $live = @($result)

        # Assert: an empty array, and no enumeration was attempted. The ascent
        # invocation count is asserted too, so the row cannot pass with a dead mock and
        # the real ascent happening to return null for a synthetic path.
        $live.Count | Should -Be 0
        Should -Invoke -CommandName Find-WorktreeResolutionRoot -ModuleName WorktreeItemResolution -Times 1 -Exactly
        Should -Invoke -CommandName Get-WorktreeResolutionWorktreeRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
    }
}

Describe 'WorktreeItemResolution target resolution' {
    It 'resolves NoTarget without enumerating worktrees when the text carries no identity' {
        # Arrange: the liveness seam throws, so reaching it would fail the test.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith { throw 'no file may be read' }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Please open a pull request for the change.' -SessionRoot $script:Session

        # Assert: the no-target verdict is reached before any enumeration or file read.
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        Should -Invoke -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
        Should -Invoke -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 0 -Exactly
    }

    It 'resolves the single live worktree whose checkpoint records the issue' {
        # Arrange: two live roots, one recording the issue.
        Set-ItemTopology -Live @($script:Session, $script:Own) -Checkpoint @{
            $script:Session = (New-CheckpointJson -IssueNumber '"838"')
            $script:Own     = (New-CheckpointJson -IssueNumber '"901"')
        }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901.' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Own
        $target.ReasonCode | Should -BeNullOrEmpty
    }

    It 'resolves NoTarget when no live worktree records the issue' {
        # Arrange: a live root recording a different issue.
        Set-ItemTopology -Live @($script:Session) -Checkpoint @{ $script:Session = (New-CheckpointJson -IssueNumber '"838"') }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 902.' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
    }

    It 'resolves Ambiguous when two live worktrees record the issue' {
        # Arrange: a stale attempt and the current one both recording issue 901.
        Set-ItemTopology -Live @($script:Own, $script:Sibling) -Checkpoint @{
            $script:Own     = (New-CheckpointJson -IssueNumber '"901"')
            $script:Sibling = (New-CheckpointJson -IssueNumber '"901"')
        }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901.' -SessionRoot $script:Session

        # Assert: both candidates are carried and the detail names both remedies.
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        $target.Candidates.Count | Should -Be 2
        $target.Detail | Should -BeLike '*handoff*'
        $target.Detail | Should -BeLike '*branch:*'
    }

    It 'breaks a stale-attempt tie with the branch signal' {
        # Arrange: two live roots record issue 901, and the branch names one of them.
        Set-ItemTopology -Live @($script:Own, $script:Sibling) -BranchRoot @($script:Own) -Checkpoint @{
            $script:Own     = (New-CheckpointJson -IssueNumber '"901"')
            $script:Sibling = (New-CheckpointJson -IssueNumber '"901"')
        }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901. branch: f5-fixture-own' -SessionRoot $script:Session

        # Assert: the branch resolves the tie the issue alone could not.
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Own
        $target.Signal | Should -Be 'Branch'
        $target.SignalValue | Should -Be 'f5-fixture-own'
    }

    It 'resolves Ambiguous when the branch worktree records a different issue' {
        # Arrange: the branch places the call where a different issue is recorded.
        Set-ItemTopology -Live @($script:Own) -BranchRoot @($script:Own) -Checkpoint @{
            $script:Own = (New-CheckpointJson -IssueNumber '"838"')
        }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901. branch: f5-fixture-own' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        $target.Detail | Should -BeLike '*records issue 838, not issue 901*'
    }

    It 'resolves Ambiguous when the branch and the issue name different worktrees' {
        # Arrange: the branch root records no issue, and another live root records 901.
        Set-ItemTopology -Live @($script:Own, $script:Sibling) -BranchRoot @($script:Own) -Checkpoint @{
            $script:Sibling = (New-CheckpointJson -IssueNumber '"901"')
        }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901. branch: f5-fixture-own' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        $target.Detail | Should -BeLike '*place the call in different worktrees*'
    }

    It 'resolves the branch worktree when its checkpoint records no issue and no other worktree records it' {
        # Arrange: no live root records the issue, and the branch names one root.
        Set-ItemTopology -Live @($script:Own, $script:Sibling) -BranchRoot @($script:Own) -Checkpoint @{}

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901. branch: f5-fixture-own' -SessionRoot $script:Session

        # Assert: the branch resolves, because nothing contradicts it.
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Own
    }

    It 'resolves Ambiguous when the text names two different issue numbers' {
        # Arrange: the liveness seam throws, so this verdict must precede enumeration.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }

        # Act
        $target = Resolve-WorktreeItemTarget -Text ('Canonical issue number for this feature is 901. ' +
            'Canonical issue number for this feature is 902.') -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        $target.Detail | Should -BeLike '*2 different issue numbers (901, 902)*'
        Should -Invoke -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
    }

    It 'resolves the branch worktree when only a branch signal is present' {
        # Arrange: a branch signal with no issue line anywhere in the text.
        Set-ItemTopology -Live @($script:Own) -BranchRoot @($script:Own) -Checkpoint @{}

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'gh pr create --head f5-fixture-own --base main' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Own
        $target.SignalValue | Should -Be 'f5-fixture-own'
    }

    It 'resolves NoTarget when the branch is checked out in no live worktree' {
        # Arrange: the branch filter matches nothing.
        Set-ItemTopology -Live @($script:Own) -BranchRoot @() -Checkpoint @{}

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'gh pr create --head f5-fixture-missing' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        $target.Detail | Should -BeLike '*checked out in no live worktree*'
    }

    It 'ignores a feature-folder path and resolves NoTarget when it is the only signal' {
        # Arrange: the liveness seam throws, because a folder token is not an identity
        # and so must not reach enumeration at all.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Plan docs/features/active/2026-09-13-synthetic-target-672 now.' -SessionRoot $script:Session

        # Assert: a folder path selects nothing, so the call carries no identity.
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        $target.Signal | Should -BeNullOrEmpty
        Should -Invoke -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
    }

    It 'resolves by branch when a relative feature folder and a unique branch are both present' {
        # Arrange: a folder token that would place in several roots, plus one branch.
        Set-ItemTopology -Live @($script:Own, $script:Sibling, $script:Third) -BranchRoot @($script:Own) -Checkpoint @{}

        # Act
        $target = Resolve-WorktreeItemTarget -Text ('Plan docs/features/active/2026-09-13-synthetic-target-672 ' +
            'branch: f5-fixture-own') -SessionRoot $script:Session

        # Assert: the branch decides and the reported signal is never a folder path.
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Own
        $target.Signal | Should -Be 'Branch'
        $target.Signal | Should -Not -Be 'FeatureFolderPath'
    }

    It 'labels the result SessionRoot when the resolved worktree is the session root' {
        # Arrange: the only root recording the issue is the session's own.
        Set-ItemTopology -Live @($script:Session) -Checkpoint @{ $script:Session = (New-CheckpointJson -IssueNumber '"901"') }

        # Act
        $target = Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901.' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'SessionRoot'
        $target.WorktreeRoot | Should -Be $script:Session
    }

    It 'carries the no-target and ambiguity codes supplied by the worktree-resolution accessors' {
        # Arrange: one unresolved case per code, built through the algorithm rather
        # than by asserting a literal.
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { throw 'enumeration must not run' }
        $noTarget = Resolve-WorktreeItemTarget -Text 'no identity at all' -SessionRoot $script:Session
        $ambiguous = Resolve-WorktreeItemTarget -Text ('Canonical issue number for this feature is 901. ' +
            'Canonical issue number for this feature is 902.') -SessionRoot $script:Session

        # Act / Assert: each code equals its accessor's value, so a change to either
        # literal moves both the module and this assertion together.
        $noTarget.ReasonCode | Should -Be (Get-WorktreeResolutionNoTargetReasonCode)
        $ambiguous.ReasonCode | Should -Be (Get-WorktreeResolutionAmbiguityReasonCode)
        $noTarget.ReasonCode | Should -Not -Be $ambiguous.ReasonCode
    }

    It 'names no absolute path in the Detail of any result' {
        # Arrange: one result per status, so every Detail template is exercised.
        Set-ItemTopology -Live @($script:Own, $script:Sibling) -BranchRoot @($script:Own, $script:Sibling) -Checkpoint @{
            $script:Own     = (New-CheckpointJson -IssueNumber '"901"')
            $script:Sibling = (New-CheckpointJson -IssueNumber '"901"')
        }
        $results = @(
            (Resolve-WorktreeItemTarget -Text 'nothing here' -SessionRoot $script:Session),
            (Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 901.' -SessionRoot $script:Session),
            (Resolve-WorktreeItemTarget -Text 'branch: f5-fixture-own' -SessionRoot $script:Session),
            (Resolve-WorktreeItemTarget -Text 'Canonical issue number for this feature is 902.' -SessionRoot $script:Session)
        )

        # Act / Assert: no Detail carries the synthetic root, a drive-letter path, or a
        # whitespace-preceded absolute path. The candidate roots live on Candidates,
        # which is an object field and is never rendered into a reason.
        foreach ($result in $results) {
            $result.Detail | Should -Not -BeNullOrEmpty
            $result.Detail.Contains($script:SeamRoot) | Should -BeFalse
            $result.Detail | Should -Not -Match '(?<![A-Za-z])[A-Za-z]:[\\/]'
            $result.Detail | Should -Not -Match '\s/'
        }
    }
}
