# Remediation Plan: codex-worktree-session-regression (#281)

- **Issue:** #281
- **Feature Folder:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
- **Source of Truth:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/remediation-inputs.2026-07-03T10-04.md`
- **Original Plan:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md`
- **Status:** Preflight Pending
- **Preflight:** BLOCKED - no callable atomic-executor preflight handoff is available in this Codex session.

## Remediation Scope

Resolve the feature-review policy failure caused by committed trailing whitespace in `spec.md` and replace the insufficient working-tree-only whitespace evidence with range-based evidence for the full feature-vs-base diff.

## Constraints

- Keep remediation limited to `spec.md`, canonical QA evidence, and new timestamped review artifacts unless a new review finding identifies an additional issue.
- Do not modify TypeScript or PowerShell implementation or test files for this remediation.
- Store new evidence only under `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/`.
- Use the range command `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD` for whitespace validation.

### Phase 0 — Baseline And Policy Confirmation

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, `docs/features/active/2026-07-03-codex-worktree-session-regression-281/remediation-inputs.2026-07-03T10-04.md`, and `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T2] Capture the remediation baseline by running `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD`; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/remediation-baseline/git-diff-check-before.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the current `spec.md:85` trailing whitespace diagnostic.
- [x] [P0-T3] Review `docs/features/active/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md` and confirm all original completed tasks remain checked; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/remediation-baseline/original-plan-status.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Whitespace Remediation

- [x] [P1-T1] Edit only `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md` to remove the trailing whitespace on line 85 without changing the surrounding wording or acceptance criteria.
- [x] [P1-T2] Run `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD`; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/git-diff-check-remediation.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming the full branch range whitespace check passed.
- [x] [P1-T3] Run `python scripts/dev_tools/validate_evidence_locations.py --root .`; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/evidence-location-validation-remediation.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

### Phase 2 — Review Re-Run

- [x] [P2-T1] Rerun the feature-review workflow against `main` and merge base `476b110cc53c7f26a573c9cf23b4f3dba1b095a9`; create new timestamped `policy-audit.<timestamp>.md`, `code-review.<timestamp>.md`, and `feature-audit.<timestamp>.md` in `docs/features/active/2026-07-03-codex-worktree-session-regression-281/`.
- [x] [P2-T2] Validate the new policy audit with `mcp__drm-copilot__validate_orchestration_artifacts` using `artifact_type: "policy-audit"` and the new policy audit path; do not report remediation complete if validation fails.
- [x] [P2-T3] Validate the new code review with `mcp__drm-copilot__validate_orchestration_artifacts` using `artifact_type: "code-review"` and the new code review path; do not report remediation complete if validation fails.
- [x] [P2-T4] Validate the new feature audit with `mcp__drm-copilot__validate_orchestration_artifacts` using `artifact_type: "feature-audit"` and the new feature audit path; do not report remediation complete if validation fails.

### Phase 3 — Final Status Synchronization

- [x] [P3-T1] Recheck `docs/features/active/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md` and confirm no completed original task was unchecked by remediation; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/original-plan-status-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T2] Run `git status --short --branch --untracked-files=all`; write `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/other/remediation-final-worktree-status.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing all remaining changed files.
- [x] [P3-T3] Report remediation completion only if the range-based whitespace check, evidence-location validation, and all new review-artifact validators pass.

## Acceptance Criteria

- The full branch range command `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD` exits 0.
- New canonical evidence records the range-based command and `EXIT_CODE: 0`.
- Evidence-location validation exits 0 after new evidence is written.
- New timestamped review artifacts exist and pass their repository validators.
- No TypeScript or PowerShell implementation/test files are modified by this remediation unless a new review finding explicitly requires it.

## Preflight Requirement

Before execution, this remediation plan must be handed to `atomic_executor` with the exact directive:

```text
DIRECTIVE: PREFLIGHT VALIDATION ONLY
```

Execution must not start until preflight returns:

```text
PREFLIGHT: ALL CLEAR
```
