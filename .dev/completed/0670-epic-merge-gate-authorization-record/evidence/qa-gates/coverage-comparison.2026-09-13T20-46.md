# Coverage Comparison — Issue #670

Timestamp: 2026-09-17T08-36
Task: [P7-T2]
Command: git add -A ; git diff --cached -U0 origin/epic/worktree-scoped-state-resolution-integration -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-authorization.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 ; changed-line intersection with artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0

Staging precondition: the delegation states that `artifacts/orchestration/orchestrator-state.json` already satisfies the pre-implementation gate. `git add -A` ran without a hook denial (exit 0).

Method: the staged, base-anchored `-U0` diff (727 lines) was parsed for every added (`+`) line's new-file line number. Each such line was looked up among the `line` elements (`nr`, `ci`) of the file's `sourcefile` node in `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:31:34; the [P7-T1] measurement). Added lines with no `line` element are non-executable and excluded from both numerator and denominator. Numerator: lines with `ci > 0`. Denominator: added lines that have a `line` element.

| File | Baseline % (`p1-post-registration-coverage`) | Post-change % (`post-change-coverage`) | Added/modified lines | Excluded non-executable | Executable changed lines (denominator) | Covered changed lines (numerator) | Changed-lines % |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 100.00 | 100.00 | 442 | 342 | 100 | 100 | 100.00 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.49 | 96.67 | 33 | 26 | 7 | 7 | 100.00 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 98.59 | 99.34 | 192 | 112 | 80 | 80 | 100.00 |

Remediation note: the first post-change measurement put the Codex hook at 93.38% (141/151), below its 98.59% baseline, with nine uncovered new branches (field checks and block shapes). The Codex suite was extended with the spec's row-5 and row-6 counterparts (see `pass-after-codex-authorization.2026-09-13T20-46.md`, addendum), and [P7-T1] was re-measured. The table above uses the re-measured values.

Output Summary:
- The changed-line set for `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` is non-empty (442 added lines, 100 executable).
- All three post-change line-coverage percentages are at least 85.0 (100.00, 96.67, 99.34).
- Each post-change percentage is at least its baseline (100.00 >= 100.00; 96.67 >= 96.49; 99.34 >= 98.59).
- Changed-lines coverage is 100.00% for each of the three files (at least 85.0).
- PowerShell is exempt from the branch-coverage threshold; no branch figure is recorded.
