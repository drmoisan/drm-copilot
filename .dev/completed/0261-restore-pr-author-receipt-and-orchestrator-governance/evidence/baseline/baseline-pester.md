# Baseline — Pester (claude-hooks scope)

Timestamp: 2026-06-27T23-40

Command: mcp__drm-copilot__run_poshqc_test (scan folder: tests/scripts/claude-hooks), plus a targeted coverage run of tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 against .claude/hooks/enforce-pr-author-skill.ps1

EXIT_CODE: 0

Output Summary:
- Full claude-hooks suite (artifacts/pester/pester-junit.xml): tests=378, failures=0, errors=0.
- enforce-pr-author-skill.Tests.ps1: tests=46, failures=0, errors=0 (sentinel model still in place at baseline).
- Targeted coverage for .claude/hooks/enforce-pr-author-skill.ps1 (JaCoCo CoverageGutters counters):
  - LINE coverage: 75 covered / 80 total = 93.75% (>= 85% threshold).
  - Pester command coverage (branch proxy; CoverageGutters does not emit BRANCH counters): 86 covered / 93 analyzed = 92.47% (>= 75% threshold).
  - INSTRUCTION: 86 covered / 93 = 92.47%; METHOD 10/10; CLASS 1/1.

Note: The shared pester.runsettings.psd1 pins CodeCoverage.Path to a 5-hook list that excludes enforce-pr-author-skill.ps1. Baseline coverage for this hook was captured via a dedicated targeted Pester configuration (intermediate coverage XML written to the session scratchpad, not an evidence path).
