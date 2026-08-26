Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/publish-mcp-npm.yml.
#
# Location note (issue #526): the Pester runner discovers tests only under the roots
# declared in scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ('scripts',
# 'tests/powershell', 'tests/scripts'). A suite mirroring '.github/workflows/'
# literally would not be discovered, so this file lives under 'tests/scripts/workflows/'.
#
# The workflow is read from disk as text and asserted with line-oriented and regular
# expression checks. No YAML parser module is imported, so the suite has no dependency
# beyond Pester itself, and no external process, temporary file, or network call is made.

Describe "publish-mcp-npm.yml workflow invariants" {
    BeforeAll {
        $script:workflowPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../.github/workflows/publish-mcp-npm.yml")).Path
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

        # Partition the file into step blocks. A step begins at exactly six spaces followed
        # by '- name:'; the publish JOB shares the name 'Publish to npm' with the publish
        # STEP but sits at four spaces with no leading dash, so this partition never
        # confuses the two. A block runs to the line before the next step start.
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

        $script:refGuardPattern = "if:\s*startsWith\(github\.ref,\s*'refs/tags/mcp-server-v'\)"
        $script:publishStep = @($script:stepBlocks | Where-Object { $_.Text -match 'npm publish' })[0]
        $script:equalityStep = @($script:stepBlocks | Where-Object { $_.Text -match 'packages/mcp-server/package\.json' })[0]
        $script:pollStep = @($script:stepBlocks | Where-Object { $_.Text -match 'npm view' })[0]
    }

    It "declares a pull_request trigger scoped to the mcp-server package and the workflow file" {
        # The modified-workflow-needs-green-run policy rule makes any diff to this file
        # Blocking unless a green branch-head run exists. A push-tag-only trigger set has
        # no trigger that can produce such a run, so the pull_request trigger is a hard
        # precondition of touching the file at all.
        $script:triggerText | Should -Match '(?m)^\s{2}pull_request:'
        $script:triggerText | Should -Match '(?m)^\s+-\s+"?packages/mcp-server/\*\*"?\s*$'
        $script:triggerText | Should -Match '(?m)^\s+-\s+"?\.github/workflows/publish-mcp-npm\.yml"?\s*$'
    }

    It "guards the publish step on the tag ref and not on the event name" {
        # An event-name guard passes on any push event, including a branch push, and it
        # cannot distinguish a tag push from a workflow_dispatch run. The ref guard is
        # what makes a non-destructive re-dispatch possible and what keeps the publish
        # step from running on a pull-request ref.
        $eventNameGuards = @($script:workflowLines | Where-Object { $_ -match '^\s*if:\s*.*github\.event_name' })
        $eventNameGuards.Count | Should -Be 0

        $refGuards = @($script:workflowLines | Where-Object { $_ -match "startsWith\(github\.ref,\s*'refs/tags/mcp-server-v'\)" })
        $refGuards.Count | Should -BeGreaterThan 0
    }

    It "asserts tag and manifest version equality in a ref-guarded step ordered before the publish step" {
        # A tag whose version disagrees with the manifest publishes the manifest version
        # under a tag that names a different one, which is the divergence this step blocks.
        $script:equalityStep | Should -Not -BeNullOrEmpty
        $script:publishStep | Should -Not -BeNullOrEmpty

        # Ordered before the publish step: an equality check after the publish has already
        # happened cannot prevent the wrong version reaching the registry.
        $script:equalityStep.Index | Should -BeLessThan $script:publishStep.Index

        # Ref-guarded: a pull_request run carries no tag ref to parse.
        $script:equalityStep.Text | Should -Match $script:refGuardPattern

        # Reads the version out of the tag ref and compares it against the manifest field.
        $script:equalityStep.Text | Should -Match 'GITHUB_REF_NAME'
        $script:equalityStep.Text | Should -Match "mcp-server-v"
        $script:equalityStep.Text | Should -Match '\.version'

        # Fails the job on inequality rather than merely reporting it.
        $script:equalityStep.Text | Should -Match '-ne'
        $script:equalityStep.Text | Should -Match '(?m)^\s*exit 1\s*$'
    }

    It "polls the exact published version after publishing and fails the job on budget expiry" {
        # The bare-package operand resolves the latest dist-tag, which would have passed
        # during the 1.0.25 failure. Only the exact-version operand is decisive.
        $script:pollStep | Should -Not -BeNullOrEmpty
        $script:publishStep | Should -Not -BeNullOrEmpty

        $script:pollStep.Index | Should -BeGreaterThan $script:publishStep.Index
        $script:pollStep.Text | Should -Match '@danmoisan/drm-copilot-mcp@\$version'

        # A bounded poll with an explicit non-zero exit once the budget expires; a poll that
        # falls through silently would report success for a version that never published.
        $script:pollStep.Text | Should -Match 'maxAttempts'
        $script:pollStep.Text | Should -Match '(?m)^\s*exit 1\s*$'
    }

    It "ref-guards the post-publish registry poll step" {
        # On a pull_request run this job still executes because its `needs` is satisfied and
        # only the publish step is skipped by its ref guard. An unguarded poll would query a
        # version that was never published, exhaust its budget, and fail the job, so no green
        # branch-head run could exist for the modified-workflow-needs-green-run rule.
        $script:pollStep | Should -Not -BeNullOrEmpty
        $script:pollStep.Text | Should -Match $script:refGuardPattern
    }

    It "resets or explicitly exits after every deliberately-failing nested command in an added pwsh step" {
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
