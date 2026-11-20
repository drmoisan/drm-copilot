# Fresh Single-Process Pester Run Over tests/scripts ([P6-T6])

Timestamp: 2026-11-03T20-06
Command: sh SCRATCH/issue-1020-test.sh tests/scripts issue-1020-p6t6.log (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts'; coverage on); counts from the `testsuites` header of artifacts/pester/pester-junit.xml and the Pester console summary; failing names from a second single-process run of the same tree (SCRATCH/issue-1020-subset.ps1, Run.Path tests/scripts, PassThru, no coverage); coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1020-cov.ps1
EXIT_CODE: 255
Output Summary: tests=14106 passed=13687 failed=409 errors=6 skipped=10 on the current host (Linux Codespace). No test under tests/scripts/claude-lib/docs/ failed (0 of 383). Pester then threw while writing JUnit (`Export-XmlReport`: character 0x1B in a failure message), so artifacts/pester/pester-junit.xml holds only its header and 44 test cases; the run exit code 255 comes from that throw. Overall line coverage 92.65% (21911 covered, 1739 missed). The literal acceptance (0 errors; every failing name also failing in [P0-T6]) is NOT met: [P0-T6] was recorded on a different host and lists no failures. Against a same-host merge-base reference (`evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`), every one of the 194 unique failing names also fails on the unchanged merge-base tree on this host. Task left unchecked; the CI-shape proof is `poshqc / PowerShell QC` on windows-latest ([P6-T12]).

## Counts

| Source | tests | passed | failed | errors | skipped |
|---|---|---|---|---|---|
| Invoke-PoshQCTest console summary and JUnit header | 14106 | 13687 | 409 | 6 | 10 |
| Re-run without coverage (SCRATCH/issue-1020-subset.ps1) | 14106 | 13687 | 409 | (BeforeAll failures counted in failed) | 10 |
| Suites under tests/scripts/claude-lib/docs/ | 383 | 383 | 0 | 0 | 0 |

The six `errors` are `BeforeAll` failures (`CommandNotFoundException` for `pwsh`) in: `Codex routing PowerShell wrappers match the Python CLI corpus (issue #697)`, `Bundled Codex PreToolUse hooks run from the bundle location (issue #697)`, `Every registered Codex PreToolUse handler accepts every tool name its matcher admits`, `Codex PreToolUse hooks honour the native stdin transport contract`, `Codex epic preparation, wave, merge, and worktree gates`, `Legacy Codex hooks use native lifecycle contracts`.

## Failing names compared with the baselines

- Compared with [P0-T6] (`evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md`, failing tests: none): all 194 unique failing names are absent from that baseline, because it was recorded on another host.
- Compared with the same-host merge-base run (186 unique failing names) plus the same-host order probe: 194 of 194 branch failing names are present; 0 are new. The 8 names absent from the merge-base full run are the 160 `Resolve-CodexRouting.Parity.Tests.ps1` cases, which the merge-base tree also fails when `tests/scripts/dev-tools` runs before `tests/scripts/codex-scripts`, as in this worktree's directory order.
- Failing files are under `tests/scripts/dev-tools`, `tests/scripts/codex-hooks`, `tests/scripts/codex-scripts`, `tests/scripts/claude-hooks`, and `tests/scripts/powershell/PoshQC`; none is under `tests/scripts/claude-lib/docs/`, and no failing file is in this branch's change set.

## Coverage

- Overall line coverage: 92.65% (21911 covered, 1739 missed).
- `.claude/lib/docs/` files contribute 929 covered and 23 missed lines (per-file figures equal [P6-T3]).
- Excluding the docs files: 20982 covered and 1716 missed lines, compared with 21250 and 1448 at [P0-T6]. The 268-line difference falls in pre-existing scripts whose tests fail on this host; it is not attributable to this change.

CI: `poshqc / PowerShell QC` (windows-latest).
