# Remediation Inputs: codex-worktree-session-regression (#281)

**Timestamp:** 2026-07-03T10-04
**Feature Folder:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
**Policy Audit:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/policy-audit.2026-07-03T10-04.md`
**Code Review:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/code-review.2026-07-03T10-04.md`
**Feature Audit:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/feature-audit.2026-07-03T10-04.md`
**Review Status:** REMEDIATION_REQUIRED

## Remediation-Required Findings

1. **Committed trailing whitespace in feature spec**
   - **File:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`
   - **Location:** line 85
   - **Finding:** `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD` reports trailing whitespace.
   - **Expected behavior:** The full branch diff must pass whitespace validation.
   - **Verification command:** `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD`

2. **Final QA evidence did not validate the full branch range**
   - **File:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/git-diff-check.2026-07-03T09-14.md`
   - **Finding:** The recorded evidence used `git diff --check` without the merge-base range, so it did not catch committed whitespace in the full feature-vs-base diff.
   - **Expected behavior:** A new canonical QA evidence artifact must record the range-based whitespace command and `EXIT_CODE: 0` after the whitespace is fixed.
   - **Required evidence path:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/git-diff-check-remediation.<timestamp>.md`
   - **Verification command:** `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD`

3. **Post-remediation review gate**
   - **Files:** `policy-audit.2026-07-03T10-04.md`, `code-review.2026-07-03T10-04.md`, `feature-audit.2026-07-03T10-04.md`
   - **Finding:** Current review artifacts correctly report remediation-required status and must not be overwritten as PASS without a re-review after remediation.
   - **Expected behavior:** After remediation, run the feature-review workflow again and produce new timestamped review artifacts.

## Required Verification Commands

```powershell
git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD
python scripts/dev_tools/validate_evidence_locations.py --root .
mcp__drm-copilot__validate_orchestration_artifacts artifact_type=policy-audit artifact_path=docs/features/active/2026-07-03-codex-worktree-session-regression-281/policy-audit.<new-timestamp>.md
mcp__drm-copilot__validate_orchestration_artifacts artifact_type=code-review artifact_path=docs/features/active/2026-07-03-codex-worktree-session-regression-281/code-review.<new-timestamp>.md
mcp__drm-copilot__validate_orchestration_artifacts artifact_type=feature-audit artifact_path=docs/features/active/2026-07-03-codex-worktree-session-regression-281/feature-audit.<new-timestamp>.md
```

## Do Not Do

- Do not modify TypeScript or PowerShell implementation files for this remediation unless a new review finding identifies a separate code defect.
- Do not weaken repository policy, whitespace validation, evidence-location validation, or coverage thresholds.
- Do not replace the range-based whitespace command with working-tree-only `git diff --check`.
- Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Do not mark the review PASS until new timestamped review artifacts exist and validate.

## Context Package

Primary context files:
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md`
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/policy-audit.2026-07-03T10-04.md`
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/code-review.2026-07-03T10-04.md`
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/feature-audit.2026-07-03T10-04.md`

## Handoff Limitation

The canonical remediation workflow requires an `atomic_planner -> atomic_executor` preflight-validation handoff. No callable atomic-executor delegation tool was available in this Codex session. The remediation plan file was still created for handoff continuity and must be preflight-validated before execution.
