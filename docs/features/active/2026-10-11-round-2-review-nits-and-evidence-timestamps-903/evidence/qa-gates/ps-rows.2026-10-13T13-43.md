# Per-row Pester results (P12-T23) — iteration 1

Timestamp: 2026-10-13T13-43
Command: gh run download 38404520141 -n poshqc-test-results -D artifacts/scratch-903/ci-final-903; gh run download 38404520141 -n poshqc-linux-hook-test-results -D artifacts/scratch-903/ci-final-903; gh run view 38404520141 --log-failed; then a `python -I -c` testcase-name scan of `artifacts/scratch-903/ci-final-903/pester-junit-linux-hooks.xml` and a `[-]`-line scan of `artifacts/scratch-903/ci-final-log-failed-903.txt`
EXIT_CODE: 1
Output Summary: WINDOWS-ARTIFACT-ABSENT. `gh run download ... -n poshqc-test-results` returned `no artifact matches any of the names or patterns provided` (the Windows `Test PowerShell` step failed, so `Upload PowerShell test artifacts` was skipped). Linux JUnit: 6211 testcases, 7 failed, 0 skipped; the 7 failures are the Discovery-suite rows. Every other named row passed. Acceptance: FAIL (WINDOWS-ARTIFACT-ABSENT branch, plus seven failing Discovery rows); Phase 12 restarts at P12-T1 after the P12-T27 withhold.

Execution note: the `gh` commands were run by the orchestrator; the executor read the downloaded and saved outputs.

## Source selection (WINDOWS-ARTIFACT-ABSENT branch)

- claude-hooks and codex-hooks rows: `pester-junit-linux-hooks.xml` only.
- Remaining rows: `[-]` lines of `gh run view 38404520141 --log-failed` (14 `[-]` lines in total: the seven Discovery rows, once per job).

## claude-hooks / codex-hooks rows (pester-junit-linux-hooks.xml)

A row is counted by testcase-name substring match. `Failed` and `Skipped` are counts of matching testcases with a `failure` or `skipped` child.

| Row | Matching testcases | Failed | Skipped | Result |
|---|---|---|---|---|
| M8fe (both TargetFolder suites) | 2 | 0 | 0 | pass |
| M8fp (both TargetFolder suites) | 2 | 0 | 0 | pass |
| M8 (both TargetFolder suites; `M8:` title) | 2 | 0 | 0 | pass |
| M8h (both TargetFolder suites) | 2 | 0 | 0 | pass |
| M8m (both TargetFolder suites) | 2 | 0 | 0 | pass |
| `resolves the target by issue_num when no feature-folder basename matches` | 1 | 0 | 0 | pass |
| S06 (all chars; 9 characters x 2 resolver suites) | 18 | 0 | 0 | pass |
| S06c (both resolver suites) | 4 | 0 | 0 | pass |
| H01 (both resolver suites) | 2 | 0 | 0 | pass |
| O-4 rows | 4 | 0 | 0 | pass |
| U11 (both surfaces) | 10 | 0 | 0 | pass |
| U11b | 4 | 0 | 0 | pass |
| U11c | 2 | 0 | 0 | pass |
| U11d | 2 | 0 | 0 | pass |
| U24 | 2 | 0 | 0 | pass |
| U25 | 10 | 0 | 0 | pass |
| 120-character parity row | 2 | 0 | 0 | pass |
| CR-9 contract row (`one-paragraph multi-message`) | 1 | 0 | 0 | pass |
| F-1 rows | 6 | 0 | 0 | pass |
| F-2 row | 1 | 0 | 0 | pass |
| DEV-2 row | 1 | 0 | 0 | pass |
| Predicate AC-8 rows | 6 | 0 | 0 | pass |
| `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (`discovery guard` rows) | 325 | 7 | 0 | FAIL |
| Preimplementation-gate suites (testcase names containing `preimplementation`) | 1269 | 0 | 0 | pass |

Failing Discovery rows (each message: `<suite>: seam <SeamName>: no dot-source loads the hook; ...`):

1. `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`
2. `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`
3. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
4. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
5. `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`
6. `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
7. `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`

## Remaining rows (log-failed `[-]` lines)

| Row token | `[-]` lines matching |
|---|---|
| `kelvin-sign-extension` | 0 |
| `dotted-capital-i-extension` | 0 |
| `AC-19` (CodexDeployment parity suite) | 0 |
| `asserts tag and manifest version equality ...` | 0 |
| `polls the exact published version ...` | 0 |
| `keeps the exit-code reset ...` | 0 |
| `runs the registry poll step ...` | 0 |
| `BlastRadius.HistoricalRuns` | 0 |
| `enforcement-hooks-no-python-invocation` | 0 |
| `hook-dependency-guard-completeness` | 0 |
| `preimplementation` | 0 |

Limitation: a `[-]`-line scan shows absence of failure, not presence of a testcase; the zero-match rule of this task cannot be applied to these rows without `pester-junit.xml`.

## Decisions consumed by P12-T26 and P12-T27

- No preimplementation-gate row failed on either surface (Linux JUnit: 1269 rows, 0 failed; Windows log: no `[-]` line other than the seven Discovery rows) -> P12-T26 `Decision: CR-3 retained`.
- The Discovery suite reported findings for seven suites -> P12-T27 withhold.

Acceptance: FAIL. Phase 12 restarts at P12-T1 after the P12-T27 withhold.
