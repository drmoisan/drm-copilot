# Test-File Baseline, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-48
Task: P0-T8 (remediation-plan.2026-10-16T08-40.md)
Command: git merge-base origin/main HEAD; git diff --numstat <merge-base-sha> -- <three test files>; git show <merge-base-sha>:tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 > SCRATCH/targets-tests-base.txt; sed '399,495d' <targets test file> | tr -d '\r' | cmp - SCRATCH/targets-tests-base.txt; wc -l < each file; grep -c "^    It 'U" <targets test file>; git status --porcelain -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 (run via sh SCRATCH/c2_p0t8.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: Merge base c415af626. Numstat 97/0, 36/0, 36/0. cmp exit 0 (removing lines 399 to 495 yields the merge-base version exactly). Line counts 496, 185, 190. It 'U count 34. The new PathNotLocal suite path is absent (empty porcelain).

MergeBase: `c415af626c292f38b910e3a27e70ab3e1903b31a`

`git diff --numstat c415af626c292f38b910e3a27e70ab3e1903b31a -- ...`:

```text
97	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
36	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
36	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

| Command | Result |
|---|---|
| `git show <merge-base>:<targets test file> > SCRATCH/targets-tests-base.txt` | exit 0 |
| `sed '399,495d' <targets test file> \| tr -d '\r' \| cmp - SCRATCH/targets-tests-base.txt` | exit 0 |
| `wc -l <` targets test file | 496 |
| `wc -l <` Claude `EpicScopeTargets.Tests.ps1` | 185 |
| `wc -l <` Codex `epic-scope-targets.Tests.ps1` | 190 |
| `grep -c "^    It 'U"` targets test file | 34 |
| `git status --porcelain -- <PathNotLocal suite path>` | (empty) |
