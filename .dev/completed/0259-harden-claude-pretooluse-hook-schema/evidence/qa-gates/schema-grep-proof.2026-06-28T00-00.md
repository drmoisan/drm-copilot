# Phase 16 — Schema Grep Proof

- Timestamp: 2026-06-28T00-00
- Issue: #259

## (a) No PreToolUse hook emits a legacy top-level decision/reason shape

- Pattern: `decision\s*=\s*'(block|allow)'`
  - `.claude/hooks/*.ps1`: 0 matches
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/*.ps1`: 0 matches
- Pattern: `reason\s*=\s*\$Reason` or `decision\s*=\s*\$...` (top-level decision/reason emission)
  - `.claude/hooks/*.ps1`: 0 matches

## (a) PreToolUse hooks emit the new permissionDecision shape

- Pattern: `permissionDecision\s*=\s*'(deny|allow)'`
  - `.claude/hooks/*.ps1`: 68 total occurrences across all 13 PreToolUse hooks:
    validate-bash (1), enforce-python-batch-budget (8), check-python-test-purity (1),
    enforce-evidence-locations (6), enforce-feature-folder-order (7),
    enforce-powershell-batch-budget (8), check-powershell-test-purity (2),
    enforce-checkpoint-monotonic (12), enforce-completion-consistency (10),
    enforce-pr-author-skill (2), enforce-promotion-mcp-only (2),
    enforce-prd-feature-before-planner (7),
    enforce-orchestration-preimplementation-gate (2).

## (a) No deny-path `exit 1` remains in the 13 PreToolUse hooks

- Pattern: `exit 1` in `.claude/hooks/*.ps1`. All occurrences within the 13 PreToolUse hooks are
  in `catch { Write-Error $_; exit 1 }` error-path (malformed-input) blocks, which the plan
  retains. Verified hooks with a catch-path `exit 1`:
  enforce-orchestration-preimplementation-gate (line 221, catch),
  enforce-feature-folder-order (147, catch), enforce-completion-consistency (411, catch),
  enforce-checkpoint-monotonic (306, catch), enforce-pr-author-skill (369, catch),
  enforce-promotion-mcp-only (233, catch), enforce-prd-feature-before-planner (219, catch).
  The four always-exit-0 hooks (check-python-test-purity, check-powershell-test-purity,
  enforce-python-batch-budget, enforce-powershell-batch-budget) and validate-bash have NO
  deny-path `exit 1`. The `validate-bash.ps1:20` hit is a documentation comment.
- The bundled mirror grep returns the byte-identical set of catch-path `exit 1` occurrences;
  byte-identity confirmed by the bundle-parity pytest (P16-T5, 7 passed).

## (b) SubagentStop validators STILL use top-level decision:block + exit 1 (unchanged)

- The four SubagentStop validators do NOT use `permissionDecision`/`hookSpecificOutput`:
  - `validate-executor-output.ps1`: 0 matches
  - `validate-feature-review-coverage.ps1`: 0 matches
  - `validate-orchestrator-output.ps1`: 0 matches
  - `validate-task-researcher-output.ps1`: 0 matches
- Each retains the SubagentStop block form `Write-Error $result.Message; exit 1` (allow path
  `exit 0`).
- None of the four validators appears in `git status --porcelain`, confirming they are
  unchanged by this feature.

## Conclusion

All 13 PreToolUse hooks (runtime + mirror) emit the `hookSpecificOutput`/`permissionDecision`
shape with no legacy top-level `decision`/`reason` emission and no deny-path `exit 1`. The four
SubagentStop validators are unchanged and retain top-level decision:block via `exit 1`.
