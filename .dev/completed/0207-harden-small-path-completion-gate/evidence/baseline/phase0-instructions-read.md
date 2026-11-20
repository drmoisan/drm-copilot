# Phase 0 — Instructions Read Evidence (Issue #207)

Timestamp: 2026-06-19T18-48

Policy Order:
1. CLAUDE.md (standing instructions, tone policy, policy-compliance reading order, architecture)
2. .claude/rules/general-code-change.md (cross-language code change policy, 500-line limit, toolchain loop)
3. .claude/rules/general-unit-test.md (cross-language unit test policy, coverage thresholds)
4. .claude/rules/powershell.md (PowerShell toolchain, coding standards, mocking rules, design seams)

Files Read (explicit list):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md

Notes:
- In-scope language: PowerShell only.
- Toolchain order: PoshQC format -> PSScriptAnalyzer analyze -> Pester test (no type-check for PowerShell).
- Coverage policy: line >= 85%, branch >= 75%.
- File size limit: 500 lines for production and test files.
- Mocking rule: mock the JSON-parse seam function (ConvertFrom-CheckpointJson); no temp files.
