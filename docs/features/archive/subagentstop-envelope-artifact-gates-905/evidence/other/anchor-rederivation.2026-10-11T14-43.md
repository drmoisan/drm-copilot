# Anchor re-derivation on the merged tree ([P0-T12], issue #905)

Timestamp: 2026-10-11T14-43
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/anchors.ps1
EXIT_CODE: 0
Output Summary: Line counts 264 (discovery), 142 (pr-author), 97 (prd-feature), 294 (task-researcher), as the plan states. All 22 table anchors, the two Exhaustive Search Scope anchors, and the three line-B bootstrap anchors each match exactly one line at the line number of section 3.5. ANCHOR-DRIFT: 0; ANCHOR-MOVED: 0. No deviation recorded.

```text
LINECOUNT: .claude/hooks/validate-discovery-artifact-gate.ps1 | 264
LINECOUNT: .claude/hooks/validate-pr-author-output.ps1 | 142
LINECOUNT: .claude/hooks/validate-prd-feature-output.ps1 | 97
LINECOUNT: .claude/hooks/validate-task-researcher-output.ps1 | 294
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=184 | found=184 | OK | if (Get-DiscoveryArtifactType -Path $trimmed) {
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=224 | found=224 | OK | $outputText = [string]$payload.output
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=240 | found=240 | OK | $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $reference)
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=241 | found=241 | OK | $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($result.Output)
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=258 | found=258 | OK | $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $env:CLAUDE_HOOK_INPUT
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=260 | found=260 | OK | Write-Error $result.Message
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=261 | found=261 | OK | exit 1
ANCHOR: .claude/hooks/validate-pr-author-output.ps1 | expected=109 | found=109 | OK | $outputText = [string]$parsed.output
ANCHOR: .claude/hooks/validate-pr-author-output.ps1 | expected=135 | found=135 | OK | $decision = Get-PrAuthorOutputDecision -HookInputRaw $env:CLAUDE_HOOK_INPUT
ANCHOR: .claude/hooks/validate-pr-author-output.ps1 | expected=138 | found=138 | OK | Write-Error $decision['reason']
ANCHOR: .claude/hooks/validate-pr-author-output.ps1 | expected=139 | found=139 | OK | exit 1
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=68 | found=68 | OK | return $section.Success -and [regex]::IsMatch($section.Value, '(?m)^\s*[-*]\s*\[.\].*\b\d+\b')
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=80 | found=80 | OK | $output = if ($null -ne $payload.PSObject.Properties['output']) { $payload.output } else { $null }
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=95 | found=95 | OK | $result = Invoke-PrdFeatureOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=96 | found=96 | OK | if (-not $result.Ok) { Write-Error $result.Message; exit 1 }
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=21 | found=21 | OK | param()
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=97 | found=97 | OK | '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$'
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=246 | found=246 | OK | $agentOutput = $payload.output
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=284 | found=284 | OK | if ($MyInvocation.InvocationName -eq '.') {
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=288 | found=288 | OK | $result = Invoke-TaskResearcherOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=290 | found=290 | OK | Write-Error $result.Message
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=291 | found=291 | OK | exit 1
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=42 | found=42 | OK | if ($values['Exhaustive Search Scope'] -notmatch '(?i)\b(entire|all|complete)\b.*\b(repository|repo|source tree|tree)\b') { return @{ Ok = $false; Message = 'prd-feature hook: numeric derivation evidence does not declare an exhaustive repository search scope.' } }
ANCHOR: .claude/hooks/validate-task-researcher-output.ps1 | expected=195 | found=195 | OK | if ($values['Exhaustive Search Scope'] -notmatch '(?i)\b(entire|all|complete)\b.*\b(repository|repo|source tree|tree)\b') {
ANCHOR: .claude/hooks/validate-discovery-artifact-gate.ps1 | expected=38 | found=38 | OK | $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
ANCHOR: .claude/hooks/validate-pr-author-output.ps1 | expected=30 | found=30 | OK | $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
ANCHOR: .claude/hooks/validate-prd-feature-output.ps1 | expected=8 | found=8 | OK | $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
ANCHOR-DRIFT: 0
ANCHOR-MOVED: 0
```
