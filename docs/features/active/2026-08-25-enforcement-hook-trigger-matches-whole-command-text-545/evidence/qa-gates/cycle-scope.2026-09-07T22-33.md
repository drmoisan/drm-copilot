# Final QA — cycle-2 changed-file scope

Task: `[P5-T4]`
Timestamp: 2026-09-07T22-33

Anchor: the **cycle-scope** anchor `26dba29533ba70f6cd80d14ac3c87ac24ca82aca`, the parent of the
plan commit `459d245f893f3337d61496b2602830e381d1d7a3`. This task asks what cycle 2 changed, so the
cycle-scope anchor is the correct base. The feature-wide anchor `6dff80ed` would enumerate the whole
of #545 and could never report a twenty-one-path cycle scope; it is used only by `[P5-T5]`.

## Commands

Command: `git add -A`
EXIT_CODE: 0

Required because a name-listing diff enumerates tracked changes only and would report an empty list
for the evidence artifacts this cycle creates.

Command: `git diff --cached --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca`
EXIT_CODE: 0

Command: `git status --porcelain`
EXIT_CODE: 0

Required because it is the only view that survives if the change is committed before this task runs.
The two spans are complementary and each alone is wrong in one state.

## Totals

| Measure | Value |
|---|---|
| paths in the anchored cached diff | 61 |
| `.ps1` paths | 21 |
| `.md` paths | 40 |
| non-evidence paths | 22 |
| evidence-tree paths | 39 |
| `git status --porcelain` lines | 61 |
| porcelain `M` rows | 22 |
| porcelain `A` rows | 39 |

The two spans agree: 61 paths from each, with the porcelain `M`/`A` split of 22/39 matching the
non-evidence / evidence-tree split of the diff.

## The required twenty-one paths, enumerated

All twenty-one are present and there is no twenty-second PowerShell path. `grep -c '\.ps1$'` over
the diff returns exactly **21**.

Seven canonical production files (standing constraint 4):

| # | Path |
|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` |
| 2 | `.codex/hooks/hook-command-scanner.ps1` |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` |
| 7 | `.claude/hooks/validate-bash.ps1` |

Seven bundle mirrors:

| # | Path |
|---|---|
| 8 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` |
| 9 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` |
| 10 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` |
| 11 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` |
| 12 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` |
| 13 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` |
| 14 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` |

Seven test suites this cycle edits:

| # | Path |
|---|---|
| 15 | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` |
| 16 | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` |
| 17 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` |
| 18 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` |
| 19 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` |
| 20 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` |
| 21 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` |

**Exact count: 21 of 21 present, 0 unexpected PowerShell paths.**

## Additionally permitted paths, listed separately

| Path | Basis |
|---|---|
| `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md` | expected and explicitly permitted: the plan commit `459d245f` sits between the cycle-scope anchor and HEAD, so the plan file is in the anchored diff by construction, and its checkbox state is additionally updated during execution |
| 39 paths under `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/` | evidence tree, explicitly permitted |

`spec.md` is permitted but does not appear: no acceptance criterion was checked off in this
execution group. AC-09 is checked by `[P5-T10]` in the next group, and AC-22 is the orchestrator's.

## Blocking check

Any PowerShell path in the set other than the twenty-one blocks closure. The set contains exactly
21 `.ps1` paths and all 21 are on the required list, so nothing blocks. No file under
`.claude/lib/`, no `hook-command-invocation.ps1` on either runtime, no
`.codex/hooks/validate-bash.ps1`, and no
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` appears.

## Note on staging

`git add -A` staged the working tree so the name-listing diff could see the newly created evidence
artifacts. Nothing was committed. HEAD remains `459d245f893f3337d61496b2602830e381d1d7a3`; the
orchestrator commits after this execution group.

## Output Summary

The anchored cached diff enumerates 61 paths: the 21 required PowerShell paths, the plan file, and
39 evidence-tree artifacts. All 21 required paths are present, the `.ps1` count is exactly 21, and
no unexpected PowerShell path appears. The porcelain span agrees at 61 lines with a 22 `M` / 39 `A`
split. Cycle scope holds.
