# Phase 1 Exit-Route Probe (issue #897, epic child E1)

Timestamp: 2026-10-11T12-48
Task: [P1-T3]
Command: in-session block, no temporary files and no child process:

```powershell
Import-Module Pester -MinimumVersion 5.0 -Force
$c = New-PesterContainer -ScriptBlock {
    Describe 'exit-route probe' {
        It 'fixture exit 2 ends only the fixture' {
            $fixture = Join-Path (Get-Location).Path 'tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1'
            $savedError = [Console]::Error
            $w = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($w)
                $global:LASTEXITCODE = 0
                $out = @(& $fixture -Message 'PROBE_BLOCK_897')
                $code = $LASTEXITCODE
            }
            finally {
                [Console]::SetError($savedError)
                $global:LASTEXITCODE = 0
            }
            $code | Should -Be 2
            $w.ToString() | Should -Be ('PROBE_BLOCK_897' + [Environment]::NewLine)
            $out.Count | Should -Be 0
        }
        It 'runner continues after the fixture exit' {
            $true | Should -BeTrue
        }
    }
}
$cfg = New-PesterConfiguration; $cfg.Run.Container = $c; $cfg.Run.PassThru = $true; $cfg.Run.Exit = $false; $cfg.Output.Verbosity = 'Detailed'; $r = Invoke-Pester -Configuration $cfg
"PROBE_RESULT: passed=$($r.PassedCount) failed=$($r.FailedCount) total=$($r.TotalCount)"
'RUNNER_CONTINUED: yes'
```

EXIT_CODE: 0
Output Summary: both probe tests passed; the `exit 2` inside `Exit-SubagentStopBlock` (dot-sourced into the `&`-invoked fixture) ended only the fixture, set `$LASTEXITCODE` to 2, wrote exactly the message plus a newline to stderr, produced no success-stream output, and the Pester runner and the PowerShell session continued afterward.

## Parse results from [P1-T1] and [P1-T2]

Command: `[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path <path>).Path, [ref] $tokens, [ref] $errors)`; `@($errors).Count`; `(Get-Content <path>).Count`

```text
PARSE: tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1 | errors=0 | lines=22
PARSE: .claude/hooks/subagentstop-envelope.ps1 | errors=0 | lines=40
```

## Probe output (verbatim)

```text
Describing exit-route probe
  [+] fixture exit 2 ends only the fixture 88ms (63ms|25ms)
  [+] runner continues after the fixture exit 5ms (4ms|1ms)
Tests completed in 495ms
Tests Passed: 2, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PROBE_RESULT: passed=2 failed=0 total=2
RUNNER_CONTINUED: yes
```

RUNNER_CONTINUED: yes (the line was printed as the last statement of the block; the session did not terminate).
