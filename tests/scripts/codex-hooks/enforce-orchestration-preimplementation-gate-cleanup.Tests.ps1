#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cleanup-context legs of the Codex preimplementation gate (issue #1026).

.DESCRIPTION
    The Codex decision function receives the mapped tool_input JSON the entry tail produces
    (file_path and, for a Write, the forwarded content; or the Bash or apply_patch command).
    The baseline mocks make every checkpoint read return nothing, so each implementation call
    reaches the final deny, where the cleanup legs of
    .codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1 are evaluated with
    -AllowPatchManifest.

    Seams: the worktree listing returns an in-memory porcelain text (the session root on main,
    /synthetic-worktrees/documentationandmemories on the consolidation branch, and
    /synthetic-worktrees/bug-example on a feature branch); the temporary-root seam returns a
    long-name and an 8.3 short-name spelling under /synthetic-users; the staged-index seam
    returns NUL-terminated names. The entry-tail rows drive the hook in-process with a
    StringReader stdin. No row creates a file, starts a process, reads a clock, or touches the
    network. Every deny row for an input rejected before consolidation identity, or for a
    non-consolidation target, compares the decision with the decision the gate returns when the
    cleanup leg is withheld; a denial after the consolidation worktree is identified as the
    target asserts the appended cleanup sub-code.
#>

Describe 'Codex preimplementation gate cleanup legs (issue #1026)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:GateHookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:GateHookPath
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:Blocked = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
        $script:Consolidation = '/synthetic-worktrees/documentationandmemories'
        $script:Feature = '/synthetic-worktrees/bug-example'
        $script:LongTemp = '/synthetic-users/LongUserName/AppData/Local/Temp/'
        $script:ShortTemp = '/synthetic-users/LONGUS~1/AppData/Local/Temp/'
        $script:Manifest = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"run-1026","removals":[]}'
        $script:ManifestRelative = 'artifacts/orchestration/cleanup-worktrees-manifest.json'
        $script:ManifestPath = "$($script:Session)/$($script:ManifestRelative)"
        $script:Nul = [string][char]0
        $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/documentationandmemories`n`nworktree $($script:Feature)`nbranch refs/heads/bug/example`n"

        function ConvertTo-CodexMappedInput {
            # The mapped tool_input JSON of the entry tail: Write forwards content, Edit an empty string.
            param([string] $FilePath = '', [string] $Command = '', [string] $Content = 'x')
            if ($FilePath) { return (@{ file_path = $FilePath; content = $Content } | ConvertTo-Json -Compress) }
            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }

        function ConvertTo-CodexEnvelope {
            param([string] $ToolName, [hashtable] $ToolInput)
            return ([ordered]@{ session_id = 'cleanup-1026'; cwd = $script:Session; hook_event_name = 'PreToolUse'; tool_name = $ToolName; tool_use_id = 'tool-cleanup'; tool_input = $ToolInput } | ConvertTo-Json -Compress -Depth 10)
        }

        function Set-CodexCleanupFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([string] $Listing = $script:Listing, [string] $Staged = "docs/research/y.md$($script:Nul).claude/agent-memory/x/y.md$($script:Nul)", [int] $StagedExitCode = 0)
            $listingText = $Listing
            $session = $script:Session
            $stagedResult = [pscustomobject]@{ ExitCode = $StagedExitCode; Output = $Staged }
            $temporary = @($script:LongTemp, $script:ShortTemp)
            Mock Get-OrchestrationGateWorktreeList { $listingText }.GetNewClosure()
            Mock Find-WorktreeResolutionRoot { $session }.GetNewClosure()
            Mock Get-OrchestrationGateTemporaryRoot { $temporary }.GetNewClosure()
            Mock Get-OrchestrationGateStagedIndex { $stagedResult }.GetNewClosure()
        }

        function Get-CodexCleanupDecision {
            param([string] $MappedInput)
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $MappedInput)
        }

        # Each mapped input is denied with exactly the decision the gate returns when the cleanup
        # leg is withheld. Runs last in an It, because it mocks the leg for the rest of it.
        function Assert-CodexUnchangedDeny {
            param([string[]] $MappedInput)
            $actual = @($MappedInput | ForEach-Object { Get-CodexCleanupDecision -MappedInput $_ | ConvertTo-Json -Compress -Depth 5 })
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = '' } }
            for ($index = 0; $index -lt $MappedInput.Count; $index++) {
                $today = Get-CodexCleanupDecision -MappedInput $MappedInput[$index] | ConvertTo-Json -Compress -Depth 5
                $actual[$index] | Should -BeExactly $today -Because "input $($MappedInput[$index]) must keep today's deny"
                $actual[$index] | Should -Match '"permissionDecision":"deny"'
                $actual[$index] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED:'
            }
        }

        # Asserts a deny whose reason is the unchanged blocked text followed by the cleanup sub-code.
        function Assert-CodexSubCodeDeny {
            param([Parameter(Mandatory)] $Decision, [Parameter(Mandatory)] [string] $SubCode)
            $reason = [string]$Decision.hookSpecificOutput.permissionDecisionReason
            $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.StartsWith("$($script:Blocked) Cleanup leg not applied: $($SubCode): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must carry $SubCode after the unchanged text"
        }

        function Invoke-CodexGateEntrypoint {
            # Drives the hook's own entry tail in-process; stdin is a StringReader and both console readers are restored.
            param([Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw)
            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $script:GateHookPath
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Stdout = ($stdout -join "`n"); Stderr = $errorWriter.ToString() }
            }
            finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    BeforeEach {
        Set-CodexCleanupFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'manifest Write' {
        It 'allows a Write of the session-root cleanup manifest with valid tool and schema_version and no checkpoint' {
            # Act
            $decisions = @($script:ManifestPath, $script:ManifestRelative) | ForEach-Object { Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath $_ -Content $script:Manifest) }

            # Assert
            foreach ($decision in $decisions) { $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' }
        }

        It 'denies a manifest Write whose tool is not cleanup-merged-worktrees' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath $script:ManifestPath -Content '{"tool":"other-tool","schema_version":1}')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'denies a manifest Write whose schema_version is not 1' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath $script:ManifestPath -Content '{"tool":"cleanup-merged-worktrees","schema_version":2}')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'denies a manifest Write at a path other than the session-root spelling' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:Consolidation)/$($script:ManifestRelative)" -Content $script:Manifest)

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'denies an Edit of the cleanup manifest without a checkpoint' {
            # Act: the entry tail forwards an empty content for an Edit record.
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath $script:ManifestPath -Content '')

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }
    }

    Context 'apply_patch manifest' {
        It 'allows an apply_patch Add File of the manifest with valid content' {
            # Arrange
            $patch = "*** Begin Patch`n*** Add File: $($script:ManifestRelative)`n+$($script:Manifest)`n*** End Patch"

            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command $patch)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies an apply_patch Update, Delete, or Move of the manifest' {
            # Arrange
            $patches = @(
                "*** Begin Patch`n*** Update File: $($script:ManifestRelative)`n@@`n-{}`n+$($script:Manifest)`n*** End Patch"
                "*** Begin Patch`n*** Delete File: $($script:ManifestRelative)`n*** End Patch"
                "*** Begin Patch`n*** Update File: artifacts/orchestration/old.json`n*** Move to: $($script:ManifestRelative)`n@@`n-a`n+b`n*** End Patch"
                "*** Begin Patch`n*** Add File: $($script:ManifestRelative)`n+{`"tool`":`"other`",`"schema_version`":1}`n*** End Patch"
            )

            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @($patches | ForEach-Object { ConvertTo-CodexMappedInput -Command $_ })
        }
    }

    Context 'entry tail' {
        It 'forwards Write content from the Codex entry tail to the decision' {
            # Arrange
            $write = ConvertTo-CodexEnvelope -ToolName 'Write' -ToolInput @{ file_path = $script:ManifestRelative; content = $script:Manifest }
            $edit = ConvertTo-CodexEnvelope -ToolName 'Edit' -ToolInput @{ file_path = $script:ManifestRelative; old_string = 'a'; new_string = $script:Manifest }

            # Act
            $written = Invoke-CodexGateEntrypoint -PayloadRaw $write
            $edited = Invoke-CodexGateEntrypoint -PayloadRaw $edit

            # Assert
            $written.ExitCode | Should -Be 0
            $written.Stdout | Should -BeNullOrEmpty -Because 'a valid manifest Write is allowed and the tail prints nothing on allow'
            $edited.ExitCode | Should -Be 0
            $edited.Stdout | Should -Match ([regex]::Escape($script:Blocked)) -Because 'an Edit forwards no content, so the manifest leg denies'
        }
    }

    Context 'consolidation git add and commit' {
        It 'allows git -C `<consolidation root`> add of docs/ and .claude/agent-memory/ operands' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command "git -C $($script:Consolidation) add -- docs/research/y.md .claude/agent-memory/x/y.md")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies git add in the consolidation worktree when any operand is outside the allowlist' {
            # Arrange
            $commands = @(
                "git -C $($script:Consolidation) add -- scripts/a.ps1"
                "git -C $($script:Consolidation) add -- README.md"
                "git -C $($script:Consolidation) add -A"
                "git -C $($script:Consolidation) add -f docs/research/y.md"
                'git add docs/research/y.md'
            )

            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @($commands | ForEach-Object { ConvertTo-CodexMappedInput -Command $_ })
        }

        It 'allows git -C `<consolidation root`> commit -F when the staged index is non-empty and entirely allowlisted' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command "git -C $($script:Consolidation) commit -F msg.txt")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq $script:Consolidation }
        }

        It 'denies the commit when the staged index holds a non-allowlisted path' {
            # Arrange
            Set-CodexCleanupFixture -Staged "docs/research/y.md$($script:Nul)scripts/a.ps1$($script:Nul)"

            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command "git -C $($script:Consolidation) commit -F msg.txt")

            # Assert
            Assert-CodexSubCodeDeny -Decision $decision -SubCode 'CLEANUP_LEG_STAGED_PATH_NOT_ALLOWLISTED'
        }

        It 'denies the commit when the staged index is empty or the staged-index seam fails' {
            # Arrange
            $mapped = ConvertTo-CodexMappedInput -Command "git -C $($script:Consolidation) commit -F msg.txt"
            $variants = @(
                @{ Staged = ''; Code = 0; SubCode = 'CLEANUP_LEG_STAGED_INDEX_EMPTY' }
                @{ Staged = "docs/research/y.md$($script:Nul)"; Code = 128; SubCode = 'CLEANUP_LEG_STAGED_INDEX_UNREADABLE' }
                @{ Staged = 'docs/research/y.md'; Code = 0; SubCode = 'CLEANUP_LEG_STAGED_INDEX_UNREADABLE' }
            )

            # Act
            $actual = @(foreach ($variant in $variants) {
                    Set-CodexCleanupFixture -Staged $variant.Staged -StagedExitCode $variant.Code
                    Get-CodexCleanupDecision -MappedInput $mapped
                })

            # Assert
            $actual.Count | Should -Be $variants.Count
            for ($index = 0; $index -lt $variants.Count; $index++) { Assert-CodexSubCodeDeny -Decision $actual[$index] -SubCode $variants[$index].SubCode }
        }

        It 'denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand' {
            # Arrange
            $commands = @(
                "git -C $($script:Consolidation) commit -a -m wip"
                "git -C $($script:Consolidation) commit --amend -F msg.txt"
                "git -C $($script:Consolidation) commit --pathspec-from-file=list.txt -m wip"
                "git -C $($script:Consolidation) commit -m wip docs/research/y.md"
            )

            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @($commands | ForEach-Object { ConvertTo-CodexMappedInput -Command $_ })
        }

        It 'identifies the consolidation worktree by porcelain branch documentationandmemories and not by path' {
            # Arrange
            $renamed = '/synthetic-worktrees/renamed-consolidation'
            Set-CodexCleanupFixture -Listing "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $renamed`nbranch refs/heads/documentationandmemories`n"
            $allowed = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command "git -C $renamed add -- docs/research/y.md")
            Set-CodexCleanupFixture -Listing "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Consolidation)`nbranch refs/heads/bug/other`n"
            $denied = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -Command "git -C $($script:Consolidation) add -- docs/research/y.md")

            # Assert
            $allowed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $denied.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }
    }

    Context 'scratch and consolidation Write' {
        It 'allows a Write under the temporary root in its long-name spelling outside every worktree and the session root' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:LongTemp)codex/issue-1026-a.ps1")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a Write under the temporary root in its 8.3 short-name spelling' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:ShortTemp)codex/issue-1026-a.ps1")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a scratch-named Write inside a registered worktree, inside the session root, or at a non-local path' {
            # Arrange
            $paths = @("$($script:Feature)/issue-1026-a.ps1", "$($script:Session)/issue-1026-a.ps1", '//server/share/Temp/issue-1026-a.ps1')

            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @($paths | ForEach-Object { ConvertTo-CodexMappedInput -FilePath $_ })
        }

        It 'allows the pr-author receipt Write of artifacts/pr_body_`<digits`>.receipt.json beneath the consolidation worktree' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:Consolidation)/artifacts/pr_body_7.receipt.json" -Content '{}')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies the same receipt path beneath a non-consolidation worktree' {
            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @(ConvertTo-CodexMappedInput -FilePath "$($script:Feature)/artifacts/pr_body_7.receipt.json" -Content '{}')
        }

        It 'allows an allowlisted implementation-extension Write inside the consolidation worktree' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:Consolidation)/docs/research/data.json")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'appends CLEANUP_LEG_PATH_NOT_ALLOWLISTED to the deny for a non-allowlisted Write inside the consolidation worktree' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:Consolidation)/scripts/docs/a.ps1")

            # Assert
            Assert-CodexSubCodeDeny -Decision $decision -SubCode 'CLEANUP_LEG_PATH_NOT_ALLOWLISTED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match ([regex]::Escape("'scripts/docs/a.ps1'"))
        }

        It 'keeps the exact deny text for the same Write beneath a non-consolidation worktree' {
            # Act
            $decision = Get-CodexCleanupDecision -MappedInput (ConvertTo-CodexMappedInput -FilePath "$($script:Feature)/scripts/docs/a.ps1")

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }
    }

    Context 'paired denials outside the consolidation worktree' {
        It 'denies <Case> against a non-consolidation worktree' -ForEach @(
            @{ Case = 'the manifest Write'; Path = '/synthetic-worktrees/bug-example/artifacts/orchestration/cleanup-worktrees-manifest.json'; Command = '' }
            @{ Case = 'the scratch Write'; Path = '/synthetic-worktrees/bug-example/codex/issue-1026-a.ps1'; Command = '' }
            @{ Case = 'the receipt Write'; Path = '/synthetic-worktrees/bug-example/artifacts/pr_body_7.receipt.json'; Command = '' }
            @{ Case = 'the allowlisted Write'; Path = '/synthetic-worktrees/bug-example/docs/research/data.json'; Command = '' }
            @{ Case = 'the git add'; Path = ''; Command = 'git -C /synthetic-worktrees/bug-example add -- docs/research/y.md' }
            @{ Case = 'the git commit'; Path = ''; Command = 'git -C /synthetic-worktrees/bug-example commit -F msg.txt' }
            @{ Case = 'the apply_patch manifest Add'; Path = ''; Command = "*** Begin Patch`n*** Add File: /synthetic-worktrees/bug-example/artifacts/orchestration/cleanup-worktrees-manifest.json`n+{`"tool`":`"cleanup-merged-worktrees`",`"schema_version`":1}`n*** End Patch" }
        ) {
            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @(ConvertTo-CodexMappedInput -FilePath $Path -Command $Command -Content $script:Manifest)
        }

        It 'denies <Case> against the session root' -ForEach @(
            @{ Case = 'the scratch Write'; Leaf = 'codex/issue-1026-a.ps1'; Operation = '' }
            @{ Case = 'the receipt Write'; Leaf = 'artifacts/pr_body_7.receipt.json'; Operation = '' }
            @{ Case = 'the allowlisted Write'; Leaf = 'docs/research/data.json'; Operation = '' }
            @{ Case = 'the git add'; Leaf = ''; Operation = 'add -- docs/research/y.md' }
            @{ Case = 'the git commit'; Leaf = ''; Operation = 'commit -F msg.txt' }
        ) {
            # Arrange
            $path = if ($Leaf) { "$($script:Session)/$Leaf" } else { '' }
            $command = if ($Operation) { "git -C $($script:Session) $Operation" } else { '' }

            # Act / Assert
            Assert-CodexUnchangedDeny -MappedInput @(ConvertTo-CodexMappedInput -FilePath $path -Command $command)
        }
    }
}
