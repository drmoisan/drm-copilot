# R5 documentation Batch A line-count gate

Timestamp: 2026-08-12T16:14:36.8588342Z

Command: `$paths=@('scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py','scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py','tests/scripts/dev_tools/test_parallel_resume_truth.py','tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py'); $rows=foreach($path in $paths){[pscustomobject]@{Path=$path;Lines=(Get-Content -LiteralPath $path).Count}}; $rows | Format-Table -AutoSize; $bad=@($rows|Where-Object Lines -GT 500); "OVER_LIMIT=$($bad.Count)"; if($bad.Count){exit 1}`

EXIT_CODE: 0

Output Summary:

| Path | Lines | Result |
|---|---:|---|
| `scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py` | 414 | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py` | 465 | PASS |
| `tests/scripts/dev_tools/test_parallel_resume_truth.py` | 243 | PASS |
| `tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py` | 286 | PASS |

Acceptance result: PASS. All four Batch A files are at or below 500 lines after the clean Black pass.
