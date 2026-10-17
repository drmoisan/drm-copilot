# PR #926 CI evidence for AC-48 (P13-T3 pending-CI closeout)

Timestamp: 2026-10-13T16-28
Command: (orchestrator-run, recorded here because the executor has no gh access) `gh run view 38428074609 --json databaseId,headSha,event,conclusion,url,jobs`; `gh run view 38428074609 --log --job 115402651172`; `gh run download 38428074609 -n poshqc-test-results`; `gh run download 38428074609 -n poshqc-linux-hook-test-results` (all saved to `artifacts/scratch-903/ci-pr926-903/`). (executor-run) `poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ci_jobs_903.py <CIDIR>/run-pr926-903.json`; `poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_rows_903.py <CIDIR>/pester-junit.xml <CIDIR>/pester-junit-linux-hooks.xml`; `poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_rows_rem1_903.py <CIDIR>/pester-junit.xml <CIDIR>/pester-junit-linux-hooks.xml`; `poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_cov_extract_903.py <CIDIR>/powershell-coverage.xml files`; `git -C <worktree> diff -U0 origin/main...HEAD -- <the ten production files> > <worktree>/artifacts/scratch-903/ps-changed-lines-diff-pr926-903.txt`; `cmp` of that file against `ps-changed-lines-diff-rem1-903.txt`; `poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_changed_lines_903.py <worktree>/artifacts/scratch-903/ps-changed-lines-diff-pr926-903.txt <CIDIR>/powershell-coverage.xml`; Grep tool over `<CIDIR>/poshqc-job-pr926-903.log`; `git -C <worktree> diff --name-only 41d406d20de2ae850b60ee2b81e47276c1f0d4ff 341ff760ffe10a032ba3f8b465cbe9f3e5fe9f06`
EXIT_CODE: 0
Output Summary:
- Run https://github.com/drmoisan/drm-copilot/actions/runs/38428074609, event `pull_request`, headSha `341ff760ffe10a032ba3f8b465cbe9f3e5fe9f06` (equals the PR head and the local HEAD), conclusion `success`; 17 of 17 ci.yml jobs `success` (the orchestrator reports 20 PR checks SUCCESS in total).
- PowerShell QC: `Format PowerShell`, `Analyze PowerShell`, `Test PowerShell` all `success`; `PSScriptAnalyzer passed: no findings`; `Tests Passed: 10298, Failed: 0, Skipped: 10`; `Covered 89.59% / 0%.`
- JUnit: Windows 10308 testcases (0 failed, 10 skipped overall); Linux 6221 testcases (0 failed, 0 skipped). Every named row of P12-T23 and remediation P5-T3 prints `pass`.
- Per-file line coverage: all ten production files at or above 85% (lowest 89.09%). Changed lines 149/154 covered; the 5 uncovered lines are the same exempt lines recorded in `ps-coverage.2026-10-13T15-55.md`.
- AC-48: every condition satisfied (see Acceptance below).

`<CIDIR>` = `artifacts/scratch-903/ci-pr926-903/`. `<worktree>` = the item worktree for branch `bug/round-2-review-nits-and-evidence-timestamps-903`.

## Run identity

- URL: https://github.com/drmoisan/drm-copilot/actions/runs/38428074609
- databaseId: 38428074609
- event: pull_request (PR #926, https://github.com/drmoisan/drm-copilot/pull/926)
- headSha: 341ff760ffe10a032ba3f8b465cbe9f3e5fe9f06
- conclusion: success

Production-code identity: `git diff --name-only 41d406d2 341ff760` (remediation-cycle-1 CI head to PR head) lists only paths under `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/`, so no production or test file changed after the remediation CI run; the changed-line diff file is byte-identical to `ps-changed-lines-diff-rem1-903.txt` (`cmp` equal).

## Jobs

| Job | Conclusion | Job id |
|---|---|---|
| docs-validation / Documentation Validation | success | 115402650648 |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success | 115402650993 |
| quality-checks7 / Code Quality & Tests (3.11) | success | 115402651065 |
| quality-checks7 / Code Quality & Tests (3.12) | success | 115402651106 |
| poshqc / PowerShell QC | success | 115402651172 |
| security-scan / Security Scanning | success | 115402651230 |
| shell-coverage / Shell Coverage (Bats + kcov) | success | 115402651234 |
| build-check / Build Package | success | 115402651239 |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success | 115402651268 |
| quality-checks7 / Code Quality & Tests (3.10) | success | 115402651272 |
| NPM Audit Gate / npm audit (.) | success | 115402651328 |
| NPM Audit Gate / npm audit (packages/mcp-server) | success | 115402651417 |
| quality-checks7 / Code Quality & Tests (3.13) | success | 115402651454 |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success | 115402651557 |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success | 115402651618 |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success | 115402651717 |
| poshqc / PowerShell hook suites (Linux) | success | 115402652156 |

### PowerShell job steps

| Job | Step | Conclusion |
|---|---|---|
| poshqc / PowerShell QC | 4 Format PowerShell | success |
| poshqc / PowerShell QC | 5 Analyze PowerShell | success |
| poshqc / PowerShell QC | 6 Test PowerShell | success |
| poshqc / PowerShell QC | 7 Upload PowerShell test artifacts | success |
| poshqc / PowerShell hook suites (Linux) | 4 Test PowerShell hook suites | success |
| poshqc / PowerShell hook suites (Linux) | 5 Upload PowerShell hook-suite test results | success |

## Quoted log lines (`poshqc-job-pr926-903.log`)

```
1009: PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot
1572: Tests Passed: 10298, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
1574: Covered 89.59% / 0%. 26,345 analyzed Commands in 202 Files.
```

`[+]` lines for the 15 Pester files edited on the branch plus the remediation Decision suite (log line: path, truncated in the log as shown):

```
1032: tests\scripts\claude-hooks\enforce-completion-consistency.Payload.T
1054: tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.
1063: tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.
1065: tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.
1075: tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.T
1077: tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.
1078: tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.
1129: tests\scripts\claude-hooks\feature-folder-resolution.T
1203: tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.T
1208: tests\scripts\claude-lib\codex-routing\CodexDeployment.GeneratedFamilies.Parity.T
1288: tests\scripts\codex-hooks\codex-epic-runtime-contracts.T
1295: tests\scripts\codex-hooks\codex-pretooluse-integration.T
1317: tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Decision.T
1319: tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.T
1332: tests\scripts\codex-hooks\feature-folder-resolution.T
1569: tests\scripts\workflows\PublishMcpNpmWorkflow.T
```

## Per-row Pester results (JUnit artifacts)

```
windows testcases=10308 failed=0 skipped=10
linux testcases=6221 failed=0 skipped=0
```

`m/f/s` = matching testcases / with `failure` child / with `skipped` child.

| Row | Source | Windows m/f/s | Linux m/f/s | Result |
|---|---|---|---|---|
| M8fe (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8fp (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8 (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8h (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8m (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| resolves the target by issue_num when no feature-folder basename matches | both | 1/0/0 | 1/0/0 | pass |
| S06 (all chars, both resolver suites) | both | 18/0/0 | 18/0/0 | pass |
| S06c (both resolver suites) | both | 4/0/0 | 4/0/0 | pass |
| H01 (both resolver suites) | both | 2/0/0 | 2/0/0 | pass |
| O-4 rows | both | 3/0/0 | 3/0/0 | pass |
| U11 (both surfaces) | both | 10/0/0 | 10/0/0 | pass |
| U11b (both surfaces) | both | 4/0/0 | 4/0/0 | pass |
| U11c (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U11d (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U24 (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U25 (both surfaces) | both | 10/0/0 | 10/0/0 | pass |
| U26 (both surfaces) | both | 4/0/0 | 4/0/0 | pass |
| 120-character parity row | both | 1/0/0 | 1/0/0 | pass |
| CR-9 contract row | both | 1/0/0 | 1/0/0 | pass |
| Predicate AC-8 rows | both | 2/0/0 | 2/0/0 | pass |
| kelvin-sign-extension | pester-junit.xml | 1/0/0 | n/a | pass |
| dotted-capital-i-extension | pester-junit.xml | 1/0/0 | n/a | pass |
| DEV-2 row | both | 1/0/0 | 1/0/0 | pass |
| AC-19 rows (CodexDeployment parity) | pester-junit.xml | 9/0/0 | n/a | pass |
| PublishMcpNpm: asserts tag and manifest version equality ... | pester-junit.xml | 1/0/0 | n/a | pass |
| PublishMcpNpm: polls the exact published version ... | pester-junit.xml | 1/0/0 | n/a | pass |
| PublishMcpNpm: keeps the exit-code reset ... | pester-junit.xml | 1/0/0 | n/a | pass |
| PublishMcpNpm: runs the registry poll step only after ... | pester-junit.xml | 1/0/0 | n/a | pass |
| Epic-scope Decision suite (every row) | both | 3/0/0 | 3/0/0 | pass |
| ES-D1 | both | 1/0/0 | 1/0/0 | pass |
| ES-D2 | both | 1/0/0 | 1/0/0 | pass |
| Discovery suite (every row) | both | 334/0/0 | 334/0/0 | pass |
| enforcement-hooks-no-python-invocation (every row) | pester-junit.xml | 32/0/0 | n/a | pass |
| hook-dependency-guard-completeness (every row) | pester-junit.xml | 598/0/0 | n/a | pass |
| BlastRadius.HistoricalRuns (every row) | pester-junit.xml | 9/0/0 | n/a | pass |
| claude-hooks preimplementation-gate suites | both | 807/0/0 | 807/0/0 | pass |
| codex-hooks preimplementation-gate suites | both | 363/0/0 | 363/0/0 | pass |

The five F-1 rows and the F-2 row remain `EXCLUDED-BY-DECISION` per `f1-f2-decision.2026-10-13T13-44.md` (unchanged from `ps-rows.2026-10-13T14-25.md`).

## Per-file PowerShell line coverage (`powershell-coverage.xml`)

| File | Covered | Missed | Percent | At least 85% |
|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 33 | 0 | 100.0 | yes |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 135 | 2 | 98.54 | yes |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 90.37 | yes |
| .claude/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 | yes |
| .codex/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 | yes |
| .claude/hooks/enforce-completion-consistency.ps1 | 140 | 9 | 93.96 | yes |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 | yes |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 | yes |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 67 | 1 | 98.53 | yes |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | 6 | 89.09 | yes |

Values are identical to the remediation-cycle-1 run recorded in `ps-coverage.2026-10-13T15-55.md`.

## Changed-line coverage

Merge-base `fd81a43b45de65078236da6c1cbfd077c3eb010c`. 154 executable added lines; 149 with `ci` > 0 (96.75%). Uncovered lines (all exempt under the P12-T24 rules as recorded in `ps-coverage.2026-10-13T15-55.md`):

| File:line | `ci` | Exemption |
|---|---|---|
| .claude/hooks/enforce-completion-consistency.ps1:484 | 0 | (a) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | 0 | (c) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | 0 | (c) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 | 0 | (d), `rem1-ri2-exemption.2026-10-13T15-54.md` |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 | 0 | (d), `rem1-ri2-exemption.2026-10-13T15-54.md` |

## Acceptance (AC-48)

- PoshQC MCP tools only, no sh/bash/pwsh wrapper: the local format, analyze, and test steps were run through `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` (`ps-format.2026-10-13T13-49.md`, `ps-analyze.2026-10-13T13-50.md`, `ps-test.2026-10-13T14-00.md`; remediation reruns `rem1-ps-format.2026-10-13T15-24.md`, `rem1-ps-analyze.2026-10-13T15-24.md`, `rem1-ps-test.2026-10-13T15-32.md`), each EXIT_CODE 0 with disposition `ok:true`; none of their Command lines invokes sh, bash, or pwsh. PASS.
- Per-test results from the PR CI Pester artifacts: recorded above; every named row passes on each required surface; 0 failures overall. PASS.
- Per-file line coverage at least 85% for changed production PowerShell files from the PR CI artifact: all ten files at or above 85%. PASS.

AC-48: PASS
