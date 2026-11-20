# F1 Bundle Mirror Hash - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-46
Task: [P1-T3]
Command: `cp .claude/lib/docs/DocsPageFrontMatter.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageFrontMatter.psm1`; `sha256sum` of both files; `sh SCRATCH/issue-1021-runfile.sh tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`
EXIT_CODE: 0
Output Summary: SHA-256 equal for source and bundle copy; `Docs.Manifest.Tests.ps1` total=7 passed=7 failed=0, including `ships byte-identical bundled counterparts`.

| File | SHA-256 |
|---|---|
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | `19ecde9219f227187ac53c21c05dc1741d4163635aadc0d7f1645d5b0da81789` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageFrontMatter.psm1` | `19ecde9219f227187ac53c21c05dc1741d4163635aadc0d7f1645d5b0da81789` |
