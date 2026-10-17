# TypeScript Filter, Entry Point, and Parity Tests — Issue #621

Task: [P6-T7]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

Timestamp: 2026-09-30T00-37
Command: npx jest test/lib/push-down (working directory `extensions/drm-copilot`)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 27 passed, 27 total`; `Tests:       415 passed, 415 total`. No `failed`.
- Comparison base: the first [P0-T16] command (`npx jest test/lib/push-down`) passed 329. Delta: 415 - 329 = 86, which meets the required lower bound of 86 (27 manifest cases, 14 filter cases, 45 parity cases).
- Per-suite counts from targeted runs in this phase: `claude-exclusion-manifest.test.ts` 27 passed; `claude-exclusion-filter.test.ts` 14 passed; `claude-exclusion-parity.test.ts` 45 passed (4 non-corpus cases plus 18 + 14 + 9 corpus cases).
- The 24 pre-existing suites still pass, including `claude-customizations.test.ts`, `claude-config-carriage.test.ts`, and `claude-gitignore-delivery.test.ts`, which exercise the modified entry point without a manifest.
- Phase 6 acceptance probes: `^export function stringifySorted` count `1` and `git diff origin/epic/push-down-payload-correctness-integration --numstat` on the engine printed `1	1`; `^export class ExclusionFilterFileSystem` count `1`, the `EXCLUSION_CONFLICT_LINE_PREFIX` literal count `1`, filter module 337 lines; `export interface ClaudePushDownSummary extends PushDownSummary` count `1`, `new ExclusionFilterFileSystem(` count `1`, `claude-customizations.ts` 496 lines; `^  it(` count in the filter test `14`, 391 lines; corpus-path literal count in the parity test `1`, 193 lines; the three jest.config.cjs path counts `1` each and `global:` count `0` (exit 1).
- Toolchain on the Phase 6 files before this run: Prettier `--check` clean, `npx eslint` no findings, `npx tsc -p ./ --noEmit` no `error TS` line.

Execution note: the plan delegates [P6-T2] to [P6-T5] to `typescript-engineer` through `atomic-executor`. No subagent-delegation tool was available in this execution session, so `atomic-executor` performed the edits directly with the Edit/Write tools. `claude-customizations.ts` first measured 505 lines after the edit; comments added by this task were shortened to bring it to 496 before the acceptance probe.

AC status: with [P4-T7] (Python half) and this run (TypeScript half) passed, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-13, AC-14, AC-15, AC-17, AC-18, AC-22, and AC-23 are checked off in `spec.md`, and US-3, US-4, US-5, US-6, US-9, US-10, US-13, US-14, US-15, US-16, US-17, and US-20 in `user-story.md` (plan rule 12).
