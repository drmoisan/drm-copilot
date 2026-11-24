# Task Check P3-T3 (issue #1231)

Timestamp: 2026-11-24T00-40
Changed files:
- tests/scripts/claude-hooks/release-pull-request.Parity.Tests.ps1 (new, 142 lines)
Selection rule: the new suite itself (it reads the hook files, their bundle copies, core.json, and the generated documentation).

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/release-pull-request.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 35, Failed: 0. Rows: byte identity of the eight hook files with their claude-customizations copies (8); the core.json listing of the four new files (1); the ReleasePullRequest prefix of every script-scope name and both functions of the pure file (1); no ConvertFrom-Json, WildcardPattern, python, or poetry text in the four new files (16, AC-12 and AC-13); the receipt suffix immediately before the release suffix in both Claude gate copies, with the call between the parallel records and #1201 calls (2, AC-09); and the leg tokens in the generated rule (with `policy-level control` and `destination-owned`), brief, skill, and agent and their sources (7, AC-17 and AC-18). The suite builds every path from forward-slash relative segments with Join-Path and uses exact file-name case, so it runs on a case-sensitive file system.
