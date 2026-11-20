# [P13-T3] Final self-hosted Pester run and aggregate line coverage

Timestamp: 2026-09-07T17-11

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psd1' -Force; Invoke-PoshQCTest -Root (Get-Location).ProviderPath -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"`

Command:

```
mcp__drm-copilot__run_poshqc_test        # workspace_root: the worktree root, no scan_folders; counts read from artifacts/pester/pester-junit.xml
gh workflow run .github/workflows/_poshqc.yml    # coverage route, dispatched by the orchestrator
gh run watch 34145103168
```

EXIT_CODE: 2

The exit code is 2 because the local run reports two failures. Both are named below and both are
members of the [P0-T7] baseline failing set, so the carve-out in this task's acceptance applies.

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session; the mandated command is
refused unconditionally by the runtime worktree-isolation guard, so no process starts and it
produces no exit code. Two substitute routes were used, each for the figure it can produce
correctly:

- **Counts** came from `mcp__drm-copilot__run_poshqc_test` over the whole workspace, read from
  `artifacts/pester/pester-junit.xml`. The MCP runner executes the full suite correctly; what it
  cannot do is honour this checkout's `CodeCoverage.Path` entries, because it resolves its
  runsettings from the installed VS Code extension.
- **Coverage** came from a CI dispatch of `.github/workflows/_poshqc.yml`, run id `34145103168`,
  which imports the same self-hosted `scripts/powershell/PoshQC/PoshQC.psm1` and resolves
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from the checked-out branch, so the
  eight `CodeCoverage.Path` entries this change added are honoured. The MCP runner was deliberately
  **not** used for the coverage figure, for the reason the [P0-T7] artifact records.

## Test counts

Source: `artifacts/pester/pester-junit.xml`, emitted by the local MCP run.

| Measure | Value | Read from |
|---|---|---|
| Total tests | 4326 | `testsuites/@tests`, cross-checked by counting 4326 `<testcase>` elements |
| Errors | 0 | `testsuites/@errors` |
| **Failed** | **2** | `testsuites/@failures`, cross-checked by counting 2 `status="Failed"` attributes |
| **Skipped** | **9** | `testsuites/@disabled`, cross-checked by counting 9 `status="Skipped"` attributes |
| **Passed** | **4315** | counted directly as 4315 `status="Passed"` attributes; also 4326 - 2 - 0 - 9 |
| Wall time | 165.599 s | `testsuites/@time` |

4315 + 2 + 9 = 4326, and `status="NotRun"` appears zero times, so every test case is accounted for.

### Passed count against the [P0-T7] baseline

| Measure | [P0-T7] baseline | This run | Condition |
|---|---|---|---|
| Passed | 3919 | 4315 | at or above baseline: **satisfied**, +396 |
| Total | 3930 | 4326 | +396 |
| Failed | 2 | 2 | unchanged, same two tests by name |
| Skipped | 9 | 9 | unchanged |

The 396 additional passing tests are the cases this plan added across its 24 new Pester suites and 3 modified ones,
including the 99 cases [P12-T9] added.

## Overall line coverage

**95.4618 percent**, covered **8414**, missed **400**.

| Provenance field | Value |
|---|---|
| Route | CI dispatch of `.github/workflows/_poshqc.yml` |
| Run id | `34145103168` |
| Run outcome | watched to completion with a zero exit status |
| Measured at commit | `5903d0c7` |
| Source element | the report-level `counter` element whose `type` is `LINE` in `artifacts/pester/powershell-coverage.xml` produced by that run |
| Arithmetic | 8414 / (8414 + 400) = 8414 / 8814 = 95.4618 percent |
| First-round comparison | 94.0209 percent at commit `cc83c0c8` (run `34139262327`), covered 8287, missed 527 |
| [P0-T7] baseline comparison | 94.8047 percent, covered 7427, missed 407 |

**No threshold is asserted against this aggregate.** The 85 percent obligation applies per production
file and is evaluated in [P13-T4]. The aggregate is recorded because the task requires a numeric
figure attributed to the element it was read from, not because any gate is conditioned on it.

The suite was **GREEN on that CI checkout**, with all 99 new [P12-T9] cases included. That is the
stronger evidence on the two local failures below: on a clean checkout of the same commit, neither
reproduces.

## The two failing tests, by name, with the reason each is out of scope

Both are recorded in the [P0-T7] baseline
(`evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md`) as failing before any task in
this plan ran, observed on an unmodified worktree at HEAD `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`.
Both are ambient-state artifacts of this worktree and neither reproduces on the clean CI checkout.

### Failure 1

- Suite file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Describe: `enforce-pr-author-skill.ps1`
- Context: `allowed commands`
- It: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: line 145, `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`
- Observed `deny`, expected `allow`

**Reason it is out of scope.** The case does not mock `Get-PrAuthorCheckpointContent`, so it reads
this run's real `artifacts/orchestration/orchestrator-state.json` checkpoint. That checkpoint carries
`epic_mode: true`, while the fixture command carries no `--base` operand, so the hook denies —
correctly, on the state it was handed. The failure is produced by the ambient checkpoint present in
this worktree during an active orchestration, not by any command-text matching behaviour. On the CI
checkout `artifacts/orchestration/` is gitignored and absent, the epic-mode predicate does not fire,
and the case passes.

### Failure 2

- Suite file: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
- Describe: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits`
- It: `allows every registered handler for every tool name its own matcher admits`
- Assertion site: line 165, `$failures -join "\`n" | Should -BeNullOrEmpty`
- Observed: `enforce-epic-wave-barrier.ps1` denies every admitted tool name with
  `EPIC_WAVE_BARRIER_BLOCKED: '545' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint.`

**Reason it is out of scope.** The denial is driven by `enforce-epic-wave-barrier.ps1` reading this
worktree's gitignored epic checkpoint, which names item `545` with unmerged `depends_on` edges.
`enforce-epic-wave-barrier.ps1` is not one of the nine hooks in scope for this change and was not
modified by it. On the CI checkout the epic checkpoint is absent and the case passes.

## No test created or modified by this plan is in the failing set

The two failing suite files are `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. Neither appears in the 27-entry
test-file list of the [P12-T1] enumeration recorded in
`evidence/qa-gates/final-poshqc-analyze.2026-09-07T17-05.md`, so neither was created or modified by
this plan. Every one of the 27 test files this plan created or modified reports zero failures in
this run. The loop therefore does not restart at [P13-T1].

## Output Summary

Full local Pester run: **4315 passed, 2 failed, 9 skipped**, 4326 total, 0 errors, in 165.599 s;
exit code 2 because of the two failures. Both failing tests are named above and both are members of
the [P0-T7] baseline failing set, so the acceptance carve-out applies; each is recorded with the
ambient-state reason it is out of scope. Passed count 4315 is at or above the baseline 3919. No test
created or modified by this plan fails. **Overall line coverage 95.4618 percent**, computed as
8414 / (8414 + 400) from the report-level `LINE` counter of CI run `34145103168` at commit
`5903d0c7`; no threshold is asserted against that aggregate. The suite is green on that CI checkout.
