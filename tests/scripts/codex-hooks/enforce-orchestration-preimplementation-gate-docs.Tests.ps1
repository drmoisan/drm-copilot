#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Docs-estate leg of the Codex preimplementation gate (issue #1169).

.DESCRIPTION
    The Codex decision function receives the mapped tool_input JSON the entry tail produces
    (file_path and content for a Write, or the Bash command). The baseline mocks make every
    checkpoint read return nothing, so each implementation call reaches the final deny, where the
    cleanup leg and then the docs-estate leg of
    .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 are evaluated.

    Seams: the worktree listing returns an in-memory porcelain text (the session root on main and
    /synthetic-worktrees/docs-run on a docs branch); the staged-index seam returns NUL-terminated
    names; Get-WorktreeResolutionGitFileText returns the profile text for the docs-profile path
    and the baseline $null for any other path; and
    Test-OrchestrationDocsEstateCheckpointPresent returns a per-row answer. No row creates a file,
    starts a process, reads a clock, or sets an environment variable.
#>

Describe 'Codex preimplementation gate docs-estate leg (issue #1169)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:Blocked = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
        $script:Nul = [string][char]0
        $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree /synthetic-worktrees/docs-run`nbranch refs/heads/docs/estate`n"
        $script:ValidProfile = ([ordered]@{ artifact_kind = 'docs-profile'; documentation_roots = @(@{ id = 'docs-root'; path = 'docs' }, @{ id = 'guide'; path = 'guide' }); artifact_paths = [ordered]@{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json' } } | ConvertTo-Json -Depth 6 -Compress)

        function ConvertTo-CodexDocsMappedInput {
            param([string] $FilePath = '', [string] $Command = '')
            if ($FilePath) { return (@{ file_path = $FilePath; content = '{}' } | ConvertTo-Json -Compress) }
            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }

        function Set-CodexDocsEstateFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [AllowNull()][object] $ProfileText = $script:ValidProfile,
                [bool] $CheckpointPresent = $false,
                [string] $Staged = "docs/a.md$($script:Nul)",
                [int] $StagedExitCode = 0
            )
            $listingText = $script:Listing
            $session = $script:Session
            $profileValue = $ProfileText
            $present = $CheckpointPresent
            $stagedResult = [pscustomobject]@{ ExitCode = $StagedExitCode; Output = $Staged }
            Mock Get-OrchestrationGateWorktreeList { $listingText }.GetNewClosure()
            Mock Find-WorktreeResolutionRoot { $session }.GetNewClosure()
            Mock Get-OrchestrationGateStagedIndex { $stagedResult }.GetNewClosure()
            Mock Test-OrchestrationDocsEstateCheckpointPresent { $present }.GetNewClosure()
            Mock Get-WorktreeResolutionGitFileText { $profileValue }.GetNewClosure() -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        }

        function Get-CodexDocsEstateDecision {
            param([string] $MappedInput)
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $MappedInput)
        }

        function Assert-CodexDocsEstateSubCodeDeny {
            param([Parameter(Mandatory)] $Decision, [Parameter(Mandatory)] [string] $SubCode)
            $reason = [string]$Decision.hookSpecificOutput.permissionDecisionReason
            $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.StartsWith("$($script:Blocked) Docs-estate leg not applied: $($SubCode): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must carry $SubCode after the unchanged text"
        }

        function Assert-CodexDocsEstateUnchangedDeny {
            param([Parameter(Mandatory)] $Decision)
            $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            [string]$Decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked -Because 'the deny text carries no docs-estate suffix'
        }
    }

    BeforeEach {
        Set-CodexDocsEstateFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'allows <Label> (codex)' -ForEach @(
        @{ Label = 'a relative git add of docs paths'; Command = 'git add -- docs/a.md .github/workflows/_docs-quality.yml'; Path = '' }
        @{ Label = 'a git -C <absolute root> add'; Command = 'git -C /synthetic-worktrees/docs-run add -- guide/start.md'; Path = '' }
        @{ Label = 'a git commit -F with no pathspec'; Command = 'git commit -F artifacts/commit-message.txt'; Path = '' }
        @{ Label = 'a git commit with a single --file= option'; Command = 'git commit --file=artifacts/commit-message.txt'; Path = '' }
        @{ Label = 'a git commit with a single --message= option'; Command = 'git commit --message=docs'; Path = '' }
        @{ Label = 'a git commit with a single --trailer= option'; Command = 'git commit --trailer=Refs:1169'; Path = '' }
        @{ Label = 'a git -C <absolute root> commit with a single --file= option'; Command = 'git -C /synthetic-worktrees/docs-run commit --file=artifacts/commit-message.txt'; Path = '' }
        @{ Label = 'a git commit with two =-form options'; Command = 'git commit --file=artifacts/commit-message.txt --trailer=Refs:1169'; Path = '' }
        @{ Label = 'the mapped relative receipt Write'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json' }
        @{ Label = 'the mapped absolute receipt Write'; Command = ''; Path = '/synthetic-worktrees/docs-run/artifacts/pr_body_12.receipt.json' }
    ) {
        # Act
        $decision = Get-CodexDocsEstateDecision -MappedInput (ConvertTo-CodexDocsMappedInput -Command $Command -FilePath $Path)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
    }

    It 'denies <SubCode> for <Label> (codex)' -ForEach @(
        @{ Label = 'an invalid profile'; SubCode = 'DOCS_LEG_PROFILE_INVALID'; ProfileKind = '{"artifact_kind":"other"}'; Command = 'git add -- docs/a.md'; Staged = "docs/a.md$([char]0)"; ExitCode = 0 }
        @{ Label = 'a source operand'; SubCode = 'DOCS_LEG_PATH_NOT_ALLOWED'; ProfileKind = 'valid'; Command = 'git add -- src/a.ps1'; Staged = "docs/a.md$([char]0)"; ExitCode = 0 }
        @{ Label = 'a non-Markdown path under a root outside docs/'; SubCode = 'DOCS_LEG_PATH_NOT_ALLOWED'; ProfileKind = 'valid'; Command = 'git add -- guide/start.txt'; Staged = "docs/a.md$([char]0)"; ExitCode = 0 }
        @{ Label = 'an unreadable staged index'; SubCode = 'DOCS_LEG_STAGED_INDEX_UNREADABLE'; ProfileKind = 'valid'; Command = 'git commit -m x'; Staged = 'docs/a.md'; ExitCode = 0 }
        @{ Label = 'a failed staged-index read'; SubCode = 'DOCS_LEG_STAGED_INDEX_UNREADABLE'; ProfileKind = 'valid'; Command = 'git commit -m x'; Staged = ''; ExitCode = 124 }
        @{ Label = 'an empty staged index'; SubCode = 'DOCS_LEG_STAGED_INDEX_EMPTY'; ProfileKind = 'valid'; Command = 'git commit -m x'; Staged = ''; ExitCode = 0 }
        @{ Label = 'a staged path outside the docs path set'; SubCode = 'DOCS_LEG_STAGED_PATH_NOT_ALLOWED'; ProfileKind = 'valid'; Command = 'git commit -m x'; Staged = "src/a.ps1$([char]0)"; ExitCode = 0 }
    ) {
        # Arrange
        $profileText = if ($ProfileKind -ceq 'valid') { $script:ValidProfile } else { $ProfileKind }
        Set-CodexDocsEstateFixture -ProfileText $profileText -Staged $Staged -StagedExitCode $ExitCode

        # Act
        $decision = Get-CodexDocsEstateDecision -MappedInput (ConvertTo-CodexDocsMappedInput -Command $Command)

        # Assert
        Assert-CodexDocsEstateSubCodeDeny -Decision $decision -SubCode $SubCode
    }

    It 'denies <Label> with the unchanged deny text (codex)' -ForEach @(
        @{ Label = 'a docs git add chained with pytest'; Command = 'git add -- docs/a.md && pytest -q'; Path = ''; Present = $false; HasProfile = $true }
        @{ Label = 'a docs git add chained with Invoke-Pester'; Command = 'git add -- docs/a.md; Invoke-Pester'; Path = ''; Present = $false; HasProfile = $true }
        @{ Label = 'a commit with a pathspec'; Command = 'git commit -m x -- docs/a.md'; Path = ''; Present = $false; HasProfile = $true }
        @{ Label = 'a commit with --amend'; Command = 'git commit --amend -m x'; Path = ''; Present = $false; HasProfile = $true }
        @{ Label = 'a git add with a checkpoint present'; Command = 'git add -- docs/a.md'; Path = ''; Present = $true; HasProfile = $true }
        @{ Label = 'the receipt Write with a checkpoint present'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json'; Present = $true; HasProfile = $true }
        @{ Label = 'the receipt Write without a profile'; Command = ''; Path = 'artifacts/pr_body_12.receipt.json'; Present = $false; HasProfile = $false }
        @{ Label = 'a git add without a profile'; Command = 'git add -- src/a.ps1'; Path = ''; Present = $false; HasProfile = $false }
        @{ Label = 'a Write to another .json path'; Command = ''; Path = 'artifacts/other.json'; Present = $false; HasProfile = $true }
    ) {
        # Arrange
        $profileText = if ($HasProfile) { $script:ValidProfile } else { $null }
        Set-CodexDocsEstateFixture -ProfileText $profileText -CheckpointPresent $Present

        # Act
        $decision = Get-CodexDocsEstateDecision -MappedInput (ConvertTo-CodexDocsMappedInput -Command $Command -FilePath $Path)

        # Assert
        Assert-CodexDocsEstateUnchangedDeny -Decision $decision
    }

    It 'reads the docs profile once beneath the resolved root (codex)' {
        # Act
        $decision = Get-CodexDocsEstateDecision -MappedInput (ConvertTo-CodexDocsMappedInput -Command 'git -C /synthetic-worktrees/docs-run add -- docs/a.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Should -Invoke Get-WorktreeResolutionGitFileText -Times 1 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('/synthetic-worktrees/docs-run/docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
        Should -Invoke Get-WorktreeResolutionGitFileText -Times 1 -Exactly -ParameterFilter { ($Path -replace '\\', '/').EndsWith('docs/documentation-estate/docs-profile.json', [System.StringComparison]::Ordinal) }
    }

    It 'keeps the no-profile deny text identical to the text with the docs leg withheld (codex)' {
        # Arrange
        Set-CodexDocsEstateFixture -ProfileText $null
        $mapped = ConvertTo-CodexDocsMappedInput -Command 'git commit -F artifacts/commit-message.txt'

        # Act
        $actual = Get-CodexDocsEstateDecision -MappedInput $mapped | ConvertTo-Json -Compress -Depth 5
        Mock Get-OrchestrationDocsEstateContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = '' } }
        $withheld = Get-CodexDocsEstateDecision -MappedInput $mapped | ConvertTo-Json -Compress -Depth 5

        # Assert
        $actual | Should -BeExactly $withheld
    }

    Context 'Codex copy of hook-docs-estate-context.ps1 (issue #1169)' {
        It 'parses a valid profile and rejects <Case> (codex)' -ForEach @(
            @{ Case = 'malformed JSON'; Text = '{"artifact_kind":' }
            @{ Case = 'another artifact kind'; Text = '{"artifact_kind":"x","documentation_roots":[{"path":"docs"}],"artifact_paths":{}}' }
            @{ Case = 'empty documentation roots'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[],"artifact_paths":{}}' }
            @{ Case = 'a root that is not an object'; Text = '{"artifact_kind":"docs-profile","documentation_roots":["docs"],"artifact_paths":{}}' }
            @{ Case = 'a rooted root path'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"/docs"}],"artifact_paths":{}}' }
            @{ Case = 'artifact_paths that is not an object'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs"}],"artifact_paths":[]}' }
            @{ Case = 'a non-string artifact path'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs"}],"artifact_paths":{"a":1}}' }
        ) {
            # Act
            $valid = ConvertFrom-DocsEstateProfileText -Text $script:ValidProfile
            $invalid = ConvertFrom-DocsEstateProfileText -Text $Text

            # Assert
            $valid | Should -Not -BeNullOrEmpty
            $null -eq $invalid | Should -BeTrue
        }

        It 'classifies <Path> as <Expected> in the docs path set (codex)' -ForEach @(
            @{ Path = 'docs/a.md'; Expected = $true }
            @{ Path = 'docs/documentation-estate/x.json'; Expected = $true }
            @{ Path = '.github/workflows/_docs-quality.yml'; Expected = $true }
            @{ Path = 'guide/start.md'; Expected = $true }
            @{ Path = 'guide/start.txt'; Expected = $false }
            @{ Path = 'src/a.ps1'; Expected = $false }
            @{ Path = 'docs/../src/a.ps1'; Expected = $false }
            @{ Path = ''; Expected = $false }
        ) {
            # Arrange
            $profileDocument = ConvertFrom-DocsEstateProfileText -Text $script:ValidProfile

            # Act
            $result = Test-DocsEstatePath -RelativePath $Path -Profile $profileDocument -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

            # Assert
            $result | Should -Be $Expected
        }

        It 'reads the branch and base labels and rejects <Case> (codex)' -ForEach @(
            @{ Case = 'a missing base line'; Prompt = 'branch: docs/a' }
            @{ Case = 'a duplicated branch line'; Prompt = "branch: docs/a`nbranch: docs/b`nbase: main" }
            @{ Case = 'a value with ..'; Prompt = "branch: docs/a..b`nbase: main" }
        ) {
            # Act
            $labels = Get-DocsEstateDelegationLabel -PromptText "branch: docs/a`nbase: epic/x-integration"
            $rejected = Get-DocsEstateDelegationLabel -PromptText $Prompt

            # Assert
            $labels.Branch | Should -BeExactly 'docs/a'
            $labels.Base | Should -BeExactly 'epic/x-integration'
            $null -eq $rejected | Should -BeTrue
        }
    }
}
