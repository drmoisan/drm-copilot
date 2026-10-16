# Targets line endings and identity, remediation cycle 1 (P3-T7)

Timestamp: 2026-10-16T07-51
Command: git ls-files --eol -- <the four targets copies>; git hash-object <the four targets copies>
EXIT_CODE: 0
Output Summary: Every copy shows `i/lf` and `w/lf`; all four hash to e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 (AC-11 local check; the Parity suite in the P3-T11 CI run is authoritative).

## git ls-files --eol (verbatim)

```
i/lf    w/lf    attr/text=auto eol=lf 	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## git hash-object (verbatim)

```
e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2
e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2
e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2
e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2
```

## Acceptance check

- Every `--eol` line shows `i/lf` and `w/lf`: met.
- Four hashes identical: met.
