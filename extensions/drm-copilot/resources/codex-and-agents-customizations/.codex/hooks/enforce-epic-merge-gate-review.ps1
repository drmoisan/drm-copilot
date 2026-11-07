<#
.SYNOPSIS
    Review guard of the merge gate under review_mode concurrent (issue #1097).

.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ps1 in both runtimes; this file is byte-identical in the
    Claude and Codex hook folders. Each gate calls Get-EpicMergeGateReviewShapeDecision and then
    Get-EpicMergeGateReviewDecision with the per-feature checkpoint it read, before any allow
    branch. Under the key, a command the gates read reaches no allow branch without a passing review
    at a current head, and text that could be a merge and cannot be bound is denied.

    The key is the top-level checkpoint key review_mode. Only the exact string concurrent activates
    the guard, compared ordinally; an absent key, null, sequential, a case variant, a number, and
    every other non-string value mean sequential, and the guard then starts no process and denies
    nothing. Test-EpicMergeGateReviewModeConcurrent holds that predicate.

    Shape step, before the out-of-scope allow and the order below: text that could be a merge
    (Test-EpicMergeGateReviewMergeText) and is not one plain gh pr merge of one number
    (Get-EpicMergeGateReviewBoundPrNumber) is denied with REVIEW_GATE_HEAD_UNRESOLVED, before any
    process, when a checkpoint the gate can read carries the key. Without the key the decision is
    unchanged. On Claude an unbound command also reads the session and the item of each number in
    its text; that read is best-effort, so a failure sees no key and never denies.

    Evaluation order; the first match ends it:
      1. The checkpoint is absent or the key is not exactly concurrent: inert, no process.
      2. The command names no pull request number: REVIEW_GATE_HEAD_UNRESOLVED, before any process.
      3. The last remediation_loop.review_outcomes entry is missing, is not an object, or its
         verdict is not exactly PASS: REVIEW_GATE_NOT_PASSED, before any process.
      4. Its head_sha is absent or malformed: REVIEW_GATE_NOT_PASSED, before any process.
      5. The one bounded gh pr view <PR> --json headRefOid fails or is malformed:
         REVIEW_GATE_HEAD_UNRESOLVED.
      6. head_sha equals the live head: pass.
      7. git merge-base --is-ancestor <reviewed> <live> exits 1: REVIEW_GATE_HEAD_STALE.
      8. That command exits anything other than 0 or 1: REVIEW_GATE_HEAD_UNRESOLVED.
      9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED.
     10. git diff --name-only -z of the reviewed and live heads fails, or its non-empty output does
         not end with NUL: REVIEW_GATE_HEAD_UNRESOLVED.
     11. A listed path does not start with <feature-folder>/ (ordinal): REVIEW_GATE_HEAD_STALE,
         naming the path.
     12. Otherwise, including an empty listing: pass.

    A code change after the review is therefore stale, including a merge of origin/main, because
    that diff lists code paths. The hook never fetches: a head that is not present locally fails
    step 7 or 8 and denies. The guard applies to whichever checkpoint its gate hands it, with no
    binding exemption, so an explicit PR number that the checkpoint does not bind fails at the head
    comparison; an exemption for an unbound number would open a bypass on Codex, whose child branch
    requires no PR binding.

    Limits (issue #1097 decision D10): this guard is a policy-level control, not a security control.
    A writer in the same session can edit the checkpoint. A merge outside the Bash hook surface is
    not gated. A merge whose item target does not resolve (NoTarget or Ambiguous), or whose child
    checkpoint does not parse, sees no key, and the parallel skill step is then the only backstop. A
    push after the lookup can change the head unless the command passes --match-head-commit. The
    CI full run requirement of the join is skill-level, because a docs-only head passes CI Required
    Gate. The authorization path reads no CI result, so the required CI Required Gate context is the
    control there. A text scan cannot read a script file, encoded or run-time composed text, a gh
    alias or shell function from an earlier call, or an endpoint held in a variable. The PowerShell
    tool, mcp__* tools, and the Codex shell_command tool are not gated, because the gates are
    registered for Bash only. A queued auto-merge fires with no command. A direct push to the base
    is not a pull-request merge. A number-less merge text sees only the session checkpoint. Under
    the key the rule is fail-closed, so prose naming pr merge is denied in any command.

.NOTES
    Compatible with PowerShell 7+. This file dot-sources nothing and imports no module. It calls, at
    run time only, Invoke-DocsOnlyGhExe, Invoke-DocsOnlyGitExe, and ConvertFrom-DocsOnlyNameList
    (hook-docs-only-diff.ps1), which the gate loads before it calls this file's functions and of
    which the two process wrappers bound each call and never throw. It also calls
    Read-CommandLineInvocationSegment, ConvertTo-CommandLineNormalizedText, Get-CommandLineGlobalOption,
    Get-CommandLineStructuralWalk, and Test-CommandLineTokenLiteral (hook-command-invocation.ps1 and
    its siblings), and Test-EpicMergeGateApiMutationText and Get-EpicMergeGateSelectorPrNumber
    (enforce-epic-merge-gate-command.ps1). Read-EpicMergeGateReviewItemCheckpoint and
    Get-EpicMergeGateReviewUnscopedDecision are Claude-only: the Codex gate passes no reader.
    The Claude gate runs gh in the session worktree and git in the item worktree; the Codex gate
    runs both in the repository root.
#>

# Dash options and their values that may sit between two subcommand words of one invocation.
$script:EpicMergeGateReviewOptionGap = '(?:\s+-\S+(?:\s+[^\s-]\S*)?)*'

# Text that could be a merge, matched ordinally over the scan text: pr then merge, and pr then a
# subcommand the text cannot show, because a variable, substitution, or subshell supplies it.
$script:EpicMergeGateReviewMergePattern = '(?<![\w-])pr' + $script:EpicMergeGateReviewOptionGap + '\s+merge(?![\w-])'
$script:EpicMergeGateReviewDynamicPattern = '(?<![\w-])pr' + $script:EpicMergeGateReviewOptionGap + '\s+[$`(]'

# The REST merge path with any segment in the number position, and a GraphQL call.
$script:EpicMergeGateReviewRestPattern = '(?<![\w-])pulls/[^\s/]+/merge(?![\w-])'
$script:EpicMergeGateReviewGraphqlPattern = '(?<![\w-])api' + $script:EpicMergeGateReviewOptionGap + '\s+graphql(?![\w-])'
$script:EpicMergeGateReviewMutationPattern = '(?<![\w-])mutation(?![\w-])'

# The gh api flags that carry a GraphQL field, and the shell words that may lead a segment of a
# poll loop around a read-only query.
$script:EpicMergeGateReviewFieldFlags = @('-f', '-F', '--raw-field', '--field')
$script:EpicMergeGateReviewShellKeywords = @('do', 'then', 'else', 'elif', 'if', 'while', 'until', '!')

# The gh pr merge flags a bound command may carry. This is an allowlist, so --auto, --admin, -R,
# --repo, a redirection, and every unknown token fail by absence.
$script:EpicMergeGateReviewBoundFlags = @('--merge', '-m', '--squash', '-s', '--rebase', '-r', '--delete-branch', '-d', '--disable-auto')
$script:EpicMergeGateReviewBoundValueFlags = @('--match-head-commit', '--subject', '-t', '--body', '-b', '--body-file', '-F', '--author-email', '-A')

function Test-EpicMergeGateReviewModeConcurrent {
    <#
    .SYNOPSIS
        True when a parsed checkpoint carries review_mode exactly equal to concurrent (pure).
    .DESCRIPTION
        The value is tested with -is [string] first, because -ceq on an array filters rather than
        compares. The guard and the readiness relaxation share this meaning.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint, or $null when absent or unreadable.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Checkpoint)

    if ($Checkpoint -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    if (@($Checkpoint.PSObject.Properties.Name) -cnotcontains 'review_mode') { return $false }
    $mode = $Checkpoint.review_mode
    return ($mode -is [string]) -and ($mode -ceq 'concurrent')
}

function Test-EpicMergeGateReviewObjectId {
    <#
    .SYNOPSIS
        True when a value is a full lowercase hexadecimal object id of 40 or 64 characters.
    .PARAMETER Value
        The candidate value; any non-string value returns $false.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string]) -and ($Value -cmatch '\A[0-9a-f]{40}([0-9a-f]{24})?\z')
}

function Get-EpicMergeGateLastReviewOutcome {
    <#
    .SYNOPSIS
        Return the last remediation_loop.review_outcomes entry when it is an object, else $null.
    .DESCRIPTION
        Last-entry semantics: only the final list element counts, so an earlier PASS never
        satisfies the guard. A missing loop, a value that is not a list, an empty list, and a final
        element that is not an object all return $null.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint.
    .OUTPUTS
        System.Management.Automation.PSCustomObject or $null
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] $Checkpoint)

    $loop = $Checkpoint.remediation_loop
    if ($loop -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $outcomes = $loop.review_outcomes
    if ($outcomes -isnot [System.Array] -or $outcomes.Count -eq 0) { return $null }
    $last = $outcomes[$outcomes.Count - 1]
    if ($last -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    return $last
}

function Test-EpicMergeGateReviewFeatureFolder {
    <#
    .SYNOPSIS
        True when a value is a clean relative path below docs/features/ (pure).
    .DESCRIPTION
        A blank value, a value outside docs/features/ (which includes every absolute path), a
        backslash, an empty segment (which includes a trailing slash), and a dot segment all return
        $false, so a value such as . cannot widen the feature-folder rule.
    .PARAMETER Value
        The candidate feature-folder value; any non-string value returns $false.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { return $false }
    if (-not $Value.StartsWith('docs/features/', [System.StringComparison]::Ordinal)) { return $false }
    if ($Value.IndexOf([char]92) -ge 0) { return $false }
    foreach ($segment in $Value.Split('/')) {
        if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
    }
    return $true
}

function Test-EpicMergeGateReviewPathInFolder {
    <#
    .SYNOPSIS
        True when a repository-relative path lies inside the feature folder (pure, ordinal).
    .DESCRIPTION
        The prefix carries the separator, so a sibling folder whose name extends the feature folder
        does not match.
    .PARAMETER Path
        The repository-relative path a diff listed.
    .PARAMETER FeatureFolder
        The validated feature folder.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $FeatureFolder
    )

    return $Path.StartsWith($FeatureFolder + '/', [System.StringComparison]::Ordinal)
}

function Get-EpicMergeGateReviewLiveHeadSha {
    <#
    .SYNOPSIS
        Return the live head commit of a pull request, or $null on any failure (the live-head seam).
    .DESCRIPTION
        Runs gh pr view <PR> --json headRefOid through Invoke-DocsOnlyGhExe, which bounds the call
        and never throws. This is the guard's own seam, because the green-CI sibling that holds a
        similar function exists only on the Claude runtime. A non-zero exit, output that does not
        parse to a JSON object, and a malformed head all return $null. Tests mock this by name.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][int] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    }
    catch {
        # Unreadable gh output is a lookup failure; the guard fails closed on $null.
        return $null
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    if (-not (Test-EpicMergeGateReviewObjectId -Value $pr.headRefOid)) { return $null }
    return [string]$pr.headRefOid
}

function Get-EpicMergeGateReviewHeadState {
    <#
    .SYNOPSIS
        Classify a reviewed head against the live head as Current, Stale, or Unresolved.
    .DESCRIPTION
        Evaluates steps 6 to 12 of the file header in order. A later head is Current only when the
        reviewed head is its ancestor and every path changed since then lies inside the feature
        folder, so review artifacts and evidence do not force a new review.
    .PARAMETER ReviewedHead
        The head_sha of the last review outcome.
    .PARAMETER LiveHead
        The live pull-request head.
    .PARAMETER FeatureFolder
        The checkpoint's feature-folder value, not yet validated.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with State and Detail.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $ReviewedHead,
        [Parameter(Mandatory)][string] $LiveHead,
        [AllowNull()] $FeatureFolder,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    if ([string]::Equals($ReviewedHead, $LiveHead, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ State = 'Current'; Detail = 'the reviewed head is the live head.' }
    }

    $ancestry = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('merge-base', '--is-ancestor', $ReviewedHead, $LiveHead)
    $ancestryExit = if ($null -eq $ancestry) { -1 } else { [int]$ancestry.ExitCode }
    if ($ancestryExit -eq 1) {
        return [ordered]@{ State = 'Stale'; Detail = "the reviewed head $ReviewedHead is not an ancestor of the live head $LiveHead." }
    }
    if ($ancestryExit -ne 0) {
        return [ordered]@{ State = 'Unresolved'; Detail = "git merge-base could not compare the reviewed head $ReviewedHead with the live head $LiveHead; fetch the pull request head, then retry. This hook does not fetch." }
    }

    if (-not (Test-EpicMergeGateReviewFeatureFolder -Value $FeatureFolder)) {
        return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' }
    }

    $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', $ReviewedHead, $LiveHead)
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ State = 'Unresolved'; Detail = "git diff of the reviewed head $ReviewedHead and the live head $LiveHead could not be computed." }
    }
    $listing = [string]$diff.Output
    if ($listing.Length -gt 0 -and -not $listing.EndsWith([char]0)) {
        return [ordered]@{ State = 'Unresolved'; Detail = 'git diff did not return NUL-terminated output.' }
    }

    foreach ($path in @(ConvertFrom-DocsOnlyNameList -Text $listing)) {
        if (-not (Test-EpicMergeGateReviewPathInFolder -Path $path -FeatureFolder $FeatureFolder)) {
            return [ordered]@{ State = 'Stale'; Detail = "the path $path changed after the reviewed head $ReviewedHead and lies outside $FeatureFolder." }
        }
    }
    return [ordered]@{ State = 'Current'; Detail = 'only feature-folder paths changed after the reviewed head.' }
}

function Get-EpicMergeGateReviewDecision {
    <#
    .SYNOPSIS
        Evaluate the review guard for one merge command and return Denied and Reason.
    .DESCRIPTION
        Applies steps 1 to 5 of the file header and delegates steps 6 to 12 to
        Get-EpicMergeGateReviewHeadState. Every deny reason reads
        EPIC_MERGE_GATE_BLOCKED: <code>: <message>. Without the key it returns immediately and
        starts no process.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint, or $null.
    .PARAMETER CommandPrNumber
        The explicit PR number the command names, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Denied and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $pass = [ordered]@{ Denied = $false; Reason = $null }
    if (-not (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $Checkpoint)) { return $pass }

    if ($null -eq $CommandPrNumber) {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: review_mode concurrent requires a merge command that names the pull request number.' }
    }

    $outcome = Get-EpicMergeGateLastReviewOutcome -Checkpoint $Checkpoint
    if ($null -eq $outcome -or $outcome.verdict -isnot [string] -or $outcome.verdict -cne 'PASS') {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: review_mode concurrent requires a last review_outcomes entry with verdict PASS.' }
    }
    if (-not (Test-EpicMergeGateReviewObjectId -Value $outcome.head_sha)) {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: review_mode concurrent requires a full lowercase head_sha on the last review_outcomes entry.' }
    }

    $liveHead = Get-EpicMergeGateReviewLiveHeadSha -PrNumber $CommandPrNumber -WorktreeRoot $GhRoot
    if ($null -eq $liveHead) {
        return [ordered]@{ Denied = $true; Reason = "EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: the live head of pull request $CommandPrNumber could not be read." }
    }

    $headState = Get-EpicMergeGateReviewHeadState -ReviewedHead ([string]$outcome.head_sha) -LiveHead $liveHead -FeatureFolder $Checkpoint.'feature-folder' -GitRoot $GitRoot
    if ($headState.State -ceq 'Current') { return $pass }
    $code = if ($headState.State -ceq 'Stale') { 'REVIEW_GATE_HEAD_STALE' } else { 'REVIEW_GATE_HEAD_UNRESOLVED' }
    return [ordered]@{ Denied = $true; Reason = "EPIC_MERGE_GATE_BLOCKED: ${code}: $($headState.Detail)" }
}

function ConvertTo-EpicMergeGateReviewScanText {
    <#
    .SYNOPSIS
        Return command text as the shell would join it, for a text scan (pure).
    .DESCRIPTION
        Removes each backslash line continuation, then every backslash and quote character, so
        an escaped or quoted word reads as the word the shell passes on. RemoveBacktick also
        removes backticks, which are escape characters in PowerShell.
    .PARAMETER CommandText
        The raw command text.
    .PARAMETER RemoveBacktick
        Produce the second scan form.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [switch] $RemoveBacktick
    )

    $text = [regex]::Replace($CommandText, '\\\r?\n', '')
    $text = [regex]::Replace($text, '[\\"'']', '')
    if ($RemoveBacktick) { $text = $text.Replace('`', '') }
    return $text
}

function Test-EpicMergeGateReviewQueryField {
    <#
    .SYNOPSIS
        True when gh api graphql tokens carry a query field and every one is read-only (pure).
    .PARAMETER Token
        The tokens of the invocation.
    .PARAMETER StartIndex
        The position just past the subcommand path.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token,
        [Parameter(Mandatory)][int] $StartIndex
    )

    $found = $false
    for ($index = $StartIndex; $index -lt $Token.Count; $index++) {
        if ($Token[$index].StartsWith('--input', [System.StringComparison]::Ordinal)) { return $false }
        if ($script:EpicMergeGateReviewFieldFlags -cnotcontains $Token[$index] -or $index + 1 -ge $Token.Count) { continue }
        $field = $Token[$index + 1]
        if (-not $field.StartsWith('query=', [System.StringComparison]::Ordinal)) { continue }
        if ($field -cnotmatch '\Aquery=\s*(?:query|\{)') { return $false }
        $found = $true
    }
    return $found
}

function Test-EpicMergeGateReviewGraphqlReadOnly {
    <#
    .SYNOPSIS
        True when every gh api graphql occurrence of a command is proven read-only (pure).
    .DESCRIPTION
        Each textual occurrence must be a structural invocation, after leading shell keywords, whose
        query field is a literal query, with no --input token and no word mutation in the text. A
        command with no occurrence returns $true. The proof does not require a sole segment, so a
        poll loop around the query stays allowed. An argument-injected record proves nothing.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $scan = ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText
    $occurrences = [regex]::Matches($scan, $script:EpicMergeGateReviewGraphqlPattern).Count
    if ($occurrences -eq 0) { return $true }
    if ([regex]::IsMatch($scan, $script:EpicMergeGateReviewMutationPattern)) { return $false }

    $option = Get-CommandLineGlobalOption -CommandWord 'gh'
    $proven = 0
    foreach ($record in @(Read-CommandLineInvocationSegment -CommandText $CommandText)) {
        if ($record.ArgumentInjected) { continue }
        $tokens = [string[]]@($record.Tokens)
        $start = 0
        while ($start -lt $tokens.Count -and $script:EpicMergeGateReviewShellKeywords -ccontains $tokens[$start]) { $start++ }
        $command = [string[]]@($tokens | Select-Object -Skip $start)
        $walk = Get-CommandLineStructuralWalk -Token $command -CommandWord 'gh' -SubcommandPath @('api', 'graphql') -Option $option
        if ($walk.Outcome -ceq 'Match' -and (Test-EpicMergeGateReviewQueryField -Token $command -StartIndex $walk.OperandIndex)) { $proven++ }
    }
    return $proven -eq $occurrences
}

function Test-EpicMergeGateReviewApiTrigger {
    <#
    .SYNOPSIS
        True when command text could reach a merge through an API (pure).
    .DESCRIPTION
        Names a merge or enqueue mutation, holds a pulls/<segment>/merge path, or holds a gh api
        graphql occurrence that is not proven read-only.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    foreach ($scan in @((ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText), (ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText -RemoveBacktick))) {
        if ((Test-EpicMergeGateApiMutationText -Text $scan) -or [regex]::IsMatch($scan, $script:EpicMergeGateReviewRestPattern)) { return $true }
    }
    return -not (Test-EpicMergeGateReviewGraphqlReadOnly -CommandText $CommandText)
}

function Test-EpicMergeGateReviewMergeText {
    <#
    .SYNOPSIS
        True when command text could be a merge (pure).
    .DESCRIPTION
        The trigger needs no gh word, so it also reads a variable or path in the command position
        and an alias definition. It is deliberately wider than the scope predicate, and it decides
        only whether the shape rule looks further: without the key the decision does not change.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText)

    if ([string]::IsNullOrEmpty($CommandText)) { return $false }
    foreach ($scan in @((ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText), (ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText -RemoveBacktick))) {
        if ([regex]::IsMatch($scan, $script:EpicMergeGateReviewMergePattern) -or [regex]::IsMatch($scan, $script:EpicMergeGateReviewDynamicPattern)) { return $true }
    }
    return Test-EpicMergeGateReviewApiTrigger -CommandText $CommandText
}

function Get-EpicMergeGateReviewBoundTokenNumber {
    <#
    .SYNOPSIS
        Return the one all-digit selector of gh pr merge tokens, or $null (pure).
    .DESCRIPTION
        The first three tokens must equal gh, pr, and merge ordinally. The rest must hold exactly
        one selector and otherwise only allowlisted flags, each value flag with a literal value.
    .PARAMETER Token
        The tokens of the one segment.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    if ($Token.Count -lt 4 -or $Token[0] -cne 'gh' -or $Token[1] -cne 'pr' -or $Token[2] -cne 'merge') { return $null }
    $selector = $null
    for ($index = 3; $index -lt $Token.Count; $index++) {
        $current = $Token[$index]
        if ($script:EpicMergeGateReviewBoundFlags -ccontains $current) { continue }
        if ($script:EpicMergeGateReviewBoundValueFlags -ccontains $current) {
            $index++
            if ($index -ge $Token.Count -or -not (Test-CommandLineTokenLiteral -Token $Token[$index])) { return $null }
            continue
        }
        if ($null -ne $selector -or $current -cnotmatch '\A[0-9]+\z') { return $null }
        $selector = $current
    }
    $number = 0
    if ($null -ne $selector -and [int]::TryParse($selector, [ref] $number)) { return $number }
    return $null
}

function Get-EpicMergeGateReviewBoundPrNumber {
    <#
    .SYNOPSIS
        Return the pull request number of a command that is one plain merge, or $null (pure).
    .DESCRIPTION
        The command must be exactly one top-level segment, balanced and not opaque, that ends the
        text and spans all of it, so nothing runs before or after the merge. The text must hold one
        pr merge occurrence and no API trigger. Any other text is not bound, which makes a chain
        with a readable number unsafe even though the head lookup would pass.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $records = @(Read-CommandLineInvocationSegment -CommandText $CommandText)
    if ($records.Count -ne 1) { return $null }
    $record = $records[0]
    if ($record.Origin -cne 'TopLevel' -or $record.Unbalanced -or $record.Opaque -or $record.Delimiter.Length -ne 0) { return $null }
    if ($record.RawText.Trim() -cne (ConvertTo-CommandLineNormalizedText -CommandText $CommandText).Trim()) { return $null }
    foreach ($scan in @((ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText), (ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText -RemoveBacktick))) {
        if ([regex]::Matches($scan, $script:EpicMergeGateReviewMergePattern).Count -ne 1) { return $null }
    }
    if (Test-EpicMergeGateReviewApiTrigger -CommandText $CommandText) { return $null }
    return Get-EpicMergeGateReviewBoundTokenNumber -Token ([string[]]@($record.Tokens))
}

function Get-EpicMergeGateReviewCandidatePrNumber {
    <#
    .SYNOPSIS
        Return the distinct digit runs of command text that are not part of a longer word (pure).
    .DESCRIPTION
        A number the shape rule cannot bind may still name an item, because a parallel parent
        issues a child's merge from its own root, so each run is a candidate for a checkpoint read.
    .OUTPUTS
        System.Int32[]
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $scan = ConvertTo-EpicMergeGateReviewScanText -CommandText $CommandText
    $candidates = [System.Collections.Generic.List[int]]::new()
    foreach ($match in [regex]::Matches($scan, '(?<![\w-])[0-9]+(?![\w-])')) {
        $number = 0
        if ([int]::TryParse($match.Value, [ref] $number) -and -not $candidates.Contains($number)) { $candidates.Add($number) }
    }
    return [int[]]$candidates.ToArray()
}

function Get-EpicMergeGateReviewShapeDecision {
    <#
    .SYNOPSIS
        Deny text that could be a merge and cannot be bound to one pull request (shape rule).
    .DESCRIPTION
        A bound command passes with no read, so the guard then decides it. Otherwise the decision
        denies when a known checkpoint, or any checkpoint the reader returns, carries the key, and
        passes when none does. Without the key the decision is therefore unchanged, and a failed
        read is best-effort: it sees no key and never denies. The reader is called for the session
        ($null) only when KnownPrNumber is set, because a bare command already read it, and for each
        candidate number other than KnownPrNumber. The Codex gate passes no reader.
    .PARAMETER CommandText
        The raw command text.
    .PARAMETER KnownCheckpoint
        The parsed checkpoint the gate already read, or $null.
    .PARAMETER KnownPrNumber
        The number that checkpoint was read for, or $null for the session.
    .PARAMETER ReadCheckpoint
        Returns the parsed checkpoint of a number, or of the session for $null.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Denied and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [AllowNull()] $KnownCheckpoint,
        [AllowNull()][Nullable[int]] $KnownPrNumber,
        [scriptblock] $ReadCheckpoint
    )

    $pass = [ordered]@{ Denied = $false; Reason = $null }
    if ($null -ne (Get-EpicMergeGateReviewBoundPrNumber -CommandText $CommandText)) { return $pass }

    $deny = [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: review_mode concurrent requires a merge that can be bound to one pull request. Issue gh pr merge <PR> --merge as its own Bash call, and remove the phrase from any other command.' }
    if (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $KnownCheckpoint) { return $deny }
    if ($null -eq $ReadCheckpoint) { return $pass }

    $targets = [System.Collections.Generic.List[object]]::new()
    if ($null -ne $KnownPrNumber) { $targets.Add($null) }
    foreach ($candidate in @(Get-EpicMergeGateReviewCandidatePrNumber -CommandText $CommandText)) {
        if ($candidate -ne $KnownPrNumber) { $targets.Add($candidate) }
    }
    foreach ($target in $targets) {
        $checkpoint = $null
        try {
            $checkpoint = & $ReadCheckpoint $target
        }
        catch {
            # Best-effort read: a failure sees no key, so a run without the key keeps its decision.
            $checkpoint = $null
        }
        if (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $checkpoint) { return $deny }
    }
    return $pass
}

function Read-EpicMergeGateReviewItemCheckpoint {
    <#
    .SYNOPSIS
        Return the parsed checkpoint of a number, or of the session for $null (Claude only).
    .DESCRIPTION
        Runs at run time in the Claude gate, which holds the functions it calls. The read is
        best-effort: an unresolved target and any failure of the resolver or the read return $null,
        so a run without the key keeps its decision and a failure never denies.
    .PARAMETER PrNumber
        The pull request number, or $null for the session.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    param([AllowNull()][Nullable[int]] $PrNumber)

    try {
        $root = $null
        if ($null -eq $PrNumber) {
            $root = Get-EpicMergeGateSessionWorktreeRoot
        }
        else {
            $target = Resolve-EpicMergeGateItemTarget -PrNumber $PrNumber
            if (@('SessionRoot', 'OtherWorktree') -contains $target.Status) { $root = $target.WorktreeRoot }
        }
        if (-not $root) { return $null }
        return ConvertFrom-EpicMergeGateJson -Raw (Get-ChildOrchestratorCheckpointContent -Path (Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot $root))
    }
    catch {
        # Best-effort read: the caller treats $null as a checkpoint without the key.
        return $null
    }
}

function Get-EpicMergeGateReviewUnscopedDecision {
    <#
    .SYNOPSIS
        Apply the shape rule to a command the scope predicate does not read (Claude only).
    .DESCRIPTION
        Reads through Read-EpicMergeGateReviewItemCheckpoint, so a command that today reaches the
        out-of-scope allow can never fail on the gate's own target read.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Denied and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $number = Get-EpicMergeGateSelectorPrNumber -CommandText $CommandText
    $known = Read-EpicMergeGateReviewItemCheckpoint -PrNumber $number
    return Get-EpicMergeGateReviewShapeDecision -CommandText $CommandText -KnownCheckpoint $known -KnownPrNumber $number -ReadCheckpoint ${function:Read-EpicMergeGateReviewItemCheckpoint}
}
