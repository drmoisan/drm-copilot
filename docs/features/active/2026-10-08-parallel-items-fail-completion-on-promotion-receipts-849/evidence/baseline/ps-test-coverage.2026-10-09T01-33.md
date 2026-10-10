# PowerShell Test and Coverage Baseline (P0-T19, Issue #849)

Timestamp: 2026-10-10T10-11
Command: Read of the H0 copies `evidence/baseline/poshqc-local/pester-junit.xml` and `evidence/baseline/poshqc-local/powershell-coverage.xml` under the plan's reading rules (no command re-run; values produced by the orchestrator's Source B CI run 38057875117)
EXIT_CODE: 0
Source: B (CI dispatch of `_poshqc.yml`, run 38057875117, headSha fd229cd7535be526cf7860367745cd1d4f4703f2)

## Copy acceptance check

- `run-record.md` carries `sanitized: root, absolute-paths, properties, hostname`.
- Freshness: `SourceB-Dispatched:` 2026-10-10T14:00:04Z is later than `H0-Trigger-Completed:` 2026-10-10T13:58:21Z.
- `SourceB-HeadSha:` fd229cd7535be526cf7860367745cd1d4f4703f2 equals `SourceB-LocalHead:` fd229cd7535be526cf7860367745cd1d4f4703f2.
- Sanitization spot check: zero `<properties` elements, zero drive-letter or `/home/` absolute paths, and every `hostname` attribute equals `HOST` (279 of 279) in pester-junit.xml; zero absolute paths in powershell-coverage.xml.

## Per-file JUnit values

| Test file | tests | errors | failures | skipped |
|---|---|---|---|---|
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | 42 | 0 | 0 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | 32 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | 35 | 0 | 0 | 0 |

- RB_PS_UNIT_PASSED: 42 (42 tests - 0 failures - 0 errors - 0 skipped)
- RB_PS_PARITY_PASSED: 32 (32 tests - 0 failures - 0 errors - 0 skipped)
- enforce-orchestration-preimplementation-gate.Tests.ps1 failures: 0

## Scan-folder sums

Testsuite elements whose `name` contains `tests\scripts\claude-lib\orchestrator-state\`, `tests\scripts\claude-hooks\`, or `tests\scripts\claude-runtime\`: 122 suites, 3039 tests, 0 errors, 0 failures, 0 skipped. The file contains zero `<failure` elements.

- RB_PS_FAILED: {}

## Line coverage

Package `WORKTREE_ROOT/.claude/lib/orchestrator-state`, sourcefile `OrchestratorStateIssueAdoption.psm1`:

`<counter type="LINE" missed="0" covered="112" />`

- RB_PS_LINE: 112 / (0 + 112) = 100.00%
- Pester does not measure branch coverage; no PowerShell branch figure exists.

## Analyzer

- Source B: `AnalyzeStep: success` (from `run-record.md`), which stands for zero analyzer findings. `analyzer-output.txt` is not written for Source B, so the four Source A per-file analyzer counts are not recorded.
- RB_PS_ANALYZE: AnalyzeStep success

Output Summary: Source B. RB_PS_UNIT_PASSED 42 (failures 0); RB_PS_PARITY_PASSED 32 (failures 0); enforce-orchestration-preimplementation-gate.Tests.ps1 failures 0; RB_PS_FAILED {} across 122 suites / 3039 tests in the three scan folders; RB_PS_LINE 100.00% (112/112) for OrchestratorStateIssueAdoption.psm1; AnalyzeStep success. Freshness and sanitization records accepted.
