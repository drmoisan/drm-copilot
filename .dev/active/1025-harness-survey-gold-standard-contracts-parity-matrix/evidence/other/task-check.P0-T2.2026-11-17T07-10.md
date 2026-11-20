# Task Check — Light Remediation Cycle 3 [P0-T2] (Issue 1025)

Timestamp: 2026-11-17T07-10
Inputs: `remediation-inputs.2026-11-17T06-52.md` `## Light Fix Tasks` [P0-T2] (R7 = CR-16)

## Changed Files

- `.agents/skills/execution-environment/references/standard.md` (OB-4)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/references/standard.md` (byte copy of the base)

## Selection and Rule

Changed paths are Markdown contracts, so the selection is the contract tests that read them: the plan A Python contract set (five modules) and the four-file Pester selection named by the cycle 3 delegation, plus Text Checks (a) to (c) of `remediation-plan.2026-11-16T06-14.md`.

## Commands

Timestamp: 2026-11-17T07-08
Command: `sh SCRATCH/issue-1025-c2-tc.sh c3t2 execution-environment` (text checks, then the launcher `pytest` suite over the five contract modules, then the launcher `pester` suite with `-TestPath` and the four selected files)
EXIT_CODE: 0
Output Summary:
- (a) Contract lint: VIOLATIONS: 0 (base and bundle copy); LINT_EXIT=0.
- (b) cmp: PAIRS=1 DIFFERING=0.
- (c) Greps over both trees (g1, g1-inputs, g2, g3, g4, R3–R5): each exit 1 with 0 lines.
- Launcher pytest (five contract modules): exit 0, 92 passed.
- Launcher pester `-TestPath` (four files): exit 0, 4 shards, 269 passed, 0 failed, 0 skipped; wall-clock 131.42s. Task-check evidence only, not a gate.

## Source Check

| Contract | OB | Source heading | Members | Named | Prior text | New text | Class closed |
|---|---|---|---|---|---|---|---|
| execution-environment | OB-4 | `## Command-Text Restrictions` | the two mechanisms (runtime worktree isolation guard; repository command hooks: destructive patterns, a directory change followed by a file-reading command, a direct test runner, merge text not bound to one pull request under concurrent review); the preferred forms (target directory named on the tool, one-number merge in its own command, multi-line inline Python placed in a file) | all named | Two separate mechanisms restrict Bash command text. | Command text is restricted by two separate mechanisms with different causes and fixes, the runtime worktree isolation guard, which is not a repository hook and refuses command text it cannot show stays inside an agent-isolated worktree, and the repository command hooks, which deny destructive patterns, a directory change followed later in the same command by a file-reading command, a direct test runner in place of the test-execution launcher, and merge text that cannot be bound to one pull request when a checkpoint records concurrent review, so the preferred forms name the target directory on the tool instead of changing into it, issue a merge as one pull request number in its own command, and place a multi-line inline Python program in a file because it otherwise exits without running. | R4 (R7/CR-16) |

The sentence extends the inputs' example to the section's merge-text, test-execution-hook and inline-Python bullets so that it states the whole section (rewrite rule 2). It names no runtime tool name; mechanism names are allowed because the contract's subject is the execution environment.
