# 2026-10-15-release-flow-waits-on-required-checks-only (Remediation Plan, cycle 2)

- **Issue:** #931
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T04-02
- **Status:** Ready for preflight
- **Version:** 1.1 (preflight round 1 delta applied: P0-T7, P0-T8, P0-T12, P0-T16, P0-T17, P1-T2, P2-T4, Decision 5, Conventions, Verified Plan-Time Facts)
- **Work Mode:** minor-audit (from `issue.md`; the sole AC source is `issue.md` `## Acceptance Criteria`, AC1 through AC6; `spec.md` and `user-story.md` are intentionally absent)
- **Branch:** `bug/release-flow-waits-on-required-checks-only-931` (local alias branch `issue-931-cycle2` in the executing worktree)
- **Cycle:** remediation cycle 2, findings F1 to F4 from `remediation-inputs.2026-10-16T04-02.md`

DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Conventions Used in This Plan

- `<FEATURE>` means `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`. Every evidence path resolves to `<FEATURE>/evidence/<kind>/` with kind one of `baseline`, `regression-testing`, `qa-gates`, or `other`. Commands below spell the feature folder out in full.
- Every cycle-2 evidence file name starts with the stem `cycle2-`, so no cycle-2 file can collide with an artifact of `plan.2026-10-15T15-45.md` or `remediation-plan.2026-10-16T02-11.md`. Earlier artifacts are never edited, renamed, or deleted.
- `<ts>` in an evidence filename is the UTC time at which that file is written, read from the host clock immediately before the write with the Bash command `date -u +%Y-%m-%dT%H-%M`; its success-case output is one 16-character line of the shape yyyy-MM-ddTHH-mm. The same value is the artifact's `Timestamp:` line with no zone suffix. A file write time is read with `date -u -r <file> +%Y-%m-%dT%H-%M`, which the cycle 1 executor ran successfully (`<FEATURE>/evidence/baseline/cycle1-local-coverage-baseline.2026-10-16T02-55.md`, `COVERAGE_WRITTEN`). A task that consumes an earlier artifact selects the lexicographically greatest file matching `<name>.*.md` in the named folder.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Artifacts contain no absolute host path: the worktree root is written as `<worktree>`.
- `SCRATCH` denotes the per-item scratch directory `<session scratchpad>/issue-931/`. This plan names no scratch file; if the executor needs one, it lives under `SCRATCH` and artifacts record the literal token `SCRATCH/...`. No PowerShell scratch file is written. No test creates a temporary file.
- No commit or push task. The orchestrator commits and pushes at phase boundaries. Every scope assertion below therefore compares the working tree against the cycle entry commit `7051d8a8d` (`git diff` with that ref operand) and pairs it with `git status --porcelain`, so it holds whether or not the orchestrator has committed in between. Never force-push, never rebase, and create no GitHub issue.
- No merge from `main` (or any other branch) into the cycle branch during this cycle. A merge would add files outside `## Writes` to the diff against `7051d8a8d`, which would make the scope checks in P2-T8 and at the end of P2-T9 report paths this cycle did not change. If a merge from `main` becomes necessary, it waits until P2-T9 is complete.
- PowerShell verification is operator Option A: the PoshQC MCP tools `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, called with `workspace_root` set to the worktree root. Every `run_poshqc_test` call passes `scan_folders = ["tests/scripts/dev-tools"]` (a full-suite call does not return within the client MCP idle timeout; `<FEATURE>/evidence/baseline/ps-test.2026-10-16T01-26.md`). Every `run_poshqc_format` and `run_poshqc_analyze` call passes `scan_folders = ["scripts/dev-tools", "tests/scripts/dev-tools"]`; if the tool rejects the `scan_folders` argument with a schema or argument error, the same task calls it once more without that argument and records both calls (this is a retry of the same command, not a skip). These tools return only `{"ok":...,"summary":"..."}`; artifacts record `EXIT_CODE: 0` when the call returned `"ok":true` and non-zero otherwise. No acceptance condition reads a count, percentage, or finding from a tool result. No shell wrapper runs Pester, PSScriptAnalyzer, or the formatter.
- Pester stays on the breakpoint coverage the PoshQC runner configures; this plan changes no coverage setting. The runner leaves `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` in the working tree; they are read with the Read and Grep tools and never staged or edited. Observed schema (cycle 1 artifacts): JUnit root attributes `tests`, `failures`, `errors`; JaCoCo-style coverage with one `<class ... sourcefilename="<file>">` element per script and class-level `<counter type="LINE" missed=".." covered=".."/>`. The record of coverage for AC6 remains the PR CI artifact `poshqc-test-results` from the job `poshqc / PowerShell QC` (`windows-latest`, `.github/workflows/_poshqc.yml`), which clears at S9 and is not claimed here. The Linux job `poshqc / PowerShell hook suites (Linux)` runs only hook suites and is not relied on.
- Scoped-run note: `tests/scripts/dev-tools` holds every release-flow Pester suite, so every local count and percentage in this plan is a scoped-run value, and every baseline-to-final comparison is scoped to scoped.
- Grep-tool searches: the Grep tool takes a regular expression. A search this plan calls a "literal" is run with every regular-expression metacharacter in the quoted string (`. * [ ] ^ $ \ ( ) { } | + ?`) escaped with a backslash, so it matches the quoted text exactly; a search this plan calls a "regex" is run as written. Files this plan creates are untracked until the orchestrator commits them, so they are searched with the Grep tool, never with `git grep`.
- Fenced code blocks inside task items are indented two spaces for Markdown list nesting. That leading indentation is not part of the text to write: each line is written with the two list-nesting spaces removed, so a line shown as `  function Test-UnregisteredCheckPollOutput {` is written starting at column 1, and a line shown as `      $registrationAttempt = 1` is written with four leading spaces.
- The executor has no PowerShell tool. Commands run with the Bash tool use `git`, `wc`, `date`, `rm`, `gh`, and `poetry`, plus the Read, Grep, Glob, Edit, and Write tools. The worktree guard rejects command text naming a shell executable other than `sh` and rejects heredocs; no task needs either.
- Python: no Python file is edited. `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` pins text in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` through the constants `RELEASE_FLOW_REQUIRED_PHRASES` and `RELEASE_FLOW_ALL_CHECKS_FRAGMENTS` at lines 105-110 of the Python test module and the test `test_release_flow_waits_on_every_check_without_required_wording` at lines 251-271 of the same module, so that module is run at baseline and at final QC as a regression check; no Python coverage task is planned because no Python file changes in this cycle.

## Verified Plan-Time Facts (re-derived against the current tree in this authoring pass)

- Entry commit: the cycle entry commit is `7051d8a8d` (`docs(931): record cycle 2 remediation inputs`). In this revision pass `refs/heads/issue-931-cycle2` resolves to `049cfa67ace27a9ebbe2b636f4938cc902692ec5` (`docs(931): add remediation cycle 2 plan`), the plan commit on top of `7051d8a8d`. The plan file will be recommitted after this revision, so no task pins HEAD to a SHA: P0-T8 asserts that `7051d8a8d` is an ancestor of HEAD and that the commits since it changed nothing outside the feature folder. The worktree status at session start listed only the untracked `SCRATCH/` directory.
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is 499 lines. Line 41 is the `$RepoRoot` default and line 42 closes the script `param` block; line 44 opens `function Write-StderrLine {`. `ConvertTo-CommandResult` (lines 53-66) declares `[OutputType([pscustomobject])]` (line 55) and returns `[pscustomobject]@{ Output = $Output; ExitCode = $ExitCode }` (line 65). `Invoke-GitExe` (lines 68-83) and `Invoke-GhExe` (lines 85-100) each document `A hashtable with keys Output (string[]) and ExitCode (int).` (lines 73 and 90) and declare `[OutputType([hashtable])]` (lines 76 and 93), and each returns `ConvertTo-CommandResult` (lines 82 and 99).
- `function ConvertFrom-CheckPollOutput` spans lines 162-194; line 195 is blank; `function Get-CheckSetVerdict` spans lines 196-235; line 236 is blank; `function Wait-ForPullRequestChecks` starts at line 237. Line 213 is `$property = if ($null -eq $check) { $null } else { $check.PSObject.Properties['bucket'] }` (the F4 guard).
- `Wait-ForPullRequestChecks` help: line 240 synopsis; line 244 `The poll queries every check on the pull request head, whether or not branch protection requires it.`; lines 246-251 the Phase A paragraph; lines 275-279 the `.OUTPUTS` text. Code: line 301 `$ghArgs = @('pr', 'checks', $PrNumber, '--json', 'bucket')`; lines 304-313 Phase A (`$registrationAttempt = 1`, `while ($poll.ExitCode -ne 0) {`, timeout check, `Invoke-Sleep`, re-poll); line 315 calls `ConvertFrom-CheckPollOutput`; line 324 calls `Get-CheckSetVerdict`.
- `Get-FirstOutputLine` (lines 144-160) declares `-Output` as `Mandatory` `[object[]]` without `[AllowEmptyCollection()]`, so it is not used for the F2 message (an empty `Output` array would fail binding).
- Tests: `Invoke-FullReleaseFlow.Tests.ps1` 426 lines, 15 `It` blocks, Context `helpers` at lines 388-409 whose last test `accepts an empty array as Output without throwing` ends at line 408; `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` 297 lines, 19 `It` blocks, Context `registration phase` at lines 14-56 whose test `returns failure on registration timeout` occupies lines 37-55; `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` 160 lines, 18 `It` blocks, Describe titles at lines 2 and 103, `BeforeAll` blocks at lines 3-6 and 104-107 (each resolves the main script and runs `. $script:scriptPath -ConfirmToken 'no'`); `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` 99 lines, 2 `It` blocks (11 test cases through `-ForEach`). Every suite dot-sources the main script in `BeforeAll`.
- Existing Phase A mocks in ChecksWait return `ExitCode = 1` with output `no checks reported on the 'release/full-20260703171500' branch` (lines 21 and 122) or `no checks reported` (line 42). Every `pr checks` mock in `Invoke-FullReleaseFlow.Tests.ps1` (lines 71-72, 304-305, 335-336) and in `AdditionalFailurePaths` (line 80) returns `ExitCode = 0`. Therefore every existing test that drives Phase A stays valid under the F2 rule without edit.
- gh no-checks behavior (recorded sources, not a live run by the planner): `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/research/research.2026-10-09T02-25.md` line 44 records from `pkg/cmd/pr/checks/checks.go` that `populateStatusChecks` runs before the JSON exporter and returns the error `no checks reported on the '<branch>' branch` for zero checks; `<FEATURE>/research/2026-10-15-release-flow-all-checks-research.md` lines 26-29 record the same error as a plain non-zero exit and that with `--json` only the no-checks errors and transport or authentication errors exit non-zero; `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md` line 58 records a real run printing the sibling message `no required checks reported on the '...' branch`. Live observation (executor preflight, this cycle): `gh pr checks 15 --json bucket` against PR 15, which has no checks, printed `no checks reported on the 'chore/gitignore' branch` and exited 1. The planner had no shell in this pass, so P0-T12 repeats that call, runs `gh pr checks --help`, and makes a read-only call against PR 948, and records all of them before any edit.
- Mirrors and references: outside `docs/`, the literal `Invoke-FullReleaseFlow` occurs only in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, the four Pester suites, `.vscode/tasks.json` (line 293 only, where the task passes the entry script path `${workspaceFolder}/scripts/dev-tools/Invoke-FullReleaseFlow.ps1`), and `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (line 44). No copy exists under `.claude/`, `.github/`, `.codex/`, `.agents/`, `extensions/`, `packages/`, or `config/`. The precedent sibling helper `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` is referenced only by its caller and its own test file. `config/poshqc-coverage.json` lists the root `scripts`, so a new `.ps1` under `scripts/dev-tools/` is inside coverage measurement with no configuration change; `config/poshqc-scan.json` scans `tests/scripts`.
- Precedent for the dot-source form: `scripts/dev-tools/Invoke-ReleaseVerification.ps1` line 54 is `. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-ReleaseVerificationHelpers.ps1')`, placed after the `param` block, and `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` lines 5-9 dot-source the helper file directly.
- Python contract pin: `RELEASE_FLOW_ALL_CHECKS_FRAGMENTS` (lines 106-110) requires `every check on the pull request head`, `every GitHub check on the pull request head`, and `@('pr', 'checks', $PrNumber, '--json', 'bucket')` in the main script, and `RELEASE_FLOW_REQUIRED_PHRASES` forbids `required check`. None of these lines is moved or reworded by this plan. A recorded run of the module printed `35 passed` (`<FEATURE>/evidence/qa-gates/py-pytest-contract.2026-10-16T01-44.md`).
- Coverage history: main CI baseline for the script is 115 of 122 lines, 94.26 percent (`<FEATURE>/evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`); cycle 1 local scoped value is 153 of 160, 95.63 percent, with the seven missed lines in the mocked seams `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-ChildPowerShellScript` (2 lines each) and `Invoke-Sleep` (1 line) (`<FEATURE>/policy-audit.2026-10-16T03-14.md` section 1.2). `issue.md` shows AC1 through AC6 all checked.
- Absent literals at plan time (each is a string a task below creates): `Invoke-FullReleaseFlow.CheckHelpers`, `Test-UnregisteredCheckPollOutput`, `Could not query the checks`, `declares the command-result output type on`.

## Decisions (fixed here; no optional file or open choice remains)

1. **F3 helper file.** Create `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` holding `ConvertFrom-CheckPollOutput` (moved verbatim from lines 162-194), `Get-CheckSetVerdict` (moved from lines 196-235 with the F4 edit), and the new F2 predicate `Test-UnregisteredCheckPollOutput`. The main script dot-sources it with `. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.CheckHelpers.ps1')` placed directly after the script `param` block, which follows the `Invoke-ReleaseVerification.ps1` precedent. `$PSScriptRoot` is the directory of the file being run even when that file is dot-sourced, and a dot-sourced file runs in its caller's scope, so the helpers resolve when a Pester suite dot-sources the main script and when the main script runs as an entry point. No configuration, task, workflow, or manifest lists the script's sibling files, so no mirror edit exists to make; P0-T11 and P1-T12 record the search.
2. **F3 test location.** The 18 helper tests move to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`, which mirrors the new source file (`.claude/rules/general-unit-test.md`, Test File Location). The new file is the old file `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` with only the two Describe titles and the two `BeforeAll` blocks changed (the blocks dot-source the helper file directly, as `Invoke-ReleaseVerificationHelpers.Tests.ps1` does); every `It` block is byte-identical. The old file is then deleted with `rm`. JUnit classnames for these 18 tests therefore change from `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` to `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`; P2-T9 records the replacement S9 counts.
3. **F4.** Remove the guard: line 213 becomes `            $property = $check.PSObject.Properties['bucket']` in the helper file. The cycle 1 probe (`<FEATURE>/evidence/baseline/cycle1-binder-probe.2026-10-16T02-49.md`) recorded six call forms rejected by the binder, and the only caller passes `ConvertFrom-CheckPollOutput` output, which rejects non-object elements. `-Checks` keeps `[AllowEmptyCollection()]`, `Mandatory`, and `[object[]]` and gains no `[AllowNull()]`. Behavior for every input that can bind is unchanged, and no test changes for F4.
4. **F1.** In `Invoke-GitExe` and `Invoke-GhExe`, replace `[OutputType([hashtable])]` with `[OutputType([pscustomobject])]` and replace the `.OUTPUTS` line with `        A pscustomobject with properties Output (object[]) and ExitCode (int), built by ConvertTo-CommandResult.` One parameterized test in Context `helpers` of `Invoke-FullReleaseFlow.Tests.ps1` asserts that each wrapper declares exactly one output type equal to the type `ConvertTo-CommandResult` declares.
5. **F2 rule.** Observed gh behavior: with no registered checks, `gh pr checks <n> --json bucket` prints `no checks reported on the '<branch>' branch` and exits 1 (live run against PR 15 in executor preflight; re-observed by P0-T12). In Phase A, a non-zero poll is retried only when its output contains the substring `no checks reported`. Any other non-zero poll, such as an authentication or network failure, fails promptly without sleeping: it writes `Could not query the checks for PR #<n> (gh exit code <code>).` to stderr and returns 1 at once, before any `Invoke-Sleep` call. The rule reads output text rather than the exit code because gh uses exit 1 both for the no-checks error and for HTTP errors. Output lines are cast with `[string]`, which yields the message text for an `ErrorRecord` produced by `2>&1` in `Invoke-GhExe`. If a gh version prints `[]` with exit 0 for a head with no checks, Phase A is not entered and Phase B treats the empty set as `empty` and keeps polling within the completion budget, which is never green (AC4). Phase B is unchanged: a failed re-poll there still consumes one completion attempt (existing test `continues after a non-zero completion poll`).
6. **F2 tests.** ChecksWait gains a parameterized test over three failure texts (`HTTP 401: Bad credentials (https://api.github.com/graphql)` with exit 1, `To get started with GitHub CLI, please run:  gh auth login` with exit 4, `error connecting to api.github.com` with exit 1) asserting return 1, the new stderr text, one `Invoke-GhExe` call, and zero `Invoke-Sleep` calls with the default 24-attempt budget; and a test that returns the no-checks message as an `ErrorRecord` twice before a pass set, asserting return 0, two sleeps, and three polls. The three existing Phase A tests stay unchanged and keep proving the retry path for plain-string output. The helper file test gains four direct tests of `Test-UnregisteredCheckPollOutput`.
7. **Coverage.** Pester measures line coverage only and PowerShell has no branch gate. Acceptance in P2-T4: the main script's local line percentage is at least 94.26 (the AC6 Phase 0 baseline); the helper file's local line percentage is at least 94.26 and its missed-line count is 0; the combined percentage of the two files is at least the cycle 2 Phase 0 local percentage of the main script (expected 95.63); and the combined missed-line count is at most the Phase 0 missed count (expected 7). Plan-time expectation, not asserted: the helper file reports 100 percent and the main script about 94.8 percent, because the moved functions were fully covered and the seven mocked seam lines stay in the main script.
8. **Test-count delta.** Exactly ten test cases are added: ChecksWait +4 (three parameterized cases and one `ErrorRecord` retry test), CheckHelpers +4, `Invoke-FullReleaseFlow.Tests.ps1` +2 (two parameterized cases). The 18 moved tests keep their count. Expected `It`-block counts after Phase 1: Tests 16, ChecksWait 21, CheckHelpers 22, AdditionalFailurePaths 2.
9. **Fail-before.** No fail-before run is captured: the MCP test tool returns status only and a single scoped run follows all Phase 1 edits. The F1 test fails on the pre-change tree by construction (the declared type was `System.Collections.Hashtable`); this is recorded as reasoning only, not as evidence.
10. **AC state.** `issue.md` is not edited. AC1 through AC6 stay checked and no criterion is added; P0-T7 and P2-T8 verify the counts.

## Acceptance Criteria Traceability

Source: `<FEATURE>/issue.md` `## Acceptance Criteria` (AC1 to AC6), all checked at entry. This cycle must leave each satisfied. F1 to F4 are the cycle inputs.

| ID | Implementation tasks | Test tasks | Evidence artifacts |
|---|---|---|---|
| AC1 | none (line 301 unchanged; P1-T5 leaves it intact) | P1-T13, P2-T3, P2-T5 | qa/cycle2-ps-test, qa/cycle2-py-contract |
| AC2 | P1-T2 (verdict moved verbatim except F4) | P1-T13, P2-T3 | qa/cycle2-local-results-final |
| AC3 | P1-T2 | P1-T13, P2-T3 | qa/cycle2-local-results-final |
| AC4 | P1-T2, P1-T5 | P1-T9, P1-T13, P2-T3 | qa/cycle2-local-results-final |
| AC5 | P1-T6 (help text keeps all-checks wording) | P2-T5 | qa/cycle2-py-contract |
| AC6 | P1-T7 to P1-T10 | P2-T1 to P2-T4 | qa/cycle2-local-results-final, qa/cycle2-verification |
| F1 | P1-T4 | P1-T10, P1-T14 | rt/cycle2-pester-junit-after |
| F2 | P1-T5, P1-T6 | P1-T8, P1-T9, P1-T14 | bl/cycle2-gh-observation, rt/cycle2-pester-junit-after |
| F3 | P1-T2, P1-T3, P1-T7 | P1-T11, P1-T12, P2-T4 | rt/cycle2-structure, rt/cycle2-reference-search, qa/cycle2-local-results-final |
| F4 | P1-T2 | P1-T11, P2-T4 | rt/cycle2-structure |

`bl/` is `<FEATURE>/evidence/baseline/`, `rt/` is `<FEATURE>/evidence/regression-testing/`, `qa/` is `<FEATURE>/evidence/qa-gates/`, `ot/` is `<FEATURE>/evidence/other/`.

## Writes

Repository files this plan changes outside `<FEATURE>`:

- `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` (create)
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (edit)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` (create)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` (delete, after its content is moved)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (edit)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (edit)

Inside `<FEATURE>`: this plan (task checkboxes) and the `evidence/` artifacts named below. `issue.md` is not edited.

## Notes (not tasks)

- The planner had no shell or MCP tool in this authoring pass. Every command form below that the planner did not observe is either recorded in a cycle 1 artifact (cited in place) or is observed by its first-use task, which stops with BLOCKED on an unexpected shape.
- Residual unknown: the no-checks error text was observed live once, in executor preflight (`gh pr checks 15 --json bucket` printed `no checks reported on the 'chore/gitignore' branch` and exited 1), and agrees with the gh source summarized in earlier research. P0-T12 repeats that call as recorded evidence and also observes the installed gh version, its help, and the output shape for PR 948. The remaining unknown is whether a future gh version changes that text. The F2 rule is robust to the exit code and to a gh that returns `[]` (Decision 5); a gh that printed different no-checks text would make Phase A fail promptly rather than retry, which is a non-green outcome.
- `.vscode/tasks.json` invokes `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` by path and needs no edit; the entry script still dot-sources its helpers.
- Out of scope: Phase B retry behavior on a failed re-poll, the prd-feature receipt (minor-audit forbids `spec.md`), and the Python branch-level coverage record (PR CI).
- No upstream instruction supplied a non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry applies.
- Reduced audit after executor validation: the orchestrator runs the small audit against the P2-T9 verification artifact.

### Phase 0 — Policy reads and baseline capture

- [x] [P0-T1] Read `./CLAUDE.md` (repository root) in full (policy order step 1). Acceptance: the file is listed in the `<FEATURE>/evidence/baseline/cycle2-phase0-instructions-read.<ts>.md` artifact written by P0-T6.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full. Acceptance: listed in the P0-T6 artifact.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` in full. Acceptance: both listed in the P0-T6 artifact.
- [x] [P0-T4] Read `.claude/rules/powershell.md` in full. Acceptance: listed in the P0-T6 artifact.
- [x] [P0-T5] Read `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`, `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/remediation-inputs.2026-10-16T04-02.md`, the three review artifacts `code-review.2026-10-16T03-14.md`, `feature-audit.2026-10-16T03-14.md`, and `policy-audit.2026-10-16T03-14.md` in the same folder, and `.claude/rules/plan-acceptance-gates.md` in full. Acceptance: all six listed in the P0-T6 artifact.
- [x] [P0-T6] Write `<FEATURE>/evidence/baseline/cycle2-phase0-instructions-read.<ts>.md` with `Timestamp:`, `Policy Order:` (`CLAUDE.md`, `general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `powershell.md`), and `Files Read:` (those five plus the six files of P0-T5). Acceptance: the file exists with all three fields and eleven listed paths.
- [x] [P0-T7] Minor-audit fail-closed and AC-state check. Run `git ls-files -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/spec.md docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/user-story.md` (expected: no output), `git grep -n -e "^## Acceptance Criteria$" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md` (expected: exactly one line, containing `:58:`), `git grep -c -F -e "- [x] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md` (expected: one line ending `:6`), and `git grep -c -F -e "- [ ] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md` (expected: no output and exit 1, because no unchecked AC line exists). Write `<FEATURE>/evidence/baseline/cycle2-minor-audit-gate.<ts>.md` with the four commands, exit codes, and outputs. Acceptance: neither file is tracked, one `## Acceptance Criteria` line, checked count 6, unchecked count 0. Otherwise stop and report BLOCKED.
- [x] [P0-T8] Git baseline: run `git rev-parse HEAD` (recorded for reference only, not asserted, because the plan file is recommitted), `git merge-base --is-ancestor 7051d8a8d HEAD`, `git diff --name-only 7051d8a8d HEAD -- . ':(exclude)docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931'`, and `git status --porcelain`. Write `<FEATURE>/evidence/baseline/cycle2-git-base.<ts>.md` with each command, its exit code, and its output. Acceptance: the `merge-base --is-ancestor` command exits 0; the `git diff --name-only` command exits 0 and prints nothing, so the commits since `7051d8a8d` changed nothing outside the feature folder; and the porcelain output lists no tracked modification outside `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (an untracked `SCRATCH/` entry is recorded and ignored). If any of these does not hold, stop and report BLOCKED.
- [x] [P0-T9] Line-count baseline. Run `wc -l scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`. Write `<FEATURE>/evidence/baseline/cycle2-line-counts.<ts>.md`. Acceptance: the counts are 499, 426, 297, 160, and 99 in that order; a mismatch is recorded as a deviation and reported before continuing.
- [x] [P0-T10] Presence and absence baseline. With the Glob tool confirm that `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` do not exist. With the Grep tool in count mode search `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` for the regex `OutputType\(\[hashtable\]\)`, the regex `OutputType\(\[pscustomobject\]\)`, the regex `\$null -eq \$check`, and the regex `^function (ConvertFrom-CheckPollOutput|Get-CheckSetVerdict) `; search `scripts` and `tests` for the literal `Test-UnregisteredCheckPollOutput` and the literal `Could not query the checks`; and search each of the four suites for the regex `^\s+It "`. Write `<FEATURE>/evidence/baseline/cycle2-presence-baseline.<ts>.md`. Acceptance: both files absent; counts 2, 3, 1, 2, 0, 0; `It` counts Tests 15, ChecksWait 19, CheckClassification 18, AdditionalFailurePaths 2.
- [x] [P0-T11] Reference inventory for mirrors. Run `git grep -n -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'` and `git grep -n -F -e "Invoke-ReleaseVerificationHelpers" -- . ':(exclude)docs'`. Write `<FEATURE>/evidence/baseline/cycle2-reference-inventory.<ts>.md` with both outputs and the distinct file list of each. Acceptance: the first command's files are exactly `.vscode/tasks.json`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, and `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`; the second command's files are exactly `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, and `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`. Any extra file is recorded and reported to the caller before Phase 1, because it may be a mirror that Decision 1 does not cover.
- [x] [P0-T12] Observe gh before the F2 edit. With the Bash tool run `gh --version`, then `gh pr checks --help`, then `gh pr checks 15 --json bucket 2>&1` (read-only; PR 15 has no checks), then `gh pr checks 948 --json bucket 2>&1` (read-only). Write `<FEATURE>/evidence/baseline/cycle2-gh-observation.<ts>.md` with each command, its exit code, its output verbatim (the help output may be trimmed to the usage line, the flags section, and any exit-code section), and an `Output Summary:` that states the gh version, whether the help lists a `--json` flag, whether the help text mentions an exit code for pending checks, the exit code and text of the PR 15 no-checks output, and the shape of the PR 948 output. Add a `Derivation:` section quoting the three recorded sources named in `## Verified Plan-Time Facts` (gh-source research line 44 of the #841 research file, lines 26-29 of `<FEATURE>/research/2026-10-15-release-flow-all-checks-research.md`, and line 58 of the #658 `issue.md`) together with the PR 15 output, and stating the rule of `## Decisions` item 5. Acceptance: `gh --version` and `gh pr checks --help` exit 0; the help output contains `--json`; the PR 15 call exits non-zero and its output contains `no checks reported`; the PR 948 call either exits 0 with output that, joined, begins with `[` and contains `"bucket"`, or exits non-zero with output that contains `no checks reported`; the `Derivation:` section is present. If any of these does not hold, stop and report BLOCKED so the caller re-plans F2.
- [x] [P0-T13] PowerShell format baseline. Run `git status --porcelain` (before), call `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders = ["scripts/dev-tools", "tests/scripts/dev-tools"]`, and run `git status --porcelain` (after). If the after output lists a tracked path outside `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` that the before output did not, record it as pre-existing formatter drift and restore it with `git checkout -- <path>`, then run `git status --porcelain` a third time. Write `<FEATURE>/evidence/baseline/cycle2-ps-format.<ts>.md`. Acceptance: `EXIT_CODE: 0` (`"ok":true`) and the last porcelain output equals the before output. The success-case observation is the before-and-after porcelain identity, because the tool returns status only.
- [x] [P0-T14] PowerShell analyze baseline: call `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders = ["scripts/dev-tools", "tests/scripts/dev-tools"]`. Write `<FEATURE>/evidence/baseline/cycle2-ps-analyze.<ts>.md` with the `ok` value as `EXIT_CODE` and the summary verbatim. Acceptance: the artifact records `EXIT_CODE` and the summary; no count or finding is asserted.
- [x] [P0-T15] PowerShell test baseline: read `CALL_TS` with `date -u +%Y-%m-%dT%H-%M`, call `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders = ["tests/scripts/dev-tools"]`, and write `<FEATURE>/evidence/baseline/cycle2-ps-test.<ts>.md` whose `Command:` line records the `scan_folders` value. Acceptance: the artifact records `CALL_TS`, the `scan_folders` value, `EXIT_CODE: 0` (`"ok":true`), and the summary verbatim.
- [x] [P0-T16] Local results baseline. Read the root element of `artifacts/pester/pester-junit.xml` and run `date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M` (recorded as `JUNIT_WRITTEN`). Write `<FEATURE>/evidence/baseline/cycle2-local-results-baseline.<ts>.md` with `Timestamp:`, `Command:` (the Read of `artifacts/pester/pester-junit.xml` and the `date -u -r` command), `EXIT_CODE:` (0 when the file was read and the `date -u -r` command exited 0, otherwise that command's non-zero exit code), `BASELINE_TESTS` (root `tests`), `BASELINE_FAILURES` (root `failures`), `BASELINE_ERRORS` (root `errors`), `JUNIT_WRITTEN`, `CALL_TS` from P0-T15, and `Output Summary:`. Acceptance: `EXIT_CODE: 0`, `BASELINE_TESTS` is an integer, `BASELINE_FAILURES` and `BASELINE_ERRORS` equal 0, and `JUNIT_WRITTEN` is greater than or equal to `CALL_TS` (lexicographic comparison of the fixed-width stamps). Otherwise the task stays unchecked and the cause is reported.
- [x] [P0-T17] Local coverage baseline. With the Grep tool locate the literal `sourcefilename="Invoke-FullReleaseFlow.ps1"` in `artifacts/pester/powershell-coverage.xml`, read that `<class>` element with the Read tool, and take its class-level `LINE` counter. Run `date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M` (`COVERAGE_WRITTEN`). Read the CI floor from the greatest `<FEATURE>/evidence/baseline/ps-coverage-main.*.md`. Write `<FEATURE>/evidence/baseline/cycle2-local-coverage-baseline.<ts>.md` with `Timestamp:`, `Command:` (the Grep and Read of `artifacts/pester/powershell-coverage.xml` and the `date -u -r` command), `EXIT_CODE:` (0 when the class element was found and read and the `date -u -r` command exited 0, otherwise non-zero), `BASELINE_COVERED`, `BASELINE_MISSED`, `BASELINE_VALID` (covered plus missed), `BASELINE_PERCENT` (covered / valid x 100, two decimals), `COVERAGE_WRITTEN`, the CI floor percent, and `Output Summary:` stating the local percentage. Acceptance: `EXIT_CODE: 0`, all four numbers are recorded, `COVERAGE_WRITTEN` is greater than or equal to `CALL_TS`, and `BASELINE_PERCENT` is at least the CI floor (94.26). A missing file or entry leaves the task unchecked (never a placeholder value).
- [x] [P0-T18] Python contract baseline: run `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q -p no:cacheprovider`. Write `<FEATURE>/evidence/baseline/cycle2-py-contract.<ts>.md` with the summary line verbatim. Acceptance: exit 0 and the summary line begins `35 passed` (the recorded success-case output in `<FEATURE>/evidence/qa-gates/py-pytest-contract.2026-10-16T01-44.md`); record the count as `BASELINE_PY_PASSED`.

### Phase 1 — Constrained small-path implementation (F1 to F4)

- [x] [P1-T1] Hand off to the small-path implementation engineer. Write `<FEATURE>/evidence/other/cycle2-phase1-handoff.<ts>.md` listing the six paths in `## Writes`, `## Decisions` items 1 to 8, the gh observation outcome from the greatest `cycle2-gh-observation.*.md`, and the rule that the engineer performs P1-T2 to P1-T10 only. Acceptance: the artifact exists and lists exactly the six `## Writes` paths.
- [x] [P1-T2] Create `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` with the Write tool, containing in order: (a) a comment-based help header whose `.SYNOPSIS` reads `Pure check-poll helpers for scripts/dev-tools/Invoke-FullReleaseFlow.ps1.` and whose `.DESCRIPTION` states that the three functions are pure (no external call, filesystem access, network access, or wait), that they live here because the main script stood one line under the 500-line cap (issue #931), and that the file declares no entry-point block and is dot-sourced by `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; (b) two blank lines and `function ConvertFrom-CheckPollOutput` copied verbatim (two blank lines, not one, separate the closing `#>` of the file help header from the first `function` keyword, so PowerShell does not treat the file header as the comment-based help of `ConvertFrom-CheckPollOutput`) from `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` lines 162-194; (c) a blank line and `function Get-CheckSetVerdict` copied verbatim from lines 196-235 except that the line `            $property = if ($null -eq $check) { $null } else { $check.PSObject.Properties['bucket'] }` is replaced by `            $property = $check.PSObject.Properties['bucket']` (F4); (d) a blank line and this function, verbatim:

  ```powershell
  function Test-UnregisteredCheckPollOutput {
      <#
      .SYNOPSIS
          Reports whether failed gh check poll output means no check has registered yet.
      .DESCRIPTION
          gh pr checks exits non-zero with the error text 'no checks reported on
          the <branch> branch' while the pull request head has no check. Any other
          failure text, such as an authentication or network error, returns $false
          so the caller can fail at once instead of retrying.
      .OUTPUTS
          Boolean.
      #>
      [CmdletBinding()]
      [OutputType([bool])]
      param(
          [AllowNull()]
          [AllowEmptyCollection()]
          [Parameter(Mandatory = $true)]
          [object[]]$Output
      )
      foreach ($line in @($Output)) {
          if (([string]$line).Contains('no checks reported')) {
              return $true
          }
      }

      return $false
  }
  ```

  The file ends with a single newline and contains no `param` block at file scope and no entry-point block. Acceptance: reading the file with the Read tool shows the line after the header's closing `#>` and the line after that both blank, followed by `function ConvertFrom-CheckPollOutput {`; with the Grep tool in count mode, the file has 3 matches for the regex `^function `, 0 for the regex `\$null -eq \$check`, 1 for the literal `$property = $check.PSObject.Properties['bucket']`, 1 for the literal `function Test-UnregisteredCheckPollOutput {`, and 0 for the case-insensitive literal `required check`; `wc -l scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` prints a count of at most 150.
- [x] [P1-T3] Extract the helpers from `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` with the Edit tool. First delete the text from the line `function ConvertFrom-CheckPollOutput {` through the closing `}` of `Get-CheckSetVerdict` and the blank line that follows it (original lines 162-236), so the blank line 161 is followed directly by `function Wait-ForPullRequestChecks {`. Then replace the text `)` + newline + blank line + `function Write-StderrLine {` at original lines 42-44 so that, after the `)` that closes the script `param` block and one blank line, these four lines precede a blank line and `function Write-StderrLine {`:

  ```powershell
  # The pure check-poll helpers live in a sibling file so this script stays under
  # the 500-line cap. Dot-sourcing through $PSScriptRoot also resolves them when a
  # Pester suite dot-sources this script.
  . (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.CheckHelpers.ps1')
  ```

  Acceptance: with the Grep tool in count mode on the script, the regex `^function (ConvertFrom-CheckPollOutput|Get-CheckSetVerdict) ` has 0 matches, the literal `. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.CheckHelpers.ps1')` has 1 match, the regex `^function Wait-ForPullRequestChecks ` has 1 match, and the literal `@('pr', 'checks', $PrNumber, '--json', 'bucket')` has 1 match.
- [x] [P1-T4] F1 in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: in `Invoke-GitExe` and `Invoke-GhExe`, replace each `    [OutputType([hashtable])]` line with `    [OutputType([pscustomobject])]`, and replace each `        A hashtable with keys Output (string[]) and ExitCode (int).` line with `        A pscustomobject with properties Output (object[]) and ExitCode (int), built by ConvertTo-CommandResult.`. Acceptance: Grep tool counts on the script: regex `OutputType\(\[hashtable\]\)` 0, regex `OutputType\(\[pscustomobject\]\)` 3 (`ConvertTo-CommandResult` and the two wrappers), literal `A hashtable with keys` 0, literal `A pscustomobject with properties Output (object[]) and ExitCode (int), built by ConvertTo-CommandResult.` 2.
- [x] [P1-T5] F2 code in `Wait-ForPullRequestChecks` of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: replace the three lines `    $registrationAttempt = 1`, `    while ($poll.ExitCode -ne 0) {`, `        if ($registrationAttempt -ge $RegistrationMaxAttempts) {` with these seven lines, leaving the rest of Phase A unchanged:

  ```powershell
      $registrationAttempt = 1
      while ($poll.ExitCode -ne 0) {
          if (-not (Test-UnregisteredCheckPollOutput -Output $poll.Output)) {
              Write-StderrLine -Message "Could not query the checks for PR #$PrNumber (gh exit code $($poll.ExitCode))."
              return 1
          }
          if ($registrationAttempt -ge $RegistrationMaxAttempts) {
  ```

  Acceptance: Grep tool counts on the script: literal `if (-not (Test-UnregisteredCheckPollOutput -Output $poll.Output)) {` 1, literal `Could not query the checks for PR #` 1, literal `Invoke-Sleep -Seconds $RegistrationIntervalSeconds` 1 (unchanged), literal `did not register within the timeout` 1 (unchanged).
- [x] [P1-T6] F2 help text in `Wait-ForPullRequestChecks` of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: replace the Phase A paragraph (original lines 246-251, from `        Phase A (registration): GitHub takes several seconds to register` through `        declaring a registration timeout.`) with:

  ```text
          Phase A (registration): GitHub takes several seconds to register
          workflow checks after a pull request is opened. While the poll
          command fails with the gh error text 'no checks reported', the check
          set has not yet registered; this phase retries up to
          RegistrationMaxAttempts times, sleeping RegistrationIntervalSeconds
          between attempts, before declaring a registration timeout. Any other
          poll failure, such as a gh authentication or network error, returns 1
          at once without sleeping.
  ```

  and replace the four `.OUTPUTS` lines (original lines 276-279, from `        Integer: 0 when at least one check is reported and every bucket is` through `        check.`) with:

  ```text
          Integer: 0 when at least one check is reported and every bucket is
          pass or skipping; 1 on a gh poll failure other than an unregistered
          check set, registration timeout, completion timeout, an unparsable
          result, an unrecognized bucket, or a failing or cancelled check.
  ```

  Line 244 (`The poll queries every check on the pull request head, whether or not branch protection requires it.`) is not edited. Acceptance: Grep tool counts on the script: literal `at once without sleeping.` 1, literal `pass or skipping; 1 on a gh poll failure other than an unregistered` 1, literal `The poll queries every check on the pull request head` 1, case-insensitive literal `required check` 0.
- [x] [P1-T7] F3 test move. With the Write tool create `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` whose content is the current `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` (160 lines) with exactly these changes: the Describe title `Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict` becomes `Invoke-FullReleaseFlow.CheckHelpers.ps1 - Get-CheckSetVerdict`; the Describe title `Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput` becomes `Invoke-FullReleaseFlow.CheckHelpers.ps1 - ConvertFrom-CheckPollOutput`; in both `BeforeAll` blocks the two lines become `        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path` and `        . $script:helpersPath`. Every `It` block is copied byte-identically. Then delete the old file with the Bash command `rm tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`; if that command is denied, stop and report BLOCKED. Acceptance: the Glob tool finds the new file and does not find the old file; Grep tool counts on the new file: regex `^\s+It "` 18, literal `Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path` 2, literal `-ConfirmToken` 0, regex `^Describe "Invoke-FullReleaseFlow.CheckHelpers.ps1 - ` 2.
- [x] [P1-T8] Append to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`, after one blank line, this Describe block verbatim:

  ```powershell
  Describe "Invoke-FullReleaseFlow.CheckHelpers.ps1 - Test-UnregisteredCheckPollOutput" {
      BeforeAll {
          $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path
          . $script:helpersPath
      }

      It "reports true for the gh no-checks message" {
          $output = @("no checks reported on the 'release/full-20260703171500' branch")

          $result = Test-UnregisteredCheckPollOutput -Output $output

          $result | Should -BeTrue
      }

      It "reports true for the gh no-checks message delivered as an error record" {
          $record = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new("no checks reported on the 'release/full-20260703171500' branch"), 'gh', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)

          $result = Test-UnregisteredCheckPollOutput -Output @($record)

          $result | Should -BeTrue
      }

      It "reports false for a gh authentication failure" {
          $output = @('HTTP 401: Bad credentials (https://api.github.com/graphql)')

          $result = Test-UnregisteredCheckPollOutput -Output $output

          $result | Should -BeFalse
      }

      It "reports false for empty output" {
          $result = Test-UnregisteredCheckPollOutput -Output @()

          $result | Should -BeFalse
      }
  }
  ```

  Acceptance: Grep tool counts on the file: regex `^\s+It "` 22, regex `^Describe "` 3, literal `Mock` 0.
- [x] [P1-T9] F2 tests in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: insert, inside Context `registration phase` after the closing `}` of the test `returns failure on registration timeout` and before the Context's closing `    }`, one blank line and these two tests verbatim:

  ```powershell
          It "returns failure at once without sleeping when gh fails with '<FailureText>'" -ForEach @(
              @{ FailureText = 'HTTP 401: Bad credentials (https://api.github.com/graphql)'; FailureExitCode = 1 }
              @{ FailureText = 'To get started with GitHub CLI, please run:  gh auth login'; FailureExitCode = 4 }
              @{ FailureText = 'error connecting to api.github.com'; FailureExitCode = 1 }
          ) {
              $script:failurePoll = @{ Output = @($FailureText); ExitCode = $FailureExitCode }
              Mock -CommandName Invoke-GhExe -MockWith {
                  param([string[]]$GhArgs)
                  $null = $GhArgs
                  return $script:failurePoll
              }
              Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
              Mock -CommandName Write-StderrLine -MockWith {
                  param([string]$Message)
                  $script:capturedMessage = $Message
              }

              $result = Wait-ForPullRequestChecks -PrNumber '291'

              $result | Should -Be 1
              $script:capturedMessage | Should -Match "Could not query the checks for PR #291"
              Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
              Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
          }

          It "keeps retrying while gh reports no registered checks as an error record" {
              $script:notRegistered = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new("no checks reported on the 'release/full-20260703171500' branch"), 'gh', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)
              Mock -CommandName Invoke-GhExe -MockWith {
                  param([string[]]$GhArgs)
                  $null = $GhArgs
                  $script:ghCallCount++
                  if ($script:ghCallCount -le 2) {
                      return @{ Output = @($script:notRegistered); ExitCode = 1 }
                  }
                  return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
              }
              Mock -CommandName Invoke-Sleep -MockWith {
                  param([int]$Seconds)
                  $null = $Seconds
                  $script:sleepCallCount++
              }

              $result = Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 5 -RegistrationIntervalSeconds 1

              $result | Should -Be 0
              Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
              Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
          }
  ```

  The three existing Phase A tests (`waits through the registration race then merges`, `returns failure on registration timeout`, `invokes the sleep seam between registration polls and between completion polls`) are not edited. Acceptance: Grep tool counts on the file: regex `^\s+It "` 21, literal `returns failure at once without sleeping when gh fails with` 1, literal `keeps retrying while gh reports no registered checks as an error record` 1, literal `return @{ Output = @('no checks reported'); ExitCode = 1 }` 1 (the unchanged timeout test).
- [x] [P1-T10] F1 test in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`: insert, inside Context `helpers` after the closing `}` of the test `accepts an empty array as Output without throwing` and before the Context's closing `    }`, one blank line and this test verbatim:

  ```powershell
          It "declares the command-result output type on '<CommandName>'" -ForEach @(
              @{ CommandName = 'Invoke-GitExe' }
              @{ CommandName = 'Invoke-GhExe' }
          ) {
              $expected = (Get-Command -Name ConvertTo-CommandResult).OutputType[0].Type

              $declared = @((Get-Command -Name $CommandName).OutputType)

              $declared.Count | Should -Be 1
              $declared[0].Type | Should -Be $expected
          }
  ```

  Acceptance: Grep tool counts on the file: regex `^\s+It "` 16, literal `declares the command-result output type on` 1.
- [x] [P1-T11] Structure check. Run `wc -l scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`. With the Grep tool in count mode search the four suites for `New-TemporaryFile`, `Set-Content`, and `Out-File`, and search both production files for the regex `\$null -eq \$check`. Write `<FEATURE>/evidence/regression-testing/cycle2-structure.<ts>.md` with all counts. Acceptance: the main script count is at most 450 (plan-time expectation 435), the helper file count is at most 150, every test file count is at most 500, AdditionalFailurePaths is still 99, the temporary-file cmdlet counts are 0, and the null-guard count is 0 in both production files.
- [x] [P1-T12] Post-edit reference search. Run `git grep -n -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'` and `git status --porcelain`. With the Grep tool search `.claude`, `.github`, `.codex`, `.agents`, `extensions`, `packages`, `config`, and `.vscode` for the literal `CheckClassification.Tests` and the literal `Invoke-FullReleaseFlow.CheckHelpers`. Write `<FEATURE>/evidence/regression-testing/cycle2-reference-search.<ts>.md`. Acceptance: every file in the `git grep` output is either in the P0-T11 file list or is one of the two new files `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` (these appear only after the orchestrator has committed them); `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` does not appear in the `git grep` output; each of the two new files appears either in the `git grep` output or as a `??` entry of the porcelain output; and the Grep tool finds 0 matches for both literals in the eight searched directories.
- [x] [P1-T13] Run the PowerShell suites after the edits: read `AFTER_CALL_TS` with `date -u +%Y-%m-%dT%H-%M`, call `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders = ["tests/scripts/dev-tools"]`, and write `<FEATURE>/evidence/regression-testing/cycle2-pester-after-edit.<ts>.md` with `AFTER_CALL_TS`, the `scan_folders` value, the `ok` value as `EXIT_CODE`, and the summary verbatim. Acceptance: `EXIT_CODE: 0`. On a non-zero result, read `artifacts/pester/pester-junit.xml` for the failing testcase, fix the cause inside the `## Writes` files only, and rerun this task.
- [x] [P1-T14] Confirm the new tests in the local results. Read the root of `artifacts/pester/pester-junit.xml`, run `date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M` (`JUNIT_AFTER_WRITTEN`), and with the Grep tool in count mode search the file for the literals `returns failure at once without sleeping when gh fails with`, `keeps retrying while gh reports no registered checks as an error record`, `declares the command-result output type on`, `reports true for the gh no-checks message`, `reports false for a gh authentication failure`, `reports false for empty output`, and `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`; read each matching `testcase` element for its status. Write `<FEATURE>/evidence/regression-testing/cycle2-pester-junit-after.<ts>.md`. Acceptance: `JUNIT_AFTER_WRITTEN` is at least `AFTER_CALL_TS`; root `failures` and `errors` are 0; root `tests` equals `BASELINE_TESTS` from the greatest `cycle2-local-results-baseline.*.md` plus 10; the counts are 3, 1, 2, 2 (the plain-string and error-record tests share the prefix), 1, 1, and 0; and every matched testcase has no `failure` or `error` child.

### Phase 2 — Final QC loop

Loop rule: run P2-T1 through P2-T5 in order. If any step fails or changes a tracked file, fix the cause inside the `## Writes` files and restart from P2-T1 until one pass completes with every step clean. A tracked path outside `<FEATURE>` and outside `## Writes` that a step changes is pre-existing drift already recorded by P0-T13: restore it with `git checkout -- <path>` and record a deviation. Each pass writes new artifacts with new `<ts>` stamps; later tasks consume the greatest stamp.

- [x] [P2-T1] PowerShell format: record `git status --porcelain` (before), call `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders = ["scripts/dev-tools", "tests/scripts/dev-tools"]`, record `git status --porcelain` (after), and run `git hash-object scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` both before and after the call (it prints one 40-character object id per file and works for untracked files, which porcelain status cannot observe for content changes). Write `<FEATURE>/evidence/qa-gates/cycle2-ps-format.<ts>.md`. Acceptance: `EXIT_CODE: 0`, the before and after porcelain outputs are identical, and the before and after `git hash-object` outputs are identical line for line, which shows the formatter changed none of the five files; a difference means the formatter repaired a file: apply the Loop rule.
- [x] [P2-T2] PowerShell analyze: call `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and `scan_folders = ["scripts/dev-tools", "tests/scripts/dev-tools"]`. Write `<FEATURE>/evidence/qa-gates/cycle2-ps-analyze.<ts>.md`. Acceptance: `EXIT_CODE: 0` (`"ok":true`) and the summary recorded verbatim; no diagnostic count is asserted.
- [x] [P2-T3] PowerShell tests with coverage: read `FINAL_CALL_TS` with `date -u +%Y-%m-%dT%H-%M`, call `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders = ["tests/scripts/dev-tools"]`, and write `<FEATURE>/evidence/qa-gates/cycle2-ps-test.<ts>.md` whose `Command:` line records the `scan_folders` value and which states that the full-suite run of record is the PR CI job `poshqc / PowerShell QC`. Acceptance: `FINAL_CALL_TS`, the `scan_folders` value, `EXIT_CODE: 0`, and the summary are recorded.
- [x] [P2-T4] Local final results and per-file coverage. Read the root of `artifacts/pester/pester-junit.xml`. With the Grep tool locate the literals `sourcefilename="Invoke-FullReleaseFlow.ps1"` and `sourcefilename="Invoke-FullReleaseFlow.CheckHelpers.ps1"` in `artifacts/pester/powershell-coverage.xml` and read each `<class>` element's class-level `LINE` counter. Record `FINAL_JUNIT_WRITTEN` and `FINAL_COVERAGE_WRITTEN` with `date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M` and `date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M`. Write `<FEATURE>/evidence/qa-gates/cycle2-local-results-final.<ts>.md` with `Timestamp:`, `Command:` (the Read of `artifacts/pester/pester-junit.xml`, the Grep and Read of `artifacts/pester/powershell-coverage.xml`, and the two `date -u -r` commands), `EXIT_CODE:` (0 when both files were read, both class elements were found, and both `date -u -r` commands exited 0, otherwise non-zero), `FINAL_TESTS`, `FINAL_FAILURES`, `FINAL_ERRORS`, `BASELINE_TESTS`; for the script `SCRIPT_COVERED`, `SCRIPT_MISSED`, `SCRIPT_VALID`, `SCRIPT_PERCENT`; for the helper file `HELPER_COVERED`, `HELPER_MISSED`, `HELPER_VALID`, `HELPER_PERCENT`; `COMBINED_COVERED`, `COMBINED_MISSED`, `COMBINED_VALID`, `COMBINED_PERCENT` (sums of the two files; percent = covered / valid x 100, two decimals); the baseline `BASELINE_COVERED`, `BASELINE_MISSED`, `BASELINE_VALID`, `BASELINE_PERCENT` from the greatest `cycle2-local-coverage-baseline.*.md`; the CI floor 94.26 from the greatest `ps-coverage-main.*.md`; the delta `COMBINED_PERCENT - BASELINE_PERCENT`; and an `Output Summary:` stating `SCRIPT_PERCENT`, `HELPER_PERCENT`, and `COMBINED_PERCENT` numerically. Acceptance: `EXIT_CODE: 0`; both written stamps are at least `FINAL_CALL_TS`; `FINAL_FAILURES` and `FINAL_ERRORS` are 0; `FINAL_TESTS` equals `BASELINE_TESTS` plus 10; the helper class element exists; `SCRIPT_PERCENT` is at least 94.26; `HELPER_PERCENT` is at least 94.26 and `HELPER_MISSED` is 0; `COMBINED_PERCENT` is at least `BASELINE_PERCENT`; `COMBINED_MISSED` is at most `BASELINE_MISSED`. If any coverage value is unavailable or below its floor, the task stays unchecked and the outcome is remediation-required.

  Approved amendment (orchestrator, 2026-10-16), recorded in `<FEATURE>/evidence/qa-gates/cycle2-local-results-final.2026-10-16T05-41.md`: the MCP test tool runs the installed extension's PoshQC, whose coverage allow-list omits the helper file, so the helper class row is absent locally. The executor first attempts the in-repo PoshQC module directly (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root <worktree> -ScanFolders @('tests/scripts/dev-tools')`). If that run yields a helper row, acceptance is: failures 0, errors 0, tests = baseline + 10, `SCRIPT_PERCENT` >= 94.26 with `SCRIPT_MISSED` <= `BASELINE_MISSED`, `HELPER_PERCENT` >= 94.26, and `COMBINED_PERCENT` >= 95.63. If it yields no helper row (or the hook blocks the direct command and the MCP tool is used instead), acceptance is the script row only (same test and script conditions) plus a `HELPER_COVERAGE` line stating that helper coverage is measured in PR CI only, and P2-T9 carries the S9 helper-coverage instruction. Outcome: the direct command was rejected by the PreToolUse hook with a false `PR_AUTHOR_SKILL_BLOCKED` message; the MCP rerun (`cycle2-ps-test.2026-10-16T05-41.md`) yielded no helper row; the fallback acceptance passed (665 tests, 0 failures, 0 errors, script 131/138 = 94.93 percent, missed 7).
- [x] [P2-T5] Python contract regression: run `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q -p no:cacheprovider`. Write `<FEATURE>/evidence/qa-gates/cycle2-py-contract.<ts>.md` with the summary line verbatim and `Coverage: not applicable, no Python file changed in cycle 2`. Acceptance: exit 0 and the passed count in the summary line equals `BASELINE_PY_PASSED` from the greatest `cycle2-py-contract.*.md` in `<FEATURE>/evidence/baseline/` (expected 35), with no failed count.
- [x] [P2-T6] Evidence-location check: run `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`. Write `<FEATURE>/evidence/qa-gates/cycle2-evidence-locations.<ts>.md`. Acceptance: exit 0 and no reported path (the reviewer's recorded run in `<FEATURE>/policy-audit.2026-10-16T03-14.md`, Evidence Location Compliance, shows this success shape).
- [x] [P2-T7] Loop disposition: write `<FEATURE>/evidence/qa-gates/cycle2-qc-loop-pass.<ts>.md` naming the artifacts written by P2-T1 to P2-T6 in the final pass and the output of `git status --porcelain` run after P2-T6. Acceptance: every final-pass artifact has `EXIT_CODE: 0`, P2-T4 met its acceptance, and the porcelain output lists no path outside `## Writes` and `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (an untracked `SCRATCH/` entry is recorded and ignored).
- [x] [P2-T8] Scope and AC-state check. Run `git diff --no-renames --name-status 7051d8a8d -- . ':(exclude)docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931'`, `git status --porcelain`, `git diff --name-only 7051d8a8d -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`, `git grep -c -F -e "- [x] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`, and `git grep -c -F -e "- [ ] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`. Write `<FEATURE>/evidence/qa-gates/cycle2-scope.<ts>.md`. Acceptance: the union of the diff paths and the `??` paths of the porcelain output outside the feature folder (excluding `SCRATCH/`) is exactly the six `## Writes` paths, with the CheckClassification file reported as `D`; the `issue.md` diff prints nothing and the porcelain output has no entry for `issue.md`; the checked-count command prints one line ending `:6`; the unchecked-count command prints nothing and exits 1.
- [x] [P2-T9] Verification and handoff: write `<FEATURE>/evidence/qa-gates/cycle2-verification.<ts>.md` stating F1, F2, F3, and F4 as resolved with the task and artifact for each; the numeric baseline and final values from the greatest `cycle2-local-results-final.*.md` (tests, `SCRIPT_PERCENT`, `HELPER_PERCENT`, `COMBINED_PERCENT`); the sentence `AC1 to AC6 remain checked; no criterion was added`; and the S9 instruction for the new head that replaces the counts in `<FEATURE>/evidence/qa-gates/ac6-pr-ci-record.2026-10-16T03-38.md` step 5: passed testcases with classname `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` equal 23, passed testcases with classname `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` equal 22, no testcase has classname `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`, the script's per-file line percentage is at least 94.26, and the `Invoke-FullReleaseFlow.CheckHelpers.ps1` class is present with a line percentage of at least 85. Quote the literal `22 CheckHelpers tests` in the file. Acceptance: the file exists, contains each named item and the literal `22 CheckHelpers tests`, and its numbers equal those in the P2-T4 artifact. The ChecksWait figure 23 is the 19 existing test cases plus the 4 added by P1-T9; the CheckHelpers figure 22 is the 18 moved tests plus the 4 added by P1-T8. The earlier artifact `ac6-pr-ci-record.2026-10-16T03-38.md` is not edited: `git diff --name-only 7051d8a8d -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/qa-gates/ac6-pr-ci-record.2026-10-16T03-38.md` prints nothing and `git status --porcelain` lists no entry for that path.

  Approved amendment S9 sentence (P2-T4 fallback), written verbatim into the verification file: `HELPER_COVERAGE is measured in PR CI only: at S9 the poshqc-test-results coverage report of the job poshqc / PowerShell QC must contain the Invoke-FullReleaseFlow.CheckHelpers.ps1 class with a line percentage of at least 94.26 and 0 missed lines; if the class is absent or below that floor, S9 is not green and the item returns to remediation.` This supersedes the 85 percent helper figure above for S9.
