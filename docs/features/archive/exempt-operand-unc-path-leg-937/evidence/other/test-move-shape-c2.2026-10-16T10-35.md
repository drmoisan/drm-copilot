# Test Move Shape, Remediation Cycle 2 (issue #937 RI-8)

Timestamp: 2026-10-16T10-35
Task: P1-T4 (remediation-plan.2026-10-16T08-40.md)
Command: git diff --numstat HEAD -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1; git status --porcelain -- tests/scripts/claude-hooks; wc -l < <source suite>; wc -l < <new suite>; sed -n '23,118p' <new suite> | cmp - SCRATCH/moved-before.txt; sed -n '10,20p' <source suite> > SCRATCH/head-old.txt; sed -n '10,20p' <new suite> > SCRATCH/head-new.txt; cmp SCRATCH/head-old.txt SCRATCH/head-new.txt (run via sh SCRATCH/c2_p1t4.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: numstat 0/97 for the source suite; porcelain lists the modified source suite and the untracked new suite only; line counts 399 (source) and 119 (new), each at most 500; moved-block cmp exit 0; header cmp exit 0.

## git diff --numstat HEAD -- <source suite> (exit 0)

```text
0	97	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
```

## git status --porcelain -- tests/scripts/claude-hooks (exit 0)

```text
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
?? tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
```

## Line counts

- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1: 399
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1: 119

## cmp results

- moved block (new suite lines 23 to 118 vs SCRATCH/moved-before.txt): exit 0
- header (lines 10 to 20 of each suite): exit 0
