# AC2 and AC4 — Line-Threshold and Branch-Clause-Scoping Guard (Issue #476)

Timestamp: 2026-08-16T17-27

Command:
1. `git diff --numstat -- .claude/ .agents/ README.md extensions/`
2. `git diff -U0 -- .claude/ .agents/ README.md | grep -E "^[-+]" | grep -v "^[-+][-+][-+]" | grep "85%"` — every removed/added line touching the `>= 85%` line threshold
3. `git diff -U0 -- .claude/rules/powershell.md | grep -E "^-"` — removed lines in the primary carve-out file
4. `git diff -U0 -- .claude/ .agents/ README.md | grep -E "^-" | grep -iE "regression|changed lines"` — every removed line touching the no-regression clause

EXIT_CODE: 0

## Change Volume (`git diff --numstat`)

| File | +/- |
| --- | --- |
| `.agents/skills/general-unit-test/SKILL.md` | 1 / 1 |
| `.agents/skills/quality-tiers/SKILL.md` | 3 / 3 |
| `.claude/agents/feature-review.md` | 5 / 3 |
| `.claude/rules/general-unit-test.md` | 1 / 1 |
| `.claude/rules/powershell.md` | 1 / 1 |
| `.claude/rules/quality-tiers.md` | 3 / 3 |
| `.claude/skills/feature-review-workflow/SKILL.md` | 4 / 4 |
| `.claude/skills/powershell-qa-gate/SKILL.md` | 1 / 1 |
| `README.md` | 1 / 1 |
| (8 bundle mirrors) | identical counts to their roots |

`.claude/agents/feature-review.md` shows 5 added / 3 removed because the qualification paragraph and its blank separator line were appended; the three bullets are a 3-for-3 replacement.

## Check A — AC2: no `>= 85%` line-coverage statement lowered, removed, or made conditional

Every removed line containing `85%` was compared to its replacement.

| # | File | Removed clause (line coverage part) | Replacement clause (line coverage part) | Verdict |
| --- | --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md` | (line 63 not removed) | (line 63 not removed) | PASS — line 63 is textually unchanged; see Check B |
| 2 | `.claude/rules/powershell.md:64` (new carve-out, added line) | n/a — the removed line 64 carried no `85%` | "The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies." | PASS — the threshold is restated, not weakened |
| 3 | `.claude/rules/general-unit-test.md:24` | (line 23 line bullet not removed) | (not removed) | PASS — the line bullet is byte-unchanged |
| 4 | `.claude/rules/quality-tiers.md` uniform bullet | (`- Line coverage: >= 85%.` not removed) | (not removed) | PASS — byte-unchanged |
| 5 | `.claude/rules/quality-tiers.md` rationale | "line coverage >= 85% and branch coverage >= 75% apply uniformly across T1–T4" | "line coverage >= 85% applies uniformly across T1–T4 to **every coverage language**" | PASS — line clause unconditional and explicitly universal |
| 6 | `.claude/skills/feature-review-workflow/SKILL.md:112-114` | "line coverage >= 85% and branch coverage >= 75%" (x3) | "line coverage >= 85%, and branch coverage >= 75% **for branch-capable languages**" (x3) | PASS — the `85%` clause carries no qualifier in any of the three bullets |
| 7 | `.claude/agents/feature-review.md:112-114` | "line coverage >= 85%, branch coverage >= 75%" (x3) | "line coverage >= 85%, branch coverage >= 75% **for branch-capable languages**" (x3) | PASS — same |
| 8 | `.claude/skills/powershell-qa-gate/SKILL.md:45` | "line coverage >= 85% and branch coverage >= 75% per the uniform tier rule" | "line coverage >= 85% per the uniform tier rule" | PASS — line threshold retained verbatim; only the branch conjunct removed |
| 9 | `.agents/skills/quality-tiers/SKILL.md:56` | as row 5 | as row 5 (Codex cross-reference) | PASS |
| 10 | `.agents/skills/general-unit-test/SKILL.md:28` line bullet | (not removed) | (not removed) | PASS — byte-unchanged |
| 11 | `README.md:298` | "line coverage >= 85% and branch coverage >= 75%, with no regression on changed lines" | "line coverage >= 85%, with no regression on changed lines. Branch coverage >= 75% applies additionally to languages whose coverage tooling measures branch coverage" | PASS — line threshold unconditional; only the branch clause is scoped |

Zero `>= 85%` statements were lowered, removed, or made conditional. Every qualifier introduced by this change attaches to the words "branch coverage" and to nothing else.

## Check B — AC2: `.claude/rules/powershell.md:63` textually unchanged

`git diff -U0 -- .claude/rules/powershell.md` reports exactly one removed line:

```text
-- Branch coverage must remain >= 75% across all tiers (T1–T4).
```

That is the former line 64. Line 63 (`- Line coverage must remain >= 85% across all tiers (T1–T4) per `.claude/rules/quality-tiers.md`.`) and line 65 (`- Coverage regression on changed lines is a blocking finding.`) appear only as unchanged context lines. The most important guard of this change is satisfied.

## Check C — AC4: the no-regression-on-changed-lines clause remains unconditional everywhere

Four removed lines mentioned the no-regression clause. Each replacement retains it without qualification.

| File | Removed | Replacement retains | Verdict |
| --- | --- | --- | --- |
| `.claude/agents/feature-review.md:113` | "and no regression on changed lines relative to baseline." | "and no regression on changed lines relative to baseline." (unqualified) | PASS |
| `.claude/skills/feature-review-workflow/SKILL.md:113` | "and no regression on changed lines relative to baseline. Flag as FAIL otherwise." | identical clause retained | PASS |
| `.claude/skills/powershell-qa-gate/SKILL.md:45` | "No regression on changed lines." | "No regression on changed lines." | PASS |
| `README.md:298` | "with no regression on changed lines." | "with no regression on changed lines." | PASS |

Additionally, the no-regression bullets that were *not* touched remain byte-unchanged: `.claude/rules/general-unit-test.md:25`, `.claude/rules/quality-tiers.md` (`- No regression on changed lines.`), `.claude/rules/powershell.md:65`, `.agents/skills/general-unit-test/SKILL.md:30`, and `.agents/skills/quality-tiers/SKILL.md` (`- No regression on changed lines.`). None appears in the removed-line set.

## Check D — AC4: the qualification attaches to the branch clause and to no other clause

Reading each amended passage, the introduced qualifiers are:
- "for languages whose coverage tooling measures branch coverage" — modifies "Branch coverage must remain >= 75%" / "Branch coverage: >= 75%"
- "for branch-capable languages" — modifies "branch coverage >= 75%"
- "applies additionally to languages whose coverage tooling measures branch coverage" — modifies "Branch coverage >= 75%" (README)

In no amended passage does a qualifier appear between a line-coverage figure and its subject, or attach to the no-regression clause. In `feature-review-workflow/SKILL.md` and `agents/feature-review.md` the added explanatory paragraph states affirmatively that PowerShell "is fully subject to the line threshold and the no-regression requirement", which reinforces rather than weakens both clauses.

Output Summary: PASS on both checks for all 17 files. AC2: no `>= 85%` line-coverage statement was lowered, removed, or made conditional; `.claude/rules/powershell.md:63` is textually unchanged (the file's only removed line is the former line 64). AC4: in every shared file the introduced qualification attaches to the branch clause and to no other clause; the line clause and the no-regression-on-changed-lines clause remain unconditional for all coverage languages including PowerShell.
