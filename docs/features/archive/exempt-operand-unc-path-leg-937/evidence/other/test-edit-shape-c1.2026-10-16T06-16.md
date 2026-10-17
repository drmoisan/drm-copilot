# Test Edit Shape, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T06-16
Task: P1-T12 (remediation-plan.2026-10-16T03-39.md)
Command: git diff --numstat HEAD -- <three test files>; git diff -U0 HEAD -- <three test files> | awk 'substr($0,1,1)=="-" && substr($0,1,3)!="---"' | cut -c2- > SCRATCH/removed-lines.txt; cmp SCRATCH/long-lines-before.txt SCRATCH/removed-lines.txt; git merge-base origin/main HEAD; git diff -U0 ba53ff5694a42e975d5d1db99b2b6ef505143e66 -- <three test files> | awk 'substr($0,1,1)=="+" && substr($0,1,3)!="+++" && length($0) > 121' | wc -l; wc -l < <file> (each)
EXIT_CODE: 0
Output Summary: numstat 20/5 (targets tests), 36/3 (Claude suite), 36/3 (Codex suite); cmp exit 0 (the only removed lines are the 11 long lines of P0-T9); merge-base long added-line count 0 (RI-6); line counts 496, 185, 190 (each at most 500). HEAD at measurement: 8cc65ac3d.

The three test files are:

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`

## git diff --numstat HEAD

```text
20	5	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
36	3	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
36	3	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## cmp SCRATCH/long-lines-before.txt SCRATCH/removed-lines.txt

EXIT_CODE: 0 (no output; files identical). The only removed lines are the 11 long lines recorded by P0-T9, so U01 to U05, U14, U16, every other existing row, and every row name and value are unchanged.

## git merge-base origin/main HEAD

```text
ba53ff5694a42e975d5d1db99b2b6ef505143e66
```

## Long added lines against the merge base (length > 121 including the `+`)

```text
0
```

## Line counts

| File | Lines |
|---|---|
| targets tests | 496 |
| Claude EpicScopeTargets suite | 185 |
| Codex epic-scope-targets suite | 190 |

## Acceptance

| Condition | Result |
|---|---|
| numstat `20 5`, `36 3`, `36 3` | met |
| `cmp` exits 0 | met |
| merge-base long-line count 0 | met |
| line counts 496, 185, 190, each at most 500 | met |
