# Targets Mirror Identity, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-30
Task: P3-T3 (remediation-plan.2026-10-16T08-40.md)
Command: git hash-object <four copies>; git grep -c -F "[A-Za-z][A-Za-z0-9+.-]+:" -- <four copies> (run via sh SCRATCH/c2_p3t3_5.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: All four copies hash to f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38, which differs from the c2 baseline hash e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 (targets-hash-baseline-c2.2026-10-16T09-47.md). git grep -c prints a count of 1 for each of the four paths.

## git hash-object (EXIT_CODE: 0)

```text
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
```

Order: `.claude/hooks/...`, `.codex/hooks/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...` (file `enforce-orchestration-preimplementation-gate-targets.ps1`).

## git grep -c -F (EXIT_CODE: 0)

```text
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:1
.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:1
```

## Acceptance

- Four hashes identical to each other: met.
- Hash differs from the latest `targets-hash-baseline-c2.*.md` value `e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2`: met.
- `git grep -c` count of 1 for each of the four paths: met.
