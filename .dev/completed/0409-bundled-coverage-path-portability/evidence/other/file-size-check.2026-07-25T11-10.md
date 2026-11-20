# File-Size Cap Check — PoshQC.Testing.psm1 (issue #409)

Timestamp: 2026-07-25T11-10

Command: `pwsh -NoLogo -NoProfile -Command "(Get-Content scripts/powershell/PoshQC/PoshQC.Testing.psm1).Count"`

EXIT_CODE: 0

Output Summary:
- Line count after the fix: **463**.
- Cap: 500 lines (`.claude/rules/general-code-change.md`, "File Size Limit"; `.claude/rules/powershell.md`, "Keep scripts cohesive and under 500 lines").
- Result: **463 <= 500 — PASS.** Headroom: 37 lines.
- Pre-change count was 443; the pruning block added 20 lines (`git diff --stat`: 21 insertions, 1 deletion, single hunk at `@@ -346 +346,21 @@ function Invoke-PoshQCTest {`), which is inside the plan's projected 15-25 line estimate.
- New test file `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1`: 259 lines, also under the 500-line cap.

No `SURFACE_DEVIATION:` was required. The approved two-file production surface was not widened: no helper was extracted and no new module pair was created. The contingency path in plan task [P2-T2] was not entered.
