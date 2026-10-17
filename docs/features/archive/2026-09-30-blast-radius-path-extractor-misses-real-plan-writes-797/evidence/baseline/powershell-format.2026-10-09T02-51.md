# Baseline PowerShell Formatting (P0-T15)

Timestamp: 2026-10-09T02-51
Command: sha256sum <four P0-T15 files>; mcp__drm-copilot__run_poshqc_format scan_folders [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]; sha256sum <four P0-T15 files>; git status --porcelain (before and after)
EXIT_CODE: 0
Output Summary: substitute evidence. The PoshQC formatter returned ok:true and rewrote none of the four files (SHA256 identical before and after; porcelain unchanged), which is the tree-observation equivalent of four `True` lines. No pre-existing drift.

## Deviation (PowerShell route denied)

The plan's command (`Invoke-Formatter -ScriptDefinition ... ; $s -ceq $f`) needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). Per operator constraint 3, the PoshQC MCP formatter is used as substitute evidence, bracketed by SHA256 listings so that a rewrite would be visible.

## Output

```text
before and after (identical):
d97342cbe5d031a67febfb2f0f2aa23fa5c3464bf2cc136a320d061a2d9fbf70 .claude/lib/blast-radius/BlastRadiusExtraction.psm1
e258be2d7702f11594583c682a601b80951be4daefcfd0c2ca3cf525e855883a .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
9ec0f799460e58f512e0c8cf168ff780ecc3a5c4c452781476586f2549c16744 tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
39cb8e789119bf04a1ef7a3ead5709e2b6c8c7bb0ca6c1f35a4a1d1886a2d1d8 tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
porcelain before and after: ?? docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/
MCP result: ok:true
```

Derived per-file result (substitute for the plan's four lines):

```text
.claude/lib/blast-radius/BlastRadiusExtraction.psm1 True
.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 True
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 True
tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 True
```
