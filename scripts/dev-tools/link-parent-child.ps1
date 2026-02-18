<#
.SYNOPSIS
Links a child GitHub issue to a parent tracking issue using the gh CLI.

.DESCRIPTION
This script ensures a parent tracking issue lists a specified child issue in its
"Child Issues" section and comments on the child issue with a backlink to the
parent. It validates gh CLI availability, fetches issue metadata, and edits the
parent body safely to avoid overwriting existing content.

.PARAMETER ChildIssueNumber
The issue number of the child issue to link.

.PARAMETER ParentIssueNumber
The issue number of the parent tracking issue that will reference the child.

.INPUTS
None. Issues are supplied via parameters or interactive prompts.

.OUTPUTS
None. Writes progress messages to the pipeline and terminates on error.

.EXAMPLE
pwsh ./link-parent-child.ps1 -ChildIssueNumber 123 -ParentIssueNumber 456

.NOTES
Requires authenticated gh CLI access to the repository context. Uses temporary
files to pass updated body content to gh issue edit.
#>
[CmdletBinding()]
param(
    [string] $ChildIssueNumber,
    [string] $ParentIssueNumber
)

function Write-ScriptError {
    <#
    .SYNOPSIS
    Throws a standardized InvalidOperationException with a supplied message.

    .DESCRIPTION
    Centralizes error throwing to ensure consistent exception type and message
    formatting throughout the script.

    .PARAMETER Message
    The descriptive error message to include in the thrown exception.

    .INPUTS
    None. Accepts a message string only.

    .OUTPUTS
    None. Always throws.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string] $Message)
    throw [System.InvalidOperationException]::new($Message)
}

function Invoke-GhCli {
    <#
    .SYNOPSIS
    Invokes the gh CLI with provided arguments and captures output and exit code.

    .DESCRIPTION
    Executes gh commands through an injectable process runner to aid testing.
    Returns both stdout/stderr output and the resulting exit code for callers to
    interpret failures accurately.

    .PARAMETER GhArgs
    The gh CLI arguments to execute.

    .PARAMETER InvokeProcess
    Optional scriptblock used to run the command, enabling mocking for tests.

    .OUTPUTS
    Hashtable containing Output (string array) and ExitCode (int).

    .EXAMPLE
    Invoke-GhCli -GhArgs @('issue', 'view', '123', '--json', 'number')
    # Returns the raw gh output and exit code for inspection.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $GhArgs,

        [Parameter()]
        [scriptblock] $InvokeProcess = { param([string[]] $GhArgs) & gh @GhArgs 2>&1 }
    )

    $result = & $InvokeProcess $GhArgs
    $exitCode = $LASTEXITCODE

    return @{ Output = $result; ExitCode = $exitCode }
}

function Test-GhCli {
    <#
    .SYNOPSIS
    Ensures the gh CLI is available before proceeding.

    .DESCRIPTION
    Checks for the gh executable on PATH and raises a clear error instructing
    the user to install or authenticate if missing.

    .OUTPUTS
    None. Throws when gh is missing.

    .EXAMPLE
    Test-GhCli
    # Verifies gh is available or raises a descriptive error.
    #>
    # Guard early to prevent later gh invocations from failing with less helpful errors.
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-ScriptError "gh CLI not found on PATH. Install gh and authenticate first."
    }
}

function Read-IssueNumber {
    <#
    .SYNOPSIS
    Retrieves an issue number from provided input or interactive prompt.

    .DESCRIPTION
    Accepts a label and optional value. If the value is empty, it prompts the
    user to enter the issue number. Empty responses are rejected to guarantee a
    valid identifier.

    .PARAMETER Label
    Friendly label describing whether the number is for a child or parent issue.

    .PARAMETER Value
    The initial issue number value, if provided.

    .OUTPUTS
    Trimmed issue number string.

    .EXAMPLE
    Read-IssueNumber -Label "child" -Value "123"
    # Returns "123" ensuring the value is non-empty.
    #>
    param(
        [string] $Label,
        [string] $Value
    )
    # Prompt when the caller did not provide a value to keep interactive usage straightforward.
    if ([string]::IsNullOrWhiteSpace($Value)) {
        $Value = Read-Host "Enter $Label issue number"
    }
    # Fail fast on blank responses so downstream gh calls never receive empty identifiers.
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-ScriptError "$Label issue number is required."
    }
    return $Value.Trim()
}

function Get-IssueFetchFailureCategory {
    <#
    .SYNOPSIS
    Categorizes gh CLI failures when fetching an issue.

    .DESCRIPTION
    Inspects the exit code and textual output from gh to classify failures into
    actionable categories (authentication, not found, permission, or unknown) so
    calling code can craft precise guidance.

    .PARAMETER ExitCode
    Exit code returned by the gh CLI invocation.

    .PARAMETER Output
    Raw output from gh CLI; may be null when the command fails silently.

    .OUTPUTS
    A string category identifying the detected failure cause.

    .EXAMPLE
    Get-IssueFetchFailureCategory -ExitCode 1 -Output 'gh auth login'
    # Returns 'auth-required' for authentication errors.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [int] $ExitCode,

        [Parameter()]
        [AllowNull()]
        [object] $Output
    )

    $outputText = ""
    # Normalize output to a single string to simplify downstream pattern matching.
    if ($null -ne $Output) {
        $outputText = @($Output) -join "`n"
    }

    # Authentication-related errors take precedence because they are the most common root cause.
    if ($ExitCode -ne 0 -and (
            $outputText -match '(?i)gh\s+auth\s+login' -or
            $outputText -match '(?i)authentication' -or
            $outputText -match '(?i)not\s+logged\s+in')) {
        return 'auth-required'
    }

    # Detect missing issue references to guide users toward verifying identifiers.
    if ($outputText -match '(?i)could\s+not\s+resolve\s+to\s+an\s+issue' -or
        $outputText -match '(?i)issue\s+.*\s+not\s+found') {
        return 'not-found'
    }

    # Permission or repo-context failures often indicate wrong repository selection.
    if ($outputText -match '(?i)resource\s+not\s+accessible' -or
        $outputText -match '(?i)permission\s+denied' -or
        $outputText -match '(?i)repository\s+not\s+found') {
        return 'permission-repo-context'
    }

    return 'unknown'
}

function Get-IssueFetchFailureMessage {
    <#
    .SYNOPSIS
    Builds a user-facing error message from a categorized gh fetch failure.

    .DESCRIPTION
    Combines the failure category, issue label, and number to produce actionable
    guidance, including gh commands the user can run to remediate. Includes raw
    CLI output when available for easier troubleshooting.

    .PARAMETER Category
    Failure category returned by Get-IssueFetchFailureCategory.

    .PARAMETER IssueLabel
    Human-friendly label describing the issue role (child or parent).

    .PARAMETER IssueNumber
    The issue number that failed to fetch.

    .PARAMETER Output
    Optional raw gh CLI output to append for context.

    .OUTPUTS
    A composed string message suitable for user display.

    .EXAMPLE
    Get-IssueFetchFailureMessage -Category 'not-found' -IssueLabel 'child' -IssueNumber '123' -Output 'could not resolve to an issue'
    # Returns a guided error message instructing the user to verify the issue number or repo context.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Category,

        [Parameter(Mandatory = $true)]
        [string] $IssueLabel,

        [Parameter(Mandatory = $true)]
        [string] $IssueNumber,

        [Parameter()]
        [AllowNull()]
        [object] $Output
    )

    $outputText = ""
    # Capture raw CLI output when available so it can be appended to the guidance text.
    if ($null -ne $Output) {
        $outputText = ((@($Output) -join "`n").Trim())
    }

    $baseMessage = "Unable to fetch $IssueLabel issue #$IssueNumber."
    # Tailor guidance based on the detected failure type so the user has a direct next step.
    $guidance = switch ($Category) {
        'auth-required' {
            "Run 'gh auth status' and, if needed, authenticate with 'gh auth login'."
        }
        'not-found' {
            "Verify the issue number and repository context (for example: gh issue view $IssueNumber)."
        }
        'permission-repo-context' {
            "Check repository access and active repo context (for example: gh repo view and gh auth status)."
        }
        default {
            "Check gh CLI output and retry with explicit repo context (for example: gh issue view $IssueNumber --repo <owner>/<repo>)."
        }
    }

    # Return concise guidance when no CLI output exists to avoid cluttering the message.
    if ([string]::IsNullOrWhiteSpace($outputText)) {
        return "$baseMessage $guidance"
    }

    return "$baseMessage $guidance CLI output: $outputText"
}

function Get-Issue {
    <#
    .SYNOPSIS
    Retrieves issue metadata via gh CLI with robust error handling.

    .DESCRIPTION
    Calls gh issue view to fetch the issue number, title, URL, and body as JSON,
    converting the result to a PowerShell object. Errors are classified and
    surfaced with contextual guidance to keep failures actionable.

    .PARAMETER IssueNumber
    The issue number to retrieve.

    .PARAMETER Label
    Human-readable role label used in error messages (e.g., "child").

    .PARAMETER InvokeGh
    Optional injectable gh invoker for testing.

    .OUTPUTS
    PSCustomObject containing number, title, url, and body.

    .EXAMPLE
    Get-Issue -IssueNumber '123' -Label 'child'
    # Fetches issue metadata or raises a classified error if retrieval fails.
    #>
    param(
        [string] $IssueNumber,
        [string] $Label,
        [scriptblock] $InvokeGh = { param([string[]] $GhArgs) Invoke-GhCli -GhArgs $GhArgs }
    )

    $result = & $InvokeGh @('issue', 'view', $IssueNumber, '--json', 'number', 'title', 'url', 'body')
    # Surface classified errors immediately when gh fails to return the requested issue payload.
    if ($result.ExitCode -ne 0 -or -not $result.Output) {
        $failureCategory = Get-IssueFetchFailureCategory -ExitCode $result.ExitCode -Output $result.Output
        $failureMessage = Get-IssueFetchFailureMessage -Category $failureCategory -IssueLabel $Label -IssueNumber $IssueNumber -Output $result.Output
        Write-ScriptError $failureMessage
    }

    return $result.Output | ConvertFrom-Json
}

function Invoke-LinkParentChild {
    <#
    .SYNOPSIS
    Updates a parent tracking issue to reference a child issue and comments on the child.

    .DESCRIPTION
    Validates gh CLI availability, collects issue numbers (prompting when absent),
    fetches issue details, updates or creates the parent's "Child Issues" section,
    and posts a backlink comment on the child issue when missing.

    .PARAMETER ChildIssueNumberParam
    Issue number for the child issue; prompted if not supplied.

    .PARAMETER ParentIssueNumberParam
    Issue number for the parent tracking issue; prompted if not supplied.

    .PARAMETER InvokeGh
    Optional gh invoker for testing or alternative execution.

    .EXAMPLE
    Invoke-LinkParentChild -ChildIssueNumberParam '123' -ParentIssueNumberParam '456'
    # Updates the parent issue body and comments on the child with a backlink.
    #>
    [CmdletBinding()]
    param(
        [string] $ChildIssueNumberParam,
        [string] $ParentIssueNumberParam,
        [scriptblock] $InvokeGh = { param([string[]] $GhArgs) Invoke-GhCli -GhArgs $GhArgs }
    )

    Test-GhCli

    # Collect and validate issue numbers, prompting the user when arguments were omitted.
    $ChildIssueNumberParam = Read-IssueNumber -Label "child" -Value $ChildIssueNumberParam
    $ParentIssueNumberParam = Read-IssueNumber -Label "parent" -Value $ParentIssueNumberParam

    $childIssue = Get-Issue -IssueNumber $ChildIssueNumberParam -Label "child" -InvokeGh $InvokeGh
    $parentIssue = Get-Issue -IssueNumber $ParentIssueNumberParam -Label "parent" -InvokeGh $InvokeGh

    $parentBody = $parentIssue.body
    # Protect against empty bodies to avoid overwriting the entire issue content accidentally.
    if ([string]::IsNullOrWhiteSpace($parentBody)) {
        Write-ScriptError "Parent issue #$ParentIssueNumberParam has an empty body; aborting to avoid overwriting content."
    }

    $childEntry = "- [ ] #$($childIssue.number) - $($childIssue.title)"

    $headingPattern = "(?ims)^##\s+Child Issues\s*\r?\n(.*?)(?=^\#\#\s+|\z)"
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::Singleline
    $headingRegex = [System.Text.RegularExpressions.Regex]::new($headingPattern, $regexOptions)

    $match = $headingRegex.Match($parentBody)
    $parentUpdated = $false
    $step5Succeeded = $false

    if ($match.Success) {
        # Existing Child Issues section found; append entry if not already present.
        $step5Succeeded = $true
        $sectionContent = $match.Groups[1].Value
        $alreadyListed = $sectionContent -match [regex]::Escape($childIssue.url) -or $sectionContent -match ("#" + [regex]::Escape($childIssue.number))
        if ($alreadyListed) {
            Write-Output "Parent issue already references child #$($childIssue.number); no body update needed."
            $parentUpdated = $false
        } else {
            # Preserve existing list items while adding the new child entry to the bottom of the section.
            $existingLines = $sectionContent.TrimEnd()
            if ([string]::IsNullOrWhiteSpace($existingLines)) {
                $newSection = "## Child Issues`n$childEntry`n"
            } else {
                $newSection = "## Child Issues`n$existingLines`n$childEntry`n"
            }
            $parentBody = $headingRegex.Replace($parentBody, $newSection.TrimEnd() + "`n")
            $parentUpdated = $true
        }
    } else {
        # No Child Issues section exists; prompt to convert the parent into a tracking issue before adding the section.
        $response = Read-Host "Parent #$ParentIssueNumberParam has no 'Child Issues' section. Convert to tracking issue and add one? (y/n)"
        if ($response -notin @("y", "Y", "yes", "Yes")) {
            Write-ScriptError "Aborting: parent issue lacks a 'Child Issues' section and conversion was declined."
        }
        $step5Succeeded = $true
        $parentBody = $parentBody.TrimEnd() + "`n`n## Child Issues`n$childEntry`n"
        $parentUpdated = $true
    }

    if (-not $step5Succeeded) {
        Write-ScriptError "Unable to process parent issue body."
    }

    if ($parentUpdated) {
        # Write the updated body to a temp file to avoid in-place string escaping issues with gh CLI.
        $tmp = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), '.md')
        Set-Content -Path $tmp -Value $parentBody -Encoding UTF8

        $editResult = & $InvokeGh @('issue', 'edit', $ParentIssueNumberParam, '--body-file', $tmp)
        $editExit = $editResult.ExitCode
        Remove-Item $tmp -ErrorAction SilentlyContinue

        if ($editExit -ne 0) {
            Write-ScriptError "Failed to update parent issue #$ParentIssueNumberParam."
        }
        Write-Output "Updated parent issue #$ParentIssueNumberParam with child link."
    } else {
        Write-Output "No parent body changes were required."
    }

    $childAlreadyLinked = $childIssue.body -match [regex]::Escape($parentIssue.url) -or $childIssue.body -match ("#" + [regex]::Escape($parentIssue.number))
    # Avoid duplicating backlinks when the child body already references the parent issue.
    if ($childAlreadyLinked) {
        Write-Output "Child issue already references parent #$($parentIssue.number); no comment added."
        return
    }

    # Add a backlink comment on the child so readers can navigate to the parent tracker.
    $comment = "Linked to parent tracking issue #$($parentIssue.number) - $($parentIssue.title)"
    $commentResult = & $InvokeGh @('issue', 'comment', $ChildIssueNumberParam, '--body', $comment)
    if ($commentResult.ExitCode -ne 0) {
        Write-ScriptError "Failed to add parent link comment to child issue #$ChildIssueNumberParam."
    }

    Write-Output "Added parent link comment to child issue #$ChildIssueNumberParam."
}

if (
    $MyInvocation.InvocationName -eq '.' -and
    [string]::IsNullOrWhiteSpace($ChildIssueNumber) -and
    [string]::IsNullOrWhiteSpace($ParentIssueNumber)
) {
    # Allow dot-sourcing without immediate execution so the functions can be reused.
    return
}

if ($env:POSHQC_SKIP_SCRIPT_EXECUTION) {
    # Honor CI/formatting contexts that should skip runtime execution while still loading the script.
    return
}

Invoke-LinkParentChild -ChildIssueNumberParam $ChildIssueNumber -ParentIssueNumberParam $ParentIssueNumber
