# Targets EOL and Parity, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-58
Task: P4-T7 (remediation-plan.2026-10-16T08-40.md)
Command: git ls-files --eol -- <four targets copies> tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1; git hash-object <four targets copies> (HEAD d9ce4757ea3f7fa83b6c5a4694e2826f33ec2bfc)
EXIT_CODE: 0
Output Summary: Every --eol line shows i/lf and w/lf (attr/text=auto eol=lf), including the new suite. The four targets copies hash to f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38 (identical). AC-11 local check; the Parity suite in P4-T11 is authoritative.

## git ls-files --eol

```text
i/lf    w/lf    attr/text=auto eol=lf 	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
```

## git hash-object

```text
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38
```

## Acceptance

- Every `--eol` line shows `i/lf`: met.
- Every targets-copy line shows `w/lf`: met.
- Four hashes identical: met.
