# Per-row Pester results (P12-T23) — iteration 2

Timestamp: 2026-10-13T14-25
Command: gh run download 38410234897 -n poshqc-test-results -D artifacts/scratch-903/ci-final2-903; gh run download 38410234897 -n poshqc-linux-hook-test-results -D artifacts/scratch-903/ci-final2-903; poetry -C <worktree> run python -I artifacts/scratch-903/ps_rows_903.py artifacts/scratch-903/ci-final2-903/pester-junit.xml artifacts/scratch-903/ci-final2-903/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: Both artifacts present (not WINDOWS-ARTIFACT-ABSENT). `pester-junit.xml`: 10299 testcases, 0 with a `failure` child, 10 with a `skipped` child (none of them a named row). `pester-junit-linux-hooks.xml`: 6212 testcases, 0 failed, 0 skipped. Every required named row has at least one matching `testcase` in each required file and no `failure` or `skipped` child. The five F-1 rows and the F-2 row are EXCLUDED-BY-DECISION (`f1-f2-decision.2026-10-13T13-44.md`). The `U25` rows are required (CR-3 retained, `cr3-decision.2026-10-13T13-43.md`) and passed. Acceptance: PASS.

Path substitution: the plan names `artifacts/scratch-903/ci-final-903`; that directory holds the iteration 1 run (38404520141) files. This pass reads the iteration 2 run (38410234897) files from `artifacts/scratch-903/ci-final2-903`. The `gh` commands were run by the orchestrator; the executor ran the scan.

Method: each `testcase` is matched by the `classname` attribute (the test file path, separators normalized to `/`) containing the row's file token and the `name` attribute containing the row title token. A row whose matching testcases are all in a file under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks` is read from both files and must pass in each; other rows are read from `pester-junit.xml`. Columns `m/f/s` are matching / with `failure` (or `error`) child / with `skipped` child.

| Row | Source | Windows m/f/s | Linux m/f/s | Result |
|---|---|---|---|---|
| M8fe (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8fp (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8 (both TargetFolder suites; `M8:` title) | both | 2/0/0 | 2/0/0 | pass |
| M8h (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| M8m (both TargetFolder suites) | both | 2/0/0 | 2/0/0 | pass |
| `resolves the target by issue_num when no feature-folder basename matches` | both | 1/0/0 | 1/0/0 | pass |
| S06 (all 9 characters x 2 resolver suites) | both | 18/0/0 | 18/0/0 | pass |
| S06c (both resolver suites) | both | 4/0/0 | 4/0/0 | pass |
| H01 (both resolver suites) | both | 2/0/0 | 2/0/0 | pass |
| The three O-4 rows (`Entrypoint transport.O-4:` in `enforce-completion-consistency.Payload.Tests.ps1`) | both | 3/0/0 | 3/0/0 | pass |
| U11 (both surfaces) | both | 10/0/0 | 10/0/0 | pass |
| U11b (both surfaces) | both | 4/0/0 | 4/0/0 | pass |
| U11c (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U11d (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U24 (both surfaces) | both | 2/0/0 | 2/0/0 | pass |
| U25 (both surfaces) | both | 10/0/0 | 10/0/0 | pass |
| 120-character parity row (`keeps every line of every surface copy at or under 120 characters`) | both | 1/0/0 | 1/0/0 | pass |
| CR-9 contract row (`documents the one-paragraph multi-message trailer form in the Codex epic-plan skill`) | both | 1/0/0 | 1/0/0 | pass |
| The five F-1 rows | — | — | — | EXCLUDED-BY-DECISION (`evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`, `Decision: F-1 and F-2 withheld`) |
| The F-2 row | — | — | — | EXCLUDED-BY-DECISION (`evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`, `Decision: F-1 and F-2 withheld`) |
| Every AC-8 row of the Predicate suite (`CR-2 false-pass paths.AC-8 ...`) | both | 2/0/0 | 2/0/0 | pass |
| `kelvin-sign-extension` | pester-junit.xml | 1/0/0 | n/a | pass |
| `dotted-capital-i-extension` | pester-junit.xml | 1/0/0 | n/a | pass |
| DEV-2 row | both | 1/0/0 | 1/0/0 | pass |
| Every `AC-19` row of `CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` | pester-junit.xml | 9/0/0 | n/a | pass |
| `asserts tag and manifest version equality in a ref-guarded step ordered before the publish step` | pester-junit.xml | 1/0/0 | n/a | pass |
| `polls the exact published version after publishing and fails the job on budget expiry` | pester-junit.xml | 1/0/0 | n/a | pass |
| `keeps the exit-code reset, explicit exits, and exact-version operand in the poll step` | pester-junit.xml | 1/0/0 | n/a | pass |
| `runs the registry poll step only after a successful publish step` | pester-junit.xml | 1/0/0 | n/a | pass |
| Every row of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` | both | 332/0/0 | 332/0/0 | pass |
| Every row of `enforcement-hooks-no-python-invocation.Tests.ps1` | pester-junit.xml | 32/0/0 | n/a | pass |
| Every row of `hook-dependency-guard-completeness.Tests.ps1` (includes the HookGuardShape S1/S6 checks; 196 S1/S6 testcases, among them `S1: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return` and the matching S6 row, all `Passed`) | pester-junit.xml | 598/0/0 | n/a | pass |
| Every row of `BlastRadius.HistoricalRuns.Tests.ps1` | pester-junit.xml | 9/0/0 | n/a | pass |
| Preimplementation-gate suites, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate*.Tests.ps1` (all variants present) | both | 803/0/0 | 803/0/0 | pass |
| Preimplementation-gate suites, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate*.Tests.ps1` (all variants present) | both | 360/0/0 | 360/0/0 | pass |

Notes:

- The Predicate AC-8 count is 2 in this run (6 in iteration 1) because `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` was restored to PHASE0 content by the P12-T27 withhold; the additional iteration 1 rows were the withheld F-1 rows.
- The Discovery suite, which reported seven findings in iteration 1, reported none in this run (332 rows, 0 failed, on each surface).

Decisions (this pass records no new decision): P12-T26 `Decision: CR-3 retained` (`cr3-decision.2026-10-13T13-43.md`); P12-T27 `Decision: F-1 and F-2 withheld` (`f1-f2-decision.2026-10-13T13-44.md`, commit 4e8d9f92d).

Acceptance: PASS.
