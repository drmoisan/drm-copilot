Timestamp: 2026-09-26T23-39

Command:
```
$Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
$Token = '$entries = @($script:CommittedConfig[''mandate_reads''])'
(Select-String -Path $Target -Pattern ([regex]::Escape($Token))).Count
```

EXIT_CODE: 0

Output Summary: Count is 1. The out-of-scope `mandate_reads` two-statement form (D3, excluded from this fix) remains byte-for-byte unchanged.
