# Scope Check at the Merged Head (remediation [P3-T1])

Timestamp: 2026-11-07T18-04
Command: sh SCRATCH/issue-1037-r-scope.sh (BASE = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`; list = `git diff --name-only --no-renames BASE HEAD` united with every path of `git status --porcelain --untracked-files=all`; extension, `.codex/config.toml` and `.claude/lib/docs/` filters; `comm` against the [P1-T1] branch list SCRATCH/issue-1037-r-branch-p1t1.txt; `grep -i -E` over each listed file for the patterns `r[g]f` and `fore[c]ast`)
EXIT_CODE: 0
Output Summary: BASE resolves to the fetched integration tip (BASE_IS_TIP=true). 202 listed paths (202 from the anchored diff, 0 from porcelain status). Paths ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`: 0. `.codex/config.toml`: 0. `.claude/lib/docs/` paths: 0. Paths in the [P1-T1] branch list (194) but not in the current list: 0. Paths in the current list but not in the [P1-T1] list: 8, all remediation evidence files under `<FEATURE>/` (0 outside the feature folder). Pattern scan: 202 files scanned, 0 files with a match.

## Paths added since [P1-T1]

- `<FEATURE>/evidence/other/merge-preview.2026-11-07T17-45.md`
- `<FEATURE>/evidence/other/merge-result.2026-11-07T17-46.md`
- `<FEATURE>/evidence/qa-gates/powershell-format.2026-11-07T17-47.md`
- `<FEATURE>/evidence/qa-gates/powershell-analyze.2026-11-07T17-47.md`
- `<FEATURE>/evidence/regression-testing/codex-generator-check.2026-11-07T17-47.md`
- `<FEATURE>/evidence/qa-gates/pester-coverage.2026-11-07T17-58.md`
- `<FEATURE>/evidence/qa-gates/pytest-regression.2026-11-07T18-03.md`
- `<FEATURE>/evidence/qa-gates/jest-regression.2026-11-07T18-03.md`

The [P1-T1] list already holds `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` (edited in [P1-T3]) and both `pack-manifests/core.json` files, so the merge and the test edit add no path outside the feature folder. This artifact and the Phase 3 evidence written after it are further remediation files under `<FEATURE>/`.
