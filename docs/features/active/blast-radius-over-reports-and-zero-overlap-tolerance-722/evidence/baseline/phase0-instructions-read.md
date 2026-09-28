# Phase 0 Policy Reads (Issue #722)

Timestamp: 2026-09-27T14-37
Command: file reads (no shell command; each file read in full with the Bash cat command or the Read tool)
EXIT_CODE: 0
Output Summary: All 27 files named by P0-T1 through P0-T9 were read in full, in the order below.

Policy Order: P0-T1 (CLAUDE.md, .github copilot instructions) -> P0-T2 (eight .github instruction
files: general code change, general unit test, Python code change, Python unit test, PowerShell code
change, PowerShell unit test, TypeScript code change, TypeScript unit test) -> P0-T3 (rule files
general-code-change, general-unit-test, quality-tiers, tonality) -> P0-T4 (rule files python,
python-suppressions, self-explanatory-code-commenting) -> P0-T5 (rule file powershell) -> P0-T6
(rule files typescript, typescript-suppressions, architecture-boundaries) -> P0-T7 (rule file
plan-acceptance-gates, evidence-and-timestamp-conventions skill) -> P0-T8 (parallel-orchestration
rule file) -> P0-T9 (feature issue, spec, research note).

## Files read

| Task | Order | File (repository-relative) |
| --- | --- | --- |
| P0-T1 | 1 | CLAUDE.md |
| P0-T1 | 2 | .github/copilot-instructions.md |
| P0-T2 | 3 | .github/instructions/general-code-change.instructions.md |
| P0-T2 | 4 | .github/instructions/general-unit-test.instructions.md |
| P0-T2 | 5 | .github/instructions/python-code-change.instructions.md |
| P0-T2 | 6 | .github/instructions/python-unit-test.instructions.md |
| P0-T2 | 7 | .github/instructions/powershell-code-change.instructions.md |
| P0-T2 | 8 | .github/instructions/powershell-unit-test.instructions.md |
| P0-T2 | 9 | .github/instructions/typescript-code-change.instructions.md |
| P0-T2 | 10 | .github/instructions/typescript-unit-test.instructions.md |
| P0-T3 | 11 | .claude/rules/general-code-change.md |
| P0-T3 | 12 | .claude/rules/general-unit-test.md |
| P0-T3 | 13 | .claude/rules/quality-tiers.md |
| P0-T3 | 14 | .claude/rules/tonality.md |
| P0-T4 | 15 | .claude/rules/python.md |
| P0-T4 | 16 | .claude/rules/python-suppressions.md |
| P0-T4 | 17 | .claude/rules/self-explanatory-code-commenting.md |
| P0-T5 | 18 | .claude/rules/powershell.md |
| P0-T6 | 19 | .claude/rules/typescript.md |
| P0-T6 | 20 | .claude/rules/typescript-suppressions.md |
| P0-T6 | 21 | .claude/rules/architecture-boundaries.md |
| P0-T7 | 22 | .claude/rules/plan-acceptance-gates.md |
| P0-T7 | 23 | .claude/skills/evidence-and-timestamp-conventions/SKILL.md |
| P0-T8 | 24 | .claude/rules/parallel-orchestration.md (full; includes the Read-by-mandate classification, Enum Ownership, and issue #500 sections) |
| P0-T9 | 25 | FEATURE/issue.md |
| P0-T9 | 26 | FEATURE/spec.md |
| P0-T9 | 27 | FEATURE/research/2026-09-27T12-25-blast-radius-tolerance-research.md |

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

## Notes recorded during the reads

- The executor has no PowerShell tool in this session; every PowerShell script runs through the
  plan's POSIX sh runner (script A1) invoked with the Bash tool, as the plan's Shell route section
  states.
- No file under the .claude rules directory or the .github instructions directory was modified.
