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
    }

    It 'declares exactly the poshqc and poshqc-linux-hooks jobs' {
        (@($script:JobText.Keys | Sort-Object) -join ',') | Should -BeExactly 'poshqc,poshqc-linux-hooks'
    }

    It 'keeps the poshqc job on windows-latest running Invoke-PoshQCTest' {
        $job = $script:JobText['poshqc']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell QC[ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*windows-latest[ \t]*$'
        $job | Should -Match 'Invoke-PoshQCTest -Root'
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
}
