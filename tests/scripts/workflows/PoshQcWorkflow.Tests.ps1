Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/_poshqc.yml (issue #743).
#
# Location note: the Pester runner discovers tests only under the roots declared in
# scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ('scripts',
# 'tests/powershell', 'tests/scripts'), so this file lives under 'tests/scripts/workflows/'
# beside VerifyPublishedReleasesWorkflow.Tests.ps1.
#
# The workflow is read from disk as text and partitioned into job blocks: a job begins at a
# line of exactly two spaces, an identifier, and a colon under the top-level 'jobs:' key, and
# runs to the line before the next job start. No YAML parser module is imported, and no
# external process, temporary file, or network call is made.

Describe '_poshqc.yml workflow invariants' {
    BeforeAll {
        $workflowPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../.github/workflows/_poshqc.yml')).Path
        $workflowLines = @(Get-Content -LiteralPath $workflowPath)

        $jobLines = @{}
        $inJobs = $false
        $current = $null
        foreach ($line in $workflowLines) {
            if ($line -match '^jobs:[ \t]*$') {
                $inJobs = $true
                continue
            }
            if (-not $inJobs) {
                continue
            }
            if ($line -match '^\S') {
                break
            }
            if ($line -match '^ {2}(?<JobId>[A-Za-z0-9_-]+):[ \t]*$') {
                $current = [System.Collections.Generic.List[string]]::new()
                $jobLines[$Matches['JobId']] = $current
                continue
            }
            if ($null -ne $current) {
                $current.Add($line)
            }
        }

        $script:JobText = @{}
        foreach ($jobId in $jobLines.Keys) {
            $script:JobText[$jobId] = ($jobLines[$jobId] -join "`n")
        }

        # Issue #953 (CR-7): returns the reasons a poshqc job text fails to gate on the static and shard job
        # results. An empty result means the gate step reads both results, compares each with 'success' under
        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.
        $script:GetResultGateViolation = {
            param([string] $JobText)
            $steps = [System.Collections.Generic.List[object]]::new()
            foreach ($line in ($JobText -split "`n")) {
                if ($line -match '^ {6}- name:[ \t]*(?<Name>.+?)[ \t]*$') {
                    $steps.Add([pscustomobject]@{ Name = $Matches['Name']; Body = [System.Collections.Generic.List[string]]::new() })
                } elseif ($steps.Count -gt 0) {
                    $steps[$steps.Count - 1].Body.Add($line)
                }
            }

            $gateIndex = -1
            for ($index = 0; $index -lt $steps.Count; $index++) {
                $body = $steps[$index].Body -join "`n"
                if ($body.Contains('${{ needs.poshqc-static.result }}') -and $body.Contains('${{ needs.poshqc-shard.result }}')) {
                    $gateIndex = $index
                    break
                }
            }
            if ($gateIndex -lt 0) {
                return 'no step reads both needs.poshqc-static.result and needs.poshqc-shard.result'
            }

            $gate = $steps[$gateIndex].Body -join "`n"
            $violations = [System.Collections.Generic.List[string]]::new()
            foreach ($required in @('$staticResult = ''${{ needs.poshqc-static.result }}''', '$shardResult = ''${{ needs.poshqc-shard.result }}''', 'if ($staticResult -ne ''success'' -or $shardResult -ne ''success'') {')) {
                if (-not $gate.Contains($required)) {
                    $violations.Add("the gate step does not contain: $required")
                }
            }
            if ($gate -notmatch '(?m)^ +exit 1[ \t]*$') {
                $violations.Add('the gate step does not exit 1')
            }
            if ($gate -match '(?m)^ {8}if:') {
                $violations.Add('the gate step carries a step-level if condition')
            }
            $names = @($steps | ForEach-Object { $_.Name })
            foreach ($laterStep in @('Verify shard completeness', 'Merge PowerShell shard coverage')) {
                $laterIndex = [array]::IndexOf($names, $laterStep)
                if ($laterIndex -le $gateIndex) {
                    $violations.Add("the gate step does not precede the '$laterStep' step")
                }
            }
            $violations
        }
    }

    It 'declares exactly the poshqc, poshqc-linux-hooks, poshqc-shard, and poshqc-static jobs' {
        (@($script:JobText.Keys | Sort-Object) -join ',') | Should -BeExactly 'poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static'
    }

    It 'keeps the poshqc job as the PowerShell QC merge job on windows-latest after the static and shard jobs' {
        $job = $script:JobText['poshqc']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell QC[ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*windows-latest[ \t]*$'
        $job | Should -Match '(?m)^ {4}needs:[ \t]*\[[ \t]*poshqc-static[ \t]*,[ \t]*poshqc-shard[ \t]*\][ \t]*$'
        $job | Should -Match 'Test-PoshQCShardCompleteness'
        $job | Should -Match 'Merge-PoshQCCoverageReport'
        $job | Should -Match '(?m)^ +name:[ \t]*poshqc-test-results[ \t]*$'
    }

    It 'runs the poshqc-linux-hooks job on ubuntu-latest under its check name' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell hook suites \(Linux\)[ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*ubuntu-latest[ \t]*$'
    }

    It 'grants the poshqc-linux-hooks job read-only repository contents' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match '(?m)^ {4}permissions:[ \t]*\n {6}contents:[ \t]*read[ \t]*$'
    }

    It 'limits the poshqc-linux-hooks Run.Path to the two hook-suite folders' {
        $job = $script:JobText['poshqc-linux-hooks']
        $pathLines = @($job -split "`n" | Where-Object { $_ -match 'Run\.Path\s*=' })
        $pathLines.Count | Should -Be 1
        $folders = @([regex]::Matches($pathLines[0], "'([^']+)'") | ForEach-Object { $_.Groups[1].Value })
        ($folders -join ',') | Should -BeExactly 'tests/scripts/claude-hooks,tests/scripts/codex-hooks'
    }

    It 'fails the poshqc-linux-hooks job on a failed test and collects no coverage' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match 'Run\.Exit\s*=\s*\$true'
        $job | Should -Match 'CodeCoverage\.Enabled\s*=\s*\$false'
        $job | Should -Match 'Invoke-Pester -Configuration'
        $job | Should -Not -Match 'Invoke-PoshQCTest'
    }

    It 'uploads the poshqc-linux-hooks JUnit result under a distinct artifact name' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match "TestResult\.OutputPath\s*=\s*'artifacts/pester/pester-junit-linux-hooks\.xml'"
        $job | Should -Match '(?m)^ +name:[ \t]*poshqc-linux-hook-test-results[ \t]*$'
        $job | Should -Not -Match '(?m)^ +name:[ \t]*poshqc-test-results[ \t]*$'
    }

    It 'runs the poshqc-shard job as a three-shard matrix that does not cancel sibling shards (issue #953)' {
        $job = $script:JobText['poshqc-shard']
        $job | Should -Match '(?m)^ {6}fail-fast:[ \t]*false[ \t]*$'
        $job | Should -Match '(?m)^ {8}shard:[ \t]*\[1, 2, 3\][ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*windows-latest[ \t]*$'
    }

    It 'runs Invoke-PoshQCTest with the shard parameters and uploads the shard results even on failure (issue #953)' {
        $job = $script:JobText['poshqc-shard']
        $job | Should -Match 'Invoke-PoshQCTest -Root'
        $job | Should -Match '-ShardIndex \$\{\{ matrix\.shard \}\}'
        $job | Should -Match '(?m)^ +- name:[ \t]*Test PowerShell[ \t]*$'
        $job | Should -Match '(?m)^ {8}if:[ \t]*always\(\)[ \t]*\n {8}uses:[ \t]*actions/upload-artifact@'
        $job | Should -Match '(?m)^ +name:[ \t]*poshqc-test-results-shard-\$\{\{ matrix\.shard \}\}[ \t]*$'
    }

    It 'runs the format and analyze gates in the poshqc-static job (issue #953)' {
        $job = $script:JobText['poshqc-static']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell QC static[ \t]*$'
        $job | Should -Match 'Invoke-PoshQCFormat -Root'
        $job | Should -Match 'Invoke-PoshQCAnalyze -Root'
        $job | Should -Not -Match 'Invoke-PoshQCTest'
    }

    It 'WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS runs the poshqc merge job on every run outcome so a failed or cancelled shard run fails the check (issue #953, CR-7)' {
        $job = $script:JobText['poshqc']
        @([regex]::Matches($job, '(?m)^ {4}if:[ \t]*always\(\)[ \t]*$')).Count | Should -Be 1 -Because 'a skipped required check does not block a merge; always() runs the result gate step'
        $job | Should -Not -Match '(?m)^ {4}if:[ \t]*\$\{\{ !cancelled\(\) \}\}'
    }

    It 'WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE fails the poshqc check unless the static and shard jobs succeeded (issue #953, CR-7)' {
        $violations = @(& $script:GetResultGateViolation $script:JobText['poshqc'])
        ($violations -join '; ') | Should -BeExactly '' -Because 'the gate step is the only link between a failed shard and the poshqc / PowerShell QC check'
    }

    It 'WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS reports a removed, weakened, non-exiting, or moved gate step (issue #953, CR-7)' {
        # Arrange: every mutation is applied to an in-memory copy of the committed poshqc job text.
        $job = $script:JobText['poshqc']
        $gateBlock = [regex]::Match($job, '(?s) {6}- name:[ \t]*Require the static and shard jobs to succeed\n.*?(?= {6}- name:)').Value
        $gateBlock | Should -Not -BeNullOrEmpty -Because 'the committed poshqc job contains the gate step'
        $mutations = [ordered]@{
            removed  = $job.Replace($gateBlock, '')
            weakened = $job.Replace('-ne ''success'' -or $shardResult', '-ne ''success'' -and $shardResult')
            noExit   = $job.Replace('exit 1', 'exit 0')
            moved    = $job.Replace($gateBlock, '') + "`n" + $gateBlock.TrimEnd("`n")
        }

        # Act / Assert
        foreach ($name in $mutations.Keys) {
            $mutations[$name] | Should -Not -BeExactly $job -Because "the $name mutation changes the job text"
            @(& $script:GetResultGateViolation $mutations[$name]).Count | Should -BeGreaterThan 0 -Because "the $name mutation must be reported"
        }
    }

    It 'WF04-SHARD-COUNT-FROM-MATRIX passes strategy.job-total as the shard count and lists shard indices 1..N (issue #953, CR-11)' {
        $job = $script:JobText['poshqc-shard']
        $job | Should -Match '-ShardIndex \$\{\{ matrix\.shard \}\} -ShardCount \$\{\{ strategy\.job-total \}\}'
        $matrixLines = @($job -split "`n" | Where-Object { $_ -match '^ {8}shard:[ \t]*\[' })
        $matrixLines.Count | Should -Be 1
        $indices = @([regex]::Matches($matrixLines[0], '\d+') | ForEach-Object { [int] $_.Value })
        $indices.Count | Should -BeGreaterThan 1
        ($indices -join ',') | Should -BeExactly ((1..$indices.Count) -join ',') -Because 'shard indices must be 1..N, and strategy.job-total supplies N'
    }

    It 'WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT reads the shard count from the shard 1 manifest instead of a literal (issue #953, CR-11)' {
        $job = $script:JobText['poshqc']
        $job | Should -Not -Match '\b1\.\.\d'
        $job | Should -Match '(?m)^ +\$shardCount = \[int\] \(Get-Content -Raw -LiteralPath artifacts/shards/poshqc-test-results-shard-1/shard-files\.json \| ConvertFrom-Json\)\.shardCount[ \t]*$'
        @([regex]::Matches($job, '1\.\.\$shardCount')).Count | Should -Be 2
    }
}
