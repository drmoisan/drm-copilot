# Remediation Inputs — Issue 1163

Timestamp: 2026-11-13T14-23
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/2026-11-09-hook-session-root-resolution-1163/policy-audit.2026-11-13T14-23.md`
- `docs/features/active/2026-11-09-hook-session-root-resolution-1163/code-review.2026-11-13T14-23.md`
- `docs/features/active/2026-11-09-hook-session-root-resolution-1163/feature-audit.2026-11-13T14-23.md`
Head reviewed: `d28a5645ba0c4194484f0f947847628424e14f71` (merge base `1d62aa292161035aec8058e6c370f133e10a04db`)
Prior cycle: none (first review).

## Findings requiring remediation

### F1 — The stale-registration detail names only the first character of a single branch

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a one-line change in a function on this branch, copied to its Codex twin and two bundle mirrors, plus a tighter pattern in two existing data rows; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, `.codex/hooks/agent-target-worktree.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/agent-target-worktree.ps1`, `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`.
- Location: `Resolve-AgentTargetWorktree`, the block after the comment "A branch registered only at a prunable root names that root and the repair remedy".
- Problem: `$branches = if (...) { @($CommandBranch.Trim()) } else { @(...) }` unrolls a one-element array into a string, so `$branches[0]` is the first character. With `-CommandBranch 'bug/x-1'`, or a prompt with one `branch: bug/x-1` label, over a prunable-only registration, the detail reads `branch 'b' is registered only at the stale root '<root>'; run git worktree repair ...`. With two labels the name is correct. The stale root, `StaleRegistration`, and the reason code are correct. The AC-7 rows match only the root and `git worktree repair`, so no row detects it.
- Required change: assign `$branches = @(if (...) { ... } else { ... })`, and name the branch of the dropped record that matched (for example take the `Branch` of the first matching dropped record together with its `Root`) instead of `$branches[0]`. Copy the function text byte-identically to the Codex twin and both bundle mirrors. In `AgentTargetWorktree.Rows.Helpers.ps1`, extend the `DetailPattern` of the rows 'prunable a command branch registered only at a prunable root is not derivable and names the repair' and 'prunable a prompt branch registered only at a prunable root fails closed and names the repair' to require `branch 'bug/item'` before the stale root.
- Verification required: the two tightened rows fail against the current function text and pass after the fix (record both results append-only under `evidence/other/`); then the final QA loop: PoshQC format and analyzer clean, one `Invoke-PoshQCParallelTest` run with 0 failures, `AgentTargetWorktree.psm1` and `agent-target-worktree.ps1` at or above 85% line coverage with no drop against the 2026-11-13T14-09 run, leak scan clean, push-down contract tests and the Codex generator check pass, and source and mirror byte identity confirmed.

## Light Fix Tasks

- [ ] [P0-T1] `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, `.codex/hooks/agent-target-worktree.ps1`, both bundle mirrors, and `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1` (F1): tighten the two AC-7 `DetailPattern` values to require the full branch name and record that they fail before the fix; keep `$branches` an array and name the matching dropped record's branch in the detail; copy the function text to the Codex twin and both mirrors; run the final QA loop and record each result append-only under `evidence/`.

## Non-remediation items (record only)

- CR1 (Info): `validate-feature-review-coverage.ps1` and `validate-orchestrator-output-target.ps1` inherit the working-directory source and prunable exclusion through the shared SubagentStop helper; an optional pinning row for the feature-review coverage hook is suggested.
- CR2 (Info): the default `WorktreeListInvoker` calls `git` directly, matching the composed `HookTargetWorktree.psm1` seam.
- CR3 (Info): the D9 default resolver starts one worktree listing per stale record.
- Warning: `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` is 750 logical lines (advisory tier).
- AC-34 (CI on the PR head) is pending-CI and owned by the orchestrator at S9; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run per gate. No serial, single-process, shuffled, or reversed runs.
- Evidence is append-only; do not edit or delete existing evidence files. No artifact records an absolute path or host name.
- No Python file is added or modified.
- `HookTargetWorktree.psm1`, `hook-target-worktree.ps1`, and every other invariant path of the spec stay unchanged.
- Any commit makes this review stale, so a re-review follows.
