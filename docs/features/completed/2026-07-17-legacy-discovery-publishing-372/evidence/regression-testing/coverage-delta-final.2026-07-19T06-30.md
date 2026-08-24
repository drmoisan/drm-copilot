Timestamp: 2026-07-19T06-30

## Python (scripts/dev_tools push-down modules)

Baseline source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-push-down-suite-baseline.2026-07-19T05-20.md`
(P0-T14), re-derived to per-module precision by rerunning the identical P0-T14 command with
`coverage json` against `artifacts/.coverage` (a supplementary precision extraction; the P0-T14
task itself is unchanged and remains checked off with its own evidence artifact — no production
file was touched between that baseline run and this precision extraction, confirmed by
`git status --porcelain` showing zero changes under `scripts/dev_tools/`).

Final source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/python-test-final.2026-07-19T06-15.md`
(P8-T4).

| Module | Baseline line % | Final line % | Baseline branch % | Final branch % |
|---|---|---|---|---|
| push_down_claude_customizations.py | 90.5% | 90.5% | 75.0% | 75.0% |
| push_down_claude_filesystem.py | 89.5% | 89.5% | 84.6% | 84.6% |
| push_down_claude_pack_selection.py | 90.2% | 90.2% | 82.1% | 82.1% |
| push_down_codex_and_agents_customizations.py | 96.4% | 96.4% | 85.7% | 85.7% |
| push_down_codex_filesystem.py | 92.2% | 92.2% | 87.5% | 87.5% |
| push_down_codex_pack_selection.py | 97.9% | 97.9% | 95.2% | 95.2% |
| push_down_copilot_customizations.py | 92.6% | 92.6% | 77.8% | 77.8% |
| push_down_copilot_customizations_filesystem.py | 87.2% | 87.2% | 66.7% | 66.7% |
| push_down_copilot_customizations_rewrites.py | 97.0% | 97.0% | 90.0% | 90.0% |
| **`scripts/dev_tools` package-wide TOTAL** | line 5.3%, 145/4530 branches | line 5.3%, 145/4530 branches | (same) | (same) |

**Result: zero regression.** Every module's line and branch coverage is byte-for-byte identical
between baseline and final, because this feature made zero production-code changes (only two new
test files were added, which are excluded from the coverage measurement per policy). Eight of the
nine modules meet or exceed the uniform 85% line / 75% branch thresholds both before and after.
`push_down_copilot_customizations_filesystem.py`'s branch coverage (66.7%) is below the 75%
threshold at both baseline and final — a pre-existing condition this feature did not introduce,
did not touch, and did not regress.

## TypeScript (src/lib/push-down)

Baseline source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/typescript-push-down-suite-baseline.2026-07-19T05-30.md`
(P0-T18) — `EXIT_CODE: 1`, "No tests found." No numeric coverage was produced.

Final source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/typescript-test-final.2026-07-19T06-22.md`
(P8-T8) — `EXIT_CODE: 1`, "No tests found." No numeric coverage was produced.

**Result: UNVERIFIED.** Neither a baseline nor a final numeric TypeScript coverage value could be
produced, in either case for the identical reason: a pre-existing, out-of-plan-scope environment
defect (this worktree's path contains the dot-prefixed segment `.claude/worktrees/...`, which
breaks Jest's `testMatch` glob-pattern resolution on Windows; see the cited artifacts for full
root-cause reproduction). This is not a code-correctness regression signal for
`src/lib/push-down`: no TypeScript source or test file under `src/lib/push-down/` or
`test/lib/push-down/` was changed by this feature (confirmed by `npx prettier --check`, `npx
eslint`, and `npm run typecheck` all passing cleanly against the unchanged tree at both baseline
and final, per P0-T15–T17 and P8-T5–T7). However, the plan's numeric coverage-delta acceptance
criterion for the TypeScript side cannot be satisfied with real evidence from this worktree. This
is escalated in the executor's completion report per the Scope-change Rule; the coverage claim
should be re-verified from a worktree path that does not contain a dot-prefixed segment (for
example the main repository checkout), or after a fix to `extensions/drm-copilot/jest.config.cjs`'s
test-discovery strategy.
