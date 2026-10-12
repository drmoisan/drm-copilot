<#
.SYNOPSIS
    SubagentStop hook that validates feature-review artifacts and coverage verdicts.

.DESCRIPTION
    Runs when the feature-review subagent terminates. Validates that the final
    output advertises the required review artifact paths, that those artifacts
    exist in the canonical active-feature location, and that the policy audit
    carries explicit PASS or FAIL coverage verdicts for each language with
    changed files in the branch diff.

    Required advertised output tokens:
      - policy-audit-path
      - code-review-path
      - feature-audit-path

    Optional advertised output token:
      - remediation-inputs-path

    Additional coverage rules:
      - Enumerate languages that have changed files in artifacts/pr_context.summary.txt:
          .ts / .tsx            -> TypeScript
          .py                   -> Python
          .ps1 / .psm1          -> PowerShell
          .cs                   -> CSharp
      - For each changed language, the policy audit must contain a
        coverage-scoped PASS or FAIL verdict.
      - Scope-narrowing phrases on coverage rows are treated as failures.
      - Coverage floors follow the threshold precedence of the pushed quality-tiers
        rule: when the repository's root CLAUDE.md states a line or branch coverage
        threshold, that threshold governs; otherwise the 85 percent line and 75 percent
        branch defaults govern.
      - Each metric falls back independently, so a root CLAUDE.md that states only
        a line threshold leaves the 75 percent branch default in force. The figures are
        read by Get-FeatureReviewCoverageThreshold (feature-review-coverage-thresholds.ps1).
      - When repo-wide line coverage for an available artifact is below the governing
        line threshold, the policy audit must carry a FAIL verdict for that language;
        branch coverage below the governing branch threshold blocks termination.

.NOTES
    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
    termination; exits 1 with an error message to block.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-metrics.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-metrics.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-rules.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-rules.ps1' -ErrorRecord $_ }

$ErrorActionPreference = 'Stop'

function Invoke-FeatureReviewCoverageValidation {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string] $RawPayload
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    if ([string]::IsNullOrWhiteSpace($RawPayload)) {
        return @{ Ok = $false; Message = 'feature-review hook: CLAUDE_HOOK_INPUT is empty; cannot validate review output.' }
    }

    try {
        $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return @{ Ok = $false; Message = "feature-review hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
    }

    $agentOutput = $null
    if ($payload.PSObject.Properties.Name -contains 'output') {
        $agentOutput = $payload.output
    }
    if ([string]::IsNullOrWhiteSpace($agentOutput)) {
        return @{ Ok = $false; Message = 'feature-review hook: agent output is empty; feature-review must report required artifact paths before termination.' }
    }

    $requiredArtifacts = @(
        @{ Token = 'policy-audit-path'; Stem = 'policy-audit'; Description = 'policy audit artifact' },
        @{ Token = 'code-review-path'; Stem = 'code-review'; Description = 'code review artifact' },
        @{ Token = 'feature-audit-path'; Stem = 'feature-audit'; Description = 'feature audit artifact' }
    )

    $artifactMeta = @{}
    $errors = [System.Collections.Generic.List[string]]::new()

    foreach ($artifact in $requiredArtifacts) {
        $path = Get-ReviewArtifactPathFromOutput -AgentOutput $agentOutput -Token $artifact.Token
        if ($null -eq $path) {
            $errors.Add("missing $($artifact.Token): <path> for the required $($artifact.Description)")
            continue
        }

        $metadata = Get-ReviewArtifactInfo -Path $path -Stem $artifact.Stem
        if ($null -eq $metadata) {
            $errors.Add("$($artifact.Token) '$path' is outside the required docs/features/active/.../$($artifact.Stem).<timestamp>.md location")
            continue
        }

        $file = Get-ArtifactFileContent -Path $path
        if (-not $file.Exists) {
            $errors.Add("$($artifact.Token) '$path' was advertised for the $($artifact.Description) but no file exists at that location")
            continue
        }

        $metadata['Text'] = $file.Text
        $artifactMeta[$artifact.Stem] = $metadata
    }

    if ($artifactMeta.ContainsKey('policy-audit')) {
        $reference = $artifactMeta['policy-audit']
        foreach ($stem in @('code-review', 'feature-audit')) {
            if (-not $artifactMeta.ContainsKey($stem)) {
                continue
            }
            $candidate = $artifactMeta[$stem]
            if ($candidate.Folder -ne $reference.Folder -or $candidate.Timestamp -ne $reference.Timestamp) {
                $errors.Add("$stem artifact must share the same feature folder and timestamp as the policy audit artifact.")
            }
        }

        $remediationPath = Get-ReviewArtifactPathFromOutput -AgentOutput $agentOutput -Token 'remediation-inputs-path'
        if ($null -ne $remediationPath) {
            $remediation = Get-ReviewArtifactInfo -Path $remediationPath -Stem 'remediation-inputs'
            if ($null -eq $remediation) {
                $errors.Add("remediation-inputs-path '$remediationPath' is outside the required docs/features/active/.../remediation-inputs.<timestamp>.md location")
            }
            elseif ($remediation.Folder -ne $reference.Folder -or $remediation.Timestamp -ne $reference.Timestamp) {
                $errors.Add('remediation-inputs artifact must share the same feature folder and timestamp as the policy audit artifact.')
            }
            elseif (-not (Get-ArtifactFileContent -Path $remediationPath).Exists) {
                $errors.Add("remediation-inputs-path '$remediationPath' was advertised but no file exists at that location")
            }
        }
    }

    if ($errors.Count -gt 0) {
        $message = "feature-review hook: required review artifact validation failed:`n  - " + ($errors -join "`n  - ")
        return @{ Ok = $false; Message = $message }
    }

    $prSummary = Get-ArtifactFileContent -Path 'artifacts/pr_context.summary.txt'
    $changedLanguages = if ($prSummary.Exists) { Get-ChangedLanguageSet -Lines $prSummary.Lines } else { [ordered]@{} }
    if ($changedLanguages.Count -eq 0) {
        return @{ Ok = $true; Message = $null }
    }

    $policyAuditText = $artifactMeta['policy-audit'].Text
    $claudeMd = Get-ArtifactFileContent -Path 'CLAUDE.md'
    $thresholds = Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMd.Text
    $coverageFailures = [System.Collections.Generic.List[string]]::new()
    foreach ($lang in $changedLanguages.Keys) {
        $repoPct = Get-LanguageRepoCoverage -Language $lang
        $branchPct = Get-LanguageBranchCoverage -Language $lang
        $result = Test-LanguageCoverageRow -AuditText $policyAuditText -Language $lang -RepoWidePct $repoPct -BranchPct $branchPct -LineFloor $thresholds.Line -BranchFloor $thresholds.Branch -LineSource $thresholds.LineSource -BranchSource $thresholds.BranchSource
        if (-not $result.Ok) {
            $coverageFailures.Add($result.Reason)
        }
    }

    if ($coverageFailures.Count -gt 0) {
        $message = "feature-review hook: coverage validation failed against branch diff:`n  - " + ($coverageFailures -join "`n  - ")
        return @{ Ok = $false; Message = $message }
    }

    return @{ Ok = $true; Message = $null }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('validate-feature-review-coverage: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

$result = Invoke-FeatureReviewCoverageValidation -RawPayload $env:CLAUDE_HOOK_INPUT
if (-not $result.Ok) {
    Write-Error $result.Message
    exit 1
}

exit 0
