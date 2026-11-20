# Pass-After Evidence — Coverage-Path Pruning (issue #409)

Timestamp: 2026-07-25T11-14

Command: `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 -Output Detailed"`

EXIT_CODE: 0

Post-fix production state at time of this run:
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` — git blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`, 463 lines.
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` — same blob hash (byte-identical mirror).

Output Summary:
- Pester v5.6.1. Discovery found 4 tests in 1 file. Result: **Passed 4, Failed 0, Skipped 0, Inconclusive 0, NotRun 0**, completed in 718 ms.
- All four required scenarios pass. Per-scenario results:
  1. **PASS — all configured paths exist (pass-through preservation):** `passes the full resolved coverage set through and logs no prune lines when every configured path exists` (248 ms). `$InvokePester` received the full resolved set `@('/prune-root/present-a.ps1', '/prune-root/present-b.ps1')`, `CodeCoverage.Enabled` remained `$true`, and zero prune lines and zero disable lines were logged. This scenario also passed against pre-fix code (see `fail-before.2026-07-25T11-05.md`), which is the direct proof that the fix does not change behavior when every configured path exists.
  2. **PASS — mixed set:** `keeps only the existing paths and logs each pruned path with its resolved value for a mixed set` (34 ms). Only `/prune-root/present-a.ps1` and `/prune-root/present-c.ps1` survived; exactly one prune line was logged, equal to `Pruned nonexistent code coverage path: /prune-root/missing-b.ps1`, naming the resolved value; no disable notice was logged because the surviving set was non-empty.
  3. **PASS — empty surviving set:** `disables coverage at the $InvokePester boundary, logs one explanation, proceeds with the run, and skips the coverage copy when no configured path exists` (23 ms). `CodeCoverage.Enabled` was `$false` at the `$InvokePester` boundary; both pruned paths were logged individually (2 prune lines); the disable explanation was logged exactly once; the run proceeded, evidenced by the replayed summary line `Pester summary (replayed for readability):`; and `$CopyCoverage` was not invoked even though `$coverageOutputPath` was non-null.
  4. **PASS — rooted absolute entry:** `evaluates a rooted absolute entry with the same predicate and never re-joins it to -Root` (15 ms). The rooted survivor was forwarded as `/rooted-present.ps1`, asserted `Not -BeLike '/prune-root/*'`, proving no re-join to `-Root`; the rooted missing entry was pruned and logged as `Pruned nonexistent code coverage path: /rooted-missing.ps1`.
- Determinism: all scenarios are seam-injected via `$TestPathExists`, `$Logger`, `$InvokePester`, `$CopyCoverage`, `$LoadSettings`, `$BuildConfiguration`, `$EnsureModule`, `$ResolveScanConfig`, `$EnumerateTests`, and an `$ExpandCoveragePaths` pass-through. `New-Item` is mocked inside `InModuleScope PoshQC`. No temp files, no filesystem writes, no live Pester subprocess for the code under test, no timing waits.
