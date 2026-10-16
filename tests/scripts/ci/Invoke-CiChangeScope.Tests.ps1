Set-StrictMode -Version Latest

# Unit suite for the change-scope entry script scripts/ci/Invoke-CiChangeScope.ps1 (issue #962).
#
# The entry script is dot-sourced, so its dot-source guard skips the CI entry point and the functions are
# available to the rows. Every external effect goes through test-local fakes passed as -GhInvoker,
# -GitInvoker, -OutputWriter, and -ReadVariable; the fakes record their calls in memory. The only cmdlet
# mocks are Add-Content and Write-Information, used by the default-writer rows. No process, temporary
# file, or network call is made.

Describe 'Invoke-CiChangeScope.ps1 change-scope entry script' {
    BeforeAll {
        $script:EntryPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Invoke-CiChangeScope.ps1'
        if (-not (Test-Path -LiteralPath $script:EntryPath)) {
            throw "The entry script under test does not exist: $script:EntryPath"
        }
        . $script:EntryPath

        $script:Nul = [string][char]0
        $script:BaseA = 'a' * 40
        $script:BaseC = 'c' * 40
        $script:HeadB = 'b' * 40
        $script:ConfigJson = '{"version":1,"include_prefixes":["docs/features/active/","docs/features/completed/","docs/features/potential/","docs/research/"],"exclude_prefixes":["docs/features/potential/template.md","docs/features/templates/"],"extensions":[".md",".txt",".log",".json",".xml"]}'

        # Builds one workflow-run entry shaped like the GitHub Actions runs API payload.
        function Get-TestRunEntry {
            param([long] $Id, [long] $RunNumber, [string] $HeadSha)
            return @{ id = $Id; run_number = $RunNumber; head_sha = $HeadSha; conclusion = 'success'; head_repository = @{ full_name = 'drmoisan/drm-copilot' } }
        }

        # Wraps a payload text in the invoker result shape { ExitCode; Output }.
        function Get-TestCallResult {
            param([int] $ExitCode = 0, [AllowEmptyString()][string] $Output = '')
            return [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
        }

        # Serializes run entries into the runs payload text.
        function ConvertTo-TestRunListJson {
            param([object[]] $Runs)
            return (ConvertTo-Json -InputObject @{ workflow_runs = @($Runs) } -Depth 5)
        }

        # Serializes one CI full run job with the given conclusion into the jobs payload text.
        function ConvertTo-TestMarkerJobJson {
            param([string] $Conclusion)
            return (ConvertTo-Json -InputObject @{ jobs = @(@{ name = 'CI full run'; conclusion = $Conclusion }) } -Depth 5)
        }

        # Returns the standard scenario: a same-repository pull request, one successful run 900 whose
        # CI full run job succeeded, git checks that pass, and a docs-only diff. Each row changes one element.
        function Get-TestScenario {
            return [pscustomobject]@{
                Context       = @{ EventName = 'pull_request'; HeadSha = $script:HeadB; HeadRef = 'bug/x'; HeadRepository = 'drmoisan/drm-copilot'; Repository = 'drmoisan/drm-copilot'; RunId = '1000' }
                ConfigJson    = $script:ConfigJson
                RunsResult    = Get-TestCallResult -Output (ConvertTo-TestRunListJson -Runs @(Get-TestRunEntry -Id 900 -RunNumber 9 -HeadSha $script:BaseA))
                JobsResults   = @{ '900' = (Get-TestCallResult -Output (ConvertTo-TestMarkerJobJson -Conclusion 'success')) }
                CatFileExit   = 0
                MergeBaseExit = 0
                DiffResult    = Get-TestCallResult -Output ('docs/features/active/x/evidence/a.md' + $script:Nul)
                GhThrows      = $false
                GhCalls       = [System.Collections.Generic.List[string]]::new()
                GitCalls      = [System.Collections.Generic.List[string]]::new()
                Writes        = [System.Collections.Generic.List[object]]::new()
            }
        }

        # Runs Invoke-CiChangeScope with fakes bound to the scenario. The fakes record every call as one
        # space-joined string and answer from the scenario fields.
        function Invoke-TestScenario {
            param([Parameter(Mandatory = $true)][pscustomobject] $State, [switch] $OmitConfigJson, [switch] $UseDefaultWriter)
            $gh = {
                $State.GhCalls.Add((@($args) -join ' '))
                if ($State.GhThrows) { throw 'synthetic gh failure' }
                $apiPath = [string]$args[1]
                if ($apiPath.Contains('/actions/workflows/ci.yml/runs?')) { return $State.RunsResult }
                foreach ($runId in $State.JobsResults.Keys) {
                    if ($apiPath.Contains("/actions/runs/$runId/jobs?")) { return $State.JobsResults[$runId] }
                }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }.GetNewClosure()
            $git = {
                $State.GitCalls.Add((@($args) -join ' '))
                $verb = [string]$args[0]
                if ($verb -ceq 'cat-file') { return [pscustomobject]@{ ExitCode = $State.CatFileExit; Output = '' } }
                if ($verb -ceq 'merge-base') { return [pscustomobject]@{ ExitCode = $State.MergeBaseExit; Output = '' } }
                if ($verb -ceq 'diff') { return $State.DiffResult }
                return [pscustomobject]@{ ExitCode = 1; Output = '' }
            }.GetNewClosure()
            $writer = {
                param([string] $Target, [string] $Text)
                $State.Writes.Add([pscustomobject]@{ Target = $Target; Text = $Text })
            }.GetNewClosure()

            $arguments = @{ Context = $State.Context; GhInvoker = $gh; GitInvoker = $git }
            if (-not $OmitConfigJson) { $arguments['ConfigJson'] = $State.ConfigJson }
            if (-not $UseDefaultWriter) { $arguments['OutputWriter'] = $writer }
            return Invoke-CiChangeScope @arguments
        }

        # Returns the texts the writer fake recorded for one target.
        function Get-TestWriteText {
            param([Parameter(Mandatory = $true)][pscustomobject] $State, [Parameter(Mandatory = $true)][string] $Target)
            return @($State.Writes | Where-Object { $_.Target -ceq $Target } | ForEach-Object { $_.Text })
        }
    }

    Context 'event and fork gates' {
        It 'writes code=true EVENT_NOT_PULL_REQUEST for <EventName> without calling either invoker (AC-1)' -ForEach @(
            @{ EventName = 'merge_group' }
            @{ EventName = 'push' }
            @{ EventName = 'workflow_dispatch' }
        ) {
            $state = Get-TestScenario
            $state.Context.EventName = $EventName

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'EVENT_NOT_PULL_REQUEST'
            (Get-TestWriteText -State $state -Target 'Output') -join '|' | Should -BeExactly 'code=true'
            $state.GhCalls.Count | Should -Be 0
            $state.GitCalls.Count | Should -Be 0 -Because "a $EventName run decides without reading runs or git history"
        }

        It 'writes code=true FORK_PULL_REQUEST for a fork pull request without calling either invoker (AC-2)' {
            $state = Get-TestScenario
            $state.Context.HeadRepository = 'someone/drm-copilot'

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'FORK_PULL_REQUEST'
            (Get-TestWriteText -State $state -Target 'Output') -join '|' | Should -BeExactly 'code=true'
            ($state.GhCalls.Count + $state.GitCalls.Count) | Should -Be 0 -Because 'a fork pull request always runs in full'
        }
    }

    Context 'run and job list failures' {
        It 'writes code=true RUN_LIST_FAILED when the run-list call exits non-zero (AC-3)' {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -ExitCode 1

            $result = Invoke-TestScenario -State $state

            $result.Code | Should -BeExactly 'true'
            $result.Reason | Should -BeExactly 'RUN_LIST_FAILED' -Because 'an unreadable run list fails closed'
        }

        It 'writes code=true RUN_LIST_FAILED when the run list is not valid JSON (AC-3)' {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -Output 'not json'

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'RUN_LIST_FAILED' -Because 'an unparseable run list fails closed'
        }

        It 'writes code=true JOB_LIST_FAILED when a jobs call fails (AC-4)' {
            $state = Get-TestScenario
            $state.JobsResults['900'] = Get-TestCallResult -ExitCode 1

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'JOB_LIST_FAILED' -Because 'an unreadable job list fails closed'
        }

        It 'writes code=true NO_FULL_GREEN_RUN when the only successful run skipped CI full run (AC-6)' {
            $state = Get-TestScenario
            $state.JobsResults['900'] = Get-TestCallResult -Output (ConvertTo-TestMarkerJobJson -Conclusion 'skipped')

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'NO_FULL_GREEN_RUN' -Because 'a docs-only run is never a base for a later docs-only run'
        }

        It 'writes code=true NO_FULL_GREEN_RUN when the run list is empty (AC-6)' {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -Output (ConvertTo-TestRunListJson -Runs @())

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'NO_FULL_GREEN_RUN' -Because 'without a prior green run there is no base'
        }

        It 'uses the older qualifying run as the base when the newer run has no full-run marker (AC-6)' {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -Output (ConvertTo-TestRunListJson -Runs @((Get-TestRunEntry -Id 900 -RunNumber 9 -HeadSha $script:BaseA), (Get-TestRunEntry -Id 800 -RunNumber 8 -HeadSha $script:BaseC)))
            $state.JobsResults['900'] = Get-TestCallResult -Output (ConvertTo-TestMarkerJobJson -Conclusion 'skipped')
            $state.JobsResults['800'] = Get-TestCallResult -Output (ConvertTo-TestMarkerJobJson -Conclusion 'success')

            $result = Invoke-TestScenario -State $state

            $result.Code | Should -BeExactly 'false'
            $result.Reason | Should -BeExactly ('DOCS_ONLY_SINCE_' + $script:BaseC) -Because 'the newest run with a successful CI full run job is the base'
        }

        It 'never uses the current run as the base (AC-5)' {
            $state = Get-TestScenario
            $state.RunsResult = Get-TestCallResult -Output (ConvertTo-TestRunListJson -Runs @(Get-TestRunEntry -Id 1000 -RunNumber 10 -HeadSha $script:BaseA))
            $state.JobsResults['1000'] = Get-TestCallResult -Output (ConvertTo-TestMarkerJobJson -Conclusion 'success')

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'NO_FULL_GREEN_RUN' -Because 'the run that is deciding cannot be its own base'
        }
    }

    Context 'ancestry and diff' {
        It 'writes code=true BASE_NOT_PRESENT when git cat-file fails (AC-7)' {
            $state = Get-TestScenario
            $state.CatFileExit = 128

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'BASE_NOT_PRESENT' -Because 'a base commit missing from the checkout cannot be diffed'
        }

        It 'writes code=true BASE_NOT_ANCESTOR when merge-base exits 1 (AC-7)' {
            $state = Get-TestScenario
            $state.MergeBaseExit = 1

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'BASE_NOT_ANCESTOR' -Because 'a rewritten history makes the recorded base unrelated to the head'
        }

        It 'writes code=true ANCESTRY_CHECK_FAILED when merge-base exits 128 (AC-7)' {
            $state = Get-TestScenario
            $state.MergeBaseExit = 128

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'ANCESTRY_CHECK_FAILED' -Because 'any other merge-base failure fails closed'
        }

        It 'passes --name-only, -z, --no-renames, --no-color, --no-ext-diff, --no-relative, and both SHAs to git diff (AC-8)' {
            $state = Get-TestScenario

            $null = Invoke-TestScenario -State $state

            $diffCalls = @($state.GitCalls | Where-Object { $_.StartsWith('diff ', [StringComparison]::Ordinal) })
            $diffCalls.Count | Should -Be 1
            $arguments = $diffCalls[0].Split(' ')
            $missing = @(@('--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', $script:BaseA, $script:HeadB) | Where-Object { $arguments -cnotcontains $_ })
            ($missing -join ',') | Should -BeExactly '' -Because 'the diff must list NUL-terminated paths between the base and the head without rename pairing or external tools'
        }

        It 'writes code=true DIFF_FAILED when git diff exits non-zero (AC-8)' {
            $state = Get-TestScenario
            $state.DiffResult = Get-TestCallResult -ExitCode 128

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'DIFF_FAILED' -Because 'a failed diff fails closed'
        }

        It 'writes code=true DIFF_FAILED when the diff output does not end in NUL (AC-8)' {
            $state = Get-TestScenario
            $state.DiffResult = Get-TestCallResult -Output 'docs/features/active/x/evidence/a.md'

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'DIFF_FAILED' -Because 'output without the trailing NUL is not git diff -z output'
        }

        It 'writes code=true EMPTY_DIFF for an empty diff (AC-9)' {
            $state = Get-TestScenario
            $state.DiffResult = Get-TestCallResult -Output ''

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'EMPTY_DIFF' -Because 'an empty diff fails closed'
        }

        It 'writes code=true NON_ALLOWLISTED_PATH for a mixed diff (AC-10)' {
            $state = Get-TestScenario
            $state.DiffResult = Get-TestCallResult -Output ('docs/features/active/x/evidence/a.md' + $script:Nul + 'scripts/ci/CiChangeScope.psm1' + $script:Nul)

            $null = Invoke-TestScenario -State $state

            (Get-TestWriteText -State $state -Target 'Log') -join '|' | Should -BeExactly 'code=true reason=NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1' -Because 'one code path forces a full run'
        }

        It 'writes code=false and logs DOCS_ONLY_SINCE with the base for a docs-only diff (AC-11)' {
            $state = Get-TestScenario

            $result = Invoke-TestScenario -State $state

            $result.Code | Should -BeExactly 'false'
            (Get-TestWriteText -State $state -Target 'Output') -join '|' | Should -BeExactly 'code=false'
            (Get-TestWriteText -State $state -Target 'Log') -join '|' | Should -BeExactly ('code=false reason=DOCS_ONLY_SINCE_' + $script:BaseA)
            $summary = (Get-TestWriteText -State $state -Target 'Summary') -join '|'
            $summary.Contains('reason=DOCS_ONLY_SINCE_' + $script:BaseA) | Should -BeTrue
            $summary.Contains('base=' + $script:BaseA) | Should -BeTrue -Because 'the summary records the reason and the base commit'
        }
    }

    Context 'fail-closed envelope' {
        It 'writes code=true UNEXPECTED_ERROR and a warning for an invalid config (AC-14)' {
            $state = Get-TestScenario
            $state.ConfigJson = '{bad'

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'UNEXPECTED_ERROR'
            $warnings = @(Get-TestWriteText -State $state -Target 'Warning')
            $warnings.Count | Should -Be 1
            $warnings[0].StartsWith('Change scope failed closed: ', [StringComparison]::Ordinal) | Should -BeTrue -Because 'an invalid allowlist is reported and fails closed'
        }

        It 'writes code=true UNEXPECTED_ERROR and a warning without throwing when an invoker throws (AC-16)' {
            $state = Get-TestScenario
            $state.GhThrows = $true

            { $script:Captured = Invoke-TestScenario -State $state } | Should -Not -Throw
            $result = $script:Captured

            $result.Code | Should -BeExactly 'true'
            $result.Reason | Should -BeExactly 'UNEXPECTED_ERROR'
            @(Get-TestWriteText -State $state -Target 'Warning').Count | Should -Be 1 -Because 'an unexpected exception is reported as a warning annotation'
        }

        It 'writes code=true UNEXPECTED_ERROR when HEAD_SHA is blank on a pull_request event (AC-16)' {
            $state = Get-TestScenario
            $state.Context.HeadSha = ''

            $result = Invoke-TestScenario -State $state

            $result.Reason | Should -BeExactly 'UNEXPECTED_ERROR'
            @(Get-TestWriteText -State $state -Target 'Warning').Count | Should -Be 1 -Because 'a blank head SHA cannot be decided'
        }
    }

    Context 'seams, context, and default writer' {
        It 'declares the GhInvoker, GitInvoker, and OutputWriter seams and a dot-source guard (AC-17)' {
            $parameterNames = @((Get-Command -Name Invoke-CiChangeScope).Parameters.Keys)
            $scriptText = Get-Content -Raw -LiteralPath $script:EntryPath

            $missing = @(@('GhInvoker', 'GitInvoker', 'OutputWriter') | Where-Object { $parameterNames -cnotcontains $_ })

            ($missing -join ',') | Should -BeExactly ''
            $scriptText.Contains('$MyInvocation.InvocationName -ne ''.''') | Should -BeTrue -Because 'the entry point must not run when the script is dot-sourced'
        }

        It 'reads the six context values through the injected variable reader (AC-17)' {
            $reader = { param([string] $Name) 'value-of-' + $Name }

            $context = Get-CiChangeScopeContext -ReadVariable $reader

            $context.EventName | Should -BeExactly 'value-of-EVENT_NAME'
            $context.HeadSha | Should -BeExactly 'value-of-HEAD_SHA'
            $context.HeadRef | Should -BeExactly 'value-of-HEAD_REF'
            $context.HeadRepository | Should -BeExactly 'value-of-HEAD_REPO'
            $context.Repository | Should -BeExactly 'value-of-REPOSITORY'
            $context.RunId | Should -BeExactly 'value-of-RUN_ID' -Because 'the context is read only through the injected reader'
        }

        It 'default writer appends Output and Summary text to the GITHUB_OUTPUT and GITHUB_STEP_SUMMARY paths (AC-11)' {
            Mock -CommandName Add-Content
            $reader = {
                param([string] $Name)
                if ($Name -ceq 'GITHUB_OUTPUT') { return '/synthetic/output' }
                if ($Name -ceq 'GITHUB_STEP_SUMMARY') { return '/synthetic/summary' }
                return $null
            }

            Write-CiChangeScopeTarget -Target 'Output' -Text 'code=true' -ReadVariable $reader
            Write-CiChangeScopeTarget -Target 'Summary' -Text 'Change scope: code=true; reason=EMPTY_DIFF; base=none' -ReadVariable $reader

            Should -Invoke -CommandName Add-Content -Times 1 -Exactly -ParameterFilter { (@($LiteralPath) -join '') -ceq '/synthetic/output' -and (@($Value) -join '') -ceq 'code=true' }
            Should -Invoke -CommandName Add-Content -Times 1 -Exactly -ParameterFilter { (@($LiteralPath) -join '') -ceq '/synthetic/summary' -and (@($Value) -join '') -ceq 'Change scope: code=true; reason=EMPTY_DIFF; base=none' } -Because 'the decision is published to the step output and the job summary'
        }

        It 'default writer prefixes Warning text with ::warning:: on the information stream (AC-16)' {
            Mock -CommandName Write-Information

            Write-CiChangeScopeTarget -Target 'Warning' -Text 'Change scope failed closed: boom'

            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData).StartsWith('::warning::', [StringComparison]::Ordinal) } -Because 'GitHub Actions turns a ::warning:: line into an annotation'
        }

        It 'reads the committed allowlist when no ConfigJson is supplied (AC-15)' {
            $state = Get-TestScenario

            $result = Invoke-TestScenario -State $state -OmitConfigJson

            $result.Code | Should -BeExactly 'false' -Because 'the committed allowlist accepts the standard docs-only diff'
        }

        It 'uses the default writer when no OutputWriter is supplied (AC-1)' {
            Mock -CommandName Add-Content
            Mock -CommandName Write-Information
            $state = Get-TestScenario
            $state.Context.EventName = 'merge_group'

            $result = Invoke-TestScenario -State $state -UseDefaultWriter

            $result.Code | Should -BeExactly 'true'
            $state.Writes.Count | Should -Be 0
            Should -Invoke -CommandName Write-Information -ParameterFilter { ([string]$MessageData).Contains('code=true reason=EVENT_NOT_PULL_REQUEST') } -Because 'the default writer logs the decision on the information stream'
        }

        It 'default writer sends Output text to the information stream when GITHUB_OUTPUT is unset (AC-11)' {
            Mock -CommandName Add-Content
            Mock -CommandName Write-Information

            Write-CiChangeScopeTarget -Target 'Output' -Text 'code=true' -ReadVariable { $null }

            Should -Invoke -CommandName Add-Content -Times 0 -Exactly
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq '[Output] code=true' } -Because 'without GITHUB_OUTPUT the text is shown on the information stream'
        }
    }
}
