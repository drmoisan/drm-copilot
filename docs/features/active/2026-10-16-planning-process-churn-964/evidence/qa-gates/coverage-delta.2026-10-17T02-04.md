# QA Gate — Coverage Delta (final pass, merged tree)

Timestamp: 2026-10-17T02-04
Task: [P6-T8]
Command: comparison of the [P0-T4], [P0-T6], [P0-T8] baseline artifacts with `python-tests.2026-10-17T02-04.md`, `ts-tests.2026-10-17T02-04.md`, and `ps-tests.2026-10-17T02-04.md`
EXIT_CODE: 0
Output Summary:
- No regression in any language total or changed production file; every new or changed production file is at or above 85% line, and every Python and TypeScript file at or above 75% branch.

| Language | Scope | Baseline | Post-change | Disposition |
|---|---|---|---|---|
| Python | Total (line / branch) | 94.04% / 88.65% | 94.11% / 88.78% | PASS |
| Python | `plan_gate_document.py` (new) | n/a | 100.00% / 100.00% | PASS |
| Python | `plan_gate_discrimination.py` | 99.25% / 98.08% | 99.26% / 98.08% | PASS |
| Python | `generate_codex_agent_variants.py` | 90.62% / 82.61% | 94.53% / 89.13% | PASS |
| Python | `codex_native_converter/rewrites.py` | 91.30% / 85.71% | 91.30% / 85.71% | PASS |
| TypeScript | Total (lines / branches) | 97.39% / 92.63% | 97.41% / 92.65% | PASS |
| TypeScript | `plan-gate-document.ts` (new) | n/a | 100% / 95.08% | PASS |
| TypeScript | `plan-gate-discrimination.ts` | 100% / 98.27% | 100% / 98.27% | PASS |
| TypeScript | `codex-native-converter/rewrites-rules.ts` | 100% / 100% | 100% / 100% | PASS |
| PowerShell | Total (line) | 92.09% | 92.23% | PASS |
| PowerShell | `premortem-section.ps1` (new) | n/a | 100.00% | PASS |
| PowerShell | `validate-planner-output.ps1` | 99.50% | 99.52% | PASS |
| PowerShell | `validate-task-researcher-output.ps1` | 97.09% | 98.17% | PASS |
| PowerShell | `validate-executor-output.ps1` | 98.33% | 100.00% | PASS |

The earlier artifact `coverage-delta.2026-10-17T01-12.md` named the uncovered executor-hook lines without checking them; the coverage XML showed one new uncovered line (the `Test-PreflightFixRecord` body) and two pre-existing ones. Cases for all three were added in [P6-T9], and the executor hook now measures 100%.
