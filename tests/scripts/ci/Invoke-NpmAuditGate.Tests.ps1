Set-StrictMode -Version Latest

# Unit suite for the npm audit gate entry script scripts/ci/Invoke-NpmAuditGate.ps1 (issue #1204).
#
# The entry script is dot-sourced, so its dot-source guard skips the CI entry point and the functions are
# available to the cases. The file read, the clock, and the output writer are test-local fakes passed as
# -ReadFile, -GetUtcDate, and -OutputWriter. The npm wrapper Invoke-NpmAuditExe is mocked with the same
# NpmArgs parameter name as production, so no npm process starts; the other default-seam helpers
# (Get-NpmAuditGateFileText, Get-NpmAuditGateUtcDate, Write-NpmAuditGateTarget, Get-NpmAuditGateVariable)
# are mocked where the default path is exercised. No temporary file or network call is made.

BeforeDiscovery {
    $script:ExitCases = @(
        @{ Code = 'NPM_AUDIT_EXCEPTION_INVALID'; Exceptions = '{'; Date = '2026-11-20'; ProdExit = 0; Full = 'NONE' }
        @{ Code = 'NPM_AUDIT_EXCEPTION_EXPIRED'; Exceptions = 'VALID'; Date = '2026-12-19'; ProdExit = 0; Full = 'NONE' }
        @{ Code = 'NPM_AUDIT_PROD_FINDING'; Exceptions = 'VALID'; Date = '2026-11-20'; ProdExit = 1; Full = 'NONE' }
        @{ Code = 'NPM_AUDIT_UNEXCEPTED_ADVISORY'; Exceptions = 'VALID'; Date = '2026-11-20'; ProdExit = 0; Full = 'OTHER' }
        @{ Code = 'NPM_AUDIT_OUTPUT_UNPARSEABLE'; Exceptions = 'VALID'; Date = '2026-11-20'; ProdExit = 0; Full = 'JUNK' }
    )
}

Describe 'Invoke-NpmAuditGate.ps1 entry script' {
    BeforeAll {
        $script:EntryPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Invoke-NpmAuditGate.ps1'
        if (-not (Test-Path -LiteralPath $script:EntryPath)) {
            throw "The entry script under test does not exist: $script:EntryPath"
        }
        . $script:EntryPath

        $script:ValidExceptions = '{"version":1,"exceptions":[{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","reason":"no patched version exists","approved_at":"2026-11-18","expires":"2026-12-18"}]}'
        $viaPicomatch = [ordered]@{ source = 1; name = 'picomatch'; url = 'https://github.com/advisories/GHSA-fc5q-39xc-vjpf'; severity = 'high' }
        $viaOther = [ordered]@{ source = 2; name = 'otherpkg'; url = 'https://github.com/advisories/GHSA-aaaa-bbbb-cccc'; severity = 'high' }
        $script:PicomatchAudit = ConvertTo-Json -InputObject ([ordered]@{ vulnerabilities = [ordered]@{ picomatch = [ordered]@{ name = 'picomatch'; severity = 'high'; via = @($viaPicomatch) } } }) -Depth 8 -Compress
        $script:OtherAudit = ConvertTo-Json -InputObject ([ordered]@{ vulnerabilities = [ordered]@{ otherpkg = [ordered]@{ name = 'otherpkg'; severity = 'high'; via = @($viaOther) } } }) -Depth 8 -Compress

        # Per-test fake npm results; the mock below picks one by whether the call is the --json call.
        $script:FakeProduction = [pscustomobject]@{ ExitCode = 0; StdOut = 'found 0 vulnerabilities' }
        $script:FakeFull = [pscustomobject]@{ ExitCode = 1; StdOut = $script:PicomatchAudit }

        # Runs Invoke-NpmAuditGate with in-memory seams and returns the decision and the recorded writes.
        $script:RunGate = {
            param([string] $AuditLevel = 'moderate', [string] $ExceptionsText = $script:ValidExceptions, [string] $Date = '2026-11-20', [scriptblock] $GetUtcDate = $null)
            $script:Writes = [System.Collections.Generic.List[object]]::new()
            $reader = { param([string] $Path) $script:ReadPaths.Add($Path); $script:ExceptionsText }
            $script:ReadPaths = [System.Collections.Generic.List[string]]::new()
            $script:ExceptionsText = $ExceptionsText
            $clock = { $script:FakeDate }
            if ($null -ne $GetUtcDate) { $clock = $GetUtcDate }
            $script:FakeDate = $Date
            $writer = { param([string] $Target, [string] $Text) $script:Writes.Add([pscustomobject]@{ Target = $Target; Text = $Text }) }
            return Invoke-NpmAuditGate -AuditLevel $AuditLevel -ExceptionsPath 'config/npm-audit-exceptions.json' -ReadFile $reader -GetUtcDate $clock -OutputWriter $writer
        }
    }

    BeforeEach {
        $script:FakeProduction = [pscustomobject]@{ ExitCode = 0; StdOut = 'found 0 vulnerabilities' }
        $script:FakeFull = [pscustomobject]@{ ExitCode = 1; StdOut = $script:PicomatchAudit }
        Mock -CommandName Invoke-NpmAuditExe -MockWith {
            param([string[]] $NpmArgs)
            if ($NpmArgs -contains '--json') { return $script:FakeFull }
            return $script:FakeProduction
        }
    }

    Context 'exit codes' {
        It 'INA-EXIT-0-PASS exits 0 when the only advisory is excepted and production is clean' {
            $decision = & $script:RunGate

            $decision.Passed | Should -BeTrue
            Get-NpmAuditGateExitCode -Decision $decision | Should -Be 0
            $script:ReadPaths[0] | Should -BeExactly 'config/npm-audit-exceptions.json'
        }

        It 'INA-EXIT-1-FOR-EACH-CODE exits 1 and prints <Code>' -ForEach $script:ExitCases {
            $exceptions = if ($Exceptions -ceq 'VALID') { $script:ValidExceptions } else { $Exceptions }
            $script:FakeProduction = [pscustomobject]@{ ExitCode = $ProdExit; StdOut = 'production output' }
            $script:FakeFull = [pscustomobject]@{ ExitCode = 1; StdOut = $(switch ($Full) { 'OTHER' { $script:OtherAudit } 'JUNK' { 'not json' } default { $script:PicomatchAudit } }) }

            $decision = & $script:RunGate -ExceptionsText $exceptions -Date $Date

            $decision.Passed | Should -BeFalse
            $decision.Code | Should -BeExactly $Code
            Get-NpmAuditGateExitCode -Decision $decision | Should -Be 1
            @($script:Writes | Where-Object { $_.Target -ceq 'Log' -and $_.Text -like "*$Code*" }).Count | Should -BeGreaterThan 0 -Because 'the failure code must appear in the job log'
        }

        It 'INA-EXIT-1-FOR-EACH-CODE maps a missing, null, or non-boolean Passed value to exit code 1' -ForEach @(
            @{ Decision = $null }
            @{ Decision = [pscustomobject]@{ Passed = 'true' } }
            @{ Decision = [pscustomobject]@{ Scope = 'x' } }
        ) {
            Get-NpmAuditGateExitCode -Decision $Decision | Should -Be 1
        }
    }

    Context 'npm calls' {
        It 'INA-NPM-ARGS passes the audit level unchanged to the production call and runs the full call as audit --json' {
            $null = & $script:RunGate -AuditLevel 'high'

            Should -Invoke -CommandName Invoke-NpmAuditExe -Times 1 -Exactly -ParameterFilter { (@($NpmArgs) -join ' ') -ceq 'audit --omit=dev --audit-level=high' }
            Should -Invoke -CommandName Invoke-NpmAuditExe -Times 1 -Exactly -ParameterFilter { (@($NpmArgs) -join ' ') -ceq 'audit --json' }
            Should -Invoke -CommandName Invoke-NpmAuditExe -Times 2 -Exactly
        }

        It 'INA-NPM-ARGS never omits dev dependencies from the full call' {
            $null = & $script:RunGate

            Should -Invoke -CommandName Invoke-NpmAuditExe -Times 0 -Exactly -ParameterFilter { ($NpmArgs -contains '--json') -and (@($NpmArgs | Where-Object { $_ -like '--omit*' }).Count -gt 0) }
        }

        It 'INA-NPM-ARGS splits standard error lines from standard output' {
            $records = @('{"a":1}', [System.Management.Automation.ErrorRecord]::new([System.Exception]::new('npm warn config'), 'warn', 'NotSpecified', $null), '{"b":2}')

            $streams = Split-NpmAuditRecord -Record $records

            $streams.StdOut | Should -BeExactly "{`"a`":1}`n{`"b`":2}"
            @($streams.StdErr) | Should -Be @('npm warn config')
        }

        It 'INA-NPM-ARGS builds the wrapper result with the exit code, the standard output, and the standard error logged' {
            Mock -CommandName Write-Information
            $records = @('{"a":1}', [System.Management.Automation.ErrorRecord]::new([System.Exception]::new('npm warn config'), 'warn', 'NotSpecified', $null))

            $result = ConvertTo-NpmAuditExeResult -Record $records -ExitCode 1

            $result.ExitCode | Should -Be 1
            $result.StdOut | Should -BeExactly '{"a":1}'
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq 'npm stderr: npm warn config' }
        }

        It 'INA-NPM-ARGS reports a missing exit code as 1 so a missing code never reads as success' {
            $result = ConvertTo-NpmAuditExeResult -Record @() -ExitCode $null

            $result.ExitCode | Should -Be 1
        }

        It 'INA-NPM-ARGS returns empty streams for no records' {
            $streams = Split-NpmAuditRecord -Record @()

            $streams.StdOut | Should -BeExactly ''
            @($streams.StdErr).Count | Should -Be 0
        }
    }

    Context 'output writer' {
        It 'INA-OUTPUT-WRITER sends the applied exception fields to the Summary and Log targets' {
            $decision = & $script:RunGate

            $summary = @($script:Writes | Where-Object { $_.Target -ceq 'Summary' })
            $summary.Count | Should -Be 1
            $summary[0].Text | Should -BeExactly $decision.SummaryText
            foreach ($field in @('id=GHSA-fc5q-39xc-vjpf', 'package=picomatch', 'approved_at=2026-11-18', 'expires=2026-12-18', 'days_remaining=28', 'reason=no patched version exists')) {
                $summary[0].Text | Should -BeLike "*$field*"
                @($script:Writes | Where-Object { $_.Target -ceq 'Log' -and $_.Text -like "*$field*" }).Count | Should -Be 1 -Because "the log carries $field"
            }
        }

        It 'INA-OUTPUT-WRITER logs the production audit output and both exit codes' {
            $script:FakeProduction = [pscustomobject]@{ ExitCode = 0; StdOut = 'production audit text' }

            $null = & $script:RunGate

            $logText = (@($script:Writes | Where-Object { $_.Target -ceq 'Log' } | ForEach-Object { $_.Text })) -join "`n"
            $logText | Should -BeLike '*npm audit --omit=dev --audit-level=moderate exited 0*production audit text*'
            $logText | Should -BeLike '*npm audit --json exited 1*'
        }

        It 'INA-OUTPUT-WRITER shows the summary on the information stream when GITHUB_STEP_SUMMARY is blank' {
            Mock -CommandName Add-Content
            Mock -CommandName Write-Information

            Write-NpmAuditGateTarget -Target 'Summary' -Text 'gate text' -ReadVariable { '' }

            Should -Invoke -CommandName Add-Content -Times 0 -Exactly
            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq '[Summary] gate text' }
        }

        It 'INA-OUTPUT-WRITER reads GITHUB_STEP_SUMMARY through the default environment wrapper' {
            Mock -CommandName Get-NpmAuditGateVariable -MockWith { '' }
            Mock -CommandName Write-Information

            Write-NpmAuditGateTarget -Target 'Summary' -Text 'gate text'

            Should -Invoke -CommandName Get-NpmAuditGateVariable -Times 1 -Exactly -ParameterFilter { $Name -ceq 'GITHUB_STEP_SUMMARY' }
        }

        It 'INA-OUTPUT-WRITER appends the summary to the path that GITHUB_STEP_SUMMARY names' {
            Mock -CommandName Add-Content
            $names = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $Name) $names.Add($Name); '/synthetic/summary' }.GetNewClosure()

            Write-NpmAuditGateTarget -Target 'Summary' -Text 'gate text' -ReadVariable $reader

            ($names -join ',') | Should -BeExactly 'GITHUB_STEP_SUMMARY'
            Should -Invoke -CommandName Add-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -ceq '/synthetic/summary' -and $Value -ceq 'gate text' }
        }

        It 'INA-OUTPUT-WRITER writes Log text to the information stream' {
            Mock -CommandName Write-Information

            Write-NpmAuditGateTarget -Target 'Log' -Text 'log text'

            Should -Invoke -CommandName Write-Information -Times 1 -Exactly -ParameterFilter { ([string]$MessageData) -ceq 'log text' }
        }

        It 'INA-OUTPUT-WRITER reads an environment variable through the wrapper' {
            Get-NpmAuditGateVariable -Name 'NPM_AUDIT_GATE_SURELY_UNSET_VARIABLE_1204' | Should -BeNullOrEmpty
        }
    }

    Context 'default seams and fail-closed envelope' {
        It 'INA-FAIL-CLOSED-ENVELOPE turns an exception from a seam into a failed decision with exit code 1' {
            $decision = & $script:RunGate -GetUtcDate { throw 'synthetic clock failure' }

            $decision.Passed | Should -BeFalse
            $decision.SummaryText | Should -BeExactly 'NPM Audit Gate: FAIL (unexpected error: synthetic clock failure)'
            Get-NpmAuditGateExitCode -Decision $decision | Should -Be 1
            @($script:Writes | Where-Object { $_.Target -ceq 'Summary' }).Count | Should -Be 1
        }

        It 'INA-FAIL-CLOSED-ENVELOPE reports an unreadable exception file as NPM_AUDIT_EXCEPTION_INVALID' {
            $writes = [System.Collections.Generic.List[object]]::new()
            $writer = { param([string] $Target, [string] $Text) $writes.Add([pscustomobject]@{ Target = $Target; Text = $Text }) }.GetNewClosure()

            $decision = Invoke-NpmAuditGate -ExceptionsPath 'missing.json' -ReadFile { throw 'synthetic read failure' } -GetUtcDate { '2026-11-20' } -OutputWriter $writer

            $decision.Code | Should -BeExactly 'NPM_AUDIT_EXCEPTION_INVALID'
            @($writes | Where-Object { $_.Text -like '*Cannot read the exception file: synthetic read failure*' }).Count | Should -Be 1
        }

        It 'INA-FAIL-CLOSED-ENVELOPE runs the entry function through the default seams and returns the exit code' {
            Mock -CommandName Get-NpmAuditGateFileText -MockWith { $script:ValidExceptions }
            Mock -CommandName Get-NpmAuditGateUtcDate -MockWith { '2026-11-20' }
            Mock -CommandName Write-NpmAuditGateTarget

            Invoke-NpmAuditGateEntry -AuditLevel 'moderate' -ExceptionsPath 'config/npm-audit-exceptions.json' | Should -Be 0

            Should -Invoke -CommandName Get-NpmAuditGateFileText -Times 1 -Exactly -ParameterFilter { $Path -ceq 'config/npm-audit-exceptions.json' }
            Should -Invoke -CommandName Write-NpmAuditGateTarget -Times 1 -Exactly -ParameterFilter { $Target -ceq 'Summary' }
        }

        It 'INA-FAIL-CLOSED-ENVELOPE returns exit code 1 from the entry function when the gate fails' {
            Mock -CommandName Get-NpmAuditGateFileText -MockWith { '{' }
            Mock -CommandName Get-NpmAuditGateUtcDate -MockWith { '2026-11-20' }
            Mock -CommandName Write-NpmAuditGateTarget

            Invoke-NpmAuditGateEntry -ExceptionsPath 'x.json' | Should -Be 1
        }

        It 'INA-FAIL-CLOSED-ENVELOPE reads the clock as a yyyy-MM-dd UTC date' {
            Get-NpmAuditGateUtcDate | Should -Match '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        }

        It 'INA-FAIL-CLOSED-ENVELOPE reads file text through Get-Content with a literal path' {
            Mock -CommandName Get-Content -MockWith { 'synthetic file text' }

            Get-NpmAuditGateFileText -Path '/synthetic/exceptions.json' | Should -BeExactly 'synthetic file text'

            Should -Invoke -CommandName Get-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -ceq '/synthetic/exceptions.json' -and $Raw }
        }
    }

    Context 'dot-source guard' {
        It 'INA-DOT-SOURCE-GUARD defines the functions without running the entry point' {
            $names = @('Get-NpmAuditGateVariable', 'Get-NpmAuditGateFileText', 'Get-NpmAuditGateUtcDate', 'Split-NpmAuditRecord', 'ConvertTo-NpmAuditExeResult', 'Invoke-NpmAuditExe', 'Write-NpmAuditGateTarget', 'Invoke-NpmAuditGate', 'Get-NpmAuditGateExitCode', 'Invoke-NpmAuditGateEntry')

            $missing = @($names | Where-Object { $null -eq (Get-Command -Name $_ -CommandType Function -ErrorAction SilentlyContinue) })

            ($missing -join ',') | Should -BeExactly '' -Because 'dot-sourcing the script defines its functions and does not exit'
        }

        It 'INA-DOT-SOURCE-GUARD ends the guarded entry point with explicit exit 0 and exit 1' {
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
}
