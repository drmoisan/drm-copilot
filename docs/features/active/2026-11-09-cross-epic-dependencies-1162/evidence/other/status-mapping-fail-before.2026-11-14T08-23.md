# Status-Mapping Fail-Before (F2) — Remediation Cycle 1, P1-T3 (Issue 1162)

Timestamp: 2026-11-14T08-23
Command: sh SCRATCH/issue-1162-tc2.sh "tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1" "tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1" (task check: Invoke-Formatter and Invoke-ScriptAnalyzer on the changed file, then Pester 6.2.0 with Run.Path set to the file)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed file: tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1, which adds to `BeforeDiscovery` the `$mappingToken` list (the fragment `Status mapping (D7).` and the five mapping sentences, verbatim with backticks) and `$script:MappingRow` (4 rows), plus `It 'CES-STATUS-MAPPING <Path>' -ForEach $script:MappingRow`, which reuses `Get-CrossEpicSection`, `Get-CrossEpicCollapsedText`, and `Get-CrossEpicMissingToken`.
- Selection rule: the changed contract test file. No description surface is edited yet.
- Format: 0 differences. Analyzer: 0 findings.
- Pester: passed=19, failed=4, total=23. The only failures are the four new cases: `CES-STATUS-MAPPING .claude/skills/epic-orchestrate/SKILL.md`, `CES-STATUS-MAPPING .agents/skills/epic-orchestrate/SKILL.md`, `CES-STATUS-MAPPING .claude/agents/epic-orchestrator.md`, and `CES-STATUS-MAPPING .codex/agents/epic-orchestrator.toml`. Every existing case passes.
