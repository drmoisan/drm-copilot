# r3 Scratch Scripts Written (P1-T1, P1-T2, P1-T3)

Timestamp: 2026-10-16T21-15
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; foreach ($n in @("issue-953-r3-run-set.ps1", "issue-953-r3-bisect.ps1")) { $errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $S $n), [ref]$null, [ref]$errors); "PARSE_ERRORS=$n $($errors.Count)"; "LINES=$n $((Get-Content -LiteralPath (Join-Path $S $n)).Count)"; "SHA256=$n $((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $S $n)).Hash)" }' (SCRATCH/issue-953-r3-p1-t3.sh)
EXIT_CODE: 0
Output Summary:
- PARSE_ERRORS=issue-953-r3-run-set.ps1 0
- LINES=issue-953-r3-run-set.ps1 54
- SHA256=issue-953-r3-run-set.ps1 8CA4E8B93786A76F3C5BA3BAA9534A9E635C95A7B7F134DC86FDD55E3AA56B57
- PARSE_ERRORS=issue-953-r3-bisect.ps1 0
- LINES=issue-953-r3-bisect.ps1 96
- SHA256=issue-953-r3-bisect.ps1 8478B8F497091F8024FBFEEB0B02D2196EA723C51980C38F1EFABCCD8618C51A
- Result: PASS (both scripts parse with 0 errors; line counts 54 and 96 equal the plan blocks; both were written verbatim from the plan with the Write tool under SCRATCH).
