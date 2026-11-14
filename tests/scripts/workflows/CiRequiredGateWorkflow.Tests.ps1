Set-StrictMode -Version Latest

# Workflow-invariant suite for the issue #1074 'CI Required Gate' job in .github/workflows/ci.yml.
#
# The workflow is read from disk as text and partitioned into job blocks: a job begins at a line of
# exactly two spaces, an identifier, and a colon under the top-level 'jobs:' key, and runs to the line
# before the next job start (the technique of PoshQcWorkflow.Tests.ps1). The decision module
# scripts/ci/CiRequiredGate.psm1 is imported for its skippable-set constant. No YAML module, process,
# temporary file, or network call is used.

Describe 'ci.yml CI Required Gate job invariants' {
    BeforeAll {
        $workflowPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../.github/workflows/ci.yml'
        $workflowLines = @(Get-Content -LiteralPath $workflowPath -ErrorAction Stop | ForEach-Object { $_.TrimEnd() })
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/CiRequiredGate.psm1') -Force

        $jobLines = [ordered]@{}
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

        $script:JobText = [ordered]@{}
        foreach ($jobId in $jobLines.Keys) {
            $script:JobText[$jobId] = ($jobLines[$jobId] -join "`n")
        }
        $script:GateJobId = 'ci-required-gate'
        $script:OtherJobIds = [string[]] @($script:JobText.Keys | Where-Object { $_ -cne $script:GateJobId } | Sort-Object)

        # Returns the job ids listed in the block-form 'needs:' of a job text, in file order.
        $script:GetNeedsList = {
            param([string] $JobText)
            $ids = [System.Collections.Generic.List[string]]::new()
            $inNeeds = $false
            foreach ($line in ($JobText -split "`n")) {
                if ($line -match '^ {4}needs:[ \t]*$') {
                    $inNeeds = $true
                    continue
                }
                if ($inNeeds -and $line -match '^ {6}- (?<Id>[A-Za-z0-9_-]+)[ \t]*$') {
                    $ids.Add($Matches['Id'])
                    continue
                }
                $inNeeds = $false
            }
            $ids.ToArray()
        }

        # Returns the reasons a job text fails the gate shape: the name, if: always(), the runner, read-only
        # contents, a credential-free checkout, the pwsh step that passes toJSON(needs) and runs the entry
        # script, no run-heavy input, and a needs list equal to the expected job ids. An empty result means
        # the job text is a valid gate.
        $script:GetGateViolation = {
            param([string] $JobText, [string[]] $ExpectedNeeds)
            $violations = [System.Collections.Generic.List[string]]::new()
            $requiredPatterns = [ordered]@{
                'name CI Required Gate'         = '(?m)^ {4}name: CI Required Gate$'
                'if: always()'                  = '(?m)^ {4}if: always\(\)$'
                'runs-on ubuntu-latest'         = '(?m)^ {4}runs-on: ubuntu-latest$'
                'read-only contents permission' = '(?m)^ {4}permissions:\n {6}contents: read$'
                'persist-credentials false'     = '(?m)^ {10}persist-credentials: false$'
                'shell pwsh'                    = '(?m)^ {8}shell: pwsh$'
                'NEEDS_JSON from toJSON(needs)' = '(?m)^ {10}NEEDS_JSON: \$\{\{ toJSON\(needs\) \}\}$'
                'run of the entry script'       = '(?m)^ {8}run: \./scripts/ci/Invoke-CiRequiredGate\.ps1$'
            }
            foreach ($label in $requiredPatterns.Keys) {
                if ($JobText -notmatch $requiredPatterns[$label]) { $violations.Add("missing $label") }
            }
            if ($JobText.Contains('run-heavy')) { $violations.Add('the gate passes a run-heavy input') }
            $needs = @(& $script:GetNeedsList $JobText)
            $actual = (@($needs | Sort-Object) -join ',')
            $expected = (@($ExpectedNeeds | Sort-Object) -join ',')
            if ($actual -cne $expected) { $violations.Add("needs [$actual] differ from [$expected]") }
            $violations.ToArray()
        }
    }

    It 'WG01-GATE-JOB-SHAPE declares the gate job with its name, condition, runner, permissions, and step (AC-01)' {
        $script:JobText.Contains($script:GateJobId) | Should -BeTrue -Because 'ci.yml declares the ci-required-gate job'

        $violations = @(& $script:GetGateViolation $script:JobText[$script:GateJobId] $script:OtherJobIds)

        ($violations -join '; ') | Should -BeExactly '' -Because 'the gate must run on every outcome and evaluate toJSON(needs) with the entry script'
    }

    It 'WG02-GATE-NEEDS-EVERY-OTHER-JOB needs exactly every other top-level ci.yml job (AC-02)' {
        $needs = @(& $script:GetNeedsList $script:JobText[$script:GateJobId])

        $script:OtherJobIds.Count | Should -Be 11 -Because 'ci.yml has eleven jobs besides the gate'
        (@($needs | Sort-Object) -join ',') | Should -BeExactly ($script:OtherJobIds -join ',') -Because 'a job missing from needs would not be enforced by the gate'
        @($needs | Select-Object -Unique).Count | Should -Be $needs.Count -Because 'needs lists each job once'
    }

    It 'WG03-SKIPPABLE-CONSTANT-PARITY matches the module skippable set to the jobs skipped at job level on a docs-only run (AC-04)' {
        $skippedAtJobLevel = @(
            foreach ($jobId in $script:OtherJobIds) {
                $ifLines = @(($script:JobText[$jobId] -split "`n") | Where-Object { $_ -match '^ {4}if: ' })
                if (@($ifLines | Where-Object { $_.Contains("needs.changes.outputs.code != 'false'") }).Count -gt 0) { $jobId }
            }
        )

        $constant = @(Get-CiRequiredGateSkippableJob)

        (@($skippedAtJobLevel | Sort-Object) -join ',') | Should -BeExactly 'full-run-marker,npm-audit-gate,root-typescript-tests'
        ($constant -join ',') | Should -BeExactly (@($skippedAtJobLevel | Sort-Object) -join ',') -Because 'only jobs skipped by the change scope may report skipped on a docs-only run'
    }

    It 'WG04-GATE-CHECK-DETECTS-MUTATIONS reports a removed needs entry and a removed always() condition (AC-03)' {
        # Arrange: every mutation is applied to an in-memory copy of the committed gate job text.
        $job = $script:JobText[$script:GateJobId]
        $mutations = [ordered]@{
            neededJobRemoved = $job.Replace("`n      - npm-audit-gate", '')
            alwaysRemoved    = $job.Replace("`n    if: always()", '')
            alwaysWeakened   = $job.Replace('    if: always()', '    if: ${{ !cancelled() }}')
        }

        # Act / Assert
        foreach ($name in $mutations.Keys) {
            $mutations[$name] | Should -Not -BeExactly $job -Because "the $name mutation changes the job text"
            @(& $script:GetGateViolation $mutations[$name] $script:OtherJobIds).Count | Should -BeGreaterThan 0 -Because "the $name mutation must be reported"
        }
    }

    It 'WG05-GATE-NAME-IS-NOT-CI-FULL-RUN keeps the gate name distinct from the change-scope base marker' {
        $gate = $script:JobText[$script:GateJobId]

        $gate | Should -Not -Match '(?m)^ {4}name: CI full run$' -Because 'Test-CiFullRunMarker selects a change-scope base by the job name CI full run'
        $script:JobText['full-run-marker'] | Should -Match '(?m)^ {4}name: CI full run$'
        @($script:JobText.Keys | Where-Object { $script:JobText[$_] -match '(?m)^ {4}name: CI Required Gate$' }).Count | Should -Be 1 -Because 'exactly one job reports the CI Required Gate context'
    }
}
