# Coverage Comparison — Baseline vs Post-Change

Timestamp: 2026-07-06T14-03

Sources:
- Baseline: `evidence/baseline/baseline-test.md`
- Post-change: `evidence/qa-gates/final-test.md`

## Repository-wide (bundled MCP coverage)

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Line coverage | 92.93% (999/1075) | 93.24% (1021/1095) | +0.31 pts |
| Instruction coverage | 91.83% (1394/1518) | 92.11% (1424/1546) | +0.28 pts |
| Tests | 1035 pass / 0 fail | 1063 pass / 0 fail | +28 tests |

## Changed-file coverage

| File | Baseline line | Post-change line | Determination |
|---|---|---|---|
| .claude/hooks/enforce-pr-author-skill.ps1 | 89.57% | 91.20% | PASS (>=85%, +1.63 pts, no regression) |
| .claude/hooks/validate-orchestrator-output.ps1 | 87.23% | 89.42% | PASS (>=85%, +2.19 pts, no regression) |
| .claude/lib/orchestrator-state/OrchestratorState.psm1 | n/a (new file) | 100.00% command | PASS (>=85%) |
| .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | n/a (new file) | 100.00% command | PASS (>=85%) |

## Branch coverage note

The PowerShell Pester coverage tooling emits LINE and INSTRUCTION (command) counters, not a report-level BRANCH counter. Instruction/command coverage is recorded as the finer-grained signal in place of branch coverage, consistent with the existing ModelRouting.psm1 module. All changed files exceed 85% line; the two new modules reach 100% command coverage (all rejection and fail-closed branches exercised), comfortably above the 75% branch floor.

## No-regression determination

PASS. No changed file dropped below its baseline coverage; both edited hooks increased. All changed files meet or exceed the line (>=85%) and branch (>=75%, represented by command coverage) thresholds. No threshold is unmet.
