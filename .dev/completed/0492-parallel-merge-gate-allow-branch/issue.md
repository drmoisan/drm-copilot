# parallel-merge-gate-allow-branch (Issue #492)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-merge-gate-allow-branch/ (Issue #492)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #492
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/492
- Last Updated: 2026-08-19
- Work Mode: minor-audit

## Summary

The merge-gate PreToolUse hook `.claude/hooks/enforce-epic-merge-gate.ps1` denies every per-item `gh pr merge --merge` performed by a parallel-orchestrator run, because the hook has no branch that authorizes a merge from the parallel-orchestrator checkpoint. This blocks a parallel run from merging each item's own PR to main after CI is green.

## Environment

- OS/version: Windows 11 (PowerShell 7+ hook runtime)
- Python version: not applicable (PowerShell change)
- Command/flags used: `gh pr merge <N> --merge` and bare `gh pr merge --merge`
- Data source or fixture: `artifacts/orchestration/parallel-orchestrator-state.json`

## Steps to Reproduce

1. Run a parallel orchestration (`parallel-orchestrator`) whose child orchestrator runs with `epic_mode` false/absent and no epic checkpoint present.
2. Bring one item's PR to CI-green (`merge_status == "ci_green"`).
3. Attempt the per-item merge with `gh pr merge <pr_number> --merge`.

## Expected Behavior

The merge is permitted when the parallel-orchestrator checkpoint at `artifacts/orchestration/parallel-orchestrator-state.json` authorizes it: `route_id == "parallel"`, the target item's `merge_status == "ci_green"`, and (when an explicit PR number is named) the number matches that item's recorded `pr_number`.

## Actual Behavior

The command is denied with `EPIC_MERGE_GATE_BLOCKED`. The hook has only two allow-branches: the child-feature path (`epic_mode == true` and `step9_status == "passed"`) and the epic-integration path (`epic_merge_pr.ci_gate.conclusion == "success"`). A parallel run satisfies neither.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", or an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number.`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`enforce-epic-merge-gate.ps1` predates the parallel orchestration surface and has no parallel allow-branch. Multiple PreToolUse hooks on the same `Bash` matcher are conjunctive for denial, so any dedicated new hook cannot un-deny a merge on its own; `enforce-epic-merge-gate.ps1` itself must stop denying legitimate parallel merges. The parallel checkpoint schema and enums are defined in `.claude/rules/parallel-orchestration.md`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: new parallel allow-branch (ci_green + matching PR number -> allow); parallel deny cases (wrong merge_status, non-matching PR number, missing/unreadable/invalid checkpoint -> deny); confirmation existing epic/child branches behave identically.
- [x] Integration scenario to retest: end-to-end hook invocation with a fabricated parallel checkpoint denies/allows per the read seam.
- [x] Manual verification notes: confirm no other hook on the Bash matcher denies a parallel merge.

## Acceptance Criteria

- [x] AC1: `.claude/hooks/enforce-epic-merge-gate.ps1` permits `gh pr merge --merge` when the parallel-orchestrator checkpoint at `artifacts/orchestration/parallel-orchestrator-state.json` exists, has `route_id == "parallel"`, and the command targets an item whose `merge_status == "ci_green"`.
- [x] AC2: When the command names an explicit PR number, the parallel allow-branch permits the merge only when that number matches the target item's recorded `pr_number` (mirroring the existing epic-path PR-number matching logic).
- [x] AC3: The parallel allow-branch fails closed: a missing, unreadable, or invalid parallel checkpoint denies with `EPIC_MERGE_GATE_BLOCKED`, and a target item whose `merge_status` is not `ci_green` denies.
- [x] AC4: The existing child-feature branch (`epic_mode == true` and `step9_status == "passed"`) and epic-integration branch (`epic_merge_pr.ci_gate.conclusion == "success"` with matching `pr_number`) behave identically to before; the parallel branch is additive.
- [x] AC5: For a legitimate parallel merge, no PreToolUse hook wired to the `Bash` matcher in `.claude/settings.json` returns `permissionDecision: deny`.
- [x] AC6: `enforce-epic-merge-gate.ps1` remains under 500 lines and retains the injectable read-seam function pattern; Pester tests mock the filesystem boundary without creating temporary files.
- [x] AC7: PowerShell toolchain passes (PoshQC format, PSScriptAnalyzer clean, Pester green), with line coverage >= 85% on changed lines and no coverage regression.
- [x] AC8: Any documentation update to `.claude/rules/parallel-orchestration.md` (enforcement or F7-seam references to the merge gate) is minimal and consistent with the landed behavior.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
