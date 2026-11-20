# Preflight Fixes — Remediation Plan Cycle 2 (Issue 1025)

Timestamp: 2026-11-17T04-46
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-plan.2026-11-16T06-14.md

## Fixes

1. `## Text Checks` (c) | literal-formatting / binding-input citation | The plan cited cycle 1 grep 1, whose pattern omits `listed below`, while the binding `## Verification Commands` item 3 of `remediation-inputs.2026-11-16T06-14.md` states the R1 grep with `listed below`. (c) now also runs the inputs' R1 grep form. The asserted outcome is unchanged: each grep exits 1 with empty output (probed at preflight: both forms exit 1 in both trees).

## Probes (no fix needed)

- 65 base contracts and 65 bundle copies; 262 OB items and 327 AC items in the base tree (matches [P1-T6]).
- R3–R5 grep: 11 lines per tree (matches [P0-T1]); the two D-C2-1 lines are present in `csharp-orchestration-state-machine` and `powershell-orchestration-state-machine` OB-4.
- Cycle 1 greps 1 to 3 and the inputs' R1 form: exit 1 with empty output in both trees.
- Source-check row total: 10 + 9 + 8 + 4 + 1 = 32, matching [P2-T4] (29 findings: R3 8, R4 17, R5 4; 2 under D-C2-1; 1 under CR-14).
- Validation after the fix: Python CLI `plan` exit 0; MCP `plan` ok.
