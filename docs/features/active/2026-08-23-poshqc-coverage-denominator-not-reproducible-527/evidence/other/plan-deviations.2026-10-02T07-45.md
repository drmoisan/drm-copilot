# Plan Deviations Register

Timestamp: 2026-10-02T07-45
Command: git diff --stat 43e403a1 HEAD -- <plan-cited files>; git diff 43e403a1 HEAD -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1; git diff -U0 43e403a1 HEAD -- .claude/hooks/enforce-powershell-batch-budget.ps1; Read tool on .gitignore lines 1-10; plus the per-entry commands below
EXIT_CODE: 0
Output Summary: named deviations from plan.2026-09-29T15-32.md recorded per task under the operator decision of 2026-10-01 (Option A) and the classification in `evidence/other/pwsh-task-classification.2026-10-02T07-50.md`. Of the plan-cited files checked for drift since plan commit 43e403a1, two changed (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`); all others are unchanged. Later execution segments append entries to this file.

## DEV-MERGE — origin/main merged before execution

- Task: all (execution base).
- Plan mechanism: the plan was authored and preflighted against plan commit 43e403a1.
- Replacement: origin/main 71f8dcb4 was merged into the branch as 8f0483ec before execution; the orchestrator's classification commit 589b51a3 sits on top (BASE_SHA, `evidence/baseline/base-ref.2026-10-02T07-45.md`). Issues #623, #743, and #744 had merged on main before 71f8dcb4.
- Line-citation drift check (`git diff --stat 43e403a1 HEAD -- <file>`; empty output = unchanged):

| File | Plan citations | Result since 43e403a1 |
| --- | --- | --- |
| `.gitignore` | line 6 (`/artifacts`) | unchanged; Read tool confirms line 6 is `/artifacts` and line 7 is `.agent_logs` |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 211-214, 228-231, 290-292, 296-298, 308-312, 338-381, 394-398 | unchanged |
| `scripts/powershell/PoshQC/PoshQC.psm1` | lines 107-146 | unchanged |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 23-325 (`CodeCoverage.Path` array) | **changed** (+16 lines, 0 removed): the array now spans lines 23-341 (opening `Path = @(` at line 23, closing `)` at line 341); file is 350 lines. Added entries: `.claude/hooks/enforce-batch-budget-route.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `.codex/hooks/enforce-batch-budget-route.ps1`, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, and the three `.claude/lib/parallel-drift/` files, with their comments. D5 removes the whole array, so P3-T6 must remove lines 23-341 (not 23-325). Not edited in this segment. |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` | lines 60-140 | unchanged |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | lines 621-622, 745-746 | unchanged |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | line 14 | unchanged |
| `scripts/powershell/PoshQC/README.md` | lines 68, 80 | unchanged |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | lines 277-297 | **changed** (substantial rewrite of the decision function). Current lines: out-of-root candidates are discarded without consuming a slot at lines 286-291 (plan: 277-282); a new large-path route exempts all files at lines 293-296; test-file classification `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$` is at line 299 and test files never count (plan: 284); the deny of a production file once the counted set reaches `prodCap` is at lines 309-316 (plan: 293-297, "fourth distinct file of a kind"). Under the current hook only production files count; `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` (`.psm1`, so not matched by the `tests/.*\.ps1$` pattern) still counts as production and the two fixture `.ps1` files under `tests/` are test files. Not edited (outside the write set). |

## DEV-D10 — scratchpad `sh` fallback withdrawn

- Task: every task whose command or acceptance runs `pwsh`.
- Plan mechanism: D10, each rule body saved as a scratchpad `.ps1` and run with `pwsh -NoProfile -File`, with an `sh <scratchpad>/<name>.sh` wrapper where the Bash tool refuses `pwsh`.
- Replacement: none of these routes is used (operator decision 2026-10-01, Option A). Each affected task uses the replacement named in its own entry below.
- Evidence: `evidence/other/pwsh-task-classification.2026-10-02T07-50.md`.

## DEV-P0-T3 — rule LL

- Task: P0-T3.
- Plan mechanism: rule LL, `(Get-Content -LiteralPath $file).Count` in a `pwsh` child.
- Replacement: `git grep --untracked -c '' -- <six files>`.
- Evidence: `evidence/baseline/line-counts.2026-10-02T07-45.md`.

## DEV-P0-T4 — baseline full suite from CI

- Task: P0-T4.
- Plan mechanism: rule FR (args '.', 'baseline-run.log') then rule JX (args '.') locally.
- Replacement: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219 (push to main at 71f8dcb4, conclusion success); JUnit reduced with `poetry run python artifacts/ci/ci_evidence.py jx ...` (Python port of JX). The branch tree differs from 71f8dcb4 only under the feature folder.
- Evidence: `evidence/baseline/pwsh-full-suite.2026-10-02T07-45.md`.

## DEV-P0-T5 — baseline coverage from CI

- Task: P0-T5.
- Plan mechanism: rule CX (args '.', 'artifacts/pester/powershell-coverage.xml') on the P0-T4 local output.
- Replacement: the same CI run's powershell-coverage.xml reduced with `poetry run python artifacts/ci/ci_evidence.py cx ... <CI_ROOT>` (Python port of CX). Package-name shape observed from the CI XML (absolute forward-slash names under `<CI_ROOT>`), not from this machine.
- Evidence: `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md`.

## DEV-P0-T6 — non-writing format baseline from CI; HS replaced

- Task: P0-T6.
- Plan mechanism: `Invoke-PoshQCFormat` with a no-op `-WriteFile` over five files in a `pwsh` child; rule HS before and after.
- Replacement: the CI `Invoke-PoshQCFormat -Root <CI_ROOT>` step of the same run (607 `Already formatted:` lines and 0 `Formatted:` lines in the step; the five files each have an `Already formatted:` line); WOULD_FORMAT=0. Rule HS replaced by `git hash-object` on the five files compared with `git ls-tree 71f8dcb4`; no local formatter ran, so no file could change.
- Evidence: `evidence/baseline/pwsh-format.2026-10-02T07-45.md`.

## DEV-P0-T7 — analyzer baseline from CI

- Task: P0-T7.
- Plan mechanism: `Invoke-PoshQCAnalyze -GetFileList` over four files in a `pwsh` child.
- Replacement: the CI `Invoke-PoshQCAnalyze -Root <CI_ROOT>` step over the whole repository (superset of the four files), which printed `PSScriptAnalyzer passed: no findings under <CI_ROOT>`.
- Evidence: `evidence/baseline/pwsh-analyze.2026-10-02T07-45.md`.

## DEV-P0-T8 — targeted PoshQC baseline from CI JUnit

- Task: P0-T8.
- Plan mechanism: rule TR (args 'tests/scripts/powershell/PoshQC', '') locally.
- Replacement: the same CI run's JUnit filtered to `tests/scripts/powershell/PoshQC` with `poetry run python artifacts/ci/ci_evidence.py tr ...`; FAILED_CONTAINERS (not printed by the filter) derived from the ten `testsuite` elements, each with errors="0" and failures="0".
- Evidence: `evidence/baseline/pwsh-poshqc-targeted.2026-10-02T07-45.md`.
