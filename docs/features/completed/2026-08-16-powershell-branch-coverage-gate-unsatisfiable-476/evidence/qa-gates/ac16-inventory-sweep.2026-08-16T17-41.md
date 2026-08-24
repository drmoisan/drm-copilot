# AC16 — Late Inventory Sweep (Issue #476)

Timestamp: 2026-08-16T17-41

Command:
1. `rg -i -n --hidden "branch coverage|branch-coverage" .claude/ .agents/ .codex/ README.md extensions/drm-copilot/resources/claude-customizations/ extensions/drm-copilot/resources/codex-and-agents-customizations/` — identical to the P0-T6 baseline command
2. `rg -i -n --hidden "branch coverage[^.]{0,60}75%" <same roots> | grep -viE "branch-capable|whose coverage tooling measures branch coverage|applies additionally"` — residual statements binding the 75% figure to branch coverage with no capability qualifier on the same line
3. `git diff --name-only 687380a6 | grep -E "(^|/)shell\.md$"` and `git diff --stat -- .claude/rules/shell.md <mirror>`

EXIT_CODE: 0 (checks 1 and 2); 1 (check 3's grep, no-match exit — the required outcome)

## Check 1 — Baseline Comparison

| Metric | P0-T6 baseline | Post-change sweep | Delta |
| --- | --- | --- | --- |
| Matching lines | 49 | 49 | 0 |
| Matching files | 29 | 29 | 0 |

The totals are unchanged because every amendment rewrote a matching line in place rather than deleting the phrase: the amended text still contains the words "branch coverage", now in a capability-qualified or negating construction ("Branch coverage is not measurable by Pester for PowerShell", "there is no PowerShell branch-coverage gate", "for languages whose coverage tooling measures branch coverage"). A drop in the raw count was never the success condition; the success condition is the absence of an unqualified binding, tested in Check 2.

## Check 2 — Residual Statements Binding an Unqualified Branch `>= 75%` Requirement

The filter removes every line carrying a capability qualifier and reports what remains. Ten lines remain, comprising five distinct statements each duplicated in its bundle mirror. Every one is outside the edit surface and binds the threshold to a branch-capable language or to parameterized hook logic — none binds it to PowerShell.

| # | File (root, mirror identical) | Line | Statement binds branch `>= 75%` to | Disposition |
| --- | --- | --- | --- | --- |
| 1 | `.claude/rules/typescript.md` | 50 | TypeScript (branch-capable) | Correctly retained; AC5 requires it unchanged |
| 2 | `.claude/rules/python.md` | 89 | Python (branch-capable) | Correctly retained; AC5 requires it unchanged |
| 3 | `.claude/rules/csharp.md` | 44 | C# (branch-capable) | Correctly retained; AC5 requires it unchanged |
| 4 | `.claude/skills/python-qa-gate/SKILL.md` | 46 | Python (branch-capable) | Correctly retained; outside the edit surface |
| 5 | `.claude/hooks/validate-feature-review-coverage.ps1` | 327 | No language literally — the message is parameterized by `$Language` and `$BranchPct` | Correctly retained; AC10 prohibits modifying the hook. The hook reaches line 327 only when a branch percentage exists; `Get-JacocoBranchCoverage` returns `$null` for a zero-`BRANCH`-counter report and the floor check is skipped on null, so a Pester report never reaches this message |

**Residual statements binding an unqualified branch `>= 75%` requirement to PowerShell: 0.**

The eight root-file sites that did bind the threshold to PowerShell at baseline — `.claude/rules/powershell.md:64`, `.claude/rules/general-unit-test.md:24`, `.claude/rules/quality-tiers.md:25,34,51`, `.claude/skills/feature-review-workflow/SKILL.md:112-114`, `.claude/agents/feature-review.md:112-114`, `.claude/skills/powershell-qa-gate/SKILL.md:45`, `.agents/skills/general-unit-test/SKILL.md:29`, `.agents/skills/quality-tiers/SKILL.md:30,39,56` — plus `README.md:298` and all 8 bundle mirrors, are absent from the residual list because each now carries a capability qualifier or has had the branch conjunct removed outright.

`.codex/` produced zero matches at baseline and zero matches post-change.

## Check 3 — `.claude/rules/shell.md` Unchanged

An anchored filter (`(^|/)shell\.md$`) on the changed-file list returns no rows (exit code 1). An unanchored `shell.md` filter initially matched `powershell.md` as a substring; the anchored form is the correct test and is the one recorded here. `git diff --stat` over `.claude/rules/shell.md` and its bundle mirror produces no output, confirming both are unmodified.

Current text of `.claude/rules/shell.md:68-70`, unchanged:

```text
- kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per
  `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for
  bash; there is no bash branch-coverage gate.
```

Output Summary: PASS. The post-change sweep finds zero remaining statements binding an unqualified branch `>= 75%` requirement to PowerShell across `.claude/`, `.agents/`, `.codex/`, `README.md`, and both bundle payload trees. The ten residual unqualified matches all bind the threshold to a branch-capable language (TypeScript, Python, C#) or belong to the deliberately unmodified coverage hook, each of which the spec requires to remain unchanged. `.claude/rules/shell.md` and its bundle mirror are byte-unchanged.
