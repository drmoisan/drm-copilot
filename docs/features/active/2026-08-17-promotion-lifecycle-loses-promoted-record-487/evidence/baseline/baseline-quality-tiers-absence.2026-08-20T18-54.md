# Baseline — Tier-Classification Source Absence [P0-T10]

Timestamp: 2026-08-20T18-54

Command: `find . -name "quality-tiers.y*ml" -not -path "./node_modules/*" -not -path "*/node_modules/*"`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

SearchScope: The entire worktree `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`, recursively from the repository root, excluding `node_modules` trees.

SearchPatterns: `quality-tiers.y*ml` (matches both `quality-tiers.yml` and `quality-tiers.yaml`).

SearchResult: none. The command produced no output lines and exited 0. No file named `quality-tiers.yml` or `quality-tiers.yaml` exists anywhere in the worktree, including at the repository root where `.claude/rules/quality-tiers.md` states it must live.

## Raw Output

```
(no output)
```

Output Summary: **No tier-classification source exists in this repository.** `.claude/rules/quality-tiers.md` names `quality-tiers.yml` at the repository root as the source of truth mapping every project to a T1–T4 tier; that file is absent.

Consequences for this change, recorded so they are not re-litigated at P7-T11:

- **The uniform gates still bind.** `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` set line coverage >= 85% and branch coverage >= 75% uniformly across T1–T4. Those thresholds do not depend on a classification and are asserted for both TypeScript and Python in P7-T11. Format-check 100% pass, 0 lint errors, 0 type errors, and no regression on changed lines are likewise uniform and bind unconditionally.
- **The tier-dependent gates have no classification source.** Property-test density (`>= 1 per pure function` for T1/T2), mutation score (`>= 75%` for T1), untyped-escape-hatch limits, determinism retry rates, golden-test requirements, and E2E scope are all keyed to a tier that this repository does not record for the modules in scope. Those gates therefore cannot be evaluated for `flow.ts`, `new-active-feature-folder-service-call.ts`, `potential-to-issue-service-call.ts`, or `new_active_feature_folder_flow.py`.
- **Creating `quality-tiers.yml` is out of scope** for this bug fix, per the plan's Out-of-Scope Confirmations. This artifact records the absence as a verification outcome rather than remedying it.
