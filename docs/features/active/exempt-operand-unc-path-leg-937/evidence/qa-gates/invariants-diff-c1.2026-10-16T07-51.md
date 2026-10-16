# Invariants against the base branch, remediation cycle 1 (P3-T8)

Timestamp: 2026-10-16T07-51
Command: git fetch origin main; git merge-base origin/main HEAD; git diff --numstat ba53ff5694a42e975d5d1db99b2b6ef505143e66 -- <four targets copies> <three edited test files> tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: Merge base ba53ff5694a42e975d5d1db99b2b6ef505143e66 (origin/main fetched at a880c46b919ca58b1144a925d54488ce51f02bfb; the merge base is unchanged). Exactly seven numstat lines; each targets copy `9 0`; the three edited test files show 0 deleted (97, 36, 36 added); C1bCoverage and Parity test files do not appear (AC-10, AC-18).

## git diff --numstat (verbatim)

```
9	0	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
97	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
36	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
36	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## Acceptance check

- Exactly seven numstat lines: met.
- Each targets copy `9` added, `0` deleted: met.
- Each edited test file `0` deleted: met.
- Neither C1bCoverage nor Parity test file appears: met.
