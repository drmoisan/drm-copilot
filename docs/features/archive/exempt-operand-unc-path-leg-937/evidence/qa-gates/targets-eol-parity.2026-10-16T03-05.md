# Targets line endings and identity (P3-T6)

Timestamp: 2026-10-16T03-05
Command: git ls-files --eol -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1; git hash-object <same four paths>
EXIT_CODE: 0
Output Summary: Every `--eol` line shows `i/lf` and `w/lf`; all four copies hash to ef89c7f2e603ec3667d0c09589628be8af187559. Acceptance met (AC-11 local check; the Parity suite in P3-T10 is authoritative).

## git ls-files --eol

```
i/lf    w/lf    attr/text=auto eol=lf 	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## git hash-object

```
ef89c7f2e603ec3667d0c09589628be8af187559
ef89c7f2e603ec3667d0c09589628be8af187559
ef89c7f2e603ec3667d0c09589628be8af187559
ef89c7f2e603ec3667d0c09589628be8af187559
```
