# Remediation Baseline — Cycle 2 Contract Text (Issue 1025)

Timestamp: 2026-11-17T04-47
Head: 5bb41dc645b24aa0b19f3f6fd811fb087b1e018e
Plan task: [P0-T1] of `remediation-plan.2026-11-16T06-14.md`
Command: `sh SCRATCH/issue-1025-textcheck.sh all` (Text Checks (a), (b) and (c) over all 65 contracts and both trees)
EXIT_CODE: 0
Output Summary: 65 contracts x 2 copies, 0 lint violations; 65 cmp pairs, 0 differing; cycle 1 greps 1 to 4 and the inputs' R1 form return 0 lines (exit 1) in each tree; the R3–R5 grep returns 11 lines per tree (fail-before state).

## (a) Contract lint

Command: `sh SCRATCH/issue-1025-lint-contracts.sh <all 65 names>` (imports `scripts/harness/HarnessSkillContract.psm1`, calls `Get-HarnessSkillContractViolation` on the base and bundle copy)
EXIT_CODE: 0
Output: `CONTRACTS_CHECKED: 65 (x2 copies)`, `VIOLATIONS: 0`

## (b) Mirror identity

Command: `cmp -s .agents/skills/<name>/references/standard.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md` for each of the 65 names
EXIT_CODE: 0
Output: `PAIRS=65 DIFFERING=0`

## (c) Regression greps (per tree)

| Grep | Base tree exit / lines | Bundle tree exit / lines |
| --- | --- | --- |
| 1 (cycle 1 R1 form) | 1 / 0 | 1 / 0 |
| 1 (inputs R1 form, with `listed below`) | 1 / 0 | 1 / 0 |
| 2 (R2) | 1 / 0 | 1 / 0 |
| 3 (cycle 1 sweep) | 1 / 0 | 1 / 0 |
| 4 (forbidden tokens) | 1 / 0 | 1 / 0 |
| R3–R5 (Verification Command 3) | 0 / 11 | 0 / 11 |

R3–R5 grep lines (identical in both trees; the 9 named R3/R5 items plus the two D-C2-1 items):

1. `atomic-plan-contract` OB-4 (R3)
2. `csharp-orchestration-state-machine` OB-4 (D-C2-1)
3. `epic-plan` OB-1 (R5)
4. `evidence-and-timestamp-conventions` OB-5 (R3)
5. `orchestrate` OB-1 (R5)
6. `powershell-orchestration-state-machine` OB-4 (D-C2-1)
7. `review-epic` OB-1 (R3)
8. `skill-canonical-location-audit` OB-2 (R3)
9. `skill-canonical-location-audit` OB-3 (R3)
10. `translate-copilot-to-claude` OB-2 (R5)
11. `translate-copilot-to-claude` OB-5 (R5)

Acceptance: all 65 pairs 0 violations and no cmp difference; cycle 1 greps 1 to 4 return 0 lines; the R3–R5 grep returns exactly 11 lines per tree. PASS.
