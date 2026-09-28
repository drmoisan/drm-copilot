Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/verify-published-releases.yml.
#
# Location note (issue #526): the Pester runner discovers tests only under the roots
# declared in scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ('scripts',
# 'tests/powershell', 'tests/scripts'). A suite mirroring '.github/workflows/'
# literally would not be discovered, so this file lives under 'tests/scripts/workflows/'.
#
# The workflow is read from disk as text and asserted with line-oriented and regular
# expression checks. No YAML parser module is imported, so the suite has no dependency
# beyond Pester itself, and no external process, temporary file, or network call is made.

Describe "verify-published-releases.yml workflow invariants" {
    BeforeAll {
        $script:workflowPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../.github/workflows/verify-published-releases.yml")).Path
        $script:workflowLines = @(Get-Content -LiteralPath $script:workflowPath)

        # Isolate the top-level trigger block: every line after the 'on:' key up to the
        # next top-level (column-zero) key. Scoping the trigger assertions to this block
        # keeps them from being satisfied by an unrelated occurrence elsewhere in the file.
        $triggerLines = [System.Collections.Generic.List[string]]::new()
        $inTriggerBlock = $false
        foreach ($line in $script:workflowLines) {
            if ($line -match '^on:') {
                $inTriggerBlock = $true
                continue
            }
            if ($inTriggerBlock -and $line -match '^\S') {
                break
            }
            if ($inTriggerBlock) {
                $triggerLines.Add($line)
            }
        }
        $script:triggerText = ($triggerLines -join "`n")

        # Partition the file into step blocks. A step begins at exactly six spaces
        # followed by '- name:'; a block runs to the line before the next step start.
        $stepPattern = '^\s{6}-\s+name:\s*(?<StepName>.+?)\s*$'
        $stepStarts = @()
        for ($i = 0; $i -lt $script:workflowLines.Count; $i++) {
            if ($script:workflowLines[$i] -match $stepPattern) {
                $stepStarts += $i
            }
        }

        $blocks = [System.Collections.Generic.List[object]]::new()
        for ($j = 0; $j -lt $stepStarts.Count; $j++) {
            $start = $stepStarts[$j]
            $end = if ($j -lt ($stepStarts.Count - 1)) { $stepStarts[$j + 1] - 1 } else { $script:workflowLines.Count - 1 }
            $blocks.Add([pscustomobject]@{
                    Name  = ([regex]::Match($script:workflowLines[$start], $stepPattern)).Groups['StepName'].Value
                    Index = $start
                    Text  = (($script:workflowLines[$start..$end]) -join "`n")
                })
        }
        $script:stepBlocks = $blocks
    }

    It "declares a schedule trigger" {
        # The retroactive sweep is the only layer that can surface a tag whose version was
        # never published when nobody ran a release to look for it, so it must fire on its
        # own rather than only when a human dispatches it.
        $script:triggerText | Should -Match '(?m)^\s{2}schedule:'
        $script:triggerText | Should -Match '(?m)^\s+-\s+cron:'
    }

    It "declares a pull_request trigger scoped to the workflow file and the reconciliation script" {
        # The modified-workflow-needs-green-run policy rule makes a diff to this file
        # Blocking unless a green branch-head run exists. A schedule-only trigger set has
        # no trigger that can produce such a run before the file lands.
        $script:triggerText | Should -Match '(?m)^\s{2}pull_request:'
        $script:triggerText | Should -Match '(?m)^\s+-\s+"?\.github/workflows/verify-published-releases\.yml"?\s*$'
        $script:triggerText | Should -Match '(?m)^\s+-\s+"?scripts/dev-tools/Invoke-ReleaseReconciliation\.ps1"?\s*$'
    }

    It "gates the registry sweep off pull-request runs so a branch-head run cannot fail on a pre-existing divergence" {
        # The sweep reports a divergence that predates this change, including the 1.0.12
        # gap. Running it on a pull request would fail the branch-head run the policy rule
        # requires, making that rule unsatisfiable.
        $sweepStep = @($script:stepBlocks | Where-Object { $_.Text -match 'Invoke-ReleaseReconciliation\.ps1 -TagVersionList' })[0]
        $sweepStep | Should -Not -BeNullOrEmpty
        $sweepStep.Text | Should -Match "if:\s*github\.event_name\s*!=\s*'pull_request'"

        # The offline validation step is what makes the pull-request run non-empty: it
        # exercises the pure comparison with no network query, so it must NOT be gated off.
        $offlineStep = @($script:stepBlocks | Where-Object { $_.Text -match 'Get-UnpublishedTagVersion' })[0]
        $offlineStep | Should -Not -BeNullOrEmpty
        $offlineStep.Text | Should -Not -Match "if:\s*github\.event_name"
    }

    It "resets or explicitly exits after every deliberately-failing nested command in a pwsh step" {
        # Per .claude/rules/ci-workflows.md a pwsh step terminates with the exit code of its
        # last external command unless the script resets it or calls exit. No local stage
        # executes a workflow run block, so this assertion is the only gate on that defect.
        $pwshSteps = @($script:stepBlocks | Where-Object { $_.Text -match '(?m)^\s*shell:\s*pwsh\s*$' })
        $pwshSteps.Count | Should -BeGreaterThan 0

        foreach ($step in $pwshSteps) {
            $resetsExitCode = $step.Text -match '\$LASTEXITCODE\s*=\s*0'
            $exitsExplicitly = ($step.Text -match '(?m)^\s*exit 0\s*$') -and ($step.Text -match '(?m)^\s*exit 1\s*$')
            ($resetsExitCode -or $exitsExplicitly) | Should -BeTrue -Because "pwsh step '$($step.Name)' must reset `$LASTEXITCODE or exit explicitly"
        }
    }
}
