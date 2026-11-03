# Remediation Inputs (Issue #1011), feature review 2026-10-31T02-17

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

**Entry timestamp:** 2026-10-31T02-17
**Feature folder:** `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011`
**Base branch:** `main` (merge base `1a342cc8c974593fd0c733894a7b140527dbca82`)
**Head reviewed:** `106f1cf4d0f5f5874ea18d90da9a4a8094cfde39` on `bug/pr-author-session-not-rooted-1011`
**Work mode:** `full-bug`; AC source is `spec.md` `## Acceptance Criteria` only (18 of 18 evaluated as met)
**Blocking finding count:** 1 (autonomous: 1)
**Audit artifacts:**
- `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/policy-audit.2026-10-31T02-17.md`
- `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/code-review.2026-10-31T02-17.md`
- `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/feature-audit.2026-10-31T02-17.md`

## Findings

### F1 (CR-1) - SessionRoot labelling omits the enclosing-worktree ascent

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect and its fix lie entirely in one function of a file already in the branch diff, plus one new test row and the bundled mirror; no external system, policy decision, or CI run is needed.

File: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `ConvertFrom-PrAuthorHookTargetResult` (line 137), and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`.

Current behavior: SessionRoot is decided by an OrdinalIgnoreCase comparison of the normalized resolved root with the normalized `(Get-Location).Path`. When the hook's process directory is a subdirectory of the item worktree, a `gh pr create --head <branch> --body-file artifacts/pr_body_<N>.md` command is labelled `OtherWorktree`, `RelativeBodyAllowed` is false, and the relative body is denied with `PR_BODY_PATH_NONCANONICAL`.

Expected behavior: identical to the replaced path. `ConvertTo-WorktreeItemResolvedResult` (exported by `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`, lines 217-257) labels `SessionRoot` when the root equals the session path or the worktree that path sits inside (`Find-WorktreeResolutionRoot` ascent). The spec requires every gate decision for an item-rooted session to stay unchanged, and its design maps "a resolved root equal to the session worktree" to `SessionRoot`.

Fix:
1. In `ConvertFrom-PrAuthorHookTargetResult`, keep the existing null, signal, source, ambiguous, and empty-root handling. Replace the inline `$isSession` comparison and the `New-WorktreeResolutionTargetResult` call for the resolved case with `ConvertTo-WorktreeItemResolvedResult -WorktreeRoot $Result.WorktreeRoot -SessionRoot $SessionRoot -Branch $branch -Detail $detail`. Confirm the returned object still carries `Signal = 'Branch'` and the branch as `SignalValue` (TR-02 and TR-03 assert `Signal`).
2. Update the function's comment-based help to state that labelling is delegated to `ConvertTo-WorktreeItemResolvedResult`.
3. Add a row to `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` in the `shared resolver consumption (issue #1011)` context: a CommandOperand result whose root is the item root, a `SessionRoot` argument that is a subdirectory of that root, and `Find-WorktreeResolutionRoot` mocked in module `WorktreeItemResolution` to return the item root; assert `Status` is `SessionRoot`. Keep synthetic roots in forward-slash or `$PSScriptRoot`-composed form; no temporary files and no git process.
4. Copy the helpers file byte-identically to the bundled path.

Verification:
- Invoke-Formatter (no changes) and Invoke-ScriptAnalyzer (0 findings) with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` on the helpers file and the TargetResolution suite.
- The TargetResolution suite (new row fails before the fix and passes after; record fail-before under `<FEATURE>/evidence/regression-testing/`).
- The gate suites named in spec criterion 8, the five touched suites under at least three seeded shuffles, and the full `tests/scripts` Pester run with coverage; helpers line coverage stays at or above 97.73% and at least 85%, with no missed changed line.
- `cmp` parity for the helpers file against its bundled copy; `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider` for the push-down contract suites.
- Logical line count of the helpers file stays at or below 500 (currently 497; the fix is expected to remove lines).

## Related non-blocking findings (planner discretion, same files)

These are not counted above. Under the operator preference that related findings in the same files are fixed inside the item before merge, the planner may include them in this cycle.

- CR-2 (Minor): when the shared resolver selects a worktree from the branch, the canonical-issue agreement check of `Resolve-WorktreeItemTargetByBranch` is skipped. Option: when `Find-WorktreeItemIssueSignal` returns an issue number for the command text, bypass the shared-resolver shortcut so the identity resolver decides. Add one TR row with both signals.
- CR-3 (Minor): the shared resolver does not drop registrations whose directory is gone, so a deleted worktree yields a later `PR_CONTEXT_MISSING` instead of `TARGET_WORKTREE_NOT_DERIVABLE`. Option: treat a root that fails `Test-WorktreeResolutionRootMarker` as no selection inside `ConvertFrom-PrAuthorHookTargetResult`. Do not edit `.claude/lib/worktree-resolution/` (owned by #1009 and protected by spec criterion 18).

## Do not do

- Do not modify `.claude/lib/worktree-resolution/`, `.codex/`, `.github/agents/`, any pack manifest, or any policy file under `.claude/rules/` or `.github/instructions/`.
- Do not change `Resolve-PrAuthorArtifactRoot`, `Resolve-PrAuthorCurrentBranchTarget`, `Get-PrAuthorBypassReason`, `Invoke-OrchestratorStatePreflight`, `Get-PrAuthorDocsOnlyExemption`, `Get-PrAuthorBodyPathBindingReason`, or `Test-PrAuthorReceiptVerification` (spec criterion 9).
- Do not change the expectation of any existing gate-suite row (spec criterion 8) or modify `pr-author-issue-link-contract.Tests.ps1` (criterion 12).
- Do not weaken any receipt check, deny code, or allowlist form; do not add coverage exclusions; do not skip or remove tests.
- Write evidence only under `<FEATURE>/evidence/<kind>/`.
