# R2 Modified PowerShell Owners Batch B Expected-Red Evidence

Timestamp: 2026-08-13T17-45-04:00
Command: PowerShell script block below, executed by the repository's default PowerShell shell.

```powershell
$coveragePath = 'artifacts/pester/powershell-coverage.xml'
$authoritativeReceipt = 'docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-tests-coverage.txt'
[xml]$coverage = Get-Content -Raw -LiteralPath $coveragePath
$receipt = Get-Content -Raw -LiteralPath $authoritativeReceipt
$owners = @(
  '.codex/hooks/validate-codex-subagent-routing.ps1',
  '.codex/scripts/launch-epic-child-wave.ps1',
  '.codex/scripts/resume-epic-child.ps1'
)
$failures = 0
foreach ($owner in $owners) {
  $className = $owner.Substring(0, $owner.Length - 4)
  $class = $coverage.SelectNodes('//class') | Where-Object { ($_.name -replace '\\','/') -like "*/$className" } | Select-Object -First 1
  if ($null -ne $class) {
    $counter = $class.counter | Where-Object type -eq 'LINE'
    $covered = [int]$counter.covered
    $total = $covered + [int]$counter.missed
    $source = 'CURRENT_XML'
  }
  else {
    $pattern = '(?m)^\| `' + [regex]::Escape($owner) + '` \| M \| \d+ \| (?<covered>\d+)/(?<total>\d+) = (?<pct>[0-9.]+)% \|'
    $match = [regex]::Match($receipt, $pattern)
    if (-not $match.Success) {
      "$owner|XML_STATUS=MISSING|NUMERIC_STATUS=MISSING"
      $failures++
      continue
    }
    $covered = [int]$match.Groups['covered'].Value
    $total = [int]$match.Groups['total'].Value
    $source = 'AUTHORITATIVE_PRE_REMEDIATION_RECEIPT_XML_OWNER_MISSING'
  }
  $percent = 100.0 * $covered / $total
  $result = if ($percent -ge 80) { 'PASS' } else { 'FAIL_BELOW_80' }
  "$owner|SOURCE=$source|COVERED=$covered|TOTAL=$total|PERCENT=$('{0:F6}' -f $percent)|RESULT=$result"
  if ($percent -lt 80) { $failures++ }
}
"FAILURE_COUNT=$failures"
if ($failures -gt 0) { exit 1 }
exit 0
```

EXIT_CODE: 1
Output Summary: All three named Batch B owners failed the 80% line threshold. The current bundled MCP XML omitted the owner classes, so the command did not infer counters; it transparently preserved the exact source-attributed pre-remediation values from the authoritative QA receipt and labeled each result `AUTHORITATIVE_PRE_REMEDIATION_RECEIPT_XML_OWNER_MISSING`.

| Owner | Covered | Total | Line coverage | Current XML status | Result |
|---|---:|---:|---:|---|---|
| `.codex/hooks/validate-codex-subagent-routing.ps1` | 28 | 86 | 32.558140% | MISSING | FAIL_BELOW_80 |
| `.codex/scripts/launch-epic-child-wave.ps1` | 45 | 225 | 20.000000% | MISSING | FAIL_BELOW_80 |
| `.codex/scripts/resume-epic-child.ps1` | 40 | 178 | 22.471910% | MISSING | FAIL_BELOW_80 |

Failure count: 3

Acceptance result: PASS for `[expect-fail]`; every sub-threshold owner produced the expected failing disposition, and each observed numerator, denominator, and percentage is explicit.
