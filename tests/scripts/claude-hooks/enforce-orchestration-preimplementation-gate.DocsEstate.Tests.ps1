#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Docs-estate leg of the Claude preimplementation gate (issue #1169).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision with no ready checkpoint, so each call
    the gate classifies as implementation reaches the final deny, where the cleanup leg and then
    the docs-estate leg of enforce-orchestration-preimplementation-gate-docs.ps1 are evaluated.

    Seams: the worktree listing Get-OrchestrationGateWorktreeList returns an in-memory porcelain
    text (the session root on main and /synthetic-worktrees/docs-run on a docs branch); the
    staged-index seam returns NUL-terminated names; Get-WorktreeResolutionGitFileText returns the
    profile text for the docs-profile path and the baseline $null for any other path;
    Test-OrchestrationDocsEstateCheckpointPresent returns a
    per-row answer. No row creates a file, starts a process, reads a clock, or sets an environment
    variable.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'

    $script:Blocked = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:DocsRun = '/synthetic-worktrees/docs-run'
    $script:Nul = [string][char]0
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:DocsRun)`nbranch refs/heads/docs/estate`n"
    $script:ValidProfile = ([ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }, @{ id = 'guide'; path = 'guide' }); artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json' } } | ConvertTo-Json -Depth 6 -Compress)
    # Under the pre-CR3 rule this profile admits guide/start.md (a .md file under a root) and
    # scripts/evil.ps1 (under an artifact directory); under the CR3 rule it admits neither.
    $script:DiscriminatingProfile = ([ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }, @{ id = 'guide'; path = 'guide' }); artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; extra = 'scripts/x.json' } } | ConvertTo-Json -Depth 6 -Compress)

    function ConvertTo-DocsEstatePayload {
        param([string] $Tool, [string] $FilePath = '', [string] $Command = '')
        $toolInput = if ($Tool -eq 'Write') { @{ file_path = $FilePath; content = '{}' } } else { @{ command = $Command } }
        return (@{ tool_name = $Tool; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    function Set-DocsEstateSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()][object] $ProfileText = $script:ValidProfile,
            [bool] $CheckpointPresent = $false,
            [string] $Staged = "docs/a.md$($script:Nul)",
            [int] $StagedExitCode = 0
        )
        $listingText = $script:Listing
        $profileValue = $ProfileText
        $present = $CheckpointPresent
        $stagedResult = [pscustomobject]@{ ExitCode = $StagedExitCode; Output = $Staged }
        Mock Get-OrchestrationGateWorktreeList { $listingText }.GetNewClosure()
        Mock Get-OrchestrationGateStagedIndex { $stagedResult }.GetNewClosure()
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $present }.GetNewClosure()
        Mock Get-WorktreeResolutionGitFileText { $profileValue }.GetNewClosure() -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
    }

    function Get-DocsEstateDecision {
        param([string] $Payload)
        return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $Payload)
    }

    function Assert-DocsEstateSubCodeDeny {
        param([Parameter(Mandatory)] $Decision, [Parameter(Mandatory)] [string] $SubCode)
        $reason = [string]$Decision.hookSpecificOutput.permissionDecisionReason
        $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith("$($script:Blocked) Docs-estate leg not applied: $($SubCode): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must carry $SubCode after the unchanged text"
    }

    function Assert-DocsEstateUnchangedDeny {
        param([Parameter(Mandatory)] $Decision)
        $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        [string]$Decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked -Because 'the deny text carries no docs-estate suffix'
    }
}

AfterAll {
    # Remove the top-level functions of the dot-sourced gate and of the docs-leg files it loads.
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    foreach ($file in @('enforce-orchestration-preimplementation-gate.ps1', 'enforce-orchestration-preimplementation-gate-docs.ps1', 'hook-docs-estate-context.ps1') | ForEach-Object { Join-Path $hookRoot $_ }) {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Claude preimplementation gate docs-estate leg (issue #1169)' {
    BeforeEach {
        Set-DocsEstateSeam
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allowed docs-estate operations' {
        It 'allows <Label>' -ForEach @(
            @{ Label = 'a relative git add of docs paths'; Command = 'git add -- docs/a.md docs/documentation-estate/docs-coverage-ledger.json' }
            @{ Label = 'a git add of the docs-init workflow path'; Command = 'git add -- .github/workflows/_docs-quality.yml docs/documentation-estate/.vale.ini' }
            @{ Label = 'a git -C <absolute root> add'; Command = 'git -C /synthetic-worktrees/docs-run add -- docs/a.md' }
            @{ Label = 'a relative git commit -F with no pathspec'; Command = 'git commit -F artifacts/commit-message.txt' }
            @{ Label = 'a git -C <absolute root> commit -m'; Command = 'git -C /synthetic-worktrees/docs-run commit -m "docs: refresh"' }
            @{ Label = 'a chained add and commit'; Command = 'git add -- docs/a.md && git commit -F artifacts/commit-message.txt' }
            @{ Label = 'a git commit with a single --file= option'; Command = 'git commit --file=artifacts/commit-message.txt' }
            @{ Label = 'a git commit with a single --message= option'; Command = 'git commit --message=docs' }
            @{ Label = 'a git commit with a single --trailer= option'; Command = 'git commit --trailer=Refs:1169' }
            @{ Label = 'a git -C <absolute root> commit with a single --file= option'; Command = 'git -C /synthetic-worktrees/docs-run commit --file=artifacts/commit-message.txt' }
            @{ Label = 'a git commit with two =-form options'; Command = 'git commit --file=artifacts/commit-message.txt --trailer=Refs:1169' }
        ) {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }

        It 'allows the pr-author receipt Write as a <Label> path' -ForEach @(
            @{ Label = 'relative'; Path = 'artifacts/pr_body_12.receipt.json' }
            @{ Label = 'absolute'; Path = '/synthetic-worktrees/docs-run/artifacts/pr_body_12.receipt.json' }
        ) {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Write' -FilePath $Path)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }
    }

    Context 'command shape prefilter' {
        It 'returns one commit shape for a single =-form option' {
            # Act
            $shapes = Get-OrchestrationDocsEstateCommandShape -Command 'git commit --file=msg.txt'

            # Assert
            $null -eq $shapes | Should -BeFalse -Because 'a single --file= option is an admitted commit option'
            $shapes.Count | Should -Be 1
            $shapes[0].Kind | Should -BeExactly 'commit'
        }
    }

    Context 'denials with a docs-estate sub-code' {
        It 'denies DOCS_LEG_PROFILE_INVALID for an invalid profile on <Label>' -ForEach @(
            @{ Label = 'a git add'; Tool = 'Bash'; Command = 'git add -- docs/a.md'; Path = '' }
            @{ Label = 'the receipt Write'; Tool = 'Write'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json' }
        ) {
            # Arrange
            Set-DocsEstateSeam -ProfileText '{"artifact_kind":"docs-profile","documentation_roots":[]}'

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool $Tool -Command $Command -FilePath $Path)

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode 'DOCS_LEG_PROFILE_INVALID'
        }

        It 'denies DOCS_LEG_PATH_NOT_ALLOWED for <Label>' -ForEach @(
            @{ Label = 'a source operand'; Command = 'git add -- docs/a.md src/a.ps1' }
            @{ Label = 'a non-Markdown path under a root outside docs/'; Command = 'git add -- guide/start.txt' }
            @{ Label = 'a .. operand'; Command = 'git add -- docs/../src/a.ps1' }
        ) {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command $Command)

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode 'DOCS_LEG_PATH_NOT_ALLOWED'
        }

        It 'denies DOCS_LEG_PATH_NOT_ALLOWED for a git add of a .md path under a root outside docs/' {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git add -- guide/start.md')

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode 'DOCS_LEG_PATH_NOT_ALLOWED'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'guide/start.md'*"
        }

        It 'denies DOCS_LEG_PATH_NOT_ALLOWED for an add operand <Outside> outside docs/ under the discriminating profile' -ForEach @(
            @{ Outside = 'guide/start.md' }
            @{ Outside = 'scripts/evil.ps1' }
        ) {
            # Arrange
            Set-DocsEstateSeam -ProfileText $script:DiscriminatingProfile

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command "git add -- docs/a.md $Outside")

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode 'DOCS_LEG_PATH_NOT_ALLOWED'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'$Outside'*"
        }

        It 'denies DOCS_LEG_STAGED_PATH_NOT_ALLOWED for a staged path <Outside> outside docs/ under the discriminating profile' -ForEach @(
            @{ Outside = 'guide/start.md' }
            @{ Outside = 'scripts/evil.ps1' }
        ) {
            # Arrange
            Set-DocsEstateSeam -ProfileText $script:DiscriminatingProfile -Staged "docs/a.md$($script:Nul)$Outside$($script:Nul)"

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git commit -F artifacts/commit-message.txt')

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode 'DOCS_LEG_STAGED_PATH_NOT_ALLOWED'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'$Outside'*"
        }

        It 'denies <SubCode> for <Label>' -ForEach @(
            @{ Label = 'an unreadable staged index'; SubCode = 'DOCS_LEG_STAGED_INDEX_UNREADABLE'; Staged = ''; ExitCode = 128 }
            @{ Label = 'a staged index without the trailing NUL'; SubCode = 'DOCS_LEG_STAGED_INDEX_UNREADABLE'; Staged = 'docs/a.md'; ExitCode = 0 }
            @{ Label = 'an empty staged index'; SubCode = 'DOCS_LEG_STAGED_INDEX_EMPTY'; Staged = ''; ExitCode = 0 }
            @{ Label = 'a staged path outside the docs path set'; SubCode = 'DOCS_LEG_STAGED_PATH_NOT_ALLOWED'; Staged = "docs/a.md$([char]0)src/a.ps1$([char]0)"; ExitCode = 0 }
        ) {
            # Arrange
            Set-DocsEstateSeam -Staged $Staged -StagedExitCode $ExitCode

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git commit -F artifacts/commit-message.txt')

            # Assert
            Assert-DocsEstateSubCodeDeny -Decision $decision -SubCode $SubCode
        }
    }

    Context 'denials with the unchanged deny text' {
        It 'denies a docs git add chained with <Tool> with an empty docs suffix and no docs-leg I/O' -ForEach @(
            @{ Tool = 'pytest'; Command = 'git add -- docs/a.md && pytest -q' }
            @{ Tool = 'ruff'; Command = 'git add -- docs/a.md && ruff check .' }
            @{ Tool = 'black'; Command = 'git add -- docs/a.md && black .' }
            @{ Tool = 'pyright'; Command = 'git add -- docs/a.md; pyright' }
            @{ Tool = 'npm'; Command = 'git add -- docs/a.md && npm test' }
            @{ Tool = 'npx'; Command = 'git add -- docs/a.md && npx jest' }
            @{ Tool = 'Invoke-Pester'; Command = 'git add -- docs/a.md && Invoke-Pester' }
        ) {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command $Command)

            # Assert
            Assert-DocsEstateUnchangedDeny -Decision $decision
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        It 'denies <Label> with an empty docs suffix' -ForEach @(
            @{ Label = 'a commit that carries a pathspec'; Command = 'git commit -m x -- docs/a.md' }
            @{ Label = 'a commit with -a'; Command = 'git commit -a -m x' }
            @{ Label = 'a commit with --amend'; Command = 'git commit --amend -m x' }
            @{ Label = 'a git add without the -- separator'; Command = 'git add docs/a.md' }
            @{ Label = 'a git add with an option'; Command = 'git add -f -- docs/a.md' }
        ) {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command $Command)

            # Assert
            Assert-DocsEstateUnchangedDeny -Decision $decision
        }

        It 'does not apply the docs leg when a checkpoint is present at R (<Label>)' -ForEach @(
            @{ Label = 'git add'; Tool = 'Bash'; Command = 'git add -- docs/a.md'; Path = '' }
            @{ Label = 'receipt Write'; Tool = 'Write'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json' }
        ) {
            # Arrange
            Set-DocsEstateSeam -CheckpointPresent $true

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool $Tool -Command $Command -FilePath $Path)

            # Assert
            Assert-DocsEstateUnchangedDeny -Decision $decision
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        It 'keeps the deny text byte-identical without a profile file (<Label>)' -ForEach @(
            @{ Label = 'git add'; Tool = 'Bash'; Command = 'git add -- src/a.ps1'; Path = '' }
            @{ Label = 'git commit'; Tool = 'Bash'; Command = 'git commit -F artifacts/commit-message.txt'; Path = '' }
            @{ Label = 'receipt Write'; Tool = 'Write'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json' }
        ) {
            # Arrange
            Set-DocsEstateSeam -ProfileText $null
            $payload = ConvertTo-DocsEstatePayload -Tool $Tool -Command $Command -FilePath $Path

            # Act
            $actual = Get-DocsEstateDecision -Payload $payload | ConvertTo-Json -Compress -Depth 5
            Mock Get-OrchestrationDocsEstateContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = '' } }
            $withheld = Get-DocsEstateDecision -Payload $payload | ConvertTo-Json -Compress -Depth 5

            # Assert
            $actual | Should -BeExactly $withheld -Because 'without a profile the docs leg changes no deny text'
            $actual | Should -Match '"permissionDecision":"deny"'
        }

        It 'does not admit a Write to another .json path' {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Write' -FilePath 'artifacts/other.json')

            # Assert
            Assert-DocsEstateUnchangedDeny -Decision $decision
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        It 'does not apply the docs leg to an absolute Write outside every registered worktree' {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Write' -FilePath '/elsewhere/artifacts/pr_body_12.receipt.json')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }
    }

    Context 'leg order' {
        It 'allows a call the cleanup leg allows with no docs-leg seam call' {
            # Arrange
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $true; DenySuffix = '' } }

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git add -- docs/a.md')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Test-OrchestrationDocsEstateCheckpointPresent -Times 0 -Exactly
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        It 'appends the docs suffix after the cleanup suffix' {
            # Arrange
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = ' Cleanup leg not applied: X: y.' } }

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git add -- src/a.ps1')
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason.StartsWith("$($script:Blocked) Cleanup leg not applied: X: y. Docs-estate leg not applied: DOCS_LEG_PATH_NOT_ALLOWED: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        }

        It 'reads the docs profile once beneath the resolved root' {
            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git -C /synthetic-worktrees/docs-run add -- docs/a.md')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 1 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('/synthetic-worktrees/docs-run/docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 1 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        It 'declines without throwing when a seam throws' {
            # Arrange
            Mock Get-WorktreeResolutionGitFileText { throw [System.IO.IOException]::new('locked') } -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }

            # Act
            $decision = Get-DocsEstateDecision -Payload (ConvertTo-DocsEstatePayload -Tool 'Bash' -Command 'git add -- docs/a.md')

            # Assert
            Assert-DocsEstateUnchangedDeny -Decision $decision
        }
    }
}
