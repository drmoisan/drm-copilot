# Task Check — Light Remediation Cycle 3 [P0-T1] (Issue 1025)

Timestamp: 2026-11-17T07-07
Inputs: `remediation-inputs.2026-11-17T06-52.md` `## Light Fix Tasks` [P0-T1] (R6 = CR-15, plus the optional CR-17 alignment)

## Changed Files

- `.agents/skills/python-change-budget-router/references/standard.md` (OB-1, OB-3)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-change-budget-router/references/standard.md` (byte copy of the base)

## Selection and Rule

Changed paths are Markdown contracts, so the selection is the contract tests that read them: the plan A Python contract set (five modules) and the four-file Pester selection named by the cycle 3 delegation (`parallel-gate-wording`, `test-cadence-wording`, `policy-toolchain-naming`, `HarnessParityMatrix.RepoGate`), plus Text Checks (a) to (c) of `remediation-plan.2026-11-16T06-14.md`.

## Commands

Timestamp: 2026-11-17T07-03
Command: `sh SCRATCH/issue-1025-c2-tc.sh c3t1 python-change-budget-router` (runs `sh SCRATCH/issue-1025-textcheck.sh python-change-budget-router`, then the launcher `pytest` suite over the five contract modules, then the launcher `pester` suite with `-TestPath` and the four selected files)
EXIT_CODE: 0
Output Summary:
- (a) Contract lint: VIOLATIONS: 0 (base and bundle copy); LINT_EXIT=0.
- (b) cmp: PAIRS=1 DIFFERING=0.
- (c) Greps over both trees (g1, g1-inputs, g2, g3, g4, R3–R5): each exit 1 with 0 lines.
- Launcher pytest (five contract modules): exit 0, 92 passed.
- Launcher pester `-TestPath` (four files): exit 0, 4 shards, 269 passed, 0 failed, 0 skipped (shard counts 136, 108, 18, 7); wall-clock 137.26s. Task-check evidence only, not a gate.

## Source Check

| Contract | OB | Source heading | Members | Named | Prior text | New text | Class closed |
|---|---|---|---|---|---|---|---|
| python-change-budget-router | OB-3 | `## Orchestrated Small-Path Requirements` | promotion and folder lifecycle steps through the repository automation tools; stop before promotion when the required tool is unavailable | all named | If the MCP server or required tool is unavailable, stop before promotion. | Promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins. | R5 (R6/CR-15) |
| python-change-budget-router | OB-1 | `## Canonical Routing Rules` | estimate from production Python files; 1 to 3 production files with tests to the small path; more than 3 to the large path with no production-file cap; test files not counted | all named | Estimate rough change budget first based on likely production Python files touched. | The skill first estimates the change budget from the likely production Python files touched and then routes 1 to 3 production files with their tests to the small path (`python-typed-engineer` direct mode) and more than 3 production files to the orchestrated large path, which has no production-file cap, and test files are not counted toward the routing threshold. | CR-17 alignment (Nit) |

OB-1 names the large path tool-neutrally ("the orchestrated large path") instead of the source's runtime prompt path, under rewrite rule 3.
