Set-StrictMode -Version Latest

# Trigger-invariant suite for .github/workflows/ci.yml (issue #658).
#
# Every epic child PR targets its epic's integration branch (epic/<slug>-integration)
# rather than main, so the ci.yml pull_request branch filter must list "epic/**" or no
# CI gate runs for those PRs. The push branch filter must stay exactly main and development.
#
# Location note (issue #526): the Pester runner discovers tests only under the roots
# declared in scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ('scripts',
# 'tests/powershell', 'tests/scripts'). A suite mirroring '.github/workflows/'
# literally would not be discovered, so this file lives under 'tests/scripts/workflows/'.
#
# The workflow is read from disk as text and asserted with line-oriented regular
# expression checks. No YAML parser module is loaded, and no process launch, temporary
# file, or network call is made.

Describe "ci.yml workflow triggers" {
    BeforeAll {
        $script:workflowPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../.github/workflows/ci.yml")).Path
        $script:workflowLines = @(Get-Content -LiteralPath $script:workflowPath)

        # Isolate the top-level trigger block: every line after the 'on:' key up to the
        # next top-level (column-zero) key. Scoping the branch lookups to this block
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
        $script:triggerLines = [string[]]$triggerLines.ToArray()

        function Get-CiTriggerBranchList {
            <#
            .SYNOPSIS
            Returns the branch filter entries declared for one trigger event.

            .DESCRIPTION
            Locates the two-space-indented event key inside the isolated trigger block,
            scans that event's body up to the next sibling key, and reads its four-space
            'branches:' key in either the bracketed flow form or the dash-item block form.
            Surrounding whitespace and one pair of surrounding single or double quotes are
            removed from each entry. Returns an empty array when the event or the
            'branches:' key is absent. The array is enumerated onto the pipeline, so callers
            wrap the call in @() to keep an array when zero or one entry is returned.

            .PARAMETER TriggerLines
            The lines of the 'on:' block, excluding the 'on:' line itself.

            .PARAMETER EventName
            The trigger event key to read, for example 'pull_request' or 'push'.
            #>
            [CmdletBinding()]
            [OutputType([string[]])]
            param(
                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [AllowEmptyString()]
                [string[]]$TriggerLines,

                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [string]$EventName
            )

            $eventPattern = '^\s{2}' + [regex]::Escape($EventName) + ':\s*$'
            $eventIndex = -1

            # Find the first line that opens the requested event at two-space indentation.
            for ($i = 0; $i -lt $TriggerLines.Count; $i++) {
                if ($TriggerLines[$i] -match $eventPattern) {
                    $eventIndex = $i
                    break
                }
            }
            if ($eventIndex -lt 0) {
                return [string[]]@()
            }

            $rawItems = [System.Collections.Generic.List[string]]::new()
            $foundBranchesKey = $false

            # Walk the event body until the next sibling event key, looking for 'branches:'.
            for ($j = $eventIndex + 1; $j -lt $TriggerLines.Count; $j++) {
                $current = $TriggerLines[$j]
                if ($current -match '^\s{2}\S') {
                    break
                }
                if ($current -notmatch '^\s{4}branches:\s*(?<Rest>.*)$') {
                    continue
                }

                $foundBranchesKey = $true
                $rest = $Matches['Rest'].Trim()
                if ($rest.StartsWith('[')) {
                    $inner = $rest.Substring(1)
                    $closeIndex = $inner.LastIndexOf(']')
                    if ($closeIndex -ge 0) {
                        $inner = $inner.Substring(0, $closeIndex)
                    }

                    # Each comma-separated segment of the flow list is one branch entry.
                    foreach ($segment in $inner.Split(',')) {
                        $rawItems.Add($segment)
                    }
                }
                else {
                    # Collect the dash items that directly follow the 'branches:' key.
                    for ($k = $j + 1; $k -lt $TriggerLines.Count; $k++) {
                        if ($TriggerLines[$k] -notmatch '^\s{6}-\s*(?<Item>.+)$') {
                            break
                        }
                        $rawItems.Add($Matches['Item'])
                    }
                }
                break
            }

            if (-not $foundBranchesKey) {
                return [string[]]@()
            }

            $branches = [System.Collections.Generic.List[string]]::new()

            # Normalize each raw entry: trim whitespace, then strip one pair of matching quotes.
            foreach ($rawItem in $rawItems) {
                $value = $rawItem.Trim()
                if ($value -match '^([''"])(?<Inner>.*)\1$') {
                    $value = $Matches['Inner'].Trim()
                }
                if ($value.Length -gt 0) {
                    $branches.Add($value)
                }
            }

            return [string[]]$branches.ToArray()
        }
    }

    It "lists main, development, and epic/** in the pull_request branch filter" {
        # Arrange: the isolated trigger block must be non-empty, otherwise the lookup below
        # would be reading nothing and its result would not describe the workflow.
        $script:triggerLines.Count | Should -BeGreaterThan 0 -Because "ci.yml must declare an 'on:' trigger block"

        # Act: read the pull_request branch filter.
        $pullRequestBranches = @(Get-CiTriggerBranchList -TriggerLines $script:triggerLines -EventName 'pull_request')

        # Assert: epic child PRs target epic/<slug>-integration, so 'epic/**' must be listed
        # alongside main and development for those PRs to run the CI gate.
        $pullRequestBranches | Should -Contain 'main' -Because 'PRs into main must run CI'
        $pullRequestBranches | Should -Contain 'development' -Because 'PRs into development must run CI'
        $pullRequestBranches | Should -Contain 'epic/**' -Because 'epic child PRs into epic/<slug>-integration must run CI (issue #658)'
    }

    It "keeps the push branch filter exactly main and development" {
        # Arrange: the push trigger is out of scope for issue #658 and must not change.
        $script:triggerLines.Count | Should -BeGreaterThan 0 -Because "ci.yml must declare an 'on:' trigger block"

        # Act: read the push branch filter.
        $pushBranches = @(Get-CiTriggerBranchList -TriggerLines $script:triggerLines -EventName 'push')

        # Assert: the push filter lists exactly main and development, in that order.
        ($pushBranches -join ',') | Should -BeExactly 'main,development'
    }
}
