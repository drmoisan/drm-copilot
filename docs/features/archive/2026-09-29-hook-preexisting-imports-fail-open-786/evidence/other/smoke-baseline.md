# Smoke Baseline for Live Claude Hooks ([P0-T21])

Timestamp: 2026-10-09T22-25
Command: sh <SCRATCHPAD>/r.sh p0t21 (R-SMOKE launch, payload, and normalized capture, run twice for each of the 30 Claude W-HOOKS rows; implementation <SCRATCHPAD>/rlib.ps1 Invoke-RSmoke)
EXIT_CODE: 0
Output Summary: 30 SMOKE-BASELINE lines, every one repeat=same; 24 PreToolUse hooks exit 0 and 6 SubagentStop hooks exit 1; no captured stream contains hook-dependency-guard.ps1 or failed to load.

HOOKS: 30
DIFFERENT: 0
FORBIDDEN-TOKEN lines: none

Per-hook captures (first run; normalized):
SMOKE-BASELINE: .claude/hooks/check-powershell-test-purity.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/check-python-test-purity.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-checkpoint-monotonic.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-completion-consistency.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-discovery-artifact-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-epic-invocation-origin.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-epic-merge-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-epic-wave-barrier.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-evidence-locations.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-feature-folder-order.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-mermaid-validation.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-model-routing-receipt.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-parallel-abandon-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-parallel-drift-gate.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-powershell-batch-budget.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-pr-author-skill.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-prd-feature-before-planner.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-promotion-mcp-only.ps1 | exit=0 | repeat=same
```stdout
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/enforce-python-batch-budget.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/validate-bash.ps1 | exit=0 | repeat=same
```stdout

```
```stderr

```
SMOKE-BASELINE: .claude/hooks/validate-discovery-artifact-gate.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty

```
SMOKE-BASELINE: .claude/hooks/validate-feature-review-coverage.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: <WORKSPACE_ROOT>\.claude\hooks\validate-feature-review-coverage.ps1:<POS>

```
SMOKE-BASELINE: .claude/hooks/validate-orchestrator-output.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:<POS>

```
SMOKE-BASELINE: .claude/hooks/validate-planner-output.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: <WORKSPACE_ROOT>\.claude\hooks\validate-planner-output.ps1:<POS>

```
SMOKE-BASELINE: .claude/hooks/validate-pr-author-output.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.

```
SMOKE-BASELINE: .claude/hooks/validate-prd-feature-output.ps1 | exit=1 | repeat=same
```stdout

```
```stderr
Write-Error: <WORKSPACE_ROOT>\.claude\hooks\validate-prd-feature-output.ps1:<POS>

```
