# P0-T21 Baseline PowerShell Coverage Values

SupersededBy: powershell-coverage-values.2026-10-09T23-09.md (OPS-2: source = CI run 38017407907 artifact poshqc-test-results). The values below are non-authoritative context.

Timestamp: 2026-10-09T23-06
Command: poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/powershell-coverage.xml').getroot(); rows=[(('/'+p.get('name','')+'/'+s.get('name','')).replace(chr(92),'/'),int(k.get('missed')),int(k.get('covered'))) for p in r.iter('package') for s in p.findall('sourcefile') for k in s.findall('counter') if k.get('type')=='LINE']; m=sum(x[1] for x in rows); c=sum(x[2] for x in rows); print('REPO_LINE', round(100*c/(m+c),2), 'SOURCEFILES', len(rows)); [print('FILE', t, next((round(100*x[2]/(x[1]+x[2]),2) for x in rows if x[0].endswith('/'+t) and x[1]+x[2]>0), 'MISSING')) for t in ('.claude/hooks/validate-feature-review-coverage.ps1','.claude/hooks/feature-review-coverage-thresholds.ps1')]"
EXIT_CODE: 0
Output Summary:
- STATUS: STOP CONDITION TRIGGERED (task acceptance not met; P0-T21 left unchecked)
- G5 output (verbatim):
  REPO_LINE 96.41 SOURCEFILES 127
  FILE .claude/hooks/validate-feature-review-coverage.ps1 MISSING
  FILE .claude/hooks/feature-review-coverage-thresholds.ps1 MISSING
- BASE_PS_LINE: 96.41 (numeric; scope is the MCP runner's coverage population, 127 source files)
- BASE_HOOK_COV: MISSING (non-numeric). The plan states "A non-numeric BASE_PS_LINE or BASE_HOOK_COV stops the plan."
- The helper MISSING value is expected (the helper does not exist yet).
- The OPS-1 item 6 deferral clause does not apply literally: both XML reports were present and fresh after the P0-T20 MCP call (powershell-coverage.xml mtime 2026-10-09 23:04:16, previously 22:57:27).
- Diagnosis (read-only inspection):
  - The coverage XML contains 18 packages and 127 source files; package `/.claude/hooks` is present with 43 source files, while `.claude/hooks/*.ps1` holds 49 files. validate-feature-review-coverage.ps1 is not among the 43, and the string does not appear in powershell-coverage.koverage.xml (grep count 0).
  - config/poshqc-coverage.json lists `.claude/hooks` as a root with no excludes, and tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 dot-sources the hook in BeforeAll, so the repository's own PoshQC configuration would be expected to measure it.
  - The MCP runner is known to use the installed extension's bundled PoshQC resources and settings rather than the repository copy, which is the likely cause of the narrower coverage population. This is likely but not confirmed.
- Next action options for the orchestrator: (a) authorize an OPS-1 deferral of BASE_HOOK_COV to the CI coverage job; (b) authorize running the repository PoshQC module directly (the plan's original G4 route, currently prohibited by the operator); or (c) another decision. The executor has not continued past P0-T21.
