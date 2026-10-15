# Baseline static scan ([P0-T27], fail-before for AC-20 and AC-21, issue #905)

Timestamp: 2026-10-11T14-49
Command: Select-String -Path .claude/hooks/validate-discovery-artifact-gate.ps1,.claude/hooks/validate-pr-author-output.ps1,.claude/hooks/validate-prd-feature-output.ps1,.claude/hooks/validate-task-researcher-output.ps1 -Pattern 'CLAUDE_HOOK_INPUT','\.output\b' ; Select-String -Path <same four paths> -Pattern '\bexit 1\b','Write-Error' ; each also over the four W-MIRRORS paths (run through R-ROUTE, <SCRATCHPAD>/p0-static.ps1)
EXIT_CODE: 0
Output Summary: AC-20 pattern: 29 matches in the four hooks, 29 in the four mirrors. AC-21 pattern: 8 matches in the four hooks, 8 in the four mirrors. All four counts are greater than zero (fail-before established).

```text
SCAN-A-HOOKS (CLAUDE_HOOK_INPUT, \.output\b): 29
SCAN-A-MIRRORS (CLAUDE_HOOK_INPUT, \.output\b): 29
SCAN-B-HOOKS (\bexit 1\b, Write-Error): 8
SCAN-B-MIRRORS (\bexit 1\b, Write-Error): 8
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:8 | generic-agent matcher group. The hook reads $env:CLAUDE_HOOK_INPUT JSON
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:9 | containing .output (the terminating subagent's final text), scans that
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:197 | Parses CLAUDE_HOOK_INPUT and returns an Ok/Message validation result
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:212 | return @{ Ok = $false; Message = 'discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty' }
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:219 | return @{ Ok = $false; Message = "discovery artifact gate hook: CLAUDE_HOOK_INPUT is not valid JSON: $_" }
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:224 | $outputText = [string]$payload.output
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:241 | $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($result.Output)
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:243 | return @{ Ok = $false; Message = "DISCOVERY_ARTIFACT_GATE_BLOCKED: $($result.Output)" }
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:258 | $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:260 | Write-Error $result.Message
MATCH: .claude/hooks/validate-discovery-artifact-gate.ps1:261 | exit 1
MATCH: .claude/hooks/validate-pr-author-output.ps1:7 | transcript JSON from the CLAUDE_HOOK_INPUT environment variable, extracts the .output field,
MATCH: .claude/hooks/validate-pr-author-output.ps1:13 | The hook blocks (exit 1) when:
MATCH: .claude/hooks/validate-pr-author-output.ps1:14 | - CLAUDE_HOOK_INPUT is empty,
MATCH: .claude/hooks/validate-pr-author-output.ps1:16 | - the .output field is empty, or
MATCH: .claude/hooks/validate-pr-author-output.ps1:40 | The pr-author agent's final output text extracted from CLAUDE_HOOK_INPUT.output.
MATCH: .claude/hooks/validate-pr-author-output.ps1:75 | Parse CLAUDE_HOOK_INPUT and return an allow-or-block decision with exit code semantics.
MATCH: .claude/hooks/validate-pr-author-output.ps1:78 | only when the parsed .output reports a PR per Test-PrAuthorOutputReportsPr. Empty input,
MATCH: .claude/hooks/validate-pr-author-output.ps1:81 | The raw JSON transcript payload supplied by Claude Code via CLAUDE_HOOK_INPUT.
MATCH: .claude/hooks/validate-pr-author-output.ps1:96 | reason  = 'PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.'
MATCH: .claude/hooks/validate-pr-author-output.ps1:105 | reason  = 'PR_AUTHOR_OUTPUT_MALFORMED: CLAUDE_HOOK_INPUT is not valid JSON.'
MATCH: .claude/hooks/validate-pr-author-output.ps1:109 | $outputText = [string]$parsed.output
MATCH: .claude/hooks/validate-pr-author-output.ps1:135 | $decision = Get-PrAuthorOutputDecision -HookInputRaw $env:CLAUDE_HOOK_INPUT
MATCH: .claude/hooks/validate-pr-author-output.ps1:138 | Write-Error $decision['reason']
MATCH: .claude/hooks/validate-pr-author-output.ps1:139 | exit 1
MATCH: .claude/hooks/validate-prd-feature-output.ps1:78 | if ([string]::IsNullOrWhiteSpace($RawPayload)) { return @{ Ok = $false; Message = 'prd-feature hook: CLAUDE_HOOK_INPUT is empty.' } }
MATCH: .claude/hooks/validate-prd-feature-output.ps1:79 | try { $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop } catch { return @{ Ok = $false; Message = "prd-feature hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" } }
MATCH: .claude/hooks/validate-prd-feature-output.ps1:80 | $output = if ($null -ne $payload.PSObject.Properties['output']) { $payload.output } else { $null }
MATCH: .claude/hooks/validate-prd-feature-output.ps1:95 | $result = Invoke-PrdFeatureOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: .claude/hooks/validate-prd-feature-output.ps1:96 | if (-not $result.Ok) { Write-Error $result.Message; exit 1 }
MATCH: .claude/hooks/validate-task-researcher-output.ps1:14 | Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
MATCH: .claude/hooks/validate-task-researcher-output.ps1:234 | return @{ Ok = $false; Message = 'task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output.' }
MATCH: .claude/hooks/validate-task-researcher-output.ps1:241 | return @{ Ok = $false; Message = "task-researcher hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
MATCH: .claude/hooks/validate-task-researcher-output.ps1:246 | $agentOutput = $payload.output
MATCH: .claude/hooks/validate-task-researcher-output.ps1:288 | $result = Invoke-TaskResearcherOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: .claude/hooks/validate-task-researcher-output.ps1:290 | Write-Error $result.Message
MATCH: .claude/hooks/validate-task-researcher-output.ps1:291 | exit 1
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:8 | generic-agent matcher group. The hook reads $env:CLAUDE_HOOK_INPUT JSON
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:9 | containing .output (the terminating subagent's final text), scans that
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:197 | Parses CLAUDE_HOOK_INPUT and returns an Ok/Message validation result
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:212 | return @{ Ok = $false; Message = 'discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty' }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:219 | return @{ Ok = $false; Message = "discovery artifact gate hook: CLAUDE_HOOK_INPUT is not valid JSON: $_" }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:224 | $outputText = [string]$payload.output
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:241 | $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($result.Output)
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:243 | return @{ Ok = $false; Message = "DISCOVERY_ARTIFACT_GATE_BLOCKED: $($result.Output)" }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:258 | $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:260 | Write-Error $result.Message
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1:261 | exit 1
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:7 | transcript JSON from the CLAUDE_HOOK_INPUT environment variable, extracts the .output field,
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:13 | The hook blocks (exit 1) when:
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:14 | - CLAUDE_HOOK_INPUT is empty,
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:16 | - the .output field is empty, or
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:40 | The pr-author agent's final output text extracted from CLAUDE_HOOK_INPUT.output.
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:75 | Parse CLAUDE_HOOK_INPUT and return an allow-or-block decision with exit code semantics.
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:78 | only when the parsed .output reports a PR per Test-PrAuthorOutputReportsPr. Empty input,
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:81 | The raw JSON transcript payload supplied by Claude Code via CLAUDE_HOOK_INPUT.
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:96 | reason  = 'PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.'
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:105 | reason  = 'PR_AUTHOR_OUTPUT_MALFORMED: CLAUDE_HOOK_INPUT is not valid JSON.'
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:109 | $outputText = [string]$parsed.output
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:135 | $decision = Get-PrAuthorOutputDecision -HookInputRaw $env:CLAUDE_HOOK_INPUT
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:138 | Write-Error $decision['reason']
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1:139 | exit 1
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1:78 | if ([string]::IsNullOrWhiteSpace($RawPayload)) { return @{ Ok = $false; Message = 'prd-feature hook: CLAUDE_HOOK_INPUT is empty.' } }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1:79 | try { $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop } catch { return @{ Ok = $false; Message = "prd-feature hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" } }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1:80 | $output = if ($null -ne $payload.PSObject.Properties['output']) { $payload.output } else { $null }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1:95 | $result = Invoke-PrdFeatureOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1:96 | if (-not $result.Ok) { Write-Error $result.Message; exit 1 }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:14 | Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:234 | return @{ Ok = $false; Message = 'task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output.' }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:241 | return @{ Ok = $false; Message = "task-researcher hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:246 | $agentOutput = $payload.output
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:288 | $result = Invoke-TaskResearcherOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:290 | Write-Error $result.Message
MATCH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1:291 | exit 1
```
