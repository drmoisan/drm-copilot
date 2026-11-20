# Coverage Comparison — Remediation Cycle 1, P2-T7 (Issue 1162)

Timestamp: 2026-11-14T09-36
Command: comparison of the Phase 0 baseline artifacts under evidence/remediation-baseline/ (pester.2026-11-14T08-14.md, pytest.2026-11-14T08-18.md, jest.2026-11-14T08-19.md, jest-root.2026-11-14T08-19.md), the P1 phase gate (evidence/qa-gates/phase-gate.P1.2026-11-14T08-57.md), and the final gates (evidence/qa-gates/pester.2026-11-14T09-30.md, pytest.2026-11-14T09-34.md, jest.2026-11-14T09-35.md, jest-root.2026-11-14T09-35.md); line-level read of artifacts/pester/powershell-coverage.xml; git ls-files -s of the three module copies
EXIT_CODE: 0
Output Summary:
- Verdict: PASS. No new failing test. No per-file drop. Every threshold is met. The repository-wide figures are equal at reported precision; the four-decimal Pester difference below is attributable to the origin/main merge.

| Gate | Phase 0 baseline | Final | Result |
|---|---|---|---|
| Pester counts | 24321 tests, 0 failed | 25005 tests, 0 failed | no new failure |
| Pester repository line coverage | 40622/42328, 95.97% (95.9696) | 41422/43163, 95.97% (95.9665) | equal at 2 dp; see note |
| pytest counts | 16815 passed, 0 failed, 6 skipped | 16822 passed, 0 failed, 6 skipped | no new failure |
| pytest scripts.dev_tools | line 94.93% (17145/18060), branch 90.48% (5995/6626) | line 94.93% (17145/18060), branch 90.48% (5995/6626) | unchanged |
| Jest extension | 343 suites, 5624 tests, 0 failed; lines 97.19%, branches 94.00% | 343 suites, 5629 tests, 0 failed; lines 97.19%, branches 94.00% | unchanged |
| Jest worktree root | 346 suites, 5641 tests, 0 failed; lines 98.30%, branches 93.73% | 346 suites, 5646 tests, 0 failed; lines 98.30%, branches 93.73% | unchanged |

- `.claude/lib/epic-wave/EpicCrossDependency.psm1`: baseline 349/356 (98.03%); post-change 349/356 (98.03%); changed-line coverage 1/1 (100%). The changed line is the fetch statement in `Get-EpicCrossReadinessResult` with the argument array `fetch`, `-q`, `--prune`, `origin`, executed 4 times in the final run. At or above 85% and not below the baseline.
- `.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1` (not changed): 5/5 (100%) in both runs.
- No Python or TypeScript production file changed in this cycle.
- Pester repository-wide note: the P1 phase-gate run, which covers this cycle's changes before the origin/main merge, recorded 40622/42328, identical to the Phase 0 baseline. The final run adds 800 covered and 35 missed lines (95.81%), all brought in by the #1156 merge (new regeneration modules and hooks). That moves the four-decimal ratio from 95.9696% to 95.9665%. This cycle's own changes add no executable line, and its effect on repository coverage is zero. The autonomous decision record is evidence/other/autonomous-decisions.2026-11-14T09-36.md.
- Blob-id parity of the three module copies (`git ls-files -s`): `.claude/lib/epic-wave/EpicCrossDependency.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1`, and `extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1` all equal b7f1eb4d44c34c157e5fc8da1159358e97af4201.
- Every required value is present; none is missing.
