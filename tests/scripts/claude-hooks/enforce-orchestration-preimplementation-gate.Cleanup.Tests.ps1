#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cleanup-context legs of the Claude preimplementation gate (issue #1026).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision with no ready checkpoint: the
    baseline mocks make every checkpoint read return nothing, so each call that the gate
    classifies as implementation reaches the final deny, where the cleanup legs of
    enforce-orchestration-preimplementation-gate-cleanup.ps1 are evaluated.

    Seams: the worktree listing Get-OrchestrationGateWorktreeList returns an in-memory porcelain
    text (the session root on main, /synthetic-worktrees/documentationandmemories on the
    consolidation branch, and /synthetic-worktrees/bug-example on a feature branch); the
    temporary-root seam returns a long-name and an 8.3 short-name spelling under
    /synthetic-users; the staged-index seam returns NUL-terminated names. No row creates a file,
    starts a process, reads a clock, or touches the network.

    Every deny row compares the decision with the decision the gate returns when the cleanup
    leg is withheld (Test-OrchestrationCleanupContextAllowed mocked to $false), so the deny text
    is the text the gate returns today.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    $script:RealTemporaryRoot = ${function:Get-OrchestrationGateTemporaryRoot}
    $script:RealStagedIndex = ${function:Get-OrchestrationGateStagedIndex}
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'

    $script:Blocked = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Consolidation = '/synthetic-worktrees/documentationandmemories'
    $script:Feature = '/synthetic-worktrees/bug-example'
    $script:LongTemp = '/synthetic-users/LongUserName/AppData/Local/Temp/'
    $script:ShortTemp = '/synthetic-users/LONGUS~1/AppData/Local/Temp/'
    $script:Manifest = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"run-1026","removals":[]}'
    $script:ManifestPath = "$($script:Session)/artifacts/orchestration/cleanup-worktrees-manifest.json"
    $script:Nul = [string][char]0
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/documentationandmemories`n`nworktree $($script:Feature)`nbranch refs/heads/bug/example`n"

    function ConvertTo-CleanupPayload {
        param([string] $Tool, [string] $FilePath = '', [string] $Command = '', [string] $Content = 'x')
        $toolInput = switch ($Tool) {
            'Write' { @{ file_path = $FilePath; content = $Content } }
            'Edit' { @{ file_path = $FilePath; old_string = 'a'; new_string = 'b' } }
            default { @{ command = $Command } }
        }
        return (@{ tool_name = $Tool; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    function Set-CleanupListing {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Listing = $script:Listing, [string] $Staged = "docs/research/y.md$($script:Nul).claude/agent-memory/x/y.md$($script:Nul)", [int] $StagedExitCode = 0)
        $listingText = $Listing
        $stagedResult = [pscustomobject]@{ ExitCode = $StagedExitCode; Output = $Staged }
        $temporary = @($script:LongTemp, $script:ShortTemp)
        Mock Get-OrchestrationGateWorktreeList { $listingText }.GetNewClosure()
        Mock Get-OrchestrationGateTemporaryRoot { $temporary }.GetNewClosure()
        Mock Get-OrchestrationGateStagedIndex { $stagedResult }.GetNewClosure()
    }

    function Get-CleanupDecision {
        param([string] $Payload)
        return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $Payload)
    }

    # Asserts that each payload is denied with exactly the decision the gate returns when the
    # cleanup leg is withheld. Runs last in an It, because it mocks the leg for the rest of it.
    function Assert-CleanupUnchangedDeny {
        param([string[]] $Payload)
        $actual = @($Payload | ForEach-Object { Get-CleanupDecision -Payload $_ | ConvertTo-Json -Compress -Depth 5 })
        Mock Test-OrchestrationCleanupContextAllowed { $false }
        for ($index = 0; $index -lt $Payload.Count; $index++) {
            $today = Get-CleanupDecision -Payload $Payload[$index] | ConvertTo-Json -Compress -Depth 5
            $actual[$index] | Should -BeExactly $today -Because "payload $($Payload[$index]) must keep today's deny"
            $actual[$index] | Should -Match '"permissionDecision":"deny"'
            $actual[$index] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED:'
        }
    }
}

Describe 'Claude preimplementation gate cleanup legs (issue #1026)' {
    BeforeEach {
        Set-CleanupListing
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'manifest Write' {
        It 'allows a Write of the session-root cleanup manifest with valid tool and schema_version and no checkpoint' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath $script:ManifestPath -Content $script:Manifest)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-OrchestrationGateWorktreeList -Times 1 -Exactly -Because 'only the gate resolution lists worktrees; the manifest leg is pure'
        }

        It 'denies a manifest Write whose tool is not cleanup-merged-worktrees' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath $script:ManifestPath -Content '{"tool":"other-tool","schema_version":1}')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'denies a manifest Write whose schema_version is not 1' {
            # Act
            $decisions = @('{"tool":"cleanup-merged-worktrees","schema_version":2}', '{"tool":"cleanup-merged-worktrees","schema_version":"1"}') | ForEach-Object {
                Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath $script:ManifestPath -Content $_)
            }

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked }
        }

        It 'denies a manifest Write at a path other than the session-root spelling' {
            # Arrange
            $paths = @("$($script:Consolidation)/artifacts/orchestration/cleanup-worktrees-manifest.json", "$($script:Session)/sub/artifacts/orchestration/cleanup-worktrees-manifest.json", "$($script:Session)/Artifacts/orchestration/cleanup-worktrees-manifest.json")

            # Act
            $decisions = $paths | ForEach-Object { Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath $_ -Content $script:Manifest) }

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked }
        }

        It 'denies an Edit of the cleanup manifest without a checkpoint' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Edit' -FilePath $script:ManifestPath)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'allows the relative spelling of the manifest path with valid content' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath 'artifacts/orchestration/cleanup-worktrees-manifest.json' -Content $script:Manifest)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'consolidation git add' {
        It 'allows git -C `<consolidation root`> add of docs/ and .claude/agent-memory/ operands' {
            # Act
            $decisions = @(
                "git -C $($script:Consolidation) add -- docs/research/y.md .claude/agent-memory/x/y.md"
                "git -C $($script:Consolidation) add docs/research/y.md && git -C $($script:Consolidation) add .claude/agent-memory/x/y.md"
            ) | ForEach-Object { Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Bash' -Command $_) }

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' }
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 0 -Exactly -Because 'git add never reads the staged index'
        }

        It 'denies git add in the consolidation worktree when any operand is outside the allowlist' {
            # Arrange
            $commands = @(
                "git -C $($script:Consolidation) add -- docs/research/y.md scripts/a.ps1"
                "git -C $($script:Consolidation) add -- README.md"
                "git -C $($script:Consolidation) add -A"
                "git -C $($script:Consolidation) add -f docs/research/y.md"
                'git add docs/research/y.md'
                "git -C $($script:Consolidation) add -- -- docs/research/y.md"
                "git -C $($script:Consolidation) add -- docs/research/y.md && pytest"
            )

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @($commands | ForEach-Object { ConvertTo-CleanupPayload -Tool 'Bash' -Command $_ })
        }
    }

    Context 'consolidation git commit' {
        It 'allows git -C `<consolidation root`> commit -F when the staged index is non-empty and entirely allowlisted' {
            # Act
            $decisions = @(
                "git -C $($script:Consolidation) commit -F /synthetic-users/LongUserName/AppData/Local/Temp/issue-1026-msg.txt"
                "git -C $($script:Consolidation) commit -m wip --trailer Refs=1026 --file=msg.txt --message=done"
            ) | ForEach-Object { Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Bash' -Command $_) }

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' }
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 2 -Exactly -ParameterFilter { $WorktreeRoot -eq $script:Consolidation }
        }

        It 'denies the commit when the staged index holds a non-allowlisted path' {
            # Arrange
            Set-CleanupListing -Staged "docs/research/y.md$($script:Nul)scripts/a.ps1$($script:Nul)"

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @(ConvertTo-CleanupPayload -Tool 'Bash' -Command "git -C $($script:Consolidation) commit -F msg.txt")
        }

        It 'denies the commit when the staged index is empty or the staged-index seam fails' {
            # Arrange
            $payload = ConvertTo-CleanupPayload -Tool 'Bash' -Command "git -C $($script:Consolidation) commit -F msg.txt"
            $actual = foreach ($variant in @(@{ Staged = ''; Code = 0 }, @{ Staged = "docs/research/y.md$($script:Nul)"; Code = 1 }, @{ Staged = ''; Code = -1 }, @{ Staged = 'docs/research/y.md'; Code = 0 }, @{ Staged = $script:Nul; Code = 0 })) {
                Set-CleanupListing -Staged $variant.Staged -StagedExitCode $variant.Code
                Get-CleanupDecision -Payload $payload
            }

            # Assert
            foreach ($decision in $actual) { $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked }
        }

        It 'denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand' {
            # Arrange
            $commands = @(
                "git -C $($script:Consolidation) commit -a -m wip"
                "git -C $($script:Consolidation) commit --amend -F msg.txt"
                "git -C $($script:Consolidation) commit --pathspec-from-file=list.txt -m wip"
                "git -C $($script:Consolidation) commit -m wip docs/research/y.md"
                "git -C $($script:Consolidation) commit -m"
                "git -C $($script:Consolidation) commit -mwip"
            )

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @($commands | ForEach-Object { ConvertTo-CleanupPayload -Tool 'Bash' -Command $_ })
        }
    }

    Context 'consolidation identity' {
        It 'identifies the consolidation worktree by porcelain branch documentationandmemories and not by path' {
            # Arrange: the consolidation branch is checked out at a path that does not name it.
            $renamed = '/synthetic-worktrees/renamed-consolidation'
            Set-CleanupListing -Listing "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $renamed`nbranch refs/heads/documentationandmemories`n"
            $allowed = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Bash' -Command "git -C $renamed add -- docs/research/y.md")
            $command = ConvertTo-CleanupPayload -Tool 'Bash' -Command "git -C $($script:Consolidation) add -- docs/research/y.md"
            $listings = @(
                "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/documentationandmemories`nprunable gitdir file points to non-existent location`n"
                "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nHEAD 0123456789abcdef0123456789abcdef01234567`ndetached`n"
                "worktree $($script:Consolidation)`nbranch refs/heads/documentationandmemories`n`nworktree $($script:Session)`nbranch refs/heads/main`n"
                "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/bug/other`n"
            )

            # Act
            $denied = foreach ($listing in $listings) {
                Set-CleanupListing -Listing $listing
                Get-CleanupDecision -Payload $command
            }

            # Assert
            $allowed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            foreach ($decision in $denied) {
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^PREIMPLEMENTATION_GATE_BLOCKED:'
            }
        }
    }

    Context 'scratch Write' {
        It 'allows a Write under the temporary root in its long-name spelling outside every worktree and the session root' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:LongTemp)claude/scratchpad/issue-1026/issue-1026-a.ps1")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a Write under the temporary root in its 8.3 short-name spelling' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:ShortTemp)claude/scratchpad/issue-1026/issue-1026-a.py")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a scratch-named Write inside a registered worktree, inside the session root, or at a non-local path' {
            # Arrange
            $paths = @("$($script:Feature)/issue-1026-a.ps1", "$($script:Session)/issue-1026-a.ps1", '//server/share/Temp/issue-1026-a.ps1', "$($script:Consolidation)/issue-1026-a.ps1")

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @($paths | ForEach-Object { ConvertTo-CleanupPayload -Tool 'Write' -FilePath $_ })
        }

        It 'denies a scratch Write when a registered worktree lies under the temporary root' {
            # Arrange
            Set-CleanupListing -Listing "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:ShortTemp)wt/item`nbranch refs/heads/bug/item`n"

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @(ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:ShortTemp)claude/issue-1026-a.ps1")
        }
    }

    Context 'consolidation Write' {
        It 'allows the pr-author receipt Write of artifacts/pr_body_`<digits`>.receipt.json beneath the consolidation worktree' {
            # Act
            $decision = Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:Consolidation)/artifacts/pr_body_7.receipt.json" -Content '{}')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies the same receipt path beneath a non-consolidation worktree' {
            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @(ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:Feature)/artifacts/pr_body_7.receipt.json" -Content '{}')
        }

        It 'allows an allowlisted implementation-extension Write or Edit inside the consolidation worktree' {
            # Act
            $decisions = @(
                (Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Write' -FilePath "$($script:Consolidation)/docs/research/data.json")),
                (Get-CleanupDecision -Payload (ConvertTo-CleanupPayload -Tool 'Edit' -FilePath "$($script:Consolidation)/.claude/agent-memory/x/notes.json"))
            )

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' }
        }

        It 'denies a consolidation Write whose relative path is outside the allowlist' {
            # Arrange
            $paths = @("$($script:Consolidation)/scripts/docs/a.ps1", "$($script:Consolidation)/artifacts/pr_body_7.json", "$($script:Consolidation)/.claude/rules/x.json")

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @($paths | ForEach-Object { ConvertTo-CleanupPayload -Tool 'Write' -FilePath $_ })
        }
    }

    Context 'paired denials outside the consolidation worktree' {
        It 'denies <Case> against a non-consolidation worktree' -ForEach @(
            @{ Case = 'the manifest Write'; Tool = 'Write'; Path = '/synthetic-worktrees/bug-example/artifacts/orchestration/cleanup-worktrees-manifest.json'; Command = '' }
            @{ Case = 'the scratch Write'; Tool = 'Write'; Path = '/synthetic-worktrees/bug-example/claude/scratchpad/issue-1026/issue-1026-a.ps1'; Command = '' }
            @{ Case = 'the receipt Write'; Tool = 'Write'; Path = '/synthetic-worktrees/bug-example/artifacts/pr_body_7.receipt.json'; Command = '' }
            @{ Case = 'the allowlisted Write'; Tool = 'Write'; Path = '/synthetic-worktrees/bug-example/docs/research/data.json'; Command = '' }
            @{ Case = 'the git add'; Tool = 'Bash'; Path = ''; Command = 'git -C /synthetic-worktrees/bug-example add -- docs/research/y.md .claude/agent-memory/x/y.md' }
            @{ Case = 'the git commit'; Tool = 'Bash'; Path = ''; Command = 'git -C /synthetic-worktrees/bug-example commit -F msg.txt' }
        ) {
            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @(ConvertTo-CleanupPayload -Tool $Tool -FilePath $Path -Command $Command -Content $script:Manifest)
        }

        It 'denies <Case> against the session root' -ForEach @(
            @{ Case = 'the scratch Write'; Tool = 'Write'; Leaf = 'claude/scratchpad/issue-1026/issue-1026-a.ps1'; Operation = '' }
            @{ Case = 'the receipt Write'; Tool = 'Write'; Leaf = 'artifacts/pr_body_7.receipt.json'; Operation = '' }
            @{ Case = 'the allowlisted Write'; Tool = 'Write'; Leaf = 'docs/research/data.json'; Operation = '' }
            @{ Case = 'the git add'; Tool = 'Bash'; Leaf = ''; Operation = 'add -- docs/research/y.md .claude/agent-memory/x/y.md' }
            @{ Case = 'the git commit'; Tool = 'Bash'; Leaf = ''; Operation = 'commit -F msg.txt' }
        ) {
            # Arrange
            $path = if ($Leaf) { "$($script:Session)/$Leaf" } else { '' }
            $command = if ($Operation) { "git -C $($script:Session) $Operation" } else { '' }

            # Act / Assert
            Assert-CleanupUnchangedDeny -Payload @(ConvertTo-CleanupPayload -Tool $Tool -FilePath $path -Command $command)
        }
    }

    Context 'prefilters and fail-closed behavior' {
        It 'starts no listing process when every prefilter fails' {
            # Act
            $write = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CleanupPayload -Tool 'Write' -FilePath 'scripts/a.ps1') -CheckpointRaw '{}'
            $commit = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CleanupPayload -Tool 'Bash' -Command 'git commit -m wip') -CheckpointRaw '{}'

            # Assert
            $write.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            $commit.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Get-OrchestrationGateWorktreeList -Times 0 -Exactly
        }

        It 'answers false when the listing throws, is empty, or names no consolidation worktree' {
            # Arrange
            Mock Get-OrchestrationGateWorktreeList { throw 'simulated listing failure (issue #1026)' }
            $thrown = Test-OrchestrationCleanupContextAllowed -FilePath "$($script:Consolidation)/docs/research/data.json" -Content 'x' -Command ''
            Mock Get-OrchestrationGateWorktreeList { '' }
            $empty = @(
                (Test-OrchestrationCleanupContextAllowed -FilePath "$($script:LongTemp)claude/a.ps1" -Content 'x' -Command ''),
                (Test-OrchestrationCleanupContextAllowed -FilePath '' -Content '' -Command "git -C $($script:Consolidation) add -- docs/research/y.md")
            )

            # Assert
            $thrown | Should -BeFalse
            $empty | Should -Not -Contain $true
            Test-OrchestrationCleanupContextAllowed -FilePath '' -Content '' -Command '' | Should -BeFalse
        }

        It 'denies a consolidation command that the target resolver cannot resolve or that is unresolvable text' {
            # Arrange
            $commands = @(
                "git -C $($script:Consolidation) add -- docs/research/`$name.md"
                "GIT_DIR=/x git -C $($script:Consolidation) add -- docs/research/y.md"
                "git -C $($script:Consolidation) add -- 'docs/research/y.md"
                'git -C relative/root add -- docs/research/y.md'
            )

            # Act
            $results = $commands | ForEach-Object { Test-OrchestrationCleanupContextAllowed -FilePath '' -Content '' -Command $_ }

            # Assert
            $results | Should -Not -Contain $true
        }

        It 'admits only a single-marker apply_patch Add File of the manifest with -AllowPatchManifest' {
            # Arrange
            $added = "*** Begin Patch`n*** Add File: artifacts/orchestration/cleanup-worktrees-manifest.json`n+$($script:Manifest)`n*** End Patch"
            $twoMarkers = "*** Begin Patch`n*** Add File: artifacts/orchestration/cleanup-worktrees-manifest.json`n+{}`n*** Add File: docs/x.md`n+x`n*** End Patch"
            $update = "*** Begin Patch`n*** Update File: artifacts/orchestration/cleanup-worktrees-manifest.json`n@@`n-a`n+b`n*** End Patch"
            $otherPath = "*** Begin Patch`n*** Add File: artifacts/orchestration/other.json`n+$($script:Manifest)`n*** End Patch"
            $contextLine = "*** Begin Patch`n*** Add File: artifacts/orchestration/cleanup-worktrees-manifest.json`n $($script:Manifest)`n*** End Patch"

            # Act / Assert
            Test-OrchestrationCleanupContextAllowed -Command $added -AllowPatchManifest | Should -BeTrue
            Test-OrchestrationCleanupContextAllowed -Command $added | Should -BeFalse -Because 'only the Codex gate passes -AllowPatchManifest'
            foreach ($patch in @($twoMarkers, $update, $otherPath, $contextLine)) {
                Test-OrchestrationCleanupContextAllowed -Command $patch -AllowPatchManifest | Should -BeFalse
            }
        }
    }

    Context 'seam bodies' {
        It 'returns distinct non-empty temporary-root spellings' {
            # Act
            $roots = @(& $script:RealTemporaryRoot)

            # Assert
            $roots.Count | Should -BeGreaterThan 0
            @($roots | Select-Object -Unique).Count | Should -Be $roots.Count
            @($roots | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count | Should -Be 0
        }

        It 'reads the staged index through the bounded docs-only git seam' {
            # Arrange
            Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 0; Output = 'docs/a.md' } }

            # Act
            $result = & $script:RealStagedIndex -WorktreeRoot $script:Consolidation

            # Assert
            $result.Output | Should -Be 'docs/a.md'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter {
                $WorktreeRoot -eq $script:Consolidation -and ($GitArgs -join ' ') -ceq 'diff --cached --name-only -z --no-renames --no-color --no-ext-diff --no-relative'
            }
        }
    }
}
