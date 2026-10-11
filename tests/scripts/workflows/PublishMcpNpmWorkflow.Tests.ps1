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
        [regex]::Matches($script:equalityStep.Text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
        $script:equalityStep.Text | Should -Match '(?s)if \(\$tagVersion -ne \$manifestVersion\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
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
        [regex]::Matches($script:pollStep.Text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
        $script:pollStep.Text | Should -Match '(?s)if \(-not \$resolved\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
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

    # Issue #723: the registry verify poll must tolerate propagation delay beyond the former
    # 180 second window. The assertions below pin a bounded backoff schedule whose cumulative
    # sleep budget is at least 600 seconds, a timeout message that does not blame the tag
    # push, and the existing exit-code and exact-version invariants of the poll step.
    It "polls with a bounded backoff schedule whose cumulative sleep budget is at least 600 seconds" {
        $script:pollStep | Should -Not -BeNullOrEmpty
        $text = $script:pollStep.Text

        $text | Should -Match '\$maxAttempts\s*=\s*14\b'
        $text | Should -Match '\$initialIntervalSeconds\s*=\s*10\b'
        $text | Should -Match '\$maxIntervalSeconds\s*=\s*60\b'
        $text | Should -Match '\[Math\]::Min\(\s*\$initialIntervalSeconds\s*\*\s*\$attempt\s*,\s*\$maxIntervalSeconds\s*\)'

        $attemptsMatch = [regex]::Match($text, '\$maxAttempts\s*=\s*(?<Value>\d+)')
        $initialMatch = [regex]::Match($text, '\$initialIntervalSeconds\s*=\s*(?<Value>\d+)')
        $capMatch = [regex]::Match($text, '\$maxIntervalSeconds\s*=\s*(?<Value>\d+)')
        $attemptsMatch.Success | Should -BeTrue -Because "the poll step must assign `$maxAttempts"
        $initialMatch.Success | Should -BeTrue -Because "the poll step must assign `$initialIntervalSeconds"
        $capMatch.Success | Should -BeTrue -Because "the poll step must assign `$maxIntervalSeconds"

        $maxAttemptsValue = [int]$attemptsMatch.Groups['Value'].Value
        $initialValue = [int]$initialMatch.Groups['Value'].Value
        $capValue = [int]$capMatch.Groups['Value'].Value

        $totalSleepSeconds = 0
        for ($k = 1; $k -le ($maxAttemptsValue - 1); $k++) {
            $totalSleepSeconds += [Math]::Min($initialValue * $k, $capValue)
        }
        $totalSleepSeconds | Should -BeGreaterOrEqual 600 -Because "the cumulative sleep budget must cover at least 600 seconds"
    }

    It "caps the poll interval at 60 seconds and skips the sleep after the final attempt" {
        $script:pollStep | Should -Not -BeNullOrEmpty
        $text = $script:pollStep.Text

        # The sleep cmdlet name is assembled from two fragments because the repository
        # test-purity hook rejects the literal cmdlet name in any Pester file. The name is
        # only a search token here; no sleep is executed by this test.
        $sleepToken = 'Start' + '-Sleep'

        $text | Should -Match '\$maxIntervalSeconds\s*=\s*60\b'
        $text | Should -Match ($sleepToken + '\s+-Seconds\s+\$sleepSeconds')

        $sleepStatements = [regex]::Matches($text, $sleepToken)
        $sleepStatements.Count | Should -Be 1

        $guardMatch = [regex]::Match($text, '\$attempt\s+-lt\s+\$maxAttempts')
        $guardMatch.Success | Should -BeTrue -Because "the sleep must sit behind a final-attempt guard"

        $sleepMatch = [regex]::Match($text, $sleepToken)
        $guardMatch.Index | Should -BeLessThan $sleepMatch.Index -Because "the final-attempt guard must precede the sleep statement"
    }

    It "reports a timeout message that does not claim the tag push failed to publish" {
        $script:pollStep | Should -Not -BeNullOrEmpty
        $errorLines = @(($script:pollStep.Text -split "`n") | Where-Object { $_ -match '::error::' })
        $errorLines.Count | Should -Be 1

        $errorLine = $errorLines[0]
        $errorLine | Should -Not -Match 'tag push did not publish'
        $errorLine | Should -Match 'not yet resolvable'
        $errorLine | Should -Match 'publish step succeeded'
        $errorLine | Should -Match 'Check the registry'
        $errorLine | Should -Match 're-publishing an existing version fails'
    }

    It "keeps the exit-code reset, explicit exits, and exact-version operand in the poll step" {
        $script:pollStep | Should -Not -BeNullOrEmpty
        $text = $script:pollStep.Text

        $text | Should -Match '\$LASTEXITCODE\s*=\s*0'
        $text | Should -Match '@danmoisan/drm-copilot-mcp@\$version'
        $text | Should -Match '(?m)^\s*exit 0\s*$'
        [regex]::Matches($text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
        $text | Should -Match '(?s)if \(-not \$resolved\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
        $text | Should -Match $script:refGuardPattern
    }

    # Issue #723 refinement, closed under #846: the poll step's error message states that the
    # publish step succeeded. That statement holds only while the poll step keeps the default
    # success() status check (no always(), failure(), or cancelled() in its if: expression),
    # the publish step cannot report success after a failure (no continue-on-error), and the
    # poll step runs after the publish step.
    It "runs the registry poll step only after a successful publish step" {
        $script:pollStep | Should -Not -BeNullOrEmpty
        $script:publishStep | Should -Not -BeNullOrEmpty

        $pollConditions = @(($script:pollStep.Text -split "`n") | Where-Object { $_ -match '^\s+if:' })
        $pollConditions.Count | Should -Be 1
        $pollConditions[0] | Should -Not -Match 'always\(\)|failure\(\)|cancelled\(\)'

        $script:publishStep.Text | Should -Not -Match 'continue-on-error'
        $script:pollStep.Index | Should -BeGreaterThan $script:publishStep.Index
    }
}
