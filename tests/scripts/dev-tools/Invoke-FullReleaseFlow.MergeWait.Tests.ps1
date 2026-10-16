Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Merge-confirmation wait tests for scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (issue #952).
.DESCRIPTION
    Under a merge queue, gh pr merge exits 0 after it enqueues the pull request, so the release
    flow waits for a confirmed merge before checkout, pull, and tag push. These cases drive
    Wait-ForPullRequestMerged (defined in scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1,
    dot-sourced by the release script) and the guarded flow through the Invoke-GhExe,
    Invoke-GitExe, Invoke-ChildPowerShellScript, Invoke-Sleep, and Write-StderrLine seams. No
    live gh or git, no real wait, no child process, and no temporary file is used.
#>

Describe "Invoke-FullReleaseFlow.ps1 - merge wait (issue #952)" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
        . $script:scriptPath -ConfirmToken 'no'

        $script:MergedSnapshot = '{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","isInMergeQueue":false,"mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"autoMergeRequest":null}'
        $script:PendingSnapshot = '{"state":"OPEN","mergedAt":null,"isInMergeQueue":true,"mergeCommit":null,"autoMergeRequest":{"enabledAt":"2026-10-16T12:00:00Z"}}'
        $script:NotQueuedSnapshot = '{"state":"OPEN","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}'
        $script:ClosedSnapshot = '{"state":"CLOSED","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}'

        function script:Initialize-SnapshotGhMock {
            <#
            .SYNOPSIS
                Mock Invoke-GhExe: the release-flow PR calls succeed, and each '^api graphql '
                call returns the next scripted snapshot (the last one repeats).
            #>
            param(
                [Parameter(Mandatory = $true)][string[]]$Snapshots,
                [int]$ApiExitCode = 0
            )

            $script:snapshotSequence = $Snapshots
            $script:apiExitCode = $ApiExitCode
            $script:apiCallCount = 0
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)

                $script:capturedGhArgsList.Add($GhArgs)
                $joined = $GhArgs -join " "
                if ($joined -eq 'pr view release/full-20260703171500 --json number --jq .number') {
                    return @{ Output = @('291'); ExitCode = 0 }
                }
                if ($joined -eq 'pr checks 291 --json bucket') {
                    return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
                }
                if ($joined -eq 'pr merge 291 --merge') {
                    return @{ Output = @('queued'); ExitCode = 0 }
                }
                if ($joined -match '^api graphql ') {
                    $index = [Math]::Min($script:apiCallCount, $script:snapshotSequence.Count - 1)
                    $script:apiCallCount++
                    return @{ Output = @($script:snapshotSequence[$index]); ExitCode = $script:apiExitCode }
                }
                return @{ Output = @(); ExitCode = 0 }
            }
        }

        function script:Initialize-SuccessfulGitFlowMock {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)

                $script:capturedGitArgsList.Add($GitArgs)
                $joined = $GitArgs -join " "
                if ($joined -eq 'branch --show-current') {
                    $script:branchReadCount++
                    if ($script:branchReadCount -eq 1) {
                        return @{ Output = @('main'); ExitCode = 0 }
                    }
                    return @{ Output = @('release/full-20260703171500'); ExitCode = 0 }
                }
                if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') {
                    return @{ Output = @('abc123'); ExitCode = 0 }
                }
                return @{ Output = @(); ExitCode = 0 }
            }
        }

        function script:Initialize-SuccessfulChildScriptMock {
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param(
                    [string]$ScriptPath,
                    [string[]]$ScriptArguments
                )

                $script:capturedChildCalls.Add(@{
                        ScriptPath = $ScriptPath
                        Arguments  = $ScriptArguments
                    })
                return 0
            }
        }
    }

    BeforeEach {
        $script:capturedMessages = [System.Collections.Generic.List[string]]::new()
        $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedGhArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedChildCalls = [System.Collections.Generic.List[object]]::new()
        $script:branchReadCount = 0
        Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
        Mock -CommandName Write-StderrLine -MockWith {
            param([string]$Message)
            $script:capturedMessages.Add($Message)
        }
    }

    Context "Wait-ForPullRequestMerged" {
        It "W-1 returns 0 after a pending snapshot followed by a merged snapshot, sleeping once for the poll interval" {
            Initialize-SnapshotGhMock -Snapshots @($script:PendingSnapshot, $script:MergedSnapshot)

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-Sleep -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 30 }
        }

        It "W-2 returns 0 on the first poll with no sleep when the pull request is already merged" {
            Initialize-SnapshotGhMock -Snapshots @($script:MergedSnapshot)

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "W-3 returns 1 after polling floor(timeout / interval) + 1 times when every snapshot is pending" {
            Initialize-SnapshotGhMock -Snapshots @($script:PendingSnapshot)

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 1
            Should -Invoke -CommandName Invoke-GhExe -Times 4 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 3 -Exactly
            ($script:capturedMessages -join "`n") | Should -Match 'did not merge within 90 seconds'
        }

        It "W-4 returns 1 with a not-queued message when the pull request is open and neither merged nor queued" {
            Initialize-SnapshotGhMock -Snapshots @($script:NotQueuedSnapshot)

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 1
            ($script:capturedMessages -join "`n") | Should -Match 'neither merged nor queued'
        }

        It "W-5 returns 1 with a closed message when the pull request is closed" {
            Initialize-SnapshotGhMock -Snapshots @($script:ClosedSnapshot)

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 1
            ($script:capturedMessages -join "`n") | Should -Match 'was closed without merging'
        }

        It "W-6 returns 1 when the merge-state read fails" {
            Initialize-SnapshotGhMock -Snapshots @('gh: error') -ApiExitCode 1

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 1
            ($script:capturedMessages -join "`n") | Should -Match 'Failed to read merge state for PR #291'
        }

        It "W-7 returns 1 with the parser message when the snapshot is malformed" {
            Initialize-SnapshotGhMock -Snapshots @('not json')

            $result = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $result | Should -Be 1
            ($script:capturedMessages -join "`n") | Should -Match 'Invoke-MergeConfirmationParser:'
        }

        It "W-8 reads merge state with the exact gh api graphql argument list" {
            Initialize-SnapshotGhMock -Snapshots @($script:MergedSnapshot)

            $null = Wait-ForPullRequestMerged -PrNumber '291' -PollIntervalSeconds 30 -TimeoutSeconds 90

            $script:capturedGhArgsList.Count | Should -Be 1
            ($script:capturedGhArgsList[0] -join ' ') | Should -BeExactly 'api graphql -f query=query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}} -F owner={owner} -F name={repo} -F number=291 --jq .data.repository.pullRequest'
        }
    }

    Context "guarded flow with the merge wait" {
        It "W-9 flow: merges with no --delete-branch, waits for the merge, then checks out, pulls, and pushes the tag" {
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Initialize-SnapshotGhMock -Snapshots @($script:PendingSnapshot, $script:MergedSnapshot)

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            $ghFlat = @($script:capturedGhArgsList | ForEach-Object { $_ -join " " })
            $ghFlat | Should -Contain 'pr merge 291 --merge'
            ($ghFlat -join "`n") | Should -Not -Match '--delete-branch'
            $mergeIndex = [Array]::IndexOf($ghFlat, 'pr merge 291 --merge')
            $firstApiIndex = @(0..($ghFlat.Count - 1) | Where-Object { $ghFlat[$_] -match '^api graphql ' })[0]
            $firstApiIndex | Should -BeGreaterThan $mergeIndex -Because 'the merge state is read only after the merge call'
            $gitFlat = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            $gitFlat | Should -Contain 'checkout main'
            $gitFlat | Should -Contain 'pull origin main'
            @($script:capturedChildCalls).Count | Should -Be 2
        }

        It "W-10 flow: stops before checkout, pull, and tag push when the merge wait times out" {
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Initialize-SnapshotGhMock -Snapshots @($script:PendingSnapshot)

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $gitText = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n"
            $gitText | Should -Not -Match 'checkout main'
            $gitText | Should -Not -Match 'pull origin main'
            @($script:capturedChildCalls).Count | Should -Be 1
        }

        It "W-11 flow: stops before checkout, pull, and tag push when the pull request is not queued" {
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Initialize-SnapshotGhMock -Snapshots @($script:NotQueuedSnapshot)

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $gitText = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n"
            $gitText | Should -Not -Match 'checkout main'
            $gitText | Should -Not -Match 'pull origin main'
            @($script:capturedChildCalls).Count | Should -Be 1
        }

        It "W-12 flow: stops before checkout, pull, and tag push when the pull request is closed" {
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Initialize-SnapshotGhMock -Snapshots @($script:ClosedSnapshot)

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $gitText = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n"
            $gitText | Should -Not -Match 'checkout main'
            $gitText | Should -Not -Match 'pull origin main'
            @($script:capturedChildCalls).Count | Should -Be 1
        }
    }
}
