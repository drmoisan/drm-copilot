#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for steps 1 to 12 of Get-EpicMergeGateReleaseDecision (issue #1234).

.DESCRIPTION
    Runs every row once per hook tree (.claude/hooks and .codex/hooks), dot-sourcing the leg and its
    call-time dependencies from that tree so both byte-identical copies are measured. The allowance
    reader and the container probe are injected scriptblocks that call test-local functions, and
    Invoke-DocsOnlyGhExe is mocked with parameter filters on GhArgs. No row starts a process, runs
    git or gh, or writes a file; the root is a synthetic forward-slash path.
#>

BeforeDiscovery {
    $script:ReleaseLegTrees = @(@{ Tree = '.claude/hooks' }, @{ Tree = '.codex/hooks' })
}

Describe 'release merge leg steps 1 to 12 in <Tree> (#1234)' -ForEach $script:ReleaseLegTrees {
    BeforeAll {
        $hookRoot = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path $Tree
        . (Join-Path $hookRoot 'hook-dependency-guard.ps1')
        . (Join-Path $hookRoot 'hook-command-invocation.ps1')
        . (Join-Path $hookRoot 'hook-docs-only-diff.ps1')
        . (Join-Path $hookRoot 'enforce-epic-merge-gate-child-ci.ps1')
        . (Join-Path $hookRoot 'enforce-epic-merge-gate-release.ps1')

        $script:ReleaseHead = '0123456789abcdef0123456789abcdef01234567'
        $script:ReleaseOtherHead = 'fedcba9876543210fedcba9876543210fedcba98'
        $script:ReleaseRoot = '/synthetic-worktrees/release-1234'
        $script:ReleaseFields = 'headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files'
        $script:ReleaseCommand = "gh pr merge 5 --merge --match-head-commit $($script:ReleaseHead)"

        function Get-ReleaseLegConfigText {
            # Test-local allowance reader seam; each row mocks it.
            param([string] $Root)
            Write-Verbose "allowance read for $Root"
            return $null
        }

        function Test-ReleaseLegContainer {
            # Test-local container probe seam; each row mocks it.
            param([string] $Root, [string] $RelativePath)
            Write-Verbose "container probe for $Root and $RelativePath"
            return $false
        }

        function Get-ReleaseLegAllowanceText {
            # Return allowance file text with one allowance per entry of Allowance.
            param([object[]] $Allowance = @(@{ id = 'release'; branch_patterns = @('release/*'); allowed_paths = @('package.json', 'CHANGELOG.md') }))
            return ([ordered]@{ schema_version = 1; allowances = @($Allowance) } | ConvertTo-Json -Depth 6 -Compress)
        }

        function Get-ReleaseLegPullRequestText {
            # Return gh pr view JSON for pull request 5 with top-level overrides.
            param([hashtable] $Override = @{})
            $document = [ordered]@{
                headRefName       = 'release/v1.2.3'
                baseRefName       = 'main'
                headRefOid        = $script:ReleaseHead
                state             = 'OPEN'
                isCrossRepository = $false
                changedFiles      = 2
                files             = @(@{ path = 'package.json'; changeType = 'MODIFIED' }, @{ path = 'CHANGELOG.md'; changeType = 'MODIFIED' })
            }
            foreach ($key in $Override.Keys) { $document[$key] = $Override[$key] }
            return ($document | ConvertTo-Json -Depth 6 -Compress)
        }

        function Set-ReleaseLegSeam {
            # Mock the allowance reader, the pr view call, and the run list call for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([AllowNull()] $Allowance = (Get-ReleaseLegAllowanceText), [string] $PullRequest = (Get-ReleaseLegPullRequestText), [int] $PrExit = 0, [string] $Runs = '[]', [int] $RunExit = 0)
            $allowanceText = $Allowance
            $prText = $PullRequest
            $prCode = $PrExit
            $runText = $Runs
            $runCode = $RunExit
            Mock Get-ReleaseLegConfigText -MockWith ({ $allowanceText }.GetNewClosure())
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'pr' } -MockWith ({ [pscustomobject]@{ ExitCode = $prCode; Output = $prText } }.GetNewClosure())
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith ({ [pscustomobject]@{ ExitCode = $runCode; Output = $runText } }.GetNewClosure())
        }

        function Invoke-ReleaseLeg {
            # Call the leg with the injected seams.
            param([string] $Command = $script:ReleaseCommand, [AllowNull()][Nullable[int]] $PrNumber = 5, [AllowEmptyString()][string] $Root = $script:ReleaseRoot, [bool] $NoRecordingTarget = $true)
            return Get-EpicMergeGateReleaseDecision -CommandText $Command -PrNumber $PrNumber -WorktreeRoot $Root -NoRecordingTarget $NoRecordingTarget -ConfigReader { param([string] $Root) Get-ReleaseLegConfigText -Root $Root } -ContainerProbe { param([string] $Root, [string] $RelativePath) Test-ReleaseLegContainer -Root $Root -RelativePath $RelativePath }
        }

        function Get-ReleaseLegCode {
            # Return the RELEASE_MERGE_* code of a suffix, or ''.
            param([AllowEmptyString()][string] $Suffix)
            if ($Suffix -cmatch '^ \(release merge not applied: (RELEASE_MERGE_[A-Z_]+): ') { return $Matches[1] }
            return ''
        }

        function Get-ReleaseLegDetail {
            # Return the detail of a suffix, or ''.
            param([AllowEmptyString()][string] $Suffix)
            if ($Suffix -cmatch '^ \(release merge not applied: RELEASE_MERGE_[A-Z_]+: (?<detail>.*)\)$') { return $Matches['detail'] }
            return ''
        }
    }

    BeforeEach {
        Mock Get-ReleaseLegConfigText { $null }
        Mock Test-ReleaseLegContainer { $false }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
    }

    AfterAll {
        foreach ($name in 'Get-ReleaseLegConfigText', 'Test-ReleaseLegContainer', 'Get-ReleaseLegAllowanceText', 'Get-ReleaseLegPullRequestText', 'Set-ReleaseLegSeam', 'Invoke-ReleaseLeg', 'Get-ReleaseLegCode', 'Get-ReleaseLegDetail') {
            Remove-Item -LiteralPath "Function:\$name" -ErrorAction SilentlyContinue
        }
    }

    Context 'step 1 (AC-03)' {
        It 'declines <Name> with an empty suffix and no I/O (#1234)' -ForEach @(
            @{ Name = 'a null PrNumber'; PrNumber = $null; Root = '/synthetic-worktrees/release-1234' }
            @{ Name = 'PrNumber 0'; PrNumber = 0; Root = '/synthetic-worktrees/release-1234' }
            @{ Name = 'PrNumber -1'; PrNumber = -1; Root = '/synthetic-worktrees/release-1234' }
            @{ Name = 'a blank WorktreeRoot'; PrNumber = 5; Root = ' ' }
        ) {
            # Arrange
            Set-ReleaseLegSeam

            # Act
            $result = Invoke-ReleaseLeg -PrNumber $PrNumber -Root $Root

            # Assert
            $result.Allowed | Should -BeFalse
            $result.Suffix | Should -BeExactly ''
            Should -Invoke Get-ReleaseLegConfigText -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }

    Context 'step 2 (AC-04)' {
        It 'declines an absent allowance file with an empty suffix and no gh call (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -Allowance $null

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            $result.Allowed | Should -BeFalse
            $result.Suffix | Should -BeExactly ''
            Should -Invoke Get-ReleaseLegConfigText -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'reports RELEASE_MERGE_CONFIG_INVALID with the detail <Detail> for <Name> (#1234)' -ForEach @(
            @{ Name = 'a reader throw'; Case = 'throw'; Detail = 'the file could not be read' }
            @{ Name = 'a parse failure'; Case = 'parse'; Detail = 'the file is not valid JSON' }
            @{ Name = 'a directory entry'; Case = 'container'; Detail = "allowed_paths entry 'package.json' is a directory" }
        ) {
            # Arrange
            Set-ReleaseLegSeam
            if ($Case -eq 'throw') { Mock Get-ReleaseLegConfigText { throw 'read failed' } }
            if ($Case -eq 'parse') { Mock Get-ReleaseLegConfigText { 'not json' } }
            if ($Case -eq 'container') { Mock Test-ReleaseLegContainer { $true } }

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            $result.Allowed | Should -BeFalse
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CONFIG_INVALID'
            Get-ReleaseLegDetail -Suffix $result.Suffix | Should -BeExactly $Detail
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }

    Context 'step 3 (AC-05)' {
        It 'reports RELEASE_MERGE_CHECKPOINT_PRESENT when NoRecordingTarget is false (#1234)' {
            # Arrange
            Set-ReleaseLegSeam

            # Act
            $result = Invoke-ReleaseLeg -NoRecordingTarget $false

            # Assert
            $result.Allowed | Should -BeFalse
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CHECKPOINT_PRESENT'
        }
    }

    Context 'step 4 (AC-06)' {
        It 'reports RELEASE_MERGE_COMMAND_NOT_MODELLED with the shape detail for <Name> (#1234)' -ForEach @(
            @{ Name = 'a chained command'; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567 && echo x' }
            @{ Name = 'a VAR= prefix'; Command = 'GH_REPO=o/r gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567' }
            @{ Name = '-R'; Command = 'gh pr merge 5 --merge -R o/r --match-head-commit 0123456789abcdef0123456789abcdef01234567' }
            @{ Name = '--repo'; Command = 'gh pr merge 5 --merge --repo o/r --match-head-commit 0123456789abcdef0123456789abcdef01234567' }
            @{ Name = 'a URL selector'; Command = 'gh pr merge https://github.com/o/r/pull/5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567' }
            @{ Name = '--auto'; Command = 'gh pr merge 5 --merge --auto --match-head-commit 0123456789abcdef0123456789abcdef01234567' }
        ) {
            # Arrange
            Set-ReleaseLegSeam
            $expected = (Get-DocsOnlyMergeShapeViolation -CommandText $Command -PrNumber 5).Substring('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '.Length)

            # Act
            $result = Invoke-ReleaseLeg -Command $Command

            # Assert
            $result.Allowed | Should -BeFalse
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_COMMAND_NOT_MODELLED'
            ((Get-ReleaseLegDetail -Suffix $result.Suffix) -ceq $expected) | Should -BeTrue -Because "the detail is the shape text '$expected'"
        }

        It 'reports RELEASE_MERGE_COMMAND_NOT_MODELLED with the detail --admin is not eligible (#1234)' {
            # Arrange
            Set-ReleaseLegSeam

            # Act
            $result = Invoke-ReleaseLeg -Command "gh pr merge 5 --merge --admin --match-head-commit $($script:ReleaseHead)"

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_COMMAND_NOT_MODELLED'
            ((Get-ReleaseLegDetail -Suffix $result.Suffix) -ceq '--admin is not eligible') | Should -BeTrue
        }
    }

    Context 'step 5 (AC-07)' {
        It 'reports RELEASE_MERGE_MATCH_HEAD_MISSING for <Name> (#1234)' -ForEach @(
            @{ Name = 'no --match-head-commit'; Command = 'gh pr merge 5 --merge' }
            @{ Name = 'the flag with no value'; Command = 'gh pr merge 5 --merge --match-head-commit' }
            @{ Name = 'an uppercase value'; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789ABCDEF0123456789ABCDEF01234567' }
            @{ Name = 'a 39-character value'; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef0123456' }
        ) {
            # Arrange
            Set-ReleaseLegSeam

            # Act
            $result = Invoke-ReleaseLeg -Command $Command

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_MATCH_HEAD_MISSING'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }
    }

    Context 'step 6 (AC-08)' {
        It 'reports RELEASE_MERGE_PR_UNRESOLVED for <Name> (#1234)' -ForEach @(
            @{ Name = 'a gh pr view exit 1'; Case = 'exit'; Override = @{} }
            @{ Name = 'unparseable output'; Case = 'text'; RawOutput = 'not json'; Override = @{} }
            @{ Name = 'a JSON array'; Case = 'array'; Override = @{} }
            @{ Name = 'an invalid headRefOid'; Override = @{ headRefOid = 'abc' } }
            @{ Name = 'a headRefName of -x'; Override = @{ headRefName = '-x' } }
            @{ Name = 'a baseRefName containing ..'; Override = @{ baseRefName = 'main..x' } }
            @{ Name = 'isCrossRepository as a string'; Override = @{ isCrossRepository = 'false' } }
            @{ Name = 'changedFiles as 1.5'; Override = @{ changedFiles = 1.5 } }
            @{ Name = 'files as an object'; Override = @{ files = @{ path = 'package.json'; changeType = 'MODIFIED' } } }
        ) {
            # Arrange
            $text = Get-ReleaseLegPullRequestText -Override $Override
            if ($Case -eq 'text') { $text = $RawOutput }
            if ($Case -eq 'array') { $text = '[' + $text + ']' }
            $exit = if ($Case -eq 'exit') { 1 } else { 0 }
            Set-ReleaseLegSeam -PullRequest $text -PrExit $exit

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            $result.Allowed | Should -BeFalse
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_PR_UNRESOLVED'
        }

        It 'calls gh pr view once with the step 6 argument list (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PrExit 1

            # Act
            $null = Invoke-ReleaseLeg

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq "pr view 5 --json $($script:ReleaseFields)" }
        }
    }

    Context 'steps 7 to 9 (AC-09, AC-10, AC-11)' {
        It 'reports RELEASE_MERGE_PR_NOT_OPEN for state <State> (#1234)' -ForEach @(
            @{ State = 'MERGED' }
            @{ State = 'CLOSED' }
            @{ State = 'open' }
        ) {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ state = $State })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_PR_NOT_OPEN'
        }

        It 'reports RELEASE_MERGE_CROSS_REPOSITORY for a cross-repository head with a matching branch (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ isCrossRepository = $true })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CROSS_REPOSITORY'
        }

        It 'reports RELEASE_MERGE_HEAD_MISMATCH for a headRefOid that differs from --match-head-commit (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ headRefOid = $script:ReleaseOtherHead })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_HEAD_MISMATCH'
        }
    }

    Context 'steps 10 and 11 (AC-12, AC-13)' {
        It 'reports RELEASE_MERGE_FILES_TRUNCATED for <Name> (#1234)' -ForEach @(
            @{ Name = 'changedFiles 101 with 101 entries'; Count = 101; Listed = 101 }
            @{ Name = 'changedFiles 2 with one entry'; Count = 2; Listed = 1 }
        ) {
            # Arrange
            $files = @(0..($Listed - 1) | ForEach-Object { @{ path = "f$_.txt"; changeType = 'MODIFIED' } })
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = $Count; files = $files })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_FILES_TRUNCATED'
        }

        It 'passes step 10 for changedFiles 100 with 100 listed MODIFIED entries (#1234)' {
            # Arrange
            $paths = @(0..99 | ForEach-Object { "f$_.txt" })
            $files = @($paths | ForEach-Object { @{ path = $_; changeType = 'MODIFIED' } })
            Set-ReleaseLegSeam -Allowance (Get-ReleaseLegAllowanceText -Allowance @(@{ id = 'release'; branch_patterns = @('release/*'); allowed_paths = $paths })) -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = 100; files = $files })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_MISSING'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }

        It 'reports RELEASE_MERGE_CHANGE_NOT_MODELLED for <Name> (#1234)' -ForEach @(
            @{ Name = 'a RENAMED entry'; Entry = @{ path = 'package.json'; changeType = 'RENAMED' } }
            @{ Name = 'a COPIED entry'; Entry = @{ path = 'package.json'; changeType = 'COPIED' } }
            @{ Name = 'a blank path'; Entry = @{ path = ''; changeType = 'MODIFIED' } }
        ) {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = 1; files = @($Entry) })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CHANGE_NOT_MODELLED'
        }

        It 'passes step 11 for ADDED, MODIFIED, CHANGED, and DELETED entries (#1234)' {
            # Arrange
            $paths = @('a.txt', 'b.txt', 'c.txt', 'd.txt')
            $types = @('ADDED', 'MODIFIED', 'CHANGED', 'DELETED')
            $files = @(0..3 | ForEach-Object { @{ path = $paths[$_]; changeType = $types[$_] } })
            Set-ReleaseLegSeam -Allowance (Get-ReleaseLegAllowanceText -Allowance @(@{ id = 'release'; branch_patterns = @('release/*'); allowed_paths = $paths })) -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = 4; files = $files })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_CI_MISSING'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }
    }

    Context 'step 12 (AC-14)' {
        It 'reports RELEASE_MERGE_BRANCH_NOT_MATCHED for a head branch that matches no pattern (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ headRefName = 'feature/x' })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_BRANCH_NOT_MATCHED'
        }

        It 'reports RELEASE_MERGE_EMPTY_DIFF for an empty files array with changedFiles 0 (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = 0; files = @() })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_EMPTY_DIFF'
        }

        It 'reports RELEASE_MERGE_PATH_NOT_ALLOWED for an unlisted path (#1234)' {
            # Arrange
            Set-ReleaseLegSeam -PullRequest (Get-ReleaseLegPullRequestText -Override @{ changedFiles = 1; files = @(@{ path = 'src/a.ps1'; changeType = 'MODIFIED' }) })

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_PATH_NOT_ALLOWED'
            Get-ReleaseLegDetail -Suffix $result.Suffix | Should -BeExactly "'src/a.ps1' is not listed in allowed_paths of allowance 'release'"
        }

        It 'does not combine the paths of two matching allowances (#1234)' {
            # Arrange
            $allowances = @(
                @{ id = 'first'; branch_patterns = @('release/*'); allowed_paths = @('package.json') }
                @{ id = 'second'; branch_patterns = @('release/v*'); allowed_paths = @('CHANGELOG.md') }
            )
            Set-ReleaseLegSeam -Allowance (Get-ReleaseLegAllowanceText -Allowance $allowances)

            # Act
            $result = Invoke-ReleaseLeg

            # Assert
            Get-ReleaseLegCode -Suffix $result.Suffix | Should -BeExactly 'RELEASE_MERGE_PATH_NOT_ALLOWED'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
        }
    }
}
