# Baseline — PowerShell Tests and Coverage (PoshQC / Pester) (#501)

Timestamp: 2026-08-21T22-08

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-18`

EXIT_CODE: 0

Task: [P0-T4]

Numeric source: `artifacts/pester/powershell-coverage.xml` (JaCoCo-format report written by the run; report-level `LINE` counters) and `artifacts/pester/pester-junit.xml` (report-level `testsuites` attributes).

Output Summary:
- MCP result: `{"ok":true,"tool":"run_poshqc_test",...,"summary":"Ran bundled PoshQC test against '...2026-08-21T17-18'."}`. The MCP result surface carries no numeric counts, so the numbers below are read from the report files the run wrote.
- Tests: `tests="3116"`, `errors="0"`, `failures="0"`, `disabled="9"`, `time="192.110"` from the root `<testsuites>` element of `artifacts/pester/pester-junit.xml`. All executed tests passed.
- Coverage (baseline, line): report-level counters in `artifacts/pester/powershell-coverage.xml` are `<counter type="LINE" missed="228" covered="5792" />`, giving **96.2126% line coverage** over 6020 measured lines (5792 / 6020).
- Coverage (baseline, instruction, informational only — no threshold attached per `.claude/rules/powershell.md`): `<counter type="INSTRUCTION" missed="334" covered="8115" />` = 96.0450% over 8449 instructions.
- Branch coverage: not measured by Pester; no branch gate applies.
- Denominator note: this baseline predates the [P5-T6] `CodeCoverage.Path` additions, so the post-change denominator will be nine files larger. The >= 85% absolute threshold remains well-defined under both denominators.
