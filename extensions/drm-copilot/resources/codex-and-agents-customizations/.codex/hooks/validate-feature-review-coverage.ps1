<#
.SYNOPSIS
    SubagentStop hook that validates feature-review coverage verdicts against the branch diff.

.DESCRIPTION
    Runs when the feature-review subagent terminates. Cross-checks the policy audit that the
    reviewer names in its final message (last_assistant_message) against the PR context
    summary at artifacts/pr_context.summary.txt and against existing coverage artifacts
    (issue #1114).

    Target selection (feature-review-coverage-target.ps1):
      - The policy-audit paths named in the message are extracted; an absolute path resolves
        its item root through Resolve-HookTargetWorktree (hook-target-worktree.ps1), and a
        relative path uses the session root (the repository holding this hook).
      - Several audits of one feature folder select the greatest timestamp. Audits of
        different folders, paths in different worktrees, a '..' segment, or a named audit
        that does not exist beneath the item root block once. A message that names no audit
        blocks once and asks for the policy-audit path; there is no recency fallback
        (decision D2).
      - The audit, the PR context summary, the root CLAUDE.md, and the coverage reports are
        read beneath the item root.
      - When the item root differs from the session root, the freshness decision of
        validate-feature-review-coverage-freshness.ps1 blocks on an absent PR context
        summary, an absent report for a changed language, a report older than the newest
        item commit touching that language, or a failed git query. No freshness probe runs
        when the item root is the session root (decision D1, as on Claude for issue #1105).

    Validation rules:
      - Enumerate languages that have changed files in the branch diff:
          .ts / .tsx            -> TypeScript
          .py                   -> Python
          .ps1 / .psm1          -> PowerShell
          .cs                   -> CSharp
      - For each language with one or more changed files, the policy audit must contain
        a coverage-scoped row or line that states an explicit PASS or FAIL verdict for
        that language. Scope-narrowing phrases on those rows are treated as validation
        failures:
          "informational only", "context only", "out of plan scope", "out of scope",
          "not applicable", "N/A", "UNVERIFIED".
        The record "N/A - no pre-change run" is not narrowing in three positions: after
        "Baseline:" or "baseline coverage artifact:", as the fifth table cell, and as a
        backticked quotation not directly after a colon. "Change: N/A" on a line carrying
        "Baseline: N/A - no pre-change run" is not narrowing either.
      - If the coverage artifact for a language is present, repo-wide line coverage is
        parsed and compared against the governing line floor: the line coverage
        threshold the repository's root CLAUDE.md states, otherwise the 85 percent
        default (read by Get-FeatureReviewCoverageThreshold from this directory's
        feature-review-coverage-thresholds.ps1); an absent root CLAUDE.md uses the
        defaults, and an unreadable root CLAUDE.md fails closed. When repo-wide coverage
        is below the governing line floor and the audit does not carry a FAIL verdict on
        a coverage row for that language, validation fails. The Codex hook enforces the
        line floor only.

    Coverage artifact paths by language:
        TypeScript  coverage/lcov.info                          (LCOV text)
        Python      artifacts/python/lcov.info                  (LCOV text)
        PowerShell  artifacts/pester/powershell-coverage.xml    (JaCoCo XML)
        CSharp      artifacts/csharp/coverage.xml               (JaCoCo XML)

    Reads one Codex SubagentStop payload from stdin. On validation failure, the hook
    requests one continuation with decision=block and exit 0. If stop_hook_active is
    already true, it emits continue=false to avoid a continuation loop. Malformed input
    fails closed with exit 2 and the reason on stderr.

.NOTES
    Compatible with PowerShell 7+.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'hook-target-worktree.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-freshness.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-freshness.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'feature-review-coverage-target.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-target.ps1' -ErrorRecord $_ }

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
}

function Get-ChangedLanguageSet {
    [OutputType([System.Collections.Hashtable])]
    param([string]$RepoRoot)

    $prSummary = Join-Path $RepoRoot 'artifacts/pr_context.summary.txt'
    $langs = [ordered]@{}
    if (-not (Test-Path $prSummary)) { return $langs }

    foreach ($line in Get-Content -Path $prSummary) {
        if ($line -notmatch '^\s*-\s+(\S+)\s+\(\+\d+/-\d+\)\s*$') { continue }
        $path = $matches[1]
        $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
        switch -Regex ($ext) {
            '^\.(ts|tsx)$' { $langs['TypeScript'] = $true }
            '^\.py$' { $langs['Python']     = $true }
            '^\.(ps1|psm1)$' { $langs['PowerShell'] = $true }
            '^\.cs$' { $langs['CSharp']     = $true }
        }
    }
    return $langs
}

function Get-LcovRepoCoverage {
    [OutputType([Nullable[double]])]
    param([string]$Path)

    if (-not (Test-Path $Path)) { return $null }

    $totalFound = 0
    $totalHit = 0
    foreach ($line in Get-Content -Path $Path) {
        if ($line.StartsWith('LF:')) {
            $totalFound += [int]($line.Substring(3))
        }
        elseif ($line.StartsWith('LH:')) {
            $totalHit += [int]($line.Substring(3))
        }
    }
    if ($totalFound -le 0) { return $null }
    return [math]::Round(($totalHit * 100.0) / $totalFound, 2)
}

function Get-JacocoRepoCoverage {
    [OutputType([Nullable[double]])]
    param([string]$Path)

    if (-not (Test-Path $Path)) { return $null }

    [xml]$doc = Get-Content -Path $Path -Raw
    $counters = $doc.SelectNodes('//counter[@type="LINE"]')
    if (-not $counters -or $counters.Count -eq 0) { return $null }

    $missed = 0
    $covered = 0
    foreach ($counter in $counters) {
        $missed += [int]$counter.missed
        $covered += [int]$counter.covered
    }
    $total = $missed + $covered
    if ($total -le 0) { return $null }
    return [math]::Round(($covered * 100.0) / $total, 2)
}

function Get-LanguageRepoCoverage {
    [OutputType([Nullable[double]])]
    param(
        [string]$RepoRoot,
        [string]$Language
    )

    switch ($Language) {
        'TypeScript' { return Get-LcovRepoCoverage -Path (Join-Path $RepoRoot 'coverage/lcov.info') }
        'Python' { return Get-LcovRepoCoverage -Path (Join-Path $RepoRoot 'artifacts/python/lcov.info') }
        'PowerShell' { return Get-JacocoRepoCoverage -Path (Join-Path $RepoRoot 'artifacts/pester/powershell-coverage.xml') }
        'CSharp' { return Get-JacocoRepoCoverage -Path (Join-Path $RepoRoot 'artifacts/csharp/coverage.xml') }
    }
    return $null
}

function Get-CoverageNarrowingLine {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory = $true)]
        [string]$LabelPattern,

        [Parameter(Mandatory = $true)]
        [string]$Language
    )

    # Sanctioned narrowing text is not a scope narrowing by the audit: a line inside a
    # '## Rejected Scope Narrowing' section (caller text recorded verbatim), and a PowerShell
    # line naming branch coverage but not line coverage (Pester measures no branch coverage).
    # The policy-audit template prescribes the no-pre-change-run record in three positions only,
    # so the record is removed there and stays a narrowing form everywhere else.
    $narrowingPattern = '(?i)(informational only|context only|out of plan scope|out of scope|not applicable|\bN/A\b|\bUNVERIFIED\b)'
    $recordPatterns = @(
        '(?<=(?:\bBaseline|\bbaseline coverage artifact):\s*)N/A - no pre-change run'
        '(?<=^\s*\|(?:[^|]*\|){4}\s*)N/A - no pre-change run(?=\s*\|)'
        '(?<!:\s*)`N/A - no pre-change run`'
    )
    $insideRejectedSection = $false
    foreach ($line in $Lines) {
        if ($line -match '^##\s') { $insideRejectedSection = $line -match '^##\s+Rejected Scope Narrowing\b' }
        elseif ($insideRejectedSection) { continue }
        if ($line -notmatch $LabelPattern -or $line -notmatch '(?i)(coverage|lcov|line[s]?\s+hit|pester)') { continue }
        $reducedLine = $line
        foreach ($recordPattern in $recordPatterns) { $reducedLine = [regex]::Replace($reducedLine, $recordPattern, '') }
        # Tested on the original line, because the removals above strip the record it names.
        if ($line.Contains('Baseline: N/A - no pre-change run')) {
            $reducedLine = [regex]::Replace($reducedLine, '(?<![\w/-])Change: N/A', '')
            $reducedLine = $reducedLine.Replace('New/changed-code coverage: N/A - no production file changed', '')
        }
        if ($reducedLine -notmatch $narrowingPattern) { continue }
        if ($Language -eq 'PowerShell' -and $line -match '(?i)\bbranch\b' -and $line -notmatch '(?i)\bline\s+coverage\b') { continue }
        $line
    }
}

function Test-LanguageCoverageRow {
    [OutputType([System.Collections.Hashtable])]
    param(
        [string]$AuditText,
        [string]$Language,
        [Nullable[double]]$RepoWidePct,
        [double] $LineFloor = 85.0
    )

    $languageLabelMap = @{
        'TypeScript' = @('TypeScript', 'typescript')
        'Python'     = @('Python', 'python', 'pytest')
        'PowerShell' = @('PowerShell', 'powershell', 'pester')
        'CSharp'     = @('C#', 'CSharp', 'csharp', '.NET', 'dotnet')
    }

    $labels = $languageLabelMap[$Language]
    $labelPattern = '(?i)(' + (($labels | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')'

    $lines = $AuditText -split "`r?`n"
    $languageLines = $lines | Where-Object { $_ -match $labelPattern }

    if (-not $languageLines -or $languageLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but the policy-audit does not mention $Language."
        }
    }

    $coverageLines = $languageLines | Where-Object { $_ -match '(?i)(coverage|lcov|line[s]?\s+hit|pester)' }
    if (-not $coverageLines -or $coverageLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but no coverage-scoped row in the policy-audit mentions $Language."
        }
    }

    $narrowing = @(Get-CoverageNarrowingLine -Lines $lines -LabelPattern $labelPattern -Language $Language)
    if ($narrowing.Count -gt 0) {
        $first = ($narrowing | Select-Object -First 1).ToString().Trim()
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but a coverage-scoped row narrows scope: '$first'. Scope narrowing is not permitted for languages with changed files."
        }
    }

    $verdictLines = $coverageLines | Where-Object { $_ -match '\b(PASS|FAIL)\b' }
    if (-not $verdictLines -or $verdictLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language coverage rows contain neither a PASS nor a FAIL verdict."
        }
    }

    if ($null -ne $RepoWidePct -and $RepoWidePct -lt $LineFloor) {
        $failLines = $coverageLines | Where-Object { $_ -match '\bFAIL\b' }
        if (-not $failLines -or $failLines.Count -eq 0) {
            return @{
                Ok     = $false
                Reason = ("{0} repo-wide coverage is {1}% (below the {2}% line coverage floor) but the policy-audit contains no FAIL verdict on a coverage row for {0}." -f $Language, $RepoWidePct, $LineFloor)
            }
        }
    }

    return @{ Ok = $true; Reason = $null }
}

function Get-FeatureReviewCoverageContinuation {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $Reason,
        [Parameter(Mandatory)][bool] $StopHookActive
    )

    if ($StopHookActive) {
        return [ordered]@{
            continue      = $false
            stopReason    = $Reason
            systemMessage = $Reason
        }
    }
    return [ordered]@{
        decision = 'block'
        reason   = $Reason
    }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('validate-feature-review-coverage: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

try {
    $payloadRaw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($payloadRaw)) {
        throw 'validate-feature-review-coverage hook input is empty.'
    }
    try {
        $payload = $payloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "validate-feature-review-coverage hook input is malformed JSON: $_"
    }
    if ($payload.PSObject.Properties.Name -notcontains 'stop_hook_active' -or
        $payload.stop_hook_active -isnot [bool]) {
        throw 'validate-feature-review-coverage hook input requires boolean stop_hook_active.'
    }
    if ([string]$payload.hook_event_name -ne 'SubagentStop' -or
        @('feature-review', 'feature-reviewer') -notcontains [string]$payload.agent_type) {
        throw 'validate-feature-review-coverage requires a feature-review SubagentStop payload.'
    }
    $stopHookActive = [bool]$payload.stop_hook_active

    $repoRoot = Get-RepoRoot
    $message = if ($payload.PSObject.Properties.Name -contains 'last_assistant_message') { $payload.last_assistant_message } else { $null }
    $target = Resolve-CodexReviewCoverageTarget -Message $message -SessionRoot $repoRoot
    if ($null -ne $target.ReasonCode) {
        $reason = "Feature-review coverage validation cannot select the policy audit ($($target.ReasonCode)): $($target.Reason)"
        Get-FeatureReviewCoverageContinuation -Reason $reason -StopHookActive $stopHookActive |
            ConvertTo-Json -Compress -Depth 5 |
                Write-Output
        exit 0
    }

    $itemRoot = $target.ItemRoot
    $auditPath = "$itemRoot/$($target.AuditRelativePath)"
    $auditText = Get-Content -Path $auditPath -Raw
    $changedLanguages = Get-ChangedLanguageSet -RepoRoot $itemRoot

    $freshness = Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot $itemRoot -SessionRoot $repoRoot -Source $target.Source -ChangedLanguage $changedLanguages -GitInvoker { param($Root, $Pathspec) Invoke-CodexReviewCoverageGitLog -Root $Root -Pathspec $Pathspec }
    if ($null -ne $freshness) {
        $reason = "Feature-review coverage inputs in the item worktree are absent or stale.`n  - " + ($freshness.Reasons -join "`n  - ") + "`nAudit file: $auditPath"
        Get-FeatureReviewCoverageContinuation -Reason $reason -StopHookActive $stopHookActive |
            ConvertTo-Json -Compress -Depth 5 |
                Write-Output
        exit 0
    }

    if ($changedLanguages.Count -eq 0) {
        exit 0
    }

    $claudeMdPath = Join-Path $itemRoot 'CLAUDE.md'
    $claudeMdText = $null
    if (Test-Path -Path $claudeMdPath) { try { $claudeMdText = Get-Content -Path $claudeMdPath -Raw -ErrorAction Stop } catch { throw "root CLAUDE.md exists but could not be read ($(([string]$_.Exception.Message -split "`r?`n")[0])); coverage floors cannot be resolved, so the gate fails closed." } }
    $thresholds = Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMdText

    $failures = [System.Collections.Generic.List[string]]::new()

    foreach ($lang in $changedLanguages.Keys) {
        $repoPct = Get-LanguageRepoCoverage -RepoRoot $itemRoot -Language $lang
        $result = Test-LanguageCoverageRow -AuditText $auditText -Language $lang -RepoWidePct $repoPct -LineFloor $thresholds.Line
        if (-not $result.Ok) {
            $failures.Add($result.Reason)
        }
    }

    if ($failures.Count -gt 0) {
        $header = "Feature-review coverage validation failed against branch diff."
        $body   = "  - " + ($failures -join "`n  - ")
        $footer = "Audit file: $auditPath`nFix the policy-audit to carry an explicit PASS or FAIL verdict per language with changed files, and reflect repo-wide coverage below the governing line coverage floor ($($thresholds.Line)%) as FAIL."
        $reason = "{0}`n{1}`n{2}" -f $header, $body, $footer
        Get-FeatureReviewCoverageContinuation -Reason $reason -StopHookActive $stopHookActive |
            ConvertTo-Json -Compress -Depth 5 |
                Write-Output
        exit 0
    }

    exit 0
}
catch {
    $reason = "Feature-review coverage validator error: $($_.Exception.Message)"
    if ($null -ne $stopHookActive -and $stopHookActive) {
        Get-FeatureReviewCoverageContinuation -Reason $reason -StopHookActive $true |
            ConvertTo-Json -Compress -Depth 5 |
                Write-Output
        exit 0
    }
    [Console]::Error.WriteLine($reason)
    exit 2
}
