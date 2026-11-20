# Pre-Change Branch-Coverage Inventory Grep (Issue #476)

Timestamp: 2026-08-16T17-14

Command: `rg -i -n --hidden "branch coverage|branch-coverage" .claude/ .agents/ .codex/ README.md extensions/drm-copilot/resources/claude-customizations/ extensions/drm-copilot/resources/codex-and-agents-customizations/` (run from the repository root; `docs/features/**` and `docs/research/**` are outside the search roots and therefore excluded by construction)

EXIT_CODE: 0

## Tooling Note (methodology correction, recorded for reproducibility)

The first invocation omitted `--hidden` and returned zero matches under both bundle payload roots. The cause is ripgrep's default hidden-file behavior: the mirror paths contain `.claude` and `.agents` as *nested* hidden directory components (`extensions/drm-copilot/resources/claude-customizations/.claude/...`), which ripgrep prunes unless `--hidden` is supplied. The top-level `.claude/` and `.agents/` roots were searched because they were named explicitly as search arguments. `git check-ignore` confirms the mirrors are not gitignored and `git ls-files` confirms they are tracked; the omission was a search-flag defect, not a missing-file condition. `--hidden` is therefore mandatory for this grep and is used for both this baseline and the P4-T9 post-change sweep so the two lists are comparable.

## Raw Result Totals

49 matching lines across 29 files. `.codex/` produced zero matches, confirming no branch-coverage statement exists on that surface.

## Sites Binding a Branch `>= 75%` Threshold to PowerShell (the defect surface — expected to change)

| # | File | Line(s) | Binding |
| --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md` | 64 | Direct: "Branch coverage must remain >= 75% across all tiers (T1–T4)." |
| 2 | `.claude/rules/general-unit-test.md` | 24 | Cross-language uniform statement; unqualified, so it reaches PowerShell |
| 3 | `.claude/rules/quality-tiers.md` | 25, 34, 51 | Uniform-thresholds statement, uniform gate bullet, rationale paragraph |
| 4 | `.claude/skills/feature-review-workflow/SKILL.md` | 112, 113, 114 | New files, modified files, repo-wide per language; PowerShell enumerated as a coverage language |
| 5 | `.claude/agents/feature-review.md` | 112, 113, 114 | Same three bullets |
| 6 | `.claude/skills/powershell-qa-gate/SKILL.md` | 45 | Direct: "line coverage >= 85% and branch coverage >= 75%" |
| 7 | `.agents/skills/general-unit-test/SKILL.md` | 29 | Codex restatement of site 2 |
| 8 | `.agents/skills/quality-tiers/SKILL.md` | 30, 39, 56 | Codex restatement of site 3 |
| — | `README.md` | 298 | "Coverage thresholds are uniform across all module tiers (T1–T4): line coverage >= 85% and branch coverage >= 75%" |

Each of sites 1-6 has a byte-identical mirror at the same relative line under `extensions/drm-copilot/resources/claude-customizations/`, and sites 7-8 under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. All mirror lines were confirmed present at the same line numbers in the `--hidden` run. This matches research R1 exactly: 8 root sites plus 8 mirrors plus `README.md:298`.

## Matches Outside the Edit Surface (correctly retained; must be unchanged after the fix)

| File | Line(s) | Reason retained |
| --- | --- | --- |
| `.claude/rules/python.md` (+ mirror) | 89 | Python is branch-capable; gate stays at `>= 75%` (AC5) |
| `.claude/rules/typescript.md` (+ mirror) | 50 | TypeScript is branch-capable; gate stays (AC5) |
| `.claude/rules/csharp.md` (+ mirror) | 44 | C# is branch-capable; gate stays (AC5) |
| `.claude/skills/python-qa-gate/SKILL.md` (+ mirror) | 46 | Python QA gate; not in the edit surface |
| `.claude/rules/shell.md` (+ mirror) | 69, 70 | The bash carve-out; structural precedent, explicitly not an edit target (AC16) |
| `.claude/hooks/validate-feature-review-coverage.ps1` (+ mirror) | 164, 327 | The coverage hook; already implements the target policy, explicitly not modified (AC10) |

Output Summary: The pre-change inventory records 49 matching lines across 29 files. Nineteen root-file line positions across 8 files bind an unqualified branch `>= 75%` requirement that reaches PowerShell, plus the same 19 positions in the bundle mirrors, plus `README.md:298`. Twelve further match positions (Python, TypeScript, C#, python-qa-gate, shell.md carve-out, and the coverage hook, each with its mirror) are outside the edit surface and must be textually unchanged after the fix. This list is the baseline against which the P4-T9 post-change sweep is compared.
