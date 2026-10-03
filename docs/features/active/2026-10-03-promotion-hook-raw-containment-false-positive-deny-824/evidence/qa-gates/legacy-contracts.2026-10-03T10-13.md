# P6-T11 LEGACY result inside the final full run (AC-25)

Timestamp: 2026-10-03T10-13
Command: [xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $cases = @($j.SelectNodes('//testcase') | Where-Object { $_.classname -like '*legacy-codex-hook-contracts*' -or $_.name -like '*byte-identical to their bundled copies*' -or $_.name -like '*lists every shared hook module in the core pack manifest*' }); "matched=$($cases.Count) failed=$(@($cases | Where-Object { $_.failure }).Count)"
EXIT_CODE: 0
Output Summary:
- matched=43 failed=0 (artifacts/pester/pester-junit.xml as produced by the P6-T3 direct run)
- Result: PASS
