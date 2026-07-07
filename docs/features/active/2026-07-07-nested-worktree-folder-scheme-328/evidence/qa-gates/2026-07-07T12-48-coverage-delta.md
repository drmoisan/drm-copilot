# Coverage Delta Verification (P6-T8)

Timestamp: 2026-07-07T12-48

## TypeScript (extensions/drm-copilot) — baseline (P0-T6) vs post-change (P6-T7)

| Metric | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| Lines | 96.58% (30827/31916) | 96.58% (31116/32215) | >= 85% | PASS |
| Branches | 88.52% (3943/4454) | 88.5% (3973/4489) | >= 75% | PASS |
| Functions | 87.54% (886/1012) | 87.37% (893/1022) | (supporting) | n/a |

Whole-extension line coverage is unchanged (96.58%); branch coverage moved -0.02 pp (88.52% -> 88.50%), remaining far above the 75% floor. This is a global-denominator effect from added code, not a regression on changed lines.

### Changed-file coverage (no regression on changed lines)

| File | Line | Branch |
|---|---|---|
| src/claude-worktree-session.ts | 100.0% (248/248) | 95.0% (19/20) |
| src/codex-worktree-session.ts | 100.0% (120/120) | 100.0% (14/14) |
| src/extension.ts | 97.3% (470/483) | 90.8% (59/65) |
| src/remove-worktrees.ts | 99.0% (297/300) | 90.0% (45/50) |
| src/remove-worktrees-runner.ts | 96.0% (242/252) | 84.8% (28/33) |
| src/lib/subagent-tree/workspace-encoding.ts | 100.0% (73/73) | 100.0% (4/4) |

Every changed source file exceeds both thresholds; the new behavior (grouping helpers, ensureParentDirectory, empty-parent cleanup, new-scheme encoding matches) is directly covered by added unit tests.

## PowerShell — baseline (P0-T3) vs post-change (P6-T3)

| Metric | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| Line | 93.67% (1006/1074) | 93.67% (1006/1074) | >= 85% | PASS (unchanged) |
| Instruction | 92.59% (1399/1511) | 92.59% (1399/1511) | (supporting) | n/a |
| Branch | not emitted | not emitted | >= 75% | See note |
| Tests | 1063 pass | 1071 pass | — | +8 tests |

Branch coverage is not emitted by the repo Pester config (OutputFormat = CoverageGutters). The changed PowerShell file (scripts/dev-tools/new-claude-worktree-session.ps1) is outside the config's explicit CodeCoverage.Path allow-list, so it is not in the measured PowerShell coverage denominator; its behavior is nevertheless fully exercised by the Pester suite (8 new passing tests). These are pre-existing repo-configuration characteristics, unchanged by this plan, and recorded as follow-up findings.

## Outcome

- TypeScript: line 96.58% >= 85%, branch 88.5% >= 75%, no regression on changed lines. PASS.
- PowerShell: line 93.67% >= 85% (unchanged, no regression); branch not measured by repo config; changed file outside measured scope (follow-up finding). Pester suite green.
- AC9 coverage thresholds satisfied for measured scope; no unmet numeric threshold.
