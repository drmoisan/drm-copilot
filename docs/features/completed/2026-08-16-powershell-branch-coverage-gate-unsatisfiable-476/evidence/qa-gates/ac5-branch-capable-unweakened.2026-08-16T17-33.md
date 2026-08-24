# AC5 — Branch-Capable Languages Unweakened (Issue #476)

Timestamp: 2026-08-16T17-33

Command:
1. `rg -n --hidden ">= 75%" <amended shared files> | grep -i branch` — the retained branch threshold in each amended shared file
2. `git diff --name-only | grep -E "rules/(python|typescript|csharp)\.md"` — presence of the three language rule files in the changed-file list
3. `rg -n --hidden "Branch coverage|branch coverage" .claude/rules/python.md .claude/rules/typescript.md .claude/rules/csharp.md` — current text of the three gates

EXIT_CODE: 0 (checks 1 and 3); 1 (check 2, grep's no-match exit — the required outcome)

## Check 1 — The `>= 75%` Branch Threshold Is Retained, Scoped to Branch-Capable Languages

| File | Line | Retained branch statement |
| --- | --- | --- |
| `.claude/rules/general-unit-test.md` | 24 | "Branch coverage must remain **>= 75%** across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage." |
| `.claude/rules/quality-tiers.md` | 34 | "Branch coverage: **>= 75%** for languages whose coverage tooling measures branch coverage." |
| `.claude/rules/quality-tiers.md` | 51 | "branch coverage **>= 75%** applies uniformly across T1–T4 to every language whose coverage tooling measures branch coverage" |
| `.claude/skills/feature-review-workflow/SKILL.md` | 112, 113, 114 | "branch coverage **>= 75%** for branch-capable languages. Flag as FAIL otherwise." (all three bullets) |
| `.claude/agents/feature-review.md` | 112, 113, 114 | "branch coverage **>= 75%** for branch-capable languages" (all three bullets) |
| `.agents/skills/general-unit-test/SKILL.md` | 29 | "Branch coverage must remain **>= 75%** across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage." |
| `.agents/skills/quality-tiers/SKILL.md` | 39, 56 | Same as `quality-tiers.md` 34 and 51 |
| `README.md` | 298 | "Branch coverage **>= 75%** applies additionally to languages whose coverage tooling measures branch coverage" |

The threshold value is unchanged at `>= 75%` in every amended file. `.claude/skills/feature-review-workflow/SKILL.md` and `.claude/agents/feature-review.md` name the branch-capable set explicitly as "TypeScript, Python, and C#". No amended file lowers, removes, or conditions the branch threshold for any branch-capable language; the qualification narrows the set of languages the threshold reaches to exactly those for which it is evaluable.

## Check 2 — The Three Language Rule Files Are Unmodified

`git diff --name-only` filtered for `rules/(python|typescript|csharp)\.md` returns no rows (grep exit code 1). None of the following appears in the changed-file list:

- `.claude/rules/python.md`
- `.claude/rules/typescript.md`
- `.claude/rules/csharp.md`

Their bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/` are likewise absent from the changed-file list.

## Check 3 — Their Branch Gates Read As Before

```text
.claude/rules/python.md:89:- Branch coverage must remain >= 75% across all tiers (T1–T4).
.claude/rules/typescript.md:50:- Coverage thresholds follow the uniform tier rule defined in `.claude/rules/quality-tiers.md`: line coverage >= 85% and branch coverage >= 75% across all tiers (T1–T4).
.claude/rules/csharp.md:44:- Line coverage line >= 85% and branch coverage branch >= 75% uniform across all tiers (T1–T4). No tier-specific lower floor is used.
```

Each is byte-identical to its pre-change text as recorded in the P0-T6 baseline inventory (`evidence/baseline/branch-coverage-grep-baseline.2026-08-16T17-14.md`, "Matches Outside the Edit Surface" table, rows for python.md:89, typescript.md:50, csharp.md:44).

Note on `.claude/rules/typescript.md:50`: it delegates to `.claude/rules/quality-tiers.md` while also restating both figures locally. The amended `quality-tiers.md` continues to state branch `>= 75%` for branch-capable languages, and TypeScript is branch-capable, so the delegation resolves to an unchanged obligation. The same reasoning applies to `.claude/skills/python-qa-gate/SKILL.md:46`, which is unmodified and outside the edit surface.

Output Summary: PASS. The `>= 75%` branch threshold is retained in every amended shared file, scoped to branch-capable languages, with TypeScript, Python, and C# named explicitly in the two feature-review surfaces. `.claude/rules/python.md`, `.claude/rules/typescript.md`, and `.claude/rules/csharp.md` (and their bundle mirrors) do not appear in `git diff --name-only` and their branch statements are byte-identical to the P0-T6 baseline.
