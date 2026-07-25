# PowerShell Test and Coverage Baseline — PoshQC / Pester (issue #413)

Timestamp: 2026-07-25T17-01

Command:

1. `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df` (authoritative for pass/fail)
2. `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` at repo root (authoritative for coverage numbers)

EXIT_CODE: 0

- MCP call (1) returned `{"ok":true,"tool":"run_poshqc_test", ...}` — pass.
- Direct run (2) completed with `Failed: 0` and produced both run outputs without error.

Output Summary:

Pass/fail counts (from `artifacts/pester/pester-junit.xml`, `<testsuites>` attributes, and the
console summary of run 2):

- Tests discovered: 1354 in 86 files
- Tests Passed: 1345
- Failed: 0
- Errors: 0
- Skipped / disabled: 9
- Inconclusive: 0, NotRun: 0
- Duration: 32.17s

Coverage (from `artifacts/pester/powershell-coverage.xml`, Pester `CoverageGutters` / JaCoCo format):

- Overall covered percentage (report-level INSTRUCTION counter): **89.68%**
  (covered 2,929 / (covered 2,929 + missed 337) = 2,929 / 3,266). Console line:
  `Covered 89.68% / 0%. 3,266 analyzed Commands in 31 Files.`
- Overall report-level LINE counter: 2,150 covered / 233 missed = 90.22%.
- Per-file value for the changed hook `.claude/hooks/validate-orchestrator-output.ps1`
  (summed INSTRUCTION counters under that file's `<sourcefile name="validate-orchestrator-output.ps1">`
  element inside `<package name=".../.claude/hooks">`, i.e. covered / (covered + missed);
  the report-level total was NOT used as the per-file value):
  - INSTRUCTION: covered **167**, missed **12** -> **93.30%** (167 / 179 commands)
  - LINE (same sourcefile element, recorded for completeness): covered 94, missed 8 -> 92.16%
  - METHOD: covered 5, missed 0 -> 100%

Branch coverage: not emitted — this toolchain's Pester CoverageGutters output provides
INSTRUCTION/LINE/METHOD counters only and no BRANCH counter (precedent:
docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/baseline/poshqc-test-baseline.md).

The absent branch metric is a documented tooling limitation and does not trigger the
fail-closed evidence rule (explicit in plan task [P0-T5]).

Gate status at baseline: overall line/instruction coverage 89.68% >= 85% threshold. The
per-file baseline of 93.30% for the changed hook is the no-regression reference value that
[P6-T5] compares the post-change value against.
