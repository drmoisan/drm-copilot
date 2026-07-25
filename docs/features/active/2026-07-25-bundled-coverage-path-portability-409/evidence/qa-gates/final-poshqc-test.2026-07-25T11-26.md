# Final QC — PowerShell Test and Coverage (issue #409)

Timestamp: 2026-07-25T11-26

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52`

EXIT_CODE: 0

Output Summary:
- Tool returned `{"ok":true,"tool":"run_poshqc_test", ...}` with summary `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52'.`
- Test counts (from tool output `artifacts/pester/pester-junit.xml`): **1354 tests, 0 failures, 0 errors, 9 skipped.** Baseline was 1350 tests; the increase of exactly 4 is the new test file.
- **Numeric post-change line coverage: 90.22%** (JaCoCo report-level `LINE` counter: covered 2150, missed 233). Baseline was 90.19% (covered 2143, missed 233) — coverage increased, no regression.
- Numeric post-change command/instruction coverage: **89.68%** (covered 2929, missed 337). Baseline 89.64% (covered 2916, missed 337).
- Measured files: 31 distinct `<sourcefile>` entries, identical in count to baseline.
- Threshold status: line 90.22% >= 85% PASS. Branch coverage is not separately measurable in the PowerShell toolchain (Pester 5.6.1 JaCoCo output emits `INSTRUCTION`, `LINE`, `METHOD`, `CLASS` counters only, no `BRANCH` counter) — documented limitation per `spec.md` Test Strategy.
- **The new test file was discovered and passed inside this run.** JUnit suite entry: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1` with `tests=4 failures=0`.
- No files were changed by this stage, so the toolchain loop does not restart.

Harness note: this stage runs the npx-cached published `@danmoisan/drm-copilot-mcp` 1.0.18 bundle, not the edited repository module. It is therefore the mandated toolchain gate and the coverage denominator for the changed file (coverage breakpoints bind to the on-disk `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, which the new test file imports and drives), but it is **not** the AC-4 invariance harness. The AC-4 invariance harness is the direct repo-root module run in task [P4-T4].
