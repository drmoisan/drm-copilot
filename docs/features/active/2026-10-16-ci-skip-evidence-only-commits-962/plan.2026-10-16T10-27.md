# 2026-10-16-ci-skip-evidence-only-commits (Plan)

- **Issue:** #962
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Ready for executor preflight (revision 4: coordinator decisions 1 and 2 of 2026-10-16 applied as a minimal delta to the plan that cleared preflight round 4; the dependency gate becomes a dependency record, `_poshqc.yml` gating is specified for both shapes, and the D14 follow-ups a to d are added; edit points re-derived against the branch head `e07e235d531a7510624988f152a7e7c32ec0a350`, which already contains `origin/main` at `fa27cd5edcb39a5d5f63054c3e38cefef18ab316`)
- **Version:** 1.4
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). The acceptance-criteria source is `spec.md`, section `## Acceptance Criteria`, AC-1 to AC-38 (AC-35 to AC-38 are the D14 follow-ups a to d). AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 are CI-dependent. `user-story.md` is absent by design.
- **Design inputs:** `spec.md` (Decisions D1 to D9, `## Proof Procedure`, `## Out of Scope`), `research/research.2026-10-16T14-39.md` (cited as "research §n"), and `issue.md` for context.
- **Branch:** `bug/ci-skip-evidence-only-commits-962`. Every push is `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` (fast-forward only). No force push, no `--amend`, no rebase, no deletion of any repository file or branch.

**Fail-closed evidence rule:** PowerShell is the main production code language this plan changes; the bash shell-QC library and wrapper and one bats suite change for the D14 follow-ups c and d (PD-19 to PD-21; local static evidence plus CI test and coverage evidence); one existing Python test file is adjusted (PD-13) and runs the Python toolchain stages; the workflow YAML files are linted with actionlint. Baseline artifacts are produced in Phase 0, expect-fail regression artifacts in Phase 1, pass artifacts in Phases 2 to 5, final-QA and coverage artifacts in Phase 6, and CI proof artifacts in Phase 7. If any required baseline, QA, or coverage artifact is missing or incomplete, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** every evidence-producing task names its artifact path. No evidence-backed task is checked off without its artifact on disk carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## 1. Terms

- `FEATURE` denotes `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`.
- `SCRATCH` resolves to `<session scratchpad>/issue-962/`. Every scratch file this plan names lives under `SCRATCH/tools/` (the launcher and the recipes) or `SCRATCH/stage/` (the launcher's staged copies). Artifacts record the literal token `SCRATCH`, never a host path. In Bash command text the executor substitutes the forward-slash form of the resolved path for `SCRATCH`.
- Evidence paths are `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. `<timestamp>` is the UTC write time read from the host clock immediately before the write (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm` or `date -u +%Y-%m-%dT%H-%M`), never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- `CR-<NAME>` is a command recipe in section 5. `cr-<name>.txt` is its scratch file under `SCRATCH/tools/` (PowerShell 7 source stored with a `.txt` extension). `SCRATCH/tools/run-cr.sh` is the POSIX launcher of section 5; a CR is always run as `sh SCRATCH/tools/run-cr.sh cr-<name> <arguments>` (rule 3).
- Named lists (comma-separated when passed to a CR):
  - `LIST-NEW-TESTS` = `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
  - `LIST-CI-TESTS` = `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`
  - `LIST-NEW-PS` = `scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1` followed by `LIST-NEW-TESTS` (the six new PowerShell files).
  - `LIST-EDITED-SUITES` = the `LIST-EDITED-SUITES:` line of the latest `FEATURE/evidence/other/edit-points.*.md` (derived by P0-T9: `tests/scripts/workflows/CiWorkflow.Tests.ps1` when `A2-APPLICABLE: yes`, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` when `POSHQC-SHAPE: sharded`; the list is empty on the current head, where neither applies, and an empty list contributes no entry to a comma-joined argument because every recipe drops blank entries).
  - `LIST-PS-WRITTEN` = `LIST-NEW-PS` followed by `LIST-EDITED-SUITES` (every PowerShell file this plan writes).
  - `LIST-SHELL-WRITTEN` = `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh`, `tests/shell/test_shell_qc_commands.bats` (the D14-c and D14-d files). Because the first two paths contain a token that rule 4 forbids in Bash command text, this list is never passed on a command line: CR-SHELL-STATIC and CR-SCOPE carry it inside the recipe file, and git commands name those two files through the pathspecs `scripts/*/shell_qc_lib.sh` and `scripts/*/shell-qc.sh` (each matches exactly one tracked file in the current tree).
  - `LIST-EXISTING-SUITES` = the `LIST-EXISTING-SUITES:` line of the latest `FEATURE/evidence/other/edit-points.*.md` (derived mechanically by CR-INVENTORY in P0-T9: every `tests/scripts/workflows/*.Tests.ps1` present after the merge, every other `*.Tests.ps1` under `tests/` whose text names one of the seven files of `LIST-WORKFLOWS` by its `.github/workflows/` path, and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, de-duplicated and sorted).
  - `LIST-PY-WORKFLOW-TESTS` = `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (space-separated; the Python suites that read `.github/workflows/`; only the first is edited, by A1 of section 7).
  - `LIST-WORKFLOWS` = `.github/workflows/ci.yml,.github/workflows/_quality-checks.yml,.github/workflows/_security-scan.yml,.github/workflows/_build-check.yml,.github/workflows/_shell-coverage.yml,.github/workflows/_drm-copilot-extension-tests.yml,.github/workflows/_poshqc.yml`
  - `SCAN-BASE` = `tests/scripts/workflows,tests/scripts/claude-lib/ci-gate`; `SCAN-FINAL` = `tests/scripts/ci,tests/scripts/workflows,tests/scripts/claude-lib/ci-gate`.
  - `PATTERNS-UNIT` = `*(AC-1)*,*(AC-2)*,*(AC-3)*,*(AC-4)*,*(AC-5)*,*(AC-6)*,*(AC-7)*,*(AC-8)*,*(AC-9)*,*(AC-10)*,*(AC-11)*,*(AC-12)*,*(AC-13)*,*(AC-14)*,*(AC-15)*,*(AC-16)*,*(AC-17)*`
  - `PATTERNS-WORKFLOW` = `*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*`
  - `PATTERNS-PARSER` = `returns success when a check is skipping (skipping is non-blocking),returns pending for an empty check array with -RequireWorkflow CI,returns pending when the only CI checks are skipping`

## 2. Rules binding on every task

1. **Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, followed by the command output with host paths redacted (rule 2). When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command and each later command's exit code is recorded on its own labelled line. An artifact whose expected exit code is non-zero also carries `ExpectedExitCode: 1`. A PoshQC MCP call records `EXIT_CODE: 0` for `MCP_CALL: returned` and `EXIT_CODE: 1` for `MCP_CALL: error <message>`; that value implies no count, percentage, or finding. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or an account name. The worktree root is written as `<WORKSPACE_ROOT>` and scratch paths as `SCRATCH/...`.
3. **Command route (decided once by P0-T4).** The worktree isolation guard refuses any Bash command text that contains the token `pwsh`, and the executor has no PowerShell tool, so a CR never runs as a direct `pwsh` command. Every CR runs from the worktree root through the Bash tool as `sh SCRATCH/tools/run-cr.sh cr-<name> <arguments>`. The launcher `SCRATCH/tools/run-cr.sh` (section 5) copies `SCRATCH/tools/cr-<name>.txt` to `SCRATCH/stage/cr-<name>.ps1` with `cp` and then executes that copy with PowerShell 7 (`-NoProfile -NonInteractive -File`), passing the arguments through unchanged and returning the recipe's exit code. If P0-T4 observes a refusal or a missing interpreter, it records `CR-ROUTE: BLOCKED` with the refusal or launcher text and execution stops. `git` runs directly through the Bash tool. The executor does not call `gh`, `grep`, or `actionlint` directly, and calls `sh` only in the launcher form above; `actionlint`, `poetry install`, and `poetry run python` run inside recipes, and `poetry run black`, `poetry run ruff`, `poetry run pyright`, and `poetry run pytest` run directly (allowlisted).
4. **Bash command text.** One command per call: no `&&`, no `;`, no `cd`, no heredoc, and none of the tokens `pwsh`, `bash`, or `wsl` anywhere in the command text (the worktree isolation guard refuses them; these names appear only inside `run-cr.sh`, inside recipe files, and inside repository files edited with Edit). A path containing such a token is named in git commands through a pathspec glob (`scripts/*/shell_qc_lib.sh`, `scripts/*/shell-qc.sh`) and inside recipes as a literal. A search pattern that begins with `-` is passed through `-e`. The launcher file is written with LF line endings.
4a. **No PowerShell scratch file is written with Write or Edit (coordinator directive for this item).** The executor writes exactly two kinds of scratch file with Write: `SCRATCH/tools/run-cr.sh` and the recipe files `SCRATCH/tools/cr-<name>.txt`. No `.ps1`, `.psm1`, or `.psd1` file under `SCRATCH` is created or changed with Write or Edit. The only `.ps1` files under `SCRATCH` are the staged copies `SCRATCH/stage/cr-<name>.ps1`, which the launcher creates with `cp` at run time; nobody edits them, and a recipe change is made in its `.txt` file only.
5. **PoshQC MCP results carry no output.** `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` run as toolchain stages (P6-T1, P6-T2, P6-T4) and their record is the call disposition plus a tree observation. No task reads a count, a percentage, or a finding from an MCP result; every asserted number is read from CR output. `mcp__drm-copilot__run_poshqc_test` overwrites `artifacts/pester/powershell-coverage.xml`, so it never runs between CR-PESTER-COV and CR-COV-FILES.
6. **Success-output observation rule.** The Phase 0 run of each CR is the reference observation. Before a later task asserts a CR literal, a Phase 0 artifact (or, for CRs that cannot pass at baseline, the first passing run) must show that literal on a successful run. If a named literal is absent from a successful run, record the observed output and stop BLOCKED; do not substitute a different literal.
7. **Hook denials.** If any hook denies a Write, Edit, or Bash call, record the denial text in the task's artifact and stop BLOCKED. Never work around a hook, never delete hook state, never reset a budget file. This plan writes two production PowerShell files (`scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`), below the direct-mode threshold of `.claude/hooks/enforce-powershell-batch-budget.ps1`; test files and scratch files outside the worktree root are not counted.
8. **Test purity.** No file under `tests/` written by this plan contains `Start-Process`, `Start-Sleep`, `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `$env:TMP`, `Invoke-WebRequest`, `Invoke-RestMethod`, `Set-Content`, `Out-File`, `New-Item`, or a line beginning `Mock git` or `Mock gh` (bare or quoted), because `.claude/hooks/check-powershell-test-purity.ps1` denies such writes and AC-17 forbids temporary files and process starts. Fakes are test-local scriptblocks passed through `-GhInvoker`, `-GitInvoker`, `-OutputWriter`, and `-ReadVariable`. Cmdlet mocks of `Add-Content` and `Write-Information` are permitted in `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` (they are not executables). Tests read committed repository files only through paths built from `$PSScriptRoot` with `Join-Path`.
9. **PowerShell syntax.** `scripts/powershell/PoshQC/settings/pssa.settings.psd1` lines 8-12 enforce `PSUseCompatibleSyntax` for 5.1 and 7.6: no ternary `? :`, no `??`, no `?.`, no `&&`/`||` pipeline chains. `Write-Host` is prohibited (line 26); use `Write-Information`. Every new file is 500 lines or fewer.
10. **No Python or bash for the decision logic.** No `.py`, `.sh`, or `.bats` file is added under `scripts/ci/` or `tests/scripts/ci/`.
11. **Commit form (every phase boundary).** In order: `git add -- <paths named by the task>`; `git commit -m "<subject>" -m "<attribution trailer required by the executing session>"`; `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/ci-skip-evidence-only-commits-962`. A rejected push stops the task BLOCKED. The commit task writes `FEATURE/evidence/other/commit-phase-<N>.<timestamp>.md` after the push and sets its own plan checkbox after the observation; both are committed by the next phase's commit task.
12. **Untracked tool output.** `scripts/dev-tools/run-actionlint.ps1` downloads `actionlint` into `tools/actionlint/bin/` when the binary is not on PATH (lines 26-27, 151-153), and `.gitignore` does not ignore `tools/`. A porcelain line `?? tools/` is expected after the first actionlint run, is never staged, and is excluded from every porcelain assertion. Nothing under `tools/` is deleted.
13. **Scope boundary.** The complete repository write set is `## Files Written` (frozen to this plan plus the D14 follow-ups a to d). Recorded only, not fixed here: the CI `actionlint` job cited in the read-only `.github/instructions/github-actions.instructions.md` (spec Out of Scope item 1), and the PowerShell `CoveragePercentTarget = 0` (owned by #953). Policy documents under `.claude/rules/` and `.github/instructions/` are read-only. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, its bundle mirror, `.claude/skills/orchestrate/SKILL.md`, and `.claude/skills/parallel-orchestrate/SKILL.md` are not edited (D4).
14. **AC check-off.** The executor changes `- [ ]` to `- [x]` for an AC in `FEATURE/spec.md` only in the task named for it in section 4, after that task's acceptance condition holds, and changes no criterion text (`.claude/skills/acceptance-criteria-tracking/SKILL.md`). AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 stay unchecked until Phase 7. The criterion-text amendments of PD-22 were made by the planning agent in revision 4, before execution.
15. **Pester runner and CI job.** Every Pester acceptance condition in this plan is observed in a local run through CR-PESTER-LIST or CR-PESTER-COV on the executor's Windows host. The CI job that runs the same suites is `poshqc / PowerShell QC` on `windows-latest` (in the unsharded shape that job runs every suite itself; in the sharded shape of #953 the suites execute in the `poshqc-shard` matrix that this aggregator requires, and the coverage report is merged there); PowerShell coverage is produced only in that job. No acceptance condition in this plan relies on `poshqc / PowerShell hook suites (Linux)` or on `ubuntu-latest` for Pester or for coverage. Each Pester task below names this job as `CI job: poshqc / PowerShell QC (windows-latest)`.
16. **Python scope and coverage.** The only Python file this plan writes is the test file `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (PD-13). No Python production file changes, and test files are excluded from coverage measurement by policy, so no Python coverage threshold applies and no Python coverage command is run; the Python stages are format (`black --check`), lint (`ruff check`), type check (`pyright`), and test (`pytest`), each recorded with its success literal. The CI job that runs these checks is `quality-checks7 / Code Quality & Tests` (four Python versions on `ubuntu-latest`).
17. **Re-integration when `origin/main` advances (coordinator decision 1).** Execution never halts because #952 or #953 is absent. If `origin/main` gains #952 (a `merge_group` trigger in `ci.yml`) or #953 (the `poshqc-shard` and `poshqc-static` jobs in `_poshqc.yml`) at any point before this item's pull request merges, the following conditional block runs; it is a recorded re-integration, not a halt, and it writes `FEATURE/evidence/other/reintegration.<timestamp>.md` with the output of every step:
    - RI-1 (orchestrator): `git fetch origin`, then `git merge --no-ff --no-edit origin/main` (no rebase, no force push). A conflict in `.github/workflows/_poshqc.yml`, `.github/workflows/ci.yml`, `.github/workflows/README.md`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, or `tests/scripts/workflows/CiWorkflow.Tests.ps1` is resolved by `git checkout --theirs -- <path>` for each conflicted path of that list, the merge is committed, and the edits of this plan for that path are re-applied in RI-3; a conflict in any other path runs `git merge --abort` and stops BLOCKED with the paths recorded. The merge is pushed per rule 11.
    - RI-2 (executor): re-run P0-T5 (record) and P0-T9 (edit points), which select the shape and `A2-APPLICABLE` for the new head.
    - RI-3 (executor): for #953, re-run P4-T6 (G6 in the shape now recorded, A4 and A4C when sharded); for #952, re-run P4-T7 (G7 when it was taken from `origin/main`, and A2 when applicable); for a README conflict, re-run P5-T1.
    - RI-4 (executor): re-run P4-T11, P4-T12, P4-T13, P4-T14, P4-T15, P5-T2 (when RI-3 re-ran P5-T1), and then the Phase 6 loop from P6-T1, each writing new artifacts.
    - RI-5 (executor): commit and push per rule 11 with the subject `ci(962): re-integrate origin/main and re-apply the change-scope gating`, recording the commit in the re-integration artifact.
    - RI-6 (orchestrator, when Phase 7 has started): re-run P7-T2 onward for the new head, because the new merge is not allowlisted and starts a full run.
18. **Shell evidence (D14-c and D14-d, Option A).** The executor cannot run bash, wsl, or bats in this worktree. Local shell evidence is CR-SHELL-STATIC: structural checks of `LIST-SHELL-WRITTEN`, plus `shellcheck` and `shfmt -d` on the two scripts when those tools are on PATH (otherwise `SHELL-TOOL-ABSENT:` lines record that the lint stage is CI-only). Bats test results and kcov coverage are CI evidence, read by the orchestrator in P7-T4 from the `shell-coverage / Shell Coverage (Bats + kcov)` job of the first full PR run. The fail-before evidence for the new bats tests is the exception dossier of P1-T8.

## 3. Decisions fixed by this plan

- **PD-1 (dependency record, AC-30; revised by coordinator decision 1).** #952 and #953 are recorded, not awaited. Each token is an anchored extended regular expression searched with `git grep -c -E -e '<regex>'` (git grep has no `-x`; the `^` and `[[:space:]]*$` anchors make the match whole-line, and `[[:space:]]*` tolerates a trailing carriage return); git grep exits 1 with no output when a pattern has no match, and that outcome is recorded as `absent`, not as a failure. #952 is present when `origin/main:.github/workflows/ci.yml` has a line matching `^  merge_group:[[:space:]]*$`. #953 is present when `origin/main:.github/workflows/_poshqc.yml` has a line matching `^  poshqc-shard:[[:space:]]*$` and a line matching `^  poshqc-static:[[:space:]]*$`. The check `^    name: PowerShell QC[[:space:]]*$` is a retention check of the required job name and matches in both shapes. At the time of this revision (orchestrator observation 2026-10-16T20:47Z) all three presence tokens are absent from `origin/main` at `fa27cd5edcb39a5d5f63054c3e38cefef18ab316`, the retention token is present, `origin/bug/ci-merge-queue-for-main-952` is at `547e18d7b81037a95ab0dede12e91056f2a6e504`, and `origin/bug/pester-profiler-coverage-953` is at `7558c7e42ec8c8955cb5f9997cca41afc6e3b797`. P0-T5 records the values it observes, which may differ. Integration is `git merge --no-ff --no-edit origin/main`; when the branch already contains `origin/main` (true at revision time, through merge commit `e07e235d531a7510624988f152a7e7c32ec0a350`), git prints `Already up to date.` and that state is recorded instead of a new merge commit.
- **PD-2 (edit points re-derived).** P0-T9 re-derives the job and step inventory of the head mechanically (CR-INVENTORY), records `POSHQC-SHAPE:` (`main` for the job set `poshqc,poshqc-linux-hooks`, `sharded` for `poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static`) and `A2-APPLICABLE:`, and stops BLOCKED on any of: B1 `POSHQC-SHAPE: unknown`; B2 in the sharded shape, the `poshqc` job has no job-level `if:` equal to `always()` or `${{ always() }}`, or, in the main shape, the `poshqc` job has any job-level `if:`; B3 in the sharded shape, the `poshqc` job does not have exactly one step whose name begins `Require` (not applicable in the main shape); B4 any of the steps `Install dependencies` and `Upload coverage to Codecov` (in `_quality-checks.yml`) or `Build kcov from source` (in `_shell-coverage.yml`) is absent; B5 any of the nine `ci.yml` caller jobs of research N2 is absent; B6 in the sharded shape, the A4 target line or the A4C target line of section 7 is not present exactly once in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (not applicable in the main shape, where both counts are recorded and expected to be 0); B7 the A2 target line and the A2B anchor line of section 7 are not both present exactly once or both absent in `tests/scripts/workflows/CiWorkflow.Tests.ps1` (both present once gives `A2-APPLICABLE: yes`; both absent gives `A2-APPLICABLE: no`). CR-INVENTORY prints one `EDIT-TARGET-<id>:` line per target with the exact-line match count and, for a count other than 1, one `EDIT-TARGET-<id>-CANDIDATE:` line per line carrying the target's anchor text; a B6 or B7 stop records those lines as the observed text. B6 and B7 exist because the #952 and #953 branches were still receiving commits when this plan was revised.
- **PD-3 (pre-existing suite failures).** If a suite in `LIST-EXISTING-SUITES` fails at baseline (P0-T10), execution stops BLOCKED with `PREEXISTING_SUITE_FAILURE`, because D6 forbids editing those suites for reasons other than #962 gating and AC-26 requires them to pass (spec Out of Scope item 4).
- **PD-4 (seam contract).** `-GhInvoker` and `-GitInvoker` are scriptblocks invoked as `& $GhInvoker <arg1> <arg2> ...`; they receive the arguments in `$args` and return `[pscustomobject]@{ ExitCode = <int>; Output = <string> }`. `-OutputWriter` is a scriptblock `param([string] $Target, [string] $Text)` with `Target` one of `Output`, `Summary`, `Log`, `Warning`. Section 6 fixes every signature.
- **PD-5 (gating text).** Every gated step receives `if: ${{ inputs.run-heavy }}` on the line directly after its `- name:` line (or after the dash line of an unnamed step). A step with an existing condition `<expr>` receives `if: ${{ inputs.run-heavy && (<expr without ${{ }}>) }}`, except the three research §2.3 cases, which use the exact text of section 7, and any `always()` step condition, which becomes `if: ${{ always() && inputs.run-heavy }}`. A job with an existing job-level `if:` is combined the same way. PD-5 applies to steps of jobs without a job-level `run-heavy` gate only; PD-15 governs steps inside a job-gated job.
- **PD-6 (analyzer suppressions).** `Select-CiGreenBaseCandidates` carries `[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #962 spec.')]` and `New-CiChangeScopeDecision` carries `[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the name is fixed by the issue #962 spec.')]`, following `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` line 213 and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` line 92. No other suppression is added.
- **PD-7 (AC-28 test names).** The spec cites the skipping test "around line 79" and the `-RequireWorkflow` empty-set refusal "around line 364" of `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. In the current tree line 79 is `returns success when a check is skipping (skipping is non-blocking)`, line 264 is `returns pending for an empty check array with -RequireWorkflow CI` (the empty-set refusal), and line 364 is `returns pending when the only CI checks are skipping`. All three names are recorded (`PATTERNS-PARSER`).
- **PD-8 (coverage rows).** If CR-COV-FILES reports a file below 85%, the executor adds rows whose names end in ` (COV)` instead of an AC tag, so the per-AC row counts of section 8 stay fixed.
- **PD-9 (baseline actionlint findings).** A finding that P0-T15 records for one of `LIST-WORKFLOWS` is fixed in that file by the Phase 4 task that edits it, with the smallest change that clears it, recorded in that task's artifact; AC-25 requires zero findings.
- **PD-10 (proof derivations).** `id1` is the newest completed `pull_request` run of `ci.yml` on the branch whose `CI full run` job concluded `success`; `head1` is its `headSha`. `id2` is the run for `head2`, the head pushed by P7-T6. `id3` is the run for `head3`, the head pushed by P7-T15.
- **PD-11 (P3 proof edit, AC-34).** P7-T14 appends exactly one line at the end of `scripts/ci/CiChangeScope.psm1`: `# Changes to this module fall outside the docs-only allowlist, so they always start a full CI run (issue #962, proof step P3).`
- **PD-12 (Phase 7 ownership).** Phase 7 runs after the pull request exists, at S9, by the item's orchestrator run, not by the executor during plan execution. AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 stay unchecked until the Phase 7 task that verifies each.
- **PD-13 (Python workflow contract test, preflight D4).** `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg` (lines 134-143 of the current tree; identical in the #952 and #953 branch copies) asserts `"if" not in step` for the step running `check_python_coverage_thresholds` (`_quality-checks.yml` lines 87-92). G1 gives that step `if: ${{ inputs.run-heavy }}`, so the unmodified test fails on every CI matrix leg and AC-32 could not pass. The minimal change is A1 of section 7: the test requires the step's `if` value to equal exactly `${{ inputs.run-heavy }}` (a condition with the same value on every matrix leg) and fails on an absent key or on any other condition. The adjustment is planned fail-first (P4-T8, expect-fail) and pass-after (P4-T10), and is recorded with the D6 adjustments (P4-T13). The spec's D6 names only the two Pester suites; this Python test is the same class of gating-caused assertion change, and the spec does not exclude it from the write set. No other test in `tests/` pins a step or job condition of `ci.yml` or the six reusable workflows: the search recorded in section 7 found only A1 to A4.
- **PD-14 (Pester suites from #952 and #953, revised by coordinator decision 1).** The adjustments of the two existing suites are conditional on the shape recorded by P0-T9 and task-ordered: A4 (with A4C) is made in P4-T6 together with the `_poshqc.yml` edit only when `POSHQC-SHAPE: sharded`, and A2 is made in P4-T7 together with the `ci.yml` edit only when `A2-APPLICABLE: yes`; otherwise the task records `A4 not applicable on this HEAD` or `A2 not applicable on this HEAD` (the item that merges later resolves the composition through rule 17). The existing-suite run P4-T12 can then reach `Failed=0` in either shape. Both files are in `## Files Written` under `### Conditionally written`. Main-shape re-derivation for this revision (against `e07e235d5`): no assertion of `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (rows at lines 50-94) or of `tests/scripts/workflows/CiWorkflow.Tests.ps1` (rows at lines 149-173) breaks under the main-shape G6 or under G7; the detail is in section 7.
- **PD-15 (step conditions in a job-gated job; coordinator decision 1).** A job that receives a job-level `run-heavy` gate keeps every step-level condition unchanged, including `if: always()`: when `run-heavy` is false the job is skipped and none of its steps starts, and when it is true the job behaves as today. This is the least test churn: A3 (which rewrote the #953 shard-upload assertion to the combined `always() && inputs.run-heavy` condition) is withdrawn, and W14 asserts the absence of a bare `always()` step only in jobs that carry no job-level `run-heavy` gate.
- **PD-16 (shape selection).** G6 is applied in the shape recorded by the latest `FEATURE/evidence/other/edit-points.*.md` (`POSHQC-SHAPE:`) at P4-T6 time, and A2 by its `A2-APPLICABLE:` line at P4-T7 time. The suite W rows that depend on the shape (W15 to W17) read `_poshqc.yml` and branch on the presence of a `poshqc-shard` job, so their names and counts are identical in both shapes.
- **PD-17 (D14-a, README corrections).** Exactly three changes are made to pre-existing README content, as section 10 states: line 4 `eight` becomes `nine` (the nine `_*.yml` files are `_build-check`, `_docs-validation`, `_drm-copilot-extension-tests`, `_npm-audit-gate`, `_poshqc`, `_quality-checks`, `_root-typescript-tests`, `_security-scan`, `_shell-coverage`, and `ci.yml` calls all nine); the Per-Stage Dispatch table gains a `_npm-audit-gate.yml` row after the `_root-typescript-tests.yml` row (line 29), because line 4 refers to "the `_<name>.yml` files below" and the table must then list nine; and line 79 `All seven jobs in` becomes `The seven jobs it extracted from`, which keeps the paragraph a historical statement about the seven extracted jobs (accurate) instead of a count of today's `ci.yml` jobs (nine before G7, eleven after). The Triggers section (lines 8-16), which #952 edits, is not touched.
- **PD-18 (D14-b, blocking security scan).** G2 removes `continue-on-error: true`, adds `shell: bash` (GitHub Actions then runs `bash --noprofile --norc -eo pipefail`, so an export failure fails the pipeline), and inserts an export-plugin step before the scan; safety stays the scanner. Whether existing dependencies have findings cannot be determined locally (local Poetry 2.3.2 has no `export` command and the executor has no `gh`). Decision rule, applied by the orchestrator in P7-T3 to the first full PR run: if safety reports 0 vulnerabilities, the step stays blocking and AC-36 is checked off; if it reports findings, each finding (package, version, advisory id) is recorded in `FEATURE/evidence/other/security-scan-findings.<timestamp>.md`, the orchestrator opens a remediation cycle that restores `continue-on-error: true` on the scan step only (keeping the export fix, and adjusting row W18 and the `### Security scan` README subsection of section 10 to match), and records the decision for the coordinator; AC-36 then stays unchecked until that cycle completes. Any other failure of the job (the plugin install or the export) is a related defect remediated in a cycle that keeps the step blocking.
- **PD-19 (D14-c, recursive bats discovery).** `--recursive` is passed to bats directly before the directory argument in both invocations of `scripts/bash/shell_qc_lib.sh` (section 6a, S1). The two nounset assertions of `tests/shell/test_shell_qc_commands.bats` that quote the stub's argv change accordingly, and two new tests assert the flag in both modes (section 6a, S4). Collected-set check: every `.bats` file is directly under `tests/shell` (49 files at revision time; the only subdirectory `tests/shell/helpers/` holds one `.bash` helper), and `tests/bash` does not exist, so the recursive run collects the same files; CR-SHELL-STATIC records `SHELL-NESTED-BATS-FILES: 0`, and P7-T4 compares the CI test count with the `@test` line count.
- **PD-20 (D14-d, bash coverage threshold).** The simplest mechanism is a library function `check_coverage_threshold` with the minimum from `SHELL_QC_MIN_LINE_COVERAGE` (default 85, the line default that governs because the root `CLAUDE.md` states no threshold), called in `run_test_coverage` after `print_coverage_summary` (section 6a, S2). No workflow flag is needed, so `_shell-coverage.yml` changes only by G0 and G4. A missing or unparseable report prints nothing and returns 0, matching `print_coverage_summary` (this keeps the stub-based coverage test, whose kcov stub writes no report, passing; the CI upload step's `if-no-files-found: error` still fails a run that produced no kcov output). `scripts/bash/shell_qc_lib.sh` grows from 394 to 432 lines, under the 500-line limit.
- **PD-21 (D14 shell evidence).** Per rule 18: P0-T18 records the shell baseline, P1-T8 records the fail-before dossier, P5-T6 and P6-T11 record CR-SHELL-STATIC passes, and P7-T4 records the CI bats count, the coverage summary, the threshold line, and the baseline and post-change bash coverage (main run 38948304976 printed `Bash coverage (lines): 95.2%`, orchestrator observation).
- **PD-22 (spec amendments made in revision 4, coordinator decisions 1 and 2).** `spec.md` changed in these places only: the In-scope list (one D14 bullet); the D1 table row 4 (shape-neutral wording); D5 (dependency record, both shapes, re-integration); D9 (one sentence naming the AC-35 corrections); `### Dependencies or blocked work` (none blocking); the `#### Files/modules to change` list (one D14 bullet); the external-dependencies bullet; AC-20 third bullet (`always()` steps only in jobs without a job-level gate, PD-15); AC-21 (shape-conditional); AC-30 (record instead of gate); new AC-35 to AC-38 (marked D14-a to D14-d); Out of Scope items 2, 3, 5, and 6; and Rollout steps 1 and 2. No other criterion text changed.
- **PD-23 (Phase 7 renumbering).** Two orchestrator tasks for the first full PR run (P7-T3 security scan, P7-T4 shell coverage) are inserted after P7-T2, because a blocking security scan with findings would fail run `id1` and must be decided before AC-32 is evaluated; the former P7-T3 to P7-T15 become P7-T5 to P7-T17, and every reference in this plan uses the new numbers.

## 4. Requirements trace

Row identifiers are those of section 8 (suite C = `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, P = `tests/scripts/ci/CiChangeScope.Tests.ps1`, I = `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, W = `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`). Function identifiers F1 to F12 are those of section 6; shell edit identifiers S1 to S4 are those of section 6a; gating identifiers G0 to G7 are those of section 7.

| AC | Implementation | Tests | Evidence (check-off task) |
|---|---|---|---|
| AC-1 | F1, F12 | P1, P2, I1, I26 | P3-T2 |
| AC-2 | F1, F12 | P3, P4, I2 | P3-T2 |
| AC-3 | F6, F12 | P19, P20, I3, I4 | P3-T2 |
| AC-4 | F7, F12 | P24, I5 | P3-T2 |
| AC-5 | F6 | P15-P18, I9 | P2-T4 |
| AC-6 | F7, F12 | P21-P23, I6-I8 | P3-T2 |
| AC-7 | F12 | I10-I12 | P3-T2 |
| AC-8 | F4, F12 | P9, P11, I13-I15 | P3-T2 |
| AC-9 | F5, F12 | P10, P12, I16 | P3-T2 |
| AC-10 | F5 | P13, I17 | P2-T4 |
| AC-11 | F8, F10, F12 | P14, P25, P26, P28, I18, I23, I28 | P3-T2 |
| AC-12 | F3 | P7 | P2-T4 |
| AC-13 | F3 | P8 | P2-T4 |
| AC-14 | F2, F12 | P5, P6, I19 | P3-T2 |
| AC-15 | section 9 config | C1-C6, I25 | P2-T2 |
| AC-16 | F10, F12 | I20, I24, I27 | P3-T2 |
| AC-17 | section 6 layout | P27, I21, I22, CR-STRUCTURE, CR-HERMETIC | P3-T3 |
| AC-18 | G7 | W1-W5 | P4-T11 |
| AC-19 | G7 | W6-W8 | P4-T11 |
| AC-20 | G0-G6 | W9-W14 | P4-T11 |
| AC-21 | G6 | W15-W17 | P4-T11 |
| AC-22 | `## Files Written`, A1, A2 (when applicable), A4 (when sharded) | CR-SCOPE, CR-ONBLOCK, the D6 record | P6-T19 (from P4-T13, P4-T14, P6-T10) |
| AC-23 | Phase 1 before Phase 4 | W suite | P4-T11 (with P1-T6) |
| AC-24 | section 10 | CR-README | P5-T2 |
| AC-25 | G0-G7 | CR-ACTIONLINT | P6-T19 (from P6-T3) |
| AC-26 | `LIST-PS-WRITTEN` (new files and any suite in `LIST-EDITED-SUITES`) | CR-FORMAT, CR-PSSA, CR-PESTER-LIST | P6-T19 (from P6-T1, P6-T2, P6-T5) |
| AC-27 | F1-F12 | CR-PESTER-COV, CR-COV-FILES, CR-COV-DELTA | P6-T19 (from P6-T6, P6-T7, P6-T8) |
| AC-28 | none (unchanged surfaces) | `PATTERNS-PARSER` rows, CR-SCOPE | P6-T19 (from P6-T5, P6-T10) |
| AC-29 | section 9 tier entry | `check_quality_tiers`, quality-tiers pytest files | P2-T6 |
| AC-30 | P0-T5 to P0-T8, rule 17 | dependency-state `git grep` record, CR-SCOPE history lines | P6-T19 (from P0-T5, P0-T8, P6-T10) |
| AC-31 | section 1 evidence rule | CR-EVIDENCE | P6-T19 (from P6-T13) |
| AC-32 | G7 decision jobs | CI run `id1` | P7-T5 |
| AC-33 | G0-G7, F1-F12 | CI run `id2`, baseline run 38896898318 | P7-T13 |
| AC-34 | G0-G7, F1-F12, PD-11 | CI run `id3` | P7-T16 |
| AC-35 | section 10 corrections, PD-17 | CR-README | P5-T2 |
| AC-36 | G2, PD-18 | W18, CI run `id1` security-scan log | P7-T3 |
| AC-37 | S1, S4, PD-19 | CR-SHELL-STATIC, CI run `id1` shell-coverage log | P7-T4 |
| AC-38 | S2, S3, S4, PD-20 | CR-SHELL-STATIC, CR-KCOV-FILE, CI run `id1` shell-coverage log | P7-T4 |

## 5. Command recipes (CR)

P0-T3 writes the launcher below, verbatim, to `SCRATCH/tools/run-cr.sh` (LF line endings), and each recipe below, verbatim, to `SCRATCH/tools/<file>` where `<file>` is the `.txt` name in its heading. Recipe bodies are PowerShell 7 source; the `.txt` extension keeps every scratch file written with Write outside the `.ps1`/`.psm1`/`.psd1` set (rule 4a). These files are outside the worktree, are not test files, and are not committed. Every recipe ends by printing `EXIT_CODE_COMPUTED: <n>` and exiting with that code, so the process exit code and the printed value agree; a disagreement stops the task BLOCKED. The one exception is CR-PESTER-COV, where Pester can end the process itself (`Run.Exit = $true`); its success observation is the process exit code 0 plus the `Tests Passed:` line, and its trailing lines are not asserted. Every recipe run through the launcher prints `RUN-CR: cr-<name>` first.

### run-cr.sh (the POSIX launcher)

```sh
#!/bin/sh
# Runs one command recipe, SCRATCH/tools/<name>.txt, with PowerShell 7 from the current directory.
# Usage: sh SCRATCH/tools/run-cr.sh cr-<name> [recipe arguments...]
set -u
MSYS_NO_PATHCONV=1
MSYS2_ARG_CONV_EXCL='*'
export MSYS_NO_PATHCONV MSYS2_ARG_CONV_EXCL
if [ "$#" -lt 1 ]; then
  echo "RUN-CR-USAGE: run-cr.sh cr-<name> [arguments]"
  echo "EXIT_CODE_COMPUTED: 2"
  exit 2
fi
name="$1"
shift
case "$name" in
  cr-*) ;;
  *)
    echo "RUN-CR-BAD-NAME: $name"
    echo "EXIT_CODE_COMPUTED: 2"
    exit 2
    ;;
esac
tools_dir=$(dirname "$0")
recipe="$tools_dir/$name.txt"
stage_dir="$tools_dir/../stage"
if [ ! -f "$recipe" ]; then
  echo "RUN-CR-RECIPE-MISSING: $name"
  echo "EXIT_CODE_COMPUTED: 2"
  exit 2
fi
if ! command -v pwsh >/dev/null 2>&1; then
  echo "RUN-CR-INTERPRETER-ABSENT: PowerShell 7"
  echo "EXIT_CODE_COMPUTED: 2"
  exit 2
fi
mkdir -p "$stage_dir"
cp "$recipe" "$stage_dir/$name.ps1"
echo "RUN-CR: $name"
exec pwsh -NoProfile -NonInteractive -File "$stage_dir/$name.ps1" "$@"
```

The launcher passes every argument as one argv element, so a quoted list or pattern containing spaces or parentheses reaches the recipe intact, and the `MSYS` variables stop Git for Windows `sh` from rewriting path-like arguments. Success-case literals: `RUN-CR: cr-<name>` followed by the recipe's own output; the process exit code is the recipe's. Failure literals: `RUN-CR-USAGE:`, `RUN-CR-BAD-NAME:`, `RUN-CR-RECIPE-MISSING:`, `RUN-CR-INTERPRETER-ABSENT:` with exit code 2.

### cr-python-env.txt (CR-PYTHON-ENV, preflight D3)

```powershell
[CmdletBinding()]
param()
$install = @(& poetry install --no-interaction 2>&1)
$installExit = $LASTEXITCODE
foreach ($line in $install) { "PYENV-INSTALL: $line" }
"PYENV-INSTALL-EXIT: $installExit"
$probe = @(& poetry run python -c "import pytest, yaml; print('PYTHON-IMPORTS-OK')" 2>&1)
$probeExit = $LASTEXITCODE
foreach ($line in $probe) { "PYENV-PROBE: $line" }
"PYENV-PROBE-EXIT: $probeExit"
$importsOk = @($probe | Where-Object { ([string]$_).Trim() -ceq 'PYTHON-IMPORTS-OK' }).Count -eq 1
$ready = ($installExit -eq 0) -and ($probeExit -eq 0) -and $importsOk
if ($ready) { 'PYTHON-ENV-READY' } else { 'PYTHON-ENV-NOT-READY' }
$code = if ($ready) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

`poetry install --no-interaction` creates or updates the worktree's Poetry environment from `pyproject.toml` and `poetry.lock` (it is a write-mode command; its observation is the printed readiness literal, not its exit code). The probe is a single-line `-c` program, because a multi-line `-c` argument can exit 0 without running. Success-case literals: `PYENV-INSTALL-EXIT: 0`, `PYENV-PROBE: PYTHON-IMPORTS-OK`, `PYENV-PROBE-EXIT: 0`, `PYTHON-ENV-READY`, `EXIT_CODE_COMPUTED: 0`. `PYTHON-ENV-READY` is printed only when all three conditions hold, so it cannot appear on a failed install or a failed import.

### cr-probe.txt (CR-PROBE)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
"PROBE-PWSH: $($PSVersionTable.PSVersion)"
$pester = Get-Module -ListAvailable -Name Pester | Sort-Object -Property Version -Descending | Select-Object -First 1
$pssa = Get-Module -ListAvailable -Name PSScriptAnalyzer | Sort-Object -Property Version -Descending | Select-Object -First 1
$pesterText = if ($pester) { [string]$pester.Version } else { 'absent' }
$pssaText = if ($pssa) { [string]$pssa.Version } else { 'absent' }
$atRoot = Test-Path -LiteralPath 'scripts/powershell/PoshQC/PoshQC.psm1'
"PROBE-PESTER: $pesterText"
"PROBE-PSSA: $pssaText"
"PROBE-CWD-IS-REPO-ROOT: $atRoot"
$ok = ($null -ne $pester) -and ($pester.Version.Major -ge 5) -and ($null -ne $pssa) -and $atRoot
$code = if ($ok) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `PROBE-PESTER: 5.` (prefix), `PROBE-CWD-IS-REPO-ROOT: True`, `EXIT_CODE_COMPUTED: 0`.

### cr-inventory.txt (CR-INVENTORY)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$files = @('.github/workflows/ci.yml', '.github/workflows/_quality-checks.yml', '.github/workflows/_security-scan.yml', '.github/workflows/_build-check.yml', '.github/workflows/_shell-coverage.yml', '.github/workflows/_drm-copilot-extension-tests.yml', '.github/workflows/_poshqc.yml')
$poshqcJobs = [System.Collections.Generic.List[string]]::new()
foreach ($file in $files) {
    $lines = @(Get-Content -LiteralPath $file)
    $inJobs = $false
    $job = ''
    $stepIndex = 0
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^on:') { "ONBLOCK-START: $file | line=$($i + 1)" }
        if ($line -match '^jobs:\s*$') { $inJobs = $true; "JOBS-LINE: $file | line=$($i + 1)"; continue }
        if (-not $inJobs) {
            if ($line -match '^ {4}inputs:\s*$') { "INPUTS-DECLARED: $file | line=$($i + 1)" }
            continue
        }
        if ($line -match '^ {2}(?<id>[A-Za-z0-9_-]+):\s*$') {
            $job = $Matches['id']
            $stepIndex = 0
            if ($file -eq '.github/workflows/_poshqc.yml') { $poshqcJobs.Add($job) }
            "JOB: $file | $job | line=$($i + 1)"
            continue
        }
        if ($line -match '^ {4}if:\s*(?<cond>.+)$') { "JOB-IF: $file | $job | $($Matches['cond'])" }
        if ($line -match '^ {4}needs:\s*(?<needs>.+)$') { "JOB-NEEDS: $file | $job | $($Matches['needs'])" }
        if ($line -match '^ {6}- name:\s*(?<name>.+)$') { $stepIndex++; "STEP: $file | $job | $stepIndex | $($Matches['name'])"; continue }
        if ($line -match '^ {6}- ') { $stepIndex++; "STEP-UNNAMED: $file | $job | $stepIndex | line=$($i + 1)" }
        if ($line -match '^ {8}if:\s*(?<cond>.+)$') { "STEP-IF: $file | $job | $stepIndex | $($Matches['cond'])" }
    }
}
$jobArray = [string[]]@($poshqcJobs)
[Array]::Sort($jobArray, [StringComparer]::Ordinal)
$jobSet = $jobArray -join ','
$shape = 'unknown'
if ($jobSet -ceq 'poshqc,poshqc-linux-hooks') { $shape = 'main' }
elseif ($jobSet -ceq 'poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static') { $shape = 'sharded' }
"POSHQC-JOB-SET: $jobSet"
"POSHQC-SHAPE: $shape"
$mergeGroupCount = @(Get-Content -LiteralPath '.github/workflows/ci.yml' | Where-Object { $_ -match '^  merge_group:\s*$' }).Count
$mergeGroupText = 'absent'
if ($mergeGroupCount -gt 0) { $mergeGroupText = 'present' }
"CI-MERGE-GROUP: $mergeGroupText"
$editTargets = @(
    [pscustomobject]@{ Id = 'A2'; Path = 'tests/scripts/workflows/CiWorkflow.Tests.ps1'; Text = '            $eventFieldLines = @($graphLines | Where-Object { $_ -match ''github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name'' })'; Anchor = '$eventFieldLines = @(' }
    [pscustomobject]@{ Id = 'A2B'; Path = 'tests/scripts/workflows/CiWorkflow.Tests.ps1'; Text = '            $eventFieldLines.Count | Should -Be 0 -Because "$graphFile must not read a pull-request event field, which a merge_group run does not carry"'; Anchor = '$eventFieldLines.Count' }
    [pscustomobject]@{ Id = 'A4'; Path = 'tests/scripts/workflows/PoshQcWorkflow.Tests.ps1'; Text = '            if ($gate -match ''(?m)^ {8}if:'') {'; Anchor = '$gate -match' }
    [pscustomobject]@{ Id = 'A4C'; Path = 'tests/scripts/workflows/PoshQcWorkflow.Tests.ps1'; Text = '        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.'; Anchor = 'carries no step-level if condition' }
)
foreach ($target in $editTargets) {
    $suiteLines = @(Get-Content -LiteralPath $target.Path)
    $hits = @(for ($i = 0; $i -lt $suiteLines.Count; $i++) { if ($suiteLines[$i] -ceq $target.Text) { $i + 1 } })
    "EDIT-TARGET-$($target.Id): $($target.Path) | count=$($hits.Count) | lines=$($hits -join ',')"
    if ($hits.Count -ne 1) {
        for ($i = 0; $i -lt $suiteLines.Count; $i++) { if ($suiteLines[$i].Contains($target.Anchor)) { "EDIT-TARGET-$($target.Id)-CANDIDATE: line=$($i + 1) | $($suiteLines[$i])" } }
    }
}
$root = (Get-Location).Path
$workflowSuites = @(Get-ChildItem -LiteralPath 'tests/scripts/workflows' -Filter '*.Tests.ps1' -File | ForEach-Object { 'tests/scripts/workflows/' + $_.Name })
$referencePattern = '\.github/workflows/(ci|_quality-checks|_security-scan|_build-check|_shell-coverage|_drm-copilot-extension-tests|_poshqc)\.yml'
$referencing = @(Get-ChildItem -LiteralPath 'tests' -Filter '*.Tests.ps1' -File -Recurse | Where-Object { [string](Get-Content -Raw -LiteralPath $_.FullName) -match $referencePattern } | ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace([string][char]92, '/') })
foreach ($suite in $referencing) { "WORKFLOW-REFERENCING-SUITE: $suite" }
$suites = @(@($workflowSuites) + @($referencing) + 'tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1' | Sort-Object -Unique)
"LIST-EXISTING-SUITES: $($suites -join ',')"
"EXIT_CODE_COMPUTED: 0"
exit 0
```

Success-case literals: one `JOB:` line per job, one `STEP:` line per step, a `POSHQC-JOB-SET:` line, `POSHQC-SHAPE: main` or `POSHQC-SHAPE: sharded`, a `CI-MERGE-GROUP:` line, four `EDIT-TARGET-<id>:` lines (ids `A2`, `A2B`, `A4`, `A4C`), one `WORKFLOW-REFERENCING-SUITE:` line per suite under `tests/` that names one of the seven workflow files by path, a `LIST-EXISTING-SUITES:` line, and `EXIT_CODE_COMPUTED: 0`. On the head at revision time (`e07e235d5`, main shape, no `merge_group`) the expected values are `POSHQC-JOB-SET: poshqc,poshqc-linux-hooks`, `POSHQC-SHAPE: main`, `CI-MERGE-GROUP: absent`, `count=0` for all four targets, and no `EDIT-TARGET-` candidate line (none of the four anchor texts occurs in the two suites, verified by reading both files in this revision). In the sharded shape the A4 and A4C lines must show `count=1` (lines 85 and 51 of the #953 copy at `1f208b4e5baa6d1815877343823418f971c7ba78`; the later head `7558c7e42ec8c8955cb5f9997cca41afc6e3b797` was not readable from this worktree, so B6 re-verifies them); with #952 the A2 and A2B lines must show `count=1` (lines 232 and 236 of the #952 copy as read in revision 3). The edit-target texts are the section 7 lines written as PowerShell single-quoted strings (each embedded `'` doubled), compared with `-ceq` against whole lines, so indentation and case must match exactly. In the head at revision time the referencing suites are `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, and `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (which names `ci.yml` only as test data); the #953 copy adds `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (row `RS07-WORKFLOW-LINUX-PESTER-RANGE` reads the `poshqc-linux-hooks` job; G6 adds no `Import-Module Pester` line, so it is unaffected).

### cr-pester-list.txt (CR-PESTER-LIST)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $PathList, [string] $NamePatternList = '')
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$paths = @($PathList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$patterns = @($NamePatternList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$configuration = New-PesterConfiguration
$configuration.Run.Path = $paths
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
$result = Invoke-Pester -Configuration $configuration
function Get-RelativeName([string] $File) {
    if ($File.StartsWith($root)) { $File = $File.Substring($root.Length + 1) }
    return $File.Replace([string][char]92, '/')
}
foreach ($container in $result.Containers) { "CONTAINER: $(Get-RelativeName ([string]$container.Item)) | Result=$($container.Result)" }
foreach ($group in ($result.Tests | Group-Object { Get-RelativeName ([string]$_.ScriptBlock.File) } | Sort-Object Name)) {
    $passed = @($group.Group | Where-Object Result -EQ 'Passed').Count
    $failed = @($group.Group | Where-Object Result -EQ 'Failed').Count
    $skipped = @($group.Group | Where-Object Result -EQ 'Skipped').Count
    $notRun = @($group.Group | Where-Object Result -EQ 'NotRun').Count
    "SUITE: $($group.Name) | Passed=$passed | Failed=$failed | Skipped=$skipped | NotRun=$notRun"
}
foreach ($pattern in $patterns) {
    $hits = @($result.Tests | Where-Object { $_.ExpandedName -like $pattern })
    "NAMED: $pattern | Passed=$(@($hits | Where-Object Result -EQ 'Passed').Count) | Failed=$(@($hits | Where-Object Result -EQ 'Failed').Count) | Total=$($hits.Count)"
}
foreach ($test in $result.Tests) { "ROW: $($test.Result) | $(Get-RelativeName ([string]$test.ScriptBlock.File)) | $($test.ExpandedName)" }
foreach ($test in $result.Failed) { "FAILED: $($test.ExpandedPath) :: $((($test.ErrorRecord | Select-Object -First 1).Exception.Message) -replace '\s+', ' ')" }
"TOTAL: Passed=$($result.PassedCount) | Failed=$($result.FailedCount) | Skipped=$($result.SkippedCount) | NotRun=$($result.NotRunCount) | FailedBlocks=$($result.FailedBlocksCount) | FailedContainers=$($result.FailedContainersCount)"
$code = if ($result.Result -eq 'Passed') { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `CONTAINER:` line per file with `Result=Passed`, one `SUITE:` line per file, one `NAMED:` line per pattern, a `TOTAL:` line with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.

### cr-pester-cov.txt (CR-PESTER-COV, the PoshQC coverage run)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $ScanFolderList)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$folders = @($ScanFolderList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
"COVERAGE-RUN-START-UTC: $([DateTime]::UtcNow.ToString('o'))"
Import-Module (Join-Path $root 'scripts/powershell/PoshQC/PoshQC.psm1') -Force
Invoke-PoshQCTest -Root $root -ScanFolders $folders
"EXIT_CODE_COMPUTED: 0"
exit 0
```

`Invoke-PoshQCTest` uses `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`Run.Exit = $true` at line 4, coverage output `artifacts/pester/powershell-coverage.xml` at line 22, `CoveragePercentTarget = 0` at line 26) and derives the coverage population from `config/poshqc-coverage.json`, whose `scripts` root includes `scripts/ci`. A failing run ends the process inside Pester with a non-zero code. Success-case observation: the line `COVERAGE-RUN-START-UTC:` (its value is passed to CR-COV-FILES as `-NotBefore`), the line `Code coverage population: source=config`, a `Tests Passed: <n>, Failed: 0` line, and process exit code 0. This CR always runs in a child process (rule 3), never in-process.

### cr-cov-files.txt (CR-COV-FILES)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $TargetList, [Parameter(Mandatory = $true)][string] $NotBefore, [int] $Threshold = 85)
$ErrorActionPreference = 'Stop'
$targets = @($TargetList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$reportItem = Get-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$notBeforeUtc = [DateTime]::Parse($NotBefore, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
$fresh = $reportItem.LastWriteTimeUtc -ge $notBeforeUtc
"COVERAGE-FILE-FRESH: $fresh"
if (-not $fresh) { 'EXIT_CODE_COMPUTED: 1'; exit 1 }
[xml] $report = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$sourceFiles = @($report.SelectNodes('//sourcefile'))
$covered = 0
$missed = 0
foreach ($node in $sourceFiles) {
    $counter = $node.SelectSingleNode("counter[@type='LINE']")
    if ($null -ne $counter) { $covered += [int]$counter.GetAttribute('covered'); $missed += [int]$counter.GetAttribute('missed') }
}
"SOURCEFILE-COUNT: $($sourceFiles.Count)"
"TOTAL-LINE-COVERAGE: covered=$covered | missed=$missed | percent=$([math]::Round(100 * $covered / [math]::Max(1, $covered + $missed), 2))"
$failing = 0
foreach ($target in $targets) {
    $folder = $target.Substring(0, $target.LastIndexOf('/'))
    $leaf = $target.Substring($target.LastIndexOf('/') + 1)
    $folderPattern = '(^|/)' + [regex]::Escape($folder) + '$'
    $hits = @(
        foreach ($package in @($report.SelectNodes('//package'))) {
            $packageName = ($package.GetAttribute('name') -replace '\\', '/').TrimEnd('/')
            if ($packageName -notmatch $folderPattern) { continue }
            foreach ($file in @($package.SelectNodes('sourcefile'))) {
                $fileName = $file.GetAttribute('name') -replace '\\', '/'
                if ($fileName -ceq $leaf -or $fileName.EndsWith('/' + $leaf)) { $file }
            }
        }
    )
    if ($hits.Count -ne 1) { $failing++; "COV-FILE: $target | matches=$($hits.Count) | MISSING"; continue }
    $line = $hits[0].SelectSingleNode("counter[@type='LINE']")
    $c = [int]$line.GetAttribute('covered')
    $m = [int]$line.GetAttribute('missed')
    $percent = [math]::Round(100 * $c / [math]::Max(1, $c + $m), 2)
    $verdict = if ($percent -ge $Threshold) { 'PASS' } else { 'FAIL' }
    if ($verdict -eq 'FAIL') { $failing++ }
    "COV-FILE: $target | covered=$c | missed=$m | percent=$percent | threshold=$Threshold | $verdict"
}
"COV-FILES-FAILING: $failing"
$code = [int]($failing -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

`-NotBefore` is the `COVERAGE-RUN-START-UTC:` value printed by the CR-PESTER-COV run being read, so a stale coverage file from an earlier run cannot be read. Success-case literals: `COVERAGE-FILE-FRESH: True`, a positive `SOURCEFILE-COUNT:`, one numeric `TOTAL-LINE-COVERAGE:` line, one `COV-FILE:` line per target ending in `PASS`, `COV-FILES-FAILING: 0`, `EXIT_CODE_COMPUTED: 0`. Pester measures line and command coverage only; no branch figure is recorded for PowerShell.

### cr-cov-delta.txt (CR-COV-DELTA)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$feature = 'docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962'
$baseline = Get-ChildItem -LiteralPath "$feature/evidence/baseline" -Filter 'baseline-coverage-files.*.md' -File | Sort-Object -Property Name | Select-Object -Last 1
$final = Get-ChildItem -LiteralPath "$feature/evidence/qa-gates" -Filter 'final-coverage-files.*.md' -File | Sort-Object -Property Name | Select-Object -Last 1
if ($null -eq $baseline -or $null -eq $final) { "DELTA-INPUT-MISSING: baseline=$($null -ne $baseline) | final=$($null -ne $final)"; "EXIT_CODE_COMPUTED: 1"; exit 1 }
"DELTA-BASELINE-ARTIFACT: $($baseline.Name)"
"DELTA-FINAL-ARTIFACT: $($final.Name)"
foreach ($line in Get-Content -LiteralPath $baseline.FullName) { if ($line -match '^\s*(TOTAL-LINE-COVERAGE|COV-FILE):') { "BASELINE $($line.Trim())" } }
$failing = $null
foreach ($line in Get-Content -LiteralPath $final.FullName) {
    if ($line -match '^\s*(TOTAL-LINE-COVERAGE|COV-FILE):') { "FINAL $($line.Trim())" }
    if ($line -match '^\s*COV-FILES-FAILING:\s*(?<n>\d+)') { $failing = [int]$Matches['n'] }
}
"DELTA-NEW-CODE-FILES-FAILING: $failing"
$code = if ($failing -eq 0) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `BASELINE TOTAL-LINE-COVERAGE:`, two `BASELINE COV-FILE:` lines ending `MISSING`, `FINAL TOTAL-LINE-COVERAGE:`, two `FINAL COV-FILE:` lines ending `PASS`, `DELTA-NEW-CODE-FILES-FAILING: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-format.txt (CR-FORMAT; mirrors `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 56-66)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $PathList, [switch] $Write)
$ErrorActionPreference = 'Stop'
$paths = @($PathList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$drift = 0
foreach ($path in $paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) {
        $drift++
        if ($Write) { Set-Content -LiteralPath $path -Value $formatted -Encoding UTF8 -NoNewline; "FORMAT-WRITTEN: $path" } else { "FORMAT-DRIFT: $path" }
    }
    else { "FORMAT-CLEAN: $path" }
}
"FORMAT-DRIFT-COUNT: $drift"
$code = if ($Write) { 0 } else { [int]($drift -gt 0) }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals (clean, unchanged run): one `FORMAT-CLEAN:` line per file and `FORMAT-DRIFT-COUNT: 0`. In `-Write` mode the exit code is 0 whether or not a file was formatted, so a write-mode task asserts `FORMAT-DRIFT-COUNT: 0` and treats any `FORMAT-WRITTEN:` line as a change that restarts the loop.

### cr-pssa.txt (CR-PSSA)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $PathList)
$ErrorActionPreference = 'Stop'
$paths = @($PathList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$total = 0
foreach ($path in $paths) {
    $findings = @(Invoke-ScriptAnalyzer -Path $path -Settings $settings -Severity Error, Warning, Information)
    $total += $findings.Count
    "PSSA: $path | findings=$($findings.Count)"
    foreach ($finding in $findings) { "PSSA-FINDING: $($path):$($finding.Line) $($finding.RuleName) $($finding.Severity)" }
}
"PSSA-TOTAL: $total"
$code = [int]($total -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-hermetic.txt (CR-HERMETIC)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $PathList)
$ErrorActionPreference = 'Stop'
$paths = @($PathList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$tokens = @(('Start-' + 'Process'), ('Start-' + 'Sleep'), ('New-' + 'TemporaryFile'), ('Test' + 'Drive'), ('GetTemp' + 'Path'), ('GetTemp' + 'FileName'), ('$env:' + 'TEMP'), ('$env:' + 'TMP'), ('Invoke-' + 'WebRequest'), ('Invoke-' + 'RestMethod'), ('Set-' + 'Content'), ('Out-' + 'File'), ('New-' + 'Item'), ('System.Diagnostics.' + 'Process'))
$mockPattern = '(?m)^\s*Mock\s+[''"]?(git|gh)[''"]?(\s|$)'
$hits = 0
$over = 0
foreach ($path in $paths) {
    $text = Get-Content -Raw -LiteralPath $path
    foreach ($token in $tokens) { if ($text.Contains($token)) { $hits++; "HERMETIC-HIT: $path | $token" } }
    if ($text -match $mockPattern) { $hits++; "HERMETIC-HIT: $path | direct executable mock" }
    $count = @(Get-Content -LiteralPath $path).Count
    if ($count -gt 500) { $over++ }
    "LINES: $path | $count"
}
"HERMETIC-HITS: $hits"
"LINES-OVER-500: $over"
$code = [int](($hits + $over) -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `LINES:` line per file, `HERMETIC-HITS: 0`, `LINES-OVER-500: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-structure.txt (CR-STRUCTURE, AC-17)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$expected = @('ConvertFrom-CiDocsOnlyPathConfig', 'ConvertFrom-CiNulPathList', 'Get-CiChangeScopePathDecision', 'New-CiChangeScopeDecision', 'Select-CiGreenBaseCandidates', 'Test-CiChangeScopeEventEligible', 'Test-CiDocsOnlyPath', 'Test-CiFullRunMarker')
$banned = @('git', 'gh', 'Get-Content', 'Set-Content', 'Add-Content', 'Out-File', 'New-Item', 'Remove-Item', 'Copy-Item', 'Move-Item', 'Test-Path', 'Get-ChildItem', 'Get-Item', 'Invoke-WebRequest', 'Invoke-RestMethod', ('Start-' + 'Process'), 'Import-Module', 'Invoke-Expression')
$moduleTokens = $null
$moduleErrors = $null
$moduleAst = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath 'scripts/ci/CiChangeScope.psm1').Path, [ref] $moduleTokens, [ref] $moduleErrors)
$defined = @($moduleAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Name } | Sort-Object)
$functionMatch = (($defined -join ',') -ceq ((@($expected) | Sort-Object) -join ','))
$commands = @($moduleAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true))
$bannedHits = @($commands | Where-Object { $banned -contains $_.GetCommandName() })
$ampersand = @($commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand })
$ioTypes = @($moduleAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.TypeExpressionAst] -or $n -is [System.Management.Automation.Language.TypeConstraintAst] }, $true) | Where-Object { $_.TypeName.FullName -match '^(System\.)?(IO|Net|Diagnostics)\.' })
"STRUCT-MODULE-PARSE-ERRORS: $(@($moduleErrors).Count)"
"STRUCT-MODULE-FUNCTIONS: $($defined -join ',')"
"STRUCT-MODULE-FUNCTIONS-MATCH: $functionMatch"
"STRUCT-MODULE-BANNED-COMMANDS: $($bannedHits.Count)"
"STRUCT-MODULE-INVOCATION-OPERATORS: $($ampersand.Count)"
"STRUCT-MODULE-IO-TYPES: $($ioTypes.Count)"
$entryTokens = $null
$entryErrors = $null
$entryAst = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath 'scripts/ci/Invoke-CiChangeScope.ps1').Path, [ref] $entryTokens, [ref] $entryErrors)
$invoke = @($entryAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -ceq 'Invoke-CiChangeScope' }, $true))
$seams = @()
if ($invoke.Count -eq 1 -and $null -ne $invoke[0].Body.ParamBlock) {
    $seams = @($invoke[0].Body.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath } | Where-Object { $_ -in @('GhInvoker', 'GitInvoker', 'OutputWriter') })
}
$guard = (Get-Content -Raw -LiteralPath 'scripts/ci/Invoke-CiChangeScope.ps1').Contains('$MyInvocation.InvocationName -ne ''.''')
$nonPowerShell = @(Get-ChildItem -LiteralPath 'scripts/ci', 'tests/scripts/ci' -File -Recurse | Where-Object { $_.Extension -notin @('.ps1', '.psm1') })
"STRUCT-ENTRY-PARSE-ERRORS: $(@($entryErrors).Count)"
"STRUCT-ENTRY-SEAMS: $($seams.Count)"
"STRUCT-ENTRY-GUARD: $guard"
"STRUCT-NON-POWERSHELL-FILES: $($nonPowerShell.Count)"
$ok = (@($moduleErrors).Count -eq 0) -and (@($entryErrors).Count -eq 0) -and $functionMatch -and ($bannedHits.Count -eq 0) -and ($ampersand.Count -eq 0) -and ($ioTypes.Count -eq 0) -and ($seams.Count -eq 3) -and $guard -and ($nonPowerShell.Count -eq 0)
$code = if ($ok) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `STRUCT-MODULE-FUNCTIONS-MATCH: True`, `STRUCT-MODULE-BANNED-COMMANDS: 0`, `STRUCT-MODULE-INVOCATION-OPERATORS: 0`, `STRUCT-MODULE-IO-TYPES: 0`, `STRUCT-ENTRY-SEAMS: 3`, `STRUCT-ENTRY-GUARD: True`, `STRUCT-NON-POWERSHELL-FILES: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-onblock.txt (CR-ONBLOCK)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
function Get-OnBlock([string[]] $Lines) {
    $block = [System.Collections.Generic.List[string]]::new()
    $inside = $false
    foreach ($line in $Lines) {
        if ($line -match '^on:') { $inside = $true; $block.Add($line); continue }
        if ($inside -and $line -match '^\S') { break }
        if ($inside) { $block.Add($line) }
    }
    return , $block.ToArray()
}
$mergeBase = ([string](git merge-base origin/main HEAD)).Trim()
"MERGE-BASE: $mergeBase"
$baseBlock = Get-OnBlock @(git show "$($mergeBase):.github/workflows/ci.yml")
$headBlock = Get-OnBlock @(Get-Content -LiteralPath '.github/workflows/ci.yml')
$identical = (($baseBlock -join "`n") -ceq ($headBlock -join "`n"))
"ONBLOCK-LINES: base=$($baseBlock.Count) | head=$($headBlock.Count)"
"ONBLOCK-HAS-MERGE-GROUP: $(($headBlock -join "`n").Contains('merge_group'))"
"ONBLOCK-IDENTICAL: $identical"
$code = if ($identical -and $baseBlock.Count -gt 0) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `ONBLOCK-IDENTICAL: True`, `EXIT_CODE_COMPUTED: 0`, and an `ONBLOCK-HAS-MERGE-GROUP:` line whose value is `True` exactly when the latest edit-points artifact records `CI-MERGE-GROUP: present` (`False` on the head at revision time). The comparison uses the merge base so that a later advance of `origin/main` does not change the result.

### cr-readme.txt (CR-README, AC-24)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$mergeBase = ([string](git merge-base origin/main HEAD)).Trim()
$baseLines = @(git show "$($mergeBase):.github/workflows/README.md")
$headLines = @(Get-Content -LiteralPath '.github/workflows/README.md')
$oldLines = @('orchestrator that composes eight reusable per-stage workflows (the `_<name>.yml` files', 'This extraction does not, by itself, change job-DAG concurrency. All seven jobs in')
$newLines = @('orchestrator that composes nine reusable per-stage workflows (the `_<name>.yml` files', 'This extraction does not, by itself, change job-DAG concurrency. The seven jobs it extracted from')
$insertAfter = '| `_root-typescript-tests.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _root-typescript-tests.yml` |'
$insertLine = '| `_npm-audit-gate.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _npm-audit-gate.yml` |'
$replaced = @(0, 0)
$anchorHits = 0
$expected = [System.Collections.Generic.List[string]]::new()
foreach ($line in $baseLines) {
    $index = [Array]::IndexOf($oldLines, [string]$line)
    if ($index -ge 0) { $expected.Add($newLines[$index]); $replaced[$index]++ } else { $expected.Add([string]$line) }
    if ([string]$line -ceq $insertAfter) { $expected.Add($insertLine); $anchorHits++ }
}
$prefix = ($headLines.Count -gt $expected.Count) -and ($replaced[0] -eq 1) -and ($replaced[1] -eq 1) -and ($anchorHits -eq 1)
for ($i = 0; $prefix -and $i -lt $expected.Count; $i++) { if ($headLines[$i] -cne $expected[$i]) { $prefix = $false; "README-PREFIX-MISMATCH: line=$($i + 1)" } }
"README-LINES: base=$($baseLines.Count) | expected-prefix=$($expected.Count) | head=$($headLines.Count)"
"README-REPLACED-LINES: $($replaced -join ',')"
"README-ANCHOR-HITS: $anchorHits"
"README-PREFIX-IDENTICAL: $prefix"
$appended = (@($headLines | Select-Object -Skip $expected.Count)) -join "`n"
$tokens = @('## Change-Scope Decision (Issue #962)', 'config/ci-docs-only-paths.json', 'scripts/ci/Invoke-CiChangeScope.ps1', 'run-heavy', 'continue-on-error: true', 'CI full run', 'EVENT_NOT_PULL_REQUEST', 'FORK_PULL_REQUEST', 'RUN_LIST_FAILED', 'JOB_LIST_FAILED', 'NO_FULL_GREEN_RUN', 'BASE_NOT_PRESENT', 'BASE_NOT_ANCESTOR', 'ANCESTRY_CHECK_FAILED', 'DIFF_FAILED', 'EMPTY_DIFF', 'NON_ALLOWLISTED_PATH', 'DOCS_ONLY_SINCE_', 'UNEXPECTED_ERROR', 'drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)', 'drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)', 'docs-validation / Documentation Validation', 'poshqc / PowerShell QC', 'shell-coverage / Shell Coverage (Bats + kcov)', 'security-scan / Security Scanning', 'quality-checks7 / Code Quality & Tests (3.10)', 'quality-checks7 / Code Quality & Tests (3.11)', 'quality-checks7 / Code Quality & Tests (3.12)', 'quality-checks7 / Code Quality & Tests (3.13)', 'build-check / Build Package')
$missing = @($tokens | Where-Object { -not $appended.Contains($_) })
foreach ($token in $missing) { "README-MISSING: $token" }
"README-TOKENS-MISSING: $($missing.Count)"
$code = if ($prefix -and $missing.Count -eq 0) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `README-REPLACED-LINES: 1,1`, `README-ANCHOR-HITS: 1`, `README-PREFIX-IDENTICAL: True` (the head starts with the merge-base README in which exactly the two PD-17 lines are replaced and the PD-17 table row is inserted; every other pre-existing line, including the Triggers section, is unchanged, and the new text is appended), `README-TOKENS-MISSING: 0`, `EXIT_CODE_COMPUTED: 0`. The three PD-17 texts in the recipe were re-derived in revision 4 from lines 4, 29, and 79 of the current `.github/workflows/README.md`. Before P5-T1 (unchanged README) the recipe prints `README-REPLACED-LINES: 1,1`, `README-ANCHOR-HITS: 1`, and `README-PREFIX-IDENTICAL: False` (the head is not longer than the expected prefix, so the line comparison does not run). Backticks inside the single-quoted PowerShell strings are literal characters.

### cr-scope.txt (CR-SCOPE, AC-22, AC-28, AC-30)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $AllowedList, [Parameter(Mandatory = $true)][string] $MergeCommit)
$ErrorActionPreference = 'Stop'
$feature = 'docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/'
$branch = 'bug/ci-skip-evidence-only-commits-962'
$embeddedAllowed = @('scripts/bash/shell_qc_lib.sh', 'scripts/bash/shell-qc.sh')
$allowed = @(@($AllowedList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }) + $embeddedAllowed)
"SCOPE-EMBEDDED-ALLOWED: $($embeddedAllowed -join ',')"
$forbidden = @('.github/workflows/_docs-validation.yml', '.github/workflows/_root-typescript-tests.yml', '.github/workflows/_npm-audit-gate.yml', '.claude/lib/ci-gate/Invoke-CiGateParser.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1', '.claude/skills/orchestrate/SKILL.md', '.claude/skills/parallel-orchestrate/SKILL.md', 'tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1')
$policyPrefixes = @('.claude/rules/', '.github/instructions/')
$changed = @(git diff --name-only origin/main...HEAD)
$status = @(git status --porcelain | Where-Object { $_ -notmatch '^\?\? tools/' })
foreach ($path in $changed) { "SCOPE-CHANGED: $path" }
$forbiddenHits = @($changed | Where-Object { $forbidden -contains $_ })
$policyHits = @($changed | Where-Object { $candidate = $_; @($policyPrefixes | Where-Object { $candidate.StartsWith($_) }).Count -gt 0 })
$outside = @($changed | Where-Object { -not $_.StartsWith($feature) -and ($allowed -notcontains $_) })
foreach ($path in $outside) { "SCOPE-OUTSIDE: $path" }
foreach ($line in $status) { "SCOPE-PORCELAIN: $line" }
$history = @(git reflog show --format=%gs "refs/heads/$branch") + @(git reflog show --format=%gs "refs/remotes/origin/$branch")
$rewrites = @($history | Where-Object { $_ -match 'rebase|forced-update' })
git merge-base --is-ancestor $MergeCommit HEAD
$mergeContained = ($LASTEXITCODE -eq 0)
"SCOPE-FORBIDDEN-PRESENT: $($forbiddenHits.Count)"
"SCOPE-POLICY-PRESENT: $($policyHits.Count)"
"SCOPE-OUTSIDE-WRITE-SET: $($outside.Count)"
"SCOPE-PORCELAIN-ENTRIES: $($status.Count)"
"SCOPE-HISTORY-REWRITES: $($rewrites.Count)"
"SCOPE-MERGE-COMMIT-CONTAINED: $mergeContained"
$code = [int](($forbiddenHits.Count + $policyHits.Count + $outside.Count + $rewrites.Count) -gt 0 -or -not $mergeContained)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `SCOPE-FORBIDDEN-PRESENT: 0`, `SCOPE-POLICY-PRESENT: 0`, `SCOPE-OUTSIDE-WRITE-SET: 0`, `SCOPE-HISTORY-REWRITES: 0`, `SCOPE-MERGE-COMMIT-CONTAINED: True`, `EXIT_CODE_COMPUTED: 0`. `SCOPE-PORCELAIN-ENTRIES` is informational (the plan file and unstaged evidence appear there before a commit). `$embeddedAllowed` holds the two `LIST-SHELL-WRITTEN` paths that rule 4 keeps off the command line; the `-AllowedList` argument carries every other permitted path.

### cr-evidence.txt (CR-EVIDENCE, AC-31)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$feature = 'docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/'
$kinds = 'baseline|regression-testing|qa-gates|issue-updates|other|remediation-baseline'
$stamp = '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}'
$canonical = '^' + [regex]::Escape($feature) + 'evidence/(' + $kinds + ')/[^/]+\.' + $stamp + '\.md$'
$documents = '^' + [regex]::Escape($feature) + '(issue\.md|spec\.md|plan\.2026-10-16T10-27\.md|research/.+)$'
$tracked = @(git diff --name-only origin/main...HEAD)
$untracked = @(git status --porcelain --untracked-files=all | Where-Object { $_ -match '^\?\? ' } | ForEach-Object { $_.Substring(3) })
$all = @(@($tracked) + @($untracked) | Sort-Object -Unique)
$inFeature = @($all | Where-Object { $_.StartsWith($feature) })
$bad = @($inFeature | Where-Object { $_ -notmatch $canonical -and $_ -notmatch $documents })
$outside = @($all | Where-Object { -not $_.StartsWith($feature) -and $_ -match ('\.' + $stamp + '\.md$') })
foreach ($path in $bad) { "EVIDENCE-NONCANONICAL: $path" }
foreach ($path in $outside) { "EVIDENCE-OUTSIDE-FEATURE: $path" }
"EVIDENCE-FILES: $(@($inFeature | Where-Object { $_ -match $canonical }).Count)"
"EVIDENCE-NONCANONICAL-COUNT: $($bad.Count)"
"EVIDENCE-OUTSIDE-FEATURE-COUNT: $($outside.Count)"
$code = [int](($bad.Count + $outside.Count) -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: a positive `EVIDENCE-FILES:`, `EVIDENCE-NONCANONICAL-COUNT: 0`, `EVIDENCE-OUTSIDE-FEATURE-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-actionlint.txt (CR-ACTIONLINT, AC-25)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $PathList)
$ErrorActionPreference = 'Stop'
$paths = @($PathList.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
& pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 @paths
$wrapperExit = $LASTEXITCODE
"ACTIONLINT-WRAPPER-EXIT: $wrapperExit"
$binary = Get-Command actionlint -ErrorAction SilentlyContinue
$binaryPath = $null
if ($binary) { $binaryPath = $binary.Source }
elseif (Test-Path -LiteralPath 'tools/actionlint/bin/actionlint.exe') { $binaryPath = (Resolve-Path -LiteralPath 'tools/actionlint/bin/actionlint.exe').Path }
if ($null -eq $binaryPath) { 'ACTIONLINT-BINARY: absent'; 'EXIT_CODE_COMPUTED: 1'; exit 1 }
"ACTIONLINT-VERSION: $(@(& $binaryPath -version)[0])"
$findings = @(& $binaryPath -no-color -oneline @paths)
$directExit = $LASTEXITCODE
foreach ($finding in $findings) { "ACTIONLINT-FINDING: $finding" }
"ACTIONLINT-DIRECT-EXIT: $directExit"
"ACTIONLINT-FINDINGS: $($findings.Count)"
$code = [int](($wrapperExit -ne 0) -or ($directExit -ne 0) -or ($findings.Count -gt 0))
"EXIT_CODE_COMPUTED: $code"
exit $code
```

`scripts/dev-tools/run-actionlint.ps1` discards the binary's output (line 128) and exits non-zero exactly when the binary does (lines 159-161), so the direct run supplies the finding text. Success-case literals: `ACTIONLINT-WRAPPER-EXIT: 0`, `ACTIONLINT-DIRECT-EXIT: 0`, `ACTIONLINT-FINDINGS: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-quality-tiers.txt (CR-QUALITY-TIERS, AC-29)

```powershell
[CmdletBinding()]
param()
$output = @(& poetry run python -m scripts.dev_tools.check_quality_tiers 2>&1)
$exit = $LASTEXITCODE
foreach ($line in $output) { "QT-OUTPUT: $line" }
"QT-EXIT: $exit"
"QT-SCRIPTS-CI-ENTRY: $((Get-Content -Raw -LiteralPath 'quality-tiers.yml').Contains('path: "scripts/ci"'))"
"EXIT_CODE_COMPUTED: $exit"
exit $exit
```

`scripts/dev_tools/check_quality_tiers.py` lists tracked files with `git ls-files -z` (line 96) and prints `quality-tiers: OK (<n> entries, <m> discovered projects)` on success (lines 196-198). Success-case literals: `QT-OUTPUT: quality-tiers: OK`, `QT-EXIT: 0`, `EXIT_CODE_COMPUTED: 0`.

### cr-ac-status.txt (CR-AC-STATUS)

```powershell
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$lines = @(Get-Content -LiteralPath 'docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md')
$checked = 0
$unchecked = 0
foreach ($line in $lines) {
    if ($line -match '^- \[(?<state>[ x])\] (?<id>AC-\d+)') {
        if ($Matches['state'] -eq 'x') { $checked++; "AC-STATUS: $($Matches['id']) | checked" }
        else { $unchecked++; "AC-STATUS: $($Matches['id']) | unchecked" }
    }
}
"AC-CHECKED: $checked"
"AC-UNCHECKED: $unchecked"
"EXIT_CODE_COMPUTED: 0"
exit 0
```

Success-case literals: 38 `AC-STATUS:` lines, `AC-CHECKED:` and `AC-UNCHECKED:` summing to 38. The four D14 criteria use the same `- [ ] AC-<n>` line form (for example `- [ ] AC-35 (D14-a): ...`), so the recipe's pattern matches them.

### cr-shell-static.txt (CR-SHELL-STATIC, AC-37 and AC-38 local evidence)

```powershell
[CmdletBinding()]
param([switch] $LintInformational)
$ErrorActionPreference = 'Stop'
$lib = 'scripts/bash/shell_qc_lib.sh'
$wrapper = 'scripts/bash/shell-qc.sh'
$suite = 'tests/shell/test_shell_qc_commands.bats'
$shellFiles = @($lib, $wrapper, $suite)
$libLines = @(Get-Content -LiteralPath $lib)
$wrapperLines = @(Get-Content -LiteralPath $wrapper)
$suiteLines = @(Get-Content -LiteralPath $suite)
function Get-FragmentLineCount([string[]] $Lines, [string] $Fragment) { return @($Lines | Where-Object { $_.Contains($Fragment) }).Count }
$recursive = Get-FragmentLineCount $libLines '"$bats_bin" --recursive "$test_dir"'
$nonRecursive = Get-FragmentLineCount $libLines '"$bats_bin" "$test_dir"'
$thresholdFunction = @($libLines | Where-Object { $_ -ceq 'check_coverage_threshold() {' }).Count
$thresholdWiring = @($libLines | Where-Object { $_.Trim() -ceq 'check_coverage_threshold "$out_dir/cov.xml" || exit_code=$?' }).Count
$thresholdDefault = Get-FragmentLineCount $libLines 'SHELL_QC_MIN_LINE_COVERAGE:-85'
$usageLine = Get-FragmentLineCount $wrapperLines 'SHELL_QC_MIN_LINE_COVERAGE'
$nounsetUpdated = Get-FragmentLineCount $suiteLines 'ran: --recursive tests/shell'
$names = @('test passes --recursive to bats for each test directory', 'test --coverage passes --recursive to bats under kcov', 'check_coverage_threshold fails below the default 85 percent minimum', 'check_coverage_threshold passes when coverage equals the minimum', 'check_coverage_threshold passes when coverage is above the minimum', 'check_coverage_threshold rejects a minimum that is not an integer', 'check_coverage_threshold rejects a minimum above 100', 'check_coverage_threshold prints nothing and passes when cov.xml is missing')
$missing = @($names | Where-Object { $name = $_; @($suiteLines | Where-Object { $_ -ceq ('@test "' + $name + '" {') }).Count -ne 1 })
$testsRoot = (Resolve-Path -LiteralPath 'tests/shell').Path
$nestedFiles = @(Get-ChildItem -LiteralPath 'tests/shell' -Recurse -File | Where-Object { $_.Directory.FullName -ne $testsRoot })
$nestedBats = @($nestedFiles | Where-Object { $_.Extension -eq '.bats' })
$over = 0
$crlf = 0
foreach ($file in $shellFiles) {
    $count = @(Get-Content -LiteralPath $file).Count
    if ($count -gt 500) { $over++ }
    if ((Get-Content -Raw -LiteralPath $file).Contains([string][char]13)) { $crlf++; "SHELL-CRLF: $file" }
    "SHELL-LINES: $file | $count"
}
"SHELL-RECURSIVE-INVOCATIONS: $recursive"
"SHELL-NONRECURSIVE-INVOCATIONS: $nonRecursive"
"SHELL-THRESHOLD-FUNCTION: $thresholdFunction"
"SHELL-THRESHOLD-WIRING: $thresholdWiring"
"SHELL-THRESHOLD-DEFAULT-85: $thresholdDefault"
"SHELL-USAGE-THRESHOLD-LINE: $usageLine"
"SHELL-NOUNSET-ASSERTIONS-UPDATED: $nounsetUpdated"
foreach ($name in $missing) { "SHELL-NEW-TEST-MISSING: $name" }
"SHELL-NEW-TESTS-MISSING: $($missing.Count)"
foreach ($file in $nestedFiles) { "SHELL-NESTED-FILE: $($file.Directory.Name)/$($file.Name)" }
"SHELL-NESTED-BATS-FILES: $($nestedBats.Count)"
"SHELL-TESTS-BASH-DIR-EXISTS: $(Test-Path -LiteralPath 'tests/bash')"
"SHELL-LINES-OVER-500: $over"
"SHELL-CRLF-FILES: $crlf"
$lintRan = 0
$lintFailing = 0
$shellcheck = Get-Command shellcheck -ErrorAction SilentlyContinue
if ($shellcheck) {
    $out = @(& $shellcheck.Source $lib $wrapper 2>&1)
    $rc = $LASTEXITCODE
    foreach ($line in $out) { "SHELLCHECK: $line" }
    "SHELLCHECK-EXIT: $rc"
    $lintRan++
    if ($rc -ne 0) { $lintFailing++ }
}
else { 'SHELL-TOOL-ABSENT: shellcheck' }
$shfmt = Get-Command shfmt -ErrorAction SilentlyContinue
if ($shfmt) {
    $out = @(& $shfmt.Source -d $lib $wrapper 2>&1)
    $rc = $LASTEXITCODE
    foreach ($line in $out) { "SHFMT: $line" }
    "SHFMT-EXIT: $rc"
    $lintRan++
    if ($rc -ne 0) { $lintFailing++ }
}
else { 'SHELL-TOOL-ABSENT: shfmt' }
"SHELL-LOCAL-LINT: ran=$lintRan | failing=$lintFailing | informational=$([bool]$LintInformational)"
$lintOk = $LintInformational -or ($lintFailing -eq 0)
$ok = ($recursive -eq 2) -and ($nonRecursive -eq 0) -and ($thresholdFunction -eq 1) -and ($thresholdWiring -eq 1) -and ($thresholdDefault -eq 1) -and ($usageLine -eq 1) -and ($nounsetUpdated -eq 2) -and ($missing.Count -eq 0) -and ($nestedBats.Count -eq 0) -and ($over -eq 0) -and ($crlf -eq 0) -and $lintOk
$code = if ($ok) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

The recipe reads the three `LIST-SHELL-WRITTEN` files as text; it runs no bash, bats, or kcov. The fragment `'"$bats_bin" "$test_dir"'` does not occur inside the recursive form, so the two counts are independent. Success-case literals (after Phase 5): `SHELL-RECURSIVE-INVOCATIONS: 2`, `SHELL-NONRECURSIVE-INVOCATIONS: 0`, `SHELL-THRESHOLD-FUNCTION: 1`, `SHELL-THRESHOLD-WIRING: 1`, `SHELL-THRESHOLD-DEFAULT-85: 1`, `SHELL-USAGE-THRESHOLD-LINE: 1`, `SHELL-NOUNSET-ASSERTIONS-UPDATED: 2`, `SHELL-NEW-TESTS-MISSING: 0`, `SHELL-NESTED-BATS-FILES: 0`, `SHELL-LINES-OVER-500: 0`, `SHELL-CRLF-FILES: 0`, a `SHELL-LOCAL-LINT:` line, and `EXIT_CODE_COMPUTED: 0`. At baseline (unchanged files) the expected values are `SHELL-RECURSIVE-INVOCATIONS: 0`, `SHELL-NONRECURSIVE-INVOCATIONS: 2`, `SHELL-THRESHOLD-FUNCTION: 0`, `SHELL-NOUNSET-ASSERTIONS-UPDATED: 0`, `SHELL-NEW-TESTS-MISSING: 8`, `SHELL-NESTED-FILE: helpers/codex_web_setup_common.bash`, `SHELL-NESTED-BATS-FILES: 0`, `SHELL-TESTS-BASH-DIR-EXISTS: False`, and `EXIT_CODE_COMPUTED: 1`. `-LintInformational` is passed only when the P0-T18 baseline recorded a failing local lint on the unchanged files (local tool versions can differ from CI, which is canonical per `.claude/rules/shell.md`); the CI `Run shell-qc check` step remains the lint gate.

### cr-kcov-file.txt (CR-KCOV-FILE, AC-38 per-file bash coverage from a downloaded CI artifact)

```powershell
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $ReportDir, [Parameter(Mandatory = $true)][string] $FileSuffix, [int] $Threshold = 85)
$ErrorActionPreference = 'Stop'
$report = Get-ChildItem -LiteralPath $ReportDir -Recurse -File -Filter 'cov.xml' | Sort-Object -Property { $_.FullName.Length } | Select-Object -First 1
if ($null -eq $report) { 'KCOV-REPORT: absent'; 'EXIT_CODE_COMPUTED: 1'; exit 1 }
'KCOV-REPORT: present'
[xml] $xml = Get-Content -Raw -LiteralPath $report.FullName
$totalRate = [double]::Parse($xml.DocumentElement.GetAttribute('line-rate'), [Globalization.CultureInfo]::InvariantCulture)
"KCOV-TOTAL: percent=$([math]::Round(100 * $totalRate, 1))"
$classes = @($xml.SelectNodes('//class') | Where-Object { ($_.GetAttribute('filename') -replace '\\', '/').EndsWith('/' + $FileSuffix) -or ($_.GetAttribute('filename') -ceq $FileSuffix) })
"KCOV-FILE-MATCHES: $($classes.Count)"
if ($classes.Count -ne 1) { 'EXIT_CODE_COMPUTED: 1'; exit 1 }
$rate = [double]::Parse($classes[0].GetAttribute('line-rate'), [Globalization.CultureInfo]::InvariantCulture)
$percent = [math]::Round(100 * $rate, 1)
$verdict = if ($percent -ge $Threshold) { 'PASS' } else { 'FAIL' }
"KCOV-FILE: $FileSuffix | percent=$percent | threshold=$Threshold | $verdict"
$code = [int]($verdict -ne 'PASS')
"EXIT_CODE_COMPUTED: $code"
exit $code
```

`-ReportDir` is the directory into which P7-T4 downloads the `shell-coverage` artifact (under `SCRATCH/stage/`); the recipe prints the file suffix, never the report's absolute file names (rule 2). The class-level `filename` and `line-rate` attributes are the Cobertura form that kcov writes, but no kcov report of this repository was observed locally, so this recipe has no rule 6 reference observation before P7-T4: its first run is the observation, and `KCOV-REPORT: absent` or `KCOV-FILE-MATCHES:` other than 1 records the coverage value as unavailable (`BASH-CHANGED-FILE-COVERAGE: UNAVAILABLE`), which makes AC-38 remediation-required, never PASS. Success-case literals: `KCOV-REPORT: present`, a numeric `KCOV-TOTAL: percent=` line, `KCOV-FILE-MATCHES: 1`, a `KCOV-FILE:` line ending `PASS`, `EXIT_CODE_COMPUTED: 0`.

## 6. Production contracts (scripts/ci)

### scripts/ci/CiChangeScope.psm1 (pure; no git, gh, file, process, or network call)

Top: `Set-StrictMode -Version Latest`. Bottom: `Export-ModuleMember -Function` with exactly the eight names below. Every function is an advanced function with `[CmdletBinding()]` and `[OutputType()]`.

- **F1 `Test-CiChangeScopeEventEligible -EventName -HeadRepository -Repository`** (all `[AllowEmptyString()][string]`). Returns `'EVENT_NOT_PULL_REQUEST'` when `EventName -cne 'pull_request'`; else `'FORK_PULL_REQUEST'` when `HeadRepository` is blank or not equal to `Repository` under `[StringComparison]::OrdinalIgnoreCase`; else `$null`.
- **F2 `ConvertFrom-CiDocsOnlyPathConfig -Json`** (`[AllowEmptyString()][string]`). Returns `[pscustomobject]@{ Version; IncludePrefixes; ExcludePrefixes; Extensions }` with extensions lower-cased (`ToLowerInvariant`). Throws, with messages beginning `CI_DOCS_ONLY_CONFIG_INVALID: `: `malformed JSON` (blank text, a parse failure, or a non-object root); `version must be 1`; `include_prefixes must be a non-empty array of non-blank strings`; `exclude_prefixes must be an array of non-blank strings` (an empty array is valid); `extensions must be a non-empty array`; `extension '<value>' must start with '.'`.
- **F3 `Test-CiDocsOnlyPath -Path -Config`** returns `[bool]`, false in this order: blank path; path contains `\`; path starts with `/`; any `/`-separated segment equals `..`; no include prefix matches by `StartsWith(<prefix>, [StringComparison]::Ordinal)`; any exclude prefix matches the same way; the last segment has no `.` after its first character; the lower-cased text from the last `.` of the last segment is not in `Extensions`. Otherwise true.
- **F4 `ConvertFrom-CiNulPathList -Text`** (`[AllowNull()][AllowEmptyString()][string]`) returns `[pscustomobject]@{ Valid; Paths }`: empty or null text gives `Valid = $true`, `Paths = @()`; text not ending in `[char]0` gives `Valid = $false`; otherwise the text without its final NUL is split on `[char]0`, and an empty entry gives `Valid = $false`.
- **F5 `Get-CiChangeScopePathDecision -Paths -Config`** (`[AllowEmptyCollection()][string[]]`) returns `'EMPTY_DIFF'` for zero paths, `"NON_ALLOWLISTED_PATH: <first path in input order that F3 rejects>"`, or `$null` when all paths pass F3.
- **F6 `Select-CiGreenBaseCandidates -RunsJson -CurrentRunId -Repository`** (PD-6 suppression) parses the runs payload; throws `CI_RUN_LIST_INVALID: malformed JSON` for blank or unparseable text and `CI_RUN_LIST_INVALID: workflow_runs is missing` when the `workflow_runs` property is absent. Keeps a run only when `[string]id -cne CurrentRunId`, `conclusion -ceq 'success'`, `head_repository.full_name` equals `Repository` under OrdinalIgnoreCase, and `head_sha` is non-blank. Returns `[pscustomobject]@{ Id = [string]; RunNumber = [long]; HeadSha = [string] }` items sorted by `RunNumber` descending.
- **F7 `Test-CiFullRunMarker -JobsJson [-MarkerName 'CI full run']`** throws `CI_JOB_LIST_INVALID: malformed JSON` or `CI_JOB_LIST_INVALID: jobs is missing`; returns `$true` only when some job has `name -ceq MarkerName` and `conclusion -ceq 'success'`.
- **F8 `New-CiChangeScopeDecision -Code [bool] -Reason [string] [-BaseSha [string] = '']`** (PD-6 suppression) returns `[pscustomobject]@{ Code; Reason; BaseSha; OutputLine; LogLine; SummaryText }` where `Code` is `'true'` or `'false'`, `OutputLine = "code=<Code>"`, `LogLine = "code=<Code> reason=<Reason>"`, and `SummaryText = "Change scope: code=<Code>; reason=<Reason>; base=<BaseSha, or none when blank>"`. Throws `CI_CHANGE_SCOPE_DECISION_INVALID: code=false requires a DOCS_ONLY_SINCE_ reason` when `Code` is false and `Reason` does not start with `DOCS_ONLY_SINCE_`.

### scripts/ci/Invoke-CiChangeScope.ps1 (thin I/O entry point)

Top: `Set-StrictMode -Version Latest`, then `Import-Module (Join-Path $PSScriptRoot 'CiChangeScope.psm1') -Force`. The script defines the functions below and ends with the dot-source guard (precedent `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` lines 390-401):

```powershell
if ($MyInvocation.InvocationName -ne '.') {
    $null = Invoke-CiChangeScope -Context (Get-CiChangeScopeContext)
    exit 0
}
```

- **F9 `Invoke-CiChangeScopeNative -FileName -ArgumentList`** runs `& $FileName @ArgumentList 2>$null`, collects the lines, and returns `[pscustomobject]@{ ExitCode = [int]$LASTEXITCODE; Output = <lines joined with LF> }`. This is the only process boundary; tests never call it.
- **F10 `Write-CiChangeScopeTarget -Target -Text [-ReadVariable]`** with `[ValidateSet('Output', 'Summary', 'Log', 'Warning')]` and `-ReadVariable` defaulting to `{ param([string] $Name) [Environment]::GetEnvironmentVariable($Name) }`. `Output` appends `Text` with `Add-Content -LiteralPath <GITHUB_OUTPUT>`; `Summary` appends to `<GITHUB_STEP_SUMMARY>`; when that variable is blank, the text goes to `Write-Information -MessageData "[<Target>] <Text>" -InformationAction Continue` instead. `Log` writes `Write-Information -MessageData <Text> -InformationAction Continue`. `Warning` writes `Write-Information -MessageData "::warning::<Text>" -InformationAction Continue`.
- **F11 `Get-CiChangeScopeContext [-ReadVariable]`** returns `@{ EventName; HeadSha; HeadRef; HeadRepository; Repository; RunId }` read from `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO`, `REPOSITORY`, `RUN_ID`. `Read-CiChangeScopeConfigText [-Path]` returns `Get-Content -Raw` of `-Path`, defaulting to `Join-Path $PSScriptRoot '../../config/ci-docs-only-paths.json'`.
- **F12 `Invoke-CiChangeScope -Context [hashtable] [-ConfigJson [string]] [-GhInvoker] [-GitInvoker] [-OutputWriter]`** with defaults `{ Invoke-CiChangeScopeNative -FileName 'gh' -ArgumentList $args }`, `{ Invoke-CiChangeScopeNative -FileName 'git' -ArgumentList $args }`, and `{ param([string] $Target, [string] $Text) Write-CiChangeScopeTarget -Target $Target -Text $Text }`. Inside one `try`, it decides in this order and stops at the first decision (helper functions are allowed):
  1. F1 reason present: `code=true` with that reason; no invoker call.
  2. Blank `HeadSha`, `HeadRef`, `Repository`, or `RunId`: throw `CI_CHANGE_SCOPE_CONTEXT_INVALID: <name> is blank`.
  3. Config text is `-ConfigJson` when bound (`$PSBoundParameters.ContainsKey('ConfigJson')`), else `Read-CiChangeScopeConfigText`; parse with F2 (a throw reaches the envelope).
  4. `& $GhInvoker 'api' "repos/<Repository>/actions/workflows/ci.yml/runs?branch=<[uri]::EscapeDataString(HeadRef)>&event=pull_request&status=success&per_page=50"`; a non-zero exit or an F6 throw gives `RUN_LIST_FAILED`.
  5. For each F6 candidate in order: `& $GhInvoker 'api' "repos/<Repository>/actions/runs/<Id>/jobs?filter=latest&per_page=100"`; a non-zero exit or an F7 throw gives `JOB_LIST_FAILED`; the first candidate for which F7 is true is the base. No base gives `NO_FULL_GREEN_RUN`.
  6. `& $GitInvoker 'cat-file' '-e' "<base>^{commit}"` non-zero gives `BASE_NOT_PRESENT`. `& $GitInvoker 'merge-base' '--is-ancestor' <base> <HeadSha>` exit 1 gives `BASE_NOT_ANCESTOR`; any other non-zero gives `ANCESTRY_CHECK_FAILED`.
  7. `& $GitInvoker 'diff' '--name-only' '-z' '--no-renames' '--no-color' '--no-ext-diff' '--no-relative' <base> <HeadSha>`; a non-zero exit or F4 `Valid = $false` gives `DIFF_FAILED`.
  8. F5: `EMPTY_DIFF` or `NON_ALLOWLISTED_PATH: <path>` gives `code=true`; `$null` gives `code=false` with reason `DOCS_ONLY_SINCE_<base>` and `BaseSha = <base>`.
  The `catch` builds `code=true` with reason `UNEXPECTED_ERROR` and calls `& $OutputWriter 'Warning' "Change scope failed closed: <exception message>"`. After the decision, it calls `& $OutputWriter 'Output' <OutputLine>`, `& $OutputWriter 'Log' <LogLine>`, `& $OutputWriter 'Summary' <SummaryText>`, and returns the F8 object. It never throws to its caller.

## 6a. Shell QC edits (D14-c and D14-d; S1 to S4)

Line numbers are those of the head at revision time (`e07e235d5`), re-derived in revision 4. `scripts/bash/*.sh` use tab indentation (shfmt default); `tests/shell/*.bats` use four spaces. Every edit is made with the Edit tool; the files keep LF line endings (`.gitattributes` line 1, `* text=auto eol=lf`), which CR-SHELL-STATIC checks.

**S1 (D14-c) `scripts/bash/shell_qc_lib.sh`, recursive discovery.**

- Line 262 `		BASH_ENV="$trace_env" BASH_XTRACEFD="$trace_fd" "$bats_bin" "$test_dir" || rc=$?` becomes `		BASH_ENV="$trace_env" BASH_XTRACEFD="$trace_fd" "$bats_bin" --recursive "$test_dir" || rc=$?`.
- Line 365 `			"$run_dir" "$bats_bin" "$test_dir" || rc=$?` becomes `			"$run_dir" "$bats_bin" --recursive "$test_dir" || rc=$?`.
- In the `run_test` comment, directly after line 233 (`	# fails, and the maximum exit code is returned.`), insert:

```bash
	# bats receives --recursive, so .bats files in subdirectories of a test directory are
	# collected as well as top-level ones (issue #962).
```

**S2 (D14-d) `scripts/bash/shell_qc_lib.sh`, coverage threshold.**

- Directly after the closing `}` of `print_coverage_summary` (line 307) and its following blank line, insert this function followed by one blank line, so it sits between `print_coverage_summary` and `run_test_coverage`:

```bash
check_coverage_threshold() {
	# Enforce the minimum bash line coverage on a Cobertura cov.xml (issue #962).
	#
	# The minimum is SHELL_QC_MIN_LINE_COVERAGE, an integer percentage from 0 to 100,
	# defaulting to 85 (the repository line-coverage default). The comparison uses the
	# one-decimal percentage that print_coverage_summary prints. A missing or unparseable
	# cov.xml prints nothing and returns 0, matching print_coverage_summary.
	#
	# Args: $1 = path to cov.xml.
	# Returns 0 when coverage meets the minimum, 1 when it is below, and 2 when the
	# minimum is not an integer from 0 to 100.
	local cov_xml="$1"
	local minimum=${SHELL_QC_MIN_LINE_COVERAGE:-85}
	if [[ ! $minimum =~ ^[0-9]+$ ]] || ((10#$minimum > 100)); then
		printf 'Invalid SHELL_QC_MIN_LINE_COVERAGE: %s (expected an integer from 0 to 100).\n' "$minimum"
		return 2
	fi
	local rate
	if ! rate=$(extract_cobertura_line_rate "$cov_xml"); then
		return 0
	fi
	local percent
	percent=$(awk -v r="$rate" 'BEGIN { printf "%.1f", r * 100 }')
	# awk exits 0 when the printed percentage is at least the integer minimum.
	if awk -v p="$percent" -v m="$minimum" 'BEGIN { exit !(p + 0 >= m + 0) }'; then
		printf 'Bash coverage %s%% meets the minimum line coverage of %s%%.\n' "$percent" "$minimum"
		return 0
	fi
	printf 'Bash coverage %s%% is below the minimum line coverage of %s%%.\n' "$percent" "$minimum"
	return 1
}
```

- In the `run_test_coverage` comment, directly after line 318 (`	# single cov.xml. The transient .kcov_runs directory is always removed.`), insert:

```bash
	# bats receives --recursive (issue #962). After the summary, check_coverage_threshold
	# enforces the minimum line coverage, and its non-zero status becomes the return value.
```

- Lines 389-392 (the comment `	# On overall success, emit the one-line coverage summary when cov.xml is parseable.` through the matching `	fi`) become:

```bash
	# On overall success, emit the one-line coverage summary when cov.xml is parseable,
	# then enforce the minimum line coverage on the same report.
	if ((exit_code == 0)); then
		print_coverage_summary "$out_dir/cov.xml"
		check_coverage_threshold "$out_dir/cov.xml" || exit_code=$?
	fi
```

The file grows from 394 lines to 432 (2 + 32 + 2 + 2 added lines).

**S3 (D14-d) `scripts/bash/shell-qc.sh`, usage text.** Directly after line 36 (`  SHELL_QC_KCOV_OUT_DIR  Coverage output directory (default artifacts/pester/kcov).`), inside the `usage` here-document, insert:

```text
  SHELL_QC_MIN_LINE_COVERAGE
                         Minimum line coverage for test --coverage, an integer
                         percentage from 0 to 100 (default 85).
```

The file grows from 103 lines to 106.

**S4 (D14-c and D14-d) `tests/shell/test_shell_qc_commands.bats`.**

- Line 180 `    [[ "$output" == *"nounset-stub ran: tests/shell"* ]]` becomes `    [[ "$output" == *"nounset-stub ran: --recursive tests/shell"* ]]`, and line 190 `    [[ "$output" == *"nounset-reset-stub ran: tests/shell"* ]]` becomes `    [[ "$output" == *"nounset-reset-stub ran: --recursive tests/shell"* ]]` (both stubs echo their argv, which now starts with the flag).
- After the last line of the file (line 204, the closing `}` of `kcov_trace_env.sh sets the kcov PS4 format`), append one blank line and these eight tests, separated by single blank lines:

```bash
@test "test passes --recursive to bats for each test directory" {
    # Issue #962 follow-up (c): bats collects only the top-level files of a directory
    # unless --recursive is given, so the wrapper passes it for every test directory.
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test"
    [ "$status" -eq 0 ]
    [[ "$output" == *"bats --recursive tests/shell"* ]]
}

@test "test --coverage passes --recursive to bats under kcov" {
    # Issue #962 follow-up (c): the coverage path collects nested test files as well.
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats" SHELL_QC_KCOV_BIN="${STUB_DIR}/kcov" \
        SHELL_QC_KCOV_OUT_DIR="${KCOV_OUT}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test --coverage"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stub-bin/bats --recursive tests/shell"* ]]
}

@test "check_coverage_threshold fails below the default 85 percent minimum" {
    # Issue #962 follow-up (d): the fixture cov.xml reports 75.0%, below the default.
    run env -u SHELL_QC_MIN_LINE_COVERAGE \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 1 ]
    [ "$output" = "Bash coverage 75.0% is below the minimum line coverage of 85%." ]
}

@test "check_coverage_threshold passes when coverage equals the minimum" {
    run env SHELL_QC_MIN_LINE_COVERAGE=75 \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 0 ]
    [ "$output" = "Bash coverage 75.0% meets the minimum line coverage of 75%." ]
}

@test "check_coverage_threshold passes when coverage is above the minimum" {
    run env SHELL_QC_MIN_LINE_COVERAGE=70 \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 0 ]
    [ "$output" = "Bash coverage 75.0% meets the minimum line coverage of 70%." ]
}

@test "check_coverage_threshold rejects a minimum that is not an integer" {
    run env SHELL_QC_MIN_LINE_COVERAGE=abc \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 2 ]
    [ "$output" = "Invalid SHELL_QC_MIN_LINE_COVERAGE: abc (expected an integer from 0 to 100)." ]
}

@test "check_coverage_threshold rejects a minimum above 100" {
    run env SHELL_QC_MIN_LINE_COVERAGE=101 \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 2 ]
    [ "$output" = "Invalid SHELL_QC_MIN_LINE_COVERAGE: 101 (expected an integer from 0 to 100)." ]
}

@test "check_coverage_threshold prints nothing and passes when cov.xml is missing" {
    run env -u SHELL_QC_MIN_LINE_COVERAGE \
        bash -c "source '${LIB}' && check_coverage_threshold '${FIXTURE_ROOT}/cov/missing.xml'"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
```

The fixture `tests/fixtures/shell_qc/cov/cov.xml` carries `line-rate="0.75"` (line 2), which `print_coverage_summary` already renders as `75.0%` (existing test at line 143). The stub `tests/fixtures/shell_qc/stub-bin/bats` echoes `bats $*` (line 5) and the kcov stub echoes `kcov $*` and writes no report (lines 6-7), so the coverage-path test reaches the threshold call with no `cov.xml` and still exits 0. Before S1 and S2 every one of the eight new tests and the two changed assertions fails (no flag in the stub argv; `check_coverage_threshold` undefined, status 127). The suite grows from 204 lines to 265 and from 22 tests to 30. No test creates a file; the `missing.xml` path is never created.

## 7. Workflow gating (G0 to G7)

### G0. `run-heavy` input block (each of the six reusable workflows)

The `on:` block of each reusable workflow becomes the following. If the post-merge `on:` block already declares `inputs:` under a trigger, `run-heavy` is added to that map with the same lines.

```yaml
on:
  workflow_call:
    inputs:
      run-heavy:
        description: "Run the heavy steps. ci.yml passes false only for a docs-only change scope."
        required: false
        type: boolean
        default: true
  workflow_dispatch:
    inputs:
      run-heavy:
        description: "Run the heavy steps. ci.yml passes false only for a docs-only change scope."
        required: false
        type: boolean
        default: true
```

### G1 to G5. Step gating in the five single-job workflows

Every step of the named job receives `if: ${{ inputs.run-heavy }}` (PD-5) except these exact replacements:

- G1 `.github/workflows/_quality-checks.yml`, job `quality-checks7`: step `Install dependencies` gets `if: ${{ inputs.run-heavy && steps.cached-poetry-dependencies.outputs.cache-hit != 'true' }}` (replacing line 39 today); step `Upload coverage to Codecov` gets `if: ${{ inputs.run-heavy && matrix.python-version == '3.13' }}` (replacing line 95 today).
- G2 `.github/workflows/_security-scan.yml`, job `security-scan` (D14-b, PD-18): the first three steps receive `if: ${{ inputs.run-heavy }}` per PD-5. Directly before the step `Check for security vulnerabilities` (line 26 today), a new step is inserted, followed by one blank line:

  ```yaml
        - name: Install the Poetry export plugin
          if: ${{ inputs.run-heavy }}
          run: poetry self add poetry-plugin-export
  ```

  and lines 26-30 today (the scan step, ending with `        continue-on-error: true`) become exactly:

  ```yaml
        - name: Check for security vulnerabilities
          if: ${{ inputs.run-heavy }}
          shell: bash
          run: |
            poetry run pip install safety
            poetry export -f requirements.txt --without-hashes | poetry run safety check --stdin
  ```

  (the six-space step indentation of the file is kept; the two-space indentation of these blocks inside this list item is not part of the YAML). No `continue-on-error` line remains in the file. Safety stays the scanner; no new dependency is added.
- G3 `.github/workflows/_build-check.yml`, job `build-check`: no exception.
- G4 `.github/workflows/_shell-coverage.yml`, job `shell-coverage`: step `Build kcov from source` gets `if: ${{ inputs.run-heavy && steps.cache-kcov.outputs.cache-hit != 'true' }}` (replacing line 34 today); the upload step with `if-no-files-found: error` (lines 57-62 today) is gated like every other step.
- G5 `.github/workflows/_drm-copilot-extension-tests.yml`, job `drm-copilot-extension-tests`: no exception.

### G6. `.github/workflows/_poshqc.yml` (shape from `POSHQC-SHAPE:` of the latest edit-points artifact, PD-16)

In both shapes, a job that receives a job-level gate keeps every step-level condition unchanged, including `if: always()` (PD-15).

**G6-main (`POSHQC-SHAPE: main`; the shape of the head at revision time, lines cited from it).** The `poshqc` job (`name: PowerShell QC`, line 9; it reports the required context `poshqc / PowerShell QC`) receives no job-level `if:`. Each of its six steps receives `        if: ${{ inputs.run-heavy }}` on the line directly after its `- name:` line: `Check out repository` (line 13), `Install PoshQC tooling` (16), `Format PowerShell` (22), `Analyze PowerShell` (32), `Test PowerShell` (38), and `Upload PowerShell test artifacts` (44; it has no condition today, so it receives the plain gate). Under `run-heavy: false` the job runs with every step skipped and reports `success`; under `true` it behaves as today. The `poshqc-linux-hooks` job (not a required context) receives `    if: ${{ inputs.run-heavy }}` on the line directly after `    name: PowerShell hook suites (Linux)` (line 55), so its `permissions:` and `contents: read` lines stay adjacent; its steps are unchanged, and its upload step keeps `if: always()` (line 85).

**G6-sharded (`POSHQC-SHAPE: sharded`, #953).** `poshqc-static`, `poshqc-shard`, and `poshqc-linux-hooks` each receive the job-level line `if: ${{ inputs.run-heavy }}` directly after their `name:` line (combined per PD-5 if a job-level `if:` exists); their step conditions are unchanged (PD-15), so the shard upload step keeps `if: always()`. The `poshqc` aggregator keeps its job-level `if: always()` line unchanged, and every aggregator step, including the step whose name begins `Require` (recorded by P0-T9), receives `if: ${{ inputs.run-heavy }}`; an aggregator step whose condition is `always()` becomes `if: ${{ always() && inputs.run-heavy }}` (PD-5).

### G7. `.github/workflows/ci.yml` (`on:` block untouched)

Insert the following two jobs directly after the `jobs:` line:

```yaml
  changes:
    name: Change scope
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
    outputs:
      code: ${{ steps.scope.outputs.code }}
    steps:
      - name: Check out the pull request head
        uses: actions/checkout@v7
        with:
          ref: ${{ github.event.pull_request.head.sha || github.sha }}
          fetch-depth: 0
          filter: blob:none
          persist-credentials: false

      - name: Decide the change scope
        id: scope
        shell: pwsh
        continue-on-error: true
        env:
          GH_TOKEN: ${{ github.token }}
          EVENT_NAME: ${{ github.event_name }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha || github.sha }}
          HEAD_REF: ${{ github.head_ref }}
          HEAD_REPO: ${{ github.event.pull_request.head.repo.full_name }}
          REPOSITORY: ${{ github.repository }}
          RUN_ID: ${{ github.run_id }}
        run: |
          ./scripts/ci/Invoke-CiChangeScope.ps1
          exit 0

  full-run-marker:
    name: CI full run
    needs: changes
    if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}
    runs-on: ubuntu-latest
    steps:
      - name: Record that the heavy jobs run in full
        run: echo "The heavy CI jobs run in full for this commit."

```

The explicit `exit 0` follows `.claude/rules/ci-workflows.md` (a nested `git merge-base --is-ancestor` exit 1 must not leak). Each of `quality-checks7`, `security-scan`, `build-check`, `poshqc`, `shell-coverage`, and `drm-copilot-extension-tests` receives, directly after its job-id line, `    needs: changes` and `    if: ${{ !cancelled() }}`, and after its `uses:` line a `with:` block (or an added entry in an existing one) `      run-heavy: ${{ needs.changes.outputs.code != 'false' }}`. `root-typescript-tests` receives `    needs: changes` and `    if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}` directly after its job-id line; `npm-audit-gate` receives the same two lines directly after its `name:` line, and its `permissions:` and `with: audit-level: moderate` are unchanged. `docs-validation` is unchanged. Any job present after the merge that is not one of the nine is left unchanged.

### A1 to A4. Existing contract-test adjustments (PD-13, PD-14, PD-15)

Revision 4 status: A1 is unconditional. A2 applies only when `A2-APPLICABLE: yes` (the #952 row is on the head at P4-T7); otherwise P4-T7 records `A2 not applicable on this HEAD`. A3 is withdrawn (PD-15: the shard upload step keeps `if: always()` inside its job-gated job, so the A3 row passes unchanged). A4 and A4C apply only when `POSHQC-SHAPE: sharded`; otherwise P4-T6 records `A4 not applicable on this HEAD`. Main-shape re-derivation (revision 4, against `e07e235d5`): in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, the job-set row (lines 50-52) partitions jobs at two-space keys, which G6-main does not add; the `poshqc` row (lines 54-60) asserts the four-space `name:` and `runs-on:` lines and two texts that G6-main keeps; the `poshqc-linux-hooks` rows (lines 62-94) assert the `name:` and `runs-on:` lines (both kept; the job-level `if:` is inserted between them, and the multiline patterns do not require adjacency), the adjacent `permissions:`/`contents: read` pair at line 70 (kept adjacent because the `if:` is inserted after `name:`), and run-step texts that G6-main does not change. In `tests/scripts/workflows/CiWorkflow.Tests.ps1`, both rows (lines 149-173) read only the `on:` block, which G7 does not change. No main-shape adjustment is therefore needed in either suite.

Search recorded for preflight D4: the tree under `tests/` (excluding `tests/fixtures/`) was searched for every reference to `ci.yml` and the six reusable workflow files, in the current tree and in the #952 and #953 branch copies. Files that read one of them: `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `tests/scripts/dev_tools/test_ruff_config_alignment.py`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`, and (on the #953 copy) `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`; `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` enumerates every workflow file for `NPM_TOKEN` and `NODE_AUTH_TOKEN` references, which G0 to G7 do not add. Of these, exactly three files pin a condition or a condition-adjacent line that G0 to G7 change, and they take four adjustments: A1, A2, A3, and A4 (A3 and A4 are in the same file). A4 was added in revision 2 (preflight round 2, R1): the `BeforeAll` helper `$script:GetResultGateViolation` of `PoshQcWorkflow.Tests.ps1` reports any step-level `if:` on the aggregator gate step, which G6 gives `if: ${{ inputs.run-heavy }}`. The revision-2 re-check of the #953 branch at `1f208b4e5baa6d1815877343823418f971c7ba78` read every row of `PoshQcWorkflow.Tests.ps1` against G6: rows `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS` (counts only four-space job-level `if: always()` lines), `WF04-SHARD-COUNT-FROM-MATRIX`, `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT`, the job-set row, and the `poshqc-linux-hooks` rows (the job-level `if:` is inserted after `name:`, so the `permissions:`/`contents: read` pair stays adjacent) are unaffected; under the revision-3 G6 only the A3 line and the two A4 lines changed, and under the revision-4 G6-sharded only the two A4 lines change (A3 withdrawn; A4 replaces the helper's condition line and, since revision 3 (preflight round 3, D1), the helper comment line that describes it). `test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step` asserts only that a Ruff invocation line exists, which gating keeps; `hook-docs-only-diff.Tests.ps1` uses `.github/workflows/ci.yml` as a path literal in test data; `PoshQC.RunSettings.Tests.ps1` row `RS07-WORKFLOW-LINUX-PESTER-RANGE` counts `Import-Module Pester` lines, which G6 does not add. Those files are not edited; the Pester ones run in `LIST-EXISTING-SUITES` and the Python ones in `LIST-PY-WORKFLOW-TESTS`.

**A1. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (P4-T9).** Add the module constant `RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"` directly after the line `CODECOV_ACTION = "codecov/codecov-action"` (line 26 of the current tree), and replace the body of `test_threshold_step_runs_on_every_matrix_leg` (lines 134-143) with exactly:

```python
def test_threshold_step_runs_on_every_matrix_leg() -> None:
    """The enforcement step must not be conditioned onto one matrix leg.

    Scenario: the step running the threshold checker is inspected for its
    condition, per decision D3 of the spec. The only permitted condition is the
    issue #962 run-heavy gate, whose value is the same on every matrix leg.
    Expected outcome: the step's ``if`` value equals the run-heavy gate exactly;
    an absent key or any other condition fails.
    """
    step = step_running(THRESHOLD_CHECKER_MODULE)

    assert step.get("if") == RUN_HEAVY_GATE, (
        "the threshold step must carry exactly the run-heavy gate, found "
        f"{step.get('if')!r}"
    )
```

No other line of the file changes. `yaml.safe_load` reads the G1 line `if: ${{ inputs.run-heavy }}` as the string `${{ inputs.run-heavy }}`.

**A2. `tests/scripts/workflows/CiWorkflow.Tests.ps1` (P4-T7, #952 shape; only when `A2-APPLICABLE: yes`).** In the row `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` (lines 212-239 of the #952 branch copy), the line

`            $eventFieldLines = @($graphLines | Where-Object { $_ -match 'github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name' })`

(line 232 of that copy) is replaced by the following lines, at the same indentation:

```powershell
            # Issue #962: the ci.yml 'changes' job reads these five pull-request fields only with
            # merge_group-safe fallbacks, and its decision returns code=true for every event other
            # than pull_request before it uses them. Exactly these lines, once each, are allowed.
            $allowedEventFieldLines = @()
            if ($graphFile -eq $script:workflowPath) {
                $allowedEventFieldLines = @(
                    'ref: ${{ github.event.pull_request.head.sha || github.sha }}'
                    'EVENT_NAME: ${{ github.event_name }}'
                    'HEAD_SHA: ${{ github.event.pull_request.head.sha || github.sha }}'
                    'HEAD_REF: ${{ github.head_ref }}'
                    'HEAD_REPO: ${{ github.event.pull_request.head.repo.full_name }}'
                )
            }
            $allowedHits = @($graphLines | Where-Object { $allowedEventFieldLines -ccontains $_.Trim() })
            $eventFieldLines = @($graphLines | Where-Object { $_ -match 'github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name' } | Where-Object { $allowedEventFieldLines -cnotcontains $_.Trim() })
```

and directly after the existing line `            $eventFieldLines.Count | Should -Be 0 -Because "$graphFile must not read a pull-request event field, which a merge_group run does not carry"` (line 236 of that copy) this line is inserted:

```powershell
            $allowedHits.Count | Should -Be $allowedEventFieldLines.Count -Because "$graphFile must carry each issue #962 change-scope event-field line exactly once"
```

The row name and every other line are unchanged. The five allowed lines are exactly the G7 lines that match the suite's event-field pattern (`ref:` of the checkout step and `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO` of the decision step); any other event-field line in `ci.yml` or any event-field line in a called workflow still fails the row. If the post-merge copy of this row differs from the text quoted above, P4-T7 stops BLOCKED and requests a plan revision.

**A3. Withdrawn in revision 4 (PD-15).** The row `runs Invoke-PoshQCTest with the shard parameters and uploads the shard results even on failure (issue #953)` of the #953 copy asserts `if: always()` directly before the shard upload's `uses:` line; G6-sharded leaves that step condition unchanged because the `poshqc-shard` job carries the job-level gate, so the row is not edited.

**A4. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (P4-T6, #953 shape only; preflight round 2, R1).** In the `BeforeAll` helper `$script:GetResultGateViolation` (lines 52-96 of the #953 branch copy at `1f208b4e5baa6d1815877343823418f971c7ba78`), which rows `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE` (lines 177-180) and `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS` (lines 182-199) call, the line

`            if ($gate -match '(?m)^ {8}if:') {`

(line 85 of that copy) is replaced by exactly:

`            if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {`

Cause: G6 gives every aggregator step, including the gate step `Require the static and shard jobs to succeed` (line 82 of the #953 `_poshqc.yml` copy), the line `        if: ${{ inputs.run-heavy }}` directly after its `- name:` line, and the unmodified helper reports any eight-space `if:` line in the gate step body, so WF02 would fail. The replacement accepts exactly the run-heavy line and still reports any other step-level condition, including a combined one such as `if: ${{ always() && inputs.run-heavy }}`. WF03's four mutations (removed, weakened, non-exiting, moved) each remain reported, because none of them depends on the `if:` check: the removed mutation leaves no gate step, the weakened and non-exiting mutations remove a required text, and the moved mutation breaks the step order. The helper reads the job text joined with LF from `Get-Content`, so the `$` anchor of the new pattern is not affected by line endings.

In the same edit (revision 3, preflight round 3, D1), the last line of the comment directly above the helper (lines 49-51 of the #953 copy), which states the helper's empty-result contract and after the condition change above would no longer match the code (`.claude/rules/self-explanatory-code-commenting.md` lines 39 and 97 require docstrings and comments to stay accurate when behaviour changes; that file is path-scoped to Python, and the plan applies the same accuracy requirement to this PowerShell comment), the line

`        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.`

(line 51 of that copy; target `A4C` of CR-INVENTORY, anchor `carries no step-level if condition`) is replaced by exactly:

`        # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.`

The eight-space indentation and the text before `carries no step-level if condition` are unchanged; only the clause `other than the issue #962 run-heavy gate` is inserted. Comment lines 49 and 50 and every other line of the helper are unchanged, so A4 changes exactly two lines (51 and 85). If the post-merge copy of either A4 line differs from the text quoted above, P4-T6 stops BLOCKED and requests a plan revision. A4 is unaffected by PD-15: the gate step belongs to the aggregator, which has no job-level `run-heavy` gate, so G6-sharded still gives it the step-level line.

## 8. Test row inventory

Every row name ends with its tag; `<Name>` placeholders are Pester `-ForEach` template keys. Each `It` follows Arrange-Act-Assert with a `-Because` message on the main assertion. Additional coverage rows end in ` (COV)` (PD-8). In the table cells below, `\|` denotes a literal `|`.

Fail-on-missing-target rule (required for the P1-T6 expect-fail outcome): the `BeforeAll` of suites C, P, and I throws when its target file is absent, by reading or importing with `-ErrorAction Stop` (suite C: `Get-Content -Raw -LiteralPath <config> -ErrorAction Stop`; suite P: `Import-Module <module> -Force -ErrorAction Stop`; suite I: an explicit `throw` naming the path when `Test-Path -LiteralPath <script>` is false, before the dot-source). Without it, rows such as C3 and C5 would pass against a missing config.

### Suite C: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 (23 rows, all AC-15)

Reads `config/ci-docs-only-paths.json` through `Join-Path $PSScriptRoot '../../../config/ci-docs-only-paths.json'` and `ConvertFrom-Json`, in `BeforeAll`; it does not import the module.

| Row | Name | Data and assertion |
|---|---|---|
| C1 | `parses the committed allowlist with version 1 (AC-15)` | `version` equals 1 |
| C2 | `starts every include prefix with docs/ (AC-15)` | every `include_prefixes` entry starts with `docs/` (ordinal) |
| C3 | `does not let any include prefix cover <Path> (AC-15)` | x3: `docs/features/templates/`, `docs/engineering/`, `docs/discovery/`; no include prefix P with `Path.StartsWith(P)` or `P.StartsWith(Path)` |
| C4 | `lists <Prefix> as an exclude prefix (AC-15)` | x2: `docs/features/templates/`, `docs/features/potential/template.md` |
| C5 | `does not configure the code extension <Extension> (AC-15)` | x15: `.py`, `.ps1`, `.psm1`, `.psd1`, `.sh`, `.bats`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.yml`, `.yaml`, `.toml` |
| C6 | `configures exactly the D3 include prefixes and extensions (AC-15)` | sorted include list equals the four D3 prefixes; sorted extensions equal `.json,.log,.md,.txt,.xml` |

### Suite P: tests/scripts/ci/CiChangeScope.Tests.ps1 (54 rows)

`BeforeAll` imports `Join-Path $PSScriptRoot '../../../scripts/ci/CiChangeScope.psm1'` with `-Force`. `$Config` is F2's result for the section 9 JSON held as a here-string in the test.

| Row | Name | Data and assertion |
|---|---|---|
| P1 | `Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for <EventName> (AC-1)` | x3: `merge_group`, `push`, `workflow_dispatch` |
| P2 | `Test-CiChangeScopeEventEligible returns nothing for a same-repository pull_request (AC-1)` | result null or empty |
| P3 | `Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a different head repository (AC-2)` | head `someone/drm-copilot` |
| P4 | `Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a blank head repository (AC-2)` | head empty string |
| P5 | `ConvertFrom-CiDocsOnlyPathConfig parses a valid config and lower-cases the extensions (AC-14)` | input extension `.MD` gives `.md` |
| P6 | `ConvertFrom-CiDocsOnlyPathConfig rejects <Case> (AC-14)` | x6: malformed JSON, empty text, version 2, missing include_prefixes, empty include_prefixes, extension without a dot; `Should -Throw -ExpectedMessage` with the F2 message |
| P7 | `Test-CiDocsOnlyPath accepts <Path> (AC-12)` | x6: `docs/features/active/x/evidence/a.md`, `docs/features/completed/x/evidence/b.txt`, `docs/features/potential/x/c.log`, `docs/research/d.json`, `docs/features/active/x/evidence/e.xml`, `docs/features/active/x/evidence/RUN.MD` |
| P8 | `Test-CiDocsOnlyPath rejects <Path> (AC-13)` | x13: `docs/features/templates/README.md`, `docs/features/potential/template.md`, `docs/engineering/x.md`, `docs/discovery/x.md`, `docs/features/active/x/a.ps1`, `docs/features/active/x/a.py`, `docs/features/active/x/a.yml`, `docs/features/active/../../scripts/a.md`, a path with backslash separators under `docs/features/active`, `/docs/features/active/a.md`, `Docs/features/active/x.md`, `config/ci-docs-only-paths.json`, `docs/features/active/x/noextension` |
| P9 | `ConvertFrom-CiNulPathList splits a NUL-terminated list (AC-8)` | two paths each followed by NUL |
| P10 | `ConvertFrom-CiNulPathList returns an empty valid list for empty text (AC-9)` | |
| P11 | `ConvertFrom-CiNulPathList marks text without a trailing NUL invalid (AC-8)` | |
| P12 | `Get-CiChangeScopePathDecision returns EMPTY_DIFF for no paths (AC-9)` | |
| P13 | `Get-CiChangeScopePathDecision names the first non-allowlisted path of a mixed set (AC-10)` | `docs/features/active/x/evidence/a.md`, `scripts/ci/CiChangeScope.psm1`; result `NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1` |
| P14 | `Get-CiChangeScopePathDecision returns nothing when every path is allowlisted (AC-11)` | |
| P15 | `Select-CiGreenBaseCandidates excludes the current run (AC-5)` | |
| P16 | `Select-CiGreenBaseCandidates excludes runs from a foreign head repository (AC-5)` | |
| P17 | `Select-CiGreenBaseCandidates orders unsorted runs by run_number descending (AC-5)` | run numbers 7, 9, 8 give 9, 8, 7 |
| P18 | `Select-CiGreenBaseCandidates excludes runs whose conclusion is not success (AC-5)` | |
| P19 | `Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID for malformed JSON (AC-3)` | |
| P20 | `Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID when workflow_runs is missing (AC-3)` | |
| P21 | `Test-CiFullRunMarker returns true when CI full run concluded success (AC-6)` | |
| P22 | `Test-CiFullRunMarker returns false when CI full run concluded <Conclusion> (AC-6)` | x3: `skipped`, `failure`, `cancelled` |
| P23 | `Test-CiFullRunMarker returns false when no CI full run job exists (AC-6)` | |
| P24 | `Test-CiFullRunMarker throws CI_JOB_LIST_INVALID for malformed JSON (AC-4)` | |
| P25 | `New-CiChangeScopeDecision renders code=false with the DOCS_ONLY_SINCE reason and base (AC-11)` | `OutputLine`, `LogLine`, `SummaryText` exact |
| P26 | `New-CiChangeScopeDecision renders code=true with base none (AC-11)` | |
| P27 | `CiChangeScope.psm1 defines only the eight pure functions and calls no git, gh, file, or network command (AC-17)` | AST of the module file: function set and banned command names as in CR-STRUCTURE |
| P28 | `New-CiChangeScopeDecision throws when code is false without a DOCS_ONLY_SINCE reason (AC-11)` | |

### Suite I: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 (30 rows)

`BeforeAll` dot-sources `Join-Path $PSScriptRoot '../../../scripts/ci/Invoke-CiChangeScope.ps1'` (the guard suppresses execution). Standard scenario: context `EventName = 'pull_request'`, `HeadSha` = 40 `b`, `HeadRef = 'bug/x'`, `HeadRepository` and `Repository` = `drmoisan/drm-copilot`, `RunId = '1000'`; `-ConfigJson` = the section 9 JSON; one run `id 900`, `run_number 9`, `head_sha` = 40 `a`, `conclusion success`; jobs for 900 = `CI full run` / `success`; git `cat-file` and `merge-base` exit 0; diff output `docs/features/active/x/evidence/a.md` plus NUL. Fakes record every call; the writer fake records `Target` and `Text`. Each row changes one element.

| Row | Name | Variation and assertion |
|---|---|---|
| I1 | `writes code=true EVENT_NOT_PULL_REQUEST for <EventName> without calling either invoker (AC-1)` | x3 events; both call logs empty |
| I2 | `writes code=true FORK_PULL_REQUEST for a fork pull request without calling either invoker (AC-2)` | |
| I3 | `writes code=true RUN_LIST_FAILED when the run-list call exits non-zero (AC-3)` | |
| I4 | `writes code=true RUN_LIST_FAILED when the run list is not valid JSON (AC-3)` | |
| I5 | `writes code=true JOB_LIST_FAILED when a jobs call fails (AC-4)` | |
| I6 | `writes code=true NO_FULL_GREEN_RUN when the only successful run skipped CI full run (AC-6)` | |
| I7 | `writes code=true NO_FULL_GREEN_RUN when the run list is empty (AC-6)` | |
| I8 | `uses the older qualifying run as the base when the newer run has no full-run marker (AC-6)` | runs 9 (marker skipped) and 8 (marker success, head 40 `c`); reason `DOCS_ONLY_SINCE_` plus 40 `c` |
| I9 | `never uses the current run as the base (AC-5)` | the only qualifying run has id equal to `RunId`; reason `NO_FULL_GREEN_RUN` |
| I10 | `writes code=true BASE_NOT_PRESENT when git cat-file fails (AC-7)` | |
| I11 | `writes code=true BASE_NOT_ANCESTOR when merge-base exits 1 (AC-7)` | |
| I12 | `writes code=true ANCESTRY_CHECK_FAILED when merge-base exits 128 (AC-7)` | |
| I13 | `passes --name-only, -z, --no-renames, --no-color, --no-ext-diff, --no-relative, and both SHAs to git diff (AC-8)` | recorded diff arguments contain each flag, the base, and the head |
| I14 | `writes code=true DIFF_FAILED when git diff exits non-zero (AC-8)` | |
| I15 | `writes code=true DIFF_FAILED when the diff output does not end in NUL (AC-8)` | |
| I16 | `writes code=true EMPTY_DIFF for an empty diff (AC-9)` | |
| I17 | `writes code=true NON_ALLOWLISTED_PATH for a mixed diff (AC-10)` | |
| I18 | `writes code=false and logs DOCS_ONLY_SINCE with the base for a docs-only diff (AC-11)` | `Output` text `code=false`; `Log` text `code=false reason=DOCS_ONLY_SINCE_` plus 40 `a`; `Summary` text contains the reason and `base=` plus 40 `a` |
| I19 | `writes code=true UNEXPECTED_ERROR and a warning for an invalid config (AC-14)` | `-ConfigJson '{bad'`; one `Warning` call |
| I20 | `writes code=true UNEXPECTED_ERROR and a warning without throwing when an invoker throws (AC-16)` | gh fake throws; `Should -Not -Throw` |
| I21 | `declares the GhInvoker, GitInvoker, and OutputWriter seams and a dot-source guard (AC-17)` | `(Get-Command Invoke-CiChangeScope).Parameters` keys; script text contains the guard |
| I22 | `reads the six context values through the injected variable reader (AC-17)` | `Get-CiChangeScopeContext -ReadVariable` fake |
| I23 | `default writer appends Output and Summary text to the GITHUB_OUTPUT and GITHUB_STEP_SUMMARY paths (AC-11)` | `Mock Add-Content`; reader fake returns `/synthetic/output` and `/synthetic/summary`; `Should -Invoke Add-Content` with `-ParameterFilter` on `LiteralPath` and `Value` |
| I24 | `default writer prefixes Warning text with ::warning:: on the information stream (AC-16)` | `Mock Write-Information`; `Should -Invoke` with `MessageData` starting `::warning::` |
| I25 | `reads the committed allowlist when no ConfigJson is supplied (AC-15)` | standard scenario without `-ConfigJson`; `code=false` |
| I26 | `uses the default writer when no OutputWriter is supplied (AC-1)` | `merge_group` event; `Mock Add-Content` and `Mock Write-Information`; returned `Code` is `true` |
| I27 | `writes code=true UNEXPECTED_ERROR when HEAD_SHA is blank on a pull_request event (AC-16)` | |
| I28 | `default writer sends Output text to the information stream when GITHUB_OUTPUT is unset (AC-11)` | reader fake returns null; `Mock Write-Information`; no `Add-Content` call |

### Suite W: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 (39 rows)

Reads the seven workflow files as text (`Get-Content -LiteralPath`, paths from `$PSScriptRoot`), partitions `jobs:` into job blocks at lines matching `^ {2}[A-Za-z0-9_-]+:\s*$` and job blocks into step blocks at lines matching `^ {6}- `, and asserts exact lines after `TrimEnd()`. No YAML module, process, temporary file, or network call (same technique as `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` lines 15-48).

| Row | Name | Assertion |
|---|---|---|
| W1 | `declares the changes job as Change scope with actions read and contents read (AC-18)` | `changes` block holds `    name: Change scope` and the consecutive lines `    permissions:`, `      actions: read`, `      contents: read` |
| W2 | `binds the changes job output code to steps.scope.outputs.code (AC-18)` | lines `    outputs:` and `      code: ${{ steps.scope.outputs.code }}` |
| W3 | `checks out the pull request head with fetch-depth 0, filter blob:none, and persist-credentials false (AC-18)` | lines `          ref: ${{ github.event.pull_request.head.sha \|\| github.sha }}`, `          fetch-depth: 0`, `          filter: blob:none`, `          persist-credentials: false` |
| W4 | `runs scripts/ci/Invoke-CiChangeScope.ps1 in a pwsh step with id scope and continue-on-error true (AC-18)` | one step block holds `        id: scope`, `        shell: pwsh`, `        continue-on-error: true`, and a line containing `./scripts/ci/Invoke-CiChangeScope.ps1` |
| W5 | `declares full-run-marker as CI full run that needs changes and runs only when code is not false (AC-18)` | lines `    name: CI full run`, `    needs: changes`, `    if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}` |
| W6 | `wires <Caller> with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)` | x6 callers; lines `    needs: changes`, `    if: ${{ !cancelled() }}`, `      run-heavy: ${{ needs.changes.outputs.code != 'false' }}` |
| W7 | `skips <Caller> at job level when code is false (AC-19)` | x2: `root-typescript-tests`, `npm-audit-gate`; lines `    needs: changes`, `    if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}` |
| W8 | `keeps docs-validation without needs and without if (AC-19)` | no line matching `^ {4}(needs\|if):` |
| W9 | `declares run-heavy as a boolean defaulting to true under both triggers in <File> (AC-20)` | x6 files; under each of `  workflow_call:` and `  workflow_dispatch:`, a `      run-heavy:` block holding `        type: boolean` and `        default: true` |
| W10 | `gates every step of <Job> on inputs.run-heavy in <File> (AC-20)` | x6 (file, job): (`_quality-checks.yml`, `quality-checks7`), (`_security-scan.yml`, `security-scan`), (`_build-check.yml`, `build-check`), (`_shell-coverage.yml`, `shell-coverage`), (`_drm-copilot-extension-tests.yml`, `drm-copilot-extension-tests`), (`_poshqc.yml`, `poshqc`); at least one step, and every step block has a line matching `^ {8}if: .*inputs\.run-heavy` |
| W11 | `combines run-heavy with the poetry cache-miss condition in _quality-checks.yml (AC-20)` | G1 exact line in step `Install dependencies` |
| W12 | `combines run-heavy with the 3.13-only condition in _quality-checks.yml (AC-20)` | G1 exact line in step `Upload coverage to Codecov` |
| W13 | `combines run-heavy with the kcov cache-miss condition in _shell-coverage.yml (AC-20)` | G4 exact line in step `Build kcov from source` |
| W14 | `leaves no bare always() step condition outside a job gated at job level on run-heavy in <File> (AC-20)` | x6 files; in every job block that has no line matching `^ {4}if: .*inputs\.run-heavy`, no line matching `^ {8}if:\s*(\$\{\{\s*)?always\(\)\s*(\}\})?\s*$` (PD-15) |
| W15 | `skips every _poshqc.yml job other than poshqc at job level unless run-heavy (AC-21)` | `_poshqc.yml` has at least one job other than `poshqc`, and each such job block has a line matching `^ {4}if: .*inputs\.run-heavy` (one row in both shapes: `poshqc-linux-hooks`, plus `poshqc-static` and `poshqc-shard` when sharded) |
| W16 | `keeps the poshqc job-level condition free of run-heavy and keeps if always() in the sharded shape (AC-21)` | the `poshqc` block has no line matching `^ {4}if: .*inputs\.run-heavy`; when the file declares a `poshqc-shard` job, the `poshqc` block has a line matching `^ {4}if:\s*(\$\{\{\s*)?always\(\)\s*(\}\})?\s*$`; otherwise it has no line matching `^ {4}if:` |
| W17 | `gates every poshqc step, including any step whose name begins Require, on run-heavy (AC-21)` | the `poshqc` block has at least one step and every step block has a line matching `^ {8}if: .*inputs\.run-heavy`; when the file declares a `poshqc-shard` job, exactly one `poshqc` step name begins `Require` (the step recorded as `POSHQC-REQUIRE-STEP:`) |
| W18 | `runs the security scan under bash after installing the Poetry export plugin and without continue-on-error (AC-36)` | in `_security-scan.yml`, job `security-scan`: no line matching `^\s*continue-on-error:`; a step block whose `- name:` is `Install the Poetry export plugin` holds the exact line `        run: poetry self add poetry-plugin-export` and is immediately followed by the step block named `Check for security vulnerabilities`, which holds the exact line `        shell: bash` |

W15 to W17 read `_poshqc.yml` at run time and branch on the presence of a `poshqc-shard` job, so their names and counts are the same in both shapes (PD-16); W17 no longer reads the edit-points artifact.

Per-AC row totals (asserted by `NAMED:` lines): AC-1 8, AC-2 3, AC-3 4, AC-4 2, AC-5 5, AC-6 8, AC-7 3, AC-8 5, AC-9 3, AC-10 2, AC-11 7, AC-12 6, AC-13 13, AC-14 8, AC-15 24, AC-16 3, AC-17 3, AC-18 5, AC-19 9, AC-20 21, AC-21 3, AC-36 1. Suite totals: C 23, P 54, I 30, W 39.

`W-PASS-BEFORE` (rows expected to pass against the pre-edit workflows, derived mechanically from the edit-points artifact): W8; each W14 row whose file has no `STEP-IF:` line with condition `always()` or `${{ always() }}` (before Phase 4 no job carries a `run-heavy` gate); and W16 (before Phase 4 the `poshqc` block has no `run-heavy` line, and it has `if: always()` in the sharded shape and no job-level `if:` in the main shape, as B2 verifies). On the head at revision time this gives W8, the five W14 rows of the files other than `_poshqc.yml` (whose `poshqc-linux-hooks` upload step has `if: always()`), and W16: seven rows. Every other W row, including W18, is expected to fail before Phase 4.

## 9. Configuration and tier entry

`config/ci-docs-only-paths.json` (research §4.1, spec D3):

```json
{
  "version": 1,
  "include_prefixes": [
    "docs/features/active/",
    "docs/features/completed/",
    "docs/features/potential/",
    "docs/research/"
  ],
  "exclude_prefixes": [
    "docs/features/potential/template.md",
    "docs/features/templates/"
  ],
  "extensions": [".md", ".txt", ".log", ".json", ".xml"]
}
```

Appended to `quality-tiers.yml` after the last entry (line 75 today), as research §5 recommends (`scripts/dev_tools/quality_tiers_contract.py` rule R3 discovers `scripts/ci` once a tracked code file exists there):

```yaml
  - path: "scripts/ci"
    tier: T4
    rationale: "CI change-scope decision script and its pure helper module (CI scaffolding)"
```

No test fixture changes: `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` line 195 asserts the length of its own constant, and lines 198-199 reject only T1 and T2 entries.

## 10. README corrections and section (.github/workflows/README.md)

**Corrections of pre-existing content (D14-a, PD-17; the only pre-existing changes).** Re-derived in revision 4 from the current file:

- Line 4 `orchestrator that composes eight reusable per-stage workflows (the `` `_<name>.yml` `` files` becomes the same line with `eight` replaced by `nine` (CR-README holds both lines verbatim).
- Directly after line 29 (the `_root-typescript-tests.yml` row of the Per-Stage Dispatch table), insert the row ``| `_npm-audit-gate.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _npm-audit-gate.yml` |`` (`_npm-audit-gate.yml` declares both triggers, lines 4 and 13).
- Line 79 `This extraction does not, by itself, change job-DAG concurrency. All seven jobs in` becomes `This extraction does not, by itself, change job-DAG concurrency. The seven jobs it extracted from`; lines 80-84 are unchanged and now complete that sentence.

**Appended section.** Appended after the current last line (line 95):

```markdown

## Change-Scope Decision (Issue #962)

`ci.yml` starts every run with the `changes` job (check name `Change scope`). The job decides whether the heavy CI steps run for the commit under test and publishes the decision as the job output `code` (`true` or `false`).

### Decision

On a `pull_request` event from this repository, `scripts/ci/Invoke-CiChangeScope.ps1` reads the newest 50 successful `ci.yml` runs on the pull request branch, selects the newest one whose `CI full run` job concluded `success`, checks that its head commit is present and is an ancestor of the current head, and lists the files changed between the two commits with `git diff --name-only -z --no-renames`. When every changed file is on the allowlist, the decision is `code=false`; otherwise it is `code=true`. The step logs `code=<true|false> reason=<REASON>` and writes the reason and the base commit to the job summary.

Reason codes: `EVENT_NOT_PULL_REQUEST`, `FORK_PULL_REQUEST`, `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`, `ANCESTRY_CHECK_FAILED`, `DIFF_FAILED`, `EMPTY_DIFF`, `NON_ALLOWLISTED_PATH: <first path>`, `DOCS_ONLY_SINCE_<base sha>`, and `UNEXPECTED_ERROR`.

### Allowlist

`config/ci-docs-only-paths.json` holds the allowlist. A path is allowlisted only when it starts with an include prefix (`docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, or `docs/research/`), does not start with an exclude prefix (`docs/features/templates/` or `docs/features/potential/template.md`), ends in one of the extensions `.md`, `.txt`, `.log`, `.json`, or `.xml` (compared case-insensitively), and contains no `..` segment, no backslash, and no leading `/`. Prefixes are compared case-sensitively. A change to the allowlist file itself is not allowlisted.

### Fail-closed rules

The decision is `code=true` (a full run) for every event other than `pull_request` (`merge_group`, `push`, and `workflow_dispatch`), for a pull request from a fork, when the run list or a job list cannot be read or parsed, when no successful run with a successful `CI full run` job is found, when the base commit is missing or is not an ancestor of the head, when the ancestry check or the diff fails, when the diff is empty, when any changed path is outside the allowlist, and on any unexpected error. The decision step uses `continue-on-error: true`, and the callers compare the output with `!= 'false'`, so a failed or missing decision also gives a full run.

### The `run-heavy` input

`_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, and `_drm-copilot-extension-tests.yml` declare a boolean input `run-heavy` (default `true`) under both `workflow_call` and `workflow_dispatch`. `ci.yml` passes `run-heavy: ${{ needs.changes.outputs.code != 'false' }}`. When the input is `false`, each required job still starts under its full-run name and every step is skipped, so the job reports `success`. In `_poshqc.yml`, the `poshqc` job, which reports `poshqc / PowerShell QC`, runs with every step gated, and every other job is skipped at job level; when the file has the sharded shape of #953, `poshqc` is the aggregator and keeps `if: always()`. A job skipped at job level keeps its step conditions unchanged. A standalone dispatch, or a caller that omits the input, runs in full. `root-typescript-tests` and `npm-audit-gate` are skipped at job level when `code` is `false`, and `docs-validation` always runs. The `CI full run` job runs only when `code` is not `false`; it marks a run as a valid base for later decisions and is not a required check.

### Required contexts under a docs-only run

| # | Required context (ruleset 15241672) | Behaviour when `code=false` | Reported conclusion |
|---|---|---|---|
| 1 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | job and matrix start; every step skipped by `inputs.run-heavy` | `success` |
| 2 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | same as row 1 | `success` |
| 3 | `docs-validation / Documentation Validation` | unchanged; runs in full | `success` on a passing docs check |
| 4 | `poshqc / PowerShell QC` | the `poshqc` job runs with every step gated (as the aggregator with `if: always()` in the sharded shape); every other `_poshqc.yml` job skipped at job level | `success` |
| 5 | `shell-coverage / Shell Coverage (Bats + kcov)` | job runs; every step skipped, including the upload step | `success` |
| 6 | `security-scan / Security Scanning` | job runs; every step skipped | `success` |
| 7 | `quality-checks7 / Code Quality & Tests (3.10)` | matrix expands; every step skipped | `success` |
| 8 | `quality-checks7 / Code Quality & Tests (3.11)` | same as row 7 | `success` |
| 9 | `quality-checks7 / Code Quality & Tests (3.12)` | same as row 7 | `success` |
| 10 | `quality-checks7 / Code Quality & Tests (3.13)` | same as row 7 | `success` |
| 11 | `build-check / Build Package` | job runs; every step skipped | `success` |

Non-required jobs under `code=false`: `Change scope` reports `success`, `CI full run` is `skipped`, and the `root-typescript-tests` and `npm-audit-gate` callers are `skipped`.

### Security scan

On a full run, `security-scan / Security Scanning` installs the Poetry export plugin, exports the locked dependencies, and runs `safety check` under `bash` with `pipefail`. The scan step has no `continue-on-error`, so a finding or an export failure fails the required check (issue #962 follow-up).
```

## 11. Phases

### Phase 0 — Baseline Capture and Dependency Record

- [ ] [P0-T1] Read the policy files in order and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read.
  - Order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/powershell.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/shell.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/ci-workflows.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/rules/self-explanatory-code-commenting.md`; `.claude/rules/tonality.md`; `.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`; `.github/instructions/general-unit-test.instructions.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.github/instructions/github-actions.instructions.md`; `.claude/skills/acceptance-criteria-tracking/SKILL.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Done when the artifact lists all 22 files in that order. No policy file is edited.
- [ ] [P0-T2] Record the baseline branch state in `FEATURE/evidence/baseline/branch-state.<timestamp>.md` by running `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git status --porcelain`, and `git log -3 --format=%H%x09%s`.
  - Done when the branch is `bug/ci-skip-evidence-only-commits-962` and the porcelain output contains at most these three entries and no other: ` M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md` and ` M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` (each present only when that file has uncommitted revision-4 changes) and `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` (the untracked evidence folder, which exists because P0-T1 wrote its artifact first). Any other entry stops the task BLOCKED with the porcelain output recorded.
- [ ] [P0-T3] Write the launcher and every recipe of section 5 verbatim with the Write tool to `SCRATCH/tools/`: `run-cr.sh` (LF line endings) and the 20 recipe files `cr-python-env.txt`, `cr-probe.txt`, `cr-inventory.txt`, `cr-pester-list.txt`, `cr-pester-cov.txt`, `cr-cov-files.txt`, `cr-cov-delta.txt`, `cr-format.txt`, `cr-pssa.txt`, `cr-hermetic.txt`, `cr-structure.txt`, `cr-onblock.txt`, `cr-readme.txt`, `cr-scope.txt`, `cr-evidence.txt`, `cr-actionlint.txt`, `cr-quality-tiers.txt`, `cr-ac-status.txt`, `cr-shell-static.txt`, `cr-kcov-file.txt`.
  - Done when the 21 files exist with content identical to section 5, no `.ps1`, `.psm1`, or `.psd1` file was written with Write or Edit (rule 4a), and no file is written inside the worktree.
- [ ] [P0-T4] Probe the command route and prepare the Python environment (rule 3, preflight D1 and D3): run `sh SCRATCH/tools/run-cr.sh cr-probe`, then `sh SCRATCH/tools/run-cr.sh cr-python-env` (which runs `poetry install --no-interaction` and an import probe), and write `FEATURE/evidence/baseline/cr-route-probe.<timestamp>.md` with both outputs and the line `CR-ROUTE: sh-launcher` or `CR-ROUTE: BLOCKED` followed by the refusal or launcher text.
  - Done when the first output shows `RUN-CR: cr-probe`, `PROBE-PESTER: 5.` (prefix), `PROBE-CWD-IS-REPO-ROOT: True`, and `EXIT_CODE_COMPUTED: 0`, and the second shows `PYENV-INSTALL-EXIT: 0`, `PYENV-PROBE: PYTHON-IMPORTS-OK`, `PYTHON-ENV-READY`, and `EXIT_CODE_COMPUTED: 0`. A Bash refusal, any `RUN-CR-` failure literal, `PYTHON-ENV-NOT-READY`, or a non-zero exit records `CR-ROUTE: BLOCKED` (or `PYTHON-ENV: BLOCKED`) and stops execution BLOCKED. These two runs are the rule 6 reference observations for the launcher and for `PYTHON-ENV-READY`.
- [ ] [P0-T5] Record the dependency state (AC-30, PD-1; a record, not a gate) in `FEATURE/evidence/other/dependency-state.<timestamp>.md`: `git fetch origin`, then `git rev-parse origin/main`, `git rev-parse origin/bug/ci-merge-queue-for-main-952`, `git rev-parse origin/bug/pester-profiler-coverage-953`, `git grep -c -E -e '^  merge_group:[[:space:]]*$' origin/main -- .github/workflows/ci.yml`, `git grep -c -E -e '^  poshqc-shard:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml`, `git grep -c -E -e '^  poshqc-static:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml`, and `git grep -c -E -e '^    name: PowerShell QC[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml`, each with its exit code on a labelled line.
  - Done when the artifact carries the three SHAs (a `rev-parse` that fails because a dependency branch no longer exists is recorded with its exit code and the value `absent`), one line per token of the form `TOKEN-<merge_group|poshqc-shard|poshqc-static|PowerShell QC>: present (<count>)` for a search that exits 0 with an `origin/main:<path>:<count>` line or `TOKEN-<...>: absent` for a search that exits 1 with no output, the derived lines `DEP-952: present|absent` (present when the `merge_group` token is present) and `DEP-953: present|absent` (present when both the `poshqc-shard` and `poshqc-static` tokens are present), and the line `DEPENDENCY_STATE: RECORDED`. A search exit code other than 0 or 1 is recorded and stops the task BLOCKED (a git error, not an absence). There is no halting branch for an absent dependency; on the head at revision time the expected record is `DEP-952: absent`, `DEP-953: absent`, and the retention token present.
- [ ] [P0-T6] Commit the Phase 0 artifacts written so far before the merge: `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, then `git commit -m "docs(962): record Phase 0 policy reads and the dependency state" -m "<trailer>"` (no push in this task; P0-T8 pushes).
  - Done when `git status --porcelain` lists nothing except `?? tools/` (rule 12).
- [ ] [P0-T7] Integrate `origin/main` with `git merge --no-ff --no-edit origin/main` and write `FEATURE/evidence/other/merge-integration.<timestamp>.md` with the merge output, then the output and exit code of `git rev-parse HEAD`, `git rev-parse HEAD^1`, `git rev-parse HEAD^2`, and `git merge-base --is-ancestor origin/main HEAD`.
  - Done when the merge exits 0 and the ancestry check exits 0, and either (a) the merge output contains `Already up to date.` (the expected outcome at revision time, because merge commit `e07e235d5` already contains `origin/main` at `fa27cd5ed`): record `MERGE-RESULT: already-up-to-date` and `MERGE-COMMIT: <the origin/main SHA recorded by P0-T5>` (`HEAD^2` then fails or names an unrelated parent and is recorded, not asserted); or (b) a merge commit was created: `HEAD^2` equals the `origin/main` SHA recorded by P0-T5, and record `MERGE-RESULT: merged` and `MERGE-COMMIT: <HEAD SHA>`. On a conflict, run `git merge --abort`, record the conflicting paths, and stop BLOCKED. No rebase is used.
- [ ] [P0-T8] Push the merge with `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` and append to the P0-T7 artifact under `FEATURE/evidence/other/` the output of `git rev-parse HEAD` and `git rev-parse origin/bug/ci-skip-evidence-only-commits-962`.
  - Done when the push is a fast-forward and both SHAs are equal. A rejected push stops BLOCKED; no force push.
- [ ] [P0-T9] Re-derive the edit points by running `sh SCRATCH/tools/run-cr.sh cr-inventory` after reading the head's `.github/workflows/ci.yml`, `.github/workflows/_poshqc.yml`, and every `tests/scripts/workflows/*.Tests.ps1`, and write `FEATURE/evidence/other/edit-points.<timestamp>.md` with the full CR output plus the derived lines `POSHQC-SHAPE: <main|sharded>` (copied from the CR), `CI-MERGE-GROUP: <present|absent>` (copied), `POSHQC-AGGREGATOR-IF: <the JOB-IF condition of the poshqc job, or none>`, `POSHQC-REQUIRE-STEP: <exact step name, or n/a in the main shape>`, `A2-APPLICABLE: <yes|no>` (yes when the `EDIT-TARGET-A2:` and `EDIT-TARGET-A2B:` lines both show `count=1`), `LIST-EDITED-SUITES: <comma list, possibly empty>` (section 1), `W-PASS-BEFORE: <row list>` (section 8), the four `EDIT-TARGET-` lines copied verbatim, and `BLOCK-CHECKS: B1=<pass|fail> B2=... B3=<pass|fail|n/a> B4=... B5=... B6=<pass|fail|n/a> B7=...` (PD-2).
  - Done when the CR prints `EXIT_CODE_COMPUTED: 0` and every block check is `pass` or `n/a` as PD-2 defines. In the sharded shape B6 passes only when the CR output carries one line beginning `EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=`, one line beginning `EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=`, and no `EDIT-TARGET-A4-CANDIDATE:` or `EDIT-TARGET-A4C-CANDIDATE:` line. On the head at revision time the expected derived lines are `POSHQC-SHAPE: main`, `CI-MERGE-GROUP: absent`, `POSHQC-AGGREGATOR-IF: none`, `POSHQC-REQUIRE-STEP: n/a`, `A2-APPLICABLE: no`, `LIST-EDITED-SUITES:` with an empty value, and `B3=n/a`, `B6=n/a`. Any failing block check stops BLOCKED and requests a plan revision; a B6 or B7 failure records every `EDIT-TARGET-` line of the CR output (the observed text of the lines) in the artifact. Rule 17 re-runs this task after a re-integration.
- [ ] [P0-T10] Capture the baseline Pester state of the existing suites: `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-EXISTING-SUITES>" -NamePatternList "<PATTERNS-PARSER>"`, written to `FEATURE/evidence/baseline/baseline-pester-list.<timestamp>.md`.
  - Done when the output shows one `CONTAINER:` line with `Result=Passed` per suite of `LIST-EXISTING-SUITES`, `TOTAL:` with `Failed=0`, each of the three `NAMED:` lines shows `Passed=1 | Failed=0 | Total=1`, and `EXIT_CODE_COMPUTED: 0`. Any failing row stops BLOCKED with `PREEXISTING_SUITE_FAILURE` (PD-3). CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P0-T11] Run the baseline PoshQC coverage run `sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"` and write `FEATURE/evidence/baseline/baseline-pester-coverage.<timestamp>.md`.
  - Done when the output shows a `COVERAGE-RUN-START-UTC:` line, `Code coverage population: source=config`, and a `Tests Passed:` line with `Failed: 0`, and the process exit code is 0. CI job (the only job that measures PowerShell coverage): `poshqc / PowerShell QC` (windows-latest).
- [ ] [P0-T12] Read the baseline per-file coverage with `sh SCRATCH/tools/run-cr.sh cr-cov-files -TargetList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1" -NotBefore "<COVERAGE-RUN-START-UTC value from P0-T11>"` and write `FEATURE/evidence/baseline/baseline-coverage-files.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Done when the output shows `COVERAGE-FILE-FRESH: True`, a positive `SOURCEFILE-COUNT:`, a numeric `TOTAL-LINE-COVERAGE:` percent (the baseline headline), both `COV-FILE:` lines ending `MISSING` (the files do not exist yet), and `EXIT_CODE_COMPUTED: 1`. The Output Summary records the numeric baseline percent.
- [ ] [P0-T13] Capture the baseline format state (read-only) with `sh SCRATCH/tools/run-cr.sh cr-format -PathList "<LIST-EXISTING-SUITES>"` and write `FEATURE/evidence/baseline/baseline-format-check.<timestamp>.md`.
  - Done when the artifact records every `FORMAT-CLEAN:` or `FORMAT-DRIFT:` line and the `FORMAT-DRIFT-COUNT:` value. The result is informational: pre-existing drift in a suite that is not edited is recorded, not fixed; drift recorded here for a suite of `LIST-EDITED-SUITES` is cleared by the Phase 6 format stage, which runs over `LIST-PS-WRITTEN`.
- [ ] [P0-T14] Capture the baseline analyzer state with `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "<LIST-EXISTING-SUITES>"` and write `FEATURE/evidence/baseline/baseline-pssa.<timestamp>.md`.
  - Done when the artifact records each `PSSA:` line and the `PSSA-TOTAL:` value (informational, as for P0-T13).
- [ ] [P0-T15] Capture the baseline actionlint state of the seven workflow files with `sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList "<LIST-WORKFLOWS>"` and write `FEATURE/evidence/baseline/baseline-actionlint.<timestamp>.md`.
  - Done when the artifact records `ACTIONLINT-WRAPPER-EXIT:`, `ACTIONLINT-DIRECT-EXIT:`, every `ACTIONLINT-FINDING:` line, and `ACTIONLINT-FINDINGS:`. Findings are fixed in Phase 4 under PD-9. `ACTIONLINT-BINARY: absent` stops BLOCKED.
- [ ] [P0-T16] Capture the baseline tier classification with `sh SCRATCH/tools/run-cr.sh cr-quality-tiers` and `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py`, written to `FEATURE/evidence/baseline/baseline-quality-tiers.<timestamp>.md`.
  - Done when the CR shows `QT-OUTPUT: quality-tiers: OK`, `QT-SCRIPTS-CI-ENTRY: False`, and `EXIT_CODE_COMPUTED: 0`, and the pytest summary line reports `passed` with no `failed`.
- [ ] [P0-T17] Capture the Python toolchain baseline for `LIST-PY-WORKFLOW-TESTS` (rule 16) in `FEATURE/evidence/baseline/baseline-python.<timestamp>.md`, one labelled exit-code line per command: `poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `poetry run pyright tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, and `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.
  - Done when Black prints `1 file would be left unchanged.`, Ruff prints `All checks passed!`, Pyright prints a summary beginning `0 errors`, the single-file pytest summary reports `6 passed` with no `failed` (the count B used by P4-T8; if the post-merge file has a different number of tests, the printed number is B and is recorded as `PY-CONTRACT-BASELINE-PASSED: <B>`), the three-file pytest summary reports `passed` with no `failed`, and every exit code is 0. These runs are the rule 6 reference observations for the Python literals. A failure here stops BLOCKED with `PREEXISTING_PYTHON_FAILURE`, because the Phase 6 Python stages could not then pass. CI job: `quality-checks7 / Code Quality & Tests` (ubuntu-latest).
- [ ] [P0-T18] Capture the shell baseline (rule 18, PD-21) with `sh SCRATCH/tools/run-cr.sh cr-shell-static` and write `FEATURE/evidence/baseline/baseline-shell-static.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Done when the output shows `SHELL-RECURSIVE-INVOCATIONS: 0`, `SHELL-NONRECURSIVE-INVOCATIONS: 2`, `SHELL-THRESHOLD-FUNCTION: 0`, `SHELL-NEW-TESTS-MISSING: 8`, `SHELL-NESTED-BATS-FILES: 0`, `SHELL-LINES-OVER-500: 0`, `SHELL-CRLF-FILES: 0`, a `SHELL-LOCAL-LINT:` line, and `EXIT_CODE_COMPUTED: 1`, and the Output Summary records the `SHELL-LINES:` counts (394, 103, and 204 expected) and whether local lint ran and failed. A `SHELL-CRLF-FILES:` value other than 0 stops BLOCKED (the files would not match CI). The bash coverage baseline is the CI figure `Bash coverage (lines): 95.2%` of main run 38948304976 (orchestrator observation), re-read from the log by P7-T4; the executor cannot measure it locally.
- [ ] [P0-T19] Commit and push the Phase 0 baseline evidence (rule 11): `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "docs(962): record Phase 0 baselines after merging origin/main" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-0.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 1 — Regression Tests (Expect-Fail)

- [ ] [P1-T1] Write `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` with exactly rows C1 to C6 of section 8 (23 expanded rows).
  - Done when the file exists, is 500 lines or fewer, and its row names match section 8 (verified by the `ROW:` lines of P1-T6).
- [ ] [P1-T2] Write `tests/scripts/ci/CiChangeScope.Tests.ps1` with exactly rows P1 to P28 of section 8 (54 expanded rows), importing the module in `BeforeAll`.
  - Done when the file exists, is 500 lines or fewer, and its row names match section 8 (P1-T6 `ROW:` lines).
- [ ] [P1-T3] Write `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` with exactly rows I1 to I28 of section 8 (30 expanded rows), dot-sourcing the entry script in `BeforeAll` and using only test-local scriptblock fakes and the `Add-Content` and `Write-Information` cmdlet mocks (rule 8).
  - Done when the file exists, is 500 lines or fewer, and its row names match section 8 (P1-T6 `ROW:` lines).
- [ ] [P1-T4] Write `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` with exactly rows W1 to W18 of section 8 (39 expanded rows); W15 to W17 detect the `_poshqc.yml` shape at run time (PD-16) and read no evidence artifact.
  - Done when the file exists, is 500 lines or fewer, and its row names match section 8 (P1-T6 `ROW:` lines).
- [ ] [P1-T5] Check the four new suites for purity and size with `sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "<LIST-NEW-TESTS>"` and write `FEATURE/evidence/regression-testing/p1-test-hygiene.<timestamp>.md`.
  - Done when the output shows `HERMETIC-HITS: 0`, `LINES-OVER-500: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [ ] [P1-T6] [expect-fail] Run the four new suites against the unchanged production tree with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-NEW-TESTS>" -NamePatternList "<PATTERNS-WORKFLOW>"` and write `FEATURE/evidence/regression-testing/expect-fail-new-suites.<timestamp>.md` with `ExpectedExitCode: 1` (AC-23 fail-before).
  - Done when: the `SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` line shows `Passed=` equal to the size of `W-PASS-BEFORE` and `Failed=` equal to 39 minus that size (7 and 32 on the head at revision time); every `ROW: Passed` line for that suite names a `W-PASS-BEFORE` row and every other W row appears as `ROW: Failed`; for each of the three `tests/scripts/ci` suites either its `CONTAINER:` line shows `Result=Failed` or its `SUITE:` line shows `Passed=0` (the module, script, and config do not exist yet); and `EXIT_CODE_COMPUTED: 1`. Any other outcome stops BLOCKED with the observed rows. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P1-T7] Apply S4 of section 6a to `tests/shell/test_shell_qc_commands.bats` with the Edit tool (the two nounset assertions at lines 180 and 190, and the eight tests appended after line 204).
  - Done when the file ends with the eight S4 tests and P1-T8 shows `SHELL-NEW-TESTS-MISSING: 0` and `SHELL-NOUNSET-ASSERTIONS-UPDATED: 2`.
- [ ] [P1-T8] [expect-fail] Record the fail-before evidence for the shell tests (rule 18): run `sh SCRATCH/tools/run-cr.sh cr-shell-static` against the unchanged `scripts/bash` files and write `FEATURE/evidence/regression-testing/fail-before-exception.<timestamp>.md` with `ExpectedExitCode: 1`, a `WhyFailingRunImpossible:` line (the worktree isolation guard refuses bash, wsl, and bats command text, so the bats suite cannot run in this worktree; CI runs it in `shell-coverage / Shell Coverage (Bats + kcov)`), and an alternative-proof section holding the CR output.
  - Done when the output shows `SHELL-NEW-TESTS-MISSING: 0`, `SHELL-NOUNSET-ASSERTIONS-UPDATED: 2`, `SHELL-RECURSIVE-INVOCATIONS: 0`, `SHELL-THRESHOLD-FUNCTION: 0`, `SHELL-THRESHOLD-WIRING: 0`, and `EXIT_CODE_COMPUTED: 1`, and the alternative-proof section states, for each of the ten S4 assertions, why it fails against this tree: the eight new tests and the two changed assertions expect `--recursive` in the stub argv, which the unchanged invocations (counted by `SHELL-NONRECURSIVE-INVOCATIONS: 2`) do not pass, or call `check_coverage_threshold`, which is undefined (`SHELL-THRESHOLD-FUNCTION: 0`), so bash returns status 127.
- [ ] [P1-T9] Commit and push the regression suites (rule 11): `git add -- tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 tests/scripts/ci/CiChangeScope.Tests.ps1 tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 tests/shell/test_shell_qc_commands.bats docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "test(962): add failing change-scope, workflow-gating, and shell QC regression tests" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-1.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 2 — Allowlist Config, Pure Module, and Tier Entry

- [ ] [P2-T1] Write `config/ci-docs-only-paths.json` with the exact content of section 9.
  - Done when the file exists with that content (verified by P2-T2 rows C1 and C6).
- [ ] [P2-T2] Run the config suite with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1" -NamePatternList "*(AC-15)*"` and write `FEATURE/evidence/regression-testing/p2-config-suite.<timestamp>.md`; then check off AC-15 in `FEATURE/spec.md`.
  - Done when the output shows `NAMED: *(AC-15)* | Passed=23 | Failed=0 | Total=23`, `TOTAL:` with `Failed=0`, and `EXIT_CODE_COMPUTED: 0`. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P2-T3] Write `scripts/ci/CiChangeScope.psm1` implementing F1 to F8 of section 6 with the PD-6 suppressions and no other function; the file ends with a newline (P7-T14 relies on it).
  - Done when the file exists, is 500 lines or fewer, ends with a newline, and P2-T4 passes.
- [ ] [P2-T4] Run the pure suite with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiChangeScope.Tests.ps1" -NamePatternList "*(AC-5)*,*(AC-10)*,*(AC-12)*,*(AC-13)*"` and write `FEATURE/evidence/regression-testing/p2-pure-suite.<timestamp>.md`; then check off AC-5, AC-10, AC-12, and AC-13 in `FEATURE/spec.md`.
  - Done when the `SUITE:` line shows `Passed=54 | Failed=0`, the `NAMED:` lines show `Total=4`, `Total=1`, `Total=6`, and `Total=13` respectively with `Failed=0`, and `EXIT_CODE_COMPUTED: 0`. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P2-T5] Append the `scripts/ci` entry of section 9 to `quality-tiers.yml` after the last existing entry, then run `git diff --numstat HEAD -- quality-tiers.yml` and record its output in `FEATURE/evidence/regression-testing/p2-tier-entry-diff.<timestamp>.md`.
  - Done when the file ends with that three-line entry and the numstat output is exactly one line reading `3`, a tab, `0`, a tab, `quality-tiers.yml` (three lines added, none deleted; the file ends with a newline today, after line 75, so nothing else changes). Any other numstat line stops the task BLOCKED.
- [ ] [P2-T6] Stage the new tracked files and verify the tier classification (AC-29): `git add -- scripts/ci/CiChangeScope.psm1 config/ci-docs-only-paths.json quality-tiers.yml`, then `sh SCRATCH/tools/run-cr.sh cr-quality-tiers` and `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py`, written to `FEATURE/evidence/regression-testing/p2-quality-tiers.<timestamp>.md`; then check off AC-29 in `FEATURE/spec.md`.
  - Done when the CR shows `QT-OUTPUT: quality-tiers: OK`, `QT-SCRIPTS-CI-ENTRY: True`, and `EXIT_CODE_COMPUTED: 0`, and the pytest summary reports `passed` with no `failed`.
- [ ] [P2-T7] Commit and push Phase 2 (rule 11): `git add -- scripts/ci/CiChangeScope.psm1 config/ci-docs-only-paths.json quality-tiers.yml docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "feat(962): add the docs-only allowlist, the pure change-scope module, and the scripts/ci tier entry" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-2.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 3 — Entry Script

- [ ] [P3-T1] Write `scripts/ci/Invoke-CiChangeScope.ps1` implementing F9 to F12 of section 6, with the dot-source guard as its last statement.
  - Done when the file exists, is 500 lines or fewer, and P3-T2 passes.
- [ ] [P3-T2] Run the three `tests/scripts/ci` suites with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-CI-TESTS>" -NamePatternList "<PATTERNS-UNIT>"` and write `FEATURE/evidence/regression-testing/p3-ci-suites.<timestamp>.md`; then check off AC-1, AC-2, AC-3, AC-4, AC-6, AC-7, AC-8, AC-9, AC-11, AC-14, and AC-16 in `FEATURE/spec.md`.
  - Done when `TOTAL:` shows `Passed=107 | Failed=0`, every `NAMED:` line shows `Failed=0` with the section 8 per-AC total (AC-1 8, AC-2 3, AC-3 4, AC-4 2, AC-5 5, AC-6 8, AC-7 3, AC-8 5, AC-9 3, AC-10 2, AC-11 7, AC-12 6, AC-13 13, AC-14 8, AC-15 24, AC-16 3, AC-17 3), and `EXIT_CODE_COMPUTED: 0`. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P3-T3] Verify the structure of `scripts/ci/` (AC-17) with `sh SCRATCH/tools/run-cr.sh cr-structure` and `sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "<LIST-NEW-PS>"`, written to `FEATURE/evidence/regression-testing/p3-structure.<timestamp>.md`; then check off AC-17 in `FEATURE/spec.md`.
  - Done when CR-STRUCTURE shows every section 5 success literal (`STRUCT-MODULE-FUNCTIONS-MATCH: True`, `STRUCT-ENTRY-SEAMS: 3`, `STRUCT-ENTRY-GUARD: True`, `STRUCT-NON-POWERSHELL-FILES: 0`, `EXIT_CODE_COMPUTED: 0`) and CR-HERMETIC shows `HERMETIC-HITS: 0` and `LINES-OVER-500: 0`.
- [ ] [P3-T4] Commit and push Phase 3 (rule 11): `git add -- scripts/ci/Invoke-CiChangeScope.ps1 docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "feat(962): add the change-scope entry script" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-3.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 4 — Workflow Gating

- [ ] [P4-T1] Edit `.github/workflows/_quality-checks.yml` per G0 and G1 (and PD-9 for any baseline actionlint finding in this file).
  - Done when every step of `quality-checks7` carries an `if:` referencing `inputs.run-heavy` and the two G1 lines are exact (verified by P4-T11 rows W9 to W14 for this file; the threshold step's new `if:` is the cause of the P4-T8 expect-fail).
- [ ] [P4-T2] Edit `.github/workflows/_security-scan.yml` per G0 and G2 (and PD-9), including the D14-b changes of PD-18.
  - Done when every step of `security-scan`, including the new `Install the Poetry export plugin` step, carries `if: ${{ inputs.run-heavy }}`, the scan step carries `shell: bash`, and no `continue-on-error` line remains (P4-T11 rows W9, W10, W14, and W18 for this file).
- [ ] [P4-T3] Edit `.github/workflows/_build-check.yml` per G0 and G3 (and PD-9).
  - Done when every step of `build-check` carries `if: ${{ inputs.run-heavy }}` (P4-T11 rows W9, W10, W14 for this file).
- [ ] [P4-T4] Edit `.github/workflows/_shell-coverage.yml` per G0 and G4 (and PD-9).
  - Done when every step of `shell-coverage`, including the `if-no-files-found: error` upload, carries an `if:` referencing `inputs.run-heavy` and the G4 line is exact (P4-T11 rows W9, W10, W13, W14 for this file).
- [ ] [P4-T5] Edit `.github/workflows/_drm-copilot-extension-tests.yml` per G0 and G5 (and PD-9).
  - Done when every step of `drm-copilot-extension-tests` carries `if: ${{ inputs.run-heavy }}` (P4-T11 rows W9, W10, W14 for this file).
- [ ] [P4-T6] Edit `.github/workflows/_poshqc.yml` per G0 and G6 in the shape named by `POSHQC-SHAPE:` of the latest edit-points artifact (G6-main or G6-sharded; PD-16) (and PD-9). When the shape is `sharded`, apply A4 (with A4C) of section 7 to `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` in the same task (PD-14), so the existing-suite run P4-T12 can pass in task order; when it is `main`, write `A4 not applicable on this HEAD` and leave the suite unchanged. Record the shape, that line or the A4 record, and the numstat output below in `FEATURE/evidence/regression-testing/p4-poshqc-suite-edit.<timestamp>.md`.
  - Done in the main shape when every one of the six `poshqc` steps carries `        if: ${{ inputs.run-heavy }}` directly after its `- name:` line, the `poshqc` job has no job-level `if:`, `poshqc-linux-hooks` carries `    if: ${{ inputs.run-heavy }}` directly after its `name:` line, its step lines are unchanged (P4-T11 rows W9, W10, W14 to W17), and `git diff --numstat HEAD -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` prints nothing. Done in the sharded shape when `poshqc-static`, `poshqc-shard`, and `poshqc-linux-hooks` carry a job-level `if:` referencing `inputs.run-heavy` with their step conditions unchanged, the aggregator's job-level `if: always()` line is unchanged, every aggregator step carries an `if:` referencing `inputs.run-heavy` (same rows), and the two A4 lines are the only changed lines of the suite (the numstat command prints one line reading `2`, a tab, `2`, a tab, and the path; rows WF02 and WF03 are observed by P4-T12). If the text of either A4 line differs from its quotation, stop BLOCKED with the observed line recorded.
- [ ] [P4-T7] Edit `.github/workflows/ci.yml` per G7 (and PD-9), leaving every line of the `on:` block unchanged. When the latest edit-points artifact records `A2-APPLICABLE: yes`, apply A2 of section 7 to `tests/scripts/workflows/CiWorkflow.Tests.ps1` in the same task (PD-14), so the existing-suite run P4-T12 can pass in task order; when it records `A2-APPLICABLE: no`, write `A2 not applicable on this HEAD` and leave the suite unchanged. Record that line or the A2 record and the numstat output below in `FEATURE/evidence/regression-testing/p4-ci-suite-edit.<timestamp>.md`.
  - Done when the `changes` and `full-run-marker` jobs and the caller lines of G7 are present (P4-T11 rows W1 to W8), P4-T14 reports the `on:` block identical, and `git diff --numstat HEAD -- tests/scripts/workflows/CiWorkflow.Tests.ps1` prints one line reading `16`, a tab, `1`, a tab, and the path when A2 applies (A2 replaces one line with fifteen and inserts one more; the row's pass is observed by P4-T12) or prints nothing when it does not. If A2 applies and the row differs from the A2 quotation, stop BLOCKED.
- [ ] [P4-T8] [expect-fail] Observe the gating-caused failure of the Python contract test before adjusting it (PD-13, preflight D4): run `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and write `FEATURE/evidence/regression-testing/p4-py-contract-fail-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Done when the exit code is 1, the short summary carries exactly one line beginning `FAILED tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg` (pytest `-ra` from the project `addopts`; pytest appends ` - <message>` to that line, and the appended text is recorded but not asserted) and no other line beginning `FAILED `, and the summary line reports `1 failed` and `<B-1> passed`, where B is the passed count recorded by P0-T17 (6 in the current tree, so `1 failed, 5 passed`). Any other outcome stops BLOCKED with the observed output. CI job: `quality-checks7 / Code Quality & Tests` (ubuntu-latest).
- [ ] [P4-T9] Apply A1 of section 7 to `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and record the numstat output below in `FEATURE/evidence/regression-testing/p4-py-contract-edit.<timestamp>.md`.
  - Done when `git diff --numstat HEAD -- tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` prints one line reading `10`, a tab, `4`, a tab, and the path (A1 adds the constant line, replaces three docstring lines with five, and replaces the one-line assertion with four lines; six lines of the test are unchanged). Any other count stops BLOCKED with the diff recorded. The behavioural check is P4-T10.
- [ ] [P4-T10] Pass-after for the Python contract test and the other Python workflow readers: run `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py` and write `FEATURE/evidence/regression-testing/p4-py-contract-pass-after.<timestamp>.md`.
  - Done when the exit code is 0, the short summary has no `FAILED` or `ERROR` line, and the summary line reports `passed` with no `failed` and a passed count equal to the P0-T17 three-file count. CI job: `quality-checks7 / Code Quality & Tests` (ubuntu-latest).
- [ ] [P4-T11] Run the workflow suite with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -NamePatternList "<PATTERNS-WORKFLOW>"` and write `FEATURE/evidence/regression-testing/p4-workflow-suite-pass.<timestamp>.md` (AC-23 pass-after); then check off AC-18, AC-19, AC-20, AC-21, and AC-23 in `FEATURE/spec.md`.
  - Done when the `SUITE:` line shows `Passed=39 | Failed=0`, the `NAMED:` lines show `Total=5`, `Total=9`, `Total=21`, `Total=3`, and `Total=1` (AC-18, AC-19, AC-20, AC-21, AC-36) with `Failed=0`, and `EXIT_CODE_COMPUTED: 0`. AC-23 is checked only if the P1-T6 artifact exists with its expected fail outcome. AC-36 is not checked here; P7-T3 checks it after the CI security-scan result (PD-18). CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P4-T12] Run the existing suites against the edited workflows, including any suite adjusted by A2 or A4, with `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-EXISTING-SUITES>" -NamePatternList "reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph,WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE*,WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS*,<PATTERNS-PARSER>"` and write `FEATURE/evidence/regression-testing/p4-existing-suites.<timestamp>.md`. The WF02 and WF03 patterns use the wildcard form because the WF02 row name contains a comma, which CR-PESTER-LIST would treat as a pattern separator.
  - Done when every `CONTAINER:` line shows `Result=Passed`, `TOTAL:` shows `Failed=0`, the three `PATTERNS-PARSER` lines each show `Passed=1 | Failed=0 | Total=1`, `EXIT_CODE_COMPUTED: 0`, and the adjusted-row `NAMED:` lines match the edit-points record: the A2 row line shows `Passed=1 | Failed=0 | Total=1` when `A2-APPLICABLE: yes` and `Total=0` when `no`; the `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE*` and `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS*` lines each show `Passed=1 | Failed=0 | Total=1` when `POSHQC-SHAPE: sharded` and `Total=0` when `main` (on the head at revision time all three show `Total=0`). A failing row in any suite stops BLOCKED and requests a plan revision; no suite outside `## Files Written` is edited. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P4-T13] Record the D6 adjustments (AC-22) in `FEATURE/evidence/other/workflow-suite-adjustment.<timestamp>.md`: for each adjustment made (A1 always; A2 when applicable; A4 when sharded), one line `D6-ADJUSTMENT: <file> | <row, test, or helper name>` followed by the old text, the new text, and the cause (the G1, G7, or G6 line that broke it); the A4 record gives the old and new text of both A4 lines (helper comment line and helper condition line) under its single `D6-ADJUSTMENT:` line. For each adjustment not made, one line `D6-NOT-APPLICABLE: <A2|A3|A4> | <reason>` (A3 is always withdrawn by PD-15). Add the P4-T8 fail-before and P4-T12, P4-T10 pass-after artifact names.
  - Done when the artifact carries one `D6-ADJUSTMENT:` line naming `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and `test_threshold_step_runs_on_every_matrix_leg` (A1, cause G1); one `D6-ADJUSTMENT:` line naming `tests/scripts/workflows/CiWorkflow.Tests.ps1` and the A2 row (cause G7) exactly when `A2-APPLICABLE: yes`; one `D6-ADJUSTMENT:` line naming `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` and the helper `$script:GetResultGateViolation` used by rows WF02 and WF03 (A4, cause G6, aggregator gate step) exactly when `POSHQC-SHAPE: sharded`; a `D6-NOT-APPLICABLE:` line for A3 and for each of A2 and A4 not made (on the head at revision time: one `D6-ADJUSTMENT:` line and three `D6-NOT-APPLICABLE:` lines); and the latest P4-T10 and P4-T12 artifacts show their pass conditions.
- [ ] [P4-T14] Verify the `ci.yml` trigger block (AC-22) with `sh SCRATCH/tools/run-cr.sh cr-onblock` and write `FEATURE/evidence/regression-testing/p4-onblock.<timestamp>.md`.
  - Done when the output shows `ONBLOCK-IDENTICAL: True` and `EXIT_CODE_COMPUTED: 0`, and the `ONBLOCK-HAS-MERGE-GROUP:` value is `True` when the latest edit-points artifact records `CI-MERGE-GROUP: present` and `False` when it records `absent`.
- [ ] [P4-T15] Lint the seven edited workflows with `sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList "<LIST-WORKFLOWS>"` and write `FEATURE/evidence/regression-testing/p4-actionlint.<timestamp>.md`.
  - Done when the output shows `ACTIONLINT-WRAPPER-EXIT: 0`, `ACTIONLINT-DIRECT-EXIT: 0`, `ACTIONLINT-FINDINGS: 0`, and `EXIT_CODE_COMPUTED: 0`. A finding that `filter` is not an input of `actions/checkout@v7` stops BLOCKED for an operator decision, because removing it changes D2.
- [ ] [P4-T16] Commit and push Phase 4 (rule 11): `git add -- .github/workflows/ci.yml .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_build-check.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml .github/workflows/_poshqc.yml tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "ci(962): gate heavy CI steps on the change-scope decision" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-4.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 5 — Workflow README and Shell QC Follow-ups

- [ ] [P5-T1] Apply the three PD-17 corrections of section 10 to `.github/workflows/README.md` (line 4, the row inserted after line 29, line 79) and append the section 10 text after its last line, changing no other existing line.
  - Done when P5-T2 passes.
- [ ] [P5-T2] Verify the README (AC-24, AC-35) with `sh SCRATCH/tools/run-cr.sh cr-readme` and write `FEATURE/evidence/regression-testing/p5-readme.<timestamp>.md`; then check off AC-24 and AC-35 in `FEATURE/spec.md`.
  - Done when the output shows `README-REPLACED-LINES: 1,1`, `README-ANCHOR-HITS: 1`, `README-PREFIX-IDENTICAL: True`, `README-TOKENS-MISSING: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [ ] [P5-T3] Apply S1 of section 6a to `scripts/bash/shell_qc_lib.sh` with the Edit tool (the two bats invocations at lines 262 and 365 and the two-line comment after line 233).
  - Done when P5-T6 shows `SHELL-RECURSIVE-INVOCATIONS: 2` and `SHELL-NONRECURSIVE-INVOCATIONS: 0`.
- [ ] [P5-T4] Apply S2 of section 6a to `scripts/bash/shell_qc_lib.sh` with the Edit tool (the `check_coverage_threshold` function after `print_coverage_summary`, the two-line comment after line 318, and the wiring that replaces lines 389-392; section 6a cites the unedited line numbers, and P5-T3 has already inserted two lines after line 233, so each S2 anchor is located by its quoted text).
  - Done when P5-T6 shows `SHELL-THRESHOLD-FUNCTION: 1`, `SHELL-THRESHOLD-WIRING: 1`, `SHELL-THRESHOLD-DEFAULT-85: 1`, and a `SHELL-LINES: scripts/bash/shell_qc_lib.sh | 432` line.
- [ ] [P5-T5] Apply S3 of section 6a to `scripts/bash/shell-qc.sh` with the Edit tool (three usage lines after line 36).
  - Done when P5-T6 shows `SHELL-USAGE-THRESHOLD-LINE: 1` and a `SHELL-LINES: scripts/bash/shell-qc.sh | 106` line.
- [ ] [P5-T6] Verify the shell edits (AC-37 and AC-38 local evidence, rule 18) with `sh SCRATCH/tools/run-cr.sh cr-shell-static`, adding `-LintInformational` only when the P0-T18 artifact records a `SHELL-LOCAL-LINT:` line with `failing=` greater than 0, and write `FEATURE/evidence/regression-testing/p5-shell-static.<timestamp>.md`.
  - Done when the output shows every CR-SHELL-STATIC success literal of section 5 (including `SHELL-NEW-TESTS-MISSING: 0`, `SHELL-NOUNSET-ASSERTIONS-UPDATED: 2`, `SHELL-NESTED-BATS-FILES: 0`, `SHELL-LINES-OVER-500: 0`, `SHELL-CRLF-FILES: 0`) and `EXIT_CODE_COMPUTED: 0`. The Output Summary records whether local `shellcheck` and `shfmt -d` ran (`SHELL-LOCAL-LINT: ran=<n>`) or are CI-only (`SHELL-TOOL-ABSENT:` lines). AC-37 and AC-38 are not checked here; P7-T4 checks them from CI.
- [ ] [P5-T7] Commit and push Phase 5 (rule 11): `git add -- .github/workflows/README.md 'scripts/*/shell_qc_lib.sh' 'scripts/*/shell-qc.sh' docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "docs(962): correct and extend the workflows README; make shell QC discovery recursive and enforce 85% coverage" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-5.<timestamp>.md`. The two quoted pathspecs name the shell-QC library and wrapper without the token rule 4 forbids.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/`.

### Phase 6 — Final QA Loop

Loop rule: P6-T1 to P6-T17 form one pass. If any of them fails, or if P6-T1 or P6-T2 changes a file, fix the cause (only within `## Files Written`) and restart at P6-T1; each pass writes new artifacts. Stage mapping to `.claude/rules/general-code-change.md`: 1 formatting (PowerShell P6-T1, Python P6-T14), 2 linting (P6-T2, P6-T3, Python P6-T15), 3 type checking (not applicable to PowerShell; Pyright for the Python test file in P6-T16), 4 architecture-boundary tests (no boundary test exists for `scripts/ci`; the purity boundary is CR-STRUCTURE in P6-T11), 5 unit tests (PowerShell with coverage in P6-T4 to P6-T8; Python in P6-T17, without coverage per rule 16), 6 contract and schema checks (P6-T9, plus the suite C config contract and actionlint schema checks), 7 integration (the CI-dependent Phase 7). Shell (D14-c and D14-d, rule 18): formatting and linting are the local `shfmt -d` and `shellcheck` runs inside CR-SHELL-STATIC in P6-T11 when the tools are on PATH; type checking is not applicable; bats tests and kcov coverage run in CI and are read in P7-T4.

- [ ] [P6-T1] Formatting stage: run `sh SCRATCH/tools/run-cr.sh cr-format -PathList "<LIST-PS-WRITTEN>" -Write`, then `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the output of `git rev-parse --show-toplevel` and `scan_folders` `["scripts/ci", "tests/scripts/ci"]`, recording both `git status --porcelain` and `git diff --numstat HEAD` before and after the MCP call, in `FEATURE/evidence/qa-gates/final-format.<timestamp>.md`.
  - Done when CR-FORMAT shows one `FORMAT-CLEAN:` line per file (every file unchanged) and `FORMAT-DRIFT-COUNT: 0`, the porcelain output after the MCP call equals the output before it, and the `git diff --numstat HEAD` output after the MCP call equals the output before it (no file formatted by the MCP stage; the numstat comparison also detects a rewrite of a file that was already modified before the call, which the porcelain status line alone does not show). Any `FORMAT-WRITTEN:` line, porcelain difference, or numstat difference restarts the loop.
- [ ] [P6-T2] Linting stage: run `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "<LIST-PS-WRITTEN>"`, then `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and `scan_folders`, in `FEATURE/evidence/qa-gates/final-pssa.<timestamp>.md`.
  - Done when CR-PSSA shows `findings=0` for every file, `PSSA-TOTAL: 0`, and `EXIT_CODE_COMPUTED: 0`, and the MCP disposition is `MCP_CALL: returned`.
- [ ] [P6-T3] Workflow lint (AC-25): run `sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList "<LIST-WORKFLOWS>"` and write `FEATURE/evidence/qa-gates/final-actionlint.<timestamp>.md`.
  - Done when the output shows `ACTIONLINT-WRAPPER-EXIT: 0`, `ACTIONLINT-DIRECT-EXIT: 0`, `ACTIONLINT-FINDINGS: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [ ] [P6-T4] Unit-test stage, route compliance: call `mcp__drm-copilot__run_poshqc_test` with the same `workspace_root` and `scan_folders` `["tests/scripts/ci", "tests/scripts/workflows"]` and write `FEATURE/evidence/qa-gates/final-mcp-test.<timestamp>.md`.
  - Done when the artifact records the call disposition `MCP_CALL: returned` (rule 5: no count is read from it). This task runs before P6-T6 because the MCP run overwrites the coverage file. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P6-T5] Unit-test stage, counts (AC-26, AC-28): run `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-NEW-TESTS>,<LIST-EXISTING-SUITES>" -NamePatternList "<PATTERNS-UNIT>,<PATTERNS-WORKFLOW>,<PATTERNS-PARSER>"` in one invocation and write `FEATURE/evidence/qa-gates/final-pester-list.<timestamp>.md`.
  - Done when every `CONTAINER:` line shows `Result=Passed`, `TOTAL:` shows `Failed=0`, every AC `NAMED:` line shows `Failed=0` with its section 8 total, each `PATTERNS-PARSER` line shows `Passed=1 | Failed=0 | Total=1`, and `EXIT_CODE_COMPUTED: 0`. `LIST-EXISTING-SUITES` includes `CiWorkflow.Tests.ps1` and `PoshQcWorkflow.Tests.ps1` whether or not A2 or A4 adjusted them. CI job: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P6-T6] Unit-test stage, PoshQC coverage run: run `sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/ci,tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"` and write `FEATURE/evidence/qa-gates/final-pester-coverage.<timestamp>.md`.
  - Done when the output shows a `COVERAGE-RUN-START-UTC:` line, `Code coverage population: source=config`, and a `Tests Passed:` line with `Failed: 0`, and the process exit code is 0. CI job (the only job that measures PowerShell coverage): `poshqc / PowerShell QC` (windows-latest).
- [ ] [P6-T7] Per-file coverage (AC-27): run `sh SCRATCH/tools/run-cr.sh cr-cov-files -TargetList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1" -NotBefore "<COVERAGE-RUN-START-UTC value from P6-T6>"` and write `FEATURE/evidence/qa-gates/final-coverage-files.<timestamp>.md`.
  - Done when the output shows `COVERAGE-FILE-FRESH: True`, both `COV-FILE:` lines show a numeric `percent=` of at least 85 ending `PASS`, `COV-FILES-FAILING: 0`, and `EXIT_CODE_COMPUTED: 0`. A file below 85% is remediated under PD-8 and the loop restarts. CI job (the only job that measures PowerShell coverage): `poshqc / PowerShell QC` (windows-latest).
- [ ] [P6-T8] Coverage comparison: run `sh SCRATCH/tools/run-cr.sh cr-cov-delta` and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` reporting the baseline total, the post-change total, and the new-code (per-file) coverage.
  - Done when the output shows `BASELINE TOTAL-LINE-COVERAGE:`, `FINAL TOTAL-LINE-COVERAGE:`, two `FINAL COV-FILE:` lines ending `PASS`, `DELTA-NEW-CODE-FILES-FAILING: 0`, and `EXIT_CODE_COMPUTED: 0`. Both changed files are new, so the changed-line coverage is the per-file coverage.
- [ ] [P6-T9] Contract stage (AC-29 recheck): run `sh SCRATCH/tools/run-cr.sh cr-quality-tiers` and `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py`, written to `FEATURE/evidence/qa-gates/final-quality-tiers.<timestamp>.md`.
  - Done when the CR shows `QT-OUTPUT: quality-tiers: OK`, `QT-SCRIPTS-CI-ENTRY: True`, and `EXIT_CODE_COMPUTED: 0`, and the pytest summary reports `passed` with no `failed`.
- [ ] [P6-T10] Scope and history check (AC-22, AC-28, AC-30): run `sh SCRATCH/tools/run-cr.sh cr-scope -AllowedList ".github/workflows/ci.yml,.github/workflows/_quality-checks.yml,.github/workflows/_security-scan.yml,.github/workflows/_build-check.yml,.github/workflows/_shell-coverage.yml,.github/workflows/_drm-copilot-extension-tests.yml,.github/workflows/_poshqc.yml,.github/workflows/README.md,config/ci-docs-only-paths.json,scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,quality-tiers.yml,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py,tests/shell/test_shell_qc_commands.bats" -MergeCommit "<MERGE-COMMIT from the latest merge-integration or re-integration artifact>"` (twenty paths: the eighteen always-written paths of `## Files Written` that rule 4 allows on a command line plus the two conditionally written suites; the recipe adds the two remaining always-written shell paths from `$embeddedAllowed`) (it runs `git diff --name-only origin/main...HEAD`, `git status --porcelain`, and the reflog and ancestry checks) and `sh SCRATCH/tools/run-cr.sh cr-onblock`, written to `FEATURE/evidence/qa-gates/final-scope.<timestamp>.md`.
  - Done when CR-SCOPE shows `SCOPE-FORBIDDEN-PRESENT: 0`, `SCOPE-POLICY-PRESENT: 0`, `SCOPE-OUTSIDE-WRITE-SET: 0`, `SCOPE-HISTORY-REWRITES: 0`, `SCOPE-MERGE-COMMIT-CONTAINED: True`, and `EXIT_CODE_COMPUTED: 0`, and CR-ONBLOCK shows `ONBLOCK-IDENTICAL: True`. Every `D6-ADJUSTMENT:` and `D6-NOT-APPLICABLE:` line of the latest workflow-suite-adjustment artifact is quoted in this artifact, and no `SCOPE-CHANGED:` line names `tests/scripts/workflows/CiWorkflow.Tests.ps1` or `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` unless that artifact carries a `D6-ADJUSTMENT:` line for the same file.
- [ ] [P6-T11] Structure and purity recheck (AC-17) and shell recheck (rule 18): run `sh SCRATCH/tools/run-cr.sh cr-structure`, `sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "<LIST-PS-WRITTEN>"`, and `sh SCRATCH/tools/run-cr.sh cr-shell-static` (with `-LintInformational` under the same condition as P5-T6), written to `FEATURE/evidence/qa-gates/final-structure.<timestamp>.md`.
  - Done when CR-STRUCTURE shows its section 5 success literals with `EXIT_CODE_COMPUTED: 0`, CR-HERMETIC shows one `LINES:` line per file of `LIST-PS-WRITTEN`, `HERMETIC-HITS: 0`, `LINES-OVER-500: 0`, and `EXIT_CODE_COMPUTED: 0`, and CR-SHELL-STATIC shows its section 5 success literals with `EXIT_CODE_COMPUTED: 0`.
- [ ] [P6-T12] README recheck (AC-24): run `sh SCRATCH/tools/run-cr.sh cr-readme` and write `FEATURE/evidence/qa-gates/final-readme.<timestamp>.md`.
  - Done when the output shows `README-PREFIX-IDENTICAL: True`, `README-TOKENS-MISSING: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [ ] [P6-T13] Evidence-location check (AC-31): run `sh SCRATCH/tools/run-cr.sh cr-evidence` and write `FEATURE/evidence/qa-gates/evidence-location.<timestamp>.md`.
  - Done when the output shows a positive `EVIDENCE-FILES:`, `EVIDENCE-NONCANONICAL-COUNT: 0`, `EVIDENCE-OUTSIDE-FEATURE-COUNT: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [ ] [P6-T14] Python formatting stage (rule 16): run `poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and write `FEATURE/evidence/qa-gates/final-python-format.<timestamp>.md`.
  - Done when the output carries `1 file would be left unchanged.` (the success line observed by P0-T17) and the exit code is 0. A `would reformat` line fails the stage; the executor then runs `poetry run black tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, records its `1 file reformatted.` line, and restarts the loop at P6-T1. CI job: `quality-checks7 / Code Quality & Tests` (ubuntu-latest).
- [ ] [P6-T15] Python linting stage: run `poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and write `FEATURE/evidence/qa-gates/final-python-lint.<timestamp>.md`.
  - Done when the output carries `All checks passed!` (observed by P0-T17) and the exit code is 0. The command runs without `--fix`, and the repository Ruff configuration does not enable fix mode (`tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode`), so the stage changes no file.
- [ ] [P6-T16] Python type-checking stage: run `poetry run pyright tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and write `FEATURE/evidence/qa-gates/final-python-types.<timestamp>.md`.
  - Done when the summary line begins `0 errors` (observed by P0-T17) and the exit code is 0.
- [ ] [P6-T17] Python test stage: run `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py` and write `FEATURE/evidence/qa-gates/final-python-tests.<timestamp>.md`.
  - Done when the exit code is 0, the short summary has no `FAILED` or `ERROR` line, and the summary line reports `passed` with no `failed` and a passed count equal to the P0-T17 three-file count. No coverage argument is passed (rule 16). CI job: `quality-checks7 / Code Quality & Tests` (ubuntu-latest).
- [ ] [P6-T18] Record the clean loop pass in `FEATURE/evidence/qa-gates/qa-loop.<timestamp>.md`: `QA-LOOP-PASS: <n>` and, for each of P6-T1 to P6-T17, the artifact name of that pass and its `EXIT_CODE`.
  - Done when the listed pass has every task passing with no file changed by P6-T1, P6-T2, or P6-T14 in that pass.
- [ ] [P6-T19] Check off the QA-dependent criteria and record AC status: check off AC-22, AC-25, AC-26, AC-27, AC-28, AC-30, and AC-31 in `FEATURE/spec.md`, then run `sh SCRATCH/tools/run-cr.sh cr-ac-status` and write `FEATURE/evidence/qa-gates/ac-verification.<timestamp>.md` listing each AC with its status, the verifying artifact, and `PENDING-CI` for AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38.
  - Done when the output shows `AC-CHECKED: 32` and `AC-UNCHECKED: 6`, and the six unchecked IDs are AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38.
- [ ] [P6-T20] Commit and push the final QA evidence (rule 11): `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962` plus any file in `## Files Written` changed by a loop restart (the two shell-QC scripts through the rule 4 pathspecs `'scripts/*/shell_qc_lib.sh'` and `'scripts/*/shell-qc.sh'`), `git commit -m "docs(962): record final QA evidence" -m "<trailer>"`, push, and write `FEATURE/evidence/other/commit-phase-6.<timestamp>.md`.
  - Done when `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` and `git status --porcelain` lists nothing except `?? tools/` (the observation precedes the `commit-phase-6` artifact and this checkbox, per rule 11).

### Phase 7 — CI-Dependent Proof and Post-Proof QA (Orchestrator-Owned, S9)

Owner and timing (PD-12): the item's orchestrator run executes this phase after the pull request exists, at S9 (`.claude/skills/orchestrate/SKILL.md` section `## Step S9 — CI Green Gate`). `<PR>` is the pull request number of the branch. Each command below is the spec `## Proof Procedure` command with the observed values substituted; each artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` and the verbatim output. AC-36, AC-37 and AC-38, AC-32, AC-33, and AC-34 stay unchecked until P7-T3, P7-T4, P7-T5, P7-T13, and P7-T16 respectively verify them (task numbers per PD-23). `SCRATCH` is session-scoped: if the running session's `SCRATCH/tools/` does not hold the section 5 launcher and recipes, write them first exactly as P0-T3 does (rule 4a applies: `.txt` recipes and `run-cr.sh` only). Recipes run through the launcher form of rule 3 (`sh SCRATCH/tools/run-cr.sh cr-<name> <arguments>`, no `pwsh` token in Bash command text), and `gh` and `git` run through whichever shell the orchestrator session permits.

- [ ] [P7-T1] [orchestrator, S9] Proof step P0, baseline timing: run `gh run view 38896898318 --repo drmoisan/drm-copilot --json createdAt,updatedAt,conclusion,headSha` and write `FEATURE/evidence/regression-testing/ci-p0-baseline-timing.<timestamp>.md` with `createdAt`, `updatedAt`, `conclusion`, `headSha`, and `BASELINE-DURATION-SECONDS: <updatedAt - createdAt>`.
  - Done when the artifact carries both timestamps verbatim and a positive integer duration.
- [ ] [P7-T2] [orchestrator, S9] Proof step P1.1, identify the full run: run `gh run list --repo drmoisan/drm-copilot --workflow ci.yml --branch bug/ci-skip-evidence-only-commits-962 --event pull_request --limit 5 --json databaseId,headSha,status,conclusion,createdAt,updatedAt` and, for each completed run listed, `gh run view <id> --repo drmoisan/drm-copilot --json conclusion,jobs --jq '.conclusion, (.jobs[] | [.name,.conclusion] | @tsv)'`, written to `FEATURE/evidence/regression-testing/ci-p1-run-list.<timestamp>.md`.
  - Done when the artifact records `ID1: <id>` and `HEAD1: <sha>` derived by PD-10 (the newest completed run whose `CI full run` job concluded `success`). No such run within the five listed: repeat with `--limit 20` and record the deviation; still none records `AC-32: FAIL`.
- [ ] [P7-T3] [orchestrator, S9] Security-scan result of the first full PR run (D14-b, AC-36, PD-18): run `gh run view <id1> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Security Scanning")) | [.databaseId, .conclusion] | @tsv'` and `gh run view <id1> --repo drmoisan/drm-copilot --log --job <security-scan-job-id-1>`, written to `FEATURE/evidence/regression-testing/ci-security-scan.<timestamp>.md` with the job conclusion, the export and safety output lines quoted verbatim, and one line `SAFETY-RESULT: no-vulnerabilities`, `SAFETY-RESULT: findings`, or `SAFETY-RESULT: other-failure`.
  - `no-vulnerabilities` requires the job conclusion `success`, safety summary lines that report zero vulnerabilities for a non-zero number of scanned packages, and no `No packages found` text (the vacuous form observed in main run 38948304976, job 117132949247); then check off AC-36 in `FEATURE/spec.md`. `findings` (safety reports one or more vulnerabilities): write `FEATURE/evidence/other/security-scan-findings.<timestamp>.md` with one line `SAFETY-FINDING: <package> | <version> | <advisory id>` per finding, record `REMEDIATION-CYCLE: opened` and the decision for the coordinator per PD-18 (restore `continue-on-error: true` on the scan step only), leave AC-36 unchecked, and re-run P7-T2 onward after the remediation merges into the branch. `other-failure` (the plugin install, the export, or another non-safety error failed the job): record the failing log lines, open a remediation cycle that keeps the scan blocking, leave AC-36 unchecked, and re-run P7-T2 onward after it merges. Safety's summary wording is not observed locally (rule 6); the lines are quoted verbatim and classified by the three rules above.
- [ ] [P7-T4] [orchestrator, S9] Shell-coverage results of the first full PR run (D14-c and D14-d; AC-37, AC-38; PD-19 to PD-21): run `gh run view <id1> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Shell Coverage")) | [.databaseId, .conclusion] | @tsv'` and `gh run view <id1> --repo drmoisan/drm-copilot --log --job <shell-coverage-job-id-1>`; the same two commands for the baseline main run 38948304976; `git grep -c -E -e '^[[:space:]]*@test ' <HEAD1> -- tests/shell`; `git ls-tree -r --name-only <HEAD1> -- tests/shell`; `gh run download <id1> --repo drmoisan/drm-copilot --name shell-coverage --dir SCRATCH/stage/kcov-<id1>` and `gh run download 38948304976 --repo drmoisan/drm-copilot --name shell-coverage --dir SCRATCH/stage/kcov-38948304976`; then `sh SCRATCH/tools/run-cr.sh cr-kcov-file -ReportDir SCRATCH/stage/kcov-<id1> -FileSuffix shell_qc_lib.sh` and the same recipe with `-ReportDir SCRATCH/stage/kcov-38948304976`. Write everything to `FEATURE/evidence/regression-testing/ci-shell-coverage.<timestamp>.md` with the derived lines `BATS-TESTS-DECLARED: <sum of the git grep counts>`, `BATS-TESTS-RUN: <n>` (from the TAP plan line `1..<n>` or the bats summary line of the `id1` log, whichever the log carries, quoted verbatim), `NESTED-BATS-AT-HEAD1: <count of ls-tree paths ending .bats with a directory below tests/shell>`, and `BASH-COVERAGE: baseline=<main-run summary percent> | post=<id1 summary percent> | shell_qc_lib.sh=<id1 KCOV-FILE percent> (baseline <main-run KCOV-FILE percent or UNAVAILABLE>)`.
  - Check off AC-37 when the `id1` shell-coverage job concluded `success`, `BATS-TESTS-RUN` equals `BATS-TESTS-DECLARED`, `NESTED-BATS-AT-HEAD1: 0`, the log carries no `not ok ` text, and the names `test passes --recursive to bats for each test directory` and `test --coverage passes --recursive to bats under kcov` appear on `ok` lines. Check off AC-38 when, in addition, the six `check_coverage_threshold` test names of S4 appear on `ok` lines, the `id1` log carries `Bash coverage (lines): <NN.N>%` (the line also observed in main run 38948304976 as `95.2%`) and the line `Bash coverage <NN.N>% meets the minimum line coverage of 85%.` with the same percentage, and the `id1` CR-KCOV-FILE run shows `KCOV-FILE-MATCHES: 1` and a `KCOV-FILE:` line ending `PASS`. If CR-KCOV-FILE prints `KCOV-REPORT: absent` or a match count other than 1, record `BASH-CHANGED-FILE-COVERAGE: UNAVAILABLE`; AC-38 is then remediation-required and stays unchecked (the coverage evidence contract forbids a PASS without the value). Any other unmet condition records `AC-37: FAIL` or `AC-38: FAIL` with the observed lines and opens a remediation cycle. The baseline per-file value is informational; the baseline and post-change totals and the changed-file value are the coverage-delta record for bash.
- [ ] [P7-T5] [orchestrator, S9] Proof steps P1.2 to P1.4 for `id1`: run `gh run view <id1> --repo drmoisan/drm-copilot --json conclusion,jobs --jq '.conclusion, (.jobs[] | [.name,.conclusion] | @tsv)'`, `gh run view <id1> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Change scope")) | .databaseId'`, and `gh run view <id1> --repo drmoisan/drm-copilot --log --job <changes-job-id-1>`, written to `FEATURE/evidence/regression-testing/ci-p1-full-run.<timestamp>.md`; then check off AC-32 in `FEATURE/spec.md` when every expected value holds.
  - Expected (AC-32): run conclusion `success`; `CI full run` `success`; every other job `success` (the heavy jobs); the `Change scope` log holds a line `code=true reason=NO_FULL_GREEN_RUN` or `code=true reason=NON_ALLOWLISTED_PATH: <path>`, quoted verbatim. Any mismatch records `AC-32: FAIL` and leaves the box unchecked.
- [ ] [P7-T6] [orchestrator, S9] Docs-only evidence commit for AC-33: `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "docs(962): record the full-run proof for AC-32" -m "<trailer>"`, push per rule 11, then record `git diff --name-only <head1> HEAD`, `git status --porcelain`, and `git rev-parse HEAD` (as `HEAD2`) in `FEATURE/evidence/regression-testing/ci-p2-commit.<timestamp>.md`.
  - Done when every path listed by the diff starts with `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/` and ends with `.md` (all allowlisted), the porcelain lists nothing except `?? tools/`, and the push is a fast-forward.
- [ ] [P7-T7] [orchestrator, S9] Proof step P2.1 after the run `id2` for `HEAD2` completes: run `gh run view <id2> --repo drmoisan/drm-copilot --json conclusion,createdAt,updatedAt,jobs --jq '.conclusion, .createdAt, .updatedAt, (.jobs[] | [.name,.conclusion] | @tsv)'` and write `FEATURE/evidence/regression-testing/ci-p2-run.<timestamp>.md` with `ID2: <id2>`.
  - Expected: run `success`; `Change scope` `success`; `CI full run` `skipped`; every job whose name starts with `root-typescript-tests` or `NPM Audit Gate` (or `npm-audit-gate`) `skipped`; the 11 required job names of the section 10 table present with `success`.
- [ ] [P7-T8] [orchestrator, S9] Proof steps P2.2 and P2.3: run `gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | [.name, ([.steps[] | select(.conclusion == "success")] | length)] | @tsv'`, `gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | .name as $job | .steps[] | select(.conclusion == "success") | [$job, .name] | @tsv'`, and `gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | .steps[] | select(.name == "Run tests with Pytest") | .conclusion'`, written to `FEATURE/evidence/regression-testing/ci-p2-steps.<timestamp>.md`.
  - Expected: the first command prints four lines, one per `Code Quality & Tests` job, each with the count `2`; the second command prints exactly eight lines, and for each of the four jobs the succeeded step names are exactly `Set up job` and `Complete job` (no other step name appears); the third command prints `skipped` four times. Any other succeeded step name records `AC-33: FAIL` with the printed lines.
- [ ] [P7-T9] [orchestrator, S9] Proof step P2.4: run `gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Change scope")) | .databaseId'` and `gh run view <id2> --repo drmoisan/drm-copilot --log --job <changes-job-id-2>`, written to `FEATURE/evidence/regression-testing/ci-p2-decision-log.<timestamp>.md`.
  - Expected: the log line `code=false reason=DOCS_ONLY_SINCE_<HEAD1>`, quoted verbatim, where the SHA equals `HEAD1` from P7-T2 (or the head of a later run whose `CI full run` concluded `success`, recorded with its run id).
- [ ] [P7-T10] [orchestrator, S9] Proof step P2.5: run `gh api repos/drmoisan/drm-copilot/commits/<HEAD2>/check-runs --paginate --jq '.check_runs[] | [.name,.status,.conclusion] | @tsv'` and write `FEATURE/evidence/regression-testing/ci-p2-check-runs.<timestamp>.md` comparing the names line by line with the 11 contexts of the section 10 table.
  - Expected: each of the 11 contexts appears as `completed` / `success`. Record `CHECK-RUN-NAME-FORM: full` when the API name carries the caller prefix, or `CHECK-RUN-NAME-FORM: suffix` when the comparison had to use the called-job-name suffix (spec P2.5).
- [ ] [P7-T11] [orchestrator, S9] Proof step P2.6: run `gh pr checks <PR> --repo drmoisan/drm-copilot --required --json name,bucket,state` and write `FEATURE/evidence/regression-testing/ci-p2-required-checks.<timestamp>.md`.
  - Expected: 11 entries, all with bucket `pass`.
- [ ] [P7-T12] [orchestrator, S9] Proof step P2.7: run `gh pr view <PR> --repo drmoisan/drm-copilot --json mergeStateStatus,headRefOid` and write `FEATURE/evidence/regression-testing/ci-p2-merge-state.<timestamp>.md` recording the value verbatim.
  - Expected: not `BLOCKED` because of checks (`CLEAN`, or `BEHIND` if `main` moved). If the value is `BLOCKED`, also run `gh pr view <PR> --repo drmoisan/drm-copilot --json reviewDecision,mergeable` and record whether the block is attributable to checks; with P7-T11 at 11 `pass`, a block from review state is recorded as not caused by checks.
- [ ] [P7-T13] [orchestrator, S9] Timing comparison for AC-33: run `gh run view <id2> --repo drmoisan/drm-copilot --json createdAt,updatedAt` and write `FEATURE/evidence/regression-testing/ci-timing-comparison.<timestamp>.md` with `BASELINE-RUN: 38896898318 | <seconds>` (from P7-T1), `DOCS-ONLY-RUN: <id2> | <seconds>`, and `DIFFERENCE-SECONDS: <baseline minus docs-only>`; then check off AC-33 in `FEATURE/spec.md` when P7-T7 to P7-T12 all met their expected values.
  - Done when both durations are recorded as positive integers next to each other (no fixed threshold, per spec). Any unmet P7-T7 to P7-T12 expectation records `AC-33: FAIL` and leaves the box unchecked.
- [ ] [P7-T14] [orchestrator, S9] Proof step P3 edit and its local QA: append the PD-11 line at the end of `scripts/ci/CiChangeScope.psm1` (followed by a newline), then run `git diff --numstat HEAD -- scripts/ci/CiChangeScope.psm1`, `sh SCRATCH/tools/run-cr.sh cr-format -PathList "scripts/ci/CiChangeScope.psm1"`, `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "scripts/ci/CiChangeScope.psm1"`, `sh SCRATCH/tools/run-cr.sh cr-structure`, and `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiChangeScope.Tests.ps1"`, written to `FEATURE/evidence/regression-testing/ci-p3-edit-qa.<timestamp>.md`.
  - Done when the numstat output is exactly one line reading `1`, a tab, `0`, a tab, `scripts/ci/CiChangeScope.psm1` (one line added, none deleted; P2-T3 left the file ending in a newline), CR-FORMAT shows `FORMAT-CLEAN: scripts/ci/CiChangeScope.psm1` (unchanged) and `FORMAT-DRIFT-COUNT: 0`, CR-PSSA shows `PSSA-TOTAL: 0`, CR-STRUCTURE shows `EXIT_CODE_COMPUTED: 0`, and the suite shows `Passed=54 | Failed=0`. CI job for the suite: `poshqc / PowerShell QC` (windows-latest).
- [ ] [P7-T15] [orchestrator, S9] Commit and push the non-allowlisted change: `git add -- scripts/ci/CiChangeScope.psm1 docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`, `git commit -m "test(962): touch CiChangeScope.psm1 to prove a full run after a docs-only skip" -m "<trailer>"`, push per rule 11, and record `git rev-parse HEAD` (as `HEAD3`) and `git status --porcelain` in `FEATURE/evidence/regression-testing/ci-p3-commit.<timestamp>.md`.
  - Done when the push is a fast-forward and the porcelain lists nothing except `?? tools/`.
- [ ] [P7-T16] [orchestrator, S9] Proof step P3 verification for run `id3` on `HEAD3`: repeat the P1 commands of P7-T5 for `id3` and write `FEATURE/evidence/regression-testing/ci-p3-full-run.<timestamp>.md`; then check off AC-34 in `FEATURE/spec.md` when every expected value holds.
  - Expected (AC-34): `CI full run` `success`; every heavy job `success`; the `Change scope` log line `code=true reason=NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1`, quoted verbatim. Any mismatch records `AC-34: FAIL` and leaves the box unchecked.
- [ ] [P7-T17] [orchestrator, S9] Final evidence commit and gate re-run: run `sh SCRATCH/tools/run-cr.sh cr-ac-status`, commit `FEATURE` with `git commit -m "docs(962): record CI proof evidence and check off the CI-dependent criteria" -m "<trailer>"`, push per rule 11, and write `FEATURE/evidence/regression-testing/ci-final-head.<timestamp>.md` with the final `git rev-parse HEAD`, the CR-AC-STATUS output, and the S9 gate result re-run against that head.
  - Done when CR-AC-STATUS shows `AC-CHECKED: 38` and `AC-UNCHECKED: 0` (or names each failed or remediation-pending CI criterion), and the S9 gate records `ci_gate.head_sha` equal to the final head with `ci_gate.conclusion` `success`. This last push changes only allowlisted paths, so its run skips the heavy steps and must still report every required context as `success`.

## Files Written

### Always written

1. `.github/workflows/ci.yml`
2. `.github/workflows/_quality-checks.yml`
3. `.github/workflows/_security-scan.yml`
4. `.github/workflows/_build-check.yml`
5. `.github/workflows/_shell-coverage.yml`
6. `.github/workflows/_drm-copilot-extension-tests.yml`
7. `.github/workflows/_poshqc.yml`
8. `.github/workflows/README.md`
9. `config/ci-docs-only-paths.json`
10. `scripts/ci/CiChangeScope.psm1` (written in P2-T3; one line appended in P7-T14)
11. `scripts/ci/Invoke-CiChangeScope.ps1`
12. `quality-tiers.yml`
13. `tests/scripts/ci/CiChangeScope.Tests.ps1`
14. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`
15. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
16. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
17. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (A1, P4-T9; the `RUN_HEAVY_GATE` constant and the body of `test_threshold_step_runs_on_every_matrix_leg`)
18. `scripts/bash/shell_qc_lib.sh` (D14-c S1 and D14-d S2, P5-T3 and P5-T4; already classified in `quality-tiers.yml` line 22, so no tier entry changes)
19. `scripts/bash/shell-qc.sh` (D14-d S3, P5-T5; three usage lines)
20. `tests/shell/test_shell_qc_commands.bats` (D14-c and D14-d S4, P1-T7; two assertions changed and eight tests appended)

Items 1 to 9 keep their meaning; item 3 (`_security-scan.yml`) also carries the D14-b changes of G2, and item 8 (`.github/workflows/README.md`) also carries the three D14-a corrections of section 10. Verified against the spec and the current tree: no module manifest is required (the entry script imports `scripts/ci/CiChangeScope.psm1` by path, and tier discovery rule R3 needs only a tracked code file under `scripts/ci`); no `quality-tiers.yml` test fixture changes (section 9); no bundle mirror, CHANGELOG, or `.codex/` copy is affected (research §6, §9; `scripts/bash/shell_qc_lib.sh` and `scripts/bash/shell-qc.sh` have no copy under `extensions/drm-copilot/resources/`, verified by search in revision 4); `_shell-coverage.yml` needs no threshold flag (PD-20); no fixture or stub under `tests/fixtures/shell_qc/` changes. The contract-test search of section 7 found no other test under `tests/` that pins a step or job condition of `ci.yml` or the six reusable workflows, and no test reads `_security-scan.yml` or asserts the shell-QC bats argv other than the two S4 assertions.

### Conditionally written

1. `tests/scripts/workflows/CiWorkflow.Tests.ps1` (A2, P4-T7) only when the latest edit-points artifact records `A2-APPLICABLE: yes` (the #952 row `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` is on the head); not written on the head at revision time.
2. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (A4 with A4C, P4-T6) only when it records `POSHQC-SHAPE: sharded`: the condition line of the `BeforeAll` helper `$script:GetResultGateViolation` used by rows `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE` and `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, plus the last line of the comment above that helper (two lines; A3 is withdrawn by PD-15); not written on the head at revision time.

No other existing suite or test is edited; a failure in any other suite after the workflow edits stops BLOCKED (P4-T10, P4-T12). A re-integration under rule 17 can make either conditional file applicable later.

### Feature-folder artifacts

1. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md` (checkbox updates only)
2. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` (AC check-offs only during execution; the PD-22 criterion-text amendments were made by the planning agent in revision 4)
3. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/baseline/<name>.<timestamp>.md` for `phase0-instructions-read`, `branch-state`, `cr-route-probe`, `baseline-pester-list`, `baseline-pester-coverage`, `baseline-coverage-files`, `baseline-format-check`, `baseline-pssa`, `baseline-actionlint`, `baseline-quality-tiers`, `baseline-python`, `baseline-shell-static`
4. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/<name>.<timestamp>.md` for `p1-test-hygiene`, `expect-fail-new-suites`, `fail-before-exception`, `p5-shell-static`, `ci-security-scan`, `ci-shell-coverage`, `p2-config-suite`, `p2-pure-suite`, `p2-tier-entry-diff`, `p2-quality-tiers`, `p3-ci-suites`, `p3-structure`, `p4-poshqc-suite-edit`, `p4-ci-suite-edit`, `p4-py-contract-fail-before`, `p4-py-contract-edit`, `p4-py-contract-pass-after`, `p4-workflow-suite-pass`, `p4-existing-suites`, `p4-onblock`, `p4-actionlint`, `p5-readme`, `ci-p0-baseline-timing`, `ci-p1-run-list`, `ci-p1-full-run`, `ci-p2-commit`, `ci-p2-run`, `ci-p2-steps`, `ci-p2-decision-log`, `ci-p2-check-runs`, `ci-p2-required-checks`, `ci-p2-merge-state`, `ci-timing-comparison`, `ci-p3-edit-qa`, `ci-p3-commit`, `ci-p3-full-run`, `ci-final-head`
5. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/<name>.<timestamp>.md` for `final-format`, `final-pssa`, `final-actionlint`, `final-mcp-test`, `final-pester-list`, `final-pester-coverage`, `final-coverage-files`, `coverage-delta`, `final-quality-tiers`, `final-scope`, `final-structure`, `final-readme`, `evidence-location`, `final-python-format`, `final-python-lint`, `final-python-types`, `final-python-tests`, `qa-loop`, `ac-verification`
6. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/<name>.<timestamp>.md` for `dependency-state`, `merge-integration`, `edit-points`, `workflow-suite-adjustment`, `commit-phase-0` to `commit-phase-6`, and, when their conditions occur, `reintegration` (rule 17) and `security-scan-findings` (PD-18)

### Not written by this plan

- The merge commit of P0-T7 (or of rule 17) brings `origin/main` content into the branch; those paths are not changes of this branch (`git diff origin/main...HEAD` excludes them).
- Downloaded CI artifacts of P7-T4 under `SCRATCH/stage/kcov-<run id>/` (outside the repository).
- Tool outputs that are never staged: `artifacts/pester/*` (gitignored), the Poetry environment `.venv` and the Python caches `__pycache__/` and `.pytest_cache/` (gitignored, `.gitignore` lines 12, 36, 50), and, when actionlint is not on PATH, `tools/actionlint/bin/*` (rule 12).
- Scratch files under `SCRATCH/tools/` (`run-cr.sh` and the `cr-<name>.txt` recipes, written with Write) and `SCRATCH/stage/` (the `cr-<name>.ps1` copies made by the launcher with `cp`), all outside the repository (rule 4a).
- Read-only: `issue.md`, `research/research.2026-10-16T14-39.md`, every file under `.claude/rules/` and `.github/instructions/`, `.github/workflows/_docs-validation.yml`, `.github/workflows/_root-typescript-tests.yml`, `.github/workflows/_npm-audit-gate.yml`, `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
