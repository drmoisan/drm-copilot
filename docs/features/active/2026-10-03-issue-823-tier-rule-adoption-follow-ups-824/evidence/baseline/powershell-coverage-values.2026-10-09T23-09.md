# P0-T21 Baseline PowerShell Coverage Values

Timestamp: 2026-10-09T23-09
Supersedes: powershell-coverage-values.2026-10-09T23-06.md
OPS-2: source = CI run 38017407907 artifact poshqc-test-results
Command: poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/orchestration/ci-baseline-poshqc/powershell-coverage.xml').getroot(); rows=[(('/'+p.get('name','')+'/'+s.get('name','')).replace(chr(92),'/'),int(k.get('missed')),int(k.get('covered'))) for p in r.iter('package') for s in p.findall('sourcefile') for k in s.findall('counter') if k.get('type')=='LINE']; m=sum(x[1] for x in rows); c=sum(x[2] for x in rows); print('REPO_LINE', round(100*c/(m+c),2), 'SOURCEFILES', len(rows)); [print('FILE', t, next((round(100*x[2]/(x[1]+x[2]),2) for x in rows if x[0].endswith('/'+t) and x[1]+x[2]>0), 'MISSING')) for t in ('.claude/hooks/validate-feature-review-coverage.ps1','.claude/hooks/feature-review-coverage-thresholds.ps1')]"
EXIT_CODE: 0
Output Summary:
- STATUS: PASS (acceptance met under OPS-2)
- G5 output (verbatim):
  REPO_LINE 88.0 SOURCEFILES 178
  FILE .claude/hooks/validate-feature-review-coverage.ps1 49.52
  FILE .claude/hooks/feature-review-coverage-thresholds.ps1 MISSING
- BASE_PS_LINE: 88.0
- BASE_HOOK_COV: 49.52
- Helper MISSING is expected (the helper does not exist yet).
- Input provenance (OPS-2): Appendix G item G5 run with only the input path changed from artifacts/pester/powershell-coverage.xml to artifacts/orchestration/ci-baseline-poshqc/powershell-coverage.xml. The file is the poshqc-test-results artifact of main CI run 38017407907 (head 816b5513a7e64b574a514ee320ccaef28fc7a597), produced by the repository PoshQC module. Per the orchestrator, git diff --stat 816b5513a BASE_SHA lists only four feature-folder docs files, so every PowerShell input is identical to BASE_SHA (b50df12b6467789d67118c994a5fd56a2fc8db81). The executor's output matches the orchestrator's recorded run.
- Pre-existing baseline condition (recorded, no action): BASE_HOOK_COV 49.52 is below the 85 per-file floor that P9-T13 requires for FINAL_HOOK_COV.
- Non-authoritative context: the earlier MCP-runner run (artifact powershell-coverage-values.2026-10-09T23-06.md) printed REPO_LINE 96.41 SOURCEFILES 127 with the hook MISSING, because the MCP runner's coverage population omits the target hook. That figure is not used as a baseline.
