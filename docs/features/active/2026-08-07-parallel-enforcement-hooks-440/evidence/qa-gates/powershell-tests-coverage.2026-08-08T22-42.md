# QA Gate — PowerShell Tests and Coverage (PoshQC / Pester) — Issue #440

Timestamp: 2026-08-08T22-42

Task: [P5-T3]

Branch: `feature/parallel-enforcement-hooks-440`

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`

EXIT_CODE: 1

## Raw Result

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Command exited with code 1."
}
```

## Numeric Test Totals

Read from `artifacts/pester/pester-junit.xml` (`testsuites` root attributes) produced by this run:

| Metric | Baseline (P0-T4) | This run (P5-T3) | Delta |
| --- | --- | --- | --- |
| tests | 2031 | **2141** | +110 |
| failures | 1 | **1** | 0 |
| errors | 0 | **0** | 0 |
| skipped | (attribute empty) | (attribute empty) | — |
| time (s) | 112.637 | 99.938 | -12.699 |

Passing tests: **2140 of 2141**.

### Test-Count Delta Attribution (+110 accounted for exactly)

| Suite | tests | failures |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` (new, P1-T2) | 56 | 0 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` (new, P1-T4) | 40 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (appended contexts, P2-T2) | 27 | 0 |

56 + 40 = 96 tests from the two new suites, plus 14 appended `Context` cases in the invocation-origin suite (27 total, 13 pre-existing), equals exactly +110. Every test added by this feature passes; all three of this feature's suites report 0 failures and 0 errors.

## Numeric Coverage Headline

Read from `artifacts/pester/powershell-coverage.xml` (JaCoCo-format top-level `counter` elements) produced by this run:

| Counter type | covered | missed | total | percentage | baseline percentage |
| --- | --- | --- | --- | --- | --- |
| LINE | 3148 | 189 | 3337 | **94.34%** | 94.34% |
| INSTRUCTION (commands) | 4316 | 278 | 4594 | **93.95%** | 93.95% |
| METHOD | 240 | 26 | 266 | 90.23% | 90.23% |
| CLASS | 39 | 2 | 41 | 95.12% | 95.12% |

LINE/COMMAND coverage headline (post-change): **94.34% line / 93.95% command** — byte-identical to the P0-T4 baseline, therefore zero regression.

BRANCH: not emitted by PoshQC/Pester coverage output

The emitted coverage document contains exactly four top-level `counter` elements — `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS`. No `BRANCH` counter exists, so no branch figure can be read for PowerShell. Line/command coverage is the authoritative PowerShell numeric and this explicit absence note is the required substitute, not a placeholder for an available metric (plan Binding Constraint 7).

### Coverage-Denominator Note (why these figures are unchanged)

The identical totals are expected and are not evidence that the new hooks are unmeasured. `mcp__drm-copilot__run_poshqc_test` executes the **installed extension bundle's** `resources/templates/run-poshqc-test.ps1`, which imports the installed bundle's `PoshQC` module and that module's module-root-relative `settings/pester.runsettings.psd1`. P2-T4's `CodeCoverage.Path` additions were made to the two **in-repo** copies, so they take effect only for runs made from a republished bundle. This run's coverage denominator therefore excludes the three files this feature creates or modifies, which is exactly why plan task [P5-T8] obtains the per-file numbers from a dedicated repo-local `Invoke-Pester` run instead of from this artifact (precedent: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/phase6-ps-test.2026-07-09T09-59.md`).

## Failure Attribution — One Pre-Existing, Out-of-Scope Failure

- **Test file:** `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (suite total 46 tests, 1 failure)
- **Test case:** `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- **Assertion output:**
  ```
  Expected strings to be the same, but they were different.
  Expected length: 5
  Actual length:   4
  Strings differ at index 0.
  Expected: 'allow'
  But was:  'deny'
  ```
- **Classification:** PRE-EXISTING, out of scope. This is byte-for-byte the same test and the same assertion message recorded in the P0-T4 baseline artifact (`evidence/baseline/powershell-tests-coverage.2026-08-08T20-57.md`), taken before any file in this feature was written.
- **Cause:** the test reads the real, gitignored `artifacts/orchestration/orchestrator-state.json` instead of injecting checkpoint content through a mocked read seam. The live checkpoint was verified parseable JSON at the time of this run (`Get-Content -Raw artifacts/orchestration/orchestrator-state.json | ConvertFrom-Json` succeeded), but its momentary contents do not satisfy the PR-author gate while an orchestrated run is in flight, so the hook returns `deny` where the test asserts `allow`.
- **Non-attribution proof:** the subject under test is `.claude/hooks/enforce-pr-author-skill.ps1`, which this feature does not touch; the failing suite references none of this feature's changed files; the test-count delta (+110) is fully accounted for by this feature's own passing tests; and all three of this feature's suites report 0 failures.
- **Disposition:** recorded, not fixed. Neither the test file nor the live checkpoint is edited by this feature, per the execution directive.

### Environment-Sensitive Suites Named in the Directive — Both Passed

The two suites that failed during the Phase 2 run because the live checkpoint was momentarily invalid JSON both pass in this run, confirming the orchestrator-side defect has been repaired:

| Suite | tests | failures |
| --- | --- | --- |
| `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` | 12 | 0 |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | 6 | 0 |

## Restart Decision

The `EXIT_CODE: 1` is driven entirely by the single pre-existing, out-of-scope failure above. No failure is attributable to this feature, so the toolchain loop is not restarted from [P5-T1]; there is no defect in this feature's scope to fix.

Output Summary: 2141 tests executed, 2140 passed, 1 failed, 0 errors, 99.938 s. EXIT_CODE 1 driven entirely by the single pre-existing, out-of-scope failure `enforce-pr-author-skill.Tests.ps1` -> `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, which reads the live gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam; identical test and identical assertion message to the P0-T4 baseline. Post-change coverage headline: **94.34% line / 93.95% command** (LINE covered 3148 / missed 189 of 3337; INSTRUCTION covered 4316 / missed 278 of 4594) — identical to baseline, zero regression. BRANCH: not emitted by PoshQC/Pester coverage output. Test-count delta +110 is exactly this feature's added tests (56 + 40 new, 14 appended contexts), all passing with 0 failures across all three of this feature's suites. The two directive-named codex suites that failed in Phase 2 now pass (12/12 and 6/6). Because this run executes the installed bundle's runsettings, the coverage denominator excludes the three files this feature touches; their per-file numbers come from [P5-T8]'s dedicated repo-local Pester run.
