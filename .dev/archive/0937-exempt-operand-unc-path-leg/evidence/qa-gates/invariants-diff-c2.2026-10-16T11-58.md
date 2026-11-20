# Invariants Against the Base Branch, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-58
Task: P4-T8 (remediation-plan.2026-10-16T08-40.md)
Command: git fetch origin main; git merge-base origin/main HEAD; git diff --numstat <merge-base-sha> -- <four targets copies> <source suite> <new suite> <two gate suites> <C1bCoverage suite> <Parity suite> (HEAD d9ce4757ea3f7fa83b6c5a4694e2826f33ec2bfc)
EXIT_CODE: 0
Output Summary: Merge base c415af626c292f38b910e3a27e70ab3e1903b31a. Exactly seven numstat lines: each targets copy 9/0, the new suite 134/0, each gate suite 54/0. The source suite, the C1bCoverage suite, and the Parity suite do not appear (unchanged against the merge base; AC-10).

## git merge-base origin/main HEAD

```text
c415af626c292f38b910e3a27e70ab3e1903b31a
```

## git diff --numstat c415af626c292f38b910e3a27e70ab3e1903b31a

```text
9	0	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
134	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
54	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
54	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## Acceptance

- Exactly seven numstat lines: met.
- Each targets copy `9	0`: met.
- New suite `134	0`: met.
- Each gate suite `54	0`: met.
- Source suite, C1bCoverage suite, and Parity suite absent: met.
