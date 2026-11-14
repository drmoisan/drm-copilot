# Scope and Structure Check (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-36
Command: sh SCRATCH/issue-1006-scope.sh (git diff --name-only MERGE_BASE compared with git diff --name-only MERGE_BASE <P0-T2 HEAD>; git status --porcelain; git diff --name-only <P0-T2 HEAD> -- <frozen paths>; grep -rn -F "function unionStrings" extensions/drm-copilot/src; grep -c -F './claude-blast-radius-overlay"' on the demote module)
EXIT_CODE: 0
Output Summary: Only FEATURE/ paths were added to the listing; no frozen path changed since P0-T2; exactly one `function unionStrings` definition (in claude-blast-radius-overlay-demote.ts); zero matches for the import specifier. The script's own exit status is 1 only because the last `grep -c` found zero matches, which is the expected result.

## Values

- MERGE_BASE: `1898400756e909b88cde5f51a05f0b11d423d3b0`
- HEAD: `3c94c93c96b6d8d5560db077ee411362c3f1b115`
- P0-T2 HEAD (reference): `4fdb1848ab48cb161d46725c3115892fb1067000`
- Tracked listing against MERGE_BASE: 95 paths now, 86 at P0-T2.

## Paths added to the tracked listing since P0-T2 (all under FEATURE/)

- `evidence/other/preflight-fixes.2026-10-31T09-10.md`
- `evidence/regression-testing/pester-keypartition.2026-10-31T09-16.md`
- `evidence/regression-testing/ts-union-helper.2026-10-31T09-15.md`
- `evidence/remediation-baseline/branch-state.2026-10-31T09-11.md`
- `evidence/remediation-baseline/line-counts.2026-10-31T09-11.md`
- `evidence/remediation-baseline/pester-keypartition.2026-10-31T09-13.md`
- `evidence/remediation-baseline/phase0-instructions-read.2026-10-31T09-11.md`
- `evidence/remediation-baseline/ts-coverage.2026-10-31T09-12.md`
- `remediation-plan.2026-10-31T08-57.md`

The three CYCLE_FILES were already in the P0-T2 listing.

## Porcelain (all under FEATURE/)

One modified plan file and eleven untracked Phase 3 evidence files under `FEATURE/evidence/qa-gates/` and `FEATURE/evidence/regression-testing/`. No path outside FEATURE/.

## Frozen paths: no change since P0-T2

`git diff --name-only <P0-T2 HEAD>` over the following returned an empty list:

- `.claude/skills/parallel-plan/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
- every Python file (`*.py`)
- `extensions/drm-copilot/jest.config.cjs`
- the three TS_TESTS files
- the six execution-environment brief copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the bundle copies under `extensions/drm-copilot/resources/claude-customizations/`, `codex-and-agents-customizations/`, and `customizations/`

## Structure

- `function unionStrings` in `extensions/drm-copilot/src`: exactly 1 match, `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` (`export function unionStrings<T>(`).
- Import specifier `./claude-blast-radius-overlay"` in `claude-blast-radius-overlay-demote.ts`: 0 matches. The one-way import direction is kept and no cycle exists.
