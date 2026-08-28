# Phase 0 Policy Read Evidence — [P0-T1]

Timestamp: 2026-08-28T12-46

Policy Order: The reading order defined by `.claude/skills/policy-compliance-order/SKILL.md`, as enumerated by [P0-T1] of the plan: `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/python.md`, then `.claude/rules/python-suppressions.md`, then `.claude/rules/powershell.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/plan-acceptance-gates.md`, then `.claude/rules/parallel-orchestration.md`.

Command: read of the nine policy files listed below, plus `wc -l` over the same nine paths to record their sizes in this worktree

EXIT_CODE: 0

## Files Read (nine, in reading order)

| # | Path | Lines in this worktree |
| --- | --- | --- |
| 1 | `CLAUDE.md` | 56 |
| 2 | `.claude/rules/general-code-change.md` | 80 |
| 3 | `.claude/rules/general-unit-test.md` | 105 |
| 4 | `.claude/rules/python.md` | 100 |
| 5 | `.claude/rules/python-suppressions.md` | 143 |
| 6 | `.claude/rules/powershell.md` | 97 |
| 7 | `.claude/rules/quality-tiers.md` | 51 |
| 8 | `.claude/rules/plan-acceptance-gates.md` | 257 |
| 9 | `.claude/rules/parallel-orchestration.md` | 412 |

Total: 1301 lines across nine files.

Output Summary: All nine policy files were read in the order defined by the policy-compliance-order skill. Constraints carried into execution: the Python toolchain order is black, ruff, pyright, pytest with a restart from step 1 on any failure or file rewrite; the PowerShell toolchain order is PoshQC format, analyze, test with type checking not applicable; uniform coverage thresholds are 85 percent line for both languages and 75 percent branch for Python only, with PowerShell exempt from the branch threshold because Pester does not measure it; no policy file under `.claude/rules/` may be modified; no new dependency may be added, which excludes `hypothesis`; no production, test, or reusable script file may exceed 500 lines; the PowerShell per-batch change budget of three production and three test files is respected by this change, which touches two production `.psm1` files and one `.Tests.ps1` file; suppressions must match a pre-authorized pattern, and this change introduces none; the acceptance-gate rule set is G1 through G9, with G1 and G2 Blocking and the remainder Warning; and the Blast-Radius Contention Doctrine requires out-of-scope path citations to stay unformatted so they are not harvested into the declared radius.
