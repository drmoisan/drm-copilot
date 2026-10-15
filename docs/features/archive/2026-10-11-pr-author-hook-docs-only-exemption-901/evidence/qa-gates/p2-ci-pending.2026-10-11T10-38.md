# P2-T7 AC-9 CI-dependent criteria (pending CI)

Timestamp: 2026-10-12T18-23
Command: grep -c '^COVERAGE_TARGET: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md
EXIT_CODE: 0
Output Summary:
- No local coverage number is recorded; per-file line coverage for the four edited production files is read from the CI poshqc-test-results artifact after the pull request runs.
- Format and analyze outcomes are confirmed by the CI Format PowerShell and Analyze PowerShell steps; the Linux hook-suite job confirms the new suites on Linux.
- AC-9 remains unchecked until the CI artifact is read under the rule below.

COVERAGE_STATUS: PENDING_CI
CI_WORKFLOW: .github/workflows/ci.yml job poshqc -> .github/workflows/_poshqc.yml job "PowerShell QC" (windows-latest)
CI_FORMAT_STEP: Format PowerShell (fails when Invoke-PoshQCFormat leaves git status non-empty)
CI_ANALYZE_STEP: Analyze PowerShell (Invoke-PoshQCAnalyze throws on any finding)
CI_TEST_STEP: Test PowerShell
CI_LINUX_JOB: "PowerShell hook suites (Linux)" artifact poshqc-linux-hook-test-results
CI_COVERAGE_ARTIFACT: poshqc-test-results / artifacts/pester/powershell-coverage.xml
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill-helpers.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 threshold=85.00
COVERAGE_READ_RULE: per file, the LINE counter of the class whose package name joined with its sourcefilename equals the repository-relative path; covered / (covered + missed) * 100 >= 85.00
BASELINE_CI_RUN_ID: 38315946747
