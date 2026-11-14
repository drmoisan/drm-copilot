Set-StrictMode -Version Latest

# Unit suite for the CI Required Gate entry script scripts/ci/Invoke-CiRequiredGate.ps1 (issue #1074).
#
# The entry script is dot-sourced, so its dot-source guard skips the CI entry point and the functions are
# available to the cases. The environment read and the summary writes go through test-local fakes passed
# as -ReadVariable and -OutputWriter, which record their calls in memory; the real NEEDS_JSON and
# GITHUB_STEP_SUMMARY variables are never read or written. The mocks are Add-Content and Write-Information
# for the default target writer, Get-CiRequiredGateDecision for the fail-closed case, and the environment
# wrapper Get-CiRequiredGateVariable for the default-seam cases.
# No process, temporary file, or network call is made.

Describe 'Invoke-CiRequiredGate.ps1 entry script' {
    BeforeAll {
        $script:EntryPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Invoke-CiRequiredGate.ps1'
        if (-not (Test-Path -LiteralPath $script:EntryPath)) {
            throw "The entry script under test does not exist: $script:EntryPath"
        }
        . $script:EntryPath

        $jobs = @('build-check', 'changes', 'docs-validation', 'drm-copilot-extension-tests', 'full-run-marker', 'npm-audit-gate', 'poshqc', 'quality-checks7', 'root-typescript-tests', 'security-scan', 'shell-coverage')
        $needs = [ordered]@{}
        foreach ($job in $jobs) { $needs[$job] = [ordered]@{ result = 'success'; outputs = [ordered]@{} } }
        $needs['changes']['outputs']['code'] = 'true'
        $script:PassingNeedsJson = ConvertTo-Json -InputObject $needs -Depth 5 -Compress
    }

    Context 'seams' {
        It 'IG01-READS-NEEDS-JSON-THROUGH-SEAM reads exactly NEEDS_JSON through the injected reader (AC-16)' {
            $names = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $Name) $names.Add($Name); '{"changes":{}}' }.GetNewClosure()

            $value = Get-CiRequiredGateNeedsJson -ReadVariable $reader

            $value | Should -BeExactly '{"changes":{}}'
            ($names -join ',') | Should -BeExactly 'NEEDS_JSON' -Because 'the entry reads only NEEDS_JSON, and only through the seam'
        }

        It 'IG01-READS-NEEDS-JSON-THROUGH-SEAM returns an empty string when the reader returns nothing' {
            $value = Get-CiRequiredGateNeedsJson -ReadVariable { $null }

            $value | Should -BeExactly '' -Because 'an unset variable becomes blank text, which the decision treats as a configuration error'
        }

        It 'IG02-WRITES-SUMMARY-THROUGH-WRITER sends the summary to the Summary and Log targets (AC-16)' {
            $writes = [System.Collections.Generic.List[object]]::new()
            $writer = { param([string] $Target, [string] $Text) $writes.Add([pscustomobject]@{ Target = $Target; Text = $Text }) }.GetNewClosure()

            $decision = Invoke-CiRequiredGate -NeedsJson $script:PassingNeedsJson -OutputWriter $writer

            $decision.Passed | Should -BeTrue
            (@($writes | ForEach-Object { $_.Target }) -join ',') | Should -BeExactly 'Summary,Log'
            $writes[0].Text | Should -BeExactly $decision.SummaryText
            $writes[1].Text | Should -BeExactly $decision.SummaryText -Because 'the log carries the same table so it can be read from the job log'
        }
    }

    Context 'exit code and guard' {
        It 'IG03-EXIT-CODE-MAPPING maps <Label> to exit code <Expected> (AC-17)' -ForEach @(
            @{ Label = 'Passed true'; Decision = [pscustomobject]@{ Passed = $true }; Expected = 0 }
            @{ Label = 'Passed false'; Decision = [pscustomobject]@{ Passed = $false }; Expected = 1 }
            @{ Label = 'Passed null'; Decision = [pscustomobject]@{ Passed = $null }; Expected = 1 }
            @{ Label = 'Passed as the string true'; Decision = [pscustomobject]@{ Passed = 'true' }; Expected = 1 }
            @{ Label = 'a missing Passed property'; Decision = [pscustomobject]@{ Scope = 'full' }; Expected = 1 }
            @{ Label = 'a null decision'; Decision = $null; Expected = 1 }
        ) {
            Get-CiRequiredGateExitCode -Decision $Decision | Should -Be $Expected
        }

        It 'IG04-DOT-SOURCE-GUARD defines the four functions without running the entry point (AC-17)' {
            $names = @('Write-CiRequiredGateTarget', 'Get-CiRequiredGateNeedsJson', 'Invoke-CiRequiredGate', 'Get-CiRequiredGateExitCode')

            $missing = @($names | Where-Object { $null -eq (Get-Command -Name $_ -CommandType Function -ErrorAction SilentlyContinue) })

            ($missing -join ',') | Should -BeExactly '' -Because 'dot-sourcing the script defines its functions and does not exit'
        }

        It 'IG04-DOT-SOURCE-GUARD ends the guarded entry point with explicit exit 0 and exit 1 (AC-17)' {
            $scriptText = (Get-Content -Raw -LiteralPath $script:EntryPath) -replace "`r`n", "`n"
            $guardLine = 'if ($MyInvocation.InvocationName -ne ''.'') {'

            $guardIndex = $scriptText.IndexOf($guardLine, [StringComparison]::Ordinal)

            $guardIndex | Should -BeGreaterThan 0 -Because 'the entry point must not run when the script is dot-sourced'
            $guardBlock = $scriptText.Substring($guardIndex)
            $guardBlock | Should -Match '(?m)^ +exit 0[ \t]*$'
            $guardBlock | Should -Match '(?m)^ +exit 1[ \t]*$'
            $guardBlock.TrimEnd() | Should -Match '\}$' -Because 'the guard block is the last statement of the script'
        }
    }

    Context 'fail-closed envelope and default target writer' {
        It 'IG05-UNEXPECTED-ERROR-FAILS-CLOSED turns a decision exception into a failed decision' {
            Mock -CommandName Get-CiRequiredGateDecision -MockWith { throw 'synthetic decision failure' }
            $writes = [System.Collections.Generic.List[object]]::new()
            $writer = { param([string] $Target, [string] $Text) $writes.Add([pscustomobject]@{ Target = $Target; Text = $Text }) }.GetNewClosure()

            $decision = Invoke-CiRequiredGate -NeedsJson $script:PassingNeedsJson -OutputWriter $writer

            $decision.Passed | Should -BeFalse -Because 'an unexpected failure must never report a green gate'
            ($decision.SummaryText -split "`n")[-1] | Should -BeExactly 'Verdict: FAIL (unexpected error: synthetic decision failure)'
            $writes.Count | Should -Be 2
            Get-CiRequiredGateExitCode -Decision $decision | Should -Be 1
        }

        It 'IG06-BLANK-SUMMARY-PATH-WRITES-INFORMATION shows the summary on the information stream when GITHUB_STEP_SUMMARY is blank' {
            Mock -CommandName Add-Content
            Mock -CommandName Write-Information

            Write-CiRequiredGateTarget -Target 'Summary' -Text 'gate table' -ReadVariable { '' }

            Should -Invoke -CommandName Add-Content -Times 0 -Exactly -Because 'no file is written without a summary path'
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq '[Summary] gate table' }
        }

        It 'IG06-BLANK-SUMMARY-PATH-WRITES-INFORMATION appends the summary to the path that the reader returns' {
            Mock -CommandName Add-Content
            $names = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $Name) $names.Add($Name); '/synthetic/summary' }.GetNewClosure()

            Write-CiRequiredGateTarget -Target 'Summary' -Text 'gate table' -ReadVariable $reader

            ($names -join ',') | Should -BeExactly 'GITHUB_STEP_SUMMARY'
            Should -Invoke -CommandName Add-Content -Times 1 -Exactly -ParameterFilter { (@($LiteralPath) -join '') -ceq '/synthetic/summary' -and (@($Value) -join '') -ceq 'gate table' }
        }

        It 'IG06-BLANK-SUMMARY-PATH-WRITES-INFORMATION writes Log text to the information stream without reading a variable' {
            Mock -CommandName Write-Information
            $names = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $Name) $names.Add($Name); '/synthetic/summary' }.GetNewClosure()

            Write-CiRequiredGateTarget -Target 'Log' -Text 'gate table' -ReadVariable $reader

            $names.Count | Should -Be 0
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq 'gate table' }
        }
    }

    Context 'default seams through the mocked environment wrapper' {
        It 'IG07-DEFAULT-SEAMS-USE-ENVIRONMENT-WRAPPER returns null for a variable name that no process sets' {
            # A fixed, issue-specific name keeps the real NEEDS_JSON and GITHUB_STEP_SUMMARY values out of the test.
            $value = Get-CiRequiredGateVariable -Name 'ISSUE_1074_TEST_VARIABLE_NEVER_SET_7F3A'

            $value | Should -BeNullOrEmpty
        }

        It 'IG07-DEFAULT-SEAMS-USE-ENVIRONMENT-WRAPPER returns <Expected> and publishes the summary when NEEDS_JSON is <Label>' -ForEach @(
            @{ Label = 'a passing needs object'; Passing = $true; Expected = 0; VerdictLine = 'Verdict: PASS' }
            @{ Label = 'blank'; Passing = $false; Expected = 1; VerdictLine = 'Verdict: FAIL (configuration error: NEEDS_JSON is blank)' }
        ) {
            # The wrapper is the only environment boundary; mocking it keeps the real variables untouched.
            $needsValue = ''
            if ($Passing) { $needsValue = $script:PassingNeedsJson }
            Mock -CommandName Get-CiRequiredGateVariable -MockWith { $needsValue } -ParameterFilter { $Name -ceq 'NEEDS_JSON' }
            Mock -CommandName Get-CiRequiredGateVariable -MockWith { '' } -ParameterFilter { $Name -ceq 'GITHUB_STEP_SUMMARY' }
            Mock -CommandName Add-Content
            Mock -CommandName Write-Information

            $exitCode = Invoke-CiRequiredGateEntry

            $exitCode | Should -Be $Expected
            Should -Invoke -CommandName Get-CiRequiredGateVariable -Times 1 -Exactly -ParameterFilter { $Name -ceq 'NEEDS_JSON' }
            Should -Invoke -CommandName Get-CiRequiredGateVariable -Times 1 -Exactly -ParameterFilter { $Name -ceq 'GITHUB_STEP_SUMMARY' }
            Should -Invoke -CommandName Add-Content -Times 0 -Exactly
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData).StartsWith('[Summary] CI Required Gate:', [StringComparison]::Ordinal) -and ([string]$MessageData).EndsWith($VerdictLine, [StringComparison]::Ordinal) }
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData).StartsWith('CI Required Gate:', [StringComparison]::Ordinal) } -Because 'the Log target carries the same summary'
        }
    }
}
