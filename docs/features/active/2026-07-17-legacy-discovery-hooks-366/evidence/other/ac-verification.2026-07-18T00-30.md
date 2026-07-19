# Acceptance Criteria Verification

- Timestamp: 2026-07-18T00-30
- Feature: 2026-07-17-legacy-discovery-hooks-366

## [P3-T1] AC: "One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators"

Evidence (both hook files call `Invoke-DiscoveryValidatorExe`, which invokes `python -m scripts.dev_tools.validate_discovery_artifacts`):

- `.claude/hooks/enforce-discovery-artifact-gate.ps1:50` — `$output = & python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` (inside `Invoke-DiscoveryValidatorExe`, defined lines 34-52).
- `.claude/hooks/enforce-discovery-artifact-gate.ps1:182` (function `Invoke-DiscoveryArtifactGateDecision`) — `$result = Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $filePath)`.
- `.claude/hooks/validate-discovery-artifact-gate.ps1:53` — `$output = & python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` (inside `Invoke-DiscoveryValidatorExe`, defined lines 37-55).
- `.claude/hooks/validate-discovery-artifact-gate.ps1:215` (function `Invoke-DiscoveryArtifactGateValidation`) — `$result = Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $reference)`.

**Result: PASS.** Both hooks route exclusively to the validator CLI; neither reimplements validator logic.

## [P3-T2] AC: "Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard"

Evidence:

- Dot-source guard, `enforce-discovery-artifact-gate.ps1:199-201`: `if ($MyInvocation.InvocationName -eq '.') { return }`.
- Dot-source guard, `validate-discovery-artifact-gate.ps1:227-229`: `if ($MyInvocation.InvocationName -eq '.') { return }`.
- Env-var read, `enforce-discovery-artifact-gate.ps1:204`: `$decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT`.
- Env-var read, `validate-discovery-artifact-gate.ps1:231`: `$result = Invoke-DiscoveryArtifactGateValidation -RawPayload $env:CLAUDE_HOOK_INPUT`.
- PreToolUse JSON serialization, `enforce-discovery-artifact-gate.ps1:211`: `$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output`.

**Result: PASS.**

## [P3-T3] AC: "Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form"

Evidence (`.claude/settings.json`):

- `PreToolUse` -> matcher `"Write|Edit"` (line 121) array now includes, at line 161:
  `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1"}`
  (position: last entry in that matcher group's `hooks` array, after `enforce-completion-consistency.ps1`).
- `SubagentStop` -> matcher `"atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner"` (line 193) array now includes, at line 201:
  `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1"}`
  (position: second entry in that matcher group's `hooks` array, after the existing inline completion-artifact-path check).
- Both entries use the exact standard command form `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/<name>.ps1"}`.
- No other matcher group was modified; `.claude/settings.json` parses as valid JSON (confirmed via `ConvertFrom-Json`).

**Result: PASS.**

## [P3-T4] AC: "Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages)"

Command run (standalone, distinct from the Pester grep-gate tests in P1-T17/P2-T16):

```
pwsh -NoProfile -Command "$m = Select-String -Path '.claude/hooks/enforce-discovery-artifact-gate.ps1','.claude/hooks/validate-discovery-artifact-gate.ps1' -Pattern 'TaskMaster|TMW|Outlook|VSTO'; Write-Output \"MatchCount=$(@($m).Count)\""
```

Result: `MatchCount=0`.

**Result: PASS.**

## [P3-T5] AC: "Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`"

- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` exists, mirroring `.claude/hooks/enforce-discovery-artifact-gate.ps1`.
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` exists, mirroring `.claude/hooks/validate-discovery-artifact-gate.ps1`.
- Both dot-source their respective production file in `BeforeAll` and exercise the decision/validation functions directly.

**Result: PASS.**

## [P3-T6] AC Status Summary

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/spec.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: none

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/user-story.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: none
