# r1 P0-T1 — full-bug preconditions and AC state

Timestamp: 2026-10-03T12-38
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t1.ps1 -Worktree WORKTREE
EXIT_CODE: 0
Output Summary:
- COUNTS=1,2,27,14,1
- issue.md carries `Work Mode: full-bug` once; spec.md has both `## Acceptance Criteria` and `## Scope Extension`; 27 checked AC (AC-1 to AC-13, AC-15 to AC-26, AC-28, AC-29); 14 unchecked AC (AC-14, AC-27, AC-30 to AC-41); remediation-inputs carries `Review-Verdict: REMEDIATION_REQUIRED` once.
- VERDICT(`($c -join ',') -eq '1,2,27,14,1'`) held; step script exited 0.

Step script body (after the A0 preamble):

```powershell
$c = @((Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/issue.md -SimpleMatch -Pattern 'Work Mode: full-bug').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^## (Acceptance Criteria|Scope Extension)$').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[x\] AC-\d+:').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[ \] AC-\d+:').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-inputs.2026-10-03T10-30.md -SimpleMatch -Pattern 'Review-Verdict: REMEDIATION_REQUIRED').Count); "COUNTS=$($c -join ',')"
exit ([int](-not (($c -join ',') -eq '1,2,27,14,1')))
```
