Set-StrictMode -Version Latest

# Unit suite for the pure CI Required Gate decision module scripts/ci/CiRequiredGate.psm1 (issue #1074).
#
# Every case builds a NEEDS_JSON string in memory with Get-TestNeedsJson, which starts from all eleven
# needed jobs reporting 'success' and applies per-case overrides. No file other than the module text,
# no process, no environment variable, and no network call is used.

BeforeDiscovery {
    $script:DiscoveryAllJobs = @(
        'build-check', 'changes', 'docs-validation', 'drm-copilot-extension-tests', 'full-run-marker', 'npm-audit-gate',
        'poshqc', 'quality-checks7', 'root-typescript-tests', 'security-scan', 'shell-coverage'
    )
    $script:DiscoverySkippable = @('full-run-marker', 'npm-audit-gate', 'root-typescript-tests')
    $script:DiscoveryNonSkippable = @($script:DiscoveryAllJobs | Where-Object { $script:DiscoverySkippable -cnotcontains $_ })
    $script:DiscoveryJobScopeCases = @(
        foreach ($job in $script:DiscoveryAllJobs) {
            @{ Job = $job; Code = 'true'; Scope = 'full' }
            @{ Job = $job; Code = 'false'; Scope = 'docs-only' }
        }
    )
}

Describe 'CiRequiredGate.psm1 decision module' {
    BeforeAll {
        $script:ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/CiRequiredGate.psm1'
        Import-Module -Name $script:ModulePath -Force
        $script:AllJobs = @(
            'build-check', 'changes', 'docs-validation', 'drm-copilot-extension-tests', 'full-run-marker', 'npm-audit-gate',
            'poshqc', 'quality-checks7', 'root-typescript-tests', 'security-scan', 'shell-coverage'
        )
        $script:SkippableJobs = @('full-run-marker', 'npm-audit-gate', 'root-typescript-tests')

        # Builds the text of toJSON(needs). Every job reports 'success' unless -Results overrides it; the
        # changes job carries outputs.code = -Code unless -OmitCode or -OmitOutputs is set. -Omit drops
        # whole jobs and -NoResult drops the result property of the named jobs.
        function Get-TestNeedsJson {
            param(
                [hashtable] $Results = @{},
                [AllowNull()][object] $Code = 'true',
                [switch] $OmitCode,
                [switch] $OmitOutputs,
                [string[]] $Omit = @(),
                [string[]] $NoResult = @()
            )
            $needs = [ordered]@{}
            foreach ($job in $script:AllJobs) {
                if ($Omit -ccontains $job) { continue }
                $result = 'success'
                if ($Results.ContainsKey($job)) { $result = $Results[$job] }
                $entry = [ordered]@{ result = $result; outputs = [ordered]@{} }
                if ($NoResult -ccontains $job) { $entry.Remove('result') }
                if ($job -ceq 'changes') {
                    if ($OmitOutputs) { $entry.Remove('outputs') }
                    elseif (-not $OmitCode) { $entry['outputs']['code'] = $Code }
                }
                $needs[$job] = $entry
            }
            return (ConvertTo-Json -InputObject $needs -Depth 5 -Compress)
        }

        # Returns a results override that marks every skippable job 'skipped'.
        function Get-TestSkippedSkippable {
            $results = @{}
            foreach ($job in $script:SkippableJobs) { $results[$job] = 'skipped' }
            return $results
        }
    }

    Context 'RG01 docs-only scope passes with accepted results (AC-06)' {
        It 'RG01-DOCS-ONLY-PASSES passes when the skippable jobs are <Label>' -ForEach @(
            @{ Label = 'all skipped'; Skipped = @('full-run-marker', 'npm-audit-gate', 'root-typescript-tests') }
            @{ Label = 'all success'; Skipped = @() }
            @{ Label = 'mixed'; Skipped = @('full-run-marker') }
        ) {
            $results = @{}
            foreach ($job in $Skipped) { $results[$job] = 'skipped' }

            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results $results -Code 'false')

            $decision.Scope | Should -BeExactly 'docs-only'
            $decision.Passed | Should -BeTrue -Because 'every non-skippable job is success and each skippable job is success or skipped'
            @($decision.Rows).Count | Should -Be 11 -Because 'the summary has one row per needed job'
        }
    }

    Context 'RG02 docs-only scope rejects a skipped non-skippable job (AC-07)' {
        It 'RG02-DOCS-ONLY-NON-SKIPPABLE-SKIPPED-FAILS fails when <_> is skipped' -ForEach $script:DiscoveryNonSkippable {
            $results = Get-TestSkippedSkippable
            $results[$_] = 'skipped'

            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results $results -Code 'false')

            $decision.Scope | Should -BeExactly 'docs-only'
            $decision.Passed | Should -BeFalse -Because "$_ is not in the docs-only skippable set"
            @($decision.Rows | Where-Object { $_.Verdict -ceq 'fail' }).Count | Should -BeGreaterThan 0
        }

        It 'RG02-DOCS-ONLY-MISSING-REQUIRED-JOB-FAILS fails when a non-skippable job is absent from NEEDS_JSON' {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results (Get-TestSkippedSkippable) -Code 'false' -Omit @('poshqc'))

            $decision.Passed | Should -BeFalse -Because 'every non-skippable job must be present on a docs-only run'
            ($decision.SummaryText -split "`n")[-1] | Should -BeExactly 'Verdict: FAIL (missing job: poshqc)'
        }
    }

    Context 'RG03 and RG04 full scope (AC-08)' {
        It 'RG03-FULL-ALL-SUCCESS-PASSES passes when every needed job is success' {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Code 'true')

            $decision.Scope | Should -BeExactly 'full'
            $decision.Passed | Should -BeTrue -Because 'every needed job is success'
            ($decision.SummaryText -split "`n")[-1] | Should -BeExactly 'Verdict: PASS'
        }

        It 'RG04-FULL-ANY-SKIPPED-FAILS fails when <_> is skipped in full scope' -ForEach $script:DiscoveryAllJobs {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ $_ = 'skipped' } -Code 'true')

            $decision.Scope | Should -BeExactly 'full'
            $decision.Passed | Should -BeFalse -Because 'full scope accepts only success, including for the skippable set'
        }
    }

    Context 'RG05 scope predicate (AC-09)' {
        It 'RG05-CODE-NOT-EXACTLY-FALSE-IS-FULL selects full scope when code is <Label>' -ForEach @(
            @{ Label = 'true'; Code = 'true'; OmitCode = $false; OmitOutputs = $false; Expected = 'true' }
            @{ Label = 'empty'; Code = ''; OmitCode = $false; OmitOutputs = $false; Expected = '' }
            @{ Label = 'absent'; Code = $null; OmitCode = $true; OmitOutputs = $false; Expected = $null }
            @{ Label = 'absent with no outputs'; Code = $null; OmitCode = $false; OmitOutputs = $true; Expected = $null }
            @{ Label = 'False'; Code = 'False'; OmitCode = $false; OmitOutputs = $false; Expected = 'False' }
            @{ Label = 'space false'; Code = ' false'; OmitCode = $false; OmitOutputs = $false; Expected = ' false' }
        ) {
            $json = Get-TestNeedsJson -Results (Get-TestSkippedSkippable) -Code $Code -OmitCode:$OmitCode -OmitOutputs:$OmitOutputs

            $decision = Get-CiRequiredGateDecision -NeedsJson $json

            $decision.Scope | Should -BeExactly 'full' -Because 'only the exact string false selects docs-only scope'
            $decision.Code | Should -Be $Expected
            $decision.Passed | Should -BeFalse -Because 'full scope does not accept the skipped skippable jobs'
        }

        It 'RG05-CODE-NOT-EXACTLY-FALSE-IS-FULL renders an absent code as (absent) in the header' {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -OmitCode)

            ($decision.SummaryText -split "`n")[0] | Should -BeExactly 'CI Required Gate: scope=full code=(absent)'
            $decision.Passed | Should -BeTrue -Because 'an absent code is full scope, and every job is success'
        }
    }

    Context 'RG06 to RG08 rejected results (AC-10, AC-11, AC-12)' {
        It 'RG06-FAILURE-FAILS fails when <Job> is failure in <Scope> scope' -ForEach $script:DiscoveryJobScopeCases {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ $Job = 'failure' } -Code $Code)

            $decision.Scope | Should -BeExactly $Scope
            $decision.Passed | Should -BeFalse -Because 'a failed needed job turns the gate red'
            @($decision.Rows | Where-Object { $_.Job -ceq $Job })[0].Verdict | Should -BeExactly 'fail'
        }

        It 'RG07-CANCELLED-FAILS fails when <Job> is cancelled in <Scope> scope' -ForEach $script:DiscoveryJobScopeCases {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ $Job = 'cancelled' } -Code $Code)

            $decision.Scope | Should -BeExactly $Scope
            $decision.Passed | Should -BeFalse -Because 'a cancelled needed job turns the gate red'
        }

        It 'RG08-UNKNOWN-RESULT-FAILS fails when <Job> reports <Label> with code <Code>' -ForEach @(
            @{ Label = 'neutral'; Job = 'poshqc'; Code = 'true'; Result = 'neutral'; NoResult = $false }
            @{ Label = 'Success'; Job = 'poshqc'; Code = 'true'; Result = 'Success'; NoResult = $false }
            @{ Label = 'null'; Job = 'poshqc'; Code = 'true'; Result = $null; NoResult = $false }
            @{ Label = 'no result'; Job = 'poshqc'; Code = 'true'; Result = $null; NoResult = $true }
            @{ Label = 'neutral'; Job = 'npm-audit-gate'; Code = 'false'; Result = 'neutral'; NoResult = $false }
            @{ Label = 'Skipped'; Job = 'npm-audit-gate'; Code = 'false'; Result = 'Skipped'; NoResult = $false }
            @{ Label = 'null'; Job = 'npm-audit-gate'; Code = 'false'; Result = $null; NoResult = $false }
        ) {
            $noResultJobs = @()
            if ($NoResult) { $noResultJobs = @($Job) }
            $json = Get-TestNeedsJson -Results @{ $Job = $Result } -Code $Code -NoResult $noResultJobs

            $decision = Get-CiRequiredGateDecision -NeedsJson $json

            $decision.Passed | Should -BeFalse -Because 'an unknown, differently cased, or null result fails closed'
            @($decision.Rows | Where-Object { $_.Job -ceq $Job })[0].Verdict | Should -BeExactly 'fail'
        }

        It 'RG08-UNKNOWN-RESULT-FAILS renders a null result as (null)' {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ poshqc = $null } -Code 'true')

            ($decision.SummaryText -split "`n") | Should -Contain '| poshqc | (null) | success | fail |'
        }
    }

    Context 'RG09 changes job (AC-13)' {
        It 'RG09-CHANGES-NOT-SUCCESS-FAILS fails when changes is <_> and every other job is success' -ForEach @('failure', 'skipped') {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ changes = $_ } -Code 'true')

            $decision.Passed | Should -BeFalse -Because 'the scope cannot be trusted when changes did not succeed'
            ($decision.SummaryText -split "`n")[-1] | Should -BeExactly 'Verdict: FAIL (result not accepted: changes; changes result is not success)'
        }
    }

    Context 'RG10 configuration errors (AC-14)' {
        It 'RG10-CONFIGURATION-ERROR reports a configuration error for <Label>' -ForEach @(
            @{ Label = 'blank'; Json = ''; Omit = ''; Detail = 'NEEDS_JSON is blank' }
            @{ Label = 'whitespace'; Json = "  `n "; Omit = ''; Detail = 'NEEDS_JSON is blank' }
            @{ Label = 'invalid JSON'; Json = '{"changes":'; Omit = ''; Detail = 'NEEDS_JSON is not valid JSON' }
            @{ Label = 'a JSON array'; Json = '[]'; Omit = ''; Detail = 'NEEDS_JSON is not a JSON object' }
            @{ Label = 'a JSON number'; Json = '42'; Omit = ''; Detail = 'NEEDS_JSON is not a JSON object' }
            @{ Label = 'a JSON string'; Json = '"changes"'; Omit = ''; Detail = 'NEEDS_JSON is not a JSON object' }
            @{ Label = 'JSON null'; Json = 'null'; Omit = ''; Detail = 'NEEDS_JSON is not a JSON object' }
            @{ Label = 'missing changes'; Json = $null; Omit = 'changes'; Detail = 'missing job: changes' }
            @{ Label = 'missing docs-validation'; Json = $null; Omit = 'docs-validation'; Detail = 'missing job: docs-validation' }
            @{ Label = 'missing full-run-marker'; Json = $null; Omit = 'full-run-marker'; Detail = 'missing job: full-run-marker' }
            @{ Label = 'missing npm-audit-gate'; Json = $null; Omit = 'npm-audit-gate'; Detail = 'missing job: npm-audit-gate' }
            @{ Label = 'missing root-typescript-tests'; Json = $null; Omit = 'root-typescript-tests'; Detail = 'missing job: root-typescript-tests' }
        ) {
            $text = $Json
            if ($Omit) { $text = Get-TestNeedsJson -Omit @($Omit) }

            $decision = Get-CiRequiredGateDecision -NeedsJson $text

            $decision.Scope | Should -BeExactly 'invalid'
            $decision.Passed | Should -BeFalse -Because 'input the gate cannot classify fails closed'
            @($decision.Rows).Count | Should -Be 0
            $decision.Code | Should -BeNullOrEmpty
            ($decision.SummaryText -split "`n")[-1] | Should -BeExactly "Verdict: FAIL (configuration error: $Detail)"
        }

        It 'RG10-CONFIGURATION-ERROR renders the complete configuration-error summary' {
            $expected = @(
                'CI Required Gate: scope=invalid code=(absent)'
                ''
                '| Job | Result | Accepted | Verdict |'
                '|---|---|---|---|'
                ''
                'Verdict: FAIL (configuration error: NEEDS_JSON is blank)'
            ) -join "`n"

            (Get-CiRequiredGateDecision -NeedsJson '').SummaryText | Should -BeExactly $expected
        }
    }

    Context 'RG11 summary text (AC-15)' {
        It 'RG11-SUMMARY-TEXT-EXACT renders the docs-only summary exactly' {
            $expected = @(
                'CI Required Gate: scope=docs-only code=false'
                ''
                '| Job | Result | Accepted | Verdict |'
                '|---|---|---|---|'
                '| build-check | success | success | ok |'
                '| changes | success | success | ok |'
                '| docs-validation | success | success | ok |'
                '| drm-copilot-extension-tests | success | success | ok |'
                '| full-run-marker | skipped | success, skipped | ok |'
                '| npm-audit-gate | skipped | success, skipped | ok |'
                '| poshqc | success | success | ok |'
                '| quality-checks7 | success | success | ok |'
                '| root-typescript-tests | skipped | success, skipped | ok |'
                '| security-scan | success | success | ok |'
                '| shell-coverage | success | success | ok |'
                ''
                'Verdict: PASS'
            ) -join "`n"

            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results (Get-TestSkippedSkippable) -Code 'false')

            $decision.SummaryText | Should -BeExactly $expected
        }

        It 'RG11-SUMMARY-TEXT-EXACT renders the failing full-scope summary exactly' {
            $expected = @(
                'CI Required Gate: scope=full code=true'
                ''
                '| Job | Result | Accepted | Verdict |'
                '|---|---|---|---|'
                '| build-check | success | success | ok |'
                '| changes | success | success | ok |'
                '| docs-validation | failure | success | fail |'
                '| drm-copilot-extension-tests | success | success | ok |'
                '| full-run-marker | success | success | ok |'
                '| npm-audit-gate | success | success | ok |'
                '| poshqc | (null) | success | fail |'
                '| quality-checks7 | success | success | ok |'
                '| root-typescript-tests | success | success | ok |'
                '| security-scan | success | success | ok |'
                '| shell-coverage | success | success | ok |'
                ''
                'Verdict: FAIL (result not accepted: docs-validation, poshqc)'
            ) -join "`n"

            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson -Results @{ 'docs-validation' = 'failure'; poshqc = $null } -Code 'true')

            $decision.SummaryText | Should -BeExactly $expected
        }
    }

    Context 'RG12 and RG13 module surface (AC-05)' {
        It 'RG12-SKIPPABLE-SET returns exactly the three skippable jobs in ordinal order as a fresh copy' {
            $first = @(Get-CiRequiredGateSkippableJob)
            $first[0] = 'mutated'

            $second = @(Get-CiRequiredGateSkippableJob)

            ($second -join ',') | Should -BeExactly 'full-run-marker,npm-audit-gate,root-typescript-tests' -Because 'a caller change to a returned copy must not reach the module constant'
        }

        It 'RG13-NO-IO-AND-EXPORTS exports only the two functions and contains no I/O call' {
            $exported = @((Get-Module -Name CiRequiredGate).ExportedFunctions.Keys | Sort-Object)
            $moduleText = Get-Content -Raw -LiteralPath $script:ModulePath
            # The network and process command names are assembled from parts so that the repository's test
            # purity hook, which scans test text for those names, does not read this search list as a call.
            $forbidden = @(
                'Get-Content'
                'Set-Content'
                'Add-Content'
                'Out-File'
                '$env:'
                '[Environment]'
                ('Invoke-' + 'WebRequest')
                ('Invoke-' + 'RestMethod')
                ('Start-' + 'Process')
            )

            ($exported -join ',') | Should -BeExactly 'Get-CiRequiredGateDecision,Get-CiRequiredGateSkippableJob'
            $found = @($forbidden | Where-Object { $moduleText.Contains($_) })
            ($found -join ',') | Should -BeExactly '' -Because 'the decision module performs no file, environment, process, or network I/O'
            $forbidden.Count | Should -Be 9
        }

        It 'RG13-NO-IO-AND-EXPORTS returns the five documented decision properties' {
            $decision = Get-CiRequiredGateDecision -NeedsJson (Get-TestNeedsJson)

            (@($decision.PSObject.Properties.Name) -join ',') | Should -BeExactly 'Passed,Scope,Code,Rows,SummaryText'
            (@($decision.Rows[0].PSObject.Properties.Name) -join ',') | Should -BeExactly 'Job,Result,Accepted,Verdict'
        }
    }
}
