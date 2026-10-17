Set-StrictMode -Version Latest

# Unit suite for the merge-base fallback of scripts/ci/Invoke-CiChangeScope.ps1 (issue #973).
#
# The entry script is dot-sourced, so its dot-source guard skips the CI entry point and the functions are
# available to the rows. Every external effect goes through test-local fakes passed as -GhInvoker,
# -GitInvoker, -OutputWriter, and -ReadVariable; the fakes record their calls in memory. No cmdlet is
# mocked, and no process, temporary file, environment variable change, or network call is made.

Describe 'Invoke-CiChangeScope.ps1 merge-base fallback (issue #973)' {
    BeforeAll {
        $script:EntryPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Invoke-CiChangeScope.ps1'
        if (-not (Test-Path -LiteralPath $script:EntryPath)) {
            throw "The entry script under test does not exist: $script:EntryPath"
        }
        . $script:EntryPath

        $script:Nul = [string][char]0
        $script:GreenA = 'a' * 40
        $script:HeadB = 'b' * 40
        $script:PayloadBaseD = 'd' * 40
        $script:MergeBaseE = 'e' * 40
        # The seven-prefix allowlist of issue #973, held in the test so the rows do not depend on the committed
        # config file; the rows that use the committed file omit -ConfigJson.
        $script:ConfigJson = '{"version":1,"include_prefixes":["docs/features/active/","docs/features/archive/","docs/features/completed/","docs/features/epics/","docs/features/parallel/","docs/features/potential/","docs/research/"],"exclude_prefixes":["docs/features/potential/template.md","docs/features/templates/"],"extensions":[".md",".txt",".log",".json",".xml"]}'
        $script:EmptyRunList = '{"workflow_runs":[]}'
        $script:GreenRunList = '{"workflow_runs":[{"id":900,"run_number":9,"head_sha":"' + ('a' * 40) + '","conclusion":"success","head_repository":{"full_name":"drmoisan/drm-copilot"}}]}'
        $script:MarkerSuccess = '{"jobs":[{"name":"CI full run","conclusion":"success"}]}'

        # Wraps a payload text in the invoker result shape { ExitCode; Output }.
        function Get-TestCallResult {
            param([int] $ExitCode = 0, [AllowEmptyString()][string] $Output = '')
            return [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
        }

        # Joins paths into git diff -z output: every path is terminated by NUL.
        function ConvertTo-TestNulList {
            param([string[]] $Paths)
            return (@($Paths | ForEach-Object { $_ + $script:Nul }) -join '')
        }

        # Returns the standard scenario: a same-repository pull request into main with no earlier full green
        # run, a payload base commit that is present, a merge base E, and a docs-only diff from E to the head.
        # Each row changes one element.
        function Get-TestScenario {
            return [pscustomobject]@{
                Context         = @{ EventName = 'pull_request'; HeadSha = $script:HeadB; HeadRef = 'docs/x'; HeadRepository = 'drmoisan/drm-copilot'; Repository = 'drmoisan/drm-copilot'; RunId = '1000'; BaseSha = $script:PayloadBaseD; BaseRef = 'main' }
                RunsResult      = Get-TestCallResult -Output $script:EmptyRunList
                JobsResult      = Get-TestCallResult -Output $script:MarkerSuccess
                CatFileExit     = @{}
                AncestorExit    = 0
                MergeBaseResult = Get-TestCallResult -Output $script:MergeBaseE
                DiffResults     = @{ $script:MergeBaseE = (Get-TestCallResult -Output (ConvertTo-TestNulList -Paths @('docs/features/active/x/evidence/a.md'))) }
                GhCalls         = [System.Collections.Generic.List[string]]::new()
                GitCalls        = [System.Collections.Generic.List[string]]::new()
                Writes          = [System.Collections.Generic.List[object]]::new()
            }
        }

        # Runs Invoke-CiChangeScope with fakes bound to the scenario. The git fake answers cat-file per SHA,
        # tells merge-base --is-ancestor from the bare two-SHA merge-base form by its second argument, and
        # answers diff per base SHA; every call is recorded as one space-joined string.
        function Invoke-TestScenario {
            param([Parameter(Mandatory = $true)][pscustomobject] $State, [switch] $OmitConfigJson)
            $gh = {
                $State.GhCalls.Add((@($args) -join ' '))
                $apiPath = [string]$args[1]
                if ($apiPath.Contains('/actions/workflows/ci.yml/runs?')) { return $State.RunsResult }
                if ($apiPath.Contains('/actions/runs/900/jobs?')) { return $State.JobsResult }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }.GetNewClosure()
            $git = {
                $State.GitCalls.Add((@($args) -join ' '))
                $verb = [string]$args[0]
                if ($verb -ceq 'cat-file') {
                    $target = ([string]$args[2]).Replace('^{commit}', '')
                    $exit = 0
                    if ($State.CatFileExit.ContainsKey($target)) { $exit = [int]$State.CatFileExit[$target] }
                    return [pscustomobject]@{ ExitCode = $exit; Output = '' }
                }
                if ($verb -ceq 'merge-base') {
                    if ([string]$args[1] -ceq '--is-ancestor') { return [pscustomobject]@{ ExitCode = $State.AncestorExit; Output = '' } }
                    return $State.MergeBaseResult
                }
                if ($verb -ceq 'diff') {
                    $diffBase = [string]$args[7]
                    if ($State.DiffResults.ContainsKey($diffBase)) { return $State.DiffResults[$diffBase] }
                }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }.GetNewClosure()
            $writer = {
                param([string] $Target, [string] $Text)
                $State.Writes.Add([pscustomobject]@{ Target = $Target; Text = $Text })
            }.GetNewClosure()

            $arguments = @{ Context = $State.Context; GhInvoker = $gh; GitInvoker = $git; OutputWriter = $writer }
            if (-not $OmitConfigJson) { $arguments['ConfigJson'] = $script:ConfigJson }
            return Invoke-CiChangeScope @arguments
        }

        # Returns the texts the writer fake recorded for one target, joined with '|'.
        function Get-TestWriteText {
            param([Parameter(Mandatory = $true)][pscustomobject] $State, [Parameter(Mandatory = $true)][string] $Target)
            return (@($State.Writes | Where-Object { $_.Target -ceq $Target } | ForEach-Object { $_.Text }) -join '|')
        }

        # Returns the recorded bare two-SHA merge-base calls (not the --is-ancestor form).
        function Get-TestBareMergeBaseCall {
            param([Parameter(Mandatory = $true)][pscustomobject] $State)
            return @($State.GitCalls | Where-Object { $_.StartsWith('merge-base ', [StringComparison]::Ordinal) -and -not $_.StartsWith('merge-base --is-ancestor ', [StringComparison]::Ordinal) })
        }
    }

    Context 'merge-base decisions' {
        It 'decides code=false DOCS_ONLY_SINCE_MERGE_BASE with the merge base in the summary when no green run exists and the base ref is main (#973)' {
            $state = Get-TestScenario

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly ('code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_' + $script:MergeBaseE)
            Get-TestWriteText -State $state -Target 'Output' | Should -BeExactly 'code=false'
            (Get-TestWriteText -State $state -Target 'Summary').Contains('base=' + $script:MergeBaseE) | Should -BeTrue -Because 'the summary records the merge base that the diff started from'
        }

        It 'decides NON_ALLOWLISTED_PATH on the merge-base diff when one path is outside the allowlist (#973)' {
            $state = Get-TestScenario
            $state.DiffResults[$script:MergeBaseE] = Get-TestCallResult -Output (ConvertTo-TestNulList -Paths @('docs/features/active/x/evidence/a.md', 'scripts/ci/x.ps1'))

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly 'code=true reason=NON_ALLOWLISTED_PATH: scripts/ci/x.ps1' -Because 'one code path in the merge-base diff forces a full run'
        }

        It 'decides NON_ALLOWLISTED_PATH on the merge-base diff for a rename <Direction> the allowlist (#973)' -ForEach @(
            @{ Direction = 'into'; Paths = @('scripts/x.ps1', 'docs/features/archive/x.md') }
            @{ Direction = 'out of'; Paths = @('docs/features/archive/x.md', 'scripts/x.ps1') }
        ) {
            # git diff --no-renames lists a rename as the deleted old path and the added new path.
            $state = Get-TestScenario
            $state.DiffResults[$script:MergeBaseE] = Get-TestCallResult -Output (ConvertTo-TestNulList -Paths $Paths)

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly 'code=true reason=NON_ALLOWLISTED_PATH: scripts/x.ps1' -Because "a rename $Direction the allowlist has one side outside it"
        }

        It 'reaches DOCS_ONLY_SINCE_MERGE_BASE for a Markdown path under <Prefix> with the committed allowlist (#973)' -ForEach @(
            @{ Prefix = 'docs/features/archive/' }
            @{ Prefix = 'docs/features/parallel/' }
            @{ Prefix = 'docs/features/epics/' }
        ) {
            $state = Get-TestScenario
            $state.DiffResults[$script:MergeBaseE] = Get-TestCallResult -Output (ConvertTo-TestNulList -Paths @($Prefix + 'x/evidence/a.md'))

            $null = Invoke-TestScenario -State $state -OmitConfigJson

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly ('code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_' + $script:MergeBaseE) -Because "the committed allowlist includes $Prefix"
        }

        It 'decides MERGE_BASE_UNRESOLVED with base none when <Case> (#973)' -ForEach @(
            @{ Case = 'BASE_SHA is blank'; BaseSha = ''; CatFileExit = 0; MergeBaseExit = 0; MergeBaseOutput = ('e' * 40) }
            @{ Case = 'git cat-file exits 128'; BaseSha = ('d' * 40); CatFileExit = 128; MergeBaseExit = 0; MergeBaseOutput = ('e' * 40) }
            @{ Case = 'git merge-base exits 1'; BaseSha = ('d' * 40); CatFileExit = 0; MergeBaseExit = 1; MergeBaseOutput = '' }
            @{ Case = 'git merge-base exits 128'; BaseSha = ('d' * 40); CatFileExit = 0; MergeBaseExit = 128; MergeBaseOutput = '' }
            @{ Case = 'the merge-base output is empty'; BaseSha = ('d' * 40); CatFileExit = 0; MergeBaseExit = 0; MergeBaseOutput = '' }
            @{ Case = 'the merge-base output is not a SHA'; BaseSha = ('d' * 40); CatFileExit = 0; MergeBaseExit = 0; MergeBaseOutput = 'fatal: not a commit' }
            @{ Case = 'the merge-base output holds two SHA lines'; BaseSha = ('d' * 40); CatFileExit = 0; MergeBaseExit = 0; MergeBaseOutput = (('e' * 40) + "`n" + ('a' * 40)) }
        ) {
            $state = Get-TestScenario
            $state.Context.BaseSha = $BaseSha
            $state.CatFileExit[('d' * 40)] = $CatFileExit
            $state.MergeBaseResult = Get-TestCallResult -ExitCode $MergeBaseExit -Output $MergeBaseOutput

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly 'code=true reason=MERGE_BASE_UNRESOLVED'
            (Get-TestWriteText -State $state -Target 'Summary').EndsWith('base=none', [StringComparison]::Ordinal) | Should -BeTrue
            @($state.GitCalls | Where-Object { $_.StartsWith('diff ', [StringComparison]::Ordinal) }).Count | Should -Be 0 -Because "an unresolved merge base ($Case) fails closed without a diff"
        }

        It 'falls back to the merge base when the primary reason is <PrimaryReason> and the base ref is main (#973)' -ForEach @(
            @{ PrimaryReason = 'BASE_NOT_PRESENT'; GreenCatFileExit = 128; AncestorExit = 0 }
            @{ PrimaryReason = 'BASE_NOT_ANCESTOR'; GreenCatFileExit = 0; AncestorExit = 1 }
        ) {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -Output $script:GreenRunList
            $state.CatFileExit[$script:GreenA] = $GreenCatFileExit
            $state.AncestorExit = $AncestorExit

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly ('code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_' + $script:MergeBaseE) -Because "$PrimaryReason on the green base falls back to the merge base for a pull request into main"
        }

        It 'keeps NO_FULL_GREEN_RUN without a bare merge-base call when the base ref is <BaseRef> (#973)' -ForEach @(
            @{ BaseRef = 'development' }
            @{ BaseRef = 'epic/x' }
        ) {
            $state = Get-TestScenario
            $state.Context.BaseRef = $BaseRef

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly 'code=true reason=NO_FULL_GREEN_RUN'
            @(Get-TestBareMergeBaseCall -State $state).Count | Should -Be 0 -Because "a pull request into $BaseRef keeps the issue #962 behavior"
        }

        It 'keeps <Reason> without a merge-base resolution call when the base ref is main (#973)' -ForEach @(
            @{ Reason = 'RUN_LIST_FAILED'; RunListExit = 1; JobListExit = 0 }
            @{ Reason = 'JOB_LIST_FAILED'; RunListExit = 0; JobListExit = 1 }
        ) {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -ExitCode $RunListExit -Output $script:GreenRunList
            $state.JobsResult = Get-TestCallResult -ExitCode $JobListExit -Output $script:MarkerSuccess

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly "code=true reason=$Reason"
            $state.GitCalls.Count | Should -Be 0 -Because "$Reason is a terminal full run with no fallback"
        }

        It 'decides <Reason> when the merge-base diff <Case> (#973)' -ForEach @(
            @{ Reason = 'DIFF_FAILED'; Case = 'exits non-zero'; DiffExit = 128 }
            @{ Reason = 'EMPTY_DIFF'; Case = 'is empty'; DiffExit = 0 }
        ) {
            $state = Get-TestScenario
            $state.DiffResults[$script:MergeBaseE] = Get-TestCallResult -ExitCode $DiffExit -Output ''

            $null = Invoke-TestScenario -State $state

            Get-TestWriteText -State $state -Target 'Log' | Should -BeExactly "code=true reason=$Reason"
            (Get-TestWriteText -State $state -Target 'Summary').Contains('base=' + $script:MergeBaseE) | Should -BeTrue -Because 'every merge-base diff outcome records the merge base'
        }

        It 'passes the unchanged diff flag list with the merge base and the head to git diff (#973)' {
            $state = Get-TestScenario

            $null = Invoke-TestScenario -State $state

            $diffCalls = @($state.GitCalls | Where-Object { $_.StartsWith('diff ', [StringComparison]::Ordinal) })
            $diffCalls.Count | Should -Be 1
            $diffCalls[0] | Should -BeExactly ('diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative ' + $script:MergeBaseE + ' ' + $script:HeadB) -Because 'the merge-base diff reuses the green-run diff arguments'
        }
    }

    Context 'event gates and context' {
        It 'decides <Reason> before any invoker call for <Case> with base ref main (#973)' -ForEach @(
            @{ Case = 'push'; EventName = 'push'; HeadRepository = 'drmoisan/drm-copilot'; Reason = 'EVENT_NOT_PULL_REQUEST' }
            @{ Case = 'merge_group'; EventName = 'merge_group'; HeadRepository = 'drmoisan/drm-copilot'; Reason = 'EVENT_NOT_PULL_REQUEST' }
            @{ Case = 'workflow_dispatch'; EventName = 'workflow_dispatch'; HeadRepository = 'drmoisan/drm-copilot'; Reason = 'EVENT_NOT_PULL_REQUEST' }
            @{ Case = 'a fork pull request'; EventName = 'pull_request'; HeadRepository = 'someone/drm-copilot'; Reason = 'FORK_PULL_REQUEST' }
        ) {
            $state = Get-TestScenario
            $state.Context.EventName = $EventName
            $state.Context.HeadRepository = $HeadRepository

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly $Reason
            ($state.GhCalls.Count + $state.GitCalls.Count) | Should -Be 0 -Because "$Case keeps the issue #962 never-skip semantics"
        }

        It 'Get-CiChangeScopeContext reads BASE_SHA and BASE_REF through the injected reader (#973)' {
            $reader = { param([string] $Name) 'value-of-' + $Name }

            $context = Get-CiChangeScopeContext -ReadVariable $reader

            $context['BaseSha'] | Should -BeExactly 'value-of-BASE_SHA'
            $context['BaseRef'] | Should -BeExactly 'value-of-BASE_REF' -Because 'the payload base values are read only through the injected reader'
        }
    }
}
