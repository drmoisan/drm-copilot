# AC Check-Off — Contract surface (10 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:46:31-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Contract surface' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 10 of 10 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | Module directory exposes Resolve-WorktreeCallTarget, ConvertTo-WorktreeResolutionRepoRelativePath, Get-WorktreeResolutionAmbiguityReasonCode; no consumer rewired | Export-ModuleMember lists in both modules (9 + 6 exports); suites call all three (worktree-resolution-suite, worktree-target-resolution-suite); evidence/qa-gates/scope-boundary.2026-09-13T22-00.md (both listings empty) |
| 2 | Resolve-WorktreeCallTarget always returns a [pscustomobject] with the eight fields | worktree-target-resolution-suite: "returns an object carrying exactly the eight contract fields from Resolve-WorktreeCallTarget" |
| 3 | Status takes exactly the four literals; a test shows each is produced by a documented input | worktree-target-resolution-suite: "produces each of the four Status values from a documented input"; factory `ValidateSet` rejection in "refuses an empty Detail or SessionRoot and an unknown Status" |
| 4 | For every Status: SessionRoot populated, Candidates an array, Detail non-empty | worktree-target-resolution-suite: "enforces the field invariants for Status SessionRoot / OtherWorktree / NoTarget / Ambiguous" |
| 5 | WorktreeRoot populated only for SessionRoot and OtherWorktree | same four field-invariant rows; the 12 "required matrix row" tests; the NoTarget test |
| 6 | Regression guard when target worktree equals the process worktree | worktree-target-resolution-suite: the four "required matrix row: cwd ..., own target resolves to SessionRoot" rows assert WorktreeRoot = SessionRoot, ReasonCode null, Candidates exactly that root |
| 7 | NoTarget returns null Signal, SignalValue, WorktreeRoot, ReasonCode and an empty Candidates array | worktree-target-resolution-suite: "returns NoTarget with empty signal fields for a payload naming nothing, without reading the filesystem" |
| 8 | Ambiguous returns the reason code, Signal naming the present kind, SignalValue carrying the raw token | worktree-target-resolution-suite: the six "ambiguous sub-case" tests assert Status, ReasonCode, Signal (per row), and a non-empty SignalValue. The verbatim property rests on "preserves the absolute prefix ..." and the "returns the bare token ..." extractor tests together with the direct pass-through of the extracted value into `SignalValue` in Resolve-WorktreeCallTarget; no test compares SignalValue to the token string directly |
| 9 | NoTarget versus Ambiguous determinable from the object alone, with a test | worktree-target-resolution-suite: "distinguishes NoTarget from Ambiguous by Status and ReasonCode alone" |
| 10 | Every documented Ambiguous sub-case has a test | worktree-target-resolution-suite: six "ambiguous sub-case" tests (two worktrees, zero worktrees, no .git on the upward walk, branch matching none, branch matching several, two signals disagreeing) |

Supporting evidence: evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md (33 passed),
evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md (48 passed),
evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md (51 passed),
evidence/qa-gates/scope-boundary.2026-09-13T22-00.md.
