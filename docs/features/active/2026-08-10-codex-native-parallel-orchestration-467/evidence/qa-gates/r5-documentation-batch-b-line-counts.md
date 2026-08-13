# R5 documentation Batch B line-count gate

Timestamp: 2026-08-12T16:33:32.1693268Z

Command: `$paths=@('scripts/dev_tools/validate_parallel_codex_readiness.py','tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py'); $rows=foreach($p in $paths){[pscustomobject]@{Path=$p;Lines=(Get-Content -LiteralPath $p).Count}}; $rows|Format-Table -AutoSize; $bad=@($rows|Where-Object Lines -GT 500); "OVER_LIMIT=$($bad.Count)"; if($bad.Count){exit 1}`

EXIT_CODE: 0

Output Summary:

| Path | Lines | Result |
|---|---:|---|
| `scripts/dev_tools/validate_parallel_codex_readiness.py` | 495 | PASS |
| `tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py` | 447 | PASS |

Acceptance result: PASS. Both Batch B files are at or below 500 lines after the clean Black pass.
