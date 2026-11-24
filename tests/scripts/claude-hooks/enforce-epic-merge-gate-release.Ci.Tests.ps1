#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for steps 13 to 17 and the cross-step rows of Get-EpicMergeGateReleaseDecision (issue #1234).

.DESCRIPTION
    Runs every row once per hook tree (.claude/hooks and .codex/hooks), dot-sourcing the leg and its
    call-time dependencies from that tree so both byte-identical copies are measured. The allowance
    reader and the container probe are injected scriptblocks that call test-local functions, and
    Invoke-DocsOnlyGhExe is mocked with parameter filters on GhArgs. No row starts a process, runs
    git or gh, or writes a file; the root is a synthetic forward-slash path.
#>

BeforeDiscovery {
    $script:ReleaseCiTrees = @(@{ Tree = '.claude/hooks' }, @{ Tree = '.codex/hooks' })
}

Describe 'release merge leg steps 13 to 17 in <Tree> (#1234)' -ForEach $script:ReleaseCiTrees {
    BeforeAll {
        $hookRoot = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path $Tree
        . (Join-Path $hookRoot 'hook-dependency-guard.ps1')
        . (Join-Path $hookRoot 'hook-command-invocation.ps1')
        . (Join-Path $hookRoot 'hook-docs-only-diff.ps1')
        . (Join-Path $hookRoot 'enforce-epic-merge-gate-child-ci.ps1')
        . (Join-Path $hookRoot 'enforce-epic-merge-gate-release.ps1')

        $script:ReleaseCiHead = '0123456789abcdef0123456789abcdef01234567'
        $script:ReleaseCiRoot = '/synthetic-worktrees/release-1234'

        function Get-ReleaseCiConfigText {
            # Test-local allowance reader seam; each row mocks it.
            param([string] $Root)
            Write-Verbose "allowance read for $Root"
            return $null
        }

        function Get-ReleaseCiPullRequestText {
            # Return gh pr view JSON for pull request 5 with top-level overrides.
            param([hashtable] $Override = @{})
            $document = [ordered]@{
                headRefName       = 'release/v1.2.3'
                baseRefName       = 'main'
                headRefOid        = $script:ReleaseCiHead
                state             = 'OPEN'
                isCrossRepository = $false
                changedFiles      = 2
                files             = @(@{ path = 'package.json'; changeType = 'MODIFIED' }, @{ path = 'CHANGELOG.md'; changeType = 'MODIFIED' })
            }
            foreach ($key in $Override.Keys) { $document[$key] = $Override[$key] }
            return ($document | ConvertTo-Json -Depth 6 -Compress)
        }

        function Get-ReleaseCiRun {
            # Return one run-list entry for the head with overrides.
            param([hashtable] $Override = @{})
            $run = [ordered]@{ databaseId = 11; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $script:ReleaseCiHead; workflowName = 'CI'; createdAt = '2026-11-20T10:00:00Z' }
            foreach ($key in $Override.Keys) { $run[$key] = $Override[$key] }
            return $run
        }

        function Set-ReleaseCiSeam {
            # Mock the allowance reader, the pr view call, and the run list call for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([string] $PullRequest = (Get-ReleaseCiPullRequestText), [object[]] $Run = @(Get-ReleaseCiRun), [int] $RunExit = 0)
            $allowanceText = '{"schema_version":1,"allowances":[{"id":"release","branch_patterns":["release/*"],"allowed_paths":["package.json","CHANGELOG.md"]}]}'
            $prText = $PullRequest
            $runText = ConvertTo-Json -InputObject @($Run) -Depth 5 -Compress
            $runCode = $RunExit
            Mock Get-ReleaseCiConfigText -MockWith ({ $allowanceText }.GetNewClosure())
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $prText } }.GetNewClosure())
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith ({ [pscustomobject]@{ ExitCode = $runCode; Output = $runText } }.GetNewClosure())
        }

        function Invoke-ReleaseCiLeg {
            # Call the leg with the injected seams.
            param([string] $Command = "gh pr merge 5 --merge --match-head-commit $($script:ReleaseCiHead)", [bool] $NoRecordingTarget = $true)
            return Get-EpicMergeGateReleaseDecision -CommandText $Command -PrNumber 5 -WorktreeRoot $script:ReleaseCiRoot -NoRecordingTarget $NoRecordingTarget -ConfigReader { param([string] $Root) Get-ReleaseCiConfigText -Root $Root } -ContainerProbe { $false }
        }

        function Get-ReleaseCiCode {
            # Return the RELEASE_MERGE_* code of a suffix, or ''.
            param([AllowEmptyString()][string] $Suffix)
            if ($Suffix -cmatch '^ \(release merge not applied: (RELEASE_MERGE_[A-Z_]+): ') { return $Matches[1] }
            return ''
        }
    }

    BeforeEach {
        Mock Get-ReleaseCiConfigText { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
    }

    AfterAll {
        foreach ($name in 'Get-ReleaseCiConfigText', 'Get-ReleaseCiPullRequestText', 'Get-ReleaseCiRun', 'Set-ReleaseCiSeam', 'Invoke-ReleaseCiLeg', 'Get-ReleaseCiCode') {
            Remove-Item -LiteralPath "Function:\$name" -ErrorAction SilentlyContinue
        }
    }

    Context 'step 17 allow rows (AC-01)' {
        It 'allows the release merge with <Method> (#1234)' -ForEach @(
            @{ Method = '--merge' }
            @{ Method = '--squash' }
            @{ Method = '--rebase' }
        ) {
            # Arrange
            Set-ReleaseCiSeam

            # Act
            $result = Invoke-ReleaseCiLeg -Command "gh pr merge 5 $Method --match-head-commit $($script:ReleaseCiHead)"

            # Assert
            $result.Allowed | Should -BeTrue -Because "suffix: $($result.Suffix)"
            $result.Suffix | Should -BeExactly ''
        }

        It 'allows a 64-character head commit (#1234)' {
            # Arrange
            $longHead = '0123456789abcdef' * 4
            Set-ReleaseCiSeam -PullRequest (Get-ReleaseCiPullRequestText -Override @{ headRefOid = $longHead }) -Run @(Get-ReleaseCiRun -Override @{ headSha = $longHead })

            # Act
            $result = Invoke-ReleaseCiLeg -Command "gh pr merge 5 --merge --match-head-commit $longHead"

            # Assert
            $result.Allowed | Should -BeTrue -Because "suffix: $($result.Suffix)"
        }
    }

    Context 'steps 13 and 14 (AC-15)' {
        It 'reports RELEASE_MERGE_CI_UNREADABLE for a gh run list exit 1 (#1234)' {
            # Arrange
            Set-ReleaseCiSeam -RunExit 1

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            Get-ReleaseCiCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_UNREADABLE'
        }

        It 'reports RELEASE_MERGE_CI_MISSING for a run list holding only a Release workflow run (#1234)' {
            # Arrange
            Set-ReleaseCiSeam -Run @(Get-ReleaseCiRun -Override @{ workflowName = 'Release' })

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            Get-ReleaseCiCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_MISSING'
        }

        It 'reads the run list with --commit equal to the live headRefOid (#1234)' {
            # Arrange
            Set-ReleaseCiSeam

            # Act
            $null = Invoke-ReleaseCiLeg

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter {
                $index = [array]::IndexOf([string[]]$GhArgs, '--commit')
                $GhArgs[0] -ceq 'run' -and $index -ge 0 -and $GhArgs[$index + 1] -ceq $script:ReleaseCiHead
            }
        }
    }

    Context 'steps 15 and 16 (AC-16, AC-17)' {
        It 'reports RELEASE_MERGE_CI_EVENT_NOT_ALLOWED for a newest <Event> run over an older pull_request success (#1234)' -ForEach @(
            @{ Event = 'push' }
            @{ Event = 'workflow_dispatch' }
        ) {
            # Arrange
            $runs = @(
                Get-ReleaseCiRun -Override @{ databaseId = 10; createdAt = '2026-11-20T09:00:00Z' }
                Get-ReleaseCiRun -Override @{ databaseId = 12; event = $Event; createdAt = '2026-11-20T11:00:00Z' }
            )
            Set-ReleaseCiSeam -Run $runs

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            Get-ReleaseCiCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_EVENT_NOT_ALLOWED'
        }

        It 'reports RELEASE_MERGE_CI_NOT_GREEN for a newest pull_request run <Name> (#1234)' -ForEach @(
            @{ Name = 'in progress'; Override = @{ status = 'in_progress'; conclusion = '' } }
            @{ Name = 'completed with failure'; Override = @{ status = 'completed'; conclusion = 'failure' } }
        ) {
            # Arrange
            Set-ReleaseCiSeam -Run @(Get-ReleaseCiRun -Override $Override)

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            Get-ReleaseCiCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_NOT_GREEN'
        }
    }

    Context 'cross-step rows (AC-18, AC-19, AC-20)' {
        It 'reports only the earlier code when two steps fail (#1234)' {
            # Arrange
            Set-ReleaseCiSeam -PullRequest (Get-ReleaseCiPullRequestText -Override @{ isCrossRepository = $true })

            # Act
            $result = Invoke-ReleaseCiLeg -Command 'gh pr merge 5 --merge'

            # Assert
            $result.Allowed | Should -BeFalse
            Get-ReleaseCiCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_MATCH_HEAD_MISSING'
            ([regex]::Matches($result.Suffix, 'release merge not applied')).Count | Should -Be 1
        }

        It 'makes no process call for a step <Step> failure (#1234)' -ForEach @(
            @{ Step = 3; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567'; NoRecordingTarget = $false }
            @{ Step = 4; Command = 'gh pr merge 5 --merge --auto --match-head-commit 0123456789abcdef0123456789abcdef01234567'; NoRecordingTarget = $true }
            @{ Step = 5; Command = 'gh pr merge 5 --merge'; NoRecordingTarget = $true }
        ) {
            # Arrange
            Set-ReleaseCiSeam

            # Act
            $result = Invoke-ReleaseCiLeg -Command $Command -NoRecordingTarget $NoRecordingTarget

            # Assert
            $result.Allowed | Should -BeFalse
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'makes one pr view call and no run list call for a step <Step> failure (#1234)' -ForEach @(
            @{ Step = 7; Override = @{ state = 'MERGED' } }
            @{ Step = 9; Override = @{ headRefOid = 'fedcba9876543210fedcba9876543210fedcba98' } }
            @{ Step = 12; Override = @{ headRefName = 'feature/x' } }
        ) {
            # Arrange
            Set-ReleaseCiSeam -PullRequest (Get-ReleaseCiPullRequestText -Override $Override)

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            $result.Allowed | Should -BeFalse
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'pr' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }

        It 'makes one pr view call and one run list call for the <Name> row (#1234)' -ForEach @(
            @{ Name = 'step 14'; Run = @(@{ databaseId = 11; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = '0123456789abcdef0123456789abcdef01234567'; workflowName = 'Release'; createdAt = '2026-11-20T10:00:00Z' }); Allowed = $false }
            @{ Name = 'step 16'; Run = @(@{ databaseId = 11; event = 'pull_request'; status = 'completed'; conclusion = 'failure'; headSha = '0123456789abcdef0123456789abcdef01234567'; workflowName = 'CI'; createdAt = '2026-11-20T10:00:00Z' }); Allowed = $false }
            @{ Name = 'allow'; Run = @(@{ databaseId = 11; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = '0123456789abcdef0123456789abcdef01234567'; workflowName = 'CI'; createdAt = '2026-11-20T10:00:00Z' }); Allowed = $true }
        ) {
            # Arrange
            Set-ReleaseCiSeam -Run $Run

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            $result.Allowed | Should -Be $Allowed
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'pr' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }

        It 'catches an unexpected error with an empty suffix and a Write-Debug record (#1234)' {
            # Arrange
            Set-ReleaseCiSeam
            Mock Select-EpicMergeGateChildCiRun { throw 'selector failed' }
            Mock Write-Debug { }

            # Act
            $result = Invoke-ReleaseCiLeg

            # Assert
            $result.Allowed | Should -BeFalse
            $result.Suffix | Should -BeExactly ''
            Should -Invoke Write-Debug -Times 1 -Exactly -ParameterFilter { $Message -like '*EPIC_MERGE_GATE_RELEASE_LEG_ERROR*' }
        }
    }
}
