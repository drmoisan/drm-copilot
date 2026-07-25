# Baseline — PowerShell Test and Coverage (issue #409)

Timestamp: 2026-07-25T10-46

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52`

EXIT_CODE: 0

Output Summary:
- Tool returned `{"ok":true,"tool":"run_poshqc_test", ...}` with summary `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T09-52'.`
- Test counts (from the tool output `artifacts/pester/pester-junit.xml`): 1350 tests, 0 failures, 0 errors, 9 skipped, 61.849 s.
- Numeric baseline line coverage: **90.19%** (JaCoCo report-level `LINE` counter: covered 2143, missed 233, total 2376).
- Numeric baseline command/instruction coverage: **89.64%** (report-level `INSTRUCTION` counter: covered 2916, missed 337, total 3253). Pester's own replayed "Covered %" headline is derived from the command/instruction counter.
- Measured files: 31 distinct `<sourcefile>` entries in `artifacts/pester/powershell-coverage.xml`.
- Branch coverage is **not separately measurable** in the PowerShell toolchain. Pester 5.6.1's JaCoCo output emits `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only; no `BRANCH` counter is produced. This is a documented limitation recorded in `spec.md` (Test Strategy: "Branch coverage is not separately measurable for PowerShell in this toolchain (documented limitation)").
- Baseline line coverage 90.19% is above the repository threshold of >= 85% (`.claude/rules/quality-tiers.md`).

Harness note: this baseline was produced by the MCP tool, which executes the npx-cached published `@danmoisan/drm-copilot-mcp` 1.0.18 bundle. That bundle's `resources/powershell/PoshQC/PoshQC.Testing.psm1` is currently byte-identical to the repo-root copy (git blob `53756b61a31c0a90b11e51e96f099fb6375c0af4`). The AC-4 invariance baseline is captured separately by task [P0-T5] from a direct repo-root module run.
