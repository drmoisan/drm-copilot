# Spec AC-2 Check-off (Remediation Cycle 1)

Timestamp: 2026-10-01T16-50
Task: [P4-T16]
Location: worktree root

Edit: in `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md`, the AC-2 line prefix changed from `[ ] AC-2:` to `[x] AC-2:`. No other text was edited.

Backing artifacts for AC-2:

- P1-T7: `evidence/regression-testing/split-line-counts.2026-10-01T16-36.md` (split files 187, 462, 177 lines).
- P4-T13: `evidence/qa-gates/rem1-file-size-gate.2026-10-01T16-48.md` (every Python, PowerShell, TypeScript, and JavaScript-config file created or modified by #509 relative to the integration branch is below 500 lines; largest 477).

AC-18 was checked off by the 2026-09-30T15-25 feature review (`feature-audit.2026-09-30T15-25.md`).

## Command 1

Command: `grep -c -E -e "^- \[[ x]\] AC-[0-9]+:" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md`
EXIT_CODE: 0
Output Summary: `22`

## Command 2

Command: `grep -c -E -e "^- \[x\] AC-[0-9]+:" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md`
EXIT_CODE: 0
Output Summary: `22`. Both print 22, so no acceptance criterion remains unchecked.
