# Remediation Plan — Issue #526 — Cycle 2026-08-26T02-36

- **Feature folder:** `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
- **Input findings:** `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/remediation-inputs.2026-08-26T02-36.md`
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` at `d9c148a7`
- **Work Mode:** `full-bug` (`spec.md` is the sole acceptance-criteria source)
- **Findings in scope:** R1 (Blocking), R3 (Major), R4 (Major), R5 (Major)
- **Findings out of scope:** R2, and the six minor findings m1 through m6

---

## Scope Statement

### R2 is deliberately excluded and is not forgotten

R2 (obtain the green branch-head runs required by `modified-workflow-needs-green-run`) requires no
code change and no plan task. The orchestrator handles it directly, outside this plan, in two steps:
a `workflow_dispatch` of `publish-mcp-npm.yml` against the branch head after this plan finishes
executing, and the `pull_request`-triggered run of `verify-published-releases.yml` that becomes
reachable only once the pull request is opened. Both runs are recorded in the existing artifact
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`,
and AC18 is checked off by the orchestrator at that point. No task below touches AC18, that artifact,
or either workflow file.

### Minor findings are not in scope

Findings m1 through m6 are recorded in the remediation inputs as maintainer-discretion items. m1
(the 500-line proximity of `scripts/dev-tools/Invoke-ReleaseVerification.ps1`) is resolved as a side
effect of Phase 1, because R1 forces the extraction. The remaining five are untouched.

### Documented deviation from the remediation inputs — four helpers extracted, not five

The remediation inputs record the remedy as extracting five pure helpers
(`ConvertFrom-JsonSafely`, `Resolve-PublishStepConclusion`, `Get-RecoveryInstruction`,
`ConvertTo-VerificationResult`, `Get-CodexPinnedMcpVersion`) into a sibling module. This plan
extracts **four** of them and leaves `Resolve-PublishStepConclusion` in
`scripts/dev-tools/Invoke-ReleaseVerification.ps1`. The reason is a hard interaction between two
constraints that the inputs did not size together:

- The nine uncovered measured lines of `scripts/dev-tools/Invoke-ReleaseVerification.ps1` are
  uncoverable by construction. Five are the `Invoke-GhExe`, `Invoke-NpmExe`, and `Invoke-Sleep`
  wrapper-seam bodies, whose coverage would require a real external process or a real wall-clock
  wait, both prohibited by AC21 and AC22. The other four are the dot-source-guarded entry-point
  block. That count of nine does not fall when covered lines are moved out.
- AC24 asserts at least 85 percent line coverage for that file. With nine fixed misses the file
  needs at least 60 measured lines to satisfy the floor. The pre-split file measures 92 lines with
  83 covered. `Resolve-PublishStepConclusion` is by a wide margin the densest of the five candidates
  in measured lines per source line, so relocating it removes the most covered lines for the least
  source-line relief, and it is the single candidate that pushes the ratio under the floor.

Extracting the four low-density helpers removes roughly 129 source lines, leaving roughly 100 lines
of headroom under the 500-line cap after the additions R1 and R3 make, while retaining the covered
measured lines the floor needs. `Resolve-PublishStepConclusion` remains a pure function and remains
fully tested; it is simply not relocated. Phase 1 measures the actual post-split figure and carries
an explicit branch (P1-T8, P1-T9) for the case where the measurement contradicts this estimate, so
no downstream task depends on the estimate being right.

### Coverage-denominator re-partitioning — how this plan handles it

The module split moves measured lines from one file into a second file. Every per-file figure
recorded before the split therefore becomes stale, and the repository-wide denominator changes as
soon as the new file is registered for coverage. Three rules bind every coverage task below:

1. **No post-split figure is ever compared against a pre-split figure.** The recorded pre-split
   values (92 measured, 83 covered, 9 missed, 90.22 percent for
   `scripts/dev-tools/Invoke-ReleaseVerification.ps1`; 96.0543 percent repository-wide) appear in
   artifacts as historical record only, and never as the right-hand side of an acceptance condition.
2. **Every coverage acceptance condition compares against an absolute constant.** The constants used
   are the uniform 85.0 percent line-coverage floor from `.claude/rules/quality-tiers.md` and a
   missed-line count of exactly 0 for the new helpers file, whose four relocated functions are all
   currently fully covered.
3. **The uncoverable-line set is asserted as a set, not as a percentage.** The condition that every
   uncovered line of `scripts/dev-tools/Invoke-ReleaseVerification.ps1` lies inside a wrapper-seam
   body or the entry-point block is falsifiable, is unaffected by the re-partitioning, and catches
   the regression a percentage would hide.

### Coverage measurement route — mandatory

Every coverage-reading task below invokes the self-hosted PoshQC module directly through `pwsh`:

```
pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'
```

The MCP tool `mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the installed
VS Code extension bundle, which carries no `CodeCoverage.Path` entry for a newly registered file, so
it emits no coverage row at all for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`. A
missing row from the MCP runner is a tooling-path artifact and must not be read as a coverage
failure. No task in this plan uses the MCP runner. Where an orchestrator-level gate runs the MCP
runner in the same session, the direct invocation must run **last**, because both runners write the
same `artifacts/pester/powershell-coverage.xml` path.

Per-file coverage rows are parsed by keying on the enclosing `package` element (the full directory
path) and never on the bare `sourcefile` name, because more than one directory in this repository
contains a file of the same base name.

### Command-quoting convention

Every acceptance command below passes its PowerShell payload to `pwsh -NoProfile -Command` inside
**single** quotes, with double quotes used for any string literal inside the payload. This keeps the
payload literal under both a POSIX shell and a PowerShell host, so a `$` inside the payload reaches
PowerShell unexpanded. Do not re-quote these commands.

### Evidence filename timestamps

Every evidence artifact this plan creates carries the fixed stamp `2026-08-26T02-36`, matching the
remediation-inputs stamp for this cycle. The executor must not substitute a different stamp: the
acceptance conditions below assert exact filenames.

### Test purity constraints — binding on every test task

No test added or modified by this plan may create or read a temporary file, reference
`New-TemporaryFile`, `GetTempFileName`, the TEMP environment variable, or `TestDrive`, call
`Start-Sleep`, or invoke a real `npm`, `gh`, or `git` process. All external interaction goes through
the mocked `Invoke-GhExe`, `Invoke-NpmExe`, `Invoke-GitExe`, and `Invoke-Sleep` seams. All fixture
content is supplied as in-memory string literals.

---

## Finding-to-Task Map

| Finding | Severity | Tasks |
|---|---|---|
| R1 — per-check polling budgets, plus the module split it forces | Blocking | P1-T1 through P1-T10; P2-T1 through P2-T5; P4-T2, P4-T3, P4-T4 |
| R3 — `RUN_INCOMPLETE` distinct from `RUN_FAILED` | Major | P3-T1 through P3-T7; P4-T1, P4-T5 |
| R4 — AC21 network-isolation clause | Major | P5-T1, P5-T2 |
| R5 — `Get-ReconciliationReport` deviation record | Major | P5-T3 |

---

### Phase 0 — Baseline capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/ci-workflows.md`, and `.claude/rules/plan-acceptance-gates.md`, then write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/phase0-instructions-read.2026-08-26T02-36.md`. Acceptance: that file exists and contains the fields `Timestamp:`, `Policy Order:`, and an explicit list naming all eight paths above, one per line.

- [ ] [P0-T2] Capture the PowerShell formatter baseline by running `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path'` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/powershell-format-baseline.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its recorded `EXIT_CODE:` value is `0`.

- [ ] [P0-T3] Capture the PSScriptAnalyzer baseline by running `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path'` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/powershell-analyze-baseline.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its recorded `EXIT_CODE:` value is `0`.

- [ ] [P0-T4] Capture the Pester and coverage baseline by running the mandatory coverage-route command and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/powershell-pester-coverage-baseline.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records numeric values for the suite passed count, the suite failed count, the repository-wide line-coverage percent, and the covered, missed, and total measured line counts for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`.

- [ ] [P0-T5] Capture the file-size baseline by running `pwsh -NoProfile -Command 'Get-ChildItem -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1, ./scripts/dev-tools/Invoke-ReleaseTagPush.ps1, ./scripts/dev-tools/Invoke-ReleaseReconciliation.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | ForEach-Object { $_.Name + " " + @(Get-Content -LiteralPath $_.FullName).Count }'` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/file-size-baseline.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records one integer line count for each of the five paths named in the command.

- [ ] [P0-T6] Capture the actionlint baseline by running `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/remediation-baseline/actionlint-baseline.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its recorded `EXIT_CODE:` value is `0`.

### Phase 1 — Extract the pure helpers into a sibling module (R1 precondition)

- [ ] [P1-T1] Create `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` holding the four functions `ConvertFrom-JsonSafely`, `Get-RecoveryInstruction`, `ConvertTo-VerificationResult`, and `Get-CodexPinnedMcpVersion`, each moved verbatim from `scripts/dev-tools/Invoke-ReleaseVerification.ps1` together with its full comment-based help, preceded by a file-level `.SYNOPSIS` block naming issue #526 and stating that the file holds pure helpers and declares no entry-point block. Do not condense any comment-based help. Acceptance: the command `pwsh -NoProfile -Command '. ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1; if ((Get-Command ConvertFrom-JsonSafely -ErrorAction SilentlyContinue) -and (Get-Command Get-RecoveryInstruction -ErrorAction SilentlyContinue) -and (Get-Command ConvertTo-VerificationResult -ErrorAction SilentlyContinue) -and (Get-Command Get-CodexPinnedMcpVersion -ErrorAction SilentlyContinue)) { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P1-T2] Delete the four moved function definitions from `scripts/dev-tools/Invoke-ReleaseVerification.ps1` and, immediately after that file's `param()` block, dot-source the sibling with a `Join-Path` call against `$PSScriptRoot`, under a comment stating that the sibling is dot-sourced so its functions resolve in every consumer scope, including the scope of `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, which dot-sources this file in turn. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0.

- [ ] [P1-T3] Confirm the transitive dot-source still resolves `Get-CodexPinnedMcpVersion` inside `Invoke-ReleaseTagPushGuarded`. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 -CI'` exits with code 0.

- [ ] [P1-T4] Create `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`, which sets `Set-StrictMode -Version Latest`, dot-sources `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` and nothing else, and holds at least eight `It` blocks: the six relocated verbatim from `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` (the two JSON-parse-tolerance tests, the two recovery-instruction tests, and the two Codex-pin tests that need no seam), plus two new tests named exactly `sets ExitCode 0 only for the RESOLVED state` and `reads the pinned mcp version from in-memory Codex config content`. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 -Pattern "sets ExitCode 0 only for the RESOLVED state") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P1-T5] Delete from `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` exactly the six `It` blocks relocated by P1-T4, leaving every test that exercises a seam in place. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -Pattern "returns null for whitespace-only JSON text") { exit 1 } else { exit 0 }'` exits with code 0.

- [ ] [P1-T6] Register the entry `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` in the `CodeCoverage.Path` array of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, immediately after the existing `scripts/dev-tools/Invoke-ReleaseVerification.ps1` entry, preceded by a comment naming issue #526 and stating that `CodeCoverage.Path` is an explicit per-file allow-list, so the new production file must be registered to stay inside the coverage denominator. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Pattern "scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P1-T7] Apply the byte-identical edit from P1-T6 to the bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: the command `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` exits with code 0, and its output reports the test `test_poshqc_bundled_module_files_match_repo_root_sources` as passed.

- [ ] [P1-T8] Run the mandatory coverage-route command and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/module-split-coverage.2026-08-26T02-36.md`. Acceptance: that file exists and contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `CoverageFloorBranch:`, where the `Output Summary:` section records covered, missed, total measured, and percent line coverage separately for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` and for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` plus the explicit uncovered line numbers of the first of those two files, and where `CoverageFloorBranch:` carries exactly one of the two literal values `NO_ACTION` (recorded when the measured percent for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` is at or above 85.0) or `RELOCATE_GET_CODEXPINNEDMCPVERSION` (recorded when it is below 85.0).

- [ ] [P1-T9] Apply the branch that P1-T8 recorded. Under `NO_ACTION`, change no file. Under `RELOCATE_GET_CODEXPINNEDMCPVERSION`, move `Get-CodexPinnedMcpVersion` and its comment-based help back from `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` into `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, move its tests back into `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, and re-run the coverage-route command. Write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/module-split-coverage-branch.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `BranchApplied:`, and `Output Summary:`, its `BranchApplied:` value repeats the branch value P1-T8 recorded, and its `Output Summary:` section records a line-coverage percent for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` that is at or above 85.0.

- [ ] [P1-T10] Verify the 500-line cap after the split by running the P0-T5 command extended with `./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` and `./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`, and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/post-split-file-size.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records an integer line count of at most 500 for each of the seven paths.

### Phase 2 — Per-check polling budgets (R1)

- [ ] [P2-T1] In `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, replace the `IntervalSeconds` and `MaxAttempts` parameters of `Invoke-TagPublishVerification` with the six per-check parameters `RunIntervalSeconds` defaulted to 10, `RunMaxAttempts` defaulted to 18, `StepIntervalSeconds` defaulted to 20, `StepMaxAttempts` defaulted to 60, `NpmIntervalSeconds` defaulted to 15, and `NpmMaxAttempts` defaulted to 40, and forward each pair to its own check: the run pair to `Wait-ForWorkflowRun`, the step pair to `Test-PublishStepConclusion`, and the npm pair to the inline check (c) loop and its `Invoke-Sleep` call. Extend the function's comment-based help with a `.PARAMETER` block stating that the three defaults are the section 3.4 ceilings of 3 minutes, 20 minutes, and 10 minutes. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1 -Pattern "StepMaxAttempts = 60") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P2-T2] In the script-level `param()` block of `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, replace the `IntervalSeconds` and `MaxAttempts` parameters with the same six per-check parameters and identical defaults, and update the entry-point block so it forwards all six by name to `Invoke-TagPublishVerification`. Immediately above that forwarding call, add a single-line comment reading exactly `# Forward all six per-check budgets; one shared pair was the issue 526 R1 defect.` Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1 -Pattern "Forward all six per-check budgets; one shared pair was the issue 526 R1 defect.") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P2-T3] In `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, replace the `MaxAttempts` entry of the `$script:verifyArgs` splat with the three entries `RunMaxAttempts` set to 3, `StepMaxAttempts` set to 3, and `NpmMaxAttempts` set to 3, and update every per-test override of that splat so the existing sleep-count assertions remain valid. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -Pattern "StepMaxAttempts = 3") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P2-T4] Add to `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` a `Context` holding three tests named exactly `forwards the check (a) interval and attempt budget to Wait-ForWorkflowRun`, `forwards the check (b) interval and attempt budget to Test-PublishStepConclusion`, and `polls the registry with the check (c) interval and attempt budget`. Each invokes `Invoke-TagPublishVerification` supplying only `TagName`, `Version`, and `PackageName`, so the defaults apply. The first two mock the named check function with a `-ParameterFilter` binding both its interval and its attempt budget to that check's default pair, and assert `Should -Invoke -Times 1 -Exactly` against the same filter. The third arranges the npm seam never to resolve and asserts `Should -Invoke -CommandName Invoke-NpmExe -Times 40 -Exactly` together with `Should -Invoke -CommandName Invoke-Sleep -Times 39 -Exactly` under a `-ParameterFilter` binding the sleep interval to 15. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -Pattern "forwards the check (b) interval and attempt budget to Test-PublishStepConclusion") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P2-T5] Record the fail-before state of the three tests P2-T4 adds by writing `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/regression-testing/fail-before-per-check-budgets.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, carries `WhyFailingRunImpossible:` when no failing run was captured, and its `Output Summary:` section names all three test titles verbatim and states, for each, which forwarded budget value the pre-change code supplied.

### Phase 3 — Distinguish an exhausted check (b) budget from a failed run (R3)

- [ ] [P3-T1] In `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, change the budget-exhaustion return of `Test-PublishStepConclusion` from the `RUN_FAILED` token to the `RUN_INCOMPLETE` token, and rewrite that function's `.DESCRIPTION` and `.OUTPUTS` help so the exhaustion sentence states that the run never completed and that the correct operator action is to re-run the verifier. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1 -Pattern "RUN_INCOMPLETE") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T2] Add a `RUN_INCOMPLETE` entry to the `$instructions` table of `Get-RecoveryInstruction` in `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, whose text states that the run had not reached a terminal conclusion when the polling budget expired, that the version may or may not be consumed, and that the correct action is to re-run the verifier rather than to read the run logs. Acceptance: the command `pwsh -NoProfile -Command '. ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1; if ((Get-RecoveryInstruction -State "RUN_INCOMPLETE") -and ((Get-RecoveryInstruction -State "RUN_INCOMPLETE") -ne (Get-RecoveryInstruction -State "RUN_FAILED"))) { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T3] In `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, rename the pinning test `check (b) returns RUN_FAILED when its attempt budget is exhausted` to `check (b) returns RUN_INCOMPLETE when its attempt budget is exhausted` and change its expected token accordingly, leaving its sleep-count assertion unchanged. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -Pattern "check (b) returns RUN_INCOMPLETE when its attempt budget is exhausted") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T4] Add to `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` a test named exactly `distinguishes an exhausted publish-step budget from a failed run conclusion`, which drives `Invoke-TagPublishVerification` once with the run view never reporting status completed and once with the run conclusion set to failure, and asserts that the two returned `State` values differ, that the first is the `RUN_INCOMPLETE` token, that the second is the `RUN_FAILED` token, and that both results carry a non-zero `ExitCode`. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 -Pattern "distinguishes an exhausted publish-step budget from a failed run conclusion") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T5] Add to `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` a test named exactly `emits a RUN_INCOMPLETE instruction distinct from the RUN_FAILED instruction`, asserting that both instructions are non-empty and that they are different strings. Acceptance: the command `pwsh -NoProfile -Command 'Invoke-Pester -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 -CI'` exits with code 0, and the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 -Pattern "emits a RUN_INCOMPLETE instruction distinct from the RUN_FAILED instruction") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T6] Update the `.OUTPUTS` help of `Invoke-TagPublishVerification` in `scripts/dev-tools/Invoke-ReleaseVerification.ps1` so it enumerates all seven state tokens, adding `RUN_INCOMPLETE` to the existing six. Acceptance: the command `pwsh -NoProfile -Command 'if ((Select-String -SimpleMatch -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1 -Pattern "RUN_INCOMPLETE").Count -ge 3) { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P3-T7] Add a `RUN_INCOMPLETE` row to the state summary table of `docs/engineering/missed-npm-publish.runbook.md` and a dedicated section headed `## RUN_INCOMPLETE`, placed between the `## NO_RUN` and `## RUN_FAILED` sections, stating the meaning (the publish-step polling budget expired while the run was still in progress), the consumption answer (unknown, and the run may still complete), and the recovery (re-run the verifier before reading any run log, because the run had not concluded). Leave the `## RUN_FAILED` section describing the concluded-failure case only. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./docs/engineering/missed-npm-publish.runbook.md -Pattern "## RUN_INCOMPLETE") { exit 0 } else { exit 1 }'` exits with code 0, and the command `pwsh -NoProfile -Command 'if ((Select-String -SimpleMatch -Path ./docs/engineering/missed-npm-publish.runbook.md -Pattern "RUN_INCOMPLETE").Count -ge 3) { exit 0 } else { exit 1 }'` exits with code 0.

### Phase 4 — Specification reconciliation

- [ ] [P4-T1] Add a `RUN_INCOMPLETE` row to the failure-state table in section 3.2 of `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, directly above the `RUN_FAILED` row, with the meaning "Check (b) budget exhausted; the run had not reached a terminal conclusion" and the recovery "Re-run the verifier. The run may still complete; do not read the run logs as though it had failed." Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "RUN_INCOMPLETE") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P4-T2] Add two rows to the "Files Expected to Change" table in section 7 of `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, one for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` and one for `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`, each stating that the file exists because the 500-line cap forced the pure helpers out of the verification module. Acceptance: the command `pwsh -NoProfile -Command 'if ((Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "Invoke-ReleaseVerificationHelpers").Count -ge 2) { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P4-T3] Extend AC24 in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` so its file list also names `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, leaving the 85 percent floor and the no-exclusion clause unchanged. Acceptance: the command `pwsh -NoProfile -Command 'if ((Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "Invoke-ReleaseVerificationHelpers.ps1").Count -ge 2) { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P4-T4] Append AC29 to the Acceptance Criteria section of `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, unchecked, reading that `Invoke-TagPublishVerification` accepts and forwards a separate interval and attempt budget for each of the three checks, defaulted to the section 3.4 ceilings, and that `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` asserts the forwarded budget of each check individually. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "AC29") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P4-T5] Append AC30 to the Acceptance Criteria section of `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, unchecked, reading that an exhausted check (b) budget returns the distinct token `RUN_INCOMPLETE` with its own recovery instruction and its own runbook section, and that a test asserts the token differs from `RUN_FAILED` while both carry a non-zero exit code. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "AC30") { exit 0 } else { exit 1 }'` exits with code 0.

### Phase 5 — AC21 network-isolation evidence (R4) and the deviation record (R5)

- [ ] [P5-T1] Establish network isolation, run the complete Pester suite inside it, and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md`. Take the preferred branch first: in a single `pwsh` session set `HTTP_PROXY`, `HTTPS_PROXY`, and `ALL_PROXY` to the discard endpoint `http://127.0.0.1:9`, set `NO_PROXY` to the empty string, set `NPM_CONFIG_REGISTRY` to the same discard endpoint, prove the isolation is real by running `npm view @danmoisan/drm-copilot-mcp version` and requiring a non-zero exit code, then run the mandatory coverage-route command in that same session. If the isolation probe exits 0 the isolation is not real in this environment: take the recorded-limitation branch instead, change no environment variable, run no suite under isolation, and record that a network-isolated run is impractical here together with the probe output that showed it. Acceptance: that file exists and contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `IsolationMethod:`, `IsolationProbeExitCode:`, `NetworkIsolationBranch:`, and `Output Summary:`, where `NetworkIsolationBranch:` carries exactly one of the two literal values `EXECUTED` or `RECORDED_LIMITATION`, and where the `Output Summary:` section records the suite passed count and failed count under the `EXECUTED` branch, or the probe output and the reason isolation could not be established under the `RECORDED_LIMITATION` branch.

- [ ] [P5-T2] Reconcile AC21 in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` against the branch P5-T1 recorded. Under `EXECUTED`, leave AC21's text unchanged and append a sentence naming `evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md` as the evidence for its first clause. Under `RECORDED_LIMITATION`, narrow AC21's first clause so it asserts only that no test added or modified by this change reaches the network, and append a sentence naming the same artifact as the record of why the whole-suite isolation clause was narrowed. Acceptance: the command `pwsh -NoProfile -Command 'if (Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "network-isolated-suite.2026-08-26T02-36.md") { exit 0 } else { exit 1 }'` exits with code 0.

- [ ] [P5-T3] Write the deviation record `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/other/get-reconciliation-report-deviation.2026-08-26T02-36.md`, mirroring the structure of the existing `evidence/other/marketplace-check-deferral.2026-08-26T02-05.md`. This task changes no code. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, names the function `Get-ReconciliationReport` and its location `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`, quotes verbatim the Coverage Exclusion Policy sentence from `.claude/rules/general-unit-test.md` that begins "The correct response to a file that contains untestable lines is to refactor it", states that task P5-T1 of the original plan named only `Get-UnpublishedTagVersion` and the dot-source guard, and records both historical per-file line-coverage figures 70.83 and 88.89 as the before-and-after of the extraction.

### Phase 6 — Post-change coverage, denominator record, and criterion check-off

- [ ] [P6-T1] Run the mandatory coverage-route command and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/post-remediation-coverage.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section records a repository-wide line-coverage percent at or above 85.0, a per-file line-coverage percent at or above 85.0 for each of `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, and `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, and a missed-line count of exactly 0 for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`.

- [ ] [P6-T2] Write the denominator record `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/coverage-denominator-repartition.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records all of: the pre-split measured, covered, and missed line counts for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, quoted as historical values from `evidence/qa-gates/verification-module-coverage.2026-08-26T01-13.md`; the post-split measured, covered, and missed counts for that same file and for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`; the arithmetic sum of the two post-split measured counts set beside the pre-split measured count of 92 with an explanation of the difference; and an explicit statement that no acceptance condition in this cycle compared a post-split figure against a pre-split figure.

- [ ] [P6-T3] Classify every uncovered line of `scripts/dev-tools/Invoke-ReleaseVerification.ps1` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/uncovered-line-classification.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section enumerates every uncovered line number with the enclosing function name or the literal `entry-point block` for each, and states that the count of uncovered lines falling outside the `Invoke-GhExe`, `Invoke-NpmExe`, `Invoke-Sleep`, and entry-point regions is 0.

- [ ] [P6-T4] Record the pass-after state of the R1 and R3 regression tests by writing `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/regression-testing/pass-after-per-check-budgets.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section names verbatim each of the six test titles introduced by P2-T4, P3-T3, P3-T4, and P3-T5 and records each as passed.

- [ ] [P6-T5] Check off AC29 and AC30 in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` by changing their checkboxes from unchecked to checked, citing `pass-after-per-check-budgets.2026-08-26T02-36.md` in a trailing sentence on each. Acceptance: the command `pwsh -NoProfile -Command 'if ((Select-String -SimpleMatch -Path ./docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md -Pattern "pass-after-per-check-budgets.2026-08-26T02-36.md").Count -ge 2) { exit 0 } else { exit 1 }'` exits with code 0.

### Phase 7 — Final QA loop

Run the stages in the order given. If any stage fails, or if any stage changes a file on disk,
restart the loop at P7-T1. Do not proceed past a failing stage. Every task in this phase is
unconditional; none carries a skip branch, and `EXIT_CODE: SKIPPED` is not a valid outcome for any
of them.

- [ ] [P7-T1] Run `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path'` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-format.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section records the count of files the formatter changed as 0.

- [ ] [P7-T2] Run `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path'` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-analyze.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section records the PSScriptAnalyzer finding count as 0.

- [ ] [P7-T3] Run the mandatory coverage-route command and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-pester.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section records the suite passed count, a failed count of 0, and a repository-wide line-coverage percent at or above 85.0.

- [ ] [P7-T4] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-runsettings-parity.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, its recorded `EXIT_CODE:` value is `0`, and its `Output Summary:` section names the test `test_poshqc_bundled_module_files_match_repo_root_sources` and records it as passed.

- [ ] [P7-T5] Run `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-actionlint.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its recorded `EXIT_CODE:` value is `0`.

- [ ] [P7-T6] Run the file-size check across all seven paths named in P1-T10 and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-file-size-check.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records an integer line count of at most 500 for each of the seven paths.

- [ ] [P7-T7] Verify test purity across the four test files this cycle adds or modifies (`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`, `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`, and `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1`) and write `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/final-test-purity.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records, per file, a match count of 0 for each of `New-TemporaryFile`, `GetTempFileName`, `TestDrive`, and `Start-Sleep`, and a classification of every textual `npm`, `gh`, or `git` match as a mock payload, a test title, a mock declaration, or an assertion pattern.

- [ ] [P7-T8] Record the loop outcome in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/toolchain-loop.2026-08-26T02-36.md`. Acceptance: that file exists, contains the fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` section records the number of loop iterations performed, states which iteration was the first in which P7-T1 through P7-T7 all passed consecutively with no file changed, and names the stages in the order they ran.
