Set-StrictMode -Version Latest

# Workflow-invariant suite for the issue #962 change-scope gating of .github/workflows/ci.yml and the six
# reusable workflows it calls.
#
# Each workflow is read from disk as text. The lines under the top-level 'jobs:' key are partitioned into
# job blocks at lines of exactly two spaces, an identifier, and a colon; each job block is partitioned into
# step blocks at lines that begin with six spaces and '- '. Assertions compare whole lines after TrimEnd().
# The same technique is used by PoshQcWorkflow.Tests.ps1. No YAML module, process, temporary file, or
# network call is used. The _poshqc.yml rows detect the sharded shape of issue #953 at run time from the
# presence of a poshqc-shard job, so their names and counts are the same in both shapes.

Describe 'issue #962 change-scope workflow gating' {
    BeforeAll {
        $workflowRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../.github/workflows'
        $script:Workflow = @{}
        foreach ($fileName in @('ci.yml', '_quality-checks.yml', '_security-scan.yml', '_build-check.yml', '_shell-coverage.yml', '_drm-copilot-extension-tests.yml', '_poshqc.yml')) {
            $path = Join-Path -Path $workflowRoot -ChildPath $fileName
            $script:Workflow[$fileName] = [string[]]@(Get-Content -LiteralPath $path -ErrorAction Stop | ForEach-Object { $_.TrimEnd() })
        }
        $script:RunHeavyStepIf = '^ {8}if: .*inputs\.run-heavy'
        $script:RunHeavyJobIf = '^ {4}if: .*inputs\.run-heavy'
        $script:BareAlwaysStepIf = '^ {8}if:\s*(\$\{\{\s*)?always\(\)\s*(\}\})?\s*$'
        $script:BareAlwaysJobIf = '^ {4}if:\s*(\$\{\{\s*)?always\(\)\s*(\}\})?\s*$'

        # Partitions the lines under 'jobs:' into an ordered map of job id to the job's lines.
        function Get-TestJobBlock {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string[]] $Lines)
            $blocks = [ordered]@{}
            $inJobs = $false
            $current = $null
            foreach ($line in $Lines) {
                if ($line -match '^jobs:\s*$') { $inJobs = $true; continue }
                if (-not $inJobs) { continue }
                if ($line -match '^\S') { break }
                if ($line -match '^ {2}(?<Id>[A-Za-z0-9_-]+):\s*$') {
                    $current = [System.Collections.Generic.List[string]]::new()
                    $blocks[$Matches['Id']] = $current
                    continue
                }
                if ($null -ne $current) { $current.Add($line) }
            }
            return $blocks
        }

        # Partitions a job's lines into step blocks; each block starts with its '      - ' line.
        function Get-TestStepBlock {
            param([Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]] $JobLines)
            $steps = [System.Collections.Generic.List[object]]::new()
            $current = $null
            foreach ($line in $JobLines) {
                if ($line -match '^ {6}- ') {
                    $current = [System.Collections.Generic.List[string]]::new()
                    $steps.Add($current)
                }
                if ($null -ne $current) { $current.Add($line) }
            }
            return , $steps
        }

        # Returns the step name of a step block, or an empty string for an unnamed step.
        function Get-TestStepName {
            param([Parameter(Mandatory = $true)][object] $Step)
            if ($Step[0] -match '^ {6}- name:\s*(?<Name>.+)$') { return $Matches['Name'] }
            return ''
        }

        # Returns the job lines of one job in one workflow file, or $null when the job is absent.
        function Get-TestJobLine {
            param([Parameter(Mandatory = $true)][string] $FileName, [Parameter(Mandatory = $true)][string] $JobId)
            $blocks = Get-TestJobBlock -Lines $script:Workflow[$FileName]
            if (-not $blocks.Contains($JobId)) { return $null }
            return , [string[]]@($blocks[$JobId])
        }

        # True when the expected lines occur as one consecutive run inside the given lines.
        function Test-TestConsecutiveLine {
            param([Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Lines, [Parameter(Mandatory = $true)][string[]] $Expected)
            for ($start = 0; $start -le $Lines.Count - $Expected.Count; $start++) {
                $match = $true
                for ($offset = 0; $offset -lt $Expected.Count; $offset++) {
                    if ($Lines[$start + $offset] -cne $Expected[$offset]) { $match = $false; break }
                }
                if ($match) { return $true }
            }
            return $false
        }

        # True when the trigger of the on: block declares a run-heavy input of type boolean defaulting to true.
        function Test-TestRunHeavyInput {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string[]] $Lines, [Parameter(Mandatory = $true)][string] $Trigger)
            $onIndex = [Array]::IndexOf($Lines, 'on:')
            if ($onIndex -lt 0) { return $false }
            $triggerIndex = -1
            for ($i = $onIndex + 1; $i -lt $Lines.Count -and $Lines[$i] -notmatch '^\S'; $i++) {
                if ($Lines[$i] -ceq "  $($Trigger):") { $triggerIndex = $i; break }
            }
            if ($triggerIndex -lt 0) { return $false }
            $inputLines = [System.Collections.Generic.List[string]]::new()
            $inInput = $false
            for ($i = $triggerIndex + 1; $i -lt $Lines.Count -and $Lines[$i] -notmatch '^ {0,2}\S'; $i++) {
                if ($Lines[$i] -ceq '      run-heavy:') { $inInput = $true; continue }
                if ($inInput -and $Lines[$i] -notmatch '^ {8}') { break }
                if ($inInput) { $inputLines.Add($Lines[$i]) }
            }
            return ($inputLines -ccontains '        type: boolean') -and ($inputLines -ccontains '        default: true')
        }
    }

    Context 'ci.yml decision jobs' {
        It 'declares the changes job as Change scope with actions read and contents read (AC-18)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'changes'

            $job | Should -Not -BeNullOrEmpty -Because 'ci.yml must declare the changes job'
            $job -ccontains '    name: Change scope' | Should -BeTrue
            Test-TestConsecutiveLine -Lines $job -Expected @('    permissions:', '      actions: read', '      contents: read') | Should -BeTrue -Because 'the decision job reads runs and jobs with read-only permissions'
        }

        It 'binds the changes job output code to steps.scope.outputs.code (AC-18)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'changes'

            $job | Should -Not -BeNullOrEmpty
            Test-TestConsecutiveLine -Lines $job -Expected @('    outputs:', '      code: ${{ steps.scope.outputs.code }}') | Should -BeTrue -Because 'the callers read needs.changes.outputs.code'
        }

        It 'checks out the pull request head with fetch-depth 0, filter blob:none, and persist-credentials false (AC-18)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'changes'

            $job | Should -Not -BeNullOrEmpty
            $expected = @('          ref: ${{ github.event.pull_request.head.sha || github.sha }}', '          fetch-depth: 0', '          filter: blob:none', '          persist-credentials: false')
            $missing = @($expected | Where-Object { $job -cnotcontains $_ })
            ($missing -join ' | ') | Should -BeExactly '' -Because 'the decision needs full history to check ancestry and diff against the base'
        }

        It 'runs scripts/ci/Invoke-CiChangeScope.ps1 in a pwsh step with id scope and continue-on-error true (AC-18)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'changes'

            $job | Should -Not -BeNullOrEmpty
            $matching = @((Get-TestStepBlock -JobLines $job) | Where-Object {
                    $step = [string[]]@($_)
                    ($step -ccontains '        id: scope') -and ($step -ccontains '        shell: pwsh') -and ($step -ccontains '        continue-on-error: true') -and (@($step | Where-Object { $_.Contains('./scripts/ci/Invoke-CiChangeScope.ps1') }).Count -gt 0)
                })
            $matching.Count | Should -Be 1 -Because 'one pwsh step runs the decision script and cannot fail the job'
        }

        It 'declares full-run-marker as CI full run that needs changes and runs only when code is not false (AC-18)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'full-run-marker'

            $job | Should -Not -BeNullOrEmpty -Because 'ci.yml must declare the full-run-marker job'
            $expected = @('    name: CI full run', '    needs: changes', '    if: ${{ !cancelled() && needs.changes.outputs.code != ''false'' }}')
            $missing = @($expected | Where-Object { $job -cnotcontains $_ })
            ($missing -join ' | ') | Should -BeExactly '' -Because 'the marker job runs exactly when the heavy steps run'
        }
    }

    Context 'ci.yml callers' {
        It 'wires <Caller> with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)' -ForEach @(
            @{ Caller = 'quality-checks7' }
            @{ Caller = 'security-scan' }
            @{ Caller = 'build-check' }
            @{ Caller = 'poshqc' }
            @{ Caller = 'shell-coverage' }
            @{ Caller = 'drm-copilot-extension-tests' }
        ) {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId $Caller

            $job | Should -Not -BeNullOrEmpty
            $expected = @('    needs: changes', '    if: ${{ !cancelled() }}', '      run-heavy: ${{ needs.changes.outputs.code != ''false'' }}')
            $missing = @($expected | Where-Object { $job -cnotcontains $_ })
            ($missing -join ' | ') | Should -BeExactly '' -Because "$Caller reports a required context, so it always runs and receives run-heavy"
        }

        It 'skips <Caller> at job level when code is false (AC-19)' -ForEach @(
            @{ Caller = 'root-typescript-tests' }
            @{ Caller = 'npm-audit-gate' }
        ) {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId $Caller

            $job | Should -Not -BeNullOrEmpty
            $expected = @('    needs: changes', '    if: ${{ !cancelled() && needs.changes.outputs.code != ''false'' }}')
            $missing = @($expected | Where-Object { $job -cnotcontains $_ })
            ($missing -join ' | ') | Should -BeExactly '' -Because "$Caller is not a required context, so it is skipped for a docs-only change"
        }

        It 'keeps docs-validation without needs and without if (AC-19)' {
            $job = Get-TestJobLine -FileName 'ci.yml' -JobId 'docs-validation'

            $job | Should -Not -BeNullOrEmpty
            @($job | Where-Object { $_ -match '^ {4}(needs|if):' }).Count | Should -Be 0 -Because 'documentation validation always runs in full'
        }
    }

    Context 'reusable-workflow gating' {
        It 'declares run-heavy as a boolean defaulting to true under both triggers in <File> (AC-20)' -ForEach @(
            @{ File = '_quality-checks.yml' }
            @{ File = '_security-scan.yml' }
            @{ File = '_build-check.yml' }
            @{ File = '_shell-coverage.yml' }
            @{ File = '_drm-copilot-extension-tests.yml' }
            @{ File = '_poshqc.yml' }
        ) {
            $lines = $script:Workflow[$File]

            Test-TestRunHeavyInput -Lines $lines -Trigger 'workflow_call' | Should -BeTrue -Because "$File must declare run-heavy for callers"
            Test-TestRunHeavyInput -Lines $lines -Trigger 'workflow_dispatch' | Should -BeTrue -Because "$File must declare run-heavy for a standalone dispatch"
        }

        It 'gates every step of <Job> on inputs.run-heavy in <File> (AC-20)' -ForEach @(
            @{ File = '_quality-checks.yml'; Job = 'quality-checks7' }
            @{ File = '_security-scan.yml'; Job = 'security-scan' }
            @{ File = '_build-check.yml'; Job = 'build-check' }
            @{ File = '_shell-coverage.yml'; Job = 'shell-coverage' }
            @{ File = '_drm-copilot-extension-tests.yml'; Job = 'drm-copilot-extension-tests' }
            @{ File = '_poshqc.yml'; Job = 'poshqc' }
        ) {
            $jobLines = Get-TestJobLine -FileName $File -JobId $Job
            $jobLines | Should -Not -BeNullOrEmpty

            $steps = Get-TestStepBlock -JobLines $jobLines
            $ungated = @($steps | Where-Object { @([string[]]@($_) | Where-Object { $_ -match $script:RunHeavyStepIf }).Count -eq 0 } | ForEach-Object { Get-TestStepName -Step $_ })

            $steps.Count | Should -BeGreaterThan 0
            ($ungated -join ' | ') | Should -BeExactly '' -Because "every step of $Job reports success without running when run-heavy is false"
        }

        It 'combines run-heavy with the poetry cache-miss condition in _quality-checks.yml (AC-20)' {
            $steps = Get-TestStepBlock -JobLines (Get-TestJobLine -FileName '_quality-checks.yml' -JobId 'quality-checks7')
            $step = @($steps | Where-Object { (Get-TestStepName -Step $_) -ceq 'Install dependencies' })

            $step.Count | Should -Be 1
            ([string[]]@($step[0])) -ccontains '        if: ${{ inputs.run-heavy && steps.cached-poetry-dependencies.outputs.cache-hit != ''true'' }}' | Should -BeTrue -Because 'the cache-miss condition is kept inside the run-heavy gate'
        }

        It 'combines run-heavy with the 3.13-only condition in _quality-checks.yml (AC-20)' {
            $steps = Get-TestStepBlock -JobLines (Get-TestJobLine -FileName '_quality-checks.yml' -JobId 'quality-checks7')
            $step = @($steps | Where-Object { (Get-TestStepName -Step $_) -ceq 'Upload coverage to Codecov' })

            $step.Count | Should -Be 1
            ([string[]]@($step[0])) -ccontains '        if: ${{ inputs.run-heavy && matrix.python-version == ''3.13'' }}' | Should -BeTrue -Because 'the single-leg upload condition is kept inside the run-heavy gate'
        }

        It 'combines run-heavy with the kcov cache-miss condition in _shell-coverage.yml (AC-20)' {
            $steps = Get-TestStepBlock -JobLines (Get-TestJobLine -FileName '_shell-coverage.yml' -JobId 'shell-coverage')
            $step = @($steps | Where-Object { (Get-TestStepName -Step $_) -ceq 'Build kcov from source' })

            $step.Count | Should -Be 1
            ([string[]]@($step[0])) -ccontains '        if: ${{ inputs.run-heavy && steps.cache-kcov.outputs.cache-hit != ''true'' }}' | Should -BeTrue -Because 'the kcov cache-miss condition is kept inside the run-heavy gate'
        }

        It 'leaves no bare always() step condition outside a job gated at job level on run-heavy in <File> (AC-20)' -ForEach @(
            @{ File = '_quality-checks.yml' }
            @{ File = '_security-scan.yml' }
            @{ File = '_build-check.yml' }
            @{ File = '_shell-coverage.yml' }
            @{ File = '_drm-copilot-extension-tests.yml' }
            @{ File = '_poshqc.yml' }
        ) {
            $blocks = Get-TestJobBlock -Lines $script:Workflow[$File]
            $offenders = [System.Collections.Generic.List[string]]::new()
            foreach ($jobId in $blocks.Keys) {
                $jobLines = [string[]]@($blocks[$jobId])
                if (@($jobLines | Where-Object { $_ -match $script:RunHeavyJobIf }).Count -gt 0) { continue }
                foreach ($line in @($jobLines | Where-Object { $_ -match $script:BareAlwaysStepIf })) { $offenders.Add("$($jobId): $($line.Trim())") }
            }

            ($offenders -join ' | ') | Should -BeExactly '' -Because 'a bare always() step would run its heavy work under run-heavy false'
        }
    }

    Context '_poshqc.yml gating' {
        It 'skips every _poshqc.yml job other than poshqc at job level unless run-heavy (AC-21)' {
            $blocks = Get-TestJobBlock -Lines $script:Workflow['_poshqc.yml']
            $others = @($blocks.Keys | Where-Object { $_ -cne 'poshqc' })
            $ungated = @($others | Where-Object { @([string[]]@($blocks[$_]) | Where-Object { $_ -match $script:RunHeavyJobIf }).Count -eq 0 })

            $others.Count | Should -BeGreaterThan 0
            ($ungated -join ' | ') | Should -BeExactly '' -Because 'the jobs that do not report poshqc / PowerShell QC are skipped for a docs-only change'
        }

        It 'keeps the poshqc job-level condition free of run-heavy and keeps if always() in the sharded shape (AC-21)' {
            $blocks = Get-TestJobBlock -Lines $script:Workflow['_poshqc.yml']
            $job = [string[]]@($blocks['poshqc'])
            $sharded = $blocks.Contains('poshqc-shard')

            @($job | Where-Object { $_ -match $script:RunHeavyJobIf }).Count | Should -Be 0 -Because 'the poshqc job always starts so its required context reports'
            if ($sharded) {
                @($job | Where-Object { $_ -match $script:BareAlwaysJobIf }).Count | Should -Be 1 -Because 'the sharded aggregator keeps if: always()'
            }
            else {
                @($job | Where-Object { $_ -match '^ {4}if:' }).Count | Should -Be 0 -Because 'the unsharded poshqc job has no job-level condition'
            }
        }

        It 'gates every poshqc step, including any step whose name begins Require, on run-heavy (AC-21)' {
            $blocks = Get-TestJobBlock -Lines $script:Workflow['_poshqc.yml']
            $steps = Get-TestStepBlock -JobLines ([string[]]@($blocks['poshqc']))
            $ungated = @($steps | Where-Object { @([string[]]@($_) | Where-Object { $_ -match $script:RunHeavyStepIf }).Count -eq 0 } | ForEach-Object { Get-TestStepName -Step $_ })

            $steps.Count | Should -BeGreaterThan 0
            ($ungated -join ' | ') | Should -BeExactly '' -Because 'every poshqc step is skipped under run-heavy false'
            if ($blocks.Contains('poshqc-shard')) {
                @($steps | Where-Object { (Get-TestStepName -Step $_).StartsWith('Require', [StringComparison]::Ordinal) }).Count | Should -Be 1 -Because 'the sharded aggregator has exactly one result-gate step'
            }
        }
    }

    Context 'security scan' {
        It 'runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)' {
            $job = Get-TestJobLine -FileName '_security-scan.yml' -JobId 'security-scan'
            $job | Should -Not -BeNullOrEmpty
            $steps = Get-TestStepBlock -JobLines $job
            $names = @($steps | ForEach-Object { Get-TestStepName -Step $_ })
            $pluginIndex = [Array]::IndexOf($names, 'Install the Poetry export plugin')

            $pluginIndex | Should -BeGreaterOrEqual 0
            ([string[]]@($steps[$pluginIndex])) -ccontains '        run: poetry self add poetry-plugin-export' | Should -BeTrue
            $pluginIndex + 1 | Should -BeLessThan $steps.Count
            $names[$pluginIndex + 1] | Should -BeExactly 'Check for security vulnerabilities'
            $scanStep = [string[]]@($steps[$pluginIndex + 1])
            $scanStep -ccontains '        shell: bash' | Should -BeTrue -Because 'bash runs with pipefail, so a failed export is reported in the scan step'
            (@($job | Where-Object { $_ -match '^\s*continue-on-error:' }) -join ' | ') | Should -BeExactly '        continue-on-error: true' -Because 'only the scan step is non-blocking while the pre-existing safety findings remain (issue #962 PD-18)'
            $scanStep -ccontains '        continue-on-error: true' | Should -BeTrue -Because 'continue-on-error belongs to the scan step and to no other step'
        }
    }
}
