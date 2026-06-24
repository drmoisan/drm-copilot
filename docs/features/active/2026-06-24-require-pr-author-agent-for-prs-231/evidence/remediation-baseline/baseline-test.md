# Baseline PoshQC Test + Coverage — pre-fix (F-1 remediation)

Timestamp: 2026-06-24T15-59

Command: `mcp__drm-copilot__run_poshqc_test` over scan folder `tests/scripts/claude-hooks`

Supplementary scoped coverage command (because the bundled runsettings `CodeCoverage.Path` does not instrument `enforce-pr-author-skill.ps1`; see agent-memory `powershell-coverage-scope`):
```
New-PesterConfiguration with:
  Run.Path = tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
  CodeCoverage.Enabled = $true
  CodeCoverage.OutputFormat = JaCoCo
  CodeCoverage.Path = .claude/hooks/enforce-pr-author-skill.ps1
```

EXIT_CODE: 0

Output Summary:
- Full claude-hooks suite (bundled PoshQC run): tests=288, failures=0, errors=0 (source: `artifacts/pester/pester-junit.xml`).
- Scoped coverage for `enforce-pr-author-skill.ps1` (its own test file, 41 `It` cases): TESTS_TOTAL=41, PASSED=41, FAILED=0.
- Baseline line coverage for `enforce-pr-author-skill.ps1`: 92.05% (81 of 88 commands covered, 7 missed). This is the pre-fix numeric headline.
- Branch coverage: not produced by Pester's PowerShell coverage engine (line/command counters only); see agent-memory note. Line coverage is the reported metric.
