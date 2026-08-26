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
}
