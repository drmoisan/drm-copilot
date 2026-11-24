#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Release delegation leg of the model-routing receipt gate (issue #1231, Leg 2).

.DESCRIPTION
    Unit rows call Get-ModelRoutingReleaseDecision directly with the synthetic root
    /synthetic-worktrees/release. Decision rows drive Invoke-ModelRoutingReceiptDecision for
    checkpoint-free Agent(pr-author) delegations: the resolution seam
    Resolve-ModelRoutingWorktreeTarget returns the synthetic root, Get-ModelRoutingCheckpoint
    returns $null, Get-ModelRoutingDocsEstateFileText returns no docs profile unless a row
    supplies one, the allowance file text and the container probe are mocked, and
    Invoke-DocsOnlyGitExe is mocked by its arguments. No row creates a file, starts a process,
    reads a clock, or sets an environment variable.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt-release.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Get-ModelRoutingCheckpoint { $null }

    $script:Root = '/synthetic-worktrees/release'
    $script:BaseCommit = '3333333333333333333333333333333333333333'
    $script:Head = '2222222222222222222222222222222222222222'
    $script:Nul = [string][char]0
    $script:ValidConfig = '{"schema_version":1,"allowances":[{"id":"npm","branch_patterns":["release/*"],"allowed_paths":["package.json","package-lock.json"]}]}'
    $script:Blocked = "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."
    $script:Prefix = ' Release delegation leg not applied: '
    $script:Prompt = "Open the release pull request.`nbranch: release/v1.2.3`nbase: main`nCanonical issue number for this feature is 12.`nAuthor-asserted autoclose issues: #12"

    function Set-ReleaseRoutingFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()][object] $Config = $script:ValidConfig,
            [int] $BaseExit = 0,
            [int] $HeadExit = 0,
            [int] $DiffExit = 0,
            [string] $DiffOutput = "package.json$([char]0)package-lock.json$([char]0)",
            [AllowNull()][object] $ProfileText = $null
        )
        $configText = $Config
        $profileValue = $ProfileText
        $target = [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:Root; ReasonCode = $null; Detail = 'synthetic release root' }
        $baseResult = [pscustomobject]@{ ExitCode = $BaseExit; Output = $script:BaseCommit }
        $headResult = [pscustomobject]@{ ExitCode = $HeadExit; Output = $script:Head }
        $diffResult = [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput }
        Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
        Mock Get-ModelRoutingDocsEstateFileText -MockWith ({ param([string] $Path) if ($Path.EndsWith('docs-profile.json')) { $profileValue } else { $null } }.GetNewClosure())
        Mock Get-OrchestrationGateReleaseAllowanceConfigText { $configText }.GetNewClosure()
        Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $false }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 128; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1] -ceq 'HEAD^{commit}' } -MockWith ({ $headResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' } -MockWith ({ $diffResult }.GetNewClosure())
    }

    function Get-ReleaseRoutingResult {
        param([string] $Prompt = $script:Prompt)
        return (Get-ModelRoutingReleaseDecision -PromptText $Prompt -WorktreeRoot $script:Root)
    }

    function Get-ReleaseRoutingDecision {
        param([string] $Prompt = $script:Prompt)
        $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'pr-author'; prompt = $Prompt } } | ConvertTo-Json -Depth 5 -Compress
        return (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload)
    }
}

Describe 'model-routing gate release delegation leg (#1231)' {
    BeforeEach {
        Set-ReleaseRoutingFixture
    }

    It 'baseline mock interception probe (#1231)' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'unit rows' {
        It 'allows a delegation whose diff is listed by the matching allowance (#1231)' {
            # Act
            $result = Get-ReleaseRoutingResult

            # Assert
            $result.Allowed | Should -BeTrue
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' -and ($GitArgs -join ' ') -ceq "diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative $($script:BaseCommit)...HEAD" }
        }

        It 'declines with an empty suffix and no git call when the allowance file is absent (#1231)' {
            # Arrange
            Set-ReleaseRoutingFixture -Config $null

            # Act
            $result = Get-ReleaseRoutingResult
            $blank = Get-ModelRoutingReleaseDecision -PromptText $script:Prompt -WorktreeRoot ''

            # Assert
            foreach ($entry in @($result, $blank)) {
                $entry.Allowed | Should -BeFalse
                $entry.DenySuffix | Should -BeExactly ''
            }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'reports RELEASE_DELEGATION_CONFIG_INVALID for an invalid file or a read failure (#1231)' {
            # Act
            Set-ReleaseRoutingFixture -Config '{"schema_version":1}'
            $invalid = Get-ReleaseRoutingResult
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { throw 'synthetic read failure' }
            $thrown = Get-ReleaseRoutingResult

            # Assert
            $invalid.DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_DELEGATION_CONFIG_INVALID: missing top-level key 'allowances'"
            $thrown.DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_DELEGATION_CONFIG_INVALID: the file could not be read"
        }

        It 'reports RELEASE_DELEGATION_LABEL_INVALID for <Label> (#1231)' -ForEach @(
            @{ Label = 'a missing base line'; Prompt = "branch: release/v1.2.3`nCanonical issue number for this feature is 12." }
            @{ Label = 'two branch lines'; Prompt = "branch: release/v1.2.3`nbranch: release/v1.2.4`nbase: main" }
        ) {
            # Act
            $result = Get-ReleaseRoutingResult -Prompt $Prompt

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeLike "$($script:Prefix)RELEASE_DELEGATION_LABEL_INVALID: *"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'reports RELEASE_DELEGATION_BRANCH_NOT_MATCHED with no git call (#1231)' {
            # Act
            $result = Get-ReleaseRoutingResult -Prompt "branch: feature/x`nbase: main"

            # Assert
            $result.DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_DELEGATION_BRANCH_NOT_MATCHED: branch 'feature/x' matches no allowance."
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'reports RELEASE_DELEGATION_DIFF_UNREADABLE for <Label> (#1231)' -ForEach @(
            @{ Label = 'an unresolved base'; BaseExit = 1; HeadExit = 0; DiffExit = 0; DiffOutput = "package.json$([char]0)" }
            @{ Label = 'an unresolved HEAD'; BaseExit = 0; HeadExit = 1; DiffExit = 0; DiffOutput = "package.json$([char]0)" }
            @{ Label = 'a failed diff'; BaseExit = 0; HeadExit = 0; DiffExit = 1; DiffOutput = '' }
            @{ Label = 'unterminated output'; BaseExit = 0; HeadExit = 0; DiffExit = 0; DiffOutput = 'package.json' }
        ) {
            # Arrange
            Set-ReleaseRoutingFixture -BaseExit $BaseExit -HeadExit $HeadExit -DiffExit $DiffExit -DiffOutput $DiffOutput

            # Act
            $result = Get-ReleaseRoutingResult

            # Assert
            $result.DenySuffix | Should -BeLike "$($script:Prefix)RELEASE_DELEGATION_DIFF_UNREADABLE: *"
        }

        It 'reports RELEASE_DELEGATION_DIFF_EMPTY for an empty diff (#1231)' {
            # Arrange
            Set-ReleaseRoutingFixture -DiffOutput ''

            # Act / Assert
            (Get-ReleaseRoutingResult).DenySuffix | Should -BeLike "$($script:Prefix)RELEASE_DELEGATION_DIFF_EMPTY: *"
        }

        It 'reports RELEASE_DELEGATION_PATH_NOT_ALLOWED for an unlisted path (#1231)' {
            # Arrange
            Set-ReleaseRoutingFixture -DiffOutput "package.json$($script:Nul)src/app.ps1$($script:Nul)"

            # Act / Assert
            (Get-ReleaseRoutingResult).DenySuffix | Should -BeExactly "$($script:Prefix)RELEASE_DELEGATION_PATH_NOT_ALLOWED: 'src/app.ps1' is not listed in allowed_paths of allowance 'npm'."
        }

        It 'declines with an empty suffix and a Write-Debug record when a seam throws (#1231)' {
            # Arrange
            Mock Write-Debug { }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $true } -MockWith { throw 'synthetic git failure' }

            # Act
            $result = Get-ReleaseRoutingResult

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Write-Debug -Times 1 -ParameterFilter { $Message -like 'MODEL_ROUTING_RELEASE_LEG_ERROR:*' }
        }
    }

    Context 'decision rows through Invoke-ModelRoutingReceiptDecision' {
        It 'allows a checkpoint-free release delegation (AC-05) (#1231)' {
            # Act
            $decision = Get-ReleaseRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }

        It 'keeps MODEL_ROUTING_RECEIPT_BLOCKED and appends the <Code> suffix (AC-06) (#1231)' -ForEach @(
            @{ Code = 'RELEASE_DELEGATION_CONFIG_INVALID'; Config = '{"schema_version":1}'; Prompt = $null; Diff = "package.json$([char]0)"; BaseExit = 0 }
            @{ Code = 'RELEASE_DELEGATION_LABEL_INVALID'; Config = $null; Prompt = 'branch: release/v1.2.3'; Diff = "package.json$([char]0)"; BaseExit = 0 }
            @{ Code = 'RELEASE_DELEGATION_BRANCH_NOT_MATCHED'; Config = $null; Prompt = "branch: feature/x`nbase: main"; Diff = "package.json$([char]0)"; BaseExit = 0 }
            @{ Code = 'RELEASE_DELEGATION_DIFF_UNREADABLE'; Config = $null; Prompt = $null; Diff = "package.json$([char]0)"; BaseExit = 1 }
            @{ Code = 'RELEASE_DELEGATION_DIFF_EMPTY'; Config = $null; Prompt = $null; Diff = ''; BaseExit = 0 }
            @{ Code = 'RELEASE_DELEGATION_PATH_NOT_ALLOWED'; Config = $null; Prompt = $null; Diff = "src/app.ps1$([char]0)"; BaseExit = 0 }
        ) {
            # Arrange
            $configText = if ($null -ne $Config) { $Config } else { $script:ValidConfig }
            $promptText = if ($null -ne $Prompt) { $Prompt } else { $script:Prompt }
            Set-ReleaseRoutingFixture -Config $configText -DiffOutput $Diff -BaseExit $BaseExit

            # Act
            $decision = Get-ReleaseRoutingDecision -Prompt $promptText
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.StartsWith("$($script:Blocked)$($script:Prefix)$($Code): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' carries $Code after the unchanged text"
        }

        It 'appends the release suffix after a non-empty docs-estate suffix (AC-06) (#1231)' {
            # Arrange: an invalid docs profile gives a docs-estate suffix; an unlisted path gives a release suffix.
            Set-ReleaseRoutingFixture -ProfileText 'not a profile' -DiffOutput "src/app.ps1$($script:Nul)"

            # Act
            $reason = [string](Get-ReleaseRoutingDecision).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason.StartsWith("$($script:Blocked) Docs-estate delegation leg not applied: DOCS_DELEGATION_PROFILE_INVALID: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "reason: $reason"
            $reason.EndsWith("$($script:Prefix)RELEASE_DELEGATION_PATH_NOT_ALLOWED: 'src/app.ps1' is not listed in allowed_paths of allowance 'npm'.", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "reason: $reason"
            $reason.IndexOf('Docs-estate delegation leg not applied', [System.StringComparison]::Ordinal) | Should -BeLessThan $reason.IndexOf('Release delegation leg not applied', [System.StringComparison]::Ordinal)
        }

        It 'keeps the exact pre-change deny text with no git call when the allowance file is absent (AC-10) (#1231)' {
            # Arrange
            Set-ReleaseRoutingFixture -Config $null

            # Act
            $decision = Get-ReleaseRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }
}
